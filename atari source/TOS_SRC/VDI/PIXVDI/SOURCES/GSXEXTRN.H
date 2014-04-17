/*
********************************  gsxextrn.h  *********************************
*
* $Revision: 3.2 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/gsxextrn.h,v $
* =============================================================================
* $Author: lozben $	$Date: 91/09/10 19:55:20 $     $Locker:  $
* =============================================================================
*
* $Log:	gsxextrn.h,v $
* Revision 3.2  91/09/10  19:55:20  lozben
* Deleted the extern definition for _q_circle.
* 
* Revision 3.1  91/07/29  14:38:48  lozben
* Declared all the needed externals.
* 
* Revision 3.0  91/01/03  15:10:20  lozben
* New generation VDI
* 
* Revision 2.3  89/06/30  17:15:46  lozben
* Adjusted the declaration LINE_STYLE[] the name was spelled
* different in three different files (we lucked out because
* it wasn't the first 8 characters, which makeup the symbol name).
* 
* Revision 2.2  89/05/16  16:09:30  lozben
* Added declarations for FG_B_PLANES & REQ_X_COL, deleted
* declarations for FG_BP_[1,2,3,4].
* 
* Revision 2.1  89/02/21  17:23:01  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
*******************************************************************************
*/

#ifndef _GSXEXTRN_H_
#define _GSXEXTRN_H_

/* line_a variable structure */
extern	VDIVARS	*la;

/* Virtual workstation attributes   */
extern	ATTRIBUTE virt_work;

/* overlay variables */
extern  WORD    seed_type;      /* indicates the type of fill               */
extern  LONG    search_color;   /* the color of the border                  */
extern  WORD    Qbottom;        /* the bottom of the Q (zero)               */
extern  WORD    Qtop;           /* points top seed + 3                      */
extern  WORD    *Qptr;	 	/* points to the active point               */
extern  WORD    Qtmp;
extern  WORD    Qhole;		/* an empty space in the Q                  */
extern  WORD    oldy;           /* the previous scan line                   */
extern  WORD    oldxleft;       /* left end of line at oldy                 */
extern  WORD    oldxright;      /* right end                                */
extern  WORD    newxleft;       /* ends of line at oldy +                   */
extern  WORD    newxright;      /* the current direction                    */
extern  WORD    xleft;          /* temporary endpoints                      */
extern  WORD    xright;
extern  WORD    direction;      /* is next scan line up or down?            */
extern  WORD    done;           /* is the seed queue full?                  */
extern  WORD    gotseed;        /* a seed was put in the Q                  */
extern  WORD    leftoldy;       /* like _oldy. (new seedfill)               */
extern  WORD    leftdirection;  /* like _direction. (new seedfill)          */
extern  WORD    leftseed;       /* like _gotseed. (new seedfill)            */
extern  WORD    h_align;
extern  WORD    leftcollision;  /* like _collision. (new seedfill)          */
extern  WORD    v_align;        /* scaler alignments                        */
extern  WORD    width;
extern  WORD    collision;      /* seed was removed from Q (new rtn)        */
extern  WORD    Q[];            /* storage for the seed points (1280)       */
extern  WORD    height;         /* extent of string set in dqt_extent       */
extern  WORD    wordx;
extern  WORD    wordy;          /* add this to each space for interword     */
extern  WORD    rmword;         /* the number of pixels left over           */
extern  WORD    rmwordx;
extern  WORD    rmwordy;        /* add this to use up remainder             */
extern  WORD    charx;
extern  WORD    chary;          /* inter-character distance                 */
extern  WORD    rmchar;         /* number of pixels left over               */
extern  WORD    rmcharx;
extern  WORD    rmchary;        /* add this to use up remainder             */
extern  WORD    FLIP_Y;         /* Non-zero PTSOUT contains magnitudes      */
extern  WORD    deftxbu[];      /* scratch buf for 8x16 (276 bytes)         */


extern  FONT_HEAD   first;      /* The small system font                    */
extern	FONT_HEAD   ram8x16, ram8x8, ram16x32;

extern  WORD    scrtsiz;
extern 	WORD	ROM_DEV_TAB[];  /* initial intout array for open work       */
extern 	WORD	ROM_SIZ_TAB[];  /* initial ptsout array for open work       */
extern	WORD	ROM_INQ_TAB[];  /* extended inquire values */
extern	WORD	MAP_COL[], REV_MAP_COL[];
extern	WORD	LINE_STYLE[];
extern	WORD 	DITHER[];
extern  WORD    HAT_0_MSK, HAT_1_MSK;
extern	WORD	HATCH0[],HATCH1[],OEMPAT[];
extern	WORD	ROM_UD_PATRN[];
extern	WORD	SOLID;
extern	WORD	HOLLOW;
extern	WORD	DITHRMSK, OEMMSKPAT;
extern  WORD    m_dot[], m_plus[], m_star[], m_square[], m_cross[], m_dmnd[];
extern  WORD    plane_mask[];
extern  WORD    *markhead[];
extern	LONG	colors[];

/* Assembly Language Support Routines */
extern	VOID	ABLINE(),   HABLINE(),  CLEARMEM();
extern	VOID	CHK_ESC(),  INIT_G(),   DINIT_G();
extern	VOID	CLC_FLIT(), SMUL_DIV(), GSHIFT_S();
extern  VOID    st_fl_p(),  DIS_CUR(),  GCHC_KEY();
extern  VOID    HIDE_CU(),  GLOC_KEY(), GCHR_KEY();
extern  VOID    XFM_CRFM(), XFM_UNDL(), COPY_RFM();
extern  VOID    VEX_BUTV(), VEX_MOTV(), RECTFILL();
extern  VOID    TEXT_BLT(), VEX_CURV();
extern	LONG	get_pix();

/* C Support routines */
extern	WORD 	isin();
extern	WORD 	icos();
extern  WORD	text_init();
extern  WORD    screen();
extern  WORD    VEC_LEN();


/* device specific drawing primitives */
extern	VOID (**STHardList)();	    /* orig ST routines blitter		    */
extern	VOID (**STSoftList)();	    /* orig ST routines no blitter	    */
extern	VOID (**PixHardList)();	    /* pixel packed routines		    */
extern	VOID (**PixSoftList)();	    /* pixel packed routines		    */
extern	VOID (**SPPixSoftList)();   /* pixel packed routines		    */
extern	VOID (**SPPixHardList)();   /* SPARROW routines (hard blit)	    */

#endif
