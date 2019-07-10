static char *sccsid = "@(#) special.c 1.2 91/1/22 rosenkra\0             ";

/*------------------------------*/
/*	fnt_special		*/
/*------------------------------*/
fnt_special ()
{

/*
 *	set font to special
 */

	extern int	f8x16sp[];	/* font data, special chars */

	extern int	load_msp_font ();

	load_msp_font (1, (int *) f8x16sp);
}

#include "special.h"
