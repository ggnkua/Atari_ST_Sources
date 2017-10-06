/////////////////////////////////////////////////////////////////////////////
//
//  GEMtimer
//
//  A GEMtimer is an event handler that acts when a time expires.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMt_h
#define GEMt_h

#include <gemfb.h>

class GEMactivity;
class GEMevent;

class GEMtimer
{
public:
	GEMtimer (GEMactivity& in, int millisec);
	virtual ~GEMtimer();

	int Interval() { return interval; }

	// Should only change during Expire call.
	void Interval (int i) { interval = i; }

	virtual GEMfeedback Expire (const GEMevent&) = 0;

	// Below for service provider
	static int NextInterval ();
	static GEMfeedback ExpireNext (const GEMevent&);

	GEMactivity& Activity() const { return *act; }

private:
	void InsertInto (GEMtimer*&);
	void DeleteFrom (GEMtimer*&);

	static GEMactivity* act;
	static GEMtimer* head;
	static int now;

	GEMtimer* next;
	int interval;
	int mytime;
};

#endif
