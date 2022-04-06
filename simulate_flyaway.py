#!venv/bin/python3
from pymavlink import mavutil
from math import *
import time
import random
import sys


while True:
    master = mavutil.mavlink_connection("udp:0.0.0.0:14550")
    print('Waiting for connection...')
    master.wait_heartbeat()
    print('Connected!')

    args_goto = (
        master.target_system, # target system
        master.target_component, # target component
        mavutil.mavlink.MAV_CMD_DO_REPOSITION, # message type
        0, # command index
        -1, # ground speed default
        mavutil.mavlink.MAV_DO_REPOSITION_FLAGS_CHANGE_MODE, # set GOTO mode
        0, # reserved
        0, # desired yaw
        63.4630527, # latitude, Værnes
        10.9184977, # longitude, Værnes
        2000.0, # altitude
    )
    args_transition = (
        master.target_system, # target system
        master.target_component, # target component
        mavutil.mavlink.MAV_CMD_DO_VTOL_TRANSITION, # message type
        0, # command index
        mavutil.mavlink.MAV_VTOL_STATE_FW, # state
        0, # immediate
        0,0,0,0,0 # unused
    )
    print(args_goto)
    master.mav.command_long_send(*args_goto)
    print(args_transition)
    master.mav.command_long_send(*args_transition)
    master.close()
    time.sleep(1)
