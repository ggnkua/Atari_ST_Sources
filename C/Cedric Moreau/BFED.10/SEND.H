/*
	file: search.h
	utility: header file of send.c
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
	comments: 
*/
#ifndef SEND_H
#define SEND_H

#include "wind.h"	/* defs for windowptr */

extern void send_vslid(windowptr	thewin);
extern void send_redraw(windowptr	thewin);
extern void immed_redraw(windowptr thewin);
extern void send_arrow(windowptr	thewin,int direction);
extern void send_redraw_all(void);

#endif