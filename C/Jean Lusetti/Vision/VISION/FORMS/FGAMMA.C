#include <string.h>
#include <stdlib.h>
#include "..\tools\gwindows.h"

#include "..\tools\rasterop.h"

#include "defs.h"
#include "undo.h"
#include "actions.h"
#include "true_col.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif


typedef struct
{
  GEM_WINDOW *wnd ;
  VXIMAGE    *vimage ;
  INFO_IMAGE *inf_img ;

  int   nb_bits, wbar ;
  int   off_x, off_y ;
  float rgamma, vgamma, bgamma ;

  int           trgamma[1030] ;
  int           tvgamma[1030] ;
  int           tbgamma[1030] ;
  unsigned char tcrgamma[256] ;
  unsigned char tcvgamma[256] ;
  unsigned char tcbgamma[256] ;
}
WEXTENSION_GAMMA ;


void update_gammabox(GEM_WINDOW *wnd, int reference)
{
  WEXTENSION_GAMMA *wext = wnd->DlgData->UserData ;
  OBJECT           *adr_gamma = wnd->DlgData->BaseObject ;
  INFO_IMAGE       *inf_img = wext->inf_img ;
  char             buf[20] ;

  switch( reference )
  {
    case GAMMA_RVAL : xobjc_draw( wnd->window_handle,adr_gamma, GAMMA_RBAR ) ; 
                      sprintf(buf, "%.2f", wext->rgamma) ;
                      if (!Truecolor) set_gamma(wext->rgamma, wext->trgamma) ;
                      else            set_tcgamma(wext->rgamma, wext->tcrgamma, wext->nb_bits) ;
                      break ;
    case GAMMA_VVAL : xobjc_draw( wnd->window_handle,adr_gamma, GAMMA_VBAR ) ; 
                      sprintf(buf, "%.2f", wext->vgamma) ;
                      if (!Truecolor) set_gamma(wext->vgamma, wext->tvgamma) ;
                      else            set_tcgamma(wext->vgamma, wext->tcvgamma, wext->nb_bits) ;
                      break ;
    case GAMMA_BVAL : xobjc_draw( wnd->window_handle,adr_gamma, GAMMA_BBAR ) ; 
                      sprintf(buf, "%.2f", wext->bgamma) ;
                      if (!Truecolor) set_gamma(wext->bgamma, wext->tbgamma) ;
                      else            set_tcgamma(wext->bgamma, wext->tcbgamma, wext->nb_bits) ;
                      break ;
  }

  if (selected(adr_gamma, GAMMA_GROUP))
  {
    switch(reference)
    {
      case GAMMA_RVAL : wext->vgamma = wext->bgamma = wext->rgamma ;
                        if (Truecolor)
                        {
                          memcpy(wext->tcvgamma, wext->tcrgamma, 256) ;
                          memcpy(wext->tcbgamma, wext->tcrgamma, 256) ;
                        }
                        else
                        {
                          memcpy(wext->tvgamma, wext->trgamma, 1030*2) ;
                          memcpy(wext->tbgamma, wext->trgamma, 1030*2) ;
                        }
                        break ;
      case GAMMA_VVAL : wext->rgamma = wext->bgamma = wext->vgamma ;
                        if (Truecolor)
                        {
                          memcpy(wext->tcrgamma, wext->tcvgamma, 256) ;
                          memcpy(wext->tcbgamma, wext->tcvgamma, 256) ;
                        }
                        else
                        {
                          memcpy(wext->trgamma, wext->tvgamma, 1030*2) ;
                          memcpy(wext->tbgamma, wext->tvgamma, 1030*2) ;
                        }
                        break ;
      case GAMMA_BVAL : wext->vgamma = wext->rgamma = wext->bgamma ;
                        if (Truecolor)
                        {
                          memcpy(wext->tcvgamma, wext->tcbgamma, 256) ;
                          memcpy(wext->tcrgamma, wext->tcbgamma, 256) ;
                        }
                        else
                        {
                          memcpy(wext->tvgamma, wext->tbgamma, 1030*2) ;
                          memcpy(wext->trgamma, wext->tbgamma, 1030*2) ;
                        }
                        break ;
    }

    adr_gamma[GAMMA_RSLIDER].ob_x = wext->off_x ;
    xobjc_draw( wnd->window_handle,adr_gamma, GAMMA_RBAR ) ;
    adr_gamma[GAMMA_VSLIDER].ob_x = wext->off_x ;
    xobjc_draw( wnd->window_handle,adr_gamma, GAMMA_VBAR ) ;
    adr_gamma[GAMMA_BSLIDER].ob_x = wext->off_x ;
    xobjc_draw( wnd->window_handle,adr_gamma, GAMMA_BBAR ) ;
    write_text(adr_gamma, GAMMA_RVAL, buf) ;
    xobjc_draw( wnd->window_handle,adr_gamma, GAMMA_RVAL ) ;
    write_text(adr_gamma, GAMMA_VVAL, buf) ;
    xobjc_draw( wnd->window_handle,adr_gamma, GAMMA_VVAL ) ;
    write_text(adr_gamma, GAMMA_BVAL, buf) ;
    xobjc_draw( wnd->window_handle,adr_gamma, GAMMA_BVAL ) ;
  }
  else
  {
    write_text(adr_gamma, reference, buf) ;
    xobjc_draw( wnd->window_handle,adr_gamma, reference ) ;
  }
  if (Truecolor)
  {
    if ( !UseStdVDI )
      screen_tcpal( wext->tcrgamma, wext->tcvgamma, wext->tcbgamma, wext->wnd ) ;
  } 
  else
    if (inf_img->palette != NULL)
    {
      int pal[6*256] ;

      memcpy(pal, inf_img->palette, 6*inf_img->nb_cpal) ;
      make_vdigamma(wext->trgamma, wext->tvgamma, wext->tbgamma, inf_img->palette, (int) inf_img->nb_cpal) ;
      set_imgpalette( wext->vimage ) ;
      memcpy(inf_img->palette, pal, 6*inf_img->nb_cpal) ;
    }
}

void OnInitDialogGamma(void *w)
{
  GEM_WINDOW       *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_GAMMA *wext = wnd->DlgData->UserData ;
  OBJECT           *adr_gamma = wnd->DlgData->BaseObject ;
  char             buf[20] ;

  if ( nb_plane == 16 ) wext->nb_bits = 5 ;
  else                  wext->nb_bits = 8 ;
  wext->rgamma = wext->vgamma = wext->bgamma = 1.0 ;
  sprintf(buf, "%.2f", wext->rgamma) ;
  write_text(adr_gamma, GAMMA_RVAL, buf) ;
  write_text(adr_gamma, GAMMA_VVAL, buf) ;
  write_text(adr_gamma, GAMMA_BVAL, buf) ;
  wext->wbar = adr_gamma[GAMMA_RBAR].ob_width-adr_gamma[GAMMA_RSLIDER].ob_width ;
  if ( Truecolor )
  {
    set_tcgamma( wext->rgamma, wext->tcrgamma, wext->nb_bits ) ;
    memcpy( wext->tcvgamma, wext->tcrgamma, 256) ;
    memcpy( wext->tcbgamma, wext->tcrgamma, 256) ;
  }
  else
  {
    set_gamma( gamma, wext->trgamma) ;
    memcpy( wext->tvgamma, wext->trgamma, 1030*2) ;
    memcpy( wext->tbgamma, wext->trgamma, 1030*2) ;
  }
  wext->off_x = (int) ( wext->rgamma*(float)wext->wbar/2.0 ) ;
  adr_gamma[GAMMA_RSLIDER].ob_x = wext->off_x ;
  adr_gamma[GAMMA_VSLIDER].ob_x = wext->off_x ;
  adr_gamma[GAMMA_BSLIDER].ob_x = wext->off_x ;
}

int OnObjectNotifyGamma(void *w, int obj)
{
  GEM_WINDOW       *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_GAMMA *wext = wnd->DlgData->UserData ;
  OBJECT           *adr_gamma = wnd->DlgData->BaseObject ;
  int              xm, dummy ;
  int              code = -1 ;

  switch( obj )
  {
     case GAMMA_RMOINS  :
     case GAMMA_RPLUS   : if ( obj == GAMMA_RPLUS ) wext->rgamma += 0.05 ;
                          else                      wext->rgamma -= 0.05 ;
                          if ( wext->rgamma < 0.02 ) wext->rgamma = 0.02 ;
                          if ( wext->rgamma > 2.0 )  wext->rgamma = 2.0 ;
                          wext->off_x = (int) (wext->rgamma*(float)wext->wbar/2.0) ;
                          adr_gamma[GAMMA_RSLIDER].ob_x = wext->off_x ;
                          update_gammabox( wnd, GAMMA_RVAL ) ;
                          break ;
     case GAMMA_RBAR  :   graf_mkstate(&xm, &dummy, &dummy, &dummy) ;
                          objc_offset(adr_gamma, GAMMA_RSLIDER, &wext->off_x, &wext->off_y) ;
                          if (xm > wext->off_x) wext->rgamma += 0.2 ;
                          else                  wext->rgamma -= 0.2 ;
                          if (wext->rgamma < 0.02) wext->rgamma = 0.02 ;
                          if (wext->rgamma > 2.0)  wext->rgamma = 2.0 ;
                          wext->off_x = (int) (wext->rgamma*(float)wext->wbar/2.0) ;
                          adr_gamma[GAMMA_RSLIDER].ob_x = wext->off_x ;
                          update_gammabox( wnd, GAMMA_RVAL) ;
                          break ;
     case GAMMA_RSLIDER : wext->rgamma = (float) graf_slidebox(adr_gamma, GAMMA_RBAR, GAMMA_RSLIDER, 0) ;
                          wext->rgamma = wext->rgamma*2.0/1000.0 ;
                          if (wext->rgamma < 0.02) wext->rgamma = 0.02 ;
                          wext->off_x  = (int) (wext->rgamma*(float)wext->wbar/2.0) ;
                          adr_gamma[GAMMA_RSLIDER].ob_x = wext->off_x ;
                          update_gammabox( wnd, GAMMA_RVAL) ;
                          break ;
     case GAMMA_VMOINS  :
     case GAMMA_VPLUS   : if ( obj == GAMMA_VPLUS ) wext->vgamma += 0.05 ;
                          else                      wext->vgamma -= 0.05 ;
                          if (wext->vgamma < 0.02) wext->vgamma = 0.02 ;
                          if (wext->vgamma > 2.0)  wext->vgamma = 2.0 ;
                          wext->off_x = (int) (wext->vgamma*(float)wext->wbar/2.0) ;
                          adr_gamma[GAMMA_VSLIDER].ob_x = wext->off_x ;
                          update_gammabox( wnd, GAMMA_VVAL) ;
                          break ;
     case GAMMA_VBAR  :   graf_mkstate(&xm, &dummy, &dummy, &dummy) ;
                          objc_offset(adr_gamma, GAMMA_VSLIDER, &wext->off_x, &wext->off_y) ;
                          if (xm > wext->off_x) wext->vgamma += 0.2 ;
                          else                  wext->vgamma -= 0.2 ;
                          if (wext->vgamma < 0.02) wext->vgamma = 0.02 ;
                          if (wext->vgamma > 2.0)  wext->vgamma = 2.0 ;
                          wext->off_x = (int) (wext->vgamma*(float)wext->wbar/2.0) ;
                          adr_gamma[GAMMA_VSLIDER].ob_x = wext->off_x ;
                          update_gammabox( wnd, GAMMA_VVAL) ;
                          break ;
     case GAMMA_VSLIDER : wext->vgamma = (float) graf_slidebox(adr_gamma, GAMMA_VBAR, GAMMA_VSLIDER, 0) ;
                          wext->vgamma = wext->vgamma*2.0/1000.0 ;
                          if (wext->vgamma < 0.02) wext->vgamma = 0.02 ;
                          wext->off_x  = (int) (wext->vgamma*(float)wext->wbar/2.0) ;
                          adr_gamma[GAMMA_VSLIDER].ob_x = wext->off_x ;
                          update_gammabox( wnd, GAMMA_VVAL) ;
                          break ;
     case GAMMA_BMOINS  :
     case GAMMA_BPLUS   : if ( obj == GAMMA_BPLUS ) wext->bgamma += 0.05 ;
                          else                      wext->bgamma -= 0.05 ;
                          if (wext->bgamma < 0.02) wext->bgamma = 0.02 ;
                          if (wext->bgamma > 2.0)  wext->bgamma = 2.0 ;
                          wext->off_x = (int) (wext->bgamma*(float)wext->wbar/2.0) ;
                          adr_gamma[GAMMA_BSLIDER].ob_x = wext->off_x ;
                          update_gammabox( wnd, GAMMA_BVAL) ;
                          break ;
     case GAMMA_BBAR  :   graf_mkstate(&xm, &dummy, &dummy, &dummy) ;
                          objc_offset(adr_gamma, GAMMA_BSLIDER, &wext->off_x, &wext->off_y) ;
                          if (xm > wext->off_x) wext->bgamma += 0.2 ;
                          else                  wext->bgamma -= 0.2 ;
                          if (wext->bgamma < 0.02) wext->bgamma = 0.02 ;
                          if (wext->bgamma > 2.0)  wext->bgamma = 2.0 ;
                          wext->off_x = (int) (wext->bgamma*(float)wext->wbar/2.0) ;
                          adr_gamma[GAMMA_BSLIDER].ob_x = wext->off_x ;
                          update_gammabox( wnd, GAMMA_BVAL) ;
                          break ;
     case GAMMA_BSLIDER : wext->bgamma = (float) graf_slidebox(adr_gamma, GAMMA_BBAR, GAMMA_BSLIDER, 0) ;
                          wext->bgamma = wext->bgamma*2.0/1000.0 ;
                          if (wext->bgamma < 0.02) wext->bgamma = 0.02 ;
                          wext->off_x  = (int) (wext->bgamma*(float)wext->wbar/2.0) ;
                          adr_gamma[GAMMA_BSLIDER].ob_x = wext->off_x ;
                          update_gammabox( wnd, GAMMA_BVAL) ;
                          break ;
     case GAMMA_GROUP   :
     case GAMMA_TGROUP  : inv_select(adr_gamma, GAMMA_GROUP) ;
                          break ;
     case GAMMA_OK      : code = IDOK ;
                          break ;
     case GAMMA_CANCEL  : code = IDCANCEL ;
                          break ;
  }

  if ( code == IDOK )
  {

  }

  return( code ) ;
}

void traite_gamma(GEM_WINDOW *gwnd)
{
  GEM_WINDOW       *dlg ;
  WEXTENSION_GAMMA *wext ;
  VXIMAGE          *vimage ;
  INFO_IMAGE       *inf_img ;
  DLGDATA          dlg_data ;
  int              code ;

  if ( gwnd == NULL ) return ;
  wext = (WEXTENSION_GAMMA *) malloc( sizeof(WEXTENSION_GAMMA) ) ;
  if ( wext == NULL )
  {
    form_error( 8 ) ;
    return ;
  }
  wext->wnd     = gwnd ;
  wext->vimage  = vimage  = (VXIMAGE *) gwnd->Extension ;
  wext->inf_img = inf_img = &vimage->inf_img ;

  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
  dlg_data.RsrcId         = FORM_GAMMA ;
  strcpy( dlg_data.Title, msg[MSG_WFNAMES] ) ;
  dlg_data.UserData       = wext ;
  dlg_data.OnInitDialog   = OnInitDialogGamma ;
  dlg_data.OnObjectNotify = OnObjectNotifyGamma ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, 0 ) ;

  if ( code == IDOK )
  {
    mouse_busy() ;
    undo_put( gwnd, 0, 0, vimage->raster.fd_w-1, vimage->raster.fd_h-1, UGAMMA, NULL ) ;

    if ( Truecolor ) make_tcpal( wext->tcrgamma, wext->tcvgamma, wext->tcbgamma, gwnd ) ;
    else
    {
      if ( inf_img->palette )
        make_vdigamma( wext->trgamma, wext->tvgamma, wext->tbgamma, inf_img->palette, (int) inf_img->nb_cpal) ;
      set_imgpalette( vimage ) ;
    }

    set_modif( gwnd ) ;
    mouse_restore() ;
    if (Truecolor) GWRePaint( gwnd ) ;
  }
  else
  {
    if (Truecolor) GWRePaint( gwnd ) ;
    else           set_imgpalette( vimage ) ;
  }

  free( wext ) ;
}

