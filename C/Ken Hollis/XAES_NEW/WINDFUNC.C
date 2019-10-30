/********************************************************************
 *																1.00*
 *	XAES: Enhanced Window Functions									*
 *	by Ken Hollis													*
 *																	*
 *	Copyright (c) 1994, Bitgate Software.  All Rights Reserved.		*
 *																	*
 *	Copy these window routines, and death is imminent.  Currently,	*
 *	these routines only handle the resizing of large window			*
 *	elements.  Small window elements will be added soon.			*
 *																	*
 ********************************************************************/

#include "xaes.h"

#define W_ULSIZE 1   /* BOX dans l'arbre WINDOW */
#define W_PCLOSE 2   /* BOX dans l'arbre WINDOW */
#define W_CLOSER 3   /* BOXTEXT dans l'arbre WINDOW */
#define W_TSIZE  4   /* BOX dans l'arbre WINDOW */
#define W_URSIZE 5   /* BOX dans l'arbre WINDOW */
#define W_PCASC  6   /* BOX dans l'arbre WINDOW */
#define W_FULLER 7   /* BOXTEXT dans l'arbre WINDOW */
#define W_LSIZE  8   /* BOX dans l'arbre WINDOW */
#define W_RSIZE  9   /* BOX dans l'arbre WINDOW */
#define W_LLSIZE 10  /* BOX dans l'arbre WINDOW */
#define W_PSLLT  11  /* BOX dans l'arbre WINDOW */
#define W_SLLT   12  /* BOXTEXT dans l'arbre WINDOW */
#define W_BSIZE  13  /* BOX dans l'arbre WINDOW */
#define W_LRSIZE 14  /* BOX dans l'arbre WINDOW */
#define W_PSLDN  15  /* BOX dans l'arbre WINDOW */
#define W_SLDN   16  /* BOXTEXT dans l'arbre WINDOW */
#define W_MOVER  17  /* BOXTEXT dans l'arbre WINDOW */
#define W_CASCADE 18  /* BOXTEXT dans l'arbre WINDOW */
#define W_MENU   19  /* BOX dans l'arbre WINDOW */
#define W_MENU_L 20  /* BOXTEXT dans l'arbre WINDOW */
#define W_MENU_R 21  /* BOXTEXT dans l'arbre WINDOW */
#define W_INFO   22  /* BOXTEXT dans l'arbre WINDOW */
#define W_INFO_R 23  /* BOXTEXT dans l'arbre WINDOW */
#define W_INFO_L 24  /* BOXTEXT dans l'arbre WINDOW */
#define WORKAREA 25  /* BOXTEXT dans l'arbre WINDOW */
#define W_SLUP   26  /* BOXTEXT dans l'arbre WINDOW */
#define W_VERTRK 27  /* BOX dans l'arbre WINDOW */
#define W_VERSL  28  /* BOX dans l'arbre WINDOW */
#define W_HORTRK 29  /* BOX dans l'arbre WINDOW */
#define W_HORSL  30  /* BOX dans l'arbre WINDOW */
#define W_SLRT   31  /* BOXTEXT dans l'arbre WINDOW */
#define W_OPTION 32  /* BOXTEXT dans l'arbre WINDOW */

#define S_ULSIZE 1   /* BOX dans l'arbre WINDSM */
#define S_CLOSER 3   /* BOXTEXT dans l'arbre WINDSM */
#define S_TSIZE  4   /* BOX dans l'arbre WINDSM */
#define S_URSIZE 5   /* BOX dans l'arbre WINDSM */
#define S_FULLER 7   /* BOXTEXT dans l'arbre WINDSM */
#define S_CASCADE 8   /* BOXTEXT dans l'arbre WINDSM */
#define S_RSIZE  9   /* BOX dans l'arbre WINDSM */
#define S_LRSIZE 10  /* BOX dans l'arbre WINDSM */
#define S_SLDN   12  /* BOXTEXT dans l'arbre WINDSM */
#define S_SLRT   13  /* BOXTEXT dans l'arbre WINDSM */
#define S_BSIZE  14  /* BOX dans l'arbre WINDSM */
#define S_LLSIZE 15  /* BOX dans l'arbre WINDSM */
#define S_SLLT   17  /* BOXTEXT dans l'arbre WINDSM */
#define S_LSIZE  18  /* BOX dans l'arbre WINDSM */
#define S_MOVER  19  /* BOXTEXT dans l'arbre WINDSM */
#define S_MENU   20  /* BOX dans l'arbre WINDSM */
#define S_MENU_L 21  /* BOXTEXT dans l'arbre WINDSM */
#define S_MENU_R 22  /* BOXTEXT dans l'arbre WINDSM */
#define S_INFO   23  /* BOXTEXT dans l'arbre WINDSM */
#define S_INFO_R 24  /* BOXTEXT dans l'arbre WINDSM */
#define S_INFO_L 25  /* BOXTEXT dans l'arbre WINDSM */
#define S_OPTIONS 26  /* BOXTEXT dans l'arbre WINDSM */
#define S_UP     27  /* BOXTEXT dans l'arbre WINDSM */
#define S_VERTRK 28  /* BOX dans l'arbre WINDSM */
#define S_VERSL  29  /* BOX dans l'arbre WINDSM */
#define S_HORTRK 30  /* BOX dans l'arbre WINDSM */
#define S_HORSL  31  /* BOX dans l'arbre WINDSM */
#define S_WORK   32  /* BOXTEXT dans l'arbre WINDSM */

GLOBAL void WFixSize(WINDOW *win)
{
	if (win)
		if (win->style & W_CUSTOMWINDOW) {
			win->wind->ob_x				= win->size.g_x;
			win->wind->ob_y				= win->size.g_y;
			win->wind->ob_width			= win->size.g_w;
			win->wind->ob_height		= win->size.g_h;

			win->wind[W_ULSIZE].ob_x	= 0;
			win->wind[W_ULSIZE].ob_y 	= 0;
			win->wind[W_CLOSER].ob_x	= 0;
			win->wind[W_CLOSER].ob_y	= 0;
			win->wind[W_PCLOSE].ob_x	= win->wind[W_ULSIZE].ob_width - win->wind[W_PCLOSE].ob_width;
			win->wind[W_PCLOSE].ob_y	= win->wind[W_ULSIZE].ob_height - win->wind[W_PCLOSE].ob_height;
			win->wind[W_URSIZE].ob_x	= win->wind->ob_width - win->wind[W_URSIZE].ob_width;
			win->wind[W_URSIZE].ob_y	= 0;
			win->wind[W_FULLER].ob_x	= 0;
			win->wind[W_FULLER].ob_y	= 0;
			win->wind[W_PCASC].ob_x		= 0;
			win->wind[W_PCASC].ob_y		= win->wind[W_URSIZE].ob_height - win->wind[W_PCASC].ob_height;
			win->wind[W_TSIZE].ob_x		= win->wind[W_ULSIZE].ob_width - 1;
			win->wind[W_TSIZE].ob_y		= 0;
			win->wind[W_TSIZE].ob_width	= win->wind->ob_width - win->wind[W_ULSIZE].ob_width - win->wind[W_URSIZE].ob_width + 2;
			win->wind[W_CASCADE].ob_x	= win->wind->ob_width - win->wind[W_URSIZE].ob_width - win->wind[W_CASCADE].ob_width + 1;
			win->wind[W_CASCADE].ob_y	= win->wind[W_TSIZE].ob_height - 1;
			win->wind[W_MOVER].ob_x		= win->wind[W_ULSIZE].ob_width - 1;
			win->wind[W_MOVER].ob_y		= win->wind[W_TSIZE].ob_height - 1;
			win->wind[W_MOVER].ob_width	= win->wind->ob_width - win->wind[W_ULSIZE].ob_width - win->wind[W_URSIZE].ob_width - win->wind[W_CASCADE].ob_width + 3;
			win->wind[W_LLSIZE].ob_x	= 0;
			win->wind[W_LLSIZE].ob_y	= win->wind->ob_height - win->wind[W_LLSIZE].ob_height;
			win->wind[W_LSIZE].ob_x		= 0;
			win->wind[W_LSIZE].ob_y		= win->wind[W_ULSIZE].ob_height - 1;
			win->wind[W_LSIZE].ob_height= win->wind->ob_height - win->wind[W_LLSIZE].ob_height - win->wind[W_ULSIZE].ob_height + 2;
			win->wind[W_LRSIZE].ob_x	= win->wind->ob_width - win->wind[W_LRSIZE].ob_width;
			win->wind[W_LRSIZE].ob_y	= win->wind->ob_height - win->wind[W_LRSIZE].ob_height;
			win->wind[W_RSIZE].ob_x		= win->wind->ob_width - win->wind[W_RSIZE].ob_width;
			win->wind[W_RSIZE].ob_y		= win->wind[W_URSIZE].ob_height - 1;
			win->wind[W_RSIZE].ob_height= win->wind->ob_height - win->wind[W_LRSIZE].ob_height - win->wind[W_URSIZE].ob_height + 2;
			win->wind[W_BSIZE].ob_x		= win->wind[W_LLSIZE].ob_width - 1;
			win->wind[W_BSIZE].ob_y		= win->wind->ob_height - win->wind[W_BSIZE].ob_height;
			win->wind[W_BSIZE].ob_width	= win->wind->ob_width - win->wind[W_LLSIZE].ob_width - win->wind[W_LRSIZE].ob_width + 2;
			win->wind[W_MENU].ob_x		= win->wind[W_LSIZE].ob_width - 1;
			win->wind[W_MENU].ob_y		= win->wind[W_TSIZE].ob_height + win->wind[W_MOVER].ob_height - 2;
			win->wind[W_MENU].ob_width	= win->wind->ob_width - win->wind[W_LSIZE].ob_width - win->wind[W_RSIZE].ob_width + 2;
			win->wind[W_MENU_L].ob_x	= 0;
			win->wind[W_MENU_L].ob_y	= 0;
			win->wind[W_MENU_R].ob_x	= win->wind[W_MENU_L].ob_width - 1;
			win->wind[W_MENU_R].ob_y	= 0;
			win->wind[W_INFO].ob_x		= win->wind[W_LSIZE].ob_width - 1;
			win->wind[W_INFO].ob_y		= win->wind[W_TSIZE].ob_height + win->wind[W_MOVER].ob_height + win->wind[W_MENU].ob_height - 3;
			win->wind[W_INFO].ob_width	= win->wind->ob_width - win->wind[W_LSIZE].ob_width - win->wind[W_RSIZE].ob_width - win->wind[W_OPTION].ob_width + 3;
			win->wind[W_INFO_L].ob_x	= 0;
			win->wind[W_INFO_L].ob_y	= 0;
			win->wind[W_INFO_R].ob_x	= win->wind[W_INFO_L].ob_width - 1;
			win->wind[W_INFO_R].ob_y	= 0;
			win->wind[W_OPTION].ob_x	= win->wind->ob_width - win->wind[W_RSIZE].ob_width - win->wind[W_OPTION].ob_width + 1;
			win->wind[W_OPTION].ob_y	= win->wind[W_TSIZE].ob_height + win->wind[W_MOVER].ob_height + win->wind[W_MENU].ob_height - 3;
			win->wind[W_PSLLT].ob_x		= win->wind[W_LLSIZE].ob_width - win->wind[W_PSLLT].ob_width;
			win->wind[W_PSLLT].ob_y		= 0;
			win->wind[W_SLLT].ob_x		= 0;
			win->wind[W_SLLT].ob_y		= 0;
			win->wind[W_SLRT].ob_x		= win->wind->ob_width - win->wind[W_LRSIZE].ob_width - win->wind[W_SLRT].ob_width + 1;
			win->wind[W_SLRT].ob_y		= win->wind->ob_height - win->wind[W_BSIZE].ob_height - win->wind[W_SLRT].ob_height + 1;
			win->wind[W_HORTRK].ob_x	= win->wind[W_LLSIZE].ob_width - 1;
			win->wind[W_HORTRK].ob_y	= win->wind->ob_height - win->wind[W_BSIZE].ob_height - win->wind[W_HORTRK].ob_height + 1;
			win->wind[W_HORTRK].ob_width= win->wind->ob_width - win->wind[W_LLSIZE].ob_width - win->wind[W_LRSIZE].ob_width - win->wind[W_SLRT].ob_width + 3;
			win->wind[W_SLUP].ob_x		= win->wind->ob_width - win->wind[W_RSIZE].ob_width - win->wind[W_SLUP].ob_width + 1;
			win->wind[W_SLUP].ob_y		= win->wind[W_URSIZE].ob_height + win->wind[W_MENU].ob_height + win->wind[W_OPTION].ob_height - 4;
			win->wind[W_PSLDN].ob_x		= 0;
			win->wind[W_PSLDN].ob_y		= 0;
			win->wind[W_SLDN].ob_x		= 0;
			win->wind[W_SLDN].ob_y		= 0;
			win->wind[W_VERTRK].ob_x	= win->wind->ob_width - win->wind[W_RSIZE].ob_width - win->wind[W_VERTRK].ob_width + 1;
			win->wind[W_VERTRK].ob_y	= win->wind[W_URSIZE].ob_height + win->wind[W_MENU].ob_height + win->wind[W_OPTION].ob_height + win->wind[W_SLUP].ob_height - 5;
			win->wind[W_VERTRK].ob_height=	win->wind->ob_height - win->wind[W_LRSIZE].ob_height - win->wind[W_URSIZE].ob_height - win->wind[W_INFO].ob_height -
											win->wind[W_MENU].ob_height - win->wind[W_SLUP].ob_height + 6;
			win->wind[W_VERSL].ob_x		= 0;
			win->wind[W_VERSL].ob_y		= 0;
			win->wind[W_VERSL].ob_height= win->wind[W_VERTRK].ob_height;
			win->wind[W_HORSL].ob_x		= 0;
			win->wind[W_HORSL].ob_y		= 0;
			win->wind[W_HORSL].ob_width	= win->wind[W_HORTRK].ob_width;
			win->wind[WORKAREA].ob_x	= win->wind[W_LSIZE].ob_width - 1;
			win->wind[WORKAREA].ob_y	= win->wind[W_TSIZE].ob_height + win->wind[W_MOVER].ob_height + win->wind[W_INFO].ob_height + win->wind[W_MENU].ob_height - 4;

			win->wind[WORKAREA].ob_width= win->wind->ob_width - win->wind[W_LSIZE].ob_width - win->wind[W_RSIZE].ob_width - win->wind[W_VERTRK].ob_width + 3;
			win->wind[WORKAREA].ob_height=	win->wind->ob_height - win->wind[W_BSIZE].ob_height - win->wind[W_HORTRK].ob_height - win->wind[W_TSIZE].ob_height -
											win->wind[W_MOVER].ob_height - win->wind[W_INFO].ob_height - win->wind[W_MENU].ob_height + 6;

			if (win->kind & CLOSER)
				win->wind[W_CLOSER].ob_flags &= ~HIDETREE;

			if (!(win->kind & CLOSER)) {
				win->wind[W_CLOSER].ob_flags |= HIDETREE;
				win->wind[W_MOVER].ob_x -= win->wind[W_CLOSER].ob_width - 1;
				win->wind[W_MOVER].ob_width += win->wind[W_CLOSER].ob_width - 1;
			}

			if (win->kind & CASCADE)
				win->wind[W_CASCADE].ob_flags &= ~HIDETREE;

			if (!(win->kind & CASCADE)) {
				win->wind[W_CASCADE].ob_flags |= HIDETREE;
				win->wind[W_MOVER].ob_width += win->wind[W_CASCADE].ob_width - 1;
			}

			if (win->kind & FULLER)
				win->wind[W_FULLER].ob_flags &= ~HIDETREE;

			if (!(win->kind & FULLER)) {
				win->wind[W_FULLER].ob_flags |= HIDETREE;
				win->wind[W_CASCADE].ob_x += win->wind[W_CASCADE].ob_width - 1;
				win->wind[W_MOVER].ob_width += win->wind[W_FULLER].ob_width - 1;
			}

			if (win->state & W_UNSIZABLE)
				win->wind[W_FULLER].ob_state |= DISABLED;

			if (!(win->state & W_UNSIZABLE))
				win->wind[W_FULLER].ob_state &= ~DISABLED;

			if (win->kind & MENUWORK)
				win->wind[W_MENU].ob_flags &= ~HIDETREE;

			if (!(win->kind & MENUWORK)) {
				win->wind[W_MENU].ob_flags |= HIDETREE;
				win->wind[W_INFO].ob_y = win->wind[W_TSIZE].ob_height + win->wind[W_MOVER].ob_height - 2;
				win->wind[W_OPTION].ob_y = win->wind[W_TSIZE].ob_height + win->wind[W_MOVER].ob_height - 2;
				win->wind[WORKAREA].ob_y = win->wind[W_TSIZE].ob_height + win->wind[W_MOVER].ob_height + win->wind[W_INFO].ob_height - 3;
				win->wind[W_SLUP].ob_y = win->wind[W_URSIZE].ob_height + win->wind[W_OPTION].ob_height - 2;
				win->wind[W_VERTRK].ob_y = win->wind[W_URSIZE].ob_height + win->wind[W_OPTION].ob_height + win->wind[W_SLUP].ob_height - 3;
				win->wind[W_VERTRK].ob_height += win->wind[W_MENU].ob_height - 1;
				win->wind[W_VERSL].ob_height = win->wind[W_VERTRK].ob_height;
				win->wind[WORKAREA].ob_height += win->wind[W_MENU].ob_height - 1;
			}

			if (win->kind & INFO)
				win->wind[W_INFO].ob_flags &= ~HIDETREE;

			if (!(win->kind & INFO)) {
				win->wind[W_INFO].ob_flags |= HIDETREE;
				win->wind[W_OPTION].ob_y -= win->wind[W_OPTION].ob_height - 1;
				win->wind[WORKAREA].ob_y -= win->wind[W_INFO].ob_height - 1;
				win->wind[W_SLUP].ob_y -= win->wind[W_INFO].ob_height - 1;
				win->wind[W_VERTRK].ob_y -= win->wind[W_INFO].ob_height - 1;
				win->wind[W_VERTRK].ob_height += win->wind[W_INFO].ob_height - 1;
				win->wind[W_VERSL].ob_height = win->wind[W_VERTRK].ob_height;
				win->wind[WORKAREA].ob_height += win->wind[W_INFO].ob_height - 1;

				ChangeObjectText(win->wind, W_INFO, (char *) win->info, 3, TE_LEFT);
			}

			if (win->kind & UPARROW)
				win->wind[W_SLUP].ob_flags &= ~HIDETREE;

			if (win->kind & DNARROW)
				win->wind[W_SLDN].ob_flags &= ~HIDETREE;

			if (win->kind & VSLIDE)
				win->wind[W_VERTRK].ob_flags &= ~HIDETREE;

			if (!(win->kind & UPARROW))
				win->wind[W_SLUP].ob_flags |= HIDETREE;

			if (!(win->kind & DNARROW))
				win->wind[W_SLDN].ob_flags |= HIDETREE;

			if (!(win->kind & VSLIDE))
				win->wind[W_VERTRK].ob_flags |= HIDETREE;

			if (!(win->kind & (UPARROW|DNARROW|VSLIDE))) {
				win->wind[WORKAREA].ob_width += win->wind[W_VERTRK].ob_width - 1;
				win->wind[W_SLRT].ob_x += win->wind[W_SLDN].ob_width - 1;
				win->wind[W_HORTRK].ob_width += win->wind[W_SLDN].ob_width - 1;
				win->wind[W_HORSL].ob_width = win->wind[W_HORTRK].ob_width;
			}

			if (win->kind & OPTIONS)
				win->wind[W_OPTION].ob_flags &= ~HIDETREE;

			if (!(win->kind & OPTIONS)) {
				win->wind[W_OPTION].ob_flags |= HIDETREE;
				win->wind[W_INFO].ob_width += win->wind[W_OPTION].ob_width - 1;
			}

			if (win->kind & LFARROW)
				win->wind[W_SLLT].ob_flags &= ~HIDETREE;

			if (win->kind & RTARROW)
				win->wind[W_SLRT].ob_flags &= ~HIDETREE;

			if (win->kind & HSLIDE)
				win->wind[W_HORTRK].ob_flags &= ~HIDETREE;

			if (!(win->kind & LFARROW))
				win->wind[W_SLLT].ob_flags |= HIDETREE;

			if (!(win->kind & RTARROW))
				win->wind[W_SLRT].ob_flags |= HIDETREE;

			if (!(win->kind & HSLIDE))
				win->wind[W_HORTRK].ob_flags |= HIDETREE;

			if (!(win->kind & (LFARROW|RTARROW|HSLIDE)))
				win->wind[WORKAREA].ob_height += win->wind[W_HORTRK].ob_height - 1;

			if (win->kind & MOVER)
				win->wind[W_MOVER].ob_state &= ~DISABLED;

			if (!(win->kind & MOVER))
				win->wind[W_MOVER].ob_state |= DISABLED;
		}
}

GLOBAL void WWindAdjust(WINDOW *win)
{
	if (win) {
		if (win->tree) {
			if ((win->wind_type == WC_WINDOW) && (win->style & W_CUSTOMWINDOW)) {
				win->wind[25].ob_width = win->tree->ob_width - 3;
				win->wind[25].ob_height= win->tree->ob_height - 4;

				win->size.g_w = win->wind[W_LSIZE].ob_width +
								win->wind[WORKAREA].ob_width +
								win->wind[W_VERTRK].ob_width +
								win->wind[W_RSIZE].ob_width;
				win->size.g_h = win->wind[W_URSIZE].ob_height +
								win->wind[W_INFO].ob_height +
								win->wind[W_MENU].ob_height +
								win->wind[WORKAREA].ob_height +
								win->wind[W_LRSIZE].ob_height;

				if (!(win->kind & MENUWORK))
					win->size.g_h -= win->wind[W_MENU].ob_height - 1;

				if (!(win->kind & (UPARROW|DNARROW|VSLIDE)))
					win->size.g_w -= win->wind[W_VERTRK].ob_width - 1;

				if (!(win->kind & (LFARROW|RTARROW|HSLIDE)))
					win->size.g_h -= win->wind[W_HORTRK].ob_height - 1;

				if (!(win->kind & INFO))
					win->size.g_h -= win->wind[W_INFO].ob_height - 1;
			}
		}

	/* Haha..  I won't even let you open a window larger than the
	   physical screen size! */
		if ((win->size.g_w > desk.g_w) ||
			(win->size.g_h > desk.g_h)) {
			win->size.g_w = desk.g_w - win->size.g_x;
			win->size.g_h = desk.g_h - win->size.g_y;

			if (win->style & W_CUSTOMWINDOW) {
				if (win->wind_type == WC_WINDOW) {
					win->wind[W_SLLT].ob_flags &= ~HIDETREE;
					win->wind[W_SLRT].ob_flags &= ~HIDETREE;
					win->wind[W_SLUP].ob_flags &= ~HIDETREE;
					win->wind[W_SLDN].ob_flags &= ~HIDETREE;
					win->wind[W_VERTRK].ob_flags &= ~HIDETREE;
					win->wind[W_HORTRK].ob_flags &= ~HIDETREE;
					win->wind[W_VERSL].ob_flags &= ~HIDETREE;
					win->wind[W_HORSL].ob_flags &= ~HIDETREE;
				}

				if (win->wind_type == WC_SWINDOW) {
					win->wind[S_SLLT].ob_flags &= ~HIDETREE;
					win->wind[S_SLRT].ob_flags &= ~HIDETREE;
					win->wind[S_UP].ob_flags &= ~HIDETREE;
					win->wind[S_SLDN].ob_flags &= ~HIDETREE;
					win->wind[S_VERTRK].ob_flags &= ~HIDETREE;
					win->wind[S_HORTRK].ob_flags &= ~HIDETREE;
					win->wind[S_VERSL].ob_flags &= ~HIDETREE;
					win->wind[S_HORSL].ob_flags &= ~HIDETREE;
				}
			}
		}

		win->minimum.g_x = win->size.g_x;
		win->minimum.g_y = win->size.g_y;
		win->minimum.g_w = win->size.g_w;
		win->minimum.g_h = win->size.g_h;
	}
}

GLOBAL void WMoveWindow(WINDOW *win, int x, int y, int w, int h)
{
	int wx, wy, ww, wh, ox, oy, ow, oh, x1, y1, w1, h1;
	int tophandle;

	if ((win) && (win->handle != 0))
		if (win->state & W_OPEN) {
			wind_get(win->handle, WF_CURRXYWH, &wx, &wy, &ww, &wh);
			WWindGet(win, WF_TOP, &tophandle);

			if (tophandle != 0) {
				x1 = wx;
				y1 = wy;
				w1 = ww;
				h1 = wh;

				x = (x == -1) ? wx : (win->size.g_x = x);
				y = (y == -1) ? wy : (win->size.g_y = y);

				if ((win->state & W_ICONIFIED) && (win->iconify)) {
					w = win->iconify->ob_width;
					h = win->iconify->ob_height;
				} else {
					w = (w == -1) ? ww : w;
					h = (h == -1) ? wh : h;
				}

				ox = x;
				oy = y;
				ow = w;
				oh = h;

				if (win->state & W_MINIMIZED)
					if (w != ww || h != wh )
						win->state &= ~W_MINIMIZED;
					else {
						int dummy, height;

						wind_get(win->handle, WF_WORKXYWH, &dummy, &dummy, &dummy, &height);
						if (h > wh - height)
							h = wh - height;
					}

				if (!(win->state & W_MINIMIZED))
					if ((win->state & W_ICONIFIED) && (win->iconify)) {
						win->size.g_w = win->iconify->ob_width;
						win->size.g_h = win->iconify->ob_height;
					} else {
						win->size.g_w = w;
						win->size.g_h = h;
					}

				if ((win->size.g_w < win->minimum.g_w) ||
					(win->size.g_w > win->maximum.g_w)) {
					win->size.g_w = win->minimum.g_w;
					w = w1 = ow = win->size.g_w;
				}

				if ((win->size.g_h < win->minimum.g_h) ||
					(win->size.g_h > win->maximum.g_h)) {
					win->size.g_h = win->minimum.g_h;
					h = h1 = oh = win->size.g_h;
				}

				if (!(xaes.config1 & X_LEFTBORDER))
					if ((x != 1) && (x < -1))
						x = 0;

				if ((win->state & W_ICONIFIED) && (win->iconify))
					if (x != wx || y != wy)
						wind_set(win->handle, WF_CURRXYWH, x, y, win->iconify->ob_width, win->iconify->ob_height + 13);

				if (!(win->state & W_ICONIFIED))
					if (x != wx || y != wy || w != ww || h != wh) /* If either parameter has changed... */
						wind_set(win->handle, WF_CURRXYWH, x, y, w, h);	/* Move window */

				wind_get(win->handle, WF_WORKXYWH, &x, &y, &w, &h);

				if ((win->wind) && (win->style & W_CUSTOMWINDOW)) {
					win->wind->ob_x = x - (win->wind->ob_type & 0xff00 ? win->wind->ob_spec.obspec.framesize : 0);
					win->wind->ob_y = y - (win->wind->ob_type & 0xff00 ? win->wind->ob_spec.obspec.framesize : 0);

					win->wind->ob_x--;
					win->wind->ob_y--;
				}

				if (((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify : win->tree)) && (win->style & W_CUSTOMWINDOW))
					if ((win->state & W_ICONIFIED) && (win->iconify)) {
						win->iconify->ob_x = (x + win->wind[WORKAREA].ob_x) - (win->iconify->ob_type & 0xFF00 ? win->iconify->ob_spec.obspec.framesize + 1 : 1);
						win->iconify->ob_y = (y + win->wind[WORKAREA].ob_y) - (win->iconify->ob_type & 0xFF00 ? win->iconify->ob_spec.obspec.framesize + 1 : 1);
					} else {						
						win->tree->ob_x = (x + win->wind[WORKAREA].ob_x) - (win->tree->ob_type & 0xff00 ? win->tree->ob_spec.obspec.framesize + 1 : 1);
						win->tree->ob_y = (y + win->wind[WORKAREA].ob_y) - (win->tree->ob_type & 0xff00 ? win->tree->ob_spec.obspec.framesize + 1 : 1);
					}
				else if ((((win->state & W_ICONIFIED) && (win->iconify)) ? win->iconify : win->tree))
					if ((win->state & W_ICONIFIED) && (win->iconify)) {
						win->iconify->ob_x = x - (win->iconify->ob_type & 0xFF00 ? win->iconify->ob_spec.obspec.framesize + 1 : 1);
						win->iconify->ob_y = y - (win->iconify->ob_type & 0xFF00 ? win->iconify->ob_spec.obspec.framesize + 1 : 1);
					} else {
						win->tree->ob_x = x - (win->tree->ob_type & 0xff00 ? win->tree->ob_spec.obspec.framesize + 1 : 1);
						win->tree->ob_y = y - (win->tree->ob_type & 0xff00 ? win->tree->ob_spec.obspec.framesize + 1 : 1);
					}

				if (((ox == x1) && (oy == y1) && (ow < w1) && (oh < h1)) ||
					((ox == x1) && (oy == y1) && (ow == w1) && (oh < h1)) ||
					((ox == x1) && (oy == y1) && (ow < w1) && (oh == h1))) {
					int x2, y2, w2, h2;

					if (win->handle == tophandle) {
						wind_get(win->handle, WF_WORKXYWH, &x2, &y2, &w2, &h2);
						WRedrawWindow(win, x2, y2, w2, h2);
					}
				}

				if ((win->handle != 0) && (win->style & W_CUSTOMWINDOW) && (win->wind)) {
					WFixSize(win);
					WFixWindow(win);
				}

				win->minimum.g_x = win->size.g_x;
				win->minimum.g_y = win->size.g_y;
			}
		}
}