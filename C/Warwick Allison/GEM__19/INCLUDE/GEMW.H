/////////////////////////////////////////////////////////////////////////////
//
//  GEMwindow
//
//  A GEMwindow is a standard GEM window, which acts just like that as
//  a base class.  Its contents is undefined, and redraw requests have
//  no effect - derived classes should implement this.  It does, however,
//  handle the requirement of clipping the redraw area - a standard
//  requirement of GEM windows.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMw_h
#define GEMw_h

#include <gemfb.h>
#include <gempa.h>
#include <grect.h>
#include <gemfast.h>
#include <bool.h>

class GEMactivity;
class GEMevent;

class GEMwindow : public GEMpanarea
{
public:
	GEMwindow(GEMactivity& in, int Parts);
	GEMwindow(GEMactivity& in, int Parts, const GRect&);
	GEMwindow(GEMactivity& in, int Parts, const GRect& actWorkArea, const GRect& maxWorkArea);
	GEMwindow(const GEMwindow&);

	virtual ~GEMwindow();

	// some GEM like open and close functions
	virtual bool Create();
	virtual void Open();
	virtual void Close();
	virtual void Delete();

	// Accessory windows are closed "automatically".  Groan.  An accessory
	// should call this method for all windows on an AC_CLOSE message.
	virtual void BecomeDeleted();

	// discriminators and inquiring functions
	virtual bool  IsOpen() const;
	bool  IsCreated() const		{ return created;		}
	GRect BorderRect() const	{ return Work2Win(Pos);	}
	GRect WorkRect() const		{ return Pos;			}

	// routines performing actions
	virtual void Top(const GEMevent&);
	virtual void Bottom(const GEMevent&);
	virtual void Move(int X, int Y);
	virtual void Resize(int w, int h);	// it's the border size
	virtual GEMfeedback Click(const GEMevent&);

	// Top attempted by clicking at (x,y) - returns TRUE if actually topped.
	// (rather than simply using the click)


	void RedrawOverlaps(const GRect&); // Calls Redraw

	int Handle() const { return handle; }

	void Align(int x, int y, int xmult=8, int ymult=1);
	// Movement will align such that (x,y) is a multiple of (xmult,ymult).

	virtual GEMfeedback UserClosed();
	virtual void UserFulled();
	virtual void UserResized(int w,int h);
	virtual void UserMoved(int x, int y);
	
	// methods for the vertical slider
	virtual void VSlidered(int newPos);
	
	// methods for the horizontal slider
	virtual void HSlidered(int newPos);

	// Info-line
	char *InfoText() const	{ return info;	}
	void SetInfoText(const char *);

	// Name (title)
	void SetName(const char *);
	const char *Name() const { return name;	}

	// Flush slider
	virtual void Flush();

	// the Set* members flush their changes !
	void SetVisibleLines(int noOfLines);
	void SetTotalLines(int noOfLines);
	void SetTopLine(int noOfLine);
	void SetVisibleColumns(int noOfColumns);
	void SetTotalColumns(int noOfColumns);
	void SetLeftColumn(int noOfColumn);

	// Document units -> pixels
	void LineHeight(int i) { lineHeight=i; }
	void ColumnWidth(int i) { columnWidth=i; }
	int LineHeight() { return lineHeight; }
	int ColumnWidth() { return columnWidth; }

	// NB: "colour" is not strictly correct - see manual.
	void SetPartColour(int part, short activecolour, short inactivecolour);
	void DefaultPartColour(int part);

	// The GEMform MUST be of a special kind - see manual.
	void SetPartColours(class GEMform& active, class GEMform& inactive);
	void DefaultPartColours();

	short PartColour(int part, bool activecolour) const;

	int ButtonEventFlags(int flags);

protected:
	int	parts;
	bool initialized;
	// characteristic rectangles, representing the work area
	GRect Pos, Max; // Current and Full sizes

	// convert functions using the 'parts' member
	GRect Win2Work(const GRect& outer) const;
	GRect Work2Win(const GRect& work) const;

	virtual void Redraw(const GRect&);

	void SetBorderRect(const GRect&);
	virtual void SetWorkRect(const GRect&);

	virtual bool ScrollByBlitting() const=0;

	void VCalculateGEMvalues();
	void VCalculateValues();
	virtual void VFlushSlider();
	void HCalculateGEMvalues();
	void HCalculateValues();
	virtual void HFlushSlider();

private:
	char *info;
	GRect	storer;			// stores last actual size and pos. 
	char *name;
	int handle;
		
	bool opened, created;
	GEMactivity* act;
	int xoff,yoff,xalign,yalign;
	short bevent;

	// parameters representing the real GEM slider
	int	vSize,
		vPosition;
	int	hSize,
		hPosition;

	// pixel size of document units
	int lineHeight,columnWidth;

	void InActivity(GEMactivity& in);

	class GEMwPartCol* partcol;
};


#endif
