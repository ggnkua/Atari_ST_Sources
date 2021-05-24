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

char zoom2index[] = { 1, 1, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5 } ;


void show_prtzoom( int show, GEM_WINDOW* wnd)
{
  OBJECT*      adr_rtzoom = wnd->DlgData->BaseObject ;
  WDLG_RTZOOM* wdlg = wnd->Extension ;
  OBJECT*      popup_level = wdlg->popup_level ;
  char         ids[] = { ZOOMRT_LEVEL, ZOOMRT_SCREEN, ZOOMRT_TSCREEN, ZOOMRT_IMG, ZOOMRT_TIMG, ZOOMRT_SMART, ZOOMRT_TSMART,
                         ZOOMRT_USEGEM, ZOOMRT_TUSEGEM, ZOOMRT_OPTPOS, ZOOMRT_TOPTPOS, ZOOMRT_SIZE, ZOOMRT_INCSIZE, ZOOMRT_DECSIZE
                       } ;
  short i ;

  if ( show )
  {
    write_text( adr_rtzoom, ZOOMRT_LEVEL, popup_level[zoom2index[config.rt_zoomlevel]].ob_spec.free_string ) ;
    for ( i = 0; i < ARRAY_SIZE(ids); i++ )
      adr_rtzoom[ids[i]].ob_state &= ~DISABLED ;
  }
  else
  {
    for ( i = 0; i < ARRAY_SIZE(ids); i++ )
      adr_rtzoom[ids[i]].ob_state |= DISABLED ;
  }

  for ( i = 0; i < ARRAY_SIZE(ids); i++ )
    xobjc_draw( wnd->window_handle, adr_rtzoom, ids[i] ) ;
}

void OnInitDialogRTZoom(void *w)
{
  GEM_WINDOW*        wnd = (GEM_WINDOW*) w ;
  WEXTENSION_RTZOOM* wext = wnd->DlgData->UserData ;
  WDLG_RTZOOM*       wdlg = wnd->Extension ;
  OBJECT*            adr_prtzoom = wnd->DlgData->BaseObject ;
  int                i ;
  char               buf[50] ;

  memcpy( &wext->cfg, &config, sizeof(VISION_CFG) ) ;

  /* ZOOMRT_VALID, ZOOMRT_USEGEM and ZOOMRT_OPTPOS should not */
  /* Have RADIOBUTTON set in resource; Fix it here rather     */
  /* Than changing all resource files                         */
  adr_prtzoom[ZOOMRT_VALID].ob_flags  &= ~RBUTTON ;
  adr_prtzoom[ZOOMRT_USEGEM].ob_flags &= ~RBUTTON ;
  adr_prtzoom[ZOOMRT_OPTPOS].ob_flags &= ~RBUTTON ;

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

static void draw_objs(int hwnd, OBJECT* adr_prtzoom)
{
  xobjc_draw( hwnd, adr_prtzoom, ZOOMRT_IMG ) ;
  xobjc_draw( hwnd, adr_prtzoom, ZOOMRT_SCREEN ) ;
  xobjc_draw( hwnd, adr_prtzoom, ZOOMRT_SMART ) ;
}

static int OnObjectNotifyRTZoom(void *w, int obj)
{
  GEM_WINDOW        *wnd = (GEM_WINDOW*) w ;
  WEXTENSION_RTZOOM *wext = wnd->DlgData->UserData ;
  WDLG_RTZOOM       *wdlg = wnd->Extension ;
  OBJECT            *adr_prtzoom = wnd->DlgData->BaseObject ;
  int               code = -1 ;
  int               i, off_x, off_y ;
  char              buf[50] ;

  switch( obj )
  {
    case ZOOMRT_TVALID  : inv_select( adr_prtzoom, ZOOMRT_VALID ) ;
    case ZOOMRT_VALID   : config.use_rtzoom = 1 - config.use_rtzoom ;
                          show_prtzoom( config.use_rtzoom, wnd ) ;
                          break ;
    case ZOOMRT_IMG     :
    case ZOOMRT_TIMG    : select( adr_prtzoom, ZOOMRT_IMG ) ;
                          deselect( adr_prtzoom, ZOOMRT_SCREEN ) ;
                          deselect( adr_prtzoom, ZOOMRT_SMART ) ;
                          draw_objs( wnd->window_handle, adr_prtzoom ) ;
                          break ;
    case ZOOMRT_SCREEN  :
    case ZOOMRT_TSCREEN : select( adr_prtzoom, ZOOMRT_SCREEN ) ;
                          deselect( adr_prtzoom, ZOOMRT_IMG ) ;
                          deselect( adr_prtzoom, ZOOMRT_SMART ) ;
                          draw_objs( wnd->window_handle, adr_prtzoom ) ;
                          break ;
    case ZOOMRT_SMART  :
    case ZOOMRT_TSMART :  select( adr_prtzoom, ZOOMRT_SMART ) ;
                          deselect( adr_prtzoom, ZOOMRT_IMG ) ;
                          deselect( adr_prtzoom, ZOOMRT_SCREEN ) ;
                          draw_objs( wnd->window_handle, adr_prtzoom ) ;
                          break ;
    case ZOOMRT_TUSEGEM : inv_select( adr_prtzoom, ZOOMRT_USEGEM ) ;
                          break ;
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

  return code ;
}

int OnCloseDlgRTZoom(void *w)
{
  GEM_WINDOW  *wnd = (GEM_WINDOW*) w ;
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

  /* Disable Real Time Zoom */
  RTZoomDisable  = 1 ;
  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId       = FORM_ZOOMRT ;
  strcpy( dlg_data.Title, MsgTxtGetMsg(hMsg, MSG_WFNAMES)  ) ;
  dlg_data.UserData       = &wext ;
  dlg_data.OnInitDialog   = OnInitDialogRTZoom ;
  dlg_data.OnObjectNotify = OnObjectNotifyRTZoom ;
  dlg_data.OnCloseDialog  = OnCloseDlgRTZoom ;
  dlg_data.ExtensionSize  = sizeof(WDLG_RTZOOM) ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, -1 ) ;

  /* Enable Real Time Zoom */
  RTZoomDisable = 0 ;
  if ( code == IDOK ) UpdateRTZoom4App( config.use_rtzoom ) ;

  return( code == IDOK ) ;
}