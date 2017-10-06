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

#ifndef _FastCounter_h
#define _FastCounter_h

#include <bool.h>
#include "Screen.h"

class CounterFont
{
public:
	CounterFont(short Height);

	// x must be multiple of 16
	void GetImages(Screen&,short x,short y);

	friend class FastCounter;
	void Draw(short,long Offset); // Draw "00" to "99"; 100+x=" x", 110="  "

private:
	short *Data;
	short shifts;
	short height;
};

class FastCounter
{
public:
	// Use given font, draw at (x,y) - x multiple of 16,
	// initial counter value v, given number of digits (multiple of 2).
	FastCounter(CounterFont*,int x,int y,unsigned v=0,short digits=6,short plane=0);
	~FastCounter();

	void Draw();			// Draw on current page
	void Add(short);		// Increase/decrease
	void Set(unsigned);
	void operator ++ () {Add(1);}
	void operator -- () {Add(-1);}
	void operator += (short x) {Add(x);}
	void operator -= (short x) {Add(-x);}
	FastCounter& operator = (unsigned x) { Set(x); return *this; }
	operator int();			// Convert to int
	operator double();		// convert to double
	void MoveTo(short x,short y,short plane=0);
	void ZeroSuppression(bool on=TRUE);	// Turned on by default

private:
	bool LeadingZeroes;
	unsigned short Changed[2];
	short Size;
	long Offset;
	short plane;
	CounterFont *Font;
	unsigned short *Digit;
};

#endif
