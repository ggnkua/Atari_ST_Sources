/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
//  (Extensions made in 1992 by Andre Pareis.)
//
/////////////////////////////////////////////////////////////////////////////

#include <aesbind.h>
#include <bool.h>
#include "gema.h"
#include "gemw.h"
#include "gemf.h"
#include "vdi.h"
#include "contract.h"

#ifndef WF_BEVENT
#define WF_BEVENT 24
#endif

#ifndef WF_BOTTOM
#define WF_BOTTOM 25
#endif

static int abs(int i)
{
	return i<0 ? -i : i;
}

// Defining STOP_WINX prevents windows from moving off the left edge
// of the screen (The WINX extensions allow this in GEM).
// #define STOP_WINX

extern "C" { int __aes__(unsigned long coded_control); }

void wind_get_dcol(int part, int* w1, int* w2)
// Since gemlib doesn't support it.
{
	_intin[0]=0;
	_intin[1]=WF_DCOLOR;
	_intin[2]=part;

	__aes__(0x68030400);

	*w1 = _intout[2];
	*w2 = _intout[3];
}

// Maximum number of colour that we will remember.
// There are only 19 possible ones (... currently).
const int MAXPARTCOL=18;

// Colours of parts are stored in these records.
class GEMwPartCol {
public:
	short active_col, inactive_col;
};


////////////////////////////////////////
//	constructors, destructor
////////////////////////////////////////

GEMwindow::GEMwindow(GEMactivity& in, int Parts) :
	parts(Parts),
	xoff(0), yoff(0),
	opened(FALSE), created(FALSE), initialized(FALSE),
	xalign(1), yalign(1),
	act(0),
	partcol(0),
	bevent(0)
{
	Pos = Max = GRect(0, 0, 0, 0);
	*(info = new char[1]) = 0;	// create an empty string
	*(name = new char[1]) = 0;		// create an empty name

	lineHeight = 1;
	columnWidth = 1;

	if (parts<0) {
		handle = 0;
		Create();
	}

	InActivity(in);
}


GEMwindow::GEMwindow(GEMactivity& in, int Parts, const GRect& actWorkArea, const GRect& maxWorkArea) :
	parts(Parts),
	Pos(actWorkArea), Max(maxWorkArea), handle(0),
	opened(FALSE), created(FALSE), initialized(TRUE),
	xoff(0), yoff(0),
	xalign(1), yalign(1),
	act(0),
	partcol(0),
	bevent(0)
{
	*(info = new char[1]) = 0;	// create an empty string
	*(name = new char[1]) = 0;		// create an empty name

	lineHeight = 1;
	columnWidth = 1;

	if (parts<0) {
		handle = 0;
		Create();
	}

	InActivity(in);
}


GEMwindow::GEMwindow(GEMactivity& in, int Parts, const GRect& workArea) :
	parts(Parts),
	Pos(workArea), Max(workArea), handle(0),
	opened(FALSE), created(FALSE), initialized(TRUE),
	xoff(0), yoff(0),
	xalign(1), yalign(1),
	act(0),
	partcol(0),
	bevent(0)
{
	*(info = new char[1]) = 0;	// create an empty string
	*(name = new char[1]) = 0;		// create an empty name

	lineHeight = 1;
	columnWidth = 1;

	if (parts<0) {
		handle = 0;
		Create();
	}

	InActivity(in);
}

GEMwindow::GEMwindow(const GEMwindow& copy) :
	parts(copy.parts), Pos(copy.Pos), Max(copy.Max),
	handle(0), opened(FALSE), created(FALSE),
	initialized(copy.initialized),
	xoff(copy.xoff), yoff(copy.yoff),
	xalign(copy.xalign), yalign(copy.yalign),
	info(strdup(copy.info)),
	name(strdup(copy.name)),
	act(0),
	storer(copy.storer),
	vSize(copy.vSize), vPosition(copy.vSize),
	hSize(copy.vSize), hPosition(copy.vSize),
	lineHeight(copy.lineHeight),
	columnWidth(copy.columnWidth),
	partcol(0),
	bevent(copy.bevent)
{
	if (copy.partcol) {
		for (int i=0; i<=MAXPARTCOL; i++) {
			if (copy.partcol[i].active_col!=-1 || copy.partcol[i].inactive_col!=-1)
				SetPartColour(i,
					copy.partcol[i].active_col,
					copy.partcol[i].inactive_col);
		}
	}

	GRect win=BorderRect();
	win.g_x+=10;
	win.g_y+=10;
	Move(win.g_x,win.g_y);

	// If the original window was in an activity, put this one in there too.
	if (copy.act) InActivity(*copy.act);
}

GEMwindow::~GEMwindow()
{
	if (act) act->RemoveWindow(*this);

	if (IsOpen())
		Close();

	if (IsCreated())
		Delete();
	
	delete info;
	delete name;
	delete [] partcol;

	Ensure(!IsCreated());
}


void GEMwindow::RedrawOverlaps(const GRect& area)
// Standard algorithm found in all GEM code... that's why we have classes!
{
	GRect box,
		dirty_dest,
		work_area = WorkRect();

	wind_update(BEG_UPDATE);
	graf_mouse(M_OFF, 0);

	wind_get(handle, WF_FIRSTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h);

	while (box.g_w && box.g_h)
	{
		if (rc_intersect(&(GRect&)area, &box))
		{
			rc_copy(&box, &dirty_dest);
			
			if (rc_intersect(&work_area, &dirty_dest))
				Redraw(dirty_dest);
		}
		wind_get(handle, WF_NEXTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h);
	}
	
	graf_mouse(M_ON, 0);
	wind_update(END_UPDATE);
}


////////////////////////////////////////////////////////////////////////
//
// SPC:	Redraw(GRect& area)
//	-- this method should be redefined in client classes
//
////////////////////////////////////////////////////////////////////////

void GEMwindow::Redraw(const GRect& area)
{
	// clients should clip the 'area' and draw the window contents
}

void GEMwindow::Open()
{
	if (!IsOpen()) {
		Create();
		if (!IsCreated()) return;

		VFlushSlider();
		HFlushSlider();
		wind_set(handle, WF_NAME, name, 0, 0);
		wind_set(handle, WF_INFO, info, 0, 0);

		GRect	win = BorderRect();

		wind_open(handle, win.g_x, win.g_y, win.g_w, win.g_h);
		opened = TRUE;
	} else {
		wind_set(handle, WF_TOP);
	}

	if (act) act->Topped(*this);

	Ensure(IsOpen());
}

void GEMwindow::Close()
{
	if (IsOpen() && handle) {
		wind_close(handle);
		opened = FALSE;
		act->Bottomed(*this);
		Delete();
	}
}


////////////////////////////////////////////////////////////////////////
//
// SPC:	move(int x, int y)
//	-- Move() moves the window to the upper left point (x, y) and
//	-- performs the move at screen if the window is opened
//
////////////////////////////////////////////////////////////////////////

void GEMwindow::Move(int x, int y)
{
	GRect	win = BorderRect();
	GRect	root;

	win.MoveAbs((x+xoff+xalign/2)/xalign*xalign-xoff,
		(y+yoff+yalign/2)/yalign*yalign-yoff);
	
	wind_get(0, WF_WORKXYWH, &root.g_x, &root.g_y, &root.g_w, &root.g_h);

#ifdef STOP_WINX
	if (win.g_x < root.g_x)
		win.g_x = root.g_x;
	if (win.g_y < root.g_y)
		win.g_y = root.g_y;
#endif

	SetBorderRect(win);
}

void GEMwindow::Top(const GEMevent&)
{
	if (handle && IsOpen()) {
		wind_set(handle, WF_TOP);
		act->Topped(*this);
	}
}

void GEMwindow::Bottom(const GEMevent&)
{
	if (handle && IsOpen()) {
		wind_set(handle, WF_BOTTOM);
		act->Bottomed(*this);
	}
}

GEMfeedback GEMwindow::Click(const GEMevent&)
{
	return ContinueInteraction;
}


void GEMwindow::Align(int x, int y, int xmult=8, int ymult=1)
{
	xoff=x;
	yoff=y;

	// Ignore 0 multiples!
	if (xmult) xalign=xmult;
	if (ymult) yalign=ymult;
}

void GEMwindow::InActivity(GEMactivity& in)
{
	in.AddWindow(*this);
	act=&in;
}


////////////////////////////////////////////////////////////////////////
//
//	Here are the extensions added by A.Pareis, and subsequently greatly
//  edited by Warwick.
//
////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////
//
// SPC:	Create()
//	-- Create() creates the real window how GEM knows it;
//	-- the returned value signals the success of the operation
//
////////////////////////////////////////////////////////////////////////

bool GEMwindow::Create()
{
	Require(!IsCreated());
	if (IsCreated()) return FALSE;
	
	GRect win;
	
	if (!initialized) {
		// i.e., no rectangles given
		wind_get(0, WF_WORKXYWH, &win.g_x, &win.g_y, &win.g_w, &win.g_h);
		Pos = Max = Win2Work(win);
		initialized = TRUE;
	} else
		win = BorderRect();

	if (parts<0) {
		handle=0; // ie. Desktop
		parts=0;
	} else {
		handle = wind_create(parts, win.g_x, win.g_y, win.g_w, win.g_h);
	}
	
	if (handle>=0) {
		// if succesfully created
		created = TRUE;
		if (partcol) {
			for (int i=0; i<=MAXPARTCOL; i++) {
				if (partcol[i].active_col!=-1 || partcol[i].inactive_col!=-1)
					wind_set(handle,WF_COLOR,i,partcol[i].active_col,partcol[i].inactive_col,0);
			}
		}
		wind_set(handle,WF_BEVENT,bevent,0,0,0);
	}
	
	return created;
}




////////////////////////////////////////////////////////////////////////
//
// SPC:	Delete()
//	-- delete the real GEM window, but not the instance of this class
//	-- if the window is opened, close it first
//
////////////////////////////////////////////////////////////////////////

void GEMwindow::Delete()
{
	if (IsCreated()) {
		if (IsOpen())
			Close();

		if (handle) wind_delete(handle);
		created = FALSE;
	
		Ensure(!IsCreated());
	}
}





////////////////////////////////////////////////////////////////////////
//
// SPC:	BecomeDeleted()
//
////////////////////////////////////////////////////////////////////////

void GEMwindow::BecomeDeleted()
{
	if (IsCreated()) {
		opened = FALSE;
		created = FALSE;
	
		Ensure(!IsCreated());
	}
}





////////////////////////////////////////////////////////////////////////
//
// SPC:	SetBorderRect(GRect& newPos)
//	-- the window may be moved and resized, if it is opened, the
//	-- action will be performed at screen, too
//
////////////////////////////////////////////////////////////////////////

void GEMwindow::SetBorderRect(const GRect& newPos)
{
	SetWorkRect(Win2Work(newPos));
}



void GEMwindow::SetWorkRect(const GRect& newPos)
{
	Pos = newPos;

	if (parts&HSLIDE && Pos.g_w/columnWidth > TotalColumns())
		Pos.g_w=columnWidth * TotalColumns();

	if (parts&VSLIDE && Pos.g_h/lineHeight > TotalLines())
		Pos.g_h=lineHeight * TotalLines();

	// Round size down to nearest document unit
	Pos.g_w-=Pos.g_w%columnWidth;
	Pos.g_h-=Pos.g_h%lineHeight;

	GRect win = BorderRect();

	if (IsOpen() && handle)
		wind_set(handle, WF_CURRXYWH, win.g_x, win.g_y, win.g_w, win.g_h);

	if (parts&HSLIDE && Pos.g_w/columnWidth != VisibleColumns())
		SetVisibleColumns(Pos.g_w/columnWidth);

	if (parts&VSLIDE && Pos.g_h/lineHeight != VisibleLines())
		SetVisibleLines(Pos.g_h/lineHeight);
}






////////////////////////////////////////////////////////////////////////
//
// SPC:	Resize(int w, int h)
//
////////////////////////////////////////////////////////////////////////

void GEMwindow::Resize(int w, int h)
{
	GRect	win = BorderRect();
	
	win.Resize(w, h);

	SetBorderRect(win);
}






GRect GEMwindow::Win2Work(const GRect& outer) const
{
	GRect	tmp;
	
	wind_calc(WC_WORK, parts < 0 ? 0 : parts, outer.g_x, outer.g_y, outer.g_w, outer.g_h,
			&tmp.g_x, &tmp.g_y, &tmp.g_w, &tmp.g_h);
	
	return tmp;
}


GRect GEMwindow::Work2Win(const GRect& work) const
{
	GRect	tmp;
	
	wind_calc(WC_BORDER, parts < 0 ? 0 : parts, work.g_x, work.g_y, work.g_w, work.g_h,
			&tmp.g_x, &tmp.g_y, &tmp.g_w, &tmp.g_h);
	
	return tmp;
}


////////////////////////////////////////////////////////////////////////
//
// SPC:	SetInfoText(const char *line)
//	-- store and set the new info line for the window
//	-- this _must_! be at least created
//
////////////////////////////////////////////////////////////////////////

void GEMwindow::SetInfoText(const char *line)
{
	if (handle) {
		delete info;
		info = new char[ strlen(line)+1 ];
		info = strcpy(info, line);
		if (IsCreated()) wind_set(handle, WF_INFO, info, 0, 0);

		Ensure(strcmp(info, line)==0);
	}
}







GEMfeedback GEMwindow::UserClosed()
{
	Close();
	return ContinueInteraction;
}


////////////////////////////////////////////////////////////////////////
//
// SPC:	UserFulled()
//	-- usually called by an application manager, the default action
//	-- is to toggle between two possible positions and sizes
//
////////////////////////////////////////////////////////////////////////

void GEMwindow::UserFulled()
{
	Require(IsOpen());
	if (!IsOpen()) return;
	
	if (Max==WorkRect())			// i.e., is fulled
		SetWorkRect(storer);		// use stored value
	else
	{
		storer = WorkRect();		// store actual rectangle
		SetWorkRect(Max);
	}
}




////////////////////////////////////////////////////////////////////////
//
// SPC:	UserResized(int w, int h)
//	-- this function may be redefined to align the new size, but
//	-- here it does nothing else than to call the standard Resize()
//	-- of a simple GEMwindow with the same values
//
////////////////////////////////////////////////////////////////////////

void GEMwindow::UserResized(int w, int h)
{
	Resize(w, h);
}

void GEMwindow::UserMoved(int x, int y)
{
	Move(x, y);
}


void GEMwindow::SetName(const char *newName)
{	
	delete name;
	name = new char[ strlen(newName)+1 ];
	name = strcpy(name, newName);
	if (IsCreated())
		wind_set(handle, WF_NAME, name, 0, 0);
}


////////////////////////////////////////////////////////////////////////
//
// SPC:	Flush()
//	-- this method will be called, if the user changed the state
//	-- of a slider, e.g., by moving it; descendant classes may
//	-- refine it, with the aim of a more efficient implementation
//
////////////////////////////////////////////////////////////////////////

void GEMwindow::Flush()
{
	if (IsOpen())
		RedrawOverlaps(WorkRect());
}


////////////////////////////////////////////////////////////////////////
//
// SPC:	SetVisibleLines(int noOfLines)
//	-- change the number of visible lines, this change will be
//	-- flushed through to the GEM window
//
////////////////////////////////////////////////////////////////////////

void GEMwindow::SetVisibleLines(int noOfLines)
{
	GEMpanarea::SetVisibleLines(noOfLines);

	VFlushSlider();
}


void GEMwindow::SetTotalLines(int noOfLines)
{
	if (noOfLines!=TotalLines()) {
		GEMpanarea::SetTotalLines(noOfLines);

		VFlushSlider();

		Flush();
	}
}

void GEMwindow::SetTopLine(int noOfLine)
{
	int prev_topline=TopLine();

	GEMpanarea::SetTopLine(noOfLine);

	if (TopLine()!=prev_topline) {
		VFlushSlider();

		if (abs(noOfLine-prev_topline) < VisibleLines() && ScrollByBlitting()) {
			int pixels_down=(noOfLine-prev_topline)*LineHeight();

			GRect box,
				clip,
				work_area = WorkRect();

			wind_update(BEG_UPDATE);
			graf_mouse(M_OFF, 0);
			VDI vdi;

			wind_get(handle, WF_FIRSTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h);

			while (box.g_w && box.g_h)
			{
				rc_copy(&box, &clip);
				
				if (rc_intersect(&work_area, &clip)) {
					if (clip.g_h > abs(pixels_down)) {
						int pxy[8];

						pxy[0]=clip.g_x;
						pxy[2]=clip.g_x+clip.g_w-1;
						pxy[4]=clip.g_x;
						pxy[6]=clip.g_x+clip.g_w-1;

						if (pixels_down>0) {
							pxy[1]=clip.g_y+pixels_down;
							pxy[3]=clip.g_y+clip.g_h-1;
							pxy[5]=clip.g_y;
							pxy[7]=clip.g_y+clip.g_h-pixels_down-1;
						} else {
							pxy[1]=clip.g_y;
							pxy[3]=clip.g_y+clip.g_h+pixels_down-1;
							pxy[5]=clip.g_y-pixels_down;
							pxy[7]=clip.g_y+clip.g_h-1;
						}

						vdi.ro_cpyfm(VDI::SRC,pxy);
					}

					if (pixels_down>0) {
						GRect redraw_side(clip.g_x,clip.g_y+clip.g_h-pixels_down,
							clip.g_w,pixels_down);
						if (rc_intersect(&work_area,&redraw_side))
							Redraw(redraw_side);
					} else {
						GRect redraw_side(clip.g_x,clip.g_y,clip.g_w,-pixels_down);
						if (rc_intersect(&work_area,&redraw_side))
							Redraw(redraw_side);
					}
				}

				wind_get(handle, WF_NEXTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h);
			}
		
			graf_mouse(M_ON, 0);
			wind_update(END_UPDATE);
		} else {
			Flush();
		}
	}
}




////////////////////////////////////////////////////////////////////////
//
// SPC:	VCalculateGEMvalues() and CalculateValues():
//	-- use the members totalLines, visibleLines and
//	-- actualTopLine to calculate the size and position of the GEM
//	-- slider and vice versa;
//
////////////////////////////////////////////////////////////////////////

void GEMwindow::VCalculateGEMvalues()
{
	if (TotalLines() > 0) {
		vSize = 1000 * VisibleLines() / TotalLines();

		if (TotalLines() == VisibleLines())
			vPosition = 1;
		else
			vPosition = TopLine() * 1000 /
				(TotalLines()-VisibleLines());
    }
}




////////////////////////////////////////////////////////////////////////
//
// SPC: VCalculateValues()
//	-- that method converts the GEM representation of the slider
//	-- into the document representation
//
////////////////////////////////////////////////////////////////////////

void GEMwindow::VCalculateValues()
{
	SetTopLine(vPosition*(TotalLines()-VisibleLines())/1000);
}






////////////////////////////////////////////////////////////////////////
//
// SPC:	VFlushSlider()
//	-- is the counterpart of Flush(),
//	-- and is used to flush any changes in the internal slider
//	-- representation through to GEM; it doesn't need to be redefined
//
////////////////////////////////////////////////////////////////////////

void GEMwindow::VFlushSlider()
{
	if (handle) {
		VCalculateGEMvalues();			// ensures correctness
	
		if (IsCreated()) {
			wind_set(handle, WF_VSLIDE, vPosition, 0, 0, 0);
			wind_set(handle, WF_VSLSIZE, vSize, 0, 0, 0);
		}
	}
}








////////////////////////////////////////////////////////////////////////
//
// SPC:	VSlidered(int newPos)
//	-- this function is called by the application manager, if
//	-- the user has moved the vertical slide box to a new position;
//	-- the default action performed by it is to store the new value,
//	-- then to call VCalculateValues(), and then to return
//	-- the value RedrawMe to the caller
//
////////////////////////////////////////////////////////////////////////

void GEMwindow::VSlidered(int newPos)
{
	vPosition = newPos;
	
	VCalculateValues();
}





////////////////////////////////////////////////////////////////////////
//
// SPC:	SetVisibleColumns(int noOfLines)
//	-- change the number of visible columns, this change will be
//	-- flushed through to the GEM window
//
////////////////////////////////////////////////////////////////////////

void GEMwindow::SetVisibleColumns(int noOfColumns)
{
	GEMpanarea::SetVisibleColumns(noOfColumns);
	
	HFlushSlider();
}



void GEMwindow::SetTotalColumns(int noOfColumns)
{
	if (noOfColumns!=TotalColumns()) {
		GEMpanarea::SetTotalColumns(noOfColumns);
		
		HFlushSlider();
		
		Flush();
	}
}




void GEMwindow::SetLeftColumn(int noOfColumn)
{
	int prev_leftcolumn=LeftColumn();

	GEMpanarea::SetLeftColumn(noOfColumn);

	if (LeftColumn()!=prev_leftcolumn) {
		HFlushSlider();

		if (abs(noOfColumn-prev_leftcolumn) < VisibleColumns() && ScrollByBlitting()) {
			int pixels_right=(noOfColumn-prev_leftcolumn)*ColumnWidth();

			GRect box,
				clip,
				work_area = WorkRect();

			wind_update(BEG_UPDATE);
			graf_mouse(M_OFF, 0);
			VDI vdi;

			wind_get(handle, WF_FIRSTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h);

			while (box.g_w && box.g_h)
			{
				rc_copy(&box, &clip);
				
				if (rc_intersect(&work_area, &clip)) {
					if (clip.g_w > abs(pixels_right)) {
						int pxy[8];

						if (pixels_right>0) {
							pxy[0]=clip.g_x+pixels_right;
							pxy[2]=clip.g_x+clip.g_w-1;
							pxy[4]=clip.g_x;
							pxy[6]=clip.g_x+clip.g_w-pixels_right-1;
						} else {
							pxy[0]=clip.g_x;
							pxy[2]=clip.g_x+clip.g_w+pixels_right-1;
							pxy[4]=clip.g_x-pixels_right;
							pxy[6]=clip.g_x+clip.g_w-1;
						}

						pxy[1]=clip.g_y;
						pxy[3]=clip.g_y+clip.g_h-1;
						pxy[5]=clip.g_y;
						pxy[7]=clip.g_y+clip.g_h-1;

						vdi.ro_cpyfm(VDI::SRC,pxy);
					}

					if (pixels_right>0) {
						GRect redraw_side(clip.g_x+clip.g_w-pixels_right,clip.g_y,
							pixels_right,clip.g_h);
						if (rc_intersect(&work_area,&redraw_side))
							Redraw(redraw_side);
					} else if (pixels_right) {
						GRect redraw_side(clip.g_x,clip.g_y,-pixels_right,clip.g_h);
						if (rc_intersect(&work_area,&redraw_side))
							Redraw(redraw_side);
					}
				}

				wind_get(handle, WF_NEXTXYWH, &box.g_x, &box.g_y, &box.g_w, &box.g_h);
			}
		
			graf_mouse(M_ON, 0);
			wind_update(END_UPDATE);
		} else {
			Flush();
		}
	}
}




////////////////////////////////////////////////////////////////////////
//
// SPC:	HCalculateGEMvalues() and HCalculateValues():
//	-- use the members totalColumns, visibleColumns and
//	-- actualLeftColumn to calculate the size and position of the GEM
//	-- slider and vice versa;
//
////////////////////////////////////////////////////////////////////////

void GEMwindow::HCalculateGEMvalues()
{
	if (TotalColumns() > 0) {
		hSize = 1000 * VisibleColumns() / TotalColumns();

		if (TotalColumns() == VisibleColumns())
			hPosition = 1;
		else
			hPosition = LeftColumn() * 1000 /
				(TotalColumns()-VisibleColumns());
    }
}




////////////////////////////////////////////////////////////////////////
//
// SPC: HCalculateValues()
//	-- that method converts the GEM representation of the slider
//	-- into the document representation
//
////////////////////////////////////////////////////////////////////////

void GEMwindow::HCalculateValues()
{
	SetLeftColumn(hPosition*(TotalColumns()-VisibleColumns())/1000);
}






////////////////////////////////////////////////////////////////////////
//
// SPC:	HFlushSlider()
//	-- is the counterpart of GEMwindow::Flush(),
//	-- and is used to flush any changes in the internal slider
//	-- representation through to GEM; it doesn't need to be redefined
//
////////////////////////////////////////////////////////////////////////

void GEMwindow::HFlushSlider()
{
	if (handle) {
		HCalculateGEMvalues();			// ensures correctness
	
		if (IsCreated()) {
			wind_set(handle, WF_HSLIDE, hPosition, 0, 0, 0);
			wind_set(handle, WF_HSLSIZE, hSize, 0, 0, 0);
		}
	}
}








////////////////////////////////////////////////////////////////////////
//
// SPC:	HSlidered(int newPos)
//	-- this function is called by the application manager, if
//	-- the user has moved the horizontal slide box to a new position;
//	-- the default action performed by it is to store the new value,
//	-- then to call HCalculateValues(), then to return the
//	-- value RedrawMe to the caller
//
////////////////////////////////////////////////////////////////////////

void GEMwindow::HSlidered(int newPos)
{
	hPosition = newPos;
	
	HCalculateValues();
}





bool GEMwindow::IsOpen() const
{
	return created && opened;
}


// "Colour" support.

void GEMwindow::SetPartColour(int part, short enabledcolour, short disabledcolour)
{
	Ensure(part>=0 && part<=MAXPARTCOL);

	if (!partcol) {
		partcol=new GEMwPartCol[MAXPARTCOL+1];
		for (int i=0; i<=MAXPARTCOL; i++) {
			partcol[i].active_col=-1;
			partcol[i].inactive_col=-1;
		}
	}

	if (enabledcolour!=-1) partcol[part].active_col=enabledcolour;
	if (disabledcolour!=-1) partcol[part].inactive_col=disabledcolour;

	if (IsCreated()) {
		wind_set(handle,WF_COLOR,part,
			partcol[part].active_col,
			partcol[part].inactive_col,0);
	}
}

void GEMwindow::DefaultPartColour(int part)
{
	if (partcol) {
		partcol[part].active_col=-1;
		partcol[part].inactive_col=-1;
		if (IsCreated()) {
			int w1,w2;
			wind_get_dcol(part,&w1,&w2);
			//wind_get(0,WF_DCOLOR,&part,&w1,&w2,&j);
			wind_set(handle,WF_COLOR,part,w1,w2,0);
		}
	}
}

void GEMwindow::SetPartColours(GEMform& enabled, GEMform& disabled)
{
	for (int i=0; i<=MAXPARTCOL; i++) {
		SetPartColour(i,
			enabled[i].ObjectSpecific()&0xffff,
			disabled[i].ObjectSpecific()&0xffff
		);
	}
}

void GEMwindow::DefaultPartColours()
{
	for (int i=0; i<MAXPARTCOL; i++) {
		DefaultPartColour(i);
	}
	delete [] partcol;
	partcol=0;
}

short GEMwindow::PartColour(int part, bool activecolour) const
{
	if (activecolour) {
		if (partcol && partcol[part].active_col!=-1) {
			return partcol[part].active_col;
		} else {
			int w1=0,w2;
			wind_get_dcol(part,&w1,&w2);
			//wind_get(0,WF_DCOLOR,&part,&w1,&w2,&j);
			return w1;
		}
	} else {
		if (partcol && partcol[part].inactive_col!=-1) {
			return partcol[part].inactive_col;
		} else {
			int w1,w2=0;
			wind_get_dcol(part,&w1,&w2);
			//wind_get(0,WF_DCOLOR,&part,&w1,&w2,&j);
			return w2;
		}
	}
}

int GEMwindow::ButtonEventFlags(int flags)
{
	int result=bevent;
	if (flags!=-1) bevent=flags;
	if (IsCreated()) wind_set(handle,WF_BEVENT,bevent,0,0,0);
	return result;
}
