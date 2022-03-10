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
/*				   This module was written by Bob Hartman					*/
/*																			*/
/*																			*/
/*				   BinkleyTerm Fidolist processing module					*/
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
#ifdef __TOS__
#include <ext.h>
#else
#include <sys\types.h>
#include <sys\stat.h>
#include <fcntl.h>
#endif
#include <string.h>
#ifndef LATTICE
#include <io.h>
#endif

#include "bink.h"
#include "nodeproc.h"

static size_t reclength = -1;
static int nrecs = -1;

void fidouser( char *name, ADDR *faddr )
{
   int low, high, mid, f, cond;
   FILE *fbtnc;
   size_t namelen;
   char midname[80];
   char last_name_first[80];
   char *c, *p, *m;
   struct stat buffer;

   faddr->Zone = faddr->Net = faddr->Node = faddr->Point = -1;
   faddr->Domain = NULL;

   c = midname; 								 /* Start of temp name buff   */
   p = name;									 /* Point to start of name	  */
   m = NULL;									 /* Init pointer to space	  */

   *c = *p++;
   while (*c)									 /* Go entire length of name  */
	  {
	  if (*c == ' ')							 /* Look for space			  */
		 m = c; 								 /* Save location			  */
	  c++;
	  *c = *p++;
	  }

   if (m != NULL)								 /* If we have a pointer,	  */
	  {
	  *m++ = '\0';								 /* Terminate the first half  */
	  (void) strcpy (last_name_first, m);				/* Now copy the last name	 */
	  (void) strcat (last_name_first, ", ");			/* Insert a comma and space  */
	  (void) strcat (last_name_first, midname); 		/* Finally copy first half	 */
	  }
   else (void) strcpy (last_name_first, midname);		/* Use whole name otherwise  */

   (void) fancy_str (last_name_first);					/* Get caps in where needed  */
   namelen = (int) strlen (last_name_first);		   /* Calc length now			*/

   midname[0] = '\0';							 /* "null-terminated string"  */
   (void) strcpy (midname, net_info);					/* take nodelist path		 */
   (void) strcat (midname, "FIDOUSER.LST"); 			/* add in the file name 	 */
   
   if (nodeListType != BTNC)
   {
      if ((f = open (midname, O_RDONLY | O_BINARY)) == -1)
	  {
	     reclength = -1;							 /* Reset all on open failure */
	     return;
	  }
   }
   else
   {
       if ((fbtnc = fopen (midname, "r")) == NULL) return;
   }
   

   /* Find out if we have done this before */
   if (reclength == -1 && nodeListType != BTNC)
	  {
	  /* If not, then determine file size and record length */

#ifdef ATARIST
	  stat (midname, &buffer);			/* ST doesnt have fstat!!!! */
#else
	  fstat(f, &buffer);				/* Get file stats in buffer  */
#endif
	  (void) read (f, midname, 80); 					/* Read 1 record			 */
	  reclength = ((int) strchr (midname, '\n') - (int) midname) + 1;	/* FindEnd */
	  nrecs = (int) (buffer.st_size / reclength);/* Now get num of records */
	  }

   if (nodeListType != BTNC)
   {   
      /* Binary search algorithm */
      low = 0;
      high = nrecs - 1;
      while (low <= high)
	  {
	     mid = low + (high - low) / 2;
	     (void) lseek (f, (long) ((long) mid * (long) reclength), SEEK_SET);
	     (void) read (f, midname, reclength);
	     if ((cond = strnicmp (last_name_first, midname, namelen)) < 0)
		    high = mid - 1;
	     else
		 {
		    if (cond > 0)
	 		   low = mid + 1;
		    else
		    {
			   /* Return the address information */
			   (void) close (f);
			   /* The offset of 40 is just a number that should work properly */
			   faddr->Point = 0;
		  	   if (!find_address (&midname[40], faddr))
			   {
			      faddr->Zone = faddr->Net = faddr->Node = faddr->Point = -1; faddr->Domain = NULL;
			   }
			   return;
			}
		 }
	  }
      faddr->Zone = faddr->Net = faddr->Node = faddr->Point = -1;
      faddr->Domain = NULL;
      (void) close (f);
   }
   else
   {
       /* sequentiell searching in BTNC fidouser.lst */
       /* this files isn't sorted                    */
       
       while (fgets (midname, 79, fbtnc) != NULL)
       {
           if (strnicmp (last_name_first, midname, namelen) == 0)
           {
               if (!find_address (midname+namelen+1, faddr))
               {
			      faddr->Zone = faddr->Net = faddr->Node = faddr->Point = -1; faddr->Domain = NULL;
			   }
			   fclose (fbtnc);
			   return;
		   }
       }
       fclose (fbtnc);
   }
}
