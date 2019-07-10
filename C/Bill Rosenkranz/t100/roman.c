/*
 *	roman.c
 */

#ifndef lint
static char *rcsid_roman_c = "$Id: roman.c,v 1.0 1991/09/12 20:32:56 rosenkra Exp $";
#endif

/*
 * $Log: roman.c,v $
 * Revision 1.0  1991/09/12  20:32:56  rosenkra
 * Initial revision
 *
 */


#include "roman.h"

int	load_msp_font (int, short *);

/*------------------------------*/
/*	fnt_roman		*/
/*------------------------------*/
void fnt_roman ()
{

/*
 *	set font to roman
 */

	extern short	f8x16ro[];	/* font data, roman */

	load_msp_font (1, (short *) f8x16ro);

	return;
}



