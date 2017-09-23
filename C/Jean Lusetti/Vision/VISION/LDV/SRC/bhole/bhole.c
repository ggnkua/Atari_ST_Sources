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
				0x0100,	 /* version de la lib, recommand‚ */
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
long c[1024], s[1024] ; /* Precalculs cosinus et sinus */
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

LDV_STATUS bpRun(MFDB *in, long angle, long gravity, MFDB *out)
{
  MFDB          dst_line ;
  LDV_STATUS    status = ELDV_NOERROR ;
  size_t        size_indexes, size_offset, size_dst_line ;
  short         x, y, pc ;
  long          *loffset, *pt_off, offset, add, wout, sizelout ;
  long          xd, yd, rd2, xs, ys, rs2, p ;
  long          cosinus, sinus ;
  short         alpha ;
  unsigned char *index_in, *index_out, *out_ptr ;
  char          cancel = 0 ;

  /* On va convertir toute en source en indexes, */
  /* Precalculer les offsets de chaque ligne et  */
  /* Allouer de la memoire pour la conversion    */
  /* D'une ligne de destination                  */
  size_indexes  = (long) ALIGN16( in->fd_w ) ;
  size_indexes *= (long) in->fd_h ;
  size_offset   = sizeof(long) * (long) in->fd_h ;
  size_dst_line = (long) ALIGN16( out->fd_w ) ;
  index_in = (unsigned char *) malloc( size_indexes + size_offset + size_dst_line ) ;
  if ( index_in == NULL ) return( ELDV_NOTENOUGHMEMORY ) ;

  loffset   = (long *) (index_in + size_indexes) ;
  index_out = index_in + size_indexes + size_offset ;

  /* Precalcul offsets ligne */
  add    = (long) ALIGN16( in->fd_w ) ;
  offset = 0L ;
  pt_off = loffset ;
  for ( y = 0; y < in->fd_h; y++ )
  {
    *pt_off++ = offset ;
    offset   += add ;
  }

  /* Conversions de la source en indices */
  Vapi->RaRaster2Ind( in->fd_addr, size_indexes, (long)in->fd_nplanes, index_in ) ;

  memcpy( &dst_line, out, sizeof(MFDB) ) ;
  dst_line.fd_wdwidth = out->fd_w / 16 ;
  if ( out->fd_w % 16 ) dst_line.fd_wdwidth++ ;
  dst_line.fd_h = 1 ;
  wout          = (long) ALIGN16( out->fd_w ) ; 
  out_ptr       = out->fd_addr ;
  sizelout      = Vapi->RaGetImgSize( (long) dst_line.fd_w, (long) dst_line.fd_h, (long) out->fd_nplanes ) ;
  yd            = -out->fd_h / 2 ;
  for ( y = 0; !cancel && (y < out->fd_h); y++, out_ptr += sizelout )
  {
    xd  = -out->fd_w / 2 ;
    rd2 = xd*xd + yd*yd ;
    for ( x = 0; x < out->fd_w; x++, xd++ )
    {
      rd2    += ( xd << 1 ) + 1 ;
      rs2     = rd2 ;
      alpha   = 0 ;
      cosinus = c[alpha] ;
      sinus   = s[alpha] ;
      xs      = xd * c[alpha] - yd * s[alpha] ;
      ys      = xd * s[alpha] + yd * c[alpha] ;
      xs    >>= 16 ;
      ys    >>= 16 ;
      p       = loffset[ys] + xs ;
      index_out[x] = index_in[p] ;
    }
    dst_line.fd_addr = out_ptr ;
    Vapi->RaInd2RasterInit( &dst_line, wout ) ;
    Vapi->RaInd2Raster( index_out, wout ) ;
    if ( ( y & 0x0F ) == 0 )
    {
      pc     = (short) ( ( 100L * (long)y ) / (long)out->fd_h ) ;
      cancel = Vapi->PrSetProgEx( pc ) ;
    }
  }

  free( index_in ) ;
  if ( cancel ) status = ELDV_CANCELLED ;

  return( status ) ;
}

LDV_STATUS Run16(MFDB *in, long angle, long gravity, MFDB *out)
{
  LDV_STATUS    status = ELDV_NOERROR ;
  char          cancel = 0 ;

  if ( cancel ) status = ELDV_CANCELLED ;

  return( status ) ;
}

LDV_STATUS Run32(MFDB *in, long angle, long gravity, MFDB *out)
{
  LDV_STATUS    status = ELDV_NOERROR ;
  char          cancel = 0 ;

  if ( cancel ) status = ELDV_CANCELLED ;

  return( status ) ;
}

LDV_STATUS cdecl Run(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out)
{
  LDV_STATUS status ;
  long       gravity, angle ;

  if ( Vapi->Header.Version < 0x102 ) return( ELDV_BADVAPIVERSION ) ;

  angle   = (long) params->Param[0].s ;
  gravity = (long) params->Param[1].s ;

  if ( in->Raster.fd_nplanes <= 8 )       status = bpRun( &in->Raster, angle, gravity, &out->Raster ) ;
  else if ( in->Raster.fd_nplanes == 16 ) status = Run16( &in->Raster, angle, gravity, &out->Raster ) ;
  else if ( in->Raster.fd_nplanes == 32 ) status = Run32( &in->Raster, angle, gravity, &out->Raster ) ;
  else                                    status = ELDV_BADVAPIVERSION ;

  return( status ) ;
}

LDV_STATUS cdecl Preview(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out)
{
  return( Run( in, params, out ) ) ;
}
#pragma warn +par

void InitTrigo(void)
{
  double r, angle, add ;
  long   q, quarter = (sizeof(c) / sizeof(c[0]) >> 2 ;
  long   i ;

  add = M_PI / 2.0 / (double)quarter ;
  for ( angle = 0.0, i = 0; i < quarter; i++, angle += add )
  {
    r    =  65536.0 * cos( angle ) ;
    c[i] = (long) r ;
    r    =  65536.0 * sin( angle ) ;
    s[i] = (long) r ;

    q = quarter ;
    /* Deduction [PI/2;PI] */
    c[q+i] = -s[i] ;
    s[q+i] = c[i] ;

    q += quarter ;
    /* Deduction [PI;3*PI/2] */
    c[q+i] = -c[i] ;
    s[q+i] = -s[i] ;

    q += quarter ;
    /* Deduction [3*PI/2; 2*PI] */
    c[q+i] = c[i] ;
    s[q+i] = -s[i] ;
  }
}

int main(void)
{
  ldg_init( Ldg ) ;

  InitTrigo() ;

  return( 0 ) ;
}
