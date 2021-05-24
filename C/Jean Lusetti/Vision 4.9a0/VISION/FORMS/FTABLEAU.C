#include <string.h>
#include <stdlib.h>
#include "..\tools\gwindows.h"

#include "defs.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  int w, h ;
}
WEXTENSION_TAB ;


int OnObjectNotifyTableau(void *w, int obj)
{
  GEM_WINDOW     *wnd = (GEM_WINDOW*) w ;
  WEXTENSION_TAB *wext = wnd->DlgData->UserData ;
  OBJECT         *adr_tab = wnd->DlgData->BaseObject ;
  int            code = -1 ;
  char           buf[10] ;

  switch( obj )
  {
     case TAB_OK : code = IDOK ;
                   break ;
  }

  if ( code == IDOK )
  {
    read_text(adr_tab, TAB_W, buf) ;
    wext->w = atoi(buf) ;
    read_text(adr_tab, TAB_H, buf) ;
    wext->h = atoi(buf) ;
  }

  return code ;
}

int get_tableau(int *w, int *h)
{
  GEM_WINDOW     *dlg ;
  WEXTENSION_TAB wext ;
  DLGDATA        dlg_data ;
  int            code ;

  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId       = FORM_TABLEAU ;
  strcpy( dlg_data.Title, MsgTxtGetMsg(hMsg, MSG_WFNAMES)  ) ;
  dlg_data.UserData     = &wext ;
  dlg_data.OnObjectNotify = OnObjectNotifyTableau ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, TAB_W ) ;

  if ( code == IDOK )
  {
    *w = wext.w ;
    *h = wext.h ;
  }

  return code ;
}
