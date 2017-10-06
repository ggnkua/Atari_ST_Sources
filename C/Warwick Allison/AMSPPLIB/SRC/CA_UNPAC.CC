//////////////////////////////////////////////////////////////////////////////
//
//  This file is part of the Atari Machine Specific Library,
//  and is Copyright 1992 by Warwick W. Allison.
//
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.
//
//////////////////////////////////////////////////////////////////////////////

/****************************************************\
 *                                                  *
 *  CrackArt file decompressor.                     *
 *   by Warwick Allison, May 8th 1992.              *
 *                                                  *
 *  Based on assembler code routine:                *
 *                                                  *
 *   ; Dekomprimierung von CRACK ART Bildern (CA?)  *
 *   ; Copyright ½ Detlef R”ttger 04.03.1990        *
 *                                                  *
 *  The full file format (in bytes) is:             *
 *       'C', 'A', 1, Rez, Colours x 2, Data        *
 *                                                  *
 *    Data = Esc, Delta, OffsetHi, OffsetLo,        *
 *           codes*, Esc, 2, 0                      *
 *                                                  *
\****************************************************/

#include "ca_unpac.h"

// These globals are a result of the ASM original.  Sorry.
static unsigned char* location;
static int CycleStart;
static int Cycler;
static int Size;
static int Count;
static int Offset;

void OutByte(char b)
{
	location[Cycler]=b;
	Cycler+=Offset;
	Count--;
	if (Cycler>=Size) {
		CycleStart++;
		Cycler=CycleStart;
	}
}

unsigned char InByte(FILE* f)
{
	return fgetc(f);
}

void LoadCrackArtData(unsigned char* To, int nel, FILE* f)
{
	unsigned char Esc=InByte(f);
	unsigned char Delta=InByte(f);

	Offset=(InByte(f)*256+InByte(f))&0x7fff;

	location=To;
	Size=nel;
	Count=nel;
	CycleStart=0;
	Cycler=0;

	while (Count) {
		unsigned int n;
		unsigned char b;
		unsigned char code=InByte(f);

		if (code!=Esc) {
			OutByte(code);
		} else {
			code=InByte(f);
			if (code==Esc) {
				OutByte(code);
			} else if (code==0) {
				n=InByte(f)+1;
				b=InByte(f);
				while (n--) OutByte(b);
			} else if (code==1) {
				n=InByte(f)*256+InByte(f)+1;
				b=InByte(f);
				while (n--) OutByte(b);
			} else if (code==2) {
				n=InByte(f);
				if (n) {
					n=n*256+InByte(f)+1;
					while (n--) OutByte(Delta);
				} else {
					while (Count) OutByte(Delta);
				}
			} else {
				n=code+1;
				b=InByte(f);
				while (n--) OutByte(b);
			}
		}
	}
}
