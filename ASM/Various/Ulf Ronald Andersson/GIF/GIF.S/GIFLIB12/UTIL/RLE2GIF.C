/*****************************************************************************
*   "Gif-Lib" - Yet another gif library.				     *
*									     *
* Written by:  Gershon Elber				Ver 0.1, Jul. 1989   *
******************************************************************************
* Program to convert RLE (utah raster toolkit) file to GIF format.	     *
* Options:								     *
* -q : quite printing mode.						     *
* -c #colors : in power of two, i.e. 7 will allow upto 128 colors in output. *
* -h : on line help.							     *
******************************************************************************
* History:								     *
* 5 Jan 90 - Version 1.0 by Gershon Elber.				     *
*****************************************************************************/

#ifdef __MSDOS__
#include <graphics.h>
#include <stdlib.h>
#include <alloc.h>
#include <io.h>
#include <dos.h>
#include <bios.h>
#endif /* __MSDOS__ */

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <fcntl.h>
#include "gif_lib.h"
#include "getarg.h"

#include "rle.h"			   /* The rle tool kit header files. */

#define PROGRAM_NAME	"Rle2Gif"

#ifdef __MSDOS__
extern unsigned int
    _stklen = 16384;			     /* Increase default stack size. */
#endif /* __MSDOS__ */

#ifdef SYSV
static char *VersionStr =
        "Gif library module,\t\tGershon Elber\n\
	(C) Copyright 1989 Gershon Elber, Non commercial use only.\n";
static char
    *CtrlStr = "Rle2Gif q%- c%-#Colors!d h%- RleFile!*s";
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
	" q%- c%-#Colors!d h%- RleFile!*s";
#endif /* SYSV */

/* Make some variables global, so we could access them faster: */
static int
    ColorFlag = FALSE,
    ExpNumOfColors = 8,
    HelpFlag = FALSE,
    ColorMapSize = 256;

static void LoadRle(char *FileName,
		    GifByteType **RedBuffer,
		    GifByteType **GreenBuffer,
		    GifByteType **BlueBuffer,
		    int *Width, int *Height);
static void SaveGif(GifByteType *OutputBuffer,
		    GifColorType *OutputColorMap,
		    int ExpColorMapSize, int Width, int Height);
static void QuitGifError(GifFileType *GifFile);

/******************************************************************************
* Interpret the command line and scan the given GIF file.		      *
******************************************************************************/
void main(int argc, char **argv)
{
    int	i, j, Error, NumFiles, Width, Height;
    char **FileName = NULL;
    GifByteType *RedBuffer = NULL, *GreenBuffer = NULL, *BlueBuffer = NULL,
        *OutputBuffer = NULL;
    GifColorType *OutputColorMap = NULL;

    if ((Error = GAGetArgs(argc, argv, CtrlStr, &GifQuitePrint,
		&ColorFlag, &ExpNumOfColors, &HelpFlag,
		&NumFiles, &FileName)) != FALSE ||
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

    ColorMapSize = 1 << ExpNumOfColors;

    if (NumFiles == 1) {
	LoadRle(*FileName,
		&RedBuffer, &GreenBuffer, &BlueBuffer, &Width, &Height);
    }
    else {
	LoadRle(NULL,
		&RedBuffer, &GreenBuffer, &BlueBuffer, &Width, &Height);
    }

    if ((OutputColorMap = (GifColorType *) malloc(ColorMapSize *
					      sizeof(GifColorType))) == NULL ||
	(OutputBuffer = (GifByteType *) malloc(Width * Height *
					    sizeof(GifByteType))) == NULL)
	GIF_EXIT("Failed to allocate memory required, aborted.");

    if (QuantizeBuffer(Width, Height, &ColorMapSize,
		       RedBuffer, GreenBuffer, BlueBuffer,
		       OutputBuffer, OutputColorMap) == GIF_ERROR)
	QuitGifError(NULL);
    free((char *) RedBuffer);
    free((char *) GreenBuffer);
    free((char *) BlueBuffer);

    SaveGif(OutputBuffer, OutputColorMap, ExpNumOfColors, Width, Height);
}

/******************************************************************************
* Load RLE file into internal frame buffer.				      *
******************************************************************************/
static void LoadRle(char *FileName,
		    GifByteType **RedBuffer,
		    GifByteType **GreenBuffer,
		    GifByteType **BlueBuffer,
		    int *Width, int *Height)
{
    int i, j, k, Size;
    GifByteType *OutputPtr[3];
    rle_hdr in_hdr;
    rle_pixel **rows, *ptr;
    
    if (FileName != NULL) {
	if ((in_hdr.rle_file = fopen(FileName, "r")) == NULL)
	    GIF_EXIT("Can't open input file name.");
    }
    else
	in_hdr.rle_file = stdin;

    rle_get_setup_ok( &in_hdr, "rle2gif", FileName );

    *Width = in_hdr.xmax - in_hdr.xmin + 1;
    *Height = in_hdr.ymax - in_hdr.ymin + 1;

    if (in_hdr.ncolors != 3)
	GIF_EXIT("Input Rle file does not hold 3 (RGB) colors, aborted.");

    Size = *Width * *Height * sizeof(GifByteType);
    if (rle_row_alloc(&in_hdr, &rows) ||
	(*RedBuffer = (GifByteType *) malloc(Size)) == NULL ||
	(*GreenBuffer = (GifByteType *) malloc(Size)) == NULL ||
	(*BlueBuffer = (GifByteType *) malloc(Size)) == NULL)
	GIF_EXIT("Failed to allocate memory required, aborted.");

    OutputPtr[0] = *RedBuffer;
    OutputPtr[1] = *GreenBuffer;
    OutputPtr[2] = *BlueBuffer;

    for (i = 0; i < *Height; i++) {
	rle_getrow(&in_hdr, rows);	    /* Get one scan line (3 colors). */

	for (j = 0; j < 3; j++) { /* Copy the 3 colors to the given buffers. */
	    ptr = &rows[j][in_hdr.xmin];

	    for (k = 0; k < *Width; k++)
		*OutputPtr[j]++ = *ptr++;
	}
    }
}

/******************************************************************************
* Save the GIF resulting image.						      *
******************************************************************************/
static void SaveGif(GifByteType *OutputBuffer,
		    GifColorType *OutputColorMap,
		    int ExpColorMapSize, int Width, int Height)
{
    int i;
    GifFileType *GifFile;
    GifByteType *Ptr = OutputBuffer + Width * (Height - 1);

    /* Open stdout for the output file: */
    if ((GifFile = EGifOpenFileHandle(1)) == NULL)
	QuitGifError(GifFile);

    if (EGifPutScreenDesc(GifFile,
			  Width, Height, ExpColorMapSize, 0, ExpColorMapSize,
			  OutputColorMap) == GIF_ERROR ||
	EGifPutImageDesc(GifFile,
			 0, 0, Width, Height, FALSE, ExpColorMapSize, NULL) ==
	                                                             GIF_ERROR)
	QuitGifError(GifFile);

    GifQprintf("\n%s: Image 1 at (%d, %d) [%dx%d]:     ",
	       PROGRAM_NAME, GifFile -> ILeft, GifFile -> ITop,
	       GifFile -> IWidth, GifFile -> IHeight);

    for (i = 0; i < Height; i++) {
	if (EGifPutLine(GifFile, Ptr, Width) == GIF_ERROR)
	    QuitGifError(GifFile);
	GifQprintf("\b\b\b\b%-4d", Height - i - 1);

	Ptr -= Width;
    }

    if (EGifCloseFile(GifFile) == GIF_ERROR)
	QuitGifError(GifFile);
}

/******************************************************************************
* Close output file (if open), and exit.				      *
******************************************************************************/
static void QuitGifError(GifFileType *GifFile)
{
    PrintGifError();
    if (GifFile != NULL) EGifCloseFile(GifFile);
    exit(1);
}
