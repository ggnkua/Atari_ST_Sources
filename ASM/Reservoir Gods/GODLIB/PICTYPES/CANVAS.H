#ifndef	INCLUDED_CANVAS_H
#define	INCLUDED_CANVAS_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>


/* ###################################################################################
#  DEFINES
################################################################################### */


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef union
{
struct {U8 r,g,b,a;} b;
U32					 l;
} uCanvasPixel;


typedef struct
{
	U32				ID;
	U32				Version;
	U16				Width;
	U16				Height;

	uCanvasPixel *	pPixels;
} sCanvas;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

sCanvas *		Canvas_Create( void );
U8				Canvas_Destroy( sCanvas * apCanvas );

U8				Canvas_CreateImage(  sCanvas * apCanvas, U16 aWidth, U16 aHeight );
U8				Canvas_DestroyImage( sCanvas * apCanvas );

U8				Canvas_PaletteFromST( uCanvasPixel * apPal, U16 aColourCount, U16 * apPalette );
U8				Canvas_PaletteToST(   uCanvasPixel * apPal, U16 aColourCount, U16 * apPalette );

sCanvas *		Canvas_ImageFrom1Plane( U16 aWidth, U16 aHeight, U16 * apPixels, uCanvasPixel * apPal );
sCanvas *		Canvas_ImageFrom2Plane( U16 aWidth, U16 aHeight, U16 * apPixels, uCanvasPixel * apPal );
sCanvas *		Canvas_ImageFrom4Plane( U16 aWidth, U16 aHeight, U16 * apPixels, uCanvasPixel * apPal );
sCanvas *		Canvas_ImageFrom8Plane( U16 aWidth, U16 aHeight, U16 * apPixels, uCanvasPixel * apPal );

U8				Canvas_ImageTo565(   sCanvas * apCanvas, U16 aWidth, U16 aHeight, U16 * apPixels );
U8				Canvas_ImageFrom565( sCanvas * apCanvas, U16 aWidth, U16 aHeight, U16 * apPixels );

sCanvas *		Canvas_Load(   sCanvas * apCanvas, char * apFileName );
U8				Canvas_LoadAt( sCanvas * apCanvas, char * apFileName, void * apMem );
U8				Canvas_Save(   sCanvas * apCanvas, char * apFileName );

void			CanvasPixel_FromST( uCanvasPixel * apPixel, U16 * apST );
void			CanvasPixel_ToST(   uCanvasPixel * apPixel, U16 * apST );

void			Canvas_SetPixel( sCanvas * apCanvas, U16 aX, U16 aY, U32 aPixel );
uCanvasPixel	Canvas_GetPixel( sCanvas * apCanvas, U16 aX, U16 aY );



/* ################################################################################ */

#endif	/*	INCLUDED_CANVAS_H */