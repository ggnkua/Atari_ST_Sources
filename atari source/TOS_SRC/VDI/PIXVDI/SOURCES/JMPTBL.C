/*
******************* Revision Control System *****************************
*
* $Author: lozben $
* =======================================================================
*
* $Date: 91/01/18 19:04:53 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log:	jmptbl.c,v $
* Revision 3.2  91/01/18  19:04:53  lozben
* Changed cur_font to CUR_FONT.
* 
* Revision 3.1  91/01/10  17:37:41  lozben
* Made patptr, patmsk, multifill, scrpt2, and scrtchp uppercase, beacause
* there was a name conflict with the defines and the attribute structure.
* 
* Revision 3.0  91/01/03  15:12:02  lozben
* New generation VDI
* 
* Revision 2.1  89/02/21  17:23:19  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  87/11/20  15:16:00  lozben
* Initial revision
* 
* =======================================================================
*
* $Revision: 3.2 $
* =======================================================================
*
* $Source: /u/lozben/projects/vdi/mtaskvdi/RCS/jmptbl.c,v $
* =======================================================================
*
*************************************************************************
*/

#include	"portab.h"
#include	"fontdef.h"
#include	"attrdef.h"
#include	"scrndev.h"
#include	"vardefs.h"
#include	"lineavar.h"
#include	"gsxdef.h"
#include	"gsxextrn.h"
#include	"jmptbl.h"
#include	"proto.h"

WORD	(*jmptb1[])() =
{
	v_opnwk,
	v_clswk,
	CLEARMEM,
	v_nop,
	CHK_ESC,
	v_pline,
	v_pmarker,
	d_gtext,
	v_fillarea,
	v_cellarray,
	v_gdp,
	dst_height,
	dst_rotation,
	vs_color,
	vsl_type,
	vsl_width,
	vsl_color,
	vsm_type,
	vsm_height,
	vsm_color,
	dst_font,
	dst_color,
	vsf_interior,
	vsf_style,
	vsf_color,
	vq_color,
	vq_cellarray,
	v_locator,
	v_valuator,
	v_choice,
	v_string, 
	vswr_mode,
	vsin_mode,
	v_nop,
	vql_attr,
	vqm_attr,
	vqf_attr,
	dqt_attributes,
	dst_alignment
};

WORD	(*jmptb2[])() =
{
	d_opnvwk,
	d_clsvwk,
	vq_extnd,
	d_contourfill,
	vsf_perimeter,
	v_get_pixel,
	dst_style,
	dst_point,
	vsl_ends,
	dro_cpyfm,
	dr_trn_fm,
	XFM_CRFM,
	dsf_udpat,
	vsl_udsty,
	dr_recfl,
	vqi_mode,
	dqt_extent,
	dqt_width,
	EX_TIMV,
	dt_loadfont,
	dt_unloadfont,
	drt_cpyfm,
	v_show_c,
	v_hide_c,
	vq_mouse_status,
	VEX_BUTV,
	VEX_MOTV,
	VEX_CURV,
	vq_key_s,
	s_clip,
	dqt_name,
	dqt_fontinfo
};

/************************************************************************
*    Screen Driver Entry Point						*
************************************************************************/

VOID
SCREEN( VOID ) 
{
    REG WORD	    opcode, r, *control;
    REG ATTRIBUTE   *work_ptr;

    control = CONTRL;
    r = *(control+6);

    opcode = *control;

    /* no ints out & no pts out */

    *(control+2) = 0;
    *(control+4) = 0;

    FLIP_Y = 0;

    if (opcode != 1 && opcode != 100) {

	/* Find the attribute area which matches the handle */

	work_ptr = &virt_work;

	do {
	    if (r == work_ptr->handle)
		goto found_handle;
	} while ( (work_ptr = work_ptr->next_work) );

	/* handle is invalid if we fall through, so exit */

	return( VOID );

	found_handle:

	cur_work = work_ptr;
	INQ_TAB[19] = CLIP = work_ptr->clip;
	XMN_CLIP = work_ptr->xmn_clip;
	YMN_CLIP = work_ptr->ymn_clip;
	XMX_CLIP = work_ptr->xmx_clip;
	YMX_CLIP = work_ptr->ymx_clip;

	WRT_MODE = work_ptr->wrt_mode;

	PATPTR = work_ptr->patptr;
	PATMSK = work_ptr->patmsk;

	if (work_ptr->fill_style == 4)
	    MULTIFILL = work_ptr->multifill;
	else
	    MULTIFILL = 0;

	font_ring[2] = work_ptr->loaded_fonts;

	DEV_TAB[10] = work_ptr->num_fonts;

	DDA_INC = work_ptr->dda_inc;
	T_SCLSTS = work_ptr->t_sclsts;
	DOUBLE = work_ptr->scaled;

	CUR_FONT = work_ptr->cur_font;

	MONO_STATUS = MONOSPACE & CUR_FONT->flags;
	SCRPT2 = work_ptr->scrpt2;
	SCRTCHP = work_ptr->scrtchp;
	STYLE = work_ptr->style;
	h_align = work_ptr->h_align;
	v_align = work_ptr->v_align;
	CHUP = work_ptr->chup;

    } /* end if open work or vwork */

    if ( opcode >= 1 && opcode <= 39 ) {
	opcode--;
	(*jmptb1[opcode])();
    }

    else if ( opcode >= 100 && opcode <= 131 ) {
	opcode -= 100;
	(*jmptb2[opcode])();
    }
}
