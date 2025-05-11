/////////////////////////////////////////////////////////////////////////////
//
//  GEMfontlist
//
//  A GEMfontlist is a list of fonts available in a VDI.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMfl_h
#define GEMfl_h

class VDI;
#include <bool.h>
#include <gemfn.h>

class GEMfontlist {
public:
	GEMfontlist(VDI&);
	~GEMfontlist();

	int NumberOfFonts() const;

	// Returns new copy of name.  So delete it later.
	char* FontName(int index) const;

	int FontCode(int index) const;
	int IndexOfFontCoded(int code) const;
	bool ArbitrarilySizable(int index) const;
	int CodeOfFontNamed(char* name) const; // -1 if no such font.

	class GEMfont Font(int index) const;

private:
	VDI& vdi;
	int numfonts;
	char** name;
	int* code;
	bool* arb;
};

#endif
