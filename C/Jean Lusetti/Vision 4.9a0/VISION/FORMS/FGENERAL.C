#include <string.h>
#include "..\tools\gwindows.h"

#include "actions.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  int mode ;
  int mask_out ;
}
WEXTENSION_PGENERAL ;

void OnInitDialogFGeneral(void *w)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
  WEXTENSION_PGENERAL *wext = wnd->DlgData->UserData ;
  OBJECT              *adr_pgen = wnd->DlgData->BaseObject ;

  wext->mode = mode_vswr ;

  if ( config.flags & FLG_MASKOUT )
  {
    select(adr_pgen, MASK_OUT) ;
    deselect(adr_pgen, MASK_IN) ;
  }
  else
  {
    select(adr_pgen, MASK_IN) ;
    deselect(adr_pgen, MASK_OUT) ;
  }

  deselect( adr_pgen, MODE_REMPLACE ) ;
  deselect( adr_pgen, MODE_TRANSPARENT ) ;
  deselect( adr_pgen, MODE_XOR ) ;
  deselect( adr_pgen, MODE_INVTRANS ) ;
  switch( wext->mode )
  {
    case MD_REPLACE : select(adr_pgen, MODE_REMPLACE) ;
                      break ;
    case MD_TRANS   : select(adr_pgen, MODE_TRANSPARENT) ;
                      break ;
    case MD_XOR     : select(adr_pgen, MODE_XOR) ;
                      break ;
    case MD_ERASE   : select(adr_pgen, MODE_INVTRANS) ;
                      break ;
  }
}

int OnObjectNotifyFGeneral(void *w, int obj)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
  WEXTENSION_PGENERAL *wext = wnd->DlgData->UserData ;
  OBJECT              *adr_pgen = wnd->DlgData->BaseObject ;
  int code = -1 ;

  switch( obj )
  {
    case MODE_TRE : if (selected(adr_pgen, MODE_REMPLACE)) break ;
                    inv_select(adr_pgen, MODE_REMPLACE) ;
                    if (selected(adr_pgen, MODE_TRANSPARENT))
                      inv_select(adr_pgen, MODE_TRANSPARENT) ;
                    else
                    if (selected(adr_pgen, MODE_XOR))
                      inv_select(adr_pgen, MODE_XOR) ;
                    else
                    if (selected(adr_pgen, MODE_INVTRANS))
                      inv_select(adr_pgen, MODE_INVTRANS) ;
                    break ;
    case MODE_TTR : if (selected(adr_pgen, MODE_TRANSPARENT)) break ;
                    inv_select(adr_pgen, MODE_TRANSPARENT) ;
                    if (selected(adr_pgen, MODE_REMPLACE))
                      inv_select(adr_pgen, MODE_REMPLACE) ;
                    else
                    if (selected(adr_pgen, MODE_XOR))
                      inv_select(adr_pgen, MODE_XOR) ;
                    else
                    if (selected(adr_pgen, MODE_INVTRANS))
                      inv_select(adr_pgen, MODE_INVTRANS) ;
                    break ;
    case MODE_TXO : if (selected(adr_pgen, MODE_XOR)) break ;
                    inv_select(adr_pgen, MODE_XOR) ;
                    if (selected(adr_pgen, MODE_TRANSPARENT))
                      inv_select(adr_pgen, MODE_TRANSPARENT) ;
                    else
                    if (selected(adr_pgen, MODE_REMPLACE))
                      inv_select(adr_pgen, MODE_REMPLACE) ;
                    else
                    if (selected(adr_pgen, MODE_INVTRANS))
                      inv_select(adr_pgen, MODE_INVTRANS) ;
                    break ;
    case MODE_TTI : if (selected(adr_pgen, MODE_INVTRANS)) break ;
                    inv_select(adr_pgen, MODE_INVTRANS) ;
                    if (selected(adr_pgen, MODE_TRANSPARENT))
                      inv_select(adr_pgen, MODE_TRANSPARENT) ;
                    else
                    if (selected(adr_pgen, MODE_XOR))
                      inv_select(adr_pgen, MODE_XOR) ;
                    else
                    if (selected(adr_pgen, MODE_REMPLACE))
                      inv_select(adr_pgen, MODE_REMPLACE) ;
                    break ;
    case MASK_IN  :
    case MASK_TIN : select(adr_pgen, MASK_IN) ;
                    deselect(adr_pgen, MASK_OUT) ;
                    xobjc_draw( wnd->window_handle, adr_pgen, MASK_IN ) ;
                    xobjc_draw( wnd->window_handle, adr_pgen, MASK_OUT ) ;
                    break ;
    case MASK_OUT :
    case MASK_TOUT :select(adr_pgen, MASK_OUT) ;
                    deselect(adr_pgen, MASK_IN) ;
                    xobjc_draw( wnd->window_handle, adr_pgen, MASK_IN ) ;
                    xobjc_draw( wnd->window_handle, adr_pgen, MASK_OUT ) ;
                    break ;
    case GENERAL_OK : code = IDOK ;
                      break ;
     case GENERAL_CANCEL : code = IDCANCEL ;
                      break ;
  }

  if ( code == IDOK )
  {
    if (selected(adr_pgen, MODE_REMPLACE))    wext->mode = MD_REPLACE ;
    else
    if (selected(adr_pgen, MODE_TRANSPARENT)) wext->mode = MD_TRANS ;
    else
    if (selected(adr_pgen, MODE_XOR))         wext->mode = MD_XOR ;
    else
    if (selected(adr_pgen, MODE_INVTRANS))    wext->mode = MD_ERASE ;

    if (selected(adr_pgen, MASK_OUT)) wext->mask_out = FLG_MASKOUT ;
    else                              wext->mask_out = 0 ;
  }

  return code ;
}

void traite_pgeneral(void)
{
  GEM_WINDOW          *dlg ;
  WEXTENSION_PGENERAL wext ;
  DLGDATA             dlg_data ;
  int    bouton ;

  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId       = FORM_GENERAL ;
  strcpy( dlg_data.Title, MsgTxtGetMsg(hMsg, MSG_WFNAMES)  ) ;
  dlg_data.UserData     = &wext ;
  dlg_data.OnInitDialog = OnInitDialogFGeneral ;
  dlg_data.OnObjectNotify = OnObjectNotifyFGeneral ;

  dlg = GWCreateDialog( &dlg_data ) ;
  bouton = GWDoModal( dlg, 0 ) ;

  if ( bouton == IDOK )
  {
    mode_vswr = wext.mode ;
    config.flags |= wext.mask_out ;
  }
}

