/////////////////////////////////////////////////////////////////////////////
//
//  IMGcursor - Iterator on IMG class
//
//  This file is Copyright 1992,1993,1994 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef IMGcurs_h
#define IMGcurs_h

#include <bool.h>

class IMG;

class IMGcursor {
//
//  WARNING:  Operations with IMGcursor are NOT bounds checked.
//            They are VERY efficient if used carefully, however.
//
public:
	IMGcursor(unsigned short* at, long linesep, long planesep); // See IMG::Cursor() below.

	// Very fast cursor movement
	void Left();  // Left 1 pixel in current bitplane.
	void Right(); // Right 1 pixel in current bitplane.
	void Up();    // Up 1 line in current bitplane.
	void Down();  // Down 1 line in current bitplane.
	void In();    // In 1 bitplane.
	void Out();   // Out 1 bitplane.

	// Slower cursor movement

	// Move to given position in given bitmap.
	// NOTE: dimensions of bitmap must be same as before.
	void MoveTo(unsigned short* bitmap, int x, int y, int z);
	// Configure cursor to now be operating on bitmap of given dimensions.
	// Any depth.  Cursor is moved to (0,0,0) by operation.
	void SetDimensions(unsigned short* bitmap, int w, int h);

	// A bit faster - prefer Up/Down/Left/Right above, unless
	// parameters are constants, in which case it should be as good.
	inline void MoveBy(int dx, int dy, int dz=0); // Move by given amounts in given bitmap.

	// Fast bit-pixel manipulations.
	void Put1();     // Set pixel on current bitplane to 1.
	void Put0();   // Set pixel on current bitplane to 0.
	void Toggle();  // Set pixel on current bitplane to not itself.
	void Put(bool); // Set pixel on current bitplane to given bit.
	bool Get();     // Get state of pixel on current bitplane.

	// Slower multi-depth pixel manipulations.
	//
	// Warnings:  These use bitmap colour, not VDI colour, so the value
	//            returned is only valid for use in manipulating these
	//            bitmaps.
	//
	// The pixel manipulated is the bitset from the current cursor
	// position "depth" planes into the bitmap.  For example, if
	// the cursor is on the top bitmap, and depth is the same as
	// the depth of the bitmap, these will deal with the full pixel
	// depth.  See IMG::Colour_* methods.
	//
	void PutPixel(int colour, int depth);
	int GetPixel(int depth);

private:
	unsigned short* cursor;
	unsigned short bit;
	long linesep,planesep;
};

#ifdef TRACE_IMG
#define IMGTR(x) printf(#x " -> %x %x %x\n",cursor,bit,*cursor);
#else
#define IMGTR(x) 
#endif

#define TOPBIT (1<<15)

inline IMGcursor::IMGcursor(unsigned short* at, long lnsep, long plsep) :
	cursor(at), bit(TOPBIT), linesep(lnsep), planesep(plsep) { IMGTR(init)}
inline void IMGcursor::Left()  { if (!(bit<<=1)) { bit=1; cursor--; } IMGTR(L)}
inline void IMGcursor::Right() { if (!(bit>>=1)) { bit=TOPBIT; cursor++; } IMGTR(R)}
inline void IMGcursor::Up()    { cursor-=linesep; IMGTR(U)}
inline void IMGcursor::Down()  { cursor+=linesep; IMGTR(D)}
inline void IMGcursor::In()    { cursor+=planesep; IMGTR(I)}
inline void IMGcursor::Out()   { cursor-=planesep; IMGTR(O)}

inline void IMGcursor::MoveTo(unsigned short* bm, int x, int y, int z)
	{ cursor=bm; bit=TOPBIT; MoveBy(x,y,z); IMGTR(mv)}
inline void IMGcursor::SetDimensions(unsigned short* bm, int w, int h)
	{ linesep=(w+15)/16; planesep=linesep*h; cursor=bm; bit=TOPBIT; IMGTR(sd)}

inline void IMGcursor::MoveBy(int dx, int dy, int dz=0)
	{
		int t=dx%16;
		cursor+=dx/16+dy*linesep+dz*planesep;
		while (t--) Right();
	IMGTR(mb)}
inline void IMGcursor::Put1()       { *cursor|=bit; IMGTR(P1)}
inline void IMGcursor::Put0()       { *cursor&=~bit; IMGTR(P0)}
inline void IMGcursor::Toggle()     { *cursor^=bit; IMGTR(tog)}
inline void IMGcursor::Put(bool on) { if (!!(*cursor&bit)!=on) *cursor^=bit; IMGTR(P)}
inline bool IMGcursor::Get()        { return !!(*cursor&bit); }
inline void IMGcursor::PutPixel(int colour, int depth)
	{
		while (depth--) {
			if (colour&(1<<depth))
				*(cursor+planesep*depth)|=bit;
			else
				*(cursor+planesep*depth)&=~bit;
		}
	}
inline int IMGcursor::GetPixel(int depth)
	{
		int colour=0;
		while (depth--) {
			if (*(cursor+planesep*depth)&bit)
				colour|=1<<depth;
		}
		return colour;
	}

#undef TOPBIT

#endif
