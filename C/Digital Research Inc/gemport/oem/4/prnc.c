/*  prn.c - printer driver						*/

#include	"portab.h"
#include	"gemerror.h"
#include	"io.h"

/*
**  conditional compile switches
*/

#ifndef	PRNDEBUG
#define	PRNDEBUG	0
#endif

/*
**  externals
*/

EXTERN	VOID	prnout(), prninit();

/*
**  local constants
*/

#define	PRNDATA		(0xfc6000 + 0x09)
#define	PRNSTROBE	(0xfc6000 + 0x69)

/*
**  global data
*/

	/*
	**  prnavail -  set true by phys init routine if printer is there
	*/

	BOOLEAN	prnavail = FALSE ;

#if	PRNDEBUG
	/*
	**  prnchr - for debugging
	*/

	char	*prnchr = " " ;	
#endif


/*
**  pinit -
**	printer init routine
*/

VOID	pinit()
{
	prninit() ;	/*  call asm level routine in prn.s		*/
#if	PRNDEBUG
	kputs("pinit: printer is ") ;
	kpress( prnavail ? "available " : "not available " ) ;
#endif
}

/*
**  pinstat -
**	printer input status
*/

ECODE	pinstat()
{
	return( DEVNOTREADY ) ;
}

/*
**  poutstat -
**	printer output status
*/

ECODE	poutstat()
{
	return( DEVREADY ) ;
}

/*
**  pputc -
**	printer put char routine
*/

VOID	pputc( ch )
	WORD	ch ;
{
	if( prnavail )
	{
#if	PRNDEBUG
		*prnchr = ch ;			/*  store in buffer	*/
		kputs("pputc: outputing char: ") ;
		kputs( prnchr ) ;
#endif
		
		OUTP( (BYTE) ch , PRNDATA ) ;	/*  output the data	*/

		while(   (INP( PRNSTROBE ) & 0x02)  == 0x00   )
			/*  busy wait for ack */ ;

	}
}

/*
**  pgetc -
**	priner get char routine
*/

LONG	pgetc()
{
	return( -1L ) ;		      /*  don't try that with me, bozo	*/
}

