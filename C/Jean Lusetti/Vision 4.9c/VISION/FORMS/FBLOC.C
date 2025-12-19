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

static void OnInitDialogBloc(void* w)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
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

static int OnObjectNotifyBloc(void* w, int obj)
{
  GEM_WINDOW*      wnd = (GEM_WINDOW*) w ;
  OBJECT*          adr_bloc = wnd->DlgData->BaseObject ;
  WEXTENSION_BLOC* wext = wnd->DlgData->UserData ;
  int              code = -1 ;

  switch( obj )
  {
      case BLOC_SIMPLE  :
      case BLOC_TSIMPLE : select( adr_bloc, BLOC_SIMPLE ) ;
                          deselect( adr_bloc, BLOC_LIBRE ) ;
                          GWObjcDraw( wnd, adr_bloc, BLOC_SIMPLE ) ;
                          GWObjcDraw( wnd, adr_bloc, BLOC_LIBRE ) ;
                          break ;
      case BLOC_LIBRE   :
      case BLOC_TLIBRE  : deselect( adr_bloc, BLOC_SIMPLE ) ;
                          select( adr_bloc, BLOC_LIBRE ) ;
                          GWObjcDraw( wnd, adr_bloc, BLOC_SIMPLE ) ;
                          GWObjcDraw( wnd, adr_bloc, BLOC_LIBRE ) ;
                          break ;
     case BLOC_OK       : code = IDOK ;
                          break ;
     case BLOC_CANCEL   : code = IDCANCEL ;
                          break ;
  }

  if ( code == IDOK )
    wext->bloc_type = selected(adr_bloc, BLOC_SIMPLE) ? BLOC_RECTANGLE : BLOC_LASSO ;

  return code ;
}

void traite_pbloc(void)
{
  WEXTENSION_BLOC wext ;
  DLGDATA         dlg_data ;

  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId       = FORM_BLOC ;
  strcpy( dlg_data.Title, vMsgTxtGetMsg(MSG_WFNAMES)  ) ;
  dlg_data.UserData       = &wext ;
  dlg_data.OnInitDialog   = OnInitDialogBloc ;
  dlg_data.OnObjectNotify = OnObjectNotifyBloc ;

  if ( GWCreateAndDoModal(&dlg_data, 0) == IDOK) vclip.form = wext.bloc_type ;
}

