/*******************************************************
*
*  $Id: ttf-dump.c 1.4 1999/11/27 21:33:36 tbb Exp $
*
* utility to choose & dump a font
* 
* (evolved from choosfnt by Steve Pedler)
*
********************************************************/


/* includes */
#include <aesbind.h>
#include <vdibind.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <osbind.h>
#include <sysvars.h>
#include "ttf-gdos.h"
#include "ttf-dump.h"


/** defines **/

#if 0
#define dprintf(x) printf x
#define dgetchar getchar
#else
#define dprintf(x)
#define dgetchar()
#endif

 /* ttf-gdos can use handle 0 to represent the gem AES handle */
#define GRAF_HANDLE 0

#define MAX_NAMES 8           /* size of selector box */
#define FONT_ELEMENT 43       /* length of font name string */
#define NO_INDEX -1
#define MOT_FLAG 0x0004
#define HOR_FLAG 0x0002
#ifndef FALSE
#define FALSE 0
#define TRUE (!0)
#endif


/** typedefs **/

typedef unsigned char bool;

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


/** globals **/

extern int16 _contrl[];         /* for finding font chain from vdi */

/*
** the chooser can display only MAX_NAMES names at a time, but there may be 
** more than this.  If the user clicks on a name and then scrolls the list,
** the selected name may disappear. The variable iSelected is used to keep
** track of selected names even if they scroll out of the box.  It takes
** the value NO_INDEX iff no font is selected.
*/

/* we will build an array of these to contain all the font info */
typedef struct tFontName {
   const tGemFont *pFont;
   char name[FONT_ELEMENT];
} tFontName;

static tFontName *name_table;
static int        iSelected = NO_INDEX;
static int        nr_names;
static bool       fMot;
static bool       fWidOnly;
static char       gem_file_name[16];

static OBJECT *chooser;
static int handle;


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


/* ------------------------------------------------------------------- */
static bool is_ttf_gdos( void )
{
uint32 *p = (uint32 *)vq_vgdos();

   /** look for ttf-gdos ... **/

   return( p != (uint32*)GDOS_NONE
	&& ((uint8)p&1) == 0
	&& p <= (uint32 *)get_sysvar(phystop)
	&& p >= (uint32 *)0x800 /* bot of mem */
	&& *p == MAGIC_NR );
} /* is_ttf_gdos() */


/* ------------------------------------------------------------------- */
static bool init_wkstn( bool is_prn )
{
int work_in[12], work_out[57];
int i;
   handle = GRAF_HANDLE; /* ttf-gdos can use handle 0 to represent the gem AES handle */
   work_in[0] = is_prn? 21: (Getrez()+1);
   for(i=1; i<10; i++) work_in[i]=1;
   work_in[10] = 2;
   if( is_prn ) v_opnwk(work_in, &handle, work_out);
   else v_opnvwk(work_in, &handle, work_out);
   dprintf(( "\033Hopened wk %d, handle is %d\n", work_in[0], handle )); dgetchar();
   return handle != 0;
} /* init_wkstn() */


/* ------------------------------------------------------------------- */
/* toggle highlight over a selected font name with object nr obj */
void highlight( int obj )
{
register OBJECT *po = chooser+obj;
   graf_mouse(M_OFF, 0);
   objc_change( chooser, obj, 0,
                chooser[ROOT].ob_x, chooser[ROOT].ob_y, chooser[ROOT].ob_width, chooser[ROOT].ob_height, /* po->ob_x, po->ob_y, po->ob_width, po->ob_height, */
		po->ob_state ^ SELECTED, 1 );	/* toggle state */
   graf_mouse(M_ON, 0);

} /* highlight() */


/* -------------------------------------------------------------------- */
/* Display the font names in the dialog box */
static void show_names( int top )
{
int i, j;
   graf_mouse(M_OFF, 0);
   for(i=NAME1, j=top; i<=NAME8; i++, j++ ) {
      ((TEDINFO *)chooser[i].ob_spec)->te_ptext = name_table[j].name;
      ((TEDINFO *)chooser[i].ob_spec)->te_txtlen = strlen( name_table[j].name );
      if( j == iSelected ) chooser[i].ob_state |= SELECTED;  /* highlight if selected */
      else chooser[i].ob_state &= ~SELECTED;
   }
   objc_draw(chooser, NAMEBOX, MAX_DEPTH, chooser[ROOT].ob_x, chooser[ROOT].ob_y, chooser[ROOT].ob_width, chooser[ROOT].ob_height );
   graf_mouse(M_ON, 0);
} /* show_names() */


/* ------------------------------------------------------------------ */

/* simulate the GEM method of tracking slider positions */
static void set_slider_pos( const int top )
{
long pos;

   if( nr_names<=MAX_NAMES ) pos = 0;
   else {
      pos =top*1000L/(nr_names-MAX_NAMES);
      if(pos>1000) pos =1000;
      if(pos<0) pos =0;
   }
   chooser[SLIDER].ob_y =pos*(long)(chooser[SLIDEBAR].ob_height-chooser[SLIDER].ob_height)/1000;
}


/* ------------------------------------------------------------------ */
/* simulate the GEM method of setting slider sizes */

static void set_slider_size( void )
{
long size;

   if( nr_names <= MAX_NAMES ) size =100;   /* avoid divide-by-zero error */
   else size = (100*MAX_NAMES)/nr_names;
   if(size>100) size = 100;
   if(size<1) size = 1;
   chooser[SLIDER].ob_height =(chooser[SLIDEBAR].ob_height*size)/100;
   if(chooser[SLIDER].ob_height<(chooser[SLIDEBAR].ob_height/8)) chooser[SLIDER].ob_height =chooser[SLIDEBAR].ob_height/8;
} /* set_slider_size() */


/* ------------------------------------------------------------
** Function to select a font from the chooser dialog.
*   Returns:
*	 TRUE  if the user clicked on OK and had selected a name;
*	 FALSE if the user clicked on Cancel, or on OK but there was no selected name
*/

static bool select_font( bool is_prn )
{
int button, cx, cy, cw, ch, mousey, slidey, dum;
int index, i, double_click;
long pos;
static int top = 0;                 /* first name set to the top */

   wind_update(BEG_UPDATE);

   set_slider_size();                     /* set slider size and position, like a GEM window */
   set_slider_pos(top);

   ((TEDINFO *)chooser[CHACTION].ob_spec)->te_ptext = " Choose GDOS font ";
   ((TEDINFO *)chooser[CHTITLE].ob_spec)->te_ptext = is_prn? " Printer font list: ": " Screen font list: ";
   ((TEDINFO *)chooser[GEMFNAME].ob_spec)->te_ptext = gem_file_name;
   ((TEDINFO *)chooser[GEMFNAME].ob_spec)->te_txtlen = sizeof(gem_file_name);
   form_center(chooser, &cx, &cy, &cw, &ch);
   form_dial(FMD_START, 0, 0, 0, 0, cx, cy, cw, ch);
   objc_draw(chooser, ROOT, MAX_DEPTH, cx, cy, cw, ch);

   /*
   ** the chooser can show up to MAX_NAMES names. If there are fewer than this,
   ** the empty slots are disabled by clearing the TOUCHEXIT flags
   */
   for( i=0; i<MAX_NAMES; i++ ) {
      if( i<nr_names ) {
	 chooser[NAME1+i].ob_flags |= TOUCHEXIT;
      }
      else {
	 chooser[NAME1+i].ob_flags &= ~TOUCHEXIT;
      } /* if */
   } /* for */
   show_names( top );    /* display the font names */

   /** the main loop **/
   
   do {
      button =form_do( chooser, GEMFNAME );
      dprintf(( "\033Hbutton is %x\n", button)); dgetchar();
      if(button&0x8000) {     /* double click */
	 double_click = TRUE;
	 button &= 0x7fff;
      }
      else double_click = FALSE;
      if(button ==DNARR) {
	 if((top+MAX_NAMES)<nr_names) {
	    top++;   /* next name in the list */
	    show_names( top );
	    set_slider_pos(top);
	    objc_draw(chooser, SLIDEBAR, MAX_DEPTH, cx, cy, cw, ch);
	 }
      }
      else if(button ==UPARR) {
	 if(top>0) {
	    top--;
	    show_names( top );
	    set_slider_pos(top);
	    objc_draw(chooser, SLIDEBAR, MAX_DEPTH, cx, cy, cw, ch);
	 }
      }
      else if(button ==SLIDEBAR && nr_names>MAX_NAMES) { /* handle clicks on the slidebar */
	 graf_mkstate(&dum, &mousey, &dum, &dum);     /* where is the mouse - above or below the slider? */
	 objc_offset(chooser, SLIDER, &dum, &slidey);
	 if(mousey<slidey) {                       /* mouse is above the slider */
	    top-=MAX_NAMES;                        /* move up one page of names */
	    if(top<0) top =0;
	 }
	 else {
	    top+=MAX_NAMES;
	    if(top>(nr_names-MAX_NAMES)) top =nr_names-MAX_NAMES;
	 } /* if */
	 show_names( top );
	 set_slider_pos(top);
	 objc_draw(chooser, SLIDEBAR, MAX_DEPTH, cx, cy, cw, ch);
      }
      else if(button ==SLIDER && nr_names>MAX_NAMES) {      /* handle the slider */
	 pos =graf_slidebox(chooser, SLIDEBAR, SLIDER, 1);   /* the position the user wants */
	 chooser[SLIDER].ob_y =pos*(long)(chooser[SLIDEBAR].ob_height-chooser[SLIDER].ob_height)/1000;
	 top =pos*(nr_names-MAX_NAMES)/1000;
	 if(top<0) top =0;
	 if(top>(nr_names-MAX_NAMES)) top =nr_names-MAX_NAMES;
	 show_names( top );
	 objc_draw(chooser, SLIDEBAR, MAX_DEPTH, cx, cy, cw, ch);
      }
      else if(button>=NAME1 && button<=NAME8) {
	 /*** the user has clicked on a font name ***/
	 index = top+button-NAME1;
         dprintf(( "\033Hindex is %d\n", index)); dgetchar();
	 if( iSelected == index ) {    /* the name is already selected */
	    assert( iSelected >=0 );
	    assert( iSelected < nr_names );
	    iSelected = NO_INDEX;      /* deselect it */
	    highlight(button);         /* remove the highlight from the name */
	 }
	 else {
	    /* is the currently selected font name displayed in the box? */
	    if( iSelected!=NO_INDEX
	     && (iSelected+NAME1-top)>=NAME1
	     && (iSelected+NAME1-top)<=NAME8 ) {
	       highlight( iSelected+NAME1-top );        /* remove highlight */
	    } /* if */
	    iSelected = index;    /* set the index for the new selection */
	    highlight(button);         /* and highlight it */
	 } /* if */
	 if(double_click) button =CHOOSEOK;   /* if double clicked on a name, exit immediately */
      } /* if */
      assert( iSelected == NO_INDEX || iSelected >=0 );
      assert( iSelected == NO_INDEX || iSelected < nr_names );
   } while(button!=CHOOSEOK && button!=CHOOSECA);


   /** returned from form, process user actions **/

   dprintf(( "\033HiSelected is %d\n", iSelected)); dgetchar();
   dprintf(( "selected name is %s\n", name_table[iSelected].name ));
   dprintf(( "gem file name is %s\n", 
		     ((TEDINFO *)chooser[GEMFNAME].ob_spec)->te_ptext ));
   dprintf(( "%s format%s\n", 
      chooser[MOT].ob_state&SELECTED ? "motorola" : "intel",
      chooser[WIDONLY].ob_state&SELECTED ? ", width tables only" : "" ));
   dgetchar();

   assert( (chooser[MOT].ob_state & SELECTED) != (chooser[INTEL].ob_state&SELECTED) );
   fMot = (chooser[MOT].ob_state & SELECTED) != 0;
   fWidOnly = (chooser[WIDONLY].ob_state & SELECTED) != 0; 
   chooser[button].ob_state &= ~SELECTED;
   form_dial( FMD_FINISH, 0, 0, 0, 0, cx, cy, cw, ch );
   wind_update( END_UPDATE );
   return button==CHOOSEOK;
} /* select_font() */


/* --------------------------------------------------------------------
** get the list of font names.
** put names into name_table[]
** set nr_names = number of font names found 
*/
static bool get_fontnames( const tGemFont *const pf )
{
register const tGemFont *p;
register int i;
register tFontName *pn = NULL;

   /** count nr fonts **/
   for( i=0, p=pf; p!=NULL; i++, p=p->next_font );
   nr_names = i;
   dprintf(( "\033Hthere are %d names\n", nr_names )); dgetchar();
   name_table = malloc( nr_names * sizeof(tFontName) );
   if( name_table == NULL ) {
      form_alert(1, "[3][Not enough memory|to list font names][OK]");
      return FALSE;
   } /* if */
   
   /** get all font names **/
   for( i=0, p=pf, pn=name_table ; i<nr_names ; i++, p=p->next_font, pn++ ) {
      assert( p!=NULL );
      pn->pFont = p;
      sprintf( pn->name, "%-0.32s, %d pts", p->name, p->size );
      assert( strlen(pn->name) < sizeof(pn->name) );
      dprintf(( "%\033Hs\n", pn->name ));
   } /* for */
   dgetchar();
   
   return TRUE;

} /* get_fontnames() */


/* ------------------------------------------------------------------ */

static void dump_font()
{
const tGemFont *const pgf = name_table[iSelected].pFont;
const uint16 nr_entries = pgf->last_ade - pgf->first_ade + 1;
const uint32 size_wid = (nr_entries+1) * sizeof(uint16);
uint32 size_hor;
register tGemFont *phdr;
FILE *fp;
int16 dummy;
int16 clip_array[4] = { 0, 0, 100, 100 };
OBJECT *generating;
int cx, cy, cw, ch;
char *err_str;

   dprintf(( "\033Hgenerating fonts ... " )); dgetchar();
   rsrc_gaddr( R_TREE, GENFONTS, &generating );
   form_center( generating, &cx, &cy, &cw, &ch);
   form_dial(FMD_START, 0, 0, 0, 0, cx, cy, cw, ch);
   objc_draw( generating, ROOT, MAX_DEPTH, cx, cy, cw, ch);
   vst_font( handle, pgf->font_id );
   vst_point( handle, pgf->size, &dummy, &dummy, &dummy, &dummy );

   assert( (pgf->flags&MOT_FLAG) != 0 );
   size_hor = pgf->flags&HOR_FLAG ? nr_entries : 0;

   phdr = (tGemFont*)malloc( sizeof(tGemFont) + size_wid );
   if( phdr == NULL ) {
      err_str = "[3][Not enough memory|to convert font][OK]";
      goto error0;
   } /* if */
   
   *phdr = *pgf;        /* copy header data */
   phdr->h_table = (int8*)sizeof(tGemFont);
   phdr->off_table = (int16*)((uint32)phdr->h_table + size_hor);
   phdr->dat_table = (int8*)((uint32)phdr->off_table + size_wid);
   memcpy( phdr+1, pgf->off_table, size_wid );
   
   if( !fMot ) {
   register int16 *char_tbl = (int16*)(phdr+1);
   register uint16 i;
      for (i = nr_entries+1; i > 0; i--) {
	   Swapw(*char_tbl);
	   char_tbl++;
      } /* for */

      /* swap header words and longs */
      phdr->flags &= ~MOT_FLAG;
      Swapw(phdr->font_id);             Swapw(phdr->size);
      Swapw(phdr->first_ade);           Swapw(phdr->last_ade);
      Swapw(phdr->top);                 Swapw(phdr->ascent);
      Swapw(phdr->half);                Swapw(phdr->descent);
      Swapw(phdr->bottom);
      Swapw(phdr->max_char_width);      Swapw(phdr->max_cell_width);
      Swapw(phdr->left_offset);         Swapw(phdr->right_offset);
      Swapw(phdr->thicken);             Swapw(phdr->ul_size);
      Swapw(phdr->lighten);             Swapw(phdr->skew);
      Swapw(phdr->flags);               Swapl(phdr->h_table);
      Swapl(phdr->off_table);           Swapl(phdr->dat_table); 
      Swapw(phdr->form_width);          Swapw(phdr->form_height);
   } /* if */

   fp = fopen( gem_file_name, "wb" );
   if( fp == NULL ) {
      err_str = "[3][can't open gem font file][OK]";
      goto error1;
   } /* if */

   /** write the font header **/
   assert( phdr != NULL );   
   if( fwrite( phdr, sizeof( *phdr), 1, fp ) != 1 ) {
      goto error2;
   } /* if */
   
   if( size_hor != 0 ) {
      /** write horizontal offset table **/
      assert( pgf->h_table != NULL );   
      if( fwrite( pgf->h_table, nr_entries, 1, fp ) != 1 ) {
	 goto error2;
      } /* if */
   } /* if */

   /** write the character offset table **/
   if( fwrite( phdr+1, size_wid, 1, fp ) != 1 ) {
      goto error2;
   } /* if */

   if( !fWidOnly ) {
      /** write the character data table **/
      int q;
      unsigned char char_array[2] = { '\0', '\0' };
      dprintf(( "\033Hgenerating character data\n" )); dgetchar();
      vs_clip( handle, 1, clip_array );
      for( q=nr_entries, *char_array=pgf->first_ade; q>0; q--, (*char_array)++ ) {
         v_gtext( handle, 200, 200, char_array );
      } /* for */
      vs_clip( handle, 0, clip_array );
      assert( pgf->dat_table != NULL );   
      if( fwrite( pgf->dat_table, pgf->form_width, pgf->form_height, fp )
						      != pgf->form_height ) {
	 goto error2;
      } /* if */
   } /* if */
   fclose( fp );
   free( phdr );
   form_dial( FMD_FINISH, 0, 0, 0, 0, cx, cy, cw, ch );
   return;
   
error2:
   fclose( fp );
   err_str = "[3][can't write to|gem font file][OK]";
error1:
   free( phdr );
error0:
   form_dial( FMD_FINISH, 0, 0, 0, 0, cx, cy, cw, ch );
   form_alert(1, err_str );
} /* dump_font() */


/* ------------------------------------------------------------------ */
static void choose_font(void)
{
OBJECT *loading;
int cx, cy, cw, ch;
bool is_prn;

   is_prn = (form_alert( 1, "[0][select device][screen|printer]" )==2);
   dprintf(( "\033Hselected %s workstation\n", is_prn? "printer": "screen" ));

   if( init_wkstn( is_prn ) ) {

      graf_mouse(BUSY_BEE, 0);
      dprintf(( "ready to load fonts ... " )); dgetchar();
      rsrc_gaddr( R_TREE, LDGFONTS, &loading );
      form_center( loading, &cx, &cy, &cw, &ch);
      form_dial(FMD_START, 0, 0, 0, 0, cx, cy, cw, ch);
      objc_draw( loading, ROOT, MAX_DEPTH, cx, cy, cw, ch);
      (void)vst_load_fonts(handle, 0);
      form_dial( FMD_FINISH, 0, 0, 0, 0, cx, cy, cw, ch );
      dprintf(( "\033Hdone\nnow getting font names ..." )); dgetchar();
      if( get_fontnames( *(tGemFont **)(&_contrl[10]) ) ) {
	 dprintf(( "done\n" )); dgetchar();
	 graf_mouse(ARROW, 0);
	 while( select_font( is_prn ) ) {
	    if( iSelected == NO_INDEX ) {
	       form_alert( 1, "[1][You must choose|a font to dump][Try Again]" );
	    }
	    else if( gem_file_name[0] == '\0' ) {
	       form_alert( 1, "[1][You must choose a|"
			 "gem font file name][Try Again]" );
	    }
	    else {
	       dump_font();
	       gem_file_name[0] = '\0'; /* reset entries for next round */
	       iSelected = NO_INDEX;
	    } /* if */
	 } /* while */
      } /* if */

      vst_unload_fonts(handle, 0);

      free(name_table);

      dprintf(( "\033Hclosing %s workstation ...", is_prn? "printer": "screen" ));
      if( is_prn ) v_clswk(handle);
      else v_clsvwk(handle);
   }
   else form_alert(1, "[3][Can't open workstation][OK]");

} /* choose_font() */


/* ------------------------------------------------------------------- */
int main(void)
{
   appl_init();
   graf_mouse(ARROW, 0);
   if(is_ttf_gdos()) {      /* is GDOS loaded? */
      if(rsrc_load("ttf-dump.rsc")) {
	 rsrc_gaddr( R_TREE, CHOOSER, &chooser );
	 choose_font();
	 rsrc_free();
	 }
	 else form_alert(1, "[3][Cannot open resource file][OK]");
   }
   else form_alert(1, "[3][this program needs TTF-GDOS][OK]");
   appl_exit();
   exit(0);
} /* main() */

/********************* end of file *************************/
