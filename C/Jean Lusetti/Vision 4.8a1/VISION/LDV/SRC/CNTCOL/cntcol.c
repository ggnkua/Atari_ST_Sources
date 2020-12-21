#define PCGEMLIB 1 /* Set to 1 if PureC is used */

#if PCGEMLIB
#include <aes.h>
#include <vdi.h>
#else
#include <aesbind.h>
#include <vdibind.h>
#endif

#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "..\..\ldg.h"
#include "..\..\vapi.h"
#include "..\..\ldv.h"

/* Prototypes */
LDV_INFOS* cdecl GetLDVCapabilities(VAPI* vapi) ;
LDV_STATUS cdecl PreRun(LDV_IMAGE* in, LDV_PARAMS* params, LDV_IMAGE* out) ;
LDV_STATUS cdecl Run(LDV_IMAGE* in, LDV_PARAMS* params, LDV_IMAGE* out) ;

/* Global variables */
PROC Proc[]  = {
                 "GetLDVCapabilities", "LDV capabilities", (void*)GetLDVCapabilities,
                 "PreRun", "Run initialization", (void*)PreRun,
                 "Run", "LDV operation", (void*)Run,
              } ;

char Info[] = "LDV" ;

LDGLIB Ldg[] = {
                 0x0107, /* Lib version                       */
                      3, /* Number of functions in lib        */
                   Proc, /* Pointers to our functions         */
                   Info, /* Lib information                   */
                    0x0, /* Lib flags                         */
                   NULL, /* On exit, free VDI handle (unused) */
               } ;

#define CAPS (LDVF_ATARIFORMAT | LDVF_SUPPORTPROG | LDVF_OPINPLACE | LDVF_SUPPORTCANCEL | LDVF_NOSELECTION | LDVF_NOCHANGE)

LDV_INFOS LdvInfos = {
                       (short) sizeof(LDV_INFOS), /* size of this structure */
                       TLDV_MODIFYIMG,            /* LDV Type               */
                       "Jean Lusetti/Seedy",      /* Authors                */
                       {
                         {  1,  1, CAPS },        /* 1 bitplane capabilities  */
                         {  2,  2, CAPS },        /* 2 bitplane capabilities  */
                         {  4,  4, CAPS },        /* 4 bitplane capabilities  */
                         {  8,  8, CAPS },        /* 8 bitplane capabilities  */
                         { 16, 16, CAPS },        /* 16 bitplane capabilities */
/* Not yet               { 24, 24, CAPS },                                    */
                         { 32, 32, CAPS },        /* 32 bitplane capabilities */
                         { 0, 0, 0UL }            /* End of this list         */
                       },
                     } ;

VAPI*         Vapi = NULL ;
unsigned char VapiLog = 0 ;
unsigned char UseVAlloc ;     /* Use VISION's allocation routines if possible */
unsigned char NbBitsIn[256] ; /* Number of bits set to 1 for every integer in [0;255] */

typedef struct _CNTCOL_DATA
{
  /* Input data */
  LDV_IMAGE*  in ;
  LDV_PARAMS* params ;
  FILE*       report_file ;
  short       method ; /* 0: auto, 1: bit array of colors, 2: sorted colors */
}
CNTCOL_DATA, *PCNTCOL_DATA ;

typedef struct _CC1_CONTEXT
{
  void*          line_colors ;
  unsigned long  so_line_colors ;
  unsigned char* unique_colors_bits ;
  unsigned long  so_unique_colors_bits ;
  short          nplanes ;
  unsigned char* indexes ; /* Allocated only if nplanes <= 8 */
  unsigned long  so_indexes ;
  unsigned long  used_bytes ;
}
CC1_CONTEXT, *PCC1_CONTEXT ;

typedef struct _CC2_CONTEXT
{
  unsigned char* line_sorted ;
  unsigned char* img_sorted ;
  unsigned long  nb_img_colors ;
  unsigned long  nb_img_colors_max ;
  short          nplanes ;
  unsigned char* indexes ; /* Allocated only if nplanes <= 8 */
  unsigned long  so_indexes ;
  unsigned long  used_bytes ;
}
CC2_CONTEXT, *PCC2_CONTEXT ;

typedef struct _CC3_CONTEXT
{
  unsigned char* line_sorted ;
  unsigned long  so_line_colors ;
  unsigned char* unique_colors_bits ;
  unsigned long  so_unique_colors_bits ;
  short          nplanes ;
  unsigned char* indexes ; /* Allocated only if nplanes <= 8 */
  unsigned long  so_indexes ;
  unsigned long  used_bytes ;
}
CC3_CONTEXT, *PCC3_CONTEXT ;

typedef union _CC_CONTEXT
{
  /* Specific data for each method */
  CC1_CONTEXT c1 ; /* color table for a line and bitcolor array globally */
  CC2_CONTEXT c2 ; /* sort/reduce each line and globally                 */
  CC3_CONTEXT c3 ; /* sort/reduce each line and bitcolor array globally  */
}
CC_CONTEXT, *PCC_CONTEXT ;

typedef struct _CC_INTERFACE
{
  LDV_STATUS    (*Init)(CC_CONTEXT* vc, CNTCOL_DATA* data) ;
  unsigned long (*CountColors)(CC_CONTEXT* vc, void* addr, unsigned long so_line) ;
  unsigned long (*CountColorsEnd)(CC_CONTEXT* vc) ;
  unsigned long (*Exit)(CC_CONTEXT* vc) ;
}
CC_INTERFACE, *PCC_INTERFACE ;


/* Helper function to call best progress routine depending on VAPI progress function availability */
/* Return value:                                                                                  */
/* 1:  Cencel requested by user                                                                   */
/* 0:  Progress update done                                                                       */
/* -1: Progress update not made to screen ()                                                      */
static short Prog(long current, long max)
{
  short status = 0 ;

  if ( Vapi->PrSetProgRange ) status = (short) Vapi->PrSetProgRange( current, max ) ;
  else if ( max && ( ( current & 0x0F ) == 0 ) )
  {
    short pc ;

    /* Call progress routine only once on 16 */
    pc = (short) ( ( 100L * ( current - max ) ) / max ) ;
    if ( Vapi->PrSetProgEx ) status = Vapi->PrSetProgEx( pc ) ;
    else                     Vapi->PrSetProg( pc ) ;
  }

  return status ;
}

/* Wrappers to abstract dynamic allocation routines */
static void* localCalloc(unsigned long size)
{
  void* p ;

  if ( UseVAlloc ) p = Vapi->MeXcalloc( 1, size ) ;
  else             p = calloc( 1, size ) ;

  return p ;
}

static void* localAlloc(unsigned long size)
{
  void* p ;

  if ( UseVAlloc ) p = Vapi->MeXalloc( size ) ;
  else             p = malloc( size ) ;

  return p ;
}

static void localFree(void* p)
{
  if ( p )
  {
    if ( UseVAlloc ) Vapi->MeXfree( p ) ;
    else             free( p ) ;
  }
}

LDV_INFOS* cdecl GetLDVCapabilities(VAPI* vapi)
{
  Vapi    = vapi ;
  VapiLog = Vapi && Vapi->LoDoLog ;

  return( &LdvInfos ) ;
}

#pragma warn -par
LDV_STATUS cdecl PreRun(LDV_IMAGE* in, LDV_PARAMS* params, LDV_IMAGE* out)
{
  return ELDV_NOERROR ;
}
#pragma warn +par

static FILE* CreateReportFile(CNTCOL_DATA* data)
{
  FILE* stream ;
  char* filename ;

  if ( data->params->Param[1].str ) filename = data->params->Param[1].str ;
  else                              filename = "cntcol.txt" ;
  stream = fopen( filename, "wb" ) ;
  if ( VapiLog )
  {
    if ( stream ) Vapi->LoDoLog(LL_INFO, "cntcol.ldv will generate report file %s", filename) ;
    else          Vapi->LoDoLog(LL_ERROR, "cntcol.ldv failed to create report file %s", filename) ;
  }

  if ( stream )
  {
    fprintf( stream, "cntcol LDV running on image %dx%d, %d bitplanes:\r\n", data->in->Raster.fd_w, data->in->Raster.fd_h, data->in->Raster.fd_nplanes ) ;
    fprintf( stream, "-------|--------------------\r\n" ) ;
    fprintf( stream, "| Line | # unique colors |\r\n" ) ;
  }

  return stream ;
}

static unsigned long CountBits(unsigned char* pt, unsigned long nb_bytes)
{
  unsigned char* p = pt ;
  unsigned long  nb_bits = 0 ;

  while ( p < pt+nb_bytes )
  {
    nb_bits += NbBitsIn[*p] ;
    p++ ;
  }

  return nb_bits ;
}

static LDV_STATUS check_prog(short y, short ymax, unsigned long nb_unique_colors_on_line)
{
  short status ;

  status = Prog( y, ymax ) ;
  if ( status == 0 ) /* GUI updated */
  {
    if ( Vapi->PrSetText )
    {
      char buf[128] ;

      sprintf( buf, "%lu unique colors on line %d", nb_unique_colors_on_line, y ) ;
      Vapi->PrSetText( 1, buf ) ;
    }
  }

  return LDVPROG_CANCEL( status ) ? ELDV_CANCELLED:ELDV_NOERROR ;
}

static short add_pixel_if_not_present16(unsigned short pixel, unsigned short* line_colors, unsigned long nb_colors)
{
  unsigned long i ;

  for ( i = 0; i < nb_colors; i++ )
    if ( line_colors[i] == pixel ) break ;

  if ( i == nb_colors ) { line_colors[nb_colors++] = pixel ; return 1 ; }

  return 0 ;
}

static short add_pixel_if_not_present32(unsigned long pixel, unsigned long* line_colors, unsigned long nb_colors)
{
  unsigned long i ;

  for ( i = 0; i < nb_colors; i++ )
    if ( line_colors[i] == pixel ) break ;

  if ( i == nb_colors ) { line_colors[nb_colors++] = pixel ; return 1 ; }

  return 0 ;
}

static unsigned long CC1(CC_CONTEXT* vc, void* addr, unsigned long so_line)
{
  CC1_CONTEXT*   c = (CC1_CONTEXT*) &vc->c1 ;
  unsigned char* line = (unsigned char*) addr ;
  unsigned long  offset, nb_colors = 0 ;
  unsigned short bit ;

  if ( c->nplanes <= 8 ) /* Bit planes */
  {
    unsigned char  unique_colors_bits_line[256/8] ; /* 256 bits --> 256/8 bytes */
    unsigned short x ;

    memset( unique_colors_bits_line, 0, sizeof(unique_colors_bits_line) ) ;
    Vapi->RaRaster2Ind( addr, c->so_indexes, c->nplanes, c->indexes ) ;
    for ( x = 0; x < c->so_indexes; x++ )
    {
      bit                              = c->indexes[x] & 0x07 ;
      offset                           = c->indexes[x] >> 3 ;
      c->unique_colors_bits[offset]   |= (1 << bit) ;
      unique_colors_bits_line[offset] |= (1 << bit) ;
    }
    nb_colors = CountBits( unique_colors_bits_line, sizeof(unique_colors_bits_line) ) ;
  }
  else if ( c->nplanes == 16 ) /* TC16 */
  {
    unsigned short* p ;
    unsigned short  pixel ;

    for ( p = (unsigned short*)line; p < (unsigned short*) (line+so_line); p++ )
    {
      pixel      = *p ;
      nb_colors += add_pixel_if_not_present16( pixel, c->line_colors, nb_colors ) ;
      bit        = pixel & 0x07 ;
      offset     = pixel >> 3 ;
      c->unique_colors_bits[offset] |= (1 << bit) ;
    }
  }
  else if ( c->nplanes == 32 ) /* TC32 */
  {
    unsigned char* p ;
    unsigned long  pixel ;

    for ( p = line; p < line+so_line; p += 4 )
    {
      pixel      = p[0] ;
      pixel     |= ( (unsigned long)p[1] << 8 ) ;
      pixel     |= ( (unsigned long)p[2] << 16 ) ;
      nb_colors += add_pixel_if_not_present32( pixel, c->line_colors, nb_colors ) ;
      bit        = (unsigned short)pixel & 0x07 ;
      offset     = pixel >> 3 ;
      c->unique_colors_bits[offset] |= (1 << bit) ;
    }
  }

  return nb_colors ;
}

static unsigned long CC1Exit(CC_CONTEXT* vc)
{
  CC1_CONTEXT* c = &vc->c1 ;

  localFree( c->unique_colors_bits ) ;
  localFree( c->line_colors ) ;
  localFree( c->indexes ) ;

  return c->used_bytes ;
}

static unsigned long Getso_unique_colors_bits(MFDB* img)
{
  unsigned long so_unique_colors_bits ;

  if ( img->fd_nplanes > 8 )
  {
    if ( img->fd_nplanes == 16 ) so_unique_colors_bits = 1UL << 16 ;
    else                         so_unique_colors_bits = 1UL << 24 ; /* TC24 or TC32 */
  }
  else so_unique_colors_bits = 256 ;

  so_unique_colors_bits >>= 3 ; /* #bits --> #bytes */
  if ( so_unique_colors_bits == 0 ) so_unique_colors_bits = 1 ;

  return so_unique_colors_bits ;
}

static LDV_STATUS CC1Init(CC_CONTEXT* vc, CNTCOL_DATA* data)
{
  MFDB*         img = &data->in->Raster ;
  CC1_CONTEXT*  c = &vc->c1 ;

  memset( c, 0, sizeof(*c) ) ;
  c->nplanes = img->fd_nplanes ;
  if ( img->fd_nplanes > 8 )
  {
    /* True Color */
    /* Size of bit array for each unique color depending on the number of planes */
    c->so_line_colors = Vapi->RaGetImgSize( img->fd_w, 1, img->fd_nplanes ) ;
    c->line_colors = localAlloc( c->so_line_colors ) ;
    if ( c->line_colors == NULL ) return ELDV_NOTENOUGHMEMORY ;
  }
  else
  {
    /* Bit planes */
    c->so_indexes     = 16*img->fd_wdwidth ; /* Max for 8 planes */
    c->indexes        = (unsigned char*) localAlloc( c->so_indexes ) ;
    c->so_line_colors = 0 ;
    if ( c->indexes == NULL ) return ELDV_NOTENOUGHMEMORY ;
  }

  c->so_unique_colors_bits = Getso_unique_colors_bits( img ) ;
  c->unique_colors_bits = localCalloc( c->so_unique_colors_bits ) ;
  if ( c->unique_colors_bits == NULL ) { CC1Exit( vc ) ; return ELDV_NOTENOUGHMEMORY ; }

  c->used_bytes = c->so_unique_colors_bits + c->so_line_colors + c->so_indexes ;

  return ELDV_NOERROR ;
}

static unsigned long CC1End(CC_CONTEXT* vc)
{
  CC1_CONTEXT* c = &vc->c1 ;

  return CountBits( c->unique_colors_bits, c->so_unique_colors_bits ) ;
}

static int cmp8(const void* a, const void* b)
{
  unsigned char* e1 = (unsigned char*) a ;
  unsigned char* e2 = (unsigned char*) b ;

  return (int)( *e1 - *e2 ) ;
}

static int cmp16(const void* a, const void* b)
{
  unsigned short* e1 = (unsigned short*) a ;
  unsigned short* e2 = (unsigned short*) b ;

  return ( *e1 - *e2 ) ;
}

static int cmp32(const void* a, const void* b)
{
  unsigned long* e1 = (unsigned long*) a ;
  unsigned long* e2 = (unsigned long*) b ;

  if ( *e1 < *e2 ) return -1 ;
  if ( *e1 == *e2 ) return 0 ;
  return 1 ;
}

static unsigned long reduce8(unsigned char* array, unsigned long nb_items)
{
  unsigned long  nb_unique = 0 ;
  unsigned char* pread ;
  unsigned char* pwrite ;
  unsigned char  val ;

  pread = pwrite = array ;
  while ( pread < array + nb_items )
  {
    val = *pread++ ;
    while ( (pread < array + nb_items) && (*pread == val) ) pread++ ;
    nb_unique++ ;
    *pwrite++ = val ;
  }

  return nb_unique ;
}

static unsigned long reduce16(unsigned short* array, unsigned long nb_items)
{
  unsigned long   nb_unique = 0 ;
  unsigned short* pread ;
  unsigned short* pwrite ;
  unsigned short  val ;

  pread = pwrite = array ;
  while ( pread < array + nb_items )
  {
    val = *pread++ ;
    while ( (pread < array + nb_items) && (*pread == val) ) pread++ ;
    nb_unique++ ;
    *pwrite++ = val ;
  }

  return nb_unique ;
}

static unsigned long reduce32(unsigned long* array, unsigned long nb_items)
{
  unsigned long  nb_unique = 0 ;
  unsigned long* pread ;
  unsigned long* pwrite ;
  unsigned long  val ;

  pread = pwrite = array ;
  while ( pread < array + nb_items )
  {
    val = *pread++ ;
    while ( (pread < array + nb_items) && (*pread == val) ) pread++ ;
    nb_unique++ ;
    *pwrite++ = val ;
  }

  return nb_unique ;
}

static unsigned long CC2(CC_CONTEXT* vc, void* addr, unsigned long so_line)
{
  CC2_CONTEXT*  c = (CC2_CONTEXT*) &vc->c2 ;
  unsigned long nb_colors = 0 ;

  if ( c->nplanes <= 8 ) /* Bit planes */
  {
    Vapi->RaRaster2Ind( addr, c->so_indexes, c->nplanes, c->indexes ) ;
    qsort( c->indexes, c->so_indexes, sizeof(unsigned char), cmp8 ) ;
    nb_colors = reduce8( c->indexes, c->so_indexes ) ;
    /* Add new line of unique colors to current image unique colors */
    memmove( c->img_sorted + c->nb_img_colors, c->indexes, nb_colors*sizeof(unsigned char) ) ;
    c->nb_img_colors += nb_colors ;
  }
  else if ( c->nplanes == 16 ) /* TC16 */
  {
    memmove( c->line_sorted, addr, so_line ) ;
    qsort( c->line_sorted, so_line >> 1, sizeof(unsigned short), cmp16 ) ;
    nb_colors = reduce16( (unsigned short*) c->line_sorted, so_line >> 1 ) ;
    /* Add new line of unique colors to current image unique colors */
    memmove( c->img_sorted + 2*c->nb_img_colors, c->line_sorted, nb_colors*sizeof(unsigned short) ) ;
    c->nb_img_colors += nb_colors ;
  }
  else if ( c->nplanes == 32 ) /* TC32 */
  {
    memmove( c->line_sorted, addr, so_line ) ;
    qsort( c->line_sorted, so_line >> 2, sizeof(unsigned long), cmp32 ) ;
    nb_colors = reduce32( (unsigned long*) c->line_sorted, so_line >> 2 ) ;
    /* Add new line of unique colors to current image unique colors */
    memmove( c->img_sorted + 4*c->nb_img_colors, c->line_sorted, nb_colors*sizeof(unsigned long) ) ;
    c->nb_img_colors += nb_colors ;
  }

  return nb_colors ;
}

static unsigned long CC2Exit(CC_CONTEXT* vc)
{
  CC2_CONTEXT* c = &vc->c2 ;

  localFree( c->indexes ) ;
  localFree( c->img_sorted ) ;
  localFree( c->line_sorted ) ;

  return c->used_bytes ;
}

static LDV_STATUS CC2Init(CC_CONTEXT* vc, CNTCOL_DATA* data)
{
  MFDB*         img = &data->in->Raster ;
  CC2_CONTEXT*  c = &vc->c2 ;
  short         pixel_in_bytes ;

  memset( c, 0, sizeof(*c) ) ;
  c->nplanes = img->fd_nplanes ;

  /* Use VISION's checked allocation routine for safety as VISION performs bounduary checks */
  /* Allocate memory to duplicate a line and sort it out */
  if ( img->fd_nplanes > 8 )
  {
    c->line_sorted = (unsigned char*) localAlloc( Vapi->RaGetImgSize( img->fd_w, 1, img->fd_nplanes ) ) ;
    if ( c->line_sorted == NULL ) return ELDV_NOTENOUGHMEMORY ;
    if ( img->fd_nplanes == 16 ) pixel_in_bytes = 2 ;
    else                         pixel_in_bytes = 4 ;
  }
  else
  {
    /* Bit planes: we need an index array */
    c->so_indexes = 16*img->fd_wdwidth ; /* Max for 8 planes */
    c->indexes    = (unsigned char*) localAlloc( c->so_indexes ) ;
    if ( c->indexes == NULL ) { CC2Exit( vc ) ; return ELDV_NOTENOUGHMEMORY ; }
    pixel_in_bytes = 1 ;
  }

  /* Allocate memory to store all colors used for all the image                 */
  /* There can't be more colors than pixels in the image, so let's go with that */
  c->nb_img_colors_max = (unsigned long)img->fd_w * (unsigned long)img->fd_h ;
  c->img_sorted        = (unsigned char*) localAlloc( c->nb_img_colors_max*pixel_in_bytes ) ;
  if ( c->img_sorted == NULL ) { CC2Exit( vc ) ; return ELDV_NOTENOUGHMEMORY ; }
  c->used_bytes = c->so_indexes + c->nb_img_colors_max*pixel_in_bytes ;

  return ELDV_NOERROR ;
}

static unsigned long CC2End(CC_CONTEXT* vc)
{
  CC2_CONTEXT* c = &vc->c2 ;

  if ( c->nplanes <= 8 ) /* Bit planes */
  {
    /* Sort the new array */
    qsort( c->img_sorted, c->nb_img_colors, sizeof(unsigned char), cmp8 ) ;
    /* And reduce it */
    c->nb_img_colors = reduce8( c->img_sorted, c->nb_img_colors ) ;
  }
  else if ( c->nplanes == 16 ) /* TC16 */
  {
    /* Sort the new array */
    qsort( c->img_sorted, c->nb_img_colors, sizeof(unsigned short), cmp16 ) ;
    /* And reduce it */
    c->nb_img_colors = reduce16( (unsigned short*) c->img_sorted, c->nb_img_colors ) ;
  }
  else if ( c->nplanes == 32 ) /* TC32 */
  {
    /* Sort the new array */
    qsort( c->img_sorted, c->nb_img_colors, sizeof(unsigned long), cmp32 ) ;
    /* And reduce it */
    c->nb_img_colors = reduce32( (unsigned long*) c->img_sorted, c->nb_img_colors ) ;
  }

  return c->nb_img_colors ;
}

static unsigned long CC3Exit(CC_CONTEXT* vc)
{
  CC3_CONTEXT* c = &vc->c3 ;

  localFree( c->unique_colors_bits ) ;
  localFree( c->line_sorted ) ;
  localFree( c->indexes ) ;

  return c->used_bytes ;
}

static LDV_STATUS CC3Init(CC_CONTEXT* vc, CNTCOL_DATA* data)
{
  MFDB*         img = &data->in->Raster ;
  CC3_CONTEXT*  c = &vc->c3 ;

  memset( c, 0, sizeof(*c) ) ;
  c->nplanes = img->fd_nplanes ;
  if ( img->fd_nplanes > 8 )
  {
    /* True Color */
    /* Size of bit array for each unique color depending on the number of planes */
    c->so_line_colors = Vapi->RaGetImgSize( img->fd_w, 1, img->fd_nplanes ) ;
    /* Allocate memory for a line to get sorted */
    c->line_sorted = localAlloc( c->so_line_colors ) ;
    if ( c->line_sorted == NULL ) return ELDV_NOTENOUGHMEMORY ;
  }
  else
  {
    /* Bit planes */
    c->so_indexes = 16*img->fd_wdwidth ; /* Max for 8 planes */
    c->indexes    = (unsigned char*) localAlloc( c->so_indexes ) ;
    if ( c->indexes == NULL ) return ELDV_NOTENOUGHMEMORY ;
  }

  c->so_unique_colors_bits = Getso_unique_colors_bits( img ) ;
  c->unique_colors_bits    = localCalloc( c->so_unique_colors_bits ) ;
  if ( c->unique_colors_bits == NULL ) { CC3Exit( vc ) ; return ELDV_NOTENOUGHMEMORY ; }

  c->used_bytes = c->so_line_colors + c->so_indexes + c->so_unique_colors_bits ;

  return ELDV_NOERROR ;
}

static unsigned long CC3End(CC_CONTEXT* vc)
{
  CC3_CONTEXT* c = &vc->c3 ;

  return CountBits( c->unique_colors_bits, c->so_unique_colors_bits ) ;
}

static unsigned long CC3(CC_CONTEXT* vc, void* addr, unsigned long so_line)
{
  CC3_CONTEXT*   c = (CC3_CONTEXT*) &vc->c3 ;
  unsigned char* line = (unsigned char*) addr ;
  unsigned long  offset, nb_colors = 0 ;
  unsigned short bit ;

  if ( c->nplanes <= 8 ) /* Bit planes */
  {
    unsigned short x ;

    /* Sort/reduce this line */
    Vapi->RaRaster2Ind( addr, c->so_indexes, c->nplanes, c->indexes ) ;
    qsort( c->indexes, c->so_indexes, sizeof(unsigned char), cmp8 ) ;
    nb_colors = reduce8( c->indexes, c->so_indexes ) ;

    /* Update global bitarray */
    for ( x = 0; x < c->so_indexes; x++ )
    {
      bit                            = c->indexes[x] & 0x07 ;
      offset                         = c->indexes[x] >> 3 ;
      c->unique_colors_bits[offset] |= (1 << bit) ;
    }
  }
  else if ( c->nplanes == 16 ) /* TC16 */
  {
    unsigned short* p ;
    unsigned short  pixel ;

    /* Sort/reduce this line */
    memmove( c->line_sorted, addr, so_line ) ;
    qsort( c->line_sorted, so_line >> 1, sizeof(unsigned short), cmp16 ) ;
    nb_colors = reduce16( (unsigned short*) c->line_sorted, so_line >> 1 ) ;

    /* Update global bitarray */
    for ( p = (unsigned short*)line; p < (unsigned short*) (line+so_line); p++ )
    {
      pixel  = *p ;
      bit    = pixel & 0x07 ;
      offset = pixel >> 3 ;
      c->unique_colors_bits[offset] |= (1 << bit) ;
    }
  }
  else if ( c->nplanes == 32 ) /* TC32 */
  {
    unsigned char* p ;
    unsigned long  pixel ;

    /* Sort/reduce this line */
    memmove( c->line_sorted, addr, so_line ) ;
    qsort( c->line_sorted, so_line >> 2, sizeof(unsigned long), cmp32 ) ;
    nb_colors = reduce32( (unsigned long*) c->line_sorted, so_line >> 2 ) ;

    for ( p = line; p < line+so_line; p += 4 )
    {
      pixel  = p[0] ;
      pixel |= ( (unsigned long)p[1] << 8 ) ;
      pixel |= ( (unsigned long)p[2] << 16 ) ;
      bit    = (unsigned short)pixel & 0x07 ;
      offset = pixel >> 3 ;
      c->unique_colors_bits[offset] |= (1 << bit) ;
    }
  }

  return nb_colors ;
}

static LDV_STATUS LDVOperation(CNTCOL_DATA* data)
{
  CC_INTERFACE   cci ;
  CC_CONTEXT     c ;
  LDV_STATUS     status ; 
  MFDB*          img = &data->in->Raster ;
  unsigned char* line ;
  unsigned long  so_line ;
  short          method, l = 0 ;
  unsigned long  nb_unique_colors_on_line, used_ram ;
  unsigned char* pt_after_img ;

  so_line = Vapi->RaGetImgSize( img->fd_w, 1, img->fd_nplanes ) ;
  method  = data->method ;
  if ( method == 0 )
  {
    /* Let me decide */
    if ( img->fd_nplanes <= 8 ) method = 1 ; /* qsort/reduce is too costy when there are not so many colors */
    else                        method = 3 ;
  }
  switch( method )
  {
    case 1:  cci.Init           = CC1Init ;
             cci.CountColors    = CC1 ;
             cci.CountColorsEnd = CC1End ;
             cci.Exit           = CC1Exit ;
             break ;

    case 2:  cci.Init           = CC2Init ;
             cci.CountColors    = CC2 ;
             cci.CountColorsEnd = CC2End ;
             cci.Exit           = CC2Exit ;
             break ;

    default: cci.Init           = CC3Init ;
             cci.CountColors    = CC3 ;
             cci.CountColorsEnd = CC3End ;
             cci.Exit           = CC3Exit ;
             method             = 3 ;
             break ;
  }
  if ( VapiLog )
  {
    Vapi->LoDoLog(LL_DEBUG, "cntcol.ldv: Image is %dx%dx%d, wd_width=%d", img->fd_w, img->fd_h, img->fd_nplanes, img->fd_wdwidth ) ;
    Vapi->LoDoLog(LL_DEBUG, "cntcol.ldv: using %s's memory allocation routines", UseVAlloc ? "VISION":"compiler" ) ;
    Vapi->LoDoLog(LL_DEBUG, "cntcol.ldv: using method %d for counting colors", method ) ;
  }
  status = cci.Init( &c, data ) ;
  if ( !LDV_SUCCESS( status ) ) return status ;
  if ( VapiLog ) Vapi->LoDoLog(LL_DEBUG, "cntcol.ldv: init done" ) ;

  line         = img->fd_addr ;
  pt_after_img = line + (unsigned long)img->fd_h*so_line ;
  while ( LDV_SUCCESS( status ) && (line < pt_after_img) )
  {
    nb_unique_colors_on_line = cci.CountColors( &c, line, so_line ) ;
    if ( nb_unique_colors_on_line > 0 )
    {
      fprintf( data->report_file, "|%6d|%17lu|\r\n", l, nb_unique_colors_on_line ) ;
      line  += so_line ;
      status = check_prog( l++, img->fd_h, nb_unique_colors_on_line ) ;
    }
    else status = ELDV_NOTENOUGHMEMORY ;
  }

  if ( status == ELDV_CANCELLED ) fprintf( data->report_file, "---- Operation cancelled by user ----\r\n" ) ;
  else if ( status == ELDV_NOTENOUGHMEMORY ) fprintf( data->report_file, "---- Not enough memory ----\r\n" ) ;
  else
  {
    unsigned long nb_unique_colors ;

    if ( VapiLog ) Vapi->LoDoLog(LL_DEBUG, "cntcol.ldv: finishing counting..." ) ;
    fprintf( data->report_file, "-------|------------------\r\n" ) ;
    nb_unique_colors = cci.CountColorsEnd( &c ) ;
    fprintf( data->report_file, "|Total |%17lu|\r\n", nb_unique_colors ) ;
    if ( VapiLog ) Vapi->LoDoLog(LL_INFO, "cntcol.ldv: %lu unique colors on image", nb_unique_colors ) ;
    if ( Vapi->Header.Version >= 0x0106 )
    {
      /* LDV_PARAMS provides storage for returning */
      /* A free text to be displayed in VISION     */
      if ( VapiLog ) Vapi->LoDoLog(LL_INFO, "cntcol.ldv: returning #unique colors to VISION" ) ;
      sprintf( data->params->ldv_txt_out, "%lu unique colors", nb_unique_colors ) ;
    }
  }

  fprintf( data->report_file, "-------|------------------\r\n" ) ;
  used_ram = cci.Exit( &c ) ;
  fprintf( data->report_file, "RAM used: %lu KB\r\n", used_ram/1024UL ) ;

  return status ;
}

#pragma warn -par
LDV_STATUS cdecl Run(LDV_IMAGE* in, LDV_PARAMS* params, LDV_IMAGE* out)
{
  CNTCOL_DATA data ;
  LDV_STATUS  status ;
  clock_t     t0 ;

  if ( (in->RasterFormat & CAPS) == 0 ) return ELDV_IMGFORMATMISMATCH ;

  UseVAlloc = Vapi && Vapi->MeXcalloc && Vapi->MeXfree ;

  data.in          = in ;
  data.params      = params ;
  data.method      = data.params->Param[0].s ;
  data.report_file = CreateReportFile( &data ) ;
  if ( data.report_file == NULL ) return ELDV_GENERALFAILURE ;

  t0     = clock() ;
  status = LDVOperation( &data ) ;

  fprintf( data.report_file, "Computation time: %lu ms\r\n", (1000L*(clock()-t0))/CLK_TCK ) ;
  fclose( data.report_file ) ;

  return status ;
}
#pragma warn +par

static void init_bit_counts(void)
{
  unsigned short i, mask ;

  for ( i = 0; i <= 255; i++ )
    for ( mask = 1; mask < 256; mask <<= 1 )
      if ( i & mask ) NbBitsIn[i]++ ;
}

int main(void)
{
  ldg_init( Ldg ) ;

  init_bit_counts() ;

  return 0 ;
}
