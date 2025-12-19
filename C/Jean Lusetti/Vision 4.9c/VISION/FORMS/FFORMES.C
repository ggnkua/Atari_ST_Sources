#include <string.h>
#include "..\tools\gwindows.h"

#include "actions.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  LINE_TYPE   ligne ;
  MARKER_TYPE marker ;
  FILL_TYPE   fill ;

  int         ind_fill ;
}
WEXTENSION_FORMES ;


static int cdecl draw_pattern(PARMBLK* paramblk)
{
  WEXTENSION_FORMES* wext = (WEXTENSION_FORMES*) paramblk->pb_parm ;
  int                xy[4] ;
  
  xy[0] = paramblk->pb_x ;
  xy[1] = paramblk->pb_y ;
  xy[2] = paramblk->pb_x+paramblk->pb_w-1 ;
  xy[3] = paramblk->pb_y+paramblk->pb_h-1 ;
  svs_clipON( xy ) ;
  (void)svswr_mode( MD_REPLACE ) ;
  set_filltype( &wext->fill ) ;
  GWHideCursor() ;
  v_bar( handle, xy ) ;
  GWShowCursor() ;
  svs_clipOFF( xy ) ;

  return 0 ;
}

static int cdecl draw_line(PARMBLK* paramblk)
{
  WEXTENSION_FORMES* wext = (WEXTENSION_FORMES*) paramblk->pb_parm ;
  int                xy[4] ;
  int                x1, y1, x2 ;

  xy[0] = paramblk->pb_x ;
  xy[1] = paramblk->pb_y ;
  xy[2] = paramblk->pb_x+paramblk->pb_w-1 ;
  xy[3] = paramblk->pb_y+paramblk->pb_h-1 ;
  svs_clipON( xy ) ;
  svswr_mode( MD_REPLACE ) ;
  svsf_interior( FIS_SOLID ) ;
  svsf_color( 0 ) ;
  x1 = paramblk->pb_x+8 ;
  y1 = paramblk->pb_y+(paramblk->pb_h>>1) ;
  x2 = paramblk->pb_x+paramblk->pb_w-8 ;
  set_linetype( &wext->ligne ) ;
  set_markertype( &wext->marker ) ;
  GWHideCursor() ;
  svr_recfl( xy ) ;
  line( x1, y1, x2, y1 ) ;
  GWShowCursor() ;
  svs_clipOFF( xy ) ;

  return 0 ;
}

static int cdecl draw_point(PARMBLK* paramblk)
{
  WEXTENSION_FORMES* wext = (WEXTENSION_FORMES*) paramblk->pb_parm ;
  int                xy[4] ;
  int                x, y ;

  xy[0] = paramblk->pb_x ;
  xy[1] = paramblk->pb_y ;
  xy[2] = paramblk->pb_x+paramblk->pb_w-1 ;
  xy[3] = paramblk->pb_y+paramblk->pb_h-1 ;
  svs_clipON( xy ) ;
  svswr_mode( MD_REPLACE ) ;
  svsf_interior( FIS_SOLID ) ;
  svsf_color( 0 ) ;
  x = paramblk->pb_x+(paramblk->pb_w>>1) ;
  y = paramblk->pb_y+(paramblk->pb_h>>1) ;
  set_markertype( &wext->marker ) ;
  GWHideCursor() ;
  svr_recfl( xy ) ;
  pset( x, y ) ;
  GWShowCursor() ;
  svs_clipOFF( xy ) ;

  return 0 ;
}

static void OnInitDialogFormes(void* w)
{
  GEM_WINDOW*        wnd = (GEM_WINDOW*) w ;
  WEXTENSION_FORMES* wext = wnd->DlgData->UserData ;
  OBJECT*            adr_forme = wnd->DlgData->BaseObject ;

  adr_forme[FORME_REMPLIS].ob_spec.userblk->ub_code = draw_pattern ;
  adr_forme[FORME_REMPLIS].ob_spec.userblk->ub_parm = (long) wext ;
  adr_forme[FORM_LIGNE].ob_spec.userblk->ub_code    = draw_line ;
  adr_forme[FORM_LIGNE].ob_spec.userblk->ub_parm    = (long) wext ;
  adr_forme[FORM_POINT].ob_spec.userblk->ub_code    = draw_point ;
  adr_forme[FORM_POINT].ob_spec.userblk->ub_parm    = (long) wext ;

  memcpy( &wext->ligne, &ltype, sizeof(LINE_TYPE) ) ;
  memcpy( &wext->marker, &mtype, sizeof(MARKER_TYPE) ) ;
  memcpy( &wext->fill, &ftype, sizeof(FILL_TYPE) ) ;
  wext->ind_fill = ftype.sindex ;
  if ( ftype.style == FIS_HATCH ) wext->ind_fill += 24 ;
  checkbox_setstate( ftype.perimeter, adr_forme, SURF_PERI ) ;
  checkbox_setstate( config.flags & FLG_SROUND, adr_forme, SURF_PERI ) ;
}

static int OnObjectNotifyFormes(void* w, int obj)
{
  GEM_WINDOW*        wnd = (GEM_WINDOW*) w ;
  WEXTENSION_FORMES* wext = wnd->DlgData->UserData ;
  OBJECT*            adr_forme = wnd->DlgData->BaseObject ;
  int                x, y ;
  int                code = -1 ;

  switch( obj )
  {
      case REMPLIS_MOINS :
      case REMPLIS_PLUS  : objc_offset( adr_forme, FORME_REMPLIS, &x, &y ) ;
                           if ( obj == REMPLIS_MOINS ) wext->ind_fill-- ;
                           else                        wext->ind_fill++ ;
                           if ( wext->ind_fill > 24+12 ) wext->ind_fill = 1 ;
                           if ( wext->ind_fill <= 0 )    wext->ind_fill = 24+12 ;
                           if ( wext->ind_fill > 24 )
                           {
                             wext->fill.style  = FIS_HATCH ;
                             wext->fill.sindex = wext->ind_fill-24 ;
                           }
                           else
                           {
                             wext->fill.style  = FIS_PATTERN ;
                             wext->fill.sindex = wext->ind_fill ;
                           }
                           GWObjcDraw( wnd, adr_forme, FORME_REMPLIS ) ;
                           break ;
      case EPAIS_LMOINS  :
      case EPAIS_LPLUS   : if ( obj == EPAIS_LMOINS ) wext->ligne.width -= 2 ;
                           else                       wext->ligne.width += 2 ;
                           if ( wext->ligne.width < 1 ) wext->ligne.width = 1 ;
                           GWObjcDraw( wnd, adr_forme, FORM_LIGNE ) ;
                           break ;
      case MOTIF_LMOINS  :
      case MOTIF_LPLUS   : if ( obj == MOTIF_LMOINS ) wext->ligne.style-- ;
                           else                       wext->ligne.style++ ;
                           if ( wext->ligne.style < 1 ) wext->ligne.style = 1 ;
                           if ( wext->ligne.style > 6 ) wext->ligne.style = 6 ;
                           GWObjcDraw( wnd, adr_forme, FORM_LIGNE ) ;
                           break ;
      case EXTREM_LMOINS :
      case EXTREM_LPLUS  : if ( obj == EXTREM_LMOINS ) wext->ligne.st_kind-- ;
                           else                        wext->ligne.st_kind++ ;
                           if ( wext->ligne.st_kind < 0 ) wext->ligne.st_kind = 0 ;
                           if ( wext->ligne.st_kind > 2 ) wext->ligne.st_kind = 2 ;
                           GWObjcDraw( wnd, adr_forme, FORM_LIGNE ) ;
                           break ;
      case ED_LMOINS     :
      case ED_LPLUS      : if ( obj == ED_LMOINS ) wext->ligne.ed_kind-- ;
                           else                    wext->ligne.ed_kind++ ;
                           if ( wext->ligne.ed_kind < 0 ) wext->ligne.ed_kind = 0 ;
                           if ( wext->ligne.ed_kind > 2 ) wext->ligne.ed_kind = 2 ;
                           GWObjcDraw( wnd, adr_forme, FORM_LIGNE ) ;
                           break ;
      case TYPE_PMOINS   :
      case TYPE_PPLUS    : if ( obj == TYPE_PMOINS ) wext->marker.style-- ;
                           else                      wext->marker.style++ ;
                           if ( wext->marker.style < 1 ) wext->marker.style = 1 ;
                           if ( wext->marker.style > 6 ) wext->marker.style = 6 ;
                           GWObjcDraw( wnd, adr_forme, FORM_POINT ) ;
                           break ;
      case H_PMOINS      :
      case H_PPLUS       : if ( obj == H_PMOINS ) wext->marker.height -= 6 ;
                           else                   wext->marker.height += 6 ;
                           GWObjcDraw( wnd, adr_forme, FORM_POINT ) ;
                           break ;
       case SURF_TROUND  : inv_select( adr_forme, SURF_ROUND ) ;
                           break ;
       case SURF_TPERI   : inv_select( adr_forme, SURF_PERI ) ;
                           break ;
     case FORME_OK     :   code = IDOK ;
                           break ;
     case FORME_CANCEL :   code = IDCANCEL ;
                           break ;
  }

  deselect( adr_forme, obj ) ;
  GWObjcDraw( wnd, adr_forme, obj ) ;

  if ( code == IDOK )
  {
    memcpy( &ltype, &wext->ligne, sizeof(LINE_TYPE) ) ;
    memcpy( &mtype, &wext->marker, sizeof(MARKER_TYPE) ) ;  
    memcpy( &ftype, &wext->fill, sizeof(FILL_TYPE) ) ;
    if ( selected(adr_forme, SURF_PERI) ) ftype.perimeter = 1 ;
    else                                  ftype.perimeter = 0 ;
    if ( selected(adr_forme, SURF_ROUND) ) config.flags |= FLG_SROUND ;
    else                                   config.flags &= ~FLG_SROUND ;
  }

  return code ;
}

void traite_pformes(void)
{
  WEXTENSION_FORMES wext ;
  DLGDATA           dlg_data ;

  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId         = FORM_FORMES ;
  strcpy( dlg_data.Title, vMsgTxtGetMsg(MSG_WFNAMES)  ) ;
  dlg_data.UserData       = &wext ;
  dlg_data.OnInitDialog   = OnInitDialogFormes ;
  dlg_data.OnObjectNotify = OnObjectNotifyFormes ;

  GWCreateAndDoModal( &dlg_data, 0 ) ;
}
