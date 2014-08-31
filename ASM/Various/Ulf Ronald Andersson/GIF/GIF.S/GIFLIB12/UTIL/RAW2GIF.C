/*****************************************************************************
*   "Gif-Lib" - Yet another gif library.				     *
*									     *
* Written by:  Gershon Elber				Ver 0.1, Jun. 1989   *
******************************************************************************
* Module to conver raw image into a GIF file.				     *
* Options:                                                                   *
* -q : quite printing mode.						     *
* -s Width Height : specifies size of raw image.                             *
* -p ColorMapFile : specifies color map for ray image (see gifclrmp).        *
* -h : on line help.                                                         *
******************************************************************************
* History:								     *
* 15 Oct 89 - Version 1.0 by Gershon Elber.				     *
*****************************************************************************/

#ifdef __MSDOS__
#include <dos.h>
#include <alloc.h>
#include <stdlib.h>
#include <graphics.h>
#include <io.h>
#endif /* __MSDOS__ */

#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include "getarg.h"
#include "gif_lib.h"

#define PROGRAM_NAME	"Raw2Gif"

#ifdef __MSDOS__
extern unsigned int
    _stklen = 16384;			     /* Increase default stack size. */
#endif /* __MSDOS__ */

#ifdef SYSV
static char *VersionStr =
        "Gif library module,\t\tGershon Elber\n\
	(C) Copyright 1989 Gershon Elber, Non commercial use only.\n";
static char
    *CtrlStr = "Raw2Gif q%- s!-Width|Height!d!d p%-ColorMapFile!s h%- RawFile!*s";
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
	" q%- s!-Width|Height!d!d p%-ColorMapFile!s h%- RawFile!*s";
#endif /* SYSV */

static GifColorType EGAPallete[] =      /* Default color map is EGA pallete. */
{
    {   0,   0,   0 },   /* 0. Black */
    {   0,   0, 170 },   /* 1. Blue */
    {   0, 170,   0 },   /* 2. Green */
    {   0, 170, 170 },   /* 3. Cyan */
    { 170,   0,   0 },   /* 4. Red */
    { 170,   0, 170 },   /* 5. Magenta */
    { 170, 170,   0 },   /* 6. Brown */
    { 170, 170, 170 },   /* 7. LightGray */
    {  85,  85,  85 },   /* 8. DarkGray */
    {  85,  85, 255 },   /* 9. LightBlue */
    {  85, 255,  85 },   /* 10. LightGreen */
    {  85, 255, 255 },   /* 11. LightCyan */
    { 255,  85,  85 },   /* 12. LightRed */
    { 255,  85, 255 },   /* 13. LightMagenta */
    { 255, 255,  85 },   /* 14. Yellow */
    { 255, 255, 255 },   /* 15. White */
};
#define EGA_PALLETE_SIZE (sizeof(EGAPallete) / sizeof(GifColorType))

int Raw2Gif(int ImagwWidth, int ImagwHeight,
				GifColorType *ColorMap, int ColorMapSize);
static int HandleGifError(GifFileType *GifFile);

/******************************************************************************
* Interpret the command line, prepar global data and call the Gif routines.   *
******************************************************************************/
void main(int argc, char **argv)
{
    int	Error, NumFiles, ImageWidth, ImageHeight, Dummy, Red, Green, Blue,
	ColorMapSize, InFileHandle,
	ImageSizeFlag = FALSE, ColorMapFlag = FALSE, HelpFlag = FALSE;
    char **FileName = NULL, *ColorMapFile;
    GifColorType *ColorMap;
    FILE *InColorMapFile;

    if ((Error = GAGetArgs(argc, argv, CtrlStr, &GifQuitePrint,
		&ImageSizeFlag, &ImageWidth, &ImageHeight,
		&ColorMapFlag, &ColorMapFile,
		&HelpFlag,
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

    if (ColorMapFlag) {
	/* Read color map from given file: */
	if ((InColorMapFile = fopen(ColorMapFile, "rt")) == NULL) {
	    GIF_MESSAGE("Failed to open COLOR MAP file (not exists!?).");
	    exit(2);
	}
	if ((ColorMap = (GifColorType *) 
	                malloc(sizeof(GifColorType) * 255))  /* Biggest map. */
	    == NULL) {
	    GIF_MESSAGE("Failed to allocate bitmap, aborted.");
	    exit(3);
	}

	for (ColorMapSize = 0;
	     ColorMapSize < 256 && !feof(InColorMapFile);
	     ColorMapSize++) {
	    fscanf(InColorMapFile, "%3d %3d %3d %3d\n",
						&Dummy, &Red, &Green, &Blue);
	    ColorMap[ColorMapSize].Red = Red;
	    ColorMap[ColorMapSize].Green = Green;
	    ColorMap[ColorMapSize].Blue = Blue;
	}
    }
    else {
	ColorMap = EGAPallete;
	ColorMapSize = EGA_PALLETE_SIZE;
    }

    if (NumFiles == 1) {
#ifdef __MSDOS__
	if ((InFileHandle = open(*FileName, O_RDONLY | O_BINARY)) == -1) {
#else
	if ((InFileHandle = open(*FileName, O_RDONLY)) == -1) {
#endif /* __MSDOS__ */
	    GIF_MESSAGE("Failed to open RAW image file (not exists!?).");
	    exit(2);
	}
	dup2(InFileHandle, 0);		       /* Make stdin from this file. */
    }
    else {
#ifdef __MSDOS__
	setmode(0, O_BINARY);		  /* Make sure it is in binary mode. */
#endif /* __MSDOS__ */
    }

#ifdef __MSDOS__
    setvbuf(stdin, NULL, _IOFBF, GIF_FILE_BUFFER_SIZE);
#endif /* __MSDOS__ */

    /* Conver Raw image from stdin to Gif file in stdout: */
    Raw2Gif(ImageWidth, ImageHeight, ColorMap, ColorMapSize);
}

/******************************************************************************
* Convert Raw image (One byte per pixel) into Gif file. Raw data is read from *
* stdin, and Gif is dumped to stdout. ImagwWidth times ImageHeight bytes are  *
* read. Color map is dumped from ColorMap.				      *
******************************************************************************/
int Raw2Gif(int ImageWidth, int ImageHeight,
				GifColorType *ColorMap, int ColorMapSize)
{
    static int BitsPerPixelArray[] = { 2, 4 ,8, 16, 32, 64, 128, 256 };
    int i, j, BitsPerPixel;
    static GifPixelType *ScanLine;
    GifFileType *GifFile;

    for (BitsPerPixel = 0;
	 BitsPerPixel < 8 && BitsPerPixelArray[BitsPerPixel] != ColorMapSize;
	 BitsPerPixel++);
    if (++BitsPerPixel > 8) {
	GIF_MESSAGE("Number of color map is NOT power of 2 up to 256.");
	exit(3);
    }

    if ((ScanLine = (GifPixelType *) malloc(sizeof(GifPixelType) * ImageWidth))
								== NULL) {
	GIF_MESSAGE("Failed to allocate scan line, aborted.");
	exit(3);
    }

    if ((GifFile = EGifOpenFileHandle(1)) == NULL) {	   /* Gif to stdout. */
	free((char *) ScanLine);
	return HandleGifError(GifFile);
    }

    if (EGifPutScreenDesc(GifFile, ImageWidth, ImageHeight, BitsPerPixel,
			  0, BitsPerPixel, ColorMap) == GIF_ERROR) {
	free((char *) ScanLine);
	return HandleGifError(GifFile);
    }

    if (EGifPutImageDesc(GifFile, 0, 0, ImageWidth, ImageHeight, FALSE, 1,
			 NULL) == GIF_ERROR) {
	free((char *) ScanLine);
	return HandleGifError(GifFile);
    }

    /* Here it is - get one raw line from stdin, and dump to stdout Gif: */
    GifQprintf("\n%s: Image 1 at (0, 0) [%dx%d]:     ",
	PROGRAM_NAME, ImageWidth, ImageHeight);
    for (i = 0; i < ImageHeight; i++) {
	/* Note we assume here PixelSize == Byte, which is not necessarily   */
	/* so. If not - must read one byte at a time, and coerce to pixel.   */
	if (fread(ScanLine, 1, ImageWidth, stdin) != ImageWidth) {
	    GIF_MESSAGE("RAW input file ended prematurely.");
	    exit(3);
	}

	for (j = 0; j < ImageWidth; j++)
	    if (ScanLine[j] >= ColorMapSize)
		GIF_MESSAGE("Warning: RAW data color > maximum color map entry.");

	if (EGifPutLine(GifFile, ScanLine, ImageWidth) == GIF_ERROR) {
	    free((char *) ScanLine);
	    return HandleGifError(GifFile);
	}
	GifQprintf("\b\b\b\b%-4d", i);
    }

    if (EGifCloseFile(GifFile) == GIF_ERROR) {
	free((char *) ScanLine);
	return HandleGifError(GifFile);
    }

    free((char *) ScanLine);
    return 0;
}

/******************************************************************************
* Handle last GIF error. Try to close the file and free all allocated memory. *
******************************************************************************/
static int HandleGifError(GifFileType *GifFile)
{
    int i = GifLastError();

    if (EGifCloseFile(GifFile) == GIF_ERROR) {
	GifLastError();
    }
    return i;
}
