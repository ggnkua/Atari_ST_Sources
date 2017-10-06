/////////////////////////////////////////////////////////////////////////////
//
//  GEMscrolltext
//
//  A GEMscrolltext is a GEMcanvas of a scrolling single-font text.
//
//  This file is Copyright 1993,1994 by Warwick W. Allison,
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////


#ifndef GEMst_h
#define GEMst_h

#include <gemc.h>
#include <gemcha.h>

class GEMformwindow;

class GEMscrolltext : public GEMcanvas {
public:
	// NB: It only works in GEMformwindow, not GEMforms, since it
	//     usees the focus features of GEMformwindow.
	//
	GEMscrolltext(GEMformwindow&, int RSCindex); // Width/height from size.
	GEMscrolltext(GEMformwindow&, int RSCindex, int width, int height);
	~GEMscrolltext();

	int TextWidth() { return width; }
	int TextHeight() { return height; }

	void Cursor(int x, int y);
	void Put(char);
	void Put(char*);
	char CharAt(int x, int y) { return textline[y][x]; }

	// TTY operations
	void CarriageReturn();
	void DeleteChar();
	void Backspace();
	void CursorLeft();
	void CursorRight();
	void CursorUp();
	void CursorDown();
	void CursorToEndOfLine();
	void CursorToStartOfLine();
	void Home();
	void End();
	void ClearHome();

	void AutoRefresh(bool yes); // Default=yes.  Turn off for bulk update.
	void Refresh(); // Manual update.

	//void ScrollText(int columns_right, int lines_down);

	void AlignAtBottom(bool yes=true); // AlignBottom(false) initially.

	// Call this if you change it's font.
	void FontChanged();

protected:
	virtual int DrawAt(int x, int y, const GRect& area);
	virtual GEMfeedback Touch(int x, int y, const GEMevent& e); // KEYS too.
	virtual void InFocus(bool yes);

	void PixelToCharacter(int x, int y, int& cx, int& cy);

private:
	void Init(int w, int h);
	int width,height;
	bool bottom_aligned;
	GEMchangearea change;
	char** textline;
	int fontwidth;
	int fontheight;
	bool auto_refresh;
	bool in_focus;
	int cursorx,cursory;
};


#endif
