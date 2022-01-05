#define PCGEMLIB 1 /* Set to 1 if PureC is used */

#if PCGEMLIB
#include <aes.h>
#include <vdi.h>
#else
#include <aesbind.h>
#include <vdibind.h>
#endif

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
LDV_STATUS cdecl Preview(LDV_IMAGE* in, LDV_PARAMS* params, LDV_IMAGE* out) ;

/* Variables globales */
PROC Proc[]  = {
                 "GetLDVCapabilities", "LDV capabilities", (void *)GetLDVCapabilities,
                 "PreRun", "Run initialization", (void *)PreRun,
                 "Run", "LDV operation", (void *)Run,
                 "Preview", "Pre-Visu", (void *)Preview,
              } ;

char Info[] = "LDV" ;

LDGLIB Ldg[] = {
                 0x0100, /* Lib version                       */
                      4, /* Number of functions in lib        */
                   Proc, /* Pointers to our functions         */
                   Info, /* Lib information                   */
                    0x0, /* Lib flags                         */
                   NULL, /* On exit, free VDI handle (unused) */
               } ;

#define CAPS (LDVF_ATARIFORMAT | LDVF_SUPPORTPREVIEW | LDVF_OPINPLACE | LDVF_NOSELECTION)

LDV_INFOS LdvInfos = {
                       (short) sizeof(LDV_INFOS), /* size of this structure */
                       TLDV_MODIFYIMG,            /* LDV Type               */
                       "Jean Lusetti",            /* Authors                */
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

VAPI* Vapi = NULL ;


LDV_INFOS* cdecl GetLDVCapabilities(VAPI* vapi)
{
  Vapi = vapi ;

  return( &LdvInfos ) ;
}

static LDV_STATUS GenMaxColors(MFDB* img)
{
  unsigned long nb = ((unsigned long)img->fd_wdwidth << 4) * (unsigned long) img->fd_h ;
  unsigned long n ;

  if ( img->fd_nplanes <= 8 )
  {
    MFDB           tmp ;
    unsigned char* pt_img ;
    unsigned char* pt_after_img ;
    unsigned char  indexes[256] ;   /* Array of indexes: 256 as max for 8 bitplanes */
    short          bitplanes[128] ; /* Transformation into bitplanes Atari */
    unsigned long  so_line ;
    unsigned short ncol = 1 << img->fd_nplanes ;

    memset( &tmp, 0, sizeof(MFDB) ) ;
    tmp.fd_addr = bitplanes ; tmp.fd_nplanes = img->fd_nplanes ;
    tmp.fd_w = ncol ; tmp.fd_h = 1 ;
    for ( n = 0; n < 256; n++ ) indexes[n] = (unsigned char) n ;
    Vapi->RaInd2RasterInit( &tmp, 256 ) ;
    Vapi->RaInd2Raster( indexes, 256 ) ;
    /* Fill in img MFDB with repetition of bitplanes buffer */
    pt_img       = img->fd_addr ;
    so_line      = 16UL*img->fd_wdwidth ;
    so_line     *= (unsigned long)img->fd_nplanes ;
    so_line    >>= 3 ; /* Size of a line in bytes */
    pt_after_img = pt_img + so_line * (unsigned long)img->fd_h ;
    Vapi->LoDoLog(LL_DEBUG, "genimg.ldv: pt_after_img=%p", pt_after_img ) ;
    while ( pt_img < pt_after_img-256 )
    {
      Vapi->LoDoLog(LL_DEBUG, "genimg.ldv: pt_img=%p", pt_img ) ;
      memcpy( pt_img, bitplanes, 256 ) ;
      pt_img += 256 ;
    }
  }
  else if ( img->fd_nplanes == 16 )
  {
    unsigned short* pt = img->fd_addr ;
    unsigned short  inc = (unsigned short) (nb / (1UL << 16)) ;
    unsigned short  val = 0 ;

    if ( inc < 1 ) inc = 1 ;
    
    for ( n = 0; n < nb; n++ )
    {
      *pt++ = val ;
      val  += inc ;
    }
  }
  else if ( img->fd_nplanes == 32 )
  {
    unsigned long* pt = img->fd_addr ;
    unsigned long  inc = nb / (1UL << 24) ;
    unsigned long  val = 0 ;

    if ( inc < 1 ) inc = 1 ;
    inc <<= 8 ;
    
    for ( n = 0; n < nb; n++ )
    {
      *pt++ = val ;
      val  += inc ;
    }
  }

  return ELDV_NOERROR ;
}

#pragma warn -par
LDV_STATUS cdecl PreRun(LDV_IMAGE* in, LDV_PARAMS* params, LDV_IMAGE* out)
{
  return ELDV_NOERROR ;
}

LDV_STATUS cdecl Run(LDV_IMAGE* in, LDV_PARAMS* params, LDV_IMAGE* out)
{
  LDV_STATUS status ; 

  switch( params->Param[0].s )
  {
    case 1:  /* Generate an image with as many colors as possible */
             status = GenMaxColors( &in->Raster ) ;
             break ;

    default: status = ELDV_INVALIDPARAMETER ;
             break ;
  }

  return status ;
}
#pragma warn +par

LDV_STATUS cdecl Preview(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out)
{
  return( Run( in, params, out ) ) ;
}

int main(void)
{
  ldg_init( Ldg ) ;

  return 0 ;
}
