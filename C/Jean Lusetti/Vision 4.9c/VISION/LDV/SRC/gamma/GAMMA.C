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

/* Variables globales */
PROC Proc[]  = {
                 "GetLDVCapabilities", "Capacit‚s du LDV", (void *)GetLDVCapabilities,
                 "PreRun", "Init du Run", (void *)PreRun,
                 "Run", "Fonction du LDV", (void *)Run,
                 "Preview", "Pre-Visu", (void *)Preview,
              } ;

char Info[] = "LDV";

LDGLIB Ldg[] = {
				0x0102,	 /* version de la lib, recommand‚ */
				4,		 /* nombre de fonction dans la lib */
				Proc,	 /* Pointeurs vers nos fonctions */
				Info, 	 /* Information sur la lib */
				0x0,   	 /* Flags de la lib, obligatoire */
                NULL,    /* Fermeture, liberation de VDIHandle */
				};

#define BP_CAPS (LDVF_SPECFORMAT | LDVF_OPINPLACE | LDVF_SUPPORTPREVIEW | LDVF_AFFECTPALETTE | LDVF_REALTIMEPARAMS)
#define TC_CAPS (LDVF_SPECFORMAT | LDVF_OPINPLACE | LDVF_SUPPORTPREVIEW | LDVF_SUPPORTPROG | LDVF_SUPPORTCANCEL | LDVF_REALTIMEPARAMS)

LDV_INFOS LdvInfos = {
                       (short) sizeof(LDV_INFOS), /* Taille de cette structure */
                       TLDV_MODIFYIMG,            /* Type du LDV               */
                       "Jean Lusetti",            /* Auteurs                   */
                       {
                         {  1,  1, BP_CAPS },        /* Capacites pour 1 plan   */
                         {  2,  2, BP_CAPS },        /* Capacites pour 2 plans  */
                         {  4,  4, BP_CAPS },        /* Capacites pour 4 plans  */
                         {  8,  8, BP_CAPS },        /* Capacites pour 8 plans  */
                         { 16, 16, TC_CAPS },        /* Capacites pour 16 plans */
                         { 32, 32, TC_CAPS },        /* Capacites pour 32 plans */
                         { 0, 0, 0UL }         /* Fin de la liste des capacites */
                       },
                     } ;

VAPI *Vapi = NULL ;
double gamma_rgb   = 100.0 ;
double gamma_red   = -1.0 ;
double gamma_green = -1.0 ;
double gamma_blue  = -1.0 ;

unsigned char RedRemap[256] ; /* Tables de reaffectation des couleurs en True Color */
unsigned char GreenRemap[256] ;
unsigned char BlueRemap[256] ;

#define CHECK_VAPI(vapi) if ( (vapi == NULL ) || (vapi->Header.Version < 0x103) ) return( ELDV_BADVAPIVERSION ) ;

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
  return ELDV_NOERROR ;
}

double GammaFunc(double val, double val_max, double gamma)
{
  return( val_max * pow( val/val_max, gamma ) ) ;
}

void ChangeColors(double gamma, unsigned char *tab, unsigned short nb_bits)
{
  unsigned char  *pnew_val = tab ;
  double         max_val = (double) ((1 << nb_bits) - 1) ;
  unsigned short i ;
  
  for ( i = 0; i <= max_val; i++, pnew_val++ )
    *pnew_val = (short) ( 0.5 + GammaFunc( i, max_val, gamma ) ) ;
}

LDV_STATUS cdecl Run(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out)
{
  LDV_PALETTE*    vdi_palette = &in->Palette ;
  VDI_ELEMENTPAL* vdi_epal ;
  double          rgamma, ggamma, bgamma ;
  short           vdi_index ;
  short           cancel = 0 ;

  if ( (params->Param[0].s / 100.0) != gamma_rgb )
  {
    gamma_rgb          = params->Param[0].s / 100.0 ;
    params->Param[1].s = params->Param[0].s ;
    params->Param[2].s = params->Param[0].s ;
    params->Param[3].s = params->Param[0].s ;
  }

  rgamma = params->Param[1].s / 100.0 ;
  ggamma = params->Param[2].s / 100.0 ;
  bgamma = params->Param[3].s / 100.0 ;
  if ( in->Raster.fd_nplanes <= 8 )
  {
    if ( vdi_palette == NULL ) return ELDV_GENERALFAILURE ;
    vdi_epal = vdi_palette->Pal ;
    if ( vdi_epal == NULL ) return ELDV_GENERALFAILURE ;
    for ( vdi_index = 0; vdi_index < vdi_palette->NbColors; vdi_index++, vdi_epal++ )
    {
      if ( rgamma != gamma_red )   vdi_epal->Red   = (short) ( 0.5 + GammaFunc( vdi_epal->Red, 1000.0, rgamma ) ) ;
      if ( ggamma != gamma_green ) vdi_epal->Green = (short) ( 0.5 + GammaFunc( vdi_epal->Green, 1000.0, ggamma ) ) ;
      if ( bgamma != gamma_blue )  vdi_epal->Blue  = (short) ( 0.5 + GammaFunc( vdi_epal->Blue, 1000.0, bgamma ) ) ;
    }
  }
  else
  {
    REMAP_COLORS rc ;
    MFDB           *img = &in->Raster ;
    long           *pt_line32, nb_pts_in_line ;
    short          *pt_line16, y, pc, is_15bits ;
    unsigned short nb_bits_red=8, nb_bits_green=8, nb_bits_blue=8 ; /* Sur 32 bits par defaut */

    CHECK_VAPI(Vapi) ;

    rc.red    = RedRemap ;
    rc.green  = GreenRemap ;
    rc.blue   = BlueRemap ;
    rc.nb_pts = (long) (1 + params->x2 - params->x1) ;
    is_15bits = Vapi->RaIs15Bits() ;
    if ( img->fd_nplanes == 16 )
    {
      nb_bits_red   = 5 ;
      nb_bits_green = is_15bits ? 5:6 ;
      nb_bits_blue  = 5 ;
    }
    /* Remet a jour les precalculs de pourcentage sur les composantes si necessaire */
    if ( rgamma != gamma_red )   ChangeColors( rgamma, RedRemap,   nb_bits_red ) ;
    if ( ggamma != gamma_green ) ChangeColors( ggamma, GreenRemap, nb_bits_green ) ;
    if ( bgamma != gamma_blue )  ChangeColors( bgamma, BlueRemap,  nb_bits_blue ) ;

    nb_pts_in_line = ALIGN16(img->fd_w) ;
    pt_line16  = (short *) img->fd_addr ;
    pt_line16 += (long)(params->y1) * nb_pts_in_line ;
    pt_line16 += params->x1 ;
    pt_line32  = (long *) img->fd_addr ;
    pt_line32 += (long)(params->y1) * nb_pts_in_line ;
    pt_line32 += params->x1 ;
    for ( y = params->y1; !cancel && (y <= params->y2); y++ )
    {
      if ( img->fd_nplanes == 16 )
      {
        rc.pt_img  = pt_line16 ;
        pt_line16 += nb_pts_in_line ;
        if ( is_15bits ) Vapi->RaTC15RemapColors( &rc ) ;
        else             Vapi->RaTC16RemapColors( &rc ) ;
      }
      else
      {
        rc.pt_img  = pt_line32 ;
        pt_line32 += nb_pts_in_line ;
        Vapi->RaTC32RemapColors( &rc ) ;
      }
      if ( ( y & 0x0F ) == 0x0F )
      {
        pc = (short) ( ( 100L * (long)(y - params->y1) ) / (long)(params->y2 - params->y1) ) ;
        cancel = Vapi->PrSetProgEx( pc ) ;
      }
    }
  }
  gamma_red   = rgamma ;
  gamma_green = ggamma ;
  gamma_blue  = bgamma ;

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
