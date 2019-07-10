static char *sccsid = "@(#) uline.c 1.2 91/1/22 rosenkra\0             ";

/*------------------------------*/
/*	fnt_uline		*/
/*------------------------------*/
fnt_uline ()
{

/*
 *	set font to underline
 */

	extern int	f8x16ul[];	/* font data, underline */

	extern int	load_msp_font ();

	load_msp_font (1, (int *) f8x16ul);
}

#include "uline.h"
