/*	GEMFLAG.C	1/27/84 - 02/08/85	Lee Jay Lorenzen	*/
/*	Reg Opt		03/09/85		Derek Mui		*/
/*	1.1		03/23/85 - 6/19/85	Lowell Webster		*/
/*	Add window update free stuff	3/7/88	D.Mui			*/
/*	Fix at unsync	3/7/88			D.Mui			*/
/*	Moved wm_update and wm_new to here 	2/26/91	D.Mui		*/
/*	Change at take_ownership		4/23/91	D.Mui		*/	
/*	Convert to Lattice C 5.51		2/17/93 C.Gee		*/
/*	Force the use of prototypes		2/24/93	C.Gee		*/

/*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------
*/	

/*
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.01
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
*/
#include "pgem.h"
#include "pmisc.h"

#include "machine.h"
#include "dispvars.h"
#include "mintbind.h"


EXTERN	WORD	gl_multi;
EXTERN	WORD	aesid;
EXTERN	WORD	gl_smid;
EXTERN	GRECT	gl_rscreen;
EXTERN  WORD	gl_kbid;
EXTERN	PD	*gl_mowner;
EXTERN	OBJECT	*gl_mntree;
EXTERN	PD	*errpd;

static	OBJECT	*ml_mnhold;
static	PD	*ml_pmown;
static	PD	*ml_pkown;
static 	PD	*ml_pcown;
static	GRECT	ml_ctrl;
static	WORD	ml_ocnt;



/*	Transfer the the ownership of the whole system		*/

	VOID
take_ownership( ownit )
	WORD	ownit;
{
	Debug7( currpd->p_name );
	Debug7( " Take_ownership " );

	if ( ownit )			/* 1 = mouse control	   */
	{
	  if ( spdid )
	  {
	    Debug7( "spd owner is " );
	    Debug7( idtopd( spdid )->p_name );
	    Debug7( "\r\n" );
	  }

	  wm_update( 1 );		/* are we ready?	*/
	  if ( ml_ocnt == 0 )
	  {
	    ml_pmown = gl_mowner;		/* save the mouse owner	   */
	    ml_pkown = idtopd( gl_kbid );	/* save the keyboard owner */
	    gl_mowner = currpd;
	    gl_smid = gl_kbid = currpd->p_pid;
	  }
	  ml_ocnt++;

	  Debug7( "set " );
	  if ( gl_smid )
	    Debug7( idtopd( gl_smid )->p_name );
	  else
	    Debug7( "nobody" );
	 
	  Debug7( "\r\n" );
	}
	else
	{					/* 0 = end mouse control   */
	  ml_ocnt--;
	  if ( ml_ocnt == 0 )
	  {
	    gl_mowner = ml_pmown;		/* restore ownerships	*/
	    gl_kbid = ml_pkown->p_pid;
	    gl_smid = 0;
	  }
	  wm_update( 0 );
	
	  Debug7( "restore mouse\r\n" );
	}
}


/*	Wake up the screen waiting process	*/

	VOID
unsync( VOID )
{
	PD	*p;
	
	if ( p = slr )	/* if sombody is waiting then wake him up */
	{
	  Debug7( p->p_name );
	  Debug7( " is unblocked (unsync)\r\n" );
	  slr = p->p_link;
	  spdid = p->p_pid;
	  p->p_state = PS_READY;
	  link_tail( &drl, p );
	}
	else {
	  Debug7("unsync: clear spdid\r\n");
	  spdid = 0;
	}
}


/*	Release the window control and let the sleeping process awake	*/

	WORD
nosync( VOID )
{
	if ( currpd->p_wmtas )
	  currpd->p_wmtas--;
	
	if ( spdid == currpd->p_pid )	/* does he owns the screen?*/
	{
	  Debug7( currpd->p_name );
	  Debug7( " release wm_update\r\n" );	  
	  if ( !currpd->p_wmtas ) {	/* count down		*/
	    unsync();			/* wake someone up	*/
	  } else {
		Debug7("unsync not called, p_wmtas="); Ndebug7((LONG)currpd->p_wmtas);
	  }
	  return( TRUE ); 
	}
	Debug7("nosync failed\r\n");
	return( FALSE );
}


/*	Release the window control by this process	*/

	WORD
ch_wmlock( p, reset )
	WORD	reset;
	PD	*p;
{
	if ( reset )
	  p->p_wmtas = 0;

	if ( p->p_pid == spdid )	/* it is owning the screen	*/
	{
	  unsync();			/* so release it		*/
	  return( TRUE );
	}
	else
	{
	  unlink_pd( &slr, p );
	  return( FALSE );
	}
}

/*	Mutual exclusion works this way. If a process does a 		*/
/*	wind_update( TRUE ) call, then the ownership of the window	*/
/*	will be given to this process. However if other process wants 	*/
/*	to claim ownership and does a wind_update( TRUE ) call also, it */
/*	will be blocked until the wind_update( FALSE ) is called by 	*/
/*	the owner. But if the second process doesn't do a wind_update 	*/
/*	call then it will still have the right to access the controlled */
/*	area despite the screen is owned by somebody else.		*/

/*	Locks or unlocks the current state of the window tree while an	*/ 
/*	application is responding to a window update message in his 	*/
/*	message pipe or is making some other direct screen update based	*/
/*	on his current rectangle list.					*/


        WORD
wm_update ( flag )
        WORD	flag;
{				/* if critical error then bypass it	*/

	WORD	ret;

	Debug6("Wm_update called, flag="); Ndebug6((LONG)flag);

	if ( ( !currpd ) || ( currpd == errpd ) || ( currpd->p_pid == aesid ) 
	     || ( currpd->p_state == PS_DEAD ) 
	     || ( currpd->p_state == PS_ZOMBIE ) ) {
	  Debug6("Wm_update returns FALSE\r\n");
	  return( FALSE );
	}


	ret = TRUE;

	switch( flag & 0x00FF )
	{
	  case 0:		/* normal wm_update stuff	*/	
	    ret = nosync();	/* give up window control	*/
	    break;

	  case 1:
	    if ( flag & 0x0100 )/* just checking */
	    {
	      if ( ( spdid ) && ( currpd->p_pid != spdid ) )
		return( FALSE );
	    }
			
	    currpd->p_wmtas++;

	    if ( spdid )		/* is someone locking the screen*/
	    {				/* yes		*/
              if ( currpd->p_pid != spdid )	/* himself ?	*/
	      {				/* No		*/
		currpd->p_prvstate = currpd->p_state;
		currpd->p_state = PS_BLOCKED;
		Debug6( "wm_update call dsptch\r\n" );	
		if ( !dsptch() )	/* REALLY??? */
		{
	  	  Debug6( "Wm_update calls dsptch fails\r\n" );
		  while(1)
		  {
		  }
		}
	      }
	    }
	    else
	      spdid = currpd->p_pid;	/* this guy owns the screen	*/

	    break;

	 case 2:
           take_ownership( 0 );
	   break;

	 case 3:         
	    if ( flag & 0x0100 )/* just checking */
	    {
	      if ( ( spdid ) && ( currpd->p_pid != spdid ) ) {
		Debug6("Wm_update returns FALSE (checking mode)\r\n");	
		return( FALSE );
	      }
	    }

           take_ownership( 1 );
	   break;

	 case 4:		/* release window control	*/
	
	 case 5: 		/* take over window control	*/
		
	   break;		 	
        }

	Debug6("Wm_update returns TRUE\r\n");	
	return( ret );
}




