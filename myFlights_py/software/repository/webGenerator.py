#! /usr/bin/env python
# -*- coding: utf-8 -*-
#
# by Zbigniew Karolczuk, 20 November 2017 

import sys, os
import re as regex
import datetime
import shutil
import mainFunctions as importDef

## GENERATING HTML FILE

def html(PROCESSING, FLIGHTS, MAIN_CATEGORIES):
  
  now = datetime.datetime.now()
  webname = "website/myFlightsStats, " + now.strftime("%d %b %Y") + ".html"
  website = open(webname, "w")
  templte = open("software/repository/template.html", 'r')

  for line in templte:
    line=line.rstrip()
    
    if regex.search("<button>#BUTTON</button>", line):
      for table in sorted(PROCESSING.keys()):
	website.write("  <button class=\"tablinks\" onclick=\"openTable(event, '" + str(table) + "')")
	if table == "YEAR":
	  website.write("\" id=\"defaultOpen")
	website.write("\">" + str(table) + "</button>\n")
      for table in ("CSV FILE","my SKYDIVES"):
	website.write("  <button class=\"tablinks\" onclick=\"openTable(event, '" + str(table) + "')\">" + str(table) + "</button>\n")
    
    elif regex.search("<div>#TABLE</div>", line):
      for table in sorted(PROCESSING.keys()):
	ITEMS = sorted(PROCESSING[table].keys())
	HEADERS = sorted(PROCESSING[table][ITEMS[0]]['headers'].keys())
	
	tabout  = "\n<div id=\"" + str(table) + "\" class=\"tabcontent\">\n"
	tabout += "  <p><table id=\"" + table + "\" width=\"97%\" align=\"center\">\n  <thead>\n    "
	tabout += "<tr>"
	tabout += "<th><a onclick=\"sortStringsTable(0,'" + table + "')\">" + table + "</a></th>"
	tabout += "<th>SUMMARY BY...<br><i>"
	tabout += "<a onclick=\"sortValuesTable(2,'" + table + "')\" > flights </a>"
	tabout += "<a onclick=\"sortValuesTable(3,'" + table + "')\" > distance </a>"
	tabout += "<a onclick=\"sortValuesTable(4,'" + table + "')\" > duration </a></i>"
	tabout += "</th>"
	tabout += "<th style=\"display:none;\">FLIGHTS</th>"
	tabout += "<th style=\"display:none;\">DISTANCE_RAW</th>"
	tabout += "<th style=\"display:none;\">DURATION_RAW</th>"
	for header in HEADERS:
	  tabout += "<th>" + header + "</th>"
	tabout += "</tr>\n  </thead>\n  <tbody id=\"data\">\n"
	
	DICT_I = {}
	for item in ITEMS:
	  DICT_I[item] = len(set(PROCESSING[table][item]['commons']))
	i = 1
	for dict_iv in sorted(set(DICT_I.values()), reverse=True):
	  for item in ITEMS:
	    if dict_iv == len(set(PROCESSING[table][item]['commons'])):
	      
	      LINELIST = list()
	      for x in sorted(FLIGHTS.keys()):
		for y in MAIN_CATEGORIES[table]:
		  if item == FLIGHTS[x][y]:
		    LINELIST.append(x)
	      
	      allFlights     = int(importDef.totalFlights(FLIGHTS.keys()))
	      allDistance    = importDef.totalDistance(FLIGHTS.keys(), FLIGHTS)
	      allDuration    = importDef.formatTime(importDef.totalTime(FLIGHTS.keys(), FLIGHTS))
	      statFlights    = str("%2.2f" % (((float(PROCESSING[table][item]['total']) / allFlights)) * 100))
	      statDistance   = str("%2.2f" % (((float(PROCESSING[table][item]['distance_raw']) / float(importDef.totalDistanceNoKM(FLIGHTS.keys(), FLIGHTS)))) * 100))
	      statDuration   = str("%2.2f" % (((float(PROCESSING[table][item]['duration_raw']) / float(importDef.totalTime(FLIGHTS.keys(), FLIGHTS)))) * 100))
	      
	      VISITED_EVENT  = list()
	      map(lambda x: VISITED_EVENT.append(FLIGHTS[x]['ARRIVAL']), PROCESSING[table][item]['commons'])
	      map(lambda x: VISITED_EVENT.append(FLIGHTS[x]['DEPARTE']), PROCESSING[table][item]['commons'])
	      VISITED_TOTAL  = list()
	      map(lambda x: VISITED_TOTAL.append(FLIGHTS[x]['ARRIVAL']), FLIGHTS.keys())
	      map(lambda x: VISITED_TOTAL.append(FLIGHTS[x]['DEPARTE']), FLIGHTS.keys())
	      
	      l = 0
	      box_m = ""
	      for linelist in sorted(set(LINELIST)):
		if l > 0:
		  box_m += "<br>"
		box_m += str(FLIGHTS[linelist]["DATE"]) + " , "
		box_m += str(FLIGHTS[linelist]["DEPARTE"]) + " to " + str(FLIGHTS[linelist]["ARRIVAL"]) + " <br>"
		box_m += str(importDef.formatNumber(FLIGHTS[linelist]["DIST_KM"])) + " km @ "
		box_m += importDef.formatTime(FLIGHTS[linelist]["DURTION"]) + " , " + str(FLIGHTS[linelist]["AIRCRAFT"]) + " <br>"
		l += 1
		
	      box_s  = "Overall summary:<br>"
	      box_s += str(statFlights) + "% of total flights (" + str(allFlights) + ") <br>"
	      box_s += str(statDistance) + "% of total distance flown (" + str(allDistance) + ") <br>"
	      box_s += str(statDuration) + "% of total time traveled (" + str(allDuration) + ") <br><br>"
	      box_s += "Visited " + str(len(set(VISITED_EVENT))) + " airfields of total " + str(len(set(VISITED_TOTAL))) + "<br>"
	      box_s += "Visited " + str(len(set(map(lambda x: FLIGHTS[x]['COUNTRY'], PROCESSING[table][item]['commons']))))
	      box_s += " countries of total " + str(len(set(map(lambda x: FLIGHTS[x]['COUNTRY'], FLIGHTS.keys())))) + "<br>"
	      box_s += "Used " +  str(len(set(map(lambda x: FLIGHTS[x]['COMPANY'], PROCESSING[table][item]['commons']))))
	      box_s += " fly companies of total " + str(len(set(map(lambda x: FLIGHTS[x]['COMPANY'], FLIGHTS.keys())))) + "<br>"
	      box_s += "Traveled with " + str(len(set(map(lambda x: FLIGHTS[x]['AIRCRAFT'], PROCESSING[table][item]['commons']))))
	      box_s += " different aircrafts of total " + str(len(set(map(lambda x: FLIGHTS[x]['AIRCRAFT'], FLIGHTS.keys())))) + "<br>"
	      box_s += "Flights executed in " + str(len(set(map(lambda x: FLIGHTS[x]['YEAR'], PROCESSING[table][item]['commons']))))
	      box_s += " years of total " + str(len(set(map(lambda x: FLIGHTS[x]['YEAR'], FLIGHTS.keys())))) + "<br>"
	      
	      item_fl = "Flights: " + str(dict_iv)
	      item_ds = "Distance: " + PROCESSING[table][item]['distance']
	      item_tm = PROCESSING[table][item]['duration']
	      
	      function = "tooltipUpR"
	      if i >= len(ITEMS)-1:
		function = "tooltipDwR"
	      tabout += "    <tr>"
	      tabout += "<td><a>" + importDef.toolTip(function, str(item), box_m) + "</a></td>"
	      tabout += "<td><a>" + importDef.toolTip(function, item_fl + "<br>" + item_ds + "<br>" + item_tm, box_s) + "</a></td>"
	      tabout += "<td style=\"display:none;\">" + str(PROCESSING[table][item]['total']) + "</td>"
	      tabout += "<td style=\"display:none;\">" + str(PROCESSING[table][item]['distance_raw']) + "</td>"
	      tabout += "<td style=\"display:none;\">" + str(PROCESSING[table][item]['duration_raw']) + "</td>"
	      
	      h = 0
	      for header in HEADERS:
		DICT_H = {}
		tabout += "        <td>"
		
		e = 0
		for element in sorted(PROCESSING[table][item]['headers'][header].keys()):
		  DICT_H[element] = len(set(PROCESSING[table][item]['headers'][header][element]['commons']))
		for dict_hv in sorted(set(DICT_H.values()), reverse=True):
		  for element in sorted(PROCESSING[table][item]['headers'][header].keys()):
		    CELLIST = sorted(set(PROCESSING[table][item]['headers'][header][element]['commons']))
		    if dict_hv == len(CELLIST):
		      
		      box_c  = "Number of flights: " + str(len(CELLIST)) + "<br>"
		      box_c += "Distance flown: " + importDef.totalDistance(CELLIST, FLIGHTS) + "<br>"
		      box_c += "Time traveled: " + importDef.formatTime(importDef.totalTime(CELLIST, FLIGHTS)) + "<br><br>"
		      
		      c = 0
		      for cellist in CELLIST:
			if c>0:
			  box_c += "<br>"
			box_c += str(FLIGHTS[cellist]["DATE"]) + " , "
			box_c += str(FLIGHTS[cellist]["DEPARTE"]) + " to " + str(FLIGHTS[cellist]["ARRIVAL"]) + " <br>"
			box_c += str(importDef.formatNumber(FLIGHTS[cellist]["DIST_KM"])) + " km @ "
			box_c += importDef.formatTime(FLIGHTS[cellist]["DURTION"]) + " , " + str(FLIGHTS[cellist]["AIRCRAFT"]) + " <br>"
			c += 1
		      
		      if e > 0:
			tabout += "            <br>"
		      function = "tooltipUpR"
		      if i < len(ITEMS)-1 and h >= len(HEADERS)-4:
			function = "tooltipUpL"
		      elif i >= len(ITEMS)-1 and h < len(HEADERS)-4:
			function = "tooltipDwR"
		      elif i >= len(ITEMS)-1 and h >= len(HEADERS)-4:
			function = "tooltipDwL"
		      tabout += "<a>" + importDef.toolTip(function, str(element) + " (" + str(dict_hv) + ")", box_c) + "</a>\n"
		      e += 1
		h += 1
		tabout += "        </td>\n"
	      tabout += "    </tr>\n"
	      i += 1
	tabout += "  </tbody></table></p>\n</div>\n"
	website.write(tabout)

## ADD READING A CONTENT OF CSV FILE
      
      table   = "CSV FILE"
      tabout  = "\n<div id=\"" + table + "\" class=\"tabcontent\">\n  "
      tabout += "<p><table id=\"" + table + "\" width=\"95%\" align=\"center\">\n    <thead><tr>"
      tabout += "<th onclick=\"sortValuesTable(0,'" + table + "')\"><a>NO</a></th>"
      tabout += "<th onclick=\"sortStringsTable(1,'" + table + "')\"><a>DATE</a></th>"
      tabout += "<th onclick=\"sortStringsTable(2,'" + table + "')\"><a>ROUTE</a></th>"
      tabout += "<th onclick=\"sortStringsTable(3,'" + table + "')\"><a>COUNTRY</a></th>"
      tabout += "<th onclick=\"sortValuesTable(5,'" + table + "')\"><a>DURATION</a></th>"
      tabout += "<th style=\"display:none;\"><a>DURATION_RAW</a></th>"
      tabout += "<th onclick=\"sortValuesTable(7,'" + table + "')\"><a>DISTANCE</a></th>"
      tabout += "<th style=\"display:none;\"><a>DISTANCE_RAW</a></th>"
      tabout += "<th onclick=\"sortStringsTable(8,'" + table + "')\"><a>AIRCRAFT</a></th>"
      tabout += "<th onclick=\"sortStringsTable(9,'" + table + "')\"><a>REMARKS</a></th>"
      tabout += "</tr></thead><tbody id=\"data\">\n"
      
      for i in sorted(FLIGHTS.keys()):
	text = ""
	tabout += "    <tr>"
	tabout += "<td>" + str(i) + "</td>"
	tabout += "<td>" + str(FLIGHTS[i]["DATE"]) + "</td>"
	tabout += "<td>" + str(FLIGHTS[i]["DEPARTE"]) + " to " + str(FLIGHTS[i]["ARRIVAL"]) + "</td>"
	tabout += "<td>" + FLIGHTS[i]["COUNTRY"] + "</td>"
	tabout += "<td>" + importDef.formatTime(FLIGHTS[i]["DURTION"]) + "</td>"
	tabout += "<td style=\"display:none;\">" + str(FLIGHTS[i]["DURTION"]) + "</td>"
	tabout += "<td>" + str(importDef.formatNumber(FLIGHTS[i]["DIST_KM"])) + " km (" + str(importDef.formatNumber(FLIGHTS[i]["DIST_NM"])) + " nm)</td>"
	tabout += "<td style=\"display:none;\">" + str(FLIGHTS[i]["DIST_KM"]) + "</td>"
	tabout += "<td><a>" + importDef.toolTip("tooltipMin", FLIGHTS[i]["AIRCRAFT"], FLIGHTS[i]["COMPANY"]) + "</a></td>"
	if len(FLIGHTS[i]["REMARKS"]) > 0:
	  text = " notes " 
	tabout += "<td><a>" + importDef.toolTip("tooltipUpL", text, FLIGHTS[i]["REMARKS"]) + "</a></td>"
	tabout += "</tr>\n"
      tabout += "  </tbody></table></p>\n</div>\n"
      website.write(tabout)

    else:
      website.write(line + "\n")
      
  website.close()
  templte.close()
  
  shutil.copyfile(webname, 'zib\'s flights.html')
