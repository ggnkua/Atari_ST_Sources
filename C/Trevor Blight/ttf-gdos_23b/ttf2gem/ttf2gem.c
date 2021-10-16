/************** (c) 2000-2021 Trevor Blight *************************
 * 
 * ttf2gem.c   -- generate hinted gem bitmap fonts from true type fonts
 *
 * $Id: ttf2gem.c 3342 2021-10-25 15:16:15Z trevor $
 * 
 * This and associated files are licenced under the same terms as the
 * freetype library.  See the licence terms described therein.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * THE AUTHORS OR DISTRIBUTORS OF THIS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

/** TODO:

- provide default name, derived from ttf name
  check name is valid before converting font
  check / warn if file already exists
 **/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <unixlib.h>
#include <aesbind.h>
#include <osbind.h>

#include "freetype.h"
#include "ttf2gem.h"


/**************************************************************************
 *
 * Macros.
 *
 **************************************************************************/

/*
 * Set the default values used to generate a GEM font.
 * use Apple platform, roman encoding
 */
#define PLATFORM_ID 1
#define ENCODING_ID 0

#define DEFAULT_POINT_SIZE 12

#define DEFAULT_RESOLUTION 90

#define GEM_FIRST_CH ' '
#define GEM_LAST_CH  255
#define GEM_FONT_NAME_LEN 32

#ifndef MAX
#define MAX(h,i) ((h) > (i) ? (h) : (i))
#endif

#ifndef MIN
#define MIN(l,o) ((l) < (o) ? (l) : (o))
#endif

#if defined __GNUC__
#define Swapw(v) __asm__( "rorw #8,%0" : "=d" ((uint16)(v)) : "0" ((uint16)(v)) )
#define Swapl(v) __asm__( "rorw #8,%0; swap %0; rorw #8,%0" \
			   : "=d" ((uint32)(v)) : "0" ((uint32)(v)) )
#else
#define Swapw(v)        (v) = ((v)<<8) | ((v)>>8)&0x00FF
#define Swapl(v)        { register char t, *vp = (char *)&(v); \
			  t = vp[0]; vp[0] = vp[3]; vp[3] = t; \
			  t = vp[1]; vp[1] = vp[2]; vp[2] = t; }
#endif


/*********************************************
*
* typedefs
*
**********************************************/

typedef short int16;  /* 16 bits */
typedef long int32;   /* 32 bits */
typedef char int8;    /* 8 bits */
typedef unsigned short uint16;  /* 16 bits */
typedef unsigned long uint32;   /* 32 bits */
typedef unsigned char uint8;    /* 8 bits */
typedef unsigned char bool;


typedef struct _font {

/* Type    Name       Offset   Function		    Comments		     */
/* ------------------------------------------------------------------------- */
   int16  font_id;    /*  0 Font face identifier  1 == system font	     */
   int16  size;       /*  2 Font size in points				     */
   char   name[GEM_FONT_NAME_LEN];   /*  4 Face name			     */
   uint16  first_ade; /* 36 Lowest ADE value in the face (lowest ASCII value of displayable character).		             */
   uint16  last_ade;  /* 38 Highest ADE value in the face (highest ASCII value of displayable character).		             */
   int16  top;	      /* 40 Distance of top line relative to baseline	     */
   int16  ascent;     /* 42 Distance of ascent line relative to baseline     */
   int16  half;       /* 44 Distance of half line relative to baseline       */
   int16  descent;    /* 46 Distance of decent line relative to baseline     */
   int16  bottom;     /* 48 Distance of bottom line relative to baseline     */
		                /*    All distances are measured in absolute values    */
		                /*    rather than as offsets. They are always +ve      */
   int16 max_char_width; /* 50 Width of the widest character in font	     */
   int16 max_cell_width; /* 52 Width of the widest cell character cell in face  */
   int16 left_offset;  /* 54 Left Offset see Vdi appendix G		     */
   int16 right_offset; /* 56 Right offset   "      "     "		     */
   int16  thicken;    /* 58 Number of pixels by which to thicken characters  */
   int16  ul_size;    /* 60 Width in  pixels of the underline		     */
   int16  lighten;    /* 62 The mask used to lighten characters		     */
   int16  skew;       /* 64 The mask used to determine when to perform       */
		                /*    additional rotation on the character to perform skewing					     */
   int16  flags;      /* 66 Flags					     */
		                /*      bit 0 set if default system font		     */
		                /*      bit 1 set if horiz offset table should be used */
		                /*      bit 2 byte-swap flag (thanks to Intel idiots)  */
		                /*      bit 3 set if mono spaced font		     */
   uint32   h_table;   /* 68 offset to horizontal offset table		     */
   uint32 off_table; /* 72 offset to character offset table		     */
   uint32 form_data; /* 76 offset to font data			     */
   uint16 form_width; /* 80 Form width (#of bytes /scanline in font data)    */
   uint16 form_height;/* 82 Form height (#of scanlines in font data)	     */
   struct _font *next_font;  /* 84 Pointer to next font in face		     */
} tGEM_FONT_HDR;

#define MOT_FLAG  0x0004
#define MONO_FLAG 0x0008


/**************************************************************************
 *
 * General globals for user interface
 *
 **************************************************************************/

/*
 * Default resolutions.
 */
static int hres = DEFAULT_RESOLUTION;
static int vres = DEFAULT_RESOLUTION;

static OBJECT *form;		/* for user selections */
static OBJECT *progress;	/* for progress report */
static int Prx, Pry, Prw, Prh;
static char ttf_name[32];
static char ttf_path[256] = "A:";
static char gem_file_name[14];
static char gem_id_str[5] = "254";
static char point_size_str[3] = "12";
static char v_res_str[4] = "90";
static char h_res_str[4] = "90";

static char err_msg[128];

/**************************************************************************
 *
 * gem font related globals
 *
 **************************************************************************/

/*
 * Structure used for building the gem font
 */
const static tGEM_FONT_HDR default_gem_font = { 0, DEFAULT_POINT_SIZE, { "" },
		GEM_FIRST_CH,GEM_LAST_CH,
		0,0,0,0,0,0,0,0,0,0,0,
		0x5555,0x5555,4,0L,0L,0L,0,0,NULL };

static tGEM_FONT_HDR gem_font;
static tGEM_FONT_HDR temp_font;

static int16 offset_table[ GEM_LAST_CH-GEM_FIRST_CH+2 ];

/**************************************************************************
 *
 * Freetype globals.
 *
 **************************************************************************/

static TT_Engine engine;
static TT_Face face;
static TT_Face_Properties properties;
static TT_Instance instance;
static TT_CharMap cmap;

/**************************************************************************
 *
 * Freetype related code.
 *
 **************************************************************************/

/*
 * Create a gem name from the TT name table.
 * face name is in first 16 chars, then style name starts at char 16
 * to the GEM_FONT_NAME_LEN chars maximum.
 *
 * This routine always looks for English language names and 
 * checks these possibilities:
 * 1. English names with the MS Unicode encoding ID. (platform 3, encoding 1 )
 * 2. English names with the MS unknown encoding ID. (platform 3, encoding 0 )
 * 3. English names with the Apple Unicode encoding ID. (platform 0, encoding 0 )
 *
 */
static void make_gem_name( char *const name )
{
int ic, in;
TT_UShort irec;
TT_UShort nrPlatformID, nrEncodingID, nrLanguageID, nrNameID;
/*const*/ TT_String *s;

   for( irec=0; irec < properties.num_Names; irec++ ) {
      TT_Get_Name_ID( face, irec, &nrPlatformID, &nrEncodingID,
			&nrLanguageID, &nrNameID);

      /* attempt to find a Unicode English name */
      if( ((nrPlatformID == 0 && nrLanguageID == 0)	/* Apple Unicode */
          ||
	  (nrPlatformID == 3 &&    /* microsoft */
	     ( nrEncodingID == 0 || nrEncodingID == 1 ) &&
	     (nrLanguageID == TT_MS_LANGID_ENGLISH_UNITED_STATES
	     || nrLanguageID == TT_MS_LANGID_ENGLISH_UNITED_KINGDOM
	     || nrLanguageID == TT_MS_LANGID_ENGLISH_AUSTRALIA
	     || nrLanguageID == TT_MS_LANGID_ENGLISH_CANADA
	     || nrLanguageID == TT_MS_LANGID_ENGLISH_NEW_ZEALAND
	     || nrLanguageID == TT_MS_LANGID_ENGLISH_IRELAND))
	   ) && (nrNameID == TT_NAME_ID_FONT_FAMILY)
      ) {
         /*
         * Found the Apple Unicode English name or one of the MS English 
	 * font names.  The name is by definition encoded in Unicode, 
	 * so copy every second byte into the `name' parameter, 
	 * assuming GEM_FONT_NAME_LEN char gem font name.
         */
	 TT_UShort full_len, face_len, style_len;
         TT_Get_Name_String(face, irec, &s, &face_len);
         for( in=0, ic=1; s!=NULL && ic<face_len && in<GEM_FONT_NAME_LEN; ic+=2, in++ ) {
              name[in] = s[ic];
         } /* for */
	 /** <<<< assume no missing name strings!! **/
	 assert( (TT_Get_Name_ID( face, irec+TT_NAME_ID_FULL_NAME-TT_NAME_ID_FONT_FAMILY, 
			&nrPlatformID, &nrEncodingID, &nrLanguageID, &nrNameID),
		 nrNameID == TT_NAME_ID_FULL_NAME) );
         TT_Get_Name_String( face, irec+TT_NAME_ID_FULL_NAME-TT_NAME_ID_FONT_FAMILY, &s, &full_len);
         for( ic=0; s!=NULL && ic<(full_len/2) && ic<sizeof(ttf_name); ic++ ) {
              ttf_name[ic] = ((int*)s)[ic];
	 } /* for */
	 ttf_name[ic] = '\0';
	 assert( full_len >= face_len );
	 if( full_len != face_len ) {
	    /** if the full name & face name are not the same, add the style */
	    while( in<16 ) name[in++] = ' ';	/* pad to style position */
	    assert( (TT_Get_Name_ID(face, irec+TT_NAME_ID_FONT_SUBFAMILY-TT_NAME_ID_FONT_FAMILY, 
			&nrPlatformID, &nrEncodingID, &nrLanguageID, &nrNameID),
		    nrNameID == TT_NAME_ID_FONT_SUBFAMILY) );
            TT_Get_Name_String(face, irec+TT_NAME_ID_FONT_SUBFAMILY-TT_NAME_ID_FONT_FAMILY, &s, &style_len);
	    if( s != NULL ) {
	       for( ic=1; ic<style_len && in<GEM_FONT_NAME_LEN; ic+=2, in++ ) {
		    name[in] = s[ic];
	       } /* for */
	    } /* if */
	 } /* if */
         if( in < GEM_FONT_NAME_LEN ) name[in] = '\0';
	 return;
      } /* if record found */

    } /* for all name records */

   (void) strcpy(name, "Unknown");

} /* make_gem_name() */


/**************************************************************************
** translate gem character code to apple character code for chars >= 127
**/
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
   
/** symbolic fonts have these gem ids, and must not be remapped ...
**	128	Symbol
**	129	Zapf Dingbats
**	130	Sonata (music)
**	3072 .. 3087   id from os2 table for symbolic font
**/
#define IS_SYMBOLIC(id) ((((id)&0x0f00)==0x0c00) || ((unsigned)((id)-128)<=2))

#define GEM2APPLE(gem_char,id) ((gem_char<127)||IS_SYMBOLIC(id) ? gem_char : gem2apple[gem_char-127])


static void show_progress( int prog, int max )
{
register OBJECT *p = &progress[ProgressBar];
   int old_wid = p->ob_width;
   int new_wid = (long)progress[ProgressBox].ob_width*prog/max;
   if( new_wid > old_wid ) {
        p->ob_width = new_wid;
        objc_draw( progress, ROOT, MAX_DEPTH,
                   Prx+progress[ProgressBox].ob_x+old_wid,
                   Pry+progress[ProgressBox].ob_y,
                   new_wid-old_wid,
                   p->ob_height+2 ); /* +2?? <<<< */
   } /* if */
} /* show_progress() */


static void init_progress( char *msg )
{
   (char*)progress[ProgressText].ob_spec = msg;
   progress[ProgressBar].ob_width = 0;
   objc_draw(progress, ROOT, MAX_DEPTH, Prx, Pry, Prw, Prh);
} /* init_progress() */


/*******************************************************
*
* Now go through and generate the font header and character bitmaps
*
*/
static void generate_gem_font_data( void )
{
int16 mono_wid = -1;	/* 0 ==> not mono, -1 ==> not started, >0 ==> width for all chars so far */
int16 max_width=0;
FILE *gem_font_file;
int32 xoff;
int16 idx, gem_char;
int fontMiny=0, fontMaxy=0;
TT_Raster_Map raster;
TT_Glyph glyph;
TT_Instance_Metrics imetrics;
TT_Glyph_Metrics metrics;
TT_Error res;
tGEM_FONT_HDR *pFont;
char gem_path[256];
char *s;


   /** Create a new glyph container **/

   if( (res = TT_New_Glyph(face, &glyph))) {
      sprintf(err_msg, "[3][unable to create glyph|freetype error %ld][quit]", (long)res);
      form_alert( 1, err_msg );
      return;
   } /* if */

   (void) TT_Get_Face_Properties(face, &properties);
   (void) TT_Get_Instance_Metrics(instance, &imetrics);

   init_progress( "generating character width table" );


   /***** first pass thru the chars to get char width & height info *****/
   
   offset_table[0] = 0;
   for( gem_char = gem_font.first_ade; gem_char <= gem_font.last_ade; gem_char++ ) {
   int16 xleft, xright, xwidth;
      show_progress( gem_char, gem_font.last_ade );
      idx = TT_Char_Index( cmap, GEM2APPLE(gem_char,gem_font.font_id) );
      if( idx <= 0 || TT_Load_Glyph(instance, glyph, idx, TTLOAD_DEFAULT) != TT_Err_Ok ) xwidth = 0;
      else {
         /** this char has non-zero width **/
	 (void) TT_Get_Glyph_Metrics(glyph, &metrics);
	 xleft = MIN(0,metrics.bbox.xMin);
	 xright = MAX(metrics.bbox.xMax,metrics.advance);
	 xwidth = xright-xleft;
	 if(xwidth>max_width) max_width = xwidth;
   
	 if( mono_wid != 0 ) {
	   /* Test to see if the font is going to be monowidth or not by
	    * comparing the current glyph width against the previous ones
	    */
	    if( mono_wid > 0 ) {
	       if( (xwidth>>6) != mono_wid ) mono_wid = 0;
	    }
	    else {
	       mono_wid = (xwidth>>6);	/* set initial value */
	    } /* if */
	 } /* if */
   
	 if( metrics.bbox.yMin < fontMiny ) fontMiny = metrics.bbox.yMin;
	 if( metrics.bbox.yMax > fontMaxy ) fontMaxy = metrics.bbox.yMax;
      } /* if */
      offset_table[gem_char-gem_font.first_ade+1] = offset_table[gem_char-gem_font.first_ade]+(xwidth>>6);
   } /* for */

   gem_font.top = (fontMaxy-32)>>6;
   gem_font.bottom = (32-fontMiny)>>6;
   gem_font.max_char_width = gem_font.max_cell_width = max_width>>6;
   gem_font.form_height = gem_font.top+gem_font.bottom+1;
   gem_font.form_width = ((offset_table[gem_font.last_ade-gem_font.first_ade+1]+15)&~15)>>3;
   gem_font.left_offset = (gem_font.bottom+1)>>1;
   gem_font.right_offset = gem_font.top>>1;
   gem_font.thicken = 1 + (gem_font.form_height >> 5);
   gem_font.ul_size = 1 + (gem_font.form_height >> 5);
   if( properties.os2 != NULL ) {
      /** prefer os2 ascender/descender **/
      int units_per_em = properties.header->Units_Per_EM;
      gem_font.ascent = (properties.os2->sTypoAscender * imetrics.y_ppem) / units_per_em;
      gem_font.descent = (-properties.os2->sTypoDescender * imetrics.y_ppem) / units_per_em;
   }
   else {
      gem_font.ascent = gem_font.top;
      gem_font.descent = gem_font.bottom;
   } /* if */


   /** now generate the character bitmap data **/
   
   init_progress( "generating character bitmap" );

   raster.flow = TT_Flow_Down;
   raster.width = gem_font.form_width << 3;
   raster.rows = gem_font.form_height;
   raster.cols = (raster.width + 7) >> 3;
   raster.size = (long)raster.cols * raster.rows;

   raster.bitmap = (void *) malloc(raster.size);
   if( raster.bitmap == NULL ) {
     form_alert( 1, "[3][not enough memory|to generate font file][ok]" );
     return;
   } /* if */
   (void) memset((char *) raster.bitmap, 0, raster.size);	/* Clear the raster bitmap */

   for( gem_char = gem_font.first_ade; gem_char <= gem_font.last_ade; gem_char++ ) {
      idx = TT_Char_Index( cmap, GEM2APPLE(gem_char,gem_font.font_id) );

      /** If the glyph could not be loaded for some reason,
          just continue with next glyph **/
      if( idx <= 0 
          || TT_Load_Glyph(instance, glyph, idx, TTLOAD_DEFAULT) != TT_Err_Ok )
          continue;	/* assert( char_wid == 0 ) */

      (void)TT_Get_Glyph_Metrics( glyph, &metrics );

      /*
      * Grid fit to determine the x and y offsets that will force the
      * bitmap to fit into the storage provided.
      */
      xoff = ((long)offset_table[gem_char-gem_font.first_ade]*64) - MIN(0,metrics.bbox.xMin);

      /** If the bitmap cannot be generated, simply continue. **/
      if( TT_Get_Glyph_Bitmap(glyph, &raster, xoff, -fontMiny) != TT_Err_Ok ) continue;

      show_progress( offset_table[gem_char-gem_font.first_ade], offset_table[gem_font.last_ade-gem_font.first_ade] );

   } /* gem_char ... */

   assert( raster.size == (long)gem_font.form_height*gem_font.form_width );
   gem_font.off_table = sizeof(gem_font);
   gem_font.form_data = gem_font.off_table + sizeof(offset_table);

   /*  NOTE: could also set MONO_WID from OS2 table -> panose -> proportion == monospaced */
   if( mono_wid > 0 ) gem_font.flags |= MONO_FLAG;

   pFont = &gem_font;
   if( (gem_font.flags & MOT_FLAG) == 0 ) {     /** convert to intel format **/
   register uint16 i;

      pFont = &temp_font;
      temp_font = gem_font;
      for (i=0;  i<=sizeof(offset_table)/sizeof(offset_table[0]); i++) {
	   Swapw(offset_table[i]);
      } /* for */

      /* swap header words and longs */
      Swapw(temp_font.font_id);             Swapw(temp_font.size);
      Swapw(temp_font.first_ade);           Swapw(temp_font.last_ade);
      Swapw(temp_font.top);                 Swapw(temp_font.ascent);
      Swapw(temp_font.half);                Swapw(temp_font.descent);
      Swapw(temp_font.bottom);
      Swapw(temp_font.max_char_width);      Swapw(temp_font.max_cell_width);
      Swapw(temp_font.left_offset);         Swapw(temp_font.right_offset);
      Swapw(temp_font.thicken);             Swapw(temp_font.ul_size);
      Swapw(temp_font.lighten);             Swapw(temp_font.skew);
      Swapw(temp_font.flags);               Swapl(temp_font.h_table);
      Swapl(temp_font.off_table);           Swapl(temp_font.form_data); 
      Swapw(temp_font.form_width);          Swapw(temp_font.form_height);
   } /* if */


   strcpy( gem_path, ttf_path );
   s = strrchr( gem_path, '\\' );
   if( s!=NULL ) s++; /* advance to 1st char of filename */
   else s = gem_path;
   strcpy( s, gem_file_name );
   s = strrchr( gem_path, '?' );
   if( s!=NULL && s[-1] == '?') {
        /* substitute point size */
        s[-1] = '0' + gem_font.size / 10;   /* tens digit */
        s[ 0] = '0' + gem_font.size % 10;   /* units digit */
   } /* if */
   gem_font_file = fopen( gem_path, "wb" );
   if( gem_font_file == NULL ) {
      sprintf( err_msg, "[3][can't create gem font file|'%s'][ok]", gem_file_name );
      form_alert( 1, err_msg );
   }
   else {
      /** write out the font file **/
   
      /** write the font header **/
      if( fwrite( pFont, sizeof(*pFont), 1, gem_font_file ) != 1 ) {
	 sprintf( err_msg, "[3][can't write header|to '%s'][ok]", gem_file_name  );
      form_alert( 1, err_msg );
      }
      else if( fwrite( offset_table, sizeof(offset_table), 1, gem_font_file ) != 1 ) {         /** write the character offset table **/
         sprintf( err_msg, "[3]s[can't write|character offset table|to '%s'][ok]", gem_file_name );
      form_alert( 1, err_msg );
      }
      else if( fwrite( raster.bitmap, raster.size, 1, gem_font_file ) != 1 ) {
         sprintf( err_msg, "[3][can't write character data|to '%s'][ok]", gem_file_name );
      form_alert( 1, err_msg );
      } /* if */
      fclose( gem_font_file );
   } /* if */


   free( raster.bitmap );	/* Free up the raster storage */

} /* generate_gem_font_data() */


/****************************************
* generate a new gem font if ok to do so,
* return if not
*/
void convert_to_gem( void )
{
TT_Error res;

   /*
   * Arbitrarily limit the point size to a minimum of 2pt and maximum of 99pt,
   * and the resolutions to a minimum of 40dpi and a maximum of 1200dpi.
   */
   if( gem_font.size < 2 || gem_font.size > 99) {
	sprintf( err_msg, "[3]['%d' points is ridiculous][ok]", gem_font.size);
	form_alert( 1, err_msg );
	return;
   } /* if */
   if( hres < 40 || hres > 1200) {
	sprintf(err_msg, "[3][invalid horizontal resolution|'%d dpi'][ok]", hres);
	form_alert( 1, err_msg );
	return;
    } /* if */
    if( vres < 40 || vres > 1200) {
	sprintf(err_msg, "[3][invalid vertical resolution|'%d dpi'][ok]", vres);
	form_alert( 1, err_msg );
	return;
   } /* if */

   if( gem_font.font_id <= 0 ) {
      form_alert( 1, "[3][font id must be|greater than zero][ok]" );
      return;
   } /* if */

   
   /** Create a new instance **/

   if( (res = TT_New_Instance( face, &instance)) ) {
      sprintf(err_msg, "[3][freetype doesn't work with|this true type font|freetype error %ld][ok]", (long)res);
      form_alert( 1, err_msg );
      return;
   } /* if */

   form_center(progress, &Prx, &Pry, &Prw, &Prh);
   form_dial(FMD_START, 0, 0, 0, 0, Prx, Pry, Prw, Prh);
   init_progress( "creating true type instance" );

   /** Set the instance resolution and point size **/

   (void) TT_Set_Instance_Resolutions(instance, hres, vres);
   (void) TT_Set_Instance_CharSize(instance, gem_font.size*64);

   generate_gem_font_data();      /* Generate the GEM font from the TrueType font */

   (void) TT_Done_Instance(instance);

   form_dial( FMD_FINISH, 0, 0, 0, 0, Prx, Pry, Prw, Prh );

} /* convert_to_gem() */


/****************************************************************
*
*
*
*/

typedef enum{ eQuit, eConvert, eNewTTF } tUserAction;

tUserAction get_args( void )
{
int button;
int cx, cy, cw, ch;
   sprintf( gem_id_str, "%d", gem_font.font_id );

   form_center(form, &cx, &cy, &cw, &ch);
   form_dial(FMD_START, 0, 0, 0, 0, cx, cy, cw, ch);
   objc_draw(form, ROOT, MAX_DEPTH, cx, cy, cw, ch);
   button =form_do( form, FORM1 );
   form_dial( FMD_FINISH, 0, 0, 0, 0, cx, cy, cw, ch );

   button &= 0x7ffff;
   form[button].ob_state &= ~SELECTED;
   switch( button & 0x7ffff ) {
   case FinishedBtn:
      return eQuit;
   case SelTTFFile:
      return eNewTTF;
   } /*    switch */

   gem_font.font_id = atoi( gem_id_str );
   gem_font.size = atoi( point_size_str );	/* Set the point size */
   hres = atoi( h_res_str );	/* Set the horizontal and vertical resolutions */
   vres = atoi( v_res_str );
   assert( (form[MotBtn].ob_state & SELECTED) != (form[IntelBtn].ob_state&SELECTED) );
   gem_font.flags = (form[MotBtn].ob_state & SELECTED) != 0 ? MOT_FLAG : 0;
   return eConvert;

} /* get_args() */


/*********************************************
* get true type font selection
* load & initialise true type font
* make gem fonts
*/
static tUserAction ttf2gem( void )
{
int r, btn;
char inpath[128]; 
TT_UShort p, e;
TT_Error res;
int i;
tUserAction action;
char *s;
char ttf_file[14];


   ttf_file[0] = '\0';
   gem_file_name[0] = '\0';

   /* ask user to choose a true type font file */
   r = fsel_exinput( ttf_path, ttf_file, &btn, "select a true type font" );
   if( r==0 ) {
      form_alert( 1, "[3][can't select a ttf file][new ttf]" );
      return eNewTTF;
   } /* if */
   if( btn==0 ) return eQuit;

   if( ttf_file[0] == '\0' ) {
        form_alert( 1, "[3][no file selected!][try again]" );
        return eNewTTF;
    } /* if */

   /*
    * Open the ttf file
    */
   strcpy( inpath, ttf_path );
   s = strrchr( inpath, '\\' );
   if( s!=NULL ) {
      strcpy( s+1, ttf_file );
      s = inpath;
   } else s = ttf_file;

   if( (res = TT_Open_Face( engine, s, &face )) != TT_Err_Ok ) {
      sprintf(err_msg, "[3][unable to open ttf file|'%s'|freetype error %ld][new ttf]", ttf_file, (long)res );
      form_alert( 1, err_msg );
      return eNewTTF;
   } /* if */

   gem_font = default_gem_font;

   (void) TT_Get_Face_Properties(face, &properties);

   if( properties.os2 != NULL ) {
      gem_font.font_id = properties.os2->sFamilyClass;
   } /* if */
   make_gem_name( gem_font.name );    /* Generate the gem font name */

   /*
    * Get & check the requested cmap.
    */
   for ( i=0; i<properties.num_CharMaps; i++ ) {
      if( !TT_Get_CharMap_ID(face, i, &p, &e) && p == PLATFORM_ID && e == ENCODING_ID)
         break;
   } /* for */

   if( i < properties.num_CharMaps && (TT_Get_CharMap(face, i, &cmap) == TT_Err_Ok) ) {
      while( (action=get_args()) == eConvert ) {
         graf_mouse(M_OFF, 0);
         convert_to_gem();
         graf_mouse(M_ON, 0);
      } /* while */
   }
   else {
      form_alert( 1, "[3][can't find suitable|character map in ttf][new ttf]" );
      action = eNewTTF;
    } /* if */

   (void) TT_Close_Face(face);

   return action;

} /* ttf2gem() */


void init_form( void )
{
   /* get current directory */
   ttf_path[0] += Dgetdrv();
   (void)Dgetpath(ttf_path+2, 0);
   strcat( ttf_path, "\\*.TTF" );

   (char *)form[TTFFileName].ob_spec = ttf_name;
   ((TEDINFO *)form[GetGemFileName].ob_spec)->te_ptext = gem_file_name;
   ((TEDINFO *)form[GetGemFileName].ob_spec)->te_txtlen = sizeof(gem_file_name);
   ((TEDINFO *)form[GetGemFontId].ob_spec)->te_ptext = gem_id_str;
   ((TEDINFO *)form[GetGemFontId].ob_spec)->te_txtlen = sizeof(gem_id_str);
   ((TEDINFO *)form[GetGemPointSize].ob_spec)->te_ptext = point_size_str;
   ((TEDINFO *)form[GetGemPointSize].ob_spec)->te_txtlen = sizeof(point_size_str);
   ((TEDINFO *)form[GetVertRez].ob_spec)->te_ptext = v_res_str;
   ((TEDINFO *)form[GetVertRez].ob_spec)->te_txtlen = sizeof(v_res_str);
   ((TEDINFO *)form[GetHorRez].ob_spec)->te_ptext = h_res_str;
   ((TEDINFO *)form[GetHorRez].ob_spec)->te_txtlen = sizeof(h_res_str);
} /* init_form() */


void main( void )
{
tUserAction r;
TT_Error res;

   appl_init();
   graf_mouse(ARROW, 0);
   if(rsrc_load("ttf2gem.rsc")) {
      rsrc_gaddr( R_TREE, FORM1, &(void*)form );
      init_form();
      rsrc_gaddr( R_TREE, PROGRESS, &(void*)progress );
      if( (res = TT_Init_FreeType(&engine)) != TT_Err_Ok ) {    /* Intialize Freetype */
	 sprintf( err_msg, "[3][freetype is unable to|initialize its renderer|freetype error %ld][quit]", (long)res);
	 form_alert( 1, err_msg );
      }
      else {
	 do {
	    r = ttf2gem();    /* user selects true type font */
	 } while( r != eQuit );
	 (void) TT_Done_FreeType(engine);     /* Shut down the renderer */
      } /* if */
   
      rsrc_free();
   }
   else form_alert(1, "[3][cannot open resource file][quit]");
   appl_exit();
   exit(0);

} /* main() */

/******************** end of ttf2gem.c **********************/

