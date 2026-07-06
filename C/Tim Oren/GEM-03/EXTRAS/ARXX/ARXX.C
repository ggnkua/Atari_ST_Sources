/*
 *   arxx.c
 *
 *   library utility, replacement of ar68
 *
 *   Author:	Ton van Overbeek
 *		TPC862@ESTEC.BITNET
 *		1986-10-05
 *
 */

#include <stdio.h>
#include <osbind.h>
#include "archive.h"

main (argc, argv)
int argc;
char **argv;
{
   register char *p;		/* pointer for argument processing	*/
   char *libname;		/* library filename			*/
   char *opmod;			/* library module to insert after or	*/
				/* before with -ra or -rb option	*/
   char **modnames;		/* array of module names to insert,	*/
				/* extract, delete, ...			*/
   char *tmpname = "arxx.tmp";	/* temporary workfile			*/
   int oper;			/* selected operation			*/
   WORD flib;			/* handle for library			*/
   WORD ftmp;			/* handle for workfile			*/
   WORD ibuf[2];		/* buffer for creating empty library	*/
   int verbose;			/* TRUE if -v option specified		*/
   int aftbef;			/* after/before flag for -ra/-rb option	*/
   int retval;			/* return value from action routines	*/

   argc--; argv++;
   oper = 0;
   aftbef = 0;
   while ((argc > 0) && (**argv == '-'))
   {
      argc--;
      p = *argv++;

      while (*++p != '\0')
      {
         switch(*p)
         {
         case 'T':	/* list library */
         case 't':
            oper |= LIST;
            break;

         case 'R':	/* replace/insert modules */
         case 'r':
            oper |= REPLACE;
            break;

         case 'D':	/* delete modules */
         case 'd':
            oper |= DELETE;
            break;

         case 'X':	/* extract modules */
         case 'x':
            oper |= EXTRACT;
            break;

         case 'W':	/* write module to stdout */
         case 'w':
            oper |= WRITE;
            break;

         case 'V':	/* verbose flag */
         case 'v':
            verbose = TRUE;
            break;

         case 'A':	/* specify after opmodule */
         case 'a':
            aftbef |= AFTER;
            if (*(p+1) != '\0') usage();/* must be followed by module name */
            if (--argc == 0)  usage();	/* and library name + ....         */
            opmod = *argv;
            argv++;
            break;

         case 'B':	/* specify before opmodule */
         case 'b':
            aftbef |= BEFORE;
            if (*(p+1) != '\0') usage();/* must be followed by module name */
            if (--argc == 0)  usage();	/* and library name + ....         */
            opmod = *argv;
            argv++;
            break;

         }
      }
   }

   if (aftbef == (AFTER|BEFORE)) usage();
   if (aftbef && (oper != REPLACE)) usage();
   if (argc == 0) usage();

   libname = *argv;
   argc--; argv++;

   if (argc == 0) {
      if (oper != LIST) usage();
   }

   modnames = argv;

   /*
    *  Open library for reading,
    *  If error and operation is replace create an empty library
    *  and open it for reading
    */

   if ((flib = Fopen(libname, 0)) < 0) {
      if (oper != REPLACE) {
         errmsg("arxx: cannot open library: %s", libname);
         exit(1);
      } else {
         if ((flib = Fcreate(libname, 0)) < 0) {
            errmsg("arxx: cannot create library: %s", libname);
            exit(1);
         }
         ibuf[0] = ARCHTYP; ibuf[1] = 0;
         if (Fwrite(flib, 4L, ibuf) < 0) {
            errmsg("arxx: write error on %s", libname);
            exit(1);
         }
         Fclose(flib);
         flib = Fopen(libname, 0);
      }
   }

   if ((oper == REPLACE) || (oper == DELETE)) {		/* open temp file */
      if ((ftmp = Fcreate(tmpname, 0)) < 0) {
         errmsg("arxx: cannot create %s", tmpname);
         exit(1);
      }
   }

   switch (oper)

   {
   case LIST:
      retval = listlib(flib, libname, verbose);
      break;

   case REPLACE:
      retval = replmod(flib, libname, ftmp, tmpname, modnames, argc,
                       aftbef, opmod, verbose); 
      break;

   case DELETE:
      retval = delmod(flib, libname, ftmp, tmpname, modnames, argc,
                      verbose);
      break;

   case EXTRACT:
      retval = extrmod(flib, libname, modnames, argc, verbose);
      break;

   case WRITE:
      retval = wrtmod(flib, libname, modnames, argc, verbose);
      break;

   default:
      Fclose(flib);
      usage();
      break;
   }


   if (retval) {
      Fclose(flib);
      Fdelete(tmpname);
   }
   exit(retval);
}

usage()
{
   errmsg("usage: arxx -trdxw[v] [-ab opmod] lib mod1 mod2 .... [> file]");
   exit(1);
}
