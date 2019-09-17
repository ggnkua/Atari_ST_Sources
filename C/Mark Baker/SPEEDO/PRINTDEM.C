#include <stdio.h>
#include <vdi.h>
#include <aes.h>

int main( void ) ;

int main( void )
{
	short prn = 0 ;								/* Printer handle			*/
	short workin[] = { 21,1,1,1,1,1,1,1,1,1,2 } ;
	short workout[57] ;
	short extend[57] ;
	short font_id ;								/* Index of first font		*/
	char fontname[33] ;							/* Name of font				*/
	short ch ;									/* Text line spacing		*/
	short dummy ;								/* Dummy return				*/
	short pxy[4] ;								/* Array of coordinates		*/
	int x, y ;
	int xres, yres ;							/* Resolution (Pels per cm)	*/
	int cm ;
	char str[50] ;								/* Buffer for strings		*/
	
	appl_init() ;
	v_opnwk( workin, &prn, workout ) ;			/* Open workstation			*/
	if( !prn )
	{
		appl_exit() ;							/* Exit if open failed		*/
		return 1 ;
	}
	
	vq_extnd( prn, 1, extend ) ;				/* Get extended information	*/
	vst_load_fonts( prn, 0 ) ;					/* Load font headers		*/
	
	xres = 10000 / workout[3] ;					/* Calculate x pixels per cm*/
	yres = 10000 / workout[4] ;					/* Calculate y pixels per cm*/
	
	font_id = vqt_name( prn, 2, fontname ) ;	/* Get id of first font		*/
	vst_font( prn, font_id ) ;					/* Set font to that			*/
	vst_point( prn, 10, &dummy, &dummy, &ch, &dummy ) ;	/* Use 10pt font	*/
	
	pxy[0] = pxy[2] = workout[0] / 2 ;
	pxy[1] = 0 ;
	pxy[3] = workout[1] ;
	v_pline( prn, 2, pxy ) ;					/* Draw vertical rule		*/
	
	pxy[0] -= 20 ;
	pxy[2] += 20 ;
	for( y=0, cm=0; y<=workout[1]; cm++, y+=yres )
	{
		pxy[1] = pxy[3] = y ;
		v_pline( prn, 2, pxy ) ;				/* Graduations on vert scale*/
		
		sprintf( str, "%d", cm ) ;				/* Print number				*/
		v_gtext( prn, workout[0] / 2 + 25, y, str ) ;
	}
	
	pxy[1] = pxy[3] = workout[1] / 2 ;
	pxy[0] = 0 ;
	pxy[2] = workout[0] ;
	v_pline( prn, 2, pxy ) ;					/* Draw horizontal rule		*/
	
	pxy[1] -= 20 ;
	pxy[3] += 20 ;
	for( x=0, cm=0; x<=workout[0]; cm++, x+=xres )
	{
		pxy[0] = pxy[2] = x ;
		v_pline( prn, 2, pxy ) ;				/* Graduations on vert scale*/
		
		sprintf( str, "%d", cm ) ;				/* Print number				*/
		v_gtext( prn, x, workout[1] / 2 - 25, str ) ;
	}

	if( extend[19] )							/* If print area offsets on	*/
	{
		x = extend[45] ;						/* Top left of print area 	*/
		y = extend[46] ;
	}
	else
	{
		x = 0 ;									/* Else start at origin		*/
		y = 0 ;
	}

	sprintf( str, "Size in pixels %d x %d", workout[0], workout[1] ) ;
	v_gtext( prn, x, y += ch, str ) ;
	
	sprintf( str, "Pixel size in æm %d x %d", workout[3], workout[4] ) ;
	v_gtext( prn, x, y += ch, str ) ;

	sprintf( str, "Size in mm %d x %d", workout[0] * workout[3] / 1000,
										workout[1] * workout[4] / 1000 ) ;
	v_gtext( prn, x, y += ch, str ) ;

	sprintf( str, "Print area offsets %s", extend[19] ? "on" : "off" ) ;
	v_gtext( prn, x, y += ch, str ) ;

	sprintf( str, "Printable area (%d,%d) to (%d,%d)", extend[45], extend[46],
													extend[47], extend[48] ) ;
	v_gtext( prn, x, y += ch, str ) ;

	vst_unload_fonts( prn, 0 ) ;
	v_clswk( prn ) ;
	appl_exit() ;
	return 0 ;
}
