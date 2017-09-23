#include <string.h>
#include "..\tools\gwindows.h"

#include "actions.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif


void OnInitDialogLog(void *w)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  OBJECT     *adr = wnd->DlgData->BaseObject ;

  write_text( adr, LOG_FILE, config.log_file ) ;

  if ( config.log_flags & LF_FLGAPPEND ) deselect( adr, LOG_ADD ) ;
  else                                   select( adr, LOG_ADD ) ;
}

int OnObjectNotifyLog(void *w, int obj)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  OBJECT     *adr = wnd->DlgData->BaseObject ;
  int        code = -1 ;
  char       buf[PATH_MAX] ;

  switch( obj )
  {
    case LOG_TADD    : inv_select( adr, LOG_ADD ) ;
                       break ;

    case LOG_FILE    : buf[0] = 0 ;
                       if ( file_name( config.log_file, "", buf ) == 1 ) write_text( adr, LOG_FILE, buf ) ;
                       deselect( adr, obj ) ;
                       break ;
     case LOG_OK     : code = IDOK ;
                       break ;
     case LOG_CANCEL : code = IDCANCEL ;
                       break ;
  }

  if ( code == IDOK )
  {
    if ( selected( adr, LOG_ADD ) ) config.log_flags &= ~LF_FLGAPPEND ;
    else                            config.log_flags |= LF_FLGAPPEND ;
    read_text( adr, LOG_FILE, config.log_file ) ;
  }

  return( code ) ;
}

void pref_logfile(void)
{
  GEM_WINDOW *dlg ;
  DLGDATA    dlg_data ;
  int        code ;

  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
  dlg_data.RsrcId       = FORM_LOG ;
  strcpy( dlg_data.Title, msg[MSG_WFNAMES] ) ;
  dlg_data.UserData     = NULL;
  dlg_data.OnInitDialog = OnInitDialogLog ;
  dlg_data.OnObjectNotify = OnObjectNotifyLog ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, -1 ) ;

  if ( code == IDOK )
  {

  }
}
