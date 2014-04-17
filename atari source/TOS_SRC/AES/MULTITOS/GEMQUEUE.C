/*	GEMQUEUE.C	1/27/84 - 01/07/85	Lee Jay Lorenzen	*/
/*	Reg Opt		03/09/85		Derek Mui		*/
/*	Modify doq for acc wait	7/13/90		D.Mui			*/
/*	Modify the doq and aqueue for multiple windows 10/28/90	D.Mui	*/
/*	02/16/93	cjg	Convert to Lattice C 5.51		*/
/*	02/23/93	cjg	Force the use of prototypes		*/

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
#include "aesmint.h"

#include "message.h"

						/* in PD88.C		*/
EXTERN	PD	*currpd;
EXTERN	WORD	spdid;
EXTERN	WORD	gl_multi;


	VOID
doq( donq, p, m )
	WORD		donq;
	REG PD		*p;
	QPB		*m;
{
	REG WORD	n;
	REG WORD	index, *om, *nm;


	n = m->qpb_cnt;

	if (donq)
	{
	  LBCOPY(p->p_qaddr + p->p_qindex, m->qpb_buf, n);
#if 1
	/* the code below was commented out for MultiTOS */
	/* why?? */
						/* if its a redraw msg	*/
						/*   try to find a 	*/
						/*   matching msg and	*/
						/*   union the redraw	*/
						/*   rects together	*/
	  nm = (WORD *) &p->p_queue[p->p_qindex];

	  if ( nm[0] == WM_REDRAW )
	  {
	    index = 0;
	    while ( (index < p->p_qindex) &&
		    (n) )
	    {
	      om = (WORD *) &p->p_queue[index];
	      if ( (om[0] == WM_REDRAW) &&
		   (nm[3] == om[3]) )
	      {
		rc_union(&nm[4], &om[4]);
	        n = 0;
	      }
	      else
	        index += (om[2] + 16);
	    }
	  }
#endif
	  p->p_qindex += n;
	}
	else
	{
	  LBCOPY(m->qpb_buf, p->p_qaddr, n);

	  p->p_qindex -= n;
	  if ( p->p_qindex )
	  {
	    LBCOPY( p->p_qaddr, p->p_qaddr + n, p->p_qindex );
	  }
	}
 }


/*	Queue up events to wait for message	*/

	WORD
aqueue( isqwrite, e, lm )
	WORD		isqwrite;
	REG EVB		*e;
	REG QPB		*lm;
{
	REG PD		*p;
	EVB		**ppe;
	EVB		*e1;
	WORD		qready,reverse;

	if ( !( p = idtopd( lm->qpb_pid ) ) ) {
	  Debug5("aqueue: p is null\r\n");
	  return( FALSE );
	} 
	else
	{
	  if ( p->p_state == PS_DEAD ) {
	    Debug5("aqueue: p is dead\r\n");
	    return( FALSE );
	  }
	}

	if ( isqwrite )
	  qready = ( lm->qpb_cnt < (QUEUE_SIZE - p->p_qindex) );
	else		  /* was <=, changed 4/12/93 hmk */
	  qready = ( p->p_qindex > 0 );

	ppe = (isqwrite ^ qready) ? &p->p_qnq : &p->p_qdq;

	reverse = FALSE;

	if ( qready )
	{
	  doq( isqwrite, p, lm );	/* do the operation	*/
	  e->e_mask = 0;	
/*	  zombie( e );	*/
					/* if somone is waiting for the */
	  				/* operation then wake him up 	*/
q_1:	  if ( e1 = *ppe )
	  {
	     while( e1 )		/* get the last one	*/
	     {
	       if ( e1->e_link )
	         e1 = e1->e_link;
	       else
		 break;	
	     }		     
	
	     doq( !isqwrite, p, (QPB *) e1->e_parm );
	     e1->e_flag |= NOCANCEL;
	     evremove( e1, 0 );
	     if ( reverse )
	     {
	       doq( isqwrite, p, lm );
	       e->e_mask = 0;
/*	       zombie( e );	*/
	     }
	  }
	}
	else					
	{			
	  if ( !isqwrite ) 	/* if read but no message then check	*/
	  {			/* to see if somebody is waiting to send*/
	    if ( *ppe )		/* Yes	*/
	    {
	      reverse = TRUE;
	      goto q_1;	
	    }
	  }
	  else
	  {			/* if queue is full and it is writing to */
				/* itself, then return error		 */	
	    if ( p == currpd ) {
	      Debug1(currpd->p_name); Debug1(": Event queue is full.\r\n");
	      return( FALSE );
	    }
	  }

	  if ( spdid != currpd->p_pid )
	  {
	    e->e_parm = ( LONG )lm;
	    evinsert( e, ppe );
	  }	
	  else {
	    Debug5("aqueue: deadlock case\r\n");
	    if (spdid){
		Debug1("spdid is: "); Debug1(currpd->p_name); Debug1("\r\n");
	    }else
		Debug1("spdid is 0\r\n");	

					/* to prevent dead lock		*/
	    return( FALSE );		/* reject the request		*/
	  }
	}

	return( TRUE );
}

