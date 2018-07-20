#! /usr/bin/env python
# -*- coding: utf-8 -*-
#
# by Zbigniew Karolczuk, 20 November 2017 

## MOST FREQUENTLY USED FUNCTIONS

def totalFlights(array):
  return len(array)

def totalDistanceNoKM(array, HASH):
  return sum(map(lambda x: HASH[x]["DIST_KM"], array))

def totalDistance(array, HASH):
  return formatNumber(totalDistanceNoKM(array, HASH)) + " km"

def totalTime(array, HASH):
  return sum(map(lambda x: HASH[x]["DURTION"], array))

def formatTime(value):
  d = int(value/(60*24))
  h = int((value-(d*60*24))/60)
  m = value % 60 
  string = ""
  if d > 0:
    string += str(d) + " day"
    if d > 1:
      string += "s"
    string += " " + str("%01d" % h) + " hour"
    if h > 1:
      string += "s"
  else:
    string += str("%01d" % h) + " hour"
    if h != 1:
      string += "s"
  string += " " + str("%02d" % m) + " minute"
  if m != 1:
    string += "s"
  return string

def formatNumber(number):
  number = str(number)
  string = ""
  for b in range(0,len(number)):
    string += number[b]
    if len(number) > 3 and (len(number)-b) % 3 == 1 and (b+1) < len(number):
      string += ","      
  return string

def populate(saveDB, scanDB, iterator, attribute): 
  if scanDB[iterator][attribute] in saveDB[attribute].keys():
    saveDB[attribute][scanDB[iterator][attribute]].append(iterator)
  else:
    saveDB[attribute][scanDB[iterator][attribute]] = list()
    saveDB[attribute][scanDB[iterator][attribute]].append(iterator)

def toolTip(function, text, box):
  return("<div class=\"tooltip\">" + text + "<span class=\"" + function + "\">" + box + "</span></div>")
