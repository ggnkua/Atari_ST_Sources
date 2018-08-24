#include <string.h>
#include "..\tools\gwindows.h"

#include "..\tools\rasterop.h"

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

  int        type_sym ;
  char       sym_image ;
}
WEXTENSION_SYM ;


void OnInitDialogSym(void *w)
{
  GEM_WINDOW     *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_SYM *wext = wnd->DlgData->UserData ;
  OBJECT         *adr_sym = wnd->DlgData->BaseObject ;

  if ( vclip.gwindow == wext->wnd )
  {
    adr_sym[SYMETRIE_BLOC].ob_state  &= ~DISABLED ;
    adr_sym[SYMETRIE_TBLOC].ob_state &= ~DISABLED ;
  }
  else
  {
    adr_sym[SYMETRIE_BLOC].ob_state  |= DISABLED ;
    adr_sym[SYMETRIE_TBLOC].ob_state |= DISABLED ;
    select(adr_sym, SYMETRIE_IMAGE) ;
    deselect(adr_sym, SYMETRIE_BLOC) ;
  }
}

int OnObjectNotifySym(void *w, int obj)
{
  GEM_WINDOW     *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_SYM *wext = wnd->DlgData->UserData ;
  OBJECT         *adr_sym = wnd->DlgData->BaseObject ;
  int            code = -1 ;

  switch( obj )
  {
     case SYMETRIE_TX     : if (!selected(adr_sym, SYMETRIE_X))
                            {
                              adr_sym[SYMETRIE_X].ob_state  |= SELECTED ;
                              adr_sym[SYMETRIE_Y].ob_state  &= ~SELECTED ;
                              adr_sym[SYMETRIE_XY].ob_state &= ~SELECTED ;
                              xobjc_draw( wnd->window_handle,adr_sym, SYMETRIE_X ) ;
                              xobjc_draw( wnd->window_handle,adr_sym, SYMETRIE_Y ) ;
                              xobjc_draw( wnd->window_handle,adr_sym, SYMETRIE_XY ) ;
                            }
                            break ;
     case SYMETRIE_TY     : if (!selected(adr_sym, SYMETRIE_Y))
                            {
                              adr_sym[SYMETRIE_Y].ob_state  |= SELECTED ;
                              adr_sym[SYMETRIE_X].ob_state  &= ~SELECTED ;
                              adr_sym[SYMETRIE_XY].ob_state &= ~SELECTED ;
                              xobjc_draw( wnd->window_handle,adr_sym, SYMETRIE_X ) ;
                              xobjc_draw( wnd->window_handle,adr_sym, SYMETRIE_Y ) ;
                              xobjc_draw( wnd->window_handle,adr_sym, SYMETRIE_XY ) ;
                            }
                            break ;
     case SYMETRIE_TXY    : if (!selected(adr_sym, SYMETRIE_XY))
                            {
                              adr_sym[SYMETRIE_XY].ob_state |= SELECTED ;
                              adr_sym[SYMETRIE_X].ob_state  &= ~SELECTED ;
                              adr_sym[SYMETRIE_Y].ob_state  &= ~SELECTED ;
                              xobjc_draw( wnd->window_handle,adr_sym, SYMETRIE_X ) ;
                              xobjc_draw( wnd->window_handle,adr_sym, SYMETRIE_Y ) ;
                              xobjc_draw( wnd->window_handle,adr_sym, SYMETRIE_XY ) ;
                            }
                            break ;
     case SYMETRIE_TBLOC  : if (adr_sym[SYMETRIE_TBLOC].ob_state & DISABLED) break ;
                            if (!selected(adr_sym, SYMETRIE_BLOC))
                            {
                              adr_sym[SYMETRIE_BLOC].ob_state  |= SELECTED ;
                              adr_sym[SYMETRIE_IMAGE].ob_state &= ~SELECTED ;
                              xobjc_draw( wnd->window_handle,adr_sym, SYMETRIE_BLOC ) ;
                              xobjc_draw( wnd->window_handle,adr_sym, SYMETRIE_IMAGE ) ;
                            }
                            break ;
     case SYMETRIE_TIMAGE : if (!selected(adr_sym, SYMETRIE_IMAGE))
                            {
                              adr_sym[SYMETRIE_IMAGE].ob_state |= SELECTED ;
                              adr_sym[SYMETRIE_BLOC].ob_state  &= ~SELECTED ;
                              xobjc_draw( wnd->window_handle,adr_sym, SYMETRIE_BLOC ) ;
                              xobjc_draw( wnd->window_handle,adr_sym, SYMETRIE_IMAGE ) ;
                            }
                            break ;
     case SYMETRIE_OK     : code = IDOK ;
                            break ;
     case SYMETRIE_CANCEL : code = IDCANCEL ;
                            break ;
  }

  if ( code == IDOK )
  {
    if ( selected( adr_sym, SYMETRIE_X ) ) wext->type_sym = SYMETRIE_X ;
    if ( selected( adr_sym, SYMETRIE_Y ) ) wext->type_sym = SYMETRIE_Y ;
    if ( selected( adr_sym, SYMETRIE_XY ) ) wext->type_sym = SYMETRIE_XY ;
    if ( selected( adr_sym, SYMETRIE_IMAGE ) ) wext->sym_image = 1 ;
    else                                       wext->sym_image = 0 ;
  }

  return( code ) ;
}

int FGetSym(WEXTENSION_SYM *wext)
{
  GEM_WINDOW *dlg ;
  DLGDATA    dlg_data ;
  int        code ;

  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
  dlg_data.RsrcId       = FORM_SYMETRIE ;
  strcpy( dlg_data.Title, MsgTxtGetMsg(hMsg, MSG_WFNAMES)  ) ;
  dlg_data.UserData     = wext ;
  dlg_data.OnInitDialog = OnInitDialogSym ;
  dlg_data.OnObjectNotify = OnObjectNotifySym ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, 0 ) ;

  if ( code == IDOK )
  {

  }

  return( code ) ;
}

void traite_symetrie(GEM_WINDOW *gwnd)
{
  WEXTENSION_SYM wext ;
  VXIMAGE        *vimage ;
  int            xy[4] ;

  if ( gwnd == NULL ) return ;
  wext.wnd     = gwnd ;
  wext.vimage  = vimage = (VXIMAGE *) gwnd->Extension ;

  if ( FGetSym( &wext ) != IDOK ) return ;

  mouse_busy() ;
  if ( wext.sym_image )
  {
    xy[0] = 0 ;
    xy[1] = 0 ;
    xy[2] = vimage->raster.fd_w-1 ;
    xy[3] = vimage->raster.fd_h-1 ;
  }
  else
  {
    xy[0] = vclip.x1 ;
    xy[1] = vclip.y1 ;
    xy[2] = vclip.x2 ;
    xy[3] = vclip.y2 ;
    gwnd = vclip.gwindow ;
  }

  if ( wext.type_sym == SYMETRIE_X )
  {
    undo_put( gwnd, xy[0], xy[1], xy[2], xy[3], USYMX, NULL ) ;
    if (raster_hsym(&vimage->raster, xy) != 0)
      form_error(8) ;
    if ( wext.sym_image )
    {
      vclip.y1 = vimage->raster.fd_h-1-vclip.y1 ;
      vclip.y2 = vimage->raster.fd_h-1-vclip.y2 ;
      if (vclip.y1 > vclip.y2)
      {
        int temp ;

        temp     = vclip.y1 ; 
        vclip.y1 = vclip.y2 ;
        vclip.y2 = temp ;
      }
    }
  }
  else
  if ( wext.type_sym == SYMETRIE_Y )
  {
    undo_put( gwnd, xy[0], xy[1], xy[2], xy[3], USYMY, NULL ) ;
    if (raster_vsym(&vimage->raster, xy) != 0)
      form_error(8) ;
    if ( wext.sym_image )
    {
      vclip.x1 = vimage->raster.fd_w-1-vclip.x1 ;
      vclip.x2 = vimage->raster.fd_w-1-vclip.x2 ;
      if (vclip.x1 > vclip.x2)
      {
        int temp ;

        temp     = vclip.x1 ; 
        vclip.x1 = vclip.x2 ;
        vclip.x2 = temp ;
      }
    }
  }
  else
  if ( wext.type_sym == SYMETRIE_XY )
  {
    undo_put( gwnd, xy[0], xy[1], xy[2], xy[3], USYMXY, NULL ) ;
    if (raster_vsym(&vimage->raster, xy) != 0)
      form_error(8) ;
    if ( wext.sym_image )
    {
      vclip.x1 = vimage->raster.fd_w-1-vclip.x1 ;
      vclip.x2 = vimage->raster.fd_w-1-vclip.x2 ;
      if (vclip.x1 > vclip.x2)
      {
        int temp ;

        temp     = vclip.x1 ; 
        vclip.x1 = vclip.x2 ;
        vclip.x2 = temp ;
      }
    }
    if (raster_hsym(&vimage->raster, xy) != 0)
      form_error(8) ;
    if ( wext.sym_image )
    {
      vclip.y1 = vimage->raster.fd_h-1-vclip.y1 ;
      vclip.y2 = vimage->raster.fd_h-1-vclip.y2 ;
      if (vclip.y1 > vclip.y2)
      {
        int temp ;

        temp     = vclip.y1 ; 
        vclip.y1 = vclip.y2 ;
        vclip.y2 = temp ;
      }
    }
  }

  mouse_restore() ;
  set_modif( gwnd ) ;
  if (vimage->zoom_level != 1)
    traite_loupe( gwnd, vimage->zoom_level, -1, -1 ) ;
  GWRePaint( gwnd ) ;
}
