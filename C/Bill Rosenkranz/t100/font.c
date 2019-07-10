#undef __NO_INLINE__


/*
 *	font.c
 */

#ifndef lint
static char *rcsid_font_c = "$Id: font.c,v 1.0 1991/09/12 20:32:56 rosenkra Exp $";
#endif

/*
 * $Log: font.c,v $
 * Revision 1.0  1991/09/12  20:32:56  rosenkra
 * Initial revision
 *
 */


/*
 *	this is a set of routines to allow for changing fonts. what we do
 *	here will work in all resolutions, though the font data included
 *	below is only for high rez. this uses line A. it only supports the
 *	monospaced font, which is fine for things like nroff.
 *
 *	load_msp_font (int opt, int *pfdar)
 *			load a font (used by the others)
 *
 *	front ends to load_msp_font:
 *
 *	fnt_bold ()	set bold font (provides data)
 *	fnt_uline ()	set underline font (provides data)
 *	fnt_reverse ()	set reverse (standout) font (provides data)
 *	fnt_roman ()	set roman font (provides data)
 *	fnt_normal ()	set normal font (reset to orig sys font)
 */

#include <stdio.h>			/* for NULL only */
#include <linea.h>
#include <osbind.h>



/*------------------------------*/
/*	load_msp_font		*/
/*------------------------------*/
int load_msp_font (opt, pfdar)
int	opt;				/* 0=init, 1=set, 2=reset to orig */
short  *pfdar;				/* new font data */
{

/*
 *	load a new monospaced font (8x16 only now)
 *
 *	opt=0		save original data (uses static variables)
 *			this is also done if it was not done before
 *	opt=1		set new font
 *	opt=2		reset back to (saved) original data
 *
 *	what we do is change 2 pointers: 1) the fnt_dta ptr in the DEF_FONT
 *	header, and 2) the ptr to the monospaced font data. we get the info
 *	from line A.
 */

	static short	       *origfhdat = 0L;	/* saved DEF_FONT->dat_table */
	static short	       *origmspdat = 0L;/* saved V_FNT_AD */
	static long		A_ptr = 0L;

	long		       *pltmp;
	long			ltmp;
	long			saveptr;
	__FONT		       *pfnthdr;



	/*
	 *   everything we need is based on line A. get ptr to its struct
	 */
	if (A_ptr == 0)
	{
		linea0 ();
		A_ptr = (long) __aline;
	}


	/*
	 *   if we did not already save the original ptrs (fnt_dta in
	 *   DEF_FONT header and V_FNT_AD, the monospaced font), do so...
	 */
	if ((origfhdat == (short *) NULL) && (origmspdat == (short *) NULL))
	{
		saveptr    = (long) Super (0L);

		ltmp       = *(long *) ((long) A_ptr - 460L);	/* DEF_FONT */
		pfnthdr    = (__FONT *) (ltmp);
		origfhdat  = (short *) (pfnthdr->dat_table);
		ltmp       = *(long *) ((long) A_ptr - 22L);	/* V_FNT_AD */
		origmspdat = (short *) (ltmp);

		Super (saveptr);
	}


	/*
	 *   if we are just initializing, return
	 */
	if (opt == 0)
		return;


	/*
	 *   what are we here for?
	 */
	switch (opt)
	{
	case 1:				/* set new font */
		saveptr            = (long) Super (0L);
		pltmp              = (long *) ((long) A_ptr - 460L);
		pfnthdr            = (__FONT *) (*pltmp);
		pfnthdr->dat_table = (char *) pfdar;
		pltmp              = (long *) ((long) A_ptr - 22L);
		*pltmp             = (long) pfdar;
		Super (saveptr);
		break;

	case 2:				/* reset orig */
		saveptr            = (long) Super (0L);
		pltmp              = (long *) ((long) A_ptr - 460L);
		pfnthdr            = (__FONT *) (*pltmp);
		pfnthdr->dat_table = (char *) origfhdat;
		pltmp              = (long *) ((long) A_ptr - 22L);
		*pltmp             = (long) origmspdat;
		Super (saveptr);
		break;
	}

	return;
}

