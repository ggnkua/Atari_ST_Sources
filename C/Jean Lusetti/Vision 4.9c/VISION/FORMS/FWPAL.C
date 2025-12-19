#include <string.h>
#include <math.h>
#include "..\tools\gwindows.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

#include "actions.h"
#include "visionio.h"
#include "fwpal.h"
#include "fpal.h"
#include "..\vtoolbar.h"

typedef struct
{
  GEM_WINDOW* vwnd ;
  int         nbcx, nbcy ;
  int         taille ;

  /* Restauration des parametres pour OnRestoreFulled */
  int rf_nbcx, rf_nbcy ;
  int rf_taille ;
}
WEXTENSION_SELPALINDEX ;

GEM_WINDOW* WndSelPalIndex ;
int        old_nbplane ;
int        nbcx, nbcy, taille ;
int        xb, yb ;

#pragma warn -par
int OnLButtonDownSelPalIndex(void *w, int mk_state, int x, int y)
{
  GEM_WINDOW             *wnd = (GEM_WINDOW*) w ;
  WEXTENSION_SELPALINDEX *wext = wnd->Extension ;
  int                    index ;
  char                   flag[1+NB_TOOLS] ;

  index = x / wext->taille + wext->nbcx * ( y / wext->taille ) ;
  ltype.color = mtype.color = ftype.color = ttype.color = pencil.color = index ;

  GWInvalidate( wnd ) ;
  memzero( flag, 1 + NB_TOOLS ) ;
  flag[PALETTE] = 1 ;
  VToolBarUpdate( flag ) ;

  return GW_EVTSTOPROUTING ;
}

int OnRButtonDownSelPalIndex(void *w, int mk_state, int x, int y)
{
  GEM_WINDOW             *wnd = (GEM_WINDOW*) w ;
  WEXTENSION_SELPALINDEX *wext = wnd->Extension ;

  traite_makepalette( wext->vwnd ) ;

  return GW_EVTSTOPROUTING ;
}

int OnMouseMoveSelPalIndex(void *w, int button, int kstate, int mx, int my )
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
  int        rgb[3] ;
  int        xi, yi, index, dummy ;
  char       buf[100] ;

  buf[0] = 0 ;
  if ( mx >= 0 )
  {
    wnd->GetWorkXYWH( wnd, &xi, &yi, &dummy, &dummy ) ;
    GWHideCursor() ;
    v_get_pixel( handle, xi + mx, yi + my, &dummy, &index ) ;
    GWShowCursor() ;
    svq_color( index, 1, rgb ) ;
    sprintf( buf, vMsgTxtGetMsg(MSG_RVB), rgb[0], rgb[1], rgb[2], index ) ;
  }
  GWSetWindowInfo( wnd, buf ) ;

  return GW_EVTSTOPROUTING ;
}

#pragma warn +par

int OnCloseSelPalIndex(void *w)
{
  GEM_WINDOW             *wnd = GemApp.CurrentGemWindow ;
  WEXTENSION_SELPALINDEX *wext = wnd->Extension ;
  int                    dummy ;

  WndSelPalIndex = NULL ;
  nbcx        = wext->nbcx ;
  nbcy        = wext->nbcy ;
  taille      = wext->taille ;
  old_nbplane = screen.fd_nplanes ;
  GWGetCurrXYWH( wnd, &xb, &yb, &dummy, &dummy ) ;
 
  return( GWOnClose( w ) ) ;
}

int OnToppedSelPalIndex(void *w)
{
  GEM_WINDOW             *wnd = GemApp.CurrentGemWindow ;
  WEXTENSION_SELPALINDEX *wext = WndSelPalIndex->Extension ;

  if ( strcmp( wnd->ClassName, VIMG_CLASSNAME ) == 0 ) wext->vwnd = wnd ;

  return( GWOnTopped( w ) ) ;
}

void OnDrawSelPalIndex(void *wn, int xycoords[4])
{
  GEM_WINDOW             *wnd = (GEM_WINDOW*) wn ;
  WEXTENSION_SELPALINDEX *wext = wnd->Extension ;
  FILL_TYPE              fstyle ;
  LINE_TYPE              lstyle ;
  float                  ftaille ;
  int                    ltaille ;
  int                    xy[10] ;
  int                    x, y, w, h ;
  int                    xc, yc, xi, yi ;
  int                    nx, index, ix, iy ;

  fstyle.style     = FIS_SOLID ;
  fstyle.color     = 0 ;
  fstyle.perimeter = 0 ;
  svswr_mode( MD_REPLACE) ;
  wnd->GetWorkXYWH( wnd, &xi, &yi, &w, &h ) ;
  nx = (int) ( sqrt( nb_colors )+0.5 ) ;
  if ( wnd->is_icon )
  {
    GWOnDraw( wnd, xycoords ) ;
    ftaille = w / nx ;
  }
  else ftaille = wext->taille ;
  ltaille = (int) ( ftaille + 0.5 ) ;
  for ( yc = 0; yc < wext->nbcy; yc++ )
  {
    y = yi + ftaille * yc ;
    for ( xc = 0; xc < wext->nbcx; xc++ )
    {
      x = xi + ftaille * xc ;
      set_filltype( &fstyle ) ;
      if ( intersect( x, y, ltaille, ltaille, xycoords[0], xycoords[1], xycoords[2], xycoords[3], xy ) )
        svr_recfl( xy ) ;
      fstyle.color++ ;
    }
  }

  /* Met en surbrillance l'index courant */
  if ( !wnd->is_icon )
  {
    index = mtype.color ;
    ix    = index % wext->nbcx ;
    iy    = index / wext->nbcx ;
    xy[0] = xi + ix * ftaille ;     xy[1] = yi + iy * ftaille ;
    xy[2] = xi + (1+ix) * ftaille ; xy[3] = yi + iy * ftaille ;
    xy[4] = xi + (1+ix) * ftaille ; xy[5] = yi + (1+iy) * ftaille ;
    xy[6] = xi + ix * ftaille ;     xy[7] = yi + (1+iy) * ftaille ;
    xy[8] = xy[0] ;                 xy[9] = xy[1] ;
    lstyle.color   = index ;
    lstyle.style   = 1 ;
    lstyle.st_kind = 0 ;
    lstyle.ed_kind = 0 ;
    lstyle.width   = 3 ;
    set_linetype( &lstyle ) ;
    (void)svswr_mode( MD_XOR ) ;
    sv_pline( 5, xy ) ;
  }
}

void AdjustTabForDim(GEM_WINDOW* wnd, int xywh[4])
{
  WEXTENSION_SELPALINDEX *wext = wnd->Extension ;
  long                   lmin ;
  int                    npower, xi, yi, wi, hi ;

  wind_calc( WC_WORK, wnd->window_kind, xywh[0], xywh[1], xywh[2], xywh[3], &xi, &yi, &wi, &hi ) ;
  if ( wi > hi ) lmin = hi ;
  else           lmin = wi ;
  wext->taille = (int) ( ( lmin*lmin ) / (long)nb_colors ) ;
  wext->taille = (int) sqrt( (float)wext->taille ) ;
  if ( wext->taille < 8 ) wext->taille = 8 ;
  wext->nbcx   = wi / wext->taille ;
  if ( wext->nbcx > 128 ) wext->nbcx = 128 ;
  for ( npower = 7; npower > 1; npower-- )
    if ( pow( 2, npower ) <  wext->nbcx ) break ;

  wext->nbcx = pow( 2, npower ) ;
  wext->nbcy = nb_colors / wext->nbcx ;
  while ( wext->nbcy * wext->taille > hdesk - 64 )  wext->taille-- ;
}

void OnSizeSelPalIndex(void *w, int xywh[4])
{
  GEM_WINDOW             *wnd = (GEM_WINDOW*) w ;
  WEXTENSION_SELPALINDEX *wext = wnd->Extension ;
  int                    xi, yi, dummy ;

  AdjustTabForDim( wnd, xywh ) ;
  wind_calc( WC_WORK, wnd->window_kind, xywh[0], xywh[1], xywh[2], xywh[3], &xi, &yi, &dummy, &dummy ) ;
  wind_calc( WC_BORDER, wnd->window_kind, xi, yi, wext->nbcx * wext->taille, wext->nbcy * wext->taille, &xywh[0], &xywh[1], &xywh[2], &xywh[3] ) ;

  GWOnSize( w, xywh ) ;
}

void SetMaxWindow(WEXTENSION_SELPALINDEX *wext)
{
  switch( screen.fd_nplanes )
  {
    case 1 : wext->nbcx = 2 ;
             wext->nbcy = 1 ;
             break ;
    case 2 : wext->nbcx = 2 ;
             wext->nbcy = 2 ;
             break ;
    case 4 : wext->nbcx = 4 ;
             wext->nbcy = 4 ;
             break ;
    case 8 : wext->nbcx = 16 ;
             wext->nbcy = 16 ;
             break ;
  }
  if ( wdesk > hdesk ) wext->taille = ( hdesk - 32 ) / wext->nbcx ;
  else                 wext->taille = ( wdesk - 32 ) / wext->nbcx ;
  wext->taille = ( wext->taille * 3 ) / 10 ;
}

int OnFulledSelPalIndex(void *w)
{
  GEM_WINDOW             *wnd = (GEM_WINDOW*) w ;
  WEXTENSION_SELPALINDEX *wext = wnd->Extension ;
  int                    xywh[4] ;

  wext->rf_nbcx   = wext->nbcx ;
  wext->rf_nbcy   = wext->nbcy ;
  wext->rf_taille = wext->taille ;
  SetMaxWindow( wext ) ;
  wind_calc( WC_BORDER, WndSelPalIndex->window_kind, 0, 0,
             wext->nbcx * wext->taille, wext->nbcy * wext->taille, &xywh[0], &xywh[1], &xywh[2], &xywh[3] ) ;
  xywh[0] = xdesk + ( wdesk-wext->taille * wext->nbcx ) >> 1 ;
  xywh[1] = ydesk ;

  return( GWOnFulled( wnd, xywh ) ) ;
}

int OnRestoreFulledSelPalIndex(void *w)
{
  GEM_WINDOW             *wnd = (GEM_WINDOW*) w ;
  WEXTENSION_SELPALINDEX *wext = wnd->Extension ;
  int                    xywh[4]  ;

  wind_get( wnd->window_handle, WF_PREVXYWH, &xywh[0], &xywh[1], &xywh[2], &xywh[3] ) ;
  AdjustTabForDim( wnd, xywh ) ;
  wext->nbcx   = wext->rf_nbcx ;
  wext->nbcy   = wext->rf_nbcy ;
  wext->taille = wext->rf_taille ;
  GWOnRestoreFulled( wnd, NULL ) ;

  return 0 ;
}

GEM_WINDOW* SelPalIndexCreateWindow(void)
{
  return( GWCreateWindow( NAME | SIZER | MOVER | INFO | CLOSER | FULLER, sizeof(WEXTENSION_SELPALINDEX), SETPALINDEX_CLASSNAME ) ) ;
}

void traite_selpalindex(GEM_WINDOW* cur_window)
{
  WEXTENSION_SELPALINDEX *wext ;
  int                    x, y, w, h ;
  int                    xo, yo ;

  if ( WndSelPalIndex ) PostMessage( WndSelPalIndex, WM_TOPPED, NULL ) ;
  else
  {
    WndSelPalIndex = SelPalIndexCreateWindow() ;
    if ( WndSelPalIndex )
    {
      wext       = WndSelPalIndex->Extension ;
      wext->vwnd = cur_window ;
      if ( old_nbplane == screen.fd_nplanes )
      {
        wext->nbcx   = nbcx ;
        wext->nbcy   = nbcy ;
        wext->taille = taille ;
        xo           = xb ;
        yo           = yb ;
      }
      else
      {
        SetMaxWindow( wext ) ;
        xo = xdesk + ( wdesk-wext->taille * wext->nbcx ) >> 1 ;
        yo = ydesk ;
      }
      WndSelPalIndex->OnTopped        = OnToppedSelPalIndex ;
      WndSelPalIndex->OnDraw          = OnDrawSelPalIndex ;
      WndSelPalIndex->OnClose         = OnCloseSelPalIndex ;
      WndSelPalIndex->OnFulled        = OnFulledSelPalIndex ;
      WndSelPalIndex->OnRestoreFulled = OnRestoreFulledSelPalIndex ;
      WndSelPalIndex->OnLButtonDown   = OnLButtonDownSelPalIndex ;
      WndSelPalIndex->OnRButtonDown   = OnRButtonDownSelPalIndex ;
      WndSelPalIndex->OnMouseMove     = OnMouseMoveSelPalIndex ;
      WndSelPalIndex->OnSize          = OnSizeSelPalIndex ;
      WndSelPalIndex->flags          |= FLG_MUSTCLIP ;

      GWSetWindowCaption( WndSelPalIndex, vMsgTxtGetMsg(MSG_PALETTEDISPO)  ) ;
      wind_calc( WC_BORDER, WndSelPalIndex->window_kind, xdesk + ( wdesk - wext->taille * wext->nbcx ) >> 1, ydesk + ( hdesk - wext->taille * wext->nbcy ) >> 1,
                 wext->nbcx * wext->taille, wext->nbcy * wext->taille, &x, &y, &w, &h ) ;
      GWOpenWindow( WndSelPalIndex, xo, yo, w, h ) ;
    }
    else vform_stop( MSG_NOMOREWINDOW ) ;
  }
}
