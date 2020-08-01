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
				} ;
/* Enlever le commentaire de la ligne suivante */
/* Pour que le LDV ne supporte plus la         */
/* Transformation sur place (but uniquement    */
/* Pedagogique !                               */
/*#define NOTOPINPLACE*/
#ifndef NOTOPINPLACE
#define CAPS (LDVF_SPECFORMAT | LDVF_SUPPORTPREVIEW | LDVF_OPINPLACE)
#else
#define CAPS (LDVF_SPECFORMAT | LDVF_SUPPORTPREVIEW)
#endif

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
                         { 32, 32, CAPS },        /* Capacites pour 24 plans   */
                         { 24, 24, CAPS },        /* Capacites pour 32 plans   */
                         { 0, 0, 0UL }        /* Fin de la liste des capacites */
                       },
                     } ;

VAPI *Vapi = NULL ;
int  VDIHandle = -1 ;

void OnClose(void)
{
  if ( VDIHandle != -1 ) v_clsvwk( VDIHandle ) ;
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
  int xy[8] ;

  if ( VDIHandle == -1 ) VDIHandle = vdihandle() ;
#ifndef NOTOPINPLACE
  {
   /* Recopie le raster source vers la destination */
    xy[0] = xy[4] = 0 ;
    xy[1] = xy[5] = 0 ;
    xy[2] = xy[6] = in->Raster.fd_w - 1 ;
    xy[3] = xy[7] = in->Raster.fd_h - 1 ;
    vro_cpyfm( VDIHandle, S_ONLY, xy, &in->Raster, &out->Raster ) ;
  }
#endif

  xy[0] = params->x1 ;
  xy[1] = params->y1 ;
  xy[2] = params->x2 ;
  xy[3] = params->y2 ;
  memcpy( &xy[4], xy, 4*sizeof(int) ) ;

  vro_cpyfm( VDIHandle, D_INVERT, xy, &out->Raster, &out->Raster ) ;

  return( ELDV_NOERROR ) ;
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
