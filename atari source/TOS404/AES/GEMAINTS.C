/*
*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/gemaints.c,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:20:23 $	$Locker: kbad $
* =======================================================================
*  $Log:	gemaints.c,v $
* Revision 2.2  89/04/26  18:20:23  mui
* TT
* 
* Revision 2.1  89/02/22  05:24:03  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  88/06/02  12:30:40  lozben
* Initial revision
*
*************************************************************************
*/
/*	GEMAINTS.C	1/27/84 - 01/18/85	Lee Jay Lorenzen	*/
/*	Reg Opt		03/09/95		Derek Mui		*/
/*	Changed at signal for acc wait	7/13/90	D.Mui			*/


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

	VOID
signal(e)
	EVB		*e;
{
	REG PD		*p, *p1, *q1;

	p = (PD *) e->e_pd;
	p->p_evflg |= e->e_mask;
						/* off the not-ready	*/
						/*   list 		*/
	for (p1 = (q1 = (PD *) &nrl)->p_link; (p1 != p) && (p1);
	  p1 = (q1=p1)->p_link);
	if ( p != rlr )
	{
	  if ( p->p_evflg & p->p_evwait)
	  {
	    if ( p1 )
	    {
	      p1->p_stat |= PS_RUN;
						/* onto the drl		*/
	      q1->p_link = p1->p_link;
	      p1->p_link = drl;
	      drl = p1;
	    }
	  }
	}
}


	VOID
zombie(e)
	REG EVB		*e;
{
						/* must be called with	*/
						/*   dispatching off 	*/
	e->e_link = zlr;
	if ( zlr )
	  zlr->e_pred = e;
	e->e_pred = (BYTE *) &zlr - elinkoff;
	zlr = e;
	e->e_flag = COMPLETE;
	signal(e);
}


