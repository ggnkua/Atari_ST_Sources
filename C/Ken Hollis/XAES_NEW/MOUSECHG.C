/********************************************************************
 *																0.01*
 *	XAES: Mouse changing routine for special window elements		*
 *	by Ken Hollis													*
 *																	*
 *	Copyright (C) 1994, Bitgate Software.  All Rights Reserved.		*
 *																	*
 ********************************************************************/

#define W_ULSIZE 1   /* BOX dans l'arbre WINDOW */
#define W_TSIZE  4   /* BOX dans l'arbre WINDOW */
#define W_URSIZE 5   /* BOX dans l'arbre WINDOW */
#define W_LSIZE  8   /* BOX dans l'arbre WINDOW */
#define W_RSIZE  9   /* BOX dans l'arbre WINDOW */
#define W_LLSIZE 10  /* BOX dans l'arbre WINDOW */
#define W_BSIZE  13  /* BOX dans l'arbre WINDOW */
#define W_LRSIZE 14  /* BOX dans l'arbre WINDOW */
#define W_MOVER  17  /* BOXTEXT dans l'arbre WINDOW */
#define WORKAREA 25  /* BOXTEXT dans l'arbre WINDOW */
#define W_VERTRK 27  /* BOX dans l'arbre WINDOW */
#define W_VERSL  28  /* BOX dans l'arbre WINDOW */
#define W_HORTRK 29  /* BOX dans l'arbre WINDOW */
#define W_HORSL  30  /* BOX dans l'arbre WINDOW */

#include "xaes.h"

GLOBAL void WChangeMouseElement(WINDOW *win, int object)
{
	if (win)
		if (win->wind)
			switch(object) {
				case W_ULSIZE:
					WGrafMouse(ULMOVE_MOUSE);
					break;

				case W_TSIZE:
					WGrafMouse(TSIZER_MOUSE);
					break;

				case W_URSIZE:
					WGrafMouse(URMOVE_MOUSE);
					break;

				case W_LSIZE:
					WGrafMouse(LSIZER_MOUSE);
					break;

				case W_RSIZE:
					WGrafMouse(RSIZER_MOUSE);
					break;

				case W_LLSIZE:
					WGrafMouse(LLMOVE_MOUSE);
					break;

				case W_BSIZE:
					WGrafMouse(BSIZER_MOUSE);
					break;

				case W_LRSIZE:
					WGrafMouse(LRMOVE_MOUSE);
					break;

				case W_MOVER:
					WGrafMouse(MOVER_MOUSE);
					break;

				case W_VERTRK:
				case W_VERSL:
					WGrafMouse(UDSLIDE_MOUSE);
					break;

				case W_HORTRK:
				case W_HORSL:
					WGrafMouse(LRSLIDE_MOUSE);
					break;

				case OUTSIDE_DIALOG:
					WGrafMouse(NOWINDOW_MOUSE);
					break;

				case WORKAREA:
					if ((cur_mouse_form != TEXT_CRSR) && (cur_mouse_form != IBARHELP_MOUSE))
						WGrafMouse(ARROW);
					break;

				default:
					WGrafMouse(ARROW);
					break;
			}

	if (win->handle == 0)
		WGrafMouse(NOWINDOW_MOUSE);
}
