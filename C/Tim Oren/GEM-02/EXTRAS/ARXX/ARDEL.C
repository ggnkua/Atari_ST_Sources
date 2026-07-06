/*
 *   ardel.c
 *
 *   delete command for arxx
 *
 *   Author:	Ton van Overbeek
 *		TPC862@ESTEC.BITNET
 *		1986-10-05
 */

#include <stdio.h>
#include <osbind.h>
#include "archive.h"

long eFread();
long eFwrite();

static WORD buff[512];			/* buffer for copying modules */
static struct armodhead modhead;	/* library module header */

int delmod(flib, libname, ftmp, tmpname, modnames, modcount, verbose)
WORD flib, ftmp;
int modcount, verbose;
char *libname, *tmpname, **modnames;
{
   WORD flag;				/* library flag, should be 0xff65 */ 
   WORD fobj;				/* handle for object file */
   int eolib = FALSE;			/* end-of-library flag */

   /*
    *	read and check library magic word
    */

   if (eFread(flib, libname, 2L, &flag) != 2L) return -1;
   if (flag != ARCHTYP) {
     errmsg("arxx: %s not in library format", libname);
     return -1;
   }

   buff[0] = ARCHTYP;
   if (eFwrite(ftmp, tmpname, 2L, buff) != 2L) return -1;

   while (modcount > 0) {
      eolib = search(flib, libname, ftmp, tmpname, *modnames, eolib,
                     0, verbose);
      if (eolib < 0) return -1;
      if (eolib) {
         errmsg("arxx: module %s not found", *modnames);
         return -1;
      }
      if (verbose) printf("d %s\n", *modnames);
      modcount--;
      modnames++;
   }

   /*
    *	copy remainder of library by searching for empty modulename
    */

   if (search(flib, libname, ftmp, tmpname, "", eolib,0, verbose) < 0) {
      return -1;
   }

   /*
    *	everything ok:
    *	write end-of-lib (0 word),
    *	rename temp file and delete original library
    */

   buff[0] = 0;
   if (eFwrite(ftmp, tmpname, 2L, buff) != 2L) return -1;
   Fclose(flib);
   Fclose(ftmp);
   Fdelete(libname);
   Frename(0, tmpname, libname);
   return 0;
}
