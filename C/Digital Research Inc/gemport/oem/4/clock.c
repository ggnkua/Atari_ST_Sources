/*  clock.c - clock handler (for things not in sony.s)			*/
/*  clklox , clksvec							*/

#include	"portab.h"
#include	"io.h"
#include	"interrup.h"

/*
**  forward declarations
*/

	ISR	clklox() ;

/*
**  globals
*/

	/*
	**  msecs -  number of milliseconds since boot, unless the user
	**	has stolen the vector
	*/

	LONG	msecs = 0 ;

	/*
	**  clkvec -  logical interrupt routine vector
	*/

	PFI	clkvec = ADDRESS_OF( clklox ) ;

/*
**  clklox -
**	handle tick logical interrupts
*/

ISR	clklox( flags , time )
	LONG	flags ;			/*  isr flags			*/
	LONG	time ;			/*  nmbr millisecs passed	*/
{
	if( flags & IF_RPKT )
	{
		msecs += time ;
	}
}

/*
**  clksvec -
**	tick set vector routine
*/

PFI	clksvec( newrtn )
	PFI	newrtn ;
{
	PFI	rtn ;

	rtn = clkvec ;
	clkvec = newrtn ;
	return( rtn ) ;
}

