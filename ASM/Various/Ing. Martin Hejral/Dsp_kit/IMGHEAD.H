/**************************************************************
*************    I M A G E    L I B R A R Y     ***************
***************************************************************
******* by Martin Hejral ****** last update 31.12.1995 ********
***************************************************************
******** - definition of image types and constants - **********
******** ( prototypes of procedures in <imgproc.h> ) **********
**************************************************************/

#define __IMGLIB__	"Image Library v.0.16 beta"

/*************************************************************/

#define MAX_FONTS	8

/*************************************************************/

#ifndef malloc
#include <stdlib.h>
#endif

#ifndef FILE
#include <stdio.h>
#endif

#ifndef strncmp
#include <string.h>
#endif

#ifndef max
#define max(x,y)	((x<y) ? (y) : (x))
#endif

#define min(a,b)	((a<b) ? (a) : (b))



/**************************************************************/

typedef unsigned char BYTE;
typedef unsigned int  WORD;
typedef unsigned long LONG;

typedef struct {
	WORD Red, Green, Blue, Filter;
} IMAGE_COLOUR;

typedef struct {
  	BYTE red, green, blue;
} RGB;

/*** common image format ***/
typedef struct
{
	int width, height;  		/* bitmap width & height */
	long colours;       		/* number of colours */
	IMAGE_COLOUR *colour_map;	/* table of RGB values */
	union 
	{
		RGB **rgb_lines;		/* direct colours */
		BYTE **map_lines;		/* indexed colours */
	} data;
	WORD *map;	/* pointer to bitmap in screen format */
} IMAGE;

/*** screen parameters ***/
typedef struct {
		WORD *adr;		/* adr. of screen memory */
		int width,height;	/* of screen */
		int bitplanes;
} SCREEN;

/*** type for reading IFF files ***/
typedef struct Chunk_Header_Struct {
   long name, size;
} CHUNK_HEADER;

/*** 8bit array for joystick state ***/
typedef struct {
	unsigned fire : 1;
	unsigned xx : 3;
	unsigned rt : 1;
	unsigned lt : 1;
	unsigned dn : 1;
	unsigned up : 1;
} BIT8;

/**************************************************************/

extern handle;  		/* VDI handle */

/***   P U B L I C   V A R I A B L E S    defined in IMGLIB ***/

extern int xm,ym,cm;	/* screen size & colours */
extern int bitplanes;	/* number of colour planes */

extern IMAGE NIMAGE;	/* NULL image */
extern IMAGE_COLOUR rgb_old[256];	/* saved system palette */

/*** table for conversion between VDI and real colour index ***/
extern BYTE colour_vdi[256],colour_real[256];

/********************* end of IMGHEAD.H ***********************/
