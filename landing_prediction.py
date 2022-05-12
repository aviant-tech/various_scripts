import sys
import numpy as np
from sklearn.neighbors import KDTree
import json
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from geopy import distance

DRONE_LON = None #12.0597
DRONE_LAT = None #62.6406
PLAN_FILENAME = None #'RRS-FUN_QC220510_HK.plan'
CRUISE_SPEED_MPS = None #23
TIMEOUT_S = None #90

assert DRONE_LON is not None
assert DRONE_LAT is not None
assert PLAN_FILENAME is not None
assert CRUISE_SPEED_MPS is not None
assert TIMEOUT_S is not None

with open(PLAN_FILENAME, 'rb') as f:
    plan_json = json.load(f)

plan_wps = plan_json['mission']['items']
wp_lons = [plan_wp['params'][5] for plan_wp in plan_wps]
wp_lats = [plan_wp['params'][4] for plan_wp in plan_wps]
wp_alts = [plan_wp['params'][6] for plan_wp in plan_wps]
wps = list(zip(wp_lons, wp_lats))

lon_avg = np.average(wp_lons)
lat_avg = np.average(wp_lats)

plan_rps = plan_json['rallyPoints']['points']
rp_lons = [plan_rp[1] for plan_rp in plan_rps]
rp_lats = [plan_rp[0] for plan_rp in plan_rps]
rp_alts = [plan_rp[2] for plan_rp in plan_rps]
rps = list(zip(rp_lons, rp_lats))

drone_pos = np.array([DRONE_LON, DRONE_LAT])

prev_wp_idx = None
next_wp_idx = None
min_proximity_score = np.inf
for idx in range(len(wps)-1):
    prev_wp_pos = np.array([wp_lons[idx], wp_lats[idx]])
    next_wp_pos = np.array([wp_lons[idx+1], wp_lats[idx+1]])

    prev_dist = distance.geodesic(drone_pos,prev_wp_pos).m
    next_dist = distance.geodesic(drone_pos,next_wp_pos).m
    tot_dist = distance.geodesic(next_wp_pos,prev_wp_pos).m

    proximity_score = np.abs(prev_dist+next_dist-tot_dist)
    if proximity_score < min_proximity_score:
        min_proximity_score = proximity_score
        prev_wp_idx = idx
        next_wp_idx = idx+1

assert prev_wp_idx is not None, 'Could not find closest waypoint'

def time_between(start, end):
    dist = distance.geodesic(np.array(start), np.array(end)).m
    time = dist/CRUISE_SPEED_MPS
    return time

travel_lons = [DRONE_LON]
travel_lats = [DRONE_LAT]
time_left = TIMEOUT_S

travel_points = [tuple(drone_pos)] + wps[next_wp_idx:]
for cur_pos, next_pos in zip(travel_points[:-1], travel_points[1:]):
    delta_time = time_between(cur_pos, next_pos)
    if delta_time > time_left:
        alpha = time_left/delta_time
        timeout_pos = (1-alpha)*np.array(cur_pos) + alpha*np.array(next_pos)
        travel_lons.append(timeout_pos[0])
        travel_lats.append(timeout_pos[1])
        break
    travel_lons.append(next_pos[0])
    travel_lats.append(next_pos[1])
    time_left -= delta_time

rp_kdtree = KDTree(rps, leaf_size=2)              
_, rp_idxs = rp_kdtree.query([timeout_pos])
rp_idx = rp_idxs[0][0]
travel_lons.append(rp_lons[rp_idx])
travel_lats.append(rp_lats[rp_idx])

fig = go.Figure(
    layout=go.Layout(
        title=go.layout.Title(text=f'Predicted landing location for {PLAN_FILENAME} with cruise speed {CRUISE_SPEED_MPS} m/s and timeout {TIMEOUT_S} s.')
    )
)
fig.add_trace(go.Scattermapbox(
    lon=wp_lons,
    lat=wp_lats,
    mode='lines+markers',
    marker={'color': 'green', 'size': 5 },
    text=[f'#{i+1}: {alt} m' for i, alt in enumerate(wp_alts)],
    name='Mission path',
))
fig.add_trace(go.Scattermapbox(
    lon=rp_lons,
    lat=rp_lats,
    mode='markers',
    marker={'color': 'green', 'size': 10 },
    name='Rally points',
    text=[f'{alt} m' for alt in rp_alts],
))
fig.add_trace(go.Scattermapbox(
    lon=travel_lons,
    lat=travel_lats,
    mode='lines+markers',
    marker={'color': 'yellow', 'size': 5 },
    name='Predicted path',
    hoverinfo='skip',
))
fig.add_trace(go.Scattermapbox(
    lon=[DRONE_LON],
    lat=[DRONE_LAT],
    mode='markers',
    marker={'color': 'blue', 'size': 10 },
    name='Last drone position',
    hoverinfo='name',
))


fig.update_layout(mapbox_style="open-street-map")
fig.update_layout(
    mapbox={
        'zoom': 8,
        'center': {'lon': lon_avg, 'lat': lat_avg},
    },
)
fig.show()
