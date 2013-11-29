#include <string.h>
#include <stdlib.h>
#include "..\tools\gwindows.h"

#include "..\tools\image_io.h"

#include "defs.h"
#include "register.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  INFO_IMAGE inf_visionimg ;
  MFDB       visionimg ;
  int        saved_pal[256*3] ;
  char       use_img ;
  char       must_be_freed ;

  char       user[20] ;
  char       key[20] ;
}
WEXTENSION_BARATIN ;


int cdecl draw_visionimg(PARMBLK *paramblk)
{
  WEXTENSION_BARATIN *wext = (WEXTENSION_BARATIN *) paramblk->pb_parm ;
  int cxy[4] ;
  int xy[8] ;

  xy[0]  = 0 ;
  xy[1]  = 0 ;
  xy[2]  = wext->visionimg.fd_w-1 ;
  xy[3]  = wext->visionimg.fd_h-1 ;
  xy[4]  = paramblk->pb_x ;
  xy[5]  = paramblk->pb_y ;
  xy[6]  = xy[4]+wext->visionimg.fd_w-1 ;
  xy[7]  = xy[5]+wext->visionimg.fd_h-1 ;
  cxy[0] = paramblk->pb_xc ;
  cxy[1] = paramblk->pb_yc ;
  cxy[2] = paramblk->pb_xc+paramblk->pb_wc-1 ;
  cxy[3] = paramblk->pb_yc+paramblk->pb_hc-1 ;
  vs_clip(handle, 1, cxy) ;
  v_hide_c(handle) ;
  vro_cpyfm(handle, S_ONLY, xy, &wext->visionimg, &screen) ;
  v_show_c(handle, 1) ;
  vs_clip(handle, 0, xy) ;

  return(0) ;
}

int load_visionimg(GEM_WINDOW *wnd)
{
  WEXTENSION_BARATIN *wext = wnd->DlgData->UserData ;
  LIB_ID             save_lib_ids[5] ;
  LIB_ID             lib_id = { P_LDV, 0, 0 } ;
  OBJECT             *adr_baratin = wnd->DlgData->BaseObject ;
  char               name[200] ;
  int                nb_lib_ids, ret ;

  nb_lib_ids = GetLibPriorities( save_lib_ids ) ;
  SetLibPriorities( &lib_id, 1 ) ;

  strcpy(name, " :");
  name[0] = 'A' + Dgetdrv();
  if ( ( Xmax - 16 < adr_baratin[0].ob_width ) || 
       ( Ymax - 16 < adr_baratin[0].ob_height ) ||
       (*name == 'A') || !haute_resolution
     )
  {
    adr_baratin[BARATIN_IMG].ob_flags = HIDETREE ;
/*    adr_baratin[0].ob_width = 242 ;*/
    wext->use_img = 0 ;
    SetLibPriorities( save_lib_ids, nb_lib_ids ) ;
    return( 0 ) ;
  }

  Dgetpath( &name[2], 0 );
  sprintf( name, "%s\\VISION.IMG", init_path ) ;

  if ( img_format( name, &wext->inf_visionimg ) )
  {
    adr_baratin[BARATIN_IMG].ob_flags |= HIDETREE ;
    adr_baratin[0].ob_width = 242 ;
    wext->use_img = 0 ;
    SetLibPriorities( save_lib_ids, nb_lib_ids ) ;
    return( 0 ) ;
  }

  wext->visionimg.fd_nplanes = nb_plane ;
  if ( nb_plane == 16 ) Force16BitsLoad = 1 ;
  else                  Force16BitsLoad = 0 ;
  ret = load_picture( name, &wext->visionimg, &wext->inf_visionimg, NULL ) ;
  if ( ret != 0 )
  {
    adr_baratin[BARATIN_IMG].ob_flags |= HIDETREE ;
    adr_baratin[0].ob_width = 242 ;
    wext->use_img = 0 ;
    SetLibPriorities( save_lib_ids, nb_lib_ids ) ;
    return( 0 ) ;
  }

  if ( wext->inf_visionimg.palette ) free( wext->inf_visionimg.palette ) ;
  wext->inf_visionimg.palette = NULL ;
  adr_baratin[BARATIN_IMG].ob_flags &= ~HIDETREE ;
  adr_baratin[0].ob_width = 484 ;
  wext->use_img = 1 ;

  SetLibPriorities( save_lib_ids, nb_lib_ids ) ;
  return( 1 ) ;
}

void OnInitDialogBaratin(void *w)
{
  GEM_WINDOW  *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_BARATIN *wext = wnd->DlgData->UserData ;
  OBJECT      *adr_baratin = wnd->DlgData->BaseObject ;
  char        buffer[50] ;

  adr_baratin[BARATIN_IMG].ob_spec.userblk->ub_code = draw_visionimg ;
  adr_baratin[BARATIN_IMG].ob_spec.userblk->ub_parm = (long) wext ;

  sprintf( buffer, "VISION %s", NO_VERSION ) ;
  write_text( adr_baratin, REGISTER, "" ) ;
  write_text( adr_baratin, KEY, "" ) ;
  write_text( adr_baratin, VERSION, buffer ) ;
  write_text( adr_baratin, WEBLINK, "http://vision.atari.org" ) ;

  if ( IsRegistered )
  {
    crypte_ident( adr_baratin ) ;
    adr_baratin[REGISTER].ob_flags &= ~EDITABLE ;
    adr_baratin[KEY].ob_flags      |= HIDETREE ;
  }

  load_visionimg( wnd ) ;
}

int OnObjectNotifyBaratin(void *w, int obj)
{
  GEM_WINDOW  *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_BARATIN *wext = wnd->DlgData->UserData ;
  OBJECT      *adr_baratin = wnd->DlgData->BaseObject ;
  int code = -1 ;

  switch( obj )
  {
    case BARATIN_OK : code = IDOK ;
                      break ;
  }

  if ( code == IDOK )
  {
    read_text( adr_baratin, REGISTER, wext->user ) ;
    read_text( adr_baratin, KEY, wext->key ) ;
  }

  return( code ) ;
}

int OnCloseDialogBaratin(void *w)
{
  GEM_WINDOW  *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_BARATIN *wext = wnd->DlgData->UserData ;

  if ( wext->use_img ) free( wext->visionimg.fd_addr ) ;
  if ( wext->must_be_freed ) free( wext ) ;

  return( GWCloseDlg( w ) ) ;
}

int FGetBaratin(char *user, char *key)
{
  GEM_WINDOW         *dlg ;
  WEXTENSION_BARATIN wext ;
  DLGDATA            dlg_data ;
  int                code ;

  wext.must_be_freed = 0 ;
  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
  dlg_data.RsrcId       = FORM_BARATIN ;
  strcpy( dlg_data.Title, msg[MSG_WFNAMES] ) ;
  dlg_data.UserData     = &wext ;
  dlg_data.OnInitDialog = OnInitDialogBaratin ;
  dlg_data.OnObjectNotify = OnObjectNotifyBaratin ;
  dlg_data.OnCloseDialog  = OnCloseDialogBaratin;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, REGISTER ) ;

  if ( code == IDOK )
  {
    if ( user ) strcpy( user, wext.user ) ;
    if ( key ) strcpy( key, wext.key ) ;
  }

  return( code ) ;
}

void display_baratin(void)
{
  FGetBaratin( NULL, NULL ) ;
}

GEM_WINDOW *display_splash(void)
{
  GEM_WINDOW         *dlg ;
  WEXTENSION_BARATIN *wext ;
  DLGDATA            dlg_data ;
  OBJECT             *adr_baratin ;
  char               buffer[50] ;

  wext = (WEXTENSION_BARATIN *) calloc( 1, sizeof(WEXTENSION_BARATIN) ) ;
  if ( wext == NULL ) return( NULL ) ;

  wext->must_be_freed = 1 ;
  Xrsrc_gaddr( R_TREE, FORM_BARATIN, &adr_baratin ) ;
  crypte_ident( adr_baratin ) ;
  adr_baratin[BARATIN_OK].ob_flags  |= HIDETREE ;
  strcpy(buffer, "VISION ") ;
  strcat(buffer, NO_VERSION) ;
  write_text(adr_baratin, VERSION, buffer) ;
  adr_baratin[KEY].ob_flags |= HIDETREE ;

  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
  dlg_data.RsrcId       = FORM_BARATIN ;
  strcpy( dlg_data.Title, msg[MSG_WFNAMES] ) ;
  dlg_data.UserData     = wext ;
  dlg_data.OnInitDialog = OnInitDialogBaratin ;
  dlg_data.OnObjectNotify = OnObjectNotifyBaratin ;
  dlg_data.OnCloseDialog  = OnCloseDialogBaratin;

  dlg  = GWCreateDialog( &dlg_data ) ;
  adr_baratin[BARATIN_OK].ob_flags  &= ~HIDETREE ;

  return( dlg ) ;
}
