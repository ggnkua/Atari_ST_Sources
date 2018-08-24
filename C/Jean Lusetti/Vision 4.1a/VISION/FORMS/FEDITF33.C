#include <string.h>
#include <stdlib.h>
#include <stdio.h>
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

  char  data[9] ;
}
WEXTENSION_F33 ;

void OnInitDialogF33(void *w)
{
  GEM_WINDOW     *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_F33 *wext = wnd->DlgData->UserData ;
  OBJECT         *adr_filter = wnd->DlgData->BaseObject ;
  int            bouton ;
  char           buf[PATH_MAX] ;

  if ( wext->in_filter == NULL )
  {
    wext->filter.w    = wext->filter.h = 3 ;
    wext->filter.data = wext->data ;
    write_text(adr_filter, FILTRE33_NAME, "") ;
    write_text(adr_filter, FILTRE33_DESCRIP, "") ;
  }
  else
  {
    char *pt ;

    memcpy(&wext->filter, wext->in_filter, sizeof(CONVOLUTION_FILTRE)) ;
    write_text(adr_filter, FILTRE33_NAME, wext->filter.name) ;
    write_text(adr_filter, FILTRE33_DESCRIP, wext->filter.description) ;
    pt = (char *) wext->filter.data ;
    for (bouton = FILTRE33_E1; bouton <= FILTRE33_ELAST; bouton++)
    {
      sprintf(buf, "%+.2d", *pt++) ;
      write_text(adr_filter, bouton, buf) ;
    }
  }
}

int OnObjectNotifyF33(void *w, int obj)
{
  GEM_WINDOW     *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_F33 *wext = wnd->DlgData->UserData ;
  OBJECT          *adr_filter = wnd->DlgData->BaseObject ;
  int             bouton, code = -1 ;
  char            buf[PATH_MAX] ;

  switch( obj )
  {
     case FILTRE33_SAVE   : code = IDOK ;
                            break ;
     case FILTRE33_CANCEL : code = IDCANCEL ;
                            break ;
  }

  if ( code == IDOK )
  {
    for (bouton = FILTRE33_E1; bouton <= FILTRE33_ELAST; bouton++)
    {
      read_text(adr_filter, bouton, buf) ;
      wext->filter.data[bouton-FILTRE33_E1] = atoi(buf) ;
    }
    read_text(adr_filter, FILTRE33_NAME, wext->filter.name) ;
    read_text(adr_filter, FILTRE33_DESCRIP, wext->filter.description) ;
  }

  return( code ) ;
}

int FGetFilter33(WEXTENSION_F33 *wext)
{
  GEM_WINDOW          *dlg ;
  DLGDATA             dlg_data ;
  int    code ;

  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
  dlg_data.RsrcId       = FORM_FILTRE33 ;
  strcpy( dlg_data.Title, MsgTxtGetMsg(hMsg, MSG_WFNAMES)  ) ;
  dlg_data.UserData     = wext ;
  dlg_data.OnInitDialog = OnInitDialogF33 ;
  dlg_data.OnObjectNotify = OnObjectNotifyF33 ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, 0 ) ;

  if ( code == IDOK )
  {

  }

  return( code ) ;
}

void edit_3x3filter(CONVOLUTION_FILTRE *in_filter)
{
  WEXTENSION_F33 wext ;
  char           nom[PATH_MAX] ;
  char           buf[PATH_MAX] ;
  char           path_filter[PATH_MAX] ;

  wext.in_filter = in_filter ;
  if ( FGetFilter33( &wext ) != IDOK ) return ;

  GetFilterPathForLanguage( path_filter ) ;
  sprintf( buf, "%s\\*.VCF", path_filter ) ;
  if ( file_name( buf, "", nom ) )
  {
    if ( convolution_savefilter( nom, &wext.filter ) == -1 ) form_stop( 1, MsgTxtGetMsg(hMsg, MSG_WRITEERROR)  ) ;
  }
}

