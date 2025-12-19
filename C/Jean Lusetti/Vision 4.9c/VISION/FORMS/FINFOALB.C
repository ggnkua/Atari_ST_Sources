#include <string.h>
#include "..\tools\gwindows.h"
#include "..\tools\xfile.h"

#include "..\tools\catalog.h"
#include "..\tools\logging.h"

#include "actions.h"
#include "falbum.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif


typedef struct
{
  CATALOG_STATS stats ;
  OBJECT*       popup_categorie ; /* Created by caller */
  HCAT          hCat ;
}
WEXTENSION_ALBINFO ;


void lstd_input(char* text, char* buf)
{
  char *c, *d ;
  char txt_cancel[20] ;

  d = NULL ;
  c = strchr( 1+vMsgTxtGetMsg(MSG_FILENOTEXIST), '[' ) ;
  if ( c != NULL ) d = strchr( c, ']' ) ;
  if ( d != NULL )
  {
    *d = 0 ;
    strcpy( txt_cancel, 1+c ) ;
    *d = ']' ;
    std_input( text, buf, txt_cancel ) ;
  }
  else std_input( text, buf, NULL ) ;
}

static void OnInitDialogAlbInfo(void* w)
{
  GEM_WINDOW*         wnd = (GEM_WINDOW*) w ;
  WEXTENSION_ALBINFO* wext = wnd->DlgData->UserData ;
  CATALOG_HEADER*     catalog_header = catalog_get_header(wext->hCat) ;
  OBJECT*             adr_infos = wnd->DlgData->BaseObject ;
  TEDINFO*            ted ;
  int                 len ;
  char                buf[200] ;

  if ( !catalog_header )
  {
    LoggingDoInvalidhCat() ;
    return ;
  }
  catalog_stats( wext->hCat, &wext->stats ) ;
  write_text( adr_infos, ALBINF_NAME, wext->stats.name ) ;
  write_text( adr_infos, ALBINF_DATE, wext->stats.date ) ;
  write_text( adr_infos, ALBINF_REM1, wext->stats.comment ) ;
  ted = (TEDINFO *) adr_infos[ALBINF_REM1].ob_spec.tedinfo ;
  len = ted->te_txtlen ;
  if ( strlen(wext->stats.comment) > len-1 ) write_text( adr_infos, ALBINF_REM2, &wext->stats.comment[len] ) ;
  else                                       write_text( adr_infos, ALBINF_REM2, "" ) ;
  sprintf(buf, "%ld", wext->stats.nb_records ) ;
  write_text( adr_infos, ALBINF_RECORDS, buf ) ;
  sprintf( buf, "%ld", wext->stats.nb_deleted ) ;
  write_text( adr_infos, ALBINF_DELETED, buf ) ;
  sprintf( buf, "%ld", wext->stats.nb_1plane ) ;
  write_text( adr_infos, ALBINF_NB1P, buf ) ;
  sprintf( buf, "%ld", wext->stats.size_1p ) ;
  write_text( adr_infos, ALBINF_SIZE1P, buf ) ;
  sprintf( buf, "%ld", wext->stats.nb_2plane ) ;
  write_text( adr_infos, ALBINF_NB2P, buf ) ;
  sprintf( buf, "%ld", wext->stats.size_2p ) ;
  write_text( adr_infos, ALBINF_SIZE2P, buf ) ;
  sprintf( buf, "%ld", wext->stats.nb_4plane ) ;
  write_text( adr_infos, ALBINF_NB4P, buf ) ;
  sprintf( buf, "%ld", wext->stats.size_4p ) ;
  write_text( adr_infos, ALBINF_SIZE4P, buf ) ;
  sprintf( buf, "%ld", wext->stats.nb_8plane ) ;
  write_text( adr_infos, ALBINF_NB8P, buf ) ;
  sprintf( buf, "%ld", wext->stats.size_8p ) ;
  write_text( adr_infos, ALBINF_SIZE8P, buf ) ;
  sprintf( buf, "%ld", wext->stats.nb_tc ) ;
  write_text( adr_infos, ALBINF_NBTC, buf ) ;
  sprintf( buf, "%ld", wext->stats.size_tc ) ;
  write_text( adr_infos, ALBINF_SIZETC, buf ) ;

  sprintf( buf, "  %s", catalog_header->category_names[catalog_header->default_categorie] ) ;
  write_text( adr_infos, ALBINF_DEFCAT, buf ) ;

  if ( catalog_header->cat_inifile[0] && FileExist( catalog_header->cat_inifile ) )
  {
    write_text( adr_infos, ALBINF_INICAT, catalog_header->cat_inifile ) ;
    select( adr_infos, ALBINF_RINICAT ) ;
    deselect( adr_infos, ALBINF_RDEFCAT ) ;
  }
  else
  {
    deselect( adr_infos, ALBINF_RINICAT ) ;
    select( adr_infos, ALBINF_RDEFCAT ) ;
  }
}

static int OnObjectNotifyAlbInfo(void* w, int obj)
{
  GEM_WINDOW*         wnd = (GEM_WINDOW*) w ;
  WEXTENSION_ALBINFO* wext = wnd->DlgData->UserData ;
  CATALOG_HEADER*     catalog_header = catalog_get_header(wext->hCat) ;
  OBJECT*             adr_infos = wnd->DlgData->BaseObject ;
  int                 code = -1 ;
  int                 mx, my, clicked ;
  char                buf[200] ;

  if ( !catalog_header )
  {
    LoggingDoInvalidhCat() ;
    return code ;
  }
  switch( obj )
  {
    case ALBINF_DEFCAT : deselect( adr_infos, obj ) ;
                         objc_offset( adr_infos, obj, &mx, &my ) ;
                         clicked = popup_formdo( &wext->popup_categorie, mx, my, 2+catalog_header->default_categorie, -1 ) ;
                         if ( clicked > 1 )
                         {
                           sprintf(buf, "  %s", catalog_header->category_names[clicked-2]) ;
                           write_text( adr_infos, obj, buf ) ;
                           catalog_header->default_categorie = clicked-2 ;
                         }
                         else if ( clicked == 1 )
                         {
                           lstd_input( vMsgTxtGetMsg(MSG_CATENEW), buf ) ;
                           if ( buf[0] )
                           {
                             char tmp[200] ;

                             catalog_header->default_categorie = catalog_addcategory( wext->hCat, buf ) ;
                             wext->popup_categorie = make_category_popup( wnd ) ;
                             sprintf( tmp, "  %s", buf ) ;
                             write_text( adr_infos, obj, tmp ) ;
                           }
                         }
                         GWObjcDraw( wnd, adr_infos, ALBINF_DEFCAT ) ;
    case ALBINF_RDEFCAT:
    case ALBINF_RTDEFCAT:
                         select( adr_infos, ALBINF_RDEFCAT ) ;
                         GWObjcDraw( wnd, adr_infos, ALBINF_RDEFCAT ) ;
                         deselect( adr_infos, ALBINF_RINICAT ) ;
                         GWObjcDraw( wnd, adr_infos, ALBINF_RINICAT ) ;
                         break ;

    case ALBINF_INICAT : buf[0] = 0 ;
                         deselect( adr_infos, obj ) ;
                         if ( file_name( catalog_header->cat_inifile, "", buf ) == 1 )
                           write_text( adr_infos, ALBINF_INICAT, buf ) ;
                         GWObjcDraw( wnd, adr_infos, ALBINF_INICAT ) ;
    case ALBINF_RINICAT:
    case ALBINF_RTINICAT:
                         deselect( adr_infos, ALBINF_RDEFCAT ) ;
                         GWObjcDraw( wnd, adr_infos, ALBINF_RDEFCAT ) ;
                         select( adr_infos, ALBINF_RINICAT ) ;
                         GWObjcDraw( wnd, adr_infos, ALBINF_RINICAT ) ;
                         break ;

    case ALBINF_OK     : code = IDOK ;
                         break ;

    case ALBINF_CANCEL : code = IDCANCEL ;
                         break ;
  }

  if ( code == IDOK )
  {
    if ( selected( adr_infos, ALBINF_RDEFCAT ) ) catalog_header->cat_inifile[0] = 0 ;
    else                                         read_text( adr_infos, ALBINF_INICAT, catalog_header->cat_inifile ) ;
  }

  return code ;
}

int FGetAlbInfo(WEXTENSION_ALBINFO* wext)
{
  DLGDATA dlg_data ;

  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId         = FORM_ALBUMINFO ;
  strcpy( dlg_data.Title, vMsgTxtGetMsg(MSG_WFNAMES) ) ;
  dlg_data.UserData       = wext ;
  dlg_data.OnInitDialog   = OnInitDialogAlbInfo ;
  dlg_data.OnObjectNotify = OnObjectNotifyAlbInfo ;

  return GWCreateAndDoModal( &dlg_data, 0 ) ;
}

int show_infos(HCAT hCat, OBJECT *popup_categorie)
{
  WEXTENSION_ALBINFO wext ;

  wext.popup_categorie = popup_categorie ;
  wext.hCat            = hCat ;

  return( FGetAlbInfo( &wext ) ) ;
}
