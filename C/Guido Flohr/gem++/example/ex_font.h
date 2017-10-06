#ifndef ex_font_h
#define ex_font_h

#include <gemvo.h>
#include <gemsl.h>
#include <gemfn.h>
#include <gemfiw.h>
#include <gemfl.h>
#include <vdi.h>

class GEMvditextobject : public GEMvdiobject {
public:
	GEMvditextobject(GEMform& f, int RSCindex, VDI& v);
	virtual int Draw(int x, int y);
};

// A scrolling list of [selectable] text lines.
//
class ScrollingTextList : public GEMslider {
public:
	ScrollingTextList(GEMform& form, int RSCbox,
	 int RSCknob, int RSCrack, int RSCminus, int RSCplus,
	 int RSCfirstline, int RSClastline);

	int LineToRSCindex(int line);
	int RSCindexToLine(int RSCindex);
	void RedrawLine(int line);
	virtual void VFlush();

protected:
	// Override these to get an actual scrolling textbox...
	virtual int NumberOfLines()=0;
	virtual char* Line(int i)=0;

	// Override this if some of the lines are to be selectable.
	virtual bool SelectedLine(int line);

private:
	int line0, lineN, linebox;
};

class ScrollingFontList : public ScrollingTextList {
public:
	ScrollingFontList(GEMform& form, int RSCbox,
	 int RSCknob, int RSCrack, int RSCminus, int RSCplus,
	 int RSCfirstline, int RSClastline, VDI& v);

	GEMfont SelectedFont();
	void LineClicked(int RSCindex);

protected:
	virtual int NumberOfLines();
	virtual char* Line(int i);
	virtual bool SelectedLine(int line);

private:
	int selectedfont;
	GEMfontlist fontlist;
};

//
// Demonstrates GEMfonts.
//
class FontWindow : public GEMformiconwindow {
public:
	FontWindow(GEMactivity& in, const GEMrsc& rsc);

	const GEMfont& Chosen();
	virtual GEMfeedback DoItem(int item, const GEMevent& e);

private:
	VDI vdi;
	ScrollingFontList fontlist;
	GEMfont font;
	GEMvditextobject exampletext;
};

#endif
