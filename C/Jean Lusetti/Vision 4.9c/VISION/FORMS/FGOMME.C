#include <string.h>
#include "..\tools\gwindows.h"

#include "actions.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif


static void OnInitDialogGomme(void* w)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
  OBJECT*     adr_pgomme = wnd->DlgData->BaseObject ;
  int         obj ;
  
  for ( obj = GOMME_1; obj <= GOMME_8; obj++ ) deselect( adr_pgomme, obj ) ;
  select( adr_pgomme, GOMME_1 + config.sgomme ) ;
}

static int OnObjectNotifyGomme(void* w, int obj)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
  OBJECT           *adr_pgomme = wnd->DlgData->BaseObject ;
  int              code = -1 ;
  int              sgomme ;

  switch( obj )
  {
     case GOMME_OK     : code = IDOK ;
                         break ;
     case GOMME_CANCEL : code = IDCANCEL ;
                         break ;
  }

  if ( code == IDOK )
  {
    for ( sgomme = GOMME_1; sgomme <= GOMME_8; sgomme++ )
      if ( selected( adr_pgomme, sgomme ) ) break ;
    config.sgomme = sgomme - GOMME_1 ;
  }

  return code ;
}

void traite_pgomme(void)
{
  DLGDATA dlg_data ;

  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId         = GOMMES ;
  strcpy( dlg_data.Title, vMsgTxtGetMsg(MSG_WFNAMES)  ) ;
  dlg_data.UserData       = NULL ;
  dlg_data.OnInitDialog   = OnInitDialogGomme ;
  dlg_data.OnObjectNotify = OnObjectNotifyGomme ;

  (void)GWCreateAndDoModal( &dlg_data, 0 ) ;
}
