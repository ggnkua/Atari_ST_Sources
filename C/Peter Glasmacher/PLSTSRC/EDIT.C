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

#include    <stdio.h>
#include    <string.h>
#include    <stdlib.h>
#include    <ext.h>
#include    <ctype.h>

#include "types.h"
#include "pl.h"

/*----------------------------------------------------------------------*
* -rev 04-16-87  (abbreviated)                                          *
*  The CRC-16 routines used by XMODEM, YMODEM, and ZMODEM               *
*  are also in this file, a fast table driven macro version             *
*-----------------------------------------------------------------------*/

/*----------------------------------------------------------------------*
* crctab calculated by Mark G. Mendel, Network Systems Corporation      *
*-----------------------------------------------------------------------*/
static unsigned short crctab[256] = {
    0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50a5, 0x60c6, 0x70e7, 0x8108,
    0x9129, 0xa14a, 0xb16b, 0xc18c, 0xd1ad, 0xe1ce, 0xf1ef, 0x1231, 0x0210,
    0x3273, 0x2252, 0x52b5, 0x4294, 0x72f7, 0x62d6, 0x9339, 0x8318, 0xb37b,
    0xa35a, 0xd3bd, 0xc39c, 0xf3ff, 0xe3de, 0x2462, 0x3443, 0x0420, 0x1401,
    0x64e6, 0x74c7, 0x44a4, 0x5485, 0xa56a, 0xb54b, 0x8528, 0x9509, 0xe5ee,
    0xf5cf, 0xc5ac, 0xd58d, 0x3653, 0x2672, 0x1611, 0x0630, 0x76d7, 0x66f6,
    0x5695, 0x46b4, 0xb75b, 0xa77a, 0x9719, 0x8738, 0xf7df, 0xe7fe, 0xd79d,
    0xc7bc, 0x48c4, 0x58e5, 0x6886, 0x78a7, 0x0840, 0x1861, 0x2802, 0x3823,
    0xc9cc, 0xd9ed, 0xe98e, 0xf9af, 0x8948, 0x9969, 0xa90a, 0xb92b, 0x5af5, 
    0x4ad4, 0x7ab7, 0x6a96, 0x1a71, 0x0a50, 0x3a33, 0x2a12, 0xdbfd, 0xcbdc,
    0xfbbf, 0xeb9e, 0x9b79, 0x8b58, 0xbb3b, 0xab1a, 0x6ca6, 0x7c87, 0x4ce4,
    0x5cc5, 0x2c22, 0x3c03, 0x0c60, 0x1c41, 0xedae, 0xfd8f, 0xcdec, 0xddcd,
    0xad2a, 0xbd0b, 0x8d68, 0x9d49, 0x7e97, 0x6eb6, 0x5ed5, 0x4ef4, 0x3e13,
    0x2e32, 0x1e51, 0x0e70, 0xff9f, 0xefbe, 0xdfdd, 0xcffc, 0xbf1b, 0xaf3a, 
    0x9f59, 0x8f78, 0x9188, 0x81a9, 0xb1ca, 0xa1eb, 0xd10c, 0xc12d, 0xf14e,
    0xe16f, 0x1080, 0x00a1, 0x30c2, 0x20e3, 0x5004, 0x4025, 0x7046, 0x6067,
    0x83b9, 0x9398, 0xa3fb, 0xb3da, 0xc33d, 0xd31c, 0xe37f, 0xf35e, 0x02b1, 
    0x1290, 0x22f3, 0x32d2, 0x4235, 0x5214, 0x6277, 0x7256, 0xb5ea, 0xa5cb, 
    0x95a8, 0x8589, 0xf56e, 0xe54f, 0xd52c, 0xc50d, 0x34e2, 0x24c3, 0x14a0,
    0x0481, 0x7466, 0x6447, 0x5424, 0x4405, 0xa7db, 0xb7fa, 0x8799, 0x97b8,
    0xe75f, 0xf77e, 0xc71d, 0xd73c, 0x26d3, 0x36f2, 0x0691, 0x16b0, 0x6657,
    0x7676, 0x4615, 0x5634, 0xd94c, 0xc96d, 0xf90e, 0xe92f, 0x99c8, 0x89e9,
    0xb98a, 0xa9ab, 0x5844, 0x4865, 0x7806, 0x6827, 0x18c0, 0x08e1, 0x3882,
    0x28a3, 0xcb7d, 0xdb5c, 0xeb3f, 0xfb1e, 0x8bf9, 0x9bd8, 0xabbb, 0xbb9a,
    0x4a75, 0x5a54, 0x6a37, 0x7a16, 0x0af1, 0x1ad0, 0x2ab3, 0x3a92, 0xfd2e,
    0xed0f, 0xdd6c, 0xcd4d, 0xbdaa, 0xad8b, 0x9de8, 0x8dc9, 0x7c26, 0x6c07,
    0x5c64, 0x4c45, 0x3ca2, 0x2c83, 0x1ce0, 0x0cc1, 0xef1f, 0xff3e, 0xcf5d,
    0xdf7c, 0xaf9b, 0xbfba, 0x8fd9, 0x9ff8, 0x6e17, 0x7e36, 0x4e55, 0x5e74,
    0x2e93, 0x3eb2, 0x0ed1, 0x1ef0
};

/*
 * updcrc macro derived from article Copyright (C) 1986 Stephen Satchell. 
 *  NOTE: First argument must be in range 0 to 255.
 *        Second argument is referenced twice.
 * 
 * Programmers may incorporate any or all code into their programs, 
 * giving proper credit within the source. Publication of the 
 * source routines is permitted so long as proper credit is given 
 * to Stephen Satchell, Satchell Evaluations and Chuck Forsberg, 
 * Omen Technology.
 */

#define updcrc(cp, crc) ( crctab[((crc >> 8) & 255) ^ cp] ^ (crc << 8))

char     old_name[13] = "NODELIST.*";
char     new_name[13] = "NODELIST.";
char     diff_name[13] = "NODEDIFF.*";
FILE     *old_file, *diff_file, *new_file;
unsigned official_crc = 0;
unsigned calc_crc = 0;   /* Until I find out how to do the CRC */

unsigned crcstr (char *buf, unsigned crc)
{
char *p;

   p = buf;
   fix_up (p);

   while (*p) {
      crc = updcrc (*p++, crc);
   }

   return (crc);
}

void fix_up (char *buf)
{
char  *p;

   p = buf + strlen (buf) - 1;
   if (*p == '\n')
      --p;
   if (*p == '\r')
      --p;
   while (*p == ' ')
      --p;
   strcpy (++p, "\r\n");

   /* Now get rid of rotten chars */
   p = buf;
   while (*p)    {
      if (*p >= 128)
         *p = '?';
      ++p;
   }
}

void edit (void)                         /* Add NODEDIFF to NODELIST */
{
int results;

   get_old_name (old_name);
   if (!get_diff_name (diff_name))   {
      results = open_infiles (old_name, diff_name);
   }  else   {
      results = 1;
   }
   if (results == 0)
      add_files ();
   close_files ();
   return;
}

void add_files (void)             /* Actually put the new lines in here */
{
char  old_line[256];
char  diff_line[256];
char  *pnt_line;
char  first_char;
char  *diff_result;
char  *old_result;
char  *ptr;
int   i, j, k;
int   first_diff;

   first_diff = 1;

   pnt_line = (char *) malloc (256);

   while ((diff_result = fgets (diff_line, 256, diff_file)) != NULL)    {
      strcpy (pnt_line, diff_line);
      first_char = diff_line[0];

      switch (first_char)   {
         case ';':
            continue;

         case 'D':
            j = atoi (pnt_line + 1);
            for (i = 0; i < j; i++)    {
               old_result = fgets (old_line, 256, old_file);
            }
            break;

         case 'A':
            j = atoi (pnt_line + 1);
            for (i = 0; i < j; i++)    {
               diff_result = fgets (diff_line, 256, diff_file);
               if (!first_diff)
                  calc_crc = crcstr (diff_line, calc_crc);
               else   {
                  first_diff = 0;
                  ptr = strrchr (diff_line, ':');
                  if (ptr != NULL)    {
                     ++ptr;
                     official_crc = atoi (ptr);
                  }
               }
               k = fputs (diff_line, new_file);
            }
            break;

         case 'C':
            j = atoi (pnt_line + 1);
            for (i = 0; i < j; i++)      {
               diff_result = fgets (old_line, 256, old_file);
               calc_crc = crcstr (old_line, calc_crc);
               k = fputs (old_line, new_file);
               }
            break;

         default:
            printf ("\n\tI don't understand this line.\n");
            break;
         }
      }

   if (calc_crc != official_crc)
      {
      fputs (";A This nodelist does not have the proper CRC!\r\n", new_file);
      printf ("This nodelist does not have the proper CRC %u/%u!\n",
         calc_crc, official_crc);
      printf ("Please check out the problem and correct it.\n\n");
      }

   fprintf (new_file, "%c", '\032');

   return;
}

void close_files (void)
{
   if (old_file)
      fclose (old_file);
   if (new_file)
      fclose (new_file);
   if (new_file)
      fclose (diff_file);

   return;
}

open_infiles (char *nodelist, char *difflist)
{
char           first_line[256], *result;
char           temp[11];
int            a_number, i, j;
struct ffblk   c_file;

   i = findfirst (new_name,&c_file,0);
   if (i == 0)
      {
      printf ("%s already exists.\n", new_name);
      return (1);
      }
   if ((old_file = fopen (nodelist, "rb"))==0)    {
      printf ("Error opening old nodelist file!\n");
      return (1);
      }
   if ((diff_file = fopen (difflist, "rb"))==0)
      {
      printf ("Error opening nodediff file!\n");
      return (1);
      }
   result = fgets (first_line, 256, diff_file);
   for (i = 0; i < 80; i++)
      if (first_line[i] == ':')
         j = i;
   for (i = 0; i < 10; i++)
      temp[i] = first_line[i + j + 1];
   official_crc = atoi (temp);
   j -= 5;
   for (i = 0; i < 5; i++)
      temp[i] = first_line[i + j];
   temp[5] = '\0';
   j = atoi (temp);
   result = strrchr (nodelist, '.');
   result++;
   i = atoi (result);
   if (i != j)
      {
      printf ("NodeDiff doesn't match to existing Nodelist file! Skipping...\n");
      return (1);
      }
   new_file = fopen (new_name, "wb");
   if (new_file == NULL)
      {
      printf ("Can't open new nodelist file!\n");
      return (1);
      }
   printf ("Applying '%s' to '%s'\n", difflist, nodelist);
   return (0);
}

void get_old_name (char *temp_name)
{
char           *temp;
int             i, j, k;
struct ffblk   c_file;

   temp = (char *)malloc (20);

   j = findfirst (temp_name,&c_file,0);
   while (j == 0)  {
      temp = strrchr (c_file.ff_name, '.');
      temp++;
      if (isdigit (*temp) && isdigit (*(temp+1)) && isdigit (*(temp+2)))     {
         i = atoi (temp);
         strcpy (old_name, c_file.ff_name);
         break;
      } else     {
         j = findnext (&c_file);
      }
   }

   while (j == 0)   {
      j = findnext (&c_file);
      temp = strrchr (c_file.ff_name, '.');
      if (temp)   {
         temp++;
         if (isdigit (*temp) &&
             isdigit (*(temp+1)) && 
             isdigit (*(temp+2)))      {
            k = atoi (temp);

            if ((i < k && (k - i) < 300) ||
                (k < i && (k - i) > 300))     {
               i = k;
               strcpy (old_name, c_file.ff_name);
            }
         }
      }
      
   }
   return;
}

get_diff_name (char *temp_name)
{
char           *temp;
int             i, j, k;
struct ffblk   c_file;

   temp = (char *)malloc (80);
   if ((j = findfirst (temp_name,&c_file,0))!=0)      {
      return (1);
   }

   while (j == 0)      {
      temp = strrchr (c_file.ff_name, '.');
      if (temp)   {
         temp++;
         if (isdigit (*temp) && 
             isdigit (*(temp+1)) && 
             isdigit (*(temp+2)))     {
            i = atoi (temp);
            strcpy (diff_name, c_file.ff_name);
            break;
         } else  {
            j = findnext (&c_file);
         }
      }
   }

   if (j != 0)
      return (1);

   while (j == 0)  {
      j = findnext (&c_file);
      temp = strrchr (c_file.ff_name, '.');
      if (temp)   {
         temp++;
         if (isdigit (*temp) && 
             isdigit (*(temp+1)) && 
             isdigit (*(temp+2)))     {
            k = atoi (temp);
            if ((i < k && (k - i) < 300) ||
                (k < i && (k - i) > 300))  {
               i = k;
               strcpy (diff_name, c_file.ff_name);
            }
         }
      }
   }
   temp = strrchr (diff_name, '.');
   temp++;
   strcat (new_name, temp);
   return (0);
}
