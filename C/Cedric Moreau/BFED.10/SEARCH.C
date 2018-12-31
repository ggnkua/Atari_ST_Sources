/*
	file: search.c
	utility: 
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
	comments: 
*/
#include <stdio.h>
#include <string.h>

#ifdef __PUREC__ 
#include <aes.h>
#include <compend.h>
#else
#include <aesbind.h>
#endif

#include "e:\proging\c\libs\malib\alert.h"
#include "bufman.h"
#include "cursor.h"
#include "dialog.h"
#include "edit.h"
#include "keys.h"
#include "onepage.h"
#include "search.h"
#include "send.h"
#include "slider.h"
#include "wind.h"

#include "bfed_rsc.h"

/*
	locales vars
*/
char	s_str[MAX_SEARCH];
char	r_str[MAX_SEARCH];
long	sstrlen = 0;
long	rstrlen = 0;

/*
	locals variables
*/
static long rl, sl;  /* length of replace and search strings  */

/*
	locals functions
*/
static char *chk_rstr_len(void);
static long forward2(windowptr	thewin,char *sstr);
static long back2(windowptr	thewin,char *sstr);
static int rp_forw(windowptr	thewin,char *sstr);
static int ronce(windowptr	thewin,char *sstr, char *rstr);
static void rall(windowptr	thewin,char *sstr, char *rstr);
static void rver(windowptr	thewin,char *sstr, char *rstr);

/*
	name: chk_sstr_len
	utility: check search string length
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
char *chk_sstr_len(void)
{
	char *sstr;
	
	if(dsearch[SCUTBUF].ob_state == SELECTED)
	{
		sstr = cutbuffer;
		sstrlen = cutlength;
	}
	else
	{
		sstr = s_str;
		sstrlen = strlen(sstr);
	}
	
	if ( !sstr || !sstrlen )
	{
		rsc_alert(SEARCH_NULL);
		return NULL; 
	}
	else
		return sstr;
}

/*
	name: chk_rstr_len
	utility: 
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
static char *chk_rstr_len(void)
{
	char *rstr;
	
	if (dsearch[RCUTBUF].ob_state == SELECTED)
	{
		rstr = cutbuffer;
		rstrlen = cutlength;
	}
	else
	{
		rstr = r_str;
		rstrlen = strlen(rstr);
	}
	
	if ( !rstr || !rstrlen )
	{
		rsc_alert(REPL_NULL);
		return NULL;
	}
	else
		return rstr;
}

/*
	name: find0
	utility: handles results from srch/rpl dialog
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
void find0(int button)
{
	char *sstr;

		/* if there is a string to process */
	if ( (sstr=chk_sstr_len()) != NULL )
	{
		windowptr thewin = firstwindow;	/*** find the window to work ***/

		switch (button)
		{
			case SBUT:	/* click on search button */
				if (dsearch[SFORWARD].ob_state == SELECTED)
				{
					forward1(thewin,sstr);
					check_scroll(thewin);
				}
				else /* SBACK selected */
				{
					back1(thewin,sstr);
				}
				break;
			case RBUT: /* click on replace button */
				{
					char *rstr=NULL;
	
					if ( (rstr=chk_rstr_len()) != NULL )
					{
						if ( (dsearch[RALL].ob_state != SELECTED) )
						{
							ronce(thewin,sstr,rstr);	/* Replace Once */
							repos(thewin);
 							send_redraw(thefrontwin);
/*							one_page(thefrontwin);
							redraw_vslider(thewin->handle);
*/						}
						else if (dsearch[RVER].ob_state != SELECTED)
						{	
							rall(thewin,sstr,rstr);	/* Replace All */
						}
						else 	/* RALL & RVER selected */
						{
							rver(thewin,sstr,rstr);	/* Replace All & Verify */
						}
					}
				}
			case NBUT: /* Clic on next button */
				break;
		}
	}		
}

/*
	name: forward1
	utility: searches forward
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
int forward1(windowptr thewin, char *sstr)
{
	long	pos;

	graf_mouse(BUSYBEE,0L);
	if (thewin->position < thewin->flen-2)
		thewin->position++;

	pos = forward2(thewin,sstr);
	if (pos > 0)
	{	
		thewin->position = pos;
		graf_mouse(ARROW,0L);
		return(-1);
	}
	else
	{	
		rsc_alert(NO_OCCUR);
		thewin->position--;
		graf_mouse(ARROW,0L);
		return(0);
	}
}

/*
	name: forward2
	utility: searches forward
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
static long forward2(windowptr	thewin,char *sstr)
{
	unsigned	num;
	register int	j;
	register long i;
	long strl = sstrlen;
	
	for (i=thewin->position; i<(thewin->flen-strl); i++)
	{
		j=1;
		num = getbyte(thewin,i);
		if (num == sstr[0])
		{
			while (j<strl)
			{
				if( (num = getbyte(thewin,i+j)) == sstr[j])
					j++;
				else
					break;
			}
			if (j == strl)
				return(i);
		}
	}
	return(-1);
}

/*
	name: rp_forw
	utility: replace going forward
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
static int rp_forw(windowptr	thewin,char *sstr)
{
	long pos = forward2(thewin,sstr);
	if ( pos > -1)
	{
		thewin->position = pos;
		return(-1);
	}
	else
	{
 		send_redraw(thefrontwin);
/*		one_page(thewin);
		redraw_vslider(thewin->handle);
*/		rsc_alert(NO_OCCUR);
		return(0);
	}
}

/*
	name: back1
	utility: search backwards
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
void back1(windowptr	thewin,char *sstr)
{
	long	pos;

	graf_mouse(BUSYBEE,0L);

	thewin->position--;
	pos = back2(thewin,sstr);

	if( pos > -1 )
	{
		thewin->position = pos;
		check_scroll(thewin);
	}
	else
	{
		rsc_alert(NOT_FOUND);
		thewin->position++;
	}
	graf_mouse(ARROW, 0L);
}

/*
	name: back2
	utility: search backwards
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
static long back2(windowptr	thewin,char *sstr)
{
	unsigned	num;
	int	j;
	long i;
	long strl = sstrlen;
	
	for (i=thewin->position; i > -1; i--)
	{
		j=1;
		num = getbyte(thewin,i);
		if(num == sstr[0])
		{
			while (j<strl)
			{
				if( (num = getbyte(thewin,i+j)) == sstr[j])
					j++;
				else
					break;
			}
			if (j == strl)
				return(i);
		}
	}
	return(-1);
}		

/*
	name: ronce
	utility: replace once
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
static int ronce(windowptr	thewin,char *sstr, char *rstr)
{
	graf_mouse(BUSYBEE,0L);
	if (rp_forw(thewin,sstr))
	{
		thewin->startmark = thewin->position;
		thewin->position += sstrlen;
		thewin->position = thewin->position<thewin->flen-1 ?
							 thewin->position : thewin->flen-1;
		thewin->endmark = thewin->position -1;
		thewin->markson = TRUE;
		cutit(thewin);
		thewin->changed = TRUE;
			/* following code just clears the marks  */
		thewin->startmark = 1;
		thewin->endmark = 0;
		thewin->markson = FALSE;
		
	/* insert_it() inserts rstrlen bytes from string pointed to by rstr
   	into the file before the position of the cursor... see edit.c
	*/
		insert_it(thewin,rstrlen,rstr);
		graf_mouse(ARROW,0L);
		return(-1);
	}
	else
	{
		graf_mouse(ARROW,0L);
		return(0);
	}
}	
	
/*
	name: rall
	utility: replace all
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
static void rall(windowptr	thewin,char *sstr, char *rstr)
{
 	send_redraw(thefrontwin);
/*	one_page(thewin);
*/
	while(ronce(thewin,sstr,rstr))
		thewin->position += rl;	
	thewin->position -= rl;
	jump_pos(thewin);
	send_redraw(thewin);
}

/*
	name: rver
	utility: replace with verify
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
static void rver(windowptr	thewin, char *sstr, char *rstr)
{
	int	result = 1;

	graf_mouse(BUSYBEE,0L);
	do
	{	
		if(rp_forw(thewin,sstr))
		{
/*			int button;
			const int x=dsearch2->ob_x;
			const int y=dsearch2->ob_y;
			const int w=dsearch2->ob_width;
			const int h=dsearch2->ob_height;
*/

			repos(thewin);
 			send_redraw(thewin);
/*			one_page(thewin); */
			redraw_vslider(thewin);
			putcur();	/* cursor on	*/
			graf_mouse(ARROW,0L);
/*			button = do_dialxy(dsearch2, 200, 100);
*/			graf_mouse(BUSYBEE,0L);
/*			objc_change(dsearch2, RPBUT, 0,x,y,w,h, NORMAL, 0);
			objc_change(dsearch2, SKBUT, 0,x,y,w,h, NORMAL, 0);
			objc_change(dsearch2, ABBUT, 0,x,y,w,h, NORMAL, 0);
			putcur();	/* cursor off	*/
			
			if(button == RPBUT)
			{
				thewin->startmark = thewin->position;
				thewin->position += sstrlen;
				thewin->endmark = thewin->position -1;
				thewin->markson = TRUE;
				cutit(thewin);
				thewin->changed = TRUE;
					/* following code just clears the marks  */
				thewin->startmark = 1;
				thewin->endmark = 0;
				thewin->markson = FALSE;
				
			/* insert_it() inserts rl bytes from string pointed to by rstr
				into the file before the position of the cursor... see edit.c
			*/
				insert_it(thewin,rstrlen,rstr);
				thewin->position += rstrlen;
				result = 1;
			}
			else if (button == SKBUT)
			{
				if (thewin->position < thewin->flen-2)
					thewin->position++;
			}
			else if(button == ABBUT)
				break;
*/		} /* end of if(rp_forw())  */
		else
		{
			thewin->position -= rstrlen;	
			result = 0;
		}
	} while(result);

	send_redraw(thewin);
	graf_mouse(ARROW,0L);
}
