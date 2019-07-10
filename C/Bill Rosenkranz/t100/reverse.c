/*
 *	reverse.c
 */

#ifndef lint
static char *rcsid_reverse_c = "$Id: reverse.c,v 1.0 1991/09/12 20:32:56 rosenkra Exp $";
#endif

/*
 * $Log: reverse.c,v $
 * Revision 1.0  1991/09/12  20:32:56  rosenkra
 * Initial revision
 *
 */

#include "reverse.h"

int	load_msp_font (int, short *);

/*------------------------------*/
/*	fnt_reverse		*/
/*------------------------------*/
void fnt_reverse ()
{

/*
 *	set font to reverse
 */

	extern short	f8x16rv[];	/* font data, reverse */

	load_msp_font (1, (short *) f8x16rv);

	return;
}

