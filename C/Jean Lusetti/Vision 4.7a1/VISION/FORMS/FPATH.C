#include <string.h>
#include <stdio.h>
#include "..\tools\gwindows.h"

#include "actions.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  char path_img[PATH_MAX] ;
  char path_filter[PATH_MAX] ;
  char path_lod[PATH_MAX] ;
  char path_album[PATH_MAX] ;
  char path_language[PATH_MAX] ;
  char path_temp[PATH_MAX] ;
  char path_ldv[PATH_MAX] ;
}
WEXTENSION_PATH ;


void OnInitDialogPath(void *w)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  OBJECT     *adr_paths = wnd->DlgData->BaseObject ;

  write_text(adr_paths, PATH_IMG, config.path_img) ;
  write_text(adr_paths, PATH_FILTRES, config.path_filter) ;
  write_text(adr_paths, PATH_DSP, config.path_lod) ;
  write_text(adr_paths, PATH_ALBUM, config.path_album) ;
  write_text(adr_paths, PATH_LANGUES, config.path_language) ;
  write_text(adr_paths, PATH_TEMP, config.path_temp) ;
  write_text(adr_paths, PATH_LDV, config.path_ldv) ;
}

void get_path(OBJECT *tree, int index)
{
  char buffer[200] ;
  char nom[200] ;

  read_text( tree, index, buffer ) ;
  strcat( buffer, "\\" ) ;
  if ( folder_name( buffer, "", nom ) == 1 )
    write_text( tree, index, nom ) ;
  deselect( tree, index ) ;
}

int OnObjectNotifyPath(void *w, int obj)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_PATH *wext = wnd->DlgData->UserData ;
  OBJECT          *adr_paths = wnd->DlgData->BaseObject ;
  int             code = -1 ;

  switch( obj )
  {
    case PATH_IMG     : 
    case PATH_FILTRES :
    case PATH_DSP     :
    case PATH_ALBUM   :
    case PATH_LANGUES :
    case PATH_TEMP    :
    case PATH_LDV     :
                        get_path( adr_paths, obj ) ;
                        break ;
     case PATH_OK     : code = IDOK ;
                        break ;
     case PATH_CANCEL : code = IDCANCEL ;
                        break ;
  }

  if ( code == IDOK )
  {
    read_text( adr_paths, PATH_IMG, wext->path_img ) ;
    read_text( adr_paths, PATH_FILTRES, wext->path_filter ) ;
    read_text( adr_paths, PATH_DSP, wext->path_lod ) ;
    read_text( adr_paths, PATH_ALBUM, wext->path_album ) ;
    read_text( adr_paths, PATH_LANGUES, wext->path_language ) ;
    read_text( adr_paths, PATH_TEMP, wext->path_temp ) ;
    read_text( adr_paths, PATH_LDV, wext->path_ldv ) ;
  }

  return( code ) ;
}

void get_paths(void)
{
  GEM_WINDOW      *dlg ;
  WEXTENSION_PATH wext ;
  DLGDATA         dlg_data ;
  int             code ;

  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
  dlg_data.RsrcId       = FORM_PATH ;
  strcpy( dlg_data.Title, MsgTxtGetMsg(hMsg, MSG_WFNAMES)  ) ;
  dlg_data.UserData     = &wext ;
  dlg_data.OnInitDialog = OnInitDialogPath ;
  dlg_data.OnObjectNotify = OnObjectNotifyPath ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, 0 ) ;

  if ( code == IDOK )
  {
    strcpy( config.path_img, wext.path_img ) ;
    strcpy( config.path_filter, wext.path_filter ) ;
    strcpy( config.path_lod, wext.path_lod ) ;
    strcpy( config.path_album, wext.path_album ) ;
    strcpy( config.path_language, wext.path_language ) ;
    strcpy( config.path_temp, wext.path_temp ) ;
    strcpy( config.path_ldv, wext.path_ldv ) ;
  }
}

