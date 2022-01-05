/*
 *
 *
 *	Version PureC / Gcc
 */

#define PCGEMLIB 1 /* mettre 1 si les utilisateurs de Pure C
					* utilise les librairies GEM Pure C */

/* Fichiers headers */

#include <portab.h>
#if PCGEMLIB
#include <aes.h>
#include <vdi.h>
#else
#include <aesbind.h>
#include <vdibind.h>
#endif

#include <string.h>
#include <stdlib.h>
#include "..\..\ldg.h"
#include "..\..\vapi.h"
#include "..\..\ldv.h"
#include "..\..\mt_aes.h"

/* Prototypages */
LDV_INFOS * cdecl GetLDVCapabilities(VAPI *vapi) ;
LDV_STATUS  cdecl PreRun(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out) ;
LDV_STATUS  cdecl Run(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out) ;
LDV_STATUS  cdecl Preview(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out) ;

void OnClose(void) ;

/* Variables globales */
PROC Proc[]  = {
                 "GetLDVCapabilities", "Capacit‚s du LDV", (void *)GetLDVCapabilities,
                 "PreRun", "Init du Run", (void *)PreRun,
                 "Run", "Fonction du LDV", (void *)Run,
                 "Preview", "Pre-Visu", (void *)Preview,
              } ;

char Info[] = "LDV";

LDGLIB Ldg[] = {
				0x0101,	 /* version de la lib, recommand‚ */
				4,		 /* nombre de fonction dans la lib */
				Proc,	 /* Pointeurs vers nos fonctions */
				Info, 	 /* Information sur la lib */
				0x0,   	 /* Flags de la lib, obligatoire */
                OnClose, /* Fermeture, liberation de VDIHandle */
				};

#define BP_CAPS (LDVF_ATARIFORMAT | LDVF_SUPPORTPREVIEW | LDVF_SUPPORTPROG | LDVF_REALTIMEPARAMS | LDVF_SUPPORTCANCEL | LDVF_NOSELECTION)
#define TC_CAPS (LDVF_SPECFORMAT  | LDVF_SUPPORTPREVIEW | LDVF_SUPPORTPROG | LDVF_REALTIMEPARAMS | LDVF_SUPPORTCANCEL)

LDV_INFOS LdvInfos = {
                       (short) sizeof(LDV_INFOS), /* Taille de cette structure */
                       TLDV_MODIFYIMG,            /* Type du LDV               */
                       "Jean Lusetti",            /* Auteurs                   */
                       {
                         {  1,  1, BP_CAPS }, /* Capacites pour 1 plan     */
                         {  2,  2, BP_CAPS }, /* Capacites pour 2 plans    */
                         {  4,  4, BP_CAPS }, /* Capacites pour 4 plans    */
                         {  8,  8, BP_CAPS }, /* Capacites pour 8 plans    */
                         { 16, 16, TC_CAPS }, /* Capacites pour 16 plans   */
                         { 32, 32, TC_CAPS }, /* Capacites pour 32 plans   */
                         { 0, 0, 0UL }        /* Fin de la liste des capacites */
                       },
                     } ;

VAPI *Vapi = NULL ;
int  VDIHandle = -1 ;

void OnClose(void)
{
  if ( VDIHandle != -1 ) v_clsvwk( VDIHandle ) ;
  VDIHandle = -1 ;
}

/* 
 * Fonctions de la librairie
 */

LDV_INFOS * cdecl GetLDVCapabilities(VAPI *vapi)
{
  Vapi = vapi ;

  return( &LdvInfos ) ;
}

int vdihandle(void)
{
  int work_in[11], work_out[57], i ;
	
  for ( i = 0; i < 10; work_in[i++] = 1 ) ;
  work_in[10] = 2 ;
  v_opnvwk( work_in, &i, work_out ) ;

  return( i ) ;
}

#pragma warn -par
LDV_STATUS cdecl PreRun(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out)
{
  out->Raster.fd_w = in->Raster.fd_w ;
  out->Raster.fd_h = in->Raster.fd_h ;

  return( ELDV_NOERROR ) ;
}

LDV_STATUS cdecl Run(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out)
{
  MFDB           dst_line ;
  int            xy[8] ;
  long           *pt32_in, *pt32_out ;
  short          *pt16_in, *pt16_out ;
  unsigned char  *pt8_in = NULL, *pt8_out ;
  long           wscale, wout, wpixel, xpixel ;
  long           angle, depth, src_line32, yoffset, lo_line_in, lo_line_out ;
  short          line, y1, y2 ;
  short          wlen, pc, cancel = 0 ;

  if ( Vapi->Header.Version < 0x102 ) return( ELDV_BADVAPIVERSION ) ;

  if ( VDIHandle == -1 ) VDIHandle = vdihandle() ;

  if (
       ( params->x1 != 0 ) || ( params->x2 != in->Raster.fd_w -1 ) ||
       ( params->y1 != 0 ) || ( params->y2 != in->Raster.fd_h -1 )
     )
  {
    xy[0] = xy[4] = 0 ;
    xy[1] = xy[5] = 0 ;
    xy[2] = xy[6] = in->Raster.fd_w - 1 ;
    xy[3] = xy[7] = in->Raster.fd_h - 1 ;
    vro_cpyfm( VDIHandle, S_ONLY, xy, &in->Raster, &out->Raster ) ;
    xy[0] = params->x1 ; xy[1] = params->y1 ;
    xy[2] = params->x2 ; xy[3] = params->y2 ;
    xy[4] = params->x1 ; xy[5] = params->y1 ;
    xy[6] = params->x2 ; xy[7] = params->y2 ;
    vro_cpyfm( VDIHandle, ALL_WHITE, xy, &in->Raster, &out->Raster ) ;
  }
  else
    Vapi->RaImgWhite( &out->Raster ) ;

  wpixel      = 1+params->x2-params->x1 ;
  lo_line_in  = ALIGN16( in->Raster.fd_w ) ; 
  lo_line_out = ALIGN16( out->Raster.fd_w ) ; 
  angle       = (long) params->Param[0].s ;
  depth       = (long) params->Param[1].s ;
  y1          = (long) params->y1 + (long) ( ((long)(params->y2 - params->y1)*angle) / 1000 ) ;
  y2          = (long) params->y1 + params->y2 - y1 ;

  yoffset    = ((long) (params->y2 - params->y1)) << 16 ;
  yoffset   /= (long) (y2 - y1 ) ;
  if ( y1 > y2 )
  {
    short tmp ;
    
    tmp = y1 ;
    y1  = y2 ;
    y2  = tmp ;
    src_line32   = params->y2 ;
    src_line32 <<= 16 ;
  }
  else
  {
    src_line32   = params->y1 ;
    src_line32 <<= 16 ;
  }

  /* Mode bitplan : allocation memoire pour conversion index <--> format ATARI */
  /* pt16_... est utilise pour le mode 16 bits et le mode bit-plan (avec reajustement) */
  if ( in->Raster.fd_nplanes <= 8 )
  {
    size_t win ;

    win     = ALIGN16( in->Raster.fd_w ) ;
    wout    = ALIGN16( out->Raster.fd_w ) ;
    pt8_in  = (unsigned char *) malloc( win + wout ) ; /* Car on alloue aussi pour la remise a l'echelle */
    if ( pt8_in == NULL ) return ELDV_NOTENOUGHMEMORY ;
    pt8_out = pt8_in + in->Raster.fd_w ;

    /* Pour conversions conversion index --> format ATARI (Vapi->RaInd2raster) */
    memcpy( &dst_line, &out->Raster, sizeof(MFDB) ) ;
    dst_line.fd_h = 1 ;

    lo_line_in  /= ( 16 / in->Raster.fd_nplanes ) ;
    lo_line_out /= ( 16 / in->Raster.fd_nplanes ) ;
    pt16_in      = (short *) in->Raster.fd_addr ;
    pt16_out     = (short *) out->Raster.fd_addr ;
    pt16_out    += (long)(y1) * lo_line_out ;
  }
  else if ( in->Raster.fd_nplanes == 16 )
  {
    pt16_in   = (short *) in->Raster.fd_addr ;
    pt16_out  = (short *) out->Raster.fd_addr ;
    pt16_out += (long)(y1) * lo_line_out ;
  }
  else
  {
    pt32_in   = (long *) in->Raster.fd_addr ;
    pt32_out  = (long *) out->Raster.fd_addr ;
    pt32_out += (long)(y1) * lo_line_out ;
  }

  wscale = ( wpixel * depth ) / 100L ;
  wlen   = ALIGN16( 1+params->x2 ) ;
  for ( line = y1 ; !cancel && (line <= y2); line++, src_line32 += yoffset )
  {
    wout   = wpixel - ( wscale * (line-y1) / (y2-y1) ) ;
    xpixel = params->x1 + ( ( wpixel - wout ) >> 1 ) ;
    switch( in->Raster.fd_nplanes )
    {
      case  1 :
      case  2 :
      case  4 :
      case  8 :
                Vapi->RaRaster2Ind( pt16_in + (src_line32 >> 16) * lo_line_in, wlen, in->Raster.fd_nplanes, pt8_in ) ;
                memset( pt8_out, 0, xpixel ) ;
                Vapi->MeSCopyMemory8( pt8_out + xpixel, pt8_in + params->x1, wout, wpixel ) ;
                dst_line.fd_addr = pt16_out ;
                Vapi->RaInd2RasterInit( &dst_line, xpixel+wout-1 ) ;
                Vapi->RaInd2Raster( pt8_out, xpixel+wout-1 ) ;
                pt16_out += lo_line_out ;
                break ;

      case 16 : Vapi->MeSCopyMemory16( pt16_out + xpixel,
                                       pt16_in + (long)params->x1 + (src_line32 >> 16) * lo_line_in,
                                       wout, wpixel ) ;
                pt16_out += lo_line_out ;
                break ;

      case 32 : Vapi->MeSCopyMemory32( pt32_out + xpixel,
                                       pt32_in + (long)params->x1 + (src_line32 >> 16) * lo_line_in,
                                       wout, wpixel ) ;
                pt32_out += lo_line_out ;
      default:  break ;
    }
    if ( Vapi && ( line & 0x0F) == 0x0F )
    {
      /* Appelle la routine de progression une fois sur 16 */
      /* NB : en mode preview, VISION ignorera cet appel,  */
      /*      inutile donc de s'en soucier                 */
      pc     = (short) ( ( 100L * (long)(line - y1) ) / (long)(y2 - y1) ) ;
      cancel = Vapi->PrSetProgEx( pc ) ;
    }
  }

  if ( pt8_in ) free( pt8_in ) ;

  return( cancel ? ELDV_CANCELLED : ELDV_NOERROR ) ;
}

LDV_STATUS cdecl Preview(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out)
{
  return( Run( in, params, out ) ) ;
}
#pragma warn +par


int main(void)
{
  ldg_init( Ldg ) ;

  return( 0 ) ;
}
