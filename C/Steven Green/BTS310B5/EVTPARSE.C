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
/*                 This module was written by Bob Hartman                   */
/*                                                                          */
/*                                                                          */
/*                     BinkleyTerm Scheduler Routines                       */
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
#include <ctype.h>
#ifdef __TOS__
#include <ext.h>
#else
#include <sys/types.h>
#include <sys/stat.h>
#endif
#include <string.h>
#include <stdlib.h>
#ifndef LATTICE
#include <process.h>
#endif
#include <time.h>

#ifdef __TURBOC__
#include "tc_utime.h"
#ifndef __TOS__
#include <alloc.h>
#include <mem.h>
#endif
#else
#ifndef LATTICE
#include <sys/utime.h>
#include <malloc.h>
#include <memory.h>
#endif
#endif

#include "bink.h"
#include "msgs.h"
#include "sched.h"

static char *start_time (BTEVENT *, char *);
static char *end_time (BTEVENT *, char *);


static char *start_time (e, p)
BTEVENT *e;
char *p;
{
   int i, j, k, l, n;

   if ((n = sscanf (p, "%d:%d,%d,%d", &i, &j, &k, &l)) < 2)
      {
      return NULL;
      }

   e->minute = i * 60 + j;
   if ((e->minute < 0) || (e->minute > (24 * 60)))
      {
      return (NULL);
      }

   if (n >= 3)
      e->month = (char)k;
   if (n >= 4)
      e->day = (char)l;

   p = skip_to_blank (p);

   return (p);
}

static char *end_time (e, p)
BTEVENT *e;
char *p;
{
   int i, j, k;

   if (sscanf (p, "%d:%d", &i, &j) != 2)
      {
      return NULL;
      }

   k = i * 60 + j;
   if ((k > (24 * 60)) || (k < 0))
      {
      return (NULL);
      }

   if (k < e->minute)
      {
      (void) printf (msgtxt[M_NO_END_MIDNIGHT]);
      return (NULL);
      }

   e->length = k - e->minute;

   p = skip_to_blank (p);

   return (p);
}

int parse_event (e_line)
char *e_line;
{
   int i, j, j1, j2;
   char *p, *p1, call_slots[100];
   BTEVENT *e;

   /* If we already have a schedule, then forget it */
   if (got_sched)
      return (0);

   /* Skip blanks to get to the days field */
   p = skip_blanks (e_line);

   /* Parse the days field */
   e = (BTEVENT *) calloc (sizeof (BTEVENT), 1);
   memset (e->call_slot, 0, 33);
   e->days = 0;
   e->wait_time = 120;
   while ((*p) && (!isspace (*p)))
      {
      switch (toupper (*p))
         {
         case 'S':                              /* Sunday or Saturday */
            if (!strnicmp (p, "sun", 3))
               {
               e->days |= DAY_SUNDAY;
               }
            else if (!strnicmp (p, "sat", 3))
               {
               e->days |= DAY_SATURDAY;
               }
            else /* Error condition */ 
               {
               goto err;
               }
            p += 3;
            break;

         case 'M':                              /* Monday */
            if (!strnicmp (p, "mon", 3))
               {
               e->days |= DAY_MONDAY;
               }
            else /* Error condition */ 
               {
               goto err;
               }
            p += 3;
            break;

         case 'T':                              /* Tuesday or Thursday */
            if (!strnicmp (p, "tue", 3))
               {
               e->days |= DAY_TUESDAY;
               }
            else if (!strnicmp (p, "thu", 3))
               {
               e->days |= DAY_THURSDAY;
               }
            else /* Error condition */ 
               {
               goto err;
               }
            p += 3;
            break;

         case 'W':                              /* Wednesday, Week or
                                                  * Weekend */
            if (!strnicmp (p, "wed", 3))
               {
               e->days |= DAY_WEDNESDAY;
               p += 3;
               }
            else if (!strnicmp (p, "week", 4))
               {
               e->days |= DAY_WEEK;
               p += 4;
               }
            else if (!strnicmp (p, "wkend", 5))
               {
               e->days |= DAY_WKEND;
               p += 5;
               }
            else /* Error condition */ 
               {
               goto err;
               }
            break;

         case 'F':                              /* Friday */
            if (!strnicmp (p, "fri", 3))
               {
               e->days |= DAY_FRIDAY;
               }
            else /* Error condition */ 
               {
               goto err;
               }
            p += 3;
            break;

         case 'A':                              /* All */
            if (!strnicmp (p, "all", 3))
               {
               e->days |= (DAY_WEEK | DAY_WKEND);
               }
            else /* Error condition */ 
               {
               goto err;
               }
            p += 3;
            break;

         default:                               /* Error condition */
            goto err;
         }

      if (*p == '|')
         ++p;
      }

   /* Did we get something valid? */
   if (e->days == 0)
      {
      goto err;
      }

   /* Skip blanks to get to the start-time field */
   p = skip_blanks (p);

   /* Parse the start-time field */
   if ((p = start_time (e, p)) == NULL)
      {
      (void) printf (msgtxt[M_INVALID_START], e_line);
      free (e);
      return (1);
      }

   /* Give each event a default of 60 minutes */
   e->length = 60;

   /* Give each event a local cost of 0 */
   e->node_cost = 0;

   /* Give each event a default of T=3,10000 */
   e->with_connect = 3;
   e->no_connect = 10000;

   /* While there are still things on the line */
   while (*p)
      {
      /* Skip blanks to get to the next field */
      p = skip_blanks (p);

      /* switch to find what thing is being parsed */
      switch (tolower (*p))
         {
         case '\0':                             /* No more stuff */
            break;

         case '0':                              /* Digits must be an ending
                                                  * time */
         case '1':
         case '2':
         case '3':
         case '4':
         case '5':
         case '6':
         case '7':
         case '8':
         case '9':
            /* Parse ending time */
            if ((p = end_time (e, p)) == NULL)
               {
               (void) printf (msgtxt[M_INVALID_END], e_line);
               free (e);
               return (1);
               }
            break;

         case ';':                              /* Comment */
         case '%':
            *p = '\0';
            break;

         case '"':                              /* Extra chars to append to
                                                  * packer strings */
            ++p;
            p1 = e->cmd;
            *p1++ = ' ';
            while (*p != '"')
               *p1++ = *p++;
            *p1 = '\0';
            ++p;
            break;

         case 'a':                              /* Average wait */
            ++p;
            if (*p == '=')
               {
               ++p;
               if (isdigit (*p))
                  {
                  i = atoi (p);
                  if ((i > 1800) || (i < 0))
                     {
                     (void) printf (msgtxt[M_INVALID_AVGWAIT], e_line);
                     free (e);
                     return (1);
                     }
                  e->wait_time = i;
                  p = skip_to_blank (p);
                  break;
                  }
               }
            (void) printf (msgtxt[M_INVALID_AVGWAIT], e_line);
            free (e);
            return (1);

         case 'b':                              /* BBS type event */
            p = skip_to_blank (p);
            e->behavior |= MAT_BBS;
            break;

         case 'c':                              /* #CM event */
            p = skip_to_blank (p);
            e->behavior |= MAT_CM;
            break;

         case 'd':                              /* Dynamic event */
            p = skip_to_blank (p);
            e->behavior |= MAT_DYNAM;
            break;

         case 'e':                              /* An errorlevel exit */
            ++p;
            if (isdigit (*p))
               {
               i = *p - '0';
               ++p;
               if (*p == '=')
                  {
                  if ((i <= 3) && (i > 0))
                     {
                     ++p;
                     if (isdigit (*p))
                        {
                        j = atoi (p);
                        e->errlevel[i - 1] = j;
                        p = skip_to_blank (p);
                        break;
                        }
                     }
                  else if ((i > 3) && (i <= 9))
                     {
                     ++p;
                     if (isdigit (*p))
                        {
                        j = atoi (p);
                        e->errlevel[i - 1] = j;
                        while (*p && (*p != ','))
                           ++p;
                        ++p;
                        (void) strncpy (&(e->err_extent[i - 4][0]), p, 3);
                        p = skip_to_blank (p);
                        break;
                        }
                     }
                  }
               }
            (void) printf (msgtxt[M_BAD_ERRORLEVEL], e_line);
            free (e);
            return (1);

         case 'f':                              /* Forced event */
            p = skip_to_blank (p);
            e->behavior |= MAT_FORCED;
            break;

         case 'k':                              /* no #CM event */
            p = skip_to_blank (p);
            e->behavior |= MAT_NOCM;
            break;

         case 'l':                              /* Local only mail */
            ++p;
            e->node_cost = 0;
            if (*p == '=')
               {
               ++p;
               if (isdigit (*p))
                  {
                  e->node_cost = atoi (p);
                  }
               }
            else if (*p == '>')
               {
               ++p;
               if (isdigit (*p))
                  {
                  e->node_cost = -atoi (p) - 1;
                  }
               }
            else if (*p == '<')
               {
               ++p;
               if (isdigit (*p))
                  {
                  e->node_cost = atoi (p) - 1;
                  }
               }
            p = skip_to_blank (p);
            e->behavior |= MAT_LOCAL;
            break;

         case 'm':                              /* Mailable 24 hours */
            p = skip_to_blank (p);
            e->behavior |= MAT_NOMAIL24;
            break;

         case 'n':                              /* No requests */
            p = skip_to_blank (p);
            e->behavior |= MAT_NOREQ;
            break;

         case 'r':                              /* Receive only */
            p = skip_to_blank (p);
            e->behavior |= MAT_NOOUT;
            break;

         case 's':                              /* Send only */
            p = skip_to_blank (p);
            e->behavior |= MAT_OUTONLY;
            break;

         case 't':                              /* Tries */
            ++p;
            if (sscanf (p, "=%d,%d", &j1, &j2) != 2)
               {
               (void) printf (msgtxt[M_BAD_TRIES], e_line);
               return (1);
               }
            else
               {
               if ((j1 > 8) || (j1 < 1))
                  {
                  (void) printf (msgtxt[M_BAD_TRIES], e_line);
                  return (1);
                  }
               e->with_connect = j1;
               e->no_connect = j2;
               }
            p = skip_to_blank (p);
            break;

         case 'x':                              /* No outbound requests here */
            p = skip_to_blank (p);
            e->behavior |= MAT_NOOUTREQ;
            break;

#ifdef NEW
		 case '$':
		    p = skip_to_blank(p);
		    e->behavior |= MAT_KILLBAD;
		    break;
		    
		 case 'p':
		    ++p;
            if (sscanf (p, "=%s", call_slots) != 1)
            {
            	(void) printf (msgtxt[M_BAD_POLLSLOT], e_line);
            	return (1);
            }
            else
            {
             	strncpy (e->call_slot, call_slots, 32);
            }
            p = skip_to_blank (p);
            break;
#endif

         default:                               /* Error condition */
            (void) printf (msgtxt[M_INDECIPHERABLE], e_line);
            free (e);
            return (1);
         }
      }

   /* Save it in the array  of pointers */
   e_ptrs[num_events++] = e;

   /* Return that everything is cool */
   return (0);

err:
   (void) printf (msgtxt[M_BAD_DAY], e_line);
   free (e);
   return (1);
}
