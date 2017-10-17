/*
 * Tests for VDI contour filling.
 * 
 * Draws multi-spike star that are partly on screen, parly out,
 * and fills them.
 */

#include <stdio.h>
#include <stdlib.h>
#include "vdiutil.h"
#include "cos.h"

#define SIGN(x) (x < 0 ? -1 : 1)


static int cosi(int angle, int len)
{
	fraction_t *fx = &(cos_lookup[angle % 360]);
	return ((long)len * fx->numerator / fx->denominator);
}

/* draw & fill a star at given position with given number of spikes and base & spike radius */
static void draw_star(int x, int y, int spikes, int base_r, int spike_r, int color)
{
	short *pxyarray, *pxy;
	int i, inc, len, angle;

	spikes *= 2; /* both spike peaks & bottoms */
	pxyarray = malloc(sizeof(*pxy)*2*(spikes+1));
	if (!pxyarray) {
		return;
	}
	pxy = pxyarray;

	len = 0;
	angle = 0;
	inc = 360 / spikes;

	for (i = 0; i < spikes; i++) {
		if (len == base_r) {
			len = spike_r;
		} else {
			len = base_r;
		}
		*pxy++ = x + cosi(angle, len);
		*pxy++ = y + cosi(angle+90, len);
		angle += inc;
	}
	*pxy++ = pxyarray[0];
	*pxy++ = pxyarray[1];

	v_pline(vdi_handle, spikes+1, pxyarray);
	v_contourfill(vdi_handle, x, y, color);
}

int main(void)
{
	int diff, r1, r2;

	work_open();

	/* set line width */
	vsl_width(vdi_handle, 1);

	if (screen.w > screen.h) {
		diff = screen.w / 32;
	} else {
		diff = screen.h / 32;
	}
	r1 = 5*diff;
	r2 = 7*diff;

	draw_star(5*diff, 5*diff, 5, r1, r2, 1);
	r1 -= diff;
	r2 += diff;
	draw_star(screen.w-5*diff, 5*diff, 7, r1, r2, -1);
	r1 -= diff;
	r2 += diff;
	draw_star(5*diff, screen.h-5*diff, 9, r1, r2, 1);
	r1 -= diff;
	r2 += diff;
	draw_star(screen.w-5*diff, screen.h-5*diff, 11, r1, r2, -1);

	wait_key();
	work_close();
	return 0;
}
