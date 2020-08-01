/////////////////////////////////////////////////////////////////////////////
//
//  IMG - Standard GEM image format
//
//  An IMG is a bitmap.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef IMG_h
#define IMG_h

#include <bool.h>


class IMG
{
public:
	// Contents undefined, but writable.
	IMG(int width,int height,int depth=1);	

	// Contents defined as bitmap At given location, with given dimensions.
	IMG(unsigned char* At, int width, int height, int depth=1);

	// Read from IMG file.
	IMG(const char *);

	virtual ~IMG();

	int operator!() const; // creation failure (memory or file) test

	int Save(const char *,int PatLen=2);

	int operator() (int,int);
	void Left();
	void Right();
	void Up();
	void Down();
	void Put(short);
	short Get() const;

	int Width() const;
	int Height() const;
	int Depth() const;

	long Pos() const;
	void Repos(long);

	void Clear(int colour=0);
	void operator|= (const IMG&);
	//void Copy(const IMG& from);
	//void Copy(const IMG& from, int to_x, int to_y, const GRect& fromarea);

	unsigned char* Location() const;

private:
	int W,H,D;
	int bW,uW,uH;
	unsigned char *data;
	long Cursor;
	unsigned char bit;
	bool External;
};

const unsigned char TOPBIT=(1<<7);

inline int IMG::operator() (int X,int Y) { Cursor=bW*Y+(X>>3); bit=TOPBIT>>(X&7); return Get(); }
inline void IMG::Left() { if (bit==TOPBIT) { bit=1; Cursor--; } else bit<<=1; }
inline void IMG::Right() { if (bit==1) { bit=TOPBIT; Cursor++; } else bit>>=1; }
inline void IMG::Up() { Cursor-=bW; }
inline void IMG::Down() { Cursor+=bW; }
inline void IMG::Put(short b) { if (b) data[Cursor]|=bit; else data[Cursor]&=~bit; }
inline short IMG::Get() const { if (data[Cursor]&bit) return 1; else return 0; }
inline long IMG::Pos() const { return (Cursor<<8)|bit; }
inline void IMG::Repos(long p) { Cursor=p>>8; bit=p&0xff; }
inline int IMG::Width() const { return bW<<3; }
inline int IMG::Height() const { return H; }
inline int IMG::Depth() const { return D; }
inline int IMG::operator!() const { return !data; }
inline unsigned char* IMG::Location() const { return data; }

#endif
