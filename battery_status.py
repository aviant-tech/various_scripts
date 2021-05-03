import numpy as np
import numbers
# from sys import exit
from pandas import read_csv
from matplotlib import pyplot as plt
from scipy.integrate import cumtrapz

flight_name = '17_35_25'
log_format = 'logs/%s/%s_%%s.csv' % (flight_name, flight_name)


def read_table(table_name):
    log_filename = log_format % table_name
    print('Reading %s' % log_filename)
    data = read_csv(log_filename)
    print('Headers: %s' % data.keys())
    return data


battery_data = read_table('battery_status_0')
battery_timestamps = battery_data['timestamp'].values/1e6
battery_fraction = battery_data['remaining']
discharged = battery_data['discharged_mah']


mission_data = read_table('mission_result_0')
curr_wp = np.unique(mission_data['seq_current'])
mission_timestamp = mission_data['timestamp'].values/1e6

battery_at_wp = []
discharged_at_wp = []
wp_timestamps = []


for i in range(len(curr_wp)):
    if(i == 0):
        wp_timestamp = mission_timestamp[2]
        wp_timestamps.append(wp_timestamp)
    else:
        wp_timestamp = mission_timestamp[i]
        wp_timestamps.append(wp_timestamp)

    
    battery_index = np.where(abs(battery_timestamps - wp_timestamp < 1 ))[-1][-1]
    battery_at_wp.append(battery_fraction[battery_index]*100)
    discharged_at_wp.append(discharged[battery_index])

#plt.figure()
#plt.plot(battery_timestamps/60, battery_fraction*100, '-', label='Remaining percentage displayed')
#plt.legend()
#plt.xlabel('t / min')
#plt.ylabel('Percent')
#plt.title('Pusher battery percentage')
#plt.show()
#
#plt.figure()
#plt.plot(curr_wp, battery_at_wp, '-', label='Remaining percentage displayed')
#plt.legend()
#plt.xlabel('wp')
#plt.ylabel('Percent')
#plt.title('Pusher battery percentage')
#plt.show()
#
#plt.figure()
#plt.plot(curr_wp, discharged_at_wp, '-', label='Remaining percentage displayed')
#plt.legend()
#plt.xlabel('wp')
#plt.ylabel('Percent')
#plt.title('Pusher battery percentage')
#plt.show()

f = open("Battery_status_at_wp","w")
f.write("WP \t % \t discharge \n")
for i in range(len(curr_wp)):
    line = str(curr_wp[i] + 1 ) + '\t' + str(battery_at_wp[i]) + '\t' + str(discharged_at_wp[i]) + '\n'
    f.write(line)
f.close()

