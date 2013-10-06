#ifndef	INCLUDED_LINEA_H
#define	INCLUDED_LINEA_H

/* ###################################################################################
#  INCLUDES
################################################################################### */

#include	<GODLIB\BASE\BASE.H>


/* ###################################################################################
#  DEFINES
################################################################################### */

enum
{
	eLINEA_MWRITE_VDI = -1,
	eLINEA_MWRITE_XOR = 1
};

enum
{
	eLINEA_MOUSEINT_DISABLE = 0,
	eLINEA_MOUSEINT_ENABLE = 1,
};


/* ###################################################################################
#  STRUCTS
################################################################################### */


typedef	struct sLineAFont
{
	S16		ID;
	S16		PointSize;
	char	Name[ 32 ];
	U16		CharFirst;
	U16		CharLast;
	U16		Top;
	U16		Ascent;
	U16		Half;
	U16		Descent;
	U16		Bottom;
	U16		CharWidthMax;
	U16		CellWidthMax;
	U16		OffsetLeft;
	U16		OffsetRight;
	U16		Thicken;
	U16		UnderLineSize;
	U16		Lighten;
	U16		Skew;
	U16		Flags;
	U8 *	pHorOffsetTable;
	U16 *	pCharOffsetTable;
	U8 *	pData;
	U16		FormWidth;
	U16		FormHeight;
	struct	sLineAFont *	pNext;
	U16		Reserved;
} sLineAFont;

typedef	struct
{
	S32				Reserved0;
	sLineAFont *	pFontCurrent;
	U8				Reserved1[ 46 ];
	S16				MouseHotSpotX;
	S16				MouseHotSpotY;
	S16				MouseWriteMode;
	S16				MouseColourBG;
	S16				MouseColourFG;
	U16				MouseGfx[ 32 ];
	S16				InqTable[ 45 ];
	S16				DevTable[ 45 ];
	S16				MouseX;
	S16				MouseY;
	S16				MouseHideCount;
	U16				MouseButtonStatus;
	U16				VdiPalette[ 48 ];
	S16				SizeTable[ 15 ];
	U16				Reserved2;
	U16				Reserved3;
	U8 *			pWork;
	sLineAFont *	pFontDefault;
	sLineAFont *	pFontRing[ 4 ];
	U16				FontCount;
	U8				Reserved4[ 90 ];
	U8				MouseStatusCurrent;
	U8				Reserved5;
	S16				CursorHideCount;
	S16				CursorX;
	S16				CursorY;
	U8				MouseRedrawFlag;
	U8				MouseInterruptFlag;
	U32				Reserved6;
	S16				CursorSavedX;
	S16				CursorSavedY;
	S16				HeightSaved;
	U16 *			pScreenSaved;
	U16				StatusSaved;
	U8				MouseBufferSaved[ 256 ];
	void *			pfOnTick;
	void *			pfOnTickEnd;
	void *			pfOnMouseButton;
	void *			pfOnMouseRender;
	void *			pfOnMouseMoved;
	S16				TextCellHeight;
	S16				TextColCount;
	S16				TextRowCount;
	S16				CellGap;
	S16				TextCellColourBG;
	S16				TextCellColourFG;
	U8 *			pTextCursor;
	S16				TextOffset;
	S16				TextCursorX;
	S16				TextCursorY;
	S8				CursorBlinkRate;
	S8				CursorBlinkCountDown;
	sLineAFont *	pFontSystem;
	S16				SystemFontCharLast;
	S16				SystemFontCharFirst;
	S16				SystemFontWidth;
	S16				HorizontalRes;
	U16 *			pFontOffsets;
	U16				Reserved7;
	S16				VerticalRes;
	S16				ScreenLineSize;
	U16				PlaneCount;
	U16				Width;
	S16 *			pControl;
	S16 *			pIntin;
	S16 *			pPtsin;
	S16 *			pIntout;
	S16 *			pPtsout;
	S16				ColBit0;
	S16				ColBit1;
	S16				ColBit2;
	S16				ColBit3;
	S16				LastPixelDrawFlag;
	S16				LinePattern;
	S16				VDIWriteMode;
	S16				X1;
	S16				Y1;
	S16				X2;
	S16				Y2;
	U16 *			pFillPattern;
	U16				PatternMask;
	U16				MultiPlaneFillFlag;
	U16				ClippingFlag;
	S16				ClipLeft;
	S16				ClipRight;
	S16				ClipTop;
	S16				ClipBot;
	S16				TextScaleDDA;
	S16				TextScaleInc;
	U16				TextScaleDir;
	U16				MonoSpaceFontFlag;
	S16				SourceX;
	S16				SourceY;
	S16				DestX;
	S16				DestY;
	S16				OutputCharWidth;
	S16				OutputCharHeight;
	U16 *			pFontImage;
	U16				FontFormWidth;
	U16				FontStyle;
	U16				LightenMask;
	U16				SkewMsk;
	U16				ThickenWidth;
	U16				ItalicRightOff;
	U16				ItalicLeftOff;
	U16				TextScalingFlag;
	S16				CharRotAngle;
	U16				TextColourFG;
	U16 *			pScratchBuffer;
	U16				SratchBuffer2Offset;
	U16				TextColourBG;
	U16				RasterCopyMode;
	void *			pfSeedFill;
} sLineA;

typedef	struct
{
	S16	X0;
	S16	Y0;
	S16	X1;
	S16	Y1;
	U16	Colour;
	U16	LastLineFlag;
	U16	LineMask;
	U16	WriteMode;
} sLineALine;


/* ###################################################################################
#  PROTOTYPES
################################################################################### */

sLineA *	LineA_Init( void );
void		LineA_PlotPixel( const S16 aX, const S16 aY, const U16 aColour);
U16			LineA_GetPixel(  const S16 aX, const S16 aY );
U16			LineA_ArbitaryLine( const sLineALine * apLine );
U16			LineA_HorizontalLine( const sLineALine * apLine );


/* ################################################################################ */

#endif	/* INCLUDED_LINEA_H */
