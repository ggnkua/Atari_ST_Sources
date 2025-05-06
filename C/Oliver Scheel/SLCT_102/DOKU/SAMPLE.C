/* ------------------------------------------------------------------------- */
/* ----- sample.c ----- Selectric Example ---------------------------------- */
/* ------------------------------------------------------------------------- */
/* ----------------------------------------- (c) 1992 by Oliver Scheel ----- */
/* ------------------------------------------------------------------------- */

#include <stdio.h>
#include <aes.h>

#include "fsel_inp.h"

#define	DEMO	1

/* ------------------------------------------------------------------------- */

char	p0[128] = "C:\\ACCS\\*.AC?",
	p1[128] = "C:\\TOOLS\\*.*",
	p2[128] = "",
	p3[128] = "";

char	e0[17] = "*.AC[CX]",
	e1[17] = "*.PRG",
	e2[17] = "*.TXT,*.DOC",
	e3[17] = "*.INF";

char	*my_paths[4] = { p0, p1, p2, p3 };
char	*my_ext[4] = { e0, e1, e2, e3 };

char	more_fnames[5 * 15];	/* entspricht 5 Namen a 15 Zeichen */

char	pfname[128] = "",
	pname[128] = "",
	fname[14] = "";

/* ------------------------------------------------------------------------- */

int main(void)
{
	int	is_slct_da, d;
#if (DEMO==1)
	DTA	mydta;
#endif

	appl_init();

	slct_extpath(4, &my_ext, 4, &my_paths);	/* eigene Pfade setzen */
#if (DEMO==1)
	is_slct_da = slct_check(0x0102);
	if(is_slct_da)
		slct->comm = CMD_FILES_OUT|CFG_FIRSTNEXT;
#else
	is_slct_da = slct_morenames(1, 5, more_fnames);	/* we want more */
#endif
	wind_update(BEG_MCTRL);		/* Wichtig!! */
	if(file_select(pfname, pname, fname, "*.*", "Selectric\277 Sample"))
	{
		if(is_slct_da)
		{
#if (DEMO==1)
			d = slct_first(&mydta, FA_ARCHIVE);
			while(!d)
			{
				printf("\n\r%s\t%02x", mydta.d_fname, mydta.d_attrib);
				d = slct_next(&mydta);
			}
			slct_release();
#else
			/* weggucken ... */
			printf("\r\nYou wanted more ... \r\n\n%s", more_fnames);
#endif
		}
	}
	wind_update(END_MCTRL);		/* Wichtig!! */

	appl_exit();
	return(0);
}
