#include <string.h>
#include "..\tools\gwindows.h"
#include "..\tools\logging.h"

#include "..\tools\imgmodul.h"

#include  "defs.h"
#include "fdecoup.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  DECOUP* decoup ;
  int     sel ;

  int    flag_out ;
  long   lfmt ;

  IMG_MODULE** img_modules ;
  short        nb_img_modules ;
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
    caps = &wext->img_modules[wext->sel]->Capabilities ;

  return caps ;
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
    memzero( caps, sizeof(INFO_IMAGE_DRIVER) ) ;
  }
  if ( wdlg->popup_fmt )
  {
    write_text( adr_fmt, INOUT_FORMAT, wdlg->popup_fmt[1+sel].ob_spec.free_string ) ;
    write_text( adr_fmt, INOUT_DRIVER, caps->name ) ;
    sprintf( buf, "%02x.%02x", caps->version >> 8, caps->version & 0xFF ) ;
    write_text( adr_fmt, INOUT_VERSION, buf ) ;
  }
  else
  {
    write_text( adr_fmt, INOUT_FORMAT, "  NA  " ) ;
    write_text( adr_fmt, INOUT_DRIVER, "" ) ;
    write_text( adr_fmt, INOUT_VERSION, "" ) ;
  }


  if (caps->import & IEF_P1)  write_text(adr_fmt, INOUT_IMPORT1, check) ;
  else                        write_text(adr_fmt, INOUT_IMPORT1, nocheck) ;
  if (caps->import & IEF_P2)  write_text(adr_fmt, INOUT_IMPORT2, check) ;
  else                        write_text(adr_fmt, INOUT_IMPORT2, nocheck) ;
  if (caps->import & IEF_P4)  write_text(adr_fmt, INOUT_IMPORT4, check) ;
  else                        write_text(adr_fmt, INOUT_IMPORT4, nocheck) ;
  if (caps->import & IEF_P8)  write_text(adr_fmt, INOUT_IMPORT8, check) ;
  else                        write_text(adr_fmt, INOUT_IMPORT8, nocheck) ;
  if (caps->import & IEF_P16) write_text(adr_fmt, INOUT_IMPORT16, check) ;
  else                        write_text(adr_fmt, INOUT_IMPORT16, nocheck) ;
  if (caps->import & IEF_P24) write_text(adr_fmt, INOUT_IMPORT24, check) ;
  else                        write_text(adr_fmt, INOUT_IMPORT24, nocheck) ;

  if (caps->export & IEF_P1)  write_text(adr_fmt, INOUT_EXPORT1, check) ;
  else                        write_text(adr_fmt, INOUT_EXPORT1, nocheck) ;
  if (caps->export & IEF_P2)  write_text(adr_fmt, INOUT_EXPORT2, check) ;
  else                        write_text(adr_fmt, INOUT_EXPORT2, nocheck) ;
  if (caps->export & IEF_P4)  write_text(adr_fmt, INOUT_EXPORT4, check) ;
  else                        write_text(adr_fmt, INOUT_EXPORT4, nocheck) ;
  if (caps->export & IEF_P8)  write_text(adr_fmt, INOUT_EXPORT8, check) ;
  else                        write_text(adr_fmt, INOUT_EXPORT8, nocheck) ;
  if (caps->export & IEF_P16) write_text(adr_fmt, INOUT_EXPORT16, check) ;
  else                        write_text(adr_fmt, INOUT_EXPORT16, nocheck) ;
  if (caps->export & IEF_P24) write_text(adr_fmt, INOUT_EXPORT24, check) ;
  else                        write_text(adr_fmt, INOUT_EXPORT24, nocheck) ;
}

static void OnInitDialog(void* w)
{
  IMG_MODULE*        img_module_total ;
  INFO_IMAGE_DRIVER* caps ;
  GEM_WINDOW*        wnd = (GEM_WINDOW*) w ;
  WDLG_INOUT*        wdlg = wnd->Extension ;
  WEXTENSION_INOUT*  wext = wnd->DlgData->UserData ;
  OBJECT*            adr_fmt = wnd->DlgData->BaseObject ;
  short              nb_img_modules ;
  short              nb_modules_for_saving = 0 ;
  short              i ;
  char               buffer[60] ;

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

  img_module_total = DImgGetImgModules( NULL, &nb_img_modules, NULL, NULL ) ; /* Just get current list of modules */
  if ( img_module_total == NULL ) return ;
  for ( i = 0; i < nb_img_modules; i++ )
    if ( img_module_total[i].Type == MST_LDI ) nb_modules_for_saving++ ;
  if ( nb_modules_for_saving > 0 )
  {
    wdlg->popup_fmt = popup_make( nb_modules_for_saving, 15 ) ;
    if ( wdlg->popup_fmt == NULL ) return ;
    wdlg->nb_popup_fmt = nb_modules_for_saving ;
    wext->img_modules  = Xcalloc( nb_modules_for_saving, sizeof(IMG_MODULE*) ) ;
    if ( wext->img_modules == NULL )
    {
      Xfree( wdlg->popup_fmt ) ; wdlg->popup_fmt = NULL ;
      return ;
    }
    wext->nb_img_modules = nb_modules_for_saving ;

    wext->sel = 0 ;
    for ( i = 0; i < nb_img_modules; i++ )
    {
      caps = &img_module_total[i].Capabilities ;
      if ( (img_module_total[i].Type == MST_LDI) && (wext->sel < nb_modules_for_saving) )
      {
        /* Only implemented for Vision internal modules right now */
        sprintf( buffer, "  %s", caps->short_name ) ;
        wext->img_modules[wext->sel] = &img_module_total[i] ;
        wext->sel++ ;
        strcpy( wdlg->popup_fmt[wext->sel].ob_spec.free_string, buffer ) ;
      }
    }
    LoggingDo(LL_INFO, "%d modules available for saving", wext->sel) ;
    wext->sel = 0 ; /* Select first entry */
  }
  else wext->sel = -1 ;
  caps = get_caps( wext ) ;
  fill_caps( adr_fmt, caps, wdlg, wext->sel ) ;
}

int OnObjectNotify(void *w, int obj)
{
  INFO_IMAGE_DRIVER *caps ;
  GEM_WINDOW        *wnd = (GEM_WINDOW* ) w ;
  WDLG_INOUT        *wdlg = wnd->Extension ;
  WEXTENSION_INOUT  *wext = wnd->DlgData->UserData ;
  OBJECT            *adr_fmt = wnd->DlgData->BaseObject ;
  int               i, code = -1 ;
  int               off_x, off_y ;

  if ( wdlg->popup_fmt == NULL ) return IDCANCEL ;

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
                         wext->lfmt = IID_UNKNOWN ;
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

static int OnCloseDialogInOut(void* w)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
  WDLG_INOUT* wdlg = wnd->Extension ;

  if ( wdlg->popup_fmt ) popup_kill( wdlg->popup_fmt, wdlg->nb_popup_fmt ) ;

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
  wext.lfmt          = IID_UNKNOWN ;

  GWZeroDlgData( &dlg_data ) ;
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

  if ( wext.img_modules ) Xfree( wext.img_modules ) ;

  return( wext.lfmt ) ;
}
