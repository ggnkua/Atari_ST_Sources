#include <string.h>
#include "..\tools\gwindows.h"

#include "actions.h"
#include "fpath.h"
#include "fdsp.h"
#include "fsldshow.h"
#include "fundo.h"
#include "frtzoom.h"
#include "flog.h"
#include "vtoolbar.h"
#include "visionio.h"

#ifndef __VISION_H
#define __VISION_H
#include "langues\francais\vision.h"
#endif

typedef struct
{
  VISION_CFG save ;

  int  cp, dm ;
  int  rtzoom_change ;
  int  display_toolbar ;
  char language[20] ;
}
WEXTENSION_PREF ;

typedef struct
{
  OBJECT* popup_cp ;
  OBJECT* popup_dm ;
  OBJECT* popup_language ;
}
WDLG_PREF ;


static void OnInitDialogPref(void* w)
{
  GEM_WINDOW*      wnd = (GEM_WINDOW*) w ;
  WEXTENSION_PREF* wext = wnd->DlgData->UserData ;
  WDLG_PREF*       wdlg = wnd->Extension ;
  OBJECT*          adr_pref = wnd->DlgData->BaseObject ;
  int              i ;

  memcpy( &wext->save, &config, sizeof(VISION_CFG) ) ;
  wext->display_toolbar = config.flags & FLG_TOOLBAR ;
#ifndef __NO_BUBBLE
  checkbox_setstate( config.flags & FLG_HELP, adr_pref, PREF_AIDE ) ;
#else
  deselect(adr_pref, PREF_AIDE) ;
  adr_pref[PREF_AIDE].ob_state  |= DISABLED ;
  adr_pref[PREF_TAIDE].ob_state |= DISABLED ;
#endif

  checkbox_setstate( config.flag_fullscreen, adr_pref, PREF_PECRAN ) ;
  checkbox_setstate( config.w_info, adr_pref, PREF_WKIND ) ;
  checkbox_setstate( config.quitte, adr_pref, PREF_QUIT ) ;
  checkbox_setstate( config.clip_gem, adr_pref, PREF_CLIP ) ;
  checkbox_setstate( config.souris_viseur, adr_pref, PREF_MVISEUR ) ;
  checkbox_setstate( config.flags & FLG_SPLASH, adr_pref, PREF_SPLASH ) ;
  checkbox_setstate( config.flags & FLG_TOOLBAR, adr_pref, PREF_TOOLBAR ) ;
  checkbox_setstate( config.flags & FLG_LONGFNAME, adr_pref, PREF_LONGFNAME ) ;
  checkbox_setstate( config.flags & FLG_DITHERAUTO, adr_pref, PREF_DITHERAUTO ) ;

  wdlg->popup_cp = popup_make(3, 14) ;
  if (wdlg->popup_cp == NULL) return ;
  for (i = 0; i <= 2; i++) strcpy(wdlg->popup_cp[1+i].ob_spec.free_string, vMsgTxtGetMsg(MSG_CPNONE+i) ) ;

  wext->cp = config.color_protect ;
  write_text(adr_pref, PREF_CP, vMsgTxtGetMsg(MSG_CPNONE+wext->cp) ) ;

  wdlg->popup_dm = popup_make(3, 26) ;
  if (wdlg->popup_dm == NULL) return ;
  for (i = 0; i <= 2; i++) strcpy(wdlg->popup_dm[1+i].ob_spec.free_string, vMsgTxtGetMsg(MSG_DITHERAUTO+i) ) ;

  wext->dm = config.dither_method ;
  write_text(adr_pref, PREF_DITHER, vMsgTxtGetMsg(MSG_DITHERAUTO+wext->dm) ) ;

  wdlg->popup_language = popup_make( config.nb_languages, 17 ) ;
  if ( wdlg->popup_language == NULL ) return ;
  for ( i = 1; i <= config.nb_languages; i++)
    sprintf( wdlg->popup_language[i].ob_spec.free_string, "  %s", config.all_languages[i-1] ) ;

  sprintf( wext->language, "  %s", config.language ) ;
  write_text( adr_pref, PREF_LANGUE, wext->language ) ;
  adr_pref[PREF_LOGFILE].ob_flags |= HIDETREE ; /* Logfile feature no longer used */
}

static int OnObjectNotifyPref(void *w, int obj)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
  WEXTENSION_PREF *wext = wnd->DlgData->UserData ;
  WDLG_PREF       *wdlg = wnd->Extension ;
  OBJECT          *adr_pref = wnd->DlgData->BaseObject ;
  int             i, off_x, off_y ;
  int             code = -1 ;
  int             save = 0 ;

  switch( obj )
  {
    case PREF_TPECRAN   : inv_select(adr_pref, PREF_PECRAN) ;
                          break ;
    case PREF_TQUIT     : inv_select(adr_pref, PREF_QUIT) ;
                          break ;
    case PREF_TCLIP     : inv_select(adr_pref, PREF_CLIP) ;
                          break ;
    case PREF_TWKIND    : inv_select(adr_pref, PREF_WKIND) ;
                          break ;
    case PREF_TMVISEUR  : inv_select(adr_pref, PREF_MVISEUR) ;
                          break ;
    case PREF_TAIDE     : inv_select(adr_pref, PREF_AIDE) ;
                          break ;
    case PREF_TDITHERAUTO: inv_select(adr_pref, PREF_DITHERAUTO) ;
                          break ;
    case PREF_TSPLASH   : inv_select(adr_pref, PREF_SPLASH) ;
                          break ;
    case PREF_TTOOLBAR  : inv_select(adr_pref, PREF_TOOLBAR) ;
                          break ;
    case PREF_TLONGFNAME: inv_select(adr_pref, PREF_LONGFNAME) ;
                          break ;
    case PREF_CP        : deselect(adr_pref, PREF_CP) ;
                          objc_offset(adr_pref, PREF_CP, &off_x, &off_y) ;
                          i = popup_formdo(&wdlg->popup_cp, off_x, off_y, 1+wext->cp, -1) ;
                          if (i > 0) wext->cp = i-1 ;
                          write_text(adr_pref, PREF_CP, vMsgTxtGetMsg(MSG_CPNONE+wext->cp) ) ;
                          GWObjcDraw( wnd, adr_pref, PREF_CP ) ;
                          break ;
    case PREF_LANGUE    : deselect( adr_pref, PREF_LANGUE ) ;
                          if ( config.nb_languages > 1 )
                          {
                            objc_offset( adr_pref, PREF_LANGUE, &off_x, &off_y ) ;
                            i = popup_formdo( &wdlg->popup_language, off_x, off_y, 1, -1 ) ;
                            if (i > 0) sprintf( wext->language, "  %s", config.all_languages[i-1] ) ;
                            write_text( adr_pref, PREF_LANGUE, wext->language ) ;
                          }
                          GWObjcDraw( wnd, adr_pref, PREF_LANGUE ) ;
                          break ;
    case PREF_DITHER    : deselect(adr_pref, PREF_DITHER) ;
                          objc_offset(adr_pref, PREF_DITHER, &off_x, &off_y) ;
                          i = popup_formdo(&wdlg->popup_dm, off_x, off_y, 1+wext->dm, -1) ;
                          if (i > 0) wext->dm = i-1 ;
                          write_text(adr_pref, PREF_DITHER, vMsgTxtGetMsg(MSG_DITHERAUTO+wext->dm) ) ;
                          GWObjcDraw( wnd, adr_pref, PREF_DITHER ) ;
                          break ;
    case PREF_PATHS     : get_paths() ;
                          inv_select( adr_pref, obj ) ;
                          break ;
    case PREF_DSP       : pref_dsp() ;
                          inv_select( adr_pref, obj ) ;
                          break ;
    case PREF_SLDSHOW   : pref_sldshow() ;
                          inv_select( adr_pref, obj ) ;
                          break ;
    case PREF_UNDO      : pref_undo() ;
                          inv_select( adr_pref, obj ) ;
                          break ;
    case PREF_RTZOOM    : wext->rtzoom_change = pref_rtzoom() ;
                          inv_select( adr_pref, obj ) ;
                          break ;
/*    case PREF_LOGFILE   : pref_logfile() ;
                          inv_select( adr_pref, obj ) ;
                          break ;*/
     case PREF_SAVE     : save = 1 ;
     case PREF_OK       : code = IDOK ;
                          break ;
     case PREF_CANCEL   : code = IDCANCEL ;
                          break ;
  }

  if ( code == IDOK )
  {
    if (selected(adr_pref, PREF_PECRAN))     config.flag_fullscreen = 1 ;
    else                                     config.flag_fullscreen = 0 ;
    if (selected(adr_pref, PREF_WKIND))      config.w_info = 1 ;
    else                                     config.w_info = 0 ;
    if (selected(adr_pref, PREF_QUIT))       config.quitte = 1 ;
    else                                     config.quitte = 0 ;
    if (selected(adr_pref, PREF_CLIP))       config.clip_gem = 1 ;
    else                                     config.clip_gem = 0 ;
    if (selected(adr_pref, PREF_MVISEUR))    config.souris_viseur = 1 ;
    else                                     config.souris_viseur = 0 ;
    if (selected(adr_pref, PREF_AIDE))       config.flags |= FLG_HELP ;
    else                                     config.flags &= ~FLG_HELP ;
    if (selected(adr_pref, PREF_LONGFNAME))  config.flags |= FLG_LONGFNAME ;
    else                                     config.flags &= ~FLG_LONGFNAME ;
    if (selected(adr_pref, PREF_DITHERAUTO)) config.flags |= FLG_DITHERAUTO ;
    else                                     config.flags &= ~FLG_DITHERAUTO ;
    if (selected(adr_pref, PREF_SPLASH))     config.flags |= FLG_SPLASH ;
    else                                     config.flags &= ~FLG_SPLASH ;
    if (selected(adr_pref, PREF_TOOLBAR))    config.flags |= FLG_TOOLBAR ;
    else                                     config.flags &= ~FLG_TOOLBAR ;

    if ( config.flags & FLG_HELP ) GemApp.Flags.HelpBubbles = 1 ;
    else                           GemApp.Flags.HelpBubbles = 0 ;
    config.color_protect = wext->cp ;
    config.dither_method = wext->dm ;
    if ( GemApp.CurrentGemWindow && ( strcmp( GemApp.CurrentGemWindow->ClassName, VIMG_CLASSNAME ) == 0 ) )
      set_imgpalette( (VXIMAGE *) GemApp.CurrentGemWindow->Extension ) ;

    if ( strcmp( config.language, 2+wext->language ) )
    {
      vform_stop( MSG_CHANGELNG ) ;
      strcpy( config.language, 2+wext->language ) ;
      save = 1 ; /* Force la sauvegarde */
    }

    VToolBarShow( config.flags & FLG_TOOLBAR ) ;
  }

  if ( save )
  {
    if ( SaveVISIONIniFile( &config ) ) vform_stop( MSG_WRITEERROR ) ;
  }

  return code ;
}

static int OnCloseDlgPref(void *w)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
  WDLG_PREF*  wdlg = wnd->Extension ;

  popup_kill( wdlg->popup_language, config.nb_languages ) ;
  popup_kill( wdlg->popup_dm, 3 ) ;
  popup_kill( wdlg->popup_cp, 3 ) ;

  return( GWCloseDlg( w ) ) ;
}

static int OnTxtBubblePref(void* w, int mx, int my, char* txt)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) w ;
  OBJECT*     adr_form =  wnd->DlgData->BaseObject ;
  int         obj = objc_find( adr_form, 0, MAX_DEPTH, mx, my ) ;
  int         objs[] = { PREF_PECRAN, PREF_TPECRAN, PREF_QUIT, PREF_TQUIT, PREF_WKIND, PREF_TWKIND, PREF_MVISEUR, PREF_TMVISEUR, PREF_CLIP, PREF_TCLIP, PREF_AIDE, PREF_TAIDE, PREF_LONGFNAME, PREF_TLONGFNAME,
                         PREF_DITHERAUTO, PREF_TDITHERAUTO, PREF_SPLASH, PREF_TSPLASH, PREF_DSP, PREF_PATHS, PREF_CP, PREF_DITHER  } ;
  int         msgs[] = { MSG_HPREFFULLSCR, MSG_HPREFFULLSCR, MSG_HPREFQUIT, MSG_HPREFQUIT, MSG_HPREFINFO, MSG_HPREFINFO, MSG_HPREFMOUSE, MSG_HPREFMOUSE, MSG_HPREFCLIP, MSG_HPREFCLIP, MSG_HPREFHELP, MSG_HPREFHELP, MSG_HLONGFNAME, MSG_HLONGFNAME, 
                        MSG_HDITHERAUTO, MSG_HDITHERAUTO, MSG_HSPLASH, MSG_HSPLASH, MSG_HPREFDSP, MSG_HPREFPATH, MSG_HPREFGEMP, MSG_HPREFDITHER } ;

  return( vget_txtbubblemsg( obj, objs, msgs, ARRAY_SIZE(objs), txt ) ) ;
}

void traite_preferences(void)
{
  GEM_WINDOW*     dlg ;
  WEXTENSION_PREF wext ;
  DLGDATA         dlg_data ;
  int             code, use_longfilenames ;

  use_longfilenames = ( config.flags & FLG_LONGFNAME ) ;
  GWZeroDlgData( &dlg_data ) ;
  dlg_data.RsrcId       = FORM_PREF ;
  strcpy( dlg_data.Title, vMsgTxtGetMsg(MSG_WFNAMES)  ) ;
  dlg_data.UserData       = &wext ;
  dlg_data.ExtensionSize  = sizeof(WDLG_PREF) ;
  dlg_data.OnInitDialog   = OnInitDialogPref ;
  dlg_data.OnObjectNotify = OnObjectNotifyPref ;
  dlg_data.OnCloseDialog  = OnCloseDlgPref ;

  dlg = GWCreateDialog( &dlg_data ) ;
#ifndef __NO_BUBBLE
  dlg->OnTxtBubble = OnTxtBubblePref ;
#endif
  code = GWDoModal( dlg, -1 ) ;
  if ( code == IDOK )
  {
    if ( use_longfilenames != ( config.flags & FLG_LONGFNAME ) ) Pdomain( ( config.flags & FLG_LONGFNAME ) ? 1:0 ) ;
  }
  else memcpy( &config, &wext.save, sizeof(VISION_CFG) ) ;
}
