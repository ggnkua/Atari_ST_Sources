#include <string.h>
#include <stdlib.h>
#include "..\tools\gwindows.h"

#include "defs.h"
#include "ffind.h"

static void OnInitDialog(void* w)
{
  GEM_WINDOW*      wnd = (GEM_WINDOW*) w ;
  OBJECT*          adr_find = wnd->DlgData->BaseObject ;
  FINDTEXT_PARAMS* fparams = wnd->DlgData->UserData ;

  write_text( adr_find, FF_STRING, fparams->string ) ;
  if ( fparams->case_insensitive ) select( adr_find, FF_CASE ) ;
  if ( fparams->wrap )             select( adr_find, FF_WRAP ) ;
  if ( fparams->reverse )          select( adr_find, FF_BACK ) ;
}

static int OnObjectNotify(void* w, int obj)
{
  GEM_WINDOW*      wnd = (GEM_WINDOW*) w ;
  OBJECT*          adr_find = wnd->DlgData->BaseObject ;
  FINDTEXT_PARAMS* fparams = wnd->DlgData->UserData ;
  int              code = -1 ;

  switch( obj )
  {
    case FF_CASE:
    case FF_TCASE:  inv_select( adr_find, FF_CASE ) ;
                    break ;
    case FF_WRAP:
    case FF_TWRAP:  inv_select( adr_find, FF_WRAP ) ;
                    break ;
    case FF_BACK:
    case FF_TBACK:  inv_select( adr_find, FF_BACK ) ;
                    break ;
    case FF_OK:     read_text( adr_find, FF_STRING, fparams->string ) ;
                    fparams->case_insensitive = selected( adr_find, FF_CASE ) ;
                    fparams->wrap             = selected( adr_find, FF_WRAP ) ;
                    fparams->reverse          = selected( adr_find, FF_BACK ) ;
                    code = IDOK ;
                    break ;
    case FF_CANCEL: code = IDCANCEL ;
                    break ;
  }

  return code ;
}

short form_find(FINDTEXT_PARAMS* fparams)
{
  DLGDATA dlg_data ;

  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId         = FORM_FIND ;
  dlg_data.OnInitDialog   = OnInitDialog ;
  dlg_data.UserData       = fparams ;
  dlg_data.OnObjectNotify = OnObjectNotify ;

  return ( GWDoModal( GWCreateDialog( &dlg_data ), FF_STRING ) == IDOK ) ;
}
