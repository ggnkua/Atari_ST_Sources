#ifndef	INCLUDED_TGA_H
#define	INCLUDED_TGA_H

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
	U8	ImageIDLength;
	U8	ColourMapType;
	U8	ImageType;
	U8	ColourMapFirstIndex[ 2 ];
	U8	ColourMapCount[ 2 ];
	U8	ColourMapBitDepth;
	U8	OriginX[ 2 ];
	U8	OriginY[ 2 ];
	U8	Width[ 2 ];
	U8	Height[ 2 ];
	U8	PixelDepth;
	U8	Descriptor;
} sTgaHeader;


typedef	struct
{
	U16	Tag;
	U32	Offset;
	U32	Size;
} sTgaDirectoryEntry;


typedef	struct
{
	U16	TagCount;
} sTgaDirectoryHeader;


typedef	struct
{
	sTgaDirectoryHeader	Header;
	sTgaDirectoryEntry	Entry[ 1 ];
} sTgaDirectory;


typedef	struct
{
	U16	ExtensionSize;
	U8	AuthorName[ 41 ];
	U8	AuthorComments[ 324 ];
	U16	Month;
	U16	Day;
	U16	Year;
	U16	Hour;
	U16	Minute;
	U16	Second;
	U8	JobName[ 41 ];
	U16	JobHours;
	U16	JobMinutes;
	U16	JobSeconds;
	U8	SoftwareID[ 41 ];
	U16	VersionNumber;
	U8	VersionLetter;
	U32	KeyColour;
	U16	PixelWidth;
	U16	PixelHeight;
	U16	GammaNumerator;
	U16	GammaDenominator;
	U32	ColourCorectionTableOffset;
	U32	PostageStampOffset;
	U32	ScanLineOffset;
	U8	AlphaAttributes;
} sTgaExtension;


typedef	struct
{
	U32	ExtensionAreaOffset;
	U32	DevloperDirectoryOffset;
	U8	Signature[ 16 ];
	U8	Period;
	U8	Zero;
} sTgaFooter;


typedef	struct
{
	U16	A;
	U16	R;
	U16	G;
	U16	B;
} sTgaColourCorrectionEntry;


typedef	struct
{
	sTgaColourCorrectionEntry	Colour[ 256 ];
} sTgaColourCorrectionTable;


typedef	struct
{
	sTgaHeader	Header;
	U8			Data[1];
} sTga;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

sTga *		Tga_FromCanvas( sCanvas * apCanvas );
sCanvas *	Tga_ToCanvas( sTga * apTga );


/* ################################################################################ */

#endif	/*	INCLUDED_TGA_H */