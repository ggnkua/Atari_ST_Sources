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

#include "DoubleBuffer.h"
#include <osbind.h>

static Screen Desk(DESKSCREEN);
DoubleBuffer *Pages=new DoubleBuffer(Desk,Desk);

DoubleBuffer::DoubleBuffer()
{
	Canvas[0]=new Screen;
	Canvas[1]=new Screen;
	Pulse=0;
}

DoubleBuffer::DoubleBuffer(Screen& a, Screen& b)
{
	Canvas[0]=&a;
	Canvas[1]=&b;
	Pulse=0;
}

void DoubleBuffer::Flip()
{
	Canvas[Pulse]->Show();
	Vsync();
	Pulse=1-Pulse;
}

void DoubleBuffer::Flop()
{
	Canvas[Pulse]->Show();
	Pulse=1-Pulse;
}
