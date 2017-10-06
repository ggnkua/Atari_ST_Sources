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

#ifndef _Sprite_h
#define _Sprite_h
//
//  Sprites - small objects, double buffered.
//

#include <stdio.h>
#include <bool.h>
#include "DoubleBuffer.h"

class Incarnation
{
public:
	// Set hot spot (default (0,0))
	void		SetHotSpot(short x, short y);

	// I/O
	virtual int	fput(FILE *fp);

	// Draw/Wipe image from double buffer page.  Coordinates are in pixels.
	virtual void	Draw(short x, short y, long *Store)=0;
	virtual int	TouchDraw(short x, short y, long *Store)=0; // not implemented
	virtual void	Wipe(long *Store)=0;

	// Take the area at (x,y) on the given screen as the image.
	// x must be multiple of 16.
	virtual void	GetImage(Screen&, int x, int y)=0;

	// Return width and height of the incarnation.
	// Width is actual pixel width from the left.
	short	Width() { return width; }
	short	Height() { return height; }

	// Words of backing store used by the incarnmation (used by Sprite)
	int	BackingRequired() { return Backing; }

protected:
	Incarnation(FILE *fp);
	Incarnation(short h, int b);
	short	width,height; // In pixels
	short	HotX,HotY;
	int	Backing;
};


class Sprite
{
public:
	// Constructors:

	//  A sprite with one shape.
	Sprite(Incarnation *OnlyOne);

	//  A sprite with an array of shapes.
	Sprite(Incarnation **ListOfThem,int Count);

	//  A sprite with a list of (undefined) shapes.
	Sprite(short maxinca);

	//  A sprite with the same shapes as another sprite.
	Sprite(Sprite& Copy);

	//  A sprite from a file.
	Sprite(const char *filename);
	Sprite(FILE *);

	// Destructor
	~Sprite();

	// I/O
	int		Load(const char *filename);
	int		Save(const char *filename);

	int		fput(FILE *);
	int		fget(FILE *);

	// Draw on current page
	void		Draw();
	int		TouchDraw(); // not implemented
	// Remove from page.  If already wiped, does nothing.
	void		Wipe();

	// Choose incarnation, starting from 0.
	void		ShapeTo(short);

	// Scale of pixels to coords.  Coord = 2**Scale * Pixel
	// All values below are scaled by this amount
	void		Scale(short s) { Shift=s; }

	// Move
	void		MoveTo(int x, int y);
	void		MoveBy(int x, int y);

	// Set one of the possible shapes to a given Incarnation
	void		SetImage(int i, Incarnation* In);

	// Inspectors
	int X() { return x; }
	int Y() { return y; }
	int Shape() { return shape; }
	int Width() { return Inca[shape]->Width() << Shift; }
	int Height() { return Inca[shape]->Height() << Shift; }

protected:
	int	x,y;
	short shape;
	short Shift;

	long *BackingStore[2];
	unsigned int BackingSize;
	char *OverlayMask;

	short MaxInca;
	Incarnation **Inca; // Dynamically allocated array of *Incarnation

private:
	bool ExternalInca;
};


/////////////////////////////
//
//  Below are all the derived Incarnations,
//  see main comment for details.
//
/////////////////////////////


class MonochromeIncarnation : public Incarnation
{
public:
	MonochromeIncarnation(int height);
	virtual ~MonochromeIncarnation();

	virtual void	Draw(short x, short y, long *Store);
	virtual int	TouchDraw(short x, short y, long* Store);
	virtual void	Wipe(long *Store);

	virtual int	fput(FILE *fp);

	virtual void	GetImage(Screen&, int x, int y);

private:
	friend Incarnation* IncarnationReader(FILE *fp);
	MonochromeIncarnation(FILE*);
	short unsigned *Data,*Mask;
};


class WideMonochromeIncarnation : public Incarnation
{
public:
	WideMonochromeIncarnation(int height);
	virtual ~WideMonochromeIncarnation();

	virtual void	Draw(short x, short y, long *Store);
	virtual int	TouchDraw(short x, short y, long* Store);
	virtual void	Wipe(long *Store);

	virtual int	fput(FILE *fp);

	virtual void	GetImage(Screen&, int x, int y);

private:
	friend Incarnation* IncarnationReader(FILE *fp);
	WideMonochromeIncarnation(FILE*);
	unsigned long *Data,*Mask;
};


class PreshiftedMonochromeIncarnation : public Incarnation
{
public:
	PreshiftedMonochromeIncarnation(int height);
	virtual ~PreshiftedMonochromeIncarnation();

	virtual void	Draw(short x, short y, long *Store);
	virtual int	TouchDraw(short x, short y, long* Store);
	virtual void	Wipe(long *Store);

	virtual int	fput(FILE *fp);

	virtual void	GetImage(Screen&, int x, int y);

private:
	friend Incarnation* IncarnationReader(FILE *fp);
	PreshiftedMonochromeIncarnation(FILE*);
	unsigned long *Data[16],*Mask[16];
};



class WideColourIncarnation : public Incarnation
{
public:
	WideColourIncarnation(int height);
	virtual ~WideColourIncarnation();

	virtual void	Draw(short x, short y, long *Store);
	virtual int	TouchDraw(short x, short y, long* Store);
	virtual void	Wipe(long *Store);

	virtual int	fput(FILE *fp);

	virtual void	GetImage(Screen&, int x, int y);

private:
	friend Incarnation* IncarnationReader(FILE *fp);
	WideColourIncarnation(FILE*);
	long unsigned *Data,*Mask;
};

class ColourIncarnation : public Incarnation
{
public:
	ColourIncarnation(int height);
	virtual ~ColourIncarnation();

	virtual void	Draw(short x, short y, long *Store);
	virtual int	TouchDraw(short x, short y, long* Store);
	virtual void	Wipe(long *Store);

	virtual int	fput(FILE *fp);

	virtual void	GetImage(Screen&, int x, int y);

private:
	friend Incarnation* IncarnationReader(FILE *fp);
	ColourIncarnation(FILE*);
	short unsigned *Data,*Mask;
};

class PreshiftedColourIncarnation : public Incarnation
{
public:
	PreshiftedColourIncarnation(int height);
	virtual ~PreshiftedColourIncarnation();

	virtual void	Draw(short x, short y, long *Store);
	virtual int	TouchDraw(short x, short y, long* Store);
	virtual void	Wipe(long *Store);

	virtual int	fput(FILE *fp);

	virtual void	GetImage(Screen&, int x, int y);

private:
	friend Incarnation* IncarnationReader(FILE *fp);
	PreshiftedColourIncarnation(FILE*);
	short unsigned *Data[16],*Mask[16];
};


// NOTE: TrueColourIncarnations must be initialized to an
//        image always and only BEFORE being added to a sprite,
//        otherwise backingstore requirements cannot be known.
class TrueColourIncarnation : public Incarnation
{
public:
	TrueColourIncarnation(int width, int height);
	virtual ~TrueColourIncarnation();

	virtual void Draw(short x, short y, long *Store);
	virtual int TouchDraw(short x, short y, long* Store);
	virtual void Wipe(long *Store);

	virtual int fput(FILE *fp);

	virtual void GetImage(Screen&, int x, int y);

private:
	friend Incarnation* IncarnationReader(FILE *fp);
	TrueColourIncarnation(FILE*);
	short unsigned *Data;
	int DataLength;
};


// Some inlines for efficiency...

inline void	Sprite::MoveTo(int X, int Y) { x=X; y=Y; }
inline void	Sprite::MoveBy(int X, int Y) { x+=X; y+=Y; }
inline void	Sprite::ShapeTo(short s) { shape=s; }

#endif // !Sprite_h
