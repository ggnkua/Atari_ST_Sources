#ifndef	INCLUDED_CANVASIC_H
#define	INCLUDED_CANVASIC_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>
#include	<GODLIB\PICTYPES\CANVAS.H>


/* ###################################################################################
#  DEFINES
################################################################################### */


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef	struct
{
	U32				ID;
	U32				Version;
	U16				Width;
	U16				Height;

	uCanvasPixel 	Palette[ 256 ];
	U8 *			pPixels;
} sCanvasIC;

typedef	struct
{
	uCanvasPixel	Colour;
	U32				Count;
} sCanvasICColourCounter;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

sCanvasIC *		CanvasIC_Create( void );
U8				CanvasIC_Destroy( sCanvasIC * apCanvasIC );

U8				CanvasIC_CreateImage(  sCanvasIC * apCanvasIC, U16 aWidth, U16 aHeight );
U8				CanvasIC_DestroyImage( sCanvasIC * apCanvasIC );

U8				CanvasIC_CreateIndexedColourImage(  sCanvasIC * apCanvasIC, U16 aColourCount, uCanvasPixel * apPalette );
U8				CanvasIC_DestroyIndexedColourImage( sCanvasIC * apCanvasIC );

U8				CanvasIC_CreateDefaultPalette( sCanvasIC * apCanvasIC, U16 aColourCount );

U8				CanvasIC_PaletteFromST( sCanvasIC * apCanvasIC, U16 aColourCount, U16 * apPalette );
U8				CanvasIC_PaletteToST(   sCanvasIC * apCanvasIC, U16 aColourCount, U16 * apPalette );

sCanvasIC *		CanvasIC_From1Plane( U16 aWidth, U16 aHeight, U16 * apPixels, uCanvasPixel * apPal );
sCanvasIC *		CanvasIC_From2Plane( U16 aWidth, U16 aHeight, U16 * apPixels, uCanvasPixel * apPal );
sCanvasIC *		CanvasIC_From4Plane( U16 aWidth, U16 aHeight, U16 * apPixels, uCanvasPixel * apPal );
sCanvasIC *		CanvasIC_From8Plane( U16 aWidth, U16 aHeight, U16 * apPixels, uCanvasPixel * apPal );

void			CanvasIC_To1Plane( sCanvasIC * apCanvasIC, U16 aWidth, U16 aHeight, U16 * apPixels );
void			CanvasIC_To2Plane( sCanvasIC * apCanvasIC, U16 aWidth, U16 aHeight, U16 * apPixels );
void			CanvasIC_To4Plane( sCanvasIC * apCanvasIC, U16 aWidth, U16 aHeight, U16 * apPixels );
void			CanvasIC_To8Plane( sCanvasIC * apCanvasIC, U16 aWidth, U16 aHeight, U16 * apPixels );

U8				CanvasIC_To565(   sCanvasIC * apCanvasIC, U16 aWidth, U16 aHeight, U16 * apPixels );
U8				CanvasIC_From565( sCanvasIC * apCanvasIC, U16 aWidth, U16 aHeight, U16 * apPixels );

sCanvasIC *		CanvasIC_FromCanvas( sCanvas * apCanvas, const U16 aColourCount, uCanvasPixel * apPal );

U8				CanvasIC_Palettize( sCanvasIC * apCanvasIC );
void			CanvasIC_ReduceColourDepth( sCanvasIC * apCanvasIC, U16 aColourCount );

sCanvasIC *		CanvasIC_Load(   sCanvasIC * apCanvasIC, char * apFileName );
U8				CanvasIC_LoadAt( sCanvasIC * apCanvasIC, char * apFileName, void * apMem );
U8				CanvasIC_Save(   sCanvasIC * apCanvasIC, char * apFileName );

void			CanvasICPixel_FromST( uCanvasPixel * apPixel, U16 * apST );
void			CanvasICPixel_ToST(   uCanvasPixel * apPixel, U16 * apST );

void			CanvasIC_SetPixel( sCanvasIC * apCanvasIC, U16 aX, U16 aY, U8 aPixel );
U8				CanvasIC_GetPixel( sCanvasIC * apCanvasIC, U16 aX, U16 aY );

uCanvasPixel	CanvasIC_GetPaletteColour( sCanvasIC * apCanvasIC, U16 aIndex );
void			CanvasIC_SetPaletteColour( sCanvasIC * apCanvasIC, U16 aIndex, uCanvasPixel aPixel );



/* ################################################################################ */

#endif	/*	INCLUDED_CANVASIC_H */