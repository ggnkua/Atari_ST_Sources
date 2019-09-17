/* bitimage.c - Demonstrates use of v_bit_image() function */

#include <vdi.h>
#include <aes.h>

int main( void ) ;

int main( void )
{
	short printer ;
	short workout[57] ;
	short workin[11] = { 21, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2 } ;
	short pxyarray[4] ;
	 
	appl_init() ;								/* Initialise AES			*/
	
	v_opnwk( workin, &printer, workout ) ;		/* Open printer				*/
	
	pxyarray[0] = pxyarray[1] = 0 ;
	pxyarray[2] = workout[0] ;
	pxyarray[3] = workout[1] ;
	
	/* Actually print bitmap. Try changing the five parameters I've 		*/
	/* commented to	how they affect the output								*/
	
	v_bit_image( printer, "sample.img",
							0,					/* Preserve aspect ratio	*/
							0,					/* Integer scaling on x axis*/
							0,					/* Integer scaling on y axis*/
							1,					/* Centre horizontally		*/
							1,					/* Centre vertically		*/
							pxyarray ) ;
	
	v_updwk( printer ) ;
	v_clrwk( printer ) ;						/* Also does form feed		*/
	v_clswk( printer ) ;

	appl_exit() ;

	return 0 ;
}
