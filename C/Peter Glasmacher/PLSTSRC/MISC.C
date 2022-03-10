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
#include <ctype.h>
#include <time.h>
#  include <ext.h>
#  include <tos.h>

#include "types.h"
#include "externs.h"
#include "pl.h"


cmp (a, b)
struct nidxs *a, *b;
{
   if (a->idxnet < b->idxnet)    {
      return (-1);
   }   else if (a->idxnet > b->idxnet)    {
      return (1);
   }  else      {
      return (a->idxnode - b->idxnode);
   }
}

/* Returns the next field that ends with a comma or newline */

char *nextfield (p, s)
char *p, *s;
{
   while ((*p) && (*p != ',') && (*p != '\n'))    {
      *s++ = *p++;
   }
   *s = '\0';
   return (++p);
}

/* Converts a "special" word to upper case and appends a space */

void spec_word (char *b1)
{
char *p1;

   strupr (b1);
   p1 = b1 + strlen (b1);
   *p1++ = ' ';
   *p1 = '\0';
}

/* Uses malloc() to get memory, but exits on allocation error */

char *mymalloc(unsigned int s)
{
char *p;
extern void *malloc();

   p = malloc (s);
   if (p == NULL)    {
      printf ("\n\nNot Enough Memory - Exiting\n\n");
      exit (1);
   }
   return (p);
}

/* Gets the name of the nodelist that should be processed this run */

void nfile_name (char **fn)
{
int i;
long t;
struct tm *tm1, *localtime();

   /* Get todays info */
   time (&t);
   tm1 = localtime (&t);

   /* find all NODELIST.* files and if end in number, put in array */
   get_nl_list ();

   for (i = tm1->tm_yday + 1; i >= 0; i--)    {
      if (nl[i])   {
         *fn = mymalloc (13);
         sprintf (*fn, "NODELIST.%03d", i);
         return;
      }
   }

   /* If no nodelist files, try last years */
   for (i = 366; i >= tm1->tm_yday; i--)     {
      if (nl[i])     {
         *fn = mymalloc (13);
         sprintf (*fn, "NODELIST.%03d", i);
         return;
      }
   }

   /* If still nothing, try the big numbers */
   for (i = 999; i >= 367; i--)    {
      if (nl[i])   {
         *fn = mymalloc (13);
         sprintf (*fn, "NODELIST.%03d", i);
         return;
      }
   }

   printf ("\n\nCannot find a valid NODELIST.xxx file - Exiting\n\n");
   exit (1);
}

/* Remove dashes from the string */

void undash (str)
char *str;
{
   char *p, *p1;

   p = str;
   p1 = str;
   while (*p)   {
      if (*p != '-')
         *p1++ = *p;
      ++p;
   }
   *p1 = '\0';
}

void get_nl_list (void)
{
   char str[13];
   char init_name[13];
   int i, d;

   /* Start out by initializing what we are looking for */
   strcpy (init_name, "NODELIST.*");
   d = 0;

   /* Now loop through getting each file name that matches,
      and copying the number into the array */
   do      {
      (void) filedir (init_name, d, str, 0);
      i = 0;
      d = 1;
      sscanf (str, "NODELIST.%d", &i);

      if ((i > 0) &&
          (isdigit (str[9])) &&
          (isdigit (str[10])) &&
          (isdigit (str[11])))     {
         nl[i] = 1;
      }
   }
   while (str[0] != '\0');
}

struct ffblk sbuf;

filedir (name, times, ret_str, mode)
char *name;
int times;
char *ret_str;
int mode;
{
        if (times == 0)
                {
                if (findfirst (name,&sbuf,mode))
                        sbuf.ff_name[0] = '\0';
                strcpy (ret_str, sbuf.ff_name);
                }
        else
                {
                if (findnext (&sbuf))
                        sbuf.ff_name[0] = '\0';
                strcpy (ret_str, sbuf.ff_name);
                }

   return (sbuf.ff_attrib);
        }

void get_addr (char *s, int *z, int *net, int *node)
{
   if (sscanf (s, "%d:%d/%d", z, net, node) != 3)
      {
      *z = myzone;
      if (sscanf (s, "%d/%d", net, node) != 2)
         {
         *node = *net;
         *net = mynet;
         }
      }
}

#undef exit
void stexit(int code)
{
  if (wait)   {
     puts("\n\rPress a key to exit.....\n\r");
     Cnecin();
  }
     exit(code);
}

