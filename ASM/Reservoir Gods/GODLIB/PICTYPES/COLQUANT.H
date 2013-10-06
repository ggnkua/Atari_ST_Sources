#ifndef	INCLUDED_COLQUANT_H
#define	INCLUDED_COLQUANT_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>

#include	<GODLIB\PICTYPES\CANVAS.H>
#include	<GODLIB\PICTYPES\CANVASIC.H>

/* ###################################################################################
#  ENUMS
################################################################################### */

enum
{
	eCOLOURQUANTIZE_BITSHIFT,
	eCOLOURQUANTIZE_POPULAR,
	eCOLOURQUANTIZE_MEDIANCUT,
	eCOLOURQUANTIZE_LKM,
	eCOLOURQUANTIZE_OCTREE,

	eCOLOURQUANTIZE_LIMIT
};


/* ###################################################################################
#  PROTOTYPES
################################################################################### */


sCanvasIC *		ColourQuantize_BitShift(  sCanvas * apCanvas, const U16 aColourCount );
sCanvasIC *		ColourQuantize_Popular(   sCanvas * apCanvas, const U16 aColourCount );
sCanvasIC *		ColourQuantize_MedianCut( sCanvas * apCanvas, const U16 aColourCount );
sCanvasIC *		ColourQuantize_LKM(       sCanvas * apCanvas, const U16 aColourCount );
sCanvasIC *		ColourQuantize_Octree(    sCanvas * apCanvas, const U16 aColourCount );

sCanvasIC *		ColourQuantize_FromCanvas( sCanvas * apCanvas, const U16 aColourCount );
void			ColourQuantize_SetMethod( const U16 aMethod );
U16				ColourQuantize_GetMethod( void );

/* ################################################################################ */

#endif	/*	INCLUDED_COLQUANT_H */