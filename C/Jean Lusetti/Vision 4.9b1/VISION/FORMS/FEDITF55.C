#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "..\tools\gwindows.h"

#include "..\tools\convol.h"

#include "defs.h"
#include "actions.h"
#include "ffilter.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  CONVOLUTION_FILTRE *in_filter ;
  CONVOLUTION_FILTRE filter ;

  char  data[25] ;
}
WEXTENSION_F55 ;

void OnInitDialogF55(void *w)
{
  GEM_WINDOW     *wnd = (GEM_WINDOW*) w ;
  WEXTENSION_F55 *wext = wnd->DlgData->UserData ;
  OBJECT         *adr_filter = wnd->DlgData->BaseObject ;
  int            bouton ;
  char           buf[PATH_MAX] ;

  if ( wext->in_filter == NULL )
  {
    wext->filter.w    = wext->filter.h = 3 ;
    wext->filter.data = wext->data ;
    write_text(adr_filter, FILTRE55_NAME, "") ;
    write_text(adr_filter, FILTRE55_DESCRIP, "") ;
  }
  else
  {
    char *pt ;

    memcpy(&wext->filter, wext->in_filter, sizeof(CONVOLUTION_FILTRE)) ;
    write_text(adr_filter, FILTRE55_NAME, wext->filter.name) ;
    write_text(adr_filter, FILTRE55_DESCRIP, wext->filter.description) ;
    pt = (char *) wext->filter.data ;
    for (bouton = FILTRE55_E1; bouton <= FILTRE55_ELAST; bouton++)
    {
      sprintf(buf, "%+.2d", *pt++) ;
      write_text(adr_filter, bouton, buf) ;
    }
  }
}

int OnObjectNotifyF55(void *w, int obj)
{
  GEM_WINDOW     *wnd = (GEM_WINDOW*) w ;
  WEXTENSION_F55 *wext = wnd->DlgData->UserData ;
  OBJECT          *adr_filter = wnd->DlgData->BaseObject ;
  int             bouton, code = -1 ;
  char            buf[PATH_MAX] ;

  switch( obj )
  {
     case FILTRE55_SAVE   : code = IDOK ;
                            break ;
     case FILTRE55_CANCEL : code = IDCANCEL ;
                            break ;
  }

  if ( code == IDOK )
  {
    for (bouton = FILTRE55_E1; bouton <= FILTRE55_ELAST; bouton++)
    {
      read_text(adr_filter, bouton, buf) ;
      wext->filter.data[bouton-FILTRE55_E1] = atoi(buf) ;
    }
    read_text(adr_filter, FILTRE55_NAME, wext->filter.name) ;
    read_text(adr_filter, FILTRE55_DESCRIP, wext->filter.description) ;
  }

  return code ;
}

int FGetFilter55(WEXTENSION_F55 *wext)
{
  GEM_WINDOW* dlg ;
  DLGDATA    dlg_data ;
  int        code ;

  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId       = FORM_FILTRE55 ;
  strcpy( dlg_data.Title, MsgTxtGetMsg(hMsg, MSG_WFNAMES)  ) ;
  dlg_data.UserData     = wext ;
  dlg_data.OnInitDialog = OnInitDialogF55 ;
  dlg_data.OnObjectNotify = OnObjectNotifyF55 ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, 0 ) ;

  if ( code == IDOK )
  {

  }

  return code ;
}

void edit_5x5filter(CONVOLUTION_FILTRE *in_filter)
{
  WEXTENSION_F55 wext ;
  char           nom[PATH_MAX] ;
  char           buf[PATH_MAX] ;
  char           path_filter[PATH_MAX] ;

  wext.in_filter = in_filter ;
  if ( FGetFilter55( &wext ) != IDOK ) return ;

  GetFilterPathForLanguage( path_filter ) ;
  sprintf( buf, "%s\\*.VCF", path_filter ) ;
  if ( file_name( buf, "", nom ) )
  {
    if ( convolution_savefilter( nom, &wext.filter ) == -1 ) form_stop(  MsgTxtGetMsg(hMsg, MSG_WRITEERROR)  ) ;
  }
}

