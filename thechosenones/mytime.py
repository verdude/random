#!/usr/bin/env python3

import argparse
import logging
import json
import os
import math
import sys

EARLIEST_IN_TIME = 0
LATEST_OUT_TIME = 23.999999

def convert_to_military(time):
    tag = time[-2:]
    afternoon = "PM" in tag
    time = time[:-2]
    units = time.split(":")
    if afternoon and int(units[0]) < 12:
        units[0] = str(int(units[0]) + 12)
    return ":".join(units)

def convert_to_value(time):
    if time.endswith("M"):
        time = time[:-2]
    units = [int(x) for x in time.split(":")]
    seconds_as_fraction_of_hours = units[2] / 60 / 60
    minutes_as_fraction_of_hours = units[1] / 60
    return seconds_as_fraction_of_hours + minutes_as_fraction_of_hours + units[0]

def val_to_military(val):
    # casts to int are to truncate the float
    hours = int(val)
    # get remainder
    minutes = (val - hours) * 60
    # get ceiling of remainder of minutes
    seconds = math.ceil((minutes - int(minutes)) * 60)
    seconds = seconds if seconds < 60 else 59
    return str(hours) + ":" + str(int(minutes)).zfill(2) + ":" + str(seconds).zfill(2)

def military_to_ampm(mili):
    units = mili.split(":")
    hour = int(units[0])
    tag = "PM" if hour >= 12 else "AM"
    if hour > 12:
        units[0] = str(hour - 12)
    return ":".join(units) + tag

def calc_elapsed(clock_in, clock_out):
    val_in = convert_to_value(convert_to_military(clock_in))
    val_out = convert_to_value(convert_to_military(clock_out))
    logging.info("Elapsed hours [%f]" % (val_out - val_in))
    return val_out - val_in

def calc_out(clock_in, total, desired):
    if total >= desired:
        logging.error("Desired hours should be greater than the total hours")
        sys.exit()
    val_in = convert_to_value(convert_to_military(clock_in))
    remaining = desired - total
    # check if over 24
    val_out = remaining + val_in
    if val_out > 24:
        logging.warning("Desired hours cannot be attained, truncating clock-out time to 11:59:59PM")
        remainder = val_out - LATEST_OUT_TIME
        val_out = val_out - remainder
        logging.warning("Out value adjusted to [%f]" % val_out)
        logging.warning("Hours remaining after truncation [%f]" % remainder)
    out_time = military_to_ampm(val_to_military(val_out))
    return out_time

def calc_in(clock_out, total, desired):
    if total >= desired:
        logging.error("Desired hours should be greater than the total hours")
        sys.exit()
    val_out = convert_to_value(convert_to_military(clock_out))
    remaining = desired - total
    val_in = val_out - remaining
    if val_in < 0:
        logging.warning("Desired hours cannot be attained, truncating clock-in time to 0:00:00AM")
        remainder = EARLIEST_IN_TIME - val_in
        val_in = EARLIEST_IN_TIME
        logging.warning("In vlaue adjusted to [%f]" % val_out)
        logging.warning("Hours remaining after truncation [%f]" % remainder)
    in_time = military_to_ampm(val_to_military(val_in))
    return in_time

def parse_options():
    parser = argparse.ArgumentParser(prog="Clolc",
        description="Calculates the time elapsed between a clock out and in or returns the clock out time to reach the desired amount of hours",
        add_help=True)
    parser.add_argument("-d", "--debug", action="store_true", help="set logging to debug")
    parser.add_argument("-q", "--quiet", action="store_true", help="set logging to quiet")
    parser.add_argument("-t", "--total", action="store", type=float, help="The total amount of hours for the week.")
    parser.add_argument("-s", "--desired", action="store", type=float, help="The hours goal for the week.", default=40)
    parser.add_argument("-i", "--clock-in", action="store", help="format: HH:MM:SS[AM|PM]")
    parser.add_argument("-o", "--clock-out", action="store", help="format: HH:MM:SS[AM|PM]")
    return parser.parse_args()

if __name__ == "__main__":
    args = parse_options()
    if args.quiet:
        lg_level = logging.WARN
    elif args.debug:
        lg_level = logging.DEBUG
    else:
        lg_level = logging.INFO
    logging.basicConfig(level=lg_level)

    if args.clock_out is not None and args.clock_in is not None:
        elapsed = calc_elapsed(args.clock_in, args.clock_out)
        print("Elapsed Time: %s" % elapsed)
    elif args.clock_in is not None and args.total is not None:
        clock_out_time = calc_out(args.clock_in, args.total, args.desired)
        print("Clock Out time: %s" % clock_out_time)
    elif args.clock_out is not None and args.total is not None:
        clock_out_time = calc_in(args.clock_out, args.total, args.desired)
        print("Clock In time: %s" % clock_out_time)
    else:
        logging.error("No punches provided.")
