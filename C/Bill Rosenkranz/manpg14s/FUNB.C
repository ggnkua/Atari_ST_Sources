static char *sccsid = "@(#) funb.c 1.3 91/1/25 rosenkra\0             ";

/*------------------------------*/
/*	fnt_bfun		*/
/*------------------------------*/
fnt_bfun ()
{

/*
 *	set font to bold funny
 */

#ifdef USE_FUNNY_FONT
	extern int	f8x16fb[];	/* font data, bold funny */

	extern int	load_msp_font ();

	load_msp_font (1, (int *) f8x16fb);
#else
	return;
#endif
}

#ifdef USE_FUNNY_FONT
#include "funb.h"
#endif


