/*
 *	pi1tomon - display .pi1 file, floyd-steinberg dither
 *
 *	pi1tomon [-t(hree)] [-i(nvert)] [-90 | +90] file ...
 */

#include <stdio.h>
#include <math.h>
#include <osbind.h>
#include "version.h"


#define BLACK		1		/* pixel colors */
#define WHITE		0

int		do_floyd ();
int		usage ();
int		init ();		/* atari ST */
int		finish ();		/* atari ST */
int		check_key ();		/* atari ST (BIOS) */
int		wait_key ();		/* atari ST (BIOS) */
int		set_pixel ();		/* atari ST (line A) */
int		cursor ();		/* atari ST (gemdos, vt52) */
int		mv_cursor ();		/* atari ST (vt52) */
int		clr_screen ();		/* atari ST (gemdos, vt52) */
long		do_time ();		/* atari ST (gemdos, sysvar) */



int		scrn[16000];
int		palette[16];
long		histo[16];


/*------------------------------*/
/*	main			*/
/*------------------------------*/
main (argc, argv)
int	argc;
char   *argv[];
{
	int		opt;
	int		hold_scrn;	/* for hold before return to desktop */
	int		ret;
	long		elapsed;	/* elapsed seconds */
	FILE	       *in;
	int		res;
	int		nread;
	int		invert;
	int		rotat;
	int		three_by;
	char	       *ps;


	/*
	 *   initialize things...
	 */
	init ();

	opt       = 1;
	hold_scrn = 1;
	rotat     = 0;
	invert    = 0;
	three_by  = 0;

	argc--, argv++;


	/*
	 *   parse args...
	 */
	while (argc && (**argv == '-' || **argv == '+'))
	{
		if (**argv == '+' && !strncmp (*argv, "+90", 3))
			rotat = 90;
		else if (**argv == '-')
		{
			switch (*(*argv+1))
			{
			case '9':		/* -90 deg rotation */
				rotat = -90;
				break;
			case 'i':		/* invert black/white */
				invert = 1;
				break;
			case 't':		/* use 3x3 neighbors */
				three_by = 1;
				break;
			}
		}

		argc--, argv++;
	}

	if (argc < 1)
		usage ();


	/*
	 *   loop on remaining files...
	 */
	while (argc--)
	{

		clr_screen ();


		/*
		 *   open file
		 */
		if ((in = fopenb (*argv, "r")) == (FILE *) 0)
		{
			fprintf (stderr, "could not open %s\n", *argv);
			exit (1);
		}
		ps = *argv++;


		/*
		 *   read file
		 *
		 *	1	word	resolution
		 *	16	word	palette
		 *	16000	word	screen memory
		 */
		nread = fread (&res, 2, 1, in);
		if (nread != 1)
		{
			fprintf (stderr, "could not read resolution\n");
			fclose (in);
			exit (1);
		}
		nread = fread (palette, 2, 16, in);
		if (nread != 16)
		{
			fprintf (stderr, "could not read palette\n");
			fclose (in);
			exit (1);
		}
		nread = fread (scrn, 2, 16000, in);
		if (nread != 16000)
		{
			fprintf (stderr, "could not read screen\n");
			fclose (in);
			exit (1);
		}

		fclose (in);


		/*
		 *   do it...
		 */
		do_time (1);

		do_floyd (rotat, invert, three_by);

		elapsed = do_time (2);


		/*
		 *   legend...
		 */
		mv_cursor (51, 18);  printf (" file:  %s", ps);
		mv_cursor (51, 19);  printf (" elapsed time = %ld (sec)", elapsed);
		mv_cursor (51, 21);  printf (" any key to continue...");


		/*
		 *   wait for a keypress...
		 */
		wait_key ();
	}

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

	fprintf (stderr, "pi1tomon [-90 | +90] [-i] [-t] file.pi1 ...\n");

	cursor (1);
	exit (1);
}



long		accum[327][207];		/* error accumulation array */


/*------------------------------*/
/*	do_floyd		*/
/*------------------------------*/
int	do_floyd (rotat, invert, three_by)
int	rotat;
int	invert;
int	three_by;
{

/*
 *	test floyd-steinberg dither. hardwired for 320x200
 */

	register int	shift;
	register int	indx;
	register int	val;
	register int	ix,		/* pixel number */
			iy;		/* row number */
	int		px,
			py;
	long		error;
	long		e1,
			e2;
	long		intens;
	int		pl_0,
			pl_1,
			pl_2,
			pl_3;


	/*
	 *   draw box around image
	 */
	if (rotat)
	{
		do_line (  9,   9, 210,   9);
		do_line (  9,   9,   9, 330);
		do_line (210, 330, 210,   9);
		do_line (210, 330,   9, 330);
	}
	else
	{
		do_line (  9,   9, 330,   9);
		do_line (  9,   9,   9, 210);
		do_line (330, 210, 330,   9);
		do_line (330, 210,   9, 210);
	}


	/*
	 *   make sure to zero out error accumulate array!
	 */
	for (iy = 0; iy < 207; iy++)
	{
		for (ix = 0; ix < 327; ix++)
			accum[ix][iy] = 0;
	}


	/*
	 *   clear histogram
	 */
	for (iy = 0; iy < 16; iy++)
	{
		histo[iy] = 0L;
	}


	/*
	 *   each row...
	 */
	for (iy = 0; iy < 200; iy++)
	{
		/*
		 *   scan alternating right (even rows) and left (odd rows)
		 *   putting the test outside the loop is faster (but bigger)
		 */
		if (iy & 1)
		{
			/*
			 *   scan left...
			 *
			 *   each pixel in row...
			 */
			for (ix = 319; ix >= 0; ix--)
			{
				/*
				 *   get intensities for pixel, scaled 0-100
				 */
				indx  = (iy * 80) + (ix / 16) * 4;
				shift = 15 - (ix % 16);

				pl_0 = ((scrn[indx] >> shift) & 1);
				pl_1 = ((scrn[indx+1] >> shift) & 1);
				pl_2 = ((scrn[indx+2] >> shift) & 1);
				pl_3 = ((scrn[indx+3] >> shift) & 1);

				val = (pl_3 << 3) | (pl_2 << 2) | (pl_1 << 1)
				                  | (pl_0);

				intens = (long) (palette[val]);

				histo[val] += 1L;


				/*
				 *   device intensities: 0=black, 0x777=white
				 *
				 *   this is the heart of the f-s alg: find
				 *   the value of device intesity (in this
				 *   case 0 or 777) which minimizes the error.
				 *   if invert, change black to white and visa
				 *   versa...
				 */
				if (three_by)
				{
					px = ix + 2;
					py = iy + 1;
				}
				else
				{
					px = ix + 1;
					py = iy + 1;
				}

				if (invert)
				{
					e1 = intens + accum[px][py];
					e2 = intens + accum[px][py] - 0x777L;
				}
				else
				{
					e1 = intens + accum[px][py] - 0x777L;
					e2 = intens + accum[px][py];
				}


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
					 *
					 *   handle rotation here
					 */
					error = e2;

					if (rotat < 0)
						set_pixel (200 - iy + 10, ix + 10);
					else if (rotat > 0)
						set_pixel (iy + 10, 320 - ix + 10);
					else
						set_pixel (ix + 10, iy + 10);
				}

				/*
				 *   accumulate error in neighbors...
				 */
				if (three_by)
				{
			accum[px-1][py  ] = accum[px-1][py  ] + (2 * error) / 9;
			accum[px  ][py+1] = accum[px  ][py+1] + (2 * error) / 9;
			accum[px-2][py  ] = accum[px-2][py  ] + (error / 9);
			accum[px  ][py+2] = accum[px  ][py+2] + (error / 9);
			accum[px-1][py+1] = accum[px-1][py+1] + (error / 6);
			accum[px-2][py+1] = accum[px-2][py+1] + (error / 18);
			accum[px-1][py+2] = accum[px-1][py+2] + (error / 18);
			accum[px-2][py+2] = accum[px-2][py+2] + (error / 18);
				}
				else
				{
			accum[px-1][py]   = accum[px-1][py]   + (3 * error) / 8;
			accum[px][py+1]   = accum[px][py+1]   + (3 * error) / 8;
			accum[px-1][py+1] = accum[px-1][py+1] + (error / 4);
				}


				/*
				 *   was a key pressed? if so, exit for now...
				 */
				if (check_key ())
					return (1);
			}
		}
		else
		{
			/*
			 *   scan right...
			 *
			 *   each pixel in row...
			 */
			for (ix = 0L; ix < 320L; ix++)
			{
				/*
				 *   get intensities for pixel, scaled 0-100
				 */
				indx  = (iy * 80) + (ix / 16) * 4;
				shift = 15 - (ix % 16);

				pl_0 = ((scrn[indx] >> shift) & 1);
				pl_1 = ((scrn[indx+1] >> shift) & 1);
				pl_2 = ((scrn[indx+2] >> shift) & 1);
				pl_3 = ((scrn[indx+3] >> shift) & 1);

				val = (pl_3 << 3) | (pl_2 << 2) | (pl_1 << 1)
				                  | (pl_0);

				intens = (long) (palette[val]);

				histo[val] += 1L;


				/*
				 *   device intensities: 0=black, 1(000)=white
				 */
				if (three_by)
				{
					px = ix + 2;
					py = iy + 1;
				}
				else
				{
					px = ix + 1;
					py = iy + 1;
				}


				if (invert)
				{
					e1 = intens + accum[px][py];
					e2 = intens + accum[px][py] - 0x777L;
				}
				else
				{
					e1 = intens + accum[px][py] - 0x777L;
					e2 = intens + accum[px][py];
				}

				if (abs (e1) < abs (e2))
				{
					error = e1;
				}
				else
				{
					error = e2;

					if (rotat < 0)
						set_pixel (200 - iy + 10, ix + 10);
					else if (rotat > 0)
						set_pixel (iy + 10, 320 - ix + 10);
					else
						set_pixel (ix + 10, iy + 10);
				}

				if (three_by)
				{
			accum[px+1][py  ] = accum[px+1][py  ] + (2 * error) / 9;
			accum[px  ][py+1] = accum[px  ][py+1] + (2 * error) / 9;
			accum[px+2][py  ] = accum[px+2][py  ] + (error / 9);
			accum[px  ][py+2] = accum[px  ][py+2] + (error / 9);
			accum[px+1][py+1] = accum[px+1][py+1] + (error / 6);
			accum[px+2][py+1] = accum[px+2][py+1] + (error / 18);
			accum[px+1][py+2] = accum[px+1][py+2] + (error / 18);
			accum[px+2][py+2] = accum[px+2][py+2] + (error / 18);
				}
				else
				{
			accum[px+1][py]   = accum[px+1][py]   + (3 * error) / 8;
			accum[px][py+1]   = accum[px][py+1]   + (3 * error) / 8;
			accum[px+1][py+1] = accum[px+1][py+1] + (error / 4);
				}


				/*
				 *   was a key pressed? if so, exit for now...
				 */
				if (check_key ())
					return (1);
			}
		}
	}

	/*
	 *   draw histogram
	 */
	do_histo (rotat);

	return (0);
}




/*------------------------------*/
/*	do_histo		*/
/*------------------------------*/
int	do_histo (rotat)
int	rotat;
{

/*
 *	draw histogram
 */

	int	i;
	long	hmax;
	int	x1,
 		x2,
 		y1,
 		y2;

	/*
	 *   draw box around histogram
	 */
	do_line (400,   9, 455,   9);
	do_line (400,   9, 400,  89);
	do_line (455,  89, 455,   9);
	do_line (455,  89, 400,  89);

	hmax = 0;
	for (i = 0; i < 16; i++)
	{
		if (histo[i] > hmax)
			hmax = histo[i];
	}

	for (i = 0; i < 16; i++)
	{
		x1 = 400;
		y1 = 12 + (5 * i);
		x2 = x1 + (int) ((50 * histo[i]) / hmax);
		y2 = y1;
		do_line (x1, y1, x2, y2);
	}
}




/*------------------------------*/
/*	init			*/
/*------------------------------*/
init ()
{

/*
 *	start up thingies (open windows, clear screens, etc)
 */

	clr_screen ();
	cursor (0);
	do_time (0);

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

	if (hold_scrn)
	{
		mv_cursor (51, 21);  printf (" any key to exit...     ");
		wait_key ();
	}
	cursor (1);

	exit (0);
}




/*------------------------------*/
/*	check_key		*/
/*------------------------------*/
check_key ()
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
/*	set_pixel		*/
/*------------------------------*/
set_pixel (ix, iy)
int	ix;
int	iy;
{

/*
 *	set (draw) a pixel via linea
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

		
	linea1 (A_ptr, ix, iy, 1);
}




/*------------------------------*/
/*	do_line			*/
/*------------------------------*/
do_line (x1, y1, x2, y2)
int	x1, y1, x2, y2;
{

/*
 *	draw a line. uses linea
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

	printf ("\33Y%c%c", (char) (row + ' '), (char) (col + ' '));
	fflush (stdout);

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
long	do_time (opt)
int	opt;				/* 0=init,1=start,2=end (ret elapsed)*/
{

/*
 *	timing functions. here we time using 200 Hz system timer
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

}

