#ifndef	INCLUDED_MBK_H
#define	INCLUDED_MBK_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>


/* ###################################################################################
#  DEFINES
################################################################################### */

#define	dMBK_HEADER_MAGIC	0x19861987 
#define	dMBK_PAL_MAGIC		0x50414C54


/* ###################################################################################
#  STRUCTS
################################################################################### */

typedef	struct
{
	U16	Reserved[ 9 ];
	U32	Magic;
	U32	LowResOffset;
	U32	MedResOffset;
	U32	HighResOffset;
	U16	LowResFrameCount;
	U16	MedResFrameCount;
	U16	HighResFrameCount;
} sMbkHeader;


typedef	struct
{
	U32	DataOffset;
	U16	Width;
	U16	Height
	U16	HotspotX;
	U16	HotspotY;
} sMbkFrame;


typedef	struct
{
	U32	Magic;
	U16	Palette[ 16 ];
} sMbkPal;

/* ################################################################################ */

#endif	/*	INCLUDED_MBK_H */