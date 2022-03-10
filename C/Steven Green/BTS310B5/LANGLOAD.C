/*--------------------------------------------------------------------------*/
/*																			*/
/*																			*/
/*		------------		 Bit-Bucket Software, Co.						*/
/*		\ 10001101 /		 Writers and Distributors of					*/
/*		 \ 011110 / 		 Freely Available<tm> Software. 				*/
/*		  \ 1011 /															*/
/*		   ------															*/
/*																			*/
/*	(C) Copyright 1987-90, Bit Bucket Software Co., a Delaware Corporation. */
/*																			*/
/*																			*/
/*				 This module was written by Vince Perriello 				*/
/*																			*/
/*																			*/
/*					  BinkleyTerm Language File Loader						*/
/*																			*/
/*																			*/
/*	  For complete	details  of the licensing restrictions, please refer	*/
/*	  to the License  agreement,  which  is published in its entirety in	*/
/*	  the MAKEFILE and BT.C, and also contained in the file LICENSE.240.	*/
/*																			*/
/*	  USE  OF THIS FILE IS SUBJECT TO THE  RESTRICTIONS CONTAINED IN THE	*/
/*	  BINKLEYTERM  LICENSING  AGREEMENT.  IF YOU DO NOT FIND THE TEXT OF	*/
/*	  THIS	AGREEMENT IN ANY OF THE  AFOREMENTIONED FILES,	OR IF YOU DO	*/
/*	  NOT HAVE THESE FILES,  YOU  SHOULD  IMMEDIATELY CONTACT BIT BUCKET	*/
/*	  SOFTWARE CO.	AT ONE OF THE  ADDRESSES  LISTED BELOW.  IN NO EVENT	*/
/*	  SHOULD YOU  PROCEED TO USE THIS FILE	WITHOUT HAVING	ACCEPTED THE	*/
/*	  TERMS  OF  THE  BINKLEYTERM  LICENSING  AGREEMENT,  OR  SUCH OTHER	*/
/*	  AGREEMENT AS YOU ARE ABLE TO REACH WITH BIT BUCKET SOFTWARE, CO.		*/
/*																			*/
/*																			*/
/* You can contact Bit Bucket Software Co. at any one of the following		*/
/* addresses:																*/
/*																			*/
/* Bit Bucket Software Co.		  FidoNet  1:104/501, 1:132/491, 1:141/491	*/
/* P.O. Box 460398				  AlterNet 7:491/0							*/
/* Aurora, CO 80046 			  BBS-Net  86:2030/1						*/
/*								  Internet f491.n132.z1.fidonet.org 		*/
/*																			*/
/* Please feel free to contact us at any time to share your comments about	*/
/* our software and/or licensing policies.									*/
/*																			*/
/*--------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#ifdef __TOS__
#include <ext.h>
#else
#include <sys/types.h>
#include <sys/stat.h>
#endif
#include <string.h>

#ifdef __TURBOC__
#ifndef __TOS__
#include <alloc.h>
#endif
#else
#ifndef LATTICE
#include <malloc.h>
#endif
#endif


#include "bink.h"
#include "msgs.h"

#define LANGFILE "BINKLEY.LNG"
#define DEVICEDRIVER "BINKLEY.IO"


/*
 * Read the compiled BinkleyTerm Language file.
 *
 */

int load_language (void)
{
	int pointer_size;
	char *memory;
	size_t memory_size;
	char *malloc_target;
	char *envptr;
	char LANGpath[128];
	int error;
	int i;
	size_t read;
	struct stat stbuf;
	FILE		   *fpt;						 /* stream pointer			 */

   envptr = getenv ("BINKLEY"); 				 /* get path from environment*/
   if ((envptr != NULL) 						 /* If there was one, and	 */
	   && (!dexists (LANGFILE)))				 /* No local language file,  */
	  {
	  (void) strcpy (LANGpath, envptr); 		 /* use BINKLEY as our path  */
	  (void) add_backslash (LANGpath);
	  }
   else
	  LANGpath[0] = '\0';

   strcat (LANGpath, LANGFILE);

   /*
	* Get some info about the file
	*/

	error = stat (LANGpath, &stbuf);
	if (error != 0)
		{
		fprintf (stderr, "Cannot get information on file %s\n",LANGpath);
		if (reset_port) exit_port();
		exit (250);
		}

   /*
	* Allocate space for the raw character array and for the
	* pointer and fixup arrays
	*
	*/

	memory_size = stbuf.st_size;

	malloc_target = malloc (memory_size);
	if (malloc_target == NULL)
		{
		fprintf (stderr, "Unable to allocate string memory\n");
		if (reset_port) exit_port();
		exit (250);
		}

   /*
	* Open the input file
	*
	*/

	fpt = fopen (LANGpath, read_binary);				/* Open the file			 */
	if (fpt == NULL)							/* Were we successful?		 */
		{
		fprintf (stderr, "Can not open input file %s\n", LANGpath);
		if (reset_port) exit_port();
		exit (250);
		}

   /*
	* Read the entire file into memory now.
	*
	*/

	read = fread (malloc_target, 1, memory_size, fpt);
	if (read != memory_size)
		{
		fprintf (stderr, "Could not read language data from file %s\n",LANGpath);
		fclose (fpt);
		if (reset_port) exit_port();
		exit (250);
		}

   /*
	* Close the file.
	*
	*/

	error = fclose (fpt);
	if (error != 0)
		{
		fprintf (stderr, "Unable to close language file %s\n",LANGpath);
		if (reset_port) exit_port();
		exit (250);
		}

   /*
	* Do fixups on the string pointer array as follows:
	*
	* 1. Find the NULL pointer in the mess here.
	* 2. Start of the string memory is the "following pointer".
	* 3. Apply arithmetic correction to entire array.
	*
	*/

	msgtxt = (char **) malloc_target;
	for (i = 0; msgtxt[i] != NULL; i++) 		/* Find NULL marker in array */
		;

	pointer_size = i - 1;						/* Count of elements w/o NULL*/
	if (pointer_size != X_TOTAL_MSGS)
		{
#ifdef NEW
		fprintf(stderr, "Incompatible language file %s\n", LANGFILE);
		fprintf(stderr,	"It has %d messages instead of %d\n",
					pointer_size, X_TOTAL_MSGS);
		fprintf(stderr, "Recompile it by using BTLNG.TOS\n");
#else
		fprintf (stderr, "Count of %d from file does not match %d required\n",
					pointer_size, X_TOTAL_MSGS);
#endif
		if (reset_port) exit_port();
		exit (250);
		}

	memory = (char *) &msgtxt[++i]; 			/* Text starts after NULL	 */

	for (i = 1; i <= pointer_size; i++)
		{
		msgtxt[i] = memory + (msgtxt[i] - msgtxt[0]);
		}

	msgtxt[0] = memory;


/* Read Device-Driver */


   envptr = getenv ("BINKLEY"); 				 /* get path from environment*/
   if ((envptr != NULL) 						 /* If there was one, and	 */
	   && (!dexists (DEVICEDRIVER)))				 /* No local language file,  */
	  {
	  (void) strcpy (LANGpath, envptr); 		 /* use BINKLEY as our path  */
	  (void) add_backslash (LANGpath);
	  }
   else
	  LANGpath[0] = '\0';

   strcat (LANGpath, DEVICEDRIVER);

	error = stat (LANGpath, &stbuf);
	if (error != 0)
		{	fprintf (stderr, "Cannot get information on file %s\n",LANGpath);
			if (reset_port) exit_port();
			exit (250);
		}
	else
		{	memory_size = stbuf.st_size;

			malloc_target = malloc (memory_size);
			if (malloc_target == NULL)
				{
				fprintf (stderr, "Unable to allocate devicedriver memory\n");
				if (reset_port) exit_port();
				exit (250);
				}
		
			fpt = fopen (LANGpath, read_binary);				/* Open the file			 */
			if (fpt == NULL)							/* Were we successful?		 */
				{
				fprintf (stderr, "Can not open input file %s\n", LANGpath);
				if (reset_port) exit_port();
				exit (250);
				}
		
			read = fread (malloc_target, 1, memory_size, fpt);
			if (read != memory_size)
				{
				fprintf (stderr, "Could not read devicedriver data from file %s\n",LANGpath);
				fclose (fpt);
				if (reset_port) exit_port();
				exit (250);
				}
		
			error = fclose (fpt);
			if (error != 0)
				{
				fprintf (stderr, "Unable to close devicedriver file %s\n",LANGpath);
				if (reset_port) exit_port();
				exit (250);
				}
			device_addr = (long) malloc_target;
		}

	return (1);
}
