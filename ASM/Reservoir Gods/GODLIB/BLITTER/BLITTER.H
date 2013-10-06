#ifndef	INCLUDED_BLITTER_H
#define	INCLUDED_BLITTER_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>

/* ###################################################################################
#  ENUMS
################################################################################### */

enum
{
	eBLITTERLOP_ZERO,
	eBLITTERLOP_SRC_AND_DST,
	eBLITTERLOP_SRC_ANDNOT_DST,
	eBLITTERLOP_SRC,
	eBLITTERLOP_NOTSRC_AND_DST,
	eBLITTERLOP_DST,
	eBLITTERLOP_SRC_XOR_DST,
	eBLITTERLOP_SRC_OR_DST,
	eBLITTERLOP_NOTSRC_ANDNOT_DST,
	eBLITTERLOP_NOTSRC_XOR_DST,
	eBLITTERLOP_NOTDST,
	eBLITTERLOP_SRC_ORNOT_DST,
	eBLITTERLOP_NOTSRC,
	eBLITTERLOP_NOTSRC_OR_DST,
	eBLITTERLOP_NOTSRC_ORNOT_DST,
	eBLITTERLOP_ONE
};


enum
{
	eBLITTERHOP_ONE,
	eBLITTERHOP_HALFTONE,
	eBLITTERHOP_SRC,
	eBLITTERHOP_SRC_AND_HALFTONE
};


#define	dBLITTERMODE_LINENUMBER_MASK	(0xF)
#define	dBLITTERMODE_SMUDGE_BIT			(1<<5)
#define	dBLITTERMODE_SMUDGE_MASK		(~dBLITTERMODE_SMUDGE_BIT)
#define	dBLITTERMODE_HOG_BIT			(1<<6)
#define	dBLITTERMODE_HOG_MASK			(~dBLITTERMODE_HOG_BIT)
#define	dBLITTERMODE_BUSY_BIT			(1<<7)
#define	dBLITTERMODE_BUSY_MASK			(~dBLITTERMODE_BUSY_BIT)

#define	dBLITTERSKEW_SKEW_MASK			(0xF)
#define	dBLITTERSKEW_NFSR_BIT			(1<<6)
#define	dBLITTERSKEW_NFSR_MASK			(~dBLITTERSKEW_NFSR_BIT)
#define	dBLITTERSKEW_FXSR_BIT			(1<<7)
#define	dBLITTERSKEW_FXSR_MASK			(~dBLITTERSKEW_FXSR_BIT)


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef	struct
{
	U16		HalftoneRAM[ 16 ];
	U16		SrcIncX;
	U16		SrcIncY;
	U16 *	pSrc;
	U16		EndMask1;
	U16		EndMask2;
	U16		EndMask3;
	U16		DstIncX;
	U16		DstIncY;
	U16 *	pDst;
	U16		CountX;
	U16		CountY;
	U8		HOP;
	U8		LOP;
	U8		Mode;
	U8		Skew;
} sBlitter;

typedef	struct
{
	U16 *	pGfx;
	U16 *	pMask;
	U16		Width;
	U16		Height;
	U16		GfxPlaneCount;
	U16		MaskPlaneCount;
} sBlitterSprite;


typedef	struct
{
	U16	Width;
	U16	Height;
	U16	Colour;
} sBlitterBox;



/* ###################################################################################
#  PROTOTYPES
################################################################################### */

void					Blitter_Init( void );
void					Blitter_DeInit( void );

void					Blitter_DrawSprite( sBlitterSprite * apSprite, U16 * apScreen, S16 aX, S16 aY );
void					Blitter_DrawOpaqueSprite( sBlitterSprite * apSprite, U16 * apScreen, S16 aX, S16 aY );
void					Blitter_DrawColouredSprite( sBlitterSprite * apSprite, U16 * apScreen, S16 aX, S16 aY, U8 aColour );
void					Blitter_DrawBox( sBlitterBox * apBox, U16 * apScreen, U16 aX, U16 aY );
void					Blitter_CopyBox( U16 * apSrc, U16 * apDst, U16 aSrcX, U16 aSrcY, U16 aDstX, U16 aDstY, U16 aWidth, U16 aHeight );

void					Blitter_Wait( void );

extern	U16				gBlitterStartMasks[ 16 ];
extern	U16				gBlitterEndMasks[ 16 ];


/* ################################################################################ */

#endif	/*	INCLUDED_BLITTER_H */