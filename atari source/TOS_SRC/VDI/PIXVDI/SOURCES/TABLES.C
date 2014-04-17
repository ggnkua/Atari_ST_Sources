/*
*******************************  tables.c  ************************************
*
* $Revision: 3.1 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/tables.c,v $
* =============================================================================
* $Author: lozben $	$Date: 91/07/30 15:30:49 $     $Locker:  $
* =============================================================================
*
* $Log:	tables.c,v $
* Revision 3.1  91/07/30  15:30:49  lozben
* Added table markhead[].
* 
* Revision 3.0  91/01/03  15:19:12  lozben
* New generation VDI
* 
* Revision 2.7  90/04/03  13:50:05  lozben
* The rom_inq_tab now has BLTPRFRM define in the table. It is a define for the
* blit performance. It used to be just hardwired to a 1000.
* 
* Revision 2.6  90/03/09  18:24:48  lozben
* Added to plane_mask[], so it can mask up to 8 planes.
* 
* Revision 2.5  89/08/18  15:05:00  lozben
* Adjusted some of the mappings.
* 
* Revision 2.4  89/08/17  15:54:10  lozben
* Changed ROM_MAP_COL[] and ROM_REV_MAP_COL[] back to MAP_COL[] and
* REV_MAP_COL[]. Also changed these tables back to word tables and
* adjusted some of the mappings.
* 
* Revision 2.3  89/07/28  21:23:39  lozben
* Changed MAP_COL[] and REV_MAP_COL[] into rom tables and increased them
* to 256. (these are byte tables - alcyon has no provision for unsigned char;
* keep that in mind.).
* 
* Revision 2.2  89/04/14  15:25:36  lozben
* Changed constants for number of colors to choose from (512) to a
* define MAX_PAL.
* 
* Revision 2.1  89/02/21  17:28:19  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
*******************************************************************************
*/
/************************************************************/
/*                                                          */
/*              DEV, SIZ, INQ tables converted to 'c'       */
/*                                                          */
/************************************************************/

#include "portab.h"
#include "gsxdef.h"
#include "styles.h"

WORD plane_mask[] = {0,   1,   3,   7,  15,  31,  63, 127, 255,
			255, 255, 255, 255, 255, 255, 255, 255,
			255, 255, 255, 255, 255, 255, 255, 255,
			255, 255, 255, 255, 255, 255, 255, 255
		    };

WORD ROM_DEV_TAB[45] = {
  	319,	/* 0	x resolution			     */
  	199,	/* 1	y resolution			     */
  	0,	/* 2	device precision 0=exact,1=not exact */
  	338,	/* 3	width of pixel			     */
  	372,	/* 4	heigth of pixel			     */
  	1,	/* 5	character sizes			     */
   MX_LN_STYLE,	/* 6	linestyles		       	     */
	0,	/* 7	linewidth			     */
  	6,	/* 8	marker types			     */
  	8,	/* 9	marker size			     */
  	1,	/* 10	text font			     */
MX_FIL_PAT_INDEX,/* 11	area patterns			     */
MX_FIL_HAT_INDEX,/* 12	crosshatch patterns		     */
  	16,	/* 13	colors at one time		     */
  	10,	/* 14	number of GDP's			     */
  	1,	/* 15	GDP bar				     */
  	2,	/* 16	GDP arc				     */
  	3,	/* 17	GDP pic				     */
  	4,	/* 18	GDP circle			     */
  	5,	/* 19	GDP ellipse			     */
  	6,	/* 20	GDP elliptical arc		     */
  	7,	/* 21	GDP elliptical pie		     */
  	8,	/* 22	GDP rounded rectangle		     */
  	9,	/* 23	GDP filled rounded rectangle	     */
  	10,	/* 24	GDP #justified text		     */
  	3,	/* 25	GDP #1				     */
  	0,	/* 26	GDP #2				     */
  	3,	/* 27	GDP #3				     */
  	3,	/* 28	GDP #4				     */
  	3,	/* 29	GDP #5				     */
  	0,	/* 30	GDP #6				     */
  	3,	/* 31	GDP #7				     */
  	0,	/* 32	GDP #8				     */
  	3,	/* 33	GDP #9				     */
  	2,	/* 34	GDP #10				     */
  	1,	/* 35	Color capability		     */
  	1,	/* 36	Text Rotation			     */
  	1,	/* 37	Polygonfill			     */		
  	0,	/* 38	Cell Array			     */
	MAX_PAL,/* 39	Pallette size			     */
  	2,	/* 40	# of locator devices 1 = mouse       */
  	1,	/* 41	# of valuator devices		     */
  	1,	/* 42	# of choice devices		     */
  	1,	/* 43	# of string devices		     */
  	2	/* 44	Workstation Type 2 = out/in	     */
};

/************************************************************/ 
/* size_table                                               */
/* returns text,line and marker sizes in device coordinates */
/************************************************************/

WORD  ROM_SIZ_TAB[12] = {
  	0,	/* 0	min char width			*/
  	7,	/* 1	min char height			*/
  	0,	/* 2	max char width			*/
  	7,	/* 3	max char height			*/
  	1,	/* 4	min line width			*/
  	0,	/* 5	reserved 0			*/
   MX_LN_WIDTH,	/* 6	max line width			*/
  	0,	/* 7	reserved 0			*/
  	15,	/* 8	min marker width		*/
  	11,	/* 9	min marker height		*/
  	120,	/* 10	max marker width		*/
  	88	/* 11	max marker height		*/
};

WORD  ROM_INQ_TAB[45] = {
  	4,		/*  0  type of alpha/graphic controllers*/
  	MAX_PAL,	/*  1  number of background colors	*/
  	0x1F,		/*  2  text styles supported		*/
  	0,		/*  3  scale rasters = false		*/
  	4,		/*  4  number of planes			*/
  	1,		/*  5  video lookup table		*/
  	BLTPRFRM,	/*  6  performance factor????		*/
  	1,		/*  7  contour fill capability		*/
  	1,		/*  8  character rotation capability    */
  	4,		/*  9  number of writing modes		*/
  	2,		/*  10 highest input mode		*/
  	1,		/*  11 text alignment flag		*/
  	0,		/*  12 Inking capability		*/
  	0,		/*  13 rubber banding			*/
  	MAX_VERT,	/*  14 maximum vertices			*/
  	-1,		/*  15 maximum intin			*/
  	2,		/*  16 number of buttons on MOUSE	*/
  	0,		/*  17 styles for wide lines            */
	0,		/*  18 writing modes for wide lines     */
	0,		/*  19 filled in with clipping flag     */
	0,0,0,0,0,
  	0,0,0,0,0,0,0,0,
  	0,0,0,0,0,0,0,0,
  	0,0,0,0
};

/**********************************************************/
/*                                                        */
/* Marker definitions.                                    */
/*                                                        */
/**********************************************************/

WORD	m_dot[] = { 1, 2, 0, 0, 0, 0 };

WORD	m_plus[] = { 2, 2, 0, -3, 0, 3, 2,-4, 0, 4, 0 };

WORD	m_star[] = { 3, 2, 0, -3, 0, 3, 2, 3, 2, -3, -2, 2, 3, -2, -3, 2};

WORD	m_square[] = { 1, 5, -4, -3, 4, -3, 4, 3, -4, 3, -4, -3 };

WORD	m_cross[] = { 2, 2, -4, -3, 4, 3, 2, -4, 3, 4, -3 };

WORD	m_dmnd[] = { 1, 5, -4, 0, 0, -3, 4, 0, 0, 3, -4, 0 };

WORD    *markhead[] = { m_dot, m_plus, m_star, m_square, m_cross, m_dmnd };

WORD MAP_COL[] = {
	0, 255,   1,   2,   4,   6,   3,   5,   7,   8,
	9,  10,  12,  14,  11,  13,  16,  17,  18,  19,
       20,  21,  22,  23,  24,  25,  26,  27,  28,  29,
       30,  31,  32,  33,  34,  35,  36,  37,  38,  39,
       40,  41,  42,  43,  44,  45,  46,  47,  48,  49,
       50,  51,  52,  53,  54,  55,  56,  57,  58,  59,
       60,  61,  62,  63,  64,  65,  66,  67,  68,  69,
       70,  71,  72,  73,  74,  75,  76,  77,  78,  79,
       80,  81,  82,  83,  84,  85,  86,  87,  88,  89,
       90,  91,  92,  93,  94,  95,  96,  97,  98,  99,
      100, 101, 102, 103, 104, 105, 106, 107, 108, 109,
      110, 111, 112, 113, 114, 115, 116, 117, 118, 119,
      120, 121, 122, 123, 124, 125, 126, 127, 128, 129,
      130, 131, 132, 133, 134, 135, 136, 137, 138, 139,
      140, 141, 142, 143, 144, 145, 146, 147, 148, 149,
      150, 151, 152, 153, 154, 155, 156, 157, 158, 159,
      160, 161, 162, 163, 164, 165, 166, 167, 168, 169,
      170, 171, 172, 173, 174, 175, 176, 177, 178, 179,
      180, 181, 182, 183, 184, 185, 186, 187, 188, 189,
      190, 191, 192, 193, 194, 195, 196, 197, 198, 199,
      200, 201, 202, 203, 204, 205, 206, 207, 208, 209,
      210, 211, 212, 213, 214, 215, 216, 217, 218, 219,
      220, 221, 222, 223, 224, 225, 226, 227, 228, 229,
      230, 231, 232, 233, 234, 235, 236, 237, 238, 239,
      240, 241, 242, 243, 244, 245, 246, 247, 248, 249,
      250, 251, 252, 253, 254,  15
};

WORD REV_MAP_COL[] = {
        0,   2,   3,   6,   4,   7,   5,   8,   9,  10,
       11,  14,  12,  15,  13, 255,  16,  17,  18,  19,
       20,  21,  22,  23,  24,  25,  26,  27,  28,  29,
       30,  31,  32,  33,  34,  35,  36,  37,  38,  39,
       40,  41,  42,  43,  44,  45,  46,  47,  48,  49,
       50,  51,  52,  53,  54,  55,  56,  57,  58,  59,
       60,  61,  62,  63,  64,  65,  66,  67,  68,  69,
       70,  71,  72,  73,  74,  75,  76,  77,  78,  79,
       80,  81,  82,  83,  84,  85,  86,  87,  88,  89,
       90,  91,  92,  93,  94,  95,  96,  97,  98,  99,
      100, 101, 102, 103, 104, 105, 106, 107, 108, 109,
      110, 111, 112, 113, 114, 115, 116, 117, 118, 119,
      120, 121, 122, 123, 124, 125, 126, 127, 128, 129,
      130, 131, 132, 133, 134, 135, 136, 137, 138, 139,
      140, 141, 142, 143, 144, 145, 146, 147, 148, 149,
      150, 151, 152, 153, 154, 155, 156, 157, 158, 159,
      160, 161, 162, 163, 164, 165, 166, 167, 168, 169,
      170, 171, 172, 173, 174, 175, 176, 177, 178, 179,
      180, 181, 182, 183, 184, 185, 186, 187, 188, 189,
      190, 191, 192, 193, 194, 195, 196, 197, 198, 199,
      200, 201, 202, 203, 204, 205, 206, 207, 208, 209,
      210, 211, 212, 213, 214, 215, 216, 217, 218, 219,
      220, 221, 222, 223, 224, 225, 226, 227, 228, 229,
      230, 231, 232, 233, 234, 235, 236, 237, 238, 239,
      240, 241, 242, 243, 244, 245, 246, 247, 248, 249,
      250, 251, 252, 253, 254,   1
};
