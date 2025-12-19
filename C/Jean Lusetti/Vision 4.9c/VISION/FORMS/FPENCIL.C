#include <string.h>
#include "..\tools\gwindows.h"

#include "actions.h"


#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  PENCIL pencil ;
}
WEXTENSION_PENCIL ;


static int cdecl draw_pencil(PARMBLK* parmblk)
{
  WEXTENSION_PENCIL *wext = (WEXTENSION_PENCIL *) parmblk->pb_parm ;
  int xy[8] ;
  int xc, yc ;

  xy[0] = parmblk->pb_x ;
  xy[1] = parmblk->pb_y ;
  xy[2] = parmblk->pb_x+parmblk->pb_w-1 ;
  xy[3] = parmblk->pb_y+parmblk->pb_h-1 ;
  svs_clipON( xy ) ;
  xc = (xy[0]+xy[2])>>1 ;
  yc = (xy[1]+xy[3])>>1 ;
  svswr_mode( MD_REPLACE ) ;
  svsf_interior( FIS_SOLID ) ;
  svsf_color( 0 ) ;
  svr_recfl( xy ) ;

  svsf_color(  wext->pencil.color) ;
  switch( wext->pencil.type )
  {
    case 0 : xy[0] = xc-(wext->pencil.height>>1) ;
             xy[1] = yc-(wext->pencil.height>>1) ;
             xy[2] = xc+(wext->pencil.height>>1) ;
             xy[3] = yc+(wext->pencil.height>>1) ;
             svr_recfl( xy) ;
             break ;
    case 1 : v_circle( handle, xc, yc, wext->pencil.height>>1 ) ;
             break ;
    case 2 : xy[0] = xc ;
             xy[1] = yc-(wext->pencil.height>>1) ;
             xy[2] = xc+(wext->pencil.height>>1) ;
             xy[3] = yc ;
             xy[4] = xc ;
             xy[5] = yc+(wext->pencil.height>>1) ;
             xy[6] = xc-(wext->pencil.height>>1) ;
             xy[7] = yc ;
             v_fillarea( handle, 4, xy ) ;
             break ;
  }
  svs_clipOFF( xy ) ;

  return 0 ;
}

static void show_pencil(OBJECT* obj, WEXTENSION_PENCIL* wext)
{
  PARMBLK parmblk ;

  objc_offset(obj, PINCEAU_BOX, &parmblk.pb_x, &parmblk.pb_y) ;
  parmblk.pb_w = obj[PINCEAU_BOX].ob_width ; 
  parmblk.pb_h = obj[PINCEAU_BOX].ob_height ; 
  parmblk.pb_parm = (long) wext ;
  draw_pencil( &parmblk ) ;
}

static void OnInitDialogPencil(void* w)
{
  GEM_WINDOW*        wnd = (GEM_WINDOW*) w ;
  WEXTENSION_PENCIL* wext = wnd->DlgData->UserData ;
  OBJECT*            adr_pencil = wnd->DlgData->BaseObject ;

  memcpy( &wext->pencil, &pencil, sizeof(PENCIL) ) ;
  wext->pencil.color = ftype.color ;
  adr_pencil[PINCEAU_BOX].ob_spec.userblk->ub_code = draw_pencil ;
}

static int OnObjectNotifyPencil(void* w, int obj)
{
  GEM_WINDOW*        wnd = (GEM_WINDOW*) w ;
  WEXTENSION_PENCIL* wext = wnd->DlgData->UserData ;
  OBJECT*            adr_pencil = wnd->DlgData->BaseObject ;
  int                code = -1 ;

  switch( obj )
  {

      case PINCEAU_TMOINS:
      case PINCEAU_TPLUS : if ( obj == PINCEAU_TPLUS ) wext->pencil.height++ ;
                           else                        wext->pencil.height-- ;
                           if ( wext->pencil.height < 4 )  wext->pencil.height = 4 ;
                           if ( wext->pencil.height > 64 ) wext->pencil.height = 64 ;
                           show_pencil( adr_pencil, wext ) ;
                           break ;
      case PINCEAU_FMOINS:
      case PINCEAU_FPLUS : if ( obj == PINCEAU_FPLUS ) wext->pencil.type++ ;
                           else                        wext->pencil.type-- ;
                           if ( wext->pencil.type < 0 ) wext->pencil.type = 0 ;
                           if ( wext->pencil.type > 2 ) wext->pencil.type = 2 ;
                           show_pencil( adr_pencil, wext ) ;
                           break ;
     case PINCEAU_OK     : code = IDOK ;
                           break ;
     case PINCEAU_CANCEL : code = IDCANCEL ;
                           break ;
  }

  if ( code == IDOK )
  {
  }

  return code ;
}

void traite_ppinceau(void)
{
  WEXTENSION_PENCIL wext ;
  DLGDATA           dlg_data ;

  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId       = FORM_PINCEAU ;
  strcpy( dlg_data.Title, vMsgTxtGetMsg(MSG_WFNAMES)  ) ;
  dlg_data.UserData     = &wext ;
  dlg_data.OnInitDialog = OnInitDialogPencil ;
  dlg_data.OnObjectNotify = OnObjectNotifyPencil ;

  if ( GWCreateAndDoModal( &dlg_data, 0 ) == IDOK ) memcpy( &pencil, &wext.pencil, sizeof(PENCIL) ) ;
}
