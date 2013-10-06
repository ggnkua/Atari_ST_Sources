#ifndef	INCLUDED_NEO_H
#define	INCLUDED_NEO_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>

#include	<GODLIB\PICTYPES\CANVAS.H>
#include	<GODLIB\PICTYPES\CANVASIC.H>


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef struct
{
	U16	Flag;
	U16	Resolution;
	U16	Palette[ 16 ];
	U8	FileName[ 12 ];
	U16	ColourAnimLimit;
	U16	ColourAnimSpeedDir;
	U16	ColourSteps;
	U16	OffsetX;
	U16	OffsetY;
	U16	Width;
	U16	Height;
	U16	Reserved[ 33 ];
} sNeoHeader;


typedef	struct
{
	sNeoHeader	Header;
	U16			Pixels[ 16000 ];
} sNeo;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

sNeo * 		Neo_FromCanvas( sCanvas * apCanvas, uCanvasPixel * apPalette );
sCanvas *	Neo_ToCanvas(   sNeo * apNeo );


/* ################################################################################ */

#endif	/*	INCLUDED_NEO_H */