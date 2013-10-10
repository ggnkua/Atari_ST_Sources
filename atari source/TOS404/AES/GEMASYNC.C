/*
*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/gemasync.c,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:20:44 $	$Locker: kbad $
* =======================================================================
*  $Log:	gemasync.c,v $
* Revision 2.2  89/04/26  18:20:44  mui
* TT
* 
* Revision 2.1  89/02/22  05:24:16  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.2  89/02/16  10:48:04  mui
* In acancel, clean up any outstanding d click event
*
* Revision 1.1  88/06/02  12:30:50  lozben
* Initial revision
* 
*************************************************************************
*/
/*	GEMASYNC.C	1/27/84 - 02/05/85	Lee Jay Lorenzen	*/
/*	to 68k		03/09/85 - 04/05/85	Derek Mui		*/
/*	remove bit_num	06/10/85		Mike Schmal		*/
/*	Change at aret for tbutton 10/29/86	Derek Mui		*/
/*	Change at mwait for acc wait	7/13/90	D.Mui			*/
/*	No check of mowner() at iasync	4/15/91	D.Mui			*/

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

EXTERN	PD	*mowner();
EXTERN VOID	dsptch();

EXTERN VOID	aqerr();			/* in QUEUE88.C		*/
EXTERN VOID	aqrd();
EXTERN VOID	aqwrt();

EXTERN WORD	button;
EXTERN WORD	gl_bpend;
EXTERN WORD	xrat;
EXTERN WORD	yrat;
EXTERN LONG	CMP_TICK;
EXTERN LONG	NUM_TICK;

GLOBAL WORD	tbutton;
WORD		wwait;

#if UNLINKED
	EVB
*get_evb()
{
	REG EVB		*e;

	if (e = eul)
	{
	  eul = eul->e_nextp;
	  bfill(sizeof(EVB), 0, e);
	}
	return(e);
}
#endif

	VOID
evinsert( e, root )
	REG EVB		*e;
	EVB		**root;
{
	REG EVB		*p, *q;
						/* insert event block	*/
						/*   on list 		*/
	q = (BYTE *) root - elinkoff ;
	p = *root;
	e->e_pred = q;
	q->e_link = e;
	e->e_link = p;
	if ( p )
	  p->e_pred = e;
}

	VOID
takeoff(p)
	REG EVB			*p;
{
	REG LONG		c;
						/* take event p off	*/
						/* e_link list, must 	*/
						/* be NODISP 		*/
	p->e_pred->e_link = p->e_link;
	if (p->e_link)
	{
	  p->e_link->e_pred = p->e_pred;
	  if (p->e_flag & EVDELAY)
	  {
	    c = (LONG) p->e_link->e_parm;
	    c += (LONG) p->e_parm;
	    p->e_link->e_parm = (LONG) c;
	  }
	}
	p->e_nextp = eul;
	eul = p;
}

	EVSPEC
mwait( mask )
	EVSPEC		mask;
{
	rlr->p_evwait = mask;
	if ( !(mask & rlr->p_evflg) )
	{
	  rlr->p_stat &= ~PS_RUN;
	  rlr->p_stat |= PS_MWAIT;
	  wwait = TRUE;
	  dsptch();
	}
	return(rlr->p_evflg);
}

	EVSPEC 
iasync(afunc, aparm)
	WORD		afunc;
	REG LONG	aparm;
{
	REG EVB		*e;
	REG EVB		*p, *q;
	MOBLK		mob;


				/* e = get_evb();	*/
	if (e = eul)
	{
	  eul = eul->e_nextp;
	  bfill(sizeof(EVB), 0, e);
	}

	e->e_nextp = rlr->p_evlist;		/* link the EVB to the	*/
	rlr->p_evlist = e;			/* PD evlist		*/
	e->e_pd = (BYTE *) rlr;
	e->e_flag = e->e_pred = 0;
						/* find a free bit in	*/
						/*   in the mask	*/
	for (e->e_mask=1; rlr->p_evbits & e->e_mask ; e->e_mask <<= 1);

	rlr->p_evbits |= e->e_mask;

	switch( afunc )
	{
	  case AQRD: 
		aqueue(FALSE,e,aparm);
		break;
	  case AQWRT:
		aqueue(TRUE,e,aparm);
		break;
	  case ADELAY: 			/* link to the CDA also	*/
					/* adelay(e,aparm);	*/

		if ( aparm == 0x0L)	/* # of ticks to wait	*/
		  aparm = 0x1L;

		cli();
		if ( CMP_TICK )
		{
					/* if already counting	*/
					/*   down then reset	*/
					/*   CMP_TICK to the	*/
					/*   lower number but	*/
					/*   let NUM_TICK grow	*/
					/*   from its accumulated*/
					/*   value		*/
		  if ( aparm <= CMP_TICK)
		    CMP_TICK = aparm; 
		}
		else
		{
						/* if we aren't currently*/
						/*   counting down for	*/
						/*   someone else then	*/
						/*   start ticking	*/
	  	  CMP_TICK = aparm;
						/* start NUM_TICK out	*/
						/*   at zero		*/
	  	  NUM_TICK = 0x0L;
		}


		e->e_flag |= EVDELAY;
		q = (BYTE *) &dlr - elinkoff;

		for (p = dlr; p; p = (q = p) -> e_link)
		{
	  	  if ( aparm <= (LONG) p->e_parm)
	    	    break;
	  	  aparm -= (LONG) p->e_parm;
		}

		e->e_pred = q;
		q->e_link = e;
		e->e_parm = aparm;
		e->e_link = p;

		if ( p )
		{
		  aparm = (LONG) p->e_parm - aparm;
		  p->e_pred = e;
		  p->e_parm = (LONG)aparm;
		}
		sti();

		break;
	  case AMUTEX:			/* link to the CDA also	*/
		amutex(e,aparm);
		break;			
	  case AKBIN: 			/* link to the CDA also	*/
					/* akbin(e,aparm);break;*/
					/* find vcb to input,	*/
					/*   point c at it	*/
	    	if ( cda->c_q.c_cnt )
	    	{
					/* another satisfied	*/
					/*   customer		*/
	      	  e->e_return = (UWORD) dq(&cda->c_q);
	      	  zombie(e);
	    	}
	    	else			/* time to zzzzz...	*/
	      	  evinsert(e, &cda->c_iiowait);

	    	break;
			
	  case AMOUSE:			/* link to the CDA also	*/
					/* amouse(e,aparm);	*/

		LBCOPY( &mob, aparm, sizeof(MOBLK));
					/* if already in (or	*/
					/*   out) signal	*/
					/*   immediately	*/
		if ( mob.m_out != inside(xrat, yrat, &mob.m_x) )
	  	  zombie(e);
		else
		{
	  	  if ( mob.m_out )
		    e->e_flag |= EVMOUT;
	  	  else
		    e->e_flag &= ~EVMOUT;
		  e->e_parm = HW(mob.m_x) + mob.m_y;
		  e->e_return = HW(mob.m_w) + mob.m_h;
		  evinsert(e, &(cda->c_msleep) );
		}
		break;

	  case ABUTTON:			/* link to the CDA also	*/
					/* abutton(e,aparm);	*/
/*		if ( mowner( button ) != rlr )
		  goto mui;
*/
		if ( downorup( button, aparm ) )
		{			/* changed */	
	  	  e->e_return = HW(button);		
	  	  zombie(e);		/* 'nuff said		*/
		}
		else
		{
					/* increment counting	*/
					/*   semaphore to show	*/
mui:					/*   someone cares about*/
					/*   multiple clicks	*/
	  	  if ( ( LHIWD(aparm) & 0x000000ffL ) > 1 )
	    	    gl_bpend++;

	  	  e->e_parm = aparm;
	  	  evinsert(e, &cda->c_bsleep);
		}
		break;
	}
	
	return(e->e_mask);
}


	UWORD
aret(mask)
	REG EVSPEC		mask;
{
	REG EVB		*p, *q, *pz;
	UWORD		erret;


						/* first find the event	*/
						/*   on the process list*/
	for (p = (q = (EVB *) &rlr->p_evlist)->e_nextp; p; p = (q=p)->e_nextp)
	{
	  if ( p->e_mask == mask ) 
	    break;
	}

	if ( !p )				
	  return( NOT_FOUND );
						/* if this event has	*/
						/*   occured, it is on	*/
						/*   the zombie list 	*/
	for (pz = zlr; (pz != p) && pz; pz = pz->e_link);

	if ( !pz )				/* otherwise it is not	*/
	  return( NOT_COMPLETE );		/* completed		*/
						/* found the event,	*/
						/* remove it from the	*/
						/* zombie list 		*/
	pz->e_pred->e_link = pz->e_link;
	if ( pz->e_link )
	  pz->e_link->e_pred = pz->e_pred;
	q->e_nextp = p->e_nextp;
	rlr->p_evbits &= ~mask;
	rlr->p_evwait &= ~mask;
	rlr->p_evflg &= ~mask;

	erret = LLOWD( p->e_return );
	p->e_nextp = eul;
	eul = p;
	tbutton = LHIWD( p->e_return );
	return(erret);
}


	EVSPEC
acancel(m)
	EVSPEC		m;
{
	REG EVSPEC	m1;		/* mask of items not	*/
					/*   cancelled		*/
	REG WORD	f;
	REG EVB		*p, *q;

	for ( p = rlr->p_cda->c_bsleep; p; p = p->p_link )
	{
	  if ( p->e_mask & m )
	  {		
	    if ( ( LHIWD(p->e_parm) & 0x00ffL ) > 1 )
	    {
	       if ( gl_bpend )
	         gl_bpend--;
	    }	  
	  }
	}


	m1 = 0;
	for (p = (q = (EVB *) &rlr->p_evlist)->e_nextp; p; p = (q=p)->e_nextp)
	{
	  if ( p->e_mask & m )		/* if this is the one	*/
	  {				/* then check its status*/

	    f = p->e_flag;		/* aret() will take out	*/
					/* completed EVB	*/
	    if ( (f & NOCANCEL) || (f & COMPLETE) )
	      m1 |= p->e_mask;
	    else			/* Take it off		*/
	    {				/* if not completed or 	*/
	      q->e_nextp = p->e_nextp;	/* still in progress	*/
	      takeoff(p);
	      rlr->p_evbits &= ~p->e_mask;
	      rlr->p_evwait &= ~p->e_mask;
	      p = q;			/* contine traversal	*/
	    }
	  }
	}
	return(m1);
}

