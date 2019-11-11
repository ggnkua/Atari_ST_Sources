/*******************************************************************************

Program: julia.ttp
   Desc: Julia Set Display program
 Author: Roy Stead
Created:  1/3/91

 Rights: This source code is (c)opyright March 1992 by Roy Stead, but may be
	 distributed freely so long as this entire file remains unmodified and
	 no more than a reasonable amount for disk copying is charged.

	 Any bug reports and/or suggestions for improvement should be sent to:

			Roy Stead,
			34 Cherry Sutton,
			Hough Green,
			Widnes,
			Cheshire WA8 9TN.

Compile with:       cc -f julia.c

Use with:           julia [-help][<real> [<imaginary>]]

Plots the Julia Set for the given number '<real> + <imaginary>i'

julia uses 6000 iterations in plotting the Julia Set using
the inverse iterations method, as described  on page 154 of Michael Barnsley's
excellent manual, _The Science of Fractal Images_ [Springer-Verlag, 1988].

If no number is given, julia uses default, 0.200000 + 0.300000i.
If only the real part is given, julia assumes imaginary part is zero. Thus:

julia             Plots default Julia Set (0.200000 + 0.300000i)
julia -1.0        Plots Julia Set for value -1.0 + 0.0i
julia 1.2 0.3     Plots Julia Set for value 1.2 + 0.3i
julia -help       Reproduces this information

Some more suggestions for sets to look at are:

julia -2.0
julia 0.0
julia 0.0 1.0


Revision History:

 Date		By	Comments

*******************************************************************************/

#include <stdio.h>			/* STandarD Input/Output	*/
#include <osbind.h>			/* Operating System BINDings	*/
#include <malloc.h>			/* Memory ALLOCation functions	*/
#include <string.h>			/* STRING handling functions	*/
#include <math.h>			/* MATHematical functions	*/

#ifdef PROGNAME
#undef PROGNAME
#endif
#define PROGNAME	"julia"		/* Name of this program		*/
char *myname;


#define SCRN_W		640L		/* Screen area bounds		*/
#define Y_OFFSET	10L
#define SCRN_H		(200L - Y_OFFSET)

#define ITERATIONS	6000L		/* Number of iterations to use	*/

#define REAL		0.2		/* Default real	part		*/
#define IMAGINARY	0.3		/* Default imaginary part	*/

float	real;				/* Real part of number to use	*/
float	imaginary;			/* Complex part of number to use*/


WORD	*scrnstart;			/* Ptr to base of video memory	*/


main ( argc, argv, envp )
int argc;
char *argv[];
char *envp;
{
int rand();			/* Returns random integer		*/
register float x;		/* Real value of number in set		*/
register float y;		/* Imaginary value of number in set	*/
register LONG n;		/* General looping variable		*/
register LONG px;		/* Horizontal coord of pixel to plot	*/
register LONG py;		/* Vertical coord of pixel to plot	*/
int kbhit();			/* Returns non-zero if a key is pressed	*/


myname = strdup ( PROGNAME );	/* Assign name of this program		*/

if ( Getrez() != 1 )		/* Check screen resolution		*/
	{
	printf ("%s: Must be in medium resolution to run\n", myname);

	while ( !kbhit() )	/* Wait for key press			*/
		;

	exit ( 1 );		/* Exit program				*/
	};

scrnstart = Physbase();		/* Get start of video memory		*/

Setscreen ( (long) scrnstart, (long) scrnstart, 1 );	/* Clear screen	*/


/* If there are arguments, use their values				*/
if ( argc > 1 )
	{
	if ( stricmp ( &argv[1][0], "-help" ) == 0 )	/* -help flag	*/
		julia_help();
	else
		real = atof ( &argv[1][0]);	/* Real part of number	*/

	if ( argc > 2 )
		imaginary = atof ( &argv[2][0] );	/* Imaginary bit*/
	else
		imaginary = 0.0;	/* Only real value given, so imaginary*/
	}				/* Part is assumed to be zero	      */
else
	{
	real = REAL;			/* No arguments, so use default	      */
	imaginary = IMAGINARY;
	};


/* Display complex number whose Julia Set we are drawing		*/
printf ("Julia set for complex number %f + %fi : ", real, imaginary);

/* Get random starting point within the Julia set			*/
x = (float) ( rand() % SCRN_W ) / (float) SCRN_W;
y = (float) ( rand() % SCRN_H ) / (float) SCRN_H;
for ( n = 0; n < 8; n++)
	next_point ( &x, &y );


/* Main loop								*/
for ( n = 0; n < ITERATIONS; n++ )
	{
	next_point ( &x, &y );		/* Get next point in set	*/

	/* Translate floating point coordinates to valid screen coordinates.
	*/
	px = (LONG) ( -5 + ( ( x + 4 ) * SCRN_W / 8 ) );
	py = (LONG) ( ( 2 - y ) * SCRN_H / 4 );

	plot ( px, py );		/* Plot point			*/

	/* Every 1000 iterations, display number of iterations so far	*/
	if ( ! ( n % 1000 ) )
		printf ("%5ld\b\b\b\b\b", n);

	};

/* Completion message							*/
printf ("Completed %ld iterations", ITERATIONS );

while ( !kbhit() )	/* Wait for key press				*/
	;
};


/*******************************************************************************
next_point()	-	Takes pointers to floating point coordinates (*x and *y)
			and calculate next point in julia set.
*******************************************************************************/

next_point (x, y)
float *x;			/* Ptr to real part of current number	*/
float *y;			/* Ptr to imaginary part of current num	*/
{
int rand();			/* Returns random integer		*/
int rnum = rand() % 2;		/* Get random number ( 0 or 1 )		*/
float wx, wy, theta, r;		/* Used for calculations below		*/

/* This bit actually calculates a point within the Julia Set, based on
 * The inverse iterations method given on page 154 of Michael Barnsley's
 * _The Science of Fractal Images_ [Springer-Verlag, 1988].
 */
wx = *x - real;
wy = *y - imaginary;

if ( wx < 0 )
	theta = atan ( wy / wx );
else if ( wx > 0 )
	theta = atan ( wy / wx ) + M_PI;
else
	theta = M_PI / 2;

theta /= 2;

r = sqrt ( wx * wx + wy * wy );
if ( rnum )
	r = sqrt ( r );
else
	r = - sqrt ( r );

*x = r * cos ( theta );
*y = r * sin ( theta );

};


/*******************************************************************************
plot ()	-		Plots a single point (x,y) on the screen in Medium 
			resolution (640x200), by directly accessing the video 
			memory.

			Note that x is the horizontal coordinate, while y is
			the vertical one, with (0,0) being the screen's top left
*******************************************************************************/

plot (x, y)
register LONG x;		/* x-coordinate of pixel to plot/erase	*/
register LONG y;		/* y-coordinate of pixel to plot/erase	*/
{
register WORD *address;		/* Pointer to physical location of pixel*/
register WORD bit_mask;		/* Bit mask to use to set / unset pixel	*/


/* Check bounds on plot coordinates and display coordinates of any points 
 * which exceed required bounds.
 * 
 */

char *statstr;			/* Status line string			*/
int n;				/* Status line counter			*/

if (x < 0 || x > SCRN_W || y < 0 || y > (SCRN_H + Y_OFFSET) )
	{

	/* Note - in medium resolution, 
	 * this status line must be 79 characters long at most
	 */
	statstr = malloc ( 80 );			/* Allocate mem	*/

	n = sprintf (statstr, "Bounds exceeded ");	/* Constuct str	*/
	n += sprintf (statstr + n, "plotting at <%03ld, %03ld>         ", x, y);

	n = printf ( statstr );				/* Display str	*/
	free ( statstr );				/* Reclaim mem	*/

	for ( ; n > 0; n-- )
		printf ("\b");

	return ;					/* Exit function*/

	};


/* Get address of word of screen memory which contains bit to plot.
 *
 * This address is calculated as an offset from the start of video memory:
 *	vertical   = 80 * y   (640 dots per line * 2 planes / 16 bits per word)
 *	horizontal = x >> 4   (16 bits per word)
 *		       << 1   (2 planes, so only every other word pointed to)
 */

address = scrnstart + ((x >> 4) << 1) + 80 * y;

/* Plot pixel								*/
bit_mask = (WORD) ( 0x00008000L >> (x % 16) );
*address |= bit_mask;
address++;
*address |= bit_mask;

};


/*******************************************************************************
julia_help()	-	Provides a little help for julia program
*******************************************************************************/

julia_help()
{
int kbhit();			/* Returns non-zero if a key is pressed	*/


printf ("      Julia Set Plotting Program ");
printf ("by Roy Stead - (UK) (051) 423 1965\n\n");


printf ("Use with:           %s [-help][<real> [<imaginary>]]\n\n", myname);

printf ("Plots the Julia Set for the given number '<real> + <imaginary>i'\n\n");

printf ("%s uses %ld iterations in ", myname, ITERATIONS);
printf ("plotting the Julia Set using\n");
printf ("the inverse iterations method, as described  on page 154 of ");
printf ("Michael Barnsley's\n");
printf ("excellent manual, _The Science of Fractal Images_ ");
printf ("[Springer-Verlag, 1988].\n\n");

printf ("If no number is given, %s uses the default,", myname );
printf (" %f + %fi.\n", REAL, IMAGINARY );
printf ("If only the real part is given, ");
printf ("%s assumes the imaginary part is zero. Thus:\n\n", myname);

printf ("%s             Plots default Julia Set ", myname);
printf ("(%f + %fi)\n", REAL, IMAGINARY);
printf ("%s -1.0        Plots Julia Set for value -1.0 + 0.0i\n", myname);
printf ("%s 1.2 0.3     Plots Julia Set for value 1.2 + 0.3i\n", myname);
printf ("%s -help       Reproduces this information\n\n", myname);

printf ("Some more suggestions for sets to look at are:\n\n");

printf ("%s -2.0\n%s 0.0\n%s 0.0 1.0\n", myname, myname, myname );

while ( !kbhit() )	/* Wait for key press				*/
	;

exit ( 0 );		/* Exit program					*/

};
