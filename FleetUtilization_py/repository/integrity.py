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

import functions as F

### ## # ## ###

def names():
  
  for k in sorted(__main__.AIRLINE_FLEET.keys()):
    for i in sorted(__main__.AIRLINE_FLEET[k].keys()):
    
      X = __main__.AIRLINE_FLEET[k][i]
    
      if re.search("Near", X['Departure Airport Full']):
	X['Departure Airport Full'] = __main__.AIRLINE_FLEET[k][i+1]['Arrive Airport Full']
	X['Departure Airport Code'] = __main__.AIRLINE_FLEET[k][i+1]['Arrive Airport Code']
    
      if X['Departure Airport Code'] is None and X['Departure Airport Full'] in __main__.AIRLINE_PLACE.keys():
	X['Departure Airport Code'] = __main__.AIRLINE_PLACE[X['Departure Airport Full']]
    
      if X['Arrive Airport Code'] is None and X['Arrive Airport Full'] in __main__.AIRLINE_PLACE.keys():
	X['Arrive Airport Code'] = __main__.AIRLINE_PLACE[X['Arrive Airport Full']]
    
      X['posArrive'] = F.posTime(F.minutes(X['Arrive Time']), __main__.JULIANS[X['Arrive Date']]['scalar'], __main__.cellHeight)
      X['posDeparture'] = F.posTime(F.minutes(X['Departure Time']), __main__.JULIANS[X['Departure Date']]['scalar'], __main__.cellHeight)
      X['boxAirborne'] = X['posDeparture'] - X['posArrive']
    
      if int(i) > 1:
	X['boxGround'] = int(X['posArrive']) - int(__main__.AIRLINE_FLEET[k][i-1]['posDeparture'])
      else:
	X['boxGround'] = int(X['posArrive'])

### ## # ## ###

def gaps():
  for regr in sorted(__main__.AIRLINE_FLEET.keys()):
    x = 1;
    for i in sorted(__main__.AIRLINE_FLEET[regr].keys()):
      if i > x:
	if x in __main__.AIRLINE_FLEET[regr].keys():
	  __main__.AIRLINE_FLEET[regr].pop(x)
	__main__.AIRLINE_FLEET[regr][x] = __main__.AIRLINE_FLEET[regr].pop(i)
      x = x + 1

### ## # ## ###

def diverted():
  for regr in sorted(__main__.AIRLINE_FLEET.keys()):
    for i in sorted(__main__.AIRLINE_FLEET[regr].keys()):
      if __main__.AIRLINE_FLEET[regr][i]['Status'] == "Diverted":
	__main__.AIRLINE_FLEET[regr][i-1]['Status'] = "Diverted from original route " + __main__.AIRLINE_FLEET[regr][i]['Departure Airport Code'] + " to " + __main__.AIRLINE_FLEET[regr][i]['Arrive Airport Code']
	for x in range(i-2, i-5, -1):
	  if __main__.AIRLINE_FLEET[regr][i-1]['Arrive Airport Code'] == __main__.AIRLINE_FLEET[regr][x]['Departure Airport Code'] and __main__.AIRLINE_FLEET[regr][i]['Arrive Airport Code'] == __main__.AIRLINE_FLEET[regr][x]['Arrive Airport Code']:
	    __main__.AIRLINE_FLEET[regr][x]['Status'] = "Continue disrupted flight to " + __main__.AIRLINE_FLEET[regr][x]['Arrive Airport Code']
	__main__.AIRLINE_FLEET[regr].pop(i)

### ## # ## ###

def duplicated():
  for regr in sorted(__main__.AIRLINE_FLEET.keys()):
    for i in sorted(__main__.AIRLINE_FLEET[regr].keys()):
      if i > 1:
	curr = __main__.AIRLINE_FLEET[regr][i]
	prev = __main__.AIRLINE_FLEET[regr][i-1]
	if ( ( curr['Departure Airport Code'] == prev['Departure Airport Code']) and (curr['Arrive Airport Code'] == prev['Arrive Airport Code']) and (curr['Departure Date'] == prev['Departure Date']) ):
	  __main__.AIRLINE_FLEET[regr].pop(i-1)

### ## # ## ###
def julian():
  y = int(str(min(__main__.JULIANS.keys()))[:4])
  j = int(str(min(__main__.JULIANS.keys()))[4:])

  if y%4==0:
    J = range(j,367)
  else:
    J = range(j,366)
  for j in J:
    temp = int(str(y) + format(j, '03d'))
    if temp not in __main__.JULIANS.keys() and temp < max(__main__.JULIANS.keys()):
      #print(temp)
      dt = datetime.datetime.strptime(str(temp), "%Y%j")
      k = int(str(dt.timetuple().tm_year) + format(dt.timetuple().tm_yday, '03d'))
      __main__.JULIANS[k] = {}
      __main__.JULIANS[k]['date'] = dt.strftime("%d %b %Y, %A")
      __main__.JULIANS[k]['dateHTML'] = dt.strftime("%d") + "&nbsp;" + dt.strftime("%b") + "&nbsp;" + dt.strftime("%Y") + "<br>" + dt.strftime("%A")
      print(__main__.JULIANS[k]['date'])
      print(dt.strftime("%d %b %Y, %A"))

  i = 0
  for k in sorted(__main__.JULIANS.keys(), reverse=True):
    __main__.JULIANS[k]['scalar'] = i
    i+=1

### ## # ## ###