/********** (c) 1999, Trevor Blight ********************
*
*  $Id: fix-fwid.c 1.5 1999/12/27 22:52:06 tbb Exp tbb $
*
* utility to fix fontwid.prg for timeworks 2
* 
* some versions of fontwid for timeworks have problems with ttf-gdos.
* this is because it interferes with gdos so it can  read the gem font 
* files itself, rather than reading the font info from gdos.
* This approach has 2 problems when it uses ttf-gdos:
*  - there are no gem font files for ttf fonts
*  - fontwid doesn't always get the file names correct
* 
* this program fixes this by:
*  - create gem font files for all fonts, even ttf fonts
*  - tweak ttf-gdos to use these instead of the ttf fonts
*  - call fontwid.prg
*  - restore everything to its original state
* 
*  The font files contain only width & header info, not font data. 
*  This keeps them small so they shouldn't use up too much disk space
* 
* to use this program, put it into the same directory (ie folder) as 
* fontwid.prg and run this program.
* 
* 
* tech notes
* ==========
* 
* 1. in ttf-gdos, vq_gdos() returns a pointer to config info.
*    see ttf-gdos doc for exact details.
* 
* 2. when the fonts are loaded in ttf-gdos, a pointer to the font chain
*    is available.
* 
* 3. this program accesses the font chain and writes into the gemsys 
*    directory gem fonts equivalent to all fonts (including ttf fonts) loaded.
*    these fonts are given short names because fontwid.app can only cope 
*    with (gempath+fontname) < 20 chars.
*    only the width part of the font is stored, not the data, so all fonts
*    are very small (about 600 bytes)
* 
* 4. the new fonts are assigned to the workstations in the 
*    ttf-gdos config found in step 1.
* 
* 5. with ttf-gdos now set up with only gem fonts, fontwid.app is called
* 
* 6. ttf-gdos config is restored.
*
********************************************************/


/* includes */
#include <aesbind.h>
#include <vdibind.h>
#include <obdefs.h>
#include <gemdefs.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <osbind.h>
#include <sysvars.h>
#include "ttf-gdos.h"

typedef unsigned char bool;
#define FALSE 0
#define TRUE  (!FALSE)

/** defines **/
#define FONT_FILE_NAME(str,n) sprintf( str, "f%x", n )
#define MOT_FLAG 0x0004

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

/** typedefs **/

typedef struct _font {

/* Type    Name       Offset   Function             Comments                 */
/* ------------------------------------------------------------------------- */
   int16  font_id;    /*  0 Font face identifier  1 == system font           */
   int16  size;       /*  2 Font size in points                              */
   char   name[32];   /*  4 Face name                                        */
   int16  first_ade;  /* 36 Lowest ADE value in the face (lowest ASCII value of displayable character).                      */
   int16  last_ade;   /* 38 Highest ADE value in the face (highest ASCII value of displayable character).                            */
   int16  top;         /* 40 Distance of top line relative to baseline       */
   int16  ascent;     /* 42 Distance of ascent line relative to baseline     */
   int16  half;       /* 44 Distance of half line relative to baseline       */
   int16  descent;    /* 46 Distance of decent line relative to baseline     */
   int16  bottom;     /* 48 Distance of bottom line relative to baseline     */
				/*    All distances are measured in absolute values    */
				/*    rather than as offsets. They are always +ve      */
   int16 max_char_width; /* 50 Width of the widest character in font         */
   int16 max_cell_width; /* 52 Width of the widest cell character cell in face  */
   int16 left_offset;  /* 54 Left Offset see Vdi appendix G                  */
   int16 right_offset; /* 56 Right offset   "      "     "		     */
   int16  thicken;    /* 58 Number of pixels by which to thicken characters  */
   int16  ul_size;    /* 60 Width in  pixels of the underline                */
   int16  lighten;    /* 62 The mask used to lighten characters              */
   int16  skew;       /* 64 The mask used to determine when to perform       */
				/*    additional rotation on the character to perform skewing                                        */
   int16  flags;      /* 66 Flags                                            */
				/*      bit 0 set if default system font                     */
				/*      bit 1 set if horiz offset table should be used */
				/*      bit 2 byte-swap flag (thanks to Intel idiots)  */
				/*      bit 3 set if mono spaced font                */
   int8  *h_table;    /* 68 offset to horizontal offset table                */
   int16 *off_table;  /* 72 offset to character offset table                 */
   int8  *dat_table;  /* 76 offset to font data                      */
   int16  form_width; /* 80 Form width (#of bytes /scanline in font data)    */
   int16  form_height;/* 82 Form height (#of scanlines in font data)         */
   struct _font *next_font;  /* 84 Pointer to next font in face              */
} tGemFont;


/** local variables **/
static char err_string[256];	/* make an error message here */
static gem_font_count;		/* add new gem font counts to the workstations */
static TTF_GDOS_INF_RECORD *pInfo;	/* pointer to ttf-gdos info */
static struct {			/* save/restore old ttf-gdos info */
   uint8 nr_gemfonts;
   uint8 first_font;
   WORKSTN_RECORD *pw;	/* pointer to wkstn record to be altered */
} save[30];


/** this is a box for reporting user messages **/
static char usr_msg[32];

static OBJECT rs_object[] = {
    -1, 1, 1,G_BOX,   0x0, 0x0, 0x21190L, 0,0,25,3,  /* 0 dialog box */
     0,-1,-1,G_STRING,0x20,0x0, usr_msg,  1,1,22,1   /* 1 progress string */
     };
/*   ^  ^  ^    ^      ^    ^    ^        ^ ^  ^ ^
     |  |  |    |      |    |    |        | |  | +-- ob_height height of obj (now chars, but
     |  |  |    |      |    |    |        | |  +---- ob_width  width  of obj (must cnvt to pixels
     |  |  |    |      |    |    |        | +------- ob_y      y coord relative to parent
     |  |  |    |      |    |    |        +--------- ob_x      x coord relative to parent
     |  |  |    |      |    |    +-----------------  ob_spec   obj determines meaning (p11-55,60)
     |  |  |    |      |    +----------------------  ob_state  current state of obj (p.11-61 MM)
     |  |  |    |      +---------------------------  ob_flags  attributes for obj (p.11-60 MM)
     |  |  |    +----------------------------------  ob_type   object type (p. 11-59 MM)
     |  |  +---------------------------------------  ob_tail   ptr to last child of obj or -1
     |  +------------------------------------------  ob_head   ptr to first child of obj or -1
     +---------------------------------------------  ob_next   ptr to next sibling or -1

*/


/** globals **/

extern int16 _contrl[];         /* for finding font chain from vdi */


/****************************************
* check that ttf-gdos is loaded,
* save pointer to config info
* */
static bool is_ttf_gdos( void )
{
   /** look for ttf-gdos ... **/

   pInfo = (TTF_GDOS_INF_RECORD *)vq_vgdos();
   if( (int32)pInfo == GDOS_NONE	/* no gdos at all */
	|| ((int)pInfo&1) != 0		/* pointer to add address*/
	|| pInfo > (void *)get_sysvar(phystop)	/* points outside valid memory*/
	|| pInfo < (void *)0x800 /* bot of mem */
	|| pInfo->magic_nr != MAGIC_NR ) {	/* ttf-gdos not there */
	 return FALSE;
   } /* if */

   if( pInfo->version > MY_VERSION ) {
      form_alert( 1, "[3][please use latest version][good idea]");
      return FALSE;
   } /* if */

   if( pInfo->version < MY_VERSION ) {
      form_alert( 1, "[3][please upgrade to|latest version of ttf-gdos][OK]" );
      return FALSE;
   } /* if */

   return TRUE;

} /* is_ttf_gdos() */


/************************************************
* open the vdi workstation
*/
static int16 init_wkstn( int16 dev_nr )
{
int work_in[12], work_out[57];
int handle;
int i;
   handle = 0; /* ttf-gdos can use handle 0 to represent the gem AES handle */
   work_in[0] = dev_nr;
   for(i=1; i<10; i++) work_in[i]=1;
   work_in[10] = 2;
   if( dev_nr>10 ) v_opnwk(work_in, &handle, work_out);
   else v_opnvwk(work_in, &handle, work_out);
/*   printf( "opened wk %d, handle is %d\n", work_in[0], handle ); getchar(); */
   return handle;
} /* init_wkstn() */


/*******************************************************
* load fonts for device
* get font chain and dump fonts (width table only) in current directory
*/
static void dump_gem_fonts( int16 dev_nr )
{
const tGemFont *pgf;	/* pointer to the font chain */
int16 handle;
char *err_msg;
register tGemFont *phdr;	/* pointer to font we are making */
char *const gempath = ((void**)pInfo)[-1];
FILE *fp;
int xdial,ydial,wdial,hdial;         /* co-ords for dialog box */
int  x,y,w,h;

   handle = init_wkstn( dev_nr );	/* open the workstation */
   if( handle == 0 ) {
      sprintf( err_string, "[3][can't connect to %s][skip]", dev_nr>10? "printer": "screen" );
      form_alert(1, err_string );
      return;
   } /* if */
   if( vst_load_fonts( handle, 0 ) == 0 ) {
      sprintf( err_string, "[3][can't find fonts for %s][skip]", dev_nr>10? "printer": "screen" );
      goto error0;
   } /* if */
   pgf = *(tGemFont **)(&_contrl[10]);	/* get pointer to font chain */
   save[dev_nr].pw->first_font = gem_font_count;

   /******************
   * loop thru font chain, 
   * writing a new font file for each font found in the chain
   * count the fonts so we can assign them to the workstations
   * this can take quite a while, so report progress as we go
   */

   form_center (&rs_object,&xdial,&ydial,&wdial,&hdial);
   x=y=w=h=0;
   form_dial (FMD_START,x,y,w,h,xdial,ydial,wdial,hdial);      /* reserve room */

   for( ; pgf!=NULL; pgf=pgf->next_font ) {
   const uint16 nr_entries = pgf->last_ade - pgf->first_ade + 1;
   const uint32 size_wid = (nr_entries+1) * sizeof(int16);	/* sizeof(*(tGemFont*)->off_table) */
   register int16 *char_tbl;
   register uint16 i;
      
      /* printf( "line %d, %.32s, %d points\n", (int)__LINE__, pgf->name, pgf->size ); */
      sprintf( usr_msg, "storing gem fonts: %d", gem_font_count );
      objc_draw( &rs_object, 0, 2, xdial, ydial, wdial, hdial ); /* draw the dialog box */
      phdr = (tGemFont*)malloc( sizeof(tGemFont) + size_wid );
      if( phdr == NULL ) {
	 err_msg = "[3][Not enough memory|to dump font][OK]";
	 goto error1;
      } /* if */
      
      *phdr = *pgf;	   /* copy header data */
      phdr->off_table = (int16*)sizeof(tGemFont);
      memcpy( phdr+1, pgf->off_table, size_wid );
      phdr->dat_table = 0L;
      
      /** convert font to intel format before dumping **/
      for( i = nr_entries+1, char_tbl = (int16*)(phdr+1); i > 0; i--, char_tbl++ ) {
	   Swapw(*char_tbl);
      } /* for */

      /* swap header words and longs */
      phdr->flags &= ~MOT_FLAG;
      Swapw(phdr->font_id);		Swapw(phdr->size);
      Swapw(phdr->first_ade);		Swapw(phdr->last_ade);
      Swapw(phdr->top); 		Swapw(phdr->ascent);
      Swapw(phdr->half);		Swapw(phdr->descent);
      Swapw(phdr->bottom);
      Swapw(phdr->max_char_width);	Swapw(phdr->max_cell_width);
      Swapw(phdr->left_offset); 	Swapw(phdr->right_offset);
      Swapw(phdr->thicken);		Swapw(phdr->ul_size);
      Swapw(phdr->lighten);		Swapw(phdr->skew);
      Swapw(phdr->flags);		Swapl(phdr->h_table);
      Swapl(phdr->off_table);		Swapl(phdr->dat_table); 
      Swapw(phdr->form_width);		Swapw(phdr->form_height);

      /* printf( "line %dn", (int)__LINE__); getchar(); */
      FONT_FILE_NAME( gempath+pInfo->len_gem_path, gem_font_count );
      fp = fopen( gempath, "wb" );
      if( fp == NULL ) {
	 err_msg = "[3][can't open gem font file|%s][OK]";
	 goto error2;
      } /* if */

      /** write the font header **/
      if( fwrite( phdr, sizeof( *phdr), 1, fp ) != 1 ) {
	 goto error3;
      } /* if */
      
      /** write the character offset table **/
      if( fwrite( phdr+1, size_wid, 1, fp ) != 1 ) {
	 goto error3;
      } /* if */
   
      fclose( fp );
      free( phdr );
      gem_font_count++;
   } /* for */
   save[dev_nr].pw->nr_gemfonts = gem_font_count - save[dev_nr].pw->first_font;
   (void)vst_unload_fonts( handle, 0 );
   if( dev_nr>10 ) v_clswk(handle);
   else v_clsvwk(handle);

   form_dial( FMD_FINISH, x, y, w, h, xdial, ydial, wdial, hdial );  /* release its room */
   return;

error3:
   fclose(fp);
   err_msg = "[3][can't write to gem font file|%s][OK]";
error2:
   sprintf( err_string, err_msg, strerror(errno) );
   free( phdr );
error1:
   form_dial( FMD_FINISH, x, y, w, h, xdial, ydial, wdial, hdial );  /* release its room */
error0:
   (void)vst_unload_fonts( handle, 0 );
   if( dev_nr>10 ) v_clswk(handle);
   else v_clsvwk(handle);
   form_alert(1, err_string );
} /* dump_gem_fonts() */


/***********************************
* create new list of gem fonts to reconfigure ttf-gdos for the new gem fonts, 
* then call fontwid.app
*/
static void call_fontwid( void )
{
FILE_NAME *const pf0 = calloc( gem_font_count, sizeof(FILE_NAME) );
register FILE_NAME * pf = pf0;
char *const gempath = ((char**)pInfo)[-1];	/* use ttf-gdos hook */
register int16 i;
int16 r;
int16 save_nr_gemfonts = pInfo->nr_gemfonts;
FILE_NAME *save_gem_font_ptr;

   /******************
   * fontwid saves only 20 chars of file path (including null at end)
   * we need 3 chars for the file name
   */
   #define MAX_PATH_LEN 17
   #define STR(s) #s
   #define STRVAL(s) STR(s)

   if( pInfo->len_gem_path < MAX_PATH_LEN ) {

      /** this fills ttf-gdos info structure with the gem fonts **/
      pInfo->nr_gemfonts = gem_font_count;
      save_gem_font_ptr = ((FILE_NAME**)pInfo)[-2];
      ((FILE_NAME**)pInfo)[-2] = pf0;
      for( i=0; i<gem_font_count; i++, pf++ ) {
	 FONT_FILE_NAME( &pf[0][0], i );
      } /* for */
   
      r = Pexec( 0, "fontwid.app", NULL, NULL );
      if( r != 0 ) {
	 sprintf( err_string, "[3][error while running fontwid.app|%s][OK]", strerror(-r) );
	 form_alert(1, err_string );
      } /* if */
      pInfo->nr_gemfonts = save_nr_gemfonts;;
      ((void**)pInfo)[-2] = save_gem_font_ptr;
   } else {
      sprintf( err_string,
               "[3][gem path '%.*s'|must be less than " STRVAL(MAX_PATH_LEN) " chars][OK]",
	       pInfo->len_gem_path, gempath );
      form_alert(1, err_string );
   } /* if */
   free( pf0 );
   
} /* call_fontwid() */


/*****************************
* save details of every workstation
*/
static void save_inf( void )
{
register uint16 n = pInfo->nr_wkstns;
register WORKSTN_RECORD *pw = pInfo->workstn_table;
   for( ; n>0; n--, pw++ ) {
      save[pw->id].nr_gemfonts = pw->nr_gemfonts;
      save[pw->id].first_font = pw->first_font;
      save[pw->id].pw = pw;
      /* printf( "wkstn %d, %s, 1st font is %d, nr is %d\n", pw->id, &pw->driver_name, pw->first_font, pw->nr_gemfonts ); */
   } /* for */
} /* save_inf() */


/***************************
* restore ttf-gdos to its previous config
*/
static void tidy_up( void )
{
register uint16 n = pInfo->nr_wkstns;
register WORKSTN_RECORD *pw = pInfo->workstn_table;
char *const gempath = ((void**)pInfo)[-1];
register int i = gem_font_count;
int xdial,ydial,wdial,hdial;         /* co-ords for dialog box */
int  x,y,w,h;

   form_center (&rs_object,&xdial,&ydial,&wdial,&hdial);
   x=y=w=h=0;
   form_dial (FMD_START,x,y,w,h,xdial,ydial,wdial,hdial);      /* reserve room */
   sprintf( usr_msg, "please wait ..." );
   objc_draw( &rs_object, 0, 2, xdial, ydial, wdial, hdial ); /* draw the dialog box */

   for( ; n>0; n--, pw++ ) {
      /* printf( "wkstn %d, %s, 1st font is %d, nr is %d\n", pw->id, &pw->driver_name, pw->nr_gemfonts, pw->first_font ); */
      pw->nr_gemfonts = save[pw->id].nr_gemfonts;
      pw->first_font = save[pw->id].first_font;
   } /* for */

   for( ; i>=0; i-- ) {
      FONT_FILE_NAME( gempath+pInfo->len_gem_path, i );
      remove( gempath );
   } /* for */

   form_dial( FMD_FINISH, x, y, w, h, xdial, ydial, wdial, hdial );  /* release its room */

} /* tidy_up() */


int main( void )
{
   appl_init();
   graf_mouse(ARROW, 0);
   rsrc_obfix(rs_object,0);        /* chg coord from char to pixel */
   rsrc_obfix(rs_object,1);        /* chg coord from char to pixel */
   if( is_ttf_gdos() ) {      /* is ttf-gdos loaded? */
      save_inf();
      dump_gem_fonts( Getrez()+2 );	/* screen workstation */
      dump_gem_fonts( 21 );		/* printer */
      call_fontwid();
      tidy_up();
   }
   else form_alert(1, "[3][this program needs TTF-GDOS][OK]");
   appl_exit();
   exit(0);
} /* main() */

/********************** end of fix-fwid.c **********************/
