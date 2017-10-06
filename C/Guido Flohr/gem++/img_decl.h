/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

// Declarations for img*.cc modules.

#include "img.h"

#include <stdio.h>
#include <builtin.h>

#define SEEK_SET 0
#define SEEK_CUR 1

inline int Wpad(int x) { return (x+15)>>4; }
inline int Bpad(int x) { return (x+7)>>3; }

struct IMGfileheader
{
	short version;
	short length;
	short planes;
	short patternlen;
	short uW,uH;
	short W,H;
};

struct XIMGextension
{
#define XIMGmagic "XIMG"
	char magic[4];
#define XIMGrgb 0
	short col_format;
	// VDIRGB palette[1 << header.planes]
};

class GEMimgpalette : public GEMpalette {
public:
	GEMimgpalette(IMG& image);
	~GEMimgpalette();

	VDIRGB* RawVDIRGBs() { return rgb; }

	void ImageChanged(bool depth_changed);

protected:
	virtual void SetRGB(int index, int& vdiindex, const VDIRGB& rgb);
	virtual void GetRGB(int index, int& vdiindex, VDIRGB& in) const;
	virtual int PaletteSize() const;

private:
	VDIRGB* rgb;
	class IMG& img;
};
