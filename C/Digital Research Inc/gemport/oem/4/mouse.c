/*  mouse.c - clock handler (for things not in sony.s)			*/
/*  moulox , mousvec							*/

#include	"portab.h"
#include	"io.h"
#include	"interrup.h"

/*
**  forward declarations
*/

	ISR	moulox() ;

/*
**  externs
*/

EXTERN	PFI	ratint ;		/*  mouse intr vec in conio.c	*/

/*
**  moulox -
**	default handle tick logical interrupts
**	(actually, this routine isn't the default yet.  Current default
**	is defrat in biosa.s)
*/

ISR	moulox( flags , pkt )
	LONG	flags ;			/*  isr flags			*/
	BYTE	*pkt ;			/*  ptr to mouse packet		*/
{
	/*  do nothing  */
}

/*
**  mousvec -
**	mouse set vector routine
*/

PFI	mousvec( newrtn )
	PFI	newrtn ;
{
	PFI	rtn ;

	rtn = ratint ;
	ratint = newrtn ;
	return( rtn ) ;
}

