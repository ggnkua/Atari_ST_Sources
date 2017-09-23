#include <string.h>
#include <stdlib.h>
#include "..\tools\gwindows.h"

#include "..\tools\rasterop.h"
#include "..\tools\rzoom.h"

#include "defs.h"
#include "undo.h"
#include "actions.h"
#include "gstenv.h"


#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  GEM_WINDOW *wnd ;
  VXIMAGE    *vimage ;
  INFO_IMAGE *inf_img ;

  int        pcx, pcy ;
  float      x, y ;
  char       flag_propor ;
}
WEXTENSION_TAILLE ;

void OnInitDialogTaille(void *w)
{
  GEM_WINDOW        *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_TAILLE *wext = wnd->DlgData->UserData ;
  OBJECT            *adr_taille = wnd->DlgData->BaseObject ;
  float             valx, valy ;
  char              buf[40] ;

  wext->pcx = 100 ;
  sprintf(buf, "%.3d", wext->pcx) ;
  write_text(adr_taille, TAILLE_PCX, buf) ;
  wext->pcy  = 100 ;
  sprintf(buf, "%.3d", wext->pcy) ;
  write_text(adr_taille, TAILLE_PCY, buf) ;
  wext->x = (float)wext->vimage->raster.fd_w/100.0 ;
  wext->y = (float)wext->vimage->raster.fd_h/100.0 ;
  valx    = (float)wext->pcx*wext->x ;
  valy    = (float)wext->pcy*wext->y ;
  sprintf(buf, "%d x %d", (int) valx, (int) valy) ;
  write_text(adr_taille, TAILLE_XY, buf) ;
  wext->flag_propor = selected(adr_taille, TAILLE_PROPOR) ;
}

int OnObjectNotifyTaille(void *w, int obj)
{
  GEM_WINDOW        *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_TAILLE *wext = wnd->DlgData->UserData ;
  OBJECT            *adr_taille = wnd->DlgData->BaseObject ;
  int               flag_propor = selected(adr_taille, TAILLE_PROPOR) ;
  int               newx, newy ;
  int               code = -1 ;
  char              buf[40] ;

  switch( obj )
  {
     case TAILLE_XPLUS  : wext->pcx++ ;
                          if (wext->pcx > 500) wext->pcx = 500 ;
                          sprintf(buf, "%.3d", wext->pcx) ;
                          write_text(adr_taille, TAILLE_PCX, buf) ;
                          if (flag_propor)
                          {
                            wext->pcy = wext->pcx ;
                            write_text(adr_taille, TAILLE_PCY, buf) ;
                            xobjc_draw( wnd->window_handle,adr_taille, TAILLE_PCY ) ;
                          }
                          xobjc_draw( wnd->window_handle,adr_taille, TAILLE_PCX ) ;
                          newx = (int) ((float)wext->pcx*wext->x) ;
                          newy = (int) ((float)wext->pcy*wext->y) ;
                          sprintf(buf, "%d x %d", newx, newy) ;
                          write_text(adr_taille, TAILLE_XY, buf) ;
                          xobjc_draw( wnd->window_handle,adr_taille, TAILLE_XY ) ;
                          break ;
    case TAILLE_XMOINS  : wext->pcx-- ;
                          if (wext->pcx < 1) wext->pcx = 1 ;
                          sprintf(buf, "%.3d", wext->pcx) ;
                          write_text(adr_taille, TAILLE_PCX, buf) ;
                          if (flag_propor)
                          {
                            wext->pcy = wext->pcx ;
                            write_text(adr_taille, TAILLE_PCY, buf) ;
                            xobjc_draw( wnd->window_handle,adr_taille, TAILLE_PCY ) ;
                          }
                          xobjc_draw( wnd->window_handle,adr_taille, TAILLE_PCX ) ;
                          newx = (int) ((float)wext->pcx*wext->x) ;
                          newy = (int) ((float)wext->pcy*wext->y) ;
                          sprintf(buf, "%d x %d", newx, newy) ;
                          write_text(adr_taille, TAILLE_XY, buf) ;
                          xobjc_draw( wnd->window_handle,adr_taille, TAILLE_XY ) ;
                          break ;
     case TAILLE_YPLUS  : wext->pcy++ ;
                          if (wext->pcy > 500) wext->pcy = 500 ;
                          sprintf(buf, "%.3d", wext->pcy) ;
                          write_text(adr_taille, TAILLE_PCY, buf) ;
                          if (flag_propor)
                          {
                            wext->pcx = wext->pcy ;
                            write_text(adr_taille, TAILLE_PCX, buf) ;
                            xobjc_draw( wnd->window_handle,adr_taille, TAILLE_PCX ) ;
                          }
                          xobjc_draw( wnd->window_handle,adr_taille, TAILLE_PCY ) ;
                          newx = (int) ((float)wext->pcx*wext->x) ;
                          newy = (int) ((float)wext->pcy*wext->y) ;
                          sprintf(buf, "%d x %d", newx, newy) ;
                          write_text(adr_taille, TAILLE_XY, buf) ;
                          xobjc_draw( wnd->window_handle,adr_taille, TAILLE_XY ) ;
                          break ;
     case TAILLE_YMOINS  : wext->pcy-- ;
                          if (wext->pcy < 1) wext->pcy = 1 ;
                          sprintf(buf, "%.3d", wext->pcy) ;
                          write_text(adr_taille, TAILLE_PCY, buf) ;
                          if (flag_propor)
                          {
                            wext->pcx = wext->pcy ;
                            write_text(adr_taille, TAILLE_PCX, buf) ;
                            xobjc_draw( wnd->window_handle,adr_taille, TAILLE_PCX ) ;
                          }
                          xobjc_draw( wnd->window_handle,adr_taille, TAILLE_PCY ) ;
                          newx = (int) ((float)wext->pcx*wext->x) ;
                          newy = (int) ((float)wext->pcy*wext->y) ;
                          sprintf(buf, "%d x %d", newx, newy) ;
                          write_text(adr_taille, TAILLE_XY, buf) ;
                          xobjc_draw( wnd->window_handle,adr_taille, TAILLE_XY ) ;
                          break ;
     case TAILLE_TPROPOR: inv_select(adr_taille, TAILLE_PROPOR) ;
                          break ;
     case TAILLE_OK     : code = IDOK ;
                          break ;
     case TAILLE_CANCEL : code = IDCANCEL ;
                          break ;
  }

  if ( code == IDOK )
  {
    wext->flag_propor = selected(adr_taille, TAILLE_PROPOR) ;
  }

  return( code ) ;
}

int FGetTaille(WEXTENSION_TAILLE *wext)
{
  GEM_WINDOW *dlg ;
  DLGDATA    dlg_data ;
  int        code ;

  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
  dlg_data.RsrcId       = FORM_TAILLE ;
  strcpy( dlg_data.Title, msg[MSG_WFNAMES] ) ;
  dlg_data.UserData     = wext ;
  dlg_data.OnInitDialog = OnInitDialogTaille ;
  dlg_data.OnObjectNotify = OnObjectNotifyTaille ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, TAILLE_PCX ) ;

  if ( code == IDOK )
  {

  }

  return( code ) ;
}

void traite_taille(GEM_WINDOW *gwnd)
{
  GEM_WINDOW        *wprog ;
  WEXTENSION_TAILLE wext ;
  VXIMAGE           *vimage ;
  INFO_IMAGE        *inf_img ;
  MFDB              out ;
  float             valx, valy ;
  int               xo, yo, wo, ho ;
  int               xe, ye, wxe, whe ;
  int               ww, wh ;
  int               dummy ;

  if ( gwnd == NULL ) return ;
  wext.wnd     = gwnd ;
  wext.vimage  = vimage = (VXIMAGE *) gwnd->Extension ;
  wext.inf_img = inf_img = &vimage->inf_img ;

  if ( FGetTaille( &wext ) != IDOK ) return ;

  GWSetWindowInfo( gwnd, msg[MSG_CALCULZOOM] ) ;
  mouse_busy() ;

  undo_put( gwnd, 0, 0, vimage->raster.fd_w-1, vimage->raster.fd_h-1, UTAILLE, NULL ) ;

  wprog = DisplayStdProg( msg[MSG_TAILLE], "", "", CLOSER ) ;
/*  if ( raster_pczoom(&vimage->raster, &out, wext.pcx, wext.pcy, wprog ) == -1 )*/
  out.fd_addr = NULL ;
  out.fd_w    = (int) ( 0.5 + (float)vimage->raster.fd_w * wext.pcx / 100.0 ) ;
  out.fd_h    = (int) ( 0.5 + (float)vimage->raster.fd_h * wext.pcy / 100.0 ) ;
  if ( RasterZoom( &vimage->raster, &out, wprog ) )
  {
    GWDestroyWindow( wprog ) ;
    mouse_restore() ;
    form_error(8) ;
    free_lastundo( gwnd ) ;
    GWSetWindowInfo( gwnd, "" ) ;
    return ;
  }
  GWSetWindowInfo( gwnd, "" ) ;
  GWDestroyWindow( wprog ) ;

  free( vimage->raster.fd_addr ) ;
  if ( vimage->zoom.fd_addr ) free( vimage->zoom.fd_addr ) ;
  memcpy(&vimage->raster, &out, sizeof(MFDB)) ;
  inf_img->largeur = out.fd_w ;
  inf_img->hauteur = out.fd_h ;
  memset(&vimage->zoom, 0, sizeof(MFDB)) ;
  vimage->x1         = 0 ;
  vimage->y1         = 0 ;
/*  vimage->x2         = out.fd_w-1 ;
  vimage->y2         = out.fd_h-1 ;*/
  vimage->modif      = 0 ;
  vimage->zoom_level = 1 ;
  if (vclip.gwindow == gwnd)
  {
    valx     = (float)vclip.x1*wext.pcx/100.0 ;
    vclip.x1 = (int) valx ;
    valx     = (float)vclip.x2*wext.pcx/100.0 ;
    vclip.x2 = (int) valx ;
    valy     = (float)vclip.y1*wext.pcy/100.0 ;
    vclip.y1 = (int) valy ;
    valy     = (float)vclip.y2*wext.pcy/100.0 ;
    vclip.y2 = (int) valy ;
  }
  wind_calc( WC_WORK, gwnd->window_kind, xopen, yopen, wdesk-(xopen-xdesk), hdesk-(yopen-ydesk),
            &xe, &ye, &wxe, &whe ) ;
  if (wxe >= vimage->raster.fd_w) wxe = vimage->raster.fd_w-1 ;
  if (whe >= vimage->raster.fd_h) whe = vimage->raster.fd_h-1 ;
  wind_calc(WC_BORDER, gwnd->window_kind, xe, ye, wxe, whe, &xo, &yo, &wo, &ho) ;
  if ( gwnd->is_icon )
  {
    int xywh[4] ;

    xywh[0] = xo ; xywh[1] = yo ;
    xywh[2] = wo ; xywh[3] = ho ;
    GWOnUnIconify( gwnd, xywh ) ;
  }
  else
    GWSetCurrXYWH( gwnd, xo, yo, wo, ho) ;
  gwnd->GetWorkXYWH( gwnd, &dummy, &dummy, &wo, &ho) ;
  vimage->x2 = vimage->x1 + wo - 1 ;
  vimage->y2 = vimage->y1 + ho - 1 ;
  ww = (int) (1000.0*(double)wo/(double)vimage->raster.fd_w) ;
  wh = (int) (1000.0*(double)ho/(double)vimage->raster.fd_h) ;
  GWSetHSlider( gwnd, 1 ) ;
  GWSetVSlider( gwnd, 1) ;
  GWSetHSliderSize( gwnd, ww ) ;
  GWSetVSliderSize( gwnd, wh ) ;
  set_modif( gwnd ) ;
  update_view( gwnd ) ;
  update_zview( gwnd ) ;
  GWRePaint( gwnd ) ;
  mouse_restore() ;
}
