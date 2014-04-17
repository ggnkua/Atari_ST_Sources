/*	GEMASYNC.C	1/27/84 - 02/05/85	Lee Jay Lorenzen	*/
/*	to 68k		03/09/85 - 04/05/85		Derek Mui	*/
/*	remove bit_num	06/10/85			Mike Schmal	*/
/*	Change at aret for tbutton 10/29/86		Derek Mui	*/
/*	Change at mwait for acc wait	7/13/90		D.Mui		*/
/*	Evinsert is fine tuned		1/17/91		D.Mui		*/
/*	Change at iasync for button events	3/7/91	D.Mui		*/
/*	Change aret and eret			3/14/91	D.Mui		*/
/*	iasync button event checks for mouse ownership	4/22/91		*/
/*	iasync return 0 for error			4/23/91 	*/
/*	Change at mwait for Mint OS	7/23/91		D.Mui		*/
/*	Change at acancel( p )		7/24/91		D.Mui		*/
/*	Convert to Lattice C 5.51	02/25/93	C.Gee		*/
/*	Force the use of prototypes					*/

/*	-----------------------------------------------------------
*	AES Version 4.0	MultiTOS version is written by Derek M. Mui
*	Copyright (C) 1992 
*	Atari (U.S.) Corp
*	All Rights Reserved
*	-----------------------------------------------------------
*/	

/*
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.0
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
*/
#include "pgem.h"
#include "pmisc.h"

#include "machine.h"
#include "dispvars.h"
#include "mintbind.h"
						/* in OPTIMIZE.C	*/
						/* in DSPTCH88.C	*/
EXTERN	WORD	cu_button;
EXTERN	WORD	gl_bpend;
EXTERN	LONG	CMP_TICK;
EXTERN	LONG	NUM_TICK;
EXTERN	WORD	cu_xrat;	/* current mouse x after being processed*/
EXTERN	WORD	cu_yrat;
EXTERN	PD	*gl_mowner;
EXTERN	WORD	gl_button;
EXTERN	PD	*errpd;
EXTERN	PD	*scr_pd;


/*	Get a EVB from the PD structure	*/

	EVB
*get_evb( p )
	PD	*p;
{
	REG EVB		*e;
	WORD		i;

	if ( !p )
	   return( (EVB*)0 );

	for ( i = 0; i < NUMEVB; i++ )
	{
	  e = &p->p_evb[i];
	  if ( !e->e_mask )
	  {
	    bfill( sizeof(EVB), 0, ( BYTE *)e );
	    break;
	  }
	}

	if ( i == NUMEVB )
	  return( (EVB*)0 );

	return( e );
}


/*	Remove the event from the CDA	*/
/*	ret may have number of clicks 	*/
/*	or the desired character 	*/

	VOID
evremove( e, ret )
	REG EVB		*e;
	UWORD		ret;
{
					/* unlinked this EVB, and aret()*/
	e->e_return |= (UWORD) ret;	/* will remove and free the EVB	*/

	if ( !e->e_pred )		/* at the head?	*/
	  *(e->e_head) = e->e_link;	
	else		
	  e->e_pred->e_link = e->e_link;

	if ( e->e_link )
	  e->e_link->e_pred = e->e_pred;

	zombie(e);
}



/*	Insert an EVB into the event list	*/
/*	Always link at the head			*/

	VOID
evinsert( e, root )
	REG EVB		*e;
	EVB		**root;
{
	REG EVB		*q;

	e->e_head = root;
				/* always link to the head	*/

	if ( q = *root )	/* head has something ?		*/
	{				
	  e->e_pred = q->e_pred;
	  q->e_pred = e;
	}
	else
	  e->e_pred = (EVB*)0;

	e->e_link = q;	
	*root = e;
}


/*	Take a timer event off the list. must be NODISP	*/

	VOID
takeoff( e )
	REG EVB		*e;
{
	REG LONG	c;
/*	LONG		old;*/
	REG WORD	oldsr;

	oldsr = spl7();

	if ( !e->e_pred )
	  *(e->e_head) = e->e_link;
	else
	  e->e_pred->e_link = e->e_link;

	if ( e->e_link )		
	{
	  e->e_link->e_pred = e->e_pred;

	  if ( e->e_flag & EVDELAY )
	  {
	    c = (LONG) e->e_link->e_parm;
	    c += (LONG) e->e_parm;
	    e->e_link->e_parm = (LONG) c;
	  }
	}

	e->e_mask = 0;

	spl(oldsr);
}


/*	Let this process go into the waiting mode	*/
/*	Return a non-zero number otherwise this process	*/
/*	needs to wait for event to happen		*/

	EVSPEC
mwait( mask )
	EVSPEC		mask;
{
	REG PD		*p;
/*	WORD		pri;	*/

	p = currpd;
	p->p_evwait |= mask;

	if ( !( mask & p->p_evflg ) )	/* if nothing happen	*/
	{
	  if ( ( p->p_state == PS_ALLRUN ) && ( p != errpd ) 
		&& ( p != scr_pd ) )
	  {
	    Debug7( p->p_name );
	    Debug7( " send_ctrl 1 message\r\n" );
/*	    send_ctrl( p, 1 );	*/
	  }

          p->p_prvstate = p->p_state;
	  p->p_state = PS_MWAIT;	/* wait for event	*/
/*	  Debug0( "Mwait calls mwait\r\n" );	*/
	  if ( !dsptch() )
	  {
	    Debug1( "Mwait calls dsptch fails\r\n" );
	    while(1)
	    {
	    }
	  }
	}
	else				/* something happen	*/
	{
	  if ( p->p_state == PS_CRITICAL )
	    p->p_state = p->p_prvstate;
	}

	return( p->p_evflg );	/* return which EVB satisfied	*/
}


/*	Set up the waiting event block			*/
/*	If it is a read or write message, check 	*/
/*	the return code -1 for OK and no wait		*/
/*	0 for error 					*/
 
	EVSPEC 
iasync( afunc, aparm )
	WORD		afunc;
	REG LONG	aparm;
{
	REG EVB		*e;
	REG EVB		*p, *q;
	MOBLK		mob;
/*	LONG		old;*/
	WORD		ret,mask;
	WORD		oldsr;
	
	if ( !( e = get_evb( currpd ) ) ) {
	  Debug7("iasync: no evb\r\n");
	  return( (EVSPEC)FALSE );
	}
	  
	e->e_nextp = currpd->p_evlist;		/* link the EVB to the	*/
	currpd->p_evlist = e;			/* PD evlist		*/
	e->e_pd = (BYTE *)currpd;
						/* find a free bit in	*/
						/*   in the mask	*/

	for (e->e_mask=1; currpd->p_evbits & e->e_mask ; e->e_mask <<= 1);

	if ( !e->e_mask ) {
	  Debug7("iasync: e_mask is 0\r\n");
	  return( (EVSPEC) 0 );
	}

	mask = e->e_mask;
	currpd->p_evbits |= e->e_mask;

	switch( afunc )
	{
	  case AQRD: 
		ret = aqueue( FALSE, e, ( QPB *)aparm );
		goto i_3;

	  case AQWRT:	
		ret = aqueue( TRUE, e, ( QPB *)aparm );
i_3:		
		if ( !e->e_mask )	/* O.K */
		{
		  currpd->p_evbits ^= mask;
		  currpd->p_evlist = e->e_nextp;
		  return( -1 );
		}

		if ( !ret )
		{
		  currpd->p_evbits ^= mask;
		  currpd->p_evlist = e->e_nextp;
		  e->e_mask = 0;
		  Debug7("iasync: aqueue returns 0\r\n");
		  return( (EVSPEC)0 );
		}

		break;
		
	  case ADELAY: 		
		if ( !aparm )		/* # of ticks to wait	*/
		{
		  Debug7("iasync: aparm is 0\r\n");
		  zombie(e);
		  return( (EVSPEC)0 );
		}
		
		oldsr = spl7();

		if ( tel )
		  tel->e_parm = CMP_TICK;

		e->e_flag |= EVDELAY;
		e->e_head = &tel;
		p = tel;
		q = (EVB*)0;
		
		while( p )		/* compare to the next guy on	*/
		{			/* the list, and substract the	*/
	  	  if ( aparm <= p->e_parm )
		  {			/* time value as it goes on	*/	
		    p->e_parm -= aparm;		    
	    	    break;
		  }
	  	  aparm -= p->e_parm;
		  q = p;
		  p = p->e_link;
		}

		e->e_parm = aparm;
		
		if ( e->e_pred = q )	/* insert in the middle	*/
		  q->e_link = e;
		else			/* insert at the head	*/	
		  tel = e;

		if ( e->e_link = p )
		  p->e_pred = e;

		CMP_TICK = tel->e_parm;
		NUM_TICK = 0x0L;

		spl(oldsr);
		break;

			
	  case AKBIN: 			/* link to the CDA also	*/
					/* akbin(e,aparm);break;*/
					/* find vcb to input,	*/
					/*   point c at it	*/

	    	if ( currpd->p_cda.c_q.c_cnt )
	    	{
					/* another satisfied	*/
					/*   customer		*/
	      	  e->e_return = (UWORD)dq( currpd );
	      	  zombie(e);
	    	}
	    	else			/* time to zzzzz...	*/
		{
	      	  evinsert(e, &currpd->p_cda.c_iiowait);
		}

	    	break;
			
	  case AMOUSE:			/* link to the CDA also	*/
					/* amouse(e,aparm);	*/
		LBCOPY( ( BYTE *)&mob, ( BYTE *)aparm, sizeof(MOBLK));
					/* if already in (or	*/
					/*   out) signal	*/
					/*   immediately	*/
		
		if ( mob.m_out != inside( cu_xrat, cu_yrat, ( GRECT *)&mob.m_x ) )
		{
		  Debug7("iasync: AMOUSE: Enter zombie\r\n");
	  	  zombie(e);
		} 
		else
		{
		  Debug7("iasync: AMOUSE: handling rect\r\n");
	  	  if ( mob.m_out )
		    e->e_flag |= EVMOUT;
	  	  else
		    e->e_flag &= ~EVMOUT;
		  e->e_parm = HW(mob.m_x) + mob.m_y;
		  e->e_return = HW(mob.m_w) + mob.m_h;
		  evinsert(e, &currpd->p_cda.c_msleep );
		}
		break;

	  case ABUTTON:			/* check current button state	*/
	  	e->e_parm = aparm;
		e->e_type = afunc;

		if ( aparm & 0x1L )	/* Left button?			*/
		{			/* Yes then check for ownership	*/
		  if ( ch_mowner( cu_button, 1 ) != currpd )
		    goto mui;
		}

		if ( downorup( cu_button, e ) )/* && ( gl_mowner == currpd ) )*/
		{
		  e->e_button = cu_button;
		  e->e_mx = cu_xrat;
		  e->e_my = cu_yrat;
		  e->e_click = 1;				
	  	  e->e_return = HW( cu_button ) + e->e_click;		
	  	  zombie(e);
		}
		else
		{
mui:			/* increment counting semaphore to show	*/
			/* someone cares about  multiple clicks	*/
	  	  if ( ( LHIWD(aparm) & 0x000000ffL ) > 1 )
	    	    gl_bpend++;

	  	  evinsert( e, &currpd->p_cda.c_bsleep );
		}
		break;
	}
	Debug7("iasync: aqueue returns e_mask:");Ndebug7((LONG)e->e_mask);
	return( (EVSPEC) e->e_mask );
}



/*	Return the waiting event	*/

	EVB
*x_eret( p, mask )
	PD		*p;
	EVSPEC		mask;	
{
	REG EVB		*e, *q, *pz;
/*	UWORD		erret;*/
						/* first find the event	*/
						/*   on the process list*/
	for (e = (q = (EVB *) &p->p_evlist)->e_nextp; e; e = (q=e)->e_nextp)
	{
	  if ( e->e_mask == mask ) 
	    break;
	}

	if ( !e )
	  return( (EVB*)0 );
					/* if this event has occured	*/
					/* it is on the zombie list 	*/

	for (pz = zel; (pz != e) && pz; pz = pz->e_link);

	if ( !pz )				/* otherwise it is not	*/
	  return( (EVB*)0 );			/* completed		*/

	if ( !pz->e_pred )
	  *(pz->e_head)= pz->e_link;		/* found the event,	*/
	else					/* remove it from the	*/
	  pz->e_pred->e_link = pz->e_link;	/* zombie list 		*/

	if ( pz->e_link )
	  pz->e_link->e_pred = pz->e_pred;

	q->e_nextp = e->e_nextp;
	p->p_evbits &= ~mask;
	p->p_evwait &= ~mask;
	p->p_evflg &= ~mask;

	e->e_mask = 0;
	return( e );
}


/*	Return the waiting event	*/

	EVB
*eret( mask )
	EVSPEC		mask;	
{
	return(	x_eret( currpd, mask ) );
}


/*	Find the finished event and get its return code	*/

	UWORD
aret( mask )
	EVSPEC	mask;
{	
	EVB	*e;

	if ( e = eret( mask ) )
	  return( LLOWD( e->e_return ) );
	else
	  return( FALSE ); 
}  


/*	Cancel outstanding waiting events	*/

	EVSPEC
acancel( p, m )
	REG PD		*p;
	EVSPEC		m;
{
	REG EVSPEC	m1;	/* mask of items not cancelled		*/
	REG WORD	f;
	REG EVB		*e, *ne;

					/* cancel double click events */
	for ( e = p->p_cda.c_bsleep; e; e = e->e_link )
	{
	  if ( e->e_mask & m )
	  {		
	    if ( ( LHIWD(e->e_parm) & 0x00ffL ) > 1 )
	    {
	       if ( gl_bpend )
	         gl_bpend--;
	    }	  
	  }
	}

	m1 = 0;		/* satisfied event	*/

	for (e = (ne = (EVB *) &p->p_evlist)->e_nextp; e; e = (ne=e)->e_nextp)
	{
	  if ( e->e_mask & m )		/* if this is the one	*/
	  {				/* then check its status*/

	    f = e->e_flag;		/* aret() will take out	*/
					/* completed EVB	*/
	    if ( (f & NOCANCEL) || (f & COMPLETE) )
	      m1 |= e->e_mask;
	    else			/* Take it off		*/
	    {				/* if not completed or 	*/
	      ne->e_nextp = e->e_nextp;	/* still in progress	*/
	      p->p_evbits &= ~e->e_mask;
	      p->p_evwait &= ~e->e_mask;
	      takeoff(e);
	      e = ne;			/* contine traversal	*/
	    }
	  }
	}

	return(m1);
}

