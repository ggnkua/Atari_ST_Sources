/* --------------------------------------------------------------------
   Modul:      ACCESS.C
   Subject:    access() Funktion
   Author:     ho
   Started:    03.11.91     13:27:44
   Modified:   03.11.91     13:39:52
   -------------------------------------------------------------------- */


#include <ext.h>
#include <tos.h>
#include <errno.h>



int access(char *pName, int mode)
{
   struct ffblk ffblk;

   if (findfirst(pName, &ffblk, 0) == 0)
   {
      if ((ffblk.ff_attrib & FA_RDONLY) && (mode & 0x02))
      {
         errno = EACCES;
         return -1;
      }
   }
   else
   {
      errno = ENOENT;
      return -1;
   }

   return 0;
}
