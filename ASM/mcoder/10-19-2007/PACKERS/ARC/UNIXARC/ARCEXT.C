/*  ARC - Archive utility - ARCEXT

(C) COPYRIGHT 1985 by System Enhancement Associates; ALL RIGHTS RESERVED

    By:  Thom Henderson

    Description:
         This file contains the routines used to extract files from
         an archive.

    Language:
         Computer Innovations Optimizing C86
*/
#include <stdio.h>
#include "arc.h"

#ifdef ARC
extarc(num,arg,prt)                    /* extract files from archive */
int num;                               /* number of arguments */
char *arg[];                           /* pointers to arguments */
int prt;                               /* true if printing */
#endif ARC
#ifdef XARC
extarc()                               /* extract files from archive */
#endif XARC
{
    struct heads hdr;                  /* file header */
#ifdef ARC
    int save;                          /* true to save current file */
    int did[MAXARG];                  /* true when argument was used */
    char *i, *rindex();                /* string index */
    char **name, *alloc();             /* name pointer list, allocator */
    int n;                             /* index */

    name = (char **)alloc(num*sizeof(char *));  /* get storage for name pointers */

    for(n=0; n<num; n++)               /* for each argument */
    {    did[n] = 0;                   /* reset usage flag */
         if(!(i=rindex(arg[n],'\\')))  /* find start of name */
              if(!(i=rindex(arg[n],'/')))
                   if(!(i=rindex(arg[n],':')))
                        i = arg[n]-1;
         name[n] = i+1;
    }

#endif ARC

    openarc(0);                        /* open archive for reading */

#ifdef ARC
    if(num)                            /* if files were named */
    {    while(readhdr(&hdr,arc))      /* while more files to check */
         {    save = 0;                /* reset save flag */
              for(n=0; n<num; n++)     /* for each template given */
              {    if(match(hdr.name,name[n]))
                   {    save = 1;      /* turn on save flag */
                        did[n] = 1;    /* turn on usage flag */
                        break;         /* stop looking */
                   }
              }

              if(save)                 /* extract if desired, else skip */
                   extfile(&hdr,arg[n],prt);
              else fseek(arc,hdr.size,1);
         }
    }

    else while(readhdr(&hdr,arc))      /* else extract all files */
         extfile(&hdr,"",prt);
#endif ARC
#ifdef XARC
    while(readhdr(&hdr,arc))           /* extract all files */
         extfile(&hdr);
#endif XARC

    closearc(0);                       /* close archive after reading */
#ifdef ARC

    if(note)
    {    for(n=0; n<num; n++)          /* report unused args */
         {    if(!did[n])
              {    printf("File not found: %s\n",arg[n]);
                   nerrs++;
              }
         }
    }

    free(name);
#endif ARC
}

#ifdef ARC
static extfile(hdr,path,prt)           /* extract a file */
struct heads *hdr;                     /* pointer to header data */
char *path;                            /* pointer to path name */
int prt;                               /* true if printing */
#define USE fix
#endif ARC
#ifdef XARC
static extfile(hdr)                    /* extract a file */
#define USE hdr->name
#endif XARC
{
    FILE *f, *fopen();                 /* extracted file, opener */
    char buf[STRLEN];                 /* input buffer */
#ifdef ARC
    char fix[STRLEN];                 /* fixed name buffer */
    char *i, *rindex();                /* string index */

    if(prt)                            /* printing is much easier */
    {    unpack(arc,stdout,hdr);       /* unpack file from archive */
         printf("\f");                 /* eject the form */
         return;                       /* see? I told you! */
    }

    strcpy(fix,path);                  /* note path name template */
    if(!(i=rindex(fix,'\\')))          /* find start of name */
         if(!(i=rindex(fix,'/')))
              if(!(i=rindex(fix,':')))
                   i = fix-1;
#if unix
    lower(hdr->name);
#endif
    strcpy(i+1,hdr->name);             /* replace template with name */
#endif ARC
#ifdef XARC
#if unix
    lower(hdr->name);
#endif
#endif XARC

    if(note)
         printf("Extracting file: %s\n",USE);

    if(warn)
    {    if(f=fopen(USE,"r"))        /* see if it exists */
         {    fclose(f);
              printf("WARNING: File %s already exists!",USE);
              while(1)
              {    printf("  Overwrite it (y/n)? ");
                   fgets(buf,STRLEN,stdin);
                   *buf = toupper(*buf);
                   if(*buf=='Y' || *buf=='N')
                        break;
              }
              if(*buf=='N')
              {    printf("%s not extracted.\n",USE);
                   fseek(arc,hdr->size,1);
                   return;
              }
         }
    }

    if(!(f=fopen(USE,"w")))
    {    if(warn)
         {    printf("Cannot create %s\n",USE);
              nerrs++;
         }
         fseek(arc,hdr->size,1);
         return;
    }

    /* now unpack the file */

    unpack(arc,f,hdr);                 /* unpack file from archive */
#if unix
    fclose(f);                         /* all done writing to file */
    setstamp(USE,hdr->date,hdr->time);   /* set the proper date/time stamp */
#else
    setstamp(f,hdr->date,hdr->time);   /* set the proper date/time stamp */
    fclose(f);                         /* all done writing to file */
#endif
}
