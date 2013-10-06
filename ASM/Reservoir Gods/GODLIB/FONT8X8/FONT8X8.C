/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: FONT8X8.C
::
:: Font printing routines
::
:: [c] 2000 Reservoir Gods
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"FONT8X8.H"


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

extern	U8 	gFont8x8[12544];


/* ###################################################################################
#  FUNCTIONS
################################################################################### */

/*-----------------------------------------------------------------------------------*
* FUNCTION : Font8x8_Print( const char * apString, U16 * apScreen, U16 aX, U16 aY )
* ACTION   : prints string apString on screen apScreen at aX,aY
* CREATION : 16.01.01 PNK
*-----------------------------------------------------------------------------------*/

void	Font8x8_Print( char * apString, U16 * apScreen, U16 aX, U16 aY )
{
	U32		lOffset;
	U16		lChar;
	U16		lNextX;
	U8 *	lpSrc;
	U8 *	lpScreen;

	lOffset   = aY;
	lOffset  *= 160L;
	lOffset  += (aX>>4)<<3;
	lpScreen  = (U8*)apScreen;
	lpScreen  = &lpScreen[ lOffset ];

	lNextX = aX & 8;
	if( lNextX )
	{
		lpScreen++;
	}

	while( *apString )
	{
		lChar   = (U16)((*apString++ - 32) & 0xFF);
		lChar <<=3;
		lpSrc   = &gFont8x8[ lChar ];

		lpScreen[ 0*160 ] = *lpSrc++;
		lpScreen[ 1*160 ] = *lpSrc++;
		lpScreen[ 2*160 ] = *lpSrc++;
		lpScreen[ 3*160 ] = *lpSrc++;
		lpScreen[ 4*160 ] = *lpSrc++;
		lpScreen[ 5*160 ] = *lpSrc++;
		lpScreen[ 6*160 ] = *lpSrc++;
		lpScreen[ 7*160 ] = *lpSrc++;

		if( lNextX )
		{
			lpScreen += 7;
			lNextX    = 0;
		}
		else
		{
			lpScreen++;
			lNextX =1;
		}
		
	}
}