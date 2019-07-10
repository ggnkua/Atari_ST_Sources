static char *sccsid = "@(#) standout.c 1.2 91/1/22 rosenkra\0             ";

/*------------------------------*/
/*	fnt_standout		*/
/*------------------------------*/
fnt_standout ()
{

/*
 *	set font to standout
 */

	extern int	f8x16so[];	/* font data, standout */

	extern int	load_msp_font ();

	load_msp_font (1, (int *) f8x16so);
}

#include "standout.h"
