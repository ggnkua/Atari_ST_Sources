#include <stdlib.h>
#include <string.h>

#include "..\tools\gwindows.h"
#include "..\tools\imgmodul.h"
#include "..\tools\frecurse.h"
#include "..\tools\rasterop.h"
#include "..\tools\rzoom.h"
#include "..\tools\print.h"
#include "..\tools\logging.h"

#include     "defs.h"
#include "visionio.h"
#include "actions.h"
#include "touches.h"
#include "ibrowser.h"

typedef struct
{
  INFO_IMAGE inf_img ;
  MFDB       zoom ;      /* Image en cours de zoom      */

  int  img_valid ;
  int  load_err ;
  int  loading_img ;
  int  obj_notify ;
  int  x1, y1 ;           /* Partie en cours de zoom     */
  int  last_mx, last_my ;
  int  pczoom ;
  int  pzoom_index ;
  char nom[PATH_MAX] ;    /* Nom TOS complet         */

  int mini_w ;

  char   base_path[PATH_MAX] ;
  char** fimg_list ;
  int    nb_files ;
  char*  buffer_list ;
  int    pos ;
  short  do_not_use_base_path ; /* fimg_list will contain full path for each file */
}
WBROWSER ;


typedef struct
{
  OBJECT* popup_zoom ;
}
CMD_BROWSER ;

#define NB_LABELS  10
static char* popup_label[NB_LABELS] = {
                               "Auto",
                               "10%", "25%", "50%", "75%",
                               "100%",
                               "150%", "200%", "400%", "800%"
                             } ;
#define SEL_100PC    5

typedef struct
{
  int    nb_files, nfile ;
  long   nb_bytes_for_names ;
  char*  last_ptname ;
  char** fimg_list ;
}
BROWSE_FILES ;

typedef struct
{
  size_t  increment ;
  size_t  nb_files ;
  size_t  nb_bytes_for_fnames ;
  size_t  offset ;
  char*   alloc_fnames ;
}
BROWSE_FULLFILES ;

/* Suite a possibilite de recursivite mutuelle entre DisplayImg et OnObjectNotifyIBrowser */
/* Pour pouvoir gerer l'appui sur les touches <-- et --> durant un chargement */
static int OnObjectNotifyIBrowser(void* gw, int obj) ;

static short add_file_to_list(FR_CDATA* fr_cdata)
{
  BROWSE_FILES* browse_files = (BROWSE_FILES*) fr_cdata->user_data ;
  char*         slash ;

  slash = strrchr( fr_cdata->filename, '\\' ) ;
  if ( slash )
  {
    strcpy( browse_files->last_ptname, 1 + slash ) ;
    if ( DImgGetIIDFromFile( fr_cdata->filename ) != 0 )
    {
      browse_files->fimg_list[browse_files->nfile++] = browse_files->last_ptname ;
      browse_files->last_ptname += 1 + strlen( 1 + slash ) ;
    }
  }

  return 0 ;
}

static short prepare_list(FR_CDATA* fr_cdata)
{
  BROWSE_FILES* browse_files = (BROWSE_FILES*) fr_cdata->user_data ;
  char*         slash ;

  slash = strrchr( fr_cdata->filename, '\\' ) ;
  if ( slash )
  {
    browse_files->nb_files++ ;
    browse_files->nb_bytes_for_names += 1 + strlen( 1+ slash ) ;
  }

  return 0 ;
}

static int cmp_file(const void* e1, const void* e2)
{
  int  cmp, ret = 0 ;
  char **f1, **f2 ;

  f1 = (char**) e1 ;
  f2 = (char**) e2 ;

  cmp = strcmpi( *f1, *f2 ) ;
  if ( cmp < 0 )      ret = -1 ;
  else if ( cmp > 0 ) ret = 1 ;

  return ret ;
}

static void build_flist(WBROWSER* wb)
{
  FR_DATA      fr_data ;
  BROWSE_FILES browse_files ;
  int          i, trouve ;
  char*        slash ;

  memzero( &browse_files, sizeof(browse_files) ) ;
  strcpy( wb->base_path, wb->nom ) ;
  slash = strrchr( wb->base_path, '\\' ) ;
  if ( slash ) *slash = 0 ;

  fr_data.flags      = GetLongFileNamesStatus() ;
  fr_data.path       = wb->base_path ;
  fr_data.mask       = "*.*" ;
  fr_data.log_file   = NULL ;
  fr_data.user_func  = prepare_list ;
  fr_data.user_data  = &browse_files ;
  find_files( &fr_data ) ;
  wb->fimg_list = Xcalloc( 100+browse_files.nb_files, sizeof(char*) ) ; /* +100 in case new files show up... */
  if ( wb->fimg_list )
  {
    browse_files.nfile = 0 ;
    wb->buffer_list = Xcalloc( 1, browse_files.nb_bytes_for_names + 500 ) ; /* +500 in case new files show up ... */
    browse_files.last_ptname = wb->buffer_list ;
    if ( wb->buffer_list )
    {
      browse_files.fimg_list = wb->fimg_list ;
      fr_data.flags     = GetLongFileNamesStatus() ;
      fr_data.path       = wb->base_path ;
      fr_data.mask       = "*.*" ;
      fr_data.log_file   = NULL ;
      fr_data.user_func  = add_file_to_list ;
      fr_data.user_data  = &browse_files ;
      find_files( &fr_data ) ;
      wb->nb_files = browse_files.nfile ;

      /* Trier le dossier */
      qsort( wb->fimg_list, wb->nb_files, sizeof(char**), cmp_file ) ;

      /* Recherche de la position du fichier courant */
      trouve = 0 ;
      for ( i = 0; !trouve && ( i < wb->nb_files ) ; i++ )
        if ( strcmpi( wb->fimg_list[i], 1 + slash ) == 0 ) trouve = 1 ;

      if ( trouve ) wb->pos = i-1 ;
      else          wb->pos = 0 ;
    }
  }
}

static void free_current_img(WBROWSER* wb)
{
  free_info( &wb->inf_img ) ;
  memzero( &wb->inf_img, sizeof(INFO_IMAGE) ) ;
  if ( wb->zoom.fd_addr ) Xfree( wb->zoom.fd_addr ) ;
  wb->zoom.fd_addr = NULL ;
}

static void free_current_folder(WBROWSER* wb)
{
  if ( wb->fimg_list ) Xfree( wb->fimg_list ) ;
  wb->fimg_list = NULL ;
  if ( wb->buffer_list ) Xfree( wb->buffer_list ) ;
  wb->buffer_list = NULL ;
}

static void adapt_display(GEM_WINDOW* wnd, int set_window)
{
  WBROWSER*    wb   = (WBROWSER*) wnd->Extension ;
  OBJECT*      bobj = wnd->DlgData->BaseObject ;
  CMD_BROWSER* wdlg = wnd->DlgData->UserData ;
  int          i, w, h, ibh = bobj[0].ob_height ;

  if ( wb->fimg_list == NULL ) return ;

  wb->x1 = wb->y1 = 0 ;
  /* Calcul du facteur de zoom */
  if ( wb->pczoom < 0 )
  {
    wind_calc( WC_WORK, wnd->window_handle, xdesk, ydesk, wdesk, hdesk, &i, &i, &w, &h  ) ;
    i = (int) ( (w * 100L) / wb->inf_img.mfdb.fd_w ) ;
    wb->pczoom = (int) ( ((h - ibh) * 100L) / wb->inf_img.mfdb.fd_h ) ;
    if ( wb->pczoom > i ) wb->pczoom = i ;
    if ( wb->pczoom > 100 ) wb->pczoom = 100 ;
  }

  if ( wb->zoom.fd_addr ) Xfree( wb->zoom.fd_addr ) ;
  wb->zoom.fd_addr = NULL ;
  if ( wb->pczoom != 100 ) 
  {
    float ratio ;
    
    ratio         = (float)wb->pczoom / 100.0 ;
    wb->zoom.fd_w = (int) ( 0.5 + (float)wb->inf_img.mfdb.fd_w * ratio ) ;
    wb->zoom.fd_h = (int) ( 0.5 + (float)wb->inf_img.mfdb.fd_h * ratio ) ;
    if ( RasterZoom( &wb->inf_img.mfdb, &wb->zoom, wnd ) != 0 )
    {
      wb->pczoom      = 100 ;
      wb->pzoom_index = SEL_100PC ;
    }
  }
  if ( wb->pczoom == 100 )
  {
    w = wb->inf_img.width ;
    h = wb->inf_img.mfdb.fd_h + ibh ;
  }
  else
  {
    w = wb->zoom.fd_w ;
    h = wb->zoom.fd_h + ibh ;
  }

  if ( w < wb->mini_w ) w = wb->mini_w ;
  else                  bobj[0].ob_width = w ;
  if ( set_window )
  {
    int xo, yo, wo, ho ;
    int xco, yco, wh0 ;

    yopen -= ibh+16 ; /* Fake yopen as open_where assumes we want to open a new window below Image Browser one */
    open_where( wnd->window_kind, w, h, &xo, &yo, &wo, &ho ) ;
    yopen += ibh+16 ;
    GWGetCurrXYWH( wnd, &xco, &yco, &wh0, &wh0 ) ;
    if ( ( xco + wo > Xmax ) || ( yco + ho > Ymax ) ) GWSetCurrXYWH( wnd, xo, yo, wo, ho ) ;
    else                                              GWSetCurrXYWH( wnd, xco, yco, wo, ho ) ;
  }

  GWGetWorkXYWH( wnd, &bobj[0].ob_x, &bobj[0].ob_y, &w, &h ) ;
  GWInvalidate( wnd ) ;
  wb->img_valid = 1 ;
  write_text( bobj, IMGB_TEXT, "" ) ;
  xobjc_draw( wnd->window_handle, bobj, IMGB_TEXT ) ;

  if ( wb->pzoom_index > 1 ) write_text( bobj, IMGB_SCALE, wdlg->popup_zoom[1+wb->pzoom_index].ob_spec.free_string ) ;
  else                       write_text( bobj, IMGB_SCALE, wdlg->popup_zoom[1].ob_spec.free_string ) ; /* AUTO */
  xobjc_draw( wnd->window_handle, bobj, IMGB_SCALE ) ;
}

static int DisplayImg(GEM_WINDOW* wnd, int create_open, int reload)
{
  WBROWSER* wb   = (WBROWSER*) wnd->Extension ;
  OBJECT*   bobj = wnd->DlgData->BaseObject ;
  int       ret, w, h ;
  int       xo, yo, wo, ho ;
  int       xco, yco, wco, hco ;
  char*     slash ;

  mouse_busy() ;
  wb->img_valid   = 0 ;
  wb->loading_img = 1 ;
  wb->load_err    = 0 ;
  wb->obj_notify  = 0 ;
  free_current_img( wb ) ;
  strcpy( wb->base_path, wb->nom ) ;
  slash = strrchr( wb->base_path, '\\' ) ;
  if ( slash ) *slash = 0 ;
  if ( reload ) free_current_folder( wb ) ;
  GWInvalidate( wnd ) ;
  ret = vimg_format( IID_UNKNOWN, -1, wb->nom, &wb->inf_img ) ;
  if ( ret == 0 )
  {
    w = wb->inf_img.width ;
    h = wb->inf_img.height + bobj[0].ob_height ;
    if ( w < wb->mini_w ) w = wb->mini_w ;
    else                  bobj[0].ob_width = w ;
    open_where( wnd->window_kind, w, h, &xo, &yo, &wo, &ho ) ;
    if ( reload ) build_flist( wb ) ;
    if ( create_open ) GWOpenWindow( wnd, xo, yo, wo, ho ) ;
    else               GWGetCurrXYWH( wnd, &xco, &yco, &wco, &hco ) ;
    GWGetWorkXYWH( wnd, &bobj[0].ob_x, &bobj[0].ob_y, &w, &h  ) ;
    wb->inf_img.mfdb.fd_nplanes = screen.fd_nplanes ;
    wb->inf_img.prog            = wnd ;
    ret = vload_picture( &wb->inf_img ) ;
    write_text( bobj, IMGB_TEXT, "" ) ;
    xobjc_draw( wnd->window_handle, bobj, IMGB_TEXT ) ;
    if ( ret == 0 )
    {
      if ( wb->pzoom_index == 0 ) wb->pczoom = -1 ;
      adapt_display( wnd, 1 ) ;
      set_imgpalette( (VXIMAGE*)wb ) ;
      wb->img_valid = 1 ;
    }
  }
  mouse_restore() ;
  wb->load_err    = ret ;
  wb->loading_img = 0 ;
  GWSetWindowCaption( wnd, wb->nom ) ;

  if ( wb->obj_notify ) OnObjectNotifyIBrowser( wnd, wb->obj_notify ) ;

  return ret ;
}

static void OnInitDialogIBrowser(void* w)
{
  GEM_WINDOW*  wnd = (GEM_WINDOW*) w ;
  OBJECT*      bobj = wnd->DlgData->BaseObject ;
  WBROWSER*    wb   = (WBROWSER*) wnd->Extension ;
  CMD_BROWSER* wdlg = wnd->DlgData->UserData ;
  int          i ;
  int          sel = SEL_100PC ; /* 100% */

  wdlg->popup_zoom = popup_make( NB_LABELS, 3 + 1 + (int)strlen( popup_label[0] ) ) ;
  if ( wdlg->popup_zoom == NULL ) return ;
  for ( i = 0; i < NB_LABELS; i++ )
   sprintf( wdlg->popup_zoom[1+i].ob_spec.free_string, "  %s ", popup_label[i] ) ;

  write_text( bobj, IMGB_SCALE, wdlg->popup_zoom[1+sel].ob_spec.free_string ) ;
  sscanf( wdlg->popup_zoom[1+sel].ob_spec.free_string, "%d%%", &wb->pczoom ) ;

  write_text( bobj, IMGB_TEXT, "" ) ;

  wb->mini_w = bobj[0].ob_width ;
}

static void new_edit_vximage(WBROWSER* wb)
{
  GEM_WINDOW* new_wnd ;
  VXIMAGE*    new_vimage ;
  MFDB*       raster ;
  int         xy[8] ;
  int         w, h ;
  int         tpmx, tpmy ;
  char        name[50] ;

  if ( wb->pczoom == 100 ) raster = &wb->inf_img.mfdb ;
  else                     raster = &wb->zoom ;

  w    = raster->fd_w ;
  h    = raster->fd_h ;
  tpmx = micron2inch( wb->inf_img.lpix ) ;
  tpmy = micron2inch( wb->inf_img.hpix ) ;
  if ( Truecolor ) strcpy( name, "NEW.TIF" ) ;
  else             strcpy( name, "NEW.IMG" ) ;

  new_wnd = nouvelle_wimage( name, w, h, 1 << wb->inf_img.nplanes, tpmx, tpmy ) ;
  if ( new_wnd )
  {
    new_vimage = (VXIMAGE*) new_wnd->Extension ;

    xy[0] = 0 ;     xy[1] = 0 ;
    xy[2] = w - 1 ; xy[3] = h - 1 ;
    xy[4] = 0 ;     xy[5] = 0 ;
    xy[6] = w-1 ;   xy[7] = h-1 ;

    vro_cpyfm( handle, S_ONLY, xy, raster, &new_vimage->inf_img.mfdb ) ;
  }
  else form_error( 8 ) ;
}

static void update_nav(GEM_WINDOW* wnd)
{
  WBROWSER* wb  = (WBROWSER*) wnd->Extension ;
  OBJECT*   bobj = wnd->DlgData->BaseObject ;
  char      buf[20] ;

#ifdef __NO_PRINT
  bobj[IMGB_PRINT].ob_state &= ~DISABLED ;
#endif

  if ( wb->fimg_list )
  {
    bobj[IMGB_PREVIOUS].ob_state &= ~DISABLED ;
    bobj[IMGB_NEXT].ob_state     &= ~DISABLED ;
    bobj[IMGB_EDIT].ob_state     &= ~DISABLED ;
    bobj[IMGB_DELETE].ob_state   &= ~DISABLED ;
  }
  else
  {
    bobj[IMGB_PREVIOUS].ob_state |= DISABLED ;
    bobj[IMGB_NEXT].ob_state     |= DISABLED ;
    bobj[IMGB_EDIT].ob_state     |= DISABLED ;
    bobj[IMGB_DELETE].ob_state   |= DISABLED ;
  }

  if ( wb->pos == 0 ) bobj[IMGB_PREVIOUS].ob_state |= DISABLED ;
  if ( wb->pos == wb->nb_files - 1 ) bobj[IMGB_NEXT].ob_state |= DISABLED ;

  if ( wb->nom[0] ) sprintf( buf, "%d/%d", 1 + wb->pos, wb->nb_files ) ;
  else              buf[0] = 0 ;
  write_text( bobj, IMGB_TEXT2, buf ) ;

  xobjc_draw( wnd->window_handle, bobj, IMGB_PREVIOUS ) ;
  xobjc_draw( wnd->window_handle, bobj, IMGB_NEXT ) ;
  xobjc_draw( wnd->window_handle, bobj, IMGB_TEXT2 ) ;
  xobjc_draw( wnd->window_handle, bobj, IMGB_EDIT ) ;
  xobjc_draw( wnd->window_handle, bobj, IMGB_DELETE ) ;
}

static void BuildFname(WBROWSER* wb)
{
  if ( wb->do_not_use_base_path ) strcpy( wb->nom, wb->fimg_list[wb->pos] ) ;
  else                            sprintf( wb->nom, "%s\\%s", wb->base_path, wb->fimg_list[wb->pos] ) ;
}

int ObjectNotifyIBrowser(void* gw, int obj, void* external_call)
{
  GEM_WINDOW*  wnd  = (GEM_WINDOW*) gw ;
  WBROWSER*    wb   = (WBROWSER*) wnd->Extension ;
  CMD_BROWSER* wdlg = wnd->DlgData->UserData ;
  OBJECT*      bobj = wnd->DlgData->BaseObject ;
  int          i, off_x, off_y ;
  int          do_it = 0 ;
  int          code = -1 ;
  char         buf[PATH_MAX] ;

  switch( obj )
  {
    case IMGB_OPEN     : if ( !external_call )
                         {
                           if ( wb->base_path[0] ) sprintf( buf, "%s\\*.*", wb->base_path ) ;
                           else                    sprintf( buf, "%s\\*.*", config.path_img ) ;
                           do_it = ( file_name( buf, "", buf ) == 1 ) ;
                         }
                         else
                         {
                           buf[0] = 0 ;
                           strcpy( buf, external_call ) ;
                           do_it = (buf[0] != 0) ;
                         }
                         if ( do_it )
                         {
                           wb->do_not_use_base_path = 0 ;
                           strcpy( wb->nom, buf ) ;
                           DisplayImg( wnd, 0, 1 ) ;
                         }
                         deselect( bobj, obj ) ;
                         update_nav( wnd ) ;
                         break ;

    case IMGB_PREVIOUS : 
    case IMGB_NEXT     : if ( wb->fimg_list )
                         {
                           int new_pos = wb->pos ;
                           int add = 1 ;

                           if ( xKbshift() ) add = 10 ;
                           if ( obj == IMGB_PREVIOUS ) add = -add ;
                           new_pos += add ;
                           if ( new_pos < 0 ) new_pos = 0 ;
                           if ( new_pos > wb->nb_files - 1 ) new_pos = wb->nb_files - 1 ;
                           if ( new_pos != wb->pos )
                           {
                             wb->pos = new_pos ;
                             BuildFname( wb ) ;
                             DisplayImg( wnd, 0, 0 ) ;
                           }
                         }
                         deselect( bobj, obj ) ;
                         update_nav( wnd ) ;
                         break ;

    case IMGB_SCALE    : deselect( bobj, obj ) ;
                         objc_offset( bobj, obj, &off_x, &off_y ) ;
                         i = popup_formdo( &wdlg->popup_zoom, off_x, off_y, 1 + wb->pzoom_index, 0 ) ;
                         if ( i > 0 )
                         {
                           wb->pzoom_index = i - 1 ;
                           LoggingDo(LL_DEBUG, "IMGB_SCALE, pzoom_index=%d", wb->pzoom_index) ;
                           write_text( bobj, obj, wdlg->popup_zoom[i].ob_spec.free_string ) ;

                           if ( wb->pzoom_index > 0 ) sscanf( wdlg->popup_zoom[i].ob_spec.free_string, "%d%%", &wb->pczoom ) ;
                           else                       wb->pczoom = -1 ;

                           adapt_display( wnd, 1 ) ;
                         }
                         break ;

    case IMGB_EDIT     : deselect( bobj, obj ) ;
                         if ( wb->fimg_list ) new_edit_vximage( wb ) ;
                         xobjc_draw( wnd->window_handle, bobj, obj ) ;
                         break ;

    case IMGB_DELETE   : deselect( bobj, obj ) ;
                         if ( wb->fimg_list )
                           if ( form_interrogation( 2, MsgTxtGetMsg(hMsg, MSG_CONFIRMDEL) ) == 1 )
                             if ( Fdelete( wb-> nom ) ) form_stop( 1, MsgTxtGetMsg(hMsg, MSG_WRITEERROR) ) ;
                         xobjc_draw( wnd->window_handle, bobj, obj ) ;
                         break ;
#ifndef __NO_PRINT
    case IMGB_PRINT   : deselect( bobj, obj ) ;
                        GetAppTitle( buf ) ;
                        switch( print_image( &wb->inf_img, buf ) )
                        {
                          case PNOGDOS   : form_stop(1, MsgTxtGetMsg(hMsg, MSG_PNOGDOS) ) ;
                                           break ;
                          case PTIMEOUT  : form_stop(1, MsgTxtGetMsg(hMsg, MSG_PTIMEOUT) ) ;
                                           break ;
                          case PWRITERR  : form_stop(1, MsgTxtGetMsg(hMsg, MSG_PWRITERR) ) ;
                                           break ;
                          case PNOHANDLE : form_stop(1, MsgTxtGetMsg(hMsg, MSG_PNOHANDLE) ) ;
                                           break ;
                          case PROTERR   : form_error(8) ;
                                           break ;
                          case PNODRIVER : form_stop(1, MsgTxtGetMsg(hMsg, MSG_PNODRIVER) ) ;
                                           break ;
                        }
                        xobjc_draw( wnd->window_handle, bobj, obj ) ;
                        break ;
#endif
  }

  return code ;
}

static int OnObjectNotifyIBrowser(void* gw, int obj)
{
  return ObjectNotifyIBrowser( gw, obj, NULL ) ;
}

static int OnCloseIBrowser(void* w)
{
  GEM_WINDOW*  wnd = (GEM_WINDOW*) w ;
  WBROWSER*    wb  = (WBROWSER*) wnd->Extension ;
  CMD_BROWSER* wdlg = wnd->DlgData->UserData ;

  free_current_img( wb ) ;
  free_current_folder( wb ) ;

  popup_kill( wdlg->popup_zoom, NB_LABELS ) ;

  Xfree( wdlg ) ;

  return( GWCloseDlg( w ) ) ;
}

static void OnImgDraw(GEM_WINDOW* wnd, int xywh[4])
{
  WBROWSER* wb  = (WBROWSER*) wnd->Extension ;
  MFDB*     raster ;
  int       w, h ;
  int       off_x, off_y, xi, yi, wi, hi ;
  int       xy[8] ;
  int       posx, posy ;

  wnd->GetWorkXYWH( wnd, &xi, &yi, &wi, &hi ) ;

  if ( !wb->img_valid || wb->load_err )
  {
    GWOnDraw( wnd, xywh ) ;
    if ( wb->load_err )
    {
      vsl_ends( handle, 0, 0 ) ;
      vsl_width( handle, 3 ) ;
      vsl_color( handle, 1 ) ;
      line( xi + wi -1, yi, xi, yi + hi - 1  ) ;
      line( xi, yi, xi + wi -1, yi + hi - 1 ) ;
    }
    return ;
  }
  
  posx = wb->x1 ;
  posy = wb->y1 ;
  if ( wb->pczoom == 100 ) raster = &wb->inf_img.mfdb ;
  else                     raster = &wb->zoom ;

  off_x = xywh[0] - xi ;
  off_y = xywh[1] - yi ;
  w = xywh[2] ;
  if ( off_x + posx + w > raster->fd_w ) w -= off_x + posx + w - raster->fd_w ;
  h = xywh[3] ;
  xy[4] = xywh[0] ;         xy[5] = xywh[1] ;
  xy[6] = xywh[0] + w - 1 ; xy[7] = xywh[1] + h - 1 ;

  xy[0] = off_x + posx ; xy[1] = off_y + posy ;
  xy[2] = xy[0] + w - 1 ;
  xy[3] = xy[1] + h - 1 ;
  
  vro_cpyfm( handle, S_ONLY, xy, raster, &screen ) ;

  if ( w != xywh[2] )
  {
    xy[0] = 1 + xy[6] ;
    xy[2] = xywh[2] - w ;
    xy[1] = xywh[1] ;
    xy[3] = xywh[3] ;
    GWOnDraw( wnd, xy ) ;
  }
}

static void OnDrawIBrowser(void* gw, int xywh[4])
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) gw ;
  OBJECT*     bobj = wnd->DlgData->BaseObject ;
  int         xy[4] ;
  int         x, y, w ,h ;

  objc_offset( bobj, 0, &x, &y ) ;
  if ( intersect( x, y, bobj[0].ob_width, bobj[0].ob_height, xywh[0], xywh[1], xywh[2], xywh[3], xy ) )
  {
    xy[2] = 1 + xy[2] - xy[0] ;
    xy[3] = 1 + xy[3] - xy[1] ;
    OnDrawDlg( gw, xy ) ;
  }

  wnd->GetWorkXYWH( gw, &x, &y, &w, &h ) ;
  if ( intersect( x, y, w, h, xywh[0], xywh[1], xywh[2], xywh[3], xy ) )
  {
    xy[2] = 1 + xy[2] - xy[0] ;
    xy[3] = 1 + xy[3] - xy[1] ;
    OnImgDraw( wnd, xy ) ;
  }
}

static void GetWorkXYWHIBrowser(void* gw, int* x, int* y, int* w, int* h)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) gw ;
  OBJECT*     bobj = wnd->DlgData->BaseObject ;

  GWGetWorkXYWH( wnd, x, y, w, h ) ;
  *y += bobj[0].ob_height ;
  *h -= bobj[0].ob_height ;
}

#pragma warn -par
static int OnProgRangeIBrowser(void* w, long val, long max, char* txt)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
  OBJECT*     bobj = wnd->DlgData->BaseObject ;
  int         stop = 0 ;
  char        buf[20] ;

  if ( max )
  {
    short pc = cal_pc( val, max ) ;

    sprintf( buf, "(%d%%)", pc ) ;
    write_text( bobj, IMGB_TEXT, buf ) ;
    xobjc_draw( wnd->window_handle, bobj, IMGB_TEXT ) ;
    stop = ( GWBasicModalHandler() == GW_EVTSTOPROUTING ) ;
  }

  return stop ;
}
#pragma warn +par

static int OnTxtBubbleIBrowser(void* w, int mx, int my, char* txt)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
  OBJECT*     adr_form =  wnd->DlgData->BaseObject ;
  int         obj = objc_find( adr_form, 0, MAX_DEPTH, mx, my ) ;
  int         objs[] = { IMGB_OPEN,   IMGB_PREVIOUS, IMGB_NEXT,   IMGB_SCALE,   IMGB_EDIT,   IMGB_DELETE,   IMGB_PRINT } ;
  int         msgs[] = { MSG_HIBOPEN, MSG_HIBPREV,   MSG_HIBNEXT, MSG_HIBSCALE, MSG_HIBEDIT, MSG_HIBDELETE, MSG_HIBPRINT } ;

/*
  switch( objet )
  {
    case IMGB_OPEN       : strcpy(txt, MsgTxtGetMsg(hMsg, MSG_HIBOPEN) ) ;
                           break ;

    case IMGB_PREVIOUS   : strcpy(txt, MsgTxtGetMsg(hMsg, MSG_HIBPREV) ) ;
                           break ;

    case IMGB_NEXT       : strcpy(txt, MsgTxtGetMsg(hMsg, MSG_HIBNEXT) ) ;
                           break ;

    case IMGB_SCALE      : strcpy(txt, MsgTxtGetMsg(hMsg, MSG_HIBSCALE) ) ;
                           break ;

    case IMGB_EDIT       : strcpy(txt, MsgTxtGetMsg(hMsg, MSG_HIBEDIT) ) ;
                           break ;

    case IMGB_DELETE     : strcpy(txt, MsgTxtGetMsg(hMsg, MSG_HIBDELETE) ) ;
                           break ;

    case IMGB_PRINT      : strcpy(txt, MsgTxtGetMsg(hMsg, MSG_HIBPRINT) ) ;
                           break ;

    default              : trouve = 0 ;
  }
*/
  return( vget_txtbubblemsg( obj, objs, msgs, ARRAY_SIZE(objs), txt ) ) ;
}

#pragma warn -par
static int OnMouseMoveIBrowser(void* gw, int button, int kstate, int mx, int my )
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) gw ;
  WBROWSER*   wb  = (WBROWSER*) wnd->Extension ;

  wb->last_mx = mx ;
  wb->last_my = my ;

  return 0 ;
}
#pragma warn +par

static int OnLButtonDownIBrowser(void* gw, int mk_state, int mx, int my)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) gw ;
  WBROWSER*   wb  = (WBROWSER*) wnd->Extension ;
  MFDB*       raster ;
  int         w, h, dummy ;

  if ( OnLButtonDownDlg( wnd, mk_state, mx, my ) == 0 )
  {
    if ( wb->pczoom == 100 ) raster = &wb->inf_img.mfdb ;
    else                     raster = &wb->zoom ;
    /* Bouton gauche appuye sur l'image */
    wb->x1 += wb->last_mx - mx ;
    wb->y1 += wb->last_my - my ;

    if ( wb->x1 < 0 ) wb->x1 = 0 ;
    if ( wb->y1 < 0 ) wb->y1 = 0 ;
    wnd->GetWorkXYWH( wnd, &dummy, &dummy, &w, &h ) ;
    if ( wb->x1 + w > raster->fd_w ) wb->x1 = raster->fd_w - w ;
    if ( wb->y1 + h > raster->fd_h ) wb->y1 = raster->fd_h - h ;
    GWRePaint( wnd ) ;
    wb->last_mx = mx ;
    wb->last_my = my ;
  }

  return 0 ;
}

static int OnKeyPressedIBrowser(void* w, int key)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
  WBROWSER*   wb  = (WBROWSER*) wnd->Extension ;
  int         code = GW_EVTCONTINUEROUTING ;

  switch( key )
  {
    case CURSOR_RT  : if ( wb->loading_img ) wb->obj_notify = IMGB_NEXT ;
                      else                   OnObjectNotifyIBrowser( w, IMGB_NEXT ) ;
                      code = GW_EVTSTOPROUTING ;
                      break ;

    case CURSOR_LSRT:
    case CURSOR_RSRT: if ( wb->fimg_list && !wb->loading_img )
                      {
                        wb->pos = wb->nb_files - 1 ;
                        BuildFname( wb ) ;
                        DisplayImg( wnd, 0, 0 ) ;
                        update_nav( wnd ) ;
                      }
                      code = GW_EVTSTOPROUTING ;
                      break ;

    case CURSOR_LT  : if ( wb->loading_img ) wb->obj_notify = IMGB_PREVIOUS ;
                      else                   OnObjectNotifyIBrowser( w, IMGB_PREVIOUS ) ;
                      code = GW_EVTSTOPROUTING ;
                      break ;

    case CURSOR_LSLT:
    case CURSOR_RSLT: if (  wb->fimg_list && !wb->loading_img )
                      {
                        wb->pos = 0 ;
                        BuildFname( wb ) ;
                        DisplayImg( wnd, 0, 0 ) ;
                        update_nav( wnd ) ;
                      }
                      code = GW_EVTSTOPROUTING ;
                      break ;

    case STD_PAL    : traite_tab( wnd ) ;
                      code = GW_EVTSTOPROUTING ;
                      break ;

    case IMPRIMER   : OnObjectNotifyIBrowser( w, IMGB_PRINT ) ;
                      code = GW_EVTSTOPROUTING ;
                      break ;
  }

  return code ;
}

#pragma warn -par
static char* OnGetWindowIDIBrowser(void* w)
{
  return "IBrowser" ;
}
#pragma warn +par

static int OnToppedIBrowser(void* w)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
  WBROWSER*   wb  = (WBROWSER*) wnd->Extension ;

  if ( !Truecolor && wb->inf_img.palette ) set_imgpalette( (VXIMAGE*) wb ) ;

  return( OnToppedDlg( w ) ) ;
}

GEM_WINDOW* CreateImgBrowser(char* filename, char high_res)
{
  DLGDATA     dlg_data ;
  GEM_WINDOW* wnd ;
  OBJECT*     bobj ;
  WBROWSER*   wb ;
  int         xo, yo, wo, ho, dummy ;

  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId         = FORM_IMGBROWSER ;
  dlg_data.ExtensionSize  = sizeof(WBROWSER) ;
  dlg_data.UserData       = Xcalloc( 1, sizeof(CMD_BROWSER) ) ;
  dlg_data.OnInitDialog   = OnInitDialogIBrowser ;
  dlg_data.OnObjectNotify = OnObjectNotifyIBrowser ;
  dlg_data.OnCloseDialog  = OnCloseIBrowser ;
  dlg_data.WKind          = SMALLER ;
  strcpy( dlg_data.ClassName, VIBROWSER_CLASSNAME ) ;
  wnd = GWCreateWindowCmdBar( &dlg_data ) ;
  if ( wnd == NULL )
  {
    Xfree( dlg_data.UserData ) ;
    return NULL ;
  }
  bobj               = wnd->DlgData->BaseObject ;
  wb                 = wnd->Extension ;
  wnd->OnDraw        = OnDrawIBrowser ;
  wnd->GetWorkXYWH   = GetWorkXYWHIBrowser ;
#ifndef __NO_BUBBLE
  wnd->OnTxtBubble   = OnTxtBubbleIBrowser ;
#endif
  wnd->ProgRange     = OnProgRangeIBrowser ;
  wnd->OnLButtonDown = OnLButtonDownIBrowser ;
  wnd->OnMouseMove   = OnMouseMoveIBrowser ;
  wnd->OnKeyPressed  = OnKeyPressedIBrowser ;
  wnd->OnTopped      = OnToppedIBrowser ;
  wnd->GetWindowID   = OnGetWindowIDIBrowser ;
  wnd->flags        |= FLG_MUSTCLIP ;

  GWSetWndRscIcon( wnd, FORM_ICONS, ICN_IBROWSER ) ;

  if ( filename )
  {
    strcpy( wb->nom, filename ) ;
    DisplayImg( wnd, 1, 1 ) ;
  }
  else
  {
    /* Fenetre sans fichier image */
    open_where( wnd->window_kind, bobj[0].ob_width, bobj[0].ob_height, &xo, &yo, &wo, &ho ) ;
    wind_calc( WC_WORK, wnd->window_handle, xo, yo, wo,ho, &bobj[0].ob_x, &bobj[0].ob_y, &dummy, &dummy  ) ;
    GWOpenWindow( wnd, xo, yo, wo, ho ) ;
    GWSetWindowCaption( wnd, "Image Browser" ) ;
    update_nav( wnd ) ;
    if ( high_res )
    {
      xopen = xo ;
      yopen = ydesk + ho ;
    }
    else
    {
      xopen  = xdesk ;
      yopen += ho ;
    }
  }

  return wnd ;
}

static short add_fullfile_to_list(BROWSE_FULLFILES* browse_ffile, char* new_file)
{
  size_t len = 1 + strlen( new_file ) ;

  if ( browse_ffile->offset + len > browse_ffile->nb_bytes_for_fnames )
  {
    char* new_alloc_fnames ;

    /* Need more space */
    new_alloc_fnames = Xrealloc( browse_ffile->alloc_fnames, browse_ffile->nb_bytes_for_fnames + browse_ffile->increment ) ;
    if ( new_alloc_fnames )
    {
      browse_ffile->alloc_fnames         = new_alloc_fnames ;
      browse_ffile->nb_bytes_for_fnames += browse_ffile->increment ;
    }
    else
    {
      LoggingDo(LL_WARNING,"Image browser: can't add more files to list (%lu)", browse_ffile->nb_files) ;
      return 1 ;
    }
  }
  memcpy( browse_ffile->alloc_fnames+browse_ffile->offset, new_file, len ) ;
  browse_ffile->offset += len ;
  browse_ffile->nb_files++ ;

  return 0 ;
}

static short fradd_fullfile_to_list(FR_CDATA* fr_cdata)
{
  if ( DImgGetIIDFromFile( fr_cdata->filename ) != IID_UNKNOWN )
    return add_fullfile_to_list( fr_cdata->user_data, fr_cdata->filename ) ;

  return 0 ;
}

static void CommitControl(GEM_WINDOW* wnd, char* data, char** cmds, short ncmds)
{
  WBROWSER* wb = (WBROWSER*) wnd->Extension ;

  free_current_folder( wb ) ;
  wb->nb_files             = ncmds ;
  wb->do_not_use_base_path = 1 ;
  wb->pos                  = 0 ;
  wb->fimg_list            = cmds ; /* Now this is responsibility of Image Browser to free it */
  wb->buffer_list          = data ; /* Now this is responsibility of Image Browser to free it */
  BuildFname( wb ) ;
  DisplayImg( wnd, 0, 0 ) ;
  update_nav( wnd ) ;
}

static char** BuildCmds( char* alloc_fnames, size_t nb_files )
{
  char** cmds = (char**) Xcalloc( nb_files, sizeof(char*) ) ;

  /* There should be nb_files in alloc_fnames (double NULL terminated) */
  if ( cmds )
  {
    char*  pt = alloc_fnames ;
    char*  cmd ;
    size_t n = 0 ;

    do
    {
      cmd = pt ;
      while ( *pt ) pt++ ;
      if ( n < nb_files ) cmds[n++] = cmd ;
      else                { LoggingDo(LL_WARNING, "BuildCmds:should not be more than %lu files; skipping", nb_files) ; break ; }
      pt++ ;
    }
    while ( *pt ) ;
  }

  return cmds ;
}

int ControlListIBrowser(GEM_WINDOW* wnd, char* data, char** cmds, short ncmds, short recurse)
{
  short ifolder ;

  if ( (wnd == NULL) || (wnd->Extension == NULL) ) return -1 ;

  /* First check if there is a folder in the list of commands */
  /* As this will require some allocation to store all files  */
  /* We won't simply get the pointers from the caller         */
  for ( ifolder = 0; ifolder < ncmds; ifolder++ )
    if ( FolderExist( cmds[ifolder] ) ) break ;

  if ( ifolder == ncmds ) CommitControl( wnd, data, cmds, ncmds ) ;
  else
  {
    BROWSE_FULLFILES browse_ffiles ;

    /* There is at least a folder in the list; that will complicate things a bit... */
    LoggingDo(LL_DEBUG,"%s is a folder, need more...", cmds[ifolder]) ;

    mouse_busy() ;
    memzero( &browse_ffiles, sizeof(browse_ffiles) ) ;
    browse_ffiles.increment = 2048UL ;
    for ( ifolder = 0; ifolder < ncmds; ifolder++ )
    {
      if ( FolderExist( cmds[ifolder] ) )
      {
        FR_DATA fr_data ;

        fr_data.path      = cmds[ifolder] ;
        fr_data.flags     = GetLongFileNamesStatus() ;
        fr_data.mask      = "*.*" ;
        fr_data.log_file  = NULL ;
        fr_data.user_func = fradd_fullfile_to_list ;
        fr_data.user_data = &browse_ffiles ;
        if ( recurse ) folder_recurse( &fr_data ) ;
        else           find_files( &fr_data ) ;
      }
      else add_fullfile_to_list( &browse_ffiles, cmds[ifolder] ) ;
    }
    mouse_restore() ;
    if ( browse_ffiles.nb_files )
    {
      char** new_cmds = BuildCmds( browse_ffiles.alloc_fnames, browse_ffiles.nb_files ) ;

      if ( new_cmds ) CommitControl( wnd, browse_ffiles.alloc_fnames, new_cmds, browse_ffiles.nb_files ) ;
      else
      {
        LoggingDo(LL_ERROR,"Image browser: can't build cmd list") ;
        Xfree( browse_ffiles.alloc_fnames ) ;
      }
    }

    /* Free duplicated stuff or stuff we can't handle anyway */
    Xfree( cmds ) ;
    Xfree( data ) ;
  }

  return 0 ;
}
