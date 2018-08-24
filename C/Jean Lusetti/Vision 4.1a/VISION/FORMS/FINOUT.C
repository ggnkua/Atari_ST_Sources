#include <string.h>
#include "..\tools\gwindows.h"

#include "..\tools\imgmodul.h"

#include  "defs.h"
#include "fdecoup.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  DECOUP *decoup ;
  int    sel ;

  int    flag_out ;
  long   lfmt ;

  IMG_MODULE *img_modules ;
  short      nb_img_modules ;
}
WEXTENSION_INOUT ;

typedef struct
{
  OBJECT *popup_fmt ;
  int    nb_popup_fmt ;
}
WDLG_INOUT ;


INFO_IMAGE_DRIVER *get_caps(WEXTENSION_INOUT *wext)
{
  INFO_IMAGE_DRIVER *caps = NULL ;

  if ( ( wext->sel >= 0 ) && ( wext->sel < wext->nb_img_modules ) )
    caps = &wext->img_modules[wext->sel].Capabilities ;

  return( caps ) ;
}

void fill_caps(OBJECT *adr_fmt, INFO_IMAGE_DRIVER *caps, WDLG_INOUT *wdlg, int sel)
{
  INFO_IMAGE_DRIVER def_caps ;
  char              check[] = " \x8" ;
  char              nocheck[] = "   " ;
  char              buf[50] ;

  if ( caps == NULL )
  {
    caps = &def_caps ;
    memset( caps, 0, sizeof(INFO_IMAGE_DRIVER) ) ;
    caps->iid = IID_HEXDUMP ;
  }
  sel++ ;
  write_text( adr_fmt, INOUT_FORMAT, wdlg->popup_fmt[sel].ob_spec.free_string ) ;
  write_text( adr_fmt, INOUT_DRIVER, caps->name ) ;
  sprintf( buf, "%02d.%02d", caps->version >> 8, caps->version & 0xFF ) ;
  write_text( adr_fmt, INOUT_VERSION, buf ) ;

  if (caps->inport1)  write_text(adr_fmt, INOUT_IMPORT1, check) ;
  else                write_text(adr_fmt, INOUT_IMPORT1, nocheck) ;
  if (caps->inport2)  write_text(adr_fmt, INOUT_IMPORT2, check) ;
  else                write_text(adr_fmt, INOUT_IMPORT2, nocheck) ;
  if (caps->inport4)  write_text(adr_fmt, INOUT_IMPORT4, check) ;
  else                write_text(adr_fmt, INOUT_IMPORT4, nocheck) ;
  if (caps->inport8)  write_text(adr_fmt, INOUT_IMPORT8, check) ;
  else                write_text(adr_fmt, INOUT_IMPORT8, nocheck) ;
  if (caps->inport16) write_text(adr_fmt, INOUT_IMPORT16, check) ;
  else                write_text(adr_fmt, INOUT_IMPORT16, nocheck) ;
  if (caps->inport24) write_text(adr_fmt, INOUT_IMPORT24, check) ;
  else                write_text(adr_fmt, INOUT_IMPORT24, nocheck) ;

  if (caps->export1)  write_text(adr_fmt, INOUT_EXPORT1, check) ;
  else                write_text(adr_fmt, INOUT_EXPORT1, nocheck) ;
  if (caps->export2)  write_text(adr_fmt, INOUT_EXPORT2, check) ;
  else                write_text(adr_fmt, INOUT_EXPORT2, nocheck) ;
  if (caps->export4)  write_text(adr_fmt, INOUT_EXPORT4, check) ;
  else                write_text(adr_fmt, INOUT_EXPORT4, nocheck) ;
  if (caps->export8)  write_text(adr_fmt, INOUT_EXPORT8, check) ;
  else                write_text(adr_fmt, INOUT_EXPORT8, nocheck) ;
  if (caps->export16) write_text(adr_fmt, INOUT_EXPORT16, check) ;
  else                write_text(adr_fmt, INOUT_EXPORT16, nocheck) ;
  if (caps->export24) write_text(adr_fmt, INOUT_EXPORT24, check) ;
  else                write_text(adr_fmt, INOUT_EXPORT24, nocheck) ;
}

void OnInitDialog(void *w)
{
  INFO_IMAGE_DRIVER *caps ;
  GEM_WINDOW        *wnd = (GEM_WINDOW *) w ;
  WDLG_INOUT        *wdlg = wnd->Extension ;
  WEXTENSION_INOUT  *wext = wnd->DlgData->UserData ;
  OBJECT            *adr_fmt = wnd->DlgData->BaseObject ;
  short             i ;
  char              buffer[60] ;

  if ( wext->flag_out )
  {
    adr_fmt[INOUT_OPEN].ob_flags   |= HIDETREE ;
    adr_fmt[INOUT_SAVE].ob_flags   &= ~HIDETREE ;
    adr_fmt[INOUT_DECOUP].ob_flags &= ~HIDETREE ;
  }
  else
  {
    adr_fmt[INOUT_OPEN].ob_flags   &= ~HIDETREE ;
    adr_fmt[INOUT_SAVE].ob_flags   |= HIDETREE ;
    adr_fmt[INOUT_DECOUP].ob_flags |= HIDETREE ;
  }

  wext->img_modules = DImgGetImgModules( NULL, &wext->nb_img_modules, NULL, 0 ) ;
  if ( wext->img_modules == NULL ) return ;
  wdlg->nb_popup_fmt = 1 + wext->nb_img_modules ; /* + Hexa-Dump */
  wdlg->popup_fmt = popup_make( wdlg->nb_popup_fmt, 15 ) ;
  if ( wdlg->popup_fmt == NULL ) return ;

  wext->sel = 0 ;
  for ( i = 0; i < wext->nb_img_modules; i++ )
  {
    caps = &wext->img_modules[i].Capabilities ;
    sprintf( buffer, "  %s", caps->short_name ) ;
    wext->sel++ ;
    strcpy( wdlg->popup_fmt[wext->sel].ob_spec.free_string, buffer ) ;
  }
  wext->sel++ ;
  strcpy( wdlg->popup_fmt[wext->sel].ob_spec.free_string, "  Hexa-Dump " ) ;

  wext->sel = 0 ;
  caps      = get_caps( wext ) ;
  fill_caps( adr_fmt, caps, wdlg, wext->sel ) ;
}

int OnObjectNotify(void *w, int obj)
{
  INFO_IMAGE_DRIVER *caps ;
  GEM_WINDOW        *wnd = (GEM_WINDOW *) w ;
  WDLG_INOUT        *wdlg = wnd->Extension ;
  WEXTENSION_INOUT  *wext = wnd->DlgData->UserData ;
  OBJECT            *adr_fmt = wnd->DlgData->BaseObject ;
  int               i, code = -1 ;
  int               off_x, off_y ;

  switch( obj )
  {
     case INOUT_FORMAT : objc_offset(adr_fmt, INOUT_FORMAT, &off_x, &off_y) ;
                         i = popup_formdo(&wdlg->popup_fmt, off_x, off_y, 1+wext->sel, -1) ;
                         if ( i > 0 ) wext->sel = i - 1 ;
                         deselect( adr_fmt, obj ) ;

                         caps = get_caps( wext ) ;
                         fill_caps( adr_fmt, caps, wdlg, wext->sel ) ;
                         xobjc_draw( wnd->window_handle, adr_fmt, INOUT_FORMAT ) ;
                         xobjc_draw( wnd->window_handle, adr_fmt, INOUT_DRIVER ) ;
                         xobjc_draw( wnd->window_handle, adr_fmt, INOUT_VERSION ) ;
                         for (i = INOUT_IMPORT1; i <= INOUT_IMPORT24; i++)
                           xobjc_draw( wnd->window_handle, adr_fmt, i ) ;
                         for (i = INOUT_EXPORT1; i <= INOUT_EXPORT24; i++)
                           xobjc_draw( wnd->window_handle, adr_fmt, i ) ;
                         break ;

     case INOUT_DECOUP : get_decoup( wext->decoup ) ;
                         deselect( adr_fmt, obj ) ;
                         break ;

     case INOUT_OK     : code = IDOK ;
                         break ;

     case INOUT_CANCEL : code = IDCANCEL ;
                         wext->lfmt = 0 ;
                         break ;
  }

  if ( code == IDOK )
  {
    caps = get_caps( wext ) ;
    if ( caps ) wext->lfmt = caps->iid ;
    else        wext->lfmt = IID_HEXDUMP ;
  }

  return( code ) ;
}

int OnCloseDialogInOut(void *w)
{
  GEM_WINDOW       *wnd = (GEM_WINDOW *) w ;
  WDLG_INOUT       *wdlg = wnd->Extension ;

  popup_kill( wdlg->popup_fmt, wdlg->nb_popup_fmt ) ;

  return( GWCloseDlg( w ) ) ;
}

long get_format(DECOUP *decoup, int flag_out)
{
  GEM_WINDOW       *dlg ;
  WEXTENSION_INOUT wext ;
  DLGDATA          dlg_data ;
  int              code ;

  wext.decoup        = decoup ;
  wext.decoup->valid = 0 ;
  wext.flag_out      = flag_out ;
  wext.lfmt          = 0 ;

  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
  dlg_data.RsrcId       = FORM_INOUT ;
  strcpy( dlg_data.Title, MsgTxtGetMsg(hMsg, MSG_WFNAMES)  ) ;
  dlg_data.UserData       = &wext ;
  dlg_data.ExtensionSize  = sizeof(WDLG_INOUT) ;
  dlg_data.OnInitDialog   = OnInitDialog ;
  dlg_data.OnObjectNotify = OnObjectNotify ;
  dlg_data.OnCloseDialog  = OnCloseDialogInOut ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, 0 ) ;

  if ( code == IDOK )
  {

  }

  return( wext.lfmt ) ;
}
