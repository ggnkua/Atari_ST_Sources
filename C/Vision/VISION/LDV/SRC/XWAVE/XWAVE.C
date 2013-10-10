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
#include <math.h>
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

#define CAPS (LDVF_SPECFORMAT | LDVF_SUPPORTPREVIEW | LDVF_SUPPORTPROG | LDVF_REALTIMEPARAMS | LDVF_SUPPORTCANCEL)

LDV_INFOS LdvInfos = {
                       (short) sizeof(LDV_INFOS), /* Taille de cette structure */
                       TLDV_MODIFYIMG,            /* Type du LDV               */
                       "Jean Lusetti",            /* Auteurs                   */
                       {
                         {  1,  1, CAPS },        /* Capacites pour 1 plan     */
                         {  2,  2, CAPS },        /* Capacites pour 2 plans    */
                         {  4,  4, CAPS },        /* Capacites pour 4 plans    */
                         {  8,  8, CAPS },        /* Capacites pour 8 plans    */
                         { 16, 16, CAPS },        /* Capacites pour 16 plans   */
                         { 24, 24, CAPS },        /* Capacites pour 24 plans   */
                         { 32, 32, CAPS },        /* Capacites pour 32 plans   */
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
  float angle, phi ;
  float amplitude ;
  int   xy[8] ;
  short line ;
  short xoffset ;
  short pc, cancel = 0 ;

  if ( VDIHandle == -1 ) VDIHandle = vdihandle() ;

  if (
       ( params->x1 != 0 ) || ( params->x2 != in->Raster.fd_w -1 ) ||
       ( params->y1 != 0 ) || ( params->y2 != in->Raster.fd_h -1 )
     )
  {
    /* Bloc a l'interieur de l'image */
    xy[0] = xy[4] = 0 ;
    xy[1] = xy[5] = 0 ;
    xy[2] = xy[6] = in->Raster.fd_w - 1 ;
    xy[3] = xy[7] = in->Raster.fd_h - 1 ;
    vro_cpyfm( VDIHandle, S_ONLY, xy, &in->Raster, &out->Raster ) ;
  }
  else
    if ( Vapi && Vapi->RaImgWhite ) Vapi->RaImgWhite( &out->Raster ) ;

  amplitude = (float)params->Param[0].s / 10.0 ;
  phi       = M_PI * (float)params->Param[1].s / 10.0 / (float)(params->y2 - params->y1) ;
  for ( line = params->y1 ; !cancel && (line <= params->y2); line++ )
  {
    angle    = (float) (line - params->y1) * phi ;
    xoffset  = (short) (amplitude * ( 1+ sin( angle ) ) ) ;
    if ( params->x2 - xoffset < params->x1 ) xoffset = params->x2 - params->x1 ;
    if ( params->x2 - xoffset > in->Raster.fd_w - 1 ) xoffset = params->x2 - in->Raster.fd_w + 1 ;
    if ( params->x1 + xoffset > out->Raster.fd_w - 1 ) xoffset = out->Raster.fd_w - params->x1 - 1 ;
    if ( params->x2 < params->x1 + xoffset ) xoffset = params->x2 - params->x1 ;
    xy[0]    = params->x1 ;
    xy[1]    = line ;
    xy[2]    = params->x2 - xoffset ;
    xy[3]    = line ;
    xy[4]    = params->x1 + xoffset ;
    xy[5]    = line ;
    xy[6]    = params->x2 ;
    xy[7]    = line ;
    vro_cpyfm( VDIHandle, S_ONLY, xy, &in->Raster, &out->Raster ) ;
    if ( Vapi && ( line & 0x0F) == 0x0F )
    {
      /* Appelle la routine de progression une fois sur 16 */
      /* NB : en mode preview, VISION ignorera cet appel,  */
      /*      inutile donc de s'en soucier                 */
      pc = (short) ( ( 100L * (long)(line - params->y1) ) / (long)(params->y2 - params->y1) ) ;
      if ( Vapi->PrSetProgEx )
      {
        cancel = Vapi->PrSetProgEx( pc ) ;
      }
      else
        Vapi->PrSetProg( pc ) ;
    }
  }

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
