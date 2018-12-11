/*******************/
/* Logging library */
/*******************/
#if !defined(__NO_LOGGING)
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include "logging.h"
#include "xfile.h"

#define NB_MAX_ARCH 20

static FILE*          ll_hLog=NULL ;
static char           ll_filename[PATH_MAX] ;
static char*          ll_extfilename ;
static int            ll_archno= -1 ;
static unsigned long  ll_size = 0 ;
static unsigned int   ll_flushfreq = 0 ;
static LOGGING_CONFIG LogConfig ;

static char* GetLabel(unsigned long level)
{
  char* label ;

  if      (level & LL_FATAL)   label = "[FATAL]" ;
  else if (level & LL_ERROR)   label = "[ERROR]" ;
  else if (level & LL_WARNING) label = "[WARN] " ;
  else if (level & LL_INFO)    label = "[INFO] " ;
  else if (level & LL_MEM)     label = "[MEM]  " ;
  else if (level & LL_IMG)     label = "[IMG]  " ;
  else if (level & LL_PERF)    label = "[PERF] " ;
  else if (level & LL_DEBUG)   label = "[DEBUG]" ;
  else if (level & LL_KEYCODE) label = "[KCODE]" ;
  else if (level & LL_GW2)     label = "[GWIN2]" ;
  else if (level & LL_GW1)     label = "[GWIN1]" ;
  else if (level & LL_TMP2)    label = "[TMP2] " ;
  else if (level & LL_TMP1)    label = "[TMP1] " ;
  else                         label = "[?????]" ;

  return label ; 
}

char* LoggingGetLabelLevels(unsigned long level_mask, char* labels, size_t labels_size)
{
  unsigned long bmask = 0x80000000L ;
  size_t        size_out = 0 ;

  while (bmask)
  {
    if (bmask & level_mask)
    {
      char* mlabel ;
      
      mlabel = GetLabel(bmask) ;
      /* Remove [], ignore ? */
      if ( strchr(mlabel, '?') == NULL )
      {
        size_t lsize ;
        char   *str, *c, tmp[16] ;

        str = tmp ;
        strcpy(str,mlabel) ;
        c = strchr(tmp, '[') ;
        if ( c ) str = 1+c ;
        c = strchr(tmp, ']') ;
        if (c) *c = 0 ;
        lsize  = 2+strlen(str) ;
        if (size_out + lsize < labels_size)
        {
          if (size_out) strcat(labels, "|") ;
          strcat(labels, str) ;
          size_out += lsize ;
        }
      }
    }
    bmask >>= 1 ;
  }

  return labels ;
}

static int GetArchNo(void)
{
  int seq = 0 ;

  ll_extfilename = strrchr(ll_filename, '.') ;
  if ( ll_extfilename )
  {
    char archname[PATH_MAX] ;

    *ll_extfilename = 0 ; /* Now ll_filename has no extension */
    for (seq=0; seq < LogConfig.MaxNbArchives; seq++)
    {
      sprintf(archname, "%s.%03d", ll_filename, seq) ;
      if (!FileExist(archname)) break ;
    }

    seq %= LogConfig.MaxNbArchives ;
    *ll_extfilename = '.' ; /* Restore extension */
  }

  return seq ;
}

unsigned long LoggingGetLevel(void)
{
  return LogConfig.Level ;
}

void LoggingClose(void)
{
  if ( ll_hLog )
    fclose( ll_hLog ) ;
  ll_size = 0 ;
  ll_hLog = NULL ;
}

void LoggingGetDefaultConfig(LOGGING_CONFIG* config)
{
  config->Flags         = LF_CLRLOGSONSTART ;
  config->Level         = LL_DISABLED ;
  config->MaxFileSize   = 1024L*1024L ; /* 1 MB max per file */
  config->MaxNbArchives = 10 ;
  config->FlushFreq     = 1 ;
}

static void LoggingSetDefaultConfig(void)
{
  LoggingGetDefaultConfig(&LogConfig) ;
}

static void ClearLogs(char* filename)
{
  char* extfilename ;
  int   seq = 0 ;

  unlink(filename) ;
  extfilename = strrchr(filename, '.') ;
  if ( extfilename )
  {
    char archname[PATH_MAX] ;

    *extfilename = 0 ; /* Now filename has no extension */
    for (seq=0; seq < NB_MAX_ARCH; seq++)
    {
      sprintf(archname, "%s.%03d", filename, seq) ;
      unlink(archname) ;
    }
    *extfilename = '.' ; /* Restore extension */
  }
}

static int iLoggingInit(char* filename, LOGGING_CONFIG* config, unsigned int clear_logs)
{
  int err = 0 ;

  LoggingClose() ;
  if ( (config == NULL) || (config->MaxNbArchives == 0) )
    LoggingSetDefaultConfig() ;
  else
    memcpy(&LogConfig, config, sizeof(LOGGING_CONFIG)) ;

  if (LogConfig.MaxNbArchives == 0) LogConfig.MaxNbArchives = 1 ;
  if (LogConfig.MaxNbArchives > NB_MAX_ARCH) LogConfig.MaxNbArchives = NB_MAX_ARCH ;
  if (clear_logs) ClearLogs(filename) ;
  ll_hLog  = fopen( filename, "a+" ) ;
  if ( ll_hLog != NULL )
  {
    strcpy(ll_filename, filename) ;
    ll_size  = file_size(filename) ;
    if (ll_archno == -1) ll_archno = GetArchNo() ;
  }
  else
    err = -1 ;

  return err ; 
}

int LoggingInit(char* filename, LOGGING_CONFIG* config)
{
  return iLoggingInit(filename, config, config->Flags & LF_CLRLOGSONSTART) ;
}
 
static void checkRoll(int r)
{
  if ( r > 0 )
  {
    ll_size += r ;
    if ( ++ll_flushfreq >= LogConfig.FlushFreq )
    {
      fflush(ll_hLog) ;
      ll_flushfreq = 0 ;
    }
    if ( ll_extfilename && (ll_size > LogConfig.MaxFileSize) )
    {
       char archname[PATH_MAX] ;

       LoggingClose() ;
       *ll_extfilename = 0 ; /* Now ll_filename has no extension */
       sprintf(archname, "%s.%03d", ll_filename, ll_archno++) ;
       ll_archno %= LogConfig.MaxNbArchives ;
       *ll_extfilename = '.' ; /* Restore extension */
       unlink(archname) ; /* delete maybe existing archive */
       rename(ll_filename, archname) ;
       (void)iLoggingInit(ll_filename, &LogConfig, 0) ;
     }
  }
}

int LoggingvDo(unsigned long level, char* format, va_list argp)
{
  int r = 0 ;

  if ( ll_hLog )
  {
    if ( level & LogConfig.Level )
    {
      time_t    s ;
      struct tm n ;

      time(&s) ;
      n=*localtime(&s) ;
      r = fprintf( ll_hLog, "%02d/%02d/%02d %02d:%02d:%02d %s ", 
            n.tm_mday, n.tm_mon+1, n.tm_year-100,
            n.tm_hour, n.tm_min, n.tm_sec,
            GetLabel(level) ) ;
      r += vfprintf(ll_hLog, format, argp);
      r += fprintf(ll_hLog, "\n") ;
      checkRoll(r) ;
    }
  }
  else
    r = -1 ;

  return r ; 
}

int LoggingDo(unsigned long level, char* format, ...)
{
  va_list argp ;
  int     r ;

  va_start(argp, format) ;
  r = LoggingvDo(level, format, argp) ;
  va_end(argp) ;

  return r ; 
}

#endif
