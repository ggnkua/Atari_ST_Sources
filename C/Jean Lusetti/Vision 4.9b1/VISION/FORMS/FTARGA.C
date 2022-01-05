#include <string.h>
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
  INFO_IMAGE *inf ;
}
WEXTENSION_TARGA ;



void OnInitDialogTarga(void *w)
{
  GEM_WINDOW       *wnd = (GEM_WINDOW*) w ;
  WEXTENSION_TARGA *wext = wnd->DlgData->UserData ;
  OBJECT           *adr_targa = wnd->DlgData->BaseObject ;

  deselect(adr_targa, TARGA_16BITS) ;
  deselect(adr_targa, TARGA_24BITS) ;
  deselect(adr_targa, TARGA_FLIPFLOP) ;
  if ( wext->inf->nplanes == 16 ) select( adr_targa, TARGA_16BITS ) ;
  else                            select( adr_targa, TARGA_24BITS ) ;
}

int OnObjectNotifyTarga(void *w, int obj)
{
  GEM_WINDOW       *wnd = (GEM_WINDOW*) w ;
  WEXTENSION_TARGA *wext = wnd->DlgData->UserData ;
  OBJECT           *adr_targa = wnd->DlgData->BaseObject ;
  int              code = -1 ;

  switch( obj )
  {
     case TARGA_T16BITS   :
     case TARGA_16BITS    : select(adr_targa, TARGA_16BITS) ;
                            deselect(adr_targa, TARGA_24BITS) ;
                            xobjc_draw( wnd->window_handle, adr_targa, TARGA_16BITS ) ;
                            xobjc_draw( wnd->window_handle, adr_targa, TARGA_24BITS ) ;
                            break ;
     case TARGA_T24BITS   :
     case TARGA_24BITS    : select(adr_targa, TARGA_24BITS) ;
                            deselect(adr_targa, TARGA_16BITS) ;
                            xobjc_draw( wnd->window_handle, adr_targa, TARGA_16BITS ) ;
                            xobjc_draw( wnd->window_handle, adr_targa, TARGA_24BITS ) ;
                            break ;
     case TARGA_TFLIPFLOP :
     case TARGA_FLIPFLOP  : inv_select(adr_targa, TARGA_FLIPFLOP) ;
                            break ;
     case TARGA_OK        : code = IDOK ;
                            break ;
     case TARGA_CANCEL    : code = IDCANCEL ;
                            break ;
  }

  if ( code == IDOK )
  {
    if (selected(adr_targa, TARGA_16BITS)) wext->inf->nplanes = 16 ;
    else                                   wext->inf->nplanes = 24 ;

    if (selected(adr_targa, TARGA_FLIPFLOP)) wext->inf->c.flipflop = FLIPFLOP_Y ;
    else                                     wext->inf->c.flipflop = 0 ;
  }

  return code ;
}

int targa_options(INFO_IMAGE *inf)
{
  GEM_WINDOW       *dlg ;
  WEXTENSION_TARGA wext ;
  DLGDATA          dlg_data ;
  int              code ;

  wext.inf = inf ;
  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId       = FORM_ETARGA ;
  strcpy( dlg_data.Title, MsgTxtGetMsg(hMsg, MSG_WFNAMES)  ) ;
  dlg_data.UserData     = &wext ;
  dlg_data.OnInitDialog = OnInitDialogTarga ;
  dlg_data.OnObjectNotify = OnObjectNotifyTarga ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, 0 ) ;

  if ( code == IDOK )
  {

  }

  return( ( code == IDOK ) ? 0 : -1 ) ;
}
