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

#define BP_CAPS (LDVF_SPECFORMAT | LDVF_SUPPORTPREVIEW | LDVF_SUPPORTPROG | LDVF_REALTIMEPARAMS | LDVF_SUPPORTCANCEL | LDVF_NOSELECTION)
#define TC_CAPS (LDVF_SPECFORMAT | LDVF_SUPPORTPREVIEW | LDVF_SUPPORTPROG | LDVF_REALTIMEPARAMS | LDVF_SUPPORTCANCEL | LDVF_NOSELECTION)

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

/* Petite macro de verification pour VAPI */
#define CHECK_VAPI(vapi) if ( ( vapi == NULL ) || ( vapi->Header.Version < 0x0103 ) ) return( ELDV_BADVAPIVERSION ) ;

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
  long angle ;

  CHECK_VAPI( Vapi ) ;

  angle = (long) params->Param[0].s ;
  Vapi->RaRasterRotateGetDstMFDB( &in->Raster, &out->Raster, angle ) ;

  return( ELDV_NOERROR ) ;
}

LDV_STATUS cdecl Run(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out)
{
  LDV_STATUS status ;
  long       angle ;

  CHECK_VAPI( Vapi ) ;

  angle = (long) params->Param[0].s ;
  status = Vapi->RaRasterRotate( &in->Raster, &out->Raster, angle, 0x03 ) ; /* 0x03 = 0x01 (progress) | 0x02 (cancel) */

  return( status ) ;
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
