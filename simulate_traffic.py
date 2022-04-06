#!venv/bin/python3

from pymavlink import mavutil
from math import *
import time
import random
import sys

master = mavutil.mavlink_connection("udpin:0.0.0.0:14540")

r_earth = 6317e3

incoming_heading = 90-20 # degrees
incoming_speed = 90 # meters per second
incoming_dist = 10000 # meters
incoming_alt = 500 # meters
update_rate = 5 # seconds

callsign = 'DOC28'
if len(sys.argv) > 1:
    callsign = sys.argv[1]
    print('Using callsign %s' % callsign)


coll_lat = None
coll_lon = None
coll_alt = None
coll_heading = None
prev_time = None


def dxy2dlatlon(dx, dy, lat, lon):
    dlat = (dy / r_earth) * (180 / pi)
    dlon = (dx / r_earth) * (180 / pi) / cos(lat * pi / 180)
    return dlat, dlon


initiated = False
while True:
    if not initiated:
        recv = master.recv_match()
        if recv is None:
            continue
        msg_id = recv.get_msgId()
        if msg_id == mavutil.mavlink.MAVLINK_MSG_ID_GLOBAL_POSITION_INT:
            msg = recv.to_dict()
            print(msg)

            lat = msg['lat'] * 1e-7
            lon = msg['lon'] * 1e-7
            alt = msg['alt'] * 1e-3
            heading = msg['hdg'] * 1e-2

            dx = incoming_dist*sin((heading + incoming_heading)/180*pi)
            dy = incoming_dist*cos((heading + incoming_heading)/180*pi)
            dlat, dlon = dxy2dlatlon(dx, dy, lat, lon)
            coll_lat = lat + dlat
            coll_lon = lon + dlon
            coll_alt = alt +  incoming_alt
            coll_heading = (heading + incoming_heading + 180) % 360
            prev_time = time.time()

            initiated = True
        time.sleep(0.1)

    if initiated:
        dt = time.time() - prev_time
        prev_time = time.time()
        ds = incoming_speed * dt
        dx = ds*sin(coll_heading*pi/180)
        dy = ds*cos(coll_heading*pi/180)
        dlat, dlon = dxy2dlatlon(dx, dy, lat, lon)
        coll_lat += dlat
        coll_lon += dlon

        args = (
            63, # icao
            int(coll_lat*1e7), # lat E7
            int(coll_lon*1e7), # lon E7
            mavutil.mavlink.ADSB_ALTITUDE_TYPE_PRESSURE_QNH,
            int(coll_alt*1e3), # altitude mm
            int(coll_heading * 1e2), # heading cdeg
            int(incoming_speed * 1e2), # hor vel cm/s
            0, # ver vel cm/2
            callsign.encode('ascii'), # callsign[8]
            mavutil.mavlink.ADSB_EMITTER_TYPE_ROTOCRAFT, # emitter type
            1, # seconds since last comm
            65535, # flags
            1234, # squawk
        )
        

        print(args)
        master.mav.adsb_vehicle_send(*args)
        time.sleep(random.random()*update_rate)
