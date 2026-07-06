/*
 *   arlist.c
 *
 *   list command for arxx
 *
 *   Author:	Ton van Overbeek
 *		TPC862@ESTEC.BITNET
 *		1986-10-05
 */

#include <stdio.h>
#include <osbind.h>
#include "archive.h"

long eFread();
long eFseek();

listlib(flib, libname, verbose)		/* list contents of library */
int flib;				/* file handle */
char *libname;				/* library filename */
int verbose;				/* TRUE if -v specified */
{
   WORD flag;				/* library flag, should be 0xff65 */ 
   struct armodhead modhead;		/* library module header */
   long count;

   /*
    *	read and check library flag
    */

   if (eFread(flib, libname, 2L, &flag) != 2L) {
     return -1;
   }
   if (flag != ARCHTYP) {
     errmsg("arxx: %s not in archive format", libname);
     return -1;
   }

   /*
    *	list module names and sizes
    */

   while (TRUE) {

      /* read module header and check if not end of library */

      if ((count = Fread(flib, (long) sizeof(modhead), &modhead)) != 
          (long) sizeof(modhead)) {
        if ((count > 0) && (modhead.fname[0] == (char)0)) {
           break;					/* end of library */
        }
        errmsg("arxx: read error on %s", libname);
        return -1;
      }
      if (modhead.fname[0] == (char) 0 ) break;		/* end of library */

      /* print module name and size */

      printf("%-12s %6ld", modhead.fname, modhead.fsize);

      /* if not verbose skip object file */

      if (!verbose) {
         if (eFseek(modhead.fsize, flib, libname) < 0) {
           return -1;
         }
      } else {

         /* list global symbols */

         struct objfhead objecth;
         struct symbtab symbolt;
         int nsym;		/* nr of symbols printed for this module */

         if (eFread(flib, libname, (long) sizeof(objecth), &objecth) !=
             (long) sizeof(objecth)) {
           return -1;
         }
         if (eFseek(objecth.textsize + objecth.datasize, flib, libname) < 0) {
           return -1;
         }
         count = objecth.symtsize;
         nsym = 0;
         while (count > 0) {
            if (eFread(flib, libname, (long) sizeof(symbolt), &symbolt) !=
                (long) sizeof(symbolt)) {
               return -1;
            }
            if ((symbolt.symtype & 0x2600) >= 0x2200 ||
                (symbolt.symtype == 0xA800 && symbolt.symvalue)) {
               if (nsym && ((nsym % 6) == 0)) printf("\n%19s", "");
               if (symbolt.symtype & 0x0200) {		/* text segment */
                  printf("  ");
               } else if (symbolt.symtype & 0x400) {	/* data segment */
                  printf(" *");
               } else if (symbolt.symtype == 0xA800) {	/* common */
                  printf(" %%");
               }
               symbolt.symtype = 0;		/* force terminated string */
               printf("%-8s", symbolt.symname);
               nsym++;
            }
            count -= sizeof(symbolt);
         }
         /* skip relocation info */
         count = modhead.fsize - sizeof(objecth) - objecth.textsize -
                 objecth. datasize - objecth.symtsize;
         if (eFseek(count, flib, libname) < 0) {
           return -1;
         }
      }
      printf("\n");
   }
   return 0;
}
