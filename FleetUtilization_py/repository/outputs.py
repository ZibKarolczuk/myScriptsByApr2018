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
import functions as F

### ## # ## ###

def datesJS():
  datesJS = open("htmlJS/dates.js", "w")
  datesJS.write("document.write(\' \\" + "\n")
  datesJS.write("<div class=\"toleft\"> \\" + "\n")
  for i in sorted(__main__.JULIANS.keys(), reverse=True):
    datesJS.write("  <div class=\"outer grid date\"><div class=\"inner rotate\">" + __main__.JULIANS[i]['dateHTML'] + "</div></div> \\" + "\n")
  datesJS.write("</div> \\" + "\n")
  datesJS.write("\');")
  datesJS.close()
  
### ## # ## ###

def flightsJS():
  flightsJS = open("htmlJS/flights.js", "w")
  flightsJS.write("document.write(\' \\" + "\n")

  __main__.USAGE = {}
  __main__.column = 0   
  for __main__.k in sorted(__main__.AIRLINE_FLEET.keys()):
    __main__.column += 1
    __main__.length = 0
    flightsJS.write("<div class=\"toleft\"> \\" + "\n")
      
    for i in sorted(__main__.AIRLINE_FLEET[__main__.k].keys()):
      __main__.X = __main__.AIRLINE_FLEET[__main__.k][i]    
      C.paint(__main__.X)
      F.graph_data()
    
      title = __main__.X['Departure Airport Code'] + " - " + __main__.X['Arrive Airport Code']
      tooltip_tekst = "<p>Reg " + __main__.k + "</p><p style=\"line-height: 1.7\">Take-off " + __main__.X['Departure Time'] + " " + __main__.X['Departure Airport Full'] \
	+ "<br>Landing " + __main__.X['Arrive Time'] + " " + __main__.X['Arrive Airport Full'] + "<br>"\
	+ "Duration  " + __main__.X['Duration'] + "</p><p>" + __main__.X['Status'] + "</p>"
  
      flightsJS.write("  <div class=\"empty\" style=\"height:" + str(__main__.X['boxGround']) + "px\"></div> \\" + "\n")
      flightsJS.write("    <div class=\"tooltip container\" style=\"height:" + str(__main__.X['boxAirborne']-2) + "px; color:" + __main__.colF + "; " + __main__.fill + "\"> \\" + "\n" \
	+ "    <span>" + title + "<span class=\"tooltiptext" + F.typetool() + "\">" + F.raw(tooltip_tekst) + "</span></span></div> \\" + "\n")
    
    flightsJS.write("</div> \\" + "\n")
  flightsJS.write("\');")
  flightsJS.close()

### ## # ## ###

def graphJS():
  graphJS = open("htmlJS/graph.js", "w")
  graphJS.write("document.write(\' \\" + "\n")
  graphJS.write("<div class=\"toleft col grid graph\"> \\" + "\n")

  for i in sorted(__main__.USAGE.keys()):
    
    tiptopGraph = ""
    if ( i > (len(__main__.USAGE.keys())-300)):
      tiptopGraph = "-top"
    
    graphJS.write("  <span class=\"tooltip\" style=\"height:1px; background-color:hsla(" + str(F.color(__main__.USAGE[i]['value'])) + ", 100%, 50%, 0.8); display: block; width:" + str(__main__.USAGE[i]['value']*3) + "px\"> \\" + "\n" \
    + "  <span class=\"tooltip-graph" + tiptopGraph + "\"><strong>Time " + __main__.USAGE[i]['time'] + "<br>Aircrafts Airborne: " + str(__main__.USAGE[i]['value']) + " </strong><br>" + __main__.USAGE[i]['list'] + "</span></span> \\" + "\n")
  graphJS.write("</div> \\" + "\n")
  graphJS.write("\');")
  graphJS.close()
  
### ## # ## ###
