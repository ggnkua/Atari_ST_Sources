/************************************************************************
*************************************************************************
** NOTE:                                                               **
**   This Module is part of the ATARI ST Implementation of Parselst    **
**   It should NOT be used for general reference. Please read the com- **
**   plete Disclaimer at the TOP of PARSELST.C.                        **
**   Peter Glasmacher at 1:143/9  Ph (408)985-1538                     **
*************************************************************************
*************************************************************************/

/*----------------------------------------------------------------------*
*                              Nodelist Parser                          *
*                                                                       *
*              This module was originally written by Bob Hartman        *
*                       Sysop of FidoNet node 1:132/101                 *
*                                                                       *
* Spark Software, 427-3 Amherst St, CS 2032, Suite 232, Nashua, NH 03061*
*                                                                       *
* This program source code is being released with the following         *
* provisions:                                                           *
*                                                                       *
* 1.  You are  free to make  changes to this source  code for use on    *
*     your own machine,  however,  altered source files may not be      *
*     distributed without the consent of Spark Software.                *
*                                                                       *
* 2.  You may distribute "patches"  or  "diff" files for any changes    *
*     that you have made, provided that the "patch" or "diff" files are *
*     also sent to Spark Software for inclusion in future releases of   *
*     the entire package.   A "diff" file for the source archives may   *
*     also contain a compiled version,  provided it is  clearly marked  *
*     as not  being created  from the original source code.             *
*     No other  executable  versions may be  distributed without  the   *
*     consent of Spark Software.                                        *
*                                                                       *
* 3.  You are free to include portions of this source code in any       *
*     program you develop, providing:  a) Credit is given to Spark      *
*     Software for any code that may is used, and  b) The resulting     *
*     program is free to anyone wanting to use it, including commercial *
*     and government users.                                             *
*                                                                       *
* 4.  There is  NO  technical support  available for dealing with this  *
*     source code, or the accompanying executable files.  This source   *
*     code  is provided as is, with no warranty expressed or implied    *
*     (I hate legalease).   In other words, if you don't know what to   *
*     do with it,  don't use it,  and if you are brave enough to use it,*
*      you're on your own.                                              *
*                                                                       *
* Spark Software may be contacted by modem at (603) 888-8179            *
* (node 1:132/101)                                                      *
* on the public FidoNet network, or at the address given above.         *
*                                                                       *
*-----------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#  include <ext.h>
#include <ctype.h>
#include <time.h>

#include "types.h"
#include "externs.h"
#include "pl.h"

void do_names (void)
{
FILE *o1, *o2;
char b1[50];

   printf ("Sorting SysOp Name Data\n\n");
   sort();
   if ((o1 = fopen ("FIDOUSER.$$1", "r")) == NULL)  {
      
   }
   if ((o2 = fopen ("FIDOUSER.LST", "w")) == NULL) {

   }


   b1[0] = '\0';
   nnodes = 0;
   printf ("\nDeleting Duplicate SysOp Names\n");
   while (fgets (t_str, 127, o1) != NULL)   {
      if (strncmp (t_str, b1, 40) == 0)    {
         continue;
      }
      ++nnodes;
      if (nnodes % 100 == 0)
         printf ("\r%d", nnodes);
      t_str[60] = '\n';
      t_str[61] = '\0';
      fputs (t_str, o2);
      strncpy (b1, t_str, 40);
   }
   printf ("\r%d Unique SysOp Names Found in Network\n", nnodes);
   fclose (o1);
   fclose (o2);
   unlink ("FIDOUSER.$$1");
}

/* Just some random equation to determine likelihood of current address
   being the correct default address for an individual (a good guess -
   at least I hope so <grin>).  */
void how_likely (p, dphone, addrs, node, n_baud)
char *p;
int dphone;
int addrs[];
int node;
int n_baud;
{

   /*-------------------------------------------------------------------*
   * It is less likely if it is a coordinator node                      *
   *--------------------------------------------------------------------*/
   if (dphone || (node == 0)) {
      likely = 6000;
   } else {
      likely = 8000;
   }

   /*-------------------------------------------------------------------*
   * If its not in my zone, punish it                                   *
   *--------------------------------------------------------------------*/
   if ((myzone > 0) && (addrs[0] != myzone))
      likely -= 3000;

   /*-------------------------------------------------------------------*
   * If it is a "normal" net number, add something to it                *
   *--------------------------------------------------------------------*/
   if ((addrs[2] >= 100) && (addrs[2] <= 999))
      likely += 2000 + addrs[2];
   /*-------------------------------------------------------------------*
   * If it is a region, that is better than a private net               *
   *--------------------------------------------------------------------*/
   else if (addrs[2] < 100)
      likely += 250;
   /*-------------------------------------------------------------------*
   * Otherwise, it is probably bad news                                 *
   *--------------------------------------------------------------------*/
   else
      likely -= 1000;

   /*-------------------------------------------------------------------*
   * Prefer the higher baud rate                                        *
   *--------------------------------------------------------------------*/
   likely += n_baud / 8;

   /*-------------------------------------------------------------------*
   * CM or XP or WZ is real nice                                        *
   *--------------------------------------------------------------------*/
   if (strstr (p, "CM")) {
      likely += 2500;
   } else if (strstr (p, "XP")) {
      likely += 2500;
   }
   else if (strstr (p, "WZ")) {
      likely += 2500;
   }

   /*-------------------------------------------------------------------*
   * Favor WZ a bit more                                                *
   *--------------------------------------------------------------------*/
   if (strstr (p, "WZ")) {
      likely += 100;
   }

   /*-------------------------------------------------------------------*
   * If it is mail only, then it is probably not his primary            *
   *--------------------------------------------------------------------*/
   if (strstr (p, "MO")) {
      likely -= 100;
   }

   /*-------------------------------------------------------------------*
   * Don't be fooled if has restricted hours, probably not primary      *
   *--------------------------------------------------------------------*/
   if (strstr (p, "WK")) {
      likely -= 100;
   }
   if (strstr (p, "WE")) {
      likely -= 100;
   }
   if (strstr (p, "DA")) {
      likely -= 100;
   }

   /*-------------------------------------------------------------------*
   * If it is a coordinator, punish it depending on what type of coord  *
   *--------------------------------------------------------------------*/
   if (dphone)
      likely -= (5 - dphone) * 75;
}
int (comp)(char *,char *);

sort()
{
int o1;
struct ffblk dta;
size_t recsize,rcount;
char *base,buf[100];

   if (findfirst("FIDOUSER.$$1",&dta,0x27) != 0)   {
       printf("\nUnable to open User directory");      
       return;
   }
   if ((base = malloc(dta.ff_fsize)) == 0)   {
      printf( "\nNot enough memory to sort Userlist");
      return;
   }

   o1 = open("FIDOUSER.$$1",O_RDWR | O_BINARY);
   read(o1,buf,80);   
   recsize = ( strchr (buf, '\n') -( buf ) + 1);
   rcount  = ( dta.ff_fsize / recsize); /* number of records*/
   lseek(o1,0,SEEK_SET);

   if (read(o1,base,dta.ff_fsize)!= dta.ff_fsize)   {
     printf("\Problems reading FIDOUSER.$$1 into memory");
     free (base);
     return;
   }
   close(o1);
   printf("\nSorting....");
   qsort(base,rcount,recsize,comp);
   printf("\nwriting sorted List...");
   if ((o1 = open("FIDOUSER.$$1",O_RDWR|O_TRUNC))<0)   {
      printf("\nunable to write sorted Userlist back to disk");
      free(base);
      return;
   }
   if (write(o1,base,dta.ff_fsize)!= dta.ff_fsize)   {
      printf("\ncouldn't write the complete List");
   }
   free(base);
   return;
}

int comp(char *a, char *b)
{
   return(strcmp(a,b));
}
