/************************************************************/
/*                                                          */
/*              DEV, SIZ, INQ tables converted to 'c'       */
/*                                                          */
/************************************************************/

#include "portab.h"
#include "gsxdef.h"
#include "styles.h"

WORD plane_mask[4] = {1, 3, 7, 15};

WORD DEV_TAB[45] = {
  	719,	/* 0	x resolution			     */
  	363,	/* 1	y resolution			     */
  	0,	/* 2	device precision 0=exact,1=not exact */
  	305,	/* 3	width of pixel			     */
  	415,	/* 4	heigth of pixel			     */
  	1,	/* 5	character sizes			     */
   MX_LN_STYLE,	/* 6	linestyles		       	     */
	0,	/* 7	linewidth			     */
  	6,	/* 8	marker types			     */
  	8,	/* 9	marker size			     */
  	1,	/* 10	text font			     */
MX_FIL_PAT_INDEX,/* 11	area patterns			     */
MX_FIL_HAT_INDEX,/* 12	crosshatch patterns		     */
  	2,	/* 13	colors at one time		     */
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
  	0,	/* 35	Color capability		     */
  	1,	/* 36	Text Rotation			     */
  	1,	/* 37	Polygonfill			     */		
  	0,	/* 38	Cell Array			     */
	2,	/* 39	Pallette size			     */
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

WORD  SIZ_TAB[12] = {
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
  	88,	/* 11	max marker height		*/
};

WORD  INQ_TAB[45] = {
  	1,		/*  0  type of alpha/graphic controllers*/
  	1,		/*  1  number of background colors	*/
  	0x1F,		/*  2  text styles supported		*/
  	0,		/*  3  scale rasters = false		*/
  	1,		/*  4  number of planes			*/
  	0,		/*  5  video lookup table		*/
  	50,		/*  6  performance factor????		*/
  	1,		/*  7  contour fill capability		*/
  	1,		/*  8  character rotation capability    */
  	4,		/*  9  number of writing modes		*/
  	2,		/*  10 highest input mode		*/
  	1,		/*  11 text alignment flag		*/
  	0,		/*  12 Inking capability		*/
  	0,		/*  13 rubber banding			*/
  	128,		/*  14 maximum vertices	- must agree with entry.s*/
  	-1,		/*  15 maximum intin			*/
  	1,		/*  16 number of buttons on MOUSE	*/
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

WORD	m_star[] = { 3, 2, 0, -3, 0, 3, 2, 3, 
		     2, -3, -2, 2, 3, -2, -3, 2};

WORD	m_square[] = { 1, 5, -4, -3, 4, -3, 4, 3, -4, 3, -4, -3 };

WORD	m_cross[] = { 2, 2, -4, -3, 4, 3, 2, -4, 3, 4, -3 };

WORD	m_dmnd[] = { 1, 5, -4, 0, 0, -3, 4, 0, 0, 3, -4, 0 };

WORD MAP_COL[MAX_COLOR] = {0, 15, 1, 2, 4, 6, 3, 5, 7, 8, 9, 10, 12, 14, 11, 13};

WORD REV_MAP_COL[MAX_COLOR] = {0, 2, 3, 6, 4, 7, 5, 8, 9, 10, 11, 14, 12, 15, 13, 1};
