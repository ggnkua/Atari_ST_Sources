/******************************************************************************

                                     GenEdit
                                        by
                                   Tom Bajoras

                        Copyright 1990/1991 Tom Bajoras

	module EDIT1 : editor top level

	ex_edit

	do_editkey, do_editbar, do_edit

	exit_edit, undo_edit, mode_edit, send_edit, page_edit, play_edit, chan_edit

	draweditpage, draw_chg

	enc_chan, enc_thru, enc_port, enc_orig, enc_chng, enc_page, enc_send

******************************************************************************/

overlay "edit"

/* include header files .....................................................*/

	/* standard */
#include <osbind.h>		/* GEMDOS, BIOS, XBIOS */
#include <gemdefs.h>		/* AES */
#include <obdefs.h>		/* more AES */

	/* program-specific */
#include "defines.h"		/* miscellaneous */
#include "scan.h"			/* keyboard scan codes */
#include "temdefs.h"		/* template stuff */
#include "genedit.h"		/* created by RCS */
#include "externs.h"		/* global variables */

/* in tem.c .................................................................*/

extern int curr_page,curr_mem,curr_nctrl;
extern int temoutl;

/* local globals ............................................................*/

int edit_side,edit_pat;		/* side and patch being edited, edit_side<0 means
										no selected patch */
int edit_chan;					/* midi channel when edit_side<0 */
int edit_chng;					/* whether edit buffer different than orig buffer,
										always 0 if edit_side<0 */
int edit_orig;					/* currently displaying: 0= edited, 1= original */
int origmem;					/* heap handle: original buffer */
int backmem;					/* heap handle: edit buffer backup buffer */
int chgtabmem;					/* heap handle: control changed table */
int chgtabn;					/* how many ctrls have changed in chgtabmem */
int scrmem;						/* heap handle: saved screen */
int ptabmem;					/* heap handle: page table */
int addrmem;					/* heap handle: ctrl address table */
int sendpending;	/* edit buffer needs to be sent as soon as mouse button up */
int send_flag;					/* 0= on, 1= semi, 2= off */

/* editor main loop .........................................................*/

ex_edit(side,pat)
int side,pat;		/* selected patch: can be  -1,-1 meaning none */
{
#if (EDITFLAG*TEMFLAG)
	register int i;
	int event,done,error,mem;
	int mstate,mousex,mousey;
	int key,kstate,ctrl_i;
	int bar_x,bar_y,bar_w,bar_h;
	int saveoutl;
	long getebdtsize();
	int accel;

	/* template/config linking */
	if (side>=0)
		if (!match_tem(side,0)) return;

	/* fix resource */
	bar_x= editaddr[0].ob_x= 0;
	bar_y= editaddr[0].ob_y= rez-1;
	bar_w= editaddr[0].ob_width;
	bar_h= editaddr[0].ob_height= charh;

	/* variables that get reset every time */
	edit_side= side;	/* which window are we editing in? (-1 none) */
	edit_pat= pat;		/* which patch are we editing? (-1 none) */
	edit_orig= 0;		/* displaying edited version */
	edit_chng= 0;		/* edit and original buffers same */

	/* disable empty pages */
	error= -1;
	for (i=0; i<NTEMPAGES; i++)
	{
		mem= temmem[ seg_to_mem(idTEMPAGE0+i) ] ;
		if (heap[mem].nbytes)
		{
			editaddr[EDITPAGE+i].ob_state &= ~DISABLED;
			if (error<0) error=i;	/* mark first non-empty page */
		}
		else
			editaddr[EDITPAGE+i].ob_state |= DISABLED;
	}
	if (error<0) return; /* all pages blank */

	/* if we're on an empty page, change to lowest #d non-empty one */
	if (editaddr[EDITPAGE+curr_page].ob_state & DISABLED) curr_page=error;

	/* allocate buffers */
	origmem= backmem= -1;
	error= (scrmem=alloc_mem(SCRLENG)) < 0 ;
	if (!error) error= (origmem=alloc_mem(0L)) < 0 ;
	if (!error) error= (backmem=alloc_mem(0L)) < 0 ;
	if (!error) error= (ptabmem=alloc_mem(0L)) < 0 ;
	if (!error) error= (addrmem=alloc_mem(0L)) < 0 ;
	if (!error) error= (chgtabmem=alloc_mem(0L)) < 0 ;
	if (error) goto edit_exit;

	/* copy selected patch (if any) to edit buf, or create fake edit buf */
	graf_mouse(BEE_MOUSE);
	if (edit_side>=0)
	{
		error= !putpgetp((int)(cnxDTOE),edit_side,edit_pat);
		if (!error) error= editbufok();
		if (!error) error= !copy_mem(editmem,origmem);
	}
	else
		error= fakeeditbuf();
	if (!error) error= !copy_mem(editmem,backmem);
	graf_mouse(ARROWMOUSE);
	if (error) goto edit_exit;

	/* encode into resource */
	if (edit_side>=0)
	{
		if (!itop(edit_pat,windpnumfmt[edit_side],editaddr[EDITNUMB].ob_spec))
			strcpy(editaddr[EDITNUMB].ob_spec,"       ");
		i= min(16,nameleng[edit_side]); /* truncate to 16 characters */
		copy_bytes(heap[namemem[edit_side]].start+edit_pat*nameleng[edit_side],
					  editaddr[EDITNAME].ob_spec,(long)i);
		(editaddr[EDITNAME].ob_spec)[i]=0;
		send_flag= temheader.no_send;
	}
	else
	{
		strcpy(editaddr[EDITNUMB].ob_spec," ");
		strcpy(editaddr[EDITNAME].ob_spec,NOEDBUFMSG);
		send_flag=2;
	}
	if (midi_opsys)
	{
		editaddr[EDITPLAY].ob_state |= DISABLED;
		editaddr[EDITTCHN].ob_flags |= HIDETREE;
	}
	else
	{
		editaddr[EDITPLAY].ob_state &= ~DISABLED;
		editaddr[EDITTCHN].ob_flags &= ~HIDETREE;
	}
	if (midiplexer)
		editaddr[EDITTPRT].ob_flags &= ~HIDETREE;
	else
		editaddr[EDITTPRT].ob_flags |= HIDETREE;
	enc_send(0);
	enc_orig(0);
	enc_thru(0);
	enc_port(0);
	enc_chan(0);
	enc_chng(0);
	enc_page(0);

	/* save screen, draw editor shell */
	HIDEMOUSE;
	copy_longs(scrbase,heap[scrmem].start,SCRLENG/4);
	set_longs(scrbase,SCRLENG/4,0L);
	objc_draw(editaddr,ROOT,MAX_DEPTH,0,0,640,200*rez);
	SHOWMOUSE;

	/* swap in template drawing options */
	saveoutl= temoutl; temoutl=0;	/* no outlining */
	setup_side(-1);					/* no pallette */

	/* draw current page, abort editor if can't build page table */
	set_curr();
	done= !change_mem(chgtabmem,2L*curr_nctrl);
	if (!done) done= page_table();
	if (!done) draweditpage();
	if (!done) done= send_edit();	/* send right away (if edit_side>=0) */

	sendpending=0;
	waitmouse();
	/* track most recently clicked on control, lock in on control so that
		do_edit() doesn't need to call find_ctrl() everytime */
	ctrl_i= -1;
	while (!done)
	{
		/* Check for incoming keys */
		event= evnt_multi(MU_KEYBD|MU_TIMER,0,0,0,0,0,0,0,0,0,0,0,0,0,
				 &dummy,0,0,&dummy,&dummy,&dummy,&kstate,&key,&dummy);
		kstate &= 0x0F;	/* alt/ctrl/shift */
		if (event&MU_KEYBD)
		{
			done= do_editkey(key,kstate);
			ctrl_i= -1;
		}
		/* mouse button repeat rate accelerates after several repeats, but no
			acceleration while keyboard modifier */
		accel= ctrl_i<0 ? 0 : accel+1 ;
		if (kstate) accel=0;
		if (accel>11) accel=11;
		mstate= accel<11 ? getwmouse(&mousex,&mousey) : getmouse(&mousex,&mousey);
		/* when button goes down do something,
			when button goes up send edit buffer if it has changed */
		if (mstate)
		{
			if (in_rect(mousex,mousey,bar_x,bar_y,bar_w,bar_h))
			{
				done= do_editbar(mstate,mousex,mousey);
				ctrl_i= -1;
			}
			else
				ctrl_i= do_edit(kstate,mstate,mousex,mousey,ctrl_i);
		}
		else
		{
			if (sendpending) done= send_edit();
			sendpending=0;
			ctrl_i= -1;
		}
	}	/* end while !done */

	/* restore screen */
	HIDEMOUSE;
	copy_longs(heap[scrmem].start,scrbase,SCRLENG/4);
	SHOWMOUSE;

	/* restore stuff */
	temoutl= saveoutl;

	/* redraw selected patch in case editor has changed it */
	if ((side>=0)&&(pat>=0))
		if (build_1name(side,pat))
			draw_names(side,pat);

edit_exit:
	/* deallocate buffers */
	dealloc_mem(scrmem);
	dealloc_mem(origmem);
	dealloc_mem(backmem);
	dealloc_mem(ptabmem);
	dealloc_mem(addrmem);
	dealloc_mem(chgtabmem);
	change_mem(editmem,0L);

#endif
}	/* end ex_edit() */

#if (EDITFLAG*TEMFLAG)

/* handle key typed .........................................................*/
/* returns 1= done, 0= not done */

do_editkey(key,kstate)
register int key,kstate;
{
	int done=0;
	register int i;
	int asci;

	asci= key & 0xFF;	/* asci */
	key >>= 8;			/* scan code */

	/* <Shift><key> = send macro */
	if ((kstate==K_LSHIFT)||(kstate==K_RSHIFT))
	{
		for (i=0; i<NMACROS; i++)
			if (key==macroscan[i]) break;
		if (i<NMACROS) send_macro(i);
		return 0;
	}

	/* targeted HybriSwitch */
	if ( (kstate==K_ALT) && (key>=SCAN_f1) && (key<=SCAN_f10) && sw_ptr )
	{
		ex_switch(key-SCAN_f1);
		return 0;
	}

	/* Steinberg Switcher */
	if ( (key>=SCAN_F1) && (key<=SCAN_F10) && (kstate==(K_CTRL|K_LSHIFT))
		&& (midi_opsys==2) )
	{
		steinswitch();
		return 0;
	}

	switch (key)
	{
		case SCAN_ESC:		done=exit_edit();	break;
		case SCAN_UNDO:	done=undo_edit();	break;
		case SCAN_TAB:		done=mode_edit();	break;
		case SCAN_SPACE:	play_edit(kstate==K_ALT); break;
		case SCAN_S:
		if (send_flag==2) break;
		if (kstate==K_CTRL)
		{
			send_flag= !send_flag;
			enc_send(1);
			if (send_flag==0) done= send_edit();
		}
		else
			done= send_edit();
		break;

		case SCAN_SUB:
		case SCAN_ADD:
		chan_edit(key==SCAN_SUB ? -1 : 1);
		break;

		default:
		if ((asci>='1')&&(asci<='8')) done= page_edit(asci-'1');

	}	/* end switch (scan) */
	return done;
}	/* end do_editkey() */

/* handle mouse clicked in bar ..............................................*/
/* returns 1= done, 0= not done */

do_editbar(mstate,mx,my)
int mstate,mx,my;
{
	int done=0;
	register int i,exit_obj;

	/* convert mstate to -1 left, +1 right */
	mstate= mstate==1 ? -1 : 1 ;

	switch (exit_obj=objc_find(editaddr,ROOT,MAX_DEPTH,mx,my))
	{
		case EDITNAME:
		case EDITNUMB:
		case -1:			break;

		case EDITEXIT: done=exit_edit();	break;
		case EDITUNDO: done=undo_edit();	break;

		case EDITORIG:
		if (!edit_orig) done=mode_edit();
		break;
		case EDITEDTD:
		if (edit_orig) done=mode_edit();
		break;

		case EDITPLAY:	play_edit(mstate>0);		break;

		case EDITSEND:
		if (send_flag==2) break;
		if (mstate<0)
		{
			send_flag= !send_flag;
			enc_send(1);
			if (send_flag==0) done= send_edit();
		}
		else
			done= send_edit();
		break;

		case EDITSCHN:
		i= edit_side<0 ? edit_chan : wind_device[edit_side].midichan;
		i += mstate;
		if (i<(-1)) i=15;
		if (i>15) i= -1;
		if (edit_side<0)
			edit_chan= i;
		else
			wind_device[edit_side].midichan= i;
		enc_chan(1);
		break;

		case EDITTCHN:
		chan_edit(mstate);
		break;

		case EDITTPRT:
		i= thru_tport + mstate;
		if (i<0) i=3;
		if (i>3) i=0;
		if (midithru) thru_nts_off();
		thru_tport=i;
		enc_port(1);
		break;

		default:
		i= exit_obj-EDITPAGE;
		if ((i>=0)&&(i<NTEMPAGES)) done= page_edit(i);

	}	/* end switch (exit_obj) */
	waitmouse();

	return done;
}	/* end do_editbar() */

/* handle mouse clicked in work area ........................................*/
/* returns control # clicked on (-1 for none) */

do_edit(kstate,mstate,mousex,mousey,ctrl_i)
int kstate,mstate,mousex,mousey,ctrl_i;
{
	static CTRLHEADER *ctrl;

	/* can't edit while displaying original */
	if (edit_orig) return 1;

	/* which control clicked on? */
	if (ctrl_i<0) ctrl_i= find_ctrl(mousex,mousey,&ctrl);
	if (ctrl_i<0) return -1;

	if (hndl_ctrl(ctrl_i,ctrl,kstate,mstate,mousex,mousey))
	{
		/* send when mouse button goes up */
		if (send_flag==0) sendpending=1;

		/* edit buffer has been changed and is not sent yet !!! */
		if ( (edit_side>=0) && strcmp(editaddr[EDITSEND].ob_spec,SEND2_MSG) )
		{
			strcpy(editaddr[EDITSEND].ob_spec,SEND2_MSG);
			draw_object(editaddr,EDITSEND);
		}

		/* if there's an edit buffer, mark it as changed */
		if ((edit_side>=0)&&!edit_chng)
		{
			edit_chng=1;
			enc_chng(1);
		}
	}
	return ctrl_i;
}	/* end do_edit() */

/* exit editor ..............................................................*/
/* returns 1= exit, 0= don't exit */

exit_edit()
{
	int what_to_do;

	if (editaddr[EDITEXIT].ob_state&DISABLED) return 0;

	/* if edit buffer has changed:  keep, discard, or cancel */
	if (edit_chng)
		what_to_do= form_alert(1,CHEKEDIT);
	else
		what_to_do= 2;						/* discard */
	if (what_to_do==3) return 0;		/* cancel */
	if (what_to_do==1)					/* keep */
	{
		/* copy edit buffer back to bank */
		putpgetp((int)cnxETOD,edit_side,edit_pat);
		change_flag[edit_side ? rdatCHANGE : ldatCHANGE]= 1;
	}
	return 1;
}	/* end exit_edit() */

/* undo editing .............................................................*/
/* returns 1= error (abort out of editor), 0= okay */

undo_edit()
{
	int error=0;

	if ( !(editaddr[EDITUNDO].ob_state&DISABLED) )
	{
		if (form_alert(1,CHEKUNDO)==1)
		{
			copy_mem(origmem,editmem);
			error= send_edit();
			if (!error)
			{
				chgtabn=0;
				setallvals(0,-1);
				draw_chg();
				edit_chng=0;
				enc_chng(1);
			}
		}
	}
	return error;
}	/* end undo_edit() */

/* toggle original/edited ...................................................*/
/* returns 1= error (abort out of editor), 0= okay */

mode_edit()
{
	int error=0;

	if ( !(editaddr[EDITORIG].ob_state&DISABLED) )
	{
		edit_orig= !edit_orig;
		enc_orig(1);
		error= send_edit();
		if (!error)
		{
			chgtabn=0;
			setallvals(0,-1);
			draw_chg();
		}
	}
	return error;
}	/* end mode_edit() */

/* send edit/orig buffer to instrument ......................................*/
/* returns 1= error (abort out of editor), 0= okay */

send_edit()
{
	register int temp;
	int error=0;

	/* don't send if send is turned off */
	if (send_flag==2) return 0;

	/* can't send if there's no edit buffer */
	if (edit_side<0) return 0;

	if (edit_orig) /* send original */
	{
		temp= origmem;
		origmem= editmem;
		editmem= temp;
	}

	cnxvars[VAR_PAT]= edit_pat;
	edittomidi(edit_side);

	/* fatal error if Send trashes the ebdt-mapped part of edit buffer */
	error= clipedbuf(2);
	if (error) form_alert(1,BADEDSEND);

	if (edit_orig) /* sent original */
	{
		temp= origmem;
		origmem= editmem;
		editmem= temp;
	}
	else				/* reset "edit buffer hasn't been sent" !!! */
	{
		if (strcmp(editaddr[EDITSEND].ob_spec,SEND1_MSG))
		{
			strcpy(editaddr[EDITSEND].ob_spec,SEND1_MSG);
			draw_object(editaddr,EDITSEND);
		}
	}
	enc_chan(1);
	return error;
}	/* end send_edit() */

/* change page ..............................................................*/
/* returns 1= can't build page table, 0= ok */

page_edit(new)
int new;
{
	int error=0;

	/* can't page to an empty page */
	if (editaddr[EDITPAGE+new].ob_state&DISABLED) return 0;

	if (new!=curr_page)
	{
		curr_page= new;
		enc_page(1);

		/* draw new page */
		set_curr();
		error= !change_mem(chgtabmem,2L*curr_nctrl);
		if (!error) error= page_table();
		if (!error) draweditpage();
	}
	return error;

}	/* end page_edit() */

/* change thru channel ......................................................*/

chan_edit(del)
int del;	/* -1, +1 */
{
	if (midi_opsys) return;
	if (midithru)
	{
		thru_nts_off();
		thruchan += del;
		if ( (thruchan<0) || (thruchan>15) ) thruchan=midithru=0;
	}
	else
	{
		thruchan= del>0 ? 0 : 15 ;
		midithru=1;
	}
	enc_thru(1);
}	/* end chan_edit() */

/* play sequencer ...........................................................*/

play_edit(internal)
int internal;	/* 0= mtst, 1= internal */
{
	int chan;

	if (midi_opsys) return;	/* not if SoftLink, etc. */
	chan= midithru ? thruchan : -1 ;
	return internal ? play_seq(chan) : play_mtst(chan) ;
}	/* end play_edit() */

/* draw page ................................................................*/

draweditpage()
{
	chgtabn=0;
	setallvals(0,-1);
	draw_alltem();
	chgtabn=0;
}	/* end draweditpage() */

/* draw changed controls ....................................................*/

draw_chg()
{
	register int i,j;
	register long ptr;
	register int *chgptr;
	register long *addr;
	long currptr;
	int type;
	int x1,y1,x2,y2;
	CTRLHEADER ctrlheader;

	addr=   (long*)( heap[addrmem].start );
	currptr= heap[curr_mem].start;

	chgptr= (int*)( heap[chgtabmem].start );
	for (j=chgtabn; j>0; j--)
	{
		i= *chgptr++;
		/* control might be repeated in chg table:  draw each only once */
		if ( !(addr[i]&0xff000000L) )
		{
			ptr= addr[i] + currptr;
			type= ( (CTRLHEADER*)(ptr) )->type;
			ptr += sizeof(ctrlheader);
			rect2scr(ptr,&x1,&x2,&y1,&y2);
			if (x1>x2) { i=x1; x1=x2; x2=i; }
			if (y1>y2) { i=y1; y1=y2; y2=i; }
			set_clip(x1,y1,x2-x1+1,y2-y1+1);
			draw_ctrl(type,ptr,x1,y1,x2,y2);
			addr[i] |= 0xff000000L;		/* control has been drawn */
		}
	}
	vs_clip(gl_hand,0,0L);

	/* unmark all controls -- all have been drawn */
	chgptr= (int*)( heap[chgtabmem].start );
	for (j=chgtabn; j>0; j--)
		addr[ *chgptr++ ] &= 0x00ffffffL;
	chgtabn=0;

}	/* end draw_chg() */

/* encode send channel ......................................................*/

enc_chan(draw)
int draw;	/* whether to redraw */
{
	int obj=EDITSCHN;
	static int last_chan= 1000;
	int chan;

	chan= edit_side<0 ? edit_chan : wind_device[edit_side].midichan ;
	if (chan!=last_chan)
	{
		last_chan=chan;
		strcpy(editaddr[obj].ob_spec,chanchar[chan+1]);
		if (draw) draw_object(editaddr,obj);
	}
}	/* end enc_chan() */

/* encode thruchan ..........................................................*/

enc_thru(draw)
int draw;	/* whether to redraw */
{
	int obj=EDITTCHN;
	static int last_chan= 1000;
	int chan;

	chan= midithru ? thruchan : -1 ;
	if (chan!=last_chan)
	{
		last_chan=chan;
		strcpy(editaddr[obj].ob_spec,chanchar[chan+1]);
		if (draw) draw_object(editaddr,obj);
	}
}	/* end enc_thru() */

/* encode thru_tport ........................................................*/

enc_port(draw)
int draw;	/* whether to redraw */
{
	int obj= EDITTPRT;
	char *ptr;

	ptr= ((TEDINFO*)(editaddr[obj].ob_spec))->te_ptext;
	ptr[0] = 'A' + thru_tport;
	if (draw) draw_object(editaddr,obj);

}	/* end enc_port() */

/* encode edit_orig .........................................................*/

enc_orig(draw)
int draw;	/* whether to redraw */
{
	if (edit_orig)
	{
		editaddr[EDITEXIT].ob_state |=  DISABLED ;
		editaddr[EDITUNDO].ob_state |=  DISABLED ;
		editaddr[EDITORIG].ob_state |=  SELECTED ;
		editaddr[EDITEDTD].ob_state &= ~SELECTED ;
	}
	else
	{
		editaddr[EDITEXIT].ob_state &= ~DISABLED ;
		editaddr[EDITUNDO].ob_state &= ~DISABLED ;
		editaddr[EDITORIG].ob_state &= ~SELECTED ;
		editaddr[EDITEDTD].ob_state |=  SELECTED ;
	}
	if (draw)
	{
		draw_object(editaddr,EDITEXIT);
		draw_object(editaddr,EDITUNDO);
		draw_object(editaddr,EDITORIG);
		draw_object(editaddr,EDITEDTD);
	}
}	/* end enc_orig() */

/* encode edit_chng .......................................................*/

enc_chng(draw)
int draw;	/* whether to redraw */
{
	if (edit_chng)
	{
		editaddr[EDITUNDO].ob_state &= ~DISABLED;
		editaddr[EDITORIG].ob_state &= ~DISABLED;
	}
	else
	{
		editaddr[EDITUNDO].ob_state |= DISABLED;
		editaddr[EDITORIG].ob_state |= DISABLED;
	}
	if (draw)
	{
		draw_object(editaddr,EDITUNDO);
		draw_object(editaddr,EDITORIG);
	}
}	/* end enc_chng() */

/* encode send_flag .........................................................*/

enc_send(draw)
int draw;		/* whether to redraw */
{
	switch (send_flag)
	{
		case 0:	/* yes */
		editaddr[EDITSEND].ob_state |= SELECTED;
		editaddr[EDITSEND].ob_state &= ~DISABLED;
		break;

		case 1:	/* semi */
		editaddr[EDITSEND].ob_state &= ~SELECTED;
		editaddr[EDITSEND].ob_state &= ~DISABLED;
		break;

		case 2:	/* off */
		editaddr[EDITSEND].ob_state &= ~SELECTED;
		editaddr[EDITSEND].ob_state |= DISABLED;
		break;
	}
	if (draw) draw_object(editaddr,EDITSEND);
}	/* end enc_send() */

/* encode curr_page .........................................................*/

enc_page(draw)
int draw;		/* whether to redraw */
{
	register int i;

	for (i=0; i<NTEMPAGES; i++)
	{
		if ( editaddr[EDITPAGE+i].ob_state & SELECTED )
		{
			editaddr[EDITPAGE+i].ob_state &= ~SELECTED ;
			if (draw) draw_object(editaddr,EDITPAGE+i);
		}
	}
	editaddr[EDITPAGE+curr_page].ob_state |= SELECTED;
	if (draw) draw_object(editaddr,EDITPAGE+curr_page);
}	/* end enc_page() */
	
#endif

/* EOF */
