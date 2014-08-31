/*****************************************************************************
*   "Gif-Lib" - Yet another gif library.				     *
*									     *
* Written by:  Gershon Elber				Ver 0.1, Jun. 1989   *
******************************************************************************
* Program to dump GIF file content as TEXT information			     *
* Options:								     *
* -q : quite printing mode.						     *
* -c : include the color maps as well.					     *
* -e : include encoded information packed as bytes as well.		     *
* -z : include encoded information (12bits) codes as result from the zl alg. *
* -p : dump pixel information instead of encoded information.		     *
* -r : same as -p but dump one pixel as one byte in binary form with no      *
*      other information. This will create a file of size Width by Height.   *
* -h : on line help.							     *
******************************************************************************
* History:								     *
* 28 Jun 89 - Version 1.0 by Gershon Elber.				     *
* 21 Dec 89 - Fix segmentation fault problem in PrintCodeBlock (Version 1.1) *
* 25 Dec 89 - Add the -r flag for raw output.                                *
*****************************************************************************/

#ifdef __MSDOS__
#include <stdlib.h>
#include <alloc.h>
#include <conio.h>
#include <io.h>
#endif /* __MSDOS__ */

#include <stdio.h>
#include <ctype.h>
#include <fcntl.h>
#include "gif_lib.h"
#include "getarg.h"

#define PROGRAM_NAME	"GifText"

#define MAKE_PRINTABLE(c)  (isprint(c) ? (c) : ' ')

#ifdef __MSDOS__
extern unsigned int
    _stklen = 16384;			     /* Increase default stack size. */
#endif /* __MSDOS__ */

#ifdef SYSV
static char *VersionStr =
        "Gif library module,\t\tGershon Elber\n\
	(C) Copyright 1989 Gershon Elber, Non commercial use only.\n";
static char
    *CtrlStr = "GifText q%- c%- e%- z%- p%- r%- h%- GifFile!*s";
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
	" q%- c%- e%- z%- p%- r%- h%- GifFile!*s";
#endif /* SYSV */

static void PrintCodeBlock(GifFileType *GifFile, GifByteType *CodeBlock, int Reset);
static void PrintPixelBlock(GifByteType *PixelBlock, int Len, int Reset);
static void PrintExtBlock(GifByteType *Extension, int Reset);
static void PrintLZCodes(GifFileType *GifFile);

/******************************************************************************
* Interpret the command line and scan the given GIF file.		      *
******************************************************************************/
void main(int argc, char **argv)
{
    int i, j, ExtCode, CodeSize, Error, NumFiles, Len,
	ColorMapFlag = FALSE, EncodedFlag = FALSE, LZCodesFlag = FALSE,
	PixelFlag = FALSE, HelpFlag = FALSE, RawFlag = FALSE, ImageNum = 1;
    char *GifFileName, **FileName = NULL;
    GifPixelType *Line;
    GifRecordType RecordType;
    GifByteType *CodeBlock, *Extension;
    GifFileType *GifFile;

    if ((Error = GAGetArgs(argc, argv, CtrlStr,
		&GifQuitePrint, &ColorMapFlag, &EncodedFlag,
		&LZCodesFlag, &PixelFlag, &RawFlag, &HelpFlag,
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

    if (NumFiles == 1) {
	GifFileName = *FileName;
	if ((GifFile = DGifOpenFileName(*FileName)) == NULL) {
	    PrintGifError();
	    exit(-1);
	}
    }
    else {
	/* Use the stdin instead: */
	GifFileName = "Stdin";
	if ((GifFile = DGifOpenFileHandle(0)) == NULL) {
	    PrintGifError();
	    exit(-1);
	}
    }

    /* Because we write binary data - make sure no text will be written. */
    if (RawFlag) {
	ColorMapFlag = EncodedFlag = LZCodesFlag = PixelFlag = FALSE;
#ifdef __MSDOS__
	setmode(1, O_BINARY);             /* Make sure it is in binary mode. */
#endif /* __MSDOS__ */
    }
    else {
	printf("\n%s:\n\n\tScreen Size - Width = %d, Height = %d.\n",
	       GifFileName, GifFile -> SWidth, GifFile -> SHeight);
	printf("\tColorResolution = %d, BitsPerPixel = %d, BackGround = %d.\n",
	       GifFile -> SColorResolution, GifFile -> SBitsPerPixel,
	       GifFile -> SBackGroundColor);
	if (GifFile -> SColorMap)
	    printf("\tHas Global Color Map.\n\n");
	else
	    printf("\tNo Global Color Map.\n\n");
	if (ColorMapFlag && GifFile -> SColorMap) {
	    printf("\tGlobal Color Map:\n");
	    Len = 1 << GifFile -> SBitsPerPixel;
	    for (i = 0; i < Len; i+=4) {
		for (j = 0; j < 4 && j < Len; j++) {
		    printf("%3d: %02xh %02xh %02xh   ", i + j,
			   GifFile -> SColorMap[i + j].Red,
			   GifFile -> SColorMap[i + j].Green,
			   GifFile -> SColorMap[i + j].Blue);
		}
		printf("\n");
	    }
	}
    }

    do {
	if (DGifGetRecordType(GifFile, &RecordType) == GIF_ERROR) {
	    PrintGifError();
	    exit(-1);
	}
	switch (RecordType) {
	    case IMAGE_DESC_RECORD_TYPE:
		if (DGifGetImageDesc(GifFile) == GIF_ERROR) {
		    PrintGifError();
		    exit(-1);
		}
		if (!RawFlag) {
		    printf("\nImage #%d:\n\n\tImage Size - Left = %d, Top = %d, Width = %d, Height = %d.\n",
			   ImageNum++, GifFile -> ILeft, GifFile -> ITop,
			   GifFile -> IWidth, GifFile -> IHeight);
		    printf("\tImage is %s",
			   GifFile -> IInterlace ? "Interlaced" :
						    "Non Interlaced");
		    if (GifFile -> IColorMap != NULL)
			printf(", BitsPerPixel = %d.\n",
						GifFile -> IBitsPerPixel);
		    else
			printf(".\n");
		    if (GifFile -> IColorMap)
			printf("\tImage Has Color Map.\n");
		    else
			printf("\tNo Image Color Map.\n");
		    if (ColorMapFlag && GifFile -> IColorMap) {
			Len = 1 << GifFile -> IBitsPerPixel;
			for (i = 0; i < Len; i+=4) {
			    for (j = 0; j < 4 && j < Len; j++) {
				printf("%3d: %02xh %02xh %02xh   ", i + j,
				       GifFile -> IColorMap[i + j].Red,
				       GifFile -> IColorMap[i + j].Green,
				       GifFile -> IColorMap[i + j].Blue);
			    }
			    printf("\n");
			}
		    }
		}

		if (EncodedFlag) {
		    if (DGifGetCode(GifFile, &CodeSize, &CodeBlock) == GIF_ERROR) {
			PrintGifError();
			exit(-1);
		    }
		    printf("\nImage LZ compressed Codes (Code Size = %d):\n",
			   CodeSize);
		    PrintCodeBlock(GifFile, CodeBlock, TRUE);
		    while (CodeBlock != NULL) {
			if (DGifGetCodeNext(GifFile, &CodeBlock) == GIF_ERROR) {
			    PrintGifError();
			    exit(-1);
			}
			PrintCodeBlock(GifFile, CodeBlock, FALSE);
		    }
		}
		else if (LZCodesFlag) {
		    PrintLZCodes(GifFile);
		}
		else if (PixelFlag) {
		    Line = (GifPixelType *) malloc(GifFile -> IWidth *
						sizeof(GifPixelType));
		    for (i = 0; i < GifFile -> IHeight; i++) {
			if (DGifGetLine(GifFile, Line, GifFile -> IWidth)
			    == GIF_ERROR) {
			    PrintGifError();
			    exit(-1);
			}
			PrintPixelBlock(Line, GifFile -> IWidth, i == 0);
		    }
		    PrintPixelBlock(NULL, GifFile -> IWidth, FALSE);
		    free((char *) Line);
		}
		else if (RawFlag) {
		    Line = (GifPixelType *) malloc(GifFile -> IWidth *
						sizeof(GifPixelType));
		    for (i = 0; i < GifFile -> IHeight; i++) {
			if (DGifGetLine(GifFile, Line, GifFile -> IWidth)
			    == GIF_ERROR) {
			    PrintGifError();
			    exit(-1);
			}
			fwrite(Line, 1, GifFile -> IWidth, stdout);
		    }
		    free((char *) Line);
		}
		else {
		    /* Skip the image: */
		    if (DGifGetCode(GifFile, &CodeSize, &CodeBlock) == GIF_ERROR) {
			PrintGifError();
			exit(-1);
		    }
		    while (CodeBlock != NULL) {
			if (DGifGetCodeNext(GifFile, &CodeBlock) == GIF_ERROR) {
			    PrintGifError();
			    exit(-1);
			}
		    }

		}
		break;
	    case EXTENSION_RECORD_TYPE:
		if (DGifGetExtension(GifFile, &ExtCode, &Extension) == GIF_ERROR) {
		    PrintGifError();
		    exit(-1);
		}
		if (!RawFlag) {
		    printf("\nExtension Record (Ext Code = %d [%c]):\n",
			   ExtCode, MAKE_PRINTABLE(ExtCode));
		    PrintExtBlock(Extension, TRUE);
		}
		while (Extension != NULL) {
		    if (DGifGetExtensionNext(GifFile, &Extension) == GIF_ERROR) {
			PrintGifError();
			exit(-1);
		    }
		    PrintExtBlock(Extension, FALSE);
		}
		break;
	    case TERMINATE_RECORD_TYPE:
		break;
	    default:		     /* Should be traps by DGifGetRecordType */
		break;
	}
    }
    while (RecordType != TERMINATE_RECORD_TYPE);

    if (DGifCloseFile(GifFile) == GIF_ERROR) {
	PrintGifError();
	exit(-1);
    }

    if (!RawFlag) printf("\nGif file terminated normally.\n");
}

/******************************************************************************
* Print the given CodeBlock - a string in pascal notation (size in first      *
* place). Save local information so printing can be performed continuously,   *
* or reset to start state if Reset. If CodeBlock is NULL, output is flushed   *
******************************************************************************/
static void PrintCodeBlock(GifFileType *GifFile, GifByteType *CodeBlock, int Reset)
{
    static int CrntPlace = 0, Print = TRUE;
    static long CodeCount = 0;
    char c;
    int i, Percent, Len;
    long NumBytes;

    if (Reset || CodeBlock == NULL) {
	if (CodeBlock == NULL) {
	    if (CrntPlace > 0) {
		if (Print) printf("\n");
		CodeCount += CrntPlace - 16;
	    }
	    if (GifFile -> IColorMap)
		NumBytes = ((((long) GifFile -> IWidth) * GifFile -> IHeight)
				* GifFile -> IBitsPerPixel) / 8;
	    else
		NumBytes = ((((long) GifFile -> IWidth) * GifFile -> IHeight)
				* GifFile -> SBitsPerPixel) / 8;
	    Percent = 100 * CodeCount / NumBytes;
	    printf("\nCompression ratio: %ld/%ld (%d%%).\n",
			CodeCount, NumBytes, Percent);
	    return;
	}
	CrntPlace = 0;
	CodeCount = 0;
	Print = TRUE;
    }

    Len = CodeBlock[0];
    for (i = 1; i <= Len; i++) {
	if (CrntPlace == 0) {
	    if (Print) printf("\n%05lxh:  ", CodeCount);
	    CodeCount += 16;
	}
#ifdef __MSDOS__
	if (kbhit() && ((c = getch()) == 'q' || c == 'Q')) Print = FALSE;
#endif /* __MSDOS__ */
	if (Print) printf(" %02xh", CodeBlock[i]);
	if (++CrntPlace >= 16) CrntPlace = 0;
    }
}

/******************************************************************************
* Print the given Extension - a string in pascal notation (size in first      *
* place). Save local information so printing can be performed continuously,   *
* or reset to start state if Reset. If Extension is NULL, output is flushed   *
******************************************************************************/
static void PrintExtBlock(GifByteType *Extension, int Reset)
{
    static int CrntPlace = 0, Print = TRUE;
    static long ExtCount = 0;
    static char HexForm[49], AsciiForm[17];
    char c;
    int i, Len;

    if (Reset || Extension == NULL) {
	if (Extension == NULL) {
	    if (CrntPlace > 0) {
		HexForm[CrntPlace * 3] = 0;
		AsciiForm[CrntPlace] = 0;
		if (Print) printf("\n%05lx: %-49s  %-17s\n",
				ExtCount, HexForm, AsciiForm);
		return;
	    }
	    else if (Print)
		printf("\n");
	}
	CrntPlace = 0;
	ExtCount = 0;
	Print = TRUE;
    }

    if (!Print) return;

    Len = Extension[0];
    for (i = 1; i <= Len; i++) {
	sprintf(&HexForm[CrntPlace * 3], " %02x", Extension[i]);
	sprintf(&AsciiForm[CrntPlace], "%c", MAKE_PRINTABLE(Extension[i]));
#ifdef __MSDOS__
	if (kbhit() && ((c = getch()) == 'q' || c == 'Q')) Print = FALSE;
#endif /* __MSDOS__ */
	if (++CrntPlace == 16) {
	    HexForm[CrntPlace * 3] = 0;
	    AsciiForm[CrntPlace] = 0;
	    if (Print) printf("\n%05lx: %-49s  %-17s",
				ExtCount, HexForm, AsciiForm);
	    ExtCount += 16;
	    CrntPlace = 0;
	}
    }
}

/******************************************************************************
* Print the given PixelBlock of length Len.				      *
* Save local information so printing can be performed continuously,           *
* or reset to start state if Reset. If PixelBlock is NULL, output is flushed  *
******************************************************************************/
static void PrintPixelBlock(GifByteType *PixelBlock, int Len, int Reset)
{
    static int CrntPlace = 0, Print = TRUE;
    static long ExtCount = 0;
    static char HexForm[49], AsciiForm[17];
    char c;
    int i;

    if (Reset || PixelBlock == NULL) {
	if (PixelBlock == NULL) {
	    if (CrntPlace > 0) {
		HexForm[CrntPlace * 3] = 0;
		AsciiForm[CrntPlace] = 0;
		if (Print) printf("\n%05lx: %-49s  %-17s\n",
				ExtCount, HexForm, AsciiForm);
	    }
	    else if (Print)
		printf("\n");
	}
	CrntPlace = 0;
	ExtCount = 0;
	Print = TRUE;
	if (PixelBlock == NULL) return;
    }

    if (!Print) return;

    for (i = 0; i < Len; i++) {
	sprintf(&HexForm[CrntPlace * 3], " %02x", PixelBlock[i]);
	sprintf(&AsciiForm[CrntPlace], "%c", MAKE_PRINTABLE(PixelBlock[i]));
#ifdef __MSDOS__
	if (kbhit() && ((c = getch()) == 'q' || c == 'Q')) Print = FALSE;
#endif /* __MSDOS__ */
	if (++CrntPlace == 16) {
	    HexForm[CrntPlace * 3] = 0;
	    AsciiForm[CrntPlace] = 0;
	    if (Print) printf("\n%05lx: %-49s  %-17s",
				ExtCount, HexForm, AsciiForm);
	    ExtCount += 16;
	    CrntPlace = 0;
	}
    }
}

/******************************************************************************
* Print the image as LZ codes (each 12bits), until EOF marker is reached.     *
******************************************************************************/
static void PrintLZCodes(GifFileType *GifFile)
{
    char c;
    int Code, Print = TRUE, CrntPlace = 0;
    long CodeCount = 0;

    do {
	if (Print && CrntPlace == 0) printf("\n%05lx:", CodeCount);
	if (DGifGetLZCodes(GifFile, &Code) == GIF_ERROR) {
	    PrintGifError();
	    exit(-1);
	}
	if (Print && Code >= 0)
	    printf(" %03x", Code);	      /* EOF Code is returned as -1. */
	CodeCount++;
	if (++CrntPlace >= 16) CrntPlace = 0;
#ifdef __MSDOS__
	if (kbhit() && ((c = getch()) == 'q' || c == 'Q')) Print = FALSE;
#endif /* __MSDOS__ */
    }
    while (Code >= 0);
}
