#include <math.h>
#include <string.h>
#include <stdlib.h>
#include "..\tools\gwindows.h"
#include "..\tools\rasterop.h"
#include "..\tools\image_io.h"
#include "..\tools\stdmline.h"

#include "defs.h"
#include "undo.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  GEM_WINDOW* wnd ;
  VXIMAGE*    vimage ;
  INFO_IMAGE* info_image ;
}
WEXTENSION_INFOIMG ;

typedef struct
{
  OBJECT* popup ;
  int     unite ;
}
WDLG_INFOIMG ;


/* Conversion Pouces --> Unit‚ voulue  */
float coe[] = { 0.0,   /* inutilise */
                2.54,  /* Pouces --> cm     */
                25.4,  /* Pouces --> mm     */
                1.0    /* Pouces --> Inchs  */
              } ;

/*
   Formule … utiliser par la suite :
   (x ou y) (unit‚) = (nb_pixel/dpi(x ou y)) *coe[wdlg->unite]
                        ----- Pouces -----
*/

static void display_time(OBJECT* adr_inf, int obj, size_t time)
{
  char buf[16] ;

  if ( time == PERF_NA ) strcpy( buf, "NA" ) ;
  else                   sprintf( buf, "%.1f", (float)(time)/1000.0 ) ;
  write_text( adr_inf, obj, buf ) ;
}

static void OnInitDialogInfoImg(void* w)
{
  GEM_WINDOW*         wnd = (GEM_WINDOW*) w ;
  WDLG_INFOIMG*       wdlg = wnd->Extension ;
  WEXTENSION_INFOIMG* wext = wnd->DlgData->UserData ;
  VXIMAGE*            vimage = wext->vimage ;
  INFO_IMAGE*         info_image = wext->info_image ;
  OBJECT*             adr_inf = wnd->DlgData->BaseObject ;
  float               tpmx, tpmy ;
  float               dpix, dpiy ;
  long                size ;
  int                 i, x, y ;
  char                buf[200] ;

  wdlg->popup = popup_make(4, 10) ;
  if ( wdlg->popup == NULL ) return ;
  for ( i = 0; i <= 3; i++ ) strcpy( wdlg->popup[1+i].ob_spec.free_string, vMsgTxtGetMsg(MSG_PIXEL+i) ) ;

  memzero( buf, sizeof(buf) ) ;
  tpmx = (float) info_image->lpix ; /* Taille d'un pixel en microns sur (Ox) */
  tpmy = (float) info_image->hpix ; /* Taille d'un pixel en microns sur (Oy) */
  if ( tpmx <= 0 ) tpmx = (float) 0x200 ;
  if ( tpmy <= 0 ) tpmy = (float) 0x200 ;
  dpix = 25400.0/tpmx ; /* 1 Pouce = 25400 Microns */
  dpiy = 25400.0/tpmy ;

  write_text( adr_inf, INFO_NOM, info_image->filename ) ;
  size = img_size( vimage->inf_img.mfdb.fd_w, vimage->inf_img.mfdb.fd_h, screen.fd_nplanes ) ;
  size = size >> 10 ; /* En Ko */
  sprintf(buf, "%ld Kb", size) ;
  write_text( adr_inf, INFO_RAM, buf ) ;
  write_text( adr_inf, INFO_UNITE, vMsgTxtGetMsg(MSG_PIXEL) ) ;
  wdlg->unite = 0 ;
  sprintf( buf, "%d x %d", vimage->inf_img.mfdb.fd_w, vimage->inf_img.mfdb.fd_h ) ;
  write_text( adr_inf, INFO_TAILLE, buf ) ;
  x = (int) (0.5+dpix) ; y = (int) (0.5+dpiy) ;
  sprintf( buf, "%.4d", x ) ;
  write_text( adr_inf, INFO_RESOLX, buf ) ;
  sprintf( buf, "%.4d", y ) ;
  write_text( adr_inf, INFO_RESOLY, buf ) ;
  sprintf( buf, "%ld", 1L << ((info_image->nplanes <= 24)?info_image->nplanes:24) ) ;
  write_text( adr_inf, INFO_COLORS, buf ) ;

  display_time( adr_inf, INFO_TOTAL, info_image->perf_info.total_load_time ) ;
  display_time( adr_inf, INFO_DITHER, info_image->perf_info.dither_time ) ;
  display_time( adr_inf, INFO_DISKACCESS, info_image->perf_info.disk_access_time ) ;
  display_time( adr_inf, INFO_COMPRESS, info_image->perf_info.compress_time ) ;
  display_time( adr_inf, INFO_IND2RASTER, info_image->perf_info.ind2raster_time ) ;
  display_time( adr_inf, INFO_STDFORMAT, info_image->perf_info.stdformat_time ) ;

  if ( !high_res || !get_informations_first(info_image) ) adr_inf[INFO_PLUS].ob_flags |= HIDETREE ;
}

static int get_informations(INFO_IMAGE* inf, MLINES_PARAMS* mlp)
{
  char* informations ;
  int   i, code = IDCANCEL ;

  informations = get_informations_first( inf ) ;
  if ( informations )
  {
    memzero( mlp, sizeof(MLINES_PARAMS) ) ;
    for ( i = 0; informations && (i < MLP_NLINES); i++, informations = get_informations_next(informations) )
      strncpy( &mlp->mesg[i][0], informations, MLP_LINEMAX-1 ) ;
    strncpy( mlp->title, vMsgTxtGetMsg(MSG_IMGADDPROP), sizeof(mlp->title)-1 ) ;
    strcpy( mlp->ok_caption, "OK" ) ;
    strcpy( mlp->cancel_caption, vMsgTxtGetMsg(MSG_CANCEL) );
    code = FormStdMLines( mlp ) ;
  }

  return code ;
}

static int OnObjectNotifyInfoImg(void* w, int obj)
{
  MLINES_PARAMS       mlp ;
  GEM_WINDOW*         wnd = (GEM_WINDOW*) w ;
  WDLG_INFOIMG*       wdlg = wnd->Extension ;
  WEXTENSION_INFOIMG* wext = wnd->DlgData->UserData ;
  VXIMAGE*            vimage = wext->vimage ;
  INFO_IMAGE*         info_image = wext->info_image ;
  OBJECT*             adr_inf = wnd->DlgData->BaseObject ;
  float              dpix, dpiy, xr, yr ;
  int                 clicked, off_x, off_y, x, y ;
  int                 code = -1 ;
  char                buf[200] ;

  switch( obj )
  {
    case INFO_UNITE :   deselect( adr_inf, INFO_UNITE ) ;
                        objc_offset( adr_inf, INFO_UNITE, &off_x, &off_y ) ;
                        clicked = popup_formdo(&wdlg->popup, off_x, off_y, 1+wdlg->unite, -1 ) ;
                        if ( clicked > 0 ) wdlg->unite = clicked-1 ;
                        write_text( adr_inf, INFO_UNITE, vMsgTxtGetMsg(MSG_PIXEL+wdlg->unite) ) ;
                        if ( wdlg->unite == 0 )
                 	      {
                 	        x = vimage->inf_img.mfdb.fd_w ;
                 	        y = vimage->inf_img.mfdb.fd_h ;
                 	        sprintf( buf, "%d x %d", x, y ) ;
                 	      }
                 	      else
                        {
                          read_text( adr_inf, INFO_RESOLX, buf ) ;
                   	      x    = atoi( buf ) ;
                   	      dpix = (float) x ;
                   	      read_text( adr_inf, INFO_RESOLY, buf ) ;
                   	      y    = atoi( buf ) ;
                 	        dpiy = (float) y ;
                 	        if ( dpix == 0 ) dpix = 1 ;
                 	        if ( dpiy == 0 ) dpiy = 1 ;
                 	        xr = (float)vimage->inf_img.mfdb.fd_w/dpix ;
                   	      yr = (float)vimage->inf_img.mfdb.fd_h/dpiy ;
                   	      xr = xr*coe[wdlg->unite] ;
                          yr = yr*coe[wdlg->unite] ;
                   	      sprintf( buf, "%.1f x %.1f", xr, yr ) ;
                   	    }
                   	    write_text( adr_inf, INFO_TAILLE, buf ) ;
                        GWObjcDraw( wnd, adr_inf, INFO_UNITE ) ;
                        GWObjcDraw( wnd, adr_inf, INFO_TAILLE ) ;
                        break ;
     case INFO_PLUS:    if ( get_informations( info_image, &mlp ) == IDOK )
                        {
                          char* sep ;
                          int   i ;

                          release_informations( info_image ) ;
                          for ( i = 0; i < MLP_NLINES; i++ )
                          {
                            sep = strchr( &mlp.mesg[i][0], ':' ) ;
                            if ( sep )
                            {
                              *sep = 0 ;
                              add_informations( info_image, &mlp.mesg[i][0], 1+sep ) ;
                              *sep = ':' ;
                            }
                          }
                        }
                        deselect( adr_inf, obj ) ;
                        GWObjcDraw( wnd, adr_inf, obj ) ;
                        break ;
     case INFO_OK   :   code = IDOK ;
                        break ;
     case INFO_CANCEL : code = IDCANCEL ;
                        break ;
  }

  if ( code == IDOK )
  {
    read_text( adr_inf, INFO_RESOLX, buf ) ;
    x    = atoi( buf ) ;
    dpix = (float) x ;
    read_text( adr_inf, INFO_RESOLY, buf ) ;
    y    = atoi( buf ) ;
    dpiy = (float) y ;
    if ( dpix == 0 ) dpix = 1 ;
    if ( dpiy == 0 ) dpiy = 1 ;
    info_image->lpix = (int) (25400.0/dpix) ;
    info_image->hpix = (int) (25400.0/dpiy) ;
  }

  return code ;
}

static int OnCloseDialogInfoImg(void* w)
{
  GEM_WINDOW   *wnd = (GEM_WINDOW*) w ;
  WDLG_INFOIMG *wdlg = wnd->Extension ;

  popup_kill( wdlg->popup, 4 ) ;

  return( GWCloseDlg( w ) ) ;
}

void traite_info(GEM_WINDOW* gwnd)
{
  WEXTENSION_INFOIMG wext ;
  DLGDATA            dlg_data ;

  wext.wnd        = gwnd ;
  wext.vimage     = gwnd->Extension ;
  wext.info_image = &wext.vimage->inf_img ;

  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId         = FORM_INFO ;
  strcpy( dlg_data.Title, vMsgTxtGetMsg(MSG_WFNAMES)  ) ;
  dlg_data.UserData       = &wext ;
  dlg_data.ExtensionSize  = sizeof(WDLG_INFOIMG) ;
  dlg_data.OnInitDialog   = OnInitDialogInfoImg ;
  dlg_data.OnObjectNotify = OnObjectNotifyInfoImg ;
  dlg_data.OnCloseDialog  = OnCloseDialogInfoImg ;

  if ( GWCreateAndDoModal( &dlg_data, 0 ) == IDOK ) set_modif( gwnd ) ;
}
