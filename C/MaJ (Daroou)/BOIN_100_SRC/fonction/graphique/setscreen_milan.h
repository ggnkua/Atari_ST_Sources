/* -------------------------------------- */
/*      New  SETSCREEN MILAN TOS          */
/*             and CT060                  */
/* -------------------------------------- */
/* defines des nouvelles commandes de la  */
/* fonction XBIOS setscreen() disponible  */
/* sur MilanTOS et CT060 Radeon           */
/* -------------------------------------- */
/*  MaJ : 08 aout 2017                    */
/*  Daroou <<Renaissance>>                */
/* -------------------------------------- */



/* Vsetscreen New modes */

/* http://toshyp.atari.org/en/Screen_functions.html#Setscreen_2C_20Milan */
/* http://toshyp.atari.org/en/Screen_functions.html#Setscreen_2C_20ct60  */


/* Vsetscreen(void *par1, void *par2, short rez, short command) */
/* with rez always 0x564E 'VN' (Vsetscreen New) in CT060        */
/* with rez always 0x4D49 'MI' (MIlan) in Milan OS              */



/* -------------------------------------- */
/* TOShyp 4.5.19 Setscreen, ct60          */
/* TOShyp 4.5.18 Setscreen, Milan         */
/* -------------------------------------- */

#define MI_MAGIC      /*(0x4D49)*/   (('M' << 8) | 'I')
#ifndef CT060_MAGIC
#define CT060_MAGIC   /*(0x564E)*/   (('V' << 8) | 'N')
#endif


/* The following values are defined for command: */
#ifndef CMD_GETMODE
/* Already present in CT60.H */
#define CMD_GETMODE    0
#define CMD_SETMODE    1
#define CMD_GETINFO    2
#define CMD_ALLOCPAGE  3
#define CMD_FREEPAGE   4
#define CMD_FLIPPAGE   5
#define CMD_ALLOCMEM   6
#define CMD_FREEMEM    7
#define CMD_SETADR     8
#define CMD_ENUMMODES  9
#define CMD_TESTMODE   10
#define CMD_COPYPAGE   11
#define CMD_FILLMEM    12
#define CMD_COPYMEM    13
#define CMD_TEXTUREMEM 14
#define CMD_GETVERSION 15
#define CMD_LINEMEM    16
#define CMD_CLIPMEM    17
#define CMD_SYNCMEM    18
#define CMD_BLANK      19
#endif


 
/* -------------------------------------- */
/* TOShyp 4.21.21 SCREENINFO              */
/* -------------------------------------- */

/* scrFlags */
 #define SCRINFO_OK 1

/* scrClut */
 #define NO_CLUT    0
 #define HARD_CLUT  1
 #define SOFT_CLUT  2

/* scrFormat */
 #define INTERLEAVE_PLANES  0
 #define STANDARD_PLANES    1
 #define PACKEDPIX_PLANES   2

/* bitFlags */
 #define STANDARD_BITS  1
 #define FALCON_BITS    2
 #define INTEL_BITS     8

typedef struct screeninfo
{
  int32 size;        /* Size of structur           */
  int32 devID;       /* Device ID number           */
  int8  name[64];    /* Friendly name of Screen    */
  int32 scrFlags;    /* Some flags                 */
  int32 frameadr;    /* Adress of framebuffer      */
  int32 scrHeight;   /* Visible X res              */
  int32 scrWidth;    /* Visible Y res              */
  int32 virtHeight;  /* Virtual X res              */
  int32 virtWidth;   /* Virtual Y res              */
  int32 scrPlanes;   /* color Planes               */
  int32 scrColors;   /* # of colors                */
  int32 lineWrap;    /* # of bytes to next line    */
  int32 planeWarp;   /* # of bytes to next plane   */
  int32 scrFormat;   /* Screen format              */
  int32 scrClut;     /* Type of clut               */
  int32 redBits;     /* Mask of Red Bits           */
  int32 greenBits;   /* Mask of Green Bits         */
  int32 blueBits;    /* Mask of Blue Bits          */
  int32 alphaBits;   /* Mask of Alpha Bits         */
  int32 genlockBits; /* Mask of Genlock Bits       */
  int32 unusedBits;  /* Mask of unused Bits        */
  int32 bitFlags;    /* Bits organisation flags    */
  int32 maxmem;      /* Max. memory in this mode   */
  int32 pagemem;     /* Needed memory for one page */
  int32 max_x;       /* Max. possible width        */
  int32 max_y;       /* Max. possible heigth       */
} SCREENINFO;



/* -------------------------------------- */
/* TOShyp 4.21.25 SCRMEMBLK               */
/* -------------------------------------- */
 
 #define BLK_ERR      0
 #define BLK_OK       1
 #define BLK_CLEARED  2

typedef struct _scrblk
{
  int32 size;              /* Size of strukture                  */
  int32 blk_status;        /* Status bits of blk                 */
  int32 blk_start;         /* Start adress                       */
  int32 blk_len;           /* Length of memblk                   */
  int32 blk_x;             /* X pos in total screen              */
  int32 blk_y;             /* Y pos in total screen              */
  int32 blk_w;             /* Width                              */
  int32 blk_h;             /* Height                             */
  int32 blk_wrap;          /* Width in bytes, from: 2000-01-13   */
} SCRMEMBLK;




/*

http://www.megast.info/Milan_coding_docs.html

---------------------------------------
LINEA functiones (for information only)
---------------------------------------

All LineA functions work on the Milan too and use the
hardware functiones if available, otherwise it will be done
via software.



---------------------------------------
Standard graphic modes
---------------------------------------

The following screen modes are defined for the low lever driver. The ID numbers
are fixed and won't be changed.
All additional defined modes in MVDI.CNF, which aren't available
from this list recieve ID numbers starting from 0x2000.
These numbers are dynamic and may change after a restart.
If a standard mode is modified in the MVDI.CNF file the
ID number won't change.

DevID X-Res Y-Res Bits/Pixel Flags
0x1000 640 400 1 INTERLEAVE
0x1001 640 400 8 PIXPACKED
0x1002 640 400 15 PIXPACKED
0x1003 640 400 16 PIXPACKED
0x1004 640 400 32 PIXPACKED
0x1010 640 480 1 INTERLEAVE
0x1011 640 480 8 PIXPACKED
0x1012 640 480 15 PIXPACKED
0x1013 640 480 16 PIXPACKED
0x1014 640 480 32 PIXPACKED
0x1020 800 608 1 INTERLEAVE
0x1021 800 608 8 PIXPACKED
0x1022 800 608 15 PIXPACKED
0x1023 800 608 16 PIXPACKED
0x1024 800 608 32 PIXPACKED
0x1030 1024 768 1 INTERLEAVE
0x1031 1024 768 8 PIXPACKED
0x1032 1024 768 15 PIXPACKED
0x1033 1024 768 16 PIXPACKED
0x1034 1024 768 32 PIXPACKED
0x1040 1152 864 1 INTERLEAVE
0x1041 1152 864 8 PIXPACKED
0x1043 1152 864 15 PIXPACKED
0x1043 1152 864 16 PIXPACKED
0x1044 1152 864 32 PIXPACKED
0x1050 1280 1024 1 INTERLEAVED
0x1051 1280 1024 8 PIXPACKED
0x1052 1280 1024 15 PIXPACKED
0x1053 1280 1024 16 PIXPACKED
0x1054 1280 1024 32 PIXPACKED
0x1060 1600 1200 1 INTERLEAVED
0x1061 1600 1200 8 PIXPACKED
0x1062 1600 1200 15 PIXPACKED
0x1063 1600 1200 16 PIXPACKED
0x1064 1600 1200 32 PIXPACKED

*/

