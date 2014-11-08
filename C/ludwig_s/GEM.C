/******************************************************************************

                                    Ludwig

                                      by
                                  Tom Bajoras

                        Copyright 1988 Hybrid Arts, Inc.

	module:	GEM -- interface to GEM

	menu_drop, waitmouse, allmenus, getmouse, menulock, mouserepeat
	do_dial, evnt_null, re_window, set_clip, rc_intersect,
	putdial, big_alert, draw_object, set_rbutton, which_rbutton

******************************************************************************/

overlay "gem"

/* include header files .....................................................*/

#include <asm.h>				  /* needed for in-line assembly language */
#include "defines.h"         /* program-specific */
#include <gemdefs.h>         /* AES                  */
#include <obdefs.h>          /* more AES  */
#include <osbind.h>          /* GEMDOS, BIOS, XBIOS  */
#include "ludwig.h"          /* created by RCS       */

/* global variables .........................................................*/

#include "externs.h"

	/* imported from GEM */
extern int *pioff, *iioff, *pooff, *iooff;
extern int int_in[],int_out[],control[],global[];
extern long addr_in[], addr_out[];

/* declare extern any asm entry points ......................................*/

extern int getmouse(),menulock();

/* enable/disable menu drop-down ............................................*/

menu_drop(onoff)
int onoff;		/* 1 to enable drop down, 0 to disable */
{
	static int menuflag=1;	/* start with drop down enabled */

	if (onoff!=menuflag)
	{
		wind_update(!onoff);
		menuflag=onoff;
#if ALOCKFLAG
		asm {
			move.w	maincrc(a4),d0
			subi.w	#MAINCRC,d0
			adda.w	d0,a7
		}
#endif
	}
}	/* end menu_drop() */

/* wait for mouse buttons to be released ....................................*/

waitmouse()
{
	do
		evnt_null();
	while (3 & *Mstate);
#if ALOCKFLAG
		asm {
			move.w	mainchksum(a4),d0
			subi.w	#MAINCHKSUM,d0
			adda.w	d0,a7
		}
#endif
}  /* end waitmouse() */

/* enable/disable all menu entries except "About..." ........................*/

/*.................... disable/enable all menu items .........................*/

allmenus(onoff)
int onoff;   /* 1 to enable, 0 to disable */
{
	register int obj,box,i=0;
	register OBJECT *maddr=menuaddr;
	static char saveable[50];	/* oversized */
	static char saveabout;

	if (onoff && !saveabout)
		maddr[LUINFO].ob_state &= ~DISABLED ;
	else
	{
		saveabout= maddr[LUINFO].ob_state & DISABLED;
		maddr[LUINFO].ob_state |= DISABLED;
	}

	/* box--> file menu box */
	box= maddr[ maddr[ maddr[1].ob_next ].ob_head ].ob_next;	

	while(1)
	{
		obj= maddr[box].ob_head;    /* obj--> first entry in menu */
		do
		{
			if (onoff && !saveable[i])
				maddr[obj].ob_state &= ~DISABLED ;
			else
			{
				saveable[i]= maddr[obj].ob_state & DISABLED;
				maddr[obj].ob_state |= DISABLED;
			}
			i++;
			if ( maddr[obj].ob_flags & LASTOB ) return;
			obj= maddr[obj].ob_next;
		}
		while (obj!=box);
		box= maddr[box].ob_next;
	}  /* end while (1) */

}  /* end allmenus() */

/* get mouse position and buttons state .....................................*/
/* returns buttons state: 0/1/2/3 = none/left/right/both */

asm {			/* 4(a7) --> where to put x, 8(a7) --> where to put y */
getmouse:
	movea.l	Mousex(a4),a0
	movea.l	4(a7),a1
	move.w   (a0),(a1)
	movea.l	Mousey(a4),a0
	movea.l	8(a7),a1
	move.w	(a0),(a1)
	move.l	Mstate(a4),a0
	move.b	(a0),d0
	andi.w	#3,d0
}
#if ALOCKFLAG
asm {
	move.w	maincrc(a4),d1
	subi.w	#MAINCRC,d1				; obviously this has to come out zero
	adda.w	d1,a7
}
#endif
asm {
	rts
}	/* end getmouse() */

/* any menu currently dropped down? .........................................*/
/* returns non-0 = yes, 0= no */

asm {
menulock:
	clr.w		d0			; default return 0
	movea.l	menuaddr(a4),a0
	adda.w	#6,a0		; --> first object's type
loop1:					; look for first title
	adda.w	#24,a0
	cmpi.w	#G_TITLE,(a0)
	bne		loop1
	movea.l	a0,a1
	addq.l	#4,a1		; --> state
loop2:
	cmpi.w	#G_TITLE,(a0)
	bne		done		; stop when we come to a non-title
	move.w	(a1),d0	; get title's object state
	bne		done		; stop when we come to a selected title
	adda.w	#24,a0	; go to next object in menu tree
	adda.w	#24,a1
	bra		loop2
done:
}
#if ALOCKFLAG
asm {
	move.w	mainchksum(a4),d1
	subi.w	#MAINCHKSUM,d1
	adda.w	d1,a7
}
#endif
asm {
	rts
}  /* end menulock() */

/* delay between mouse auto-repeats .........................................*/

mouserepeat()
{
	evnt_timer(160,0);
}	/* end mouserepeat() */

/* interact with dialog box without touch exits .............................*/
/* return the selected exit object number */

do_dial(dialaddr,edit_obj)
long dialaddr;
int edit_obj;
{
	int exit_obj;

	putdial(dialaddr,1,0);
	exit_obj= my_form_do(dialaddr,&edit_obj,&dummy);
	putdial(0L,0,exit_obj);
#if ALOCKFLAG
	asm {
		move.w	maincrc(a4),d0
		subi.w	#MAINCRC,d0
		adda.w	d0,a7
	}
#endif
	return(exit_obj);
}  /* end do_dial() */

/* (un)draw dialog box ......................................................*/

putdial(addr,on_off,exit_obj)
OBJECT *addr;
int on_off,exit_obj;
{
	static OBJECT *dial_addr;
	static int dial_x,dial_y,dial_w,dial_h;
	int y2,ymax;

	if (on_off)		/* draw dialog box */
	{
		form_center(dial_addr=addr,&dial_x,&dial_y,&dial_w,&dial_h);
		/* don't allow bottom of box to draw beyond screen */
		y2= dial_y+dial_h-1;
		ymax= 200*rez-1;
		if ( y2 > ymax )
		{
			dial_addr[0].ob_y -= (y2-ymax);
			dial_y -= (y2-ymax);
		}
		qsave_screen(dial_y,dial_y+dial_h-1);
		objc_draw(addr,ROOT,MAX_DEPTH,dial_x,dial_y,dial_w,dial_h);
	}
	else				/* un-draw dialog box */
	{
		waitmouse();	/* prevent print-through from mouse button */
		qrest_screen(dial_y,dial_y+dial_h-1);

		/* deselect exit object */
		if (exit_obj>=0) dial_addr[exit_obj].ob_state &= ~SELECTED;
	}
}	/* end putdial() */

/* ignore all events ........................................................*/

evnt_null()
{
	int dumbbuf[8];

	evnt_multi(MU_MESAG|MU_KEYBD|MU_TIMER,0L,0L,0L,0L,0L,0L,0,
			 dumbbuf,0L,&dummy,&dummy,&dummy,&dummy,&dummy,&dummy);
#if ALOCKFLAG
	asm {
		move.w	mainchksum(a4),d0
		subi.w	#MAINCHKSUM,d0
		adda.w	d0,a7
	}
#endif
}	/* end evnt_null() */

/* redraw window behind a moving desk accessory .............................*/

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
	xyarray[2]= 639; xyarray[3]= y2-menu_hi_y-1;
	xyarray[4]= 0;   xyarray[5]= menu_hi_y+1;
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
			set_clip( t1.g_x, t1.g_y, t1.g_x+t1.g_w-1, t1.g_y+t1.g_h-1 );
			intin[0] = 3;   /* write mode = replace */
			pioff=xyarray;
			asm {
				lea		contrl(a4),a0
				move.w	#109,(a0)
				move.w	#4,2(a0)
				move.w	#1,6(a0)
				move.w	gl_hand(a4),12(a0)
				lea		savedfdb(a6),a1
				move.l	a1,14(a0)
				lea		scrfdb(a6),a1
				move.l	a1,18(a0)
			}
			vdi();             /* vro_cpyfm() */
			pioff= ptsin;
		}   
/* get next rectangle in this window's rectangle list */
		wind_get(windhndl,WF_NEXTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
	}

	SHOWMOUSE;

}  /* end re_window() */

/* set VDI clipping rectangle ...............................................*/

set_clip(x1,y1,x2,y2)
register int x1,y1,x2,y2;
{
	ptsin[0]=x1;	ptsin[1]=y1;
	ptsin[2]=x2;	ptsin[3]=y2;
	intin[0] = 1;
	contrl[0] = 129;
	contrl[1] = 2;
	contrl[3] = 1;
	contrl[6] = gl_hand;
	vdi();
}  /* end set_clip() */

/* find intersection of two rectangles ......................................*/

rc_intersect(p1,p2)
register GRECT *p1,*p2;
{
	register int tx, ty, tw, th;

	tw = min(p2->g_x + p2->g_w, p1->g_x + p1->g_w);
	th = min(p2->g_y + p2->g_h, p1->g_y + p1->g_h);
	tx = max(p2->g_x, p1->g_x);
	ty = max(p2->g_y, p1->g_y);
	p2->g_x = tx;
	p2->g_y = ty;
	p2->g_w = tw - tx;
	p2->g_h = th - ty;
	return ((tw > tx) && (th > ty));
}  /* end rc_intersect() */

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

/* draw a single object in a tree ...........................................*/

draw_object(tree,obj)
OBJECT *tree;
int obj;
{
	int x,y,w,h;

	objc_offset(tree,obj,&x,&y);
	w= tree[obj].ob_width;
	h= tree[obj].ob_height;
	objc_draw(tree,ROOT,MAX_DEPTH,x,y,w,h);
#if ALOCKFLAG
	asm {
		move.w	maincrc(a4),d0
		subi.w	#MAINCRC,d0
		adda.w	d0,a7
	}
#endif
}	/* end draw_object() */

/* which one of a set of radio buttons is selected ..........................*/

which_rbutton(tree,n,button0)	/* returns 0-(n-1), -1 if none */
register OBJECT *tree;
int n,button0;
{
	register int i;
	
	for (i=0; i<n; i++)
		if ( tree[button0+i].ob_state & SELECTED ) return(i);
	return(-1);
}	/* end which_rbutton() */

/* set one of a set of buttons ..............................................*/

set_rbutton(which,n,tree,button0)
int which,n,button0;
register OBJECT *tree;
{
	register int i;

	for (i=0; i<n; i++,button0++)
		if (which==i)
			tree[button0].ob_state |= SELECTED;
		else
			tree[button0].ob_state &= ~SELECTED;

}	/* end set_rbutton() */

/* EOF gem.c */
