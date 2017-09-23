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

#define CAPS (LDVF_SPECFORMAT | LDVF_SUPPORTPREVIEW | LDVF_SUPPORTPROG | LDVF_REALTIMEPARAMS | LDVF_SUPPORTCANCEL | LDVF_NOSELECTION)

LDV_INFOS LdvInfos = {
                       (short) sizeof(LDV_INFOS), /* Taille de cette structure */
                       TLDV_MODIFYIMG,            /* Type du LDV               */
                       "Jean Lusetti",            /* Auteurs                   */
                       {
                         {  1,  1, CAPS }, /* Capacites pour 1 plan     */
                         {  2,  2, CAPS }, /* Capacites pour 2 plans    */
                         {  4,  4, CAPS }, /* Capacites pour 4 plans    */
                         {  8,  8, CAPS }, /* Capacites pour 8 plans    */
                         { 16, 16, CAPS }, /* Capacites pour 16 plans   */
                         { 24, 24, CAPS }, /* Capacites pour 24 plans   */
                         { 32, 32, CAPS }, /* Capacites pour 32 plans   */
                         { 0, 0, 0UL }     /* Fin de la liste des capacites */
                       },
                     } ;

VAPI  *Vapi = NULL ;
int   VDIHandle = -1 ;
short *ToBeMixed = NULL ; /* Tableau (1,2,...) a melanger */
short Nw, Nh, Entropy ;

void OnClose(void)
{
  if ( VDIHandle != -1 ) v_clsvwk( VDIHandle ) ;
  VDIHandle = -1 ;
  if ( ToBeMixed ) free( ToBeMixed ) ;
  ToBeMixed = NULL ;
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

void SetMixedArray(short Nw, short Nh, short entropy)
{
  short nb = Nw * Nh ;

  if ( ToBeMixed ) free( ToBeMixed ) ;
  ToBeMixed = (short *) malloc( nb * sizeof(short) ) ;
  if ( ToBeMixed )
  {
    short i, j, k, l, *pt ;

    pt = ToBeMixed ;
    for ( i = 0; i < nb; i++ ) *pt++ = i ; /* Un tableau bien trie ... */
    for ( i = 0; i < entropy*entropy; i++ )
    {
      j            = rand() % nb ;  /* On prend 2 elements au hasard */
      k            = rand() % nb ;
      l            = ToBeMixed[j] ; /* Et on les permute ...         */
      ToBeMixed[j] = ToBeMixed[k] ;
      ToBeMixed[k] = l ;
    }
  } 
}

#pragma warn -par
LDV_STATUS cdecl PreRun(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out)
{
  Nw      = params->Param[0].s ;
  Nh      = params->Param[1].s ;
  Entropy = params->Param[2].s ;

  out->Raster.fd_w = in->Raster.fd_w ;
  out->Raster.fd_h = in->Raster.fd_h ;

  return( ELDV_NOERROR ) ;
}

LDV_STATUS cdecl Run(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out)
{
  LDV_STATUS status = ELDV_NOERROR ;
  long       cancel, pc ;
  short      *src_num = ToBeMixed ;
  short      dst_num ;
  int        xy[8] ;
  int        x, y, w, h ;
  int        nw, nh, mw, mh ;

  if ( ToBeMixed == NULL ) return( ELDV_NOTENOUGHMEMORY ) ;

  if ( VDIHandle == -1 ) VDIHandle = vdihandle() ;

  cancel = 0 ;
  w      = in->Raster.fd_w / Nw ;
  h      = in->Raster.fd_h / Nh ;
  mw     = in->Raster.fd_w % Nw ;
  if ( mw )
  {
    /* Les "restes" de bloc sont recopies tels quels */
    xy[0] = xy[4] = in->Raster.fd_w - mw - 1 ;
    xy[1] = xy[5] = 0 ;
    xy[2] = xy[6] = in->Raster.fd_w - 1 ;
    xy[3] = xy[7] = in->Raster.fd_h - 1 ;
    vro_cpyfm( VDIHandle, S_ONLY, xy, &in->Raster, &out->Raster ) ;
  }
  mh = in->Raster.fd_h % Nh ;
  if ( mh )
  {
    /* Les "restes" de bloc sont recopies tels quels */
    xy[0] = xy[4] = 0 ;
    xy[1] = xy[5] = in->Raster.fd_h - mh - 1 ;
    xy[2] = xy[6] = in->Raster.fd_w - 1 ;
    xy[3] = xy[7] = in->Raster.fd_h - 1 ;
    vro_cpyfm( VDIHandle, S_ONLY, xy, &in->Raster, &out->Raster ) ;
  }
  y = 0 ;
  for ( nh = 0; !cancel && ( nh < Nh ); nh++, y += h )
  {
    xy[1] = y ;
    xy[3] = y + h - 1 ;
    x     = 0 ;
    for ( nw = 0; nw < Nw; nw++, x += w )
    {
      dst_num = *src_num++ ;
      xy[0]   = x ;
      xy[2]   = x + w - 1 ;
      xy[4]   = ( dst_num % Nw ) * w ;
      xy[5]   = ( dst_num / Nw ) * h ;
      xy[6]   = xy[4] + w - 1 ;
      xy[7]   = xy[5] + h - 1 ;
      vro_cpyfm( VDIHandle, S_ONLY, xy, &in->Raster, &out->Raster ) ;
    }
    pc     = ( 100L * y ) / in->Raster.fd_h ;
    cancel = Vapi->PrSetProgEx( pc ) ;
  }

  if ( cancel ) status = ELDV_CANCELLED ;

  return( status ) ;
}

LDV_STATUS cdecl Preview(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out)
{
  SetMixedArray( Nw, Nh, Entropy ) ;
  if ( ToBeMixed == NULL ) return( ELDV_NOTENOUGHMEMORY ) ;

  return( Run( in, params, out ) ) ;
}
#pragma warn +par


int main(void)
{
  ldg_init( Ldg ) ;

  srand( 256 ) ;

  return( 0 ) ;
}
