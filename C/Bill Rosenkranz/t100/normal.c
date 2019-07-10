/*
 *	normal.c
 */

#ifndef lint
static char *rcsid_normal_c = "$Id: normal.c,v 1.0 1991/09/12 20:32:56 rosenkra Exp $";
#endif

/*
 * $Log: normal.c,v $
 * Revision 1.0  1991/09/12  20:32:56  rosenkra
 * Initial revision
 *
 */


/*------------------------------*/
/*	fnt_normal		*/
/*------------------------------*/
void fnt_normal ()
{

/*
 *	set font to normal
 */

	extern int	load_msp_font ();

	load_msp_font (2, (short *) 0);
}



