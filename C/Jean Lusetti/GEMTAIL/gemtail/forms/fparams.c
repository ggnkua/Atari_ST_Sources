#include <string.h>
#include <stdlib.h>
#include "..\tools\gwindows.h"
#include "..\tools\logging.h"
#include "..\tools\xgem.h"

#include "..\defs.h"

#include "..\twindow.h"

#define NB_FILTERS 10

typedef struct
{
  TWINDOW_PARAMS* params ;
  short           nb_params ;
  int             selection ;
  int             filter_no ;
}
WEXTENSION_TWPARAMS ;

typedef struct
{
  OBJECT* popup_tail ;
  OBJECT* popup_filter ;
  OBJECT* popup_text_color ;
  OBJECT* popup_back_color ;
}
WDLG_PARAM ;


static void UpdateColors(GEM_WINDOW* wnd, short redraw)
{
  WEXTENSION_TWPARAMS* wext = wnd->DlgData->UserData ;
  WDLG_PARAM*          wdlg = wnd->Extension ;
  OBJECT*              adr_params = wnd->DlgData->BaseObject ;
  TEXT_TYPE*           tt = &wext->params[wext->selection].HighLightData[wext->filter_no].TextType ;
  char                 buffer[160] ;

  adr_params[FP_FILTERTC].ob_spec.tedinfo->te_color &= 0xFFF0 ;
  adr_params[FP_FILTERTC].ob_spec.tedinfo->te_color |= tt->color ;

  adr_params[FP_FILTERBC].ob_spec.tedinfo->te_color &= 0xFFF0 ;
  adr_params[FP_FILTERBC].ob_spec.tedinfo->te_color |= tt->fg_color ;

  adr_params[FP_FILTERKW].ob_spec.tedinfo->te_color &= 0xF0F0 ;
  adr_params[FP_FILTERKW].ob_spec.tedinfo->te_color |= (tt->color << 8) + tt->fg_color ;

  write_text( adr_params, FP_FILTERN, wdlg->popup_filter[1+wext->filter_no].ob_spec.free_string ) ;
  write_text( adr_params, FP_FILTERTC, wdlg->popup_text_color[1+tt->color].ob_spec.free_string ) ;
  write_text( adr_params, FP_FILTERBC, wdlg->popup_back_color[1+tt->fg_color].ob_spec.free_string ) ;
  write_text( adr_params, -FP_TAIL, wext->params[wext->selection].FileName ) ;  /* Negative: best match for diaplay */
  TWMultipleStringToCommaSep( wext->params[wext->selection].ExcludedKeywords, buffer ) ;
  write_text( adr_params, FP_EXCLUDE, buffer ) ;
  TWMultipleStringToCommaSep( wext->params[wext->selection].HighLightData[wext->filter_no].Keywords, buffer ) ;
  write_text( adr_params, FP_FILTERKW, buffer ) ;
  if ( redraw )
  {
    xobjc_draw( wnd->window_handle, adr_params, FP_FILTERTC ) ;
    xobjc_draw( wnd->window_handle, adr_params, FP_FILTERBC ) ;
    xobjc_draw( wnd->window_handle, adr_params, FP_FILTERKW ) ;
    xobjc_draw( wnd->window_handle, adr_params, FP_FILTERN ) ;
    xobjc_draw( wnd->window_handle, adr_params, FP_TAIL ) ;
    xobjc_draw( wnd->window_handle, adr_params, FP_EXCLUDE ) ;
    xobjc_draw( wnd->window_handle, adr_params, FP_FILTERKW ) ;
  }
}

static void OnInitDialog(void* w)
{
  GEM_WINDOW*          wnd = (GEM_WINDOW*) w ;
  WDLG_PARAM*          wdlg = wnd->Extension ;
  WEXTENSION_TWPARAMS* wext = wnd->DlgData->UserData ;
  OBJECT*              adr_params = wnd->DlgData->BaseObject ;
  char                 buffer[160] ;
  char                 filter_name[64] ;
  char*                string ;
  short                i, size ;

  /* FP_TAIL popup */
  read_text( adr_params, FP_TAIL, buffer ) ;
  size = (short) strlen( buffer ) ;
  wdlg->popup_tail = popup_make( wext->nb_params, size ) ;
  if ( wdlg->popup_tail == NULL ) return ;

  for ( i = 0; i < wext->nb_params; i++ )
  {
    string = reduce_string_if_required( wext->params[i].FileName, buffer, size ) ;
    strncpy( wdlg->popup_tail[1+i].ob_spec.free_string, string, size ) ;
  }

  /* FP_FILTERN popup */
  read_text( adr_params, FP_FILTERN, buffer ) ;
  size = (short) strlen( buffer ) ;
  wdlg->popup_filter = popup_make( NB_FILTERS, size ) ;
  if ( wdlg->popup_filter == NULL ) { popup_kill( wdlg->popup_tail, wext->nb_params ) ; return ; }

  string = strrchr( buffer, '1' ) ;
  if ( string )
  {
    *string = 0 ;
    strcpy( filter_name, buffer ) ;
    *string = '1' ;
  }
  else strcpy( filter_name, "Filter " ) ;

  for ( i = 0; i < NB_FILTERS; i++ )
  {
    sprintf( buffer, "%s%d", filter_name, i ) ;
    strncpy( wdlg->popup_filter[1+i].ob_spec.free_string, buffer, size ) ;
  }

  /* FP_FILTERTC popup */
  read_text( adr_params, FP_FILTERTC, buffer ) ;
  size = (short) strlen( buffer ) ;
  wdlg->popup_text_color = popup_make( 16, size ) ;
  if ( wdlg->popup_text_color == NULL ) { popup_kill( wdlg->popup_filter, NB_FILTERS ) ; popup_kill( wdlg->popup_tail, wext->nb_params ) ; return ; }

  for ( i = 0; i < 16; i++ )
  {
    sprintf( buffer, "%d", i ) ;
    strncpy( wdlg->popup_text_color[1+i].ob_spec.free_string, buffer, size ) ;
  }

  /* FP_FILTERBC popup */
  read_text( adr_params, FP_FILTERBC, buffer ) ;
  size = (short) strlen( buffer ) ;
  wdlg->popup_back_color = popup_make( 16, size ) ;
  if ( wdlg->popup_back_color == NULL ) { popup_kill( wdlg->popup_text_color, NB_FILTERS ) ; popup_kill( wdlg->popup_filter, NB_FILTERS ) ; popup_kill( wdlg->popup_tail, wext->nb_params ) ; return ; }

  for ( i = 0; i < 16; i++ )
  {
    sprintf( buffer, "%d", i ) ;
    strncpy( wdlg->popup_back_color[1+i].ob_spec.free_string, buffer, size ) ;
  }

  sprintf( buffer, "%04ld", wext->params[wext->selection].MaxBufferSize >> 10 ) ;
  write_text( adr_params, FP_MAXBUFFER, buffer ) ;
  sprintf( buffer, "%04ld", wext->params[wext->selection].TimerMs ) ;
  write_text( adr_params, FP_REFRESH, buffer ) ;
  TWMultipleStringToCommaSep( wext->params[wext->selection].ExcludedKeywords, buffer ) ;
  write_text( adr_params, FP_EXCLUDE, buffer ) ;
  TWMultipleStringToCommaSep( wext->params[wext->selection].HighLightData[wext->filter_no].Keywords, buffer ) ;
  write_text( adr_params, FP_FILTERKW, buffer ) ;

  UpdateColors( wnd, 0 ) ;
}

static void UpdateFromGUI(GEM_WINDOW* wnd)
{
  WEXTENSION_TWPARAMS* wext = wnd->DlgData->UserData ;
  OBJECT*              adr_params = wnd->DlgData->BaseObject ;
  char                 buffer[160] ;

  /* Update text fields to TWINDOW_PARAMS */
  read_text( adr_params, FP_MAXBUFFER, buffer ) ;
  wext->params[wext->selection].MaxBufferSize = atol(buffer) << 10 ;
  read_text( adr_params, FP_REFRESH, buffer ) ;
  wext->params[wext->selection].TimerMs = atol(buffer) ;
  memzero( wext->params[wext->selection].ExcludedKeywords, sizeof(wext->params[0].ExcludedKeywords) ) ;
  read_text( adr_params, FP_EXCLUDE, wext->params[wext->selection].ExcludedKeywords ) ;
  strrep( wext->params[wext->selection].ExcludedKeywords, ',', 0 ) ;
  memzero( wext->params[wext->selection].HighLightData[wext->filter_no].Keywords, sizeof(wext->params[0].HighLightData[0].Keywords) ) ;
  read_text( adr_params, FP_FILTERKW, wext->params[wext->selection].HighLightData[wext->filter_no].Keywords ) ;
  strrep( wext->params[wext->selection].HighLightData[wext->filter_no].Keywords, ',', 0 ) ;
}

static void PopupDo(GEM_WINDOW* wnd, short obj, OBJECT** popup, int* recipient)
{
  OBJECT* adr_params = wnd->DlgData->BaseObject ;
  int     i, off_x, off_y ;

  UpdateFromGUI( wnd ) ;
  deselect( adr_params, obj ) ;
  objc_offset( adr_params, obj, &off_x, &off_y ) ;
  i = popup_formdo( popup, off_x, off_y, 1 + *recipient, -1 ) ;
  if ( i > 0 )
  {
    *recipient = i-1 ;
    UpdateColors( wnd, 1 ) ;
  }
}

static int OnObjectNotify(void* w, int obj)
{
  GEM_WINDOW*          wnd = (GEM_WINDOW*) w ;
  WDLG_PARAM*          wdlg = wnd->Extension ;
  WEXTENSION_TWPARAMS* wext = wnd->DlgData->UserData ;
  int                  i, off_x, off_y ;
  int                  code = -1 ;

  switch( obj )
  {
    case FP_TAIL:     PopupDo( wnd, obj, &wdlg->popup_tail, &wext->selection ) ;
                      break ;
    case FP_FILTERN:  PopupDo( wnd, obj, &wdlg->popup_filter, &wext->filter_no ) ;
                      break ;
    case FP_FILTERTC: PopupDo( wnd, obj, &wdlg->popup_text_color, &wext->params[wext->selection].HighLightData[wext->filter_no].TextType.color ) ;
                      break ;
    case FP_FILTERBC: PopupDo( wnd, obj, &wdlg->popup_back_color, &wext->params[wext->selection].HighLightData[wext->filter_no].TextType.fg_color ) ;
                      break ;
    case FP_OK:       UpdateFromGUI( wnd ) ;
                      code = IDOK ;
                      break ;
    case FP_CANCEL:   code = IDCANCEL ;
                      break ;
  }

  return code ;
}

static int OnCloseDlg(void *w)
{
  GEM_WINDOW*          wnd = (GEM_WINDOW*) w ;
  WDLG_PARAM*          wdlg = wnd->Extension ;
  WEXTENSION_TWPARAMS* wext = wnd->DlgData->UserData ;

  popup_kill( wdlg->popup_back_color, 16 ) ;
  popup_kill( wdlg->popup_text_color, 16 ) ;
  popup_kill( wdlg->popup_filter, NB_FILTERS ) ;
  popup_kill( wdlg->popup_tail, wext->nb_params ) ;

  return( GWCloseDlg( w ) ) ;
}

short form_twparams(TWINDOW_PARAMS* params, short nb_params, short selection)
{
  DLGDATA             dlg_data ;
  WEXTENSION_TWPARAMS wext ;

  wext.params    = params ;
  wext.nb_params = nb_params ;
  wext.selection = selection ;
  wext.filter_no = 0 ;
  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId         = FORM_PARAMS ;
  dlg_data.OnInitDialog   = OnInitDialog ;
  dlg_data.UserData       = &wext ;
  dlg_data.OnObjectNotify = OnObjectNotify ;
  dlg_data.ExtensionSize  = sizeof(WDLG_PARAM) ;
  dlg_data.OnCloseDialog  = OnCloseDlg ;

  return ( GWDoModal( GWCreateDialog( &dlg_data ), FP_MAXBUFFER ) == IDOK ) ;
}
