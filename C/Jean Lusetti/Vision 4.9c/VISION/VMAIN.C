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
#include  "hexdump.h"
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

#include "..\tools\spattern.h" /* test */


char high_res ;

static char section_general[]      = "General" ;
static char section_folders[]      = "Folders" ;
static char section_dsp[]          = "DSP" ;
static char section_diaporama[]    = "SlideShow" ;
static char section_undo[]         = "Undo" ;
static char section_rtzoom[]       = "Real Time Zoom" ;
static char section_graphics[]     = "Graphics" ;
/* static char section_log[]          = "Log" ; Logfile feature no longer used */
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
#define WM_RUN_ARGS         (WM_USER_FIRST+2)


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
  SetIniKey( h_ini, section_general, "Language", cfg->language ) ;
  SetIniKeyBool( h_ini, section_general, "HelpBubbles", cfg->flags & FLG_HELP ) ;
  SetIniKeyBool( h_ini, section_general, "DitherAuto", cfg->flags & FLG_DITHERAUTO ) ;
  SetIniKeyBool( h_ini, section_general, "FullScreen", cfg->flag_fullscreen ) ;
  SetIniKeyBool( h_ini, section_general, "InfoBar", cfg->w_info ) ;
  SetIniKeyBool( h_ini, section_general, "QuitIfNoWindow", cfg->quitte ) ;
  SetIniKeyBool( h_ini, section_general, "UseGEMClipboard", cfg->clip_gem ) ;
  SetIniKeyBool( h_ini, section_general, "CrossMouse", cfg->souris_viseur ) ;
  SetIniKeyBool( h_ini, section_general, "ColorProtection", cfg->color_protect ) ;
  SetIniKeyUShort( h_ini, section_general, "DitherMethod", cfg->dither_method ) ;
  SetIniKeyBool( h_ini, section_general, "SplashWindow", cfg->flags & FLG_SPLASH ) ;
  SetIniKeyBool( h_ini, section_general, "DisplayToolBar", cfg->flags & FLG_TOOLBAR ) ;
  SetIniKeyBool( h_ini, section_general, "UseLongFileNames", cfg->flags & FLG_LONGFNAME ) ;
  SetIniKeyShort( h_ini, section_general, "RsrcChoice", cfg->rsrc_choice ) ;
  SetIniKeyBool( h_ini, section_general, "ShowIBrowser", cfg->show_ibrowser ) ;
  SetIniKeyBool( h_ini, section_general, "HexDumpOnError", cfg->flags & FLG_HEXDUMPONERR ) ;
 
  /**************************************************************************/

  /***************************** Section FOLDERS  ***************************/
  SetIniKey( h_ini, section_folders, "Languages", cfg->path_language ) ;
  SetIniKey( h_ini, section_folders, "Temp", cfg->path_temp ) ;
  SetIniKey( h_ini, section_folders, "Images", cfg->path_img ) ;
  SetIniKey( h_ini, section_folders, "DSP", cfg->path_lod ) ;
  SetIniKey( h_ini, section_folders, "Filters", cfg->path_filter ) ;
  SetIniKey( h_ini, section_folders, "Album", cfg->path_album ) ;
  SetIniKey( h_ini, section_folders, "LDV", cfg->path_ldv ) ;
  SetIniKey( h_ini, section_folders, "zvLDG", cfg->path_zvldg ) ;
  SetIniKey( h_ini, section_folders, "ImgMod", cfg->path_imgmod ) ;
#ifdef MST_ZVSLB
  SetIniKey( h_ini, section_folders, "zvSLB", cfg->path_zvslb ) ;
#endif
  /**************************************************************************/

  /*************************** Section DSP **********************************/
  SetIniKeyBool( h_ini, section_dsp, "UseDSP", cfg->dspuse ) ;
  SetIniKeyUShort( h_ini, section_dsp, "HandleLock", cfg->dsphandlelock ) ;

  /**************************************************************************/

  /********************** Section UNDO *********************************/
  if ( cfg->nb_undo < 0 ) cfg->nb_undo = 0 ;
  if ( cfg->nb_undo > MAX_UNDO ) cfg->nb_undo = MAX_UNDO ;
  SetIniKeyUShort( h_ini, section_undo, "NbBuffers", cfg->nb_undo ) ;
  SetIniKeyUShort( h_ini, section_undo, "Type", cfg->type_undo ) ;
  SetIniKeyUShort( h_ini, section_undo, "UseDiskIfKo", cfg->ko_undo ) ;
  SetIniKeyBool( h_ini, section_undo, "UseRedo", cfg->use_redo ) ;

  /**************************************************************************/

  /*************************** Section Diaporama ****************************/
  SetIniKeyShort( h_ini, section_diaporama, "WaitMiniSec", cfg->wait_mini_sec ) ;
  SetIniKeyBool( h_ini, section_diaporama, "HideMouse", cfg->do_not_show_mouse ) ;
  SetIniKeyBool( h_ini, section_diaporama, "DoNotClearScreen", cfg->do_not_cls_scr ) ;
  SetIniKeyUShort( h_ini, section_diaporama, "Cycle", cfg->cycle ) ;
  SetIniKeyShort( h_ini, section_diaporama, "BackGroundColor", cfg->back ) ;
  SetIniKeyUShort( h_ini, section_diaporama, "DisplayType", cfg->display_type ) ;
  SetIniKeyUShort( h_ini, section_diaporama, "Transition", cfg->transition ) ;
  SetIniKeyBool( h_ini, section_diaporama, "DisplayName", cfg->aff_name ) ;
  SetIniKeyBool( h_ini, section_diaporama, "DisplayProg", cfg->aff_prog ) ;

  /**************************************************************************/

  /*************************** Section Zoom Temps Reel **********************/
  SetIniKeyUShort( h_ini, section_rtzoom, "ObjectToZoom", cfg->rt_zoomwhat ) ;
  SetIniKeyBool( h_ini, section_rtzoom, "RespectGEM", cfg->rt_respectgem ) ;
  SetIniKeyBool( h_ini, section_rtzoom, "OptimizePosition", cfg->rt_optimizepos ) ;
  SetIniKeyBool( h_ini, section_rtzoom, "UseRtZoom", cfg->use_rtzoom ) ;
  SetIniKeyUShort( h_ini, section_rtzoom, "RTWidth", cfg->rt_width ) ;
  SetIniKeyUShort( h_ini, section_rtzoom, "RTHeight", cfg->rt_height ) ;
  SetIniKeyUShort( h_ini, section_rtzoom, "ZoomLevel", cfg->rt_zoomlevel ) ;

  /*************************************************************************/

  /************************* Section Graphics ******************************/
  SetIniKeyShort( h_ini, section_graphics, "WriteMode", mode_vswr ) ;
  SetIniKeyShort( h_ini, section_graphics, "EraserForm", cfg->sgomme ) ;
  SetIniKeyBool( h_ini, section_graphics, "MaskOutside", cfg->flags & FLG_MASKOUT ) ;

  SetIniKeyShort( h_ini, section_graphics, "TWCar", ttype.wcar ) ;
  SetIniKeyShort( h_ini, section_graphics, "THCar", ttype.hcar ) ;
  SetIniKeyShort( h_ini, section_graphics, "TWCell", ttype.wcell ) ;
  SetIniKeyShort( h_ini, section_graphics, "THCell", ttype.hcell ) ;
  SetIniKeyShort( h_ini, section_graphics, "TAngle", ttype.angle ) ;
  SetIniKeyShort( h_ini, section_graphics, "TFont", ttype.font ) ;
  SetIniKeyShort( h_ini, section_graphics, "TColor", ttype.color ) ;
  SetIniKeyShort( h_ini, section_graphics, "TAttribute", ttype.attribute ) ;
  SetIniKeyShort( h_ini, section_graphics, "THdisp", ttype.hdisp ) ;
  SetIniKeyShort( h_ini, section_graphics, "TVDisp", ttype.vdisp ) ;

  SetIniKeyShort( h_ini, section_graphics, "FStyle", ftype.style ) ;
  SetIniKeyShort( h_ini, section_graphics, "FColor", ftype.color ) ;
  SetIniKeyShort( h_ini, section_graphics, "FSindex", ftype.sindex ) ;
  SetIniKeyShort( h_ini, section_graphics, "FPerimeter", ftype.perimeter ) ;

  SetIniKeyShort( h_ini, section_graphics, "MStyle", mtype.style ) ;
  SetIniKeyShort( h_ini, section_graphics, "MColor", mtype.color ) ;
  SetIniKeyShort( h_ini, section_graphics, "MHeight", mtype.height ) ;

  SetIniKeyShort( h_ini, section_graphics, "LStyle", ltype.style ) ;
  SetIniKeyShort( h_ini, section_graphics, "LColor", ltype.color ) ;
  SetIniKeyShort( h_ini, section_graphics, "LStKind", ltype.st_kind ) ;
  SetIniKeyShort( h_ini, section_graphics, "LEdKind", ltype.ed_kind ) ;
  SetIniKeyShort( h_ini, section_graphics, "LWidth", ltype.width ) ;

  SetIniKeyBool( h_ini, section_graphics, "RoundedSurfaces", cfg->flags & FLG_SROUND ) ;

  SetIniKeyShort( h_ini, section_graphics, "PType", pencil.type ) ;
  SetIniKeyShort( h_ini, section_graphics, "PHeight", pencil.height ) ;
  SetIniKeyShort( h_ini, section_graphics, "PColor", pencil.color ) ;

  sprintf( buf, "%u,%u,%u,%u,%u,%u,%u,%u,%u", config.thickness[0], config.thickness[1], config.thickness[2], config.thickness[3],
                                              config.thickness[4], config.thickness[5], config.thickness[6], config.thickness[7], config.thickness[8] ) ;
  SetIniKey( h_ini, section_graphics, "Thickness", buf ) ;

  /***************************** Section Log ********************************/
  /*  Logfile feature no longer used
  SetIniKey( h_ini, section_log, "LogFile", config.log_file ) ;
  SetIniKeyUShort( h_ini, section_log, "LogFlags", config.log_flags ) ; */

  /*************************************************************************/

  /*************************** Section SnapShot ****************************/
  SetIniKeyUShort( h_ini, section_snap, "SnapFlags", config.snap_flags ) ;

  /*************************** Section LDV  ********************************/
  SetIniKeyBool( h_ini, section_ldv, "Hide030", config.ldv_options & LDVO_HIDE030 ) ;
  SetIniKeyBool( h_ini, section_ldv, "HideDSP", config.ldv_options & LDVO_HIDEDSP ) ;
  SetIniKeyBool( h_ini, section_ldv, "HideFPU", config.ldv_options & LDVO_HIDEFPU ) ;

  SetIniKeyShort( h_ini, section_ldv, "PreviewSrcSize", config.ldv_preview_src_size ) ;
  SetIniKeyShort( h_ini, section_ldv, "PreviewDstSize", config.ldv_preview_dst_size ) ;

  /*************************************************************************/

  /***************************** Section Logging *******************************/
  SetIniKey( h_ini, section_logging, "LoggingFile", config.logging_file ) ;

  sprintf( buf, "%lx", config.logging_flags ) ;
  SetIniKey( h_ini, section_logging, "LoggingFlags", buf ) ;

  SetIniKeyShort( h_ini, section_logging, "LoggingFlushFreq", config.logging_flushfreq ) ;

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
  SetIniKeyBool( h_ini, section_vupdate, "Enabled", config.vu_enabled ) ;
  SetIniKeyBool( h_ini, section_vupdate, "Choice", config.vu_choice ) ;

  sprintf( buf, "%ld", config.vu_last_check ) ;
  SetIniKey( h_ini, section_vupdate, "LastCheck", buf ) ;

  sprintf( buf, "%ld", config.vu_mincheck_s ) ;
  SetIniKey( h_ini, section_vupdate, "MinCheck", buf ) ;

  SetIniKey( h_ini, section_vupdate, "Updater", config.vu_updater ) ;
  SetIniKey( h_ini, section_vupdate, "URL", config.vu_url ) ;
  SetIniKey( h_ini, section_vupdate, "TrustedCAFile", config.vu_trusted_ca_file ) ;

  /*************************************************************************/

  return( SaveAndCloseIni( h_ini, NULL ) ) ;
}

long LoadImgPriorities(HINI h_ini, VISION_CFG* cfg)
{
  long save_ini ;
  char p[NB_MST_MAX] ;
  char buf[PATH_MAX] ;
  int  n ;

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
    cfg->im_priority_global[2] = MST_IMGMOD ;
    cfg->im_priority_global[3] = MST_ZVLDG ;
#else
    cfg->im_priority_global[1] = MST_IMGMOD ;
    cfg->im_priority_global[2] = MST_ZVLDG ;
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

typedef struct _READ_ENTRY
{
  HINI  h_ini ;
  char* section ;
  long  save_ini ;
}
READ_ENTRY, *PREAD_ENTRY ;

static int ReadEntry_short(READ_ENTRY* re, char* key_name, short def_value)
{
  char buf[PATH_MAX] ;

  sprintf( buf, "%d", def_value ) ;
  re->save_ini |= GetOrSetIniKey( re->h_ini, re->section, key_name, buf ) ;
  return atoi( buf ) ;
}

static unsigned int ReadEntry_shortmask(READ_ENTRY* re, char* key_name, short def_value, int mask)
{
  unsigned int out_mask = 0 ;

  if ( ReadEntry_short( re, key_name, def_value ) ) out_mask |= mask ;

  return out_mask ;
}

void LoadVISIONIniFile(VISION_CFG* cfg)
{
  READ_ENTRY re ;
  char       buf[PATH_MAX] ;
  char       def_updater[] = "wget" ;
  char       def_url[]     = "http://jlusetti.free.fr/vupdate/staging/" ; /* As atari.org enforces https since 2024 or so */

  memzero( &re, sizeof(READ_ENTRY) ) ;
  memzero( cfg, sizeof(VISION_CFG) ) ;
  strcpy( cfg->version, NO_VERSION ) ;
  sprintf( buf, "%s\\VISION.INI", init_path ) ;
  if ( !FileExist( buf ) )
  {
    sprintf( buf, "VISION.INI" ) ;
    re.save_ini = 1 ;
  }

  LoggingDo(LL_INFO, "Loading VISION INI file %s...", buf) ;
  re.h_ini = OpenIni( buf ) ;

  /*********************** Section GENERAL ****************************/
  re.section = section_general ;
  sprintf( buf, "%s", "ENGLISH" ) ;
  re.save_ini |= GetOrSetIniKey( re.h_ini, section_general, "Language", buf ) ;
  strcpy( cfg->language, buf ) ;

  GemApp.Flags.HelpBubbles = 0 ;
#ifndef __NO_BUBBLE
  cfg->flags |= ReadEntry_shortmask( &re, "HelpBubbles", 1, FLG_HELP ) ;
  if ( cfg->flags & FLG_HELP ) GemApp.Flags.HelpBubbles = 1 ;
#endif

  cfg->flags |= ReadEntry_shortmask( &re, "DitherAuto", DITHER_AUTO, FLG_DITHERAUTO ) ;
  cfg->flags |= ReadEntry_shortmask( &re, "SplashWindow", 0, FLG_SPLASH ) ;
  cfg->flags |= ReadEntry_shortmask( &re, "DisplayToolBar", 1, FLG_TOOLBAR ) ;
  cfg->flags |= ReadEntry_shortmask( &re, "HexDumpOnError", 1, FLG_HEXDUMPONERR ) ;

  cfg->flag_fullscreen = ReadEntry_short( &re, "FullScreen", 0 ) ;
  cfg->w_info          = ReadEntry_short( &re, "InfoBar", 1 ) ;
  cfg->quitte          = ReadEntry_short( &re, "QuitIfNoWindow", 0 ) ;
  cfg->clip_gem        = ReadEntry_short( &re, "UseGEMClipboard", 0 ) ;
  cfg->souris_viseur   = ReadEntry_short( &re, "CrossMouse", 0 ) ;
  cfg->color_protect   = ReadEntry_short( &re, "ColorProtection", 1 ) ;
  cfg->dither_method   = ReadEntry_short( &re, "DitherMethod", DITHER_AUTO ) ;
  cfg->flags          |= ReadEntry_shortmask( &re, "UseLongFileNames", 0, FLG_LONGFNAME ) ;
  cfg->flags          |= ReadEntry_shortmask( &re, "ForceUseStdVDI", 0, FLG_FORCEUSESTDVDI ) ;
  cfg->rsrc_choice     = ReadEntry_short( &re, "RsrcChoice", -1 ) ;
  cfg->show_ibrowser   = ReadEntry_short( &re, "ShowIBrowser", 1 ) ;

  /**************************************************************************/

  /***************************** Section FOLDERS  ***************************/
  sprintf( buf, "%s\\LANGUES", init_path ) ;
  re.save_ini |= GetOrSetIniKey( re.h_ini, section_folders, "Languages", buf ) ;
  strcpy( cfg->path_language, buf ) ;

  sprintf( buf, "%s\\TEMP", init_path ) ;
  re.save_ini |= GetOrSetIniKey( re.h_ini, section_folders, "Temp", buf ) ;
  strcpy( cfg->path_temp, buf ) ;

  sprintf( buf, "%s", init_path ) ;
  re.save_ini |= GetOrSetIniKey( re.h_ini, section_folders, "Images", buf ) ;
  strcpy( cfg->path_img, buf ) ;

  sprintf( buf, "%s\\DSP", init_path ) ;
  re.save_ini |= GetOrSetIniKey( re.h_ini, section_folders, "DSP", buf ) ;
  strcpy( cfg->path_lod, buf ) ;

  sprintf( buf, "%s\\FILTRES", init_path ) ;
  re.save_ini |= GetOrSetIniKey( re.h_ini, section_folders, "Filters", buf ) ;
  strcpy( cfg->path_filter, buf ) ;

  sprintf( buf, "%s", init_path ) ;
  re.save_ini |= GetOrSetIniKey( re.h_ini, section_folders, "Album", buf ) ;
  strcpy( cfg->path_album, buf ) ;

  sprintf( buf, "%s\\LDV", init_path ) ;
  re.save_ini |= GetOrSetIniKey( re.h_ini, section_folders, "LDV", buf ) ;
  strcpy( cfg->path_ldv, buf ) ;

  buf[0] = 0 ;
  re.save_ini |= GetOrSetIniKey( re.h_ini, section_folders, "zvLDG", buf ) ;
  strcpy( cfg->path_zvldg, buf ) ;

  strcpy( buf, "C:\\GEMSYS\\IMGMOD" ) ;
  re.save_ini |= GetOrSetIniKey( re.h_ini, section_folders, "ImgMod", buf ) ;
  strcpy( cfg->path_imgmod, buf ) ;

#ifdef MST_ZVSLB
  buf[0] = 0 ;
  re.save_ini |= GetOrSetIniKey( re.h_ini, section_folders, "zvSLB", buf ) ;
  strcpy( cfg->path_zvslb, buf ) ;
#endif
  /**************************************************************************/

  /*************************** Section DSP **********************************/
  re.section         = section_dsp ;
  cfg->dspuse        = ReadEntry_short( &re, "UseDSP", DspInfo.use ) ;
  cfg->dsphandlelock = ReadEntry_short( &re, "HandleLock", DspInfo.WhatToDoIfLocked ) ;

  /**************************************************************************/

  /*************************** Section UNDO *********************************/
  re.section     = section_undo ;
  cfg->nb_undo   = ReadEntry_short( &re, "NbBuffers", 4 ) ;
  cfg->type_undo = ReadEntry_short( &re, "Type", 0 ) ;
  cfg->ko_undo   = ReadEntry_short( &re, "UseDiskIfKo", 0 ) ;
  cfg->use_redo  = ReadEntry_short( &re, "UseRedo", 1 ) ;

  /**************************************************************************/

  /*************************** Section Diaporama ****************************/
  re.section             = section_diaporama ;
  cfg->wait_mini_sec     = ReadEntry_short( &re, "WaitMiniSec", 0 ) ;
  cfg->do_not_show_mouse = ReadEntry_short( &re, "HideMouse", 0 ) ;
  cfg->do_not_cls_scr    = ReadEntry_short( &re, "DoNotClearScreen", 0 ) ;
  cfg->cycle             = ReadEntry_short( &re, "Cycle", 0 ) ;
  cfg->back              = ReadEntry_short( &re, "BackGroundColor", BACK_BLACK ) ;
  cfg->display_type      = ReadEntry_short( &re, "DisplayType", 0 ) ;
  cfg->transition        = ReadEntry_short( &re, "Transition", TRANSITION_NULL ) ;
  cfg->aff_name          = ReadEntry_short( &re, "DisplayName", 1 ) ;
  cfg->aff_prog          = ReadEntry_short( &re, "DisplayProg", 1 ) ;

  /**************************************************************************/

  /*************************** Section Zoom Temps Reel **********************/
  re.section          = section_rtzoom ;
  cfg->rt_zoomwhat    = ReadEntry_short( &re, "ObjectToZoom", 1 ) ;
  cfg->rt_respectgem  = ReadEntry_short( &re, "RespectGEM", 1 ) ;
  cfg->rt_optimizepos = ReadEntry_short( &re, "OptimizePosition", 1 ) ;
  cfg->rt_zoomlevel   = ReadEntry_short( &re, "ZoomLevel", 2 ) ;
  cfg->rt_height      = ReadEntry_short( &re, "RTHeight", 128 ) ;
  cfg->rt_width       = ReadEntry_short( &re, "RTWidth", 128 ) ;
  cfg->use_rtzoom     = ReadEntry_short( &re, "UseRtZoom", high_res ) ;

  /*************************************************************************/

  /************************** Section Graphics *****************************/
  re.section      = section_graphics ;
  mode_vswr       = ReadEntry_short( &re, "WriteMode", mode_vswr ) ;
  cfg->sgomme     = ReadEntry_short( &re, "EraserForm", 0 ) ;
  cfg->flags     |= ReadEntry_shortmask( &re, "MaskOutside", 0, FLG_MASKOUT ) ;
  ttype.wcar      = ReadEntry_short( &re, "TWCar", ttype.wcar ) ;
  ttype.hcar      = ReadEntry_short( &re, "THCar", ttype.hcar ) ;
  ttype.wcell     = ReadEntry_short( &re, "TWCell", ttype.wcell ) ;
  ttype.hcell     = ReadEntry_short( &re, "THCell", ttype.hcell ) ;
  ttype.angle     = ReadEntry_short( &re, "TAngle", ttype.angle ) ;
  ttype.font      = ReadEntry_short( &re, "TFont", ttype.font ) ;
  ttype.color     = ReadEntry_short( &re, "TColor", ttype.color ) ;
  ttype.attribute = ReadEntry_short( &re, "TAttribute", ttype.attribute ) ;
  ttype.hdisp     = ReadEntry_short( &re, "THdisp", ttype.hdisp ) ;
  ttype.vdisp     = ReadEntry_short( &re, "TVDisp", ttype.vdisp ) ;
  ftype.style     = ReadEntry_short( &re, "FStyle", ftype.style ) ;
  ftype.color     = ReadEntry_short( &re, "FColor", ftype.color ) ;
  ftype.sindex    = ReadEntry_short( &re, "FSIndex", ftype.sindex ) ;
  ftype.perimeter = ReadEntry_short( &re, "FPerimeter", ftype.perimeter ) ;
  mtype.style     = ReadEntry_short( &re, "MStyle", mtype.style ) ;
  mtype.color     = ReadEntry_short( &re, "MColor", mtype.color ) ;
  mtype.height    = ReadEntry_short( &re, "MHeight", mtype.height ) ;
  mtype.style     = ReadEntry_short( &re, "LStyle", mtype.style ) ;
  ltype.style     = ReadEntry_short( &re, "LStyle", ltype.style ) ;
  ltype.color     = ReadEntry_short( &re, "LColor", ltype.color ) ;
  ltype.st_kind   = ReadEntry_short( &re, "LStKind", ltype.st_kind ) ;
  ltype.ed_kind   = ReadEntry_short( &re, "LEdKind", ltype.ed_kind ) ;
  ltype.width     = ReadEntry_short( &re, "LWidth", ltype.width ) ;
  cfg->flags     |= ReadEntry_shortmask( &re, "RoundedSurfaces", 0, FLG_SROUND ) ;
  pencil.type     = ReadEntry_short( &re, "PType", pencil.type ) ;
  pencil.height   = ReadEntry_short( &re, "PHeight", pencil.height ) ;
  pencil.color    = ReadEntry_short( &re, "PColor", pencil.color ) ;

  GetDefThickness( buf ) ;
  re.save_ini |= GetOrSetIniKey( re.h_ini, section_graphics, "Thickness", buf ) ;
  GetThickness( cfg, buf ) ;

  /***************************** Section Log *******************************/
  /* Logfile feature no longer used
  re.section      = section_log ;
  cfg->log_flags  = ReadEntry_short( &re, "LogFlags", 0 ) ;
  cfg->log_file[0] = 0 ;
  re.save_ini |= GetOrSetIniKey( re.h_ini, section_log, "LogFile", cfg->log_file ) ; */

  /*************************************************************************/

  /*************************** Section SnapShot ****************************/
  re.section      = section_snap ;
  cfg->snap_flags = ReadEntry_short( &re, "SnapFlags", SF_ALLSCREEN ) ;

  sprintf( buf, "%x", SNAPSHOT ) ;
  re.save_ini |= GetOrSetIniKey( re.h_ini, section_snap, "SnapKeyViaConfig", buf ) ;
  sscanf( buf, "%x", &cfg->snap_keyviaconfig ) ;

  sprintf( buf, "%x", SSNAPSHOT ) ;
  re.save_ini |= GetOrSetIniKey( re.h_ini, section_snap, "SnapKeyDirect", buf ) ;
  sscanf( buf, "%x", &cfg->snap_keydirect ) ;

  /*************************************************************************/

  /*************************** Section LDV *********************************/
  re.section       = section_ldv ;
  cfg->ldv_options = 0 ;

  cfg->ldv_options         |= ReadEntry_shortmask( &re, "Hide030", 0, LDVO_HIDE030 ) ;
  cfg->ldv_options         |= ReadEntry_shortmask( &re, "HideDSP", 0, LDVO_HIDEDSP ) ;
  cfg->ldv_options         |= ReadEntry_shortmask( &re, "HideFPU", 0, LDVO_HIDEFPU ) ;
  cfg->ldv_preview_src_size = ReadEntry_short( &re, "PreviewSrcSize", 0 ) ;
  cfg->ldv_preview_dst_size = ReadEntry_short( &re, "PreviewDstSize", LDV_PREVIEWDEFAULTSIZE ) ;

  /************************* Section Logging **************************/
  /* Note that is information is already read & used since SetupRoots */
  re.section = section_logging ;
  strcpy( cfg->logging_file, "vision.log" ) ;
  re.save_ini |= GetOrSetIniKey( re.h_ini, section_logging, "LoggingFile", cfg->logging_file ) ;

  sprintf( buf, "%lx", LL_FATAL | LL_ERROR | LL_WARNING | LL_INFO ) ;
  re.save_ini |= GetOrSetIniKey( re.h_ini, section_logging, "LoggingFlags", buf ) ;
  sscanf( buf, "%lx", &cfg->logging_flags ) ;

  cfg->logging_flushfreq  = ReadEntry_short( &re, "LoggingFlushFreq", 1 ) ;

  /****************** Section Image Module Priorities ******************/
  re.save_ini |= LoadImgPriorities( re.h_ini, cfg ) ;

  /****************** Section VISION update ******************/
  re.section = section_vupdate ;
  cfg->vu_enabled = ReadEntry_short( &re, "Enabled", InternetAvailable() ) ;
  cfg->vu_choice  = ReadEntry_short( &re, "Choice", 1 ) ;

  sprintf( buf, "%lu", 0UL ) ;
  re.save_ini |= GetOrSetIniKey( re.h_ini, section_vupdate, "LastCheck", buf ) ;
  sscanf( buf, "%ld", &cfg->vu_last_check ) ;

  sprintf( buf, "%ld", 7L*24L*3600L ) ; /* Check updates once a week by default */
  re.save_ini |= GetOrSetIniKey( re.h_ini, section_vupdate, "MinCheck", buf ) ;
  sscanf( buf, "%ld", &cfg->vu_mincheck_s ) ;

  strcpy( cfg->vu_updater, def_updater ) ;
  re.save_ini |= GetOrSetIniKey( re.h_ini, section_vupdate, "Updater", cfg->vu_updater ) ;

  strcpy( cfg->vu_url, def_url ) ;
  re.save_ini |= GetOrSetIniKey( re.h_ini, section_vupdate, "URL", cfg->vu_url ) ;

  /* As atari.org now (2024?) enforces https and wgets is usually no compiled with TLS support on Mint */
  /* If we are using wget, make suse to use jlusetti.free.fr, at least as long as free.fr does not mandate https... */
  if ( (strcmp(cfg->vu_updater, def_updater) == 0) && (strcmp(cfg->vu_url, def_url) != 0) )
  {
    /* Make sure to use default valid URL for wget */
    strcpy( cfg->vu_url, def_url ) ;
    LoggingDo(LL_INFO, "Enforcing http URL for wget") ;
    re.save_ini = 1 ;
  }

  cfg->vu_trusted_ca_file[0] = 0 ;
  re.save_ini |= GetOrSetIniKey( re.h_ini, section_vupdate, "TrustedCAFile", cfg->vu_trusted_ca_file ) ;

  /*************************************************************************/

  if ( re.save_ini )  SaveAndCloseIni( re.h_ini, NULL ) ;
  else                CloseIni( re.h_ini ) ;

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

static int ajust_pathconfig(void)
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
  if ( !FolderExist(config.path_imgmod) ) LoggingDo(LL_INFO, "ImgMod IM path %s does not exist, VISION won't use any ImgView IM plugin", config.path_imgmod) ;
#ifdef MST_ZVSLB
  save_ini |= AdjustPath( config.path_zvslb, "zvSLB" ) ;
  if ( !FolderExist(config.path_zvslb) ) LoggingDo(LL_INFO, "zView SLB path %s does not exist, VISION won't use any zView SLB plugin", config.path_zvslb) ;
#endif
  save_ini |= AdjustPath( config.path_temp, "TEMP" ) ;
  if ( !FolderExist(config.path_temp) ) Dcreate( config.path_temp ) ;

  /* Let's make sure UPDATE folder exists */
  sprintf( tmp, "%s\\UPDATE", init_path ) ;
  if ( !FolderExist(tmp) ) Dcreate( tmp ) ;
  set_tmp_folder( config.path_temp ) ;

  return save_ini ;
}

static int get_prefs(void)
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

static void init_params(void)
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

  /* Init pencil */
  pencil.type   = 0 ; /* Square */
  pencil.height = 16 ;
  pencil.color  = 1 ;

  /* Cliboard initialzation */
  memzero( &clipboard, sizeof(clipboard) ) ;
  memzero( &vclip, sizeof(vclip) ) ;  
  vclip.form = BLOC_RECTANGLE ;
}

typedef struct _VMFORM
{
  char       mfid ;      /* Icon index in MOUSES tree */
  MOUSE_DEF* mouse_def ; /* Pointer to associated MOUSE_DEF structure */
  char       xhot ;
  char       yhot ;
  
}
VMFORM, *PVMFORM ;

static void init_mouseforms(void)
{
  ICONBLK*   micon ;
  OBJECT*    mouse_form ;
  VMFORM     vmforms[] = {
                           { MGOMME,    &mf_gomme,   0, 0, },
                           { MPEINTURE, &mf_peint,   0, 0, },
                           { MLOUPE,    &mf_loupe,   0, 0, },
                           { MPENCIL,   &mf_pencil,  2, 0, },
                           { MVISEUR,   &mf_viseur,  7, 7, },
                           { MAEROSOL,  &mf_aerosol, 9, 2, }
                         } ;
  VMFORM*    vmform ;
  MOUSE_DEF* mdef ;
 
  Xrsrc_gaddr( R_TREE, MOUSES, &mouse_form ) ;
  for ( vmform = &vmforms[0]; vmform < &vmforms[ARRAY_SIZE(vmforms)]; vmform++ )
  {
    mdef                    = vmform->mouse_def ;
    mdef->gr_mof.mf_xhot    = vmform->xhot ;
    mdef->gr_mof.mf_yhot    = vmform->yhot ;
    mdef->gr_mof.mf_nplanes = 1 ;
    mdef->gr_mof.mf_fg      = 0 ;
    mdef->gr_mof.mf_bg      = 1 ;
    micon                   = mouse_form[vmform->mfid].ob_spec.iconblk ;
    memcpy( &mdef->gr_mof.mf_mask, micon->ib_pmask, 16*sizeof(short) ) ;
    memcpy( &mdef->gr_mof.mf_data, micon->ib_pdata, 16*sizeof(short) ) ;
  }
}

static int init_msg(void)
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
    form_stop( buf ) ; 
  }

  return( hMsg ? 0:-1 ) ; /* -1: file not found, i.e. INI is wrong */
}

static void get_languages(void)
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
static int OnAppMouseMove(int bbutton, int mk_state, int mx, int my)
{
  int zoom_what = 0 ;

  if ( config.rt_zoomwhat != RTZ_SMART ) zoom_what = config.rt_zoomwhat ;
  rtzoom_display( mx, my, zoom_what ) ;

  return GW_EVTCONTINUEROUTING ;
}
#pragma warn +par

static void OnTerminateApp(void* ap)
{
  GEM_APP* app = (GEM_APP*) ap ;

/*  if ( config.log_stream ) fclose( config.log_stream ) ;  Logfile feature no longer used  */

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
static short StartVCSSCript(char* name)
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
  /* Need to queue VCS files if more than 1 as they are using GEM messages */
  if ( !VCSInScriptMode ) StartVCSSCript( name ) ;
  else
  {
    LoggingDo(LL_INFO, "VISION is already in script mode, adding %s to queue", name) ;
    if ( VCSScriptLastIndex < ARRAY_SIZE(VCSScriptNames) ) VCSScriptNames[VCSScriptLastIndex++] = name ;
    else                                                   LoggingDo(LL_ERROR, "Can't add script %s to current list", name) ;
  }
}
#endif

static void OnOpenFileApp(char* name)
{
  if ( FolderExist( name ) )
  {
    short recurse = xKbshift() & 0x06 ; /* Shift or Control pressed */
    char* folder_name = Xstrdup( name ) ;

    if ( folder_name )
    {
      char** cmds = Xalloc( sizeof(char*) ) ; /* That's overkill but Image Browser needs to free it anyway */

      if ( cmds )
      {
        cmds[0] = folder_name ;
        ControlListIBrowser( GWGetWindowByID("IBrowser"), folder_name, cmds, 1, recurse ) ;
        /* Now up to Image Browser to free foder_name and cmds */
      }
      else Xfree( folder_name ) ;
    }
  }
  else
  {
    char ext[10] ;

    get_ext( name, ext ) ;
    if ( strcmpi( ext, "VIC" ) == 0 )      traite_album( name ) ;
    else if ( strcmpi( ext, "VSS" ) == 0 ) traite_slideshow( name ) ;
#ifndef __NO_SCRIPT
    else if ( strcmpi( ext, "VCS" ) == 0 ) traite_command_script( name ) ;
#endif
    else load_wpicture( name, IID_UNKNOWN ) ;
  }
}

static int DrapDropMsg(DD_DATA* dd_data)
{
  GEM_WINDOW* wnd = (GEM_WINDOW*) dd_data->wnd_or_app ;
  short       icmd = dd_data->args.user[0] ; /* Our current command to execute */
  short       i, wnd_type = -1 ;
  short       recurse = 0 ;
  char*       wclassnames[] = { VIMG_CLASSNAME, HEXDUMP_CLASSNAME, VTOOLBAR_CLASSNAME, VIBROWSER_CLASSNAME } ;
  char*       filename = dd_data->args.cmds[icmd] ;

  LoggingDo(LL_DEBUG,"WM_RUN_ARGS (%d/%d) for %s", 1+icmd, dd_data->args.ncmds, filename ) ;
  if ( dd_data->kstate & 4 ) recurse = 1 ;  /* Control --> recurse for IBrowser */
  if ( dd_data->kstate & 2 ) wnd_type = 1 ; /* Shift --> force Hex-Dump         */
  else if ( wnd )
  {
    /* Drap and Drop recipient is a window */
    for ( i = 0; i < ARRAY_SIZE(wclassnames); i++ )
      if ( strcmpi( wnd->ClassName, wclassnames[i] ) == 0 ) { wnd_type = i ; break ; }
  }
  LoggingDo(LL_DEBUG,"DrapDropMsg, DD recipient window class is %s", (wnd_type == -1) ? "application":wclassnames[wnd_type] ) ;
  switch( wnd_type )
  {
    case 1:  /* Hex Dump */
             CreateHexDump( filename ) ;
             break ;

    case 3:  /* Image Browser */
             /* There will be only one call requesting Image Browser */
             /* To load all commands (files)                         */
             ControlListIBrowser( GWGetWindowByID("IBrowser"), dd_data->data, dd_data->args.cmds, dd_data->args.ncmds, recurse ) ;
             dd_data->args.user[0] = dd_data->args.ncmds ; /* Let it believe we are done to call free dd_data */
             break ;

    default: /* Let VISION decide */
             OnOpenFileApp( filename ) ;
             break ;
  }

  dd_data->args.user[0]++ ;
  if ( dd_data->args.user[0] < dd_data->args.ncmds )
  {
    int mesg[4] ;

    *((DD_DATA**)mesg) = dd_data ;
    PostMessage( NULL, WM_RUN_ARGS, mesg ) ; /* Queue next one */
  }
  else
  {
    /* If Image Browser, up to Image Browser window to free list of cmds/filenames */
    if ( wnd_type != 3 )
    {
      if ( dd_data->args.cmds ) Xfree( dd_data->args.cmds ) ;
      Xfree( dd_data->data ) ;
    }
    Xfree( dd_data ) ;
  }

  return 0 ;
}

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
      short st = SVCS_SCRIPTINVALID ;

      while ( (st != SVCS_SUCCESS) && (VCSScriptCurrentIndex < VCSScriptLastIndex) && (VCSScriptNames[VCSScriptCurrentIndex] != NULL) )
      {
        LoggingDo(LL_DEBUG, "CurrentScriptIndex=%d, LastScriptIndex=%d, next script name=%s", VCSScriptCurrentIndex, VCSScriptLastIndex, VCSScriptNames[VCSScriptCurrentIndex] ) ;
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
    short       do_it = 1 ;
    short       save_ini = 1 ;

    LoggingDo(LL_INFO, "New version is available: %s", VUContext->url_version) ;
    if ( config.vu_choice ) /* Ask or user's confirmation */
    {
      char buf[200] ;

      sprintf( buf, vMsgTxtGetMsg(MSG_UPDATEAVAILABLE), VUContext->url_version ) ;
      do_it = ( form_interrogation( 2, buf ) == 1 ) ;
    }
    if ( do_it )
    {
      short status ;

      VUContext->wprog = DisplayStdProg( vMsgTxtGetMsg(MSG_VUPDATING) , "", "", 0 ) ;
      status = AUPerformUpdate( VUContext ) ;
      GWDestroyWindow( VUContext->wprog ) ;
      if ( status == AU_UPDATEDONE )
      {
        vform_stop( MSG_UPDATEDONE ) ;
        ret = GW_EVTQUITAPP ;
      }
      else
      {
        char buf[128] ;

        LoggingDo(LL_ERROR, "Update failed with %d", status) ;
        sprintf( buf, vMsgTxtGetMsg(MSG_UPDATEFAILED), status ) ;
        form_stop( buf ) ;
        save_ini = 0 ;
      }
    }
    else LoggingDo(LL_INFO, "User decided to not proceed with update") ;

    Xfree( VUContext ) ;
    if ( save_ini )
    {
      time_t s ;

      time( &s ) ;
      config.vu_last_check = s ;
      SaveVISIONIniFile( &config ) ;
    }
  }
#endif

  if ( id == WM_RUN_ARGS ) ret = DrapDropMsg( *((DD_DATA**)mesg) ) ;

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
                     form_stop(  buf ) ;
                     break ;
  }
*/
  return code ;
}
#pragma warn +par

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
  char* ignore[] = { "vision.ini", "vision.log" } ;
  short i ;

  for ( i = 0;  i < ARRAY_SIZE(ignore); i++ )
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
          strcpy( VUContext->trusted_ca_file, config.vu_trusted_ca_file ) ;
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
                                    if ( form_interrogation( 1, vMsgTxtGetMsg(MSG_UPDATENOINTERNET) ) == 1 )
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

static int OnAppDragDrop(DD_DATA* dd_data)
{
  short free_dd_data = 1 ;

  if ( dd_data->header.type == 'ARGS' )
  {
    LoggingDo(LL_DEBUG,"OnAppDragDrop(ARGS), data=%s, ncmds=%d", dd_data->data, dd_data->args.ncmds) ;
    if ( dd_data->args.ncmds )
    {
      /* Let's initiate WM_USER message to queue all commands */
      int mesg[4] ;

      *((DD_DATA**)mesg) = dd_data ;
      PostMessage( NULL, WM_RUN_ARGS, mesg ) ;
      free_dd_data = 0 ;
    }
    else LoggingDo(LL_WARNING, "OnAppDragDrop(ARGS), no cmd") ;
  }
  else LoggingDo(LL_INFO, "Unknown DragDrop type %s", long2ASC(dd_data->header.type)) ;

  if ( free_dd_data )
  {
    if ( dd_data->data ) Xfree( dd_data->data ) ;
    if ( dd_data->args.cmds ) Xfree( dd_data->args.cmds ) ;
    Xfree( dd_data ) ;
  }

  return 0 ;
}

static char* MapID2Txt(int id)
{
  /* Map IDs needed by ImgLib to IDs in messages file */
  short id_msg[] =    {    MSG_DSPLOCK,    MSG_DECODAGELZW,    MSG_ENCODAGELZW,    MSG_DITHER,    MSG_TRSFFMTSTD,    MSG_LOOKSPDDRV,    MSG_PRINTCOLOR,    MSG_PRINTBW,    MSG_LOADINGIMG,    MSG_ROTATING,    MSG_DOGDOSIMG,    MSG_PRINTING,    MSG_DECODAGEPCB } ;
  short id_imglib[] = { IMGMID_DSPLOCK, IMGMID_LZWDECODING, IMGMID_LZWENCODING, IMGMID_DITHER, IMGMID_TRSFFMTSTD, IMGMID_LOOKSPDDRV, IMGMID_PRINTCOLOR, IMGMID_PRINTBW, IMGMID_LOADINGIMG, IMGMID_ROTATING, IMGMID_DOGDOSIMG, IMGMID_PRINTING, IMGMID_DECODAGEPCB } ;
  short i ;

  for ( i = 0; i < ARRAY_SIZE(id_msg); i++ )
    if ( id_imglib[i] == id ) { id = id_msg[i] ; break ; }

  if ( i == ARRAY_SIZE(id_msg) ) id = -1 ;

  return MsgTxtGetMsg( hMsg, id ) ;
}

static int OnInitApp(void* ap)
{
  GEM_APP*    app = (GEM_APP*) ap ;
  GEM_WINDOW* splash = NULL ;
  int         save_ini ;
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

  save_ini = get_prefs() ;
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
    if ( form_interrogation(1, vMsgTxtGetMsg(MSG_4COLORMODE) ) != 1 )
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

    GWShowCursor() ;
    LoggingDo(LL_FATAL, "Can't load resource file %s, you should delete VISION.INI for a fresh start and check VISION LANGUES folder", rsc_name);
    sprintf( bbuf, "[File %s is missing !|You should delete VISION.INI|for a fresh start!][ End ]", rsc_name );
    form_stop( bbuf ) ;
    OnTerminateApp( app ) ;

    return 1 ;
  }

#ifndef __NO_BUBBLE
  if ( BHelpInit() ) LoggingDo(LL_WARNING, "Not enough memory to get Help bubbles") ;
#endif

  ImgSetTxt4ID( MapID2Txt ) ;

  GetAppTitle( buf ) ;
  GWSetMenu( M_VISION, buf ) ;
  GWSetMenuStatus( 0 ) ;

  mod_paths[MST_LDI-MST_LDI]    = NULL ;               /* No dynamic LDI         */
  mod_paths[MST_ZVLDG-MST_LDI]  = config.path_zvldg ;  /* zView LDG plugins path */
  mod_paths[MST_IMGMOD-MST_LDI] = config.path_imgmod ; /* ImgMod IM plugins path */
#ifdef MST_ZVSLB
  mod_paths[MST_ZVSLB-MST_LDI]  = config.path_zvslb ;  /* zView SLB plugins path */
#endif
  DImgGetImgModules( mod_paths, NULL, vMsgTxtGetMsg(MSG_UPTIMGMOD), config.im_priority_global ) ;
  graf_mouse( ARROW, NULL ) ;
  if ( config.flags & FLG_SPLASH ) splash = display_splash( high_res ) ;

  num_fonts = 0 ;
  if ( Gdos ) num_fonts = vst_load_fonts( handle, 0 ) ;

  if ( splash ) GWDestroyWindow( splash ) ;

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
/* Logfile feature no longer used
  if ( config.log_file[0] != 0 )
  {
    char  bbuf[PATH_MAX] ;
    char* mode = "wb" ;

    if ( config.log_file[1] != ':' )
      sprintf( bbuf, "%s\\%s", init_path, config.log_file ) ; 
    else
      strcpy( bbuf, config.log_file ) ;
    if ( config.log_flags & LF_FLGAPPEND ) mode = "ab+" ;
    config.log_stream = fopen( bbuf, mode ) ;
  }
  else config.log_stream = NULL ;
*/
  app->OnKeyPressed   = OnAppKeyPressed ;
  app->OnMenuSelected = OnAppMenuSelected ;
  /* OnAppMouseMove is set when UpdateRTZoom4App is called */
  app->OnUpdateGUI    = OnAppUpdateGUI ;
  app->OnTerminate    = OnTerminateApp ;
  app->OnOpenFile     = OnOpenFileApp ;
  app->OnMsgUser      = OnAppMsgUser ;
  app->OnPreModal     = OnAppPreModal ;
  app->OnPostModal    = OnAppPostModal ;

  GWDDAddType( NULL, 'ARGS' ) ;
  app->DragDrop.OnDD = OnAppDragDrop ;

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

  /* Test zone */
  /* XFileTest(); */
  /* utest_xzview_err() ; */
  /* XPexec_eas( 0, "u:\\usr\\bin\\curl", "-L --cacert cacert.pem --get https://vision2.atari.org/vupdate/staging/vision.ver --output H:\\PURE_C\\PROJECTS\\VISION\\UPDATE\\vision.ver" ) ; */
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
  LoggingDo(LL_WARNING, "Reset memory upon free is enabled!") ;*/

  XallocInit( &allocConfig ) ;
}

int vget_txtbubblemsg(int obj, int* objs, int* msgs, int nb_elem, char* txt)
{
  int i ;

  for ( i = 0; i < nb_elem; i++ )
    if ( obj == objs[i] ) { strcpy( txt, vMsgTxtGetMsg(msgs[i]) ) ; break ; }

  return( i != nb_elem ) ;
}

void test_search_pattern(void)
{
#define SP_SIZE (1024L*1024L*4L)
  char*  buffer = (char*) Xcalloc( 1, SP_SIZE ) ;
  char*  patterns[7] = { "abcdefgh", "abCDefGh", "azertyuiopmlkjhgfdsqwxcvn,;:!", "aZerTyuIopmLkjhgFdsqWxcvn,;:!", "aaaaaaaaaaabbbbbbbbbbbbb", "v", "0123456789" } ;
  long   sresults[10] ;
  long   nresults ;
  long   offset = 0 ;
  int    i, j ;
  size_t t0 ;

  if ( buffer == NULL ) return ;

  LoggingDo(LL_INFO, "ARRAYçSIZE(patterns)=%ld", ARRAY_SIZE(patterns)) ;
  for ( i = 0; i < ARRAY_SIZE(patterns); i++ )
  {
    memcpy( buffer+offset, patterns[i], strlen(patterns[i]) ) ;
    memcpy( buffer+offset+SP_SIZE/2, patterns[i], strlen(patterns[i]) ) ;
    offset += (SP_SIZE/2)/7L ; /* Why ARRAY_SIZE(patterns) does not work? */
  }

  for ( j=SPT_BIN; j <= SPT_STRINGNOCASE; j++ )
  {
    t0 = clock() ;
    for ( i = 0; i < ARRAY_SIZE(patterns); i++ )
    {
      nresults = find_pattern( j, buffer, SP_SIZE, patterns[i], strlen(patterns[i]), sresults, ARRAY_SIZE(sresults) ) ;
      LoggingDo(LL_INFO, "Search for pattern %s(type %d): %ld occurences", patterns[i], j, nresults) ;
    }
    LoggingDo(LL_INFO, "Searches duration: %ldms", (1000L*(clock()-t0))/CLK_TCK) ;
  }

  Xfree( buffer ) ;
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
