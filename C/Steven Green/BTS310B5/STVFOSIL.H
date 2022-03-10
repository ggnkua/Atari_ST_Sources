#ifndef H_STVFOSSIL
#define H_STVFOSSIL
/*
 * ST VFossil.h
 *
 * Video Fossil, see FSC-0021
 *
 * (C)1990 STeVeN W Green
 *
 * Fido 2:255/355, FNET 1004
 *
 * This was written as part of my port of Binkley 2.40
 *
 * All the licence agreements apply as in BT.C
 */

typedef struct {
   int   cur_start;
   int   cur_end;
   int   cur_wid;
   int   cur_attr;
} CURSOR, *CURSORP;

typedef CURSOR far *PVIOCURSORINFO;

typedef struct _VIOCONFIGINFO { /* vioin */
	unsigned int  cb     ;
	unsigned int  adapter;
	unsigned int  display;
	unsigned long	cbMemory;
} VIOCONFIGINFO;

typedef VIOCONFIGINFO *PVIOCONFIGINFO;

typedef struct _VIOMODEINFO {   /* viomi */
	unsigned int cb;
	unsigned char  fbType;
	unsigned char  color;
	unsigned int col;
	unsigned int row;
	unsigned int hres;
	unsigned int vres;
	unsigned char  fmt_ID;
	unsigned char  attrib;
} VIOMODEINFO;

typedef VIOMODEINFO *PVIOMODEINFO;

void VioWrtCellStr(BYTEBUFP, size_t, int, int, int);

#endif	/* H_STVFOSSIL */
