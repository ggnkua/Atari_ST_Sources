/*
 * Tests for different VDI marker sizes & types.
 */

#include "vdiutil.h"

#define ITEMS_X 12	/* number of objects horizontally */
#define ITEMS_Y 6	/* number of objects vertically */
#define OFFSET  32	/* offset from screen borders */

/* rotate marker type & double size */
static void next_style(void)
{
	static int type = 1, size = 8;
	vsm_height(vdi_handle, size);
	vsm_type(vdi_handle, type);
	type = (type % 6) + 1;
	size += 4;
}

static void markers(void)
{
	short pxyarray[2 * ITEMS_Y];
	int i, j, x, y, dx, dy;

	/* item offsets */
	dx = (screen.w - 2*OFFSET) / ITEMS_X;
	dy = (screen.h - 2*OFFSET) / ITEMS_Y;

	for (x = OFFSET, j = 0; j < ITEMS_X; j++, x += dx) {
		next_style();
		for (y = OFFSET, i = 0; i < ITEMS_Y; i++, y += dy) {
			pxyarray[2*i]   = x;
			pxyarray[2*i+1] = y;
		}
		v_pmarker(vdi_handle, ITEMS_Y, pxyarray);
	}
}


int main(void)
{
	work_open();
	markers();
	wait_key();
	work_close();
	return 0;
}
