/***** (C) 1998-2002 Trevor Blight *****
*
*  $Id: font.c 1.10 2001/03/10 22:33:57 tbb Exp $
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
***********************************************************
*
* this file manages font loading & generation:-
*
* when fonts are loaded for a workstation,
* a chain of font headers and width tables is generated (no font data is needed yet)
*
* when text is output, the relevant chars are generated if necessary
*
* font data is kept in a font cache, and refreshed whenever it is used again.
* Any font may drop out of the cache if it is used for a while, so then it
* needs to be regenerated.
* The pointer to the font data in the cache may change under our feet, so
* we need to be careful not to make cpoies of it.
*
****************************************/

#include <stddef.h>
#include <osbind.h>

#include "ttf-gdos.h"
#include "ttf-defs.h"

/***************************
* font data structures
*
*
*/

/** set of flags to track if character has been generated in the font 
 ** bitmap data.  This goes in the cache at the end of the bitmap data **/
#define CH_FL_SZ (GEM_LAST_CH - GEM_FIRST_CH + 1)/8
typedef uint8 used_flags[ CH_FL_SZ ];   /* 1 bit for each char */

typedef struct {
   int16 ttf_nr;               /* .. or GEM_MAGIC, same size as ttf-gdos.h */
   tGEM_FONT_HDR gemFont;
} tDATA;

typedef struct {
   uint32 data_size; /* size of form data */
   tDATA font_data;
  /* the width tables go here */
  /* the cvt goes here when the interpreter is implemented*/
} tFONT;

#define GEM_MAGIC 0xface

#define IS_GEM( pf )  (((tDATA *)((size_t)(pf) - offsetof(tDATA, gemFont)))->ttf_nr == GEM_MAGIC )
#define IS_TTF( pf )  (((tDATA *)((size_t)(pf) - offsetof(tDATA, gemFont)))->ttf_nr >= 0 )

/** template used to generate new fonts **/
static tFONT font_template = {
   0,        /* data_size */
   0,        /* ttf number */
   { 0,0,{ "" },GEM_FIRST_CH,GEM_LAST_CH,0,0,0,0,0,0,0,0,0,0,0,
     0x5555,0x5555,4,NULL,NULL,NULL,0,0,NULL }
};

/* mem overhead reserved in cache for tables, fpgm, etc */
#define RESERVED 10000

/** vdi param block arrays used for local driver calls ... **/
/** overlay these with scratch memory??, with start code?? <<< **/
int16 xintin[256];
int16 xptsin[10];
int16 xintout[44];
int16 xptsout[12];
struct contrl_io xcontrl;

static int16 ttf_count = 0;  /* nr ttf fonts in cache */
static uint32 max_data_size;   /* size of largest cache data block */

/***********************
*  free a font's data
*  ttf fonts have different header structures than gem fonts
*/
static void
free_font( tGEM_FONT_HDR * const fp )
{
   assert( IS_TTF(fp) || IS_GEM(fp) );
   if( IS_TTF(fp) ) {
      if( fp->form_data != NULL ) release_mem( fp->form_data );
      (void)free( (tFONT *)((size_t)fp - offsetof(tFONT, font_data.gemFont)) );  /* assume successful */
      assert( ttf_count > 0 );
      ttf_count--;
   }
   else {
      (void)free( (tDATA *)((size_t)fp - offsetof(tDATA, gemFont)) );  /* assume successful */
   } /* if */
} /* free_font() */


/***********************************
*  insert font (*fp) into chain (*head)
*  chain is in order of increasing font id then increasing point size
*  free the font if one with same size & id is already in the chain
*/
static void
insert( tGEM_FONT_HDR **const head, tGEM_FONT_HDR *const fp )
{
tGEM_FONT_HDR **pp = head;
register tGEM_FONT_HDR *next = *pp;

   /*** scan chain for insertion position **/
   while( (next != NULL) && (*(uint32*)next < *(uint32*)fp) ) { /* id & siz combined into one uint32 */
      pp = &(next->next_font);
      next = *pp;
   } /* while */
   if( (next != NULL) && (*(uint32*)next == *(uint32*)fp) ) {
      /* already there!! */
      free_font( fp );
   }
   else {
      assert( (next == NULL) || (next->font_id > fp->font_id) ||
          ((next->font_id == fp->font_id) && (next->size > fp->size)) );
      /*** insert new font into chain ***/
      fp->next_font = next;
      *pp = fp;
   } /* if */
} /* insert() */


static __inline__ int
exist_font( tGEM_FONT_HDR **head, uint16 id, uint16 size )
{
register tGEM_FONT_HDR *next = *head;
register uint32 f = ((uint32)id << 16) + size;

   /*** scan chain **/
   while( (next != NULL) && (*(uint32*)next < f) ) { /* id & siz combined into one uint32 */
      next = next->next_font;
   } /* while */
   return (next!=NULL) && (*(uint32*)next == f);
} /* exist_font() */


/*******************************
* return handle of another workstation on same device,
* and with fonts already loaded
* return NULL if no such workstation found
*/
static ACTIVE_WKS_REC *find_partner( const ACTIVE_WKS_REC *const pd )
{
register ACTIVE_WKS_REC *scan     = active_wk_tbl;
register int16           sav_root = pd->root_handle;	/* <<< use wsid ??? */
register int             n;

   n = MAX_WKS;
   while( (n > 0 )                      /* loop while entries exist ... */
       && ((scan->root_handle != sav_root)  /* ... and no partner found ... */
       || (scan->wks_fonts.font_chain == NULL)  /* ... with fonts loaded */
       || ( scan == pd )) ) {
      scan++; n--;
   } /* while */
   assert( (n<=0) ||
               (scan->root_handle == sav_root)
	        && (scan->wks_fonts.font_chain != NULL)
		&& (scan != pd) );
   return n>0 ? scan : NULL;

} /* find_partner() */


/*******************************
*  free font memory for this workstation
*  check for sharing with partner
*/
void free_wks_fonts( ACTIVE_WKS_REC *const pd )
{
   if( find_partner( pd ) == NULL ) {
   register tGEM_FONT_HDR *fp = pd->wks_fonts.font_chain;
      while( fp != NULL ) {
      register tGEM_FONT_HDR *const old_fp = fp;
         fp = fp->next_font;
         free_font(old_fp);
      } /* while */
      if( ttf_count <= 0 ) {
         assert( ttf_count == 0 );
         remove_cache();
      } /* if */
      if(pd->wks_fonts.scratch_adr != NULL ) {
         (void)free(pd->wks_fonts.scratch_adr);        /* assume successful */
         pd->wks_fonts.scratch_adr = NULL;
      } /* if */
   } /* if */
   pd->wks_fonts.font_chain = NULL;
} /* free_wks_fonts() */


/** define a few fast swap functions ... **/
#define Swapw(v) __asm__( "rorw #8,%0" : "=d" ((uint16)v) : "0" ((uint16)v) )
#define Swaph(v) __asm__( "swap %0" : "=d" ((uint32)v) : "0" ((uint32)v))
#define Swapl(v) __asm__( "rorw #8,%0; swap %0; rorw #8,%0" : "=d" ((uint32)v) : "0" ((uint32)v))


/***********************************
* load GEM font,
* create motorola format header structure from data in font file,
* check for correct font format
* return pointer to font, or NULL if error.
*/
static tGEM_FONT_HDR *
load_gem_font( const FILE_NAME name)
{
FILE_H fh;
int i, nch;
const int32 size = get_sysfile_siz( name );
int is_mot;
register tGEM_FONT_HDR* fp;

#define FP ((tGEM_FONT_HDR*)NULL)

   if( size <= 0 ) goto error0;        /* missing file ?? */
   fp = (tGEM_FONT_HDR*)hi_malloc(size+2);        /* ie sizeof(tDATA.magic) */
   if (fp == NULL) goto error0;
   *((int16*)fp) = GEM_MAGIC;        /* set magic number */
   ((int16*)fp)++;

   fh = open_sys_file( name );
   if (fh < 0) goto error1;

   /* read file */
   if( Fread(fh, size, fp) < 0 ) goto error2;
   (void)Fclose( fh );     /* assume successful */

   is_mot = fp->flags&0x0004;

   if (!is_mot) {
   register int  ib;
   register uint16 *p = &fp->first_ade;
      /* swap header words and longs */
      for( ib = (int)(&FP->form_height - &FP->first_ade); ib>=0; ib-- ) {
         Swapw(*p);
         p++;
      } /* for */
      Swapw(fp->font_id);
      Swapw(fp->size);
      Swaph(fp->h_table);
      Swaph(fp->off_table);
      Swaph(fp->form_data);
      fp->flags |= 0x0004;        /* now in motorola format */
   } /* if */

   nch = fp->last_ade - fp->first_ade + 1;
   if( nch <= 0 ) goto error1;        /* bad font file ?? */
   if( (uint32)fp->off_table > size ) goto error1;	/* watch out - might only be loading width files */
   if( (uint32)fp->form_data > size ) goto error1;

   assert( size >= sizeof(tGEM_FONT_HDR)
                   + (((fp->flags&0x0002) != 0) ? nch*sizeof(*fp->h_table) : 0)
                   + (nch+1) * sizeof(*fp->off_table)
                   + (uint32)fp->form_width*fp->form_height );

   /* set horizontal offset table */
   if ((fp->flags&0x0002) != 0) {
      if( (uint32)fp->h_table >= size ) goto error1;        /* bad font file ?? */
      fp->h_table += (uint32)fp/sizeof(*fp->h_table);
   } /* if */

   /* set char wid table */
   fp->off_table += (uint32)fp/sizeof(*fp->off_table);
   if (!is_mot)                   /* swap offset array words */
      for (i = 0; i <= nch; i++) {
          Swapw(fp->off_table[i]);
         assert( (i==0 && fp->off_table[0]==0)
                || (fp->off_table[i] >= fp->off_table[i-1]) );
      } /* for */

   /* set bitmap */
   fp->form_data += (uint32)fp/sizeof(*fp->form_data);

   return fp;

error2:
   (void)Fclose( fh );     /* assume successful */
error1:
   assert( IS_GEM( fp ) );
   free_font(fp);        /* assume successful */
error0:
   return NULL;
} /* load_gem_font() */


/***********************************************
* install font chain for a workstation
*
*/
static void read_font_chain( ACTIVE_WKS_REC *const pd )
{
register tGEM_FONT_HDR *fp IPTR;
FILE_NAME *fdp = GemFont_Tablep + pd->pw->first_font;
register int n, ttf_nr;

   assert( pd->wks_fonts.font_chain == NULL );
   pd->wks_fonts.font_chain = NULL;  /* <<< remove ??? */

   /* first load gem fonts */
   for( n=pd->pw->nr_gemfonts ; n>0; n-- ) { /** all gem fonts **/
      fp = load_gem_font( *fdp );
      if( fp != NULL ) {
         insert( &pd->wks_fonts.font_chain, fp );
      } /* if */
      fdp++;
   } /* for */

   if( (pd->pw->id < 30) || (pd->pw->id > 40) )  {  /* don't load for meta file */
   const FONT_RECORD *fdp = TTFont_Tablep;
      assert( font_template.font_data.gemFont.first_ade == GEM_FIRST_CH);
      assert( font_template.font_data.gemFont.last_ade == GEM_LAST_CH);
      assert( font_template.font_data.gemFont.lighten == 0x5555 );
      assert( font_template.font_data.gemFont.skew == 0x5555 );

      /** set up cache **/
      if( ttf_count <= 0 ) {
         assert( ttf_count == 0 );
         max_data_size = install_cache( ((uint32)setup_inf.cache_size)<<10 );
      } /* if */

      /******************
      *  loop to process all fonts for all sizes
      *  if error occurs, continue with next font
      ******************/
      for( ttf_nr=0; ttf_nr<setup_inf.nr_ttfonts; ttf_nr++ ) { /** all tt fonts **/
      register int32 q = fdp->psize_mask;
      register uint16 p;
      FILE_H fh = open_sys_file( TTFont_Tablep[ttf_nr].font_name );

         if( fh > 0 ) {
            font_template.font_data.ttf_nr = ttf_nr;
            font_template.font_data.gemFont.font_id = fdp->id;

            if( get_ttf_data( ttf_nr, font_template.font_data.gemFont.name, fh ) == OK 
                && get_glyf_data( ttf_nr, fh ) == OK ) {
               for( q=fdp->psize_mask, p=7; q!=0; q<<=1, p++ ) {

                  assert( p < 7+32);

                  /** create a font for this size??  **/
                  if( (q<0) && !exist_font( &pd->wks_fonts.font_chain, fdp->id, p ) ) {
                  tFONT *const fp0 = (tFONT*)hi_malloc( sizeof(tFONT) + sizeof(uint16)*(GEM_LAST_CH - GEM_FIRST_CH + 2) );
                     if( fp0 != NULL ) {
                        *fp0 = font_template;
                        fp = &fp0->font_data.gemFont;
                        fp->size = p;
                        assert( fp->off_table == NULL );

                        /*** generate font header & width table ***/
                        fp->off_table = (uint16 *)(fp+1);
                        gen_font_header( ttf_nr, fp, pd->dpix, pd->dpiy );
			assert( ttf_count >= 0 );
			ttf_count++;
                        if( (uint32)fp->form_height*fp->form_width <= max_data_size-RESERVED ) {
                           insert( &pd->wks_fonts.font_chain, fp );
                           assert( exist_font( &pd->wks_fonts.font_chain, fp->font_id, fp->size ) );
                        }
                        else {
			/* this font is too big for the data cache */
#if 0
			/* so reduce nr chars to make it fit */
			register uint16 new_wid = ((max_data_size-RESERVED)/fp->form_height & ~1) << 3; /* max width in bits */
			register char c = fp->first_ade;
			register uint16 *p = fp->off_table + 2;
			   while( *p <= new_wid ) c++, p++;
			   fp->last_ade = c-1;
			   fp->form_width = ((p[-1]+15)&~15)>>3;
			   assert( (uint32)fp->form_height*fp->form_width <= max_data_size-RESERVED );
			   assert( (uint32)fp->form_height*(((*p+15)&~15)>>3) > max_data_size-RESERVED );
                           insert( &pd->wks_fonts.font_chain, fp );
                           assert( exist_font( &pd->wks_fonts.font_chain, fp->font_id, fp->size ) );
#else
			/* so don't allow it to be chosen */
                           free_font( fp );
#endif
                        } /* if data fits in cache */
                        /****/

                     } /* if allocated space */
                  } /* if select size */
               } /* for all sizes */
               /* free_interp(); */
               release_glyf_data();
            } /* if( get ttf data ... */
            (void)Fclose( fh );
         } /* if( fh > 0 */
         fdp++;
      } /* for all ttfonts */
      if( ttf_count <= 0 ) {
         assert( ttf_count == 0 );
         remove_cache();
      } /* if */

   } /* if not meta file */

} /* read_font_chain() */


/***************************************
*
*  load fonts for a workstation
*/
void vst_load_fonts(const Vdi_Params *vdi_param_adr)
{
register ACTIVE_WKS_REC *const pd = find_wkstnp( vdi_param_adr->contrl_adr->handle );

   assert(vdi_param_adr->contrl_adr->opcode == OP_LDFNT);

   if( pd == NULL ) {
      goto error;
   } /* if */

   if( pd->wks_fonts.font_chain == NULL ) {
   register const ACTIVE_WKS_REC *const pp = find_partner( pd );
      /*
      ** the scratch buffer is used for the char effects & the edge list
      ** min size for edge list is 132*dpiy/2 bytes
      ** min size for effects buffer is dpix/2*dpiy/2 bytes
      ** effects buffer must be exact nr longs
      ** (the scratch buffer will also used by the ttf interpreter,
      **  so it also needs to be large enough for this)
      */

      if( pp == NULL ) {
      register const uint16 size_bytes = ((pd->dpix>264?(pd->dpix>>1):132)*(pd->dpiy>>1)+3)&~3;
         /*** no partner found ***/
	 read_font_chain( pd );
	 if( pd->wks_fonts.font_chain == NULL ) goto error;
	 pd->wks_fonts.scratch_size = size_bytes >> 1;
	 assert( (pd->wks_fonts.scratch_size&1) == 0);
	 pd->wks_fonts.scratch_adr = hi_malloc( size_bytes );
         if( pd->wks_fonts.scratch_adr == NULL ) {
            pd->wks_fonts.scratch_size = 0;
         } /* if */
      }
      else {
         /*** share font data with partner ***/
         pd->wks_fonts = pp->wks_fonts;
         assert( pd->pw->id <= 10 );
         assert( pp->pw->id <= 10 );
         assert( pp != pd );
         assert( pd->wks_fonts.font_chain != NULL );
      } /* if */
   }
   else {
      /*** fonts already loaded !! ==> do nothing ***/
   } /* if */

   /** contrl[] must have at least 12 elements for load fonts **/
   assert( (int16*)vdi_param_adr->contrl_adr > vdi_param_adr->intin_adr
        || (int16*)vdi_param_adr->contrl_adr+12 <= vdi_param_adr->intin_adr );
   assert( (int16*)vdi_param_adr->contrl_adr > vdi_param_adr->intout_adr
        || (int16*)vdi_param_adr->contrl_adr+12 <= vdi_param_adr->intout_adr );
   assert( (int16*)vdi_param_adr->contrl_adr > vdi_param_adr->ptsin_adr
        || (int16*)vdi_param_adr->contrl_adr+12 <= vdi_param_adr->ptsin_adr );
   assert( (int16*)vdi_param_adr->contrl_adr > vdi_param_adr->ptsout_adr
        || (int16*)vdi_param_adr->contrl_adr+12 <= vdi_param_adr->ptsout_adr );

   {
#if 1
   register struct {
      struct contrl_io    contrl;
      FONT_CONTRL_RECORD  wks_fonts;
      } *const pcontrl = (void *)vdi_param_adr->contrl_adr;
      pcontrl->wks_fonts = pd->wks_fonts;   /* set up font data in contrl[] */
      call_driver( vdi_param_adr, pd );

#else
   /** if contrl[] is not 12 words long, use this code */
   struct {
      struct contrl_io    contrl;
      FONT_CONTRL_RECORD  wks_fonts;
   } const new_contrl = { *vdi_param_adr->contrl_adr, pd->wks_fonts };
   struct contrl_io *const sav = vdi_param_adr->contrl_adr;
      vdi_param_adr->contrl_adr = &new_contrl;
      call_driver( vdi_param_adr, pd );
      vdi_param_adr->contrl_adr = sav;
      *sav = new_contrl.contrl;
#endif
   }

   /* get initial font */
   {
   Vdi_Params xpb = { &xcontrl, xintin, xptsin, xintout, xptsout };
      xcontrl.opcode = 38;  /* opcode for vqt_attributes */
      xcontrl.nptsin = 0;   /* entries in ptsin[] */
      xcontrl.nintin = 0;   /* entries in intin[] */
      xcall_driver( &xpb, pd );   /* get info from driver */
      pd->font_id = xpb.intout_adr[0];   /* initial font id selected by driver */
   }

   return;

error:        /* couldn't load fonts */
   vdi_param_adr->intout_adr[0] = 0;       /* nr new fonts */
   vdi_param_adr->contrl_adr->nintout = 1;  /* length intout[] */
   return;

} /* vst_load_fonts() */


/*****************************************************************
*
*  unload fonts for a workstation
*/
void vst_unload_fonts(register const Vdi_Params *vdi_param_adr)
{
register ACTIVE_WKS_REC *const pd = find_wkstnp( vdi_param_adr->contrl_adr->handle );

   assert(vdi_param_adr->contrl_adr->opcode == OP_ULDFNT);

   if( pd != NULL ) {
      free_wks_fonts( pd );
      assert( pd->wks_fonts.font_chain == NULL );
      call_driver( vdi_param_adr, pd );
   } /* if */
} /* vst_unload_fonts() */


/*****************
* set font id for a workstation
* called from hook
*/
void vst_font( const Vdi_Params *vdi_param_adr )
{
register ACTIVE_WKS_REC * const pd = find_wkstnp( vdi_param_adr->contrl_adr->handle );

   assert(vdi_param_adr->contrl_adr->opcode == OP_SETFNT);

   if( pd != NULL ) {
      call_driver( vdi_param_adr, pd );
      pd->font_id = vdi_param_adr->intout_adr[0];   /* font id selected by driver */
   } /* if */
} /* vst_font() */


/**********************
* text output function:
* find current font id & size,
* update cache memory lru & data
*/
void v_gtext( const Vdi_Params *vdi_param_adr )
{
register const ACTIVE_WKS_REC * const pd = find_wkstnp( vdi_param_adr->contrl_adr->handle );

   assert( vdi_param_adr->contrl_adr->opcode == OP_GTEXT
        || vdi_param_adr->contrl_adr->opcode == OP_GDP
        && vdi_param_adr->contrl_adr->subfunc == 10 );

   if( pd != NULL ) {
   register tGEM_FONT_HDR *fp = pd->wks_fonts.font_chain;

      /*******************
      * need to ensure that character bitmaps are generated
      * note: fp == NULL if meta file
      */
      if( fp != NULL && pd->font_id >= 2 ) {
      Vdi_Params xpb = { &xcontrl, xintin, xptsin, xintout, xptsout };
      register const int16 font_id = pd->font_id;

         xcontrl.opcode = 131;  /* opcode for vqt_fontinfo */
         xcontrl.nptsin = 0;   /* entries in ptsin[] */
         xcontrl.nintin = 0;   /* entries in intin[] */
         xcall_driver( &xpb, pd );   /* inquire font height */
         assert( xcontrl.nptsout == 5 );
         assert( xcontrl.nintout == 2 );

         while( fp->font_id < font_id ) {  /* look for current font id */
            fp = fp->next_font;
            assert( fp != NULL );
         } /* while */

         {
	 /* find font with current id & font_top */
         register tGEM_FONT_HDR *sav_fp = NULL;
         register int16 font_top = xptsout[9];
         register int16 font_bottom = xptsout[1];

         do {
            assert( fp != NULL );
	    assert( fp->font_id == font_id );
	    /* assert( fp->top <= font_top ); not true for kandinsky!! */
            if( fp->top == font_top && fp->bottom == font_bottom ) {
	       sav_fp = fp;	/* found the current font */
	       break;
	    }
	    else if( fp->top == (font_top>>1) && fp->bottom == (font_bottom>>1) ) {
	       /* found double height font, keep going */
	       sav_fp = fp;
	    } /* if */
            fp = fp->next_font;
         } while( fp != NULL && fp->font_id == font_id );

	 fp = sav_fp;   /* fp = pointer to current font header */
	 }

         /** only need to generate data for TT fonts, gem fonts are OK **/
         if( fp != NULL && IS_TTF(fp) ) {
	    assert( fp->font_id == font_id );
	    assert( (fp->top == xptsout[9] && fp->bottom == xptsout[1])
		|| (fp->top == (xptsout[9]>>1)  && fp->bottom == (xptsout[1]>>1)) );
            if( fp->form_data == NULL ) {
            uint32 size = (uint32)fp->form_height*fp->form_width + CH_FL_SZ;
               /* memory for font data doesn't exist, so get it .... */
               find_mem( size, &fp->form_data ); /* from cache */
               /* assert( (size&3)==0 ); .. allocated space is exact nr longs */
               if( fp->form_data == NULL ) {
                  /* failed!!, shouldn't happen as fonts exist only if data fits into cache */
#ifndef NDEBUG
	          sprintf( assert_buf, "no cache mem for font %32s, %d points\r\n", fp->name, fp->size );
		  Cconws( assert_buf );
#endif
	          return;
	       } /* if */

               ((tFONT*)((size_t)fp - offsetof(tFONT, font_data.gemFont)))->data_size = size-CH_FL_SZ;
               /* clear the form data & char flags, we know it is rounded up to long boundary */
               {
               register uint32 *p = (uint32*)fp->form_data;
               register int32 i = (size-1)>>2;
               assert( i>=0 );
               do {
                  *p++ = 0;
               } while( --i >= 0);
	       
               }
            }
            else {
               /* make this memory most recently used */
               use_mem( fp->form_data );
            } /* if */

   	    /** force driver to update its copy of data pointer, etc **/
	    xcontrl.opcode = 107;  /* opcode for vst_point */
	    xcontrl.nptsin = 0;   /* entries in ptsin[] */
	    xcontrl.nintin = 1;   /* entries in intin[] */
	    {
	    register uint16 d = fp->size;
	       if( xptsout[9]!=fp->top ) d *= 2;
	       xintin[0] = d;
	    }
	    /* assert( font_top == xptsout[9] ); */
	    xcall_driver( &xpb, pd );	/* set font height */
	    assert( xcontrl.nptsout == 2 );
	    assert( xcontrl.nintout == 1 );
	    assert( (fp->top == xptsout[1]) || (fp->top == xptsout[1]>>1) );
   
            /** update character data */
            {
            const int16 *s = vdi_param_adr->intin_adr;             /* input_string */
            int16 n = vdi_param_adr->contrl_adr->nintin;
            int16 nr_gen = 0;  /* nr chars to generate */
            int16 *t = xintin;   /* string of chars to generate */
            const int16 ttf_nr = ((tDATA*)((size_t)fp - offsetof(tDATA, gemFont)))->ttf_nr;
            register uint8* used_flags = fp->form_data + ((tFONT*)((size_t)fp - offsetof(tFONT, font_data.gemFont)))->data_size;

            assert( TTFont_Tablep[ttf_nr].id == fp->font_id );
            if( vdi_param_adr->contrl_adr->opcode == OP_GDP /* OP_V_JUSTIFIED */ ) {
               s+=2; /* skip space flags */
               n-=2;
            } /* if */

            while( n>0 ) { /* for all chars in input string */
            /* test if font data for each char in text is defined */
            register const uint16 c = *s; /* offset into used flags array */
               if( c <= fp->last_ade ) {
               register uint8 *const a = &used_flags[(c-GEM_FIRST_CH)>>3];
               register const uint8 q = 1<<((c-GEM_FIRST_CH)&7);
                  if( (*a & q) == 0 ) {
                     *a |= q;   /* char is now defined */
                     *t++ = c;  /* list this char */
                     nr_gen++;
                     assert( nr_gen <= 256 );
                  } /* if */
               } /* if */
               s++, n--;
            } /* while */

            if( nr_gen > 0 ) {
            FILE_H fh = open_sys_file( TTFont_Tablep[ttf_nr].font_name );
               if( fh >= 0 ) {
                  if( set_tables( ttf_nr, fh ) == OK ) {
                     /* if cache set up to be less than min size,
                     ** form_data could have disappeared to make room for 
                     ** ttf tables.  Check, just to be sure */
		     if( fp->form_data != NULL ) {
                        gen_font_data( fh, ttf_nr, fp, pd, nr_gen, xintin );
		     }
		     else {
			/* failed!!, shouldn't happen as fonts exist only if data fits into cache */
#ifndef NDEBUG
			sprintf( assert_buf, "no cache mem for font %32s, %d poin\r\n", fp->name, fp->size );
			Cconws( assert_buf );
#endif
		     } /* if */
                  }
		  else {
#ifndef NDEBUG
		     sprintf( assert_buf, "couldn't set tables for %s\r\n", TTFont_Tablep[ttf_nr].font_name );
		     Cconws( assert_buf );
#endif
		  } /* if */
                  (void)Fclose( fh );
               }
	       else {
#ifndef NDEBUG
		  sprintf( assert_buf, "couldn't open %s\r\n", TTFont_Tablep[ttf_nr].font_name );
		  Cconws( assert_buf );
#endif
	       } /* if */
	    } /* if */
            }
         } /* if IS_TTF... */
      } /* if fp != NULL and font_id != 0 */

      call_driver( vdi_param_adr, pd );

   } /* if pd != NULL */

} /* v_gtext() */

/***************** end of font.c ************/



