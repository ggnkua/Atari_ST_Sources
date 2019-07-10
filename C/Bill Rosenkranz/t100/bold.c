/*
 *	bold.c
 */

#ifndef lint
static char *rcsid_bold_c = "$Id: bold.c,v 1.0 1991/09/12 20:32:56 rosenkra Exp $";
#endif

/*
 * $Log: bold.c,v $
 * Revision 1.0  1991/09/12  20:32:56  rosenkra
 * Initial revision
 *
 */

#include "bold.h"

int	load_msp_font (int, short *);

/*------------------------------*/
/*	fnt_bold		*/
/*------------------------------*/
void fnt_bold ()
{

/*
 *	set font to bold
 */

	extern short	f8x16bo[];	/* font data, bold */

	load_msp_font (1, (short *) f8x16bo);

	return;
}



