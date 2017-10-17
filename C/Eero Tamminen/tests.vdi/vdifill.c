/*
 * Tests for different VDI fill modes, types, patterns, borders, colors
 * and filled objects.
 */

#include "vdiutil.h"

/* there are 6*4 = 24 bit patterns */
#define NUM_ITEMS (ITEMS_X * ITEMS_Y)
#define ITEMS_X 8	/* number of objects horizontally */
#define ITEMS_Y 6	/* number of objects vertically */
#define OFFSET  5	/* distance between objects */

static struct {
	int idx;	/* counter since init */
	int mode;
	int type;
	int pattern;
	int border;
	int color;
} style;

static void init_style(void)
{
	style.idx = 0;
	style.mode = 1;
	style.type = 0;
	style.pattern = 1;
	style.border = 0;
	style.color = 0;
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
	style.mode = (style.mode % 4) + 1;
}

/* rotate fill types:
 * 0: not filled
 * 1: solid fill
 * 2: bit pattern
 * 3: cross-hatch
 * 4: user-defined
 */
static void next_type(void)
{
	vsf_interior(vdi_handle, style.type);
	if (style.idx < 2) {
		style.type++;
	} else {
		if (style.idx < 2+12) {
			style.type = (style.type % 2) + 2;
		} else {
			style.type = 2;
		}
	}
}

/* rotate fill patterns:
 * 1-24 for bit patterns
 * 1-12 for cross-hatches
 * 
 * Must be called after next_type()!
 */
static void next_pattern(void)
{
	style.pattern = (style.pattern % 24) + 1;
	vsf_style(vdi_handle, style.pattern);
}

/* rotate border on/off */
static void next_border(void)
{
	vsf_perimeter(vdi_handle, style.border);
	style.border = (style.border + 1) % 2;
}

/* rotate color */
static void next_color(void)
{
	vsf_color(vdi_handle, style.color);
	style.color = style.color % (screen.colors-1) + 1;
}

/* rotate everything */
static void next_style(void)
{
	style.idx++;
	next_mode();
	next_type();
	next_pattern();
	next_border();
	next_color();
}

/* draw filled rounded rectangle */
static void draw_rfbox(int x, int y, int w, int h)
{
	short pxyarray[4];
	pxyarray[0] = x;
	pxyarray[1] = y;
	pxyarray[2] = x + w;
	pxyarray[3] = y + h;
	v_rfbox(vdi_handle, pxyarray);
}

/* draw fillarea */
static void draw_fillarea(int x, int y, int w, int h)
{
	short pxyarray[8];
	pxyarray[0] = x;
	pxyarray[1] = y;
	pxyarray[2] = x + w;
	pxyarray[3] = y;
	pxyarray[4] = x + w;
	pxyarray[5] = y + h;
	pxyarray[6] = x;
	pxyarray[7] = y + h;
	v_fillarea(vdi_handle, 4, pxyarray);
}

/* draw filled rectangle */
static void draw_recfl(int x, int y, int w, int h)
{
	short pxyarray[4];
	pxyarray[0] = x;
	pxyarray[1] = y;
	pxyarray[2] = x + w;
	pxyarray[3] = y + h;
	vr_recfl(vdi_handle, pxyarray);
}

/* draw filled bar */
static void draw_bar(int x, int y, int w, int h)
{
	short pxyarray[4];
	pxyarray[0] = x;
	pxyarray[1] = y;
	pxyarray[2] = x + w;
	pxyarray[3] = y + h;
	v_bar(vdi_handle, pxyarray);
}

/* draw filled elliptical pie */
static void draw_ellpie(int x, int y, int w, int h)
{
	static int beg = 10, end = 3600;
	static const int inc = 150;
	/* radius */
	w >>= 1;
	h >>= 1;
	/* middle */
	x += w;
	y += h;
	v_ellpie(vdi_handle, x, y, w, h, beg, end);
	/* end and start angle */
	beg += inc;
	end += inc/2;
}

/* draw filled pie */
static void draw_pieslice(int x, int y, int w, int h)
{
	static int beg = 10, end = 3600;
	static const int inc = 150;
	/* radius */
	int r = (w+h) >> 2;
	/* middle */
	x += r;
	y += r;
	v_pieslice(vdi_handle, x, y, r, beg, end);
	/* end and start angle */
	beg += inc;
	end += inc/2;
}

/* draw filled ellipse */
static void draw_ellipse(int x, int y, int w, int h)
{
	/* radius */
	w >>= 1;
	h >>= 1;
	/* middle */
	x += w;
	y += h;
	v_ellipse(vdi_handle, x, y, w, h);
}

/* draw circle */
static void draw_circle(int x, int y, int w, int h)
{
	/* radius */
	int r = (w+h) >> 2;
	/* middle */
	x += r;
	y += r;
	v_circle(vdi_handle, x, y, r);
}

static void draw(void (*object)(int x, int y, int w, int h))
{
	int i, j, x, y, dx, dy;

	/* item size */
	dx = (screen.w - 2*OFFSET) / ITEMS_X;
	dy = (screen.h - 2*OFFSET) / ITEMS_Y;

	for (y = OFFSET, i = 0; i < ITEMS_Y; i++, y += dy) {
		for (x = OFFSET, j = 0; j < ITEMS_X; j++, x += dx) {
			next_style();
			object(x, y, dx, dy);
		}
	}
}


int main(void)
{
	void (*drawer[])(int x, int y, int w, int h) = {
		draw_pieslice, draw_ellpie,
		draw_circle, draw_ellipse,
		draw_fillarea, draw_rfbox,
		draw_bar, draw_recfl
	};
	unsigned int i;

	work_open();
	for (i = 0; i < ARRAY_ITEMS(drawer); i++) {
		init_style();
		draw(drawer[i]);
		wait_key();
		work_clear();
	}
	work_close();
	return 0;
}
