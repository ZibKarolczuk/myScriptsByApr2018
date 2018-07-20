#! /usr/bin/env python
# -*- coding: utf-8 -*-
#
# by Zbigniew Karolczuk, 20 November 2017

import mainFunctions as importDef

## FETCHING DATA DO DIFFERENT DATABASES

def databases(MAIN,STATS,PERFORMANCE,FLIGHTS,BIGDATA):
  for m in MAIN.keys():
    STATS[m]=list()
    for i in MAIN.keys():
      if i != m:
	STATS[m].append(i)

  i = 0
  f = open("import/dbFlights - performanceAircraft.csv", 'r')
  for line in f:
    line=line.rstrip()
    STRINGS = line.split(",")
    if i > 0 and len(STRINGS[1]) > 0:
      PERFORMANCE[STRINGS[1]] = {}
      PERFORMANCE[STRINGS[1]]["TYPE"] = STRINGS[2]
      PERFORMANCE[STRINGS[1]]["V_KT"] = int(STRINGS[3])
      PERFORMANCE[STRINGS[1]]["VKMH"] = int(str("%.0f" % (int(STRINGS[3])*1.852)))
    i += 1
  f.close()

  i = 0
  f = open("import/dbFlights - myFlights.csv", 'r')
  for line in f:
    line=line.rstrip()
    STRINGS = line.split(",")
    if i > 0 and len(STRINGS[1]) > 0:    
      FLIGHTS[i] = {}
      FLIGHTS[i]["DATE"] = STRINGS[1]
      FLIGHTS[i]["YEAR"] = STRINGS[1].split("-")[0]
      FLIGHTS[i]["DURTION"] = int(STRINGS[2].split(":")[0])*60 + int(STRINGS[2].split(":")[1])
      FLIGHTS[i]["DEPARTE"] = STRINGS[3]
      FLIGHTS[i]["ARRIVAL"] = STRINGS[4]
      FLIGHTS[i]["COUNTRY"] = STRINGS[5]
      FLIGHTS[i]["AIRCRAFT"] = STRINGS[6]
      FLIGHTS[i]["TYPE"] = PERFORMANCE[STRINGS[6]]["TYPE"]
      FLIGHTS[i]["DIST_KM"] = int(str("%.0f" % (PERFORMANCE[STRINGS[6]]["VKMH"]*FLIGHTS[i]["DURTION"]/60)))
      FLIGHTS[i]["DIST_NM"] = int(str("%.0f" % (FLIGHTS[i]["DIST_KM"] * 0.54)))   
      FLIGHTS[i]["COMPANY"] = STRINGS[7]
      FLIGHTS[i]["REMARKS"] = STRINGS[8]
    i+=1
  f.close()
  for k in ("YEAR","TYPE","AIRCRAFT","DEPARTE","ARRIVAL","COUNTRY","COMPANY"):
    BIGDATA[k] = {}
    for i in FLIGHTS.keys():
      importDef.populate(BIGDATA,FLIGHTS,int(i),k)

## PROCESSING DATA FOR WEBSITE STATISTICS

def bigdata(COMMONS, ATTRIBUTES, ATTR_TABLE, MAIN, BIGDATA, STATS, FLIGHTS, PROCESSING):
  i = 0
  for k in ATTR_TABLE[ATTRIBUTES[i]]:  
    if "ALL" in ATTR_TABLE[ATTRIBUTES[i]]:
      for y in  MAIN[ATTRIBUTES[i]]:
	for k in BIGDATA[y].keys():
	  COMMONS +=  BIGDATA[y][k]
    else:
      for y in  MAIN[ATTRIBUTES[i]]:
	COMMONS += BIGDATA[y][k]

  COMMONS = set(COMMONS)

  if len(ATTRIBUTES) > 1:
    for i in range(1,len(ATTRIBUTES)):
      Attribute = list()
      if "ALL" in ATTR_TABLE[ATTRIBUTES[i]]:
	for y in  MAIN[ATTRIBUTES[i]]:
	  for k in BIGDATA[y].keys():
	    Attribute +=  BIGDATA[y][k]
      else:
	for k in ATTR_TABLE[ATTRIBUTES[i]]:
	  for y in  MAIN[ATTRIBUTES[i]]:
	    Attribute +=  BIGDATA[y][k]
	    
      COMMONS = set(COMMONS) & set(Attribute)

  ATTR_REPORT = STATS[ATTRIBUTES[0]]

  if len(ATTRIBUTES) > 1:
    for i in range(1,len(ATTRIBUTES)):
      ATTR_REPORT = set(ATTR_REPORT) & set(STATS[ATTRIBUTES[i]])

  for x in ATTRIBUTES:
    PROCESSING[x] = {}
    
    for main_key in MAIN[x]:
      for main_val in BIGDATA[main_key].keys():
	results = set(BIGDATA[main_key][main_val]) & set(COMMONS)
	if len(results) > 0:
	  if not main_val in PROCESSING[x].keys():
	    PROCESSING[x][main_val] = {}
	    PROCESSING[x][main_val]['commons'] =list()
	  PROCESSING[x][main_val]['commons'] += results
      
    for y in PROCESSING[x].keys():
      PROCESSING[x][y]['total'] = importDef.totalFlights(set(PROCESSING[x][y]['commons']))
      PROCESSING[x][y]['duration'] = importDef.formatTime(importDef.totalTime(set(PROCESSING[x][y]['commons']), FLIGHTS))
      PROCESSING[x][y]['duration_raw'] = str(importDef.totalTime(set(PROCESSING[x][y]['commons']), FLIGHTS))
      PROCESSING[x][y]['distance'] = importDef.totalDistance(set(PROCESSING[x][y]['commons']), FLIGHTS)
      PROCESSING[x][y]['distance_raw'] = str(importDef.totalDistanceNoKM(set(PROCESSING[x][y]['commons']), FLIGHTS))
      PROCESSING[x][y]['headers'] = {}
      
      for h in (set(MAIN.keys()) - set([x])):
	PROCESSING[x][y]['headers'][h] = {}
	for hx in MAIN[h]:
	  for hy in BIGDATA[hx].keys():
	    results = set(BIGDATA[hx][hy]) & set(PROCESSING[x][y]['commons'])
	    if not hy in PROCESSING[x][y]['headers'][h].keys() and len(results) > 0:
	      PROCESSING[x][y]['headers'][h][hy] = {}
	      PROCESSING[x][y]['headers'][h][hy]['commons'] = list()
	    if len(results) > 0:
	      PROCESSING[x][y]['headers'][h][hy]['commons'] += results
	for hx in PROCESSING[x][y]['headers'].keys():
	  for hy in PROCESSING[x][y]['headers'][hx].keys():
	    PROCESSING[x][y]['headers'][hx][hy]['total'] = importDef.totalFlights(set(PROCESSING[x][y]['headers'][hx][hy]['commons']))
	    PROCESSING[x][y]['headers'][hx][hy]['duration'] = importDef.formatTime(importDef.totalTime(set(PROCESSING[x][y]['headers'][hx][hy]['commons']), FLIGHTS))
	    PROCESSING[x][y]['headers'][hx][hy]['distance'] = importDef.totalDistance(set(PROCESSING[x][y]['headers'][hx][hy]['commons']), FLIGHTS)
	    for cmmn in sorted(set(PROCESSING[x][y]['headers'][hx][hy]['commons'])):
	      PROCESSING[x][y]['headers'][hx][hy]['distance'] = importDef.totalDistance(set(PROCESSING[x][y]['headers'][hx][hy]['commons']), FLIGHTS)
