#include <string.h>
#include <stdlib.h>
#include "..\tools\gwindows.h"

#include "actions.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif


static void select_undo_type(GEM_WINDOW* wnd, int selected_one)
{
  OBJECT *adr_undo = wnd->DlgData->BaseObject ;

  deselect( adr_undo, UNDO_NEVER ) ;
  deselect( adr_undo, UNDO_KO ) ;
  deselect( adr_undo, UNDO_SMART ) ;
  deselect( adr_undo, UNDO_ALWAYS ) ;
  select( adr_undo, selected_one ) ;

  xobjc_draw( wnd->window_handle, adr_undo, UNDO_ALWAYS ) ;
  xobjc_draw( wnd->window_handle, adr_undo, UNDO_NEVER ) ;
  xobjc_draw( wnd->window_handle, adr_undo, UNDO_KO ) ;
  xobjc_draw( wnd->window_handle, adr_undo, UNDO_SMART ) ;
}


static void OnInitDialogUndo(void *w)
{
  GEM_WINDOW* wnd = (GEM_WINDOW* ) w ;
  OBJECT     *adr_undo = wnd->DlgData->BaseObject ;
  char       buffer[20] ;

  sprintf( buffer, "%d", config.nb_undo ) ;
  write_text( adr_undo, UNDO_TNBNEVER, buffer ) ;
  sprintf( buffer, "%d", config.ko_undo ) ;
  write_text( adr_undo, UNDO_TNBKO, buffer ) ;

  select_undo_type( wnd, config.type_undo ) ;
}

static int OnObjectNotifyUndo(void *w, int obj)
{
  GEM_WINDOW* wnd = (GEM_WINDOW* ) w ;
  OBJECT     *adr_undo = wnd->DlgData->BaseObject ;
  int        code = -1 ;
  char       buffer[20] ;

  switch( obj )
  {
    case UNDO_NEVER   : 
    case UNDO_TNEVER  : select_undo_type( wnd, UNDO_NEVER ) ;
                        break ;
    case UNDO_KO      : 
    case UNDO_TKO     : select_undo_type( wnd, UNDO_KO ) ;
                        break ;
    case UNDO_SMART   : 
    case UNDO_TSMART  : select_undo_type( wnd, UNDO_SMART ) ;
                        break ;
    case UNDO_ALWAYS  : 
    case UNDO_TALWAYS : select_undo_type( wnd, UNDO_ALWAYS ) ;
                        break ;
     case UNDO_OK     : code = IDOK ;
                        break ;
     case UNDO_CANCEL : code = IDCANCEL ;
                        break ;
  }

  if ( code == IDOK )
  {
    read_text( adr_undo, UNDO_TNBKO, buffer ) ;
    config.ko_undo = atoi( buffer ) ;
    read_text( adr_undo, UNDO_TNBNEVER, buffer ) ;
    config.nb_undo = atoi( buffer ) ;
    if ( selected( adr_undo, UNDO_NEVER ) ) config.type_undo = TUNDO_MEMORY ;
    else
    if ( selected( adr_undo, UNDO_KO ) ) config.type_undo = TUNDO_KO ;
    else
    if ( selected( adr_undo, UNDO_SMART ) ) config.type_undo = TUNDO_SMART ;
    else
    if ( selected( adr_undo, UNDO_ALWAYS ) ) config.type_undo = TUNDO_DISK ;
    if ( config.type_undo != TUNDO_MEMORY ) config.nb_undo = MAX_UNDO ;
  }

  return( code ) ;
}

void pref_undo(void)
{
  GEM_WINDOW* dlg ;
  DLGDATA    dlg_data ;
  int        code ;

  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId       = FORM_UNDO ;
  strcpy( dlg_data.Title, MsgTxtGetMsg(hMsg, MSG_WFNAMES)  ) ;
  dlg_data.UserData     = NULL ;
  dlg_data.OnInitDialog = OnInitDialogUndo ;
  dlg_data.OnObjectNotify = OnObjectNotifyUndo ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, 0 ) ;

  if ( code == IDOK )
  {

  }
}
