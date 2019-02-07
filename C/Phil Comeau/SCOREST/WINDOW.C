/* window: Library of window-manipulation functions used by ScoreST
 * phil comeau 04-jan-88
 * last edited 11-oct-89 0013
 *
 * Copyright 1988 by Phil Comeau
 * Copyright 1989, 1990 Antic Publishing Inc.
 */

#include <stdio.h>
#include <gemdefs.h>
#include <obdefs.h>
#include <mylib.h>
#include <dialog.h>
#include <graphics.h>
#include "graph.h"
#include "scoredef.h"

#define DESKWINHANDLE 0			/* handle of the desktop window. */
#define CELLSZ 10			/* distance window moves for line &
					 * column movement
					 */
					/* window component mask */
#define WINKIND (CLOSER | NAME | \
    UPARROW | DNARROW | VSLIDE | LFARROW | RTARROW | HSLIDE)

/* Global Variables */
BOOLEAN WinOpen = FALSE;		/* TRUE if the window is opened. */
RECT2D WinScsRct;			/* rectangle describing window work
					 * area in SCS
					 */
RECT2D WinWcsRct;			/* rectangle describing window work
					 * area in WCS
					 */
static RECT2D DeskScsRct;		/* rectangle describing desktop
					 * work area in SCS.
					 */
int WHandle;				/* Window handle */

extern FILE *Debug;

/* createWind: Create a window for use. */
void createWind()
{
	extern RECT2D PalScsRct;

	/* Determine the size of the desktop window. These dimensions
	 * will be used to limit the size of the window we'll use. We'll
	 * limit the window's size to the desktop area minus the rectangle
	 * occupied by the palette. The palette is known to be at the
	 * bottom of the screen.
	 */
	wind_get(DESKWINHANDLE, WF_WORKXYWH, &DeskScsRct.x,
	    &DeskScsRct.y, &DeskScsRct.w, &DeskScsRct.h);

	if ((WHandle = wind_create(WINKIND, DeskScsRct.x,
	    DeskScsRct.y, DeskScsRct.w,
	    DeskScsRct.h - PalScsRct.h)) < 0) {
		Error("Can't create window");
	}
}

/* openWind: Open an existing window, making it visible and usable. Returns
 * success.
 */
BOOLEAN openWind()
{
	extern RECT2D PalScsRct;
	void updtWinTtl();

	/* Set the window's title. */
	updtWinTtl(TRUE);

	/* Initialize the positions of the window's sliders. */
	wind_set(WHandle, WF_VSLIDE, 1);
	wind_set(WHandle, WF_HSLIDE, 1);

	if (wind_open(WHandle, DeskScsRct.x, DeskScsRct.y,
	    DeskScsRct.w, DeskScsRct.h - PalScsRct.h) == 0) {
		Warning("Can't open window");
		return (FALSE);
	}

	/* Obtain the window's SCS rectangle. */
	wind_get(WHandle, WF_WORKXYWH, &WinScsRct.x, &WinScsRct.y,
	    &WinScsRct.w, &WinScsRct.h);

	/* Obtain the window's WCS rectangle. */
	SETRECT(&WinWcsRct, 0, 0, WinScsRct.w, WinScsRct.h);

	/* Calculate the initial thumb sizes. */
	wind_set(WHandle, WF_HSLSIZE, (int)((WinScsRct.w * 1000L) /
	    WCSMAXX));
	wind_set(WHandle, WF_VSLSIZE, (int)((WinScsRct.h * 1000L) /
	    WCSMAXY));

	WinOpen = TRUE;

	return (TRUE);
}

/* clsWind: Close the window. */
void clsWind()
{
	if (WinOpen) {
		wind_close(WHandle);
		WinOpen = FALSE;
	}
}

/* delWind: Delete the window. */
void delWind()
{
	wind_delete(WHandle);
}

/* clrWind: Clear the window. */
void clrWind()
{
	clrRect(&WinScsRct);
}

/* wRedraw: Redraw the window and the icon palette. */
void wRedraw(reDrwRct)
register RECT2D *reDrwRct;
{
	RECT2D wRct;
	void updtWinTtl();
	extern int rect_intersect();
	extern RECT2D PalScsRct;

	/* Hide the mouse and prevent any further updates to the window. */
	hideMouse();
	wind_update(TRUE);

	/* Redraw all window rectangles that intersect with the area to
	 * be redrawn.
	 */
	wind_get(WHandle, WF_FIRSTXYWH, &wRct.x, &wRct.y, &wRct.w,
	    &wRct.h);
	while (wRct.w > 0 && wRct.h > 0) {

		/* Determine if this rectangle intersects with the area to
		 * be redrawn.
		 */
		if (rect_intersect(reDrwRct->x, reDrwRct->y,
		    reDrwRct->w, reDrwRct->h, wRct.x, wRct.y,
		    wRct.w, wRct.h, &wRct)) {
			setClipRct(&wRct);
			setWrtMode(MD_REPLACE);
			drwPg();
		}

		/* Get the next rectangle in the window's rectangle list. */
		wind_get(WHandle, WF_NEXTXYWH, &wRct.x, &wRct.y,
		    &wRct.w, &wRct.h);
	}

	/* Redraw the palette if it intersects with the area to be redrawn.
	 */
	COPYRECT(&PalScsRct, &wRct);
	if (rect_intersect(reDrwRct->x, reDrwRct->y, reDrwRct->w,
	    reDrwRct->h, wRct.x, wRct.y, wRct.w, wRct.h, &wRct)) {
		drwPalette();
	}

	/* The redraw-area has been refreshed. Display the mouse, allow
	 * window updates, and set the clipping rectangle to the desktop
	 * work area.
	 */
	wind_update(FALSE);
	showMouse();
	setClipRct(&DeskScsRct);
	updtWinTtl(FALSE);
}

/* wArrowed: Handle window scrolling */
void wArrowed(action)
register int action;
{
	register int newX, newY, maxX, maxY;
	void wRefresh(), setThumbs();

	/* Respond based on the arrow action. */
	switch (action) {
	case WA_UPPAGE:
		newY = WinWcsRct.y - WinWcsRct.h;
		WinWcsRct.y = MAX(0, newY);
		break;
	case WA_DNPAGE:
		newY = WinWcsRct.y + WinWcsRct.h;
		maxY = MAX(1, WCSMAXY - WinScsRct.h);
		WinWcsRct.y = MIN(maxY, newY);
		break;
	case WA_UPLINE:
		newY = WinWcsRct.y - CELLSZ;
		WinWcsRct.y = MAX(0, newY);
		break;
	case WA_DNLINE:
		newY = WinWcsRct.y + CELLSZ;
		maxY = WCSMAXY - WinScsRct.h;
		WinWcsRct.y = MIN(maxY, newY);
		break;
	case WA_LFPAGE:
		newX = WinWcsRct.x - WinWcsRct.w;
		WinWcsRct.x = MAX(0, newX);
		break;
	case WA_RTPAGE:
		newX = WinWcsRct.x + WinWcsRct.w;
		maxX = MAX(1, WCSMAXX - WinScsRct.w);
		WinWcsRct.x = MIN(maxX, newX);
		break;
	case WA_LFLINE:
		newX = WinWcsRct.x - CELLSZ;
		WinWcsRct.x = MAX(0, newX);
		break;
	case WA_RTLINE:
		newX = WinWcsRct.x + CELLSZ;
		maxX = WCSMAXX - WinScsRct.w;
		WinWcsRct.x = MIN(maxX, newX);
		break;
	}

	setThumbs();

	/* Update the window. */
	wRefresh();
}

/* wTopped: Make the window the top one. */
void wTopped()
{
	wind_set(WHandle, WF_TOP, 0, 0, 0, 0);
}

/* wSlider: Respond to change in one of the window's slider positions. */
void wSlider(sliderPos, sliderTyp)
register int sliderPos, sliderTyp;
{
	void wRefresh(), setThumbs();

	if (sliderTyp == WF_HSLIDE) {
		WinWcsRct.x = ((WCSMAXX - (long)WinScsRct.w) * sliderPos) /
		    1000L;
	}
	else {
		WinWcsRct.y = ((WCSMAXY - (long)WinScsRct.h) * sliderPos) /
		    1000L;
	}

	wind_set(WHandle, sliderTyp, sliderPos);

	setThumbs();

	/* Update the window. */
	wRefresh();
}

/* wRefresh: Redraw the window after a change in its status. */
void wRefresh()
{
	setClipRct(&WinScsRct);
	setWrtMode(MD_REPLACE);
	clrRect(&WinScsRct);
	drwPg();
}

/* updtWinTtl: Update the window title with current information. */
void updtWinTtl(force)
register BOOLEAN force;
{
	char ttl[MAXSTR];
	register int pgNum;
	static char lastFlNm[FILENAMESZ] = '\0';
	static BOOLEAN lastFileDirty = FALSE;
	static int lastPgNum = 0;
	extern BOOLEAN FileDirty;
	extern char FileNm[];
	extern int getCurPgNum();

	pgNum = getCurPgNum();
	if (force ||strcmp(FileNm, lastFlNm) != 0 ||
	    FileDirty != lastFileDirty || pgNum != lastPgNum) {
		sprintf(ttl, "%s%s Page %d", FileDirty ? "(*) " : "", FileNm,
		    pgNum);
		wind_set(WHandle, WF_NAME, ttl, 0, 0);
		strcpy(lastFlNm, FileNm);
		lastFileDirty = FileDirty;
		lastPgNum = pgNum;
	}
}

/* setThumbs:	Establish the thumb sizes, based on the window size in
 *		relation to the world.
 */
void setThumbs()
{
	/* First, make sure WinWcsRct is valid. */
	WinWcsRct.x = MAX(0, WinWcsRct.x);
	WinWcsRct.y = MAX(0, WinWcsRct.y);
	WinWcsRct.x = MIN(WinWcsRct.x, WCSMAXX - WinScsRct.w);
	WinWcsRct.y = MIN(WinWcsRct.y, WCSMAXY - WinScsRct.h);

	/* Recalculate the thumb sizes. */
	wind_set(WHandle, WF_HSLSIZE,
	    (int)((WinScsRct.w * 1000L) / WCSMAXX));
	wind_set(WHandle, WF_VSLSIZE,
	    (int)((WinScsRct.h * 1000L) / WCSMAXY));

	/* Reset the thumb positions. */
	wind_set(WHandle, WF_HSLIDE,
	    (int)((WinWcsRct.x * 1000L) / (WCSMAXX - WinScsRct.w)));
	wind_set(WHandle, WF_VSLIDE,
	    (int)((WinWcsRct.y * 1000L) / (WCSMAXY - WinScsRct.h)));
}

