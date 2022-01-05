#ifndef __XFILE_H
#define __XFILE_H

#ifndef __GWINDOWS_H
#include "..\tools\gwindows.h"
#endif


/* A simplified structure for FILE (stdio) as */
/* PureC stdio file functions are pretty slow */
/* Over a NFS connection                      */
typedef struct _XFILE
{
  int    valid ;
  int    gdos_fd ;
  size_t cache_size ;
  size_t file_size ;    /* Filled in only if cache_size=-1 in XFopen */
  char*  cache_buffer ;
  long   cache_start ;
  long   cache_end ;
  long   physical_seek_ptr ;
  long   logical_seek_ptr ;
  long   ncache_hits ;
  long   nreads ;
}
XFILE, *PXFILE ;

int   FileExist(char* file) ;
int   FolderExist(char* folder) ;
int   CopyFile(char* src, char* dst) ;
int   CopyFileR(char* src, char* dst) ;
void* CreateFileR(char* name) ; /* FILE* returned */
int   MoveFile(char* src, char* dst) ;
int   CreateFolder(char* path) ;
int   CmpFiles(char* f1, char* f2) ;
long  FileTxtStats(char* filename, long* nbytes) ;

long XFopen(XFILE* xfile, char* name, short mode, long cache_size) ;
int  XFclose(XFILE* xfile) ;
long XFseek(XFILE* xfile, long offset, short seek_mode) ;
long XFread(XFILE* xfile, void* buf, long count) ;

void ImgFTrackExit(void) ;
void XFileTest(void) ;

long XFinstat(short fd) ;

#endif
