/* This file illustrates use of all functions in chart.h */

#include <aes.h>
#include <gemf.h>
#include <vdi.h>
#include <stdbool.h>
#include "chart.h"

/* Creates a simple bar chart, using default fill/colour styles */
struct bar_chart * create_bar_chart_1 (void) {
	struct bar_chart * bc;
	int values[] = {1, 2, 3, 4, 5};

	bc = chart_make_bar ("Bar Chart: Simple Values", "Items", "Counts", 5, values);

	return bc;
}

/* Creates a bar chart with varying colours and x-labels */
struct bar_chart * create_bar_chart_2 (void) {
	struct bar_chart * bc;
	int values[] = {6, 1, 7, 13, 14, 8, 7, 7, 5, 5};
	int i, c;
	char * labels[] = {"1979-1984", "1985", "1986", "1987", "1988", "1989", "1990", "1991-1993", "1994-1999", "2000 or later"};

	bc = chart_make_bar ("Forum Poll: When did you have your first Atari?", "Year", "Count", 10, values);

	for (i = 0; i < 10; i += 1) {
		chart_set_bar_x_label (bc, i, labels[i]);
	}

	c = 1;
	for (i = 0; i < 10; i += 1) {
		chart_set_bar_colour (bc, i, c);
		chart_set_bar_style (bc, i, 2, i);
		c += 1;
	}

	return bc;
}

/* Create a line chart for two maths functions */
struct line_chart * create_line_chart_1 (void) {
	int sqrs_x[11]; /* space for the x/y coordinates of line 1 */
	int sqrs_y[11];
	int cubes_x[11]; /* space for the x/y coordinates of line 2 */
	int cubes_y[11];
	int i;
	struct line_chart * lc;

	/* Create the line chart with headings and planned count of lines */
	lc = chart_make_line ("Maths Functions", "x-axis", "y-axis", 2);

	/* Create data for the two lines */
	for (i = 0; i < 11; i += 1) {
		int val=i-5; /* do graph from -5 to 5 */
		sqrs_x[i] = val;
		sqrs_y[i] = val*val;
		cubes_x[i] = val;
		cubes_y[i] = val*val*val;
	}

	/* add the two lines to the line_chart */
	chart_set_line (lc, 0, "squares", 11, sqrs_x, sqrs_y, BLUE, 3, 6); /* blue, star, dash-dot-dot */
	chart_set_line (lc, 1, "cubes", 11, cubes_x, cubes_y, GREEN, 6, 3); /* green, diamond, dotted */

	return lc;
}

/* Create a simple pie chart */
struct pie_chart * create_pie_chart_1 (void) {
	struct pie_chart * pc;
	int values[] = {5, 20, 10, 20};
	char * labels[] = {"Section 1", "Section 2", "Section 3", "Section 4"};
	int i, c;

	/* create the pie chart */
	pc = chart_make_pie ("Simple Pie Chart", 4, values);

	/* set the labels for each region */
	for (i = 0; i < 4; i += 1) {
		chart_set_pie_label (pc, i, labels[i]);
	}
	/* regions in pie chart are distinguished by colour/style */
	c = 1;
	for (i = 0; i < 10; i += 1) {
		chart_set_pie_colour (pc, i, c);
		chart_set_pie_style (pc, i, 2, i);
		c += 1;
	}

	return pc;
}

/* -- simple set of windows to display charts, each of a fixed size -- */

#define PARTS NAME|CLOSER|MOVER
static int app_handle; /* application handle */

/* GEM arrays */
int work_in[11],
	work_out[57],
	contrl[12],
	intin[128],
	ptsin[128],
	intout[128],
	ptsout[128];

/* Struct to hold window information */
struct win_data {
	int handle;
	void * chart;
	int chart_number;

	struct win_data * next;
};

int char_w, char_h, box_w, box_h; /* dimensions of characters in display */

/* standard code to set up gem arrays and open work area */
void open_vwork (void) {
	int i;

	app_handle = graf_handle (&char_w, &char_h, &box_w, &box_h);
	for (i = 0; i < 10; work_in[i++] = 1);
	work_in[10] = 2;
	v_opnvwk (work_in, &app_handle, work_out);
}

/* sets/unsets clipping rectangle in VDI */
void set_clip (int flag, GRECT rec) {
	int pxy[4];

	pxy[0] = rec.g_x;
	pxy[1] = rec.g_y;
	pxy[2] = rec.g_x + rec.g_w - 1;
	pxy[3] = rec.g_y + rec.g_h - 1;

	vs_clip (app_handle, flag, pxy);
}

/* -- Code to create and draw the example windows -- */

/* draw example 1 and 2 */
void draw_interior_1 (struct win_data * wd, GRECT clip) {
	int wrkx, wrky, wrkw, wrkh; /* some variables describing current working area */

	graf_mouse (M_OFF, 0L);
	set_clip (true, clip);
	wind_get (wd->handle, WF_WORKXYWH, &wrkx, &wrky, &wrkw, &wrkh);

	chart_draw_bar ((struct bar_chart *)wd->chart, app_handle,
		wrkx, wrky, wrkw, wrkh);

	set_clip (false, clip);
	graf_mouse (M_ON, 0L);
}

/* create example 1 window */
void create_window_1 (struct win_data * wd) {
	int x,y,w,h;
	GRECT rec;

	wind_get (0, WF_WORKXYWH, &x, &y, &w, &h);
	wd->handle = wind_create (PARTS, x, y, w, h);
	wind_set (wd->handle, WF_NAME, "Example 1", 0, 0);
	wind_open (wd->handle, x, y, 300, 180);

	wd->chart_number = 1;
	wd->chart = create_bar_chart_1 ();

	wind_get (wd->handle, WF_WORKXYWH, &rec.g_x, &rec.g_y, &rec.g_w, &rec.g_h);
	draw_interior_1 (wd, rec);
}

/* create example 2 window */
void create_window_2 (struct win_data * wd) {
	int x,y,w,h;
	GRECT rec;

	wind_get (0, WF_WORKXYWH, &x, &y, &w, &h);
	wd->handle = wind_create (PARTS|SIZER, x, y, w, h);
	wind_set (wd->handle, WF_NAME, "Example 2: Resize me!", 0, 0);
	wind_open (wd->handle, x, y, (x+w >= 600 ? 600 : w), 180);

	wd->chart_number = 2;
	wd->chart = create_bar_chart_2 ();

	wind_get (wd->handle, WF_WORKXYWH, &rec.g_x, &rec.g_y, &rec.g_w, &rec.g_h);
	draw_interior_1 (wd, rec);
}

/* draw example 3 */
void draw_interior_3 (struct win_data * wd, GRECT clip) {
	int wrkx, wrky, wrkw, wrkh; /* some variables describing current working area */

	graf_mouse (M_OFF, 0L);
	set_clip (true, clip);
	wind_get (wd->handle, WF_WORKXYWH, &wrkx, &wrky, &wrkw, &wrkh);

	chart_draw_pie ((struct pie_chart *)wd->chart, app_handle,
		wrkx, wrky, wrkw, wrkh);

	set_clip (false, clip);
	graf_mouse (M_ON, 0L);
}

/* create example 3 window */
void create_window_3 (struct win_data * wd) {
	int x,y,w,h;
	GRECT rec;

	wind_get (0, WF_WORKXYWH, &x, &y, &w, &h);
	wd->handle = wind_create (PARTS|SIZER, x, y, w, h);
	wind_set (wd->handle, WF_NAME, "Example 3", 0, 0);
  if (w > 300 && y > 400) {
	  wind_open (wd->handle, x, y+200, 300, 200);
  } else {
    wind_open (wd->handle, x, y, w-50, h-50);
  }

	wd->chart_number = 3;
	wd->chart = create_pie_chart_1 ();

	wind_get (wd->handle, WF_WORKXYWH, &rec.g_x, &rec.g_y, &rec.g_w, &rec.g_h);
	draw_interior_3 (wd, rec);
}

/* draw example 4 */
void draw_interior_4 (struct win_data * wd, GRECT clip) {
	int wrkx, wrky, wrkw, wrkh; /* some variables describing current working area */

	graf_mouse (M_OFF, 0L);
	set_clip (true, clip);
	wind_get (wd->handle, WF_WORKXYWH, &wrkx, &wrky, &wrkw, &wrkh);

	chart_draw_line ((struct line_chart *)wd->chart, app_handle,
		wrkx, wrky, wrkw, wrkh);

	set_clip (false, clip);
	graf_mouse (M_ON, 0L);
}

/* create example 4 window */
void create_window_4 (struct win_data * wd) {
	int x,y,w,h;
	GRECT rec;

	wind_get (0, WF_WORKXYWH, &x, &y, &w, &h);
	wd->handle = wind_create (PARTS|SIZER, x, y, w, h);
	wind_set (wd->handle, WF_NAME, "Example 4: Line Chart", 0, 0);
  if (w > 500 && y > 500) {
    wind_open (wd->handle, x+100, y+100, 400, 400);
  } else {
    wind_open (wd->handle, x, y, w-50, h-50);
  }

	wd->chart_number = 4;
	wd->chart = create_line_chart_1 ();

	wind_get (wd->handle, WF_WORKXYWH, &rec.g_x, &rec.g_y, &rec.g_w, &rec.g_h);
	draw_interior_4 (wd, rec);
}

/* draw example 5: chart with other material around it */
void draw_interior_5 (struct win_data * wd, GRECT clip) {
	int wrkx, wrky, wrkw, wrkh, dum;
	int pxy[4];

	graf_mouse (M_OFF, 0L);
	set_clip (true, clip);
	wind_get (wd->handle, WF_WORKXYWH, &wrkx, &wrky, &wrkw, &wrkh);

	vsf_interior (app_handle, SOLID);
	vsf_color (app_handle, CYAN);
	pxy[0] = wrkx;
	pxy[1] = wrky;
	pxy[2] = wrkx + wrkw - 1;
	pxy[3] = wrky + wrkh - 1;
	vr_recfl (app_handle, pxy);
	chart_draw_bar ((struct bar_chart *)wd->chart, app_handle,
		wrkx+50, wrky+50, wrkw-60, wrkh-70);
	vsf_color (app_handle, RED);
	vst_height (app_handle, TITLE_FONT, &dum, &dum, &dum, &dum);
	v_gtext (app_handle, wrkx+10, wrky+20, "Charts can be drawn with other items");

	pxy[0] = wrkx+45;
	pxy[1] = wrky+45;
	pxy[2] = wrkx+wrkw-5;
	pxy[3] = wrky+wrkh-5;
	vsl_color (app_handle, BLUE);
	vsl_width (app_handle, 3);
	v_rbox (app_handle, pxy);

	set_clip (false, clip);
	graf_mouse (M_ON, 0L);
}

/* create example 5 window */
void create_window_5 (struct win_data * wd) {
	int x, y, w, h;
	GRECT rec;

	wind_get (0, WF_WORKXYWH, &x, &y, &w, &h);
	wd->handle = wind_create (PARTS, x, y, w, h);
	wind_set (wd->handle, WF_NAME, "Example 5: Bar Chart + Others", 0, 0);
  if (w > 700 && h > 700) {
  	wind_open (wd->handle, x+300, y, 400, 400);
  } else {
    wind_open (wd->handle, x, y, w-20, h-20);
  }

	wd->chart_number = 5;
	wd->chart = create_bar_chart_1 ();

	wind_get (wd->handle, WF_WORKXYWH, &rec.g_x, &rec.g_y, &rec.g_w, &rec.g_h);
	draw_interior_5 (wd, rec);
}

/* -- general window code -- */

/* Called when application asked to redraw parts of its display.
   Walks the rectangle list, redrawing the relevant part of the window.
 */
void do_redraw (struct win_data * wd, GRECT * rec1) {
	GRECT rec2;

	wind_update (BEG_UPDATE);

	wind_get (wd->handle, WF_FIRSTXYWH, &rec2.g_x, &rec2.g_y, &rec2.g_w, &rec2.g_h);
	while (rec2.g_w && rec2.g_h) {
		if (rc_intersect (rec1, &rec2)) {
			switch (wd->chart_number) {
				case 1:
				case 2:
					draw_interior_1 (wd, rec2);
					break;
				case 3:
					draw_interior_3 (wd, rec2);
					break;
				case 4:
					draw_interior_4 (wd, rec2);
					break;
				case 5:
					draw_interior_5 (wd, rec2);
					break;
			}
		}
		wind_get (wd->handle, WF_NEXTXYWH, &rec2.g_x, &rec2.g_y, &rec2.g_w, &rec2.g_h);
	}

	wind_update (END_UPDATE);
}

/* Create a window for each example, and monitor redraw events
   to keep windows drawn correctly. Exit on Ctrl-Q / close on any window
 */
void do_examples (void) {
	struct win_data wd_1, wd_2, wd_3, wd_4, wd_5;
	int msg_buf[8];

	create_window_5 (&wd_5);
	create_window_4 (&wd_4);
	create_window_3 (&wd_3);
	create_window_2 (&wd_2);
	create_window_1 (&wd_1);

	graf_mouse (ARROW, 0L);

	/* receive event messages until close clicked or Ctrl-Q pressed */
	do {
		int dum, event, key;

		event = evnt_multi (MU_MESAG|MU_KEYBD, 0,0,0,0,0,0,0,0,0,0,0,0,0,msg_buf,0,0,
			&dum,&dum,&dum,&dum, &key, &dum);

		/* -- check for and handle keyboard events */
		if (event & MU_KEYBD) {
			if (key == 0x1011) { /* ctrl-Q */
			    break; /* quit the do-while loop */
			}
		}

		/* -- check for and handle window/menu events */
		if (event & MU_MESAG) {
			switch (msg_buf[0]) {

				case WM_TOPPED:
					wind_set (msg_buf[3], WF_TOP, 0, 0);
					break;

				case WM_MOVED:
					wind_set (msg_buf[3], WF_CURRXYWH, msg_buf[4],
						msg_buf[5], msg_buf[6], msg_buf[7]);
					break;

				case WM_SIZED:
					wind_set (msg_buf[3], WF_TOP, 0, 0);
					wind_set (msg_buf[3],
						WF_CURRXYWH,
						msg_buf[4],
						msg_buf[5],
						(msg_buf[6] < 50 ? 50 : msg_buf[6]),
						(msg_buf[7] < 50 ? 50 : msg_buf[7]));
					// break; redraw afterwards

				case WM_REDRAW:
				 	if (msg_buf[3] == wd_1.handle) {
						do_redraw (&wd_1, (GRECT *)&msg_buf[4]);
					} else if (msg_buf[3] == wd_2.handle) {
						do_redraw (&wd_2, (GRECT *)&msg_buf[4]);
					} else if (msg_buf[3] == wd_3.handle) {
						do_redraw (&wd_3, (GRECT *)&msg_buf[4]);
					} else if (msg_buf[3] == wd_4.handle) {
						do_redraw (&wd_4, (GRECT *)&msg_buf[4]);
					} else if (msg_buf[3] == wd_5.handle) {
						do_redraw (&wd_5, (GRECT *)&msg_buf[4]);
					}
					break;

			}
		}
	} while (msg_buf[0] != WM_CLOSED);

	wind_close (wd_1.handle);
	wind_delete (wd_1.handle);
	wind_close (wd_2.handle);
	wind_delete (wd_2.handle);
	wind_close (wd_3.handle);
	wind_delete (wd_3.handle);
	wind_close (wd_4.handle);
	wind_delete (wd_4.handle);
	wind_close (wd_5.handle);
	wind_delete (wd_5.handle);
}

/* -- get the example started -- */
void main (int argc, char * argv[]) {
	appl_init ();
	open_vwork ();
	do_examples ();
	rsrc_free ();
	v_clsvwk (app_handle);
	appl_exit ();
}
