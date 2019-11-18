/*****************************************/
/* Programme principal du Project VISION */
/* (c) LUSETTI Jean Aout 1993            */
/*****************************************/
#include  <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stddef.h>

#include       "..\tools\ini.h"
#include   "..\tools\stdprog.h"
#include  "..\tools\stdinput.h"
#include      "..\tools\xgem.h"
#include     "..\tools\xmint.h"
#include     "..\tools\xfile.h"
#include  "..\tools\gwindows.h"
#include     "..\tools\aides.h"
#include    "..\tools\dither.h"
#include  "..\tools\imgmodul.h"
#include   "..\tools\cookies.h"
#include  "..\tools\rasterop.h"
#include   "..\tools\logging.h"
#include    "..\tools\msgtxt.h"
#include  "..\tools\chkstack.h"

#include     "defs.h"
#include     "undo.h"
#include   "gstenv.h"
#include   "rtzoom.h"
#include  "actions.h"
#include  "touches.h"
#include "visionio.h"
#include "vsldshow.h"
#include "vtoolbar.h"
#include "ibrowser.h"
#include "vcscript.h"

#include "forms\ftcwheel.h"
#include "forms\ffilter.h"
#include "forms\fbaratin.h"
#include "forms\falbum.h"

#include "ldv\ldvcom.h"
#include "forms\fldv.h"

char high_res ;

static char section_general[]      = "General" ;
static char section_folders[]      = "Folders" ;
static char section_dsp[]          = "DSP" ;
static char section_diaporama[]    = "SlideShow" ;
static char section_undo[]         = "Undo" ;
static char section_rtzoom[]       = "Real Time Zoom" ;
static char section_graphics[]     = "Graphics" ;
static char section_log[]          = "Log" ;
static char section_snap[]         = "SnapShot" ;
static char section_ldv[]          = "LDV" ;
static char section_logging[]      = "Logging" ;
static char section_img_mod_prio[] = "Img Priorities" ;

static char vision_rsc_access[] = "%s\\%s\\VISION.RSC" ;

HMSG        hMsg ;
VCMD_SCRIPT VCmdScript ;


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

long SaveVISIONIniFile(VISION_CFG* cfg)
{
  HINI  h_ini ;
  char  buf[PATH_MAX] ;
  char  tmp[16] ;
  char* c ;

  sprintf( buf, "%s\\VISION.INI", init_path ) ;
  h_ini = OpenIni( buf ) ;

  LoggingDo(LL_INFO, "Saving INI file %s", buf) ;

  /*********************** Section GENERAL ****************************/
  sprintf( buf, "%s", cfg->language ) ;
  SetIniKey( h_ini, section_general, "Language", buf ) ;

  if ( cfg->flags & FLG_HELP ) strcpy( buf, "1" ) ;
  else                         strcpy( buf, "0" ) ;
  SetIniKey( h_ini, section_general, "HelpBubbles", buf ) ;

  if ( cfg->flags & FLG_DITHERAUTO ) strcpy( buf, "1" ) ;
  else                               strcpy( buf, "0" ) ;
  SetIniKey( h_ini, section_general, "DitherAuto", buf ) ;

  sprintf( buf, "%u", cfg->flag_fullscreen ) ;
  SetIniKey( h_ini, section_general, "FullScreen", buf ) ;

  sprintf( buf, "%u", cfg->w_info ) ;
  SetIniKey( h_ini, section_general, "InfoBar", buf ) ;

  sprintf( buf, "%u", cfg->quitte ) ;
  SetIniKey( h_ini, section_general, "QuitIfNoWindow", buf ) ;

  sprintf( buf, "%u", cfg->clip_gem ) ;
  SetIniKey( h_ini, section_general, "UseGEMClipboard", buf ) ;

  sprintf( buf, "%u", cfg->souris_viseur ) ;
  SetIniKey( h_ini, section_general, "CrossMouse", buf ) ;

  sprintf( buf, "%u", cfg->color_protect ) ;
  SetIniKey( h_ini, section_general, "ColorProtection", buf ) ;

  sprintf( buf, "%u", cfg->dither_method ) ;
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

  sprintf( buf, "%d", cfg->rsrc_choice ) ;
  SetIniKey( h_ini, section_general, "RsrcChoice", buf ) ;

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

  sprintf( buf, "%s", cfg->path_zvldg ) ;
  SetIniKey( h_ini, section_folders, "zvLDG", buf ) ;

#ifdef MST_ZVSLB
  sprintf( buf, "%s", cfg->path_zvslb ) ;
  SetIniKey( h_ini, section_folders, "zvSLB", buf ) ;
#endif
  /**************************************************************************/

  /*************************** Section DSP **********************************/
  sprintf( buf, "%u", cfg->dspuse ) ;
  SetIniKey( h_ini, section_dsp, "UseDSP", buf ) ;

  sprintf( buf, "%u", cfg->dsphandlelock ) ;
  SetIniKey( h_ini, section_dsp, "HandleLock", buf ) ;

  /**************************************************************************/

  /********************** Section UNDO *********************************/
  sprintf( buf, "%d", cfg->nb_undo ) ;
  SetIniKey( h_ini, section_undo, "NbBuffers", buf ) ;
  if ( cfg->nb_undo < 0 ) cfg->nb_undo = 0 ;
  if ( cfg->nb_undo > MAX_UNDO ) cfg->nb_undo = MAX_UNDO ;

  sprintf( buf, "%u", cfg->type_undo ) ;
  SetIniKey( h_ini, section_undo, "Type", buf ) ;

  sprintf( buf, "%d", cfg->ko_undo ) ;
  SetIniKey( h_ini, section_undo, "UseDiskIfKo", buf ) ;

  sprintf( buf, "%u", cfg->use_redo ) ;
  SetIniKey( h_ini, section_undo, "UseRedo", buf ) ;

  /**************************************************************************/

  /*************************** Section Diaporama ****************************/
  sprintf( buf, "%d", cfg->wait_mini_sec ) ;
  SetIniKey( h_ini, section_diaporama, "WaitMiniSec", buf ) ;

  sprintf( buf, "%u", cfg->do_not_show_mouse ) ;
  SetIniKey( h_ini, section_diaporama, "HideMouse", buf ) ;

  sprintf( buf, "%u", cfg->do_not_cls_scr ) ;
  SetIniKey( h_ini, section_diaporama, "DoNotClearScreen", buf ) ;

  sprintf( buf, "%u", cfg->cycle ) ;
  SetIniKey( h_ini, section_diaporama, "Cycle", buf ) ;

  sprintf( buf, "%d", cfg->back ) ;
  SetIniKey( h_ini, section_diaporama, "BackGroundColor", buf ) ;

  sprintf( buf, "%u", cfg->display_type ) ;
  SetIniKey( h_ini, section_diaporama, "DisplayType", buf ) ;

  sprintf( buf, "%u", cfg->transition ) ;
  SetIniKey( h_ini, section_diaporama, "Transition", buf ) ;

  sprintf( buf, "%u", cfg->ignore_vss ) ;
  SetIniKey( h_ini, section_diaporama, "IgnoreVSS", buf ) ;

  sprintf( buf, "%u", cfg->aff_name ) ;
  SetIniKey( h_ini, section_diaporama, "DisplayName", buf ) ;

  sprintf( buf, "%u", cfg->aff_prog ) ;
  SetIniKey( h_ini, section_diaporama, "DisplayProg", buf ) ;

  /**************************************************************************/

  /*************************** Section Zoom Temps Reel **********************/
  sprintf( buf, "%u", cfg->rt_zoomwhat ) ;
  SetIniKey( h_ini, section_rtzoom, "ObjectToZoom", buf ) ;

  sprintf( buf, "%u", cfg->rt_respectgem ) ;
  SetIniKey( h_ini, section_rtzoom, "RespectGEM", buf ) ;

  sprintf( buf, "%u", cfg->rt_optimizepos ) ;
  SetIniKey( h_ini, section_rtzoom, "OptimizePosition", buf ) ;

  sprintf( buf, "%u", cfg->use_rtzoom ) ;
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

  /***************************** Section Log ********************************/
  SetIniKey( h_ini, section_log, "LogFile", config.log_file ) ;

  sprintf( buf, "%u", config.log_flags ) ;
  SetIniKey( h_ini, section_log, "LogFlags", buf ) ;

  /*************************************************************************/

  /*************************** Section SnapShot ****************************/
  sprintf( buf, "%u", config.snap_flags ) ;
  SetIniKey( h_ini, section_snap, "SnapFlags", buf ) ;

  /*************************** Section LDV  ********************************/
  sprintf( buf, "%d", ( config.ldv_options & LDVO_HIDE030 ) ? 1 :0 ) ;
  SetIniKey( h_ini, section_ldv, "Hide030", buf ) ;

  sprintf( buf, "%d", ( config.ldv_options & LDVO_HIDEDSP ) ? 1 :0 ) ;
  SetIniKey( h_ini, section_ldv, "HideDSP", buf ) ;

  sprintf( buf, "%d", ( config.ldv_options & LDVO_HIDEFPU ) ? 1 :0 ) ;
  SetIniKey( h_ini, section_ldv, "HideFPU", buf ) ;

  sprintf( buf, "%d", config.ldv_preview_src_size ) ;
  SetIniKey( h_ini, section_ldv, "PreviewSrcSize", buf ) ;

  sprintf( buf, "%d", config.ldv_preview_dst_size ) ;
  SetIniKey( h_ini, section_ldv, "PreviewDstSize", buf ) ;

  /*************************************************************************/

  /***************************** Section Logging *******************************/
  SetIniKey( h_ini, section_logging, "LoggingFile", config.logging_file ) ;

  sprintf( buf, "%lx", config.logging_flags ) ;
  SetIniKey( h_ini, section_logging, "LoggingFlags", buf ) ;

  sprintf( buf, "%d", config.logging_flushfreq ) ;
  SetIniKey( h_ini, section_logging, "LoggingFlushFreq", buf ) ;

  /****************** Section Image Module Priorities ******************/
  c = &config.im_priority_global[0] ;
  buf[0] = 0 ;
  while ( *c )
  {
    sprintf( tmp, "%c", *c ) ;
    strcat( buf, tmp ) ;
    c++ ;
    if ( *c ) strcat( buf, "," ) ;
  }
  SetIniKey( h_ini, section_img_mod_prio, "Global", buf ) ;

  /*************************************************************************/

  return( SaveAndCloseIni( h_ini, NULL ) ) ;
}

long LoadImgPriorities(HINI h_ini, VISION_CFG* cfg)
{
  long save_ini ;
  char p[NB_MST_MAX] ;
  int  n ;
  char buf[PATH_MAX] ;

  memset( cfg->im_priority_global, 0, sizeof(cfg->im_priority_global) ) ;
  strcpy( buf, "1,3,2" ) ;
  save_ini = GetOrSetIniKey( h_ini, section_img_mod_prio, "Global", buf ) ;
  n = sscanf( buf, "%c,%c,%c", &p[0], &p[1], &p[2] ) ;
  if ( n > NB_MST_MAX ) n = NB_MST_MAX ;
  if ( n > 0 )
  {
    char* pp = &p[0] ;
    char* c = &cfg->im_priority_global[0] ;

    while ( n )
    {
      *c++ = *pp++ ;
      n-- ;
    }
  }
  else
  {
    cfg->im_priority_global[0] = MST_LDI ;
#ifdef MST_ZVSLB
    cfg->im_priority_global[1] = MST_ZVSLB ;
    cfg->im_priority_global[2] = MST_ZVLDG ;
#else
    cfg->im_priority_global[1] = MST_ZVLDG ;
#endif
  }

  return save_ini ;
}

void LoadVISIONIniFile(VISION_CFG* cfg)
{
  HINI h_ini ;
  long save_ini = 0 ;
  char buf[PATH_MAX] ;

  memset( cfg, 0, sizeof(VISION_CFG) ) ;
  strcpy( cfg->version, NO_VERSION ) ;
  sprintf( buf, "%s\\VISION.INI", init_path ) ;
  if ( !FileExist( buf ) )
  {
    sprintf( buf, "VISION.INI" ) ;
    save_ini = 1 ;
  }

  LoggingDo(LL_INFO, "Loading VISION INI file %s...", buf) ;
  h_ini = OpenIni( buf ) ;

  /*********************** Section GENERAL ****************************/
  sprintf( buf, "%s", "FRANCAIS" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_general, "Language", buf ) ;
  strcpy( cfg->language, buf ) ;

#ifndef __NO_BUBBLE
  strcpy( buf, "1" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_general, "HelpBubbles", buf ) ;
  if ( atoi( buf ) != 0 ) cfg->flags |= FLG_HELP ;
  if ( cfg->flags & FLG_HELP ) GemApp.Flags.HelpBubbles = 1 ;
  else                         GemApp.Flags.HelpBubbles = 0 ;
#else
  GemApp.Flags.HelpBubbles = 0 ;
#endif

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

  strcpy( buf, "-1" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_general, "RsrcChoice", buf ) ;
  cfg->rsrc_choice = atoi( buf ) ;

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

  buf[0] = 0 ;
  save_ini |= GetOrSetIniKey( h_ini, section_folders, "zvLDG", buf ) ;
  strcpy( cfg->path_zvldg, buf ) ;

#ifdef MST_ZVSLB
  buf[0] = 0 ;
  save_ini |= GetOrSetIniKey( h_ini, section_folders, "zvSLB", buf ) ;
  strcpy( cfg->path_zvslb, buf ) ;
#endif
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

  sprintf( buf, "%d", high_res ) ;
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
  cfg->log_file[0] = 0 ;
  save_ini |= GetOrSetIniKey( h_ini, section_log, "LogFile", cfg->log_file ) ;
  sprintf( buf, "%d", 0 ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_log, "LogFlags", buf ) ;
  cfg->log_flags = atoi( buf ) ;

  /*************************************************************************/

  /*************************** Section SnapShot ****************************/
  sprintf( buf, "%d", SF_ALLSCREEN ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_snap, "SnapFlags", buf ) ;
  cfg->snap_flags = atoi( buf ) ;

  sprintf( buf, "%x", SNAPSHOT ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_snap, "SnapKeyViaConfig", buf ) ;
  sscanf( buf, "%x", &cfg->snap_keyviaconfig ) ;

  sprintf( buf, "%x", SSNAPSHOT ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_snap, "SnapKeyDirect", buf ) ;
  sscanf( buf, "%x", &cfg->snap_keydirect ) ;

  /*************************************************************************/

  /*************************** Section LDV *********************************/
  cfg->ldv_options = 0 ;
  sprintf( buf, "%d", 0 ) ;

  sprintf( buf, "%d", 0 ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_ldv, "Hide030", buf ) ;
  if ( atoi( buf ) ) cfg->ldv_options |= LDVO_HIDE030 ;

  sprintf( buf, "%d", 0 ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_ldv, "HideDSP", buf ) ;
  if ( atoi( buf ) ) cfg->ldv_options |= LDVO_HIDEDSP ;

  sprintf( buf, "%d", 0 ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_ldv, "HideFPU", buf ) ;
  if ( atoi( buf ) ) cfg->ldv_options |= LDVO_HIDEFPU ;

  sprintf( buf, "%d", LDV_PREVIEWDEFAULTSIZE ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_ldv, "PreviewSrcSize", buf ) ;
  cfg->ldv_preview_src_size = atoi( buf ) ;

  sprintf( buf, "%d", LDV_PREVIEWDEFAULTSIZE ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_ldv, "PreviewDstSize", buf ) ;
  cfg->ldv_preview_dst_size = atoi( buf ) ;

  /************************* Section Logging **************************/
  /* Note that is information is already read & used since SetupRoots */
  strcpy( cfg->logging_file, "vision.log" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_logging, "LoggingFile", cfg->logging_file ) ;

  sprintf( buf, "%lx", LF_CLRLOGSONSTART | LL_FATAL | LL_ERROR | LL_WARNING | LL_INFO ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_logging, "LoggingFlags", buf ) ;
  sscanf( buf, "%lx", &cfg->logging_flags ) ;

  sprintf( buf, "%d", 1 ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_logging, "LoggingFlushFreq", buf ) ;
  cfg->logging_flushfreq = atoi( buf ) ;

  /****************** Section Image Module Priorities ******************/
  save_ini |= LoadImgPriorities( h_ini, cfg ) ;

  /*************************************************************************/

  if ( save_ini )  SaveAndCloseIni( h_ini, NULL ) ;
  else             CloseIni( h_ini ) ;

  LoggingDo(LL_INFO, "VISION INI loaded!") ;
}

void ajust_pathconfig(void)
{
  char  tmp[PATH_MAX] ;
  char* path ;
  int   save_ini = 0 ;

  path = config.path_img ;
  if ( (path[0] == 0) || !FolderExist(path) )
  {
    sprintf( tmp, "%c:\\", init_path[0] ) ;
    LoggingDo(LL_INFO, "Image path %s does not exist, setting it to %s", path, tmp) ;
    strcpy( path, tmp ) ;
    save_ini = 1 ;
  }

  path = config.path_album ;
  if ( (path[0] == 0) || !FolderExist(path) )
  {
    sprintf( tmp, "%c:\\", init_path[0] ) ;
    LoggingDo(LL_INFO, "Album path %s does not exist, setting it to %s", path, tmp) ;
    strcpy( path, tmp ) ;
    save_ini = 1 ;
  }

  path = config.path_lod ;
  if ( (path[0] == 0) || !FolderExist(path) )
  {
    sprintf( tmp, "%s\\DSP", init_path ) ;
    LoggingDo(LL_INFO, "DSP path %s does not exist, setting it to %s", path, tmp) ;
    strcpy( path, tmp ) ;
    save_ini = 1 ;
  }

  path = config.path_language ;
  if ( (path[0] == 0) || !FolderExist(path) )
  {
    sprintf( tmp, "%s\\LANGUES", init_path ) ;
    LoggingDo(LL_INFO, "Language path %s does not exist, setting it to %s", path, tmp) ;
    strcpy( path, tmp ) ;
    save_ini = 1 ;
  }

  path = config.path_temp ;
  if ( (path[0] == 0) || !FolderExist(path) )
  {
    sprintf( tmp, "%s\\TEMP", init_path ) ;
    LoggingDo(LL_INFO, "Temporary path %s does not exist, setting it to %s", path, tmp) ;
    strcpy( path, tmp ) ;
    if ( !FolderExist(path) ) Dcreate( path ) ;
    save_ini = 1 ;
  }

  path = config.path_filter ;
  if ( (path[0] == 0) || !FolderExist(path) )
  {
    sprintf( tmp, "%s\\FILTRES", init_path ) ;
    LoggingDo(LL_INFO, "Filters path %s does not exist, setting it to %s", path, tmp) ;
    strcpy( path, tmp ) ;
    save_ini = 1 ;
  }

  path = config.path_ldv ;
  if ( (path[0] == 0) || !FolderExist(path) )
  {
    sprintf( tmp, "%s\\LDV", init_path ) ;
    LoggingDo(LL_INFO, "LDV path %s does not exist, setting it to %s", path, tmp) ;
    strcpy( path, tmp ) ;
    save_ini = 1 ;
  }

  path = config.path_zvldg ;
  if ( (path[0] == 0) || !FolderExist(path) )
  {
    tmp[0] = 0 ;
    LoggingDo(LL_INFO, "zView LDG path %s does not exist, VISION won't use any zView LDG plugin", path) ;
    strcpy( path, tmp ) ;
  }

#ifdef MST_ZVSLB
  path = config.path_zvslb ;
  if ( (path[0] == 0) || !FolderExist(path) )
  {
    tmp[0] = 0 ;
    LoggingDo(LL_INFO, "zView SLB path %s does not exist, VISION won't use any zView SLB plugin", path) ;
    strcpy( path, tmp ) ;
  }
#endif

  if ( save_ini )
    SaveVISIONIniFile( &config ) ;
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
  ICONBLK* micon ;
  OBJECT*  mouse_form ;
  int*     mask ;
  int*     data ;
  
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
  char name[PATH_MAX] ;

/* This block was used to generate VMSG.TXT files after loading VSMG.RSC
  {
    FILE* stream ;

    sprintf( name, "%s\\%s\\VMSG.TXT", config.path_language, config.language ) ;
    stream = fopen( name, "w" ) ;
    if ( stream )
    {
      int   j ;
      char  buf[512] ;
 
      for ( i = 1; i < MSG_ENDLIST; i++ )
      {
        strcpy( buf, mesg[i] ) ;
        for ( j = 0; j< strlen(buf)-1; j++ )
          if ( ( buf[j] == '\r' ) && ( buf[1+j] == '\n' ) )
          {
            buf[j] = '\\' ;
            buf[1+j] = 'n' ;
          }
        fprintf( stream, "%d:%s\n", i, buf ) ;
      }
      fclose( stream ) ;
    }
  }
 It has just been used once */
 
  sprintf( name, "%s\\%s\\VMSG.TXT", config.path_language, config.language ) ;
  if ( !FileExist( name ) )
    sprintf( name, "LANGUES\\%s\\VMSG.TXT", config.language ) ;
  hMsg = MsgTxtLoadFile( name ) ;
  if ( hMsg == NULL )
  {
    char buf[128+PATH_MAX] ;

    LoggingDo(LL_FATAL, "Can't locate VMSG.TXT, you should delete VISION.INI for a fresh start") ;
    sprintf( buf, "[File VMSG.TXT is missing !|You should delete VISION.INI|for a fresh start!][ End ]" ) ;
    form_stop( 1, buf ) ; 
  }

  return( hMsg ? 0:-1 ) ; /* -1: file not found, i.e. INI is wrong */
}

void get_languages(void)
{
  DTA  dta ;
  DTA* old_dta ;
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
          sprintf( rsc_name, "%s\\%s\\VMSG.TXT", config.path_language, dta.d_fname ) ;
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
  if ( config.rt_zoomwhat == RTZ_SMART ) rtzoom_display( mx, my, 0 ) ;
  else                                   rtzoom_display( mx, my, config.rt_zoomwhat ) ;

  return GW_EVTCONTINUEROUTING ;
}
#pragma warn +par

void OnTerminateApp(void* ap)
{
  GEM_APP* app = (GEM_APP*) ap ;

  if ( config.log_stream ) fclose( config.log_stream ) ;

  ReleaseTCWheel() ;

  cleanup_filters() ;

  FreeClipboard() ;

  LDVFreeAllModules() ;
  TerminateImgLib() ;

#ifndef __NO_BUBBLE
  BHelpExit() ;
#endif

  if ( Gdos ) vst_unload_fonts( handle, 0 ) ;
  menu_bar( app->Menu, 0 ) ;
  Xrsrc_free() ;
  MsgTxtFreeMsg( hMsg ) ;
#ifndef __NO_SCRIPT
  FreeScript( &VCmdScript ) ;
#endif
}

static void traite_command_script(char* name)
{
  short status ;

  /*strcpy( name, "H:\\PURE_C\\PROJECTS\\VISION\\SCRIPTS\\main.vcs" ) ;*/
  status = LoadCommandScript( name, &VCmdScript ) ;
  if ( status == SVCS_SUCCESS )
  {
    int mesg[4] ;

    *((VCMD_SCRIPT**)mesg) = &VCmdScript ;
    LoggingDo(LL_INFO, "Vision is in script mode on %s", name) ;
    PostMessage( NULL, WM_CMDSCRIPT_EXELINE, mesg ) ;
  }
  else LoggingDo(LL_ERROR, "Command Script %s failed to load with %d", name, status) ;
}

#pragma warn -par
static int OnAppMsgUser(void* app, int id, int* mesg)
{
  int ret = 0 ;

#ifndef __NO_SCRIPT
  if ( id == WM_CMDSCRIPT_EXELINE )
  {
    VCMD_SCRIPT* vcmd_script = *((VCMD_SCRIPT**)mesg) ;
    int          continue_script = 1 ;
    short        status ;

    status = ExeNextCommandLine( vcmd_script ) ;
    switch( status )
    {
      case SVCS_SUCCESS:       /* Command properly executed, continue wih next */
                               break ;

      case SVCS_FILENOEXIST:   LoggingDo(LL_ERROR, "No script file or file in parameter missing") ;
                               break ;

      case SVCS_CMDFAILED:     LoggingDo(LL_WARNING, "Command line failed") ;
                               break ;

      case SVCS_UNKNOWNCMD:    LoggingDo(LL_WARNING, "Unknown script command") ;
                               break ;

      case SVCS_NOMORECMD:     LoggingDo(LL_INFO, "No more command from script") ;
                               continue_script = 0 ;
                               break ;

      case SVCS_WAIT:          LoggingDo(LL_INFO, "Waiting for script to resume...") ;
                               continue_script = 0 ;
                               break ;

      case SVCS_EXITREQUEST:   LoggingDo(LL_INFO, "Script requests exit") ;
                               ret             = GW_EVTQUITAPP ;
                               continue_script = 0 ;
                               break ;

      case SVCS_MISSINGP1: 
      case SVCS_MISSINGP2: 
      case SVCS_MISSINGP3: 
      case SVCS_MISSINGP4: 
                               LoggingDo(LL_WARNING, "Parameter %d missing", 1+SVCS_MISSINGP1-status) ; /* As SVCS_MISSINGPx are in reverse order */
                               break ;

      case SVCS_NOMEMORY:      LoggingDo(LL_WARNING, "Not enough memory for script") ;
                               break ;

      case SVCS_LOOPINVALID:   LoggingDo(LL_WARNING, "Invalid loop value, ignoring") ;
                               break ;

      case SVCS_SCRIPTINVALID: LoggingDo(LL_WARNING, "Invalid script structure at $%p", vcmd_script) ; ;
                               break ;

      default:                 LoggingDo(LL_WARNING, "Unknown error from script") ;
                               break ;
    }
    if ( continue_script ) PostMessage( NULL, WM_CMDSCRIPT_EXELINE, mesg ) ;
  }
#endif

  return ret ;
}

static int OnAppUnknownMsg(void* app, int* mesg)
{
  int code = 0 ;
/*  LDG           *ldg ;
  unsigned long lsb, msb ;
  int           ldg_err ;
  char          buf[50] ;

  switch( mesg[0] )
  {
    case LDG_QUIT  : lsb = (unsigned long) mesg[4] ;
                     msb = (unsigned long) mesg[3] ;
                     ldg = (LDG *) ( ( msb << 16 ) + lsb ) ;
                     LDVTerminate( ldg ) ;
                     break ;

    case LDG_ERROR : ldg_err = ldg_error() ;
                     sprintf( buf, "[LDG Error %d][ OK ]", ldg_err ) ;
                     form_stop( 1, buf ) ;
                     break ;
  }
*/
  return code ;
}
#pragma warn +par

static void OnOpenFileApp(char *name)
{
  char ext[10] ;

  get_ext( name, ext ) ;
  if ( strcmpi( ext, "VIC" ) == 0 )      traite_album( name ) ;
  else if ( strcmpi( ext, "VSS" ) == 0 ) traite_slideshow( name ) ;
#ifndef __NO_SCRIPT
  else if ( strcmpi( ext, "VCS" ) == 0 ) traite_command_script( name ) ;
#endif
  else                                   load_wpicture( name, IID_UNKNOWN ) ;
}

void GetAppTitle(char* buf)
{
  if ( buf ) sprintf( buf, "  Vision %s", NO_VERSION ) ;
}

void UpdateRTZoom4App(int use_rtzoom)
{
  GEM_APP* app = GWGetApp( 0, NULL ) ; /* Don't change argc/argv as they may have not been handled yet (called from OnInitApp) */

  /* Just to avoid notifying mouse moves to application un-neccessarily */
  app->OnMouseMove = use_rtzoom ? OnAppMouseMove:NULL ;
  rtzoom_free() ;
  if ( use_rtzoom ) rtzoom_init() ;
}

int OnInitApp(void* ap)
{
  GEM_APP*    app = (GEM_APP*) ap ;
  GEM_WINDOW* splash = NULL ;
  int         x, y, w, h ;
  char*       mod_paths[NB_MST_MAX] ;
  char        rsc_name[PATH_MAX] ;
  char        buf[64] ;
  char        sfpu[30], sdsp[30] ;

  graf_mouse( BUSYBEE, NULL ) ;

  LoggingDo(LL_INFO, "VISION initializes...") ;
  LoggingDo(LL_INFO, "AES Version:%x.%x", AESVersion >> 8, AESVersion & 0xFF ) ;
  LoggingDo(LL_INFO, "Graphics:%dx%d, %d planes %s", 1+Xmax, 1+Ymax, nb_plane, Truecolor ? "(Truecolor)":"" ) ;

  high_res = (Xmax > 512) && (Ymax > 384) ;
  init_params() ;
  init_pencil() ;

  get_prefs() ;
  get_languages() ;

  if ( init_msg() )
  {
    OnTerminateApp( app ) ;
    return 1 ;
  }

  if ( nb_plane == 2 )
  {
    /* 4 color mode (e.g. ST-Medium), VISION does not fully support it */
    /* Especially regarding icon displaying, so let the user decide    */
    /* If he would like to continue                                    */
    LoggingDo(LL_WARNING, "4 color graphic mode, not fully supported by VISION, let user decide..." ) ;
    if ( form_interrogation(1, MsgTxtGetMsg(hMsg, MSG_4COLORMODE) ) != 1 )
    {
      OnTerminateApp( app ) ;
      return 1 ;
    }
  }

  if ( get_fpu() ) sprintf( sfpu, "%ld", get_fpu()) ;
  else             strcpy( sfpu, "<None>" ) ;
  if ( DspInfo.type ) sprintf( sdsp, "%ld", 56000L+DspInfo.type) ;
  else                strcpy( sdsp, "<None>" ) ;
  LoggingDo(LL_INFO, "CPU:%ld, FPU:%s, DSP:%s", 68000L+MachineInfo.cpu, sfpu, sdsp ) ;
  if ( (MachineInfo.cpu >= 30L) && (config.ldv_options & LDVO_HIDE030) )
    LoggingDo(LL_INFO, "68030 will NOT be reported to LDVs" ) ;

  if ( get_fpu() && (config.ldv_options & LDVO_HIDEFPU) )
    LoggingDo(LL_INFO, "FPU will NOT be reported to LDVs" ) ;

  if ( DspInfo.type && (config.ldv_options & LDVO_HIDEDSP) )
    LoggingDo(LL_INFO, "DSP will NOT be reported to LDVs" ) ;
  
  LoggingDo(LL_INFO, "Language:%s", config.language ) ;

  if ( high_res )
  {
    sprintf( rsc_name, vision_rsc_access, config.path_language, config.language ) ;
    if ( !FileExist( rsc_name ) )
      sprintf( rsc_name, "LANGUES\\%s\\VISION.RSC", config.language ) ;
  }
  else
  {
    sprintf( rsc_name, "%s\\%s\\VISIONB.RSC", config.path_language, config.language ) ;
    if ( !FileExist( rsc_name ) )
      sprintf( rsc_name, "LANGUES\\%s\\VISIONB.RSC", config.language ) ;
  }

  LoggingDo(LL_INFO, "Loading RSC file %s with rsrc_choice=%d", rsc_name, config.rsrc_choice) ;
  if ( Xrsrc_load( rsc_name, config.rsrc_choice ) == 0 )
  {
    char bbuf[PATH_MAX] ;

    v_show_c( handle, 1 ) ;
    LoggingDo(LL_FATAL, "Can't load resource file %s, you should delete VISION.INI for a fresh start and check VISION LANGUES folder", rsc_name);
    sprintf(bbuf, "[File %s is missing !|You should delete VISION.INI|for a fresh start!][ End ]", rsc_name);
    form_stop( 1, bbuf ) ;
    OnTerminateApp( app ) ;

    return 1 ;
  }

#ifndef __NO_BUBBLE
  if ( BHelpInit() )
    LoggingDo(LL_WARNING, "Not enough memory to get Help bubbles") ;
#endif

  GetAppTitle( buf ) ;
  GWSetMenu( M_VISION, buf ) ;
  GWSetMenuStatus( 0 ) ;

  mod_paths[0] = NULL ;              /* No dynamic LDI         */
  mod_paths[1] = config.path_zvldg ; /* zView LDG plugins path */
#ifdef MST_ZVSLB
  mod_paths[2] = config.path_zvslb ; /* zView SLB plugins path */
#endif
  DImgGetImgModules( mod_paths, NULL, MsgTxtGetMsg(hMsg, MSG_UPTIMGMOD), config.im_priority_global ) ;
  graf_mouse( ARROW, NULL ) ;
  if ( config.flags & FLG_SPLASH ) splash = display_splash( high_res ) ;

  if ( Gdos ) num_fonts = vst_load_fonts( handle, 0 ) ;
  else        num_fonts = 0 ;

  if ( splash ) GWDestroyWindow( splash ) ;
  init_data() ;

  if ( !high_res )
  {
    app->Menu[M_UNDO-1].ob_x   = 96 ;
    app->Menu[M_PLEIN-1].ob_x  = 110 ;
    app->Menu[M_OPOINT-1].ob_x = 110 ;
    app->Menu[M_OTRACE-1].ob_x = 110 ;
    app->Menu[M_Z11-1].ob_x    = 110 ;
  }

  if ( Truecolor ) menu_ienable( app->Menu, M_PALETTE, 0 ) ;

  VToolBarInit( high_res ) ;

  init_mouseforms() ;

  UpdateRTZoom4App( config.use_rtzoom ) ;

  if ( config.log_file[0] != 0 )
  {
    char bbuf[PATH_MAX] ;
    char mode[10] = "wb" ;

    if ( config.log_file[1] != ':' ) /* Chemin relatif demand‚ */
      sprintf( bbuf, "%s\\%s", init_path, config.log_file ) ; 
    else
      strcpy( bbuf, config.log_file ) ;
    if ( config.log_flags & LF_FLGAPPEND ) strcpy( mode, "ab+" ) ;
    config.log_stream = fopen( bbuf, mode ) ;
  }
  else config.log_stream = NULL ;

  app->OnKeyPressed   = OnAppKeyPressed ;
  app->OnMenuSelected = OnAppMenuSelected ;
  /* OnAppMouseMove is set when UpdateRTZoom4App is called */
  app->OnUpdateGUI    = OnAppUpdateGUI ;
  app->OnTerminate    = OnTerminateApp ;
  app->OnOpenFile     = OnOpenFileApp ;
  app->OnUnknownMsg   = OnAppUnknownMsg ;
  app->OnMsgUser      = OnAppMsgUser ;

  if ( !Multitos && (config.flags & FLG_LONGFNAME) )
  {
    LoggingDo(LL_WARNING, "Long filenames enabled but not a Multitos OS, may cause troubles, not enabling long filenames") ;
    config.flags &= ~FLG_LONGFNAME ;
  }

  if ( config.flags & FLG_LONGFNAME )
  {
    LoggingDo(LL_INFO, "Long filenames enabled") ;
    Pdomain( 1 ) ;
  }
  
  if ( WndToolBar && ( WndToolBar->flags & FLG_ISVISIBLE ) )
  {
    GWGetCurrXYWH( WndToolBar, &x, &y, &w, &h ) ;
    if ( high_res )
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
  CreateImgBrowser( NULL, high_res ) ;

  LoggingDo(LL_INFO, "VISION %s is up and running!", NO_VERSION) ;

  set_goodmouse() ;

  return 0 ;
}

void SetupRoots(void)
{
#ifndef __NO_LOGGING
  LOGGING_CONFIG logconfig ;
  char           buf[32] ;
  char           lflags[128] ;
#endif
  XALLOC_CONFIG  allocConfig ;

#ifndef __NO_LOGGING
  LoggingGetDefaultConfig(&logconfig) ;
  strcpy( config.logging_file, "vision.log" ) ;
  GetIniKeyFromFile( "vision.ini", section_logging, "LoggingFile", config.logging_file ) ;

  sprintf( buf, "%lx", LF_CLRLOGSONSTART | LL_FATAL | LL_ERROR | LL_WARNING | LL_INFO ) ;
  GetIniKeyFromFile( "vision.ini", section_logging, "LoggingFlags", buf ) ;
  sscanf( buf, "%lx", &config.logging_flags ) ;

  sprintf( buf, "%d", 1 ) ;
  GetIniKeyFromFile( "vision.ini", section_logging, "LoggingFlushFreq", buf ) ;
  config.logging_flushfreq = atoi(buf) ;

  logconfig.Flags     = (unsigned int) (config.logging_flags >> 24) ;
  logconfig.Level     = config.logging_flags & 0x00FFFFFFL ;
  logconfig.FlushFreq = config.logging_flushfreq ;

  LoggingInit(config.logging_file, &logconfig) ;
  LoggingDo(LL_INFO, "VISION logs to %s with level $%lX(%s), flush frequency=1/%d", config.logging_file, logconfig.Level, LoggingGetLabelLevels(logconfig.Level, lflags, sizeof(lflags)), logconfig.FlushFreq) ;
#endif

  XallocGetDefaultConfig(&allocConfig) ;
  allocConfig.StatsEverynSec = 60 ;
  XallocInit(&allocConfig) ;
}

int main(int argc, char** argv)
{
  GEM_APP* theApp ;

  SetupRoots() ;
  theApp = GWGetApp( argc, argv ) ;

  theApp->OnInit = OnInitApp ;
  GWDeclareAndRunApp( theApp ) ;

  XallocExit() ;
  LoggingDo(LL_INFO, "VISION is now exiting") ;
  LoggingClose() ;

  return 0 ;
}
