/***********************************************************
* A DEMONSTRATION OF THE USE OF ST SPRITES FROM C  USING   *
* METACOMCO LATTICE-C WITH THE LINE-A BINDINGS IN GLIB.BIN *
*		by Andy Beveridge 27/3/86		   *
***********************************************************/

#include	<stdio.h>	/* standard I/O header	    */
#include	<portab.h>	/* portability macros	    */

#define		ESC	0x1b	/* hex constant for <esc> */

	/* sprite definition block */
 WORD	sprdef[] = { 8, 8, -1, 0, 1,
			0,0x03c0, 0,0x0ff0, 0,0x1ff8, 0,0x3ffc,
			0,0x7ffe, 0,0x7ffe, 0,0xf3cf, 0,0xf3cf,
			0,0xffff, 0,0xffff, 0,0x7ffe, 0,0x7bde,
			0,0x3c3c, 0,0x3ffc, 0,0x0ff0, 0,0x03c0 } ;

 WORD	sprsav[40];	/* space to save background for undraw */

 extern	a_sprite(), a_unsprite();    /* external sprite bindings in GLIB */

main()
{
	WORD	xpos, ypos, xv, yv;

	putch( ESC );	putch('E');	/* clear screen */

	xpos = 320;	ypos = 200;
	xv = 3;		yv = 2;

	while( !kbhit() )	/* while no key pressed */
	{
		a_sprite( xpos, ypos, sprdef, sprsav );	/* draw sprite */
		xpos += xv;
		ypos += yv;

	/* now check if it has to bounce */

		if( (xpos < 16) || (xpos > 623) )
			xv = -xv;
		if( (ypos < 16) || (ypos > 383) )
			yv = -yv;

		xbios(37);	/* use xbios to wait for blanking */
		a_unsprite( sprsav );	/* undraw sprite */
	}

}
