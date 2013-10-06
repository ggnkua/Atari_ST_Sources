/*
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: COLQUANT.C
::
:: Routines for colour quantizing images
::
:: [c] 2002 Reservoir Gods
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
*/


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"COLQUANT.H"

#include	<GODLIB\MEMORY\MEMORY.H>
#include	<GODLIB\PICTYPES\OCTTREE.H>


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef	struct
{
	uCanvasPixel	Pixel;
	U32				Count;
} sCQCounter;

typedef	struct
{
	U32					TotalCount;
	U32					ActiveCount;
} sCQHeader;

typedef	struct
{
	sCQHeader	Header;
	sCQCounter	Counter[1];
} sCQContainer;


typedef	struct
{
	U32				ColourCount;
	U32				MaxDepth;
	sCQContainer *	pOldPal;
	U32				RGBCounters[ 3 ][ 256 ];
	uCanvasPixel	Palette[ 256 ];
} sCQMedianContainer;


typedef	struct
{
	U32				RedSum;
	U32				GreenSum;
	U32				BlueSum;
	U32				Count;
} sCQLKMColour;


/* ###################################################################################
#  DATA
################################################################################### */

U16	gColourQuantizeMethod     = eCOLOURQUANTIZE_MEDIANCUT;
U32	gColourQuantizeVariance   = 1024;
U32	gColourQuantizeIterations = 1024;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

sCQContainer *	ColourQuantize_ContainerInit( const U32 aCount );
void			ColourQuantize_ContainerAdd( sCQContainer * apContainer, const U32 aPixel );
void			ColourQuantize_ContainerSort( sCQContainer * apContainer );
U16				ColourQuantize_GetIndex( const U32 aPixel, uCanvasPixel * apPal, const U16 aColourCount );

void			ColourQuantize_MedianSubDivide( sCQMedianContainer * apContainer, U32 aRGBmin, U32 aRGBmax, U32 aDepth );


/* ###################################################################################
#  FUNCTIONS
################################################################################### */


/*-----------------------------------------------------------------------------------*
* FUNCTION    : ColourQuantize_FromCanvas( sCanvas * apCanvas, const U16 aColourCount )
* DESCRIPTION : quantizes canvas image
* AUTHOR      : 12.05.02 PNK
*-----------------------------------------------------------------------------------*/

sCanvasIC *		ColourQuantize_FromCanvas( sCanvas * apCanvas, const U16 aColourCount )
{
	sCanvasIC *	lpCanvasIC;

	switch( gColourQuantizeMethod )
	{

	case	eCOLOURQUANTIZE_BITSHIFT:
		lpCanvasIC = ColourQuantize_BitShift( apCanvas, aColourCount );
		break;

	case	eCOLOURQUANTIZE_POPULAR:
		lpCanvasIC = ColourQuantize_Popular( apCanvas, aColourCount );
		break;

	case	eCOLOURQUANTIZE_MEDIANCUT:
		lpCanvasIC = ColourQuantize_MedianCut( apCanvas, aColourCount );
		break;

	case	eCOLOURQUANTIZE_LKM:
		lpCanvasIC = ColourQuantize_LKM( apCanvas, aColourCount );
		break;

	case	eCOLOURQUANTIZE_OCTREE:
		lpCanvasIC = ColourQuantize_Octree( apCanvas, aColourCount );
		break;

	default:
		lpCanvasIC = 0;
		break;
	}

	return( lpCanvasIC );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : ColourQuantize_BitShift(  sCanvas * apCanvas, const U16 aColourCount )
* DESCRIPTION : quantizes images
* AUTHOR      : 12.05.02 PNK
*-----------------------------------------------------------------------------------*/

sCanvasIC *		ColourQuantize_BitShift(  sCanvas * apCanvas, const U16 aColourCount )
{
	sCanvasIC *		lpCanvasIC;
	uCanvasPixel *	lpSrc;
	U8 *			lpDst;
	U16				x,y;

	lpCanvasIC = CanvasIC_Create();

	if( lpCanvasIC )
	{
		if( CanvasIC_CreateImage( lpCanvasIC, apCanvas->Width, apCanvas->Height ) )
		{

			lpSrc = apCanvas->pPixels;
			lpDst = lpCanvasIC->pPixels;

			switch( aColourCount )
			{

			case	2:
				lpCanvasIC->Palette[ 0 ].l = 0x00000000;
				lpCanvasIC->Palette[ 1 ].l = 0xFFFFFFFF;

				for( y=0; y<apCanvas->Height; y++ )
				{
					for( x=0; x<apCanvas->Width; x++ )
					{
						*lpDst = ((lpSrc->b.r>>7) | (lpSrc->b.g>>7) | (lpSrc->b.b>>7))&1;
						lpDst++;
						lpSrc++;
					}
				}

				break;

			case	4:
				lpCanvasIC->Palette[ 0 ].l = 0x00000000;
				lpCanvasIC->Palette[ 1 ].l = 0x55555555;
				lpCanvasIC->Palette[ 2 ].l = 0xAAAAAAAA;
				lpCanvasIC->Palette[ 1 ].l = 0xFFFFFFFF;

				for( y=0; y<apCanvas->Height; y++ )
				{
					for( x=0; x<apCanvas->Width; x++ )
					{
						*lpDst = ((lpSrc->b.r>>7)&1) + ((lpSrc->b.g>>7)&1) + ((lpSrc->b.b>>7)&1);
						lpDst++;
						lpSrc++;
					}
				}
				break;

			case	16:

				for( x=0; x<256; x++ )
				{
					lpCanvasIC->Palette[ x ].b.r = (((x>>3)&1)<<7);
					lpCanvasIC->Palette[ x ].b.g = (((x>>1)&3)<<6);
					lpCanvasIC->Palette[ x ].b.b = ((x&1)<<7);
				}

				for( y=0; y<apCanvas->Height; y++ )
				{
					for( x=0; x<apCanvas->Width; x++ )
					{
						*lpDst = (((lpSrc->b.r>>7)&1)<<3) | (((lpSrc->b.g>>6)&3)<<1) | ((lpSrc->b.b>>7)&1);
						lpDst++;
						lpSrc++;
					}
				}
				break;

			case	256:

				for( x=0; x<256; x++ )
				{
					lpCanvasIC->Palette[ x ].b.r = (((x>>5)&7)<<5);
					lpCanvasIC->Palette[ x ].b.g = (((x>>2)&7)<<5);
					lpCanvasIC->Palette[ x ].b.b = ((x&3)<<6);
				}

				for( y=0; y<apCanvas->Height; y++ )
				{
					for( x=0; x<apCanvas->Width; x++ )
					{
						*lpDst = (((lpSrc->b.r>>5)&3)<<5) | (((lpSrc->b.g>>5)&3)<<2) | ((lpSrc->b.b>>6)&3);
						lpDst++;
						lpSrc++;
					}
				}
				break;
			}
		}
		else
		{
			CanvasIC_Destroy( lpCanvasIC );
			lpCanvasIC = 0;
		}
	}

	return( lpCanvasIC );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : ColourQuantize_Popular(   sCanvas * apCanvas, const U16 aColourCount );
* DESCRIPTION : quantizes images
* AUTHOR      : 12.05.02 PNK
*-----------------------------------------------------------------------------------*/

sCanvasIC *		ColourQuantize_Popular(   sCanvas * apCanvas, const U16 aColourCount )
{
	sCQContainer *	lpContainer;
	sCanvasIC *		lpCanvasIC;
	uCanvasPixel *	lpSrc;
	U8 *			lpDst;
	U32				lSize;
	U32				i;

	lSize  = apCanvas->Width;
	lSize *= apCanvas->Height;

	lpCanvasIC  = 0;
	lpContainer = ColourQuantize_ContainerInit( lSize );
	
	if( lpContainer )
	{
		lpCanvasIC = CanvasIC_Create();

		if( lpCanvasIC )
		{
			if( CanvasIC_CreateImage( lpCanvasIC, apCanvas->Width, apCanvas->Height ) )
			{
				lpSrc = apCanvas->pPixels;
				for( i=0; i<lSize; i++ )
				{
					ColourQuantize_ContainerAdd( lpContainer, lpSrc->l );
					lpSrc++;
				}
				ColourQuantize_ContainerSort( lpContainer );

				for( i=0; i<aColourCount; i++ )
				{
					lpCanvasIC->Palette[ i ] = lpContainer->Counter[ i ].Pixel;
				}

				lpSrc = apCanvas->pPixels;
				lpDst = lpCanvasIC->pPixels;
				for( i=0; i<lSize; i++ )
				{
					*lpDst = (U8)ColourQuantize_GetIndex( lpSrc->l, &lpCanvasIC->Palette[0], aColourCount );
					lpSrc++;
					lpDst++;
				}
				ColourQuantize_ContainerSort( lpContainer );

			}
		}

		Memory_Release( lpContainer );
	}

	return( lpCanvasIC );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : ColourQuantize_MedianSubDivide( sCQMedianContainer * apContainer, U32 aRGBmin, U32 aRGBmax, U32 aDepth )
* DESCRIPTION : performs median cut
* AUTHOR      : 12.05.02 PNK
*-----------------------------------------------------------------------------------*/

void			ColourQuantize_MedianSubDivide( sCQMedianContainer * apContainer, U32 aRGBmin, U32 aRGBmax, U32 aDepth )
{
	uCanvasPixel	lStart0;
	uCanvasPixel	lEnd0;
	uCanvasPixel	lStart1;
	uCanvasPixel	lEnd1;
	sCQCounter *	lpEntry;
	S16				lDiff[ 3 ];
	U16				lDiffIndex;
	U32				lActiveColours;
	U32				lMedian;
	U32				lPos;
	S32				i;

	lStart0.l = aRGBmin;
	lEnd0.l   = aRGBmax;

	lStart1.l = aRGBmin;
	lEnd1.l   = aRGBmax;

	if( aDepth == apContainer->MaxDepth )
	{
		lStart1.b.r = (lStart0.b.r + lEnd0.b.r)>>1;
		lStart1.b.g = (lStart0.b.g + lEnd0.b.g)>>1;
		lStart1.b.b = (lStart0.b.b + lEnd0.b.b)>>1;

		if( apContainer->ColourCount < 256 )
		{
			apContainer->Palette[ apContainer->ColourCount ] = lStart1;
			apContainer->ColourCount++;
		}
	}
	else
	{
		for( i=0; i<256; i++ )
		{
			apContainer->RGBCounters[ 0 ][ i ] = 0L;
			apContainer->RGBCounters[ 1 ][ i ] = 0L;
			apContainer->RGBCounters[ 2 ][ i ] = 0L;
		}

		lpEntry = &apContainer->pOldPal->Counter[ 0 ];
		i = apContainer->pOldPal->Header.ActiveCount;


		lActiveColours = 0;
		while( i>0 )
		{
			if( (lpEntry->Pixel.b.r >= lStart0.b.r) && (lpEntry->Pixel.b.r <= lEnd0.b.r) )
			{
				if( (lpEntry->Pixel.b.g >= lStart0.b.g) && (lpEntry->Pixel.b.g <= lEnd0.b.g) )
				{
					if( (lpEntry->Pixel.b.b >= lStart0.b.b) && (lpEntry->Pixel.b.b <= lEnd0.b.b) )
					{
						apContainer->RGBCounters[ 0 ][ lpEntry->Pixel.b.r ] += lpEntry->Count;
						apContainer->RGBCounters[ 1 ][ lpEntry->Pixel.b.g ] += lpEntry->Count;
						apContainer->RGBCounters[ 2 ][ lpEntry->Pixel.b.b ] += lpEntry->Count;
						lActiveColours++;
					}
				}
			}
			lpEntry++;
			i--;
		}

		if( lActiveColours <= 1 )
		{
			lStart1.b.r = (lStart0.b.r + lEnd0.b.r)>>1;
			lStart1.b.g = (lStart0.b.g + lEnd0.b.g)>>1;
			lStart1.b.b = (lStart0.b.b + lEnd0.b.b)>>1;

			if( apContainer->ColourCount < 256 )
			{
				apContainer->Palette[ apContainer->ColourCount ] = lStart1;
				apContainer->ColourCount++;
			}
		}
		else
		{
			lDiff[ 0 ] = lEnd0.b.r - lStart0.b.r;
			lDiff[ 1 ] = lEnd0.b.g - lStart0.b.g;
			lDiff[ 2 ] = lEnd0.b.b - lStart0.b.b;

			for( i=0; i<3; i++ )
			{
				if( lDiff[ i ] < 0 )
				{
					lDiff[ i ] = 0 - lDiff[ i ];
				}
			}

			lDiffIndex = 0;
			if( lDiff[ 1 ] > lDiff[ 0 ] )
			{
				lDiffIndex = 1;
			}
			if( lDiff[ 2 ] > lDiff[ lDiffIndex ] )
			{
				lDiffIndex = 2;
			}


			lPos = 0;
			lMedian = lActiveColours>>1;
			if( !lMedian )
			{
				lMedian = 1;
			}
			i = 256;
			do
			{
				i--;
				lPos += apContainer->RGBCounters[ lDiffIndex ][ i ];
			} while( (i>=0) && (lPos < lMedian ) );



			switch( lDiffIndex )
			{
				case 0:
					lEnd0.b.r   = (U8)i;
					lStart1.b.r = (U8)i;
					break;
				case 1:
					lEnd0.b.g   = (U8)i;
					lStart1.b.g = (U8)i;
					break;
				case 2:
					lEnd0.b.b   = (U8)i;
					lStart1.b.b = (U8)i;
					break;
			}

			ColourQuantize_MedianSubDivide( apContainer, lStart0.l, lEnd0.l, aDepth+1 );
			ColourQuantize_MedianSubDivide( apContainer, lStart1.l, lEnd1.l, aDepth+1 );
		}
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : ColourQuantize_MedianCut( sCanvas * apCanvas, const U16 aColourCount )
* DESCRIPTION : quantizes images
* AUTHOR      : 12.05.02 PNK
*-----------------------------------------------------------------------------------*/

sCanvasIC *		ColourQuantize_MedianCut( sCanvas * apCanvas, const U16 aColourCount )
{
	sCanvasIC *			lpCanvasIC;
	sCQMedianContainer	lContainer;
	uCanvasPixel *		lpSrc;
	U32					lSize;
	U32					i;


	lSize  = apCanvas->Width;
	lSize *= apCanvas->Height;

	lpCanvasIC = 0;

	lContainer.pOldPal =  ColourQuantize_ContainerInit( lSize );

	if( lContainer.pOldPal )
	{

		lpSrc = apCanvas->pPixels;
		for( i=0; i<lSize; i++ )
		{
			ColourQuantize_ContainerAdd( lContainer.pOldPal, lpSrc->l );
			lpSrc++;
		}

		ColourQuantize_MedianSubDivide( &lContainer, 0L, 0xFFFFFFFFL, 0 );

		Memory_Release( lContainer.pOldPal );

		lpCanvasIC = CanvasIC_Create();

		if( lpCanvasIC )
		{
			if( CanvasIC_CreateImage( lpCanvasIC, apCanvas->Width, apCanvas->Height ) )
			{
				for( i=0; i<aColourCount; i++ )
				{
					lpCanvasIC->Palette[ i ] = lContainer.Palette[ i ];
				}
			}
		}
		
	}


	return( lpCanvasIC );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : ColourQuantize_BitShift(  sCanvas * apCanvas, const U16 aColourCount )
* DESCRIPTION : quantizes images
* AUTHOR      : 12.05.02 PNK
*-----------------------------------------------------------------------------------*/

sCanvasIC *		ColourQuantize_LKM(       sCanvas * apCanvas, const U16 aColourCount )
{
	sCQContainer *	lpContainer;
	sCanvasIC *		lpCanvasIC;
	uCanvasPixel *	lpSrc;
	uCanvasPixel *	lpPal;
	sCQLKMColour *	lpColours;
	U8 *			lpDst;
	U32				lVariance;
	U32				lIterations;
	U32				lSize;
	U32				i;
	U32				lRandomIndex;
	S32				lDiff;
	U16				lIndex;

	lSize  = apCanvas->Width;
	lSize *= apCanvas->Height;

	lpCanvasIC  = 0;
	lpContainer = ColourQuantize_ContainerInit( lSize );
	
	if( lpContainer )
	{
		lpCanvasIC = CanvasIC_Create();

		if( lpCanvasIC )
		{
			if( CanvasIC_CreateImage( lpCanvasIC, apCanvas->Width, apCanvas->Height ) )
			{
				lpSrc = apCanvas->pPixels;
				for( i=0; i<lSize; i++ )
				{
					ColourQuantize_ContainerAdd( lpContainer, lpSrc->l );
					lpSrc++;
				}

				lSize  = aColourCount;
				lSize *= sizeof( sCQLKMColour );

				lpColours = (sCQLKMColour*)Memory_Calloc( lSize );

				if( lpColours )
				{
					lSize  = aColourCount;
					lSize *= sizeof( uCanvasPixel );

					lpPal = (uCanvasPixel*)Memory_Calloc( lSize );
					
					if( lpPal )
					{
						for( i=0; i<aColourCount; i++ )
						{
							lpPal[ i ] = lpContainer->Counter[ i ].Pixel;
						}

						lSize  = apCanvas->Width;
						lSize *= apCanvas->Height;

						lIterations  = 0;
						lRandomIndex = 0;
						do
						{
							for( i=0; i<aColourCount; i++ )
							{
								lpColours[ i ].Count    = 0;
								lpColours[ i ].BlueSum  = 0;
								lpColours[ i ].GreenSum = 0;
								lpColours[ i ].RedSum   = 0;
							}

							for( i=0; i<lpContainer->Header.ActiveCount; i++ )
							{
								lIndex = ColourQuantize_GetIndex( lpContainer->Counter[ i ].Pixel.l, lpPal, aColourCount );
								lpColours[ lIndex ].Count++;
								lpColours[ lIndex ].RedSum   += lpContainer->Counter[ i ].Pixel.b.r;
								lpColours[ lIndex ].GreenSum += lpContainer->Counter[ i ].Pixel.b.g;
								lpColours[ lIndex ].BlueSum  += lpContainer->Counter[ i ].Pixel.b.b;
							}

							lVariance = 0;
							for( i=0; i<aColourCount; i++ )
							{
								if( !lpColours[ i ].Count )
								{
									lpColours[ i ].RedSum   = lpContainer->Counter[ lRandomIndex ].Pixel.b.r;
									lpColours[ i ].GreenSum = lpContainer->Counter[ lRandomIndex ].Pixel.b.g;
									lpColours[ i ].BlueSum  = lpContainer->Counter[ lRandomIndex ].Pixel.b.b;
									lRandomIndex++;
									if( lRandomIndex > lpContainer->Header.ActiveCount )
									{
										lRandomIndex = 0;
									}
								}
								else
								{
									lpColours[ i ].RedSum   /= lpColours[ i ].Count;
									lpColours[ i ].GreenSum /= lpColours[ i ].Count;
									lpColours[ i ].BlueSum  /= lpColours[ i ].Count;
								}

								lDiff= (lpColours[ i ].RedSum - lpPal[ i ].b.r);
								if( lDiff < 0 )
								{
									lDiff = -lDiff;
								}
								lVariance += lDiff;

								lDiff= (lpColours[ i ].GreenSum - lpPal[ i ].b.g);
								if( lDiff < 0 )
								{
									lDiff = -lDiff;
								}
								lVariance += lDiff;
								lDiff= (lpColours[ i ].GreenSum - lpPal[ i ].b.g);
								if( lDiff < 0 )
								{
									lDiff = -lDiff;
								}
								lVariance += lDiff;

								lpPal[ i ].b.r = (U8)lpColours[ i ].RedSum;
								lpPal[ i ].b.g = (U8)lpColours[ i ].GreenSum;
								lpPal[ i ].b.b = (U8)lpColours[ i ].BlueSum;

							}

							lIterations++;
						} while( (lVariance < gColourQuantizeVariance) && (lIterations < gColourQuantizeIterations) );


						lpSrc = apCanvas->pPixels;
						lpDst = lpCanvasIC->pPixels;
						for( i=0; i<lSize; i++ )
						{
							*lpDst = (U8)ColourQuantize_GetIndex( lpSrc->l, &lpCanvasIC->Palette[0], aColourCount );
							lpSrc++;
							lpDst++;
						}
						ColourQuantize_ContainerSort( lpContainer );

						Memory_Release( lpPal );
					}
					Memory_Release( lpColours );
				}

			}
		}

		Memory_Release( lpContainer );
	}

	return( lpCanvasIC );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : ColourQuantize_BitShift(  sCanvas * apCanvas, const U16 aColourCount )
* DESCRIPTION : quantizes images
* AUTHOR      : 12.05.02 PNK
*-----------------------------------------------------------------------------------*/

sCanvasIC *		ColourQuantize_Octree(    sCanvas * apCanvas, const U16 aColourCount )
{
	return( 0 );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : ColourQuantize_ContainerInit( const U32 aCount )
* DESCRIPTION : inits a container
* AUTHOR      : 12.05.02 PNK
*-----------------------------------------------------------------------------------*/

sCQContainer * ColourQuantize_ContainerInit( const U32 aCount )
{
	sCQContainer *	lpContainer;
	U32				lSize;

	lSize  = aCount;
	lSize *= sizeof( sCQCounter );
	lSize += sizeof( sCQHeader  );
	
	lpContainer = Memory_Calloc( lSize );

	if( lpContainer )
	{
		lpContainer->Header.ActiveCount = 0;
		lpContainer->Header.TotalCount  = 0;
	}

	return( lpContainer );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : ColourQuantize_ContainerAdd( sCQContainer * apContainer, const U32 aPixel )
* DESCRIPTION : adds a colour to a container
* AUTHOR      : 12.05.02 PNK
*-----------------------------------------------------------------------------------*/

void	 ColourQuantize_ContainerAdd( sCQContainer * apContainer, const U32 aPixel )
{
	U32	i;

	for( i=0; i<apContainer->Header.ActiveCount; i++ )
	{
		if( apContainer->Counter[ i ].Pixel.l == aPixel )
		{
			apContainer->Counter[ i ].Count++;
			return;
		}
	}
	apContainer->Counter[ apContainer->Header.ActiveCount ].Pixel.l = aPixel;
	apContainer->Counter[ apContainer->Header.ActiveCount ].Count   = 1;
	apContainer->Header.ActiveCount++;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : ColourQuantize_ContainerSort( sCQContainer * apContainer )
* DESCRIPTION : sorts a container
* AUTHOR      : 12.05.02 PNK
*-----------------------------------------------------------------------------------*/

void			ColourQuantize_ContainerSort( sCQContainer * apContainer )
{
	U8	lSwitchFlag;
	U32			lGap;
	S32			i;
	sCQCounter	lTemp;

	lSwitchFlag = 0;
	lGap        = apContainer->Header.ActiveCount;

	while( (lGap>1) || (lSwitchFlag) )
	{
		lGap *= 10L;
		lGap /= 13L;

		if( lGap < 1 )
		{
			lGap = 1;
		}

		if( (lGap==9) || (lGap==10) )
		{
			lGap = 11;
		}

		lSwitchFlag = 0;

		for( i=1; i<(S32)(apContainer->Header.ActiveCount-lGap); i++ )
		{
			if( apContainer->Counter[ i ].Count > apContainer->Counter[ i+lGap ].Count )
			{
				lTemp = apContainer->Counter[ i ];
				apContainer->Counter[ i      ] = apContainer->Counter[ i+lGap ];
				apContainer->Counter[ i+lGap ] = lTemp;
				lSwitchFlag = 1;
			}
		}
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : ColourQuantize_GetIndex( const U32 aPixel, uCanvasPixel * apPal, const U16 aColourCount )
* DESCRIPTION : returns index of colour in a palette
* AUTHOR      : 12.05.02 PNK
*-----------------------------------------------------------------------------------*/

U16				ColourQuantize_GetIndex( const U32 aPixel, uCanvasPixel * apPal, const U16 aColourCount )
{
	U32				lIndex;
	S16				lDiffR;
	S16				lDiffG;
	S16				lDiffB;
	S16				lBestDiff;
	U16				i;
	uCanvasPixel *	lpPal;
	uCanvasPixel	lPixel;

	lBestDiff = 0x7FFF;
	lPixel.l  = aPixel;
	lIndex    = 0;
	lpPal     = apPal;

	for( i=0; i<aColourCount; i++ )
	{
		lDiffR = lpPal->b.r - lPixel.b.r;
		lDiffG = lpPal->b.g - lPixel.b.g;
		lDiffB = lpPal->b.b - lPixel.b.b;

		if( lDiffR < 0 )
		{
			lDiffR = -lDiffR;
		}
		if( lDiffG < 0 )
		{
			lDiffG = -lDiffG;
		}
		if( lDiffB < 0 )
		{
			lDiffB = -lDiffB;
		}

		lDiffR += lDiffG;
		lDiffR += lDiffB;

		if( 0 == lDiffR )
		{
			return( i );
		}
		else if( lDiffR < lBestDiff )
		{
			lIndex    = i;
			lBestDiff = lDiffR;
		}

		lpPal++;
	}


	return( lIndex );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : ColourQuantize_SetMethod( const U16 aMethod )
* DESCRIPTION : sets quantization method
* AUTHOR      : 12.05.02 PNK
*-----------------------------------------------------------------------------------*/

void			ColourQuantize_SetMethod( const U16 aMethod )
{
	gColourQuantizeMethod = aMethod;
}


/*-----------------------------------------------------------------------------------*
* FUNCTION    : ColourQuantize_GetMethod( void )
* DESCRIPTION : returns quantization method
* AUTHOR      : 12.05.02 PNK
*-----------------------------------------------------------------------------------*/

U16				ColourQuantize_GetMethod( void )
{
	return( gColourQuantizeMethod );
}
