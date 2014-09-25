/*
	stwin.c

	LandMines Windows handler

	Copyright 1991 K.Soohoo
	Created: April 18, 1991 K.Soohoo
	Modified from stwin.c for STTRANS: April 14, 1992
*/

#include <gemdefs.h>		/* Lotta includes... */
#include <obdefs.h>
#include <osbind.h>
#include <aesbind.h>
#include <bios.h>
#include <xbios.h>
#include <stat.h>
#include <stdio.h>

extern void redraw_board(/* int rx, int ry, int rw, int rh */);

extern int SCw, SCh;
extern int board_x, board_y;		/* Board location */
extern int board_width, board_height;	/* Board size in cells */
extern int cell_x, cell_y;		/* Size of cells in pixels */

int fullx, fully, fullw, fullh;		/* Screen's biggest size */
int currx, curry, currw, currh; 	/* Current coordinates */
int innerx, innery, innerw, innerh;

char mines_title[80] = "Landmine";
char mines_status[80] = "";
int window_attrib = NAME | CLOSER | MOVER | INFO;

int new_window()
/*
	New window creator.
*/
{
	int whandle;

	wind_get(0, WF_FULLXYWH, &fullx, &fully, &fullw, &fullh);
	whandle = wind_create(window_attrib, fullx, fully, fullw, fullh);
	if (whandle < 0) return -1;

	wind_set(whandle, WF_NAME, mines_title, 0, 0, 0);
	wind_set(whandle, WF_INFO, mines_status, 0, 0, 0);

	/* Assign the inner width and height */
	currw = board_width * cell_x;
	currh = board_height * cell_y;

	wind_calc(WC_BORDER, window_attrib,
		  currx, curry, currw, currh, 
		  &innerx, &innery, &currw, &currh);

	/* Open the window */
	if ((currx + currw) >= SCw) {
		currx = SCw - currw - 1;
	}
	if ((curry + currh) >= SCh) {
		curry = SCh - currh - 1;
	}

	form_dial(FMD_GROW, fullx, fully, 20, 20, currx, curry, currw, currh);
	wind_open(whandle, currx, curry, currw, currh);

	wind_get(whandle, WF_WORKXYWH, &innerx, &innery, &innerw, &innerh);

	board_x = innerx;
	board_y = innery;

	return(whandle);
}

void redraw_event(window, box)
int window;
GRECT *box;
/* redraw_event(window, box)
   If a screen redraw is requested, due to window overlap, then this
   catches the event and replaces the inner drawing with whatever should
   be there.
 */
{
	GRECT area;

	wind_get(window, WF_FIRSTXYWH, &area.g_x, &area.g_y, 
			&area.g_w, &area.g_h);

	graf_mouse(M_OFF, 0);
	while((area.g_w != 0) && (area.g_h != 0)) {
		if (rc_intersect(box, &area)){
			/* Draw whatever should be inside the window */

			if ((area.g_x + area.g_w) > SCw) 
				area.g_w = SCw - area.g_x;
			if ((area.g_y + area.g_h) > SCh) 
				area.g_h = SCh - area.g_y;
			redraw_board(area.g_x, area.g_y, area.g_w, area.g_h);
		}

		wind_get(window, WF_NEXTXYWH, &area.g_x, &area.g_y, 
				&area.g_w, &area.g_h);
		}
	graf_mouse(M_ON, 0);

	return;
}

void close_window(handle)
int handle;
{
	wind_get(handle, WF_CURRXYWH, &currx, &curry, &currw, &currh);
	form_dial(FMD_SHRINK, fullx, fully, 20, 20, 
		  currx, curry, currw, currh);
	wind_close(handle);
	wind_delete(handle);

	return;
}
