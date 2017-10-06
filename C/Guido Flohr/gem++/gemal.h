/////////////////////////////////////////////////////////////////////////////
//
//  GEMalert
//
//  A GEMalert is an interface to standard GEM alerts.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMal_h
#define GEMal_h

#include <bool.h>

class GEMrsc;

class GEMalert
{
public:
	GEMalert(const GEMrsc& in, int RSCindex);
	~GEMalert();

	// Avoid using this - it is language-specific - use an alert in an GEMrsc.
	GEMalert(const char* lines, const char* buttons, int icon=3);

	int Alert(int Default=-1); // -ve values count from right-most button.
	int Alertf(int Default, ...); // As per printf.

private:
	char* text;
	bool local;
};


#endif
