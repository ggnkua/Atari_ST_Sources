/*
 * Test for first 2 colors with normal & inverted palette
 */

#include <stdio.h>
#if defined(__GNUC__)
# include <osbind.h>	/* MiNTlib */
#else
# include <tos.h>
#endif
#include "vdiutil.h"

/* Only EmuTOS and TOS v4.x allow monochrome mode colors
 * to be set with VDI color setting, so use Xbios instead.
 */
#define USE_XBIOS 1

static short screen_color[3*256];


/* paint right side screen black */
static void draw_box(void)
{
	short pxyarray[4];

	pxyarray[0] = screen.w/2;
	pxyarray[1] = 0;
	pxyarray[2] = screen.w;
	pxyarray[3] = screen.h;

	vr_recfl(vdi_handle, pxyarray);
}

static void print(const char *text)
{
	static short text_y = 16;
	if (text) {
		short d;
		vst_point(vdi_handle, 9, &d, &d, &d, &d);
		v_gtext(vdi_handle, 0, text_y, text);
	}
	text_y += 8;
}

static void get_palette(void)
{
	char text[64];
	int i;

	print(NULL);
	sprintf(text, "planes=%d, colors=%d:",
		screen.planes, screen.colors);
	print(text);

	/* a resolution with a palette? */
	if(screen.planes > 0 && screen.planes < 9) {
		/* get current color palette */
		for(i = 0; i < screen.colors; i++) {
			vq_color(vdi_handle, i, 1, screen_color + 3*i);
			sprintf(text, "- %d: r=%d, g=%d, b=%d", i,
				screen_color[3*i+0],
				screen_color[3*i+1],
				screen_color[3*i+2]);
			print(text);
		}
	}
}

static void print_colors(void)
{
	short hw_idx, vdi_idx;
	char text[64];

	v_get_pixel(vdi_handle, 1*screen.w/3, 4, &hw_idx, &vdi_idx);
	sprintf(text, "- left:  HW=%d, VDI=%d", hw_idx, vdi_idx);
	print(text);

	v_get_pixel(vdi_handle, 2*screen.w/3, 4, &hw_idx, &vdi_idx);
	sprintf(text, "- right: HW=%d, VDI=%d", hw_idx, vdi_idx);
	print(text);
}

int main(void)
{
	work_open();

	get_palette();
	draw_box();

	/* invert first two colors */
#ifdef USE_XBIOS
	(void)Setcolor(0, 0x000);
	(void)Setcolor(1, 0xfff);
#else
	vs_color(vdi_handle, 0, screen_color + 3*1);
	vs_color(vdi_handle, 1, screen_color + 3*0);
#endif

	print(NULL);
	print("inverted palette color indexes:");
	print_colors();
	wait_key();

	/* restore first two colors */
#ifdef USE_XBIOS
	(void)Setcolor(0, 0xfff);
	(void)Setcolor(1, 0x000);
#else
	vs_color(vdi_handle, 0, screen_color + 3*0);
	vs_color(vdi_handle, 1, screen_color + 3*1);
#endif

	print(NULL);
	print("default palette color indexes:");
	print_colors();
	wait_key();

	work_close();
	return 0;
}
