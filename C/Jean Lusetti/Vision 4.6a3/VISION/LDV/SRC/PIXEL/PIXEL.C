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
LDV_STATUS  cdecl GetParams(LDV_IMAGE *in, LDV_PARAMS *params, char *path) ;

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
                NULL,    /* Fermeture, liberation de VDIHandle (inutilise) */
				};

#define CAPS (LDVF_ATARIFORMAT | LDVF_SUPPORTPREVIEW | LDVF_SUPPORTPROG | LDVF_REALTIMEPARAMS | LDVF_OPINPLACE | LDVF_SUPPORTCANCEL)

LDV_INFOS LdvInfos = {
                       (short) sizeof(LDV_INFOS), /* Taille de cette structure */
                       TLDV_MODIFYIMG,            /* Type du LDV               */
                       "Jean Lusetti",            /* Auteurs                   */
                       {
                         { 16, 16, CAPS },        /* Capacites pour 16 plans   */
/* Qui le fera ?         { 24, 24, CAPS },                                     */
                         { 32, 32, CAPS },        /* Capacites pour 32 plans   */
                         { 0, 0, 0UL }        /* Fin de la liste des capacites */
                       },
                     } ;
/* Ce LDV ne peut marcher qu'avec une versio de VAPI >= 1.02 */
/* Du … un bug dans la version 1.01                          */
#define CHK_VAPIVERSION(vapi) if ( ( vapi == NULL ) || ( vapi->Header.Version < 0x102 ) ) return( ELDV_BADVAPIVERSION ) ;

/* Petites macros bien utiles ... */
#define RVB16( r, v, b ) ( (r << 11) + (v << 5) + (b) )
#define RVB32( r, v, b ) ( ((long)(r) << 24) + ((long)(v) << 16) + ((long)(b << 8)) )

VAPI     *Vapi = NULL ;
unsigned short powerx, powery ;
unsigned long p2 ;

/* 
   Notez que ce LDV ne se sert pas de VDIHandle, OnClose... puisque aucune fonction VDI (vo_cpyfm par ex.) n'est utilisee
int  VDIHandle = -1 ;


void OnClose(void)
{
  if ( VDIHandle != -1 ) v_clsvwk( VDIHandle ) ;
  VDIHandle = -1 ;
}

int vdihandle(void)
{
  int work_in[11], work_out[57], i ;
	
  for ( i = 0; i < 10; work_in[i++] = 1 ) ;
  work_in[10] = 2 ;
  v_opnvwk( work_in, &i, work_out ) ;

  return( i ) ;
}
*/

/* 
 * Fonctions de la librairie
 */

LDV_INFOS * cdecl GetLDVCapabilities(VAPI *vapi)
{
  Vapi = vapi ;

  return( &LdvInfos ) ;
}

#pragma warn -par
LDV_STATUS cdecl PreRun(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out)
{
  CHK_VAPIVERSION( Vapi ) ;

  /* La transformation se fait "sur place" */

  return( ELDV_NOERROR ) ;
}
#pragma warn +par

unsigned short Pixelize16(unsigned short *pt, long nb_lpts)
{
  unsigned short *last_pt = pt ;
  unsigned long  rsum = 0 ;
  unsigned long  gsum = 0 ;
  unsigned long  bsum = 0 ;
  unsigned short pixel, *ptu ;
  unsigned short red, green, blue ;
  short          x, y ;

  for ( y = 0; y < powery; y++, last_pt += nb_lpts )
  {
    ptu = last_pt ;
    for ( x = 0; x < powerx; x++, ptu++ )
    {
      pixel  = *ptu ;
      red    = pixel >> 11 ;            /* Sur 5 bits */
      green  = ( pixel >> 5 ) & 0x3F ;  /* Sur 6 bits */
      blue   = pixel & 0x1F ;           /* Sur 5 bits */
      rsum  += (unsigned long) red ;
      gsum  += (unsigned long) green ;
      bsum  += (unsigned long) blue ;
    }
  }

  red   = (unsigned short) (rsum / p2) ;
  green = (unsigned short) (gsum / p2) ;
  blue  = (unsigned short) (bsum / p2) ;
  pixel = RVB16( red, green, blue ) ;

  return( pixel ) ;
}

LDV_STATUS Run16(LDV_IMAGE *in, LDV_PARAMS *params)
{
  unsigned short new_pixel, *pt, *tmp_pt, *dpix ;
  unsigned long  po2 ;
  long           yoffset, nb_lpts ;
  short          power, x, y ;
  short          pc, cancel = 0 ;
  short          iter = 0 ;

  power   = params->Param[0].s ;
  po2     = power * power ;
  nb_lpts = in->Raster.fd_w ;
  if ( nb_lpts % 16 ) nb_lpts++ ;
  yoffset = nb_lpts * (long)(params->y1) ;
  for ( y = params->y1; !cancel && (y < params->y2); y += power, yoffset += nb_lpts*power )
  {
    powerx = power ;
    if ( y + power - 1 > params->y2 )
    {
      powery = 1 + params->y2 - y ;
      p2     = powerx * powery ;
    }
    else
    {
      powery = power ;
      p2     = po2 ;
    }
    pt = (unsigned short *)(in->Raster.fd_addr) + yoffset + params->x1 ;
    for ( x = params->x1; x < params->x2 - powerx; x += powerx, pt += powerx )
    {
      new_pixel = Pixelize16( pt, nb_lpts ) ;
      for ( tmp_pt = pt; tmp_pt < pt + powery*nb_lpts; tmp_pt += nb_lpts )
        for ( dpix = tmp_pt; dpix < tmp_pt + powerx; dpix++ ) *dpix = new_pixel ;
    }
    /* Residuel sur x (evite un test pour chaque paquet power x power) */
    if ( x < params->x2 )
    {
      powerx    = params->x2 - x ;
      p2        = powerx * powery ;
      new_pixel = Pixelize16( pt, nb_lpts ) ;
      for ( tmp_pt = pt; tmp_pt < pt + powery*nb_lpts; tmp_pt += nb_lpts )
        for ( dpix = tmp_pt; dpix < tmp_pt + powerx; dpix++ ) *dpix = new_pixel ;
    }
    if ( Vapi && ( ( iter++ & 0x0F ) == 0x0F ) )
    {
      pc = (short) ( ( 100L * (long)(y - params->y1) ) / (long)(params->y2 - power- params->y1) ) ;
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

unsigned long Pixelize32(unsigned long *pt, long nb_lpts)
{
  unsigned long  *last_pt = pt ;
  unsigned long  rsum = 0 ;
  unsigned long  gsum = 0 ;
  unsigned long  bsum = 0 ;
  unsigned long  pixel, *ptu ;
  unsigned long  red, green, blue ;
  short          x, y ;

  for ( y = 0; y < powery; y++, last_pt += nb_lpts )
  {
    ptu = last_pt ;
    for ( x = 0; x < powerx; x++, ptu++ )
    {
      pixel  = *ptu ;
      pixel >>= 8 ;
      bsum  += pixel & 0xFF ;
      pixel >>= 8 ;
      gsum  += pixel & 0xFF ;
      pixel >>= 8 ;
      rsum  += pixel ;
    }
  }

  red   = rsum / p2 ;
  green = gsum / p2 ;
  blue  = bsum / p2 ;
  pixel = RVB32( red, green, blue ) ;

  return( pixel ) ;
}

LDV_STATUS Run32(LDV_IMAGE *in, LDV_PARAMS *params)
{
  unsigned long new_pixel, *pt, *tmp_pt, *dpix ;
  unsigned long po2 ;
  long          yoffset, nb_lpts ;
  short         power, x, y ;
  short         pc, cancel = 0 ;
  short         iter = 0 ;

  power   = params->Param[0].s ;
  po2     = power * power ;
  nb_lpts = in->Raster.fd_w ;
  if ( nb_lpts % 16 ) nb_lpts++ ;
  yoffset = nb_lpts * (long)(params->y1) ;
  for ( y = params->y1; !cancel && (y < params->y2); y += power, yoffset += nb_lpts*power )
  {
    powerx = power ;
    if ( y + power - 1 > params->y2 )
    {
      powery = 1 + params->y2 - y ;
      p2     = powerx * powery ;
    }
    else
    {
      powery = power ;
      p2     = po2 ;
    }
    pt = (unsigned long *)(in->Raster.fd_addr) + yoffset + params->x1 ;
    for ( x = params->x1; x < params->x2 - powerx; x += powerx, pt += powerx )
    {
      new_pixel = Pixelize32( pt, nb_lpts ) ;
      for ( tmp_pt = pt; tmp_pt < pt + powery*nb_lpts; tmp_pt += nb_lpts )
        for ( dpix = tmp_pt; dpix < tmp_pt + powerx; dpix++ ) *dpix = new_pixel ;
    }
    /* Residuel sur x (evite un test pour chaque paquet power x power) */
    if ( x < params->x2 )
    {
      powerx    = params->x2 - x ;
      p2        = powerx * powery ;
      new_pixel = Pixelize32( pt, nb_lpts ) ;
      for ( tmp_pt = pt; tmp_pt < pt + powery*nb_lpts; tmp_pt += nb_lpts )
        for ( dpix = tmp_pt; dpix < tmp_pt + powerx; dpix++ ) *dpix = new_pixel ;
    }
    if ( Vapi && ( ( iter++ & 0x0F ) == 0x0F ) )
    {
      pc = (short) ( ( 100L * (long)(y - params->y1) ) / (long)(params->y2 - power- params->y1) ) ;
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

#pragma warn -par
LDV_STATUS cdecl Run(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out)
{
  LDV_STATUS status ; 

  CHK_VAPIVERSION( Vapi ) ;

  if ( ( in->RasterFormat & CAPS ) == 0 ) return( ELDV_IMGFORMATMISMATCH ) ;

/*  if ( VDIHandle == -1 ) VDIHandle = vdihandle() ; (inutile) */

  switch( in->Raster.fd_nplanes )
  {
    case 16 : status = Run16( in, params ) ;
              break ;
/*
    case 24 : status = Run24( in, params ) ;
              break ;
*/
    case 32 : status = Run32( in, params ) ;
              break ;

    default : status = ELDV_NBPLANESNOTSUPPORTED ;
              break ;
  }

  return( status ) ;
}
#pragma warn +par

LDV_STATUS cdecl Preview(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out)
{
  return( Run( in, params, out ) ) ;
}


int main(void)
{
  ldg_init( Ldg ) ;

  return( 0 ) ;
}
