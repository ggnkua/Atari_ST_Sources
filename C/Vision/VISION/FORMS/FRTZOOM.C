#include <string.h>
#include "..\tools\gwindows.h"

#include "defs.h"
#include "rtzoom.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  VISION_CFG cfg ;

  int w, h ;
}
WEXTENSION_RTZOOM ;

typedef struct
{
  OBJECT *popup_level ;
}
WDLG_RTZOOM ;

int zoom2index[] = { 1, 1, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5 } ;


void show_prtzoom( int show, GEM_WINDOW *wnd)
{
  OBJECT      *adr_rtzoom = wnd->DlgData->BaseObject ;
  WDLG_RTZOOM *wdlg = wnd->Extension ;
  OBJECT      *popup_level = wdlg->popup_level ;

  if ( show )
  {
    write_text( adr_rtzoom, ZOOMRT_LEVEL, popup_level[zoom2index[config.rt_zoomlevel]].ob_spec.free_string ) ;
    adr_rtzoom[ZOOMRT_LEVEL].ob_state &= ~DISABLED ;
    adr_rtzoom[ZOOMRT_SCREEN].ob_state &= ~DISABLED ;
    adr_rtzoom[ZOOMRT_TSCREEN].ob_state &= ~DISABLED ;
    adr_rtzoom[ZOOMRT_IMG].ob_state &= ~DISABLED ;
    adr_rtzoom[ZOOMRT_TIMG].ob_state &= ~DISABLED ;
    adr_rtzoom[ZOOMRT_SMART].ob_state &= ~DISABLED ;
    adr_rtzoom[ZOOMRT_TSMART].ob_state &= ~DISABLED ;
    adr_rtzoom[ZOOMRT_USEGEM].ob_state &= ~DISABLED ;
    adr_rtzoom[ZOOMRT_TUSEGEM].ob_state &= ~DISABLED ;
    adr_rtzoom[ZOOMRT_OPTPOS].ob_state &= ~DISABLED ;
    adr_rtzoom[ZOOMRT_TOPTPOS].ob_state &= ~DISABLED ;
    adr_rtzoom[ZOOMRT_SIZE].ob_state &= ~DISABLED ;
    adr_rtzoom[ZOOMRT_INCSIZE].ob_state &= ~DISABLED ;
    adr_rtzoom[ZOOMRT_DECSIZE].ob_state &= ~DISABLED ;
  }
  else
  {
    adr_rtzoom[ZOOMRT_LEVEL].ob_state |= DISABLED ;
    adr_rtzoom[ZOOMRT_SCREEN].ob_state |= DISABLED ;
    adr_rtzoom[ZOOMRT_TSCREEN].ob_state |= DISABLED ;
    adr_rtzoom[ZOOMRT_IMG].ob_state |= DISABLED ;
    adr_rtzoom[ZOOMRT_TIMG].ob_state |= DISABLED ;
    adr_rtzoom[ZOOMRT_SMART].ob_state |= DISABLED ;
    adr_rtzoom[ZOOMRT_TSMART].ob_state |= DISABLED ;
    adr_rtzoom[ZOOMRT_USEGEM].ob_state |= DISABLED ;
    adr_rtzoom[ZOOMRT_TUSEGEM].ob_state |= DISABLED ;
    adr_rtzoom[ZOOMRT_OPTPOS].ob_state |= DISABLED ;
    adr_rtzoom[ZOOMRT_TOPTPOS].ob_state |= DISABLED ;
    adr_rtzoom[ZOOMRT_SIZE].ob_state |= DISABLED ;
    adr_rtzoom[ZOOMRT_INCSIZE].ob_state |= DISABLED ;
    adr_rtzoom[ZOOMRT_DECSIZE].ob_state |= DISABLED ;
  }

  xobjc_draw( wnd->window_handle, adr_rtzoom, ZOOMRT_LEVEL ) ;
  xobjc_draw( wnd->window_handle, adr_rtzoom, ZOOMRT_SCREEN ) ;
  xobjc_draw( wnd->window_handle, adr_rtzoom, ZOOMRT_TSCREEN ) ;
  xobjc_draw( wnd->window_handle, adr_rtzoom, ZOOMRT_IMG ) ;
  xobjc_draw( wnd->window_handle, adr_rtzoom, ZOOMRT_TIMG ) ;
  xobjc_draw( wnd->window_handle, adr_rtzoom, ZOOMRT_SMART ) ;
  xobjc_draw( wnd->window_handle, adr_rtzoom, ZOOMRT_TSMART ) ;
  xobjc_draw( wnd->window_handle, adr_rtzoom, ZOOMRT_USEGEM ) ;
  xobjc_draw( wnd->window_handle, adr_rtzoom, ZOOMRT_TUSEGEM ) ;
  xobjc_draw( wnd->window_handle, adr_rtzoom, ZOOMRT_SIZE ) ;
  xobjc_draw( wnd->window_handle, adr_rtzoom, ZOOMRT_INCSIZE ) ;
  xobjc_draw( wnd->window_handle, adr_rtzoom, ZOOMRT_DECSIZE ) ;
  xobjc_draw( wnd->window_handle, adr_rtzoom, ZOOMRT_OPTPOS ) ;
  xobjc_draw( wnd->window_handle, adr_rtzoom, ZOOMRT_TOPTPOS ) ;
}

void OnInitDialogRTZoom(void *w)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_RTZOOM *wext = wnd->DlgData->UserData ;
  WDLG_RTZOOM       *wdlg = wnd->Extension ;
  OBJECT      *adr_prtzoom = wnd->DlgData->BaseObject ;
  int         i ;
  char        buf[50] ;

  memcpy( &wext->cfg, &config, sizeof(VISION_CFG) ) ;

  wdlg->popup_level = popup_make( 5, 8 ) ;
  if ( wdlg->popup_level == NULL ) return ;

  for ( i = 0; i < 5; i++ )
    sprintf( wdlg->popup_level[1+i].ob_spec.free_string, "  x %d ", 1 << i ) ;

  write_text( adr_prtzoom, ZOOMRT_LEVEL, wdlg->popup_level[zoom2index[config.rt_zoomlevel]].ob_spec.free_string ) ;
  if ( config.use_rtzoom ) select( adr_prtzoom, ZOOMRT_VALID ) ;
  else                     deselect( adr_prtzoom, ZOOMRT_VALID ) ;

  if ( config.rt_optimizepos ) select( adr_prtzoom, ZOOMRT_OPTPOS ) ;
  else                         deselect( adr_prtzoom, ZOOMRT_OPTPOS ) ;

  if ( config.rt_respectgem ) select( adr_prtzoom, ZOOMRT_USEGEM ) ;
  else                        deselect( adr_prtzoom, ZOOMRT_USEGEM ) ;

  /* D‚-active le zoom temps r‚el */
  RTZoomDisable  = 1 ;

  deselect( adr_prtzoom, ZOOMRT_IMG ) ;
  deselect( adr_prtzoom, ZOOMRT_SCREEN ) ;
  deselect( adr_prtzoom, ZOOMRT_SMART ) ;

  switch( config.rt_zoomwhat )
  {
    case RTZ_IMG :    select( adr_prtzoom, ZOOMRT_IMG ) ;
                      break ;
    case RTZ_SCREEN : select( adr_prtzoom, ZOOMRT_SCREEN ) ;
                      break ;
    case RTZ_SMART :  select( adr_prtzoom, ZOOMRT_SMART ) ;
                      break ;
  }

  wext->w = config.rt_width ;
  wext->h = config.rt_height ;
  sprintf( buf, "%03d x %03d", config.rt_width, config.rt_height ) ;
  write_text( adr_prtzoom, ZOOMRT_SIZE, buf ) ;
}

int OnObjectNotifyRTZoom(void *w, int obj)
{
  GEM_WINDOW        *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_RTZOOM *wext = wnd->DlgData->UserData ;
  WDLG_RTZOOM       *wdlg = wnd->Extension ;
  OBJECT            *adr_prtzoom = wnd->DlgData->BaseObject ;
  int               code = -1 ;
  int               i, off_x, off_y ;
  char              buf[50] ;

  switch( obj )
  {
    case ZOOMRT_VALID   :
    case ZOOMRT_TVALID  : config.use_rtzoom = 1 - config.use_rtzoom ;
                          inv_select( adr_prtzoom, ZOOMRT_VALID ) ;
                          show_prtzoom( config.use_rtzoom, wnd ) ;
                          break ;
    case ZOOMRT_IMG     :
    case ZOOMRT_TIMG    : select( adr_prtzoom, ZOOMRT_IMG ) ;
                          deselect( adr_prtzoom, ZOOMRT_SCREEN ) ;
                          deselect( adr_prtzoom, ZOOMRT_SMART ) ;
                          xobjc_draw( wnd->window_handle, adr_prtzoom, ZOOMRT_IMG ) ;
                          xobjc_draw( wnd->window_handle, adr_prtzoom, ZOOMRT_SCREEN ) ;
                          xobjc_draw( wnd->window_handle, adr_prtzoom, ZOOMRT_SMART ) ;
                          break ;
    case ZOOMRT_SCREEN  :
    case ZOOMRT_TSCREEN : select( adr_prtzoom, ZOOMRT_SCREEN ) ;
                          deselect( adr_prtzoom, ZOOMRT_IMG ) ;
                          deselect( adr_prtzoom, ZOOMRT_SMART ) ;
                          xobjc_draw( wnd->window_handle, adr_prtzoom, ZOOMRT_IMG ) ;
                          xobjc_draw( wnd->window_handle, adr_prtzoom, ZOOMRT_SCREEN ) ;
                          xobjc_draw( wnd->window_handle, adr_prtzoom, ZOOMRT_SMART ) ;
                          break ;
    case ZOOMRT_SMART  :
    case ZOOMRT_TSMART :  select( adr_prtzoom, ZOOMRT_SMART ) ;
                          deselect( adr_prtzoom, ZOOMRT_IMG ) ;
                          deselect( adr_prtzoom, ZOOMRT_SCREEN ) ;
                          xobjc_draw( wnd->window_handle, adr_prtzoom, ZOOMRT_IMG ) ;
                          xobjc_draw( wnd->window_handle, adr_prtzoom, ZOOMRT_SCREEN ) ;
                          xobjc_draw( wnd->window_handle, adr_prtzoom, ZOOMRT_SMART ) ;
                          break ;
    case ZOOMRT_USEGEM  :
    case ZOOMRT_TUSEGEM : inv_select( adr_prtzoom, ZOOMRT_USEGEM ) ;
                          break ;
    case ZOOMRT_OPTPOS  :
    case ZOOMRT_TOPTPOS : inv_select( adr_prtzoom, ZOOMRT_OPTPOS ) ;
                          break ;
    case ZOOMRT_LEVEL   :
                          objc_offset( adr_prtzoom, obj, &off_x, &off_y ) ;
                          i = popup_formdo( &wdlg->popup_level, off_x, off_y, zoom2index[config.rt_zoomlevel], -1) ;
                          if ( i > 0 ) config.rt_zoomlevel = 1 << (i-1) ;
                          write_text( adr_prtzoom, obj, wdlg->popup_level[zoom2index[config.rt_zoomlevel]].ob_spec.free_string ) ;
                          inv_select( adr_prtzoom, obj ) ;
                          break ;
   case ZOOMRT_INCSIZE  : if ( wext->w < RTZ_MAXSIZE ) wext->w += 16 ;
                          wext->h = wext->w ;
                          sprintf( buf, "%03d x %03d", wext->w, wext->h ) ;
                          write_text( adr_prtzoom, ZOOMRT_SIZE, buf ) ;
                          xobjc_draw( wnd->window_handle, adr_prtzoom, ZOOMRT_SIZE ) ;
                          break ;
   case ZOOMRT_DECSIZE  : if ( wext->w > RTZ_MINSIZE ) wext->w -= 16 ;
                          wext->h = wext->w ;
                          sprintf( buf, "%03d x %03d", wext->w, wext->h ) ;
                          write_text( adr_prtzoom, ZOOMRT_SIZE, buf ) ;
                          xobjc_draw( wnd->window_handle, adr_prtzoom, ZOOMRT_SIZE ) ;
                          break ;
     case ZOOMRT_OK     : code = IDOK ;
                          break ;
     case ZOOMRT_CANCEL : code = IDCANCEL ;
                          break ;
  }

  if ( code == IDOK )
  {
    if ( selected( adr_prtzoom, ZOOMRT_VALID ) )  config.use_rtzoom = 1 ;
    else                                          config.use_rtzoom = 0 ;
    if ( selected( adr_prtzoom, ZOOMRT_USEGEM ) ) config.rt_respectgem = 1 ;
    else                                          config.rt_respectgem = 0 ;
    if ( selected( adr_prtzoom, ZOOMRT_IMG ) )    config.rt_zoomwhat = RTZ_IMG ;
    else
    if ( selected( adr_prtzoom, ZOOMRT_SCREEN ) )   config.rt_zoomwhat = RTZ_SCREEN ;
    else if ( selected( adr_prtzoom, ZOOMRT_IMG ) ) config.rt_zoomwhat = RTZ_IMG ;
    else                                            config.rt_zoomwhat = RTZ_SMART ;
    if ( selected( adr_prtzoom, ZOOMRT_OPTPOS ) ) config.rt_optimizepos = 1 ;
    else                                          config.rt_optimizepos = 0 ;
    config.rt_width  = wext->w ;
    config.rt_height = wext->h ;
  }
  else if ( code == IDCANCEL ) memcpy( &config, &wext->cfg, sizeof(VISION_CFG) ) ;

  return( code ) ;
}

int OnCloseDlgRTZoom(void *w)
{
  GEM_WINDOW  *wnd = (GEM_WINDOW *) w ;
  WDLG_RTZOOM *wdlg = wnd->Extension ;

  popup_kill( wdlg->popup_level, 5 ) ;

  return( GWCloseDlg( w ) ) ;
}

int pref_rtzoom(void)
{
  GEM_WINDOW        *dlg ;
  WEXTENSION_RTZOOM wext ;
  DLGDATA           dlg_data ;
  int               code ;

  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
  dlg_data.RsrcId       = FORM_ZOOMRT ;
  strcpy( dlg_data.Title, msg[MSG_WFNAMES] ) ;
  dlg_data.UserData     = &wext ;
  dlg_data.OnInitDialog = OnInitDialogRTZoom ;
  dlg_data.OnObjectNotify = OnObjectNotifyRTZoom ;
  dlg_data.OnCloseDialog  = OnCloseDlgRTZoom ;
  dlg_data.ExtensionSize  = sizeof(WDLG_RTZOOM) ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, -1 ) ;

  RTZoomDisable = 0 ;
  if ( code == IDOK )
  {
    rtzoom_free() ;
    if ( config.use_rtzoom ) rtzoom_init() ;
  }

  return( code == IDOK ) ;
}
