/*
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: CANVAS.C
::
:: Routines for manipulating graphics
::
:: [c] 2000 Reservoir Gods
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
*/


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"CANVAS.H"

#include	<GODLIB\MEMORY\MEMORY.H>
#include	<GODLIB\PICTYPES\OCTTREE.H>


/* ###################################################################################
#  DEFINES
################################################################################### */

#define	dCANVAS_ID		mSTRING_TO_U32( 'c', 's', 'R', 'G' )
#define	dCANVAS_VERSION	0x0


/* ###################################################################################
#  FUNCTIONS
################################################################################### */

/*-----------------------------------------------------------------------------------*
* FUNCTION    : Canvas_Create()
* DESCRIPTION : allocates memory for a canvas descriptor
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

sCanvas *	Canvas_Create()
{
	sCanvas * lpCanvas;

	lpCanvas = (sCanvas*)Memory_Calloc( sizeof(sCanvas) );

	lpCanvas->ID       = dCANVAS_ID;
	lpCanvas->Version  = dCANVAS_VERSION;
	lpCanvas->pPixels  = 0;

	return( lpCanvas );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Canvas_Destroy( sCanvas * apCanvas )
* DESCRIPTION : deallocates memory for a canvas image, palette & descriptor
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

U8			Canvas_Destroy( sCanvas * apCanvas )
{
	Canvas_DestroyImage(   apCanvas );

	Memory_Release( apCanvas );

	return( 1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Canvas_CreateImage( sCanvas * apCanvas, U16 aWidth, U16 aHeight )
* DESCRIPTION : allocates memory for a canvas image
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

U8				Canvas_CreateImage( sCanvas * apCanvas, U16 aWidth, U16 aHeight )
{
	U32	lImageSize;

	Canvas_DestroyImage( apCanvas );

	lImageSize  = aWidth;
	lImageSize *= aHeight;
	lImageSize *= sizeof( uCanvasPixel );

	apCanvas->pPixels = (uCanvasPixel*)Memory_Calloc( lImageSize );

	if( !apCanvas->pPixels )
	{
		apCanvas->Width  = 0;
		apCanvas->Height = 0;
		return( 0 );
	}
	
	apCanvas->Width  = aWidth;
	apCanvas->Height = aHeight;

	return( 1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Canvas_DestroyImage( sCanvas * apCanvas )
* DESCRIPTION : deallocates memory for an image
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

U8				Canvas_DestroyImage( sCanvas * apCanvas )
{
	if( apCanvas->pPixels )
	{
		Memory_Release(apCanvas->pPixels );
	}

	apCanvas->Width   = 0;
	apCanvas->Height  = 0;
	apCanvas->pPixels = 0;

	return( 1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Canvas_PaletteFromST( sCanvas * apCanvas, U16 aColourCount, U16 * apPalette )
* DESCRIPTION : converts an st palette to a canvas palette
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

U8			Canvas_PaletteFromST( uCanvasPixel * apPal, U16 aColourCount, U16 * apPalette )
{
	U16	i;

	for( i=0; i<aColourCount; i++ )
	{
		CanvasPixel_FromST( &apPal[ i ], &apPalette[ i ] );
	}
	
	return( 1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Canvas_PaletteToST(   sCanvas * apCanvas, U16 aColourCount, U16 * apPalette )
* DESCRIPTION : creates a canvas palette to an st palette
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

U8			Canvas_PaletteToST(   uCanvasPixel * apPal, U16 aColourCount, U16 * apPalette )
{
	U16	i;

	for( i=0; i<aColourCount; i++ )
	{
		CanvasPixel_ToST( &apPal[ i ], &apPalette[ i ] );
	}
	
	return( 1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Canvas_ImageFrom1Plane( sCanvas * apCanvas, U16 aWidth, U16 aHeight, U16 apPixels )
* DESCRIPTION : creates a canvas from a 1 plane image
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

sCanvas *			Canvas_ImageFrom1Plane( U16 aWidth, U16 aHeight, U16 * apPixels, uCanvasPixel * apPal )
{
	sCanvas *		lpCanvas;
	uCanvasPixel *	lpDst;

	U32				lImageSize;
	U32				i;
	U16				lPlane0;
	U16				lIndex;

	lpCanvas = Canvas_Create();

	if( lpCanvas )
	{
		Canvas_CreateImage( lpCanvas, aWidth, aHeight );

		lImageSize  = aWidth;
		lImageSize *= aHeight;

		lpDst = lpCanvas->pPixels;

		for( i=0; i<lImageSize; i++ )
		{
			if( !(i & 15) )
			{
				lPlane0  = *apPixels++;
			}

			lIndex   = (lPlane0>>15) & 1;
			*lpDst++ = apPal[ lIndex ];

			lPlane0  <<= 1;
		}
	}

	return( lpCanvas );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Canvas_ImageFrom2Plane( sCanvas * apCanvas, U16 aWidth, U16 aHeight, U16 apPixels )
* DESCRIPTION : creates a canvas from a 2 plane image
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

sCanvas *		Canvas_ImageFrom2Plane( U16 aWidth, U16 aHeight, U16 * apPixels, uCanvasPixel * apPal )
{
	sCanvas *		lpCanvas;
	uCanvasPixel *	lpDst;
	U32				lImageSize;
	U32				i;
	U16				lPlane0,lPlane1;
	U16				lIndex;

	lpCanvas = Canvas_Create();

	if( lpCanvas )
	{
		Canvas_CreateImage( lpCanvas, aWidth, aHeight );

		lImageSize  = aWidth;
		lImageSize *= aHeight;

		lpDst = lpCanvas->pPixels;

		for( i=0; i<lImageSize; i++ )
		{
			if( !(i & 15) )
			{
				lPlane0 = *apPixels++;
				lPlane1 = *apPixels++;
			}

			lIndex    = ((lPlane0>>15) & 1);
			lIndex   |= ((lPlane1>>15) & 1)<<1;

			*lpDst++  = apPal[ lIndex ];

			lPlane0 <<= 1;
			lPlane1 <<= 1;
		}
	}
	return( lpCanvas );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Canvas_ImageFrom4Plane( sCanvas * apCanvas, U16 aWidth, U16 aHeight, U16 apPixels )
* DESCRIPTION : creates a canvas from a 4 plane image
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

sCanvas *		Canvas_ImageFrom4Plane( U16 aWidth, U16 aHeight, U16 * apPixels, uCanvasPixel * apPal )
{
	sCanvas *		lpCanvas;
	uCanvasPixel *	lpDst;
	U32				lImageSize;
	U32				i;
	U16				lPlane0,lPlane1,lPlane2,lPlane3;
	U16				lIndex;

	lpCanvas = Canvas_Create();

	if( lpCanvas )
	{

		Canvas_CreateImage( lpCanvas, aWidth, aHeight );

		lImageSize  = aWidth;
		lImageSize *= aHeight;

		lpDst = lpCanvas->pPixels;

		for( i=0; i<lImageSize; i++ )
		{
			if( !(i & 15) )
			{
				lPlane0 = *apPixels++;
				lPlane1 = *apPixels++;
				lPlane2 = *apPixels++;
				lPlane3 = *apPixels++;
			}

			lIndex    = ((lPlane0>>15) & 1);
			lIndex   |= ((lPlane1>>15) & 1)<<1;
			lIndex   |= ((lPlane2>>15) & 1)<<2;
			lIndex   |= ((lPlane3>>15) & 1)<<3;

			*lpDst++  = apPal[ lIndex ];

			lPlane0 <<= 1;
			lPlane1 <<= 1;
			lPlane2 <<= 1;
			lPlane3 <<= 1;
		}
	}
	return( lpCanvas );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Canvas_ImageFrom8Plane( sCanvas * apCanvas, U16 aWidth, U16 aHeight, U16 apPixels )
* DESCRIPTION : creates a canvas from a 8 plane image
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

sCanvas *		Canvas_ImageFrom8Plane( U16 aWidth, U16 aHeight, U16 * apPixels, uCanvasPixel * apPal )
{
	sCanvas *		lpCanvas;
	uCanvasPixel *	lpDst;
	U32				lImageSize;
	U32				i;
	U16				lPlane0,lPlane1,lPlane2,lPlane3,lPlane4,lPlane5,lPlane6,lPlane7;
	U16				lIndex;

	lpCanvas = Canvas_Create();

	if( lpCanvas )
	{
		Canvas_CreateImage( lpCanvas, aWidth, aHeight );


		lImageSize  = aWidth;
		lImageSize *= aHeight;

		lpDst = lpCanvas->pPixels;

		for( i=0; i<lImageSize; i++ )
		{
			if( !(i & 15) )
			{
				lPlane0 = *apPixels++;
				lPlane1 = *apPixels++;
				lPlane2 = *apPixels++;
				lPlane3 = *apPixels++;
				lPlane4 = *apPixels++;
				lPlane5 = *apPixels++;
				lPlane6 = *apPixels++;
				lPlane7 = *apPixels++;
			}

			lIndex    = ((lPlane0>>15) & 1);
			lIndex   |= ((lPlane1>>15) & 1)<<1;
			lIndex   |= ((lPlane2>>15) & 1)<<2;
			lIndex   |= ((lPlane3>>15) & 1)<<3;
			lIndex   |= ((lPlane4>>15) & 1)<<4;
			lIndex   |= ((lPlane5>>15) & 1)<<5;
			lIndex   |= ((lPlane6>>15) & 1)<<6;
			lIndex   |= ((lPlane7>>15) & 1)<<7;

			*lpDst++  = apPal[ lIndex ];

			lPlane0 <<= 1;
			lPlane1 <<= 1;
			lPlane2 <<= 1;
			lPlane3 <<= 1;
			lPlane4 <<= 1;
			lPlane5 <<= 1;
			lPlane6 <<= 1;
			lPlane7 <<= 1;
		}
	}
	return( lpCanvas );
}




/*-----------------------------------------------------------------------------------*
* FUNCTION    : Canvas_ImageTo565(   sCanvas * apCanvas, U16 aWidth, U16 aHeight, U16 * apPixels )
* DESCRIPTION : converts a canvas to a 565 image
* AUTHOR      : 28.12.00 PNK
*-----------------------------------------------------------------------------------*/

U8			Canvas_ImageTo565(   sCanvas * apCanvas, U16 aWidth, U16 aHeight, U16 * apPixels )
{
	uCanvasPixel *	lpSrc;
	U16				l565;
	U16				x,y;


	lpSrc = apCanvas->pPixels;

	for( y=0; y<aHeight; y++ )
	{
		for( x=0; x<aWidth; x++ )
		{
			l565  = (lpSrc->b.r << 8) & 0xF800;
			l565 |= (lpSrc->b.g << 3) & 0x07E0;
			l565 |= (lpSrc->b.r >> 3) & 0x001F;

			*apPixels++ = l565;
			lpSrc++;
		}
	}

	return( 1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Canvas_ImageFrom565( sCanvas * apCanvas, U16 aWidth, U16 aHeight, U16 * apPixels )
* DESCRIPTION : converts a canvas to a 565 image
* AUTHOR      : 28.12.00 PNK
*-----------------------------------------------------------------------------------*/

U8			Canvas_ImageFrom565( sCanvas * apCanvas, U16 aWidth, U16 aHeight, U16 * apPixels )
{
	U16				x,y;
	U16				l565;
	uCanvasPixel *	lpPixel;

	if( !Canvas_CreateImage( apCanvas, aWidth, aHeight ) )
		return( 0 );

	lpPixel = apCanvas->pPixels;

	for( y=0; y<aHeight; y++ )
	{
		for( x=0; x<aWidth; x++ )
		{
			l565 = *apPixels++;

			lpPixel->b.a = 0;
			lpPixel->b.r = ((l565 >> 11) & 0x1F) << 3;
			lpPixel->b.g = ((l565 >> 5 ) & 0x2F) << 2;
			lpPixel->b.b = ((l565 >> 5 ) & 0x1F) << 3;

			lpPixel++;
		}
	}

	return( 1 );
}


#if	0

U8			Canvas_Palettize( sCanvas * apCanvas )
{
}


void		Canvas_ReduceColourDepth( sCanvas * apCanvas, U16 aColourCount )
{
}



/*-----------------------------------------------------------------------------------*
* FUNCTION    : Canvas_Load(   sCanvas * apCanvas, char * apFileName )
* DESCRIPTION : allocates memory for and loads a canvas
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

sCanvas *	Canvas_Load(   sCanvas * apCanvas, char * apFileName )
{
	sCanvas *	lpCanvas;
	

	return( lpCanvas );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Canvas_LoadAt( sCanvas * apCanvas, char * apFileName, void * apMem )
* DESCRIPTION : loads a canvas to a specified memory location
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

U8			Canvas_LoadAt( sCanvas * apCanvas, char * apFileName, void * apMem )
{
	return( 1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Canvas_Save(   sCanvas * apCanvas, char * apFileName )
* DESCRIPTION : saves a canvas
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

U8			Canvas_Save(   sCanvas * apCanvas, char * apFileName )
{
	return( 1 );
}

#endif


/*-----------------------------------------------------------------------------------*
* FUNCTION    : CanvasPixel_FromST( U16 aColour )
* DESCRIPTION : converts a 4.4.4 ST colour to a uCanvasPixel
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

void		CanvasPixel_FromST( uCanvasPixel * apPixel, U16 * apST )
{
	apPixel->b.a = 0;
	apPixel->b.r = ((*apST>>8) & 0xF) << 4;
	apPixel->b.g = ((*apST>>4) & 0xF) << 4;
	apPixel->b.b = ((*apST   ) & 0xF) << 4;

}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : CanvasPixel_ToST( uCanvasPixel aPixel )
* DESCRIPTION : converts a uCanvasPixel to a 4.4.4 ST colour
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

void		CanvasPixel_ToST( uCanvasPixel * apPixel, U16 * apST )
{
	*apST  = ((apPixel->b.r>>4) & 0xF)<<8;
	*apST |= ((apPixel->b.g>>4) & 0xF)<<4;
	*apST |= ((apPixel->b.b>>4) & 0xF);
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Canvas_GetPixel( sCanvas * apCanvas, U16 aX, U16 aY )
* DESCRIPTION : returns a pixel from specified canvas location
* AUTHOR      : 28.12.00 PNK
*-----------------------------------------------------------------------------------*/

uCanvasPixel		Canvas_GetPixel( sCanvas * apCanvas, U16 aX, U16 aY )
{
	uCanvasPixel	lTemp;
	U32				lOffset;

	if( apCanvas->pPixels )
	{
		if( aX < apCanvas->Width )
		{
			if( aY < apCanvas->Height )
			{
				lOffset  = aY;
				lOffset *= apCanvas->Width;
				lOffset += aX;

				return( apCanvas->pPixels[ lOffset ] );
			}
		}
	}
	lTemp.l = 0;
	return( lTemp );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : Canvas_SetPixel( sCanvas * apCanvas, U16 aX, U16 aY, uCanvasPixel aPixel )
* DESCRIPTION : sets a pixel
* AUTHOR      : 28.12.00 PNK
*-----------------------------------------------------------------------------------*/

void			Canvas_SetPixel( sCanvas * apCanvas, U16 aX, U16 aY, U32 aPixel )
{
	U32	lOffset;

	if( apCanvas->pPixels )
	{
		if( aX < apCanvas->Width )
		{
			if( aY < apCanvas->Height )
			{
				lOffset   = apCanvas->Width;
				lOffset  *= aY;
				lOffset  += aX;

				apCanvas->pPixels[ lOffset ].l = aPixel;
			}
		}
	}
}