#include <string.h>
#include <stdlib.h>
#include "..\tools\gwindows.h"
#include "..\tools\catalog.h"
#include "..\tools\logging.h"

#include "defs.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  CHTML_EXPORT *exp ;
}
WEXTENSION_ECATHTML ;

void OnInitDialogEHTML(void *w)
{
  GEM_WINDOW          *wnd = (GEM_WINDOW* ) w ;
  WEXTENSION_ECATHTML *wext = wnd->DlgData->UserData ;
  OBJECT              *adr_ehtml = wnd->DlgData->BaseObject ;
  char                buf[10] ;

  sprintf( buf, "%d", wext->exp->nb_img_per_line ) ;
  if ( wext->exp->nb_img_per_line > 0 ) write_text( adr_ehtml, EHTML_NBLINES, buf ) ;
  sprintf( buf, "%d", wext->exp->nb_img_per_row ) ;
  if ( wext->exp->nb_img_per_row > 0 ) write_text( adr_ehtml, EHTML_NBROWS, buf ) ;
  sprintf( buf, "%d", wext->exp->border_width ) ;
  if ( wext->exp->border_width > 0 ) write_text( adr_ehtml, EHTML_WBORDER, buf ) ;
  if ( wext->exp->flags & EH_LINKIMG ) select( adr_ehtml, EHTML_LINKIMG ) ;
  write_text( adr_ehtml, EHTML_TITLE, "" ) ;
}

int OnObjectNotifyEHTML(void *w, int obj)
{
  GEM_WINDOW          *wnd = (GEM_WINDOW* ) w ;
  WEXTENSION_ECATHTML *wext = wnd->DlgData->UserData ;
  CATALOG_HEADER*     catalog_header = catalog_get_header(wext->exp->hCat) ;
  OBJECT              *adr_ehtml = wnd->DlgData->BaseObject ;
  int                 code = -1 ;
  char                buf[PATH_MAX] ;
  char                filename[PATH_MAX] ;
  char                sug_name[50] ;
  char                *slash, *point ;

  switch( obj )
  {
     case EHTML_TLINKIMG  : inv_select( adr_ehtml, EHTML_LINKIMG ) ;
                            xobjc_draw( wnd->window_handle, adr_ehtml, EHTML_LINKIMG ) ;
                            break ;

     case EHTML_TSHOWNAMES: inv_select( adr_ehtml, EHTML_SHOWNAMES ) ;
                            xobjc_draw( wnd->window_handle, adr_ehtml, EHTML_SHOWNAMES ) ;
                            break ;

     case EHTML_BACK      : sprintf( buf, "%s\\*.*", config.path_img ) ;
                            if ( file_name( buf, "", filename ) == 1 )
                            {
                              strcpy( wext->exp->back_file, filename ) ;
                              write_text( adr_ehtml, obj, filename ) ;
                              xobjc_draw( wnd->window_handle, adr_ehtml, obj ) ;
                            }
                            break ;

     case EHTML_SAVE      : if ( catalog_header )
                            {
                              slash = strrchr( catalog_header->catalog_name, '\\' ) ;
                              if ( slash ) strcpy( sug_name, 1 + slash ) ;
                              else         strcpy( sug_name, catalog_header->catalog_name ) ;
                              point = strrchr( sug_name, '.' ) ;
                              if ( point ) *point = 0 ;
                              strcat( sug_name, ".HTM" ) ;
                              sprintf( buf, "%s\\*.HTM", config.path_img ) ;
                              if ( file_name( buf, sug_name, filename ) == 1 )
                              {
                                slash = strrchr( filename, '\\' ) ;
                                if ( slash ) *slash = 0 ;
                                strcpy( wext->exp->path, filename ) ;
                                if ( slash )
                                {
                                  point = strrchr( 1 + slash, '.' ) ;
                                  if ( point ) *point = 0 ;
                                  memzero( wext->exp->base_name, sizeof(wext->exp->base_name) ) ;
                                  strncpy( wext->exp->base_name, 1 + slash, sizeof(wext->exp->base_name) - 1 ) ;
                                }
                              }
                              code = IDOK ;
                            }
                            else LoggingDo(LL_ERROR, "Invalid hCat");
                            inv_select( adr_ehtml, obj ) ;
                            xobjc_draw( wnd->window_handle, adr_ehtml, obj ) ;
                            break ;

     case EHTML_CANCEL    : code = IDCANCEL ;
                            break ;
  }

  if ( code == IDOK )
  {
    read_text( adr_ehtml, EHTML_NBLINES, buf ) ;
    wext->exp->nb_img_per_line = atoi( buf ) ;
    read_text( adr_ehtml, EHTML_NBROWS, buf ) ;
    wext->exp->nb_img_per_row = atoi( buf ) ;
    read_text( adr_ehtml, EHTML_WBORDER, buf ) ;
    wext->exp->border_width = atoi( buf ) ;
    read_text( adr_ehtml, EHTML_LPREV, wext->exp->previous_label ) ;
    read_text( adr_ehtml, EHTML_LNEXT, wext->exp->next_label ) ;
    read_text( adr_ehtml, EHTML_LPAGE, wext->exp->page_label ) ;
    wext->exp->flags = 0 ;
    if ( selected( adr_ehtml, EHTML_LINKIMG ) ) wext->exp->flags |= EH_LINKIMG ;
    if ( selected( adr_ehtml, EHTML_SHOWNAMES ) ) wext->exp->flags |= EH_SHOWNAMES ;
    read_text( adr_ehtml, EHTML_TITLE, wext->exp->page_title ) ;
    read_text( adr_ehtml, EHTML_TABSIZE, buf ) ;
    wext->exp->pc = atoi( buf ) ;
    if ( wext->exp->pc < 1 )   wext->exp->pc = 1 ;
    if ( wext->exp->pc > 100 ) wext->exp->pc = 100 ;
  }

  return( code ) ;
}

int FGetHTMLExport(CHTML_EXPORT *exp)
{
  GEM_WINDOW          *dlg ;
  WEXTENSION_ECATHTML wext ;
  DLGDATA             dlg_data ;
  int                 code ;

  wext.exp = exp ;
  GWZeroDlgData( &dlg_data ) ;
  strcpy( dlg_data.Title, MsgTxtGetMsg(hMsg, MSG_WFNAMES)  ) ;
  dlg_data.RsrcId         = FORM_EHTML ;
  dlg_data.UserData       = &wext ;
  dlg_data.OnInitDialog   = OnInitDialogEHTML ;
  dlg_data.OnObjectNotify = OnObjectNotifyEHTML ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, EHTML_TITLE ) ;

  return( code ) ;
}

void HTMLCatalogExport(HCAT hCat, long first, long last)
{
  GEM_WINDOW   *wprog ;
  CHTML_EXPORT exp ;
  char         buf[100] ;

  memzero( &exp, sizeof(CHTML_EXPORT) ) ;

  exp.hCat = hCat ;
  strcpy( exp.app_name, "VISION" ) ;
  if ( FGetHTMLExport( &exp ) == IDOK )
  {
    sprintf( buf, MsgTxtGetMsg(hMsg, MSG_EHTML) , exp.page_title ) ;
    wprog = DisplayStdProg( buf, "", "", 0 ) ;
    exp.first = first ;
    exp.last  = last ;
    exp.back_color[0] = 255 ;
    exp.back_color[1] = 255 ;
    exp.back_color[2] = 255 ;
    switch( catalog_ehtml( &exp, wprog ) )
    {
    }
    PostMessage( wprog, WM_CLOSED, NULL ) ;
  }
}

