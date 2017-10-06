/////////////////////////////////////////////////////////////////////////////
//
//  GEMfocus
//
//  Share focus among windows.
//
//  This file is Copyright 1994 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMfoc_h
#define GEMfoc_h

class GEMwindow;

class GEMfocus
{
public:
	static void FocusOn(GEMwindow*);
	static void FocusOff(GEMwindow*);
	static GEMwindow* Focus();

private:
	static GEMwindow* focus;
};

#endif
