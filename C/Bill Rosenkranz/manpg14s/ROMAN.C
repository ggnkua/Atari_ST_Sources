static char *sccsid = "@(#) roman.c 1.2 91/1/22 rosenkra\0             ";

/*------------------------------*/
/*	fnt_roman		*/
/*------------------------------*/
fnt_roman ()
{

/*
 *	set font to roman
 */

	extern int	f8x16ro[];	/* font data, roman */

	extern int	load_msp_font ();

	load_msp_font (1, (int *) f8x16ro);
}

#include "roman.h"



