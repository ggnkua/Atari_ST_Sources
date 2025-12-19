/*********************************/
/* Gestion du catalogue d'images */
/*********************************/
#include  <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>

#include  "..\tools\crc.h"
#include  "..\tools\stdprog.h"
#include    "..\tools\xfile.h"
#include "..\tools\stdinput.h"
#include "..\tools\gwindows.h"
#include    "..\tools\aides.h"
#include  "..\tools\catalog.h"
#include  "..\tools\logging.h"
#include "..\tools\frecurse.h"
#include "..\tools\imgmodul.h"
#include "..\tools\rasterop.h"
#include              "defs.h"

#include   "gstenv.h"
#include   "walbum.h"
#include   "falbum.h"
#include "visionio.h"
#include  "fnewalb.h"
#include  "frfiles.h"
#include "finfoalb.h"
#include  "falbcfg.h"
#include  "falbimg.h"

#define FMT_SIZE 26

typedef struct
{
  float          hf ;
  int            cconfig ;
  char*          name ;
  char           nom[20] ;
  char           album_name[20] ;

  INFO_IMAGE     imginf ;
  OBJECT*        categorie ;
  int            nb_categories ;
  char           img_comment[SIZE_COMMENT] ;

  int            first ;
  int            last_num ;
  HCAT           hCat ;
  CATALOG_FILTER cfilter ;
  char           cat_name[PATH_MAX] ;
  GEM_WINDOW*    WndAlbum ;
}
WEXTENSION_ALBUM ;


typedef struct
{
  GEM_WINDOW* waddprog ;
  FILE*       error_stream ;
  char        album_errfile[14] ;
  long        total_nb_files_expected ;
  long        nb_files ;
  int         cancel_adds ;
  int         nb_fails ;
  HCAT        hCat ;
}
ADD_ALBUM ;

typedef struct _COUNT_FILES_DATA
{
  GEM_WINDOW* wcount_files_prog ;
  clock_t     last_check ;
  clock_t     dclock_min ;
  long        previous_nfiles ;
  int         cancel_counting ;
  int         fake_pc ;
}
COUNT_FILES_DATA, *PCOUNT_FILES_DATA ;


static void set_palette(INFO_IMAGE* inf)
{
  int rgb[3] ;

  if ( Truecolor || (screen.fd_nplanes == 1) || (inf->palette == NULL) ) return ;

  if ( config.color_protect && (nb_colors == 256) )
  {
    set_stospalette(inf->palette, nb_colors-17, 16) ;
    set_tospalette(old_pal, 16) ;
    return ;
  }
  else set_tospalette(inf->palette, nb_colors) ;

  if ( config.color_protect )
  {
    rgb[0] = rgb[1] = rgb[2] = 1000 ;
    svs_color( 0, rgb) ;
    rgb[0] = rgb[1] = rgb[2] = 0 ;
    svs_color( 1, rgb) ;
    rgb[0] = rgb[1] = rgb[2] = 753 ;
    svs_color( 8, rgb) ;
    rgb[0] = rgb[1] = rgb[2] = 502 ;
    svs_color( 9, rgb) ;
  }
}

static void load_icon(GEM_WINDOW* wnd, int num)
{
  WEXTENSION_ALBUM* wext = wnd->DlgData->UserData ;
  OBJECT*           adr_album = wnd->DlgData->BaseObject ;
  INDEX_RECORD*     tab_index = catalog_get_index_record(wext->hCat) ;
  CATALOG_HEADER*   catalog_header = catalog_get_header(wext->hCat) ;
  char*             c ;
  char              buf[200] ;
  char              comment[SIZE_COMMENT] ;

  if ( !catalog_header || !tab_index )
  {
    LoggingDoInvalidhCat();
    return ;
  }

  if ( wext->last_num != num )
  {
    if ((num < catalog_header->nb_records+catalog_header->nb_deleted) && tab_index[num].is_visible)
    {
      wext->imginf.mfdb.fd_nplanes = screen.fd_nplanes ;
      if ( wext->imginf.mfdb.fd_addr ) Xfree(wext->imginf.mfdb.fd_addr) ;
      if ( wext->imginf.palette )
      {
        Xfree(wext->imginf.palette) ;
        wext->imginf.palette = NULL ;
      }
      catalog_loadicon(wext->hCat, num, &wext->imginf, comment) ;
      set_palette(&wext->imginf) ;
      if ( (wext->last_num < 0) || (tab_index[num].category_1 != tab_index[wext->last_num].category_1) )
      {
        c = &catalog_header->category_names[tab_index[num].category_1][0] ;
        sprintf( buf, "  %s", c ) ;
        write_text( adr_album, ALBUM_CATEGORIE1, buf ) ;
        GWObjcDraw( wnd, adr_album, ALBUM_CATEGORIE1 ) ;
      }
      if ( (wext->last_num < 0) || (tab_index[num].category_2 != tab_index[wext->last_num].category_2) )
      {
        c = &catalog_header->category_names[tab_index[num].category_2][0] ;
        sprintf( buf, "  %s", c ) ;
        write_text( adr_album, ALBUM_CATEGORIE2, buf ) ;
        GWObjcDraw( wnd, adr_album, ALBUM_CATEGORIE2 ) ;
      }
      if ( (wext->last_num < 0) || (tab_index[num].category_3 != tab_index[wext->last_num].category_3) )
      {
        c = &catalog_header->category_names[tab_index[num].category_3][0] ;
        sprintf( buf, "  %s", c ) ;
        write_text( adr_album, ALBUM_CATEGORIE3, buf ) ;
        GWObjcDraw( wnd, adr_album, ALBUM_CATEGORIE3 ) ;
      }
      if ( strcmp( comment, wext->img_comment ) )
      {
        strcpy( wext->img_comment, comment ) ;
        write_text( adr_album, ALBUM_COMMENT, wext->img_comment ) ;
        GWObjcDraw( wnd, adr_album, ALBUM_COMMENT ) ;
      }
    }
    else if ( wext->imginf.mfdb.fd_addr ) img_raz( &wext->imginf.mfdb ) ;
    wext->last_num = num ;
  }
  /* Try understand weird Aranym behavior with memory corruption with JIT
  LoggingDo(LL_DEBUG, "load_icon:") ;
  LogMFDB(&wext->imginf.mfdb) ; */
}

static int cdecl draw_albumimg(PARMBLK* paramblk)
{
  WEXTENSION_ALBUM* wext = (WEXTENSION_ALBUM*) paramblk->pb_parm ;
  int               cxy[4] ;
  int               xy[8] ;

 /* Try understand weird Aranym behavior with memory corruption with JIT
  LoggingDo(LL_DEBUG, "draw_albumimg:") ;
  LogMFDB(&wext->imginf.mfdb) ;*/
  if ( wext->imginf.mfdb.fd_addr )
  {
    xy[0]  = 0 ;
    xy[1]  = 0 ;
    xy[2]  = wext->imginf.mfdb.fd_w-1 ;
    xy[3]  = wext->imginf.mfdb.fd_h-1 ;
    xy[4]  = paramblk->pb_x ;
    xy[5]  = paramblk->pb_y ;
    xy[6]  = xy[4]+wext->imginf.mfdb.fd_w-1 ;
    xy[7]  = xy[5]+wext->imginf.mfdb.fd_h-1 ;
    cxy[0] = paramblk->pb_xc ;
    cxy[1] = paramblk->pb_yc ;
    cxy[2] = paramblk->pb_xc+paramblk->pb_wc-1 ;
    cxy[3] = paramblk->pb_yc+paramblk->pb_hc-1 ;
    svs_clipON( cxy ) ;
    GWHideCursor() ;
    svro_cpyfmSOS( xy, &wext->imginf.mfdb ) ;
    GWShowCursor() ;
    svs_clipOFF( cxy ) ;
  }

  return 0 ;
}

static void fmt_line(HCAT hCat, OBJECT *adr_album, int line, int first)
{
  char buf[FMT_SIZE+1] ;
  char nom[10] ;
  char fmt[10] ;
  char colors[10] ;

  memset( buf, ' ', FMT_SIZE ) ;
  buf[FMT_SIZE] = 0 ;
  catalog_getstdinfos( hCat, first+line-ALBUM_ITEM1, nom, fmt, colors ) ;
  if ( nom[0] != MARKED_DELETED ) sprintf( buf, "%s  %s   %s", nom, fmt, colors ) ;
  write_text( adr_album, line, buf ) ;
}

static void update_list(GEM_WINDOW* wnd, int flag_aff)
{
  WEXTENSION_ALBUM* wext = wnd->DlgData->UserData ;
  OBJECT*           adr_album = wnd->DlgData->BaseObject ;
  CATALOG_FILTER*   catalog_filter = catalog_get_filter(wext->hCat) ;
  int               i ;

  if (catalog_filter && (catalog_filter->nb_visibles > 0) )
    adr_album[ALBUM_SLIDER].ob_height = (int) ((float)adr_album[ALBUM_BOX].ob_height*(float)(1+ALBUM_ITEM10-ALBUM_ITEM1)/(float)catalog_filter->nb_visibles) ;
  else
    adr_album[ALBUM_SLIDER].ob_height = adr_album[ALBUM_BOX].ob_height ;
  if (adr_album[ALBUM_SLIDER].ob_height > adr_album[ALBUM_BOX].ob_height)
    adr_album[ALBUM_SLIDER].ob_height = adr_album[ALBUM_BOX].ob_height ;
  if (adr_album[ALBUM_SLIDER].ob_height < 10)
    adr_album[ALBUM_SLIDER].ob_height = 10 ;
  if ( catalog_filter ) adr_album[ALBUM_SLIDER].ob_y = (int) ((float)(wext->first)*(float)(adr_album[ALBUM_BOX].ob_height-adr_album[ALBUM_SLIDER].ob_height)/(float)(catalog_filter->nb_visibles-1-ALBUM_ITEM10+ALBUM_ITEM1)) ;
  else                  adr_album[ALBUM_SLIDER].ob_y = 0 ;

  if ( flag_aff ) GWObjcDraw( wnd, adr_album, ALBUM_BOX ) ;
  for ( i = ALBUM_ITEM1; i <= ALBUM_ITEM10; i++ )
  {
    fmt_line( wext->hCat, adr_album, i, wext->first ) ;
    if (flag_aff) GWObjcDraw( wnd, adr_album, i ) ;
  }
}

static void alb_refresh(GEM_WINDOW* wnd)
{
  WEXTENSION_ALBUM* wext = wnd->DlgData->UserData ;
  OBJECT*           adr_album = wnd->DlgData->BaseObject ;
  int               i ;

  wext->first = 0 ; /* Let's make it simple */
  update_list( wnd, 1 ) ;
  wext->hf =(float) (adr_album[ALBUM_BOX].ob_height-adr_album[ALBUM_SLIDER].ob_height) ;
  for (i = ALBUM_ITEM1; i <= ALBUM_ITEM10; i++)
    if (selected(adr_album, i)) break ;
  wext->last_num = -1 ;
  load_icon( wnd, wext->first+i-ALBUM_ITEM1 ) ;
  GWObjcDraw( wnd, adr_album, ALBUM_IMAGE ) ;
}

static void inform_error(char *name, int err, ADD_ALBUM *add_album)
{
  char buf[200] ;

  add_album->nb_fails++ ;
  if ( add_album->error_stream == NULL )
  {
    add_album->error_stream = fopen( add_album->album_errfile, "wb+" ) ;
    sprintf( buf, vMsgTxtGetMsg(MSG_CATAHEADER) , add_album->album_errfile ) ;
    fwrite( buf, strlen(buf), 1, add_album->error_stream ) ;
  }
  if ( add_album->error_stream )
  {
    char buffer[100] ;

    buffer[0] = 0 ;
    sprintf( buf, vMsgTxtGetMsg(MSG_ERRCATADD), name ) ;
    switch( err )
    {
      /* PureC generated code size is bigger if we use errs and msgs arrays */
      case -2  : strcat( buf, vMsgTxtGetMsg(MSG_CATADATA) ) ;
                 break ;
      case -3  : strcat( buf, vMsgTxtGetMsg(MSG_CATAMEM) ) ;
                 break ;
      case -4  : strcat( buf, vMsgTxtGetMsg(MSG_CATACOMPRESS) ) ;
                 break ;
      case -6  : strcat( buf, vMsgTxtGetMsg(MSG_CATAFMT) ) ;
                 break ;
      case -7  : strcat( buf, vMsgTxtGetMsg(MSG_CATACOMPRESS) ) ;
                 break ;
      case -8  : strcat( buf, vMsgTxtGetMsg(MSG_CATACANCEL) ) ;
                 break ;
      case -9  : strcat( buf, vMsgTxtGetMsg(MSG_CATADSPDRV) ) ;
                 break ;
      case -10 : strcat( buf, vMsgTxtGetMsg(MSG_CATADSPLCK) ) ;
                 break ;
      case -21 : strcat( buf, vMsgTxtGetMsg(MSG_CATAEXIST) ) ;
                 break ;
    }
    strcat( buf, buffer ) ;
    fwrite( buf, strlen(buf), 1, add_album->error_stream ) ;
  }
}

static short add_img(FR_CDATA* fr_cdata)
{
  ADD_ALBUM *add_album = (ADD_ALBUM*) fr_cdata->user_data ;
  int       err ;
  char      buf[50] ;

  if ( add_album->cancel_adds ) return 1 ;

  add_album->nb_files++ ;
  if ( DImgGetIIDFromFile( fr_cdata->filename ) != 0 )
  {
    if ( add_album->waddprog && ( add_album->total_nb_files_expected >= 0 ) )
    {
      StdProgWText( add_album->waddprog, 0, vMsgTxtGetMsg(MSG_LOADINGIMG)  ) ;
      StdProgWText( add_album->waddprog, 1, fr_cdata->filename ) ;
      sprintf( buf, "%ld/%ld", add_album->nb_files, add_album->total_nb_files_expected ) ;
      add_album->cancel_adds = PROG_CANCEL_CODE( GWProgRange( add_album->waddprog, add_album->nb_files, add_album->total_nb_files_expected, buf ) ) ;
    }
    if ( !add_album->cancel_adds )
    {
      err = catalog_add( add_album->hCat, fr_cdata->filename, NULL ) ;
      switch( err )
      {
        case 0 :              LoggingDo( LL_INFO, "(%ld/%ld):Adding %s to catalog...OK", add_album->nb_files, add_album->total_nb_files_expected, fr_cdata->filename ) ;
                              break ;
        case ECAT_ITEMEXIST : LoggingDo( LL_INFO, "(%ld/%ld):Adding %s to catalog...file already there", add_album->nb_files, add_album->total_nb_files_expected, fr_cdata->filename ) ;
                              break ;
        default:              LoggingDo( LL_WARNING, "(%ld/%ld):Adding %s to catalog returned %d", add_album->nb_files, add_album->total_nb_files_expected, fr_cdata->filename, err ) ;
                              break ;
      }
    }
    else LoggingDo( LL_INFO, "(%ld/%ld):Adding %s has been cancelled by user", add_album->nb_files, add_album->total_nb_files_expected, fr_cdata->filename ) ;
  }
  else LoggingDo( LL_INFO, "(%ld/%ld):Adding %s to catalog...extension not recognized", add_album->nb_files, add_album->total_nb_files_expected, fr_cdata->filename ) ;

  return 0 ;
}

static int count_files_callback(long nfiles_so_far, char* current_filename, void* user_data)
{
  COUNT_FILES_DATA* cfd = (COUNT_FILES_DATA*) user_data ;
  int               stop_counting = 0 ;

  if ( cfd && (nfiles_so_far - cfd->previous_nfiles > 16) )
  {
    clock_t now = clock() ;

    if ( now-cfd->last_check > cfd->dclock_min )
    {
      char buf[200] ;

      if ( cfd->wcount_files_prog == NULL )
      {
        sprintf( buf, vMsgTxtGetMsg(MSG_CFNSOFAR), 0 ) ;
        cfd->wcount_files_prog = DisplayStdProg( buf, "", "", 0 ) ;
        GWSetWindowCaption(cfd->wcount_files_prog, vMsgTxtGetMsg(MSG_COUNTFILES) ) ;
      }

      sprintf( buf, vMsgTxtGetMsg(MSG_CFNSOFAR), nfiles_so_far ) ;
      StdProgWText( cfd->wcount_files_prog, 0, buf ) ;
      StdProgWText( cfd->wcount_files_prog, 1, current_filename ) ;
      cfd->fake_pc += 10 ;
      if ( cfd->fake_pc > 100 ) cfd->fake_pc = 0 ; /* Simulate a circular progress */
      cfd->cancel_counting = PROG_CANCEL_CODE( GWProgRange( cfd->wcount_files_prog, cfd->fake_pc, -100, NULL ) ) ; /* Fake progress as we don't know, just to handle cancel */
      stop_counting        = cfd->cancel_counting ;
      cfd->last_check      = now ;
      cfd->previous_nfiles = nfiles_so_far ;
    }
  }

  return stop_counting ;
}

static void add_folders(WEXTENSION_ALBUM *wext, void* external_call)
{
  ADD_ALBUM        add_album ;
  COUNT_FILES_DATA count_file_data ;
  RFILE            rfiles[NB_MAX_RFILES] ;
  CATALOG_HEADER*  catalog_header = catalog_get_header(wext->hCat) ;
  int              i ;
  char             buf[PATH_MAX] ;

  if ( !catalog_header )
  {
    LoggingDoInvalidhCat();
    return ;
  }

  memzero( &add_album, sizeof(ADD_ALBUM) ) ;
  strcpy( add_album.album_errfile, "CATALOG.ERR" ) ;
  if ( external_call ) memcpy( rfiles, external_call, NB_MAX_RFILES*sizeof(RFILE) ) ;
  else                 memzero( rfiles, NB_MAX_RFILES*sizeof(RFILE) ) ;
  memzero( &count_file_data, sizeof(COUNT_FILES_DATA) ) ;
  count_file_data.dclock_min = 3L*CLK_TCK ; /* No more than 1 update every 3s */
  sprintf( buf, "%s\\RFILES.LOG", config.path_temp ) ;
  unlink( buf ) ;
  add_album.total_nb_files_expected = GetRFilesEx( rfiles, NB_MAX_RFILES, 1, buf, count_files_callback, &count_file_data ) ;
  if ( !count_file_data.cancel_counting ) GWDestroyWindow( count_file_data.wcount_files_prog ) ;
  if ( !count_file_data.cancel_counting && (add_album.total_nb_files_expected > 0) )
  {
    add_album.waddprog = DisplayStdProg( vMsgTxtGetMsg(MSG_LOADINGIMG), "", "", 0 ) ;
    GWSetWindowCaption( add_album.waddprog, vMsgTxtGetMsg(MSG_ADDCAT) ) ;
    add_album.error_stream = NULL ;
    add_album.nb_fails     = 0 ;
    add_album.hCat         = wext->hCat ;
    catalog_setcatini( wext->hCat, catalog_header->cat_inifile[0] ) ; /* TRUE ou FALSE, ouverture eventuelle du .INI */
    if ( rfiles[0].recurse )
    {
      FILE *stream = fopen( buf, "rb" ) ;

      if ( stream )
      {
        while ( !add_album.cancel_adds && fgets( buf, PATH_MAX, stream ) )
        {
          FR_CDATA fr_cdata ;

          removeCRCF( buf ) ;
          memzero( &fr_cdata, sizeof(FR_CDATA) ) ;
          fr_cdata.filename  = buf ;
          fr_cdata.user_data = &add_album ;
          add_img( &fr_cdata ) ;
        }
        fclose( stream ) ;
      }
    }
    else
    {
      for ( i = 0; !add_album.cancel_adds && ( i < NB_MAX_RFILES ) ; i++ )
      {
        if ( rfiles[i].path[0] != 0 )
        {
          FR_DATA fr_data ;

          fr_data.flags      = GetLongFileNamesStatus() ;
          fr_data.path       = rfiles[i].path ;
          fr_data.mask       = rfiles[i].mask ;
          fr_data.log_file   = NULL ;
          fr_data.user_func  = add_img ;
          fr_data.user_data  = &add_album ;
          find_files( &fr_data ) ;
        }
      }
    }
    if ( add_album.error_stream )
    {
      sprintf( buf, vMsgTxtGetMsg(MSG_CATAEND) , add_album.nb_fails ) ;
      fwrite( buf, strlen(buf), 1, add_album.error_stream ) ;
      fclose( add_album.error_stream ) ;
      add_album.error_stream = NULL ;
      sprintf( buf, vMsgTxtGetMsg(MSG_ERRSEEFILE) , add_album.album_errfile ) ;
      if ( !external_call ) form_stop( buf ) ;
    }
    if ( !add_album.cancel_adds ) GWDestroyWindow( add_album.waddprog ) ; /* Deja detruit si annulation */
    catalog_setcatini( wext->hCat, 0 ) ; /* Fermeture du .INI */
  }
  sprintf( buf, "%s\\RFILES.LOG", config.path_temp ) ;
  unlink( buf ) ;
}

OBJECT* make_category_popup(GEM_WINDOW* wnd)
{
  WEXTENSION_ALBUM* wext = wnd->DlgData->UserData ;
  CATALOG_HEADER*   catalog_header = catalog_get_header(wext->hCat) ;
  int               i = 0 ;

  if ( wext->categorie ) popup_kill( wext->categorie, wext->nb_categories ) ;
  wext->nb_categories = 1 ;
  while ( catalog_header && catalog_header->category_names[i][0] )
  {
    wext->nb_categories++ ;
    i++ ;
  }
  wext->categorie = popup_make( wext->nb_categories, 3+CATEGORY_SIZE ) ;
  if ( wext->categorie == NULL ) return NULL ;
  strcpy( wext->categorie[1].ob_spec.free_string, vMsgTxtGetMsg(MSG_NEWCAT)  ) ;
  i = 0 ;
  while ( catalog_header && catalog_header->category_names[i][0] )
  {
    sprintf( wext->categorie[2+i].ob_spec.free_string, "  %s", catalog_header->category_names[i] ) ;
    i++ ;
  }

  return wext->categorie ;
}

static HCAT fcatalog_open(char* cat_name, GEM_WINDOW* wprog, int* err)
{
  HCAT hCat ;

  hCat = catalog_open( cat_name, wprog, err ) ;
  if ( (*err == ECAT_UPGRADEREQUIRED) && (form_interrogation(1, vMsgTxtGetMsg(MSG_ASKUPGCATALOG) ) == 1) )
  {
    LoggingDo(LL_INFO, "Upgrading catalog %s...", cat_name) ;
    StdProgWText( wprog, 0, vMsgTxtGetMsg(MSG_UPGCATALOG) ) ;
    *err = catalog_upgrade( cat_name, wprog ) ;
    LoggingDo((*err == ECAT_NOERR) ? LL_INFO:LL_ERROR, "Catalog upgrade status is %d", *err) ;
    if ( *err == ECAT_NOERR )
    {
      StdProgWText( wprog, 0, vMsgTxtGetMsg(MSG_LOADCATALOG) ) ;
      hCat = catalog_open( cat_name, wprog, err ) ;
    }
    else
    {
      char buf[200] ;

      sprintf( buf, vMsgTxtGetMsg(MSG_ERRUPGCATALOG), *err ) ;
      form_stop( buf ) ;
    }
  }

  return hCat ;
}

static void set_ob_states(OBJECT* adr_album, short enable)
{
  char ids[] = { ALBUM_REMOVE, ALBUM_ADDIMG, ALBUM_ADDFOLDER, ALBUM_INFOS, ALBUM_CATEGORIE1, ALBUM_CATEGORIE2, ALBUM_CATEGORIE3,
                 ALBUM_INFOIMG, ALBUM_CONFIG, ALBUM_UPDATE, ALBUM_WINDOW, ALBUM_TOVSS } ;
  short i ;

  for ( i = 0; i < ARRAY_SIZE(ids); i++ )
  {
    if ( enable ) adr_album[ids[i]].ob_state &= ~DISABLED ;
    else          adr_album[ids[i]].ob_state |= DISABLED ;
  }
}

#define enable_on_states(adr_album)  set_ob_states(adr_album,1)
#define disable_on_states(adr_album) set_ob_states(adr_album,0)

static void OnInitDialogAlb(void* w)
{
  GEM_WINDOW*       wprog ;
  GEM_WINDOW*       wnd = (GEM_WINDOW*) w ;
  WEXTENSION_ALBUM* wext = wnd->DlgData->UserData ;
  OBJECT*           adr_album = wnd->DlgData->BaseObject ;
  int               i, err ;
  char*             c, *n ;

  adr_album[ALBUM_IMAGE].ob_spec.userblk->ub_code = draw_albumimg ;
  adr_album[ALBUM_IMAGE].ob_spec.userblk->ub_parm = (long) wext ;
  make_category_popup( wnd ) ;
  ZeroMFDB(&wext->imginf.mfdb) ;
  wext->imginf.palette   = NULL ;
  write_text(adr_album, ALBUM_NAME, "") ;
  write_text(adr_album, ALBUM_CATEGORIE1, "") ;
  write_text(adr_album, ALBUM_CATEGORIE2, "") ;
  write_text(adr_album, ALBUM_CATEGORIE3, "") ;
  for (i = ALBUM_ITEM1; i <= ALBUM_ITEM10; i++) deselect(adr_album, i) ;
  select(adr_album, ALBUM_ITEM1) ;
  wext->album_name[0] = 0 ;
  wext->first         = 0 ;
  disable_on_states(adr_album) ;
  if ( Truecolor )
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

  /* Name passed as parameter */
  if ( wext->name )
  {
    c = strrchr( wext->name, '\\' ) ;
    if (c == NULL) c = wext->name ;
    else           c++ ;
    n = wext->nom ;
    while ( *c && ( *c != '.' ) ) *n++ = *c++ ;
    *n = 0 ;
    wprog = DisplayStdProg( vMsgTxtGetMsg(MSG_LOADCATALOG) , "", "", CLOSER ) ;
    wext->hCat = fcatalog_open( wext->name, wprog, &err ) ;
    GWDestroyWindow( wprog ) ;
    if ( !err )
    {
      write_text(adr_album, ALBUM_NAME, wext->nom) ;
      wext->first = 0 ;
      enable_on_states(adr_album) ;
    }
    else
    {
      wext->first = 0 ;
      switch(err)
      {
        case -1 : vform_stop( MSG_FILENOTEXIST ) ;
                  break ;
        case -2 : vform_stop( MSG_CATBADVER ) ;
                  break ;
        case -3 : form_error_mem() ;
                  break ;
      }
      disable_on_states(adr_album) ;
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

int ObjectNotifyAlb(void* w, int obj, void* external_call)
{
  GEM_WINDOW*       wprog ;
  GEM_WINDOW*       wnd = (GEM_WINDOW*) w ;
  WEXTENSION_ALBUM* wext = wnd->DlgData->UserData ;
  OBJECT*           adr_album = wnd->DlgData->BaseObject ;
  CATALOG_HEADER*   catalog_header = catalog_get_header(wext->hCat) ;
  CATALOG_FILTER*   catalog_filter = catalog_get_filter(wext->hCat) ;
  INDEX_RECORD*     tab_index = catalog_get_index_record(wext->hCat) ;
  HCAT              new_hCat ;
  float             pc ;
  int               i, y, clicked, bs, err, code = -1 ;
  int               mx, my, dummy ;
  int               do_it, valid ;
  char              *c, *n ;
  char              buf[PATH_MAX] ;
  char              vss_name[PATH_MAX] ;

  bs   = obj ;
  obj &= 32767 ;
  if ( !(adr_album[obj].ob_state & DISABLED) && obj )
  {
    read_text(adr_album, ALBUM_COMMENT, buf) ;
    if ( strcmp(buf, wext->img_comment ) )
    {
      catalog_setimgcomment( wext->hCat, wext->last_num, buf ) ;
      strcpy( wext->img_comment, buf ) ;
    }
  }

  switch( obj )
  {
    case ALBUM_INFOS     : if ( catalog_header )
                           {
                             strcpy( buf, catalog_header->cat_inifile ) ;
                             show_infos( wext->hCat, wext->categorie ) ;
                             deselect( adr_album, obj ) ;
                             GWObjcDraw( wnd, adr_album, obj ) ;
                             if ( catalog_header->cat_inifile[0] && strcmpi( buf, catalog_header->cat_inifile ) )
                               if ( form_interrogation( 2, vMsgTxtGetMsg(MSG_QCATUPTINI) ) == 1 )
                                 catalog_applyini( wext->hCat, vMsgTxtGetMsg(MSG_CATUPTINI) ) ;
                           }
                           else LoggingDoInvalidhCat();
                           break ;
    case ALBUM_NEW       : strcpy( buf, wext->album_name ) ;
                           new_hCat = get_newalbum( wext->album_name, &i ) ;
                           switch( i )
                           {
                             case  0 : if ( wext->hCat ) catalog_close(wext->hCat) ;
                                       if ( wext->WndAlbum ) GWDestroyWindow( wext->WndAlbum ) ;
                                       wext->WndAlbum = NULL ;
                                       wext->hCat     = new_hCat ;
                                       catalog_header = catalog_get_header(wext->hCat) ;
                                       write_text(adr_album, ALBUM_NAME, catalog_header->catalog_name) ;
                                       break ;
                             case -1 :
                             case -2 : vform_stop( MSG_WRITEERROR ) ;
                                       break ;
                             case -3 : form_error_mem() ;
                                       break ;
                             case -4 : strcpy( wext->album_name, buf ) ;
                                       break ;
                           }
                           deselect( adr_album, obj ) ;
                           GWObjcDraw( wnd, adr_album, obj ) ;
                           if ( wext->album_name[0] == 0 )
                           {
                             wext->first = 0 ;
                             disable_on_states(adr_album) ;
                           }
                           else enable_on_states(adr_album) ;
                           if (i == 0)
                           {
                             wext->first    = 0 ;
                             wext->last_num = -1 ;
                             for (i = ALBUM_ITEM1; i <= ALBUM_ITEM10; i++) deselect(adr_album, i) ;
                             select(adr_album, ALBUM_ITEM1) ;
                             make_category_popup( wnd ) ;
                             update_list( wnd, 1 ) ;
                             load_icon( wnd, wext->first ) ;
                           }
                           GWObjcDraw( wnd, adr_album, 0 ) ; /* Redraw full dialog */
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
                             wprog = DisplayStdProg( vMsgTxtGetMsg(MSG_LOADCATALOG) , "", "", CLOSER ) ;
                             new_hCat = fcatalog_open( buf, wprog, &err ) ;
                             GWDestroyWindow( wprog ) ;
                             if ( ( err == 0 ) || ( err == -4 ) ) /* Pas d'erreur ou erreur fseek */
                             {
                               int ret = 1 ;

                               if ( err == -4 ) ret = vform_stop( MSG_CATERRMINOR ) ;
                               if ( ret == 1 ) err = 0 ;
                               if ( !err )
                               {
                                 if ( wext->hCat ) catalog_close(wext->hCat) ;
                                 if ( wext->WndAlbum ) GWDestroyWindow( wext->WndAlbum ) ;
                                 wext->WndAlbum = NULL ;
                                 wext->hCat     = new_hCat ;
                                 write_text(adr_album, ALBUM_NAME, wext->nom) ;
                                 wext->first = 0 ;
                                 enable_on_states(adr_album) ;
                               }
                             }
                             else
                             {
                               wext->first = 0 ;
                               switch(err)
                               {
                                 case -1 : vform_stop( MSG_FILENOTEXIST ) ;
                                           break ;
                                 case -2 : vform_stop( MSG_CATBADVER ) ;
                                           break ;
                                 case -3 : form_error_mem() ;
                                           break ;
                               }
                               disable_on_states(adr_album) ;
                             }
                           }
                           deselect(adr_album, obj) ;
                           GWObjcDraw( wnd, adr_album, obj ) ;
                           wext->first    = 0 ;
                           wext->last_num = -1 ;
                           for (i = ALBUM_ITEM1; i <= ALBUM_ITEM10; i++) deselect(adr_album, i) ;
                           if ( !err )
                           {
                             select(adr_album, ALBUM_ITEM1) ;
                             update_list( wnd, 1 ) ;
                             make_category_popup( wnd ) ;
                             load_icon( wnd, wext->first ) ;
                             GWObjcDraw( wnd, adr_album, ALBUM_IMAGE ) ;
                             wext->hf =(float) (adr_album[ALBUM_BOX].ob_height-adr_album[ALBUM_SLIDER].ob_height) ;
                           }
                           PostMessage( wnd, WM_TOPPED, NULL ) ;
                           GWInvalidate( wnd ) ;
                           break ;
    case ALBUM_REMOVE    : for (i = ALBUM_ITEM1; i <= ALBUM_ITEM10; i++)
                             if (selected(adr_album, i)) break ;
                           if (i != 1+ALBUM_ITEM10)
                           {
                             err = catalog_remove(wext->hCat, wext->first+i-ALBUM_ITEM1) ;
                             inv_select(adr_album, obj) ;
                             wext->first-- ;
                             if (wext->first < 0) wext->first = 0 ;
                             wext->last_num = -1 ;
                             load_icon( wnd, wext->first+i-ALBUM_ITEM1 ) ;
                             update_list( wnd, 1 ) ;
                             GWObjcDraw( wnd, adr_album, ALBUM_IMAGE ) ;
                             wext->hf =(float) (adr_album[ALBUM_BOX].ob_height-adr_album[ALBUM_SLIDER].ob_height) ;
                             if ( wext->WndAlbum ) PostMessage( wext->WndAlbum, MSG_WALB_REFRESH, NULL ) ;
                           }
                           break ;
   case  ALBUM_ADDIMG    : if ( external_call == NULL )
                           {
                             strcpy(buf, config.path_img) ;
                             strcat(buf, "\\*.*") ;
                             do_it = file_name( buf, "", buf ) ;
                           }
                           else
                           {
                             /* Called from outside, parameters provided, don't ask user */
                             memzero( buf, sizeof(buf) ) ;
                             strncpy( buf, external_call, sizeof(buf)-1 ) ;
                             do_it = 1 ;
                           }
                           if ( do_it )
                           {
                             wprog = DisplayStdProg( vMsgTxtGetMsg(MSG_LOADINGIMG) , "", buf, 0 ) ;
                             err = catalog_add( wext->hCat, buf, wprog ) ;
                             GWDestroyWindow( wprog ) ;
                             switch(err)
                             {
                               case ECAT_FILENOTFOUND  : if ( !external_call ) vform_stop( MSG_FILENOTEXIST ) ;
                                                         break ;
                               case ECAT_NOMEMORY      : if ( !external_call ) form_error_mem() ;
                                                         break ;
                               case ECAT_ITEMEXIST     : if ( !external_call ) vform_stop( MSG_CATITEMEXIST ) ;
                                                         break ;
                               default                 : if (err && !external_call ) vform_stop( MSG_CATADDERR ) ;
                                                         else if ( wext->WndAlbum ) PostMessage( wext->WndAlbum, MSG_WALB_REFRESH, NULL ) ;
                                                         break ;
                             }
                           }
                           deselect(adr_album, obj) ;
                           GWObjcDraw( wnd, adr_album, obj ) ;
                           update_list( wnd, 1 ) ;
                           GWObjcDraw( wnd, adr_album, ALBUM_IMAGE ) ;
                           wext->hf =(float) (adr_album[ALBUM_BOX].ob_height-adr_album[ALBUM_SLIDER].ob_height) ;
                           break ;
    case ALBUM_ADDFOLDER : add_folders( wext, external_call ) ;
                           make_category_popup( wnd ) ; /* Si fichier INI ... */
                           deselect( adr_album, obj ) ;
                           GWObjcDraw( wnd, adr_album, obj ) ;
                           update_list( wnd, 1 ) ;
                           GWObjcDraw( wnd, adr_album, ALBUM_IMAGE ) ;
                           wext->hf =(float) (adr_album[ALBUM_BOX].ob_height-adr_album[ALBUM_SLIDER].ob_height) ;
                           if ( wext->WndAlbum ) PostMessage( wext->WndAlbum, MSG_WALB_REFRESH, NULL ) ;
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
                               GWObjcDraw( wnd, adr_album, ALBUM_IMAGE ) ;
                             }
                             else
                             {
                               catalog_getfullname(wext->hCat, wext->first+obj-ALBUM_ITEM1, buf) ;
                               config.color_protect = wext->cconfig ;
                               load_wpicture( buf, IID_UNKNOWN ) ;
                               config.color_protect = selected(adr_album, ALBUM_PPAL) ;
                             }
                           }
                           break ;
    case ALBUM_INFOIMG   : deselect(adr_album, obj) ;
                           GWObjcDraw( wnd, adr_album, obj ) ;
                           for (i = ALBUM_ITEM1; i <= ALBUM_ITEM10; i++)
                             if (selected(adr_album, i)) break ;
                           if (i != 1+ALBUM_ITEM10)
                             show_imginfo(wext->hCat, wext->first+i-ALBUM_ITEM1, wext->img_comment) ;
                           break ;
    case ALBUM_IMAGE     : deselect(adr_album, obj) ;
                           for (i = ALBUM_ITEM1; i <= ALBUM_ITEM10; i++)
                             if (selected(adr_album, i)) break ;
                           if (i != 1+ALBUM_ITEM10)
                           {
                             catalog_getfullname(wext->hCat, wext->first+i-ALBUM_ITEM1, buf) ;
                             config.color_protect = wext->cconfig ;
                             load_wpicture( buf, IID_UNKNOWN ) ;
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
    case ALBUM_PLUS      : if (wext->first+1+ALBUM_ITEM10-ALBUM_ITEM1 < catalog_filter->nb_visibles)
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
                           if ( catalog_filter )
                             if (wext->first+1+ALBUM_ITEM10-ALBUM_ITEM1 > catalog_filter->nb_visibles)
                               wext->first = (int) (catalog_filter->nb_visibles-1-ALBUM_ITEM10+ALBUM_ITEM1) ;
                           update_list( wnd, 1 ) ;
                           break ;
    case ALBUM_SLIDER    : pc = (float) graf_slidebox(adr_album, ALBUM_BOX, ALBUM_SLIDER, 1) ;
                           pc = (1000.0-pc)/10.0 ;
                           y = (int) ((100.0-pc)*(float)wext->hf/100.0) ;
                           adr_album[ALBUM_SLIDER].ob_y = y ;
                           if ( catalog_filter )
                           {
                             wext->first = (int) ((float)y*(float)(catalog_filter->nb_visibles-1-ALBUM_ITEM10+ALBUM_ITEM1)/wext->hf) ;
                             if ( wext->first+1+ALBUM_ITEM10-ALBUM_ITEM1 > catalog_filter->nb_visibles )
                               wext->first = (int) (catalog_filter->nb_visibles-1-ALBUM_ITEM10+ALBUM_ITEM1) ;
                           }
                           if ( wext->first < 0 ) wext->first = 0 ;
                           update_list( wnd, 1 ) ;
                           break ;
    case ALBUM_PTPAL     : inv_select( adr_album, ALBUM_PPAL ) ;
                           GWObjcDraw( wnd, adr_album, ALBUM_PPAL ) ;
    case ALBUM_PPAL      : config.color_protect = selected( adr_album, ALBUM_PPAL ) ;
                           set_palette( &wext->imginf ) ;
                           break ;
    case ALBUM_CATEGORIE1:
    case ALBUM_CATEGORIE2:
    case ALBUM_CATEGORIE3:
                           for ( i = ALBUM_ITEM1; i <= ALBUM_ITEM10; i++ )
                             if ( selected(adr_album, i) ) break ;
                           if (( tab_index == NULL) || (i == 1+ALBUM_ITEM10) ) break ;
                           deselect( adr_album, obj ) ;
                           objc_offset( adr_album, obj, &mx, &my ) ;
                           y = wext->first+i-ALBUM_ITEM1 ;
                           if ( obj == ALBUM_CATEGORIE1 )      y = tab_index[y].category_1 ;
                           else if ( obj == ALBUM_CATEGORIE2 ) y = tab_index[y].category_2 ;
                           else                                y = tab_index[y].category_3 ;
                           clicked = popup_formdo( &wext->categorie, mx, my, y, -1 ) ;
                           if ( clicked > 1 )
                           {
                             sprintf( buf, "  %s", catalog_header->category_names[clicked-2] ) ;
                             write_text( adr_album, obj, buf ) ;
                             if ( ( obj == ALBUM_CATEGORIE1 ) &&
                                  ( tab_index[wext->first+i-ALBUM_ITEM1].category_1 == tab_index[wext->first+i-ALBUM_ITEM1].category_2 ) &&
                                  ( tab_index[wext->first+i-ALBUM_ITEM1].category_2 == tab_index[wext->first+i-ALBUM_ITEM1].category_3 )
                                )
                             {
                               int j ;

                               for ( j = 1; j <= 3 ; j++ )
                                 catalog_setcategory( wext->hCat, wext->first+i-ALBUM_ITEM1, clicked-2, j ) ;
                             }
                             else
                               catalog_setcategory( wext->hCat, wext->first+i-ALBUM_ITEM1, clicked-2, 1+obj-ALBUM_CATEGORIE1 ) ;
                           }
                           else if ( clicked == 1 )
                           {
                             int  index_category ;
                             char buffer[80] ;

                             lstd_input( vMsgTxtGetMsg(MSG_CATENEW), buffer ) ;
                             if ( buffer[0] )
                             {
                               index_category = catalog_addcategory(wext->hCat, buffer) ;
                               make_category_popup( wnd ) ;
                               sprintf( buf, "  %s", buffer ) ;
                               write_text( adr_album, obj, buf ) ;
                               catalog_setcategory( wext->hCat, wext->first+i-ALBUM_ITEM1, index_category, 1+obj-ALBUM_CATEGORIE1 ) ;
                             }
                           }
                           wext->last_num = -1 ;
                           load_icon( wnd, wext->first+i-ALBUM_ITEM1 ) ;
                           break ;
    case ALBUM_CONFIG    : if (album_config(wext->hCat) == 1)
                           {
                             mouse_busy() ;
                             catalog_sort_index(wext->hCat) ;
                             wext->first = 0 ;
                             mouse_restore() ;
                           }
                           deselect(adr_album, obj) ;
                           GWObjcDraw( wnd, adr_album, obj ) ;
                           update_list( wnd, 1 ) ;
                           wext->hf =(float) (adr_album[ALBUM_BOX].ob_height-adr_album[ALBUM_SLIDER].ob_height) ;
                           for (i = ALBUM_ITEM1; i <= ALBUM_ITEM10; i++)
                             if (selected(adr_album, i)) break ;
                           wext->last_num = -1 ;
                           load_icon( wnd, wext->first+i-ALBUM_ITEM1 ) ;
                           if (catalog_filter && (catalog_filter->nb_visibles <= 0) )
                             adr_album[ALBUM_WINDOW].ob_state |= DISABLED ;
                           else
                             adr_album[ALBUM_WINDOW].ob_state &= ~DISABLED ;
                           GWObjcDraw( wnd, adr_album, ALBUM_IMAGE ) ;
                           GWObjcDraw( wnd, adr_album, ALBUM_WINDOW ) ;
                           break ;
    case ALBUM_UPDATE    : catalog_update( wext->hCat, vMsgTxtGetMsg(MSG_UPDATECAT)  ) ;
                           deselect(adr_album, obj) ;
                           GWObjcDraw( wnd, adr_album, obj ) ;
                           update_list( wnd, 1 ) ;
                           wext->hf =(float) (adr_album[ALBUM_BOX].ob_height-adr_album[ALBUM_SLIDER].ob_height) ;
                           for (i = ALBUM_ITEM1; i <= ALBUM_ITEM10; i++)
                             if (selected(adr_album, i)) break ;
                           wext->last_num = -1 ;
                           load_icon( wnd, wext->first+i-ALBUM_ITEM1 ) ;
                           GWObjcDraw( wnd, adr_album, ALBUM_IMAGE ) ;
                           if ( wext->WndAlbum ) PostMessage( wext->WndAlbum, MSG_WALB_REFRESH, NULL ) ;
                           break ;
    case ALBUM_WINDOW    : if ( wext->WndAlbum == NULL ) album_window(wext->hCat, wnd, &wext->WndAlbum) ;
                           deselect(adr_album, obj) ;
                           GWObjcDraw( wnd, adr_album, obj ) ;
                           wext->hf =(float) (adr_album[ALBUM_BOX].ob_height-adr_album[ALBUM_SLIDER].ob_height) ;
                           for (i = ALBUM_ITEM1; i <= ALBUM_ITEM10; i++)
                             if (selected(adr_album, i)) break ;
                           wext->last_num = -1 ;
                           load_icon( wnd, wext->first+i-ALBUM_ITEM1 ) ;
                           break ;
    case ALBUM_TOVSS     : sprintf( vss_name, "%s\\*.VSS", config.path_album ) ;
                           valid = file_name(vss_name, "", vss_name) ;
                           if ( valid && catalog_filter )
                           {
                             FILE* stream ;
                             long  num ;
                             int   r = 0 ;
                             char  full_name[PATH_MAX] ;

                             if ( FileExist( vss_name ) )
                               r = form_interrogation(2, vMsgTxtGetMsg(MSG_FILEEXISTS) ) ;
                             if ( r == 2 ) break ;
                             stream = fopen( vss_name, "wb" ) ;
                             if ( stream == NULL )
                             {
                               vform_stop( MSG_WRITEERROR ) ;
                               break ;
                             }
                             wprog = DisplayStdProg( vMsgTxtGetMsg(MSG_SAVEVSS) , "", "", CLOSER ) ;
                             for ( num = 0;  num < catalog_filter->nb_visibles ; num++ )
                             {
                               catalog_getfullname( wext->hCat, num, full_name ) ;
                               if ( full_name[0] != 0 )
                               {
                                 sprintf( buf, "Display %s\r\n", full_name ) ;
                                 if ( fwrite( buf, strlen(buf), 1, stream ) != 1 )
                                 {
                                   form_stop( vMsgTxtGetMsg(MSG_WRITEERROR) ) ;
                                   break ;
                                 }
                               }
                               if ( (num & 0x2F) == 0x2F )
                               {
                                 sprintf( buf, "%04ld/%04ld", num, catalog_filter->nb_visibles ) ;
                                 (void)GWProgRange( wprog, num, catalog_filter->nb_visibles, buf ) ;
                               }
                             }
                             fclose( stream ) ;
                             GWDestroyWindow( wprog ) ;
                           }
                           deselect(adr_album, obj) ;
                           GWObjcDraw( wnd, adr_album, obj ) ;
                           break ;
    case ALBUM_OK        : code = IDOK ;
                           break ;
  }

  if ( code == IDOK )
  {
  }

  return code ;
}

static int OnObjectNotifyAlb(void *w, int obj)
{
  return ObjectNotifyAlb( w, obj, NULL ) ;
}

static int OnTxtBubbleAlb(void* w, int mx, int my, char* txt)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
  OBJECT*     adr_form =  wnd->DlgData->BaseObject ;
  int         obj = objc_find( adr_form, 0, MAX_DEPTH, mx, my ) ;
  int         objs[] = { ALBUM_NEW,   ALBUM_OPEN,   ALBUM_INFOS,   ALBUM_PPAL,  ALBUM_PTPAL, ALBUM_INFOIMG, ALBUM_ADDIMG, ALBUM_ADDFOLDER, ALBUM_REMOVE,   ALBUM_CONFIG,   ALBUM_UPDATE,   ALBUM_IMAGE, ALBUM_TOVSS } ;
  int         msgs[] = { MSG_HALMNEW, MSG_HALMOPEN, MSG_HALMINFOS, MSG_HALMPAL, MSG_HALMPAL, MSG_HALMLOAD,  MSG_HALMADD,  MSG_HALMADDF,    MSG_HALMREMOVE, MSG_HALMCONFIG, MSG_HALMUPDATE, MSG_HALMIMG, MSG_HALMTOVSS } ;

  if ( (obj >= ALBUM_CATEGORIE1) && ((obj <= ALBUM_CATEGORIE3)) )
  {
    sprintf( txt, vMsgTxtGetMsg(MSG_HALMCAT) , 1+obj-ALBUM_CATEGORIE1 ) ;
    return 1 ;
  }

  return( vget_txtbubblemsg( obj, objs, msgs, ARRAY_SIZE(objs), txt ) ) ;
}

static int OnCloseAlb(void *w)
{
  GEM_WINDOW*       wnd = (GEM_WINDOW*) w ;
  WEXTENSION_ALBUM* wext = wnd->DlgData->UserData ;

  if ( wext->name ) Xfree( wext->name ) ;
  if ( wext->imginf.mfdb.fd_addr ) Xfree( wext->imginf.mfdb.fd_addr ) ;
  if ( wext->imginf.palette ) Xfree( wext->imginf.palette ) ;
  wext->imginf.palette = NULL ;
  config.color_protect = wext->cconfig ;

  popup_kill( wext->categorie, wext->nb_categories ) ;

  if ( wext->WndAlbum ) GWDestroyWindow( wext->WndAlbum ) ;
  catalog_close(wext->hCat) ;

  Xfree( wext ) ;

  return( GWCloseDlg( w ) ) ;
}

#pragma warn -par
static int OnMsgUserAlb(void* w, int msg_id, int mesag[4])
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;

  switch(msg_id)
  {
    case MSG_ALB_REFRESH: alb_refresh( wnd ) ;
                          break ;

    default:              LoggingDo(LL_WARNING, "Unknown User Message %d for Album dialog", msg_id) ;
                          break ;
  }

  return 0 ;
}
#pragma warn +par

static char* AlbGetWindowID(void* w)
{
  GEM_WINDOW*       wnd = (GEM_WINDOW*) w ;
  WEXTENSION_ALBUM* wext = wnd->DlgData->UserData ;

  if ( wext->name ) return wext->name ;
  else              return "EmptyCat" ;
}

static void FGetAlbum(WEXTENSION_ALBUM *wext)
{
  GEM_WINDOW* dlg ;
  DLGDATA     dlg_data ;

  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId       = FORM_ALBUM ;
  strcpy( dlg_data.Title, vMsgTxtGetMsg(MSG_WFNAMES)  ) ;
  dlg_data.UserData       = wext ;
  dlg_data.OnInitDialog   = OnInitDialogAlb ;
  dlg_data.OnObjectNotify = OnObjectNotifyAlb ;
  dlg_data.OnCloseDialog  = OnCloseAlb ;
  dlg_data.WKind          = SMALLER ;

  dlg = GWCreateDialog( &dlg_data ) ;
#ifndef __NO_BUBBLE
  dlg->OnTxtBubble = OnTxtBubbleAlb ;
#endif
  dlg->OnMsgUser   = OnMsgUserAlb ;
  dlg->GetWindowID = AlbGetWindowID ;
}

void traite_album(char* name)
{
  WEXTENSION_ALBUM* wext = (WEXTENSION_ALBUM*) Xcalloc( 1, sizeof(WEXTENSION_ALBUM) ) ;

  if ( name ) wext->name = Xstrdup( name ) ;
  FGetAlbum( wext ) ;
}

HCAT GethCatFromAlbumWindow(GEM_WINDOW* wnd)
{
  WEXTENSION_ALBUM* wext = wnd->DlgData->UserData ;

  return wext->hCat ;
}