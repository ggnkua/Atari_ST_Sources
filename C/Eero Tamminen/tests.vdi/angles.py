#!/usr/bin/python
#
# VDI test - angles.py
#
# Copyright (C) 2013 by Eero Tamminen
# 
# This file is distributed under the GNU Public License, version 2 or at
# your option any later version. Read the file gpl.txt for details.

import os, sys
from math import cos, pi
from fractions import Fraction

angles = 360
write = sys.stdout.write
name = os.path.basename(sys.argv[0])

write("""/*
 * header with array or pre-generated fraction values
 * for cos values, indexed by decimal degree.
 * 
 * pre-generation done with '%s' python script.
 */
typedef struct {
	short numerator;
	short denominator;
} fraction_t;

fraction_t cos_lookup[%d] = {
""" % (name, angles))

for i in range(angles):
  # angle in radians
  r = pi*i/180.0
  x = cos(r)
  # output values in fractions limited to 15 bits
  f = Fraction.from_float(x).limit_denominator((1<<15)-1)
  write("\t{ %6d, %6d },\n" % (f.numerator, f.denominator))
write("};\n\n")
