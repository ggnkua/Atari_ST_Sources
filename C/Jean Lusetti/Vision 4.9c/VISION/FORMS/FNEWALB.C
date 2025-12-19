#include <string.h>
#include <stdio.h>
#include "..\tools\gwindows.h"

#include "..\tools\catalog.h"

#include "actions.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  char name[30] ;
  char path[PATH_MAX] ;

  char comment[80] ;
}
WEXTENSION_NALB ;

void OnInitDialogNewAlb(void *w)
{
  GEM_WINDOW      *wnd = (GEM_WINDOW*) w ;
  WEXTENSION_NALB *wext = wnd->DlgData->UserData ;
  OBJECT          *adr_newalbum = wnd->DlgData->BaseObject ;

  strcpy( wext->path, config.path_album ) ;
  write_text( adr_newalbum, NEWALBUM_FOLDER, wext->path ) ;
  write_text( adr_newalbum, NEWALBUM_NAME, "" ) ;
  write_text( adr_newalbum, NEWALBUM_REM1, "" ) ;
  write_text( adr_newalbum, NEWALBUM_REM2, "" ) ;
}

int OnObjectNotifyNewAlb(void *w, int obj)
{
  GEM_WINDOW      *wnd = (GEM_WINDOW*) w ;
  WEXTENSION_NALB *wext = wnd->DlgData->UserData ;
  OBJECT          *adr_newalbum = wnd->DlgData->BaseObject ;
  int             i, code = -1 ;
  char            rem[80] ;

  switch( obj )
  {
     case NEWALBUM_FOLDER : if ( file_name( wext->path, "", wext->path ) == 1 )
                            {
                              write_text( adr_newalbum, NEWALBUM_FOLDER, wext->path ) ;
                              GWObjcDraw( wnd, adr_newalbum, NEWALBUM_FOLDER ) ;
                            }
                            break ;
     case NEWALBUM_OK     : code = IDOK ;
                            break ;
     case NEWALBUM_CANCEL : code = IDCANCEL ;
                            break ;
  }

  if ( code == IDOK )
  {
    read_text(adr_newalbum, NEWALBUM_NAME, wext->name ) ;
    read_text(adr_newalbum, NEWALBUM_FOLDER, wext->path ) ;
    wext->comment[0] = 0 ;
    for ( i = NEWALBUM_REM1; i <= NEWALBUM_REM2; i++ )
    {
      read_text( adr_newalbum, i, rem ) ;
      strcat( wext->comment, rem ) ;
    }
  }

  return code ;
}

int FGetNewAlb(WEXTENSION_NALB *wext)
{
  DLGDATA dlg_data ;

  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId       = FORM_NEWALBUM ;
  strcpy( dlg_data.Title, vMsgTxtGetMsg(MSG_WFNAMES)  ) ;
  dlg_data.UserData     = wext ;
  dlg_data.OnInitDialog = OnInitDialogNewAlb ;
  dlg_data.OnObjectNotify = OnObjectNotifyNewAlb ;

  return GWCreateAndDoModal( &dlg_data, 0 ) ;
}

HCAT get_newalbum(char *name, int* status)
{
  WEXTENSION_NALB wext ;
  HCAT            hCat = NULL ;
  int             code ;

  code = FGetNewAlb( &wext ) ;
  if ( code == IDOK )
  {
    mouse_busy() ;
    hCat = catalog_new( wext.path, wext.name, status ) ;
    mouse_restore() ;
    if ( *status == 0 )
    {
      strcpy( name, wext.name ) ;
      catalog_setrem( hCat, wext.comment ) ;
    }
    return hCat ;
  }

  *status = -4 ;

  return hCat ;
}

