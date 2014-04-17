/*
********************************* attrdef.h ***********************************
*
* $Revision: 3.1 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/attrdef.h,v $
* =============================================================================
* $Author: lozben $	$Date: 91/01/04 12:20:40 $     $Locker:  $
* =============================================================================
*
* $Log:	attrdef.h,v $
* Revision 3.1  91/01/04  12:20:40  lozben
* Typedefed structure atribute to ATTRIBUTE.
* 
* Revision 3.0  91/01/03  15:05:57  lozben
* New generation VDI
* 
* Revision 2.2  90/04/24  15:51:14  lozben
* Expanded the user defined pattern array from a 4x16 to an 8x16.
* 
* Revision 2.1  89/02/21  17:28:19  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
*******************************************************************************
*/

#ifndef _ATTRDEF_H_
#define _ATTRDEF_H_

/* Structure to hold data for a virtual workstation */
typedef struct attribute {
    WORD chup;			    /* Character Up vector 		    */
    WORD clip;			    /* Clipping Flag 			    */
    FONT_HEAD *cur_font;	    /* Pointer to current font 		    */
    WORD dda_inc;		    /* Fraction to be added to the DDA 	    */
    WORD multifill;		    /* Multi-plane fill flag 		    */
    WORD patmsk;		    /* Current pattern mask 		    */
    WORD *patptr;		    /* Current pattern pointer 		    */
    WORD pts_mode;		    /* TRUE if height set in points mode    */
    WORD *scrtchp;		    /* Pointer to text scratch buffer 	    */
    WORD scrpt2;		    /* Offset to large text buffer 	    */
    WORD style;			    /* Current text style 		    */
    WORD t_sclsts;		    /* TRUE if scaling up 		    */
    WORD fill_color;		    /* Current fill color (PEL value) 	    */
    WORD fill_index;		    /* Current fill index 		    */
    WORD fill_per;		    /* TRUE if fill area outlined 	    */
    WORD fill_style;		    /* Current fill style 		    */
    WORD h_align;		    /* Current text horizontal alignment    */
    WORD handle;		    /* handle for attribute area	    */
    WORD line_beg;		    /* Beginning line endstyle 		    */
    WORD line_color;		    /* Current line color (PEL value) 	    */
    WORD line_end;		    /* Ending line endstyle 		    */
    WORD line_index;		    /* Current line style 		    */
    WORD line_width;		    /* Current line width 		    */
    FONT_HEAD *loaded_fonts;	    /* Pointer to first loaded font 	    */
    WORD mark_color;		    /* Current marker color (PEL value)	    */
    WORD mark_height;		    /* Current marker height 		    */
    WORD mark_index;		    /* Current marker style 		    */
    WORD mark_scale;		    /* Current scale factor for marker data */
    struct attribute *next_work;    /* Pointer to next virtual workstation  */
    WORD num_fonts;		    /* Total number of faces available 	    */
    WORD scaled;		    /* TRUE if font scaled in any way	    */
    FONT_HEAD scratch_head;	    /* Holder for the doubled font data	    */
    WORD text_color;		    /* Current text color (PEL value) 	    */
    WORD ud_ls;			    /* User defined linestyle 		    */
    WORD ud_patrn[32*16];	    /* User defined pattern 		    */
    WORD v_align;		    /* Current text vertical alignment 	    */
    WORD wrt_mode;		    /* Current writing mode 		    */
    WORD xfm_mode;		    /* Transformation mode requested 	    */
    WORD xmn_clip;		    /* Low x point of clipping rectangle    */
    WORD xmx_clip;		    /* High x point of clipping rectangle   */
    WORD ymn_clip;		    /* Low y point of clipping rectangle    */
    WORD ymx_clip;		    /* High y point of clipping rectangle   */
} ATTRIBUTE;

#endif
