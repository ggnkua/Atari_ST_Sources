/*
***************************   GEMDISP.C    ******************************
*
* $Revision: 2.3 $	$Source: /u2/MRS/osrevisions/aes/gemdisp.c,v $
* =======================================================================
* $Author: mui $ 	$Date: 89/04/26 18:21:59 $    $Locker: kbad $
* =======================================================================
*
* $Log:	gemdisp.c,v $
* Revision 2.3  89/04/26  18:21:59  mui
* TT
* 
* Revision 2.2  89/04/19  14:42:26  kbad
* 680x0 support: removed savestate() and switchto() (now in jdispa.s)
* 
* Revision 2.1  89/02/22  05:25:37  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.2  88/12/05  16:50:41  mui
* make the forkq return TRUE or FALSE
* 
* Revision 1.1  88/06/02  12:31:33  lozben
* Initial revision
* 
*************************************************************************
*/
/*	GEMDISP.C	1/27/84 - 02/03/85	Lee Jay Lorenzen	*/
/*	Reg Opt		03/09/85		Derek Mui		*/
/*	1.1		03/21/85		Lowell Webster		*/
/*	Change chkbd	07/22/85		Derek Mui		*/
/*	Change disp_act	07/12/85		Derek Mui		*/
/*	Reorganize the chkkbd	08/14/85	Derek Mui		*/
/*	Trying 1.2	10/16/85		Derek Mui		*/
/*	Fix the forker  3/10/86			Derek Mui		*/
/*	Fix the KEYSTOP	3/21/86			Derek Mui		*/
/*	Inlined code of schedule and mwait_act	4/9/88			*/
/*	Fix the accessory wait problem	7/13/90	D.Mui			*/
/*	Block process when in critical error	8/1/90	D.Mui		*/

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
#include <funcdef.h>


#define KEYSTOP 0x2b1c0000L		/* control backslash	*/

/****************************************************************
 * externals							*
 ****************************************************************/

PD	*dpd;				/* critical error process	*/

EXTERN WORD	crt_error;
						/* gemflag.c	*/
EXTERN WORD	tchange();
						/* geminput.c	*/
EXTERN WORD	kchange();
EXTERN PD	*gl_kowner;
EXTERN WORD	kstate;
						/* gemaplib.c	*/
EXTERN WORD	gl_recd;
EXTERN WORD	gl_rlen;
EXTERN LONG	gl_rbuf;
						/* apgsxif.s	*/
EXTERN WORD	intin[];
EXTERN WORD	intout[];
EXTERN WORD	contrl[];
						/* gemglobe.c	*/
EXTERN THEGLO	D;

PD		*slr;

EXTERN	WORD	wwait;

/****************************************************************/

	VOID
forkq(fcode,fdata)
	WORD		(*fcode)();
	LONG		fdata;
{
	REG FPD		*f;
						/* q a fork process,	*/
						/*   enter with ints OFF*/
	if (fpcnt < NFORKS)
	{
	  f = &D.g_fpdx[fpt++];
						/* wrap pointer around	*/
	  if (fpt == NFORKS)
	    fpt = 0;

	  f->f_code = fcode;
	  f->f_data = fdata;

	  fpcnt++;
	  return( TRUE );
	}
	return( FALSE );
}


	VOID
disp_act(p)
REG 	PD		*p;
{      
	REG PD		*pq, *q;
						/* process is ready,	*/
						/*   so put him on RLR	*/
	p->p_stat &= ~PS_MWAIT;
	p->p_stat |= PS_RUN;
						/* find the end		*/
	for ( pq = (q = (PD *) &rlr) -> p_link ; pq ; pq = (q = pq) -> p_link); 
						/* link him in		*/
	p->p_link = pq;
	q->p_link = p;
}


/*	Suspend the process	*/

	VOID
suspend_act(p)
REG 	PD		*p;
{      
	REG PD		*q;

	p->p_stat = PS_SUSPENDED;
	p->p_link = slr;
	slr = p;
}


	VOID
forker()
{
	REG FPD			*f;
	REG PD			*oldrl;
	REG LONG		amt;

	infork = 1;
	oldrl = rlr;
	rlr = (PD *) -1;
	while(fpcnt)
	{
	  fpcnt--;
	  f = &D.g_fpdx[fph++];
	  if (fph == NFORKS) 
	    fph = 0;
						/* see if recording	*/
	  if (gl_recd)
	  {
						/* check for stop key	*/
	    if ( (f->f_code == &kchange) &&
	         ((f->f_data & 0xffff0000L) == KEYSTOP) )
	      gl_recd = FALSE;
						/* if still recording	*/
						/*   then handle event	*/
	    if (gl_recd)
	    {
						/* if its a time event &*/
						/*   previously recorded*/
						/*   was a time event	*/
						/*   then coalesce them	*/ 
						/*   else record the	*/
						/*   event		*/
	      if ( (f->f_code == &tchange) &&
	           (LLGET(gl_rbuf - sizeof(FPD)) == &tchange) )
	      {
	        amt = f->f_data + LLGET(gl_rbuf-sizeof(LONG));
	        LLSET(gl_rbuf - sizeof(LONG), amt);	      
	      }
	      else
	      {
	        LBCOPY(gl_rbuf, ADDR(f), sizeof(FPD));
	        gl_rbuf += sizeof(FPD);
	        gl_rlen--;
		gl_recd = gl_rlen;
	      }
	    }
	  }
	  (*f->f_code)(f->f_data);
	}
	rlr = oldrl;
	infork = 0;
}


	VOID
chkkbd()
{
	REG WORD		achar, kstat;
	REG WORD		*pintin;

   	gsx_ncode( KEY_SHST, 0x0L );
	kstat = intout[0];

	achar = 0;
	if ( gl_kowner->p_cda->c_q.c_cnt < KBD_SIZE )
	{
	  pintin = &intin[0];

	  pintin[0] = 4;
	  pintin[1] = 2;
	  gsx_ncode( 33, 0x00000002L );
	
	  pintin[0] = -1;
	  pintin[1] = FALSE;        	/* no echo */
	  gsx_ncode( 31, FALSE, 2 );
	  if ( contrl[4] )
	    achar = intout[0];
	}

	if ( ( achar ) || ( kstat != kstate ) )
	  forkq( kchange, achar, kstat );
}


/****************************************************************
 *								*
 *   dispatcher maintains all flags/regs so it looks like	*
 *   an RTE to the caller.					*
 *   dsptch() = rte						*
 *   rlr -> p_stat determines the action to perform on the	*
 *	    process that was in context				*
 *   rlr -> p_uda -> dparam is used by the action routines	*
 *								*
 ****************************************************************/

/****************************************************************
 * Machine state is saved before this routine is entered!	*
 ****************************************************************/

	VOID
disp()
{
	REG PD		*p;
	REG PD		*p1;	

						/* take the process p	*/
						/*   off the ready list	*/
						/*   root		*/
	if ( crt_error )
	{
	  dpd = rlr;				/* save the current process */
 	}

	rlr = ( p = rlr ) -> p_link;
						/* based on the state	*/
						/*   of the process p	*/

						/*   do something	*/
	if ( p->p_stat & PS_RUN )
	  disp_act( p );
	else
	  if ( p->p_stat & PS_MWAIT )		/* mwait_act( p );	*/
	  {
	     if ( p->p_evwait & p->p_evflg )
	       disp_act( p );
	     else
	     {
	        if ( ( p->p_stat & PS_TOSUSPEND ) && ( !wwait ) )
	          suspend_act( p );		/* suspend the process	*/
		else
		{ 
	          p->p_link = nrl;		/* good night, Mrs.	*/
	          nrl = p;			/* Calabash, wherever	*/
		}
	     }
	   }

	wwait = FALSE;
					/* run through and 	*/
					/*   execute all the	*/
d_1:					/*   fork processes	*/
	do 
	{
	  forker();
					/*  schedule();		*/
					/* run through lists	*/
					/*   until someone is	*/
					/*   on the rlr or the	*/
					/*   fork list		*/
	  do
	  {
					/* poll the keyboard	*/
	     chkkbd();
					/* now move drl		*/
					/*   processes to rlr	*/

	     while ( drl )
	     { 
	       drl = (p = drl) -> p_link;
	       disp_act(p);
	     }
					/* check if there is	*/
					/*   something to run	*/
	  } while ( !rlr && !fpcnt );

	} while (fpcnt);

	if ( crt_error )
	{
	  if ( rlr != dpd )	/* is the 1st guy the same	*/
	  {			/* one in critical error?	*/
	    p = rlr->p_link;	/* Head	*/
	    p1 = rlr;		/* next	*/
	    while ( p )		/* move this process to the head*/
	    {
	      if ( p == dpd )
	      {
		p1->p_link = p->p_link;
		dpd->p_link = rlr;
		rlr = dpd;
		goto d_2;
	      }
	      else
	      {
		p1 = p;
		p = p->p_link;
	      }
	    }
	    goto d_1;		/* critical process isn't here		*/
	  }			/* the critical process is at the head	*/
d_2:
	  crt_error = FALSE;
	} 
					/* This process is to be suspended*/
					/* when it return to here	*/
	if ( rlr->p_stat & PS_TRYSUSPEND )
	{
	  rlr->p_stat &= ~PS_TRYSUSPEND;
	  rlr->p_stat |= PS_TOSUSPEND;
	}
 
	cda = rlr->p_cda;		/* switch to the context of the	*/
					/* appropriate process		*/
}

/****************************************************************
 * Actual context switch happens after we fall out of disp().	*
 ****************************************************************/
