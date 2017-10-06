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

#include "BlockMap.h"
#include "DoubleBuffer.h"
#include <bool.h>

// If more than this fraction of changes are made, the whole
// image is updated, on the premise that it is faster to draw the
// blocks consecutively.
#define OPTIMALMAXCHANGERATIO 5/6

int CeilingLog2(int x)
// result-1 < logbase2(x) <= result
{
	int result=0;
	while (x > (1<<result)) result++;
	return result;
}

BlockMap::BlockMap(short w, short h, short *map) :
	use_short_not_char(TRUE),
	dynamic(0),
	width(w),
	height(h),
	shiftheight(CeilingLog2(w)),
	views(0),
	data(map)
{
}

BlockMap::BlockMap(short w, short h, char *map) :
	use_short_not_char(FALSE),
	dynamic(0),
	width(w),
	height(h),
	shiftheight(CeilingLog2(w)),
	views(0),
	data((short*)map)
{
}

BlockMap::BlockMap(short w, short h, int MaxBlock=256) :
	use_short_not_char(MaxBlock > 256),
	dynamic(1),
	width(w),
	height(h),
	shiftheight(CeilingLog2(w)),
	views(0),
	data(use_short_not_char
		? (new short[w<<shiftheight])
		: ((short*) new char[w<<shiftheight]))
{
}

BlockMap::~BlockMap()
{
	if (dynamic) delete data;
}

void BlockMap::Set(short x, short y, short ch)
{
	if (use_short_not_char)
		data[(x<<shiftheight)+y]=ch;
	else
		((char*)data)[(x<<shiftheight)+y]=ch;

	if (views) views->Touch(x,y);
}


int BlockMap::fput(FILE *fp)
{
	return 0;
}

int BlockMap::fget(FILE *fp)
{
	return 0;
}

short BlockMap::operator() (short x, short y)
{
	return use_short_not_char
			? data[(x<<shiftheight)+y]
			: ((char*)data)[(x<<shiftheight)+y];
}

BlockMapView::BlockMapView(BlockMap& m, BlockImages& Im, short sx, short sy, short w, short h, short x=0, short y=0) :
	map(&m), images(&Im),
	maxchanges(w*h*OPTIMALMAXCHANGERATIO), next(map->views),
	x(x),y(y)
{
	map->views=this;
	change[0]=new ChangeList[maxchanges];
	change[1]=new ChangeList[maxchanges];
	views(x,y);
	MoveView(sx,sy);
	Resize(w,h);
}

void BlockMapView::MoveView(short sx, short sy)
{
	pageoffset=(sy * Pages->Current().Rez().BytesPerLine() / 2)
			+ (sx / 16 * Pages->Current().Rez().BitPlanes());
}

void BlockMapView::Draw()
{
	short nc=changes[Pages->Pulse];

	if (!nc) return; // Short circuit for most common case.

	short *Line=(short*)Pages->Location()+pageoffset;
	int LineSpacing=Pages->Current().Rez().BytesPerLine()/2;

	if (map->use_short_not_char) {
		// THIS CODE IS IDENTICAL TO OTHER if BRANCH EXCEPT FOR THIS LINE
		short *D=map->data+(x<<map->shiftheight)+y;

		if (1 || nc > maxchanges) {
			for (short i=0; i<width; i++) {
				short *To=Line;
				for (short j=0; j<height; j++) {
					images->Draw(D[j],To,LineSpacing);
				}
				D+=1<<map->shiftheight;
				Line+=images->wordwidth;
			}
		} else {
			int BlockSpacing=LineSpacing*images->height;
			int DD=1<<map->shiftheight;
			ChangeList *C=change[Pages->Pulse];
			for (short c=0; c<nc; c++) {
				short *To=Line+C[c].y*BlockSpacing+C[c].x*images->wordwidth;
				images->Draw((D+DD*C[c].x)[C[c].y],To,LineSpacing);
			}
		}
	} else {
		// THIS CODE IS IDENTICAL TO OTHER if BRANCH EXCEPT FOR THIS LINE
		char *D=(char*)map->data+(x<<map->shiftheight)+y;

		if (1 || nc > maxchanges) {
			for (short i=0; i<width; i++) {
				short *To=Line;
				for (short j=0; j<height; j++) {
					images->Draw(D[j],To,LineSpacing);
				}
				D+=1<<map->shiftheight;
				Line+=images->wordwidth;
			}
		} else {
			int BlockSpacing=LineSpacing*images->height;
			int DD=1<<map->shiftheight;
			ChangeList *C=change[Pages->Pulse];
			for (short c=0; c<nc; c++) {
				short *To=Line+C[c].y*BlockSpacing+C[c].x*images->wordwidth;
				images->Draw((D+DD*C[c].x)[C[c].y],To,LineSpacing);
			}
		}
	}

	changes[Pages->Pulse]=0;
}

void BlockMapView::TouchMe()
{
	changes[0]=maxchanges+1;
	changes[1]=maxchanges+1;
}

void BlockMapView::Touch()
{
	changes[0]=maxchanges+1;
	changes[1]=maxchanges+1;
	if (next) next->Touch();
}

void BlockMapView::Touch(short x, short y)
{
	if (x>=x && y>=y && x<x+width && y<y+height) {
		for (short c=0; c<2; c++) {
			if (changes[c] < maxchanges) {
				change[c][changes[c]].x=x-x;
				change[c][changes[c]].y=y-y;
				changes[c]++;
			} else {
				changes[c]=maxchanges+1;
			}
		}
	}

	if (next) next->Touch(x,y);
}

void BlockMapView::ViewsMap(BlockMap& m)
{
	if (&m != map) {
		for (BlockMapView** cursor=&map->views;
			*cursor!=this; cursor=&((*cursor)->next));
		*cursor=(*cursor)->next;
		map=&m;
		next=map->views;
		map->views=this;
		TouchMe();
	}
}

BlockImages::BlockImages(short Blocks, short WordsPerBlock, short WWidth, short Height) :
	wordwidth(WWidth), height(Height),
	maxblocks(Blocks),
	blockshift(CeilingLog2(WordsPerBlock)),
	blockdata(new short[Blocks<<blockshift])
{
}


BlockImages::~BlockImages()
{
	delete blockdata;
}


MonochromeBlockImages::MonochromeBlockImages(short Blocks,short Height)
	: BlockImages(Blocks, Height, 1, Height)
{ }

void MonochromeBlockImages::Draw(short c, short*& At, int LineSpacing)
{
#ifdef NOASM
	short *From=blockdata + ((int)c << blockshift);
	short *tempAt=At;

	for (short i=height; i--;) {
		*tempAt=*From++;
		tempAt+=LineSpacing;
	}

	At=tempAt;
#else // Only 17% speed-up, but it's written now...
	asm("
		movel	%1@,a0
		addl	%2,%2
		subw	#1,%3
0:
		movew	%0@+,a0@
		addl	%2,a0
		dbra	%3,0b

		movel	a0,%1@

	"	: // Outputs
		: // Inputs
			"a" (blockdata+((int)c << blockshift)),
			"a" (&At),
			"d" (LineSpacing),
			"d" (height)
		: "a0"
	);
#endif
}

void MonochromeBlockImages::GetImage(short c, int x, int y, Screen& From)
{
	int LineSpacing=From.Rez().BytesPerLine()/2;
	short *F=(short*)From.Location() + y*LineSpacing + x/16;
	short *T=blockdata + ((int)c << blockshift);

	for (short i=height; i--;) {
		*T++ = *F;
		F+=LineSpacing;
	}
}

WideMonochromeBlockImages::WideMonochromeBlockImages(short Blocks,short Height)
	: BlockImages(Blocks, Height*2, 2, Height)
{ }

void WideMonochromeBlockImages::Draw(short c, short*& At, int LineSpacing)
{
	long *From=(long*)(blockdata + ((int)c << blockshift));
	long *tempAt=(long*)At;
	LineSpacing/=2;

	for (short i=height; i--;) {
		*tempAt=*From++;
		tempAt+=LineSpacing;
	}

	At=(short*)tempAt;
}

void WideMonochromeBlockImages::GetImage(short c, int x, int y, Screen& From)
{
	int LineSpacing=From.Rez().BytesPerLine()/4;
	long *F=(long*)((short*)From.Location() + x/16) + y*LineSpacing;
	long *T=(long*)(blockdata + ((int)c << blockshift));

	for (short i=height; i--; ) {
		*T++ = *F;
		F+=LineSpacing;
	}
}



ColourBlockImages::ColourBlockImages(short Blocks,short Height)
	: BlockImages(Blocks, Height*4, 4, Height)
{ }

void ColourBlockImages::Draw(short c, short*& At, int LineSpacing)
{
	long *From=(long*)(blockdata + ((int)c << blockshift));
	long *tempAt=(long*)At;
	LineSpacing/=2;
	LineSpacing-=1;

	for (short i=height; i--;) {
		*tempAt++=*From++;
		*tempAt=*From++;
		tempAt+=LineSpacing;
	}

	At=(short*)tempAt;
}

void ColourBlockImages::GetImage(short c, int x, int y, Screen& From)
{
	int LineSpacing=From.Rez().BytesPerLine()/2;
	short *F=(short*)From.Location() + y*LineSpacing + x/16*4;
	short *T=blockdata + ((int)c << blockshift);

	for (short i=height; i--;) {
		*T++ = F[0];
		*T++ = F[1];
		*T++ = F[2];
		*T++ = F[3];
		F+=LineSpacing;
	}
}

WideColourBlockImages::WideColourBlockImages(short Blocks,short Height)
	: BlockImages(Blocks, Height*8, 8, Height)
{ }

void WideColourBlockImages::Draw(short c, short*& At, int LineSpacing)
{
	long *From=(long*)(blockdata + ((int)c << blockshift));
	long *tempAt=(long*)At;
	LineSpacing/=2;
	LineSpacing-=3;

	for (short i=height; i--;) {
		*tempAt++=*From++;
		*tempAt++=*From++;
		*tempAt++=*From++;
		*tempAt=*From++;
		tempAt+=LineSpacing;
	}

	At=(short*)tempAt;
}

void WideColourBlockImages::GetImage(short c, int x, int y, Screen& From)
{
	int LineSpacing=From.Rez().BytesPerLine()/2;
	short *F=(short*)From.Location() + y*LineSpacing + x/16*4;
	short *T=blockdata + ((int)c << blockshift);

	for (short i=height; i--;) {
		*T++ = F[0];
		*T++ = F[1];
		*T++ = F[2];
		*T++ = F[3];
		*T++ = F[4];
		*T++ = F[5];
		*T++ = F[6];
		*T++ = F[7];
		F+=LineSpacing;
	}
}

void BlockImages::GetImages(short c, short num, Screen& S)
{
	int x=0;
	int y=0;
	int xspacing=wordwidth*16/S.Rez().BitPlanes();
	int swidth=S.Rez().Width();

	while (num) {
		GetImage(c,x,y,S);

		x+=xspacing;
		if (x>=swidth) {
			x=0;
			y+=height;
		}

		num--;
		c++;
	}
}
