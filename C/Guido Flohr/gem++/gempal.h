/////////////////////////////////////////////////////////////////////////////
//
//  GEMpalette - Centralized handling of VDI palette change.
//
//  This file is Copyright 1994 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMpal_h
#define GEMpal_h

#include <bool.h>
#include <gemfast.h>
#include <aesext.h>
#include <grect.h>
#include <vdi++.h>

class VDIRGB {
public:
	VDIRGB() { }
	VDIRGB(int red, int green, int blue) : r(red),g(green),b(blue) { }

	void Set(int red, int green, int blue) { r=red; g=green; b=blue; }

	int Red() const { return r; }
	int Green() const { return g; }
	int Blue() const { return b; }

private:
	short r,g,b;
};


class GEMpalette {
public:
	GEMpalette();
	virtual ~GEMpalette();

	// Call this when you want this palette to be the current displayed one.
	void Show();

	// Call this when other applications may have changed the
	// current palette.
	static void ShowCurrent();

	void Set(int index, const VDIRGB&);
	void Get(int index, VDIRGB&) const;

	virtual int PaletteSize() const=0;

protected:
	virtual void SetRGB(int index, int& vdiindex, const VDIRGB& rgb)=0;
	virtual void GetRGB(int index, int& vdiindex, VDIRGB& rgb) const=0;
	virtual VDI& Device() const;

private:
	static GEMpalette* current;
};

#endif
