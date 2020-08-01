/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include "gemsl.h"
#include "gemf.h"
#include "geme.h"
#include "contract.h"
#include <aesbind.h>
#include <minmax.h>

const int PAGE_DELAY=250;
const int LINE_DELAY=50;


class SL_Knob : public GEMobject
{
public:
	SL_Knob(GEMform& f, int RSCindex, GEMslider& tell) :
		GEMobject(f, RSCindex),
		Tell(tell)
	{ }

	virtual GEMfeedback Touch(int x, int y, const GEMevent&)
	{
		int tx,ty;

		Tell.GetAbsoluteXY(tx,ty);

		int ox,oy,nx,ny;
		ox=tx+X();
		oy=ty+Y();

		graf_dragbox(Width(),Height(),ox,oy,
			tx,ty,Tell.Width(),Tell.Height(),&nx,&ny);

		if (ox!=nx || oy!=ny) {
			MoveTo(nx-tx,ny-ty);
			Tell.GEMtoDOC();
			if (ox!=nx) Tell.HFlush();
			if (oy!=ny) Tell.VFlush();
		}

		return ContinueInteraction;
	}

private:
	GEMslider& Tell;
};

static void Untouch(int timeout)
{
	GEMevent event;
	if (event.Button()) {
		event.Interval(timeout); // Wait for timeout
		event.Button(1,0); // or leftbutton release
		event.Get(MU_TIMER|MU_BUTTON);
	}
}


class SL_Left : public GEMobject
{
public:
	SL_Left(GEMform& f, int RSCindex, GEMslider& tell) :
		GEMobject(f, RSCindex),
		Tell(tell)
	{ }

	virtual GEMfeedback Touch(int x, int y, const GEMevent&)
	{
		Tell.ColumnLeft();
		Tell.HFlush();
		Untouch(Tell.LineDelay(-1));
		return ContinueInteraction;
	}

private:
	GEMslider& Tell;
};


class SL_Right : public GEMobject
{
public:
	SL_Right(GEMform& f, int RSCindex, GEMslider& tell) :
		GEMobject(f, RSCindex),
		Tell(tell)
	{ }

	virtual GEMfeedback Touch(int x, int y, const GEMevent&)
	{
		Tell.ColumnRight();
		Tell.HFlush();
		Untouch(Tell.LineDelay(-1));
		return ContinueInteraction;
	}

private:
	GEMslider& Tell;
};


class SL_Up : public GEMobject
{
public:
	SL_Up(GEMform& f, int RSCindex, GEMslider& tell) :
		GEMobject(f, RSCindex),
		Tell(tell)
	{ }

	virtual GEMfeedback Touch(int x, int y, const GEMevent&)
	{
		Tell.LineUp();
		Tell.VFlush();
		Untouch(Tell.LineDelay(-1));
		return ContinueInteraction;
	}

private:
	GEMslider& Tell;
};


class SL_Down : public GEMobject
{
public:
	SL_Down(GEMform& f, int RSCindex, GEMslider& tell) :
		GEMobject(f, RSCindex),
		Tell(tell)
	{ }

	virtual GEMfeedback Touch(int x, int y, const GEMevent&)
	{
		Tell.LineDown();
		Tell.VFlush();
		Untouch(Tell.LineDelay(-1));
		return ContinueInteraction;
	}

private:
	GEMslider& Tell;
};



GEMslider::GEMslider(GEMform& f, int RSCknob, int RSCrack) :
	GEMobject(f,RSCrack),
	GEMpanarea(f[RSCknob].Height(),Height(),f[RSCknob].Width(),Width()),
	K(new SL_Knob(f,RSCknob,*this)),
	U(0),D(0),L(0),R(0),
	page_delay(PAGE_DELAY), line_delay(LINE_DELAY)
{
	GEMtoDOC();
}

GEMslider::GEMslider(GEMform& f, int RSCknob, int RSCrack, int RSCminus, int RSCplus) :
	GEMobject(f,RSCrack),
	GEMpanarea(f[RSCknob].Height(),Height(),f[RSCknob].Width(),Width()),
	K(new SL_Knob(f,RSCknob,*this)),
	U(0),D(0),L(0),R(0),
	page_delay(PAGE_DELAY), line_delay(LINE_DELAY)
{
	GEMtoDOC();
	if (Width()-K->Width() > Height()-K->Height()) {
		// Horizontal
		L=new SL_Left(f,RSCminus,*this);
		R=new SL_Right(f,RSCplus,*this);
	} else {
		// Vertical
		U=new SL_Up(f,RSCminus,*this);
		D=new SL_Down(f,RSCplus,*this);
	}
}

GEMslider::GEMslider(GEMform& f, int RSCknob, int RSCrack,
		int RSChminus, int RSChplus,
		int RSCvminus, int RSCvplus) :
	GEMobject(f,RSCrack),
	GEMpanarea(f[RSCknob].Height(),Height(),f[RSCknob].Width(),Width()),
	K(new SL_Knob(f,RSCknob,*this)),
	L(new SL_Left(f,RSChminus,*this)),
	R(new SL_Right(f,RSChplus,*this)),
	U(new SL_Up(f,RSCvminus,*this)),
	D(new SL_Down(f,RSCvplus,*this)),
	page_delay(PAGE_DELAY), line_delay(LINE_DELAY)
{
	GEMtoDOC();
}

GEMslider::~GEMslider()
{
	delete K;
	if (U) delete U;
	if (D) delete D;
	if (L) delete L;
	if (R) delete R;
}

GEMfeedback GEMslider::Touch(int x, int y, const GEMevent&)
{
	if (x<K->X()) {
		PageLeft();
		HFlush();
	} else if (x>=K->X()+K->Width()) {
		PageRight();
		HFlush();
	}
	if (y<K->Y()) {
		PageUp();
		VFlush();
	} else if (y>=K->Y()+K->Height()) {
		PageDown();
		VFlush();
	}
	Untouch(page_delay);
	return ContinueInteraction;
}

void GEMslider::GEMtoDOC()
{
	SetTopLine(Height() > K->Height()
		? K->Y()*(TotalLines()-VisibleLines())/(Height()-K->Height())
		: 0
	);

	SetLeftColumn(Width() > K->Width()
		? K->X()*(TotalColumns()-VisibleColumns())/(Width()-K->Width())
		: 0
	);
}

void GEMslider::VFlush()
{
	int y,h;
	VGetScaledValue(Height(),h,y);
	K->SetHeight(h);
	K->MoveTo(K->X(),y);
	Redraw();
}

void GEMslider::HFlush()
{
	int x,w;
	HGetScaledValue(Width(),w,x);
	K->SetWidth(w);
	K->MoveTo(x,K->Y());
	Redraw();
}

void GEMslider::SetVisibleLines(int noOfLines)
{
	GEMpanarea::SetVisibleLines(noOfLines);
	//VFlush();
}

void GEMslider::SetTotalLines(int noOfLines)
{
	GEMpanarea::SetTotalLines(noOfLines);
	//VFlush();
}

void GEMslider::SetTopLine(int noOfLine)
{
	GEMpanarea::SetTopLine(noOfLine);
	//VFlush();
}

void GEMslider::SetVisibleColumns(int noOfColumns)
{
	GEMpanarea::SetVisibleColumns(noOfColumns);
	//HFlush();
}

void GEMslider::SetTotalColumns(int noOfColumns)
{
	GEMpanarea::SetTotalColumns(noOfColumns);
	//HFlush();
}

void GEMslider::SetLeftColumn(int noOfColumn)
{
	GEMpanarea::SetLeftColumn(noOfColumn);
	//HFlush();
}

int GEMslider::LineDelay(int ms)
{
	int r=line_delay;
	if (ms>=0) line_delay=ms;
	return r;
}

int GEMslider::PageDelay(int ms)
{
	int r=page_delay;
	if (ms>=0) page_delay=ms;
	return r;
}
