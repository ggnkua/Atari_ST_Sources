static char *sccsid = "@(#) bold.c 1.2 91/1/22 rosenkra\0             ";

/*------------------------------*/
/*	fnt_bold		*/
/*------------------------------*/
fnt_bold ()
{

/*
 *	set font to bold
 */

	extern int	f8x16bo[];	/* font data, bold */

	extern int	load_msp_font ();

	load_msp_font (1, (int *) f8x16bo);
}

#include "bold.h"



