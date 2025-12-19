/*
   Note: This is a clip from Ray Tracing News...
   This was the basis of my shellgen.bas program.
   The output is in generic NFF format, but is easily changed to any other
   script format.


    A related book that just came out is "Computers, Pattern, Chaos, and
Beauty" by Clifford Pickover (St. Martin's Press).  At first I thought this
was just another fractal book, but there are many other functions and
algorithms explored here.  This book is something like a collection of
"Computer Recreations" columns, and is worth checking out.  One topic mentioned
in the book is creating sea shells by a series of spheres.  This was also
covered in the IEEE CG&A November 1989 article, pages 8-11.  Here's a code
fragment that outputs a series of spheres in NFF (I leave a good view & lights
& colors to you).  Cut the number of steps way down for a rough idea where
the surface is located, and have fun playing with the various numbers and
formulae.

DKB - I've changed the format to output a simple DKB script.
*/

#include <stdio.h>
#include <math.h>

#ifndef M_PI
#define M_PI 3.1415926535897932384626
#endif

main(argc,argv)
int argc;  char *argv[];
{
static	double	gamma = 1.0 ;	/* 0.01 to 3 */
static	double	alpha = 1.1 ;	/* > 1 */
static	double	beta = -2.0 ;	/* ~ -2 */
static	int	steps = 600 ;	/* ~number of spheres generated */
static	double	a = 0.15 ;	/* exponent constant */
static	double	k = 1.0 ;	/* relative size */
double	r,x,y,z,rad,angle ;
int	i ;

    printf ("OBJECT\n   UNION\n");
    for ( i = -steps*2/3; i <= steps/3 ; ++i ) {
	angle = 3.0 * 6.0 * M_PI * (double)i / (double)steps ;
	r = k * exp( a * angle ) ;
	x = r * sin( angle ) ;
	y = r * cos( angle ) ;
	/* alternate formula: z = alpha * angle */
	z = beta * r ;
	rad = r / gamma ;

	printf( "      SPHERE <%g %g %g> %g END_SPHERE\n", x, y, z, rad ) ;
    }
    printf ("   END_UNION\n");
    printf ("   TEXTURE\n");
    printf ("      AMBIENT 0.3\n");
    printf ("      DIFFUSE 0.7\n");
    printf ("      PHONG 1.0\n");
    printf ("      COLOUR RED 1.0 GREEN 0.498939 BLUE 0.0 { Coral }");
    printf ("      PHONGSIZE 20.0\n");
    printf ("   END_TEXTURE\n");
    printf ("END_OBJECT\n");
}
