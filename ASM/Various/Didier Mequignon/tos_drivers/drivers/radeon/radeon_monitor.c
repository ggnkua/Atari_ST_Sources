#include <mint/errno.h>
#include "radeonfb.h"
#include "edid.h"
#include "relocate.h"

#ifndef INT_MAX
#define INT_MAX ((int)(~0U>>1))
#endif

static struct fb_var_screeninfo radeonfb_default_var = {
	.xres		= 640,
	.yres		= 480,
	.xres_virtual	= 640,
	.yres_virtual	= 480,
	.bits_per_pixel = 8,
	.red		= { .length = 8 },
	.green		= { .length = 8 },
	.blue		= { .length = 8 },
	.activate	= FB_ACTIVATE_NOW,
	.height		= -1,
	.width		= -1,
	.pixclock	= 39721,
	.left_margin	= 40,
	.right_margin	= 24,
	.upper_margin	= 32,
	.lower_margin	= 11,
	.hsync_len	= 96,
	.vsync_len	= 2,
	.vmode		= FB_VMODE_NONINTERLACED
};

static char *radeon_get_mon_name(int type)
{
	char *pret = NULL;
	switch(type)
	{
		case MT_NONE:
			pret = "no";
			break;
		case MT_CRT:
			pret = "CRT";
			break;
		case MT_DFP:
			pret = "DFP";
			break;
		case MT_LCD:
			pret = "LCD";
			break;
		case MT_CTV:
			pret = "CTV";
			break;
		case MT_STV:
			pret = "STV";
			break;
	}
	return pret;
}

/*
 * Probe physical connection of a CRT. This code comes from XFree
 * as well and currently is only implemented for the CRT DAC, the
 * code for the TVDAC is commented out in XFree as "non working"
 */
static int radeon_crt_is_connected(struct radeonfb_info *rinfo, int is_crt_dac)
{
	int	connected = 0;
	/* the monitor either wasn't connected or it is a non-DDC CRT.
	 * try to probe it
   */
	if(is_crt_dac)
	{
		unsigned long ulOrigVCLK_ECP_CNTL;
		unsigned long ulOrigDAC_CNTL;
		unsigned long ulOrigDAC_EXT_CNTL;
		unsigned long ulOrigCRTC_EXT_CNTL;
		unsigned long ulData;
		unsigned long ulMask;
		ulOrigVCLK_ECP_CNTL = INPLL(VCLK_ECP_CNTL);
		ulData = ulOrigVCLK_ECP_CNTL;
		ulData &= ~(PIXCLK_ALWAYS_ONb | PIXCLK_DAC_ALWAYS_ONb);
		ulMask = ~(PIXCLK_ALWAYS_ONb | PIXCLK_DAC_ALWAYS_ONb);
		OUTPLLP(VCLK_ECP_CNTL, ulData, ulMask);
	 	ulOrigCRTC_EXT_CNTL = INREG(CRTC_EXT_CNTL);
		ulData = ulOrigCRTC_EXT_CNTL;
		ulData |= CRTC_CRT_ON;
		OUTREG(CRTC_EXT_CNTL, ulData);
		ulOrigDAC_EXT_CNTL = INREG(DAC_EXT_CNTL);
		ulData = ulOrigDAC_EXT_CNTL;
		ulData &= ~DAC_FORCE_DATA_MASK;
		ulData |= (DAC_FORCE_BLANK_OFF_EN | DAC_FORCE_DATA_EN | DAC_FORCE_DATA_SEL_MASK);
		if((rinfo->family == CHIP_FAMILY_RV250) || (rinfo->family == CHIP_FAMILY_RV280))
	    ulData |= (0x01b6 << DAC_FORCE_DATA_SHIFT);
		else
	    ulData |= (0x01ac << DAC_FORCE_DATA_SHIFT);
		OUTREG(DAC_EXT_CNTL, ulData);
 		ulOrigDAC_CNTL = INREG(DAC_CNTL);
		ulData = ulOrigDAC_CNTL;
		ulData |= DAC_CMP_EN;
		ulData &= ~(DAC_RANGE_CNTL_MASK | DAC_PDWN);
		ulData |= 0x2;
		OUTREG(DAC_CNTL, ulData);
		mdelay(1);
		ulData = INREG(DAC_CNTL);
		connected = (DAC_CMP_OUTPUT & ulData) ? 1 : 0;
		ulData = ulOrigVCLK_ECP_CNTL;
		ulMask = 0xFFFFFFFFL;
		OUTPLLP(VCLK_ECP_CNTL, ulData, ulMask);
		OUTREG(DAC_CNTL, ulOrigDAC_CNTL);
		OUTREG(DAC_EXT_CNTL, ulOrigDAC_EXT_CNTL );
		OUTREG(CRTC_EXT_CNTL, ulOrigCRTC_EXT_CNTL);
	}
	return connected ? MT_CRT : MT_NONE;
}

/*
 * Parse the "monitor_layout" string if any. This code is mostly
 * copied from XFree's radeon driver
 */
static int radeon_parse_monitor_layout(struct radeonfb_info *rinfo, const char *monitor_layout)
{
	char s1[5], s2[5];
	int i = 0, second = 0;
	const char *s;
	if((monitor_layout == NULL) || (*monitor_layout == '\0'))
		return 0;
	s = monitor_layout;
	do
	{
		switch(*s)
		{
			case ',':
				s1[i] = '\0';
				i = 0;
				second = 1;
				break;
			case ' ':
			case '\0':
				break;
			default:
				if(i >= 4)
					break;
				if(second)
					s2[i] = *s;
				else
					s1[i] = *s;
				i++;
				break;				
		}
	}
	while(*s++);
	if(second)
		s2[i] = '\0';
	else
	{
		s1[i] = '\0';
		s2[0] = '\0';
	}
	if(Funcs_equal(s1, "CRT"))
		rinfo->mon1_type = MT_CRT;
	else if(Funcs_equal(s1, "TMDS"))
		rinfo->mon1_type = MT_DFP;
	else if(Funcs_equal(s1, "LVDS"))
		rinfo->mon1_type = MT_LCD;
	if(Funcs_equal(s2, "CRT"))
		rinfo->mon2_type = MT_CRT;
	else if(Funcs_equal(s2, "TMDS"))
		rinfo->mon2_type = MT_DFP;
	else if(Funcs_equal(s2, "LVDS"))
		rinfo->mon2_type = MT_LCD;
	return 1;
}

/*
 * Probe display on both primary and secondary card's connector (if any)
 * by i2c and try to retreive EDID. The algorithm here comes from XFree's
 * radeon driver
 */
void radeon_probe_screens(struct radeonfb_info *rinfo,
     const char *monitor_layout, int ignore_edid)
{
#ifdef CONFIG_FB_RADEON_I2C
	int ddc_crt2_used = 0;	
#endif
	if(radeon_parse_monitor_layout(rinfo, monitor_layout))
	{
		/*
		 * If user specified a monitor_layout option, use it instead
		 * of auto-detecting. Maybe we should only use this argument
		 * on the first radeon card probed or provide a way to specify
		 * a layout for each card ?
		 */
#ifdef CONFIG_FB_RADEON_I2C
		DPRINT("radeonfb: radeon_probe_screens: use monitor layout\r\n");
		if(!ignore_edid)
		{
			if(rinfo->mon1_type != MT_NONE)
			{
				DPRINT("radeonfb: radeon_probe_screens: probe ddc_dvi on MON1\r\n");
				if(!radeon_probe_i2c_connector(rinfo, ddc_dvi, &rinfo->mon1_EDID))
				{
					DPRINT("radeonfb: radeon_probe_screens: probe ddc_crt2 on MON1\r\n");
					radeon_probe_i2c_connector(rinfo, ddc_crt2, &rinfo->mon1_EDID);
					ddc_crt2_used = 1;
				}
			}
			if(rinfo->mon2_type != MT_NONE)
			{
				DPRINT("radeonfb: radeon_probe_screens: probe ddc_vga on MON2\r\n");
				if(!radeon_probe_i2c_connector(rinfo, ddc_vga, &rinfo->mon2_EDID) && !ddc_crt2_used)
				{
					DPRINT("radeonfb: radeon_probe_screens: probe ddc_crt2 on MON2\r\n");
					radeon_probe_i2c_connector(rinfo, ddc_crt2, &rinfo->mon2_EDID);
				}
			}
		}
#endif /* CONFIG_FB_RADEON_I2C */
		if(rinfo->mon1_type == MT_NONE)
		{
			if(rinfo->mon2_type != MT_NONE)
			{
				rinfo->mon1_type = rinfo->mon2_type;
				rinfo->mon1_EDID = rinfo->mon2_EDID;
			}
			else
			{
				rinfo->mon1_type = MT_CRT;
				DPRINT("radeonfb: No valid monitor, assuming CRT on first port\r\n");
			}
			rinfo->mon2_type = MT_NONE;
			rinfo->mon2_EDID = NULL;
		}
	}
	else
	{
		/*
		 * Auto-detecting display type (well... trying to ...)
		 */
#ifdef CONFIG_FB_RADEON_I2C
		DPRINT("radeonfb: radeon_probe_screens: Auto-detecting\r\n");
#endif
#if 0 //#if DEBUG && defined(CONFIG_FB_RADEON_I2C)
		{
			unsigned char *EDIDs[4] = { NULL, NULL, NULL, NULL };
			int mon_types[4] = {MT_NONE, MT_NONE, MT_NONE, MT_NONE};
			int i;
			for(i = 0; i < 4; i++)
				mon_types[i] = radeon_probe_i2c_connector(rinfo, i+1, &EDIDs[i]);
		}
#endif /* DEBUG */
		/*
		 * Old single head cards
		 */
		if(!rinfo->has_CRTC2)
		{
#ifdef CONFIG_FB_RADEON_I2C
			if(rinfo->mon1_type == MT_NONE)
			{
				DPRINT("radeonfb: radeon_probe_screens: probe ddc_dvi on MON1\r\n");
				rinfo->mon1_type = radeon_probe_i2c_connector(rinfo, ddc_dvi, &rinfo->mon1_EDID);
			}
			if(rinfo->mon1_type == MT_NONE)
			{
				DPRINT("radeonfb: radeon_probe_screens: probe ddc_vga on MON1\r\n");
				rinfo->mon1_type = radeon_probe_i2c_connector(rinfo, ddc_vga, &rinfo->mon1_EDID);
			}
			if(rinfo->mon1_type == MT_NONE)
			{
				DPRINT("radeonfb: radeon_probe_screens: probe ddc_crt2 on MON1\r\n");
				rinfo->mon1_type = radeon_probe_i2c_connector(rinfo, ddc_crt2, &rinfo->mon1_EDID);
			}
#endif /* CONFIG_FB_RADEON_I2C */
			if(rinfo->mon1_type == MT_NONE)
				rinfo->mon1_type = MT_CRT;
			goto bail;
		}
		/*
		 * Probe primary head (DVI or laptop internal panel)
		 */
#ifdef CONFIG_FB_RADEON_I2C
		if(rinfo->mon1_type == MT_NONE)
		{
			DPRINT("radeonfb: radeon_probe_screens: probe ddc_dvi on MON1\r\n");
			rinfo->mon1_type = radeon_probe_i2c_connector(rinfo, ddc_dvi, &rinfo->mon1_EDID);
		}
		if(rinfo->mon1_type == MT_NONE)
		{
			DPRINT("radeonfb: radeon_probe_screens: probe ddc_crt2 on MON1\r\n");
			rinfo->mon1_type = radeon_probe_i2c_connector(rinfo, ddc_crt2, &rinfo->mon1_EDID);
			if(rinfo->mon1_type != MT_NONE)
				ddc_crt2_used = 1;
		}
#endif /* CONFIG_FB_RADEON_I2C */
		if(rinfo->mon1_type == MT_NONE && rinfo->is_mobility
		 && (INREG(LVDS_GEN_CNTL) & LVDS_ON))
		{
			rinfo->mon1_type = MT_LCD;
			DPRINT("Non-DDC laptop panel detected\r\n");
		}
		if(rinfo->mon1_type == MT_NONE)
			rinfo->mon1_type = radeon_crt_is_connected(rinfo, rinfo->reversed_DAC);
		/*
		 * Probe secondary head (mostly VGA, can be DVI)
		 */
#ifdef CONFIG_FB_RADEON_I2C
		if(rinfo->mon2_type == MT_NONE)
		{
			DPRINT("radeonfb: radeon_probe_screens: probe ddc_vga on MON2\r\n");
			rinfo->mon2_type = radeon_probe_i2c_connector(rinfo, ddc_vga,	&rinfo->mon2_EDID);
		}
		if(rinfo->mon2_type == MT_NONE && !ddc_crt2_used)
		{
			DPRINT("radeonfb: radeon_probe_screens: probe ddc_crt2 on MON2\r\n");
			rinfo->mon2_type = radeon_probe_i2c_connector(rinfo, ddc_crt2, &rinfo->mon2_EDID);
		}
#endif /* CONFIG_FB_RADEON_I2C */
		if(rinfo->mon2_type == MT_NONE)
			rinfo->mon2_type = radeon_crt_is_connected(rinfo, !rinfo->reversed_DAC);
		/*
		 * If we only detected port 2, we swap them, if none detected,
		 * assume CRT (maybe fallback to old BIOS_SCRATCH stuff ? or look
		 * at FP registers ?)
		 */
		if(rinfo->mon1_type == MT_NONE)
		{
			if(rinfo->mon2_type != MT_NONE)
			{
				rinfo->mon1_type = rinfo->mon2_type;
				rinfo->mon1_EDID = rinfo->mon2_EDID;
			}
			else
				rinfo->mon1_type = MT_CRT;
			rinfo->mon2_type = MT_NONE;
			rinfo->mon2_EDID = NULL;
		}
		/*
		 * Deal with reversed TMDS
		 */
		if(rinfo->reversed_TMDS)
		{
			/* Always keep internal TMDS as primary head */
			if(rinfo->mon1_type == MT_DFP || rinfo->mon2_type == MT_DFP)
			{
				int tmp_type = rinfo->mon1_type;
				unsigned char *tmp_EDID = rinfo->mon1_EDID;
				rinfo->mon1_type = rinfo->mon2_type;
				rinfo->mon1_EDID = rinfo->mon2_EDID;
				rinfo->mon2_type = tmp_type;
				rinfo->mon2_EDID = tmp_EDID;
				if(rinfo->mon1_type == MT_CRT || rinfo->mon2_type == MT_CRT)
					rinfo->reversed_DAC ^= 1;
			}
		}
	}
	if(ignore_edid)
	{
		Funcs_free(rinfo->mon1_EDID);
		rinfo->mon1_EDID = NULL;
		Funcs_free(rinfo->mon2_EDID);
		rinfo->mon2_EDID = NULL;
	}
bail:
	DPRINT("radeonfb: Monitor 1 type ");
	DPRINT(radeon_get_mon_name(rinfo->mon1_type));
	DPRINT(" found\r\n");
	if(rinfo->mon1_EDID)
	{
		DPRINT("radeonfb: EDID probed\r\n");
	}
	if(!rinfo->has_CRTC2)
		return;
	DPRINT("radeonfb: Monitor 2 type ");
	DPRINT(radeon_get_mon_name(rinfo->mon2_type));
	DPRINT(" found\r\n");
	if(rinfo->mon2_EDID)
	{
		DPRINT("radeonfb: EDID probed\r\n");
	}
}

/*
 * Fill up panel infos from a mode definition, either returned by the EDID
 * or from the default mode when we can't do any better
 */
static void radeon_var_to_panel_info(struct radeonfb_info *rinfo, struct fb_var_screeninfo *var)
{
	rinfo->panel_info.xres = var->xres;
	rinfo->panel_info.yres = var->yres;
	rinfo->panel_info.clock = 100000000 / var->pixclock;
	rinfo->panel_info.hOver_plus = var->right_margin;
	rinfo->panel_info.hSync_width = var->hsync_len;
	rinfo->panel_info.hblank = var->left_margin + (var->right_margin + var->hsync_len);
	rinfo->panel_info.vOver_plus = var->lower_margin;
	rinfo->panel_info.vSync_width = var->vsync_len;
	rinfo->panel_info.vblank = var->upper_margin + (var->lower_margin + var->vsync_len);
	rinfo->panel_info.hAct_high = (var->sync & FB_SYNC_HOR_HIGH_ACT) != 0;
	rinfo->panel_info.vAct_high = (var->sync & FB_SYNC_VERT_HIGH_ACT) != 0;
	rinfo->panel_info.valid = 1;
	/* We use a default of 200ms for the panel power delay, 
	 * I need to have a real schedule() instead of mdelay's in the panel code.
	 * we might be possible to figure out a better power delay either from
	 * MacOS OF tree or from the EDID block (proprietary extensions ?)
	 */
	rinfo->panel_info.pwr_delay = 200;
}

static void radeon_videomode_to_var(struct fb_var_screeninfo *var,
       const struct fb_videomode *mode)
{
	var->xres = mode->xres;
	var->yres = mode->yres;
	var->xres_virtual = mode->xres;
	var->yres_virtual = mode->yres;
	var->xoffset = 0;
	var->yoffset = 0;
	var->pixclock = mode->pixclock;
	var->left_margin = mode->left_margin;
	var->right_margin = mode->right_margin;
	var->upper_margin = mode->upper_margin;
	var->lower_margin = mode->lower_margin;
	var->hsync_len = mode->hsync_len;
	var->vsync_len = mode->vsync_len;
	var->sync = mode->sync;
	var->vmode = mode->vmode;
}

/*
 * Build the modedb for head 1 (head 2 will come later), check panel infos
 * from either BIOS or EDID, and pick up the default mode
 */
void radeon_check_modes(struct radeonfb_info *rinfo, struct mode_option *resolution)
{
	struct fb_info *info = rinfo->info;
	int has_default_mode = 0;
	struct mode_option xres_yres;
	DPRINT("radeonfb: radeon_check_modes\r\n");
	/*
	 * Fill default var first
	 */
	memcpy(&info->var, &radeonfb_default_var, sizeof(struct fb_var_screeninfo));
	/*
	 * Parse EDID detailed timings and deduce panel infos if any. Right now
	 * we only deal with first entry returned by parse_EDID, we may do better
	 * some day...
	 */
	if(!rinfo->panel_info.use_bios_dividers
	 && rinfo->mon1_type != MT_CRT && rinfo->mon1_EDID)
	{
		struct fb_var_screeninfo var;
		DPRINT("radeonfb: radeon_check_modes: fb_parse_edid\r\n");
		if(fb_parse_edid(rinfo->mon1_EDID, &var) == 0)
		{
			if((var.xres >= rinfo->panel_info.xres) && (var.yres >= rinfo->panel_info.yres))
				radeon_var_to_panel_info(rinfo, &var);
		}
		else
		{
			DPRINT("radeonfb: radeon_check_modes: no data to parse\r\n");
		}
	}
	/*
	 * If we have some valid panel infos, we setup the default mode based on
	 * those
	 */
	if(rinfo->mon1_type != MT_CRT && rinfo->panel_info.valid)
	{
		struct fb_var_screeninfo *var = &info->var;
		DPRINT("radeonfb: radeon_check_modes: setup the default mode based on panel info\r\n");
		var->xres = rinfo->panel_info.xres;
		var->yres = rinfo->panel_info.yres;
		var->xres_virtual = rinfo->panel_info.xres;
		var->yres_virtual = rinfo->panel_info.yres;
		var->xoffset = var->yoffset = 0;
		var->bits_per_pixel = 8;
		var->pixclock = 100000000 / rinfo->panel_info.clock;
		var->left_margin = (rinfo->panel_info.hblank - rinfo->panel_info.hOver_plus - rinfo->panel_info.hSync_width);
		var->right_margin = rinfo->panel_info.hOver_plus;
		var->upper_margin = (rinfo->panel_info.vblank - rinfo->panel_info.vOver_plus - rinfo->panel_info.vSync_width);
		var->lower_margin = rinfo->panel_info.vOver_plus;
		var->hsync_len = rinfo->panel_info.hSync_width;
		var->vsync_len = rinfo->panel_info.vSync_width;
		var->sync = 0;
		if(rinfo->panel_info.hAct_high)
			var->sync |= FB_SYNC_HOR_HIGH_ACT;
		if(rinfo->panel_info.vAct_high)
			var->sync |= FB_SYNC_VERT_HIGH_ACT;
		var->vmode = 0;
		has_default_mode = 1;
	}
	/*
	 * Now build modedb from EDID
	 */
	if(rinfo->mon1_EDID)
	{
		fb_edid_to_monspecs(rinfo->mon1_EDID, &info->monspecs);
		rinfo->mon1_modedb = info->monspecs.modedb;
		rinfo->mon1_dbsize = info->monspecs.modedb_len;
	}
	/*
	 * Finally, if we don't have panel infos we need to figure some (or
	 * we try to read it from card), we try to pick a default mode
	 * and create some panel infos. Whatever...
	 */
	if(rinfo->mon1_type != MT_CRT && !rinfo->panel_info.valid)
	{
		struct fb_videomode	*modedb;
		int dbsize;
		if(rinfo->panel_info.xres == 0 || rinfo->panel_info.yres == 0)
		{
			unsigned long tmp = INREG(FP_HORZ_STRETCH) & HORZ_PANEL_SIZE;
			rinfo->panel_info.xres = ((tmp >> HORZ_PANEL_SHIFT) + 1) * 8;
			tmp = INREG(FP_VERT_STRETCH) & VERT_PANEL_SIZE;
			rinfo->panel_info.yres = (tmp >> VERT_PANEL_SHIFT) + 1;
		}
		if((rinfo->panel_info.xres <= 8) || (rinfo->panel_info.yres <= 1))
		{
			rinfo->mon1_type = MT_CRT;
			goto pickup_default;
		}
		modedb = rinfo->mon1_modedb;
		dbsize = rinfo->mon1_dbsize;
		xres_yres.used = 1;
		xres_yres.width = rinfo->panel_info.xres;
		xres_yres.height = rinfo->panel_info.yres;
		xres_yres.bpp = xres_yres.freq = 0;
		if(fb_find_mode(&info->var, info, &xres_yres, modedb, dbsize, NULL, (resolution->bpp >= 8) ? (unsigned int)resolution->bpp : 8) == 0)
		{
			rinfo->mon1_type = MT_CRT;
			goto pickup_default;
		}
		has_default_mode = 1;
		radeon_var_to_panel_info(rinfo, &info->var);
	}
pickup_default:
	/*
	 * Apply passed-in mode option if any
	 */
	if(resolution->used)
	{
		if(fb_find_mode(&info->var, info, resolution, info->monspecs.modedb,
		 info->monspecs.modedb_len, NULL, (resolution->bpp >= 8) ? (unsigned int)resolution->bpp : 8) != 0)
			has_default_mode = 1;
 	}
	/*
	 * Still no mode, let's pick up a default from the db
	 */
	if(!has_default_mode && info->monspecs.modedb != NULL)
	{
		struct fb_monspecs *specs = &info->monspecs;
		struct fb_videomode *modedb = NULL;
		/* get preferred timing */
		if(specs->misc & FB_MISC_1ST_DETAIL)
		{
			int i;
			for(i = 0; i < specs->modedb_len; i++)
			{
				if(specs->modedb[i].flag & FB_MODE_IS_FIRST)
				{
					modedb = &specs->modedb[i];
					break;
				}
			}
		}
		else
		{
			/* otherwise, get first mode in database */
			modedb = &specs->modedb[0];
		}
		if(modedb != NULL)
		{
			info->var.bits_per_pixel = 8;
			radeon_videomode_to_var(&info->var, modedb);
			has_default_mode = 1;
		}
	}
}

/*
 * The code below is used to pick up a mode in check_var and
 * set_var. It should be made generic
 */

/*
 * This is used when looking for modes. We assign a "distance" value
 * to a mode in the modedb depending how "close" it is from what we
 * are looking for.
 * Currently, we don't compare that much, we could do better but
 * the current fbcon doesn't quite mind ;)
 */
static int radeon_compare_modes(const struct fb_var_screeninfo *var,
				const struct fb_videomode *mode)
{
	int distance = 0;
	distance = mode->yres - var->yres;
	distance += (mode->xres - var->xres)/2;
	return distance;
}

/*
 * This function is called by check_var, it gets the passed in mode parameter, and
 * outputs a valid mode matching the passed-in one as closely as possible.
 * We need something better ultimately.
 */
int radeon_match_mode(struct radeonfb_info *rinfo,
		       struct fb_var_screeninfo *dest,
		       const struct fb_var_screeninfo *src)
{
	const struct fb_videomode	*db = vesa_modes;
	int i, dbsize = 34;
	int has_rmx, native_db = 0;
	int	distance = INT_MAX;
	const struct fb_videomode	*candidate = NULL;
	DPRINT("radeonfb: radeon_match_mode\r\n");
	/* Start with a copy of the requested mode */
	memcpy(dest, src, sizeof(struct fb_var_screeninfo));
	/* Check if we have a modedb built from EDID */
	if(rinfo->mon1_modedb)
	{
		db = rinfo->mon1_modedb;
		dbsize = rinfo->mon1_dbsize;
		native_db = 1;
	}
	/* Check if we have a scaler allowing any fancy mode */
	has_rmx = (rinfo->mon1_type == MT_LCD) || (rinfo->mon1_type == MT_DFP);
	/* If we have a scaler and are passed FB_ACTIVATE_TEST or
	 * FB_ACTIVATE_NOW, just do basic checking and return if the
	 * mode match
	 */
	if((src->activate & FB_ACTIVATE_MASK) == FB_ACTIVATE_TEST
	 || (src->activate & FB_ACTIVATE_MASK) == FB_ACTIVATE_NOW)
	{
		/* We don't have an RMX, validate timings. If we don't have
	 	 * monspecs, we should be paranoid and not let use go above
		 * 640x480-60, but I assume userland knows what it's doing here
		 * (though I may be proven wrong...)
		 */
		if((has_rmx == 0) && rinfo->mon1_modedb)
		{
			if(fb_validate_mode((struct fb_var_screeninfo *)src, rinfo->info))
				return -EINVAL;
		}
		return 0;
	}
	DPRINT("radeonfb: radeon_match_mode, look for a mode in the database\r\n");
	/* Now look for a mode in the database */
	while(db)
	{
		for(i = 0; i < dbsize; i++)
		{
			int d;
			if((db[i].yres < src->yres) || (db[i].xres < src->xres))
				continue;
			d = radeon_compare_modes(src, &db[i]);
			/* If the new mode is at least as good as the previous one,
			 * then it's our new candidate
			 */
			if(d < distance)
			{
				candidate = &db[i];
				distance = d;
			}
		}
		db = NULL;
		/* If we have a scaler, we allow any mode from the database */
		if(native_db && has_rmx)
		{
			db = vesa_modes;
			dbsize = 34;
			native_db = 0;
		}
	}
	/* If we have found a match, return it */
	if(candidate != NULL)
	{
		radeon_videomode_to_var(dest, candidate);
		return 0;
	}
	/* If we haven't and don't have a scaler, fail */
	if(!has_rmx)
		return -EINVAL;
	return 0;
}
