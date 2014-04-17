/*
*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/gemmnlib.c,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:25:14 $	$Locker: kbad $
* =======================================================================
*  $Log:	gemmnlib.c,v $
* Revision 2.2  89/04/26  18:25:14  mui
* TT
* 
* Revision 2.1  89/02/22  05:28:13  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.2  88/10/26  19:27:23  kbad
* made menu line redraw in replace vice XOR mode.
* 
* Revision 1.1  88/06/02  12:34:30  lozben
* Initial revision
* 
*************************************************************************
*/
/*	GEMMNLIB.C	04/26/84 - 04/05/85	Lowell Webster		*/
/*	Reg Opt		03/08/85 - 03/09/85	Derek Mui		*/
/*	At mn_do, added the ctlmouse	3/4/86	Derek Mui		*/
/*	Fix at mn_do			3/5/86	Derek Mui		*/
/*	Fix at mn_do for disabled menu bar	6/11/86	Derek Mui	*/
/*	Change at mn_bar to do a dsptch		3/10/88	D.Mui		*/
/*	Fix at mn_bar again so it won't lose click 6/25/90	D.Mui	*/

/*
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.1
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
*/

#include <portab.h>
#include <machine.h>
#include <struct88.h>
#include <baspag88.h>
#include <obdefs.h>
#include <taddr.h>
#include <gemlib.h>
						/* in BB.C		*/
EXTERN	VOID	bb_restore();
EXTERN	VOID	bb_save();
						/* in EVLIB.C		*/
EXTERN	WORD	ev_multi();
						/* in GSXIF.C		*/
EXTERN	VOID	gsx_mxmy();
						/* in OBLIB.C		*/
EXTERN	WORD	ob_find();
EXTERN	VOID	ob_draw();
EXTERN	VOID	ob_change();
						/* in OBED.C		*/
EXTERN	VOID	ob_actxywh();

EXTERN	WORD	gl_moff;

EXTERN WORD	gl_width;
EXTERN WORD	gl_height;
EXTERN WORD	gl_wbox;
EXTERN WORD	gl_hbox;
EXTERN GRECT	gl_rzero;
EXTERN GRECT	gl_rmenu;

EXTERN WORD	gl_wchar;
EXTERN WORD	gl_hchar;

EXTERN WORD	appl_msg[];

EXTERN PD	*ctl_pd;
EXTERN PD	*gl_mowner;
EXTERN THEGLO	D;

EXTERN MOBLK	gl_ctwait;

GLOBAL LONG	gl_mntree;
GLOBAL LONG	gl_mnpid;
GLOBAL GRECT	gl_rmnactv;

GLOBAL LONG	desk_acc[NUM_DESKACC];
GLOBAL WORD	desk_pid[NUM_DESKACC];

GLOBAL WORD	gl_dacnt;
GLOBAL WORD	gl_dabase;
GLOBAL WORD	gl_dabox;

#if 0
/*
*	Change a mouse-wait rectangle based on an object's size.
*/

	VOID
rect_change(tree, prmob, iob, x)
	LONG		tree;
	MOBLK		*prmob;
	WORD		iob;
	WORD		x;
{
	ob_actxywh(tree, iob, &prmob->m_x);
	prmob->m_out = x;
}
#endif


/*
*	Routine to change the state of a particular object.  The
*	change in state will not occur if the object is disabled
*	and the chkdisabled parameter is set.  The object will
*	be drawn with its new state only if the dodraw parameter
*	is set.
*/

	UWORD
do_chg(tree, iitem, chgvalue, dochg, dodraw, chkdisabled)
	REG LONG		tree;		/* tree that holds item	*/
	WORD		iitem;			/* item to affect	*/
	REG UWORD		chgvalue;	/* bit value to change	*/
	WORD		dochg;			/* set or reset value	*/
	WORD		dodraw;			/* draw resulting change*/
	WORD		chkdisabled;		/* only if item enabled	*/
{
	REG UWORD		curr_state;

	curr_state = LWGET(OB_STATE(iitem));
	if ( (chkdisabled) &&
	     (curr_state & DISABLED) )
	  return(FALSE);
	
	if ( dochg )
	  curr_state |= chgvalue;
	else
	  curr_state &= ~chgvalue;

	if (dodraw)
	  gsx_sclip(&gl_rzero);	

	ob_change(tree, iitem, curr_state, dodraw);
	return(TRUE);
}

#if 0
/*
*	Routine to set and reset values of certain items if they
*	are not the current item
*/
	WORD
menu_set(tree, last_item, cur_item, setit)
	LONG		tree;
	REG WORD		last_item;
	WORD		cur_item;
	WORD		setit;
{
	if ( (last_item != NIL) &&
	     (last_item != cur_item) )
	{
	  return( do_chg( tree, last_item, SELECTED, setit, TRUE, TRUE) );
	}
	return(FALSE);
}

/*
*	Routine to save or restore the portion of the screen underneath
*	a menu tree.  This involves BLTing out and back
*	the data that was underneath the menu before it was pulled
*	down.
*/

	VOID
menu_sr(saveit, tree, imenu)
	WORD		saveit;
	LONG		tree;
	WORD		imenu;
{
	GRECT		t;

	gsx_sclip(&gl_rzero);	
	ob_actxywh(tree, imenu, &t);
	t.g_x -= MTH;
	t.g_w += 2*MTH;
	t.g_h += 2*MTH;
	if (saveit)
	  bb_save(&t);
	else
	  bb_restore(&t);
}

/*
*	Routine to pull a menu down.  This involves saving the data
*	underneath the menu and drawing in the proper menu sub-tree.
*/

	WORD
menu_down(tree, ititle)
	REG LONG		tree;
	REG WORD		ititle;
{
	REG WORD		imenu, i;
						/* correlate title #	*/
						/*   to menu subtree #	*/
	imenu = LWGET(OB_HEAD(THEMENUS));
	for (i=ititle-THEACTIVE; i>1; i--)
	  imenu = LWGET(OB_NEXT(imenu));
						/* draw title selected	*/
	if ( do_chg(tree, ititle, SELECTED, TRUE, TRUE, TRUE) )
	{
						/* save area underneath	*/
						/*   the menu		*/
	  menu_sr(TRUE, tree, imenu);
						/* draw all items in menu */
	  ob_draw(tree, imenu, MAX_DEPTH);
	}
	return(imenu);
}


	WORD
mn_do(ptitle, pitem)
	WORD		*ptitle, *pitem;
{
	REG LONG		tree;
	LONG		buparm;
	WORD		mnu_flags, done;
	REG WORD		cur_menu, cur_item, last_menu, last_item;
	WORD		cur_title, flag, last_title;
	UWORD		ev_which;
	MOBLK		p1mor, p2mor;
	WORD		menu_state, rect;
	WORD		rets[6];
	WORD		curstate;

	tree = gl_mntree;
						/* initially wait to	*/
						/*   go into the active	*/
						/*   part of the bar	*/
						/*   or the button state*/
						/*   to change		*/
						/*   or out of the bar	*/
						/*   when nothing is	*/
						/*   down		*/
	menu_state = INBAR;

	done = FALSE;
	buparm = 0x00010101L;
	cur_title = cur_menu = cur_item = NIL;

	ctlmouse( TRUE );			/*  3/4/86		*/
		
	while (!done)
	{
	  mnu_flags = MU_BUTTON | MU_M1;
	  flag = TRUE;
	  switch (menu_state)
	  {
	    case INBAR:
		rect = THEACTIVE;
		flag = FALSE;
		mnu_flags |= MU_M2;
		rect_change( tree, &p2mor, THEBAR, TRUE);
		break;
	    case OUTTITLE:
		rect = cur_title;
		break;
	    case INBARECT:
		rect = THEACTIVE;
		flag = FALSE;
		mnu_flags |= MU_M2;
		rect_change( tree, &p2mor, cur_menu, FALSE );
		break;
	    case OUTITEM:
		rect = cur_item;
		buparm = (gsx_button() & 0x0001) ? 0x00010100L : 0x00010101L;
		break;
	  }
	  rect_change( tree, &p1mor, rect, flag);

	  ev_which = ev_multi(mnu_flags, &p1mor, &p2mor, 0x0L,
				buparm, 0x0L, &rets[0]);

	  if ( ev_which & MU_BUTTON )
	  {
	    if ( menu_state != OUTTITLE )
	      done = TRUE;
	    else
	      buparm ^= 0x00000001;
	  }
	  if ( !done )
	  {
						/* save old values	*/
	    last_title = cur_title;
	    last_item = cur_item;
	    last_menu = cur_menu;
						/* see if over the bar	*/
	    cur_title = ob_find( tree, THEACTIVE, 1, rets[0], rets[1] );
	    curstate = LWGET(OB_STATE(cur_title));
	    if ( (cur_title != NIL) && ( curstate != DISABLED )) 
	    {
	      cur_item = NIL;
	      menu_state = OUTTITLE;
	    }
	    else
	    {
	      cur_title = last_title;
	      if (last_menu != NIL)
	      {
	        cur_item = ob_find(tree, last_menu, 1, rets[0], rets[1]);
	        menu_state = (cur_item != NIL) ? OUTITEM : INBARECT;
	      }
	      else
	      {
		menu_state = INBAR;
		if ( curstate != DISABLED )
		  done = TRUE;
	      }
	    }
						/* clean up old state	*/
	    menu_set(tree, last_item, cur_item, FALSE);
	    if ( menu_set(tree, last_title, cur_title, FALSE) )
	      menu_sr(FALSE, tree, last_menu);
						/* set up new state	*/
	    if ( menu_set(tree, cur_title, last_title, TRUE) )
	      cur_menu = menu_down( tree, cur_title);
	    menu_set(tree, cur_item, last_item, TRUE);
	  }
	} /* while (!done) */
						/* decide what should	*/
						/*   be cleaned up and	*/
						/*   returned		*/
	flag = FALSE;
	if ( cur_title != NIL )
	{
	  menu_sr(FALSE, tree, cur_menu);
	  if ( (cur_item != NIL) &&
	       ( do_chg( tree, cur_item, SELECTED, FALSE, FALSE, TRUE) ) )
	  {
						/* only return TRUE when*/
						/*   item is enabled and*/
						/*   is not NIL		*/
	     *ptitle = cur_title;
	     *pitem = cur_item;
	     flag = TRUE;
	  }
	  else
	    do_chg( tree, cur_title, SELECTED, FALSE, TRUE, TRUE);
	}

	ctlmouse( FALSE );			/* fixed 3/5/86		*/

	return(flag);
}
#endif

/*
*	Routine to display the menu bar.  Clipping is turned completely
*	off so that this operation will be as fast as possible.  The
*	global variable gl_mntree which is used in CTLMGR88.C is also
*	set or reset.
*/
	WORD
mn_bar(tree, showit)
	REG LONG		tree;
	WORD		showit;
{
	REG WORD		i, ob, h, cnt;
	LONG		spec;

	if ( showit )
	{
	  gl_mntree = tree;
	  ob_actxywh(tree, THEACTIVE, &gl_rmnactv);
		
	  /* change the waiting rectangle	*/

	  ch_wrect( &gl_ctwait.m_x, &gl_rmnactv );
	  
	  rc_copy(&gl_rmnactv, &gl_ctwait.m_x);
	  gl_mnpid = rlr->p_pid;
	  gl_dabox = LWGET(OB_HEAD(THEMENUS));
	  LWSET(OB_HEAD(gl_dabox), NIL); 
	  LWSET(OB_TAIL(gl_dabox), NIL); 
	  h = 0;
	  i = 1;
	  if (gl_dacnt)
	  {
						/* add disabled line	*/
						/*   and each desk acc	*/
	    cnt = 2 + gl_dacnt;
	    gl_dabase = gl_dabox + 3;
	  }
	  else
	    cnt = 1;

	  while (i <= cnt)
	  {
	    ob = gl_dabox + i;
	    ob_add(tree, gl_dabox, ob);
						/* fixup each		*/
						/*   desk accessory line*/
	    if (i > 2)
	      LLSET(OB_SPEC(ob), desk_acc[i-3]);
	    h += gl_hchar;
	    i++;
	  }
	  LWSET(OB_HEIGHT(gl_dabox), h);
	  gsx_sclip(&gl_rzero);
	  ob_draw(tree, THEBAR, MAX_DEPTH);
	  gsx_attr( FALSE, MD_REPLACE, BLACK );	/* not xor mode!	*/
	  gsx_cline(0, gl_hbox - 1, gl_width - 1, gl_hbox - 1);
	}
	else
	{
	  gl_mntree = 0x0L;
				/* change the waiting rect */
	  ch_wrect( &gl_ctwait.m_x, &gl_rmenu );

	  rc_copy(&gl_rmenu, &gl_ctwait.m_x);
	}
						/* make ctlmgr fix up	*/
						/*   the size of rect	*/
						/*   its waiting for	*/
/*	gl_fakemsg++;			*/
	post_button( ctl_pd, 0x0000, 1);
	dsptch();			
}

/*
*	Routine to tell desk accessories that the currently running
*	application is about to terminate.
*/
	VOID
mn_clsda()
{
	REG WORD		i;

	for (i=0; i<gl_dacnt; i++)
	  ap_sendmsg(appl_msg, AC_CLOSE, desk_pid[i], i, 0x0L, 0x0L);
}


/*
*	Routine to register a desk accessory item on the menu bar.
*	The return value is the object index of the menu item that
*	was added.
*/
	WORD
mn_register(pid, pstr)
	REG WORD		pid;
	REG LONG		pstr;
{
	BYTE		tmpname[13];
						/* use this to name	*/
						/*   our process	*/
	if (pid == -1)
	{
	  LSTCPY(ADDR(&tmpname[0]), pstr);
	  p_nameit(rlr, &tmpname[0]);
	  return(TRUE);
	}
	else
	{
						/* add desk acc. if room*/
	  if (gl_dacnt < NUM_DESKACC)
	  {
	    desk_pid[gl_dacnt] = pid;
	    desk_acc[gl_dacnt] = pstr;
	    gl_dacnt++;
	    return(gl_dacnt - 1);
	  }
	  else
	    return(-1);
	}
}	


/*	Change the waiting rectangle for new menu bar	*/

ch_wrect( r, n )
	GRECT		*r;	/* old rect */
	GRECT		*n;	/* new rect */
{
	PD		*p;	
	REG EVB		*e;
	WORD		*p1,*p2;

	p = ctl_pd;

	for ( e = p->p_cda->c_msleep; e ; e = e->e_link )
	{
	  p1 = &e->e_parm;
	  p2 = &e->e_return;

	  if ( ( r->g_x == p1[0] ) && 
	       ( r->g_y == p1[1] ) && 
	       ( r->g_w == p2[0] ) && 
	       ( r->g_h == p2[1] ) )
	  {
	    e->e_parm = HW(n->g_x) + n->g_y;
	    e->e_return = HW(n->g_w) + n->g_h;	  
	  }
	}
}

