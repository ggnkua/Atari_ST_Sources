/*****************************************************************************
**
** siochr.c - Character input/output routines for sio driver (AUX:)
**
** CREATED
** ktb			For Lisa GEM DOS BIOS.
**
** MODIFICATIONS
** 27 sep 85 scc	Converted from Lisa to VME/10.
**			Modified sputc() to use tx1st() instead of STARTX().
**
**  9 oct 85 scc	Added reference to tbeflag.
**			Deleted check of (tq.qcnt == 1) from sputc().
**
** NAMES
**	ktb	Karl T. Braun
**	scc	Steven C. Cavender
**
******************************************************************************
*/


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

EXTERN WORD	tbeflag;

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

	while( !rq.qcnt )
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
	if (!tbeflag )
		tx1st();
	while ( tq.qcnt > HIWATER ) 
		/*  busy wait  */ ;
}

/*****************************************************************************
**
**  srx1 -
**	get a char from the rx que.
**	if we are in ctls state and we go below low water, send ctlq
**
******************************************************************************
*/

BYTE	srx1()
{
	BYTE c, sdq() ;

	c = sdq( &rq );

	if ( sctls )
	{
		if ( rq.qcnt < LOWATER ) 
		{
			sputc( CTLQ );
			sctls = FALSE;
		}
	}

	return(c);
}
