#include <string.h>
#include  "..\tools\logging.h"
#include "..\tools\gwindows.h"
#include "..\tools\frecurse.h"

#include "defs.h"
#include "frfiles.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  RFILE* rfiles ;
  RFILE  local_rfile[NB_MAX_RFILES] ;

  int    nb_rfiles ;
}
WEXTENSION_RFILE ;

typedef struct
{
  clock_t last_check ;
  long    previous_nfiles ;
  long    nfiles ;
  int     (*user_func)(long nfiles_so_far, char *current_filename, void* user_data) ;
  void*   user_data ;
}
COUNT_DATA, *PCOUNT_DATA ;


void OnInitDialogRFiles(void *w)
{
  GEM_WINDOW*       wnd = (GEM_WINDOW *) w ;
  WEXTENSION_RFILE* wext = wnd->DlgData->UserData ;
  OBJECT*           adr_find = wnd->DlgData->BaseObject ;
  char*             c ;
  int               i ;
  char              buf[10] ;

  for ( i = 0; i < NB_MAX_RFILES; i++ )
  {
    write_text( adr_find, i+FIND_FOLDER1, wext->rfiles[i].path ) ;

    strcpy( buf, wext->rfiles[i].mask ) ;
    c = strchr( buf, '.' ) ;
    if ( c )
    {
      *c = 0 ;
      write_text( adr_find, i + FIND_MASK1, buf ) ;
      write_text( adr_find, i + FIND_MASKE1, 1+c ) ;
    }
    else
    {
      write_text( adr_find, i + FIND_MASK1, "*" ) ;
      write_text( adr_find, i + FIND_MASKE1, "*") ;
    }
  }
}

int OnObjectNotifyRFiles(void *w, int obj)
{
  GEM_WINDOW*       wnd = (GEM_WINDOW *) w ;
  WEXTENSION_RFILE* wext = wnd->DlgData->UserData ;
  OBJECT*           adr_find = wnd->DlgData->BaseObject ;
  int               i, code = -1 ;
  char              buf[PATH_MAX], buf1[20], buf2[20] ;

  switch( obj )
  {
    case FIND_FOLDER1 :
    case FIND_FOLDER2 :
    case FIND_FOLDER3 :
    case FIND_FOLDER4 : read_text( adr_find, obj, buf ) ;
                        if ( buf[0] == 0 ) sprintf( buf, "%s\\*.*", config.path_img ) ;
                        if ( folder_name( buf, "", buf ) )
                        {
                          write_text( adr_find, obj, buf ) ;
                          strcpy( wext->local_rfile[obj-FIND_FOLDER1].path, buf ) ;
                        }
                        deselect( adr_find, obj ) ;
                        xobjc_draw( wnd->window_handle, adr_find, obj ) ;
                        break ;
    case FIND_TRECURS :
    case FIND_RECURS  :
                        inv_select( adr_find, FIND_RECURS ) ;
                        break ;
    case FIND_OK      : code = IDOK ;
                        break ;
    case FIND_CANCEL  : code = IDCANCEL ;
                        break ;
  }

  if ( code == IDOK )
  {
    for ( i = 0; ( i < 1+FIND_FOLDER4-FIND_FOLDER1 ) && ( i < wext->nb_rfiles ) ; i++ )
    {
      strcpy( wext->rfiles[i].path, wext->local_rfile[i].path ) ;
      read_text( adr_find, i + FIND_MASK1, buf1 ) ;
      read_text( adr_find, i + FIND_MASKE1, buf2 ) ;
      sprintf( wext->rfiles[i].mask, "%s.%s", buf1, buf2 ) ;
      wext->rfiles[i].recurse = selected( adr_find, FIND_RECURS ) ;
    }
  }

  return code ;
}

static short count_callback(FR_CDATA* fr_cdata)
{
  COUNT_DATA* pcd = fr_cdata->user_data ;
  long        nb_files_so_far = pcd->nfiles + fr_cdata->nfiles ;
  int         stop_counting = 0 ;

  /* As clock() is a bit time consuming on Aranym/Mint, don't call it */
  /* On every update; just every 16 files */
  if ( nb_files_so_far - pcd->previous_nfiles > 16 )
  {
    clock_t now = clock() ;

    /* For logging progress, no more than twice a min */
    if ( now-pcd->last_check > 30L*CLK_TCK )
    {
      LoggingDo(LL_INFO, "%ld files listed so far (listed file is now %s)", nb_files_so_far, fr_cdata->filename) ;
      pcd->last_check      = now ;
      pcd->previous_nfiles = nb_files_so_far ;
    }
  }

  /* For user_func, let the caller decide */
  if ( pcd->user_func )
    stop_counting = pcd->user_func( nb_files_so_far, fr_cdata->filename, pcd->user_data ) ;
  
  return stop_counting ;
}

long GetRFilesEx(RFILE* rfiles, int nb_max_rfiles, int return_nb_files, char* log_file, int (*user_func)(long nfiles_so_far, char* current_filename, void* user_data), void* user_data)
{
  COUNT_DATA cd ;
  int        code, i ;

  memset( &cd, 0, sizeof(COUNT_DATA) ) ;
  cd.user_func = user_func ;
  cd.user_data = user_data ;

  if ( rfiles[0].path[0] == 0 )
  {
    GEM_WINDOW*      dlg ;
    WEXTENSION_RFILE wext ;
    DLGDATA          dlg_data ;

    memset( &wext, 0, sizeof(WEXTENSION_RFILE) ) ;
    wext.rfiles    = rfiles ;
    wext.nb_rfiles = nb_max_rfiles ;
    memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
    dlg_data.RsrcId       = FORM_FIND ;
    strcpy( dlg_data.Title, MsgTxtGetMsg(hMsg, MSG_WFNAMES)  ) ;
    dlg_data.UserData       = &wext ;
    dlg_data.OnInitDialog   = OnInitDialogRFiles ;
    dlg_data.OnObjectNotify = OnObjectNotifyRFiles ;
    dlg  = GWCreateDialog( &dlg_data ) ;
    code = GWDoModal( dlg, 0 ) ;
  }
  else code = IDOK ; /* RFiles provided */

  if ( return_nb_files && ( code == IDOK ) )
  {
    mouse_busy() ;
    unlink( log_file ) ;
    LoggingDo(LL_INFO, "Listing all files in following folder(s):") ;
    for ( i = 0; i < NB_MAX_RFILES; i++ )
    {
      if ( rfiles[i].path[0] )
        LoggingDo(LL_INFO, "  %s", rfiles[i].path) ;
    }
    LoggingDo(LL_INFO, "This might take a while, will update every 30s...") ;
    for ( i = 0; i < nb_max_rfiles; i++ )
    {
      if ( rfiles[i].path[0] )
      {
        FR_DATA fr_data ;

        fr_data.flags      = (config.flags & FLG_LONGFNAME) ? FFR_LONGNAMES|FFR_NOLONGNAMESDETAILS:0 ;
        fr_data.path       = rfiles[i].path ;
        fr_data.mask       = rfiles[i].mask ;
        fr_data.log_file   = log_file ;
        fr_data.user_func  = count_callback ;
        fr_data.user_data  = &cd ;
        cd.nfiles         += count_files( rfiles[i].recurse, &fr_data ) ;
      }
    }
    LoggingDo(LL_INFO, "Listed a total of %ld files", cd.nfiles) ;
    mouse_restore() ;
  }
  else cd.nfiles = ( code == IDOK ) ;

  return cd.nfiles ;
}
