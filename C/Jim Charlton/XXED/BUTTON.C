#include "xxed.h"
#include <gemdefs.h>
#include <obdefs.h>
#include <osbind.h>

#include "globals.h"


do_button(mousex,mousey)
	int	mousex,mousey;
{	
	windowptr	thewin;
	int	x,y,x2,y2,status,lastw,lasth;
	long oldpos, newpos;


/* WARNING  There are multiple 'returns' in this function  */
	
	thewin = thefrontwin;
	status = 1;
	lasth=lastw=0;
	oldpos = thewin->position;
	while(status==1)
	{	vq_mouse(thewin->graf.handle,&status,&x,&y);
		if ((abs(x-mousex))>6 || ((abs(y-mousey))>6))
			graf_rubberbox(mousex,mousey,6,6,&lastw,&lasth);
	}
	if(lastw>7 || lasth>7)
	{

		newpos = calc_pos(mousex,mousey);
		if(newpos == -1L) return;
		if(newpos == -2L)
		{	thewin->position = thewin->flen-1;
			return;				
		}
		thewin->startmark = newpos;
		newpos = calc_pos(x-3,y-3);
		if(newpos == -1) return;
		thewin->endmark = newpos<thewin->flen-1 ?
							newpos : thewin->flen-2;
		thewin->position = thewin->endmark;
		if(thewin->startmark <= thewin->endmark) /* it must !! */
		{	send_redraw(thewin);
			thewin->markson = TRUE;
			menubar[CUT].ob_state = NORMAL;
			menubar[COPY].ob_state = NORMAL;
			menubar[ERASE].ob_state = NORMAL;
		}
	}
	else 
	{	newpos = calc_pos(mousex,mousey);
		if(newpos == -1) return;
		if(newpos == -2L)
		{	thewin->position = thewin->flen-1;
			return;				
		}
	}
	thewin->position = newpos;
}
			

long calc_pos(mousex,mousey)
	int	mousex,mousey;
{
	int x,y,w,h,i;
	windowptr	thewin;
	long	pos;
	int button, xin;

		thewin = thefrontwin;  /* move cursor around in frontwin */
		x = thewin->work.g_x;
		y = thewin->work.g_y;
		w = thewin->work.g_w;
		h = thewin->work.g_h;
		mousex -= 5;

		if(mousex > x + w) mousex = x + w - gl_wchar;
		if(mousex > (x + gl_wchar * 48) && mousex < (x + gl_wchar * 64))
			{	xin = (mousex - x - gl_wchar*48)/gl_wchar;
				mousex = x + xoffset[xin]*gl_wchar+1;
				inhex = FALSE;
				wr_ins_rpl(ins);
					/* go to ascii input	*/
			}
		else
			{	inhex = TRUE;
				wr_ins_rpl(ins);		/* hex input	*/
			}
		if(mousex < x) mousex = x + gl_wchar/2;
		if(mousex > (x + gl_wchar * 48)) mousex = x + gl_wchar * 48;
		if(mousey < y) mousey = y + gl_wchar/2;
		if(mousey > y + h) mousey = y + h - gl_wchar/2;
			{	for (i=0;xoffset[i]*gl_wchar < (mousex-x);i++);
				pos = 16*((mousey-y)/gl_hchar) + 
								i + thewin->topchar - 1;
			}

	if(pos>thewin->flen-1)
		{
	return(-2L); /* trying to move cursor outside file !   */				
		}
	if(thewin->icount!=0) /* don't allow cursor move til finish entry*/
		{	
	Bconout(2,7);
	button = form_alert(1, "[1][ | | Enter a HEX digit or Backspace ][ OK ]");				
	return(-1L);				
		}
			pos = pos < (thewin->flen-1) ? pos : (thewin->flen-1) ;

			return pos;
}


