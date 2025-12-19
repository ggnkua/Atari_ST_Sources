#include <string.h>
#include <stdlib.h>
#include "..\tools\gwindows.h"
#include "..\tools\logging.h"

#include "..\tools\image_io.h"

#include "defs.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  INFO_IMAGE inf_visionimg ;
  int        saved_pal[256*3] ;
  char       use_img ;
  char       must_be_freed ;
  char       high_res ;
}
WEXTENSION_BARATIN ;


int cdecl draw_visionimg(PARMBLK* paramblk)
{
  WEXTENSION_BARATIN* wext = (WEXTENSION_BARATIN*) paramblk->pb_parm ;
  int                 cxy[4] ;
  int                 xy[8] ;

  xy[0]  = 0 ;
  xy[1]  = 0 ;
  xy[2]  = wext->inf_visionimg.mfdb.fd_w-1 ;
  xy[3]  = wext->inf_visionimg.mfdb.fd_h-1 ;
  xy[4]  = paramblk->pb_x ;
  xy[5]  = paramblk->pb_y ;
  xy[6]  = xy[4]+wext->inf_visionimg.mfdb.fd_w-1 ;
  xy[7]  = xy[5]+wext->inf_visionimg.mfdb.fd_h-1 ;
  cxy[0] = paramblk->pb_xc ;
  cxy[1] = paramblk->pb_yc ;
  cxy[2] = paramblk->pb_xc+paramblk->pb_wc-1 ;
  cxy[3] = paramblk->pb_yc+paramblk->pb_hc-1 ;
  svs_clipON( cxy ) ;
  GWHideCursor() ;
  svro_cpyfmSOS( xy, &wext->inf_visionimg.mfdb ) ;
  GWShowCursor() ;
  svs_clipOFF( xy ) ;

  return 0 ;
}

int load_visionimg(GEM_WINDOW* wnd)
{
  WEXTENSION_BARATIN* wext = wnd->DlgData->UserData ;
  OBJECT*             adr_baratin = wnd->DlgData->BaseObject ;
  char                name[200] ;
  int                 ret ;
  short               current_pref_type = DImgGetPrefType() ;

  sprintf( name, "%s\\VISION.IMG", init_path ) ;
  if ( (Xmax - 16 < adr_baratin[0].ob_width) || 
       (Ymax - 16 < adr_baratin[0].ob_height) ||
       (name[0] <= 'B') || !wext->high_res
     )
  {
    adr_baratin[BARATIN_IMG].ob_flags = HIDETREE ;
/*    adr_baratin[0].ob_width = 242 ;*/
    LoggingDo(LL_INFO, "Not loading vision.img: name=%s", name) ;
    wext->use_img = 0 ;
    return 0 ;
  }

  DImgSetPrefType( MST_LDI ) ;
  if ( vimg_format( IID_IMG, -1, name, &wext->inf_visionimg ) )
  {
    adr_baratin[BARATIN_IMG].ob_flags |= HIDETREE ;
    adr_baratin[0].ob_width = 242 ;
    LoggingDo(LL_INFO, "Not loading vision.img: %s failed img_format", name) ;
    wext->use_img = 0 ;
    DImgSetPrefType( current_pref_type ) ;
    return 0 ;
  }

  wext->inf_visionimg.mfdb.fd_nplanes = screen.fd_nplanes ;
  ret = vload_picture( &wext->inf_visionimg ) ;
  if ( ret != 0 )
  {
    adr_baratin[BARATIN_IMG].ob_flags |= HIDETREE ;
    adr_baratin[0].ob_width = 242 ;
    LoggingDo(LL_INFO, "Not loading vision.img: %s failed load_picture with %d", name, ret) ;
    wext->use_img = 0 ;
    DImgSetPrefType( current_pref_type ) ;
    return 0 ;
  }

  adr_baratin[BARATIN_IMG].ob_flags &= ~HIDETREE ;
  adr_baratin[0].ob_width   = 484 ;
  adr_baratin[0].ob_height += 8 ; /* Should be fixed in RSC file but too many of them... */
  wext->use_img = 1 ;

  DImgSetPrefType( current_pref_type ) ;
  return 1 ;
}

static void OnInitDialogBaratin(void* w)
{
  GEM_WINDOW*         wnd = (GEM_WINDOW*) w ;
  WEXTENSION_BARATIN* wext = wnd->DlgData->UserData ;
  OBJECT*             adr_baratin = wnd->DlgData->BaseObject ;
  char                buffer[50] ;

  adr_baratin[BARATIN_IMG].ob_spec.userblk->ub_code = draw_visionimg ;
  adr_baratin[BARATIN_IMG].ob_spec.userblk->ub_parm = (long) wext ;

  sprintf( buffer, "VISION %s", NO_VERSION ) ;
  write_text( adr_baratin, REGISTER, "" ) ;
  write_text( adr_baratin, KEY, "" ) ;
  write_text( adr_baratin, VERSION, buffer ) ;
  write_text( adr_baratin, WEBLINK, "http://vision.atari.org" ) ;

  adr_baratin[REGISTER].ob_flags  &= ~EDITABLE ;
  adr_baratin[REGISTER].ob_flags  |= HIDETREE ;
  adr_baratin[KEY].ob_flags       |= HIDETREE ;
  adr_baratin[SHAREWARE].ob_flags |= HIDETREE ;

  load_visionimg( wnd ) ;
}

#pragma warn -par
static int OnObjectNotifyBaratin(void* w, int obj)
{
  int code = -1 ;

  switch( obj )
  {
    case BARATIN_OK : code = IDOK ;
                      break ;
  }

  return code ;
}
#pragma warn +par

static int OnCloseDialogBaratin(void* w)
{
  GEM_WINDOW*         wnd = (GEM_WINDOW*) w ;
  WEXTENSION_BARATIN* wext = wnd->DlgData->UserData ;

  free_info( &wext->inf_visionimg ) ;
  if ( wext->must_be_freed ) Xfree( wext ) ;

  return( GWCloseDlg( w ) ) ;
}

void display_baratin(char high_res)
{
  WEXTENSION_BARATIN wext ;
  DLGDATA            dlg_data ;

  wext.must_be_freed = 0 ;
  wext.high_res      = high_res ;
  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId         = FORM_BARATIN ;
  strcpy( dlg_data.Title, vMsgTxtGetMsg(MSG_WFNAMES)  ) ;
  dlg_data.UserData       = &wext ;
  dlg_data.OnInitDialog   = OnInitDialogBaratin ;
  dlg_data.OnObjectNotify = OnObjectNotifyBaratin ;
  dlg_data.OnCloseDialog  = OnCloseDialogBaratin ;

  (void)GWCreateAndDoModal( &dlg_data, REGISTER ) ;
}

GEM_WINDOW* display_splash(char high_res)
{
  GEM_WINDOW*         dlg ;
  WEXTENSION_BARATIN* wext ;
  DLGDATA             dlg_data ;
  OBJECT*             adr_baratin ;
  char                buffer[50] ;

  wext = (WEXTENSION_BARATIN*) Xcalloc( 1, sizeof(WEXTENSION_BARATIN) ) ;
  if ( wext == NULL ) return NULL ;

  wext->must_be_freed = 1 ;
  wext->high_res      = high_res ;
  Xrsrc_gaddr( R_TREE, FORM_BARATIN, &adr_baratin ) ;
  adr_baratin[BARATIN_OK].ob_flags  |= HIDETREE ;
  strcpy(buffer, "VISION ") ;
  strcat(buffer, NO_VERSION) ;
  write_text(adr_baratin, VERSION, buffer) ;
  adr_baratin[KEY].ob_flags |= HIDETREE ;

  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId         = FORM_BARATIN ;
  strcpy( dlg_data.Title, vMsgTxtGetMsg(MSG_WFNAMES)  ) ;
  dlg_data.UserData       = wext ;
  dlg_data.OnInitDialog   = OnInitDialogBaratin ;
  dlg_data.OnObjectNotify = OnObjectNotifyBaratin ;
  dlg_data.OnCloseDialog  = OnCloseDialogBaratin;

  dlg = GWCreateDialog( &dlg_data ) ;
  adr_baratin[BARATIN_OK].ob_flags &= ~HIDETREE ;

  return dlg ;
}
