/************************************/
/*            GWINDOWS.C            */
/* Gestion "objet" des fenetres GEM */
/************************************/
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "xgem.h"
#include "gwindows.h"
#include "aides.h"
#include "image_io.h"
#include "rasterop.h"

#define GET_GEM_WINDOW_FROM_LIST_ENTRY(x) CONTAINING_RECORD((x), GEM_WINDOW, ListEntry)
#define GET_LIST_ENTRY_FROM_GEM_WINDOW(x) (&(x)->ListEntry)

GEM_APP    GemApp ;


int GWIsWindowValid(GEM_WINDOW *wnd)
{
  LIST_ENTRY *sentry = GET_LIST_ENTRY_FROM_GEM_WINDOW( wnd ) ;
  LIST_ENTRY *entry = &GemApp.GemWindowListHead ;
  int        found = 0 ;

  entry = entry->Flink ;
  while ( !found && ( entry != &GemApp.GemWindowListHead ) )
  {
    if ( entry == sentry ) found = 1 ;
    entry = entry->Flink ;
  }

  return( found ) ;
}

GEM_WINDOW *GetWindowByHandle(int handle)
{
  LIST_ENTRY *entry = &GemApp.GemWindowListHead ;
  GEM_WINDOW *wnd ;
  GEM_WINDOW *wnd_found = NULL ;

  if ( handle < 0 ) return( NULL ) ;

  entry = entry->Flink ;
  while ( ( wnd_found == NULL ) && ( entry != &GemApp.GemWindowListHead ) )
  {
    wnd   = GET_GEM_WINDOW_FROM_LIST_ENTRY( entry ) ;
    entry = entry->Flink ;
    if ( wnd->window_handle == handle )
      wnd_found = wnd ;
  }

  return( wnd_found ) ;
}

GEM_WINDOW *GWGetWindowByClass(char *class_name)
{
  LIST_ENTRY *entry = &GemApp.GemWindowListHead ;
  GEM_WINDOW *wnd ;
  GEM_WINDOW *wnd_found = NULL ;

  entry = entry->Flink ;
  while ( ( wnd_found == NULL ) && ( entry != &GemApp.GemWindowListHead ) )
  {
    wnd   = GET_GEM_WINDOW_FROM_LIST_ENTRY( entry ) ;
    entry = entry->Flink ;
    if ( strcmp( wnd->ClassName, class_name ) == 0 )
      wnd_found = wnd ;
  }

  return( wnd_found ) ;
}

GEM_WINDOW *AllocateNewGemWindow(void)
{
  GEM_WINDOW *wnd = NULL ;

  if ( GemApp.NbGemWindows >= NB_MAX_GEM_WINDOWS ) return( wnd ) ;

  wnd = (GEM_WINDOW *) calloc( 1, sizeof(GEM_WINDOW) ) ;
  if ( wnd )
  {
    InsertHeadList( &GemApp.GemWindowListHead, &wnd->ListEntry ) ;
    GemApp.NbGemWindows++ ;
  }

  return( wnd ) ;
}

void DestroyWindow(GEM_WINDOW *wnd)
{
  if ( GWIsWindowValid( wnd ) )
  {
    GemApp.NbGemWindows-- ;
    RemoveEntryList( GET_LIST_ENTRY_FROM_GEM_WINDOW( wnd ) ) ;
    if ( wnd->window_handle >= 0 )
    {
      if ( wnd->flags & FLG_ISVISIBLE ) wind_close( wnd->window_handle ) ;
      wind_delete( wnd->window_handle ) ;
    }
    if ( wnd->window_icon.fd_addr ) free( wnd->window_icon.fd_addr ) ;
    if ( wnd->Extension ) free( wnd->Extension ) ;
    free( wnd ) ;
  }
}

int GWInModalDialog(void)
{
  int in_modal_dialog = 0 ;

  if ( GemApp.CurrentGemWindow && ( GemApp.CurrentGemWindow->flags & FLG_ISMODAL ) )
    in_modal_dialog = 1 ;

  return( in_modal_dialog ) ;
}

int GWInDialog(void)
{
  int in_dialog = 0 ;

  if ( GemApp.CurrentGemWindow && GemApp.CurrentGemWindow->DlgData )
    in_dialog = 1 ;

  return( in_dialog ) ;
}

long ComputeMinTimer(void)
{
  LIST_ENTRY *entry = &GemApp.GemWindowListHead ;
  GEM_WINDOW *wnd ;
  long       ms, min_timer = 1000L ; /* Pour les bulles d'aide */

  if ( GemApp.TimeOutMs > 0 )
    if ( GemApp.TimeOutMs < min_timer ) min_timer = GemApp.TimeOutMs ;

  entry = entry->Flink ;
  while ( entry != &GemApp.GemWindowListHead )
  {
    wnd = GET_GEM_WINDOW_FROM_LIST_ENTRY( entry ) ;
    if ( wnd->TimeOutMs > 0 )
      if ( wnd->TimeOutMs < min_timer ) min_timer = wnd->TimeOutMs ;
    entry = entry->Flink ;
  }

  ms = min_timer / 2 ; 
  if ( ms == 0 ) ms = 1 ;

  return( ms ) ;
}

void GWSetTimer(GEM_WINDOW *wnd, long ms)
{
  if ( wnd )
  {
    wnd->TimeOutMs = ms ;
    wnd->LastTick  = clock() ;
  }
  else
  {
    GemApp.TimeOutMs = ms ;
    GemApp.LastTick  = clock() ;
  }

  ms = ComputeMinTimer() ;

  GemApp.Event.ev_mtlocount  = (int) ( ms ) ;
  GemApp.Event.ev_mthicount  = (int) ( ms >> 16 ) ;
}

void GWKillTimer(GEM_WINDOW *wnd)
{
  long ms ;

  if ( wnd ) wnd->TimeOutMs = -1 ;
  else      GemApp.TimeOutMs = -1 ;

  ms = ComputeMinTimer() ;

  GemApp.Event.ev_mtlocount  = (int) ( ms ) ;
  GemApp.Event.ev_mthicount  = (int) ( ms >> 16 ) ;
}


/* Fonctions de base appellees par defaut si la fenetre ne le redefinit pas */
/* Peut etre appele depuis la routine qui a ete deroutee */
#pragma warn -par
void GWOnDraw(GEM_WINDOW *wnd, int xycoords[4])
{
  int index ;
  int xy[4] ;

  if ( !Truecolor ) index = 0 ;
  else
  {
    int rgb[3] = { 1000, 1000, 1000 } ;

    index = 19 ;
    vs_color( handle, index, rgb ) ;
  }
  vswr_mode( handle, MD_REPLACE ) ;
  vsf_color( handle, index ) ;
  vsf_interior( handle, FIS_SOLID ) ;
  vsf_perimeter( handle, 0 ) ;

  xy[0] = xycoords[0] ;
  xy[1] = xycoords[1] ;
  xy[2] = xycoords[0] + xycoords[2] - 1 ;
  xy[3] = xycoords[1] + xycoords[3] - 1 ;
  vr_recfl( handle, xy ) ;
}
#pragma warn +par

int GWOnTopped(GEM_WINDOW *wnd)
{
  wind_set( wnd->window_handle, WF_TOP ) ;

  return( 0 ) ;
}

#pragma warn -par
int GWOnUnTopped(GEM_WINDOW *wnd)
{
  return( 0 ) ;
}
#pragma warn +par

GEM_WINDOW *GetTopWnd(void)
{
  int h_topped ;

  wind_get( 0, WF_TOP, &h_topped ) ;

  return( GetWindowByHandle( h_topped ) ) ;
}

int GWOnClose(GEM_WINDOW *wnd)
{
  DestroyWindow( wnd ) ;
  GemApp.CurrentGemWindow = GetTopWnd() ; /* WM_TOPPED n'est pas envoye ensuite sous certains vieux TOS */

  return( GW_EVTCONTINUEROUTING ) ;
}

void GWOnMove(GEM_WINDOW *wnd, int xywh[4])
{
  wind_set( wnd->window_handle, WF_CURRXYWH, xywh[0], xywh[1], xywh[2], xywh[3]) ;
}
 
void GWOnHSlider(GEM_WINDOW *wnd, int pos)
{
  wind_set( wnd->window_handle, WF_HSLIDE, pos ) ;
}
 
void GWOnVSlider(GEM_WINDOW *wnd, int pos)
{
  wind_set( wnd->window_handle, WF_VSLIDE, pos ) ;
}

void GWOnSize(GEM_WINDOW *wnd, int xywh[4])
{
  wind_set( wnd->window_handle, WF_CURRXYWH, xywh[0], xywh[1], xywh[2], xywh[3]) ;

  wnd->must_be_fulled = 1 ;
  GWRePaint( wnd ) ;
}
 
int GWOnFulled(GEM_WINDOW *wnd, int xywh[4])
{
  if ( xywh )
    wind_set( wnd->window_handle, WF_CURRXYWH, xywh[0], xywh[1], xywh[2], xywh[3] ) ;
  else
    wind_set( wnd->window_handle, WF_CURRXYWH, xdesk, ydesk, wdesk, hdesk ) ;

  wnd->must_be_fulled = 0 ;

  GWInvalidate( wnd ) ;

  return( 0 ) ;
}
 
int GWOnRestoreFulled(GEM_WINDOW *wnd, int xywh[4])
{
  int x, y, w, h ;

  if ( xywh )
  {
    x = xywh[0] ; y = xywh[1] ;
    w = xywh[2] ; h = xywh[3] ;
  }
  else
  wind_get( wnd->window_handle, WF_PREVXYWH, &x, &y, &w, &h ) ;
  wind_set( wnd->window_handle, WF_CURRXYWH, x, y, w, h ) ;

  wnd->must_be_fulled = 1 ;

  GWInvalidate( wnd ) ;
  
  return( 0 ) ;
}

int GWOnIconify(GEM_WINDOW *wnd, int xywh[4])
{
  int x, y, w, h ;

  wnd->is_icon = 1 ;
  wind_get( wnd->window_handle, WF_CURRXYWH, &x, &y, &w, &h ) ;
  wnd->xywh_bicon[0] = x ; wnd->xywh_bicon[1] = y ;
  wnd->xywh_bicon[2] = w ; wnd->xywh_bicon[3] = h ;
  form_dial( FMD_SHRINK, xywh[0], xywh[1], xywh[2], xywh[3], x, y, w, h ) ;
  wind_set( wnd->window_handle, WF_ICONIFY, xywh[0], xywh[1], xywh[2], xywh[3] ) ;

  return( 0 ) ;
}

int GWOnUnIconify(GEM_WINDOW *wnd, int xywh[4])
{
  int x, y, w, h ;

  wnd->is_icon = 0 ;
  wind_get( wnd->window_handle, WF_WORKXYWH, &x, &y, &w, &h ) ;
  form_dial( FMD_GROW, x, y, w, h, xywh[0], xywh[1], xywh[2], xywh[3] ) ;
  wind_set( wnd->window_handle, WF_UNICONIFY, xywh[0], xywh[1], xywh[2], xywh[3] ) ;

  return( 0 ) ;
}

#pragma warn -par
int GWOnKeyPressed(int key)
{

  return( 0 ) ;
}
#pragma warn +par

#pragma warn -par
int GWOnMenuSelected(int t_id, int m_id)
{
  if ( GemApp.Menu ) menu_tnormal( GemApp.Menu, t_id, 1 ) ;

  return( 0 ) ;
}
#pragma warn +par

int CursorKeyToArrowAction(int key)
{
  int action = 0 ;

  switch( key )
  {
    case CURSOR_UP  : action = WA_UPLINE ;
                      break ;

    case CURSOR_SUP : action = WA_UPPAGE ;
                      break ;

    case CURSOR_DN  : action = WA_DNLINE ;
                      break ;

    case CURSOR_SDN : action = WA_DNPAGE ;
                      break ;

    case CURSOR_RT  : action = WA_RTLINE ;
                      break ;

    case CURSOR_SRT : action = WA_RTPAGE ;
                      break ;

    case CURSOR_LT  : action = WA_LFLINE ;
                      break ;

    case CURSOR_SLT : action = WA_LFPAGE ;
                      break ;
  }

  return( action ) ;
}

int GeneralKbdHandler(int key)
{
  GEM_WINDOW *cur_window = GemApp.CurrentGemWindow ;
  int        code = GW_EVTCONTINUEROUTING ;
  int        cursor_key, action ;

  cursor_key = ( key == CURSOR_UP ) || ( key == CURSOR_SUP ) ||
               ( key == CURSOR_DN ) || ( key == CURSOR_SDN ) ||
               ( key == CURSOR_RT ) || ( key == CURSOR_SRT ) ||
               ( key == CURSOR_LT ) || ( key == CURSOR_SLT ) ;

  GWSetMenuStatus( 0 ) ;

  if ( cur_window && cur_window->OnKeyPressed )
    code = cur_window->OnKeyPressed( cur_window, key ) ;

  if ( cursor_key && ( code == GW_EVTCONTINUEROUTING ) && cur_window->OnArrow )
  {
    action = CursorKeyToArrowAction( key ) ;
    cur_window->OnArrow( cur_window, action ) ;
    code = GW_EVTSTOPROUTING ;
  }

  if ( code == GW_EVTCONTINUEROUTING )
  {
    if ( GemApp.OnKeyPressed )
      code = GemApp.OnKeyPressed( key ) ;
    else
      code = GWOnKeyPressed( key ) ;
  }

  if ( !GWInModalDialog() )
  {
    if ( GemApp.OnUpdateGUI ) GemApp.OnUpdateGUI() ;
    else                      GWSetMenuStatus( 1 ) ;
  }

  return( code ) ;
}

void BasicDrawingHandler(GEM_WINDOW *wnd, int pxy[4])
{
  MFDB new_icon ;
  int  xyarray[4] ;
  int  xywh[4] ;
  int  xy[8] ;
  int  x, y, w, h ;
  int  xi,yi, wx, wy ;
  int  rx, ry, rw, rh ;
  int  xoffset, yoffset ;

  wind_update( BEG_UPDATE ) ;

  x = pxy[0] ; y = pxy[1] ;
  w = pxy[2] ; h = pxy[3] ;
  wind_get( wnd->window_handle, WF_WORKXYWH, &xi, &yi, &wx, &wy ) ;
  wind_get( wnd->window_handle, WF_FIRSTXYWH, &rx, &ry, &rw, &rh ) ;
    
  v_hide_c( handle ) ;
  while ( rw != 0 )
  {
    if ( intersect( x, y, w, h, rx, ry, rw, rh, xyarray ) )
    {
      /* intersect renvoi des coordonnees et non des largeurs... */
      memcpy( xywh, xyarray, 4*sizeof(int) ) ;
      xywh[2] = 1 + xywh[2] - xywh[0] ;
      xywh[3] = 1 + xywh[3] - xywh[1] ;

      if ( wnd->is_icon && wnd->window_icon.fd_addr )
      {
        /* Si l'icone est plus petite que la fenetre iconisee, on cree une */
        /* Nouvelle icone de la bonne taille, centree sur la zone cliente  */
        if ( ( wx > wnd->window_icon.fd_w ) || ( wy > wnd->window_icon.fd_h ) )
        {
          memcpy( &new_icon, &wnd->window_icon, sizeof(MFDB) ) ;
          new_icon.fd_w = wx ;
          new_icon.fd_h = wy ;
          new_icon.fd_wdwidth = new_icon.fd_w / 16 ;
          if ( new_icon.fd_w % 16 ) new_icon.fd_wdwidth++ ;
          new_icon.fd_addr = img_alloc( new_icon.fd_w, new_icon.fd_h, new_icon.fd_nplanes ) ;
          if ( new_icon.fd_addr == NULL ) GWOnDraw( wnd, xywh ) ;
          else
          {
            img_raz( &new_icon ) ;
            xy[0] = 0 ; xy[1] = 0 ;
            xy[2] = wnd->window_icon.fd_w - 1 ;
            xy[3] = wnd->window_icon.fd_h - 1 ;
            xy[4] = ( new_icon.fd_w - wnd->window_icon.fd_w ) >> 1 ;
            xy[5] = ( new_icon.fd_h - wnd->window_icon.fd_h ) >> 1 ;
            xy[6] = xy[4] + xy[2] - xy[0] ;
            xy[7] = xy[5] + xy[3] - xy[1] ;
            vro_cpyfm( handle, S_ONLY, xy, &wnd->window_icon, &new_icon ) ;
            free( wnd->window_icon.fd_addr ) ;
            memcpy( &wnd->window_icon, &new_icon, sizeof(MFDB) ) ;
          }
        }
        xoffset = xyarray[0] - xi ; yoffset = xyarray[1] - yi ;
        xy[0]   = xoffset ; xy[1] = yoffset ;
        xy[2]   = xy[0] + xywh[2] - 1 ;
        xy[3] = xy[1] + xywh[3] - 1 ;
        xy[4] = xyarray[0] ; xy[5] = xyarray[1] ;
        xy[6] = xy[4] + xy[2] - xy[0] ;
        xy[7] = xy[5] + xy[3] - xy[1] ;
        vro_cpyfm( handle, S_ONLY, xy, &wnd->window_icon, &screen ) ;
      }
      else if ( wnd->is_icon ) GWOnDraw( wnd, xywh ) ; /* Champ icon  non valide */
      else
      {
        if ( wnd->flags & FLG_MUSTCLIP ) vs_clip( handle, 1, xyarray ) ;
        if ( wnd->OnDraw ) wnd->OnDraw( wnd, xywh ) ;
        else               GWOnDraw( wnd, xywh ) ;
        if ( wnd->flags & FLG_MUSTCLIP ) vs_clip( handle, 0, xyarray ) ;
      }
    }
	wind_get( wnd->window_handle, WF_NEXTXYWH, &rx, &ry, &rw, &rh ) ;
  }
  v_show_c( handle, 1 ) ;

  wind_update( END_UPDATE ) ;
}

int BasicMenuHandler(int *mesag)
{
  int code = GW_EVTCONTINUEROUTING ;

  if ( !GWInModalDialog() )
  {
    GWSetMenuStatus( 0 ) ;
    if ( GemApp.CurrentGemWindow && GemApp.CurrentGemWindow->OnMenuSelected )
      code = GemApp.CurrentGemWindow->OnMenuSelected( GemApp.CurrentGemWindow, mesag[3], mesag[4] ) ;

    if ( code == GW_EVTCONTINUEROUTING )
    {
      if ( GemApp.OnMenuSelected )
        code = GemApp.OnMenuSelected( mesag[3], mesag[4] ) ;
      else
        code = GWOnMenuSelected( mesag[3], mesag[4] ) ;
    }
  }

  return( code ) ;
}

int GeneralMesagHandler(EVENT *event)
{
  GEM_WINDOW *wnd, *cur_wnd ;
  int        code   = 0 ;
  int        *mesag  = event->ev_mmgpbuf ;
  int        err, top_done = 0 ;
  int        update_gui = 0 ;
  int        in_modal_dialog = GWInModalDialog() ;
  int        in_dialog = 1 ;
  char       *pfile, file[PATH_MAX] ;

  if ( !in_modal_dialog ) in_dialog = GWInDialog() ;

  cur_wnd = GemApp.CurrentGemWindow ;
  wnd     = GetWindowByHandle( mesag[3] ) ;
  if ( in_dialog && cur_wnd )
  {
    DIALOG *dlg = cur_wnd->DlgData ;
    int    h_topped ;

    wind_get( cur_wnd->window_handle, WF_TOP, &h_topped ) ;
    if ( h_topped == cur_wnd->window_handle ) dlg->ShowEdit = 1 ;
    else                                      dlg->ShowEdit = 0 ;
/*    if ( dlg->EditObject && dlg->ShowEdit )
      objc_edit( dlg->BaseObject, dlg->EditObject, 0, &dlg->Idx, ED_END ) ;*/
  }

  switch( mesag[0] )
  {
    case MN_SELECTED : code = BasicMenuHandler( mesag ) ;
                       update_gui = 1 ;
                       break ;

    case WM_REDRAW   : if ( wnd ) BasicDrawingHandler( wnd, &mesag[4] ) ;
                       break ;

    case WM_TOPPED   :
    case WM_ONTOP    :
    case WM_NEWTOP   : if ( wnd && ( !in_modal_dialog || ( in_modal_dialog && ( wnd == cur_wnd ) ) ) )
                       {
                         if ( wnd->OnTopped ) top_done = ( wnd->OnTopped( wnd ) == 0 ) ;
                         else                 top_done = ( GWOnTopped( wnd ) == 0 ) ;
                       }
                       else top_done = 0 ;
                       if ( top_done ) GemApp.CurrentGemWindow = wnd ;
                       update_gui = 1 ;
                       break ;

    case WM_UNTOPPED : if ( wnd && ( !in_modal_dialog || ( in_modal_dialog && ( wnd == cur_wnd ) ) ) )
                       {
                         if ( wnd->OnUnTopped ) top_done = ( wnd->OnUnTopped( wnd ) == 0 ) ;
                         else                   top_done = ( GWOnUnTopped( wnd ) == 0 ) ;
                       }
                       else top_done = 0 ;
                       if ( top_done ) GemApp.CurrentGemWindow = GetTopWnd() ;
                       update_gui = 1 ;
                       break ;

    case WM_CLOSED   : if ( !in_modal_dialog || ( wnd == cur_wnd ) )
    case GWM_DESTROY : {
                         if ( wnd )
                         {
                           if ( wnd->OnClose ) code = wnd->OnClose( wnd ) ;
                           else                code = GWOnClose( wnd ) ;
                           if ( in_modal_dialog && ( code == IDCANCEL ) ) code = GW_EVTQUITAPP ; /* Sortie de DoModal */
                         }
                       }
                       update_gui = 1 ;
                       break ;

    case WM_MOVED    : if ( wnd )
                       {
                         if ( wnd->OnMove ) wnd->OnMove( wnd, &mesag[4] ) ;
                         else               GWOnMove( wnd, &mesag[4] ) ;
                       }
                       break ;

    case WM_HSLID    : if ( wnd )
                       {
                         if ( wnd->OnHSlider ) wnd->OnHSlider( wnd, mesag[4] ) ;
                         else                  GWOnHSlider( wnd, mesag[4] ) ;
                       }
                       break ;

    case WM_VSLID    : if ( wnd )
                       {
                         if ( wnd->OnVSlider ) wnd->OnVSlider( wnd, mesag[4] ) ;
                         else                  GWOnVSlider( wnd, mesag[4] ) ;
                       }
                       break ;

    case WM_SIZED    : if ( wnd )
                       {
                         if ( wnd->OnSize ) wnd->OnSize( wnd, &mesag[4] ) ;
                         else               GWOnSize( wnd, &mesag[4] ) ;
                       }
                       break ;

    case WM_FULLED   : if ( wnd )
                       {
                         if ( wnd->must_be_fulled )
                         {
                           if ( wnd->OnFulled ) err = wnd->OnFulled( wnd ) ;
                           else                 err = GWOnFulled( wnd, NULL ) ;
                           if ( !err ) wnd->must_be_fulled = 0 ;
                         }
                         else
                         {
                           if ( wnd->OnRestoreFulled ) err = wnd->OnRestoreFulled( wnd ) ;
                           else                        err = GWOnRestoreFulled( wnd, NULL ) ;
                           if ( !err ) wnd->must_be_fulled = 1 ;
                         }
                       }
                       update_gui = 1 ;
                       break ;

    case WM_ARROWED  : if ( wnd && wnd->OnArrow ) wnd->OnArrow( wnd, mesag[4] ) ;
                       break ;

    case WM_ICONIFY  : if ( wnd )
                       {
                         if ( wnd->OnIconify ) wnd->OnIconify( wnd, &mesag[4] ) ;
                         else                  GWOnIconify( wnd, &mesag[4] ) ;
                       }
                       update_gui = 1 ;
                       break ;

    case WM_UNICONIFY: if ( wnd )
                       {
                         if ( wnd->OnUnIconify ) wnd->OnUnIconify( wnd, wnd->xywh_bicon ) ;
                         else                    GWOnUnIconify( wnd, wnd->xywh_bicon ) ;
                       }
                       update_gui = 1 ;
                       break ;

    case WM_VASTART  : pfile = *(char **) &mesag[3] ;
                       do
                       {
                         pfile = GetNextVaStartFileName( pfile, file ) ;
                         if ( file[0] && GemApp.OnOpenFile ) GemApp.OnOpenFile( file ) ;
                       }
                       while ( pfile && file[0] ) ;
                       break ;

    default :          if ( GemApp.OnUnknownMsg ) code = GemApp.OnUnknownMsg( &GemApp, mesag ) ;
                       break ;
  }

  if ( !GWInModalDialog() && update_gui )
  {
    if ( GemApp.OnUpdateGUI ) GemApp.OnUpdateGUI() ;
    else                      GWSetMenuStatus( 1 ) ;
  }

  return( code ) ;
}

int GeneralButtonHandler(EVENT *event)
{
  GEM_WINDOW *wnd ;
  int        wh, mx, my ;
  int        wx, wy, dummy ;
  int        code = GW_EVTCONTINUEROUTING ;

  mx = event->ev_mmox ;
  my = event->ev_mmoy ;
  wh = wind_find( mx, my ) ;
  if ( GWInModalDialog() && ( wh != GemApp.CurrentGemWindow->window_handle ) ) return( GW_EVTCONTINUEROUTING ) ;

  if ( wh == 0 )
  {
    /* Renvoye a l'application */
    if ( event->ev_mbreturn > 1 )
    {
      if ( GemApp.OnDLButtonDown && ( event->ev_mmobutton & 1 ) )
        code= GemApp.OnDLButtonDown( event->ev_mmokstate, mx, my) ;
      if ( GemApp.OnDRButtonDown && ( event->ev_mmobutton & 2 ) )
        code = GemApp.OnDRButtonDown( event->ev_mmokstate, mx, my ) ;
    }
    else
    {
      if ( GemApp.OnLButtonDown && ( event->ev_mmobutton & 1 ) )
        code= GemApp.OnLButtonDown( event->ev_mmokstate, mx, my ) ;
      if ( GemApp.OnRButtonDown && ( event->ev_mmobutton & 2 ) )
        code = GemApp.OnRButtonDown( event->ev_mmokstate, mx, my ) ;
    }
  }
  else
  {
    wnd = GetWindowByHandle( wh ) ;
    if ( wnd )
    {
      GWGetWorkXYWH( wnd, &wx, &wy, &dummy, &dummy ) ;
      mx -= wx ;
      my -= wy ;
      if ( event->ev_mbreturn > 1 )
      {
        if ( wnd->OnDLButtonDown && ( event->ev_mmobutton & 1 ) )
          code= wnd->OnDLButtonDown( wnd, event->ev_mmokstate, mx, my ) ;
        if ( wnd->OnDRButtonDown && ( event->ev_mmobutton & 2 ) )
          code = wnd->OnDRButtonDown( wnd, event->ev_mmokstate, mx, my ) ;
      }
      else
      {
        if ( wnd->OnLButtonDown && ( event->ev_mmobutton & 1 ) )
          code= wnd->OnLButtonDown( wnd, event->ev_mmokstate, mx, my ) ;
        if ( wnd->OnRButtonDown && ( event->ev_mmobutton & 2 ) )
          code = wnd->OnRButtonDown( wnd, event->ev_mmokstate, mx, my ) ;
      }
    }
  }

  if ( !GWInModalDialog() )
  {
    if ( GemApp.OnUpdateGUI ) GemApp.OnUpdateGUI() ;
    else                      GWSetMenuStatus( 1 ) ;
  }

  return( code ) ;
}

int GeneralMouseHandler(EVENT *event)
{
  static GEM_WINDOW *last_gwnd = NULL ;
  GEM_WINDOW        *cur_window ;
  int               bbutton, mk_state, mx, my ;
  int               window_top ;
  int               xi, yi, wx, wy ;

  mx         = event->ev_mmox ;
  my         = event->ev_mmoy ;
  bbutton    = event->ev_mmobutton ;
  mk_state   = event->ev_mmokstate ;
  cur_window = GemApp.CurrentGemWindow ;

  wind_get( 0, WF_TOP, &window_top ) ;
  if ( cur_window && ( cur_window->window_handle == window_top ) )
  {
    if ( cur_window->OnMouseMove )
    {
      GWGetWorkXYWH( cur_window, &xi, &yi, &wx, &wy ) ;
      mx -= xi ; my -= yi ;
      if ( ( my < 0 ) || ( mx >= wx ) || ( my >= wy ) ) mx = my = -1 ;

      if ( mx != -1 )
      {
        cur_window->OnMouseMove( cur_window, bbutton, mk_state, mx, my ) ;
        cur_window->KnowMouseIsOut = 0 ;
      }
      else if ( !cur_window->KnowMouseIsOut )
      {
        cur_window->OnMouseMove( cur_window, bbutton, mk_state, mx, my ) ;
        cur_window->KnowMouseIsOut = 1 ;
      }

    }
  }

  if ( ( cur_window != last_gwnd ) &&
       GWIsWindowValid( last_gwnd ) &&
       last_gwnd->OnMouseMove &&
       !last_gwnd->KnowMouseIsOut )
  {
    last_gwnd->OnMouseMove( last_gwnd, bbutton, mk_state, mx, my ) ;
    last_gwnd = cur_window ;
    last_gwnd->KnowMouseIsOut = 1 ;
  }

  if ( GemApp.OnMouseMove )
    GemApp.OnMouseMove( bbutton, mk_state, event->ev_mmox, event->ev_mmoy ) ;

  return( 0 ) ;
}

int GeneralTimerHandler(int mx, int my)
{
  static size_t last_call ;
  static int    last_mx, last_my ;
  LIST_ENTRY    *entry = &GemApp.GemWindowListHead ;
  GEM_WINDOW    *wnd ;
  size_t        dt ;
  char          text[200] ;

  if ( GemApp.OnTimer && ( GemApp.TimeOutMs > 0 ) )
  {
    dt = clock() - GemApp.LastTick ;
    if ( 1000UL * dt > (size_t) GemApp.TimeOutMs * CLK_TCK )
    {
      GemApp.LastTick = clock() ;
      GemApp.OnTimer( mx, my ) ;
    }
  }

  entry = entry->Flink ; ;
  while ( entry != &GemApp.GemWindowListHead )
  {
    wnd = GET_GEM_WINDOW_FROM_LIST_ENTRY( entry ) ;
    if ( wnd->OnTimer && ( wnd->TimeOutMs > 0 ) )
    {
      dt = clock() - wnd->LastTick ;
      if ( 1000UL * dt > (size_t) wnd->TimeOutMs * CLK_TCK )
      {
        wnd->LastTick = clock() ;
        wnd->OnTimer( wnd, mx, my ) ;
      }
    }
    entry = entry->Flink ; ;
  }

  if ( GemApp.Flags.HelpBubbles && ( last_mx == mx ) && ( last_my == my ) )
  {
    wnd = GetWindowByHandle( wind_find( mx, my ) ) ;
    if ( wnd && wnd->OnTxtBubble )
    {
      dt = clock() - last_call ;
      if ( dt > CLK_TCK )
      {
        if ( wnd->OnTxtBubble( wnd, mx, my, text ) )
        {
          bulle_aide( mx, my, text ) ;
          last_call = clock() ;
        }
      }
    }
  }

  last_mx = mx ;
  last_my = my ;

  return( 0 ) ;
}

#define FMD_BACKWARD -1
#define FMD_FORWARD  -2
#define FMD_DFLT     -3
int find_object(OBJECT *tree, int start_obj, int which)
{
  int object, flag, theflag, inc ;

  object = 0 ;
  flag   = EDITABLE ;
  inc    = 1 ;
  switch( which )
  {
    case FMD_BACKWARD : inc-- ;
    case FMD_FORWARD  : object = start_obj + inc ;
                        break;
    case FMD_DFLT     : flag = DEFAULT ;
                        break;
  }

  while ( object >= 0 )
  {
    theflag = tree[object].ob_flags ;
    if ( theflag & flag ) return object ;
    if ( theflag & LASTOB ) object = -1 ;
    else                    object += inc ;
  }

  return( start_obj ) ;
}

int ini_field(OBJECT *tree,int start_field)
{
  if ( start_field <= 0 ) start_field = find_object( tree, 0, FMD_FORWARD ) ;

  return( start_field ) ;
}

int find_position(OBJECT *obj, int No, int mx)
{
  int te_x = 0 ;
  int P_text = 0 ;
  int P_mask = 0 ;
  int size ;
  int i, Child ;

  if ( No < 0 ) return( 0 ) ;

  size = obj[No].ob_spec.tedinfo->te_font==3 ? 8 : 6 ;
  te_x = obj[No].ob_spec.tedinfo->te_just ? obj[No].ob_width - (obj[No].ob_spec.tedinfo->te_tmplen-1) * size : 0 ;
  if ( obj[No].ob_spec.tedinfo->te_just == 2 ) te_x /= 2 ;
  te_x += obj[No].ob_x + size/2 ;

  Child= No;
  for ( i= No-1; 0<=i; i-- )
  {
    if ( ( obj[i].ob_head <= Child ) && ( Child <= obj[i].ob_tail ) )
    {
      Child = i ;
      te_x += obj[i].ob_x ;
    }
  }

  while ( ( te_x < mx ) && ( P_mask < obj[No].ob_spec.tedinfo->te_tmplen - 1 ) )
  {
    if ( obj[No].ob_spec.tedinfo->te_ptmplt[P_mask++] == '_' )
    P_text++ ;
    te_x += size ;
  }

  return( P_text ) ;
}

int GetDefaultButton(OBJECT *base_tree)
{
  int obj = -1 ;
  int ind = 0 ;

  while ( ( ( base_tree[ind].ob_flags & LASTOB ) == 0 ) && ( ( base_tree[ind].ob_flags & DEFAULT ) == 0 ) ) ind++ ;

  if ( base_tree[ind].ob_flags & DEFAULT ) obj = ind ;

  return( obj ) ;
}

void PreDialog(GEM_WINDOW *wnd, int mx)
{
  DIALOG *dlg ;

  if ( wnd == NULL ) return ;
  if ( wnd->is_icon ) return ;
  dlg = wnd->DlgData ;
  if ( dlg == NULL ) return ;

  dlg->MuMesag = 0 ;
  if ( dlg->NextObject )
  {
    if ( !xobjc_hasflag( dlg->BaseObject, dlg->NextObject, EDITABLE ) )
    {
	  dlg->NextObject = dlg->EditObject ;
	  dlg->EditObject = 0 ;
    }
    dlg->EditObject = dlg->NextObject ;
    dlg->NextObject = 0 ;
    if ( dlg->ShowEdit )
    {
      char letter, *letterptr ;
      char buf[200] ;

      if ( ( dlg->EditObject > 0 ) && ( dlg->Idx == -1 ) )
      {
        read_text( dlg->BaseObject, dlg->EditObject, buf ) ;
        dlg->Idx = (int)strlen( buf ) ;
      }
      if ( dlg->DoNotReInitEdit )
      {
        if ( dlg->EditObject )
          letter = *(letterptr = dlg->BaseObject[dlg->EditObject].ob_spec.tedinfo->te_ptext
                   + find_position( dlg->BaseObject, dlg->EditObject, mx ) ) ;
        *letterptr = '\000' ;
        objc_edit( dlg->BaseObject, dlg->EditObject, 0, &dlg->Idx, ED_INIT ) ;
        *letterptr = letter ;
      }
      else objc_edit( dlg->BaseObject, dlg->EditObject, 0, &dlg->Idx, ED_INIT ) ;
      dlg->DoNotReInitEdit = 1 ;
    }
  }
}

#pragma warn -par
int PostDialog(GEM_WINDOW *wnd)
{
  DIALOG     *dlg ;
  GEM_WINDOW *cur_wnd = GemApp.CurrentGemWindow ;

  if ( cur_wnd == NULL ) return( 0 ) ;
  if ( cur_wnd->is_icon ) return( 0 ) ;
  dlg = cur_wnd->DlgData ;
  if ( dlg == NULL ) return( 0 ) ;
  if ( dlg->MuMesag ) return( 0 ) ;

  if ( ( !dlg->Cont || dlg->NextObject ) && dlg->ShowEdit )
    objc_edit( dlg->BaseObject, dlg->EditObject, 0, &dlg->Idx, ED_END ) ;

  dlg->Cont = 1 ;

  return( dlg->ExitCode ) ;
}
#pragma warn +par

char GWLoop(void)
{
  EVENT *event = &GemApp.Event ;
  char  must_exit = 0 ;
  int   which ;
  int   code, dummy ;

  event->ev_mbclicks    = 258 ;
  event->ev_bmask       = 3 ;
  event->ev_mbstate     = 0 ;
  event->ev_mm1flags    = 0 ;
  event->ev_mm1x        = 0 ;
  event->ev_mm1y        = 0 ;
  event->ev_mm1width    = 0 ;
  event->ev_mm1height   = 0 ;
  event->ev_mm2flags    = 0 ;
  event->ev_mm2x        = 0 ;
  event->ev_mm2y        = 0 ;
  event->ev_mm2width    = 0 ;
  event->ev_mm2height   = 0 ;
  event->ev_mflags     |= MU_KEYBD | MU_MESAG | MU_BUTTON | MU_TIMER ;
  ComputeMinTimer() ;

  event->ev_mmox = 0 ; /* Pour PreDialog */

  if ( !GWInModalDialog() )
  {
    if ( GemApp.OnUpdateGUI ) GemApp.OnUpdateGUI() ;
    else                      GWSetMenuStatus( 1 ) ;
  }

  do
  {
    /* Positionnement du flag dynamique MU_M1 */
    if (   GemApp.OnMouseMove ||
         ( GemApp.CurrentGemWindow && GemApp.CurrentGemWindow->OnMouseMove )
       )
    {
      event->ev_mflags   |= MU_M1 ;
      event->ev_mm1flags  = 1 ; /* Attendre sortie de zone */
      event->ev_mm1x      = event->ev_mmox ;
      event->ev_mm1y      = event->ev_mmoy ;
      event->ev_mm1width  = 1 ;
      event->ev_mm1height = 1 ;
    }
    else event->ev_mflags &= ~MU_M1 ;

    /* MU_TIMER sert au minimum … g‚r‚r les bulles d'aide */

    if ( GWInDialog() ) PreDialog( GemApp.CurrentGemWindow, event->ev_mmox ) ;

    which = EvntMulti( event ) ;

    if ( which & MU_MESAG )
    {
      code = GeneralMesagHandler( event ) ;
      must_exit = ( code == GW_EVTQUITAPP ) ;
    }

    if ( which & MU_KEYBD )
    {
      code = GeneralKbdHandler( event->ev_mkreturn ) ;
      must_exit = ( code == GW_EVTQUITAPP ) ;
    }

    if ( which & MU_BUTTON )
    {
      code = GeneralButtonHandler( event ) ;
      must_exit = ( code == GW_EVTQUITAPP ) ;
    }

    if ( which & MU_M1 )
      GeneralMouseHandler( event ) ;

    /* Pas de test sur MU_TIMER car un autre evenement a tres bien pu avoir lieu avant le time-out */      
    /* MU_M1 par exemple et cela reinitialiserait le timer */
    /* On re-demande les coordonnes de la souris parce qu'elles ont uu changer depuis */
    /* la sortie de EvntTMulti() suite aux handlers de messages GEM, clavier, et bouton de souris */
    graf_mkstate( &event->ev_mmox, &event->ev_mmoy, &dummy, &dummy ) ;
    GeneralTimerHandler( event->ev_mmox, event->ev_mmoy ) ;

    if ( GWInDialog() )
    {
      code = PostDialog( GemApp.CurrentGemWindow ) ;
      if ( GWInModalDialog() ) must_exit = ( ( code == IDOK ) || ( code == IDCANCEL ) ) ;
    }
  }
  while ( !must_exit ) ;

  return( code ) ;
}

void SetRecurseMenuStatus(OBJECT *root, int index, int parent, int valid)
{
  OBJECT *obj ;
  char   *string ;

  if ( index < 0 ) return ;
  obj = &root[index] ;
  if ( obj->ob_type == G_STRING )
  {
    string = obj->ob_spec.free_string ;
    if ( valid && ( string[0] != '-' ) ) obj->ob_state &= ~DISABLED ; /* ne marche pas sur A propos... */
    else                                 obj->ob_state |= DISABLED ; /* menu_ienable( root, index, 0 ) ;*/
  }
  if ( index != parent )
  {
    SetRecurseMenuStatus( root, obj->ob_next, parent, valid ) ;
    SetRecurseMenuStatus( root, obj->ob_head, index, valid ) ;
  }
}

void GWSetMenuStatus(int valid)
{
  if ( GemApp.Menu == NULL ) return ;

  SetRecurseMenuStatus( GemApp.Menu, GemApp.Menu->ob_next, 0, valid ) ;
  SetRecurseMenuStatus( GemApp.Menu, GemApp.Menu->ob_head, 0, valid ) ;
}

int GWSetMenu(int id, char *title)
{
  Xrsrc_gaddr( R_TREE, id, &GemApp.Menu ) ;
  if ( title && ( Multitos || !_app ) ) menu_register( ap_id, title ) ;

  menu_bar( GemApp.Menu, 1 ) ;

  return( 0 ) ;
}

#pragma warn -par
int NullProgPc(void *wnd, int pc, char *txt)
{

  return( 0 ) ;
}
#pragma warn +par

GEM_WINDOW *GWCreateWindow(int kind, long extension_size, char *class_name)
{
  GEM_WINDOW *wnd ;

  wnd = AllocateNewGemWindow() ;

  if ( wnd )
  {
    if ( extension_size > 0 )
    {
      wnd->Extension = calloc( extension_size, 1 ) ;
      if ( wnd->Extension == NULL ) return( NULL ) ;
    }
    wnd->window_handle = wind_create( kind, xdesk, ydesk, wdesk, hdesk ) ;
    if ( wnd->window_handle >= 0 )
    {
      wnd->window_kind  = kind ;
      strncpy( wnd->ClassName, class_name, 19 ) ;
      wnd->ProgPc      = NullProgPc ;
      wnd->GetWorkXYWH = (void (*)(void *, int *, int *, int *, int *)) GWGetWorkXYWH ;
    }
    else DestroyWindow( wnd ) ;
  }

  return( wnd ) ;
}

int GWOpenWindow(GEM_WINDOW *wnd, int x, int y, int w, int h)
{
  int w_return ;
  int err = 0 ;

  wind_set( wnd->window_handle, WF_NAME, wnd->window_name ) ;
  wind_set( wnd->window_handle, WF_INFO, wnd->window_info ) ;
  w_return = wind_open( wnd->window_handle, x, y, w, h ) ;
  if ( w_return == 0 )
  {
    wnd->flags &= ~FLG_ISVISIBLE ; /* Pour que DestroyWindow ne fasse pas wind_close */
    DestroyWindow( wnd ) ;
    err = 1 ;
  }
  else
  {
    wnd->flags             |= FLG_ISVISIBLE ;
    wnd->must_be_fulled     = 1 ;
    PostMessage( wnd, WM_TOPPED, NULL ) ;
  }

  return( err ) ;
}

#pragma warn -par
int OnLButtonDownDlg(void *w, int mk_state, int mx, int my)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  DIALOG     *dlg = wnd->DlgData ;
  int        obj_clicked ;
  int        wx, wy, dummy ;
  int        code = 0 ;

  if ( dlg == NULL ) return( 0 ) ;
  if ( dlg->MuMesag ) return( 0 ) ;

  GWGetWorkXYWH( wnd, &wx, &wy, &dummy, &dummy ) ;
  mx += wx ;
  my += wy ;
  obj_clicked = objc_find( dlg->BaseObject, 0, MAX_DEPTH, mx, my );
  if ( obj_clicked == -1 ) return( 0 ) ;
  if ( dlg->BaseObject[obj_clicked].ob_state & DISABLED ) return( 0 ) ;

  dlg->Cont = form_button( dlg->BaseObject, obj_clicked, 1, &dlg->NextObject ) ;

  if ( dlg->OnObjectNotify )
  {
    dlg->ExitCode = dlg->OnObjectNotify( wnd, obj_clicked ) ;
    code = dlg->ExitCode ;
    if ( ( code == IDOK ) || ( code == IDCANCEL ) )
    {
      deselect( dlg->BaseObject, obj_clicked ) ;
      /* Si cette boite est non modale, la fermeture intervient ici */
      if ( ( wnd->flags & FLG_ISMODAL ) == 0 ) GWDestroyWindow( wnd ) ;
      /* Si cette boite est modale, GWLoop interpretera dlg->ExitCode */
    }
/*    else xobjc_draw( wnd->window_handle, dlg->BaseObject, obj_clicked ) ;*/
  }

  return( code ) ;
}
#pragma warn +par

int GWCloseDlg(void *w)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;

  free( wnd->DlgData->BaseObject ) ;
  free( wnd->DlgData ) ;
  GWOnClose( wnd ) ;

  return( IDCANCEL ) ;
}

int OnToppedDlg(void *w)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;

  wnd->DlgData->ShowEdit = 1 ;

  return( GWOnTopped( wnd ) ) ;
}

int OnUnToppedDlg(void *w)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;

  wnd->DlgData->ShowEdit = 0 ;

  return( GWOnUnTopped( wnd ) ) ;
}

int GWOnKeyPressedDlg(void *w, int key)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  DIALOG     *dlg ;
  int        kr = key ;
  int        x, y ;
  int        wx, wy, dummy ;

  dlg = wnd->DlgData ;
  if ( dlg->MuMesag ) return( 0 ) ;

  dlg->Cont = form_keybd( dlg->BaseObject, dlg->EditObject, dlg->NextObject, kr, &dlg->NextObject, &kr ) ;
  if ( kr ) objc_edit( dlg->BaseObject, dlg->EditObject, kr, &dlg->Idx, ED_CHAR ) ;

  if ( ( key == 0x1C0D ) || ( key == 0x720D ) ) /* Return */
  {
    objc_offset( dlg->BaseObject, dlg->NextObject, &x, &y ) ;
    wnd->GetWorkXYWH( wnd, &wx, &wy, &dummy, &dummy ) ; 
    if ( wnd->OnLButtonDown ) wnd->OnLButtonDown( wnd, 1, 1+x-wx, 1+y-wy ) ;
  }

  return( 0 ) ;
}

void OnDrawDlg(void *w, int xywh[4])
{
  GEM_WINDOW *wnd  = (GEM_WINDOW *) w ;
  DIALOG     *dlg = wnd->DlgData ;
  OBJECT     *tree = dlg->BaseObject ;
  int        x, y, dummy ;

  if ( wnd->is_icon && ( wnd->window_icon.fd_addr == NULL ) ) GWOnDraw( wnd, xywh ) ;
  else
  {
    char buf[200] ;

    if ( ( dlg->EditObject > 0 ) && ( dlg->Idx == -1 ) )
    {
      read_text( dlg->BaseObject, dlg->EditObject, buf ) ;
      dlg->Idx = (int)strlen( buf ) ;
    }
    GWGetWorkXYWH( wnd, &x, &y, &dummy, &dummy ) ;
    tree->ob_x = x ;
    tree->ob_y = y ;
    objc_draw( tree, 0, MAX_DEPTH, xywh[0], xywh[1], xywh[2], xywh[3] ) ;
    if ( ( dlg->EditObject > 0 ) && dlg->ShowEdit )
      objc_edit( dlg->BaseObject, dlg->EditObject, 0, &dlg->Idx, ED_END ) ;
  }
}

void GWOnMoveDlg(void *gw, int xywh[4])
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) gw ;
  DIALOG     *dlg = wnd->DlgData ;
  int        x, y, w, h ;

  GWOnMove( wnd, xywh ) ;
  GWGetWorkXYWH( wnd, &x, &y, &w, &h ) ;
  dlg->BaseObject->ob_x = x ;
  dlg->BaseObject->ob_y = y ;
}

int XFormCenter(OBJECT *obj, int ixywh[4], int *x, int *y)
{
  int done_by_form_center = 0 ;
  int dummy ;
  int dw, dh ;

  if ( ixywh )
  {
    dw = ixywh[2] - obj->ob_width ;
    dh = ixywh[3] - obj->ob_height ;
    if ( dw < 0 ) done_by_form_center = 1 ;
    if ( dh < 0 ) done_by_form_center = 1 ;
  }
  else done_by_form_center = 1 ;

  if ( !done_by_form_center )
  {
    *x = ixywh[0] + dw / 2 ;
    *y = ixywh[1] + dh / 2 ;
  }
  else /* Centre sur l'ecran */
    form_center( obj, x, y, &dummy, &dummy ) ;

  return( done_by_form_center ) ; 
}

GEM_WINDOW *GWCreateDialog(DLGDATA *data)
{
  GEM_WINDOW *wnd ;
  DIALOG     *dlg ;
  OBJECT     *base_obj ;
  int        wkind = NAME | MOVER | CLOSER ;
  int        x, y ;
  int        bx, by, bw, bh ;
  char       class_name[20] ;

  wkind |= data->WKind ;
  wkind &= ~data->NWKind ;
  if ( data->RsrcId == -1 ) base_obj = data->Object ;
  else
  {
    if ( Xrsrc_gaddr( R_TREE, data->RsrcId, &base_obj ) == 0 ) return( NULL ) ;
    base_obj = xobjc_copy( base_obj ) ; /* Duplication de l'arbre */
  }

  if ( base_obj == NULL ) return( NULL ) ;

  if ( data->ClassName[0] ) strcpy( class_name, data->ClassName ) ;
  else                      sprintf( class_name, "%x", (unsigned long)base_obj ) ;
  wnd = GWCreateWindow( wkind, data->ExtensionSize, class_name ) ;
  if ( wnd )
  {
    dlg = (DIALOG *) calloc( sizeof(DIALOG) , 1 ) ;
    if ( dlg )
    {
      wnd->DlgData    = dlg ;
      dlg->BaseObject = base_obj ;
      dlg->UserData   = data->UserData ;
      dlg->Idx        = -1 ; /* Se positionne en fin d'objet editable */
      strcpy( wnd->window_name, data->Title ) ;

      if ( data->OnInitDialog )   dlg->OnInitDialog   = data->OnInitDialog ;
      if ( data->OnObjectNotify ) dlg->OnObjectNotify = data->OnObjectNotify ;
      if ( data->OnCloseDialog )  wnd->OnClose = data->OnCloseDialog ;
      else                        wnd->OnClose = GWCloseDlg ;

      if ( dlg->OnInitDialog ) dlg->OnInitDialog( wnd ) ;

      if ( data->XPos || data->YPos )
      {
        x = data->XPos ;
        y = data->YPos ;
      }
      else if ( data->Parent == NULL ) XFormCenter( base_obj, NULL, &x, &y ) ;
      else
      {
        int pxywh[4] ;

        data->Parent->GetWorkXYWH( data->Parent, &pxywh[0], &pxywh[1], &pxywh[2], &pxywh[3] ) ;
        XFormCenter( base_obj, pxywh, &x, &y ) ;
      }
      wnd->OnMove         = GWOnMoveDlg ;
      wnd->OnDraw         = OnDrawDlg ;
      wnd->OnKeyPressed   = GWOnKeyPressedDlg ;
      wnd->OnLButtonDown  = OnLButtonDownDlg ;
      wnd->OnTopped       = OnToppedDlg ;
      wnd->OnUnTopped     = OnUnToppedDlg ;

      dlg->NextObject = ini_field( dlg->BaseObject, 0 ) ;
      dlg->Cont = 1 ;

      wind_calc( WC_BORDER, wnd->window_kind, x, y, base_obj->ob_width, base_obj->ob_height, &bx, &by, &bw, &bh ) ;
      if ( GWOpenWindow( wnd, bx, by, bw, bh ) != 0 )
      {
        free( dlg ) ;
        wnd = NULL ;
      }
    }
  }

  return( wnd ) ;
}

int GWDoModal(GEM_WINDOW *wnd, int start_ob)
{
  DIALOG *dlg ;
  int    code ;

  if ( wnd == NULL ) return( -1 ) ;
  dlg = wnd->DlgData ;
  if ( dlg == NULL ) return( -1 ) ;

  wnd->flags |= FLG_ISMODAL ;
  PostMessage( wnd, WM_TOPPED, NULL ) ;
  GemApp.CurrentGemWindow = wnd ;
  if ( start_ob > 0 ) dlg->StartOb = start_ob ;
  dlg->NextObject = ini_field( dlg->BaseObject, dlg->StartOb ) ;
  dlg->Cont = 1 ;

  code = GWLoop() ; /* IDOK ou IDCANCEL */

  if ( GWIsWindowValid( wnd ) ) wnd->OnClose( wnd ) ;

  return( code ) ;
}

void GWEndModal(GEM_WINDOW *wnd)
{
  if ( GWIsWindowValid( wnd ) )
  {
    if ( wnd->OnClose ) wnd->OnClose( wnd ) ;
    else                GWCloseDlg( wnd ) ;
  }
}

GEM_WINDOW *GWCreateWindowCmdBar(DLGDATA *data)
{
  GEM_WINDOW *wnd ;
  DIALOG     *dlg ;
  OBJECT     *base_obj ;
  int        wkind = NAME | MOVER | CLOSER ;
  char       class_name[20] ;

  wkind |= data->WKind ;
  wkind &= ~data->NWKind ;
  if ( data->RsrcId == -1 ) base_obj = data->Object ;
  else
  {
    if ( Xrsrc_gaddr( R_TREE, data->RsrcId, &base_obj ) == 0 ) return( NULL ) ;
    base_obj = xobjc_copy( base_obj ) ; /* Duplication de l'arbre */
  }

  if ( base_obj == NULL ) return( NULL ) ;

  if ( data->ClassName[0] ) strcpy( class_name, data->ClassName ) ;
  else                      sprintf( class_name, "%x", (unsigned long)base_obj ) ;
  wnd = GWCreateWindow( wkind, data->ExtensionSize, class_name ) ;
  if ( wnd )
  {
    dlg = (DIALOG *) calloc( sizeof(DIALOG) , 1 ) ;
    if ( dlg )
    {
      wnd->DlgData    = dlg ;
      dlg->BaseObject = base_obj ;
      dlg->UserData   = data->UserData ;
      strcpy( wnd->window_name, data->Title ) ;

      if ( data->OnInitDialog )   dlg->OnInitDialog   = data->OnInitDialog ;
      if ( data->OnObjectNotify ) dlg->OnObjectNotify = data->OnObjectNotify ;
      if ( data->OnCloseDialog )  wnd->OnClose        = data->OnCloseDialog ;
      wnd->OnMove         = GWOnMoveDlg ;
      wnd->OnTopped       = OnToppedDlg ;
      wnd->OnUnTopped     = OnUnToppedDlg ;

      dlg->NextObject = ini_field( dlg->BaseObject, 0 ) ;
      dlg->Cont = 1 ;

      if ( dlg->OnInitDialog ) dlg->OnInitDialog( wnd ) ;
    }
  }

  return( wnd ) ;
}

void GWRePaint(GEM_WINDOW *wnd)
{
  int xy[4] ;

  /*wind_get( wnd->window_handle, WF_WORKXYWH, &xy[0], &xy[1], &xy[2], &xy[3] ) ;*/
  wnd->GetWorkXYWH( wnd, &xy[0], &xy[1], &xy[2], &xy[3] ) ;
  BasicDrawingHandler( wnd, xy ) ;
}

int GWBasicModalHandler(void)
{
  EVENT evnt ;
  int   which ;
  int   code, scode = 0 ;

  memset( &evnt, 0, sizeof(EVENT) ) ;
  evnt.ev_mflags = MU_KEYBD | MU_MESAG | MU_TIMER ;
  do
  {
    code = 0 ;
    which = EvntMulti( &evnt ) ;
    if ( which & MU_MESAG ) code = GeneralMesagHandler( &evnt ) ;
    if ( code != 0 )
      scode = code ;
    if ( which & MU_KEYBD ) code = GeneralKbdHandler( evnt.ev_mkreturn ) ;
    if ( code != 0 ) scode = code ;
  }
  while ( which != MU_TIMER ) ;

  return( scode ) ;
}

void GWShowWindow(GEM_WINDOW *wnd, int show)
{
  if ( show && ( ( wnd->flags & FLG_ISVISIBLE ) == 0 ) )
  {
    if ( wind_open( wnd->window_handle, wnd->vx, wnd->vy, wnd->vw, wnd->vh ) )
      wnd->flags |= FLG_ISVISIBLE ;
  }
  else if ( !show && ( wnd->flags & FLG_ISVISIBLE ) )
  {
    wind_get( wnd->window_handle, WF_CURRXYWH, &wnd->vx, &wnd->vy, &wnd->vw, &wnd->vh ) ;
    wind_close( wnd->window_handle ) ;
    wnd->flags &= ~FLG_ISVISIBLE ;
  }
}

void GWSetWindowCaption(GEM_WINDOW *wnd, char *caption)
{
  strncpy( wnd->window_name, caption, sizeof(wnd->window_name) ) ;
  wind_set( wnd->window_handle, WF_NAME, wnd->window_name ) ;
}

void GWSetWindowInfo(GEM_WINDOW *wnd, char *info)
{
  if ( ( wnd->window_kind & WF_INFO ) && strcmp( wnd->window_info, info ) )
  {
    strcpy( wnd->window_info, info ) ;
    wind_set( wnd->window_handle, WF_INFO, wnd->window_info ) ;
  }
}

void GWSetHSlider(GEM_WINDOW *wnd, int pos)
{
  if ( pos < 0 )    pos = 0 ;
  if ( pos > 1000 ) pos = 1000 ;
  wind_set( wnd->window_handle, WF_HSLIDE, pos ) ;
}

void GWSetVSlider(GEM_WINDOW *wnd, int pos)
{
  if ( pos < 0 )    pos = 0 ;
  if ( pos > 1000 ) pos = 1000 ;
  wind_set( wnd->window_handle, WF_VSLIDE, pos ) ;
}

void GWSetHSliderSize(GEM_WINDOW *wnd, int pos)
{
  if ( pos < 0 )    pos = 0 ;
  if ( pos > 1000 ) pos = 1000 ;
  wind_set( wnd->window_handle, WF_HSLSIZE, pos ) ;
}

void GWSetVSliderSize(GEM_WINDOW *wnd, int pos)
{
  if ( pos < 0 )    pos = 0 ;
  if ( pos > 1000 ) pos = 1000 ;
  wind_set( wnd->window_handle, WF_VSLSIZE, pos ) ;
}

void GWGetHSlider(GEM_WINDOW *wnd, int *pos)
{
  wind_get( wnd->window_handle, WF_HSLIDE, pos ) ;
}

void GWGetVSlider(GEM_WINDOW *wnd, int *pos)
{
  wind_get( wnd->window_handle, WF_VSLIDE, pos ) ;
}

void GWGetHSliderSize(GEM_WINDOW *wnd, int *size)
{
  wind_get( wnd->window_handle, WF_HSLSIZE, size ) ;
}

void GWGetVSliderSize(GEM_WINDOW *wnd, int *size)
{
  wind_get( wnd->window_handle, WF_VSLSIZE, size ) ;
}

void GWGetWorkXYWH(GEM_WINDOW *wnd, int *x, int *y, int *w, int *h )
{
  wind_get( wnd->window_handle, WF_WORKXYWH, x, y, w, h ) ;
}

void GWGetCurrXYWH(GEM_WINDOW *wnd, int *x, int *y, int *w, int *h )
{
  wind_get( wnd->window_handle, WF_CURRXYWH, x, y, w, h ) ;
}

void GWSetCurrXYWH(GEM_WINDOW *wnd, int x, int y, int w, int h )
{
  wind_set( wnd->window_handle, WF_CURRXYWH, x, y, w, h ) ;
  wnd->must_be_fulled = 1 ;
}

void GWRedraws(void)
{
  EVENT evnt ;
  int   which ;

  evnt.ev_mflags    = MU_MESAG | MU_TIMER ;
  evnt.ev_mtlocount = 0 ;
  evnt.ev_mthicount = 0 ;
  do
  {
    which = EvntMulti(&evnt) ;
    if ( ( which & MU_MESAG ) && ( evnt.ev_mmgpbuf[0] == WM_REDRAW ) )
    {
      GeneralMesagHandler( &evnt ) ;
    }
  }
  while ( which != MU_TIMER ) ;
}

int GWIsWindow(void)
{
  int is_window = IsListEmpty( &GemApp.GemWindowListHead ) ;

  if ( !is_window ) GemApp.CurrentGemWindow = NULL ;

  return( is_window ) ;
}

GEM_WINDOW *GWGetWindow(int x, int y)
{
  int wh ;

  wh = wind_find( x, y ) ;
  if ( wh > 0 ) return( GetWindowByHandle( wh ) ) ;
  else          return( NULL ) ;
}

void GWExit(void)
{
  LIST_ENTRY *entry ;
  GEM_WINDOW *wnd ;

  while ( !IsListEmpty( &GemApp.GemWindowListHead ) )
  {
    entry = GetHeadList( &GemApp.GemWindowListHead ) ;
    wnd   = GET_GEM_WINDOW_FROM_LIST_ENTRY( entry ) ;
    if ( wnd->OnClose ) wnd->OnClose( wnd ) ;
    else                GWOnClose( wnd ) ;
    if ( GWIsWindowValid( wnd ) ) DestroyWindow( wnd ) ;  /* Le OnClose modifie n'a pas fait son boulot ! */
    GWRedraws() ;
  }

  gem_exit() ;
}

int PostMessage(GEM_WINDOW *wnd, int id, int msg[4])
{
  int messag[8] ;

  messag[0] = id ;
  messag[1] = ap_id ;
  messag[2] = 0 ; /* Pas de surplus */
  messag[3] = wnd->window_handle ;
  if ( msg ) memcpy( &messag[4], msg, 4*sizeof(int) ) ;
  else       memset( &messag[4], 0, 4*sizeof(int) ) ;

  return( appl_write( ap_id, 16, messag ) ) ;
}

int SendMessage(GEM_WINDOW *wnd, int id, int msg[4])
{
  int messag[8] ;

  messag[0] = id ;
  messag[1] = ap_id ;
  messag[2] = 0 ; /* Pas de surplus */
  messag[3] = wnd->window_handle ;
  if ( msg ) memcpy( &messag[4], msg, 4*sizeof(int) ) ;
  else       memset( &messag[4], 0, 4*sizeof(int) ) ;

  return( appl_write( ap_id, 16, messag ) ) ;
}

void GWInvalidate(GEM_WINDOW *wnd)
{
  int msg[4] ;

  if ( wnd->flags & FLG_ISVISIBLE )
  {
    wnd->GetWorkXYWH( wnd, &msg[0], &msg[1], &msg[2], &msg[3] ) ;
    PostMessage( wnd, WM_REDRAW, msg ) ;
  }
}

void GWDestroyWindow(GEM_WINDOW *wnd)
{
  if ( GWIsWindowValid( wnd ) ) PostMessage( wnd, GWM_DESTROY, NULL ) ;
}

int GWSetWndRscIcon(GEM_WINDOW *wnd, int form, int id)
{
  USERBLK *userblk ;
  MFDB     new_icon ;
  CICONBLK *icnblk ;
  ICONBLK  *icnblk_mono ;
  OBJECT   *obj ;
  int      type ;
  int      err = 0 ;

  if ( Xrsrc_gaddr( R_TREE, form, &obj ) == 0 ) return( -1 ) ;
  type = obj[id].ob_type ;

  memset( &new_icon, 0, sizeof(MFDB) ) ;
  /* Recherche un icone dans la resolution courante */
  new_icon.fd_nplanes = nb_plane ;
  switch( type )
  {
    case G_ICON  : icnblk_mono = obj[id].ob_spec.iconblk ;
                   err         = Icon2MFDB( icnblk_mono, &new_icon ) ;
                   break ;

    case G_CICON   :
    case G_USERDEF : userblk = (USERBLK *) obj[id].ob_spec.index ;
                     if ( Sversion() < 0x3000 ) icnblk = (CICONBLK *) userblk->ub_parm ; /* Meme test que dans XRSRC.C */
                     else                       icnblk = obj[id].ob_spec.ciconblk ;      /* AES Falcon */
                     err    = Cicon2MFDB( icnblk, &new_icon ) ;
                     break ;

    default      : err = -1 ;
                   break ;
  }

  if ( !err )
  {
    if ( wnd->window_icon.fd_addr ) free( wnd->window_icon.fd_addr ) ;
    memcpy( &wnd->window_icon, &new_icon, sizeof(MFDB) ) ;
  }

  return( err ) ;
}

GEM_APP *GWGetApp(int argc, char **argv)
{
  GemApp.Argc = argc ;
  GemApp.Argv = argv ;

  return( &GemApp ) ;
}

void GWDeclareAndRunApp(GEM_APP *app)
{
  int n ;

  if ( gem_init() < 0 ) return ;

  InitializeListHead( &app->GemWindowListHead ) ;

  if ( app->OnInit ) app->OnInit( app ) ;
  if ( app->OnParseCmdLine ) app->OnParseCmdLine( app, app->Argc, app->Argv ) ;
  else if ( app->OnOpenFile )
  {
    for ( n = 1; n < app->Argc; n++ ) app->OnOpenFile( app->Argv[n] ) ;
  }

  GWSetMenuStatus(1) ;
  GWLoop() ;

  if ( app->OnTerminate ) app->OnTerminate( app ) ;

  GWExit() ;
}
