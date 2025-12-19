#include  <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

#include     "..\tools\stdprog.h"
#include     "..\tools\stdinput.h"
#include     "..\tools\xgem.h"
#include     "..\tools\gwindows.h"
#include "..\tools\fastzoom.h"
#include "..\tools\rasterop.h"

#include    "defs.h"
#include  "rtzoom.h"
#include "actions.h"
#include "visionio.h"

#define ATTR_WRTZOOM    (NAME | MOVER | CLOSER)

GEM_WINDOW* WndRTZoom ;
MFDB RTZoomSrc ;
MFDB RTZoomSrcStd ;
MFDB RTZoomDst ;
MFDB RTZoomDstStd ;
int  rtx, rty, rtw, rth ;
int  rtoffx, rtoffy ;
int  deltax, deltay ;
int  smart_offx ;
char RTZoomDisable = 0 ;
char StdVDINeeded = 0 ;


static int init_rtmemory(void)
{
  int err = 0 ;

  if ( RTZoomSrc.fd_addr )    Xfree( RTZoomSrc.fd_addr ) ;
  if ( RTZoomDst.fd_addr )    Xfree( RTZoomDst.fd_addr ) ;
  if ( RTZoomSrcStd.fd_addr ) Xfree( RTZoomSrcStd.fd_addr ) ;
  if ( RTZoomDstStd.fd_addr ) Xfree( RTZoomDstStd.fd_addr ) ;

  ZeroMFDB( &RTZoomSrc ) ;
  RTZoomSrc.fd_w       = ALIGN16( config.rt_width / config.rt_zoomlevel ) ;
  RTZoomSrc.fd_wdwidth = W2WDWIDTH( RTZoomSrc.fd_w ) ;
  RTZoomSrc.fd_h       = config.rt_height / config.rt_zoomlevel ;
  RTZoomSrc.fd_nplanes = screen.fd_nplanes ;
  RTZoomSrc.fd_addr    = img_alloc( RTZoomSrc.fd_w, RTZoomSrc.fd_h, RTZoomSrc.fd_nplanes ) ;
  if ( RTZoomSrc.fd_addr == NULL ) err = -3 ;
  else                             img_raz( &RTZoomSrc ) ;

  if ( !err )
  {
    ZeroMFDB( &RTZoomDst ) ;
    RTZoomDst.fd_w = RTZoomSrc.fd_w * config.rt_zoomlevel ;
    RTZoomDst.fd_wdwidth = RTZoomDst.fd_w / 16 ;
    if ( RTZoomDst.fd_w %16 ) RTZoomDst.fd_wdwidth++ ;
    RTZoomDst.fd_h = config.rt_height ; 
    RTZoomDst.fd_nplanes = screen.fd_nplanes ;
    RTZoomDst.fd_addr = img_alloc( RTZoomDst.fd_w, RTZoomDst.fd_h, RTZoomDst.fd_nplanes ) ;
    if ( RTZoomDst.fd_addr == NULL )
    {
      err = -3 ;
      Xfree( RTZoomSrc.fd_addr ) ;
      ZeroMFDB( &RTZoomSrc ) ;
    }
    else img_raz( &RTZoomDst ) ;
  }

  StdVDINeeded = (char)FZNeedStdFormat ;
  if ( !err && StdVDINeeded )
  {
    /* Il va y avoir des allocations suppl‚mentaires */
    CopyMFDB( &RTZoomSrcStd, &RTZoomSrc ) ;
    RTZoomSrcStd.fd_stand = 1 ;
    RTZoomSrcStd.fd_addr  = img_alloc( RTZoomSrcStd.fd_w, RTZoomSrcStd.fd_h, RTZoomSrcStd.fd_nplanes ) ;
    if ( RTZoomSrcStd.fd_addr == NULL )
    {
      err = -3 ;
      if ( RTZoomSrc.fd_addr ) Xfree( RTZoomSrc.fd_addr ) ;
      ZeroMFDB( &RTZoomSrc ) ;
      Xfree( RTZoomDst.fd_addr ) ;
      ZeroMFDB( &RTZoomDst ) ;
    }
    else img_raz( &RTZoomSrcStd ) ;

    if ( !err )
    {
      CopyMFDB( &RTZoomDstStd, &RTZoomDst ) ;
      RTZoomDstStd.fd_stand = 1 ;
      RTZoomDstStd.fd_addr  = img_alloc( RTZoomDstStd.fd_w, RTZoomDstStd.fd_h, RTZoomDstStd.fd_nplanes ) ;
      if ( RTZoomDstStd.fd_addr == NULL )
      {
        err = -3 ;
        Xfree( RTZoomSrcStd.fd_addr ) ;
        ZeroMFDB( &RTZoomSrcStd ) ;
        if ( RTZoomSrc.fd_addr ) Xfree( RTZoomSrc.fd_addr ) ;
        ZeroMFDB( &RTZoomSrc ) ;
        if ( RTZoomDst.fd_addr ) Xfree( RTZoomDst.fd_addr ) ;
        ZeroMFDB( &RTZoomDst ) ;
      }
      else img_raz( &RTZoomDstStd ) ;
    }
  }
  
  return err ;
}

static void OnMoveRTZoom(void* wind, int xywh[4])
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) wind ;
  int         mask = 0xFFFF ;
  int         x, y, w, h ;

  if ( config.rt_optimizepos ) mask = 0xFFF0 ;
    wind_calc( WC_WORK, NAME | MOVER, xywh[0], xywh[1], xywh[2], xywh[3], &x, &y, &w, &h ) ;
  x &= mask ;
  wind_calc( WC_BORDER, NAME | MOVER, x, y, w, h, &xywh[0], &xywh[1], &xywh[2], &xywh[3] ) ;
  wind_set( wnd->window_handle, WF_CURRXYWH, xywh[0], xywh[1], xywh[2], xywh[3] ) ;
  wind_get( wnd->window_handle, WF_WORKXYWH, &rtx, &rty, &rtw, &rth ) ;
}

#pragma warn -par
static int OnCloseRTZoom(void* wnd)
{
  if ( RTZoomDstStd.fd_addr ) Xfree( RTZoomDstStd.fd_addr ) ;
  ZeroMFDB( &RTZoomDstStd ) ;
  if ( RTZoomSrcStd.fd_addr ) Xfree( RTZoomSrcStd.fd_addr ) ;
  ZeroMFDB( &RTZoomSrcStd ) ;
  if ( RTZoomDst.fd_addr ) Xfree( RTZoomDst.fd_addr ) ;
  ZeroMFDB( &RTZoomDst ) ;
  if ( RTZoomSrc.fd_addr ) Xfree( RTZoomSrc.fd_addr ) ;
  ZeroMFDB( &RTZoomSrc ) ;
  WndRTZoom = NULL ;

  return( GWOnClose( wnd ) ) ;
}
#pragma warn +par

#pragma warn -par
static void OnDrawRTZoom(void* wnd, int xycoords[4])
{
  int xy[8] ;
  int index ;
  int must_fill = (rtoffx > 0) || (rtoffy > 0) ;

  if ( must_fill )
  {
    if ( !Truecolor ) index = 0 ;
    else
    {
      int rgb[3] = { 1000, 1000, 1000 } ;

      index = 19 ;
      svs_color( index, rgb ) ;
    }
    (void) svswr_mode( MD_REPLACE ) ;
    svsf_color(  index ) ;
    svsf_interior( FIS_SOLID ) ;
    svsf_perimeter( 0 ) ;
  }

  if ( intersect( rtx + rtoffx, rty + rtoffy, rtw - rtoffx, rth - rtoffy,
                  xycoords[0], xycoords[1], xycoords[2], xycoords[3],
                  &xy[4] )
     )
  {
    xy[0] = smart_offx + xy[4] - rtx - rtoffx ;
    xy[1] = xy[5] - rty - rtoffy ;
    xy[2] = smart_offx + xy[6] - rtx - rtoffx ;
    xy[3] = xy[7] - rty - rtoffy ;
    svro_cpyfmSOS( xy, &RTZoomDst ) ;

    if ( must_fill )
    {
      if ( intersect( rtx, rty, rtoffx, rth, xycoords[0], xycoords[1], xycoords[2], xycoords[3], xy ) )
        svr_recfl( xy ) ;
      if ( intersect( rtx, rty, rtw, rtoffy, xycoords[0], xycoords[1], xycoords[2], xycoords[3], xy ) )
        svr_recfl( xy ) ;
    }
  }
}
#pragma warn +par

void rtzoom_display(int mx, int my, int from_screen)
{
  GEM_WINDOW* gwnd ;
  VXIMAGE*    vimage = NULL ;
  FZOOM_DATA  rt_data ;
  MFDB*       src ;
  int         x1, x2, y1, y2 ;
  int         xi, yi, wx, wy ;
  int         xx1, yy1 ;
  int         xlimit, ylimit ;
  int         xy[8] ;
  int         do_it = 1 ;
  int         hide_mouse ;

  if ( WndRTZoom == NULL ) return ;
  if ( !config.use_rtzoom || RTZoomDisable ) return ;
  hide_mouse = ( from_screen && config.rt_hidemouse ) ;
  gwnd = GWGetWindow( mx, my ) ;
  if ( ( gwnd == NULL ) && !from_screen ) return ;
  if ( gwnd ) vimage = (VXIMAGE *) gwnd->Extension ;
  if ( !from_screen && strcmp( gwnd->ClassName, VIMG_CLASSNAME ) ) return ;

  xx1 = yy1 = 0 ;
  if ( from_screen )
  {
    xi = yi = 0 ;
    wx = screen.fd_w ;
    wy = screen.fd_h ;
  }
  else gwnd->GetWorkXYWH( gwnd, &xi ,&yi, &wx, &wy ) ;

  if ( (mx >= xi) && (my >= yi) && (mx < xi+wx) && (my < yi+wy) )
  {
    if ( !from_screen )
    {
      x1     = vimage->x1 + ( mx - xi ) / vimage->zoom_level ;
      y1     = vimage->y1 + ( my - yi ) / vimage->zoom_level ;
      xlimit = vimage->inf_img.mfdb.fd_w ;
      ylimit = vimage->inf_img.mfdb.fd_h ;
      src    = &vimage->inf_img.mfdb ;
    }
    else
    {
      x1     = mx ;
      y1     = my ;
      xlimit = screen.fd_w ;
      ylimit = screen.fd_h ;
      src    = &screen ;
    }
  }
  else
  {
    img_raz( &RTZoomSrc ) ;
    do_it = 0 ;
  }

  if ( do_it )
  {
    x2 = -1 + x1 + deltax ;
    x1 = x1 - deltax ;
    y2 = -1 + y1 + deltay ;
    y1 = y1 - deltay ;
    if ( (x1 < 0) || (y1 < 0) || (x2 >= xlimit) || (y2 >= ylimit) )
    {
      if ( x1 < 0 )
      {
        xx1 = -x1 ;
        x1  = 0 ;
        x2 += xx1 ;
      }
      if ( y1 < 0 )
      {
        yy1 = -y1 ;
        y1  = 0 ;
        y2 += yy1 ;
      }
      if ( x2 >= xlimit ) x2 = xlimit - 1 ;
      if ( y2 >= ylimit ) y2 = ylimit - 1 ;
      img_raz( &RTZoomSrc ) ;
      if ( StdVDINeeded ) img_raz( &RTZoomDstStd ) ;
      else                img_raz( &RTZoomDst ) ;
    }

    xy[0] = x1 ; xy[1] = y1 ;
    xy[2] = x2 ; xy[3] = y2 ;
    xy[4] = 0 ;  xy[5] = 0 ;
    xy[6] = x2 - x1 ;
    xy[7] = y2 - y1 ;
    if ( hide_mouse ) GWHideCursor() ;
    svro_cpyfmSO( xy, src, &RTZoomSrc ) ;
    if ( hide_mouse ) GWShowCursor() ;
    x1 = xy[4] ; y1 = xy[5] ;
    x2 = xy[6] ; y2 = xy[7] ;

    switch( config.rt_zoomlevel )
    {
      case 1 : 
                xy[0] = x1 ;  xy[1] = y1 ;
                xy[2] = x2 ;  xy[3] = y2 ;
                xy[4] = 0 ; xy[5] = 0 ;
                xy[6] = x2 - x1 ;
                xy[7] = y2 - y1 ;
                svro_cpyfmSO( xy, &RTZoomSrc, &RTZoomDst ) ;
                rtoffx = xx1 ;
                rtoffy = yy1 ;
                break ;
      default : 
                rt_data.src  = &RTZoomSrc ;
                rt_data.zoom = config.rt_zoomlevel ;
                rt_data.dst  = &RTZoomDst ;
                if ( StdVDINeeded )
                {
                  rt_data.std_src = &RTZoomSrcStd ;
                  rt_data.std_dst = &RTZoomDstStd ;
                }
                else
                {
                  rt_data.std_src = NULL ;
                  rt_data.std_dst = NULL ;
                }
                FastZoom( &rt_data ) ;
                rtoffx = xx1 * config.rt_zoomlevel ;
                rtoffy = yy1 * config.rt_zoomlevel ;
                break ;
    }
  }

  GWRePaint( WndRTZoom ) ;
}

#pragma warn -par
static int OnRButtonDownRTZoom(void* w, int mk_state, int mx, int my)
{
  GEM_WINDOW* wnd = w ;
  OBJECT*     popup ;
  int         clicked ;
  int         i, wx, wy, dummy ;

  popup = popup_make( 6, 15 ) ;
  if ( popup == NULL ) return 0 ;

  for ( i = 0; i <= 4; i++ )
    sprintf( popup[1+i].ob_spec.free_string, "  Zoom x %d ", 1 << i ) ;
  sprintf( popup[1+i].ob_spec.free_string, "  Options... " ) ;

  wnd->GetWorkXYWH( wnd, &wx, &wy, &dummy, &dummy ) ;
  clicked = popup_formdo( &popup, wx+mx-16, wy+my, 1, 0 ) - 1 ;
  popup_kill( popup, 6 ) ;

  if ( clicked >= 0 )
  {
    if ( clicked < 5 ) rtzoom_change_level( 1 << clicked ) ;
    else               pref_rtzoom() ;
    RTZoomDisable = 0 ;
  }

  return 0 ;
}
#pragma warn +par

static int init_rtwindow(void)
{
  char name[50] ;
  int err = 0 ;

  if ( WndRTZoom ) WndRTZoom->OnClose( WndRTZoom ) ;

  WndRTZoom = GWCreateWindow( ATTR_WRTZOOM, 0, RTZOOM_CLASSNAME ) ;
  if ( WndRTZoom )
  {
    int mask = 0xFFFF ;
    int x, y, w, h ;

    if ( config.rt_optimizepos ) mask = 0xFFF0 ;
    wind_calc( WC_BORDER, ATTR_WRTZOOM, (Xmax-config.rt_width) & mask, Ymax-config.rt_height, config.rt_width, config.rt_height, &x, &y, &w, &h ) ;
    WndRTZoom->OnDraw        = OnDrawRTZoom ;
    WndRTZoom->OnMove        = OnMoveRTZoom ;
    WndRTZoom->OnClose       = OnCloseRTZoom ;
    WndRTZoom->OnRButtonDown = OnRButtonDownRTZoom ;
    GWOpenWindow( WndRTZoom, x, y, w, h ) ;
    sprintf( name, vMsgTxtGetMsg(MSG_TITRERTZOOM) , config.rt_zoomlevel ) ;
    GWSetWindowCaption( WndRTZoom, name ) ;
    wind_get( WndRTZoom->window_handle, WF_WORKXYWH, &rtx, &rty, &rtw, &rth ) ;
  }
  else err = -3 ;

  return err ;
}

int rtzoom_init(void)
{
  int err = 0 ;

  init_fztab( config.rt_zoomlevel ) ;

  err = init_rtmemory() ;

  if ( !err ) init_rtwindow() ;

  deltax     = RTZoomSrc.fd_w >> 1 ;
  smart_offx = ( RTZoomDst.fd_w - config.rt_width ) >> 1 ;
  deltay     = config.rt_height / config.rt_zoomlevel >> 1 ;
  
  return err ;
}

void rtzoom_free(void)
{
  if ( WndRTZoom ) WndRTZoom->OnClose( WndRTZoom ) ;
  WndRTZoom = NULL ;
}

void rtzoom_change_level(int new_level)
{
  char name[50] ;

  if ( new_level != config.rt_zoomlevel )
  {
    config.rt_zoomlevel = new_level ;
    init_fztab( new_level ) ;
    init_rtmemory() ;
    deltax     = RTZoomSrc.fd_w >> 1 ;
    smart_offx = ( RTZoomDst.fd_w - config.rt_width ) >> 1 ;
    deltay     = config.rt_height / config.rt_zoomlevel >> 1 ;
    sprintf( name, vMsgTxtGetMsg(MSG_TITRERTZOOM) , config.rt_zoomlevel ) ;
    wind_set( WndRTZoom->window_handle, WF_NAME, name ) ;
  }
}
