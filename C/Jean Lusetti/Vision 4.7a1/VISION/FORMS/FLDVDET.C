#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "..\tools\gwindows.h"
#include "..\tools\xfile.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

#include "actions.h"

#include "ldv\ldvcom.h"

typedef struct
{
  LDV_MODULE *LdvModule ;
  int        inplanes ;
}
WEXTENSION_LDVDETAIL ;

typedef struct
{
  OBJECT *popup_nplanes ;
}
WDLG_LDVDETAIL ;


static char nplanes[] = { 1, 2, 4, 8, 16, 24, 32 } ;


void setup_details(GEM_WINDOW *wnd, int display)
{
  WEXTENSION_LDVDETAIL *wext = wnd->DlgData->UserData ;
  LDV_CAPS             *caps = NULL ;
  OBJECT               *bobj = wnd->DlgData->BaseObject ;
  int                  nbplanes ;
  char                 buf[100] ;

  read_text( bobj, LDVD_NPLANES, buf ) ;
  nbplanes = atoi( buf ) ;
  if ( nbplanes > 0 ) caps = LDVGetNPlanesCaps( wext->LdvModule, nbplanes ) ;

  if ( caps )
  {
    bobj[LDVD_NPLANES].ob_state &= ~DISABLED ;
    sprintf( buf, "%d", caps->NbPlanesOut ) ;
    write_text( bobj, LDVD_NBPLANESOUT, buf ) ;

    buf[0] = 0 ;
    if ( caps->Flags & LDVF_STDFORMAT ) strcat( buf, MsgTxtGetMsg(hMsg, MSG_LDVSTDFMT)  ) ;
    if ( caps->Flags & LDVF_ATARIFORMAT ) strcat( buf, MsgTxtGetMsg(hMsg, MSG_LDVATARIFMT)  ) ;
    if ( caps->Flags & LDVF_SPECFORMAT ) strcat( buf, MsgTxtGetMsg(hMsg, MSG_LDVSPECFMT)  ) ;
    write_text( bobj, LDVD_FORMAT, buf ) ;

    buf[0] = 0 ;
    if ( caps->Flags & LDVF_SUPPORTPREVIEW ) strcat( buf, MsgTxtGetMsg(hMsg, MSG_LDVSUPPREV)  ) ;
    if ( caps->Flags & LDVF_SUPPORTPROG ) strcat( buf, MsgTxtGetMsg(hMsg, MSG_LDVSUPPROG)  ) ;
    write_text( bobj, LDVD_SUPPORT, buf ) ;

    if ( caps->Flags & LDVF_REALTIMEPARAMS )
      bobj[LDVD_RTPREVIEW].ob_flags &= ~HIDETREE ;
    else
      bobj[LDVD_RTPREVIEW].ob_flags |= HIDETREE ;

    if ( caps->Flags & LDVF_OPINPLACE )
      bobj[LDVD_OPINPLACE].ob_flags &= ~HIDETREE ;
    else
      bobj[LDVD_OPINPLACE].ob_flags |= HIDETREE ;

    if ( ( caps->NbPlanes <= 8 ) && ( caps->Flags & LDVF_AFFECTPALETTE ) )
      bobj[LDVD_AFFECTPAL].ob_flags &= ~HIDETREE ;
    else
      bobj[LDVD_AFFECTPAL].ob_flags |= HIDETREE ;

    if ( caps->Flags & LDVF_SUPPORTCANCEL )
      bobj[LDVD_CANCEL].ob_flags &= ~HIDETREE ;
    else
      bobj[LDVD_CANCEL].ob_flags |= HIDETREE ;
  }
  else
  {
    write_text( bobj, LDVD_NBPLANESOUT, "~" ) ;
    write_text( bobj, LDVD_FORMAT, "~" ) ;
    write_text( bobj, LDVD_SUPPORT, "~" ) ;
    bobj[LDVD_AFFECTPAL].ob_flags |= HIDETREE ;
    caps = LDVGetNPlanesCaps( wext->LdvModule, 1 ) ;
    if ( caps == NULL ) caps = LDVGetNPlanesCaps( wext->LdvModule, 2 ) ;
    if ( caps == NULL ) caps = LDVGetNPlanesCaps( wext->LdvModule, 4 ) ;
    if ( caps == NULL ) caps = LDVGetNPlanesCaps( wext->LdvModule, 8 ) ;
    if ( caps == NULL ) caps = LDVGetNPlanesCaps( wext->LdvModule, 16 ) ;
    if ( caps == NULL ) caps = LDVGetNPlanesCaps( wext->LdvModule, 24 ) ;
    if ( caps == NULL ) caps = LDVGetNPlanesCaps( wext->LdvModule, 32 ) ;

    if ( caps == NULL ) bobj[LDVD_NPLANES].ob_state |= DISABLED ;
  }

  if ( display )
  {
    xobjc_draw( wnd->window_handle, bobj, LDVD_GROUPDET ) ;
    xobjc_draw( wnd->window_handle, bobj, LDVD_TFEATURES ) ;
  }
}

void GetLDVLanguages(LDV_MODULE *ldv, char *buf)
{
  DTA  dta, *old_dta ;
  char name[PATH_MAX] ;
  char ini_name[PATH_MAX] ;
  char ldv_nameextini[50] ;
  char *dot ;
  int  ret ;

  if ( ldv->FileName ) strcpy( ldv_nameextini, ldv->FileName ) ;
  else                 return ;
  dot = strrchr( ldv_nameextini, '.' ) ;
  if ( dot )
  {
    *dot = 0 ;
    strcat( ldv_nameextini, ".INI" ) ;
  }

  sprintf( ini_name, "%s\\%s", config.path_ldv, ldv_nameextini ) ;
  if ( FileExist( ini_name ) ) sprintf( buf, "English " ) ;
  else                         buf[0] = 0 ;

  sprintf( name, "%s\\*.*", config.path_ldv ) ;
  old_dta = Fgetdta() ;
  Fsetdta( &dta ) ;
  ret = Fsfirst( name, FA_SUBDIR ) ;
  while ( ret == 0 )
  {
    if ( ( dta.d_fname[0] != '.' ) && ( dta.d_attrib & FA_SUBDIR ) )
    {
      sprintf( ini_name, "%s\\%s\\%s", config.path_ldv, dta.d_fname, ldv_nameextini ) ;
      if ( FileExist( ini_name ) )
      {
        strlwr( &dta.d_fname[1] ) ;
        strcat( buf, dta.d_fname ) ;
        strcat( buf, " " ) ;
      }
    }
    ret = Fsnext() ;
  }

  Fsetdta( old_dta ) ;
}

static void OnInitDialog(void *w)
{
  GEM_WINDOW           *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_LDVDETAIL *wext = wnd->DlgData->UserData ;
  LDV_MODULE           *ldv = wext->LdvModule ;
  LDV_INFOS            *ldv_infos = &ldv->Infos ;
  LDV_INI_SPEC         *ldv_lspec = &ldv->IniSpec ;
  WDLG_LDVDETAIL       *wdlg = wnd->Extension ;
  OBJECT               *bobj = wnd->DlgData->BaseObject ;
  TEDINFO              *ted ;
  int                  i, nb_nplanes = (int) ( sizeof(nplanes)/sizeof(char) ) ;
  char                 buf[100] ;
  char                 *pt, c ;

  wdlg->popup_nplanes = popup_make( nb_nplanes, 6 ) ;
  if ( wdlg->popup_nplanes == NULL ) return ;

  wext->inplanes = -1 ;
  for ( i = 0; i < nb_nplanes; i++ )
  {
    sprintf( wdlg->popup_nplanes[1+i].ob_spec.free_string, "  %d ", nplanes[i] ) ;
    if ( LDVGetNPlanesCaps( wext->LdvModule, nplanes[i] ) == NULL ) wdlg->popup_nplanes[1+i].ob_state |= DISABLED ;
    else if ( wext->inplanes < 0 ) wext->inplanes = i+1 ;
  }

  if ( wext->inplanes >= 0 ) write_text( bobj, LDVD_NPLANES, wdlg->popup_nplanes[wext->inplanes].ob_spec.free_string ) ;

  write_text( bobj, LDVD_LONGNAME, ldv_lspec->LongName ) ;
  sprintf( buf, "%d", ldv_infos->Type ) ;
  write_text( bobj, LDVD_TYPE, buf ) ;
  sprintf( buf, "%02x.%02x", (ldv->Version & 0xFF00) >> 8, ldv->Version & 0x00FF ) ;
  write_text( bobj, LDVD_VERSION, buf ) ;
  write_text( bobj, LDVD_AUTHORS, ldv_infos->Authors ) ;
  ted = bobj[LDVD_DESC1].ob_spec.tedinfo ;
  if ( ldv_lspec->Description && ( strlen( ldv_lspec->Description ) > ted->te_txtlen ) )
  {
    pt = ldv_lspec->Description + ted->te_txtlen - 1 ;
    while ( ( pt > ldv_lspec->Description ) && ( *pt != ' ' ) ) pt-- ;
    if ( pt == ldv_lspec->Description ) pt = ldv_lspec->Description + ted->te_txtlen ;
    c   = *pt ;
    *pt = 0 ;
    write_text( bobj, LDVD_DESC1, ldv_lspec->Description ) ;
    *pt = c ;
    if ( c == ' ' ) write_text( bobj, LDVD_DESC2, 1+pt ) ;
    else            write_text( bobj, LDVD_DESC2, pt ) ;
  }
  else
  {
    write_text( bobj, LDVD_DESC1, ldv_lspec->Description ) ;
    write_text( bobj, LDVD_DESC2, "" ) ;
  }

  GetLDVLanguages( ldv, buf ) ;
  write_text( bobj, LDVD_LANGUAGES, buf ) ;
  write_text( bobj, LDVD_FILENAME, wext->LdvModule->FileName ) ;

  setup_details( wnd, 0 ) ;
}

static int OnObjectNotify(void *w, int obj)
{
  GEM_WINDOW           *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_LDVDETAIL *wext = wnd->DlgData->UserData ;
  WDLG_LDVDETAIL       *wdlg = wnd->Extension ;
  OBJECT               *bobj = wnd->DlgData->BaseObject ;
  int                  i, off_x, off_y, code = -1 ;

  switch( obj )
  {
     case LDVD_NPLANES : objc_offset( bobj, obj, &off_x, &off_y ) ;
                         i = popup_formdo( &wdlg->popup_nplanes, off_x, off_y, wext->inplanes, -1 ) ;
                         if ( i > 0 ) wext->inplanes = i ;
                         write_text( bobj, obj, wdlg->popup_nplanes[wext->inplanes].ob_spec.free_string ) ;
                         setup_details( wnd, 1 ) ;
                         deselect( bobj, obj ) ;
                         xobjc_draw( wnd->window_handle, bobj, obj ) ;
                         break ;

     case LDVD_CLOSE   : code = IDCANCEL ;
                         break ;
  }

  if ( code == IDOK )
  {

  }

  return( code ) ;
}

int OnCloseDialog(void *w)
{
  GEM_WINDOW     *wnd = (GEM_WINDOW *) w ;
  WDLG_LDVDETAIL *wdlg = wnd->Extension ;

  popup_kill( wdlg->popup_nplanes, (int) (sizeof(nplanes)/sizeof(char) ) ) ;

  return( GWCloseDlg( w ) ) ;
}

void LDVDetails(LDV_MODULE *mod)
{
  GEM_WINDOW           *dlg ;
  WEXTENSION_LDVDETAIL wext ;
  DLGDATA              dlg_data ;
  int                  code ;

  wext.LdvModule = mod ;
  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
  dlg_data.RsrcId       = FORM_LDVDETAIL ;
  strcpy( dlg_data.Title, MsgTxtGetMsg(hMsg, MSG_WFNAMES)  ) ;
  dlg_data.UserData       = &wext ;
  dlg_data.OnInitDialog   = OnInitDialog ;
  dlg_data.OnObjectNotify = OnObjectNotify ;
  dlg_data.OnCloseDialog  = OnCloseDialog ;
  dlg_data.ExtensionSize  = sizeof(WDLG_LDVDETAIL) ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, 0 ) ;

  if ( code == IDOK )
  {

  }
}

