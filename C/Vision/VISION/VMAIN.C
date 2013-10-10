/*****************************************/
/* Programme principal du Project VISION */
/* (c) LUSETTI Jean Aout 1993            */
/*****************************************/
#include  <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stddef.h>

#include      "..\tools\ini.h"
#include  "..\tools\stdprog.h"
#include  "..\tools\stdinput.h"
#include  "..\tools\xrsrc.h"
#include     "..\tools\xgem.h"
#include    "..\tools\xmint.h"
#include      "..\tools\xfile.h"
#include "..\tools\gwindows.h"
#include    "..\tools\aides.h"
#include   "..\tools\dither.h"
#include "..\tools\imgmodul.h"
#include  "..\tools\cookies.h"
#include "..\tools\rasterop.h"

#include     "defs.h"
#include     "undo.h"
#include   "gstenv.h"
#include   "rtzoom.h"
#include  "actions.h"
#include  "touches.h"
#include "visionio.h"
#include "register.h"
#include "vsldshow.h"
#include "vtoolbar.h"
#include "protect.h"
#include "ibrowser.h"

#include "forms\ftcwheel.h"
#include "forms\ffilter.h"
#include "forms\fbaratin.h"
#include "forms\falbum.h"

#include "ldv\ldvcom.h"
#include "forms\fldv.h"

int haute_resolution ;
static long key_protect = 0 ;

char section_general[]       = "General" ;
char section_folders[]       = "Folders" ;
char section_dsp[]           = "DSP" ;
char section_diaporama[]     = "SlideShow" ;
char section_undo[]          = "Undo" ;
char section_rtzoom[]        = "Real Time Zoom" ;
char section_graphics[]      = "Graphics" ;
char section_log[]           = "Log" ;
char section_snap[]          = "SnapShot" ;
char section_ldv[]           = "LDV" ;
long key_protect2 = 0 ;

char vision_prg_access[] = "%s\\VISION.PRG" ;
char vision_rsc_access[] = "%s\\%s\\VISION.RSC" ;

static long nb_timers = 0 ;

void init_data(void)
{
  memset( &clipboard.img, 0, sizeof(MFDB) ) ;
  memset( &clipboard.mask, 0, sizeof(MFDB) ) ;
  clipboard.mitem   = 0 ;
  clipboard.gwindow = NULL ;
  clipboard.x       = 0 ;
  clipboard.y       = 0 ;
  clipboard.w       = 0 ;
  clipboard.h       = 0 ;
  
  vclip.form    = BLOC_RECTANGLE ;
  vclip.gwindow = NULL ;
  vclip.x1      = 0 ;
  vclip.y1      = 0 ;
  vclip.x2      = 0 ;
  vclip.y2      = 0 ;
}

void set_defaultconfig(void)
{
  strcpy(config.version, NO_VERSION) ;
  config.flag_fullscreen = 0 ;
  config.w_info          = 1 ;
  config.quitte          = 0 ;
  config.clip_gem        = 0 ;
  config.nb_undo         = 4 ;
  config.type_undo       = 0 ;
  config.use_redo        = 1 ;
  config.souris_viseur   = 0 ;
  config.color_protect   = 1 ;
  config.flags           = FLG_HELP | FLG_TOOLBAR ;
  GemApp.Flags.HelpBubbles = 1 ;
  config.dither_method   = DITHER_AUTO ;
  config.dspuse          = DspInfo.use ;
  config.dsphandlelock   = DspInfo.WhatToDoIfLocked ;
  config.sgomme          = 0 ;
  config.path_img[0]     = 0 ;
  config.path_filter[0]  = 0 ;
  config.path_filter[0]  = 0 ;
  config.path_album[0]   = 0 ;
  /* Ajout diaporama */
  config.cycle             = 0 ;
  config.wait_mini_sec     = 0 ;
  config.do_not_show_mouse = 0 ;
  config.do_not_cls_scr    = 0;
  config.back              = BACK_BLACK;
  config.display_type      = 0 ;
  config.transition        = TRANSITION_NULL ;
  config.ignore_vss        = 0 ;
  config.aff_name          = 1 ;
  config.aff_prog          = 1 ;

  config.snap_flags        = SF_ALLSCREEN ;

  config.ldv_options       = 0 ;
}

long SaveVISIONIniFile(VISION_CFG *cfg)
{
  HINI h_ini ;
  char buf[PATH_MAX] ;

  sprintf( buf, "%s\\VISION.INI", init_path ) ;
  sprintf( "init_path . %s", init_path ) ;
  h_ini = OpenIni( buf ) ;

  /*********************** Section GENERAL ****************************/
  sprintf( buf, "%s", cfg->language ) ;
  SetIniKey( h_ini, section_general, "Language", buf ) ;

  if ( cfg->flags & FLG_HELP ) strcpy( buf, "1" ) ;
  else                         strcpy( buf, "0" ) ;
  SetIniKey( h_ini, section_general, "HelpBubbles", buf ) ;

  if ( cfg->flags & FLG_DITHERAUTO ) strcpy( buf, "1" ) ;
  else                               strcpy( buf, "0" ) ;
  SetIniKey( h_ini, section_general, "DitherAuto", buf ) ;

  sprintf( buf, "%d", cfg->flag_fullscreen ) ;
  SetIniKey( h_ini, section_general, "FullScreen", buf ) ;

  sprintf( buf, "%d", cfg->w_info ) ;
  SetIniKey( h_ini, section_general, "InfoBar", buf ) ;

  sprintf( buf, "%d", cfg->quitte ) ;
  SetIniKey( h_ini, section_general, "QuitIfNoWindow", buf ) ;

  sprintf( buf, "%d", cfg->clip_gem ) ;
  SetIniKey( h_ini, section_general, "UseGEMClipboard", buf ) ;

  sprintf( buf, "%d", cfg->souris_viseur ) ;
  SetIniKey( h_ini, section_general, "CrossMouse", buf ) ;

  sprintf( buf, "%d", cfg->color_protect ) ;
  SetIniKey( h_ini, section_general, "ColorProtection", buf ) ;

  sprintf( buf, "%d", cfg->dither_method ) ;
  SetIniKey( h_ini, section_general, "DitherMethod", buf ) ;

  if ( cfg->flags & FLG_SPLASH ) strcpy( buf, "1" ) ;
  else                           strcpy( buf, "0" ) ;
  SetIniKey( h_ini, section_general, "SplashWindow", buf ) ;

  if ( cfg->flags & FLG_TOOLBAR ) strcpy( buf, "1" ) ;
  else                            strcpy( buf, "0" ) ;
  SetIniKey( h_ini, section_general, "DisplayToolBar", buf ) ;

  if ( cfg->flags & FLG_LONGFNAME ) strcpy( buf, "1" ) ;
  else                              strcpy( buf, "0" ) ;
  SetIniKey( h_ini, section_general, "UseLongFileNames", buf ) ;

  /**************************************************************************/

  /***************************** Section FOLDERS  ***************************/
  sprintf( buf, "%s", cfg->path_language ) ;
  SetIniKey( h_ini, section_folders, "Languages", buf ) ;

  sprintf( buf, "%s", cfg->path_temp ) ;
  SetIniKey( h_ini, section_folders, "Temp", buf ) ;

  sprintf( buf, "%s", cfg->path_img ) ;
  SetIniKey( h_ini, section_folders, "Images", buf ) ;

  sprintf( buf, "%s", cfg->path_lod ) ;
  SetIniKey( h_ini, section_folders, "DSP", buf ) ;

  sprintf( buf, "%s", cfg->path_filter ) ;
  SetIniKey( h_ini, section_folders, "Filters", buf ) ;

  sprintf( buf, "%s", cfg->path_album ) ;
  SetIniKey( h_ini, section_folders, "Album", buf ) ;

  sprintf( buf, "%s", cfg->path_ldv ) ;
  SetIniKey( h_ini, section_folders, "LDV", buf ) ;

  /**************************************************************************/

  /*************************** Section DSP **********************************/
  sprintf( buf, "%d", cfg->dspuse ) ;
  SetIniKey( h_ini, section_dsp, "UseDSP", buf ) ;

  sprintf( buf, "%d", cfg->dsphandlelock ) ;
  SetIniKey( h_ini, section_dsp, "HandleLock", buf ) ;

  /**************************************************************************/

  /********************** Section UNDO *********************************/
  sprintf( buf, "%d", cfg->nb_undo ) ;
  SetIniKey( h_ini, section_undo, "NbBuffers", buf ) ;
  if ( cfg->nb_undo < 0 ) cfg->nb_undo = 0 ;
  if ( cfg->nb_undo > MAX_UNDO ) cfg->nb_undo = MAX_UNDO ;

  sprintf( buf, "%d", cfg->type_undo ) ;
  SetIniKey( h_ini, section_undo, "Type", buf ) ;

  sprintf( buf, "%d", cfg->ko_undo ) ;
  SetIniKey( h_ini, section_undo, "UseDiskIfKo", buf ) ;

  sprintf( buf, "%d", cfg->use_redo ) ;
  SetIniKey( h_ini, section_undo, "UseRedo", buf ) ;

  /**************************************************************************/

  /*************************** Section Diaporama ****************************/
  sprintf( buf, "%d", cfg->wait_mini_sec ) ;
  SetIniKey( h_ini, section_diaporama, "WaitMiniSec", buf ) ;

  sprintf( buf, "%d", cfg->do_not_show_mouse ) ;
  SetIniKey( h_ini, section_diaporama, "HideMouse", buf ) ;

  sprintf( buf, "%d", cfg->do_not_cls_scr ) ;
  SetIniKey( h_ini, section_diaporama, "DoNotClearScreen", buf ) ;

  sprintf( buf, "%d", cfg->cycle ) ;
  SetIniKey( h_ini, section_diaporama, "Cycle", buf ) ;

  sprintf( buf, "%d", cfg->back ) ;
  SetIniKey( h_ini, section_diaporama, "BackGroundColor", buf ) ;

  sprintf( buf, "%d", cfg->display_type ) ;
  SetIniKey( h_ini, section_diaporama, "DisplayType", buf ) ;

  sprintf( buf, "%d", cfg->transition ) ;
  SetIniKey( h_ini, section_diaporama, "Transition", buf ) ;

  sprintf( buf, "%d", cfg->ignore_vss ) ;
  SetIniKey( h_ini, section_diaporama, "IgnoreVSS", buf ) ;

  sprintf( buf, "%d", cfg->aff_name ) ;
  SetIniKey( h_ini, section_diaporama, "DisplayName", buf ) ;

  sprintf( buf, "%d", cfg->aff_prog ) ;
  SetIniKey( h_ini, section_diaporama, "DisplayProg", buf ) ;

  /**************************************************************************/

  /*************************** Section Zoom Temps Reel **********************/
  sprintf( buf, "%d", cfg->rt_zoomwhat ) ;
  SetIniKey( h_ini, section_rtzoom, "ObjectToZoom", buf ) ;

  sprintf( buf, "%d", cfg->rt_respectgem ) ;
  SetIniKey( h_ini, section_rtzoom, "RespectGEM", buf ) ;

  sprintf( buf, "%d", cfg->rt_optimizepos ) ;
  SetIniKey( h_ini, section_rtzoom, "OptimizePosition", buf ) ;

  sprintf( buf, "%d", cfg->use_rtzoom ) ;
  SetIniKey( h_ini, section_rtzoom, "UseRtZoom", buf ) ;

  sprintf( buf, "%d", cfg->rt_width ) ;
  SetIniKey( h_ini, section_rtzoom, "RTWidth", buf ) ;

  sprintf( buf, "%d", cfg->rt_height ) ;
  SetIniKey( h_ini, section_rtzoom, "RTHeight", buf ) ;

  sprintf( buf, "%d", cfg->rt_zoomlevel ) ;
  SetIniKey( h_ini, section_rtzoom, "ZoomLevel", buf ) ;

  /*************************************************************************/

  /************************* Section Graphics ******************************/

  sprintf( buf, "%d", mode_vswr ) ;
  SetIniKey( h_ini, section_graphics, "WriteMode", buf ) ;

  sprintf( buf, "%d", cfg->sgomme ) ;
  SetIniKey( h_ini, section_graphics, "EraserForm", buf ) ;

  sprintf( buf, "%d", ( cfg->flags & FLG_MASKOUT ) ? 1 : 0 ) ;
  SetIniKey( h_ini, section_graphics, "MaskOutside", buf ) ;

  sprintf( buf, "%d", ttype.wcar ) ;
  SetIniKey( h_ini, section_graphics, "TWCar", buf ) ;

  sprintf( buf, "%d", ttype.hcar ) ;
  SetIniKey( h_ini, section_graphics, "THCar", buf ) ;

  sprintf( buf, "%d", ttype.wcell ) ;
  SetIniKey( h_ini, section_graphics, "TWCell", buf ) ;

  sprintf( buf, "%d", ttype.hcell ) ;
  SetIniKey( h_ini, section_graphics, "THCell", buf ) ;

  sprintf( buf, "%d", ttype.angle ) ;
  SetIniKey( h_ini, section_graphics, "TAngle", buf ) ;

  sprintf( buf, "%d", ttype.font ) ;
  SetIniKey( h_ini, section_graphics, "TFont", buf ) ;

  sprintf( buf, "%d", ttype.color ) ;
  SetIniKey( h_ini, section_graphics, "TColor", buf ) ;

  sprintf( buf, "%d", ttype.attribute ) ;
  SetIniKey( h_ini, section_graphics, "TAttribute", buf ) ;

  sprintf( buf, "%d", ttype.hdisp ) ;
  SetIniKey( h_ini, section_graphics, "THdisp", buf ) ;

  sprintf( buf, "%d", ttype.vdisp ) ;
  SetIniKey( h_ini, section_graphics, "TVDisp", buf ) ;

  sprintf( buf, "%d", ftype.style ) ;
  SetIniKey( h_ini, section_graphics, "FStyle", buf ) ;

  sprintf( buf, "%d", ftype.color ) ;
  SetIniKey( h_ini, section_graphics, "FColor", buf ) ;

  sprintf( buf, "%d", ftype.sindex ) ;
  SetIniKey( h_ini, section_graphics, "FSindex", buf ) ;

  sprintf( buf, "%d", ftype.perimeter ) ;
  SetIniKey( h_ini, section_graphics, "FPerimeter", buf ) ;

  sprintf( buf, "%d", mtype.style ) ;
  SetIniKey( h_ini, section_graphics, "MStyle", buf ) ;

  sprintf( buf, "%d", mtype.color ) ;
  SetIniKey( h_ini, section_graphics, "MColor", buf ) ;

  sprintf( buf, "%d", mtype.height ) ;
  SetIniKey( h_ini, section_graphics, "MHeight", buf ) ;

  sprintf( buf, "%d", ltype.style ) ;
  SetIniKey( h_ini, section_graphics, "LStyle", buf ) ;

  sprintf( buf, "%d", ltype.color ) ;
  SetIniKey( h_ini, section_graphics, "LColor", buf ) ;

  sprintf( buf, "%d", ltype.st_kind ) ;
  SetIniKey( h_ini, section_graphics, "LStKind", buf ) ;

  sprintf( buf, "%d", ltype.ed_kind ) ;
  SetIniKey( h_ini, section_graphics, "LEdKind", buf ) ;

  sprintf( buf, "%d", ltype.width ) ;
  SetIniKey( h_ini, section_graphics, "LWidth", buf ) ;

  sprintf( buf, "%d", ( cfg->flags & FLG_SROUND ) ? 1 : 0 ) ;
  SetIniKey( h_ini, section_graphics, "RoundedSurfaces", buf ) ;

  sprintf( buf, "%d", pencil.type ) ;
  SetIniKey( h_ini, section_graphics, "PType", buf ) ;

  sprintf( buf, "%d", pencil.height ) ;
  SetIniKey( h_ini, section_graphics, "PHeight", buf ) ;

  sprintf( buf, "%d", pencil.color ) ;
  SetIniKey( h_ini, section_graphics, "PColor", buf ) ;

  /***************************** Section Log *******************************/
  SetIniKey( h_ini, section_log, "LogFile", config.log_file ) ;

  sprintf( buf, "%d", config.log_flags ) ;
  SetIniKey( h_ini, section_log, "LogFlags", buf ) ;

  /*************************************************************************/

  /*************************** Section SnapShot ****************************/
  sprintf( buf, "%d", config.snap_flags ) ;
  SetIniKey( h_ini, section_snap, "SnapFlags", buf ) ;

  /*************************** Section LDV  ********************************/
  sprintf( buf, "%d", ( config.ldv_options & LDVO_SHOWPERF ) ? 1 :0 ) ;
  SetIniKey( h_ini, section_ldv, "ShowPerf", buf ) ;

  sprintf( buf, "%d", ( config.ldv_options & LDVO_MEPRIORITY ) ? 1 :0 ) ;
  SetIniKey( h_ini, section_ldv, "MePriority", buf ) ;

  sprintf( buf, "%d", config.ldv_preview_src_size ) ;
  SetIniKey( h_ini, section_ldv, "PreviewSrcSize", buf ) ;

  sprintf( buf, "%d", config.ldv_preview_dst_size ) ;
  SetIniKey( h_ini, section_ldv, "PreviewDstSize", buf ) ;

  /*************************************************************************/

  return( SaveAndCloseIni( h_ini, NULL ) ) ;
}

void LoadVISIONIniFile(VISION_CFG *cfg)
{
  HINI h_ini ;
  long save_ini ;
  char buf[PATH_MAX] ;

  memset( cfg, 0, sizeof(VISION_CFG) ) ;
  strcpy( cfg->version, NO_VERSION ) ;
  sprintf( buf, "%s\\VISION.INI", init_path ) ;
  if ( !FileExist( buf ) ) sprintf( buf, "VISION.INI" ) ;
  save_ini = !FileExist( buf ) ;
  h_ini = OpenIni( buf ) ;

  /*********************** Section GENERAL ****************************/
  sprintf( buf, "%s", "FRANCAIS" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_general, "Language", buf ) ;
  strcpy( cfg->language, buf ) ;

  strcpy( buf, "1" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_general, "HelpBubbles", buf ) ;
  if ( atoi( buf ) != 0 ) cfg->flags |= FLG_HELP ;
  if ( config.flags & FLG_HELP ) GemApp.Flags.HelpBubbles = 1 ;
  else                           GemApp.Flags.HelpBubbles = 0 ;

  strcpy( buf, "0" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_general, "DitherAuto", buf ) ;
  if ( atoi( buf ) != 0 ) cfg->flags |= FLG_DITHERAUTO ;

  strcpy( buf, "0" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_general, "SplashWindow", buf ) ;
  if ( atoi( buf ) != 0 ) cfg->flags |= FLG_SPLASH ;

  strcpy( buf, "1" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_general, "DisplayToolBar", buf ) ;
  if ( atoi( buf ) != 0 ) cfg->flags |= FLG_TOOLBAR ;

  strcpy( buf, "0" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_general, "FullScreen", buf ) ;
  cfg->flag_fullscreen = atoi( buf ) ;

  strcpy( buf, "1" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_general, "InfoBar", buf ) ;
  cfg->w_info = atoi( buf ) ;

  strcpy( buf, "0" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_general, "QuitIfNoWindow", buf ) ;
  cfg->quitte = atoi( buf ) ;

  strcpy( buf, "0" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_general, "UseGEMClipboard", buf ) ;
  cfg->clip_gem = atoi( buf ) ;

  strcpy( buf, "0" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_general, "CrossMouse", buf ) ;
  cfg->souris_viseur = atoi( buf ) ;

  strcpy( buf, "1" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_general, "ColorProtection", buf ) ;
  cfg->color_protect = atoi( buf ) ;

  sprintf( buf, "%d", DITHER_AUTO ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_general, "DitherMethod", buf ) ;
  cfg->dither_method = atoi( buf ) ;

  strcpy( buf, "0" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_general, "UseLongFileNames", buf ) ;
  if ( atoi( buf ) != 0 ) cfg->flags |= FLG_LONGFNAME ;

  strcpy( buf, "0" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_general, "ForceUseStdVDI", buf ) ;
  if ( atoi( buf ) != 0 ) cfg->flags |= FLG_FORCEUSESTDVDI ;

  /**************************************************************************/

  /***************************** Section FOLDERS  ***************************/
  sprintf( buf, "%s\\LANGUES", init_path ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_folders, "Languages", buf ) ;
  strcpy( cfg->path_language, buf ) ;

  sprintf( buf, "%s\\TEMP", init_path ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_folders, "Temp", buf ) ;
  strcpy( cfg->path_temp, buf ) ;

  sprintf( buf, "%s", init_path ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_folders, "Images", buf ) ;
  strcpy( cfg->path_img, buf ) ;

  sprintf( buf, "%s\\DSP", init_path ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_folders, "DSP", buf ) ;
  strcpy( cfg->path_lod, buf ) ;

  sprintf( buf, "%s\\FILTRES", init_path ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_folders, "Filters", buf ) ;
  strcpy( cfg->path_filter, buf ) ;

  sprintf( buf, "%s", init_path ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_folders, "Album", buf ) ;
  strcpy( cfg->path_album, buf ) ;

  sprintf( buf, "%s\\LDV", init_path ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_folders, "LDV", buf ) ;
  strcpy( cfg->path_ldv, buf ) ;

  /**************************************************************************/

  /*************************** Section DSP **********************************/
  sprintf( buf, "%d", DspInfo.use ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_dsp, "UseDSP", buf ) ;
  cfg->dspuse = atoi( buf ) ;

  sprintf( buf, "%d", DspInfo.WhatToDoIfLocked ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_dsp, "HandleLock", buf ) ;
  cfg->dsphandlelock = atoi( buf ) ;

  /**************************************************************************/

  /*************************** Section UNDO *********************************/
  sprintf( buf, "4" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_undo, "NbBuffers", buf ) ;
  cfg->nb_undo = atoi( buf ) ;

  sprintf( buf, "0" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_undo, "Type", buf ) ;
  cfg->type_undo = atoi( buf ) ;

  sprintf( buf, "0" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_undo, "UseDiskIfKo", buf ) ;
  cfg->ko_undo = atoi( buf ) ;

  sprintf( buf, "1" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_undo, "UseRedo", buf ) ;
  cfg->use_redo = atoi( buf ) ;

  /**************************************************************************/

  /*************************** Section Diaporama ****************************/
  sprintf( buf, "0" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_diaporama, "WaitMiniSec", buf ) ;
  cfg->wait_mini_sec = atoi( buf ) ;

  sprintf( buf, "0" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_diaporama, "HideMouse", buf ) ;
  cfg->do_not_show_mouse = atoi( buf ) ;

  sprintf( buf, "0" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_diaporama, "DoNotClearScreen", buf ) ;
  cfg->do_not_cls_scr = atoi( buf ) ;

  sprintf( buf, "0" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_diaporama, "Cycle", buf ) ;
  cfg->cycle = atoi( buf ) ;

  sprintf( buf, "%d", BACK_BLACK ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_diaporama, "BackGroundColor", buf ) ;
  cfg->back = atoi( buf ) ;

  sprintf( buf, "0" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_diaporama, "DisplayType", buf ) ;
  cfg->display_type = atoi( buf ) ;

  sprintf( buf, "%d", TRANSITION_NULL ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_diaporama, "Transition", buf ) ;
  cfg->transition = atoi( buf ) ;

  sprintf( buf, "0" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_diaporama, "IgnoreVSS", buf ) ;
  cfg->ignore_vss = atoi( buf ) ;

  sprintf( buf, "1" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_diaporama, "DisplayName", buf ) ;
  cfg->aff_name = atoi( buf ) ;

  sprintf( buf, "1" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_diaporama, "DisplayProg", buf ) ;
  cfg->aff_prog = atoi( buf ) ;

  /**************************************************************************/

  /*************************** Section Zoom Temps Reel **********************/
  sprintf( buf, "%d", 1 ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_rtzoom, "ObjectToZoom", buf ) ;
  cfg->rt_zoomwhat = atoi( buf ) ;

  sprintf( buf, "%d", 1 ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_rtzoom, "RespectGEM", buf ) ;
  cfg->rt_respectgem = atoi( buf ) ;

  sprintf( buf, "%d", 1 ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_rtzoom, "OptimizePosition", buf ) ;
  cfg->rt_optimizepos = atoi( buf ) ;

  sprintf( buf, "%d", 2 ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_rtzoom, "ZoomLevel", buf ) ;
  cfg->rt_zoomlevel= atoi( buf ) ;

  sprintf( buf, "%d", 128 ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_rtzoom, "RTHeight", buf ) ;
  cfg->rt_height= atoi( buf ) ;

  sprintf( buf, "%d", 128 ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_rtzoom, "RTWidth", buf ) ;
  cfg->rt_width = atoi( buf ) & 0xFFF0 ;

  sprintf( buf, "%d", haute_resolution ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_rtzoom, "UseRtZoom", buf ) ;
  cfg->use_rtzoom = atoi( buf ) ;

  /*************************************************************************/

  /************************** Section Graphics *****************************/
  sprintf( buf, "%d", mode_vswr ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "WriteMode", buf ) ;
  mode_vswr = atoi( buf ) ;

  sprintf( buf, "%d", 0 ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "EraserForm", buf ) ;
  cfg->sgomme = atoi( buf ) ;

  sprintf( buf, "%d", 0 ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "MaskOutside", buf ) ;
  if ( atoi( buf ) ) cfg->flags |= FLG_MASKOUT ;
  else               cfg->flags &= ~FLG_MASKOUT ; 

  sprintf( buf, "%d", ttype.wcar ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "TWCar", buf ) ;
  ttype.wcar = atoi( buf ) ;

  sprintf( buf, "%d", ttype.hcar ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "THCar", buf ) ;
  ttype.hcar = atoi( buf ) ;

  sprintf( buf, "%d", ttype.wcell ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "TWCell", buf ) ;
  ttype.wcell = atoi( buf ) ;

  sprintf( buf, "%d", ttype.hcell ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "THCell", buf ) ;
  ttype.hcell = atoi( buf ) ;

  sprintf( buf, "%d", ttype.angle ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "TAngle", buf ) ;
  ttype.angle = atoi( buf ) ;

  sprintf( buf, "%d", ttype.font ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "TFont", buf ) ;
  ttype.font = atoi( buf ) ;

  sprintf( buf, "%d", ttype.color ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "TColor", buf ) ;
  ttype.color = atoi( buf ) ;

  sprintf( buf, "%d", ttype.attribute ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "TAttribute", buf ) ;
  ttype.attribute = atoi( buf ) ;

  sprintf( buf, "%d", ttype.hdisp ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "THdisp", buf ) ;
  ttype.hdisp = atoi( buf ) ;

  sprintf( buf, "%d", ttype.vdisp ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "TVDisp", buf ) ;
  ttype.vdisp = atoi( buf ) ;

  sprintf( buf, "%d", ftype.style ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "FStyle", buf ) ;
  ftype.style = atoi( buf ) ;

  sprintf( buf, "%d", ftype.color ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "FColor", buf ) ;
  ftype.color = atoi( buf ) ;

  sprintf( buf, "%d", ftype.sindex ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "FSindex", buf ) ;
  ftype.sindex = atoi( buf ) ;

  sprintf( buf, "%d", ftype.perimeter ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "FPerimeter", buf ) ;
  ftype.perimeter = atoi( buf ) ;

  sprintf( buf, "%d", mtype.style ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "MStyle", buf ) ;
  mtype.style = atoi( buf ) ;

  sprintf( buf, "%d", mtype.color ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "MColor", buf ) ;
  mtype.color = atoi( buf ) ;

  sprintf( buf, "%d", mtype.height ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "MHeight", buf ) ;
  mtype.height = atoi( buf ) ;

  sprintf( buf, "%d", ltype.style ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "LStyle", buf ) ;
  ltype.style = atoi( buf ) ;

  sprintf( buf, "%d", ltype.color ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "LColor", buf ) ;
  ltype.color = atoi( buf ) ;

  sprintf( buf, "%d", ltype.st_kind ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "LStKind", buf ) ;
  ltype.st_kind = atoi( buf ) ;

  sprintf( buf, "%d", ltype.ed_kind ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "LEdKind", buf ) ;
  ltype.ed_kind = atoi( buf ) ;

  sprintf( buf, "%d", ltype.width ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "LWidth", buf ) ;
  ltype.width = atoi( buf ) ;

  sprintf( buf, "%d", 0 ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "RoundedSurfaces", buf ) ;
  if ( atoi( buf ) ) cfg->flags |= FLG_SROUND ;
  else               cfg->flags &= ~FLG_SROUND ; 

  sprintf( buf, "%d", pencil.type ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "PType", buf ) ;
  pencil.type = atoi( buf ) ;

  sprintf( buf, "%d", pencil.height ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "PHeight", buf ) ;
  pencil.height = atoi( buf ) ;

  sprintf( buf, "%d", pencil.color ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "PColor", buf ) ;
  pencil.color = atoi( buf ) ;

  /***************************** Section Log *******************************/
  config.log_file[0] = 0 ;
  save_ini |= GetOrSetIniKey( h_ini, section_log, "LogFile", config.log_file ) ;

  sprintf( buf, "%d", 0 ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_log, "LogFlags", buf ) ;
  config.log_flags = atoi( buf ) ;

  /*************************************************************************/

  /*************************** Section SnapShot ****************************/
  sprintf( buf, "%d", SF_ALLSCREEN ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_snap, "SnapFlags", buf ) ;
  config.snap_flags = atoi( buf ) ;

  sprintf( buf, "%x", SNAPSHOT ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_snap, "SnapKeyViaConfig", buf ) ;
  sscanf( buf, "%x", &config.snap_keyviaconfig ) ;

  sprintf( buf, "%x", SSNAPSHOT ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_snap, "SnapKeyDirect", buf ) ;
  sscanf( buf, "%x", &config.snap_keydirect ) ;

  /*************************************************************************/

  /*************************** Section LDV *********************************/
  sprintf( buf, "%d", 0 ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_ldv, "ShowPerf", buf ) ;
  if ( atoi( buf ) ) cfg->ldv_options |= LDVO_SHOWPERF ;
  else               cfg->ldv_options &= ~LDVO_SHOWPERF ; 

  sprintf( buf, "%d", 0 ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_ldv, "MePriority", buf ) ;
  if ( atoi( buf ) ) cfg->ldv_options |= LDVO_MEPRIORITY ;
  else               cfg->ldv_options &= ~LDVO_MEPRIORITY ; 

  sprintf( buf, "%d", LDV_PREVIEWDEFAULTSIZE ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_ldv, "PreviewSrcSize", buf ) ;
  config.ldv_preview_src_size = atoi( buf ) ;

  sprintf( buf, "%d", LDV_PREVIEWDEFAULTSIZE ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_ldv, "PreviewDstSize", buf ) ;
  config.ldv_preview_dst_size = atoi( buf ) ;

  /*************************************************************************/

  if ( save_ini )  SaveAndCloseIni( h_ini, NULL ) ;
  else             CloseIni( h_ini ) ;
}

void ajust_pathconfig(void)
{
  DTA new_dta ;
  DTA *old_dta ;

  old_dta = Fgetdta() ;
  Fsetdta( &new_dta ) ;

  if ( Fsfirst( config.path_filter, FA_SUBDIR ) )
    sprintf( config.path_filter, "%s\\FILTRES", init_path ) ;

  if ( Fsfirst( config.path_lod, FA_SUBDIR ) )
    sprintf( config.path_lod, "%s\\DSP", init_path ) ;

  Fsetdta( old_dta ) ;
}

void get_prefs(void)
{
  LoadVISIONIniFile( &config ) ;
  DspInfo.use              = config.dspuse ;
  DspInfo.WhatToDoIfLocked = config.dsphandlelock ;
  DitherMethod             = config.dither_method ;
  if ( config.flags & FLG_FORCEUSESTDVDI ) UseStdVDI = 1 ;

  ajust_pathconfig() ;
  *last_path = 0 ;
  DImgSetImgModulePath( config.path_ldv ) ;
}

void init_params(void)
{
  ltype.style   = SOLID ;
  ltype.color   = 1 ;
  ltype.st_kind = SQUARE ;
  ltype.ed_kind = SQUARE ;
  ltype.width   = 1 ;
  set_linetype( &ltype ) ;
  
  mtype.style  = 1 ;
  mtype.color  = 1 ;
  mtype.height = 1 ;
  set_markertype( &mtype ) ;
  
  ftype.style     = FIS_PATTERN ;
  ftype.color     = 1 ;
  ftype.sindex    = 8 ;
  ftype.perimeter = 1 ;
  set_filltype( &ftype ) ;
  
  ttype.hcar      = 6 ;
  ttype.color     = 1 ;
  ttype.angle     = 0 ;
  ttype.font      = 1 ;
  ttype.attribute = 0 ;
  ttype.hdisp     = 0 ;
  ttype.vdisp     = 0 ;
  set_texttype( &ttype ) ;
  
  mode_vswr = MD_REPLACE ;
}

void init_mouseforms(void)
{
  ICONBLK *micon ;
  OBJECT  *mouse_form ;
  int     *mask ;
  int     *data ;
  
  Xrsrc_gaddr(R_TREE, MOUSES, &mouse_form) ;
  
  micon                      = mouse_form[MGOMME].ob_spec.iconblk ;
  mask                       = micon->ib_pmask ;
  data                       = micon->ib_pdata ;
  mf_gomme.gr_mof.mf_xhot    = 0 ;
  mf_gomme.gr_mof.mf_yhot    = 0 ;
  mf_gomme.gr_mof.mf_nplanes = 1 ;
  mf_gomme.gr_mof.mf_fg      = 0 ;
  mf_gomme.gr_mof.mf_bg      = 1 ;
  memcpy(&mf_gomme.gr_mof.mf_mask, mask, 16*sizeof(int)) ;
  memcpy(&mf_gomme.gr_mof.mf_data, data, 16*sizeof(int)) ;

  micon                      = mouse_form[MPEINTURE].ob_spec.iconblk ;
  mask                       = micon->ib_pmask ;
  data                       = micon->ib_pdata ;
  mf_peint.gr_mof.mf_xhot    = 0 ;
  mf_peint.gr_mof.mf_yhot    = 0 ;
  mf_peint.gr_mof.mf_nplanes = 1 ;
  mf_peint.gr_mof.mf_fg      = 0 ;
  mf_peint.gr_mof.mf_bg      = 1 ;
  memcpy(&mf_peint.gr_mof.mf_mask, mask, 16*sizeof(int)) ;
  memcpy(&mf_peint.gr_mof.mf_data, data, 16*sizeof(int)) ;

  micon                      = mouse_form[MLOUPE].ob_spec.iconblk ;
  mask                       = micon->ib_pmask ;
  data                       = micon->ib_pdata ;
  mf_loupe.gr_mof.mf_xhot    = 0 ;
  mf_loupe.gr_mof.mf_yhot    = 0 ;
  mf_loupe.gr_mof.mf_nplanes = 1 ;
  mf_loupe.gr_mof.mf_fg      = 0 ;
  mf_loupe.gr_mof.mf_bg      = 1 ;
  memcpy(&mf_loupe.gr_mof.mf_mask, mask, 16*sizeof(int)) ;
  memcpy(&mf_loupe.gr_mof.mf_data, data, 16*sizeof(int)) ;

  micon                       = mouse_form[MPENCIL].ob_spec.iconblk ;
  mask                        = micon->ib_pmask ;
  data                        = micon->ib_pdata ;
  mf_pencil.gr_mof.mf_xhot    = 2 ;
  mf_pencil.gr_mof.mf_yhot    = 0 ;
  mf_pencil.gr_mof.mf_nplanes = 1 ;
  mf_pencil.gr_mof.mf_fg      = 0 ;
  mf_pencil.gr_mof.mf_bg      = 1 ;
  memcpy(&mf_pencil.gr_mof.mf_mask, mask, 16*sizeof(int)) ;
  memcpy(&mf_pencil.gr_mof.mf_data, data, 16*sizeof(int)) ;

  micon                       = mouse_form[MVISEUR].ob_spec.iconblk ;
  mask                        = micon->ib_pmask ;
  data                        = micon->ib_pdata ;
  mf_viseur.gr_mof.mf_xhot    = 7 ;
  mf_viseur.gr_mof.mf_yhot    = 7 ;
  mf_viseur.gr_mof.mf_nplanes = 1 ;
  mf_viseur.gr_mof.mf_fg      = 0 ;
  mf_viseur.gr_mof.mf_bg      = 1 ;
  memcpy(&mf_viseur.gr_mof.mf_mask, mask, 16*sizeof(int)) ;
  memcpy(&mf_viseur.gr_mof.mf_data, data, 16*sizeof(int)) ;

  micon                        = mouse_form[MAEROSOL].ob_spec.iconblk ;
  mask                         = micon->ib_pmask ;
  data                         = micon->ib_pdata ;
  mf_aerosol.gr_mof.mf_xhot    = 9 ;
  mf_aerosol.gr_mof.mf_yhot    = 2 ;
  mf_aerosol.gr_mof.mf_nplanes = 1 ;
  mf_aerosol.gr_mof.mf_fg      = 0 ;
  mf_aerosol.gr_mof.mf_bg      = 1 ;
  memcpy(&mf_aerosol.gr_mof.mf_mask, mask, 16*sizeof(int)) ;
  memcpy(&mf_aerosol.gr_mof.mf_data, data, 16*sizeof(int)) ;
}

void init_pencil(void)
{
  pencil.type   = 0 ; /* Pinceau carr‚ */
  pencil.height = 16 ;
  pencil.color  = 1 ;
}

int init_msg(void)
{
  OBJECT *adr_msg ;
  int    i = 0 ;
  int    err = 0 ;
  int    fini = 0 ;
  char   name[PATH_MAX] ;

  sprintf( name, "%s\\%s\\VMSG.RSC", config.path_language, config.language ) ;
  if ( !FileExist( name ) ) sprintf( name, "%s\\VMSG.RSC", config.language ) ;

  if ( Xrsrc_load( name ) == 0 ) return( -1 ) ;

  Xrsrc_gaddr( R_TREE, FORM_MESSAGES, &adr_msg ) ;
  i = 1 ;
  while ( !fini )
  {
    msg[i] = adr_msg[i].ob_spec.free_string ;
    if ( adr_msg[i].ob_next > 0 ) i++ ;
    else                          fini = 1 ;
  }
  for ( i = MSG_UNDO; i <= MSG_UEND; i++ ) undo_item[i-MSG_UNDO] = msg[i] ;

  return( err ) ;
}

void get_languages(void)
{
  DTA  dta, *old_dta ;
  char name[PATH_MAX] ;
  char rsc_name[PATH_MAX] ;
  int  ret ;
  int  i = 0 ;

  sprintf( name, "%s\\*.*", config.path_language ) ;
  old_dta = Fgetdta() ;
  Fsetdta( &dta ) ;
  ret = Fsfirst( name, FA_SUBDIR ) ;
  while ( ret == 0 )
  {
    if ( ( dta.d_fname[0] != '.' ) && ( dta.d_attrib & FA_SUBDIR ) )
    {
      sprintf( rsc_name, vision_rsc_access, config.path_language, dta.d_fname ) ;
      if ( FileExist( rsc_name ) )
      {
        sprintf( rsc_name, "%s\\%s\\VISIONB.RSC", config.path_language, dta.d_fname ) ;
        if ( FileExist( rsc_name ) )
        {
          sprintf( rsc_name, "%s\\%s\\VMSG.RSC", config.path_language, dta.d_fname ) ;
          if ( FileExist( rsc_name ) )
            strcpy( config.all_languages[i++], dta.d_fname ) ;
        }
      }
    }
    ret = Fsnext() ;
  }

  config.nb_languages = i ;
  Fsetdta( old_dta ) ;
}
/*
void gen(void)
{
  unsigned char mat[256] = {
   34, 05, 21, 44, 32, 03, 20, 42, 33, 04, 21, 43, 35, 06, 22, 44,
   15, 50, 28, 12, 13, 48, 26, 10, 14, 49, 27, 11, 15, 51, 28, 12,
   31,  8, 18, 47, 29,  7, 16, 45, 30,  8, 17, 46, 32,  9, 19, 48,
   25, 41, 37, 02, 23, 39, 36,  0, 24, 40, 37,  1, 25, 41, 38, 03,
   33,  4, 20, 43, 35,  6, 22, 45, 34,  5, 21, 43, 33,  4, 20, 42,
   14, 49, 27, 10, 16, 51, 29, 13, 14, 50, 27, 11, 13, 49, 26, 10,
   30,  7, 17, 46, 32,  9, 19, 48, 31,  8, 18, 47, 30,  7, 17, 46,
   23, 39, 36,  1, 26, 42, 38,  3, 24, 40, 37,  2, 23, 39, 36,  1,
   34,  5, 21, 44, 33,  4, 20, 42, 33,  4, 20, 43, 35,  6, 22, 45,
   15, 50, 28, 11, 13, 49, 26, 10, 14, 49, 27, 11, 16, 51, 29, 12,
   31,  8, 18, 47, 29,  7, 16, 45, 30,  7, 17, 46, 32,  9, 19, 48,
   24, 40, 37,  2, 23, 39, 36,  0, 24, 40, 36,  1, 25, 41, 38, 03,
   34,  5, 21, 43, 35,  6, 22, 44, 34,  5, 22, 44, 32,  3, 19, 42,
   14, 50, 27, 11, 15, 51, 28, 12, 15, 50, 28, 12, 13, 48, 26, 10,
   30,  8, 18, 46, 31,  9, 19, 47, 31,  9, 18, 47, 29,  6, 16, 45,
   24, 40, 37,  1, 25, 41, 38, 02, 25, 41, 38,  2, 23, 39, 35,  0
                        } ;
  int i, j, k=0 ;
  unsigned char m ;
  FILE *s = fopen( "mat16.s", "wb" ) ;

  for ( i = 0; i < 16; i++ )
  {
    fprintf( s, "\nDC.B     " ) ;
    for ( j = 0; j < 16; j++ )
    {
      m = (unsigned char) (0.5 + (float)mat[k++]*40.0/51.0 ) ;
      fprintf( s, "%02d, ", m ) ;
    }
  }
  
  fclose( s ) ;
}
*/

#pragma warn -par
int OnAppMouseMove(int bbutton, int mk_state, int mx, int my)
{
  static int nb = 0 ;

  if ( config.rt_zoomwhat == RTZ_SMART ) rtzoom_display( mx, my, 0 ) ;
  else                                   rtzoom_display( mx, my, config.rt_zoomwhat ) ;

  nb++ ;
  if ( key_protect2 && ( ( nb & 0x3FF ) == 0x3FF ) )
  {
    unsigned long modulo ;

    if ( key_protect2 ) modulo = 10 + CountNbBits( ident.user[2], 1 ) ;

    if ( key_protect2 % modulo ) sfault() ; /* ANTI-CRACK */
  }

  return( GW_EVTCONTINUEROUTING ) ;
}
#pragma warn +par

void OnTerminateApp(void *ap)
{
  GEM_APP *app = (GEM_APP *) ap ;

  if ( config.log_stream ) fclose( config.log_stream ) ;

  ReleaseTCWheel() ;

  cleanup_filters() ;

  FreeClipboard() ;

  LDVFreeAllModules() ;
  TerminateImgLib() ;

  if ( key_protect != key_protect2 )
  {
    FILE *stream ;
    char buffer[PATH_MAX] ;

    sprintf( buffer, vision_prg_access, init_path ) ;
    stream = fopen( buffer, "rb+" ) ;
    if ( stream )
    {
      long to_be_written[30] ;
      long offset = (long) clock() ;

      /* ANTI-CRACK */
      offset %= 0x5FFFFL ;
      fseek( stream, offset, SEEK_SET ) ;
      fwrite( to_be_written, sizeof(to_be_written), 1, stream ) ;
      fclose ( stream ) ;
    }
    else poke0() ;
  }

  if ( Gdos ) vst_unload_fonts( handle, 0 ) ;
  menu_bar( app->Menu, 0 ) ;
  Xrsrc_free() ;
}

void OnOpenFileApp(char *name)
{
  char ext[10] ;

  get_ext( name, ext ) ;
  if ( strcmpi( ext, "VIC" ) == 0 ) traite_album( name ) ;
  else
  if ( strcmpi( ext, "VSS" ) == 0 ) traite_slideshow( name ) ;
  else                              load_wpicture( name, 0 ) ;
}

#pragma warn -par
int OnAppTimer(int mx, int my)
{
  long modulo = 0 ;

  if ( !IsRegistered ) return( GW_EVTCONTINUEROUTING ) ;

  nb_timers++ ;
  if ( ( nb_timers & 0x03 ) == 0x03 )
  {
    if ( key_protect ) modulo = 10 + CountNbBits( ident.user[2], 1 ) ;

    if ( key_protect % modulo ) stack_fault() ; /* ANTI-CRACK */
  }

  return( GW_EVTCONTINUEROUTING ) ;
}

int OnAppUnknownMsg(void *app, int *msg)
{
  int           code = 0 ;
/*  LDG           *ldg ;
  unsigned long lsb, msb ;
  int           ldg_err ;
  char          buf[50] ;

  switch( msg[0] )
  {
    case LDG_QUIT  : lsb = (unsigned long) msg[4] ;
                     msb = (unsigned long) msg[3] ;
                     ldg = (LDG *) ( ( msb << 16 ) + lsb ) ;
                     LDVTerminate( ldg ) ;
                     break ;

    case LDG_ERROR : ldg_err = ldg_error() ;
                     sprintf( buf, "[LDG Error %d][ OK ]", ldg_err ) ;
                     form_stop( 1, buf ) ;
                     break ;
  }
*/
  return( code ) ;
}
#pragma warn +par

void SetLibPriority(int me_is_priority)
{
  LIB_ID libs[2] ;

  memset( libs, 0, sizeof(libs) ) ;
  if ( me_is_priority )
  {
    libs[0].id = P_ME ;
    libs[1].id = P_LDV ;
  }
  else
  {
    libs[0].id = P_LDV ;
    libs[1].id = P_ME ;
  }

  SetLibPriorities( libs, (int)(sizeof(libs)/sizeof(libs[0])) ) ;
}

int OnInitApp(void *ap)
{
  GEM_APP    *app = (GEM_APP *) ap ;
  GEM_WINDOW *splash = NULL ;
  int        err ;
  int        x, y, w, h ;
  char       rsc_name[PATH_MAX] ;
  char       buf[PATH_MAX] ;
  
  haute_resolution = (Xmax > 512) && (Ymax > 384) ;
  init_params() ;
  init_pencil() ;

  get_prefs() ;
  get_languages() ;

  err = init_msg() ;
  switch( err )
  {
    case 0  : break ; /* OK */

	case -1 : v_show_c(handle, 1) ;
	          do
	          {
	            sprintf( buf, "[%s\\VISION.INI file|is bad or missing!|Would you find it for me?][Find...| End ]", init_path ) ;
	            if ( form_stop( 1, buf ) == 1 )
	            {
	              char path[PATH_MAX], name[PATH_MAX] ;

                  sprintf( path, "%s\\VISION.INI", init_path ) ;
	              if ( file_name( path, "", name ) == 1 )
	              {
	                char *slash = strrchr( name, '\\' ) ;
	              
	                if ( slash )
	                {
	                  *slash = '\0' ;
	                  strcpy( init_path, name ) ;
                      get_prefs() ;
                      get_languages() ;
                      err = init_msg() ;
                    }
                    else err = 1 ;
	              }
	              else return( 1 ) ;
	            }
	            else return( 1 ) ;
	          }
	          while ( err ) ;
	          break ;

	case 1  : form_error( 8 ) ; /* M‚moire insuffisante */
	          return( 1 ) ;
  }

  graf_mouse( BUSYBEE, NULL ) ;

  sprintf( rsc_name, "%s\\BULLE.RSC", config.path_language ) ;
  BHelpSetRSCFile( rsc_name ) ;

  if ( haute_resolution )
  {
    sprintf( rsc_name, vision_rsc_access, config.path_language, config.language ) ;
    if ( !FileExist( rsc_name ) )
      sprintf( rsc_name, vision_rsc_access, config.language ) ;
  }
  else
  {
    sprintf( rsc_name, "%s\\%s\\VISIONB.RSC", config.path_language, config.language ) ;
    if ( !FileExist( rsc_name ) )
      sprintf( rsc_name, "%s\\VISIONB.RSC", config.language ) ;
  }

  if ( Xrsrc_load( rsc_name ) == 0 )
  {
	v_show_c( handle, 1 ) ;
	sprintf( buf, "[File %s is missing !][ End ]", rsc_name ) ;
	form_stop( 1, buf ) ;

	return( 1 ) ;
  }

  GWSetMenu( M_VISION, MENU_NAME ) ;
  GWSetMenuStatus( 0 ) ;

  DImgGetImgModules( config.path_ldv, NULL, NULL, 0 ) ;
  graf_mouse( ARROW, NULL ) ;
  if ( config.flags & FLG_SPLASH ) splash = display_splash() ;

  if ( Gdos ) num_fonts = vst_load_fonts( handle, 0 ) ;
  else        num_fonts = 0 ;

  if ( splash ) GWDestroyWindow( splash ) ;
  init_data() ;

  if ( !haute_resolution )
  {
    app->Menu[M_UNDO-1].ob_x   = 96 ;
    app->Menu[M_PLEIN-1].ob_x  = 110 ;
    app->Menu[M_OPOINT-1].ob_x = 110 ;
    app->Menu[M_OTRACE-1].ob_x = 110 ;
    app->Menu[M_TZOOMS-1].ob_x = 110 ;
  }
  else
    app->Menu[M_TZOOMS-1].ob_x = 400 ;

  if ( Truecolor ) menu_ienable( app->Menu, M_PALETTE, 0 ) ;

  if ( IsRegistered ) key_protect = KeyDecrypt( ident.crypted_key ) ;

  VToolBarInit( haute_resolution ) ;

  init_mouseforms() ;

  if ( config.use_rtzoom ) rtzoom_init() ;

  if ( config.log_file[0] != 0 )
  {
    char buf[PATH_MAX] ;
    char mode[10] = "wb" ;

    if ( config.log_file[1] != ':' ) /* Chemin relatif demand‚ */
      sprintf( buf, "%s\\%s", init_path, config.log_file ) ; 
    else
      strcpy( buf, config.log_file ) ;
    if ( config.log_flags & LF_FLGAPPEND ) strcpy( mode, "ab+" ) ;
    config.log_stream = fopen( buf, mode ) ;
  }
  else config.log_stream = NULL ;

  GWSetTimer( NULL, 4L * 1000L ) ; /* Timer pour la protection */

  app->OnKeyPressed   = OnAppKeyPressed ;
  app->OnMenuSelected = OnAppMenuSelected ;
  app->OnMouseMove    = OnAppMouseMove ;
  app->OnUpdateGUI    = OnAppUpdateGUI ;
  app->OnTerminate    = OnTerminateApp ;
  app->OnOpenFile     = OnOpenFileApp ;
  app->OnTimer        = OnAppTimer ;
  app->OnUnknownMsg   = OnAppUnknownMsg ;

  set_goodmouse() ;

  if ( config.flags & FLG_LONGFNAME ) Pdomain( 1 ) ;
  
  key_protect2 = key_protect ;

  if ( WndToolBar && ( WndToolBar->flags & FLG_ISVISIBLE ) )
  {
    GWGetCurrXYWH( WndToolBar, &x, &y, &w, &h ) ;
    if ( haute_resolution )
    {
      xopen = x+w ;
      yopen = ydesk ;
    }
    else
    {
      xopen = xdesk ;
      yopen = y+h ;
    }
  }
  else
  {
    xopen = xdesk ;
    yopen = ydesk ;
  }
  CreateImgBrowser( NULL ) ;

  check_user() ;

  SetLibPriority( (int) (config.ldv_options & LDVO_MEPRIORITY) ) ;

  return( err ) ;
}

int main(int argc, char **argv)
{
  GEM_APP *theApp ;

#ifdef MEMDEBUG
  set_MemdebugOptions( c_Yes, c_Yes, c_Yes, c_Yes, c_Yes, c_Yes, c_Yes, 
                      0L, 0,
                      "D:\\VSTATS.MEM",
                      "D:\\VERROR.MEM"
                     ) ;
#endif

  theApp = GWGetApp( argc, argv ) ;

  theApp->OnInit = OnInitApp ;
  GWDeclareAndRunApp( theApp ) ;

  return( 0 ) ;
}
