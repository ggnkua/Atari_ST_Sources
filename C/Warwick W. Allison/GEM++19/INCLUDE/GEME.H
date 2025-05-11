/////////////////////////////////////////////////////////////////////////////
//
//  GEMevent
//
//  A GEMevent is a combination of values that represents and event.
//  it also provides the functionality for collecting events from GEM.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMe_h
#define GEMe_h

#include <bool.h>
#include <gemfast.h>


class GEMevent
{
	int ev_which;
	int btn_clicks,btn_state,btn_mask,btn_not;
	int rf[2];
	int r[2][4];
	int msg[32];
	int interval;
	int mx,my,btn;
	int meta,key,clicks;

public:
	GEMevent(); // Current button state
	GEMevent(int x, int y, int button=0, int clicks=1); // Simulated clicks
	GEMevent(int key); // Simulated key

	void Get(int ev_flags); // Use MU_* constants in gemfast.h

	void Button(int mask, int state, bool not=FALSE)	{ btn_mask=mask; btn_state=state; btn_not=not; }
	void Rectangle1(int x, int y, int w, int h, bool out_not_in)	{ rf[0]=out_not_in; r[0][0]=x; r[0][1]=y; r[0][2]=w; r[0][3]=h; }
	void Rectangle2(int x, int y, int w, int h, bool out_not_in)	{ rf[1]=out_not_in; r[1][0]=x; r[1][1]=y; r[1][2]=w; r[1][3]=h; }
	void Rectangle(int x, int y, int w, int h, bool out_not_in, int R=1)	{ rf[R-1]=out_not_in; r[R-1][0]=x; r[R-1][1]=y; r[R-1][2]=w; r[R-1][3]=h; }
	void Interval(int i)	{ interval=i; }
	int Interval() const		{ return interval; }

	bool Keyboard() const	{ return !!(ev_which&MU_KEYBD); }
	bool Button() const		{ return !!(ev_which&MU_BUTTON); }
	bool Rectangle1() const	{ return !!(ev_which&MU_M1); }
	bool Rectangle2() const	{ return !!(ev_which&MU_M2); }
	bool Rectangle() const	{ return !!(ev_which&(MU_M1|MU_M2)); }
	bool Message() const	{ return !!(ev_which&MU_MESAG); }
	bool Timer() const		{ return !!(ev_which&MU_TIMER); }

	int X() const			{ return mx; }
	int Y() const			{ return my; }

	int Message(int i) const	{ return msg[i]; }
	int Button(int b) const	{ return btn&(1<<b); }
	int Clicks() const		{ return clicks; }
	int Meta() const		{ return meta; }
	int Key() const			{ return key; }
};

#endif
