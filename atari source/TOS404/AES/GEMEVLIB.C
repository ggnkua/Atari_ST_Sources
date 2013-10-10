/*
*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/gemevlib.c,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:22:19 $	$Locker: kbad $
* =======================================================================
*  $Log:	gemevlib.c,v $
* Revision 2.2  89/04/26  18:22:19  mui
* TT
* 
* Revision 2.1  89/02/22  05:25:53  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  88/06/02  12:31:43  lozben
* Initial revision
* 
*************************************************************************
*/
/*	GEMEVLIB.C	1/28/84 - 02/02/85	Lee Jay Lorenzen	*/
/*	Reg Opt		03/09/85		Derek Mui		*/
/*	1.1		03/21/85 - 04/10/85	Lowell Webster		*/
/*	Change the double click 0 to 64 tick  2/20/86	Derek Mui	*/
/*	Change at ev_ret for tbutton	10/29/86	Derek Mui	*/
/*	Change at ev_multi for tbutton	10/30/86	Derek Mui	*/
/*	Change at ev_multi	10/31/86		Derek Mui	*/
/*	Change the click speed  12/15/86		Derek Mui	*/
/*	Fix multiple button	12/16/86		Derek Mui	*/
/*	Unfix double click speed 12/16/86		Derek Mui	*/
/*	Fix at ev_multi and mesag for smooth scrolling 3/11/87 Derek Mui*/


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
#include <gemlib.h>


EXTERN	PD	*mowner();
EXTERN	EVSPEC	iasync();
EXTERN	EVSPEC	acancel();
EXTERN	EVSPEC	aret();
EXTERN	EVSPEC	mwait();

EXTERN	WORD	xrat, yrat, button, kstate, mclick, mtrans;
EXTERN	WORD	pr_button, pr_xrat, pr_yrat, pr_mclick;

EXTERN	PD	*gl_mowner;
EXTERN	WORD	tbutton;

GLOBAL	WORD	gl_dcrates[5] = {450, 330, 275, 220, 165};
GLOBAL	WORD	gl_dcindex;
GLOBAL	WORD	gl_dclick;
GLOBAL	WORD	gl_ticktime;



/*
*	Stuff the return array with the mouse x, y, button, and keyboard
*	state.
*/
	VOID
ev_rets(rets)
	REG WORD		rets[];
{
	if ( mtrans )
	{
	  rets[0] = pr_xrat;
	  rets[1] = pr_yrat;
	}
	else
	{
	  rets[0] = xrat;
	  rets[1] = yrat;
	}

	rets[2] = tbutton;
	rets[3] = kstate;
	mtrans = 0;
}


/*
*	Routine to block for a certain async event and return a
*	single return code.
*/
	WORD
ev_block(code, lvalue)
	WORD		code;
	LONG		lvalue;
{
	EVSPEC		msk;

	mwait(msk = iasync(code, lvalue) );
	return( aret(msk) );
}



/*
*	Wait for a key to be ready at the keyboard and return it. 
*/
	UWORD
ev_keybd()
{
	return( ev_block(AKBIN, 0x0L) );
}


/*
*	Wait for the mouse buttons to reach the state where:
*		((bmask & (bstate ^ button)) == 0) != bflag
*	Clicks is how many times to wait for it to reach the state, but
*	the routine should return how many times it actually reached the
*	state before some time interval.
*/
	UWORD
ev_button(bflgclks, bmask, bstate, rets)
	WORD		bflgclks;
	UWORD		bmask;
	UWORD		bstate;
	WORD		rets[];
{
	WORD		ret;
	LONG		parm;

	parm = HW(bflgclks) | LW((bmask << 8) | bstate);
	ret = ev_block(ABUTTON, parm);
	ev_rets(&rets[0]);
	return(ret);
}


/*
*	Wait for the mouse to leave or enter a specified rectangle.
*/
	UWORD
ev_mouse(pmo, rets)
	MOBLK		*pmo;
	WORD		rets[];
{
	WORD		ret;

	ret = ev_block(AMOUSE, ADDR(pmo));
	ev_rets(&rets[0]);
	rets[2] = button;
	return(ret);
}


/*
*	Wait for a message to be received in applications message pipe.
*	Then read it into pbuff.
*/
	WORD
ev_mesag(pbuff)
	LONG		pbuff;
{
	if ( rlr->p_qindex > 0 )
	  return( ap_rdwr(AQRD, rlr->p_pid, 16, pbuff) );
	else
	{
	  if ( !rd_mymsg( pbuff ) )
	    return( ap_rdwr(AQRD, rlr->p_pid, 16, pbuff) );
	}

	return( TRUE );
}


/*
*	Wait the specified time to be completed.
*/
	WORD
ev_timer(count)
	LONG		count;
{
	return( ev_block(ADELAY, count / gl_ticktime) );
}

/*
*	Used by ev_multi() to check on mouse rectangle events
*/
	WORD
ev_mchk(pmo)
	REG MOBLK		*pmo;
{ 
	if ( (rlr == gl_mowner) &&
	     (pmo->m_out != inside(xrat, yrat, &pmo->m_x)) )
	  return( TRUE );
	else
	  return(FALSE);
}


/*
*	Do a multi-wait on the specified events.
*/
	WORD
ev_multi(flags, pmo1, pmo2, tmcount, buparm, mebuff, prets)
	REG WORD		flags;
	REG MOBLK		*pmo1;
	MOBLK		*pmo2;
	LONG		tmcount;
	LONG		buparm;
	LONG		mebuff;
	REG WORD		prets[];
{
	QPB		m;
	EVSPEC		wmask, kbmsk, bumsk, 
			m1msk, m2msk, qrmsk, tmmsk;
	REG EVSPEC		which;
	REG WORD		what;
	REG CQUEUE		*pc;
						/* say nothing has 	*/
						/*   happened yet	*/
	what = wmask = kbmsk = bumsk = m1msk = m2msk = qrmsk = tmmsk = 0x0;
		 				/* do a pre-check for a	*/
						/*   keystroke & then	*/
						/*   clear out the forkq*/
	chkkbd();
	forker();

						/*   a keystroke	*/
	if (flags & MU_KEYBD)
	{
						/* if a character is 	*/
						/*   ready then get it	*/
	  pc = &rlr->p_cda->c_q;
	  if ( pc->c_cnt )
	  {
	    prets[4] = (UWORD) dq(pc);
	    what |= MU_KEYBD;
	  }
	}
						/* quick check button	*/
	if (flags & MU_BUTTON)
	{
	  if ( rlr == gl_mowner )
	  {
	    if ( (mtrans > 1) &&
		 (downorup(pr_button, buparm)) )
	    {
	      tbutton = pr_button;		/* changed */
	      what |= MU_BUTTON;
	      prets[5] = pr_mclick;
	    }
	    else
	    {
	      if ( downorup(button, buparm) )
	      {
		tbutton = button; 		/* changed */
	        what |= MU_BUTTON;
	        prets[5] = mclick;
	      }
	    }

	    if ( mowner( tbutton ) != rlr )
	      what &= ~MU_BUTTON;	
	  }
	}
						/* quick check mouse rec*/
	if (flags & MU_M1)
	{
	  if ( ev_mchk(pmo1) )
	    what |= MU_M1;
	}
						/* quick check mouse rec*/
	if (flags & MU_M2)
	{
	  if ( ev_mchk(pmo2) )
	    what |= MU_M2;
	}
						/* quick check timer	*/
	if (flags & MU_TIMER)
	{
	  if ( (wmask == 0x0) &&
	       (tmcount == 0x0L) )
	    what |= MU_TIMER;
	}
						/* quick check message	*/
	if (flags & MU_MESAG)
	{
	  if ( rlr->p_qindex > 0 )
	  {
	    ev_mesag( mebuff );
	    what |= MU_MESAG;
	  }
	  else
	  {
	    if ( rd_mymsg( mebuff ) )	
	        what |= MU_MESAG;
	  }
	}
						/* check for quick out	*/
						/*   if something has	*/
						/*   already happened	*/
	if (what == 0x0)
	{
	  if (flags & MU_KEYBD)
	    wmask |= kbmsk = iasync( AKBIN, 0x0L );
						/* wait for a button	*/
	  if (flags & MU_BUTTON)
	    wmask |= bumsk = iasync( ABUTTON, buparm ); 
						/* wait for mouse rect.	*/
	  if (flags & MU_M1)
	    wmask |= m1msk = iasync( AMOUSE, ADDR(pmo1) ); 
						/* wait for mouse rect.	*/
	  if (flags & MU_M2)
	    wmask |= m2msk = iasync( AMOUSE, ADDR(pmo2) ); 
						/* wait for message	*/
	  if (flags & MU_MESAG)
	  {
	    m.qpb_pid = rlr->p_pid;
	    m.qpb_cnt = 16;
	    m.qpb_buf = mebuff;
	    wmask |= qrmsk = iasync( AQRD, ADDR(&m) );
	  }
						/* wait for timer	*/
	  if (flags & MU_TIMER)
	    wmask |= tmmsk = iasync( ADELAY, tmcount / gl_ticktime );
						/* wait for events	*/
	  which = mwait( wmask );
						/* cancel outstanding	*/
						/*   events		*/
	  which |= acancel( wmask );
	}
						/* get the returns	*/

	ev_rets(&prets[0]);
	if (! (flags & MU_BUTTON) )
	  prets[2] = button;

						/* do arets() if 	*/
						/*   something hasn't	*/
						/*   already happened	*/
	if (what == 0x0)
	{
	  if (which & kbmsk)
	  {
	    prets[4] = (UWORD) aret(kbmsk);
	    what |= MU_KEYBD;
 	  }
	  if (which & bumsk)
	  {
	    prets[5] = (UWORD) aret(bumsk);
	    prets[2] = tbutton;
	    what |= MU_BUTTON;
	  }
	  if (which & m1msk)
	  {
	    aret(m1msk);
	    what |= MU_M1;
	  }
	  if (which & m2msk)
	  {
	    aret(m2msk);
	    what |= MU_M2;
	  }
	  if (which & qrmsk)
	  {
	    aret(qrmsk);
	    what |= MU_MESAG;
	  }
	  if (which & tmmsk)
	  {
	    aret(tmmsk);
	    what |= MU_TIMER;
	  }
	}

 	  	  	  		/* return what happened */
	return( what );
}


/*
*	Wait for a key to be ready at the keyboard and return it. 
*/
	WORD
ev_dclick(rate, setit)
	WORD		rate, setit;
{
	if (setit)
	{
	  gl_dcindex = rate;
	  gl_dclick = gl_dcrates[gl_dcindex] / gl_ticktime ;
	}

	return( gl_dcindex );
}

