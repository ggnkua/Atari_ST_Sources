/*
********************************  jmptbl.h  ***********************************
*
* $Revision: 3.1 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/jmptbl.h,v $
* =============================================================================
* $Author: lozben $	$Date: 91/01/08 16:27:20 $     $Locker:  $
* =============================================================================
*
* $Log:	jmptbl.h,v $
* Revision 3.1  91/01/08  16:27:20  lozben
* Adjusted some names to correspond to their declarations in an include file.
* 
* Revision 3.0  91/01/03  15:12:07  lozben
* New generation VDI
* 
* Revision 2.1  89/02/21  17:23:23  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
*******************************************************************************
*/

#ifndef _JMPTBL_H_
#define _JMPTBL_H_

extern    WORD    v_nop();             /*  0   */

extern    WORD    v_opnwk();           /*  1   */
extern    WORD    v_clswk();           /*  2   */
extern    WORD    CLEARMEM();          /*  3   */
extern    WORD    v_updwk();           /*  4   */
extern    WORD    CHK_ESC();           /*  5   */

extern    WORD    v_pline();           /*  6   */
extern    WORD    v_pmarker();         /*  7   */
extern    WORD    d_gtext();           /*  8   */
extern    WORD    v_fillarea();        /*  9   */
extern    WORD    v_cellarray();       /*  10  */

extern    WORD    v_gdp();	       /*  11  */
extern    WORD    dst_height();        /*  12  */
extern    WORD    dst_rotation();      /*  13  */
extern    WORD    vs_color();	       /*  14  */
extern    WORD    vsl_type();	       /*  15  */

extern    WORD    vsl_width();	       /*  16  */
extern    WORD    vsl_color();	       /*  17  */
extern    WORD    vsm_type();	       /*  18  */
extern    WORD    vsm_height();	       /*  19  */
extern    WORD    vsm_color();	       /*  20  */

extern    WORD    dst_font();	       /*  21  */
extern    WORD    dst_color();	       /*  22  */
extern    WORD    vsf_interior();      /*  23  */
extern    WORD    vsf_style();	       /*  24  */
extern    WORD    vsf_color();	       /*  25  */

extern    WORD    vq_color();	       /*  26  */
extern    WORD    vq_cellarray();      /*  27  */
extern    WORD    v_locator();         /*  28  */
extern    WORD    v_valuator();        /*  29  */
extern    WORD    v_choice();          /*  30  */

extern    WORD    v_string();          /*  31  */
extern    WORD    vswr_mode();         /*  32  */
extern    WORD    vsin_mode();         /*  33  */
extern    WORD    vql_attr();          /*  35  */

extern    WORD    vqm_attr();          /*  36  */
extern    WORD    vqf_attr();          /*  37  */
extern    WORD    dqt_attributes();    /*  38  */
extern    WORD    dst_alignment();     /*  39  */

extern    WORD    d_opnvwk();          /* 100  */

extern    WORD    d_clsvwk();          /* 101  */
extern    WORD    vq_extnd();          /* 102  */
extern    WORD    d_contourfill();     /* 103  */
extern    WORD    vsf_perimeter();     /* 104  */
extern    WORD    v_get_pixel();       /* 105  */

extern    WORD    dst_style();         /* 106  */
extern    WORD    dst_point();         /* 107  */
extern    WORD    vsl_ends();          /* 108  */
extern    WORD    dro_cpyfm();         /* 109  */
extern    WORD    TRAN_FM();           /* 110  */

extern    WORD    XFM_CRFM();          /* 111  */
extern    WORD    dsf_udpat();         /* 112  */
extern    WORD    vsl_udsty();         /* 113  */
extern    WORD    dr_recfl();          /* 114  */
extern    WORD    vqi_mode();          /* 115  */

extern    WORD    dqt_extent();        /* 116  */
extern    WORD    dqt_width();         /* 117  */
extern    WORD    EX_TIMV();           /* 118  */
extern    WORD    dt_loadfont();       /* 119  */
extern    WORD    dt_unloadfont();     /* 120  */

extern    WORD    drt_cpyfm();         /* 121  */
extern    WORD    v_show_c();          /* 122  */
extern    WORD    v_hide_c();          /* 123  */
extern    WORD    vq_mouse_status();   /* 124  */
extern    WORD    VEX_BUTV();          /* 125  */

extern    WORD    VEX_MOTV();          /* 126  */
extern    WORD    VEX_CURV();          /* 127  */
extern    WORD    vq_key_s();          /* 128  */
extern    WORD    s_clip();            /* 129  */
extern    WORD    dqt_name();          /* 130  */

extern    WORD    dqt_fontinfo();      /* 131  */

#endif
