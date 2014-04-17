/*	GEMAINTS.C	1/27/84 - 01/18/85	Lee Jay Lorenzen	*/
/*	Reg Opt		03/09/95		Derek Mui		*/
/*	Changed at signal for acc wait	7/13/90	D.Mui			*/
/*	Convert to Lattice C 5.51	2/17/93 C.Gee			*/
/*	Force the use of prototypes	2/25/93 C.Gee			*/

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


/*	Signal a sleeping process that it is ready to wake up	*/ 

	VOID
signal( e )
	EVB		*e;
{
	REG PD		*p, *p1, *q1;
	WORD		first;

	p = (PD *) e->e_pd;
	p->p_evflg |= e->e_mask;	/* mark this evb as satisfied	*/
		
	first = TRUE;

	p1 = nrl;			/* starting p	*/
	q1 = (PD*)0;
m_1:
	while( p1 )			/* Look for the process	*/
	{				/* on the nrl		*/
	  if ( p1 == p )
	    break;
	  else
	  {
	    q1 = p1;
	    p1 = p1->p_link;
	  }
	}

	if ( !p1 )
	{
	  if ( first )
	  {
	    first = FALSE;
	    p1 = drl;
	    q1 = (PD*)0;
	    goto m_1;
	  }
	}

	if ( ( p1 ) && ( p != currpd ) )
	{
	  if ( p->p_evflg & p->p_evwait )
	  {
	    if ( first )
	    {
	      if ( q1 )		/* Find the queue */
	        q1->p_link = p->p_link;
	      else		/* At the head */
	        nrl = p->p_link;
	   
	      if ( p->p_prvstate == PS_BLOCKED )
	      {
	        p->p_prvstate = PS_RUN;
	        link_head( &slr, p );
	      }
	      else
	      {
		p->p_state = PS_READY;
	        p->p_link = drl;
	        drl = p;
	      }
	    }
	  }
	}
}



/*	Put the satisfied EVB on the zombie list	*/
/* 	Must be called with dispatching off		*/

	VOID
zombie(e)
	REG EVB		*e;
{
	if ( e->e_link = zel )
	  zel->e_pred = e;

	e->e_pred = (EVB*)0;
	e->e_head = &zel;
	zel = e;
	e->e_flag = COMPLETE;
	signal(e);		/* wake up the process	*/
}

