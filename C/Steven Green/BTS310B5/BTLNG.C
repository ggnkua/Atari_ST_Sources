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
/*                    BinkleyTerm Language File Compiler                    */
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
#include <stdlib.h>

#include "language.h"


/*
 * Assume average length of a string at 32 characters
 *
 */

#define MAX_STRINGS 1000
#define MAX_MEMORY (MAX_STRINGS * 32)

char **pointers;
size_t pointer_size;

char *memory;
size_t memory_size;

void main (int, char **);
static void usage (void);


/*
 * Read in a raw text file and write out a compiled BinkleyTerm
 * language file.
 *
 */

void main (argc, argv)
int argc;
char **argv;
{
    char *malloc_target;
    int error;

   /*
    * Print out the copyright notice.
    */

   (void) fprintf (stderr, "BinkleyTerm Language File Compiler Version 2.40");
   (void) fprintf (stderr, "\n(C) Copyright 1987-90, Bit Bucket Software, Co. ALL RIGHTS RESERVED.\n\n");

   /*
    * Make sure we were called with the requisite number of arguments
    *
    */

    if (argc != 3)
        usage ();

   /*
    * Allocate space for the raw character array and for the
    * pointer array
    *
    */

    malloc_target = malloc (MAX_MEMORY);
    if (malloc_target == NULL)
        {
        fprintf (stderr, "Unable to allocate string memory\n");
        exit (250);
        }
    memory = malloc_target;
    memory_size = MAX_MEMORY;

    malloc_target = malloc ((MAX_STRINGS + 1) * (sizeof (char *)));
    if (malloc_target == NULL)
        {
        fprintf (stderr, "Unable to allocate pointer array\n");
        exit (250);
        }
    pointers = (char **)malloc_target;
    pointer_size = MAX_STRINGS;


   /*
    * Now read the stuff into our array.
    *
    */

    error = get_language (argv[1]);
    if (error != 0)
       exit (240);


   /*
    * Write our stuff out now.
    *
    */

    error = put_language (argv[2]);
    if (error != 0)
       exit (230);
}


static void usage ()
{
    fprintf (stderr, "Usage : BTLNG language_file_name output_file_name\n");
    exit (255);
}

