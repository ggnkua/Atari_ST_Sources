#include <string.h>
#include <stdlib.h>
#include "..\tools\gwindows.h"

#include "defs.h"
#include "fdecoup.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  DECOUP decoup ;
}
WEXTENSION_DECOUP ;


void OnInitDialogDecoup(void *w)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_DECOUP *wext = wnd->DlgData->UserData ;
  OBJECT            *adr_rsc = wnd->DlgData->BaseObject ;
  char              buf[50] ;

  wext->decoup.valid = 1 ;

  if ( wext->decoup.valid ) select( adr_rsc, DECOUP_VALID ) ;
  else                      deselect( adr_rsc, DECOUP_VALID ) ;

  sprintf( buf, "%02d", wext->decoup.nb_colonnes ) ;
  write_text( adr_rsc, DECOUP_X, buf ) ;
  sprintf( buf, "%02d", wext->decoup.nb_lignes ) ;
  write_text( adr_rsc, DECOUP_Y, buf ) ;
  sprintf( buf, "%02d", wext->decoup.num ) ;
  write_text( adr_rsc, DECOUP_NUM, buf ) ;
}

int OnObjectNotifyDecoup(void *w, int obj)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_DECOUP *wext = wnd->DlgData->UserData ;
  OBJECT            *adr_rsc = wnd->DlgData->BaseObject ;
  int               code = -1 ;
  char              buf[50] ;

  switch( obj )
  {
    case DECOUP_TVALID  : inv_select( adr_rsc, DECOUP_VALID ) ;
                          break ;
     case DECOUP_OK     : code = IDOK ;
                          break ;
     case DECOUP_CANCEL : code = IDCANCEL ;
                          break ;
  }

  if ( code == IDOK )
  {
    wext->decoup.valid = selected( adr_rsc, DECOUP_VALID ) ;
    read_text( adr_rsc, DECOUP_X, buf ) ;
    wext->decoup.nb_colonnes = atoi( buf ) ;
    read_text( adr_rsc, DECOUP_Y, buf ) ;
    wext->decoup.nb_lignes = atoi( buf ) ;
    read_text( adr_rsc, DECOUP_NUM, buf ) ;
    wext->decoup.num = atoi( buf ) ;
  }

  return( code ) ;
}

int get_decoup(DECOUP *dcp)
{
  GEM_WINDOW        *dlg ;
  WEXTENSION_DECOUP wext ;
  DLGDATA           dlg_data ;
  int               code ;

  memcpy( &wext.decoup, dcp, sizeof(DECOUP) ) ;

  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
  dlg_data.RsrcId       = FORM_DECOUP ;
  strcpy( dlg_data.Title, msg[MSG_WFNAMES] ) ;
  dlg_data.UserData     = &wext ;
  dlg_data.OnInitDialog = OnInitDialogDecoup ;
  dlg_data.OnObjectNotify = OnObjectNotifyDecoup ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, 0 ) ;

  if ( code == IDOK )
  {
    memcpy( dcp, &wext.decoup, sizeof(DECOUP) ) ;
  }

  return( code ) ;
}

