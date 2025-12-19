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
  GEM_WINDOW* wnd ;
  VXIMAGE*    vimage ;

  int        type_sym ;
  char       sym_image ;
}
WEXTENSION_SYM ;


void OnInitDialogSym(void *w)
{
  GEM_WINDOW*     wnd = (GEM_WINDOW*) w ;
  WEXTENSION_SYM* wext = wnd->DlgData->UserData ;
  OBJECT*         adr_sym = wnd->DlgData->BaseObject ;

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

static void handle_sym(GEM_WINDOW* wnd, short obj_num)
{
  OBJECT* adr_sym = wnd->DlgData->BaseObject ;

  if ( !selected( adr_sym, obj_num ) )
  {
    adr_sym[SYMETRIE_X].ob_state  &= ~SELECTED ;
    adr_sym[SYMETRIE_Y].ob_state  &= ~SELECTED ;
    adr_sym[SYMETRIE_XY].ob_state &= ~SELECTED ;
    adr_sym[obj_num].ob_state     |= SELECTED ;
    GWObjcDraw( wnd, adr_sym, SYMETRIE_X ) ;
    GWObjcDraw( wnd, adr_sym, SYMETRIE_Y ) ;
    GWObjcDraw( wnd, adr_sym, SYMETRIE_XY ) ;
  }
}

int OnObjectNotifySym(void *w, int obj)
{
  GEM_WINDOW*     wnd = (GEM_WINDOW*) w ;
  WEXTENSION_SYM* wext = wnd->DlgData->UserData ;
  OBJECT*         adr_sym = wnd->DlgData->BaseObject ;
  int            code = -1 ;

  switch( obj )
  {
     case SYMETRIE_TX     : handle_sym( wnd, SYMETRIE_X ) ;
                            break ;
     case SYMETRIE_TY     : handle_sym( wnd, SYMETRIE_Y ) ;
                            break ;
     case SYMETRIE_TXY    : handle_sym( wnd, SYMETRIE_XY ) ;
                            break ;
     case SYMETRIE_TBLOC  : if (adr_sym[SYMETRIE_TBLOC].ob_state & DISABLED) break ;
                            if (!selected(adr_sym, SYMETRIE_BLOC))
                            {
                              adr_sym[SYMETRIE_BLOC].ob_state  |= SELECTED ;
                              adr_sym[SYMETRIE_IMAGE].ob_state &= ~SELECTED ;
                              GWObjcDraw( wnd,adr_sym, SYMETRIE_BLOC ) ;
                              GWObjcDraw( wnd,adr_sym, SYMETRIE_IMAGE ) ;
                            }
                            break ;
     case SYMETRIE_TIMAGE : if (!selected(adr_sym, SYMETRIE_IMAGE))
                            {
                              adr_sym[SYMETRIE_IMAGE].ob_state |= SELECTED ;
                              adr_sym[SYMETRIE_BLOC].ob_state  &= ~SELECTED ;
                              GWObjcDraw( wnd,adr_sym, SYMETRIE_BLOC ) ;
                              GWObjcDraw( wnd,adr_sym, SYMETRIE_IMAGE ) ;
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

  return code ;
}

int FGetSym(WEXTENSION_SYM *wext)
{
  DLGDATA dlg_data ;

  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId       = FORM_SYMETRIE ;
  strcpy( dlg_data.Title, vMsgTxtGetMsg(MSG_WFNAMES)  ) ;
  dlg_data.UserData     = wext ;
  dlg_data.OnInitDialog = OnInitDialogSym ;
  dlg_data.OnObjectNotify = OnObjectNotifySym ;

  return GWCreateAndDoModal( &dlg_data, 0 ) ;
}

void traite_symetrie(GEM_WINDOW* gwnd)
{
  WEXTENSION_SYM wext ;
  VXIMAGE*       vimage ;
  int            xy[4] ;
  int            sym_mask = 0 ;
  int            utype ;

  if ( gwnd == NULL ) return ;
  wext.wnd    = gwnd ;
  wext.vimage = vimage = (VXIMAGE*) gwnd->Extension ;

  if ( FGetSym( &wext ) != IDOK ) return ;

  if ( wext.sym_image )
  {
    xy[0] = 0 ;
    xy[1] = 0 ;
    xy[2] = vimage->inf_img.mfdb.fd_w-1 ;
    xy[3] = vimage->inf_img.mfdb.fd_h-1 ;
  }
  else
  {
    xy[0] = vclip.x1 ;
    xy[1] = vclip.y1 ;
    xy[2] = vclip.x2 ;
    xy[3] = vclip.y2 ;
    gwnd  = vclip.gwindow ;
  }

  switch( wext.type_sym )
  {
    case SYMETRIE_X:  sym_mask = 1 ;
                      utype = USYMX ;
                      break ;
    case SYMETRIE_Y:  sym_mask = 2 ;
                      utype = USYMY ;
                      break ;
    case SYMETRIE_XY: sym_mask = 3 ;
                      utype = USYMXY ;
                      break ;
  }

  mouse_busy() ;
  if ( sym_mask ) undo_put( gwnd, xy[0], xy[1], xy[2], xy[3], utype, NULL ) ;

  if ( sym_mask & 1 )
  {
    if ( raster_vsym( &vimage->inf_img.mfdb, xy ) != 0 ) form_error_mem() ;
    if ( wext.sym_image )
    {
      vclip.x1 = vimage->inf_img.mfdb.fd_w-1-vclip.x1 ;
      vclip.x2 = vimage->inf_img.mfdb.fd_w-1-vclip.x2 ;
    }
  }
  if ( sym_mask & 2 )
  {
    if ( raster_hsym( &vimage->inf_img.mfdb, xy ) != 0 ) form_error_mem() ;
    if ( wext.sym_image )
    {
      vclip.y1 = vimage->inf_img.mfdb.fd_h-1-vclip.y1 ;
      vclip.y2 = vimage->inf_img.mfdb.fd_h-1-vclip.y2 ;
    }
  }
  ConsistentVClip() ;
  mouse_restore() ;

  set_modif( gwnd ) ;
  if ( vimage->zoom_level != 1 ) traite_loupe( gwnd, vimage->zoom_level, -1, -1 ) ;
  GWRePaint( gwnd ) ;
}
