/***********************************************/
/* GEMTAIL, tail Linux command in a GEM window */
/* (c) LUSETTI Jean August 2021                */
/***********************************************/
#include  <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stddef.h>

#include       "..\tools\ini.h"
#include      "..\tools\xgem.h"
#include   "..\tools\logging.h"
#include  "..\tools\gwindows.h"
#include     "..\tools\xfile.h"

#include "defs.h"
#include "usract.h"

#include "usract.h"
#include "twindow.h"

GEMTAIL_CFG config ;

static char section_general[] = "General" ;
static char section_tails[]   = "Tails" ;
static char section_logging[] = "Logging" ;


static void OnTerminateApp(void* ap)
{
  GEM_APP* app = (GEM_APP*) ap ;

  if ( Gdos ) vst_unload_fonts( handle, 0 ) ;
  if ( app && app->Menu ) menu_bar( app->Menu, 0 ) ;
  Xrsrc_free() ;
}

static void GetAppTitle(char* buf)
{
  sprintf( buf, "  GemTail %s", config.version ) ;
}

static void OnAppUpdateGUI(void)
{
  GWSetMenuStatus( 1 ) ;
  if ( !GemApp.CurrentGemWindow )
  {
    GemApp.Menu[M_CLOSE].ob_state    |= DISABLED ;
    GemApp.Menu[M_COPY].ob_state     |= DISABLED ;
    GemApp.Menu[M_S_ALL].ob_state    |= DISABLED ;
    GemApp.Menu[M_FIND].ob_state     |= DISABLED ;
    GemApp.Menu[M_FINDNEXT].ob_state |= DISABLED ;
    GemApp.Menu[M_PARAMS].ob_state   |= DISABLED ;
    GemApp.Menu[M_CLEAR].ob_state    |= DISABLED ;
    GemApp.Menu[M_RELOAD].ob_state   |= DISABLED ;
    GemApp.Menu[M_PAUSE].ob_state    |= DISABLED ;
    menu_icheck( GemApp.Menu, M_PAUSE, 0 ) ;
  }
  else if ( strcmp( GemApp.CurrentGemWindow->ClassName, TWINDOW_CLASSNAME ) == 0 )
  {
    TWINDOW* tw = (TWINDOW*) GemApp.CurrentGemWindow->Extension ;

    menu_icheck( GemApp.Menu, M_PAUSE, tw->sf_pause ) ;
  }
}

long GTSaveINIFile(GEMTAIL_CFG* conf)
{
  HINI  h_ini ;
  char  buf[PATH_MAX] ;

  sprintf( buf, "%s\\GEMTAIL.INI", init_path ) ;
  h_ini = OpenIni( buf ) ;

  /*********************** Section GENERAL ****************************/
  sprintf( buf, "%d", conf->reload_tails ) ;
  SetIniKey( h_ini, section_general, "ReloadTails", buf ) ;

  /*********************** Section TAILS ****************************/
  if ( conf->reload_tails )
  {
    GEM_WINDOW* wnd = NULL ;
    char        tmp[128] ;
    short       n = 0 ;

    wnd = GWGetNextWindow( wnd ) ;
    while ( wnd )
    {
      if ( strcmp( wnd->ClassName, TWINDOW_CLASSNAME ) == 0 )
      {
        TWINDOW* tw = (TWINDOW*) wnd->Extension ;
        int      x, y, w, h ;
        char     tmp[64] ;

        sprintf( buf, "T%d", n ) ;
        SetIniKey( h_ini, section_tails, buf, tw->p.FileName ) ;
        GWGetCurrXYWH( wnd, &x, &y, &w, &h) ;
        sprintf( buf, "XYWH%d", n ) ;
        sprintf( tmp, "%d:%d:%d:%d", x, y, w, h ) ;
        SetIniKey( h_ini, section_tails, buf, tmp ) ;
      }
      wnd = GWGetNextWindow( wnd ) ;
      n++ ;
    }
    do
    {
      sprintf( buf, "T%d", n++ ) ;
      if ( GetIniKey( h_ini, section_tails, buf, tmp ) == 1 ) SetIniKey( h_ini, section_tails, buf, "" ) ;
    }
    while ( n < 20 ) ;
  }

  /*********************** Section LOGGING ****************************/
  SetIniKey( h_ini, section_logging, "LoggingFile", conf->logging_file ) ;

  sprintf( buf, "%lx", conf->logging_flags ) ;
  SetIniKey( h_ini, section_logging, "LoggingFlags", buf ) ;

  SetIniKeyShort( h_ini, section_logging, "LoggingFlushFreq", conf->logging_flushfreq ) ;

  return( SaveAndCloseIni( h_ini, NULL ) ) ;
}

static long GTLoadINIFile(GEMTAIL_CFG* conf)
{
  HINI h_ini ;
  char buf[PATH_MAX] ;
  long save_ini = 0 ;

  strcpy( conf->version, NO_VERSION ) ;

  sprintf( buf, "%s\\GEMTAIL.INI", init_path ) ;
  if ( !FileExist( buf ) )
  {
    sprintf( buf, "GEMTAIL.INI" ) ;
    save_ini = 1 ;
  }

  LoggingDo(LL_INFO, "Loading GEMTAIL INI file %s...", buf) ;
  h_ini = OpenIni( buf ) ;

  strcpy( buf, "1" ) ;
  save_ini |= GetOrSetIniKey( h_ini, section_general, "ReloadTails", buf ) ;
  if ( atoi( buf ) )
  {
    short  done = 0 ;

    conf->reload_tails = 1 ;
    while ( !done )
    {
      sprintf( buf, "T%d", conf->nTFInfo ) ;
      if ( (GetIniKey( h_ini, section_tails, buf, buf ) == 1) && buf[0] )
      {
        void* new_alloc ;

        new_alloc = Xrealloc( conf->TFInfo, (1+conf->nTFInfo)*sizeof(TF_INFO)) ;
        if ( new_alloc )
        {
          conf->TFInfo = new_alloc ;
          conf->TFInfo[conf->nTFInfo].Last = 0 ;
          strcpy( conf->TFInfo[conf->nTFInfo].FileName, buf ) ;
          sprintf( buf, "XYWH%d", conf->nTFInfo ) ;
          if ( GetIniKey( h_ini, section_tails, buf, buf ) == 1 )
          {
            int x, y, w, h ;

            if ( sscanf( buf, "%d:%d:%d:%d", &x, &y, &w, &h ) == 4 )
            {
              conf->TFInfo[conf->nTFInfo].x = x ;
              conf->TFInfo[conf->nTFInfo].y = y ;
              conf->TFInfo[conf->nTFInfo].w = w ;
              conf->TFInfo[conf->nTFInfo].h = h ;
            }
          }
          conf->nTFInfo++ ;
        }
        else done = 1 ;
      }
      else done = 1 ;
    }
    if ( conf->nTFInfo )
    {
      int mesg[4] ;

      conf->TFInfo[conf->nTFInfo-1].Last = 1 ;
      LoggingDo(LL_INFO, "%d tail files to be open", conf->nTFInfo) ;
      *((TF_INFO**)mesg) = conf->TFInfo ;
      PostMessage( NULL, WM_LOAD_TAIL, mesg ) ;
    }
  }
  else conf->reload_tails = 0 ;

  if ( save_ini )  SaveAndCloseIni( h_ini, NULL ) ;
  else             CloseIni( h_ini ) ;
  LoggingDo(LL_INFO, "GEMTAIL INI loaded!") ;

  return save_ini ;
}

#pragma warn -par
static int OnAppMsgUser(void* app, int id, int* mesg)
{
  if ( id == WM_LOAD_TAIL ) 
  {
    TF_INFO* tfinfo = *((TF_INFO**)mesg) ;

    XOpenFileApp( tfinfo->FileName, tfinfo->x, tfinfo->y, tfinfo->w, tfinfo->h ) ;
    if ( tfinfo->Last )
    {
      Xfree( config.TFInfo ) ;
      config.TFInfo = NULL ;
      config.nTFInfo = 0 ;
    }
    else
    {
      tfinfo++ ;
      *((TF_INFO**)mesg) = tfinfo ;
      PostMessage( NULL, WM_LOAD_TAIL, mesg ) ; /* Queue next one */
    }
  }

  return 0 ;
}
#pragma warn +par

static void OnOpenFileApp(char* name)
{
  XOpenFileApp( name, 0, 0, 0, 0) ;
}

static int OnInitApp(void* ap)
{
  GEM_APP* app = (GEM_APP*) ap ;
  long     save_ini ;
  char     rsc_name[PATH_MAX] ;
  char     buf[64] ;

  graf_mouse( BUSYBEE, NULL ) ;

  LoggingDo(LL_INFO, "GEMTAIL initializes...") ;
  LoggingDo(LL_INFO, "AES Version:%x.%x", AESVersion >> 8, AESVersion & 0xFF ) ;
  LoggingDo(LL_INFO, "Graphics:%dx%d, %d planes %s", screen.fd_w, screen.fd_h, screen.fd_nplanes, Truecolor ? "(Truecolor)":"" ) ;

  save_ini = GTLoadINIFile( &config ) ;

  sprintf( rsc_name, "LANG\\GEMTAIL.RSC" ) ;

  LoggingDo(LL_INFO, "Loading RSC file %s", rsc_name) ;
  if ( Xrsrc_load( rsc_name, 1 ) == 0 ) /* AES to load resource file */
  {
    char bbuf[PATH_MAX] ;

    LoggingDo(LL_FATAL, "Can't load resource file %s, you should delete GEMTAIL.INI for a fresh start and check GEMTAIL LANG folder", rsc_name) ;
    sprintf( bbuf, "[File %s is missing !|You should delete GEMTAIL.INI|for a fresh start!][ End ]", rsc_name ) ;
    form_stop( 1, bbuf ) ;
    OnTerminateApp( app ) ;

    return 1 ;
  }

  GetAppTitle( buf ) ;
  GWSetMenu( M_GEMTAIL, buf ) ;
  GWSetMenuStatus( 0 ) ;

  if ( Gdos ) num_fonts = vst_load_fonts( handle, 0 ) ;
  else        num_fonts = 0 ;

  app->OnKeyPressed   = OnAppKeyPressed ;
  app->OnMenuSelected = OnAppMenuSelected ;
  app->OnTerminate    = OnTerminateApp ;
  app->OnOpenFile     = OnOpenFileApp ;
  app->OnUpdateGUI    = OnAppUpdateGUI ;
  app->OnMsgUser      = OnAppMsgUser ;
/*
  GWDDAddType( NULL, 'ARGS' ) ;
  app->DragDrop.OnDD = OnAppDragDrop ;
*/

  if ( Multitos )
  {
    LoggingDo(LL_INFO, "Long filenames enabled") ;
    Pdomain( 1 ) ;
  }

  LoggingDo(LL_INFO, "GEMTAIL %s is up and running!", config.version) ;
  graf_mouse( ARROW, 0L ) ;

  if ( save_ini ) GTSaveINIFile( &config ) ;

  return 0 ;
}

static void SetupRoots(void)
{
  LOGGING_CONFIG logconfig ;
  char           buf[PATH_MAX] ;
  char           lflags[128] ;
  XALLOC_CONFIG  allocConfig ;

  strcpy( init_path, "GEMTAIL.PRG" ) ;
  if ( shel_find( init_path ) != 0 )
  {
    char* last_aslash = strrchr( init_path, '\\' ) ;

    if ( last_aslash ) *last_aslash = 0 ;
  }
  else init_path[0] = 0 ; /* Let library set it up */

  LoggingGetDefaultConfig( &logconfig ) ;
  strcpy( config.logging_file, "GEMTAIL.log" ) ;
  GetIniKeyFromFile( "GEMTAIL.ini", section_logging, "LoggingFile", config.logging_file ) ;
  if ( config.logging_file[1] != ':' )
  {
    /* Not a full path */
    strcpy( buf, config.logging_file ) ;
    sprintf( config.logging_file, "%s\\%s", init_path, buf ) ;
  }

  sprintf( buf, "%lx", LL_FATAL | LL_ERROR | LL_WARNING | LL_INFO ) ;
  GetIniKeyFromFile( "GEMTAIL.ini", section_logging, "LoggingFlags", buf ) ;
  sscanf( buf, "%lx", &config.logging_flags ) ;

  sprintf( buf, "%d", 1 ) ;
  GetIniKeyFromFile( "GEMTAIL.ini", section_logging, "LoggingFlushFreq", buf ) ;
  config.logging_flushfreq = atoi(buf) ;

  logconfig.Level     = config.logging_flags ;
  logconfig.FlushFreq = config.logging_flushfreq ;

  LoggingInit( config.logging_file, &logconfig ) ;
  LoggingDo(LL_INFO, "Startup path: %s", init_path) ;
  LoggingDo(LL_INFO, "GEMTAIL logs to %s with level $%lX(%s), flush frequency=1/%d", config.logging_file, logconfig.Level, LoggingGetLabelLevels(logconfig.Level, lflags, sizeof(lflags)), logconfig.FlushFreq) ;

  XallocGetDefaultConfig( &allocConfig ) ;
  allocConfig.StatsEverynSec = 60 ;

  XallocInit( &allocConfig ) ;
/*  DEBUG MEMORY only allocConfig.Flags = FA_RESET_MEM_ON_FREE ;
  LoggingDo(LL_WARNING, "Reset memory upon free is enabled!") ;*/
}

int main(int argc, char** argv)
{
  GEM_APP* theApp ;

  SetupRoots() ;
  theApp = GWGetApp( argc, argv ) ;

  theApp->OnInit = OnInitApp ;
  GWDeclareAndRunApp( theApp ) ;

  XallocExit() ;
  LoggingDo(LL_INFO, "GEMTAIL is now exiting") ;
  LoggingClose() ;

  return 0 ;
}
