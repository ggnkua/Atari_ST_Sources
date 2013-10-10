/*
*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/gemqueue.c,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:26:19 $	$Locker: kbad $
* =======================================================================
*  $Log:	gemqueue.c,v $
* Revision 2.2  89/04/26  18:26:19  mui
* TT
* 
* Revision 2.1  89/02/22  05:29:09  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  88/06/02  12:34:55  lozben
* Initial revision
* 
*************************************************************************
*/
/*	GEMQUEUE.C	1/27/84 - 01/07/85	Lee Jay Lorenzen	*/
/*	Reg Opt		03/09/85		Derek Mui		*/
/*	Modify doq for acc wait	7/13/90		D.Mui			*/


/*
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.0
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
						/* in PD88.C		*/
EXTERN PD	*fpdnm();

EXTERN THEGLO	D;


	VOID
doq(donq, p, m)
	WORD		donq;
	REG PD			*p;
	QPB		*m;
{
	REG WORD		n, index;
	REG WORD		*om, *nm;

	n = m->qpb_cnt;
	if (donq)
	{
	  LBCOPY(p->p_qaddr + p->p_qindex, m->qpb_buf, n);
						/* if its a redraw msg	*/
						/*   try to find a 	*/
						/*   matching msg and	*/
						/*   union the redraw	*/
						/*   rects together	*/
	  nm = (WORD *) &p->p_queue[p->p_qindex];

	  if ( nm[0] == AC_CLOSED )
	    p->p_stat |= PS_TRYSUSPEND;	

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
	  p->p_qindex += n;
	}
	else
	{
	  LBCOPY(m->qpb_buf, p->p_qaddr, n);
	  p->p_qindex -= n;
	  if ( p->p_qindex )
	    LBCOPY(p->p_qaddr, p->p_qaddr + n, p->p_qindex);
	}
}


	VOID
aqueue(isqwrite, e, lm)
	WORD		isqwrite;
	REG EVB			*e;
	LONG		lm;
{
	REG PD			*p;
	REG QPB			*m;
	EVB		**ppe;
	WORD		qready;

	m = (QPB *) lm;

	p = fpdnm(NULLPTR, m->qpb_pid);

	if (isqwrite)
	  qready = ( m->qpb_cnt <= (QUEUE_SIZE - p->p_qindex) );
	else
	  qready = ( p->p_qindex > 0 );

	ppe = (isqwrite ^ qready) ? &p->p_qnq : &p->p_qdq;
						/* room for message	*/
						/*  or messages in q	*/
	if (qready)
	{
	  doq(isqwrite, p, m);
	  zombie(e);
	  if ( e = *ppe )
	  {
	    e->e_flag |= NOCANCEL;
	    *ppe = e->e_link;

	    if ( e->e_link )
	      e->e_link->e_pred = e->e_pred;

	    doq(!isqwrite, p, (QPB *) e->e_parm);
	    zombie(e);
	  }
	}
	else					/* "block" the event	*/
	{
	  e->e_parm = lm;
	  evinsert(e, ppe);
	}
}

