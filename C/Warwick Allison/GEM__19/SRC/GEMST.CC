/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include "gemst.h"
#include "gemfn.h"
#include "grect.h"
#include "vdi.h"
#include <string.h>

template <class T>
void swap(T& a, T& b)
{
	T temp=a;
	a=b;
	b=temp;
}


GEMscrolltext::GEMscrolltext(GEMform& form, int RSCindex, int width, int height) :
	GEMscrollableobject(form,RSCindex),
	w(width),h(height),
	textline(new char*[height]),
	top_aligned(FALSE)
{
	change.Clear();

	for (int j=0; j<h; j++) {
		textline[j]=new char[w+1]; // +1 for '\0' terminator.
		for (int i=0; i<w; i++) {
			textline[j][i]='*';
		}
	}
}

GEMscrolltext::~GEMscrolltext()
{
	for (int j=0; j<h; j++)
		delete textline[j];

	delete textline;
}

// These are used for passing font size from ScrollText and Draw
// to RedrawClipped, through Scroll.
static int global_fontwidth;
static int global_fontheight;

void GEMscrolltext::ScrollText(int columns_right, int lines_down)
{
	// Flush any changes.
	// (could optimize by unchanging area about to be scrolled away)
	Refresh();

	if (columns_right>0) {
		if (columns_right>=w) {
			// Just clear it all.
			for (int j=0; j<h; j++) {
				memset(textline[j],' ',w);
			}
		} else {
			for (int j=0; j<h; j++) {
				memcpy(textline[j],textline[j]+columns_right,w-columns_right);
				memset(textline[j]+w-columns_right,' ',columns_right);
			}
		}
	} else if (columns_right<0) {
		if (-columns_right>=w) {
			// Just clear it all.
			for (int j=0; j<h; j++) {
				memset(textline[j],' ',w);
			}
		} else {
			for (int j=0; j<h; j++) {
				memcpy(textline[j]-columns_right,textline[j],w+columns_right);
				memset(textline[j],' ',-columns_right);
			}
		}
	}

	if (lines_down>0) {
		for (int j=0; j<h-lines_down; j++) {
			swap(textline[j],textline[j+lines_down]);
		}
		for (int jj=h-1; jj>0 && jj>j; j--) {
			memset(textline[jj],' ',w);
		}
	} else if (lines_down<0) {
		for (int j=h-1; j>=-lines_down; j--) {
			swap(textline[j],textline[j+lines_down]);
		}
		for (j=j; j>=0; j--) {
			memset(textline[j],' ',w);
		}
	}

	SetRedrawFont();

	Scroll(columns_right*global_fontwidth,lines_down*global_fontheight);
}

void GEMscrolltext::SetRedrawFont()
{
	global_fontwidth=CharCellWidth();
	global_fontheight=CharCellHeight();

	if (top_aligned) {
		int j;
		st_alignment(0,5,&j,&j); // left-top
	} else {
		int j;
		st_alignment(0,3,&j,&j); // left-bottom
	}
}

void GEMscrolltext::RedrawClipped(int x, int y, const GRect& area)
{
	clip(area.g_x,area.g_y,area.g_x+area.g_w-1,area.g_y+area.g_h-1);

	if (top_aligned) {
		int j=0;
		while (y < area.g_y+area.g_w && j<h) {
			gtext(x,y,textline[j]);
			y+=global_fontheight;
			j++; // 
		}
	} else {
		y+=GEMuserobject::Height();
		int j=h-1;
		while (y >= area.g_y && j>=0) {
			gtext(x,y,textline[j]);
			y-=global_fontheight;
			j--;
		}
	}

	clip_off();
}

void GEMscrolltext::Put(char ch, int x, int y)
{
	textline[y][x]=ch;
	change.Include(x,y);
}

void GEMscrolltext::Refresh()
{
	if (change.Changed()) {
		int fontwidth=CharCellWidth();
		int fontheight=CharCellHeight();

		change.Scale(fontwidth,fontheight);

		if (!top_aligned) {
			change.g_x+=GEMuserobject::Height()-fontheight*h;
		}

		form.RedrawObject(myindex,
			change.g_x,change.g_y,change.g_w,change.g_h);

		change.Clear();
	}
}

void GEMscrolltext::Draw(const PARMBLK* pb)
{
	SetRedrawFont();
	GEMscrollableobject::Draw(pb);
}
