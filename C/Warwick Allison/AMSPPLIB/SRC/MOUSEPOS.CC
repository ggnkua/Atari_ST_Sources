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

#include "MousePosition.h"
#include <osbind.h>

MousePosition Mouse;

void MousePosition::Bind()
{
	if (x<minx) x=minx;
	else if (x>maxx) x=maxx;
	if (y<miny) y=miny;
	else if (y>maxy) y=maxy;
}

struct Packet
{
	short Header:8;
	short x:8;
	short y:8;
};

void MyInt(Packet* Data)
{
	Mouse.SetLeft(!!(Data->Header&2));
	Mouse.SetRight(!!(Data->Header&1));
	Mouse.MoveBy(Data->x,Data->y);
}

MousePosition::MousePosition() :
	x(0),
	y(0),
	Left(FALSE),
	Right(FALSE),
	Bounded(FALSE)
{
	struct _KBDVECS *Base=Kbdvbase();

	Ikbdws(1,"\010");
	OldVec=(void*)Base->mousevec;
	Base->mousevec=(void(*)(void*))MyInt;
}

void MousePosition::Speed(short x, short y)
{
	char *T="\013??";
	T[1]=x;
	T[2]=y;
	Ikbdws(3,T);
}

MousePosition::~MousePosition()
{
	struct _KBDVECS *Base=Kbdvbase();

	Base->mousevec=(void(*)(void*))OldVec;
	Ikbdws(3,"\013\01\01");
}
