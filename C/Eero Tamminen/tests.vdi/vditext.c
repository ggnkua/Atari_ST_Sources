/*
 * Tests for different VDI text sizes, modes and styles
 */
#include <stdio.h>
#include <stdlib.h>
#include "vdiutil.h"

#define MAX_SIZE 64 /* fits well on TT-mono */


/* advance to next text effect, bit values:
 *  1 - bold
 *  2 - light
 *  4 - italic
 *  8 - underline
 * 16 - outline
 * 32 - shadowed
 */
static void next_effect(void)
{
	static int effect = 0;
	vst_effects(vdi_handle, effect);
	effect++;

	/* if outlined or shadowned */
	if (effect & (16|32)) {
		if (effect & 2) {
			/* skip light */
			effect += 2;
		}
		if (effect & 4) {
			/* skip italic */
			effect += 4;
		}
		if (effect & 8) {
			/* skip underline as non-interesting */
			effect += 8;
		}
		if ((effect & (16|32)) == (16|32)) {
			/* skip outline with shadowed */
			effect += 16;
		}
	}
	effect %= 64;
}

static int draw_text(int dir, int points, int startsize)
{
	const char *type;
	int xdir, ydir, size;
	short width, height, x, y, d; /* d=dummy */
	short char_height, cell_height, totalheight;
	short extent[8];
	char text[64];

	x = screen.w/2;
	y = screen.h/2;

	/* set horizontal text alignment and direction
	 * in which to print lines
	 */
	switch(dir) {
	case 0: /* top left */
		vst_alignment(vdi_handle, 2, 0, &d, &d);
		xdir = -1;
		ydir = -1;
		break;
	case 1: /* top right */
		vst_alignment(vdi_handle, 0, 0, &d, &d);
		xdir = 1;
		ydir = -1;
		break;
	case 2: /* bottom left */
		vst_alignment(vdi_handle, 2, 0, &d, &d);
		xdir = -1;
		ydir = 1;
		break;
	case 3: /* bottom right */
	default:
		vst_alignment(vdi_handle, 0, 0, &d, &d);
		xdir = 1;
		ydir = 1;
		break;
	}

	for (size = startsize, totalheight = 0; totalheight < screen.h/3; size++, totalheight += cell_height) {

		/* change text effect style */
		next_effect();

		/* change text size */
		if (points) {
			 /* character cell height in 1/72 inch points,
			  * as distance between baselines of print lines
			  */
			vst_point(vdi_handle, size, &d, &char_height, &d, &cell_height);
			type = "pt";
		} else {
			/* character height in pixels, as distance
			 * from baseline to end of character box
			 */
			vst_height(vdi_handle, size, &d, &char_height, &d, &cell_height);
			type = "px";
		}
		/* get text extent */
		vqt_extent(vdi_handle, "p", extent);
		width  = extent[4] - extent[0];
		height = extent[5] - extent[1];
		sprintf(text, "%d %s -> %d x %d", size, type, width, height);

		x += xdir * (cell_height >> 2);
		y += ydir * cell_height;
		v_gtext(vdi_handle, x, y, text);
	}

	return size;
}


int main(void)
{
	int dir, next;

	work_open();

	for (dir = 0; dir < 4; dir++) {
		next = draw_text(dir, 0, 4);
	}
	wait_key();
	work_clear();

	for (dir = 0; dir < 4; dir++) {
		next = draw_text(dir, 0, next);
	}
	wait_key();
	work_clear();

	for (dir = 0; dir < 4; dir++) {
		draw_text(dir, 1, 4);
	}
	wait_key();
	work_clear();

	work_close();
	return 0;
}
