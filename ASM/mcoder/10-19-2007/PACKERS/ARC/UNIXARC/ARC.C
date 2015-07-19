#define MAIN
/*  ARC - Archive utility

(C) COPYRIGHT 1985,86 by System Enhancement Associates; ALL RIGHTS RESERVED

    By:  Thom Henderson

    Description:
         This program is a general archive utility, and is used to maintain
         an archive of files.  An "archive" is a single file that combines
         many files, reducing storage space and allowing multiple files to
         be handled as one.

    Instructions:
         Run this program with no arguments for complete instructions.

    Programming notes:
         ARC Version 2 differs from version 1 in that archive entries
         are automatically compressed when they are added to the archive,
         making a separate compression step unecessary.  The nature of the
         compression is indicated by the header version number placed in
         each archive entry, as follows:

         1 = Old style, no compression
         2 = New style, no compression
         3 = Compression of repeated characters only
         4 = Compression of repeated characters plus Huffman SQueezing
         5 = Lempel-Zev packing of repeated strings (old style)
         6 = Lempel-Zev packing of repeated strings (new style)
         7 = Lempel-Zev Williams packing with improved has function
         8 = Dynamic Lempel-Zev packing with adaptive reset

         Type 5, Lempel-Zev packing, was added as of version 4.0

         Type 6 is Lempel-Zev packing where runs of repeated characters
         have been collapsed, and was added as of version 4.1

         Type 7 is a variation of Lempel-Zev using a different hash
         function which yields speed improvements of 20-25%, and was
         added as of version 4.6

         Type 8 is a different implementation of Lempel-Zev, using a
         variable code size and an adaptive block reset, and was added
         as of version 5.0

         Verion 4.3 introduced a temporary file for holding the result
         of the first crunch pass, thus speeding up crunching.

         Version 4.4 introduced the ARCTEMP environment string, so that
         the temporary crunch file may be placed on a ramdisk.  Also
         added was the distinction bewteen Adding a file in all cases,
         and Updating a file only if the disk file is newer than the
         corresponding archive entry.

         The compression method to use is determined when the file is
         added, based on whichever method yields the smallest result.

    Language:
         Computer Innovations Optimizing C86
*/
#include <stdio.h>
#include "arc.h"

#if unix
char *Progname;
#endif

main(num,arg)                          /* system entry point */
int num;                               /* number of arguments */
char *arg[];                           /* pointers to arguments */
{
    char opt = 0;                      /* selected action */
    char *a;                           /* option pointer */
    char *makefnam();                  /* filename fixup routine */
    char *upper();                     /* case conversion routine */
    char *index();                     /* string index utility */
    char *getenv();                   /* environment searcher */
    int n;                             /* argument index */

    if(num<3)
    {    printf("ARC - Archive utility, %s\n",VERSION);
         printf("(C) COPYRIGHT 1985,86 by System Enhancement Associates;");
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
         printf("Usage: ARC {amufdxerplvtc}[bswn][g<password>]");
         printf(" <archive> [<filename> . . .]\n");
         printf("Where:   a   = add files to archive\n");
         printf("         m   = move files to archive\n");
         printf("         u   = update files in archive\n");
         printf("         f   = freshen files in archive\n");
         printf("         d   = delete files from archive\n");
         printf("         x,e = extract files from archive\n");
         printf("         r   = run files from archive\n");
         printf("         p   = copy files from archive to");
         printf(" standard output\n");
         printf("         l   = list files in archive\n");
         printf("         v   = verbose listing of files in archive\n");
         printf("         t   = test archive integrity\n");
         printf("         c   = convert entry to new packing method\n");
         printf("         b   = retain backup copy of archive\n");
         printf("         s   = suppress compression (store only)\n");
         printf("         w   = suppress warning messages\n");
         printf("         n   = suppress notes and comments\n");
         printf("         g   = Encrypt/decrypt archive entry\n");
         printf("\nPlease refer to the program documentation for");
         printf(" complete instructions.\n");
         return 1;
    }

    /* see where temp files go */

    if(!(arctemp = getenv("ARCTEMP")))
         arctemp = getenv("TEMP");

    /* avoid any case problems with arguments */

#if unix
    Progname = arg[0];
    upper(arg[1]);
#else
    for(n=1; n<num; n++)               /* for each argument */
         upper(arg[n]);                /* convert it to uppercase */
#endif

    /* create archive names, supplying defaults */

    makefnam(arg[2],".ARC",arcname);
#if unix
    makefnam(arcname,".$$$",newname);
#else
    makefnam(arcname,".$$$$",newname);
#endif
    makefnam(arcname,".BAK",bakname);

    /* now scan the command and see what we are to do */

    for(a=arg[1]; *a; a++)             /* scan the option flags */
    {    if(index("AMUFDXEPLVTCR",*a)) /* if a known command */
         {    if(opt)                  /* do we have one yet? */
                   abort("Cannot mix %c and %c",opt,*a);
              opt = *a;                /* else remember it */
         }

         else if(*a=='B')              /* retain backup copy */
              keepbak = 1;

         else if(*a=='W')              /* suppress warnings */
              warn = 0;

         else if(*a=='N')              /* suppress notes and comments */
              note = 0;

         else if(*a=='G')              /* garble */
         {    password = a+1;
              while(*a)
                   a++;
              a--;
         }

         else if(*a=='S')              /* storage kludge */
              nocomp = 1;

         else if(*a=='K')              /* special kludge */
              kludge = 1;

         else if(*a=='-' || *a=='/')   /* UNIX and PC-DOS option markers */
              ;

         else abort("%c is an unknown command",*a);
    }

    if(!opt)
         abort("I have nothing to do!");

    /* act on whatever action command was given */

    switch(opt)                        /* action depends on command */
    {
    case 'A':                          /* Add */
    case 'M':                          /* Move */
    case 'U':                          /* Update */
    case 'F':                          /* Freshen */
         addarc(num-3,&arg[3],(opt=='M'),(opt=='U'),(opt=='F'));
         break;

    case 'D':                          /* Delete */
         delarc(num-3,&arg[3]);
         break;

    case 'E':                          /* Extract */
    case 'X':                          /* eXtract */
    case 'P':                          /* Print */
         extarc(num-3,&arg[3],(opt=='P'));
         break;

    case 'V':                          /* Verbose list */
         bose = 1;
    case 'L':                          /* List */
         lstarc(num-3,&arg[3]);
         break;

    case 'T':                          /* Test */
         tstarc();
         break;

    case 'C':                          /* Convert */
         cvtarc(num-3,&arg[3]);
         break;

    case 'R':                          /* Run */
         runarc(num-3,&arg[3]);
         break;

    default:
         abort("I don't know how to do %c yet!",opt);
    }

    return nerrs;
}
