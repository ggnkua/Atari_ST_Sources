#include <aes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "listfont.h"
/************************************************************************/
/* BYTE        8 bit value */
/* INT8        8 bit signed integer */
/* INT16  16 bit signed integer */
/* INT32  32 bit signed integer */
/* CARD8  8 bit unsigned integer */
/* CARD16 16 bit unsigned integer */
/* CARD32 32 bit unsigned integer */
/* BOOL        True or False */
/* STRING8     LISTofCARD8 */
/* STRING16    LISTofCHAR2B */
/* POINT  [X,Y:INT16] */
/* RECTANGLE   [X,Y:INT16  width,height:CARD16] */
/************************************************************************/
/************************************************************************/
typedef unsigned char BYTE;   /* 8 bit value */
typedef char INT8;     /*8 bit signed integer */
typedef short  INT16;  /*16 bit signed integer */
typedef  long  INT32;    /*32 bit signed integer */
typedef unsigned char CARD8;  /*8 bit unsigned integer */
typedef unsigned short CARD16; /*16 bit unsigned integer */
typedef unsigned long CARD32; /*32 bit unsigned integer */
typedef int BOOL;             /*True or False */
typedef CARD8 *STRING8;        /*LISTofCARD8 */
typedef CARD16 *STRING16;     /*LISTofCHAR2B */
typedef struct {
        INT16 X,Y;
}POINT;       /*POINT[X,Y:INT16] */
typedef struct 
{
        INT16 X,Y; 
        CARD16 width,height;
} RECTANGLE;    /*[X,Y:INT16  width,height:CARD16] */

/************************************************************************/

typedef INT16 FWord;          /* signed distances in the em-square */
typedef CARD16 uFWord;        /* unsigned distances in the em-square */
typedef INT32 Fixed;          /* signed 16.16 fixed point */
typedef INT16 F2Dot14;        /* signed 2.14 fixed point */
typedef CARD8 DateTime[8];    /* International date (8-byte field) */

/************************************************************************/

#define TTF_INT32(p) ((INT32)(((INT32)(((CARD8 *)p)[0]) << 24) \
                     | ((INT32)(((CARD8 *)p)[1]) << 16) \
                     | ((INT32)(((CARD8 *)p)[2]) << 8) \
                     | ((INT32)(((CARD8 *)p)[3]))))
                
#define TTF_CARD32(p) ((CARD32)(((CARD32)(((CARD8 *)p)[0]) << 24) \
                    | ((CARD32)(((CARD8 *)p)[1]) << 16) \
                    | ((CARD32)(((CARD8 *)p)[2]) << 8) \
                    | ((CARD32)(((CARD8 *)p)[3]))))

#define TTF_INT16(p) ((INT16)(((INT16)(((CARD8 *)p)[0]) << 8) \
                     | ((INT16)(((CARD8 *)p)[1]))))

#define TTF_CARD16(p) ((CARD32)(((CARD16)(((CARD8 *)p)[0]) << 8) \
                    | ((CARD16)(((CARD8 *)p)[1]))))

#define TTF_FWord(p) ((FWord)TTF_INT16(p))
#define TTF_uFWord(p) ((uFWord)TTF_CARD16(p))
#define TTF_Fixed(p) ((Fixed)TTF_INT32(p))
#define TTF_F2Dot14(p) ((F2Dot14)TTF_INT16(p))

/************************************************************************/

typedef struct tag_ttfOffsetTable
{
  Fixed sfntVersion;          /* 0x00010000 for version 1.0. */
  CARD16 numTables;      /* Number of tables. */ 
  CARD16 searchRange;         /* (Maximum power of 2 <= numTables) x 16. */
  CARD16 entrySelector;       /* Log2(maximum power of 2 <= numTables) */
  CARD16 rangeShift;          /* NumTables x 16-searchRange. */
} ttfOffsetTable;

/************************************************************************/

typedef struct tag_ttfTableDirectory
{
  CARD32 tag;            /* 4-byte identifier */
  CARD32 checkSum;       /* CheckSum for this table */
  CARD32 offset;         /* Offset from the beginning of the file */
  CARD32 length;         /* Length of this table */
} ttfTableDirectory;

/************************************************************************/

typedef struct tag_ttfFontHeader
{ 
  Fixed version;         /* Table version number            */
  Fixed fontRevision;         /* Set by font manufacturer.       */
  CARD32 checkSumAdjustment;  /* To compute: set it to 0, sum the     */
                    /* entire font as CARD32, then store    */
                    /* 0xB1B0AFBA - sum.               */
  CARD32 magicNumber;         /* Set to 0x5F0F3CF5.              */
  CARD16 flags;               /* Bit 0 - baseline for font at y=0;    */
                    /* Bit 1 - left sidebearing at x=0;     */
                    /* Bit 2 - instructions may be          */
                    /*         dependant on point16 size;   */
                    /* Bit 3 - force ppem to integer values */
                    /*         for all internal scaler math */
                    /*         may use fractional ppem      */
                    /*         sizes if this bit is clear;  */
                    /* Bit 4 - instructions may alter  */
                    /*         advance width (i.e., the     */
                    /*         advance widths might not     */
                    /*         scale linearly);        */
                    /* Note: All other bits must be zero.   */
  CARD16 unitsPerEm;          /* Valid range is from 16 to 16384 */
  DateTime created;      /* International date (8-byte field).   */
  DateTime modified;          /* International date (8-byte field).   */
  FWord xMin, yMin, xMax, yMax;    /* For all glyph bounding boxes.   */
  CARD16 macStyle;       /* Bit 0 - bold (if set to 1)      */
                    /* Bit 1 - italic (if set to 1)         */
                    /* Bits 2-15 reserved (set to 0).  */
  CARD16 lowestRecPPEM;       /* Smallest readable size in pixels.    */
  short fontDirectionHint;    /* 0 Fully mixed directional glyphs;    */
                    /* 1 Only strongly lseft to right; */
                    /* 2 Like 1 but also contains neutrals  */
                    /* -1 Only strongly right to left; */
                    /* -2 Like -1 but also contains neutrals*/
  short indexToLocFormat;     /* 0 for short offsets, 1 for CARD32.   */
  short glyphDataFormat; /* 0 for current format.      */
} ttfFontHeader;

/************************************************************************/

typedef struct tag_ttfGlyphData
{ 
  CARD16 numberOfContours;    /* If the number of contours is greater */
                    /* than or equal to zero, this is a     */
                    /* single glyph; if negative, this is a */
                    /* composite glyph.           */
  FWord xMin, yMin;      /* Minimum x and yfor coordinate data.  */
  FWord xMax, yMax;      /* Maximum x for coordinate data.  */
} ttfGlyphData;

/************************************************************************/

typedef struct tag_ttfMaxProfile
{
  Fixed version;         /* Version, 0x00010000 for version 1.0 */
  CARD16 numGlyphs;      /* The number of glyphs in the font */
  CARD16 maxPoints;      /* Maximum points in a non-composite glyph */
  CARD16 maxContours;         /* Maximum contours in a non-composite glyph */
  CARD16 maxCompositePoints;    /* Maximum points in a composite glyph. */
  CARD16 maxCompositeContours;  /* Maximum contours in a composite glyph. */
  CARD16 maxZones;       /* 1 if instructions do not use the twilight */
                    /* zone   (Z0), or 2 if instructions do use */
                    /* Z0; should be set to 2 in most cases. */
  CARD16  maxTwilightPoints;  /* Maximum points used in Z0. */
  CARD16  maxStorage;         /* Number of Storage Area locations. */
  CARD16  maxFunctionDefs;    /* Number of FDEFs. */
  CARD16  maxInstructionDefs; /* Number of IDEFs. */
  CARD16  maxStackElements;   /* Maximum stack depth */
                    /* This includes Font and CVT Programs, as */
                    /* well as the instructions for each glyph.. */
  CARD16  maxSizeOfInstructions;/* Maximum byte count for glyph instructions */
  CARD16  maxComponentElements; /* Maximum number of composites referenced */
                    /* at "top level" for any composite glyph. */
  CARD16  maxComponentDepth;  /* Maximum levels of recursion; 1 for */
                    /* simple components. */
} ttfMaxProfile;

typedef struct tag_nameData
{
     CARD16    formatSelector;
     CARD16    numberNameRecs;
     CARD16    storageOffset;
} ttfNameData;

typedef struct tag_nameRec
{
     CARD16    platformID;
     CARD16    platformSpecEncID;
     CARD16    languageID;
     CARD16    nameID;
     CARD16    stringLen;
     CARD16    stringOffset;
} ttfNameRec;     
/************************************************************************/

typedef struct tag_ttfHandle
{
  size_t fileLength;
  const BYTE *fileData;

  const ttfOffsetTable *offsetTable;

  long numTables;
  const ttfTableDirectory *tableDirectory;

  const ttfFontHeader *fontHeader;

  const char *baseGlyphData;

  const char *location;

  const ttfMaxProfile *maxProfile;

  const ttfNameData *nameData;

  const ttfNameRec *nameRecs;

  const char *nameStringStore;

} ttfHandle;

/************************************************************************/

#define TTFPOINT_ON 1

typedef struct tag_ttfPoint
{
  long x, y;
  long flags;
} ttfPoint;

/************************************************************************/

typedef struct tag_ttfGlyph
{
  long xMin, yMin, xMax, yMax;

  long nContours;

  unsigned endPoints[64];

  long nPoints;

  ttfPoint points[1024];
} ttfGlyph;

/************************************************************************/

typedef struct tag_ttfRenderList
{
  long nColumns;
  short columns[64];
  BOOL on[64];
} ttfRenderList;

/************************************************************************/

#define TTFMAGIC 0x5F0F3CF5
#define TTFCHECKSUMADJ 0xB1B0AFBA

/************************************************************************/

#define FRACTION 64
#define FRACTMASK 63

#define SCALE (FRACTION/16)

#define TERMVAL (FRACTION/2)

#define DEPTH 10

/************************************************************************/

static BOOL readTables(ttfHandle *handle, char *node, FILE *fpList, short *filename, short mode);

/************************************************************************/


/************************************************************************/

/***********************************************************************
  Read most of the interesting tables from the TrueType font file.
  Currently, the offset table and the tables relevant to the drawing
  of glyphs are read.

  This would be a good place to insert code for reading the Postscript
  metrics table.

  */

ttfNameData nameData;
ttfNameRec *pNameRec;


static BOOL readTables(ttfHandle *handle, char *node, FILE *fpList, short *filename, short mode)
{
  int i,c;
  char mystr[250], *pch;

  pNameRec=NULL;
  handle->offsetTable = (ttfOffsetTable *)handle->fileData;


  handle->numTables = TTF_CARD16(&handle->offsetTable->numTables);

  handle->tableDirectory = (ttfTableDirectory *)
    (handle->fileData + sizeof(ttfOffsetTable));

  for (i = 0; i < handle->numTables; i++)
  {

    switch (TTF_CARD32(&handle->tableDirectory[i].tag))
    {
    case 'glyf':
      handle->baseGlyphData = 
     (handle->fileData + TTF_CARD32(&handle->tableDirectory[i].offset));
      break;

    case 'head':
      handle->fontHeader = (ttfFontHeader *)
     (handle->fileData + TTF_CARD32(&handle->tableDirectory[i].offset));
      break;

    case 'loca':
      handle->location = 
     (handle->fileData + TTF_CARD32(&handle->tableDirectory[i].offset));
      break;

    case 'maxp':
      handle->maxProfile = (ttfMaxProfile *)
     (handle->fileData + TTF_CARD32(&handle->tableDirectory[i].offset));
      break;

    case 'name':

      handle->nameData = &nameData;
      pch=(char *)(handle->fileData + TTF_CARD32(&handle->tableDirectory[i].offset));
      memcpy((char *)&nameData,pch,sizeof(ttfNameData));

      pNameRec=(ttfNameRec *)malloc(sizeof(ttfNameRec)* handle->nameData->numberNameRecs);
      if (pNameRec)
      {
           memcpy((char *)pNameRec,pch + sizeof(ttfNameData),
                   sizeof(ttfNameRec) * handle->nameData->numberNameRecs);
    
           handle->nameRecs=pNameRec;

           handle->nameStringStore = (char *)
                   (pch + handle->nameData->storageOffset); 
      }
      else
      {
          form_alert(1,"[1][Couldn't allocate |enough memory][Ok]");
          return 1;
      }
      break;


    }

  }

  if (handle->baseGlyphData == NULL)
  {
    /* fprintf(stderr, "'glyf' table missing\n"); */
    return 0;
  }
  if (handle->fontHeader == NULL)
  {
    /* fprintf(stderr, "'head' table missing\n"); */
    return 0;
  }
  if (handle->location == NULL)
  {
    /* fprintf(stderr, "'loca' table missing\n"); */
    return 0;
  }
  if (handle->maxProfile == NULL)
  {
    /* fprintf(stderr, "'maxp' table missing\n"); */
    return 0;
  }

  if (handle->nameData == NULL)
  {
    /* fprintf(stderr, "'name' table missing\n"); */
    return 0;
  }

  if (handle->nameData->numberNameRecs)
  {
     for (c=0;c<handle->nameData->numberNameRecs;c++)
     {
          if (handle->nameRecs[c].platformID >0 && 
               handle->nameRecs[c].platformID <3 
               && handle->nameRecs[c].nameID==4)
          {
               strncpy(mystr,
                    handle->nameStringStore+handle->nameRecs[c].stringOffset,
                    handle->nameRecs[c].stringLen);
               mystr[handle->nameRecs[c].stringLen]=0;
               print_to_list(fpList, filename, node, mystr, mode);
               break;
          }

     }
  }  
  if (pNameRec) free(pNameRec);
  return 0;
}


int ttfList(char *fn, char *node, size_t size, FILE *fpList, short mode)
{
  ttfHandle *handle;
  FILE *fp;
  BYTE *fileData;
  size_t readlength;
  int ret;

  if ((handle = malloc(sizeof(ttfHandle))) == NULL)
  {
     form_alert(1,"[1][Couldn't allocate |enough memory][Ok]");

    return 1;
  }
  memset(handle, 0, sizeof(ttfHandle));

  if ((fp = fopen(fn, "rb")) == NULL)
  {
    free(handle);
    return 0;
  }
  
  handle->fileLength = size;

  if ((fileData = malloc(handle->fileLength)) == NULL)
  {
     form_alert(1,"[1][Couldn't allocate |enough memory][Ok]");
    fclose(fp);
    free(handle);
    return 1;
  }

  /* Poor man's mmap, read everything into memory */

  readlength=fread(fileData, 1, handle->fileLength, fp);
  if (readlength != handle->fileLength)
  {
    fclose(fp);
    free(handle);
    free(fileData);
    return 0;
  }

  handle->fileData = fileData;

  fclose(fp);

  ret = readTables(handle, node, fpList, fn, mode);
  free(handle);
  free(fileData);

  return ret;
}


