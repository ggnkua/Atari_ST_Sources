/********************************************************************
 *																0.10*
 *	XAES: Tools module												*
 *																	*
 *	Copyright (C) 1994, Bitgate Software							*
 *																	*
 *	Only ONE tool to use?  Can't optimize much of that...			*
 *																	*
 ********************************************************************/

#include "xaes.h"

GLOBAL void WRedrawAllWindows(void)
{
	WINDOW *win = WindowChain;

	while (win->next) {
		win = win->next;
		WRedrawWindow(win->prev, win->prev->size.g_x,
						win->prev->size.g_y, win->prev->size.g_w,
						win->prev->size.g_h);
	}
}
