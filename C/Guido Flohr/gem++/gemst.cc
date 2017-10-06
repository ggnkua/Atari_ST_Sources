/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1993,1994 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include "gemst.h"
#include "gemfn.h"
#include "gemfw.h"
#include "geme.h"
#include "grect.h"
#include "scancode.h"
#include "vdi++.h"
#include <string.h>

template <class T>
void swap(T& a, T& b)
{
	T temp=a;
	a=b;
	b=temp;
}


GEMscrolltext::GEMscrolltext(GEMformwindow& form, int RSCindex, int w, int h) :
	GEMcanvas(form,RSCindex)
{
	Init(w,h);
}

GEMscrolltext::GEMscrolltext(GEMformwindow& form, int RSCindex) :
	GEMcanvas(form,RSCindex)
{
	Init(0,0);
}

void GEMscrolltext::Init(int w, int h)
{
	in_focus=false;
	bottom_aligned=false;
	auto_refresh=true;
	cursorx=0;
	cursory=0;

	FontChanged();

	if (w && h) {
		width=w;
		height=height;
	} else {
		width=GEMuserobject::Width()/(fontwidth ? fontwidth : fontheight*3/4);
		height=GEMuserobject::Height()/fontheight;
	}

	textline=new char*[height];
	change.Clear();

	for (int j=0; j<height; j++) {
		textline[j]=new char[width+1]; // +1 for '\0' terminator.
		for (int i=0; i<=width; i++) {
			textline[j][i]=0;
		}
	}

	if (Text() && Text()[0]!='@') strncpy(textline[0],Text(),width);

	sf_interior(FIS_HOLLOW);
	sf_perimeter(0);
}

GEMscrolltext::~GEMscrolltext()
{
	for (int j=0; j<height; j++)
		delete textline[j];

	delete textline;
}

#if 0
void GEMscrolltext::ScrollText(int columns_right, int lines_down)
{
	// Flush any changes.
	// XXX (could optimize by unchanging area about to be scrolled away)
	Refresh();

	if (columns_right>0) {
		if (columns_right>=width) {
			// Just clear it all.
			for (int j=0; j<height; j++) {
				memset(textline[j],' ',width);
			}
		} else {
			for (int j=0; j<height; j++) {
				memcpy(textline[j],textline[j]+columns_right,width-columns_right);
				memset(textline[j]+width-columns_right,' ',columns_right);
			}
		}
	} else if (columns_right<0) {
		if (-columns_right>=width) {
			// Just clear it all.
			for (int j=0; j<height; j++) {
				memset(textline[j],' ',width);
			}
		} else {
			for (int j=0; j<height; j++) {
				memcpy(textline[j]-columns_right,textline[j],width+columns_right);
				memset(textline[j],' ',-columns_right);
			}
		}
	}

	if (lines_down>0) {
		for (int j=0; j<height-lines_down; j++) {
			swap(textline[j],textline[j+lines_down]);
		}
		for (int jj=height-1; jj>0 && jj>j; j--) {
			memset(textline[jj],' ',width);
		}
	} else if (lines_down<0) {
		for (int j=height-1; j>=-lines_down; j--) {
			swap(textline[j],textline[j+lines_down]);
		}
		for (j=j; j>=0; j--) {
			memset(textline[j],' ',width);
		}
	}

	Scroll(columns_right*fontwidth,lines_down*global_fontheight);
}
#endif

static
bool FontIsVariableWidth(VDI& vdi)
// Assumes 'W' will be wider than 'i' for variable-width fonts.
{
	int cw_W;
	int cw_i;
	int j;
	vdi.qt_width('W',&cw_W,&j,&j);
	vdi.qt_width('i',&cw_i,&j,&j);
	return cw_W != cw_i;
}

void GEMscrolltext::FontChanged()
{
	if (FontIsVariableWidth(*this)) {
		fontwidth=0;
	} else {
		fontwidth=CharCellWidth();
	}

	fontheight=CharCellHeight();

	if (bottom_aligned) {
		int j;
		st_alignment(0,3,&j,&j); // left-bottom
	} else {
		int j;
		st_alignment(0,5,&j,&j); // left-top
	}
}

int GEMscrolltext::DrawAt(int x, int y, const GRect& area)
{
	bool showcursor=Editable() && in_focus;

	int to=(area.g_y+area.g_h+fontheight-1)/fontheight;
	if (to>=height) to=height-1;

	for (int j=area.g_y/fontheight; j<=to; j++) {
		const int py=y+j*fontheight;

		int pxy[8];
		qt_extent(textline[j],pxy);
		int blankx1=pxy[4]+1;
		int blankx2=x+area.g_x+area.g_w-1;
		if (blankx1<=blankx2) {
			bar(blankx1,py,blankx2,py+fontheight-1);
		}

		gtext(x,py,textline[j]);

		if (showcursor && cursory==j) {
			int cursor_pixel_x;

			if (fontwidth) {
				// Fixed - easy
				cursor_pixel_x=cursorx*fontwidth;
			} else {
				// Proportional - Tricky
				char hold=textline[j][cursorx];
				textline[j][cursorx]=0;
				qt_extent(textline[j],pxy);
				cursor_pixel_x=pxy[4]+1;
				textline[j][cursorx]=hold;
			}
			if (cursorx==width) cursor_pixel_x--;

			swr_mode(MD_XOR);
			line(x+cursor_pixel_x,py,x+cursor_pixel_x,py+fontheight-1);
			swr_mode(MD_REPLACE);
		}
	}

	return States();
}

void GEMscrolltext::Cursor(int x, int y)
{
	bool showcursor=Editable() && in_focus;
	if (showcursor) change.Include(cursorx,cursory);
	cursorx=x;
	cursory=y;
	if (showcursor) change.Include(cursorx,cursory);

	// Blank fill.
	while (x && !textline[y][x-1]) {
		x--;
		textline[y][x]=' ';
		if (showcursor) change.Include(x,y); // In here, since it is rare.
	}

	if (showcursor && auto_refresh) Refresh();
}

void GEMscrolltext::Put(char ch)
{
	int i=cursorx;
	int j=cursory;

	// Find NUL
	while (ch && j<height) {
		int left=i;
		change.Include(i,j);

		while (i<width && textline[j][i])
			i++;

		char pushed;
		if (i==width) {
			// Full
			i--;
			pushed=textline[j][i];
		} else {
			pushed=0;
		}

		change.Include(i,j);

		// Shift right
		while (i>left) {
			textline[j][i]=textline[j][i-1];
			i--;
		}
		textline[j][i]=ch;

		ch=pushed;
		i=0;
		j++;
	}

	if (cursorx<width-1) {
		cursorx++;
	} else {
		cursorx=0;
		if (cursory<height-1) cursory++;
	}
	change.Include(cursorx,cursory);

	if (auto_refresh) Refresh();
}

void GEMscrolltext::Put(char* str)
{
	bool ar=auto_refresh;
	auto_refresh=false;
	while (*str) Put(*str++);
	auto_refresh=ar;
	if (auto_refresh) Refresh();
}

void GEMscrolltext::Refresh()
{
	if (change.Changed()) {
		change.Scale(fontwidth,fontheight);

		if (!fontwidth) {
			// Variable-width font - refresh full line width
			change.g_x=0;
			change.g_w=GEMuserobject::Width();
		}

		change.MoveRel(-CanvasX(),-CanvasY());

		form.RedrawObject(myindex,
			change.g_x,change.g_y,change.g_w,change.g_h);

		change.Clear();
	}
}

GEMfeedback GEMscrolltext::Touch(int x, int y, const GEMevent& e)
{
	if (e.Keyboard()) {
		switch (e.Key()>>8) {
		 case KEY_RETURN: case KEY_ENTER:
			CarriageReturn();
		break; case KEY_BS:
			Backspace();
		break; case KEY_DELETE:
			DeleteChar();
		break; case KEY_LEFT:
			if (e.Meta()) {
				CursorToStartOfLine();
			} else {
				CursorLeft();
			}
		break; case KEY_RIGHT:
			if (e.Meta()) {
				CursorToEndOfLine();
			} else {
				CursorRight();
			}
		break; case KEY_UP:
			CursorUp();
		break; case KEY_DOWN:
			CursorDown();
		break; case KEY_HOME:
			if (e.Meta()) {
				End();
			} else {
				Home();
			}
		break; case KEY_ESC: // XXX Do users really like this?
			ClearHome();
		break; default:
			Put(e.Key()&0xff);
			return ContinueInteraction;
		}
	} else if (e.Rectangle()) {
		if (!e.OutNotIn()) {
			// SAFE CAST, since constructor insists on GEMformwindow.
			((GEMformwindow&)form).Edit(myindex,1); // XXX 1=column
		}
		return ContinueInteraction;
	} else if (e.Button()) {
		if (e.Button(0)) {
			int cx,cy;
			PixelToCharacter(x,y,cx,cy);
			// Move to EOL
			while (cx && !textline[cy][cx-1]) cx--;
			Cursor(cx,cy);
			// XXX Copy-to-clipboard (delay drag)
			// XXX Use block-cursor (hard, good),
			// XXX or instant-copy-and-unhighlight (easy, bad).
		} else {
			// Right button
			// XXX Paste-from-clipboard
		}
	}
	return IgnoredClick;
}

void GEMscrolltext::InFocus(bool yes)
{
	if (in_focus!=yes) {
		in_focus=yes;
		change.Include(cursorx,cursory);
		Refresh();
	}
}

void GEMscrolltext::PixelToCharacter(int x, int y, int& cx, int& cy)
{
	cy=y/fontheight;

	if (fontwidth) {
		// Fixed width - simple
		cx=(x+fontwidth/2)/fontwidth;
	} else {
		// Proportional - tricky
		int cursor_pixel_px;
		int cursor_pixel_x=-99;
		cx=-1;
		do {
			cx++;
			int pxy[8];
			char hold=textline[cursory][cx];
			textline[cursory][cx]=0;
			qt_extent(textline[cursory],pxy);
			cursor_pixel_px=cursor_pixel_x;
			cursor_pixel_x=pxy[4];
			textline[cursory][cx]=hold;
		} while (cx<width-1 && cursor_pixel_x<x);

		// Round to nearest
		if (cx && x-cursor_pixel_px < cursor_pixel_x-x) cx--;
	}
}

// TTY operations
void GEMscrolltext::CarriageReturn()
{
	if (cursory<height-1) {
		char* lastline=textline[height-1];
		int j;
		
		for (j=height-1; j>cursory+1; j--) {
			textline[j]=textline[j-1];
		}
		textline[j]=lastline;
		
		int i;
		for (i=0; cursorx+i<width; i++) {
			lastline[i]=textline[cursory][cursorx+i];
			textline[cursory][cursorx+i]=0;
			textline[cursory][cursorx+i]=0;
		}
		for ( ; i<width; i++) {
			lastline[i]=0;
		}

		change.Include(0,cursory);
		change.Include(width-1,height-1);
		cursorx=0;
		cursory++;

		if (auto_refresh) Refresh();
	}
}

void GEMscrolltext::CursorLeft()
{
	int x=cursorx,y=cursory;
	if (x) {
		x--;
	} else if (y) {
		y--;
		while (textline[y][x]) x++;
	}
	Cursor(x,y);
}

void GEMscrolltext::CursorRight()
{
	int x=cursorx,y=cursory;
	if (textline[y][x]) {
		x++;
	} else if (y<height-1) {
		y++;
		x=0;
	}
	Cursor(x,y);
}

void GEMscrolltext::CursorUp()
{
	if (cursory) {
		int x=cursorx,y=cursory;
		y--;
		while (x && !textline[y][x-1]) x--;
		Cursor(x,y);
	}
}

void GEMscrolltext::CursorDown()
{
	if (cursory<height-1) {
		int x=cursorx,y=cursory;
		y++;
		while (x && !textline[y][x-1]) x--;
		Cursor(x,y);
	}
}

void GEMscrolltext::CursorToEndOfLine()
{
	int x=cursorx;
	while (textline[cursory][x]) x++;
	Cursor(x,cursory);
}

void GEMscrolltext::CursorToStartOfLine()
{
	Cursor(0,cursory);
}

void GEMscrolltext::Home()
{
	Cursor(0,0);
}

void GEMscrolltext::End()
{
	int x=cursorx;
	while (textline[height-1][x]) x++;
	Cursor(x,height-1);
}

void GEMscrolltext::ClearHome()
{
	for (int j=0; j<height; j++)
		for (int i=0; textline[j][i]; i++)
			textline[j][i]=0;
	change.Include(width-1,height-1);
	Home();
}

void GEMscrolltext::DeleteChar()
{
	change.Include(cursorx,cursory);
	int x=cursorx;
	while (textline[cursory][x]) {
		textline[cursory][x]=textline[cursory][x+1];
		x++;
	}
	change.Include(x,cursory);
	if (auto_refresh) Refresh();
}

void GEMscrolltext::Backspace()
{
	if (cursorx) {
		cursorx--;
		DeleteChar();
	} else {
		CursorLeft();
	}
}

