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


static int get_wh(OBJECT* adr_tab, int obj)
{
  char buf[10] ;

  read_text( adr_tab, obj, buf ) ;
  return atoi( buf ) ;
}

static int OnObjectNotifyTableau(void* w, int obj)
{
  GEM_WINDOW*     wnd = (GEM_WINDOW*) w ;
  WEXTENSION_TAB* wext = wnd->DlgData->UserData ;
  OBJECT*         adr_tab = wnd->DlgData->BaseObject ;
  int             code = -1 ;

  switch( obj )
  {
     case TAB_OK : code = IDOK ;
                   break ;
  }

  if ( code == IDOK )
  {
    wext->w = get_wh( adr_tab, TAB_H ) ; /* TAB_H: columns */
    wext->h = get_wh( adr_tab, TAB_W ) ; /* TAB_W: lines   */
  }

  return code ;
}

int get_tableau(int* w, int* h)
{
  WEXTENSION_TAB wext ;
  DLGDATA        dlg_data ;
  int            code ;

  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId         = FORM_TABLEAU ;
  strcpy( dlg_data.Title, vMsgTxtGetMsg(MSG_WFNAMES)  ) ;
  dlg_data.UserData       = &wext ;
  dlg_data.OnObjectNotify = OnObjectNotifyTableau ;

  code = GWCreateAndDoModal( &dlg_data, TAB_W ) ;
  if ( code == IDOK )
  {
    *w = wext.w ;
    *h = wext.h ;
  }

  return code ;
}
