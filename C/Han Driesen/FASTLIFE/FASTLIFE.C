/* FASTLIFE, ( c ) 1989 Han Driesen */

#include <tos.h>
#include <stdlib.h>
#include <string.h>
#include <vdi.h>
#include <aes.h>
#include <gem_init.h>

#define maxcells 16000L

char a[640L*102L] ;
char *xy1[maxcells], *xy2[maxcells], **m, **n ;
int k, x, y, w, h, button ;
long screen, xy, h1 ;

struct pnt { char x,y ; } glid_gun[] =
	{
	2,6, 2,7, 3,6, 3,7, 9,6, 10,5, 10,6, 10,7, 11,5, 11,6, 11,7, 13,3,
	13,4, 13,8, 13,9, 14,4, 14,3, 14,8, 14,9, 24,1, 24,7, 25,1, 25,7,
	26,2, 26,6, 27,3, 27,4, 27,5, 36,4, 36,5, 37,4, 37,5, 0,0
	} ;

int delay = 0 ;

#define mark( p ) if ( p < 0 ) *( *--mm = axy ) &= x7F

void blok4( char *xy )
	{
	if ( ( long )xy & 1 )
		{
		xy = ( char * )( ( long )xy >> 1 ) ;
		xy[160] = xy[80] = xy[0] ^= 0x0E ;
		}
	else
		{
		xy = ( char * )( ( long )xy >> 1 ) ;
		xy[160] = xy[80] = xy[0] ^= 0xE0 ;
		}
	}

void blok8( char *xy )
	{
	xy[480] = xy[400] = xy[320] = xy[240] = xy[160] =
	 	xy[80] = xy[0] ^= 254 ;
	}

void blok16( char *xy )
	{
	xy += ( long )xy ;
	*( short * )( xy + 1120 ) =
		*( short * )( xy + 1040 ) =
		*( short * )( xy + 960 ) =
		*( short * )( xy + 880 ) =
		*( short * )( xy + 800 ) =
		*( short * )( xy + 720 ) =
		*( short * )( xy + 640 ) =
		*( short * )( xy + 560 ) =
		*( short * )( xy + 480 ) =
		*( short * )( xy + 400 ) =
		*( short * )( xy + 320 ) =
		*( short * )( xy + 240 ) =
		*( short * )( xy + 160 ) =
		*( short * )( xy + 80 ) =
		*( short * )xy ^= 0xFFFE ;
	}

void ( *blokjes[] )( char * ) = {0, 0, blok4, blok8, blok16} ;

void select( void )
	{
	long mask = 0x1F30008L ;
	char x80 = -0x80,
		**mm = m, **nn = n, *axy, **xy1_ = xy1 + maxcells ;
	while ( mm < xy1_ )
		{
		axy = *mm++ ;
		if ( mask & ( 1UL << *axy ) )
			*--nn = axy ;
		*axy |= x80 ;
		}
	m = mm ;
	n = nn ;
	}

void flip( void )
	{
	char x10 = 0x10, x7F= 0x7F,
		**mm = m, **nn = n, **xy2_ = xy2 + maxcells ;
	long screen1 = screen ;
	void ( *blokje )( char * ) = blokjes[button] ;
	char * axy ;
	while ( nn < xy2_ )
		{
		axy = *nn++ ;
		blokje( axy + screen1 ) ;
		if ( ( *axy ^= x10 ) & x10 )
			{
			mark( ++*--axy ) ;
			axy += 2 ;
			mark( ++*axy ) ;
			axy -= 640 ;
			mark( ++*axy ) ;
			mark( ++*--axy ) ;
			mark( ++*--axy ) ;
			axy += 1282 ;
			mark( ++*axy ) ;
			mark( ++*--axy ) ;
			mark( ++*--axy ) ;
			}
		else
			{
			mark( --*--axy ) ;
			axy += 2 ;
			mark( --*axy ) ;
			axy -= 640 ;
			mark( --*axy ) ;
			mark( --*--axy ) ;
			mark( --*--axy ) ;
			axy += 1282 ;
			mark( --*axy ) ;
			mark( --*--axy ) ;
			mark( --*--axy ) ;
			}
		}
	m = mm ;
	n = nn ;
	}

void flip_1( long xy )
	{
	char *axy ;
	*--n = axy = a + 641L + xy ;
	if ( *axy < 0 )
		*( *--m = axy ) &= 0x7F ;
	flip() ;
	}

void pattern( struct pnt coord[] )
	{
	while ( coord->x )
		{
		flip_1( coord->x + ( h - 1 - coord->y ) * 640L ) ;
		coord++ ;
		}
	flip() ;
	}

int wait( void )
	{
	int sym, counter = 0 ;
	while ( 1 )
		{
		if ( Cconis() )
			{
			sym = ( int )Crawcin() ;
			if ( sym >= '0' && sym <= '9' )
				delay = 256 >> ( '9' - sym ) ;
			else
				return 0 ;
			}
		if  ( ++counter > delay )
			return 1 ;
		Vsync() ;
		}
	}

int main()
	{
	char *axy ;
	gem_init() ;
	v_hide_c( handle ) ;
	graf_mouse( 0, 0 ) ;
	Cconws( "\033E\015" ) ;
	Cconws( "\033Y\070\076Han Driesen, \275 1989" ) ;
	do
		{
		v_show_c( handle, 0 ) ;
		button = form_alert( 2, "[0][  FASTLIFE  | in Turbo C |"
			" |Celgrootte... ][4|8|16]" ) + 1 ;
		v_hide_c( handle ) ;
		Cconws( "\033E\015" ) ;
		h = 400 >> button ;
		w = 640 >> button ;
		h1 = 640L * ( h + 1 ) ;

		memset( a, -128, h1 ) ;
		
		for ( xy = 1 ;  xy <= w ;  ++xy )
			a[xy] = a[xy + h1] = 0 ;

		for ( xy = 0 ;  xy <= h1 ;  xy += 640L )
			a[xy] = a[xy + w + 1] = 0 ;

		axy = Logbase() ;
		screen = ( ( ( long )axy << 3 ) >> button ) - ( long )a - 641L ;
		for ( y = 1 ;  y <= h ;  y++ )
			switch ( button )
				{
			case 2:
				axy += 320 ;
				for ( x = 80 ;  x > 0 ;  --x )
					axy[-x] = 0x11 ;
				break ;
			case 3:
				axy += 640 ;
				for ( x = 80 ;  x > 0 ;  --x )
					axy[-x] = 1 ;
				break ;
			case 4:
				axy += 1280 ;
				for ( x = 79 ;  x > 0 ;  x -= 2 )
					axy[-x] = 1 ;
				break ;
				}

		m = xy1 + maxcells ;
		n = xy2 + maxcells ;

		v_show_c( handle, 0 ) ;
		do
			{
			if ( Cconis() && ( Cnecin() & 0xDF ) == 'G' )
				pattern( glid_gun ) ;
			
			vq_mouse( handle, &k, &x, &y ) ;
			if ( k & 1 )
				{
				v_hide_c( handle ) ;
				xy = ( y >> button ) * 640L + ( x >> button ) ;
				flip_1( xy ) ;
				v_show_c( handle, 0 ) ;
				do
					vq_mouse( handle, &k, &x, &y ) ;
				while ( k & 1 &&
					 ( y >> button ) * 640L + ( x >> button ) == xy ) ;				
				}
			}
		while ( ( k & 2 ) == 0 ) ;
		v_hide_c( handle ) ;

		while ( Cconis() )
			Cnecin() ;

		while ( wait() )
			{
			select() ;
			flip() ;
			}

		v_show_c( handle, 0 ) ;
		button = form_alert( 1, "[2][Nogmaals?][Ja|Nee]" ) ;
		v_hide_c( handle ) ;
		Cconws( "\033E\015" ) ;
		}
	while ( button == 1 ) ;

	return 0 ;
	}
