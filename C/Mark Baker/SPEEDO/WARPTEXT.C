/* warptext.c - Demonstrates warping text using Speedo	*/

#include <aes.h>
#include <vdi.h>

#include <math.h>

int main( void ) ;								/* Prototypes				*/
void transform ( short *x, short *y ) ;

char message[] = "Hello world" ;
short workout[57] ;

int main( void )
{
	short printer ;
	short workin[11] = { 21, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2 } ;

	char fontname[33] ;
	int font_id ;

	short dummy ;								/* Dummy variables			*/
	void *pdummy ;
		
	short xyarray[200] ;						/* Bezier information		*/
	char bezarray[100] ;
	short verts ;
	short extent[4] ;

	char *ch ;									/* Pointer to character		*/
	short x = 0 ;								/* Untransformed X position	*/
	fix31 advx, advy, offx, offy ;
	int i ;										/* Loop index				*/


	
	appl_init() ;								/* Initialise application	*/

	v_opnwk( workin, &printer, workout ) ;		/* Open workstation			*/
	vst_load_fonts( printer, 0 ) ;
	
	font_id = vqt_name( printer, 2, fontname ) ;/* Get id of first font		*/
	vst_font( printer, font_id ) ;				/* Set font to that			*/
	vst_point( printer, 72, &dummy, &dummy, &dummy, &dummy ) ;
												/* Use 72pt font			*/

	ch = message ;
	
	while( *ch )
	{
		v_getoutline( printer, *ch, xyarray, bezarray, 100, &verts ) ;
												/* Get outline of character	*/
		v_getbitmap_info( printer, *ch, &advx, &advy, &offx, &offy,
						&dummy, &dummy, (void *)&pdummy ) ;
												/* Get offsets				*/

		for( i = 0; i < verts ; i++ )
		{
			xyarray[2*i] += x ;						/* Adjust x				*/
			xyarray[2*i+1] -= *(short *)&offy ;		/* Adjust y				*/
			
			transform( &xyarray[ 2 * i ], &xyarray[ 2 * i + 1 ] ) ;
		}

		v_bez( printer, verts, xyarray, bezarray, extent, &dummy, &dummy ) ;

		ch++ ;									/* Next character			*/
		x += advx>>16 ;							/* Position of next char	*/
	}

	v_updwk( printer ) ;
	v_clrwk( printer ) ;
	v_clswk( printer ) ;
	
	appl_exit() ;
	
	return 0 ;
}

/* Warp text by transforming coordinates of point */

/* This one wraps it round a circle	*/

void transform( short *x, short *y )
{
	float r, angle ;
	
	r = workout[0] / 4 - *y ;					/* Calculate radius from r	*/
	angle = 3.142 - *x * 0.003 ;		/* Angle = pi - some fraction of x	*/

	*x = r * cos( angle ) + workout[0] / 2 ;
	*y = - r * sin( angle ) + workout[1] / 2 ;
}
