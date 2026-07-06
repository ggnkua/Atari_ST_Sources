/*
 *   arwrtmod.c
 *
 *   write command for arxx
 *
 *   Author:	Ton van Overbeek
 *		TPC862@ESTEC.BITNET
 *		1986-10-05
 */

#include <stdio.h>
#include <osbind.h>
#include "archive.h"

#define STDOUT	1

extern struct armodhead modhead;	/* library module header */
long eFread();

int wrtmod(flib, libname, modnames, modcount, verbose)
WORD flib;
int modcount, verbose;
char *libname, **modnames;
{
   WORD flag;				/* library flag, should be 0xff65 */ 
   WORD fobj;				/* handle for object file */
   int eolib = FALSE;			/* end-of-library flag */

   /*
    *	check if only one module asked and STDOUT redirected
    */

   if (modcount != 1) {
      errmsg("arxx: only 1 module allowed in arxx -w");
      return -1;
   }
   if (!fredir(STDOUT)) {
      errmsg("arxx: output must be redirected for arxx -w");
      return -1;
   }

   /*
    *	read and check library magic word
    */

   if (eFread(flib, libname, 2L, &flag) != 2L) return -1;
   if (flag != ARCHTYP) {
     errmsg("arxx: %s not in archive format", libname);
     return -1;
   }

   eolib = search(flib, libname, 0, NULL, *modnames, eolib,
                  NOCOPY, verbose);
   if (eolib < 0) return -1;
   if (eolib) {
      errmsg("arxx: module %s not found", *modnames);
      return -1;
   }
   if (copymodule(flib, libname, STDOUT, NULL, modhead.fsize)) {
      return -1;
   }
   if (verbose) errmsg("w %s", *modnames);

   Fclose(flib);
   return 0;
}
