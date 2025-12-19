#include <string.h>
#include <stdio.h>
#include "xgem.h"
#include "gwindows.h"
#include "stdmline.h"
/* To avoid #include "std.rsh" */
extern OBJECT* rs_trindex[] ;

typedef struct
{
  MLINES_PARAMS mlines_params ;
}
STDMLINES_EXTENSION ;

#define CL_STDMLINES   "StMLines"


static int OnObjectNotify(void* w, int obj)
{
  GEM_WINDOW*    wnd = (GEM_WINDOW*) w ;
  MLINES_PARAMS* params = wnd->DlgData->UserData ;
  OBJECT*        adr_inf = wnd->DlgData->BaseObject ;
  char           template_file[PATH_MAX] ;
  int            n ;
  int            code = -1 ;

  switch( obj )
  {
     case MLINES_OK     :    code = IDOK ;
                             break ;
     case MLINES_CANCEL :    code = IDCANCEL ;
                             break ;
     case MLINES_TEMPLATES : if ( file_name( params->templates_filemask, "", template_file ) == 1 )
                             {
                               FILE* stream = fopen( template_file, "r" ) ;
                               char buffer[MLP_LINEMAX] ;

                               if ( stream ) 
                               {
                                 for ( n = MLINES_FIRSTMSG; n <= MLINES_LASTMSG; n++ ) write_text( adr_inf, n, "" ) ;
                                 n = 0 ;
                                 while ( (n < MLP_NLINES) && fgets( buffer, MLP_LINEMAX-1, stream ) )
                                 {
                                   removeCRCF( buffer ) ;
                                   write_text( adr_inf, MLINES_FIRSTMSG+n, buffer ) ;
                                   n++ ;
                                 }
                                 fclose( stream ) ;
                               }
                             }
                             deselect( adr_inf, MLINES_TEMPLATES ) ;
                             GWObjcDraw( wnd, adr_inf, MLINES_TEMPLATES ) ;
                             for ( n = MLINES_FIRSTMSG; n <= MLINES_LASTMSG; n++ )
                               GWObjcDraw( wnd, adr_inf, n ) ;
                             break ;
  }

  if ( code == IDOK )
  {
    memzero( params, sizeof(MLINES_PARAMS) ) ;
    for ( n = MLINES_FIRSTMSG; n <= MLINES_LASTMSG; n++ )
      read_text( adr_inf, n, &params->mesg[n-MLINES_FIRSTMSG][0] ) ;
  }

  return code ;
}

int FormStdMLines(MLINES_PARAMS* params)
{
  DLGDATA     dlg_data ;
  OBJECT*     mlines ;
  static char fix_done = 0 ;
  int         n, last_num, ny, dy ;

  GWZeroDlgData( &dlg_data ) ;

  if ( !fix_done )
  {
    Xrsrc_fix( rs_trindex[FORM_MLINES] ) ;
    fix_done = 1 ;
  }

  mlines = xobjc_copy( rs_trindex[FORM_MLINES] ) ;
  if ( mlines == NULL ) return IDCANCEL ;

  for ( n = MLINES_FIRSTMSG; n <= MLINES_LASTMSG; n++ )
  {
    write_text( mlines, n, params->mesg[n-MLINES_FIRSTMSG] ) ;
    if ( params->read_only ) mlines[n].ob_flags &= ~EDITABLE ;
  }

  if ( !params->show_alllines )
  {
    for ( last_num = MLINES_LASTMSG; last_num >= MLINES_FIRSTMSG; last_num-- )
      if ( params->mesg[last_num-MLINES_FIRSTMSG][0] != 0 ) break ;
  }
  else last_num = MLINES_LASTMSG ;

  if ( last_num != MLINES_LASTMSG )
  {
    dy = mlines[0].ob_height - ( mlines[MLINES_OK].ob_y + mlines[MLINES_OK].ob_height ) ;
    ny = mlines[last_num+1].ob_y + 2 * mlines[last_num+1].ob_height ;
    mlines[MLINES_CANCEL].ob_y = mlines[MLINES_OK].ob_y = ny ;
    mlines[0].ob_height = dy + mlines[MLINES_OK].ob_y + mlines[MLINES_OK].ob_height ;
    for ( n = 1+last_num; n <= MLINES_LASTMSG; n++ )
      mlines[n].ob_flags |= HIDETREE ;
  }

  if ( !params->ok_caption[0] )
  {
    mlines[MLINES_OK].ob_flags |= HIDETREE ;
    if ( params->cancel_caption[0] )
      mlines[MLINES_CANCEL].ob_x = ( mlines[0].ob_width - mlines[MLINES_CANCEL].ob_width ) >> 1 ;
  }
  else write_text( mlines, MLINES_OK, params->ok_caption ) ;

  if ( !params->cancel_caption[0] )
  {
    mlines[MLINES_CANCEL].ob_flags |= HIDETREE ;
    if ( params->ok_caption[0] )
      mlines[MLINES_OK].ob_x = ( mlines[0].ob_width - mlines[MLINES_OK].ob_width ) >> 1 ;
  }
  else write_text( mlines, MLINES_CANCEL, params->cancel_caption ) ;

  if ( params->read_only || (params->templates_filemask[0] == 0) ) mlines[MLINES_TEMPLATES].ob_flags |= HIDETREE ;

  dlg_data.RsrcId   = -1 ;
  dlg_data.Object   = mlines ;
  dlg_data.Parent   = NULL ;
  dlg_data.UserData = params ;
  strcpy( dlg_data.ClassName, CL_STDMLINES ) ;
  strcpy( dlg_data.Title, params->title ) ;
  dlg_data.OnObjectNotify = OnObjectNotify ;

  return GWCreateAndDoModal( &dlg_data, 0 ) ;
}
