/*****************************************************************************
**
** sioint.c -	Serial port (AUX:) interrupt handlers
**		rxint -, erint -, txint -, siolox -
**
** CREATED
** ktb			Originally for Lisa GEM DOS BIOS.
**
** MODIFICATIONS
** 26 sep 85 scc	Converted for use with VME/10.
**			Changed txint() to LONG.  See SIOPHYSA.S.
**			Added erint().
**
** 27 sep 85 scc	Modified siolox() to use do_ctls and new VME/10
**			oriented routines to syncronize sending of CTLS.
**
** 30 sep 85 scc	Modified rxint() to refer to charvec[] for handler.
**			Removed reference to siovec.
**
**  9 oct 85 scc	Added reference to tbeflag.
**
**  14 Oct 85	KTB	accomodate split of fs.h into fs.h and bios.h
**
**
** NAMES
**	ktb	Karl T. Braun(kral)
**	scc	Steven C. Cavender
******************************************************************************
*/

#include "portab.h"
#include "bios.h"
#include "gemerror.h"
#include "io.h"
#include "interrup.h"
#include "sio.h"
#include "7201.h"	/* yes, we actually check some chip related info */

EXTERN WORD	tbeflag;

BOOLEAN		do_ctls;	/* flag for syncronizing transmission of
				** CTLS with other characters in transmit
				** buffer when we need to tell the guy at the
				** other end to stop transmitting.
				*/


/****************************************************************************
**
**  improvements
**
**  1	depend handling of ctls/ctlq on variable - ktb
**
****************************************************************************/

/*****************************************************************************
**
**  rxint -
**	rx interrupt routine.  called from asm lang isr.
**
******************************************************************************
*/

ISR	rxint(ch)
	BYTE ch;
{
	(*charvec[BFHAUX])( IF_RPKT , (long) (ch & 0xff) ) ;
}

/*****************************************************************************
**
** erint -
**	Receive error interrupt routine.  Called from assembly language ISR.
**	This code has NEC 7201 dependencies in it.
**
******************************************************************************
*/

ISR	erint(status)
	REG BYTE status;
{
	REG LONG flag;

	flag = IF_ERROR;

	if (status & RXOVRUN)		/* 7201 specific */
		flag |= IF_OVERRUN;

	if (status & PARERR)		/* 7201 specific */
		flag |= IF_PARITY;

	(*charvec[BFHAUX])( flag, 0L );
}

/*****************************************************************************
**
**  txint -
**	tx interrupt routine.  Called from assembly language ISR which wants
**	to know if there are any more characters in the transmit buffer.
**
******************************************************************************  
*/

LONG	txint()
{
	BYTE	sdq() ;

	if (sctls && do_ctls)
	{
		do_ctls = FALSE;
		return( (LONG) CTLS );
	}

	if(  (!rctls) && tq.qcnt  )
		return( (LONG) sdq(&tq) );	/* return the next character */

	return( -1L );				/* or indicate no character */
}

/*
**  siolox -
**	logical interrupt handler.  This is is the default routine called
**	by the interrupt service routine.  Note that tx interrupts
**	are not handled by the logical int handler.
*/

ISR	siolox( flags , parm )
	LONG	flags ;
	union 
	{
		BYTE	*pblk ;
		LONG	info ;
	} parm ;
{
	char	ch ;

	if( flags & IF_RPKT )
	{
		/*  received packet 					*/
		
		ch = (char) parm.info ;

		switch(ch) 
		{
			case CTLS:		/*  handle ctl s	*/
				rctls = TRUE;
				break;
	
			case CTLQ:		/*  handle ctl q	*/
				if( rctls ) 
				{
					rctls = FALSE;
					if (!tbeflag)
						tx1st();
					break;
				}
				/*  else fall thru  */

			default:		/*  else que up data	*/
				snq(ch,&rq);
	
				if (!sctls)	/*    if hiwater, send ctls */
				{
					if( rq.qcnt > HIWATER ) 
					{
						do_ctls = sctls = TRUE;
						if (!tq.qcnt)
							tx1st();
					}
				}
	
		} /* end switch */
	}

	/*  check for errors  */

	if( flags & IF_ERROR )
		seterr( EREADF ) ;  		/*  [2]			*/

#if	MDMCTL					/*  [1]  		*/
	if( flags & IF_DCD )
	{
		/*  carrier is on  */
	}
	else
	{
		/*  carrier is off  */
	}

	if( flags & IF_CTS )
	{
		/*  cts is on  */
	}
	else
	{
		/*  cts is off  */
	}
#endif
}


/*
** [1]	If modem control is to be handled, then it should be done according
**	to the skeleton provided.  However, we do not currently support modem
**	control line status changes.
**
** [2]	All read errors are currently mapped into a generic read fault error.
**
**				- ktb
*/
