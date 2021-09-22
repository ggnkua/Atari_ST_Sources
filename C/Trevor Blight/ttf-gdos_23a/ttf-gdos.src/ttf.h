/***** (C) 1996-2002, Trevor Blight *****
*
*  $Id: ttf.h 3274 2021-08-28 13:12:54Z trevor $
*
*  common definitions for ttf program
*
*
* ttf-gdos program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public License
* as published by the Free Software Foundation; either version 2
* of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*
*
*
******************/

typedef char            CHAR;       /* 8 bit signed integer */
typedef unsigned short  USHORT;     /* 16 bit unsigned integer */
typedef short           SHORT;      /* 16 bit signed integer */
typedef unsigned long   ULONG;      /* 32 bit unsigned integer */
typedef long            LONG;       /* 32 bit signed integer */
typedef int32           Fixed;      /* 16.16 bit signed fixed point number */
typedef int             FUnit;      /* smallest measurable distance in em space */
typedef int16           FWord;      /* describes a quantity in FUnits */
typedef uint16          uFWord;     /* describes a quantity in FUnits */
typedef int16           F2Dot14;    /* 2.14 signed fixed point number */
typedef int16           PCOORD;     /* 10.6 fixed point format for pixel coordinates */
typedef int32           F26Dot6;    /* 26.6 signed fixed point number */


/****** global font info ******/


typedef struct {
   Fixed    vers;
   USHORT   numGlyphs;
   USHORT   maxPoints;
   USHORT   maxContours;
   USHORT   maxCompositepoints;
   USHORT   maxCompositeContours;
   USHORT   maxZones;
   USHORT   maxTwilightPoints;
   USHORT   maxStorage;
   USHORT   maxFunctionDefs;
   USHORT   maxInstructionDefs;
   USHORT   maxStackElements;
   USHORT   maxSizeOfInstructions;
   USHORT   maxComponentElements;
   USHORT   maxComponentDepth;
} MAXP_REC;

typedef struct {
   union { char c[4];
           ULONG u; } tag;     /* 4-char identifier */
   uint32 checkSum;            /* checksum for this table */
   uint32 offset;              /* offset from start of file */
   uint32 length;              /* length of this table */
} tableDirectoryRecord;


typedef struct {
   uint32   glyphLoc[256];
   uint16   charMap[256];
   int16    leftsb[256];
   int16    advWid[256];
} tTTF_TBL;


/* one of these for each ttf */

typedef struct {
   const MAXP_REC maxp;
   tableDirectoryRecord cmap_dir;
   tableDirectoryRecord loca_dir;
   tableDirectoryRecord hmtx_dir;
   tableDirectoryRecord glyf_dir;
   char     font_name[32];
   BOOL     shortOffsets;
   int      numGlyphs;
   int      maxPoints;
   uint16   numberOfHMetrics;
   FWord    ttAscender;
   FWord    ttDescender;
   int16    sFamilyClass;
   FWord    yMin;
   FWord    yMax;
   uint16   unitsPerEm; /* zero <=> not set up */
   uint16   fScaleShift;
   tTTF_TBL *ptbl;	/* pointer to table data, or NULL */
} tTTF_GDATA;
extern tTTF_GDATA	*gdata;


extern uint16 ppemx, ppemy;   /* pixels per M */
extern F26Dot6 fxScale64;     /* scale factor FUnits to dots * 64 */
extern F26Dot6 fyScale64;


typedef struct {
   BYTE  flags;
   PCOORD xcoord, ycoord;
} point_Rec;

extern const void *glyfTablep;


extern void pr_cvt ( const void *tableptr, const uint32 length );
extern void pr_prep( const void *tableptr, const uint32 length );
extern void pr_fpgm( const void *tableptr, const uint32 length );
extern void run_prep( void );
extern void instruct_glyph(BYTE *program_ptr, uint16 length, char gem_char );
extern void free_interp( void );

/*************** end of ttf.h **************/
