/*
*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/gemfmlib.c,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:22:52 $	$Locker: kbad $
* =======================================================================
*  $Log:	gemfmlib.c,v $
* Revision 2.2  89/04/26  18:22:52  mui
* TT
* 
* Revision 2.1  89/02/22  05:26:14  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.3  89/01/24  15:09:54  mui
* Fix the find_obj, check current object before incrementing to next
* 
* Revision 1.2  89/01/24  05:15:44  kbad
* optimize eralert
* 
* Revision 1.1  88/06/02  12:33:44  lozben
* Initial revision
* 
*************************************************************************
*/
/*	GEMFMLIB.C	03/15/84 - 02/08/85	Gregg Morris		*/
/*	to 68k		03/12/85 - 05/24/85	Lowell Webster		*/
/*	Trying 1.2	10/11/85 - 10/21/85	Derek Mui		*/
/*	Removed error 16	2/6/86		Derek Mui		*/
/*	repaired get_par to new bind 01/03/87	Mike Schmal		*/
/*	Modify rsc constants	11/25/87	D.Mui			*/
/*	Crunch out fm_inifld	03/25/88	D.Mui			*/
/*	Change at fm_do		04/10/88	D.Mui			*/


#include <portab.h>
#include <machine.h>
#include <struct88.h>
#include <baspag88.h>
#include <obdefs.h>
#include <taddr.h>
#include <gemlib.h>
#include <gemusa.h>

#define FORWARD 0
#define BACKWARD 1
#define DEFLT 2
#define BELL 0x07				/* bell			*/

#define BACKSPACE 0x0E08			/* backspace		*/
#define SPACE 0x3920				/* ASCII <space>	*/
#define UP 0x4800				/* up arrow		*/
#define DOWN 0x5000				/* down arrow		*/
#define LEFT 0x4B00				/* left arrow		*/
#define RIGHT 0x4D00				/* right arrow		*/
#define DELETE 0x5300				/* keypad delete	*/
#define TAB 0x0F09				/* tab			*/
#define BACKTAB 0x0F00				/* backtab		*/
#define RETURN 0x1C0D				/* carriage return	*/

#if ATARI
#define ENTER 0x720D				/* enter key on keypad	*/
#endif
						/* in WMLIB.C		*/
EXTERN VOID		w_drawchange();
						/* in GEMRSLIB.C	*/
EXTERN BYTE		*rs_str();

EXTERN WORD		gl_width;
EXTERN WORD		gl_height;
EXTERN GRECT		gl_rfull;
EXTERN GRECT		gl_rscreen;
EXTERN GRECT		ctrl;

EXTERN WORD		gl_hbox;
EXTERN WORD		mtrans;
EXTERN LONG		ad_sysglo;

EXTERN THEGLO		D;


MLOCAL WORD	ml_alrt[] = 
		{ALRT00CRT,ALRT01CRT,ALRT02CRT,ALRT03CRT,ALRT04CRT,
			ALRT05CRT, ALRTDSWAP};
MLOCAL WORD	ml_pwlv[] = 
		{0x0102,0x0102,0x0102,0x0101,0x0002,0x0001,0x0101};

/*	This routine has been move to gemctrl.c		*/
/*	and renamed to take_ownership			*/

#if UNLINKED
/*	0 = end mouse control	*/
/*	1 = mouse control	*/

	VOID
fm_own(beg_ownit)
	WORD		beg_ownit;
{

	if ( beg_ownit )
	{
	  wm_update(TRUE);
	  if (ml_ocnt == 0)
	  {
	    ml_mnhold = gl_mntree;		/* save the current menu   */
	    gl_mntree = 0x0L;			/* no menu		   */
	    rc_copy( &ctrl, &ml_ctrl );		/* get_ctrl(&ml_ctrl);     */
						/* save the control rect   */
	    /* get_mkown(&ml_pmown, &ml_pkown); */
	
	    ml_pmown = gl_mowner;		/* save the mouse owner	   */
	    ml_pkown = gl_kowner;     		/* save the keyboard owner */

	    ct_chgown( rlr, &gl_rscreen );	/* change mouse ownership  */
	  }					/* and the control rect    */
	  ml_ocnt++;
	}
	else
	{
	  ml_ocnt--;
	  if (ml_ocnt == 0)
	  {
	    ct_chgown(ml_pkown, &ml_ctrl);	/* restore mouse owner	   */
	    gl_mntree = ml_mnhold;		/* restore menu tree	   */
	  }
	  wm_update(FALSE);
	}
}
#endif

/************************************************************************/
/* f i n d _ o b j							*/
/************************************************************************/
	WORD
find_obj(tree, start_obj, which)
	REG LONG	tree;
	WORD		start_obj;
	WORD		which;
{
	REG WORD	obj, flag, theflag, inc;
	WORD		last_obj;

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
						/* handle character	*/
	direction = -1;

	switch( *pchar )
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
	  *pchar = 0x0;
	  *pnew_obj = find_obj( tree, obj, direction );
	  if ( ( direction == DEFLT ) && ( *pnew_obj != 0 ) )
	  {
	    ob_change(tree, *pnew_obj, 
			LWGET(OB_STATE(*pnew_obj)) | SELECTED, TRUE);
	    return(FALSE);
	  }
	}

	return(TRUE);
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
	    ev_button(1, 0x00010000L, &rets[0]);
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
	return( cont );
}


/*
*	ForM DO routine to allow the user to interactively fill out a 
*	form.  The cursor is placed at the starting field.  This routine
*	returns the object that caused the exit to occur
*/
	WORD
fm_do(tree, start_fld)
	REG LONG	tree;
	WORD		start_fld;
{
	REG WORD	edit_obj,cont;
	WORD		next_obj;
	WORD		which;
	WORD		idx;
	WORD		rets[6];
						/* grab ownership of 	*/
						/*   screen and mouse	*/
	take_ownership(TRUE);	
						/* flush keyboard	*/
	fq();
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
	  which = ev_multi(MU_KEYBD | MU_BUTTON, NULLPTR, NULLPTR,
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
	      trap13( 0x00030002L, 7 );		/* Bconout(CON, 7)	*/
	      next_obj = 0;
	    }
	    else
	    {
	      cont = fm_button(tree, next_obj, rets[5], &next_obj);
	    }
	  }
						/* handle end of field	*/
						/*   clean up		*/
	  if ( (!cont) ||
	       ((next_obj != 0) && 
		(next_obj != edit_obj)) )

	  {
	    ob_edit(tree, edit_obj, 0, &idx, EDEND);
	  }
	}
						/* give up mouse and	*/
						/*   screen ownership	*/
	take_ownership(FALSE);	
						/* return exit object	*/
	return(next_obj);
}



/*
*	Form DIALogue routine to handle visual effects of drawing and
*	undrawing a dialogue
*/
	VOID
fm_dial(fmd_type, pi, pt)
	REG WORD		fmd_type;
	REG GRECT		*pi;
	REG GRECT		*pt;
{
						/* adjust tree position	*/
	gsx_sclip(&gl_rscreen);
	switch( fmd_type )
	{
#if UNLINKED
	  case FMD_START:
						/* grab screen sync or	*/
						/*   some other mutual	*/
						/*   exclusion method	*/
		break;
#endif
	  case FMD_GROW:
						/* growing box		*/
		gr_growbox(pi, pt);
		break;
	  case FMD_SHRINK:
						/* shrinking box	*/
		gr_shrinkbox(pi, pt);
		break;
	  case FMD_FINISH:
						/* update certain 	*/
						/*   portion of the	*/
						/*   screen		*/
		w_drawchange(pt, NIL, NIL );
		break;
	}
}


	WORD
fm_show(string, pwd, level)
	WORD		string;
	UWORD		*pwd;
	WORD		level;
{
	WORD		ret;
	BYTE		*alert;
	REG BYTE	*ad_alert;

	ad_alert = alert = rs_str(string);
	if (pwd)
	{
	  merge_str(&D.g_loc2[0], alert, pwd);
	  ad_alert = &D.g_loc2[0];
	}
	return( fm_alert(level, ad_alert) );
}


				/* TRO 9/20/84	- entered from dosif	*/
				/* when a DOS error occurs		*/
	WORD
eralert(n, d)	
	WORD		n;		/* n = alert #, 0-5 	*/	
	WORD		d;		/* d = drive code, 0=A	*/
{
	WORD		*pdrive_let;
	WORD		drive_let;

	pdrive_let = &drive_let;
	drive_let = ( d + 'A' ) << 8;	/* make it a 2 char string!	*/

					/* which alert			*/
	return( fm_show( ml_alrt[n],
					/* string to copy in (or null)	*/
			 (ml_pwlv[n] & 0xff00) ? &pdrive_let : NULLPTR,
					/* icon to use			*/
			 ml_pwlv[n] & 0x00ff ) != 1 );

}


	WORD
fm_error(n)
	WORD		 n;	/* n = dos error number */
{
	REG WORD		string;


	if ( n > 63 )		/* nothing for xtal errors */
	  return( FALSE );


	switch (n)
	{
	  case 2:			/* file not found	*/
	  case 18:			/* no more files	*/
	  case 3:			/* path not found	*/
		string = ALRT18ERR;
		break;
	  case 4:			/* too many open files	*/
		string = ALRT04ERR;
		break;
	  case 5:			/* access denied	*/
		string = ALRT05ERR;
		break;
	  case 8:			/* insufficient memory	*/
	  case 10:			/* invalid environmeny	*/
	  case 11:			/* invalid format	*/
		string = ALRT08ERR;
		break;
	  case 15:			/* invalid drive	*/
		string = ALRT15ERR;
		break;
	  default:
		string = ALRTXXERR;
	}

	return( fm_show(string, (string == ALRTXXERR) ? &n : NULLPTR, 1) != 1 );
}
