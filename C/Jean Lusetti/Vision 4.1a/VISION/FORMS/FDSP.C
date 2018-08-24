#include <string.h>
#include "..\tools\gwindows.h"

#include "actions.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  DSP_INFO confdsp ;
}
WEXTENSION_DSP ;


void OnInitDialogDSP(void *w)
{
  GEM_WINDOW     *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_DSP *wext = wnd->DlgData->UserData ;
  OBJECT         *adr_prefdsp = wnd->DlgData->BaseObject ;

  memcpy( &wext->confdsp, &DspInfo, sizeof(DSP_INFO) ) ;
  if ( DspInfo.use ) select( adr_prefdsp, PDSP_USE ) ;
  else               deselect( adr_prefdsp, PDSP_USE ) ;
  deselect( adr_prefdsp, PDSPLOCK_WARN ) ;
  deselect( adr_prefdsp, PDSPLOCK_FORCE ) ;
  deselect( adr_prefdsp, PDSPLOCK_IGNORE ) ;
  deselect( adr_prefdsp, PDSPLOCK_CANCEL ) ;
  switch( DspInfo.WhatToDoIfLocked )
  {
    case DSPLOCK_WARN   : select( adr_prefdsp, PDSPLOCK_WARN ) ;
                          break ;
    case DSPLOCK_FORCE  : select( adr_prefdsp, PDSPLOCK_FORCE ) ;
                          break ;
    case DSPLOCK_IGNORE : select( adr_prefdsp, PDSPLOCK_IGNORE ) ;
                          break ;
    case DSPLOCK_CANCEL : select( adr_prefdsp, PDSPLOCK_CANCEL ) ;
                          break ;
  }
}

int OnObjectNotifyDSP(void *w, int obj)
{
  GEM_WINDOW     *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_DSP *wext = wnd->DlgData->UserData ;
  OBJECT         *adr_prefdsp = wnd->DlgData->BaseObject ;
  int            code = -1 ;

  switch( obj )
  {
    case PDSP_USE         :
    case PDSP_TUSE        : inv_select(adr_prefdsp, PDSP_USE) ;
                            break ;
    case PDSPLOCK_WARN    : inv_select(adr_prefdsp, obj) ;
    case PDSPLOCK_TWARN   : if (!selected(adr_prefdsp, PDSPLOCK_WARN))
                            {
                              select(adr_prefdsp, PDSPLOCK_WARN) ;
                              deselect(adr_prefdsp, PDSPLOCK_IGNORE) ;
                              deselect(adr_prefdsp, PDSPLOCK_FORCE) ;
                              deselect(adr_prefdsp, PDSPLOCK_CANCEL) ;
                            }
                            break ;
    case PDSPLOCK_IGNORE  : inv_select(adr_prefdsp, obj) ;
    case PDSPLOCK_TIGNORE : if (!selected(adr_prefdsp, PDSPLOCK_IGNORE))
                            {
                              select(adr_prefdsp, PDSPLOCK_IGNORE) ;
                              deselect(adr_prefdsp, PDSPLOCK_WARN) ;
                              deselect(adr_prefdsp, PDSPLOCK_FORCE) ;
                              deselect(adr_prefdsp, PDSPLOCK_CANCEL) ;
                            }
                            break ;
    case PDSPLOCK_FORCE   : inv_select(adr_prefdsp, obj) ;
    case PDSPLOCK_TFORCE  : if (!selected(adr_prefdsp, PDSPLOCK_FORCE))
                            {
                              select(adr_prefdsp, PDSPLOCK_FORCE) ;
                              deselect(adr_prefdsp, PDSPLOCK_WARN) ;
                              deselect(adr_prefdsp, PDSPLOCK_IGNORE) ;
                              deselect(adr_prefdsp, PDSPLOCK_CANCEL) ;
                            }
                            break ;
    case PDSPLOCK_CANCEL  : inv_select(adr_prefdsp, obj) ;
    case PDSPLOCK_TCANCEL : if (!selected(adr_prefdsp, PDSPLOCK_CANCEL))
                            {
                              select(adr_prefdsp, PDSPLOCK_CANCEL) ;
                              deselect(adr_prefdsp, PDSPLOCK_WARN) ;
                              deselect(adr_prefdsp, PDSPLOCK_IGNORE) ;
                              deselect(adr_prefdsp, PDSPLOCK_FORCE) ;
                            }
                            break ;
     case PDSP_OK         : code = IDOK ;
                            break ;
     case PDSP_CANCEL     : code = IDCANCEL ;
                            break ;
  }
  xobjc_draw( wnd->window_handle, adr_prefdsp, PDSPLOCK_WARN ) ;
  xobjc_draw( wnd->window_handle, adr_prefdsp, PDSPLOCK_IGNORE ) ;
  xobjc_draw( wnd->window_handle, adr_prefdsp, PDSPLOCK_FORCE ) ;
  xobjc_draw( wnd->window_handle, adr_prefdsp, PDSPLOCK_CANCEL ) ;

  if ( code == IDOK )
  {
    if ( selected( adr_prefdsp, PDSP_USE ) ) wext->confdsp.use = 1 ;
    else                                     wext->confdsp.use = 0 ;
    if (selected(adr_prefdsp, PDSPLOCK_WARN))   wext->confdsp.WhatToDoIfLocked = DSPLOCK_WARN ;
    if (selected(adr_prefdsp, PDSPLOCK_FORCE))  wext->confdsp.WhatToDoIfLocked = DSPLOCK_FORCE ;
    if (selected(adr_prefdsp, PDSPLOCK_IGNORE)) wext->confdsp.WhatToDoIfLocked = DSPLOCK_IGNORE;
    if (selected(adr_prefdsp, PDSPLOCK_CANCEL)) wext->confdsp.WhatToDoIfLocked = DSPLOCK_CANCEL ;
  }

  return( code ) ;
}

void pref_dsp(void)
{
  GEM_WINDOW     *dlg ;
  WEXTENSION_DSP wext ;
  DLGDATA        dlg_data ;
  int            code ;

  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
  dlg_data.RsrcId       = FORM_DSP ;
  strcpy( dlg_data.Title, MsgTxtGetMsg(hMsg, MSG_WFNAMES)  ) ;
  dlg_data.UserData     = &wext ;
  dlg_data.OnInitDialog = OnInitDialogDSP ;
  dlg_data.OnObjectNotify = OnObjectNotifyDSP ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, 0 ) ;

  if ( code == IDOK )
  {
    config.dspuse = DspInfo.use                     = wext.confdsp.use ;
    config.dsphandlelock = DspInfo.WhatToDoIfLocked = wext.confdsp.WhatToDoIfLocked ;
  }
}

