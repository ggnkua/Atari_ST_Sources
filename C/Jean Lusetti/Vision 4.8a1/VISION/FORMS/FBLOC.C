#include <string.h>
#include "..\tools\gwindows.h"

#include "actions.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  int bloc_type ;
}
WEXTENSION_BLOC ;

void OnInitDialogBloc(void* w)
{
  GEM_WINDOW* wnd = (GEM_WINDOW* ) w ;
  OBJECT*     adr_bloc = wnd->DlgData->BaseObject ;

  if ( vclip.form == BLOC_LASSO )
  {
    select(adr_bloc, BLOC_LIBRE) ;
    deselect(adr_bloc, BLOC_SIMPLE) ;
  }
  else
  {
    deselect(adr_bloc, BLOC_LIBRE) ;
    select(adr_bloc, BLOC_SIMPLE) ;
  }
}

int OnObjectNotifyBloc(void* w, int obj)
{
  GEM_WINDOW*      wnd = (GEM_WINDOW* ) w ;
  OBJECT*          adr_bloc = wnd->DlgData->BaseObject ;
  WEXTENSION_BLOC* wext = wnd->DlgData->UserData ;
  int code = -1 ;

  switch( obj )
  {
      case BLOC_SIMPLE  :
      case BLOC_TSIMPLE : select(adr_bloc, BLOC_SIMPLE) ;
                          deselect(adr_bloc, BLOC_LIBRE) ;
                          xobjc_draw( wnd->window_handle, adr_bloc, BLOC_SIMPLE ) ;
                          xobjc_draw( wnd->window_handle, adr_bloc, BLOC_LIBRE ) ;
                          break ;
      case BLOC_LIBRE   :
      case BLOC_TLIBRE  : deselect(adr_bloc, BLOC_SIMPLE) ;
                          select(adr_bloc, BLOC_LIBRE) ;
                          xobjc_draw( wnd->window_handle, adr_bloc, BLOC_SIMPLE ) ;
                          xobjc_draw( wnd->window_handle, adr_bloc, BLOC_LIBRE ) ;
                          break ;
     case BLOC_OK       : code = IDOK ;
                          break ;
     case BLOC_CANCEL   : code = IDCANCEL ;
                          break ;
  }

  if ( code == IDOK )
  {
    wext->bloc_type = selected(adr_bloc, BLOC_SIMPLE) ? BLOC_RECTANGLE : BLOC_LASSO ;
  }

  return( code ) ;
}

void traite_pbloc(void)
{
  GEM_WINDOW      *dlg ;
  WEXTENSION_BLOC wext ;
  DLGDATA         dlg_data ;
  int             code ;

  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId       = FORM_BLOC ;
  strcpy( dlg_data.Title, MsgTxtGetMsg(hMsg, MSG_WFNAMES)  ) ;
  dlg_data.UserData       = &wext ;
  dlg_data.OnInitDialog   = OnInitDialogBloc ;
  dlg_data.OnObjectNotify = OnObjectNotifyBloc ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, 0 ) ;

  if ( code == IDOK )
  {
    vclip.form = wext.bloc_type ;
  }
}

