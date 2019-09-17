#define atarist		/* machine (atarist, amiga, ibmpc, mac, sun, x11) */
#define alcyon		/* specific compiler, if any */


/*
 *	NAME:		fract - Generate monochrome Mandelbrot set
 *
 *	AUTHOR:		(c) 1989 Bill Rosenkranz
 *
 *			net:	rosenkra%boston@hall.cray.com
 *			CIS:	71460,17
 *			GENIE:	W.ROSENKRANZ
 *
 *			Feel free to copy. Leave this comment alone! No other
 *			restrictions on copying or hacking. Use as you like.
 *
 *	MOTIVATION:	I don't ever remember seeing a monochrome fractal
 *			generator. I like this "zebra" effect with -a. Try:
 *
 *				fract -a -i 50 -x -0.9 -y 0.3 -r 0.5
 *
 *			or unpack m1.arc and do:
 *
 *				fract -a -f m1
 *
 *	COMPILE (ST):	cc -o fract.ttp fract.c linea0.s linea1.s linea3.s
 *
 *	PORTABILITY:	Works with Alcyon 4.14 (Atari ST), should port easily
 *			to Mac, Amiga, Sun, PC, X, etc. except for file
 *			formats on non-680x0 architectures.
 *
 *			Floats in the files are only for text annotation.
 *			Uses FFP floats not IEEE in files (3 numbers, stored
 *			with putl). FFP is almost 2x faster. Here are formats
 *			for FFP and IEEE:
 *
 *			FFP binary representation of 1.000000 is:
 *
 *			   /---------------------------- mantissa (24 bits)
 *			   |                    /------- sign (1 bit)
 *			   |                    |   /--- exponent (7 bits)
 *			   |                    |   |
 *			mmmmmmmmmmmmmmmmmmmmmmmmseeeeeee
 *			10000000000000000000000001000001
 *			^
 *			MSbit
 *
 *			mantissa: 100000000000000000000000
 *			sign:     0
 *			exponent: 1000001
 *
 *
 *			IEEE binary representation of 1.000000 is:
 *
 *			/----------------- sign (1 bit)
 *			|   /------------- exponent (8 bits)
 *			|   |         /--- mantissa (23 bits)
 *			|   |         |
 *			seeeeeeeemmmmmmmmmmmmmmmmmmmmmmm
 *			00111111100000000000000000000000
 *			^
 *			MSbit
 *
 *			sign:     0
 *			exponent: 01111111(127)
 *			mantissa: 00000000000000000000000(0)
 *
 *
 *			Note: getw() must read 16-bit int and getl() must
 *			read 32-bit int from stream. putw() and putl() should
 *			work with the same sizes, respectively.
 *
 *			For anyone hacking on the file stuff, do us all a
 *			favor and not try to write structures to the file.
 *			binary is bad enough. Binary structures is impossible.
 *
 *	NOTES:		Rough timings for scale=FINE, default x,y,range
 *			(8 Mhz atari ST):
 *
 *			-i	time
 *			-----	-------
 *			10	560 sec
 *			50	1350 sec
 *			100	2280 sec
 *			(-i 100 on a cray-2 is about 2 sec, no hand opt *8^)
 *
 *			The more points in the set in the zoom range, the
 *			longer it takes because it has to go to max_iter.
 *			The algorithm is pretty week and could be beefed up.
 *			This was a one day hack.
 *
 *			I was thinking of some sort of RLE-like encoding of
 *			data. How about if MSbit set, that word tells now
 *			many of the next word gets repeated? So rather than:
 *
 *				.... 0001 0001 0001 0001 0001 0001 0005 ....
 *
 *			you use:
 *
 *				.... 8006 0001 0005 ....
 *
 *			This takes much longer to read and write a file.
 *
 *			Make as a .ttp and use -h to hold for desktop or to
 *			take a snapshot.
 */

#include <stdio.h>
#include <math.h>
#include "version.h"


/*
 *	for portability of binary file (ha!)
 */
#undef WORD
#define WORD		int		/* 16-bit required */
#undef REAL
#define REAL		float		/* 32-bit required */
#undef LONG
#define LONG		long		/* 32-bit required */
#undef BYTE_WORD
#define BYTE_WORD	2		/* bytes per word */


#define BLACK		1		/* pixel colors */
#define WHITE		0

#define COARSE		45		/* ok for mono ST (pixels size) */
#define MED_COARSE	90		/* 360x360 pixel display */
#define MED_FINE	180
#define FINE		360

#define F_ATARIST	0		/* for file formats. all 680x0 */
#define F_AMIGA		1		/* should be the same. */
#define F_IBMPC		2
#define F_MACINTOSH	3
#define F_SUN		4


/*
 *	forward references and externals. non-portable are indicated...
 */
extern long	getl ();
extern int	getw ();		/* MUST read 16-bit (short) */

int		do_mandel ();
int		plt_mandel ();
int		plot_logic ();
int		pr_params ();
int		usage ();
int		init ();		/* atari ST */
int		finish ();		/* atari ST */
int		check_key ();		/* atari ST (BIOS) */
int		wait_key ();		/* atari ST (BIOS) */
int		do_pixel ();		/* atari ST (line A) */
int		do_line ();		/* atari ST (line A) */
int		cursor ();		/* atari ST (gemdos, vt52) */
int		mv_cursor ();		/* atari ST (vt52) */
int		clr_screen ();		/* atari ST (gemdos, vt52) */
long		do_time ();		/* atari ST (gemdos, sysvar) */


WORD		array_G[FINE][FINE];	/* storage for the set (~250 kB) */



/*------------------------------*/
/*	main			*/
/*------------------------------*/
main (argc, argv)
int	argc;
char   *argv[];
{
	int		max_iter;	/* the threshold (normally 1000) */
	int		scale;		/* pixels per unit */
	int		oset;		/* offset of plot from scrn corner */
	int		normcolor;	/* 1=normal, 0=reverse colors */
	int		alternate;	/* 0=no contours, 1=use alt cont */
	int		hold_scrn;	/* for hold before return to desktop */
	int		save_it;	/* to save as file */
	int		load_it;	/* to load from file */
	int		ret;
	int		this_vers = VERSION;
	int		file_vers;
	int		this_format = F_ATARIST;
	int		file_format;
	long		elapsed;	/* elapsed seconds */
	float		x,		/* coord of view center */
			y;
	float		range;		/* view width,height */
	char		fname[256];
	char		this_magic[10];
	char		file_magic[10];	/* magic for file */
	FILE	       *stream;
	union F_TO_L			/* for float<-->long (i/o only) */
	{
			LONG	_l;
			REAL	_f;

	}		f_to_l;



	/*
	 *   set defaults, initialize...
	 */
	strcpy (this_magic, "!<fract>");
	normcolor = 1;
	alternate = 0;
	max_iter  = 1000;
	scale     = FINE;
	oset      = 20;
	hold_scrn = 0;
	save_it   = 0;
	load_it   = 0;

	x         = -0.5;		/* image of full set... */
	y         =  0.0;
	range     =  3.0;

	init ();



	/*
	 *   parse args...
	 */
	argc--, argv++;
	while (argc)
	{
		if (**argv == '-')
		{
			switch (*(*argv+1))
			{
			case 'i':			/* iterations */
			case 'I':
				argc--, argv++;
				if (argc < 1)
					usage ();
				max_iter = atoi (*argv);
				if (max_iter < 1 || max_iter > 1000)
					max_iter = 1000;
				break;

			case 'x':			/* x coord of center */
			case 'X':
				argc--, argv++;
				if (argc < 1)
					usage ();
				x = atof (*argv);
				break;

			case 'y':			/* y coord of center */
			case 'Y':
				argc--, argv++;
				if (argc < 1)
					usage ();
				y = atof (*argv);
				break;

			case 'r':			/* range */
			case 'R':
				argc--, argv++;
				if (argc < 1)
					usage ();
				range = atof (*argv);
				break;

			case 's':			/* scale */
			case 'S':
				argc--, argv++;
				if (argc < 1)
					usage ();
				scale = atoi (*argv);
				switch (scale)
				{
				case FINE:
				case COARSE:
				case MED_FINE:
				case MED_COARSE:
					break;
				case 0:
					scale = COARSE;
					break;
				case 1:
					scale = MED_COARSE;
					break;
				case 2:
					scale = MED_FINE;
					break;
				default:
					scale = FINE;
					break;
				}
				break;

			case 'v':			/* reverse video */
			case 'V':
				normcolor = 0;
				break;

			case 'a':			/* alternate even/odd */
			case 'A':
				alternate = 1;
				break;

			case 'h':			/* hold screen */
			case 'H':
				hold_scrn = 1;
				break;

			case 'o':			/* save */
			case 'O':
				argc--, argv++;
				if (argc < 1)
					usage ();
				strcpy (fname, *argv);
				save_it = 1;
				break;

			case 'f':			/* load file */
			case 'F':
				argc--, argv++;
				if (argc < 1)
					usage ();
				strcpy (fname, *argv);
				load_it = 1;
				break;

			default:
				usage ();
			}
		}
		else
			usage ();

		argc--, argv++;
	}

	if (alternate)
		normcolor = (normcolor) ? 0 : 1;
	



	/*
	 *   if loading, read in data...
	 */
	if (load_it)
	{
		/*
		 *   file format (words are 16-bit):
		 *
		 *	magic		(8 bytes)
		 *	file format	(word)
		 *	program version	(word)
		 *	iter 		(word)
		 *	scale 		(word)
		 *	x 		(32-bit ffp float)
		 *	y 		(32-bit ffp float)
		 *	range 		(32-bit ffp float)
		 *	data 		(scale * scale 16-bit words)
		 *
		 *   (yes, i know binary data is NOT portable...)
		 *
		 *   BTW: the union is used because a cast to long would
		 *   convert (say) 1.789 to 1. the union unsures we store
		 *   it with bits unchanged...
		 */
		int	i;
		int	j;

#ifdef alcyon
		if ((stream = fopenb (fname, "r")) == (FILE *) 0)
#else
		if ((stream = fopen (fname, "rb")) == (FILE *) 0)
#endif
		{
			mv_cursor (51, 22);
			fprintf (stderr,
				"open input err, %s",
				fname);

			goto xit;
		}

		for (i = 0; i < 8; i++)
			file_magic[i] = (char) getc (stream);

		file_format = getw (stream);
		file_vers   = getw (stream);
		max_iter    = getw (stream);
		scale       = getw (stream);
		f_to_l._l   = (LONG) getl (stream); x     = (float) f_to_l._f;
		f_to_l._l   = (LONG) getl (stream); y     = (float) f_to_l._f;
		f_to_l._l   = (LONG) getl (stream); range = (float) f_to_l._f;
		for (i = 0; i < scale; i++)
		{
#ifdef alcyon
			fread (array_G[i], BYTE_WORD, scale, stream);
/*			read (stream->_fd, array_G[i], scale * 2);
			this was significantly fast but did not work
			properly. hmmm...*/
#else
			for (j = 0; j < scale; j++)
				array_G[i][j] = (WORD) getw (stream);
#endif
		}

		fclose (stream);

		/*
		 *   print parameters...
		 */
		pr_params (max_iter, scale, oset, x, y, range);

		/*
		 *   ...and just plot the set...
		 */
		plt_mandel (max_iter, scale, oset, normcolor, alternate, x, y, range);

		goto xit;
	}



	/*
	 *   this could eventually be a loop to allow users to pick new
	 *   zoom area (here to xit:)
	 */


	/*
	 *   print parameters...
	 */
	pr_params (max_iter, scale, oset, x, y, range);



	/*
	 *   do coarse grain (if interupted, proceed to fine grain)...
	 */
	do_time (1);

	ret = do_mandel (((max_iter > 50) ? 50 : max_iter), COARSE, oset,
			normcolor, alternate, x, y, range);

	elapsed = do_time (2);
	mv_cursor (51, 18);	printf ("time    = %ld (sec)", elapsed);



	/*
	 *   ...now do fine grain...
	 */
	if (scale != COARSE)
	{
		do_time (1);

		ret = do_mandel (max_iter, scale, oset, normcolor, alternate,
				x, y, range);

		elapsed = do_time (2);

		mv_cursor (51, 18);  printf ("time    = %ld (sec)", elapsed);

		if (ret)
		{
			mv_cursor (51, 22);	printf ("aborted!");

			goto xit;
		}
	}



	/*
	 *   save file if needed...
	 */
	if (save_it)
	{
		int	i;
		int	j;

#ifdef alcyon
		if ((stream = fopenb (fname, "w")) == (FILE *) 0)
#else
		if ((stream = fopen (fname, "wb")) == (FILE *) 0)
#endif
		{
			mv_cursor (51, 22);
			fprintf (stderr,
				"open output err, %s\n",
				fname);

			goto xit;
		}

		for (i = 0; i < 8; i++)
			putc (this_magic[i], stream);
		putw (this_format, stream);
		putw (this_vers,   stream);
		putw (max_iter,    stream);
		putw (scale,       stream);
		f_to_l._f = (REAL) x;	    putl ((long) (f_to_l._l), stream);
		f_to_l._f = (REAL) y;	    putl ((long) (f_to_l._l), stream);
		f_to_l._f = (REAL) range;   putl ((long) (f_to_l._l), stream);
		for (i = 0; i < scale; i++)
		{
#ifdef alcyon
			fwrite (array_G[i], BYTE_WORD, scale, stream);
#else
			for (j = 0; j < scale; j++)
				putw (array_G[i][j], stream);
#endif
		}

		fclose (stream);
	}




xit:
	/*
	 *   clean up and exit (no return)
	 */
	finish (hold_scrn);
}




/*------------------------------*/
/*	usage			*/
/*------------------------------*/
usage ()
{
	fprintf (stderr, "fract [options]\n");
	fprintf (stderr, "\n");
	fprintf (stderr, "        -i iterations (1000)\n");
	fprintf (stderr, "        -x xcenter (-1.0)\n");
	fprintf (stderr, "        -y ycenter (0.0)\n");
	fprintf (stderr, "        -r range (3.0)\n");
	fprintf (stderr, "        -s scale (360 or 3)\n");
	fprintf (stderr, "        -v\n");
	fprintf (stderr, "        -a\n");
	fprintf (stderr, "        -h\n");
	fprintf (stderr, "        -o outfile\n");
	fprintf (stderr, "        -f infile\n");

	cursor (1);
	exit (1);
}




/*------------------------------*/
/*	pr_params		*/
/*------------------------------*/
pr_params (max_iter, scale, oset, x, y, range)
int	max_iter;
int	scale;
int	oset;
float	x;
float	y;
float	range;
{

/*
 *	print parameters off to the side and make a box for the set.
 */

	int	l_scale = FINE;
	int	x1, x2, y1, y2;

	mv_cursor (49, 1);	printf ("%s", version_G);

	mv_cursor (51, 3);	printf ("iter    = %d", max_iter);
	mv_cursor (51, 4);	printf ("xcenter = %f", x);
	mv_cursor (51, 5);	printf ("ycenter = %f", y);
	mv_cursor (51, 6);	printf ("range   = %f", range);
	mv_cursor (51, 7);	printf ("scale   = %d", scale);

	mv_cursor (51, 9);	printf ("xmin    = %f", x - range/2.0);
	mv_cursor (51, 10);	printf ("xmax    = %f", x + range/2.0);
	mv_cursor (51, 11);	printf ("ymin    = %f", y - range/2.0);
	mv_cursor (51, 12);	printf ("ymax    = %f", y + range/2.0);

	fflush (stdout);

	/*
	 *   draw box...
	 */
	x1 = oset-1; 		x2 = oset+l_scale;		/* top */
	y1 = oset-1; 		y2 = y1;
	do_line (x1, y1, x2, y2);

	x1 = oset-1; 		x2 = oset+l_scale;		/* bottom */
	y1 = oset+l_scale;	y2 = y1;
	do_line (x1, y1, x2, y2);

	x1 = oset-1; 		x2 = x1;			/* left */
	y1 = oset-1; 		y2 = oset+l_scale;
	do_line (x1, y1, x2, y2);

	x1 = oset+l_scale;	x2 = x1;			/* right */
	y1 = oset-1;	 	y2 = oset+l_scale;
	do_line (x1, y1, x2, y2);
}




/*------------------------------*/
/*	do_mandel		*/
/*------------------------------*/
int	do_mandel (iter, scale, oset, normcolor, alternate, x, y, range)
int	iter;
int	scale;
int	oset;
int	normcolor;
int	alternate;
float	x,
	y;
float	range;
{

/*
 *	calculate the set and plot it as it is generated
 */

	register int	max_iter = iter;
	register int	ix,		/* pixel number */
			iy;		/* row number */
	register int	count;		/* count is the contour level */
	float		size;		/* thing to compare for convergence */
	float		a,		/* intermediates... */
			b,
			ac,
			bc,
			b1;
	float		gap;		/* units for each pixel */



	gap =  range / (float) scale;


	/*
	 *   each row...
	 */
	for (iy = 0; iy < scale; iy++)
	{
		bc = y + (range / 2.0) - (float) iy * gap;

		/*
		 *   each pixel in row...
		 */
		for (ix = 0; ix < scale; ix++)
		{
			ac    = x - (range / 2.0) + (float) ix * gap;
			a     = ac;
			b     = bc;
			size  = 0.0;
			count = 0;

			/*
			 *   iterate...
			 */
			while (size < 4.0 && count < max_iter)
			{
				b1   = 2 * a * b;
				a    = a * a - b * b + ac;
				b    = b1 + bc;
				size = a * a + b * b;

				/*
				 *   this is what we are after: the number
				 *   of iterations to convergence/divergence
				 */
				count++;
			}


			/*
			 *   store it...
			 */
			array_G[ix][iy] = (WORD) count;


			/*
			 *   if in set, plot pixel
			 */
			plot_logic (normcolor, alternate, count, max_iter,
				scale, ix, iy, oset);
			

			/*
			 *   was a key pressed? if so, exit for now...
			 */
			if (check_key ())
				return (1);
		}
	}
	return (0);
}




/*------------------------------*/
/*	plt_mandel		*/
/*------------------------------*/
plt_mandel (iter, scale, oset, normcolor, alternate, x, y, range)
int	iter;
int	scale;
int	oset;
int	normcolor;
int	alternate;
float	x,
	y;
float	range;
{

/*
 *	just plot a set in global array_G
 */

	register int	max_iter = iter;
	register int	ix,		/* pixel number */
			iy;		/* row number */
	register int	count;


	/*
	 *   each row...
	 */
	for (iy = 0; iy < scale; iy++)
	{
		/*
		 *   each pixel in row...
		 */
		for (ix = 0; ix < scale; ix++)
		{
			/*
			 *   get count from array...
			 */
			count = (int) array_G[ix][iy];


			/*
			 *   if in set, plot pixel
			 */
			plot_logic (normcolor, alternate, count, max_iter,
				scale, ix, iy, oset);
		}
	}
}




/*------------------------------*/
/*	plot_logic		*/
/*------------------------------*/
plot_logic (normcolor, alternate, count, max_iter, scale, ix, iy, oset)
int	normcolor;
int	alternate;
int	count;
int	max_iter;
int	scale;
int	ix;
int	iy;
int	oset;
{

/*
 *	logic to figure if point is in set or not and what color to plot it
 */

	if (normcolor)
	{
		if (alternate)
		{
			if ((count % 2) && (count < max_iter))
				do_pixel (scale, ix, iy, oset, BLACK);
			else
				do_pixel (scale, ix, iy, oset, WHITE);
		}
		else if (count >= max_iter)
		{
			do_pixel (scale, ix, iy, oset, BLACK);
		}
		else
		{
			do_pixel (scale, ix, iy, oset, WHITE);
		}
	}
	else
	{
		if (alternate)
		{
			if (!((count % 2) && (count < max_iter)))
				do_pixel (scale, ix, iy, oset, BLACK);
			else
				do_pixel (scale, ix, iy, oset, WHITE);
		}
		else if (count < max_iter)
		{
			do_pixel (scale, ix, iy, oset, BLACK);
		}
		else
		{
			do_pixel (scale, ix, iy, oset, WHITE);
		}
	}
}












/*
 *	these functions are all required but these are atari-specific
 */

#ifdef atarist
#include <osbind.h>			/* atari ST (BIOS) */
#endif


/*------------------------------*/
/*	init			*/
/*------------------------------*/
init ()
{

/*
 *	start up thingies (open windows, clear screens, etc)
 */

#ifdef atarist
	/*
	 *	clear screen, hide cursor, init timer...
	 */
	clr_screen ();
	cursor (0);
	do_time (0);
#endif

}




/*------------------------------*/
/*	finish			*/
/*------------------------------*/
finish (hold_scrn)
int	hold_scrn;
{

/*
 *	finish up...
 */

#ifdef atarist
	if (hold_scrn)
	{
		wait_key ();
	}
	cursor (1);

	exit (0);
#endif

}




/*------------------------------*/
/*	check_key		*/
/*------------------------------*/
check_key ()
{

/*
 *	ckecks for a key and flushes keyboard buffer.
 */

#ifdef atarist
	/*
	 *	this is for atari ST using BIOS.
	 */
	if (Bconstat (2))			/* if CONSOLE has a char... */
	{
		while (Bconstat (2))		/* read char while there are */
			Bconin (2);		/* chars to read (flush) */

		return (1);			/* yes, there was a key */
	}

	return (0);				/* no key */

#endif /*atarist*/

}




/*------------------------------*/
/*	wait_key		*/
/*------------------------------*/
wait_key ()
{

/*
 *	waits for a key and flushes keyboard buffer.
 */

#ifdef atarist
	/*
	 *	this is for atari ST using BIOS.
	 */
	while (!Bconstat (2))			/* wait for a key... */
		;

	while (Bconstat (2))			/* keep reading while there */
		Bconin (2);			/* are key inputs... */

#endif /*atarist*/

}




/*------------------------------*/
/*	do_pixel		*/
/*------------------------------*/
do_pixel (scale, ix, iy, oset, color)
int	scale;
int	ix;
int	iy;
int	oset;
int	color;
{

/*
 *	put a pixel or BIG pixel.
 */

#ifdef atarist
	/*
	 *	this is for atari ST using line A.
	 */
	extern long	linea0 ();
	extern int	linea1 ();

	static long	A_ptr = 0L;	/* to line-A struct */

	int		i,
			j;
	int		num;

	
	/*
	 *   init line A if needed...
	 */
	if (!A_ptr)
		A_ptr = linea0 ();

		
	/*
	 *   if not fine scale, we need to plot BIG pixels
	 */
	if (scale < FINE)
	{
		num = FINE / scale;

		for (i = 0; i < num; i++)
		{
			for (j = 0; j < num; j++)
			{
				linea1 (A_ptr,	oset+(ix*num+i), oset+(iy*num+j), color);
			}
		}
	}
	else
	{
		linea1 (A_ptr, oset + ix, oset + iy, color);
	}

#endif /*atarist*/

}




/*------------------------------*/
/*	do_line			*/
/*------------------------------*/
do_line (x1, y1, x2, y2)
int	x1, y1, x2, y2;
{

/*
 *	draw a line.
 */

#ifdef atarist
	/*
	 *	this is for atari ST using line A.
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

#endif /*atarist*/

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

#ifdef atarist
	/*
	 *	for atari ST. uses gemdos string output and vt52 escapes
	 */
	if (visible)
		Cconws ("\33e");
	else
		Cconws ("\33f");

#endif /*atarist*/

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

#ifdef atarist
	/*
	 *	for atari ST. uses vt52 escapes
	 */
	printf ("\33Y%c%c", (char) (row + ' '), (char) (col + ' '));
	fflush (stdout);

#endif /*atarist*/

}




/*------------------------------*/
/*	clr_screen		*/
/*------------------------------*/
clr_screen ()
{

/*
 *	clear screen, home cursor
 */

#ifdef atarist
	/*
	 *	for atari ST. uses gemdos string output and vt52 escapes
	 */
	Cconws ("\33E");

#endif /*atarist*/

}




/*------------------------------*/
/*	do_time			*/
/*------------------------------*/
long	do_time (opt)
int	opt;				/* 0=init,1=start,2=end (ret elapsed)*/
{

/*
 *	timing functions
 */

#ifdef atarist
	/*
	 *	for atari ST. uses gemdos and sys variables (200 hz timer).
	 */
	static unsigned long	start;
	static unsigned long	stop;

	long			savessp;
	unsigned long		elapsed;		/* seconds */


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

#endif /*atarist*/

}
