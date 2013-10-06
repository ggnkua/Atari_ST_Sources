#ifndef	INCLUDED_GFX_H
#define	INCLUDED_GFX_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>
#include	<GODLIB\PICTYPES\CANVAS.H>


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef	struct
{
	U32		ID;
	U16		Version;
	U16		Width;
	U16		Height;
	U8		PlaneCount;
	U8		HasMaskFlag;
} sGfxHeader;

typedef	struct
{
	sGfxHeader	Header;
	U16			Pixels[ 1 ];
} sGfx;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

sGfx *		Gfx_FromCanvas( sCanvas * apCanvas, uCanvasPixel * apPalette, uCanvasPixel aTransparentColour );
sCanvas *	Gfx_ToCanvas( sGfx * apGfx );

sGfx *		Gfx_Create( U16 aWidth, U16 aHeight, U8 aPlaneCount, U32 aLineSize, U16 * apSrc );
void		Gfx_Delete( sGfx * apGfx );
U8			Gfx_Save( sGfx * apGfx, char * apFileName );
void		Gfx_UnMaskInteriorBlack( sGfx * apGfx );


/* ################################################################################ */

#endif	/*	INCLUDED_GFX_H */