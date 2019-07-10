#include <stdio.h>
#include <gemdefs.h>
#include <obdefs.h>
#include <osbind.h>

#include "globals.h"
#include "xxed.h"

long forward2();
long back2();
char *chk_sstr_len();
char *chk_rstr_len();

long rl,sl;  /* length of replace and search strings  */


find(thewin) /* handles search and replace dialog box  */
	windowptr	thewin;
{
	int	button;
	

	button = do_dialog(dialog1);
	dialog1[SFORWARD].ob_state = NORMAL;
	dialog1[SBACK].ob_state = NORMAL;
	dialog1[CANCEL1].ob_state = NORMAL;
	dialog1[RONCE].ob_state = NORMAL;
	dialog1[RALL].ob_state = NORMAL;
	dialog1[RVER].ob_state = NORMAL;


	return(button);
}

char *chk_sstr_len(thewin) /* check search string length */
	windowptr	thewin;
{
	char *sstr;
	int  button;

		if( (dialog1[SCUTBUF].ob_state == SELECTED) )
		{	sstr = cutbuffer;
			sl = cutlength;
		}
		else
		{	sstr = s_str;
			sl = strlen(sstr);
		}
			if ( (sstr == NULL) || (sl == 0) )
	{	button = form_alert(1, "[1][ Nul search string... | Aborting.   ][ OK ]");
		return(0);
	}
			else
		return(sstr);
}

char *chk_rstr_len(thewin)
	windowptr	thewin;
{
	char *rstr;
	int  button;

		if( (dialog1[RCUTBUF].ob_state == SELECTED) )
		{	rstr = cutbuffer;
			rl = cutlength;
		}
		else
		{	rstr = r_str;
			rl = strlen(rstr);
		}
			if ( (rstr == NULL) || (rl == 0) )
	{	button = form_alert(1, "[1][ Nul replace string... | Aborting.   ][ OK ]");
		return(0);
	}
			else
		return(rstr);
}

find0(thewin) /* handles results from srch/rpl dialog */
	windowptr	thewin;
{
	char *sstr, *rstr;
	int	button;
	long	pos;

		button = find(thewin);
		if (button == CANCEL1)
			return;
		if (!(sstr = chk_sstr_len(thewin)))
			return;

		switch (button)
		 	{
			case SFORWARD :	forward1(thewin,sstr);
							check_scroll(thewin);
							break;
			case SBACK :	back1(thewin,sstr);
							break;
			case RONCE :	if (!(rstr = chk_rstr_len(thewin)))
								break;
							ronce(thewin,sstr,rstr);
							repos(thewin);
							one_page(thewin,1);
							redraw_vslider(thewin->handle);
							break;
			case RALL :		if (!(rstr = chk_rstr_len(thewin)))
								break;
							rall(thewin,sstr,rstr);
							break;
			case RVER :		if (!(rstr = chk_rstr_len(thewin)))
								return;
							rver(thewin,sstr,rstr);
							break;
			default : 		;
			}		
}

forward1(thewin,sstr) /* searches forward */
	windowptr	thewin;
	char *sstr;
{
	long	pos;
	int	button;

	graf_mouse(2,0L);

	if(thewin->position < thewin->flen-2) thewin->position += 1;
	if( (pos=forward2(thewin,sstr)) > 0 )
	{	thewin->position = pos;
		graf_mouse(0,0L);
		return(-1);
	}
	else
	{	button = form_alert(1, "[1][ | | No (further) occurrences of | the string can be found. |  ][ OK ]");
		thewin->position -= 1;
		graf_mouse(0,0L);
		return(0);
	}
}

rp_forw(thewin,sstr) /* replace going forward */
	windowptr	thewin;
	char *sstr;
{
	long	pos;
	int	button;

	if( (pos=forward2(thewin,sstr)) > -1)
	{	thewin->position = pos;
		return(-1);
	}
	else
	{	one_page(thewin,1);
		redraw_vslider(thewin->handle);
		button = form_alert(1, "[1][ | | No (further) occurrences of | the string can be found. |  ][ OK ]");
		return(0);
	}
}


long forward2(thewin,sstr)
	windowptr	thewin;
	char *sstr;
{
	unsigned	num;
	int	j, strl;
	long i;

		strl = strlen(sstr);
		for (i=thewin->position;i<(thewin->flen-strl);i++)
		{	j=1;
			num = getbyte(thewin,i);
			if(num == sstr[0])
			{	while (j<strl)
				{	if( (num = getbyte(thewin,i+j)) == sstr[j])
						j+=1;
					else
						break;
				}
				if (j == strl)
					return(i);
			}
		}
		return(-1);
}

back1(thewin,sstr) /* search backwards */
	windowptr	thewin;
	char *sstr;
{
	long	pos;
	int	button;

	graf_mouse(2,0L);

		 thewin->position -= 1;
	if( (pos=back2(thewin,sstr)) > -1 )
	{	thewin->position = pos;
		check_scroll(thewin);
	}
	else
	{	button = form_alert(1, "[1][ | |   String not found.   ][ OK ]");
		thewin->position += 1;
	}
	graf_mouse(0,0L);
}

long back2(thewin,sstr)
	windowptr	thewin;
	char *sstr;
{
	unsigned	num;
	int	j, strl;
	long i;


		strl = strlen(sstr);
		for (i=thewin->position;i > -1;i--)
		{	j=1;
			num = getbyte(thewin,i);
			if(num == sstr[0])
			{	while (j<strl)
				{	if( (num = getbyte(thewin,i+j)) == sstr[j])
						j+=1;
					else
						break;
				}
				if (j == strl)
					return(i);
			}
		}
		return(-1);
}		

ronce(thewin,sstr,rstr) /* replace once */
	windowptr	thewin;
	char *sstr, *rstr;
{
	long rl;
	int sl, button, c;


	if((c = strcmp(sstr,rstr))==0)
	{	button = form_alert(1, "[1][ | Search and Replace strings | are identical.  Aborting...  |  ][ OK ]");
		return(0);
	}
	graf_mouse(2,0L);
	if(rp_forw(thewin,sstr))
	{	rl = strlen(rstr);
		sl = strlen(sstr);
		thewin->startmark = thewin->position;
		thewin->position += sl;
		thewin->endmark = thewin->position -1;
		thewin->markson = TRUE;
		cutit(thewin);
		thewin->changed = TRUE;
/* following code just clears the marks  */
			{	thewin->startmark = 1;
				thewin->endmark = 0;
				thewin->markson = FALSE;
			}
	
	/* insert_it() inserts rl bytes from string pointed to by rstr
   	into the file before the position of the cursor... see edit.c
	*/
		insert_it(thewin,rl,rstr);
		graf_mouse(0,0L);
		return(-1);
	}
	else
		graf_mouse(0,0L);
		return(0);
}	
	
rall(thewin,sstr,rstr) /* replace all */
	windowptr	thewin;
	char *sstr, *rstr;
{
	int c, button;

	if((c = strcmp(sstr,rstr))==0)
	{	button = form_alert(1, "[1][ | Search and Replace strings | are identical.  Aborting...  |  ][ OK ]");
		return(0);
	}
	one_page(thewin,1);
	while(ronce(thewin,sstr,rstr))
		thewin->position += rl;	
	thewin->position -= rl;
	jump_pos(thewin);
	send_redraw(thewin);
}
rver(thewin,sstr,rstr) /* replace with verify */
	windowptr	thewin;
	char *sstr, *rstr;
{
	int button, result, c;

	if((c = strcmp(sstr,rstr))==0)
	{	button = form_alert(1, "[1][ | Search and Replace strings | are identical.  Aborting...  |  ][ OK ]");
		return(0);
	}
	graf_mouse(2,0L);
	result = 1;	
	while(result)
	{	if(rp_forw(thewin,sstr))
		{	repos(thewin);
			one_page(thewin,1);
			redraw_vslider(thewin->handle);
				if(thewin = thefrontwin)
				{	graf_mouse(M_OFF, 0L);
					putcur(thewin);	/* cursor on	*/
					graf_mouse(M_ON, 0L);
				}
			graf_mouse(0,0L);
			button = do_dialxy(dialog3,100,100);
			graf_mouse(2,0L);
			dialog3[RPBUT].ob_state = NORMAL;
			dialog3[SKBUT].ob_state = NORMAL;
			dialog3[ABBUT].ob_state = NORMAL;
				if(thewin = thefrontwin)
				{	graf_mouse(M_OFF, 0L);
					putcur(thewin);	/* cursor off	*/
					graf_mouse(M_ON, 0L);
				}
		if(button == RPBUT)
			{	thewin->startmark = thewin->position;
				thewin->position += sl;
				thewin->endmark = thewin->position -1;
				thewin->markson = TRUE;
				cutit(thewin);
				thewin->changed = TRUE;
		/* following code just clears the marks  */
					{	thewin->startmark = 1;
						thewin->endmark = 0;
						thewin->markson = FALSE;
					}
			
			/* insert_it() inserts rl bytes from string pointed to by rstr
   			into the file before the position of the cursor... see edit.c
			*/
				insert_it(thewin,rl,rstr);
				thewin->position += rl;
				result = 1;
			}
			if(button == SKBUT)
				if(thewin->position < thewin->flen-2)
						thewin->position += 1;
			if(button == ABBUT)
				break;
		} /* end of if(rp_forw())  */
		else
		{	thewin->position -= rl;	
			result = 0;
		}
	}  send_redraw(thewin);
	graf_mouse(0,0L);
}
		

do_dialog(dialog)   /* draw dialog boxes   */
OBJECT *dialog;
{
	int	cx, cy, cw, ch, button;

	form_center(dialog, &cx, &cy, &cw, &ch);
	form_dial(FMD_START, 0, 0, 0, 0, cx, cy, cw, ch);
	objc_draw(dialog, 0, 10, cx, cy, cw, ch);
	button = form_do(dialog, 0);
	form_dial(FMD_FINISH, 0, 0, 0, 0, cx, cy, cw, ch);
	return(button);
}
do_dialxy(dialog,x,y) /* draw dialog at specific position with form_do */
OBJECT *dialog;
int x,y;
{
	int	cx, cy, cw, ch, button;

	dialog->ob_x = x;
	dialog->ob_y = y;
	cx = x;
	cy = y;
	cw = dialog->ob_width;
	ch = dialog->ob_height;

	form_dial(FMD_START, 0, 0, 0, 0, cx, cy, cw, ch);
	objc_draw(dialog, 0, 10, cx, cy, cw, ch);
	button = form_do(dialog, 0);
	form_dial(FMD_FINISH, 0, 0, 0, 0, cx, cy, cw, ch);
	return(button);
}

drw_dialxy(dialog,x,y) /* draw object at a position.. no form_do */
OBJECT *dialog;
int x,y;
{
	int	cx, cy, cw, ch;

	dialog->ob_x = x;
	dialog->ob_y = y;
	cx = x;
	cy = y;
	cw = dialog->ob_width;
	ch = dialog->ob_height;
	form_dial(FMD_START, 0, 0, 0, 0, cx, cy, cw, ch);
	objc_draw(dialog, 0, 10, cx, cy, cw, ch);
}
