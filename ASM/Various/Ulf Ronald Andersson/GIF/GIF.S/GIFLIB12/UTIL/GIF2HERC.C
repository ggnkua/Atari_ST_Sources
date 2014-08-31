/*****************************************************************************
*   "Gif-Lib" - Yet another gif library.				     *
*									     *
* Written by:  Gershon Elber				Ver 0.1, Jul. 1989   *
******************************************************************************
* Program to display GIF file on hercules device			     *
* Options:								     *
* -q : quite printing mode.						     *
* -z factor : zoom the pixels by the given factor.			     *
* -t level : set the threshold level of white in the result (0..100).	     *
* -m mapping : methods for mapping the 24bits colors into 1 BW bit.	     *
* -i : invert the image.						     *
* -b : beeps disabled.							     *
* -h : on line help.							     *
*									     *
*   This program uses TC2.0 hercules graphic driver.			     *
*   In this file Screen refers to GIF file screen, while Device to Hercules. *
******************************************************************************
* History:								     *
* 1 Jul 89 - Version 1.0 by Gershon Elber.				     *
*****************************************************************************/

#include <graphics.h>
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <ctype.h>
#include <alloc.h>
#include <string.h>
#include <io.h>
#include <dos.h>
#include <bios.h>
#include <fcntl.h>
#include "gif_lib.h"
#include "getarg.h"

#define PROGRAM_NAME	"Gif2Herc"

#define KEY_LEFT	256	  /* Key Codes returned for operational keys */
#define KEY_RIGHT	257	  /* as return by the GetKey routine.	     */
#define KEY_UP		258
#define KEY_DOWN	259
#define KEY_RETURN	260
#define KEY_DELETE	261
#define KEY_INSERT	262
#define KEY_BSPACE	263
#define KEY_ESC		264
#define KEY_HOME	265
#define KEY_END		266
#define KEY_PGUP	267
#define KEY_PGDN	268

#define	C2BW_BACK_GROUND	0 /*Methods to map 24bits Colors to 1 BW bit.*/
#define	C2BW_GREY_LEVELS	1
#define C2BW_DITHER		2
#define C2BW_NUM_METHODS	3	        /* Always hold # of methods. */

#define DEFAULT_THRESHOLD	5000	     /* Color -> BW threshold level. */
#define INCREMENT_THRESHOLD	1000

#define DITHER_MIN_MATRIX	2
#define DITHER_MAX_MATRIX	4

#define NORMAL_ATTR	0x07				 /* Text attributes. */
#define INVERSE_ATTR	0x70
#define BLINK_ATTR	0x90

#define SET_POSITION_RESET	0	    /* Situations need positionings: */
#define SET_POSITION_ZOOM_U	1
#define SET_POSITION_ZOOM_D	2
#define SET_POSITION_PAN	3

#define DEVICE_BASE	0xb000		      /* Hercules frame buffer base. */
#define DEVICE_PAGE0	0xb000
#define DEVICE_PAGE1	0xb800
#define HERC_MAX_X	719
#define HERC_MAX_Y	347

#define CURSOR_TEXT_X	120

extern unsigned int
    _stklen = 16384;			     /* Increase default stack size. */

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
	" q%- d%-DitherSize!d z%-ZoomFactor!d t%-BWThreshold!d m%-Mapping!d i%- b%- h%- GifFile!*s";
static char
    *GifFileName;
/* Make some variables global, so we could access them faster: */
static int
    ImageNum = 0,
    BackGround = 0,
    BeepsDisabled = FALSE,
    DitherSize = 2, DitherFlag = FALSE,
    ZoomFactor = 1, ZoomFlag = FALSE,
    BWThresholdFlag = FALSE, Threshold,
    BWThreshold = DEFAULT_THRESHOLD,	   /* Color -> BW mapping threshold. */
    Mapping, MappingFlag = FALSE,
    InvertFlag = FALSE,
    HelpFlag = FALSE,
    ColorToBWMapping = C2BW_BACK_GROUND,
    InterlacedOffset[] = { 0, 4, 2, 1 }, /* The way Interlaced image should  */
    InterlacedJumps[] = { 8, 8, 4, 2 };    /* be read - offsets and jumps... */
static GifColorType
    *ColorMap;


static void DisplayScreen(GifRowType *ScreenBuffer, GifFileType *GifFile);
static void PrintSettingStatus(GifFileType *GifFile, GifRowType *DitherBuffer);
static void CPrintStr(char *Str, int y, int attr);
static void SetPositon(int Why,
		       int ScreenWidth, int ScreenHeight,
		       int DeviceMaxX,  int DeviceMaxY,
		       int *ScreenLeft, int *ScreenTop,
		       int *DeviceLeft, int *DeviceTop,
		       int MoveX,       int MoveY);
static void ClearGraphDevice(void);
static void OpenGraphDevice(void);
static void CloseGraphDevice(void);
static void EvalDitheredScanline(GifRowType *ScreenBuffer, int Row,
					int RowSize, GifRowType *DitherBuffer);
static void DrawScreen(GifRowType *ScreenBuffer, GifRowType *DitherBuffer,
	int DeviceTop, int DeviceLeft, int DeviceMaxX, int DeviceMaxY,
	int ScreenTop, int ScreenLeft, int ScreenWidth, int ScreenHeight);
static void DoCursorMode(GifRowType *ScreenBuffer,
	int ScreenLeft, int ScreenTop, int ScreenWidth, int ScreenHeight,
	int DeviceLeft, int DeviceTop);
static int MyKbHit(void);
static int MyGetCh(void);
static int GetKey(void);
static void Tone(int Frequency, int Time);

/******************************************************************************
* Interpret the command line and scan the given GIF file.		      *
******************************************************************************/
void main(int argc, char **argv)
{
    int	i, j, Error, NumFiles, Size, Row, Col, Width, Height, ExtCode, Count;
    GifRecordType RecordType;
    GifByteType *Extension;
    char **FileName = NULL;
    GifRowType *ScreenBuffer;
    GifFileType *GifFile;

    if ((Error = GAGetArgs(argc, argv, CtrlStr,
		&GifQuitePrint, &DitherFlag, &DitherSize,
		&ZoomFlag, &ZoomFactor, &BWThresholdFlag,
		&Threshold, &MappingFlag, &Mapping, &InvertFlag,
		&BeepsDisabled, &HelpFlag, &NumFiles, &FileName)) != FALSE ||
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

    if (DitherFlag) {
	/* Make sure we are o.k.: */
	if (DitherSize > DITHER_MAX_MATRIX) DitherSize = DITHER_MAX_MATRIX;
	if (DitherSize < DITHER_MIN_MATRIX) DitherSize = DITHER_MAX_MATRIX;
    }

    /* As Threshold is in [0..100] range and BWThreshold is [0..25500]: */
    if (BWThresholdFlag) {
	if (Threshold > 100 || Threshold < 0)
	    GIF_EXIT("Threshold not in 0..100 percent.");
	BWThreshold = Threshold * 255;
	if (BWThreshold == 0) BWThreshold = 1;   /* Overcome divide by zero! */
    }

    /* No message is emitted, but mapping method is clipped to exists method.*/
    if (MappingFlag) ColorToBWMapping = Mapping % C2BW_NUM_METHODS;

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
	setmode(0, O_BINARY);
	if ((GifFile = DGifOpenFileHandle(0)) == NULL) {
	    PrintGifError();
	    exit(-1);
	}
    }

    /* Allocate the screen as vector of column of rows. We cannt allocate    */
    /* the all screen at once, as this broken minded CPU can allocate up to  */
    /* 64k at a time and our image can be bigger than that:		     */
    /* Note this screen is device independent - its the screen as defined by */
    /* the GIF file parameters itself.					     */
    if ((ScreenBuffer = (GifRowType *)
	malloc(GifFile -> SHeight * sizeof(GifRowType *))) == NULL)
	    GIF_EXIT("Failed to allocate memory required, aborted.");

    Size = GifFile -> SWidth * sizeof(GifPixelType);/* Size in bytes one row.*/
    if ((ScreenBuffer[0] = (GifRowType) malloc(Size)) == NULL) /* First row. */
	GIF_EXIT("Failed to allocate memory required, aborted.");

    for (i = 0; i < GifFile -> SWidth; i++)  /* Set its color to BackGround. */
	ScreenBuffer[0][i] = GifFile -> SBackGroundColor;
    for (i = 1; i < GifFile -> SHeight; i++) {
	/* Allocate the other rows, andset their color to background too: */
	if ((ScreenBuffer[i] = (GifRowType) malloc(Size)) == NULL)
	    GIF_EXIT("Failed to allocate memory required, aborted.");

	memcpy(ScreenBuffer[i], ScreenBuffer[0], Size);
    }

    /* Scan the content of the GIF file and load the image(s) in: */
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
		Row = GifFile -> ITop; /* Image Position relative to Screen. */
		Col = GifFile -> ILeft;
		Width = GifFile -> IWidth;
		Height = GifFile -> IHeight;
		GifQprintf("\n%s: Image %d at (%d, %d) [%dx%d]:     ",
		    PROGRAM_NAME, ++ImageNum, Col, Row, Width, Height);
		if (GifFile -> ILeft + GifFile -> IWidth > GifFile -> SWidth ||
		   GifFile -> ITop + GifFile -> IHeight > GifFile -> SHeight) {
		    fprintf(stderr, "Image %d is not confined to screen dimension, aborted\n");
		    exit(-2);
		}
		if (GifFile -> IInterlace) {
		    /* Need to perform 4 passes on the images: */
		    for (Count = i = 0; i < 4; i++)
			for (j = Row + InterlacedOffset[i]; j < Row + Height;
						 j += InterlacedJumps[i]) {
			    GifQprintf("\b\b\b\b%-4d", Count++);
			    if (DGifGetLine(GifFile, &ScreenBuffer[j][Col],
				Width) == GIF_ERROR) {
				PrintGifError();
				exit(-1);
			    }
			}
		}
		else {
		    for (i = 0; i < Height; i++) {
			GifQprintf("\b\b\b\b%-4d", i);
			if (DGifGetLine(GifFile, &ScreenBuffer[Row++][Col],
				Width) == GIF_ERROR) {
			    PrintGifError();
			    exit(-1);
			}
		    }
		}
		break;
	    case EXTENSION_RECORD_TYPE:
		/* Skip any extension blocks in file: */
		if (DGifGetExtension(GifFile, &ExtCode, &Extension) == GIF_ERROR) {
		    PrintGifError();
		    exit(-1);
		}
		while (Extension != NULL) {
		    if (DGifGetExtensionNext(GifFile, &Extension) == GIF_ERROR) {
			PrintGifError();
			exit(-1);
		    }
		}
		break;
	    case TERMINATE_RECORD_TYPE:
		break;
	    default:		    /* Should be traps by DGifGetRecordType. */
		break;
	}
    }
    while (RecordType != TERMINATE_RECORD_TYPE);

    /* Lets display it - set the global variables required and do it: */
    BackGround = GifFile -> SBackGroundColor;
    ColorMap = (GifFile -> IColorMap ? GifFile -> IColorMap :
				       GifFile -> SColorMap);
    Tone(500, 10);
    DisplayScreen(ScreenBuffer, GifFile);

    if (DGifCloseFile(GifFile) == GIF_ERROR) {
	PrintGifError();
	exit(-1);
    }
}

/******************************************************************************
* Given the screen buffer, display it:					      *
* The following commands are available (case insensitive).		      *
* 1. Four arrow to move along the screen (only if ScreenBuffer > physical     *
*    screen in that direction.						      *
* 2. C - goto cursor mode - print current color & position in GIF screen      *
*        of the current pixel cursor is on.				      *
* 3. D - zoom out by factor of 2.					      *
* 4. H - halftoning dithering matrix resize.				      *
* 5. I - invert the image.						      *
* 6. M - toggles method of Color -> BW mapping.				      *
* 7. R - redraw current image.						      *
* 8. S - Print Current status/options.					      *
* 9. U - zoom in by factor of 2.					      *
* 10. ' ' - stop drawing current image.					      *
* 11. ESC - to quit.							      *
******************************************************************************/
static void DisplayScreen(GifRowType *ScreenBuffer, GifFileType *GifFile)
{
    int i, j, Size,
	DeviceTop, DeviceLeft,   /* Where ScreenBuffer is to mapped to ours. */
	ScreenTop, ScreenLeft,  /* Porsion of ScreenBuffer to start display. */
	DeviceMaxX, DeviceMaxY,		      /* Physical device dimensions. */
	XPanning, YPanning,		 /* Amount to move using the arrows. */
	GetK, DrawIt = TRUE;
    GifRowType *DitherBuffer;	     /* Used to save dithered pixel scanned. */

    OpenGraphDevice();
    DeviceMaxX = HERC_MAX_X;		    /* Read size of physical screen. */
    DeviceMaxY = HERC_MAX_Y;

    XPanning = DeviceMaxX / 2;
    YPanning = DeviceMaxY / 2;

    SetPositon(SET_POSITION_RESET, GifFile -> SWidth, GifFile -> SHeight,
		DeviceMaxX, DeviceMaxY,
		&ScreenLeft, &ScreenTop,
		&DeviceLeft, &DeviceTop,
		0, 0);

    /*   Allocate the buffer to save the dithered information. If fails to   */
    /* allocate, set it to NULL, and no dithering will take place.	     */
    if ((DitherBuffer = (GifRowType *)
	malloc(DITHER_MAX_MATRIX * sizeof(GifRowType *))) != NULL) {
	Size = GifFile -> SWidth * sizeof(GifPixelType); /* Size of one row. */
	for (i = 0; i < DITHER_MAX_MATRIX; i++) {
	    if ((DitherBuffer[i] = (GifRowType) malloc(Size)) == NULL) {
		for (j = 0; j < i; j++) free((char *) DitherBuffer[i]);
		free((char *) DitherBuffer);
		DitherBuffer = NULL;
		break;
	    }
	}
    }
    if (DitherBuffer == NULL) {
	Tone(300, 100);
	Tone(100, 300);
    }

    do {
	if (DrawIt && !MyKbHit()) {
	    DrawScreen(ScreenBuffer, DitherBuffer,
		DeviceTop, DeviceLeft, DeviceMaxX, DeviceMaxY,
		ScreenTop, ScreenLeft, GifFile -> SWidth, GifFile -> SHeight);
	    Tone(2000, 200);
	}
	DrawIt = TRUE;
	switch (GetK = GetKey()) {
	    case 'C':
		DoCursorMode(ScreenBuffer, ScreenLeft, ScreenTop,
			     GifFile -> SWidth, GifFile -> SHeight,
			     DeviceLeft, DeviceTop);
		DrawIt = FALSE;
		break;
	    case 'D':
		if (ZoomFactor > 1) {
		    ZoomFactor >>= 1;
		    SetPositon(SET_POSITION_ZOOM_D,
			GifFile -> SWidth, GifFile -> SHeight,
			DeviceMaxX, DeviceMaxY,
			&ScreenLeft, &ScreenTop,
			&DeviceLeft, &DeviceTop,
			0, 0);
		}
		else {
		    Tone(1000, 100);
		    DrawIt = FALSE;
		}
		break;
	    case 'H':
		if (++DitherSize > DITHER_MAX_MATRIX)
		    DitherSize = DITHER_MIN_MATRIX;
		break;
	    case 'I':
		InvertFlag = !InvertFlag;
		break;
	    case 'M':
		ColorToBWMapping = (ColorToBWMapping + 1) % C2BW_NUM_METHODS;

		break;
	    case 'R':
		break;
	    case 'S':
		PrintSettingStatus(GifFile, DitherBuffer);
		break;
	    case 'U':
		if (ZoomFactor < 256) {
		    ZoomFactor <<= 1;
		    SetPositon(SET_POSITION_ZOOM_U,
			GifFile -> SWidth, GifFile -> SHeight,
			DeviceMaxX, DeviceMaxY,
			&ScreenLeft, &ScreenTop,
			&DeviceLeft, &DeviceTop,
			0, 0);
		}
		else {
		    Tone(1000, 100);
		    DrawIt = FALSE;
		}
		break;
	    case KEY_ESC:
		break;
	    case KEY_LEFT:
		SetPositon(SET_POSITION_PAN,
			GifFile -> SWidth, GifFile -> SHeight,
			DeviceMaxX, DeviceMaxY,
			&ScreenLeft, &ScreenTop,
			&DeviceLeft, &DeviceTop,
			-XPanning, 0);
		break;
	    case KEY_RIGHT:
		SetPositon(SET_POSITION_PAN,
			GifFile -> SWidth, GifFile -> SHeight,
			DeviceMaxX, DeviceMaxY,
			&ScreenLeft, &ScreenTop,
			&DeviceLeft, &DeviceTop,
			XPanning, 0);
		break;
	    case KEY_UP:
		SetPositon(SET_POSITION_PAN,
			GifFile -> SWidth, GifFile -> SHeight,
			DeviceMaxX, DeviceMaxY,
			&ScreenLeft, &ScreenTop,
			&DeviceLeft, &DeviceTop,
			0, -YPanning);
		break;
	    case KEY_DOWN:
		SetPositon(SET_POSITION_PAN,
			GifFile -> SWidth, GifFile -> SHeight,
			DeviceMaxX, DeviceMaxY,
			&ScreenLeft, &ScreenTop,
			&DeviceLeft, &DeviceTop,
			0, YPanning);
		break;
	    case KEY_DELETE:
		BWThreshold += INCREMENT_THRESHOLD;
		if (BWThreshold == 0) BWThreshold = 1;
		break;
	    case KEY_INSERT:
		BWThreshold -= INCREMENT_THRESHOLD;
		if (BWThreshold == 0) BWThreshold = 1;
		break;
	    default:
		DrawIt = FALSE;
		Tone(800, 100);
		Tone(300, 200);
		break;
	}
    }
    while (GetK != KEY_ESC);

    CloseGraphDevice();
}

/******************************************************************************
* Routine to print (in text mode), current program status.		      *
******************************************************************************/
static void PrintSettingStatus(GifFileType *GifFile, GifRowType *DitherBuffer)
{
    char s[80];

    CloseGraphDevice();

    CPrintStr(PROGRAM_NAME, 1, INVERSE_ATTR);

    sprintf(s, "GIF File - %s", GifFileName);
    CPrintStr(s, 3, NORMAL_ATTR);

    sprintf(s, "Gif Screen Size = [%d, %d]. Contains %d image(s).",
	GifFile -> SWidth, GifFile -> SHeight, ImageNum);
    CPrintStr(s, 5, NORMAL_ATTR);

    if (GifFile -> SColorMap)
	sprintf(s,
	    "Has Screen Color map of %d bits. BackGround = [%d, %d, %d]",
	    GifFile -> SBitsPerPixel,
	    GifFile -> SColorMap[GifFile -> SBackGroundColor].Red,
	    GifFile -> SColorMap[GifFile -> SBackGroundColor].Green,
	    GifFile -> SColorMap[GifFile -> SBackGroundColor].Blue);
    else
	sprintf(s, "No Screen color map.");
    CPrintStr(s, 7, NORMAL_ATTR);

    if (GifFile -> IColorMap)
	sprintf(s, "Has Image map of %d bits (last image). Image is %s.",
	    GifFile -> IBitsPerPixel,
	    (GifFile -> IInterlace ? "interlaced" : "non interlaced"));
    else
	sprintf(s, "No Image color map.");
    CPrintStr(s, 9, NORMAL_ATTR);

    sprintf(s, "Color to BW threshold level - %d%%.\n", BWThreshold / 255);
    CPrintStr(s, 11, NORMAL_ATTR);

    CPrintStr("Color To BW mapping:", 15, NORMAL_ATTR);
    switch(ColorToBWMapping) {
	case C2BW_BACK_GROUND:
	    CPrintStr("Color != BackGround", 16, NORMAL_ATTR);
	    break;
	case C2BW_GREY_LEVELS:
	    CPrintStr(".3 * R + .59 * G + .11 * B > threshold", 16,
								NORMAL_ATTR);
	    break;
	case C2BW_DITHER:
	    sprintf(s, ".3 * R + .59 * G + .11 * B dithered (Size = %d).",
		DitherSize);
	    CPrintStr(s, 16, NORMAL_ATTR);
	    break;
    }

    sprintf(s, "Dither Buffer %s (Size = %d), Zoom = %d.",
	DitherBuffer ? "allocated succesfully" : "not allocated (failed)",
	DitherSize, ZoomFactor);

    CPrintStr(s, 18, NORMAL_ATTR);

    CPrintStr("Press anything to continue:", 23, BLINK_ATTR);
    MyGetCh();

    OpenGraphDevice();
}

/******************************************************************************
* Routine to cprintf given string centered at given Y level, and attr:        *
******************************************************************************/
static void CPrintStr(char *Str, int y, int attr)
{
    gotoxy(40 - (strlen(Str) + 1) / 2, y);
    textattr(attr);
    cputs(Str);
}

/******************************************************************************
* Routine to set the position of Screen in Device, and what porsion of the    *
* screen should be visible:						      *
* MoveX, MoveY are the panning factors (if both zero - initialize).	      *
******************************************************************************/
static void SetPositon(int Why,
		       int ScreenWidth, int ScreenHeight,
		       int DeviceMaxX,  int DeviceMaxY,
		       int *ScreenLeft, int *ScreenTop,
		       int *DeviceLeft, int *DeviceTop,
		       int MoveX,       int MoveY)
{

    MoveX /= ZoomFactor;	   /* Make sure move same amount independent */
    MoveY /= ZoomFactor;			   /* of what ZoomFactor is. */

    /* Figure out position of GIF file in real device X axis: */
    if (ScreenWidth * ZoomFactor <= DeviceMaxX + 1) {
	/* Device is big enough to hold all the image X axis: */
	*ScreenLeft = 0;
	*DeviceLeft = (DeviceMaxX - ScreenWidth * ZoomFactor) / 2;
    }
    else {
	/* Device is too small to hold all the image X axis: */
	switch (Why) {
	    case SET_POSITION_RESET:
		*ScreenLeft = 0;
		break;
	    case SET_POSITION_ZOOM_U:
		*ScreenLeft += DeviceMaxX / (2 * ZoomFactor);
		break;
	    case SET_POSITION_ZOOM_D:
		*ScreenLeft -= DeviceMaxX / (4 * ZoomFactor);
		break;
	    case SET_POSITION_PAN:
		if (MoveX != 0) *ScreenLeft += MoveX;
		break;
	}
	if (*ScreenLeft < 0) *ScreenLeft = 0;
	if ((ScreenWidth - *ScreenLeft) * ZoomFactor < DeviceMaxX + 1)
	    *ScreenLeft = (ScreenWidth * ZoomFactor -
						DeviceMaxX + 1) / ZoomFactor;
	*DeviceLeft = 0;
    }

    /* Figure out position of GIF file in real device Y axis: */
    if (ScreenHeight * ZoomFactor <= DeviceMaxY + 1) {
	/* Device is big enough to hold all the image Y axis: */
	*ScreenTop = 0;
	*DeviceTop = (DeviceMaxY - ScreenHeight * ZoomFactor) / 2;
    }
    else {
	/* Device is too small to hold all the image Y axis: */
	switch (Why) {
	    case SET_POSITION_RESET:
		*ScreenTop = 0;
		break;
	    case SET_POSITION_ZOOM_U:
		*ScreenTop += DeviceMaxY / (2 * ZoomFactor);
		break;
	    case SET_POSITION_ZOOM_D:
		*ScreenTop -= DeviceMaxY / (4 * ZoomFactor);
		break;
	    case SET_POSITION_PAN:
		if (MoveY != 0) *ScreenTop += MoveY;
		break;
	}
	if (*ScreenTop < 0) *ScreenTop = 0;
	if ((ScreenHeight - *ScreenTop) * ZoomFactor < DeviceMaxY + 1)
	    *ScreenTop = (ScreenHeight * ZoomFactor -
						 DeviceMaxY - 1) / ZoomFactor;
	*DeviceTop = 0;
    }

    /* Make sure the position is on Byte boundary (8 pixels per byte): */
    *DeviceLeft &= 0xfff8;
}

/******************************************************************************
* Routine to clear graphic device:					      *
******************************************************************************/
static void ClearGraphDevice(void)
{
    cleardevice();
}

/******************************************************************************
* Routine to open graphic device:					      *
******************************************************************************/
static void OpenGraphDevice(void)
{
    int GraphDriver = HERCMONO, GraphMode = HERCMONOHI;

    if (registerbgidriver(Herc_driver) < 0)
	GIF_EXIT("Cannt register graphic device.");

    initgraph(&GraphDriver, &GraphMode, "");
    if (graphresult() != grOk)
	GIF_EXIT("Graphics System Error (No Hercules!?).");
}

/*****************************************************************************
* Routine to close and shutdown	graphic	mode :				     *
*****************************************************************************/
static void CloseGraphDevice(void)
{
    closegraph();			  /* Return the system to text mode. */
}

/*****************************************************************************
* Routine to evaluate dithered scanlines out of given ones, using Size	     *
* dithering matrix, starting from Row. The given scanlines are NOT modified. *
*****************************************************************************/
static void EvalDitheredScanline(GifRowType *ScreenBuffer, int Row,
					 int RowSize, GifRowType *DitherBuffer)
{
    static char Dither2[2][2] = {	 /* See Foley & Van Dam pp. 597-601. */
	{ 1, 3 },
	{ 4, 2 }
    };
    static char Dither3[3][3] = {
	{ 7, 9, 5 },
	{ 2, 1, 4 },
	{ 6, 3, 8 }
    };
    static char Dither4[4][4] = {
	{ 1,  9,  3,  11 },
	{ 13, 5,  15, 7 },
	{ 4,  12, 2,  10 },
	{ 16, 8,  14, 6 }
    };
    int i, j, k, Level;
    long Intensity;
    GifColorType *ColorMapEntry;

    /* Scan the Rows (Size rows) evaluate intensity every Size pixel and use */
    /* the dither matrix to set the dithered result;			     */
    for (i = 0; i <= RowSize - DitherSize; i += DitherSize) {
	Intensity = 0;
	for (j = Row; j < Row + DitherSize; j++)
	    for (k = 0; k < DitherSize; k++) {
		ColorMapEntry = &ColorMap[ScreenBuffer[j][i+k]];
		Intensity += 30 * ((int) ColorMapEntry->Red) +
			     59 * ((int) ColorMapEntry->Green) +
			     11 * ((int) ColorMapEntry->Blue);
	    }

	/* Find the intensity level (between 0 and Size^2) of our matrix: */
	/* Expression is "Intensity * BWThreshold / (25500 * DefThresh)"  */
	/* but to prevent from overflow in the long evaluation we do this:*/
	Level = ((Intensity / 2550) * ((long) DEFAULT_THRESHOLD) /
						(((long) BWThreshold) * 10));
	switch (DitherSize) {
	    case 2:
		for (j = 0; j < DitherSize; j++)
		    for (k = 0; k < DitherSize; k++)
			DitherBuffer[j][i+k] = Dither2[j][k] <= Level;
		break;
	    case 3:
		for (j = 0; j < DitherSize; j++)
		    for (k = 0; k < DitherSize; k++)
			DitherBuffer[j][i+k] = Dither3[j][k] <= Level;
		break;
	    case 4:
		for (j = 0; j < DitherSize; j++)
		    for (k = 0; k < DitherSize; k++)
			DitherBuffer[j][i+k] = Dither4[j][k] <= Level;
		break;
	}
    }
}

/******************************************************************************
* The real drawing of the image is performed here. Few things are taken into  *
* account:								      *
* 1. The zoom factor. If > 1 each pixel is multiplied this amount vertically  *
*    and horizontally.							      *
* 2. The Invert flag. If TRUE each pixel before drawn is inverted.	      *
* 3. The rendering mode and dither matrix flag if dithering is selected.      *
*   The image is drawn from ScreenBuffer ScreenTop/Left in the bottom/right   *
* directions, onto the Device DeviceTop/Left in the bottom/right direction    *
*     This routine was optimized for the hercules graphic card and should be  *
* handled carfully as it is device dependent.				      *
*   Pressing space during drawing will abort this routine.		      *
******************************************************************************/
static void DrawScreen(GifRowType *ScreenBuffer, GifRowType *DitherBuffer,
	int DeviceTop, int DeviceLeft, int DeviceMaxX, int DeviceMaxY,
	int ScreenTop, int ScreenLeft, int ScreenWidth, int ScreenHeight)
{
    unsigned int Offset;
    int i, j, k, l, m, CountZoomJ, CountZoomI,
	DitheredLinesLeft = 0, DitheredLinesCount, MapInvert[2];
    GifByteType DeviceByte;
    GifPixelType *Line;
    GifColorType *ColorMapEntry;

    ClearGraphDevice();			 /* Make sure we start from scratch. */

    if (InvertFlag) {		   /* Make the inversion as fast a possible. */
	MapInvert[0] = 1;
	MapInvert[1] = 0;
    }
    else {
	MapInvert[0] = 0;
	MapInvert[1] = 1;
    }

    for (CountZoomJ = ZoomFactor, j = ScreenTop, l = DeviceTop, DeviceByte = 0;
	 j < ScreenHeight && l <= DeviceMaxY; l++) {
	Line = ScreenBuffer[j];

	/* We are going to access the hercules frame buffer directly: */
	Offset = 0x2000 * (l & 0x03) + (l >> 2) * 90 + (DeviceLeft >> 3);

	/* Abort drawing if space bar was pressed: */
	if (MyKbHit() && GetKey() == ' ') return;

	/* We decide right here what method to map Colors to BW so the inner */
	/* loop will be independent of it (and therefore faster):	     */
	switch(ColorToBWMapping) {
	    case C2BW_BACK_GROUND:
		for (CountZoomI = ZoomFactor, i = ScreenLeft, k = DeviceLeft, m = 0;
		     i < ScreenWidth && k <= DeviceMaxX;) {
		    /* The following lines are equivalent to the putpixel    */
		    /* (and making it real machine dependent...) by almost   */
		    /* factor of 3:					     */
		    /* putpixel(k++, l, MapInvert[ColorToBW(Line[i])]);	     */
		    DeviceByte = (DeviceByte << 1) +
					MapInvert[Line[i] != BackGround];
		    if (++m == 8) {
			/* We have byte - place it on hercules frame buffer: */
			k += 8;
			pokeb(DEVICE_BASE, Offset++, DeviceByte);
			m = 0;
		    }

		    if (!--CountZoomI) {
			/* Go to next column: */
			i++;
			CountZoomI = ZoomFactor;
		    }
		}
		if (k < DeviceMaxX) {
		    /* Poke last byte also: */
		    DeviceByte <<= 8 - m;
		    pokeb(DEVICE_BASE, Offset++, DeviceByte);
		}
		break;
	    case C2BW_GREY_LEVELS:
		for (CountZoomI = ZoomFactor, i = ScreenLeft, k = DeviceLeft, m = 0;
		     i < ScreenWidth && k <= DeviceMaxX;) {
		    /* The following lines are equivalent to the putpixel    */
		    /* (and making it real machine dependent...) by almost   */
		    /* factor of 3:					     */
		    /* putpixel(k++, l, MapInvert[ColorToBW(Line[i])]);	     */

		    ColorMapEntry = &ColorMap[Line[i]];
		    /* For the transformation from RGB to BW, see Folley &   */
		    /* Van Dam pp 613: The Y channel is the BW we need:	     */
		    /* As colors are 255 maximum, the result can be up to    */
		    /* 25500 which is still in range of our 16 bits integers.*/
		    DeviceByte = (DeviceByte << 1) +
			MapInvert[(30 * (int) ColorMapEntry->Red) +
				   59 * ((int) ColorMapEntry->Green) +
				   11 * ((int) ColorMapEntry->Blue) >
					BWThreshold];
		    if (++m == 8) {
			/* We have byte - place it on hercules frame buffer: */
			k += 8;
			pokeb(DEVICE_BASE, Offset++, DeviceByte);
			m = 0;
		    }

		    if (!--CountZoomI) {
			/* Go to next column: */
			i++;
			CountZoomI = ZoomFactor;
		    }
		}
		if (k < DeviceMaxX) {
		    /* Poke last byte also: */
		    DeviceByte <<= 8 - m;
		    pokeb(DEVICE_BASE, Offset++, DeviceByte);
		}
		break;
	    case C2BW_DITHER:
		if (DitheredLinesLeft-- == 0) {
		    EvalDitheredScanline(ScreenBuffer,
			(j < ScreenHeight - DitherSize ? j :
						 ScreenHeight - DitherSize),
			ScreenWidth, DitherBuffer);
		    DitheredLinesLeft = DitherSize - 1;
		    DitheredLinesCount = 0;
		}
		Line = DitherBuffer[DitheredLinesCount++];
		for (CountZoomI = ZoomFactor, i = ScreenLeft, k = DeviceLeft, m = 0;
		     i < ScreenWidth && k <= DeviceMaxX;) {
		    /* The following lines are equivalent to the putpixel    */
		    /* (and making it real machine dependent...) by almost   */
		    /* factor of 3:					     */
		    /* putpixel(k++, l, MapInvert[Line[i]]);		     */
		    DeviceByte = (DeviceByte << 1) + MapInvert[Line[i]];
		    if (++m == 8) {
			/* We have byte - place it on hercules frame buffer: */
			k += 8;
			pokeb(DEVICE_BASE, Offset++, DeviceByte);
			m = 0;
		    }

		    if (!--CountZoomI) {
			/* Go to next column: */
			i++;
			CountZoomI = ZoomFactor;
		    }
		}
		if (k < DeviceMaxX) {
		    /* Poke last byte also: */
		    DeviceByte <<= 8 - m;
		    pokeb(DEVICE_BASE, Offset++, DeviceByte);
		}
		break;
	}

	if (!--CountZoomJ) {
	    /* Go to next row: */
	    j++;
	    CountZoomJ = ZoomFactor;
	}
    }
}

/******************************************************************************
* Walks along the current image, while printing pixel value and position.     *
* 4 arrows may be used, and any other key will abort this operation	      *
* As there is no XOR mode for text, we copy all Page 0 to Page 1 before we    *
* start this, and copy it back each time...				      *
******************************************************************************/
static void DoCursorMode(GifRowType *ScreenBuffer,
	int ScreenLeft, int ScreenTop, int ScreenWidth, int ScreenHeight,
	int DeviceLeft, int DeviceTop)
{
    int GetK, DeviceRight, DeviceBottom, x, y, CursorTextY, Step;
    GifPixelType Pixel;
    char s[80];
    char far *Page0, *Page1;

    Page0 = MK_FP(DEVICE_PAGE0, 0);
    Page1 = MK_FP(DEVICE_PAGE1, 0);

    memcpy(Page1, Page0, 0x8000);


    DeviceRight = DeviceLeft + (ScreenWidth - ScreenLeft) * ZoomFactor;
    if (DeviceRight > HERC_MAX_X) DeviceRight = HERC_MAX_X;

    DeviceBottom = DeviceTop + (ScreenHeight - ScreenTop) * ZoomFactor;
    if (DeviceBottom > HERC_MAX_Y) DeviceBottom = HERC_MAX_Y;

    x = (DeviceLeft + DeviceRight) / 2;
    y = (DeviceTop + DeviceBottom) / 2;

    while (TRUE) {
	Pixel = ScreenBuffer[ScreenTop + (y - DeviceTop) / ZoomFactor]
			    [ScreenLeft + (x - DeviceLeft) / ZoomFactor];
	sprintf(s, "Color = %d [%d, %d, %d], X = %d, Y = %d.",
		Pixel,
		ColorMap[Pixel].Red,
		ColorMap[Pixel].Green,
		ColorMap[Pixel].Blue,
		(x - DeviceLeft) / ZoomFactor,
		(y - DeviceTop) / ZoomFactor);
	CursorTextY = (y > HERC_MAX_Y / 2 ? HERC_MAX_Y / 4 :
					    3 * HERC_MAX_Y / 4);
	setviewport(CURSOR_TEXT_X, CursorTextY,
		    CURSOR_TEXT_X + textwidth(s), CursorTextY + textheight(s),
		    TRUE);
	clearviewport();
	setviewport(0, 0, HERC_MAX_X, HERC_MAX_Y, TRUE);
	setcolor(1);			     /* We only have one color here. */
	line(0, y, HERC_MAX_X, y);
	line(x, 0, x, HERC_MAX_Y);
	outtextxy(CURSOR_TEXT_X, CursorTextY, s);
	GetK = GetKey();

	memcpy(Page0, Page1, 0x8000);

	Step = 10;
	switch (GetK) {
	    case '1':
		GetK = KEY_END;
		break;
	    case '2':
		GetK = KEY_DOWN;
		break;
	    case '3':
		GetK = KEY_PGDN;
		break;
	    case '4':
		GetK = KEY_LEFT;
		break;
	    case '6':
		GetK = KEY_RIGHT;
		break;
	    case '7':
		GetK = KEY_HOME;
		break;
	    case '8':
		GetK = KEY_UP;
		break;
	    case '9':
		GetK = KEY_PGUP;
		break;
	    default:
		Step = 1;
	}

	switch (GetK) {
	    case KEY_LEFT:
		x -= Step;
		break;
	    case KEY_RIGHT:
		x += Step;
		break;
	    case KEY_UP:
		y -= Step;
		break;
	    case KEY_DOWN:
		y += Step;
		break;
	    case KEY_PGUP:
		y -= Step;
		x += Step;
		break;
	    case KEY_PGDN:
		y += Step;
		x += Step;
		break;
	    case KEY_HOME:
		y -= Step;
		x -= Step;
		break;
	    case KEY_END:
		y += Step;
		x -= Step;
		break;
	    default:
		return;
	}
	if (x < DeviceLeft) x = DeviceLeft;
	if (x >= DeviceRight) x = DeviceRight;
	if (y < DeviceTop) y = DeviceTop;
	if (y >= DeviceBottom) y = DeviceBottom;
    }
}

/******************************************************************************
* Return non zero value if at list one character exists in keyboard queue.    *
* This routine emulates kbhit() which do uses stdin and useless for us.       *
******************************************************************************/
static int MyKbHit(void)
{
    return bioskey(1);
}

/******************************************************************************
* Get a key from keyboard directly (bypass stdin as we might redirect it).    *
* This routine emulates getch() which do uses stdin and useless for us.       *
******************************************************************************/
static int MyGetCh(void)
{
    static int Extended = 0;
    int c;

    if (Extended) {
	c = Extended;
	Extended = 0;
	return c;
    }
    else {
	c = bioskey(0);
	if (c & 0x0ff)
	    return c;
	else {
	    Extended = c >> 8;
	    return 0;
	}
    }
}

/******************************************************************************
* Get a key from keyboard, and translating operational keys into special      *
* codes (>255).	Lower case characters are upercased.			      *
******************************************************************************/
static int GetKey(void)
{
    char c;

    while (TRUE) switch (c = MyGetCh()) {
	case 0:		      /* Extended code - get the next extended char. */
	    switch (MyGetCh()) {
		case 75: return KEY_LEFT;
		case 77: return KEY_RIGHT;
		case 72: return KEY_UP;
		case 80: return KEY_DOWN;
		case 71: return KEY_HOME;
		case 79: return KEY_END;
		case 73: return KEY_PGUP;
		case 81: return KEY_PGDN;
		case 83: return KEY_DELETE;
		case 82: return KEY_INSERT;
	    }
	    break;
	case 8:
	    return KEY_BSPACE;
	case 10:
	case 13:
	    return KEY_RETURN;
	case 27:
	    return KEY_ESC;
	default:
	    if (isprint(c)) {
		if (islower(c))
		    return toupper(c);
		else
		    return c;
	    }
	    else {
		Tone(800, 100);
		Tone(300, 200);
	    }
    }

    return 0;				   /* Should never be here any case. */
}

/******************************************************************************
* Routine to make some sound with given Frequency, Time milliseconds:	      *
******************************************************************************/
static void Tone(int Frequency, int Time)
{
    if (BeepsDisabled) return;

    sound(Frequency);
    delay(Time);
    nosound();
}
