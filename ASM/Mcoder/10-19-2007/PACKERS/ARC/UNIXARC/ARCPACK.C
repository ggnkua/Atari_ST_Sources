/*  ARC - Archive utility - ARCPACK

(C) COPYRIGHT 1985 by System Enhancement Associates; ALL RIGHTS RESERVED

    By:  Thom Henderson

    Description:
         This file contains the routines used to compress a file
         when placing it in an archive.

    Language:
         Computer Innovations Optimizing C86
*/
#include <stdio.h>
#include "arc.h"

/* stuff for non-repeat packing */

#define DLE 0x90                       /* repeat sequence marker */

static unsigned char state;            /* current packing state */

/* non-repeat packing states */

#define NOHIST  0                      /* don't consider previous input*/
#define SENTCHAR 1                     /* lastchar set, no lookahead yet */
#define SENDNEWC 2                     /* run over, send new char next */
#define SENDCNT 3                      /* newchar set, send count next */

/* packing results */

static long stdlen;                    /* length for standard packing */
static int crcval;                     /* CRC check value */

pack(f,t,hdr)                          /* pack file into an archive */
FILE *f, *t;                           /* source, destination */
struct heads *hdr;                     /* pointer to header data */
{
    int c;                             /* one character of stream */
    long ncrlen;                       /* length after packing */
    long huflen;                       /* length after squeezing */
    long lzwlen;                       /* length after crunching */
    long pred_sq(), file_sq();         /* stuff for squeezing */
    long pred_cm();                    /* dynamic crunching cleanup */
    char tnam[STRLEN];                /* temporary name buffer */
    char *makefnam();                  /* filename fixer upper */
    FILE *crn = NULL;                  /* temporary crunch file */
    FILE *fopen();

    /* first pass - see which method is best */

    if(!nocomp)                        /* if storage kludge not active */
    {    if(note)
              printf(" analyzing, ");

         if(arctemp)                   /* use temp area if specified */
              sprintf(tnam,"%s/$ARCTEMP.CRN",arctemp);
         else makefnam("$ARCTEMP.CRN",arcname,tnam);
         crn = fopen(tnam,"w+");

         state = NOHIST;               /* initialize ncr packing */
         stdlen =  ncrlen = 0;         /* reset size counters */
         crcval = 0;                   /* initialize CRC check value */
         setcode();                    /* initialize encryption */

         init_cm(f,crn);               /* initialize for crunching */
         init_sq();                    /* initialize for squeeze scan */

         while((c=getc_ncr(f))!=EOF)   /* for each byte of file */
         {    ncrlen++;                /* one more packed byte */
              scan_sq(c);              /* see what squeezing can do */
              putc_cm(c,crn);          /* see what crunching can do */
         }
         huflen = pred_sq();           /* finish up after squeezing */
         lzwlen = pred_cm(crn);        /* finish up after crunching */
    }
    else                               /* else kludge the method */
    {    stdlen = 0;                   /* make standard look best */
         ncrlen = huflen = lzwlen = 1;
    }

    /* standard set-ups common to all methods */

    fseek(f,0L,0);                     /* rewind input */
    hdr->crc = crcval;                 /* note CRC check value */
    hdr->length = stdlen;              /* set actual file length */
    state = NOHIST;                    /* reinitialize ncr packing */
    setcode();                         /* reinitialize encryption */

    /* choose and use the shortest method */

    if(stdlen<=ncrlen && stdlen<=huflen && stdlen<=lzwlen)
    {    if(kludge)                    /*DEBUG*/
              printf("(%ld) ",lzwlen-stdlen);
         if(note)
              printf("storing, ");     /* store without compression */
         hdrver = 2;                   /* note packing method */
         stdlen = crcval = 0;          /* recalc these for kludge */
         while((c=getch(f))!=EOF)      /* store it straight */
              putc_pak(c,t);
         hdr->crc = crcval;
         hdr->length = hdr->size = stdlen;
    }

    else if(ncrlen<huflen && ncrlen<lzwlen)
    {    if(kludge)                    /*DEBUG*/
              printf("(%ld) ",lzwlen-ncrlen);
         if(note)
              printf("packing, ");     /* pack with repeat suppression */
         hdrver = 3;                   /* note packing method */
         hdr->size = ncrlen;           /* set data length */
         while((c=getc_ncr(f))!=EOF)
              putc_pak(c,t);
    }

    else if(huflen<lzwlen)
    {    if(kludge)                    /*DEBUG*/
              printf("(%ld) ",lzwlen-huflen);
         if(note)
              printf("squeezing, ");
         hdrver = 4;                   /* note packing method */
         hdr->size = file_sq(f,t);     /* note final size */
    }

    else
    {    if(kludge)                    /*DEBUG*/
              printf("(%ld) ",huflen-lzwlen);
         if(note)
              printf("crunching, ");
         hdrver = 8;
         hdr->size = lzwlen;           /* size should not change */
         if(crn)                       /* if temp was created */
         {    fseek(crn,0L,0);         /* then copy over crunched temp */
              while((c=fgetc(crn))!=EOF)
                   putc_tst(c,t);
         }
         else                          /* else re-crunch */
         {    init_cm(f,t);
              while((c=getc_ncr(f))!=EOF)
                   putc_cm(c,t);
              pred_cm(t);              /* finish up after crunching */
         }
    }

    /* standard cleanups common to all methods */

    if(crn)                            /* get rid of crunch temporary */
    {    fclose(crn);
         if(unlink(tnam) && warn)
         {    printf("Cannot delete temporary file %s\n",tnam);
              nerrs++;
         }
    }
    if(note)
         printf("done.\n");
}

/*  Non-repeat compression - text is passed through normally, except that
    a run of more than two is encoded as:

         <char> <DLE> <count>

    Special case: a count of zero indicates that the DLE is really a DLE,
    not a repeat marker.
*/

int getc_ncr(f)                        /* get bytes with collapsed runs */
FILE *f;                               /* file to get from */
{
    static int lastc;                  /* value returned on last call */
    static int repcnt;                 /* repetition counter */
    static int c;                      /* latest value seen */

    switch(state)                      /* depends on our state */
    {
    case NOHIST:                       /* no relevant history */
         state = SENTCHAR;
         return lastc = getch(f);      /* remember the value next time */

    case SENTCHAR:                     /* char was sent. look ahead */
         switch(lastc)                 /* action depends on char */
         {
         case DLE:                     /* if we sent a real DLE */
              state = NOHIST;          /* then start over again */
              return 0;                /* but note that the DLE was real */

         case EOF:                     /* EOF is always a special case */
              return EOF;

         default:                      /* else test for a repeat */
              for(repcnt=1; (c=getch(f))==lastc && repcnt<255; repcnt++)
                   ;                   /* find end of run */

              switch(repcnt)           /* action depends on run size */
              {
              case 1:                  /* not a repeat */
                   return lastc = c;   /* but remember value next time */

              case 2:                  /* a repeat, but too short */
                   state = SENDNEWC;   /* send the second one next time */
                   return lastc;

              default:                 /* a run - compress it */
                   state = SENDCNT;    /* send repeat count next time */
                   return DLE;         /* send repeat marker this time */
              }
         }

    case SENDNEWC:                     /* send second char of short run */
         state = SENTCHAR;
         return lastc = c;

    case SENDCNT:                      /* sent DLE, now send count */
         state = SENDNEWC;
         return repcnt;

    default:
         abort("Bug - bad ncr state\n");
    }
}

static int getch(f)                    /* special get char for packing */
FILE *f;                               /* file to get from */
{
    int c;                             /* a char from the file */

    if((c=fgetc(f))!=EOF)              /* if not the end of file */
    {    crcval = addcrc(crcval,c);    /* then update CRC check value */
         stdlen++;                     /* and bump length counter */
    }

    return c;
}

putc_pak(c,f)                          /* put a packed byte into archive */
char c;                                /* byte to put */
FILE *f;                               /* archive to put it in */
{
    putc_tst(code(c),f);               /* put encoded byte, with checks */
}
