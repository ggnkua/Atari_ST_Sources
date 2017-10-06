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

//  I/O return values need work.  Sorry - hacky 'game' mentality.

#ifndef __OPTIMIZE__
// Still with GCC 2.3.3 (and it actually detects it now)
#error "Due to register restrictions, this file must be optimized (-O)"
#endif


#include "Sprite.h"
#include "DoubleBuffer.h"

Incarnation::Incarnation(short h, int b) :
	height(h), Backing(b),
	HotX(0), HotY(0)
{ }

void Incarnation::SetHotSpot(short x, short y)
{
	HotX=x;
	HotY=y;
}

void Sprite::Draw()
{
	long* Back=BackingStore[Pages->Pulse];
	*Back++=(long)Inca[shape];
	Inca[shape]->Draw(x >> Shift,y >> Shift,Back);
}

int Sprite::TouchDraw()
{
	long* Back=BackingStore[Pages->Pulse];
	*Back++=(long)Inca[shape];
	return Inca[shape]->TouchDraw(x >> Shift,y >> Shift,Back);
}

void Sprite::Wipe()
{
	long *Back=BackingStore[Pages->Pulse];
	Incarnation* OldInca=(Incarnation*)*Back;
	if (OldInca) {
		*Back++=0;
		OldInca->Wipe(Back);
	}
}

short LeftBits(unsigned short x)
{
	for (int i=0; x; x<<=1) i++;
	return i;
}

short LongLeftBits(unsigned long x)
{
	for (int i=0; x; x<<=1) i++;
	return i;
}

Sprite::Sprite(Sprite& Copy)
{
	*this=Copy;

	BackingStore[0]=new long[BackingSize];
	BackingStore[1]=new long[BackingSize];
	BackingStore[0][0]=0;
	BackingStore[1][0]=0;

	ExternalInca=TRUE;
}

Sprite::Sprite(Incarnation **List,int Count) :
	x(50),
	y(50),
	shape(0),
	BackingSize(2),
	OverlayMask(0),
	ExternalInca(TRUE),
	Shift(0)
{
	for (int i=0; i<Count; i++) {
		if (List[i]->BackingRequired() > BackingSize)
			BackingSize=List[i]->BackingRequired();
	}
	BackingSize++; // For OldInca
	BackingStore[0]=new long[BackingSize];
	BackingStore[1]=new long[BackingSize];
	BackingStore[0][0]=0;
	BackingStore[1][0]=0;

	MaxInca=Count;
	Inca=List;
}

Sprite::Sprite(Incarnation *OnlyOne) :
	x(50),
	y(50),
	shape(0),
	BackingSize(OnlyOne->BackingRequired()+1),
	OverlayMask(0),
	ExternalInca(FALSE),
	MaxInca(1),
	Shift(0)
{
	BackingStore[0]=new long[BackingSize];
	BackingStore[1]=new long[BackingSize];
	BackingStore[0][0]=0;
	BackingStore[1][0]=0;

	Inca=new Incarnation*[1];

	Inca[0]=OnlyOne;
}

Sprite::Sprite(FILE *fp) :
	Inca(0)
{
	if (!fget(fp)) {
		// ?
	}
}

Sprite::Sprite(const char *filename) :
	Inca(0)
{
	FILE* fp=fopen(filename,"rb");
	fget(fp);
	if (!fclose(fp)) {
		// ?
	}
}

Sprite::Sprite(short maxinca) :
	x(50),
	y(50),
	shape(0),
	BackingSize(2), // Nothing really
	Shift(0),
	OverlayMask(0),
	MaxInca(maxinca),
	Inca(new Incarnation*[MaxInca]),
	ExternalInca(FALSE)
{
	BackingStore[0]=new long[BackingSize];
	BackingStore[1]=new long[BackingSize];
	BackingStore[0][0]=0;
	BackingStore[1][0]=0;

	for (int i=0; i<MaxInca; i++) Inca[i]=0;
}

Sprite::~Sprite()
{
	delete BackingStore[0];
	delete BackingStore[1];
	if (!ExternalInca) {
		for (int i=0; i<MaxInca; i++) if (Inca[i]) delete Inca[i];
		delete Inca;
	}
}

void	Sprite::SetImage(int i, Incarnation* In)
{
	if (BackingSize < In->BackingRequired()+1) {
		BackingSize=In->BackingRequired()+1;
		delete BackingStore[0];
		delete BackingStore[1];
		BackingStore[0]=new long[BackingSize];
		BackingStore[1]=new long[BackingSize];
		BackingStore[0][0]=0;
		BackingStore[1][0]=0;
	}
	Inca[i]=In;
}

#define READ(x) fread(&x,sizeof(x),1,fp)
#define WRITE(x) fwrite(&x,sizeof(x),1,fp)

Incarnation* IncarnationReader(FILE *fp)
{
	short Tag;

	fread(&Tag,sizeof(Tag),1,fp);

	switch (Tag) {
	 case 0:
		return new MonochromeIncarnation(fp);
	break; case 1:
		return new ColourIncarnation(fp);
	break; case 2:
		return new WideMonochromeIncarnation(fp);
	break; case 3:
		return new WideColourIncarnation(fp);
	break; case 4:
		return new PreshiftedMonochromeIncarnation(fp);
	break; case 5:
		return new PreshiftedColourIncarnation(fp);
	break; case 6:
		return new TrueColourIncarnation(fp);
	break; default:
		return 0;
	}
}

int	Sprite::fget(FILE *fp)
{
	fread(&x,sizeof(x),1,fp);
	fread(&y,sizeof(y),1,fp);
	fread(&shape,sizeof(shape),1,fp);
	fread(&Shift,sizeof(Shift),1,fp);

	if (Inca && !ExternalInca) {
		for (int i=0; i<MaxInca; i++) if (Inca[i]) delete Inca[i];
		delete Inca;
	}

	fread(&MaxInca,sizeof(MaxInca),1,fp);

	Inca=new Incarnation*[MaxInca];

	int i;

	for (i=0; i<MaxInca; i++) {
		short yes;
		READ(yes);
		if (yes) {
			Inca[i]=IncarnationReader(fp);
		} else {
			Inca[i]=0;
		}
	}

	BackingSize=2; // Nothing really
	for (i=0; i<MaxInca; i++) {
		if (Inca[i] && Inca[i]->BackingRequired() > BackingSize)
			BackingSize=Inca[i]->BackingRequired();
	}
	BackingSize++; // For OldInca
	BackingStore[0]=new long[BackingSize];
	BackingStore[1]=new long[BackingSize];
	BackingStore[0][0]=0;
	BackingStore[1][0]=0;

	ExternalInca=FALSE;

	return 1;
}

int	Sprite::fput(FILE *fp)
{
	fwrite(&x,sizeof(x),1,fp);
	fwrite(&y,sizeof(y),1,fp);
	fwrite(&shape,sizeof(shape),1,fp);
	fwrite(&Shift,sizeof(Shift),1,fp);
	fwrite(&MaxInca,sizeof(MaxInca),1,fp);

	for (int i=0; i<MaxInca; i++) {
		short yes=(Inca[i]!=0);
		fwrite(&yes,sizeof(yes),1,fp);
		if (yes) Inca[i]->fput(fp);
	}

	return 1;
}

int	Sprite::Load(const char *filename)
{
	FILE* fp=fopen(filename,"rb");
	if (!fp) return 0;
	fget(fp);
	return fclose(fp);
}

int	Sprite::Save(const char *filename)
{
	FILE* fp=fopen(filename,"wb");
	if (!fp) return 0;
	fput(fp);
	return fclose(fp);
}

MonochromeIncarnation::MonochromeIncarnation(int h) :
	Incarnation(h,h+2),
	Data(new unsigned short[h]),
	Mask(new unsigned short[h])
{
}

MonochromeIncarnation::~MonochromeIncarnation()
{
	delete Data;
	delete Mask;
}

int	Incarnation::fput(FILE *fp)
{
	fwrite(&width,sizeof(width),1,fp);
	fwrite(&height,sizeof(height),1,fp);
	fwrite(&HotX,sizeof(HotX),1,fp);
	return (fwrite(&HotY,sizeof(HotY),1,fp)==1);
}

Incarnation::Incarnation(FILE *fp)
{
	READ(width);
	READ(height);
	READ(HotX);
	READ(HotY);
}

int	MonochromeIncarnation::fput(FILE *fp)
{
	short tag=0;
	fwrite(&tag,sizeof(tag),1,fp);
	Incarnation::fput(fp);
	fwrite(Data,sizeof(*Data),height,fp);
	return (fwrite(Mask,sizeof(*Mask),height,fp)==height);
}

MonochromeIncarnation::MonochromeIncarnation(FILE *fp) :
	Incarnation(fp),
	Data(new unsigned short[height]),
	Mask(new unsigned short[height])
{
	Backing=height+2;
	fread(Data,sizeof(*Data),height,fp);
	fread(Mask,sizeof(*Mask),height,fp);
}


int	MonochromeIncarnation::TouchDraw(short x, short y, long *Store)
{ return 0; }

void	MonochromeIncarnation::Draw(short x, short y, long *Store)
{
	x-=HotX;
	y-=HotY;
	short LineSpacing=Pages->Current().Rez().BytesPerLine();
	long *At = (long*)(Pages->Location() + y*LineSpacing + ((x>>4)<<1));
	unsigned short shift = 16-(x&15);
#ifdef NOASM
	unsigned short *D=Data;
	unsigned short *M=Mask;

	*(Store++)=(long)At;
	*(Store++)=(long)height-1;
	for (int h=0; h<height; h++) {
		*(Store++)=*At;
		*At=(*At & ~((long)(*(M++)) << shift)) | ((long)(*(D++)) << shift);
		At=(long*)((long)At+LineSpacing);
	}
#else
	asm("
			subl	#1,%6
			movel	%0,%5@+
			movel	%6,%5@+
		0:	movel	%0@,d0
			movel	d0,%5@+
			clrl	d1
			movew	%1@+,d1
			asll	%3,d1
			notl	d1
			andl	d1,d0
			clrl	d1
			movew	%2@+,d1
			asll	%3,d1
			orl	d1,d0
			movel	d0,%0@
			addl	%4,%0
			dbra	%6,0b
		1:
	"	: 
		: "a" (At),
		  "a" (Mask),
		  "a" (Data),
		  "d" (shift),
		  "d" ((long)LineSpacing),
		  "a" (Store),
		  "d" (height)
		
		: "d0", "d1");
#endif
}

void	SimpleMonoWipe(long *Store)
{
	short LineSpacing=Pages->Current().Rez().BytesPerLine();
#ifdef NOASM
	if (*Store) {
		long *At = (long*)*Store;
		*(Store++) = 0;

		for (int h=1+*(Store++); h; h--) {
			*At=*(Store++);
			At=(long*)((long)At+LineSpacing);
		}
	}
#else
	asm("
	movel	%0@,d0		| Since moves to address regs don't change Z flag
	beq	1f
	movel	d0,a0
	clrl	%0@+
	movel	%0@+,d0
0:
	movel	%0@+,a0@
	addl	%1,a0		| next line on screen
	dbra	d0,0b
1:
" :
  :	"a" (Store),
	"d" ((long)LineSpacing)

  :	"d0", "a0"
);
#endif
}

void	MonochromeIncarnation::Wipe(long *Store)
{
	SimpleMonoWipe(Store);
}

void	MonochromeIncarnation::GetImage(Screen& S, int x, int y)
{
	short LineSpacing=S.Rez().BytesPerLine();
	unsigned short *At=(unsigned short*)(S.Location()+y*LineSpacing+x/16*2);
	unsigned short *D,*M;
	unsigned short or=0;

	D=Data;
	M=Mask;
	for (int h=0; h<height; h++) {
		*D++=At[0];
		*M++=At[1];
		or|=At[1];
		At=(unsigned short*)((long)At+LineSpacing);
	}

	width=LeftBits(or);
}


WideMonochromeIncarnation::WideMonochromeIncarnation(int h) :
	Incarnation(h,(h+1)*3/2+2),
	Data(new unsigned long[h]),
	Mask(new unsigned long[h])
{ }

WideMonochromeIncarnation::~WideMonochromeIncarnation()
{
	delete Data;
	delete Mask;
}

int	WideMonochromeIncarnation::fput(FILE *fp)
{
	short tag=2;
	fwrite(&tag,sizeof(tag),1,fp);
	Incarnation::fput(fp);
	fwrite(Data,sizeof(*Data),height,fp);
	return fwrite(Mask,sizeof(*Mask),height,fp)==height;
}

WideMonochromeIncarnation::WideMonochromeIncarnation(FILE *fp) :
	Incarnation(fp),
	Data(new unsigned long[height]),
	Mask(new unsigned long[height])
{
	Backing=(height+1)*3/2+2;
	fread(Data,sizeof(*Data),height,fp);
	fread(Mask,sizeof(*Mask),height,fp);
}



int	WideMonochromeIncarnation::TouchDraw(short x, short y, long *Store)
{ return 0; }

void	WideMonochromeIncarnation::Draw(short x, short y, long *Store)
{
	x-=HotX;
	y-=HotY;
	short LineSpacing=Pages->Current().Rez().BytesPerLine();
	long *At = (long*)(Pages->Location() + y*LineSpacing + x/16*2);
#ifdef NOASM
	error("This is too hard to do without assembler");
#else
	short rshift=x&15;
	short lshift=16-rshift;

	asm("
	movel	%5,%2@+		| Save output address
	subl	#1,%6
	movel	%6,%2@+		| Save Height-1
0:
|	Save scanline:
	movel	%5@,%2@+
	movew	%5@(4),%2@+

|	Get mask
	movel	%1@+,d3
	movew	d3,d4
	lsrl	%4,d3
	aslw	%3,d4
	notl	d3
	notw	d4

|	Draw scanline:
	movel	%0@+,d1
	movew	d1,d2
	lsrl	%4,d1
	aslw	%3,d2

	movew	%5@(4),d0	| First the right end word
	andw	d4,d0
	orw	d2,d0
	movew	d0,%5@(4)
	movel	%5@,d0		| Then the left end long
	andl	d3,d0
	orl	d1,d0
	movel	d0,%5@
	
	addl	%7,%5		| next line on screen

	dbra	%6,0b

" :
  :	"a" (Data),
	"a" (Mask),
	"a" (Store),
	"d" (lshift),
	"d" (rshift),
	"a" (At),
	"d" ((long)height),
	"a" ((long)LineSpacing)

  :	"d0", "d1", "d2", "d3", "d4"
);
#endif
}

void	WideMonochromeIncarnation::Wipe(long *Store)
{
	short LineSpacing=Pages->Current().Rez().BytesPerLine();
#ifdef NOASM
	error("Too hairy mixing long and short without ASM");
#else
	asm("
	movel	%0@,d0		| Since moves to address regs don't change Z flag
	beq	1f
	movel	d0,a0
	clrl	%0@+
	movel	%0@+,d0
	subl	#4,%1
0:
	movel	%0@+,a0@+
	movew	%0@+,a0@
	addl	%1,a0		| next line on screen
	dbra	d0,0b
1:
" :
  :	"a" (Store),
	"d" ((long)LineSpacing)

  :	"d0", "a0"
);
#endif
}

void	WideMonochromeIncarnation::GetImage(Screen& S, int x, int y)
{
	short LineSpacing=S.Rez().BytesPerLine();
	unsigned long *At=(unsigned long*)(S.Location()+y*LineSpacing+x/16*2);
	unsigned long or=0,*D,*M;

	D=Data;
	M=Mask;
	for (int h=0; h<height; h++) {
		*D=*At;
		*M=At[1];
		or|=*M++;
		D++;
		At=(unsigned long*)((long)At+LineSpacing);
	}
	width=LongLeftBits(or);
}



PreshiftedMonochromeIncarnation::PreshiftedMonochromeIncarnation(int h)
	: Incarnation(h,h+2)
{
	int s;

	for (s=0; s<16; s++) Data[s]=new unsigned long[height];
	for (s=0; s<16; s++) Mask[s]=new unsigned long[height];
}

PreshiftedMonochromeIncarnation::~PreshiftedMonochromeIncarnation()
{
	int s;

	for (s=0; s<16; s++) delete Data[s];
	for (s=0; s<16; s++) delete Mask[s];
}

int	PreshiftedMonochromeIncarnation::fput(FILE *fp)
{
	short tag=4;
	fwrite(&tag,sizeof(tag),1,fp);
	Incarnation::fput(fp);
	fwrite(Data[0],sizeof(*Data[0]),height,fp);
	return fwrite(Mask[0],sizeof(*Mask[0]),height,fp)==height;
}

PreshiftedMonochromeIncarnation::PreshiftedMonochromeIncarnation(FILE *fp) :
	Incarnation(fp)
{
	int s;

	for (s=0; s<16; s++) Data[s]=new unsigned long[height];
	for (s=0; s<16; s++) Mask[s]=new unsigned long[height];

	Backing=height+2;
	fread(Data[0],sizeof(*Data[0]),height,fp);
	fread(Mask[0],sizeof(*Mask[0]),height,fp);

	// **** BELOW COPIED FROM GetImage - should be private member.
	unsigned long *D,*M,*SD,*SM;

	for (s=1; s<16; s++) {
		D=Data[0];
		M=Mask[0];

		SD=Data[s];
		SM=Mask[s];

		for (int h=0; h<height; h++) {
			*SD++=*D++>>s;
			*SM++=~(*M++>>s);
		}
	}

	M=Mask[0];
	for (int h=0; h<height; h++) {
		M[h]=~M[h];
	}
	// **** ABOVE COPIED FROM GetImage - should be private member.
}


int	PreshiftedMonochromeIncarnation::TouchDraw(short x, short y, long *Store)
{ return 0; }

void	PreshiftedMonochromeIncarnation::Draw(short x, short y, long *Store)
{
	x-=HotX;
	y-=HotY;
	unsigned short shift = x&15;
	short LineSpacing=Pages->Current().Rez().BytesPerLine();
	long *At = (long*)(Pages->Location() + y*LineSpacing+((x>>4)<<1));
#ifdef NOASM
	unsigned long *D=Data[shift];
	unsigned long *M=Mask[shift];

	unsigned long m;

	*(Store++)=(long)At;
	*(Store++)=(long)height-1;
	for (int h=0; h<height; h++) {
		m=*(M++);

		*(Store++)=*At;

		*At=*At & m | *(D++);

		At=(long*)((long)At+LineSpacing);
	}
#else
	asm("
	movel	%2,%3@+		| Save output address
	subl	#1,%4
	movel	%4,%3@+		| Save Height-1
0:
|	Get mask
	movel	%0@+,d1

	movel	%1@+,d0
	movel	%2@,d4
	movel	d4,%3@+
	andl	d1,d4
	orl	d0,d4
	movel	d4,%2@

	addl	%5,%2	| next line on screen

	dbra	%4,0b
" :
  :	"a" (Mask[shift]),
	"a" (Data[shift]),
	"a" (At),
	"a" (Store),
	"d" (height),
	"d" ((long)LineSpacing)
  :	"d0", "d1", "d4"
);
#endif
}

void	PreshiftedMonochromeIncarnation::Wipe(long *Store)
{
	SimpleMonoWipe(Store);
}


void	PreshiftedMonochromeIncarnation::GetImage(Screen& S, int x, int y)
{
	short LineSpacing=S.Rez().BytesPerLine();
	unsigned short *At=(unsigned short*)(S.Location()+y*LineSpacing+x/16*2);
	unsigned long *D,*M,*SD,*SM;
	unsigned short or=0;
	int h;

	D=Data[0];
	M=Mask[0];
	for (h=0; h<height; h++) {
		*D++=At[0] << 16;
		*M++=At[1] << 16;
		or|=At[1];
		At=(unsigned short*)((long)At+LineSpacing);
	}
	width=LeftBits(or);

	for (int s=1; s<16; s++) {
		D=Data[0];
		M=Mask[0];

		SD=Data[s];
		SM=Mask[s];

		for (h=0; h<height; h++) {
			*SD++=*D++>>s;

			*SM++=~(*M++>>s);
		}
	}

	M=Mask[0];
	for (h=0; h<height; h++) {
		M[h]=~M[h];
	}
}


WideColourIncarnation::WideColourIncarnation(int h) :
	Incarnation(h,h*6+2),
	Data(new unsigned long[h*4]),
	Mask(new unsigned long[h])
{ }

WideColourIncarnation::~WideColourIncarnation()
{
	delete Data;
	delete Mask;
}

int	WideColourIncarnation::fput(FILE *fp)
{
	short tag=3;
	fwrite(&tag,sizeof(tag),1,fp);
	Incarnation::fput(fp);
	fwrite(Data,sizeof(*Data),height*6,fp);
	return fwrite(Mask,sizeof(*Mask),height,fp)==height;
}

WideColourIncarnation::WideColourIncarnation(FILE *fp) :
	Incarnation(fp),
	Data(new unsigned long[height*6]),
	Mask(new unsigned long[height])
{
	Backing=height*6+2;
	fread(Data,sizeof(*Data),height*6,fp);
	fread(Mask,sizeof(*Mask),height,fp);
}


int	WideColourIncarnation::TouchDraw(short x, short y, long *Store)
{ return 0; }

void	WideColourIncarnation::Draw(short x, short y, long *Store)
{
	x-=HotX;
	y-=HotY;
	short LineSpacing=Pages->Current().Rez().BytesPerLine();
	long *At = (long*)(Pages->Location() + y*LineSpacing+((x>>4)<<3));
#ifdef NOASM
	error("This is too hard to do without assembler");
#else
	short rshift=x&15;
	short lshift=16-rshift;

	asm("
	movel	%5,%2@+		| Save output address
	subl	#1,%6
	movel	%6,%2@+		| Save Height-1
0:
|	Save scanline:
	movel	%5@,%2@+
	movel	%5@(4),%2@+
	movel	%5@(8),%2@+
	movel	%5@(12),%2@+
	movel	%5@(16),%2@+
	movel	%5@(20),%2@+

|	Get mask
	movel	%1@+,d3
	movew	d3,d4
	lsrl	%4,d3
	aslw	%3,d4
	notl	d3
	notw	d4

|	Draw scanline:
	movel	%0@+,d1
	movew	d1,d2
	lsrl	%4,d1
	aslw	%3,d2

	movew	%5@(16),d0	| First the right end word
	andw	d4,d0
	orw	d2,d0
	movew	d0,%5@(16)
	movew	%5@,d0		| Then the left end long
	swap	d0
	movew	%5@(8),d0
	andl	d3,d0
	orl	d1,d0
	movew	d0,%5@(8)
	swap	d0
	movew	d0,%5@+
	
|	Draw scanline:
	movel	%0@+,d1
	movew	d1,d2
	lsrl	%4,d1
	aslw	%3,d2

	movew	%5@(16),d0	| First the right end word
	andw	d4,d0
	orw	d2,d0
	movew	d0,%5@(16)
	movew	%5@,d0		| Then the left end long
	swap	d0
	movew	%5@(8),d0
	andl	d3,d0
	orl	d1,d0
	movew	d0,%5@(8)
	swap	d0
	movew	d0,%5@+
	
|	Draw scanline:
	movel	%0@+,d1
	movew	d1,d2
	lsrl	%4,d1
	aslw	%3,d2

	movew	%5@(16),d0	| First the right end word
	andw	d4,d0
	orw	d2,d0
	movew	d0,%5@(16)
	movew	%5@,d0		| Then the left end long
	swap	d0
	movew	%5@(8),d0
	andl	d3,d0
	orl	d1,d0
	movew	d0,%5@(8)
	swap	d0
	movew	d0,%5@+
	
|	Draw scanline:
	movel	%0@+,d1
	movew	d1,d2
	lsrl	%4,d1
	aslw	%3,d2

	movew	%5@(16),d0	| First the right end word
	andw	d4,d0
	orw	d2,d0
	movew	d0,%5@(16)
	movew	%5@,d0		| Then the left end long
	swap	d0
	movew	%5@(8),d0
	andl	d3,d0
	orl	d1,d0
	movew	d0,%5@(8)
	swap	d0
	movew	d0,%5@+
	
	addl	%7,%5		| next line on screen
	subl	#8,%5

	dbra	%6,0b

" :
  :	"a" (Data),
	"a" (Mask),
	"a" (Store),
	"d" (lshift),
	"d" (rshift),
	"a" (At),
	"d" ((long)height),
	"a" ((long)LineSpacing)

  :	"d0", "d1", "d2", "d3", "d4"
);
#endif
}

void	WideColourIncarnation::Wipe(long *Store)
{
	short LineSpacing=Pages->Current().Rez().BytesPerLine();
#ifdef NOASM
	if (*Store) {
		long *At = (long*) *Store;
		*(Store++) = 0;

		for (int h=1+*(Store++); h; h--) {
			*At=*(Store++);
			At[1]=*(Store++);
			At[2]=*(Store++);
			At[3]=*(Store++);
			At[4]=*(Store++);
			At[5]=*(Store++);
			At=(long*)((long)At+LineSpacing);
		}
	}
#else
	asm("
	movel	%0@,d0		| Since moves to address regs don't change Z flag
	beq	1f
	movel	d0,a0
	clrl	%0@+
	movel	%0@+,d0
	subl	#20,%1
0:
	movel	%0@+,a0@+
	movel	%0@+,a0@+
	movel	%0@+,a0@+
	movel	%0@+,a0@+
	movel	%0@+,a0@+
	movel	%0@+,a0@
	addl	%1,a0		| next line on screen
	dbra	d0,0b
1:
" :
  :	"a" (Store),
	"d" ((long)LineSpacing)

  :	"d0", "a0"
);
#endif
}

void	WideColourIncarnation::GetImage(Screen& S, int x, int y)
{
	short LineSpacing=S.Rez().BytesPerLine();
	unsigned short *At=(unsigned short*)(S.Location()+y*LineSpacing+x/16*8);
	unsigned long or=0,*D,*M;

	D=Data;
	M=Mask;
	for (int h=0; h<height; h++) {
		D[0]=At[0]<<16|At[4];
		D[1]=At[1]<<16|At[5];
		D[2]=At[2]<<16|At[6];
		D[3]=At[3]<<16|At[7];
		*M=D[0]|D[1]|D[2]|D[3];
		or|=*M++;
		D+=4;
		At=(unsigned short*)((long)At+LineSpacing);
	}
	width=LongLeftBits(or);
}



ColourIncarnation::ColourIncarnation(int h) :
	Incarnation(h,h*4+2),
	Data(new unsigned short[h*4]),
	Mask(new unsigned short[h])
{ }

ColourIncarnation::~ColourIncarnation()
{
	delete Data;
	delete Mask;
}

int	ColourIncarnation::fput(FILE *fp)
{
	short tag=1;
	fwrite(&tag,sizeof(tag),1,fp);
	Incarnation::fput(fp);
	fwrite(Data,sizeof(*Data),height*4,fp);
	return fwrite(Mask,sizeof(*Mask),height,fp)==height;
}

ColourIncarnation::ColourIncarnation(FILE *fp) :
	Incarnation(fp),
	Data(new unsigned short[height*4]),
	Mask(new unsigned short[height])
{
	Backing=height*4+2;
	fread(Data,sizeof(*Data),height*4,fp);
	fread(Mask,sizeof(*Mask),height,fp);
}


int	ColourIncarnation::TouchDraw(short x, short y, long *Store)
{ return 0; }

void	ColourIncarnation::Draw(short x, short y, long *Store)
{
	x-=HotX;
	y-=HotY;
	unsigned short shift = 16-(x&15);
	short LineSpacing=Pages->Current().Rez().BytesPerLine();
	long *At = (long*)(Pages->Location() + y*LineSpacing+((x>>4)<<3));
#ifdef NOASM
	unsigned short *D=Data;
	unsigned short *M=Mask;

	unsigned long m1,m2,d1,d2,t1,t2,t3,t4;

	*(Store++)=(long)At;
	*(Store++)=(long)height-1;
	for (int h=0; h<height; h++) {
		t1=~(((long)*(M++)) << shift);
		m1=(t1 & 0xffff0000) | ((t1 & 0xffff0000) >> 16);
		m2=((t1 & 0x0000ffff) << 16) | (t1 & 0x0000ffff);

		*(Store++)=*At;
		*(Store++)=At[1];
		*(Store++)=At[2];
		*(Store++)=At[3];

		t1=((long)*(D++)) << shift;
		t2=((long)*(D++)) << shift;
		t3=((long)*(D++)) << shift;
		t4=((long)*(D++)) << shift;
		d1=(t1 & 0xffff0000) | ((t2 & 0xffff0000) >> 16);
		d2=((t1 & 0x0000ffff) << 16) | (t2 & 0x0000ffff);
		At[0]=(At[0] & m1) | d1;
		At[2]=(At[2] & m2) | d2;
		d1=(t3 & 0xffff0000) | ((t4 & 0xffff0000) >> 16);
		d2=((t3 & 0x0000ffff) << 16) | (t4 & 0x0000ffff);
		At[1]=(At[1] & m1) | d1;
		At[3]=(At[3] & m2) | d2;

		At=(long*)((long)At+LineSpacing);
	}
#else
	asm("
	movel	%4,%2@+		| Save output address
	subl	#1,%5
	movel	%5,%2@+		| Save Height-1
0:
|	Save scanline:
	movel	%4@,%2@+
	movel	%4@(4),%2@+
	movel	%4@(8),%2@+
	movel	%4@(12),%2@+

|	Get mask
	clrl	d1
	movew	%1@+,d1
	asll	%3,d1
	notl	d1

|	Draw scanline:  Word 1
	clrl	d0
	movew	%0@+,d0
	asll	%3,d0
	movew	%4@,d4
	swap	d4
	movew	%4@(8),d4
	andl	d1,d4
	orl	d0,d4
	movew	d4,%4@(8)
	swap	d4
	movew	d4,%4@+

|	Draw scanline:  Word 2
	clrl	d0
	movew	%0@+,d0
	asll	%3,d0
	movew	%4@,d4
	swap	d4
	movew	%4@(8),d4
	andl	d1,d4
	orl	d0,d4
	movew	d4,%4@(8)
	swap	d4
	movew	d4,%4@+

|	Draw scanline:  Word 3
	clrl	d0
	movew	%0@+,d0
	asll	%3,d0
	movew	%4@,d4
	swap	d4
	movew	%4@(8),d4
	andl	d1,d4
	orl	d0,d4
	movew	d4,%4@(8)
	swap	d4
	movew	d4,%4@+

|	Draw scanline:  Word 4
	clrl	d0
	movew	%0@+,d0
	asll	%3,d0
	movew	%4@,d4
	swap	d4
	movew	%4@(8),d4
	andl	d1,d4
	orl	d0,d4
	movew	d4,%4@(8)
	swap	d4
	movew	d4,%4@+

	addl	%6,%4		| next line on screen
	subl	#8,%4

	dbra	%5,0b

" :
  :	"a" (Data),
	"a" (Mask),
	"a" (Store),
	"d" (shift),
	"a" (At),
	"d" ((long)height),
	"d" ((long)LineSpacing)

  :	"d0", "d1", "d4"
);
#endif
}

void	SimpleWipe(long *Store)
{
	short LineSpacing=Pages->Current().Rez().BytesPerLine();
#ifdef NOASM
	if (*Store) {
		long *At = (long*) *Store;
		*(Store++) = 0;

		for (int h=1+*(Store++); h; h--) {
			*At=*(Store++);
			At[1]=*(Store++);
			At[2]=*(Store++);
			At[3]=*(Store++);
			At=(long*)((long)At+LineSpacing);
		}
	}
#else
	asm("
	movel	%0@,d0		| Since moves to address regs don't change Z flag
	beq	1f
	movel	d0,a0
	clrl	%0@+
	movel	%0@+,d0
	subl	#12,%1
0:
	movel	%0@+,a0@+
	movel	%0@+,a0@+
	movel	%0@+,a0@+
	movel	%0@+,a0@
	addl	%1,a0		| next line on screen
	dbra	d0,0b
1:
" :
  :	"a" (Store),
	"d" ((long)LineSpacing)

  :	"d0", "a0"
);
#endif
}

void	ColourIncarnation::Wipe(long *Store)
{
	SimpleWipe(Store);
}

void	ColourIncarnation::GetImage(Screen& S, int x, int y)
{
	short LineSpacing=S.Rez().BytesPerLine();
	unsigned short *At=(unsigned short*)(S.Location()+y*LineSpacing+x/16*8);
	unsigned short or=0,*D,*M;

	D=Data;
	M=Mask;
	for (int h=0; h<height; h++) {
		*D++=At[0];
		*D++=At[1];
		*D++=At[2];
		*D++=At[3];
		*M=At[0]|At[1]|At[2]|At[3];
		or|=*M++;
		At=(unsigned short*)((long)At+LineSpacing);
	}
	width=LeftBits(or);
}



PreshiftedColourIncarnation::PreshiftedColourIncarnation(int h)
	: Incarnation(h,h*4+2)
{
	int s;

	for (s=0; s<16; s++) Data[s]=new unsigned short[height*4*2];
	for (s=0; s<16; s++) Mask[s]=new unsigned short[height*2];
}

PreshiftedColourIncarnation::~PreshiftedColourIncarnation()
{
	int s;

	for (s=0; s<16; s++) delete Data[s];
	for (s=0; s<16; s++) delete Mask[s];
}

int	PreshiftedColourIncarnation::fput(FILE *fp)
{
	short tag=5;
	fwrite(&tag,sizeof(tag),1,fp);
	Incarnation::fput(fp);
	fwrite(Data[0],sizeof(*Data[0]),height*4*2,fp);
	return fwrite(Mask[0],sizeof(*Mask[0]),height*2,fp)==height*2;
}

PreshiftedColourIncarnation::PreshiftedColourIncarnation(FILE *fp) :
	Incarnation(fp)
{
	int s;

	for (s=0; s<16; s++) Data[s]=new unsigned short[height*4*2];
	for (s=0; s<16; s++) Mask[s]=new unsigned short[height*2];

	Backing=height*4+2;

	fread(Data[0],sizeof(*Data[0]),height*4*2,fp);
	fread(Mask[0],sizeof(*Mask[0]),height*2,fp);

	unsigned short *D,*M,*SD,*SM;
	int h;

	// Invert mask (easier to shift)
	M=Mask[0];
	for (h=0; h<height; h++) {
		M[h*2]=~M[h*2];
		M[h*2+1]=~0;
	}

	// BELOW COPIED FROM GetImage
	unsigned long t;

	for (s=1; s<16; s++) {
		D=Data[0];
		M=Mask[0];

		SD=Data[s];
		SM=Mask[s];

		for (int h=0; h<height; h++) {
			for (int bp=0; bp<4; bp++) {
				t=(long)D[bp] << (16-s);
				SD[bp]=t>>16;
				SD[bp+4]=t&0xffff;
			}
			SD+=8;
			D+=8;

			t=((unsigned long)*M++ << (16-s));
			M++;
			*SM++=~(t>>16);
			*SM++=~(t&0xffff);
		}
	}

	M=Mask[0];
	for (h=0; h<height; h++) {
		M[h*2]=~M[h*2];
		M[h*2+1]=~0;
	}
	// ABOVE COPIED FROM GetImage
}


int	PreshiftedColourIncarnation::TouchDraw(short x, short y, long *Store)
{ return 0; }

void	PreshiftedColourIncarnation::Draw(short x, short y, long *Store)
{
	x-=HotX;
	y-=HotY;
	unsigned short shift = x&15;
	short LineSpacing=Pages->Current().Rez().BytesPerLine();
	long *At = (long*)(Pages->Location() + y*LineSpacing+((x>>4)<<3));
#ifdef NOASM
	unsigned short *D=Data[shift];
	unsigned short *M=Mask[shift];

	unsigned long m;

	*(Store++)=(long)At;
	*(Store++)=(long)height-1;
	for (int h=0; h<height; h++) {
		m=*(M++);

		*(Store++)=At[0];
		*(Store++)=At[1];
		*(Store++)=At[2];
		*(Store++)=At[3];

		At[0]=At[0] & m | *(D++);
		At[1]=At[1] & m | *(D++);
		At[2]=At[2] & m | *(D++);
		At[3]=At[3] & m | *(D++);

		At=(long*)((long)At+LineSpacing);
	}
#else
	asm("
	movel	%2,%3@+		| Save output address
	subl	#1,%4
	movel	%4,%3@+		| Save Height-1
	subl	#12,%5
0:
|	Get mask	HH in d3, LL in d1
	movel	%0@+,d1
	movel	d1,d3
	swap	d1
	movew	d1,d0
	movew	d3,d1
	movew	d0,d3

|:	First word, bitplanes 0 & 1
	movel	%1@+,d0
	movel	%2@,d4
	movel	d4,%3@+
	andl	d3,d4
	orl	d0,d4
	movel	d4,%2@+

|:	First word, bitplanes 2 & 3
	movel	%1@+,d0
	movel	%2@,d4
	movel	d4,%3@+
	andl	d3,d4
	orl	d0,d4
	movel	d4,%2@+

|:	Second word (second mask), bitplanes 0 & 1
	movel	%1@+,d0
	movel	%2@,d4
	movel	d4,%3@+
	andl	d1,d4
	orl	d0,d4
	movel	d4,%2@+

|:	Second word (second mask), bitplanes 2 & 3
	movel	%1@+,d0
	movel	%2@,d4
	movel	d4,%3@+
	andl	d1,d4
	orl	d0,d4
	movel	d4,%2@

	addl	%5,%2	| next line on screen

	dbra	%4,0b
" :
  :	"a" (Mask[shift]),
	"a" (Data[shift]),
	"a" (At),
	"a" (Store),
	"d" (height),
	"d" ((long)LineSpacing)
  :	"d0", "d1", "d3", "d4"
);
#endif
}

void	PreshiftedColourIncarnation::Wipe(long *Store)
{
	SimpleWipe(Store);
}


void	PreshiftedColourIncarnation::GetImage(Screen& S, int x, int y)
{
	short LineSpacing=S.Rez().BytesPerLine();
	unsigned short *At=(unsigned short*)(S.Location()+y*LineSpacing+x/16*8);
	unsigned short or=0,*D,*M,*SD,*SM;
	unsigned long t;
	int h,bp;

	D=Data[0];
	M=Mask[0];
	for (h=0; h<height; h++) {
		*D++=At[0];
		*D++=At[1];
		*D++=At[2];
		*D++=At[3];
		*D++=0;
		*D++=0;
		*D++=0;
		*D++=0;
		*M=(At[0]|At[1]|At[2]|At[3]);
		or|=*M++;
		*M++=0;
		At=(unsigned short*)((long)At+LineSpacing);
	}
	width=LeftBits(or);

	for (int s=1; s<16; s++) {
		D=Data[0];
		M=Mask[0];

		SD=Data[s];
		SM=Mask[s];

		for (h=0; h<height; h++) {
			for (bp=0; bp<4; bp++) {
				t=(long)D[bp] << (16-s);
				SD[bp]=t>>16;
				SD[bp+4]=t&0xffff;
			}
			SD+=8;
			D+=8;

			t=((unsigned long)*M++ << (16-s));
			M++;
			*SM++=~(t>>16);
			*SM++=~(t&0xffff);
		}
	}

	M=Mask[0];
	for (h=0; h<height; h++) {
		M[h*2]=~M[h*2];
		M[h*2+1]=~0;
	}
}



TrueColourIncarnation::TrueColourIncarnation(int w, int h) :
	Incarnation(h,1),
	Data(0),
	DataLength(0)
{
	width=w;
}

TrueColourIncarnation::~TrueColourIncarnation()
{
	if (Data) delete Data;
}

int	TrueColourIncarnation::fput(FILE *fp)
{
	short tag=6;
	fwrite(&tag,sizeof(tag),1,fp);
	Incarnation::fput(fp);
	fwrite(&Backing,sizeof(Backing),1,fp);
	fwrite(&DataLength,sizeof(DataLength),1,fp);
	return fwrite(Data,sizeof(Data[0]),DataLength,fp)==DataLength;
}

TrueColourIncarnation::TrueColourIncarnation(FILE *fp) :
	Incarnation(fp)
{
	fread(&Backing,sizeof(Backing),1,fp);
	fread(&DataLength,sizeof(DataLength),1,fp);
	fread(Data,sizeof(Data[0]),DataLength,fp);
}


int	TrueColourIncarnation::TouchDraw(short x, short y, long *Store)
{
	// Oh, come on, this is easy to implement!
	return 0;
}

void	TrueColourIncarnation::Draw(short x, short y, long *Store)
{
	x-=HotX;
	y-=HotY;
	short *At = (short*)(Pages->Location()) + x + y*Pages->Current().Rez().BytesPerLine()/sizeof(short);

// Automatically generated by gentcd
#include "../src/tcd.icc"
}

void	TrueColourIncarnation::Wipe(long *Store)
{
// Automatically generated by gentcd
#include "../src/tcw.icc"
}


// TrueColour incarnations are drawn using a series of "commands"
// from the Data.  The commands are:
//
//	0	Quit
//	1..22	n sequential pixels (n pos value^n)
//
//	24	5x1-pixel (24 value^5 pos^5)
//	25	5x2-pixel (25 value^10 pos^5)
//	26	3x2;2x4-pixel (26 value^14 pos^5)
//
//	32	5x1-pixel 'AND'
//	33	5x2-pixel 'AND'
//	34	3x2;2x4-pixel 'AND'
//
//	40	5x1-pixel 'ADD'
//	41	5x2-pixel 'ADD'
//	42	3x2;2x4-pixel 'ADD'
//
//	48	5x1-pixel 'OR'
//	49	5x2-pixel 'OR'
//	50	3x2;2x4-pixel 'OR'


#define PUT5 24
#define PUT10 25
#define PUT14 26

void TrueColourIncarnation::GetImage(Screen& S, int x, int y)
{
	short LineSpacing=S.Rez().BytesPerLine()/sizeof(short);
	unsigned short *At=(unsigned short*)(S.Location())+y*LineSpacing+x;

	if (Data) delete Data;

// Limited implementation:  two-pass, n-pixel commands only...

	int cmdcount=0;
	int bckcount=0;
	for (int final=0; final<=1; final++) {
		unsigned short* d=0;
		if (final) {
			Data=new unsigned short[cmdcount];
			Backing=bckcount;
			d=Data;
		}
		for (int j=0; j<height; j++) {
			for (int i=0; i<width; i++) {
				int n=0;
				while (n<22 && i+n<width && At[j*LineSpacing+i+n]) n++;
				if (n) {
					// n-PIXEL command...

					if (final) {
						*(d++)=n;
						*((long*)d)=(j*LineSpacing+i)*sizeof(short);
						d+=2;
						for (int N=0; N<(n); N++)
							*(d++)=At[j*LineSpacing+i+N];
					} else {
						cmdcount+=1+2+n;
						bckcount+=n;
					}
					i+=n-1;
				}
			}
		}

		// QUIT command...
		if (final) {
			*(d++)=0;
		} else {
			cmdcount++;
			bckcount+=2; // includes initial pos storage
		}
	}
}
