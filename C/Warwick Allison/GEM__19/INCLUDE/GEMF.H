/////////////////////////////////////////////////////////////////////////////
//
//  GEMform
//
//  A GEMform interacts with the user through a GEM form (or dialog).
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMf_h
#define GEMf_h

#include <gemfb.h>
#include <gemrawo.h>
#include <bool.h>

class GEMobject;
class GEMrsc;
class GEMevent;
class GRect;

class GEMform
{
public:
	GEMform(const GEMrsc& in, int RSCindex);
	GEMform(const GEMform&);
	virtual ~GEMform();

	int Do(); // Centred
	virtual int Do(int x, int y);

	bool Zooms(bool b);
	bool Flight(bool b);
	void Fly(bool opaque=TRUE);

	virtual void RedrawObject(int RSCindex);
	virtual void RedrawObject(int RSCindex,int Cx,int Cy,int Cw,int Ch); // Clipped
	void RedrawObjectFromRoot(int RSCindex);

	int Parent(int RSCindex) const;

	// See GEMrawobject for conversion function to GEMobject*
	GEMrawobject& Object(int RSCindex) const { return Obj[RSCindex]; }
	GEMrawobject& operator[](int RSCindex) const { return Object(RSCindex); }

	virtual void AlignObject(int RSCindex, int xmult=8, int ymult=1);

	const int SearchDown=-1;
	const int SkipSubtree=-2;

	int Map(int Do(GEMrawobject*, int), bool skiphidden=TRUE, int RSCfrom=0, int RSCto=-1);

	virtual GEMfeedback DoItem(int item, const GEMevent& e);

	int Index() const { return myindex; }

	virtual bool IsOpen();

	// Should always be called to completion.
	// GRects invalid afer next call.
	virtual GRect* FirstClip(int RSCobject);
	virtual GRect* NextClip(GRect* prev);

private:
	int myindex;
	void* flybuffer;
	int vdihandle;
	int open;

protected:
	bool ZoomOn;
	bool flight;
	GEMrawobject *Obj;
	virtual int FormDo();
	int xoffset,yoffset,xmult,ymult;
};
inline	bool GEMform::Zooms(bool b)	{ bool t=b; ZoomOn=b; return t; }

#endif
