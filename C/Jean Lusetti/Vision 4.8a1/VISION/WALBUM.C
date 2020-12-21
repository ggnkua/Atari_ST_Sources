/********************************************/
/* Gestion du catalogue d'images en fenˆtre */
/********************************************/
#include  <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <ctype.h>
#include <string.h>

#include "..\tools\stdprog.h"
#include "..\tools\stdinput.h"
#include "..\tools\xgem.h"
#include "..\tools\gwindows.h"
#include "..\tools\aides.h"
#include "..\tools\catalog.h"
#include "..\tools\image_io.h"
#include "..\tools\rasterop.h"
#include "..\tools\logging.h"
#include "defs.h"

#include   "rtzoom.h"
#include   "gstenv.h"
#include  "touches.h"
#include  "actions.h"
#include "visionio.h"
#include "walbum.h"

#include "forms\falbum.h"
#include "forms\fehtml.h"
#include "forms\falbimg.h"

typedef struct
{
  INFO_IMAGE info ;
  char       nom[20] ;
  char       com[SIZE_COMMENT] ;
}
VIGNETTE ;

#define VWALB_CLASSNAME  "CN_VWALBUM"
typedef struct
{
  VIGNETTE*    tab_vignette ;
  long         start_visible, last_start_visible ;
  int          nb_w, nb_h, nb_vignettes, nb_vignettes_max, num_vignette ;
  int          xf, yf ;
  int          last_x, last_y, last_w, last_h ;
  int          h_vignette ;
  char         std_palette ;
  long         NumVignetteInfo ;
  HCAT         hCat ;
  GEM_WINDOW*  wnd_album ;
  GEM_WINDOW** pwnd ; /* Because caller needs to know when we close */
  long         sel_icon ;
  MFDB         emptyImg ;
  int          name_filter_offset ;
  char         WindowID[PATH_MAX] ;
}
WALB_EXTENSION ;

#define WALB_STYLE (NAME|CLOSER|MOVER|INFO|UPARROW|DNARROW|VSLIDE|SIZER|FULLER|SMALLER)

static TEXT_TYPE wcat_ttype = { 6, 6, 6, 6, 0, 0, 1, 0, 1, 0 } ;


static void show_icon(WALB_EXTENSION* wext, int i)
{
  CATALOG_HEADER* catalog_header = catalog_get_header(wext->hCat) ;
  INDEX_RECORD*   tab_index = catalog_get_index_record(wext->hCat) ;
  VIGNETTE*       v ;
  int             txy[4] ;
  int             xy[8] ;
  int             x, y ;
  char            buf[10] ;
  char*           c ;

  if ( !catalog_header || !tab_index )
  {
    LoggingDo(LL_ERROR, "Invalid hCat");
    return ;
  }

  v = &wext->tab_vignette[i] ;
  if ( v->info.mfdb.fd_addr == NULL )
  {
    LoggingDo(LL_WARNING, "Invalid vignette %i", i);
    return ;
  }

  xy[0] = xy[1] = 0 ;
  xy[2] = v->info.mfdb.fd_w-1 ;
  xy[3] = v->info.mfdb.fd_h-1 ;
  xy[4] = wext->xf+(i % wext->nb_w)*catalog_header->width ;
  xy[5] = wext->yf+(i/wext->nb_w)*wext->h_vignette ;
  xy[6] = xy[4]+v->info.mfdb.fd_w-1 ;
  xy[7] = xy[5]+v->info.mfdb.fd_h-1 ;
/*  vro_cpyfm(handle, tab_index[wext->start_visible+i].selected ? S_OR_NOTD:S_ONLY, xy, &v->info.mfdb, &screen) ;*/
  vro_cpyfm(handle, S_ONLY, xy, &v->info.mfdb, &screen) ;
  if ( tab_index[wext->start_visible+i].selected )
  {
    int coords[8] ;

    coords[0] = xy[2] - 4 - 8 ;
    coords[1] = xy[1] + 4 ;
    coords[2] = xy[2] - 4 ;
    coords[3] = xy[1] + 4 + 8 ;
    coords[4] = xy[6] - 4 - 8 ;
    coords[5] = xy[5] + 4 ;
    coords[6] = xy[6] - 4 ;
    coords[7] = xy[5] + 4 + 8 ;
    vro_cpyfm(handle, D_INVERT, coords, &v->info.mfdb, &screen) ;
  }
  vsf_perimeter(handle, 0) ;
  vsf_interior(handle, FIS_HOLLOW) ;
  txy[0] = xy[4] ; txy[1] = 1+xy[7] ;
  txy[2] = xy[6] ; txy[3] = txy[1]+wext->h_vignette-catalog_header->height-1 ;
  vr_recfl(handle, txy) ;
  memcpy(buf, wext->tab_vignette[i].nom, 8) ;
  buf[8] = 0 ;
  c = strchr(buf, ' ') ;
  if (c) *c = 0 ;
  x = (xy[4]+xy[6]) >> 1 ;
  y = 8+xy[7] ;
  v_gtext(handle, x, y, buf) ;
}

static void affiche_vignettes(WALB_EXTENSION* wext, int xywh[4])
{
  CATALOG_HEADER* catalog_header = catalog_get_header(wext->hCat) ;
  int             cxy[4] ;
  int             i ;
  int             cx, cy ;

  if ( !catalog_header )
  {
    LoggingDo(LL_ERROR, "Invalid hCat");
    return ;
  }

  for ( i = 0; i < wext->nb_vignettes; i++ )
  {
    cx = wext->xf + ( i % wext->nb_w ) * catalog_header->width ;
    cy = wext->yf + ( i / wext->nb_w ) * wext->h_vignette ;
    if ( intersect( cx, cy, cx + catalog_header->width - 1, cy + catalog_header->height-1,
                    xywh[0], xywh[1], xywh[2], xywh[3], cxy )
       )
    {
      vs_clip( handle, 1, cxy ) ;
      show_icon( wext, i ) ;
      vs_clip( handle, 0, cxy ) ;
    }
  }
}

static void free_vignette(VIGNETTE* v, void* empty_img_addr)
{
    if ( v->info.mfdb.fd_addr && (v->info.mfdb.fd_addr != empty_img_addr) )
    {
      Xfree( v->info.mfdb.fd_addr ) ;
      v->info.mfdb.fd_addr = NULL ;
    }
    if ( v->info.palette )
    {
      Xfree( v->info.palette ) ;
      v->info.palette = NULL ;
    }
}

static int charge_vignettes(GEM_WINDOW* wnd, long start)
{
  WALB_EXTENSION* wext = wnd->Extension ;
  INDEX_RECORD*   tab_index = catalog_get_index_record(wext->hCat) ;
  VIGNETTE*       tab_vignette = wext->tab_vignette ;
  long            i ;
  int             err = 0 ;
  char            buf[60] ;

  if ( !tab_index || !tab_vignette )
  {
    LoggingDo(LL_ERROR, "Invalid hCat");
    return -1 ;
  }

  mouse_busy() ;
  set_texttype(&wcat_ttype) ;
  for (i = 0; i < wext->nb_vignettes; i++)
  {
    sprintf( buf, " %02ld %c", ( i*100 ) / wext->nb_vignettes, '%' ) ;
    GWSetWindowInfo( wnd, buf ) ;
    tab_vignette[i].nom[0] = 0 ;
    err = catalog_loadicon( wext->hCat, start+i, &tab_vignette[i].info, tab_vignette[i].com ) ;
    if ( err == ECAT_NOERR )
    {
      if ( tab_index[wext->start_visible+i].is_visible )
      {
        memcpy( tab_vignette[i].nom, tab_index[start+i].name, 8 ) ;
        tab_vignette[i].nom[8] = 0 ;
      }
    }
    else if ( err == ECAT_BADINDEX )
    {
      /* Index is wrong or image is marked deleted */
      CopyMFDB( &tab_vignette[i].info.mfdb, &wext->emptyImg ) ;
      err = 0 ;
    }
  }

  wext->last_start_visible = wext->start_visible = start ;
  mouse_restore() ;

  return err ;
}

static int charge_nvignettes(GEM_WINDOW* wnd, long pos, long nb)
{
  WALB_EXTENSION* wext = wnd->Extension ;
  INDEX_RECORD*   tab_index = catalog_get_index_record(wext->hCat) ;
  VIGNETTE*       tab_vignette = wext->tab_vignette ;
  long            i ;
  int             err = 0 ;
  char            buf[100] ;

  if ( !tab_index || !tab_vignette )
  {
    LoggingDo(LL_ERROR, "Invalid hCat");
    return -1 ;
  }

  mouse_busy() ;
  for (i = pos; i < pos+nb; i++)
  {
    sprintf( buf, "% 02ld %c", ( (i-pos)*100 ) / nb, '%' ) ;
    GWSetWindowInfo( wnd, buf ) ;
    tab_vignette[i].nom[0] = 0 ;
    err = catalog_loadicon( wext->hCat, wext->start_visible+i, &tab_vignette[i].info, tab_vignette[i].com ) ;
    if ( err == ECAT_NOERR )
    {
      if ( tab_index[wext->start_visible+i].is_visible )
      {
        memcpy( tab_vignette[i].nom, tab_index[wext->start_visible+i].name, 8 ) ;
        tab_vignette[i].nom[8] = 0 ;
      }
    }
    else if ( err == ECAT_BADINDEX )
    {
      /* Index is wrong or image is marked deleted */
      CopyMFDB( &tab_vignette[i].info.mfdb, &wext->emptyImg ) ;
      err = 0 ;
    }
    else LoggingDo(LL_ERROR, "charge_nvignettes(%ld):%p (failed)", wext->start_visible+i, tab_vignette[i].info.mfdb.fd_addr);
  }

  wext->last_start_visible = wext->start_visible ;
  mouse_restore() ;

  return err ;
}

static void ajuste_premiere_vignette(WALB_EXTENSION* wext)
{
  CATALOG_FILTER* catalog_filter = catalog_get_filter(wext->hCat) ;

  if ( catalog_filter )
  {
    if (wext->start_visible > catalog_filter->nb_visibles-wext->nb_vignettes)
      wext->start_visible = catalog_filter->nb_visibles-wext->nb_vignettes ;
  }
  else LoggingDo(LL_ERROR, "Invalid hCat");
  if (wext->start_visible < 0) wext->start_visible = 0 ;
}
 
static void ajour_vignettes(GEM_WINDOW* wnd, int force)
{
  WALB_EXTENSION* wext = wnd->Extension ;
  VIGNETTE*       tab_vignette = wext->tab_vignette ;
  long            delta = wext->start_visible-wext->last_start_visible ;
  long            nb, i ;

  if ( !tab_vignette )
  {
    LoggingDo(LL_ERROR, "Invalid hCat");
    return ;
  }

  if ( !force && (labs(delta) < wext->nb_vignettes) )
  {
    nb = wext->nb_vignettes-labs(delta) ;
    if (delta > 0)
    {
      for (i = 0; i < delta; i++)
        free_vignette( &tab_vignette[i], wext->emptyImg.fd_addr ) ;
      memmove(tab_vignette, &tab_vignette[delta], nb*sizeof(VIGNETTE)) ;
      charge_nvignettes(wnd, nb, delta) ;
    }
    else
    {
      delta = -delta ;
      for (i = wext->nb_vignettes-delta; i < wext->nb_vignettes; i++)
        free_vignette( &tab_vignette[i], wext->emptyImg.fd_addr ) ;
      memmove(&tab_vignette[delta], tab_vignette, nb*sizeof(VIGNETTE)) ;
      charge_nvignettes(wnd, 0, delta) ;
    }
  }
  else
  {
    for (i = 0; i < wext->nb_vignettes; i++)
      free_vignette( &tab_vignette[i], wext->emptyImg.fd_addr ) ;
    charge_nvignettes(wnd, 0, wext->nb_vignettes) ;
  }
  GWRePaint( wnd ) ;
  GWSetWindowInfo( wnd, "" ) ;
}

static void wselect_icons(WALB_EXTENSION* wext, long start, long end, int select)
{
  INDEX_RECORD* tab_index = catalog_get_index_record(wext->hCat) ;
  long          n ;

  if ( !tab_index )
  {
    LoggingDo(LL_ERROR, "Invalid hCat");
    return ;
  }

  tab_index += start ;
  for ( n = start; n <= end; n++, tab_index++ )
    tab_index->selected = select ;
  LoggingDo(LL_INFO, "Icons[%ld-%ld] %sselected", start, end, select ? "":"un-");
}

static void update_vslider(GEM_WINDOW* wnd)
{
  WALB_EXTENSION* wext = wnd->Extension ;
  CATALOG_FILTER* catalog_filter = catalog_get_filter(wext->hCat) ;
  float           total ;
  int             ypos, wh ;

  if ( !catalog_filter )
  {
    LoggingDo(LL_ERROR, "Invalid hCat");
    return ;
  }

  total = (float) (catalog_filter->nb_visibles-wext->nb_vignettes) ;

  wh = (int) (1000.0*(float)wext->nb_vignettes/(float)catalog_filter->nb_visibles) ;
  if ((wh > 1000) || (wh < 0)) wh = 1000 ;
  wind_set( wnd->window_handle, WF_VSLSIZE, wh ) ;

  ypos = (int) ( 1000.0*(float)wext->start_visible/total ) ;
  wind_set( wnd->window_handle, WF_VSLIDE, ypos ) ;
}

static void get_info_fonname(CATALOG_FILTER* catalog_filter, char* buffer)
{
  if ( !catalog_filter->show_all && catalog_filter->filter_on_name )
  {
    if ( catalog_filter->contains ) sprintf(buffer, ", Filter on name contains %s", catalog_filter->filter_name ) ;
    else                            sprintf(buffer, ", Filter on name starts with %s", catalog_filter->filter_name ) ;
  }
  else strcpy(buffer, " (No filter on name)") ;
}

static void make_info(WALB_EXTENSION* wext, long num, char *buf)
{
  CATALOG_HEADER* catalog_header = catalog_get_header(wext->hCat) ;
  CATALOG_FILTER* catalog_filter = catalog_get_filter(wext->hCat) ;
  INDEX_RECORD*   tab_index = catalog_get_index_record(wext->hCat) ;
  VIGNETTE*       tab_vignette = wext->tab_vignette ;
  VIGNETTE*       v ;
  INDEX_RECORD*   r ;
  char            buffer[64+PATH_MAX] ;

  if ( !catalog_header || !catalog_filter || !tab_index || !tab_vignette )
  {
    LoggingDo(LL_ERROR, "Invalid hCat");
    return ;
  }

  v = &tab_vignette[num-wext->start_visible] ;
  r = &tab_index[num] ;
  if ( config.flags & FLG_LONGFNAME ) catalog_getfullname( wext->hCat, num, buffer ) ;
  else                                strcpy( buffer, v->nom ) ;
  sprintf(buf, "%s, %s", buffer,  catalog_header->category_names[r->category_1]) ;
  if (r->category_2 != r->category_1)
  {
    sprintf(buffer, ", %s",  catalog_header->category_names[r->category_2]) ;
    strcat(buf, buffer) ;
  }

  if ((r->category_3 != r->category_2) && (r->category_3 != r->category_1))
  {
    sprintf(buffer, ", %s",  catalog_header->category_names[r->category_3]) ;
    strcat(buf, buffer) ;
  }
  if (v->com[0] != 0)
  {
    sprintf(buffer, ", %s", v->com) ;
    strcat(buf, buffer) ;
  }

  get_info_fonname( catalog_filter, buffer ) ;
  strcat(buf, buffer) ;
}

static void clean_up(GEM_WINDOW* wnd)
{
  WALB_EXTENSION* wext = wnd->Extension ;
  VIGNETTE*       tab_vignette = wext->tab_vignette ;
  int             i ;

  for ( i = 0; i < wext->nb_vignettes_max; i++ )
    free_vignette( &tab_vignette[i], wext->emptyImg.fd_addr ) ;

  Xfree( wext->emptyImg.fd_addr ) ;
  Xfree( tab_vignette ) ;
  *wext->pwnd = NULL ;
  GWDestroyWindow( wnd ) ;
}

static void OnDrawAlbum(void *wnd, int xycoords[4])
{
  GEM_WINDOW*     gwnd = wnd ;
  WALB_EXTENSION* wext = gwnd->Extension ;
  CATALOG_HEADER* catalog_header = catalog_get_header(wext->hCat) ;

  if ( gwnd->is_icon )
  {
    GWOnDraw( gwnd, xycoords ) ;
    return ;
  }

  if ( !catalog_header )
  {
    LoggingDo(LL_ERROR, "Invalid hCat");
    return ;
  }

  set_texttype( &wcat_ttype ) ;
  vswr_mode( handle, MD_REPLACE ) ;
  affiche_vignettes( wext, xycoords ) ;
}

static int OnCloseAlbum(void *wnd)
{
  clean_up( wnd ) ;

  return GWOnClose( wnd ) ;
}

static void OnVSliderAlbum(void *w, int pos)
{
  GEM_WINDOW*     wnd = (GEM_WINDOW* ) w ;
  WALB_EXTENSION* wext = wnd->Extension ;
  CATALOG_FILTER* catalog_filter = catalog_get_filter(wext->hCat) ;

  GWOnVSlider( wnd, pos ) ;
  if ( catalog_filter )
    wext->start_visible = ( (long)pos*(catalog_filter->nb_visibles - wext->nb_vignettes) )/1000 ;
  ajuste_premiere_vignette(wext) ;
  ajour_vignettes(wnd,0) ;
}

static void OnMoveAlbum(void *w, int xywh[4])
{
  GEM_WINDOW*     wnd = (GEM_WINDOW* ) w ;
  WALB_EXTENSION* wext = wnd->Extension ;
  int             dummy ;

  GWOnMove( wnd, xywh ) ;
  wnd->GetWorkXYWH( wnd, &wext->xf, &wext->yf, &dummy, &dummy ) ;
}

static void OnArrowAlbum(void *w, int action)
{
  GEM_WINDOW*     wnd = (GEM_WINDOW* ) w ;
  WALB_EXTENSION* wext = wnd->Extension ;
  CATALOG_FILTER* catalog_filter = catalog_get_filter(wext->hCat) ;
  float           total ;
  int             new ;
  char            done = 0 ;

  if ( !catalog_filter )
  {
    LoggingDo(LL_ERROR, "Invalid hCat");
    return ;
  }

  total = (float) ( catalog_filter->nb_visibles-wext->nb_vignettes ) ;
  switch( action )
  {
    case WA_UPPAGE : wext->start_visible -= wext->nb_vignettes ;
                     done = 1 ;
                     break ;

    case WA_DNPAGE : wext->start_visible += wext->nb_vignettes ;
                     done = 1 ;
                     break ;

    case WA_UPLINE : wext->start_visible -= wext->nb_w ;
                     done = 1 ;
                     break ;

    case WA_DNLINE : wext->start_visible += wext->nb_w ;
                     done = 1 ;
                     break ;
  }

  if ( done )
  {
    ajuste_premiere_vignette(wext) ;

    new = (int) ( 1000.0*(float)wext->start_visible/total ) ;
    GWSetVSlider( wnd, new ) ;
    ajour_vignettes(wnd,0) ;
  }
}

static void OnSizeAlbum(void *w, int xywh[4])
{
  GEM_WINDOW*     wnd = (GEM_WINDOW* ) w ;
  WALB_EXTENSION* wext = wnd->Extension ;
  CATALOG_HEADER* catalog_header = catalog_get_header(wext->hCat) ;
  int             dummy ;
  int             we, he ;

  if ( !catalog_header )
  {
    LoggingDo(LL_ERROR, "Invalid hCat");
    return ;
  }

  wind_calc( WC_WORK, wnd->window_kind, xywh[0], xywh[1], xywh[2], xywh[3], &dummy, &dummy, &we, &he ) ;
  wext->nb_w          = we / catalog_header->width ;
  if ( wext->nb_w == 0 ) wext->nb_w = 1 ;
  wext->nb_h          = he / wext->h_vignette ;
  if ( wext->nb_h == 0 ) wext->nb_h = 1 ;
  wext->nb_vignettes  = wext->nb_w * wext->nb_h ;
  we            = wext->nb_w * catalog_header->width ;
  he            = wext->nb_h * wext->h_vignette ;
  wind_calc( WC_BORDER, wnd->window_kind, xywh[0], xywh[1], we, he, &dummy, &dummy, &xywh[2], &xywh[3] ) ;
  GWSetCurrXYWH( wnd, xywh[0], xywh[1], xywh[2], xywh[3] ) ;
  wext->last_x = xywh[0] ;
  wext->last_y = xywh[1] ;
  wext->last_w = xywh[2] ;
  wext->last_h = xywh[3] ;
  wnd->GetWorkXYWH( wnd, &wext->xf, &wext->yf, &dummy, &dummy ) ;
  ajuste_premiere_vignette(wext) ;
  update_vslider(wnd) ;
  ajour_vignettes(wnd,0) ;
}

static int OnFulledAlbum(void *w)
{
  GEM_WINDOW*     wnd = (GEM_WINDOW* ) w ;
  WALB_EXTENSION* wext = wnd->Extension ;
  CATALOG_HEADER* catalog_header = catalog_get_header(wext->hCat) ;
  int             xywh[4] ;
  int             dummy ;
 
  if ( !catalog_header )
  {
    LoggingDo(LL_ERROR, "Invalid hCat");
    return 0 ;
  }

  wind_calc( WC_WORK, wnd->window_kind, xdesk, ydesk, wdesk, hdesk, &xywh[0], &xywh[1], &xywh[2], &xywh[3] ) ;
  wext->nb_w          = xywh[2]/catalog_header->width ;
  wext->nb_h          = xywh[3]/wext->h_vignette ;
  wext->nb_vignettes  = wext->nb_w*wext->nb_h ;
  wind_calc( WC_BORDER, wnd->window_kind, xywh[0], xywh[1], wext->nb_w*catalog_header->width, wext->nb_h*wext->h_vignette, &xywh[0], &xywh[1], &xywh[2], &xywh[3] ) ;
  GWOnFulled( wnd, xywh ) ;
  update_vslider(wnd) ;
  wnd->GetWorkXYWH( wnd, &wext->xf, &wext->yf, &dummy, &dummy ) ;

  return 0 ;
}

static int OnRestoreFulledAlbum(void *w)
{
  GEM_WINDOW*     wnd = (GEM_WINDOW* ) w ;
  WALB_EXTENSION* wext = wnd->Extension ;
  CATALOG_HEADER* catalog_header = catalog_get_header(wext->hCat) ;
  int             wf, hf ;

  if ( !catalog_header )
  {
    LoggingDo(LL_ERROR, "Invalid hCat");
    return 0 ;
  }

  GWOnRestoreFulled( wnd, NULL ) ;
  wnd->GetWorkXYWH( wnd, &wext->xf, &wext->yf, &wf, &hf ) ;
  wext->nb_w          = wf/catalog_header->width ;
  wext->nb_h          = hf/wext->h_vignette ;
  wext->nb_vignettes  = wext->nb_w*wext->nb_h ;
  ajuste_premiere_vignette(wext) ;
  update_vslider(wnd) ;

  return( 0 ) ;
}

#pragma warn -par
static int OnKeyPressedAlbum(void *w, int key)
{
  GEM_WINDOW*     wnd = (GEM_WINDOW* ) w ;
  WALB_EXTENSION* wext = wnd->Extension ;
  CATALOG_FILTER* catalog_filter = catalog_get_filter(wext->hCat) ;
  int             full_refresh = 0 ;
  long            nsel ;
  char            buf[256] ;
  int             black[] = { 0, 0, 0 } ;
  int             code = GW_EVTCONTINUEROUTING ;

  switch( key )
  {
    case STD_PAL    :   wext->std_palette = 1-wext->std_palette ;
                        if ( wext->std_palette && old_pal )
                          set_tospalette( old_pal, 16 ) ;
                        else if ( wext->tab_vignette[wext->num_vignette].info.palette != NULL )
                        {
                          set_tospalette( wext->tab_vignette[wext->num_vignette].info.palette, (int)wext->tab_vignette[wext->num_vignette].info.nb_cpal ) ;
                          vs_color( handle, 1, black ) ;
                        }
                        break ;
    case KBD_CTRL_A :   /* Select all icons */
                        if ( catalog_filter )
                        {
                          wselect_icons( wext, 0, catalog_filter->nb_visibles-1, 1 ) ;
                          GWRePaint( wnd ) ;
                        }
                        break ;
    case KBD_DELETE :   nsel = catalog_getnsel(wext->hCat) ;
                        if ( nsel > 0 )
                        {
                          sprintf( buf, MsgTxtGetMsg(hMsg, MSG_CATDELICON), nsel ) ;
                          if ( form_interrogation(2, buf ) == 1 )
                          {
                            GEM_WINDOW* wprog = NULL ;

                            if ( nsel > 100 ) wprog = DisplayStdProg( MsgTxtGetMsg(hMsg, MSG_CATSDELREC) , "", "", CLOSER ) ;
                            catalog_removesel( wext->hCat, 0, wprog ) ;
                            if ( wprog ) GWDestroyWindow( wprog ) ;
                            ajuste_premiere_vignette(wext) ;
                            update_vslider(wnd) ;
                            ajour_vignettes(wnd,1) ; /* Force vignette to reload */
                            if ( *wext->pwnd ) PostMessage( wext->wnd_album, MSG_ALB_REFRESH, NULL ) ;
                          }
                        }
                        break ;
    case KBD_RSDELETE:
    case KBD_LSDELETE:  nsel = catalog_getnsel(wext->hCat) ;
                        if ( nsel > 0 )
                        {
                          sprintf( buf, MsgTxtGetMsg(hMsg, MSG_CATSDELICON), nsel ) ;
                          if ( form_interrogation(2, buf ) == 1 )
                          {
                            GEM_WINDOW* wprog = NULL ;

                            if ( nsel > 10 ) wprog = DisplayStdProg( MsgTxtGetMsg(hMsg, MSG_CATSDELRECIMG) , "", "", CLOSER ) ;
                            catalog_removesel( wext->hCat, 1, wprog ) ;
                            if ( wprog ) GWDestroyWindow( wprog ) ;
                            ajuste_premiere_vignette(wext) ;
                            update_vslider(wnd) ;
                            ajour_vignettes(wnd,1) ; /* Force vignette to reload */
                            if ( *wext->pwnd ) PostMessage( wext->wnd_album, MSG_ALB_REFRESH, NULL ) ;
                          }
                        }
                        break ;
    case KBD_BACKSPACE: if ( (wext->name_filter_offset > 0) && catalog_filter )
                        {
                          wext->name_filter_offset-- ;
                          catalog_filter->filter_name[wext->name_filter_offset] = 0 ;
                          if ( wext->name_filter_offset == 0 ) catalog_filter->filter_on_name = 0 ;
                          full_refresh = 1 ;
                        }
                        break ;
    case KBD_CTRL_H :   /* Switch between filter on start or contains */
                        if ( catalog_filter )
                        {
                          catalog_filter->contains = 1-catalog_filter->contains ;
                          if ( catalog_filter->filter_on_name ) full_refresh = 1 ;
                        }
                        break ;
    default:            if ( (wext->name_filter_offset < 8) && catalog_filter && (CursorKeyToArrowAction(key) == -1) && isprint(key) )
                        {
                          LoggingDo(LL_DEBUG, "Key $%04X to be used for filtering", key);
                          key = toupper( key ) ;
                          catalog_filter->filter_name[wext->name_filter_offset] = key ;
                          wext->name_filter_offset++ ;
                          catalog_filter->filter_on_name = 1 ;
                          catalog_filter->show_all       = 0 ;
                          full_refresh = 1 ;
                        }
                        break ;
  }

  if ( full_refresh )
  {
    mouse_busy() ;
    catalog_filter->filter_name[wext->name_filter_offset] = 0 ;
    catalog_sort_index(wext->hCat) ;
    mouse_restore() ;
    ajuste_premiere_vignette(wext) ;
    update_vslider(wnd) ;
    ajour_vignettes(wnd,1) ; /* Force vignette to reload */
    if ( *wext->pwnd ) PostMessage( wext->wnd_album, MSG_ALB_REFRESH, NULL ) ;
  }

  return( code ) ;
}
#pragma warn +par

static long GetNumVignette(GEM_WINDOW* wnd, int x, int y)
{
  WALB_EXTENSION* wext = wnd->Extension ;
  CATALOG_FILTER* catalog_filter = catalog_get_filter(wext->hCat) ;
  CATALOG_HEADER* catalog_header = catalog_get_header(wext->hCat) ;
  long            num ;
  int             wx, wy, ww, wh ;
  int             xy[4] ;

  if ( !catalog_header || !catalog_filter )
  {
    LoggingDo(LL_ERROR, "Invalid hCat");
    return -1 ;
  }

  wnd->GetWorkXYWH( wnd, &wx, &wy, &ww, &wh ) ;
  x += wx ;
  y += wy ;
  if ( intersect( x, y, 1, 1, wx, wy, ww, wh, xy ) )
  {
    num = wext->start_visible + (x-wext->xf)/catalog_header->width + ((y-wext->yf)/wext->h_vignette)*wext->nb_w ;
    if ( ( num < wext->start_visible ) || ( num >= wext->start_visible + catalog_filter->nb_visibles ) ) num = -1L ;
  }
  else num = -1L ;
  
  if ( num-wext->start_visible >= wext->nb_vignettes_max )
  {
     LoggingDo(LL_ERROR, "WAlbum GetNumVignette=%ld, max=%d", num-wext->start_visible, wext->nb_vignettes_max);
     num = -1 ;
  }

  return num ;
}

#pragma warn -par
static int OnDLButtonDownAlbum(void *w, int mk_state, int x, int y)
{
  GEM_WINDOW*     wnd = (GEM_WINDOW* ) w ;
  WALB_EXTENSION* wext = wnd->Extension ;
  long            num_vignette ;
  char            buf[200] ;

  num_vignette = GetNumVignette( wnd, x, y ) ;
  if ( num_vignette != -1 )
  {
    catalog_getfullname( wext->hCat, num_vignette, buf ) ;
    load_wpicture( buf, IID_UNKNOWN ) ;
  }

  return GW_EVTSTOPROUTING ;
}

static int OnLButtonDownAlbum(void *w, int mk_state, int x, int y)
{
  GEM_WINDOW*     wnd = (GEM_WINDOW* ) w ;
  WALB_EXTENSION* wext = wnd->Extension ;
  INDEX_RECORD*   tab_index = catalog_get_index_record(wext->hCat) ;
  CATALOG_FILTER* catalog_filter = catalog_get_filter(wext->hCat) ;
  int             text_color[3] ;
  int*            img_palette ;
  long            index = GetNumVignette( wnd, x, y ) ;
  long            num_vignette ;

  num_vignette = index-wext->start_visible ;
  LoggingDo(LL_DEBUG, "OnLButtonDownAlbum for num_vignette %ld", num_vignette) ;
  if ( !Truecolor && ( num_vignette >= 0 ) && ( num_vignette < wext->nb_vignettes_max ) && wext->tab_vignette[num_vignette].info.palette )
  {
    img_palette = (int *) wext->tab_vignette[num_vignette].info.palette ;
    LoggingDo(LL_DEBUG, "OnLButtonDownAlbum: palette=%p, %d colors", img_palette, (int)wext->tab_vignette[num_vignette].info.nb_cpal) ;
    set_tospalette(img_palette, (int)wext->tab_vignette[num_vignette].info.nb_cpal) ;
    text_color[0] = 1000-img_palette[0] ;
    text_color[1] = 1000-img_palette[1] ;
    text_color[2] = 1000-img_palette[2] ;
    vs_color(handle, 1, text_color) ;
  }

  if ( (mk_state & K_CTRL) && tab_index )
  {
    /* Control: add/remove to selection */
    int sel = tab_index[index].selected ;

    wselect_icons( wext, index, index, 1 - sel ) ;
    wext->sel_icon = index ;
    GWRePaint( wnd ) ;
  }

  if ( mk_state & (K_LSHIFT|K_RSHIFT) )
  {
    /* Right or Left Shift: extend selection */
    wselect_icons( wext, wext->sel_icon, index, 1 ) ;
    GWRePaint( wnd ) ;
  }

  if ( (mk_state == 0) && catalog_filter )
  {
    /* No special key: remove selected icons */
    wselect_icons( wext, 0, catalog_filter->nb_visibles-1, 0 ) ;
    GWRePaint( wnd ) ;
  }

  return GW_EVTSTOPROUTING ;
}

static int OnRButtonDownAlbum(void *w, int mk_state, int mx, int my)
{
  GEM_WINDOW*     wnd = (GEM_WINDOW* ) w ;
  WALB_EXTENSION* wext = wnd->Extension ;
  CATALOG_FILTER* catalog_filter = catalog_get_filter(wext->hCat) ;
  OBJECT*         popup ;
  long            num_vignette ;
  long            nsel ;
  int             i, clicked ;
  int             wx, wy, dummy ;
  int             nb_items = 1+MSG_PEHTML-MSG_PLOADIMG+2 ; /* 2: seperator,select all */
  int             nchars=30 ;
  char            buf[PATH_MAX] ;

  if ( !catalog_filter )
  {
    LoggingDo(LL_ERROR, "Invalid hCat");
    return 0 ;
  }

  nsel = catalog_getnsel(wext->hCat) ;
  if ( nsel > 0 ) nb_items += 2 ; /* 2: delete icons, delete files */

  num_vignette = GetNumVignette( wnd, mx, my ) ;
  if ( num_vignette < 0 ) return( 0 ) ;

  popup = popup_make( nb_items, nchars ) ;
  if ( popup == NULL ) return( 0 ) ;
  for ( i = MSG_PLOADIMG; i <= MSG_PEHTML; i++ )
  {
    strncpy( popup[1+i-MSG_PLOADIMG].ob_spec.free_string, MsgTxtGetMsg(hMsg, i), nchars ) ;
    popup[1+i-MSG_PLOADIMG].ob_flags |= SELECTABLE ;
  }

  /* Add new features, unfortunatly not contiguous with VMSG list */
  strncpy( popup[1+i-MSG_PLOADIMG].ob_spec.free_string, "--------------------------------", nchars ) ;
  popup[1+i-MSG_PLOADIMG].ob_flags &= ~SELECTABLE ;
  i++ ;

  strncpy( popup[1+i-MSG_PLOADIMG].ob_spec.free_string, MsgTxtGetMsg(hMsg, MSG_WASALL), nchars ) ;
  popup[1+i-MSG_PLOADIMG].ob_flags |= SELECTABLE ;
  i++ ;

  if ( nsel > 0 )
  {
    strncpy( popup[1+i-MSG_PLOADIMG].ob_spec.free_string, MsgTxtGetMsg(hMsg, MSG_WADELICONS), nchars ) ;
    popup[1+i-MSG_PLOADIMG].ob_flags |= SELECTABLE ;
    i++ ;
    strncpy( popup[1+i-MSG_PLOADIMG].ob_spec.free_string, MsgTxtGetMsg(hMsg, MSG_WADELFILES), nchars ) ;
    popup[1+i-MSG_PLOADIMG].ob_flags |= SELECTABLE ;
  }

  wnd->GetWorkXYWH( wnd, &wx, &wy, &dummy, &dummy ) ;
  clicked = popup_formdo( &popup, wx+mx-16, wy+my, 1, 0 ) ;
  popup_kill( popup, nb_items ) ;

  switch ( MSG_PLOADIMG+clicked-1 )
  {
    case MSG_PLOADIMG  : catalog_getfullname( wext->hCat, num_vignette, buf ) ;
                         load_wpicture( buf, IID_UNKNOWN ) ;
                         break ;

    case MSG_PIMGINFO  : show_imginfo( wext->hCat, num_vignette, wext->tab_vignette[num_vignette-wext->start_visible].com ) ;
                         break ;

    case MSG_PEHTML    : HTMLCatalogExport( wext->hCat, 0, catalog_filter->nb_visibles - 1 ) ;
                         break ;
    case MSG_PEHTML+2  : /* --> MSG_WASALL */
                         OnKeyPressedAlbum( w, KBD_CTRL_A ) ;
                         break ;
    case MSG_PEHTML+3  : /* --> MSG_WADELICONS */
                         OnKeyPressedAlbum( w, KBD_DELETE ) ;
                         break ;
    case MSG_PEHTML+4  : /* --> MSG_WADELFILES */
                         OnKeyPressedAlbum( w, KBD_LSDELETE ) ;
                         break ;
  }

  return GW_EVTSTOPROUTING ;
}

static int OnMouseMoveAlbum(void *w, int button, int kstate, int mx, int my)
{
  GEM_WINDOW*     wnd = (GEM_WINDOW* ) w ;
  WALB_EXTENSION* wext = (WALB_EXTENSION *) wnd->Extension ;
  CATALOG_FILTER* catalog_filter = catalog_get_filter(wext->hCat) ;
  CATALOG_HEADER* catalog_header = catalog_get_header(wext->hCat) ;
  long            num_vignette ;
  char            buf[64+PATH_MAX] ;

  if ( !catalog_header || !catalog_filter )
  {
    LoggingDo(LL_ERROR, "Invalid hCat");
    return GW_EVTSTOPROUTING ;
  }

  num_vignette = GetNumVignette( wnd, mx, my ) ;
  if ( num_vignette != -1 )
  {
    if ( num_vignette != wext->NumVignetteInfo )
    {
      make_info( wext, num_vignette, buf ) ;
      GWSetWindowInfo( wnd, buf ) ;
      wext->NumVignetteInfo = num_vignette ;
    }
  }
  else if ( wext->NumVignetteInfo != -1L )
  {
    char buffer[128] ;

    sprintf( buf, MsgTxtGetMsg(hMsg, MSG_CATINFO) , catalog_filter->nb_visibles, catalog_header->nb_records ) ;
    get_info_fonname( catalog_filter, buffer ) ;
    strcat(buf, buffer) ;
    GWSetWindowInfo( wnd, buf ) ;
    wext->NumVignetteInfo = -1L ;
  }

  return GW_EVTSTOPROUTING ;
}

static int OnMsgUserAlbum(void* w, int msg_id, int mesag[4])
{
  GEM_WINDOW*     wnd = (GEM_WINDOW*) w ;
  WALB_EXTENSION* wext = (WALB_EXTENSION *) wnd->Extension ;

  switch(msg_id)
  {
    case MSG_WALB_REFRESH: wext->start_visible = 0 ; /* Make it simple */
                           ajuste_premiere_vignette(wext) ;
                           update_vslider(wnd) ;
                           ajour_vignettes( wnd, 1 ) ;
                           break ;

    default:               LoggingDo(LL_WARNING, "Unknown User Message %d for WAlbum", msg_id) ;
                           break ;
  }

  return 0 ;
}

#pragma warn +par

static GEM_WINDOW* VWAlbCreateWindow(void)
{
  return GWCreateWindow( WALB_STYLE, sizeof(WALB_EXTENSION), VWALB_CLASSNAME ) ;
}

static char* OnGetWindowID(void* w)
{
  GEM_WINDOW*     wnd = (GEM_WINDOW*) w ;
  WALB_EXTENSION* wext = (WALB_EXTENSION *) wnd->Extension ;

  return wext->WindowID ;
}

GEM_WINDOW* album_window(HCAT hCat, GEM_WINDOW* wnd_album, GEM_WINDOW** pwnd)
{
  CATALOG_HEADER* catalog_header = catalog_get_header(hCat) ;
  CATALOG_FILTER* catalog_filter = catalog_get_filter(hCat) ;
  INDEX_RECORD*   tab_index = catalog_get_index_record(hCat) ;
  GEM_WINDOW*     WndAlbum ;
  WALB_EXTENSION* wext ;
  int             xe, ye, we, he ;
  int             dummy ;
  char            buf[200] ;

  if ( !catalog_header || !catalog_filter || !tab_index )
  {
    LoggingDo(LL_ERROR, "Invalid hCat");
    return NULL ;
  }

  WndAlbum = VWAlbCreateWindow() ;
  if ( WndAlbum == NULL )
  {
    form_stop(1, MsgTxtGetMsg(hMsg, MSG_NOMOREWINDOW) ) ;
    return NULL ;
  }

  wext = (WALB_EXTENSION *) WndAlbum->Extension ;
  wext->hCat      = hCat ;
  wext->wnd_album = wnd_album ;
  sprintf( wext->WindowID, "WAlb_%s", wnd_album->GetWindowID ? wnd_album->GetWindowID(wnd_album):"Unknown" ) ;
  wext->pwnd      = pwnd ;
  wind_calc( WC_WORK, WALB_STYLE, xdesk, ydesk, wdesk, hdesk, &xe, &ye, &we, &he ) ;
  wext->nb_w          = we/catalog_header->width ;
  wext->h_vignette    = 16+catalog_header->height ;
  wext->nb_h          = he/wext->h_vignette ;
  wext->nb_vignettes_max = wext->nb_vignettes = wext->nb_w*wext->nb_h ;
  wext->start_visible = 0 ;
  wext->last_start_visible = -1 ;
  wext->tab_vignette = (VIGNETTE*) Xcalloc( wext->nb_vignettes_max, sizeof(VIGNETTE) ) ;
  if ( wext->tab_vignette == NULL )
  {
    form_error(8) ;
    GWDestroyWindow( WndAlbum ) ;
    LoggingDo(LL_ERROR, "Can't allocate vignettes");
    return NULL ;
  }

  catalog_filter->filter_on_name = 0 ;
  catalog_filter->contains       = 0 ;
  catalog_filter->filter_name[0] = 0 ;
  wext->name_filter_offset       = 0 ;
  /* Allocate an empty image icon for displaying invalid items */
  wext->emptyImg.fd_w = catalog_header->width ;
  wext->emptyImg.fd_h = catalog_header->height ;
  wext->emptyImg.fd_wdwidth = w2wdwidth( wext->emptyImg.fd_w ) ;
  wext->emptyImg.fd_nplanes = screen.fd_nplanes ;
  wext->emptyImg.fd_stand   = 0 ;
  wext->emptyImg.fd_addr    = img_alloc( wext->emptyImg.fd_w, wext->emptyImg.fd_h, wext->emptyImg.fd_nplanes ) ;
  if ( wext->emptyImg.fd_addr == NULL )
  {
    form_error(8) ;
    Xfree( wext->tab_vignette ) ;
    GWDestroyWindow( WndAlbum ) ;
    LoggingDo(LL_ERROR, "Can't allocate empty image");
    return NULL ;
  }
  img_raz( &wext->emptyImg ) ;

  wind_calc( WC_BORDER, WALB_STYLE, xe, ye, wext->nb_w*catalog_header->width, wext->nb_h*wext->h_vignette,
             &xe, &ye, &we, &he ) ;
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
  WndAlbum->OnMsgUser       = OnMsgUserAlbum ;
  WndAlbum->GetWindowID     = OnGetWindowID ;

  GWSetWindowCaption( WndAlbum, catalog_header->catalog_name ) ;
  sprintf( buf, MsgTxtGetMsg(hMsg, MSG_CATINFO) , catalog_filter->nb_visibles, catalog_header->nb_records ) ;
  GWSetWindowInfo( WndAlbum, buf ) ;

  GWSetWndRscIcon( WndAlbum, FORM_ICONS, ICN_WCAT ) ;

  GWOpenWindow( WndAlbum, xe, ye, we, he ) ;
  wind_set( WndAlbum->window_handle, WF_TOP ) ;
  WndAlbum->GetWorkXYWH( WndAlbum, &wext->xf, &wext->yf, &dummy, &dummy ) ;
  update_vslider(WndAlbum) ;

  wext->num_vignette = 0 ;
  if ( charge_nvignettes( WndAlbum, 0, wext->nb_vignettes ) != 0 )
  {
    clean_up(WndAlbum) ;

    form_error(8) ;
    GWDestroyWindow( WndAlbum ) ;
    WndAlbum = NULL ;
    LoggingDo(LL_ERROR, "Error loading icons");
  }

  *pwnd = WndAlbum ;
  return WndAlbum ;
}
