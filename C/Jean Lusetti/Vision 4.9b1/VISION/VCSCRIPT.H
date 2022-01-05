#ifndef __VISION_COMMAND_SCRIPT_H
#define __VISION_COMMAND_SCRIPT_H

#include "..\tools\gwindows.h"

#define SVCS_NOMOREDATA      -14
#define SVCS_VARARRAYFULL    -13
#define SVCS_VARNAMETOOBIG   -12
#define SVCS_UNKNOWNVARIABLE -11
#define SVCS_SCRIPTINVALID   -10
#define SVCS_MISSINGP5       -7
#define SVCS_MISSINGP4       -6
#define SVCS_MISSINGP3       -5
#define SVCS_MISSINGP2       -4
#define SVCS_MISSINGP1       -3
#define SVCS_UNKNOWNCMD      -2
#define SVCS_FILENOEXIST     -1
#define SVCS_SUCCESS          0
#define SVCS_NOMORECMD        1
#define SVCS_EXITREQUEST      2
#define SVCS_WAIT             3
#define SVCS_CMDFAILED       10
#define SVCS_NOMEMORY        11
#define SVCS_LOOPINVALID     12
#define SVCS_INVALIDPARAM    13
#define SVCS_IMGLOADERROR    14

#define VCS_MAGIC '_VCS'

typedef struct
{
  short NbLoopsToGo ;
  short StartLoopIndex ;
  short LoopIndex ;
}
LOOP_DATA, *PLOOP_DATA ;
#define NB_NESTED_LOOPS 4

typedef struct
{
  FILE*     FileList ;
  LOOP_DATA Loop ;
}
LOOPFOLDER_DATA, *PLOOPFOLDER_DATA ;

typedef struct
{
  char  Name[15+1] ;
  char* Value ;
  short ValLen ;
}
GLOBAL_VARIABLE, *PGLOBAL_VARIABLE ;
#define NB_GLOBAL_VARIABLE 8

typedef struct
{
  long            Magic ;
  char            FileName[PATH_MAX] ;
  void*           ChildScript ;
  void*           ScriptContext ;
  char*           Buffer ;
  size_t          BufferLength ;
  short           LineIndex ;
  short           LastLineIndex ;
  char**          PtrLines ;
  short           LoopDepth ;
  LOOP_DATA       LoopData[NB_NESTED_LOOPS] ;
  LOOPFOLDER_DATA LoopFolderData ;
  GLOBAL_VARIABLE GlobalVariable[NB_GLOBAL_VARIABLE] ;

  /* For the current command line */
  /* 10 parameters max            */
  short nparams ;
  char* params[10] ;

  clock_t LastCmdLDVDoCall ;
}
VCMD_SCRIPT, *PVCMD_SCRIPT ;

#define WM_CMDSCRIPT_EXELINE WM_USER_FIRST

short LoadCommandScript(char* name, VCMD_SCRIPT* vcmd_script) ;
short ExeNextCommandLine(VCMD_SCRIPT* vcmd_script) ;
void  FreeScript(VCMD_SCRIPT* vcmd_script) ;

#endif