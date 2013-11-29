/********************************************/
/* Gestion du catalogue d'images en fenˆtre */
/********************************************/
#include  <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>

#include     "..\tools\stdprog.h"
#include     "..\tools\stdinput.h"
#include     "..\tools\xgem.h"
#include     "..\tools\gwindows.h"
#include    "..\tools\aides.h"
#include  "..\tools\catalog.h"
#include "..\tools\image_io.h"
#include "..\tools\rasterop.h"
#include              "defs.h"

#include   "rtzoom.h"
#include   "gstenv.h"
#include  "touches.h"
#include  "actions.h"
#include "visionio.h"
#include "walbum.h"

#include "forms\fehtml.h"
#include "forms\falbimg.h"

typedef struct
{
  long       cat_index ;
  MFDB       img ;
  INFO_IMAGE info ;
  char       nom[20] ;
  char       com[SIZE_COMMENT] ;
}
VIGNETTE ;

typedef struct
{
  long NumVignetteInfo ;
}
WALB_EXTENSION ;

#define WALB_STYLE (NAME|CLOSER|MOVER|INFO|UPARROW|DNARROW|VSLIDE|SIZER|FULLER|SMALLER)

VIGNETTE *tab_vignette ;
long     start_visible, last_start_visible ;
int      nb_w, nb_h, nb_vignettes, nb_vignettes_max, num_vignette ;
int      xf, yf ;
int      last_x, last_y, last_w, last_h ;
int      h_vignette ;
GEM_WINDOW *WndAlbum ;
char     std_palette = 0 ;

TEXT_TYPE wcat_ttype = { 6, 6, 6, 6, 0, 0, 1, 0, 1, 0 } ;


void show_icon(int i)
{
  VIGNETTE *v ;
  int      txy[4] ;
  int      xy[8] ;
  int      x, y ;
  char     buf[10] ;
  char     *c ;

  v = &tab_vignette[i] ;
  xy[0] = xy[1] = 0 ;
  xy[2] = v->img.fd_w-1 ;
  xy[3] = v->img.fd_h-1 ;
  xy[4] = xf+(i%nb_w)*catalog_header.width ;
  xy[5] = yf+(i/nb_w)*h_vignette ;
  xy[6] = xy[4]+v->img.fd_w-1 ;
  xy[7] = xy[5]+v->img.fd_h-1 ;
  vro_cpyfm(handle, S_ONLY, xy, &v->img, &screen) ;
  vsf_perimeter(handle, 0) ;
  vsf_interior(handle, FIS_HOLLOW) ;
  txy[0] = xy[4] ; txy[1] = 1+xy[7] ;
  txy[2] = xy[6] ; txy[3] = txy[1]+h_vignette-catalog_header.height-1 ;
  vr_recfl(handle, txy) ;
  memcpy(buf, tab_vignette[i].nom, 8) ;
  buf[8] = 0 ;
  c = strchr(buf, ' ') ;
  if (c) *c = 0 ;
  x = (xy[4]+xy[6]) >> 1 ;
  y = 8+xy[7] ;
  v_gtext(handle, x, y, buf) ;
}

void affiche_vignettes(int xywh[4])
{
  int cxy[4] ;
  int i ;
  int cx, cy ;

  for ( i = 0; i < nb_vignettes; i++ )
  {
    cx = xf + ( i % nb_w ) * catalog_header.width ;
    cy = yf + ( i / nb_w ) * h_vignette ;
    if ( intersect( cx, cy, cx + catalog_header.width - 1, cy + catalog_header.height-1,
                    xywh[0], xywh[1], xywh[2], xywh[3], cxy )
       )
    {
      vs_clip( handle, 1, cxy ) ;
      show_icon( i ) ;
      vs_clip( handle, 0, cxy ) ;
    }
  }
}

int charge_vignettes(long start, int flag_aff)
{
  long i ;
  int  cxy[4] ;
  int  x, y, w, h ;
  int  err = 0 ;
  char buf[60] ;

  if (flag_aff)
  {
    WndAlbum->GetWorkXYWH( WndAlbum, &x, &y, &w, &h ) ;
    cxy[0] = x ;     cxy[1] = y ;
    cxy[2] = x+w-1 ; cxy[3] = y+h-1 ;
    vs_clip(handle, 1, cxy) ;
    set_texttype(&wcat_ttype) ;
  }
  mouse_busy() ;
  for (i = 0; i < nb_vignettes; i++)
  {
    sprintf( buf, " %02ld %c", ( i*100 ) / nb_vignettes, '%' ) ;
    GWSetWindowInfo( WndAlbum, buf ) ;
    if ( catalog_loadicon( start+i, &tab_vignette[i].img,
                           &tab_vignette[i].info,
                           tab_vignette[i].com) == -3)
    {
      err = 1 ;
      break ;
    }
    if (!tab_index[start_visible+i].is_visible) tab_vignette[i].nom[0] = 0 ;
    else
    {
      memcpy(tab_vignette[i].nom, tab_index[start+i].name, 8) ;
      tab_vignette[i].nom[8]    = 0 ;
    }
    tab_vignette[i].cat_index = start+i ;
    if (flag_aff) show_icon((int) i) ;
  }

  if (flag_aff) vs_clip(handle, 0, cxy) ;
  last_start_visible = start_visible = start ;
  mouse_restore() ;
  return(err) ;
}

void charge_nvignettes(int pos, long nb)
{
  long i ;
  char buf[100] ;

  mouse_busy() ;
  for (i = pos; i < pos+nb; i++)
  {
    sprintf( buf, "% 02ld %c", ( (i-pos)*100 ) / nb, '%' ) ;
    GWSetWindowInfo( WndAlbum, buf ) ;
    catalog_loadicon( start_visible+i, &tab_vignette[i].img,
                      &tab_vignette[i].info,
                      tab_vignette[i].com) ;
    if (!tab_index[start_visible+i].is_visible) img_raz(&tab_vignette[i].img) ;
    memcpy(tab_vignette[i].nom, tab_index[start_visible+i].name, 8) ;
    tab_vignette[i].nom[8]    = 0 ;
    tab_vignette[i].cat_index = start_visible+i ;
  }

  last_start_visible = start_visible ;
  mouse_restore() ;
}

void ajuste_premiere_vignette(void)
{
  if (start_visible > catalog_filter.nb_visibles-nb_vignettes)
    start_visible = catalog_filter.nb_visibles-nb_vignettes ;
  if (start_visible < 0) start_visible = 0 ;
}
 
void ajour_vignettes(void)
{
  long delta = start_visible-last_start_visible ;
  int  nb, i ;

  if (labs(delta) < (long)nb_vignettes)
  {
    nb = nb_vignettes-(int)labs(delta) ;
    if (delta > 0)
    {
      for (i = 0; i < delta; i++)
      {
        free(tab_vignette[i].img.fd_addr) ;
        if (tab_vignette[i].info.palette != NULL) free(tab_vignette[i].info.palette) ;
      }
      memmove(tab_vignette, &tab_vignette[delta], nb*sizeof(VIGNETTE)) ;
      charge_nvignettes(nb, delta) ;
      GWRePaint( WndAlbum ) ;
    }
    else
    {
      delta = -delta ;
      for (i = nb_vignettes-(int)delta; i < nb_vignettes; i++)
      {
        free(tab_vignette[i].img.fd_addr) ;
        if (tab_vignette[i].info.palette != NULL) free(tab_vignette[i].info.palette) ;
      }
      memmove(&tab_vignette[delta], tab_vignette, nb*sizeof(VIGNETTE)) ;
      charge_nvignettes(0, delta) ;
      GWRePaint( WndAlbum ) ;
    }
  }
  else
  {
    for (i = 0; i < nb_vignettes; i++)
    {
      free(tab_vignette[i].img.fd_addr) ;
      if (tab_vignette[i].info.palette != NULL) free(tab_vignette[i].info.palette) ;
    }
    charge_vignettes(start_visible, 0) ;
    GWRePaint( WndAlbum ) ;
  }
  GWSetWindowInfo( WndAlbum, "" ) ;
}

void update_vslider(void)
{
  float total ;
  int ypos, wh ;

  total = (float) (catalog_filter.nb_visibles-nb_vignettes) ;

  wh = (int) (1000.0*(float)nb_vignettes/(float)catalog_filter.nb_visibles) ;
  if ((wh > 1000) || (wh < 0)) wh = 1000 ;
  wind_set( WndAlbum->window_handle, WF_VSLSIZE, wh ) ;

  ypos = (int) ( 1000.0*(float)start_visible/total ) ;
  wind_set( WndAlbum->window_handle, WF_VSLIDE, ypos ) ;
}

void make_info(long num, char *buf)
{
  VIGNETTE     *v ;
  INDEX_RECORD *r ;
  char         buffer[80] ;

  v = &tab_vignette[num-start_visible] ;
  r = &tab_index[num] ;
  sprintf(buf, "%s, %s", v->nom,  catalog_header.category_names[r->category_1]) ;
  if (r->category_2 != r->category_1)
  {
    sprintf(buffer, ", %s",  catalog_header.category_names[r->category_2]) ;
    strcat(buf, buffer) ;
  }

  if ((r->category_3 != r->category_2) && (r->category_3 != r->category_1))
  {
    sprintf(buffer, ", %s",  catalog_header.category_names[r->category_3]) ;
    strcat(buf, buffer) ;
  }
  if (v->com[0] != 0)
  {
    sprintf(buffer, ", %s", v->com) ;
    strcat(buf, buffer) ;
  }
}

void clean_up(void)
{
  int i ;

  for ( i = 0; i < nb_vignettes_max; i++ )
  {
    if ( tab_vignette[i].img.fd_addr ) free( tab_vignette[i].img.fd_addr ) ;
    if ( tab_vignette[i].info.palette ) free( tab_vignette[i].info.palette ) ;
  }

  free( tab_vignette ) ;
  GWDestroyWindow( WndAlbum ) ;
  WndAlbum = NULL ;
}

#pragma warn -par
void OnDrawAlbum(void *wnd, int xycoords[4])
{
  GEM_WINDOW *gwnd = wnd ;
  int w, h ;
  int nb_max_vignettes ;
  int must_fill = 0 ;

  if ( gwnd->is_icon )
  {
    GWOnDraw( gwnd, xycoords ) ;
    return ;
  }

  w = xycoords[2] ; h = xycoords[3] ;
  nb_max_vignettes = ( w / catalog_header.width ) * ( h / h_vignette ) ;
  if ( nb_vignettes > nb_max_vignettes ) must_fill = 1 ;

  set_texttype( &wcat_ttype ) ;
  vswr_mode( handle, MD_REPLACE ) ;
  if ( must_fill )
  {
    vsf_interior( handle, 0 ) ;
    xycoords[2] = xycoords[0] + xycoords[2] - 1 ; /* XYWH -> XYXY */
    xycoords[3] = xycoords[1] + xycoords[3] - 1 ; /* XYWH -> XYXY */
    v_bar( handle, xycoords ) ;
    xycoords[2] = 1 + xycoords[2] - xycoords[0] ; /* XYXY -> XYWH */
    xycoords[3] = 1 + xycoords[3] - xycoords[1] ; /* XYXY -> XYWH */
  }
  affiche_vignettes( xycoords ) ;
}
#pragma warn +par

int OnCloseAlbum(void *wnd)
{
  clean_up() ;

  return( GWOnClose( wnd ) ) ;
}

void OnVSliderAlbum(void *w, int pos)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;

  GWOnVSlider( wnd, pos ) ;
  start_visible = ( (long)pos*(catalog_filter.nb_visibles - nb_vignettes) )/1000 ;
  ajuste_premiere_vignette() ;
  ajour_vignettes() ;
}

void OnMoveAlbum(void *w, int xywh[4])
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  int        dummy ;

  GWOnMove( wnd, xywh ) ;
  wnd->GetWorkXYWH( wnd, &xf, &yf, &dummy, &dummy ) ;
}

void OnArrowAlbum(void *w, int action)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  float      total ;
  int        new ;
  char       done = 0 ;

  total = (float) ( catalog_filter.nb_visibles-nb_vignettes ) ;
  switch( action )
  {
    case WA_UPPAGE : start_visible -= nb_vignettes ;
                     done = 1 ;
                     break ;

    case WA_DNPAGE : start_visible += nb_vignettes ;
                     done = 1 ;
                     break ;

    case WA_UPLINE : start_visible -= nb_w ;
                     done = 1 ;
                     break ;

    case WA_DNLINE : start_visible += nb_w ;
                     done = 1 ;
                     break ;
  }

  if ( done )
  {
    ajuste_premiere_vignette() ;

    new = (int) ( 1000.0*(float)start_visible/total ) ;
    GWSetVSlider( wnd, new ) ;
    ajour_vignettes() ;
  }
}

void OnSizeAlbum(void *w, int xywh[4])
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  int        dummy ;
  int        we, he ;

  wind_calc( WC_WORK, wnd->window_kind, xywh[0], xywh[1], xywh[2], xywh[3], &dummy, &dummy, &we, &he ) ;
  nb_w          = we / catalog_header.width ;
  if ( nb_w == 0 ) nb_w = 1 ;
  nb_h          = he / h_vignette ;
  if ( nb_h == 0 ) nb_h = 1 ;
  nb_vignettes  = nb_w * nb_h ;
  we            = nb_w * catalog_header.width ;
  he            = nb_h * h_vignette ;
  wind_calc( WC_BORDER, wnd->window_kind, xywh[0], xywh[1], we, he, &dummy, &dummy, &xywh[2], &xywh[3] ) ;
  GWSetCurrXYWH( wnd, xywh[0], xywh[1], xywh[2], xywh[3] ) ;
  last_x = xywh[0] ;
  last_y = xywh[1] ;
  last_w = xywh[2] ;
  last_h = xywh[3] ;
  wnd->GetWorkXYWH( wnd, &xf, &yf, &dummy, &dummy ) ;
  ajuste_premiere_vignette() ;
  update_vslider() ;
  ajour_vignettes() ;
}

int OnFulledAlbum(void *w)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  int        xywh[4] ;
  int        dummy ;
 
  wind_calc( WC_WORK, wnd->window_kind, xdesk, ydesk, wdesk, hdesk, &xywh[0], &xywh[1], &xywh[2], &xywh[3] ) ;
  nb_w          = xywh[2]/catalog_header.width ;
  nb_h          = xywh[3]/h_vignette ;
  nb_vignettes  = nb_w*nb_h ;
  wind_calc( WC_BORDER, wnd->window_kind, xywh[0], xywh[1], nb_w*catalog_header.width, nb_h*h_vignette, &xywh[0], &xywh[1], &xywh[2], &xywh[3] ) ;
  GWOnFulled( wnd, xywh ) ;
  update_vslider() ;
  wnd->GetWorkXYWH( wnd, &xf, &yf, &dummy, &dummy ) ;

  return( 0 ) ;
}

int OnRestoreFulledAlbum(void *w)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  int        wf, hf ;

  GWOnRestoreFulled( wnd, NULL ) ;
  wnd->GetWorkXYWH( wnd, &xf, &yf, &wf, &hf ) ;
  nb_w          = wf/catalog_header.width ;
  nb_h          = hf/h_vignette ;
  nb_vignettes  = nb_w*nb_h ;
  ajuste_premiere_vignette() ;
  update_vslider() ;

  return( 0 ) ;
}

#pragma warn -par
int OnKeyPressedAlbum(void *w, int key)
{
  int black[] = { 0, 0, 0 } ;
  int code = GW_EVTCONTINUEROUTING ;

  switch( key )
  {
    case STD_PAL    : std_palette = 1-std_palette ;
                      if ( std_palette && old_pal )
                        set_tospalette( old_pal, 16 ) ;
                      else if ( tab_vignette[num_vignette].info.palette != NULL )
                      {
                        set_tospalette( tab_vignette[num_vignette].info.palette, (int)tab_vignette[num_vignette].info.nb_cpal ) ;
                        vs_color( handle, 1, black ) ;
                      }
                      break ;
  }

  return( code ) ;
}
#pragma warn +par

long GetNumVignette(int x, int y)
{
  long num ;
  int  wx, wy, ww, wh ;
  int  xy[4] ;

  WndAlbum->GetWorkXYWH( WndAlbum, &wx, &wy, &ww, &wh ) ;
  x += wx ;
  y += wy ;
  if ( intersect( x, y, 1, 1, wx, wy, ww, wh, xy ) )
  {
    num = start_visible + (x-xf)/catalog_header.width + ((y-yf)/h_vignette)*nb_w ;
    if ( ( num < start_visible ) || ( num >= start_visible + catalog_filter.nb_visibles ) ) num = -1L ;
  }
  else num = -1L ;

  return( num ) ;
}

#pragma warn -par
int OnDLButtonDownAlbum(void *w, int mk_state, int x, int y)
{
  long num_vignette ;
  char buf[200] ;

  num_vignette = GetNumVignette( x, y ) ;
  if ( num_vignette != -1 )
  {
    catalog_getfullname( num_vignette, buf ) ;
    load_wpicture( buf, 0 ) ;
    ajour_vignettes() ;
  }

  return( 0 ) ;
}

int OnLButtonDownAlbum(void *w, int mk_state, int x, int y)
{
  int  text_color[3] ;
  int  *img_palette ;
  long num_vignette ;

  num_vignette = GetNumVignette( x, y ) ;
  if ( ( num_vignette != -1 ) && tab_vignette[num_vignette].info.palette )
  {
    img_palette = (int *) tab_vignette[num_vignette].info.palette ;
    set_tospalette(img_palette, (int)tab_vignette[num_vignette].info.nb_cpal) ;
    text_color[0] = 1000-img_palette[0] ;
    text_color[1] = 1000-img_palette[1] ;
    text_color[2] = 1000-img_palette[2] ;
    vs_color(handle, 1, text_color) ;
  }

  return( 0 ) ;
}

int OnRButtonDownAlbum(void *w, int mk_state, int mx, int my)
{
  GEM_WINDOW *wnd = w ;
  OBJECT     *popup ;
  long       num_vignette ;
  int        i, clicked ;
  int        wx, wy, dummy ;
  int        nb_items = 1+MSG_PEHTML-MSG_PLOADIMG ;
  char       buf[PATH_MAX] ;

  num_vignette = GetNumVignette( mx, my ) ;
  if ( num_vignette < 0 ) return( 0 ) ;

  popup = popup_make( nb_items, 25 ) ;
  if ( popup == NULL ) return( 0 ) ;
  for ( i = MSG_PLOADIMG; i <= MSG_PEHTML; i++ )
  {
    strcpy( popup[1+i-MSG_PLOADIMG].ob_spec.free_string, msg[i] ) ;
    popup[1+i-MSG_PLOADIMG].ob_flags |= SELECTABLE ;
  }

  wnd->GetWorkXYWH( wnd, &wx, &wy, &dummy, &dummy ) ;
  clicked = popup_formdo( &popup, wx+mx-16, wy+my, 1, 0 ) ;
  popup_kill( popup, nb_items ) ;

  switch ( MSG_PLOADIMG+clicked-1 )
  {
    case MSG_PLOADIMG  : catalog_getfullname( num_vignette, buf ) ;
                         load_wpicture( buf, 0 ) ;
                         break ;

    case MSG_PIMGINFO  : show_imginfo( num_vignette, tab_vignette[num_vignette-start_visible].com ) ;
                         break ;

    case MSG_PEHTML    : HTMLCatalogExport( 0, catalog_filter.nb_visibles - 1 ) ;
                         break ;
  }

  return( 0 ) ;
}

int OnMouseMoveAlbum(void *w, int button, int kstate, int mx, int my)
{
  GEM_WINDOW     *wnd = (GEM_WINDOW *) w ;
  WALB_EXTENSION *ext = (WALB_EXTENSION *) wnd->Extension ;
  long       num_vignette ;
  char       buf[60] ;

  num_vignette = GetNumVignette( mx, my ) ;
  if ( num_vignette != -1 )
  {
    if ( num_vignette != ext->NumVignetteInfo )
    {
      make_info( num_vignette, buf ) ;
      GWSetWindowInfo( wnd, buf ) ;
      ext->NumVignetteInfo = num_vignette ;
    }
  }
  else if ( ext->NumVignetteInfo != -1L )
  {
    sprintf( buf, msg[MSG_CATINFO], catalog_filter.nb_visibles, catalog_header.nb_records ) ;
    GWSetWindowInfo( wnd, buf ) ;
    ext->NumVignetteInfo = -1L ;
  }

  return( 0 ) ;
}
#pragma warn +par

GEM_WINDOW *VWAlbCreateWindow(void)
{
  return( GWCreateWindow( WALB_STYLE, sizeof(WALB_EXTENSION), VWALB_CLASSNAME ) ) ;
}

void album_window(void)
{
  int  xe, ye, we, he ;
  int  dummy ;
  char buf[200] ;

  if ( tab_index == NULL ) return ;

  wind_calc( WC_WORK, WALB_STYLE, xdesk, ydesk, wdesk, hdesk, &xe, &ye, &we, &he ) ;
  nb_w          = we/catalog_header.width ;
  h_vignette    = 16+catalog_header.height ;
  nb_h          = he/h_vignette ;
  nb_vignettes_max = nb_vignettes = nb_w*nb_h ;
  start_visible = 0 ;
  last_start_visible = -1 ;
  tab_vignette = (VIGNETTE *) calloc( nb_vignettes_max, sizeof(VIGNETTE) ) ;
  if ( tab_vignette == NULL )
  {
    form_error(8) ;
    return ;
  }

  wind_calc( WC_BORDER, WALB_STYLE, xe, ye, nb_w*catalog_header.width, nb_h*h_vignette,
             &xe, &ye, &we, &he ) ;

  WndAlbum = VWAlbCreateWindow() ;
  if ( WndAlbum == NULL )
  {
    clean_up() ;

    form_stop(1, msg[MSG_NOMOREWINDOW]) ;
    return ;
  }

  WndAlbum->OnDraw          = OnDrawAlbum ;
  WndAlbum->OnClose         = OnCloseAlbum ;
  WndAlbum->OnMove          = OnMoveAlbum ;
  WndAlbum->OnVSlider       = OnVSliderAlbum ;
  WndAlbum->OnArrow         = OnArrowAlbum ;
  WndAlbum->OnSize          = OnSizeAlbum ;
  WndAlbum->OnFulled        = OnFulledAlbum ;
  WndAlbum->OnRestoreFulled = OnRestoreFulledAlbum ;
  WndAlbum->OnKeyPressed    = OnKeyPressedAlbum ;
  WndAlbum->OnLButtonDown   = OnLButtonDownAlbum ;
  WndAlbum->OnDLButtonDown  = OnDLButtonDownAlbum ;
  WndAlbum->OnRButtonDown   = OnRButtonDownAlbum ;
  WndAlbum->OnMouseMove     = OnMouseMoveAlbum ;

  GWSetWindowCaption( WndAlbum, catalog_name ) ;
  sprintf( buf, msg[MSG_CATINFO], catalog_filter.nb_visibles, catalog_header.nb_records ) ;
  GWSetWindowInfo( WndAlbum, buf ) ;

  GWSetWndRscIcon( WndAlbum, FORM_ICONS, ICN_WCAT ) ;

  GWOpenWindow( WndAlbum, xe, ye, we, he ) ;
  wind_set ( WndAlbum->window_handle, WF_TOP ) ;
  WndAlbum->GetWorkXYWH( WndAlbum, &xf, &yf, &dummy, &dummy ) ;
  update_vslider() ;

  num_vignette = 0 ;
  if ( charge_vignettes( start_visible, 0 ) != 0 )
  {
    clean_up() ;

    form_error(8) ;
    return ;
  }
}
