/*
	Milan VDI driver defines

	Copyright (C) 2002	Patrice Mandin

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
*/

#ifndef _MVDI_H
#define _MVDI_H

#include <mint/falcon.h>	/* for trap_14_xxx macros */

/*--- Defines ---*/

/* Cookies */
#define C__MIL 0x5F4D494CL
#define C__VDI 0x5F564449L

/* Vsetscreen() parameters */
#define MI_MAGIC	0x4D49 

enum {
	CMD_GETMODE=0,
	CMD_SETMODE,
	CMD_GETINFO,
	CMD_ALLOCPAGE,
	CMD_FREEPAGE,
	CMD_FLIPPAGE,
	CMD_ALLOCMEM,
	CMD_FREEMEM,
	CMD_SETADR,
	CMD_ENUMMODES
};

enum {
	ENUMMODE_EXIT=0,
	ENUMMODE_CONT
};

enum {
	BLK_ERR=0,
	BLK_OK,
	BLK_CLEARED
};

/* scrFlags */ 
#define SCRINFO_OK 1 

/* scrClut */ 
enum {
	NO_CLUT=0,
	HARD_CLUT,
	SOFT_CLUT
};

/* scrFormat */ 
enum {
	INTERLEAVE_PLANES=0,
	STANDARD_PLANES,
	PACKEDPIX_PLANES
};

/* bitFlags */ 
#define STANDARD_BITS  1 
#define FALCON_BITS   2 
#define INTEL_BITS   8 

/*--- Structures ---*/

typedef struct _scrblk 
{ 
	unsigned long size;    /* size of strukture  */ 
	unsigned long blk_status;  /* status bits of blk */ 
	unsigned long blk_start;   /* Start Adress   */ 
	unsigned long blk_len;   /* length of memblk  */ 
	unsigned long blk_x;    /* x pos in total screen*/ 
	unsigned long blk_y;    /* y pos in total screen */ 
	unsigned long blk_w;    /* width     */ 
	unsigned long blk_h;    /* height    */ 
	unsigned long blk_wrap;   /* width in bytes  */ 
} SCRMEMBLK; 

typedef struct screeninfo 
{ 
	unsigned long size;    /* Size of structur   */ 
	unsigned long devID;    /* device id number   */ 
	unsigned char name[64];   /* Friendly name of Screen */ 
	unsigned long scrFlags;   /* some Flags    */ 
	unsigned long frameadr;   /* Adress of framebuffer */ 
	unsigned long scrHeight;   /* visible X res   */ 
	unsigned long scrWidth;   /* visible Y res   */ 
	unsigned long virtHeight;  /* virtual X res   */ 
	unsigned long virtWidth;   /* virtual Y res   */ 
	unsigned long scrPlanes;   /* color Planes    */ 
	unsigned long scrColors;   /* # of colors    */ 
	unsigned long lineWrap;   /* # of Bytes to next line  */ 
	unsigned long planeWarp;   /* # of Bytes to next plane */ 
	unsigned long scrFormat;   /* screen Format    */ 
	unsigned long scrClut;   /* type of clut    */ 
	unsigned long redBits;   /* Mask of Red Bits   */ 
	unsigned long greenBits;   /* Mask of Green Bits  */ 
	unsigned long blueBits;   /* Mask of Blue Bits  */ 
	unsigned long alphaBits;   /* Mask of Alpha Bits  */ 
	unsigned long genlockBits;  /* Mask of Genlock Bits  */ 
	unsigned long unusedBits;  /* Mask of unused Bits  */ 
	unsigned long bitFlags;   /* Bits organisation flags */ 
	unsigned long maxmem;   /* max. memory in this mode */ 
	unsigned long pagemem;   /* needed memory for one page */ 
	unsigned long max_x;    /* max. possible width   */ 
	unsigned long max_y;    /* max. possible heigth  */ 
} SCREENINFO; 

/*--- Predefined video modes ---*/

#define NUM_MVDIMODELIST 35

typedef struct {
	int deviceid;
	int width;
	int height;
	int bpp;
	int format;
} mvdimode_t;

extern mvdimode_t mvdimodelist[NUM_MVDIMODELIST];

/*--- Functions prototypes ---*/

#define Validmode(mode)	\
	(short)trap_14_ww((short)0x5f,(short)(mode))

#endif /* _MVDI_H */
