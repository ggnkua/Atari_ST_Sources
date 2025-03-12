#define MAIN
/*  MARC - Archive merge utility

(C) COPYRIGHT 1985 by System Enhancement Associates; ALL RIGHTS RESERVED

    By:  Thom Henderson

    Description:
         This program is used to "merge" archives.  That is, to move
         files from one archive to another with no data conversion.
         Please refer to the ARC source for a description of archives
         and archive formats.

    Instructions:
         Run this program with no arguments for complete instructions.

    Language:
         Computer Innovations Optimizing C86
*/
#include <stdio.h>
#include "arc.h"

FILE *src;                             /* source archive */

char srcname[STRLEN];                 /* source archive name */

main(nargs,arg)                        /* system entry point */
int nargs;                             /* number of arguments */
char *arg[];                           /* pointers to arguments */
{
    char *makefnam();                  /* filename fixup routine */
    static char *allf[] = {"*.*"};     /* phony arg to merge all files */

    if(nargs<3)
    {    printf("MARC - Archive merger, %s\n",VERSION);
         printf("(C) COPYRIGHT 1985 by System Enhancement Associates;");
         printf(" ALL RIGHTS RESERVED\n\n");
#if 0
         printf("Please refer all inquiries to:\n\n");
         printf("       System Enhancement Associates\n");
         printf("       21 New Street, Wayne NJ 07470\n\n");
         printf("You may copy and distribute this program freely,");
         printf(" provided that:\n");
         printf("    1)   No fee is charged for such copying and");
         printf(" distribution, and\n");
         printf("    2)   It is distributed ONLY in its original,");
         printf(" unmodified state.\n\n");
         printf("If you like this program, and find it of use, then your");
         printf(" contribution will\n");
         printf("be appreciated.  You may not use this product in a");
         printf(" commercial environment\n");
         printf("or a governmental organization without paying a license");
         printf(" fee of $35.  Site\n");
         printf("licenses and commercial distribution licenses are");
         printf(" available.  A program\n");
         printf("disk and printed documentation are available for $50.\n");
         printf("\nIf you fail to abide by the terms of this license, ");
         printf(" then your conscience\n");
         printf("will haunt you for the rest of your life.\n\n");
#endif 0
         printf("Usage: MARC <tgtarc> <srcarc> [<filename> . . .]\n");
         printf("Where: <tgtarc> is the archive to add files to,\n");
         printf("       <srcarc> is the archive to get files from, and\n");
         printf("       <filename> is zero or more file names to get.\n");
         return 1;
    }

    makefnam(arg[1],".ARC",arcname);   /* fix up archive names */
    makefnam(arg[2],".ARC",srcname);
#if unix
    makefnam(arg[1],".$$$",newname);
#else
    makefnam(arg[1],".$$$$",newname);
    upper(arcname); upper(srcname); upper(newname);
#endif

    arc = fopen(arcname,"r");         /* open the archives */
    if(!(src=fopen(srcname,"r")))
         abort("Cannot read source archive %s",srcname);
    if(!(new=fopen(newname,"w")))
         abort("Cannot create new archive %s",newname);

    if(!arc)
         printf("Creating new archive %s\n",arcname);

    if(nargs==3)
         merge(1,allf);                /* merge all files */
    else merge(nargs-3,&arg[3]);       /* merge selected files */

    if(arc) fclose(arc);               /* close the archives */
    fclose(src);

#if unix
    fclose(new);
    setstamp(newname,arcdate,arctime);     /* new arc matches newest file */
#else
    setstamp(new,arcdate,arctime);     /* new arc matches newest file */
    fclose(new);
#endif

    if(arc)                            /* make the switch */
         if(unlink(arcname))
              abort("Unable to delete old copy of %s",arcname);
    if(rename(newname,arcname))
         abort("Unable to rename %s to %s",newname,arcname);

    return nerrs;
}

merge(nargs,arg)                       /* merge two archives */
int nargs;                             /* number of filename templates */
char *arg[];                           /* pointers to names */
{
    struct heads srch;                 /* source archive header */
    struct heads arch;                 /* target archive header */
    int gotsrc, gotarc;                /* archive entry versions (0=end) */
    int copy;                          /* true to copy file from source */
    int n;                             /* index */

    gotsrc = gethdr(src,&srch);        /* get first source file */
    gotarc = gethdr(arc,&arch);        /* get first target file */

    while(gotsrc || gotarc)            /* while more to merge */
    {    if(strcmp(srch.name,arch.name)>0)
         {    copyfile(arc,&arch,gotarc);
              gotarc = gethdr(arc,&arch);
         }

         else if(strcmp(srch.name,arch.name)<0)
         {    copy = 0;
              for(n=0; n<nargs; n++)
              {    if(match(srch.name,arg[n]))
                   {    copy = 1;
                        break;
                   }
              }
              if(copy)                 /* select source or target */
              {    printf("Adding file:   %s\n",srch.name);
                   copyfile(src,&srch,gotsrc);
              }
              else fseek(src,srch.size,1);
              gotsrc = gethdr(src,&srch);
         }

         else                          /* duplicate names */
         {    copy = 0;
              {    if((srch.date>arch.date)
                   || (srch.date==arch.date && srch.time>arch.time))
                   {    for(n=0; n<nargs; n++)
                        {    if(match(srch.name,arg[n]))
                             {    copy = 1;
                                  break;
                             }
                        }
                   }
              }
              if(copy)                 /* select source or target */
              {    printf("Updating file: %s\n",srch.name);
                   copyfile(src,&srch,gotsrc);
                   gotsrc = gethdr(src,&srch);
                   if(gotarc)
                   {    fseek(arc,arch.size,1);
                        gotarc = gethdr(arc,&arch);
                   }
              }
              else
              {    copyfile(arc,&arch,gotarc);
                   gotarc = gethdr(arc,&arch);
                   if(gotsrc)
                   {    fseek(src,srch.size,1);
                        gotsrc = gethdr(src,&srch);
                   }
              }
         }
    }

    hdrver = 0;                        /* end of archive marker */
    writehdr(&arch,new);               /* mark the end of the archive */
}

int gethdr(f,hdr)                      /* special read header for merge */
FILE *f;                               /* file to read from */
struct heads *hdr;                     /* storage for header */
{
    char *i = hdr->name;               /* string index */
    int n;                             /* index */

    for(n=0; n<FNLEN; n++)            /* fill name field */
         *i++ = 0176;                  /* impossible high value */
    *--i = '\0';                       /* properly end the name */

    hdrver = 0;                        /* reset header version */
    if(readhdr(hdr,f))                 /* use normal reading logic */
         return hdrver;                /* return the version */
    else return 0;                     /* or fake end of archive */
}

copyfile(f,hdr,ver)                    /* copy a file from an archive */
FILE *f;                               /* archive to copy from */
struct heads *hdr;                     /* header data for file */
int ver;                               /* header version */
{
    hdrver = ver;                      /* set header version */
    writehdr(hdr,new);                 /* write out the header */
    filecopy(f,new,hdr->size);         /* copy over the data */
}
