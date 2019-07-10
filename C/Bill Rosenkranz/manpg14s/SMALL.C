static char *sccsid = "@(#) small.c 1.2 91/1/22 rosenkra\0             ";

/*------------------------------*/
/*	fnt_small		*/
/*------------------------------*/
fnt_small ()
{

/*
 *	set font to small
 */

	extern int	f8x16sm[];	/* font data, small */

	extern int	load_msp_font ();

	load_msp_font (1, (int *) f8x16sm);
}

#include "small.h"

