#ifndef	INCLUDED_IFF_H
#define	INCLUDED_IFF_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>


/* ###################################################################################
#  DEFINES
################################################################################### */

#define	dIFF_BMHD_ID		mSTRING_TO_U32( 'B', 'M', 'H', 'D' )
#define	dIFF_BODY_ID		mSTRING_TO_U32( 'B', 'O', 'D', 'Y' )
#define	dIFF_CAMG_ID		mSTRING_TO_U32( 'C', 'A', 'M', 'G' )
#define	dIFF_CMAP_ID		mSTRING_TO_U32( 'C', 'M', 'A', 'P' )
#define	dIFF_CRNG_ID		mSTRING_TO_U32( 'C', 'R', 'N', 'G' )
#define	dIFF_FORM_ID		mSTRING_TO_U32( 'F', 'O', 'R', 'M' )
#define	dIFF_ILBM_ID		mSTRING_TO_U32( 'I', 'L', 'B', 'M' )


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef	struct
{
	U32	ID;
	U32	Length;
} sIffChunk;


typedef	struct
{
	U32	ID;
	U32	Length;
	U32	ILBM;
} sIffFormChunk;


typedef	struct
{
	U32	ID;
	U32	Length;
	U16	Width;
	U16	Height;
	U16	X;
	U16	Y;
	U8	PlaneCount;
	U8	Mask;
	U8	CompressedFlag;
	U8	Reserved;
	U8	TransparentColourIndex;
	U8	AspectX;
	U8	AspectY;
	U16	PageWidth;
	U16	PageHeight;
} sIffBmhdChunk;


typedef	struct
{
	U8	R;
	U8	G;
	U8	B;
} sIffColour;


typedef	struct
{
	U32			ID;
	U32			Length;
	sIffColour	Colour[ 1 ];
} sIffCmapChunk;


typedef	struct
{
	U32	ID;
	U32	Length;
	U16	Reserved;
	U16	AnimSpeed;
	U16	ActiveFlag;
	U8	LeftBotColourAnimLimit;
	U8	RightTopColourAnimLimit;
} sIffCrngChunk;


typedef	struct
{
	U32	ID;
	U32	Length;
	U32	ViewportMode;
} sIffCamgChunk;


typedef	struct
{
	U32	ID;
	U32	Length;
	U32	ViewportMode;
} sIffCamgChunk;

typedef	struct
{
	U32	ID;
	U32	Length;
	U8	Pixels[ 1 ];
} sIffBodyChunk;


/* ################################################################################ */

#endif	/*	INCLUDED_IFF_H */