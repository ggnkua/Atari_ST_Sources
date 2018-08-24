#include <string.h>
#include "..\tools\gwindows.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{

}
WEXTENSION_ ;

void OnInitDialog(void *w)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_ *wext = wnd->DlgData->UserData ;
  OBJECT              * = wnd->DlgData->BaseObject ;

}

int OnObjectNotify(void *w, int obj)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_ *wext = wnd->DlgData->UserData ;
  OBJECT              * = wnd->DlgData->BaseObject ;
  int code = -1 ;

  switch( obj )
  {

     case _OK : code = IDOK ;
                      break ;
     case _CANCEL : code = IDCANCEL ;
                      break ;
  }

  if ( code == IDOK )
  {

  }

  return( code ) ;
}

void (void)
{
  GEM_WINDOW          *dlg ;
  WEXTENSION_ wext ;
  DLGDATA             dlg_data ;
  int    code ;

  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
  dlg_data.RsrcId       = FORM_ ;
  strcpy( dlg_data.Title, MsgTxtGetMsg(hMsg, MSG_WFNAMES)  ) ;
  dlg_data.UserData     = &wext ;
  dlg_data.OnInitDialog = OnInitDialog ;
  dlg_data.OnObjectNotify = OnObjectNotify ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, 0 ) ;

  if ( code == IDOK )
  {

  }
}

