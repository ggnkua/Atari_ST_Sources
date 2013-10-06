/*
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: DEGAS.C
::
:: Routines for manipulating degas pi1 images
::
:: [c] 2000 Reservoir Gods
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
*/


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"DEGAS.H"

#include	<GODLIB\MEMORY\MEMORY.H>


/* ###################################################################################
#  INCLUDES
################################################################################### */

#define		dDEGAS_COMPRESSED_MASK	0x8000


/* ###################################################################################
#  FUNCTIONS
################################################################################### */

/*-----------------------------------------------------------------------------------*
* FUNCTION    : Degas_DeCompress( U8 * apSrc, U8 * apDst, U32 aDepackSize )
* DESCRIPTION : depacks RLE encoded image data
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

void	Degas_DeCompress( U8 * apSrc, U8 * apDst, U32 aDepackSize )
{
	U32		lDepackIndex;
	U8 *	lpDst;
	U8 *	lpSrc;
	S16		i;
	S16		lCode;
	U8		lByte;

	lDepackIndex = 0;
	lpDst        = apDst;
	lpSrc        = apSrc;
		

	while( lDepackIndex < aDepackSize )
	{
		lCode = *lpSrc++;

		if( lCode < 0 )
		{
			lByte = *lpSrc++;

			lCode = -lCode;
			
			for( i=0; i<=lCode; i++ )
				*lpDst++ = lByte;

			lDepackIndex += lCode+1;
		}
		else
		{
			for( i=0; i<=lCode; i++ )
				*lpDst++ = *lpSrc++;
			
			lDepackIndex += lCode+1;
		}
	} 
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Degas_Pi1ToCanvas( sDegas * apDegas )
* DESCRIPTION : converts a pi1 image to a canvas
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

sCanvas *		Degas_Pi1ToCanvas( sDegas * apDegas )
{
	uCanvasPixel	lPal[ 16 ];
	sCanvas *		lpCanvas;

	lpCanvas = Canvas_Create();

	Canvas_PaletteFromST(   &lPal[ 0 ],  16, apDegas->Header.Palette );
	lpCanvas = Canvas_ImageFrom4Plane( 320, 200, apDegas->Pixels, &lPal[ 0 ] );

	return( lpCanvas );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Degas_Pi2ToCanvas( sDegas * apDegas )
* DESCRIPTION : converts a pi2 image to a canvas
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

sCanvas *		Degas_Pi2ToCanvas( sDegas * apDegas )
{
	uCanvasPixel	lPal[ 4 ];
	sCanvas *		lpCanvas;

	lpCanvas = Canvas_Create();

	Canvas_PaletteFromST(   &lPal[ 0 ],  4, apDegas->Header.Palette );
	lpCanvas = Canvas_ImageFrom2Plane( 640, 200, apDegas->Pixels, &lPal[ 0 ] );

	return( lpCanvas );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Degas_Pi3ToCanvas( sDegas * apDegas )
* DESCRIPTION : converts a pi3 image to a canvas
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

sCanvas *		Degas_Pi3ToCanvas( sDegas * apDegas )
{
	uCanvasPixel	lPal[ 2 ];
	sCanvas *		lpCanvas;

	lpCanvas = Canvas_Create();

	Canvas_PaletteFromST( &lPal[ 0 ], 2, apDegas->Header.Palette );
	lpCanvas = Canvas_ImageFrom1Plane( 640, 400, apDegas->Pixels, &lPal[ 0 ] );

	return( lpCanvas );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Degas_Pc1ToCanvas( sDegas * apDegas )
* DESCRIPTION : converts a pc1 image to a canvas
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

sCanvas *		Degas_Pc1ToCanvas( sDegas * apDegas )
{
	U8				lPlane0,lPlane1,lPlane2,lPlane3;
	sCanvas *		lpCanvas;
	uCanvasPixel	lPal[ 16 ];
	U8 *			lpScanline;
	U8 *			lpPixels;
	U16				i,j;
	U16				lIndex;

	lpCanvas = Canvas_Create();

	Canvas_PaletteFromST( &lPal[ 0 ], 16, apDegas->Header.Palette );
	
	lpPixels = Memory_Alloc( 32000 );

	Degas_DeCompress( (U8*)&apDegas->Pixels[0], lpPixels, 32000 );

	Canvas_CreateImage( lpCanvas, 320, 200 );

	for( i=0; i<200; i++ )
	{
		lpScanline = &lpPixels[ i*160 ];

		for( j=0;j<320; j++ )
		{
			if( j&7 )
			{
				lPlane0 = lpScanline[   0 ];
				lPlane1 = lpScanline[  40 ];
				lPlane2 = lpScanline[  80 ];
				lPlane3 = lpScanline[ 120 ];
				lpScanline++;
			}

			lIndex  = (lPlane0>>7) & 0x01;
			lIndex |= (lPlane1>>6) & 0x02;
			lIndex |= (lPlane2>>5) & 0x04;
			lIndex |= (lPlane3>>4) & 0x08;

			Canvas_SetPixel( lpCanvas, i, j, lPal[ lIndex ].l );

			lPlane0 <<= 1;
			lPlane1 <<= 1;
			lPlane2 <<= 1;
			lPlane3 <<= 1;

		}
	}

	Memory_Release( lpPixels );

	return( lpCanvas );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Degas_Pc2ToCanvas( sDegas * apDegas )
* DESCRIPTION : converts a pc2 image to a canvas
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

sCanvas *		Degas_Pc2ToCanvas( sDegas * apDegas )
{
	U8				lPlane0,lPlane1;
	sCanvas *		lpCanvas;
	uCanvasPixel	lPal[ 16 ];
	U8 *			lpScanline;
	U8 *			lpPixels;
	U16				i,j;
	U16				lIndex;

	lpCanvas = Canvas_Create();

	Canvas_PaletteFromST( &lPal[ 0 ], 4, apDegas->Header.Palette );
	
	lpPixels = Memory_Alloc( 32000 );

	Degas_DeCompress( (U8*)&apDegas->Pixels[0], lpPixels, 32000 );

	Canvas_CreateImage( lpCanvas, 640, 200 );

	for( i=0; i<200; i++ )
	{
		lpScanline = &lpPixels[ i*160 ];

		for( j=0;j<640; j++ )
		{
			if( j&7 )
			{
				lPlane0 = lpScanline[   0 ];
				lPlane1 = lpScanline[  80 ];
				lpScanline++;
			}

			lIndex  = (lPlane0>>7) & 0x01;
			lIndex |= (lPlane1>>6) & 0x02;

			Canvas_SetPixel( lpCanvas, i, j, lPal[ lIndex ].l );

			lPlane0 <<= 1;
			lPlane1 <<= 1;
		}
	}

	Memory_Release( lpPixels );

	return( lpCanvas );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Degas_Pc3ToCanvas( sDegas * apDegas )
* DESCRIPTION : converts a pc3 image to a canvas
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

sCanvas *		Degas_Pc3ToCanvas( sDegas * apDegas )
{
	U8				lPlane0;
	sCanvas *		lpCanvas;
	uCanvasPixel	lPal[ 16 ];
	U8 *			lpScanline;
	U8 *			lpPixels;
	U16				i,j;
	U16				lIndex;

	lpCanvas = Canvas_Create();

	Canvas_PaletteFromST( &lPal[ 0 ], 2, apDegas->Header.Palette );
	
	lpPixels = Memory_Alloc( 32000 );

	Degas_DeCompress( (U8*)&apDegas->Pixels[0], lpPixels, 32000 );

	Canvas_CreateImage( lpCanvas, 640, 200 );

	for( i=0; i<200; i++ )
	{
		lpScanline = &lpPixels[ i*160 ];

		for( j=0;j<640; j++ )
		{
			if( j&7 )
			{
				lPlane0 = lpScanline[   0 ];
				lpScanline++;
			}

			lIndex  = (lPlane0>>7) & 0x01;

			Canvas_SetPixel( lpCanvas, i, j, lPal[ lIndex ].l );

			lPlane0 <<= 1;
		}
	}

	Memory_Release( lpPixels );

	return( lpCanvas );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Degas_Pi1FromCanvas( sCanvas * apCanvas )
* DESCRIPTION : converts a pi1 from canvas
* AUTHOR      : 27.12.00 PNK
*-----------------------------------------------------------------------------------*/

sDegas *		Degas_Pi1FromCanvas( sCanvas * apCanvas, uCanvasPixel * apPalette )
{
	sDegas *	lpDegas;
	sCanvasIC *	lpCanvasIC;

	lpDegas    = 0;
	lpCanvasIC = CanvasIC_FromCanvas( apCanvas, 16, apPalette );

	if( lpCanvasIC )
	{
		lpDegas = (sDegas*)Memory_Calloc( sizeof(sDegas) );

		if( lpDegas )
		{
			lpDegas->Header.Mode = 0;

			CanvasIC_PaletteToST( lpCanvasIC, 16, lpDegas->Header.Palette );
			CanvasIC_To4Plane(    lpCanvasIC, 320, 200, lpDegas->Pixels );
		}
		CanvasIC_Destroy( lpCanvasIC );
	}

	return( lpDegas );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Degas_Pi2FromCanvas( sCanvas * apCanvas )
* DESCRIPTION : converts a pi2 from canvas
* AUTHOR      : 27.12.00 PNK
*-----------------------------------------------------------------------------------*/

sDegas *		Degas_Pi2FromCanvas( sCanvas * apCanvas, uCanvasPixel * apPalette )
{
	sDegas *	lpDegas;
	sCanvasIC *	lpCanvasIC;

	lpDegas    = 0;
	lpCanvasIC = CanvasIC_FromCanvas( apCanvas, 4, apPalette );

	if( lpCanvasIC )
	{
		lpDegas = (sDegas*)Memory_Calloc( sizeof(sDegas) );

		if( lpDegas )
		{
			lpDegas->Header.Mode = 1;

			CanvasIC_PaletteToST( lpCanvasIC, 4, lpDegas->Header.Palette );
			CanvasIC_To2Plane(    lpCanvasIC, 640, 200, lpDegas->Pixels );
		}
		CanvasIC_Destroy( lpCanvasIC );
	}
	return( lpDegas );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Degas_Pi3FromCanvas( sCanvas * apCanvas )
* DESCRIPTION : converts a pi3 from canvas
* AUTHOR      : 27.12.00 PNK
*-----------------------------------------------------------------------------------*/

sDegas *		Degas_Pi3FromCanvas( sCanvas * apCanvas, uCanvasPixel * apPalette )
{
	sDegas *	lpDegas;
	sCanvasIC *	lpCanvasIC;

	lpDegas    = 0;
	lpCanvasIC = CanvasIC_FromCanvas( apCanvas, 2, apPalette );

	if( lpCanvasIC )
	{

		lpDegas = (sDegas*)Memory_Calloc( sizeof(sDegas) );

		if( lpDegas )
		{
			lpDegas->Header.Mode = 1;

			CanvasIC_PaletteToST( lpCanvasIC, 2, lpDegas->Header.Palette );
			CanvasIC_To1Plane(    lpCanvasIC, 640, 400, lpDegas->Pixels );
		}
		CanvasIC_Destroy( lpCanvasIC );
	}

	return( lpDegas );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Degas_ToCanvas(   sDegas * apDegas )
* DESCRIPTION : converts a degas image to a canvas
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

sCanvas *		Degas_ToCanvas(   sDegas * apDegas )
{
	sCanvas *		lpCanvas;

	lpCanvas = 0;

	if( apDegas->Header.Mode & dDEGAS_COMPRESSED_MASK )
	{
		switch( apDegas->Header.Mode & 3 )
		{

		case	0:
			lpCanvas = Degas_Pc1ToCanvas( apDegas );
			break;

		case	1:
			lpCanvas = Degas_Pc2ToCanvas( apDegas );
			break;

		case	2:
			lpCanvas = Degas_Pc3ToCanvas( apDegas );
			break;

		}
	}
	else
	{
		switch( apDegas->Header.Mode & 3 )
		{

		case	0:
			lpCanvas = Degas_Pi1ToCanvas( apDegas );
			break;

		case	1:
			lpCanvas = Degas_Pi2ToCanvas( apDegas );
			break;

		case	2:
			lpCanvas = Degas_Pi3ToCanvas( apDegas );
			break;

		}
	}

	return( lpCanvas );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Degas_FromCanvas(   sDegas * apDegas )
* DESCRIPTION : converts a canas to a degas image
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

sDegas *	Degas_FromCanvas( sCanvas * apCanvas, uCanvasPixel * apPalette )
{
	return( Degas_Pi1FromCanvas( apCanvas, apPalette ) );	
}
