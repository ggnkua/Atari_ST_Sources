/////////////////////////////////////////////////////////////////////////////
//
//  GEMfont
//
//  A GEMfont is a textface, plus a size.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMfn_h
#define GEMfn_h

class VDI;
#include <bool.h>

class GEMfont {
public:
	GEMfont(VDI&, int code, int size);
	GEMfont(VDI&); // current font

	// Same font in another VDI.  VDI's must have same fonts loaded.
	//
	GEMfont(VDI&, const GEMfont&);

	int Code() const;
	void Code(int);
	char* Name() const;

	bool ArbitrarilySizable() const;
	int PointSize() const;
	void PointSize(int);
	bool Larger(); // go to next larger size.  true if could.
	bool Smaller(); // go to next smaller size.  true if could.

	void Use() const; // Use in the VDI of the font.

private: // 8 bytes - small enough to pass around by value.
	VDI& vdi;
	short code;
	unsigned char size;
	unsigned char flags;
};

#endif
