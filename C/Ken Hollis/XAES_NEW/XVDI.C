/********************************************************************
 *																0.90*
 *	XAES: Extended Video Display Interface routines					*
 *	by Ken Hollis													*
 *																	*
 *	Copyright (c) 1994, Bitgate Software.  All Rights Reserved.		*
 *																	*
 *	These are the extended VDI routines.  They also make it so that	*
 *	most commonly called routines are used with one call.  The KISS	*
 *	method works unbelievably well.									*
 *																	*
 ********************************************************************/

#include "xaes.h"

XVDIVARS SaveHandles;

GLOBAL void line(int x1, int y1, int x2, int y2)
{
	int pxyarray[4];

	pxyarray[0] = x1;
	pxyarray[1] = y1;
	pxyarray[2] = x2;
	pxyarray[3] = y2;

	v_pline(VDIhandle, 2, pxyarray);
}

GLOBAL void point(int x, int y, int color)
{
	int pxyarray[2];

	pxyarray[0] = x;
	pxyarray[1] = y;

	vsm_color(VDIhandle, color);
	v_pmarker(VDIhandle, 1, pxyarray);
}

GLOBAL void box(int x, int y, int w, int h, int color)
{
	int pxyarray[10];

	pxyarray[2] = pxyarray[4] = (pxyarray[0] = pxyarray[6] = pxyarray[8] = x) + w;
	pxyarray[5] = pxyarray[7] = (pxyarray[1] = pxyarray[3] = pxyarray[9] = y) + h;

	vsl_color(VDIhandle, color);
	v_pline(VDIhandle, 5, pxyarray);
}

GLOBAL void box_fill(int x, int y, int w, int h, int color)
{
	int pxyarray[4];

	pxyarray[2] = (pxyarray[0] = x) + w;
	pxyarray[3] = (pxyarray[1] = y) + h;

/*	vsf_interior(VDIhandle, 1); */
	vsf_color(VDIhandle, color);
	vsl_color(VDIhandle, color);
	v_bar(VDIhandle, pxyarray);
}

GLOBAL void fillarea(int x1, int y1, int x2, int y2, int interior, int color)
{
	int pxyarray[4];

	pxyarray[0] = x1;
	pxyarray[1] = y1;
	pxyarray[2] = x2;
	pxyarray[3] = y2;

	vsf_interior(VDIhandle, interior);
	vsf_color(VDIhandle, color);

	v_fillarea(VDIhandle, 2, pxyarray);
}

GLOBAL void fill(int x, int y, int color)
{
	vsf_interior(VDIhandle, 1);
	vsf_color(VDIhandle, color);

	v_contourfill(VDIhandle, x, y, color);
}

GLOBAL void XVDI_SaveHandles(void)
{
	int i;

	vqt_attributes(VDIhandle, SaveHandles.textattributes);
	vqf_attributes(VDIhandle, SaveHandles.fillattributes);
	vql_attributes(VDIhandle, SaveHandles.lineattributes);

	vswr_mode(VDIhandle, MD_REPLACE);

	vst_color(VDIhandle, BLACK);
	vst_rotation(VDIhandle, 0);
	vst_height(VDIhandle, 6, &i, &i, &i, &i);
	vst_effects(VDIhandle, 0);

	vsf_interior(VDIhandle, FIS_SOLID);
	vsf_color(VDIhandle, BLACK);
	vsf_style(VDIhandle, 7);
	vsf_perimeter(VDIhandle, 0);

	vsl_type(VDIhandle, 1);
	vsl_color(VDIhandle, BLACK);
	vsl_width(VDIhandle, 1);
}

GLOBAL void XVDI_RestoreHandles(void)
{
	int	i;

	vst_color(VDIhandle, SaveHandles.textattributes[1]);
	vst_rotation(VDIhandle, SaveHandles.textattributes[2]);
	vst_alignment(VDIhandle, SaveHandles.textattributes[3], SaveHandles.textattributes[4], &i, &i);
	vst_effects(VDIhandle, 0);

/* Why they save the writing mode three times I may never know, but
   they do.  Use the text attributes, since it's text we're using
   for the drawing mode.  If not, change the writing mode in your
   own routine. */

	vswr_mode(VDIhandle, SaveHandles.textattributes[5]);
/*	vswr_mode(VDIhandle, SaveHandles.fillattributes[3]); */
/*	vswr_mode(VDIhandle, SaveHandles.lineattributes[2]); */

	vst_height(VDIhandle, SaveHandles.textattributes[7], &i, &i, &i, &i);

	vsf_interior(VDIhandle, SaveHandles.fillattributes[0]);
	vsf_color(VDIhandle, SaveHandles.fillattributes[1]);
	vsf_style(VDIhandle, SaveHandles.fillattributes[2]);
	vsf_perimeter(VDIhandle, SaveHandles.fillattributes[4]);

	vsl_type(VDIhandle, SaveHandles.lineattributes[0]);
	vsl_color(VDIhandle, SaveHandles.lineattributes[1]);
	vsl_width(VDIhandle, SaveHandles.lineattributes[5]);
}

GLOBAL void XVDI_RestoreForGEM(void)
{
	int	i;

	vst_color(VDIhandle, BLACK);
	vst_rotation(VDIhandle, 0);
	vst_effects(VDIhandle, 0);

	vswr_mode(VDIhandle, MD_REPLACE);
	vst_height(VDIhandle, 6, &i, &i, &i, &i);

	vsf_interior(VDIhandle, FIS_HOLLOW);
	vsf_color(VDIhandle, WHITE);
	vsl_udsty(VDIhandle,0x5555);
	vsl_type(VDIhandle,1);
	vsf_perimeter(VDIhandle, 1);

	vsl_color(VDIhandle, BLACK);
	vsl_width(VDIhandle, 1);
}