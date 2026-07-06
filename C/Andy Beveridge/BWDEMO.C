/********************************************************
*                                                       *
* This C program is an example of the use of assembler  *
* modules with C. The object file from this compilation *
* must be linked with the line-A binding GLIB.BIN to    *
* allow access to the line-A primitives from C.         *
*                                                       *
*        Written by Andy Beveridge   15/12/85           *
*                                                       *
********************************************************/

#include <stdio.h>		/* standard include files from the */
#include <portab.h>		/*        compiler disk            */

#define XMIN 8
#define XMAX 311
#define YMIN 8
#define YMAX 191

 extern	a_init(), a_line();	/* the line-A graphics bindings     */
 extern double	drand48();	/* using drand cos it's more random */

 WORD	xpos[40],ypos[40],xvel[40],yvel[40];

main()
{
	long	oldn,npoints,follow,tmoves;	/* cos scanf() gets an int */
	WORD	moves,n;

	putch(27); putch('c'); putch('1');	/* bg color */
	putch(27); putch('b'); putch('0');	/* fg color */

   do {
	putch(27); putch('E');			/* clear screen */

/*	do {
		puts("\nHow many points (2 to 8) ?");
		scanf("%ld", &npoints);		/* must get it as a long */
	} while(npoints<0 || npoints>20);

	do {
		puts("\nTrail length ?");
		scanf("%ld", &follow);
	} while(follow<0);

	do {
		puts("\nMoves per screen ?");
		scanf("%ld", &tmoves);
	} while(tmoves<0);
*/
	npoints = 4;	/* If you comment out these 3 lines and */
	follow = 80;	/* de-comment the above, you can enter  */
	tmoves = 800;	/* different values at runtime		*/

	oldn = npoints;

	a_init();
	a_color(1);

	srand48(0x375a276f);

	for(n=0; n<npoints; n++){
		xpos[n+npoints] = xpos[n] = (WORD) (drand48() * 280 + 10);
		ypos[n+npoints] = ypos[n] = (WORD) (drand48() * 160 + 10);
		xvel[n+npoints] = xvel[n] = (WORD) (drand48() * 4 + 2);
		yvel[n+npoints] = yvel[n] = (WORD) (drand48() * 4 + 2);
	}	/* set initial values */

	if( npoints > 3 ){
		xpos[npoints*2-1] = xpos[npoints-1] = xpos[0];
		ypos[npoints*2-1] = ypos[npoints-1] = ypos[0];
		xvel[npoints*2-1] = xvel[npoints-1] = xvel[0];
		yvel[npoints*2-1] = yvel[npoints-1] = yvel[0];
	}	/* tie ends together */

	putch(27); putch('f');		/* hide cursor */


	do {

		putch(27); putch('E');	/* clear screen */

		for(moves=0; moves<tmoves; moves++){

			if( moves == follow ){
				putch(7);
				npoints = oldn * 2; /* double it */
			}

			for(n=0; n<npoints; n++){

				xpos[n] += xvel[n];
				if( xpos[n]<XMIN || xpos[n]>XMAX ){
					xpos[n] -= xvel[n];
					xvel[n] = -xvel[n];	/* reverse   */
					putch(7);		/* ring bell */
				}

				ypos[n] += yvel[n];
				if( ypos[n]<YMIN || ypos[n]>YMAX ){
					ypos[n] -= yvel[n];
					yvel[n] = -yvel[n];
					putch(7);
				}
			}

			a_color(0);
			for(n=0; n<(npoints-1); n++){
				if( n == oldn-1 ){
					n++;	/* skip middle pair */
					a_color(1);
				}
	a_line(    xpos[n],     ypos[n],     xpos[n+1],     ypos[n+1]);
	a_line(639-xpos[n], 399-ypos[n], 639-xpos[n+1], 399-ypos[n+1]);
	a_line(639-xpos[n],     ypos[n], 639-xpos[n+1],     ypos[n+1]);
	a_line(    xpos[n], 399-ypos[n],     xpos[n+1], 399-ypos[n+1]);
			}

		}		/* close the moves loop		*/
	} while( ! kbhit() );	/* close the forever loop	*/
   } while( (getch() & 0xff) == 'r' );	/* if pressed 'r' then restart	*/

}				/* close main			*/
