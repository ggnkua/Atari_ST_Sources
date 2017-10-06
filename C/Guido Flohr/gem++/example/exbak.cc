/////////////////////////////////////////////////////////////////////////////
//
//  example
//
//  This file demonstrates many of the features of the gem++ library.
//
/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992 by Warwick W. Allison,
//  and is freely distributable providing no charge is made.
//
/////////////////////////////////////////////////////////////////////////////

// Include the headers of the GEM++ feature demonstrated.
//
#include "gemfiw.h"
#include "gemo.h"
#include "gemt.h"
#include "gema.h"
#include "gemr.h"
#include "gemap.h"
#include "gemto.h"
#include "gemhf.h"
#include "gemal.h"
#include "gemvo.h"
#include "gemvb.h"
#include "gemro.h"
#include "gemsl.h"
#include "gemfn.h"
#include "gemfl.h"
#include "geme.h"
#include "gemc.h"
#include "gemm.h"
#include "gemfs.h"
#include "gemd.h"
#include "gemks.h"
#include "gemrt.h"
#include "gemcha.h"

#include "example.h"
#include "scancode.h"
#include <time.h>
#include <string.h>
#include <support.h>
#include <stdlib.h>
#include <vt52.h>
//

#define FIS_HOLLOW 0
#define FIS_SOLID 1
#define FIS_PATTERN 2
#define FIS_HATCH 3
#define FIS_USER 4


//
// Demonstrates a simple derived class of GEMobject
//
// Objects of this class will become Checked when clicked upon.
//
class MenuItemToggle : public GEMobject {
public:
	MenuItemToggle(GEMform& form, int RSCindex) :
		GEMobject(form,RSCindex)
	{
	}

	GEMfeedback Touch(int x, int y, const GEMevent& e)
	{
		Checked(bool(!Checked()));
		Deselect();
		Redraw();
		return ContinueInteraction;
	}
};


static char* monthtext[12]={"JAN","FEB","MAR","APR","MAY","JUN","JUL","AUG","SEP","OCT","NOV","DEC"};

//
// Demonstrates GEMtimer and GEMhotform used for popup menus.
//
// This class encapsulates all the RSCindices required to setup
// the clock, so only of of these objects could be created, since
// they use the single graphics in the GEMrsc.  See the GEMringfiw
// below for a more complex example that allows duplicates.
//
// This class has quite a few components...
//
//  - it is a GEMformwindow with no window-parts, so it is a form
//       in a window.
//  - it is a GEMtimer, so its Expire() method is called at the intervals
//       requested with Interval().
//  - it is a GEMobject based on the GRABBER object, so its Touch() method
//       is called when the GRABBER is touched.
//  - it has two GEMtextobjects, timetext and datetext, which we can just
//       treat as if they are char*'s since they have conversion operators.
//  - it has a GEMhotform, popup, used for a pop-up menu.
//  - it has a MenuItemToggle (defined above), gmt, which is in the popup
//       menu, and which we test the Checked() state of when deciding to
//       use local or Greenwich time.
//  - it has a GEMalert, gmjoke, which makes the whole GMT thing worthwhile.
//
// The member functions are described within.
//
class Clock : public GEMformwindow, GEMtimer, GEMobject {
public:
	Clock(GEMactivity& act, const GEMrsc& rsc) :
		GEMformwindow(act,rsc,CLOCK,0),
		GEMtimer(act,0), // Initially interval==0, ie. Expire() immediately.
		GEMobject(*this,GRABBER),
		timetext(*this,TIME),
		datetext(*this,DATE),
		popup(rsc,POPUP),
		gmt(popup,GMT),
		gmjoke(rsc,GMJOKE)
	{
		strcpy(timetext,"    ");
		strcpy(datetext,"     ");
	}

private:

	// The Update() method gets the local time or Greenwich time, according
	// to whether the gmt GEMobject is Checked.  It then sets the timetext
	// and datetext strings (they are actually GEMtextobjects).  It then
	// Redraws those strings.  Update() is a local member, called by the
	// methods below it.
	//
	void Update()
	{
		time_t ti=time(0);
		tm* T;
		if (gmt.Checked())
			T=gmtime(&ti);
		else
			T=localtime(&ti);
		timetext[0]=T->tm_hour/10 ? T->tm_hour/10+'0' : ' ';
		timetext[1]=T->tm_hour%10+'0';
		timetext[2]=T->tm_min/10+'0';
		timetext[3]=T->tm_min%10+'0';
		strncpy(datetext,monthtext[T->tm_mon],3);
		datetext[3]=T->tm_mday/10 ? T->tm_mday/10+'0' : ' ';
		datetext[4]=T->tm_mday%10+'0';
		if (IsOpen()) {
			timetext.Redraw();
			datetext.Redraw();
		}
	}

protected:

	// The Expire() method overrides that inherited from GEMtimer.
	// It is called when the interval expires.  Its action it
	// to merely Update the time and wait set the interval to
	// be 60000 milliseconds.  We only need to reset the interval
	// because when we created the object, we requested the interval
	// to be 0 so that the Expire (and hence Update) would be
	// immediate.
	//
	virtual GEMfeedback Expire(const GEMevent&)
	{
		Update();
		Interval(60000); // Every minute, approx.
		return ContinueInteraction;
	}

	// The Touch() method overrides that inheritted from GEMobject.
	// It is called whenever the user touches the GRABBER object
	// on which the object was defined.
	//
	// If the touch is made using the right button (button 1), the
	// popup menu is displayed.  If the exitor of the popup is
	// the "close" menuitem, the Close() method inheritted from
	// GEMformwindow is called.  If the exitor is the smiley-face
	// icon (DOGMJOKE, that's Do-GM-joke), the gmjoke alert is
	// popped up.  If the exitor is the "quit" menuitem, EndInteraction
	// is returned, ending the GEMactivity.Do() loop.  Note that
	// the "GMT" menuitem is handled by using the Touch() method of
	// MenuItemToggle as described above.
	//
	// If the touch is not made by the right button, we employ a bit
	// of AES code (hmm, maybe that ugly stuff needs a class) to drag
	// a box the size of the BorderRect of this window, then we
	// GEMformwindow::Move this window to that dragged location.
	//
	virtual GEMfeedback Touch(int x, int y, const GEMevent& e)
	{
		if (e.Button(1)) {
			switch (popup.Do(e.X(),e.Y())) {
			 case QCLOCK:
				Close();
			break; case DOGMJOKE:
				gmjoke.Alert();
			break; case QPROG:
				return EndInteraction;
			}
			Update();
			return ContinueInteraction;
		} else {
			int bx,by,bw,bh;
			int nx,ny;
			wind_get(0,WF_WORKXYWH,&bx,&by,&bw,&bh);
			GRect w=BorderRect();
			graf_dragbox(w.g_w,w.g_h,w.g_x,w.g_y,bx,by,bw,bh,&nx,&ny);

			GEMformwindow::Move(nx,ny);

			return ContinueInteraction;
		}
	}

private:
	GEMtextobject timetext,datetext;
	GEMhotform popup;
	MenuItemToggle gmt;
	GEMalert gmjoke;
};

//
// Demonstrates GEMvdiobject
//
class GEMliney : public GEMvdiobject {
public:
	GEMliney(GEMform& form, int RSCindex, VDI& vdi) :
		GEMvdiobject(form,RSCindex,vdi)
	{
	}

protected:
	virtual void Draw(int x, int y)
		{
			int j=Width() < Height() ? Width() : Height();
			for (int i=0; i<j; i+=3) {
				vdi.line(x,y+j-i,x+i,y);
			}
		}
};

//
// Demonstrates GEMvdiobject, with special "Selected" state display.
//
class GEMellipse : public GEMvdiobject {
public:
	GEMellipse(GEMform& form, int RSCindex, VDI& vdi) :
		GEMvdiobject(form,RSCindex,vdi)
	{
	}

protected:
	virtual void Draw(int x, int y)
		{
			vdi.sf_interior(FIS_PATTERN);
			if (Selected()) vdi.sf_style(20);
			else vdi.sf_style(10);
			vdi.ellipse(x+Width()/2,y+Height()/2,Width()/2,Height()/2);
		}
};

//
// Demonstrates that GEMuserobjects (and GEMvdiobjects) retain
// the features of the object that is having its display representation
// redefined.
//
class GEMroundbutton : public GEMvdiobject {
private:
	int texth;

public:
	GEMroundbutton(GEMform& f, int RSCindex, VDI& v) :
		GEMvdiobject(f,RSCindex,v)
	{
		int j;
		graf_handle(&j,&texth,&j,&j);
	}

protected:
	virtual void Draw(int x, int y)
		{
			if (Selected()) vdi.sf_interior(1);
			else vdi.sf_interior(0);
			vdi.rfbox(x,y,x+Width()-1,y+Height()-1);
			vdi.swr_mode(MD_XOR);
			int j;
			vdi.st_alignment(1,3,&j,&j); // Centre-Bottom aligned
			vdi.gtext(x+Width()/2,y+(Height()+texth)/2-1,Text());
			vdi.swr_mode(MD_REPLACE);
		}
};


//
// Demonstrates various GEMobjects, and the GEMformiconwindow
//
class Various : public GEMformiconwindow {
public:
	Various(GEMactivity& in, const GEMrsc& rsc) :
		GEMformiconwindow(in,rsc,VARIOUS,VARIOUSI),
		picture(*this,PIC),
		panner(*this,PANKNOB,PANRACK,PANLEFT,PANRIGHT,PANUP,PANDOWN),
		vertslider(*this,VKNOB,VRACK,UP,DOWN),
		horzslider(*this,HKNOB,HRACK,LEFT,RIGHT),
		vdi(),
		ellipse(*this,ELLIPSE,vdi),
		liney(*this,LINEY,vdi),
		r1(*this,RBUT1,vdi),
		r2(*this,RBUT2,vdi)
	{
		picture.Read("example.img");
		SetName(" Various GEM++ objects ");
	}

private:
	GEMrasterobject picture;
	GEMslider panner;
	GEMslider vertslider;
	GEMslider horzslider;
	VDI vdi;
	GEMellipse ellipse;
	GEMliney liney;
	GEMroundbutton r1;
	GEMroundbutton r2;
};

//
// Demonstrates the IMG class.
//
class MicroDraw : public GEMformiconwindow {
public:
	MicroDraw(GEMactivity& in, const GEMrsc& rsc) :
		GEMformiconwindow(in,rsc,XIMG,XIMGI),
		drawbox(*this,XIMG_DRAWBOX),
		vdi(),
		colour(0),
		col0(*this,XIMG_COL0+0,vdi),
		col1(*this,XIMG_COL0+1,vdi),
		col2(*this,XIMG_COL0+2,vdi),
		col3(*this,XIMG_COL0+3,vdi),
		col4(*this,XIMG_COL0+4,vdi),
		col5(*this,XIMG_COL0+5,vdi)
	{
		col0.Colour(drawbox.Colour_BitmapToVDI(0));
		col1.Colour(drawbox.Colour_BitmapToVDI(1));
		col2.Colour(drawbox.Colour_BitmapToVDI(2));
		col3.Colour(drawbox.Colour_BitmapToVDI(3));
		col4.Colour(drawbox.Colour_BitmapToVDI(4));
		col5.Colour(drawbox.Colour_BitmapToVDI(5));

		SetColour(1);
		drawbox.Clear();
		SetName(" XIMG - Draw! ");
	}

	virtual GEMfeedback DoItem(int item, const GEMevent& e)
	{
		switch (item) {
		 case XIMG_DRAWBOX:
			int x,y;
			drawbox.GetAbsoluteXY(x,y);
			x=e.X()-x;
			y=e.Y()-y;
			if (x>0 && y>0 && x<drawbox.IMG::Width()-1 && y<drawbox.IMG::Height()-1) {
				int depth=drawbox.Depth();
				IMGcursor cursor=drawbox.Cursor(x,y);

				cursor.PutPixel(colour,depth); cursor.Right();
				cursor.PutPixel(colour,depth); cursor.Down();
				cursor.PutPixel(colour,depth); cursor.Left();
				cursor.PutPixel(colour,depth); cursor.Left();
				cursor.PutPixel(colour,depth); cursor.Up();
				cursor.PutPixel(colour,depth); cursor.Up();
				cursor.PutPixel(colour,depth); cursor.Right();
				cursor.PutPixel(colour,depth); cursor.Right();
				cursor.PutPixel(colour,depth);

				GRect changearea(x-1,y-1,3,3);
				drawbox.TranslateArea(changearea);
				RedrawObject(XIMG_DRAWBOX,x-1,y-1,3,3);
			}
		break; case XIMG_LOAD:
			Load();
		break; case XIMG_SAVE:
			Save();
		break; case XIMG_DELETE:
			drawbox.Clear();
			drawbox.Redraw();
		break; default:
			if (item>=XIMG_COL0 && item<=XIMG_COLN) {
				SetColour(item-XIMG_COL0);
			}
		}

		return ContinueInteraction;
	}

	void SetColour(int c)
	{
		Object(XIMG_COL0+colour).Checked(false);
		colour=c;
		Object(XIMG_COL0+colour).Checked(true);
		RedrawObject(XIMG_COLBOX);
	}

	void Load()
	{
		if (file.Get("Load XIMG file")) {
			IMG loaded(file.Filename());
			if (!!loaded) {
				drawbox.Copy(loaded);
			}
		}
	}

	void Save()
	{
		if (file.Get("Save XIMG file")) {
			drawbox.Write(file.Filename());
		}
	}

private:
	GEMrasterobject drawbox;
	int colour;
	VDI vdi;
	GEMvdibox col0;
	GEMvdibox col1;
	GEMvdibox col2;
	GEMvdibox col3;
	GEMvdibox col4;
	GEMvdibox col5;
	GEMfileselector file;
};


class GEMvditextobject : public GEMvdiobject {
public:
	GEMvditextobject(GEMform& f, int RSCindex, VDI& v) :
		GEMvdiobject(f,RSCindex,v)
	{
	}

	virtual void Draw(int x, int y)
	{
		// Assume vdi is all setup.
		vdi.r_recfl(x,y,x+Width()-1,y+Height()-1);
		vdi.gtext(x,y,Text());
	}
};

// A scrolling list of [selectable] text lines.
//
class ScrollingTextList : public GEMslider {
public:
	ScrollingTextList(GEMform& form, int RSCbox,
	 int RSCknob, int RSCrack, int RSCminus, int RSCplus,
	 int RSCfirstline, int RSClastline) :
		GEMslider(form,RSCknob,RSCrack,RSCminus,RSCplus),
		line0(RSCfirstline),
		lineN(RSClastline),
		linebox(RSCbox)
	{
		SetTotalLines(lineN-line0+1);
		SetVisibleLines(lineN-line0+1);
	}

	int LineToRSCindex(int line)
	{
		int RSCindex=line-TopLine()+line0;

		if (RSCindex>=line0 && RSCindex<=lineN) {
			return RSCindex;
		} else {
			return -1;
		}
	}

	int RSCindexToLine(int RSCindex)
	{
		return RSCindex-line0+TopLine();
	}

	void RedrawLine(int line)
	{
		int RSCindex=LineToRSCindex(line);

		if (RSCindex>=0) {
			form.RedrawObject(RSCindex);
		}
	}

	virtual void VFlush()
	{
		int lineindex=TopLine();

		for (int i=line0; i<=lineN; i++) {
			if (lineindex<NumberOfLines()) {
				strcpy(form[i].Text(),Line(lineindex));
				if (SelectedLine(lineindex)) {
					form[i].Select();
				} else {
					form[i].Deselect();
				}
			} else {
				strcpy(form[i].Text()," ");
				form[i].Deselect();
			}

			lineindex++;
		}

		form.RedrawObject(linebox);

		GEMslider::VFlush();
	}

protected:
	// Override these to get an actual scrolling textbox...
	virtual int NumberOfLines()=0;
	virtual char* Line(int i)=0;

	// Override this if some of the lines are to be selectable.
	virtual bool SelectedLine(int line)
	{
		return false;
	}

private:
	int line0, lineN, linebox;
};

class ScrollingFontList : public ScrollingTextList {
public:
	ScrollingFontList(GEMform& form, int RSCbox,
	 int RSCknob, int RSCrack, int RSCminus, int RSCplus,
	 int RSCfirstline, int RSClastline, VDI& v) :
		ScrollingTextList(form, RSCbox, RSCknob, RSCrack, RSCminus, RSCplus, RSCfirstline, RSClastline),
		selectedfont(0),
		fontlist(v)
	{
		SetTopLine(0);
		if (fontlist.NumberOfFonts() < VisibleLines()) {
			SetVisibleLines(fontlist.NumberOfFonts());
		}
		SetTotalLines(fontlist.NumberOfFonts());
	}

	GEMfont SelectedFont()
	{
		return fontlist.Font(selectedfont);
	}

	void LineClicked(int RSCindex)
	{
		int newselectedfont=RSCindexToLine(RSCindex);

		if (newselectedfont<fontlist.NumberOfFonts()) {
			int RSCold=LineToRSCindex(selectedfont);
			if (RSCold>=0) {
				form[RSCold].Deselect();
				form.RedrawObject(RSCold);
			}
			selectedfont=newselectedfont;
			form[RSCindex].Select();
			form.RedrawObject(RSCindex);
		}
	}

protected:
	virtual int NumberOfLines()
	{
		return fontlist.NumberOfFonts();
	}

	virtual char* Line(int i)
	{
		return fontlist.FontName(i);
	}

	virtual bool SelectedLine(int line)
	{
		return line==selectedfont;
	}

private:
	int selectedfont;
	GEMfontlist fontlist;
};

//
// Demonstrates how to use events rather than busy-waiting.
//
static void WaitForNoButton()
{
	GEMevent event;
	if (event.Button()) {
		event.Button(1,0); // wait for left button release
		event.Get(MU_BUTTON);
	}
}

//
// Demonstrates GEMfonts.
//
class FontWindow : public GEMformiconwindow {
public:
	FontWindow(GEMactivity& in, const GEMrsc& rsc) :
		GEMformiconwindow(in,rsc,FONTS,FONTSI),
		vdi(),
		fontlist(*this,FONTNAMEBOX,FONTKNOB,FONTRACK,FONTMINUS,FONTPLUS,
			FONTNAME0,FONTNAMEN,(vdi.st_load_fonts(),vdi)),
		font(vdi,fontlist.SelectedFont()),
		exampletext(*this,EXAMPLETEXT,vdi)
	{
		SetName(" Font Selection ");
		exampletext.SetText("Quick brown foxes jump over the lazy dog.");
		int j;
		vdi.st_alignment(0,5,&j,&j); // Left-Top aligned
		vdi.sf_interior(0);
		fontlist.VFlush();
		font.Use();
		_itoa(font.PointSize(),Object(FONTPOINT).Text(),10);
	}

	const GEMfont& Chosen()
	{
		return font;
	}

	virtual GEMfeedback DoItem(int item, const GEMevent& e)
	{
		bool fontchanged=false;
		GEMformwindow::DoItem(item,e);

		if (item>=FONTNAME0 && item <=FONTNAMEN) {
			fontlist.LineClicked(item);
			GEMfont selectedfont=fontlist.SelectedFont();
			font.Code(selectedfont.Code());
			font.Smaller();
			font.Larger();
			fontchanged=true;
		}

		if (item==FONTPOINT) {
			font.PointSize(atoi(Object(FONTPOINT).Text()));
			fontchanged=true;
		}

		if (font.ArbitrarilySizable()) {
			switch (item) {
			 case FONTPTPLUS10:
				font.PointSize(font.PointSize()+10);
				fontchanged=true;
			break; case FONTPTMINUS10:
				font.PointSize(font.PointSize()-10);
				fontchanged=true;
			break; case FONTPTPLUS1:
				font.PointSize(font.PointSize()+1);
				fontchanged=true;
			break; case FONTPTMINUS1:
				font.PointSize(font.PointSize()-1);
				fontchanged=true;
			}
		} else {
			switch (item) {
			 case FONTPTPLUS10:
				font.Larger();
				fontchanged=true;
			break; case FONTPTMINUS10:
				font.Smaller();
				fontchanged=true;
			break; case FONTPTPLUS1:
				font.Larger();
				fontchanged=true;
			break; case FONTPTMINUS1:
				font.Smaller();
				fontchanged=true;
			}
		}

		if (fontchanged) {
			font.Use();
			_itoa(font.PointSize(),Object(FONTPOINT).Text(),10);
			RedrawObject(FONTPOINT);
			exampletext.Redraw();
		}

		return ContinueInteraction;
	}

private:
	VDI vdi;
	ScrollingFontList fontlist;
	GEMfont font;
	GEMvditextobject exampletext;
};


//
// Demonstrates a sophisticated duplicatable window with shared objects
//
class GEMringfiw : public GEMformiconwindow {
private:
	GEMringfiw*& head;
	GEMringfiw* next;
	GEMringfiw* prev;

protected:
	virtual GEMfeedback UserClosed() {
		GEMformwindow::Close();
		delete this;
		return ContinueInteraction;
	}

	GEMringfiw(GEMactivity& in, const GEMrsc& rsc, int RSCform, int RSCicon, GEMringfiw*& h) :
		GEMformiconwindow(in,rsc,RSCform,RSCicon),
		head(h)
	{
		next=prev=this;
	}

	GEMringfiw(GEMringfiw& copy, GEMringfiw*& h) :
		GEMformiconwindow(copy),
		next(&copy), prev(copy.prev),
		head(h)
	{
		next->prev=this;
		prev->next=this;
	}

	~GEMringfiw()
	{
		if (next==this) {
			head=0;
		} else {
			if (head==this) head=next;
			prev->next=next;
			next->prev=prev;
		}
	}

public:
	static bool OpenNew(GEMactivity& act, const GEMrsc& rsc, int RSCform, int RSCicon, GEMringfiw*& head)
	{
		GEMringfiw* newhead;

		if (head)
			newhead=new GEMringfiw(*head,head);
		else
			newhead=new GEMringfiw(act,rsc,RSCform,RSCicon,head);

		head=newhead;
		head->Open();
		if (head->IsOpen()) {
			return true;
		} else {
			delete newhead;
			return false;
		}
	}

	static void DeleteAll(GEMringfiw*& head)
	{
		while (head) {
			delete head;
		}
	}
};


//
// Demonstrates flying dialog boxes.
//
class GEMflyform : public GEMform {
public:
	GEMflyform(GEMrsc& rsc, int RSCindexform, int RSCindexknob=0, bool opaq=false) :
		GEMform(rsc,RSCindexform),
		opaque(opaq),
		knob(RSCindexknob)
	{
	}

protected:
	virtual GEMfeedback DoItem(int item, const GEMevent& e)
	{
		if (item==knob) {
			Fly(opaque);
			return ContinueInteraction;
		}

		return GEMform::DoItem(item,e);
	}

	void Opaque(bool opaq=true)
	{
		opaque=opaq;
	}

private:
	bool opaque;
	int knob;
};

class Flying : public GEMflyform {
public:
	Flying(GEMrsc& rsc) :
		GEMflyform(rsc,FLYING,FLYKNOB)
	{
		Opaque(Object(OPAQUE).Selected());
	}

protected:
	virtual GEMfeedback DoItem(int item, const GEMevent& e)
	{
		if (item==OPAQUE) {
			Opaque(Object(OPAQUE).Selected());
			return ContinueInteraction;
		}

		return GEMflyform::DoItem(item,e);
	}
};


class ColourSlider : public GEMslider {
// A ColourSlider is a simple slider (no arrowers) that shows the current
// value in the knob as text and colour.
//
// TODO: Auto-detect orientation.  Currently ONLY HORIZONTAL.
//
public:
	ColourSlider(GEMform& form, int rack, int minvalue, int maxvalue) :
		GEMslider(form,rack+1,rack)
	{
		SetTotalColumns(maxvalue-minvalue+1);
		SetVisibleColumns(2);
		SetLeftColumn(0);
	}

	virtual int HPageAmount()
	{
		return 1;
	}

	void HFlush()
	{
		int v=Value();
		char* text=form[FirstChild()].Text();
		if (v<10) {
			text[0]=v+'0';
			text[1]=0;
		} else {
			text[0]=v/10+'0';
			text[1]=v%10+'0';
			text[2]=0;
		}

		form[FirstChild()].BackCol(Value());
		if (Value()==0) {
			form[FirstChild()].ForeCol(1);
		} else {
			form[FirstChild()].ForeCol(0);
		}
		GEMslider::HFlush();
	}

	int Value()
	{
		return LeftColumn();
	}

	void Value(int v)
	{
		SetLeftColumn(v);
		HFlush();
	}
};

class PartsForm : public GEMformwindow {
public:
	PartsForm(GEMactivity& in, const GEMrsc& rsc) :
		GEMformwindow(in,rsc,BIGFORM,/*BIGFORMI,*/
			/* ALL */ NAME|CLOSER|FULLER|MOVER|SIZER|INFO|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE|SMALLER),
		borderslider(*this,BORDERRACK,0,15),
		textslider(*this,TEXTRACK,0,15),
		fillslider(*this,FILLRACK,0,15)
	{
		Resize(200,200);
		GEMform enabled(rsc,WCACTIVE);
		GEMform disabled(rsc,WCINACTIVE);
		SetPartColours(enabled,disabled);
		SetName(" Big Form ");

		for (int p=PART0; p<=PARTN && !Object(p).Selected(); p++)
			;

		if (p>PARTN) {
			p=PART0;
			Object(p).Select();
		}

		SetCurrentPart(p-PART0);
	}

	virtual GEMfeedback DoItem(int item, const GEMevent& e)
	{
		GEMfeedback result=ContinueInteraction;

		if (item==MODEBUTTON) {
			Object(MODEBUTTON).Transparent(bool(!Object(MODEBUTTON).Transparent()));
			colour.bits.textmode=Object(MODEBUTTON).Transparent();
			RedrawObject(MODEBUTTON);
		} else if (item>=PART0 && item<=PARTN) {
			SetCurrentPart(item-PART0);
		} else if (item>=FILL0 && item<=FILLN) {
			SelectPattern(item-FILL0);
		} else if (item==INACTIVE) {
			RedrawObject(Parent(INACTIVE));
			result=RedrawMyParent;
			SetCurrentPart(currentpart);
		} else if (item==ACTIVE) {
			SetCurrentPart(currentpart);
		} else {
			// The sliders are real objects.
			result=GEMformiconwindow::DoItem(item,e);

			switch (item) {
			 case BORDERKNOB: case BORDERRACK:
				colour.bits.framecol=borderslider.Value();
			break; case TEXTKNOB: case TEXTRACK:
				colour.bits.textcol=textslider.Value();
			break; case FILLKNOB: case FILLRACK:
				colour.bits.interiorcol=fillslider.Value();
			}
		}

		if (Object(ACTIVE).Selected()) {
			SetPartColour(currentpart,colour.packed,-1);
		} else {
			SetPartColour(currentpart,-1,colour.packed);
		}

		return result;
	}

private:
	ColourSlider borderslider,textslider,fillslider;

	void SetCurrentPart(int part)
	{
		currentpart=part;

		if (Object(ACTIVE).Selected()) {
			colour.packed=PartColour(part,true);
		} else {
			colour.packed=PartColour(part,false);
		}

		borderslider.Value(colour.bits.framecol);
		textslider.Value(colour.bits.textcol);

		Object(MODEBUTTON).Transparent(bool(colour.bits.textmode));

		SelectPattern(colour.bits.fillpattern);

		fillslider.Value(colour.bits.interiorcol);
	}

	void SelectPattern(int p)
	{
		if (p<0) p=0;
		else if (p+FILL0>FILLN) p=FILLN-FILL0;

		colour.bits.fillpattern=p;

		for (int i=FILL0; i<=FILLN; i++) {
			if (*(Object(i).Text())=='\010') {
				Object(i).SetText(" ");
				RedrawObject(i);
				break;
			}
		}

		Object(FILL0+p).SetText("\010");
		RedrawObject(FILL0+p);
	}

	int currentpart;

	union {
		short packed;
		struct {
			unsigned short framecol    :  4;
			unsigned short textcol     :  4;
			unsigned short textmode    :  1;
			unsigned short fillpattern :  3;
			unsigned short interiorcol :  4;
		} bits;
	} colour;
};

class Shape {
public:
	static void SetVDI(VDI& v)
	// Set the device on which all Shapes are drawn.
	{
		vdi=&v;
	}

	Shape(Shape* n=0) :
		next(n)
	{
	}

	void Append(Shape* sh)
	{
		Shape* cursor=this;
		while (cursor->next) {
			cursor=cursor->next;
		}
		cursor->next=sh;
	}

	Shape* Next() { return next; }

	virtual void Draw(int xoff, int yoff)=0;

	virtual void GetExtent(GRect& extent)=0;

	virtual bool Touches(int x,int y)=0;

	Shape* Remove(Shape* sh)
	// Remove sh from this list, returning resulting list.
	{
		if (sh==this) {
			Shape* result=next;
			next=0;

			return result;
		} else {
			if (next)
				next=next->Remove(sh);
			return this;
		}
	}

	Shape* FindLast(int x,int y)
	// Return the last shape touching (x,y).
	{
		Shape* last=0;
		Shape* cursor=this;

		while (cursor) {
			if (cursor->Touches(x,y))
				last=cursor;
			cursor=cursor->next;
		}

		return last;
	}

protected:
	VDI& Device()
	{
		return *vdi;
	}

private:
	static VDI* vdi;
	Shape* next;
};

VDI* Shape::vdi=0;

class CircleShape : public Shape {
public:
	CircleShape(int xpos, int ypos, int radius, Shape* next=0) :
		Shape(next),
		x(xpos),y(ypos),r(radius)
	{
	}

	virtual void Draw(int xoff, int yoff)
	{
		Device().circle(x+xoff,y+yoff,r);
	}

	virtual void GetExtent(GRect& extent)
	{
		extent.g_x=x-r;
		extent.g_y=y-r;
		extent.g_w=r*2+1;
		extent.g_h=r*2+1;
	}

	virtual bool Touches(int tx,int ty)
	{
		if (tx<x-r || tx>x+r || ty<y-r || ty>y+r) return false;

		int dx=abs(tx-x);
		int dy=abs(ty-y);

		// Distance formula:  sqrt(dx**2 + dy**2) < r
		return dx*dx+dy*dy <= r*r;
	}

private:
	int x,y,r;
};

class RectangleShape : public Shape {
public:
	RectangleShape(int xpos, int ypos, int width, int height, Shape* next=0) :
		Shape(next),
		x(xpos),y(ypos),w(width),h(height)
	{
	}

	virtual void Draw(int xoff, int yoff)
	{
		Device().bar(x+xoff,y+yoff,x+xoff+w-1,y+yoff+h-1);
	}

	virtual void GetExtent(GRect& extent)
	{
		extent.g_x=x;
		extent.g_y=y;
		extent.g_w=w;
		extent.g_h=h;
	}

	virtual bool Touches(int tx,int ty)
	{
		return tx>=x && tx<x+w && ty>=y && ty<y+h;
	}

private:
	int x,y,w,h;
};

class TextShape : public Shape {
public:
	TextShape(int xpos, int ypos, const char* text, const GEMfont& fnt, Shape* next=0) :
		Shape(next),
		x(xpos),y(ypos),txt(strdup(text)),
		font(Device(),fnt)
	{
	}

	virtual ~TextShape()
	{
		delete txt;
	}

	virtual void Draw(int xoff, int yoff)
	{
		font.Use();
		Device().gtext(x+xoff,y+yoff,txt);
	}

	virtual void GetExtent(GRect& extent)
	{
		// NB:  qt_extent() does not take alignment into account.
		//      (ie. we are assuming alignement is Top-Left)
		int txt_extent[8];
		font.Use();
		Device().qt_extent(txt,txt_extent);

		extent.g_x=x+txt_extent[0];
		extent.g_y=y+txt_extent[1];
		extent.g_w=txt_extent[2]-txt_extent[0]+1;
		extent.g_h=txt_extent[5]-txt_extent[3]+1;
	}

	virtual bool Touches(int tx,int ty)
	{
		GRect r;
		GetExtent(r);

		return tx>=r.g_x && tx<r.g_x+r.g_w && ty>=r.g_y && ty<r.g_y+r.g_h;
	}

private:
	int x,y;
	char* txt;
	GEMfont font;
};

class Canvas : public GEMcanvas {
public:
	Canvas(GEMform& form, int RSCindex) :
		GEMcanvas(form,RSCindex),
		shape_list(0)
	{
		st_alignment(0,5);
		sf_interior(FIS_HOLLOW);
	}

	void RedrawVirtualArea(GRect& rect)
	{
		form.RedrawObject(myindex,rect.g_x-CanvasX(),rect.g_y-CanvasY(),rect.g_w,rect.g_h);
	}

	void AppendShape(Shape* sh)
	{
		if (shape_list)
			shape_list->Append(sh);
		else
			shape_list=sh;

		GRect extent;
		sh->GetExtent(extent);
		RedrawVirtualArea(extent);
	}

	Shape* FindShape(int x, int y)
	{
		if (shape_list)
			return shape_list->FindLast(x,y);
		else
			return 0;
	}

	void DeleteShape(Shape* sh)
	{
		if (shape_list) {
			GRect extent;
			sh->GetExtent(extent);

			shape_list=shape_list->Remove(sh);

			RedrawVirtualArea(extent);

			delete sh;
		}
	}

	void DeleteAll()
	{
		while (shape_list) {
			Shape* sh=shape_list;
			shape_list=shape_list->Next();
			delete sh;
		}
		Redraw();
	}

	void Circle(int x, int y, int radius)
	{
		AppendShape(new CircleShape(x,y,radius));
	}

	void Rectangle(int x, int y, int w, int h)
	{
		AppendShape(new RectangleShape(x,y,w,h));
	}

	void Text(int x, int y, char* text, const GEMfont& fnt)
	{
		GEMfont to_use(*this,fnt);
		AppendShape(new TextShape(x,y,text,to_use));
	}

	virtual void DrawAt(int x, int y, const GRect& clip)
	{
		// Clear background.
		r_recfl(x+clip.g_x,y+clip.g_y,x+clip.g_x+clip.g_w-1,y+clip.g_y+clip.g_h-1);

		// Just rely on VDI clipping to decide what to draw.
		// More appropriately, we could store our shapes in a fashion that
		// allowed us to instantly decide which subgroup to actually draw.
		DrawAll(x,y);
	}

	void DrawAll(int x, int y)
	{
		for (Shape* sh=shape_list; sh; sh=sh->Next()) {
			sh->Draw(x,y);
		}
	}

	void DrawOn(VDI& v)
	{
		Shape::SetVDI(v);
		DrawAll(0,0);
		Shape::SetVDI(*this);
	}

	void WriteMetafile(char* filename)
	{
		VDI metafile(filename);

		GEMchangearea bb; // Bounding Box

		for (Shape* sh=shape_list; sh; sh=sh->Next()) {
			GRect extent;
			sh->GetExtent(extent);
			bb.Include(extent);
		}

		metafile.m_pagesize(bb.g_w*PixelWidth()/100,bb.g_h*PixelHeight()/100);
		metafile.meta_extents(bb.g_x,bb.g_y,bb.g_x+bb.g_w-1,bb.g_y+bb.g_h-1);

		DrawOn(metafile);
	}

private:
	Shape* shape_list;
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

// A trivial sliding object.
class GEMslidable : public GEMobject {
public:
	GEMslidable(GEMform& form, int RSCindex) :
		GEMobject(form,RSCindex)
	{
	}

	virtual GEMfeedback Touch(int x, int y, const GEMevent&)
	{
		GEMobject parent(form,form.Parent(myindex));

		int tx,ty;
		parent.GetAbsoluteXY(tx,ty);

		int ox,oy,nx,ny;
		ox=tx+X();
		oy=ty+Y();

		graf_dragbox(Width(),Height(),ox,oy,
			tx,ty,parent.Width(),parent.Height(),&nx,&ny);

		// Redraw parent with this hidden
		HideTree(true);

		int cx,cy;
		GetAbsoluteXY(cx,cy);

		form.RedrawObject(form.Parent(myindex), cx-tx, cy-ty,
			Width(), Height());

		MoveTo(nx-tx,ny-ty);

		HideTree(false);

		Redraw();

		return ContinueInteraction;
	}
};

class CanvasWindow : public GEMformiconwindow {
public:
	CanvasWindow(GEMactivity& in, const GEMrsc& rsc, FontWindow& fntselector) :
		GEMformiconwindow(in,rsc,CANVAS,CANVASI),
		canvas(*this,CNVBOX),
		speed(*this,CNVKNOB,CNVRACK),
		parameter(*this,CNVPARM),
		cursor(*this,CNVCURSOR),
		canvashelp(rsc,CANVASHELP),
		canvasphelp(in,rsc,CANVASPHELP),
		fontselector(fntselector)
	{
		canvas.st_load_fonts();

		SetName(" Canvas ");
		canvasphelp.SetName(" Canvas - parameters ");

		Shape::SetVDI(canvas);
	}

	virtual GEMfeedback DoItem(int item, const GEMevent& e)
	{
		int cursor_x=canvas.CanvasX()+Object(CNVCURSOR).X()+7;
		int cursor_y=canvas.CanvasY()+Object(CNVCURSOR).Y()+7;

		switch (item) {
		 case CNVUP: case CNVDOWN: case CNVLEFT: case CNVRIGHT:
			// Redraw CNVBOX with CNVCURSOR hidden
			Object(CNVCURSOR).HideTree(true);

			// XXX This should be provided by GEMform
			int cx,cy,bx,by;
			objc_offset(Obj,CNVCURSOR,&cx,&cy);
			objc_offset(Obj,CNVBOX,&bx,&by);
			RedrawObject(CNVBOX,cx-bx,cy-by,
				Object(CNVCURSOR).Width(),
				Object(CNVCURSOR).Height());

			int delay=speed.TotalColumns()-speed.LeftColumn()-speed.VisibleColumns();
			int scroll_amount=1;

			// Delay 0..7 is implemented using scroll amount 16..2, no delay.
			// Delay 8.. is implemented using scroll amount of 1 and time delay.
			//
			// Why?  Because it looks nice.
			//
			if (delay < 8) {
				scroll_amount=(8-delay)*2;
				delay=0;
			} else {
				delay-=7;
			}

			switch (item) {
			 case CNVUP:
				canvas.VScroll(-scroll_amount);
			break; case CNVDOWN:
				canvas.VScroll(+scroll_amount);
			break; case CNVLEFT:
				canvas.HScroll(-scroll_amount);
			break; case CNVRIGHT:
				canvas.HScroll(+scroll_amount);
			}

			if (delay) {
				Untouch(delay*5);
			}

			// Replace cursor
			Object(CNVCURSOR).HideTree(false);
			RedrawObject(CNVCURSOR);
		break; case CNVCIRCLE:
			int radius=atoi(parameter);
			if (radius < 1) radius=1;
			canvas.Circle(cursor_x,cursor_y,radius);
		break; case CNVSQUARE:
			int hside=atoi(parameter);
			if (hside < 1) hside=1;
			for (char* parm=parameter; *parm && *parm!=',' && *parm!='x' && *parm!='*'; parm++)
				;
			int vside=*parm ? atoi(parm+1) : hside;
			if (vside < 1) vside=hside;
			canvas.Rectangle(cursor_x,cursor_y,hside,vside);
		break; case CNVTEXT:
			canvas.Text(cursor_x,cursor_y,parameter,fontselector.Chosen());
		break; case CNVDELETE1:
			Shape* sh=canvas.FindShape(cursor_x,cursor_y);
			if (sh) {
				canvas.DeleteShape(sh);
			}
		break; case CNVERASE:
			if (parameter[0]=='y') canvas.DeleteAll();
		break; case CNVHELP:
			// Popup canvas help on top of canvas window.
			// (it's an overlayed help box).
			canvashelp.Do(Object(0).X(),Object(0).Y());
		break; case CNVPHELP:
			// Open canvas parameter help window.
			canvasphelp.Open();
		break; case CNVWRITE:
			canvas.WriteMetafile(parameter);
		break; default:
			GEMformiconwindow::DoItem(item,e);
		}

		return ContinueInteraction;
	}

private:
	Canvas canvas;

	GEMslidable cursor;
	GEMslider speed;
	GEMtextobject parameter;
	GEMform canvashelp;
	GEMformwindow canvasphelp;
	FontWindow& fontselector;
};

//
// Demonstrates GEMmenu as central to the interaction.
//
class Menu : GEMmenu {
public:
	Menu(GEMactivity& in, const GEMrsc& r) :
		GEMmenu(in,r,MENU),
		act(in),
		rsc(r),
		about(rsc,ABOUT),
		itisfree(rsc,FREE),
		authors(rsc,AUTHORS),
		gnu(rsc,GNU),
		flying(rsc),
		errwin(rsc,ERRWIN),
		clocknote(rsc,CLOCKNOTE),
		various(in,rsc),
		fonts(in,rsc),
		clock(in,rsc),
		microdraw(in,rsc),
		windows(0),
		partsform(in,rsc),
		canvaswin(in,rsc,fonts)
	{
	}

	~Menu()
	{
		GEMringfiw::DeleteAll(windows);
	}

protected:
	virtual GEMfeedback DoItem(int item, const GEMevent& e)
	{
		switch (item) {
		 case DOABOUT:
			about.Do();
		break; case DOFREE:	
			itisfree.Do();
		break; case DOAUTHORS:
			authors.Do();
		break; case DOGNU:
			gnu.Do();
		break; case DOQUIT:
			return EndInteraction;
		break; case DOVARIOUS:
			various.Open();
		break; case DOFLYING:
			flying.Do();
		break; case DOBIGFORM:
			partsform.Open();
		break; case DOSHARING:
			if (!GEMringfiw::OpenNew(act,rsc,SHARING,SHARINGI,windows))
				switch (errwin.Alert()) {
				 case 1: return DoItem(item,e);
				break; case 2: about.Do();
				}
		break; case DOFONTS:
			fonts.Open();
		break; case DOCANVAS:
			canvaswin.Open();
		break; case DOCLOCK:
			clocknote.Alert();
			clock.Open();
		break; case DOXIMG:
			microdraw.Open();
		}

		return ContinueInteraction;
	}

private:
	GEMringfiw* windows;
	GEMactivity& act;
	GEMrsc& rsc;
	FontWindow fonts; // defined before othrs, because it loads fonts.
	Clock clock;
	GEMform about,itisfree,authors,gnu;
	Flying flying;
	PartsForm partsform;
	CanvasWindow canvaswin;
	Various various;
	MicroDraw microdraw;
	GEMalert errwin;
	GEMalert clocknote;
};


//
// Demonstrates GEMfileselector
//
class FileChooser : public GEMobject, public GEMfileselector {
public:
	FileChooser(GEMform& f, int RSCibutn, GEMobject& disp, char* prmpt) :
		GEMobject(f,RSCibutn),
		GEMfileselector(disp.Text()),
		display(disp),
		prompt(prmpt)
	{
		display.Redraw();
	}

	virtual GEMfeedback Touch(int x, int y, const GEMevent& e)
	{
		if (Get(prompt)) display.Redraw();

		return ContinueInteraction;
	}

private:
	GEMobject& display;
	char* prompt;
};

//
// Demonstrates GEMdesktop
//
class Desktop : public GEMdesktop {
public:
	Desktop(GEMactivity& in, const GEMrsc& rsc) :
		GEMdesktop(in,rsc,DESKTOP),
		display(*this,FILEDISPLAY),
		files(*this,FILES,display,rsc.String(FILEPROMPT))
	{
	}

private:
	GEMobject display;
	FileChooser files;
};


class KeyProcessor : public GEMkeysink {
public:
	KeyProcessor(GEMactivity& a) :
		GEMkeysink(a),
		act(a)
	{
	}

	virtual GEMfeedback Consume(const GEMevent& ev)
	{
		switch (ev.Key()>>8) {
		 case KEY_Q:
			return EndInteraction;
		}
		return ContinueInteraction;
	}

private:
	GEMactivity& act;
};


main()
{
	// Before we do ANYTHING with GEM, we must declare a GEMapplication.
	GEMapplication example;

	// Next, we declare a GEMrsc, which we then use to create other objects.
	GEMrsc rsc("example.rsc",8,16);
	// GEMrsc rsc("example.rsc");

	if (!rsc) {
		// If the GEMrsc file cannot be created, we have to resort to a
		// GEMalert constructed from strings rather than from the GEMrsc.
		GEMalert dammit("Could not load \"example.rsc\".","Quit");
		dammit.Alert();
	} else {
		// But if everything goes fine, we create a GEMactivity, and
		// our own Menu and Desktop (see definitions above) in that
		// GEMactivity.

		GEMactivity activity;

		Menu menu(activity,rsc);

		KeyProcessor keyproc(activity);

		Desktop desktop(activity,rsc);

		GEMrectangletracker tracker(activity);

		// Then, conduct the GEMactivity - returns when all done.
		activity.Do();
	}
}
