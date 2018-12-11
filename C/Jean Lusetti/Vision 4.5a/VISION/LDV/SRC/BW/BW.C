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
				0x0102,	 /* version de la lib, recommand‚ */
				4,		 /* nombre de fonction dans la lib */
				Proc,	 /* Pointeurs vers nos fonctions */
				Info, 	 /* Information sur la lib */
				0x0,   	 /* Flags de la lib, obligatoire */
                OnClose, /* Fermeture, liberation de VDIHandle */
				};

#define BP_CAPS (LDVF_SPECFORMAT | LDVF_OPINPLACE | LDVF_SUPPORTPREVIEW | LDVF_AFFECTPALETTE)
#define TC_CAPS (LDVF_SPECFORMAT | LDVF_OPINPLACE | LDVF_SUPPORTPREVIEW | LDVF_SUPPORTPROG | LDVF_SUPPORTCANCEL)

LDV_INFOS LdvInfos = {
                       (short) sizeof(LDV_INFOS), /* Taille de cette structure */
                       TLDV_MODIFYIMG,            /* Type du LDV               */
                       "Jean Lusetti/Olivier Landemarre", /* Auteurs                   */
                       {
                         {  1,  1, BP_CAPS },        /* Capacites pour 1 plan   */
                         {  2,  2, BP_CAPS },        /* Capacites pour 2 plans  */
                         {  4,  4, BP_CAPS },        /* Capacites pour 4 plans  */
                         {  8,  8, BP_CAPS },        /* Capacites pour 8 plans  */
                         { 16, 16, TC_CAPS },        /* Capacites pour 16 plans */
                         { 24, 24, TC_CAPS },        /* Capacites pour 24 plans */
                         { 32, 32, TC_CAPS },        /* Capacites pour 32 plans */
                         { 0, 0, 0UL }         /* Fin de la liste des capacites */
                       },
                     } ;

VAPI *Vapi = NULL ;
int  VDIHandle = -1 ;

/* Petites macros bien utiles ... */
#define RVB16( r, v, b ) ( (r << 11) + (v << 5) + (b) )
#define RVB32( r, v, b ) ( ((long)r << 24) + ((long)v << 16) + ((long)b << 8) )


void OnClose(void)
{
  if ( VDIHandle != -1 ) v_clsvwk( VDIHandle ) ;
  VDIHandle = -1 ;
}

/* 
 * Fonctions de la librairie
 */
int R4[256],G4[256],B4[256];   /*pr‚calcul de luminescence 256 niveaux */

LDV_INFOS * cdecl GetLDVCapabilities(VAPI *vapi)
{ float valR=0,valG=0,valB=0; int i;
  Vapi = vapi ;
  for(i=0;i<256;i++)
  {
			R4[i]=(int)valR;         /* methode rapide */
			G4[i]=(int)valG;
			B4[i]=(int)valB;
			valR+=0.302;
			valG+=0.589;
			valB+=0.114;
			
  }
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
  return( ELDV_NOERROR ) ;
}

LDV_STATUS cdecl Run(LDV_IMAGE *in, LDV_PARAMS *params, LDV_IMAGE *out)
{
  LDV_PALETTE    *vdi_palette = &in->Palette ;
  VDI_ELEMENTPAL *vdi_epal ;
  short          vdi_index ;
  short          bw_value ;
  short          cancel = 0 ;

  if ( in->Raster.fd_nplanes <= 8 )
  {
    if ( vdi_palette == NULL ) return( ELDV_GENERALFAILURE ) ;
    vdi_epal = vdi_palette->Pal ;
    if ( vdi_epal == NULL ) return( ELDV_GENERALFAILURE ) ;

    for ( vdi_index = 0; vdi_index < vdi_palette->NbColors; vdi_index++, vdi_epal++ )
    {
      bw_value        = ( vdi_epal->Red + vdi_epal->Green + vdi_epal->Blue ) / 3 ;
      vdi_epal->Red   = bw_value ;
      vdi_epal->Green = bw_value ;
      vdi_epal->Blue  = bw_value ;
    }
  }
  else
  {
    MFDB  *img = &in->Raster ;
    long  nb_pts_in_line ;
    short x, y, pc ;

    if ( Vapi == NULL ) return( ELDV_GENERALFAILURE ) ;

    /* Convertir l'image au format True Color "standard" ATARI */
    /* Format specifique --> format "ATARI True Color"         */
    Vapi->RaTCInvConvert( img ) ;

    nb_pts_in_line = img->fd_w ;
    if ( nb_pts_in_line % 16 ) nb_pts_in_line = (16+nb_pts_in_line) & 0xFFF0 ; /* Toujours aligne sur 16 pixels ! */

    if ( img->fd_nplanes == 16 )
    {
      unsigned short *ptu, red, green, blue, ugris, val, ubr ;

      for ( y = params->y1; !cancel && (y <= params->y2); y++ )
      {
        ptu  = (unsigned short *) img->fd_addr ;
        ptu += nb_pts_in_line * y ;
        ptu += params->x1 ;
        for ( x = params->x1; x <= params->x2; x++ )
        {
          val    = *ptu ;
          red    = ( val & 0x01F ) << 1 ;   /* Sur 6 bits */
          green  = ( val & 0x07E0 ) >> 6 ;  /* Sur 6 bits */
          blue   = ( val & 0xF800 ) >> 10 ; /* Sur 6 bits */
          ugris  = ( R4[red] + G4[green] + B4[blue] )  ;
          ubr    = ( ugris >> 1 ) ; 
          *ptu++ = RVB16( ubr, ugris, ubr ) ;
        }
        if ( ( y & 0x0F ) == 0x0F )
        {
          /* Appelle la routine de progression une fois sur 16 */
          /* NB : en mode preview, VISION ignorera cet appel,  */
          /*      inutile donc de s'en soucier                 */
          pc = (short) ( ( 100L * ( y - params->y1 ) ) / ( params->y2 - params->y1 ) ) ;
          if ( Vapi->PrSetProgEx )
          {
            cancel = Vapi->PrSetProgEx( pc ) ;
          }
          else
            Vapi->PrSetProg( pc ) ;
        }
      }
    }
    else if ( img->fd_nplanes == 24 ) /* NON teste ! */
    {
      unsigned char  *ptu ;
      unsigned short red, green, blue, ugris ;

      for ( y = params->y1; !cancel && (y <= params->y2); y++ )
      {
        ptu  = (unsigned char *) img->fd_addr ;
        ptu += 3 * nb_pts_in_line * y ;
        ptu += 3 * params->x1 ;
        for ( x = params->x1; x <= params->x2; x++ )
        {
          red    = (unsigned short) (*ptu++) ;
          green  = (unsigned short) (*ptu++) ;
          blue   = (unsigned short) (*ptu++) ;
          ugris  = ( R4[red] + G4[green] + B4[blue] )  ;
          *ptu-- = ugris ;
          *ptu-- = ugris ;
          *ptu-- = ugris ;
          ptu   += 3 ;
        }
        if ( ( y & 0x0F ) == 0x0F )
        {
          /* Appelle la routine de progression une fois sur 16 */
          /* NB : en mode preview, VISION ignorera cet appel,  */
          /*      inutile donc de s'en soucier                 */
          pc = (short) ( ( 100L * ( y - params->y1 ) ) / ( params->y2 - params->y1 ) ) ;
          if ( Vapi->PrSetProgEx )
          {
            cancel = Vapi->PrSetProgEx( pc ) ;
          }
          else
            Vapi->PrSetProg( pc ) ;
        }
      }
    }
    else if ( img->fd_nplanes == 32 )
    {
      unsigned long  *ptu, val ;
      unsigned short red, green, blue, ugris ;

      for ( y = params->y1; !cancel && (y <= params->y2); y++ )
      {
        ptu = (unsigned long *)img->fd_addr ;
        ptu += nb_pts_in_line * y ;
        ptu += params->x1 ;
        for ( x = params->x1; x <= params->x2; x++ )
        {
          val    = *ptu ;
          val  >>= 8 ;
          blue   = (unsigned short) (val & 0xFF) ;
          val  >>= 8 ;
          green  = (unsigned short) (val & 0xFF) ;
          val  >>= 8 ;
          red    = (unsigned short) (val & 0xFF) ;
          ugris  = ( R4[red] + G4[green] + B4[blue] )  ;
          *ptu++ = RVB32( ugris, ugris, ugris ) ;
        }
        if ( ( y & 0x0F ) == 0x0F )
        {
          /* Appelle la routine de progression une fois sur 16 */
          /* NB : en mode preview, VISION ignorera cet appel,  */
          /*      inutile donc de s'en soucier                 */
          pc = (short) ( ( 100L * ( y - params->y1 ) ) / ( params->y2 - params->y1 ) ) ;
          if ( Vapi->PrSetProgEx )
          {
            cancel = Vapi->PrSetProgEx( pc ) ;
          }
          else
            Vapi->PrSetProg( pc ) ;
        }
      }
    }

    /* Format "ATARI True Color" --> format specifique */
    Vapi->RaTCConvert( img ) ;
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
