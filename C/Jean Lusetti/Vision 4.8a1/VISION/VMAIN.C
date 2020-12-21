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
#include  "..\tools\aupdate.h"

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
static char section_vupdate[]      = "Update" ;

static char vision_rsc_access[] = "%s\\%s\\VISION.RSC" ;

HMSG hMsg ;

#ifndef __NO_SCRIPT
VCMD_SCRIPT VCmdScript ;
char*       VCSScriptNames[16] ;
char        VCSScriptLastIndex ;
char        VCSScriptCurrentIndex ;
char        VCSInScriptMode ;
#endif

#define WM_UPDATE_AVAILABLE (WM_USER_FIRST+1)


void init_data(void)
{
  memzero( &clipboard, sizeof(clipboard) ) ;
  memzero( &vclip, sizeof(vclip) ) ;  
  vclip.form = BLOC_RECTANGLE ;
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

  sprintf( buf, "%u", cfg->show_ibrowser ) ;
  SetIniKey( h_ini, section_general, "ShowIBrowser", buf ) ;
 
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

  sprintf( buf, "%u,%u,%u,%u,%u,%u,%u,%u,%u", config.thickness[0], config.thickness[1], config.thickness[2], config.thickness[3],
                                              config.thickness[4], config.thickness[5], config.thickness[6], config.thickness[7], config.thickness[8] ) ;
  SetIniKey( h_ini, section_graphics, "Thickness", buf ) ;

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

  /***************************** Section VISION Update *******************************/
  sprintf( buf, "%d", config.vu_enabled ) ;
  SetIniKey( h_ini, section_vupdate, "Enabled", buf ) ;

  sprintf( buf, "%d", config.vu_choice ) ;
  SetIniKey( h_ini, section_vupdate, "Choice", buf ) ;

  sprintf( buf, "%lu", config.vu_last_check ) ;
  SetIniKey( h_ini, section_vupdate, "LastCheck", buf ) ;

  sprintf( buf, "%lu", config.vu_mincheck_s ) ;
  SetIniKey( h_ini, section_vupdate, "MinCheck", buf ) ;

  sprintf( buf, "%s", config.vu_updater ) ;
  SetIniKey( h_ini, section_vupdate, "Updater", buf ) ;

  sprintf( buf, "%s", config.vu_url ) ;
  SetIniKey( h_ini, section_vupdate, "URL", buf ) ;

  /*************************************************************************/

  return( SaveAndCloseIni( h_ini, NULL ) ) ;
}

long LoadImgPriorities(HINI h_ini, VISION_CFG* cfg)
{
  long save_ini ;
  char p[NB_MST_MAX] ;
  int  n ;
  char buf[PATH_MAX] ;

  memzero( cfg->im_priority_global, sizeof(cfg->im_priority_global) ) ;
  buf[0] = 0 ;
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

static void GetDefThickness(char* buf)
{
  static char def_thickness[] = "1,4,7,10,14,18,22,26,30" ; /* From Claude */

  strcpy( buf, def_thickness ) ;
}

static void GetThickness(VISION_CFG* cfg, char* buf)
{
  int   i ;
  char* last_c ;
  char* c = buf ;

  /* Replace all , and spaces with 0 to ease atoi usage */
  while ( *c )
  {
    if ( (*c == ',') || (*c == ' ') ) *c = 0 ;
    c++ ;
  }
  last_c = c ;

  c = buf ;
  for ( i = 0; i < ARRAY_SIZE(cfg->thickness); i++ )
  {
    if ( ( *c >= '0') && ( *c <= '9') )
      cfg->thickness[i] = (unsigned char) atoi( c ) ;
    while ( (c < last_c) && *c ) c++ ; /* Next thickness */
    while ( (c < last_c) && (*c == 0) ) c++ ; /* Ignore NULL(s) */
    if ( c >= last_c ) break ;
  }
}

void LoadVISIONIniFile(VISION_CFG* cfg)
{
  HINI h_ini ;
  long save_ini = 0 ;
  char buf[PATH_MAX] ;

  memzero( cfg, sizeof(VISION_CFG) ) ;
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

  strcpy( buf, "1" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_general, "ShowIBrowser", buf ) ;
  cfg->show_ibrowser = atoi( buf ) ;

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

  GetDefThickness( buf ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_graphics, "Thickness", buf ) ;
  GetThickness( cfg, buf ) ;

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

  sprintf( buf, "%lx", LL_FATAL | LL_ERROR | LL_WARNING | LL_INFO ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_logging, "LoggingFlags", buf ) ;
  sscanf( buf, "%lx", &cfg->logging_flags ) ;

  sprintf( buf, "%d", 1 ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_logging, "LoggingFlushFreq", buf ) ;
  cfg->logging_flushfreq = atoi( buf ) ;

  /****************** Section Image Module Priorities ******************/
  save_ini |= LoadImgPriorities( h_ini, cfg ) ;

  /****************** Section VISION update ******************/
  sprintf( buf, "%d", InternetAvailable() ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_vupdate, "Enabled", buf ) ;
  cfg->vu_enabled = atoi( buf ) ;

  sprintf( buf, "%d", 1 ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_vupdate, "Choice", buf ) ;
  cfg->vu_choice = atoi( buf ) ;

  sprintf( buf, "%lu", 0UL ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_vupdate, "LastCheck", buf ) ;
  sscanf( buf, "%lu", &cfg->vu_last_check ) ;

  sprintf( buf, "%lu", 7UL*24UL*3600UL ) ; /* Check updates once a week by default */
  save_ini |= GetOrSetIniKey( h_ini, section_vupdate, "MinCheck", buf ) ;
  sscanf( buf, "%lu", &cfg->vu_mincheck_s ) ;

  strcpy( cfg->vu_updater, "wget" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_vupdate, "Updater", cfg->vu_updater ) ;

  strcpy( cfg->vu_url, "http://vision.atari.org/vupdate/staging/" ) ; /* TODO: replace /staging/ with /stable/ */
  save_ini |= GetOrSetIniKey( h_ini, section_vupdate, "URL", cfg->vu_url ) ;

  /*************************************************************************/

  if ( save_ini )  SaveAndCloseIni( h_ini, NULL ) ;
  else             CloseIni( h_ini ) ;

  LoggingDo(LL_INFO, "VISION INI loaded!") ;
}

static short AdjustPath(char* path, char* def_dir)
{
  short ajusted = 0 ;

  if ( (path[0] == 0) || !FolderExist(path) )
  {
    char tmp[PATH_MAX] ;

    if ( def_dir ) sprintf( tmp, "%s\\%s", init_path, def_dir ) ;
    else           strcpy( tmp, init_path ) ;
    LoggingDo(LL_INFO, "Path %s does not exist, setting it to %s", path, tmp) ;
    strcpy( path, tmp ) ;
    ajusted = 1 ;
  }

  return ajusted ;
}

int ajust_pathconfig(void)
{
  char tmp[PATH_MAX] ;
  int  save_ini = 0 ;

  save_ini |= AdjustPath( config.path_img, NULL ) ;
  save_ini |= AdjustPath( config.path_album, NULL ) ;
  save_ini |= AdjustPath( config.path_lod, "DSP" ) ;
  save_ini |= AdjustPath( config.path_language, "LANGUES" ) ;
  save_ini |= AdjustPath( config.path_filter, "FILTRES" ) ;
  save_ini |= AdjustPath( config.path_ldv, "LDV" ) ;
  save_ini |= AdjustPath( config.path_zvldg, "zvLDG" ) ;
  if ( !FolderExist(config.path_zvldg) ) LoggingDo(LL_INFO, "zView LDG path %s does not exist, VISION won't use any zView LDG plugin", config.path_zvldg) ;
#ifdef MST_ZVSLB
  save_ini |= AdjustPath( config.path_zvslb, "zvSLB" ) ;
  if ( !FolderExist(config.path_zvslb) ) LoggingDo(LL_INFO, "zView SLB path %s does not exist, VISION won't use any zView SLB plugin", config.path_zvslb) ;
#endif
  save_ini |= AdjustPath( config.path_temp, "TEMP" ) ;
  if ( !FolderExist(config.path_temp) ) Dcreate( config.path_temp ) ;

  /* Let's make sure UPDATE folder exists */
  sprintf( tmp, "%s\\UPDATE", init_path ) ;
  if ( !FolderExist(tmp) ) Dcreate( tmp ) ;

  return save_ini ;
}

int get_prefs(void)
{
  int save_ini ;

  LoadVISIONIniFile( &config ) ;
  DspInfo.use              = config.dspuse ;
  DspInfo.WhatToDoIfLocked = config.dsphandlelock ;
  if ( config.flags & FLG_FORCEUSESTDVDI ) UseStdVDI = 1 ;

  save_ini   = ajust_pathconfig() ;
  *last_path = 0 ;

  return save_ini ;
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
    if ( (dta.d_fname[0] != '.') && (dta.d_attrib & FA_SUBDIR) )
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

#ifndef __NO_SCRIPT
short StartVCSSCript(char* name)
{
  short status = LoadCommandScript( name, &VCmdScript ) ;

  if ( status == SVCS_SUCCESS )
  {
    int mesg[4] ;

    *((VCMD_SCRIPT**)mesg) = &VCmdScript ;
    LoggingDo(LL_INFO, "Vision is in script mode on %s", name) ;
    VCSInScriptMode = 1 ;
    PostMessage( NULL, WM_CMDSCRIPT_EXELINE, mesg ) ;
  }
  else LoggingDo(LL_ERROR, "Command Script %s failed to load with %d", name, status) ;

  return status ;
}

void traite_command_script(char* name)
{
  /* Need to queue VCS files if more than 1 as they are using GEM messagea */
  if ( !VCSInScriptMode ) StartVCSSCript( name ) ;
  else
  {
    LoggingDo(LL_INFO, "VISION is already in script mode, adding %s to queue", name) ;
    if ( VCSScriptLastIndex < ARRAY_SIZE(VCSScriptNames) ) VCSScriptNames[VCSScriptLastIndex++] = name ;
    else                                                   LoggingDo(LL_ERROR, "Can't add script %s to current list", name) ;
  }
}
#endif

#pragma warn -par
static int OnAppMsgUser(void* app, int id, int* mesg)
{
  int ret = 0 ;

#ifndef __NO_SCRIPT
  if ( id == WM_CMDSCRIPT_EXELINE )
  {
    VCMD_SCRIPT* vcmd_script = *((VCMD_SCRIPT**)mesg) ;
    short        continue_script = 1 ;
    short        gotonextscript = 0 ;
    short        status ;

    status = ExeNextCommandLine( vcmd_script ) ;
    switch( status )
    {
      case SVCS_SUCCESS:       /* Command properly executed, continue wih next */
                               break ;

      case SVCS_FILENOEXIST:   LoggingDo(LL_ERROR, "No script file or file in parameter missing") ;
                               gotonextscript  = 1 ;
                               break ;

      case SVCS_CMDFAILED:     LoggingDo(LL_WARNING, "Command line failed") ;
                               break ;

      case SVCS_UNKNOWNCMD:    LoggingDo(LL_WARNING, "Unknown script command") ;
                               break ;

      case SVCS_NOMORECMD:     LoggingDo(LL_INFO, "No more command from script") ;
                               continue_script = 0 ;
                               gotonextscript  = 1 ;
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
      case SVCS_MISSINGP4:     LoggingDo(LL_WARNING, "Parameter %d missing", 1+SVCS_MISSINGP1-status) ; /* As SVCS_MISSINGPx are in reverse order */
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
    else if ( gotonextscript )
    {
      short st = SVCS_SUCCESS ;

      while ( (st == SVCS_SUCCESS) && (VCSScriptCurrentIndex < VCSScriptLastIndex) && (VCSScriptNames[VCSScriptCurrentIndex] != NULL) )
      {
        LoggingDo(LL_DEBUG, "CurrentScriptIndex=%d, LastScriptIndex=%d, script name=%s", VCSScriptCurrentIndex, VCSScriptLastIndex, VCSScriptNames[VCSScriptCurrentIndex] ) ;
        st = StartVCSSCript( VCSScriptNames[VCSScriptCurrentIndex++] ) ;
      }
    }
    VCSInScriptMode = (VCSScriptCurrentIndex < VCSScriptLastIndex) ;
    LoggingDo(LL_DEBUG, "Script mode:%d", VCSInScriptMode) ;
  }
#endif

#ifndef __NO_UPDATE
  if ( id == WM_UPDATE_AVAILABLE )
  {
    AU_CONTEXT* VUContext = *((AU_CONTEXT**)mesg) ;
    short       do_it = 0 ;
    short       save_ini = 1 ;

    LoggingDo(LL_INFO, "New version is available: %s", VUContext->url_version) ;
    if ( config.vu_choice )
    {
      char buf[200] ;

      sprintf( buf, MsgTxtGetMsg(hMsg, MSG_UPDATEAVAILABLE), VUContext->url_version ) ;
      do_it = ( form_interrogation( 2, buf ) == 1 ) ;
    }
    if ( do_it )
    {
      short status ;

      VUContext->wprog = DisplayStdProg( MsgTxtGetMsg(hMsg, MSG_VUPDATING) , "", "", 0 ) ;
      status = AUPerformUpdate( VUContext ) ;
      GWDestroyWindow( VUContext->wprog ) ;
      if ( status == AU_UPDATEDONE )
      {
        form_stop( 1, MsgTxtGetMsg(hMsg, MSG_UPDATEDONE) ) ;
        ret = GW_EVTQUITAPP ;
      }
      else
      {
        char buf[128] ;

        LoggingDo(LL_ERROR, "Update failed with %d", status) ;
        sprintf( buf, MsgTxtGetMsg(hMsg, MSG_UPDATEFAILED), status ) ;
        form_stop( 1, buf ) ;
        save_ini = 0 ;
      }
    }
    else LoggingDo(LL_INFO, "User decided to not proceed with update") ;

    if ( save_ini )
    {
      time_t s ;

      time( &s ) ;
      config.vu_last_check = s ;
      SaveVISIONIniFile( &config ) ;
    }
    Xfree( VUContext ) ;
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
  if ( buf ) sprintf( buf, "  Vision %s", config.version ) ;
}

void UpdateRTZoom4App(int use_rtzoom)
{
  GEM_APP* app = GWGetApp( 0, NULL ) ; /* Don't change argc/argv as they may have not been handled yet (called from OnInitApp) */

  /* Just to avoid notifying mouse moves to application un-neccessarily */
  app->OnMouseMove = use_rtzoom ? OnAppMouseMove:NULL ;
  rtzoom_free() ;
  if ( use_rtzoom ) rtzoom_init() ;
}

static short VUIsFileToUpdate(char* filename)
{
  char* ignore[] = { "vision.ini", "vision.log", NULL } ;
  short i ;

  for ( i = 0; ignore[i]; i++ )
    if ( strcmpi( filename, ignore[i] ) == 0 ) return 0 ;

  return 1 ;
}

static int CheckUpdates(void)
{
  int save_ini = 0 ;

  if ( config.vu_enabled )
  {
    if ( InternetAvailable() )
    {
      time_t s ;

      time( &s ) ;
      if ( s-config.vu_last_check > config.vu_mincheck_s )
      {
        AU_CONTEXT* VUContext = (AU_CONTEXT*) Xcalloc( 1, sizeof(AU_CONTEXT) ) ;

        if ( VUContext )
        {
          int   mesg[4] ;
          short status ;

          strcpy( VUContext->current_version, config.version ) ;
          strcpy( VUContext->url, config.vu_url ) ;
          strcpy( VUContext->updater, config.vu_updater ) ;
          strcpy( VUContext->path_init, init_path ) ;
          sprintf( VUContext->path_update, "%s\\%s", init_path, "UPDATE" ) ;
          strcpy( VUContext->inet_app_fversion, "vision.ver" ) ;
          VUContext->IsFileToUpdate = VUIsFileToUpdate ;
          status = AUCheckUpdate( VUContext ) ;
          switch( status )
          {
            case AU_UPDATEFOUND:    *((AU_CONTEXT**)mesg) = VUContext ;
                                    PostMessage( NULL, WM_UPDATE_AVAILABLE, mesg ) ;
                                    break ;

            case AU_NOUPDATE:       LoggingDo(LL_INFO, "CheckUpdate: no update found") ;
                                    config.vu_last_check = s ;
                                    break ;

            case AU_NOUPDATER:      LoggingDo(LL_WARNING, "Can't update: updater %s is not installed, please consider installing curl (https://tho-otto.de/crossmint.php) or wget (https://freemint.github.io/sparemint/sparemint/html/packages/wget.html)", config.vu_updater) ;
                                    LoggingDo(LL_WARNING, "Important: either specify FULL path for Updater in VISION.INI or copy it to a folder in $PATH") ;
                                    break ;

            case AU_UPDATERUNKNOWN: LoggingDo(LL_WARNING, "Can't update: updater %s is unknown", config.vu_updater) ;
                                    break ;

            case AU_UPDATERERR:     LoggingDo(LL_WARNING, "Can't update: updater %s reported error, check Internet connection", config.vu_updater) ;
                                    if ( form_interrogation( 1, MsgTxtGetMsg(hMsg, MSG_UPDATENOINTERNET) ) == 1 )
                                    {
                                      LoggingDo(LL_INFO, "User decided to no longer check for updates") ;
                                      config.vu_enabled = 0 ;
                                      save_ini          = 1 ;
                                    }
                                    break ;
          }
          if ( status != AU_UPDATEFOUND ) Xfree( VUContext ) ;
        }
        else LoggingDo(LL_WARNING, "Not enough memory to query for updates") ;
      }
      else
      {
        LoggingDo(LL_INFO, "CheckUpdate: still %luh to wait before next check", (config.vu_last_check+config.vu_mincheck_s-s)/3600UL) ;
        /* Don't update VISION.INI more than once a day for this */
        if ( s-config.vu_last_check > 3600UL*24UL )
        {
          config.vu_last_check = s ;
          save_ini             = 1 ;
        }
      }
    }
    else LoggingDo(LL_INFO, "Internet connection not available, won't check against VISION updates from Web") ;
  }
  else LoggingDo(LL_INFO, "Check update from Web feature is not enabled") ;

  return save_ini ;
}

static void OnAppPreModal(void)
{
  mouse.gr_monumber = ARROW ;
  set_mform( &mouse ) ;
}

static void OnAppPostModal(void)
{
  /* Restore mouse as a modal dialog switched mouse back to classic arrow                                */
  /* This is done as a work around to Nova card driver which does not restore                            */
  /* Properly the hot point of the cursor, see https://groups.google.com/g/atari-mon-amour/c/y5ZBot1GbRc */
  set_goodmouse() ;
}

int OnInitApp(void* ap)
{
  GEM_APP*    app = (GEM_APP*) ap ;
  GEM_WINDOW* splash = NULL ;
  int         save_ini = 0 ;
  int         x, y, w, h ;
  char*       mod_paths[NB_MST_MAX] ;
  char        rsc_name[PATH_MAX] ;
  char        buf[64] ;
  char        sfpu[30], sdsp[30] ;

  graf_mouse( BUSYBEE, NULL ) ;

  LoggingDo(LL_INFO, "VISION initializes...") ;
  LoggingDo(LL_INFO, "AES Version:%x.%x", AESVersion >> 8, AESVersion & 0xFF ) ;
  LoggingDo(LL_INFO, "Graphics:%dx%d, %d planes %s", screen.fd_w, screen.fd_h, screen.fd_nplanes, Truecolor ? "(Truecolor)":"" ) ;

  high_res = (Xmax > 512) && (Ymax > 384) ;
  init_params() ;
  init_pencil() ;

  save_ini |= get_prefs() ;
  get_languages() ;

  if ( init_msg() )
  {
    OnTerminateApp( app ) ;
    return 1 ;
  }

  if ( screen.fd_nplanes == 2 )
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
  if ( BHelpInit() ) LoggingDo(LL_WARNING, "Not enough memory to get Help bubbles") ;
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
    char  bbuf[PATH_MAX] ;
    char* mode = "wb" ;

    if ( config.log_file[1] != ':' ) /* Chemin relatif demand‚ */
      sprintf( bbuf, "%s\\%s", init_path, config.log_file ) ; 
    else
      strcpy( bbuf, config.log_file ) ;
    if ( config.log_flags & LF_FLGAPPEND ) mode = "ab+" ;
    config.log_stream = fopen( bbuf, mode ) ;
  }
  else config.log_stream = NULL ;

  app->OnKeyPressed   = OnAppKeyPressed ;
  app->OnMenuSelected = OnAppMenuSelected ;
  /* OnAppMouseMove is set when UpdateRTZoom4App is called */
  app->OnUpdateGUI    = OnAppUpdateGUI ;
  app->OnTerminate    = OnTerminateApp ;
  app->OnOpenFile     = OnOpenFileApp ;
/*  app->OnUnknownMsg   = OnAppUnknownMsg ; Unused */
  app->OnMsgUser      = OnAppMsgUser ;
  app->OnPreModal     = OnAppPreModal ;
  app->OnPostModal    = OnAppPostModal ;

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
  
  if ( WndToolBar && (WndToolBar->flags & FLG_ISVISIBLE) )
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

#ifndef __NO_UPDATE
  save_ini |= CheckUpdates() ;
#endif

  if ( config.show_ibrowser ) CreateImgBrowser( NULL, high_res ) ;

  if ( save_ini ) SaveVISIONIniFile( &config ) ;

  LoggingDo(LL_INFO, "VISION %s is up and running!", config.version) ;

  set_goodmouse() ;
/*XFileTest();*/  
  return 0 ;
}

static void SetupRoots(void)
{
#ifndef __NO_LOGGING
  LOGGING_CONFIG logconfig ;
  char           buf[PATH_MAX] ;
  char           lflags[128] ;
#endif
  XALLOC_CONFIG  allocConfig ;

#ifndef __NO_LOGGING
  strcpy( init_path, "VISION.PRG" ) ;
  if ( shel_find( init_path ) != 0 )
  {
    char* last_aslash = strrchr( init_path, '\\' ) ;

    if ( last_aslash ) *last_aslash = 0 ;
  }
  else init_path[0] = 0 ; /* Let library set it up */

  LoggingGetDefaultConfig( &logconfig ) ;
  strcpy( config.logging_file, "vision.log" ) ;
  GetIniKeyFromFile( "vision.ini", section_logging, "LoggingFile", config.logging_file ) ;
  if ( config.logging_file[1] != ':' )
  {
    /* Not a full path */
    strcpy( buf, config.logging_file ) ;
    sprintf( config.logging_file, "%s\\%s", init_path, buf ) ;
  }

  sprintf( buf, "%lx", LL_FATAL | LL_ERROR | LL_WARNING | LL_INFO ) ;
  GetIniKeyFromFile( "vision.ini", section_logging, "LoggingFlags", buf ) ;
  sscanf( buf, "%lx", &config.logging_flags ) ;

  sprintf( buf, "%d", 1 ) ;
  GetIniKeyFromFile( "vision.ini", section_logging, "LoggingFlushFreq", buf ) ;
  config.logging_flushfreq = atoi(buf) ;

  logconfig.Level     = config.logging_flags ;
  logconfig.FlushFreq = config.logging_flushfreq ;

  LoggingInit( config.logging_file, &logconfig ) ;
  LoggingDo(LL_INFO, "Startup path: %s", init_path) ;
  LoggingDo(LL_INFO, "VISION logs to %s with level $%lX(%s), flush frequency=1/%d", config.logging_file, logconfig.Level, LoggingGetLabelLevels(logconfig.Level, lflags, sizeof(lflags)), logconfig.FlushFreq) ;
#endif

  XallocGetDefaultConfig( &allocConfig ) ;
  allocConfig.StatsEverynSec = 60 ;

  /* These lines should be commented unless debugging */
/*  allocConfig.Flags = FA_RESET_MEM_ON_FREE ;
  LoggingDo(LL_WARNING, "Reset memory upon free is enabled!", init_path) ;*/

  XallocInit( &allocConfig ) ;
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
