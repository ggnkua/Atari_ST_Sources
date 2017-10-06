#include "ex_font.h"
#include <example.h>

GEMvditextobject::GEMvditextobject(GEMform& f, int RSCindex, VDI& v) :
	GEMvdiobject(f,RSCindex,v)
{
}

int GEMvditextobject::Draw(int x, int y)
{
	// Assume vdi is all setup.
	vdi.r_recfl(x,y,x+Width()-1,y+Height()-1);
	vdi.gtext(x,y,Text());
	return States();
}

// A scrolling list of [selectable] text lines.
//
ScrollingTextList::ScrollingTextList(GEMform& form, int RSCbox,
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

int ScrollingTextList::LineToRSCindex(int line)
{
	int RSCindex=line-TopLine()+line0;

	if (RSCindex>=line0 && RSCindex<=lineN) {
		return RSCindex;
	} else {
		return -1;
	}
}

int ScrollingTextList::RSCindexToLine(int RSCindex)
{
	return RSCindex-line0+TopLine();
}

void ScrollingTextList::RedrawLine(int line)
{
	int RSCindex=LineToRSCindex(line);

	if (RSCindex>=0) {
		form.RedrawObject(RSCindex);
	}
}

void ScrollingTextList::VFlush()
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

// Override this if some of the lines are to be selectable.
bool ScrollingTextList::SelectedLine(int line)
{
	return false;
}

ScrollingFontList::ScrollingFontList(GEMform& form, int RSCbox,
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

GEMfont ScrollingFontList::SelectedFont()
{
	return fontlist.Font(selectedfont);
}

void ScrollingFontList::LineClicked(int RSCindex)
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

int ScrollingFontList::NumberOfLines()
{
	return fontlist.NumberOfFonts();
}

char* ScrollingFontList::Line(int i)
{
	return fontlist.FontName(i);
}

bool ScrollingFontList::SelectedLine(int line)
{
	return line==selectedfont;
}

//
// Demonstrates GEMfonts.
//
FontWindow::FontWindow(GEMactivity& in, const GEMrsc& rsc) :
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

const GEMfont& FontWindow::Chosen()
{
	return font;
}

static int ChangeFontSize(GEMfont& font, int delta)
{
	int size=font.PointSize();
	size+=delta;
	if (size<1) size=1;
	if (size>255) size=255;
	font.PointSize(size);
	return size;
}

GEMfeedback FontWindow::DoItem(int item, const GEMevent& e)
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
			ChangeFontSize(font,+10);
			fontchanged=true;
		break; case FONTPTMINUS10:
			ChangeFontSize(font,-10);
			fontchanged=true;
		break; case FONTPTPLUS1:
			ChangeFontSize(font,+1);
			fontchanged=true;
		break; case FONTPTMINUS1:
			ChangeFontSize(font,-1);
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
