#define MAIN
/*  XARC - Archive extraction utility

(C) COPYRIGHT 1985 by System Enhancement Associates; ALL RIGHTS RESERVED

    By:  Thom Henderson

    Description:
         This program is used to extract files from archives which were
         created using the ARC general archive maintenance program.
         Please refer to the ARC source for a description of archives
         and archive formats.

    Instructions:
         Run this program with no arguments for complete instructions.

    Programming notes:
         This is essentially a stripped down version of ARC, including only
         those routines required to extract files.

    Language:
         Computer Innovations Optimizing C86
*/
#include <stdio.h>
#include "arc.h"

main(num,arg)                          /* system entry point */
int num;                               /* number of arguments */
char *arg[];                           /* pointers to arguments */
{
    char *makefnam();                  /* filename fixup routine */
    char buf[STRLEN];                 /* fixed filename storage */
    char *d, *dir();                   /* file directory stuff */
    int nomatch;                       /* true when no matching archive */
    int n;                             /* argument index */

    if(num<2)
    {    printf("XARC - Archive extractor, %s\n",VERSION);
         printf("(C) COPYRIGHT 1985 by System Enhancement Associates;");
         printf(" ALL RIGHTS RESERVED\n\n");
#if 0
         printf("Please refer all inquiries to:\n\n");
         printf("  System Enhancement Associates\n");
         printf("  21 New Street, Wayne NJ 07470\n\n");
         printf("You may copy and distribute this program freely,");
         printf(" provided that:\n");
         printf("    1)   No fee is charged for such copying and");
         printf(" distribution, and\n");
         printf("    2)   It is distributed ONLY in its original,");
         printf(" unmodified state.\n\n");
         printf("If you like this program, and find it of use, then your");
         printf(" contribution will\n");
         printf("be appreciated.  If you are using this product in a");
         printf(" commercial environment,\n");
         printf("then the contribution is not voluntary.\n\n");
         printf("If you fail to abide by the terms of this license, then");
         printf(" your conscience\n");
         printf("will haunt you for the rest of your life.\n\n");
#endif
         printf("Usage: XARC <arcname> [<arcname>. . .]\n\n");
         printf("Where <arcname> is the name of an archive.");
         printf("  If no filename extension is\n");
         printf("supplied, then .ARC is assumed.\n");
         return 1;
    }

    for(n=1; n<num; n++)               /* for each argument */
    {    makefnam(arg[n],".ARC",buf);
         nomatch = 1;
         for(d=dir(buf,0); *d; d=dir(NULL,0))
         {    makefnam(d,buf,arcname);
              printf("Archive: %s\n",arcname);
              extarc();           /* extract all files */
              free(d);
              nomatch = 0;
         }
         if(nomatch)
              printf("No such archive: %s\n",buf);
    }

    return nerrs;
}
