/*****************************************************************************
*   "Gif-Lib" - Yet another gif library.				     *
*									     *
* Written by:  Gershon Elber				Ver 0.1, Jul. 1989   *
******************************************************************************
* Program to display GIF file using the BGI device indepedent routines       *
* Options:								     *
* -q : quite printing mode.						     *
* -d BGI path : specify the directory where to look for bgi drivers.	     *
* -u BGIUserDriverName.Mode : use user driver instead of auto detection.     *
* -z factor : zoom the pixels by the given factor.			     *
* -b : beeps disabled.							     *
* -h : on line help.							     *
*									     *
*   In this file Screen refers to GIF file screen, while Device to BGI size. *
******************************************************************************
* History:								     *
* 31 Jul 90 - Version 1.0 by Gershon Elber.				     *
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

#define PROGRAM_NAME	"Gif2BGI"

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

#define SET_POSITION_RESET	0	    /* Situations need positionings: */
#define SET_POSITION_ZOOM_U	1
#define SET_POSITION_ZOOM_D	2
#define SET_POSITION_PAN	3

#define CURSOR_TEXT_X	120

#define BGI_USER_INSTALL	999	/* BGI User installed driver device. */

#define MIN(x, y)	((x) < (y) ? (x) : (y))

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
	" q%- d%-BGI|Directory!s u%-UserBGIDrv.Mode!s z%-ZoomFactor!d b%- h%- GifFile!*s";
static char
    *GifFileName,
    *BGIPath = "",
    *BGIUserDriverName = NULL;

/* Make some variables global, so we could access them faster: */
static int
    ImageNum = 0,
    BackGround = 0,
    ForeGround = 1,			   /* As close to white as possible. */
    BeepsDisabled = FALSE,
    ZoomFactor = 1,
    MaximumScreenHeight = 1,
    BGIUserDriverMode = -1,
    DeviceMaxX = 640, DeviceMaxY = 400,	      /* Physical device dimensions. */
    ScreenWidth = 320, ScreenHeight = 200,         /* Gif image screen size. */
    InterlacedOffset[] = { 0, 4, 2, 1 }, /* The way Interlaced image should. */
    InterlacedJumps[] = { 8, 8, 4, 2 };    /* be read - offsets and jumps... */
static GifColorType
    *ColorMap;

static int huge detectVGA(void);
static void BGIInstallUserDriver(char *BGIUserDriverNameMode);
static void DisplayScreen(GifRowType *ScreenBuffer, GifFileType *GifFile);
static void PrintSettingStatus(GifFileType *GifFile);
static void CPrintStr(char *Str, int y);
static void SetPosition(int Why,
		        int *ScreenLeft, int *ScreenTop,
		        int *DeviceLeft, int *DeviceTop,
		        int MoveX,       int MoveY);
static void DrawScreen(GifRowType *ScreenBuffer,
		int ScreenLeft, int ScreenTop, int DeviceLeft, int DeviceTop);
static void DoCursorMode(GifRowType *ScreenBuffer,
		int ScreenLeft, int ScreenTop, int DeviceLeft, int DeviceTop);
static int MyKbHit(void);
static int MyGetCh(void);
static int GetKey(void);
static void Tone(int Frequency, int Time);

/******************************************************************************
* Interpret the command line and scan the given GIF file.		      *
******************************************************************************/
void main(int argc, char **argv)
{
    int	i, j, k, Error, NumFiles, Size, Row, Col, Width, Height, ExtCode,
	Count, ColorMapSize, GraphDriver, GraphMode, Sum,
	HelpFlag = FALSE,
	BGIPathFlag = FALSE,
	BGIUserDriverFlag = FALSE,
	ZoomFlag = FALSE;
    GifRecordType RecordType;
    GifByteType *Extension;
    char Str[80], *BGIUserDriverNameMode,
	**FileName = NULL;
    GifRowType *ScreenBuffer;
    GifFileType *GifFile;
    struct text_info TextInfo;      /* So we can restore starting text mode. */

    if ((Error = GAGetArgs(argc, argv, CtrlStr,
		&GifQuitePrint, &BGIPathFlag, &BGIPath,
		&BGIUserDriverFlag, &BGIUserDriverNameMode,
		&ZoomFlag, &ZoomFactor,
		&BeepsDisabled, &HelpFlag,
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

    if (BGIUserDriverFlag) {
	/* Use the driver supplied by the user! */
        BGIInstallUserDriver(BGIUserDriverNameMode);
        installuserdriver(BGIUserDriverName, detectVGA);
	GraphDriver = BGI_USER_INSTALL;
    }
    else {
        /* Sense type of display we have and attempt to load right driver. */
        detectgraph(&GraphDriver, &GraphMode);
        if (GraphDriver < 0)
	    GIF_EXIT("BGI Auto detect: No graphics device detected.");
    }

    /* Put in the following any graphic driver specific setup: */
    switch (GraphDriver) {
	case CGA:
	    GraphMode = CGAHI;
	    break;
	case EGA:
	    GraphMode = EGAHI;
	    break;
	case EGA64:
	    GraphMode = EGA64HI;
	    break;
	case EGAMONO:
	    GraphMode = EGAMONOHI;
	    break;
	case HERCMONO:
	    GraphMode = HERCMONOHI;
	    break;
	case VGA:
	    GraphMode = VGAHI;
	    break;
	case BGI_USER_INSTALL:
	    GraphDriver = DETECT;
	    GraphMode = BGIUserDriverMode;
	    break;
	default:
	    GIF_EXIT("Requested graphic device is not supported.");
	    break;
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

    Size = GifFile -> SWidth * sizeof(GifPixelType);/* Size in bytes of one row.*/
    if ((ScreenBuffer[0] = (GifRowType) malloc(Size)) == NULL)    /* First row. */
	GIF_EXIT("Failed to allocate memory required, aborted.");

    for (i = 0; i < GifFile -> SWidth; i++)  /* Set its color to BackGround. */
	ScreenBuffer[0][i] = GifFile -> SBackGroundColor;
    MaximumScreenHeight = GifFile -> SHeight - 1;
    for (i = 1; i < GifFile -> SHeight; i++) {
	/* Allocate the other rows, and set their color to background too: */
	if ((ScreenBuffer[i] = (GifRowType) malloc(Size)) == NULL) {
	    if (i > 30) {
		/* Free some memory for the BGI driver and auxilary. */
		for (j = 1; j < 28; j++)
	    	    free((char *) ScreenBuffer[i - j]);
	    	MaximumScreenHeight = i - 28;
	    	fprintf(stderr, "\n%s: Failed to allocate all memory required, last line %d.\n",
			PROGRAM_NAME, MaximumScreenHeight);
	    	break;
	    }
	    else
		GIF_EXIT("Failed to allocate memory required, aborted.");
	}

	memcpy(ScreenBuffer[i], ScreenBuffer[0], Size);
    }

    /* Scan the content of the GIF file and load the image(s) in: */
    do {
	if (DGifGetRecordType(GifFile, &RecordType) == GIF_ERROR) {
	    PrintGifError();
	    break;
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
		    fprintf(stderr, "Image %d is not confined to screen dimension, aborted.\n");
		    exit(-2);
		}
		if (GifFile -> IInterlace) {
		    /* Need to perform 4 passes on the images: */
		    for (Count = i = 0; i < 4; i++)
			for (j = Row + InterlacedOffset[i]; j < Row + Height;
						 j += InterlacedJumps[i]) {
			    GifQprintf("\b\b\b\b%-4d", Count++);
			    if (DGifGetLine(GifFile,
				&ScreenBuffer[MIN(j, MaximumScreenHeight)][Col],
				Width) == GIF_ERROR) {
				PrintGifError();
				exit(-1);
			    }
			}
		}
		else {
		    for (i = 0; i < Height; i++, Row++) {
			GifQprintf("\b\b\b\b%-4d", i);
			if (DGifGetLine(GifFile, &ScreenBuffer[MIN(Row, MaximumScreenHeight)][Col],
				Width) == GIF_ERROR) {
			    PrintGifError();
			    MaximumScreenHeight = MIN(i - 1, MaximumScreenHeight);
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
    ColorMapSize = 1 << (GifFile -> IColorMap ? GifFile -> IBitsPerPixel :
						GifFile -> SBitsPerPixel);

    gettextinfo(&TextInfo);	     /* Save current mode so we can recover. */

    initgraph(&GraphDriver, &GraphMode, BGIPath);
    if (graphresult() != grOk)	 	       /* Error occured during init. */
	GIF_EXIT("Graphics System Error, failed to initialize driver.");

    if (getmaxcolor() + 1 < ColorMapSize) {
	sprintf(Str, "GIF Image color map (%d) is too big for device (%d).\n",
					      ColorMapSize, getmaxcolor() + 1);
	closegraph();
	GIF_EXIT(Str);
    }

    /* Initialize hardware pallete and also select fore/background color.    */
    BackGround = ForeGround = 1;
    Sum = ((int) ColorMap[1].Red) +
	  ((int) ColorMap[1].Green) +
	  ((int) ColorMap[1].Blue);
    j = k = Sum;
    for (i = 0; i < ColorMapSize; i++) {
	setrgbpalette(i, ColorMap[i].Red >> 2,
			 ColorMap[i].Green >> 2,
			 ColorMap[i].Blue >> 2);

	Sum = ((int) ColorMap[i].Red) +
	      ((int) ColorMap[i].Green) +
	      ((int) ColorMap[i].Blue);
	if (i != 0 && Sum > j) {			/* Dont use color 0. */
	    ForeGround = i;
	    j = Sum;
	}
	if (i != 0 && Sum <= k) {			/* Dont use color 0. */
	    BackGround = i;
	    k = Sum;
	}
    }

    DeviceMaxX = getmaxx();		    /* Read size of physical screen. */
    DeviceMaxY = getmaxy();
    ScreenWidth = GifFile -> SWidth;
    ScreenHeight = MIN(GifFile -> SHeight, MaximumScreenHeight);

    Tone(500, 10);
    DisplayScreen(ScreenBuffer, GifFile);

    if (DGifCloseFile(GifFile) == GIF_ERROR) {
	PrintGifError();
	closegraph();
	exit(-1);
    }

    closegraph();

    textmode(TextInfo.currmode);
}

/****************************************************************************
* Routine to be called for the user installed driver:			    *
****************************************************************************/
static int huge detectVGA(void)
{
    return BGIUserDriverMode;
}

/****************************************************************************
* Routine to install the user BGI driver information.			    *
****************************************************************************/
static void BGIInstallUserDriver(char *BGIUserDriverNameMode)
{
    char *p;

    if ((p = strrchr(BGIUserDriverNameMode, '/')) != NULL ||
	(p = strrchr(BGIUserDriverNameMode, '\\')) != NULL) {
	p[0] = 0;
	BGIPath = strdup(BGIUserDriverNameMode);
	p++;
    }

    p = strtok(p, ".");
    BGIUserDriverName = strdup(p);

    p = strtok(NULL, ".");
    if (sscanf(p, "%d", &BGIUserDriverMode) != 1 || BGIUserDriverName == NULL)
	GIF_EXIT("User [-u] BGI specification has wrong format.");
}

/******************************************************************************
* Given the screen buffer, display it:					      *
* The following commands are available (case insensitive).		      *
* 1. Four arrow to move along the screen (only if ScreenBuffer > physical     *
*    screen in that direction.						      *
* 2. C - goto cursor mode - print current color & position in GIF screen      *
*        of the current pixel cursor is on.				      *
* 3. D - zoom out by factor of 2.					      *
* 4. R - redraw current image.						      *
* 5. S - Print Current status/options.					      *
* 6. U - zoom in by factor of 2.					      *
* 7. ' ' - stop drawing current image.					      *
* 8. ESC - to quit.							      *
******************************************************************************/
static void DisplayScreen(GifRowType *ScreenBuffer, GifFileType *GifFile)
{
    int DeviceTop, DeviceLeft,   /* Where ScreenBuffer is to mapped to ours. */
	ScreenTop, ScreenLeft,  /* Porsion of ScreenBuffer to start display. */
	XPanning, YPanning,		 /* Amount to move using the arrows. */
	GetK, DrawIt = TRUE;

    XPanning = DeviceMaxX / 2;
    YPanning = DeviceMaxY / 2;

    SetPosition(SET_POSITION_RESET,
		&ScreenLeft, &ScreenTop,
		&DeviceLeft, &DeviceTop,
		0, 0);

    do {
	if (DrawIt && !MyKbHit()) {
	    DrawScreen(ScreenBuffer, ScreenLeft, ScreenTop,
				     DeviceLeft, DeviceTop);
	    Tone(2000, 200);
	}
	DrawIt = TRUE;
	switch (GetK = GetKey()) {
	    case 'C':
		DoCursorMode(ScreenBuffer, ScreenLeft, ScreenTop,
					   DeviceLeft, DeviceTop);
		DrawIt = TRUE;
		break;
	    case 'D':
		if (ZoomFactor > 1) {
		    ZoomFactor >>= 1;
		    SetPosition(SET_POSITION_ZOOM_D,
			&ScreenLeft, &ScreenTop,
			&DeviceLeft, &DeviceTop,
			0, 0);
		}
		else {
		    Tone(1000, 100);
		    DrawIt = FALSE;
		}
		break;
	    case 'R':
		break;
	    case 'S':
		PrintSettingStatus(GifFile);
		break;
	    case 'U':
		if (ZoomFactor < 256) {
		    ZoomFactor <<= 1;
		    SetPosition(SET_POSITION_ZOOM_U,
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
		SetPosition(SET_POSITION_PAN,
			&ScreenLeft, &ScreenTop,
			&DeviceLeft, &DeviceTop,
			-XPanning, 0);
		break;
	    case KEY_RIGHT:
		SetPosition(SET_POSITION_PAN,
			&ScreenLeft, &ScreenTop,
			&DeviceLeft, &DeviceTop,
			XPanning, 0);
		break;
	    case KEY_UP:
		SetPosition(SET_POSITION_PAN,
			&ScreenLeft, &ScreenTop,
			&DeviceLeft, &DeviceTop,
			0, -YPanning);
		break;
	    case KEY_DOWN:
		SetPosition(SET_POSITION_PAN,
			&ScreenLeft, &ScreenTop,
			&DeviceLeft, &DeviceTop,
			0, YPanning);
		break;
	    default:
		DrawIt = FALSE;
		Tone(800, 100);
		Tone(300, 200);
		break;
	}
    }
    while (GetK != KEY_ESC);
}

/******************************************************************************
* Routine to print (in text mode), current program status.		      *
******************************************************************************/
static void PrintSettingStatus(GifFileType *GifFile)
{
    char s[80];

    setcolor(ForeGround);

    CPrintStr(PROGRAM_NAME, 1);

    sprintf(s, "GIF File - %s.", GifFileName);
    CPrintStr(s, 10);

    sprintf(s, "Gif Screen Size = [%d, %d]. Contains %d image(s).",
	GifFile -> SWidth, GifFile -> SHeight, ImageNum);
    CPrintStr(s, 20);

    if (GifFile -> SColorMap)
	sprintf(s,
	    "Has Screen Color map of %d bits. BackGround = [%d, %d, %d].",
	    GifFile -> SBitsPerPixel,
	    GifFile -> SColorMap[GifFile -> SBackGroundColor].Red,
	    GifFile -> SColorMap[GifFile -> SBackGroundColor].Green,
	    GifFile -> SColorMap[GifFile -> SBackGroundColor].Blue);
    else
	sprintf(s, "No Screen color map.");
    CPrintStr(s, 30);

    if (GifFile -> IColorMap)
	sprintf(s, "Has Image map of %d bits (last image). Image is %s.",
	    GifFile -> IBitsPerPixel,
	    (GifFile -> IInterlace ? "interlaced" : "non interlaced"));
    else
	sprintf(s, "No Image color map.");
    CPrintStr(s, 40);

    CPrintStr("Press anything to continue:", 60);
    MyGetCh();
}

/******************************************************************************
* Routine to cprintf given string centered at given Y level, and attr:        *
******************************************************************************/
static void CPrintStr(char *Str, int y)
{
    setfillstyle(SOLID_FILL, BackGround);
    bar(0, y, textwidth(Str) + 2, y + textheight(Str) + 2);

    setcolor(ForeGround);
    outtextxy(1, y + 1, Str);
}

/******************************************************************************
* Routine to set the position of Screen in Device, and what porsion of the    *
* screen should be visible:						      *
* MoveX, MoveY are the panning factors (if both zero - initialize).	      *
******************************************************************************/
static void SetPosition(int Why,
		        int *ScreenLeft, int *ScreenTop,
		        int *DeviceLeft, int *DeviceTop,
		        int MoveX,       int MoveY)
{

    MoveX /= ZoomFactor;     /* Make sure move move same amount independent. */
    MoveY /= ZoomFactor;			   /* of what ZommFactor is. */

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
* The real drawing of the image is performed here. Few things are taken into  *
* account:								      *
* 1. The zoom factor. If > 1 each pixel is multiplied this amount vertically  *
*    and horizontally.							      *
*   The image is drawn from ScreenBuffer ScreenTop/Left in the bottom/right   *
* directions, onto the Device DeviceTop/Left in the bottom/right direction    *
*   Pressing space during drawing will abort this routine.		      *
******************************************************************************/
static void DrawScreen(GifRowType *ScreenBuffer,
		int ScreenLeft, int ScreenTop, int DeviceLeft, int DeviceTop)
{
    int i, j, k, l, CountZoomJ, CountZoomI,
	DeviceWidth, DeviceRight, ScreenBottom;
    unsigned char *ImageBuffer, *p;
    GifPixelType *Line;

    /* Make sure we start from scratch. Note cleardevice() uses color 0 even */
    /* if it may be non black.						     */
    cleardevice();

    if (getmaxcolor() + 1 == 256) {
	/* Optimize this case - one byte per pixel. */
    	DeviceWidth = ScreenWidth * ZoomFactor;
	if (DeviceWidth + DeviceLeft > DeviceMaxX)
	    DeviceWidth = DeviceMaxX - DeviceLeft;
    	DeviceRight = DeviceLeft + DeviceWidth - 1;
    	ScreenBottom = ScreenTop + ScreenHeight - 1;

	if ((ImageBuffer = malloc(imagesize(DeviceLeft, DeviceTop,
					    DeviceRight, DeviceTop))) == NULL)
	    GIF_EXIT("Failed to allocate memory required, aborted.");
	getimage(DeviceLeft, DeviceTop, DeviceRight, DeviceTop, ImageBuffer);

	for (k = DeviceTop; k < DeviceMaxY && ScreenTop <= ScreenBottom;) {
	    Line = ScreenBuffer[ScreenTop++];
	    p = ImageBuffer + 4;	  /* point on first pixel in bitmap. */
	    if (ZoomFactor == 1)
		memcpy(p, &Line[ScreenLeft], DeviceWidth);
	    else {
		for (i = 0, j = ScreenLeft, CountZoomI = ZoomFactor;
		     i < DeviceWidth;
		     i++) {
		    *p++ = Line[j];
		    if (--CountZoomI == 0) {
			CountZoomI = ZoomFactor;
			j++;
		    }
		}
	    }

	    /* Abort drawing if space bar was pressed: */
	    if (MyKbHit() && GetKey() == ' ') break;

	    for (i = 0; i < ZoomFactor; i++)
		putimage(DeviceLeft, k++, ImageBuffer, COPY_PUT);
	}

	free((char *) ImageBuffer);
    }
    else {
        for (CountZoomJ = ZoomFactor, j = ScreenTop, l = DeviceTop;
	     j < ScreenHeight && l <= DeviceMaxY; l++) {
	    Line = ScreenBuffer[j];

	    /* Abort drawing if space bar was pressed: */
	    if (MyKbHit() && GetKey() == ' ') break;

	    for (CountZoomI = ZoomFactor, i = ScreenLeft, k = DeviceLeft;
	         i < ScreenWidth && k <= DeviceMaxX;) {
	        putpixel(k++, l, Line[i]);

	        if (!--CountZoomI) {
		    /* Go to next column: */
		    i++;
		    CountZoomI = ZoomFactor;
	        }
	    }

	    if (!--CountZoomJ) {
	        /* Go to next row: */
	        j++;
	        CountZoomJ = ZoomFactor;
	    }
        }
    }
}

/******************************************************************************
* Walks along the current image, while printing pixel value and position.     *
* 4 arrows may be used, and any other key will abort this operation	      *
******************************************************************************/
static void DoCursorMode(GifRowType *ScreenBuffer,
		int ScreenLeft, int ScreenTop, int DeviceLeft, int DeviceTop)
{
    int GetK, DeviceRight, DeviceBottom, x, y, Step;
    GifPixelType Pixel;
    char s[80];

    DeviceRight = DeviceLeft + (ScreenWidth - ScreenLeft) * ZoomFactor;
    if (DeviceRight > DeviceMaxX) DeviceRight = DeviceMaxX;

    DeviceBottom = DeviceTop + (ScreenHeight - ScreenTop) * ZoomFactor;
    if (DeviceBottom > DeviceMaxY) DeviceBottom = DeviceMaxY;

    x = (DeviceLeft + DeviceRight) / 2;
    y = (DeviceTop + DeviceBottom) / 2;

    setwritemode(XOR_PUT);

    while (TRUE) {
	Pixel = ScreenBuffer[ScreenTop + (y - DeviceTop) / ZoomFactor]
			    [ScreenLeft + (x - DeviceLeft) / ZoomFactor];
	sprintf(s, "Color = %3d [%3d, %3d, %3d], X = %3d, Y = %3d",
		Pixel,
		ColorMap[Pixel].Red,
		ColorMap[Pixel].Green,
		ColorMap[Pixel].Blue,
		(x - DeviceLeft) / ZoomFactor,
		(y - DeviceTop) / ZoomFactor);

	setfillstyle(SOLID_FILL, BackGround);
	bar(0, 0, textwidth(s) + 2, textheight(s) + 2);

    	setcolor(ForeGround);
	outtextxy(1, 1, s);

	line(0, y, DeviceMaxX, y);
	line(x, 0, x, DeviceMaxY);
	GetK = GetKey();
	line(0, y, DeviceMaxX, y);
	line(x, 0, x, DeviceMaxY);

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
		setwritemode(COPY_PUT);
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
