/*********************************/
/* Gestion du catalogue d'images */
/*********************************/
#include  <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>

#include     "..\tools\stdprog.h"
#include      "..\tools\xfile.h"
#include     "..\tools\stdinput.h"
#include     "..\tools\gwindows.h"
#include    "..\tools\aides.h"
#include  "..\tools\catalog.h"
#include "..\tools\frecurse.h"
#include "..\tools\imgmodul.h"
#include "..\tools\rasterop.h"
#include              "defs.h"
#include           "protect.h"

#include   "gstenv.h"
#include   "walbum.h"
#include "visionio.h"
#include "register.h"
#include "fnewalb.h"
#include "frfiles.h"
#include "finfoalb.h"
#include "falbcfg.h"
#include "falbimg.h"
#include "fbuyme.h"

#define FMT_SIZE 26

typedef struct
{
  float hf ;

  int   cconfig ;

  char *name ;
  char nom[20] ;
  char album_name[20] ;

  INFO_IMAGE imginf ;
  OBJECT     *categorie ;
  int        nb_categories ;
  char       img_comment[SIZE_COMMENT] ;

  int  first ;
  int  last_num ;
  MFDB albumimg ;
}
WEXTENSION_ALBUM ;


CATALOG_FILTER cfilter ;
static char    cat_name[PATH_MAX] ;

typedef struct
{
  GEM_WINDOW *waddprog ;
  FILE       *error_stream ;
  char       album_errfile[14] ;
  long       total_nb_files_expected ;
  long       nb_files ;
  int        cancel_adds ;
  int        nb_fails ;
}
ADD_ALBUM ;

void set_palette(INFO_IMAGE *inf)
{
  int rgb[3] ;

  if (Truecolor || (nb_plane == 1) || (inf->palette == NULL)) return ;

  if (config.color_protect && (nb_colors == 256))
  {
    set_stospalette(inf->palette, nb_colors-17, 16) ;
    set_tospalette(old_pal, 16) ;
    return ;
  }
  else
    set_tospalette(inf->palette, nb_colors) ;

  if (config.color_protect)
  {
    rgb[0] = rgb[1] = rgb[2] = 1000 ;
    vs_color(handle, 0, rgb) ;
    rgb[0] = rgb[1] = rgb[2] = 0 ;
    vs_color(handle, 1, rgb) ;
    rgb[0] = rgb[1] = rgb[2] = 753 ;
    vs_color(handle, 8, rgb) ;
    rgb[0] = rgb[1] = rgb[2] = 502 ;
    vs_color(handle, 9, rgb) ;
  }
}

void load_icon(GEM_WINDOW *wnd, int num)
{
  WEXTENSION_ALBUM *wext = wnd->DlgData->UserData ;
  OBJECT           *adr_album = wnd->DlgData->BaseObject ;
  char             *c ;
  char             buf[200] ;
  char             comment[SIZE_COMMENT] ;

  if (tab_index == NULL) return ;

  if ( wext->last_num != num )
  {
    if ((num < catalog_header.nb_records+catalog_header.nb_deleted) && tab_index[num].is_visible)
    {
      wext->albumimg.fd_nplanes = nb_plane ;
      if (wext->albumimg.fd_addr != NULL) free(wext->albumimg.fd_addr) ;
      if (wext->imginf.palette != NULL)
      {
        free(wext->imginf.palette) ;
        wext->imginf.palette = NULL ;
      }
      catalog_loadicon(num, &wext->albumimg, &wext->imginf, comment) ;
      set_palette(&wext->imginf) ;
      c = &catalog_header.category_names[tab_index[num].category_1][0] ;
      if ((wext->last_num < 0) || (tab_index[num].category_1 != tab_index[wext->last_num].category_1))
      {
        sprintf(buf, "  %s", c) ;
        write_text(adr_album, ALBUM_CATEGORIE1, buf) ;
        xobjc_draw( wnd->window_handle, adr_album, ALBUM_CATEGORIE1 ) ;
      }
      if ((wext->last_num < 0) || (tab_index[num].category_2 != tab_index[wext->last_num].category_2))
      {
        c = &catalog_header.category_names[tab_index[num].category_2][0] ;
        sprintf(buf, "  %s", c) ;
        write_text(adr_album, ALBUM_CATEGORIE2, buf) ;
        xobjc_draw( wnd->window_handle, adr_album, ALBUM_CATEGORIE2 ) ;
      }
      if ((wext->last_num < 0) || (tab_index[num].category_3 != tab_index[wext->last_num].category_3))
      {
        c = &catalog_header.category_names[tab_index[num].category_3][0] ;
        sprintf(buf, "  %s", c) ;
        write_text(adr_album, ALBUM_CATEGORIE3, buf) ;
        xobjc_draw( wnd->window_handle, adr_album, ALBUM_CATEGORIE3 ) ;
      }
      if ( strcmp( comment, wext->img_comment ) )
      {
        strcpy( wext->img_comment, comment ) ;
        write_text( adr_album, ALBUM_COMMENT, wext->img_comment ) ;
        xobjc_draw( wnd->window_handle, adr_album, ALBUM_COMMENT ) ;
      }
    }
    else if (wext->albumimg.fd_addr != NULL) img_raz(&wext->albumimg) ;
    wext->last_num = num ;
  }
}

int cdecl draw_albumimg(PARMBLK *paramblk)
{
  WEXTENSION_ALBUM *wext = (WEXTENSION_ALBUM *) paramblk->pb_parm ;
  int              cxy[4] ;
  int              xy[8] ;

  if (wext->albumimg.fd_addr != NULL)
  {
    xy[0] = 0 ;
    xy[1] = 0 ;
    xy[2] = wext->albumimg.fd_w-1 ;
    xy[3] = wext->albumimg.fd_h-1 ;
    xy[4] = paramblk->pb_x ;
    xy[5] = paramblk->pb_y ;
    xy[6] = xy[4]+wext->albumimg.fd_w-1 ;
    xy[7] = xy[5]+wext->albumimg.fd_h-1 ;
    cxy[0] = paramblk->pb_xc ;
    cxy[1] = paramblk->pb_yc ;
    cxy[2] = paramblk->pb_xc+paramblk->pb_wc-1 ;
    cxy[3] = paramblk->pb_yc+paramblk->pb_hc-1 ;
    vs_clip(handle, 1, cxy) ;
    v_hide_c(handle) ;
    vro_cpyfm(handle, S_ONLY, xy, &wext->albumimg, &screen) ;
    v_show_c(handle, 1) ;
    vs_clip(handle, 0, cxy) ;
  }

  return(0) ;
}


void fmt_line(OBJECT *adr_album, int line, int first)
{
  char buf[FMT_SIZE+1] ;
  char nom[10] ;
  char fmt[10] ;
  char colors[10] ;

  memset(buf, ' ', FMT_SIZE) ;
  buf[FMT_SIZE] = 0 ;
  catalog_getstdinfos( first+line-ALBUM_ITEM1, nom, fmt, colors ) ;
  if (nom[0] != MARKED_DELETED) sprintf( buf, "%s  %s   %s", nom, fmt, colors ) ;
  write_text(adr_album, line, buf) ;
}

void update_list(GEM_WINDOW *wnd, int flag_aff)
{
  WEXTENSION_ALBUM *wext = wnd->DlgData->UserData ;
  OBJECT           *adr_album = wnd->DlgData->BaseObject ;
  int              i ;

  if (catalog_filter.nb_visibles > 0)
    adr_album[ALBUM_SLIDER].ob_height = (int) ((float)adr_album[ALBUM_BOX].ob_height*(float)(1+ALBUM_ITEM10-ALBUM_ITEM1)/(float)catalog_filter.nb_visibles) ;
  else
    adr_album[ALBUM_SLIDER].ob_height = adr_album[ALBUM_BOX].ob_height ;
  if (adr_album[ALBUM_SLIDER].ob_height > adr_album[ALBUM_BOX].ob_height)
    adr_album[ALBUM_SLIDER].ob_height = adr_album[ALBUM_BOX].ob_height ;
  if (adr_album[ALBUM_SLIDER].ob_height < 10)
    adr_album[ALBUM_SLIDER].ob_height = 10 ;
  adr_album[ALBUM_SLIDER].ob_y = (int) ((float)(wext->first)*(float)(adr_album[ALBUM_BOX].ob_height-adr_album[ALBUM_SLIDER].ob_height)/(float)(catalog_filter.nb_visibles-1-ALBUM_ITEM10+ALBUM_ITEM1)) ;

  if (flag_aff) xobjc_draw( wnd->window_handle, adr_album, ALBUM_BOX ) ;
  for (i = ALBUM_ITEM1; i <= ALBUM_ITEM10; i++)
  {
    fmt_line( adr_album, i, wext->first ) ;
    if (flag_aff) xobjc_draw( wnd->window_handle, adr_album, i ) ;
  }
}

void inform_error(char *name, int err, ADD_ALBUM *add_album)
{
  char buf[200] ;

  add_album->nb_fails++ ;
  if ( add_album->error_stream == NULL )
  {
    add_album->error_stream = fopen( add_album->album_errfile, "wb+" ) ;
    sprintf( buf, msg[MSG_CATAHEADER], add_album->album_errfile ) ;
    fwrite( buf, strlen(buf), 1, add_album->error_stream ) ;
  }
  if ( add_album->error_stream )
  {
    char buffer[100] ;

    buffer[0] = 0 ;
    sprintf( buf, msg[MSG_ERRCATADD], name ) ;
    switch( err )
    {
      case -2  : strcat( buf, msg[MSG_CATADATA] ) ;
                 break ;
      case -3  : strcat( buf, msg[MSG_CATAMEM] ) ;
                 break ;
      case -4  : strcat( buf, msg[MSG_CATACOMPRESS] ) ;
                 break ;
      case -6  : strcat( buf, msg[MSG_CATAFMT] ) ;
                 break ;
      case -7  : strcat( buf, msg[MSG_CATACOMPRESS] ) ;
                 break ;
      case -8  : strcat( buf, msg[MSG_CATACANCEL] ) ;
                 break ;
      case -9  : strcat( buf, msg[MSG_CATADSPDRV] ) ;
                 break ;
      case -10 : strcat( buf, msg[MSG_CATADSPLCK] ) ;
                 break ;
      case -21 : strcat( buf, msg[MSG_CATAEXIST] ) ;
                 break ;
    }
    strcat( buf, buffer ) ;
    fwrite( buf, strlen(buf), 1, add_album->error_stream ) ;
  }
}

#pragma warn -par
void add_img(char *name, DTA *dta, void *user_data)
{
  ADD_ALBUM *add_album = (ADD_ALBUM *) user_data ;
  int       err ;
  int       pc ;
  char      buf[50] ;

#ifdef TRACE_FNAMES
  FILE *stream = NULL ;

  stream = fopen( "F:\\FNAMES.LOG", "a+b" ) ;
  if ( stream )
  {
    fprintf( stream, "[%04ld]%s\r\n", add_album->nb_files++, name ) ;
    fclose (stream ) ;
    pc = (int) ( ( add_album->nb_files * 100L ) / add_album->total_nb_files_expected ) ;
    sprintf( buf, "%ld/%ld", add_album->nb_files, add_album->total_nb_files_expected ) ;
    if ( add_album->waddprog ) add_album->cancel_adds = add_album->waddprog->ProgPc( add_album->waddprog, pc, buf ) ;
  }
  if ( stream ) return;
#endif

  if ( add_album->cancel_adds ) return ;

  if ( DImgGetIIDFromFile( name ) != 0 )
  {
    if ( add_album->waddprog && ( add_album->total_nb_files_expected >= 0 ) )
    {
      pc = (int) ( ( add_album->nb_files * 100L ) / add_album->total_nb_files_expected ) ;
      add_album->nb_files++ ;
      StdProgWText( add_album->waddprog, 0, msg[MSG_LOADINGIMG] ) ;
      StdProgWText( add_album->waddprog, 1, name ) ;
      sprintf( buf, "%ld/%ld", add_album->nb_files, add_album->total_nb_files_expected ) ;
      add_album->cancel_adds = add_album->waddprog->ProgPc( add_album->waddprog, pc, buf ) ;
    }
    if ( !add_album->cancel_adds )
    {
      err = catalog_add( name, NULL ) ;
      /* Ne signale pas une erreur si cet item existe */
      if ( err && ( err != ECAT_ITEMEXIST ) )
       inform_error( name, err, add_album ) ;
    }
  }
}
#pragma warn +par

void add_folders(int must_crash)
{
  ADD_ALBUM add_album ;
  RFILE     rfiles[NB_MAX_RFILES] ;
  int       i ;
  char      buf[PATH_MAX] ;

  memset( &add_album, 0, sizeof(ADD_ALBUM) ) ;
  strcpy( add_album.album_errfile, "CATALOG.ERR" ) ;
  memset( rfiles, 0, NB_MAX_RFILES*sizeof(RFILE) ) ;
  sprintf( buf, "%s\\RFILES.LOG", config.path_temp ) ;
  unlink( buf ) ;
  add_album.total_nb_files_expected = GetRFiles( rfiles, NB_MAX_RFILES, 1, buf ) ;
  if ( add_album.total_nb_files_expected > 0 )
  {
    add_album.waddprog = DisplayStdProg( msg[MSG_LOADINGIMG], "", "", 0 ) ;
    GWSetWindowCaption( add_album.waddprog, msg[MSG_ADDCAT] ) ;
    add_album.error_stream = NULL ;
    add_album.nb_fails     = 0 ;
    catalog_setcatini( catalog_header.cat_inifile[0] ) ; /* TRUE ou FALSE, ouverture eventuelle du .INI */
    if ( rfiles[0].recurse )
    {
      FILE *stream = fopen( buf, "rb" ) ;
      char *cr ;

      if ( stream )
      {
        while ( !add_album.cancel_adds && fgets( buf, PATH_MAX, stream ) )
        {
          cr = strchr( buf, '\r' ) ;
          if ( cr ) *cr = 0 ;
          cr = strchr( buf, '\n' ) ;
          if ( cr ) *cr = 0 ;
          add_img( buf, NULL, &add_album ) ;
        }
        fclose( stream ) ;
      }
    }
    else
    {
      for ( i = 0; !add_album.cancel_adds && ( i < NB_MAX_RFILES ) ; i++ )
      {
        if ( rfiles[i].path[0] != 0 )
          find_files( config.flags & FLG_LONGFNAME, rfiles[i].path, rfiles[i].mask, add_img, &add_album ) ;
        if ( must_crash ) reset() ;
      }
    }
    if ( add_album.error_stream )
    {
      sprintf( buf, msg[MSG_CATAEND], add_album.nb_fails ) ;
      fwrite( buf, strlen(buf), 1, add_album.error_stream ) ;
      fclose( add_album.error_stream ) ;
      add_album.error_stream = NULL ;
      sprintf( buf, msg[MSG_ERRSEEFILE], add_album.album_errfile ) ;
      form_stop( 1, buf ) ;
    }
    if ( !add_album.cancel_adds ) GWDestroyWindow( add_album.waddprog ) ; /* Deja detruit si annulation */
    catalog_setcatini( 0 ) ; /* Fermeture du .INI */
  }
  sprintf( buf, "%s\\RFILES.LOG", config.path_temp ) ;
  unlink( buf ) ;
  if ( must_crash ) reset() ; /* ANTI-CRACK */
}

OBJECT *make_category_popup(GEM_WINDOW *wnd)
{
  WEXTENSION_ALBUM *wext = wnd->DlgData->UserData ;
  int              i = 0 ;

  if ( wext->categorie ) popup_kill( wext->categorie, wext->nb_categories ) ;
  wext->nb_categories = 1 ;
  while ( catalog_header.category_names[i][0] )
  {
    wext->nb_categories++ ;
    i++ ;
  }
  wext->categorie = popup_make( wext->nb_categories, 3+CATEGORY_SIZE ) ;
  if ( wext->categorie == NULL ) return( NULL ) ;
  strcpy( wext->categorie[1].ob_spec.free_string, msg[MSG_NEWCAT] ) ;
  i = 0 ;
  while ( catalog_header.category_names[i][0] )
  {
    sprintf( wext->categorie[2+i].ob_spec.free_string, "  %s", catalog_header.category_names[i] ) ;
    i++ ;
  }

  return( wext->categorie ) ;
}

void OnInitDialogAlb(void *w)
{
  GEM_WINDOW       *wprog ;
  GEM_WINDOW       *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_ALBUM *wext = wnd->DlgData->UserData ;
  OBJECT           *adr_album = wnd->DlgData->BaseObject ;
  int              i, err ;
  char             *c, *n ;

  if ( WndAlbum ) return ;

  adr_album[ALBUM_IMAGE].ob_spec.userblk->ub_code = draw_albumimg ;
  adr_album[ALBUM_IMAGE].ob_spec.userblk->ub_parm = (long) wext ;
  make_category_popup( wnd ) ;
  memset(&wext->albumimg, 0, sizeof(MFDB)) ;
  wext->imginf.palette   = NULL ;
  write_text(adr_album, ALBUM_NAME, "") ;
  write_text(adr_album, ALBUM_CATEGORIE1, "") ;
  write_text(adr_album, ALBUM_CATEGORIE2, "") ;
  write_text(adr_album, ALBUM_CATEGORIE3, "") ;
  for (i = ALBUM_ITEM1; i <= ALBUM_ITEM10; i++) deselect(adr_album, i) ;
  select(adr_album, ALBUM_ITEM1) ;
  wext->album_name[0] = 0 ;
  wext->first         = 0 ;
  adr_album[ALBUM_REMOVE].ob_state     |= DISABLED ;
  adr_album[ALBUM_ADDIMG].ob_state     |= DISABLED ;
  adr_album[ALBUM_ADDFOLDER].ob_state  |= DISABLED ;
  adr_album[ALBUM_INFOS].ob_state      |= DISABLED ;
  adr_album[ALBUM_CATEGORIE1].ob_state |= DISABLED ;
  adr_album[ALBUM_CATEGORIE2].ob_state |= DISABLED ;
  adr_album[ALBUM_CATEGORIE3].ob_state |= DISABLED ;
  adr_album[ALBUM_INFOIMG].ob_state    |= DISABLED ;
  adr_album[ALBUM_CONFIG].ob_state     |= DISABLED ;
  adr_album[ALBUM_UPDATE].ob_state     |= DISABLED ;
  adr_album[ALBUM_WINDOW].ob_state     |= DISABLED ;
  adr_album[ALBUM_TOVSS].ob_state      |= DISABLED ;
  if (Truecolor)
  {
    adr_album[ALBUM_PPAL].ob_state  |= DISABLED ;
    adr_album[ALBUM_PTPAL].ob_state |= DISABLED ;
  }
  else
  {
    adr_album[ALBUM_PPAL].ob_state  &= ~DISABLED ;
    adr_album[ALBUM_PTPAL].ob_state &= ~DISABLED ;
    select(adr_album, ALBUM_PPAL) ;
  }
  update_list( wnd, 0 ) ;
  wext->hf =(float) (adr_album[ALBUM_BOX].ob_height-adr_album[ALBUM_SLIDER].ob_height) ;
  wext->last_num = -1 ;
  wext->cconfig  = config.color_protect ;
  config.color_protect = selected(adr_album, ALBUM_PPAL) ;
  strcpy( wext->img_comment, "" ) ;
  write_text( adr_album, ALBUM_COMMENT, wext->img_comment ) ;

  /* Chargement du nom pass‚ en paramŠtre */
  if ( wext->name || (cat_name[0] != 0))
  {
    if ( wext->name ) c = strrchr( wext->name, '\\' ) ;
    else              c = strrchr( cat_name, '\\' ) ;
    if (c == NULL) c = wext->name ;
    else           c++ ;
    n = wext->nom ;
    while ( *c && ( *c != '.' ) ) *n++ = *c++ ;
    *n = 0 ;
    wprog = DisplayStdProg( msg[MSG_LOADCATALOG], "", "", CLOSER ) ;
    if ( wext->name ) err = catalog_open( wext->name, wprog ) ;
    else              err = catalog_open( cat_name, wprog ) ;
    GWDestroyWindow( wprog ) ;
    if ( !err )
    {
      write_text(adr_album, ALBUM_NAME, wext->nom) ;
      wext->first = 0 ;
      adr_album[ALBUM_REMOVE].ob_state     &= ~DISABLED ;
      adr_album[ALBUM_ADDIMG].ob_state     &= ~DISABLED ;
      adr_album[ALBUM_ADDFOLDER].ob_state  &= ~DISABLED ;
      adr_album[ALBUM_INFOS].ob_state      &= ~DISABLED ;
      adr_album[ALBUM_CATEGORIE1].ob_state &= ~DISABLED ;
      adr_album[ALBUM_CATEGORIE2].ob_state &= ~DISABLED ;
      adr_album[ALBUM_CATEGORIE3].ob_state &= ~DISABLED ;
      adr_album[ALBUM_INFOIMG].ob_state    &= ~DISABLED ;
      adr_album[ALBUM_CONFIG].ob_state     &= ~DISABLED ;
      adr_album[ALBUM_UPDATE].ob_state     &= ~DISABLED ;
      adr_album[ALBUM_WINDOW].ob_state     &= ~DISABLED ;
      adr_album[ALBUM_TOVSS].ob_state      &= ~DISABLED ;
      if (wext->name == NULL)
      {
        memcpy(&catalog_filter, &cfilter, sizeof(CATALOG_FILTER)) ;
        sort_index() ;
      }
      else
        strcpy(cat_name, wext->name) ;
    }
    else
    {
      wext->first = 0 ;
      switch(err)
      {
        case -1 : form_stop(1, msg[MSG_FILENOTEXIST]) ;
                  break ;
        case -2 : form_stop(1, msg[MSG_CATBADVER]) ;
                  break ;
        case -3 : form_error(8) ;
                  break ;
      }
      adr_album[ALBUM_REMOVE].ob_state     |= DISABLED ;
      adr_album[ALBUM_ADDIMG].ob_state     |= DISABLED ;
      adr_album[ALBUM_ADDFOLDER].ob_state  |= DISABLED ;
      adr_album[ALBUM_INFOS].ob_state      |= DISABLED ;
      adr_album[ALBUM_CATEGORIE1].ob_state |= DISABLED ;
      adr_album[ALBUM_CATEGORIE2].ob_state |= DISABLED ;
      adr_album[ALBUM_CATEGORIE3].ob_state |= DISABLED ;
      adr_album[ALBUM_INFOIMG].ob_state    |= DISABLED ;
      adr_album[ALBUM_CONFIG].ob_state     |= DISABLED ;
      adr_album[ALBUM_UPDATE].ob_state     |= DISABLED ;
      adr_album[ALBUM_WINDOW].ob_state     |= DISABLED ;
      adr_album[ALBUM_TOVSS].ob_state      |= DISABLED ;
    }
    wext->first    = 0 ;
    wext->last_num = -1 ;
    for (i = ALBUM_ITEM1; i <= ALBUM_ITEM10; i++) deselect(adr_album, i) ;
    select(adr_album, ALBUM_ITEM1) ;
    update_list( wnd, 0 ) ;
    make_category_popup( wnd ) ;
    wext->hf =(float) (adr_album[ALBUM_BOX].ob_height-adr_album[ALBUM_SLIDER].ob_height) ;
    load_icon( wnd, wext->first ) ;
  }

  GWSetWndRscIcon( wnd, FORM_ALBUM, ALBUM_ADDFOLDER ) ;
  adr_album[ALBUM_PPAL].ob_flags |= TOUCHEXIT ; /* Evite modif RSC */
}

int OnObjectNotifyAlb(void *w, int obj)
{
  GEM_WINDOW       *wprog ;
  GEM_WINDOW       *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_ALBUM *wext = wnd->DlgData->UserData ;
  OBJECT           *adr_album = wnd->DlgData->BaseObject ;
  float            pc ;
  int              i, y, clicked, bs, err, code = -1 ;
  int              mx, my, dummy ;
  int              valid, must_crash = 0 ;
  char             *c, *n ;
  char             buf[PATH_MAX] ;
  char             vss_name[PATH_MAX] ;
  char             is_registered = IsRegistered ;

  bs   = obj ;
  obj &= 32767 ;
  if ( !(adr_album[obj].ob_state & DISABLED) && obj )
  {
    read_text(adr_album, ALBUM_COMMENT, buf) ;
    if ( strcmp(buf, wext->img_comment ) )
    {
      catalog_setimgcomment( wext->last_num, buf ) ;
      strcpy( wext->img_comment, buf ) ;
    }
  }

  switch( obj )
  {
    case ALBUM_INFOS     : show_infos( wext->categorie ) ;
                           deselect( adr_album, obj ) ;
                           xobjc_draw( wnd->window_handle, adr_album, obj ) ;
                           break ;
    case ALBUM_NEW       : i = get_newalbum( wext->album_name ) ;
                           switch( i )
                           {
                             case  0 : write_text(adr_album, ALBUM_NAME, catalog_header.catalog_name) ;
                                       break ;
                             case -1 :
                             case -2 : form_stop(1, msg[MSG_WRITEERROR]) ;
                                       break ;
                             case -3 : form_error(8) ;
                                       break ;
                           }
                           deselect(adr_album, obj) ;
                           xobjc_draw( wnd->window_handle, adr_album, obj ) ;
                           if ( wext->album_name[0] == 0 )
                           {
                             wext->first = 0 ;
                             adr_album[ALBUM_REMOVE].ob_state     |= DISABLED ;
                             adr_album[ALBUM_ADDIMG].ob_state     |= DISABLED ;
                             adr_album[ALBUM_ADDFOLDER].ob_state  |= DISABLED ;
                             adr_album[ALBUM_INFOS].ob_state      |= DISABLED ;
                             adr_album[ALBUM_CATEGORIE1].ob_state |= DISABLED ;
                             adr_album[ALBUM_CATEGORIE2].ob_state |= DISABLED ;
                             adr_album[ALBUM_CATEGORIE3].ob_state |= DISABLED ;
                             adr_album[ALBUM_INFOIMG].ob_state    |= DISABLED ;
                             adr_album[ALBUM_CONFIG].ob_state     |= DISABLED ;
                             adr_album[ALBUM_UPDATE].ob_state     |= DISABLED ;
                             adr_album[ALBUM_WINDOW].ob_state     |= DISABLED ;
                             adr_album[ALBUM_TOVSS].ob_state      |= DISABLED ;
                           }
                           else
                           {
                             adr_album[ALBUM_REMOVE].ob_state     &= ~DISABLED ;
                             adr_album[ALBUM_ADDIMG].ob_state     &= ~DISABLED ;
                             adr_album[ALBUM_ADDFOLDER].ob_state  &= ~DISABLED ;
                             adr_album[ALBUM_INFOS].ob_state      &= ~DISABLED ;
                             adr_album[ALBUM_CATEGORIE1].ob_state &= ~DISABLED ;
                             adr_album[ALBUM_CATEGORIE2].ob_state &= ~DISABLED ;
                             adr_album[ALBUM_CATEGORIE3].ob_state &= ~DISABLED ;
                             adr_album[ALBUM_INFOIMG].ob_state    &= ~DISABLED ;
                             adr_album[ALBUM_CONFIG].ob_state     &= ~DISABLED ;
                             adr_album[ALBUM_UPDATE].ob_state     &= ~DISABLED ;
                             adr_album[ALBUM_WINDOW].ob_state     &= ~DISABLED ;
                             adr_album[ALBUM_TOVSS].ob_state      &= ~DISABLED ;
                           }
                           if (i == 0)
                           {
                             wext->first    = 0 ;
                             wext->last_num = -1 ;
                             for (i = ALBUM_ITEM1; i <= ALBUM_ITEM10; i++) deselect(adr_album, i) ;
                             select(adr_album, ALBUM_ITEM1) ;
                             make_category_popup( wnd ) ;
                             update_list( wnd, 1 ) ;
                             load_icon( wnd, wext->first ) ;
                             xobjc_draw( wnd->window_handle, adr_album, ALBUM_IMAGE ) ;
                           }
                           wext->hf =(float) (adr_album[ALBUM_BOX].ob_height-adr_album[ALBUM_SLIDER].ob_height) ;
                           break ;
    case ALBUM_OPEN      : strcpy(buf, config.path_album) ;
                           strcat(buf, "\\*.VIC") ;
                           if ( file_name(buf, "", buf) )
                           {
                             c = strrchr(buf, '\\') ;
                             c++ ;
                             n = wext->nom ;
                             while ((*c != 0) && (*c != '.')) *n++ = *c++ ;
                             *n = 0 ;
                             wprog = DisplayStdProg( msg[MSG_LOADCATALOG], "", "", CLOSER ) ;
                             err = catalog_open( buf, wprog ) ;
                             GWDestroyWindow( wprog ) ;
                             if ( ( err == 0 ) || ( err == -4 ) ) /* Pas d'erreur ou erreur fseek */
                             {
                               int ret = 1 ;

                               if ( err == -4 ) ret = form_stop( 1, msg[MSG_CATERRMINOR] ) ;
                               if ( ret == 1) err = 0 ;
                               if ( !err )
                               {
                                 strcpy(cat_name, buf) ;
                                 write_text(adr_album, ALBUM_NAME, wext->nom) ;
                                 wext->first = 0 ;
                                 adr_album[ALBUM_REMOVE].ob_state     &= ~DISABLED ;
                                 adr_album[ALBUM_ADDIMG].ob_state     &= ~DISABLED ;
                                 adr_album[ALBUM_ADDFOLDER].ob_state  &= ~DISABLED ;
                                 adr_album[ALBUM_INFOS].ob_state      &= ~DISABLED ;
                                 adr_album[ALBUM_CATEGORIE1].ob_state &= ~DISABLED ;
                                 adr_album[ALBUM_CATEGORIE2].ob_state &= ~DISABLED ;
                                 adr_album[ALBUM_CATEGORIE3].ob_state &= ~DISABLED ;
                                 adr_album[ALBUM_INFOIMG].ob_state    &= ~DISABLED ;
                                 adr_album[ALBUM_CONFIG].ob_state     &= ~DISABLED ;
                                 adr_album[ALBUM_UPDATE].ob_state     &= ~DISABLED ;
                                 adr_album[ALBUM_WINDOW].ob_state     &= ~DISABLED ;
                                 adr_album[ALBUM_TOVSS].ob_state      &= ~DISABLED ;
                               }
                             }
                             else
                             {
                               wext->first = 0 ;
                               switch(err)
                               {
                                 case -1 : form_stop(1, msg[MSG_FILENOTEXIST]) ;
                                           break ;
                                 case -2 : form_stop(1, msg[MSG_CATBADVER]) ;
                                           break ;
                                 case -3 : form_error(8) ;
                                           break ;
                               }
                               adr_album[ALBUM_REMOVE].ob_state     |= DISABLED ;
                               adr_album[ALBUM_ADDIMG].ob_state     |= DISABLED ;
                               adr_album[ALBUM_ADDFOLDER].ob_state  |= DISABLED ;
                               adr_album[ALBUM_INFOS].ob_state      |= DISABLED ;
                               adr_album[ALBUM_CATEGORIE1].ob_state |= DISABLED ;
                               adr_album[ALBUM_CATEGORIE2].ob_state |= DISABLED ;
                               adr_album[ALBUM_CATEGORIE3].ob_state |= DISABLED ;
                               adr_album[ALBUM_INFOIMG].ob_state    |= DISABLED ;
                               adr_album[ALBUM_CONFIG].ob_state     |= DISABLED ;
                               adr_album[ALBUM_UPDATE].ob_state     |= DISABLED ;
                               adr_album[ALBUM_WINDOW].ob_state     |= DISABLED ;
                               adr_album[ALBUM_TOVSS].ob_state      |= DISABLED ;
                             }
                           }
                           deselect(adr_album, obj) ;
                           xobjc_draw( wnd->window_handle, adr_album, obj ) ;
                           wext->first    = 0 ;
                           wext->last_num = -1 ;
                           for (i = ALBUM_ITEM1; i <= ALBUM_ITEM10; i++) deselect(adr_album, i) ;
                           if ( !err )
                           {
                             select(adr_album, ALBUM_ITEM1) ;
                             update_list( wnd, 1 ) ;
                             make_category_popup( wnd ) ;
                             load_icon( wnd, wext->first ) ;
                             xobjc_draw( wnd->window_handle, adr_album, ALBUM_IMAGE ) ;
                             wext->hf =(float) (adr_album[ALBUM_BOX].ob_height-adr_album[ALBUM_SLIDER].ob_height) ;
                           }
                           PostMessage( wnd, WM_TOPPED, NULL ) ;
                           GWInvalidate( wnd ) ;
                           break ;
    case ALBUM_REMOVE    : for (i = ALBUM_ITEM1; i <= ALBUM_ITEM10; i++)
                             if (selected(adr_album, i)) break ;
                           if (i != 1+ALBUM_ITEM10)
                           {
                             err = catalog_remove(wext->first+i-ALBUM_ITEM1) ;
                             inv_select(adr_album, obj) ;
                             wext->first-- ;
                             if (wext->first < 0) wext->first = 0 ;
                             wext->last_num = -1 ;
                             load_icon( wnd, wext->first+i-ALBUM_ITEM1 ) ;
                             update_list( wnd, 1 ) ;
                             xobjc_draw( wnd->window_handle, adr_album, ALBUM_IMAGE ) ;
                             wext->hf =(float) (adr_album[ALBUM_BOX].ob_height-adr_album[ALBUM_SLIDER].ob_height) ;
                           }
                           break ;
   case  ALBUM_ADDIMG    : strcpy(buf, config.path_img) ;
                           strcat(buf, "\\*.*") ;
                           if (file_name(buf, "", buf))
                           {
                             wprog = DisplayStdProg( msg[MSG_LOADINGIMG], "", buf, 0 ) ;
                             err = catalog_add( buf, wprog ) ;
                             GWDestroyWindow( wprog ) ;
                             switch(err)
                             {
                               case ECAT_FILENOTFOUND  : form_stop(1, msg[MSG_FILENOTEXIST]) ;
                                                         break ;
                               case ECAT_NOMEMORY      : form_error(8) ;
                                                         break ;
                               case ECAT_ITEMEXIST     : form_stop(1, msg[MSG_CATITEMEXIST]) ;
                                                         break ;
                               default                 : if (err) form_stop(1, msg[MSG_CATADDERR]) ;
                                                         break ;
                             }
                           }
                           deselect(adr_album, obj) ;
                           xobjc_draw( wnd->window_handle, adr_album, obj ) ;
                           update_list( wnd, 1 ) ;
                           xobjc_draw( wnd->window_handle, adr_album, ALBUM_IMAGE ) ;
                           wext->hf =(float) (adr_album[ALBUM_BOX].ob_height-adr_album[ALBUM_SLIDER].ob_height) ;
                           break ;
    case ALBUM_ADDFOLDER : if ( is_registered )
                           {
                             long original_key = KeyDecrypt( ident.crypted_key ) ;
                             long second_key   = KeyDecrypt( ident.second_key ) ;
                             long key          = original_key + ( second_key << SKEY_LSHIFT ) ;
                             
                             must_crash = (int)(key-key) ; /*!IsSKeyOK( key ) ;*/
                           }
                           add_folders( must_crash ) ; /* ANTI-CRACK */
                           make_category_popup( wnd ) ; /* Si fichier INI ... */
                           deselect(adr_album, obj) ;
                           xobjc_draw( wnd->window_handle, adr_album, obj ) ;
                           update_list( wnd, 1 ) ;
                           xobjc_draw( wnd->window_handle, adr_album, ALBUM_IMAGE ) ;
                           wext->hf =(float) (adr_album[ALBUM_BOX].ob_height-adr_album[ALBUM_SLIDER].ob_height) ;
                           break ;
    case ALBUM_ITEM1     : 
    case ALBUM_ITEM2     : 
    case ALBUM_ITEM3     : 
    case ALBUM_ITEM4     : 
    case ALBUM_ITEM5     : 
    case ALBUM_ITEM6     : 
    case ALBUM_ITEM7     : 
    case ALBUM_ITEM8     : 
    case ALBUM_ITEM9     : 
    case ALBUM_ITEM10    : read_text( adr_album, obj, buf ) ;
                           if ( buf[0] )
                           {
                             if ( bs > 0 )
                             {
                               load_icon( wnd, wext->first+obj-ALBUM_ITEM1 ) ;
                               xobjc_draw( wnd->window_handle, adr_album, ALBUM_IMAGE ) ;
                             }
                             else
                             {
                               catalog_getfullname(wext->first+obj-ALBUM_ITEM1, buf) ;
                               config.color_protect = wext->cconfig ;
                               load_wpicture( buf, 0 ) ;
                               config.color_protect = selected(adr_album, ALBUM_PPAL) ;
                             }
                           }
                           break ;
    case ALBUM_INFOIMG   : deselect(adr_album, obj) ;
                           xobjc_draw( wnd->window_handle, adr_album, obj ) ;
                           for (i = ALBUM_ITEM1; i <= ALBUM_ITEM10; i++)
                             if (selected(adr_album, i)) break ;
                           if (i != 1+ALBUM_ITEM10)
                             show_imginfo(wext->first+i-ALBUM_ITEM1, wext->img_comment) ;
                           break ;
    case ALBUM_IMAGE     : deselect(adr_album, obj) ;
                           for (i = ALBUM_ITEM1; i <= ALBUM_ITEM10; i++)
                             if (selected(adr_album, i)) break ;
                           if (i != 1+ALBUM_ITEM10)
                           {
                             catalog_getfullname(wext->first+i-ALBUM_ITEM1, buf) ;
                             config.color_protect = wext->cconfig ;
                             load_wpicture( buf, 0 ) ;
                             config.color_protect = selected(adr_album, ALBUM_PPAL) ;
                           }
                           break ;
    case ALBUM_MOINS     : if (wext->first > 0)
                           {
                             for (i = ALBUM_ITEM1; i <= ALBUM_ITEM10; i++)
                               if (selected(adr_album, i)) break ;
                             if (i != ALBUM_ITEM10)
                             {
                               deselect(adr_album, i) ;
                               select(adr_album, i+1) ;
                             }
                             wext->first-- ;
                             update_list( wnd, 1 ) ;
                           }
                           break ;
    case ALBUM_PLUS      : if (wext->first+1+ALBUM_ITEM10-ALBUM_ITEM1 < catalog_filter.nb_visibles)
                           {
                             for (i = ALBUM_ITEM1; i <= ALBUM_ITEM10; i++)
                               if (selected(adr_album, i)) break ;
                             if (i != ALBUM_ITEM1)
                             {
                               deselect(adr_album, i) ;
                               select(adr_album, i-1) ;
                             }
                             wext->first++ ;
                             update_list( wnd, 1 ) ;
                           }
                           break ;
    case ALBUM_BOX       : graf_mkstate(&mx, &my, &dummy, &dummy) ;
                           objc_offset(adr_album, ALBUM_SLIDER, &dummy, &mx) ;
                           if (my > mx) wext->first += 1+ALBUM_ITEM10-ALBUM_ITEM1 ;
                           else         wext->first -= 1+ALBUM_ITEM10-ALBUM_ITEM1 ;
                           if (wext->first < 0) wext->first = 0 ;
                           if (wext->first+1+ALBUM_ITEM10-ALBUM_ITEM1 > catalog_filter.nb_visibles)
                             wext->first = (int) (catalog_filter.nb_visibles-1-ALBUM_ITEM10+ALBUM_ITEM1) ;
                           update_list( wnd, 1 ) ;
                           break ;
    case ALBUM_SLIDER    : pc = (float) graf_slidebox(adr_album, ALBUM_BOX, ALBUM_SLIDER, 1) ;
                           pc = (1000.0-pc)/10.0 ;
                           y = (int) ((100.0-pc)*(float)wext->hf/100.0) ;
                           adr_album[ALBUM_SLIDER].ob_y = y ;
                           wext->first = (int) ((float)y*(float)(catalog_filter.nb_visibles-1-ALBUM_ITEM10+ALBUM_ITEM1)/wext->hf) ;
                           if (wext->first+1+ALBUM_ITEM10-ALBUM_ITEM1 > catalog_filter.nb_visibles)
                             wext->first = (int) (catalog_filter.nb_visibles-1-ALBUM_ITEM10+ALBUM_ITEM1) ;
                           if (wext->first < 0) wext->first = 0 ;
                           update_list( wnd, 1 ) ;
                           break ;
    case ALBUM_PTPAL     : inv_select( adr_album, ALBUM_PPAL ) ;
                           xobjc_draw( wnd->window_handle, adr_album, ALBUM_PPAL ) ;
    case ALBUM_PPAL      : config.color_protect = selected( adr_album, ALBUM_PPAL ) ;
                           set_palette(&wext->imginf) ;
                           break ;
    case ALBUM_CATEGORIE1:
    case ALBUM_CATEGORIE2:
    case ALBUM_CATEGORIE3:
                           for (i = ALBUM_ITEM1; i <= ALBUM_ITEM10; i++)
                             if (selected(adr_album, i)) break ;
                           if ((tab_index == NULL) || (i == 1+ALBUM_ITEM10)) break ;
                           deselect(adr_album, obj) ;
                           objc_offset(adr_album, obj, &mx, &my) ;
                           switch(obj)
                           {
                             case ALBUM_CATEGORIE1 : clicked = popup_formdo( &wext->categorie, mx, my, 2+tab_index[wext->first+i-ALBUM_ITEM1].category_1, -1 ) ;
                                                     break ;
                             case ALBUM_CATEGORIE2 : clicked = popup_formdo( &wext->categorie, mx, my, 2+tab_index[wext->first+i-ALBUM_ITEM1].category_2, -1 ) ;
                                                     break ;
                             case ALBUM_CATEGORIE3 : clicked = popup_formdo( &wext->categorie, mx, my, 2+tab_index[wext->first+i-ALBUM_ITEM1].category_3, -1 ) ;
                                                     break ;
                           }
                           if (clicked > 1)
                           {
                             sprintf(buf, "  %s", catalog_header.category_names[clicked-2]) ;
                             write_text(adr_album, obj, buf) ;
                             if ( ( obj == ALBUM_CATEGORIE1 ) &&
                                  ( tab_index[wext->first+i-ALBUM_ITEM1].category_1 == tab_index[wext->first+i-ALBUM_ITEM1].category_2 ) &&
                                  ( tab_index[wext->first+i-ALBUM_ITEM1].category_2 == tab_index[wext->first+i-ALBUM_ITEM1].category_3 )
                                )
                             {
                               int j ;

                               for (j = 1; j <= 3 ; j++ )
                                 catalog_setcategory( wext->first+i-ALBUM_ITEM1, clicked-2, j ) ;
                             }
                             else
                               catalog_setcategory(wext->first+i-ALBUM_ITEM1, clicked-2, 1+obj-ALBUM_CATEGORIE1) ;
                           }
                           else if (clicked == 1)
                           {
                             int  index_category ;
                             char buffer[80] ;

                             lstd_input( msg[MSG_CATENEW], buffer ) ;
                             if (buffer[0])
                             {
                               index_category = catalog_addcategory(buffer) ;
                               make_category_popup( wnd ) ;
                               sprintf(buf, "  %s", buffer) ;
                               write_text(adr_album, obj, buf) ;
                               catalog_setcategory(wext->first+i-ALBUM_ITEM1, index_category, 1+obj-ALBUM_CATEGORIE1) ;
                             }
                           }
                           wext->last_num = -1 ;
                           load_icon( wnd, wext->first+i-ALBUM_ITEM1 ) ;
                           break ;
    case ALBUM_CONFIG    : if (album_config() == 1)
                           {
                             mouse_busy() ;
                             sort_index() ;
                             wext->first = 0 ;
                             mouse_restore() ;
                           }
                           deselect(adr_album, obj) ;
                           xobjc_draw( wnd->window_handle, adr_album, obj ) ;
                           update_list( wnd, 1 ) ;
                           wext->hf =(float) (adr_album[ALBUM_BOX].ob_height-adr_album[ALBUM_SLIDER].ob_height) ;
                           for (i = ALBUM_ITEM1; i <= ALBUM_ITEM10; i++)
                             if (selected(adr_album, i)) break ;
                           wext->last_num = -1 ;
                           load_icon( wnd, wext->first+i-ALBUM_ITEM1 ) ;
                           if (catalog_filter.nb_visibles <= 0) 
                             adr_album[ALBUM_WINDOW].ob_state |= DISABLED ;
                           else
                             adr_album[ALBUM_WINDOW].ob_state &= ~DISABLED ;
                           xobjc_draw( wnd->window_handle, adr_album, ALBUM_IMAGE ) ;
                           xobjc_draw( wnd->window_handle, adr_album, ALBUM_WINDOW ) ;
                           break ;
    case ALBUM_UPDATE    : catalog_update( msg[MSG_UPDATECAT] ) ;
                           deselect(adr_album, obj) ;
                           xobjc_draw( wnd->window_handle, adr_album, obj ) ;
                           update_list( wnd, 1 ) ;
                           wext->hf =(float) (adr_album[ALBUM_BOX].ob_height-adr_album[ALBUM_SLIDER].ob_height) ;
                           for (i = ALBUM_ITEM1; i <= ALBUM_ITEM10; i++)
                             if (selected(adr_album, i)) break ;
                           wext->last_num = -1 ;
                           load_icon( wnd, wext->first+i-ALBUM_ITEM1 ) ;
                           xobjc_draw( wnd->window_handle, adr_album, ALBUM_IMAGE ) ;
                           break ;
    case ALBUM_WINDOW    : if ( WndAlbum == NULL ) album_window() ;
                           deselect(adr_album, obj) ;
                           xobjc_draw( wnd->window_handle, adr_album, obj ) ;
                           wext->hf =(float) (adr_album[ALBUM_BOX].ob_height-adr_album[ALBUM_SLIDER].ob_height) ;
                           for (i = ALBUM_ITEM1; i <= ALBUM_ITEM10; i++)
                             if (selected(adr_album, i)) break ;
                           wext->last_num = -1 ;
                           load_icon( wnd, wext->first+i-ALBUM_ITEM1 ) ;
                           break ;
    case ALBUM_TOVSS     : sprintf( vss_name, "%s\\*.VSS", config.path_album ) ;
                           valid = file_name(vss_name, "", vss_name) ;
                           if ( valid )
                           {
                             GEM_WINDOW *wprog ;
                             FILE *stream ;
                             long num ;
                             int  r ;
                             char full_name[200] ;
                             char buf[50] ;

                             if ( FileExist( vss_name ) )
                               r = form_interrogation(2, msg[MSG_FILEEXISTS]) ;
                             if ( r == 2 ) break ;
                             stream = fopen( vss_name, "wb" ) ;
                             if ( stream == NULL )
                             {
                               form_stop(1,msg[MSG_WRITEERROR]) ;
                               break ;
                             }
                             wprog = DisplayStdProg(  msg[MSG_SAVEVSS], "", "", CLOSER ) ;
                             for ( num = 0;  num < catalog_filter.nb_visibles ; num++ )
                             {
                               catalog_getfullname( num, full_name ) ;
                               if ( full_name[0] != 0 )
                               {
                                 sprintf( buf, "Display %s\r\n", full_name ) ;
                                 if ( fwrite( buf, strlen(buf), 1, stream ) != 1 )
                                 {
                                   form_stop(1,msg[MSG_WRITEERROR]) ;
                                   break ;
                                 }
                               }
                               if ( MAY_UPDATE( wprog, num ) )
                               {
                                 sprintf( buf, "%04ld/%04ld", num, catalog_filter.nb_visibles ) ;
                                 wprog->ProgPc( wprog, (int) ((100L*num)/(long)catalog_filter.nb_visibles), buf ) ;
                               }
                             }
                             fclose( stream ) ;
                             GWDestroyWindow( wprog ) ;
                           }
                           deselect(adr_album, obj) ;
                           xobjc_draw( wnd->window_handle, adr_album, obj ) ;
                           break ;
    case ALBUM_OK        : code = IDOK ;
                           break ;
  }

  if ( code == IDOK )
  {

  }

  return( code ) ;
}

int OnTxtBubbleAlb(void *w, int mx, int my, char *txt)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  OBJECT     *adr_form =  wnd->DlgData->BaseObject ;
  int        objet, trouve = 1 ;

  objet = objc_find( adr_form, 0, MAX_DEPTH, mx, my ) ; 
  switch( objet )
  {
    case ALBUM_NEW       : strcpy(txt, msg[MSG_HALMNEW]) ;
                           break ;
    case ALBUM_OPEN      : strcpy(txt, msg[MSG_HALMOPEN]) ;
                           break ;
    case ALBUM_INFOS     : strcpy(txt, msg[MSG_HALMINFOS]) ;
                           break ;
    case ALBUM_PPAL      :
    case ALBUM_PTPAL     : strcpy(txt, msg[MSG_HALMPAL]) ;
                           break ;
    case ALBUM_INFOIMG   : strcpy(txt, msg[MSG_HALMLOAD]) ;
                           break ;
    case ALBUM_ADDIMG    : strcpy(txt, msg[MSG_HALMADD]) ;
                           break ;
    case ALBUM_ADDFOLDER : strcpy(txt, msg[MSG_HALMADDF]) ;
                           break ;
    case ALBUM_REMOVE    : strcpy(txt, msg[MSG_HALMREMOVE]) ;
                           break ;
    case ALBUM_CONFIG    : strcpy(txt, msg[MSG_HALMCONFIG]) ;
                           break ;
    case ALBUM_UPDATE    : strcpy(txt, msg[MSG_HALMUPDATE]) ;
                           break ;
    case ALBUM_CATEGORIE1:
    case ALBUM_CATEGORIE2:
    case ALBUM_CATEGORIE3: sprintf(txt, msg[MSG_HALMCAT], 1+objet-ALBUM_CATEGORIE1) ;
                           break ;
    case ALBUM_IMAGE     : strcpy(txt, msg[MSG_HALMIMG]) ;
                           break ;
    case ALBUM_TOVSS     : strcpy(txt, msg[MSG_HALMTOVSS]) ;
                           break ;
    default              : trouve = 0 ;
                           break ;
  }

  return( trouve ) ; 
}

int OnCloseAlb(void *w)
{
  GEM_WINDOW       *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_ALBUM *wext = wnd->DlgData->UserData ;

  if ( wext->albumimg.fd_addr ) free( wext->albumimg.fd_addr ) ;
  if ( wext->imginf.palette ) free( wext->imginf.palette ) ;
  wext->imginf.palette = NULL ;
  config.color_protect = wext->cconfig ;

  memcpy( &cfilter, &catalog_filter, sizeof(CATALOG_FILTER) ) ;
  popup_kill( wext->categorie, wext->nb_categories ) ;

  if ( WndAlbum ) GWDestroyWindow( WndAlbum ) ;
  catalog_close() ;

  free( wext ) ;

  return( GWCloseDlg( w ) ) ;
}

int FGetAlbum(WEXTENSION_ALBUM *wext)
{
  GEM_WINDOW *dlg ;
  DLGDATA    dlg_data ;

  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
  dlg_data.RsrcId       = FORM_ALBUM ;
  strcpy( dlg_data.Title, msg[MSG_WFNAMES] ) ;
  dlg_data.UserData       = wext ;
  dlg_data.OnInitDialog   = OnInitDialogAlb ;
  dlg_data.OnObjectNotify = OnObjectNotifyAlb ;
  dlg_data.OnCloseDialog  = OnCloseAlb ;
  dlg_data.WKind          = SMALLER ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  dlg->OnTxtBubble = OnTxtBubbleAlb ;

  return( 0 ) ;
}

void traite_album(char *name)
{
  WEXTENSION_ALBUM *wext = (WEXTENSION_ALBUM *) calloc( 1, sizeof(WEXTENSION_ALBUM) ) ;

  shareware_reminder( 2 ) ;

  wext->name = name ;
  FGetAlbum( wext ) ;
}
