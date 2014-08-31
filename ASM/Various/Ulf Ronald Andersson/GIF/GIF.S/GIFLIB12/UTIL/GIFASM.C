/*****************************************************************************
*   "Gif-Lib" - Yet another gif library.				     *
*									     *
* Written by:  Gershon Elber				Ver 0.1, Jul. 1989   *
******************************************************************************
* Program to assemble/disassemble GIF files: disassembles multi image file   *
* into seperated files, or assembles few single image GIF files into one.    *
* Options:								     *
* -q : quite printing mode.						     *
* -a : assemble few files into one (default)				     *
* -d name : disassmble given GIF file into seperate files derived from name. *
* -h : on line help.							     *
******************************************************************************
* History:								     *
* 7 Jul 89 - Version 1.0 by Gershon Elber.				     *
*****************************************************************************/

#ifdef __MSDOS__
#include <stdlib.h>
#include <alloc.h>
#endif /* __MSDOS__ */

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "gif_lib.h"
#include "getarg.h"

#define PROGRAM_NAME	"GifAsm"

#ifdef __MSDOS__
extern unsigned int
    _stklen = 16384;			     /* Increase default stack size. */
#endif /* __MSDOS__ */

#ifdef SYSV
static char *VersionStr =
        "Gif library module,\t\tGershon Elber\n\
	(C) Copyright 1989 Gershon Elber, Non commercial use only.\n";
static char
    *CtrlStr = "GifAsm q%- a%- d%-OutFileName!s h%- GifFile(s)!*s";
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
	" q%- a%- d%-OutFileName!s h%- GifFile(s)!*s";
#endif /* SYSV */

static int
    AsmFlag = FALSE;

static void DoAssembly(int NumFiles, char **FileNames);
static void DoDisassembly(char *InFileName, char *OutFileName);
static void QuitGifError(GifFileType *GifFileIn, GifFileType *GifFileOut);

/******************************************************************************
* Interpret the command line and scan the given GIF file.		      *
******************************************************************************/
void main(int argc, char **argv)
{
    int	Error, NumFiles, DisasmFlag = FALSE, HelpFlag = FALSE;
    char **FileNames = NULL, *OutFileName;

    if ((Error = GAGetArgs(argc, argv, CtrlStr,
		&GifQuitePrint, &AsmFlag, &DisasmFlag, &OutFileName,
		&HelpFlag, &NumFiles, &FileNames)) != FALSE) {
	GAPrintErrMsg(Error);
	GAPrintHowTo(CtrlStr);
	exit(1);
    }

    if (HelpFlag) {
	fprintf(stderr, VersionStr);
	GAPrintHowTo(CtrlStr);
	exit(0);
    }

    if (!AsmFlag && !DisasmFlag) AsmFlag = TRUE; /* Make default - assemble. */
    if (AsmFlag && NumFiles < 2) {
	GIF_MESSAGE("At list two GIF files are required to assembly operation.");
	GAPrintHowTo(CtrlStr);
	exit(1);
    }
    if (!AsmFlag && NumFiles > 1) {
	GIF_MESSAGE("Error in command line parsing - one GIF file please.");
	GAPrintHowTo(CtrlStr);
	exit(1);
    }

    if (AsmFlag)
        DoAssembly(NumFiles, FileNames);
    else
	DoDisassembly(NumFiles == 1 ? *FileNames : NULL, OutFileName);
}

/******************************************************************************
* Perform the assembly operation - take few input files into one output.      *
******************************************************************************/
static void DoAssembly(int NumFiles, char **FileNames)
{
    int	i, ExtCode, CodeSize;
    GifRecordType RecordType;
    GifByteType *Extension, *CodeBlock;
    GifFileType *GifFileIn = NULL, *GifFileOut = NULL;

    /* Open stdout for the output file: */
    if ((GifFileOut = EGifOpenFileHandle(1)) == NULL)
	QuitGifError(GifFileIn, GifFileOut);

    /* Scan the content of the GIF file and load the image(s) in: */
    for (i = 0; i < NumFiles; i++) {
	if ((GifFileIn = DGifOpenFileName(FileNames[i])) == NULL)
	    QuitGifError(GifFileIn, GifFileOut);

	/* And dump out screen descriptor iff its first image.	*/
	if (i == 0)
	    if (EGifPutScreenDesc(GifFileOut,
		GifFileIn -> SWidth, GifFileIn -> SHeight,
		GifFileIn -> SColorResolution, GifFileIn -> SBackGroundColor,
		GifFileIn -> SBitsPerPixel, GifFileIn -> SColorMap) == GIF_ERROR)
		QuitGifError(GifFileIn, GifFileOut);

	do {
	    if (DGifGetRecordType(GifFileIn, &RecordType) == GIF_ERROR)
		QuitGifError(GifFileIn, GifFileOut);

	    switch (RecordType) {
		case IMAGE_DESC_RECORD_TYPE:
		    if (DGifGetImageDesc(GifFileIn) == GIF_ERROR)
			QuitGifError(GifFileIn, GifFileOut);
		    /* Put image descriptor to out file: */
		    if (EGifPutImageDesc(GifFileOut,
			GifFileIn -> ILeft, GifFileIn -> ITop,
			GifFileIn -> IWidth, GifFileIn -> IHeight,
			GifFileIn -> IInterlace, GifFileIn -> IBitsPerPixel,
			GifFileIn -> IColorMap) == GIF_ERROR)
			QuitGifError(GifFileIn, GifFileOut);

		    /* Now read image itself in decoded form as we dont      */
		    /* dont care what is there, and this is much faster.     */
		    if (DGifGetCode(GifFileIn, &CodeSize, &CodeBlock) == GIF_ERROR
		     || EGifPutCode(GifFileOut, CodeSize, CodeBlock) == GIF_ERROR)
			QuitGifError(GifFileIn, GifFileOut);
		    while (CodeBlock != NULL)
			if (DGifGetCodeNext(GifFileIn, &CodeBlock) == GIF_ERROR ||
			    EGifPutCodeNext(GifFileOut, CodeBlock) == GIF_ERROR)
			    QuitGifError(GifFileIn, GifFileOut);
		    break;
		case EXTENSION_RECORD_TYPE:
		    /* Skip any extension blocks in file: */
		    if (DGifGetExtension(GifFileIn, &ExtCode, &Extension)
			== GIF_ERROR)
			QuitGifError(GifFileIn, GifFileOut);
		    if (EGifPutExtension(GifFileOut, ExtCode, Extension[0],
						       Extension) == GIF_ERROR)
			QuitGifError(GifFileIn, GifFileOut);

		    /* No support to more than one extension blocks, discard.*/
		    while (Extension != NULL)
			if (DGifGetExtensionNext(GifFileIn, &Extension)
			    == GIF_ERROR)
				QuitGifError(GifFileIn, GifFileOut);
		    break;
		case TERMINATE_RECORD_TYPE:
		    break;
		default:	    /* Should be traps by DGifGetRecordType. */
		    break;
	    }
	}
	while (RecordType != TERMINATE_RECORD_TYPE);

	if (DGifCloseFile(GifFileIn) == GIF_ERROR)
	    QuitGifError(GifFileIn, GifFileOut);
    }

    if (EGifCloseFile(GifFileOut) == GIF_ERROR)
	QuitGifError(GifFileIn, GifFileOut);
}

/******************************************************************************
* Perform the disassembly operation - take one input files into few output.   *
******************************************************************************/
static void DoDisassembly(char *InFileName, char *OutFileName)
{
    int	i, ExtCode, CodeSize, FileNum = 0, FileEmpty;
    GifRecordType RecordType;
    char CrntFileName[80], *p;
    GifByteType *Extension, *CodeBlock;
    GifFileType *GifFileIn = NULL, *GifFileOut = NULL;

    /* If name has type postfix, strip it out, and make sure name is less    */
    /* or equal to 6 chars, so we will have 2 chars in name for numbers.     */
    for (i = 0; i < strlen(OutFileName);  i++)/* Make sure all is upper case.*/
	if (islower(OutFileName[i]))
	    OutFileName[i] = toupper(OutFileName[i]);

    if ((p = strrchr(OutFileName, '.')) != NULL && strlen(p) <= 4) p[0] = 0;
    if ((p = strrchr(OutFileName, '/')) != NULL ||
	(p = strrchr(OutFileName, '\\')) != NULL ||
	(p = strrchr(OutFileName, ':')) != NULL) {
	if (strlen(p) > 7) p[7] = 0;  /* p includes the '/', '\\', ':' char. */
    }
    else {
	/* Only name is given for current directory: */
	if (strlen(OutFileName) > 6) OutFileName[6] = 0;
    }

    /* Open input file: */
    if (InFileName != NULL) {
	if ((GifFileIn = DGifOpenFileName(InFileName)) == NULL)
	    QuitGifError(GifFileIn, GifFileOut);
    }
    else {
	/* Use the stdin instead: */
	if ((GifFileIn = DGifOpenFileHandle(0)) == NULL)
	    QuitGifError(GifFileIn, GifFileOut);
    }

    /* Scan the content of GIF file and dump image(s) to seperate file(s): */
    do {
	sprintf(CrntFileName, "%s%02d.gif", OutFileName, FileNum++);
	if ((GifFileOut = EGifOpenFileName(CrntFileName, TRUE)) == NULL)
	    QuitGifError(GifFileIn, GifFileOut);
	FileEmpty = TRUE;

	/* And dump out its exactly same screen information: */
	if (EGifPutScreenDesc(GifFileOut,
	    GifFileIn -> SWidth, GifFileIn -> SHeight,
	    GifFileIn -> SColorResolution, GifFileIn -> SBackGroundColor,
	    GifFileIn -> SBitsPerPixel, GifFileIn -> SColorMap) == GIF_ERROR)
	    QuitGifError(GifFileIn, GifFileOut);

	do {
	    if (DGifGetRecordType(GifFileIn, &RecordType) == GIF_ERROR)
		QuitGifError(GifFileIn, GifFileOut);

	    switch (RecordType) {
		case IMAGE_DESC_RECORD_TYPE:
		    FileEmpty = FALSE;
		    if (DGifGetImageDesc(GifFileIn) == GIF_ERROR)
			QuitGifError(GifFileIn, GifFileOut);
		    /* Put same image descriptor to out file: */
		    if (EGifPutImageDesc(GifFileOut,
			GifFileIn -> ILeft, GifFileIn -> ITop,
			GifFileIn -> IWidth, GifFileIn -> IHeight,
			GifFileIn -> IInterlace, GifFileIn -> IBitsPerPixel,
			GifFileIn -> IColorMap) == GIF_ERROR)
			QuitGifError(GifFileIn, GifFileOut);

		    /* Now read image itself in decoded form as we dont      */
		    /* really care what is there, and this is much faster.   */
		    if (DGifGetCode(GifFileIn, &CodeSize, &CodeBlock) == GIF_ERROR
		     || EGifPutCode(GifFileOut, CodeSize, CodeBlock) == GIF_ERROR)
			QuitGifError(GifFileIn, GifFileOut);
		    while (CodeBlock != NULL)
			if (DGifGetCodeNext(GifFileIn, &CodeBlock) == GIF_ERROR ||
			    EGifPutCodeNext(GifFileOut, CodeBlock) == GIF_ERROR)
			QuitGifError(GifFileIn, GifFileOut);
		    break;
		case EXTENSION_RECORD_TYPE:
		    FileEmpty = FALSE;
		    /* Skip any extension blocks in file: */
		    if (DGifGetExtension(GifFileIn, &ExtCode, &Extension)
			== GIF_ERROR)
			QuitGifError(GifFileIn, GifFileOut);
		    if (EGifPutExtension(GifFileOut, ExtCode, Extension[0],
							Extension) == GIF_ERROR)
			QuitGifError(GifFileIn, GifFileOut);

		    /* No support to more than one extension blocks, discard.*/
		    while (Extension != NULL)
			if (DGifGetExtensionNext(GifFileIn, &Extension)
			    == GIF_ERROR)
			    QuitGifError(GifFileIn, GifFileOut);
		    break;
		case TERMINATE_RECORD_TYPE:
		    break;
		default:	    /* Should be traps by DGifGetRecordType. */
		    break;
	    }
	}
	while (RecordType != IMAGE_DESC_RECORD_TYPE &&
	       RecordType != TERMINATE_RECORD_TYPE);

	if (EGifCloseFile(GifFileOut) == GIF_ERROR)
	    QuitGifError(GifFileIn, GifFileOut);
	if (FileEmpty) {
	    /* Might happen on last file - delete it if so: */
	    unlink(CrntFileName);
	}
   }
    while (RecordType != TERMINATE_RECORD_TYPE);

    if (DGifCloseFile(GifFileIn) == GIF_ERROR)
	QuitGifError(GifFileIn, GifFileOut);
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
