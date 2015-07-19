/*  ARC - Archive utility - ARCIO

(C) COPYRIGHT 1985 by System Enhancement Associates; ALL RIGHTS RESERVED

    By:  Thom Henderson

    Description:
         This file contains the file I/O routines used to manipulate
         an archive.

    Language:
         Computer Innovations Optimizing C86
*/
#include <stdio.h>
#include "arc.h"
#if unix
extern urdhdr();
extern urdohdr();
extern uwrhdr();
#endif

int readhdr(hdr,f)                     /* read a header from an archive */
struct heads *hdr;                     /* storage for header */
FILE *f;                               /* archive to read header from */
{
    char name[FNLEN];                 /* filename buffer */
    int try = 0;                       /* retry counter */
    static int first = 1;              /* true only on first read */

    if(!f)                             /* if archive didn't open */
         return 0;                     /* then pretend it's the end */
    if(feof(f))                        /* if no more data */
         return 0;                     /* then signal end of archive */

    if(fgetc(f)!=ARCMARK)             /* check archive validity */
    {    if(warn)
         {    printf("An entry in %s has a bad header.",arcname);
              nerrs++;
         }

         while(!feof(f))
         {    try++;
              if(fgetc(f)==ARCMARK)
              {    ungetc(hdrver=fgetc(f),f);
                   if(hdrver>=0 && hdrver<=ARCVER)
                        break;
              }
         }

         if(feof(f) && first)
              abort("%s is not an archive",arcname);

         if(warn)
              printf("  %d bytes skipped.\n",try);

         if(feof(f))
              return 0;
    }

    hdrver = fgetc(f);                 /* get header version */
    if(hdrver<0)
         abort("Invalid header in archive %s",arcname);
    if(hdrver==0)
         return 0;                     /* note our end of archive marker */
    if(hdrver>ARCVER)
    {    fread(name,sizeof(char),FNLEN,f);
         printf("I don't know how to handle file %s in archive %s\n",
              name,arcname);
         printf("I think you need a newer version of ARC.\n");
         exit(1);
    }

    /* amount to read depends on header type */

#if unix
    if(hdrver==1)                      /* old style is shorter */
    {
	 urdohdr(hdr,f);
         hdrver = 2;                   /* convert header to new format */
         hdr->length = hdr->size;      /* size is same when not packed */
    }
    else urdhdr(hdr,f);
#else
    if(hdrver==1)                      /* old style is shorter */
    {    fread(hdr,sizeof(struct heads)-sizeof(long int),1,f);
         hdrver = 2;                   /* convert header to new format */
         hdr->length = hdr->size;      /* size is same when not packed */
    }
    else fread(hdr,sizeof(struct heads),1,f);
#endif

    first = 0; return 1;               /* we read something */
}

writehdr(hdr,f)                        /* write a header to an archive */
struct heads *hdr;                     /* header to write */
FILE *f;                               /* archive to write to */
{
    fputc(ARCMARK,f);                 /* write out the mark of ARC */
    fputc(hdrver,f);                   /* write out the header version */
    if(!hdrver)                        /* if that's the end */
         return;                       /* then write no more */
#if unix
    uwrhdr(hdr,f);
#else
    fwrite(hdr,sizeof(struct heads),1,f);
#endif

    /* note the newest file for updating the archive timestamp */

    if(hdr->date>arcdate
    ||(hdr->date==arcdate && hdr->time>arctime))
    {    arcdate = hdr->date;
         arctime = hdr->time;
    }
}

filecopy(f,t,size)                     /* bulk file copier */
FILE *f, *t;                           /* from, to */
long size;                             /* number of bytes */
{
    int len;                           /* length of a given copy */

    while(size--)                      /* while more bytes to move */
         putc_tst(fgetc(f),t);
}

putc_tst(c,t)                          /* put a character, with tests */
char c;                                /* character to output */
FILE *t;                               /* file to write to */
{
    if(t)
         if(fputc(c,t)==EOF)
              abort("Write fail (disk full?)");
}
