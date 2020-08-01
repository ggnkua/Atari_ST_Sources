#include <string.h>
#include <stdlib.h>
#include "..\tools\gwindows.h"

#include "vsldshow.h"
#include "actions.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  int back ;
  int transition ;
}
WEXTENSION_SLDSHOW ;

typedef struct
{
  OBJECT* popup_transition ;
  OBJECT* popup_back ;
}
WDLG_DATA ;


static void OnInitDialogSldShow(void* w)
{
  GEM_WINDOW*         wnd = (GEM_WINDOW*) w ;
  WEXTENSION_SLDSHOW* wext = wnd->DlgData->UserData ;
  WDLG_DATA*          wdlg = wnd->Extension ;
  OBJECT*             adr_sldshow = wnd->DlgData->BaseObject ;
  int                 max_le,i ;
  char                buffer[20] ;

  if ( config.display_type & DISPLAYTYPE_ZOOM ) select( adr_sldshow, SSH_AFFZOOM ) ;
  else                                          deselect( adr_sldshow, SSH_AFFZOOM ) ;
  if ( config.display_type & DISPLAYTYPE_REDUC ) select( adr_sldshow, SSH_AFFREDUC ) ;
  else                                           deselect( adr_sldshow, SSH_AFFREDUC ) ;
  
  wext->transition = config.transition ;
  wdlg->popup_transition = popup_make(3, 13) ;
  if (wdlg->popup_transition == NULL) return ;
  for (i = 0; i <= 2; i++)
    strcpy(wdlg->popup_transition[1+i].ob_spec.free_string, MsgTxtGetMsg(hMsg, MSG_TRANSIT0+i) ) ;
  write_text(adr_sldshow, SSH_TRANSITION, MsgTxtGetMsg(hMsg, MSG_TRANSIT0+wext->transition) ) ;

  wext->back = config.back ;
  if ( wext->back != BACK_WHITE ) wext->back = BACK_BLACK ;
  wdlg->popup_back = popup_make( 2, 13 ) ;
  if ( wdlg->popup_back == NULL ) return ;
  strcpy(wdlg->popup_back[1].ob_spec.free_string, MsgTxtGetMsg(hMsg, MSG_NOIR) ) ;
  strcpy(wdlg->popup_back[2].ob_spec.free_string, MsgTxtGetMsg(hMsg, MSG_BLANC) ) ;
  write_text(adr_sldshow, SSH_FOND, wdlg->popup_back[1+wext->back].ob_spec.free_string ) ;

  if ( config.cycle ) select(adr_sldshow, SSH_CYCLE) ;
  else                deselect(adr_sldshow, SSH_CYCLE) ;
  if ( config.do_not_cls_scr ) deselect(adr_sldshow, SSH_CLSSCREEN) ;
  else                         select(adr_sldshow, SSH_CLSSCREEN) ;
  if ( config.aff_name ) select(adr_sldshow, SSH_SHOWNAME) ;
  else                   deselect(adr_sldshow, SSH_SHOWNAME) ;
  if ( config.aff_prog ) select(adr_sldshow, SSH_SHOWPROG) ;
  else                   deselect(adr_sldshow, SSH_SHOWPROG) ;

  if ( config.wait_mini_sec >= 0 )
  {
    sprintf( buffer, "%02d", config.wait_mini_sec ) ;
    write_text(adr_sldshow, SSH_WAITMINI, buffer) ;
    adr_sldshow[SSH_WAITMINI].ob_state   &= ~DISABLED ;
    adr_sldshow[SSH_TWAITMINI].ob_state  &= ~DISABLED ;
    deselect( adr_sldshow, SSH_NOTIMER ) ;
  }
  else
  {
    strcpy( buffer, "00" ) ;
    write_text(adr_sldshow, SSH_WAITMINI, buffer) ;
    adr_sldshow[SSH_WAITMINI].ob_state   |= DISABLED ;
    adr_sldshow[SSH_TWAITMINI].ob_state  |= DISABLED ;
    select( adr_sldshow, SSH_NOTIMER ) ;
  }
}

static int OnObjectNotifySldShow(void *w, int obj)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  WEXTENSION_SLDSHOW *wext = wnd->DlgData->UserData ;
  WDLG_DATA          *wdlg = wnd->Extension ;
  OBJECT             *adr_sldshow = wnd->DlgData->BaseObject ;
  int                i, off_x, off_y ;
  int                code = -1 ;
  char               buffer[20] ;

  switch( obj )
  {
    case SSH_TRANSITION  : deselect(adr_sldshow, SSH_TRANSITION) ;
                           objc_offset(adr_sldshow, SSH_TRANSITION, &off_x, &off_y) ;
                           i = popup_formdo(&wdlg->popup_transition, off_x, off_y, 1+wext->transition, -1) ;
                           if (i > 0) wext->transition = i-1 ;
                           write_text( adr_sldshow, SSH_TRANSITION, MsgTxtGetMsg(hMsg, MSG_TRANSIT0+wext->transition)  ) ;
                           xobjc_draw( wnd->window_handle, adr_sldshow, SSH_TRANSITION ) ;
                           break ;
    case SSH_FOND        : deselect(adr_sldshow, SSH_FOND) ;
                           objc_offset(adr_sldshow, SSH_FOND, &off_x, &off_y) ;
                           i = popup_formdo(&wdlg->popup_back, off_x, off_y, 1+wext->back, -1) ;
                           if (i > 0) wext->back = i-1 ;
                           if ( wext->back == BACK_WHITE ) write_text(adr_sldshow, SSH_FOND, MsgTxtGetMsg(hMsg, MSG_BLANC) ) ;
                           else                            write_text(adr_sldshow, SSH_FOND, MsgTxtGetMsg(hMsg, MSG_NOIR) ) ;
                           xobjc_draw( wnd->window_handle, adr_sldshow, SSH_FOND ) ;
                           break ;
    case SSH_TAFFZOOM    : inv_select( adr_sldshow, SSH_AFFZOOM ) ;
                           break ;
    case SSH_TAFFREDUC   : inv_select( adr_sldshow, SSH_AFFREDUC ) ;
                           break ;
    case SSH_TCYCLE      : inv_select(adr_sldshow, SSH_CYCLE) ;
                           break ;
    case SSH_TCLSSCREEN  : inv_select(adr_sldshow, SSH_CLSSCREEN) ;
                           break ;
    case SSH_TSHOWNAME   : inv_select(adr_sldshow, SSH_SHOWNAME) ;
                           break ;
    case SSH_TSHOWPROG   : inv_select(adr_sldshow, SSH_SHOWPROG) ;
                           break ;
    case SSH_NOTIMER     : 
    case SSH_TNOTIMER    : inv_select(adr_sldshow, SSH_NOTIMER) ;
                           if ( selected(adr_sldshow, SSH_NOTIMER) )
                           {
                             adr_sldshow[SSH_WAITMINI].ob_state   |= DISABLED ;
                             adr_sldshow[SSH_TWAITMINI].ob_state  |= DISABLED ;
                           }
                           else
                           {
                             adr_sldshow[SSH_WAITMINI].ob_state   &= ~DISABLED ;
                             adr_sldshow[SSH_TWAITMINI].ob_state  &= ~DISABLED ;
                           }
                           xobjc_draw( wnd->window_handle, adr_sldshow, SSH_WAITMINI ) ;
                           xobjc_draw( wnd->window_handle, adr_sldshow, SSH_TWAITMINI ) ;
                           break ;
     case SLDSHOW_OK :     code = IDOK ;
                           break ;
     case SLDSHOW_CANCEL : code = IDCANCEL ;
                           break ;
  }

  if ( code == IDOK )
  {
    if ( selected(adr_sldshow, SSH_AFFZOOM) )  config.display_type |= DISPLAYTYPE_ZOOM ;
    else                                       config.display_type &= ~DISPLAYTYPE_ZOOM ;
    if ( selected(adr_sldshow, SSH_AFFREDUC) ) config.display_type |= DISPLAYTYPE_REDUC ;
    else                                      config.display_type &= ~DISPLAYTYPE_REDUC ;

    if ( wext->back >= 0 ) config.back = wext->back ;
    if ( wext->transition >= 0 ) config.transition = wext->transition ;
    if ( selected(adr_sldshow, SSH_CYCLE) ) config.cycle = 1 ;
    else                                    config.cycle = 0 ;
    if ( selected(adr_sldshow, SSH_CLSSCREEN) ) config.do_not_cls_scr = 0 ;
    else                                        config.do_not_cls_scr = 1 ;
    if ( selected(adr_sldshow, SSH_SHOWNAME) ) config.aff_name = 1 ;
    else                                       config.aff_name = 0 ;
    if ( selected(adr_sldshow, SSH_SHOWPROG) ) config.aff_prog = 1 ;
    else                                       config.aff_prog = 0 ;
    if ( !selected( adr_sldshow, SSH_NOTIMER ) )
    {
      read_text(adr_sldshow, SSH_WAITMINI, buffer) ;
      config.wait_mini_sec = atoi(buffer) ;
    }
    else
      config.wait_mini_sec = -1 ;
  }

  return( code ) ;
}

static int OnCloseDialogSldShow(void *w)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  WDLG_DATA  *wdlg = wnd->Extension ;

  popup_kill( wdlg->popup_transition, 3 ) ;
  popup_kill( wdlg->popup_back, 2 ) ;

  return( GWCloseDlg( w ) ) ;
}

static int OnTxtBubbleSldShow(void *w, int mx, int my, char *txt)
{
  GEM_WINDOW *wnd = (GEM_WINDOW *) w ;
  OBJECT     *adr_form =  wnd->DlgData->BaseObject ;
  int        objet, trouve = 1 ;

  objet = objc_find( adr_form, 0, MAX_DEPTH, mx, my ) ; 
  switch( objet )
  {
    case SSH_TRANSITION  : strcpy( txt, MsgTxtGetMsg(hMsg, MSG_HSSHTRANSIT)  ) ;
                           break ;
    case SSH_CYCLE       : 
    case SSH_TCYCLE      : 
                           strcpy( txt, MsgTxtGetMsg(hMsg, MSG_HSSHCYCLE)  ) ;
                           break ;
    case SSH_WAITMINI    : 
    case SSH_TWAITMINI   : 
                           strcpy( txt, MsgTxtGetMsg(hMsg, MSG_HSSHWAITMINI)  ) ;
                           break ;
    case SSH_CLSSCREEN   :
    case SSH_TCLSSCREEN  :
                           strcpy( txt, MsgTxtGetMsg(hMsg, MSG_HSSHCLS)  ) ;
                           break ;
    case SSH_SHOWNAME    :
    case SSH_TSHOWNAME   :
                           strcpy( txt, MsgTxtGetMsg(hMsg, MSG_HSSHAFFNAME)  ) ;
                           break ;
    case SSH_AFFZOOM     :
    case SSH_TAFFZOOM    :
                           strcpy( txt, MsgTxtGetMsg(hMsg, MSG_HSSHAFFZOOM)  ) ;
                           break ;
    case SSH_AFFREDUC    :
    case SSH_TAFFREDUC   :
                           strcpy( txt, MsgTxtGetMsg(hMsg, MSG_HSSHAFFREDUC)  ) ;
                           break ;
    case SSH_SHOWPROG    :
    case SSH_TSHOWPROG   :
                           strcpy( txt, MsgTxtGetMsg(hMsg, MSG_HSSHAFFPROG)  ) ;
                           break ;
    case SSH_NOTIMER     :
    case SSH_TNOTIMER    :
                           strcpy( txt, MsgTxtGetMsg(hMsg, MSG_HSSHNOTIMER)  ) ;
                           break ;
    default              : trouve = 0 ;
  }

  return( trouve ) ; 
}

void pref_sldshow(void)
{
  GEM_WINDOW         *dlg ;
  WEXTENSION_SLDSHOW wext ;
  DLGDATA            dlg_data ;
  int                code ;

  memset( &dlg_data, 0, sizeof(DLGDATA) ) ;
  dlg_data.RsrcId       = FORM_SLIDESHOW ;
  strcpy( dlg_data.Title, MsgTxtGetMsg(hMsg, MSG_WFNAMES)  ) ;
  dlg_data.UserData       = &wext ;
  dlg_data.ExtensionSize  = sizeof(WDLG_DATA) ;
  dlg_data.OnInitDialog   = OnInitDialogSldShow ;
  dlg_data.OnObjectNotify = OnObjectNotifySldShow ;
  dlg_data.OnCloseDialog  = OnCloseDialogSldShow ;

  dlg  = GWCreateDialog( &dlg_data ) ;
#ifndef __NO_BUBBLE
  dlg->OnTxtBubble = OnTxtBubbleSldShow ;
#endif
  code = GWDoModal( dlg, 0 ) ;

  if ( code == IDOK )
  {

  }
}
