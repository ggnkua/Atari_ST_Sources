/*
 * Tests for VDI line drawing.
 * 
 * Drawing is done with different widths, orientations,
 * line endings, types and drawing modes.
 */

#include "vdiutil.h"

#define MAX_WIDTH 41	/* max line width limit */

static struct {
	int end;
	int type;
	int mode;
} style;


static void init_style(void)
{
	style.end = 1;
	style.type = 1;
	style.mode = 1;
}

/* rotate line ending style */
static void next_line_ends(void)
{
	vsl_ends(vdi_handle, style.end, style.end);
	style.end = (style.end + 1) % 3;
}

/* rotate draw type */
static void next_type(void)
{
	vsl_type(vdi_handle, style.type);
	style.type = (style.type % 6) + 1;
}

/* rotate draw mode:
 * 0: replace
 * 1: transparent
 * 2: XOR
 * 3: reverse transparent
 */
static void next_mode(void)
{
	vswr_mode(vdi_handle, style.mode);
	/* TODO, test also MD_ERASE: 4 (have good test for that)? */
	style.mode = (style.mode % 3) + 1;
}


/* draw some elliptical arcs */
static void draw_arcs(int width)
{
	int x, y, xr, yr, beg, end, inc, dec;

	/* set line width */
	vsl_width(vdi_handle, width);

	/* center */
	x = screen.w/2;
	y = screen.h/2;

	xr = x; yr = y;
	dec = 15 + width;

	beg = 0;
	end = 2400;
	inc = 300 + 4*width;

	while (xr > 0 && yr > 0) {
		next_type();
		v_ellarc(vdi_handle, x, y, xr, yr, beg, end);
		beg += inc;
		end += inc;
		xr -= dec;
		yr -= dec;
	}
}


/* draw some lines */
static void draw_lines(int width)
{
	int i, wx, wy, ix, iy, dx, dy;
	short pxyarray[4];

	/* set line width */
	vsl_width(vdi_handle, width);

	/* draw area */
	wx = screen.w - 4;
	wy = screen.h - 8;

	/* allow wider lines to go slightly outside clip area */
	pxyarray[0] = 2;
	pxyarray[1] = wy;
	pxyarray[2] = wx;
	pxyarray[3] = 4;

	/* position offsets & line counts in both direction */
	dx = 3*MAX_WIDTH;
	ix = wx / dx;
	dy = 3*MAX_WIDTH;
	iy = wy / dy;

	for (i = 0; i < iy; i++) {
		next_type();
		v_pline(vdi_handle, 2, pxyarray);
		pxyarray[1] -= dy;
		pxyarray[3] += dy;
	}
	for (i = 0; i < ix; i++) {
		next_type();
		v_pline(vdi_handle, 2, pxyarray);
		pxyarray[0] += dx;
		pxyarray[2] -= dx;
	}
}

/* ------------------------------------------- */
int main(void)
{
	int i, inc;
	
	work_open();

	init_style();
	for (i = 1, inc = 2; i <= MAX_WIDTH; i += inc, inc += 2) {
		next_line_ends();
		next_mode();
		draw_arcs(i);
		wait_key();
		work_clear();
	}

	init_style();
	for (i = 1, inc = 2; i <= MAX_WIDTH; i += inc, inc += 2) {
		next_line_ends();
		next_mode();
		draw_lines(i);
		wait_key();
		work_clear();
	}

	work_close();
	return 0;
}
