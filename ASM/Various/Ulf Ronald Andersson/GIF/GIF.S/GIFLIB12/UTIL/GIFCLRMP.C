/*****************************************************************************
*   "Gif-Lib" - Yet another gif library.				     *
*									     *
* Written by:  Gershon Elber				Ver 0.1, Jul. 1989   *
******************************************************************************
* Program to modify GIF file color map(s). Images are not modified at all.   *
* Options:								     *
* -q : quite printing mode.						     *
* -s : save screen color map (unless -i - see below), to stdout.	     *
* -l colormap.file : substitute given colormap.file colormap into screen     *
*    colormap (unless -i - see below).					     *
* -g correction : apply gamma correction to the screen colormap (unless -i - *
*    see below).							     *
* -i n : select image number n color map instead of screen map for above     *
*    operations (n = 1 for first image).				     *
* -h : on line help.							     *
*   All color maps are ascii text files, with one line per color of the      *
* form: index, Red color, Green color, Blue color - all in the range 0..255. *
*   All color maps should be in the exact same length.			     *
******************************************************************************
* History:								     *
* 17 Jul 89 - Version 1.0 by Gershon Elber.				     *
*****************************************************************************/

#ifdef __MSDOS__
#include <stdlib.h>
#include <alloc.h>
#endif /* __MSDOS__ */

#include <math.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "gif_lib.h"
#include "getarg.h"

#define PROGRAM_NAME	"GifClrMp"

#ifdef __MSDOS__
extern unsigned int
    _stklen = 16384;			     /* Increase default stack size. */
#endif /* __MSDOS__ */

#ifdef SYSV
static char *VersionStr =
        "Gif library module,\t\tGershon Elber\n\
	(C) Copyright 1989 Gershon Elber, Non commercial use only.\n";
static char
    *CtrlStr = "GifClrMp q%- s%- l%-ColorMapFile!s g%-Gamma!F i%-Image#!d h%- GifFile!*s";
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
	" q%- s%- l%-ColorMapFile!s g%-Gamma!F i%-Image#!d h%- GifFile!*s";
#endif /* SYSV */

static int
    SaveFlag = FALSE,
    LoadFlag = FALSE,
    GammaFlag = FALSE;
static
    double Gamma = 1.0;
static
    FILE *ColorFile = NULL;


static void ModifyColorMap(GifColorType *ColorMap, int BitsPerPixel);
static void QuitGifError(GifFileType *GifFileIn, GifFileType *GifFileOut);

/******************************************************************************
* Interpret the command line and scan the given GIF file.		      *
******************************************************************************/
void main(int argc, char **argv)
{
    int	Error, NumFiles, ExtCode, CodeSize, ImageNum = 0,
	ImageNFlag = FALSE, ImageN, HelpFlag = FALSE, HasGIFOutput;
    GifRecordType RecordType;
    GifByteType *Extension, *CodeBlock;
    char **FileName = NULL, *ColorFileName;
    GifFileType *GifFileIn = NULL, *GifFileOut = NULL;

    if ((Error = GAGetArgs(argc, argv, CtrlStr, &GifQuitePrint,
		&SaveFlag, &LoadFlag, &ColorFileName,
		&GammaFlag, &Gamma, &ImageNFlag, &ImageN,
		&HelpFlag, &NumFiles, &FileName)) != FALSE ||
		(NumFiles > 1 && !HelpFlag)) {
	if (Error)
	    GAPrintErrMsg(Error);
	else if (NumFiles > 1)
	    GIF_MESSAGE("Error in command line parsing - one GIF file please.");
	GAPrintHowTo(CtrlStr);
	exit(1);
    }

    if (HelpFlag) {
	fprintf(stderr, VersionStr);
	GAPrintHowTo(CtrlStr);
	exit(0);
    }

    if (SaveFlag && LoadFlag || SaveFlag && GammaFlag || LoadFlag && GammaFlag)
	GIF_EXIT("Can not handle more than one of -s -l or -g at the same time.");

    if (NumFiles == 1) {
	if ((GifFileIn = DGifOpenFileName(*FileName)) == NULL)
	    QuitGifError(GifFileIn, GifFileOut);
    }
    else {
	/* Use the stdin instead: */
	if ((GifFileIn = DGifOpenFileHandle(0)) == NULL)
	    QuitGifError(GifFileIn, GifFileOut);
    }

    if (SaveFlag) {
	/* We are dumping out the color map as text file to stdout: */
	ColorFile = stdout;
    }
    else if (LoadFlag) {
	/* We are loading new color map from specified file: */
	if ((ColorFile = fopen(ColorFileName, "rt")) == NULL)
	    GIF_EXIT("Failed to open specified color map file.");
    }

    if ((HasGIFOutput = (LoadFlag || GammaFlag)) != 0) {
	/* Open stdout for GIF output file: */
	if ((GifFileOut = EGifOpenFileHandle(1)) == NULL)
	    QuitGifError(GifFileIn, GifFileOut);
    }

    if (!ImageNFlag) {
	/* We are suppose to modify the screen color map, so do it: */
	ModifyColorMap(GifFileIn -> SColorMap, GifFileIn -> SBitsPerPixel);
	if (!HasGIFOutput) {
	    /* We can quit here, as we have the color map: */
	    if (GifFileIn != NULL) DGifCloseFile(GifFileIn);
	    fclose(ColorFile);
	    exit(0);
	}
    }
    /* And dump out its new possible repositioned screen information: */
    if (HasGIFOutput)
	if (EGifPutScreenDesc(GifFileOut,
	    GifFileIn -> SWidth, GifFileIn -> SHeight,
	    GifFileIn -> SColorResolution, GifFileIn -> SBackGroundColor,
	    GifFileIn -> SBitsPerPixel, GifFileIn -> SColorMap) == GIF_ERROR)
	    QuitGifError(GifFileIn, GifFileOut);

    /* Scan the content of the GIF file and load the image(s) in: */
    do {
	if (DGifGetRecordType(GifFileIn, &RecordType) == GIF_ERROR)
	    QuitGifError(GifFileIn, GifFileOut);

	switch (RecordType) {
	    case IMAGE_DESC_RECORD_TYPE:
		if (DGifGetImageDesc(GifFileIn) == GIF_ERROR)
		    QuitGifError(GifFileIn, GifFileOut);
		if (++ImageNum == ImageN && ImageNFlag) {
		    /* We are suppose to modify this image color map, do it: */
		    ModifyColorMap(GifFileIn -> SColorMap,
                                                  GifFileIn -> SBitsPerPixel);
		    if (!HasGIFOutput) {
			/* We can quit here, as we have the color map: */
			if (GifFileIn != NULL) DGifCloseFile(GifFileIn);
			fclose(ColorFile);
			exit(0);
		    }
		}
		if (HasGIFOutput)
		    if (EGifPutImageDesc(GifFileOut,
			GifFileIn -> ILeft, GifFileIn -> ITop,
			GifFileIn -> IWidth, GifFileIn -> IHeight,
			GifFileIn -> IInterlace, GifFileIn -> IBitsPerPixel,
			GifFileIn -> IColorMap) == GIF_ERROR)
			QuitGifError(GifFileIn, GifFileOut);

		/* Now read image itself in decoded form as we dont really   */
		/* care what we have there, and this is much faster.	     */
		if (DGifGetCode(GifFileIn, &CodeSize, &CodeBlock) == GIF_ERROR)
		    QuitGifError(GifFileIn, GifFileOut);
		if (HasGIFOutput)
		    if (EGifPutCode(GifFileOut, CodeSize, CodeBlock) == GIF_ERROR)
			QuitGifError(GifFileIn, GifFileOut);
		while (CodeBlock != NULL) {
		    if (DGifGetCodeNext(GifFileIn, &CodeBlock) == GIF_ERROR)
			QuitGifError(GifFileIn, GifFileOut);
		    if (HasGIFOutput)
			if (EGifPutCodeNext(GifFileOut, CodeBlock) == GIF_ERROR)
			    QuitGifError(GifFileIn, GifFileOut);
		}
		break;
	    case EXTENSION_RECORD_TYPE:
		/* Skip any extension blocks in file: */
		if (DGifGetExtension(GifFileIn, &ExtCode, &Extension) == GIF_ERROR)
		    QuitGifError(GifFileIn, GifFileOut);
		if (HasGIFOutput)
		    if (EGifPutExtension(GifFileOut, ExtCode, Extension[0],
							Extension) == GIF_ERROR)
			QuitGifError(GifFileIn, GifFileOut);

		/* No support to more than one extension blocks, so discard: */
		while (Extension != NULL) {
		    if (DGifGetExtensionNext(GifFileIn, &Extension) == GIF_ERROR)
			QuitGifError(GifFileIn, GifFileOut);
		}
		break;
	    case TERMINATE_RECORD_TYPE:
		break;
	    default:		    /* Should be traps by DGifGetRecordType. */
		break;
	}
    }
    while (RecordType != TERMINATE_RECORD_TYPE);

    if (DGifCloseFile(GifFileIn) == GIF_ERROR)
	QuitGifError(GifFileIn, GifFileOut);
    if (HasGIFOutput)
	if (EGifCloseFile(GifFileOut) == GIF_ERROR)
	    QuitGifError(GifFileIn, GifFileOut);
}

/******************************************************************************
* Modify the given colormap according to global variables setting.	      *
******************************************************************************/
static void ModifyColorMap(GifColorType *ColorMap, int BitsPerPixel)
{
    int i, Dummy, Red, Green, Blue;
    double Gamma1;

    if (SaveFlag) {
	/* Save this color map to ColorFile: */
	for (i = 0; i < (1 << BitsPerPixel); i++)
	    fprintf(ColorFile, "%3d %3d %3d %3d\n", i,
		ColorMap[i].Red, ColorMap[i].Green, ColorMap[i].Blue);
    }
    else if (LoadFlag) {
	/* Read the color map in ColorFile into this color map: */
	for (i = 0; i < (1 << BitsPerPixel); i++) {
	    if (feof(ColorFile))
		GIF_EXIT("Color file to load color map from, too small.");
	    fscanf(ColorFile, "%3d %3d %3d %3d\n", &Dummy, &Red, &Green, &Blue);
	    ColorMap[i].Red = Red;
	    ColorMap[i].Green = Green;
	    ColorMap[i].Blue = Blue;
	}
    }
    else if (GammaFlag) {
	/* Apply gamma correction to this color map: */
	Gamma1 = 1.0 / Gamma;
	for (i = 0; i < (1 << BitsPerPixel); i++) {
	    ColorMap[i].Red =
		((int) (255 * pow(ColorMap[i].Red / 255.0, Gamma1)));
	    ColorMap[i].Green =
		((int) (255 * pow(ColorMap[i].Green / 255.0, Gamma1)));
	    ColorMap[i].Blue =
		((int) (255 * pow(ColorMap[i].Blue / 255.0, Gamma1)));
	}
    }
    else
	GIF_EXIT("Nothing to do!");
}

/******************************************************************************
* Close both input and output file (if open), and exit.			      *
******************************************************************************/
static void QuitGifError(GifFileType *GifFileIn, GifFileType *GifFileOut)
{
    PrintGifError();
    if (GifFileIn != NULL) DGifCloseFile(GifFileIn);
    if (GifFileOut != NULL) EGifCloseFile(GifFileOut);
    exit(1);
}

