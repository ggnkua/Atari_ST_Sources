/*****************************************************************************
*   "Gif-Lib" - Yet another gif library.				     *
*									     *
* Written by:  Gershon Elber				Ver 0.1, Jul. 1989   *
******************************************************************************
* Program to combine 2 GIF images into single one, using optional mask GIF   *
* file. Result colormap will be the union of the two images colormaps.	     *
* Both images should have exactly the same size, although they may be mapped *
* differently on screen. Only First GIF screen descriptor info. is used.     *
* Options:								     *
* -q : quite printing mode.						     *
* -m mask : optional boolean image, defines where second GIF should be used. *
* -h : on line help.							     *
******************************************************************************
* History:								     *
* 12 Jul 89 - Version 1.0 by Gershon Elber.				     *
*****************************************************************************/

#ifdef __MSDOS__
#include <stdlib.h>
#include <alloc.h>
#endif /* _MSDOS__ */

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "gif_lib.h"
#include "getarg.h"

#define PROGRAM_NAME	"GifComb"

#ifdef __MSDOS__
extern unsigned int
    _stklen = 16384;			     /* Increase default stack size. */
#endif /* __MSDOS__ */

#ifdef SYSV
static char *VersionStr =
        "Gif library module,\t\tGershon Elber\n\
	(C) Copyright 1989 Gershon Elber, Non commercial use only.\n";
static char
    *CtrlStr = "GifComb q%- m%-MaskGIFFile!s h%- GifFile!*s";
#else
static char
    *VersionStr =
	PROGRAM_NAME
	GIF_LIB_VERSION
	"	Gershon Elber,	"
	__DATE__ ",   " __TIME__ "\n"
	"(C) Copyright 1989 Gershon Elber, Non commercial use only.\n";
static char
    *CtrlStr =
	PROGRAM_NAME
	" q%- m%-MaskGIFFile!s h%- GifFile!*s";
#endif /* SYSV */

static int ReadUntilImage(GifFileType *GifFile);
static int UnionColorMap(GifColorType *ColorIn1, int ColorIn1Size,
			 GifColorType *ColorIn2, int ColorIn2Size,
			 GifColorType **ColorUnionPtr, int *ColorUnionSize,
			 GifPixelType ColorTransIn2[]);
static void QuitGifError(GifFileType *GifFileIn1, GifFileType *GifFileIn2,
			 GifFileType *GifMaskFile, GifFileType *GifFileOut);

/******************************************************************************
* Interpret the command line and scan the given GIF file.		      *
******************************************************************************/
void main(int argc, char **argv)
{
    int	i, j, Error, NumFiles, Size, ColorUnionSize,
	ColorIn1Size = 0, ColorIn2Size = 0,
	MaskFlag = FALSE, HelpFlag = FALSE;
    char **FileName = NULL, *MaskFileName;
    GifPixelType ColorTransIn2[256];
    GifRowType LineIn1 = NULL, LineIn2 = NULL, LineMask = NULL, LineOut = NULL;
    GifColorType *ColorIn1 = NULL, *ColorIn2 = NULL, *ColorUnion;
    GifFileType *GifFileIn1 = NULL, *GifFileIn2 = NULL, *GifMaskFile = NULL,
	*GifFileOut = NULL;

    if ((Error = GAGetArgs(argc, argv, CtrlStr,
		&GifQuitePrint, &MaskFlag, &MaskFileName,
		&HelpFlag, &NumFiles, &FileName)) != FALSE ||
		(NumFiles != 2 && !HelpFlag)) {
	if (Error)
	    GAPrintErrMsg(Error);
	else if (NumFiles != 2)
	    GIF_MESSAGE("Error in command line parsing - two GIF file please.");
	GAPrintHowTo(CtrlStr);
	exit(1);
    }

    if (HelpFlag) {
	fprintf(stderr, VersionStr);
	GAPrintHowTo(CtrlStr);
	exit(0);
    }

    /* Open all input files (two GIF to combine, and optional mask): */
    if ((GifFileIn1 = DGifOpenFileName(FileName[0])) == NULL ||
	(GifFileIn2 = DGifOpenFileName(FileName[1])) == NULL ||
	(MaskFlag && (GifMaskFile = DGifOpenFileName(MaskFileName)) == NULL))
	QuitGifError(GifFileIn1, GifFileIn2, GifMaskFile, GifFileOut);

    if (ReadUntilImage(GifFileIn1) == GIF_ERROR ||
	ReadUntilImage(GifFileIn2) == GIF_ERROR ||
	(MaskFlag && ReadUntilImage(GifMaskFile) == GIF_ERROR))
	QuitGifError(GifFileIn1, GifFileIn2, GifMaskFile, GifFileOut);

    if (GifFileIn1 -> IWidth != GifFileIn2 -> IWidth ||
	GifFileIn2 -> IHeight != GifFileIn2 -> IHeight ||
	(MaskFlag && (GifFileIn1 -> IWidth != GifMaskFile -> IWidth ||
		      GifFileIn1 -> IHeight != GifMaskFile -> IHeight)))
	GIF_EXIT("Given GIF files have different image dimensions.");

    /* Open stdout for the output file: */
    if ((GifFileOut = EGifOpenFileHandle(1)) == NULL)
	QuitGifError(GifFileIn1, GifFileIn2, GifMaskFile, GifFileOut);

    Size = sizeof(GifPixelType) * GifFileIn1 -> IWidth;
    if ((LineIn1 = (GifRowType) malloc(Size)) == NULL ||
	(LineIn2 = (GifRowType) malloc(Size)) == NULL ||
	(MaskFlag && (LineMask = (GifRowType) malloc(Size)) == NULL) ||
	(LineOut = (GifRowType) malloc(Size)) == NULL)
	GIF_EXIT("Failed to allocate memory required, aborted.");

    if (GifFileIn1 -> IColorMap) {
	ColorIn1 = GifFileIn1 -> IColorMap;
	ColorIn1Size = 1 << GifFileIn1 -> IBitsPerPixel;
    }
    else if (GifFileIn1 -> SColorMap) {
	ColorIn1 = GifFileIn1 -> SColorMap;
	ColorIn1Size = 1 << GifFileIn1 -> SBitsPerPixel;
    }
    else
	GIF_EXIT("Neither Screen nor Image color map exists - GIF file 1.");

    if (GifFileIn2 -> IColorMap) {
	ColorIn2 = GifFileIn2 -> IColorMap;
	ColorIn2Size = 1 << GifFileIn2 -> IBitsPerPixel;
    }
    else if (GifFileIn2 -> SColorMap) {
	ColorIn2 = GifFileIn2 -> SColorMap;
	ColorIn2Size = 1 << GifFileIn2 -> SBitsPerPixel;
    }
    else
	GIF_EXIT("Neither Screen nor Image color map exists - GIF file 2.");

    /* Create union of the two given color maps. ColorIn1 will be copied as  */
    /* is while ColorIn2 will be mapped using ColorTransIn2 table.	     */
    /* ColorUnion is allocated by the procedure itself.			     */
    if (UnionColorMap(ColorIn1, ColorIn1Size, ColorIn2, ColorIn2Size,
		&ColorUnion, &ColorUnionSize, ColorTransIn2) == GIF_ERROR)
	GIF_EXIT("Unioned color map is two big (>256 colors).");

    /* Dump out new image and screen descriptors: */
    if (EGifPutScreenDesc(GifFileOut,
	GifFileIn1 -> SWidth, GifFileIn1 -> SHeight,
	ColorUnionSize, GifFileIn1 -> SBackGroundColor,
	ColorUnionSize, ColorUnion) == GIF_ERROR)
	QuitGifError(GifFileIn1, GifFileIn2, GifMaskFile, GifFileOut);
    free((char *) ColorUnion);		    /* We dont need this any more... */

    if (EGifPutImageDesc(GifFileOut,
	GifFileIn1 -> ILeft, GifFileIn1 -> ITop,
	GifFileIn1 -> IWidth, GifFileIn1 -> IHeight,
	GifFileIn1 -> IInterlace, GifFileIn1 -> IBitsPerPixel, NULL) == GIF_ERROR)
	QuitGifError(GifFileIn1, GifFileIn2, GifMaskFile, GifFileOut);


    /* Time to do it: read 2 scan lines from 2 files (and optionally from    */
    /* the mask file, merge them and them result out. Do it Height times:    */
    GifQprintf("\n%s: Image 1 at (%d, %d) [%dx%d]:     ",
	PROGRAM_NAME, GifFileOut -> ILeft, GifFileOut -> ITop,
				GifFileOut -> IWidth, GifFileOut -> IHeight);
    for (i = 0; i < GifFileIn1 -> IHeight; i++) {
	if (DGifGetLine(GifFileIn1, LineIn1, GifFileIn1 -> IWidth) == GIF_ERROR ||
	    DGifGetLine(GifFileIn2, LineIn2, GifFileIn2 -> IWidth) == GIF_ERROR ||
	    (MaskFlag &&
	     DGifGetLine(GifMaskFile, LineMask, GifMaskFile -> IWidth)
								== GIF_ERROR))
	    QuitGifError(GifFileIn1, GifFileIn2, GifMaskFile, GifFileOut);
	if (MaskFlag) {
	    /* Every time Mask has non background color, use LineIn1 pixel,  */
	    /* otherwise use LineIn2 pixel instead.			     */
	    for (j = 0; j < GifFileIn1 -> IWidth; j++) {
		if (LineMask[j] != GifMaskFile -> SBackGroundColor)
		    LineOut[j] = LineIn1[j];
		else
		    LineOut[j] = ColorTransIn2[LineIn2[j]];
	    }
	}
	else {
	    /* Every time Color of Image 1 is equal to background - take it  */
	    /* From Image 2 instead of the background.			     */
	    for (j = 0; j < GifFileIn1 -> IWidth; j++) {
		if (LineIn1[j] != GifFileIn1 -> SBackGroundColor)
		    LineOut[j] = LineIn1[j];
		else
		    LineOut[j] = ColorTransIn2[LineIn2[j]];
	    }
	}
	if (EGifPutLine(GifFileOut, LineOut, GifFileOut -> IWidth)
								== GIF_ERROR)
	QuitGifError(GifFileIn1, GifFileIn2, GifMaskFile, GifFileOut);
	GifQprintf("\b\b\b\b%-4d", i);
    }

    if (DGifCloseFile(GifFileIn1) == GIF_ERROR ||
	DGifCloseFile(GifFileIn2) == GIF_ERROR ||
	EGifCloseFile(GifFileOut) == GIF_ERROR ||
	(MaskFlag && DGifCloseFile(GifMaskFile) == GIF_ERROR))
	QuitGifError(GifFileIn1, GifFileIn2, GifMaskFile, GifFileOut);
}

/******************************************************************************
* Read until first image in GIF file is detected and read its descriptor.     *
******************************************************************************/
static int ReadUntilImage(GifFileType *GifFile)
{
    int ExtCode;
    GifRecordType RecordType;
    GifByteType *Extension;

    /* Scan the content of the GIF file, until image descriptor is detected: */
    do {
	if (DGifGetRecordType(GifFile, &RecordType) == GIF_ERROR)
	    return GIF_ERROR;

	switch (RecordType) {
	    case IMAGE_DESC_RECORD_TYPE:
		return DGifGetImageDesc(GifFile);
	    case EXTENSION_RECORD_TYPE:
		/* Skip any extension blocks in file: */
		if (DGifGetExtension(GifFile, &ExtCode, &Extension) == GIF_ERROR)
		    return GIF_ERROR;

		while (Extension != NULL)
		    if (DGifGetExtensionNext(GifFile, &Extension) == GIF_ERROR)
			return GIF_ERROR;
		break;
	    case TERMINATE_RECORD_TYPE:
		break;
	    default:		    /* Should be traps by DGifGetRecordType. */
		break;
	}
    }
    while (RecordType != TERMINATE_RECORD_TYPE);

    return GIF_ERROR;		  /* We should be here - no image was found! */
}

/******************************************************************************
* Create union of the two given color maps and return it. If result can not   *
* fit into 256 colors, GIF_ERROR is returned, GIF_OK otherwise.		      *
* ColorIn1 is copied as it to ColorUnion, while colors from ColorIn2 are      *
* copied iff they dont exists before. ColorTransIn2 is used to map old	      *
* ColorIn2 into ColorUnion color map table.				      *
******************************************************************************/
static int UnionColorMap(GifColorType *ColorIn1, int ColorIn1Size,
			 GifColorType *ColorIn2, int ColorIn2Size,
			 GifColorType **ColorUnionPtr, int *ColorUnionSize,
			 GifPixelType ColorTransIn2[])
{
    int i, j, CrntSlot;
    GifColorType *ColorUnion;

    /* Allocate table which will hold result for sure: */
    *ColorUnionPtr = ColorUnion = (GifColorType *) malloc(sizeof(GifColorType)
	* (ColorIn1Size > ColorIn2Size ? ColorIn1Size : ColorIn2Size) * 2);

    /* Copy ColorIn1 to ColorUnionSize; */
    for (i = 0; i < ColorIn1Size; i++) ColorUnion[i] = ColorIn1[i];
    CrntSlot = ColorIn1Size;			      /* Current Empty slot. */

    /* Copy ColorIn2 to ColorUnionSize (use old colors if exists): */
    for (i = 0; i < ColorIn2Size && CrntSlot<=256; i++) {
	/* Let see if this color already exists: */
	for (j = 0; j < ColorIn1Size; j++) {
	    /* If memcmp does not exists for you, use the following: */
	    /*
	    if (ColorIn1[j].Red   == ColorIn2[i].Red &&
		ColorIn1[j].Green == ColorIn2[i].Green &&
		ColorIn1[j].Blue  == ColorIn2[i].Blue) break;
	    */
	    if (memcmp(&ColorIn1[j], &ColorIn2[i], 3) == 0) break;
	}
	if (j < ColorIn1Size) {
	    /* We found this color aleardy exists in ColorIn1: */
	    ColorTransIn2[i] = j;
	}
	else {
	    /* Its new - copy it to a new slot: */
	    ColorUnion[CrntSlot] = ColorIn2[i];
	    ColorTransIn2[i] = CrntSlot++;
	}
    }

    if (CrntSlot > 256) return GIF_ERROR;

    /* Complete the color map to a power of two: */
    for (i = 1; i <= 8; i++) if ((1 << i) >= CrntSlot) break;
    for (j = CrntSlot; j < (1 << i); j++)
	ColorUnion[j].Red = ColorUnion[j].Green = ColorUnion[j].Blue = 0;

    *ColorUnionSize = i;

    return GIF_OK;
}

/******************************************************************************
* Close both input and output file (if open), and exit.			      *
******************************************************************************/
static void QuitGifError(GifFileType *GifFileIn1, GifFileType *GifFileIn2,
			 GifFileType *GifMaskFile, GifFileType *GifFileOut)
{
    PrintGifError();
    if (GifFileIn1 != NULL) DGifCloseFile(GifFileIn1);
    if (GifFileIn2 != NULL) DGifCloseFile(GifFileIn2);
    if (GifMaskFile != NULL) DGifCloseFile(GifMaskFile);
    if (GifFileOut != NULL) EGifCloseFile(GifFileOut);
    exit(1);
}
