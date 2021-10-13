#ifndef __DEFS_H
#define __DEFS_H

/* Version number */
#define NO_VERSION   "1.0a0"

#ifndef __GEMTAIL_H
#define __GEMTAIL_H
#include "lang\gemtail.h"
#endif


#ifndef __STDIO
#include <stdio.h>     /* For PATH_MAX */
#endif

#ifndef __GWINDOWS_H
#include "..\tools\gwindows.h"
#endif

typedef struct _TF_INFO
{
  char FileName[PATH_MAX] ;
  int  x, y, w, h ;
  int  Last ;
}
TF_INFO, *PTF_INFO ;

typedef struct
{
  char version[9+1] ;

  /* Logging File */
  char          logging_file[PATH_MAX] ;
  unsigned long logging_flags ;
  short         logging_flushfreq ;

  unsigned int reload_tails:1 ;
  unsigned int rfu:         15 ;

  TF_INFO* TFInfo ;
  short    nTFInfo ;
}
GEMTAIL_CFG, *PGEMTAIL_CFG ;

extern GEMTAIL_CFG config ;

long GTSaveINIFile(GEMTAIL_CFG* conf) ;

#define WM_LOAD_TAIL WM_USER_FIRST

#endif
