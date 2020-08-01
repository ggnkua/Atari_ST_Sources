/* pml compatible lib for the atari sfp004
 *
 * Michael Ritzert, Oktober 1990
 * ritzert@dfg.dbp.de
 */

/************************************************************************
 *									*
 *				N O T I C E				*
 *									*
 *			Copyright Abandoned, 1987, Fred Fish		*
 *									*
 *	This previously copyrighted work has been placed into the	*
 *	public domain by the author (Fred Fish) and may be freely used	*
 *	for any purpose, private or commercial.  I would appreciate	*
 *	it, as a courtesy, if this notice is left in all copies and	*
 *	derivative works.  Thank you, and enjoy...			*
 *									*
 *	The author makes no warranty of any kind with respect to this	*
 *	product and explicitly disclaims any implied warranties of	*
 *	merchantability or fitness for any particular purpose.		*
 *									*
 ************************************************************************
 */


/*
 *  FUNCTION
 *
 *	matherr    default math error handler function
 *
 *  KEY WORDS
 *
 *	error handler
 *	machine independent routines
 *	math libraries
 *
 *  DESCRIPTION
 *
 *	Default math error handler for the math library.  This routine
 *	may be replaced by one of the user's own handlers.  The default
 *	is to do nothing and returns zero.  If the user wishes to supply
 *	the return value for the function, and to suppress default
 *	error handling by the function, his matherr routine must return
 *	non-zero.
 *
 *  USAGE
 *
 *	int matherr (xcpt)
 *	struct exception *xcpt;
 *
 *  PROGRAMMER
 *
 *	Fred Fish
 *
 */

#include <stdio.h>
#include <pmluser.h>
#include "pml.h"

static char funcname[] = "matherr";

int matherr (xcpt)
struct exception *xcpt;
{
    DBUG_ENTER (funcname);
    DBUG_RETURN (0);
}
