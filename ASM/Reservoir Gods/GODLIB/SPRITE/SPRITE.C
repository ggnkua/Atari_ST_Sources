/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: SPRITE.C
::
:: Sprite routines
::
:: [c] 2001 Reservoir Gods
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/


/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	"SPRITE.H"

#include	<GODLIB\MEMORY\MEMORY.H>


/* ###################################################################################
#  DEFINES
################################################################################### */


#define	dSPRITEBLOCK_ID			mSTRING_TO_U32( 'B', 'S', 'B', 'K' )
#define	dSPRITEBLOCK_VERSION	0


/* ###################################################################################
#  DATA
################################################################################### */

U8	gSpriteFlipTable[ 256 ];


/* ###################################################################################
#  CODE
################################################################################### */


/*-----------------------------------------------------------------------------------*
* FUNCTION : Sprite_Init( void )
* ACTION   : Sprite_Init
* CREATION : 04.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Sprite_Init( void )
{
	U16	i,j;
	U16	lMask;
	U8	lByte;
	U8	lOr;

	for( i=0; i<256; i++ )
	{
		lByte = 0;
		lOr   = 0x80;
		lMask = 1;

		for( j=0; j<8; j++ )
		{
			if( i & lMask )
			{
				lByte |= lOr;
			}
			lOr   >>= 1;
			lMask <<= 1;
		}

		gSpriteFlipTable[ i ] = lByte;
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Sprite_DeInit( void )
* ACTION   : Sprite_DeInit
* CREATION : 04.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Sprite_DeInit( void )
{
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Sprite_Create( U16 * apGfx, U16 * apMsk, U16 aWidth, U16 aHeight, U16 aGfxPlaneCount, U16 aMskPlaneCount )
* ACTION   : creates a sprite
* CREATION : 17.02.01 PNK
*-----------------------------------------------------------------------------------*/

sSprite *		Sprite_Create( U16 * apGfx, U16 * apMsk, U16 aWidth, U16 aHeight, U16 aGfxPlaneCount, U16 aMskPlaneCount )
{
	sSprite *	lpSprite;
	U8 *				lpMem;
	U16 *				lpSrc;
	U16 *				lpDst;
	U16 *				lpSrc2;
	U32					lSize;
	U32					lGfxSize;
	U32					lMskSize;
	U32					lXwords;
	U16					i,y,x;

	lXwords   = ((aWidth+15)>>4);

	lGfxSize  = (lXwords<<1);
	lGfxSize *= aGfxPlaneCount;
	lGfxSize *= aHeight;

	lMskSize  = (lXwords<<1);
	lMskSize *= aHeight;

	lSize  = lGfxSize + lMskSize;
	lSize += sizeof( sSprite );

	lpSprite = Memory_Calloc( lSize );

	lpMem           = (U8*)lpSprite;
	lpMem          += sizeof( sSprite );
	lpSprite->pMask = (U16*)lpMem;
	lpMem          += lMskSize;
	lpSprite->pGfx  = (U16*)lpMem;

	lpSprite->GfxPlaneCount  = aGfxPlaneCount;
	lpSprite->Height         = aHeight;
	lpSprite->MaskPlaneCount = aMskPlaneCount;
	lpSprite->Width          = aWidth;

	lpSrc = apMsk;
	lpDst = lpSprite->pMask;
	if( lpSprite->MaskPlaneCount )
	{
		for( y=0; y<lpSprite->Height; y++ )
		{
			lpSrc2 = lpSrc;
			for( x=0; x<lXwords; x++ )
			{
				*lpDst   = *lpSrc2++;
				*lpDst  |= *lpSrc2++;
				*lpDst  |= *lpSrc2++;
				*lpDst  |= *lpSrc2++;
				lpDst++;
			}
			lpSrc += 80;
		}
	}

	lpSrc = apGfx;
	lpDst = lpSprite->pGfx;
	if( lpSprite->GfxPlaneCount )
	{
		for( y=0; y<lpSprite->Height; y++ )
		{
			lpSrc2 = lpSrc;
			for( x=0; x<lXwords; x++ )
			{
				for( i=0; i<lpSprite->GfxPlaneCount; i++ )
				{
					*lpDst++ = lpSrc2[ i ];
				}
				lpSrc2 += 4;

			}
			lpSrc += 80;
		}
	}

	return( lpSprite );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Sprite_Destroy( sSprite * apSprite )
* ACTION   : releases memory allocate by a sprite
* CREATION : 17.02.01 PNK
*-----------------------------------------------------------------------------------*/

void					Sprite_Destroy( sSprite * apSprite )
{
	if( apSprite )
	{
/*		Memory_Release( apSprite->pGfx );
		Memory_Release( apSprite->pMask ); */
		Memory_Release( apSprite );
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Sprite_Delocate( sSprite * apSprite )
* ACTION   : delocates a sprite
* CREATION : 17.02.01 PNK
*-----------------------------------------------------------------------------------*/

void					Sprite_Delocate( sSprite * apSprite )
{
	*(U32*)&apSprite->pGfx  -= (U32) apSprite;	
	*(U32*)&apSprite->pMask -= (U32) apSprite;	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Sprite_Relocate( sSprite * apSprite )
* ACTION   : relocates a sprite
* CREATION : 17.02.01 PNK
*-----------------------------------------------------------------------------------*/

void					Sprite_Relocate( sSprite * apSprite )
{
	*(U32*)&apSprite->pGfx  += (U32) apSprite;	
	*(U32*)&apSprite->pMask += (U32) apSprite;	
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Sprite_GetSize( sSprite * apSprite )
* ACTION   : returns the size of a sprite
* CREATION : 17.02.01 PNK
*-----------------------------------------------------------------------------------*/

U32						Sprite_GetSize( sSprite * apSprite )
{
	U32	lSize;
	U32	lGfxSize;
	U32	lMskSize;
	U32	lXwords;

	if( !apSprite )
		return( 0 );


	lXwords   = ((apSprite->Width+15)>>4);

	lGfxSize  = (lXwords<<1);
	lGfxSize *= apSprite->GfxPlaneCount;
	lGfxSize *= apSprite->Height;

	if( apSprite->MaskPlaneCount )
	{
		lMskSize  = (lXwords<<1);
		lMskSize *= apSprite->Height;
	}
	else
	{
		lMskSize = 0;
	}
	lSize  = lGfxSize + lMskSize;
	lSize += sizeof( sSprite );

	return( lSize );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Sprite_BlockCreate( U16 aSpriteCount )
* ACTION   : creates a sprite block
* CREATION : 17.02.01 PNK
*-----------------------------------------------------------------------------------*/

sSpriteBlock *	Sprite_BlockCreate( U16 aSpriteCount )
{
	sSpriteBlock *	lpBlock;
	U32						lSize;

	lSize  = sizeof( sSpriteBlockHeader );
	lSize += aSpriteCount << 2;

	lpBlock = Memory_Calloc( lSize );

	lpBlock->Header.ID          = dSPRITEBLOCK_ID;
	lpBlock->Header.Version     = dSPRITEBLOCK_VERSION;
	lpBlock->Header.SpriteCount = aSpriteCount;

	return( lpBlock );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Sprite_BlockDestroy( sSpriteBlock * apBlock )
* ACTION   : releases memory allocated by a sprite block
* CREATION : 17.02.01 PNK
*-----------------------------------------------------------------------------------*/

void					Sprite_BlockDestroy( sSpriteBlock * apBlock )
{
	U16	i;

	for( i=0 ;i< apBlock->Header.SpriteCount; i++ )
	{
		Sprite_Destroy( apBlock->pSprite[ i ] );
	}
	Memory_Release( apBlock );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Sprite_BlockDelocate( sSpriteBlock * apBlock )
* ACTION   : delocates all elements in a sprite block
* CREATION : 17.02.01 PNK
*-----------------------------------------------------------------------------------*/

void					Sprite_BlockDelocate( sSpriteBlock * apBlock )
{
	U16	i;

	for( i=0; i<apBlock->Header.SpriteCount; i++ )
	{
		if( apBlock->pSprite[ i ] )
		{
			Sprite_Delocate( apBlock->pSprite[ i ] );
		}
	}

	for( i=0; i<apBlock->Header.SpriteCount; i++ )
	{
		*(U32*)&apBlock->pSprite[ i ] -= (U32)apBlock;
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Sprite_BlockRelocate( sSpriteBlock * apBlock )
* ACTION   : relocates all elements in a sprite block
* CREATION : 17.02.01 PNK
*-----------------------------------------------------------------------------------*/

void					Sprite_BlockRelocate( sSpriteBlock * apBlock )
{
	U16	i;

	if( !apBlock )
	{
		return;
	}

	for( i=0; i<apBlock->Header.SpriteCount; i++ )
	{
		*(U32*)&apBlock->pSprite[ i ] += (U32)apBlock;
	}

	for( i=0; i<apBlock->Header.SpriteCount; i++ )
	{
		if( apBlock->pSprite[ i ] )
		{
			Sprite_Relocate( apBlock->pSprite[ i ] );
		}
	}

}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Sprite_BlockGetSize( sSpriteBlock * apBlock )
* ACTION   : returns the size of a sprite block
* CREATION : 17.02.01 PNK
*-----------------------------------------------------------------------------------*/

U32						Sprite_BlockGetSize( sSpriteBlock * apBlock )
{
	U32						lSize;
	U16						i;

	if( !apBlock )
		return( 0 );

	lSize  = sizeof( sSpriteBlockHeader );
	lSize += apBlock->Header.SpriteCount << 2;
	for( i=0; i<apBlock->Header.SpriteCount; i++ )
	{
		lSize += Sprite_GetSize( apBlock->pSprite[ i ] );
	}

	return( lSize );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Sprite_BlockSerialise( sSpriteBlock * apBlock )
* ACTION   : creates a serialised copy of apBlock
* CREATION : 17.02.01 PNK
*-----------------------------------------------------------------------------------*/

sSpriteBlock	*	Sprite_BlockSerialise( sSpriteBlock * apBlock )
{
	sSpriteBlock *	lpBlock;
	sSprite *		lpSprite;
	U8 *					lpMem;
	U32						lSize;
	U16						i;

	lSize   = Sprite_BlockGetSize( apBlock );
	lpBlock = Memory_Calloc( lSize );
	if( !lpBlock )
		return( 0 );

	lpBlock->Header.ID          = apBlock->Header.ID;
	lpBlock->Header.SpriteCount = apBlock->Header.SpriteCount;
	lpBlock->Header.Version     = apBlock->Header.Version;

	lpMem  = (U8*)lpBlock;
	lpMem += sizeof( sSpriteBlockHeader );
	lpMem += apBlock->Header.SpriteCount << 2;


	for( i=0; i<apBlock->Header.SpriteCount; i++ )
	{
		lpSprite = (sSprite*)lpMem;
		lpBlock->pSprite[ i ] = lpSprite;
		lpMem += sizeof( sSprite );

		lpSprite->GfxPlaneCount  = apBlock->pSprite[ i ]->GfxPlaneCount;
		lpSprite->Height         = apBlock->pSprite[ i ]->Height;
		lpSprite->MaskPlaneCount = apBlock->pSprite[ i ]->MaskPlaneCount;
		lpSprite->Width          = apBlock->pSprite[ i ]->Width;

		lpSprite->pMask = (U16*)lpMem;
		if( apBlock->pSprite[ i ]->MaskPlaneCount )
		{
			lSize  = ((apBlock->pSprite[ i ]->Width+15)>>4)<<1;
			lSize *= apBlock->pSprite[ i ]->Height;
			Memory_Copy( lSize, apBlock->pSprite[ i ]->pMask, lpSprite->pMask );
			lpMem += lSize;
		}
		lpSprite->pGfx = (U16*)lpMem;
		if( apBlock->pSprite[ i ]->GfxPlaneCount )
		{
			lSize  = ((apBlock->pSprite[ i ]->Width+15)>>4)<<1;
			lSize *= apBlock->pSprite[ i ]->Height;
			lSize *= apBlock->pSprite[ i ]->GfxPlaneCount;
			Memory_Copy( lSize, apBlock->pSprite[ i ]->pGfx, lpSprite->pGfx );
			lpMem += lSize;
		}
	}

	return( lpBlock );
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Sprite_FlipH( sSprite * apBlock )
* ACTION   : Sprite_FlipH
* CREATION : 04.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Sprite_FlipH( sSprite * apBlock )
{
	U16		i,j,k;
	U16		lWidth;
	U8 *	lpGfx;
	U8	*	lpMsk;
	U16 *	lpGfxDst;
	U16 *	lpMskDst;
	U16		lByte0;
	U16		lByte1;
	U16		lStack[ 256 ];
	U16		lStackIndex;
	
	lpGfx = (U8*)apBlock->pGfx;
	lpMsk = (U8*)apBlock->pMask;

	lWidth   = apBlock->Width+15;
	lWidth >>= 4;

	for( i=0; i<apBlock->Height; i++ )
	{
		lpGfxDst = (U16*)lpGfx;
		lpMskDst = (U16*)lpMsk;

		lStackIndex = 0;
		for( j=0; j<lWidth; j++ )
		{
			for( k=0; k<apBlock->GfxPlaneCount; k++ )
			{
				lByte0 = lpGfx[ 0 ];
				lByte1 = lpGfx[ 1 ];
	
				lByte0 = gSpriteFlipTable[ lByte0 ];
				lByte1 = gSpriteFlipTable[ lByte1 ];

				lByte1 <<= 8;
				lByte0  &= 0xFF;

				lByte0  |= lByte1;

				lStack[ lStackIndex ] = lByte0;

				lStackIndex++;
				lpGfx += 2;
			}
		}

		for( j=0; j<lWidth; j++ )
		{
			lStackIndex -= apBlock->GfxPlaneCount;
			for( k=0; k<apBlock->GfxPlaneCount; k++ )
			{
				*lpGfxDst++ = lStack[ lStackIndex + k ];
			}
		}


		if( apBlock->MaskPlaneCount )
		{
			lStackIndex = 0;
			for( j=0; j<lWidth; j++ )
			{
				lByte0 = lpMsk[ 0 ];
				lByte1 = lpMsk[ 1 ];
	
				lByte0 = gSpriteFlipTable[ lByte0 ];
				lByte1 = gSpriteFlipTable[ lByte1 ];

				lByte1 <<= 8;
				lByte0  &= 0xFF;

				lByte0  |= lByte1;

				lStack[ lStackIndex ] = lByte0;

				lStackIndex++;
				lpMsk += 2;
			}
			for( j=0; j<lWidth; j++ )
			{
				lStackIndex--;
				*lpMskDst++ = lStack[ lStackIndex ];
			}
		}
	}
}


/*-----------------------------------------------------------------------------------*
* FUNCTION : Sprite_BlockFlipH( sSpriteBlock * apBlock )
* ACTION   : Sprite_BlockFlipH
* CREATION : 04.01.2003 PNK
*-----------------------------------------------------------------------------------*/

void	Sprite_BlockFlipH( sSpriteBlock * apBlock )
{
	U16	i;

	for( i=0; i<apBlock->Header.SpriteCount; i++ )
	{
		Sprite_FlipH( apBlock->pSprite[ i ] );
	}
}


/* ################################################################################ */
