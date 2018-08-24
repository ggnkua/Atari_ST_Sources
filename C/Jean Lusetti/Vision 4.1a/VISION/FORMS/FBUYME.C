#include <string.h>
#include <stdio.h>
#include "..\tools\gwindows.h"

#include "defs.h"
#include "register.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

#define SHAREWARE_WAIT 15

typedef struct
{
  int     nb_sec ;
  clock_t t0 ;
}
WEXTENSION_BUYME ;


void OnInitDialogBuyMe(void *w)
{
  GEM_WINDOW       *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_BUYME *wext = wnd->DlgData->UserData ;
  OBJECT           *adr_shareware = wnd->DlgData->BaseObject ;

  adr_shareware[SHARE_WAIT].ob_flags     &= ~HIDETREE ;
  adr_shareware[SHARE_REGISTER].ob_flags |= HIDETREE ;
  adr_shareware[SHARE_CANCEL].ob_flags   |= HIDETREE ;

  write_text( adr_shareware, SHARE_EMAIL, "vision@atari.org" ) ;

  wext->nb_sec = 0 ;
  wext->t0     = clock() ;
  GWSetTimer( wnd, 1000 ) ;
}

#pragma warn -par
int OnObjectNotifyBuyMe(void *w, int obj)
{
  int code = -1 ;

  switch( obj )
  {
    case SHARE_REGISTER : code = IDOK ;
                          break ;
     case SHARE_CANCEL  : code = IDCANCEL ;
                          break ;
  }

  if ( code == IDOK )
  {

  }

  return( code ) ;
}

int OnTimerBuyMe(void *w, int mx, int my)
{
  GEM_WINDOW       *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_BUYME *wext = wnd->DlgData->UserData ;
  OBJECT           *adr_shareware = wnd->DlgData->BaseObject ;
  char             buf[50] ;

  wext->nb_sec = (int) ( ( clock() - wext->t0 ) / CLK_TCK ) ;
  if ( wext->nb_sec < SHAREWARE_WAIT )
  {
    sprintf( buf, "%02d", SHAREWARE_WAIT - wext->nb_sec ) ;
    write_text( adr_shareware, SHARE_WAIT, buf ) ;
    xobjc_draw( wnd->window_handle, adr_shareware, SHARE_WAIT ) ;
  }

  if ( wext->nb_sec >= SHAREWARE_WAIT )
  {
    GWKillTimer( wnd ) ;
    adr_shareware[SHARE_WAIT].ob_flags     |= HIDETREE ;
    adr_shareware[SHARE_REGISTER].ob_flags &= ~HIDETREE ;
    adr_shareware[SHARE_CANCEL].ob_flags   &= ~HIDETREE ;
    GWRePaint( wnd ) ;
  }

  return( GW_EVTCONTINUEROUTING ) ;
}
#pragma warn +par

int OnCloseBuyMe(void *w)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  OBJECT     *adr_shareware = wnd->DlgData->BaseObject ;

  if ( ( adr_shareware[SHARE_CANCEL].ob_flags & HIDETREE ) ||
       ( adr_shareware[SHARE_REGISTER].ob_flags & HIDETREE )
     )
  {
    return( -1 ) ;
  }
  else return( GWCloseDlg( w ) ) ;
}

int FGetBuyMe(void)
{
  WEXTENSION_BUYME wext ;
  GEM_WINDOW       *dlg ;
  DLGDATA          dlg_data ;
  int              code ;

  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
  dlg_data.RsrcId       = FORM_SHAREWARE ;
  strcpy( dlg_data.Title, MsgTxtGetMsg(hMsg, MSG_WFNAMES)  ) ;
  dlg_data.UserData     = &wext ;
  dlg_data.OnInitDialog = OnInitDialogBuyMe ;
  dlg_data.OnObjectNotify = OnObjectNotifyBuyMe ;
  dlg_data.OnCloseDialog  = OnCloseBuyMe ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  dlg->OnTimer = OnTimerBuyMe ;
  code = GWDoModal( dlg, 0 ) ;

  if ( code == IDOK )
  {

  }

  return( code ) ;
}

void buy_me(void)
{
/*  int code ;

  code = FGetBuyMe() ;
  code = IDOK;

  if ( code == IDOK ) check_user() ;*/
}

