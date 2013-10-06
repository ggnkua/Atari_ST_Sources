#ifndef	INCLUDED_SEQ_H
#define	INCLUDED_SEQ_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef	struct
{
	U16	Magic;
	U16	Version;
	U16	FrameCount;
	U16	Speed;
	U8	Reserved[ 118 ];
} sSeqHeader;


typedef	struct
{
	U16	Type;
	U16	Resolution;
	U16	Palette[ 16 ];
	U8	FileName[ 12 ];
	U16	ColourAnimLimits;
	U16	ColourAnimSpeedDir;
	U16	ColourSteps;
	U16	X;
	U16	Y;
	U16	Width;
	U16	Height;
	U8	Operation;
	U8	CompressionFlag;
	U32	DataLength;
	U8	Reserved[ 60 ];
} sSeqFrame;


/* ################################################################################ */

#endif	/*	INCLUDED_SEQ_H */