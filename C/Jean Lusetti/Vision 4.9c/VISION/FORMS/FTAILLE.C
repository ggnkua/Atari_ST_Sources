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
  GEM_WINDOW* wnd ;
  VXIMAGE*    vimage ;
  INFO_IMAGE* inf_img ;

  int         pcx, pcy ;
  float       x, y ;
  char        flag_propor ;
}
WEXTENSION_TAILLE ;

static void OnInitDialogTaille(void* w)
{
  GEM_WINDOW*        wnd = (GEM_WINDOW*) w ;
  WEXTENSION_TAILLE* wext = wnd->DlgData->UserData ;
  OBJECT*            adr_taille = wnd->DlgData->BaseObject ;
  float              valx, valy ;
  char               buf[40] ;

  wext->pcx = 100 ;
  sprintf(buf, "%.3d", wext->pcx) ;
  write_text(adr_taille, TAILLE_PCX, buf) ;
  wext->pcy  = 100 ;
  sprintf(buf, "%.3d", wext->pcy) ;
  write_text(adr_taille, TAILLE_PCY, buf) ;
  wext->x = (float)wext->vimage->inf_img.mfdb.fd_w/100.0 ;
  wext->y = (float)wext->vimage->inf_img.mfdb.fd_h/100.0 ;
  valx    = (float)wext->pcx*wext->x ;
  valy    = (float)wext->pcy*wext->y ;
  sprintf(buf, "%d x %d", (int) valx, (int) valy) ;
  write_text(adr_taille, TAILLE_XY, buf) ;
  wext->flag_propor = selected(adr_taille, TAILLE_PROPOR) ;
}

static void handle_sizechange(GEM_WINDOW* wnd, int x_or_y, int add)
{
  WEXTENSION_TAILLE* wext = wnd->DlgData->UserData ;
  OBJECT*            adr_taille = wnd->DlgData->BaseObject ;
  int                flag_propor = selected( adr_taille, TAILLE_PROPOR ) ;
  int                newx, newy ;
  int*               pcxy = &wext->pcx ;
  int*               pcyx = &wext->pcy ;
  int                obj_num1 = TAILLE_PCX ;
  int                obj_num2 = TAILLE_PCY ;
  char               buf[40] ;

  if ( x_or_y == 1 )
  {
    pcxy = &wext->pcy ;
    pcyx = &wext->pcx ;
    obj_num1 = TAILLE_PCY ;
    obj_num2 = TAILLE_PCX ;
  }

  *pcxy += add ;
  if ( *pcxy > 500) *pcxy = 500 ;
  if ( *pcxy < 1 )  *pcxy = 1 ;
  sprintf( buf, "%.3d", *pcxy ) ;
  write_text( adr_taille, obj_num1, buf ) ;
  if ( flag_propor )
  {
    *pcyx = *pcxy ;
    write_text( adr_taille, obj_num2, buf ) ;
    GWObjcDraw( wnd, adr_taille, obj_num2 ) ;
  }
  GWObjcDraw( wnd, adr_taille, obj_num1 ) ;
  newx = (int) ((float)wext->pcx*wext->x) ;
  newy = (int) ((float)wext->pcy*wext->y) ;
  sprintf( buf, "%d x %d", newx, newy ) ;
  write_text( adr_taille, TAILLE_XY, buf ) ;
  GWObjcDraw( wnd, adr_taille, TAILLE_XY ) ;
}

static int OnObjectNotifyTaille(void* w, int obj)
{
  GEM_WINDOW*        wnd = (GEM_WINDOW*) w ;
  WEXTENSION_TAILLE* wext = wnd->DlgData->UserData ;
  OBJECT*            adr_taille = wnd->DlgData->BaseObject ;
  int                code = -1 ;

  switch( obj )
  {
    case TAILLE_XPLUS  :  handle_sizechange( wnd, 0, 1 ) ;
                          break ;
    case TAILLE_XMOINS  : handle_sizechange( wnd, 0, -1 ) ;
                          break ;
    case TAILLE_YPLUS  :  handle_sizechange( wnd, 1, 1 ) ;
                          break ;
    case TAILLE_YMOINS  : handle_sizechange( wnd, 1, -1 ) ;
                          break ;
    case TAILLE_TPROPOR:  inv_select( adr_taille, TAILLE_PROPOR ) ;
                          break ;
    case TAILLE_OK     :  code = IDOK ;
                          break ;
    case TAILLE_CANCEL :  code = IDCANCEL ;
                          break ;
  }

  if ( code == IDOK ) wext->flag_propor = selected( adr_taille, TAILLE_PROPOR ) ;

  return code ;
}

int FGetTaille(WEXTENSION_TAILLE* wext)
{
  DLGDATA dlg_data ;

  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId = FORM_TAILLE ;
  strcpy( dlg_data.Title, vMsgTxtGetMsg(MSG_WFNAMES)  ) ;
  dlg_data.UserData       = wext ;
  dlg_data.OnInitDialog   = OnInitDialogTaille ;
  dlg_data.OnObjectNotify = OnObjectNotifyTaille ;

  return GWCreateAndDoModal( &dlg_data, TAILLE_PCX ) ;
}

void traite_taille(GEM_WINDOW* gwnd)
{
  GEM_WINDOW*       wprog ;
  WEXTENSION_TAILLE wext ;
  VXIMAGE*          vimage ;
  INFO_IMAGE*       inf_img ;
  MFDB              out ;
  float             valx, valy ;
  int               xo, yo, wo, ho ;
  int               xe, ye, wxe, whe ;
  int               ww, wh ;
  int               dummy ;

  if ( gwnd == NULL ) return ;
  wext.wnd     = gwnd ;
  wext.vimage  = vimage = (VXIMAGE*) gwnd->Extension ;
  wext.inf_img = inf_img = &vimage->inf_img ;

  if ( FGetTaille( &wext ) != IDOK ) return ;

  GWSetWindowInfo( gwnd, vMsgTxtGetMsg(MSG_CALCULZOOM) ) ;
  mouse_busy() ;

  undo_put( gwnd, 0, 0, vimage->inf_img.mfdb.fd_w-1, vimage->inf_img.mfdb.fd_h-1, UTAILLE, NULL ) ;

  wprog       = DisplayStdProg( vMsgTxtGetMsg(MSG_TAILLE) , "", "", CLOSER ) ;
  out.fd_addr = NULL ;
  out.fd_w    = (int) ( 0.5 + (float)vimage->inf_img.mfdb.fd_w * wext.pcx / 100.0 ) ;
  out.fd_h    = (int) ( 0.5 + (float)vimage->inf_img.mfdb.fd_h * wext.pcy / 100.0 ) ;
  if ( RasterZoom( &vimage->inf_img.mfdb, &out, wprog ) )
  {
    GWDestroyWindow( wprog ) ;
    mouse_restore() ;
    form_error_mem() ;
    free_lastundo( gwnd ) ;
    GWSetWindowInfo( gwnd, "" ) ;
    return ;
  }
  GWSetWindowInfo( gwnd, "" ) ;
  GWDestroyWindow( wprog ) ;

  Xfree( vimage->inf_img.mfdb.fd_addr ) ;
  if ( vimage->zoom.fd_addr ) Xfree( vimage->zoom.fd_addr ) ;
  CopyMFDB( &vimage->inf_img.mfdb, &out ) ;
  inf_img->width  = out.fd_w ;
  inf_img->height = out.fd_h ;
  ZeroMFDB(&vimage->zoom) ;
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
  if (wxe >= vimage->inf_img.mfdb.fd_w) wxe = vimage->inf_img.mfdb.fd_w-1 ;
  if (whe >= vimage->inf_img.mfdb.fd_h) whe = vimage->inf_img.mfdb.fd_h-1 ;
  wind_calc(WC_BORDER, gwnd->window_kind, xe, ye, wxe, whe, &xo, &yo, &wo, &ho) ;
  if ( gwnd->is_icon )
  {
    int xywh[4] ;

    xywh[0] = xo ; xywh[1] = yo ;
    xywh[2] = wo ; xywh[3] = ho ;
    GWOnUnIconify( gwnd, xywh ) ;
  }
  else GWSetCurrXYWH( gwnd, xo, yo, wo, ho) ;
  gwnd->GetWorkXYWH( gwnd, &dummy, &dummy, &wo, &ho) ;
  vimage->x2 = vimage->x1 + wo - 1 ;
  vimage->y2 = vimage->y1 + ho - 1 ;
  ww = pmf( wo, vimage->inf_img.mfdb.fd_w ) ;
  wh = pmf( ho, vimage->inf_img.mfdb.fd_h ) ;
  VSetIHVSliders( gwnd, ww, wh ) ;
  set_modif( gwnd ) ;
  update_view( gwnd ) ;
  update_zview( gwnd ) ;
  GWRePaint( gwnd ) ;
  mouse_restore() ;
}
