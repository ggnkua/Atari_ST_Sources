#include <math.h>
#include <string.h>
#include <stdlib.h>
#include "..\tools\gwindows.h"

#include "..\tools\image_io.h"

#include "defs.h"
#include "undo.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  GEM_WINDOW *wnd ;
  VXIMAGE    *vimage ;
  INFO_IMAGE *info_image ;
}
WEXTENSION_INFOIMG ;

typedef struct
{
  OBJECT *popup ;

  int unite ;
}
WDLG_INFOIMG ;


/* Conversion Pouces --> Unit‚ voulue  */
double coe[] = { 0.0,   /* inutilise */
                 2.54,  /* Pouces --> cm     */
                 25.4,  /* Pouces --> mm     */
                 1.0    /* Pouces --> Inchs  */
               } ;

/*
   Formule … utiliser par la suite :
   (x ou y) (unit‚) = (nb_pixel/dpi(x ou y)) *coe[wdlg->unite]
                        ----- Pouces -----
*/

void OnInitDialogInfoImg(void *w)
{
  GEM_WINDOW   *wnd = (GEM_WINDOW *) w ;
  WDLG_INFOIMG *wdlg = wnd->Extension ;
  WEXTENSION_INFOIMG  *wext = wnd->DlgData->UserData ;
  VXIMAGE      *vimage = wext->vimage ;
  INFO_IMAGE   *info_image = wext->info_image ;
  OBJECT       *adr_inf = wnd->DlgData->BaseObject ;
  double       tpmx, tpmy ;
  double       dpix, dpiy ;
  long         size ;
  int          i, x, y ;
  char         buf[200] ;

  wdlg->popup = popup_make(4, 10) ;
  if ( wdlg->popup == NULL ) return ;
  for (i = 0; i <= 3; i++) strcpy( wdlg->popup[1+i].ob_spec.free_string, msg[MSG_PIXEL+i]) ;

  memset(buf, 0, 50) ;
  tpmx = (double) info_image->lpix ; /* Taille d'un pixel en microns sur (Ox) */
  tpmy = (double) info_image->hpix ; /* Taille d'un pixel en microns sur (Oy) */
  if (tpmx <= 0) tpmx = (double) 0x200 ;
  if (tpmy <= 0) tpmy = (double) 0x200 ;
  dpix = 25400.0/tpmx ; /* 1 Pouce = 25400 Microns */
  dpiy = 25400.0/tpmy ;

  write_text(adr_inf, INFO_NOM, vimage->nom) ;
  size = img_size( vimage->raster.fd_w, vimage->raster.fd_h,
                  nb_plane) ;
  size = size/1024 ; /* En Ko */
  sprintf(buf, "%ld Kb", size) ;
  write_text(adr_inf, INFO_RAM, buf) ;
  write_text(adr_inf, INFO_UNITE, msg[MSG_PIXEL]) ;
  wdlg->unite = 0 ;
  sprintf(buf, "%d x %d", vimage->raster.fd_w, vimage->raster.fd_h) ;
  write_text(adr_inf, INFO_TAILLE, buf) ;
  x = (int) (0.5+dpix) ; y = (int) (0.5+dpiy) ;
  sprintf(buf, "%.4d", x) ;
  write_text(adr_inf, INFO_RESOLX, buf) ;
  sprintf(buf, "%.4d", y) ;
  write_text(adr_inf, INFO_RESOLY, buf) ;
  sprintf(buf, "%ld", (long) pow(2.0, info_image->nplans)) ;
  write_text(adr_inf, INFO_COLORS, buf) ;

  sprintf( buf, "%.1f", (float)(info_image->perf_info.total_load_time)/1000.0 ) ;
  write_text(adr_inf, INFO_TOTAL, buf) ;
  sprintf( buf, "%.1f", (float)(info_image->perf_info.dither_time)/1000.0 ) ;
  write_text(adr_inf, INFO_DITHER, buf) ;
  sprintf( buf, "%.1f", (float)(info_image->perf_info.disk_access_time)/1000.0 ) ;
  write_text(adr_inf, INFO_DISKACCESS, buf) ;
  sprintf( buf, "%.1f", (float)(info_image->perf_info.compress_time)/1000.0 ) ;
  write_text(adr_inf, INFO_COMPRESS, buf) ;
  sprintf( buf, "%.1f", (float)(info_image->perf_info.ind2raster_time)/1000.0 ) ;
  write_text(adr_inf, INFO_IND2RASTER, buf) ;
  sprintf( buf, "%.1f", (float)(info_image->perf_info.stdformat_time)/1000.0 ) ;
  write_text(adr_inf, INFO_STDFORMAT, buf) ;
}

int OnObjectNotifyInfoImg(void *w, int obj)
{
  GEM_WINDOW   *wnd = (GEM_WINDOW *) w ;
  WDLG_INFOIMG *wdlg = wnd->Extension ;
  WEXTENSION_INFOIMG  *wext = wnd->DlgData->UserData ;
  VXIMAGE      *vimage = wext->vimage ;
  INFO_IMAGE   *info_image = wext->info_image ;
  OBJECT       *adr_inf = wnd->DlgData->BaseObject ;
  double       dpix, dpiy, xr, yr ;
  int          clicked, off_x, off_y, x, y ;
  int          code = -1 ;
  char         buf[200] ;

  switch( obj )
  {
    case INFO_UNITE : deselect(adr_inf, INFO_UNITE) ;
                      objc_offset(adr_inf, INFO_UNITE, &off_x, &off_y) ;
                      clicked = popup_formdo(&wdlg->popup, off_x, off_y, 1+wdlg->unite, -1) ;
                      if (clicked > 0) wdlg->unite = clicked-1 ;
                 	  write_text(adr_inf, INFO_UNITE, msg[MSG_PIXEL+wdlg->unite]) ;
                 	  if ( wdlg->unite == 0 )
                 	  {
                 	    x = vimage->raster.fd_w ;
                 	    y = vimage->raster.fd_h ;
                 	    sprintf(buf, "%d x %d", x, y) ;
                 	  }
                 	  else
                 	  {
                 	    read_text(adr_inf, INFO_RESOLX, buf) ;
                 	    x    = atoi(buf) ;
                 	    dpix = (double) x ;
                 	    read_text(adr_inf, INFO_RESOLY, buf) ;
                 	    y    = atoi(buf) ;
                 	    dpiy = (double) y ;
                 	    if (dpix == 0) dpix = 1 ;
                 	    if (dpiy == 0) dpiy = 1 ;
                 	    xr = (double)vimage->raster.fd_w/dpix ;
                 	    yr = (double)vimage->raster.fd_h/dpiy ;
                 	    xr = xr*coe[wdlg->unite] ;
                        yr = yr*coe[wdlg->unite] ;
                 	    sprintf(buf, "%.1f x %.1f", xr, yr) ;
                 	  }
                 	  write_text(adr_inf, INFO_TAILLE, buf) ;
                      xobjc_draw( wnd->window_handle, adr_inf, INFO_UNITE ) ;
                      xobjc_draw( wnd->window_handle, adr_inf, INFO_TAILLE ) ;
                      break ;
     case INFO_OK   : code = IDOK ;
                      break ;
     case INFO_CANCEL : code = IDCANCEL ;
                        break ;
  }

  if ( code == IDOK )
  {
    read_text(adr_inf, INFO_RESOLX, buf) ;
    x    = atoi(buf) ;
    dpix = (double) x ;
    read_text(adr_inf, INFO_RESOLY, buf) ;
    y    = atoi(buf) ;
    dpiy = (double) y ;
    if (dpix == 0) dpix = 1 ;
    if (dpiy == 0) dpiy = 1 ;
    info_image->lpix = (int) (25400.0/dpix) ;
    info_image->hpix = (int) (25400.0/dpiy) ;
  }

  return( code ) ;
}

int OnCloseDialogInfoImg(void *w)
{
  GEM_WINDOW   *wnd = (GEM_WINDOW *) w ;
  WDLG_INFOIMG *wdlg = wnd->Extension ;

  popup_kill( wdlg->popup, 4 ) ;

  return( GWCloseDlg( w ) ) ;
}

void traite_info(GEM_WINDOW *gwnd)
{
  GEM_WINDOW         *dlg ;
  WEXTENSION_INFOIMG wext ;
  DLGDATA            dlg_data ;
  int                code ;

  wext.wnd        = gwnd ;
  wext.vimage     = gwnd->Extension ;
  wext.info_image = &wext.vimage->inf_img ;

  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
  dlg_data.RsrcId       = FORM_INFO ;
  strcpy( dlg_data.Title, msg[MSG_WFNAMES] ) ;
  dlg_data.UserData     = &wext ;
  dlg_data.ExtensionSize = sizeof(WDLG_INFOIMG) ;
  dlg_data.OnInitDialog = OnInitDialogInfoImg ;
  dlg_data.OnObjectNotify = OnObjectNotifyInfoImg ;
  dlg_data.OnCloseDialog  = OnCloseDialogInfoImg ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, 0 ) ;

  if ( code == IDOK )
  {
    set_modif( gwnd ) ;
  }
}
