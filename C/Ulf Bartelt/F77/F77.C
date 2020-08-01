/* Compiler-Driver for BC-Fortran-77
 *
 * (C)1992, Ulf Bartelt
 *
 * History (youngest first):
 *
 * 920122 - started in Sozobon-C 2.0
 * 920123 - Option -n ans some bugfixes
 *        - Dgetdrv/Dsetdrv used additionally to chdir()...
 */


#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <osbind.h>


extern char *getenv();


void usage()
{  fputs("BC-FORTRAN-77 Driver V.0.12, (C)1992 by Ulf Bartelt\n",stderr);
   fputs("    -c   compile only\n",stderr);
   fputs("    -f   no casefolding, distinguish upper and lowercase\n",stderr);
   fputs("    -g   compile with debug code\n",stderr);
   fputs("    -n   no actions, only show commands...\n",stderr);
   fputs("    -O   optimize (currently only optimizes linking)\n",stderr);
   fputs("    -r   don't link with MATHLIB.B\n",stderr);
   fputs("    -sn  set stack size to n kBytes\n",stderr);
   fputs("    -v   verbose compile and link\n",stderr);
   fputs("    -vc  verbose compile\n",stderr);
   fputs("    -vl  verbose link\n",stderr);
   exit(0);
}


char filetype( file )
   char *file;
{  register char *cp=file, *lb, *lp;
   while( *cp )
      if(      *cp == '\\' ) lb=cp++;
      else if( *cp == '.' ) lp=cp++;
      else cp++;
   if( lb < lp && lp[2] == 0 )
      switch( toupper(lp[1]) )
      {  case 'F' : return 'F';
         case 'B' : return 'B';
      }
   return 0;
}


char *f_2_b( file )           /* a legal source file name is assumend !!! */
   char *file;                /* i.e.:    <drive:\path\name>.f            */
{  register char *cp = file;
   register char *lp; /* last (p)oint */
   while( *cp ) if( *cp == '.'  ) lp=cp++; else cp++;
   lp[1] = 'b';
   return file;
}


int main( argc, argv )
   int argc;
   char *argv[];
{
   int retcode = 0;

   char bcf_opts[40];
   char bcl_opts[40];
   char bcf_files[129];
   char bcl_files[129];
   char bcf_exec[129];
   char bcl_exec[129];

   char stacksize[21];

   struct {
      unsigned c_casefold:1;  /* -f        ==> -U for compiler  */
      unsigned c_debug:1;     /* -g        ==> -D for compiler  */
      unsigned c_verbose:1;   /* -v or -vc ==> -L for compiler  */
      unsigned l_mathlib:1;   /* -r                             */
      unsigned l_optimize:1;  /* -O        ==> -O for linker    */
      unsigned l_stacksize:1; /* -s<n>     ==> -S<n> for linker */
      unsigned l_verbose:1;   /* -v or -vl ==> -L for linker    */
      unsigned x_nolink:1;    /* -c                             */
      unsigned x_donothing:1; /* -n                             */
      unsigned got_f_files:1; /* *.f files in arglist           */
      unsigned got_b_files:1; /* *.b files in arglist           */
   } flags;

   flags.c_casefold  = 1;
   flags.c_debug     = 0;
   flags.c_verbose   = 0;
   flags.got_b_files = 0;
   flags.got_f_files = 0;
   flags.l_mathlib   = 1;
   flags.l_optimize  = 0;
   flags.l_stacksize = 0;
   flags.l_verbose   = 0;
   flags.x_nolink    = 0;
   flags.x_donothing = 0;

   strcpy(bcf_files,"");
   strcpy(bcl_files,"");

   {  int i=1;
      char *file[129];

      while( i<argc )
      {  if( argv[i][0]=='-' )                         /* collect options */
         {  switch( argv[i][1] )
            {
               case '?': /* help */
               case 'h': usage();
                         /* "break"ed by exit in usage() */
               case 'c': flags.x_nolink = 1;
                         break;
               case 'f': flags.c_casefold = 0;
                         break;
               case 'g': /* debug */
                         flags.c_debug = 1;
                         break;
               case 'n': flags.x_donothing = 1;
                         break;
               case 'O': /* optimizing link */
                         flags.l_optimize = 1;
                         break;
               case 'r': flags.l_mathlib = 0;
                         break;
               case 's': flags.l_stacksize = 1;
                         strcpy(stacksize,argv[i]);
                         strcat(stacksize," ");
                         stacksize[1]='S'; /* BCL wants "S" */
                         break;
               case 'v': /* verbose */
                         switch( argv[i][2] )
                         {  case 000: flags.l_verbose = 1;
                            case 'c': flags.c_verbose = 1; break;
                            case 'l': flags.l_verbose = 1; break;
                            default : fprintf(stderr,"unknown option \"%s\"...\n",argv[i]);
                                      exit(1);
                         }
                         break;
               default : /* option error */
                         fprintf("unknown option \"%s\"...\n",argv[i]);
                         exit(1);
            }
         }
         else /*if( argv[i][0]!='-' )*/                  /* collect files */
         {  if( fullpath(file,argv[i]) )
            {
               switch( filetype(file) )
               {  case 'F': flags.got_f_files = 1;
                            strcat(bcf_files,file);
                            strcat(bcf_files," ");
                            strcat(bcl_files,f_2_b(file));
                            strcat(bcl_files," ");
                            break;
                  case 'B': flags.got_b_files = 1;
                            strcat(bcl_files,file);
                            strcat(bcl_files," ");
                            break;
                  default : fprintf(stderr,"Illegal suffix: %s\n",file);
                            exit(1);
               }
            }
         }
         ++i;
      }
   }

   if( flags.got_f_files && flags.got_b_files )
   {  fputs("can't mix operations on *.f and *.b...\n",stderr);
      exit(1);
   }

   strcpy(bcf_opts,"");
   strcpy(bcl_opts,"");
   if( flags.c_debug     ) strcat(bcf_opts,"-D ");
   if( flags.c_verbose   ) strcat(bcf_opts,"-P ");
   if( flags.c_casefold  ) strcat(bcf_opts,"-U ");

   if( flags.l_optimize  ) strcat(bcl_opts,"-O ");
   if( flags.l_verbose   ) strcat(bcl_opts,"-P ");
   if( flags.l_stacksize ) strcat(bcl_opts,stacksize);

   if( flags.l_mathlib  ) strcat(bcl_files,"mathlib.b");

   if( flags.got_f_files )
   {  char *execpath, *cp, command[129];
      execpath = getenv("BCF_EXEC"); /* if NULL, pfindfile uses $PATH */
      cp = pfindfile(execpath,"BCF.TTP");
      if( !cp ) { fputs("compiler not found.\n",stderr); exit(1); }
      else strcpy(bcf_exec,cp);

      sprintf(command,"%s %s%s",bcf_exec,bcf_opts,bcf_files);
      if( flags.c_verbose || flags.x_donothing ) puts(command);
      if( !flags.x_donothing )
      {  retcode = system(command);
         if( retcode ) { fputs("compiler failed !\n",stderr); exit(retcode); }
         /* Das funktioniert leider nicht...
          * Der Code bleibt aber trotzdem drin !
          */
      }
   }

   if( (flags.got_f_files && !flags.x_nolink) || flags.got_b_files )
   {  char *execpath, *libpath, *cp, drive = Dgetdrv(), libdrv;
      char cwd[129],command[129];

      execpath = getenv("BCF_EXEC"); /* if NULL, pfindfile uses $PATH */
      cp = pfindfile(execpath,"BCL.TTP");
      if( !cp ) { fputs("linker not found.\n",stderr); exit(1); }
      else      strcpy(bcl_exec,cp);

      if( !getcwd(cwd,128) ) { fputs("can't get cwd\n",stderr); exit(1); }

      libpath = getenv("BCF_LIB");
      if( libpath )
      {  if( flags.l_verbose || flags.x_donothing ) printf("cd %s\n",libpath);
         libdrv = toupper(*libpath)-'A';
         if( !flags.x_donothing
            && (Dsetdrv(libdrv) & (1u<<libdrv))
            && chdir(libpath) 
           ) { fputs("can't set path to libs.\n",stderr); exit(1); }
      }

      sprintf(command,"%s %s%s",bcl_exec,bcl_opts,bcl_files);
      if( flags.l_verbose || flags.x_donothing ) puts(command);
      if( !flags.x_donothing ) retcode = system(command);
      
      if( flags.l_verbose || flags.x_donothing ) printf("cd %s\n",cwd);
      if( !flags.x_donothing
         && (Dsetdrv(drive) & (1<<drive))
         && chdir(cwd) ) { fputs("can't reset path to working directory.\n",stderr); exit(1); }

      if( !flags.x_donothing && retcode ) { fputs("linker failed !\n",stderr); exit(retcode); }
      /* Das funktioniert leider nicht...
       * Der Code bleibt aber trotzdem drin !
       */
   }

   return 0;
}

