/*  siochr.c - char input/output routines for sio driver		*/

/****************************************************************************
** 
**  improvements
**
**  1	should probably make the sputc/txint routines a little smarter so
**	we don't lockup if tx is suddenly disabled while above hi water mark.
**		- ktb
**
****************************************************************************/


#include	"portab.h"
#include	"io.h"
#include	"sio.h"


BYTE	srx1() ;


/*
**  sgetc -
**	wait (busy) for a character to become available and then get it.
*/

LONG	sgetc()
{
	ECODE	secode() ;

	if( rxevalid )
		return( secode() ) ;

	while( !RXRDY() )
		/*  wait  */ ;

	return( (LONG) srx1() ) ;
}

/*
**  sputc -
**	put a charater in the serial transmit que.
**	if we transit from empty que to non-empty, start tx.
**	if we are above the high water mark, wait until we get below it.
*/

VOID	sputc( ch )
	WORD	ch;
{
	snq(ch,&tq);
	if(tq.qcnt == 1)
		STARTX();
	while( tq.qcnt > HIWATER ) 
		/*  busy wait  */ ;
}

/*
**  srx1 -
**	get a char from the rx que.
**	if we are in ctls state and we go below low water, send ctlq
*/

BYTE	srx1()
{
	BYTE c, sdq() ;

	c = sdq( &rq );

	if( sctls )
	{
		if( rq.qcnt < LOWATER ) 
		{
			sputc( CTLQ );
			sctls = FALSE;
		}
	}

	return(c);
}

