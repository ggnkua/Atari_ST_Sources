static char *sccsid = "@(#) fun.c 1.3 91/1/25 rosenkra\0             ";

/*------------------------------*/
/*	fnt_fun			*/
/*------------------------------*/
fnt_fun ()
{

/*
 *	set font to funny
 */

#ifdef USE_FUNNY_FONT
	extern int	f8x16f[];	/* font data, funny */

	extern int	load_msp_font ();

	load_msp_font (1, (int *) f8x16f);
#else
	return;
#endif
}

#ifdef USE_FUNNY_FONT
#include "fun.h"
#endif


