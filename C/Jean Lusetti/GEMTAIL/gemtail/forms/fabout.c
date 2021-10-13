#include <string.h>
#include <stdlib.h>
#include "..\tools\gwindows.h"
#include "..\tools\logging.h"

#include "..\defs.h"



static void OnInitDialog(void* w)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
  OBJECT*     adr_about = wnd->DlgData->BaseObject ;
  char        buffer[50] ;

  sprintf( buffer, "Version %s", NO_VERSION ) ;
  write_text( adr_about, FABOUT_VERSION, buffer ) ;
}

#pragma warn -par
static int OnObjectNotify(void* w, int obj)
{
  return IDOK ;
}
#pragma warn +par

void form_about(void)
{
  DLGDATA dlg_data ;

  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId         = FORM_ABOUT ;
  dlg_data.OnInitDialog   = OnInitDialog ;
  dlg_data.OnObjectNotify = OnObjectNotify ;

  (void)GWDoModal( GWCreateDialog( &dlg_data ), -1 ) ;
}
