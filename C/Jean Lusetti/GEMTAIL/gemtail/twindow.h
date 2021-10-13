#ifndef __TWINDOW_H
#define __TWINDOW_H

#ifndef __STDIO
#include <stdio.h>     /* For PATH_MAX */
#endif

#ifndef __XGEM_H
#include "..\tools\xgem.h"
#endif

typedef struct _HIGHLIGHTDATA
{
  TEXT_TYPE TextType ;
  char      Keywords[64] ;
}
HIGHLIGHTDATA, *PHIGHLIGHTDATA ;

typedef struct _TWINDOW_PARAMS
{
  char FileName[PATH_MAX] ;

  long InitialBufferSize ;
  long MaxBufferSize ;
  long InitialNbLines ;

  long TimerMs ;

  int x, y, w, h ;

  int Font ;
  int HCar ;

  HIGHLIGHTDATA HighLightData[16] ;
  char          ExcludedKeywords[64] ;
}
TWINDOW_PARAMS, *PTWINDOW_PARAMS ;

typedef struct _TWLINE
{
  char*      Text ;
  TEXT_TYPE* TextType ;

  unsigned int lf_selected:1 ; /* Line is selected               */
  unsigned int lf_search:1 ;   /* Line is the result from search */
}
TWLINE, *PTWLINE ;

typedef struct __FINDTEXT_PARAMS
{
  char         string[64] ;
  TWLINE*      search_line ;
  char*        search_from ;
  unsigned int case_insensitive:1 ;
  unsigned int wrap:1 ;
  unsigned int reverse:1 ;
}
FINDTEXT_PARAMS, *PFINDTEXT_PARAMS ;

typedef struct _TWINDOW_DATA
{
  char* Buffer ;
  long  BufferSize ;
  long  InitialBufferSize ;
  long  MaxBufferSize ;
  long  BufferOffset ;

  TWLINE* Lines ;
  long    NbLines ;
  long    LastLine ;
  short   BegNewLine ;

  short gdos_fd ;
  long  fpos ;
  short nopen_errors ;

  FINDTEXT_PARAMS fparams ;
}
TWINDOW_DATA, *PTWINDOW_DATA ;

typedef struct _TWINDOW
{
  TWINDOW_PARAMS p ;
  TWINDOW_DATA   d ;
  void*          wnd ;
  long           UIFirstLine ;
  long           UILastLine ;
  long           UINbLines ;
  long           UICurrentSel ;

  /* Status flags */
  unsigned int sf_pause: 1 ;       /* Pause tailing         */
  unsigned int sf_nohighlight: 1 ; /* No highlight to apply */
  unsigned int sf_finstat:1 ;      /* Use Finstat call      */
}
TWINDOW, *PTWINDOW ;

#define TWINDOW_CLASSNAME "TWINDOW"


short TWCreate(TWINDOW_PARAMS* tw_params) ;
void  TWGetOrSetParams(char* name, TWINDOW_PARAMS* tw_params) ; /* name=NULL means set */
char* TWMultipleStringToCommaSep(char *s, char *d) ;

#endif