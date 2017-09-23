#include <string.h>
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
  RFILE *rfiles ;
  RFILE local_rfile[NB_MAX_RFILES] ;

  int   nb_rfiles ;
}
WEXTENSION_RFILE ;


void OnInitDialogRFiles(void *w)
{
  GEM_WINDOW       *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_RFILE *wext = wnd->DlgData->UserData ;
  OBJECT           *adr_find = wnd->DlgData->BaseObject ;
  int              i ;
  char             *c ;
  char             buf[10] ;

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
  GEM_WINDOW       *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_RFILE *wext = wnd->DlgData->UserData ;
  OBJECT           *adr_find = wnd->DlgData->BaseObject ;
  int              i, code = -1 ;
  char             buf[PATH_MAX], buf1[20], buf2[20] ;

  switch( obj )
  {
    case FIND_FOLDER1 :
    case FIND_FOLDER2 :
    case FIND_FOLDER3 :
    case FIND_FOLDER4 : read_text( adr_find, obj, buf ) ;
                        if ( buf[0] == 0 ) sprintf( buf, "%s\\*.*", config.path_img ) ;
                        if ( file_name( buf, "", buf ) )
                        {
                          char *c ;

                          c  = strrchr(buf, '\\') ;
                          *c = 0 ;
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
    for ( i = 0; ( i <= 1+FIND_FOLDER4-FIND_FOLDER1 ) && ( i < wext->nb_rfiles ) ; i++ )
    {
      strcpy( wext->rfiles[i].path, wext->local_rfile[i].path ) ;
      read_text( adr_find, i + FIND_MASK1, buf1 ) ;
      read_text( adr_find, i + FIND_MASKE1, buf2 ) ;
      sprintf( wext->rfiles[i].mask, "%s.%s", buf1, buf2 ) ;
      wext->rfiles[i].recurse = selected( adr_find, FIND_RECURS ) ;
    }
  }

  return( code ) ;
}

long GetRFiles(RFILE *rfiles, int nb_max_rfiles, int return_nb_files, char *log_file)
{
  GEM_WINDOW       *dlg ;
  WEXTENSION_RFILE wext ;
  DLGDATA          dlg_data ;
  long             nb_files = 0 ;
  int              code, i ;

  memset( &wext, 0, sizeof(WEXTENSION_RFILE) ) ;
  wext.rfiles    = rfiles ;
  wext.nb_rfiles = nb_max_rfiles ;
  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
  dlg_data.RsrcId       = FORM_FIND ;
  strcpy( dlg_data.Title, msg[MSG_WFNAMES] ) ;
  dlg_data.UserData     = &wext ;
  dlg_data.OnInitDialog   = OnInitDialogRFiles ;
  dlg_data.OnObjectNotify = OnObjectNotifyRFiles ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, 0 ) ;

  if ( return_nb_files && ( code == IDOK ) )
  {
    unlink( log_file ) ;
    for ( i = 0; i < nb_max_rfiles; i++ )
    {
      if ( rfiles[i].path[0] )
        nb_files += count_files( rfiles[i].path, rfiles[i].mask, rfiles[i].recurse, log_file ) ;
    }
  }
  else nb_files = ( code == IDOK ) ;

  return( nb_files ) ;
}
