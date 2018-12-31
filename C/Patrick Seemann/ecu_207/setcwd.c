/* --------------------------------------------------------------------
      SETCWD.C       changes drive and directory

      18.08.90       ho
   -------------------------------------------------------------------- */



#include "clib.h"

#if defined(__TOS__)
   #include <tos.h>
#else
   #include <dir.h>
   #define  Dgetdrv  getdisk
   #define  Dsetdrv  setdisk
   #define  Dsetpath chdir
#endif

#include <ctype.h>



BOOL setcwd(char *pDir)
{
   int   drive;

   drive = Dgetdrv();
   if (isalpha(pDir[0]) && pDir[1] == ':')
   {
      Dsetdrv(toupper(pDir[0]) - 'A');
      pDir += 2;
   }
   
   if (Dsetpath(pDir) < 0)
   {
      Dsetdrv(drive);
      return FALSE;
   }
      
   return TRUE;
}   
