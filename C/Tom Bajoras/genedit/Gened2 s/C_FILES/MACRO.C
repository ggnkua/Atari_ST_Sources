/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                          Copyright 1990 Tom Bajoras

	module MACRO : macro editor

	ex_savemac, ex_loadmac, ex_editmac, load_macros, init_macros, send_macro

******************************************************************************/

overlay "macro"

/* include header files .....................................................*/

	/* standard */
#include <osbind.h>		/* GEMDOS, BIOS, XBIOS */
#include <gemdefs.h>		/* AES */
#include <obdefs.h>		/* more AES */

	/* program-specific */
#include "defines.h"		/* miscellaneous */
#include "genedit.h"		/* created by RCS */
#include "externs.h"		/* global variables */

	/* local defines */
#define FMT_HEX 0
#define FMT_DEC 1
#define FMT_BIN 2
	/* get rid of this one by using same technique as other file types !!! */
#define VERSION ( ((long)MACHINE<<16) | (long)MACRVERSION )

	/* local globals */
int cursor_m;		/* cursor position: macro within pool (0-35) */
int cursor_b;		/* cursor position: byte within macro (0-(MACRSIZE-1)) */
int cursor_c;		/* cursor position: character within byte (0-7) */
int cursor_x,cursor_y;	/* cursor graphic position */
int home_m;			/* macro displayed in first line */
int home_b;			/* byte offset into macro for first byte of first line */
int line_m[20],line_b[20];	/* macro/byte at start of each line */
int line_n[20];				/* # bytes in each line */
int macromode;					/* 0 hex, 1 decimal, 2 binary */
int ascimode;					/* ascii option: 0= off, 1= on */
int macrused;					/* # bytes used (0-MACRLENG) */
int printcol,printrow;		/* current column/row for macro printout */
int macro_x;		/* column # of start of line */
int macro_y;		/* y-coord of top of first line */
int chpermode[3]= { 2, 3, 8 };	/* characters per byte, for each mode */
int *macroleng;	/* points to length table */
char *macropool;	/* points to start of macro pool */

long load_file();

/* save macro bank ..........................................................*/

ex_savemac()
{
#if MACROFLAG
	char filename[13],pathname[80];
	long addr,leng;

	tempmem= -1;
	strcpy(filename,macrfile);
	Dsetdrv(mac_drive); dsetpath(mac_path);
	if (getfile(pathname,filename,MAX_EXT,MSAVTITL)>0)
	{
		mac_drive=Dgetdrv(); Dgetpath(mac_path,mac_drive+1);
		addr= (long)(macrobuf);
		/* in case file was loaded from a different version */
		*(long*)(macrobuf+4)= VERSION;
		leng= MAXLENG;
		save_file(filename,pathname,1,&addr,&leng);
		{
			strcpy(macrfile,filename);
			change_flag[macrCHANGE]=0;
		}
	}	/* end if ok from file selector */

	dealloc_mem(tempmem);

#endif
}	/* end ex_savemac() */

/* load macro file ..........................................................*/

ex_loadmac()
{
#if MACROFLAG
	char filename[13],pathname[80];

	/* overwrite changed macros? */
	if (change_flag[macrCHANGE])
		if (form_alert(1,CHNGEMAC)==2) return;

	tempmem= -1;
	filename[0]=0;
	Dsetdrv(mac_drive); dsetpath(mac_path);
	if (getfile(pathname,filename,MAXC_EXT,MLDETITL)>0)
	{
		mac_drive=Dgetdrv(); Dgetpath(mac_path,mac_drive+1);
		load_macros(pathname,filename);
	}	/* end if ok from file selector */

	dealloc_mem(tempmem);
#endif
}	/* end ex_loadmac() */

/* load macro file (also called during autoload) ............................*/
/* returns 0= ok, else error */

load_macros(pathname,filename)
char *pathname,*filename;
{
#if MACROFLAG
	register long *lptr;
	int error= -1;

	if (load_file(pathname,filename))
	{
		if ( heap[tempmem].nbytes == MACLENG )
			error=convertmac();
		else
		{
			error=0;
			lptr= (long*)(heap[tempmem].start);
			if (lptr[0]!=MACRMAGIC) error=1;
			if ( !error && ((lptr[1]&0xFFFFL)>MACRVERSION) ) error=2;
			if (!error) copy_bytes(lptr,macrobuf,MAXLENG);
		}
		if (error==0)
		{
			strcpy(macrfile,filename);
			change_flag[macrCHANGE]=0;
		}
		if (error==1) big_alert(1,BADREAD1,filename,BADREAD2);
		if (error==2) form_alert(1,BADVERSION);
	}	/* end if file loaded successfully */
	return error;
#endif
}	/* end load_macros() */

/* macro editor .............................................................*/

ex_editmac()
{
#if MACROFLAG

	register int temp,i;
	int exit_obj,edit_obj,mstate,mousex,mousey,done;
	int key,m,b,c;
	char *charptr;
	static int fixed;

	if (!fixed)
	{
		full_dial(macraddr);
		macraddr[MACRFIX1].ob_y += 2*rez;				/* half rows */
		macraddr[MACRFIX2].ob_y -= 2*rez;
		fixed=1;
	}

	/* pointers */
	macroleng= (int*)( macrobuf+8 );
	macropool= macrobuf+8+(2*NMACROS);

	/* encode buffer lengths */
	itoa(nmacrclip,macraddr[MACRCLIP].ob_spec,4);
	encodeclip();
	calc_used();

	/* clip board not empty? */
	if (nmacrclip)
		macraddr[MACRPSTE].ob_state &= ~DISABLED;
	else
		macraddr[MACRPSTE].ob_state |= DISABLED;

	/* file name */
	strcpy(macraddr[MACRTITL].ob_spec,macrfile);

	/* draw dialog box */
	putdial(macraddr,1,0);

	/* coordinates of display area */
	objc_offset(macraddr,MACRAREA,&macro_x,&macro_y);
	macro_x /= charw;

	/* initialize display area */
	home_m= home_b= 0;
	disp_macro();
	home_cursor();

	disp_cursor();

	edit_obj= -1;
	done=0;
	do
	{
		key=0;
		*keyb_head= *keyb_tail;		/* no type-ahead */
		exit_obj= my_form_do(macraddr,&edit_obj,&mstate,1,&key);
		getmouse(&mousex,&mousey);
		if (key) exit_obj= macro_key(key);
		switch (exit_obj)
		{
			case MACRRULE:
			if (findmbc(macro_x,mousey,&m,&b,&c)) send_macro(m);
			waitmouse();
			break;
						
			case MACRAREA:
			temp= mousex/charw;
			if (findmbc(temp,mousey,&m,&b,&c))
			{
				disp_cursor();
				cursor_m=m;
				cursor_b=b;
				cursor_c=c;
				findxy(m,b,c,&cursor_x,&cursor_y);
				disp_cursor();
			}
			waitmouse();
			break;

			case MACRDOWN:
			case MACRUPUP:
			scrolldisp(exit_obj==MACRUPUP);
			evnt_timer(100,0);
			break;

			case MACRUP:			/* scroll up by line */
			if (line_m[1]>=0)
			{
				home_m= line_m[1];
				home_b= line_b[1];
				disp_macro();
				if (!findxy(cursor_m,cursor_b,cursor_c,&cursor_x,&cursor_y))
					home_cursor();
				disp_cursor();
			}
			evnt_timer(100,0);
			break;

			case MACRFIND:
			findmacro();
			waitmouse();
			break;

			case MACRHEX:
			case MACRDEC:
			case MACRBIN:
			if (exit_obj==MACRHEX) temp= FMT_HEX;
			if (exit_obj==MACRDEC) temp= FMT_DEC;
			if (exit_obj==MACRBIN) temp= FMT_BIN;
			if (temp!=macromode)
			{
				macromode=temp;
				disp_macro();
				cursor_c=0;
				if (!findxy(cursor_m,cursor_b,cursor_c,&cursor_x,&cursor_y))
					home_cursor();
				disp_cursor();
				encodeclip();
				draw_object(macraddr,MACRFIX2);
			}
			waitmouse();
			break;

			case MACRASCI:
			ascimode= !ascimode;
			disp_macro();
			cursor_c=0;
			findxy(cursor_m,cursor_b,cursor_c,&cursor_x,&cursor_y);
			disp_cursor();
			encodeclip();
			draw_object(macraddr,MACRFIX2);
			waitmouse();
			break;

			case MACRPRNT:
			waitmouse();
			temp=1;
			while ( !(temp=Cprnos()) )
				if (form_alert(1,BADPRINT)!=1) break;
			if (temp)
			{
				menuprompt(NOWPRINTMSG);
				printmacros();
				menuprompt(0L);
			}
			sel_obj(0,macraddr,MACRPRNT);
			draw_object(macraddr,MACRPRNT);
			waitmouse();
			break;

			case MACRCOPY:
			case MACRCUT:
			temp=0;
			if (exit_obj==MACRCUT)	/* can't cut entire macro */
			{
				if ( (mstate<0) && (cursor_b==(macroleng[cursor_m]-1)) ) temp=1;
				if ( (mstate>0) && !cursor_b ) temp=1;
				if (!temp) change_flag[macrCHANGE]=1;
			}
			if (temp)
				Cconout(7);
			else
			{
				charptr= macropool;
				for (i=0; i<cursor_m; i++) charptr+=macroleng[i];
				nmacrclip=0;
				if (mstate<0)	/* left button: copy [0] to cursor_b */
				{
					for (i=0; i<=cursor_b; i++)
						macrclip[nmacrclip++]= *charptr++;
				}
				else				/* right button: copy cursor_b to end of macro */
				{
					charptr+=cursor_b;
					for (i=cursor_b; i<macroleng[cursor_m]; i++)
						macrclip[nmacrclip++]= *charptr++;
				}
				macraddr[MACRPSTE].ob_state &= ~DISABLED;
				itoa(nmacrclip,macraddr[MACRCLIP].ob_spec,4);
				encodeclip();
				if (exit_obj==MACRCUT)
				{
					if (cursor_m<(NMACROS-1))
					{	/* close up hole:
							c= first byte of hole, m= first byte past hole */
						for (i=c=0; i<cursor_m; i++) c+=macroleng[i];
						if (mstate<0)
							m= c+cursor_b+1;
						else
						{
							m= c+macroleng[i];
							c+=cursor_b;
						}
						for ( ; m<MACRLENG; macropool[c++]=macropool[m++]) ;
					}
					if (mstate<0)
					{
						macroleng[cursor_m] -= (cursor_b+1);
						cursor_b=0;
					}
					else
					{
						macroleng[cursor_m]= cursor_b;
						cursor_b--;
					}
					disp_macro();
					findxy(cursor_m,cursor_b,cursor_c,&cursor_x,&cursor_y);
					disp_cursor();
					calc_used();
					draw_object(macraddr,MACRUSED);
					draw_object(macraddr,MACRLEFT);
				}
				draw_object(macraddr,MACRPSTE);
				draw_object(macraddr,MACRCLIP);
				draw_object(macraddr,MACRFIX2);
			}
			waitmouse();
			break;

			case MACRPSTE:
			if ( (nmacrclip+macrused)<MACRLENG )
			{
				for (i=c=0; i<cursor_m; i++) c+=macroleng[i];
				c+= cursor_b;	/* insert before/after c */
				if (mstate>0) c++;	/* after */
				for (i=MACRLENG-1; i>=(c+nmacrclip); i--)
					macropool[i]= macropool[i-nmacrclip];
				copy_bytes(macrclip,macropool+c,(long)nmacrclip);
				macroleng[cursor_m] += nmacrclip;
				disp_macro();
				if (mstate<0) cursor_b += nmacrclip;
				if (!findxy(cursor_m,cursor_b,cursor_c,&cursor_x,&cursor_y))
					home_cursor();
				disp_cursor();
				calc_used();
				draw_object(macraddr,MACRUSED);
				draw_object(macraddr,MACRLEFT);
				change_flag[macrCHANGE]=1;
			}
			else
				Cconout(7);
			waitmouse();
			break;

			case MACREXIT:
			waitmouse();
			done=1;

		}	/* end switch */
	}
	while (!done);
	putdial(0L,0,exit_obj);

#endif

}	/* end ex_editmac() */

/* initialize all macros ....................................................*/

init_macros()
{
	*(long*)(macrobuf)= MACRMAGIC;
	*(long*)(macrobuf+4)= VERSION;						/* machine/version */
	set_words(macrobuf+8,(long)NMACROS,1);				/* each macro has 1 byte */
	set_bytes(macrobuf+8+2*NMACROS,MACRLENG,0);		/* zero pool */
	macrfile[0]=0;
	change_flag[macrCHANGE]=0;
}	/* end init_macros() */

/* send a macro .............................................................*/
/* returns 0= not sent (empty macro), 1= sent */

send_macro(which)
int which;		/* which macro: 0 - (NMACROS-1) */
{
#if MACROFLAG
	register int i;
	register int *lengptr;
	register char *charptr;

	lengptr= (int*)( macrobuf + 8 );
	charptr= macrobuf + 8 + 2*NMACROS;
	for (i=0; i<which; i++) charptr+=lengptr[i];
	i=0;
	if ( (lengptr[which]==1) && !charptr[0] )		/* don't send single 0 */
		Cconout(7);
	else
	{
		send_midi(charptr,lengptr[which]);
		i=1;
	}
	return i;
#else
	return 0;
#endif
}	/* end send_macro() */

/* the following functions are called only from the above functions .........*/
#if MACROFLAG

/* display macro area .......................................................*/

disp_macro()
{
	register col,row,m,b;
	register char *macroptr;
	int y,leng;
	unsigned int i;

	HIDEMOUSE

	/* clear out entire area */
	blankarea();
	for (row=0 , y=macro_y; row<20; row++,y+=charh)
		gr_text(" ",macro_x-2,y);

	row=0;
	leng= chpermode[macromode];
	macroptr= macropool;
	for (m=0; m<home_m; m++) macroptr+=macroleng[m];
	macroptr+= (b=home_b);
	y= macro_y;

	while ( (row<20) && (m<NMACROS) )
	{
		line_m[row]=m;
		line_b[row]=b;
		line_n[row]=0;
		col=0;
		if (!b) gr_text(macroasci[m],macro_x-2,y);
		while ( ((col+leng-1)<60) && (b<macroleng[m]) )
		{
			i= *macroptr++; b++;
			disp_1mac(i,macro_x+col,y);
			line_n[row]++;
			col+=(leng+1);
		}
		row++;
		y+= charh;
		if (b==macroleng[m]) { m++; b=0; }
	}
	while (row<20)
	{
		line_m[row]= -1;
		line_n[row]=0;
		line_b[row++]= -1;
	}

	SHOWMOUSE
}	/* end disp_macro() */

/* encode (start of) clipboard ..............................................*/

encodeclip()
{
	register char *bufptr,*ptr;
	register int leng,i,j;
	unsigned int ch;
	char charbuf[12];

	bufptr= macraddr[MACRFIX2].ob_spec;
	bufptr[0]=0;
	ptr= macrclip;
	leng= chpermode[macromode];
	for (i=j=0; (i<nmacrclip)&&((j+leng)<58); i++)
	{
		ch= *ptr++;
		switch (macromode)
		{
			case FMT_HEX: strcpy(charbuf,hextext[ch]); break;
			case FMT_DEC: itoa(ch,charbuf,3); break;
			case FMT_BIN: btoa(ch,charbuf);
		}
		if ( ascimode && (ch>=0x20) && (ch<=0x7E) )
		{
			charbuf[leng]=0;
			charbuf[leng-1]=ch;
			asm { move.w leng,-(a7) }
			for (leng-=2; leng>=0; leng--) charbuf[leng]=' ';
			asm { move.w (a7)+,leng }
		}
		strcat(bufptr,charbuf);
		strcat(bufptr," ");
		j+= (leng+1);
	}
	if (i<nmacrclip) strcat(bufptr,"...");
}	/* end encodeclip() */

/* display byte .............................................................*/

disp_1mac(i,x,y)
int i,x,y;
{
	int leng,halftone;
	char charbuf[9];

	leng= chpermode[macromode];
	switch (macromode)
	{
		case FMT_HEX: strcpy(charbuf,hextext[i]); break;
		case FMT_DEC: itoa(i,charbuf,3); break;
		case FMT_BIN: btoa(i,charbuf);
	}
	halftone=0;
	if (ascimode)
	{
		if ( (i>=0x20) && (i<=0x7E) )
		{
			charbuf[leng]=0;
			charbuf[leng-1]=i;
			asm { move.w leng(a6),-(a7) }
			for (leng-=2; leng>=0; leng--) charbuf[leng]=' ';
			asm { move.w (a7)+,leng(a6) }
		}
		else
			halftone=1;
	}
	gr_text(charbuf,x,y);
	if (halftone) halftext(leng,x,y);
}	/* end disp_1mac() */

/* (un)display cursor .......................................................*/

disp_cursor()
{
	int w;

	/* cursor width */
	w= ascimode ? chpermode[macromode] : 1 ;
	xortext(w,cursor_x,cursor_y);		
}	/* end disp_cursor() */

/* move cursor forward ......................................................*/

cursorfor(shift)
int shift;	/* 0= next char, 1= next byte */
{
	register int m=cursor_m;
	register int b=cursor_b;
	register int c=cursor_c;
	int x,y;

	if (ascimode||shift)
	{
		b++;	c=0;
	}
	else
	{
		c++;
		if (c==chpermode[macromode])
		{
			c=0;
			b++;
		}
	}
	if (b==macroleng[m])
	{
		c=0;
		b=0;
		m++;
	}
	if (findxy(m,b,c,&x,&y))
	{
		cursor_m=m;
		cursor_b=b;
		cursor_c=c;
		cursor_x=x;
		cursor_y=y;
	}
}	/* end cursorfor() */

/* move cursor backward .....................................................*/

cursorrev(shift)
int shift;	/* 0= previous char, 1= previous byte */
{
	register int m=cursor_m;
	register int b=cursor_b;
	register int c=cursor_c;
	int x,y;

	if ( (m==home_m) && (b==home_b) && !c ) return;

	if (ascimode||shift)
	{
		b--;	c=0;
	}
	else
	{
		c--;
		if (c<0)
		{
			c= chpermode[macromode]-1;
			b--;
		}
	}
	if (b<0)
	{
		if (m) m--;
		b= macroleng[m]-1;
		c= ascimode||shift ? 0 : chpermode[macromode]-1 ;
	}
	if (findxy(m,b,c,&x,&y))
	{
		cursor_m=m;
		cursor_b=b;
		cursor_c=c;
		cursor_x=x;
		cursor_y=y;
	}
}	/* end cursorrev() */

/* calculate and encode macrused and MACRLENG-macrused ......................*/

calc_used()
{
	register int i,leng;

	for (i=leng=0; i<NMACROS; i++) leng+=macroleng[i];
	itoa(macrused=leng,macraddr[MACRUSED].ob_spec,4);
	leng= MACRLENG-leng;
	itoa(leng,macraddr[MACRLEFT].ob_spec,4);
}	/* end calc_used() */

/* convert MAC file to MAX file .............................................*/
/* returns 0 */

convertmac()
{
	register int i;
	register char *charptr;

	init_macros();
	macroleng= (int*)( macrobuf+8 );
	charptr= macrobuf+8+(2*NMACROS);
	for (i=0; i<NMACROS; i++)
	{
		macroleng[i]= converthex(heap[tempmem].start+23*i,charptr);
		charptr += macroleng[i];
	}
	return 0;
}	/* end convertmac() */

converthex(from,to)		/* returns length >=1 */
register char *from;		/* null-term'd ascii hex string (<= 23 chars) */
register char *to;		/* binary string, must have at least 1 byte */
{
	int leng;
	register unsigned int ch1,ch2;
	int val1,val2;

	to[leng=0]=0;
	while (1)
	{
		ch1=*from++;
		val1= hexvalue(ch1);
		if (val1<0) break;	/* start of comment or null terminator */
		ch2= *from++;
		val2= hexvalue(ch2);
		if (val2<0) break;	/* start of comment or null terminator */
		to[leng++]= 16*val1 + val2;
	}

	if (leng<1) leng=1;
	return leng;
}	/* end converthex() */

/* handle keyboard input ....................................................*/
/* returns equivalent object */
/* change these:  <Control> + first letter of button name !!! */

macro_key(key)
int key;		/* high byte is scan code, low byte is ascii */
{
	register unsigned i;
	register int scan,asci;
	int m,b,c,x;
	register char *charptr;
	int val[8];
	int error=0;

	scan= key>>8;
	asci= key&0xff;

	if (asci==0x1b) return MACREXIT;			/* esc = exit */

	if (asci==0x0d)
	{
		error=1;
		i = 1 + (cursor_y-macro_y)/charh;				/* next row # (0-19) */
		if (i<=19)
		{
			if (line_m[i]>=0)
			{
				disp_cursor();
				cursor_m= line_m[i];
				cursor_b= line_b[i];
				cursor_c= 0;
				findxy(cursor_m,cursor_b,cursor_c,&cursor_x,&cursor_y);
				disp_cursor();
				error=0;
			}
		}
		if (error) Cconout(7);
		return -1;
	}

	switch (scan)
	{
		case 0x0f:
		return MACRFIND;

		case 0x4d:	/* cursor forward */

		disp_cursor();
		cursorfor(asci==0x36);
		disp_cursor();
		break;

		case 0x4b:	/* cursor backward */

		disp_cursor();
		cursorrev(asci==0x34);
		disp_cursor();
		break;

		case 0x50:

		if (asci==0x32)		/* shift-down */
			scrolldisp(1);
		else
		{
			for (i=1; i<20; i++)
			{
				if (findmbc(cursor_x,cursor_y+i*charh,&m,&b,&c))
				{
					disp_cursor();
					cursor_m=m;
					cursor_b=b;
					cursor_c=c;
					cursor_y+= (i*charh);
					disp_cursor();
					break;
				}
			}
		}
		break;

		case 0x48:

		if (asci==0x38)		/* shift-up */
			scrolldisp(0);
		else
		{
			for (i=1; i<20; i++)
			{
				if (findmbc(cursor_x,cursor_y-i*charh,&m,&b,&c))
				{
					disp_cursor();
					cursor_m=m;
					cursor_b=b;
					cursor_c=c;
					cursor_y-= (i*charh);
					disp_cursor();
					break;
				}
			}
		}
		break;

		case 0x52:	/* insert */
		for (i=b=0; i<cursor_m; i++) b+=macroleng[i];
		b+=cursor_b;
		if (asci==0x30) b++;		/* shift-insert: insert after cursor */
		if (macrused<MACRLENG)
		{
			macroleng[cursor_m]++;
			for (i=MACRLENG-1; i>b; i--) macropool[i]= macropool[i-1];
			macropool[b]=0;
			disp_macro();
			cursor_c=0;
			findxy(cursor_m,cursor_b,cursor_c,&cursor_x,&cursor_y);
			disp_cursor();
			calc_used();
			draw_object(macraddr,MACRUSED);
			draw_object(macraddr,MACRLEFT);
			change_flag[macrCHANGE]=1;
		}
		else
			Cconout(7);
		break;
		
		case 0x53:	/* delete */
		for (i=b=0; i<cursor_m; i++) b+=macroleng[i];
		b+=cursor_b;
		if (macroleng[cursor_m]>1)
		{
			macroleng[cursor_m]--;
			for (b++; b<MACRLENG; b++) macropool[b-1]= macropool[b];
			disp_macro();
			if (findmbc(cursor_x,cursor_y,&m,&b,&c))
			{
				cursor_m=m;
				cursor_b=b;
				cursor_c=c;
			}
			else
			{
				cursor_b--;
				cursor_c=0;
				findxy(cursor_m,cursor_b,cursor_c,&cursor_x,&cursor_y);
			}
			disp_cursor();
			calc_used();
			draw_object(macraddr,MACRUSED);
			draw_object(macraddr,MACRLEFT);
			change_flag[macrCHANGE]=1;
		}
		else
			Cconout(7);
		break;
		
		default:		/* data entry */
		charptr= macropool;
		for (i=0; i<cursor_m; i++) charptr+=macroleng[i];
		charptr+=cursor_b;
		i= *charptr;	/* default: no change */
		if (ascimode)
		{
			if ((asci>=0x20)&&(asci<=0x7E))
				i= asci;
			else
				error=1;
		}
		else
		{
			switch (macromode)
			{
				case FMT_HEX:
				val[0]= i/16;
				val[1]= i%16;
				error=1;
				if ( (asci>='0') && (asci<='9') )
				{	val[cursor_c]= asci-'0';		error=0; }
				if ( (asci>='A') && (asci<='F') )
				{	val[cursor_c]= asci-'A'+10;	error=0; }
				if ( (asci>='a') && (asci<='f') )
				{	val[cursor_c]= asci-'a'+10;	error=0;	}
				i= 16*val[0] + val[1];
				break;
				
				case FMT_DEC:
				if ( (asci>='0') && (asci<='9') )
				{
					val[0]= i/100;
					val[1]= (i-100*val[0])/10;
					val[2]= i%10;
					val[cursor_c]= asci-'0';
					i= 100*val[0] + 10*val[1] + val[2];
					if (i>255) error=1;
				}
				else
					error=1;
				break;

				case FMT_BIN:
				if ( (asci=='0') || (asci=='1') )
				{
					for (c=0; c<8; c++)
						val[c]= BITTEST(7-c,i);
					val[cursor_c]= asci-'0';
					i= 128*val[0] + 64*val[1] + 32*val[2] + 16*val[3] +
						  8*val[4] +  4*val[5] +  2*val[6] +    val[7];
				}
				else
					error=1;
			}
		}
		if (error)
			Cconout(7);
		else
		{
			if ( (*charptr) != i ) change_flag[macrCHANGE]=1;
			*charptr= i;
			x= cursor_x;
			for (c=cursor_c; c>0; c--) x--;
			disp_1mac(i,x,cursor_y);
			if ( cursor_b < (macroleng[cursor_m]-1) )
				cursorfor(0);
			else
			{
				if (!ascimode && (cursor_c!=(chpermode[macromode]-1)) )
					cursorfor(0);
			}
			disp_cursor();
		}
	}	/* end switch */
	return -1;
}	/* end macro_key() */

/* find screen coords of given macro/byte/character .........................*/

findxy(m,b,c,x,y)		/* returns 1 if on screen, 0 if not */
int m,b,c;				/* macro, byte, character */
int *x,*y;				/* returned column # and y-coord */
{
	register int i,j;

	for (i=0; i<20; i++)
		if (m==line_m[i])
			for (j=0; j<line_n[i]; j++)
				if (b==line_b[i]+j)
				{
					*x= macro_x + j*(chpermode[macromode]+1) + c;
					*y= macro_y + i*charh;
					return 1;
				}
	return 0;
}	/* end findxy() */

/* find macro/byte/character of given screen coords .........................*/

findmbc(x,y,m,b,c)	/* returns 1 if valid, 0 if not */
int x,y;					/* column # and y-coord */
int *m,*b,*c;			/* returned macro, byte, character */
{
	y = (y-macro_y)/charh;					/* row # (0-19) */
	if ( (y<0) || (y>19) ) return 0;		/* bad row */
	if (line_m[y]<0) return 0;				/* empty row */
	*m= line_m[y];

	*b = (x-macro_x)/(chpermode[macromode]+1);	/* byte offset into line */
	if ( (*b) >= line_n[y] ) return 0;	/* too far to right */
	*b += line_b[y];
	*c= ascimode ? 0 : (x-macro_x)%(chpermode[macromode]+1) ;
	if ( (*c) >= chpermode[macromode] ) return 0;
	return 1;
}	/* end findmbc() */

/* home cursor ..............................................................*/

home_cursor()
{
	cursor_m= home_m;
	cursor_b= home_b;
	cursor_c= 0;
	cursor_x= macro_x;
	cursor_y= macro_y;
}	/* end home_cursor() */

/* clear out display area ...................................................*/

blankarea()
{
	int w,h;

	w= macraddr[MACRAREA].ob_width / charw;
	h= macraddr[MACRAREA].ob_height;
	gr_fill(macro_x,macro_x+w-1,macro_y,macro_y+h-1,0);
}	/* end blankarea() */

/* scroll by macro ..........................................................*/

scrolldisp(dir)
int dir;			/* 0 for down, 1 for up */
{
	if ( !dir && !home_m ) return;
	if ( dir && (home_m==NMACROS-1) ) return;

	home_m+= (dir ? 1 : -1);
	home_b= 0;
	disp_macro();
	if (!findxy(cursor_m,cursor_b,cursor_c,&cursor_x,&cursor_y))
	{
		if (dir)
			home_cursor();
		else
		{
			cursor_x= macro_x;
			cursor_y= macro_y + 19*charh;
			findmbc(cursor_x,cursor_y,&cursor_m,&cursor_b,&cursor_c);
		}
	}
	disp_cursor();
}	/* end scrolldisp() */

/* find a particular macro ..................................................*/

findmacro()
{
	register int i,temp;

	/* clear out entire area */
	blankarea();

	gr_text(MFINDMSG,macro_x,macro_y);	/* prompt for key */
	i= Crawcin()>>16;	/* scan code */
	sel_obj(0,macraddr,MACRFIND);
	draw_object(macraddr,MACRFIND);
	for (temp=0; temp<NMACROS; temp++)
		if (i==macroscan[temp]) break;
	if (temp<NMACROS)
	{
		home_m= temp;
		home_b= 0;
		findxy(cursor_m,cursor_b,cursor_c,&cursor_x,&cursor_y);
		home_cursor();
	}
	disp_macro();
	disp_cursor();
}	/* end findmacro() */

/* print all macros .........................................................*/

printmacros()
{
	register m,b;
	register char *charptr;
	register unsigned int i;
	char charbuf[10];
	int leng;

	graf_mouse(BEE_MOUSE);

	leng= chpermode[macromode];
	charptr= macropool;
	printrow=printcol=0;
	for (m=0; m<NMACROS; m++)
	{
		printlfcr();
		printstr(macroasci[m]);		printstr(":   ");
		for (b=0; b<macroleng[m]; b++)
		{
			if (getmouse(&dummy,&dummy))
			{
				printlfcr();
				waitmouse();
				graf_mouse(ARROWMOUSE);
				return;
			}
			i= *charptr++;
			switch (macromode)
			{
				case FMT_HEX: strcpy(charbuf,hextext[i]); break;
				case FMT_DEC: itoa(i,charbuf,3); break;
				case FMT_BIN: btoa(i,charbuf);
			}
			if (ascimode)
			{
				if ( (i>=0x20) && (i<=0x7E) )
				{
					charbuf[leng]=0;
					charbuf[leng-1]=i;
					asm { move.w leng(a6),-(a7) }
					for (leng-=2; leng>=0; leng--) charbuf[leng]=' ';
					asm { move.w (a7)+,leng(a6) }
				}
			}
			strcat(charbuf," ");
			printstr(charbuf);
		}
	}
	printlfcr();
	if (printrow) Cprnout(0x0c);

	graf_mouse(ARROWMOUSE);
}	/* end printmacros() */

printlfcr()
{
	Cprnout(0x0d);
	Cprnout(0x0a);
	printcol=0;
	printrow++;
	if (printrow>60)
	{
		Cprnout(0x0c);
		printrow=0;
	}
}	/* end printlfcr() */

printstr(str)
register char *str;		/* null-term'd */
{
	register int ch;

	if (printcol>70)
	{
		printlfcr();
		printstr("     ");
	}
	while (ch=*str++)
	{
		Cprnout(ch);
		printcol++;
	}
}	/* end printstr() */

#endif

/* EOF */
