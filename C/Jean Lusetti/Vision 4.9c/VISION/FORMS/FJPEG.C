#include <string.h>
#include <stdlib.h>
#include "..\tools\gwindows.h"

#include "defs.h"
#include "..\tools\targa_io.h"
#include "..\tools\image_io.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  INFO_IMAGE* inf ;
}
WEXTENSION_JPEG ;



static void OnInitDialogJpeg(void* w)
{
  GEM_WINDOW*      wnd = (GEM_WINDOW*) w ;
  WEXTENSION_JPEG* wext = wnd->DlgData->UserData ;
  OBJECT*          adr_jpeg = wnd->DlgData->BaseObject ;
  char             buf[10] ;

  if ( wext->inf->c.f.jpg.quality < 10 ) wext->inf->c.f.jpg.quality = 90 ; /* Was 75 by default which is poor and very unlikely to have it < 10 */
  sprintf( buf, "%03d", wext->inf->c.f.jpg.quality ) ;
  write_text( adr_jpeg, JPEG_QUALITY, buf ) ;
}

static int OnObjectNotifyJpeg(void* w, int obj)
{
  GEM_WINDOW*      wnd = (GEM_WINDOW*) w ;
  WEXTENSION_JPEG* wext = wnd->DlgData->UserData ;
  OBJECT*          adr_jpeg = wnd->DlgData->BaseObject ;
  int              code = -1 ;
  char             buf[10] ;

  switch( obj )
  {
     case JPEG_OK     : code = IDOK ;
                        break ;
     case JPEG_CANCEL : code = IDCANCEL ;
                        break ;
  }

  if ( code == IDOK )
  {
    read_text( adr_jpeg, JPEG_QUALITY, buf ) ;
    wext->inf->c.f.jpg.quality = atoi( buf ) ;
  }

  return code ;
}

int jpeg_options(INFO_IMAGE* inf)
{
  WEXTENSION_JPEG wext ;
  DLGDATA         dlg_data ;

  wext.inf = inf ;
  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId         = FORM_EJPEG ;
  strcpy( dlg_data.Title, vMsgTxtGetMsg(MSG_WFNAMES)  ) ;
  dlg_data.UserData       = &wext ;
  dlg_data.OnInitDialog   = OnInitDialogJpeg ;
  dlg_data.OnObjectNotify = OnObjectNotifyJpeg ;

  return( (GWCreateAndDoModal( &dlg_data, JPEG_QUALITY ) == IDOK) ? 0 : -1 ) ;
}
