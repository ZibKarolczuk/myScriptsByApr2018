#! /usr/bin/env python
# -*- coding: utf-8 -*-

import re as regex
import sys, os

array = list(commons)

def totalFlights(array, FLIGHTS, PROCESSING):

  output_xml = ""
  output_xml +=  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  output_xml += "<database>\n"

  output_xml += "\n  <general>\n"
  output_xml += "    <duration>" + formatTime(totalTime(FLIGHTS.keys())) + "</duration>\n"
  output_xml += "    <duration_raw>" + str(totalTime(FLIGHTS.keys())) + "</duration_raw>\n"
  output_xml += "    <distance>" + totalDistance(FLIGHTS.keys()) + "</distance>\n"
  output_xml += "    <distance_raw>" + str(totalDistanceNoKM(FLIGHTS.keys())) + "</distance_raw>\n"
  output_xml += "    <flights>" + str(totalFlights(FLIGHTS.keys())) + "</flights>\n"
  output_xml += "  </general>\n"

  for table in sorted(PROCESSING.keys()):
    output_xml += "\n  <table>\n"
    output_xml += "    <table_item>" + table + "</table_item>\n"
    output_xml += "    <table_totl>" + str(totalFlights(array)) + "</table_totl>\n"
    output_xml += "    <table_dist>" + totalDistance(array) + "</table_dist>\n"
    output_xml += "    <table_dist_raw>" + str(totalDistanceNoKM(array)) + "</table_dist_raw>\n"
    output_xml += "    <table_time>" + formatTime(totalTime(array)) + "</table_time>\n"
    output_xml += "    <table_time_raw>" + str(totalTime(array)) + "</table_time_raw>\n"
    
    dictItem = {}
    for item in sorted(PROCESSING[table].keys()):
      dictItem[item] = len(set(PROCESSING[table][item]['commons']))
    
    for dictItemValue in sorted(set(dictItem.values()), reverse=True):
      for item in sorted(PROCESSING[table].keys()):
	if len(set(PROCESSING[table][item]['commons'])) == dictItemValue:
	  
	  output_xml += "\n    <line>\n"
	  output_xml += "      <line_item>" + item + "</line_item>\n"
	  output_xml += "      <line_totl>" + str(PROCESSING[table][item]['total']) + "</line_totl>\n"
	  output_xml += "      <line_dist>" + PROCESSING[table][item]['distance'] + "</line_dist>\n"
	  output_xml += "      <line_dist_raw>" + PROCESSING[table][item]['distance_raw'] + "</line_dist_raw>\n"
	  output_xml += "      <line_time>" + PROCESSING[table][item]['duration'] + "</line_time>\n"
	  output_xml += "      <line_time_raw>" + PROCESSING[table][item]['duration_raw'] + "</line_time_raw>\n"
      
	  for linelist_element in sorted(set(PROCESSING[table][item]['commons'])):
	    output_xml += "      <linelist>\n"
	    output_xml += "        <linelist_date>" + str(FLIGHTS[linelist_element]["DATE"]) + "</linelist_date>\n"
	    output_xml += "        <linelist_time>" + formatTime(FLIGHTS[linelist_element]["DURTION"]) + "</linelist_time>\n"
	    output_xml += "        <linelist_dept>" + str(FLIGHTS[linelist_element]["DEPARTE"]) + "</linelist_dept>\n"
	    output_xml += "        <linelist_arvl>" + str(FLIGHTS[linelist_element]["ARRIVAL"]) + "</linelist_arvl>\n"
	    output_xml += "        <linelist_equp>" + str(FLIGHTS[linelist_element]["AIRCRFT"]) + "</linelist_equp>\n"
	    output_xml += "        <linelist_dist>" + str(formatNumber(FLIGHTS[linelist_element]["DIST_KM"])) + " km" + "</linelist_dist>\n"
	    output_xml += "      </linelist>\n"
	  
	  for column in sorted(PROCESSING[table][item]['headers'].keys()):
	    output_xml += "      <header>\n"      
	    output_xml += "        <header_item>" + column + "</header_item>\n"
	    
	    dictCell = {}
	    for subitem in sorted(PROCESSING[table][item]['headers'][column].keys()):
	      dictCell[subitem] = len(set(PROCESSING[table][item]['headers'][column][subitem]['commons']))
	      
	    for dictCellValue in sorted(set(dictCell.values()), reverse=True):
	      for subitem in sorted(PROCESSING[table][item]['headers'][column].keys()):
		if len(set(PROCESSING[table][item]['headers'][column][subitem]['commons'])) == dictCellValue:
		  
		  output_xml += "          <cell>\n"
		  output_xml += "            <cell_item>" + subitem + "</cell_item>\n"
		  output_xml += "            <cell_totl>" + str(PROCESSING[table][item]['headers'][column][subitem]['total']) + "</cell_totl>\n"
		  output_xml += "            <cell_dist>" + PROCESSING[table][item]['headers'][column][subitem]['distance'] + "</cell_dist>\n"
		  output_xml += "            <cell_time>" + PROCESSING[table][item]['headers'][column][subitem]['duration'] + "</cell_time>\n"
		  
		  for element in sorted(set(PROCESSING[table][item]['headers'][column][subitem]['commons'])):
		    
		    output_xml += "            <list>\n"
		    output_xml += "              <list_date>" + str(FLIGHTS[element]["DATE"]) + "</list_date>\n"
		    output_xml += "              <list_time>" + formatTime(FLIGHTS[element]["DURTION"]) + "</list_time>\n"
		    output_xml += "              <list_dept>" + str(FLIGHTS[element]["DEPARTE"]) + "</list_dept>\n"
		    output_xml += "              <list_arvl>" + str(FLIGHTS[element]["ARRIVAL"]) + "</list_arvl>\n"
		    output_xml += "              <list_equp>" + str(FLIGHTS[element]["AIRCRFT"]) + "</list_equp>\n"
		    output_xml += "              <list_dist>" + str(formatNumber(FLIGHTS[element]["DIST_KM"])) + " km" + "</list_dist>\n"
		    output_xml += "            </list>\n"
		  
		  output_xml += "          </cell>\n"
	    output_xml += "      </header>\n"  
	  output_xml += "    </line>\n"
    output_xml += "  </table>\n"  
  output_xml += "\n</database>\n"

  f = open("data.xml", 'w')
  f.write(output_xml)
  f.close()
