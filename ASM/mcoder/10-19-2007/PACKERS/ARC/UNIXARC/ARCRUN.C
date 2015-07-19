/*  ARC - Archive utility - ARCRUN

(C) COPYRIGHT 1985 by System Enhancement Associates; ALL RIGHTS RESERVED

    By:  Thom Henderson

    Description:
         This file contains the routines used to "run" a file
         which is stored in an archive.  At present, all we really do
         is (a) extract a temporary file, (b) give its name as a system
         command, and then (c) delete the file.

    Language:
         Computer Innovations Optimizing C86
*/
#include <stdio.h>
#include "arc.h"

#if unix
runarc(num,arg)                        /* run file from archive */
int num;                               /* number of arguments */
char *arg[];                           /* pointers to arguments */
{
	fprintf(stderr, "runarc(): not supported under unix\n");
}
#else
runarc(num,arg)                        /* run file from archive */
int num;                               /* number of arguments */
char *arg[];                           /* pointers to arguments */
{
    struct heads hdr;                  /* file header */
    int run;                           /* true to run current file */
    int did[MAXARG];                  /* true when argument was used */
    int n;                             /* index */
    char *makefnam();                  /* filename fixer */
    char buf[STRLEN];                 /* filename buffer */
    FILE *fopen();                     /* file opener */

    for(n=0; n<num; n++)               /* for each argument */
         did[n] = 0;                   /* reset usage flag */
    rempath(num,arg);                  /* strip off paths */

    openarc(0);                        /* open archive for reading */

    if(num)                            /* if files were named */
    {    while(readhdr(&hdr,arc))      /* while more files to check */
         {    run = 0;                 /* reset run flag */
              for(n=0; n<num; n++)     /* for each template given */
              {    if(match(hdr.name,makefnam(arg[n],".*",buf)))
                   {    run = 1;       /* turn on run flag */
                        did[n] = 1;    /* turn on usage flag */
                        break;         /* stop looking */
                   }
              }

              if(run)                  /* if running this one */
                   runfile(&hdr);      /* then do it */
              else                     /* else just skip it */
                   fseek(arc,hdr.size,1);
         }
    }

    else while(readhdr(&hdr,arc))      /* else run all files */
         runfile(&hdr);

    closearc(0);                       /* close archive after changes */

    if(note)
    {    for(n=0; n<num; n++)          /* report unused args */
         {    if(!did[n])
              {    printf("File not found: %s\n",arg[n]);
                   nerrs++;
              }
         }
    }
}

static runfile(hdr)                    /* run a file */
struct heads *hdr;                     /* pointer to header data */
{
    FILE *tmp, *fopen();               /* temporary file */
    char buf[STRLEN], *makefnam();    /* temp file name, fixer */
    char sys[STRLEN];                 /* invocation command buffer */
    char *dir, *gcdir();               /* directory stuff */

    makefnam("$ARCTEMP",hdr->name,buf);

    if(!strcmp(buf,"$ARCTEMP.BAS"))
         strcpy(sys,"BASICA $ARCTEMP");

    else if(!strcmp(buf,"$ARCTEMP.BAT")
         || !strcmp(buf,"$ARCTEMP.COM")
         || !strcmp(buf,"$ARCTEMP.EXE"))
         strcpy(sys,"$ARCTEMP");

    else
    {    if(warn)
         {    printf("File %s is not a .BAS, .BAT, .COM, or .EXE\n",
                   hdr->name);
              nerrs++;
         }
         fseek(arc,hdr->size,1);  /* skip this file */
         return;
    }

    if(warn)
         if(tmp=fopen(buf,"r"))
              abort("Temporary file %s already exists",buf);
    if(!(tmp=fopen(makefnam("$ARCTEMP",hdr->name,buf),"w+")))
         abort("Unable to create temporary file %s",buf);

    if(note)
         printf("Invoking file: %s\n",hdr->name);

    dir = gcdir("");                   /* see where we are */
    unpack(arc,tmp,hdr);               /* unpack the entry */
    fclose(tmp);                       /* release the file */
    system(sys);                       /* try to invoke it */
    chdir(dir); free(dir);             /* return to whence we started */
    if(unlink(buf) && warn)
    {    printf("Cannot unsave temporary file %s\n",buf);
         nerrs++;
    }
}
#endif
