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

#include "FastFont.h"
#include "DoubleBuffer.h"
#include <stdio.h>

unsigned long* CalcPos(Screen& s, int x, int y, short& shift)
{
	Resolution& rez=s.Rez();
	shift=x&15;
	return (unsigned long*)((short*)s.Location()+y*rez.BytesPerLine()/sizeof(short)+(x>>4)*rez.BitPlanes());
}

FastFont::FastFont(Screen& s, int w, int h, char from, char to) :
	min(from), max(to),
	data(new unsigned short*[to-from+1]),
	width(new unsigned short[to-from+1]),
	height(h),
	plane(0),
	space(1)
{
	unsigned short mask=0;
	for (int ww=w; ww; ww--) mask=(mask>>1)|0x8000;

	int x=0;
	int y=0;
	int LPL=s.Rez().BytesPerLine()/4;
	for (int i=0; i<=to-from; i++) {
		data[i]=new unsigned short[h];
		short sh;
		unsigned long* ptr=CalcPos(s,x,y,sh);
		unsigned short m=0;
		for (int j=0; j<height; j++) {
			data[i][j]=((*ptr<<sh)>>16)&mask;
			m|=data[i][j];
			ptr+=LPL;
		}

		int ww=0;
		while (m) {
			m<<=1;
			ww++;
		}

		if (!ww) ww=w/2; // For blank characters (eg. space!)

		width[i]=ww;

		x+=w;
		if (x>=s.Rez().Width()) {
			x=0;
			y+=height;
		}
	}
}

FastFont::FastFont(const char* f)
{
	data=0;

	FILE* fd=fopen(f,"rb");

	if (!fd) return;

	if (1!=fread(&min,sizeof(min),1,fd)) return;
	if (1!=fread(&max,sizeof(max),1,fd)) return;
	if (1!=fread(&height,sizeof(height),1,fd)) return;
	if (1!=fread(&plane,sizeof(plane),1,fd)) return;
	if (1!=fread(&space,sizeof(space),1,fd)) return;

	width=new unsigned short[max-min+1];
	if (max-min+1!=fread(width,sizeof(width[0]),max-min+1,fd)) {
		delete width;
		return;
	}

	data=new unsigned short*[max-min+1];

	for (int i=0; i<=max-min; i++) {
		data[i]=new unsigned short[height];
		if (height!=fread(data[i],sizeof(data[0][0]),height,fd)) {
			delete width;
			for (int j=0; j<=i; j++) delete data[j];
			delete data;
			data=0;
			return;
		}
	}

	if (EOF==fclose(fd)) {
		delete width;
		for (int j=0; j<=max-min; j++) delete data[j];
		delete data;
		data=0;
	}
}

FastFont::~FastFont()
{
	delete width;
	for (int j=0; j<=max-min; j++) delete data[j];
	delete data;
}

int FastFont::operator! ()
{
	return !data;
}


int FastFont::Save(const char* f)
{
	FILE* fd=fopen(f,"wb");

	if (!fd) return 0;

	if (1!=fwrite(&min,sizeof(min),1,fd)) return 0;
	if (1!=fwrite(&max,sizeof(max),1,fd)) return 0;
	if (1!=fwrite(&height,sizeof(height),1,fd)) return 0;
	if (1!=fwrite(&plane,sizeof(plane),1,fd)) return 0;
	if (1!=fwrite(&space,sizeof(space),1,fd)) return 0;
	if (max-min+1!=fwrite(width,sizeof(width[0]),max-min+1,fd)) return 0;

	for (int i=0; i<=max-min; i++) {
		if (height!=fwrite(data[i],sizeof(data[0][0]),height,fd)) return 0;
	}

	return EOF!=fclose(fd);
}

void FastFont::Plane(short p)
{
	plane=p;
}

void FastFont::Put(char ch, int& x, int y)
{
	ch=(ch>=min && ch<=max) ? ch-min : 0;

	short BP=Pages->Current().Rez().BitPlanes();
	short sh;
	unsigned long* ptr=CalcPos(Pages->Current(),x,y,sh);
	x+=width[ch];

	asm("
			lsrw	#1,%5
			addl	%5,%1
			eorw	#15,%2
		0:
			clrl	d0
			movew	%0@+,d0
			lsll	%2,d0
			eorw	d0,%1@(%6:w)
			swap	d0
			eorw	d0,%1@
			addl	%3,%1
			dbra	%4,0b

		" : // No outputs
		  :	"a" (data[ch]),
			"a" (ptr),
			"d" (sh),
			"d" (Pages->Current().Rez().BytesPerLine()),
			"d" (height-1),
			"d" (plane),
			"d" (BP*2)
		  : "d0"
	);
}

void FastFont::Put(const char* s, int& x, int y)
{
	//The simple approach... *** MUCH SLOWER - 24:86 ***
	//while (*s) { Put(*s++,x,y); x+=space; }

	int BPL=Pages->Current().Rez().BytesPerLine();
	short BP=Pages->Current().Rez().BitPlanes();
	short BP2=BP*2;

	short sh;
	short hm1=height-1;
	unsigned short* ptr=(unsigned short*)CalcPos(Pages->Current(),x,y,sh)+plane;
	sh^=15;

	while (*s) {
		char ch=(*s>=min && *s<=max) ? *s-min : 0;

		asm("
				movel	%1,a0
				movel	%4,d1
			0:
				clrl	d0
				movew	%0@+,d0
				lsll	%2,d0
				eorw	d0,a0@(%5:w)
				swap	d0
				eorw	d0,a0@
				addl	%3,a0
				dbra	%4,0b

			" : // No outputs
			  :	"a" (data[ch]),
				"a" (ptr),
				"d" (sh),
				"d" (BPL),
				"d" (hm1),
				"d" (BP2)
			  : "d0", "d1", "a0"
		);

		short w=width[ch]+space;
		x+=w;
		sh-=w;
		if (sh<0) {
			sh+=16;
			ptr+=BP;
		}
		s++;
	}
}

short FastFont::Width(char ch)
{
	ch=(ch>=min && ch<=max) ? ch-min : 0;
	return width[ch];
}

int FastFont::Width(const char* s)
{
	int w=0;
	while (*s) {
		char ch=(*s>=min && *s<=max) ? *s-min : 0;
		w+=width[ch]+space;
		s++;
	}
	return w;
}

void FastFont::SetSpacing(short s)
{
	space=s;
}
