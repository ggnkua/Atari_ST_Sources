#include <string.h>
#include "..\tools\gwindows.h"

#include "defs.h"
#include "..\tools\tiff_io.h"
#include "..\tools\image_io.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  INFO_IMAGE* inf ;
}
WEXTENSION_TIFF ;



void OnInitDialogTiff(void *w)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
  OBJECT*     adr_tiff = wnd->DlgData->BaseObject ;

  adr_tiff[TIFF_LZW].ob_state  &= ~DISABLED ;
  adr_tiff[TIFF_TLZW].ob_state &= ~DISABLED ;

  adr_tiff[TIFF_DELTA].ob_state  |= DISABLED ;
  adr_tiff[TIFF_TDELTA].ob_state |= DISABLED ;
  select( adr_tiff, TIFF_NOTREAT ) ;

  select( adr_tiff, TIFF_NOCOMPRESS ) ;
  deselect( adr_tiff, TIFF_LZW ) ;
  select( adr_tiff, TIFF_NOTREAT ) ;
  deselect( adr_tiff, TIFF_DELTA ) ;
}

int OnObjectNotifyTiff(void *w, int obj)
{
  GEM_WINDOW*      wnd = (GEM_WINDOW*) w ;
  WEXTENSION_TIFF* wext = wnd->DlgData->UserData ;
  OBJECT*          adr_tiff = wnd->DlgData->BaseObject ;
  int              predictor_enable ;
  int              code = -1 ;

  switch( obj )
  {
    case TIFF_INTEL       :
    case TIFF_TINTEL      : select( adr_tiff, TIFF_INTEL ) ;
                            deselect( adr_tiff, TIFF_MOTOROLA ) ;
                            GWObjcDraw( wnd, adr_tiff, TIFF_INTEL ) ;
                            GWObjcDraw( wnd, adr_tiff, TIFF_MOTOROLA ) ;
                            break ;
    case TIFF_MOTOROLA    :
    case TIFF_TMOTOROLA   : select( adr_tiff, TIFF_MOTOROLA ) ;
                            deselect( adr_tiff, TIFF_INTEL ) ;
                            GWObjcDraw( wnd, adr_tiff, TIFF_MOTOROLA ) ;
                            GWObjcDraw( wnd, adr_tiff, TIFF_INTEL ) ;
                            break ;
    case TIFF_NOCOMPRESS  :
    case TIFF_TNOCOMPRESS : select( adr_tiff, TIFF_NOCOMPRESS ) ;
                            deselect( adr_tiff, TIFF_LZW ) ;
                            GWObjcDraw( wnd, adr_tiff, TIFF_NOCOMPRESS ) ;
                            GWObjcDraw( wnd, adr_tiff, TIFF_LZW ) ;
                            predictor_enable = selected(adr_tiff, TIFF_LZW) && (wext->inf->nplanes >= 8) ;
                            if ( predictor_enable )
                            {
                              adr_tiff[TIFF_DELTA].ob_state  &= ~DISABLED ;
                              adr_tiff[TIFF_TDELTA].ob_state &= ~DISABLED ;
                            }
                            else
                            {
                              adr_tiff[TIFF_DELTA].ob_state  |= DISABLED ;
                              adr_tiff[TIFF_TDELTA].ob_state |= DISABLED ;
                              select( adr_tiff, TIFF_NOTREAT ) ;
                              deselect( adr_tiff, TIFF_DELTA ) ;
                            }
                            GWObjcDraw( wnd, adr_tiff, TIFF_NOTREAT ) ;
                            GWObjcDraw( wnd, adr_tiff, TIFF_DELTA ) ;
                            GWObjcDraw( wnd, adr_tiff, TIFF_TDELTA ) ;
                            break ;
    case TIFF_LZW         :
    case TIFF_TLZW        : deselect( adr_tiff, TIFF_NOCOMPRESS ) ;
                            select( adr_tiff, TIFF_LZW ) ;
                            GWObjcDraw( wnd, adr_tiff, TIFF_NOCOMPRESS ) ;
                            GWObjcDraw( wnd, adr_tiff, TIFF_LZW ) ;
                            predictor_enable = selected(adr_tiff, TIFF_LZW) && (wext->inf->nplanes >= 8) ;
                            if ( predictor_enable )
                            {
                              adr_tiff[TIFF_DELTA].ob_state  &= ~DISABLED ;
                              adr_tiff[TIFF_TDELTA].ob_state &= ~DISABLED ;
                            }
                            else
                            {
                              adr_tiff[TIFF_DELTA].ob_state  |= DISABLED ;
                              adr_tiff[TIFF_TDELTA].ob_state |= DISABLED ;
                            }
                            GWObjcDraw( wnd, adr_tiff, TIFF_TDELTA ) ;
                            break ;
    case TIFF_NOTREAT     :
    case TIFF_TNOTREAT    : select( adr_tiff, TIFF_NOTREAT ) ;
                            deselect( adr_tiff, TIFF_DELTA ) ;
                            GWObjcDraw( wnd, adr_tiff, TIFF_NOTREAT ) ;
                            GWObjcDraw( wnd, adr_tiff, TIFF_DELTA ) ;
                            break ;
    case TIFF_DELTA       :
    case TIFF_TDELTA      : predictor_enable = selected(adr_tiff, TIFF_LZW) && (wext->inf->nplanes >= 8) ;
                            if ( predictor_enable )
                            {
                              deselect( adr_tiff, TIFF_NOTREAT ) ;
                              select( adr_tiff, TIFF_DELTA ) ;
                            }
                            else
                            {
                              select( adr_tiff, TIFF_NOTREAT ) ;
                              deselect( adr_tiff, TIFF_DELTA ) ;
                            }
                            GWObjcDraw( wnd, adr_tiff, TIFF_NOTREAT ) ;
                            GWObjcDraw( wnd, adr_tiff, TIFF_DELTA ) ;
                            break ;
     case TIFF_OK         : code = IDOK ;
                            break ;
     case TIFF_CANCEL     : code = IDCANCEL ;
                            break ;
  }

  if ( code == IDOK )
  {
    if (selected( adr_tiff, TIFF_LZW) )   wext->inf->compress  = 5 ;
    else                                  wext->inf->compress  = 1 ;
    if (selected( adr_tiff, TIFF_DELTA) ) wext->inf->c.f.tif.predictor = 2 ;
    else                                  wext->inf->c.f.tif.predictor = 1 ;
    if (selected( adr_tiff, TIFF_INTEL) ) wext->inf->c.f.tif.byteorder = INTEL ;
    else                                  wext->inf->c.f.tif.byteorder = MOTOROLA ;
  }

  return code ;
}

int tiff_options(INFO_IMAGE* inf)
{
  WEXTENSION_TIFF wext ;
  DLGDATA         dlg_data ;

  wext.inf = inf ;
  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId       = FORM_ETIFF ;
  strcpy( dlg_data.Title, vMsgTxtGetMsg(MSG_WFNAMES)  ) ;
  dlg_data.UserData     = &wext ;
  dlg_data.OnInitDialog = OnInitDialogTiff ;
  dlg_data.OnObjectNotify = OnObjectNotifyTiff ;

  return( (GWCreateAndDoModal( &dlg_data, 0 ) == IDOK) ? 0 : -1 ) ;
}
