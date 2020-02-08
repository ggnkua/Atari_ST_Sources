# define LINEheader		1

# define COMPRESS_TYPE	int
# define TYPEmax		32767

#include <stdio.h>
#include <stdlib.h>
#include <ext.h>
#include <tos.h>
#include <string.h>


# include "..\gp_lib.h"

# include "gp_snap.h"

PALETTE cxx_palette ;

/*--------------------------------------------- save_moc_palette ----*/
byte *save_moc_palette(byte *buffer)
/* on entry	: *in_buffer points to start of palette area,
						 ( byte sequence : dummy, r, g, b, ... )
   on exit	: *in_buffer points behind palette area				*/
{
	int	 entry ;
	byte *in ;
	
	save_palette ( &cxx_palette ) ;
	
	in = &cxx_palette[0].r ;
	
	for(entry=0;entry<=MAX_COLOR;entry++)
	{
		*buffer++ = 0 ;				/* dummy */
		*buffer++ = *in++ ;
		*buffer++ = *in++ ;
		*buffer++ = *in++ ;
	}
	return(buffer) ;
} /*- save_moc_palette -*/


# define START		0
# define RESTART	1
# define EQU		2
# define NEQ		3

# if TEST
long equ_sequ = 0 ;
long neq_sequ = 0 ;
# endif


/*--------------------------------------------- compress_line ----*/
byte *compress_line( byte *source, byte *dest, int length )
{
	COMPRESS_TYPE *sp,*dp,*cp ;
	COMPRESS_TYPE a, b ;
	
	int count, state ;

	state = START ;
	sp = (COMPRESS_TYPE *)source ;
	dp = (COMPRESS_TYPE *)dest ;
	b = 0 ;

# if LINEheader
	*dp++ = 0x8000 ;
# endif
	
	for ( ; length > 0; length -= (int)sizeof(COMPRESS_TYPE)  )
	{
		a = b ;				/* look ahead sequence	: ... a b */
		b = *sp++ ;

		switch ( state )
		{
 case START :	state = RESTART ;	/* read only lookahead : 0 a */
				break ;

 case RESTART :	if ( a == b )		/* here we have : .. a b	*/
				{
					state = EQU ;
					count = -1 ;	/* 2 equal bytes found	*/
# if TEST
	equ_sequ++ ;
# endif
				}
				else
				{
					state = NEQ ;
					count = 0 ;		/* 1 unequal byte found	*/
					cp = dp ;		/* save and skip count position	*/
					*dp++ = count ;
					*dp++ = a ;		/* save first data byte	*/
# if TEST
	neq_sequ++ ;
# endif
				}
				break ;
				
 case EQU :		if ( a == b && count > -TYPEmax )
				{
					count-- ;		/* another equal byte found	*/
				}
				else	/* finish equal sequence : a .. a b	*/
				{
					*dp++ = count ;
					*dp++ = a ;			/* save data byte	*/

					state = RESTART ;
				}
				break ;
				
 case NEQ :		/* sequence .. x y z b a .. */
				if ( a != b && count < TYPEmax )
				{
					count++ ;		/* another unequal byte found	*/
					*dp++ = a ;		/* save last byte	*/
				}
				else /* a == b */	/* finish unequal sequence	*/
				{
					*cp   = count ;	/* update count in output buffer */
					state = EQU ;
					count = -1 ;	/* 2 equal bytes found	*/
				}
				break ;
		}
	}
	
	switch ( state )
	{
 case RESTART :	/* one byte in buffer a	*/
			*dp++ = 0 ;
			*dp++ = a ;
 			break ;
 			
 case EQU :	/* finish equal sequence	*/
			*dp++ = count ;
			*dp++ = a ;
			break ;
				
 case NEQ :	/* finish unequal sequence, one byte left in a	*/
			count++ ;
			*dp++ = a ;
			
			*cp   = count ;	/* update count in output buffer */
			break ;
	}
	
	return ( (byte *) dp ) ;
}



/*--------------------------------------------- uncompress_line ----*/
byte *uncompress_line( byte *source, byte *dest, int length )
{
	int *sp,*dp ;
	int a, b, words ;
	
	sp = (int *)source ;
	dp = (int *)dest ;

	if ( (unsigned)*sp == 0x8000 )	/* skip lineheader	*/
		sp++ ;
	
	words = length / 2 ;
	while ( words > 0 )
	{
	 	a = *sp++ ;
	 	if ( a < 0 )	/* a < 0 : equal sequence	*/
	 	{
	 		if ( (unsigned)a == 0x8000 )
	 		{
	 			printf ( "format: lin %#8.8lx, pos %#8.8lx\n, scrlin %#8.8lx, key!\n",
	 						source, sp-1, dest ) ;
	 			getch();
	 		}
	 		words -= -a + 1 ;
		 	b = *sp++ ;
	 		
	 		for ( ; a <= 0 ; a++ ) *dp++ = b ;
	 	}
	 	else			/* a >= 0 : unequal sequence	*/
	 	{
	 		words -= a + 1 ;
	 		
	 		for ( ; a >= 0 ; a-- ) *dp++ = *sp++ ;
	 	}
	 }
# if TESTmccFormat
	if ( ((long)dest) + (long)d_x != (long)dp )
	{
		printf ( "linlen: lin %#8.8lx, pos %#8.8lx, scrlin %#8.8lx, key!\n",
					source, sp-1, dest ) ;
		getch();
	}
# endif
	return ( (byte *) sp ) ;
}



# if 0
			scr_ptr = bit_map ;
# if TEST	
			printf ( "data ptr : %#8.8lx, scr ptr : %#8.8lx\n",
								 pic_ptr, scr_ptr ) ;

# endif
			for(yi=y;yi<y+h;yi++)
			{
# if TEST	
				if ( ! ( yi & 0x3f ) ) putchar ( '.' ) ;
#endif
				if ( do_compression )
				{
					pic_ptr = compress_line ( scr_ptr, pic_ptr, w ) ;
				}
				else
				{
					line_blit (scr_ptr,pic_ptr,w);
					pic_ptr += w ;
				}
				scr_ptr += byt_per_lin ;
			}
# endif
