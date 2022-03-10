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
/*                   BinkleyTerm Phone list Search Module                   */
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
#include <signal.h>
#include <ctype.h>
#include <conio.h>
#include <string.h>
#include <stdlib.h>

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
#include "com.h"
#include "keybd.h"
#include "ascii.h"
#include "nodeproc.h"

static int SaveScanList( int number );
static void wait_for_keypress( void );

int list_search( void )
{
   int saved_baud;
   long t1;
   int i, k;
   size_t l;
   int dirty;
   ADDR ls_addr;
   unsigned int kbd_input;

   static unsigned int save_chars[] = {
      SHF1, SHF2, SHF3, SHF4, SHF5,
      SHF6, SHF7, SHF8, SHF9, SHF10
   };

   static unsigned int load_chars[] =  {
      ALTF1, ALTF2, ALTF3, ALTF4, ALTF5,
      ALTF6, ALTF7, ALTF8, ALTF9, ALTF10
   };

   static unsigned int command_chars[] = {
      PF1, PF2, PF3, PF4, PF5,
      PF6, PF7, PF8, PF9, PF10
   };

   /*
    * *     Input the phone numbers we want to scan *
    *
    */

   dirty = 1;
   for (;;)
      {
      if (dirty)
         {
         screen_clear ();
         (void) printf (msgtxt[M_PHONE_HELP]);
         (void) printf (msgtxt[M_PHONE_HELP2]);
         if (set_loaded)
            (void) printf (msgtxt[M_LAST_SET],set_loaded);
         (void) printf (msgtxt[M_CURRENT_PHONES]);
         for (k = 0; k < 10; k += 2)
            {
#if 1	/* #ifdef __TOS__ */
            char *s, *s1;
            s = (scan_list[k]) ? scan_list[k] : "";
            s1 = (scan_list[k+1]) ? scan_list[k+1] : "";
            (void) printf ("%2d: %35s %2d: %35s\n",
                     k + 1, s, k + 2, s1);
#else
            (void) printf ("%2d: %35s %2d: %35s\n",
                     k + 1, scan_list[k], k + 2, scan_list[k + 1]);
#endif
            }
         (void) printf (msgtxt[M_INPUT_COMMAND]);
         dirty = 0;
         }

      while (!KEYPRESS ())
         time_release ();
      kbd_input = FOSSIL_CHAR ();

      if (((kbd_input & 0xff) == '\n') || ((kbd_input & 0xff) == '\r'))
         break;

      if ((kbd_input & 0xff) == ESC)
         return (0);

      for (k = 0; k < 10; k++)
         {
         if (kbd_input == save_chars[k])         /* Save into a set?   */
            {
            (void) SaveScanList(k);                     /* Yes, do it         */
            dirty = 1;                           /* Force redisplay    */
            k = 10;                              /* Then fool the logic*/
            break;
            }

         if (kbd_input == load_chars[k])         /* Load from a set?   */
            {
            (void) LoadScanList(k,1);                   /* Yes, do it         */
            dirty = 1;                           /* Force redisplay    */
            k = 10;                              /* Then fool the logic*/
            break;
            }

         if (kbd_input == command_chars[k])      /* Plain old Fkey?    */
            break;                               /* Yup, get out now   */
         }

      if (k == 10)                               /* Not a function key */
         {
         k = (kbd_input & 0xff) - '0';           /* Convert from digit */
         if ((k < 0) || (k > 9))                 /* Was it a digit?    */
            continue;                            /* No, throw char out */
         if (!k)                                 /* Is it a zero?      */
            k = 9;                               /* That's 9 to us     */
         else --k;                               /* Else make zero-rel */
         }

      (void) printf (msgtxt[M_ELEMENT_CHOSEN], k + 1);
      if (scan_list[k] != NULL)
         {
         (void) printf (msgtxt[M_CURRENTLY_CONTAINS], scan_list[k]);
         (void) printf (msgtxt[M_PHONE_HELP3]);
         }
      else
         {
         (void) printf (msgtxt[M_PHONE_HELP4]);
         }
      (void) gets (junk);                               /* Get the user's input */
      ++dirty;                                   /* Always redisplay     */
      if ((l = (int) strlen (junk)) == 0)              /* If nothing there,    */
         continue;                               /* move along           */

      if (l == 1 && *junk == ' ')                /* If just a space...   */
         {
         if (scan_list[k] != NULL)               /* Delete old number    */
            free (scan_list[k]);
         scan_list[k] = NULL;                    /* Clean up the ref     */
         /*      ++dirty;  *//* Force a redisplay    */
         continue;                               /* End this iteration   */
         }

      if (scan_list[k] != NULL)                  /* Get rid of old num   */
         free (scan_list[k]);
      if ((scan_list[k] = malloc (++l)) == NULL) /* Allocate space       */
         {
         (void) printf (msgtxt[M_MEM_ERROR]);
         return (0);                             /* Get out for error    */
         }
      (void) strcpy (scan_list[k], junk);               /* Save new number      */
      /*   ++dirty;     *//* Force a redisplay    */
      }

   /*
    * *     Actual Search logic *
    *
    */
   status_line (msgtxt[M_STARTING_SCAN]);
   for (;;)
      {
      l = 0;
      for (k = 0; k < 10; k++)
         {
         if (scan_list[k] == NULL)
            continue;
         (void) strcpy (junk, scan_list[k]);
         if (!isdigit (junk[0]) && junk[0] != '\"')
            {
            fidouser (junk, &ls_addr);
            if ((ls_addr.Net != -1U) && (ls_addr.Node != -1U) && (ls_addr.Zone != -1U))
               {
               sprintf (junk, "%s", Pretty_Addr_Str (&ls_addr));
               }
            else continue;
            }
         if (strchr (junk, '/') != NULL)
            {
            if (!nodeproc (junk))
               break;
            (void) strcpy (junk, (char *) (newnodedes.PhoneNumber));
            }
         caller = 0;
         saved_baud = baud;
         if (try_1_connect (junk))               /* Attempt to connect     */
            {
            status_line (msgtxt[M_CONNECTED_TO_ITEM], k + 1);
            free (scan_list[k]);
            scan_list[k] = NULL;
            gong ();
            return (1);
            }
         ++l;
         baud = saved_baud;
         MDM_ENABLE (lock_baud && (btypes[baud].rate_value >= lock_baud) ? max_baud.rate_mask : btypes[baud].rate_mask);
         cur_baud = btypes[baud].rate_value;
         t1 = timerset (200);
         while (!timeup (t1))                    /* pause for 2 seconds */
            {
            if (KEYPRESS ())
               {
               i = FOSSIL_CHAR () & 0xff;
               if (i == ESC)                     /* Abort for ESCape    */
                  {
                  status_line (msgtxt[M_CONNECT_ABORTED]);
                  return (0);
                  }
               }
            time_release ();
            }
         }
      if (!l)
         return (0);
      }
}

LoadScanList( int number, int report_errors )
{
    int k;
    size_t l;
    FILE *ScanFile;

    (void) sprintf(junk,"%sBinkScan.LS%c",BINKpath, number + '0');
    if ((ScanFile = fopen(junk, read_binary)) == NULL)
        {
        if (report_errors)
            {
            (void) printf(msgtxt[M_UNABLE_TO_OPEN], junk);
            (void) printf ("\n");
            wait_for_keypress();
            }
        return(0);
        }
    for (k = 0; k < 10; k++)
        {
        if (fread(junk, 36, 1, ScanFile) != 1)
            {
            if (report_errors)
                {
                (void) printf(msgtxt[M_SET_READ_ERROR], number + 1);
                wait_for_keypress();
                }
            (void) fclose(ScanFile);
            return(0);
            }

        if (scan_list[k] != NULL)
            {
            free(scan_list[k]);
            scan_list[k] = NULL;
            }

         l = (int) strlen (junk);
         if (l)
            {
            if ((scan_list[k] = malloc (++l)) == NULL) /* Allocate space    */
                {
                if (report_errors)
                    {
                    (void) printf(msgtxt[M_MEM_ERROR]);
                    wait_for_keypress();
                    }
                (void) fclose(ScanFile);
                return(0);
                }

            (void) strcpy (scan_list[k], junk);               /* Save new number   */
            }
        }
    k = fclose (ScanFile);
    if (report_errors)
        {
        if (k)
            (void) printf(msgtxt[M_SET_CLOSE_ERR], number + 1);
        else
            {
            (void) printf(msgtxt[M_SET_LOADED], number + 1);
            set_loaded = number + 1;
            }
        wait_for_keypress();
        }
    return(k);
}

static SaveScanList( int number )
{
    int k, l;
    FILE *ScanFile;

    (void) sprintf(junk,"%sBinkScan.LS%c",BINKpath, number + '0');
    if ((ScanFile = fopen(junk, write_binary)) == NULL)
        {
        (void) printf(msgtxt[M_UNABLE_TO_OPEN],junk);
        (void) printf ("\n");
        wait_for_keypress();
        return(0);
        }
    for (k = 0; k < 10; k++)
        {
        for (l = 0; l < 36; l++)
            junk[l] = '\0';

        if (scan_list[k] != NULL)
            (void) strcpy(junk,scan_list[k]);

        if (fwrite(junk, 36, 1, ScanFile) != 1)
            {
            (void) printf(msgtxt[M_SET_WRITE_ERROR], number + 1);
            wait_for_keypress();
            (void) fclose(ScanFile);
            return(0);
            }
        }

    l = fclose (ScanFile);
    if (l)
        (void) printf(msgtxt[M_SET_CLOSE_ERR], number + 1);
    else
        {
        (void) printf(msgtxt[M_SET_SAVED], number + 1);
        set_loaded = number + 1;
        }
    wait_for_keypress();
    return(l);
}

static void wait_for_keypress( void )
{
    (void) printf("%s\n", msgtxt[M_PRESS_ENTER]);
    while (!KEYPRESS ())
        time_release ();
    (void) FOSSIL_CHAR ();
}
