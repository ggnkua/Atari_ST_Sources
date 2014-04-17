/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                          Copyright 1990 Tom Bajoras

	module GEM :  interface to GEM, and custom interface

	some of these should be moved to gr.c and misc.c !!!
	organize these into groups, named similarly within each group !!!

	menu_drop, allmenus, menulock
	waitmouse, getmouse, getwmouse, setmouse, mouse_enable
	big_alert
	re_window
	set_clip, set_clip2, rc_intersect
	save_screen, rest_screen

	putdial, do_dial, do_movedial, slide_dial, full_dial, center_dial

	draw_object, menuprompt, whichbutton
	vdi_colors, vdi_font
	set_slider, set_rbutton, fix_icons, text_edit
	v_gtext, pop_up, hndl_slider, getNumber
	encodefname, decodefname
	sel_obj, is_obj_sel, ena_obj

******************************************************************************/

overlay "gem"

/* include header files .....................................................*/

	/* standard */
#include <osbind.h>		/* GEMDOS, BIOS, XBIOS */
#include <gemdefs.h>		/* AES */
#include <obdefs.h>		/* more AES */

	/* program-specific */
#include "defines.h"		/* miscellaneous */
#include "scan.h"			/* keyboard scan codes */
#include "genedit.h"		/* created by RCS */
#include "externs.h"		/* global variables */

/* extern ...................................................................*/

	/* declared in AESBIND (in syslib) */
extern int *pioff, *iioff, *pooff, *iooff;
extern int int_in[],int_out[],control[],global[];
extern long addr_in[], addr_out[];

/* enable/disable menu drop-down ............................................*/

menu_drop(onoff)
int onoff;		/* 0 to enable drop down, 1 to disable */
{
	static int menuflag=0;	/* start with drop down enabled */

	if (onoff!=menuflag)
	{
		wind_update(onoff);
		menuflag=onoff;
	}
}	/* end menu_drop() */

/* wait for mouse buttons to be released ....................................*/
/* pass it an argument: waiting for buttons up or down, use throughout !!! */

waitmouse()
{
	int dumbbuf[8];

	do
		evnt_multi(MU_MESAG|MU_KEYBD|MU_TIMER,0L,0L,0L,0L,0L,0L,0,
				 dumbbuf,0L,&dummy,&dummy,&dummy,&dummy,&dummy,&dummy);
	while (getmouse(&dummy,&dummy));
}  /* end waitmouse() */

/* get mouse position and buttons state .....................................*/
/* returns buttons state: 0/1/2/3 = none/left/right/both */

getmouse(mx,my)
int *mx,*my;
{
	*mx= *Mousex;
	*my= *Mousey;
	return *Mstate&3;
}	/* end getmouse() */

/* get mouse position and buttons state (auto-repeat) .......................*/
/* returns buttons state: 0/1/2/3 = none/left/right/both */

getwmouse(mx,my)
int *mx,*my;
{
	static int last_state;
	int this_state;
	int i;

	*mx= *Mousex;
	*my= *Mousey;
	this_state= *Mstate&3;
	if (this_state)
	{
		if (last_state==1)
		{
			mouse_wait(mrpt_delay);	/* delay */
			last_state=2;
		}
		if (last_state==2) mouse_wait(mrpt_rate);	/* repeat */
		if (last_state==0) last_state=1;
	}
	this_state= *Mstate&3;
	if (!this_state) last_state=0;
	return this_state;
}	/* end getwmouse() */

mouse_wait(time)
register int time;
{
	asm {
		move.l	Mstate(a4),a0
		move.l	HZ200,d0
	mouse_loop:
		move.b	(a0),d2
		andi.b	#3,d2
		beq		mouse_end
		move.l	HZ200,d1
		sub.l		d0,d1
		cmp.w		time,d1
		blt		mouse_loop
	mouse_end:
	}
}	/* end mouse_wait() */

/* poke mouse position ......................................................*/

setmouse(mx,my)
int mx,my;
{
	if (mx>=0) *Mousex= mx;
	if (my>=0) *Mousey= my;
	HIDEMOUSE; SHOWMOUSE;
}	/* end setmouse() */

/* big alert box ............................................................*/
/* returns exit button # (>=1) */

big_alert(def,str1,str2,str3)
int def;
char *str1,*str2,*str3;
{
	char alertstr[200];

	strcpy(alertstr,str1);
	if (str2) strcat(alertstr,str2);
	if (str3) strcat(alertstr,str3);
	return (form_alert(def,alertstr));
}  /* end big_alert() */

/* redraw window behind a moving desk accessory .............................*/
/* re-do this with set_clip2(), no GRECT nonsense, no rc_intersect() !!! */

re_window(x,y,w,h)
int x,y,w,h;
{
	GRECT t1,t2;
	MFDB scrfdb,savedfdb;
	int xyarray[8];
	int y2=200*rez-1;
	
	scrfdb.fd_addr=    0L;
	savedfdb.fd_addr=  scrsave;
	scrfdb.fd_w=       savedfdb.fd_w=       640;
	scrfdb.fd_h=       savedfdb.fd_h=       200*rez;
	scrfdb.fd_wdwidth= savedfdb.fd_wdwidth= 40;
	scrfdb.fd_stand=   savedfdb.fd_stand=   0;
	scrfdb.fd_nplanes= savedfdb.fd_nplanes= 3-rez;

	xyarray[0]= 0;   xyarray[1]= 0;
	xyarray[2]= 639; xyarray[3]= y2-8*rez+1;
	xyarray[4]= 0;   xyarray[5]= 8*rez+3;
	xyarray[6]= 639; xyarray[7]= y2;
		
	t2.g_x= x;
	t2.g_y= y;
	t2.g_w= w;
	t2.g_h= h;

	HIDEMOUSE;

/* get the first rectangle in this window's rectangle list */
	wind_get(windhndl,WF_FIRSTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
	while (t1.g_w && t1.g_h)  /* loop until a null entry in rectangle list */
	{
/* find intersection (if any) of the update rect. and the rect. from list */
		if (rc_intersect(&t2,&t1))
		{
/* blit the portion of window lying within the intersection area */
			set_clip( t1.g_x, t1.g_y, t1.g_w, t1.g_h );
			intin[0] = 3;   /* write mode = replace */
			pioff= xyarray;
			contrl[0]= 109;
			contrl[1]= 4;
			contrl[3]= 1;
			contrl[6]= gl_hand;
			*(long*)(&contrl[7])= (long)(&savedfdb);
			*(long*)(&contrl[9])= (long)(&scrfdb);
			vdi();             /* vro_cpyfm() */
			pioff= ptsin;
		}   
/* get next rectangle in this window's rectangle list */
		wind_get(windhndl,WF_NEXTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
	}
	vs_clip(gl_hand,0,0L);	/* no clipping */

	SHOWMOUSE;

}  /* end re_window() */

/* set VDI clipping rectangle ...............................................*/
/* change args to x1,y1,x2,y2 !!! */

set_clip(x,y,w,h)
int x,y,w,h;
{
	ptsin[0]= max(x,0);
	ptsin[1]= max(y,0);
	ptsin[2]= min(x+w-1,639);
	ptsin[3]= min(y+h-1,200*rez-1);
	intin[0]= 1;
	contrl[0]= 129;
	contrl[1]= 2;
	contrl[3]= 1;
	contrl[6]= gl_hand;
	vdi();
}  /* end set_clip() */

/* intersect VDI clipping rectangle .........................................*/

set_clip2(x1,y1,x2,y2,x1c,y1c,x2c,y2c)
int x1,y1,x2,y2;
int *x1c,*y1c,*x2c,*y2c;
{
	int w,h;

	*x1c= max(x1,*x1c); *x2c= min(x2,*x2c);
	*y1c= max(y1,*y1c); *y2c= min(y2,*y2c);
	w= *x2c - *x1c + 1;
	h= *y2c - *y1c + 1;
	if ((w>0)&&(h>0))
	{
		set_clip(*x1c,*y1c,w,h);
		return 1;
	}
	else
		return 0;
}	/* end set_clip2() */

/* find intersection of two rectangles ......................................*/
/* returns non-0 if two rectangles intersect, 0 if they don't */

rc_intersect(p1,p2)
register GRECT *p1,*p2;
{
	register int tx, ty, tw, th;

	tw = min(p2->g_x + p2->g_w, p1->g_x + p1->g_w);
	th = min(p2->g_y + p2->g_h, p1->g_y + p1->g_h);
	p2->g_x= tx= max(p2->g_x, p1->g_x);
	p2->g_y= ty= max(p2->g_y, p1->g_y);
	p2->g_w = tw - tx;
	p2->g_h = th - ty;
	return (tw > tx) && (th > ty) ;
}  /* end rc_intersect() */

/* save/restore screen to/from scrsave ......................................*/

extern save_screen();
extern rest_screen();
asm {				/* 4(a7).w = y1 , 6(a7).w = y2 */
save_screen:
	move.w	#0x22d8,d0		;	= move.l (a0)+,(a1)+
	bra		sv_or_rst
rest_screen:
	move.w	#0x20d9,d0		;	= move.l (a1)+,(a0)+
sv_or_rst:
	lea		selfmod(PC),a0
	move.w	d0,(a0)

	move.l	a2,d3
	dc.w		0xA00A				;	hide mouse
	move.l	d3,a2

	movea.l	scrbase(a4),a0
	moveq		#3,d1
	sub.w		rez(a4),d1
	move.w	4(a7),d0
	mulu		#80,d0
	mulu		d1,d0
	adda.w	d0,a0					; a0 --> source area
	mulu		#20,d1
	subq.w	#1,d1 	         ; d1.w= horizontal counter = 19 mono,39 color
	move.w	d1,d3    			; d3.w= initial d1
	move.w	6(a7),d0
	sub.w		4(a7),d0				; d0.w= vertical counter
	movea.l	scrsave(a4),a1		; a1= target area
selfmod:
	nop
	dbf		d1,selfmod
	move.w	d3,d1
	dbf		d0,selfmod

	move.l	a2,d3
	dc.w		0xA009				; show mouse
	move.l	d3,a2
	rts
}  /* end save/rest_screen() */

/* interact with centered dialog box ........................................*/
/* return exit object number */

do_dial(dialaddr,edit_obj)
OBJECT *dialaddr;
int edit_obj;
{
	int exit_obj;
	int savemouse[37];

	putdial(dialaddr,-1,0);

	/* swap in arrow mouse */
	copy_words(Abase-856,savemouse,37L);
	graf_mouse(ARROWMOUSE);

	do
	{
		exit_obj= my_form_do(dialaddr,&edit_obj,&dummy,0,&dummy);
		if (exit_obj==1) slide_dial(dialaddr);
	}
	while (exit_obj==1);

	/* restore mouse icon */
	copy_words(savemouse,Abase-856,37L);
	HIDEMOUSE; SHOWMOUSE;

	putdial(0L,0,exit_obj);
	return exit_obj;
}  /* end do_dial() */

/* interact with movable dialog box .........................................*/
/* return exit object number */

do_movedial(dialaddr,edit_obj,center)
OBJECT *dialaddr;
int edit_obj;
int center;		/* 1= draw dialog box w/ centering, 0= without */
{
	int exit_obj;

	putdial(dialaddr,center ? -1 : 1,0);

	do
	{
		exit_obj= my_form_do(dialaddr,&edit_obj,&dummy,0,&dummy);
		if (exit_obj==1) slide_dial(dialaddr);
	}
	while (exit_obj==1);

	putdial(0L,0,exit_obj);
	return exit_obj;
}	/* end do_movedial() */

/* move a dialog box ........................................................*/

slide_dial(dialaddr)
OBJECT *dialaddr;
{
	int w2,h2,x;

	w2= 639 + dialaddr[0].ob_width ;
	h2= 200*rez - 1 + dialaddr[0].ob_height ;
	HIDEMOUSE;
	slide_box(&(dialaddr[0].ob_x),&(dialaddr[0].ob_y),
					dialaddr[0].ob_width,dialaddr[0].ob_height,
							 0,0,w2,h2,
							 0,0L,0L,0L,0L,0L,0L,0L,0L);
	SHOWMOUSE;

	x= dialaddr[0].ob_x;
	dialaddr[0].ob_x= charw * (x/charw) ;	/* character boundary */
	putdial(0L,0,-1);				/* undraw at old position */
	putdial(dialaddr,1,0);		/* draw at new position */

}	/* end slide_dial() */

/* (un)draw dialog box ......................................................*/

putdial(addr,on_off,exit_obj)
OBJECT *addr;
int on_off; /* 0= undraw, 1= draw without centering, -1 draw with centering */
int exit_obj;
{
	static OBJECT *dial_addr;

	if (on_off)		/* draw */
	{
		save_screen(0,200*rez-1);
		dial_addr= addr;
		if (on_off<0) center_dial(addr);	/* center it */
		objc_draw(addr,ROOT,MAX_DEPTH,0,0,640,200*rez);
	}
	else				/* un-draw */
	{
		waitmouse();	/* prevent print-through from mouse button */
		rest_screen(0,200*rez-1);
		/* deselect exit object */
		if (exit_obj>=0) sel_obj(0,dial_addr,exit_obj);
	}
}	/* end putdial() */

/* center dialog box on screen ..............................................*/
/* use this throughout !!! */

center_dial(dialaddr)
register OBJECT *dialaddr;
{
	int x;
	x= 320 - dialaddr[0].ob_width/2;
	dialaddr[0].ob_x= charw * (x/charw) ;	/* character boundary */
	dialaddr[0].ob_y= 100*rez - dialaddr[0].ob_height/2;
}	/* end center_dial() */

/* make dialog box cover entire screen ......................................*/
/* use this throughout !!! */

full_dial(dialaddr)
register OBJECT *dialaddr;
{
	dialaddr[0].ob_x=	dialaddr[0].ob_y= 0;
	dialaddr[0].ob_width= 640;
	dialaddr[0].ob_height= 200*rez;
}	/* end full_dial() */

/* enable/disable all menu entries ..........................................*/

allmenus(onoff)
int onoff;			   /* 1 to enable, 0 to disable */
{
	register OBJECT *maddr;
	register int obj,box,i=0;
	static char saveabout,saveable[100];
	int done;
	char *saveptr;

	saveptr= saveable ;

	/* box--> file menu box */
	maddr= menuaddr;
	box= maddr[ maddr[ maddr[1].ob_next ].ob_head ].ob_next;	

	/* handle desk menu separately */
	if (onoff && !saveabout)
		maddr[nmenutitl+5].ob_state &= ~DISABLED ;
	else
	{
		saveabout= maddr[nmenutitl+5].ob_state & DISABLED;
		maddr[nmenutitl+5].ob_state |= DISABLED;
	}

	done=0;
	while (!done)
	{
		obj= maddr[box].ob_head;    /* obj--> first entry in menu */
		do
		{
			if (onoff && !saveptr[i])
				maddr[obj].ob_state &= ~DISABLED ;
			else
			{
				saveptr[i]= maddr[obj].ob_state & DISABLED;
				maddr[obj].ob_state |= DISABLED;
			}
			i++;
			if ( maddr[obj].ob_flags & LASTOB )
				done=1;
			else
				obj= maddr[obj].ob_next;
		}
		while ( (obj!=box) && !done ) ;
		box= maddr[box].ob_next;
	}  /* end while (!done) */

}  /* end allmenus() */

/* any menu currently dropped down? .........................................*/
/* returns non-0 = yes, 0= no */

menulock()
{
	register OBJECT *tree;
	int result=0;

	/* look for first title */
	for (tree=menuaddr; tree[0].ob_type!=G_TITLE; tree++) ;

	/* any titles selected? */
	for (; (tree[0].ob_type==G_TITLE)&&!result; tree++)
		if (tree[0].ob_state&SELECTED) result=1;

	return result;

}  /* end menulock() */

/* draw a single object in a tree ...........................................*/

draw_object(tree,obj)
OBJECT *tree;
int obj;
{
	int x,y,w,h;

	objc_offset(tree,obj,&x,&y);
	w= tree[obj].ob_width;
	h= tree[obj].ob_height;
	objc_draw(tree,ROOT,MAX_DEPTH,x,y,w,h);	/* too slow !!! */
}	/* end draw_object() */

/* scan through a tree, double height of any ICON ...........................*/
/* use this throughout !!! */

fix_icons(tree)
register OBJECT *tree;
{
	register int i;

	for (i=0; !(tree[i].ob_flags&LASTOB); i++)
		if ( (tree[i].ob_type==G_ICON) || (tree[i].ob_type==G_IMAGE) )
			tree[i].ob_height *= 2;

}	/* end fix_icons() */

/* use menu bar for prompt ..................................................*/

menuprompt(ptr)
char *ptr;			/* --> prompt, null to restore menu bar, -1L reset */
{
	static int menu_save[800];
	static char saved;

	if ( (long)(ptr) < 0L ) { saved=0; return; }			/* reset */

	HIDEMOUSE;
	if (ptr)
	{
		if (!saved) copy_words(scrbase,menu_save,800L);	/* save prompt area */
		set_words(scrbase,800L,0xFFFF);						/* black it */
		gr_color= WH_ON_BL;
		gr_text(ptr,40-strlen(ptr)/2,1);						/* centered */
		gr_color= BL_ON_WH;
		saved=1;
	}
	else
	{
		if (saved) copy_words(menu_save,scrbase,800L);	/* restore prompt area */
		saved=0;
	}
	SHOWMOUSE;
}	/* end menuprompt() */

/* which of a set of radio buttons is selected ..............................*/
/* returns 0-(n-1), -1 if none */

whichbutton(tree,button0,n)
register OBJECT *tree;
int button0,n;	/* obj # of 1st button in set, # of buttons in set */
{
	register int i;
	
	for (i=0; i<n; i++)
		if ( tree[button0+i].ob_state & SELECTED ) return i;
	return -1;

}	/* end whichbutton() */

/* set one of a set of radio buttons ........................................*/

set_rbutton(tree,button0,n,which)
register OBJECT *tree;
int button0,n;	/* obj # of 1st button in set, # of buttons in set */
int which;		/* which button to be set */
{
	register int i;
	
	for (i=0; i<n; i++,button0++) sel_obj(i==which,tree,button0);

}	/* end set_rbutton() */

/* turn mouse on and off ....................................................*/

mouse_enable(flag)
int flag;	/* 1= on, 0= off */
{
	char str;

	if (flag)
	{ SHOWMOUSE }
	else
	{ HIDEMOUSE }

	/* don't enable/disable mouse if running under midi operating system */
	if (midi_opsys) return;

	*(char*)(Abase-339)= !flag;	/* gem mouse enable/disable */
	str= flag ? 0x08 : 0x12 ;		/* enable/disable cmds for ikbd */
	Ikbdws(0,&str);
}	/* end mouse_enable() */

/* set vdi colors ...........................................................*/

vdi_colors(color)
int color;
{
	asm {
		move.w color(a6),-(a7)
		move.w gl_hand(a4),-(a7)
	}
	vsl_color();
	vst_color();
	vsf_color();
	vsm_color();
	asm { addq.w #4,a7 }
}	/* end vdi_colors() */

/* set font for v_gtext .....................................................*/

vdi_font(font)
register int font;	/* 1= mini, 0= normal */
{
	if (rez==1)
		vst_height(gl_hand,font ? 4 : 6,&dummy,&dummy,&dummy,&dummy);
	else
		vst_point( gl_hand,font ? 8 :13,&dummy,&dummy,&dummy,&dummy);
	if (font)
	{
		charh= 6*rez;
		charw= 6;
	}
	else
	{
		charh= 8*rez;
		charw= 8;
	}
	gl_font=font;

} /* end vdi_font() */

/* size and position a slider ...............................................*/

set_slider(n,ndisp,home,y,h,hmin,h_out,y_out)
int n;		/* how many things there are (>=0) */
int ndisp;	/* how many things can be displayed at once (>0) */
int home;	/* which thing is first in window (>=0) */
int y;		/* slider home position */
int h;		/* slider full size */
int hmin;	/* slider minimum size */
int *h_out;	/* computed slider size */
int *y_out;	/* computed slider position */
{
	int ntemp,htemp,ymax;

	if (n>1)
	{
		ntemp= min(n,ndisp);			/* how many are displayed */
		htemp= (long)(ntemp*h)/n;	/* beware of sign extension */
		*h_out= htemp= max(hmin,htemp);
		ymax= y + h - htemp ;
		*y_out= y + ((long)(ymax-y)*home)/(n-1) ;	/* beware of sign extension */
	}
	else
	{
		*h_out= h;
		*y_out= y;
	}
}	/* end set_slider() */

/* custom vdi text ..........................................................*/

v_gtext( handle, x, y, string)
int handle;
int x;
int y;
char *string;
{
	int i;

	/* mini font shifted down in mono */
	if ((rez==2)&&(gl_font==1)) y+=3;

	ptsin[0] = x;
	ptsin[1] = y;
	i = 0;
	while (intin[i++] = *string++) ;

	contrl[0] = 8;
	contrl[1] = 1;
	contrl[3] = --i;
	contrl[6] = handle;
	vdi();
}	/* end v_gtext() */

/* edit a text field, with horizontal scrolling .............................*/
/* returns new offset */
/* use throughout !!! */

text_edit(key,kstate,ptr,leng,offset,fmt)
register int key;		/* high byte scan, low byte ascii, <=0 special */
int kstate;
char *ptr;	/* --> string to be edited, null-term'd */
int leng;	/* # chars in string to be edited, not including null term */
int offset;		/* in/out:  char # at left edge of display (>=0) */
TEXTEDFMT *fmt;
{
	static int curs;	/* 0 in first column */
	int scan;
	char buf[81];
	register int i,j;
	int x,y,w,spacing;
	char *valid;

	/* text editing structure */
	x= fmt->x;
	y= fmt->y;
	w= fmt->w;
	valid= fmt->valid;
	spacing= max(fmt->spacing,1);
	w= (w*spacing)/(fmt->spacing+1);

	if (key==0)		/* initialize */
	{
		text_eddraw(ptr,leng,offset,curs=0,fmt);
		return offset;
	}
	if (key==(-1)) /* finishup: draw without cursor */
	{
		text_eddraw(ptr,leng,offset,-1,fmt);
		return offset;
	}
	scan= key>>8;	/* scan code */
	key &= 0xFF;	/* ascii */

	switch (scan)
	{
		case SCAN_ESC:
		set_bytes(ptr,leng+1L,0);	/* clear string, including null term */
		text_eddraw(ptr,leng,offset=0,curs=0,fmt);
		break;

		case SCAN_CRIGHT:	/* find null at end of string */
		for (offset=0; ; offset++) if (!ptr[offset]) break;
		offset= spacing*(offset/spacing);
		for (curs=0; ; curs++) if (!ptr[offset+curs]) break;
		if (!curs && offset)
		{
			offset -= spacing;
			curs += spacing;
		}
		text_eddraw(ptr,leng,offset,curs,fmt);
		break;

		case SCAN_RIGHT:
		if (!ptr[offset+curs]) break;	/* cursor can't be beyond null-term */
		if ( (kstate==K_RSHIFT) || (kstate==K_LSHIFT) )
		{
			if ((offset+spacing)<leng)
			{
				offset += spacing ;
				if (!ptr[offset+curs])	/* cursor can't be beyond null-term */
				{
					while (!ptr[offset+curs]) curs--;
					curs++;
				}
				text_eddraw(ptr,leng,offset,curs,fmt);
			}
			break;
		}
		if ( (offset+curs) < (leng-1) )
		{
			if (curs>=(w-1))
				offset= text_edit(SCAN_RIGHT<<8,K_LSHIFT,ptr,leng,offset,fmt);
			else
			{
				HIDEMOUSE;
				text_edcurs(curs,fmt);
				curs++;
				text_edcurs(curs,fmt);
				SHOWMOUSE;
			}
		}
		break;

		case SCAN_CLEFT:
		text_eddraw(ptr,leng,offset=0,curs=0,fmt);
		break;
		
		case SCAN_LEFT:
		if ( (kstate==K_RSHIFT) || (kstate==K_LSHIFT) )
		{
			if ((offset-spacing)>=0)
			{
				offset -= spacing;
				text_eddraw(ptr,leng,offset,curs,fmt);
			}
			break;
		}
		if (offset+curs)
		{
			if (!curs)
			{
				curs += (spacing-1);
				offset= text_edit(SCAN_LEFT<<8,K_LSHIFT,ptr,leng,offset,fmt);
			}
			else
			{
				HIDEMOUSE;
				text_edcurs(curs,fmt);
				curs--;
				text_edcurs(curs,fmt);
				SHOWMOUSE;
			}
		}
		break;
		
		case SCAN_BS:
		if (offset+curs)
		{
			offset= text_edit(SCAN_LEFT<<8,0,ptr,leng,offset,fmt);
			offset= text_edit(SCAN_DEL<<8 ,0,ptr,leng,offset,fmt);
		}
		break;
		
		case SCAN_DEL:
		if ( (kstate==K_LSHIFT) || (kstate==K_RSHIFT) )
			for (i=offset+curs; i<leng; i++) ptr[i]=0;
		else
		{
			for (i=offset+curs; i<leng-1; i++) ptr[i]=ptr[i+1];
			ptr[i]=0;
		}
		text_eddraw(ptr,leng,offset,curs,fmt);
		break;
		
		default:
		if (text_edvalid(key,valid))
		{
			ptr[offset+curs]=key;
			text_eddraw(ptr,leng,offset,curs,fmt);
			offset= text_edit(SCAN_RIGHT<<8,0,ptr,leng,offset,fmt);
		}
		else
			if (fmt->bell) Cconout(7);	/* optionally ring bell for invalid */
	}	/* end switch (scan) */

	return offset;
}	/* end text_edit() */

text_eddraw(ptr,leng,offset,curs,fmt)
char *ptr;
int leng,offset,curs;
TEXTEDFMT *fmt;
{
	register int i,j,ch;
	int x,y,w,sp;
	char buf[81];

	x= fmt->x;
	y= fmt->y;
	w= fmt->w;
	sp= fmt->spacing;

	ch=1;
	for (i=0,j=offset; (i<w)&&(j<leng); j++)
	{
		if ( (sp&&i) && !((j-offset)%sp) ) buf[i++]= fmt->spacechar;
		if (i==w) break;
		if (ch) ch=ptr[j];
		buf[i++]= ch ? ch : fmt->fillchar;
	}
	for (; i<w; i++) buf[i]=' ';
	buf[w]=0;
	gr_text(buf,x,y);
	if (curs>=0) text_edcurs(curs,fmt);
}	/* end text_eddraw() */

text_edcurs(curs,fmt)
int curs;
TEXTEDFMT *fmt;
{
	int x,y,sp;

	x=fmt->x;
	y=fmt->y;
	sp=fmt->spacing;
	if (sp) curs += (curs/sp);
	HIDEMOUSE;
	xorchar(x+curs,y);
	SHOWMOUSE;
}	/* end text_edcurs() */

text_edvalid(key,valid)
register int key;			/* printable ascii */
register char *valid;	/* null-term'd list, or null */
{
	register int ch;

	if (!valid) return key>0;
	while (ch=*valid++)
		if (key==ch) return 1;
	return 0;
}	/* end text_edvalid() */

/* select/deselect an object ................................................*/
/* use this throughout !!! */

sel_obj(state,tree,obj)
int state;
OBJECT *tree;
int obj;
{
	if (state)
		tree[obj].ob_state |= SELECTED ;
	else
		tree[obj].ob_state &= ~SELECTED ;
}	/* end sel_obj() */

/* enable/disable an object .................................................*/
/* use this throughout !!! */

ena_obj(state,tree,obj)
int state;				/* 0= disable object, else enable it */
OBJECT *tree;
int obj;
{
	if (state)
		tree[obj].ob_state &= ~DISABLED ;
	else
		tree[obj].ob_state |=  DISABLED ;
}	/* end ena_obj() */

/* is object selected? ......................................................*/
/* returns 1= yes, 0= no */
/* use this throughout !!! */

is_obj_sel(tree,obj)
OBJECT *tree;
int obj;
{
	return tree[obj].ob_state & SELECTED ? 1 : 0 ;
}	/* end is_obj_sel() */

/* functions for (de)select and redraw an object !!! */

/* !!!...
getkstate()
{
	register int i;

	i= Kbshift(-1);
	i &= (K_LSHIFT|K_RSHIFT|K_ALT|K_CTRL) ;
	if (i&K_LSHIFT) i |= K_RSHIFT ;
	if (i&K_RSHIFT) i |= K_LSHIFT ;
	i &= ~K_RSHIFT;
	return i;
}
...!!! */

/* get a number .............................................................*/
/* returns signed integer */

getNumber(title,low,high,def)
char *title;
int low,high,def;
{
	char *ptr;
	int val,error;

	strcpy(((TEDINFO*)(getnaddr[GETNTITL].ob_spec))->te_ptext,title);
	ptr= ((TEDINFO*)(getnaddr[GETNLOW ].ob_spec))->te_ptext;
	itoa(low,ptr,-1);
	ptr= ((TEDINFO*)(getnaddr[GETNHIGH].ob_spec))->te_ptext;
	itoa(high,ptr,-1);
	ptr= ((TEDINFO*)(getnaddr[GETNVAL].ob_spec))->te_ptext;
	itoa(def,ptr,-1);

	do_dial(getnaddr,GETNVAL);

	val= atoii(ptr,&error);
	if (error) val=def;
	if (val<low) val=low;
	if (val>high) val=high;

	return val;

}	/* end getNumber() */

/* universal popup selector .................................................*/
/* returns choice # (-1 = none) */

pop_up(title,choice,n,fixptr,inter,varptr)
char *title; 			/* title for dialog box */
int choice; 			/* current choice #, -1 for none */
int n;    				/* how many in list */
	/* method 1: */
char *fixptr; 		/* --> first string (strings all null-term'd) */
int inter;			/* offset from start of one string to next, 0 for method 2 */
	/* method 2: */
char *varptr[];	/* pointers to strings (each one null-term'd) */
{
	register int i;
	int edit_obj,exit_obj,mstate,mousey,done;
	int nrows,home_y,y,h;
	static int home;
	int savemouse[37];

	/* title */
	((TEDINFO*)(popaddr[POPTITL].ob_spec))->te_ptext=title;

	/* how many rows can fit in display area?  round off the area's height */
	h= popaddr[POPAREA].ob_height;
	nrows= h / charh ;
	h= nrows * charh;
	i= h - popaddr[POPAREA].ob_height;
	popaddr[POPAREA].ob_height += i;
	popaddr[POPSCROL].ob_height += i;
	popaddr[POPDOWN].ob_y += i;

	if (choice>=0)
	{
		home= choice;
		home= home<nrows ? 0 : home-nrows/2 ;
	}
	else
		home= min(home,n-1);
	if (n<=nrows) home=0;
	pop_slider(0,n,nrows,home);

	/* draw dialog box shell */
	putdial(popaddr,-1,0);
	objc_offset(popaddr,POPAREA,&dummy,&home_y);

	/* fill in dialog box */
	pop_draw(home,n,nrows,choice,fixptr,inter,varptr);

	/* swap in arrow mouse */
	copy_words(Abase-856,savemouse,37L);
	graf_mouse(ARROWMOUSE);

	edit_obj= -1;
	done=0;
	do
	{
		exit_obj= my_form_do(popaddr,&edit_obj,&mstate,0,&dummy);
		getmouse(&dummy,&mousey);
		switch (exit_obj)
		{
			case CANPOP:	choice= -1;
			case OKPOP:		done=  1; break;

			case POPUP:
			case POPDOWN:
			if (n<=nrows) break;
			i= home + (exit_obj==POPUP ? -1 : 1 ) ;
			if ((i>=0)&&(i<n))
			{
				home=i;
				pop_slider(1,n,nrows,home);
				pop_draw(home,n,nrows,choice,fixptr,inter,varptr);
				mstate=0;
			}
			break;

			case POPSLIDE:
			if (n<=nrows) break;
			i= hndl_slider(home,n,popaddr,POPSLIDE,POPSCROL);
			if (i!=home)
			{
				pop_slider(1,n,nrows,home=i);
				pop_draw(home,n,nrows,choice,fixptr,inter,varptr);
			}
			break;
			
			case POPSCROL:		/* scroll list by half screen */
			if (n<=nrows) break;
			i= mousey;
			objc_offset(popaddr,POPSLIDE,&dummy,&y);
			i= i<y ? -nrows/2 : nrows/2 ;
			i += home;
			if (i<0) i=0;
			if (i>=n) i= n-1;
			pop_slider(1,n,nrows,home=i);
			pop_draw(home,n,nrows,choice,fixptr,inter,varptr);
			mstate=0;
			break;

			case POPAREA:
			i= home + (mousey - home_y) / charh ;
			if ((i>=0)&&(i<n))
			{
				if (i!=choice) pop_draw(home,n,nrows,choice=i,fixptr,inter,varptr);
				if (mstate>0) done=1;	/* R-click= select + OK */
			}
		}
		if (mstate) waitmouse();
	}
	while (!done);
	putdial(0L,0,exit_obj);

	/* restore mouse icon */
	copy_words(savemouse,Abase-856,37L);

	return choice;

}	/* end pop_up() */

pop_slider(draw,n,nrows,home)
int draw,n,nrows,home;
{
	int h= popaddr[POPSCROL].ob_height;
	int w= popaddr[POPSCROL].ob_width;

	set_slider(n,nrows,home,0,h,w,
				&popaddr[POPSLIDE].ob_height,&popaddr[POPSLIDE].ob_y);
	if (draw) draw_object(popaddr,POPSCROL);
}	/* end pop_slider() */

pop_draw(home,n,nrows,curr,fixptr,inter,varptr)
int home;
int n;    		/* how many in list */
int nrows;		/* how many can be displayed at once */
int curr; 		/* current choice #, -1 for none */
	/* method 1: */
char *fixptr; 		/* --> first string (strings all null-term'd) */
int inter;			/* offset from start of one string to next, 0 for method 2 */
	/* method 2: */
char *varptr[];	/* pointers to strings (each one null-term'd) */
{
	register int i,j;
	register char *ptr;
	int x,y,w;
	char buf[80];	/* oversized */

	objc_offset(popaddr,POPAREA,&x,&y);
	x /= charw ;
	w= popaddr[POPAREA].ob_width / charw ;

	HIDEMOUSE;
	for (i=0; i<nrows; i++,home++,y+=charh)
	{
		set_bytes(buf,(long)w,' ');
		buf[w]=0;
		if (home<n)
		{
			ptr= inter ? fixptr + (long)home*inter : varptr[home] ;
			if ( (long)(ptr) != (-1L) )	/* -1L means null inside text list */
			{
				for (j=0; j<w; j++) if (!(buf[j] = *ptr++)) break;
				pad_str(w,buf,' ');
			}
		}
		gr_text(buf,x,y);
		if (home==curr) xortext(w,x,y);
	}
	SHOWMOUSE;
}	/* end pop_draw() */

/* interact with a slider ...................................................*/
/* returns new home */
/* this can be used throughout -- definitely in ebdt.c !!! */
/* change name -- too easily confused with editor functions !!! */

hndl_slider(home,n,tree,slide_obj,scrol_obj)
int home,n;
OBJECT *tree;
int slide_obj,scrol_obj;
{
	int x1,y1,w1,h1;
	int x2,y2,w2,h2;
	int old_y1,old_x1;
	int ymax,xmax;

	objc_offset(tree,slide_obj,&x1,&y1);
	objc_offset(tree,scrol_obj,&x2,&y2);
	w1= tree[slide_obj].ob_width;
	h1= tree[slide_obj].ob_height;
	w2= tree[scrol_obj].ob_width;
	h2= tree[scrol_obj].ob_height;
	old_y1= y1;
	old_x1= x1;

	slide_box(&x1,&y1,w1,h1,x2,y2,w2,h2,0,0L,0L,0L,0L,0L,0L,0L,0L);
	if ( (h2>w2) && (y1!=old_y1) )	/* vertical slider */
	{
		ymax= y2 + h2 - h1;
		if (ymax!=y2)
			home= ( (long)(y1-y2) * (long)(n-1) ) / (ymax-y2) ;
	}
	if ( (h2<w2) && (x1!=old_x1) )	/* horizontal slider */
	{
		xmax= x2 + w2 - w1;
		if (xmax!=x2)
			home= ( (long)(x1-x2) * (long)(n-1) ) / (xmax-x2) ;
	}
	return home;
}	/* end hndl_slider() */

/* convert from file name to editable text ..................................*/

encodefname(fromptr,toptr)
register char *fromptr,*toptr;
{
	register int i,ch;

	i=0;
	while (ch=*fromptr++)
	{
		if (ch=='.')
			for (; i<8; i++) toptr[i]=' ';
		else
			toptr[i++] = ch;
	}
	toptr[i] = 0;
}	/* end encodefname() */

/* convert from editable text to file name ..................................*/
/* returns 0= ok, 1= error */

decodefname(fromptr,toptr)
register char *fromptr,*toptr;
{
	register int i,ch;

	i=0;
	while (ch=fromptr[i++])
	{
		if (ch!=' ')
		{
			if ( (ch=='_') || (ch=='.') ||
				  ((ch>='0')&&(ch<='9')) ||
				  ((ch>='A')&&(ch<='Z'))
				)
				*toptr++ = ch;
			else
				return 1;
		}
		if (i==8) *toptr++ = '.';
	}
	*toptr = 0;
	return 0;
}	/* end decodefname() */

/* EOF */
