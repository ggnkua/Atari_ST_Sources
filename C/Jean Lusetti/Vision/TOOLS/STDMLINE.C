#include <string.h>
#include <stdio.h>
#include "xgem.h"
#include "gwindows.h"
#include "stdmline.h"
/* Pour eviter #include "std.rsh" */
extern OBJECT *rs_trindex[] ;

typedef struct
{
  MLINES_PARAMS mlines_params ;
}
STDMLINES_EXTENSION ;

#define CL_STDMLINES   "StMLines"

#pragma warn -par
static int OnObjectNotify(void *w, int obj)
{
  int code = -1 ;

  switch( obj )
  {
     case MLINES_OK     : code = IDOK ;
                          break ;
     case MLINES_CANCEL : code = IDCANCEL ;
                          break ;
  }

  if ( code == IDOK )
  {
  }

  return( code ) ;
}
#pragma parm +par

GEM_WINDOW *DisplayStdMLines(MLINES_PARAMS *params)
{
  GEM_WINDOW  *wnd ;
  DLGDATA     dlg_data ;
  OBJECT      *mlines ;
  static char fix_done = 0 ;
  int         n, last_num, ny, dy ;

  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;

  if ( !fix_done )
  {
    Xrsrc_fix( rs_trindex[FORM_MLINES] ) ;
    fix_done = 1 ;
  }

  mlines = xobjc_copy( rs_trindex[FORM_MLINES] ) ;
  if ( mlines == NULL ) return( NULL ) ;

  for ( n = MLINES_FIRSTMSG; n <= MLINES_LASTMSG; n++ )
    write_text( mlines, n, params->msg[n-MLINES_FIRSTMSG] ) ;

  for ( last_num = MLINES_LASTMSG; last_num >= MLINES_FIRSTMSG; last_num-- )
    if ( params->msg[last_num-MLINES_FIRSTMSG][0] != 0 ) break ;

  if ( last_num != MLINES_LASTMSG )
  {
    dy = mlines[0].ob_height - ( mlines[MLINES_OK].ob_y + mlines[MLINES_OK].ob_height ) ;
    ny = mlines[last_num+1].ob_y + 2 * mlines[last_num+1].ob_height ;
    mlines[MLINES_CANCEL].ob_y = mlines[MLINES_OK].ob_y = ny ;
    mlines[0].ob_height = dy + mlines[MLINES_OK].ob_y + mlines[MLINES_OK].ob_height ;
  }

  if ( !params->ok_button )
  {
    mlines[MLINES_OK].ob_flags |= HIDETREE ;
    if ( params->cancel_button )
      mlines[MLINES_CANCEL].ob_x = ( mlines[0].ob_width - mlines[MLINES_CANCEL].ob_width ) / 2 ;
  }

  if ( !params->cancel_button )
  {
    mlines[MLINES_CANCEL].ob_flags |= HIDETREE ;
    if ( params->ok_button )
      mlines[MLINES_OK].ob_x = ( mlines[0].ob_width - mlines[MLINES_OK].ob_width ) / 2 ;
  }

  dlg_data.RsrcId = -1 ;
  dlg_data.Object = mlines ;
  dlg_data.Parent = NULL ;
  dlg_data.ExtensionSize = sizeof(STDMLINES_EXTENSION) ;
  strcpy( dlg_data.ClassName, CL_STDMLINES ) ;
  dlg_data.OnObjectNotify = OnObjectNotify ;
  wnd = GWCreateDialog( &dlg_data ) ;

  return( wnd ) ;
}
