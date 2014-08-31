/******************************************************************************
* In order to make life a little bit easier when using the GIF file format,   *
* this library was written, and which does all the dirty work...	      *
*									      *
*					Written by Gershon Elber,  Jun. 1989  *
*******************************************************************************
* History:								      *
* 14 Jun 89 - Version 1.0 by Gershon Elber.				      *
*  3 Sep 90 - Version 1.1 by Gershon Elber (Support for Gif89, Unique names). *
******************************************************************************/

#ifndef GIF_LIB_H
#define GIF_LIB_H

#define GIF_LIB_VERSION	" Version 1.2, "

#define	GIF_ERROR	0
#define GIF_OK		1

#ifndef TRUE
#define TRUE		1
#define FALSE		0
#endif

#define GIF_FILE_BUFFER_SIZE 16384  /* Files uses bigger buffers than usual. */

typedef	int		GifBooleanType;
typedef	unsigned char	GifPixelType;
typedef unsigned char *	GifRowType;
typedef unsigned char	GifByteType;

#define GIF_MESSAGE(Msg) fprintf(stderr, "\n%s: %s\n", PROGRAM_NAME, Msg)
#define GIF_EXIT(Msg)	{ GIF_MESSAGE(Msg); exit(-3); }

#ifdef SYSV
#define VoidPtr char *
#else
#define VoidPtr void *
#endif /* SYSV */

typedef struct GifColorType {
    GifByteType Red, Green, Blue;
} GifColorType;

/* Note entries prefixed with S are of Screen information, while entries     */
/* prefixed with I are of the current defined Image.			     */
typedef struct GifFileType {
    int SWidth, SHeight,			       /* Screen dimensions. */
	SColorResolution, SBitsPerPixel, /* How many colors can we generate? */
	SBackGroundColor,		/* I hope you understand this one... */
	ILeft, ITop, IWidth, IHeight,		/* Current image dimensions. */
	IInterlace,			     /* Sequential/Interlaced lines. */
	IBitsPerPixel;			  /* How many colors this image has? */
    GifColorType *SColorMap, *IColorMap;	      /* NULL if not exists. */
    VoidPtr Private;	  /* The regular user should not mess with this one! */
} GifFileType;

typedef enum {
    UNDEFINED_RECORD_TYPE,
    SCREEN_DESC_RECORD_TYPE,
    IMAGE_DESC_RECORD_TYPE,				   /* Begin with ',' */
    EXTENSION_RECORD_TYPE,				   /* Begin with '!' */
    TERMINATE_RECORD_TYPE				   /* Begin with ';' */
} GifRecordType;

/* DumpScreen2Gif routine constants identify type of window/screen to dump.  */
/* Note all values below 1000 are reserved for the IBMPC different display   */
/* devices (it has many!) and are compatible with the numbering TC2.0        */
/* (Turbo C 2.0 compiler for IBM PC) gives to these devices.		     */
typedef enum {
    GIF_DUMP_SGI_WINDOW = 1000,
    GIF_DUMP_X_WINDOW = 1001
} GifScreenDumpType;

/******************************************************************************
* O.k. here are the routines one can access in order to encode GIF file:      *
* (GIF_LIB file EGIF_LIB.C).						      *
******************************************************************************/

GifFileType *EGifOpenFileName(char *GifFileName, int GifTestExistance);
GifFileType *EGifOpenFileHandle(int GifFileHandle);
void EGifSetGifVersion(char *Version);
int EGifPutScreenDesc(GifFileType *GifFile,
	int GifWidth, int GifHeight, int GifColorRes, int GifBackGround,
	int GifBitsPerPixel, GifColorType *GifColorMap);
int EGifPutImageDesc(GifFileType *GifFile,
	int GifLeft, int GifTop, int Width, int GifHeight, int GifInterlace,
	int GifBitsPerPixel, GifColorType *GifColorMap);
int EGifPutLine(GifFileType *GifFile, GifPixelType *GifLine, int GifLineLen);
int EGifPutPixel(GifFileType *GifFile, GifPixelType GifPixel);
int EGifPutComment(GifFileType *GifFile, char *GifComment);
int EGifPutExtension(GifFileType *GifFile, int GifExtCode, int GifExtLen,
							VoidPtr GifExtension);
int EGifPutCode(GifFileType *GifFile, int GifCodeSize,
						   GifByteType *GifCodeBlock);
int EGifPutCodeNext(GifFileType *GifFile, GifByteType *GifCodeBlock);
int EGifCloseFile(GifFileType *GifFile);

#define	E_GIF_ERR_OPEN_FAILED	1		/* And EGif possible errors. */
#define	E_GIF_ERR_WRITE_FAILED	2
#define E_GIF_ERR_HAS_SCRN_DSCR	3
#define E_GIF_ERR_HAS_IMAG_DSCR	4
#define E_GIF_ERR_NO_COLOR_MAP	5
#define E_GIF_ERR_DATA_TOO_BIG	6
#define E_GIF_ERR_NOT_ENOUGH_MEM 7
#define E_GIF_ERR_DISK_IS_FULL	8
#define E_GIF_ERR_CLOSE_FAILED	9
#define E_GIF_ERR_NOT_WRITEABLE	10

/******************************************************************************
* O.k. here are the routines one can access in order to decode GIF file:      *
* (GIF_LIB file DGIF_LIB.C).						      *
******************************************************************************/

GifFileType *DGifOpenFileName(char *GifFileName);
GifFileType *DGifOpenFileHandle(int GifFileHandle);
int DGifGetScreenDesc(GifFileType *GifFile);
int DGifGetRecordType(GifFileType *GifFile, GifRecordType *GifType);
int DGifGetImageDesc(GifFileType *GifFile);
int DGifGetLine(GifFileType *GifFile, GifPixelType *GifLine, int GifLineLen);
int DGifGetPixel(GifFileType *GifFile, GifPixelType GifPixel);
int DGifGetComment(GifFileType *GifFile, char *GifComment);
int DGifGetExtension(GifFileType *GifFile, int *GifExtCode,
						GifByteType **GifExtension);
int DGifGetExtensionNext(GifFileType *GifFile, GifByteType **GifExtension);
int DGifGetCode(GifFileType *GifFile, int *GifCodeSize,
						GifByteType **GifCodeBlock);
int DGifGetCodeNext(GifFileType *GifFile, GifByteType **GifCodeBlock);
int DGifGetLZCodes(GifFileType *GifFile, int *GifCode);
int DGifCloseFile(GifFileType *GifFile);

#define	D_GIF_ERR_OPEN_FAILED	101		/* And DGif possible errors. */
#define	D_GIF_ERR_READ_FAILED	102
#define	D_GIF_ERR_NOT_GIF_FILE	103
#define D_GIF_ERR_NO_SCRN_DSCR	104
#define D_GIF_ERR_NO_IMAG_DSCR	105
#define D_GIF_ERR_NO_COLOR_MAP	106
#define D_GIF_ERR_WRONG_RECORD	107
#define D_GIF_ERR_DATA_TOO_BIG	108
#define D_GIF_ERR_NOT_ENOUGH_MEM 109
#define D_GIF_ERR_CLOSE_FAILED	110
#define D_GIF_ERR_NOT_READABLE	111
#define D_GIF_ERR_IMAGE_DEFECT	112
#define D_GIF_ERR_EOF_TOO_SOON	113

/******************************************************************************
* O.k. here are the routines from GIF_LIB file QUANTIZE.C.		      *
******************************************************************************/
int QuantizeBuffer(unsigned int Width, unsigned int Height, int *ColorMapSize,
	GifByteType *RedInput, GifByteType *GreenInput, GifByteType *BlueInput,
	GifByteType *OutputBuffer, GifColorType *OutputColorMap);


/******************************************************************************
* O.k. here are the routines from GIF_LIB file QPRINTF.C.		      *
******************************************************************************/
extern int GifQuitePrint;

#ifdef USE_VARARGS
void GifQprintf();
#else
void GifQprintf(char *Format, ...);
#endif /* USE_VARARGS */

/******************************************************************************
* O.k. here are the routines from GIF_LIB file GIF_ERR.C.		      *
******************************************************************************/
void PrintGifError(void);
int GifLastError(void);

/******************************************************************************
* O.k. here are the routines from GIF_LIB file DEV2GIF.C.		      *
******************************************************************************/
int DumpScreen2Gif(char *FileName, int ReqGraphDriver, int ReqGraphMode1,
						       int ReqGraphMode2,
						       int ReqGraphMode3);

#endif /* GIF_LIB_H */
