/********************************************************************
 *																0.01*
 *	XAES: Windowed object draw routine								*
 *																	*
 *	Copyright (C) 1994, Bitgate Software							*
 *																	*
 ********************************************************************/

#include "xaes.h"

GLOBAL void WObjc_Draw(WINDOW *win, int x, int y, int w, int h)
{
	if (win)
		objc_draw((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify : win->tree), win->edobject, 2, x, y, w, h);
}

GLOBAL void WObjc_Draw_Out(WINDOW *win, int x, int y, int w, int h)
{
	if (win)
		objc_draw((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify : win->tree), 0, 2, x, y, w, h);
}