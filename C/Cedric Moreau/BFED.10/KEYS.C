/*
	file: keys.c
	utility:
	date: 1989
	author: Jim Charlton
	modifications:
		1996: C. Moreau: 
	comments: 
*/
#include <ctype.h>
#include <stdio.h>
#include <string.h>

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

#include "e:\proging\c\libs\malib\alert.h"

#include "dialog.h"
#include "edit.h"
#include "init.h"
#include "keys.h"
#include "menu.h"
#include "onepage.h"
#include "send.h"
#include "wind.h"

#include "bfed_rsc.h"

/*
	globals vars
*/
int keycode;

/*
	locals vars 
*/
static long saveb;
static KEYTAB *kt;

/*
	locals functions
*/
static void ctrl_keys(int keycode, int keymods);
static void cmd_keys(int keycode, int keymods);
static void cur_up(windowptr	thewin);
static void cur_down(windowptr	thewin);
static void cur_right(windowptr	thewin);
static void cur_left(windowptr	thewin);
static void pag_up(windowptr thewin);
static void pag_down(windowptr thewin);
static void pag_home(windowptr thewin);
static void pag_end(windowptr thewin);
static int hex_chk(windowptr thewin,char	ch);

/*
	name: do_kbd
	utility:  
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C.Moreau: 
*/
void do_kbd(int keycode, int keymods)
{	
	if (keymods & K_CTRL)	/* ctrl key is pressed - command mode */
	{
		ctrl_keys(keycode, keymods);
	}
	else if (thefrontwin && !thefrontwin->form) /* window open & not form */
	{
		if (thefrontwin->markson)
			do_menu(EDIT,CLEAR);

		if (thefrontwin->icount) /* in the middle of a hex num input */
		{
			if (thefrontwin->prot)
			{
				rsc_alert(PROTECTED);
			}
			else
			{
				thefrontwin->input[thefrontwin->icount++] = keycode & 0xFF;
				ins_rpl(thefrontwin);
			}
		}
		else	/* a command keys is pressed */
		{
			cmd_keys(keycode, keymods);
		}
	}

	window_info(thefrontwin);
}

/*
	name: cmd_kbd
	utility:  
	comment: 
	parameters:
	return:
	date: 1995
	author: C.Moreau
	modifications:
*/
static void cmd_keys(int keycode, int keymods)
{
	
	{
		saveb = getbyte(thefrontwin, thefrontwin->position);
				/* store the current undirtied byte	*/
				/* then check for special keys		*/
	
		switch (keycode)
		{
			case 0x5200:	/* insert */
				ins ^= TRUE;
				update_menu();
				break;
			case 0x4d00:		/* arrow right */
				cur_right(thefrontwin);
				break;
			case 0x5000:		/* arrow down */
				cur_down(thefrontwin);
				break;
			case 0x4800:		/* arrow up */
			 	cur_up(thefrontwin);
				break;
			case 0x4b00:		/* arrow left */
				cur_left(thefrontwin);
				break;
			case 0x4838:		/* shift arrow up */
				pag_up(thefrontwin);
				break;
			case 0x5032:		/* shift arrow down */
				pag_down(thefrontwin);
				break;
			case 0x4700:		/* Home */
				pag_home(thefrontwin);
				break;
			case 0x4737:		/* shift Home */
				pag_end(thefrontwin);
				break;
			case 0x537f:		/* Delete */
				if(thefrontwin->prot)
					rsc_alert(PROTECTED);
				else
				{
					delete_one(thefrontwin, thefrontwin->position, 1);
					if (repos(thefrontwin))
						partial = FALSE;
					else
						partial = TRUE;
					send_redraw(thefrontwin);
				}
				break;
			case 0x0e08:		/* Backspac */
				if(thefrontwin->position-1 >= 0)
				{
					if(thefrontwin->prot)
						rsc_alert(PROTECTED);
					else
					{
						delete_one(thefrontwin, --thefrontwin->position, 1);
						if (repos(thefrontwin))
							partial = FALSE;
						else
							partial = TRUE;
	 					send_redraw(thefrontwin);
	/*					one_page(thefrontwin); */
					}
				}
				break;
			default:
				if (!thefrontwin->prot)		/* read-only protection not on  */
				{
					if (inhex)	/* handle hex input */
					{
						thefrontwin->input[thefrontwin->icount++] = keycode & 0xFF;
						ins_rpl(thefrontwin);
					}
					else 	/* handle ascii input	*/
						if ( (thefrontwin->position==thefrontwin->flen-1) && !ins) /* in replace mode on terminal dummy byte */
						{
							rsc_alert(LAST_BYTE2);				
							thefrontwin->icount = 0;
						}
						else if (keycode & 0xff)	
						{
							char 	inbuf[8];
							long	lnum;
	
							sprintf(inbuf, "%x", (keycode & 0xff));
			 				inbuf[2] = 0;
			 				lnum = (long)keycode & 0xff;
							enter_it(thefrontwin,inbuf,lnum);
						}
				}
				else
					rsc_alert(PROTECTED);				
		}
	}
}

/*
	name: ctrl_kbd
	utility:  
	comment: 
	parameters:
	return:
	date: 1995
	author: C.Moreau
	modifications:
*/
static void ctrl_keys(int keycode, int keymods)
{
		/* switch on ascii key code without shift */
 	switch ((char)toupper(kt->unshift[(char)(keycode >> 8)]))
	{
		case 'A':	
			do_menu(EDIT,SELECT_ALL);
			break;
		case 'C':	
			do_menu(EDIT,COPY);
			break;
		case 'D':	
			do_menu(EDIT,CLEAR);
			break;
		case 'F':	
			do_menu(SEARCH,FIND);
			break;
		case 'L':		/* Go position */
			do_menu(SEARCH,GO_POS);
			break;
		case 'M':		/* Mark start/end */
			if ( (keymods & K_RSHIFT) || (keymods & K_LSHIFT) )
				do_menu(EDIT,END);
			else
				do_menu(EDIT,START);
			break;
		case 'N':		/* New file */
			do_menu(FILE,NEW);
			break;
		case 'O':		/* Open file */
			do_menu(FILE,OPEN);
			break;
		case 'P':
			if ( (keymods & K_RSHIFT) || (keymods & K_LSHIFT) )
				do_menu(FILE,SETPRINT);
			else
				do_menu(FILE,PRINT);
			break;
		case 'Q':
			do_menu(FILE,QUIT);
			break;
		case 'S':
			if ( (keymods & K_RSHIFT) || (keymods & K_LSHIFT) )
				do_menu(FILE,SAVEAS);
			else
				do_menu(FILE,SAVE);
			break;
		case 'V':
			do_menu(EDIT,PASTE);
			break;
		case 'W':
			do_menu(EDIT,CLOSE);
			break;
		case 'X':
			do_menu(EDIT,CUT);
			break;
	}
}

/*
	name: cur_up
	utility:  
	comment: 
	parameters:
	return:
	date: 13 may 96
	author: C.Moreau
	modifications:
*/
static void cur_up(windowptr thewin)
{	
	if(thewin->position - 16 >= 0)
	{
		thewin->position -= 16;
		check_scroll(thewin);
	}
}

static void cur_down(windowptr	thewin)
{
	if(thewin->position + 16 <= thewin->flen-1)
	{
		thewin->position += 16;
		check_scroll(thewin);
	}
}

static void cur_right(windowptr thewin)
{
	if (thewin->position + 1 < thewin->flen)
	{
		thewin->position++;
		check_scroll(thewin);
	}
}

static void cur_left(windowptr thewin)
{
	if (thewin->position - 1 >= 0)
	{
		thewin->position--;
		check_scroll(thewin);
	}
}

/*
	name: pag_down
	utility:  
	comment: 
	parameters:
	return:
	date: 1995
	author: C.Moreau
	modifications:
*/
static void pag_down(windowptr thewin)
{
	const long winlines = thewin->work.g_h/gl_hchar; /* no of lines can put in window  */
	
	if (thewin->position+(winlines*16) < thewin->flen)
	{
		long topwlnmax, topwline;
		const long totallines = 1 + thewin->flen/16;
		
		thewin->topchar += winlines * 16;
		thewin->position += winlines * 16;			/* go down 1 page */
			/* update slider pos */
		topwlnmax = ((totallines - winlines)>0) ? (totallines-winlines) : 0;
	  	topwline = (thewin->topchar/16 < topwlnmax) ? thewin->topchar/16 : topwlnmax;
		thewin->vslidepos = (int)((1000*topwline)/topwlnmax);

		send_redraw(thewin);
	}
	else
	{
		thewin->position = thewin->flen-1;
		check_scroll(thewin);
	}
}

/*
	name: pag_up
	utility:  
	comment: 
	parameters:
	return:
	date: 1995
	author: C.Moreau
	modifications:
*/
static void pag_up(windowptr thewin)
{
	const long winlines = thewin->work.g_h/gl_hchar; /* no of lines can put in window  */

	if (thewin->position-(winlines*16) >= 0)
	{
		long topwlnmax, topwline;
		const long totallines = 1 + thewin->flen/16;

		thewin->topchar -= winlines * 16;
		thewin->position -= winlines * 16;			/* go down 1 page */
			/* update slider pos */
		topwlnmax = ((totallines - winlines)>0) ? (totallines-winlines) : 0;
  		topwline = (thewin->topchar/16 < topwlnmax) ? thewin->topchar/16 : topwlnmax;
		thewin->vslidepos = (int)((1000*topwline)/topwlnmax);

		send_redraw(thewin);
	}
	else
	{
		thewin->position = 0;
		check_scroll(thewin);
	}
}

static void pag_home(windowptr thewin)
{
	thewin->position = 0;
	check_scroll(thewin);
}

static void pag_end(windowptr thewin)
{
	thewin->position = thewin->flen-1;
	check_scroll(thewin);
}

/*
	name: check_scroll
	utility: cursor off screen?? scroll or reposition 
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C.Moreau:
*/
void check_scroll(windowptr	thewin)
{
	const long winlines = thewin->work.g_h/gl_hchar; /* no of lines can put in window  */
	const long bottomchar = thewin->topchar + (winlines * 16) - 1;
	
	if (thewin->position > bottomchar)		/* cursor down actual page */
	{
		if (thewin->position > bottomchar + 16)	/* more than 1 line down */
		{
			jump_pos(thewin);
			send_redraw(thewin);
		}
		else
		{
			send_arrow(thewin,WA_DNLINE);
		}
	}
	else if (thewin->position < thewin->topchar)	/* cursor up actual page */
	{
		if (thewin->position < thewin->topchar - 16) /* more than 1 line up */
		{
			jump_pos(thewin);
			send_redraw(thewin);
		}
		else
		{
			send_arrow(thewin,WA_UPLINE);
		}
	}
}

/*
	name: repos
	utility: reposition and redraw with cursor on screen 
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C.Moreau:
*/
int repos(windowptr	thewin)
{
	const long winlines = thewin->work.g_h/gl_hchar; /* no of lines can pu */ 
	const long bottomchar = thewin->topchar + (winlines * 16) - 1;
	
	if ( (thewin->position > bottomchar )||
			(thewin->position < thewin->topchar) )
	{
		jump_pos(thewin);
		return(1);
	}
	else
		return(0);
}

/*
	name: jump_pos
	utility: reset display parameters so cursor on screen  
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C.Moreau:
*/
void jump_pos(windowptr	thewin)
{	
	long topwlnmax, topwline;
	int	vslide;
	const long totallines = 1 + thewin->flen/16;
	const long winlines = thewin->work.g_h/gl_hchar; /* no of lines can put in window  */

	thewin->topchar = ((thewin->position - (8 * winlines)) & 0xfffffff0L);
	if (thewin->topchar < 0)
		thewin->topchar = 0;

	topwlnmax = ((totallines - winlines)>0) ? (totallines-winlines) : 0;
  	topwline = (thewin->topchar/16 < topwlnmax) ? thewin->topchar/16 : topwlnmax;
	vslide = (int)((1000*topwline)/topwlnmax);
	thewin->vslidepos = vslide;
}

/*
	name: ins_rpl
	utility: enters hex charactes into the file   
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C.Moreau:
*/
void ins_rpl(windowptr	thewin) 
{
	const int x = thewin->xcur;
	const int y = thewin->ycur + gl_hchar-1;
	const int handle = thewin->graf.handle;
	char	*inbuf;
	long	lnum;
	unsigned	b;

	inbuf = thewin->input;
	inbuf[thewin->icount]='\0';

	if( (thewin->position==thewin->flen-1) && !ins) /* in replace mode on terminal dummy byte */
	{
		rsc_alert(LAST_BYTE2);				
		thewin->icount = 0;
	}			 
	else if (hex_chk(thewin,inbuf[thewin->icount-1])==1) /* is a hex char */
	{
			if (thewin->icount==1) /* first hex char coming   */
			{
				b = (int)saveb;	/* saveb is the current byte	*/
				b = b & 0xf;
				lnum = strtol(thewin->input,(char **)NULL,16);
				lnum = (lnum<<4) + b;
				/* write it back with top nibble changed	*/
				putbyte(thewin,thewin->position,lnum);
				v_gtext(handle, x, y, inbuf);
			}
			else 	
	/* two valid hex characters entered. Enter in buffer and redrw line */
			{
				lnum = strtol(thewin->input,(char **)NULL,16);
				enter_it(thewin,inbuf,lnum);
			}
	}	
}

/*
	name: enter_it
	utility: insert or replace byte redrawing screen  
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C.Moreau:
*/
void enter_it(windowptr	thewin,char	*inbuf,long	lnum)
{
	const int handle = thewin->graf.handle;
	const int x = thewin->xcur;
	const int y = thewin->ycur + gl_hchar-1;

	v_gtext(handle, x, y, inbuf);
	thewin->icount=0;

	if(!ins)	/* in replace mode	*/
	{
		putbyte(thewin,thewin->position,lnum);
		graf_mouse(M_OFF, 0L);
		one_line2(thewin,thewin->position);	/* see onepage.c */
		cur_right(thewin);
		graf_mouse(M_ON, 0L);
	}
	else	/* in insert mode	*/
	{
		inbuf = "  ";
		*inbuf = (char)lnum;
			/* restore current byte as HEX input dirties it */
		putbyte(thewin,thewin->position,saveb);
		insert_it(thewin,1L,inbuf);  /* see edit.c	*/
		graf_mouse(M_OFF, 0L);
		if(thewin->position == thewin->flen-1)
			one_line2(thewin,thewin->position);
		else
		{	
			one_line2(thewin,thewin->position);	/* see onepage.c */
			partial = TRUE;
			send_redraw(thewin);
		}
		graf_mouse(M_ON, 0L);
		cur_right(thewin);
	}
}

/*
	name: hex_chk
	utility: checks to see if a hex character was entered  
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C.Moreau:
*/
static int hex_chk(windowptr	thewin, char	ch)
{
	int ret;
	static int times;

	switch (ch)
	{
		case '0': 
		case '1': 
		case '2': 
		case '3': 
		case '4': 
		case '5':
		case '6': 
		case '7': 
		case '8': 
		case '9': 
		case 'A': 
		case 'B':
		case 'C': 
		case 'D': 
		case 'E': 
		case 'F':
		case 'a': 
		case 'b':
		case 'c': 
		case 'd': 
		case 'e': 
		case 'f': 	ret = 1 ; times = 0; break;
        case  8 : 	thewin->icount = 0;  /* backspace  after one hex char */
					graf_mouse(M_OFF, 0L);
							/*	restore the byte and redraw line	*/
					putbyte(thewin,thewin->position,saveb);
					one_line2(thewin,thewin->position);
					graf_mouse(M_ON, 0L);
					times = 0;
					ret = 0;
				  	break;
        default :	Bconout(2,7);
					thewin->icount--; /*  wipe out nonhex char  */
					times++;
					if (times>2)
						rsc_alert(ENTER_HEX);				
					ret = 0;
	}
	return(ret);
}

/*
	name: init_keys
	utility: initialise keys.c module  
	comment: 
	parameters:
	return:
	date: 10 may 96
	author: C.Moreau
	modifications:
*/
void init_keys(void)
{
	kt = Keytbl((void *)-1, (void *)-1, (void *)-1);
}
