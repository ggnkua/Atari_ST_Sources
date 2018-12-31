/********************************************
	file: cursor.c
	utility:
	date: 1989
	author: Jim Charlton
	modifications:
		1996: C. Moreau: 
	comments: 
*********************************************/

/********************************************
	includes
*********************************************/
#ifdef __PUREC__ 
#include <aes.h>
#include <tos.h>
#include <vdi.h>
#include <compend.h>
#else
#include <aesbind.h>
#include <osbind.h>
#include <vdibind.h>
#endif

#include <stdio.h>

#include "button.h"
#include "cursor.h"
#include "init.h"
#include "wind.h"

/********************************************
	defines
*********************************************/

/********************************************
	locals vars declarations & definitions
*********************************************/

/********************************************
	globals vars declarations
*********************************************/
	/* offset in char for data in window */
int	xoffset[33]={	0,2,6,8,12,14,18,20,24,26,			\
					30,32,36,38,42,44,48,50,54,56,			\
					60,62,66,68,72,74,78,80,84,86,90,92,96};

/********************************************
	locals functions declarations
*********************************************/
void draw_cursors(void);

/********************************************
	globals functions definitions
*********************************************/
/*
	name: putcur
	utility: put a black box on current character
	comment: 
	parameters: none
	return: none
	date: 1989
	author: Jim Charlton
	modifications:
		1996: C. Moreau: Added NB_DATA_IN_LINE if more data wanted on a line
*/
void putcur(void)
{ 
	if(thefrontwin && !thefrontwin->form) /*  cursor action for frontwin only */
	{
			/* no of lines can put in window  */
		const long winlines = thefrontwin->work.g_h/gl_hchar;
			/* position of the 1 first data of window in file */
		const long bottomchar = thefrontwin->topchar + (winlines * NB_DATA_IN_LINE) - 1;
	
			/* don't try to draw cursor unless on page */
		if( (thefrontwin->position >= thefrontwin->topchar) &&
				(thefrontwin->position <= bottomchar) ) 
		{
			int	x,y,w,h;		/* window sizes */
			wind_get(thefrontwin->handle, WF_WORKXYWH, &x, &y, &w, &h);
			
			graf_mouse(M_OFF, 0L);

				/* set the clipping rectangle in case it was not set	 */
			pxyarray[0] = x;
			pxyarray[1] = y;
			pxyarray[2] = x + w - 1;
			pxyarray[3] = y + h - 1;
			vs_clip(thefrontwin->graf.handle, CLIP_ON, pxyarray);
	
			vswr_mode(thefrontwin->graf.handle, MD_XOR);

			draw_cursors();

			vswr_mode(thefrontwin->graf.handle, MD_REPLACE);

				/* unset the clipping rectangle	 */
			vs_clip(thefrontwin->graf.handle, CLIP_OFF, pxyarray);

			graf_mouse(M_ON, 0L);
		}
	}
}

/********************************************
	locals functions definitions
*********************************************/

/*
	name: draw_cursors
	utility: draw cursors in window
	comment: inpired of XXed code
	parameters:
	return:
	date: 14 dec 96
	author: C. Moreau
	modifications:
*/
void draw_cursors(void)
{
		/* position of data in window */
	const int pos = (int)(thefrontwin->position - thefrontwin->topchar);
		/* column position number in window */
	const int column = pos % NB_DATA_IN_LINE;
		/* line position number in window */
	const int line = pos / NB_DATA_IN_LINE;

	thefrontwin->xcur = thefrontwin->work.g_x + (xoffset[column]+1)*gl_wchar - 1;
	thefrontwin->ycur = thefrontwin->work.g_y + line*gl_hchar + 1;

		/* cursor un HEXA part */
	pxyarray[0] = thefrontwin->xcur;
	pxyarray[1] = thefrontwin->ycur;
	pxyarray[2] = thefrontwin->xcur + HEX_DATA_WSIZE*gl_wchar - 1;
	pxyarray[3] = thefrontwin->ycur + gl_hchar - 1;
	v_bar(thefrontwin->graf.handle, pxyarray);

		/* cursor in ASCII part */
	pxyarray[0] = thefrontwin->work.g_x + (ASCII_DATA_OFFSET+column+1)*gl_wchar - 1;
/*	pxyarray[1] = thefrontwin->ycur; */
	pxyarray[2] = pxyarray[0] + ASCII_DATA_WSIZE*gl_wchar - 1;
/*	pxyarray[3] = thefrontwin->ycur + gl_hchar - 1; */
	v_bar(thefrontwin->graf.handle, pxyarray);
}
