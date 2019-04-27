/*
 * CManShip Chapter 18 - Windows 2
 *
 * Ensure compiler options has '-i include' to include 'gemf.h'
 */

#include <aes.h>
#include <gemf.h>
#include <vdi.h>

#define TRUE 1
#define FALSE 0
#define PARTS NAME|CLOSER|MOVER|SIZER
#define MIN_WIDTH 64
#define MIN_HEIGHT 64

int work_in[11],
    work_out[57],
    pxyarray[10],
    contrl[12],
    intin[128],
    ptsin[128],
    intout[128],
    ptsout[128];

int handle, fullx, fully, fullw, fullh, wrkx, wrky,
    wrkh, wrkw, curx, cury, curw, curh, w_handle,
    char_w, char_h, box_w, box_h;

int msg_buf[8];

char * title = "C-manship - Chapter 18";
char * text[] = {
	"This is some sample text",
	"for use in the C-manship",
	"window demonstration found",
	"in Chapter 18."
};
int num_lines = 4;

void open_vwork (void);
void do_wndw (void);
void do_move (void);
void draw_interior (GRECT clip);
void do_redraw (GRECT * clip);
void set_clip (int flag, GRECT rec);
void open_window (void);
void close_window (void);

void main (void) {
	appl_init ();
	open_vwork ();
	do_wndw ();
	v_clsvwk (handle);
	appl_exit ();
}

void open_vwork () {
	int i;

	handle = graf_handle (&char_w, &char_h, &box_w, &box_h);
	for (i=0; i<10; work_in[i++] = 1);
	work_in[10] = 2;
	v_opnvwk (work_in, &handle, work_out);
}

void do_wndw (void) {

	open_window ();

	/* change mouse to arrow */
	graf_mouse (ARROW, 0L);

	/* receive event messages until close clicked */
	do {
		evnt_mesag (msg_buf);
		switch (msg_buf[0]) { /* msg_buf[0] is message type */
			case WM_MOVED:
			case WM_SIZED:
				do_move ();
				break;

			case WM_REDRAW:
				do_redraw ((GRECT *)&msg_buf[4]);
				break;
		}
	} while (msg_buf[0] != WM_CLOSED);

	close_window ();
}

void do_move (void) {
	if (msg_buf[6] < MIN_WIDTH) msg_buf[6] = MIN_WIDTH;
	if (msg_buf[7] < MIN_HEIGHT) msg_buf[7] = MIN_HEIGHT;
	wind_set (msg_buf[3], WF_CURRXYWH, msg_buf[4], msg_buf[5], msg_buf[6], msg_buf[7]);
}

void draw_interior (GRECT clip) {
	int pxy[4], x, y;

	graf_mouse (M_OFF, 0L);

	set_clip (TRUE, clip); /* calculate clip rectangle and set clipping on */
	wind_get (w_handle, WF_WORKXYWH, &wrkx, &wrky, &wrkw, &wrkh);
	vsf_interior (handle, 1);
	vsf_color (handle, WHITE);

	pxy[0] = wrkx;
	pxy[1] = wrky;
	pxy[2] = wrkx + wrkw - 1;
	pxy[3] = wrky + wrkh - 1;
	vr_recfl (handle, pxy);

	y = wrky + box_h;
	for (x = 0; x < num_lines; ++x) {
		v_gtext (handle, wrkx + 8, y , text[x]);
		y += box_h;
	}

	set_clip (FALSE, clip);
	graf_mouse (M_ON, 0L);
}

void do_redraw (GRECT * rec1) {
	GRECT rec2;

	/* Lock window for update */
	wind_update (BEG_UPDATE);

	/* Get first rectangle from list */
	wind_get (msg_buf[3], WF_FIRSTXYWH, &rec2.g_x, &rec2.g_y, &rec2.g_w, &rec2.g_h);

	/* Loop through entire rectangle list, redrawing where necessary */
	while (rec2.g_w && rec2.g_h) {
		if (rc_intersect (rec1, &rec2)) {
			draw_interior (rec2);
		}
		wind_get (msg_buf[3], WF_NEXTXYWH, &rec2.g_x, &rec2.g_y, &rec2.g_w, &rec2.g_h);
	}
	/* Unlock window after update */
	wind_update (END_UPDATE);
}

void set_clip (int flag, GRECT rec) {
	int pxy[4];

	pxy[0] = rec.g_x;
	pxy[1] = rec.g_y;
	pxy[2] = rec.g_x + rec.g_w - 1;
	pxy[3] = rec.g_y + rec.g_h - 1;

	vs_clip (handle, flag, pxy);
}

void open_window (void) {
	wind_get (0, WF_WORKXYWH, &fullx, &fully, &fullw, &fullh);
	w_handle = wind_create (PARTS, fullx, fully, fullw, fullh);
	wind_set (w_handle, WF_NAME, title, 0, 0);
	graf_growbox (10, 10, 10, 10, fullx, fully, fullw, fullh);
	wind_open (w_handle, fullx, fully, fullw, fullh);
}

void close_window (void) {
	wind_get (w_handle, WF_CURRXYWH, &curx, &cury, &curw, &curh);
	graf_shrinkbox (10, 10, 10, 10, curx, cury, curw, curh);
	wind_close (w_handle);
	wind_delete (w_handle);
}
