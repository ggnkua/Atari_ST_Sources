#include <string.h>
#include "..\tools\gwindows.h"

#include "defs.h"
#include "snap.h"
#include "actions.h"
#include "rtzoom.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif


typedef struct
{
  int snap_flags ;
}
WEXTENSION_SNAP ;

void get_rect(int *x, int *y, int *w, int *h)
{
  int xe, ye ;
  int x1, y1, x2, y2 ;
  int bm, dummy ;
  int zoom_what ;
 
  zoom_what = config.rt_zoomwhat ;
  if ( zoom_what == RTZ_SMART ) zoom_what = RTZ_SCREEN ;

  wind_update( BEG_UPDATE ) ;
  do
  {
    graf_mkstate( &xe, &ye, &bm, &dummy ) ;
    if ( config.use_rtzoom ) rtzoom_display( xe, ye, zoom_what ) ;
  }
  while ( bm != 1 ) ;

  x1 = xe ; y1 = ye ;
  do
  {
    graf_mkstate( &x2, &y2, &bm, &dummy ) ;
    if ( (x1 != x2) || (y1 != y2) )
    {
      vsl_type( handle, DOT ) ;
      vsl_color( handle, 1 ) ;
      vsl_width( handle, 1 ) ;
      vsl_ends( handle, SQUARE, SQUARE ) ;
      vswr_mode( handle, MD_XOR ) ;
      v_hide_c( handle ) ;
      rectangle( xe, ye, x1, y1 ) ;
      rectangle( xe, ye, x2, y2 ) ;
      v_show_c( handle, 1 ) ;
      x1 = x2 ; y1 = y2 ;
      if ( config.use_rtzoom ) rtzoom_display( x2, y2, zoom_what ) ;
    }
  }
  while ( bm == 1 ) ;

  v_hide_c( handle ) ;
  rectangle( xe, ye, x1, y1 ) ;
  v_show_c( handle, 1 ) ;
  wind_update( END_UPDATE ) ;

  if ( xe > x2 )
  {
    x2 = xe ;
    xe = dummy ;
  }
  if ( ye > y2 )
  {
    y2 = ye ;
    ye = dummy ;
  }
  *x = xe ;          *y = ye ;
  *w = 1 + x2 - xe ; *h = 1 + y2 - ye ;
}

void OnInitDialogSnap(void *w)
{
  GEM_WINDOW* wnd = (GEM_WINDOW* ) w ;
  OBJECT     *adr = wnd->DlgData->BaseObject ;

  deselect( adr, SNAP_SCREEN ) ;
  deselect( adr, SNAP_BLOC ) ;
  if ( config.snap_flags & SF_ALLSCREEN ) select( adr, SNAP_SCREEN ) ;
  else                                    select( adr, SNAP_BLOC ) ;
}

int OnObjectNotifySnap(void *w, int obj)
{
  GEM_WINDOW      *wnd = (GEM_WINDOW* ) w ;
  WEXTENSION_SNAP *wext = wnd->DlgData->UserData ;
  OBJECT          *adr = wnd->DlgData->BaseObject ;
  int             code = -1 ;

  switch( obj )
  {
    case SNAP_SCREEN :
    case SNAP_TSCREEN :
                        select( adr, SNAP_SCREEN ) ;
                        deselect( adr, SNAP_BLOC ) ;
                        xobjc_draw( wnd->window_handle, adr, SNAP_SCREEN ) ;
                        xobjc_draw( wnd->window_handle, adr, SNAP_BLOC ) ;
                        break ;
    case SNAP_BLOC  :
    case SNAP_TBLOC :
                        deselect( adr, SNAP_SCREEN ) ;
                        select( adr, SNAP_BLOC ) ;
                        xobjc_draw( wnd->window_handle, adr, SNAP_SCREEN ) ;
                        xobjc_draw( wnd->window_handle, adr, SNAP_BLOC ) ;
                        break ;

    case SNAP_TMOUSE  : 
                        inv_select( adr, SNAP_MOUSE ) ;
                        break ;
     case SNAP_OK     : code = IDOK ;
                        break ;
     case SNAP_CANCEL : code = IDCANCEL ;
                        break ;
  }

  if ( code == IDOK )
  {
    if ( selected( adr, SNAP_SCREEN ) ) wext->snap_flags  = SF_ALLSCREEN ;
    else                                wext->snap_flags  = SF_RECT ;
    if ( selected( adr, SNAP_MOUSE ) )  wext->snap_flags |= SF_MOUSE ;
  }

  return( code ) ;
}

int FGetSnap(WEXTENSION_SNAP *wext)
{
  GEM_WINDOW* dlg ;
  DLGDATA    dlg_data ;
  int        code ;

  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId       = FORM_SNAP ;
  strcpy( dlg_data.Title, MsgTxtGetMsg(hMsg, MSG_WFNAMES)  ) ;
  dlg_data.UserData     = wext ;
  dlg_data.OnInitDialog = OnInitDialogSnap ;
  dlg_data.OnObjectNotify = OnObjectNotifySnap ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, 0 ) ;

  if ( code == IDOK )
  {

  }

  return( code ) ;
}

void snap(int setup)
{
  WEXTENSION_SNAP wext ;
  int code = IDOK ;
  int x, y, w, h ;

  if ( setup ) code = FGetSnap( &wext ) ;
  else         memzero( &wext, sizeof(wext) ) ;

  if ( !setup || ( code == IDOK ) )
  {
    static int num = 0 ;
    char       buf[30] ;

    if ( code ==IDOK )
    {
      config.snap_flags = wext.snap_flags ;
      GWRedraws() ;
    }
    if ( config.snap_flags & SF_RECT ) get_rect( &x, &y, &w, &h ) ;
    else
    {
      x = y = 0 ;
      w = screen.fd_w ;
      h = screen.fd_h ;
    }
    sprintf( buf, "SNAP%02d.TIF", num++ ) ;
    snap_wimage( buf, x, y, w, h ) ;
  }
}