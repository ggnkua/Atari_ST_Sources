#ifndef	INCLUDED_SPRITE_H
#define	INCLUDED_SPRITE_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>


/* ###################################################################################
#  STRUCTS
################################################################################### */


typedef	struct
{
	U16 *	pGfx;
	U16 *	pMask;
	U16		Width;
	U16		Height;
	U16		GfxPlaneCount;
	U16		MaskPlaneCount;
} sSprite;

typedef	struct
{
	U32	ID;
	U16	Version;
	U16	SpriteCount;
} sSpriteBlockHeader;


typedef	struct
{
	sSpriteBlockHeader	Header;
	sSprite *			pSprite[ 1 ];
} sSpriteBlock;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */


sSprite *		Sprite_Create( U16 * apGfx, U16 * apMsk, U16 aWidth, U16 aHeight, U16 aGfxPlaneCount, U16 aMskPlaneCount );
void			Sprite_Destroy( sSprite * apSprite );
U32				Sprite_GetSize( sSprite * apSprite );
void			Sprite_Delocate( sSprite * apSprite );
void			Sprite_Relocate( sSprite * apSprite );

sSpriteBlock *	Sprite_BlockCreate( U16 aSpriteCount );
void			Sprite_BlockDestroy( sSpriteBlock * apBlock );
sSpriteBlock *	Sprite_BlockSerialise( sSpriteBlock * apBlock );
U32				Sprite_BlockGetSize( sSpriteBlock * apBlock );
void			Sprite_BlockDelocate( sSpriteBlock * apBlock );
void			Sprite_BlockRelocate( sSpriteBlock * apBlock );

void			Sprite_FlipH( sSprite * apBlock );
void			Sprite_BlockFlipH( sSpriteBlock * apBlock );



/* ################################################################################ */

#endif	/* INCLUDED_SPRITE_H */

