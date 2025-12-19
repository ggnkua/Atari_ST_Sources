#include <string.h>
#include <stdlib.h>
#include "..\tools\gwindows.h"


#include "actions.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif


static void OnInitDialogAerosol(void* w)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
  OBJECT*     adr_aerosol = wnd->DlgData->BaseObject ;
  char        buf[20] ;

  sprintf(buf, "%d", densite) ;
  write_text(adr_aerosol, AEROSOL_DENSITE, buf) ;
  sprintf(buf, "%d", puissance) ;
  write_text(adr_aerosol, AEROSOL_PUISS, buf) ;
}

int OnObjectNotifyAerosol(void* w, int obj)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
  OBJECT*     adr_aerosol = wnd->DlgData->BaseObject ;
  int         code = -1 ;
  char        buf[20] ;

  switch( obj )
  {
     case AEROSOL_OK     : code = IDOK ;
                           break ;
     case AEROSOL_CANCEL : code = IDCANCEL ;
                           break ;
  }

  if ( code == IDOK )
  {
    read_text(adr_aerosol, AEROSOL_DENSITE, buf) ;
    densite = atoi(buf) ;
    read_text(adr_aerosol, AEROSOL_PUISS, buf) ;
    puissance = atoi(buf) ;
  }

  return code ;
}

void traite_paerosol(void)
{
  DLGDATA dlg_data ;

  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId         = FORM_AEROSOL ;
  strcpy( dlg_data.Title, vMsgTxtGetMsg(MSG_WFNAMES)  ) ;
  dlg_data.UserData       = NULL ;
  dlg_data.OnInitDialog   = OnInitDialogAerosol ;
  dlg_data.OnObjectNotify = OnObjectNotifyAerosol ;

  (void)GWCreateAndDoModal( &dlg_data, AEROSOL_DENSITE ) ;
}
