/*	GEMFMLIB.C	03/15/84 - 02/08/85	Gregg Morris		*/
/*	to 68k		03/12/85 - 05/24/85	Lowell Webster		*/
/*	Trying 1.2	10/11/85 - 10/21/85	Derek Mui		*/
/*	Removed error 16	2/6/86		Derek Mui		*/
/*	repaired get_par to new bind 01/03/87	Mike Schmal		*/
/*	Modify rsc constants	11/25/87	D.Mui			*/
/*	Crunch out fm_inifld	03/25/88	D.Mui			*/
/*	Change at fm_do		04/10/88	D.Mui			*/
/*	Set the mouse ownership at fm_button	4/22/91		D.Mui	*/
/*	Change at fm_dial (3)			9/25/91		D.Mui	*/
/*	Restored fm_dial			2/13/92		D.Mui	*/
/*	Change in fm_keybd to use the stack to save the incoming value 	*/
/*	and return them to their original pointer at the end of the 	*/
/*	function				2/24/92		D.Mui	*/
/*	Convert to Lattice C 5.51		2/17/93		C.Gee	*/
/*	Force the use of prototypes		2/24/93		C.Gee	*/

/*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------
*/	
#include "pgem.h"
#include "pmisc.h"

#include "machine.h"
#include "objaddr.h"
#include "osbind.h"
#include "mintbind.h"
#include "gemusa.h"


#define BACKSPACE 0x0E08			/* backspace		*/
#define SPACE 0x3920				/* ASCII <space>	*/
#define UP 0x4800				/* up arrow		*/
#define DOWN 0x5000				/* down arrow		*/

#define DELETE 0x537f				/* keypad delete	*/
#define TAB 0x0F09				/* tab			*/
#define BACKTAB 0x0F00				/* backtab		*/
#define RETURN 0x1C0D				/* carriage return	*/
#define ENTER 0x720D				/* enter key on keypad	*/
#define ESCAPE 0x011B				/* escape		*/
#define FORWARD 0
#define BACKWARD 1
#define DEFLT 2
						/* in WMLIB.C		*/
EXTERN	WORD	gl_mkind;
EXTERN	GRECT	gl_rfull;
EXTERN	GRECT	gl_rscreen;
EXTERN	THEGLO	D;
EXTERN	PD	*currpd;
EXTERN	PD	*gl_mowner;



	WORD
find_obj(tree, start_obj, which)
	REG LONG	tree;
	WORD		start_obj;
	WORD		which;
{
	REG WORD	obj, flag, theflag, inc;
/*	WORD		last_obj;*/

	obj = 0;
	flag = EDITABLE;
	inc = 1;

	switch(which)
	{
	  case BACKWARD:
		inc = -1;
		obj = start_obj + inc;		
		break;
		
	  case FORWARD:		/* check if it is LASTOB before inc	*/
		if ( !( LWGET( OB_FLAGS( start_obj ) ) & LASTOB ) )
		  obj = start_obj + inc;
		else
		  obj = -1;

		break;

	  case DEFLT:
		flag = DEFAULT;
		break;

	} /* switch */

	while ( obj >= 0 )
	{
	  theflag = LWGET(OB_FLAGS(obj));

	  if ( theflag & flag )
	    return( obj );

	  if ( theflag & LASTOB )
	    obj = -1;
	  else
	    obj += inc;
	}

	return( start_obj );
}



	WORD
fm_keybd(tree, obj, pchar, pnew_obj)
	LONG		tree;
	WORD		obj;
	WORD		*pchar;
	WORD		*pnew_obj;
{
	REG WORD	direction;
	WORD		nchar,new_obj,ret;
	
	ret = TRUE;
	nchar = *pchar;
	new_obj = *pnew_obj;
						
	direction = -1;		/* handle character	*/

	switch( nchar )
	{
	  case RETURN:
	  case ENTER:
		obj = 0;
		direction = DEFLT;
		break;
	  case BACKTAB:
	  case UP:
		direction = BACKWARD;
		break;
	  case TAB:
	  case DOWN:
	        direction = FORWARD;
	}

	if ( direction != -1 )
	{
/*	  *pchar = 0x0;
	  *pnew_obj = find_obj( tree, obj, direction );
*/
	  nchar = 0x0;
	  new_obj = find_obj( tree, obj, direction );

	  if ( ( direction == DEFLT ) && ( new_obj != 0 ) )
	  {
	    ob_change(tree, new_obj, 
			LWGET(OB_STATE(new_obj)) | SELECTED, TRUE);
	    ret = FALSE;
	  }
	}

	*pchar = nchar;
	*pnew_obj = new_obj;
	return( ret );
}


	WORD
fm_button(tree, new_obj, clks, pnew_obj)
	REG LONG	tree;
	REG WORD	new_obj;
	WORD		clks;
	WORD		*pnew_obj;
{
	REG WORD	tobj;
	WORD		orword;
	WORD		parent, state, flags;
	WORD		cont, tstate, tflags;
	WORD		rets[6];
	PD		*temp;

	temp = gl_mowner;
	gl_mowner = currpd;

	cont = TRUE;
	orword = 0x0;

	state = ob_fs(tree, new_obj, &flags);
						/* handle touchexit case*/
						/*   if double click,	*/
						/*   then set high bit	*/
	if (flags & TOUCHEXIT)
	{
	  if (clks == 2)
	    orword = 0x8000;
	  cont = FALSE;
	}

						/* handle selectable case*/
	if ( ( flags & SELECTABLE ) && !( state & DISABLED ) ) 
	{
		 				/* if its a radio button*/
	  if ( flags & RBUTTON )
	  {
						/* check siblings to	*/
						/*   find and turn off	*/
						/*   the old RBUTTON	*/
	    parent = get_par(tree, new_obj);
	    tobj = LWGET(OB_HEAD(parent));
	    while ( tobj != parent )
	    {
	      tstate = ob_fs(tree, tobj, &tflags);
	      if ( (tflags & RBUTTON) && ( (tstate & SELECTED) || 
		     (tobj == new_obj) ) )
	      {
	        if (tobj == new_obj)
		  state = tstate |= SELECTED;
		else
		  tstate &= ~SELECTED;

		ob_change(tree, tobj, tstate, TRUE);
	      }
	      tobj = LWGET(OB_NEXT(tobj));
	    }
	  }
	  else
	  {					/* turn on new object	*/
	    if ( gr_watchbox(tree, new_obj, state ^ SELECTED, state) )
	      state ^= SELECTED;
	  }
						/* if not touchexit 	*/
						/*   then wait for 	*/
						/*   button up		*/
	  if ( ( cont ) && ( flags & ( SELECTABLE | EDITABLE ) ) )
	    ev_button(1, 0x0001, 0x0000L, &rets[0]);
	}
						/* see if this selection*/
						/*   gets us out	*/
	if ( ( state & SELECTED ) && ( flags & EXIT ) )
	  cont = FALSE;
						/* handle click on 	*/
						/*   another editable	*/
						/*   field		*/
	if ( ( cont ) && !( flags & EDITABLE ) )
	  new_obj = 0;

	*pnew_obj = new_obj | orword;
	gl_mowner = temp;
	return( cont );
}



/*
*	ForM DO routine to allow the user to interactively fill out a 
*	form.  The cursor is placed at the starting field.  This routine
*	returns the object that caused the exit to occur
*/
	WORD
fm_do( tree, start_fld )
	REG LONG	tree;
	WORD		start_fld;
{
	REG WORD	edit_obj,cont;
	WORD		next_obj;
	WORD		which,idx,state;
	WORD		rets[6];
	WORD		oldmouse;
						
						
	wm_update( 3 ); 		/* grab ownership of screen and mouse	*/

	oldmouse = gl_mkind;

	if ( !( oldmouse & 0x8000 ) )
	  gl_mkind |= 0x8000;			/* block any gr_mouse call */
						
/*	fq();	*/				/* flush keyboard	*/
						/* set clip so we can	*/
						/*   draw chars, and	*/
						/*   invert buttons	*/
	gsx_sclip(&gl_rfull);

						/* determine which is 	*/
						/*   the starting field	*/
						/*   to edit		*/


						/* position cursor on	*/
						/*   the starting field	*/
	if (start_fld == 0)
	  next_obj = find_obj(tree, 0, FORWARD);
	else
	  next_obj = start_fld;

	edit_obj = 0;
						/* interact with user	*/
	cont = TRUE;

	state = currpd->p_state;
#if 0
	if ( state == PS_NEW )			/* this is to avoid the	*/
	{
	  currpd->p_state = PS_CRITICAL;	/* mwait() to change it */
	}					/* to PS_RUN state	*/
#endif
	while(cont)
	{
						/* position cursor on	*/
						/*   the selected 	*/
						/*   editting field	*/
	  if ( (next_obj != 0) && (edit_obj != next_obj) )
	  {
	    edit_obj = next_obj;
	    next_obj = 0;
	    ob_edit(tree, edit_obj, 0, &idx, EDINIT);
	  }


						/* wait for mouse or key */
	  which = ev_multi(MU_KEYBD | MU_BUTTON, ( MOBLK *)NULLPTR, ( MOBLK *)NULLPTR,
			 0x0L, 0x0002ff01L, 0x0L, &rets[0]);
						/* handle keyboard event*/

	  if (which & MU_KEYBD)
	  {
	    cont = fm_keybd(tree, edit_obj, &rets[4], &next_obj);
	    if (rets[4])
	      ob_edit(tree, edit_obj, rets[4], &idx, EDCHAR);
	  }
						/* handle button event	*/
	  if (which & MU_BUTTON)
	  {
	    next_obj = ob_find(tree, ROOT, MAX_DEPTH, rets[0], rets[1]);
 	    if (next_obj == NIL)
	    {
	      Bconout( 2, 7 );		/* Bconout(CON, 7)	*/
	      next_obj = 0;
	    }
	    else
	    {
	      cont = fm_button(tree, next_obj, rets[5], &next_obj);
	    }
	  }
						/* handle end of field	*/
						/*   clean up		*/
	  if ( (!cont) || ( ( next_obj != 0 ) && ( next_obj != edit_obj ) ) )
	  {
	    ob_edit(tree, edit_obj, 0, &idx, EDEND);
	  }
	}

/*	currpd->p_state = state;	  */
						/* give up mouse and	*/
						/*   screen ownership	*/

	if ( !( oldmouse & 0x8000 ) )
	  gl_mkind = oldmouse;		/* unblock gr_mouse	*/
 
	wm_update( 2 );			/* return exit object	*/
	Debug7( "Finish fm_do\r\n" );
	return( next_obj );
}



/*
*	Form dialogue routine to handle visual effects of drawing and
*	undrawing a dialogue
*/

	WORD
fm_dial(fmd_type, pi, pt)
	REG WORD	fmd_type;
	REG GRECT	*pi;
	REG GRECT	*pt;
{
	WORD		ret;
						/* adjust tree position	*/
	gsx_sclip( &gl_rscreen );

	ret = TRUE;

	switch( fmd_type )
	{
	  case FMD_START:			/* open a system window */
		break;

	  case FMD_GROW:			/* growing box		*/
		gr_growbox(pi, pt);
		break;

	  case FMD_SHRINK:			/* shrinking box	*/
		gr_shrinkbox(pi, pt);
		break;

	  case FMD_FINISH:			/* update certain portion of the screen	*/
		wm_update( 1 );
		w_drawchange( pt, NIL, NIL );
		wm_update( 0 );
		break;

	  default:
		ret = FALSE;
	}

	return( ret );
}


	WORD
fm_show(string, pwd, level)
	WORD		string;
	UWORD		*pwd;
	WORD		level;
{
	BYTE		*alert;
	REG BYTE	*ad_alert;

	ad_alert = alert = rs_str(string);
	if ( pwd )
	{
	  merge_str(&D.g_loc2[0], alert, pwd);
	  ad_alert = &D.g_loc2[0];
	}
	return( fm_alert( level, ( LONG )ad_alert ) );
}



/*	Extended fm_do	*/

	VOID
fm_xdo( tree, start_fld )
	OBJECT	*tree;
	WORD	start_fld;
{
	GRECT	pt;

	ob_center( ( LONG )tree, &pt );		/* get the x,y,w,h of the tree */


}

