/*  sioint.c - default sio interrupt handlers				*/

#include	"portab.h"
#include	"gemerror.h"
#include	"io.h"
#include	"sio.h"
#include	"interrup.h"

EXTERN	PFI	siovec ;


/****************************************************************************
**
**  improvements
**
**  1	depend handling of ctls/ctlq on variable - ktb
**
****************************************************************************/

/*
**  rxint -
**	rx interrupt routine.  called from asm lang isr.
*/

ISR	rxint()
{
	BYTE ch;

	ch = DORX();		/*  get char from ctlr			*/
	(*siovec)( IF_RPKT , (long) (ch & 0xff) ) ;
}

/*
**  txint -
**	transmit a char.
**	watch out for empty que or ctls state.
**  
*/

ISR	txint()
{
	BYTE	sdq() ;

	if(  (!rctls) && (tq.qcnt)  )
		DOTX(  sdq(&tq)  ) ;
	else
		TXOFF() ;
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
					STARTX();	
					break;
				}
				/*  else fall thru  */

			default:		/*  else que up data	*/
				snq(ch,&rq);
	
				if(!sctls)	/*    if hiwater, send ctls */
				{
					if( rq.qcnt > HIWATER ) 
					{
						sctls = TRUE;
						while( !TXMT() )
							/* busy wait */ ;
						DOTX( CTLS );
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
