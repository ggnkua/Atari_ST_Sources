#include  <stdio.h>

#include      "..\tools\xgem.h"
#include   "..\tools\logging.h"
#include  "..\tools\gwindows.h"

#include    "forms\fabout.h"

#include    "defs.h"
#include   "akeys.h"
#include "twindow.h"


void XOpenFileApp(char* name, int x, int y, int w, int h)
{
  TWINDOW_PARAMS tw_params ;

  TWGetOrSetParams( name, &tw_params ) ;
  tw_params.x = x ; tw_params.y = y ;
  tw_params.w = w ; tw_params.h = h ;
  TWCreate( &tw_params ) ;
}

int OnAppKeyPressed(int key)
{
  static char last_path[PATH_MAX] ;
  char        path[PATH_MAX] ;
  char        name[PATH_MAX] ;
  int         code = GW_EVTCONTINUEROUTING ;

  switch( key )
  {
    case K_ABOUT:     form_about() ;
                      break ;
    case K_OPEN:      if ( *last_path == 0 ) strcpy( path, init_path ) ;
                      else                   strcpy( path, last_path ) ;
                      strcat( path, "\\*.*" ) ;
                      if ( file_name( path, "", name ) ) XOpenFileApp( name, 0, 0, 0, 0 ) ;
                      break ;
    case K_OPENCON:   XOpenFileApp( "u:\\dev\\xconout2", 0, 0, 0, 0 ) ;
                      break ;
    case K_CLOSE:     if ( GemApp.CurrentGemWindow && GemApp.CurrentGemWindow->OnClose ) GemApp.CurrentGemWindow->OnClose( GemApp.CurrentGemWindow ) ;
                      break ;
    case K_QUIT:      if ( config.reload_tails ) GTSaveINIFile( &config ) ;
                      code = GW_EVTQUITAPP ;
                      break ;
  }

  return code ;
}

int OnAppMenuSelected(int t_id, int m_id)
{
  int   code = GW_EVTCONTINUEROUTING ;
  short mids[] = { M_ABOUT, M_OPEN, M_OPENCON, M_CLOSE, M_QUIT } ;
  short keys[] = { K_ABOUT, K_OPEN, K_OPENCON, K_CLOSE, K_QUIT } ;
  short n, key = 0 ;

  for ( n = 0; n < ARRAY_SIZE(mids); n++ )
    if ( mids[n] == m_id ) { key = keys[n] ; break ; }

  if ( key ) code = OnAppKeyPressed( key ) ;

  GWOnMenuSelected( t_id, m_id ) ;

  return code ;
}
