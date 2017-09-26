/*
	NOVA video cards definitions

	Copyright (C) 2002	Patrice Mandin

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
*/

#ifndef _NOVA_H
#define _NOVA_H

/*--- Types ---*/

/* cookie IMNE points to this */
typedef struct {
	unsigned char id[4];		/* Version number (in ASCII) */
	unsigned char p_chres[4];	/* Pointer to change resolution routine */
	unsigned char mode[2];		/* Video mode type: */
								/* 0=4 bpp */
								/* 1=1 bpp */
								/* 2=8 bpp */
								/* 3=15 bpp (little endian) */
								/* 4=16 bpp (little endian) */
								/* 5=24 bpp (BGR) */
								/* 6=32 bpp (RGBA) */
	unsigned char pitch[2];		/* bpp<8: bytes per plane, per line */
								/* bpp>=8: bytes per line */
	unsigned char planes[2];	/* Bits per pixel */
	unsigned char colours[2];	/* Number of colours */
	unsigned char hc[2];		/* Hardcopy mode */
								/* 0=1 pixel screen -> 1x1 printer screen */
								/* 1=1 pixel screen -> 2x2 printer screen */
								/* 2=1 pixel screen -> 4x4 printer screen */
	unsigned char max_x[2];		/* Maximal virtual screen size (values-1) */
	unsigned char max_y[2];
	unsigned char rmn_x[2];		/* Min and max of real screen size (values-1) */
	unsigned char rmx_x[2];
	unsigned char rmn_y[2];
	unsigned char rmx_y[2];
	unsigned char scr_base[4];	/* Pointer to current screen address */
	unsigned char reg_base[4];	/* Pointer to video card I/O registers */
	unsigned char name[36];		/* Actual video mode name */
	unsigned char bl_count[4];	/* Some values for blanking */
	unsigned char bl_max[4];
	unsigned char bl_on[2];
	unsigned char card[2];		/* Video card type */
	unsigned char speed_tab[12];/* Mouse accelerator values */
	unsigned char chng_vrt[4];
	unsigned char boot_drv[2];	/* Boot drive for resolution file */
	unsigned char set_vec[4];
	unsigned char main_work[4];
	unsigned char handler[4];
	unsigned char init_col[4];
	unsigned char scrn_cnt[2];	/* Number of screens in video RAM */
	unsigned char scrn_sze[4];	/* Size of a screen in video RAM */
	unsigned char base[4];		/* Address of screen #0 in video RAM */
	unsigned char p_setscr[4];	/* Pointer to a routine to change physical screen address */
	unsigned char v_top[2];		/* Some values for virtual screen */
	unsigned char v_bottom[2];
	unsigned char v_left[2];
	unsigned char v_right[2];
	unsigned char max_light[2];
	unsigned char chng_pos[4];
	unsigned char chng_edg[4];
	unsigned char hw_flags[2];
	unsigned char calib_on[2];	/* Some values for calibration */
	unsigned char calib_col[36];
	unsigned char calib_in[4];
	unsigned char cal_tab[4];
	unsigned char recal_tab[4];
} nova_icb_t;

/* cookie NOVA points to this */
typedef struct {
	unsigned char version[4];	/* Version number */
	unsigned char resolution;	/* Resolution number */
	unsigned char blnk_time;	/* Time before blanking */
	unsigned char ms_speed;		/* Mouse speed */
	unsigned char old_res;
	unsigned char p_chres[4];	/* Pointer to routine to change resolution */
	unsigned char mode[2];		/* Video mode type: */
								/* 0=4 bpp */
								/* 1=1 bpp */
								/* 2=8 bpp */
								/* 3=15 bpp (little endian) */
								/* 4=16 bpp (little endian) */
								/* 5=24 bpp (BGR) */
								/* 6=32 bpp (RGBA) */
	unsigned char pitch[2];		/* bpp<8: bytes per plane, per line */
								/* bpp>=8: bytes per line */
	unsigned char planes[2];	/* Bits per pixel */
	unsigned char colours[2];	/* Number of colours, unused */
	unsigned char hc[2];		/* Hardcopy mode */
								/* 0=1 pixel screen -> 1x1 printer screen */
								/* 1=1 pixel screen -> 2x2 printer screen */
								/* 2=1 pixel screen -> 4x4 printer screen */
	unsigned char max_x[2];		/* Resolution, values-1 */
	unsigned char max_y[2];
	unsigned char rmn_x[2];
	unsigned char rmx_x[2];
	unsigned char rmn_y[2];
	unsigned char rmx_y[2];
	unsigned char v_top[2];
	unsigned char v_bottom[2];
	unsigned char v_left[2];
	unsigned char v_right[2];
	unsigned char p_setcol[4];	/* Pointer to routine to set colours */
	unsigned char chng_vrt[4];
	unsigned char inst_xbios[4];
	unsigned char pic_on[4];
	unsigned char chng_pos[4];
	unsigned char p_setscr[4];	/* Pointer to routine to change screen address */
	unsigned char base[4];		/* Address of screen #0 in video RAM */
	unsigned char scr_base[4];	/* Adress of video RAM */
	unsigned char scrn_cnt[2];	/* Number of possible screens in video RAM */
	unsigned char scrn_sze[4];	/* Size of a screen */
	unsigned char reg_base[4];	/* Video card I/O registers base */
	unsigned char p_vsync[4];	/* Pointer to routine to vsync */
	unsigned char name[36];		/* Video mode name */
	unsigned char mem_size[4];	/* Global size of video memory */
} nova_xcb_t;

typedef struct {
	unsigned char name[33];		/* Video mode name */
	unsigned char dummy1;

	unsigned char mode[2];		/* Video mode type */
								/* 0=4 bpp */
								/* 1=1 bpp */
								/* 2=8 bpp */
								/* 3=15 bpp (little endian) */
								/* 4=16 bpp (little endian) */
								/* 5=24 bpp (BGR) */
								/* 6=32 bpp (RGBA) */
	unsigned char pitch[2];		/* bpp<8: words/plane /line */
								/* bpp>=8: bytes /line */
	unsigned char planes[2];	/* Bits per pixel */
	unsigned char colors[2];	/* Number of colours */
	unsigned char hc_mode[2];	/* Hardcopy mode */
								/* 0=1 pixel screen -> 1x1 printer screen */
								/* 1=1 pixel screen -> 2x2 printer screen */
								/* 2=1 pixel screen -> 4x4 printer screen */
	unsigned char max_x[2];		/* Max x,y coordinates, values-1 */
	unsigned char max_y[2];
	unsigned char real_x[2];	/* Real max x,y coordinates, values-1 */
	unsigned char real_y[2];

	unsigned char freq[2];		/* Pixel clock */
	unsigned char freq2;		/* Another pixel clock */
	unsigned char low_res;		/* Half of pixel clock */
	unsigned char r_3c2;
	unsigned char r_3d4[25];
	unsigned char extended[3];
	unsigned char dummy2;
} nova_resolution_t;

/*--- Functions prototypes ---*/

nova_resolution_t *nova_LoadModes(int *num_modes);

#endif /* _NOVA_H */
