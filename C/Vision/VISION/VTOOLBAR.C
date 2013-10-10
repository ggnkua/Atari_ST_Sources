#include <string.h>
#include "..\tools\gwindows.h"

#include     "defs.h"
#include "vtoolbar.h"
#include "gstenv.h"

GEM_WINDOW * WndToolBar ;
OBJECT     *adr_icones ;

void OnMoveVToolBar(void *w, int xywh[4])
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  int        xt, yt, dummy ;

  GWOnMove( wnd, xywh ) ;
  wind_get( wnd->window_handle, WF_WORKXYWH, &xt, &yt, &dummy, &dummy) ;
  adr_icones[0].ob_x = xt ;
  adr_icones[0].ob_y = yt ;
}

int OnCloseVToolBar(void *wnd)
{
  GWShowWindow( (GEM_WINDOW *)wnd, 0 ) ;
 
  return( GW_EVTCONTINUEROUTING ) ;
}

void draw_zoombox(int xclip, int yclip, int wclip, int hclip)
{
  objc_draw(adr_icones, ZOOM_BOX, 5, xclip, yclip, wclip, hclip) ;
}

void OnDrawVToolBar(void *wd, int xywh[4])
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) wd ;
  int        xy[4] ;
  int        xyc[4] ;
  int        x, y, w, h ;
  int        xt, yt ;
  int        dummy, i ;
  
  x = xywh[0] ; y = xywh[1] ;
  w = xywh[2] ; h = xywh[3] ;
  wind_get( wnd->window_handle, WF_WORKXYWH, &xt, &yt, &dummy, &dummy ) ;
  adr_icones[0].ob_x = xt ;
  adr_icones[0].ob_y = yt ;
  for ( i = 1; i <= ZOOM_BOX; i++ )
  {
    objc_offset( adr_icones, i, &xy[0], &xy[1] ) ;
    xy[2] = adr_icones[i].ob_width ;
    xy[3] = adr_icones[i].ob_height ;
    if ( intersect( x, y, w, h, xy[0], xy[1], xy[2], xy[3], xyc ) )
    {
      if ( i == PALETTE )
      {
        vswr_mode(handle, MD_REPLACE) ;
        vsf_color(handle, ftype.color) ;
        vsf_interior(handle, FIS_SOLID) ;
        vsf_perimeter(handle, 1) ;
        vr_recfl( handle, xyc ) ;
      }
      objc_draw( adr_icones, i, 5, xyc[0], xyc[1],
                 xyc[2]-xyc[0]+1, xyc[3]-xyc[1]+1 ) ;
    }
  }
}

void VToolsPut(int haute_resolution)
{
  if ( haute_resolution )
  {
    adr_icones[POINT].ob_y         = adr_icones[TRACE].ob_y     = 0 ;
    adr_icones[PINCEAU].ob_y       = adr_icones[AEROSOL].ob_y   = 24 ;
    adr_icones[KLIGNE].ob_y        = adr_icones[LIGNE].ob_y     = 48 ;
    adr_icones[CERCLE].ob_y        = adr_icones[RECTANGLE].ob_y = 72 ;
    adr_icones[DISQUE].ob_y        = adr_icones[PLAN].ob_y      = 96 ;
    adr_icones[PEINTURE].ob_y      = adr_icones[GOMME].ob_y     = 120 ;
    adr_icones[TEXTE].ob_y         = adr_icones[LOUPE].ob_y     = 144 ;
    adr_icones[TEMPERATURE].ob_y   = adr_icones[TABLEAU].ob_y   = 168 ;
    adr_icones[MAIN].ob_y          = adr_icones[BLOC].ob_y      = 192 ;
    adr_icones[PALETTE].ob_y       = 216 ;
    adr_icones[ZOOM_BOX].ob_y      = 240 ;
    adr_icones[ZOOM_BOX].ob_height = 48 ;
    adr_icones[0].ob_height        = 288 ;
  }
  else if ( aspectratio < 0.99 )
  {
    adr_icones[TRACE].ob_y = adr_icones[AEROSOL].ob_y   = 24 ;
    adr_icones[LIGNE].ob_y = adr_icones[RECTANGLE].ob_y = 24 ;
    adr_icones[PLAN].ob_y  = adr_icones[GOMME].ob_y     = 24 ;
    adr_icones[LOUPE].ob_y = adr_icones[TABLEAU].ob_y   = 24 ;
    adr_icones[BLOC].ob_y  = adr_icones[ZOOM_BOX].ob_y  = 24 ;
    adr_icones[ZOOM_BOX].ob_height = 24 ;
    adr_icones[0].ob_height        = 48 ;
  }
}

void VToolBarShow(int show)
{
  int dummy, largeur, hauteur ;

  largeur = adr_icones[0].ob_width ;
  hauteur = adr_icones[0].ob_height ;
  WndToolBar->vx = xdesk ;
  WndToolBar->vy = ydesk ;
  wind_calc( WC_BORDER, WndToolBar->window_kind, xdesk+32, ydesk+32, largeur, hauteur,
             &dummy, &dummy, &WndToolBar->vw, &WndToolBar->vh ) ;
  if ( show ) config.flags |= FLG_TOOLBAR ;
  else        config.flags &= ~FLG_TOOLBAR ;

  GWShowWindow( WndToolBar, show ) ;
  GWSetWindowCaption( WndToolBar, msg[MSG_TITREOUTIL] ) ;
}

int OnToppedVToolBar(void *wd)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) wd ;
  EVENT      *event = &GemApp.Event ;
  int        x, y ,w, h ;

  wnd->GetWorkXYWH( wnd, &x, &y, &w, &h ) ;
  if ( ( event->ev_mmox >= x ) && ( event->ev_mmox <= x+w-1 ) && ( event->ev_mmoy >= y ) && ( event->ev_mmoy <= y+h-1 ) )
  {
    if ( Kbshift(-1) & 0x00000008L ) param_icon( event->ev_mmox, event->ev_mmoy ) ;
    else                             select_icon( event->ev_mmox, event->ev_mmoy ) ;
  }

  return( 1 ) ; /* Refus du focus */
  /* Si on clique sur un outil et que la touche ALT est appuy‚e, */
  /* On affiche alors la boite de param‚trage de l'outil cliqu‚  */
  /* (Si le lien a un sens) et on ne s‚lectionne pas l'outil     */
}

#pragma warn -par
int OnLButtonDownVToolBar(void *w, int mk_state, int x, int y)
{
  GEM_WINDOW *wnd = w ;
  int wx, wy, dummy ;

  wnd->GetWorkXYWH( wnd, &wx, &wy, &dummy, &dummy ) ;
  x += wx ;
  y += wy ;
  if ( Kbshift( -1 ) == 0x00000008L ) param_icon( x, y ) ;
  else                                select_icon( x, y ) ;
 
  return( 0  ) ;
  /* Si on clique sur un outil et que la touche ALT est appuy‚e,   */
  /* On affiche alors la boite de param‚trage de l'outil cliqu‚    */
  /* (Si le lien a un sens) et on ne s‚lectionne pas l'outil.      */
  /* NB : on n'utilise pas la variable de retour event.ev_mmkstate */
  /*      du evnt_multi car cet ‚vŠnement peut ‚galement provenir  */
  /*      d'un ‚vŠnement GEM TOPPED car la fenˆtre Outils n'est    */
  /*      pas en g‚n‚ral la fenˆtre active.                        */
}

int OnRButtonDownVToolBar(void *w, int mk_state, int x, int y)
{
  GEM_WINDOW *wnd = w ;
  int wx, wy, dummy ;

  wnd->GetWorkXYWH( wnd, &wx, &wy, &dummy, &dummy ) ;
  x += wx ;
  y += wy ;
  param_icon( x, y ) ;

  return( 0 ) ;
}
#pragma warn +par

GEM_WINDOW *VToolBarCreateWindow(void)
{
  return( GWCreateWindow( NAME | MOVER | CLOSER, 0, VTOOLBAR_CLASSNAME ) ) ;
}

#pragma warn -par
int OnTxtBubbleVToolBar(void *wnd, int mx, int my, char *txt)
{
  int obj = objc_find( adr_icones, 0, MAX_DEPTH, mx, my ) ;
  int trouve = 1 ;

  switch( obj )
  {
    case POINT       : strcpy(txt, msg[MSG_HPOINT]) ;
                       break ;
    case TRACE       : strcpy(txt, msg[MSG_HTRACE]) ;
                       break ;
    case PINCEAU     : strcpy(txt, msg[MSG_HPINCEAU]) ;
                       break ;
    case AEROSOL     : strcpy(txt, msg[MSG_HAEROSOL]) ;
                       break ;
    case KLIGNE      : strcpy(txt, msg[MSG_HKLIGNES]) ;
                       break ;
    case LIGNE       : strcpy(txt, msg[MSG_HLIGNE]) ;
                       break ;
    case CERCLE      : strcpy(txt, msg[MSG_HCERCLE]) ;
                       break ;
    case RECTANGLE   : strcpy(txt, msg[MSG_HRECTANGLE]) ;
                       break ;
    case DISQUE      : strcpy(txt, msg[MSG_HDISQUE]) ;
                       break ;
    case PLAN        : strcpy(txt, msg[MSG_HPLAN]) ;
                       break ;
    case PEINTURE    : strcpy(txt, msg[MSG_HPEINTURE]) ;
                       break ;
    case GOMME       : strcpy(txt, msg[MSG_HGOMME]) ;
                       break ;
    case TEXTE       : strcpy(txt, msg[MSG_HTEXTE]) ;
                       break ;
    case LOUPE       : strcpy(txt, msg[MSG_HLOUPE]) ;
                       break ;
    case TEMPERATURE : strcpy(txt, msg[MSG_HTEMP]) ;
                       break ;
    case TABLEAU     : strcpy(txt, msg[MSG_HTABLEAU]) ;
                       break ;
    case MAIN        : strcpy(txt, msg[MSG_HMAIN]) ;
                       break ;
    case BLOC        : strcpy(txt, msg[MSG_HBLOC]) ;
                       break ;
    case PALETTE     : strcpy(txt, msg[MSG_HPALETTE]) ;
                       break ;
    case ZOOM_IN     :
    case ZOOM_VUE    :
    case ZOOM_BOX    : strcpy(txt, msg[MSG_HZONE]) ;
                       break ;
    default          : trouve = 0 ;
  }

  return( trouve ) ;
}
#pragma warn +par

void VToolBarInit(int haute_resolution)
{
  Xrsrc_gaddr( R_TREE, CICONES, &adr_icones ) ;
  VToolsPut( haute_resolution ) ;

  WndToolBar = VToolBarCreateWindow() ;
  if ( WndToolBar )
  {
    WndToolBar->OnMove        = OnMoveVToolBar ;
    WndToolBar->OnDraw        = OnDrawVToolBar ;
    WndToolBar->OnTopped      = OnToppedVToolBar ;
    WndToolBar->OnClose       = OnCloseVToolBar ;
    WndToolBar->OnLButtonDown = OnLButtonDownVToolBar ;
    WndToolBar->OnRButtonDown = OnRButtonDownVToolBar ;
    WndToolBar->OnTxtBubble   = OnTxtBubbleVToolBar ;
    WndToolBar->flags &= ~FLG_MUSTCLIP ; 
    VToolBarShow( config.flags & FLG_TOOLBAR ) ;
  }

  adr_icones[ZOOM_IN].ob_x      = 0 ;
  adr_icones[ZOOM_IN].ob_y      = 0 ;
  adr_icones[ZOOM_IN].ob_width  = 0 ;
  adr_icones[ZOOM_IN].ob_height = 0 ;

  adr_icones[ZOOM_VUE].ob_x      = 0 ;
  adr_icones[ZOOM_VUE].ob_y      = 0 ;
  adr_icones[ZOOM_VUE].ob_width  = 0 ;
  adr_icones[ZOOM_VUE].ob_height = 0 ;
}

void VToolBarUpdate(char *flags)
{
  int xyarray[4] ;
  int xy[4] ;
  int x, y, w, h ;
  int rx, ry, rw, rh ;
  int xt, yt ;
  int i ;
  
  wind_get( WndToolBar->window_handle, WF_WORKXYWH, &xt, &yt, &w, &h ) ;
  adr_icones[0].ob_x = xt ;
  adr_icones[0].ob_y = yt ;
  wind_get( WndToolBar->window_handle, WF_FIRSTXYWH, &rx, &ry, &rw, &rh ) ;

  while ( rw != 0 )
  {
    for (i = 1; i <= NB_TOOLS; i++)
    {
      if (flags[i])
      {
        objc_offset( adr_icones, i, &x, &y ) ;
        w = adr_icones[i].ob_width ;
        h = adr_icones[i].ob_height ;
        if ( intersect( x, y, w, h, rx, ry, rw, rh, xyarray ) )
        {
          if ( i == PALETTE )
          {
            xy[0] = xt+adr_icones[i].ob_x ;
            xy[1] = yt+adr_icones[i].ob_y ;
            xy[2] = xy[0]+adr_icones[i].ob_width-1 ;
            xy[3] = xy[1]+adr_icones[i].ob_height-1 ;
            vswr_mode(handle, MD_REPLACE) ;
            vsf_color(handle, ftype.color) ;
            vsf_interior(handle, FIS_SOLID) ;
            vsf_perimeter(handle, 1) ;
            vs_clip(handle, 1, xyarray) ;
            v_hide_c(handle) ;
            vr_recfl(handle, xy) ;
            v_show_c(handle, 1) ;
            vs_clip(handle, 0, xyarray) ;
          }
          if ( i != ZOOM_BOX )
            objc_draw(adr_icones, i, 0, xyarray[0], xyarray[1] ,
                      xyarray[2]-xyarray[0]+1, xyarray[3]-xyarray[1]+1) ;
          else
            draw_zoombox(xyarray[0], xyarray[1] ,
                         xyarray[2]-xyarray[0]+1, xyarray[3]-xyarray[1]+1) ;
        }
      }
    }    
    wind_get( WndToolBar->window_handle, WF_NEXTXYWH, &rx, &ry, &rw, &rh ) ;
  }
}

