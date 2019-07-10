#undef SINGLE_FILE			/* do only 1 file... */
#undef USE_SETJMP			/* use longjump to get back to main */
#undef SCAL_DEVINT			/* for DeviceInten a fcn of bits */
					/* else constant */

/*
 *	gif - floyd-steinberg dither (mono) a gif image (.gif)
 *
 *	gif decoder lifted from PBMplus package. fdither is my own doing.
 *	longjmp does not work (yet?).
 *
 *	history:
 *
 *	90/12/16 1.0 rosenkra	- initial release (posted to c.s.atari.st)
 *
 *	91/1/7 1.1 rosenkra	- change -i to -r
 *				- change -q to -i
 *				- started to add -q (quantize), not complete
 *				- fix bug with zero'ed accumulation arrays
 *				which was being done with every call to
 *				rasterize
 *				- add histogram for each rgb value (eliminate
 *				the "intensity order" histogram, too)
 *				- make UseNTSC global
 *				- fix scan_CM (bug in gemlib read)
 *				- make default -s of 40
 *				- histogram now impacted by -N (NTSC)
 *				- add -f option
 */

static char *sccsid = "@(#) mgif 1.1 91/1/7 rosenkra\0\0                 ";
char        *myname = "mgif\0\0\0\0\0\0";
char        *version = "mgif 1.1 91/1/7 rosenkra\0\0\0                   ";


#include <stdio.h>
#include <osbind.h>
#ifdef USE_SETJMP
# include <setjmp.h>
#endif


/* these were 400000 and 250000 */
#define MAXIMG		800000L		/* image (raster) buffer, bytes */
#define MAXRAW		400000L		/* raw coded data buffer, bytes */
#define HASHSIZ		4096		/* size of hash tables */
#define OUTSIZ		1025		/* size of output table */
#define HISTSIZ		256		/* size of histogram table */
#define MAPSIZ		256		/* size of color map table */
#define MAXPIXLINE	650		/* max num pixels in display row, */
					/* need at least 642 for array dims */
#define MAX_X		640		/* number of pixels on screen, horiz*/
#define MAX_Y		400		/* number of pixels on screen, vert*/
#define LEFT		0		/* dither directions */
#define RIGHT		1

#define REDPLANE	1
#define GREENPLANE	2
#define BLUEPLANE	4
#define ALLPLANE	(REDPLANE | GREENPLANE | BLUEPLANE)

#define ENDFILE(f)	Eof != 0	/* to track EOF on input file */


typedef unsigned char uchar_t;
typedef unsigned int uint_t;
typedef unsigned long ulong_t;

typedef struct			/* screen descriptor */
{
	int	s_dx,		/* image size */
		s_dy;
	int	s_colors, 	/* # colors */
		s_bits,		/* bits/pixel */
		s_cr;		/* color resolution */
	char	s_gcm,		/* global color map flag */
		s_bgnd;		/* background color */

}		screen_t;

typedef struct			/* image descriptor */
{
	int	i_x,		/* position rel to upper left */
		i_y,
		i_dx,		/* size */
		i_dy,
		i_colors,	/* num colors in image */
		i_bits;		/* bits/pixel */
	char	i_gcm,		/* use global color map */
		i_intlace;	/* 0=sequential or !0=interlaced */

}		image_t;




/*
 *	globals:
 */

#ifdef USE_SETJMP
/*jmp_buf		JmpEnv;*/
ulong_t		JmpEnv[15];
#endif

uchar_t		Raster[MAXIMG];	/* final raster image, ColMap indx */

uchar_t		CodedGIF[MAXRAW];/* raw LZW coded raster after unblock*/

long		DeviceInten;	/* device intensity */
ulong_t		BitOffset = 0;	/* Bit Offset of next code */
int		XC = 0,		/* Output X and Y coords of current pixel */
		YC = 0;
int		Height,		/* image size */
		Width;
int		Pass = 0;	/* Used by output routine if interlaced pic */
int		OutCount = 0;	/* Decompressor output 'stack count' */
int		Interlace;	/* flag for interlaced image */
int		CodeSize,	/* Code size, read from GIF header */
		InitCodeSize,	/* Start code size, used during Clear */
		Code,		/* Value returned by read_code */
		MaxCode,	/* limit value for current code size */
		ClearCode,	/* GIF clear code */
		EOFCode,	/* GIF end-of-information code */
		CurCode,	/* Decompressor variables */
		OldCode,
		InCode,
		FirstFree,	/* First free code, gen'd per GIF spec */
		FreeCode,	/* Decompr, next free slot in hash table */
		FinChar,	/* Decompr variable */
		BitMask,	/* AND mask for data size */
		ReadMask;	/* Code AND mask for cur code size */
int		Prefix[HASHSIZ],/* hash table used by the decompr */
		Suffix[HASHSIZ];
int		OutCode[OUTSIZ];/* output array used by the decompr */
int		BitsPerPixel,	/* image attributes */
		ColorMapSize;
int		BitMask;	/* for decompression */
int		Verbose = 0;	/* this is VERY verbose... */
int		Inquire = 0;	/* inquire or render */
int		Quantize = 0;	/* quantize to 16 shades */
int		Histo = 0;	/* histogram inquiry */
int		Eof = 0;	/* EOF on input flag (GETC) */
uchar_t		GlobColorMap[MAPSIZ][3];/* Global color map */
uchar_t		ColMap[MAPSIZ][3];/* color map we use (global or local)*/
screen_t	ScrnInf;	/* global screen descriptor */
int		ImageNum;	/* if multi-image file (not used) */
long		Hist[HISTSIZ];	/* histogram */
long		rHist[HISTSIZ];
long		gHist[HISTSIZ];
long		bHist[HISTSIZ];
int		XUpperLeft = 0,	/* starting pixel (default is 0,0) */
		YUpperLeft = 0;
int		UseNTSC = 0;	/* NTSC equation for lumin */
int		Filter;		/* for selected colors */


/*
 *	local functions (in order of appearance):
 */
int		usage ();
int		draw_image ();
int		read_raster ();
int		read_code ();
int		add_pixel ();
void		rasterize ();
int		giftorgb ();
void		install_cmap ();
int		scan_SD ();
void		skip_EB ();
int		scan_ID ();
void		scan_CM ();
int		scan_MAGIC ();
int		fdither ();
int		draw_row ();		/* atari ST (line A) */
int		draw_hist ();
int		drhist ();
int		do_line ();		/* atari ST (line A) */
int		cursor ();		/* atari ST (gemdos, vt52) */
int		mv_cursor ();		/* atari ST (vt52) */
int		clr_screen ();		/* atari ST (gemdos, vt52) */
long		do_time ();		/* atari ST (gemdos, sysvar) */
int		write_pi3 ();
int		check_key ();		/* atari ST (BIOS) */
int		wait_key ();		/* atari ST (BIOS) */
int		GETC ();




/*------------------------------*/
/*	main			*/
/*------------------------------*/
main (argc, argv)
int	argc;
char   *argv[];
{

/*
 *	The following illustrates the general file layout of .GIF files:
 *
 *	+-----------------------+
 *	| +-------------------+ |
 *	| |   GIF Signature   | |	GIF87a			(required)
 *	| +-------------------+ |
 *	| +-------------------+ |
 *	| | Screen Descriptor | |	7 bytes, ends with 00	(required)
 *	| +-------------------+ |
 *	| +-------------------+ |
 *	| | Global Color Map  | |	3*2^bits bytes		(optional but
 *	| +-------------------+ |				 usual)
 *	| +-------------------+ |
 *	| | Extension Block   | |	!			(optional)
 *	| +-------------------+ |
 *	. . .		    . . .
 *	| +-------------------+ |
 *	| |  Image Descriptor | |	,			(required)
 *	| +-------------------+ |
 *	| +-------------------+ |
 *	| |  Local Color Map  | |				(optional)
 *	| +-------------------+ |
 *	| +-------------------+ |
 *	| |    Raster Data    | |				(required)
 *	| +-------------------+ |
 *	. . .		    . . .   
 *	|-    GIF Terminator   -|				(required)
 *	+-----------------------+
 *
 */

	int	hold_scrn;	/* for hold before return to desktop */
	long	elapsed;	/* elapsed seconds */
	int	reverse;		/* reverse black/white */
	int	rotate;		/* rotate image +/-90 deg */
	int	mirror;		/* mirror image */
	int	ifac;		/* intensity scale factor 0-100 */
	int	bottom;		/* start at bottom */
	int	enlarge;	/* fill screen */
	int	makepi3;	/* output a pi3 file */
	int	gif_fd;		/* file descriptor */
	char   *ps;
	long	ii;
	int	jret;		/* what setjmp returns */
	int	firsttime = 1;
	long	htot;
	long	hinc;
	char   *pi3name;	/* name of .pi3 file */


	/*
	 *   set defaults...
	 */
	Filter       = ALLPLANE;
	DeviceInten  = -1L;
	hold_scrn    = 1;
	rotate       = 0;
	reverse       = 0;
	mirror       = 0;
	bottom       = 0;
	enlarge      = 0;
	makepi3      = 0;
	ifac         = 40;		/* reasonable value */
	pi3name      = (char *) NULL;



	/*
	 *   parse args...
	 */
	argc--, argv++;
	while (argc && (**argv == '-' || **argv == '+'))
	{
		if (**argv == '+' && !strncmp (*argv, "+90", 3))
			rotate = 90;
		else if (**argv == '-')
		{
			switch (*(*argv+1))
			{
			case '9':		/* -90 deg rotation */
				rotate = -90;
				break;

			case 'b':		/* start at bottom */
				bottom = 1;
				break;

			case 'e':		/* enlarge to fill screen */
				enlarge = 1;
				break;

			case 'q':
				if (*(*argv+2) != 0)
					Quantize = atoi (*argv+2);
				else
					Quantize = 16;
				break;

			case 'r':		/* reverse black/white */
				reverse = 1;
				break;

			case 'm':		/* mirror image */
				mirror = 1;
				break;

			case 'N':		/* NTSC lum equation */
				UseNTSC = 1;
				break;

			case 's':		/* intensity scale factor */
				ifac = atoi (*argv+2);
				break;

			case 'f':		/* filter */
				Filter = atoi (*argv+2);
				break;

			case 'x':		/* start pixel x */
				XUpperLeft = atoi (*argv+2);
				break;

			case 'y':		/* start pixel y */
				YUpperLeft = atoi (*argv+2);
				break;

			case 'd':		/* device intensity */
				DeviceInten = (long) atoi (*argv+2);
				break;

			case 'i':		/* inquire only */
				Inquire++;
				break;

			case 'o':		/* output a pi3 */
				makepi3++;
				argc--, argv++;
				if (argc < 2)
				{
					fprintf (stderr,
						"%s: must specify file with -o\n",
						myname);
					usage (1);
				}
				pi3name = *argv;
				break;

			case 'v':		/* verbose output (VERY!) */
				if (!strncmp (*argv, "-vers", 5))
				{
					printf ("%s\n", version);
					exit (0);
				}
				Verbose++;
				break;

			case 'h':		/* histogram/help */
				if (!strncmp (*argv, "-help", 5))
				{
					usage (0);
				}
				Histo++;
				Inquire++;
				break;

			default:
				usage (0);
				break;
			}
		}
		argc--, argv++;
	}



	/*
	 *   make sure we have at least one file...
	 */
	if (argc < 1)
		usage (1);



	/*
	 *   force inquire if verbose...
	 */
	if (Verbose)
		Inquire++;



	/*
	 *   instructions (col, row)...
	 */
	if (!Inquire && !Verbose)
	{
		/*
		 *   initialize things (clear screen, turn off cursor, init
		 *   timing)
		 */
		clr_screen ();
		cursor (0);
		do_time (0);

		mv_cursor (10, 10);  printf ("After image is drawn,  press any key");
		mv_cursor (10, 11);  printf ("for next image (or to exit). You can");
		mv_cursor (10, 12);  printf ("interrupt rendering at any time with");
		mv_cursor (10, 13);  printf ("any key.");
		mv_cursor (10, 16);  printf ("Press any key to continue...");

		wait_key ();			/* wait for a keypress... */
	}



	/*
	 *   loop on remaining files...
	 */
	while (argc--)
	{
#ifdef SINGLE_FILE
		if (!Inquire)
			argc = 0;
#endif

		/*
		 *   fresh screen...
		 */
		if (!Inquire && !Verbose)
			clr_screen ();


		/*
		 *   open file
		 */
		ps = *argv++;
		if ((gif_fd = openb (ps, 0)) < 0)
		{
			fprintf (stderr, "%s: could not open %s\n",
					myname, ps);
			continue;
		}


		/*
		 *   make sure it is a gif file (file header is this...)
		 */
		if (!scan_MAGIC (gif_fd, "GIF87a"))
		{
			fprintf (stderr, "%s: %s not a gif file\n",
					myname, ps);
			close (gif_fd);
			continue;
		}


		/*
		 *   read screen descriptor...
		 */
		if (!scan_SD (gif_fd, &ScrnInf))
		{
			fprintf (stderr,
				"%s: file %s data format error in screen descriptor\n",
				myname, ps);
			close (gif_fd);
			continue;
		}
		if (Inquire)
		{
		printf ("File:                      %s\n", ps);
		printf ("\n");
		printf ("Screen info:\n");
		printf ("\n");
		printf ("     Screen width (s_dx)       = %d\n", (int) ScrnInf.s_dx);
		printf ("     Screen height (s_dy)      = %d\n", (int) ScrnInf.s_dy);
		printf ("     Global map? (s_gcm)       = %d\n", (int) ScrnInf.s_gcm);
		printf ("     Color resolution (s_cr)   = %d\n", (int) ScrnInf.s_cr);
		printf ("     Bits/pixel (s_bits)       = %d\n", (int) ScrnInf.s_bits);
		printf ("     Num colors (s_colors)     = %d\n", (int) ScrnInf.s_colors);
		printf ("     Background color (s_bgnd) = %d\n", (int) ScrnInf.s_bgnd);
		printf ("\n");
		}


		/*
		 *   read global color map if we have one...
		 */
		if (ScrnInf.s_gcm)
		{
			if (Inquire)
				printf ("Global color map:\n\n");

			scan_CM (gif_fd,
				 ScrnInf.s_colors,
				 (char *) GlobColorMap);
		}


		/*
		 *   do it (this assumes only 1 image per file, a reasonable
		 *   assumption)...
		 */
		ImageNum = 0;
		do_time (1);

		draw_image (gif_fd, ifac, reverse, enlarge, mirror, rotate);

#ifdef USE_SETJMP
		if (firsttime)
		{
			firsttime = 0;
			setjmp (JmpEnv);
		}
#endif

		elapsed = do_time (2);
		close (gif_fd);


		/*
		 *   write a .pi3 file before screen gets messed up...
		 */
		if (!Inquire && makepi3 && (pi3name != (char *) NULL))
		{
			int	wret;

			wret = write_pi3 (pi3name);
			if (wret)
			{
				printf ("Any key...\n");
				wait_key ();
			}
			else
			{
				mv_cursor (0, 24);
				printf (" Wrote PI3 file %s", pi3name);
			}
		}


		/*
		 *   if just inquiry with histogram, print histogram then cont
		 */
		if (Inquire && Histo)
		{
			printf ("\nHistogram:\n\n");
			printf ("  Index    Full      Color Map      Red      Green      Blue   Histogram\n");
/*!!!			hinc = 256 / (ColorMapSize);*/
/*!!!			hinc = 256 >> BitsPerPixel;*/
			hinc = 1;
			for (htot = 0, ii = 0; ii < HISTSIZ; ii += hinc)
			{
				htot += Hist[ii];
				printf ("  %5d%10ld   %02x   %02x   %02x%10ld%10ld%10ld\n",
					(int)ii,
					Hist[ii],
					(int) ColMap[ii][0],
					(int) ColMap[ii][1],
					(int) ColMap[ii][2],
					rHist[ii],
					gHist[ii],
					bHist[ii]);
			}
			printf ("\n  total%ld pixels\n\n", htot);
			continue;
		}


		/*
		 *   if just an inquiry, continue to next file...
		 */
		if (Inquire)
			continue;


		/*
		 *   before displaying timing data, wait for a key...
		 */
		wait_key ();


		/*
		 *   legend (col, row)...
		 */
		mv_cursor ( 0, 24);  printf (" file: %-39s     ", ps);
		mv_cursor (46, 24);  printf ("time: %4ld sec,  ", elapsed);
		mv_cursor (62, 24);  printf ("any key (next)...");
		fflush (stdout);

		wait_key ();		/* wait for a keypress... */


		/*
		 *   histogram plot
		 */
		if (!Inquire)
		{
			clr_screen ();
			mv_cursor (1, 1); printf ("   Histogram for this image:\n");

			draw_hist ();

			mv_cursor (15, 20); printf (" Full");
			mv_cursor ( 0,  3); printf ("  00");
			mv_cursor ( 0, 19); printf ("  FF");
			mv_cursor (36, 20); printf (" Red");
			mv_cursor (48, 20); printf (" Green");
			mv_cursor (62, 20); printf (" Blue");

			for (htot = 0, ii = 0; ii < HISTSIZ; ii++)
				htot += Hist[ii];

			mv_cursor ( 1, 22); printf ("  Total pixels %ld", htot);
			mv_cursor (62, 24); printf ("any key...       ");
			fflush (stdout);

			wait_key ();		/* wait for a keypress... */
		}


		/*
		 *   get ready for next image...
		 */
		if (!Inquire && argc)
		{
			clr_screen ();
			printf (" Resetting tables...\n");

			BitOffset    = 0;
			XC           = 0;
			YC           = 0;
			Pass         = 0;
			OutCount     = 0;
			CodeSize     = 0;
			InitCodeSize = 0;
			Code         = 0;
			MaxCode      = 0;
			ClearCode    = 0;
			EOFCode      = 0;
			CurCode      = 0;
			OldCode      = 0;
			InCode       = 0;
			FirstFree    = 0;
			FreeCode     = 0;
			FinChar      = 0;
			BitMask      = 0;
			ReadMask     = 0;
			BitMask      = 0;
			Eof          = 0;

			for (ii = 0; ii < HISTSIZ; ii++)
			{
				Hist[ii] = 0;
				rHist[ii] = 0;
				gHist[ii] = 0;
				bHist[ii] = 0;
			}
			for (ii = 0; ii < MAXIMG; ii++)
				Raster[ii] = 0;
			for (ii = 0; ii < MAXRAW; ii++)
				CodedGIF[ii] = 0;
			for (ii = 0; ii < HASHSIZ; ii++)
			{
				Prefix[ii] = 0;
				Suffix[ii] = 0;
			}
			for (ii = 0; ii < OUTSIZ; ii++)
				OutCode[ii] = 0;

			check_key ();
		}
	}


	/*
	 *   clean up and exit
	 */
	if (hold_scrn && !Inquire)
	{
		mv_cursor (62, 24);  printf (" any key (exit)...");
		fflush (stdout);

		wait_key ();
		cursor (1);
	}

	exit (0);
}



/*------------------------------*/
/*	usage			*/
/*------------------------------*/
usage (excode)
int	excode;
{

#ifdef SINGLE_FILE
/*	fprintf (stderr,
	"%s [-i|-h][-o file][-sn][-dn][-e][-r][-q][-m][-N][-90][+90][-xn -yn] file\n",
		myname);
*/
	fprintf (stderr, "%s [options] file\n", myname);
#else
/*	fprintf (stderr,
	"%s [-i|-h][-o file][-sn][-dn][-e][-r][-q][-m][-N][-90][+90][-xn -yn] file ...\n",
		myname);
*/
	fprintf (stderr, "%s [options] file ...\n", myname);
#endif
	fprintf (stderr, "\n");
	fprintf (stderr, "-i       inquire about image only\n");
	fprintf (stderr, "-h       inquire plus histogram (-h implies -i)\n");
	fprintf (stderr, "-o file  output a .pi3 file with name file\n");
	fprintf (stderr, "-sn      specify scaling factor, 1 to 100 (40 is default)\n");
/*	fprintf (stderr, "-dn      specify device intensity (default is 3*(1<<bits)\n");*/
	fprintf (stderr, "-dn      specify device intensity (default is 650)\n");
	fprintf (stderr, "-e       expand 320x200 image to fill screen\n");
	fprintf (stderr, "-r       reverse black and white\n");
	fprintf (stderr, "-q       quantize to 16 colors\n");
	fprintf (stderr, "-fn      filter (OR of 1=red,2=green,4=blue)\n");
	fprintf (stderr, "-m       mirror image\n");
	fprintf (stderr, "-N       use NTSC equation for luminescence\n");
	fprintf (stderr, "-90      rotate image 90 deg clockwise\n");
	fprintf (stderr, "+90      rotate image 90 deg counterclockwise\n");
	fprintf (stderr, "-xn      starting pixel of original image\n");
	fprintf (stderr, "-yn      starting pixel of original image\n");
	fprintf (stderr, "file     a .gif file\n");
	fprintf (stderr, "\n");
	fprintf (stderr, "If specifying more than one file, they each share all switch settings.\n");
	fprintf (stderr, "To make an image darker, use lower values for -sn.\n");
	fprintf (stderr, "Rasing the value of -dn has the same effect as lowering -sn.\n");

	cursor (1);
	exit (excode);
}



/*------------------------------*/
/*	draw_image		*/
/*------------------------------*/
int draw_image (infile, ifac, reverse, enlarge, mirror, rotate)
int	infile;
int	ifac;
int	reverse;
int	enlarge;
int	mirror;
int	rotate;
{
	uchar_t		lcm[MAPSIZ][3];
	int		flag;
	image_t		id;
	int		top;
	int		width;
	int		height;
	int		rownum;
	int		i;




	/*
	 *   read image descriptor
	 */
	ImageNum++;
	if (Inquire)
		printf ("\n\n\nImage number: %d\n", ImageNum);
	if (Verbose)
		printf ("Read image descriptor\n");

	flag = scan_ID (infile, &id);

	if (Verbose)
		printf ("Read image descriptor ret = %d\n", flag);
	if (flag == 0)
	{
		fprintf (stderr, "%s: unexpected EOF\n", myname);
		return (0);
	}
	if (flag == 1)
		return (0);
	if (Inquire)
	{
		printf ("     Image left (i_x)         = %d\n", (int) id.i_x);
		printf ("     Image top (i_y)          = %d\n", (int) id.i_y);
		printf ("     Image width (i_dx)       = %d\n", (int) id.i_dx);
		printf ("     Image height (i_dy)      = %d\n", (int) id.i_dy);
		printf ("     Use local map? (i_gcm)   = %d\n", (int) id.i_gcm);
		printf ("     Interlaced? (i_intlace)  = %d\n", (int) id.i_intlace);
		printf ("     Bits per pixel (i_bits)  = %d\n", (int) id.i_bits);
		printf ("     Number colors (i_colors) = %d\n", (int) id.i_colors);
		printf ("     (If no local color map, use screen bits and colors)\n");
		printf ("\n");
	}



	/*
	 *   read local color map, if there
	 */
	if (id.i_gcm)
	{
		if (Inquire)
			printf ("Local color map:\n\n");

		scan_CM (infile, id.i_colors, (char *) lcm);

		install_cmap (id.i_colors, (uchar_t *) lcm);
	}
	else
	{
		if (Inquire)
			printf ("Use global color map\n\n");

		install_cmap (ScrnInf.s_colors, (uchar_t *) GlobColorMap);

		/*
		 *   make sure to reset these from global info...
		 */
		id.i_colors = ScrnInf.s_colors;
		id.i_bits   = ScrnInf.s_bits;
	}

	BitsPerPixel = id.i_bits;
	ColorMapSize = 1 << BitsPerPixel;
	BitMask      = ColorMapSize - 1;


	/*
	 *   now set device intensity default, after we know bits...
	 */
	if (DeviceInten < 0)
	{
#if SCAL_DEVINT
		if      (id.i_bits == 1)	DeviceInten = 3*2;
		else if (id.i_bits == 2)	DeviceInten = 3*4;
		else if (id.i_bits == 3)	DeviceInten = 3*8;
		else if (id.i_bits == 4)	DeviceInten = 3*16;
		else if (id.i_bits == 5)	DeviceInten = 3*32;
		else if (id.i_bits == 6)	DeviceInten = 3*64;
		else if (id.i_bits == 7)	DeviceInten = 3*128;
		else if (id.i_bits == 8)	DeviceInten = 3*256;
		else if (id.i_bits == 9)	DeviceInten = 3*512;
		else if (id.i_bits == 10)	DeviceInten = 3*1024;
		else if (id.i_bits == 11)	DeviceInten = 3*2048;
		else if (id.i_bits == 12)	DeviceInten = 3*4096;
		else				DeviceInten = 3*4096;
#else
		if (UseNTSC)
			DeviceInten = 400;
		else
			DeviceInten = 650;	/* a resonable value... */
#endif
	}
	if (Verbose)
	{
		printf ("BitsPerPixel = %d\n", BitsPerPixel);
		printf ("ColorMapSize = %d\n", ColorMapSize);
		printf ("BitMask      = %04x\n", BitMask);
	}
	if (Inquire)
	{
		printf ("Scale factor:     %d\n", ifac);
		printf ("Device intensity: %ld\n", DeviceInten);
	}



	/*
	 *   check size vs internal buffer...
	 */
	width  = id.i_dx;
	height = id.i_dy;
	top    = id.i_x;
	if ((long) width * (long) height > MAXIMG)
	{
		fprintf (stderr, "this GIF too large for memory\n\n");
		return (0);
	}


	/*
	 *   if just an inquiry, quit now...
	 */
	if (Inquire && !Histo)
		return (0);



	/*
	 *   read raster data
	 */
	Interlace = id.i_intlace;
	Height    = height;
	Width     = width;

	if (read_raster (infile))
	{
		fprintf (stderr, "%s: error reading raster image\n", myname);
		return (0);
	}



	/*
	 *   if just an histogram, quit now...
	 */
	if (Inquire && Histo)
		return (0);



	/*
	 *   do image...
	 */
	if (Verbose)
		printf ("Do image...\n");
	else
		clr_screen ();

	if (enlarge && (width <= 320))
	{
		int	ylim;

		ylim = 2 * height;
		if ((ylim > MAX_Y) && !rotate)
			ylim = MAX_Y;
		else if ((ylim > MAX_X) && rotate)
			ylim = MAX_X;
		for (rownum = 0; rownum < ylim; rownum++)
		{
			rasterize (&id, rownum, width, ifac, reverse,
				DeviceInten, mirror, rotate, enlarge);

#ifdef USE_SETJMP
			if (check_key ())
				longjmp (JmpEnv, 1);
#else
			if (check_key ())
				exit (1);
#endif
		}
	}
	else
	{
		for (rownum = 0; rownum < height; rownum++)
		{
			rasterize (&id, rownum, width, ifac, reverse,
				DeviceInten, mirror, rotate, 0);

#ifdef USE_SETJMP
			if (check_key ())
				longjmp (JmpEnv, 1);
#else
			if (check_key ())
				exit (1);
#endif
		}
	}


#ifdef USE_SETJMP
	if (check_key ())
		longjmp (JmpEnv, 1);
#else
	if (check_key ())
		exit (1);
#endif

	return (!0);
}




/*------------------------------*/
/*	read_raster		*/
/*------------------------------*/
int read_raster (infile)
int	infile;
{

/*
 *	Decode a raster image
 */

	uchar_t	       *pcoded;
	uchar_t	       *praster;
	uint_t		ch;
	uint_t		ch1;
	int		i;
	int		nread;


	if (!Verbose && !Inquire)
		clr_screen ();
	printf ("Read raster data...\n");


	/*
	 *   Start reading the raster data. First we get the intial code size
	 *   and compute decompressor constant values, based on this code size.
	 */
	CodeSize  = GETC (infile);
	if (ENDFILE (infile))
	{
		fprintf (stderr, "read_raster: unexpected EOF\n");
		return (1);
	}
	ClearCode = (1 << CodeSize);
	EOFCode   = ClearCode + 1;
	FreeCode  = FirstFree = ClearCode + 2;


	/*
	 *   The GIF spec has it that the code size is the code size used to
	 *   compute the above values is the code size given in the file, but
	 *   the code size used in compression/decompression is the code size
	 *   given in the file plus one. (thus the ++).
	 */
	CodeSize++;
	InitCodeSize = CodeSize;
	MaxCode      = (1 << CodeSize);
	ReadMask     = MaxCode - 1;

	if (Verbose)
	{
		fprintf (stderr, "CodeSize  = %04x\n", CodeSize);
		fprintf (stderr, "ClearCode = %04x\n", ClearCode);
		fprintf (stderr, "EOFCode   = %04x\n", EOFCode);
		fprintf (stderr, "MaxCode   = %04x\n", MaxCode);
		fprintf (stderr, "ReadMask  = %04x\n", ReadMask);
	}


	/*
	 *   Read the raster data. Here we just transpose it from the GIF array
	 *   to the Raster array, turning it from a series of blocks into one
	 *   long data stream, which makes life much easier for read_code().
	 */
	pcoded = CodedGIF;
	do
	{
#ifdef USE_SETJMP
		if (check_key ())
			longjmp (JmpEnv, 1);
#else
		if (check_key ())
			exit (1);
#endif
		ch    = (uint_t) GETC (infile);

		if (Verbose)
			fprintf (stderr, "read %u bytes from file\n", ch);
		nread = read (infile, pcoded, ch);
		if (nread != ch)
		{
			fprintf (stderr, "error reading raster data\n");
			exit (1);
		}
		pcoded += (long) ch;

		if (((long) pcoded - (long) CodedGIF) > MAXRAW-255)
		{
			fprintf (stderr, "corrupt GIF file (unblock)\n");
			exit (1);
		}

	} while (ch);

	if (!Verbose && !Inquire)
		clr_screen ();
	printf ("Decompressing data...\n");
	if (!Inquire)
	{
		printf ("\n");
		printf ("Width            = %d\n", (int) ScrnInf.s_dx);
		printf ("Height           = %d\n", (int) ScrnInf.s_dy);
		printf ("Bits/pixel       = %d\n", (int) ScrnInf.s_bits);
		printf ("Number of colors = %d\n", (int) ScrnInf.s_colors);
	}


	/*
	 *   Decompress the file, continuing until you see the GIF EOF code.
	 *   One obvious enhancement is to add checking for corrupt files here.
	 */
	Code = read_code ();
	while (Code != EOFCode)
	{

		/*
		 *   Clear code sets everything back to its initial value,
		 *   then reads the immediately subsequent code as
		 *   uncompressed data.
		 */
		if (Code == ClearCode)
		{
			CodeSize = InitCodeSize;
			MaxCode  = (1 << CodeSize);
			ReadMask = MaxCode - 1;
			FreeCode = FirstFree;
			Code     = read_code ();
			CurCode  = Code;
			OldCode  = Code;
			FinChar  = CurCode & BitMask;
			add_pixel ((uchar_t) FinChar);
		}
		else
		{

			/*
			 *   If not a clear code, then must be data: save
			 *   same as CurCode and InCode
			 */
			CurCode = Code;
			InCode  = Code;

			/*
			 *   If greater or equal to FreeCode, not in
			 *   the hash table yet;
			 *   repeat the last character decoded
			 */
			if (CurCode >= FreeCode)
			{
				CurCode             = OldCode;
				OutCode[OutCount++] = FinChar;
			}

			/*
			 *   Unless this code is raw data, pursue the chain
			 *   pointed to by CurCode through the hash table
			 *   to its end; each code in the chain puts its
			 *   associated output code on the output queue.
			 */
			while (CurCode > BitMask)
			{
				if (OutCount > 1024)
				{
					fprintf (stderr,
						"corrupt GIF file (OutCount)\n");
					exit (1);
				}
				OutCode[OutCount++] = Suffix[CurCode];
				CurCode             = Prefix[CurCode];
			}

			/*
			 *   The last code in the chain is treated as raw data
			 */
			FinChar             = CurCode & BitMask;
			OutCode[OutCount++] = FinChar;

			/*
			 *   Now we put the data out to the Output routine.
			 *   It's been stacked LIFO, so deal with it that way
			 */
			for (i = OutCount - 1; i >= 0; i--)
				add_pixel ((uchar_t) OutCode[i]);
			OutCount = 0;

			/*
			 *   Build the hash table on-the-fly. No table is
			 *   stored in the file.
			 */
			Prefix[FreeCode] = OldCode;
			Suffix[FreeCode] = FinChar;
			OldCode          = InCode;

			/*
			 *   Point to the next slot in the table.  If we
			 *   exceed the current MaxCode value, increment
			 *   the code size unless it's already 12.  If it
			 *   is, do nothing: the next code decompressed
			 *   better be CLEAR
			 */
			FreeCode++;
			if (FreeCode >= MaxCode)
			{
				if (CodeSize < 12)
				{
					CodeSize++;
					MaxCode *= 2;
					ReadMask = (1 << CodeSize) - 1;
				}
			}
		}
		Code = read_code();
	}
	return (0);
}




/*------------------------------*/
/*	read_code		*/
/*------------------------------*/
read_code ()
{

/*
 *	Fetch the next code from the raster data stream.  The codes can be
 *	any length from 3 to 12 bits, packed into 8-bit bytes, so we have to
 *	maintain our location in the Raster array as a BIT Offset.  We compute
 *	the byte Offset into the raster array by dividing this by 8, pick up
 *	three bytes, compute the bit Offset into our 24-bit chunk, shift to
 *	bring the desired code to the bottom, then mask it off and return it. 
 */

	ulong_t		rawcode;
	ulong_t		byteoffset;
	ulong_t		shft;
	int		ret;

	byteoffset = BitOffset / 8;

	rawcode    = CodedGIF[byteoffset] + (0x100 * CodedGIF[byteoffset + 1]);
	if (CodeSize >= 8)
		rawcode += (0x10000 * CodedGIF[byteoffset + 2]);

	shft       = BitOffset % 8;
	rawcode  >>= (shft);
	BitOffset += CodeSize;

	ret = (int) (rawcode & (ulong_t) ReadMask);

	if (Verbose && XC == Width/2)
	{
		fprintf (stderr,
		"BitOff=%ld, ByteOff=%ld, shft=%ld, mask=%04x, ret=%d\n",
		BitOffset,byteoffset,shft,ReadMask,ret);
	}

	return (ret);
}



/*------------------------------*/
/*	add_pixel		*/
/*------------------------------*/
add_pixel (indx)
uchar_t	indx;
{
	long		oset;		/* linear ptr into Raster */
	uint_t		hval;		/* ptr into Hist */


	/*
	 *   check for array overflow...
	 */
	oset = ((long) YC * (long) Width) + (long) XC;
	if (Verbose && XC == Width/2)
		fprintf (stderr, "add_pixel: XC,YC = %d,%d, oset = %ld, indx = %02x\n",
				XC, YC, oset, (uint_t) indx);
	if (oset > MAXIMG)
	{
		fprintf (stderr, "add_pixel: image too large\n");
		exit (1);
	}


	/*
	 *   add to raster array...
	 */
	if (YC < Height)
	{
		Raster[oset] = indx;
		if (UseNTSC)
		{
			hval = (((uint_t) (ColMap[(uint_t)indx][0]) * 30)
			     +  ((uint_t) (ColMap[(uint_t)indx][1]) * 59)
			     +  ((uint_t) (ColMap[(uint_t)indx][2]) * 11))/300;
			if (hval > HISTSIZ - 1)
			{
				hval = HISTSIZ - 1;
				fprintf (stderr, "\nwarning: hval too large (add_pixel)\n");
			}
		}
		else
		{
			hval = ((uint_t) (ColMap[(uint_t)indx][0])
			     +  (uint_t) (ColMap[(uint_t)indx][1])
			     +  (uint_t) (ColMap[(uint_t)indx][2]))/3;
		}
		Hist[hval] = Hist[hval] + 1;
		if (Verbose && XC == Width/2)
		{
			fprintf (stderr,
				"add: indx=%u(%04x), hval=%u(%04x), Hist=%ld\n",
				(uint_t)indx, (uint_t)indx, hval, hval, Hist[hval]);
		}

		hval        = (uint_t) (ColMap[(uint_t)indx][0]);
		rHist[hval] = rHist[hval] + 1;

		hval        = (uint_t) (ColMap[(uint_t)indx][1]);
		gHist[hval] = gHist[hval] + 1;

		hval        = (uint_t) (ColMap[(uint_t)indx][2]);
		bHist[hval] = bHist[hval] + 1;
	}


	/*
	 *   Update the X-coordinate, and if it overflows, update the
	 *   Y-coordinate
	 */
	if (++XC == Width)
	{
		/*
		 *   If a non-interlaced picture, just increment YC to the
		 *   next scan line. If it's interlaced, deal with the
		 *   interlace as described in the GIF spec.  Put the
		 *   decoded scan line out to the screen if we haven't gone
		 *   past the bottom of it
		 */
		XC = 0;
		if (!Interlace)
			YC++;
		else
		{
			switch (Pass)
			{
			case 0:
				YC += 8;
				if (YC >= Height)
				{
					Pass++;
					YC = 4;
				}
				break;
			case 1:
				YC += 8;
				if (YC >= Height)
				{
					Pass++;
					YC = 2;
				}
				break;
			case 2:
				YC += 4;
				if (YC >= Height)
				{
					Pass++;
					YC = 1;
				}
				break;
			case 3:
				YC += 2;
				break;
			default:
				fprintf (stderr, "add_pixel: can't happen\n");
			}
		}
	}
}





/*------------------------------*/
/*	rasterize		*/
/*------------------------------*/
void rasterize (id, iy, width, ifac, reverse, devint, mirror, rotate, enlarge)
image_t	       *id;
int		iy;
int		width;
int		ifac;
int		reverse;
long		devint;
int		mirror;
int		rotate;
int		enlarge;
{

/*
 *	Read a row out of the raster image and draw it...
 */

	static int	firsttime = 1;
	static long	accum0[MAXPIXLINE];	/* error accumulation arrays */
	static long	accum1[MAXPIXLINE];

	uint_t		red[MAXPIXLINE];	/* up to 16 bit which is */
	uint_t		green[MAXPIXLINE];	/* overkill */
	uint_t		blue[MAXPIXLINE];
	uchar_t		row[MAXPIXLINE];
	long	       *pac0;
	long	       *pac1;
	int		direction;
	int		xmax;
	int		ix;
	uchar_t	       *praster;


#ifdef USE_SETJMP
	if (check_key ())
		longjmp (JmpEnv, 1);
#else
	if (check_key ())
		exit (1);
#endif

	if (enlarge && (width <= 320))
	{
		if ((iy >= MAX_Y) && !rotate)
			return;
		if ((iy >= MAX_X) && rotate)
			return;
	}
	else
	{
		if ((iy >= MAX_Y) && !rotate)
			return;
		if ((iy >= MAX_X) && rotate)
			return;
	}

	if (enlarge && (width <= 320))
	{
		xmax = 2 * width;
	}
	else
	{
		xmax = width;
		if (xmax > MAX_X)
			xmax = MAX_X;
	}


	/*
	 *   make sure to zero out error accumulate array!
	 */
	if (firsttime)
	{
		firsttime = 0;
		for (ix = 0; ix < xmax+1; ix++)
		{
			accum0[ix] = 0;
			accum1[ix] = 0;
		}
	}
	for (ix = 0; ix < xmax+1; ix++)
	{
		row[ix]    = 0;
	}



	/*
	 *   convert pixel row to rgb arrays. if enlarging, we get each row
	 *   twice so divide iy by 2...
	 */
	if (enlarge && (width <= 320))
	    praster = (uchar_t *) ((long) Raster + ((long) (iy/2) * (long) width));
	else
	    praster = (uchar_t *) ((long) Raster + ((long) iy * (long) width));

	giftorgb (praster, width, id->i_colors, ColMap, red, green, blue);


	/*
	 *   if enlarging a 320x200 to 640x400, shift pixels down
	 *   and fill in missing pixels with average of adjacent
	 *   pixels in the row...
	 */
	if (enlarge && (width <= 320))
	{
		for (ix = width-1; ix > 0; ix--)
		{
			red[2*ix]     = red[ix];
			red[2*ix-1]   = (red[ix] + red[ix-1]) / 2;
			green[2*ix]   = green[ix];
			green[2*ix-1] = (green[ix] + green[ix-1]) / 2;
			blue[2*ix]    = blue[ix];
			blue[2*ix-1]  = (blue[ix] + blue[ix-1]) / 2;
		}
		red[2*width-1]   = 0;
		green[2*width-1] = 0;
		blue[2*width-1]  = 0;
	}


	/*
	 *   odd rows, go left, even rows go right...
	 */
	if (iy % 2)
	{
		pac0 = &accum1[1];
		pac1 = &accum0[1];
		for (ix = -1; ix < xmax+1; ix++)
			pac1[ix] = 0;
		direction = LEFT;
	}
	else
	{
		pac0 = &accum0[1];
		pac1 = &accum1[1];
		for (ix = -1; ix < xmax+1; ix++)
			pac1[ix] = 0;
		direction = RIGHT;
	}


	/*
	 *   dither the row...
	 */
	fdither (direction, ifac, pac0, pac1, xmax, id->i_bits,
		red, green, blue, row, devint, UseNTSC, Filter);


	/*
	 *   ...and draw it...
	 */
	draw_row (iy, row, xmax, reverse, mirror, rotate);


	/*
	 *   check for interrupt...
	 */
#ifdef USE_SETJMP
	if (check_key ())
		longjmp (JmpEnv, 1);
#else
	if (check_key ())
		exit (1);
#endif
}



/*------------------------------*/
/*	giftorgb		*/
/*------------------------------*/
giftorgb (pixrow, count, colors, map, red, green, blue)
uchar_t	       *pixrow;
int		count;
int		colors;
uchar_t		map[][3];
uint_t	       *red;
uint_t	       *green;
uint_t	       *blue;
{

/*
 *	decompose gif raster row into seperate rgb tables
 */

	register int		ix;
	register int		i;
	register uchar_t	c;
	register int		lim;
	int			start;



	/*
	 *   set x limits. lim is number of pixels, start is first one in row
	 */
	lim   = count;
	start = 0;


	/*
	 *   for large images, just take center 640 pixels...
	 */
	if (count > MAX_X)
	{
		lim   = MAX_X;
		start = ((count - MAX_X) / 2) - 1;
		if (start < 0)
			start = 0;
	}


	/*
	 *   pixrow contains indices into color map. copy them to rgb arrays
	 */
	for (i = 0, ix = start; i < lim; i++, ix++)
	{
		c        = pixrow[ix];
		red[i]   = (uint_t) (map[(uint_t)c][0]);
		green[i] = (uint_t) (map[(uint_t)c][1]);
		blue[i]  = (uint_t) (map[(uint_t)c][2]);
	}
}



/*------------------------------*/
/*	install_cmap		*/
/*------------------------------*/
void install_cmap (colors, cm)
int		colors;
uchar_t	       *cm;
{
	uchar_t	       *scan;
	int		i;

	/*
	 *   most all images currently use global map, though this will
	 *   copy whatever cm points to (either local or global) into the
	 *   real map we use...
	 */
	for (scan = cm, i = 0; colors > 0; i++, colors--)
	{
		ColMap[i][0] = *scan++;
		ColMap[i][1] = *scan++;
		ColMap[i][2] = *scan++;
	}

}



/*------------------------------*/
/*	scan_SD			*/
/*------------------------------*/
int scan_SD (infile, sd)
int		infile;
screen_t       *sd;
{

/*
 *	read logical screen descriptor (req'd)
 *
 *		bits
 *	 7 6 5 4 3 2 1 0  Byte #
 *	+---------------+
 *	|		|  1
 *	+-Screen Width -+	Raster width in pixels (LSB first)
 *	|		|  2
 *	+---------------+
 *	|		|  3
 *	+-Screen Height-+	Raster height in pixels (LSB first)
 *	|		|  4
 *	+-+-----+-+-----+	M = 1, Global color map follows Descriptor
 *	|M|  cr |0|pixel|  5	cr+1 = # bits of color resolution
 *	+-+-----+-+-----+	pixel+1 = # bits/pixel in image
 *	|   background  |  6	background=Color index of screen background
 *	+---------------+	     (color is defined from the Global color
 *	|0 0 0 0 0 0 0 0|  7	      map or default map if none specified)
 *	+---------------+
 */

	uchar_t		data;
	uint_t		idata;

	idata        = (uint_t) GETC (infile);		/* width */
	sd->s_dx     = idata + ((uint_t) GETC (infile) << 8);

	idata        = (uint_t) GETC (infile);		/* height */
	sd->s_dy     = idata + ((uint_t) GETC (infile) << 8);


	idata        = GETC (infile);
	if (idata & 8)					/* bit must be 0 */
		return (0);				/* error... */

	sd->s_gcm    = (idata >> 7) & 0x01;		/* global color map?*/
	sd->s_cr     = (idata & 0x70) >> 4;		/* color resolution */
	sd->s_bits   = (idata & 7) + 1;			/* pix size, bits */
	sd->s_colors = 1 << sd->s_bits;			/* num colors */
	sd->s_bgnd   = GETC (infile);			/* background color */

	idata        = GETC (infile);
	if (idata != 0)					/* sorted map? */
		return (0);

	return (!0);
}



/*------------------------------*/
/*	skip_EB			*/
/*------------------------------*/
void skip_EB (infile)
int	infile;
{

/*
 *	skips extension block
 *
 *	 7 6 5 4 3 2 1 0  Byte #
 *	+---------------+
 *	|0 0 1 0 0 0 0 1|  1	   '!' - GIF Extension Block Introducer
 *	+---------------+
 *	| function code |  2	   Extension function code (0 to 255)
 *	+---------------+    ---+
 *	|  byte count	|	|
 *	+---------------+	|
 *	:		:	+-- Repeated as many times as necessary
 *	|func data bytes|	|
 *	:		:	|
 *	+---------------+    ---+
 *	. . .	    . . .
 *	+---------------+
 *	|0 0 0 0 0 0 0 0|	zero byte count (terminates block)
 *	+---------------+
 */

	uint_t	count;
	char	garbage[256];


	if (Inquire)
	{
		printf ("Skip extension block...\n");

/*!!!		exit (-1);*/
	}

	GETC (infile);			/* get function */

	while (count = (uint_t) GETC (infile))	/* get data */
	{
		if (ENDFILE (infile))
		{
			fprintf (stderr, "skip_EB: unexpected EOF\n");
			exit (1);
		}

		read (infile, garbage, count);

		if (ENDFILE (infile))
		{
			fprintf (stderr, "skip_EB: unexpected EOF\n");
			exit (1);
		}
	}
}



/*------------------------------*/
/*	scan_ID			*/
/*------------------------------*/
int scan_ID (infile, id)
int		infile;
image_t        *id;
{

/*
 *	read image descriptor (req'd)
 *
 *	      bits
 *	 7 6 5 4 3 2 1 0  Byte #
 *	+---------------+
 *	|0 0 1 0 1 1 0 0|  1	',' - Image separator character
 *	+---------------+
 *	|		|  2	Start of image in pixels from the
 *	+-  Image Left -+	left side of the screen (LSB first)
 *	|		|  3
 *	+---------------+
 *	|		|  4
 *	+-  Image Top  -+	Start of image in pixels from the
 *	|		|  5	top of the screen (LSB first)
 *	+---------------+
 *	|		|  6
 *	+- Image Width -+	Width of the image in pixels (LSB first)
 *	|		|  7
 *	+---------------+
 *	|		|  8
 *	+- Image Height-+	Height of the image in pixels (LSB first)
 *	|		|  9
 *	+-+-+-+-+-+-----+	M=0 - Use global color map, ignore 'pixel'
 *	|M|I|0|0|0|pixel| 10	M=1 - Local color map follows, use 'pixel'
 *	+-+-+-+-+-+-----+	I=0 - Image formatted in Sequential order
 *				I=1 - Image formatted in Interlaced order
 *				pixel+1 - # bits per pixel for this image
 */

	uchar_t	data;


	/*
	 *   skip extension block
	 */
	do
	{
		data = (uchar_t) GETC (infile);

		if (ENDFILE (infile))
			return (0);
		if (data == ';')
			return (1);
		if (data == 0x21)
			skip_EB (infile);

	} while (data != 0x2c);				/* ',' is ID start */

	data       = (uchar_t) GETC (infile);		/* left coord */
	id->i_x    = data + ((uchar_t) GETC (infile) << 8);

	data       = (uchar_t) GETC (infile);		/* top coord */
	id->i_y    = data + ((uchar_t) GETC (infile) << 8);

	data       = (uchar_t) GETC (infile);		/* width */
	id->i_dx   = data + ((uchar_t) GETC (infile) << 8);

	data       = (uchar_t) GETC (infile);		/* height */
	id->i_dy   = data + ((uchar_t) GETC (infile) << 8);

	data         = (uchar_t) GETC (infile);		/* flag: */
	id->i_gcm    = (data >> 7) & 0x01;		/* local color map? */
	id->i_intlace= (data >> 6) & 0x01;		/* interlaced? */
	id->i_bits   = (data & 7) + 1;
	id->i_colors = 1 << id->i_bits;

	return (2);
}



/*------------------------------*/
/*	scan_CM			*/
/*------------------------------*/
void scan_CM (infile, colors, cm)
int		infile;
int		colors;
char	       *cm;
{

/*
 *	read a color map (optional)
 *
 *	      bits
 *	 7 6 5 4 3 2 1 0  Byte #
 *	+---------------+
 *	| red intensity |  1	Red value for color index 0
 *	+---------------+
 *	|green intensity|  2	Green value for color index 0
 *	+---------------+
 *	| blue intensity|  3	Blue value for color index 0
 *	+---------------+
 *	| red intensity |  4	Red value for color index 1
 *	+---------------+
 *	|green intensity|  5	Green value for color index 1
 *	+---------------+
 *	| blue intensity|  6	Blue value for color index 1
 *	+---------------+
 *	:		:	(Continues for remaining colors)
 *
 */

	char	       *scan;
	int		i;

	if (Verbose)
		fprintf (stderr, "\nread color map...\n");

	for (scan = cm, i = colors; i > 0; i--, scan += 3)
	{
		*scan =     (char) GETC (infile);
		*(scan+1) = (char) GETC (infile);
		*(scan+2) = (char) GETC (infile);

		if (Verbose)
		{
			fprintf (stderr, "addr:     %08lx %08lx %08lx\n",
				(long) (scan),
				(long) (scan+1),
				(long) (scan+2));
			fprintf (stderr, "vals:     %02x %02x %02x\n",
				(uint_t) (*scan),
				(uint_t) (*(scan+1)),
				(uint_t) (*(scan+2)));
		}
	}

	if (Inquire)
	{
		printf ("     Color map for %d colors:\n\n", colors);
		for (scan = cm, i = colors; i > 0; i--, scan += 3)
			printf ("     %02x %02x %02x\n",
				(uint_t) (*scan),
				(uint_t) (*(scan+1)),
				(uint_t) (*(scan+2)));
		printf ("\n");
	}
}



/*------------------------------*/
/*	scan_MAGIC		*/
/*------------------------------*/
int scan_MAGIC (infile, parse)
int	infile;
char   *parse;
{

/*
 *	read chars from file "infile" and look for string "parse" from
 *	current file position. return 0 if no match at first mismatch.
 */

	char   *scan;
	int	dx,
		dy;

	for (scan = parse; *scan; scan++)
	{
		if (GETC (infile) != (int) *scan)
			return (0);
	}
	return (!0);
}






#define SETPIXEL(x,r)	r[(x)/8] |= 1 << (7-((x)%8))
#define GETPIXEL(x,r)	r[(x)/8] & (1 << (7-((x)%8)))

/*------------------------------*/
/*	fdither			*/
/*------------------------------*/
int fdither (direction, ifac, ac0, ac1, numpix, bits, red, green, blue, row, devint, useNTSC, filter)
int		direction;	/* in:	direction of scan (LEFT or RIGHT) */
int		ifac;		/* in:	scale intensity factor (0-100) */
register long  *ac0;		/* in:	current row accumulated error */
register long  *ac1;		/* out:	next row accumulated error */
int		numpix;		/* in:	length of this row, pixels */
int		bits;		/* in:	max bits in pixel, each color*/
uint_t	       *red;		/* in:	red intensity raster */
uint_t	       *green;		/* in:	green intensity raster */
uint_t	       *blue;		/* in:	blue intensity raster */
uchar_t	       *row;		/* out:	mono raster */
long		devint;		/* in:	device intensity */
int		useNTSC;	/* in:	use NTSC lumin equation? */
int		filter;		/* in:  draw selected color planes */
{

/*
 *	floyd-steinberg dither of a raster consisting of seperate rgb tables.
 *	direction is specified as arg (LEFT or RIGHT). accumulated error
 *	arrays are the resposibility of the caller. ac0 is generally ac1 from
 *	the previous pass. output is a mono raster, row, as 1+numpix/8 chars.
 */

	register int	ix;		/* current pixel */
	register int	px;
	register long	error;
	register long	intens;
	register long	e2;
	uint_t		rpl,
			gpl,
			bpl;
	long		e1;
	long		lfac;
	long		ldv;
	int		numbytes;	/* number of bytes in raster */



	/*
	 *   set up scale factors. if factor is negative, switch numerator
	 *   and denominator (though it had better be same order of magnitude)
	 */
	if (ifac < 0)
	{
		lfac = 50;
		ldv  = (long) -ifac;
	}
	else
	{
		lfac = (long) ifac;
		ldv  = 50;
	}


	/*
	 *   clear row (make white)
	 */
	numbytes = 1 + numpix/8;
	for (ix = 0; ix < numbytes; ix++)
		row[ix] = 0;


	/*
	 *   scan alternating right (even rows) and left (odd rows)
	 */
	if (direction == LEFT)
	{
		/*
		 *   scan left...
		 *
		 *   each pixel in row...
		 */
		for (ix = numpix-1; ix >= 0; ix--)
		{
			/*
			 *   get intensities for pixel, scaled 0-100
			 *
			 *   note: the actual NTSC equation is:
			 *
			 *	lumin = 0.299 R + 0.587 G + 0.114 B
			 */
			switch (filter)
			{
			case REDPLANE:			/* red only */
				rpl = red[ix];
				gpl = 0;
				bpl = 0;
				break;
			case GREENPLANE:		/* green only */
				rpl = 0;
				gpl = green[ix];
				bpl = 0;
				break;
			case BLUEPLANE:			/* blue only */
				rpl = 0;
				gpl = 0;
				bpl = blue[ix];
				break;
			case REDPLANE | GREENPLANE:	/* red and green */
				rpl = red[ix];
				gpl = green[ix];
				bpl = 0;
				break;
			case REDPLANE | BLUEPLANE:	/* red and blue */
				rpl = red[ix];
				gpl = 0;
				bpl = blue[ix];
				break;
			case GREENPLANE | BLUEPLANE:	/* green and blue */
				rpl = 0;
				gpl = green[ix];
				bpl = blue[ix];
				break;
			default:			/* all planes */
				rpl = red[ix];
				gpl = green[ix];
				bpl = blue[ix];
				break;
			}
			if (useNTSC)
			{
				intens = ((long) ( (rpl * 30)
				       +           (gpl * 59)
				       +           (bpl * 11) ) * lfac) / (ldv * 100);
			}
			else
			{
				intens = ((long) ( rpl
				       +           gpl
				       +           bpl ) * lfac) / ldv;
			}


			/*
			 *   device intensities: 0=black, 0x777=white
			 *
			 *   this is the heart of the f-s alg: find
			 *   the value of device intesity (in this
			 *   case 0 or 777) which minimizes the error.
			 */
/*!!!			px = ix + 1;*/
			px = ix;

			e2 = intens + ac0[px];
			e1 = e2 - devint;


			/*
			 *   which err is smaller?
			 */
			if (abs (e1) < abs (e2))
			{
				/*
				 *   white. leave alone...
				 */
				error = e1;
			}
			else
			{
				/*
				 *   black. color it...
				 */
				error = e2;

				SETPIXEL (ix, row);
			}

			/*
			 *   accumulate error in neighbors...
			 *
			 *   actual F-S filter:
			 *
			 *	  px-1    px    px+1
			 *
			 *	+------+------+
			 *	| 7/16 |  XX  | <----		ac0
			 *	+------+------+------+
			 *	| 1/16 | 5/16 | 3/16 |		ac1
			 *	+------+------+------+
			 */
			ac0[px-1] += (7 * error) >> 4;	/* really div 16 */
			ac1[px+1] += (3 * error) >> 4;
			ac1[px  ] += (5 * error) >> 4;
			ac1[px-1] += (    error) >> 4;
		}
	}
	else
	{
		/*
		 *   scan right...
		 *
		 *   each pixel in row...
		 */
		for (ix = 0; ix < numpix; ix++)
		{
			switch (filter)
			{
			case REDPLANE:			/* red only */
				rpl = red[ix];
				gpl = 0;
				bpl = 0;
				break;
			case GREENPLANE:		/* green only */
				rpl = 0;
				gpl = green[ix];
				bpl = 0;
				break;
			case BLUEPLANE:			/* blue only */
				rpl = 0;
				gpl = 0;
				bpl = blue[ix];
				break;
			case REDPLANE | GREENPLANE:	/* red and green */
				rpl = red[ix];
				gpl = green[ix];
				bpl = 0;
				break;
			case REDPLANE | BLUEPLANE:	/* red and blue */
				rpl = red[ix];
				gpl = 0;
				bpl = blue[ix];
				break;
			case GREENPLANE | BLUEPLANE:	/* green and blue */
				rpl = 0;
				gpl = green[ix];
				bpl = blue[ix];
				break;
			default:			/* all planes */
				rpl = red[ix];
				gpl = green[ix];
				bpl = blue[ix];
				break;
			}
			if (useNTSC)
			{
				intens = ((long) ( (rpl * 30)
				       +           (gpl * 59)
				       +           (bpl * 11) ) * lfac) / (ldv * 100);
			}
			else
			{
				intens = ((long) ( rpl
				       +           gpl
				       +           bpl ) * lfac) / ldv;
			}

/*!!!			px = ix + 1;*/
			px = ix;

			e2 = intens + ac0[px];
			e1 = e2 - devint;

			if (abs (e1) < abs (e2))
			{
				error = e1;
			}
			else
			{
				error = e2;

				SETPIXEL (ix, row);
			}

			/*
			 *   actual F-S filter:
			 *
			 *	  px-1    px    px+1
			 *
			 *	       +------+------+
			 *	 ----> |  XX  | 7/16 |		ac0
			 *	+------+------+------+
			 *	| 3/16 | 5/16 | 1/16 |		ac1
			 *	+------+------+------+
			 */
			ac0[px+1] += (7 * error) >> 4;	/* really div 16 */
			ac1[px-1] += (3 * error) >> 4;
			ac1[px  ] += (5 * error) >> 4;
			ac1[px+1] += (    error) >> 4;
		}
	}

	return (0);
}



/*------------------------------*/
/*	draw_row		*/
/*------------------------------*/
draw_row (iy, row, numpix, reverse, mirror, rotate)
int			iy;
register uchar_t       *row;
register int		numpix;
int			reverse;
int			mirror;
int			rotate;
{

/*
 *	draw a mono raster. uses line A
 */

	extern long		linea0 ();
	extern int		linea1 ();
	extern int		linea3 ();

	static long		A_ptr = 0L;	/* to line-A struct */

	register uchar_t	xbit;
	register uchar_t	xbyte;
	register int		ix;


#ifdef USE_SETJMP
	if (check_key ())
		longjmp (JmpEnv, 1);
#else
	if (check_key ())
		exit (1);
#endif


	/*
	 *   init line A if needed...
	 */
	if (!A_ptr)
		A_ptr = linea0 ();


	/*
	 *   clean draw (no rotate, etc)
	 */
	if (!reverse && !mirror && !rotate)
	{
		for (ix = 0; ix < numpix; ix++)
		{
			/*
			 *   first get byte containing this pixel...
			 */
			xbyte = row[ix/8];

			/*
			 *   test for some special cases which should speed
			 *   up many images (those with lots of all black
			 *   or all white backgrounds). this saves about
			 *   10%. note that linea4 (hor line) is somewhat
			 *   faster still.
			 */
			if (xbyte == 0x00)	/* skip blank byte */
			{
				ix += 7;
			}
			else if (xbyte == 0xFF)	/* solid black */
			{
				linea3 (A_ptr, ix, iy, ix+7, iy, 0, 0xFFFF, 0);
				ix += 7;
			}
#if 0
			else if (xbyte == 0xF0)	/* half black */
			{
				linea3 (A_ptr, ix, iy, ix+3, iy, 0, 0xFFFF, 0);
				ix += 7;
			}
			else if (xbyte == 0x0F)	/* half black */
			{
				linea3 (A_ptr, ix+4, iy, ix+7, iy, 0, 0xFFFF, 0);
				ix += 7;
			}
#endif
			else			/* all others */
			{
				xbit  = 1 << (7-(ix%8));
				if (xbyte & xbit)
					linea1 (A_ptr, ix, iy, 1);
			}
		}	
		return;
	}


	/*
	 *   just rotate +90
	 */
	if (!reverse && !mirror && rotate == 90)
	{
		if (numpix > MAX_Y)
			numpix = MAX_Y;
		if (iy > MAX_X)
			return;
		for (ix = 0; ix < numpix; ix++)
		{
			xbyte = row[ix/8];
			if (xbyte == 0x00)	/* skip blank byte */
			{
				ix += 7;
			}
			else if (xbyte == 0xFF)	/* solid black */
			{
				linea3 (A_ptr, iy, numpix-ix-1, iy, numpix-ix+8, 0, 0xFFFF, 0);
				ix += 7;
			}
			else
			{
				xbit  = 1 << (7-(ix%8));
				if (xbyte & xbit)
					linea1 (A_ptr, iy, numpix-ix-1, 1);
			}
		}	
		return;
	}


	/*
	 *   just rotate -90
	 */
	if (!reverse && !mirror && rotate == -90)
	{
		if (numpix > MAX_Y)
			numpix = MAX_Y;
		if (iy > MAX_X)
			return;
		for (ix = 0; ix < numpix; ix++)
		{
			xbyte = row[ix/8];
			if (xbyte == 0x00)	/* skip blank byte */
			{
				ix += 7;
			}
			else if (xbyte == 0xFF)	/* solid black */
			{
				linea3 (A_ptr, MAX_X-iy-1, ix, MAX_X-iy-1, ix+7, 0, 0xFFFF, 0);
				ix += 7;
			}
			else
			{
				xbit  = 1 << (7-(ix%8));
				if (xbyte & xbit)
					linea1 (A_ptr, MAX_X-iy-1, ix, 1);
			}
		}	
		return;
	}


	/*
	 *   just reverse
	 */
	if (reverse && !mirror && !rotate)
	{
		for (ix = 0; ix < numpix; ix++)
		{
			xbyte = row[ix/8];
			if (xbyte == 0xFF)	/* skip solid byte (all white)*/
			{
				ix += 7;
			}
			else if (xbyte == 0x00)	/* all white (all black) */
			{
				linea3 (A_ptr, ix, iy, ix+7, iy, 0, 0xFFFF, 0);
				ix += 7;
			}
			else			/* all others */
			{
				xbit  = 1 << (7-(ix%8));
				if (!(xbyte & xbit))
					linea1 (A_ptr, ix, iy, 1);
			}
		}	
		return;
	}


	/*
	 *   just mirror
	 */
	if (!reverse && mirror && !rotate)
	{
		for (ix = 0; ix < numpix; ix++)
		{
			xbyte = row[ix/8];
			if (xbyte == 0x00)	/* skip blank byte */
			{
				ix += 7;
			}
			else if (xbyte == 0xFF)	/* solid black */
			{
				linea3 (A_ptr, ix, iy, ix+7, iy, 0, 0xFFFF, 0);
				ix += 7;
			}
			else
			{
				xbit  = 1 << (7-(ix%8));
				if (xbyte & xbit)
					linea1 (A_ptr, numpix-ix-1, iy, 1);
			}
		}	
		return;
	}


	/*
	 *   mirror and reverse
	 */
	if (reverse && mirror && !rotate)
	{
		for (ix = 0; ix < numpix; ix++)
		{
			xbyte = row[ix/8];
			if (xbyte == 0xFF)	/* skip solid byte */
			{
				ix += 7;
			}
			else if (xbyte == 0x00)	/* all white */
			{
				linea3 (A_ptr, ix, iy, ix+7, iy, 0, 0xFFFF, 0);
				ix += 7;
			}
			else			/* all others */
			{
				xbit  = 1 << (7-(ix%8));
				if (!(xbyte & xbit))
					linea1 (A_ptr, numpix-ix-1, iy, 1);
			}
		}	
		return;
	}


	/*
	 *   all others (slow)...
	 */
	if (rotate == 90)
	{
		if (numpix > MAX_Y)
			numpix = MAX_Y;
		if (iy > MAX_X)
			return;
		for (ix = 0; ix < numpix; ix++)
		{
			xbyte = row[ix/8];
			if (mirror)
			{
				xbit  = 1 << (7-(ix%8));
				if ( (reverse && !(xbyte & xbit))
				||   (!reverse && (xbyte & xbit)) )
					linea1 (A_ptr, iy, ix, 1);
			}
			else
			{
				xbit  = 1 << (7-(ix%8));
				if ( (reverse && !(xbyte & xbit))
				||   (!reverse && (xbyte & xbit)) )
					linea1 (A_ptr, iy, numpix-ix-1, 1);
			}
		}
	}
	else if (rotate == -90)
	{
		if (numpix > MAX_Y)
			numpix = MAX_Y;
		if (iy > MAX_X)
			return;
		for (ix = 0; ix < numpix; ix++)
		{
			xbyte = row[ix/8];
			if (mirror)
			{
				xbit  = 1 << (7-(ix%8));
				if ( (reverse && !(xbyte & xbit))
				||   (!reverse && (xbyte & xbit)) )
					linea1 (A_ptr, MAX_X-iy-1, numpix-ix-1, 1);
			}
			else
			{
				xbit  = 1 << (7-(ix%8));
				if ( (reverse && !(xbyte & xbit))
				||   (!reverse && (xbyte & xbit)) )
					linea1 (A_ptr, MAX_X-iy-1, ix, 1);
			}
		}
	}
	return;
}




/*------------------------------*/
/*	draw_hist		*/
/*------------------------------*/
int draw_hist ()
{

/*
 *	draw histogram
 */

	int	i,
		j;
	long	hmax;
	long	rhmax,
		ghmax,
		bhmax;
	int	x1,
 		x2,
 		y1,
 		y2;
 	int	hval;
	int	xmx,
		xmn;
	int	ymx,
		ymn;
	long	xsz;


	/*
	 *   find max values in histo for scaling...
	 */
	hmax  = 0;
	rhmax = 0;
	ghmax = 0;
	bhmax = 0;
	for (i = 0; i < HISTSIZ; i++)
	{
		if (Hist[i]  > hmax)		hmax  = Hist[i];
		if (rHist[i] > rhmax)		rhmax = rHist[i];
		if (gHist[i] > ghmax)		ghmax = gHist[i];
		if (bHist[i] > bhmax)		bhmax = bHist[i];
	}


	/*
	 *   overall histogram...
	 */
	x1 = 100 - 50; 	y1 = 50;
 	x2 = x1 + 200; 	y2 = y1 + 256;
	drhist (Hist, HISTSIZ, hmax, x1, y1, x2, y2, 4, 1, 1);


	/*
	 *   reset hmax so all rgb histograms are relative to each other
	 *   (hval for full can be smaller than hval for any individual one)
	 */
	if (rhmax > hmax)	hmax = rhmax;
	if (ghmax > hmax)	hmax = ghmax;
	if (bhmax > hmax)	hmax = bhmax;


	/*
	 *   red histogram...
	 */
	x1 = x1 + 208;	x2 = x1 + 100;
	drhist (rHist, HISTSIZ, hmax, x1, y1, x2, y2, 4, 1, 1);


	/*
	 *   green histogram...
	 */
	x1 = x1 + 108;	x2 = x1 + 100;
	drhist (gHist, HISTSIZ, hmax, x1, y1, x2, y2, 4, 1, 1);


	/*
	 *   blue histogram...
	 */
	x1 = x1 + 108;	x2 = x1 + 100;
	drhist (bHist, HISTSIZ, hmax, x1, y1, x2, y2, 4, 1, 1);
}



/*------------------------------*/
/*	drhist			*/
/*------------------------------*/
int drhist (hst, hstsiz, hmax, xmn, ymn, xmx, ymx, bordr, vspace, barsize)
long   *hst;
int	hstsiz;
long	hmax;
int	xmn;
int	ymn;
int	xmx;
int	ymx;
int	bordr;
int	vspace;
int	barsize;
{

/*
 *	draw a histogram, vertical axis, horizontal values. UL/LR corners
 *	specified (pixel coord). border outside the corners if bordr >= 0.
 *	vert spacing (in pixels) given by vspace. if hmax is > 0, scale
 *	the length to this value, otherwise automatically scale to fit.
 *
 *	 ____________________________________________
 *	|   /----- start here: (xmn,ymn)	     |<-- border, drawn
 *	|  +XXXXXXXXXXXXXXXXXXXXXXXXX                |    if bordr >= 0
 *	|  XXXXXXXXX                                 |
 *	|  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  |
 *	|  XXXXXXXXXXXXXXXXXXX                       |
 *	.					     .
 *	.					     .
 *	.					     .
 *	|  XXXXXXXXXXXXX                             |
 *	|  XXXXXXXXXXXXXXXXXXXXXXXXX              +  |
 *	|____________________________________________|
 *
 *	width of each bar given by barsize (in pixels). vspace should include
 *	barsize:
 *
 *	XXXXXXXXXXXXXXXXXXXXXX ------------------------------------------
 *	XXXXXXXXXXXXXXXXXXXXXX			barsize(=3)
 *	XXXXXXXXXXXXXXXXXXXXXX ----------------------------    vspace(=4)
 *	
 *	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX---------------------------------
 *	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 *	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 */

	int	i;
	int	j;
	int	x1,
 		x2,
 		y1,
 		y2;
 	int	hval;
	long	xsz;


	/*
	 *   check data...
	 */
	if (vspace < 1)
		vspace = 1;
	if ((vspace * hstsiz) > (ymx - ymn + 1))
		vspace = (ymx - ymn) / hstsiz;
	if (vspace < 1)
		return;
	if (barsize > vspace)
		barsize = vspace;


	/*
	 *   find max value if necessary...
	 */
	if (hmax < 0)
	{
		hmax = 0;
		for (i = 0; i < hstsiz; i++)
		{
			if (hst[i] > hmax)
				hmax = hst[i];
		}
	}


	/*
	 *   draw box around histogram
	 */
	if (bordr >= 0)
	{
		do_line (xmn-bordr, ymn-bordr, xmx+bordr, ymn-bordr);
		do_line (xmn-bordr, ymn-bordr, xmn-bordr, ymx+bordr);
		do_line (xmx+bordr, ymx+bordr, xmx+bordr, ymn-bordr);
		do_line (xmx+bordr, ymx+bordr, xmn-bordr, ymx+bordr);
	}


	/*
	 *   draw the lines. note that a "baseline" could appear because for
	 *   hst entries of 0, the line is just a dot so we do not draw these.
	 */
	xsz = (long) (xmx - xmn);
	for (i = 0; i < hstsiz; i++)
	{
		x1 = xmn;
		y1 = ymn + (i * vspace);
		x2 = x1 + (int) ((xsz * hst[i]) / hmax);
		y2 = y1;
		if (x2 - x1 > 0)
		{
			for (j = 0; j < barsize; j++, y1++, y2++)
				do_line (x1, y1, x2, y2);
		}
	}
}



/*------------------------------*/
/*	do_line			*/
/*------------------------------*/
do_line (x1, y1, x2, y2)
int	x1, y1, x2, y2;
{

/*
 *	draw a line from (x1,y1) to (x2,y2). uses line A
 */

	extern long	linea0 ();
	extern int	linea3 ();

	static long	A_ptr = 0L;


	/*
	 *   line A init first, if needed
	 */
	if (!A_ptr)
		A_ptr = linea0 ();

	linea3 (A_ptr, x1, y1, x2, y2, 0, 0xFFFF, 0);

}




/*------------------------------*/
/*	cursor			*/
/*------------------------------*/
cursor (visible)
int	visible;
{

/*
 *	turn cursor on/off
 */

	if (visible)
		Cconws ("\33e");
	else
		Cconws ("\33f");
}




/*------------------------------*/
/*	mv_cursor		*/
/*------------------------------*/
mv_cursor (col, row)
int	col;
int	row;
{

/*
 *	move cursor to row,col (0,0 is UL corner). for printing
 */

	int	esc = 0x1B;
	int	spc = 0x20;
	char	msg[10];

	sprintf (msg, "%cY%c%c\0", (char) esc, (char) (row + spc), (char) (col + spc));
	Cconws (msg);
}




/*------------------------------*/
/*	clr_screen		*/
/*------------------------------*/
clr_screen ()
{

/*
 *	clear screen, home cursor
 */

	Cconws ("\33E");
}




/*------------------------------*/
/*	do_time			*/
/*------------------------------*/
long do_time (opt)
int	opt;				/* 0=init,1=start,2=end (ret elapsed)*/
{

/*
 *	timing functions. here we time using 200 Hz system timer
 */

	static ulong_t	start;
	static ulong_t	stop;

	long		savessp;
	ulong_t		elapsed;		/* seconds */


	switch (opt)
	{
	case 0:						/* reset clock */
	case 1:						/* start clock */
		savessp = Super (0L);
		start   = *(long *) (0x4ba);
		Super (savessp);
		break;

	case 2:						/* stop and elapsed */
		savessp = Super (0L);
		stop    = *(long *) (0x4ba);
		Super (savessp);

		if (stop < start)
			elapsed = (long) (stop - start + 0x7FFFFFFFL) / 200L;
		else
			elapsed = (long) (stop - start) / 200L;

		return ((long) elapsed);
	}

	return (0L);

}



/*------------------------------*/
/*	write_pi3		*/
/*------------------------------*/

#define NCHUNK		400

int write_pi3 (fname)
char   *fname;
{
	register char  *pbuf;
	register char  *pscrn;
	register int	i,
			j;
	int		fd;
	int		ival;
	char		buf[NCHUNK+10];
	long		pbase;
	long		savesp;
	FILE	       *stream;


	/*
	 *   open the .pi3 file...
	 */
	if ((stream = fopenb (fname, "w")) == (FILE *) NULL)
	{
		printf ("Error openning %s.\n",
			fname);
		return (1);
	}
	fd = fileno (stream);


	/*
	 *   get current screen address (assume aligned even)...
	 */
	pbase = Physbase ();
	pscrn = (char *) pbase;


	/*
	 *   write .pi3 header...
	 */
	ival = 2;				/* resolution (2 bytes) */
	write (fd, &ival, 2);

	ival = 0x777;				/* palette (32 bytes) */
	write (fd, &ival, 2);

	ival = 0;
	for (i = 0; i < 15; i++)
		write (fd, &ival, 2);


	/*
	 *   write the screen...
	 */
	for (i = 0; i < 32000/NCHUNK; i++)	/* screen (32000 bytes) */
	{
		pbuf   = buf;
		savesp = Super (0L);
		for (j = 0; j < NCHUNK; j++)
			*pbuf++ = *pscrn++;
		Super (savesp);

		write (fd, buf, NCHUNK);
	}

	fclose (stream);

	return (0);
}



/*------------------------------*/
/*	check_key		*/
/*------------------------------*/
int check_key ()
{

/*
 *	ckecks for a key and flushes keyboard buffer.
 */

	if (Bconstat (2))			/* if CONSOLE has a char... */
	{
		while (Bconstat (2))		/* read char while there are */
			Bconin (2);		/* chars to read (flush) */

		return (1);			/* yes, there was a key */
	}

	return (0);				/* no key */
}




/*------------------------------*/
/*	wait_key		*/
/*------------------------------*/
wait_key ()
{

/*
 *	waits for a key and flushes keyboard buffer.
 */

	while (!Bconstat (2))			/* wait for a key... */
		;

	while (Bconstat (2))			/* keep reading while there */
		Bconin (2);			/* are key inputs... */
}






/*------------------------------*/
/*	GETC			*/
/*------------------------------*/
int GETC (fd)
int	fd;
{
	uchar_t		buf[10];
	int		ret;

	ret = read (fd, buf, 1);

	if (ret < 0)
		Eof = 1;

	return ((int) buf[0]);
}


