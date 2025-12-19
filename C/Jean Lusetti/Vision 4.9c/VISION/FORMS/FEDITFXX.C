#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "..\tools\gwindows.h"

#include "..\tools\convol.h"

#include "defs.h"
/*#include "actions.h"*/
#include "ffilter.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  CONVOLUTION_FILTRE* in_filter ;
  CONVOLUTION_FILTRE  filter ;
  char                data[25] ;
  short               size ;

  /* Specific dialog object IDs, depennding on filter sirze (3x3 or 5x5) */
  short obj_fname ;
  short obj_fdesc ;
  short obj_fefirst ;
  short obj_felast ;
  short obj_fsave ;
  short obj_fcancel ;
}
WEXTENSION_FXX ;


static void OnInitDialogFxx(void* w)
{
  GEM_WINDOW*     wnd = (GEM_WINDOW*) w ;
  WEXTENSION_FXX* wext = wnd->DlgData->UserData ;
  OBJECT*         adr_filter = wnd->DlgData->BaseObject ;
  int             bouton ;
  char            buf[PATH_MAX] ;

  /* Assume a 3x3 filter */
  if ( wext->size == 3 )
  {
    wext->obj_fname   = FILTRE33_NAME ;
    wext->obj_fdesc   = FILTRE33_DESCRIP ;
    wext->obj_fefirst = FILTRE33_E1 ;
    wext->obj_felast  = FILTRE33_ELAST ;
    wext->obj_fsave   = FILTRE33_SAVE ;
    wext->obj_fcancel = FILTRE33_CANCEL ;
  }
  else
  {
    wext->obj_fname   = FILTRE55_NAME ;
    wext->obj_fdesc   = FILTRE55_DESCRIP ;
    wext->obj_fefirst = FILTRE55_E1 ;
    wext->obj_felast  = FILTRE55_ELAST ;
    wext->obj_fsave   = FILTRE55_SAVE ;
    wext->obj_fcancel = FILTRE55_CANCEL ;
  }

  if ( wext->in_filter == NULL )
  {
    wext->filter.w    = wext->filter.h = wext->size ;
    wext->filter.data = wext->data ;
    write_text( adr_filter, wext->obj_fname, "" ) ;
    write_text( adr_filter, wext->obj_fdesc, "" ) ;
  }
  else
  {
    char* pt ;

    memcpy( &wext->filter, wext->in_filter, sizeof(CONVOLUTION_FILTRE) ) ;
    write_text( adr_filter, wext->obj_fname, wext->filter.name ) ;
    write_text( adr_filter, wext->obj_fdesc, wext->filter.description ) ;
    pt = (char*) wext->filter.data ;
    for ( bouton = wext->obj_fefirst; bouton <= wext->obj_felast; bouton++ )
    {
      sprintf( buf, "%+.2d", *pt++ ) ;
      write_text( adr_filter, bouton, buf ) ;
    }
  }
}

static int OnObjectNotifyFxx(void* w, int obj)
{
  GEM_WINDOW*     wnd = (GEM_WINDOW*) w ;
  WEXTENSION_FXX* wext = wnd->DlgData->UserData ;
  OBJECT*         adr_filter = wnd->DlgData->BaseObject ;
  int             bouton, code = -1 ;
  char            buf[PATH_MAX] ;

  if ( obj == wext->obj_fsave )
  {
    code = IDOK ;
    for ( bouton = wext->obj_fefirst; bouton <= wext->obj_felast; bouton++ )
    {
      read_text( adr_filter, bouton, buf ) ;
      wext->filter.data[bouton-wext->obj_fefirst] = atoi( buf ) ;
    }
    read_text( adr_filter, wext->obj_fname, wext->filter.name ) ;
    read_text( adr_filter, wext->obj_fdesc, wext->filter.description ) ;
  }
  else if ( obj == wext->obj_fcancel ) code = IDCANCEL ;

  return code ;
}

static int FGetFilterxx(WEXTENSION_FXX* wext)
{
  DLGDATA dlg_data ;

  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId       = (wext->size == 3) ? FORM_FILTRE33:FORM_FILTRE55 ;
  strcpy( dlg_data.Title, vMsgTxtGetMsg(MSG_WFNAMES) ) ;
  dlg_data.UserData       = wext ;
  dlg_data.OnInitDialog   = OnInitDialogFxx ;
  dlg_data.OnObjectNotify = OnObjectNotifyFxx ;

  return GWCreateAndDoModal( &dlg_data, 0 ) ;
}

void edit_filterxx(CONVOLUTION_FILTRE* in_filter, short size)
{
  WEXTENSION_FXX wext ;
  char           nom[PATH_MAX] ;
  char           buf[PATH_MAX] ;
  char           path_filter[PATH_MAX] ;

  wext.in_filter = in_filter ;
  wext.size      = size ;
  if ( FGetFilterxx( &wext ) != IDOK ) return ;

  GetFilterPathForLanguage( path_filter, 0 ) ;
  sprintf( buf, "%s\\*.VCF", path_filter ) ;
  if ( file_name( buf, "", nom ) )
    if ( convolution_savefilter( nom, &wext.filter ) == -1 ) vform_stop( MSG_WRITEERROR ) ;
}
