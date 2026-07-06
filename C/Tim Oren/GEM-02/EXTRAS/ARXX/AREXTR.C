/*
 *   arextr.c
 *
 *   extract command for arxx
 *
 *   Author:	Ton van Overbeek
 *		TPC862@ESTEC.BITNET
 *		1986-10-05
 */

#include <stdio.h>
#include <osbind.h>
#include "archive.h"

extern struct armodhead modhead;	/* library module header */
long eFread();

int extrmod(flib, libname, modnames, modcount, verbose)
WORD flib;
int modcount, verbose;
char *libname, **modnames;
{
   WORD flag;				/* library flag, should be 0xff65 */ 
   WORD fobj;				/* handle for object file */
   int eolib = FALSE;			/* end-of-library flag */

   /*
    *	read and check library magic word
    */

   if (eFread(flib, libname, 2L, &flag) != 2L) return -1;
   if (flag != ARCHTYP) {
     errmsg("arxx: %s not in archive format", libname);
     return -1;
   }

   while (modcount > 0) {
      eolib = search(flib, libname, 0, NULL, *modnames, eolib,
                     NOCOPY, verbose);
      if (eolib < 0) return -1;
      if (eolib) {
         errmsg("arxx: module %s not found", *modnames);
         return -1;
      }
      if ((fobj = Fcreate(*modnames, 0)) < 0) {
         errmsg("arxx: cannot create %s", *modnames);
         return -1;
      }
      if (copymodule(flib, libname, fobj, *modnames, modhead.fsize)) {
         return -1;
      }
      Fclose(fobj);
      if (verbose) printf("x %s\n", *modnames);
      modcount--;
      modnames++;
   }

   Fclose(flib);
   return 0;
}
