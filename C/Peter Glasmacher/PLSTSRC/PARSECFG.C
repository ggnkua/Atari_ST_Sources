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
#  include <ext.h>
#include <string.h>
#include <ctype.h>
#include <time.h>

#include "types.h"
#include "externs.h"
#include "pl.h"

static char t_buff[128];

parse_config (filename, mylist, pvtlist)
char *filename;
char *mylist;
char *pvtlist;
{
   FILE *f1;
   PWTRP tpw;
   PHTRP tph;
   BDTRP tbd;
   DLTRP tdl;
   COTRP tco;
   ETTRP tet;
   CMTRP tcm;
   FNLSTP tfn;
   int foo1;
   char *p, *p1, *p2, *p3;
   extern char *strchr();

   /* Need to read in the configuration options from control file */
   if ((f1 = fopen (filename, "r")) != NULL)      {
      strupr (filename);
      printf ("Processing Configuration File '%s'\n", filename);

      if(mylist)         {
         tfn = (FNLSTP) mymalloc (sizeof (FNLST));
         tfn->fname = mymalloc (64);
         tfn->fname=mylist;
         mylist=NULL;
         strupr (tfn->fname);
         tfn->next = NULL;
         tfn->private = 1;
         fn->next = tfn;
         fn = tfn;
      }

      if(pvtlist)   {
         tfn = (FNLSTP) mymalloc (sizeof (FNLST));
         tfn->fname = mymalloc (64);
         tfn->fname=pvtlist;
         strupr (tfn->fname);
         pvtlist=NULL;
         tfn->next = NULL;
         tfn->private = 1;
         fn->next = tfn;
         fn = tfn;
      }

      while (fgets (t_buff, 127, f1) != NULL)     {
         if ((p3 = strchr (t_buff, ';')) != NULL)
            *p3 = '\0';

         p2 = t_buff;
         while ((*p2) && (isspace (*p2)))   {
            ++p2;
         }

         if ((*p2 == ';') || isspace (*p2) || (*p2 == '\0'))
            continue;

         if (strnicmp (p2, "publist", 7) == 0)   {
            printf ("PUBLIST statement not supported\n");
            continue;
         }
         if (strnicmp (p2, "cleanup", 7) == 0)        {
            printf ("CLEANUP statement not supported\n");
            continue;
         }
         if (strnicmp (p2, "ozone", 5) == 0)
            {
            printf ("OZONE statement not supported\n");
            continue;
            }
         if (strnicmp (p2, "addr", 4) == 0)
            {
            printf ("ADDR statement not supported\n");
            continue;
            }
         if (strnicmp (p2, "points", 6) == 0)
            {
            printf ("POINTS statement not supported\n");
            continue;
            }
         if (strnicmp (p2, "index", 5) == 0)
            {
            printf ("INDEX statement not supported\n");
            continue;
            }
         if (strnicmp (p2, "sindex", 6) == 0)
            {
            printf ("SINDEX statement not supported\n");
            continue;
            }

         if (strnicmp (p2, "fidoprn", 7) == 0)
            {
            fidoprn = 1;
            continue;
            }
         if (strnicmp (p2, "fidotxt", 7) == 0)
            {
            fidotxt = 1;
            continue;
            }
         if (strnicmp (p2, "nofidolist", 10) == 0)
            {
            fidoprn = 0;
            fidotxt = 0;
            continue;
            }
         if (strnicmp (p2, "noindex", 7) == 0)
            {
            do_index = 0;
            continue;
            }
         if (strnicmp (p2, "nopoints", 8) == 0)
            {
            do_points = 0;
            continue;
            }
         if ((strnicmp (p2, "seadog", 6) == 0) ||
             (strnicmp (p2, "gated", 5) == 0))
            {
            out_type = 1;
            continue;
            }
         if ((strnicmp (p2, "fido", 4) == 0) ||
             (strnicmp (p2, "opus", 4) == 0) ||
             (strnicmp (p2, "binkley", 7) == 0) ||
             (strnicmp (p2, "complete", 8) == 0))
            {
            out_type = 0;
            continue;
            }
         if ((strnicmp (p2, "newopus", 7) == 0) || (strnicmp (p2, "version6", 8) == 0))
            {
            newopus = 1;
            continue;
            }
         if ((strnicmp (p2, "oldopus", 7) == 0) || (strnicmp (p2, "version5", 8) == 0))
            {
            oldopus = 1;
            continue;
            }
         if (strnicmp (p2, "tbbslist", 8) == 0)
            {
            sealist = 1;
            continue;
            }
         if (strnicmp (p2, "binklist", 8) == 0)
            {
            binkley = 1;
            continue;
            }
         if (strnicmp (p2, "quickbbslist", 12) == 0)
            {
            quickbbs = 1;
            continue;
            }
	 if (strnicmp (p2, "STarNodelist",12) == 0)  {
	    starnet = 1;
        continue;
            }
         if (strnicmp (p2, "igate", 5) == 0)
            {
            tet = (ETTRP) mymalloc (sizeof (ETTR));
            get_addr (&p2[5], &(tet->zone), &(tet->net), &(tet->node));
            tet->etype = 'I';
            tet->next = NULL;
            if (et_head == NULL)
               {
               et_head = tet;
               }
            else
               {
               et->next = tet;
               }
            et = tet;
            continue;
            }
         if (strnicmp (p2, "ogate", 5) == 0)
            {
            tet = (ETTRP) mymalloc (sizeof (ETTR));
            get_addr (&p2[5], &(tet->zone), &(tet->net), &(tet->node));
            tet->etype = 'O';
            tet->next = NULL;
            if (et_head == NULL)
               {
               et_head = tet;
               }
            else
               {
               et->next = tet;
               }
            et = tet;
            continue;
            }
         if (strnicmp (p2, "gate", 4) == 0)
            {
            tet = (ETTRP) mymalloc (sizeof (ETTR));
            get_addr (&p2[4], &(tet->zone), &(tet->net), &(tet->node));
            tet->etype = 'G';
            tet->next = NULL;
            if (et_head == NULL)
               {
               et_head = tet;
               }
            else
               {
               et->next = tet;
               }
            et = tet;
            continue;
            }
         if (strnicmp (p2, "hub", 3) == 0)
            {
            tet = (ETTRP) mymalloc (sizeof (ETTR));
            get_addr (&p2[3], &(tet->zone), &(tet->net), &(tet->node));
            tet->etype = 'H';
            tet->next = NULL;
            if (et_head == NULL)
               {
               et_head = tet;
               }
            else
               {
               et->next = tet;
               }
            et = tet;
            continue;
            }
         if (strnicmp (p2, "include", 7) == 0)
            {
            p = &p2[7];
            while ((*p) && isspace (*p))
               {
               ++p;
               }

            p1 = p;
            while ((*p) && (!isspace (*p)))
               {
               ++p;
               }
            *p = '\0';

            parse_config (p1, mylist, pvtlist);
            printf ("Continuing Processing on File '%s'\n", filename);
            continue;
            }
         if (strnicmp (p2, "comments", 8) == 0)
            {
            comments = 1;
            continue;
            }
         if (strnicmp (p2, "nocomments", 10) == 0)
            {
            comments = 0;
            continue;
            }
         if (strnicmp (p2, "usezone", 7) == 0)
            {
            usezone = 1;
            continue;
            }
         if (strnicmp (p2, "report", 6) == 0)
            {
            doreport = 1;
            continue;
            }
         if (strnicmp (p2, "noreport", 8) == 0)
            {
            doreport = 0;
            continue;
            }
         if (strnicmp (p2, "dash", 4) == 0)
            {
            nodash = 0;
            continue;
            }
         if (strnicmp (p2, "nodash", 6) == 0)
            {
            nodash = 1;
            continue;
            }
         if (strnicmp (p2, "nonodelist", 10) == 0)
            {
            nlist = 0;
            continue;
            }
         if (strnicmp (p2, "nodelist", 8) == 0)
            {
            nlist = 1;
            continue;
            }
         if (strnicmp (p2, "nouserlist", 10) == 0)
            {
            udata = 0;
            continue;
            }
         if (strnicmp (p2, "userlist", 8) == 0)
            {
            udata = 2;
            continue;
            }
         if (strnicmp (p2, "interlist", 9) == 0)
            {
            udata = 1;
            continue;
            }
         if (strnicmp (p2, "node", 4) == 0)
            {
            if (sscanf (&p2[4], "%d:%d/%d", &myzone, &mynet, &mynode) != 3)
               {
               myzone = -1;
               if (sscanf (&p2[4], "%d/%d", &mynet, &mynode) != 2)
                  {
                  continue;
                  }
               }
            continue;
            }
         if (strnicmp (p2, "route", 5) == 0)
            {
            rdata = 1;
            continue;
            }
         if (strnicmp (p2, "noroute", 7) == 0)
            {
            rdata = 0;
            continue;
            }
         if (strnicmp (p2, "country", 7) == 0)
            {
            sscanf (&p2[7], "%s", country);
            continue;
            }
         if (strnicmp (p2, "mylist", 6) == 0)
            {
            tfn = (FNLSTP) mymalloc (sizeof (FNLST));
            tfn->fname = mymalloc (64);
            sscanf (&p2[7], "%s", tfn->fname);
            strupr (tfn->fname);
            tfn->next = NULL;
            tfn->private = 0;
            fn->next = tfn;
            fn = tfn;
            continue;
            }
         if (strnicmp (p2, "pvtlist", 7) == 0)
            {
            tfn = (FNLSTP) mymalloc (sizeof (FNLST));
            tfn->fname = mymalloc (64);
            sscanf (&p2[7], "%s", tfn->fname);
            strupr (tfn->fname);
            tfn->next = NULL;
            tfn->private = 1;
            fn->next = tfn;
            fn = tfn;
            continue;
            }
         if (strnicmp (p2, "maxbaud", 7) == 0)
            {
            maxbaud = atoi (&p2[7]);
            continue;
            }
         if (strnicmp (p2, "phone", 5) == 0)
            {
            tph = (PHTRP) mymalloc (sizeof (PHTR));
            tph->num = mymalloc (30);
            if (sscanf (&p2[5], "%d:%d/%d %s", &(tph->zone), &(tph->net), &(tph->node), tph->num) != 4)
               {
               tph->zone = myzone;
               sscanf (&p2[5], "%d/%d %s", &(tph->net), &(tph->node), tph->num);
               }
            tph->next = NULL;
            if (ph_head == NULL)
               {
               ph_head = tph;
               }
            else
               {
               ph->next = tph;
               }
            ph = tph;
            continue;
            }
         if (strnicmp (p2, "password", 8) == 0)
            {
            tpw = (PWTRP) mymalloc (sizeof (PWTR));
            tpw->pw = mymalloc (30);
            if (sscanf (&p2[8], "%d:%d/%d %s", &(tpw->zone), &(tpw->net), &(tpw->node), &(tpw->pw[1])) != 4)
               {
               sscanf (&p2[8], "%d/%d %s", &(tpw->net), &(tpw->node), &(tpw->pw[1]));
               tpw->zone = myzone;
               }
            tpw->pw[0] = '!';
            strlwr (tpw->pw);
            tpw->next = NULL;
            if (pw_head == NULL)
               {
               pw_head = tpw;
               }
            else
               {
               pw->next = tpw;
               }
            pw = tpw;
            continue;
            }
         if (strnicmp (p2, "cm", 2) == 0)
            {
            tcm = (CMTRP) mymalloc (sizeof (CMTR));
            get_addr (&p2[2], &(tcm->zone), &(tcm->net), &(tcm->node));
            tcm->next = NULL;
            if (cm_head == NULL)
               {
               cm_head = tcm;
               }
            else
               {
               cm->next = tcm;
               }
            cm = tcm;
            continue;
            }
         if (strnicmp (p2, "baud", 4) == 0)
            {
            tbd = (BDTRP) mymalloc (sizeof (BDTR));
            if (sscanf (&p2[4], "%d:%d/%d %d", &(tbd->zone), &(tbd->net), &(tbd->node), &(tbd->baud)) != 4)
               {
               sscanf (&p2[4], "%d/%d %d", &(tbd->net), &(tbd->node), &(tbd->baud));
               tbd->zone = myzone;
               }
            tbd->next = NULL;
            if (bd_head == NULL)
               {
               bd_head = tbd;
               }
            else
               {
               bd->next = tbd;
               }
            bd = tbd;
            continue;
            }
         if (strnicmp (p2, "dial", 4) == 0)
            {
            /* Save the defaults */
            strcpy (t_str, &p2[4]);

            while (fgets (t_buff, 127, f1) != NULL)
               {
               p2 = t_buff;
               if ((p3 = strchr (p2, ';')) != NULL)
                  *p3 = '\0';

               while (isspace (*p2) && *p2)
                  ++p2;

               if (strnicmp (p2, "end", 3) == 0)
                  {
                  break;
                  }

               /* Process each line of dial */
               p = p2;
               while ((*p) && (isspace (*p)))
                  {
                  ++p;
                  }

               if ((*p == ';') || (*p == '\0'))
                  {
                  continue;
                  }

               tdl = (DLTRP) mymalloc (sizeof (DLTR));
               tdl->mstr = mymalloc (30);
               tdl->pre  = mymalloc (30);
               tdl->post = mymalloc (30);

               p1 = tdl->mstr;
               while ((*p) && (!isspace (*p)))
                  {
                  *p1++ = *p++;
                  }
               *p1 = '\0';

               while ((*p) && (isspace (*p)))
                  {
                  ++p;
                  }

               p1 = tdl->pre;
               while ((*p) && (*p != '/') && (!isspace(*p)))
                  {
                  *p1++ = *p++;
                  }
               *p1 = '\0';

               p1 = tdl->post;
               if ((*p == '\0') || (isspace (*p)))
                  {
                  *p1 = '\0';
                  }
               else
                  {
                  ++p;

                  while ((*p) && (!isspace (*p)))
                     {
                     *p1++ = *p++;
                     }
                  *p1 = '\0';
                  }

               tdl->mlen = strlen (tdl->mstr);
               tdl->next = NULL;
               if (dl_head == NULL)
                  {
                  dl_head = tdl;
                  }
               else
                  {
                  dl->next = tdl;
                  }
               dl = tdl;
               }

            tdl = (DLTRP) mymalloc (sizeof (DLTR));
            tdl->mstr = country;
            tdl->mlen = strlen (country);
            tdl->next = NULL;
            tdl->pre  = mymalloc (30);
            tdl->post = mymalloc (30);

            p = t_str;
            while ((*p) && (isspace (*p)))
               {
               ++p;
               }

            p1 = tdl->pre;
            while ((*p) && (*p != '/') && (!isspace(*p)))
               {
               *p1++ = *p++;
               }
            *p1 = '\0';
            strcat (tdl->pre, country);

            p1 = tdl->post;
            if ((*p == '\0') || (isspace (*p)))
               {
               *p1 = '\0';
               }
            else
               {
               ++p;

               while ((*p) && (!isspace (*p)))
                  {
                  *p1++ = *p++;
                  }
               *p1 = '\0';
               }

            while ((*p) && (isspace (*p)))
               {
               ++p;
               }

            p1 = intl_pre_dl;
            while ((*p) && (*p != '/') && (!isspace(*p)))
               {
               *p1++ = *p++;
               }
            *p1 = '\0';

            p1 = intl_post_dl;
            if ((*p == '\0') || (isspace (*p)))
               {
               *p1 = '\0';
               }
            else
               {
               ++p;

               while ((*p) && (!isspace (*p)))
                  {
                  *p1++ = *p++;
                  }
               *p1 = '\0';
               }

            if (dl_head == NULL)
               {
               dl_head = tdl;
               }
            else
               {
               dl->next = tdl;
               }
            dl = tdl;

            continue;
            }
         if (strnicmp (p2, "cost", 4) == 0)
            {
            /* Save the defaults */
            strcpy (t_str, p2);
            sscanf (&t_str[4], "%d %d", &foo1, &intl_cost);

            while (fgets (p2, 127, f1) != NULL)
               {
               if ((p3 = strchr (p2, ';')) != NULL)
                  *p3 = '\0';

               if (strnicmp (p2, "end", 3) == 0)
                  {
                  break;
                  }

               p = p2;
               while ((*p) && (isspace (*p)))
                  {
                  ++p;
                  }

               /* Process each line of cost */
               if ((*p == ';') || (*p == '\0'))
                  {
                  continue;
                  }

               tco = (COTRP) mymalloc (sizeof (COTR));
               tco->mstr = mymalloc (30);
               tco->cost = foo1;
               tco->baud = 0;

               if (sscanf (p, "%s %d %d\n", tco->mstr, &(tco->cost), &(tco->baud)) == 1)
                  {
                  tco->cost = foo1;
                  tco->baud = 0;
                  }

               tco->mlen = strlen (tco->mstr);
               tco->next = NULL;
               if (co_head == NULL)
                  {
                  co_head = tco;
                  }
               else
                  {
                  co->next = tco;
                  }
               co = tco;
               }

            tco = (COTRP) mymalloc (sizeof (COTR));
            tco->mstr = country;
            tco->mlen = strlen (country);
            sscanf (&t_str[4], "%d %d", &(tco->cost), &intl_cost);
            tco->baud = 0;
            tco->next = NULL;
            if (co_head == NULL)
               {
               co_head = tco;
               }
            else
               {
               co->next = tco;
               }
            co = tco;

            continue;
            }
         printf ("Cannot decipher line:\n%s", p2);
         }
      fclose (f1);
      }
}
