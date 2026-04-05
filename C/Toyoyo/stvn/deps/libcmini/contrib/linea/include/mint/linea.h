/*
 * Common include file for C interface  to low level Line A calls
 *
 *	++jrb	bammi@cadence.com
 */
#ifndef _MINT_LINEA_H
#define _MINT_LINEA_H

#ifndef	_FEATURES_H
# include <features.h>
#endif

__BEGIN_DECLS

/*****************************************************************************\
*		                                                              *
*                                 Defines                                     *
*									      *
\*****************************************************************************/

/*
 *  Object colors (default pallette)
 *
 */
#define WHITE    0
#define BLACK    1
#define RED      2
#define GREEN    3
#define BLUE     4
#define CYAN     5
#define YELLOW   6
#define MAGENTA  7
#define LWHITE   8
#define LBLACK   9
#define LRED     10
#define LGREEN   11
#define LBLUE    12
#define LCYAN    13
#define LYELLOW  14
#define LMAGENTA 15


/* 
 * Vdi writing modes
 *
 */
#define MD_REPLACE 1
#define MD_TRANS   2
#define MD_XOR     3
#define MD_ERASE   4


/*
 * Raster Op Codes
 *
 */
#define ALL_WHITE  0
#define S_AND_D    1
#define	S_AND_NOTD 2
#define S_ONLY     3
#define NOTS_AND_D 4
#define	D_ONLY     5
#define S_XOR_D    6
#define S_OR_D     7
#define	NOT_SORD   8
#define	NOT_SXORD  9
#define D_INVERT  10
#define	NOT_D     10
#define	S_OR_NOTD 11
#define NOT_S	  12
#define NOTS_OR_D 13
#define	NOT_SANDD 14
#define ALL_BLACK 15

/*
 * Sprite formats
 *
 */
#define SP_VDI	    0
#define SP_XOR	    1

/*
 * Line A Opcodes
 *
 */
#define	INIT		0
#define PUTPIXEL	1
#define GETPIXEL	2
#define LINE		3
#define HLINE		4
#define RECTANGLE	5
#define FPOLYGON	6
#define BITBLT		7
#define TEXTBLT		8
#define SHOWMOUSE	9
#define HIDEMOUSE	10
#define TRANMOUSE	11
#define USPRITE		12
#define DSPRITE		13
#define CPYRASTER	14
#define FSEEDFILL	15	/* ROM TOS only	*/


/*****************************************************************************\
*		                                                              *
*                                 Types                                       *
*									      *
\*****************************************************************************/

	/*
	 * Global Variables at negative offsets from the Line A parameter
	 * block address returned by init. (I have no way of telling if this
	 * list is complete).
	 *
	 */
/* Name   Offset  Type	Description					     */
/* --------------------------------------------------------------------------*/
/* V_BYTES_LIN -2  W	bytes/line for font				     */
/* V_Y_MAX    -4   W	Max Y pixel value of the screen			     */
/* V_STATUS   -6   W	Text Status byte				     */
/* 			  Bit	Field		Zero		One	     */
/*			  0	cursor flash    disabled	enabled	     */
/*			  1	flash state     off		on	     */
/*			  2	cursor visible  no		yes          */
/*			  3     end of line     no-wrap		wrap	     */
/*			  4     inverse video   on              off          */
/*                        5     cursor saved    false           true	     */
/* V_OFF_AD  -10   L	Font offset table address			     */
/* V_X_MAX   -12   W	Max X pixel value				     */
/* V_FNT_WR  -14   W	Width of Font Form in bytes (see type FONT below)    */
/* V_FNT_ST  -16   W	First font ASCII code (first_ade)		     */
/* V_FNT_ND  -18   W	Last  font ASCII code (last_ade )                    */
/* V_FNT_AD  -22   L	Font Form address				     */
/*			Mono Spaced, 8 pixels wide and byte aligned, any ht. */
/* V_CUR_TIM -23   B	Cursor countdown timer				     */
/* V_CUR_CNT -24   B	Cursor flash interval( in frames)		     */
/* V_CUR_CY  -26   W	Y cursor position				     */
/* V_CUR_CX  -28   W	X cursor position				     */
/* V_CUR_OFF -30   W	Offset from screen base to first cell (bytes)	     */
/* V_CUR_AD  -34   L	Current cursor address				     */
/* V_COL_FG  -36   W	Foreground color index				     */
/* V_COL_BG  -38   W	Background color index				     */
/* V_CEL_WR  -40   W	Offset to next vertical cell (bytes)		     */
/* V_CEL_MY  -42   W	Max cells high - 1				     */
/* V_CEL_MX  -44   W	Max cells across - 1				     */
/* V_CEL_HT  -46   W	Cell height in pixels (font form's height)	     */
/* --------------------------------------------------------------------------*/

/*
 * Atari finally named these variables
 * so here they are
 *
 */
#define V_CEL_HT    (*((short  *)((char  *)__aline + -46L)))
#define V_CEL_MX    (*((short  *)((char  *)__aline + -44L)))
#define V_CEL_MY    (*((short  *)((char  *)__aline + -42L)))
#define V_CEL_WR    (*((short  *)((char  *)__aline + -40L)))
#define V_COL_BG    (*((short  *)((char  *)__aline + -38L)))
#define V_COL_FG    (*((short  *)((char  *)__aline + -36L)))
#define V_CUR_AD    (*((char  **)((char  *)__aline + -34L)))
#define V_CUR_OFF   (*((short  *)((char  *)__aline + -30L)))
#define V_CUR_CX    (*((short  *)((char  *)__aline + -28L)))
#define V_CUR_CY    (*((short  *)((char  *)__aline + -26L)))
#define V_CUR_CNT   (*((char   *)((char  *)__aline + -24L)))
#define V_CUR_TIM   (*(          ((char  *)__aline + -23L)))
#define V_FNT_AD    (*((char  **)((char  *)__aline + -22L)))
#define V_FNT_ND    (*((short  *)((char  *)__aline + -18L)))
#define V_FNT_ST    (*((short  *)((char  *)__aline + -16L)))
#define V_FNT_WR    (*((short  *)((char  *)__aline + -14L)))
#define V_X_MAX     (*((short  *)((char  *)__aline + -12L)))
#define V_OFF_AD    (*((char  **)((char  *)__aline + -10L)))
#define V_STATUS    (*((short  *)((char  *)__aline + -6L)))
#define V_Y_MAX     (*((short  *)((char  *)__aline + -4L)))
#define V_BYTES_LIN (*((short  *)((char  *)__aline + -2L)))

 	/* more obscure variables again found at negative offset */

/* pointer to current font 						*/
#define	CUR_FONT	(*((__FONT **)((char *)__aline + -906L)))

/* Mouse X hot spot   							*/
#define M_POS_HX 	(*((short *)((char *)__aline + -856L)))

/* Mouse Y hot spot   							*/
#define M_POS_HY 	(*((short *)((char *)__aline + -854L)))

/* writing mode for mouse						*/
#define M_PLANES 	(*((short *)((char *)__aline + -852L)))

/* mouse bkgd color    							*/
#define M_CDB_BG 	(*((short *)((char *)__aline + -850L)))

/* mouse fgd color     							*/
#define M_CDB_FG 	(*((short *)((char *)__aline + -848L)))

/* mous form, 32 words alternating words: bkgd-0, fgd-0 ... bkgd-15 fgd-16 */
#define MASK_FORM 	((short *)((char *)__aline + -846L))
	             
/* 45 words of vq_extnd 						*/
#define INQ_TAB 	((short *)((char *)__aline + -782L))

/* 45 words of v_opnwk  						*/
#define DEV_TAB 	((short *)((char *)__aline + -692L))

/* current mous X        						*/
#define GCURX   	(*((short *)((char *)__aline + -602L)))

/* current mous Y        						*/
#define GCURY   	(*((short *)((char *)__aline + -600L)))

/* current mous hide cnt						*/
#define M_HID_CT 	(*((short *)((char *)__aline + -598L)))

/* mous button stat, bit0 = left, 1 = right,  0=up, 1=down      	*/
#define MOUSE_BT 	(*((short *)((char *)__aline + -596L)))
				 
/* 3*16 words of vq_color 						*/
#define REQ_COL 	((short *)((char *)__aline + -594L))

/* 15 words containing text, line and marker sizes in dev coords
     0 min char width
     1 min char height
     2 max char width
     3 max char height
     4 min line width
     5 reserved
     6 max line width
     7 reserved
     8 min marker width
     9 min marker height
    10 max marker width
    11 max marker height
    12-14  RESERVED           						*/
#define SIZ_TAB 	((short *)((char *)__aline + -498L))

/* Pointer to current virtual workstation attributes 			*/
#define CUR_WORK 	(*((short **)((char *)__aline + -464L)))

/* -> default font hdr 							*/
#define DEF_FONT 	(*((__FONT **)((char *)__aline + -460L)) )


/* FONT_RING is an array of four longword pointers to linked lists of
font headers.  The first entry is the head pointer to the font list,
the second and third are continuation fields, and the fourth is a null
terminator. 								*/
#define FONT_RING 	((short *)((char *)__aline + -456L))

/*  Number of fonts in the FONT_RING lists  				*/
#define FONT_COUNT 	(*((short *)((char *)__aline + -440L)))

/* Mouse status
     Bit 0 = left mouse button status  (0=up, 1=down)
     Bit 1 = right mouse button status  (0=up, 1=down)
     Bit 2 = reserved
     Bit 3 = reserved
     Bit 4 = reserved
     Bit 5 = mouse movement flag  (0=no movement, 1=movement)
     Bit 6 = right mouse button change flag  (0=nochange, 1=change)
     Bit 7 = left mouse button change flag  (0=nochange, 1=change)      */
#define CUR_MS_STAT 	(*((char *)__aline + -348L))

/* Hide depth of alpha cursor 						*/
#define V_HID_CNT 	(*((short *)((char *)__aline + -346L)))

/* Mouse cursor X position 						*/
#define CUR_X  		(*((short *)((char *)__aline + -344L)))

/* Mouse cursor Y position 						*/
#define CUR_Y   	(*((short *)((char *)__aline + -342L)))

/* Nonzero = draw mouse form on VBLANK. 				*/
#define CUR_FLAG 	(*((char *)__aline + -340L))
                            
/* Non-zero if mouse interrupt processing is enabled 			*/
#define MOUSE_FLAG 	(*((char *)__aline + -339L))                    

/* Saved alpha cursor X coord 						*/
#define V_SAV_X    	(*((short *)((char *)__aline + -334L)))

/* Saved alpha cursor Y coord 						*/
#define V_SAV_Y     	(*((short *)((char *)__aline + -332L)))

/* height of saved form 						*/
#define SAVE_LEN      	(*((short *)((char *)__aline + -330L)))

/* Screen address of first word saved from screen			*/
#define SAVE_ADDR    	(*((char **)((char *)__aline + -328L)))
   
/* Save Status
    bit 0 =>  1 = info in buffer is valid.
              0 = info in buffer is not valid.
    bit 1 =>  If 1, double-word wide area was saved.
              If zero, word wide area was saved.
    bits 2-15 RESERVED 							*/
#define SAVE_STAT      (*((short *)((char *)__aline + -324L)))

/* Save up to 4 planes, 16 longwords per plane. 			*/
#define SAVE_AREA      ((long *)((char *)__aline + -322L))
          
/* USER_TIM is a pointer to a user installed routine executed on each
   system timer tick.  When done, this routine should jump to the
   address held in NEXT_TIM.  For more information, see the VDI manual
   under Exchange Timer Interrupt Vector. 				*/
#define USER_TIM       (*((void(**)())((char *)__aline + -66L)))
#define NEXT_TIM       (*((void(**)())((char *)__aline + -62L)))
          
/* User button vector */          
#define USER_BUT       (*((void(**)())((char *)__aline + -58L)))

/* User cursor vector */
#define USER_CUR       (*((void(**)())((char *)__aline + -54L)))

/* User motion vector */
#define USER_MOT       (*((void(**)())((char *)__aline + -50L)))


	/* A pointer to the type LINEA is returned by the Line A init call
	 * ($A000), in registers A0 and D0.
         * This pointer is saved in the global variable '__aline'.
	 *
	 */
typedef struct {

/* Type    Name       Offset   Function		    Comments		     */
/* ------------------------------------------------------------------------- */
   short  _VPLANES;   /*  0  # of Planes	 Also see CurrRez            */
   short  _VWRAP;     /*  2  Bytes / scan line    "    "    "                */
		      /*     VWRAP can be changed to implement special effect*/
		      /*     Doubling VWRAP will skip every other scan line  */
		      /*					             */
		      /*                                                     */
   short  *_CONTRL;   /*  4  Ptr to CONTRL Array  Contrl gets set to this    */
   short  *_INTIN;    /*  8  Ptr to INTIN  Array  Intin  gets set to this    */
   short  *_PTSIN;    /* 12  Ptr to PTSIN  Array  Ptsin  gets set to this    */
   short  *_INTOUT;   /* 16  Ptr to INTOUT Array  Intout gets set to this    */
   short  *_PTSOUT;   /* 20  Ptr to PTSOUT Array  Ptsout gets set to this    */
		      /*     CONTRL is the control array		     */
		      /*     INTIN is the array of input parameters	     */
		      /*     PTSIN is the array of input coordinates         */
		      /*	  Even entrys are X coordinate		     */
		      /* 	  Odd  entrys are corresponding Y coodinates */
		      /*     INTOUT is the array of output parameters        */
		      /*     PTSOUT is the array of output coordinates       */
		      /*	organized like PTSIN.			     */
		      /*					             */
   short  _COLBIT0;   /* 24  Plane 0 Color Value  All Three Rez's	     */
   short  _COLBIT1;   /* 26  Plane 1 Color Value  Med and Low Rez only	     */
   short  _COLBIT2;   /* 28  Plane 2 Color Value  Low Rez only 		     */
   short  _COLBIT3;   /* 30  Plane 3 Color Value  Low Rez Only 		     */
		      /*     Foreground color COLBIT0 + 2*COLBIT1 + 4*COLBIT2*/
		      /*	              + 8*COLBIT3		     */
		      /*					             */
		      /*                                                     */
   short  _LSTLIN;    /* 32  Draw last pixel of a line? 0=yes  non0=no	     */
		      /*     This prevents two connecting lines from XORing  */
		      /*     a common endpoint out of existence		     */
		      /*					             */
   short  _LNMASK;    /* 34  Linemask used when drawing lines, same as Vdi's */
		      /*     line style (rotated to aligned with rightmost   */
		      /*     endpoint when drawing lines)                    */
		      /*					             */
   short  _WMODE;     /* 36  Writing mode                                    */
		      /*     0=Replace Mode-Replace all bits in Dest with src*/
		      /*     1=Trans. Mode-Only additional bits in src set(OR*/
		      /*     2=Xor Mode- Src XOR Dest			     */
		      /*     3=Inverse Trans.- (NOT src) Or Dest             */
		      /*     Values upto 16 are permitted                    */
		      /*					             */
   short  _X1;        /* 38  X1 coordinate used in various calls             */
		      /*					             */
   short  _Y1;        /* 40  Y1 coordinate used in various calls             */
		      /*					             */
   short  _X2;        /* 42  X2 coordinate used in various calls             */
		      /*					             */
   short  _Y2;        /* 44  Y2 coordinate used in various calls             */
		      /*					             */
		      /*                                                     */
   short  *_PATPTR;   /* 46  Pointer to current fill pattern                 */
                      /*     Must be integral power of 2 (words) in length   */
   short  _PATMSK;    /* 50  I don't know why they call it a mask. It is in  */
		      /*     reality the length in words of the current patt.*/
   short  _MFILL;     /* 52  Multi Plane fill flag 1 == Current fill Pattern */
		      /*     is for Muti Plane.                              */
		      /*                                                     */
		      /*                                                     */
   short  _CLIP;      /* 54  Clipping Flag 1 == TRUE                         */
   short  _XMINCL;    /* 56  Min X of clipping window			     */
   short  _YMINCL;    /* 58  Min Y of clipping window                        */
   short  _XMAXCL;    /* 60  Max X of clipping window			     */
   short  _YMAXCL;    /* 62  Max Y of clipping window                        */
		      /*                                                     */
		      /*                                                     */
   short  _XDDA;      /* 64  Accumulator for Scaling, Must be set to 0x08000 */
                      /*     before each call to Text Blt. Done for you in   */
		      /*     in aline_text()                                 */
   short  _DDAINC;    /* 66  Scaling factor - Fractional amount to scale char*/
		      /*     When scaling up = 256 *(Size-Textsize)/Textsize */
		      /*     When scaling down = 256*(Size)/Textsize         */
		      /*     scaling down does not work                      */
   short  _SCALDIR;   /* 68  Scaling direction 0 == down                     */
   short  _MONO;      /* 70  Mono flag 0== current font is a propotional font*/
		      /*     Its Ok for Thickening to increase the width of  */
		      /*     the current character.                          */
		      /*     1 == current font is mono spaced, so thickening */
		      /*     may not increase the width of the current char  */
		      /*                                                     */
   short  _SOURCEX;   /* 72  X coordinate of character in the font form      */
		      /*     SOURCEX is calculated from info in the font     */
		      /*     header for the current font (see __FONT type)   */
		      /*     SOURCEX = off_table[char-first_ade]	     */
		      /*     SOURCEX is calculated for you in aline_text()   */
		      /*     The pointer to a table of font header for the   */
		      /*     internal fonts is returned in A2 on init (A000) */
   short  _SOURCEY;   /* 74  Y coodinate of character in the font form       */
		      /*     Typically set to 0 (top line of font form)	     */
   short  _DESTX;     /* 76  X coordinate of character on screen             */
   short  _DESTY;     /* 78  Y coordinate of character on screen             */
   short  _DELX;      /* 80  Width of Character				     */
		      /*     Difference between two SOURCEX's	             */
   short  _DELY;      /* 82  Height of Character                             */
		      /*     form_height field of FONT_HEAD of current font  */
   short  *_FBASE;    /* 84  Pointer to start of font form                   */
   short  _FWIDTH;    /* 88  Width of the current font's form                */
		      /*                                                     */
   short  _STYLE;     /* 90  Vector of style flags			     */
		      /*     Bit 0 = Thicken Flag			     */
		      /*     Bit 1 = Lighten Flag			     */
		      /*     Bit 2 = Skewing Flag			     */
		      /*     Bit 3 = Underline Flag (ignored)		     */
		      /*     Bit 4 = Outline Flag			     */
		      /*                                                     */
   short  _LITEMASK;  /* 92  Mask used for lightening text      	     */
		      /*     The Mask is picked up from the font header      */
   short  _SKEWMASK;  /* 94  Mask used for skewing text			     */
		      /*     The Mask is picked up from the font header      */
   short  _WEIGHT;    /* 96  The number of bits by which to thicken text     */
		      /*     The number is picked up from the font header    */
   short  _ROFF;      /* 98  Offset above baseline when skewing              */
                      /*     Again picked up from the font header            */
		      /*						     */
   short  _LOFF;      /* 100 Offset below character baseline when skewing    */
                      /*     Again picked up from the font header            */
		      /*                                                     */
   short  _SCALE;     /* 102 Scaling Flag 1 == true                          */
		      /*                                                     */
   short  _CHUP;      /* 104 Character rotation vector.                      */
   		      /*     0 = normal (0 degrees)			     */
		      /*     1800 = 180 degrees				     */
      		      /*     2700 = 270 degrees                              */
		      /*                                                     */
   short  _TEXTFG;    /* 106 Text foreground color			     */
		      /*                                                     */
   char  *_SCRTCHP;   /* 108 Address of buffer required for creating special */
		      /*     text effects. The size of this buffer should be */
		      /*     1K according the Internals. The Atari document  */
		      /*     of course does not talk about such things :-)   */
                      /*                                                     */
   short  _SCRPT2;    /* 112 The offset of the scaling buffer buffer in above*/
                      /*     buffer. Internals suggests an offset of 0x0040  */
                      /*     As usual the Atari document does'nt say a thing */
                      /*                                                     */
   short  _TEXTBG;    /* 114 Text background color (Ram Vdi only)            */
                      /*     used for the BitBlt writing modes (4-19) only   */
                      /*                                                     */
   short  _COPYTRAN;  /* 116 Copy raster form type flag (Ram vdi only)       */
                      /*     0 => Opaque type                                */
                      /*          n-plane source  ->  n-plane dest           */
                      /*              BitBlt writing modes (4-19)            */
                      /*    ~0 => Transparent type                           */
                      /*          1-plane source  ->  n-plane dest           */
                      /*              Vdi writing modes (1-3)                */
                      /*                                                     */
 short(*_SEEDABORT) (void);
		      /* 118 Pointer to function returning int, which is     */
                      /*     called by the fill logic to allow the fill to   */
                      /*     be aborted. If the routine returns FALSE (0)    */
                      /*     the fill is not aborted. If it returns TRUE (~0)*/
                      /*     the fill is aborted                             */
/* ------------------------------------------------------------------------- */

} __LINEA;            /*       P H E W !!!!!                                 */

/* macros for MWC compatibility */
#define	VPLANES		(__aline->_VPLANES)
#define	VWRAP		(__aline->_VWRAP)
#define	CONTRL		(__aline->_CONTRL)
#define	INTIN		(__aline->_INTIN)
#define	PTSIN		(__aline->_PTSIN)
#define	INTOUT		(__aline->_INTOUT)
#define	PTSOUT		(__aline->_PTSOUT)
#define	COLBIT0		(__aline->_COLBIT0)
#define	COLBIT1		(__aline->_COLBIT1)
#define	COLBIT2		(__aline->_COLBIT2)
#define	COLBIT3		(__aline->_COLBIT3)
#define	LSTLIN		(__aline->_LSTLIN)
#define	LNMASK		(__aline->_LNMASK)
#define	WMODE		(__aline->_WMODE)
#define	X1		(__aline->_X1)
#define	Y1		(__aline->_Y1)
#define	X2		(__aline->_X2)
#define	Y2		(__aline->_Y2)
#define	PATPTR		(__aline->_PATPTR)
#define	PATMSK		(__aline->_PATMSK)
#define	MFILL		(__aline->_MFILL)
#define	CLIP		(__aline->_CLIP)
#define	XMINCL		(__aline->_XMINCL)
#define	YMINCL		(__aline->_YMINCL)
#define	XMAXCL		(__aline->_XMAXCL)
#define	YMAXCL		(__aline->_YMAXCL)
#define	XDDA		(__aline->_XDDA)
#define	DDAINC		(__aline->_DDAINC)
#define	SCALDIR		(__aline->_SCALDIR)
#define	MONO		(__aline->_MONO)
#define	SOURCEX		(__aline->_SOURCEX)
#define	SOURCEY		(__aline->_SOURCEY)
#define	DESTX		(__aline->_DESTX)
#define	DESTY		(__aline->_DESTY)
#define	DELX		(__aline->_DELX)
#define	DELY		(__aline->_DELY)
#define	FBASE		(__aline->_FBASE)
#define	FWIDTH		(__aline->_FWIDTH)
#define	STYLE		(__aline->_STYLE)
#define	LITEMASK	(__aline->_LITEMASK)
#define	SKEWMASK	(__aline->_SKEWMASK)
#define	WEIGHT		(__aline->_WEIGHT)
#define	ROFF		(__aline->_ROFF)
#define	LOFF		(__aline->_LOFF)
#define	SCALE		(__aline->_SCALE)
#define	CHUP		(__aline->_CHUP)
#define	TEXTFG		(__aline->_TEXTFG)
#define	SCRTCHP		(__aline->_SCRTCHP)
#define	SCRPT2		(__aline->_SCRPT2)
#define	TEXTBG		(__aline->_TEXTBG)
#define	COPYTRAN	(__aline->_COPYTRAN)
#define	SEEDABORT	(__aline->_SEEDABORT)

	/* A pointer to array of type __FONT is returned by the Line A 
	 * init call ($A000), in register A1.
         * This pointer is saved in the global array variable 'fonts[]'.
	 *
	 */

typedef struct _font {

/* Type    Name       Offset   Function		    Comments		     */
/* ------------------------------------------------------------------------- */
   short  font_id;    /*  0 Font face identifier  1 == system font           */
                      /*                                                     */
   short  size;       /*  2 Font size in points                              */
                      /*                                                     */
   char   name[32];   /*  4 Face name                                        */
                      /*                                                     */
   short  first_ade;  /* 36 Lowest ADE value in the face (lowest ASCII value */
                      /*    of displayable character).                       */
                      /*                                                     */
   short  last_ade;   /* 38 Highest ADE value in the face (highest ASCII valu*/
                      /*    of displayable character).                       */
                      /*                                                     */
   short  top;        /* 40 Distance of top line relative to baseline        */
                      /*                                                     */
   short  ascent;     /* 42 Distance of ascent line relative to baseline     */
                      /*                                                     */
   short  half;       /* 44 Distance of half line relative to baseline       */
                      /*                                                     */
   short  descent;    /* 46 Distance of decent line relative to baseline     */
                      /*                                                     */
   short  bottom;     /* 48 Distance of bottom line relative to baseline     */
                      /*    All distances are measured in absolute values    */
                      /*    rather than as offsets. They are always +ve      */
                      /*                                                     */
short max_char_width; /* 50 Width of the widest character in font            */
                      /*                                                     */
short max_cell_width; /* 52 Width of the widest cell character cell in face  */
                      /*                                                     */
  short left_offset;  /* 54 Left Offset see Vdi appendix G                   */
                      /*                                                     */
  short right_offset; /* 56 Right offset   "      "     "                    */
                      /*                                                     */
   short  thicken;    /* 58 Number of pixels by which to thicken characters  */
                      /*                                                     */
   short  ul_size;    /* 60 Width in  pixels of the underline                */
                      /*                                                     */
   short  lighten;    /* 62 The mask used to lighten characters              */
                      /*                                                     */
   short  skew;       /* 64 The mask used to determine when to perform       */
                      /*    additional rotation on the character to perform  */
                      /*    skewing                                          */
                      /*                                                     */
   short  flags;      /* 66 Flags                                            */
                      /*      bit 0 set if default system font               */
                      /*      bit 1 set if horiz offset table should be used */
                      /*      bit 2 byte-swap flag (thanks to Intel idiots)  */
                      /*      bit 3 set if mono spaced font                  */
                      /*                                                     */
   char   *h_table;   /* 68 Pointer to horizontal offset table               */
                      /*                                                     */
   short  *off_table; /* 72 Pointer to character offset table                */
                      /*                                                     */
   char   *dat_table; /* 76 Pointer to font data                             */
                      /*                                                     */
   short  form_width; /* 80 Form width (#of bytes /scanline in font data)    */
                      /*                                                     */
   short  form_height;/* 82 Form height (#of scanlines in font data)         */
                      /*                                                     */
 struct _font *next_font;  /* 84 Pointer to next font in face                */
                      /*                                                     */
/* ------------------------------------------------------------------------- */
} __FONT;

	/* function pointer array
         * pointer to array is returned in A2 after a init (A000) call
	 * array contains pointers to the 16 lineA routines, allowing
	 * you to call the routines directly without incurring the
	 * overhead of processing a lineA exception. You must be in
	 * supervisor mode to call any of the routines directly
	 */
typedef short(*FPTR) (void);
typedef FPTR *FUNCPTR; /* array of pointers to functions returning short */
	
	/*
	 * OP_TAB type required for Bit Blt parameter block.
	 * each entry defines the logic operation to apply for
	 * the 4 Fore/Back ground bit combinations
	 */
typedef struct {

/* Type    Name       Offset   Function		    Comments		     */
/* ------------------------------------------------------------------------- */
   char   fg0bg0;     /* 0	Logic op to employ when both FG and BG are 0 */
   char   fg0bg1;     /* 1	Logic op to employ when FG = 0 and BG = 1    */
   char   fg1bg0;     /* 2	Logic op to employ when FG = 1 and BG = 0    */
   char   fg1bg1;     /* 3	Logic op to employ when both FG and BG are 1 */
/* ------------------------------------------------------------------------- */
} OP_TAB;


/*
 * Source and destination description blocks
 */
typedef struct  {
	short	bl_xmin;		/* Minimum x			*/
	short	bl_ymin;		/* Minimum y 			*/
	char	*bl_form;		/* short aligned memory form 	*/
	short	bl_nxwd;		/* Offset to next word in line  */
	short 	bl_nxln;		/* Offset to next line in plane */
	short 	bl_nxpl;		/* Offset to next plane 	*/
}SDDB;

	/* Offsets to next word in plane */
#define HI_NXWD		2		/* Hi Rez			*/
#define MED_NXWD	4
#define LOW_NXWD	8		/* lo Rez			*/

	/* Scan line widths of the screen */
#define HI_NXLN		80		/* Hi Rez			*/
#define MED_NXLN	160
#define LOW_NXLN	160		/* lo Rez			*/

	/*
	 * Offsets between planes - always the same due to
	 * the way the STs video memory is laid out
         */
#define NXPL		2

	/* 
	 * Bit Blt Parameter Block Type (for function $A007)
	 *
	 */

typedef struct {

/* Type    Name           Offset   Function		    Comments	     */
/* ------------------------------------------------------------------------- */
   short   bb_b_wd;     /*	 width of block in pixels 		     */
   short   bb_b_ht;     /*	 height of block in pixels		     */
   short   bb_plane_ct; /*	 number of planes to blit 		     */
   short   bb_fg_col;   /*	 foreground color 			     */
   short   bb_bg_col;   /*	 back	ground color 			     */
   OP_TAB  bb_op_tab;   /*	 logic for fg x bg combination 		     */
   SDDB	   bb_s;        /*	 source info block			     */
   SDDB	   bb_d;        /*	 destination info block 		     */
   short   *bb_p_addr;  /*	 pattern buffer address 		     */
   short   bb_p_nxln;   /*	 offset to next line in pattern 	     */
   short   bb_p_nxpl;   /*	 offset to next plane in pattern 	     */
   short   bb_p_mask;   /*	 pattern index mask 			     */
   char	   bb_fill[24];	/*	 work space				     */
/* ------------------------------------------------------------------------- */
} BBPB;


#ifndef __MFDB__
#define __MFDB__
/*
 * Memory Form Definition Block
 *
 */
typedef struct
{
	void		*fd_addr;    /* Address of upper left corner of first*/
                                     /* plane of raster area. If NULL then   */
                                     /* MFDB is for a physical device        */
	short		fd_w;	     /* Form Width in Pixels                 */
	short		fd_h;        /* Form Height in Pixels                */
	short		fd_wdwidth;  /* Form Width in shorts(fd_w/sizeof(int)*/
	short		fd_stand;    /* Form format 0= device spec 1=standard*/
	short		fd_nplanes;  /* Number of memory planes              */
	short		fd_r1;       /* Reserved                             */
	short		fd_r2;       /* Reserved                             */
	short		fd_r3;       /* Reserved                             */
} MFDB;
#endif /* __MFDB__ */

/*
 * Sprite definition block
 *
 */
typedef struct
{
	short	sp_xhot;		/* Offset to X hot spot		*/
	short	sp_yhot;		/* Offset to Y hot spot		*/
	short	sp_format;		/* Format SP_VDI or SP_XOR 	*/
	short	sp_bg;			/* Background color		*/
	short	sp_fg;			/* Foregroud color		*/
	short	sp_data[32];		/* Sprite data - 		*/
					/* Alternating words of back/fore */
					/* ground data			  */
					/* Note that:			  */
					/*   sprite save block is         */
					/*  10+VPLANES*64 bytes long	  */
} SFORM;



/*****************************************************************************\
*		                                                              *
*                             Global Variables				      *
*		                                                              *
\*****************************************************************************/

	/*
	 * Global Variables are defined in alglobal.c, extern every where else
	 *
	 */

	/* global vars */
/* Pointer to line a parameter block returned by init 	*/
extern __LINEA *__aline;

/* Array of pointers to the three system font  headers 
   returned by init (in register A1)	           	*/
extern __FONT  **__fonts;

/* Array of pointers to the 16 line a functions returned
   by init (in register A2) only valid in ROM'ed TOS     */
extern short  (**__funcs) (void);

	/* Functions */

extern void linea0 (void);
extern void linea1 (void);
extern int  linea2 (void);
extern void linea3 (void);
extern void linea4 (void);
extern void linea5 (void);
extern void linea6 (void);
extern void linea7 (BBPB *P);
extern void linea8 (void);
extern void linea9 (void);
extern void lineaa (void);
extern void lineab (void);
extern void lineac (void *P);
extern void linead (int x, int y, SFORM *sd, void *ss);
extern void lineae (void);
extern void lineaf (void);

__END_DECLS

#endif /* _MINT_LINEA_H */
