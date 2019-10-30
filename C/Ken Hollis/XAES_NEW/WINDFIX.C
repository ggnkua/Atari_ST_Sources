/********************************************************************
 *																0.01*
 *	XAES: Fix window size according to enabled elements				*
 *	by Ken Hollis													*
 *																	*
 *	Copyright (c) 1994, Bitgate Software.  All Rights Reserved.		*
 *																	*
 *	ARGH!  Another two line routine!								*
 *																	*
 ********************************************************************/

#include "xaes.h"

GLOBAL void WFixWindow(WINDOW *win)
{
	if (win)
		ChangeObjectText(win->wind, 17, (char *) win->title, 3, TE_CNTR);
}