static char *sccsid = "@(#) normal.c 1.1 91/1/15 rosenkra\0         ";

/*------------------------------*/
/*	fnt_normal		*/
/*------------------------------*/
fnt_normal ()
{

/*
 *	set font to normal
 */

	extern int	load_msp_font ();

	load_msp_font (2, (int *) 0);
}



