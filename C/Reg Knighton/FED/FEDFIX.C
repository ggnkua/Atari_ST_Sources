/*
link statement: fedfix.68k=gemstart,fedfix,osbind,gemlib

(gemstart.o needed for argc/argv)
(gemlib needed for atoi() and argc/argv)

This is a .TTP program.

FED.PRG can only create fonts that are 6, 8, and 16 pixels high. However, it
CAN edit existing .FED files in any height from 6 thru 16 pixels. A kludgy
solution this dilemma is to use FIXFED.TTP. The approach is simple though
tedious:

	1) Start a FED.PRG session and choose 'from scratch' with the:

		8x8 option for a 7 pixel high font.
		8x16 option for a font anywhere from 9 to 15 pixels high.

	2) Develop the font in the TOP n pixels of the editing box where n
	   is the pixel height of the target.

	3) Save the font in .FED format.

	4) Run FEDFIX.TTP with these parameters:

		fontname.fed 1 2 3 4 5 6 

		where:

		fontname.fed is the filename of the font
		1 is the top line distance from the baseline
		2 is the ascent line distance from the baseline
		3 is the half line distance from the baseline
		4 is the descent line distance from the baseline
		5 is the bottom line distance from the baseline
		6 is the form height

FEDFIX.TTP updates the fields in the font header that must be adjusted when
changing a font's pixel height. The form height field is the most critical.
The top, ascent, half, descent, and bottom line values are used by GEM for
special effects (primarily skewing).

Once a .FED file has been processed with FEDFIX, subsequent editng sessions
with the non-standard height font will behave normally.
*/

#include <osbind.h>

struct	font_hdr
	{
	int	id;
	int	size;
	char	facename[32];
	int	ADE_lo;
	int	ADE_hi;
	int	top_dist;
	int	asc_dist;
	int	hlf_dist;
	int	des_dist;
	int	bot_dist;
	int	wchr_wdt;
	int	wcel_wdt;
	int	lft_ofst;
	int	rgt_ofst;
	int	thckning;
	int	undrline;
	int	lghtng_m;
	int	skewng_m;
	int	flags;
	char	*hz_ofst;
	int	*ch_ofst;
	char	*fnt_dta;
	int	frm_wdt;
	int	frm_hgt;
	char	*nxt_fnt;
	} f;

main(argc, argv)
int	argc;
char	*argv[];
{
int	fd;

if((fd = Fopen(argv[1], 2)) < 0)
	{
	Cconws("Can't open: ");
	Cconws(argv[1]);
	Cconws("\r\nPress any key\r\n");
	Cnecin();
	exit(1);
	}

Fread(fd, (long)sizeof(f), &f);

f.top_dist = atoi(argv[2]);
f.asc_dist = atoi(argv[3]);
f.hlf_dist = atoi(argv[4]);
f.des_dist = atoi(argv[5]);
f.bot_dist = atoi(argv[6]);
f.frm_hgt  = atoi(argv[7]);

Fseek(0L, fd, 0);
Fwrite(fd, (long)sizeof(f), &f);
}
