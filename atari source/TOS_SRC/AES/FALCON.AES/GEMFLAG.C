/*
*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/gemflag.c,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:22:31 $	$Locker: kbad $
* =======================================================================
*  $Log:	gemflag.c,v $
* Revision 2.2  89/04/26  18:22:31  mui
* TT
* 
* Revision 2.1  89/02/22  05:26:01  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  88/06/02  12:31:47  lozben
* Initial revision
* 
*************************************************************************
*/
/*	GEMFLAG.C	1/27/84 - 02/08/85	Lee Jay Lorenzen	*/
/*	Reg Opt		03/09/85		Derek Mui		*/
/*	1.1		03/23/85 - 6/19/85	Lowell Webster		*/
/*	Add window update free stuff	3/7/88	D.Mui			*/
/*	Fix at unsync	3/7/88			D.Mui			*/
	
/*
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.01
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
						/* in ASYNC88.C		*/
EXTERN VOID	evinsert();
						/* in AINTS88.C		*/
EXTERN VOID	zombie();

EXTERN LONG	NUM_TICK;			/* number of ticks	*/
						/*   since last sample	*/
						/*   while someone was	*/
						/*   waiting		*/
EXTERN LONG	CMP_TICK;			/* indicates to tick 	*/
						/*   handler how much	*/
						/*   time to wait before*/
						/*   sending the first	*/
						/*   tchange		*/


EXTERN	LONG	ad_windspb;			/* window sync block	*/


	VOID
tchange(c)
	REG LONG		c;		/* number of ticks that	*/
						/*   have gone by	*/
{
	REG EVB			*d;
	REG LONG		c1;
						/* pull pd's off the	*/
						/*   delay list that 	*/
						/*   have waited long	*/
						/*   enough		*/
	d = dlr;
	while (d)
	{
						/* take a bite out of	*/
						/*   the amount of time	*/
						/*   the pd is waiting	*/
	  c1 = c - d->e_parm;
	  d->e_parm -= c;
	  c = c1;
						/* finished waiting	*/
	  if ( d->e_parm <= 0 )
	  {
	    d->e_parm = 0;
	    evremove(d, 0);
	    d = dlr;
 	  }
	  else
	    break;
	}
						/* set compare tick 	*/
						/*   time to the amount	*/
						/*   the first guy is	*/
						/*   waiting		*/
	cli();
	if ( d ) 				/*    6/19/85		*/
	{
	  CMP_TICK = d->e_parm;
	  NUM_TICK = 0x0L;
	}
	sti();
}




	WORD
tak_flag(sy)
	REG SPB		*sy;
{
						
	sy->sy_tas++;				/* count up		*/

						/* if we didn't already	*/
						/* own it and it wasn't	*/
						/* then wait for it else*/
						/* claim ownership	*/
	if ( (sy->sy_owner != rlr) &&
	     (sy->sy_tas != 1) )
	{
	  sy->sy_tas--;
	  return(FALSE);
	}
	else					/* when sempahore = 0 	*/
	{					/* we can claim it	*/
	  sy->sy_owner = rlr;
	  return(TRUE);
	}
}


/*	Mutual exclusion works this way. If 	*/
/*	a process does a wind_update( TRUE )	*/
/*	call, then the ownership of the window	*/
/*	will be given to this process. However	*/
/*	if other process wants to claim owner-	*/
/*	ship and does a wind_update( TRUE )	*/
/*	call also, it will be blocked until	*/
/*	the wind_update( FALSE ) is called by 	*/
/*	the owner.				*/
/*	But if the second process doesn't do a 	*/
/*	wind_update call then it will have the 	*/
/*	right to access	the controlled area. 	*/


	VOID
amutex(e, sy)
	REG EVB		*e;
	SPB		*sy;
{
	if ( tak_flag(sy) )			/* it owns it so do it	*/
	  zombie(e);
	else
	  evinsert(e, &sy->sy_wait);		/* if it doesn't own 	*/
}						/* then wait		*/


	VOID
unsync(sy)
	REG SPB		*sy;
{
	REG EVB		*p;
						/* internal unsync must	*/
						/* be in dispatcher	*/
						/* context or NODISP	*/
						/* count down		*/
	if ( sy->sy_tas > 0 )
	{
	  
	  sy->sy_tas--;
						/* if it went to 0 then	*/
						/*   give up the sync	*/
						/*   to the next guy	*/
						/*   if there is one	*/
	  if (sy->sy_tas == 0)
	  {
	    if ( p = sy->sy_wait )		/* somebody's waiting	*/
	    {
	      sy->sy_wait = p->e_link;		/* so give it to him	*/
	      sy->sy_owner = (PD *) p->e_pd;
	      sy->sy_tas = 1;			/* restart semaphore	*/
	      zombie(p);				/* start it		*/
	      dsptch();				/* kick the system !	*/
	    }
	    else
	      sy->sy_owner = 0;			/* reset owner field	*/
	  }
	}
}


