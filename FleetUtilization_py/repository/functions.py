#! /usr/bin/env python
# -*- coding: utf-8 -*-

### ## # ## ###

import glob, os
import re
import numpy
import shutil
import pprint
import datetime
dateformt = "%d-%b-%Y"

### ## # ## ###

import collections
import sys
import __main__

### ## # ## ###

import colors as C

### ## # ## ###

def raw(text):
  """Returns a raw string representation of text"""
  new_string=''
  for char in text:
    try: 
      new_string += C.escape_dict[char]
    except KeyError: 
      new_string += char
  return new_string

### ## # ## ###

def posTime(minutes, scalar, size):
  divide = float(24*60)/float(size)
  result = float(size*scalar) + float(minutes)/divide
  result = int(round(result, 0))
  return result

### ## # ## ###

def minutes(time):
  x = re.search("(?P<HH>\d+):(?P<MM>\d+)", time)
  result = int(x.group("HH"))*60 + int(x.group("MM"))
  result = 24*60 - result
  return result

### ## # ## ###

def trueminutes(time):
  x = re.search("(?P<HH>\d+):(?P<MM>\d+)", time)
  result = int(x.group("HH"))*60 + int(x.group("MM"))
  return result

### ## # ## ###

def time_minute(time):
  x = re.search("(?P<HH>\d+):(?P<MM>\d+)", time)
  return x.group("MM")

### ## # ## ###

def time_hour(time):
  x = re.search("(?P<HH>\d+):(?P<MM>\d+)", time)
  return x.group("HH")

### ## # ## ###

def color(value):
  low = 245
  hi = -20
  delta = 265
  fleet_size = 10
  step = int(delta/(fleet_size))
  color = ((low + 360) - (step * value)) % 360
  return color

### ## # ## ###

def graph_data():
  
  __main__.ground = range(__main__.length + 1, __main__.length + __main__.X['boxGround'] + 1)
  __main__.airborne = range(__main__.length + __main__.X['boxGround'] + 1, __main__.length + __main__.X['boxGround'] + __main__.X['boxAirborne']+1)    
  __main__.length += __main__.X['boxGround'] + __main__.X['boxAirborne']
  
  for g in __main__.ground:
    if g not in __main__.USAGE.keys():
      __main__.USAGE[g] = {}
      __main__.USAGE[g]['value'] = 0
      __main__.USAGE[g]['list'] = ""
      __main__.USAGE[g]['time'] = format(int( ((24*60)-((g%180)*((24*60)/__main__.cellHeight)))/60 ), '02d') + ":" + format(int( ((24*60)-((g%180)*((24*60)/__main__.cellHeight)))%60 ), '02d')
  for a in __main__.airborne:
    if a not in __main__.USAGE.keys():
      __main__.USAGE[a] = {}
      __main__.USAGE[a]['value'] = 0
      __main__.USAGE[a]['list'] = ""
      __main__.USAGE[a]['time'] = format(int( ((24*60)-((a%180)*((24*60)/__main__.cellHeight)))/60 ), '02d') + ":" + format(int( ((24*60)-((a%180)*((24*60)/__main__.cellHeight)))%60 ), '02d')
    if __main__.X['Status'] != "Cancelled flight":
      __main__.USAGE[a]['value'] += 1
    __main__.USAGE[a]['list'] += "<br>" + __main__.k + " : " + __main__.X['Departure Airport Code'] + "&nbsp;to&nbsp;" + __main__.X['Arrive Airport Code']

### ## # ## ###
  
def typetool():
  if (__main__.length > (len(__main__.JULIANS.keys())*180 - 400)):
    return " tooltip-top" 
  elif (__main__.column > 8):
    return " tooltip-left"
  else:
    return ""

### ## # ## ##
