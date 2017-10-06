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

#ifndef _Resolution_h
#define _Resolution_h

#include <bool.h>

class Resolution
{
public:
	Resolution(); // Current
	Resolution(int width, int height, int depth);

	int Width() const;
	int Height() const;
	int Depth() const;

	bool Usable() const;
	void Use() const;

	short BitPlanes() const;
	short BytesPerBitPlaneLine() const;
	short BytesPerLine() const;
	unsigned int NumberOfColours() const;
	long Size() const; // in bytes.

	int operator==(const Resolution&) const;
	int operator!=(const Resolution& R) const { return !operator==(R); }

	// The following are for implementation of old systems
	// such as Degas "mode" bytes, etc.
	Resolution(short); // As per old modes
	short OldMode() const;  // as per Getrez(), but maybe -1 if not possible

private:
	int w,h,d;
	long mode;
};


extern const Resolution STLow;
extern const Resolution STMedium;
extern const Resolution STHigh;

extern const Resolution TTLow;
extern const Resolution TTMedium;
extern const Resolution TTHigh;

extern const Resolution MaximumResolution;


inline int Resolution::Width() const { return w; }
inline int Resolution::Height() const { return h; }
inline int Resolution::Depth() const { return d; }
inline short Resolution::BitPlanes() const { return d; }
inline short Resolution::BytesPerBitPlaneLine() const { return w/8; }
inline short Resolution::BytesPerLine() const { return w*d/8; }
inline short Resolution::OldMode() const { return (mode&7) ? -1 : mode; }
inline int Resolution::operator==(const Resolution& R) const { return mode==R.mode; }


#endif

