/////////////////////////////////////////////////////////////////////////////
//
//  GEMscrolltext
//
//  A GEMscrolltext is a GEMscrollableobject scrolling single-font text.
//
//  This file is Copyright 1993 by Warwick W. Allison,
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////


#ifndef GEMst_h
#define GEMst_h

#include <gemscro.h>
#include <gemcha.h>

class GEMscrolltext : public GEMscrollableobject {
public:
	GEMscrolltext(GEMform&, int RSCindex, int width, int height);
	~GEMscrolltext();

	int TextWidth() { return w; }
	int TextHeight() { return h; }

	void Put(char, int x, int y);
	char CharAt(int x, int y) { return textline[y][x]; }
	void Refresh();

	void ScrollText(int columns_right, int lines_down);
	virtual void RedrawClipped(int x, int y, const GRect&);

	void AlignAtTop(bool yes=TRUE); // AlignTop(FALSE) initially.
	virtual void Draw(const PARMBLK*);

private:
	void SetRedrawFont();
	int w,h;
	bool top_aligned;
	GEMchangearea change;
	char** textline;
};


#endif
