static char *sccsid = "@(#) font.c 1.2 91/1/22 rosenkra\0         ";

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
 *	fnt_special ()	set special font (provides data)
 *	fnt_standout ()	set standout font (provides data)
 *	fnt_small ()	set small font (provides data)
 *	fnt_roman ()	set roman font (provides data)
 *	fnt_normal ()	set normal font (reset to orig)
 */

#include <stdio.h>			/* for NULL only */
#include <gem\fonthdr.h>
#include <osbind.h>


/*------------------------------*/
/*	load_msp_font		*/
/*------------------------------*/
load_msp_font (opt, pfdar)
int	opt;				/* 0=init, 1=set, 2=reset to orig */
int    *pfdar;				/* new font data */
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

	static int	       *origfhdat = 0L;	/* saved DEF_FONT->fnt_dta */
	static int	       *origmspdat = 0L;/* saved V_FNT_AD */

	long		       *pltmp;
	long			ltmp;
	long			A_ptr;
	long			saveptr;
	struct font_hdr	       *pfnthdr;



	/*
	 *   everything we need is based on line A. get ptr to its struct
	 */
	A_ptr = linea0 ();


	/*
	 *   if we did not already save the original ptrs (fnt_dta in
	 *   DEF_FONT header and V_FNT_AD, the monospaced font), do so...
	 */
	if ((origfhdat == (int *) NULL) && (origmspdat == (int *) NULL))
	{
		saveptr    = Super (0L);

		ltmp       = *(long *) ((long) A_ptr - 460L);	/* DEF_FONT */
		pfnthdr    = (struct font_hdr *) (ltmp);
		origfhdat  = (int *) (pfnthdr->fnt_dta);
		ltmp       = *(long *) ((long) A_ptr - 22L);	/* V_FNT_AD */
		origmspdat = (int *) (ltmp);

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
		saveptr          = Super (0L);
		pltmp            = (long *) ((long) A_ptr - 460L);
		pfnthdr          = (struct font_hdr *) (*pltmp);
		pfnthdr->fnt_dta = (int *) pfdar;
		pltmp            = (long *) ((long) A_ptr - 22L);
		*pltmp           = (long) pfdar;
		Super (saveptr);
		break;

	case 2:				/* reset orig */
		saveptr          = Super (0L);
		pltmp            = (long *) ((long) A_ptr - 460L);
		pfnthdr          = (struct font_hdr *) (*pltmp);
		pfnthdr->fnt_dta = (int *) origfhdat;
		pltmp            = (long *) ((long) A_ptr - 22L);
		*pltmp           = (long) origmspdat;
		Super (saveptr);
		break;
	}

	return;
}

