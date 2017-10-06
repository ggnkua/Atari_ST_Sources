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

#ifndef _DoubleBuffer_h
#define _DoubleBuffer_h
//
//  Encapsulated Double Buffering support.
//

#include "Screen.h"

class DoubleBuffer
{
public:
	DoubleBuffer();
	DoubleBuffer(Screen&,Screen&);

	void	Flip();	// Swap pages smoothly (synced to retrace)
	void	Flop();	// Swap pages immediately (unsynced)
	char 	*Location();

	Screen& NowShowing();
	Screen&	Current();

	short Pulse;

private:
	Screen* Canvas[2];
};

extern	DoubleBuffer *Pages;


inline char *DoubleBuffer::Location() { return Canvas[Pulse]->Location(); }
inline Screen& DoubleBuffer::NowShowing() { return *Canvas[1-Pulse]; }
inline Screen&	DoubleBuffer::Current() { return *Canvas[Pulse]; }

#endif
