#ifndef	INCLUDED_DEGAS_H
#define	INCLUDED_DEGAS_H

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
	U16	Mode;
	U16	Palette[ 16 ];
} sDegasHeader;


typedef struct
{
	U16	LeftColourAnimLimit[ 4 ];
	U16	RightColourAnimLimit[ 4 ];
	U16	AnimChannelDir[ 4 ];
	U16	AnimChannelDelay[ 4 ];
} sDegasAnim;


typedef struct
{
	sDegasHeader	Header;
	U16				Pixels[ 16000 ];
} sDegas;


typedef struct
{
	sDegasHeader	Header;
	U16				Pixels[ 16000 ];
	sDegasAnim		Anim;
} sDegasElite;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

sCanvas *		Degas_ToCanvas(   sDegas * apDegas );
sDegas *		Degas_FromCanvas( sCanvas * apCanvas, uCanvasPixel * apPalette );

sCanvas *		Degas_Pi1ToCanvas( sDegas * apDegas );
sCanvas *		Degas_Pi2ToCanvas( sDegas * apDegas );
sCanvas *		Degas_Pi3ToCanvas( sDegas * apDegas );

sDegas *		Degas_Pi1FromCanvas( sCanvas * apCanvas, uCanvasPixel * apPalette );
sDegas *		Degas_Pi2FromCanvas( sCanvas * apCanvas, uCanvasPixel * apPalette );
sDegas *		Degas_Pi3FromCanvas( sCanvas * apCanvas, uCanvasPixel * apPalette );


/* ################################################################################ */

#endif	/*	INCLUDED_DEGAS_H */