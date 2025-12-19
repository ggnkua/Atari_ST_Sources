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
#include "logging.h"
#include "chkstack.h"

#define GET_GEM_WINDOW_FROM_LIST_ENTRY(x) CONTAINING_RECORD((x), GEM_WINDOW, ListEntry)
#define GET_LIST_ENTRY_FROM_GEM_WINDOW(x) (&(x)->ListEntry)

GEM_APP GemApp ;


#define	DD_OK        0
#define DD_NAK       1
#define DD_EXT       2
#define DD_LEN       3
#define DD_TRASH     4
#define DD_PRINTER   5
#define DD_CLIPBOARD 6

void GWZeroDlgData(DLGDATA* data)
{
  memzero( data, sizeof(DLGDATA) ) ;
}

int GWIsWindowValid(GEM_WINDOW* wnd)
{
  int found = 0 ;

  if ( wnd )
  {
    LIST_ENTRY* sentry = GET_LIST_ENTRY_FROM_GEM_WINDOW( wnd ) ;
    LIST_ENTRY* entry = &GemApp.GemWindowListHead ;

    entry = entry->Flink ;
    while ( !found && (entry != &GemApp.GemWindowListHead) )
    {
      if ( entry == sentry ) found = 1 ;
      entry = entry->Flink ;
    }
  }

  return found ;
}
/* More elegant as search engine is same and only depends on a function to call (like qsort) */
static short FctGetWindowByHandle(GEM_WINDOW* wnd, void* p)
{
  return( wnd->window_handle == (int)p ) ;
}

static short FctGetWindowByClass(GEM_WINDOW* wnd, void* p)
{
  return( strcmp( wnd->ClassName, p ) == 0 ) ;
}

static short FctGetWindowByID(GEM_WINDOW* wnd, void* p)
{
  if ( wnd->GetWindowID && (strcmpi( wnd->GetWindowID(wnd), p ) == 0) ) return 1 ;
  return 0 ;
}

GEM_WINDOW* GWGetNextWindow(GEM_WINDOW* wnd)
{
  LIST_ENTRY* entry = &GemApp.GemWindowListHead ;
  GEM_WINDOW* next_window = NULL ;

  if ( wnd )
  {
    if ( GWIsWindowValid( wnd ) ) entry = GET_LIST_ENTRY_FROM_GEM_WINDOW( wnd ) ;
    else                          return next_window ;
  }
  entry = entry->Flink ;
  if ( entry != &GemApp.GemWindowListHead ) next_window = GET_GEM_WINDOW_FROM_LIST_ENTRY( entry ) ;

  return next_window ;
}

GEM_WINDOW* GetWindowBySomething(void* p, short (*FctGetWindow)(GEM_WINDOW* wnd, void* p) )
{
  LIST_ENTRY* entry = &GemApp.GemWindowListHead ;
  GEM_WINDOW* wnd ;
  GEM_WINDOW* wnd_found = NULL ;

  if ( handle < 0 ) return NULL ;

  entry = entry->Flink ;
  while ( (wnd_found == NULL) && (entry != &GemApp.GemWindowListHead) )
  {
    wnd   = GET_GEM_WINDOW_FROM_LIST_ENTRY( entry ) ;
    entry = entry->Flink ;
    if ( FctGetWindow( wnd, p ) ) wnd_found = wnd ;
  }

  return wnd_found ;
}

GEM_WINDOW* GetWindowByHandle(int handle)
{
  return GetWindowBySomething( (void*) handle, FctGetWindowByHandle ) ;
}

GEM_WINDOW* GWGetWindowByClass(char* class_name)
{
  return GetWindowBySomething( class_name, FctGetWindowByClass ) ;
}

GEM_WINDOW* GWGetWindowByID(char* name)
{
  return GetWindowBySomething( name, FctGetWindowByID ) ;
}

GEM_WINDOW* AllocateNewGemWindow(void)
{
  GEM_WINDOW* wnd = NULL ;

  if ( GemApp.NbGemWindows >= NB_MAX_GEM_WINDOWS ) return wnd ;

  wnd = (GEM_WINDOW*) Xcalloc( 1, sizeof(GEM_WINDOW) ) ;
  if ( wnd )
  {
    InsertHeadList( &GemApp.GemWindowListHead, &wnd->ListEntry ) ;
    GemApp.NbGemWindows++ ;
  }
  LoggingDo(LL_GW2,"AllocateNewGemWindow $%p, %d windows open", wnd, GemApp.NbGemWindows) ;

  return wnd ;
}

void DestroyWindow(GEM_WINDOW* wnd)
{
  if ( GWIsWindowValid( wnd ) )
  {
    GemApp.NbGemWindows-- ;
    LoggingDo(LL_GW2,"DestroyWindow $%p (handle %d), %d windows open", wnd, wnd->window_handle, GemApp.NbGemWindows) ;
    RemoveEntryList( GET_LIST_ENTRY_FROM_GEM_WINDOW( wnd ) ) ;
    if ( wnd->window_handle >= 0 )
    {
      if ( wnd->flags & FLG_ISVISIBLE ) wind_close( wnd->window_handle ) ;
      LoggingDo(LL_GW2,"wind_delete on handle %d", wnd->window_handle) ;
      wind_delete( wnd->window_handle ) ;
    }
    if ( wnd->window_icon.fd_addr ) Xfree( wnd->window_icon.fd_addr ) ;
    if ( wnd->Extension ) Xfree( wnd->Extension ) ;
    Xfree( wnd ) ;
  }
}

static char* GWInfoW(GEM_WINDOW* wnd)
{
  static char gwinfo_buffer[200] ; /* Hoping calls to this routine are not simultaneous */

  if ( wnd ) sprintf( gwinfo_buffer, "Window $%p, class %s", wnd, wnd->ClassName ) ;
  else       sprintf( gwinfo_buffer, "Window NULL" ) ;

  return gwinfo_buffer ;
}

int GWInModalDialog(void)
{
  int in_modal_dialog = 0 ;

  if ( GemApp.CurrentGemWindow && ( GemApp.CurrentGemWindow->flags & FLG_ISMODAL ) )
    in_modal_dialog = 1 ;

  return in_modal_dialog ;
}

int GWInDialog(void)
{
  int in_dialog = 0 ;

  if ( GemApp.CurrentGemWindow && GemApp.CurrentGemWindow->DlgData )
    in_dialog = 1 ;

  return in_dialog ;
}

static void ComputeMinTimer(void)
{
  LIST_ENTRY* entry = &GemApp.GemWindowListHead ;
  GEM_WINDOW* wnd ;
  long        min_timer = 0x7FFFFFFFL ; /* Big positive number */

  LoggingDo(LL_GW2, "ComputeMinTimer: help_bubbles=%d", GemApp.Flags.HelpBubbles) ;
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

  if ( GemApp.Flags.HelpBubbles && (min_timer > 1000L) ) /* Timer is set but help bubbles needs it to be smaller */
    min_timer = 1000L ;
    
  if ( min_timer != 0x7FFFFFFFL )
  {
    min_timer >>= 1 ; /* /2 just for accuracy */
    if ( min_timer == 0 ) min_timer = 1 ;
    GemApp.Event.ev_mflags   |= MU_TIMER ;
    GemApp.Event.ev_mtlocount = (int) ( min_timer ) ;
    GemApp.Event.ev_mthicount = (int) ( min_timer >> 16 ) ;
  }
  else GemApp.Event.ev_mflags &= ~MU_TIMER ;

  LoggingDo(LL_GW2, "ComputeMinTimer:%ldms", (GemApp.Event.ev_mflags & MU_TIMER) ? min_timer:-1L) ;
}

void GWSetTimer(GEM_WINDOW* wnd, long ms, void* context)
{
  clock_t t = clock() ;

  if ( wnd )
  {
    wnd->TimeOutMs = ms ;
    wnd->LastTick  = t ;
  }
  else
  {
    GemApp.TimeOutMs    = ms ;
    GemApp.TimerContext = context ;
    GemApp.LastTick     = t ;
  }

  ComputeMinTimer() ;
}

void GWKillTimer(GEM_WINDOW* wnd)
{
  if ( wnd ) wnd->TimeOutMs = -1 ;
  else       GemApp.TimeOutMs = -1 ;

  ComputeMinTimer() ;
}

void GWShowCursor(void)
{
  v_show_c ( handle, 1 ) ;
  /* NOTE: the explanation below should be correct but it leads to some cursor lost, too risky */
  /* Better use graf_mouse instead of v_show_c/v_hide_c, see https://freemint.github.io/tos.hyp/en/vdi_input.html#v_show_c */
  /* However graf_mouse must NOT be called when caller is in a user draw routine, only VDI must be used then               */
/*  if ( do_not_use_aes ) v_show_c ( handle, 1 ) ;
  else                 (void)graf_mouse( M_ON, NULL ) ;*/
}

void GWHideCursor(void)
{
  v_hide_c ( handle ) ;
  /* NOTE: the explanation below should be correct but it leads to some cursor lost, too risky */
  /* Better use graf_mouse instead of v_show_c/v_hide_c, see https://freemint.github.io/tos.hyp/en/vdi_input.html#v_show_c */
  /* However graf_mouse must NOT be called when caller is in a user draw routine, only VDI must be used then               */
  /*if ( do_not_use_aes ) v_hide_c ( handle ) ;
  else                  (void)graf_mouse( M_OFF, NULL ) ;*/
}

void GWMenuCheck(int citem)
{
  (void)menu_icheck( GemApp.Menu, citem, 1 ) ;
}
  
void GWMenuUncheck(int citem)
{
  (void)menu_icheck( GemApp.Menu, citem, 0 ) ;
}

/* Fonctions de base appellees par defaut si la fenetre ne le redefinit pas */
/* Peut etre appele depuis la routine qui a ete deroutee */
#pragma warn -par
void GWOnDraw(GEM_WINDOW* wnd, int xycoords[4])
{
  int index ;
  int xy[4] ;

  if ( !Truecolor ) index = 0 ;
  else
  {
    int rgb[3] = { 1000, 1000, 1000 } ;

    index = 19 ;
    svs_color( index, rgb ) ;
  }
  (void) svswr_mode( MD_REPLACE ) ;
  svsf_color( index ) ;
  svsf_interior( FIS_SOLID ) ;
  svsf_perimeter( 0 ) ;

  xy[0] = xycoords[0] ;
  xy[1] = xycoords[1] ;
  xy[2] = xycoords[0] + xycoords[2] - 1 ;
  xy[3] = xycoords[1] + xycoords[3] - 1 ;
  svr_recfl( xy ) ;
}

int GWOnUnTopped(GEM_WINDOW* wnd)
{
  return 0 ;
}
#pragma warn +par

int GWOnTopped(GEM_WINDOW* wnd)
{
  wind_set( wnd->window_handle, WF_TOP, 0, 0, 0 ) ;

  return 0 ;
}

GEM_WINDOW* GetTopWnd(void)
{
  int h_topped ;

  wind_get( 0, WF_TOP, &h_topped ) ;

  return( GetWindowByHandle( h_topped ) ) ;
}

int GWOnClose(GEM_WINDOW* wnd)
{
  DestroyWindow( wnd ) ;
  GemApp.CurrentGemWindow = GetTopWnd() ; /* WM_TOPPED n'est pas envoye ensuite sous certains vieux TOS */

  return GW_EVTCONTINUEROUTING ;
}

void GWOnMove(GEM_WINDOW* wnd, int xywh[4])
{
  wind_set( wnd->window_handle, WF_CURRXYWH, xywh[0], xywh[1], xywh[2], xywh[3] ) ;
}
 
void GWOnHSlider(GEM_WINDOW* wnd, int pos)
{
  wind_set( wnd->window_handle, WF_HSLIDE, pos ) ;
}
 
void GWOnVSlider(GEM_WINDOW* wnd, int pos)
{
  wind_set( wnd->window_handle, WF_VSLIDE, pos ) ;
}

void GWOnSize(GEM_WINDOW* wnd, int xywh[4])
{
  GWOnMove( wnd, xywh ) ;

  wnd->must_be_fulled = 1 ;
  GWRePaint( wnd ) ;
}
 
int GWOnFulled(GEM_WINDOW* wnd, int xywh[4])
{
  if ( xywh ) GWOnMove( wnd, xywh ) ;
  else        wind_set( wnd->window_handle, WF_CURRXYWH, xdesk, ydesk, wdesk, hdesk ) ;

  wnd->must_be_fulled = 0 ;
  GWInvalidate( wnd ) ;

  return 0 ;
}
 
int GWOnRestoreFulled(GEM_WINDOW* wnd, int xywh[4])
{
  int x, y, w, h ;

  if ( xywh )
  {
    x = xywh[0] ; y = xywh[1] ;
    w = xywh[2] ; h = xywh[3] ;
  }
  else wind_get( wnd->window_handle, WF_PREVXYWH, &x, &y, &w, &h ) ;
  wind_set( wnd->window_handle, WF_CURRXYWH, x, y, w, h ) ;

  wnd->must_be_fulled = 1 ;
  GWInvalidate( wnd ) ;
  
  return 0 ;
}

int GWOnIconify(GEM_WINDOW* wnd, int xywh[4])
{
  int x, y, w, h ;

  wnd->is_icon = 1 ;
  wind_get( wnd->window_handle, WF_CURRXYWH, &x, &y, &w, &h ) ;
  wnd->xywh_bicon[0] = x ; wnd->xywh_bicon[1] = y ;
  wnd->xywh_bicon[2] = w ; wnd->xywh_bicon[3] = h ;
  form_dial( FMD_SHRINK, xywh[0], xywh[1], xywh[2], xywh[3], x, y, w, h ) ;
  wind_set( wnd->window_handle, WF_ICONIFY, xywh[0], xywh[1], xywh[2], xywh[3] ) ;

  return 0 ;
}

int GWOnUnIconify(GEM_WINDOW* wnd, int xywh[4])
{
  int x, y, w, h ;

  wnd->is_icon = 0 ;
  wind_get( wnd->window_handle, WF_WORKXYWH, &x, &y, &w, &h ) ;
  form_dial( FMD_GROW, x, y, w, h, xywh[0], xywh[1], xywh[2], xywh[3] ) ;
  wind_set( wnd->window_handle, WF_UNICONIFY, xywh[0], xywh[1], xywh[2], xywh[3] ) ;

  return 0 ;
}

#pragma warn -par
int GWOnKeyPressed(int key)
{
  return 0 ;
}

int GWOnMenuSelected(int t_id, int m_id)
{
  if ( GemApp.Menu ) menu_tnormal( GemApp.Menu, t_id, 1 ) ;

  return 0 ;
}
#pragma warn +par

int CursorKeyToArrowAction(int key)
{
  int action = -1 ; /* As WA_... start with 0 */
/* Using arrays does not save bytes, so let's keep switch/case
  int keys[] =    { CURSOR_UP, CURSOR_PUP, CURSOR_LSUP, CURSOR_RSUP, CURSOR_DN, CURSOR_PDN, CURSOR_LSDN, CURSOR_RSDN, CURSOR_RT, CURSOR_LSRT, CURSOR_RSRT, CURSOR_LT, CURSOR_LSLT, CURSOR_RSLT } ;
  int actions[] = { WA_UPLINE, WA_UPPAGE,  WA_UPPAGE,   WA_UPPAGE,   WA_DNLINE, WA_DNPAGE,  WA_DNPAGE,   WA_DNPAGE,   WA_RTLINE, WA_RTPAGE,   WA_RTPAGE,   WA_LFLINE, WA_LFPAGE,   WA_LFPAGE } ;
  int i ;

  for ( i = 0; i < ARRAY_SIZE(keys); i++ )
    if ( key == keys[i] ) action = actions[i] ;
*/

  switch( key )
  {
    case CURSOR_UP:   action = WA_UPLINE ;
                      break ;

    case CURSOR_PUP:
    case CURSOR_SUP:  action = WA_UPPAGE ;
                      break ;

    case CURSOR_DN:   action = WA_DNLINE ;
                      break ;

    case CURSOR_PDN:
    case CURSOR_SDN:  action = WA_DNPAGE ;
                      break ;

    case CURSOR_RT  : action = WA_RTLINE ;
                      break ;

    case CURSOR_SRT:  action = WA_RTPAGE ;
                      break ;

    case CURSOR_LT  : action = WA_LFLINE ;
                      break ;

    case CURSOR_SLT:  action = WA_LFPAGE ;
                      break ;
  }

  return action ;
}

static int translate_kcode(int key, int kstate)
{
  int translated = (kstate << 8) ; /* Copy shift/control/alt information */
  int scan_code  = SCANCODE(key) ;
  int ascii_code = ASCIICODE(key) ;

  /* First 1...0 row is often different on keyboards, here we will  */
  /* Use scan code to encode the translated key code                */
  if ( (ascii_code ==0) || ( (scan_code >= 0x02) && (scan_code <= 0x0B) ) )
    translated |= (K_SCAN << 8) | scan_code ; /* Scan code to retain + SCAN bit to distinguish for switch() to come */
  else
    translated |= ascii_code ; /* ASCII code to retain */

  LoggingDo(LL_DEBUG, "key code $%04X, kstate $%02X translated to $%04X", key, kstate, translated) ;
  
  return translated ;
}

static int is_cursor_key(int key)
{
  int  cursorkeys[] = { CURSOR_UP, CURSOR_SUP, CURSOR_DN, CURSOR_SDN, CURSOR_RT, CURSOR_SRT, CURSOR_PUP, CURSOR_PDN, CURSOR_LT, CURSOR_SLT, 0 } ;
  int* pkey = &cursorkeys[0] ;

  while ( *pkey )
  {
    if ( key == *pkey ) break ;
    pkey++ ;
  }

  return *pkey ;
}

int GeneralKbdHandler(int key)
{
  GEM_WINDOW* cur_window = GemApp.CurrentGemWindow ;
  int         code = GW_EVTCONTINUEROUTING ;
  int         action ;
  int         dummy, kstate ;

  LoggingDo(LL_KEYCODE, "Key $%04X pressed", key) ;
  graf_mkstate( &dummy, &dummy, &dummy, &kstate ) ;
  if ( cur_window ) cur_window->original_key = key ;
  key = translate_kcode( key, kstate ) ;

  GWSetMenuStatus( 0 ) ;

  if ( cur_window )
  {
     if ( cur_window->OnArrow && is_cursor_key( cur_window->original_key ) )
    {
      action = CursorKeyToArrowAction( cur_window->original_key ) ;
      code   = cur_window->OnArrow( cur_window, action ) ;
    }
    if ( (code == GW_EVTCONTINUEROUTING) && cur_window->OnKeyPressed ) code = cur_window->OnKeyPressed( cur_window, key ) ;
 }

  if ( code == GW_EVTCONTINUEROUTING )
  {
    if ( GemApp.OnKeyPressed ) code = GemApp.OnKeyPressed( key ) ;
    else                       code = GWOnKeyPressed( key ) ;
  }

  if ( !GWInModalDialog() )
  {
    if ( GemApp.OnUpdateGUI ) GemApp.OnUpdateGUI() ;
    else                      GWSetMenuStatus( 1 ) ;
  }

  return code ;
}

static void GW2LoggingDoFor(GEM_WINDOW* wnd, char* str)
{
  char buffer[512] ;

  strcpy( buffer, str ) ;
  strcat( buffer, " for %s" ) ;  
  LoggingDo(LL_GW2, buffer, GWInfoW(wnd) ) ;
}

void BasicDrawingHandler(GEM_WINDOW* wnd, int pxy[4])
{
  int xyarray[4] ;
  int xywh[4] ;
  int xy[8] ;
  int x, y, w, h ;
  int xi,yi, wx, wy ;
  int rx, ry, rw, rh ;
  int xoffset, yoffset ;

  GW2LoggingDoFor(wnd, "Begin redraw request") ;
  wind_update( BEG_UPDATE ) ;

  x = pxy[0] ; y = pxy[1] ;
  w = pxy[2] ; h = pxy[3] ;
  wind_get( wnd->window_handle, WF_WORKXYWH, &xi, &yi, &wx, &wy ) ;
  wind_get( wnd->window_handle, WF_FIRSTXYWH, &rx, &ry, &rw, &rh ) ;

  if ( wnd->is_icon && ( (wx > wnd->window_icon.fd_w) || (wy > wnd->window_icon.fd_h) ) )
  {
    MFDB new_icon ;

    /* If icon is smaller than client area, update */
    /* The icon and center it on the client area   */
    if ( wnd->window_icon.fd_addr )
    {
      CopyMFDB( &new_icon, &wnd->window_icon ) ;
      new_icon.fd_w = wx ;
      new_icon.fd_h = wy ;
      new_icon.fd_wdwidth = W2WDWIDTH( new_icon.fd_w ) ;
      new_icon.fd_addr    = img_alloc( new_icon.fd_w, new_icon.fd_h, new_icon.fd_nplanes ) ;
    }
    else new_icon.fd_addr = NULL ;
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
      svro_cpyfmSO( xy, &wnd->window_icon, &new_icon ) ;
      Xfree( wnd->window_icon.fd_addr ) ;
      CopyMFDB( &wnd->window_icon, &new_icon ) ;
    }
  }

  GWHideCursor() ;
  while ( rw != 0 )
  {
    if ( intersect( x, y, w, h, rx, ry, rw, rh, xyarray ) )
    {
      /* intersect renvoie des coordonnees et non des largeurs... */
      memcpy( xywh, xyarray, sizeof(xyarray) ) ;
      xywh[2] = 1 + xywh[2] - xywh[0] ;
      xywh[3] = 1 + xywh[3] - xywh[1] ;

      if ( wnd->is_icon && wnd->window_icon.fd_addr )
      {
        xoffset = xyarray[0] - xi ; yoffset = xyarray[1] - yi ;
        xy[0]   = xoffset ; xy[1] = yoffset ;
        xy[2]   = xy[0] + xywh[2] - 1 ;
        xy[3]   = xy[1] + xywh[3] - 1 ;
        xy[4]   = xyarray[0] ; xy[5] = xyarray[1] ;
        xy[6]   = xy[4] + xy[2] - xy[0] ;
        xy[7]   = xy[5] + xy[3] - xy[1] ;
        svro_cpyfmSOS( xy, &wnd->window_icon ) ;
      }
      else if ( wnd->is_icon ) GWOnDraw( wnd, xywh ) ; /* Champ icon  non valide */
      else
      {
        if ( wnd->flags & FLG_MUSTCLIP ) svs_clipON( xyarray ) ;
        if ( wnd->OnDraw ) wnd->OnDraw( wnd, xywh ) ;
        else               GWOnDraw( wnd, xywh ) ;
        if ( wnd->flags & FLG_MUSTCLIP ) svs_clipOFF( xyarray ) ;

      }
    }
	  wind_get( wnd->window_handle, WF_NEXTXYWH, &rx, &ry, &rw, &rh ) ;
  }
  GWShowCursor() ;

  wind_update( END_UPDATE ) ;
  GW2LoggingDoFor(wnd, "End redraw request") ;
}

int BasicMenuHandler(int* mesag)
{
  int code = GW_EVTCONTINUEROUTING ;

  if ( !GWInModalDialog() )
  {
    GWSetMenuStatus( 0 ) ;
    if ( GemApp.CurrentGemWindow && GemApp.CurrentGemWindow->OnMenuSelected )
    {
      LoggingDo(LL_GW2, "Menu Selected for %s, t_id $%x, m_id $%x", GWInfoW(GemApp.CurrentGemWindow), mesag[3], mesag[4] ) ;
      code = GemApp.CurrentGemWindow->OnMenuSelected( GemApp.CurrentGemWindow, mesag[3], mesag[4] ) ;
    }

    if ( code == GW_EVTCONTINUEROUTING )
    {
      LoggingDo(LL_GW2, "Menu Selected for application, t_id $%x, m_id $%x", mesag[3], mesag[4] ) ;
      if ( GemApp.OnMenuSelected ) code = GemApp.OnMenuSelected( mesag[3], mesag[4] ) ;
      else                         code = GWOnMenuSelected( mesag[3], mesag[4] ) ;
    }
  }

  return code ;
}

static char* ddGetPipeFileName(int pipe_id, char* pipe_filename)
{
  static char tpipename[] = "U:\\PIPE\\DRAGDROP.AA" ;

  strcpy( pipe_filename, tpipename ) ;
  pipe_filename[17] = pipe_id >> 8 ;
  pipe_filename[18] = pipe_id & 0xFF ;

  return pipe_filename ;
}

static long ddOpenFD(int pipe_id)
{
  char pipename[64] ;
  long fd ;

  (void)ddGetPipeFileName( pipe_id, pipename ) ;
  fd = Fopen( pipename, 2 ) ;
  if ( fd < 0 ) LoggingDo(LL_ERROR, "DRAGDROP error: can't open pipe %s", pipename ) ;

  return fd ;
}

static void ddstatus(long fd, char status)
{
  char c = status ; /* Because looks weird to take address of a variable passed as value */

  LoggingDo(LL_DEBUG, "DRAGDROP, sending status %d", c ) ;
  Fwrite( fd, 1, &c ) ;
}

static int DDTypeKnown(long type, long* types)
{
  int known = 0 ;
  int i ;

  for ( i = 0; i < 8; i++ )
    if ( types[i] == type ) { known = 1 ; break ; }

  return known ;
}

static short DDIsTypeSupported(long* accepted_types)
{
  long* type = accepted_types ;

  while ( type < accepted_types+8 )
    if ( *type++ != 0L ) return 1 ;

  return 0 ;
}

static short GWDDBuildARGS(DD_DATA* dd_data)
{
  char* pt = dd_data->data ;
  char* cur_cmd = pt ;
  char* last_quote ;
  short in_quotes ;

  /* Possibly more than real number of cmds (filename may contain space character) but we don't care */
  dd_data->args.cmds = Xcalloc( 1+count_char( dd_data->data, ' ' ), sizeof(char*) ) ;
  if ( dd_data->args.cmds == NULL ) return -1 ;

  /* Setup args structure in dd_data to ease access to cmds */
  /* Note that original data received from DD is changed    */
  /* As transformation is performed in place                */
  dd_data->args.ncmds = 0 ;
  last_quote          = NULL ;
  in_quotes           = 0 ;
  while ( *pt )
  {
    switch( *pt )
    {
      case '\"':
      case '\'': if ( (*(pt+1) == ' ' ) || (*(pt+1) == 0 ) )
                 {
                   in_quotes = 0 ;
                   *pt++ = 0 ;
                   dd_data->args.cmds[dd_data->args.ncmds++] = cur_cmd ;
                   while ( *pt == ' ' ) pt++ ;
                   cur_cmd = pt ;
                 }
                 else
                 {
                   in_quotes   = 1 ;
                   last_quote  = pt ;
                 }
                 pt++ ;
                 break ;

      case ' ':  if ( !in_quotes )
                 {
                   *pt++ = 0 ;
                   dd_data->args.cmds[dd_data->args.ncmds++] = cur_cmd ;
                   cur_cmd = pt ;
                 }
                 else pt++ ;
                 break ;

      default:   if ( last_quote == pt-1 ) cur_cmd = pt ;
                 pt++ ;
                 break ;
    }
  }
  if ( (*(pt-1) != ' ') && (*(pt-1) != 0) ) /* Ease terminates with a last space, not Thing! */
  {
    *pt++ = 0 ;
    dd_data->args.cmds[dd_data->args.ncmds++] = cur_cmd ;
  }

  return 0 ;
}

short GWAllocDDData(DD_DATA* dd_data)
{
  dd_data->data = Xcalloc( 1, dd_data->header.data_size + 2  ) ; /* Make sure we have 2 \0 at the end for safety */
  if ( dd_data->data == NULL ) return -1 ;

  if ( dd_data->header.type == 'ARGS' )
  {
    /* Possibly more than real number of cmds (filename may contain space character) but we don't care */
    dd_data->args.cmds = Xcalloc( 1+count_char( dd_data->data, ' ' ), sizeof(char*) ) ;
    if ( dd_data->args.cmds == NULL )
    {
      Xfree( dd_data->data ) ; dd_data->data = NULL ;
      return -2 ;
    }
  }

  return 0 ;
}

static int GWHandleDD(GEM_WINDOW* wnd, int* messag)
{
  DD_DATA* dd_data = NULL ;
  int      (*OnDD)(DD_DATA* dd_data) ;
  long*    accepted_types ;
  long     fd ;
  short    send_nack = 1 ;
  short    use_app_handler = 1 ;

  fd = ddOpenFD( messag[7] ) ;
  if ( fd < 0 ) return 0 ;

  if ( wnd )
  {
    /* Check if this window accepts Drap'n'Drop */
    accepted_types = &wnd->DragDrop.data_types[0] ;
    OnDD           = wnd->DragDrop.OnDD ;
    if ( OnDD && DDIsTypeSupported( accepted_types ) ) use_app_handler = 0 ; /* OK, window accepts DD */
  }

  if ( use_app_handler )
  {
    /* Note that app can decide to handle DD for a window, so keep wnd information below with dd_data.wnd_or_app */
    accepted_types = &GemApp.DragDrop.data_types[0] ;
    OnDD           = GemApp.DragDrop.OnDD ;
  }

  if ( DDIsTypeSupported( accepted_types ) )
  {
    dd_data = (DD_DATA*) Xcalloc( 1, sizeof(DD_DATA) ) ;
    if ( dd_data )
    {
      char buffer[512] ;

      memzero( buffer, sizeof(buffer) ) ;
      ddstatus( fd, DD_OK ) ;
      Fwrite( fd, 32, accepted_types ) ;
      while ( Fread( fd, 10, &dd_data->header ) == 10 )
      {
        LoggingDo(LL_DEBUG, "DRAGDROP, header size: %d", dd_data->header.size ) ;
        LoggingDo(LL_DEBUG, "DRAGDROP, type       : %s", long2ASC(dd_data->header.type) ) ;
        LoggingDo(LL_DEBUG, "DRAGDROP, data size  : %ld", dd_data->header.data_size ) ;
        if ( dd_data->header.size > sizeof(buffer)-8 ) dd_data->header.size = sizeof(buffer)-8 ;
        Fread( fd, dd_data->header.size-8, buffer ) ;
        strncpy( dd_data->header.name, buffer, sizeof(dd_data->header.name)-1 ) ;
        strncpy( dd_data->header.filename, buffer+strlen( dd_data->header.name )+1, sizeof(dd_data->header.filename)-1 ) ;
        LoggingDo(LL_DEBUG, "DRAGDROP, name       : %s", dd_data->header.name ) ;
        LoggingDo(LL_DEBUG, "DRAGDROP, filename   : %s", dd_data->header.filename ) ;
        if ( DDTypeKnown( dd_data->header.type, accepted_types ) )
        {
          LoggingDo(LL_DEBUG, "DRAGDROP, type %s accepted", long2ASC(dd_data->header.type) ) ;
          send_nack = 0 ;
          dd_data->data = Xcalloc( 1, dd_data->header.data_size + 2  ) ; /* Make sure we have 2 \0 at the end for safety */
          if ( dd_data->data )
          {
            ddstatus( fd, DD_OK ) ;
            Fread( fd, dd_data->header.data_size, dd_data->data ) ;
            dd_data->wnd_or_app = wnd ;
            dd_data->mx         = messag[4] ;
            dd_data->my         = messag[5] ;
            dd_data->kstate     = messag[6] ;
            LoggingDo(LL_DEBUG, "DRAGDROP, mx=%d, my=%d, kstate=$%x", dd_data->mx, dd_data->my, dd_data->kstate ) ;
            if ( dd_data->header.type == 'ARGS' ) GWDDBuildARGS( dd_data ) ;
            if ( OnDD ) OnDD( dd_data ) ;
            break ;
          }
          else ddstatus( fd, DD_EXT ) ;
        }
        else ddstatus( fd, DD_EXT ) ;
      }
    }
    else LoggingDo(LL_ERROR, "DRAGDROP, not enough memory" ) ;
  }
  else LoggingDo(LL_DEBUG, "DRAGDROP, No type to report to initiator" ) ;

  if ( send_nack )
  {
    if ( dd_data ) Xfree( dd_data ) ;
    /* We don't have any type to handle or none supported by initiator */
    LoggingDo(LL_DEBUG, "DRAGDROP, NACK returned" ) ;
    ddstatus( fd, DD_NAK ) ; /* Negative Acknowledge to avoid time-out */
  }

  Fclose( fd ) ;

  return 0 ;
}

void GWDDAddType(GEM_WINDOW* wnd, long type)
{
  long* accepted_types ;
  int   i ;

  if ( wnd ) accepted_types = &wnd->DragDrop.data_types[0] ;
  else       accepted_types = &GemApp.DragDrop.data_types[0] ;

  for ( i = 0; i < ARRAY_SIZE(wnd->DragDrop.data_types); i++ ) /* DD_INFO is part of GEM_WINDOW and GEM_APP */
    if ( accepted_types[i] == 0L ) { accepted_types[i] = type ; break ; }
}

int GeneralMesagHandler(EVENT* event)
{
  GEM_WINDOW* wnd, *cur_wnd ;
  int*        mesag  = event->ev_mmgpbuf ;
  int         code   = 0 ;
  int         err, top_done = 0 ;
  int         update_gui = 0 ;
  int         in_modal_dialog = GWInModalDialog() ;
  int         in_dialog = 1 ;
  char        file[PATH_MAX] ;
  char*       pfile ;

  if ( !in_modal_dialog ) in_dialog = GWInDialog() ;

  cur_wnd = GemApp.CurrentGemWindow ;
  wnd     = GetWindowByHandle( mesag[3] ) ;
  if ( in_dialog && cur_wnd )
  {
    DIALOG* dlg = cur_wnd->DlgData ;
    int     h_topped ;

    wind_get( cur_wnd->window_handle, WF_TOP, &h_topped ) ;
    if ( h_topped == cur_wnd->window_handle ) dlg->ShowEdit = 1 ;
    else                                      dlg->ShowEdit = 0 ;
  }

  switch( mesag[0] )
  {
    case MN_SELECTED:  code = BasicMenuHandler( mesag ) ;
                       update_gui = 1 ;
                       break ;

    case WM_REDRAW:    if ( wnd ) BasicDrawingHandler( wnd, &mesag[4] ) ;
                       break ;

/*    case WM_NEWTOP:
      case WM_ONTOP:    This makes myAES sending WM_TOPPED/WM_ONTOP endlessly */
    case WM_TOPPED:    GW2LoggingDoFor(wnd, "WM_TOPPED") ;
                       if ( wnd && ( !in_modal_dialog || (wnd == cur_wnd) ) )
                       {
                         if ( wnd->OnTopped ) top_done = ( wnd->OnTopped( wnd ) == 0 ) ;
                         else                 top_done = ( GWOnTopped( wnd ) == 0 ) ;
                       }
                       else top_done = 0 ;
                       if ( top_done ) GemApp.CurrentGemWindow = wnd ;
                       update_gui = 1 ;
                       break ;

    case WM_UNTOPPED:  GW2LoggingDoFor(wnd, "WM_UNTOPPED") ;
                       if ( wnd && ( !in_modal_dialog || ( wnd == cur_wnd ) ) )
                       {
                         if ( wnd->OnUnTopped ) top_done = ( wnd->OnUnTopped( wnd ) == 0 ) ;
                         else                   top_done = ( GWOnUnTopped( wnd ) == 0 ) ;
                       }
                       else top_done = 0 ;
                       if ( top_done ) GemApp.CurrentGemWindow = GetTopWnd() ;
                       update_gui = 1 ;
                       break ;

    case WM_CLOSED:    if ( !in_modal_dialog || (wnd == cur_wnd) )
    case GWM_DESTROY:  {
                         if ( wnd )
                         {
                           GW2LoggingDoFor(wnd, "WM_CLOSED or GWM_DESTROY" ) ;
                           if ( wnd->OnClose ) code = wnd->OnClose( wnd ) ;
                           else                code = GWOnClose( wnd ) ;
                           if ( in_modal_dialog && (code == IDCANCEL) ) code = GW_EVTQUITAPP ; /* Sortie de DoModal */
                         }
                       }
                       update_gui = 1 ;
                       break ;

    case WM_MOVED:     GW2LoggingDoFor(wnd, "WM_MOVED") ;
                       if ( wnd )
                       {
                         if ( wnd->OnMove ) wnd->OnMove( wnd, &mesag[4] ) ;
                         else               GWOnMove( wnd, &mesag[4] ) ;
                       }
                       break ;

    case WM_HSLID:     GW2LoggingDoFor(wnd, "WM_HSLID") ;
                       if ( wnd )
                       {
                         if ( wnd->OnHSlider ) wnd->OnHSlider( wnd, mesag[4] ) ;
                         else                  GWOnHSlider( wnd, mesag[4] ) ;
                       }
                       break ;

    case WM_VSLID:     GW2LoggingDoFor(wnd, "WM_VSLID") ;
                       if ( wnd )
                       {
                         if ( wnd->OnVSlider ) wnd->OnVSlider( wnd, mesag[4] ) ;
                         else                  GWOnVSlider( wnd, mesag[4] ) ;
                       }
                       break ;

    case WM_SIZED:     GW2LoggingDoFor(wnd, "WM_SIZED") ;
                       if ( wnd )
                       {
                         if ( wnd->OnSize ) wnd->OnSize( wnd, &mesag[4] ) ;
                         else               GWOnSize( wnd, &mesag[4] ) ;
                       }
                       break ;

    case WM_FULLED:    GW2LoggingDoFor(wnd, "WM_FULLED") ;
                       if ( wnd )
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

    case WM_ARROWED:   GW2LoggingDoFor(wnd, "WM_ARROWED") ;
                       if ( wnd && wnd->OnArrow ) wnd->OnArrow( wnd, mesag[4] ) ;
                       break ;

    case WM_ICONIFY:   GW2LoggingDoFor(wnd, "WM_ICONIFY") ;
                       if ( wnd )
                       {
                         if ( wnd->OnIconify ) wnd->OnIconify( wnd, &mesag[4] ) ;
                         else                  GWOnIconify( wnd, &mesag[4] ) ;
                       }
                       update_gui = 1 ;
                       break ;

    case WM_UNICONIFY: GW2LoggingDoFor(wnd, "WM_UNICONIFY") ;
                       if ( wnd )
                       {
                         if ( wnd->OnUnIconify ) wnd->OnUnIconify( wnd, wnd->xywh_bicon ) ;
                         else                    GWOnUnIconify( wnd, wnd->xywh_bicon ) ;
                       }
                       update_gui = 1 ;
                       break ;

    case WM_VASTART:   GW2LoggingDoFor(wnd, "WM_VASTART") ;
                       pfile = *(char **) &mesag[3] ;
                       do
                       {
                         pfile = GetNextVaStartFileName( pfile, file ) ;
                         if ( file[0] && GemApp.OnOpenFile ) GemApp.OnOpenFile( file ) ;
                       }
                       while ( pfile && file[0] ) ;
                       break ;

    case AP_DRAGDROP:  GW2LoggingDoFor(wnd, "AP_DRAGDROP received") ;
                       /* Let's first check if application claims full control over Drag&Drop protocol */
                       if ( wnd && wnd->OnDragDrop ) code = wnd->OnDragDrop( wnd, mesag[4], mesag[5], mesag[6], mesag[7] ) ;
                       else if ( GemApp.OnDragDrop ) code = GemApp.OnDragDrop( &GemApp, mesag[4], mesag[5], mesag[6], mesag[7] ) ;
                       else                          code = GWHandleDD( wnd, mesag ) ; /* GWLib support requested */
                       break ;

    case AP_TERM:      code = GW_EVTQUITAPP ;
                       break ;

    default:           if ( (mesag[0] >= WM_USER_FIRST) && (mesag[0] <= WM_USER_LAST) )
                       {
                         LoggingDo(LL_GW2, "WM_USER $%x for %s", mesag[0], GWInfoW(wnd) ) ;
                         if ( wnd && wnd->OnMsgUser ) code = wnd->OnMsgUser( wnd, mesag[0], &mesag[4] ) ;
                         else if ( GemApp.OnMsgUser ) code = GemApp.OnMsgUser( &GemApp, mesag[0], &mesag[4] ) ;
                       }
                       else
                       {
                         LoggingDo(LL_GW2, "Unknown message id %d", mesag[0] ) ;
                         if ( GemApp.OnUnknownMsg ) code = GemApp.OnUnknownMsg( &GemApp, mesag ) ;
                       }
                       break ;
  }

  if ( !GWInModalDialog() && update_gui )
  {
    if ( GemApp.OnUpdateGUI ) GemApp.OnUpdateGUI() ;
    else                      GWSetMenuStatus( 1 ) ;
  }

  return code ;
}

int GeneralButtonHandler(EVENT* event)
{
  GEM_WINDOW* wnd ;
  int         wh, mx, my ;
  int         wx, wy, dummy ;
  int         code = GW_EVTCONTINUEROUTING ;

  mx = event->ev_mmox ;
  my = event->ev_mmoy ;
  wh = wind_find( mx, my ) ;
  if ( GWInModalDialog() && (wh != GemApp.CurrentGemWindow->window_handle) ) return GW_EVTCONTINUEROUTING ;

  if ( wh == 0 )
  {
    /* Sent back to application */
    LoggingDo(LL_GW2, "MU_BUTTON for application, ev_mbreturn=%d, ev_mmobutton=%d, ev_mmokstate=%d at (%d,%d)", event->ev_mbreturn, event->ev_mmobutton, event->ev_mmokstate, mx, my ) ;
    if ( event->ev_mbreturn > 1 )
    {
      if ( GemApp.OnDLButtonDown && (event->ev_mmobutton & 1) )
        code = GemApp.OnDLButtonDown( event->ev_mmokstate, mx, my) ;
      if ( GemApp.OnDRButtonDown && (event->ev_mmobutton & 2) )
        code = GemApp.OnDRButtonDown( event->ev_mmokstate, mx, my ) ;
    }
    else
    {
      if ( GemApp.OnLButtonDown && (event->ev_mmobutton & 1) )
        code= GemApp.OnLButtonDown( event->ev_mmokstate, mx, my ) ;
      if ( GemApp.OnRButtonDown && (event->ev_mmobutton & 2) )
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
      LoggingDo(LL_GW2, "MU_BUTTON for %s, ev_mbreturn=%d, ev_mmobutton=%d, ev_mmokstate=%d at relative (%d,%d)", GWInfoW(wnd), event->ev_mbreturn, event->ev_mmobutton, event->ev_mmokstate, mx, my ) ;
      if ( event->ev_mbreturn > 1 )
      {
        if ( wnd->OnDRButtonDown && (event->ev_mmobutton & 2) )
          code = wnd->OnDRButtonDown( wnd, event->ev_mmokstate, mx, my ) ;
        else if ( wnd->OnDLButtonDown )
        {
          if ( (event->ev_mmobutton & 1) == 0 ) LoggingDo(LL_GW2, "GeneralButtonHandler;calling OnDLButtonDown even if left button (ev_mmobutton) is not set") ;
          code = wnd->OnDLButtonDown( wnd, event->ev_mmokstate, mx, my ) ;
        }
      }
      else
      {
        if ( wnd->OnRButtonDown && (event->ev_mmobutton & 2) )
          code = wnd->OnRButtonDown( wnd, event->ev_mmokstate, mx, my ) ;
        else if ( wnd->OnLButtonDown )
        {
          if ( (event->ev_mmobutton & 1) == 0 ) LoggingDo(LL_GW2, "GeneralButtonHandler;calling OnLButtonDown even if left button (ev_mmobutton) is not set") ;
          code= wnd->OnLButtonDown( wnd, event->ev_mmokstate, mx, my ) ;
        }
      }
    }
  }

  if ( !GWInModalDialog() )
  {
    if ( GemApp.OnUpdateGUI ) GemApp.OnUpdateGUI() ;
    else                      GWSetMenuStatus( 1 ) ;
  }

  return code ;
}

int GeneralMouseHandler(EVENT* event)
{
  static GEM_WINDOW* last_gwnd = NULL ;
  GEM_WINDOW*        cur_window ;
  int                bbutton, mk_state, mx, my ;
  int                window_top ;
  int                xi, yi, wx, wy ;

  mx         = event->ev_mmox ;
  my         = event->ev_mmoy ;
  bbutton    = event->ev_mmobutton ;
  mk_state   = event->ev_mmokstate ;
  cur_window = GemApp.CurrentGemWindow ;

  if ( cur_window && cur_window->OnMouseMove )
  {
    wind_get( 0, WF_TOP, &window_top ) ;
    if ( cur_window->window_handle == window_top )
    {
      GWGetWorkXYWH( cur_window, &xi, &yi, &wx, &wy ) ;
      mx -= xi ; my -= yi ;
      if ( (my < 0) || (mx >= wx) || (my >= wy) ) mx = my = -1 ;

      if ( mx != -1 )
      {
        LoggingDo(LL_GW1, "MU_M1 in %s, ev_mmobutton=%d, ev_mmokstate=%d at (%d,%d)", GWInfoW(cur_window), bbutton, mk_state, mx, my ) ;
        cur_window->OnMouseMove( cur_window, bbutton, mk_state, mx, my ) ;
        cur_window->KnowMouseIsOut = 0 ;
      }
      else if ( !cur_window->KnowMouseIsOut )
      {
        LoggingDo(LL_GW1, "MU_M1 out %s, ev_mmobutton=%d, ev_mmokstate=%d at (%d,%d)", GWInfoW(cur_window), bbutton, mk_state, mx, my ) ;
        cur_window->OnMouseMove( cur_window, bbutton, mk_state, mx, my ) ;
        cur_window->KnowMouseIsOut = 1 ;
      }
    }
  }

  if ( (cur_window != last_gwnd) && GWIsWindowValid( last_gwnd ) &&
        last_gwnd->OnMouseMove && !last_gwnd->KnowMouseIsOut )
  {
    LoggingDo(LL_GW2, "MU_M1 for previous %s, ev_mmobutton=%d, ev_mmokstate=%d at (%d,%d)", GWInfoW(cur_window), bbutton, mk_state, mx, my ) ;
    last_gwnd->OnMouseMove( last_gwnd, bbutton, mk_state, mx, my ) ;
    last_gwnd = cur_window ;
    last_gwnd->KnowMouseIsOut = 1 ;
  }

  if ( GemApp.OnMouseMove )
  {
    LoggingDo(LL_GW1, "MU_M1 for application, ev_mmobutton=%d, ev_mmokstate=%d at (%d,%d)", bbutton, mk_state, mx, my ) ;
    GemApp.OnMouseMove( bbutton, mk_state, event->ev_mmox, event->ev_mmoy ) ;
  }

  return 0 ;
}

int GeneralTimerHandler(int mx, int my)
{
  LIST_ENTRY* entry = &GemApp.GemWindowListHead ;
  GEM_WINDOW* wnd ;
  size_t      dt ;
  clock_t     now = 0 ;
  char        text[200] ;

  if ( GemApp.OnTimer && (GemApp.TimeOutMs > 0) )
  {
    now = clock() ;
    dt  = now - GemApp.LastTick ;
    if ( 1000UL * dt > (size_t) GemApp.TimeOutMs * CLK_TCK )
    {
      GemApp.LastTick = now ;
      GemApp.OnTimer( mx, my, GemApp.TimerContext ) ;
    }
  }

  entry = entry->Flink ;
  while ( entry != &GemApp.GemWindowListHead )
  {
    wnd = GET_GEM_WINDOW_FROM_LIST_ENTRY( entry ) ;
    if ( wnd->OnTimer && (wnd->TimeOutMs > 0) )
    {
      if ( now == 0 ) now = clock() ;
      dt  = now - wnd->LastTick ;
      if ( 1000UL * dt > (size_t)wnd->TimeOutMs * CLK_TCK )
      {
        wnd->LastTick = now ;
        wnd->OnTimer( wnd, mx, my ) ;
      }
    }
    entry = entry->Flink ;
  }

#ifndef __NO_BUBBLE
  if ( GemApp.Flags.HelpBubbles )
  {
    static int last_mx, last_my ;

    if ( (last_mx == mx) && (last_my == my) )
    {
      wnd = GetWindowByHandle( wind_find( mx, my ) ) ;
      if ( wnd && wnd->OnTxtBubble && wnd->OnTxtBubble( wnd, mx, my, text ) )
        bulle_aide( mx, my, text ) ;
    }
    last_mx = mx ;
    last_my = my ;
  }
#endif

  return 0 ;
}

#define FMD_BACKWARD -1
#define FMD_FORWARD  -2
#define FMD_DFLT     -3
int find_object(OBJECT* tree, int start_obj, int which)
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
    if ( theflag & LASTOB ) object  = -1 ;
    else                    object += inc ;
  }

  return start_obj ;
}

int ini_field(OBJECT* tree, int start_field)
{
  if ( start_field <= 0 ) start_field = find_object( tree, 0, FMD_FORWARD ) ;

  return start_field ;
}

int find_position(OBJECT* obj, int No, int mx)
{
  int te_x ;
  int P_text = 0 ;
  int P_mask = 0 ;
  int size ;
  int i, Child ;

  if ( No < 0 ) return 0 ;

  size = obj[No].ob_spec.tedinfo->te_font==3 ? 8 : 6 ;
  te_x = obj[No].ob_spec.tedinfo->te_just ? obj[No].ob_width - (obj[No].ob_spec.tedinfo->te_tmplen-1) * size : 0 ;
  if ( obj[No].ob_spec.tedinfo->te_just == 2 ) te_x /= 2 ;
  te_x += obj[No].ob_x + (size>>1) ;

  Child= No;
  for ( i = No-1; 0 <= i; i-- )
  {
    if ( (obj[i].ob_head <= Child) && (Child <= obj[i].ob_tail) )
    {
      Child = i ;
      te_x += obj[i].ob_x ;
    }
  }

  while ( (te_x < mx) && (P_mask < obj[No].ob_spec.tedinfo->te_tmplen - 1) )
  {
    if ( obj[No].ob_spec.tedinfo->te_ptmplt[P_mask++] == '_' )
    P_text++ ;
    te_x += size ;
  }

  return P_text ;
}

int GetDefaultButton(OBJECT* base_tree)
{
  int obj = -1 ;
  int ind = 0 ;

  while ( ((base_tree[ind].ob_flags & LASTOB) == 0) && ((base_tree[ind].ob_flags & DEFAULT) == 0) ) ind++ ;

  if ( base_tree[ind].ob_flags & DEFAULT ) obj = ind ;

  return obj ;
}

void PreDialog(GEM_WINDOW* wnd, int mx)
{
  DIALOG* dlg ;

  if ( (wnd == NULL) || wnd->is_icon ) return ;
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
      char buf[200] ;

      if ( (dlg->EditObject > 0) && (dlg->Idx == -1) )
      {
        read_text( dlg->BaseObject, dlg->EditObject, buf ) ;
        dlg->Idx = (int)strlen( buf ) ;
      }
      if ( dlg->DoNotReInitEdit )
      {
        char* letterptr = NULL ;
        char  letter ;

        if ( dlg->EditObject )
          letter = *(letterptr = dlg->BaseObject[dlg->EditObject].ob_spec.tedinfo->te_ptext
                   + find_position( dlg->BaseObject, dlg->EditObject, mx ) ) ;
        if ( letterptr ) *letterptr = '\000' ;
        objc_edit( dlg->BaseObject, dlg->EditObject, 0, &dlg->Idx, ED_INIT ) ;
        if ( letterptr ) *letterptr = letter ;
      }
      else objc_edit( dlg->BaseObject, dlg->EditObject, 0, &dlg->Idx, ED_INIT ) ;
      dlg->DoNotReInitEdit = 1 ;
    }
  }
}

static int PostDialog(GEM_WINDOW* wnd)
{
  DIALOG* dlg ;

  if ( (wnd == NULL) || wnd->is_icon ) return 0 ;
  dlg = wnd->DlgData ;
  if ( (dlg == NULL) || dlg->MuMesag ) return 0 ;

  if ( (!dlg->Cont || dlg->NextObject) && dlg->ShowEdit )
    objc_edit( dlg->BaseObject, dlg->EditObject, 0, &dlg->Idx, ED_END ) ;

  dlg->Cont = 1 ;

  return dlg->ExitCode ;
}

int GWLoop(void)
{
  EVENT* event = &GemApp.Event ;
  char   must_exit = 0 ;
  int    help_bubbles = -1 ;
  int    which ;
  int    code, dummy ;

  LoggingDo(LL_GW2, "GWLoop:enter" ) ;
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
  event->ev_mflags     |= MU_KEYBD | MU_MESAG | MU_BUTTON ;

  event->ev_mmox = 0 ; /* Pour PreDialog */

  if ( !GWInModalDialog() )
  {
    if ( GemApp.OnUpdateGUI ) GemApp.OnUpdateGUI() ;
    else                      GWSetMenuStatus( 1 ) ;
  }
  else LoggingDo(LL_GW2, "GWLoop:in modal dialog" ) ;

  do
  {
    /* Positionnement du flag dynamique MU_M1 */
    if ( GemApp.OnMouseMove ||
         (GemApp.CurrentGemWindow && GemApp.CurrentGemWindow->OnMouseMove)
       )
    {
      event->ev_mflags   |= MU_M1 ;
      event->ev_mm1flags  = 1 ; /* Attendre sortie de zone */
      event->ev_mm1x      = event->ev_mmox ;
      event->ev_mm1y      = event->ev_mmoy ;
      event->ev_mm1width  = 2 ;
      event->ev_mm1height = 2 ;
    }
    else event->ev_mflags &= ~MU_M1 ;

    /* MU_TIMER is used for help bubbles at least */
    if ( help_bubbles != GemApp.Flags.HelpBubbles )
    {
      help_bubbles = GemApp.Flags.HelpBubbles ;
      LoggingDo(LL_GW2, "GWLoop: HelpBubbles changed to %d", help_bubbles) ;
      ComputeMinTimer() ;
    }

    if ( GWInDialog() ) PreDialog( GemApp.CurrentGemWindow, event->ev_mmox ) ;

    which = EvntMulti( event ) ;

    if ( which & MU_MESAG )
    {
      code      = GeneralMesagHandler( event ) ;
      must_exit = ( code == GW_EVTQUITAPP ) ;
      /* Next must_exit are ORed to not erase a previous quit request */
    }

    if ( which & MU_KEYBD )
    {
      code       = GeneralKbdHandler( event->ev_mkreturn ) ;
      must_exit |= ( code == GW_EVTQUITAPP ) ;
    }

    if ( which & MU_BUTTON )
    {
      code       = GeneralButtonHandler( event ) ;
      must_exit |= ( code == GW_EVTQUITAPP ) ;
    }

    if ( which & MU_M1 )
      GeneralMouseHandler( event ) ;

    if ( which & MU_TIMER )
    {
      /* Get mouse coordinates as they may have changed while handling GEM, keyboard or mouse events */
      graf_mkstate( &event->ev_mmox, &event->ev_mmoy, &dummy, &dummy ) ;
      GeneralTimerHandler( event->ev_mmox, event->ev_mmoy ) ;
    }

    if ( GWInDialog() )
    {
      code = PostDialog( GemApp.CurrentGemWindow ) ;
      if ( GWInModalDialog() ) must_exit = ( (code == IDOK) || (code == IDCANCEL) ) ;
    }
  }
  while ( !must_exit ) ;

  LoggingDo(LL_GW2, "GWLoop:exit with $%x", code ) ;
  return code ;
}

void SetRecurseMenuStatus(OBJECT* root, int index, int parent, int valid)
{
  OBJECT* obj ;
  char*   string ;

  if ( index < 0 ) return ;
  obj = &root[index] ;
  if ( obj->ob_type == G_STRING )
  {
    string = obj->ob_spec.free_string ;
    if ( valid && (string[0] != '-') ) obj->ob_state &= ~DISABLED ; /* ne marche pas sur A propos...    */
    else                               obj->ob_state |= DISABLED ;  /* menu_ienable( root, index, 0 ) ; */
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

static void GWAlignMenu(short id) /* By Daroou */
{
  OBJECT* dial ;
  short   idx_objet ;
  short   ibox_objet ;

  Xrsrc_gaddr( R_TREE, id, &dial ) ;

  /* ob_head points to first title of menu bar                         */
  /* ob_tail points to an IBOX object holding sub menus                */
  /* https://freemint.github.io/tos.hyp/en/aes_fundamentals.html 8.2.4 */
  idx_objet  = dial[0].ob_tail ;
  ibox_objet = idx_objet ;

  /* Each sub menu is included in a G_BOX */
  idx_objet  = dial[idx_objet].ob_head ;
  do
  {
    /* Check this object is a  G_BOX         */
    /* And each sub menu starts with a G_BOX */
    if ( dial[idx_objet].ob_type == G_BOX )
    {
      /* Does it go over the screen ? */
      if ( dial[idx_objet].ob_x + dial[idx_objet].ob_width >= wdesk )
      {
        /* Align it on right then */
        dial[idx_objet].ob_x = wdesk - dial[idx_objet].ob_width - 4 ;
      }
    }
    /* Move to next object */
    idx_objet = dial[idx_objet].ob_next ;
  }
  while ( idx_objet != ibox_objet ) ;
}

int GWSetMenu(int id, char* title)
{
  Xrsrc_gaddr( R_TREE, id, &GemApp.Menu ) ;
  if ( title && (Multitos || !_app) ) menu_register( ap_id, title ) ;

  GWAlignMenu( id ) ;
  menu_bar( GemApp.Menu, 1 ) ;

  return 0 ;
}

#pragma warn -par
int NullProgRange(void* wnd, long current, long max, char* txt)
{
  return 0 ;
}
#pragma warn +par

GEM_WINDOW* GWCreateWindow(int kind, long extension_size, char* class_name)
{
  GEM_WINDOW* wnd ;

  wnd = AllocateNewGemWindow() ;
  if ( wnd )
  {
    if ( extension_size > 0 )
    {
      wnd->Extension = Xcalloc( 1, extension_size ) ;
      if ( wnd->Extension == NULL )
      {
        DestroyWindow( wnd ) ;
        return NULL ;
      }
    }
    wnd->window_handle = wind_create( kind, xdesk, ydesk, wdesk, hdesk ) ;
    if ( wnd->window_handle >= 0 )
    {
      LoggingDo(LL_GW2,"wind_create returned handle %d for class %s", wnd->window_handle, class_name) ;
      strncpy( wnd->ClassName, class_name, 19 ) ;
      wnd->window_kind = kind ;
      wnd->ProgRange   = NullProgRange ;
      wnd->GetWorkXYWH = (void (*)(void *, int *, int *, int *, int *)) GWGetWorkXYWH ;
    }
    else
    {
      DestroyWindow( wnd ) ;
      LoggingDo(LL_WARNING, "GWCreateWindow: wind_create failed, %d windows open", GemApp.NbGemWindows ) ;
    }
  }

  return wnd ;
}

int GWOpenWindow(GEM_WINDOW* wnd, int x, int y, int w, int h)
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
    wnd->flags         |= FLG_ISVISIBLE ;
    wnd->must_be_fulled = 1 ;
    PostMessage( wnd, WM_TOPPED, NULL ) ;
  }

  return err ;
}

#pragma warn -par
int OnLButtonDownDlg(void* w, int mk_state, int mx, int my)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
  DIALOG*     dlg = wnd->DlgData ;
  clock_t     dt ;
  int         obj_clicked ;
  int         wx, wy, dummy ;
  int         code = 0 ;

  if ( !dlg || dlg->MuMesag ) return 0 ;

  GWGetWorkXYWH( wnd, &wx, &wy, &dummy, &dummy ) ;
  mx += wx ;
  my += wy ;
  obj_clicked = objc_find( dlg->BaseObject, 0, MAX_DEPTH, mx, my ) ;
  LoggingDo(LL_GW2, "OnLButtonDownDlg: obj_clicked=%d for mouse at (%d,%d)", obj_clicked, mx, my ) ;
  if ( obj_clicked == -1 ) return( 0 ) ;
  if ( dlg->BaseObject[obj_clicked].ob_state & DISABLED ) return( 0 ) ;

  dlg->Cont = form_button( dlg->BaseObject, obj_clicked, 1, &dlg->NextObject ) ;
  dt        = clock() - dlg->LastObjNotify ;
  if ( dlg->OnObjectNotify && (dt > CLK_TCK/40) )
  {
    dlg->ExitCode = dlg->OnObjectNotify( wnd, obj_clicked ) ;
    code = dlg->ExitCode ;
    if ( (code == IDOK) || (code == IDCANCEL) )
    {
      deselect( dlg->BaseObject, obj_clicked ) ;
      /* Si cette boite est non modale, la fermeture intervient ici */
      if ( ( wnd->flags & FLG_ISMODAL ) == 0 ) GWDestroyWindow( wnd ) ;
      /* Si cette boite est modale, GWLoop interpretera dlg->ExitCode */
    }
    dlg->LastObjNotify = clock() ;
  }

  return code ;
}
#pragma warn +par

int GWCloseDlg(void* w)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;

  Xfree( wnd->DlgData->BaseObject ) ;
  Xfree( wnd->DlgData ) ;
  GWOnClose( wnd ) ;

  return IDCANCEL ;
}

int OnToppedDlg(void* w)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;

  wnd->DlgData->ShowEdit = 1 ;

  return GWOnTopped( wnd ) ;
}

int OnUnToppedDlg(void* w)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;

  wnd->DlgData->ShowEdit = 0 ;

  return GWOnUnTopped( wnd ) ;
}

int GWOnKeyPressedDlg(void* w, int key)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
  DIALOG*     dlg ;
  int         kr = wnd->original_key ;
  int         x, y ;
  int         wx, wy, dummy ;

  dlg = wnd->DlgData ;
  if ( dlg->MuMesag ) return 0 ;

  dlg->Cont = form_keybd( dlg->BaseObject, dlg->EditObject, dlg->NextObject, kr, &dlg->NextObject, &kr ) ;
  if ( kr ) objc_edit( dlg->BaseObject, dlg->EditObject, kr, &dlg->Idx, ED_CHAR ) ;

  if ( key == KBD_RETURN )
  {
    objc_offset( dlg->BaseObject, dlg->NextObject, &x, &y ) ;
    wnd->GetWorkXYWH( wnd, &wx, &wy, &dummy, &dummy ) ; 
    if ( wnd->OnLButtonDown ) wnd->OnLButtonDown( wnd, 1, 1+x-wx, 1+y-wy ) ;
  }
  else if ( dlg->OnEditField ) dlg->OnEditField( wnd, dlg->EditObject ) ;

  return 0 ;
}

void OnDrawDlg(void* w, int xywh[4])
{
  GEM_WINDOW* wnd  = (GEM_WINDOW*) w ;
  DIALOG*     dlg  = wnd->DlgData ;
  OBJECT*     tree = dlg->BaseObject ;
  int         x, y, dummy ;

  if ( wnd->is_icon && (wnd->window_icon.fd_addr == NULL) ) GWOnDraw( wnd, xywh ) ;
  else
  {
    char buf[200] ;

    if ( (dlg->EditObject > 0) && (dlg->Idx == -1) )
    {
      read_text( dlg->BaseObject, dlg->EditObject, buf ) ;
      dlg->Idx = (int)strlen( buf ) ;
    }
    GWGetWorkXYWH( wnd, &x, &y, &dummy, &dummy ) ;
    tree->ob_x = x ;
    tree->ob_y = y ;
    (void)objc_draw( tree, 0, MAX_DEPTH, xywh[0], xywh[1], xywh[2], xywh[3] ) ;
    if ( (dlg->EditObject > 0) && dlg->ShowEdit )
      objc_edit( dlg->BaseObject, dlg->EditObject, 0, &dlg->Idx, ED_END ) ;
  }
}

void GWOnMoveDlg(void* gw, int xywh[4])
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) gw ;
  DIALOG*     dlg = wnd->DlgData ;
  int         x, y, w, h ;

  GWOnMove( wnd, xywh ) ;
  GWGetWorkXYWH( wnd, &x, &y, &w, &h ) ;
  dlg->BaseObject->ob_x = x ;
  dlg->BaseObject->ob_y = y ;
}

int XFormCenter(OBJECT* obj, int ixywh[4], int* x, int* y)
{
  int done_by_form_center = 0 ;
  int dummy ;
  int dw, dh ;

  if ( ixywh )
  {
    dw = ixywh[2] - obj->ob_width ;
    dh = ixywh[3] - obj->ob_height ;
    if ( (dw < 0) || (dh < 0) ) done_by_form_center = 1 ;
  }
  else done_by_form_center = 1 ;

  if ( !done_by_form_center )
  {
    *x = ixywh[0] + dw >> 1 ;
    *y = ixywh[1] + dh >> 1 ;
  }
  else form_center( obj, x, y, &dummy, &dummy ) ;

  return done_by_form_center ; 
}

GEM_WINDOW* GWCreateDialog(DLGDATA* data)
{
  GEM_WINDOW* wnd ;
  OBJECT*     base_obj ;
  int         wkind = NAME | MOVER | CLOSER ;
  int         x, y ;
  int         bx, by, bw, bh ;
  char        class_name[20] ;

  wkind |= data->WKind ;
  wkind &= ~data->NWKind ;
  if ( data->RsrcId == -1 ) base_obj = data->Object ;
  else
  {
    if ( Xrsrc_gaddr( R_TREE, data->RsrcId, &base_obj ) == 0 ) return NULL ;
    base_obj = xobjc_copy( base_obj ) ; /* Duplication de l'arbre */
  }

  if ( base_obj == NULL ) return NULL ;

  if ( data->ClassName[0] ) strcpy( class_name, data->ClassName ) ;
  else                      sprintf( class_name, "%lx", (unsigned long)base_obj ) ;
  wnd = GWCreateWindow( wkind, data->ExtensionSize, class_name ) ;
  if ( wnd )
  {
    DIALOG* dlg = (DIALOG*) Xcalloc( 1, sizeof(DIALOG) ) ;

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
      if ( data->OnEditField )    dlg->OnEditField = data->OnEditField ;
 
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
      wnd->OnMove        = GWOnMoveDlg ;
      wnd->OnDraw        = OnDrawDlg ;
      wnd->OnKeyPressed  = GWOnKeyPressedDlg ;
      wnd->OnLButtonDown = OnLButtonDownDlg ;
      wnd->OnTopped      = OnToppedDlg ;
      wnd->OnUnTopped    = OnUnToppedDlg ;

      dlg->NextObject    = ini_field( dlg->BaseObject, 0 ) ;
      dlg->Cont          = 1 ;
      dlg->LastObjNotify = clock() ;

      wind_calc( WC_BORDER, wnd->window_kind, x, y, base_obj->ob_width, base_obj->ob_height, &bx, &by, &bw, &bh ) ;
      if ( GWOpenWindow( wnd, bx, by, bw, bh ) != 0 )
      {
        Xfree( dlg ) ;
        if ( data->RsrcId != -1 ) Xfree( base_obj ) ;
        wnd = NULL ;
      }
    }
    else if ( data->RsrcId != -1 ) Xfree( base_obj ) ;
  }

  return wnd ;
}

int GWDoModal(GEM_WINDOW* wnd, int start_ob)
{
  DIALOG* dlg ;
  int     code ;

  if ( wnd == NULL ) return -1 ;
  dlg = wnd->DlgData ;
  if ( dlg == NULL ) return -1 ;

  if ( GemApp.OnPreModal ) GemApp.OnPreModal() ;
  wnd->flags |= FLG_ISMODAL ;
  PostMessage( wnd, WM_TOPPED, NULL ) ;
  GemApp.CurrentGemWindow = wnd ;
  if ( start_ob > 0 ) dlg->StartOb = start_ob ;
  dlg->NextObject = ini_field( dlg->BaseObject, dlg->StartOb ) ;
  dlg->Cont = 1 ;

  code = GWLoop() ; /* IDOK or IDCANCEL */

  if ( GemApp.OnPostModal ) GemApp.OnPostModal() ;

  if ( GWIsWindowValid( wnd ) ) wnd->OnClose( wnd ) ;

  return code ;
}

void GWEndModal(GEM_WINDOW* wnd)
{
  if ( GWIsWindowValid( wnd ) )
  {
    if ( wnd->OnClose ) wnd->OnClose( wnd ) ;
    else                GWCloseDlg( wnd ) ;
  }
}

GEM_WINDOW* GWCreateWindowCmdBar(DLGDATA* data)
{
  GEM_WINDOW* wnd ;
  DIALOG*     dlg ;
  OBJECT*     base_obj ;
  int         wkind = NAME | MOVER | CLOSER ;
  char        class_name[20] ;

  wkind |= data->WKind ;
  wkind &= ~data->NWKind ;
  if ( data->RsrcId == -1 ) base_obj = data->Object ;
  else
  {
    if ( Xrsrc_gaddr( R_TREE, data->RsrcId, &base_obj ) == 0 ) return( NULL ) ;
    base_obj = xobjc_copy( base_obj ) ; /* Duplication de l'arbre */
  }

  if ( base_obj == NULL ) return NULL ;

  if ( data->ClassName[0] ) strcpy( class_name, data->ClassName ) ;
  else                      sprintf( class_name, "%lx", (unsigned long)base_obj ) ;
  wnd = GWCreateWindow( wkind, data->ExtensionSize, class_name ) ;
  if ( wnd )
  {
    dlg = (DIALOG*) Xcalloc( 1, sizeof(DIALOG) ) ;
    if ( dlg )
    {
      wnd->DlgData    = dlg ;
      dlg->BaseObject = base_obj ;
      dlg->UserData   = data->UserData ;
      strcpy( wnd->window_name, data->Title ) ;

      if ( data->OnInitDialog )   dlg->OnInitDialog   = data->OnInitDialog ;
      if ( data->OnObjectNotify ) dlg->OnObjectNotify = data->OnObjectNotify ;
      if ( data->OnCloseDialog )  wnd->OnClose        = data->OnCloseDialog ;
      wnd->OnMove     = GWOnMoveDlg ;
      wnd->OnTopped   = OnToppedDlg ;
      wnd->OnUnTopped = OnUnToppedDlg ;

      dlg->NextObject = ini_field( dlg->BaseObject, 0 ) ;
      dlg->Cont = 1 ;

      if ( dlg->OnInitDialog ) dlg->OnInitDialog( wnd ) ;
    }
    else if ( data->RsrcId != -1 ) Xfree( base_obj ) ;
  }

  return wnd ;
}

void GWRePaint(GEM_WINDOW* wnd)
{
  int xy[4] ;

  wnd->GetWorkXYWH( wnd, &xy[0], &xy[1], &xy[2], &xy[3] ) ;
  BasicDrawingHandler( wnd, xy ) ;
}

int GWBasicModalHandler(void)
{
  EVENT evnt ;
  int   which ;
  int   code, scode = 0 ;

  LoggingDo(LL_GW2, "GWBasicModalHandler:enter" );
  memzero( &evnt, sizeof(EVENT) ) ;
  evnt.ev_mflags = MU_KEYBD | MU_MESAG | MU_TIMER ;
  do
  {
    code = 0 ;
    which = EvntMulti( &evnt ) ;
    if ( which & MU_MESAG ) code = GeneralMesagHandler( &evnt ) ;
    if ( code != 0 ) scode = code ;
    if ( which & MU_KEYBD ) code = GeneralKbdHandler( evnt.ev_mkreturn ) ;
    if ( code != 0 ) scode = code ;
  }
  while ( which != MU_TIMER ) ;

  LoggingDo(LL_GW2, "GWBasicModalHandler:exit with $%x", scode );
  return scode ;
}

void GWShowWindow(GEM_WINDOW* wnd, int show)
{
  if ( show && ((wnd->flags & FLG_ISVISIBLE) == 0) )
  {
    if ( wind_open( wnd->window_handle, wnd->vx, wnd->vy, wnd->vw, wnd->vh ) )
      wnd->flags |= FLG_ISVISIBLE ;
  }
  else if ( !show && (wnd->flags & FLG_ISVISIBLE) )
  {
    wind_get( wnd->window_handle, WF_CURRXYWH, &wnd->vx, &wnd->vy, &wnd->vw, &wnd->vh ) ;
    wind_close( wnd->window_handle ) ;
    wnd->flags &= ~FLG_ISVISIBLE ;
  }
}

void GWSetWindowCaption(GEM_WINDOW* wnd, char* caption)
{
  strncpy( wnd->window_name, caption, sizeof(wnd->window_name) ) ;
  wind_set( wnd->window_handle, WF_NAME, wnd->window_name ) ;
}

void GWSetWindowInfo(GEM_WINDOW* wnd, char* info)
{
  if ( (wnd->window_kind & WF_INFO) && strcmp(wnd->window_info, info) )
  {
    strncpy( wnd->window_info, info, sizeof(wnd->window_info)-1 ) ;
    wind_set( wnd->window_handle, WF_INFO, wnd->window_info ) ;
  }
}

static void GWSetSlider(GEM_WINDOW* wnd, int action, int pos)
{
  if ( pos < 0 )         pos = 0 ;
  else if ( pos > 1000 ) pos = 1000 ;
  wind_set( wnd->window_handle, action, pos ) ;
}

void GWSetHSlider(GEM_WINDOW* wnd, int pos)
{
  GWSetSlider( wnd, WF_HSLIDE, pos ) ;
}

void GWSetVSlider(GEM_WINDOW* wnd, int pos)
{
  GWSetSlider( wnd, WF_VSLIDE, pos ) ;
}

void GWSetHSliderSize(GEM_WINDOW* wnd, int pos)
{
  GWSetSlider( wnd, WF_HSLSIZE, pos ) ;
}

void GWSetVSliderSize(GEM_WINDOW* wnd, int pos)
{
  GWSetSlider( wnd, WF_VSLSIZE, pos ) ;
}

void GWGetHSlider(GEM_WINDOW* wnd, int* pos)
{
  wind_get( wnd->window_handle, WF_HSLIDE, pos ) ;
}

void GWGetVSlider(GEM_WINDOW* wnd, int* pos)
{
  wind_get( wnd->window_handle, WF_VSLIDE, pos ) ;
}

void GWGetHSliderSize(GEM_WINDOW* wnd, int* size)
{
  wind_get( wnd->window_handle, WF_HSLSIZE, size ) ;
}

void GWGetVSliderSize(GEM_WINDOW* wnd, int* size)
{
  wind_get( wnd->window_handle, WF_VSLSIZE, size ) ;
}

void GWGetWorkXYWH(GEM_WINDOW* wnd, int* x, int* y, int* w, int* h)
{
  wind_get( wnd->window_handle, WF_WORKXYWH, x, y, w, h ) ;
}

void GWGetCurrXYWH(GEM_WINDOW* wnd, int* x, int* y, int* w, int* h)
{
  wind_get( wnd->window_handle, WF_CURRXYWH, x, y, w, h ) ;
}

void GWSetCurrXYWH(GEM_WINDOW* wnd, int x, int y, int w, int h)
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
    which = EvntMulti( &evnt ) ;
    if ( (which & MU_MESAG) && (evnt.ev_mmgpbuf[0] == WM_REDRAW) )
      GeneralMesagHandler( &evnt ) ;
  }
  while ( which != MU_TIMER ) ;
}

int GWIsWindow(void)
{
  int is_window = IsListEmpty( &GemApp.GemWindowListHead ) ;

  if ( !is_window ) GemApp.CurrentGemWindow = NULL ;

  return is_window ;
}

GEM_WINDOW* GWGetWindow(int x, int y)
{
  int wh ;

  wh = wind_find( x, y ) ;
  if ( wh > 0 ) return GetWindowByHandle( wh ) ;
  else          return NULL ;
}

void GWExit(void)
{
  LIST_ENTRY* entry ;
  GEM_WINDOW* wnd ;

  while ( !IsListEmpty( &GemApp.GemWindowListHead ) )
  {
    entry = GetHeadList( &GemApp.GemWindowListHead ) ;
    wnd   = GET_GEM_WINDOW_FROM_LIST_ENTRY( entry ) ;
    if ( wnd->OnClose ) wnd->OnClose( wnd ) ;
    else                GWOnClose( wnd ) ;
    if ( GWIsWindowValid( wnd ) ) DestroyWindow( wnd ) ;  /* Le OnClose modifie n'a pas fait son boulot ! */
    GWRedraws() ;
  }
}

int PostMessage(GEM_WINDOW* wnd, int id, int mesg[4])
{
  int messag[8] ;

  memzero( messag, sizeof(messag) ) ;
  messag[0] = id ;
  messag[1] = ap_id ;
/*  messag[2] = 0 ;  No more data */
  if ( wnd ) messag[3] = wnd->window_handle ;
  if ( mesg ) memcpy( &messag[4], mesg, 4*sizeof(int) ) ;

  return appl_write( ap_id, sizeof(messag), messag ) ;
}

void GWInvalidate(GEM_WINDOW* wnd)
{
  int mesg[4] ;

  if ( wnd->flags & FLG_ISVISIBLE )
  {
    wnd->GetWorkXYWH( wnd, &mesg[0], &mesg[1], &mesg[2], &mesg[3] ) ;
    PostMessage( wnd, WM_REDRAW, mesg ) ;
  }
}

void GWDestroyWindow(GEM_WINDOW* wnd)
{
  if ( GWIsWindowValid( wnd ) ) PostMessage( wnd, GWM_DESTROY, NULL ) ;
}

int GWSetWndRscIcon(GEM_WINDOW* wnd, int form, int id)
{
  MFDB      new_icon ;
  USERBLK*  userblk ;
  CICONBLK* icnblk ;
  ICONBLK*  icnblk_mono ;
  OBJECT*   obj ;
  int       type ;
  int       err = 0 ;

  if ( Xrsrc_gaddr( R_TREE, form, &obj ) == 0 ) return -1 ;
  obj  = &obj[id] ;
  type = obj->ob_type ;

  ZeroMFDB( &new_icon ) ;
  /* Recherche un icone dans la resolution courante */
  new_icon.fd_nplanes = screen.fd_nplanes ;
  switch( type )
  {
    case G_ICON  :   icnblk_mono = obj->ob_spec.iconblk ;
                     err         = Icon2MFDB( icnblk_mono, &new_icon ) ;
                     break ;

    case G_CICON   :
    case G_USERDEF : userblk = (USERBLK*) obj->ob_spec.index ;
                     if ( Xrsrc_used ) icnblk = (CICONBLK*) userblk->ub_parm ;
                     else              icnblk = obj->ob_spec.ciconblk ;
                     err = Cicon2MFDB( icnblk, &new_icon ) ;
                     break ;

    default      :   err = -1 ;
                     break ;
  }

  if ( !err )
  {
    if ( wnd->window_icon.fd_addr ) Xfree( wnd->window_icon.fd_addr ) ;
    CopyMFDB( &wnd->window_icon, &new_icon ) ;
  }

  return err ;
}

GEM_APP* GWGetApp(int argc, char** argv)
{
  if ( argv )
  {
    GemApp.Argc = argc ;
    GemApp.Argv = argv ;
  }

  return( &GemApp ) ;
}

void GWDeclareAndRunApp(GEM_APP* app)
{
  int err = -1 ;

  if ( gem_init() < 0 ) return ;

  InitializeListHead( &app->GemWindowListHead ) ;

  if ( app->OnInit ) err = app->OnInit( app ) ;
  if ( !err )
  {
  
    if ( app->OnParseCmdLine ) app->OnParseCmdLine( app, app->Argc, app->Argv ) ;
    else if ( app->OnOpenFile )
    {
      int n ;

      for ( n = 1; n < app->Argc; n++ )
      {
        LoggingDo(LL_DEBUG,"GWOpenFile(%d/%d):%s", n, n < app->Argc, app->Argv[n]) ;
        app->OnOpenFile( app->Argv[n] ) ;
      }
    }

    GWSetMenuStatus( 1 ) ;
    GWLoop() ;
  }

  GWExit() ;
  if ( app->OnTerminate ) app->OnTerminate( app ) ;
  (void)gem_exit() ;
}

int GWProgRange(GEM_WINDOW* wnd, long val, long max, char* txt)
{
  short do_update = 0 ;
  short status = SPROG_GUINOTUPDATED ;

  if ( !wnd || !wnd->ProgRange ) return status ;

  if ( val > max ) max = val ;

  if ( max != wnd->pr_max )
  {
    LoggingDo(LL_DEBUG, "GWProgRange updating max to %ld", max) ;
    wnd->pr_max     = max ;
    wnd->pr_diffval = max >> 4 ; /* No more than 16 updates based on value change */
  }

  /* Call function either if difference in values is enough                   -or- */
  /* 2 seconds have elapsed                                                   -or- */
  /* Control key is pressed, probably meaning user wants to cancel with Control-C  */
  wnd->pr_currentT = 0 ;
/*  LoggingDo(LL_DEBUG,"Kbshift()=%lx, xKbshift()=%lx, xoKbshift()=%lx", Kbshift(-1), xKbshift(), xoKbshift());*/
  if ( xKbshift() & 0x04 ) { do_update = 1 ; wnd->pr_force_cancel_check = 1 ; }
  if ( labs(val-wnd->pr_last_val_shown) > wnd->pr_diffval ) do_update = 1 ;
  else
  {
    if ( wnd->pr_ncalls_before_clock == 0 )
    {
      wnd->pr_currentT = clock() ; /* To avoid wnd->ProgRange to call clock() once again */
      if ( wnd->pr_currentT-wnd->pr_lastupdate > 2*CLK_TCK ) do_update = 1 ;
	    else if ( wnd->pr_currentT == wnd->pr_lastupdate )     wnd->pr_ncalls_before_clock = 16 ; /* Caller calls us too often, let's reduce the number of calls to clock() as this is pretty CPU time consuming */
    }
    else wnd->pr_ncalls_before_clock-- ;
  }

  if ( do_update )
  {
    LoggingDo(LL_DEBUG, "GWProgRange(%ld, %ld) calling wnd->ProgRange", val, max) ;
    wnd->pr_last_val_shown      = val ;
    wnd->pr_ncalls_before_clock = 0 ;
    status                      = wnd->ProgRange( wnd, val, max, txt ) ;
    if ( wnd->pr_currentT ) wnd->pr_lastupdate = wnd->pr_currentT ;
    else                    wnd->pr_lastupdate = clock() ;
  }

  return status ;
}

int GWGetKey(void)
{
  EVENT evnt ;
  int   which ;
  int   key = -1 ;

  memzero( &evnt, sizeof(EVENT) ) ;
  evnt.ev_mflags = MU_KEYBD | MU_TIMER ;
  do
  {
    which = EvntMulti( &evnt ) ;
    if ( which & MU_KEYBD )
    {
      int dummy, kstate ;

      graf_mkstate( &dummy, &dummy, &dummy, &kstate ) ;
      key = translate_kcode( evnt.ev_mkreturn, kstate ) ;
    }
  }
  while ( which != MU_TIMER ) ;

  return key ;
}

void GWObjcDraw(GEM_WINDOW* wnd, OBJECT* obj, int num)
{
  xobjc_draw( wnd->window_handle, obj, num ) ;
}

short GWCreateAndDoModal(DLGDATA* dlg_data, short start_ob)
{
  return GWDoModal( GWCreateDialog(dlg_data), start_ob ) ;
}