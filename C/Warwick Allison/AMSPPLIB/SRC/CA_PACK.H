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

/**************************************************\
 *                                                *
 *  CrackArt file compressor.                     *
 *                                                *
 *  by Warwick Allison, May 8th 1992.             *
 *                                                *
\**************************************************/
#ifndef ca_pack_h
#define ca_pack_h

#include <stdio.h>

void SaveCrackArtData(unsigned char* From, int nel, FILE* f, int Compression);
// Pack the given amount of data from the given location to the
// data section of a CrackArt file.  'nel' will normally be 32000.
//
// Compression 0 = minimal compression attempt
// Compression 8 = maximal compression attempt

#endif
