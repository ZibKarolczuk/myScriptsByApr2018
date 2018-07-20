#!/usr/bin/python

#from repository import colors as C
from repository import functions as F
from repository import outputs as o
from repository import integrity as integrity

import glob, os
import re
import numpy
import shutil
import pprint
import datetime
dateformt = "%d-%b-%Y"

import collections
import sys

cellHeight = 180
JULIANS = {}
AIRLINE_FLEET = {}
AIRLINE_PLACE = {}
COLORS = {}

#print(str(test_var))

### ## # ## ###
# Reading data
os.chdir(".")
DreamLOT = glob.glob("./rawdata/*.html")
DreamLOT.sort()

for file in DreamLOT:
  i=0
  j=100
  reglot = open(file, "r")
  for line in reglot:
    line=line.rstrip()
    if re.match("(.*)class=\"nowrap\"(.*)", line):
      j=0
    j+=1
    if j in range(1,5):

      
      ### ## # ## ###
      # Get basic information
      if j==1:
	i+=1
	m = re.search("a href=\"/live/flight/(?P<REGR>\w+)/[\w,\d,/]+\">(?P<DATE>\d[^<,^>]+).+>(?P<DEPN>\w[^<,^>]+)</span>.+>(?P<ARRN>\w[^<,^>]+)</span>.+\w+.+</span>", line)
	(regr, date, depn, arrn) = (m.group("REGR"), m.group("DATE"), m.group("DEPN"), m.group("ARRN"))
	dt = datetime.datetime.strptime(date, dateformt)
	route = depn + " to " + arrn
	
	if regr not in AIRLINE_FLEET.keys():
	  AIRLINE_FLEET[regr] = {}
	
	AIRLINE_FLEET[regr][int(i)] = {}
	AIRLINE_FLEET[regr][int(i)]['Departure Airport Full'] = depn
	AIRLINE_FLEET[regr][int(i)]['Arrive Airport Full'] = arrn
	AIRLINE_FLEET[regr][int(i)]['Departure Date'] = int(str(dt.timetuple().tm_year) + format(dt.timetuple().tm_yday, '03d'))
	
	if re.search("a href=\"[\w,\d,/]+/history/\d+/\d+Z/[\w,\d]+/[\w,\d]+\"", line):
	  m = re.search("a href=\"[\w,\d,/]+/history/\d+/\d+Z/(?P<DEPC>[\w,\d]+)/(?P<ARRC>[\w,\d]+)\"", line)
	  (depc, arrc) = (m.group("DEPC"), m.group("ARRC"))
	  AIRLINE_FLEET[regr][int(i)]['Departure Airport Code'] = depc
	  AIRLINE_FLEET[regr][int(i)]['Arrive Airport Code'] = arrc
	  
	  if depn not in AIRLINE_PLACE.keys():
	    AIRLINE_PLACE[depn] = depc
	  
	  if arrn not in AIRLINE_PLACE.keys():
	    AIRLINE_PLACE[arrn] = arrc
	  
	else:
	  AIRLINE_FLEET[regr][int(i)]['Departure Airport Code'] = None
	  AIRLINE_FLEET[regr][int(i)]['Arrive Airport Code'] = None
	  
      
      ### ## # ## ###
      # Get Departure Time
      elif j==2:
	if re.search(">[\d,:,\w]+", line):
	  m = re.search(">(?P<TOFF>[\d,:,\w]+)", line)
	  toff = m.group("TOFF")
	  AIRLINE_FLEET[regr][int(i)]['Departure Time'] = toff
	
	else:
	  toff = None
	  AIRLINE_FLEET[regr][int(i)]['Departure Time'] = None
	
	
      ### ## # ## ###
      # Get Arrive Time & Calculate Flight Time
      elif j==3:
	if re.search(">[\d,:,\w]+", line):
	  m = re.search(">(?P<TLND>[\d,:,\w]+)", line)
	  tlnd = m.group("TLND")
	  AIRLINE_FLEET[regr][int(i)]['Arrive Time'] = tlnd
	  
	  if re.search("\(\+\d+\)", line):
	    n = re.search("\(\+(?P<NEXT>\d+)\)", line)
	    dt = dt + datetime.timedelta(days=int(n.group("NEXT")))
	    totl = F.minutes(toff) + int(n.group("NEXT"))*(60*24) - F.minutes(tlnd)
	    AIRLINE_FLEET[regr][int(i)]['Arrive Date'] = int(str(dt.timetuple().tm_year) + format(dt.timetuple().tm_yday, '03d'))
	    AIRLINE_FLEET[regr][int(i)]['Duration'] = str(int(totl/60)) + ":" + format(int(totl%60), '02d')
	  
	  else:
	    totl = F.minutes(toff) - F.minutes(tlnd)
	    AIRLINE_FLEET[regr][int(i)]['Arrive Date'] = int(str(dt.timetuple().tm_year) + format(dt.timetuple().tm_yday, '03d'))
	    AIRLINE_FLEET[regr][int(i)]['Duration'] = str(int(totl/60)) + ":" + format(int(totl%60), '02d')    
	    
	else:
	  tlnd = None
	  AIRLINE_FLEET[regr][int(i)]['Arrive Time'] = None
	
	k = int(str(dt.timetuple().tm_year) + format(dt.timetuple().tm_yday, '03d'))
	JULIANS[k] = {}
	JULIANS[k]['date'] = dt.strftime("%d %b %Y, %A")
	JULIANS[k]['dateHTML'] = dt.strftime("%d") + "&nbsp;" + dt.strftime("%b") + "&nbsp;" + dt.strftime("%Y") + "<br>" + dt.strftime("%A")
  
      ### ## # ## ###
      # Status check
      elif j==4:
	if re.search("En Route", line):
	  AIRLINE_FLEET[regr][i]['Status'] = "Scheduled flight"
	  
	elif re.search("Cancelled", line):
	  AIRLINE_FLEET[regr][i]['Status'] = "Cancelled flight"
	  
	elif AIRLINE_FLEET[regr][i]['Departure Airport Full'] == AIRLINE_FLEET[regr][i]['Arrive Airport Full']:
	  AIRLINE_FLEET[regr][i]['Status'] = "Technical flight"
	  
	elif re.search("Diverted", line):
	  AIRLINE_FLEET[regr][i]['Status'] = "Diverted"
	  for x in range(i-3,i):
	    if ( (AIRLINE_FLEET[regr][x]['Departure Airport Full'] == AIRLINE_FLEET[regr][i]['Departure Airport Full']) and (AIRLINE_FLEET[regr][x]['Arrive Airport Full'] == AIRLINE_FLEET[regr][i]['Arrive Airport Full']) ):
	      AIRLINE_FLEET[regr].pop(x)
	
	elif AIRLINE_FLEET[regr][i]['Departure Airport Code'] == "KPAE" and AIRLINE_FLEET[regr][i]['Arrive Airport Code'] == "EPWA":
	  AIRLINE_FLEET[regr][i]['Status'] = "Delivery flight"
	    
	else:  
	  AIRLINE_FLEET[regr][i]['Status'] = "Scheduled flight"

### ## # ## ###
# Data integrity check
integrity.gaps()
integrity.diverted()
integrity.gaps()
integrity.duplicated()
integrity.gaps()
integrity.julian()
integrity.gaps()
integrity.names()
integrity.gaps()

### ## # ## ###
# Writing to outputs:
o.datesJS()
o.flightsJS()
o.graphJS()
