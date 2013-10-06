/*
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: ART.C
::
:: Routines for manipulating art director ART images
::
:: [c] 2000 Reservoir Gods
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
*/


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"ART.H"

#include	<GODLIB\MEMORY\MEMORY.H>


/* ###################################################################################
#  FUNCTIONS
################################################################################### */

/*-----------------------------------------------------------------------------------*
* FUNCTION    : Art_ToCanvas( sArt * apArt )
* DESCRIPTION : converts an ART image to a canvas
* AUTHOR      : 28.12.00 PNK
*-----------------------------------------------------------------------------------*/

sCanvas *		Art_ToCanvas( sArt * apArt )
{
	sCanvas *		lpCanvas;
	uCanvasPixel	lPal[ 16 ];

	lpCanvas = Canvas_Create();

	Canvas_PaletteFromST(   &lPal[ 0 ],  16, apArt->Palettes[ 0 ] );
	lpCanvas = Canvas_ImageFrom4Plane( 320, 200, apArt->Pixels, &lPal[ 0 ] );

	return( lpCanvas );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Art_FromCanvas( sCanvas * apCanvas, uCanvasPixel * apPalette )
* DESCRIPTION : converts to an ART file from canvas
* AUTHOR      : 28.12.00 PNK
*-----------------------------------------------------------------------------------*/

sArt *		Art_FromCanvas( sCanvas * apCanvas, uCanvasPixel * apPalette )
{
	sArt *		lpArt;
	sCanvasIC *	lpCanvasIC;

	lpArt      = 0;
	lpCanvasIC = CanvasIC_FromCanvas( apCanvas, 16, apPalette );

	if( lpCanvasIC )
	{
		lpArt = (sArt*)Memory_Calloc( sizeof(sArt) );

		if( lpArt )
		{
			CanvasIC_PaletteToST( lpCanvasIC, 16, lpArt->Palettes[ 0 ] );
			CanvasIC_To4Plane(    lpCanvasIC, 320, 200, lpArt->Pixels );
		}

		CanvasIC_Destroy( lpCanvasIC );
	}

	return( lpArt );
}


