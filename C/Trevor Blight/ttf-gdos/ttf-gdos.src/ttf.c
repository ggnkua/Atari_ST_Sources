/***** (C) 1996-2002, Trevor Blight *****
*
*  $Id: ttf.c 1.8 2001/03/23 22:09:52 tbb Exp $
*
*
* This file is part of ttf-gdos.
*
* ttf-gdos is free software; you can redistribute it and/or
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
******************************************************************
*
*  this is the ttf file manager
*  get info from true type font file
*  get a table from the ttf file,
*  process table & store relevant info
*
*  gdata is an array of true type font records.  Each record contains a small
*  amount of miscellaneous info and indexes to the cmap, loca, & htmx tables,
*  ie tables that are frequently accessed for character generation, so when
*  a character needs to be generated only the glyph data needs to be fetched
*  from disk, and its location is quickly found from data already in memory.
*
*  ttf_startup() initialises gdata[] empty
*  set_tables() sets up the cmap, loca, htmx data in the cache
*  get_ttf_data() adds data to gdata[]
*  get_glyph_data() reads the whole glyph data table into memory, this is
*     used for offset (ie width) table generation.
*  release_glyph_data() frees the glyph table.
*
**********************************/

#include <string.h>

#include <osbind.h>

#define D_SHOW 0
#define TEST_XSUM 0

#include "ttf-gdos.h"
#include "ttf-defs.h"
#include "ttf.h"

/* global ttf data */

/** cache of ttf table data **/

tTTF_GDATA	*gdata;
const void *glyfTablep;


/**************************
* get a table from the ttf file
* test checksum
*/
static tTTF_ERROR
get_table( const FILE_H fh,
           register tableDirectoryRecord *const tableDirp,
           void *const buf )
{
   assert( (tableDirp->offset&3) == 0 );  /* table aligned on long boundary */
   if( Fseek( tableDirp->offset, fh, 0 ) <= 0
   ||  Fread( fh, tableDirp->length, buf ) < tableDirp->length ) return FILE_ERR;

   /* test checksum */
   #if TEST_XSUM
   {
   register uint32 sum = 0L;
   register int32  n = tableDirp->length >> 2;	/* nr longs */
   register uint32 *p = buf;
      while( n-->0 ) sum += *p++;
      if( sum != tableDirp->checkSum ) {
         dprintf(( "%.4s: checksum error: found %8lx, expected %8lx\n",
			tableDirp->tag.c, sum, tableDirp->checkSum ));
         return FILE_ERR;
      } /* if */
   }
   #endif
   return OK;
} /* get_table() */


/*******************
*
*  set gem file name
*  use first set of apple records found
*  if no name found, do nothing
**/
static tTTF_ERROR
pr_name( const FILE_H fh, tableDirectoryRecord *tableDirp, char *name )
{
typedef struct {
   uint16 platformID;
   uint16 encodingID;
   uint16 languageID;
   uint16 NameID;
   uint16 StringLength;
   uint16 StringOffset;
} tNameRecord;

register const tNameRecord *nrp;
register int n;
uint16 platform;	/* 0 = Apple, 2 = microsoft */

register struct {
   uint16 Format;       /* format selector */
   uint16 num;          /* number of Name Records that follow */
   uint16 Offset;       /* offset to start of string storage from start of table */
   tNameRecord nRec[0]; /* list of name records */
   } * const hdrp = malloc( tableDirp->length );

   dprintf(( "name: naming table\t" ));
   *name = '\0';
   if( hdrp == NULL ) return MEM_ERR;
   if( get_table( fh, tableDirp, hdrp ) != OK ) goto file_err;

   dprintf(( "Format is %d\t", hdrp->Format ));
   dprintf(( "num is %d\t", hdrp->num ));
   dprintf(( "Offset is %x\n", hdrp->Offset ));
   n = hdrp->num;
   assert( n>0 );
   nrp = hdrp->nRec-1;
   do {
      n--;
      if( n <= 0 ) goto file_err;
      platform = (++nrp)->platformID - 1;
   } while( platform != 0 && platform != 2 || nrp->NameID < 1);
   dprintf(( "platform is %s\n", platform==0 ? "apple" : "microsoft" ));

   /* nrp points to family name (name id == 1) */

   /* nrp->encodingID == 0 => Roman Script */
   /* nrp->languageID == 0/1/2... => English/French/German... */

   /* expect name records 1..4 to follow ... */
   assert( (nrp-1)[1].NameID == 1 ); /* family name */
   assert( (nrp-1)[2].NameID == 2 ); /* sub family name (ie style) */
   assert( (nrp-1)[4].NameID == 4 ); /* family name + style, typically (nrp-1)[1]+(nrp-1)[2] */

   /** gem file name is ideally name in [0..15] + style in [16..31]  **/

   {
   register const char *tt = (const char*)hdrp+hdrp->Offset+(nrp-1)[1].StringOffset;
   register const uint16 n1 = (nrp-1)[1].StringLength;
   register uint16 nn = platform==0 ? n1 : n1/2; /* nr chars in name */
   register char *g = name;
   register int16 ng = sizeof(tGemFName);
      assert( platform != 0 || (nrp-1)->encodingID == 0 ); /* Roman Script */

      /** copy to end of family name **/
      assert( nn>0 );
      do {
	 *g++ = platform==0 ? *tt++ : (tt++, *tt++);
	 ng--;
	 if( ng==0 ) goto done;
	 nn--;
      } while( nn>0 );

      if( n1<(nrp-1)[4].StringLength ) {
	 /** need to add a style part,
	 **  ==> pad to name[16] with blanks **/
	 assert( g < name+32 );      /* at least one space remaining in name */
	 do {
	    *g++ = ' ';
	    ng--;
	 if( ng==0 ) goto done;
	 } while( ng>16 );

	 /** copy the style **/
	 nn = (nrp-1)[2].StringLength;
	 tt = (const char*)hdrp+hdrp->Offset+(nrp-1)[2].StringOffset;
	 do {
	    *g++ = platform==0 ? *tt++ : (tt++, *tt++);
	    ng--;
	    if( ng==0 ) goto done;
	    nn--;
	 } while( nn>0 );
      } /* if */

      /** finished the name, now pad to the end with nulls **/
      assert( g < name+32 );
      do {
	 *g++ = '\0';
	 ng--;
      } while( ng>0 );
done:
      assert( g == name+32 );
   }

   free( hdrp );

   dprintf(( "gem font name is \'%.32s\'\n", name ));
   assert( strlen(name) > 0 );
   /* assert(length of records = length of table); */
   return OK;

file_err:
   dprintf(( "file error reading 'name' table\n" ));
   free( hdrp );
   return FILE_ERR;
} /* pr_name() */


static tTTF_ERROR
pr_hmtx( const FILE_H fh, tTTF_GDATA *pg )
{
typedef struct {
   uFWord   advanceWidth;
   FWord    lsb;
} longHorMetric;
FWord          *leftSideBearing;
int i;
int gi;
longHorMetric *const hMetrics = malloc( pg->hmtx_dir.length );

   dprintf(( "htmx: horizontal metrics\n" ));

   if( hMetrics == NULL ) return MEM_ERR;
   if( get_table( fh, &pg->hmtx_dir, hMetrics ) != OK ) goto file_error;

   assert( pg->ptbl != NULL );

   leftSideBearing = (FWord *)(hMetrics + pg->numberOfHMetrics);

   for( i=0; i<=GEM_LAST_CH; i++ ) {
      gi = pg->ptbl->charMap[i];            /* glyph index for char i */
      if( gi < pg->numberOfHMetrics ) {
         pg->ptbl->leftsb[i] = hMetrics[gi].lsb;
         pg->ptbl->advWid[i] = hMetrics[gi].advanceWidth;
         /* dprintf(( "char %c (%d), glyph index is %d, lsb is %d, aw is %d\n",
                  isprint(i)? i : ' ', i, gi, pg->pt->leftsb[i], pg->pt->advWid[i] )); */
      }
      else {
         pg->ptbl->leftsb[i] = leftSideBearing[gi-pg->numberOfHMetrics];
         pg->ptbl->advWid[i] = hMetrics[pg->numberOfHMetrics-1].advanceWidth;
         /* dprintf(( "** char %c (%d), glyph index is %d, lsb is %d, aw is %d\n",
                  isprint(i)? i : ' ', i, gi, pg->pt->leftsb[i], pg->pt->advWid[i] )); */
      } /* if */
   } /* for */

   free( hMetrics );
   return OK;

file_error:
   dprintf(( "file error reading 'hmtx' table\n" ));
   free( hMetrics );
   return FILE_ERR;
} /* pr_hmtx() */


/** translate gem character code to apple character code for chars >= 127 **/
static const unsigned char gem2apple[] = {
   198,
#if COMPOSITE_CHARACTERS
   130, 159, 142, 137, 138, 136, 140, 141, 144, 145, 143, 149, 148, 147, 128, 129,
   131, 190, 174, 153, 154, 152, 158, 157, 216, 133, 134, 162, 163, 180, 167, 196,
   135, 146, 151, 156, 150, 132,   0,   0, 192,   0, 194,   0,   0, 193, 199, 200,
   139, 155, 175, 191, 207, 206, 203, 204, 205, 172, 171, 160, 166, 169, 168, 170,
#else
   130,   0,   0,   0,   0,   0,   0, 141,   0,   0,   0,   0,   0,   0,   0,   0,
     0, 190, 174,   0,   0,   0,   0,   0,   0,   0,   0, 162, 163, 180, 167, 196,
     0,   0,   0,   0,   0,   0,   0,   0, 192,   0, 194,   0,   0, 193, 199, 200,
     0,   0, 175, 191, 207, 206,   0,   0,   0, 172, 171, 160, 166, 169, 168, 170,
#endif
     0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
     0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0, 164,   0, 176,
     0,   0,   0, 185, 183,   0, 181,   0,   0,   0, 189,   0,   0,   0,   0,   0,
     0, 177, 179, 178,   0,   0, 214, 197, 161, 165, 225, 195,   0,   0,   0, 248
   };

/** if the id from os2 table is in the range 3072 .. 3087
**  then this is a symbolic fonts, and must not be remapped ...
**/
#define IS_SYMBOLIC(id) (((id)&0x0f00)==0x0c00)

#define GEM2APPLE(gem_char,id) ((gem_char<127)||IS_SYMBOLIC(id) ? gem_char : gem2apple[gem_char-127])

static tTTF_ERROR
pr_cmap( FILE_H fh, tTTF_GDATA *pg )
{
struct {
   uint16   version;
   uint16   numTbls;
   struct {
      uint16   platformID;
      uint16   encodeID;
      uint32    offset;
   } encode[0];
} *const cmapHdr = malloc( pg->cmap_dir.length );

struct {
   uint16 format;
   uint16 length;
   uint16 version;
   union {
      struct {
         BYTE   glyphIdArray[256];
      } Apple;
      struct {
         uint16   segCountX2;
         uint16   searchRange;
         uint16   entrySelector;
         uint16   rangeShift;
         uint16   endCount[0];
      } Microsoft;
   } type;
} *tablep;
uint16 *endCount;
uint16 *startCount;
uint16 *idDelta;
uint16 *idRangeOffset;
uint16 *glyphIdArray;

int   segCount;
int   i;
int j;
int a;

   dprintf(( "cmap: character to glyph mapping\t" ));

   if( cmapHdr == NULL ) return MEM_ERR;
   if( get_table( fh, &pg->cmap_dir, cmapHdr ) != OK ) goto file_err;

   dprintf(( "version is %d\t%d tables\n", cmapHdr->version, cmapHdr->numTbls ));

   assert( pg->ptbl != NULL );

   i = cmapHdr->numTbls;
   while( i-- > 0 ) {
      dprintf(( "table[%d]: %d platform, %d encoding, offset = %lx\n",
               i, cmapHdr->encode[i].platformID, cmapHdr->encode[i].encodeID, cmapHdr->encode[i].offset ));
      tablep = (void *)((BYTE *)cmapHdr + cmapHdr->encode[i].offset);
      dprintf(( "format is %d, length is %d, version is %d\n",
               tablep->format, tablep->length, tablep->version ));
      if( tablep->format == 0 ) {
         dprintf(( "Apple table format\n" ));
         for( a=0; a<=GEM_LAST_CH; a++ ) {
	    assert(GEM2APPLE(a,pg->sFamilyClass)<=HIGH(pg->ptbl->charMap));
            pg->ptbl->charMap[a] = tablep->type.Apple.glyphIdArray[GEM2APPLE(a,pg->sFamilyClass)];
         } /* for */
      }
      else if(tablep->format == 4 ) {
         dprintf(( "Microsoft table format\n" )); /* <<< unfinished! */
         dprintf(( "segCountX2 is %d\t", tablep->type.Microsoft.segCountX2 ));
         dprintf(( "searchRange is %d\t", tablep->type.Microsoft.searchRange ));
         dprintf(( "entrySelector is %d\t", tablep->type.Microsoft.entrySelector ));
         dprintf(( "rangeShift is %d\n", tablep->type.Microsoft.rangeShift ));
         segCount = tablep->type.Microsoft.segCountX2/2;
         endCount = tablep->type.Microsoft.endCount;
         startCount = endCount + segCount + 1;    /* + 1 for reserved pad */
         idDelta = startCount + segCount;
         idRangeOffset = idDelta + segCount;
         glyphIdArray = idRangeOffset + segCount;
         for( j=0; j<segCount; j++ ) {
            startCount[j] =  startCount[j] ;
            endCount[j] =  endCount[j] ;
            idDelta[j] =  idDelta[j] ;
            idRangeOffset[j] =  idRangeOffset[j] ;
            dprintf(( "start[%d] = %x, end[] = %x, delta = %x, offset = %x\n",
                     j, startCount[j], endCount[j], idDelta[j], idRangeOffset[j] ));
            for( a=startCount[j]; a<=endCount[j]; a++ ) {
            int c;
               if( idRangeOffset[j] != 0 ) {
                  c = *(idRangeOffset[j]/2 + (a - startCount[j]) + &idRangeOffset[j] );
                  c = c;
                  if( c != 0 ) {
                     c += idDelta[j];
                  } /* if */
               }
               else {
                  c = a + idDelta[j];
               } /* if */

               /**
               dprintf(( "glyphIdArray['%c' (%d)] = [%d] = %d\n", (isprint(a)?a:' '), a, c, glyphIdArray[c] ));
               **/
               if( a > startCount[j] + 100 ) break;
            } /* for */
         } /* for */
      }
      else {
         dprintf(( "unsupported table format\n" ));
      } /* if */

   } /* while */

   free( cmapHdr );
   return OK;

file_err:
   dprintf(( "cmap: file error reading cmap table\n" ));
   free( cmapHdr );
   return FILE_ERR;
} /* pr_cmap() */


static tTTF_ERROR
pr_loca( const FILE_H fh, tTTF_GDATA *pg )
{
int i;
void *const tableptr = malloc( pg->loca_dir.length );
   if( tableptr == NULL ) return MEM_ERR;
   if( get_table( fh, &pg->loca_dir, tableptr ) != OK ) goto file_err;

   dprintf(( "loca: index to location, offsets are %s, %d glyphs\n",
            pg->shortOffsets ? "short" : "long", pg->numGlyphs ));

   /** use index to glyph to put location of glyph into glyphLoc **/

   assert( pg->ptbl != NULL );

   if( pg->shortOffsets ) {
   const uint16 *offsets = tableptr;
      for( i=0; i<HIGH(pg->ptbl->glyphLoc); i++ ) {
         pg->ptbl->glyphLoc[i] = 2*(uint32)offsets[i];
      } /* for */
   }
   else {
   const uint32 *offsets = tableptr;
      for( i=0; i<HIGH(pg->ptbl->glyphLoc); i++ ) {
         pg->ptbl->glyphLoc[i] = offsets[i];
      } /* for */
   } /* if */

   for( i=0; i<GEM_LAST_CH; i++ ) {
      dprintf(( "offset[%d '%c'] is %ld\n", i, i<' '?' ':i, (long)pg->pt->glyphLoc[pg->pt->charMap[i]] ));
   } /* for */

   free( tableptr );
   return OK;

file_err:
   dprintf(( "file error reading 'loca' table\n" ));
   free( tableptr );
   return FILE_ERR;
} /* pr_loca() */


static tTTF_ERROR
pr_OS2( const FILE_H fh, tableDirectoryRecord *tableDirp, tTTF_GDATA *pg )
{
struct {
   uint16 version;
   int16  xAveCharWidth;
   uint16 usWeightClass;
   uint16 usWidthClass;
   int16  fsType;
   int16  ySubscriptXSize;
   int16  ySubscriptYSize;
   int16  ySubscriptXOffset;
   int16  ySubscriptYOffset;
   int16  ySuperscriptXSize;
   int16  ySuperscriptYSize;
   int16  ySuperscriptXOffset;
   int16  ySuperscriptYOffset;
   int16  yStrikeoutSize;
   int16  yStrikeoutPosition;
   int16  sFamilyClass;
   char   panose[10];
   uint32 ulCharRange[4];
   CHAR   achVendId[4];
   uint16 fsSelection;
   uint16 usFirstCharIndex;
   uint16 usLastCharIndex;
   uint16 sTypoAscender;
   uint16 sTypoDescender;
   uint16 usWinAscent;
   uint16 usWinDescent;
} *const orp = malloc( tableDirp->length );

   if( orp == NULL ) return MEM_ERR;
   if( get_table( fh, tableDirp, orp ) != OK ) goto file_err;

   dprintf(( "OS/2 & windows specific metrics\n" ));
   dprintf(( "orp->sFamilyClass is %x\n", orp->sFamilyClass ));
   dprintf(( "VendorId is %c%c%c%c\n", orp->achVendId[0], orp->achVendId[1], orp->achVendId[2], orp->achVendId[3] ));
   dprintf(( "Typographic ascender is %d, descender is %d\n", orp->sTypoAscender, orp->sTypoDescender ));
   pg->ttAscender = orp->sTypoAscender;
   pg->ttDescender = orp->sTypoDescender;
   pg->sFamilyClass = orp->sFamilyClass;
   free( orp );
   return OK;

file_err:
   dprintf(( "file error reading 'OS/2' table\n" ));
   free( orp );
   return FILE_ERR;
} /* pr_OS2() */


static tTTF_ERROR
pr_head( const FILE_H fh, tableDirectoryRecord *tableDirp, tTTF_GDATA *pg )
{
struct {
   Fixed    vers;
   Fixed    fontRevision;
   uint32    checkSumAdjustment;
   uint32    magicNumber;
   uint16   flags;
   uint16   unitsPerEm;
   BYTE     date[8];
   BYTE     time[8];
   FWord    xMin;
   FWord    yMin;
   FWord    xMax;
   FWord    yMax;
   uint16   macStyle;
   uint16   lowestRecPPEM;
   int16    fontDirectionHint;
   int16    indexToLocFormat;
   int16    glyphDataFormat;
} *const headp = malloc( tableDirp->length );

   if( headp == NULL ) return MEM_ERR;

   assert( (tableDirp->offset&3) == 0 );  /* table aligned on long boundary */
   if( Fseek( tableDirp->offset, fh, 0 ) <= 0
   ||  Fread( fh, tableDirp->length, headp ) < tableDirp->length ) goto file_err;

   dprintf(( "head: font header\t" ));
   dprintf(( "vers is %lx\t", headp->vers ));
   dprintf(( "fontRevision is %lx\n", headp->fontRevision ));
   dprintf(( "checkSumAdjustment is %lx\n", headp->checkSumAdjustment ));
   dprintf(( "magicNumber is %lx\n", headp->magicNumber ));
   dprintf(( "flags is 0x%x\n", headp->flags ));
   dprintf(( "unitsPerEm is %d\n", headp->unitsPerEm ));
   dprintf(( "date is %x%x%x%x%x%x%x%x\n", headp->date[0], headp->date[1], headp->date[2], headp->date[3],
                                         headp->date[4], headp->date[5], headp->date[6], headp->date[7] ));
   dprintf(( "time is %x%x%x%x%x%x%x%x\n", headp->time[0], headp->time[1], headp->time[2], headp->time[3],
                                         headp->time[4], headp->time[5], headp->time[6], headp->time[7] ));
   dprintf(( "xMin is %d\n", headp->xMin ));
   dprintf(( "yMin is %d FUnits\n", headp->yMin ));
   dprintf(( "xMax is %d\n", headp->xMax ));
   dprintf(( "yMax is %d\n", headp->yMax ));
   dprintf(( "macStyle is %x\n", headp->macStyle ));
   dprintf(( "lowestRecPPEM is %d\n", headp->lowestRecPPEM ));
   dprintf(( "fontDirectionHint is %d\n", headp->fontDirectionHint ));
   dprintf(( "indexToLocFormat is %x\n", headp->indexToLocFormat ));
   dprintf(( "glyphDataFormat is %x\n", headp->glyphDataFormat ));

   /* test checksum */
   #if TEST_XSUM
   {
   register int32  n = (tableDirp->length+3)>>2;	/* nr longs */
   register uint32 *p = (uint32*)headp;
   register uint32 sum = 0L;
      headp->checkSumAdjustment = 0L;
      while( n-->0 ) sum += *p++;
      if( sum != tableDirp->checkSum ) {
         dprintf(( "%.4s: checksum error: found %8lx, expected %8lx\n",
			tableDirp->tag.c, sum, tableDirp->checkSum ));
         goto file_err;
      } /* if */
   }
   #endif

   pg->shortOffsets = (headp->indexToLocFormat == 0);
   pg->yMin = headp->yMin;
   pg->yMax = headp->yMax;
   pg->unitsPerEm = headp->unitsPerEm;

   {
   register int m = 4;  /* nr shifts in unitsPerEm */
   register int u = 16;  /* unitsPerEm always >= 16 */
      while( u < headp->unitsPerEm ) {
         u <<= 1;
         m++;
	      assert( m<=14 );
      } /* while */
      assert( u<=16384 );
      pg->fScaleShift = m;
   }

   free( headp );
   return OK;
file_err:
   dprintf(( "head: file error reading 'head' table\n" ));
   free( headp );
   return FILE_ERR;
} /* pr_head() */


static tTTF_ERROR
pr_maxp( const FILE_H fh, tableDirectoryRecord *const tableDirp, tTTF_GDATA *const pg )
{
   if( get_table( fh, tableDirp, &pg->maxp ) != OK ) return FILE_ERR;

   dprintf(( "maxp: maximum profile " ));
   dprintf(( "vers is %lx\n", pg->maxp.vers ));
   dprintf(( "numGlyphs is %d\n", pg->maxp.numGlyphs ));
   dprintf(( "maxPoints is %d\n", pg->maxp.maxPoints ));
   dprintf(( "maxContours is %d\n", pg->maxp.maxContours ));
   dprintf(( "maxCompositepoints is %d\n", pg->maxp.maxCompositepoints ));
   dprintf(( "maxCompositeContours is %d\n", pg->maxp.maxCompositeContours ));
   dprintf(( "maxZones is %d\n", pg->maxp.maxZones ));
   dprintf(( "maxTwilightPoints is %d\n", pg->maxp.maxTwilightPoints ));
   dprintf(( "maxStorage is %d\n", pg->maxp.maxStorage ));
   dprintf(( "maxFunctionDefs is %d\n", pg->maxp.maxFunctionDefs ));
   dprintf(( "maxInstructionDefs is %d\n", pg->maxp.maxInstructionDefs ));
   dprintf(( "maxStackElements is %d\n", pg->maxp.maxStackElements ));
   dprintf(( "maxSizeOfInstructions is %d\n", pg->maxp.maxSizeOfInstructions ));
   dprintf(( "maxComponentElements is %d\n", pg->maxp.maxComponentElements ));
   dprintf(( "maxComponentDepth is %d\n", pg->maxp.maxComponentDepth ));

   return OK;

} /* pr_maxp() */


static tTTF_ERROR
pr_hhea( const FILE_H fh, tableDirectoryRecord *tableDirp, tTTF_GDATA *pg )
{
struct {
   Fixed    version;
   FWord    Ascender;
   FWord    Descender;
   FWord    LineGap;
   uFWord   advanceWidthMax;
   FWord    minLeftSideBearing;
   FWord    minRightSideBearing;
   FWord    xMaxExtent;
   int16    caretSlopeRise;
   int16    caretSlopeRun;
   int16    reserved[5];
   int16    metricdataFormat;
   uint16   numberOfHMetrics;
} *const hheap = malloc( tableDirp->length );

   if( hheap == NULL ) return MEM_ERR;
   if( get_table( fh, tableDirp, hheap ) != OK ) goto err_file;

   dprintf(( "hhea: horizontal header\n" ));
   dprintf(( "version is %lx\n", hheap->version ));
   dprintf(( "Ascender is %d\n", hheap->Ascender ));
   dprintf(( "Descender is %d\n", hheap->Descender ));
   dprintf(( "LineGap is %d\n", hheap->LineGap ));
   dprintf(( "advanceWidthMax is %d\n", hheap->advanceWidthMax ));
   dprintf(( "minLeftSideBearing is %d\n", hheap->minLeftSideBearing ));
   dprintf(( "minRightSideBearing is %d\n", hheap->minRightSideBearing ));
   dprintf(( "xMaxExtent is %d\n", hheap->xMaxExtent ));
   dprintf(( "caretSlopeRise is %d\n", hheap->caretSlopeRise ));
   dprintf(( "caretSlopeRun is %d\n", hheap->caretSlopeRun ));
   dprintf(( "reserved[0] is %d\n", hheap->reserved[0] ));
   dprintf(( "reserved[1] is %d\n", hheap->reserved[1] ));
   dprintf(( "reserved[2] is %d\n", hheap->reserved[2] ));
   dprintf(( "reserved[3] is %d\n", hheap->reserved[3] ));
   dprintf(( "reserved[4] is %d\n", hheap->reserved[4] ));
   dprintf(( "metricdataFormat is %d\n", hheap->metricdataFormat ));
   dprintf(( "numberOfHMetrics is %d\n", hheap->numberOfHMetrics ));

   pg->numberOfHMetrics = hheap->numberOfHMetrics;
   free( hheap );
   return OK;

err_file:
   free( hheap );
   return FILE_ERR;

} /* pr_hhea() */


/********************
* create a global data table for ttf info
* called when ttf-gdos starts up
**/
void ttf_startup( const int16 nr_ttf_fonts )
{
int16 i;
tTTF_GDATA *p;

   gdata = hi_malloc( nr_ttf_fonts * sizeof(tTTF_GDATA) );
   for( p=gdata, i=nr_ttf_fonts; i>0; p++, i-- ) {
     p->unitsPerEm = 0;  /* this means unfilled table entry */
   } /* for */
} /* ttf_startup() */


/************************************
* update table data ready for width/char data generation
* return 0 if OK, 1 if not OK
*/
int set_tables( const int16 ttf_nr, const FILE_H fh )
{
register tTTF_GDATA *const pg = &gdata[ttf_nr];

   if( pg->ptbl == NULL ) {
      /** no tables for this ttf, so make them in cache **/
      find_mem( sizeof(tTTF_TBL), &pg->ptbl );

      /** now read in table data to table *r **/
      if( pr_cmap( fh, pg ) != OK ) goto error1;
      if( pr_hmtx( fh, pg ) != OK ) goto error1;
      if( pr_loca( fh, pg ) != OK ) goto error1;
   }
   else {
     use_mem( pg->ptbl );  /* make cache data lru */
   } /* if */

   return OK;

error1:
   return 1;
} /* set_tables() */



/***********************
* make sure global ttf data is present, scan thru ttf file if not
* needed to generate header & width tables for a font,
* must be paired with release_glyf_data() when width tables generated
* font_name must be on a word boundary
* file pointer must be set to start of file
* return 0 ==> OK
*        1 ==> failed
*/
int get_ttf_data( const int ttf_nr, char *const font_name, const FILE_H fh )
{
register tTTF_GDATA *const pg = &gdata[ttf_nr];
tableDirectoryRecord *tableDirp0;

   /** set up all gdata if not already done **/
   if( pg->unitsPerEm == 0 )
   {
   uint32 size;
   tableDirectoryRecord *tableDirp;
   struct {	/* offset table */
      Fixed    sfnt_version;
      uint16   numTables;        /* number of tables */
      uint16   searchRange;      /* 16 * (maximum power of 2 <= numTables) */
      uint16   entrySelector;    /* log2(maximum power of 2 <= numTables) */
      uint16   rangeShift;       /* numTables * 16 - searchRange */
   } otbuf;
   int i;

      if( Fread( fh, sizeof(otbuf), &otbuf ) < sizeof(otbuf) ) goto error1;
      dprintf(( "sfnt_version is (%lx) %d.%d\n", (long)otbuf.sfnt_version, (int)(otbuf.sfnt_version>>16), (int)(otbuf.sfnt_version&0xffff) ));
      dprintf(( "numTables is %x\n", otbuf.numTables ));
      dprintf(( "searchRange is %x\n", otbuf.searchRange ));
      dprintf(( "entrySelector is %x\n", otbuf.entrySelector ));
      dprintf(( "rangeShift is %x\n", otbuf.rangeShift ));

   #ifdef __m68k__
   #  define VAL(c0, c1, c2, c3) (((((((long)c0<<8)+(long)c1)<<8)+(long)c2)<<8)+(long)c3)
   #else
   #  define VAL(c0, c1, c2, c3) (((((((long)c3<<8)+(long)c2)<<8)+(long)c1)<<8)+(long)c0)
   #endif

      size = otbuf.numTables*sizeof(*tableDirp);
      tableDirp = tableDirp0 = (tableDirectoryRecord *)malloc( size );
      if( tableDirp == NULL ) goto error1;
      if( Fread( fh, size, tableDirp ) < size ) goto error2;	/* get dir tables */

      assert( VAL('a','b','c','d') == 0x61626364L );

      for( i=otbuf.numTables; i>0; i--, tableDirp++ ) {

	 tableDirp->length = (tableDirp->length+3)&~3;  /* exact nr longs stored in ttf file */
         switch( tableDirp->tag.u ) {
         case VAL('n','a','m','e'):
            if( pr_name( fh, tableDirp, pg->font_name ) != OK ) goto error2;
            break;
         case VAL('c','m','a','p'):
            pg->cmap_dir = *tableDirp;
            break;
         case VAL('O','S','/','2'):
            if( pr_OS2( fh, tableDirp, pg ) != OK ) goto error2;
            break;
         case VAL('h','e','a','d'):
            if( pr_head( fh, tableDirp, pg ) != OK ) goto error2;
            break;
         case VAL('h','h','e','a'):
            if( pr_hhea( fh, tableDirp, pg ) != OK ) goto error2;
            break;
         case VAL('m','a','x','p'):
            if( pr_maxp( fh, tableDirp, pg ) != OK ) goto error2;
            break;
         case VAL('h','m','t','x'):
            pg->hmtx_dir = *tableDirp;
            break;
         case VAL('l','o','c','a'):
            pg->loca_dir = *tableDirp;
            break;
         case VAL('g','l','y','f'):
            pg->glyf_dir = *tableDirp;
            break;
         default:
            dprintf(( "unused table %.4s\n", tableDirp->tag.c ));
         } /* switch */
      } /* for */
      free( tableDirp0 );
      pg->ptbl = NULL; /* no table data yet */
   } /* if */

   {
   register int32 *s1 = (int32 *)font_name;
   register int32 *s2 = (int32 *)pg->font_name;
   register int16 n = sizeof(pg->font_name)/sizeof(int32 *) - 1;
   assert( ((int)s1&1) == 0 );  /* word (ie even) address */
   assert( ((int)s2&1) == 0 );  /* word (ie even) address */
   do {
      *s1++ = *s2++;
   } while( --n > 0 );
   }
   return OK;

error2:  /*********************/
   free( tableDirp0 );
error1:
   return 1;
} /* get_ttf_data() */


int get_glyf_data( const int ttf_nr, const FILE_H fh )
{
register tTTF_GDATA *const pg = &gdata[ttf_nr];
   assert( glyfTablep == NULL );
   glyfTablep = malloc( pg->glyf_dir.length );
   if( glyfTablep == NULL ) goto error1;
   if( get_table( fh, &pg->glyf_dir, glyfTablep ) == OK )
      return set_tables( ttf_nr, fh );

   free( glyfTablep );
   glyfTablep = NULL;
error1:
   return 1;
} /* get_glyf_data() */

void release_glyf_data( void )
{
   assert( glyfTablep != NULL );
   if( glyfTablep != NULL ) free( glyfTablep );
   glyfTablep = NULL;
} /* release_glyf_data() */

/********************* end of ttf.c *********************/
