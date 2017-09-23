#ifndef __XFILE
#define __XFILE

#ifdef MEMDEBUG
#include "d:\pure_c\projects\tools\memdebug\memdebug.h"
#endif

#ifndef __GWINDOWS
#include "gwindows.h"
#endif


#define MD_ERASEDST   0
#define MD_CANCELOPE  1
typedef struct
{
  int manage_dst ;

  GEM_WINDOW *wprog ;
}
XFILE_OPTIONS ;

void SetXFileOptions(XFILE_OPTIONS *options) ;
int  FileExist(char *file) ;
int  CopyFile(char *src, char *dst) ;
int  MoveFile(char *src, char *dst) ;
int CreateFolder(char *path) ;
int CmpFiles(char *f1, char *f2) ;


#endif
