/*
 * CManShip Chapter 20 - Windows 4
 *
 * Ensure compiler options has '-i include' to include 'gemf.h'
 */

#include <aes.h>
#include <gemf.h>
#include <vdi.h>

#include <stdio.h>

#define TRUE 1
#define FALSE 0
#define PARTS NAME|CLOSER|SIZER|UPARROW|DNARROW|VSLIDE
#define MAX 50
#define SOLID 1
#define MIN_WIDTH 64
#define MIN_HEIGHT 64

int work_in[11],
    work_out[57],
    contrl[12],
    intin[128],
    ptsin[128],
    intout[128],
    ptsout[128];

int handle, w_h, top,
	fullx, fully, fullw, fullh,
	char_w, char_h, box_w, box_h,
	wrkx, wrky, wrkh, wrkw;

int msg_buf[8];

struct {
	char fnames[MAX][15]; /* char array for filenames. */
	int count;            /* number of filenames read. */
} files;

char * title = "C-manship - Chapter 20";

void open_vwork (void);
void do_wndw (void);
void do_arrow (void);
void do_vslide (void);
void do_uppage (void);
void do_dnpage (void);
void do_upline (void);
void do_dnline (void);
void get_fnames (void);
void calc_slid (int w_h, int line_cnt, int col_cnt);
void do_move (void);
void draw_interior (GRECT clip);
void do_redraw (GRECT * clip);
void set_clip (int flag, GRECT rec);

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

	top = 0;

	get_fnames ();
	wind_get (0, WF_WORKXYWH, &fullx, &fully, &fullw, &fullh);
	w_h = wind_create (PARTS, fullx, fully, fullw, fullh);
	wind_set (w_h, WF_NAME, title, 0, 0);
	wind_open (w_h, 100, 20, 150, 151);
	calc_slid (w_h, files.count, 14);
	graf_mouse (ARROW, 0L);

	/* receive event messages until close clicked */
	do {
		evnt_mesag (msg_buf);
		switch (msg_buf[0]) { /* msg_buf[0] is message type */

			case WM_SIZED:
				do_move ();
				break;

			case WM_ARROWED:
				do_arrow ();
				break;

			case WM_VSLID:
				do_vslide ();
				break;

			case WM_REDRAW:
				do_redraw ((GRECT *)&msg_buf[4]);
				break;
		}
	} while (msg_buf[0] != WM_CLOSED);

	wind_close (w_h);
	wind_delete (w_h);
}

void do_arrow (void) {
	switch (msg_buf[4]) {
		case WA_UPPAGE:
			do_uppage ();
			break;

		case WA_DNPAGE:
			do_dnpage ();
			break;

		case WA_UPLINE:
			do_upline ();
			break;

		case WA_DNLINE:
			do_dnline ();
			break;
	}
}

void do_vslide (void) {
	GRECT r;
	int lines_avail;

	wind_get (w_h, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	lines_avail = r.g_h / char_h;
	top = msg_buf[4] * (files.count - lines_avail) / 1000;
	wind_set (w_h, WF_VSLIDE, msg_buf[4], 0, 0, 0);
	draw_interior (r);
}

void do_uppage (void) {
	GRECT r;
	int lines_avail;

	wind_get (w_h, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	lines_avail = r.g_h / char_h;
	top -= lines_avail;
	if (top < 0) top = 0;
	draw_interior (r);
}

void do_dnpage (void) {
	GRECT r;
	int lines_avail;

	wind_get (w_h, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	lines_avail = r.g_h / char_h;
	top += lines_avail;
	if (top > files.count - lines_avail) {
		top = files.count - lines_avail;
	}
	draw_interior (r);
}

void do_upline (void) {
	FDB s, d;
	GRECT r;
	int pxy[8];

	if (top != 0) {
		top -= 1;
		wind_get (w_h, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
		set_clip (TRUE, r);
		graf_mouse (M_OFF, 0L);
		s.fd_addr = 0L;
		d.fd_addr = 0L;
		pxy[0] = r.g_x;
		pxy[1] = r.g_y + 1;
		pxy[2] = r.g_x + r.g_w;
		pxy[3] = r.g_y + r.g_h - char_h - 1;
		pxy[4] = r.g_x;
		pxy[5] = r.g_y + char_h + 1;
		pxy[6] = r.g_x + r.g_w;
		pxy[7] = r.g_y + r.g_h - 1;
		vro_cpyfm (handle, S_ONLY, pxy, &s, &d);
		v_gtext (handle, r.g_x+char_w, r.g_y+char_h, &files.fnames[top][0]);
		set_clip (FALSE, r);
		calc_slid (w_h, files.count, 14);
		graf_mouse (M_ON, 0L);
	}
}

void do_dnline (void) {
	FDB s, d;
	GRECT r;
	int pxy[8];
	int lines_avail, index;

	wind_get (w_h, WF_WORKXYWH, &r.g_x, &r.g_y, &r.g_w, &r.g_h);
	lines_avail = r.g_h / char_h;
	if ( (top+lines_avail) < files.count) {
		top += 1;
		index = top + lines_avail - 1;
		set_clip (TRUE, r);
		graf_mouse (M_OFF, 0L);
		s.fd_addr = 0L;
		d.fd_addr = 0L;
		pxy[0] = r.g_x;
		pxy[1] = r.g_y + char_h + 1;
		pxy[2] = r.g_x + r.g_w;
		pxy[3] = r.g_y + r.g_h - 1;
		pxy[4] = r.g_x;
		pxy[5] = r.g_y + 1;
		pxy[6] = r.g_x + r.g_w;
		pxy[7] = r.g_y + r.g_h - char_h - 1;
		vro_cpyfm (handle, S_ONLY, pxy, &s, &d);
		v_gtext (handle, r.g_x+char_w, r.g_y+(lines_avail * char_h), &files.fnames[index][0]);
		if (index != files.count - 1) {
			v_gtext (handle, r.g_x+char_w, r.g_y+(lines_avail * char_h)+char_h, &files.fnames[index+1][0]);
		} else {
			v_gtext (handle, r.g_x+char_w, r.g_y+(lines_avail * char_h)+char_h, "             ");
		}
		set_clip (FALSE, r);
		calc_slid (w_h, files.count, 14);
		graf_mouse (M_ON, 0L);
	}
}

void get_fnames (void) {
	DTA dta;
	int end, p, x, null_found;

	p = 0;
	files.count = 0;
	Fsetdta (&dta);
	end = Fsfirst ("*.*", 17);

	while ((end > -1) && (files.count < MAX)) {
		null_found = FALSE;
		files.count += 1;
		for (x = 0; x<14; ++x) {
			if (dta.d_fname[x] == 0) {
				null_found = TRUE;
			}
			if (null_found) {
				dta.d_fname[x] = ' ';
			}
			files.fnames[p][x] = dta.d_fname[x];
		}
		files.fnames[p][14] = 0;
		p += 1;
		end = Fsnext ();
	}
}

void calc_slid (int w_h, int line_cnt, int col_cnt) {
	int lines_avail, cols_avail, vslid_siz, pos;

	wind_get (w_h, WF_WORKXYWH, &wrkx, &wrky, &wrkw, &wrkh);
	lines_avail = wrkh / char_h;
	cols_avail = wrkw / char_w;
	vslid_siz = 1000 * lines_avail / line_cnt;
	wind_set (w_h, WF_VSLSIZE, vslid_siz, 0, 0, 0);
	pos = (int) ( (((float) top) / ((float)(files.count - lines_avail))) * 1000);
	wind_set (w_h, WF_VSLIDE, pos, 0, 0, 0);
}

void do_move (void) {
	if (msg_buf[6] < MIN_WIDTH) msg_buf[6] = MIN_WIDTH;
	if (msg_buf[7] < MIN_HEIGHT) msg_buf[7] = MIN_HEIGHT;
	wind_set (msg_buf[3], WF_CURRXYWH, msg_buf[4], msg_buf[5], msg_buf[6], msg_buf[7]);
	calc_slid (w_h, files.count, 14);
}

void draw_interior (GRECT clip) {
	int pxy[4];
	int x, lines_avail, lines_shown;

	graf_mouse (M_OFF, 0L);
	set_clip (TRUE, clip); /* calculate clip rectangle and set clipping on */
	wind_get (msg_buf[3], WF_WORKXYWH, &wrkx, &wrky, &wrkw, &wrkh);

	vsf_interior (handle, SOLID);
	vsf_color (handle, WHITE);
	pxy[0] = wrkx;
	pxy[1] = wrky;
	pxy[2] = wrkx + wrkw - 1;
	pxy[3] = wrky + wrkh - 1;
	vr_recfl (handle, pxy);

	lines_avail = wrkh / char_h;
	lines_shown = files.count - top;
	if (lines_avail > lines_shown) {
		top = files.count - lines_avail;
		if (top < 0) top = 0;
	}

	for (x=top; x < files.count; ++x) {
		v_gtext (handle, wrkx+8, wrky+(x+1-top)*char_h, &files.fnames[x][0]);
	}

	set_clip (FALSE, clip);
	calc_slid (w_h, files.count, 14);
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

