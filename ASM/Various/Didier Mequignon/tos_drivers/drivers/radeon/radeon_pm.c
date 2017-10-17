/*
 *	radeon_pm.c
 *
 *	Copyright 2003,2004 Ben. Herrenschmidt <benh@kernel.crashing.org>
 *	Copyright 2004 Paul Mackerras <paulus@samba.org>
 *
 *	This is the power management code for ATI radeon chipsets. It contains
 *	some dynamic clock PM enable/disable code similar to what X.org does,
 *	some D2-state (APM-style) sleep/wakeup code for use on some PowerMacs,
 *	and the necessary bits to re-initialize from scratch a few chips found
 *	on PowerMacs as well. The later could be extended to more platforms
 *	provided the memory controller configuration code be made more generic,
 *	and you can get the proper mode register commands for your RAMs.
 *	Those things may be found in the BIOS image...
 */

#include "radeonfb.h"
#include "ati_ids.h"

#if 0

void radeon_pm_disable_dynamic_mode(struct radeonfb_info *rinfo)
{
	unsigned long tmp;
	/* RV100 */
	if((rinfo->family == CHIP_FAMILY_RV100) && (!rinfo->is_mobility))
	{
		if(rinfo->has_CRTC2)
		{
			tmp = INPLL(pllSCLK_CNTL);
			tmp &= ~SCLK_CNTL__DYN_STOP_LAT_MASK;
			tmp |= SCLK_CNTL__CP_MAX_DYN_STOP_LAT | SCLK_CNTL__FORCEON_MASK;
			OUTPLL(pllSCLK_CNTL, tmp);
		}
		tmp = INPLL(pllMCLK_CNTL);
		tmp |= (MCLK_CNTL__FORCE_MCLKA | MCLK_CNTL__FORCE_MCLKB | MCLK_CNTL__FORCE_YCLKA
		 | MCLK_CNTL__FORCE_YCLKB | MCLK_CNTL__FORCE_AIC | MCLK_CNTL__FORCE_MC);
		OUTPLL(pllMCLK_CNTL, tmp);
		return;
	}
	/* R100 */
	if(!rinfo->has_CRTC2)
	{
		tmp = INPLL(pllSCLK_CNTL);
		tmp |= (SCLK_CNTL__FORCE_CP	| SCLK_CNTL__FORCE_HDP | SCLK_CNTL__FORCE_DISP1
		 | SCLK_CNTL__FORCE_TOP	| SCLK_CNTL__FORCE_E2	| SCLK_CNTL__FORCE_SE
		 | SCLK_CNTL__FORCE_IDCT | SCLK_CNTL__FORCE_VIP | SCLK_CNTL__FORCE_RE
		 | SCLK_CNTL__FORCE_PB | SCLK_CNTL__FORCE_TAM	| SCLK_CNTL__FORCE_TDM | SCLK_CNTL__FORCE_RB);
			OUTPLL(pllSCLK_CNTL, tmp);
		return;
	}
	/* RV350 (M10) */
	if(rinfo->family == CHIP_FAMILY_RV350)
	{
		/* for RV350/M10, no delays are required. */
		tmp = INPLL(pllSCLK_CNTL2);
		tmp |= (SCLK_CNTL2__R300_FORCE_TCL | SCLK_CNTL2__R300_FORCE_GA | SCLK_CNTL2__R300_FORCE_CBA);
		OUTPLL(pllSCLK_CNTL2, tmp);
		tmp = INPLL(pllSCLK_CNTL);
		tmp |= (SCLK_CNTL__FORCE_DISP2 | SCLK_CNTL__FORCE_CP | SCLK_CNTL__FORCE_HDP
		 | SCLK_CNTL__FORCE_DISP1 | SCLK_CNTL__FORCE_TOP | SCLK_CNTL__FORCE_E2
		 | SCLK_CNTL__R300_FORCE_VAP | SCLK_CNTL__FORCE_IDCT | SCLK_CNTL__FORCE_VIP
		 | SCLK_CNTL__R300_FORCE_SR	| SCLK_CNTL__R300_FORCE_PX | SCLK_CNTL__R300_FORCE_TX
		 | SCLK_CNTL__R300_FORCE_US	| SCLK_CNTL__FORCE_TV_SCLK | SCLK_CNTL__R300_FORCE_SU	| SCLK_CNTL__FORCE_OV0);
			OUTPLL(pllSCLK_CNTL, tmp);
		tmp = INPLL(pllSCLK_MORE_CNTL);
		tmp |= (SCLK_MORE_CNTL__FORCE_DISPREGS | SCLK_MORE_CNTL__FORCE_MC_GUI	| SCLK_MORE_CNTL__FORCE_MC_HOST);
		OUTPLL(pllSCLK_MORE_CNTL, tmp);
		tmp = INPLL(pllMCLK_CNTL);
		tmp |= (MCLK_CNTL__FORCE_MCLKA | MCLK_CNTL__FORCE_MCLKB
		 | MCLK_CNTL__FORCE_YCLKA | MCLK_CNTL__FORCE_YCLKB |	MCLK_CNTL__FORCE_MC);
		OUTPLL(pllMCLK_CNTL, tmp);
		tmp = INPLL(pllVCLK_ECP_CNTL);
		tmp &= ~(VCLK_ECP_CNTL__PIXCLK_ALWAYS_ONb | VCLK_ECP_CNTL__PIXCLK_DAC_ALWAYS_ONb
		 | VCLK_ECP_CNTL__R300_DISP_DAC_PIXCLK_DAC_BLANK_OFF);
		OUTPLL(pllVCLK_ECP_CNTL, tmp);
		tmp = INPLL(pllPIXCLKS_CNTL);
		tmp &= ~(PIXCLKS_CNTL__PIX2CLK_ALWAYS_ONb	|	PIXCLKS_CNTL__PIX2CLK_DAC_ALWAYS_ONb
		 | PIXCLKS_CNTL__DISP_TVOUT_PIXCLK_TV_ALWAYS_ONb | PIXCLKS_CNTL__R300_DVOCLK_ALWAYS_ONb
		 | PIXCLKS_CNTL__PIXCLK_BLEND_ALWAYS_ONb | PIXCLKS_CNTL__PIXCLK_GV_ALWAYS_ONb
		 | PIXCLKS_CNTL__R300_PIXCLK_DVO_ALWAYS_ONb	| PIXCLKS_CNTL__PIXCLK_LVDS_ALWAYS_ONb
		 | PIXCLKS_CNTL__PIXCLK_TMDS_ALWAYS_ONb | PIXCLKS_CNTL__R300_PIXCLK_TRANS_ALWAYS_ONb
		 | PIXCLKS_CNTL__R300_PIXCLK_TVO_ALWAYS_ONb	| PIXCLKS_CNTL__R300_P2G2CLK_ALWAYS_ONb
		 | PIXCLKS_CNTL__R300_P2G2CLK_ALWAYS_ONb | PIXCLKS_CNTL__R300_DISP_DAC_PIXCLK_DAC2_BLANK_OFF);
		OUTPLL(pllPIXCLKS_CNTL, tmp);
		return;
	}
	/* Default */
	/* Force Core Clocks */
	tmp = INPLL(pllSCLK_CNTL);
	tmp |= (SCLK_CNTL__FORCE_CP | SCLK_CNTL__FORCE_E2);
	/* XFree doesn't do that case, but we had this code from Apple and it
	 * seem necessary for proper suspend/resume operations
	 */
	if(rinfo->is_mobility)
	{
		tmp |= SCLK_CNTL__FORCE_HDP |	SCLK_CNTL__FORCE_DISP1 | SCLK_CNTL__FORCE_DISP2
		 | SCLK_CNTL__FORCE_TOP | SCLK_CNTL__FORCE_SE | SCLK_CNTL__FORCE_IDCT
		 | SCLK_CNTL__FORCE_VIP | SCLK_CNTL__FORCE_PB | SCLK_CNTL__FORCE_RE
		 | SCLK_CNTL__FORCE_TAM | SCLK_CNTL__FORCE_TDM | SCLK_CNTL__FORCE_RB
		 | SCLK_CNTL__FORCE_TV_SCLK | SCLK_CNTL__FORCE_SUBPIC | SCLK_CNTL__FORCE_OV0;
	}                                                        
	else if(rinfo->family == CHIP_FAMILY_R300 || rinfo->family == CHIP_FAMILY_R350)
	{
		tmp |=  SCLK_CNTL__FORCE_HDP | SCLK_CNTL__FORCE_DISP1 | SCLK_CNTL__FORCE_DISP2
		 | SCLK_CNTL__FORCE_TOP | SCLK_CNTL__FORCE_IDCT | SCLK_CNTL__FORCE_VIP;
	}
	OUTPLL(pllSCLK_CNTL, tmp);
	radeon_msleep(16);
	if(rinfo->family == CHIP_FAMILY_R300 || rinfo->family == CHIP_FAMILY_R350)
	{
		tmp = INPLL(pllSCLK_CNTL2);
		tmp |=  SCLK_CNTL2__R300_FORCE_TCL | SCLK_CNTL2__R300_FORCE_GA | SCLK_CNTL2__R300_FORCE_CBA;
		OUTPLL(pllSCLK_CNTL2, tmp);
		radeon_msleep(16);
	}
	tmp = INPLL(pllCLK_PIN_CNTL);
	tmp &= ~CLK_PIN_CNTL__SCLK_DYN_START_CNTL;
	OUTPLL(pllCLK_PIN_CNTL, tmp);
	radeon_msleep(15);
	if(rinfo->is_IGP)
	{
		/* Weird  ... X is _un_ forcing clocks here, I think it's
		 * doing backward. Imitate it for now...
		 */
		tmp = INPLL(pllMCLK_CNTL);
		tmp &= ~(MCLK_CNTL__FORCE_MCLKA | MCLK_CNTL__FORCE_YCLKA);
		OUTPLL(pllMCLK_CNTL, tmp);
		radeon_msleep(16);
	}
	/* Hrm... same shit, X doesn't do that but I have to */
	else if (rinfo->is_mobility)
	{
		tmp = INPLL(pllMCLK_CNTL);
		tmp |= (MCLK_CNTL__FORCE_MCLKA | MCLK_CNTL__FORCE_MCLKB
		 | MCLK_CNTL__FORCE_YCLKA |	MCLK_CNTL__FORCE_YCLKB);
		OUTPLL(pllMCLK_CNTL, tmp);
		radeon_msleep(16);
		tmp = INPLL(pllMCLK_MISC);
		tmp &= 	~(MCLK_MISC__MC_MCLK_MAX_DYN_STOP_LAT| MCLK_MISC__IO_MCLK_MAX_DYN_STOP_LAT
		 | MCLK_MISC__MC_MCLK_DYN_ENABLE | MCLK_MISC__IO_MCLK_DYN_ENABLE);
		OUTPLL(pllMCLK_MISC, tmp);
		radeon_msleep(15);
	}
	if(rinfo->is_mobility)
	{
		tmp = INPLL(pllSCLK_MORE_CNTL);
		tmp |= 	SCLK_MORE_CNTL__FORCE_DISPREGS | SCLK_MORE_CNTL__FORCE_MC_GUI
		 | SCLK_MORE_CNTL__FORCE_MC_HOST;
		OUTPLL(pllSCLK_MORE_CNTL, tmp);
		radeon_msleep(16);
	}
	tmp = INPLL(pllPIXCLKS_CNTL);
	tmp &= ~(PIXCLKS_CNTL__PIXCLK_GV_ALWAYS_ONb | PIXCLKS_CNTL__PIXCLK_BLEND_ALWAYS_ONb
	 | PIXCLKS_CNTL__PIXCLK_DIG_TMDS_ALWAYS_ONb | PIXCLKS_CNTL__PIXCLK_LVDS_ALWAYS_ONb
	 | PIXCLKS_CNTL__PIXCLK_TMDS_ALWAYS_ONb | PIXCLKS_CNTL__PIX2CLK_ALWAYS_ONb
	 | PIXCLKS_CNTL__PIX2CLK_DAC_ALWAYS_ONb);
 	OUTPLL(pllPIXCLKS_CNTL, tmp);
	radeon_msleep(16);
	tmp = INPLL( pllVCLK_ECP_CNTL);
	tmp &= ~(VCLK_ECP_CNTL__PIXCLK_ALWAYS_ONb | VCLK_ECP_CNTL__PIXCLK_DAC_ALWAYS_ONb);
	OUTPLL( pllVCLK_ECP_CNTL, tmp);
	radeon_msleep(16);
}

static void radeon_pm_enable_dynamic_mode(struct radeonfb_info *rinfo)
{
	unsigned long tmp;
	/* R100 */
	if(!rinfo->has_CRTC2)
	{
		tmp = INPLL(pllSCLK_CNTL);
		if((INREG(CONFIG_CNTL) & CFG_ATI_REV_ID_MASK) > CFG_ATI_REV_A13)
			tmp &= ~(SCLK_CNTL__FORCE_CP | SCLK_CNTL__FORCE_RB);
		tmp &= ~(SCLK_CNTL__FORCE_HDP | SCLK_CNTL__FORCE_DISP1 | SCLK_CNTL__FORCE_TOP
		 | SCLK_CNTL__FORCE_SE | SCLK_CNTL__FORCE_IDCT | SCLK_CNTL__FORCE_RE
		 | SCLK_CNTL__FORCE_PB | SCLK_CNTL__FORCE_TAM | SCLK_CNTL__FORCE_TDM);
		OUTPLL(pllSCLK_CNTL, tmp);
		return;
	}
	/* M10 */
	if(rinfo->family == CHIP_FAMILY_RV350)
	{
		tmp = INPLL(pllSCLK_CNTL2);
		tmp &= ~(SCLK_CNTL2__R300_FORCE_TCL | SCLK_CNTL2__R300_FORCE_GA | SCLK_CNTL2__R300_FORCE_CBA);
		tmp |=  (SCLK_CNTL2__R300_TCL_MAX_DYN_STOP_LAT | SCLK_CNTL2__R300_GA_MAX_DYN_STOP_LAT
		 | SCLK_CNTL2__R300_CBA_MAX_DYN_STOP_LAT);
		OUTPLL(pllSCLK_CNTL2, tmp);
		tmp = INPLL(pllSCLK_CNTL);
		tmp &= ~(SCLK_CNTL__FORCE_DISP2 | SCLK_CNTL__FORCE_CP | SCLK_CNTL__FORCE_HDP
		 | SCLK_CNTL__FORCE_DISP1 | SCLK_CNTL__FORCE_TOP | SCLK_CNTL__FORCE_E2
		 | SCLK_CNTL__R300_FORCE_VAP | SCLK_CNTL__FORCE_IDCT | SCLK_CNTL__FORCE_VIP
		 | SCLK_CNTL__R300_FORCE_SR | SCLK_CNTL__R300_FORCE_PX | SCLK_CNTL__R300_FORCE_TX
		 | SCLK_CNTL__R300_FORCE_US | SCLK_CNTL__FORCE_TV_SCLK | SCLK_CNTL__R300_FORCE_SU | SCLK_CNTL__FORCE_OV0);
		tmp |= SCLK_CNTL__DYN_STOP_LAT_MASK;
		OUTPLL(pllSCLK_CNTL, tmp);
		tmp = INPLL(pllSCLK_MORE_CNTL);
		tmp &= ~SCLK_MORE_CNTL__FORCEON;
		tmp |=  SCLK_MORE_CNTL__DISPREGS_MAX_DYN_STOP_LAT |	SCLK_MORE_CNTL__MC_GUI_MAX_DYN_STOP_LAT
		 | SCLK_MORE_CNTL__MC_HOST_MAX_DYN_STOP_LAT;
		OUTPLL(pllSCLK_MORE_CNTL, tmp);
		tmp = INPLL(pllVCLK_ECP_CNTL);
		tmp |= (VCLK_ECP_CNTL__PIXCLK_ALWAYS_ONb | VCLK_ECP_CNTL__PIXCLK_DAC_ALWAYS_ONb);
		OUTPLL(pllVCLK_ECP_CNTL, tmp);
		tmp = INPLL(pllPIXCLKS_CNTL);
		tmp |= (PIXCLKS_CNTL__PIX2CLK_ALWAYS_ONb | PIXCLKS_CNTL__PIX2CLK_DAC_ALWAYS_ONb
		 | PIXCLKS_CNTL__DISP_TVOUT_PIXCLK_TV_ALWAYS_ONb | PIXCLKS_CNTL__R300_DVOCLK_ALWAYS_ONb
		 | PIXCLKS_CNTL__PIXCLK_BLEND_ALWAYS_ONb | PIXCLKS_CNTL__PIXCLK_GV_ALWAYS_ONb
		 | PIXCLKS_CNTL__R300_PIXCLK_DVO_ALWAYS_ONb | PIXCLKS_CNTL__PIXCLK_LVDS_ALWAYS_ONb
		 | PIXCLKS_CNTL__PIXCLK_TMDS_ALWAYS_ONb | PIXCLKS_CNTL__R300_PIXCLK_TRANS_ALWAYS_ONb
		 | PIXCLKS_CNTL__R300_PIXCLK_TVO_ALWAYS_ONb | PIXCLKS_CNTL__R300_P2G2CLK_ALWAYS_ONb
		 | PIXCLKS_CNTL__R300_P2G2CLK_ALWAYS_ONb);
		OUTPLL(pllPIXCLKS_CNTL, tmp);
		tmp = INPLL(pllMCLK_MISC);
		tmp |= (MCLK_MISC__MC_MCLK_DYN_ENABLE | MCLK_MISC__IO_MCLK_DYN_ENABLE);
		OUTPLL(pllMCLK_MISC, tmp);
		tmp = INPLL(pllMCLK_CNTL);
		tmp |= (MCLK_CNTL__FORCE_MCLKA | MCLK_CNTL__FORCE_MCLKB);
		tmp &= ~(MCLK_CNTL__FORCE_YCLKA | MCLK_CNTL__FORCE_YCLKB | MCLK_CNTL__FORCE_MC);
		/* Some releases of vbios have set DISABLE_MC_MCLKA
		 * and DISABLE_MC_MCLKB bits in the vbios table.  Setting these
		 * bits will cause H/W hang when reading video memory with dynamic
		 * clocking enabled.
		 */
		if((tmp & MCLK_CNTL__R300_DISABLE_MC_MCLKA) && (tmp & MCLK_CNTL__R300_DISABLE_MC_MCLKB))
		{
			/* If both bits are set, then check the active channels */
			tmp = INPLL(pllMCLK_CNTL);
			if(rinfo->vram_width == 64)
			{
				if(INREG(MEM_CNTL) & R300_MEM_USE_CD_CH_ONLY)
					tmp &= ~MCLK_CNTL__R300_DISABLE_MC_MCLKB;
				else
					tmp &= ~MCLK_CNTL__R300_DISABLE_MC_MCLKA;
			}
			else
				tmp &= ~(MCLK_CNTL__R300_DISABLE_MC_MCLKA | MCLK_CNTL__R300_DISABLE_MC_MCLKB);
		}
		OUTPLL(pllMCLK_CNTL, tmp);
		return;
	}
	/* R300 */
	if(rinfo->family == CHIP_FAMILY_R300 || rinfo->family == CHIP_FAMILY_R350)
	{
		tmp = INPLL(pllSCLK_CNTL);
		tmp &= ~(SCLK_CNTL__R300_FORCE_VAP);
		tmp |= SCLK_CNTL__FORCE_CP;
		OUTPLL(pllSCLK_CNTL, tmp);
		radeon_msleep(15);
		tmp = INPLL(pllSCLK_CNTL2);
		tmp &= ~(SCLK_CNTL2__R300_FORCE_TCL | SCLK_CNTL2__R300_FORCE_GA | SCLK_CNTL2__R300_FORCE_CBA);
		OUTPLL(pllSCLK_CNTL2, tmp);
	}
	/* Others */
	tmp = INPLL( pllCLK_PWRMGT_CNTL);
	tmp &= ~(CLK_PWRMGT_CNTL__ACTIVE_HILO_LAT_MASK | CLK_PWRMGT_CNTL__DISP_DYN_STOP_LAT_MASK
	 | CLK_PWRMGT_CNTL__DYN_STOP_MODE_MASK);
	tmp |= CLK_PWRMGT_CNTL__ENGINE_DYNCLK_MODE_MASK | (0x01 << CLK_PWRMGT_CNTL__ACTIVE_HILO_LAT__SHIFT);
	OUTPLL( pllCLK_PWRMGT_CNTL, tmp);
	radeon_msleep(15);
	tmp = INPLL(pllCLK_PIN_CNTL);
	tmp |= CLK_PIN_CNTL__SCLK_DYN_START_CNTL;
	OUTPLL(pllCLK_PIN_CNTL, tmp);
	radeon_msleep(15);
	/* When DRI is enabled, setting DYN_STOP_LAT to zero can cause some R200
	 * to lockup randomly, leave them as set by BIOS.
	 */
	tmp = INPLL(pllSCLK_CNTL);
	tmp &= ~SCLK_CNTL__FORCEON_MASK;
	/*RAGE_6::A11 A12 A12N1 A13, RV250::A11 A12, R300*/
	if((rinfo->family == CHIP_FAMILY_RV250
	 && ((INREG(CONFIG_CNTL) & CFG_ATI_REV_ID_MASK) < CFG_ATI_REV_A13))
	  || ((rinfo->family == CHIP_FAMILY_RV100) && ((INREG(CONFIG_CNTL) & CFG_ATI_REV_ID_MASK) <= CFG_ATI_REV_A13)))
	{
		tmp |= SCLK_CNTL__FORCE_CP;
		tmp |= SCLK_CNTL__FORCE_VIP;
	}
	OUTPLL(pllSCLK_CNTL, tmp);
	radeon_msleep(15);
	if((rinfo->family == CHIP_FAMILY_RV200) || (rinfo->family == CHIP_FAMILY_RV250)
	 || (rinfo->family == CHIP_FAMILY_RV280))
	{
		tmp = INPLL(pllSCLK_MORE_CNTL);
		tmp &= ~SCLK_MORE_CNTL__FORCEON;
		/* RV200::A11 A12 RV250::A11 A12 */
		if(((rinfo->family == CHIP_FAMILY_RV200) || (rinfo->family == CHIP_FAMILY_RV250))
		 && ((INREG(CONFIG_CNTL) & CFG_ATI_REV_ID_MASK) < CFG_ATI_REV_A13))
			tmp |= SCLK_MORE_CNTL__FORCEON;
		OUTPLL(pllSCLK_MORE_CNTL, tmp);
		radeon_msleep(15);
	}
	/* RV200::A11 A12, RV250::A11 A12 */
	if (((rinfo->family == CHIP_FAMILY_RV200) || (rinfo->family == CHIP_FAMILY_RV250))
	 && ((INREG(CONFIG_CNTL) & CFG_ATI_REV_ID_MASK) < CFG_ATI_REV_A13))
	{
		tmp = INPLL(pllPLL_PWRMGT_CNTL);
		tmp |= PLL_PWRMGT_CNTL__TCL_BYPASS_DISABLE;
		OUTPLL(pllPLL_PWRMGT_CNTL, tmp);
		radeon_msleep(15);
	}
	tmp = INPLL(pllPIXCLKS_CNTL);
	tmp |=  PIXCLKS_CNTL__PIX2CLK_ALWAYS_ONb | PIXCLKS_CNTL__PIX2CLK_DAC_ALWAYS_ONb
	 | PIXCLKS_CNTL__PIXCLK_BLEND_ALWAYS_ONb | PIXCLKS_CNTL__PIXCLK_GV_ALWAYS_ONb
	 | PIXCLKS_CNTL__PIXCLK_DIG_TMDS_ALWAYS_ONb | PIXCLKS_CNTL__PIXCLK_LVDS_ALWAYS_ONb
	 | PIXCLKS_CNTL__PIXCLK_TMDS_ALWAYS_ONb;
	OUTPLL(pllPIXCLKS_CNTL, tmp);
	radeon_msleep(15);
	tmp = INPLL(pllVCLK_ECP_CNTL);
	tmp |=  VCLK_ECP_CNTL__PIXCLK_ALWAYS_ONb | VCLK_ECP_CNTL__PIXCLK_DAC_ALWAYS_ONb;
	OUTPLL(pllVCLK_ECP_CNTL, tmp);
}

void radeonfb_pm_init(struct radeonfb_info *rinfo, int dynclk)
{
	/* Enable/Disable dynamic clocks: TODO add sysfs access */
	rinfo->dynclk = dynclk;
	if(dynclk == 1)
		radeon_pm_enable_dynamic_mode(rinfo);
	else if(dynclk == 0)
		radeon_pm_disable_dynamic_mode(rinfo);
}

void radeonfb_pm_exit(struct radeonfb_info *rinfo)
{
}

#endif
