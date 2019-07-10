/*
 *	uline.c
 */

#ifndef lint
static char *rcsid_uline_c = "$Id: uline.c,v 1.0 1991/09/12 20:32:56 rosenkra Exp $";
#endif

/*
 * $Log: uline.c,v $
 * Revision 1.0  1991/09/12  20:32:56  rosenkra
 * Initial revision
 *
 */

#include "uline.h"

int	load_msp_font (int, short *);

/*------------------------------*/
/*	fnt_uline		*/
/*------------------------------*/
void fnt_uline ()
{

/*
 *	set font to underline
 */

	extern short	f8x16ul[];	/* font data, underline */

	load_msp_font (1, (short *) f8x16ul);

	return;
}
