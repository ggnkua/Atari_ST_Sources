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
/*	Check for click area at ev_multi	1/9/91	D.Mui		*/
/*	Take out g_wsend			1/9/91	D.Mui		*/
/*	Change at ev_block for Mint OS	7/23/91		D.Mui		*/
/*	Change at every functions who make ev_block call 7/23/91 D.Mui	*/
/*	Convert to Lattice C 5.51			 2/17/93 C.Gee  */
/*	Force the use of prototypes			 2/24/93 C.Gee  */

/*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------
*/	

/*
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.1
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
*/

#include "pgem.h"
#include "pmisc.h"

#include "machine.h"
#include "dispvars.h"
#include "mintbind.h"
						/* in ASYNC88.C		*/

EXTERN	WORD	cu_xrat, cu_yrat;
EXTERN	WORD	kstate;
EXTERN	PD	*gl_mowner;
EXTERN	WORD	cu_button;
EXTERN	WORD	gl_button;
EXTERN	PD	*errpd;
EXTERN	PD	*scr_pd;

GLOBAL	WORD	gl_dcrates[5] = {450, 330, 275, 220, 165};
GLOBAL	WORD	gl_dcindex;
GLOBAL	WORD	gl_dclick;
GLOBAL	UWORD	gl_ticktime;


/*
*	Stuff the return array with the mouse x, y, button, and keyboard
*	state.
*/

	VOID
ev_rets( rets )
	REG WORD	rets[];
{
	rets[0] = cu_xrat;
	rets[1] = cu_yrat;
	rets[2] = cu_button;
	rets[3] = kstate;
}


/*
*	Routine to block for a certain async event and return a
*	single return code.
*/

	EVB
*ev_block( code, lvalue )
	WORD		code;
	LONG		lvalue;
{
	EVSPEC		msk;

	if ( msk = iasync(code, lvalue) )
	{
	  mwait( msk );
	  return( eret( msk ) );
	}
	else
	  return( (EVB*) 0 );
}



/*
*	Wait for a key to be ready at the keyboard and return it. 
*/
	UWORD
ev_keybd( VOID )
{
	EVB	*e;

	if ( e = ev_block(AKBIN, 0x0L) )
	  return( e->e_char );
	else
	  return( 0 );
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
	REG EVB		*e;
	LONG		parm;

	parm = HW(bflgclks) | LW((bmask << 8) | bstate);

	if ( e = ev_block( ABUTTON, parm ) )
	{
	  rets[0] = e->e_mx;
	  rets[1] = e->e_my;
	  rets[2] = e->e_button;
	  rets[3] = kstate;
	  return( e->e_click );
	}
	else
	  return( 0 );
}


/*	
*	Wait for the mouse to leave or enter a specified rectangle.
*/

	UWORD
ev_mouse( pmo, rets )
	MOBLK		*pmo;
	WORD		rets[];
{
/*	EVB		*e;	*/

	if ( ev_block( AMOUSE, ( LONG )pmo ) )
	{
	  ev_rets( &rets[0] );
	  return( TRUE );
	}
	else
	  return( FALSE );
}


/*
*	Wait for a message to be received in applications message pipe.
*	Then read it into pbuff.
*/
	WORD
ev_mesag( pbuff )
	BYTE	*pbuff;
{
	return( ap_rdwr(AQRD, currpd->p_pid, EV_BUFSIZE, pbuff) );
}


/*
*	Wait the specified time to be completed.
*/
	WORD
ev_timer( count )
	LONG		count;
{
	count = count /(LONG) gl_ticktime;
	if ( count )
	{
	  if ( !ev_block( ADELAY, count ) )
	    return( FALSE );
	}
	return ( TRUE );
}


/*	Used by ev_multi() to check on mouse rectangle events	*/

	WORD
ev_mchk(pmo)
	REG MOBLK		*pmo;
{ 
	if ( pmo->m_out != inside( cu_xrat, cu_yrat, ( GRECT *)&pmo->m_x ) )
	  return( TRUE );
	else
	  return( FALSE );

	if ( ( currpd == gl_mowner ) && 
	     ( pmo->m_out != inside( cu_xrat, cu_yrat, ( GRECT *)&pmo->m_x) ) )
	  return( TRUE );
	else
	  return( FALSE );
}



/*	Check for any events that already happened	*/


	WORD
check_event( flags, pmo1, pmo2, tmcount, buparm, mebuff, prets )
	WORD		flags;
	LONG		tmcount,buparm;
	WORD		prets[];
	REG MOBLK	*pmo1;
	MOBLK		*pmo2;
	LONG		mebuff;
{
	WORD		what;
	CQUEUE		*pc;	

	what = 0;

	chkkbd();			/* process all the events	*/

	Debug7( " Check_event calls forker\r\n" );
	forker();

	/* Check for quick out if something has	already happened	*/

	if ( flags & MU_KEYBD )
	{
	  pc = &currpd->p_cda.c_q;	/* if a character is 	*/
	  if ( pc->c_cnt )		/* ready then get it	*/
	  {
	    prets[4] = (UWORD) dq( currpd );
	    what |= MU_KEYBD;
	  }
	}

	if ( flags & MU_BUTTON )
	{
	   Debug7( "Check button\r\n" );
	   if ( test_button( cu_button, buparm ) )
	   {
	      prets[2] = cu_button;
	      prets[5] = 1;		
	      what |= MU_BUTTON;
	   }

	   if ( currpd != ch_mowner( cu_button, 1 ) )
	      what &= ~MU_BUTTON;
	}

						/* quick check mouse rec*/
	if (flags & MU_M1)
	{
	  Debug7( "Check mu_m1: out=" );
	  Ndebug7(pmo1->m_out);
	  Debug7("x=");
	  Ndebug7(pmo1->m_x);
	  Debug7("y=");
	  Ndebug7(pmo1->m_y);
	  Debug7("w=");
	  Ndebug7(pmo1->m_w);
	  Debug7("h=");
	  Ndebug7(pmo1->m_h);
	  Debug7("\r\n");
	  if ( ev_mchk( pmo1 ) )
	    what |= MU_M1;
	}
						/* quick check mouse rec*/
	if (flags & MU_M2)
	{
	  Debug7( "Check mu_m2\r\n" );
	  if ( ev_mchk(pmo2) )
	    what |= MU_M2;
	}

						/* quick check message	*/
	if ( flags & MU_MESAG )
	{
	  Debug7( "0 Check mu_mesag\r\n" );
	  if ( currpd->p_qindex >= EV_BUFSIZE )	/* if there is message	*/
	  {
	    Debug7( "1 Check ev_mesag address is\r\n" );
	    Ndebug7( mebuff );
	    ev_mesag( ( BYTE *)mebuff );
	    what |= MU_MESAG;
	  }
	  else
	  {
	    Debug7( "2 Check rd_inmsg\r\n" );
	    if ( rd_inmsg( EV_BUFSIZE, ( BYTE *)mebuff ) )
	      what |= MU_MESAG;
  	  }
	}

	Debug7( "3 Check_event done\r\n" );

	if ( what )
	{
	  if ( flags & MU_TIMER )
	  {				/* if timer zero */
	    tmcount = tmcount / (LONG)gl_ticktime;

	    if ( !tmcount ) 	
	      what |= MU_TIMER;
	  }

	  ev_rets( &prets[0] );
	}

	Debug7( "End check_event\r\n" );
	return( what );
}


/*	Do a multi-wait on the specified events	*/

	WORD
ev_multi( flags, pmo1, pmo2, tmcount, buparm, mebuff, prets )
	REG WORD	flags;
	REG MOBLK	*pmo1;
	MOBLK		*pmo2;
	LONG		tmcount;
	LONG		buparm;	/* 31-16 click,15-8 mask,7-0 updown */
	LONG		mebuff;
	REG WORD	prets[];
{
	QPB		m;
	EVSPEC		wmask, kbmsk, bumsk,
#if 1
 xbumsk,
#endif
			m1msk, m2msk, qrmsk, tmmsk;
	REG EVSPEC	which;
	REG WORD	what;
	EVB		*e;

	what = wmask = kbmsk = bumsk = m1msk = m2msk = qrmsk = tmmsk = 0x0;
#if 1
	xbumsk = 0;
#endif
	if ( ( currpd->p_state == PS_ALLRUN ) && ( currpd != errpd ) 
		&& ( currpd != scr_pd ) )
	{
	  Debug7( currpd->p_name );
	  Debug7( " send_ctrl 1 message\r\n" );
	  send_ctrl( currpd, 1 );
	}
	
	/* Check for quick out if something has	already happened	*/

	what = check_event( flags, pmo1, pmo2, tmcount, buparm, mebuff, prets );

					/* quick check timer	*/
	if ( flags & MU_TIMER ) 
	{
	  tmcount /= (LONG)gl_ticktime;
	  if ( !( tmcount ) )
	  {
	    if ( currpd->p_state == PS_RUN )
	      what |= MU_TIMER;
	    else
	      tmcount = (LONG)gl_ticktime;
	  }
	}

	if ( !what )				
	{
	  if (flags & MU_KEYBD)			/* wait for keyboard	*/
	    wmask |= kbmsk = iasync( AKBIN, 0x0L );

	  if (flags & MU_BUTTON)		/* wait for a button	*/	
	    wmask |= bumsk = iasync( ABUTTON, buparm );

#if 1		/* MU_XBUTTON isn't used anywhere else! */
	  if (flags & MU_XBUTTON)
	    wmask |= xbumsk = iasync( AXBUTTON, buparm ); 
#endif
	  if (flags & MU_M1)			/* wait for mouse rect.	*/
	    wmask |= m1msk = iasync( AMOUSE, ( LONG )pmo1 ); 
					
	  if (flags & MU_M2)			/* wait for mouse rect.	*/
	    wmask |= m2msk = iasync( AMOUSE, ( LONG )pmo2 ); 

	  if (flags & MU_MESAG)			/* wait for message	*/
	  {
	    m.qpb_pid = currpd->p_pid;
	    m.qpb_cnt = EV_BUFSIZE;
	    m.qpb_buf = ( BYTE *)mebuff;
	    wmask |= qrmsk = iasync( AQRD, ( LONG )&m );
	  }
					
	  if ( flags & MU_TIMER )		/* wait for timer	*/
	    wmask |= tmmsk = iasync( ADELAY, tmcount );

	  which = mwait( wmask );		/* wait for events	*/

	  which |= acancel( currpd, wmask );	/* cancel outstanding events	*/
							
	}
	else
	{
	  if ( currpd->p_state == PS_ALLRUN )
	  {
	    if ( cpdid == currpd->p_pid )
	      cpdid = -1;
	    
	    currpd->p_state = PS_RUN;
	  }
	}
			
	ev_rets( &prets[0] );	/* get the current system variables	*/


				/* Now get the real run time system 	*/
				/* variables				*/
	if ( !what )
	{
	  if ( which & kbmsk )			/* keyboard event	*/
	  {
	    e = eret( kbmsk );
	    prets[4] = e->e_char;
	    prets[3] = e->e_kstate;	
	    what |= MU_KEYBD;
 	  }

	  if ( which & bumsk )			/* button event	*/
	  {
	    if ( e = eret( bumsk ) )
	    {
	      prets[0] = e->e_mx;
	      prets[1] = e->e_my;
	      prets[2] = e->e_button;
	      prets[5] = e->e_click;
	      what |= MU_BUTTON;
	    }
	  }

#if 1
/* MU_XBUTTON isn't used anywhere. What's it supposed to do?  Note
 * that gemasync.c doesn't even look at AXBUTTON, so this code is
 * bogus until gemasync.c is updated!
 * or is it... commenting it out causes all sorts of bizarreness.
 * what's going on???
 */
	  if ( which & xbumsk )			/* or button event	*/
	  {
	    if ( e = eret( xbumsk ) )
	    {
	      prets[0] = e->e_mx;
	      prets[1] = e->e_my;
	      prets[2] = e->e_button;
	      prets[5] = e->e_click;
	      what |= MU_XBUTTON;
	    }
	  }
#endif
	  if ( which & m1msk )
	  {
	    Debug7("ev_multi: m1msk event\r\n");
	    aret( m1msk );
	    what |= MU_M1;
	  }

	  if ( which & m2msk )
	  {
	    aret( m2msk );
	    what |= MU_M2;
	  }

	  if ( which & qrmsk )
	  {
	    aret( qrmsk );
	    what |= MU_MESAG;
	  }

	  if ( which & tmmsk )
	  {
	    aret( tmmsk );
	    what |= MU_TIMER;
	  }
	}

	Debug7("ev_multi(): exiting\r\n");	
	return( what );			/* return what happened */
}


/*
* Set the double-click speed.
*/
	WORD
ev_dclick( rate, setit )
	WORD		rate, setit;
{
	if ( setit )
	{
	  gl_dcindex = rate;
	  gl_dclick = gl_dcrates[gl_dcindex] / gl_ticktime ;
	}

	return( gl_dcindex );
}

