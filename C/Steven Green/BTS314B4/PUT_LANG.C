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
/*            BinkleyTerm Language Compiler File Output Module              */
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

#include "language.h"

/*
 * put_language -- store compiled language file
 *
 * This is a simple four step operation
 *
 * 1. Open file for write
 * 2. Write out the used part of the fixup array
 * 3. Write out the used part of the memory block
 * 4. Close the file
 *
 */

int put_language( char *name_of_file )
{
    FILE           *fpt;                        /* stream pointer            */
    int             error;                      /* Internal error value      */
    size_t             wanna_write;                /* How many we wanna write   */
    size_t             written;                    /* How many we really write  */

   /*
    * Open the file for output now.
    *
    */


    fpt = fopen (name_of_file, "wb");           /* Open the file             */
    if (fpt == NULL)                            /* Were we successful?       */
        {
        fprintf (stderr, "Can not open output file %s\n", name_of_file);
        return (-1);                            /* Return failure to caller  */
        }

   /*
    * OK. Looking good so far. Write out the pointer array.
    * Don't forget that last NULL pointer to terminate it!
    *
    */

    wanna_write = 1 + pointer_size;             /* Number of things to write */
    written = fwrite ((char *)pointers, sizeof (char *), (size_t)wanna_write, fpt);
    if (written != wanna_write)
        {
        fprintf (stderr, "Unable to write fixup array to output file\n");
        fclose (fpt);
        return (-2);
        }

   /*
    * Pointer array is there. Now write out the characters.
    *
    */

    wanna_write = memory_size;                  /* Number of chars to write  */
    written = fwrite (memory, sizeof (char), (size_t)wanna_write, fpt);
    if (written != wanna_write)
        {
        fprintf (stderr, "Unable to write characters to output file\n");
        fclose (fpt);
        return (-3);
        }

   /*
    * Everything's there now. Close the file.
    */

    error = fclose (fpt);
    if (error != 0)
        {
        fprintf (stderr, "Unable to properly close output file %s\n",name_of_file);
        return (-4);
        }

    return (0);
}
