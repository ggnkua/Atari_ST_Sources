/*
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: NEO.C
::
:: Routines for manipulating neochrome neo images
::
:: [c] 2000 Reservoir Gods
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
*/


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"NEO.H"

#include	<GODLIB\MEMORY\MEMORY.H>


/* ###################################################################################
#  FUNCTIONS
################################################################################### */

/*-----------------------------------------------------------------------------------*
* FUNCTION    : Neo_ToCanvas( sNeo * apNeo )
* DESCRIPTION : converts a pi1 image to a canvas
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

sCanvas *		Neo_ToCanvas( sNeo * apNeo )
{
	uCanvasPixel	lPal[ 16 ];
	sCanvas *		lpCanvas;

	lpCanvas = Canvas_Create();

	Canvas_PaletteFromST(   &lPal[ 0 ],  16, apNeo->Header.Palette );
	lpCanvas = Canvas_ImageFrom4Plane( 320, 200, apNeo->Pixels, &lPal[ 0 ] );

	return( lpCanvas );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Neo_FromCanvas( sCanvas * apCanvas, uCanvasPixel * apPalette )
* DESCRIPTION : converts a neo from canvas
* AUTHOR      : 27.12.00 PNK
*-----------------------------------------------------------------------------------*/

sNeo *		Neo_FromCanvas( sCanvas * apCanvas, uCanvasPixel * apPalette )
{
	sCanvasIC *	lpCanvasIC;
	sNeo *		lpNeo;

	lpNeo      = 0;
	lpCanvasIC = CanvasIC_FromCanvas( apCanvas, 16, apPalette );

	if( lpCanvasIC )
	{

		lpNeo = (sNeo*)Memory_Calloc( sizeof(sNeo) );

		if( lpNeo )
		{
			lpNeo->Header.Width      = 320;
			lpNeo->Header.Height     = 200;
			lpNeo->Header.Resolution = 0;
			lpNeo->Header.OffsetX    = 0;
			lpNeo->Header.OffsetY    = 0;

			CanvasIC_PaletteToST( lpCanvasIC, 16, lpNeo->Header.Palette );
			CanvasIC_To4Plane(    lpCanvasIC, 320, 200, lpNeo->Pixels );
		}
		CanvasIC_Destroy( lpCanvasIC );
	}
	return( lpNeo );
}


