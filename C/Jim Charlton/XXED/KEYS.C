
#include <gemdefs.h>
#include <obdefs.h>
#include <osbind.h>

#include "globals.h"
#include "xxed.h"

long saveb;


do_kbd(keycode,keymods)
	int	keycode,keymods;
{	
	windowptr	thewin;
	char 		inbuf[8];
	long		lnum;
	int			skip,button;

/* this fuction is probably the most tangled code in the whole program */

	if (keymods & 0x08)	/* alt key is pressed - command mode */
		{	alt_keys(keycode);
			return;
		}
		
	if (firstwindow == NULL) return; /* no window open  */

	thewin = thefrontwin;

	if(thewin->markson)
		handle_marks(CLEAR);

	graf_mouse(M_OFF, 0L);
	skip = TRUE;
	if(thewin->icount!=0) /* in the middle of a hex num input */
		do_kbd2(thewin,keycode,keymods); /* handle hex input */
	else
	{	saveb = getbyte(thewin,thewin->position);
				/* store the current undirtied byte	*/
				/* then check for special keys		*/
	switch (keycode) {
		case 0x5200:	ins ^= TRUE;
						if(ins)
				    	{	menubar[INSERT].ob_state = CHECKED;
							menubar[REPLACE].ob_state = NORMAL;
						}
						else
						{	menubar[INSERT].ob_state = NORMAL;
							menubar[REPLACE].ob_state = CHECKED;
						}
						wr_ins_rpl(ins);
						break;
		case 0x4d00:	cur_right(thewin);
						break;
		case 0x5000:	cur_down(thewin);
						break;
		case 0x4800: 	cur_up(thewin);
						break;
		case 0x4b00: 	cur_left(thewin);
						break;
		case 0x537f:	if(thewin->prot)
							prot_warn();
						else
						{	delete_one(thewin,thewin->position,1);
						if(repos(thewin))
							partial = FALSE;
						else
							partial = TRUE;
						send_redraw(thewin);
						}
						break;
		case 0x0e08:	if(thewin->position-1 >= 0)
						if(thewin->prot)
							prot_warn();
						else
						{	delete_one(thewin,--thewin->position,1);
							if(repos(thewin))
								partial = FALSE;
							else
								partial = TRUE;
							one_page(thewin,1);
						}
						break;
		default: skip = FALSE;
					}
	if (!(skip))	/* if it was not a special key	*/
	if (!thewin->prot)		/* read-only protection not on  */
		{
		if(inhex)
			do_kbd2(thewin,keycode,keymods); /* handle hex input */
		else 	/* handle ascii input	*/
			{	if( (thewin->position==thewin->flen-1) && !ins) /* in replace mode on terminal dummy byte */
				{	button = form_alert(1, "[1][ The last byte in the file is | a dummy byte and cannot be | changed. It is not saved | with the file. Use insert mode. ][OK]");				
					thewin->icount = 0;
					graf_mouse(M_ON, 0L);
					return;
				}
					if(keycode & 0xff)	
						{	sprintf(inbuf,"%x",(keycode & 0xff));
    	    				inbuf[2] = 0;
    	    				lnum = (long)keycode & 0xff;
							enter_it(thewin,inbuf,lnum);
						}
			}
		}  /* end of if(!thewin->prot)  */
		else
			prot_warn();  /* see menu.c   */
	} /* end of else for if(thewin->icount!=0).....  */
	graf_mouse(M_ON, 0L);
	
}
		
do_kbd2(thewin,keycode,keymods) /* handles hex input */
	windowptr	thewin;
	int	keycode,keymods;
{

			if(thewin->prot)
			{	prot_warn();
				return;
			}
			thewin->input[thewin->icount++] = keycode & 0xFF;
			ins_rpl(thewin);
}

alt_keys(keycode)
	int keycode;
{ 
	windowptr thewin;

	thewin = thefrontwin;

	graf_mouse(M_OFF, 0L);
	switch (keycode) {
		case 0x1000:	handle_file(QUIT);
						break;
		case 0x3000:	handle_search(BACK);
						break;
		case 0x1E00:	handle_search(FORWARD);
						break;
		case 0x2100:	graf_mouse(M_ON, 0L);
						handle_search(FIND);
						graf_mouse(M_OFF, 0L);
						break;
		case 0x1900:	handle_marks(CLEAR);
						break;
		case 0x1800:	handle_marks(END);
						break;
		case 0x1700:	handle_marks(START);
						break;
		case 0x1200:	if(thewin->prot)
							prot_warn();
						else
							handle_edit(ERASE);
						break;
		case 0x2f00:	if(thewin->prot)
							prot_warn();
						else
							handle_edit(PASTE);
						break;
		case 0x2e00:	handle_edit(COPY);
						break;
		case 0x2d00:	if(thewin->prot)
							prot_warn();
						else
							handle_edit(CUT);
						break;
		case 0x1f00:	handle_file(SAVE);
						break;
		default	   :	;
	}
	graf_mouse(M_ON, 0L);
}

cur_up(thewin)
	windowptr	thewin;
{
	 if((thewin->position-=16)<0)
		thewin->position+=16;
		else check_scroll(thewin);
}


cur_down(thewin)
	windowptr	thewin;
{
	 if((thewin->position+=16)>thewin->flen-1)
		thewin->position-=16;
		else check_scroll(thewin);
}

cur_right(thewin)
	windowptr	thewin;
{
 		if(++thewin->position>thewin->flen-1)
			thewin->position--;
			else check_scroll(thewin);
}

cur_left(thewin)
	windowptr	thewin;
{
	if(--thewin->position<0)
		thewin->position++;
		else check_scroll(thewin);
}

check_scroll(thewin) /* cursor off screen?? scroll or reposition */
	windowptr	thewin;
{
	long winlines, bottomchar;
	int up, down;
	
	winlines = thewin->work.g_h/gl_hchar; /* no of lines can put in window  */
	bottomchar = thewin->topchar + (winlines * 16) - 1;
	
	up = 2; down = 3;
	
	if (thewin->position > bottomchar )
		if (thewin->position > bottomchar +16)
			{	jump_pos(thewin);
				send_redraw(thewin);
			}
		else	send_arrow(thewin,down);
	if (thewin->position < thewin->topchar)
		if (thewin->position < thewin->topchar - 16)
			{	jump_pos(thewin);
				send_redraw(thewin);
			}
		else	send_arrow(thewin,up);

}


repos(thewin)  /* reposition and redraw with cursor on screen */
	windowptr	thewin;
{
	long winlines, bottomchar;
	
	winlines = thewin->work.g_h/gl_hchar; /* no of lines can put in window  */
	bottomchar = thewin->topchar + (winlines * 16) - 1;
	
	if ( (thewin->position > bottomchar )||
			(thewin->position < thewin->topchar) )
	{	jump_pos(thewin);
		return(1);
	}
	else
		return(0);
}

jump_pos(thewin) /* reset display parameters so cursor on screen */
	windowptr	thewin;
{	
	long totallines, winlines, topwlnmax, topwline,dummy;
	int		vslide;


	totallines = 1 + thewin->flen/16;
	winlines = thewin->work.g_h/gl_hchar; /* no of lines can put in window  */

	thewin->topchar = ((thewin->position - (8 * winlines)) & 0xfffffff0);
	if (thewin->topchar < 0)
		thewin->topchar = 0;

	topwlnmax = ((totallines - winlines)>0) ? (totallines-winlines) : 0;
  	topwline = (thewin->topchar/16 < topwlnmax) ? thewin->topchar/16 : topwlnmax;
	vslide = (1000*topwline)/topwlnmax;
	thewin->vslidepos = vslide;
}

ins_rpl(thewin)  /* enters hex charactes into the file */
	windowptr	thewin;
{
	int		x,y,handle,button;
	char	*inbuf;
	long	lnum;
	unsigned	b;

	x = 	thewin->xcur;
	y = 	thewin->ycur + gl_hchar-1;
	handle = thewin->graf.handle;
	inbuf = thewin->input;

		inbuf[thewin->icount]='\0';
	if( (thewin->position==thewin->flen-1) && !ins) /* in replace mode on terminal dummy byte */
	{	button = form_alert(1, "[1][ The last byte in the file is | a dummy byte and cannot be | changed. It is not saved | with the file. Use insert mode. ][OK]");				
		thewin->icount = 0;
		return;
	}			 
		if (hex_chk(thewin,inbuf[thewin->icount-1])==1) /* is a hex char */
			if (thewin->icount==1) /* first hex char coming   */
				{	b = saveb;	/* saveb is the current byte	*/
					b = b & 0xf;
					lnum = strtol(thewin->input,(char **)NULL,16);
					lnum = (lnum<<4) + b;
					/* write it back with top nibble changed	*/
					putbyte(thewin,thewin->position,lnum);
					v_gtext(handle, x, y, inbuf);
				}
			else 	
	/* two valid hex characters entered. Enter in buffer and redrw line */
			{	lnum = strtol(thewin->input,(char **)NULL,16);
				enter_it(thewin,inbuf,lnum);
			}
		
}

enter_it(thewin,inbuf,lnum) /* insert or replace byte redrawing screen */
	windowptr	thewin;
	char		*inbuf;
	long		lnum;

{	int x,y,handle;

				handle = thewin->graf.handle;
				x = 	thewin->xcur;
				y = 	thewin->ycur + gl_hchar-1;
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
			{	inbuf = "  ";
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


hex_chk(thewin, ch) /* checks to see if a hex character was entered */
	windowptr	thewin;
	char	ch;
{
	int ret, button;
	static int times;
	switch (ch) {
		case '0': case '1': case '2': case '3': case '4': case '5':
		case '6': case '7': case '8': case '9': case 'A': case 'B':
		case 'C': case 'D': case 'E': case 'F': case 'a': case 'b':
		case 'c': case 'd': case 'e': case 'f': ret = 1 ; times = 0; break;
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
	button = form_alert(1, "[1][ | | Enter a HEX digit or Backspace ][ OK ]");				
					ret = 0;
                }
		return(ret);
}

wr_ins_rpl(insflag) /* writes insert/replace/hex/ascii on menu line */
	int	insflag;
{	windowptr	thewin;
	
	cursor(60,0);
	if(thewin = thefrontwin)
	{	if(insflag && inhex)
			{printf("%s\n","HEX   insert ");}
		if(!(insflag) && inhex)
			{printf("%s\n","HEX   replace");}
		if(insflag && !(inhex))
			{printf("%s\n","ASCII insert ");}
		if(!(insflag) && !(inhex))
			{printf("%s\n","ASCII replace");}
	}
	else
		printf("%s\n","             ");
}

cursor(x,y)   /* position the cursor*/
        int x,y;
  {     Bconout(2,27); Bconout(2,'Y');
        Bconout(2,(32 + y)); Bconout(2,(32 + x));
  }
