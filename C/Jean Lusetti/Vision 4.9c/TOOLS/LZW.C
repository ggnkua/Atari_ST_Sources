/**************************************************/
/* Gestion de la compression et de la             */
/* D‚compression du format Lempel Ziv Welch (LZW) */
/**************************************************/
#include  <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

#include "xgem.h"
#include "logging.h"

#define MAX_BITS       12   /* Taille maximale d'un code en bits */
#define MAXN           (1 << MAX_BITS)
#define TIFF           0
#define GIF            1
#define LZW_DECOMPRESS 0
#define LZW_COMPRESS   1
#define OGIF_000       0
#define OGIF_030       1
#define OTIF_000       2
#define OTIF_030       3



FILE          *stream ;
int           last_ind ;       /* Indice du dernier ‚l‚ment du dico      */
int           first_code ;     /* Indice de la premiŠre chaine du dico   */
int           last_code ;      /* Code du dernier ‚l‚ment                */
int           limit ;
int           last_result ;
int           pt_cprs ;
int           operation ;      /* 0 : D‚compression, 1 : Compression     */
int           type_flag ;      /* GIF ou TIFF                            */
unsigned char cprs_buffer[260] ;
unsigned char *pt_out ;        /* Pointeur sur les donn‚es d‚compress‚es */


/* Inspir‚ de la routine GIF de FRACTINT */
/* Dans LZW.S */
extern unsigned char *dstack ;
extern unsigned char *suffix ;
extern int           *sizeofstring ;
extern unsigned int  *prefix ;
extern unsigned char *stackp ;
extern unsigned char out_value ;
extern int           slot, top_slot, newcodes ;
extern int           code_size ; /* Taille d'un code en bits, ‚volue       */
                                 /* Au cours du d‚compactage               */
                                 /* code_size doit ˆtre initialis‚         */
                                 /* Avant l'appel de lzw_...               */
extern long          bit_shift ;
extern int           clear_code ; /* RAZ du dictionnaire                   */
extern int           eoi_code ;   /* Plus d'information … d‚compresser     */
extern int           start_size ;
extern int           old_code ;   /* Code pr‚c‚dent                        */
extern int           code ;       /* Code … interpr‚ter                     */
extern unsigned char *pt_in ;     /* Pointeur sur les donn‚es compress‚es   */
extern int           bit1 ;       /* Indice premier et dernier bit du code  */
extern unsigned char *last_data ;

/* Compression par Hash Code */
#define TABLE_SIZE     5003
int *oldcode = NULL ;
int *currentcode = NULL ;
int *newcode = NULL ;
int prefix_code, suffix_char ;

void (*get_nextcode)(void) ;     /* Pointeur sur une des 3 fonctions suivantes */
void gif_nextcode(void) ;        /* Dans LZW.S, retour dans code */
void tiff_nextcode(void) ;       /* Dans LZW.S, retour dans code */
void tiff_030nextcode(void) ;    /* Dans LZW.S, retour dans code */
void (*output_code)(int code) ;     /* Pointeur sur une des 3 fonctions suivantes */
void output_gifcode(int code) ;     /* Dans LZW.S  code = D0 */
void output_tiffcode(int code) ;    /* Dans LZW.S  code = D0 */
void output_tiff030code(int code) ; /* Dans LZW.S  code = D0 */

/* Variables dans LZW.S */
extern int lzw_optimization ;


size_t lzw_Cdecompress(unsigned char *in, size_t nb_bytein, unsigned char *out, size_t nb_byteout)
{
  unsigned char* last_out = out + nb_byteout-1 ;
  size_t nb_out ;
  long   last_bit ;
  int    fini   = 0 ;
  int    i, j ;
  int    fcode ;
  int    fastloop ;

  pt_out     = out ;
  last_data  = in+nb_bytein-1 ;
  last_bit   = (long)nb_bytein << 3 ;
  while (!fini)
  {
    get_nextcode() ; /* Dans code */
    LoggingDo(LL_DEBUG, "code=%x", code) ;
    if ((code == clear_code) || (code == eoi_code))
    {
/*      LoggingDo(LL_DEBUG, "code=%s", (code==clear_code) ? "clear":"eoi") ;*/
      /* RAZ du dictionnaire et reprise du */
      /* Nombre de bits de codage initial  */
      code_size = start_size ;
      slot      = newcodes ;
      sizeofstring[slot] = 0 ;
      top_slot = 1 << code_size ;
      if (type_flag != GIF) top_slot-- ;
      if (code == eoi_code)
      {
        fini = 1 ;
        stackp   = dstack ;
      }
      else
      {
        while (code == clear_code) get_nextcode() ;
        if (code >= slot) code = 0 ;
        old_code = out_value = fcode = code ;
        *stackp++ = code ;
      if (get_nextcode == tiff_030nextcode) fini = (bit_shift > last_bit) ;
      else                                  fini = (pt_in > last_data) ;
      }
    }
    else
    {
      fcode = code ;
      if (fcode >= slot)
      {
        if (fcode > slot) code = slot ;
        fcode = old_code ;
        *stackp++ = out_value ;
      }

      fastloop = 0 ;
      while (fcode >= newcodes)
      {
        j = i = sizeofstring[fcode] ;
        if (i > 0)
        {
          fastloop = -1 ;
          do
          {
/*            LoggingDo(LL_DEBUG, "j=%d", j) ;*/
            *(pt_out+j) = suffix[fcode] ;
            fcode       = prefix[fcode] ;
          }
          while (--j > 0) ;
          *pt_out = (unsigned char) fcode ;
          pt_out += ++i ;
          if ( pt_out > last_out )
          {
            LoggingDo(LL_DEBUG,"LZWOverflow");
            break ;
          }
        }
        else
        {
          *stackp++ = suffix[fcode] ;
          fcode = prefix[fcode] ;
        }
      }
      if (fastloop == 0) *stackp++ = (unsigned char) fcode ;
      
      if (slot < top_slot)
      {
        sizeofstring[slot] = sizeofstring[old_code]+1 ;
        suffix[slot] = out_value = (unsigned char) fcode ;
        prefix[slot++] = old_code ;
        old_code = code ;
      }

      if (slot >= top_slot)
        if (code_size < 12)
        {
          ++code_size ;
          top_slot = 1 << code_size ;
          if (type_flag != GIF) top_slot-- ;
        }
    }

    while (stackp > dstack)
    {
      --stackp ;
      *pt_out++ = *stackp ;
    }

    if (!fini)
    {
      if (get_nextcode == tiff_030nextcode) fini = (bit_shift > last_bit) ;
      else                                  fini = (pt_in > last_data) ;
    }
  }

  nb_out = pt_out-out ;

  return nb_out ;
}

int lzw_init(int ticode, unsigned char *start, int flag)
{
  if ( start == NULL ) /* Compression */
  {
    oldcode = (int*) Xcalloc( 3*sizeof(int), TABLE_SIZE ) ;
    if ( oldcode == NULL ) return -3 ;

    currentcode = oldcode + TABLE_SIZE ;
    newcode     = currentcode + TABLE_SIZE ;
    operation   = LZW_COMPRESS ;
  }
  else /* Decompression */
  {
    sizeofstring = (int*) Xcalloc( 3*sizeof(int), MAXN ) ;
    if ( sizeofstring == NULL ) return -3 ;

    prefix    = (unsigned int*)sizeofstring + MAXN ;
    dstack    = (unsigned char*) (prefix + MAXN) ;
    suffix    = dstack + MAXN ;
    operation = LZW_DECOMPRESS ;
  }

  type_flag = flag ;
  if (type_flag == GIF) bit1 = 0 ;
  else                  bit1 = 7 ;
  if (ticode == 1) ticode = 2 ;
  clear_code = 1 << ticode ;  /* RAZ du dictionnaire            */
  eoi_code   = 1+clear_code ; /* Plus d'informations            */
  first_code = 1+eoi_code ;   /* Premier code disponible        */
  last_code  = first_code-1 ; /* Pas encore d'‚l‚ment dans dico */
  start_size = 1+ticode ;
  limit      = (1 << (1+ticode))-1-first_code ;
  if (type_flag != GIF) limit-- ;
  old_code   = -1 ;
  pt_in      = start ;
  pt_cprs    = 0 ;
  bit_shift  = 0 ;
  memzero( cprs_buffer, 260 ) ;

  stackp    = dstack ;
  slot      = newcodes = 1+eoi_code ;
  out_value = 0 ;
  top_slot  = 1 << code_size ;
  if (type_flag != GIF) top_slot-- ;

  if (type_flag == GIF)
  {
    get_nextcode     = gif_nextcode ;
    output_code      = output_gifcode ;
    lzw_optimization = OGIF_000 ;
  }
  else
  {
    if (MachineInfo.cpu >= 30L)
    {
      get_nextcode     = tiff_030nextcode ;
      output_code      = output_tiff030code ;
      lzw_optimization = OTIF_030 ;
    }
    else
    {
      get_nextcode     = tiff_nextcode ;
      output_code      = output_tiffcode ;
      lzw_optimization = OTIF_000 ;
    }
  }

  if (start == NULL) /* Compression */
  {
    last_ind    = 0 ;
    prefix_code = -1 ;
    bit_shift   = 0 ;
    output_code(clear_code) ;
    limit++ ;
  }

  return 0 ;
}

long lzw_end(void)
{
  unsigned char block_count = 0 ;

  if (operation == LZW_COMPRESS)
  {
    output_code(prefix_code) ;
    output_code(eoi_code) ;
    block_count = 1+pt_cprs ;
    if (type_flag == GIF) fwrite(&block_count, 1, 1, stream) ;
    fwrite(cprs_buffer, block_count, 1, stream) ;
    if ( oldcode ) Xfree( oldcode ) ;
    oldcode = currentcode = newcode = NULL ;
  }
  else
  {
    if ( sizeofstring != NULL ) Xfree( sizeofstring ) ;
    sizeofstring = NULL ; prefix = NULL ; dstack = NULL ; suffix = NULL ;
  }

  return (long)block_count ;
}

int lzw_compress(unsigned char *src, long nb, FILE *flux, long *nb_out)
{
  unsigned char bcount ;
  int           hx, d ;

  stream    = flux ;
  pt_in     = src ;
  last_data = pt_in+nb-1 ;
  *nb_out   = 0 ;
  if (prefix_code == -1) prefix_code = *pt_in++ ;
  while (pt_in <= last_data)
  {
    suffix_char = *pt_in++ ;
    hx          = (prefix_code ^ (suffix_char << 5)) % TABLE_SIZE ;
    d           = 1 ;
    for (;;)
    {
      if (currentcode[hx] == 0)
      {
        output_code(prefix_code) ;

        if (pt_cprs >= 250)
        {
          bcount = (unsigned char) pt_cprs ;
          *nb_out      = *nb_out+bcount ;
          if (type_flag == GIF) fwrite(&bcount, 1, 1, stream) ;
          if (fwrite(cprs_buffer, 1, bcount, stream) != bcount)
            return -2 ;
          cprs_buffer[0] = cprs_buffer[pt_cprs] ;
          pt_cprs        = 0 ;
          bit_shift     &= 0x07L ;
        }

        d = first_code+last_ind ;
        if (d < MAXN)
        {
          oldcode[hx]     = prefix_code ;
          newcode[hx]     = suffix_char ;
          currentcode[hx] = d ;
          last_ind++ ;
        }
        if (d >= first_code+limit)
        {
          if (code_size < 12)
          {
            code_size++ ;
            limit = (1 << code_size)-first_code ;
            if (type_flag != GIF) limit-- ;
          }
          else
          {
            output_code(clear_code) ;
            last_ind = 0 ;
            memzero(currentcode, TABLE_SIZE*sizeof(int)) ;
            code_size   = start_size ;
            limit       = (1 << code_size)-first_code ;
            if (type_flag != GIF) limit-- ;
          }
        }
        prefix_code = suffix_char ;
        break ;
      }
      if ((oldcode[hx] == prefix_code) && (newcode[hx] == suffix_char))
      {
        prefix_code = currentcode[hx] ;
        break ;
      }
      hx += d ;
      d  += 2 ;
      if (hx >= TABLE_SIZE) hx -= TABLE_SIZE ;
    }
  }

  if (type_flag == TIFF)
  {
    *nb_out += lzw_end() ;
    pt_cprs  = 0 ;
  }

  return 0 ;
}
