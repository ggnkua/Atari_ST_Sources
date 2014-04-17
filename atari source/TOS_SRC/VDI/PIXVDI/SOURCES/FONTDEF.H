/*
********************************  fontdef.h  **********************************
*
* $Revision: 3.1 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/fontdef.h,v $
* =============================================================================
* $Author: lozben $	$Date: 91/01/04 12:24:15 $     $Locker:  $
* =============================================================================
*
* $Log:	fontdef.h,v $
* Revision 3.1  91/01/04  12:24:15  lozben
* Typedefed structure font_head to FONT_HEAD.
* 
* Revision 3.0  91/01/03  15:19:51  lozben
* New generation VDI
* 
*******************************************************************************
*/

#ifndef _FONTDEF_H_
#define _FONTDEF_H_

/* fh_flags   */
#define	DEFAULT 1	/* this is the default font (face and size) */
#define	HORZ_OFF  2	/* there are left and right offset tables */
#define STDFORM  4	/* is the font in standard format */
#define MONOSPACE 8	/* is the font monospaced */

/* style bits */
#define	THICKEN	1
#define	LIGHT	2
#define	SKEW	4
#define	UNDER	8
#define	OUTLINE 16
#define	SHADOW	32

typedef struct font_head {	/* descibes a font */
    WORD  font_id;
    WORD  point;
    BYTE  name[32];
    UWORD first_ade;
    UWORD last_ade;
    UWORD top;
    UWORD ascent;
    UWORD half;
    UWORD descent;		
    UWORD bottom;
    UWORD max_char_width;
    UWORD max_cell_width;
    UWORD left_offset;		/* amount character slants left when skewed */
    UWORD right_offset;		/* amount character slants right */
    UWORD thicken;		/* number of pixels to smear */
    UWORD ul_size;		/* size of the underline */
    UWORD lighten;		/* mask to and with to lighten  */
    UWORD skew;			/* mask for skewing */
    UWORD flags;		    

    UBYTE *hor_table;	  	/* horizontal offsets */
    UWORD *off_table;		/* character offsets  */
    UWORD *dat_table;		/* character definitions */
    UWORD form_width;
    UWORD form_height;

    struct font_head *next_font;/* pointer to next font */
    UWORD font_seg;
} FONT_HEAD;

#endif
