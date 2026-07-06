/*
 *   arrepl.c
 *
 *   replace command for arxx
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
long eFseek();

static WORD buff[512];			/* buffer for copying modules */
struct armodhead modhead;		/* library module header */

replmod(flib, libname, ftmp, tmpname, modnames, modcount,
        aftbef, opmod, verbose)
WORD flib, ftmp;
int modcount, aftbef, verbose;
char *libname, *tmpname, **modnames, *opmod;
{
   WORD flag;				/* library flag, should be 0xff65 */ 
   WORD fobj;				/* handle for object file */
   int retval;				/* return value from insert/replace */

   /*
    *	read and check library flag
    */

   if (eFread(flib, libname, 2L, &flag) != 2L) return -1;
   if (flag != ARCHTYP) {
     errmsg("arxx: %s not in archive format", libname);
     return -1;
   }

   buff[0] = ARCHTYP;
   if (eFwrite(ftmp, tmpname, 2L, buff) != 2L) return -1;

   /*
    *	if -a or -b option is not specified replace modules in the order
    *   specified in modnames, otherwise insert the modnames modules after
    *	or before opmod.
    */

   if (aftbef == 0) {
      retval = replace(flib, libname, ftmp, tmpname, modnames, modcount,
                       verbose);
   } else {
      retval = insert(flib, libname, ftmp, tmpname, modnames, modcount,
                      opmod, aftbef, verbose);
   }
   if (retval) return -1;

   /*
    *	Everything ok up till now.
    *	Write end-of-lib (0 word),
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

static int replace(flib, libname, ftmp, tmpname, modnames, modcount, verbose)
WORD flib, ftmp;
int modcount, verbose;
char *libname, *tmpname, **modnames;
{
   WORD fobj;				/* handle for object file */
   int eolib = FALSE;			/* end-of-library flag */
   long count;				/* nr of bytes read/written */
   long getfsize();			/* get filesize from directory */
   int i;

   while (modcount > 0) {
      if((fobj = Fopen(*modnames, 0)) < 0) {
         errmsg("arxx: cannot open %s", *modnames);
         return -1;
      }
      count = getfsize(*modnames);
      /* check if really an object file */
      if (checkobj(fobj, *modnames, count)) {
         errmsg("arxx: %s not an object file", *modnames);
         Fclose(fobj);
         return -1;
      }
      eolib = search(flib, libname, ftmp, tmpname, *modnames, eolib,
                     0, verbose);
      if (eolib < 0) return -1;
      /* write new module header */
      if (eolib) {
         strcpy(modhead.fname, *modnames);
         for (i = strlen(modhead.fname) + 1; i < 12; i++) {
            modhead.fname[i] = 0;
         }
         modhead.flags = 0666;	/* unix style rw permission, not used */
      }
      modhead.fsize = count;
      if (eFwrite(ftmp, tmpname, (long) sizeof(modhead), &modhead) !=
          (long) sizeof(modhead)) {
         return -1;
      }
      if (copymodule(fobj, *modnames, ftmp, tmpname, count)) {
         return -1;
      }
      if (verbose) printf("r %s\n", modhead.fname);
      modcount--;
      modnames++;
   }

   /*
    *	copy remainder of library by searching for a non existing
    *   module
    */

   if (search(flib, libname, ftmp, tmpname, "", eolib, 0, verbose) < 0) {
      return -1;
   }
   return 0;
}

static int insert(flib, libname, ftmp, tmpname, modnames, modcount,
                  opmod, aftbef, verbose)
WORD flib, ftmp;
int modcount, aftbef, verbose;
char *libname, *tmpname, **modnames, *opmod;
{
   WORD fobj;				/* handle for object file */
   int eolib = FALSE;			/* end-of-library flag */
   long count;				/* nr of bytes read/written */
   long getfsize();			/* get filesize from directory */
   int i;

   eolib = search(flib, libname, ftmp, tmpname, opmod, eolib, aftbef, verbose);
   if (eolib < 0) return -1;
   while (modcount > 0) {
      if((fobj = Fopen(*modnames, 0)) < 0) {
         errmsg("arxx: cannot open %s", *modnames);
         return -1;
      }
      count = getfsize(*modnames);
      /* check if really an object file */
      if (checkobj(fobj, *modnames, count)) {
         errmsg("arxx: %s not an object file", *modnames);
         Fclose(fobj);
         return -1;
      }
      /* write new module header */
      strcpy(modhead.fname, *modnames);
      for (i = strlen(modhead.fname) + 1; i < 12; i++) {
         modhead.fname[i] = 0;
      }
      modhead.fsize = count;
      modhead.flags = 0666;	/* unix style rw permission, not used */
      if (eFwrite(ftmp, tmpname, (long) sizeof(modhead), &modhead) !=
          (long) sizeof(modhead)) return -1;
      if (copymodule(fobj, *modnames, ftmp, tmpname, count)) {
         return -1;
      }
      if (verbose) printf((aftbef == AFTER ? "a %s\n" : "b %s\n"),
                          modhead.fname);
      modcount--;
      modnames++;
   }

   /*
    *	copy remainder of library by searching for a non existing
    *   module
    */

   if (search(flib, libname, ftmp, tmpname, "", eolib, 0, verbose) < 0) {
      return -1;
   }
   return 0;
}

int search(flib, libname, ftmp, tmpname, modname, eolib, aftbef, verbose)
WORD flib, ftmp;
char *libname, *tmpname, *modname;
int eolib, aftbef, verbose;
{
   long count;
   int found;

   if (eolib) return eolib;
   found = FALSE;
   while (TRUE) {   
      if ((count = eFread(flib, libname, (long) sizeof(modhead), &modhead)) !=
          (long) sizeof(modhead)) {
         if (count > 0 && modhead.fname[0] == (char)0) {/* end-of-library */
            return TRUE;
         }
         return -1;
      }
      if (strcmp(modname, modhead.fname) == 0) {	/* found module */
         found = TRUE;
         if (aftbef == NOCOPY) {
            return FALSE;
         } else if (aftbef == 0) {
            /* seek past module */
            if (eFseek(modhead.fsize, flib, libname) < 0) {
              return -1;
            }
            return FALSE;
         } else if (aftbef == BEFORE) {
            /* seek back to beginning of module header */
            if (eFseek(-((long) sizeof(modhead)), flib, libname) < 0) {
              return -1;
            }
            return FALSE;
         } 
         /* else if (aftbef == AFTER) fall through to copy module */
      }

      /*
       *  module not found, copy to temp file if NOCOPY flag not set
       */

      if (aftbef != NOCOPY) {
         if (eFwrite(ftmp, tmpname, (long) sizeof(modhead), &modhead) !=
             (long) sizeof(modhead)) {
            return -1;
         }
         if (copymodule(flib, libname, ftmp, tmpname, modhead.fsize)) {
            return -1;
         }
         if (verbose) printf("c %s\n", modhead.fname);
      } else {		/* aftbef == NOCOPY, seek past module */
         if (eFseek(modhead.fsize, flib, libname) < 0) {
            return -1;
         }
      }
      if (found) return FALSE;
   }
}

int checkobj(fobj, fname, fsize)	/* returns TRUE if fname is */
WORD fobj;				/* an object file */
char *fname;
long fsize;				/* filesize from directory */
{
   struct objfhead objhead;
   long csize;

   if (eFread(fobj, fname, (long) sizeof(objhead), &objhead) !=
       (long) sizeof(objhead)) {
      return -1;
   }
   if (objhead.objtyp != OBJTYP) return -1;

   /*  Compute expected filesize from objectfile header.
    *  Expected size = size of header +
    *                  size of text segment +
    *                  size of data segment +
    *                  size of symboltable +
    *                  size of relocation information.
    *
    *  There is one byte of relocation info for each byte in the text
    *  and data segments.
    */

   csize = (long) sizeof(objhead) +
           2 * (objhead.textsize + objhead.datasize) +
           objhead.symtsize;

   if (fsize != csize) {
      errmsg("arxx: size error on %s, expected %ld, actual %ld",
             fname, csize, fsize);
      return -1;
   }

   if (eFseek(-((long) sizeof(objhead)), fobj, fname) < 0) {
      return -1;
   }
   return 0;
}

long getfsize(fname)		/* get filesize from directory */
char *fname;
{
   struct {			/* directory structure */
      WORD junk[10];
      char attrib;
      WORD date;
      WORD time;
      long size;
      char namext[14];
   } dirinfo;
   long savdta;

   savdta = Fgetdta();
   Fsetdta(&dirinfo);
   if (Fsfirst(fname, 0) != 0L) {
      errmsg("arxx: error looking for size of %s", fname);
      return 0L;
   }
   Fsetdta(savdta);
   return dirinfo.size;
}
   
   
int copymodule(fin, inname, fout, outname, size)	/* copy size bytes  */
WORD fin, fout;						/* from fin to fout */
char *inname, *outname;
long size;
{
   register long count;
   register long n;

   for (count = size; count > 0; count -= (long)1024) {
      n = min((long)1024, count);
      if (eFread(fin, inname, n, buff) != n) {
         return -1;
      }
      if (eFwrite(fout, outname, n, buff) != n) {
         return -1;
      }
   }
   return 0;
}
