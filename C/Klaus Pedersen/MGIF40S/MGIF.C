/* this version uses flicker */

#define V_HIST			/* def for vertical histogram */
#undef DBL_LOOP			/* def for for(x..., for(y... loops */
#undef FULL_SCREEN		/* def to write entire screen, not just wxh */

/*
 *	mgif - floyd-steinberg dither (mono) a gif image (.gif)
 *
 *	gif decoder lifted from PBMplus package. flicker adopted from
 *	work by Klaus Pedersen (micro@imada.dk)
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
 *	91/2/25 1.2 rosenkra	- add -b option
 *				- -i does not print color map. use -i -i
 *	91/6/3 3.0 rosenkra	- major rewrite using "flicker"
 *				- really interactive only now
 *				- ReadGIF now single entry point
 *				- flicker is single entry point
 *				- does lots of image processing (menu)
 *				including size, blur, brighten, log scale,
 *				contrast expansion, median filter
 *	91/6/3 3.2 rosenkra	- add convolutions
 *				- release to usenet
 *	91/6/6 3.3 rosenkra	- add cut, rotate, mirror
 *				- add flicker file write (*.fl)
 *	91/6/9 3.4 rosenkra	- fix some bugs in file write, median, log
 *				scale, etc
 *				- enlarge/shrink by direction
 *				- cut can work beyond screen size
 *				- add support for .pi1 and .pi2 files
 *	91/6/13 3.5 rosenkra	- point coord selection by crosshairs
 *				- add zoom (2x)
 *				- add histogram on screen in flicker screen
 *				- add copy orig<-->new
 *
 ****
 ****	Development continued by Johan Klockars (d8klojo@dtek.chalmers.se)
 ****
 *	92/11/09 4.0 Klockars	- support for GCC, Lattice C and Turbo C added
 *				- changed to dynamic memory allocation
 *				- less memory used now
 *				- fixed and enhanced clipping
 *				- improved speed in cmaptoint
 *				- file loading speeded up (especially floppy)
 */

static char *sccsid  = "@(#) mgif.c 4.0 rosenkra(3.5)  92/11/09 Klockars\0\0";
char        *myname  = "mgif\0\0\0\0\0\0";
char        *version = "mgif 4.0  91/6/18 rosenkra   92/11/09 Klockars\0\0\0";


/* #include <stdio.h>	Included via proto.h */
#include <stdlib.h>
#include <osbind.h>
#include <string.h>
/* #include "mgif.h"	Included via proto.h */

#ifndef __LATTICE__
#include "proto.h"	/* Lattice C should have this precompiled */
#endif

#define SCRNSPACE	48256L	/* buffer size for 3 screens (words) */
				/* leave extra to word-align */


/*
 *	globals:
 */

uchar_t		ColMap[MAPSIZ][3];/* color map we use (global or local)*/
screen_t	ScrnInf;	/* global screen descriptor */
image_t		Id;		/* image id struct */

/* NEW, changed to make dynamic memory possible */
long			MAXRAW, MAXIMG;
uchar_t		*Raster;	/* final raster image, ColMap indx */
uchar_t		*TransRast;/* transformed raster image */

int		Height,		/* image size */
		Width;
int		NewHeight,	/* transformed image size */
		NewWidth;

int		ShowFl = 0;
int		montage = 0;
int		Pi1 = 0;	/* use this on degas files also */
int		Pi2 = 0;
int		Batch = 0;
int		Noise = 0;	/* percentage of random noise */
int		Beta = 0;	/* beta factor for Laplace filter */
int		Verbose = 0;	/* this is VERY verbose... */
int		Inquire = 0;	/* inquire or render */
int		Quantize = 0;	/* quantize to 16 shades */
int		UseNTSC = 0;	/* NTSC equation for lumin */
long		Hist[HISTSIZ];	/* histogram */
int		XUpperLeft = 0,	/* starting pixel (default is 0,0) */
		YUpperLeft = 0;
int	       *PScreens;	/* what flicker returns. ptr to 3 screens */

/*
 *	local functions
 */

/*
int		usage ();
int		draw_image ();
int		cmaptoint ();
int		showfl ();
void		title ();
void		conv_menu ();
void		do_help ();
*/


/*------------------------------*/
/*	main			*/
/*------------------------------*/
main (argc, argv)
int	argc;
char   *argv[];
{
	long		elapsed;		/* elapsed seconds */
	int		gif_fd;		/* file descriptor */
	char		*ps;
	char		*fname;
	int		ret;
	register	long	ii;
	register	int   *pscrn;
	int		count;
	int		*scrn;		/* -> first screen for -fl */


#ifdef __GNUC__	
	setbuf(stdout, NULL);	/* GCC buffers screen output otherwise */
#endif

	/* NEW, dynamic memory allocation */

	MAXIMG = MAXRAW = ((long)Malloc(-1L) - 32768) / 2;
	if (MAXIMG > 0x100000)
		MAXIMG = MAXRAW = 0x100000;	/* We don't need >1Mb, do we? */
	Raster = (uchar_t *)malloc(MAXIMG);
	TransRast = (uchar_t *)malloc(MAXIMG);

	
	/*
	 *   set defaults...
	 */
	Batch = 0;



	/*
	 *   parse args...
	 */
	for (argc--, argv++; (argc && **argv == '-'); argc--, argv++)
	{
		switch (*(*argv+1))
		{
		case 'f':		/* just show flicker files */
			if (!strncmp (*argv, "-fl", 3))
				ShowFl++;
			else
				usage (1);
			break;

		case 'm':		/* with -fl, do montage */
			montage++;
			break;

		case 'p':
			if (!strncmp (*argv, "-pi1", 4))
				Pi1++;
			else if (!strncmp (*argv, "-pi2", 4))
				Pi2++;
			else
				usage (1);
			break;

		case 'b':		/* batch mode (no questions)*/
			Batch = 1;	/* NOT IMPLEMENTED!!! */
			break;

		case 'N':		/* NTSC lum equation */
			UseNTSC = 1;
			break;

		case 'i':		/* inquire only */
			Inquire++;
			break;

		case 'v':		/* version/verbose output */
			if (!strncmp (*argv, "-vers", 5))
			{
				printf ("%s\n", version);
				exit (0);
			}
			Verbose++;
			break;

		case 'h':		/* help */
			if (!strncmp (*argv, "-help", 5))
			{
				usage (0);
			}
			break;

		default:
			usage (1);
			break;
		}
	}



	/*
	 *   make sure we have at least one file...
	 */
	if (argc < 1)
		usage (1);



	/*
	 *   just show flicker files and exit...
	 */
	if (ShowFl)
	{
		/*
		 *   align to page boundary. use Raster as our screen buf
		 */
		scrn = (int *) (((long) Raster + 256L) & 0xFFFFFF00L);


		if (montage)
		{
			/*
			 *   for either 2 320x400, 4 320x200 images or
			 *   6 200x200 images. first read them. note
			 *   changing ptr into screen buffers...
			 */
			pscrn = scrn;
			count = 0;
			while (argc--)
			{
				/*
				 *   read a file
				 */
				printf ("Reading file: %s\n", *argv);
				if (!read_fl (*argv, pscrn, &Width, &Height))
				{
					fprintf (stderr, "%s: read_fl failed for %s\n", myname, *argv);
					exit (1);
				}


				/*
				 *   based on screen size of this image,
				 *   change pointer to screen, get ready
				 *   to read the next...
				 */
				count++;
				argv++;
				if ((Width <= 320) && (Width > 200)
				&& (Height <= 400) && (Height > 200))
				{
					/*
					 *   2 320x400 images...
					 */
					if (count == 1)
						pscrn = (int *) ((long) scrn + 40L);
					else
						break;
				}
				else if ((Width <= 320) && (Width > 200)
				&& (Height <= 200))
				{
					/*
					 *   4 320x200 images...
					 */
					if (count == 1)
						pscrn = (int *) ((long) scrn + 40L);
					else if (count == 2)
						pscrn = (int *) ((long) scrn + 16000L);
					else if (count == 3)
						pscrn = (int *) ((long) scrn + 16040L);
					else
						break;
				}
				else if ((Width <= 200) && (Height <= 200))
				{
					/*
					 *   6 200x200 images...
					 */
					if (count == 1)
						pscrn = (int *) ((long) scrn + 25L);
					else if (count == 2)
						pscrn = (int *) ((long) scrn + 50L);
					else if (count == 3)
						pscrn = (int *) ((long) scrn + 16000L);
					else if (count == 4)
						pscrn = (int *) ((long) scrn + 16025L);
					else if (count == 5)
						pscrn = (int *) ((long) scrn + 16050L);
					else
						break;
				}
				else
					/*
					 *   just display this one
					 */
					break;
			}


			/*
			 *   show them all...
			 */
			showfl (scrn);
		}
		else
		{
			/*
			 *   loop on files
			 */
			while (argc--)
			{
				/*
				 *   read file. if ok, display...
				 */
				printf ("Reading file: %s\n", *argv);
				if (read_fl (*argv, scrn, &Width, &Height))
					showfl (scrn);
				else
				{
					fprintf (stderr, "%s: read_fl failed for %s\n", myname, *argv);
					exit (1);
				}


				/*
				 *   clear screen buffer for next image if there
				 *   is one...
				 */
				if (argc)
				{
					pscrn = scrn;
					for (ii = 0L; ii < SCRNSPACE; ii++)
						*pscrn++ = 0;
					argv++;
				}
			}
		}

		exit (0);
	}



	/*
	 *   instructions (col, row)...
	 */
	do_time (0);
	if (!Inquire)
	{
		/*
		 *   initialize things (clear screen, turn off cursor, init
		 *   timing)
		 */
		title (Batch);
	}



	/*
	 *   loop on remaining files...
	 */
	while (argc--)
	{
		/*
		 *   fresh screen...
		 */
		if (!Inquire)
			clr_screen ();


		/*
		 *   get file to open
		 */
		fname = *argv++;


		/*
		 *   read image
		 */
		if (Pi1)
		{
			/*
			 *   read PI1
			 */
			do_time (1);
			if (Verbose)
				ret = ReadPI1 (fname, Raster, ColMap, VERBOSE);
			else if (Inquire)
				ret = ReadPI1 (fname, Raster, ColMap, INQUIRE);
			else
				ret = ReadPI1 (fname, Raster, ColMap, NORMAL);
			elapsed = do_time (2);

			Width  = 320;
			Height = 200;
		}
		else if (Pi2)
		{
			/*
			 *   read PI2. Will need to be resized after this
			 *   for correct aspect ration (either shrink horiz
			 *   or enlarge vert, but let user decide...)
			 */
#if 0
			fprintf (stderr, "%s: can't do PI2 files (yet)\n", myname);
			goto next;
#endif
			printf ("\nAfter PI2 is read, you will have to shrink horiz or expand vert...\n\n");
			do_time (1);
			if (Verbose)
				ret = ReadPI2 (fname, Raster, ColMap, VERBOSE);
			else if (Inquire)
				ret = ReadPI2 (fname, Raster, ColMap, INQUIRE);
			else
				ret = ReadPI2 (fname, Raster, ColMap, NORMAL);
			elapsed = do_time (2);

			Width  = 640;
			Height = 200;
		}
		else
		{
			/*
			 *   read GIF (this assumes only 1 image per file, a
			 *   reasonable assumption)...
			 */
			do_time (1);
			if (Verbose)		/* NEW, changed CodedGIF to TransRast */
				ret = ReadGIF (fname, TransRast, Raster, &ScrnInf, &Id, ColMap, VERBOSE);
			else if (Inquire)
				ret = ReadGIF (fname, TransRast, Raster, &ScrnInf, &Id, ColMap, INQUIRE);
			else		/* NEW, changed from NORMAL to SILENT below */
				ret = ReadGIF (fname, TransRast, Raster, &ScrnInf, &Id, ColMap, SILENT);
			elapsed = do_time (2);

			Width  = Id.i_dx;
			Height = Id.i_dy;
		}


		/*
		 *   draw if read was ok, else error and go to next file
		 */
		switch (ret)
		{
		case EGIFOK:
			printf ("\nElapsed time: %4ld sec\n", elapsed);

			if (!Inquire)
				draw_image (fname);
			break;

		case EGIFFILE:
			fprintf (stderr, "%s: could not open %s\n", myname, fname);
			goto next;

		case EGIFMAGIC:
			if (Pi1)
				fprintf (stderr, "%s: %s not a PI1 file\n", myname, fname);
			else
				fprintf (stderr, "%s: %s not a GIF87a file\n", myname, fname);
			goto next;

		case EGIFSDESC:
			fprintf (stderr,
				"%s: file %s data format error in screen descriptor\n",
				myname, fname);
			goto next;

		case EGIFEOF:
			fprintf (stderr, "%s: unexpected EOF\n", myname);
			goto next;

		case EGIFIDBAD:
			fprintf (stderr, "%s: bad image ID\n", myname);
			goto next;

		case EGIFBIG:
			fprintf (stderr, "this GIF too large for memory\n\n");
			goto next;

		case EGIFRAST:
			fprintf (stderr, "%s: error reading raster image\n", myname);
			goto next;
		}

next:
	;	/* NEW,  bug fix */
	}


	/*
	 *   clean up and exit
	 */
	cursor (1);

	exit (0);
}




/*------------------------------*/
/*	usage			*/
/*------------------------------*/
usage (excode)
int	excode;
{

	fprintf (stderr, "%s -fl [-m] file.fl ...\n", myname);
	fprintf (stderr, "-m       montage of flicker files\n");
	fprintf (stderr, "file.fl  a .fl flicker file\n");

	fprintf (stderr, "\nor:\n\n");

	fprintf (stderr, "%s [-i] [-v] [-N] [-pi1] [-pi2] file ...\n", myname);
	fprintf (stderr, "-i       inquire about image only\n");
	fprintf (stderr, "-v       verbose\n");
/*	fprintf (stderr, "-b       batch mode (no questions asked)\n");*/
	fprintf (stderr, "-N       use NTSC equation for luminescence\n");
	fprintf (stderr, "-pi1     read Degas .pi1 file instead \n");
	fprintf (stderr, "-pi2     read Degas .pi2 file instead \n");
	fprintf (stderr, "file     a .gif (or .pi1 or .pi2) file\n");
	fprintf (stderr, "\n");
	fprintf (stderr, "If more than one file, all share command switch settings.\n");
	fprintf (stderr, "Note that flicker file format is still subject to change.\n");
	fprintf (stderr, "All flicker files created now, however, will be ok for the future.\n");

	cursor (1);
	exit (excode);
}

/* void info();	 NEW, used here but defined later */


/*------------------------------*/
/*	draw_image		*/
/*------------------------------*/
int draw_image (fname)
char   *fname;
{
	int		i;
	int		key;
	int		orig;
	int		ret;
	char		buf[256];
	long		ii;
	int		lo, hi;
	int		brite;
	int		thresh;
	long		cthresh;
	int		conv;
	int		convkern[20];
	int		x1, y1, x2, y2;
	int		xstart, ystart;
	int		angle;
	int		opt;
	char	       *flname;
	long		elapsed;	/* elapsed seconds */



	/*
	 *   convert to grayscale
	 */
	printf ("\nConvert to grayscale\n");
	do_time (1);
	cmaptoint (Raster, Width, Height, ColMap, UseNTSC);
	elapsed = do_time (2);
	printf ("\nElapsed time: %4ld sec\n", elapsed);


	/*
	 *   copy image to transform array
	 */
	do_time (1);
	printf ("\nCopy to transform array\n");
	copyrast (Raster, Width, Height, TransRast);
	elapsed = do_time (2);
	printf ("\nElapsed time: %4ld sec\n", elapsed);


	/*
	 *   display flicker image. flicker returns after 2 keys. flicker
	 *   returns ptr to the 3 screens, page aligned, as (int *). this
	 *   address should not change so we only need assign PScreens once.
	 */
	clr_screen ();
	PScreens = flicker (Raster, Width, Height, Beta, Noise, 1);


	/*
	 *   look for commands. redisplay image as required from TransRast.
	 *   orig set 0 so successive transforms will be on new image. 'o'
	 *   option toggles this so each transform will be done on orig image.
	 */
	orig      = 0;
	NewWidth  = Width;
	NewHeight = Height;
	while (1)
	{
		/*
		 *   get a command. they can be:
		 *
		 *   commands
		 *	?	help
		 *	q	quit (next image)
		 *	ESC	exit program now
		 *	space   draw image
		 *	hi	histogram
		 *	o	original image (otherwise transform new)
		 *	f	file operations
		 *	cp	copy new <-> orig
		 *   options
		 *	n	noise
		 *	g	Laplace filter (need beta)
		 *   frame processes
		 *	e	enlarge
		 *	s	shrink
		 *	cu	cut
		 *	r	rotate
		 *	mi	mirror
		 *   point processes
		 *	he	histogram equalization
		 *	i	inverse (negation)
		 *	l	log scaling
		 *	t	threshold (black/white)
		 *	co	contrast expansion (need new range)
		 *	br	brighten
		 *   area processes
		 *	bl	blur (3x3)
		 *	me	median filter (3x3)
		 *	v	convolution (3x3)
		 */
		clr_cmd ();		mv_cursor (0, 24);
		/*printf (" Command, new(?,q,ESC,SPC,hi,o,f,cp,n,g,e,s,cu,r,mi,he,i,l,t,co,br,bl,me,v): ");*/
		if (orig)
			printf (" Command for original image (use ? for help): ");
		else
			printf (" Command for new image (use ? for help): ");
		key = get_key ();
		if ((key > 31) && (key < 128))
			printf ("%c", (char) key);

		switch (key)
		{
		case '?':			/* help */
			do_help ();
			break;

		case 0x1b:			/* ESC, exit program */
			clr_cmd ();
			mv_cursor (0, 24);
			printf (" Are you sure you want to exit? (y/n): ");
			key = get_key ();
			printf ("%c", (char) key);
			if ((key == 'y') || (key == 'Y'))
			{
				printf ("\n Program exit\n");
				cursor (1);
				exit (0);
			}
			break;

		case 'Q':			/* quit (next image) */
		case 'q':
			goto endloop;
			break;

		case 'W':			/* what */
		case 'w':
			info (fname);
			break;

		case 'F':			/* file operations */
		case 'f':
			/*
			 *   write a .fl file
			 */
			clr_cmd ();
			mv_cursor (0, 24);
			printf (" Filename to write (*.FL): ");
			get_string (83, buf);
			flname = (char *) buf;

			clr_cmd ();
			mv_cursor (0, 24);
			printf (" Write file %s now...", flname);
			if (PScreens)
			{
				if (orig)
				{
					if (write_fl (flname, PScreens, Width, Height))
					{
						mv_cursor (0, 24);
						printf (" Wrote .FL file %s (%dx%d). Any key...", flname, Width, Height);
						wait_key ();
					}
					else
					{
						mv_cursor (0, 24);
						printf (" Error writing .FL file %s. Any key...", flname);
						wait_key ();
					}
				}
				else
				{
					if (write_fl (flname, PScreens, NewWidth, NewHeight))
					{
						mv_cursor (0, 24);
						printf (" Wrote .FL file %s (%dx%d). Any key...", flname, NewWidth, NewHeight);
						wait_key ();
					}
					else
					{
						mv_cursor (0, 24);
						printf (" Error writing .FL file %s. Any key...", flname);
						wait_key ();
					}
				}
			}
			else
			{
				mv_cursor (0, 24);
				printf (" PScreens NULL! Any key...");
				wait_key ();
			}
			break;

		case 'H':			/* histogram */
		case 'h':
			key = get_key ();
			printf ("%c", (char) key);
			switch (key)
			{
			case 'I':		/* histogram */
			case 'i':
				clr_cmd ();
				mv_cursor (0, 24);  printf (" Generating histogram...");
				if (orig)
				{
					if (do_hist (Raster, Width, Height, Hist))
					{
						clr_screen ();
						draw_hist (Hist);
					}
					else
					{
						clr_cmd ();
						mv_cursor (0, 24);  printf (" Histogram failed. Enter any key... ");
						wait_key ();
					}
				}
				else
				{
					if (do_hist (TransRast, NewWidth, NewHeight, Hist))
					{
						clr_screen ();
						draw_hist (Hist);
					}
					else
					{
						clr_cmd ();
						mv_cursor (0, 24);  printf (" Histogram failed. Enter any key... ");
						wait_key ();
					}
				}
				break;

			case 'E':		/* hist equal */
			case 'e':
				clr_cmd ();
				mv_cursor (0, 24);  printf (" Histogram equalization now...");
				if (orig)
				{
					if (histeq (Raster, Width, Height, Hist, TransRast))
					{
						clr_screen ();
						flicker (TransRast, Width, Height, Beta, Noise, 1);
					}
					else
					{
						clr_cmd ();
						mv_cursor (0, 24);  printf (" Histogram equalization failed. Enter any key... ");
						wait_key ();
					}
				}
				else
				{
					if (histeq (TransRast, NewWidth, NewHeight, Hist, TransRast))
					{
						clr_screen ();
						flicker (TransRast, NewWidth, NewHeight, Beta, Noise, 1);
					}
					else
					{
						clr_cmd ();
						mv_cursor (0, 24);  printf (" Histogram equalization failed. Enter any key... ");
						wait_key ();
					}
				}
				break;

			default:
				clr_cmd ();
				mv_cursor (0, 24);
				printf (" Unknown command. Type ? for help. Enter any key... ");
				wait_key ();
				break;
			}
			break;

		case 'Z':			/* zoom (2x) */
		case 'z':
			clr_screen ();
			if (orig)
			{
				clr_screen ();
				flicker (Raster, Width, Height, Beta, Noise, 0);
				grid (0, 0, Width, Height, 20);
			}
			else
			{
				clr_screen ();
				flicker (TransRast, NewWidth, NewHeight, Beta, Noise, 0);
				grid (0, 0, NewWidth, NewHeight, 20);
			}

			/*
			 *   get zoom rectangle. it is currently ALWAYS
			 *   half the width and height of the current image.
			 *   the resulting zoom will ALWAYS be the same
			 *   size as the original image (well ALMOST, since
			 *   odd dims rounded down first)...
			 */
			if (orig)
			{
				xstart = Width/4;
				if ((xstart % 20) == 0)
					xstart -= 2;
				ystart = Height/4;
				if ((ystart % 20) == 0)
					ystart -= 2;

ret = get_xypos (VH_COORD, 1, 0, 0, Width, Height, Width/2, Height/2, xstart, ystart, &x1, &y1);

				if (ret == 0)
				{
					clr_cmd ();
					mv_cursor (0, 24);
					printf (" Canceled or failed. Any key... ");
					wait_key ();
					break;
				}
			}
			else
			{
				xstart = NewWidth/4;
				if ((xstart % 20) == 0)
					xstart -= 2;
				ystart = NewHeight/4;
				if ((ystart % 20) == 0)
					ystart -= 2;

ret = get_xypos (VH_COORD, 1, 0, 0, NewWidth, NewHeight, NewWidth/2, NewHeight/2, xstart, ystart, &x1, &y1);

				if (ret == 0)
				{
					clr_cmd ();
					mv_cursor (0, 24);
					printf (" Canceled or failed. Any key... ");
					wait_key ();
					break;
				}
			}

			clr_cmd ();
			mv_cursor (0, 24);
			printf (" Zooming image now (%d,%d)...", x1,y1);

			if (orig)
				ret = zoom (Raster, Width, Height, x1, y1, TransRast);
			else
				ret = zoom (TransRast, NewWidth, NewHeight, x1, y1, TransRast);

			/*
			 *   if zoom was successful, show the new image.
			 */
			if (ret)
			{
				if (orig)
				{
					/* order of * and / IS important! */
					NewWidth  = 2 * (Width / 2);
					NewHeight = 2 * (Height / 2);
				}
				else
				{
					NewWidth  = 2 * (NewWidth / 2);
					NewHeight = 2 * (NewHeight / 2);
				}

				clr_screen ();
				flicker (TransRast, NewWidth, NewHeight, Beta, Noise, 1);
			}
			else
			{
				clr_cmd ();
				mv_cursor (0, 24);  printf (" Zoom failed. Enter any key... ");
				wait_key ();
			}

			break;

		case 'E':			/* enlarge (2x) */
		case 'e':
e_again:
			clr_cmd ();
			mv_cursor (0, 24);
			printf (" Enlarge dimension (0=both,1=horizontal,2=vertical): ");
			get_string (32, buf);
			opt = atoi (buf);
			if ((opt < 0) || (opt > 2))
				goto e_again;

			clr_cmd ();
			mv_cursor (0, 24);  printf (" Enlarging image now...");
			if (orig)
				ret = larger (Raster, Width, Height, opt, TransRast);
			else
				ret = larger (TransRast, NewWidth, NewHeight, opt, TransRast);

			if (ret)
			{
				if (orig)
				{
					switch (opt)
					{
					case 0:			/* both */
						NewWidth  = 2 * Width;
						NewHeight = 2 * Height;
						break;
					case 1:			/* horiz */
						NewWidth  = 2 * Width;
						NewHeight = Height;
						break;
					case 2:			/* vert */
						NewWidth  = Width;
						NewHeight = 2 * Height;
						break;
					}
				}
				else
				{
					switch (opt)
					{
					case 0:
						NewWidth  = 2 * NewWidth;
						NewHeight = 2 * NewHeight;
						break;
					case 1:
						NewWidth  = 2 * NewWidth;
						NewHeight = NewHeight;
						break;
					case 2:
						NewWidth  = NewWidth;
						NewHeight = 2 * NewHeight;
						break;
					}
				}

				clr_screen ();
				flicker (TransRast, NewWidth, NewHeight, Beta, Noise, 1);
			}
			else
			{
				clr_cmd ();
				mv_cursor (0, 24);  printf (" Enlarged image too large. Enter any key... ");
				wait_key ();
			}
			break;

		case 'S':			/* shrink (.5x) */
		case 's':
s_again:
			clr_cmd ();
			mv_cursor (0, 24);
			printf (" Shrink dimension (0=both,1=horizontal,2=vertical): ");
			get_string (32, buf);
			opt = atoi (buf);
			if ((opt < 0) || (opt > 2))
				goto s_again;

			clr_cmd ();
			mv_cursor (0, 24);  printf (" Reducing image now...");
			if (orig)
				ret = smaller (Raster, Width, Height, opt, TransRast);
			else
				ret = smaller (TransRast, NewWidth, NewHeight, opt, TransRast);

			if (ret)
			{
				if (orig)
				{
					switch (opt)
					{
					case 0:			/* both */
						NewWidth  = Width / 2;
						NewHeight = Height / 2;
						break;
					case 1:			/* horiz */
						NewWidth  = Width / 2;
						NewHeight = Height;
						break;
					case 2:			/* vert */
						NewWidth  = Width;
						NewHeight = Height / 2;
						break;
					}
				}
				else
				{
					switch (opt)
					{
					case 0:
						NewWidth  = NewWidth / 2;
						NewHeight = NewHeight / 2;
						break;
					case 1:
						NewWidth  = NewWidth / 2;
						NewHeight = NewHeight;
						break;
					case 2:
						NewWidth  = NewWidth;
						NewHeight = NewHeight / 2;
						break;
					}
				}

				clr_screen ();
				flicker (TransRast, NewWidth, NewHeight, Beta, Noise, 1);
			}
			else
			{
				clr_cmd ();
				mv_cursor (0, 24);  printf (" Reduced image too small. Enter any key... ");
				wait_key ();
			}
			break;

		case 'R':			/* rotate */
		case 'r':
			if (!orig)
			{
				clr_cmd ();
				mv_cursor (0, 24);
				printf (" Can only rotate original image Any new image will be lost. Proceed (y/n)? ");
				key = get_key ();
				printf ("%c", (char) key);
				if ((key != 'y') && (key != 'Y'))
					break;
			}

			clr_cmd ();
			mv_cursor (0, 24);
			printf (" Enter angle (90=CCW,-90=CW,180): ");
			get_string (32, buf);
			angle = atoi (buf);

			if ((angle != 90) && (angle != -90)
			&&  (angle != 180) && (angle != -180))
			{
				clr_cmd ();
				mv_cursor (0, 24);
				printf (" Sorry. Bad or unsupported angle. Enter any key... ");
				wait_key ();
				break;
			}

			clr_cmd ();
			mv_cursor (0, 24);
			printf (" Forcing orig mode. After rotate, force new mode. Rotate image now...");
			if (rotate (Raster, Width, Height, angle, TransRast))
			{
				if ((angle == 90) || (angle == -90))
				{
					NewWidth  = Height;
					NewHeight = Width;
				}
				else if ((angle == 180) || (angle == -180))
				{
					NewWidth  = Width;
					NewHeight = Height;
				}
				else
				{
					clr_cmd ();
					mv_cursor (0, 24);
					printf (" Sorry. Bad or unsupported angle. Enter any key... ");
					wait_key ();
					break;
				}

				clr_cmd ();
				mv_cursor (0, 24);
				printf ("Copy to new to orig image...");
				copyrast (TransRast, NewWidth, NewHeight, Raster);
				Width  = NewWidth;
				Height = NewHeight;

				clr_screen ();
				flicker (TransRast, NewWidth, NewHeight, Beta, Noise, 1);

				orig = 0;
			}
			else
			{
				clr_cmd ();
				mv_cursor (0, 24);
				printf (" Rotation failed. Could be bad angle. Mode unchanged. Enter any key... ");
				wait_key ();
			}
			break;

		case 'T':			/* threshold */
		case 't':
			clr_cmd ();
			mv_cursor (0, 24);  printf (" Enter threshold (0 to 255): ");
			get_string (32, buf);
			thresh = atoi (buf);

			clr_cmd ();
			mv_cursor (0, 24);  printf (" Thresholding image now...");
			if (orig)
			{
				if (threshold (Raster, Width, Height, thresh, TransRast))
				{
					clr_screen ();
					flicker (TransRast, Width, Height, Beta, Noise, 1);
				}
				else
				{
					clr_cmd ();
					mv_cursor (0, 24);  printf (" Threshold failed. Enter any key... ");
					wait_key ();
				}
			}
			else
			{
				if (threshold (TransRast, NewWidth, NewHeight, thresh, TransRast))
				{
					clr_screen ();
					flicker (TransRast, NewWidth, NewHeight, Beta, Noise, 1);
				}
				else
				{
					clr_cmd ();
					mv_cursor (0, 24);  printf (" Threshold failed. Enter any key... ");
					wait_key ();
				}
			}
			break;

		case 'I':			/* inverse (negation) */
		case 'i':
			clr_cmd ();
			mv_cursor (0, 24);  printf (" Enter threshold (0 to 255): ");
			get_string (32, buf);
			thresh = atoi (buf);

			clr_cmd ();
			mv_cursor (0, 24);  printf (" Invert (negate) image now...");
			if (orig)
			{
				if (invert (Raster, Width, Height, thresh, TransRast))
				{
					clr_screen ();
					flicker (TransRast, Width, Height, Beta, Noise, 1);
				}
				else
				{
					clr_cmd ();
					mv_cursor (0, 24);  printf (" Inversion failed. Enter any key... ");
					wait_key ();
				}
			}
			else
			{
				if (invert (TransRast, NewWidth, NewHeight, thresh, TransRast))
				{
					clr_screen ();
					flicker (TransRast, NewWidth, NewHeight, Beta, Noise, 1);
				}
				else
				{
					clr_cmd ();
					mv_cursor (0, 24);  printf (" Inversion failed. Enter any key... ");
					wait_key ();
				}
			}
			break;
		
		case 'L':			/* log scaling */
		case 'l':
			clr_cmd ();
			mv_cursor (0, 24);  printf (" Log scaling image now...");
			if (orig)
			{
				if (logscale (Raster, Width, Height, TransRast))
				{
					clr_screen ();
					flicker (TransRast, Width, Height, Beta, Noise, 1);
				}
				else
				{
					clr_cmd ();
					mv_cursor (0, 24);  printf (" Log scaling failed. Enter any key... ");
					wait_key ();
				}
			}
			else
			{
				if (logscale (TransRast, NewWidth, NewHeight, TransRast))
				{
					clr_screen ();
					flicker (TransRast, NewWidth, NewHeight, Beta, Noise, 1);
				}
				else
				{
					clr_cmd ();
					mv_cursor (0, 24);  printf (" Log scaling failed. Enter any key... ");
					wait_key ();
				}
			}
			break;

		case 'C':			/* cut/contrast expansion */
		case 'c':
			key = get_key ();
			printf ("%c", (char) key);
			switch (key)
			{
			case 'P':		/* copy */
			case 'p':
				clr_cmd ();
				mv_cursor (0, 24);  printf ("Enter copy direction (0=orig->new, 1=new->orig): ");
				get_string (32, buf);
				opt = atoi (buf);

				switch (opt)
				{
				case 0:			/* orig->new */
					clr_cmd ();
					mv_cursor (0, 24);
					printf ("Copy to orig to new image...");

					copyrast (Raster, Width, Height, TransRast);

					NewWidth  = Width;
					NewHeight = Height;
					break;
				case 1:			/* new->orig */
					clr_cmd ();
					mv_cursor (0, 24);
					printf ("Copy to new to orig image...");

					copyrast (TransRast, NewWidth, NewHeight, Raster);

					Width  = NewWidth;
					Height = NewHeight;
					break;
				default:
					clr_cmd ();
					mv_cursor (0, 24);  printf (" Copy failed. Enter any key... ");
					wait_key ();
					break;
				}

				break;

			case 'U':		/* cut */
			case 'u':
				clr_screen ();
				if (orig)
				{
					clr_screen ();
					flicker (Raster, Width, Height, Beta, Noise, 0);
					grid (0, 0, Width, Height, 20);
				}
				else
				{
					clr_screen ();
					flicker (TransRast, NewWidth, NewHeight, Beta, Noise, 0);
					grid (0, 0, NewWidth, NewHeight, 20);
				}

#if 0
				clr_cmd ();
				mv_cursor (0, 24);
				printf (" Enter x1 (upper left coord, 0-%d): ",
					(orig ? Width-1 : NewWidth-1));
				get_string (32, buf);
				x1 = atoi (buf);

				clr_cmd ();
				mv_cursor (0, 24);
				printf (" Enter y1 (upper left coord, 0-%d): ",
					(orig ? Height-1 : NewHeight-1));
				get_string (32, buf);
				y1 = atoi (buf);

				clr_cmd ();
				mv_cursor (0, 24);
				printf (" Enter x2 (lower right coord, %d-%d): ",
					x1+1,
					(orig ? Width-1 : NewWidth-1));
				get_string (32, buf);
				x2 = atoi (buf);

				clr_cmd ();
				mv_cursor (0, 24);
				printf (" Enter y2 (lower right coord, %d-%d): ",
					y1+1,
					(orig ? Height-1 : NewHeight-1));
				get_string (32, buf);
				y2 = atoi (buf);
#endif
				if (orig)
				{
					xstart = Width/2;
					if ((xstart % 20) == 0)
						xstart -= 5;
					ystart = Height/2;
					if ((ystart % 20) == 0)
						ystart -= 5;

ret = get_xypos (VH_COORD, 0, 0, 0, Width, Height, 0, 0, xstart, ystart, &x1, &y1);

					if (ret == 0)
					{
						clr_cmd ();
						mv_cursor (0, 24);
						printf (" Canceled or failed. Any key... ");
						wait_key ();
						break;
					}

					xstart = x1+1+(Width-x1-1)/2;
					if ((xstart % 20) == 0)
						xstart += 1;
					ystart = y1+1+(Height-y1-1)/2;	/* NEW, was xstart! */
					if ((ystart % 20) == 0)
						ystart += 1;

ret = get_xypos (VH_COORD, 0, x1+1, y1+1, Width-x1-1, Height-y1-1, 0, 0, xstart, ystart, &x2, &y2);

					if (ret == 0)
					{
						clr_cmd ();
						mv_cursor (0, 24);
						printf (" Canceled or failed. Any key... ");
						wait_key ();
						break;
					}
					if (y2 == 399)				/* NEW, clip at bottom of */
						y2 = Height - 1;		/* picture, not just the screen */
				}
				else
				{
					xstart = NewWidth/2;
					if ((xstart % 20) == 0)
						xstart -= 5;
					ystart = NewHeight/2;
					if ((ystart % 20) == 0)
						ystart -= 5;

ret = get_xypos (VH_COORD, 0, 0, 0, NewWidth, NewHeight, 0, 0, xstart, ystart, &x1, &y1);

					if (ret == 0)
					{
						clr_cmd ();
						mv_cursor (0, 24);
						printf (" Canceled or failed. Any key... ");
						wait_key ();
						break;
					}

					xstart = x1+1+(NewWidth-x1-1)/2;
					if ((xstart % 20) == 0)
						xstart += 1;
					ystart = y1+1+(NewHeight-y1-1)/2;	/* NEW, was xstart! */
					if ((ystart % 20) == 0)
						ystart += 1;

ret = get_xypos (VH_COORD, 0, x1+1, y1+1, NewWidth-x1-1, NewHeight-y1-1, 0, 0, xstart, ystart, &x2, &y2);

					if (ret == 0)
					{
						clr_cmd ();
						mv_cursor (0, 24);
						printf (" Canceled or failed. Any key... ");
						wait_key ();
						break;
					}
					if (y2 == 399)			/* NEW, clip at bottom of */
						y2 = NewHeight - 1;	/* picture, not just the screen */
					
				}



				clr_cmd ();
				mv_cursor (0, 24);
				printf (" Cutting image now ((%d,%d) to (%d,%d)...", x1,y1, x2,y2);
				if (orig)
					ret = cut (Raster, Width, Height, x1, y1, x2, y2, TransRast);
				else
					ret = cut (TransRast, NewWidth, NewHeight, x1, y1, x2, y2, TransRast);

				if (ret)
				{
					NewWidth  = x2 - x1 + 1;
					NewHeight = y2 - y1 + 1;

					clr_screen ();
					flicker (TransRast, NewWidth, NewHeight, Beta, Noise, 1);
				}
				else
				{
					clr_cmd ();
					mv_cursor (0, 24);  printf (" Cut image failed. Enter any key... ");
					wait_key ();
				}
				break;

			case 'O':		/* contrast expansion */
			case 'o':
#if 0
				clr_cmd ();
				mv_cursor (0, 24);  printf (" Enter lo range (0-255): ");
				get_string (32, buf);
				lo = atoi (buf);

				clr_cmd ();
				mv_cursor (0, 24);  printf (" lo=%d. Enter hi range (0-255, larger than lo): ", lo);
				get_string (32, buf);
				hi = atoi (buf);
#endif
				clr_cmd ();
				mv_cursor (0, 24);  printf (" Enter threshold (pixel count): ");
				get_string (32, buf);
				cthresh = atol (buf);


				clr_cmd ();
				mv_cursor (0, 24);  printf (" Contrast expanding image now...");
				if (orig)
				{
					if (contrast (Raster, Width, Height, cthresh, Hist, TransRast))
					{
						clr_screen ();
						flicker (TransRast, Width, Height, Beta, Noise, 1);
					}
					else
					{
						clr_cmd ();
						mv_cursor (0, 24);  printf (" Contrast expansion failed. Enter any key... ");
						wait_key ();
					}
				}
				else
				{
					if (contrast (TransRast, NewWidth, NewHeight, cthresh, Hist, TransRast))
					{
						clr_screen ();
						flicker (TransRast, NewWidth, NewHeight, Beta, Noise, 1);
					}
					else
					{
						clr_cmd ();
						mv_cursor (0, 24);  printf (" Contrast expansion failed. Enter any key... ");
						wait_key ();
					}
				}
				break;

			default:
				clr_cmd ();
				mv_cursor (0, 24);
				printf (" Unknown command. Type ? for help. Enter any key... ");
				wait_key ();
				break;
			}
			break;

		case 'B':			/* blur or brighten */
		case 'b':
			key = get_key ();
			printf ("%c", (char) key);
			switch (key)
			{
			case 'L':		/* blur */
			case 'l':
				clr_cmd ();
				mv_cursor (0, 24);  printf (" Blurring image now...");
				if (orig)
				{
					if (blur (Raster, Width, Height, TransRast))
					{
						clr_screen ();
						flicker (TransRast, Width, Height, Beta, Noise, 1);
					}
					else
					{
						clr_cmd ();
						mv_cursor (0, 24);  printf (" Blurring failed. Enter any key... ");
						wait_key ();
					}
				}
				else
				{
					if (blur (TransRast, NewWidth, NewHeight, TransRast))
					{
						clr_screen ();
						flicker (TransRast, NewWidth, NewHeight, Beta, Noise, 1);
					}
					else
					{
						clr_cmd ();
						mv_cursor (0, 24);  printf (" Blurring failed. Enter any key... ");
						wait_key ();
					}
				}
				break;

			case 'R':		/* brighten */
			case 'r':
				clr_cmd ();
				mv_cursor (0, 24);  printf (" Enter brightening value (-255 to 255): ");
				get_string (32, buf);
				brite = atoi (buf);

				clr_cmd ();
				mv_cursor (0, 24);  printf (" Brightening image now...");
				if (orig)
				{
					if (brighten (Raster, Width, Height, brite, TransRast))
					{
						clr_screen ();
						flicker (TransRast, Width, Height, Beta, Noise, 1);
					}
					else
					{
						clr_cmd ();
						mv_cursor (0, 24);  printf (" Brightening failed. Enter any key... ");
						wait_key ();
					}
				}
				else
				{
					if (brighten (TransRast, NewWidth, NewHeight, brite, TransRast))
					{
						clr_screen ();
						flicker (TransRast, NewWidth, NewHeight, Beta, Noise, 1);
					}
					else
					{
						clr_cmd ();
						mv_cursor (0, 24);  printf (" Brightening failed. Enter any key... ");
						wait_key ();
					}
				}
				break;

			default:
				clr_cmd ();
				mv_cursor (0, 24);
				printf (" Unknown command. Type ? for help. Enter any key... ");
				wait_key ();
				break;
			}
			break;

		case 'M':			/* mirror/median filter */
		case 'm':
			key = get_key ();
			printf ("%c", (char) key);
			switch (key)
			{
			case 'I':		/* mirror */
			case 'i':
				clr_cmd ();
				mv_cursor (0, 24);  printf (" Enter mirror direction (0=vertical, 1=horizontal): ");
				get_string (32, buf);
				opt = atoi (buf);

				clr_cmd ();
				mv_cursor (0, 24);  printf (" Mirror image now...");
				if (orig)
				{
					if (mirror (Raster, Width, Height, opt, TransRast))
					{
						clr_screen ();
						flicker (TransRast, Width, Height, Beta, Noise, 1);
					}
					else
					{
						clr_cmd ();
						mv_cursor (0, 24);  printf (" Mirror failed. Enter any key... ");
						wait_key ();
					}
				}
				else
				{
					if (mirror (TransRast, NewWidth, NewHeight, opt, TransRast))
					{
						clr_screen ();
						flicker (TransRast, NewWidth, NewHeight, Beta, Noise, 1);
					}
					else
					{
						clr_cmd ();
						mv_cursor (0, 24);  printf (" Mirror failed. Enter any key... ");
						wait_key ();
					}
				}
				break;

			case 'E':
			case 'e':		/* median filter */
				clr_cmd ();
				mv_cursor (0, 24);  printf (" Median filter image now...");
				if (orig)
				{
					if (median (Raster, Width, Height, TransRast))
					{
						clr_screen ();
						flicker (TransRast, Width, Height, Beta, Noise, 1);
					}
					else
					{
						clr_cmd ();
						mv_cursor (0, 24);  printf (" Median filter failed. Enter any key... ");
						wait_key ();
					}
				}
				else
				{
					if (median (TransRast, NewWidth, NewHeight, TransRast))
					{
						clr_screen ();
						flicker (TransRast, NewWidth, NewHeight, Beta, Noise, 1);
					}
					else
					{
						clr_cmd ();
						mv_cursor (0, 24);  printf (" Median filter failed. Enter any key... ");
						wait_key ();
					}
				}
				break;

			default:
				clr_cmd ();
				mv_cursor (0, 24);
				printf (" Unknown command. Type ? for help. Enter any key... ");
				wait_key ();
				break;
			}
			break;

		case 'N':			/* add noise */
		case 'n':
			clr_cmd ();
			mv_cursor (0, 24);  printf (" Enter noise percentage (0-100): ");
			get_string (32, buf);
			Noise = atoi (buf);
			break;

		case 'G':			/* Laplace filter */
		case 'g':
			clr_cmd ();
			mv_cursor (0, 24);  printf (" Enter beta (0,1,2,3,4,...): ");
			get_string (32, buf);
			Beta = atoi (buf);
			break;

		case 'V':			/* convolutions */
		case 'v':
			conv_menu (1);

 			clr_cmd ();
			mv_cursor (0, 24);  printf (" Enter your choice: ");
			get_string (32, buf);
			conv = atoi (buf);

			if (conv == USER_KERN)
			{
				conv_menu (2);

				for (i = 0; i < 9; i++)
				{
		 			clr_cmd ();
					mv_cursor (0, 24);
					printf (" Enter k%d (neg or pos integer): ", i);
					get_string (32, buf);
					convkern[i] = atoi (buf);
				}

	 			clr_cmd ();
				mv_cursor (0, 24);
				printf (" Scaling (if multiplier->1, divisor->-1, no scaling-> 0): ");
				get_string (32, buf);
				convkern[9] = atoi (buf);
				if (convkern[9] > 0)
				{
		 			clr_cmd ();
					mv_cursor (0, 24);
					printf (" Multiplier (neg or pos integer): ");
					get_string (32, buf);
					convkern[10] = atoi (buf);
				}
				else if (convkern[9] < 0)
				{
v_again:
		 			clr_cmd ();
					mv_cursor (0, 24);
					printf (" Divisor (neg or pos integer, NOT 0!!!): ");
					get_string (32, buf);
					convkern[10] = atoi (buf);
					if (convkern[10] == 0)
						goto v_again;
				}
				else
					convkern[10] = 1;
			}

			clr_cmd ();
			mv_cursor (0, 24);  printf (" Convolve image now...");
			if (orig)
			{
				if (convolve (Raster, Width, Height, conv, convkern, TransRast))
				{
					clr_screen ();
					flicker (TransRast, Width, Height, Beta, Noise, 1);
				}
				else
				{
					clr_cmd ();
					mv_cursor (0, 24);  printf (" Convolution failed. Enter any key... ");
					wait_key ();
				}
			}
			else
			{
				if (convolve (TransRast, NewWidth, NewHeight, conv, convkern, TransRast))
				{
					clr_screen ();
					flicker (TransRast, NewWidth, NewHeight, Beta, Noise, 1);
				}
				else
				{
					clr_cmd ();
					mv_cursor (0, 24);  printf (" Convolution failed. Enter any key... ");
					wait_key ();
				}
			}
			break;

		case 'O':			/* orig/transform toggle */
		case 'o':
 			clr_cmd ();
			mv_cursor (0, 24);
			if (orig)
			{
				orig  = 0;
				Beta  = 0;
				Noise = 0;
				printf (" Transforms on new image. Beta,Noise reset. Enter any key... ");
				wait_key ();
			}
			else
			{
				orig  = 1;
				Beta  = 0;
				Noise = 0;
				printf (" Transforms on original image. Beta,Noise reset. Enter any key... ");
				wait_key ();
/*				printf ("Copying original to transform array...");*/
/*				copyrast (Raster, Width, Height, TransRast);*/
			}
			break;

		case ' ':
			if (orig)
			{
				clr_screen ();
				flicker (Raster, Width, Height, Beta, Noise, 1);
			}
			else
			{
				clr_screen ();
				flicker (TransRast, NewWidth, NewHeight, Beta, Noise, 1);
			}
			break;

		default:
			clr_cmd ();
			mv_cursor (0, 24);
			printf (" Unknown command. Type ? for help. Enter any key... ");
			wait_key ();
			break;
		}
	}

endloop:


	if (check_key ())
		exit (1);

	return (!0);
}




/*------------------------------*/
/*	cmaptoint		*/
/*------------------------------*/
cmaptoint (pras, w, h, map, useNTSC)
uchar_t	       *pras;
int		w;
int		h;
uchar_t		map[MAPSIZ][3];
int		useNTSC;
{

/*
 *	convert image (in place) from colormap index to intensity. input
 *	contains pointer into a colormap. output will contain intensity
 *	either simple average or using NTSC formula. values will lie
 *	between 0 and 255, inclusive. array should be declared unsigned
 *	char.
 */

	register uchar_t       *pr;
	register uchar_t       *pmap;
	register long		rpl;
	register long		gpl;
	register long		bpl;
	register uint_t		c;
	register long		val;
	long			ii;
	long			lim;
	uchar_t greymap[256];


	lim  = (long) w * (long) h;
	pr   = pras;
	pmap = &(map[0][0]);
/* NEW, we save lots of time here */
	for(ii = 0;ii < 256;ii++) {
		rpl = (ulong_t) (map[ii][0]);
		gpl = (ulong_t) (map[ii][1]);
		bpl = (ulong_t) (map[ii][2]);

		if (useNTSC)
			val = ((rpl*30L) + (gpl*59L) + (bpl*11L)) / 100L;
		else
			val = (rpl + gpl + bpl) / 3L;

		if (val > 255)
			val = 255;
		if (val < 0)
			val = 0;
		greymap[ii] = val;
	}
	
	for (ii = 0L; ii < lim; ii++)
	{ /* NEW, the code above was removed from here */
		*pr++ = greymap[*pr];
	}
}




/*------------------------------*/
/*	showfl			*/
/*------------------------------*/
int showfl (s0)
int    *s0;
{

/*
 *	show a flicker image already in memory. for 640x400 ONLY!!!
 *	returns char read to stop the display as low byte of int.
 */

	register long	ii;
	register char  *ps1;
	register char  *ps2;
	char	       *old1;
	char	       *old2;
	int	       *s1, *s2, *s3;
	long		ret;



	/*
	 *   remember old screen
	 */
	old1 = Logbase ();
	old2 = Physbase ();



	/*
	 *   clear these (phys and logical)
	 */
	ps1 = old1;
	ps2 = old2;
	for (ii = 0L; ii < 32000L; ii++)
	{
		*ps1++ = 0;
		*ps2++ = 0;
	}



	/*
	 *   set phys screen to first screen
	 */
	Setscreen (old2, s0, -1);



	/*
	 *   set pointers
	 */
	s1 = (int *) Physbase ();
	s2 = (int *) ((long) s1 + 32000L);
	s3 = (int *) ((long) s2 + 32000L);



	/*
	 *   display until a key is pressed
	 */
	do
	{
		Setscreen (old2, s1, -1);	Vsync ();
		Setscreen (old2, s2, -1);	Vsync ();
		Setscreen (old2, s3, -1);	Vsync ();

	} while (!Bconstat (2));



	/*
	 *   get the key...
	 */
	ret = Bconin (2) & 0x000000ffL;



	/*
	 *   reset screen
	 */
	Setscreen (old1, old2, -1);



	/*
	 *   clear keypresses
	 */
	while (Bconstat (2))
		Bconin (2);


	/*
	 *   done.
	 */
	return ((int) ret);
}




/*------------------------------*/
/*	title			*/
/*------------------------------*/
void title (b)
int	b;
{

 clr_screen ();
 cursor (0);

 if (!b)
 {
  mv_cursor (10, 10);
  printf ("%s", version);
  mv_cursor (10, 12);
  printf ("GIF file is first read then displayed.  Mode initially set");
  mv_cursor (10, 13);
  printf ("to apply successive transforms to image.  Use \"o\" to apply");
  mv_cursor (10, 14);
  printf ("transforms independently to original image.   Pick options");
  mv_cursor (10, 15);
  printf ("from menu at prompt.  Use \"?\" to get help.  If you plan to");
  mv_cursor (10, 16);
  printf ("rotate an image, it is probably best to do that first.");

  mv_cursor (10, 18);
  printf ("Press any key to continue...");

  wait_key ();		/* wait for a keypress... */
 }
}




/*------------------------------*/
/*	conv_menu		*/
/*------------------------------*/
void conv_menu (opt)
int	opt;
{
 if (opt == 1)
 {
  clr_screen ();
  mv_cursor (0, 0);
  printf ("                         Built-in Convolution Kernels:\n");
  printf ("\n");
  printf ("  ------------ Low Pass Filter --------------   ----- High Pass Filter -----\n");
  printf ("  1/9 1/9 1/9  1/10 1/10 1/10  1/16 2/16 1/16   -1 -1 -1   0 -1  0   1 -2  1\n");
  printf ("  1/9 1/9 1/9  1/10 2/10 1/10  2/16 4/16 2/16   -1  9 -1  -1  5 -1  -2  5 -2\n");
  printf ("  1/9 1/9 1/9  1/10 1/10 1/10  1/16 2/16 1/16   -1 -1 -1   0 -1  0   1 -2  1\n");
  printf ("      [1]            [2]             [3]           [4]       [5]       [6]\n");
  printf (" -- Shift and Difference Edge --\n");
  printf (" Vertical  Horizontal Hor and Ver   ------------- Laplace Edge -------------\n");
  printf ("  0  0  0    0 -1  0   -1  0  0     0  1  0   -1 -1 -1   -1 -1 -1    1 -2  1\n");
  printf (" -1  1  0    0  1  0    0  1  0     1 -4  1   -1  8 -1   -1  9 -1   -2  4 -2\n");
  printf ("  0  0  0    0  0  0    0  0  0     0  1  0   -1 -1 -1   -1 -1 -1    1 -2  1\n");
  printf ("    [7]        [8]        [9]         [10]       [11]       [12]       [13]\n");
  printf (" ------------------------ Gradient Directional Edge -----------------------\n");
  printf ("   North    Northeast    East     Southeast    South    Southwest     West\n");
  printf ("  1  1  1    1  1  1   -1  1  1   -1 -1  1   -1 -1 -1    1 -1 -1    1  1 -1\n");
  printf ("  1 -2  1   -1 -2  1   -1 -2  1   -1 -2  1    1 -2  1    1 -2 -1    1 -2 -1\n");
  printf (" -1 -1 -1   -1 -1  1   -1  1  1    1  1  1    1  1  1    1  1  1    1  1 -1\n");
  printf ("    [14]       [15]       [16]       [17]       [18]       [19]       [20]\n");
  printf (" Northwest\n");
  printf ("  1  1  1\n");
  printf ("  1 -2 -1      Choose a filter (numbers in \"[]\" below kernels).\n");
  printf ("  1 -1 -1      For user-defined, enter 0. You will be prompted for values.\n");
  printf ("    [21]\n");
 }
 else if (opt == 2)
 {
  clr_screen ();
  mv_cursor (0, 0);
  printf ("\n");
  printf (" The convolution kernel is a 3x3 matrix which is applied to a\n");
  printf (" 3x3 neighborhood of a pixel and looks like this:\n");
  printf ("\n");
  printf ("       __          __ \n");
  printf ("      |              |\n");
  printf ("      | k0   k1   k2 |\n");
  printf ("      |              |\n");
  printf ("      | k3   k4   k5 |\n");
  printf ("      |              |\n");
  printf ("      | k6   k7   k8 |\n");
  printf ("      |__          __|\n");
  printf ("\n\n");
  printf (" You also need to specify if there is a resultant multiplyer or\n");
  printf (" divisor. The operation on pixels (p4 is target or center) is:\n");
  printf ("\n");
  printf (" p4 =  (p0 * k0) + ... + (p8 * k8)         ( 0, no scaling)\n");
  printf (" p4 = ((p0 * k0) + ... + (p8 * k8)) * mult ( 1, with multiplier)\n");
  printf (" p4 = ((p0 * k0) + ... + (p8 * k8)) / div  (-1, with divisor)\n");
  printf ("\n");
 }
}




/*------------------------------*/
/*	info			*/
/*------------------------------*/
void info (fname)
char   *fname;
{
int	key;
long	size;

clr_screen ();
mv_cursor (0, 1);

printf (" MGIF Version:    %s\n", version);
printf (" \n");
printf (" File:            %s\n", fname);
printf (" \n");
size = (long) Width * (long) Height;
printf (" Original image:\n");
printf ("          Width   %6d\n", Width);
printf ("          Height  %6d\n", Height);
printf ("          Size    %6ld pixels\n", size);
printf (" \n");
size = (long) Width * (long) Height;
printf (" New/transformed image:\n");
printf ("          Width   %6d\n", NewWidth);
printf ("          Height  %6d\n", NewHeight);
printf ("          Size    %6ld pixels\n", size);

}




/*------------------------------*/
/*	do_help			*/
/*------------------------------*/
void do_help ()
{
int	key;

clr_screen ();
mv_cursor (0, 1);

printf (" MGIF Version:    %s\n", version);
printf (" \n");
printf (" Category         Key(s) Description\n");
printf (" --------------------------------------------------------------------\n");
printf (" Control:         ?      help\n");
printf ("                  w      what (info about image)\n");
printf ("                  q      quit (next image)\n");
printf ("                  ESC    exit program now\n");
printf ("                  SPACE  draw image\n");
printf ("                  hi     histogram\n");
printf ("                  o      toggle transform original/new image\n");
printf ("                  f      file operations\n");
printf ("                  cp     image copy (orig<-->new)\n");
printf (" \n");
printf (" Display Options: n      add noise (0-100 percent, 0 turns off)\n");
printf ("                  g      Laplace filter (beta,1,2,... 0 turns off)\n");

clr_cmd ();
mv_cursor (0, 24);
printf (" More? (y/n): ");
key = get_key ();
printf ("%c", (char) key);
if ((key == 'n') || (key == 'N'))
	return;

clr_screen ();
mv_cursor (0, 1);

printf (" MGIF Version:    %s\n", version);
printf (" \n");
printf (" Category         Key(s) Description\n");
printf (" --------------------------------------------------------------------\n");
printf (" Frame Processes: e      enlarge (2x)\n");
printf ("                  s      shrink (.5x)\n");
printf ("                  z      zoom (2x)\n");
printf ("                  cu     cut\n");
printf ("                  r      rotate (+/-90 or 180 deg)\n");
printf ("                  mi     mirror (horizontal or vertical)\n");
printf (" \n");
printf (" Point Processes: he     histogram equalization\n");
printf ("                  i      inverse (negation, 0 all points else thresh)\n");
printf ("                  l      log scaling\n");
printf ("                  t      threshold (pseudo black/white)\n");
printf ("                  co     contrast expansion (need new range)\n");
printf ("                  br     brighten (darken if negative)\n");
printf (" \n");
printf (" Area Processes:  bl     blur (3x3)\n");
printf ("                  me     median filter (3x3)\n");
printf ("                  v      convolutions (3x3)\n");

return;
}

