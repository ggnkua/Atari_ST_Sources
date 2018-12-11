#include <string.h>
#include "..\tools\gwindows.h"

#include "defs.h"
#include "finputte.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

#define NB_TEXTS   4

typedef struct
{
  char text[NB_TEXTS][100] ;
}
WEXTENSION_ITEXT ;


void OnInitDialogInputText(void *w)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  OBJECT     *adr_text = wnd->DlgData->BaseObject ;

  write_text( adr_text, THE_TEXT1, "" ) ;
  write_text( adr_text, THE_TEXT2, "" ) ;
  write_text( adr_text, THE_TEXT3, "" ) ;
  write_text( adr_text, THE_TEXT4, "" ) ;
}

int OnObjectNotifyInputText(void *w, int obj)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_ITEXT *wext = wnd->DlgData->UserData ;
  OBJECT           *adr_text = wnd->DlgData->BaseObject ;
  int              code = -1 ;
  int              i ;

  switch( obj )
  {
    case INPUTTEXT_OK :      code = IDOK ;
                             break ;
    case INPUTTEXT_CANCEL :  code = IDCANCEL ;
                             break ;
  }

  if ( code == IDOK )
  {
    for ( i = 0; i < NB_TEXTS; i++ ) read_text( adr_text, THE_TEXT1+i, wext->text[i]) ;
  }

  return( code ) ;
}

int input_text(char texts[NB_TEXTS][100])
{
  GEM_WINDOW       *dlg ;
  WEXTENSION_ITEXT wext ;
  DLGDATA          dlg_data ;
  int              code ;
  int              i ;

  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
  dlg_data.RsrcId       = FORM_INPUTTEXT ;
  strcpy( dlg_data.Title, MsgTxtGetMsg(hMsg, MSG_WFNAMES)  ) ;
  dlg_data.UserData     = &wext ;
  dlg_data.OnInitDialog  = OnInitDialogInputText ;
  dlg_data.OnObjectNotify = OnObjectNotifyInputText ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, THE_TEXT1 ) ;

  if ( code == IDOK )
    for ( i = 0; i < NB_TEXTS; i++ ) strcpy( texts[i], wext.text[i] ) ;

  return( code ) ;
}

