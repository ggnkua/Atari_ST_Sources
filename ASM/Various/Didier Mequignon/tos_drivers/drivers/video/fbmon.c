/*
 * fbmon.c
 *
 * Copyright (C) 2002 James Simmons <jsimmons@users.sf.net>
 *
 * Credits:
 * 
 * The EDID Parser is a conglomeration from the following sources:
 *
 *   1. SciTech SNAP Graphics Architecture
 *      Copyright (C) 1991-2002 SciTech Software, Inc. All rights reserved.
 *
 *   2. XFree86 4.3.0, interpret_edid.c
 *      Copyright 1998 by Egbert Eich <Egbert.Eich@Physik.TU-Darmstadt.DE>
 * 
 *   3. John Fremlin <vii@users.sourceforge.net> and 
 *      Ani Joshi <ajoshi@unixbox.com>
 *  
 * Generalized Timing Formula is derived from:
 *
 *      GTF Spreadsheet by Andy Morrish (1/5/97) 
 *      available at http://www.vesa.org
 *
 * This file is subject to the terms and conditions of the GNU General Public
 * License.  See the file COPYING in the main directory of this archive
 * for more details.
 *
 */
 
#include "config.h"
#include <mint/osbind.h>
#include <mint/errno.h>
#include <string.h>
#include "fb.h"
#include "edid.h"

/* 
 * EDID parser
 */

#define FBMON_FIX_HEADER 1
#define FBMON_FIX_INPUT  2

#ifdef CONFIG_FB_MODE_HELPERS
struct broken_edid {
	unsigned char manufacturer[4];
	unsigned long model;
	unsigned long fix;
};

static struct broken_edid brokendb[] = {
	/* DEC FR-PCXAV-YZ */
	{
		.manufacturer = "DEC",
		.model        = 0x073a,
		.fix          = FBMON_FIX_HEADER,
	},
	/* ViewSonic PF775a */
	{
		.manufacturer = "VSC",
		.model        = 0x5a44,
		.fix          = FBMON_FIX_INPUT,
	},
};

static const unsigned char edid_v1_header[] = { 0x00, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0x00
};

static void copy_string(unsigned char *c, unsigned char *s)
{
  int i;
  c = c + 5;
  for (i = 0; (i < 13 && *c != 0x0A); i++)
    *(s++) = *(c++);
  *s = 0;
  while (i-- && (*--s == 0x20)) *s = 0;
}

static int check_edid(unsigned char *edid)
{
	unsigned char *block = edid + ID_MANUFACTURER_NAME, manufacturer[4];
	unsigned char *b;
	unsigned long model;
	int i, fix = 0, ret = 0;
	manufacturer[0] = ((block[0] & 0x7c) >> 2) + '@';
	manufacturer[1] = ((block[0] & 0x03) << 3) + ((block[1] & 0xe0) >> 5) + '@';
	manufacturer[2] = (block[1] & 0x1f) + '@';
	manufacturer[3] = 0;
	model = block[2] + (block[3] << 8);
	for(i = 0; i < sizeof(brokendb)/sizeof(*brokendb); i++)
	{
		if(manufacturer[0] == brokendb[i].manufacturer[0]
		 && manufacturer[1] == brokendb[i].manufacturer[1]
		 && manufacturer[2] == brokendb[i].manufacturer[2]
		 && manufacturer[3] == brokendb[i].manufacturer[3]
		 && brokendb[i].model == model) 
		{
 			fix = brokendb[i].fix;
 			break;
		}
	}
	switch(fix)
	{
		case FBMON_FIX_HEADER:
			for(i = 0; i < 8; i++)
			{
				if(edid[i] != edid_v1_header[i])
					ret = fix;
			}
			break;
		case FBMON_FIX_INPUT:
			b = edid + EDID_STRUCT_DISPLAY;
			/* Only if display is GTF capable will
			   the input type be reset to analog */
			if(b[4] & 0x01 && b[0] & 0x80)
				ret = fix;
			break;
	}
	return ret;
}

static void fix_edid(unsigned char *edid, int fix)
{
	unsigned char *b;
	switch(fix)
	{
		case FBMON_FIX_HEADER:
			memcpy(edid, edid_v1_header, 8);
			break;
		case FBMON_FIX_INPUT:
			b = edid + EDID_STRUCT_DISPLAY;
			b[0] &= ~0x80;
			edid[127] += 0x80;
			break;
	}
}

static int edid_checksum(unsigned char *edid)
{
	unsigned char i, csum = 0, all_null = 0;
	int err = 0, fix = check_edid(edid);
	if(fix)
		fix_edid(edid, fix);
	for(i = 0; i < EDID_LENGTH; i++)
	{
		csum += edid[i];
		all_null |= edid[i];
	}
	if((csum == 0x00) && all_null)
		/* checksum passed, everything's good */
		err = 1;
	if(!err)
		DPRINT("edid bad checksum\r\n");
	return err;
}

static int edid_check_header(unsigned char *edid)
{
	int i, err = 1, fix = check_edid(edid);
	if(fix)
		fix_edid(edid, fix);
	for(i = 0; i < 8; i++)
	{
		if(edid[i] != edid_v1_header[i])
			err = 0;
	}
	if(!err)
		DPRINT("edid bad header\r\n");
	return err;
}

static void parse_vendor_block(unsigned char *block, struct fb_monspecs *specs)
{
	specs->manufacturer[0] = ((block[0] & 0x7c) >> 2) + '@';
	specs->manufacturer[1] = ((block[0] & 0x03) << 3) +	((block[1] & 0xe0) >> 5) + '@';
	specs->manufacturer[2] = (block[1] & 0x1f) + '@';
	specs->manufacturer[3] = 0;
	specs->model = block[2] + (block[3] << 8);
	specs->serial = block[4] + (block[5] << 8) + (block[6] << 16) + (block[7] << 24);
	specs->year = block[9] + 1990;
	specs->week = block[8];
	DPRINT("   Manufacturer: ");
	DPRINT((void *)specs->manufacturer);
	DPRINTVAL("\r\n   Model: ",specs->model);
	DPRINTVAL("\r\n   Serial#: ",specs->serial);
	DPRINTVAL("\r\n   Year: ",specs->year);
	DPRINTVAL(" Week ",specs->week);
	DPRINT("\r\n");
}

static void get_dpms_capabilities(unsigned char flags, struct fb_monspecs *specs)
{
	specs->dpms = 0;
	if(flags & DPMS_ACTIVE_OFF)
		specs->dpms |= FB_DPMS_ACTIVE_OFF;
	if(flags & DPMS_SUSPEND)
		specs->dpms |= FB_DPMS_SUSPEND;
	if(flags & DPMS_STANDBY)
		specs->dpms |= FB_DPMS_STANDBY;
	DPRINT("      DPMS: Active ");
	DPRINT((flags & DPMS_ACTIVE_OFF) ? "yes" : "no");
	DPRINT(", Suspend ");
	DPRINT((flags & DPMS_SUSPEND) ? "yes" : "no");
	DPRINT(", Standby ");
	DPRINT((flags & DPMS_STANDBY) ? "yes\r\n" : "no\r\n");
}
	
static void get_chroma(unsigned char *block, struct fb_monspecs *specs)
{
	int tmp;
	DPRINT("      Chroma\r\n");
	/* Chromaticity data */
	tmp = ((block[5] & (3 << 6)) >> 6) | (block[0x7] << 2);
	tmp *= 1000;
	tmp += 512;
	specs->chroma.redx = tmp/1024;
	DPRINTVAL("         RedX:     ",specs->chroma.redx/10);
	tmp = ((block[5] & (3 << 4)) >> 4) | (block[0x8] << 2);
	tmp *= 1000;
	tmp += 512;
	specs->chroma.redy = tmp/1024;
	DPRINTVAL("% RedY:     ",specs->chroma.redy/10);
	tmp = ((block[5] & (3 << 2)) >> 2) | (block[0x9] << 2);
	tmp *= 1000;
	tmp += 512;
	specs->chroma.greenx = tmp/1024;
	DPRINTVAL("%\r\n         GreenX:   ",specs->chroma.greenx/10);
	tmp = (block[5] & 3) | (block[0xa] << 2);
	tmp *= 1000;
	tmp += 512;
	specs->chroma.greeny = tmp/1024;
	DPRINTVAL("% GreenY:   ",specs->chroma.greeny/10);
	tmp = ((block[6] & (3 << 6)) >> 6) | (block[0xb] << 2);
	tmp *= 1000;
	tmp += 512;
	specs->chroma.bluex = tmp/1024;
	DPRINTVAL("%\r\n         BlueX:    ",specs->chroma.bluex/10);
	tmp = ((block[6] & (3 << 4)) >> 4) | (block[0xc] << 2);
	tmp *= 1000;
	tmp += 512;
	specs->chroma.bluey = tmp/1024;
	DPRINTVAL("% BlueY:    ",specs->chroma.bluey/10);
	tmp = ((block[6] & (3 << 2)) >> 2) | (block[0xd] << 2);
	tmp *= 1000;
	tmp += 512;
	specs->chroma.whitex = tmp/1024;
	DPRINTVAL("%\r\n         WhiteX:   ",specs->chroma.whitex/10);
	tmp = (block[6] & 3) | (block[0xe] << 2);
	tmp *= 1000;
	tmp += 512;
	specs->chroma.whitey = tmp/1024;
	DPRINTVAL("% WhiteY:   ",specs->chroma.whitey/10);
	DPRINT("%\r\n");
}

static int edid_is_serial_block(unsigned char *block)
{
	if((block[0] == 0x00) && (block[1] == 0x00)
	 && (block[2] == 0x00) && (block[3] == 0xff) && (block[4] == 0x00))
		return 1;
	else
		return 0;
}

static int edid_is_ascii_block(unsigned char *block)
{
	if((block[0] == 0x00) && (block[1] == 0x00)
	 && (block[2] == 0x00) && (block[3] == 0xfe) && (block[4] == 0x00))
		return 1;
	else
		return 0;
}

static int edid_is_limits_block(unsigned char *block)
{
	if((block[0] == 0x00) && (block[1] == 0x00)
	 && (block[2] == 0x00) && (block[3] == 0xfd) && (block[4] == 0x00))
		return 1;
	else
		return 0;
}

static int edid_is_monitor_block(unsigned char *block)
{
	if((block[0] == 0x00) && (block[1] == 0x00)
	 && (block[2] == 0x00) && (block[3] == 0xfc) && (block[4] == 0x00))
		return 1;
	else
		return 0;
}

static void calc_mode_timings(int xres, int yres, int refresh, struct fb_videomode *mode)
{
	struct fb_var_screeninfo var;
	struct fb_info info;
	var.xres = xres;
	var.yres = yres;
	fb_get_mode(FB_VSYNCTIMINGS | FB_IGNOREMON, refresh, &var, &info);
	mode->xres = xres;
	mode->yres = yres;
	mode->pixclock = var.pixclock;
	mode->refresh = refresh;
	mode->left_margin = var.left_margin;
	mode->right_margin = var.right_margin;
	mode->upper_margin = var.upper_margin;
	mode->lower_margin = var.lower_margin;
	mode->hsync_len = var.hsync_len;
	mode->vsync_len = var.vsync_len;
	mode->vmode = 0;
	mode->sync = 0;
}

static int get_est_timing(unsigned char *block, struct fb_videomode *mode)
{
	int num = 0;
	unsigned char c;
	c = block[0];
	if(c&0x80)
	{
		calc_mode_timings(720, 400, 70, &mode[num]);
		mode[num++].flag = FB_MODE_IS_CALCULATED;
		DPRINT("      720x400@70Hz\r\n");
	}
	if(c&0x40)
	{
		calc_mode_timings(720, 400, 88, &mode[num]);
		mode[num++].flag = FB_MODE_IS_CALCULATED;
		DPRINT("      720x400@88Hz\r\n");
	}
	if(c&0x20)
	{
		mode[num++] = vesa_modes[3];
		DPRINT("      640x480@60Hz\r\n");
	}
	if(c&0x10)
	{
		calc_mode_timings(640, 480, 67, &mode[num]);
		mode[num++].flag = FB_MODE_IS_CALCULATED;
		DPRINT("      640x480@67Hz\r\n");
	}
	if(c&0x08)
	{
		mode[num++] = vesa_modes[4];
		DPRINT("      640x480@72Hz\r\n");
	}
	if(c&0x04)
	{
		mode[num++] = vesa_modes[5];
		DPRINT("      640x480@75Hz\r\n");
	}
	if(c&0x02)
	{
		mode[num++] = vesa_modes[7];
		DPRINT("      800x600@56Hz\r\n");
	}
	if(c&0x01)
	{
		mode[num++] = vesa_modes[8];
		DPRINT("      800x600@60Hz\r\n");
	}
	c = block[1];
	if(c&0x80)
	{
 		mode[num++] = vesa_modes[9];
		DPRINT("      800x600@72Hz\r\n");
	}
	if(c&0x40)
	{
 		mode[num++] = vesa_modes[10];
		DPRINT("      800x600@75Hz\r\n");
	}
	if(c&0x20)
	{
		calc_mode_timings(832, 624, 75, &mode[num]);
		mode[num++].flag = FB_MODE_IS_CALCULATED;
		DPRINT("      832x624@75Hz\r\n");
	}
	if(c&0x10)
	{
		mode[num++] = vesa_modes[12];
		DPRINT("      1024x768@87Hz Interlaced\r\n");
	}
	if(c&0x08)
	{
		mode[num++] = vesa_modes[13];
		DPRINT("      1024x768@60Hz\r\n");
	}
	if(c&0x04)
	{
		mode[num++] = vesa_modes[14];
		DPRINT("      1024x768@70Hz\r\n");
	}
	if(c&0x02)
	{
		mode[num++] = vesa_modes[15];
		DPRINT("      1024x768@75Hz\r\n");
	}
	if(c&0x01)
	{
		mode[num++] = vesa_modes[21];
		DPRINT("      1280x1024@75Hz\r\n");
	}
	c = block[2];
	if(c&0x80)
	{
		mode[num++] = vesa_modes[17];
		DPRINT("      1152x870@75Hz\r\n");
	}
	DPRINTVAL("      Manufacturer's mask: ",c&0x7F);
	DPRINT("\r\n");
	return num;
}

static int get_std_timing(unsigned char *block, struct fb_videomode *mode)
{
	int xres, yres = 0, refresh, ratio, i;
	xres = (block[0] + 31) * 8;
	if(xres <= 256)
		return 0;
	ratio = (block[1] & 0xc0) >> 6;
	switch(ratio)
	{
		case 0: yres = xres; break;
		case 1:	yres = (xres * 3)/4; break;
		case 2: yres = (xres * 4)/5; break;
		case 3:	yres = (xres * 9)/16;	break;
	}
	refresh = (block[1] & 0x3f) + 60;
	DPRINTVAL("      ",xres);
	DPRINTVAL("x",yres);
	DPRINTVAL("@",refresh);
	DPRINT("Hz\r\n");
	for(i = 0; i < VESA_MODEDB_SIZE; i++)
	{
		if(vesa_modes[i].xres == xres && vesa_modes[i].yres == yres
		 && vesa_modes[i].refresh == refresh)
		{
			*mode = vesa_modes[i];
			mode->flag |= FB_MODE_IS_STANDARD;
			return 1;
		}
	}
	calc_mode_timings(xres, yres, refresh, mode);
	return 1;
}

static int get_dst_timing(unsigned char *block, struct fb_videomode *mode)
{
	int j, num = 0;
	for(j = 0; j < 6; j++, block+= STD_TIMING_DESCRIPTION_SIZE) 
		num += get_std_timing(block, &mode[num]);
	return num;
}

static void get_detailed_timing(unsigned char *block, struct fb_videomode *mode)
{
	mode->xres = H_ACTIVE;
	mode->yres = V_ACTIVE;
	mode->pixclock = PIXEL_CLOCK;
	mode->pixclock /= 1000;
	mode->pixclock = KHZ2PICOS(mode->pixclock);
	mode->right_margin = H_SYNC_OFFSET;
	mode->left_margin = (H_ACTIVE + H_BLANKING) - (H_ACTIVE + H_SYNC_OFFSET + H_SYNC_WIDTH);
	mode->upper_margin = V_BLANKING - V_SYNC_OFFSET - V_SYNC_WIDTH;
	mode->lower_margin = V_SYNC_OFFSET;
	mode->hsync_len = H_SYNC_WIDTH;
	mode->vsync_len = V_SYNC_WIDTH;
	if(HSYNC_POSITIVE)
		mode->sync |= FB_SYNC_HOR_HIGH_ACT;
	if(VSYNC_POSITIVE)
		mode->sync |= FB_SYNC_VERT_HIGH_ACT;
	mode->refresh = PIXEL_CLOCK/((H_ACTIVE + H_BLANKING) * (V_ACTIVE + V_BLANKING));
	mode->vmode = 0;
	mode->flag = FB_MODE_IS_DETAILED;
	DPRINTVAL("      ",PIXEL_CLOCK/1000000);
	DPRINTVAL(" MHz ",H_ACTIVE);
	DPRINTVAL(" ",H_ACTIVE + H_SYNC_OFFSET);
	DPRINTVAL(" ",H_ACTIVE + H_SYNC_OFFSET + H_SYNC_WIDTH);
	DPRINTVAL(" ",H_ACTIVE + H_BLANKING);
	DPRINTVAL(" ",V_ACTIVE);
	DPRINTVAL(" ",V_ACTIVE + V_SYNC_OFFSET);
	DPRINTVAL(" ",V_ACTIVE + V_SYNC_OFFSET + V_SYNC_WIDTH);
	DPRINTVAL(" ",V_ACTIVE + V_BLANKING);
	DPRINT((HSYNC_POSITIVE) ? " +" : " -");
	DPRINT("HSync ");
	DPRINT((VSYNC_POSITIVE) ? "+" : "-");
	DPRINT("VSync\r\n");
}

#define MAX_DB_ALLOC 100
static struct fb_videomode tab_db[MAX_DB_ALLOC];
static struct fb_videomode *db_used[MAX_DB_ALLOC];

static struct fb_videomode *alloc_db(int num)
{
	int i = 0;
	if(!num)
		return(NULL);
	while(i < MAX_DB_ALLOC)
	{
		if((db_used[i] == NULL) && ((i + num) <= MAX_DB_ALLOC))
		{
			int j; /* search contiguous num db free */
			for(j = 0; j < num; j++)
			{
				if(db_used[i+j] != NULL)
					break;  /* already used */
			}
			if(j >= num)
			{
				struct fb_videomode *p = &tab_db[i];
				for(j = 0; j < num; db_used[i+j] = p, j++);
				return(p);
			}
		}
		i++;
	}
	return(NULL);
}

static void free_db(struct fb_videomode *db)
{
	int i;
	for(i = 0; i < MAX_DB_ALLOC; i++)
	{
		if(db_used[i] == db)
			db_used[i] = NULL;
	}
}

/**
 * fb_destroy_modedb - destroys mode database
 * @modedb: mode database to destroy
 *
 * DESCRIPTION:
 * Destroy mode database created by fb_create_modedb
 */
void fb_destroy_modedb(struct fb_videomode *modedb)
{
//	Funcs_free(modedb);
	free_db(modedb);
}

/**
 * fb_create_modedb - create video mode database
 * @edid: EDID data
 * @dbsize: database size
 *
 * RETURNS: struct fb_videomode, @dbsize contains length of database
 *
 * DESCRIPTION:
 * This function builds a mode database using the contents of the EDID
 * data
 */
static struct fb_videomode *fb_create_modedb(unsigned char *edid, int *dbsize)
{
	struct fb_videomode *mode, *m;
	unsigned char *block;
	int num = 0, i;
//	mode = Funcs_malloc(50 * sizeof(struct fb_videomode), 3);
	mode = alloc_db(50);
	if(mode == NULL)
		return NULL;
	memset((char *)mode, 0, 50 * sizeof(struct fb_videomode));
	if(edid == NULL || !edid_checksum(edid) || !edid_check_header(edid))
	{
		fb_destroy_modedb(mode);
		return NULL;
	}
	*dbsize = 0;
	DPRINT("   Supported VESA Modes\r\n");
	block = edid + ESTABLISHED_TIMING_1;
	num += get_est_timing(block, &mode[num]);
	DPRINT("   Standard Timings\r\n");
	block = edid + STD_TIMING_DESCRIPTIONS_START;
	for(i = 0; i < STD_TIMING; i++, block += STD_TIMING_DESCRIPTION_SIZE) 
		num += get_std_timing(block, &mode[num]);
	DPRINT("   Detailed Timings\r\n");
	block = edid + DETAILED_TIMING_DESCRIPTIONS_START;
	for(i = 0; i < 4; i++, block+= DETAILED_TIMING_DESCRIPTION_SIZE)
	{
		int first = 1;
		if(block[0] == 0x00 && block[1] == 0x00)
		{
			if(block[3] == 0xfa)
				num += get_dst_timing(block + 5, &mode[num]);
		}
		else
		{
			get_detailed_timing(block, &mode[num]);
			if(first)
			{
				mode[num].flag |= FB_MODE_IS_FIRST;
				first = 0;
			}
			num++;
		}
	}
	/* Yikes, EDID data is totally useless */
	if(!num)
	{
		fb_destroy_modedb(mode);
		return NULL;
	}
	*dbsize = num;
//	m = Funcs_malloc(num * sizeof(struct fb_videomode), 3);
	m = alloc_db(num);
	if(!m)
		return mode;
	memcpy(m, mode, num * sizeof(struct fb_videomode));
	fb_destroy_modedb(mode);
	return m;
}

static int fb_get_monitor_limits(unsigned char *edid, struct fb_monspecs *specs)
{
	int i, retval = 1;
	unsigned char *block;
	block = edid + DETAILED_TIMING_DESCRIPTIONS_START;
	DPRINT("      Monitor Operating Limits: ");
	for(i = 0; i < 4; i++, block += DETAILED_TIMING_DESCRIPTION_SIZE)
	{
		if(edid_is_limits_block(block))
		{
			specs->hfmin = H_MIN_RATE * 1000;
			specs->hfmax = H_MAX_RATE * 1000;
			specs->vfmin = V_MIN_RATE;
			specs->vfmax = V_MAX_RATE;
			specs->dclkmax = MAX_PIXEL_CLOCK * 1000000;
			specs->gtf = (GTF_SUPPORT) ? 1 : 0;
			retval = 0;
			DPRINT("From EDID\r\n");
			break;
		}
	}
	/* estimate monitor limits based on modes supported */
	if(retval)
	{
		struct fb_videomode *modes;
		int num_modes, i, hz, hscan, pixclock;
		modes = fb_create_modedb(edid, &num_modes);
		if(!modes)
		{
			DPRINT("None Available\r\n");
			return 1;
		}
		retval = 0;
		for(i = 0; i < num_modes; i++)
		{
			hz = modes[i].refresh;
			pixclock = PICOS2KHZ(modes[i].pixclock) * 1000;
			hscan = (modes[i].yres * 105 * hz + 5000)/100;
			if(specs->dclkmax == 0 || specs->dclkmax < pixclock)
				specs->dclkmax = pixclock;
			if(specs->dclkmin == 0 || specs->dclkmin > pixclock)
				specs->dclkmin = pixclock;
			if(specs->hfmax == 0 || specs->hfmax < hscan)
				specs->hfmax = hscan;
			if(specs->hfmin == 0 || specs->hfmin > hscan)
				specs->hfmin = hscan;
			if(specs->vfmax == 0 || specs->vfmax < hz)
				specs->vfmax = hz;
			if(specs->vfmin == 0 || specs->vfmin > hz)
				specs->vfmin = hz;
		}
		DPRINT("Extrapolated\r\n");
		fb_destroy_modedb(modes);
	}
	DPRINTVAL("           H: ",specs->hfmin/1000);
	DPRINTVAL("-",specs->hfmax/1000);
	DPRINTVAL("KHz V: ",specs->vfmin);
	DPRINTVAL("-",specs->vfmax);
	DPRINTVAL("Hz DCLK: ",specs->dclkmax/1000000);
	DPRINT("MHz\r\n");
	return retval;
}

static void get_monspecs(unsigned char *edid, struct fb_monspecs *specs)
{
	unsigned char c, *block;
	block = edid + EDID_STRUCT_DISPLAY;
	fb_get_monitor_limits(edid, specs);
	c = block[0] & 0x80;
	specs->input = 0;
	if(c)
	{
		specs->input |= FB_DISP_DDI;
		DPRINT("      Digital Display Input");
	}
	else
	{
		DPRINT("      Analog Display Input: Input Voltage - ");
		switch ((block[0] & 0x60) >> 5)
		{
			case 0:
				DPRINT("0.700V/0.300V");
				specs->input |= FB_DISP_ANA_700_300;
				break;
			case 1:
				DPRINT("0.714V/0.286V");
				specs->input |= FB_DISP_ANA_714_286;
				break;
			case 2:
				DPRINT("1.000V/0.400V");
				specs->input |= FB_DISP_ANA_1000_400;
				break;
			case 3:
				DPRINT("0.700V/0.000V");
				specs->input |= FB_DISP_ANA_700_000;
				break;
		}
	}
	DPRINT("\r\n      Sync: ");
	c = block[0] & 0x10;
	if(c)
	{
		DPRINT("      Configurable signal level\r\n");
	}
	c = block[0] & 0x0f;
	specs->signal = 0;
	if(c & 0x10)
	{
		DPRINT("Blank to Blank ");
		specs->signal |= FB_SIGNAL_BLANK_BLANK;
	}
	if(c & 0x08)
	{
		DPRINT("Separate ");
		specs->signal |= FB_SIGNAL_SEPARATE;
	}
	if(c & 0x04)
	{
		DPRINT("Composite ");
		specs->signal |= FB_SIGNAL_COMPOSITE;
	}
	if(c & 0x02)
	{
		DPRINT("Sync on Green ");
		specs->signal |= FB_SIGNAL_SYNC_ON_GREEN;
	}
	if(c & 0x01)
	{
		DPRINT("Serration on ");
		specs->signal |= FB_SIGNAL_SERRATION_ON;
	}
	DPRINT("\r\n");
	specs->max_x = block[1];
	specs->max_y = block[2];
	DPRINT("      Max H-size in cm: ");
	if(specs->max_x)
	{
		DPRINTVAL("",specs->max_x);
		DPRINT("\r\n");
	}		
	else
	{
		DPRINT("variable\r\n");
	}
	DPRINT("      Max V-size in cm: ");
	if(specs->max_y)
	{
		DPRINTVAL("",specs->max_y);
		DPRINT("\r\n");
	}
	else
	{
		DPRINT("variable\r\n");
	}
	c = block[3];
	specs->gamma = c+100;
	DPRINTVAL("      Gamma: ",specs->gamma/100);
	DPRINT("\r\n");
	get_dpms_capabilities(block[4], specs);
	switch ((block[4] & 0x18) >> 3)
	{
		case 0:
			DPRINT("      Monochrome/Grayscale\r\n");
			specs->input |= FB_DISP_MONO;
			break;
		case 1:
			DPRINT("      RGB Color Display\r\n");
			specs->input |= FB_DISP_RGB;
			break;
		case 2:
			DPRINT("      Non-RGB Multicolor Display\r\n");
			specs->input |= FB_DISP_MULTI;
			break;
		default:
			DPRINT("      Unknown\r\n");
			specs->input |= FB_DISP_UNKNOWN;
			break;
	}
	get_chroma(block, specs);
	specs->misc = 0;
	c = block[4] & 0x7;
	if(c & 0x04)
	{
		DPRINT("      Default color format is primary\r\n");
		specs->misc |= FB_MISC_PRIM_COLOR;
	}
	if(c & 0x02)
	{
		DPRINT("      First DETAILED Timing is preferred\r\n");
		specs->misc |= FB_MISC_1ST_DETAIL;
	}
	if(c & 0x01)
	{
		DPRINT("      Display is GTF capable\r\n");
		specs->gtf = 1;
	}
}

static int edid_is_timing_block(unsigned char *block)
{
	if((block[0] != 0x00) || (block[1] != 0x00)
	 || (block[2] != 0x00) || (block[4] != 0x00))
		return 1;
	else
		return 0;
}

int fb_parse_edid(unsigned char *edid, struct fb_var_screeninfo *var)
{
	int i;
	unsigned char *block;
	if(edid == NULL || var == NULL)
		return 1;
	if(!(edid_checksum(edid)))
		return 1;
	if(!(edid_check_header(edid)))
		return 1;
	block = edid + DETAILED_TIMING_DESCRIPTIONS_START;
	for(i = 0; i < 4; i++, block += DETAILED_TIMING_DESCRIPTION_SIZE)
	{
		if(edid_is_timing_block(block))
		{
			var->xres = var->xres_virtual = H_ACTIVE;
			var->yres = var->yres_virtual = V_ACTIVE;
			var->height = var->width = -1;
			var->right_margin = H_SYNC_OFFSET;
			var->left_margin = (H_ACTIVE + H_BLANKING) - (H_ACTIVE + H_SYNC_OFFSET + H_SYNC_WIDTH);
			var->upper_margin = V_BLANKING - V_SYNC_OFFSET - V_SYNC_WIDTH;
			var->lower_margin = V_SYNC_OFFSET;
			var->hsync_len = H_SYNC_WIDTH;
			var->vsync_len = V_SYNC_WIDTH;
			var->pixclock = PIXEL_CLOCK;
			var->pixclock /= 1000;
			var->pixclock = KHZ2PICOS(var->pixclock);
			if(HSYNC_POSITIVE)
				var->sync |= FB_SYNC_HOR_HIGH_ACT;
			if(VSYNC_POSITIVE)
				var->sync |= FB_SYNC_VERT_HIGH_ACT;
			return 0;
		}
	}
	DPRINT("edid no timing block\r\n");
	return 1;
}

void fb_edid_to_monspecs(unsigned char *edid, struct fb_monspecs *specs)
{
	unsigned char *block;
	int i;
	if(edid == NULL)
		return;
	if(!(edid_checksum(edid)))
		return;
	if(!(edid_check_header(edid)))
		return;
	if(specs->modedb != NULL)
		fb_destroy_modedb(specs->modedb);
	memset((char *)specs, 0, sizeof(struct fb_monspecs));
	specs->version = edid[EDID_STRUCT_VERSION];
	specs->revision = edid[EDID_STRUCT_REVISION];
	DPRINT("========================================\r\n");
	DPRINT("Display Information (EDID)\r\n");
	DPRINT("========================================\r\n");
	DPRINTVAL("   EDID Version ",specs->version);
	DPRINTVAL(".",specs->revision);
	DPRINT("\r\n");
	parse_vendor_block(edid + ID_MANUFACTURER_NAME, specs);
	block = edid + DETAILED_TIMING_DESCRIPTIONS_START;
	for(i = 0; i < 4; i++, block += DETAILED_TIMING_DESCRIPTION_SIZE)
	{
		if(edid_is_serial_block(block))
		{
			copy_string(block, specs->serial_no);
			DPRINT("   Serial Number: ");
			DPRINT((void *)specs->serial_no);
			DPRINT("\r\n");
		}
		else if(edid_is_ascii_block(block))
		{
			copy_string(block, specs->ascii);
			DPRINT("   ASCII Block: ");
			DPRINT((void *)specs->ascii);
			DPRINT("\r\n");
		}
		else if(edid_is_monitor_block(block))
		{
			copy_string(block, specs->monitor);
			DPRINT("   Monitor Name: ");
			DPRINT((void *)specs->monitor);
			DPRINT("\r\n");
		}
	}
	DPRINT("   Display Characteristics:\r\n");
	get_monspecs(edid, specs);
	specs->modedb = fb_create_modedb(edid, (int *)&specs->modedb_len);
	DPRINT("========================================\r\n");
}

/* 
 * VESA Generalized Timing Formula (GTF) 
 */

#define FLYBACK                     550
#define V_FRONTPORCH                1
#define H_OFFSET                    40
#define H_SCALEFACTOR               20
#define H_BLANKSCALE                128
#define H_GRADIENT                  600
#define C_VAL                       30
#define M_VAL                       300

struct __fb_timings {
	unsigned long dclk;
	unsigned long hfreq;
	unsigned long vfreq;
	unsigned long hactive;
	unsigned long vactive;
	unsigned long hblank;
	unsigned long vblank;
	unsigned long htotal;
	unsigned long vtotal;
};

/**
 * fb_get_vblank - get vertical blank time
 * @hfreq: horizontal freq
 *
 * DESCRIPTION:
 * vblank = right_margin + vsync_len + left_margin 
 *
 *    given: right_margin = 1 (V_FRONTPORCH)
 *           vsync_len    = 3
 *           flyback      = 550
 *
 *                          flyback * hfreq
 *           left_margin  = --------------- - vsync_len
 *                           1000000
 */
static unsigned long fb_get_vblank(unsigned long hfreq)
{
	unsigned long vblank;
	vblank = (hfreq * FLYBACK)/1000; 
	vblank = (vblank + 500)/1000;
	return (vblank + V_FRONTPORCH);
}

/** 
 * fb_get_hblank_by_freq - get horizontal blank time given hfreq
 * @hfreq: horizontal freq
 * @xres: horizontal resolution in pixels
 *
 * DESCRIPTION:
 *
 *           xres * duty_cycle
 * hblank = ------------------
 *           100 - duty_cycle
 *
 * duty cycle = percent of htotal assigned to inactive display
 * duty cycle = C - (M/Hfreq)
 *
 * where: C = ((offset - scale factor) * blank_scale)
 *            -------------------------------------- + scale factor
 *                        256 
 *        M = blank_scale * gradient
 *
 */
static unsigned long fb_get_hblank_by_hfreq(unsigned long hfreq, unsigned long xres)
{
	unsigned long c_val, m_val, duty_cycle, hblank;
	c_val = (((H_OFFSET - H_SCALEFACTOR) * H_BLANKSCALE)/256 + H_SCALEFACTOR) * 1000;
	m_val = (H_BLANKSCALE * H_GRADIENT)/256;
	m_val = (m_val * 1000000)/hfreq;
	duty_cycle = c_val - m_val;
	hblank = (xres * duty_cycle)/(100000 - duty_cycle);
	return (hblank);
}

/* Quick integer square root using binomial theorem (from Dr. Dobbs journal) */
static int int_sqrt(int N)
{
	unsigned long l2, u, v, u2, n;
	if(N < 2)
		return N;
	u = N;
	l2 = 0;
	/* 1/2 * log_2 N = highest bit in the result */
	while ((u >>= 2))
		l2++;
	u = 1L << l2;
	v = u;
	u2 = u << l2;
	while (l2--)
	{
		v >>= 1;
		n = (u + u + v) << l2;
		n += u2;
		if (n <= N)
		{
			u += v;
			u2 = n;
		}
	}
	return u;
}

/** 
 * fb_get_hblank_by_dclk - get horizontal blank time given pixelclock
 * @dclk: pixelclock in Hz
 * @xres: horizontal resolution in pixels
 *
 * DESCRIPTION:
 *
 *           xres * duty_cycle
 * hblank = ------------------
 *           100 - duty_cycle
 *
 * duty cycle = percent of htotal assigned to inactive display
 * duty cycle = C - (M * h_period)
 * 
 * where: h_period = SQRT(100 - C + (0.4 * xres * M)/dclk) + C - 100
 *                   -----------------------------------------------
 *                                    2 * M
 *        M = 300;
 *        C = 30;

 */
static unsigned long fb_get_hblank_by_dclk(unsigned long dclk, unsigned long xres)
{
	unsigned long duty_cycle, h_period, hblank;
	dclk /= 1000;
	h_period = 100 - C_VAL;
	h_period *= h_period;
	h_period += (M_VAL * xres * 2 * 1000)/(5 * dclk);
	h_period *=10000; 
	h_period = int_sqrt(h_period);
	h_period -= (100 - C_VAL) * 100;
	h_period *= 1000; 
	h_period /= 2 * M_VAL;
	duty_cycle = C_VAL * 1000 - (M_VAL * h_period)/100;
	hblank = (xres * duty_cycle)/(100000 - duty_cycle) + 8;
	hblank &= ~15;
	return (hblank);
}
	
/**
 * fb_get_hfreq - estimate hsync
 * @vfreq: vertical refresh rate
 * @yres: vertical resolution
 *
 * DESCRIPTION:
 *
 *          (yres + front_port) * vfreq * 1000000
 * hfreq = -------------------------------------
 *          (1000000 - (vfreq * FLYBACK)
 * 
 */

static unsigned long fb_get_hfreq(unsigned long vfreq, unsigned long yres)
{
	unsigned long divisor, hfreq;
	divisor = (1000000 - (vfreq * FLYBACK))/1000;
	hfreq = (yres + V_FRONTPORCH) * vfreq  * 1000;
	return (hfreq/divisor);
}

static void fb_timings_vfreq(struct __fb_timings *timings)
{
	timings->hfreq = fb_get_hfreq(timings->vfreq, timings->vactive);
	timings->vblank = fb_get_vblank(timings->hfreq);
	timings->vtotal = timings->vactive + timings->vblank;
	timings->hblank = fb_get_hblank_by_hfreq(timings->hfreq, 
						 timings->hactive);
	timings->htotal = timings->hactive + timings->hblank;
	timings->dclk = timings->htotal * timings->hfreq;
}

static void fb_timings_hfreq(struct __fb_timings *timings)
{
	timings->vblank = fb_get_vblank(timings->hfreq);
	timings->vtotal = timings->vactive + timings->vblank;
	timings->vfreq = timings->hfreq/timings->vtotal;
	timings->hblank = fb_get_hblank_by_hfreq(timings->hfreq, timings->hactive);
	timings->htotal = timings->hactive + timings->hblank;
	timings->dclk = timings->htotal * timings->hfreq;
}

static void fb_timings_dclk(struct __fb_timings *timings)
{
	timings->hblank = fb_get_hblank_by_dclk(timings->dclk, timings->hactive);
	timings->htotal = timings->hactive + timings->hblank;
	timings->hfreq = timings->dclk/timings->htotal;
	timings->vblank = fb_get_vblank(timings->hfreq);
	timings->vtotal = timings->vactive + timings->vblank;
	timings->vfreq = timings->hfreq/timings->vtotal;
}

/*
 * fb_get_mode - calculates video mode using VESA GTF
 * @flags: if: 0 - maximize vertical refresh rate
 *             1 - vrefresh-driven calculation;
 *             2 - hscan-driven calculation;
 *             3 - pixelclock-driven calculation;
 * @val: depending on @flags, ignored, vrefresh, hsync or pixelclock
 * @var: pointer to fb_var_screeninfo
 * @info: pointer to fb_info
 *
 * DESCRIPTION:
 * Calculates video mode based on monitor specs using VESA GTF. 
 * The GTF is best for VESA GTF compliant monitors but is 
 * specifically formulated to work for older monitors as well.
 *
 * If @flag==0, the function will attempt to maximize the 
 * refresh rate.  Otherwise, it will calculate timings based on
 * the flag and accompanying value.  
 *
 * If FB_IGNOREMON bit is set in @flags, monitor specs will be 
 * ignored and @var will be filled with the calculated timings.
 *
 * All calculations are based on the VESA GTF Spreadsheet
 * available at VESA's public ftp (http://www.vesa.org).
 * 
 * NOTES:
 * The timings generated by the GTF will be different from VESA
 * DMT.  It might be a good idea to keep a table of standard
 * VESA modes as well.  The GTF may also not work for some displays,
 * such as, and especially, analog TV.
 *   
 * REQUIRES:
 * A valid info->monspecs, otherwise 'safe numbers' will be used.
 */ 
int fb_get_mode(int flags, unsigned long val, struct fb_var_screeninfo *var, struct fb_info *info)
{
	struct __fb_timings timings;
	unsigned long interlace = 1, dscan = 1;
	unsigned long hfmin, hfmax, vfmin, vfmax, dclkmin, dclkmax;
	/* 
	 * If monspecs are invalid, use values that are enough
	 * for 640x480@60
	 */
	if(!info->monspecs.hfmax || !info->monspecs.vfmax
	 || !info->monspecs.dclkmax || info->monspecs.hfmax < info->monspecs.hfmin
	 || info->monspecs.vfmax < info->monspecs.vfmin || info->monspecs.dclkmax < info->monspecs.dclkmin)
	{
		hfmin = 29000; hfmax = 30000;
		vfmin = 60; vfmax = 60;
		dclkmin = 0; dclkmax = 25000000;
	}
	else
	{
		hfmin = info->monspecs.hfmin;
		hfmax = info->monspecs.hfmax;
		vfmin = info->monspecs.vfmin;
		vfmax = info->monspecs.vfmax;
		dclkmin = info->monspecs.dclkmin;
		dclkmax = info->monspecs.dclkmax;
	}
	memset((char *)&timings, 0, sizeof(struct __fb_timings));
	timings.hactive = var->xres;
	timings.vactive = var->yres;
	if(var->vmode & FB_VMODE_INTERLACED)
	{ 
		timings.vactive /= 2;
		interlace = 2;
	}
	if(var->vmode & FB_VMODE_DOUBLE)
	{
		timings.vactive *= 2;
		dscan = 2;
	}
	switch(flags & ~FB_IGNOREMON)
	{
		case FB_MAXTIMINGS: /* maximize refresh rate */
			timings.hfreq = hfmax;
			fb_timings_hfreq(&timings);
			if(timings.vfreq > vfmax)
			{
				timings.vfreq = vfmax;
				fb_timings_vfreq(&timings);
			}
			if(timings.dclk > dclkmax)
			{
				timings.dclk = dclkmax;
				fb_timings_dclk(&timings);
			}
			break;
		case FB_VSYNCTIMINGS: /* vrefresh driven */
			timings.vfreq = val;
			fb_timings_vfreq(&timings);
			break;
		case FB_HSYNCTIMINGS: /* hsync driven */
			timings.hfreq = val;
			fb_timings_hfreq(&timings);
			break;
		case FB_DCLKTIMINGS: /* pixelclock driven */
			timings.dclk = PICOS2KHZ(val) * 1000;
			fb_timings_dclk(&timings);
			break;
		default:
			return -EINVAL;
	} 
	if(!(flags & FB_IGNOREMON)
	 && (timings.vfreq < vfmin || timings.vfreq > vfmax
	  || timings.hfreq < hfmin || timings.hfreq > hfmax
	  || timings.dclk < dclkmin || timings.dclk > dclkmax))
		return -EINVAL;
	var->pixclock = KHZ2PICOS(timings.dclk/1000);
	var->hsync_len = (timings.htotal * 8)/100;
	var->right_margin = (timings.hblank/2) - var->hsync_len;
	var->left_margin = timings.hblank - var->right_margin - var->hsync_len;
	var->vsync_len = (3 * interlace)/dscan;
	var->lower_margin = (1 * interlace)/dscan;
	var->upper_margin = (timings.vblank * interlace)/dscan - (var->vsync_len + var->lower_margin);
	return 0;
}

#else

int fb_parse_edid(unsigned char *edid, struct fb_var_screeninfo *var)
{
	return 1;
}

void fb_edid_to_monspecs(unsigned char *edid, struct fb_monspecs *specs)
{
	specs = NULL;
}

void fb_destroy_modedb(struct fb_videomode *modedb)
{
}

int fb_get_mode(int flags, unsigned long val, struct fb_var_screeninfo *var, struct fb_info *info)
{
	return -EINVAL;
}

#endif /* CONFIG_FB_MODE_HELPERS */
	
/*
 * fb_validate_mode - validates var against monitor capabilities
 * @var: pointer to fb_var_screeninfo
 * @info: pointer to fb_info
 *
 * DESCRIPTION:
 * Validates video mode against monitor capabilities specified in
 * info->monspecs.
 *
 * REQUIRES:
 * A valid info->monspecs.
 */
int fb_validate_mode(const struct fb_var_screeninfo *var, struct fb_info *info)
{
	unsigned long hfreq, vfreq, htotal, vtotal, pixclock;
	unsigned long hfmin, hfmax, vfmin, vfmax, dclkmin, dclkmax;
	/* 
	 * If monspecs are invalid, use values that are enough
	 * for 640x480@60
	 */
	if(!info->monspecs.hfmax || !info->monspecs.vfmax || !info->monspecs.dclkmax
	 || info->monspecs.hfmax < info->monspecs.hfmin
	 || info->monspecs.vfmax < info->monspecs.vfmin
	 || info->monspecs.dclkmax < info->monspecs.dclkmin)
	{
		hfmin = 29000; hfmax = 30000;
		vfmin = 60; vfmax = 60;
		dclkmin = 0; dclkmax = 25000000;
	}
	else
	{
		hfmin = info->monspecs.hfmin;
		hfmax = info->monspecs.hfmax;
		vfmin = info->monspecs.vfmin;
		vfmax = info->monspecs.vfmax;
		dclkmin = info->monspecs.dclkmin;
		dclkmax = info->monspecs.dclkmax;
	}
	if(!var->pixclock)
		return -EINVAL;
	pixclock = PICOS2KHZ(var->pixclock) * 1000;
	htotal = var->xres + var->right_margin + var->hsync_len + var->left_margin;
	vtotal = var->yres + var->lower_margin + var->vsync_len + var->upper_margin;
	if(var->vmode & FB_VMODE_INTERLACED)
		vtotal /= 2;
	if(var->vmode & FB_VMODE_DOUBLE)
		vtotal *= 2;
	hfreq = pixclock/htotal;
	vfreq = hfreq/vtotal;
	return (vfreq < vfmin || vfreq > vfmax || hfreq < hfmin || hfreq > hfmax
	 ||	pixclock < dclkmin || pixclock > dclkmax) ?	-EINVAL : 0;
}

