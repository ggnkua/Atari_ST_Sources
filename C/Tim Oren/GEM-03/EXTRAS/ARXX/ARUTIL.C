/*
 *   arutil.c
 *
 *   support routines for arxx
 *
 *   Author:	Ton van Overbeek
 *		TPC862@ESTEC.BITNET
 *		1986-10-05
 */

#include <osbind.h>
#include "archive.h"

#define TRUE	1
#define FALSE	0

int fredir(handle)	/* returns TRUE if handle belongs to a diskfile */
WORD handle;
{
   register long position;

   /*  First we write 2 characters (space + backspace).
    *  If output is to console a following Fseek will return 0L.
    *  If Fseek returns a positive position, we put the pointer
    *  back where we started and return TRUE.
    */

   if (Fwrite(handle, 2L, " \010") != 2L) {
      return FALSE;
   }
   if ((position = Fseek(0L, handle, 1)) > 0L) {
      Fseek(-2L, handle, 1);
      return TRUE;
   }
   return FALSE;
}

errmsg(plist, arg1, arg2, arg3)		/* print an errormessage on the */
char *plist, *arg1, *arg2, *arg3;	/* screen			*/
{
   char buff[81];
   sprintf(buff, plist, arg1, arg2, arg3);
   Fwrite(-1, (long) strlen(buff), buff);
   Fwrite(-1, 2L, "\r\n");
}

/*
 *   File routines with error check
 */

long eFread(handle, fname, count, buff)
WORD handle;
char *fname;
long count;
char *buff;
{
   register long n;

   n = Fread(handle, count, buff);
   if (n < 0L) {
      errmsg("arxx: read error on %s", fname);
   }
   return n;
}

long eFwrite(handle, fname, count, buff)
WORD handle;
char *fname;
long count;
char *buff;
{
   register long n;

   n = Fwrite(handle, count, buff);
   if (n != count) {
      errmsg("arxx: write error on %s", fname);
   }
   return n;
}

long eFseek(count, handle, fname)
WORD handle;
char *fname;
long count;
{
   register long n;

   n = Fseek(count, handle, 1);
   if (n < 0L) {
      errmsg("arxx: seek error on %s", fname);
   }
   return n;
}
