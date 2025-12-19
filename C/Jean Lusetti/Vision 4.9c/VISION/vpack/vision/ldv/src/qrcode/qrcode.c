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
#include "qrcode.h"

/* The LDV internal structure to hold  */
/* QRCODE library shared data and data */
/* To handle internal logic            */
typedef struct _QR_DATA
{
  QRINFO qrinfo ;
  char   text[4096] ;
  long   level ;
  char*  buffer ;
  char   internal_buffer[4096] ; /* Should be enough most of the time */
}
QRDATA, *PQRDATA ;


/* Prototypes */
LDV_INFOS* cdecl GetLDVCapabilities(VAPI* vapi) ;
LDV_STATUS cdecl PreRun(LDV_IMAGE* in, LDV_PARAMS* params, LDV_IMAGE* out) ;
LDV_STATUS cdecl Run(LDV_IMAGE* in, LDV_PARAMS* params, LDV_IMAGE* out) ;
LDV_STATUS cdecl Preview(LDV_IMAGE* in, LDV_PARAMS* params, LDV_IMAGE* out) ;

void OnClose(void) ;

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
                   OnClose, /* On exit, free VDI handle (unused) */
               } ;

#define CAPS (LDVF_ATARIFORMAT | LDVF_SUPPORTPREVIEW | LDVF_REALTIMEPARAMS | LDVF_NOSELECTION)

LDV_INFOS LdvInfos = {
                       (short) sizeof(LDV_INFOS),      /* size of this structure */
                       TLDV_MODIFYIMG,                 /* LDV Type               */
                       "Guillaume Tello/Jean Lusetti", /* Authors                */
                       {
                         {  1,  1, CAPS },           /* 1 bitplane capabilities  */
                         {  2,  1, CAPS },           /* 2 bitplane capabilities  */
                         {  4,  1, CAPS },           /* 4 bitplane capabilities  */
                         {  8,  1, CAPS },           /* 8 bitplane capabilities  */
                         { 16,  1, CAPS },           /* 16 bitplane capabilities */
/* Not yet               { 24, 24, CAPS },                                    */
                         { 32,  1, CAPS },           /* 32 bitplane capabilities */
                         { 0,  0, 0UL }              /* End of this list         */
                       },
                     } ;

VAPI*  Vapi = NULL ;
QRDATA QRData ;


static void ReleaseDataBuffer(void)
{
  if ( QRData.buffer && (QRData.buffer != QRData.internal_buffer) ) Vapi->MeXfree( QRData.buffer ) ;
  QRData.buffer = QRData.internal_buffer ;
}

/* Free allocated RunTime stuff */
void OnClose(void)
{
  ReleaseDataBuffer() ;
}

LDV_INFOS* cdecl GetLDVCapabilities(VAPI* vapi)
{
  Vapi = vapi ;

  return( &LdvInfos ) ;
}

static short AdaptText(char* in, char* out, size_t len_out)
{
  char* pin = in ;
  char* pout = out ;
  char* last_pout = out + len_out - 1 ;

  if ( memcmp( in, "SMSTO:", 6 ) == 0 )
  {
    /* if text to encode is a SMS, let's copy all chars but CR/CF */
    for ( ; *pin && (pout < last_pout); pin++ )
      if ( (*pin != '\r') && (*pin != '\n') ) *pout++ = *pin ;
  }
  else if ( memcmp( in, "MAILTO:", 7 ) == 0 )
  {
    /* if text to encode is a Email, encode space character as %20 and keep only \n (not \r)  */
    last_pout -= (3-1) ; /* As we need 3 chars for a space */
    for ( ; *pin && (pout < last_pout); pin++ )
    {
      if ( *pin == ' ' ) { *pout++ = '%' ; *pout++ = '2' ; *pout++ = '0' ; }
      else if ( *pin != '\r' ) *pout++ = *pin ;
    }
  }
  else for ( ; *pin && (pout < last_pout); pin++ ) *pout++ = *pin ; /* Just text */

  /* Let's make sure we end-up with a 0 */
  *pout = 0 ;

  return( pout >= last_pout ) ;
}

#pragma warn -par
LDV_STATUS cdecl PreRun(LDV_IMAGE* in, LDV_PARAMS* params, LDV_IMAGE* out)
{
  long err ;

  QRData.level = (long) params->Param[0].s ;

  /* Depending on the text type (e.g. SMS or Email), we may have to change it a little bit */
  if ( AdaptText( params->Param[1].str, QRData.text, sizeof(QRData.text) ) )
  {
    if ( Vapi->LoDoLog ) Vapi->LoDoLog( LL_ERROR, "LDVQRCode: text to encode is too big" ) ;
    return ELDV_NOTENOUGHMEMORY ; /* text size in structure QRDATA not big enough */
  }

  if ( Vapi->LoDoLog ) Vapi->LoDoLog( LL_DEBUG, "LDVQRCode:QRinfo, level %ld, text %s", QRData.level, QRData.text ) ;
  ReleaseDataBuffer() ; /* Note that our internal buffer, if big enough, is now ready for use */
  err = QRinfo( QRData.text, QRData.level, &QRData.qrinfo ) ;
  if ( !QRF_OK( err ) )
  {
    if ( Vapi->LoDoLog ) Vapi->LoDoLog( LL_ERROR, "LDVQRCode: QRinfo returns %ld", err ) ;
    return ELDV_INVALIDPARAMETER ;
  }

  if ( QRData.qrinfo.size > sizeof(QRData.internal_buffer) )
  {
    /* Our internal buffer is not big enough, let's allocate a specific one */
    if ( Vapi && Vapi->MeXalloc )
    {
      /* Use VAPI to allocate this memory as VISION features bounds checking on it */
      QRData.buffer = (char*) Vapi->MeXalloc( QRData.qrinfo.size ) ;
    }
    else QRData.buffer = NULL ; /* If Vapi version is not enough, let's consider it's a memory falure */
    if ( QRData.buffer == NULL ) return ELDV_NOTENOUGHMEMORY ;
  }
  else if ( Vapi->LoDoLog ) Vapi->LoDoLog( LL_DEBUG, "LDVQRCode: internal buffer used" ) ;

  /* Tell VISION what needs to be allocated for output image */
  out->Raster.fd_w       = (QRData.qrinfo.w+15) & 0xFFF0 ; /* Make sure it is 16 pixel aligned */
  out->Raster.fd_h       = QRData.qrinfo.h ;
  out->Raster.fd_nplanes = 1 ;

  if ( Vapi->LoDoLog ) Vapi->LoDoLog( LL_DEBUG, "LDVQRCode: image will be %dx%d pixels, %ld bytes needed, buffer at %p", out->Raster.fd_w, out->Raster.fd_h, QRData.qrinfo.size, QRData.buffer ) ;

  return ELDV_NOERROR ;
}

LDV_STATUS cdecl Run(LDV_IMAGE* in, LDV_PARAMS* params, LDV_IMAGE* out)
{
  MFDB mfdb ;
  long err ;

  err = QRcode( QRData.buffer, &mfdb ) ;
  if ( !QRF_OK( err ) )
  {
    if ( Vapi->LoDoLog ) Vapi->LoDoLog( LL_ERROR, "LDVQRCode: QRcode returns %ld", err ) ;
    ReleaseDataBuffer() ;
    return ELDV_INVALIDPARAMETER ;
  }

  if ( Vapi->LoDoLog ) Vapi->LoDoLog( LL_DEBUG, "LDVQRCode: QRcode returns %dx%dx%d (wd %d) image", mfdb.fd_w, mfdb.fd_h, mfdb.fd_nplanes, mfdb.fd_wdwidth ) ;

  /* QR code image has been generated, let's copy it back to VISION from our internal data */
  memcpy( out->Raster.fd_addr, mfdb.fd_addr, mfdb.fd_wdwidth*mfdb.fd_h*2L ) ;
  ReleaseDataBuffer() ;

  return ELDV_NOERROR ;
}
#pragma warn +par

LDV_STATUS cdecl Preview(LDV_IMAGE* in, LDV_PARAMS* params, LDV_IMAGE* out)
{
  return( Run( in, params, out ) ) ;
}


int main(void)
{
  ldg_init( Ldg ) ;

  return 0 ;
}
