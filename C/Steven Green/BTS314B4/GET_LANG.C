/*--------------------------------------------------------------------------*/
/*                                                                          */
/*                                                                          */
/*      ------------         Bit-Bucket Software, Co.                       */
/*      \ 10001101 /         Writers and Distributors of                    */
/*       \ 011110 /          Freely Available<tm> Software.                 */
/*        \ 1011 /                                                          */
/*         ------                                                           */
/*                                                                          */
/*  (C) Copyright 1987-90, Bit Bucket Software Co., a Delaware Corporation. */
/*                                                                          */
/*                                                                          */
/*               This module was written by Vince Perriello                 */
/*                                                                          */
/*                                                                          */
/*             BinkleyTerm Language Compiler Raw Input Module               */
/*                                                                          */
/*                                                                          */
/*    For complete  details  of the licensing restrictions, please refer    */
/*    to the License  agreement,  which  is published in its entirety in    */
/*    the MAKEFILE and BT.C, and also contained in the file LICENSE.240.    */
/*                                                                          */
/*    USE  OF THIS FILE IS SUBJECT TO THE  RESTRICTIONS CONTAINED IN THE    */
/*    BINKLEYTERM  LICENSING  AGREEMENT.  IF YOU DO NOT FIND THE TEXT OF    */
/*    THIS  AGREEMENT IN ANY OF THE  AFOREMENTIONED FILES,  OR IF YOU DO    */
/*    NOT HAVE THESE FILES,  YOU  SHOULD  IMMEDIATELY CONTACT BIT BUCKET    */
/*    SOFTWARE CO.  AT ONE OF THE  ADDRESSES  LISTED BELOW.  IN NO EVENT    */
/*    SHOULD YOU  PROCEED TO USE THIS FILE  WITHOUT HAVING  ACCEPTED THE    */
/*    TERMS  OF  THE  BINKLEYTERM  LICENSING  AGREEMENT,  OR  SUCH OTHER    */
/*    AGREEMENT AS YOU ARE ABLE TO REACH WITH BIT BUCKET SOFTWARE, CO.      */
/*                                                                          */
/*                                                                          */
/* You can contact Bit Bucket Software Co. at any one of the following      */
/* addresses:                                                               */
/*                                                                          */
/* Bit Bucket Software Co.        FidoNet  1:104/501, 1:132/491, 1:141/491  */
/* P.O. Box 460398                AlterNet 7:491/0                          */
/* Aurora, CO 80046               BBS-Net  86:2030/1                        */
/*                                Internet f491.n132.z1.fidonet.org         */
/*                                                                          */
/* Please feel free to contact us at any time to share your comments about  */
/* our software and/or licensing policies.                                  */
/*                                                                          */
/*--------------------------------------------------------------------------*/

#include <stdio.h>

#ifdef ATARIST			/* ANSI has the memcpy() prototype in <string.h> */

#include <string.h>

#else

#include <memory.h>

#endif

#include "language.h"

/*
 *	get_language - read in BinkleyTerm language source
 *
 * Read lines into table, ignoring blanks and comments
 * Store into a contiguous block of memory with the individual
 *     members being referenced by an array of pointers
 * Store number of lines read into pointer_size
 * Store amount of memory used into memory_size
 *
 */

int get_language( char *name_of_file )
{
    int             len;                        /* length of current string  */
    int             count_from_file;            /* no. of strings in file    */
    int             file_version;               /* version of file           */
    char           *p, *q;                      /* miscellaneous pointers    */
    char            c;                          /* character from *p array   */
    int             escape_on;                  /* was prev char an escape   */
    char           *storage;                    /* where we're storing now   */
    char          **load_pointers;              /* pointer to pointer array  */
    char            linebuf[255];               /* biggest line we'll allow  */
    FILE           *fpt;                        /* stream pointer            */
    int             internal_count;             /* How many strings we got   */
    int             total_size;                 /* How big it all is         */
    int             error;                      /* Internal error value      */

    internal_count = 0;                         /* zero out internal counter */
    count_from_file = 0;                        /* zero out internal counter */
    total_size = 0;                             /* Initialize storage size   */
    error = 0;                                  /* Initialize error value    */

    load_pointers = pointers;                   /* Start at the beginning    */
    storage = memory;                           /* A very good place to start*/


    /*
     * Open the file now. Then read in the appropriate table. First line of
     * the file contains the number of lines we want Second line through end:
     * ignore if it starts with a ; and store only up to ;
     *
     */


    fpt = fopen (name_of_file, "r");            /* Open the file             */
    if (fpt == NULL)                            /* Were we successful?       */
        {
        fprintf (stderr, "Can not open input file %s\n", name_of_file);
        return (-1);                            /* Return failure to caller  */
        }

    while (fgets (linebuf, 254, fpt) != NULL)   /* read a line in            */
        {
        escape_on = 0;                          /* zero out escape char flag */
        p = q = linebuf;                        /* set up for scan           */
        while ((c = *p++) > 0 ) 

            {
            switch (c)
                {
                case ';':
                    if (escape_on)
                        {
                        *q++ = ';';
                        --escape_on;
                        break;
                        }
                /* Otherwise drop into newline code */

                case '\n':
                    *q = *p = '\0';
                    break;

                case '\\':
                    if (escape_on)
                        {
                        *q++ = '\\';
                        --escape_on;
                        }
                    else
                        ++escape_on;
                    break;

                case 'n':
                    if (escape_on)
                        {
                        *q++ = '\n';
                        --escape_on;
                        }
                    else
                        *q++ = c;
                    break;

                case 'r':
                    if (escape_on)
                        {
                        *q++ = '\r';
                        --escape_on;
                        }
                    else
                        *q++ = c;
                    break;

                default:
                    *q++ = c;
                    escape_on = 0;
                    break;
					 }
            }

        if ((len = (int) (q - linebuf)) == 0)       /* Is anything there?        */
            continue;                           /* No -- ignore.             */

        if (!count_from_file)
            {
            sscanf (linebuf,"%d %d",&count_from_file, &file_version);
            if (count_from_file <= pointer_size)
                continue;

            fprintf (stderr, 
                "Messages in file = %d, Pointer array size = %d\n",
                    count_from_file, pointer_size);
            error = -2;
            break;
            }

        ++len;                                  /* Allow for the terminator  */
        if (((total_size += len) < memory_size) /* Make sure it will fit     */
        &&  (internal_count < pointer_size))
            {
            memcpy (storage, linebuf, (size_t)len);     /* Copy it now (with term)   */
            *load_pointers++ = storage;         /* Point to start of string  */
            storage += len;                     /* Move pointer into memory  */                
            }

        ++internal_count;                       /* bump count */
        }
    /*
     * Close the file. Make sure the counts match and that memory size was
     * not exceeded. If so, we have a winner! If not, snort and puke. 
     *
     */

    fclose (fpt);

    if (internal_count > pointer_size)          /* Enough pointers?          */
        {
        fprintf (stderr,
            "%d messages read exceeds pointer array size of %d\n",
                internal_count, pointer_size);
        error = -3;
        }

    if (total_size > memory_size)               /* Did we fit?               */
        {
        fprintf (stderr,
            "Required memory of %d bytes exceeds %d bytes available\n",
                total_size, memory_size);
        error = -4;
        }

    if (count_from_file != internal_count)
        {
        fprintf (stderr, 
            "Count of %d lines does not match %d lines actually read\n",
                count_from_file, internal_count);
        error = -5;
        }

    if (!error)
        {
        pointer_size = internal_count;          /* Store final usage counts  */
        memory_size = total_size;
        *load_pointers = NULL;                  /* Terminate pointer table   */
        }

    return (error);
}
