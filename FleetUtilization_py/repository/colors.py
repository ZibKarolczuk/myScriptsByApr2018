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

escape_dict={'\a':r'\a',
             '\b':r'\b',
             '\c':r'\c',
             '\f':r'\f',
             '\n':r'\n',
             '\r':r'\r',
             '\t':r'\t',
             '\v':r'\v',
             '\'':r'\'',
             '\"':r'\"'}

COLORS = {}
COLORS['KJFK'] = {}
COLORS['KJFK']['B'] = "#ff9e5e"
COLORS['KJFK']['F'] = "#7f4f2f"
COLORS['KEWR'] = {}
COLORS['KEWR']['B'] ="#262626"
COLORS['KEWR']['F'] ="#ffffff"
COLORS['KORD'] = {}
COLORS['KORD']['B'] = "#a6cf6f"
COLORS['KORD']['F'] = "#313e21"
COLORS['KLAX'] = {}
COLORS['KLAX']['B'] = "#fdc752"
COLORS['KLAX']['F'] = "#654f20"
COLORS['CYYZ'] = {}
COLORS['CYYZ']['B'] = "#6f81a2"
COLORS['CYYZ']['F'] = "#f0f2f5"
COLORS['RKSI'] = {}
COLORS['RKSI']['B'] = "#bbd4ed"
COLORS['RKSI']['F'] = "#4a545e"
COLORS['ZBAA'] ={}
COLORS['ZBAA']['B'] = "#df2626"
COLORS['ZBAA']['F'] = "#fbe9e9"
COLORS['RJAA'] ={}
COLORS['RJAA']['B'] = "#ffb7c5"
COLORS['RJAA']['F'] = "#996d76"

def paint(X):
  if X['Status'] == "Scheduled flight":
    if X['Departure Airport Code'] in COLORS.keys() and X['Arrive Airport Code'] == "EPWA":
      colB = colR = COLORS[X['Departure Airport Code']]['B']
      __main__.colF = COLORS[X['Departure Airport Code']]['F']
      __main__.fill = "background: linear-gradient(#ffffff," + colB + "," + colB + "); border:1px solid " + colR + ";" 
    elif X['Arrive Airport Code'] in COLORS.keys() and X['Departure Airport Code'] == "EPWA":
      colB = colR = COLORS[X['Arrive Airport Code']]['B']
      __main__.colF = COLORS[X['Arrive Airport Code']]['F']
      __main__.fill = "background: linear-gradient(" + colB + "," + colB  + ",#ffffff); border:1px solid " + colR + ";"
    else:
      colB = "#ffffff"
      __main__.colF = colR = "#000000"
      __main__.fill = "background-color:" + colB + "; border:1px solid " + colR + ";"
  elif re.search("Technical", X['Status']) or re.search("Diverted", X['Status']) or re.search("Continue", X['Status']) or re.search("Delivery", X['Status']) or re.search("Cancelled", X['Status']):
    colB = "#a32088"
    __main__.colF = colR = "#e3bcdb"
    __main__.fill = "background-color:" + colB + "; border:1px solid " + colR + ";"
  else:
    colB = "#ffffff"
    __main__.colF = colR = "#000000"
    __main__.fill = "background-color:" + colB + "; border:1px solid " + colR + ";"

