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

#include	"CANVASIC.H"

#include	<GODLIB\MEMORY\MEMORY.H>
#include	<GODLIB\PICTYPES\OCTTREE.H>


/* ###################################################################################
#  DEFINES
################################################################################### */

#define	dCANVASIC_ID		mSTRING_TO_U32( 'c', 's', 'I', 'C' )
#define	dCANVASIC_VERSION	0x0


/* ###################################################################################
#  FUNCTIONS
################################################################################### */

/*-----------------------------------------------------------------------------------*
* FUNCTION    : CanvasIC_Create()
* DESCRIPTION : allocates memory for a canvas descriptor
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

sCanvasIC *	CanvasIC_Create()
{
	sCanvasIC * lpCanvasIC;

	lpCanvasIC = (sCanvasIC*)Memory_Calloc( sizeof(sCanvasIC) );

	lpCanvasIC->ID       = dCANVASIC_ID;
	lpCanvasIC->Version  = dCANVASIC_VERSION;
	lpCanvasIC->pPixels  = 0;

	return( lpCanvasIC );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : CanvasIC_Destroy( sCanvasIC * apCanvasIC )
* DESCRIPTION : deallocates memory for a canvas image, palette & descriptor
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

U8			CanvasIC_Destroy( sCanvasIC * apCanvasIC )
{
	CanvasIC_DestroyImage(   apCanvasIC );

	Memory_Release( apCanvasIC );

	return( 1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : CanvasIC_CreateImage( sCanvasIC * apCanvasIC, U16 aWidth, U16 aHeight )
* DESCRIPTION : allocates memory for a canvas image
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

U8				CanvasIC_CreateImage( sCanvasIC * apCanvasIC, U16 aWidth, U16 aHeight )
{
	U32	lImageSize;

	CanvasIC_DestroyImage( apCanvasIC );

	lImageSize  = aWidth;
	lImageSize *= aHeight;

	apCanvasIC->pPixels = (U8*)Memory_Calloc( lImageSize );

	if( !apCanvasIC->pPixels )
	{
		apCanvasIC->Width  = 0;
		apCanvasIC->Height = 0;
		return( 0 );
	}
	
	apCanvasIC->Width  = aWidth;
	apCanvasIC->Height = aHeight;

	return( 1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : CanvasIC_DestroyImage( sCanvasIC * apCanvasIC )
* DESCRIPTION : deallocates memory for an image
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

U8				CanvasIC_DestroyImage( sCanvasIC * apCanvasIC )
{
	if( apCanvasIC->pPixels )
		Memory_Release(apCanvasIC->pPixels );

	apCanvasIC->Width   = 0;
	apCanvasIC->Height  = 0;
	apCanvasIC->pPixels = 0;

	return( 1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : CanvasIC_CreatePalette( sCanvasIC * apCanvasIC, U16 aColourCount )
* DESCRIPTION : allocates memory for a palette
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/


/*-----------------------------------------------------------------------------------*
* FUNCTION    : CanvasIC_CreateDefaultPalette( sCanvasIC * apCanvasIC, U16 aColourCount )
* DESCRIPTION : creates a greyscale palette
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

U8				CanvasIC_CreateDefaultPalette( sCanvasIC * apCanvasIC, U16 aColourCount )
{	
	U16	i;
	U32	lCol;

	
	for( i=0; i<aColourCount; i++ )
	{
		lCol  = i * 0xFF;
		lCol /= aColourCount;

		apCanvasIC->Palette[ i ].b.a = 0;
		apCanvasIC->Palette[ i ].b.r = (U8)lCol;
		apCanvasIC->Palette[ i ].b.g = (U8)lCol;
		apCanvasIC->Palette[ i ].b.b = (U8)lCol;
	}

	return( 1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : CanvasIC_PaletteFromST( sCanvasIC * apCanvasIC, U16 aColourCount, U16 * apPalette )
* DESCRIPTION : converts an st palette to a canvas palette
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

U8			CanvasIC_PaletteFromST( sCanvasIC * apCanvasIC, U16 aColourCount, U16 * apPalette )
{
	U16	i;

	for( i=0; i<aColourCount; i++ )
	{
		CanvasICPixel_FromST( &apCanvasIC->Palette[ i ], &apPalette[ i ] );
	}
	
	return( 1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : CanvasIC_PaletteToST(   sCanvasIC * apCanvasIC, U16 aColourCount, U16 * apPalette )
* DESCRIPTION : creates a canvas palette to an st palette
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

U8			CanvasIC_PaletteToST(   sCanvasIC * apCanvasIC, U16 aColourCount, U16 * apPalette )
{
	U16	i;

	for( i=0; i<aColourCount; i++ )
	{
		CanvasICPixel_ToST( &apCanvasIC->Palette[ i ], &apPalette[ i ] );
	}
	
	return( 1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : CanvasIC_From1Plane( sCanvasIC * apCanvasIC, U16 aWidth, U16 aHeight, U16 apPixels )
* DESCRIPTION : creates a canvas from a 1 plane image
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

sCanvasIC *			CanvasIC_From1Plane( U16 aWidth, U16 aHeight, U16 * apPixels, uCanvasPixel * apPal )
{
	U8 *			lpDst;
	sCanvasIC *		lpCanvasIC;
	U32				lImageSize;
	U32				i;
	U16				lPlane0;
	U8				lIndex;

	lpCanvasIC = CanvasIC_Create();
	if( lpCanvasIC )
	{
		CanvasIC_CreateImage( lpCanvasIC, aWidth, aHeight );

		for( i=0; i<2; i++ )
		{
			lpCanvasIC->Palette[ i ] = apPal[ i ];
		}

		lImageSize  = aWidth;
		lImageSize *= aHeight;

		lpDst = lpCanvasIC->pPixels;

		for( i=0; i<lImageSize; i++ )
		{
			if( !(i & 15) )
			{
				lPlane0  = *apPixels++;
			}

			lIndex   = (lPlane0>>15) & 1;
			*lpDst++ = lIndex;

			lPlane0  <<= 1;
		}
	}
	return( lpCanvasIC );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : CanvasIC_From2Plane( sCanvasIC * apCanvasIC, U16 aWidth, U16 aHeight, U16 apPixels )
* DESCRIPTION : creates a canvas from a 2 plane image
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

sCanvasIC *			CanvasIC_From2Plane( U16 aWidth, U16 aHeight, U16 * apPixels, uCanvasPixel * apPal )
{
	U8 *			lpDst;
	sCanvasIC *		lpCanvasIC;
	U32				lImageSize;
	U32				i;
	U16				lPlane0,lPlane1;
	U8				lIndex;

	lpCanvasIC = CanvasIC_Create();
	if( lpCanvasIC )
	{
		CanvasIC_CreateImage( lpCanvasIC, aWidth, aHeight );

		for( i=0; i<4; i++ )
		{
			lpCanvasIC->Palette[ i ] = apPal[ i ];
		}

		lImageSize  = aWidth;
		lImageSize *= aHeight;

		lpDst = lpCanvasIC->pPixels;

		for( i=0; i<lImageSize; i++ )
		{
			if( !(i & 15) )
			{
				lPlane0 = *apPixels++;
				lPlane1 = *apPixels++;
			}

			lIndex    = ((lPlane0>>15) & 1);
			lIndex   |= ((lPlane1>>15) & 1)<<1;

			*lpDst++  = lIndex;

			lPlane0 <<= 1;
			lPlane1 <<= 1;
		}
	}
	return( lpCanvasIC );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : CanvasIC_From4Plane( sCanvasIC * apCanvasIC, U16 aWidth, U16 aHeight, U16 apPixels )
* DESCRIPTION : creates a canvas from a 4 plane image
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

sCanvasIC *			CanvasIC_From4Plane( U16 aWidth, U16 aHeight, U16 * apPixels, uCanvasPixel * apPal )
{
	U8 *			lpDst;
	sCanvasIC *		lpCanvasIC;
	U32				lImageSize;
	U32				i;
	U16				lPlane0,lPlane1,lPlane2,lPlane3;
	U16				lIndex;

	lpCanvasIC = CanvasIC_Create();
	if( lpCanvasIC )
	{
		CanvasIC_CreateImage( lpCanvasIC, aWidth, aHeight );

		for( i=0; i<16; i++ )
		{
			lpCanvasIC->Palette[ i ] = apPal[ i ];
		}

		lImageSize  = aWidth;
		lImageSize *= aHeight;

		lpDst = lpCanvasIC->pPixels;

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

			*lpDst++  = lIndex;

			lPlane0 <<= 1;
			lPlane1 <<= 1;
			lPlane2 <<= 1;
			lPlane3 <<= 1;
		}
	}
	return( lpCanvasIC );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : CanvasIC_From8Plane( sCanvasIC * apCanvasIC, U16 aWidth, U16 aHeight, U16 apPixels )
* DESCRIPTION : creates a canvas from a 8 plane image
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

sCanvasIC *			CanvasIC_From8Plane( U16 aWidth, U16 aHeight, U16 * apPixels, uCanvasPixel * apPal )
{
	U8 *			lpDst;
	sCanvasIC *		lpCanvasIC;
	U32				lImageSize;
	U32				i;
	U16				lPlane0,lPlane1,lPlane2,lPlane3,lPlane4,lPlane5,lPlane6,lPlane7;
	U16				lIndex;

	lpCanvasIC = CanvasIC_Create();
	if( lpCanvasIC )
	{
		CanvasIC_CreateImage( lpCanvasIC, aWidth, aHeight );

		for( i=0; i<256; i++ )
		{
			lpCanvasIC->Palette[ i ] = apPal[ i ];
		}

		lImageSize  = aWidth;
		lImageSize *= aHeight;

		lpDst = lpCanvasIC->pPixels;

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

			*lpDst++  = lIndex;

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
	return( lpCanvasIC );
}

/*-----------------------------------------------------------------------------------*
* FUNCTION    : CanvasIC_IndexedColourTo1Plane( sCanvasIC * apCanvasIC, U16 aWidth, U16 aHeight, U16 * apPixels )
* DESCRIPTION : converts a canvas to a 1 plane image
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

void			CanvasIC_To1Plane( sCanvasIC * apCanvasIC, U16 aWidth, U16 aHeight, U16 * apPixels )
{
	U16				lIP;
	U16				i,j;
	U16				lPlane0;


	for( i=0; i<aHeight; i++ )
	{

		lPlane0 = 0;

		for( j=0; j<aWidth; j++ )
		{
			lIP      = (U16)CanvasIC_GetPixel( apCanvasIC, j, i );
			lPlane0 |= (lIP&1);

			if( (j&0xF) == 0xF )
			{
				*apPixels++ = lPlane0;
				lPlane0     = 0;
			}
			else
			{
				lPlane0 <<= 1;
			}


		}
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : CanvasIC_To2Plane( sCanvasIC * apCanvasIC, U16 aWidth, U16 aHeight, U16 * apPixels )
* DESCRIPTION : converts a canvas to a 2 plane image
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

void			CanvasIC_To2Plane( sCanvasIC * apCanvasIC, U16 aWidth, U16 aHeight, U16 * apPixels )
{
	U16				lIP;
	U16				i,j;
	U16				lPlane0,lPlane1;


	for( i=0; i<aHeight; i++ )
	{

		lPlane0 = 0;
		lPlane1 = 0;

		for( j=0; j<aWidth; j++ )
		{
			lIP      = (U16)CanvasIC_GetPixel( apCanvasIC, j, i );
			lPlane0 |= (lIP&1);
			lIP    >>= 1;
			lPlane1 |= (lIP&1);

			if( (j&0xF) == 0xF )
			{
				*apPixels++ = lPlane0;
				*apPixels++ = lPlane1;

				lPlane0 = 0;
				lPlane1 = 0;
			}
			else
			{
				lPlane0 <<= 1;
				lPlane1 <<= 1;
			}
		}
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : CanvasIC_To4Plane( sCanvasIC * apCanvasIC, U16 aWidth, U16 aHeight, U16 * apPixels )
* DESCRIPTION : converts a canvas to a 4 plane image
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

void			CanvasIC_To4Plane( sCanvasIC * apCanvasIC, U16 aWidth, U16 aHeight, U16 * apPixels )
{
	U16				lIP;
	U16				i,j;
	U16				lPlane0,lPlane1,lPlane2,lPlane3;


	for( i=0; i<aHeight; i++ )
	{

		lPlane0 = 0;
		lPlane1 = 0;
		lPlane2 = 0;
		lPlane3 = 0;

		for( j=0; j<aWidth; j++ )
		{
			lIP      = (U16)CanvasIC_GetPixel( apCanvasIC, j, i );
			lPlane0 |= (lIP&1);
			lIP    >>= 1;
			lPlane1 |= (lIP&1);
			lIP    >>= 1;
			lPlane2 |= (lIP&1);
			lIP    >>= 1;
			lPlane3 |= (lIP&1);

			if( (j&0xF) == 0xF )
			{
				*apPixels++ = lPlane0;
				*apPixels++ = lPlane1;
				*apPixels++ = lPlane2;
				*apPixels++ = lPlane3;

				lPlane0 = 0;
				lPlane1 = 0;
				lPlane2 = 0;
				lPlane3 = 0;
			}
			else
			{
				lPlane0 <<= 1;
				lPlane1 <<= 1;
				lPlane2 <<= 1;
				lPlane3 <<= 1;
			}
		}
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : CanvasIC_To8Plane( sCanvasIC * apCanvasIC, U16 aWidth, U16 aHeight, U16 * apPixels )
* DESCRIPTION : converts a canvas to a 8 plane image
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

void			CanvasIC_To8Plane( sCanvasIC * apCanvasIC, U16 aWidth, U16 aHeight, U16 * apPixels )
{
	U16				lIP;
	U16				i,j;
	U16				lPlane0,lPlane1,lPlane2,lPlane3,lPlane4,lPlane5,lPlane6,lPlane7;


	for( i=0; i<aHeight; i++ )
	{

		lPlane0 = 0;
		lPlane1 = 0;
		lPlane2 = 0;
		lPlane3 = 0;
		lPlane4 = 0;
		lPlane5 = 0;
		lPlane6 = 0;
		lPlane7 = 0;

		for( j=0; j<aWidth; j++ )
		{
			lIP      = (U16)CanvasIC_GetPixel( apCanvasIC, j, i );
			lPlane0 |= (lIP&1);
			lIP    >>= 1;
			lPlane1 |= (lIP&1);
			lIP    >>= 1;
			lPlane2 |= (lIP&1);
			lIP    >>= 1;
			lPlane3 |= (lIP&1);
			lIP    >>= 1;
			lPlane4 |= (lIP&1);
			lIP    >>= 1;
			lPlane5 |= (lIP&1);
			lIP    >>= 1;
			lPlane6 |= (lIP&1);
			lIP    >>= 1;
			lPlane7 |= (lIP&1);

			if( (j&0xF) == 0xF )
			{
				*apPixels++ = lPlane0;
				*apPixels++ = lPlane1;
				*apPixels++ = lPlane2;
				*apPixels++ = lPlane3;
				*apPixels++ = lPlane4;
				*apPixels++ = lPlane5;
				*apPixels++ = lPlane6;
				*apPixels++ = lPlane7;

				lPlane0 = 0;
				lPlane1 = 0;
				lPlane2 = 0;
				lPlane3 = 0;
				lPlane4 = 0;
				lPlane5 = 0;
				lPlane6 = 0;
				lPlane7 = 0;
			}
			else
			{
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
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : CanvasIC_ImageTo565(   sCanvasIC * apCanvasIC, U16 aWidth, U16 aHeight, U16 * apPixels )
* DESCRIPTION : converts a canvas to a 565 image
* AUTHOR      : 28.12.00 PNK
*-----------------------------------------------------------------------------------*/

U8			CanvasIC_To565(   sCanvasIC * apCanvasIC, U16 aWidth, U16 aHeight, U16 * apPixels )
{
	U8 *	lpSrc;
	U16		lPal[ 256 ];
	U16		x,y;


	for( x=0; x<16; x++ )
	{
		lPal[ x ]  = ((apCanvasIC->Palette[ x ].b.r<<8)&0xF800);
		lPal[ x ] |= ((apCanvasIC->Palette[ x ].b.g<<2)&0x07E0);
		lPal[ x ] |= ((apCanvasIC->Palette[ x ].b.b>>3)&0x001F);
	}

	lpSrc = apCanvasIC->pPixels;

	for( y=0; y<aHeight; y++ )
	{
		for( x=0; x<aWidth; x++ )
		{
			*apPixels++ = lPal[ *lpSrc ];
			lpSrc++;
		}
	}

	return( 1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : CanvasIC_ImageFrom565( sCanvasIC * apCanvasIC, U16 aWidth, U16 aHeight, U16 * apPixels )
* DESCRIPTION : converts a canvas to a 565 image
* AUTHOR      : 28.12.00 PNK
*-----------------------------------------------------------------------------------*/

U8			CanvasIC_From565( sCanvasIC * apCanvasIC, U16 aWidth, U16 aHeight, U16 * apPixels )
{
/*
	U16				x,y;
	U16				l565;
	uCanvasPixel *	lpPixel;

	if( !CanvasIC_CreateImage( apCanvasIC, aWidth, aHeight ) )
		return( 0 );

	lpPixel = apCanvasIC->pPixels;

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
*/

	return( 1 );
}

sCanvasIC *		CanvasIC_FromCanvas( sCanvas * apCanvas, const U16 aColourCount, uCanvasPixel * apPal )
{
	return( 0 );
}

#if	0

U8			CanvasIC_Palettize( sCanvasIC * apCanvasIC )
{
}


void		CanvasIC_ReduceColourDepth( sCanvasIC * apCanvasIC, U16 aColourCount )
{
}



/*-----------------------------------------------------------------------------------*
* FUNCTION    : CanvasIC_Load(   sCanvasIC * apCanvasIC, char * apFileName )
* DESCRIPTION : allocates memory for and loads a canvas
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

sCanvasIC *	CanvasIC_Load(   sCanvasIC * apCanvasIC, char * apFileName )
{
	sCanvasIC *	lpCanvasIC;
	

	return( lpCanvasIC );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : CanvasIC_LoadAt( sCanvasIC * apCanvasIC, char * apFileName, void * apMem )
* DESCRIPTION : loads a canvas to a specified memory location
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

U8			CanvasIC_LoadAt( sCanvasIC * apCanvasIC, char * apFileName, void * apMem )
{
	return( 1 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : CanvasIC_Save(   sCanvasIC * apCanvasIC, char * apFileName )
* DESCRIPTION : saves a canvas
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

U8			CanvasIC_Save(   sCanvasIC * apCanvasIC, char * apFileName )
{
	return( 1 );
}

#endif


/*-----------------------------------------------------------------------------------*
* FUNCTION    : CanvasICPixel_FromST( U16 aColour )
* DESCRIPTION : converts a 4.4.4 ST colour to a uCanvasPixel
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

void		CanvasICPixel_FromST( uCanvasPixel * apPixel, U16 * apST )
{
	apPixel->b.a = 0;
	apPixel->b.r = ((*apST>>8) & 0xF) << 4;
	apPixel->b.g = ((*apST>>4) & 0xF) << 4;
	apPixel->b.b = ((*apST   ) & 0xF) << 4;

}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : CanvasICPixel_ToST( uCanvasPixel aPixel )
* DESCRIPTION : converts a uCanvasPixel to a 4.4.4 ST colour
* AUTHOR      : 24.12.00 PNK
*-----------------------------------------------------------------------------------*/

void		CanvasICPixel_ToST( uCanvasPixel * apPixel, U16 * apST )
{
	*apST  = ((apPixel->b.r>>4) & 0xF)<<8;
	*apST |= ((apPixel->b.g>>4) & 0xF)<<4;
	*apST |= ((apPixel->b.b>>4) & 0xF);
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : CanvasIC_GetPixel( sCanvasIC * apCanvasIC, U16 aX, U16 aY )
* DESCRIPTION : returns a pixel from specified canvas location
* AUTHOR      : 28.12.00 PNK
*-----------------------------------------------------------------------------------*/

U8			CanvasIC_GetPixel( sCanvasIC * apCanvasIC, U16 aX, U16 aY )
{
	U32		lOffset;

	if( apCanvasIC->pPixels )
	{
		if( aX < apCanvasIC->Width )
		{
			if( aY < apCanvasIC->Height )
			{
				lOffset  = aY;
				lOffset *= apCanvasIC->Width;
				lOffset += aX;

				return( apCanvasIC->pPixels[ lOffset ] );
			}
		}
	}
	return( 0 );
}



void			CanvasIC_SetPixel( sCanvasIC * apCanvasIC, U16 aX, U16 aY, U8 aPixel )
{
	U32	lOffset;

	if( apCanvasIC->pPixels )
	{
		if( aX < apCanvasIC->Width )
		{
			if( aY < apCanvasIC->Height )
			{
				lOffset   = apCanvasIC->Width;
				lOffset  *= aY;
				lOffset  += aX;

				apCanvasIC->pPixels[ lOffset ] = aPixel;
			}
		}
	}
}

uCanvasPixel	CanvasIC_GetPaletteColour( sCanvasIC * apCanvasIC, U16 aIndex )
{
	return( apCanvasIC->Palette[ aIndex ] );
}

void			CanvasIC_SetPaletteColour( sCanvasIC * apCanvasIC, U16 aIndex, uCanvasPixel aPixel )
{
	apCanvasIC->Palette[ aIndex ] = aPixel;
}

