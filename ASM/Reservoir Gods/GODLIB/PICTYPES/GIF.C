/*
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: GIF.C
::
:: Routines for manipulating art director GIF images
::
:: [c] 2002 Reservoir Gods
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
*/


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"GIF.H"

#include	<GODLIB\MEMORY\MEMORY.H>


/* ###################################################################################
#  DEFINES
################################################################################### */

#define	dGIF_FIELD_IMAGE	0x2C

#define	dGIF_HASH_CC		0xFFFE
#define	dGIF_HASH_EOI		0xFFFF


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef	struct
{
	S16	Value;
	S16	ChildIndex;
	S16	NextIndex;
} sGifHashEntry;


typedef	struct
{
	S16	Stack[  4096 ];
	S16	Prefix[ 4096 ];
	S16	Ext[    4096 ];
} sGifDecodeTable;


/* ###################################################################################
#  FUNCTIONS
################################################################################### */

/*-----------------------------------------------------------------------------------*
* FUNCTION    : Gif_ToCanvas( sGif * apGif )
* DESCRIPTION : converts an GIF image to a canvas
* AUTHOR      : 28.12.00 PNK
*-----------------------------------------------------------------------------------*/

sCanvas *		Gif_ToCanvas( sGif * apGif )
{
	sCanvas *		lpCanvas;
/*	uCanvasPixel	lPal[ 16 ];*/

	lpCanvas = Canvas_Create();

/*	Canvas_PaletteFromST(   &lPal[ 0 ],  16, apGif->Palettes[ 0 ] );
	lpCanvas = Canvas_ImageFrom4Plane( 320, 200, apGif->Pixels, &lPal[ 0 ] );
*/
	return( lpCanvas );
}

void	Gif_CodeTableInit( sGifHashEntry * apEntry, const U16 aBitDepth )
{
	U16	i;
	U16	lLen;

	lLen = (1<<aBitDepth);

	for( i=0; i<lLen; i++ )
	{
		apEntry[ i ].ChildIndex = -1;
		apEntry[ i ].NextIndex  = -1;
	}

	lLen >>= 1;
	for( i=0; i<lLen; i++ )
	{
		apEntry[ i ].Value = i;
	}
	apEntry[ lLen+0 ].Value = dGIF_HASH_CC;
	apEntry[ lLen+1 ].Value = dGIF_HASH_EOI;
}


S16		Gif_CodeTableFind( sGifHashEntry * apEntry, const S16 aPrefix, const U8 aByte, const U16 aEntryCount )
{
	S16		lIndex;
	S16		lChild;

	if( aPrefix < 0 )
	{
		return( aByte );
	}

	lIndex = aPrefix;

	while( lIndex > 0 )
	{
		lChild = apEntry[ lIndex ].ChildIndex;
		if( lIndex >= 0 )
		{
			if( (U8)apEntry[ lChild ].Value == aByte )
			{
				return( lChild );
			}
		}
		lIndex = apEntry[ lIndex ].NextIndex;
	} 

	return( - 1 );
}


#define	mGIF_WRITEBITS( aValue, aBits )											\
	lBits  = aBits;																\
	lValue = aValue;															\
	while( lBits )																\
	{																			\
		if( ((254 == lIndex) && ( !lBitsLeft )) || ( lIndex > 254 ) )			\
		{																		\
			lpDst   += 255;														\
			lpBlock  = lpDst;													\
			*lpDst++ = 255;														\
			lIndex   = 0;														\
			lBitsLeft= 8;														\
		}																		\
		if( lBits < lBitsLeft )													\
		{																		\
			lpDst[ lIndex ] |= ( lValue & ((1<<lBits)-1) );						\
			lBitsLeft       -= lBits;											\
			lBits            = 0;												\
		}																		\
		else																	\
		{																		\
			lpDst[ lIndex ] |= ((lValue & ((1<<lBits)-1) ) << (8-lBitsLeft));	\
			lValue         >>= lBitsLeft;										\
			lBits           -= lBitsLeft;										\
			lIndex++;															\
			lpDst[ lIndex ]  = 0;												\
			lBitsLeft		 = 8;												\
		}																		\
	}


U32	Gif_Encode( sCanvasIC * apCanvas, U8 * apData )
{
	U8 *			lpDst;
	sGifHashEntry *	lpTable;
	U8 *			lpBlock;
	U8 *			lpSrc;
	U8				lByte;
	S16				lPrefix;
	S16				lValue;
	U16				lClearCode;
	U16				lCodeSize;
	U16				lData;
	U32				lSize;
	U16				lBits;
	U16				lBitsLeft;
	U16				lIndex;
	S16				lLimit;
	S16				lNext;

	lpTable = (sGifHashEntry*)Memory_Alloc( sizeof(sGifHashEntry)*4096 );

	if( lpTable )
	{
		lpDst  = apData;

		*lpDst++ = 8;

		lpBlock  = lpDst;
		*lpDst++ = 255;

		lCodeSize = 9;

		Gif_CodeTableInit( lpTable, lCodeSize );

		lBitsLeft = 8;
		lIndex    = 0;

		lData     = 0;

		lClearCode = (1<<(lCodeSize-1));
		lNext      = lClearCode+2;
		lLimit     = (1<<lCodeSize)-1;

		mGIF_WRITEBITS( lClearCode, lCodeSize );

		lSize  = apCanvas->Width;
		lSize *= apCanvas->Height;
		lSize--;

		lpSrc = apCanvas->pPixels;

		lPrefix = -1;

		while( lSize )
		{
			lByte  = *lpSrc++;
			lIndex = Gif_CodeTableFind( lpTable, lPrefix, lByte, lNext );
			if( lIndex >= 0 )
			{
				lPrefix = lIndex;
			}
			else
			{
				mGIF_WRITEBITS( lPrefix, lCodeSize );

				lIndex = lPrefix;

				if( lpTable[ lIndex ].ChildIndex >= 0 )
				{
					while( lpTable[ lIndex ].NextIndex >= 0 )
					{
						lIndex = lpTable[ lIndex ].NextIndex;
					}
					lpTable[ lIndex ].NextIndex = lNext;
				}
				else
				{
					lpTable[ lIndex ].ChildIndex = lNext;
				}

				lpTable[ lNext ].Value      = lByte;
				lpTable[ lNext ].ChildIndex = -1;
				lpTable[ lNext ].NextIndex  = -1;

				lNext++;

				if( lNext > lLimit )
				{
					lCodeSize++;
					if( lCodeSize > 12 )
					{
						mGIF_WRITEBITS( lClearCode, 12 );
						lCodeSize = 9;
						Gif_CodeTableInit( lpTable, lCodeSize );
					}
					lLimit = (1<<lCodeSize)-1;
				}

				lPrefix = lByte;
			}

			lSize--;
		}

		if( lPrefix >= 0 )
		{
			mGIF_WRITEBITS( lPrefix, lCodeSize );
		}
		mGIF_WRITEBITS( lClearCode+1, lCodeSize );

		*lpBlock = lIndex;

		Memory_Release( lpTable );
	}

	return( 0 );
}




U32	Gif_Decode( sCanvasIC * apCanvas, U8 * apData, const U16 aCodeSize )
{
    S16		lClearCode;
	S16		lEOI;
	S16		lBaseCodeSize;
	S16		lNext;
	S16		lCurrCode;
	S16		lFirst;
    S16		lGrabbedBits;
	S16		lCodeSize; 
	S16		lCodeMask; 
	S16		lSP;
	S16		lPrevCode;
	U32		lWorkBits;
    S16		lBufIndex;
	S16		lBufLen;
	U8 *	lpSrc;
	U8 *	lpDst;
	sGifDecodeTable *	lpTable;

	lpTable = Memory_Calloc( sizeof(sGifDecodeTable) );
	if( lpTable )
	{

		lCurrCode    = -1;
		lPrevCode    = -2;
		lSP          = 0;
		lGrabbedBits = 0;
		lWorkBits    = 0;
		lBufIndex    = 0;
		lBufLen      = 0;
		lpSrc        = apData;


		lBaseCodeSize = *lpSrc++;
		lClearCode    = 1 << lBaseCodeSize;
		lEOI          = lClearCode + 1;
		lNext         = lClearCode + 2;
		lCodeSize     = lBaseCodeSize + 1;
		lCodeMask     = (1 << lCodeSize) - 1;
		lpDst         = apCanvas->pPixels;

		while (lCurrCode != lEOI) 
		{
			while (lGrabbedBits < lCodeSize) 
			{
				if (lBufIndex == lBufLen) 
				{
					lpSrc  += lBufLen;
					lBufLen = *lpSrc++;
					lBufIndex = 0;
				}
				lWorkBits |= ((U32)lpSrc[lBufIndex++]) << lGrabbedBits;
				lGrabbedBits += 8;
			}

			lCurrCode     = lWorkBits & lCodeMask;
			lWorkBits    >>= lCodeSize;
			lGrabbedBits -= lCodeSize;

			if( lPrevCode == -2 )
			{
				lCurrCode = lClearCode;
			}

			if (lCurrCode == lClearCode) 
			{          
				lCodeSize = lBaseCodeSize + 1;      /* Original lCurrCode size */
				lCodeMask = (1 << lCodeSize) - 1;   /* Corresponding mask */
				lNext     = lClearCode + 2;         /* lFirst pos. in tables */
				lPrevCode = -1;                     /* Next lCurrCode is a root lCurrCode */
			} 
			else if (lCurrCode == lEOI) 
			{        
			} 
			else if (lPrevCode == -1) 
			{   
				*lpDst++ = lCurrCode;
				lFirst = lPrevCode = lCurrCode;
			} 
			else 
			{                               
				if (lCurrCode >= lNext) 
				{    
					lpTable->Stack[lSP++] = lFirst;
					lFirst = lPrevCode;
				} 
				else  
				{
					lFirst = lCurrCode;
				}
				while (lFirst >= lClearCode) 
				{ 
					lpTable->Stack[lSP++] = lpTable->Ext[lFirst];
					lFirst                = lpTable->Prefix[lFirst];
				}
				lpTable->Stack[lSP++] = lFirst;
				while( lSP ) 
				{
					*lpDst++ = lpTable->Stack[ --lSP ];
				}
				lpTable->Prefix[lNext] = lPrevCode;
				lpTable->Ext[lNext++]  = lFirst;
				lPrevCode              = lCurrCode;

				if( (lNext > lCodeMask) && (lCodeSize != 12) ) 
				{
					lCodeSize++;
					lCodeMask = (1 << lCodeSize) - 1;
				}
			}
		}

		Memory_Release( lpTable );
	}
    return( 1 );
}





/*-----------------------------------------------------------------------------------*
* FUNCTION    : Gif_FromCanvas( sCanvas * apCanvas, uCanvasPixel * apPalette )
* DESCRIPTION : converts to an GIF file from canvas
* AUTHOR      : 28.12.00 PNK
*-----------------------------------------------------------------------------------*/

sGif *		Gif_FromCanvas( sCanvas * apCanvas, uCanvasPixel * apPalette )
{	
	sGif *					lpGif;
	sCanvasIC *				lpCanvasIC;
	sGifColour *			lpPal;
	sGifImageDescriptor *	lpDesc;
	U32						lSize;
	U16						i;
	U8 *					lpData;

	lpGif      = 0;
	lpCanvasIC = CanvasIC_FromCanvas( apCanvas, 16, apPalette );

	if( lpCanvasIC )
	{
		lSize  = apCanvas->Width;
		lSize *= apCanvas->Height;
		lSize += sizeof( sGifHeader );
		lSize += sizeof( sGifColour ) * 256;
		lSize += sizeof( sGifImageDescriptor );
		lpGif  = (sGif*)Memory_Calloc( sizeof(sGif) );

		if( lpGif )
		{
			lpGif->Header.BackgroundColourIndex = 0;
			lpGif->Header.Height[ 0 ]           = apCanvas->Height & 0xFF;
			lpGif->Header.Height[ 1 ]           =(apCanvas->Height>>8) & 0xFF;
			lpGif->Header.Sig[ 0 ]              = 'G';
			lpGif->Header.Sig[ 1 ]              = 'I';
			lpGif->Header.Sig[ 2 ]              = 'F';
			lpGif->Header.Version[ 0 ]          = '8';
			lpGif->Header.Version[ 1 ]          = '9';
			lpGif->Header.Version[ 2 ]          = 'a';
			lpGif->Header.PixelAspectRatio      = 0;
			lpGif->Header.Flags                 = 0xF7;
			lpGif->Header.Width[ 0 ]            = apCanvas->Width & 0xFF;
			lpGif->Header.Width[ 1 ]            =(apCanvas->Width>>8) & 0xFF;

			lpPal = (sGifColour*)&lpGif->Data[ 0 ];

			for( i=0; i<256; i++ )
			{
				lpPal->R = lpCanvasIC->Palette[ i ].b.r;
				lpPal->G = lpCanvasIC->Palette[ i ].b.g;
				lpPal->B = lpCanvasIC->Palette[ i ].b.b;
				lpPal++;
			}

			lpDesc              = (sGifImageDescriptor*)lpPal;
			lpDesc->Seperator   = dGIF_FIELD_IMAGE;
			lpDesc->Height[ 0 ] = lpGif->Header.Height[ 0 ];
			lpDesc->Height[ 1 ] = lpGif->Header.Height[ 1 ];
			lpDesc->Flags       = 0;
			lpDesc->X[ 0 ]      = 0;
			lpDesc->X[ 1 ]      = 0;
			lpDesc->Y[ 0 ]      = 0;
			lpDesc->Y[ 1 ]      = 0;
			lpDesc->Width[ 0 ]  = lpGif->Header.Width[ 0 ];
			lpDesc->Width[ 1 ]  = lpGif->Header.Width[ 1 ];

			lpData  = (U8*)lpDesc;
			lpData += sizeof( lpDesc );

			Gif_Encode( lpCanvasIC, lpData );


/*			CanvasIC_PaletteToST( lpCanvasIC, 16, lpGif->Palettes[ 0 ] );
			CanvasIC_To4Plane(    lpCanvasIC, 320, 200, lpGif->Pixels );*/
		}

		CanvasIC_Destroy( lpCanvasIC );
	}

	return( lpGif );
}


