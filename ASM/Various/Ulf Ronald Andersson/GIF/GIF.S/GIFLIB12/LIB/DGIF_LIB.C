/******************************************************************************
*   "Gif-Lib" - Yet another gif library.				      *
*									      *
* Written by:  Gershon Elber			IBM PC Ver 1.1,	Aug. 1990     *
*******************************************************************************
* The kernel of the GIF Decoding process can be found here.		      *
*******************************************************************************
* History:								      *
* 16 Jun 89 - Version 1.0 by Gershon Elber.				      *
*  3 Sep 90 - Version 1.1 by Gershon Elber (Support for Gif89, Unique names). *
******************************************************************************/


#ifdef __MSDOS__
#include <io.h>
#include <alloc.h>
#include <stdlib.h>
#include <sys\stat.h>
#else
#include <sys/types.h>
#include <sys/stat.h>
#endif /* __MSDOS__ */

#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include "gif_lib.h"
#include "gif_hash.h"

#define PROGRAM_NAME	"GIF_LIBRARY"

#define COMMENT_EXT_FUNC_CODE	0xfe /* Extension function code for comment. */
#define GIF_STAMP	"GIFVER"	 /* First chars in file - GIF stamp. */
#define GIF_STAMP_LEN	sizeof(GIF_STAMP) - 1
#define GIF_VERSION_POS	3		/* Version first character in stamp. */

#define LZ_MAX_CODE	4095		/* Biggest code possible in 12 bits. */
#define LZ_BITS		12

#define FILE_STATE_READ		0x01/* 1 write, 0 read - EGIF_LIB compatible.*/

#define FLUSH_OUTPUT		4096    /* Impossible code, to signal flush. */
#define FIRST_CODE		4097    /* Impossible code, to signal first. */
#define NO_SUCH_CODE		4098    /* Impossible code, to signal empty. */

#define IS_READABLE(Private)	(!(Private -> FileState & FILE_STATE_READ))

typedef struct GifFilePrivateType {
    int FileState,
	FileHandle,			     /* Where all this data goes to! */
	BitsPerPixel,	    /* Bits per pixel (Codes uses at list this + 1). */
	ClearCode,				       /* The CLEAR LZ code. */
	EOFCode,				         /* The EOF LZ code. */
	RunningCode,		    /* The next code algorithm can generate. */
	RunningBits,/* The number of bits required to represent RunningCode. */
	MaxCode1,  /* 1 bigger than max. possible code, in RunningBits bits. */
	LastCode,		        /* The code before the current code. */
	CrntCode,				  /* Current algorithm code. */
	StackPtr,		         /* For character stack (see below). */
	CrntShiftState;		        /* Number of bits in CrntShiftDWord. */
    unsigned long CrntShiftDWord,     /* For bytes decomposition into codes. */
		  PixelCount;		       /* Number of pixels in image. */
    FILE *File;						  /* File as stream. */
    GifByteType Buf[256];	       /* Compressed input is buffered here. */
    GifByteType Stack[LZ_MAX_CODE];	 /* Decoded pixels are stacked here. */
    GifByteType Suffix[LZ_MAX_CODE+1];	       /* So we can trace the codes. */
    unsigned int Prefix[LZ_MAX_CODE+1];
} GifFilePrivateType;

#ifdef SYSV
static char *VersionStr =
        "Gif library module,\t\tGershon Elber\n\
	(C) Copyright 1989 Gershon Elber, Non commercial use only.\n";
#else
static char *VersionStr =
	PROGRAM_NAME
	"	IBMPC "
	GIF_LIB_VERSION
	"	Gershon Elber,	"
	__DATE__ ",   " __TIME__ "\n"
	"(C) Copyright 1989 Gershon Elber, Non commercial use only.\n";
#endif /* SYSV */

extern int _GifError;

static int DGifGetWord(FILE *File, int *Word);
static int DGifSetupDecompress(GifFileType *GifFile);
static int DGifDecompressLine(GifFileType *GifFile, GifPixelType *Line,
								int LineLen);
static int DGifGetPrefixChar(unsigned int *Prefix, int Code, int ClearCode);
static int DGifDecompressInput(GifFilePrivateType *Private, int *Code);
static int DGifBufferedInput(FILE *File, GifByteType *Buf,
						     GifByteType *NextByte);

/******************************************************************************
*   Open a new gif file for read, given by its name.			      *
*   Returns GifFileType pointer dynamically allocated which serves as the gif *
* info record. _GifError is cleared if succesfull.			      *
******************************************************************************/
GifFileType *DGifOpenFileName(char *FileName)
{
    int FileHandle;

    if ((FileHandle = open(FileName, O_RDONLY
#ifdef __MSDOS__
			           | O_BINARY
#endif /* __MSDOS__ */
			                     )) == -1) {
	_GifError = D_GIF_ERR_OPEN_FAILED;
	return NULL;
    }

    return DGifOpenFileHandle(FileHandle);
}

/******************************************************************************
*   Update a new gif file, given its file handle.			      *
*   Returns GifFileType pointer dynamically allocated which serves as the gif *
* info record. _GifError is cleared if succesfull.			      *
******************************************************************************/
GifFileType *DGifOpenFileHandle(int FileHandle)
{
    char Buf[GIF_STAMP_LEN+1];
    GifFileType *GifFile;
    GifFilePrivateType *Private;
    FILE *f;

#ifdef __MSDOS__
    setmode(FileHandle, O_BINARY);	  /* Make sure it is in binary mode. */
    f = fdopen(FileHandle, "rb");		   /* Make it into a stream: */
    setvbuf(f, NULL, _IOFBF, GIF_FILE_BUFFER_SIZE);/* And inc. stream buffer.*/
#else
    f = fdopen(FileHandle, "r");		   /* Make it into a stream: */
#endif /* __MSDOS__ */

    if ((GifFile = (GifFileType *) malloc(sizeof(GifFileType))) == NULL) {
	_GifError = D_GIF_ERR_NOT_ENOUGH_MEM;
	return NULL;
    }

    if ((Private = (GifFilePrivateType *) malloc(sizeof(GifFilePrivateType)))
	== NULL) {
	_GifError = D_GIF_ERR_NOT_ENOUGH_MEM;
	free((char *) GifFile);
	return NULL;
    }
    GifFile -> Private = (VoidPtr) Private;
    GifFile -> SColorMap = GifFile -> IColorMap = NULL;
    Private -> FileHandle = FileHandle;
    Private -> File = f;
    Private -> FileState = 0;   /* Make sure bit 0 = 0 (File open for read). */

    /* Lets see if this is GIF file: */
    if (fread(Buf, 1, GIF_STAMP_LEN, Private -> File) != GIF_STAMP_LEN) {
	_GifError = D_GIF_ERR_READ_FAILED;
	free((char *) Private);
	free((char *) GifFile);
	return NULL;
    }

    /* The GIF Version number is ignored at this time. Maybe we should do    */
    /* something more useful with it.					     */
    Buf[GIF_STAMP_LEN] = 0;
    if (strncmp(GIF_STAMP, Buf, GIF_VERSION_POS) != 0) {
	_GifError = D_GIF_ERR_NOT_GIF_FILE;
	free((char *) Private);
	free((char *) GifFile);
	return NULL;
    }

    if (DGifGetScreenDesc(GifFile) == GIF_ERROR) {
	free((char *) Private);
	free((char *) GifFile);
	return NULL;
    }

    _GifError = 0;

    return GifFile;
}

/******************************************************************************
*   This routine should be called before any other DGif calls. Note that      *
* this routine is called automatically from DGif file open routines.	      *
******************************************************************************/
int DGifGetScreenDesc(GifFileType *GifFile)
{
    int Size, i;
    GifByteType Buf[3];
    GifFilePrivateType *Private = (GifFilePrivateType *) GifFile -> Private;

    if (!IS_READABLE(Private)) {
	/* This file was NOT open for reading: */
	_GifError = D_GIF_ERR_NOT_READABLE;
	return GIF_ERROR;
    }

    /* Put the screen descriptor into the file: */
    if (DGifGetWord(Private -> File, &GifFile -> SWidth) == GIF_ERROR ||
	DGifGetWord(Private -> File, &GifFile -> SHeight) == GIF_ERROR)
	return GIF_ERROR;

    if (fread(Buf, 1, 3, Private -> File) != 3) {
	_GifError = D_GIF_ERR_READ_FAILED;
	return GIF_ERROR;
    }
    GifFile -> SColorResolution = (((Buf[0] & 0x70) + 1) >> 4) + 1;
    GifFile -> SBitsPerPixel = (Buf[0] & 0x07) + 1;
    GifFile -> SBackGroundColor = Buf[1];
    if (Buf[0] & 0x80) {		     /* Do we have global color map? */
	Size = (1 << GifFile -> SBitsPerPixel);
	GifFile -> SColorMap =
	    (GifColorType *) malloc(sizeof(GifColorType) * Size);
	for (i = 0; i < Size; i++) {		/* Get the global color map: */
	    if (fread(Buf, 1, 3, Private -> File) != 3) {
		_GifError = D_GIF_ERR_READ_FAILED;
		return GIF_ERROR;
	    }
	    GifFile -> SColorMap[i].Red = Buf[0];
	    GifFile -> SColorMap[i].Green = Buf[1];
	    GifFile -> SColorMap[i].Blue = Buf[2];
	}
    }

    return GIF_OK;
}

/******************************************************************************
*   This routine should be called before any attemp to read an image.         *
******************************************************************************/
int DGifGetRecordType(GifFileType *GifFile, GifRecordType *Type)
{
    GifByteType Buf;
    GifFilePrivateType *Private = (GifFilePrivateType *) GifFile -> Private;

    if (!IS_READABLE(Private)) {
	/* This file was NOT open for reading: */
	_GifError = D_GIF_ERR_NOT_READABLE;
	return GIF_ERROR;
    }

    if (fread(&Buf, 1, 1, Private -> File) != 1) {
	_GifError = D_GIF_ERR_READ_FAILED;
	return GIF_ERROR;
    }

    switch (Buf) {
	case ',':
	    *Type = IMAGE_DESC_RECORD_TYPE;
	    break;
	case '!':
	    *Type = EXTENSION_RECORD_TYPE;
	    break;
	case ';':
	    *Type = TERMINATE_RECORD_TYPE;
	    break;
	default:
	    *Type = UNDEFINED_RECORD_TYPE;
	    _GifError = D_GIF_ERR_WRONG_RECORD;
	    return GIF_ERROR;
    }

    return GIF_OK;
}

/******************************************************************************
*   This routine should be called before any attemp to read an image.         *
*   Note it is assumed the Image desc. header (',') has been read.	      *
******************************************************************************/
int DGifGetImageDesc(GifFileType *GifFile)
{
    int Size, i;
    GifByteType Buf[3];
    GifFilePrivateType *Private = (GifFilePrivateType *) GifFile -> Private;

    if (!IS_READABLE(Private)) {
	/* This file was NOT open for reading: */
	_GifError = D_GIF_ERR_NOT_READABLE;
	return GIF_ERROR;
    }

    if (DGifGetWord(Private -> File, &GifFile -> ILeft) == GIF_ERROR ||
	DGifGetWord(Private -> File, &GifFile -> ITop) == GIF_ERROR ||
	DGifGetWord(Private -> File, &GifFile -> IWidth) == GIF_ERROR ||
	DGifGetWord(Private -> File, &GifFile -> IHeight) == GIF_ERROR)
	return GIF_ERROR;
    if (fread(Buf, 1, 1, Private -> File) != 1) {
	_GifError = D_GIF_ERR_READ_FAILED;
	return GIF_ERROR;
    }
    GifFile -> IBitsPerPixel = (Buf[0] & 0x07) + 1;
    GifFile -> IInterlace = (Buf[0] & 0x40);
    if (Buf[0] & 0x80) {	    /* Does this image have local color map? */
	Size = (1 << GifFile -> IBitsPerPixel);
	if (GifFile -> IColorMap) free((char *) GifFile -> IColorMap);
	GifFile -> IColorMap =
	    (GifColorType *) malloc(sizeof(GifColorType) * Size);
	for (i = 0; i < Size; i++) {	   /* Get the image local color map: */
	    if (fread(Buf, 1, 3, Private -> File) != 3) {
		_GifError = D_GIF_ERR_READ_FAILED;
		return GIF_ERROR;
	    }
	    GifFile -> IColorMap[i].Red = Buf[0];
	    GifFile -> IColorMap[i].Green = Buf[1];
	    GifFile -> IColorMap[i].Blue = Buf[2];
	}
    }

    Private -> PixelCount = (long) GifFile -> IWidth *
			    (long) GifFile -> IHeight;

    DGifSetupDecompress(GifFile);  /* Reset decompress algorithm parameters. */

    return GIF_OK;
}

/******************************************************************************
*  Get one full scanned line (Line) of length LineLen from GIF file.	      *
******************************************************************************/
int DGifGetLine(GifFileType *GifFile, GifPixelType *Line, int LineLen)
{
    GifByteType *Dummy;
    GifFilePrivateType *Private = (GifFilePrivateType *) GifFile -> Private;

    if (!IS_READABLE(Private)) {
	/* This file was NOT open for reading: */
	_GifError = D_GIF_ERR_NOT_READABLE;
	return GIF_ERROR;
    }

    if (!LineLen) LineLen = GifFile -> IWidth;

#ifdef __MSDOS__
    if ((Private -> PixelCount -= LineLen) > 0xffff0000UL) {
#else
    if ((Private -> PixelCount -= LineLen) > 0xffff0000) {
#endif /* __MSDOS__ */
	_GifError = D_GIF_ERR_DATA_TOO_BIG;
	return GIF_ERROR;
    }

    if (DGifDecompressLine(GifFile, Line, LineLen) == GIF_OK) {
	if (Private -> PixelCount == 0) {
	    /* We probably would not be called any more, so lets clean 	     */
	    /* everything before we return: need to flush out all rest of    */
	    /* image until empty block (size 0) detected. We use GetCodeNext.*/
	    do if (DGifGetCodeNext(GifFile, &Dummy) == GIF_ERROR)
		return GIF_ERROR;
	    while (Dummy != NULL);
	}
	return GIF_OK;
    }
    else
	return GIF_ERROR;
}

/******************************************************************************
* Put one pixel (Pixel) into GIF file.					      *
******************************************************************************/
int DGifGetPixel(GifFileType *GifFile, GifPixelType Pixel)
{
    GifByteType *Dummy;
    GifFilePrivateType *Private = (GifFilePrivateType *) GifFile -> Private;

    if (!IS_READABLE(Private)) {
	/* This file was NOT open for reading: */
	_GifError = D_GIF_ERR_NOT_READABLE;
	return GIF_ERROR;
    }

#ifdef __MSDOS__
    if (--Private -> PixelCount > 0xffff0000UL)
#else
    if (--Private -> PixelCount > 0xffff0000)
#endif /* __MSDOS__ */
    {
	_GifError = D_GIF_ERR_DATA_TOO_BIG;
	return GIF_ERROR;
    }

    if (DGifDecompressLine(GifFile, &Pixel, 1) == GIF_OK) {
	if (Private -> PixelCount == 0) {
	    /* We probably would not be called any more, so lets clean 	     */
	    /* everything before we return: need to flush out all rest of    */
	    /* image until empty block (size 0) detected. We use GetCodeNext.*/
	    do if (DGifGetCodeNext(GifFile, &Dummy) == GIF_ERROR)
		return GIF_ERROR;
	    while (Dummy != NULL);
	}
	return GIF_OK;
    }
    else
	return GIF_ERROR;
}

/******************************************************************************
*   Get an extension block (see GIF manual) from gif file. This routine only  *
* returns the first data block, and DGifGetExtensionNext shouldbe called      *
* after this one until NULL extension is returned.			      *
*   The Extension should NOT be freed by the user (not dynamically allocated).*
*   Note it is assumed the Extension desc. header ('!') has been read.	      *
******************************************************************************/
int DGifGetExtension(GifFileType *GifFile, int *ExtCode,
						    GifByteType **Extension)
{
    GifByteType Buf;
    GifFilePrivateType *Private = (GifFilePrivateType *) GifFile -> Private;

    if (!IS_READABLE(Private)) {
	/* This file was NOT open for reading: */
	_GifError = D_GIF_ERR_NOT_READABLE;
	return GIF_ERROR;
    }

    if (fread(&Buf, 1, 1, Private -> File) != 1) {
	_GifError = D_GIF_ERR_READ_FAILED;
	return GIF_ERROR;
    }
    *ExtCode = Buf;

    return DGifGetExtensionNext(GifFile, Extension);
}

/******************************************************************************
*   Get a following extension block (see GIF manual) from gif file. This      *
* routine sould be called until NULL Extension is returned.		      *
*   The Extension should NOT be freed by the user (not dynamically allocated).*
******************************************************************************/
int DGifGetExtensionNext(GifFileType *GifFile, GifByteType **Extension)
{
    GifByteType Buf;
    GifFilePrivateType *Private = (GifFilePrivateType *) GifFile -> Private;

    if (fread(&Buf, 1, 1, Private -> File) != 1) {
	_GifError = D_GIF_ERR_READ_FAILED;
	return GIF_ERROR;
    }
    if (Buf > 0) {
	*Extension = Private -> Buf;           /* Use private unused buffer. */
	(*Extension)[0] = Buf;  /* Pascal strings notation (pos. 0 is len.). */
	if (fread(&((*Extension)[1]), 1, Buf, Private -> File) != Buf) {
	    _GifError = D_GIF_ERR_READ_FAILED;
	    return GIF_ERROR;
	}
    }
    else
	*Extension = NULL;

    return GIF_OK;
}

/******************************************************************************
*   This routine should be called last, to close GIF file.		      *
******************************************************************************/
int DGifCloseFile(GifFileType *GifFile)
{
    GifFilePrivateType *Private;
    FILE *File;

    if (GifFile == NULL) return GIF_ERROR;

    Private = (GifFilePrivateType *) GifFile -> Private;

    if (!IS_READABLE(Private)) {
	/* This file was NOT open for reading: */
	_GifError = D_GIF_ERR_NOT_READABLE;
	return GIF_ERROR;
    }

    File = Private -> File;

    if (GifFile -> IColorMap) free((char *) GifFile -> IColorMap);
    if (GifFile -> SColorMap) free((char *) GifFile -> SColorMap);
    if (Private) free((char *) Private);
    free(GifFile);

    if (fclose(File) != 0) {
	_GifError = D_GIF_ERR_CLOSE_FAILED;
	return GIF_ERROR;
    }
    return GIF_OK;
}

/******************************************************************************
*   Get 2 bytes (word) from the given file:				      *
******************************************************************************/
static int DGifGetWord(FILE *File, int *Word)
{
    unsigned char c[2];

    if (fread(c, 1, 2, File) != 2) {
	_GifError = D_GIF_ERR_READ_FAILED;
	return GIF_ERROR;
    }

    *Word = (((unsigned int) c[1]) << 8) + c[0];
    return GIF_OK;
}

/******************************************************************************
*   Get the image code in compressed form. his routine can be called if the   *
* information needed to be piped out as is. Obviously this is much faster     *
* than decoding and encoding again. This routine should be followed by calls  *
* to DGifGetCodeNext, until NULL block is returned.			      *
*   The block should NOT be freed by the user (not dynamically allocated).    *
******************************************************************************/
int DGifGetCode(GifFileType *GifFile, int *CodeSize, GifByteType **CodeBlock)
{
    GifFilePrivateType *Private = (GifFilePrivateType *) GifFile -> Private;

    if (!IS_READABLE(Private)) {
	/* This file was NOT open for reading: */
	_GifError = D_GIF_ERR_NOT_READABLE;
	return GIF_ERROR;
    }

    *CodeSize = Private -> BitsPerPixel;

    return DGifGetCodeNext(GifFile, CodeBlock);
}

/******************************************************************************
*   Continue to get the image code in compressed form. This routine should be *
* called until NULL block is returned.					      *
*   The block should NOT be freed by the user (not dynamically allocated).    *
******************************************************************************/
int DGifGetCodeNext(GifFileType *GifFile, GifByteType **CodeBlock)
{
    GifByteType Buf;
    GifFilePrivateType *Private = (GifFilePrivateType *) GifFile -> Private;

    if (fread(&Buf, 1, 1, Private -> File) != 1) {
	_GifError = D_GIF_ERR_READ_FAILED;
	return GIF_ERROR;
    }

    if (Buf > 0) {
	*CodeBlock = Private -> Buf;	       /* Use private unused buffer. */
	(*CodeBlock)[0] = Buf;  /* Pascal strings notation (pos. 0 is len.). */
	if (fread(&((*CodeBlock)[1]), 1, Buf, Private -> File) != Buf) {
	    _GifError = D_GIF_ERR_READ_FAILED;
	    return GIF_ERROR;
	}
    }
    else {
	*CodeBlock = NULL;
	Private -> Buf[0] = 0;		   /* Make sure the buffer is empty! */
	Private -> PixelCount = 0;   /* And local info. indicate image read. */
    }

    return GIF_OK;
}

/******************************************************************************
*   Setup the LZ decompression for this image:				      *
******************************************************************************/
static int DGifSetupDecompress(GifFileType *GifFile)
{
    int i, BitsPerPixel;
    GifByteType CodeSize;
    unsigned int *Prefix;
    GifFilePrivateType *Private = (GifFilePrivateType *) GifFile -> Private;

    fread(&CodeSize, 1, 1, Private -> File);    /* Read Code size from file. */
    BitsPerPixel = CodeSize;

    Private -> Buf[0] = 0;			      /* Input Buffer empty. */
    Private -> BitsPerPixel = BitsPerPixel;
    Private -> ClearCode = (1 << BitsPerPixel);
    Private -> EOFCode = Private -> ClearCode + 1;
    Private -> RunningCode = Private -> EOFCode + 1;
    Private -> RunningBits = BitsPerPixel + 1;	 /* Number of bits per code. */
    Private -> MaxCode1 = 1 << Private -> RunningBits;     /* Max. code + 1. */
    Private -> StackPtr = 0;		    /* No pixels on the pixel stack. */
    Private -> LastCode = NO_SUCH_CODE;
    Private -> CrntShiftState = 0;	/* No information in CrntShiftDWord. */
    Private -> CrntShiftDWord = 0;

    Prefix = Private -> Prefix;
    for (i = 0; i <= LZ_MAX_CODE; i++) Prefix[i] = NO_SUCH_CODE;

    return GIF_OK;
}

/******************************************************************************
*   The LZ decompression routine:					      *
*   This version decompress the given gif file into Line of length LineLen.   *
*   This routine can be called few times (one per scan line, for example), in *
* order the complete the whole image.					      *
******************************************************************************/
static int DGifDecompressLine(GifFileType *GifFile, GifPixelType *Line,
								int LineLen)
{
    int i = 0, j, CrntCode, EOFCode, ClearCode, CrntPrefix, LastCode, StackPtr;
    GifByteType *Stack, *Suffix;
    unsigned int *Prefix;
    GifFilePrivateType *Private = (GifFilePrivateType *) GifFile -> Private;

    StackPtr = Private -> StackPtr;
    Prefix = Private -> Prefix;
    Suffix = Private -> Suffix;
    Stack = Private -> Stack;
    EOFCode = Private -> EOFCode;
    ClearCode = Private -> ClearCode;
    LastCode = Private -> LastCode;

    if (StackPtr != 0) {
	/* Let pop the stack off before continueing to read the gif file: */
	while (StackPtr != 0 && i < LineLen) Line[i++] = Stack[--StackPtr];
    }

    while (i < LineLen) {			    /* Decode LineLen items. */
	if (DGifDecompressInput(Private, &CrntCode) == GIF_ERROR)
    	    return GIF_ERROR;

	if (CrntCode == EOFCode) {
	    /* Note however that usually we will not be here as we will stop */
	    /* decoding as soon as we got all the pixel, or EOF code will    */
	    /* not be read at all, and DGifGetLine/Pixel clean everything.   */
	    if (i != LineLen - 1 || Private -> PixelCount != 0) {
		_GifError = D_GIF_ERR_EOF_TOO_SOON;
		return GIF_ERROR;
	    }
	    i++;
	}
	else if (CrntCode == ClearCode) {
	    /* We need to start over again: */
	    for (j = 0; j <= LZ_MAX_CODE; j++) Prefix[j] = NO_SUCH_CODE;
	    Private -> RunningCode = Private -> EOFCode + 1;
	    Private -> RunningBits = Private -> BitsPerPixel + 1;
	    Private -> MaxCode1 = 1 << Private -> RunningBits;
	    LastCode = Private -> LastCode = NO_SUCH_CODE;
	}
	else {
	    /* Its regular code - if in pixel range simply add it to output  */
	    /* stream, otherwise trace to codes linked list until the prefix */
	    /* is in pixel range:					     */
	    if (CrntCode < ClearCode) {
		/* This is simple - its pixel scalar, so add it to output:   */
		Line[i++] = CrntCode;
	    }
	    else {
		/* Its a code to needed to be traced: trace the linked list  */
		/* until the prefix is a pixel, while pushing the suffix     */
		/* pixels on our stack. If we done, pop the stack in reverse */
		/* (thats what stack is good for!) order to output.	     */
		if (Prefix[CrntCode] == NO_SUCH_CODE) {
		    /* Only allowed if CrntCode is exactly the running code: */
		    /* In that case CrntCode = XXXCode, CrntCode or the	     */
		    /* prefix code is last code and the suffix char is	     */
		    /* exactly the prefix of last code!			     */
		    if (CrntCode == Private -> RunningCode - 2) {
			CrntPrefix = LastCode;
			Suffix[Private -> RunningCode - 2] =
			Stack[StackPtr++] = DGifGetPrefixChar(Prefix,
							LastCode, ClearCode);
		    }
		    else {
			_GifError = D_GIF_ERR_IMAGE_DEFECT;
			return GIF_ERROR;
		    }
		}
		else
		    CrntPrefix = CrntCode;

		/* Now (if image is O.K.) we should not get an NO_SUCH_CODE  */
		/* During the trace. As we might loop forever, in case of    */
		/* defective image, we count the number of loops we trace    */
		/* and stop if we got LZ_MAX_CODE. obviously we can not      */
		/* loop more than that.					     */
		j = 0;
		while (j++ <= LZ_MAX_CODE &&
		       CrntPrefix > ClearCode &&
		       CrntPrefix <= LZ_MAX_CODE) {
		    Stack[StackPtr++] = Suffix[CrntPrefix];
		    CrntPrefix = Prefix[CrntPrefix];
		}
		if (j >= LZ_MAX_CODE || CrntPrefix > LZ_MAX_CODE) {
		    _GifError = D_GIF_ERR_IMAGE_DEFECT;
		    return GIF_ERROR;
		}
		/* Push the last character on stack: */
		Stack[StackPtr++] = CrntPrefix;

		/* Now lets pop all the stack into output: */
		while (StackPtr != 0 && i < LineLen)
		    Line[i++] = Stack[--StackPtr];
	    }
	    if (LastCode != NO_SUCH_CODE) {
		Prefix[Private -> RunningCode - 2] = LastCode;

		if (CrntCode == Private -> RunningCode - 2) {
		    /* Only allowed if CrntCode is exactly the running code: */
		    /* In that case CrntCode = XXXCode, CrntCode or the	     */
		    /* prefix code is last code and the suffix char is	     */
		    /* exactly the prefix of last code!			     */
		    Suffix[Private -> RunningCode - 2] =
			DGifGetPrefixChar(Prefix, LastCode, ClearCode);
		}
		else {
		    Suffix[Private -> RunningCode - 2] =
			DGifGetPrefixChar(Prefix, CrntCode, ClearCode);
		}
	    }
	    LastCode = CrntCode;
	}
    }

    Private -> LastCode = LastCode;
    Private -> StackPtr = StackPtr;

    return GIF_OK;
}

/******************************************************************************
* Routine to trace the Prefixes linked list until we get a prefix which is    *
* not code, but a pixel value (less than ClearCode). Returns that pixel value.*
* If image is defective, we might loop here forever, so we limit the loops to *
* the maximum possible if image O.k. - LZ_MAX_CODE times.		      *
******************************************************************************/
static int DGifGetPrefixChar(unsigned int *Prefix, int Code, int ClearCode)
{
    int i = 0;

    while (Code > ClearCode && i++ <= LZ_MAX_CODE) Code = Prefix[Code];
    return Code;
}

/******************************************************************************
*   Interface for accessing the LZ codes directly. Set Code to the real code  *
* (12bits), or to -1 if EOF code is returned.				      *
******************************************************************************/
int DGifGetLZCodes(GifFileType *GifFile, int *Code)
{
    GifByteType *CodeBlock;
    GifFilePrivateType *Private = (GifFilePrivateType *) GifFile -> Private;

    if (!IS_READABLE(Private)) {
	/* This file was NOT open for reading: */
	_GifError = D_GIF_ERR_NOT_READABLE;
	return GIF_ERROR;
    }

    if (DGifDecompressInput(Private, Code) == GIF_ERROR)
	return GIF_ERROR;

    if (*Code == Private -> EOFCode) {
	/* Skip rest of codes (hopefully only NULL terminating block): */
	do if (DGifGetCodeNext(GifFile, &CodeBlock) == GIF_ERROR)
    	    return GIF_ERROR;
	while (CodeBlock != NULL);

	*Code = -1;
    }
    else if (*Code == Private -> ClearCode) {
	/* We need to start over again: */
	Private -> RunningCode = Private -> EOFCode + 1;
	Private -> RunningBits = Private -> BitsPerPixel + 1;
	Private -> MaxCode1 = 1 << Private -> RunningBits;
    }

    return GIF_OK;
}

/******************************************************************************
*   The LZ decompression input routine:					      *
*   This routine is responsable for the decompression of the bit stream from  *
* 8 bits (bytes) packets, into the real codes.				      *
*   Returns GIF_OK if read succesfully.					      *
******************************************************************************/
static int DGifDecompressInput(GifFilePrivateType *Private, int *Code)
{
    GifByteType NextByte;
    static unsigned int CodeMasks[] = {
	0x0000, 0x0001, 0x0003, 0x0007,
	0x000f, 0x001f, 0x003f, 0x007f,
	0x00ff, 0x01ff, 0x03ff, 0x07ff,
	0x0fff
    };

    while (Private -> CrntShiftState < Private -> RunningBits) {
	/* Needs to get more bytes from input stream for next code: */
	if (DGifBufferedInput(Private -> File, Private -> Buf, &NextByte)
	    == GIF_ERROR) {
	    return GIF_ERROR;
	}
	Private -> CrntShiftDWord |=
		((unsigned long) NextByte) << Private -> CrntShiftState;
	Private -> CrntShiftState += 8;
    }
    *Code = Private -> CrntShiftDWord & CodeMasks[Private -> RunningBits];

    Private -> CrntShiftDWord >>= Private -> RunningBits;
    Private -> CrntShiftState -= Private -> RunningBits;

    /* If code cannt fit into RunningBits bits, must raise its size. Note */
    /* however that codes above 4095 are used for special signaling.      */
    if (++Private -> RunningCode > Private -> MaxCode1 &&
	Private -> RunningBits < LZ_BITS) {
	Private -> MaxCode1 <<= 1;
	Private -> RunningBits++;
    }
    return GIF_OK;
}

/******************************************************************************
*   This routines read one gif data block at a time and buffers it internally *
* so that the decompression routine could access it.			      *
*   The routine returns the next byte from its internal buffer (or read next  *
* block in if buffer empty) and returns GIF_OK if succesful.		      *
******************************************************************************/
static int DGifBufferedInput(FILE *File, GifByteType *Buf,
						      GifByteType *NextByte)
{
    if (Buf[0] == 0) {
	/* Needs to read the next buffer - this one is empty: */
	if (fread(Buf, 1, 1, File) != 1)
	{
	    _GifError = D_GIF_ERR_READ_FAILED;
	    return GIF_ERROR;
	}
	if (fread(&Buf[1], 1, Buf[0], File) != Buf[0])
	{
	    _GifError = D_GIF_ERR_READ_FAILED;
	    return GIF_ERROR;
	}
	*NextByte = Buf[1];
	Buf[1] = 2;	   /* We use now the second place as last char read! */
	Buf[0]--;
    }
    else {
	*NextByte = Buf[Buf[1]++];
	Buf[0]--;
    }

    return GIF_OK;
}
