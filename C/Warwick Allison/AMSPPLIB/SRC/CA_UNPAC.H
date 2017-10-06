//////////////////////////////////////////////////////////////////////////////
//
//  This file is part of the Atari Machine Specific Library,
//  and is Copyright 1992 by Warwick W. Allison.
//
//  You are free to copy and modify these sources, provided you acknoledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.
//
//////////////////////////////////////////////////////////////////////////////

/****************************************************\
 *                                                  *
 *  CrackArt file decompressor.                     *
 *                                                  *
 *  by Warwick Allison, May 8th 1992.               *
 *                                                  *
\****************************************************/
#ifndef ca_unpac_h
#define ca_unpac_h

#include <stdio.h>

void LoadCrackArtData(unsigned char* To, int nel, FILE* f);
// Unpack the given amount of data from the data section of a CrackArt
// file to the given location.  'nel' will normally be 32000.

#endif
