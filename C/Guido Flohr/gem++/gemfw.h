/////////////////////////////////////////////////////////////////////////////
//
//  GEMformwindow
//
//  A GEMformwindow is a GEMwindow with a GEMform as its contents.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMfw_h
#define GEMfw_h

#include <gemfast.h>

#ifdef _LIBGEMPP
#include "gemfb.h"
#include "gemf.h"
#include "gemw.h"
#include "bool.h"
#include "aesext.h"
#else
#include <gemfb.h>
#include <gemf.h>
#include <gemw.h>
#include <bool.h>
#include <aesext.h>
#endif

class GEMformwindow : public GEMwindow, public GEMform
{
public:
	GEMformwindow(GEMactivity& in, const GEMrsc& in, int RSCindex);
	GEMformwindow(GEMactivity& in, const GEMrsc& in, int RSCindex, int Parts);
	GEMformwindow(const GEMformwindow&);

	virtual void Top(const GEMevent&);
	virtual GEMfeedback Click(const GEMevent&);
	virtual void RedrawObject(int RSCindex);
	virtual void RedrawObject(int RSCindex,int Cx,int Cy,int Cw,int Ch); // Clipped

	virtual void AlignObject(int RSCindex, int xmult=8, int ymult=1);

	virtual bool IsOpen() const;

	bool RubberWidth();
	bool RubberHeight();
	void RubberWidth(bool yes);
	void RubberHeight(bool yes);
	void Rubber(bool yes);

	virtual GRect* FirstClip(int RSCobject);
	virtual GRect* NextClip(GRect* prev);

	virtual int VLineAmount();
	virtual int HColumnAmount();

	virtual int ClipTrackingRectangle(int x, int y, GRect&);
	virtual void MousePosition(const GEMevent&);
	virtual void MousePositionOff();
	virtual void ObjectTouched(int RSCindex);

	virtual void InFocus(bool yes);
	virtual GEMfeedback Key(const GEMevent&);

	void Edit(int object, int index);

protected:
	virtual bool ScrollByBlitting() const;
	virtual void SetWorkRect( const GRect& );
	virtual void HFlushSlider();
	virtual void VFlushSlider();
	virtual void Redraw(const GRect&);

private:
	bool rubberwidth,rubberheight;
	int touched_object;
	int edit_object;
};

#endif
