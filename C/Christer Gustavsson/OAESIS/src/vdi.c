/****************************************************************************

 Module
  vdi.c
  
 Description
  Vdi calls used in oAESis.
  
 Author(s)
 	cg (Christer Gustavsson <d2cg@dtek.chalmers.se>)
 	
 Revision history
 
  960129 cg
   Created.
 
 Copyright notice
  The copyright to the program code herein belongs to the authors. It may
  be freely duplicated and distributed without fee, but not charged for.
 
 ****************************************************************************/

/****************************************************************************
 * Used interfaces                                                          *
 ****************************************************************************/

#include "debug.h"
#include "lxgemdos.h"
#include "types.h"
#include "vdi.h"

/****************************************************************************
 * Typedefs of module global interest                                       *
 ****************************************************************************/

typedef struct {
	WORD *contrl;
	WORD *intin;
	WORD *ptsin;
	WORD *intout;
	WORD *ptsout;
}VDIPB;

/****************************************************************************
 * Module global variables                                                  *
 ****************************************************************************/

/****************************************************************************
 * Local functions (use static!)                                            *
 ****************************************************************************/

/****************************************************************************
 * Public functions                                                         *
 ****************************************************************************/

/****************************************************************************
 * Vdi_v_bar                                                                *
 *  Output filled rectangle.                                                *
 ****************************************************************************/
void              /*                                                        */
Vdi_v_bar(        /*                                                        */
WORD handle,      /* Workstation handle.                                    */
WORD *pxy)        /* Coordinate list.                                       */
/****************************************************************************/
{
	WORD  contrl[7];
	VDIPB vdipb;
	
	contrl[0] = 11;
	contrl[1] = 2;
	contrl[3] = 0;
	contrl[5] = 1;
	contrl[6] = handle;

	vdipb.contrl = contrl;
	vdipb.ptsin = pxy;
	
	vdicall(&vdipb);
}

/****************************************************************************
 * Vdi_v_clrwk                                                              *
 *  Clear workstation.                                                      *
 ****************************************************************************/
void              /*                                                        */
Vdi_v_clrwk(      /*                                                        */
WORD handle)      /* Workstation handle.                                    */
/****************************************************************************/
{
	WORD  contrl[7];
	VDIPB vdipb;
	
	contrl[0] = 3;
	contrl[1] = 0;
	contrl[3] = 0;
	contrl[6] = handle;

	vdipb.contrl = contrl;
	
	vdicall(&vdipb);
}

/****************************************************************************
 * Vdi_v_clsvwk                                                             *
 *  Close virtual workstation.                                              *
 ****************************************************************************/
void              /*                                                        */
Vdi_v_clsvwk(     /*                                                        */
WORD handle)      /* Workstation handle.                                    */
/****************************************************************************/
{
	WORD  contrl[7];
	VDIPB vdipb;
	
	contrl[0] = 101;
	contrl[1] = 0;
	contrl[3] = 0;
	contrl[6] = handle;

	vdipb.contrl = contrl;
	
	vdicall(&vdipb);
}

/****************************************************************************
 * Vdi_v_clswk                                                              *
 *  Close workstation.                                                      *
 ****************************************************************************/
void              /*                                                        */
Vdi_v_clswk(      /*                                                        */
WORD handle)      /* Workstation handle.                                    */
/****************************************************************************/
{
	WORD  contrl[7];
	VDIPB vdipb;
	
	contrl[0] = 2;
	contrl[1] = 0;
	contrl[3] = 0;
	contrl[6] = handle;

	vdipb.contrl = contrl;
	
	vdicall(&vdipb);
}

/****************************************************************************
 * Vdi_v_gtext                                                              *
 *  Output graphic text.                                                    *
 ****************************************************************************/
void              /*                                                        */
Vdi_v_gtext(      /*                                                        */
WORD handle,      /* Workstation handle.                                    */
WORD x,           /* X position.                                            */
WORD y,           /* Y position.                                            */
BYTE *str)        /* Text to be output.                                     */
/****************************************************************************/
{
	WORD  i = 0;
	WORD  contrl[7];
	WORD  intin[128];
	WORD  ptsin[2];
	VDIPB vdipb;
	
	while((intin[i++] = (WORD)*(((UBYTE *)str)++)));
	
	contrl[0] = 8;
	contrl[1] = 1;
	contrl[3] = --i;
	contrl[6] = handle;

	ptsin[0] = x;
	ptsin[1] = y;

	vdipb.contrl = contrl;
	vdipb.intin = intin;
	vdipb.ptsin = ptsin;
	
	vdicall(&vdipb);
}

/****************************************************************************
 * Vdi_v_hide_c                                                             *
 *  Hide mouse cursor.                                                      *
 ****************************************************************************/
void              /*                                                        */
Vdi_v_hide_c(     /*                                                        */
WORD handle)      /* Workstation handle.                                    */
/****************************************************************************/
{
	WORD  contrl[7];
	VDIPB vdipb;
	
	contrl[0] = 123;
	contrl[1] = 0;
	contrl[3] = 0;
	contrl[6] = handle;

	vdipb.contrl = contrl;
	
	vdicall(&vdipb);
}

/****************************************************************************
 * Vdi_v_opnvwk                                                             *
 *  Open virtual workstation.                                               *
 ****************************************************************************/
void              /*                                                        */
Vdi_v_opnvwk(     /*                                                        */
WORD *work_in,    /* In parameters.                                         */
WORD *handle,     /* Workstation handle.                                    */
WORD *work_out)   /* Out parameters.                                        */
/****************************************************************************/
{
	WORD  contrl[12];
	VDIPB vdipb;
	
	contrl[0] = 100;
	contrl[1] = 0;
	contrl[3] = 11;
	contrl[6] = *handle;

	vdipb.contrl = contrl;
	vdipb.intin = work_in;
	vdipb.intout = work_out;
	vdipb.ptsout = &work_out[45];
	
	vdicall(&vdipb);
	
	*handle = contrl[6];
}

/****************************************************************************
 * Vdi_v_opnwk                                                              *
 *  Open workstation.                                                       *
 ****************************************************************************/
void              /*                                                        */
Vdi_v_opnwk(      /*                                                        */
WORD *work_in,    /* In parameters.                                         */
WORD *handle,     /* Workstation handle.                                    */
WORD *work_out)   /* Out parameters.                                        */
/****************************************************************************/
{
	WORD  contrl[7];
	VDIPB vdipb;
	
	contrl[0] = 1;
	contrl[1] = 0;
	contrl[3] = 11;
	contrl[6] = *handle;

	vdipb.contrl = contrl;
	vdipb.intin = work_in;
	vdipb.intout = work_out;
	vdipb.ptsout = &work_out[45];
	
	vdicall(&vdipb);
	
	*handle = contrl[6];
}

/****************************************************************************
 * Vdi_v_pline                                                              *
 *  Output polyline.                                                        *
 ****************************************************************************/
void              /*                                                        */
Vdi_v_pline(      /*                                                        */
WORD handle,      /* Workstation handle.                                    */
WORD count,       /* Number of points.                                      */
WORD *pxy)        /* Array of points.                                       */
/****************************************************************************/
{
	WORD  contrl[7];
	VDIPB vdipb;
	
	contrl[0] = 6;
	contrl[1] = count;
	contrl[3] = 0;
	contrl[6] = handle;

	vdipb.contrl = contrl;
	vdipb.ptsin = pxy;
	
	vdicall(&vdipb);
}

/****************************************************************************
 * Vdi_v_show_c                                                             *
 *  Show mouse cursor.                                                      *
 ****************************************************************************/
void              /*                                                        */
Vdi_v_show_c(     /*                                                        */
WORD handle,      /* Workstation handle.                                    */
WORD reset)       /* If 0 the cursor will always be shown.                  */
/****************************************************************************/
{
	WORD  contrl[7];
	VDIPB vdipb;
	
	contrl[0] = 122;
	contrl[1] = 0;
	contrl[3] = 1;
	contrl[6] = handle;

	vdipb.contrl = contrl;
	vdipb.intin = &reset;
	
	vdicall(&vdipb);
}

/****************************************************************************
 * Vdi_vex_butv                                                             *
 *  Set mouse button interrupt handler.                                     *
 ****************************************************************************/
void                             /*                                         */
Vdi_vex_butv(                    /*                                         */
WORD handle,                     /* Workstation handle.                     */
void *butv,                      /* New handler.                            */
void **old_butv)                 /* Old handler.                            */
/****************************************************************************/
{
	WORD  contrl[11];
	VDIPB vdipb;
	
	contrl[0] = 125;
	contrl[1] = 0;
	contrl[3] = 0;
	contrl[6] = handle;
	contrl[7] = (WORD)((LONG)butv >> 16);
	contrl[8] = (WORD)((LONG)butv);

	vdipb.contrl = contrl;
	
	vdicall(&vdipb);
	
	*(LONG *)old_butv = (LONG)(((LONG)contrl[9] << 16) |
											(LONG)contrl[10]);
}

/****************************************************************************
 * Vdi_vex_motv                                                             *
 *  Set mouse movement interrupt handler.                                   *
 ****************************************************************************/
void                             /*                                         */
Vdi_vex_motv(                    /*                                         */
WORD handle,                     /* Workstation handle.                     */
void *motv,                      /* New handler.                            */
void **old_motv)                 /* Old handler.                            */
/****************************************************************************/
{
	WORD  contrl[11];
	VDIPB vdipb;
	
	contrl[0] = 126;
	contrl[1] = 0;
	contrl[3] = 0;
	contrl[6] = handle;
	contrl[7] = (WORD)((LONG)motv >> 16);
	contrl[8] = (WORD)((LONG)motv);

	vdipb.contrl = contrl;
	
	vdicall(&vdipb);
	
	*(LONG *)old_motv = (LONG)(((LONG)contrl[9] << 16) |
											(LONG)contrl[10]);
}

/****************************************************************************
 * Vdi_vex_timv                                                             *
 *  Set timer tick interrupt handler.                                       *
 ****************************************************************************/
void                             /*                                         */
Vdi_vex_timv(                    /*                                         */
WORD handle,                     /* Workstation handle.                     */
void *timv,                      /* New handler.                            */
void **old_timv,                 /* Old handler.                            */
WORD *mpt)                       /* Time in milliseconds between ticks.     */
/****************************************************************************/
{
	WORD  contrl[11];
	VDIPB vdipb;
	
	contrl[0] = 118;
	contrl[1] = 0;
	contrl[3] = 0;
	contrl[6] = handle;
	contrl[7] = (WORD)((LONG)timv >> 16);
	contrl[8] = (WORD)((LONG)timv);

	vdipb.contrl = contrl;
	vdipb.intout = mpt;
	
	vdicall(&vdipb);
	
	*(LONG *)old_timv = (LONG)(((LONG)contrl[9] << 16) |
											(LONG)contrl[10]);
}

/****************************************************************************
 * Vdi_vq_extnd                                                             *
 *  Request extra information.                                              *
 ****************************************************************************/
void              /*                                                        */
Vdi_vq_extnd(     /*                                                        */
WORD handle,      /* Workstation handle.                                    */
WORD mode,        /* Request mode.                                          */
WORD *work_out)   /* Output parameters.                                     */
/****************************************************************************/
{
	WORD  contrl[7];
	VDIPB vdipb;
	
	contrl[0] = 102;
	contrl[1] = 0;
	contrl[3] = 1;
	contrl[6] = handle;

	vdipb.contrl = contrl;
	vdipb.intin = &mode;
	vdipb.intout = work_out;
	vdipb.ptsout = &work_out[45];
	
	vdicall(&vdipb);
}

/****************************************************************************
 * Vdi_vq_key_s                                                             *
 *  Request current shift key status.                                       *
 ****************************************************************************/
void              /*                                                        */
Vdi_vq_key_s(     /*                                                        */
WORD handle,      /* Workstation handle.                                    */
WORD *status)     /* Shift key status.                                      */
/****************************************************************************/
{
	WORD  contrl[7];
	VDIPB vdipb;
	
	contrl[0] = 128;
	contrl[1] = 0;
	contrl[3] = 0;
	contrl[6] = handle;

	vdipb.contrl = contrl;
	vdipb.intout = status;
	
	vdicall(&vdipb);
}

/****************************************************************************
 * Vdi_vq_mouse                                                             *
 *  Request current state of mouse.                                         *
 ****************************************************************************/
void              /*                                                        */
Vdi_vq_mouse(     /*                                                        */
WORD handle,      /* Workstation handle.                                    */
WORD *mb,         /* Button state.                                          */
WORD *mx,         /* X coordinate of mouse cursor.                          */
WORD *my)         /* Y coordinate of mouse cursor.                          */
/****************************************************************************/
{
	WORD  contrl[7];
	WORD  intout;
	WORD  ptsout[2];
	VDIPB vdipb;
	
	contrl[0] = 124;
	contrl[1] = 0;
	contrl[3] = 0;
	contrl[6] = handle;

	vdipb.contrl = contrl;
	vdipb.intout = &intout;
	vdipb.ptsout = ptsout;
	
	vdicall(&vdipb);
	
	*mb = intout;
	*mx = ptsout[0];
	*my = ptsout[1];
}

/****************************************************************************
 * Vdi_vqt_attributes                                                       *
 *  Get information about text settings.                                    *
 ****************************************************************************/
void                 /*                                                     */
Vdi_vqt_attributes(  /*                                                     */
WORD handle,         /* Workstation handle.                                 */
WORD *attr)          /* Array of attributes.                                */
/****************************************************************************/
{
	WORD  contrl[7];
	VDIPB vdipb;
	
	contrl[0] = 38;
	contrl[1] = 0;
	contrl[3] = 0;
	contrl[6] = handle;

	vdipb.contrl = contrl;
	vdipb.intout = attr;
	vdipb.ptsout = &attr[6];
	
	vdicall(&vdipb);
}

/****************************************************************************
 * Vdi_vr_recfl                                                             *
 *  Output filled rectangle.                                                *
 ****************************************************************************/
void              /*                                                        */
Vdi_vr_recfl(     /*                                                        */
WORD handle,      /* Workstation handle.                                    */
WORD *pxy)        /* Rectangle coordinates.                                 */
/****************************************************************************/
{
	WORD  contrl[7];
	VDIPB vdipb;
	
	contrl[0] = 114;
	contrl[1] = 2;
	contrl[3] = 0;
	contrl[6] = handle;

	vdipb.contrl = contrl;
	vdipb.ptsin = pxy;
	
	vdicall(&vdipb);
}

/****************************************************************************
 * Vdi_vr_trnfm                                                             *
 *  Transform memory block.                                                 *
 ****************************************************************************/
void              /*                                                        */
Vdi_vr_trnfm(     /*                                                        */
WORD handle,      /* Workstation handle.                                    */
MFDB *src,        /* Source block.                                          */
MFDB *dst)        /* Destination block.                                     */
/****************************************************************************/
{
	WORD  contrl[11];
	VDIPB vdipb;
	
	contrl[0] = 110;
	contrl[1] = 0;
	contrl[3] = 0;
	contrl[6] = handle;
	contrl[7] = (WORD)((LONG)src >> 16);
	contrl[8] = (WORD)((LONG)src);
	contrl[9] = (WORD)((LONG)dst >> 16);
	contrl[10] = (WORD)((LONG)dst);

	vdipb.contrl = contrl;

	vdicall(&vdipb);
}

/****************************************************************************
 * Vdi_vro_cpyfm                                                            *
 *  Blit memory block.                                                      *
 ****************************************************************************/
void              /*                                                        */
Vdi_vro_cpyfm(    /*                                                        */
WORD handle,      /* Workstation handle.                                    */
WORD mode,        /* Mode.                                                  */
WORD *pxy,        /* Bounding rectangles.                                   */
MFDB *src,        /* Source block.                                          */
MFDB *dst)        /* Destination block.                                     */
/****************************************************************************/
{
	WORD  contrl[11];
	VDIPB vdipb;
	
	contrl[0] = 109;
	contrl[1] = 4;
	contrl[3] = 1;
	contrl[6] = handle;
	contrl[7] = (WORD)((LONG)src >> 16);
	contrl[8] = (WORD)((LONG)src);
	contrl[9] = (WORD)((LONG)dst >> 16);
	contrl[10] = (WORD)((LONG)dst);

	vdipb.contrl = contrl;
	vdipb.intin = &mode;
	vdipb.ptsin = pxy;
	
	vdicall(&vdipb);
}

/****************************************************************************
 * Vdi_vrt_cpyfm                                                            *
 *  Blit memory block.                                                      *
 ****************************************************************************/
void              /*                                                        */
Vdi_vrt_cpyfm(    /*                                                        */
WORD handle,      /* Workstation handle.                                    */
WORD mode,        /* Mode.                                                  */
WORD *pxy,        /* Bounding rectangles.                                   */
MFDB *src,        /* Source block.                                          */
MFDB *dst,        /* Destination block.                                     */
WORD *colors)     /* Color of fg and bg.                                    */
/****************************************************************************/
{
	WORD  intin[3];
	WORD  contrl[11];
	VDIPB vdipb;
	
	contrl[0] = 121;
	contrl[1] = 4;
	contrl[3] = 1;
	contrl[6] = handle;
	contrl[7] = (WORD)((LONG)src >> 16);
	contrl[8] = (WORD)((LONG)src);
	contrl[9] = (WORD)((LONG)dst >> 16);
	contrl[10] = (WORD)((LONG)dst);

	intin[0] = mode;
	intin[1] = colors[0];
	intin[2] = colors[1];

	vdipb.contrl = contrl;
	vdipb.intin = intin;
	vdipb.ptsin = pxy;
	
	vdicall(&vdipb);
}

/****************************************************************************
 * Vdi_vs_clip                                                              *
 *  Set clipping rectangle.                                                 *
 ****************************************************************************/
void              /*                                                        */
Vdi_vs_clip(      /*                                                        */
WORD handle,      /* Workstation handle.                                    */
WORD flag,        /* On/off flag.                                           */
WORD *pxy)        /* Rectangle coordinates.                                 */
/****************************************************************************/
{
	WORD  contrl[7];
	VDIPB vdipb;
	
	contrl[0] = 129;
	contrl[1] = 2;
	contrl[3] = 1;
	contrl[6] = handle;

	vdipb.intin = &flag;
	vdipb.contrl = contrl;
	vdipb.ptsin = pxy;
	
	vdicall(&vdipb);
}

/****************************************************************************
 * Vdi_vsc_form                                                             *
 *  Set mouse form.                                                         *
 ****************************************************************************/
void              /*                                                        */
Vdi_vsc_form(     /*                                                        */
WORD handle,      /* Workstation handle.                                    */
MFORM *newform)   /* New mouse form.                                        */
/****************************************************************************/
{
	WORD  contrl[7];
	VDIPB vdipb;
	
	contrl[0] = 111;
	contrl[1] = 0;
	contrl[3] = 37;
	contrl[6] = handle;

	vdipb.intin = (WORD *)newform;
	vdipb.contrl = contrl;
	
	vdicall(&vdipb);
}

/****************************************************************************
 * Vdi_vsf_color                                                            *
 *  Set fill color.                                                         *
 ****************************************************************************/
WORD              /*                                                        */
Vdi_vsf_color(    /*                                                        */
WORD handle,      /* Workstation handle.                                    */
WORD color)       /* Color number.                                          */
/****************************************************************************/
{
	WORD  contrl[7];
	WORD  intout;
	VDIPB vdipb;
	
	contrl[0] = 25;
	contrl[1] = 0;
	contrl[3] = 1;
	contrl[6] = handle;

	vdipb.contrl = contrl;
	vdipb.intin = &color;
	vdipb.intout = &intout;
	
	vdicall(&vdipb);
	
	return intout;
}

/****************************************************************************
 * Vdi_vsf_interior                                                         *
 *  Set interior fill type.                                                 *
 ****************************************************************************/
WORD              /*                                                        */
Vdi_vsf_interior( /*                                                        */
WORD handle,      /* Workstation handle.                                    */
WORD interior)    /* Interior type.                                         */
/****************************************************************************/
{
	WORD  contrl[7];
	WORD  intout;
	VDIPB vdipb;
	
	contrl[0] = 23;
	contrl[1] = 0;
	contrl[3] = 1;
	contrl[6] = handle;

	vdipb.contrl = contrl;
	vdipb.intin = &interior;
	vdipb.intout = &intout;
	
	vdicall(&vdipb);
	
	return intout;
}

/****************************************************************************
 * Vdi_vsf_style                                                            *
 *  Set style of fill pattern.                                              *
 ****************************************************************************/
WORD              /*                                                        */
Vdi_vsf_style(    /*                                                        */
WORD handle,      /* Workstation handle.                                    */
WORD style)       /* Line type.                                             */
/****************************************************************************/
{
	WORD  contrl[7];
	WORD  intout;
	VDIPB vdipb;
	
	contrl[0] = 24;
	contrl[1] = 0;
	contrl[3] = 1;
	contrl[6] = handle;

	vdipb.contrl = contrl;
	vdipb.intin = &style;
	vdipb.intout = &intout;
	
	vdicall(&vdipb);
	
	return intout;
}

/****************************************************************************
 * Vdi_vsl_color                                                            *
 *  Set line color.                                                         *
 ****************************************************************************/
WORD              /*                                                        */
Vdi_vsl_color(    /*                                                        */
WORD handle,      /* Workstation handle.                                    */
WORD color)       /* Color number.                                          */
/****************************************************************************/
{
	WORD  contrl[7];
	WORD  intout;
	VDIPB vdipb;
	
	contrl[0] = 17;
	contrl[1] = 0;
	contrl[3] = 1;
	contrl[6] = handle;

	vdipb.contrl = contrl;
	vdipb.intin = &color;
	vdipb.intout = &intout;
	
	vdicall(&vdipb);
	
	return intout;
}

/****************************************************************************
 * Vdi_vsl_type                                                             *
 *  Set line type.                                                          *
 ****************************************************************************/
WORD              /*                                                        */
Vdi_vsl_type(     /*                                                        */
WORD handle,      /* Workstation handle.                                    */
WORD type)        /* Line type.                                             */
/****************************************************************************/
{
	WORD  contrl[7];
	WORD  intout;
	VDIPB vdipb;
	
	contrl[0] = 15;
	contrl[1] = 0;
	contrl[3] = 1;
	contrl[6] = handle;

	vdipb.contrl = contrl;
	vdipb.intin = &type;
	vdipb.intout = &intout;
	
	vdicall(&vdipb);
	
	return intout;
}

/****************************************************************************
 * Vdi_vst_alignment                                                        *
 *  Set text alignment.                                                     *
 ****************************************************************************/
void              /*                                                        */
Vdi_vst_alignment(/*                                                        */
WORD handle,      /* Workstation handle.                                    */
WORD halign,      /* Horzontal alignment.                                   */
WORD valign,      /* Vertical alignment.                                    */
WORD *hout,       /* Actual horizontal alignment.                           */
WORD *vout)       /* Actual vertical alignment.                             */
/****************************************************************************/
{
	WORD  contrl[7];
	WORD  intin[2];
	WORD  intout[2];
	VDIPB vdipb;
	
	contrl[0] = 39;
	contrl[1] = 0;
	contrl[3] = 2;
	contrl[6] = handle;

	intin[0] = halign;
	intin[1] = valign;

	vdipb.contrl = contrl;
	vdipb.intin = intin;
	vdipb.intout = intout;
	
	vdicall(&vdipb);
	
	*hout = intout[0];
	*vout = intout[1];
}

/****************************************************************************
 * Vdi_vst_color                                                            *
 *  Set text color.                                                         *
 ****************************************************************************/
WORD              /*                                                        */
Vdi_vst_color(    /*                                                        */
WORD handle,      /* Workstation handle.                                    */
WORD color)       /* Color number.                                          */
/****************************************************************************/
{
	WORD  contrl[7];
	WORD  intout;
	VDIPB vdipb;
	
	contrl[0] = 22;
	contrl[1] = 0;
	contrl[3] = 1;
	contrl[6] = handle;

	vdipb.contrl = contrl;
	vdipb.intin = &color;
	vdipb.intout = &intout;
	
	vdicall(&vdipb);
	
	return intout;
}

/****************************************************************************
 * Vdi_vst_effects                                                          *
 *  Set text effects.                                                       *
 ****************************************************************************/
WORD              /*                                                        */
Vdi_vst_effects(  /*                                                        */
WORD handle,      /* Workstation handle.                                    */
WORD effects)     /* Text effects.                                          */
/****************************************************************************/
{
	WORD  contrl[7];
	WORD  intout;
	VDIPB vdipb;
	
	contrl[0] = 106;
	contrl[1] = 0;
	contrl[3] = 1;
	contrl[6] = handle;

	vdipb.contrl = contrl;
	vdipb.intin = &effects;
	vdipb.intout = &intout;
	
	vdicall(&vdipb);
	
	return intout;
}

/****************************************************************************
 * Vdi_vst_height                                                           *
 *  Set text height.                                                        *
 ****************************************************************************/
WORD              /*                                                        */
Vdi_vst_height(   /*                                                        */
WORD handle,      /* Workstation handle.                                    */
WORD height,      /* Height in points.                                      */
WORD *wchar,      /* Width of character.                                    */
WORD *hchar,      /* Height of character.                                   */
WORD *wcell,      /* Width of character cell.                               */
WORD *hcell)      /* Height of character cell.                              */
/****************************************************************************/
{
	WORD  contrl[7];
	WORD  intout;
	WORD  ptsout[4];
	WORD  ptsin[2];
	VDIPB vdipb;
	
	contrl[0] = 12;
	contrl[1] = 1;
	contrl[3] = 0;
	contrl[6] = handle;

	ptsin[0] = 0;
	ptsin[1] = height;

	vdipb.contrl = contrl;
	vdipb.ptsin = ptsin;
	vdipb.intout = &intout;
	vdipb.ptsout = ptsout;
	
	vdicall(&vdipb);
	
	*wchar = ptsout[0];
	*hchar = ptsout[1];
	*wcell = ptsout[2];
	*hcell = ptsout[3];
	
	return intout;
}

/****************************************************************************
 * Vdi_vst_font                                                             *
 *  Set font id.                                                            *
 ****************************************************************************/
WORD              /*                                                        */
Vdi_vst_font(     /*                                                        */
WORD handle,      /* Workstation handle.                                    */
WORD fntid)       /* Text fontid.                                           */
/****************************************************************************/
{
	WORD  contrl[7];
	WORD  intout;
	VDIPB vdipb;
	
	contrl[0] = 21;
	contrl[1] = 0;
	contrl[3] = 1;
	contrl[6] = handle;

	vdipb.contrl = contrl;
	vdipb.intin = &fntid;
	vdipb.intout = &intout;
	
	vdicall(&vdipb);

	return intout;
}
	
/****************************************************************************
 * Vdi_vswr_mode                                                            *
 *  Set write mode.                                                         *
 ****************************************************************************/
WORD              /*                                                        */
Vdi_vswr_mode(    /*                                                        */
WORD handle,      /* Workstation handle.                                    */
WORD mode)        /* Write mode.                                            */
/****************************************************************************/
{
	WORD  contrl[7];
	WORD  intout;
	VDIPB vdipb;
	
	contrl[0] = 32;
	contrl[1] = 0;
	contrl[3] = 1;
	contrl[6] = handle;

	vdipb.contrl = contrl;
	vdipb.intin = &mode;
	vdipb.intout = &intout;
	
	vdicall(&vdipb);
	
	return intout;
}

/****************************************************************************
 * Vdi_vst_point                                                            *
 *  Set text height.                                                        *
 ****************************************************************************/
WORD              /*                                                        */
Vdi_vst_point(    /*                                                        */
WORD handle,      /* Workstation handle.                                    */
WORD point,       /* Height in points.                                      */
WORD *wchar,      /* Width of character.                                    */
WORD *hchar,      /* Height of character.                                   */
WORD *wcell,      /* Width of character cell.                               */
WORD *hcell)      /* Height of character cell.                              */
/****************************************************************************/
{
	WORD  contrl[7];
	WORD  intout;
	WORD  ptsout[4];
	VDIPB vdipb;
	
	contrl[0] = 107;
	contrl[1] = 0;
	contrl[3] = 1;
	contrl[6] = handle;

	vdipb.contrl = contrl;
	vdipb.intin = &point;
	vdipb.intout = &intout;
	vdipb.ptsout = ptsout;
	
	vdicall(&vdipb);
	
	*wchar = ptsout[0];
	*hchar = ptsout[1];
	*wcell = ptsout[2];
	*hcell = ptsout[3];
	
	return intout;
}
