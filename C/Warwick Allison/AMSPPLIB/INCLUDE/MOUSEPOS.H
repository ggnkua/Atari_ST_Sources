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

#ifndef _MousePosition_h
#define _MousePosition_h

//
//  Support for the Atari Mouse - directly.  Do not use with AES.
//

#include <values.h>
#include <shape.h>
#include <bool.h>

class MousePosition;
extern MousePosition Mouse;


// **** Only one MousePosition may be declared (ie. Mouse above) ****



class MousePosition
{
public:
	MousePosition();
	~MousePosition();

	int X();
	int Y();
	bool LeftButton();
	bool RightButton();
	int MoveTo(int,int);
	int MoveBy(int,int);
	void Speed(short x,short y); // Thresholds

	void Unbound(); // Default
	void Bound(Rectangle);
	/* Old */ void Bound(int MinX=0, int MinY=0,
		int Width=MAXINT, int Height=MAXINT);
	void SetLeft(int);
	void SetRight(int);

private:
	void Bind();
	bool Bounded;
	int minx,miny,maxx,maxy;
	void* OldVec;
	volatile int x,y;
	volatile bool Left,Right;
};

inline bool MousePosition::LeftButton() { return Left; }
inline bool MousePosition::RightButton() { return Right; }
inline int MousePosition::X() { return x; }
inline int MousePosition::Y() { return y; }
inline int MousePosition::MoveTo(int X,int Y) { x=X; y=Y; if (Bounded) Bind(); }
inline int MousePosition::MoveBy(int X,int Y) { x+=X; y+=Y; if (Bounded) Bind(); }
inline void MousePosition::Unbound() { Bounded=0; }
inline void MousePosition::Bound(Rectangle R)
		{ Bounded=1; minx=R.x; miny=R.y; maxx=R.w+minx-1; maxy=R.h+miny-1; Bind(); }
inline void MousePosition::Bound(int MinX=0, int MinY=0, int Width=MAXINT, int Height=MAXINT)
		{ Bounded=1; minx=MinX; miny=MinY; maxx=Width+minx-1; maxy=Height+miny-1; Bind(); }
inline void MousePosition::SetLeft(int on) { Left=on; }
inline void MousePosition::SetRight(int on) { Right=on; }


#endif
