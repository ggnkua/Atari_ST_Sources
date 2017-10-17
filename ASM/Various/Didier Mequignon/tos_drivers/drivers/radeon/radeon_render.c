#include "radeonfb.h"

#ifdef RADEON_RENDER

extern void blit_copy(unsigned char *src_addr, int src_line_add, unsigned char *dst_addr, int dst_line_add, int w, int h, int bpp);
extern int blit_copy_ok(void);

static void RadeonInit3DEngineMMIO(struct radeonfb_info *rinfo);

struct blendinfo
{
	char dst_alpha;
	char src_alpha;
	unsigned long blend_cntl;
};

/* The first part of blend_cntl corresponds to Fa from the render "protocol"
 * document, and the second part to Fb.
 */
static const struct blendinfo RadeonBlendOp[] = {
	/* Clear */
	{0, 0, SRC_BLEND_GL_ZERO | DST_BLEND_GL_ZERO},
	/* Src */
	{0, 0, SRC_BLEND_GL_ONE | DST_BLEND_GL_ZERO},
	/* Dst */
	{0, 0, SRC_BLEND_GL_ZERO | DST_BLEND_GL_ONE},
	/* Over */
	{0, 1, SRC_BLEND_GL_ONE | DST_BLEND_GL_ONE_MINUS_SRC_ALPHA},
	/* OverReverse */
	{1, 0, SRC_BLEND_GL_ONE_MINUS_DST_ALPHA | DST_BLEND_GL_ONE},
	/* In */
	{1, 0, SRC_BLEND_GL_DST_ALPHA | DST_BLEND_GL_ZERO},
	/* InReverse */
	{0, 1, SRC_BLEND_GL_ZERO | DST_BLEND_GL_SRC_ALPHA},
	/* Out */
	{1, 0, SRC_BLEND_GL_ONE_MINUS_DST_ALPHA | DST_BLEND_GL_ZERO},
	/* OutReverse */
	{0, 1, SRC_BLEND_GL_ZERO | DST_BLEND_GL_ONE_MINUS_SRC_ALPHA},
	/* Atop */
	{1, 1, SRC_BLEND_GL_DST_ALPHA | DST_BLEND_GL_ONE_MINUS_SRC_ALPHA},
	/* AtopReverse */
	{1, 1, SRC_BLEND_GL_ONE_MINUS_DST_ALPHA | DST_BLEND_GL_SRC_ALPHA},
	/* Xor */
	{1, 1, SRC_BLEND_GL_ONE_MINUS_DST_ALPHA | DST_BLEND_GL_ONE_MINUS_SRC_ALPHA},
	/* Add */
	{0, 0, SRC_BLEND_GL_ONE | DST_BLEND_GL_ONE},
	/* Saturate */
	{1, 1, SRC_BLEND_GL_SRC_ALPHA_SATURATE | DST_BLEND_GL_ONE},
	{0, 0, 0},
	{0, 0, 0},
	/* DisjointClear */
	{0, 0, SRC_BLEND_GL_ZERO | DST_BLEND_GL_ZERO},
	/* DisjointSrc */
	{0, 0, SRC_BLEND_GL_ONE | DST_BLEND_GL_ZERO},
	/* DisjointDst */
	{0, 0, SRC_BLEND_GL_ZERO | DST_BLEND_GL_ONE},
	/* DisjointOver unsupported */
	{0, 0, 0},
	/* DisjointOverReverse */
	{1, 1, SRC_BLEND_GL_SRC_ALPHA_SATURATE | DST_BLEND_GL_ONE},
	/* DisjointIn unsupported */
	{0, 0, 0},
	/* DisjointInReverse unsupported */
	{0, 0, 0},
	/* DisjointOut unsupported */
	{1, 1, SRC_BLEND_GL_SRC_ALPHA_SATURATE | DST_BLEND_GL_ZERO},
	/* DisjointOutReverse unsupported */
	{0, 0, 0},
	/* DisjointAtop unsupported */
	{0, 0, 0},
	/* DisjointAtopReverse unsupported */
	{0, 0, 0},
	/* DisjointXor unsupported */
	{0, 0, 0},
	{0, 0, 0},
	{0, 0, 0},
	{0, 0, 0},
	{0, 0, 0},
	/* ConjointClear */
	{0, 0, SRC_BLEND_GL_ZERO | DST_BLEND_GL_ZERO},
	/* ConjointSrc */
	{0, 0, SRC_BLEND_GL_ONE | DST_BLEND_GL_ZERO},
	/* ConjointDst */
	{0, 0, SRC_BLEND_GL_ZERO | DST_BLEND_GL_ONE},
};
#define RadeonOpMax (sizeof(RadeonBlendOp) / sizeof(RadeonBlendOp[0]))

/* Note on texture formats:
 * TXFORMAT_Y8 expands to (Y,Y,Y,1).  TXFORMAT_I8 expands to (I,I,I,I)
 * The RADEON and R200 TXFORMATS we use are the same on r100/r200.
 */

#define ACCEL_MMIO
#define ACCEL_PREAMBLE()     
#define BEGIN_ACCEL(n)          RADEONWaitForFifo(rinfo, (n))
#define OUT_ACCEL_REG(reg, val) OUTREG(reg, val)
#define FINISH_ACCEL()

static unsigned long RadeonGetTextureFormat(unsigned long format)
{
	switch(format)
	{
		case PICT_a8r8g8b8:
			return TXFORMAT_ARGB8888 | TXFORMAT_ALPHA_IN_MAP;
		case PICT_a8:
			return TXFORMAT_I8 | TXFORMAT_ALPHA_IN_MAP;
		case PICT_x8r8g8b8:
			return TXFORMAT_ARGB8888;
		case PICT_r5g6b5:
			return TXFORMAT_RGB565;
		case PICT_a1r5g5b5:
			return TXFORMAT_ARGB1555 | TXFORMAT_ALPHA_IN_MAP;
		case PICT_x1r5g5b5:
			return TXFORMAT_ARGB1555;
		default:
			return 0;
	}
}

static unsigned long RadeonGetColorFormat(unsigned long format)
{
	switch(format)
	{
		case PICT_a8r8g8b8:
		case PICT_x8r8g8b8:
			return COLOR_FORMAT_ARGB8888;
		case PICT_r5g6b5:
			return COLOR_FORMAT_RGB565;
		case PICT_a1r5g5b5:
		case PICT_x1r5g5b5:
			return COLOR_FORMAT_ARGB1555;
		default:
			return 0;
	}
}

/* Returns a RB3D_BLENDCNTL value, or 0 if the operation is not supported */
static unsigned long RadeonGetBlendCntl(unsigned char op, unsigned long dstFormat)
{
	unsigned long blend_cntl;
	if(op >= RadeonOpMax || RadeonBlendOp[op].blend_cntl == 0)
		return 0;
	blend_cntl = RadeonBlendOp[op].blend_cntl;
	if(RadeonBlendOp[op].dst_alpha && !PICT_FORMAT_A(dstFormat))
	{
		unsigned long srcblend = blend_cntl & SRC_BLEND_MASK;
		/* If there's no destination alpha channel, we need to wire the blending
		 * to treat the alpha channel as always 1.
		 */
		if(srcblend == SRC_BLEND_GL_ONE_MINUS_DST_ALPHA || srcblend == SRC_BLEND_GL_SRC_ALPHA_SATURATE)
			blend_cntl = (blend_cntl & ~SRC_BLEND_MASK) | SRC_BLEND_GL_ZERO;
		else if (srcblend == SRC_BLEND_GL_DST_ALPHA)
			blend_cntl = (blend_cntl & ~SRC_BLEND_MASK) | SRC_BLEND_GL_ONE;
	}
	return blend_cntl;
}

static __inline__ unsigned long F_TO_DW(float val)
{
	union
	{
		float f;
		unsigned long l;
	} tmp;
	tmp.f = val;
	return tmp.l;
}

/* Compute log base 2 of val. */
static __inline__ int ATILog2(int val)
{
	int bits;
	for(bits = 0; val != 0; val >>= 1, ++bits);
	return bits - 1;
}

static void RadeonInit3DEngine(struct radeonfb_info *rinfo)
{
	RadeonInit3DEngineMMIO(rinfo);
	rinfo->RenderInited3D = TRUE;
}

static void RenderCallback(struct radeonfb_info *rinfo)
{
	if((*_hz_200 > rinfo->RenderTimeout) && rinfo->RenderTex)
	{
		offscreen_free(rinfo->info, (long)rinfo->RenderTex); 
		rinfo->RenderTex = NULL;
	}
	if(!rinfo->RenderTex)
		rinfo->RenderCallback = NULL;
}

static int AllocateLinear(struct radeonfb_info *rinfo, int sizeNeeded)
{
	rinfo->RenderTimeout = *_hz_200 + 30000/5; /* 30 S */
	rinfo->RenderCallback = RenderCallback;
	if(rinfo->RenderTex)
	{
		if(rinfo->RenderTexSize >= sizeNeeded)
			return TRUE;
		else
		{
			void *NewRenderTex = (void *)offscreen_alloc(rinfo->info, sizeNeeded + 32);
			if(NewRenderTex != NULL)
			{
				memcpy(NewRenderTex, rinfo->RenderTex, rinfo->RenderTexSize);
				offscreen_free(rinfo->info, (long)rinfo->RenderTex);
				rinfo->RenderTex = NewRenderTex;
				rinfo->RenderTexOffset = RADEON_ALIGN((unsigned long)rinfo->RenderTex - (unsigned long)rinfo->fb_base, 32);
				return TRUE;			
			}
			offscreen_free(rinfo->info, (long)rinfo->RenderTex); 				
			rinfo->RenderTex = NULL;
		}
	}
	rinfo->RenderTexSize = sizeNeeded + 32;
	rinfo->RenderTex = (void *)offscreen_alloc(rinfo->info, rinfo->RenderTexSize);
	rinfo->RenderTexOffset = RADEON_ALIGN((unsigned long)rinfo->RenderTex - (unsigned long)rinfo->fb_base, 32);
	return(rinfo->RenderTex != NULL);
}

static int RADEONSetupRenderByteswap(struct radeonfb_info *rinfo, int tex_bytepp)
{
	/* Set up byte swapping for the framebuffer aperture as needed */
	switch(tex_bytepp)
	{
    case 1:
			OUTREG(SURFACE_CNTL, rinfo->state.surface_cntl & ~(NONSURF_AP0_SWP_32BPP | NONSURF_AP0_SWP_16BPP));
			break;
		case 2:
			OUTREG(SURFACE_CNTL, (rinfo->state.surface_cntl & ~NONSURF_AP0_SWP_32BPP) | NONSURF_AP0_SWP_16BPP);
			break;
		case 4:
			OUTREG(SURFACE_CNTL, (rinfo->state.surface_cntl & ~NONSURF_AP0_SWP_16BPP) | NONSURF_AP0_SWP_32BPP);
			break;
		default:
			DPRINT(__func__);
			DPRINTVAL(": Don't know what to do for ", tex_bytepp);
			return FALSE;
	}
	return TRUE;
}

static void RADEONRestoreByteswap(struct radeonfb_info *rinfo)
{
	OUTREG(SURFACE_CNTL, rinfo->state.surface_cntl);
}

static void RadeonInit3DEngineMMIO(struct radeonfb_info *rinfo)
{
	ACCEL_PREAMBLE();
	if(rinfo->family >= CHIP_FAMILY_R300)
	{
		/* Unimplemented */
	}
	else if((rinfo->family == CHIP_FAMILY_RV250) || (rinfo->family == CHIP_FAMILY_RV280)
	 || (rinfo->family == CHIP_FAMILY_RS300) || (rinfo->family == CHIP_FAMILY_R200))
	{
		BEGIN_ACCEL(7);
		if(rinfo->family == CHIP_FAMILY_RS300)
			OUT_ACCEL_REG(R200_SE_VAP_CNTL_STATUS, TCL_BYPASS);
		else
			OUT_ACCEL_REG(R200_SE_VAP_CNTL_STATUS, 0);
		OUT_ACCEL_REG(R200_PP_CNTL_X, 0);
		OUT_ACCEL_REG(R200_PP_TXMULTI_CTL_0, 0);
		OUT_ACCEL_REG(R200_SE_VTX_STATE_CNTL, 0);
		OUT_ACCEL_REG(R200_RE_CNTL, 0x0);
		/* XXX: correct?  Want it to be like VTX_ST?_NONPARAMETRIC */
		OUT_ACCEL_REG(R200_SE_VTE_CNTL, R200_VTX_ST_DENORMALIZED);
		OUT_ACCEL_REG(R200_SE_VAP_CNTL, R200_VAP_FORCE_W_TO_ONE | R200_VAP_VF_MAX_VTX_NUM);
		FINISH_ACCEL();
	}
	else
	{
		BEGIN_ACCEL(2);
		if((rinfo->family == CHIP_FAMILY_RADEON) || (rinfo->family == CHIP_FAMILY_RV200))
			OUT_ACCEL_REG(SE_CNTL_STATUS, 0);
		else
			OUT_ACCEL_REG(SE_CNTL_STATUS, TCL_BYPASS);
		OUT_ACCEL_REG(SE_COORD_FMT, VTX_XY_PRE_MULT_1_OVER_W0 | VTX_ST0_NONPARAMETRIC | VTX_ST1_NONPARAMETRIC | TEX1_W_ROUTING_USE_W0);
		FINISH_ACCEL();
	}
	BEGIN_ACCEL(3);
	OUT_ACCEL_REG(RE_TOP_LEFT, 0);
	OUT_ACCEL_REG(RE_WIDTH_HEIGHT, 0x07ff07ff);
	OUT_ACCEL_REG(SE_CNTL, DIFFUSE_SHADE_GOURAUD | BFACE_SOLID | FFACE_SOLID | VTX_PIX_CENTER_OGL | ROUND_MODE_ROUND | ROUND_PREC_4TH_PIX);
	FINISH_ACCEL();
}

static int RADEONSetupTextureMMIO(struct radeonfb_info *rinfo,
           unsigned long format, unsigned char *src, int src_pitch, unsigned int width, unsigned int height, int flags)
{
	unsigned char *dst;
	unsigned long tex_size = 0, txformat;
	int dst_pitch, offset, size, tex_bytepp;
	ACCEL_PREAMBLE();
	if((width > 2048) || (height > 2048))
		return FALSE;
	txformat = RadeonGetTextureFormat(format);
	tex_bytepp = PICT_FORMAT_BPP(format) >> 3;
	if(rinfo->big_endian)
	{
		if(!RADEONSetupRenderByteswap(rinfo, tex_bytepp))
		{ 
			DPRINT(__func__);
			DPRINT(": RADEONSetupRenderByteswap() failed!\r\n");
			return FALSE;
    }
	}
	dst_pitch = (width * tex_bytepp + 63) & ~63;
	size = dst_pitch * height;
	if(!AllocateLinear(rinfo, size))
		return FALSE;
	if(flags /* & XAA_RENDER_REPEAT*/)
	{
		txformat |= ATILog2(width) << R200_TXFORMAT_WIDTH_SHIFT;
		txformat |= ATILog2(height) << R200_TXFORMAT_HEIGHT_SHIFT;
	}
	else
	{
		tex_size = ((height - 1) << 16) | (width - 1);
		txformat |= TXFORMAT_NON_POWER2;
	}
	offset = rinfo->RenderTexOffset * (rinfo->bpp >> 3);
	dst = (unsigned char *)(rinfo->fb_base + offset);
//	if(rinfo->NeedToSync)
		RADEONWaitForIdleMMIO(rinfo);
	/* Upload texture to card. */
#if 1
	blit_copy(src, (src_pitch / tex_bytepp) - width, dst, (dst_pitch / tex_bytepp) - width, width, height, tex_bytepp << 3);
	while(blit_copy_ok() > 0);
#else
	{
		int i = height;
		while(--i >= 0)
		{
			memcpy(dst, src, width * tex_bytepp);
			src += src_pitch;
			dst += dst_pitch;
		}
	}
#endif
	if(rinfo->big_endian)
    RADEONRestoreByteswap(rinfo);
	if((rinfo->family == CHIP_FAMILY_RV250) || (rinfo->family == CHIP_FAMILY_RV280)
	 || (rinfo->family == CHIP_FAMILY_RS300) || (rinfo->family == CHIP_FAMILY_R200))
	{
		BEGIN_ACCEL(6);
		OUT_ACCEL_REG(R200_PP_TXFORMAT_0, txformat);
		OUT_ACCEL_REG(R200_PP_TXFORMAT_X_0, 0);
		OUT_ACCEL_REG(R200_PP_TXSIZE_0, tex_size);
		OUT_ACCEL_REG(R200_PP_TXPITCH_0, dst_pitch - 32);
		OUT_ACCEL_REG(R200_PP_TXOFFSET_0, offset + rinfo->fb_local_base + rinfo->fb_offset);
		OUT_ACCEL_REG(R200_PP_TXFILTER_0, R200_MAG_FILTER_NEAREST | R200_MIN_FILTER_NEAREST | R200_CLAMP_S_WRAP | R200_CLAMP_T_WRAP);
	}
	else /* R100 */
	{
		BEGIN_ACCEL(5);
		OUT_ACCEL_REG(PP_TXFORMAT_0, txformat);
		OUT_ACCEL_REG(PP_TEX_SIZE_0, tex_size);
		OUT_ACCEL_REG(PP_TEX_PITCH_0, dst_pitch - 32);
		OUT_ACCEL_REG(PP_TXOFFSET_0, offset + rinfo->fb_local_base + rinfo->fb_offset);
		OUT_ACCEL_REG(PP_TXFILTER_0, MAG_FILTER_LINEAR | MIN_FILTER_LINEAR | CLAMP_S_WRAP | CLAMP_T_WRAP);
	}	
	FINISH_ACCEL();
	return TRUE;
}

int RADEONSetupForCPUToScreenAlphaTextureMMIO(struct fb_info *info, 
    int op, unsigned short red, unsigned short green, unsigned short blue, unsigned short alpha, unsigned long maskFormat, unsigned long dstFormat, unsigned char *alphaPtr, int alphaPitch, int width, int height, int flags)
{
	struct radeonfb_info *rinfo = info->par;
	unsigned long colorformat, srccolor, blend_cntl;
	if(rinfo->family >= CHIP_FAMILY_R300)
	{
		DPRINT("Render acceleration unsupported on Radeon 9500/9700 and newer\r\n");
		return FALSE;
	}
	else
	{
		ACCEL_PREAMBLE();
		blend_cntl = RadeonGetBlendCntl(op, dstFormat);
		if(blend_cntl == 0)
			return FALSE;
		if(!rinfo->RenderInited3D)
			RadeonInit3DEngine(rinfo);
		if(!RADEONSetupTextureMMIO(rinfo, maskFormat, alphaPtr, alphaPitch, width, height, flags))
			return FALSE;
		colorformat = RadeonGetColorFormat(dstFormat);
		srccolor = ((alpha & 0xff00) << 16) | ((red & 0xff00) << 8) | (blue >> 8) | (green & 0xff00);
		if((rinfo->family == CHIP_FAMILY_RV250) || (rinfo->family == CHIP_FAMILY_RV280)
		 || (rinfo->family == CHIP_FAMILY_RS300) || (rinfo->family == CHIP_FAMILY_R200))
		{
			BEGIN_ACCEL(10);
			OUT_ACCEL_REG(RB3D_CNTL, colorformat | ALPHA_BLEND_ENABLE);
			OUT_ACCEL_REG(PP_CNTL, TEX_0_ENABLE | TEX_BLEND_0_ENABLE);
			OUT_ACCEL_REG(R200_PP_TFACTOR_0, srccolor);
			OUT_ACCEL_REG(R200_PP_TXCBLEND_0, R200_TXC_ARG_A_TFACTOR_COLOR | R200_TXC_ARG_B_R0_ALPHA);
			OUT_ACCEL_REG(R200_PP_TXCBLEND2_0, R200_TXC_OUTPUT_REG_R0);
			OUT_ACCEL_REG(R200_PP_TXABLEND_0, R200_TXA_ARG_A_TFACTOR_ALPHA | R200_TXA_ARG_B_R0_ALPHA);
			OUT_ACCEL_REG(R200_PP_TXABLEND2_0, R200_TXA_OUTPUT_REG_R0);
			OUT_ACCEL_REG(R200_SE_VTX_FMT_0, 0);
			OUT_ACCEL_REG(R200_SE_VTX_FMT_1, (2 << R200_VTX_TEX0_COMP_CNT_SHIFT));
		}
		else /* R100 */
		{
			BEGIN_ACCEL(7);
			OUT_ACCEL_REG(RB3D_CNTL, colorformat | ALPHA_BLEND_ENABLE);
			OUT_ACCEL_REG(PP_CNTL, TEX_0_ENABLE | TEX_BLEND_0_ENABLE);
			OUT_ACCEL_REG(PP_TFACTOR_0, srccolor);
			OUT_ACCEL_REG(PP_TXCBLEND_0, COLOR_ARG_A_TFACTOR_COLOR | COLOR_ARG_B_T0_ALPHA);
			OUT_ACCEL_REG(PP_TXABLEND_0, ALPHA_ARG_A_TFACTOR_ALPHA | ALPHA_ARG_B_T0_ALPHA);
			OUT_ACCEL_REG(SE_VTX_FMT, SE_VTX_FMT_XY | SE_VTX_FMT_ST0);
		}
		OUT_ACCEL_REG(RB3D_BLENDCNTL, blend_cntl);
		FINISH_ACCEL();
		return TRUE;
	}
}

int RADEONSetupForCPUToScreenTextureMMIO(struct fb_info *info,
    int op, unsigned long srcFormat, unsigned long dstFormat, unsigned char *texPtr, int texPitch, int width, int height, int flags)
{
	struct radeonfb_info *rinfo = info->par;
	unsigned long colorformat, blend_cntl;
	if(rinfo->family >= CHIP_FAMILY_R300)
	{
		DPRINT("Render acceleration unsupported on Radeon 9500/9700 and newer\r\n");
		return FALSE;
	}
	else
	{
		ACCEL_PREAMBLE();
		blend_cntl = RadeonGetBlendCntl(op, dstFormat);
		if(blend_cntl == 0)
			return FALSE;
		if(!rinfo->RenderInited3D)
			RadeonInit3DEngine(rinfo);
		if(!RADEONSetupTextureMMIO(rinfo, srcFormat, texPtr, texPitch, width, height, flags))
			return FALSE;
		colorformat = RadeonGetColorFormat(dstFormat);
		if((rinfo->family == CHIP_FAMILY_RV250) || (rinfo->family == CHIP_FAMILY_RV280)
		 || (rinfo->family == CHIP_FAMILY_RS300) || (rinfo->family == CHIP_FAMILY_R200))
		{	
			BEGIN_ACCEL(9);
			OUT_ACCEL_REG(RB3D_CNTL, colorformat | ALPHA_BLEND_ENABLE);
			OUT_ACCEL_REG(PP_CNTL, TEX_0_ENABLE | TEX_BLEND_0_ENABLE);
			if(srcFormat != PICT_a8)
				OUT_ACCEL_REG(R200_PP_TXCBLEND_0, R200_TXC_ARG_C_R0_COLOR);
			else
				OUT_ACCEL_REG(R200_PP_TXCBLEND_0, R200_TXC_ARG_C_ZERO);
			OUT_ACCEL_REG(R200_PP_TXCBLEND2_0, R200_TXC_OUTPUT_REG_R0);
			OUT_ACCEL_REG(R200_PP_TXABLEND_0, R200_TXA_ARG_C_R0_ALPHA);
			OUT_ACCEL_REG(R200_PP_TXABLEND2_0, R200_TXA_OUTPUT_REG_R0);
			OUT_ACCEL_REG(R200_SE_VTX_FMT_0, 0);
			OUT_ACCEL_REG(R200_SE_VTX_FMT_1, (2 << R200_VTX_TEX0_COMP_CNT_SHIFT));
		}
		else /* R100 */
		{
			BEGIN_ACCEL(6);
			OUT_ACCEL_REG(RB3D_CNTL, colorformat | ALPHA_BLEND_ENABLE);
			OUT_ACCEL_REG(PP_CNTL, TEX_0_ENABLE | TEX_BLEND_0_ENABLE);
			if(srcFormat != PICT_a8)
				OUT_ACCEL_REG(PP_TXCBLEND_0, COLOR_ARG_C_T0_COLOR);
			else
				OUT_ACCEL_REG(PP_TXCBLEND_0, COLOR_ARG_C_ZERO);
			OUT_ACCEL_REG(PP_TXABLEND_0, ALPHA_ARG_C_T0_ALPHA);
			OUT_ACCEL_REG(SE_VTX_FMT, SE_VTX_FMT_XY | SE_VTX_FMT_ST0);
		}
		OUT_ACCEL_REG(RB3D_BLENDCNTL, blend_cntl);
		FINISH_ACCEL();
	}
	return TRUE;
}

void RADEONSubsequentCPUToScreenTextureMMIO(struct fb_info *info,
     int dstx, int dsty, int srcx, int srcy, int width, int height)
{
	struct radeonfb_info *rinfo = info->par;
	int byteshift;
	unsigned long fboffset;
	float l, t, r, b, fl, fr, ft, fb;
	if(rinfo->family >= CHIP_FAMILY_R300)
	{
		DPRINT("Render acceleration unsupported on Radeon 9500/9700 and newer\r\n");
	}
	ACCEL_PREAMBLE();
	/* Note: we can't simply set up the 3D surface at the same location as the
	 * front buffer, because the 2048x2048 limit on coordinates may be smaller
	 * than the (MergedFB) screen.
	 * Can't use arbitrary offsets for color tiling
	 */ 
#ifdef RADEON_TILING
	if(rinfo->tilingEnabled)
	{
		/* can't play tricks with x coordinate, or could we - tiling is disabled anyway in that case */
		fboffset = rinfo->fb_local_base + rinfo->fb_offset + (info->var.xres_virtual * (dsty & ~15) * (rinfo->bpp >> 3));
		l = (float)dstx;
		t = (float)(dsty % 16);
	}
	else
#endif
	{
		byteshift = (rinfo->bpp >> 4);
		fboffset = (rinfo->fb_local_base + rinfo->fb_offset + (((info->var.xres_virtual * dsty) + dstx) << byteshift)) & ~15;
		l = (float)(((dstx << byteshift) % 16) >> byteshift);
		t = (float)0.0;
	}
	r = (float)(width + l);
	b = (float)(height + t);
	fl = (float)srcx;
	fr = (float)(srcx + width);
	ft = (float)srcy;
	fb = (float)(srcy + height);
	BEGIN_ACCEL(20); 
	/* Note: we can't simply setup 3D surface at the same location as the front buffer,
	   some apps may draw offscreen pictures out of the limitation of radeon 3D surface.
	 */ 
#ifdef RADEON_TILING
	OUT_ACCEL_REG(RB3D_COLORPITCH, info->var.xres_virtual | ((rinfo->tilingEnabled && (dsty <= info->var.yres_virtual)) ? COLOR_TILE_ENABLE : 0));
#else
	OUT_ACCEL_REG(RB3D_COLORPITCH, info->var.xres_virtual);
#endif
	OUT_ACCEL_REG(RB3D_COLOROFFSET, fboffset);
	if((rinfo->family == CHIP_FAMILY_RV250) || (rinfo->family == CHIP_FAMILY_RV280)
	 || (rinfo->family == CHIP_FAMILY_RS300) || (rinfo->family == CHIP_FAMILY_R200))
		OUT_ACCEL_REG(SE_VF_CNTL, (VF_PRIM_TYPE_QUAD_LIST | VF_PRIM_WALK_DATA | 4 << VF_NUM_VERTICES_SHIFT));
	else
		OUT_ACCEL_REG(SE_VF_CNTL, VF_PRIM_TYPE_TRIANGLE_FAN | VF_PRIM_WALK_DATA | VF_RADEON_MODE | (4 << VF_NUM_VERTICES_SHIFT));
	OUT_ACCEL_REG(SE_PORT_DATA0, F_TO_DW(l));
	OUT_ACCEL_REG(SE_PORT_DATA0, F_TO_DW(t));
	OUT_ACCEL_REG(SE_PORT_DATA0, F_TO_DW(fl));
	OUT_ACCEL_REG(SE_PORT_DATA0, F_TO_DW(ft));
	OUT_ACCEL_REG(SE_PORT_DATA0, F_TO_DW(r));
	OUT_ACCEL_REG(SE_PORT_DATA0, F_TO_DW(t));
	OUT_ACCEL_REG(SE_PORT_DATA0, F_TO_DW(fr));
	OUT_ACCEL_REG(SE_PORT_DATA0, F_TO_DW(ft));
	OUT_ACCEL_REG(SE_PORT_DATA0, F_TO_DW(r));
	OUT_ACCEL_REG(SE_PORT_DATA0, F_TO_DW(b));
	OUT_ACCEL_REG(SE_PORT_DATA0, F_TO_DW(fr));
	OUT_ACCEL_REG(SE_PORT_DATA0, F_TO_DW(fb));
	OUT_ACCEL_REG(SE_PORT_DATA0, F_TO_DW(l));
	OUT_ACCEL_REG(SE_PORT_DATA0, F_TO_DW(b));
	OUT_ACCEL_REG(SE_PORT_DATA0, F_TO_DW(fl));
	OUT_ACCEL_REG(SE_PORT_DATA0, F_TO_DW(fb));
	OUT_ACCEL_REG(WAIT_UNTIL, WAIT_3D_IDLECLEAN);
	FINISH_ACCEL();
}

#endif
