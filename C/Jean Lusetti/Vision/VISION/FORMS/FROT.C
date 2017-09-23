#include <string.h>
#include <stdlib.h>
#include <math.h>
#include "..\tools\gwindows.h"

#include "..\tools\rasterop.h"

#include "defs.h"
#include "undo.h"
#include "actions.h"
#include "gstenv.h"
#include "true_col.h"
#include "visionio.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  int x1, x2, x3, x4 ;
  int y1, y2, y3, y4 ;
}
COORD_ROT ;

typedef struct
{
  GEM_WINDOW *wnd ;
  VXIMAGE    *vimage ;
  INFO_IMAGE *inf_img ;

  MFDB       img_rot ;
  MFDB       strech ;
  COORD_ROT  originate_xy ;
  int        rot_angle, angle ;
  int        xc,yc ;
}
WEXTENSION_ROT ;



int cdecl draw_angle(PARMBLK *parmblock)
{
  WEXTENSION_ROT *wext = (WEXTENSION_ROT *) parmblock->pb_parm ;
  float rad ;
  float c, s ;
  int   xc, yc ;
  int   xy[10] ;
  int   cxy[4] ;

  xc = wext->xc ;
  yc = wext->yc ;

  cxy[0] = parmblock->pb_xc ;
  cxy[1] = parmblock->pb_yc ;
  if (cxy[0] < 0) cxy[0] = 0 ;
  if (cxy[1] < 0) cxy[1] = 0 ;
  cxy[2] = cxy[0]+parmblock->pb_wc-1 ;
  cxy[3] = cxy[1]+parmblock->pb_hc-1 ;
  if (cxy[2] >= xdesk+wdesk) cxy[2] = xdesk+wdesk-1 ;
  if (cxy[3] >= ydesk+hdesk) cxy[3] = ydesk+hdesk-1 ;
  vs_clip(handle, 1, cxy);
  v_hide_c(handle) ;
  vswr_mode(handle, MD_REPLACE) ;
  vsf_interior(handle, FIS_SOLID) ;	
  vsf_style(handle, 7) ;
  vsf_perimeter(handle, 0) ;
  vsf_color(handle, 0) ;
  xy[0] = parmblock->pb_x ;
  xy[1] = parmblock->pb_y ;
  xy[2] = parmblock->pb_x+parmblock->pb_w-1 ;
  xy[3] = parmblock->pb_y+parmblock->pb_h-1 ;
  v_bar(handle, xy) ;

  if (wext->img_rot.fd_addr == NULL)
  {
    rad   = wext->rot_angle*M_PI/180.0 ;
    c     = cos(rad) ;
    s     = sin(rad) ;
    xy[0] = parmblock->pb_x + xc + (int) (0.5+c*(float)(wext->originate_xy.x1-xc)+s*(float)(wext->originate_xy.y1-yc)) ;
    xy[1] = parmblock->pb_y + yc + (int) (0.5-s*(float)(wext->originate_xy.x1-xc)+c*(float)(wext->originate_xy.y1-yc)) ;
    xy[2] = parmblock->pb_x + xc + (int) (0.5+c*(float)(wext->originate_xy.x2-xc)+s*(float)(wext->originate_xy.y2-yc)) ;
    xy[3] = parmblock->pb_y + yc + (int) (0.5-s*(float)(wext->originate_xy.x2-xc)+c*(float)(wext->originate_xy.y2-yc)) ;
    xy[4] = parmblock->pb_x + xc + (int) (0.5+c*(float)(wext->originate_xy.x3-xc)+s*(float)(wext->originate_xy.y3-yc)) ;
    xy[5] = parmblock->pb_y + yc + (int) (0.5-s*(float)(wext->originate_xy.x3-xc)+c*(float)(wext->originate_xy.y3-yc)) ;
    xy[6] = parmblock->pb_x + xc + (int) (0.5+c*(float)(wext->originate_xy.x4-xc)+s*(float)(wext->originate_xy.y4-yc)) ;
    xy[7] = parmblock->pb_y + yc + (int) (0.5-s*(float)(wext->originate_xy.x4-xc)+c*(float)(wext->originate_xy.y4-yc)) ;
    xy[8] = xy[0] ;
    xy[9] = xy[1] ;

    vsf_style(handle, 1) ;
    vsf_interior(handle, FIS_PATTERN) ;	
    vsf_color(handle, 1) ;
    vsf_perimeter(handle, 1) ;
    v_fillarea(handle, 5, xy) ;
  }
  else
  {
    xy[0] = xy[1] = 0 ;
    xy[2] = wext->img_rot.fd_w-1 ;
    xy[3] = wext->img_rot.fd_h-1 ;
    xy[4] = parmblock->pb_x + xc-wext->img_rot.fd_w/2 ;
    xy[5] = parmblock->pb_y + yc-wext->img_rot.fd_h/2 ;
    xy[6] = parmblock->pb_x + xc+wext->img_rot.fd_w/2 ;
    xy[7] = parmblock->pb_y + yc+wext->img_rot.fd_h/2 ;
    vro_cpyfm(handle, S_ONLY, xy, &wext->img_rot, &screen) ;
  }

  vs_clip(handle, 0, cxy) ;
  v_show_c(handle, 1) ;

  return(0) ;
}

void OnInitDialogRot(void *gw)
{
  GEM_WINDOW     *wnd = (GEM_WINDOW *) gw ;
  WEXTENSION_ROT *wext = wnd->DlgData->UserData ;
  VXIMAGE        *vimage = wext->vimage ;
  OBJECT         *adr_rotation = wnd->DlgData->BaseObject ;
  float          coe ;
  int            w, h, pc ;
  char           buf[10] ;

  memset( &wext->img_rot, 0, sizeof(MFDB) ) ;
  adr_rotation[ROTATE_BOX].ob_spec.userblk->ub_code = draw_angle ;
  adr_rotation[ROTATE_BOX].ob_spec.userblk->ub_parm = (long) wext ;

  wext->xc = adr_rotation[ROTATE_BOX].ob_width/2 ;
  wext->yc = adr_rotation[ROTATE_BOX].ob_height/2 ;
  coe = (float)vimage->raster.fd_w ;
  if (coe < (float) vimage->raster.fd_h) coe = (float) vimage->raster.fd_h ;
  coe = coe*sqrt(2.0) ;
  w   = (int) ((float)adr_rotation[ROTATE_BOX].ob_width*(float)vimage->raster.fd_w/coe) ;
  h   = (int) ((float)adr_rotation[ROTATE_BOX].ob_height*(float)vimage->raster.fd_h/coe) ;
  wext->originate_xy.x1 = wext->xc-w/2 ;
  wext->originate_xy.y1 = wext->yc-h/2 ;
  wext->originate_xy.x2 = wext->xc+w/2 ;
  wext->originate_xy.y2 = wext->yc-h/2 ;
  wext->originate_xy.x3 = wext->xc+w/2 ;
  wext->originate_xy.y3 = wext->yc+h/2 ;
  wext->originate_xy.x4 = wext->xc-w/2 ;
  wext->originate_xy.y4 = wext->yc+h/2 ;
  read_text(adr_rotation, ROTATE_ANGLE, buf) ;
  wext->angle     = 0 ;
  wext->rot_angle = -wext->angle ;
  adr_rotation[ROTATE_SLIDER].ob_x = (adr_rotation[ROTATE_SBOX].ob_width-adr_rotation[ROTATE_SLIDER].ob_width)/2 ;
  sprintf(buf, "%+.3d", wext->angle) ;
  write_text(adr_rotation, ROTATE_ANGLE, buf) ;

  memset(&wext->strech, 0, sizeof(MFDB)) ;
  wext->strech.fd_w       = w ;
  wext->strech.fd_h       = h ;
  wext->strech.fd_nplanes = vimage->raster.fd_nplanes ;
  wext->strech.fd_wdwidth = wext->strech.fd_w/16 ;
  if (wext->strech.fd_w % 16) wext->strech.fd_wdwidth++ ;
  wext->strech.fd_stand = 0 ;
  pc = (int) (100.0*(float)w/(float)vimage->raster.fd_w) ;
  if (raster_pczoom(&vimage->raster, &wext->strech, pc, pc, NULL) == 0)
  {
    wext->img_rot.fd_addr = NULL ;
    if (raster_rotate(&wext->strech, &wext->img_rot, wext->rot_angle, NULL) == -1)
    {
      free(wext->strech.fd_addr) ;
      wext->img_rot.fd_addr = NULL ;
    }
  }
  else wext->img_rot.fd_addr = NULL ;
}

int OnObjectNotifyRot(void *w, int obj)
{
  GEM_WINDOW     *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_ROT *wext = wnd->DlgData->UserData ;
  OBJECT         *adr_rotation = wnd->DlgData->BaseObject ;
  int            x, xm, dummy ;
  int            code = -1 ;
  char           buf[10] ;

  switch( obj )
  {
     case ROTATE_MOINS   :
     case ROTATE_PLUS    : read_text(adr_rotation, ROTATE_ANGLE, buf) ;
                           wext->angle = atoi(buf) ;
                           if (obj == ROTATE_MOINS) wext->angle -= 5 ;
                           else                     wext->angle += 5 ;
                           if (wext->angle < -180) wext->angle = -180 ;
                           if (wext->angle > 180) wext->angle = 180 ;
                           sprintf(buf, "%+.3d", wext->angle) ;
                           write_text(adr_rotation, ROTATE_ANGLE, buf) ;
                           xobjc_draw( wnd->window_handle, adr_rotation, ROTATE_ANGLE ) ;
                           adr_rotation[ROTATE_SLIDER].ob_x = (int) (((float)(180+wext->angle)/360.0)*(float)(adr_rotation[ROTATE_SBOX].ob_width-adr_rotation[ROTATE_SLIDER].ob_width)) ;
                           xobjc_draw( wnd->window_handle, adr_rotation, ROTATE_SBOX ) ;
                           wext->rot_angle = -wext->angle ;
                           if (wext->img_rot.fd_addr != NULL)
                           {
                             free(wext->img_rot.fd_addr) ;
                             wext->img_rot.fd_addr = NULL ;
                             raster_rotate( &wext->strech, &wext->img_rot, wext->angle, NULL ) ;
                           }
                           xobjc_draw( wnd->window_handle, adr_rotation, ROTATE_BOX ) ;
                           break ;
     case ROTATE_SBOX    : read_text(adr_rotation, ROTATE_ANGLE, buf) ;
                           wext->angle = atoi(buf) ;
                           objc_offset(adr_rotation, ROTATE_SLIDER, &x, &dummy) ;
                           graf_mkstate(&xm, &dummy, &dummy, &dummy) ;
                           if (x > xm) wext->angle -= 20 ;
                           else        wext->angle += 20 ;
                           if (wext->angle < -180) wext->angle = -180 ;
                           if (wext->angle > 180)  wext->angle = 180 ;
                           sprintf(buf, "%+.3d", wext->angle) ;
                           write_text(adr_rotation, ROTATE_ANGLE, buf) ;
                           xobjc_draw( wnd->window_handle, adr_rotation, ROTATE_ANGLE ) ;
                           adr_rotation[ROTATE_SLIDER].ob_x = (int) (((float)(180+wext->angle)/360.0)*(float)(adr_rotation[ROTATE_SBOX].ob_width-adr_rotation[ROTATE_SLIDER].ob_width)) ;
                           xobjc_draw( wnd->window_handle, adr_rotation, ROTATE_SBOX ) ;
                           wext->rot_angle = -wext->angle ;
                           if (wext->img_rot.fd_addr != NULL)
                           {
                             free(wext->img_rot.fd_addr) ;
                             wext->img_rot.fd_addr = NULL ;
                             raster_rotate(&wext->strech, &wext->img_rot, wext->angle, NULL ) ;
                           }
                           xobjc_draw( wnd->window_handle, adr_rotation, ROTATE_BOX ) ;
                           break ;
      case ROTATE_SLIDER : wext->angle = graf_slidebox(adr_rotation, ROTATE_SBOX, ROTATE_SLIDER, 0) ;
                           wext->angle = (int) ((float)wext->angle*360.0/1000.0-180.0) ;
                           adr_rotation[ROTATE_SLIDER].ob_x = (int) (((float)(180+wext->angle)/360.0)*(float)(adr_rotation[ROTATE_SBOX].ob_width-adr_rotation[ROTATE_SLIDER].ob_width)) ;
                           sprintf(buf, "%+.3d", wext->angle) ;
                           write_text(adr_rotation, ROTATE_ANGLE, buf) ;
                           xobjc_draw( wnd->window_handle, adr_rotation, ROTATE_ANGLE ) ;
                           adr_rotation[ROTATE_SLIDER].ob_x = (int) (((float)(180+wext->angle)/360.0)*(float)(adr_rotation[ROTATE_SBOX].ob_width-adr_rotation[ROTATE_SLIDER].ob_width)) ;
                           xobjc_draw( wnd->window_handle, adr_rotation, ROTATE_SBOX ) ;
                           wext->rot_angle = -wext->angle ;
                           if (wext->img_rot.fd_addr != NULL)
                           {
                             free(wext->img_rot.fd_addr) ;
                             wext->img_rot.fd_addr = NULL ;
                             raster_rotate(&wext->strech, &wext->img_rot, wext->angle, NULL ) ;
                           }
                           xobjc_draw( wnd->window_handle, adr_rotation, ROTATE_BOX ) ;
                           break ;
     case ROT_OK         : code = IDOK ;
                           break ;
     case ROT_CANCEL     : code = IDCANCEL ;
                           break ;
  }

  if ( code == IDOK )
  {
    read_text(adr_rotation, ROTATE_ANGLE, buf) ;
    wext->angle = atoi(buf) ;
  }

  return( code ) ;
}

int FGetRot(WEXTENSION_ROT *wext)
{
  GEM_WINDOW *dlg ;
  DLGDATA    dlg_data ;
  int        code ;

  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
  dlg_data.RsrcId       = FORM_ROTATION ;
  strcpy( dlg_data.Title, msg[MSG_WFNAMES] ) ;
  dlg_data.UserData     = wext ;
  dlg_data.OnInitDialog = OnInitDialogRot ;
  dlg_data.OnObjectNotify = OnObjectNotifyRot ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, 0 ) ;

  if ( wext->img_rot.fd_addr != NULL )
  {
    free( wext->strech.fd_addr ) ;
    free( wext->img_rot.fd_addr ) ;
  }

  if ( code == IDOK )
  {

  }

  return( code ) ;
}

void traite_rotation(GEM_WINDOW *gwnd)
{
  GEM_WINDOW     *wprog ;
  WEXTENSION_ROT wext ;
  VXIMAGE        *vimage ;
  INFO_IMAGE     *inf_img ;
  MFDB           out ;
  int            xo, yo, wo, ho, ww, wh ;
  int            dummy ;

  if ( gwnd == NULL ) return ;

  wext.wnd = gwnd ;
  wext.vimage = vimage = (VXIMAGE *) gwnd->Extension ;
  wext.inf_img = inf_img = &vimage->inf_img ;

  if ( FGetRot( &wext ) != IDOK ) return ;

  undo_put( gwnd, 0, 0, vimage->raster.fd_w-1, vimage->raster.fd_h-1, UROTATION, NULL ) ;

  mouse_busy() ;
  wprog = DisplayStdProg( msg[MSG_ROTATING], "", "", CLOSER ) ;
  out.fd_addr = NULL ;
  if ( raster_rotate(&vimage->raster, &out, wext.angle, wprog ) == -1 )
  {
    GWDestroyWindow( wprog ) ;
    form_error(8) ;
    free_lastundo( gwnd ) ;
    mouse_restore() ;
    return ;
  }

  GWDestroyWindow( wprog ) ;
  if (wext.angle != 180) free(vimage->raster.fd_addr) ;
  if (vimage->zoom.fd_addr != NULL) free(vimage->zoom.fd_addr) ;
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

  open_where( gwnd->window_kind, vimage->raster.fd_w, vimage->raster.fd_h, &xo, &yo, &wo, &ho) ;
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
  update_zview( gwnd ) ;
  mouse_restore() ;
  GWInvalidate( gwnd ) ;
}

