/*******************************************************************************

Program: fern.prg
   Desc: Fern IFS Display program
 Author: Roy Stead
Created: 2/3/91

 Rights: This source code is (c)opyright March 1992 by Roy Stead, but may be
	 distributed freely so long as this entire file remains unmodified and
	 no more than a reasonable amount for disk copying is charged.

	 Any bug reports and/or suggestions for improvement should be sent to:

			Roy Stead,
			34 Cherry Sutton,
			Hough Green,
			Widnes,
			Cheshire WA8 9TN.

Compile with:	cc -f [-DNO_KBD [-DITERATIONS=xxx]] [-DDEBUG] fern.c

Preprocessor:	NO_KBD		Compile with fixed No of iterations
     symbols:			(No keyboard commands accessible)

		DEBUG		Check bounds on plot coordinates

		ITERATIONS=xxx	No of iterations to use if NO_KBD defined
				(If not defined, default is 10000)


If keybd interrupts enabled (NO_KBD not defined):

Key	Operation

q	Quit program
n or i	Switch on display of iteration number
other	Switch off display of iteration number


Revision History:

 Date		By	Comments

  2/3/92	RS	Deleted command-line option for Sierpinski Triangle
 28/2/92	RS	Threw it together in half an hour. It's not elegant or
			generalised, but it serves as a demonstration.

*******************************************************************************/

#include <stdio.h>			/* STandarD Input/Output	*/
#include <osbind.h>			/* Operating System BINDings	*/
#include <malloc.h>			/* Memory ALLOCation functions	*/
#include <math.h>			/* MATHematical functions	*/
#include <string.h>			/* STRING functions		*/

#define SCRN_W		640L		/* Screen area bounds		*/
#define Y_OFFSET	10L
#define SCRN_H		(200L - Y_OFFSET)

#ifdef NO_KBD
#ifndef ITERATIONS
#define ITERATIONS	10000L
#endif
#endif

WORD	*scrnstart;			/* Ptr to base of video memory	*/


main ()
{
int rand();
register float x = (float) ( rand() % SCRN_W ) / (float) SCRN_W;
register float y = (float) ( rand() % SCRN_H ) / (float) SCRN_H;
register LONG n;				/* General looping var	*/
register LONG px;				/* Coords of pxl to plot*/
register LONG py;
#ifndef NO_KBD
char c = 'n';			/* Code of key pressed by user		*/
int kbhit(), getch();		/* Keyboard handling functions		*/
#endif

scrnstart = Physbase();			/* Get start of video memory	*/

Setscreen ( (long) scrnstart, (long) scrnstart, 1 );	/* Clear screen	*/

for ( n = 0; n < 8; n++)		/* Get random starting point	*/
	transform ( &y, &x );

#ifndef NO_KBD
while ( c != 'q' )			/* Loop until 'q' pressed	*/
#else
for ( n = 0; n < ITERATIONS; n++ )
#endif
	{
	transform ( &y, &x );		/* Perform random re-mapping	*/

	/* Translate floating point coordinates to valid screen coordinates.
	 * Note that x and y are reversed on screen to show image horizontally
	 */
	px = (LONG) (x * SCRN_W / 10);
	py = (LONG) (y * SCRN_H / 5) + SCRN_H / 2 + Y_OFFSET;

	plot (px, py);			/* Plot point			*/

#ifndef NO_KBD
	/* If key pressed, get its scan code				*/
	if ( kbhit() )
		c = (char) getch();

	if ( c == 'n' || c == 'i' )
		printf (" %-7ld\b\b\b\b\b\b\b\b", n);	/* Show iteration No  */

	n++;
#endif
	};

};


/*******************************************************************************
transform()	-	Takes pointers to floating point coordinates (*x and *y)
			and select and perform random transformation on point.

			If you want to generalise this program, then this is the
			function to ammend. I'd suggest using a struct for the
			individual IFS mappings, and an array of such struct's
			for the overall IFS, with this function taking an extra
			argument (perhaps) to say which mapping to use from the
			array and performing matrix multiplication using the
			chosen struct's contents.
*******************************************************************************/

transform (x, y)
float *x;
float *y;
{
int rand();
int rnum = rand() % 100;	/* Select random mapping to perform	*/
if ( rnum > 75 )
	rnum = 3;
else if ( rnum > 50 )
	rnum = 2;
else if ( rnum > 25 )
	rnum = 1;
else
	rnum = 0;


switch ( rnum )			/* Perform random mapping		*/
	{
	case 0:

		*x = 0.0;
		*y = *y * 0.16;

		break;

	case 1:

		*x = *x * 0.85 * cos ( -0.0436332 ) - *y * 0.85 * sin ( -0.0436332);
		*y = *x * 0.85 * sin ( -0.0436332 ) + *y * 0.85 * cos ( -0.0436332 ) + 1.6;

		break;

	case 2:

		*x = *x * 0.3 * cos (0.8552113) - *y * 0.3 * sin (0.8552113);
		*y = *x * 0.3 * sin (0.8552113) + *y * 0.3 * cos (0.8552113) + 1.6;

		break;

	case 3:

		*x = *x * 0.3 * cos (2.0943951) - *y * 0.37 * sin ( -0.8726646);
		*y = *x * 0.3 * sin (2.0943951) + *y * 0.37 * cos ( -0.8726646)+ 0.44;

		break;

	default:		/* Random number bounds exceeded	*/

		printf ("fern: Error in random number (%d)\n", rnum);

		exit ( 1 );

		break;
	};
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


#ifdef DEBUG
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
#endif

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
