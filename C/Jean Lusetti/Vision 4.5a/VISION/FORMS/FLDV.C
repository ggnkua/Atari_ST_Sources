#include <string.h>
#include <stdlib.h>
#include "..\tools\gwindows.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif


#include "actions.h"
#include "visionio.h"
#include "fldv.h"
#include "fldvdet.h"

typedef struct
{
  GEM_WINDOW *Image ;

  int NumLDV ;
  int FirstNumDisplayed ;
}
WEXTENSION_LDV ;

/*#define SML_LDVLIST*/

static LDV_MODULE *LDVList ;
static LDV_MODULE *TotalLDVList ;
static int        NbLDV ;
static int        TotalNbLDV ;


#define NB_MAX_LDV_DISPLAYED (1 + LDV_ITEM8 - LDV_ITEM1)

void setup_ldvlist(GEM_WINDOW *wnd, int display)
{
  WEXTENSION_LDV *wext = wnd->DlgData->UserData ;
  OBJECT         *bobj = wnd->DlgData->BaseObject ;
  int            i, n ;
  char           buf[16] ;

  for ( i = LDV_ITEM1; i <= LDV_ITEM8; i++ ) write_text( bobj, i, "               " ) ;

  if ( LDVList )
  {
    for( i = LDV_ITEM1; i <= LDV_ITEM8; i++ )
    {
      n = wext->FirstNumDisplayed + i - LDV_ITEM1 ;
      if ( n < NbLDV )
      {
        if ( LDVList[n].IniSpec.ShortName )
          sprintf( buf, "%-15s", LDVList[n].IniSpec.ShortName ) ;
        else strcpy( buf, "???" ) ;
        write_text( bobj, i, buf ) ;
      }
      else break ; /* Sortie */
    }
  }

  if ( NbLDV > 0 )
  {
    if ( NbLDV > NB_MAX_LDV_DISPLAYED )
    {
      bobj[LDV_SLIDER].ob_height  = NB_MAX_LDV_DISPLAYED * bobj[LDV_BOX].ob_height ;
      bobj[LDV_SLIDER].ob_height /= NbLDV ;
    }
    else
      bobj[LDV_SLIDER].ob_height  = bobj[LDV_BOX].ob_height ;
    bobj[LDV_SLIDER].ob_y       = wext->FirstNumDisplayed * bobj[LDV_BOX].ob_height ;
    bobj[LDV_SLIDER].ob_y      /= NbLDV ;
  }
  else
  {
    bobj[LDV_SLIDER].ob_height = bobj[LDV_BOX].ob_height ;
    bobj[LDV_SLIDER].ob_y      = 0 ;
  }

  if ( display )
  {
    xobjc_draw( wnd->window_handle, bobj, LDV_BOX ) ;
    for ( i = LDV_ITEM1; i <= LDV_ITEM8; i++ )
      xobjc_draw( wnd->window_handle, bobj, i ) ;
  }
}

void display_ldvinfos(GEM_WINDOW *wnd)
{
  LDV_MODULE     *ldv ;
  LDV_INFOS      *ldv_infos ;
  LDV_INI_SPEC   *ldv_lspec ;
  WEXTENSION_LDV *wext = wnd->DlgData->UserData ;
  VXIMAGE        *vximage = wext->Image->Extension ;
  OBJECT         *bobj = wnd->DlgData->BaseObject ;
  TEDINFO        *ted ;
  int            i, num ;
  char           *pt, c ;
  char           buf[100] ;

  num = 0 ;
  for ( i = LDV_ITEM1; i <= LDV_ITEM8; i++ )
    if ( selected( bobj, i ) ) num = wext->FirstNumDisplayed + i - LDV_ITEM1 ;

  if ( ( LDVList == NULL ) || ( num >= NbLDV ) )
  {
    write_text( bobj, LDV_LONGNAME, " " ) ;
    write_text( bobj, LDV_TYPE, " " ) ;
    write_text( bobj, LDV_VERSION, " " ) ;
    write_text( bobj, LDV_AUTHORS, " " ) ;
    write_text( bobj, LDV_DESC1, " " ) ;
    write_text( bobj, LDV_DESC2, " " ) ;
    bobj[LDV_SELECT].ob_state |= DISABLED ;
    bobj[LDV_DETAIL].ob_state |= DISABLED ;
  }
  else
  {
    wext->NumLDV = num ;
    ldv          = &LDVList[wext->NumLDV] ;
    ldv_infos = &ldv->Infos ;
    ldv_lspec = &ldv->IniSpec ;

    write_text( bobj, LDV_LONGNAME, ldv_lspec->LongName ) ;
    sprintf( buf, "%d", ldv_infos->Type ) ;
    write_text( bobj, LDV_TYPE, buf ) ;
    sprintf( buf, "%02x.%02x", (ldv->Version & 0xFF00) >> 8, ldv->Version & 0x00FF ) ;
    write_text( bobj, LDV_VERSION, buf ) ;
    write_text( bobj, LDV_AUTHORS, ldv_infos->Authors ) ;
    ted = bobj[LDV_DESC1].ob_spec.tedinfo ;
    if ( ldv_lspec->Description && ( strlen( ldv_lspec->Description ) > ted->te_txtlen ) )
    {
      pt = ldv_lspec->Description + ted->te_txtlen - 1 ;
      while ( ( pt > ldv_lspec->Description ) && ( *pt != ' ' ) ) pt-- ;
      if ( pt == ldv_lspec->Description ) pt = ldv_lspec->Description + ted->te_txtlen ;
      c   = *pt ;
      *pt = 0 ;
      write_text( bobj, LDV_DESC1, ldv_lspec->Description ) ;
      *pt = c ;
      if ( c == ' ' ) write_text( bobj, LDV_DESC2, 1+pt ) ;
      else            write_text( bobj, LDV_DESC2, pt ) ;
    }
    else
    {
      write_text( bobj, LDV_DESC1, ldv_lspec->Description ) ;
      write_text( bobj, LDV_DESC2, "" ) ;
    }
    if ( LDVGetNPlanesCaps( ldv, vximage->raster.fd_nplanes ) == NULL )
    {
      bobj[LDV_SELECT].ob_state |= DISABLED ;
/*      bobj[LDV_DETAIL].ob_state |= DISABLED ;*/
    }
    else
    {
      bobj[LDV_SELECT].ob_state &= ~DISABLED ;
/*      bobj[LDV_DETAIL].ob_state &= ~DISABLED ;*/
    }
  }

  xobjc_draw( wnd->window_handle, bobj, LDV_LONGNAME ) ;
  xobjc_draw( wnd->window_handle, bobj, LDV_TYPE ) ;
  xobjc_draw( wnd->window_handle, bobj, LDV_VERSION ) ;
  xobjc_draw( wnd->window_handle, bobj, LDV_AUTHORS ) ;
  xobjc_draw( wnd->window_handle, bobj, LDV_DESC1 ) ;
  xobjc_draw( wnd->window_handle, bobj, LDV_DESC2 ) ;
  xobjc_draw( wnd->window_handle, bobj, LDV_SELECT ) ;
  xobjc_draw( wnd->window_handle, bobj, LDV_DETAIL ) ;
}

#ifdef SML_LDVLIST
#include "ldv\smlldv.h"
#endif

void InitLDVList(GEM_WINDOW *wnd, char *path_ldv)
{
  WEXTENSION_LDV *wext = wnd->DlgData->UserData ;
  LDV_MODULE     *mod ;
  VXIMAGE        *vimage = NULL ;
  OBJECT         *bobj = wnd->DlgData->BaseObject ;

  if ( strcmpi( wext->Image->ClassName, VIMG_CLASSNAME ) == 0 ) vimage = wext->Image->Extension ;
  if ( TotalLDVList == NULL )
  {
#ifdef SML_LDVLIST
    TotalLDVList = SmlLDVGetModuleList( path_ldv, &TotalNbLDV ) ;
#else
    TotalLDVList = LDVGetModuleList( path_ldv, &TotalNbLDV ) ;
#endif
  }

  if ( LDVList ) Xfree( LDVList ) ;
  LDVList = NULL ;
  if ( TotalNbLDV > 0 )
  {
    LDVList = (LDV_MODULE *) Xcalloc( 1 + TotalNbLDV, sizeof(LDV_MODULE) ) ;
    if ( LDVList )
    {
      if ( selected( bobj, LDV_COMPAT ) )
      {
       int i ;

        NbLDV = 0 ;
        mod   = TotalLDVList ;
        for ( i = 0; i < TotalNbLDV; i++, mod++ )
        {
          if ( vimage && LDVGetNPlanesCaps( mod, vimage->raster.fd_nplanes ) )
            memcpy( &LDVList[NbLDV++], mod, sizeof(LDV_MODULE) ) ;
        }
      }
      else
      {
        memcpy( LDVList, TotalLDVList, TotalNbLDV*sizeof(LDV_MODULE) ) ;
        NbLDV = TotalNbLDV ;
      }
    }
  }
}

static void OnInitDialog(void *w)
{
  GEM_WINDOW     *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_LDV *wext = wnd->DlgData->UserData ;

  wext->NumLDV            = 0 ;
  wext->FirstNumDisplayed = 0 ;

  InitLDVList( wnd, config.path_ldv ) ;

  setup_ldvlist( wnd, 0 ) ;

  display_ldvinfos( wnd ) ;
}

static int OnObjectNotify(void *w, int obj)
{
  GEM_WINDOW     *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_LDV *wext = wnd->DlgData->UserData ;
  OBJECT         *bobj = wnd->DlgData->BaseObject ;
  float          pc, hf ;
  int            off_y ;
  int            my, dummy ;
  int            code = -1 ;

  switch( obj )
  {
     case LDV_DETAIL : if ( LDVList && ( wext->NumLDV >= 0 ) && ( wext->NumLDV < NbLDV ) )
                         LDVDetails( &LDVList[wext->NumLDV] ) ;
                       deselect( bobj, obj ) ;
                       xobjc_draw( wnd->window_handle, bobj, obj ) ;
                       break ;

     case LDV_REFRESH: LDVFreeAllModules() ;
                       InitLDVList( wnd, config.path_ldv ) ;
                       setup_ldvlist( wnd, 1 ) ;
                       display_ldvinfos( wnd ) ;
                       deselect( bobj, obj ) ;
                       xobjc_draw( wnd->window_handle, bobj, obj ) ;
                       break ;

     case LDV_TCOMPAT: inv_select( bobj, LDV_COMPAT ) ;
                       xobjc_draw( wnd->window_handle, bobj, LDV_COMPAT ) ;
     case LDV_COMPAT : InitLDVList( wnd, config.path_ldv ) ;
                       setup_ldvlist( wnd, 1 ) ;
                       display_ldvinfos( wnd ) ;
                       break ;

     case LDV_MOINS  : if ( wext->FirstNumDisplayed > 0 )
                       {
                         wext->FirstNumDisplayed-- ;
                         setup_ldvlist( wnd, 1 ) ;
                         display_ldvinfos( wnd ) ;
                       }
                       deselect( bobj, obj ) ;
                       xobjc_draw( wnd->window_handle, bobj, obj ) ;
                       break ;

     case LDV_PLUS   : if ( wext->FirstNumDisplayed + NB_MAX_LDV_DISPLAYED <= NbLDV - 1 )
                       {
                         wext->FirstNumDisplayed++ ;
                         setup_ldvlist( wnd, 1 ) ;
                         display_ldvinfos( wnd ) ;
                       }
                       deselect( bobj, obj ) ;
                       xobjc_draw( wnd->window_handle, bobj, obj ) ;
                       break ;

     case LDV_BOX    : objc_offset( bobj, LDV_SLIDER, &dummy, &off_y ) ;
                       graf_mkstate( &dummy, &my, &dummy, &dummy ) ;
                       if ( my < off_y ) wext->FirstNumDisplayed -= NB_MAX_LDV_DISPLAYED ;
                       else              wext->FirstNumDisplayed += NB_MAX_LDV_DISPLAYED ;
                       if ( wext->FirstNumDisplayed + NB_MAX_LDV_DISPLAYED > NbLDV )
                         wext->FirstNumDisplayed = NbLDV - NB_MAX_LDV_DISPLAYED ;
                       if ( wext->FirstNumDisplayed < 0 ) wext->FirstNumDisplayed = 0 ;
                       setup_ldvlist( wnd, 1 ) ;
                       display_ldvinfos( wnd ) ;
                       deselect( bobj, obj ) ;
                       xobjc_draw( wnd->window_handle, bobj, obj ) ;
                       break ;

     case LDV_SLIDER : hf    = (float) (bobj[LDV_BOX].ob_height - bobj[LDV_SLIDER].ob_height) ;
                       pc    = (float) graf_slidebox( bobj, LDV_BOX, LDV_SLIDER, 1 ) ;
                       pc    = (1000.0-pc)/10.0 ;
                       off_y = (int) ((100.0-pc)*hf/100.0) ;
                       bobj[LDV_SLIDER].ob_y = off_y ;
                       wext->FirstNumDisplayed = (int) ((float)off_y*(float)(NbLDV-1-LDV_ITEM8+LDV_ITEM1)/hf) ;
                       if ( wext->FirstNumDisplayed + NB_MAX_LDV_DISPLAYED > NbLDV )
                         wext->FirstNumDisplayed = NbLDV - NB_MAX_LDV_DISPLAYED ;
                       if ( wext->FirstNumDisplayed < 0 ) wext->FirstNumDisplayed = 0 ;
                       setup_ldvlist( wnd, 1 ) ;
                       display_ldvinfos( wnd ) ;
                       deselect( bobj, obj ) ;
                       xobjc_draw( wnd->window_handle, bobj, obj ) ;
                       break ;

     case LDV_ITEM1  :
     case LDV_ITEM2  :
     case LDV_ITEM3  :
     case LDV_ITEM4  :
     case LDV_ITEM5  :
     case LDV_ITEM6  :
     case LDV_ITEM7  :
     case LDV_ITEM8  : display_ldvinfos( wnd ) ;
                       break ;

     case LDV_SELECT : code = IDOK ;
                       break ;

     case LDV_CLOSE  : code = IDCANCEL ;
                       break ;
  }

  if ( code == IDOK )
  {
    if ( ( wext->NumLDV < 0 ) || ( wext->NumLDV >= NbLDV ) ) code = IDCANCEL ;
  }

  return( code ) ;
}

LDV_MODULE *LDVSelect(GEM_WINDOW *wnd)
{
  LDV_MODULE     *module = NULL ;
  GEM_WINDOW     *dlg ;
  WEXTENSION_LDV wext ;
  DLGDATA        dlg_data ;
  int            code ;

  wext.Image = wnd ;
  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
  dlg_data.RsrcId       = FORM_LDV ;
  strcpy( dlg_data.Title, MsgTxtGetMsg(hMsg, MSG_WFNAMES)  ) ;
  dlg_data.UserData       = &wext ;
  dlg_data.OnInitDialog   = OnInitDialog ;
  dlg_data.OnObjectNotify = OnObjectNotify ;

  dlg  = GWCreateDialog( &dlg_data ) ;
  code = GWDoModal( dlg, 0 ) ;

  if ( code == IDOK )
  {
    module = &LDVList[wext.NumLDV] ;
    if ( !LDV_SUCCESS( LDVLoadFunctions( config.path_ldv, module ) ) ) module = NULL ;
  }

  return( module ) ;
}

void LDVFreeAllModules(void)
{
  if ( LDVList ) Xfree( LDVList ) ;
  LDVList = NULL ;
  NbLDV   = 0 ;

#ifdef SML_LDVLIST
  if ( TotalLDVList ) Xfree( TotalLDVList ) ;
#else
  if ( TotalLDVList ) LDVFreeModuleList( TotalLDVList ) ;
#endif
  TotalLDVList = NULL ;
  TotalNbLDV   = 0 ;
}

void LDVTerminate(LDG *ldg)
{
  LDV_MODULE *ldv ;

  ldv = GetLdvByLdg( TotalLDVList, ldg ) ;
  if ( ldv )
  {
    ldg_term( ap_id, ldv->Ldg ) ;
    memset( ldv, 0, sizeof(LDV_MODULE) ) ;
  }
}
