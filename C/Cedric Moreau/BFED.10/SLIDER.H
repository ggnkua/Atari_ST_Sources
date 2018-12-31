/*
	file: slider.c
	utility: header file of slider.c
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
	comments: 
*/
#ifndef SLIDER_H
#define SLIDER_H

#include "wind.h"

extern void vhandler(const int *message, const windowptr thewin);
extern void redraw_vslider(const windowptr thewin);

#endif