/********************************************
	file: button.c
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

#include <ctype.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "e:\proging\c\libs\malib\alert.h"
#include "button.h"
#include "cursor.h"
#include "dialog.h"
#include "edit.h"
#include "init.h"
#include "keys.h"
#include "menu.h"
#include "send.h"
#include "wind.h"

#include "bfed_rsc.h"

/********************************************
	defines
*********************************************/

/********************************************
	locals vars declarations & definitions
*********************************************/

/********************************************
	globals vars declarations
*********************************************/

/********************************************
	locals functions declarations
*********************************************/
static long calc_pos(int mousex, int mousey);

/********************************************
	globals functions definitions
*********************************************/
/*
	name: do_button
	utility: 
	comment: 
	parameters: 
		int mousex: x position of the mouse
		int mousey: y ...
	return: none
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
void do_button(int mousex, int mousey)
{	
	if (!thefrontwin->form)
	{
		int x,y;
		int status = LEFT_BUTTON;	/* mouse button state */
		int lastw = 0, lasth = 0;
		long newpos;	/* new position of the cursor */

		do
		{
			vq_mouse(thefrontwin->graf.handle, &status, &x, &y);
			if ( (abs(x-mousex)) > 6 || (abs(y-mousey)) > 6 )
				graf_rubberbox(mousex, mousey, 6, 6, &lastw, &lasth);
		} while(status == LEFT_BUTTON);

		newpos = calc_pos(mousex, mousey);
		if (newpos != -1L)	/* not outside window */
		{
			if (newpos == -2L)	/* try to go out file */
			{
				thefrontwin->position = thefrontwin->flen-1;
				check_scroll(thefrontwin);		
			}
			else
			{		/* if some byte selected by mouse */
				if (lastw > 7 || lasth > 7)
				{
					thefrontwin->startmark = newpos;
					newpos = calc_pos(x-3, y-3);
					if (newpos != -1L)
					{
						thefrontwin->endmark = 								\
								(newpos<thefrontwin->flen-1) ? 				\
									newpos : (thefrontwin->flen-2);
						thefrontwin->position = thefrontwin->endmark;
						if (thefrontwin->startmark <= thefrontwin->endmark) /* it must !! */
						{
							send_redraw(thefrontwin);
							thefrontwin->markson = TRUE;
							update_menu();
						}
						thefrontwin->position = newpos;
					}
				}
				else
					thefrontwin->position = newpos;				
			}
			window_info(thefrontwin);
		}
	}
	else		/* if someone as clicked in a form */
	{
		if (thefrontwin->form == dsearch)	/* Find dialog */
			dialog_search_exec();
		else if (thefrontwin->form == ddisk)
			dialog_disk_exec();
		else if (thefrontwin->form == dprint)
			dialog_print_exec();
		else if (thefrontwin->form == dpos)
			dialog_pos_exec();
	}
}

/********************************************
	locals functions definitions
*********************************************/
/*
	name: calc_pos
	utility: 
	comment: 
	parameters:
		int mousex: x position of the mouse
		int mousey: y ...
	return:
		long :
			position: position of the data in file
			-1L: outside window or hexa input not finished
			-2L: Try to move cursor outside file
	date: 1989
	author: Jim Charlton
	modifications:
		may 13 96: C. Moreau:	Go position only when clic in window
		nov 14 96: C. Moreau:	Make code much readable
										included NB_DATA_ON_LINE in code 
*/
static long calc_pos(int mousex, int mousey)
{
	const int	x = thefrontwin->work.g_x,  /* window sizes */
					y = thefrontwin->work.g_y,
					w = thefrontwin->work.g_w,
					h = thefrontwin->work.g_h;

	mousex -= 5;

		/* inside window */
	if ( 	(x <= mousex) || (mousex <= x + w)
		 	|| (y <= mousey) || (mousey <= y + h) )
	{
			/* mouse inside window  in ASCII part */
		if( (x + gl_wchar*3*NB_DATA_IN_LINE < mousex)
			 && (mousex < x + gl_wchar*4*NB_DATA_IN_LINE) )
		{
			const int xin = (mousex - x - gl_wchar * 3*NB_DATA_IN_LINE)/gl_wchar;

			mousex = x + xoffset[xin]*gl_wchar + 1;
			inhex = FALSE;
		}
		else /* in HEX part */
			inhex = TRUE;
	
		{	
			register int column=0;	/* column number in window */
			const int line = (mousey - y)/gl_hchar; /* line number in window */
			long pos;
	
			while ( xoffset[column]*gl_wchar < (mousex - x) )
				column++;
		
			pos = column + line*NB_DATA_IN_LINE + thefrontwin->topchar - 1;
		
			if (pos <= thefrontwin->flen-1)
			{
				if (thefrontwin->icount) /* don't allow cursor move til finish entry */
				{	
					Bconout(2,7);
					rsc_alert(ENTER_HEX);
					
					return -1L;				
				}
				else
					return pos;
			}
			else
				return -2L; /* trying to move cursor outside file !	*/				
		}
	}
	else	/* outside window */
		return -1L;
}
