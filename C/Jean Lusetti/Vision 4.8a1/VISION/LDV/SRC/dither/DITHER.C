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
LDV_INFOS* cdecl GetLDVCapabilities(VAPI *vapi) ;
LDV_STATUS cdecl PreRun(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out) ;
LDV_STATUS cdecl Run(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out) ;
LDV_STATUS cdecl Preview(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out) ;

void OnClose(void) ;

/* Variables globales */
PROC Proc[]  = {
                 "GetLDVCapabilities", "LDV capabilties", (void *)GetLDVCapabilities,
                 "PreRun", "Before Run", (void *)PreRun,
                 "Run", "LDV routine", (void *)Run,
                 "Preview", "Preview", (void *)Preview,
              } ;

char Info[] = "LDV";

LDGLIB Ldg[] = {
        0x0100, /* version de la lib, recommand‚  */
        4,		  /* nombre de fonction dans la lib */
        Proc,	  /* Pointeurs vers nos fonctions   */
        Info,   /* Information sur la lib         */
        0x0,   	/* Flags de la lib, obligatoire   */
        NULL,
        };

#define BP_CAPS (LDVF_ATARIFORMAT | LDVF_SUPPORTPREVIEW | LDVF_REALTIMEPARAMS | LDVF_NOSELECTION | LDVF_AFFECTPALETTE)
#define TC_CAPS (LDVF_ATARIFORMAT | LDVF_SUPPORTPREVIEW | LDVF_REALTIMEPARAMS | LDVF_NOSELECTION | LDVF_AFFECTPALETTE)

LDV_INFOS LdvInfos = {
                       (short) sizeof(LDV_INFOS), /* Taille de cette structure */
                       TLDV_MODIFYIMG,            /* Type du LDV               */
                       "Jean Lusetti",            /* Auteurs                   */
                       {
                         {  1, 1, BP_CAPS }, /* Capacites pour 1 plan    */
                         {  4, 1, BP_CAPS }, /* Capacites pour 4 plans    */
                         {  8, 1, BP_CAPS }, /* Capacites pour 8 plans    */
                         { 16, 1, TC_CAPS }, /* Capacites pour 16 plans   */
                         { 32, 1, TC_CAPS }, /* Capacites pour 32 plans   */
                         { 0, 0, 0UL }        /* Fin de la liste des capacites */
                       },
                     } ;

VAPI* Vapi = NULL ;

/* Petite macro de verification pour VAPI */
#define CHECK_VAPI(vapi) if ( (vapi == NULL) || (vapi->Header.Version < 0x0109) ) return ELDV_BADVAPIVERSION ;


/* 
 * Fonctions de la librairie
 */

LDV_INFOS* cdecl GetLDVCapabilities(VAPI* vapi)
{
  Vapi = vapi ;

  return( &LdvInfos ) ;
}

#pragma warn -par
LDV_STATUS cdecl PreRun(LDV_IMAGE* in, LDV_PARAMS* params, LDV_IMAGE* out)
{
  return ELDV_NOERROR ;
}

LDV_STATUS cdecl Run(LDV_IMAGE* in, LDV_PARAMS* params, LDV_IMAGE* out)
{
  LDV_STATUS status ;
  short      method, param, out_planes ;

  CHECK_VAPI( Vapi ) ;

  method     = params->Param[0].s ;
  param      = params->Param[1].s ;
  out_planes = params->Param[2].s ;
  if ( out_planes <= 0 )
  {
    SCREEN_INFO sinfo ;

    Vapi->CoGetScreenInfo( &sinfo ) ;
    out_planes = sinfo.NPlanes ;
  }
  if ( (out_planes != 1) && (out_planes != 4) &&  (out_planes != 8) &&  (out_planes != 16) &&  (out_planes != 32) )
  {
    if ( out_planes > 32 )      out_planes = 32 ;
    else if ( out_planes > 14 ) out_planes = 16 ; /* TC15 or TC16 */
    else if ( out_planes > 8 )  out_planes = 8 ;
    else if ( out_planes > 4 )  out_planes = 4 ;
    else                        out_planes = 1 ;
    if ( Vapi->LoDoLog ) Vapi->LoDoLog( LL_INFO, "LDVDither: nplanes %d not supported, changed to %d", params->Param[2].s, out_planes ) ;
  }
  out->Raster.fd_nplanes = out_planes ;

  status = (LDV_STATUS) Vapi->ImDither( method, param, in, out ) ;
  if ( status != 0 )
  {
    if ( Vapi->LoDoLog ) Vapi->LoDoLog( LL_WARNING, "LDVDither: ImDither returned %d", status ) ;
    status = ELDV_GENERALFAILURE ;
  }

  return status ;
}

LDV_STATUS cdecl Preview(LDV_IMAGE* in, LDV_PARAMS* params, LDV_IMAGE* out)
{
  return( Run( in, params, out ) ) ;
}
#pragma warn +par


int main(void)
{
  ldg_init( Ldg ) ;

  return 0 ;
}
