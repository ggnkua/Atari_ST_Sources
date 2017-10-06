
/*
 * whirlgif.h
 *
 * Copyright (C) 1995,1996 by Kevin Kadow
 * Copyright (C) 1990,1991,1992 by Mark Podlipec. 
 * All rights reserved.
 *
 * This software may be freely copied, modified and redistributed
 * without fee provided that this copyright notice is preserved 
 * intact on all copies and modified copies.
 * 
 * There is no warranty or other guarantee of fitness of this software.
 * It is provided solely "as is". The author(s) disclaim(s) all
 * responsibility and liability with respect to this software's usage
 * or its effect upon hardware or computer systems.
 *
 */

/* Default amount of inter-frame time */
#define DEFAULT_TIME 10
/* If set to 1, Netscape 'loop' code will be added by default */
#define DEFAULT_LOOP 0
/* If set to 1, use the colormaps from all images, not just the first */
#define DEFAULT_USE_COLORMAP 0

#include <stdio.h>


#define BIGSTRING 256
#define LONG int
#define ULONG unsigned int
#define BYTE char
#define UBYTE unsigned char
#define SHORT short
#define USHORT unsigned short
#define WORD short int
#define UWORD unsigned short int

#ifndef TRUE
#define TRUE 1
#endif
#ifndef FALSE
#define FALSE 0
#endif

/* Used in calculating the transparent color */
#define TRANS_NONE 1
#define TRANS_RGB 2
#define TRANS_MAP 3

#define DISP_NONE 0
#define DISP_NOT  1
#define DISP_BACK 2
#define DISP_PREV 4
/* set default disposal method here to any of the DISP_XXXX values */
#define DEFAULT_DISPOSAL DISP_NONE

typedef struct
{
 int type;
 UBYTE valid;
 UBYTE map;
 UBYTE red;
 UBYTE green;
 UBYTE blue;
 } Transparency;

typedef struct
{
 Transparency trans;
 int left;
 int top;
 unsigned int time;
 unsigned short disposal;
} Global;

typedef struct
{
 int width;
 int height;
 UBYTE m;
 UBYTE cres;
 UBYTE pixbits;
 UBYTE bc;
} GIF_Screen_Hdr; 

typedef union 
{
 struct
 {
  UBYTE red;
  UBYTE green;
  UBYTE blue;
  UBYTE pad;
 } cmap;
 ULONG pixel;
} GIF_Color;

typedef struct
{
 int left;
 int top;
 int width;
 int height;
 UBYTE m;
 UBYTE i;
 UBYTE pixbits;
 UBYTE reserved;
} GIF_Image_Hdr;

typedef struct 
{
 UBYTE valid;
 UBYTE data;
 UBYTE first;
 UBYTE res;
 int last;
} GIF_Table;


