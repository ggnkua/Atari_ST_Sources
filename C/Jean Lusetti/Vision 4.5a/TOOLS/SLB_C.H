#ifndef __SLB_C_H
#define SLB_C_H

typedef void* SHARED_LIB ;
typedef long (*SLB_EXEC)(void , ... ) ;
/*
  Unfortunately this does not work in Pure-C, because Pure-C has an
  error (!!!) here: cdecl is ignored if the function has a variable
  number of parameters.

typedef long (cdecl *SLB_EXEC)(SHARED_LIB *sl, long fn, short nargs, ... );
*/

extern long Slbopen(char* name, char* path, long min_ver, SHARED_LIB* sl, SLB_EXEC* fn ) ;
extern long Slbclose(SHARED_LIB* sl) ;

#endif