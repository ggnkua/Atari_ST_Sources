#ifndef	INCLUDED_GIF_H
#define	INCLUDED_GIF_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>

#include	<GODLIB\PICTYPES\CANVAS.H>
#include	<GODLIB\PICTYPES\CANVASIC.H>


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef	struct
{
	U8	Sig[ 3 ];
	U8	Version[ 3 ];
	U8	Width[ 2 ];
	U8	Height[ 2 ];
	U8	Flags;
	U8	BackgroundColourIndex;
	U8	PixelAspectRatio;
} sGifHeader;

typedef	struct
{
	U8	R;
	U8	G;
	U8	B;
} sGifColour;

typedef	struct
{
	U8	Seperator;
	U8	X[ 2 ];
	U8	Y[ 2 ];
	U8	Width[ 2 ];
	U8	Height[ 2 ];
	U8	Flags;
} sGifImageDescriptor;

typedef	struct
{
	sGifHeader	Header;
	U8			Data[1];
} sGif;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

sGif *		Gif_FromCanvas( sCanvas * apCanvas, uCanvasPixel * apPalette );
sCanvas *	Gif_ToCanvas( sGif * apGif );


/* ################################################################################ */

#endif	/*	INCLUDED_GIF_H */