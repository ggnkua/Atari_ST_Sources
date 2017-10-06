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

#ifndef BlockMap_h
#define BlockMap_h
#include "Screen.h"
#include <bool.h>
#include <stdio.h>
#include <shape.h>


class BlockMapView;

class BlockImages
{
public:
	virtual ~BlockImages();

	void GetImages(short c, short num, Screen&);
	// Simplified multiple GetImage

	virtual void GetImage(short, int x, int y, Screen&)=0;
	virtual void GetImage(short c, Point& P, Screen& s) { GetImage(c,P.x,P.y,s); }

protected:
	BlockImages(short maxblocks, short WordsPerBlock, short WWidth, short height);

	short wordwidth;
	short height;
	short maxblocks;
	short blockshift;
	short *blockdata;

	friend BlockMapView;

	virtual void Draw(short c, short*& At, int LineSpacing)=0;
	// Draws c at position At, modifying At to be immediately below
	// the image drawn.
};


class ColourBlockImages : public BlockImages
{
public:
	ColourBlockImages(short maxblocks,short height);
	virtual void GetImage(short, int x, int y, Screen&);
private:
	virtual void Draw(short, short*& At, int LineSpacing);
};

class WideColourBlockImages : public BlockImages
{
public:
	WideColourBlockImages(short maxblocks,short height);
	virtual void GetImage(short, int x, int y, Screen&);
private:
	virtual void Draw(short, short*& At, int LineSpacing);
};

class MonochromeBlockImages : public BlockImages
{
public:
	MonochromeBlockImages(short maxblocks,short height);
	virtual void GetImage(short, int x, int y, Screen&);
private:
	virtual void Draw(short, short*& At, int LineSpacing);
};

class WideMonochromeBlockImages : public BlockImages
{
public:
	WideMonochromeBlockImages(short maxblocks,short height);
	virtual void GetImage(short, int x, int y, Screen&);
private:
	virtual void Draw(short, short*& At, int LineSpacing);
};


class BlockMap
{
public:
	BlockMap(short w, short h, char *map);
	BlockMap(short w, short h, short *map);
	BlockMap(short w, short h, int MaxBlockImages=256);
	~BlockMap();

	short operator() (short x, short y);
	short operator() (Point& P) { return operator()(P.x,P.y); }
	void Set(short x, short y, short ch);
	void Set(Point& P, short ch) { Set(P.x,P.y,ch); }
	bool Includes(short x, short y);
	bool Includes(Point& P) { return Includes(P.x,P.y); }

	int fput(FILE *fp);
	int fget(FILE *fp);

private:
	bool use_short_not_char;
	bool dynamic;
	short width,height;
	short shiftheight;
	BlockMapView *views;
	short *data;

	friend BlockMapView;
};


class BlockMapView
{
public:
	// Position at pixel (sx,sy) on screen, w by h blocks in size,
	// viewing (x,y) in a map.
	BlockMapView(BlockMap& m, BlockImages& Im,
			short sx, short sy, short w, short h,
			short x=0, short y=0);

	void views(short x, short y);
	void views(Point& P) { views(P.x,P.y); }
	void Resize(short w, short h);
	void ViewsArea(Rectangle R) { views(R); Resize(R.w,R.h); }
	void MoveView(short sx, short sy);
	void MoveView(Point P) { MoveView(P.x,P.y); }
	void ViewsMap(BlockMap& m);
	void ViewsImages(BlockImages& Im);

	void Draw();

private:
	// For BlockMap
	void Touch(short x, short y); // one in all
	void Touch(); // all in all
	void TouchMe(); // all in one

	int pageoffset;
	short x,y;
	short width,height;
	struct ChangeList {
		short x,y;
	}* change[2];
	short changes[2];
	short maxchanges;
	BlockMap *map;
	BlockImages *images;
	BlockMapView *next;	// For views list in BlockMap

	friend BlockMap;
};


inline bool BlockMap::Includes(short x, short y) { return x>=0 && y>=0 && x<width && y<height; }
inline void BlockMapView::views(short x, short y) {x=x; y=y; TouchMe();}
inline void BlockMapView::Resize(short w, short h) {width=w; height=h; TouchMe();}
inline void BlockMapView::ViewsImages(BlockImages& Im) {images=&Im; TouchMe();}

#endif
