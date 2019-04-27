/*
 * CManShip Chapter 17 - Windows
 */

#include <aes.h>
#include <vdi.h>
#define TRUE 1
#define FALSE 0
#define PARTS NAME|CLOSER|FULLER|MOVER|INFO

int work_in[11],
    work_out[57],
    pxyarray[10],
    contrl[12],
    intin[128],
    ptsin[128],
    intout[128],
    ptsout[128];

int handle, dum, fullx, fully, fullw, fullh,
    curx, cury, curw, curh, oldx, oldy, oldw, oldh;

int msg_buf[8];

char * title = "C-manship - Chapter 17";
char * info = "Learning about windows";

void open_vwork (void);
void do_wndw (void);
int full_wind (int w_h);
void draw_backgrd (int w_h);

void main (void) {
	appl_init ();
	open_vwork ();
	do_wndw ();
	v_clsvwk (handle);
	appl_exit ();
}

void open_vwork () {
	int i;

	handle = graf_handle (&dum, &dum, &dum, &dum);
	for (i=0; i<10; work_in[i++] = 1);
	work_in[10] = 2;
	v_opnvwk (work_in, &handle, work_out);
}

void do_wndw (void) {
	int w_handle, full_flag;

	/* find size of desktop's work area */
	wind_get (0, WF_WORKXYWH, &fullx, &fully, &fullw, &fullh);
	/* create window in memory */
	w_handle = wind_create (PARTS, fullx, fully, fullw, fullh);
	/* setwindow's title and info text */
	wind_set (w_handle, WF_NAME, title, 0, 0);
	wind_set (w_handle, WF_INFO, info, 0, 0);
	/* draw the window on the screen */
	graf_growbox(10, 10, 10, 10, 50, 50, 250, 200);
	wind_open (w_handle, 50, 50, 250, 150);
	draw_backgrd (w_handle);
	/* change mouse to arrow */
	graf_mouse (ARROW, 0L);

	/* receive event messages until close clicked */
	do {
		evnt_mesag (msg_buf);
		switch (msg_buf[0]) { /* msg_buf[0] is message type */
			case WM_MOVED:
				wind_set (msg_buf[3], WF_CURRXYWH, msg_buf[4],
					msg_buf[5], msg_buf[6], msg_buf[7]);
				break;
			case WM_FULLED:
				full_flag = full_wind (w_handle);
				if (!full_flag) {
					wind_get (w_handle, WF_PREVXYWH, &oldx, &oldy, &oldw, &oldh);
					graf_shrinkbox (oldx, oldy, oldw, oldh, fullx, fully, fullw, fullh);
					wind_set (msg_buf[3], WF_CURRXYWH, oldx, oldy, oldw, oldh);
				} else {
					wind_get (w_handle, WF_CURRXYWH, &curx, &cury, &curw, &curh);
					graf_growbox (curx, cury, curw, curh, fullx, fully, fullw, fullh);
					wind_set (msg_buf[3], WF_CURRXYWH, fullx, fully, fullw, fullh);
					draw_backgrd (w_handle);
				}

				break;


		}
	} while (msg_buf[0] != WM_CLOSED);

	/* get current size of window for use in shrinkbox */
	wind_get (w_handle, WF_CURRXYWH, &curx, &cury, &curw, &curh);
	graf_shrinkbox (10, 10, 10, 10, curx, cury, curw, curh);
	wind_close (w_handle);
	wind_delete (w_handle);
}

/* calculates if window should be drawn to maximum size, or rest to previous size */
int full_wind (int w_h) {
	int c_x, c_y, c_w, c_h, f_x, f_y, f_w, f_h;

	wind_get (w_h, WF_CURRXYWH, &c_x, &c_y, &c_w, &c_h);
	wind_get (w_h, WF_FULLXYWH, &f_x, &f_y, &f_w, &f_h);
	if (c_x != f_x || c_y != f_y || c_w != f_w || c_h != f_h) {
		return TRUE;
	} else {
		return FALSE;
	}
}

/* draw white background in window's work area. */
void draw_backgrd (int w_h) {

}
