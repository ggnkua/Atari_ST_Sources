/************************************************************************
*************************************************************************
**                                                                     **
**   This Module is part of the ATARI ST Implementation of Parselst.   **
**   Parselst was ported to provide a general Nodelist Compiler for    **
**   ATARI/ST Implementation of BinkleyTerm.                           **
**   Bob Hartman, the Author of the original PARSELST is not involved  **
**   with this particular implementation, beside providing a lot of    **
**   work, writing the original code and give it to the community.     **
**                                                                     **
**   All rules and regulations Bob explains below apply to this port.  **
**   However, for questions regarding the ST Version, please direct    **
**   your Questions to                                                 **
**                                                                     **
**   Peter Glasmacher                   FidoNet 1:143/9 1:143/90       **                                
**   2250 Monroe ST #123                Ph. (408)985-1538              **
**   Santa Clara,CA 95050                                              **
**                                                                     **
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
#include <ctype.h>
#include <time.h>
#include <string.h>
#include <stdlib.h>
#ifdef ST
#  include <ext.h>
#else
#include <fcntl.h>
#endif

/* Should we generate an Opus style nodelist output */

#include "types.h"
#include "externs.h"
#include "pl.h"


char           *REV = "$Revision: 1.30 $";      /* Used in my code for my RCS
                                                 * program */

struct _node    new_node;
struct _oldnode old_node;
struct netls    seanet;
struct nodels   seanode;
struct extrastuff bt_node;
struct nidxs   *seaidx;
struct nidxs   *seaptr;
struct qidx     qbbsidx;
struct qdat     qbbsnode;
struct starlist starnode;
struct dex      starinx;
int lnet = 0;
int lzone = 0;
long            seanodecnt;
int             seacnt;
long            seanetcnt;

char            buf[256];
char            prn_first_line[256];
char            txt_first_line[256];
int             prn_pg_lines;
int             txt_pg_lines;
int             prn_pagenum;
int             txt_pagenum;
int             cmdbaud = 0;

static FILE    *nodelist_bbs, *nodelist_fon, *fidouser_SS1;
static int     nodelist_dat, nodelist_idx, nodelist_sys;
static FILE    *nodelist_prn, *nodelist_txt;
static int     netlist_dog, nodelist_dog, index_dog;
static int     nodelist_ext;
static int     qnl_idx_bbs, qnl_dat_bbs;
static int     fdstarnl,fdstarinx;
extern int     cmp();

/*----------------------------------------------------------------------*
* Nodelist entrytypes used by STarNet                                   *
*-----------------------------------------------------------------------*/
char *modif[] =  { 
   "REGION","HOST","HUB","PVT","HOLD","DOWN","KENL","ZONE",""
};

#define SNORMAL 0
#define SREGION 1
#define SHOST   2
#define SHUB    3
#define SPVT    4
#define SHOLD   5
#define SDOWN   6 
#define SKENL   7
#define SZONE   8

main (int argc, char *argv[])
{
char         buff1[20], buff2[20];        /* Junk buffers */
char         *s,*config_file ="PARSELST.CFG";
char         *mylist=NULL,*pvtlist=NULL;
char         *nodelist,editnl=0,cl_nodelist=0;
int           i;

   sscanf (REV, "$%s %s", buff1, buff2);
   fprintf (stderr, "ParseLst - %s %s by Bob Hartman, SysOp of FidoNet Node 1:132/101\n", buff1, buff2);
   fprintf (stderr, "This program is placed in the  Public Domain  as part of the BBS project.\n");
   fprintf (stderr, "For information on BBS (Bit Bucket Software), contact 132/101 or 141/491.\n");
   fprintf (stderr, "For information on BBS Ports to the \033pATARI ST\033q Line of Computers, contact\n");
   fprintf (stderr, "Peter Glasmacher at 1:143/9 \n\n");

   if (argc > 1){
       for (i=1;i<argc;i++) {
         s=argv[i];
         if ((s[0] == '/') || (s[0] == '-')) {
            switch(tolower(s[1])) {

               case 'e' :    editnl++;
                                 break;

               case 'n' :    nodelist=(s+2);
                                 strupr(nodelist);
                                 cl_nodelist++;
                                 break;

               case 'c' :    config_file=s+2;
                                 strupr (config_file);
                                 break;

               case 'm' :   mylist=(s+2);
                                strupr(mylist);
                                break;

               case 'p' :   pvtlist=s+2;
                                strupr(pvtlist);
                                break;

               case 'b' :   cmdbaud=atoi(&s[2]);
                                break;

               case 'w' :   wait = 1;       /* wait at end of prog  */
                              break;
               default:      printf("Don't understand %s\n\n",s);
                                 break;

            }
         }
      }
   }
   if (editnl > 0) {
      printf ("Using EditNL to update Nodelist\n");
      system ("EditNL");
      printf ("\n");
   } else
      edit();

   strcpy (country, "1");

   /*-------------------------------------------------------------------*
   * Need to find the correct file to use                               *
   *--------------------------------------------------------------------*/

   fn = &fn_head;
   if (cl_nodelist > 0)   {
      fn->fname = nodelist;
      strupr (fn->fname);
   }  else   {
      nfile_name (&(fn->fname));
   }
   fn->next = NULL;
   fn->private = 0;

   ph = ph_head;
   bd = bd_head;
   dl = dl_head;
   co = co_head;
   et = et_head;

   /*-------------------------------------------------------------------*
   * Parse configuration file                                           *
   *--------------------------------------------------------------------*/

   parse_config (config_file,mylist,pvtlist);

   if (cmdbaud > 0)
      maxbaud = cmdbaud;

   open_outfiles ();                    /* Open output files            */

   if (out_type == -1) {                /* Set up the output type       */
      if (myzone > 0)
         out_type = 0;
      else
         out_type = 1;
   }

   fn = &fn_head;
   while (fn != NULL) {
      process_file (1);
   }

   /*-------------------------------------------------------------------*
   * Close all the files                                                *
   *--------------------------------------------------------------------*/

   if (nodelist_bbs != NULL) {
      fclose (nodelist_bbs);
   }
   if (nodelist_fon != NULL) {
      fclose (nodelist_fon);
   }
   if (fidouser_SS1 != NULL) {
      fclose (fidouser_SS1);
    }
   if (nodelist_dat != -1) {
      close (nodelist_dat);
   }
   if (nodelist_sys != -1) {
      close (nodelist_sys);
   }
   if (nodelist_idx != -1) {
      close (nodelist_idx);
   }
   if (nodelist_ext != -1) {
      close (nodelist_ext);
   }
   if (nodelist_prn != NULL) {
      fclose (nodelist_prn);
   }
   if (nodelist_txt != NULL) {
      fclose (nodelist_txt);
   }
   if (nodelist_dog != -1) {
      close (nodelist_dog);
   }
   if (qnl_idx_bbs != -1) {
      close (qnl_idx_bbs);
   }
   if (qnl_dat_bbs != -1) {
      close (qnl_dat_bbs);
   }
   /*-------------------------------------------------------------------*
   *--------------------------------------------------------------------*/
   if (fdstarnl != -1) {
      close (fdstarnl);
   }
   if (fdstarinx != -1) {
      close (fdstarinx);
   }
   if (netlist_dog != -1) {
      if (seanet.numnodes) {
         write (netlist_dog, &seanet, sizeof (struct netls));
      }
      close (netlist_dog);

      if (seaidx != NULL) {
         printf ("\nSorting for INDEX.DOG\n"); qsort (seaidx, seacnt, sizeof (struct nidxs), cmp);
         unlink ("INDEX.DOG");
         if ((index_dog = open ("INDEX.DOG", O_WRONLY|O_BINARY|O_CREAT)) == -1) {
            printf ("Error opening INDEX.DOG - not generated\n");
            unlink ("INDEX.DOG");
         } else {
            write (index_dog, seaidx, sizeof (struct nidxs) * seacnt);
            close (index_dog);
         }
      } else {
         /*-------------------------------------------------------------*
         * Have to get rid of this to make sure no one gets confused    *
         *--------------------------------------------------------------*/
         unlink ("INDEX.DOG");
      }
   }

   printf ("\rProcessing Completed Without Errors.\n\n");

   /*-------------------------------------------------------------------*
   * Do any additional processing that might be needed                  *
   *--------------------------------------------------------------------*/

   if (doreport) {
      size_report ();
   }

   if (fidouser_SS1 != NULL)   {
      do_names ();
   }
   exit(0);
}

void open_outfiles ()
{
int             i;

   if (nlist) {
      if ((nodelist_bbs = fopen ("NODELIST.BBS", "w")) == NULL) {
         printf ("Error opening output file\n");
         exit (1);
      }
   } else {
      nodelist_bbs = NULL;
   }

   /*-------------------------------------------------------------------*
   * Open the NODELIST.FON file?                                        *
   *--------------------------------------------------------------------*/

   if (rdata) {
      if ((nodelist_fon = fopen ("NODELIST.FON", "w")) == NULL) {
         printf ("Error opening NODELIST.FON - not generated\n");
      }
   } else {
      nodelist_fon = NULL;
   }

   /*-------------------------------------------------------------------*
   * Open the Fidouser.SS1 file                                         *
   *--------------------------------------------------------------------*/

   if (udata) {
      if ((fidouser_SS1 = fopen ("FIDOUSER.$$1", "w")) == NULL) {
         printf ("Error opening FIDOUSER$$.1 - not generated\n");
      }
   } else {
      fidouser_SS1 = NULL;
   }

   nodelist_dat = -1;
   nodelist_idx = -1;

   if (newopus) {
      unlink ("NODELIST.DAT");
      if ((nodelist_dat = open ("NODELIST.DAT", O_WRONLY|O_BINARY|O_CREAT)) == -1) {
         printf ("Error opening NODELIST.DAT - not generated\n");
      } else {
         unlink ("NODELIST.IDX");
         if ((nodelist_idx = open ("NODELIST.IDX", O_WRONLY|O_BINARY|O_CREAT)) == -1) {
            printf ("Error opening NODELIST.IDX - NODELIST.DAT not generated\n");
            close (nodelist_dat);
            nodelist_dat = -1;
         } else {
            /*----------------------------------------------------------*
            * Write out the start of the .SYS file                      *
            *-----------------------------------------------------------*/
            memset (&new_node, 0, sizeof (struct _node));
            new_node.number = 6;
            new_node.net = -1;
            strcpy (new_node.name, "ParseLst");
            strcpy (new_node.city, "1:132/101 in Nashua, NH USA");
            write (nodelist_dat, &new_node, sizeof (struct _node));

            /*----------------------------------------------------------*
            * Write out the start of the .IDX file                      *
            *-----------------------------------------------------------*/

            i = 5;
            write (nodelist_idx, &i, sizeof (int));
            i = -1;
            write (nodelist_idx, &i, sizeof (int));
         }
      }
   } else {
      nodelist_dat = -1;
      nodelist_idx = -1;
   }

   nodelist_sys = -1;

   if (oldopus) {
      unlink ("NODELIST.SYS");
      if ((nodelist_sys = open ("NODELIST.SYS", O_WRONLY|O_BINARY|O_CREAT)) == -1) {
         printf ("Error opening NODELIST.SYS - not generated\n");
      } else {
         if (nodelist_idx == -1) {
            unlink ("NODELIST.IDX");
            if ((nodelist_idx = open ("NODELIST.IDX", O_WRONLY|O_BINARY|O_CREAT)) == -1) {
               printf ("Error opening NODELIST.IDX - NODELIST.SYS not generated\n");
               close (nodelist_sys);
               nodelist_sys = -1;
            } else {
               /*-------------------------------------------------------*
               * Write out the start of the .IDX file                   *
               *--------------------------------------------------------*/

               i = 5;
               write (nodelist_idx, &i, sizeof (int));
               i = -1;
               write (nodelist_idx, &i, sizeof (int));
            }
         }

         /*-------------------------------------------------------------*
         * Write out the start of the .SYS file                         *
         *--------------------------------------------------------------*/
         memset (&old_node, 0, sizeof (struct _oldnode));
         old_node.number = 5;
         old_node.net = -1;
         strcpy (old_node.name, "ParseLst");
         strcpy (old_node.city, "1:132/101 in Nashua, NH USA");
         write (nodelist_sys, &old_node, sizeof (struct _oldnode));
      }
   } else {
      nodelist_sys = -1;
   }

   nodelist_ext = -1;

   if (binkley) {
      unlink ("NODELIST.EXT");
      if ((nodelist_ext = open ("NODELIST.EXT", O_WRONLY|O_BINARY|O_CREAT)) == -1) {
         printf ("Error opening NODELIST.EXT - not generated\n");
      } else {
         if (nodelist_idx == -1) {
            unlink ("NODELIST.IDX");
            if ((nodelist_idx = open ("NODELIST.IDX", O_WRONLY|O_BINARY|O_CREAT)) == -1) {
               printf ("Error opening NODELIST.IDX - NODELIST.EXT not generated\n");
               close (nodelist_ext);
               nodelist_ext = -1;
            } else {
               /*-------------------------------------------------------*
               * Write out the start of the .IDX file                   *
               *--------------------------------------------------------*/

               i = 7;
               write (nodelist_idx, &i, sizeof (int));
               i = -1;
               write (nodelist_idx, &i, sizeof (int));
            }
         }

         /*-------------------------------------------------------------*
         * Write out the start of the .EXT file                         *
         *--------------------------------------------------------------*/

         memset (&bt_node, 0, sizeof (struct extrastuff));
         strcpy (bt_node.password, "ParseLst");
         write (nodelist_ext, &bt_node, sizeof (struct extrastuff));
      }
   } else {
      nodelist_ext = -1;
   }

   if (sealist) {
      unlink ("NODELIST.DOG");
      if ((nodelist_dog = open ("NODELIST.DOG", O_WRONLY|O_BINARY|O_CREAT)) == -1) {
         printf ("Error opening NODELIST.DOG - not generated\n");
      } else {
         unlink ("NETLIST.DOG");
         if ((netlist_dog = open ("NETLIST.DOG", O_WRONLY|O_BINARY|O_CREAT)) == -1) {
            printf ("Error opening NETLIST.DOG - NODELIST.DOG not generated\n");
            close (nodelist_dog);
            nodelist_dog = -1;
            seanetcnt = sizeof (struct netls);
         } else {
            /*----------------------------------------------------------*
            * Write out the start of the NETLIST.DOG file               *
            *-----------------------------------------------------------*/

            memset (&seanet, 0, sizeof (struct netls));
            write (netlist_dog, &seanet, sizeof (struct netls));
         }
      }

      if ((seaidx = calloc (sizeof (struct nidxs), 4000)) == NULL) {
         printf ("Could not allocate space for INDEX.DOG - not generating\n");
         seaptr = NULL;
      } else {
         seaptr = seaidx;
      }
   } else {
      nodelist_dog = -1;
      netlist_dog = -1;
   }

   if (quickbbs) {
      unlink ("QNL_DAT.BBS");
      if ((qnl_dat_bbs = open ("QNL_DAT.BBS", O_WRONLY|O_BINARY|O_CREAT)) == -1) {
         printf ("Error opening QNL_DAT.BBS - not generated\n");
      } else {
         unlink ("QNL_IDX.BBS");
         if ((qnl_idx_bbs = open ("QNL_IDX.BBS", O_WRONLY|O_BINARY|O_CREAT)) == -1) {
            printf ("Error opening QNL_IDX.BBS - QNL_DAT.BBS not generated\n");
            close (qnl_dat_bbs);
            qnl_dat_bbs = -1;
         }
      }
   } else {
      qnl_idx_bbs = -1;
      qnl_dat_bbs = -1;
   }

   /*-------------------------------------------------------------------*
   *--------------------------------------------------------------------*/

   if (starnet ) {
      unlink ("NODELIST.DAT");
      if ((fdstarnl = open ("NODELIST.DAT", O_WRONLY|O_BINARY|O_CREAT)) == -1) {
         printf ("Error opening Nodelist.DAT - not generated\n");
      } else {
         unlink ("NODELIST.INX");
         if ((fdstarinx = open ("NODELIST.INX", O_WRONLY|O_BINARY|O_CREAT)) == -1) {
            printf ("Error opening NODELIST.INX - NODELIST.BBS not generated\n");
            close (fdstarnl);
            fdstarnl = -1;
         }
      }
   } else {
      fdstarnl = -1;
      fdstarinx = -1;
   }

   if (fidoprn) {
      if ((nodelist_prn = fopen ("NODELIST.PRN", "w")) != NULL)
         prn_pg_lines = 100;
   }
   if (fidotxt) {
      if ((nodelist_txt = fopen ("NODELIST.TXT", "w")) != NULL)
         txt_pg_lines = 100;
   }
}

/*----------------------------------------------------------------------*
*-----------------------------------------------------------------------*/
void process_file (times)
int             times;
{
char *ret;
int             n_num;
int             n_cost;
int             n_baud;
int             node;
int             addrs[4];
char            this_file[64];
char            def_phone[30];
char            def_flags[30];
int             def_cost;
int             def_baud;
int             cur_addr_lev;
int             did_cost;
int             i;
int             did_phone;
int             done;
char            buff[128];
/*   int             f;*/
FILE           *f;
char           *p, *p1, *p2, *p3;
int             dphone;
char            b1[50];
char            b2[50];
char            b3[50];
char            b4[50];
char            b5[50];
char            b6[50];
char            b7[128];
char            pn1[10], pn2[10], pn3[10];
char            orig_phone[30];
int             pvt, hold, skip, def, n_out, this_list;
PWTRP           tpw;
PHTRP           tph;
BDTRP           tbd;
DLTRP           tdl;
COTRP           tco;
ETTRP           tep;
FNLSTP          tfn;
char            ntyp;
char           *mymalloc ();
extern char    *strchr ();
int startype;
unsigned long starpos;

   if (starnet)
      starpos = lnet = 0;

   /*-------------------------------------------------------------------*
   * Open the next filename                                             *
   *--------------------------------------------------------------------*/
   f = NULL;
   cur_addr_lev = 0;
   if ((f = fopen (fn->fname, "r")) == NULL)    {
      printf ("\rCould not open Nodelist File '%s' - Exiting\n", fn->fname);
      exit (1);
   }
   this_list = fn->private;

   if (times)   {
      printf ("\nProcessing Nodelist File '%s'\n", fn->fname);
      fgets (buf,256, f);
      p1 = buf + strlen (buf) - 1;
      while ((p1 >= buf) && (*p1 != ':'))
         --p1;
      if (p1 >= buf)      {
         strcpy (p1, "-- Page");
         sprintf (prn_first_line, "Bulletin Board Listing from %s", buf + 3);
         sprintf (txt_first_line, "%s", buf + 3);
      }    else      {
         prn_first_line[0] = '\0';
         txt_first_line[0] = '\0';
      }

      if ((nodelist_prn != NULL) && !this_list)      {
         ++prn_pagenum;
         fprintf (nodelist_prn, "%s %d\n\n", prn_first_line, prn_pagenum);
      }

      if ((nodelist_txt != NULL) && !this_list)     {
         ++txt_pagenum;
         fprintf (nodelist_txt, "%s %d\n\n", txt_first_line, txt_pagenum);
      }
   }  else
      printf ("\nAdding Nodelist File '%s' to Zone %d\n", fn->fname, myzone);
   strcpy (this_file, fn->fname);

   /* Show that we are not skipping here */

   skip = -1;

   addrs[0] = addrs[1] = addrs[2] = addrs[3] = (myzone > 0) ? myzone : 1;

   while (1)   {
      ret = fgets (buf, 256, f);
      if ( ret == NULL || *ret==0x1a)   {
         break;
      }
      pvt = 0;
      dphone = 0;
      n_cost = 0;
      did_cost = 0;
      hold = 0;
      ntyp = 'L';
      def = 0;
      likely = 0;

      p = buff;
      p1 = buf;
      while (*p1)    {
         if (!isspace (*p1))
            *p++ = *p1;
         ++p1;
      }
      *p++ = '\n';
      *p = '\0';
      p = buff;

      if (*p == ';')     {
         if (comments)       {
            fputs (buf, stdout);
         }

         if ((!this_list) && (buf[1] == 'A'))    {
            if ((nodelist_prn != NULL) && (prn_pg_lines == 100))
               fputs (buf + 2, nodelist_prn);
            if ((nodelist_txt != NULL) && (txt_pg_lines == 100))
               fputs (buf + 2, nodelist_txt);
         }
         continue;
      }

      nnodes++;

      /* Modifier (Host, Region, etc.) */
      p = nextfield (p, b1);
      /*----------------------------------------------------------------*
      *-----------------------------------------------------------------*/
      if (starnet )  {
         int i;
         startype = 0;
         if (*b1 != '\0') {
            for (i= 0;modif[i];i++) {
               if (stricmp(b1,modif[i]) == 0) {
                  startype = i+1;
                  break;
               }
            }
        }
      }

      /* Node number (or region or zone) */

      p = nextfield (p, b2);
      n_num = atoi (b2);

      /* Did we get anything? */
      if (b1[0] != '\0')  {
         /* Is it something we need to worry about? */
         if (stricmp (b1, "zone") == 0)  {
            if ((myzone > 0) && (addrs[0] == myzone) && nzones)   {
               if (fn != NULL)
                  fn = fn->next;
               i = 0;
               while (fn != NULL)    {
                  process_file (0);
                  i = 1;
               }
               if (i)
                  printf ("\nReturning to finish file '%s'\n", this_file);
               }

               ++nzones;
               if (out_type == 0)   {
                  if (usezone)
                     strcpy (b1, "ZONE ");
                  else
                     strcpy (b1, "REGION ");
                  dphone = 1;
               }   else    {
                  if (usezone)
                     strcpy (b1, "ZONE ");
                  else
                     strcpy (b1, "REGION ");
                  dphone = 1;
                  if (myzone > 0) {
                     if (n_num != myzone) {
                     skip = 1;
                  } else {
                     skip = 0;
                  }
               }
            }
            ntyp = 'Z';
         } else if (stricmp (b1, "region") == 0) {
            ++nregions;
            spec_word (b1);
            dphone = 2;
            if (skip == 1)
               skip = 2;
         } else if (stricmp (b1, "host") == 0) {
            ++nnets;
            spec_word (b1);
            dphone = 3;
            if (skip == 1)
               skip = 2;
            ntyp = 'I';
         } else if (stricmp (b1, "hub") == 0) {
            ++nhubs;
            if (out_type)
               spec_word (b1);
            else
               b1[0] = '\0';
            dphone = 4;
            if (skip == 1)
               skip = 2;
            ntyp = 'H';
         } else if (stricmp (b1, "pvt") == 0) {
            /* It is just a private node */
            b1[0] = '\0';
            pvt = 1;
         } else if (stricmp (b1, "hold") == 0) {
            /* It is on hold */
            b1[0] = '\0';
            hold = 1;
         } else {
            ++ndown;
            /* It is something we don't understand, or the node is down */
            continue;
         }
      }
      if (dphone)     {
         addrs[dphone - 1] = n_num;
         for (i = dphone; i < 4; i++)      {
            addrs[i] = n_num;
         }
         cur_addr_lev = dphone;
         if (dphone < 4)     {
            printf ("\rZone %2d, Region %2d, Net %5d ", addrs[0], addrs[1], addrs[2]);
            node = 0;
         }    else       {
            node = n_num;
         }
      }   else    {
         node = n_num;
      }

      /* Translate the node type if necessary */
      if (b1[0] == '\0') {
         et = et_head;
         while (et != NULL) {
            if (((addrs[0] == et->zone) || (et->zone == -1)) &&
               (addrs[2] == et->net) && (node == et->node)) {
               switch (et->etype) {
                  case 'I':
                     strcpy (b1, "IGATE ");
                     break;
                  case 'O':
                     strcpy (b1, "OGATE ");
                     break;
                  case 'G':
                     strcpy (b1, "GATE ");
                     break;
                  case 'H':
                     strcpy (b1, "HUB ");
                     break;
               }
               ntyp = et->etype;
               break;
            }
            et = et->next;
         }
      }

      /* Board name */
      p = nextfield (p, b2);

      /* Location */
      p = nextfield (p, b3);

      /* Sysop name */
      p = nextfield (p, b4);

      /* Phone number */
      p = nextfield (p, b5);
      strcpy (orig_phone, b5);

      /* Determine the cost for this node */
      co = co_head;
      while (co != NULL) {
         if (strnicmp (b5, co->mstr, co->mlen) == 0) {
            n_cost = co->cost;
            did_cost = 1;
            break;
         }
         co = co->next;
      }

      /* If we didn't get a match, then it gets intl cost */
      if ((!did_cost) && (co == NULL) &&
         (strnicmp (country, b5, strlen (country)) == 0)) {
         did_cost = 1;
      }

      /* Translate the phone number if possible via phone translations */
      did_phone = 0;
      ph = ph_head;
      while (ph != NULL) {
         if (((addrs[0] == ph->zone) || (ph->zone == -1)) &&
            (addrs[2] == ph->net) && (node == ph->node)) {
            did_phone = 1;
            strcpy (b5, ph->num);
            break;
         }
         ph = ph->next;
      }

      if (dphone) {
         if (isdigit (b5[0]) || (ph != NULL)) {
            strcpy (def_phone, b5);
         } else {
            /* Bad news - an unlisted where we need a phone number */
            ++ndown;
            continue;
         }
      }

      /* If this guy is unpublished, put something in there */
      if (((!isdigit (b5[0])) || (hold)) && (ph == NULL)) {
         if (cur_addr_lev >= 3) {
            strcpy (b5, def_phone);
            def = 1;
            ++nredirect;
         } else {
            /* No dice - he is unpublished in a region or zone */
            ++ndown;
            continue;
         }
      }

      /* Determine the cost for this node */
      if (!did_cost) {
         co = co_head;
         while (co != NULL) {
            if (strnicmp (b5, co->mstr, co->mlen) == 0) {
               n_cost = co->cost;
               did_cost = 1;
               break;
            }
            co = co->next;
         }
      }

      /* Determine some things from the phone number */
      p1 = b5;
      p2 = pn1;
      while ((*p1) && isdigit (*p1)) {
         *p2++ = *p1++;
      }
      *p2 = '\0';

      if (*p1 != '\0')
         ++p1;

      p2 = pn2;
      while ((*p1) && isdigit (*p1)) {
         *p2++ = *p1++;
      }
      *p2 = '\0';

      if (*p1 != '\0')
         ++p1;

      p2 = pn3;
      while ((*p1) && isdigit (*p1)) {
         *p2++ = *p1++;
      }
      *p2 = '\0';

      if (*p1 != '\0')
         ++p1;

      if (pn1[0] == '\0') {
         pn1[0] = '1';
         pn1[1] = '\0';
      }

      if (pn2[0] == '\0') {
         pn2[0] = '1';
         pn2[1] = '\0';
      }

      if (pn3[0] == '\0') {
         pn3[0] = '1';
         pn3[1] = '\0';
      }

      /* Translate the number if possible via dial translations */
      dl = dl_head;
      while (dl != NULL) {
         if (strnicmp (b5, dl->mstr, dl->mlen) == 0) {
            strcpy (b7, &b5[dl->mlen]);
            sprintf (b5, "%s%s%s", dl->pre, b7, dl->post);
            break;
         }
         dl = dl->next;
      }

      if ((dl == NULL) && (!did_phone) && (strnicmp (country, b5, strlen (country)) != 0)) {
         sprintf (b7, "%s%s%s", intl_pre_dl, b5, intl_post_dl);
         strcpy (b5, b7);
      }

      /* Determine the cost for this node */
      if (!did_cost) {
         co = co_head;
         while (co != NULL) {
            if (strnicmp (b5, co->mstr, co->mlen) == 0) {
               n_cost = co->cost;
               did_cost = 1;
               break;
            }
            co = co->next;
         }
      }

      /* If we didn't get a match, then it gets intl cost */
      if (!did_cost) {
         n_cost = intl_cost;
      }

      /* Baud rate */
      p = nextfield (p, b6);
      n_baud = atoi (b6);

      /* If necessary, translate the baud rate */
      bd = bd_head;
      while (bd != NULL) {
         if (((addrs[0] == bd->zone) || (bd->zone == -1)) &&
            (addrs[2] == bd->net) && (node == bd->node)) {
            n_baud = bd->baud;
            break;
         }
         bd = bd->next;
      }

      /* Fix the baud rate downward if necessary */
      if (n_baud > maxbaud) {
         n_baud = maxbaud;
      }

      /* Get rid of the newline at the end */
      p1 = p;
      while ((*p1) && (!isspace (*p1))) {
         ++p1;
      }
      *p1 = '\0';

      if (dphone) {
         strcpy (def_flags, p);
         def_baud = n_baud;
         def_cost = n_cost;
      }

      if (def) {
         strcpy (p, def_flags);
         n_baud = def_baud;
         n_cost = def_cost;
      }

      /* Put the results into the proper files */
      if (skip < 2) {
         /* Print out the results in NODELIST.BBS format */
         if (nodelist_bbs != NULL) {
            if (nodash) {
               undash (b5);
            }

            fprintf (nodelist_bbs, "%s%d %d %d %s %s %s\n", b1, n_num, n_cost, n_baud, b2, b5, b3);
         }

         /* Output to NODELIST.FON */
         if (nodelist_fon != NULL) {
            /* Convert to upper case */
            strupr (p);

            /* Print it out in NODELIST.FON format */
            fprintf (nodelist_fon, "%4d %4d %3s %3s %3s %4d %c %s\n",
                     addrs[2], node, pn1, pn2, pn3, n_baud, ntyp,
                     (*p == '\0') ? "-" : p);
         }

         if (nodelist_dat != -1) {
            memset (&new_node, 0, sizeof (struct _node));
            new_node.number = node;
            new_node.net = addrs[2];
            new_node.cost = n_cost;
            new_node.rate = n_baud / 300;
            new_node.realcost = n_cost;
            strncpy (new_node.name, b2, 33);
            p1 = new_node.name;
            while ((p1 = strchr (p1, '_')) != NULL) {
               *p1 = ' ';
            }

            strncpy (new_node.phone, b5, 39);
            strncpy (new_node.city, b3, 29);
            p1 = new_node.city;
            while ((p1 = strchr (p1, '_')) != NULL) {
               *p1 = ' ';
            }

            /* Stick in a password if there is one */
            pw = pw_head;
            while (pw != NULL) {
               if (((addrs[0] == pw->zone) || (pw->zone == -1)) &&
                  (addrs[2] == pw->net) && (node == pw->node)) {
                  strncpy (new_node.password, &(pw->pw[1]), 8);
                  break;
               }
               pw = pw->next;
            }

            if (cur_addr_lev == 4) {
               new_node.hubnode = addrs[3];
            } else {
               new_node.hubnode = 0;
            }

            new_node.modem = 0;
            if (strstr (p, "HST")) {
               new_node.modem |= M_HST;
            }
            if (strstr (p, "PEP")) {
               new_node.modem |= M_PEP;
            }

            new_node.flags1 = 0;

            switch (dphone) {
               case 0:
                  break;

               case 1:
                  new_node.flags1 |= B_zone;
                  break;

               case 2:
                  new_node.flags1 |= B_region;
                  break;

               case 3:
                  new_node.flags1 |= B_host;
                  break;

               case 4:
                  new_node.flags1 |= B_hub;
                  break;
            }

            if (strstr (p, "CM")) {
               new_node.flags1 |= B_CM;
            }

            /* Stick in a CM flag is there is one done manually */
            cm = cm_head;
            while (cm != NULL) {
               if (((addrs[0] == cm->zone) || (cm->zone == -1)) &&
                  (addrs[2] == cm->net) && (node == cm->node)) {
                  new_node.flags1 |= B_CM;
                  break;
               }
               cm = cm->next;
            }

            write (nodelist_dat, &new_node, sizeof (struct _node));
         }
         /*-------------------------------------------------------------*
         *--------------------------------------------------------------*/
         if (qnl_dat_bbs != -1) {
            memset (&qbbsnode, 0, sizeof (struct qdat));
            qbbsidx.zone = addrs[0];
            qbbsidx.net = addrs[2];
            qbbsidx.node = node;
            qbbsidx.nodetype = qbbsnode.nodetype = dphone;
            if ((dphone == 1) && (b1[0] == 'R')) {
               qbbsidx.nodetype = qbbsnode.nodetype = 2;
            }

            write (qnl_idx_bbs, &qbbsidx, sizeof (struct qidx));

            qbbsnode.zone = addrs[0];
            qbbsnode.net = addrs[2];
            qbbsnode.node = node;

            strncpy (qbbsnode.name, b2, 20);
            p1 = qbbsnode.name;
            while ((p1 = strchr (p1, '_')) != NULL) {
               *p1 = ' ';
            }
            qbbsnode.namesize = strlen (b2);
            if (qbbsnode.namesize > 20)
               qbbsnode.namesize = 20;

            strncpy (qbbsnode.city, b3, 40);
            p1 = qbbsnode.city;
            while ((p1 = strchr (p1, '_')) != NULL) {
               *p1 = ' ';
            }
            qbbsnode.citysize = strlen (b3);
            if (qbbsnode.citysize > 40)
               qbbsnode.citysize = 40;

            strncpy (qbbsnode.phone, b5, 40);
            qbbsnode.phonesize = strlen (b5);
            if (qbbsnode.phonesize > 40)
               qbbsnode.phonesize = 40;

            /* Stick in a password if there is one */
            pw = pw_head;
            while (pw != NULL) {
               if (((addrs[0] == pw->zone) || (pw->zone == -1)) &&
                  (addrs[2] == pw->net) && (node == pw->node)) {
                  strncpy (qbbsnode.password, &(pw->pw[1]), 8);
                  qbbsnode.passwordsize = strlen (&(pw->pw[1]));
                  if (qbbsnode.passwordsize > 8)
                     qbbsnode.passwordsize = 8;
                  break;
               }
               pw = pw->next;
            }

            qbbsnode.flags = 0;

            switch (dphone) {
               case 0:
                  break;

               case 1:
                  qbbsnode.flags |= B_zone;
                  break;

               case 2:
                  qbbsnode.flags |= B_region;
                  break;

               case 3:
                  qbbsnode.flags |= B_host;
                  break;

               case 4:
                  qbbsnode.flags |= B_hub;
                  break;
            }

            if (strstr (p, "CM")) {
               qbbsnode.flags |= B_CM;
            }

            /* Stick in a CM flag is there is one done manually */
            cm = cm_head;
            while (cm != NULL) {
               if (((addrs[0] == cm->zone) || (cm->zone == -1)) &&
                  (addrs[2] == cm->net) && (node == cm->node)) {
                  qbbsnode.flags |= B_CM;
                  break;
               }
               cm = cm->next;
            }

            qbbsnode.baudrate = n_baud;
            qbbsnode.cost = n_cost;

            write (qnl_dat_bbs, &qbbsnode, sizeof (struct qdat));
         }
         /*-------------------------------------------------------------*
         *--------------------------------------------------------------*/
         if (fdstarnl != -1 ) {
            memset (&starnode, 0, sizeof (struct starlist));
            memset (&starinx,0,sizeof(struct dex));
            starnode.zone = addrs[0];
            starnode.net = addrs[2];
            starnode.node = node;
            strncpy (starnode.bbsname, b2, 50);
            strncpy (starnode.bbsloc, b3, 30);
            starnode.baud = n_baud;
            strncpy (starnode.bbsnumber, b5, 20);
            starnode.cost = n_cost;
            starnode.type = startype;
            if ((startype == 1)||(startype==2)||(startype==8))   {
                printf(" %-30s",b2);
                lnet = starnode.net;
                starinx.type = starnode.type;
                strcpy(starinx.location,starnode.bbsname);
                strcpy(starinx.realloc,starnode.bbsloc);
                starinx.position = starpos;
                starnode.node = 0;
                starnode.rnet = starnode.net;
                starnode.rnode = starnode.node;
                starinx.net = starnode.net;
                starinx.zone      = addrs[0];
                write (fdstarinx, &starinx, sizeof(struct dex));
             }   else  {
                starnode.net = lnet;
                starnode.rnet = starnode.net;
                if( starnode.net != mynet)
                  starnode.rnode = 0;
                else
                   starnode.rnode=starnode.node;
             }

            /* Stick in a password if there is one */
            pw = pw_head;
            while (pw != NULL) {
               if (((addrs[0] == pw->zone) || (pw->zone == -1)) &&
                  (addrs[2] == pw->net) && (node == pw->node)) {
                  strncpy (starnode.password, &(pw->pw[1]), 10);
                  break;
               }
               pw = pw->next;
            }
            starnode.flags = 0;

            switch (dphone) {
               case 0:
                  break;

               case 1:
                  starnode.flags |= B_zone;
                  break;

               case 2:
                  starnode.flags |= B_region;
                  break;

               case 3:
                  starnode.flags |= B_host;
                  break;

               case 4:
                  starnode.flags |= B_hub;
                  break;
            }

            if (strstr (p, "CM")) {
               starnode.flags |= B_CM;
            }

            /* Stick in a CM flag is there is one done manually */
            cm = cm_head;
            while (cm != NULL) {
               if (((addrs[0] == cm->zone) || (cm->zone == -1)) &&
                  (addrs[2] == cm->net) && (node == cm->node)) {
                  starnode.flags |= B_CM;
                  break;
               }
               cm = cm->next;
            }
            if((startype == SPVT) || (startype == SHOLD))
               strncpy(starnode.bbsnumber,def_phone,20);
            if (startype != SDOWN && startype != SKENL) {
              starpos += sizeof(struct starlist);
              starnode.res1 = 0xAA;
              starnode.res2 = 0xAA;
              starnode.res3 = 0xAA;
              starnode.res4 = 0xAA;
              write (fdstarnl, &starnode,sizeof(struct starlist) );
            }
         }
         /*-------------------------------------------------------------*
         *--------------------------------------------------------------*/
         if (nodelist_ext != -1) {
            memset (&bt_node, 0, sizeof (struct extrastuff));

            /* Stick in a password if there is one */
            pw = pw_head;
            while (pw != NULL) {
               if (((addrs[0] == pw->zone) || (pw->zone == -1)) &&
                  (addrs[2] == pw->net) && (node == pw->node)) {
                  strncpy (bt_node.password, &(pw->pw[1]), 8);
                  break;
               }
               pw = pw->next;
            }

            bt_node.flags1 = 0;

            switch (dphone) {
               case 0:
                  break;

               case 1:
                  bt_node.flags1 |= B_zone;
                  break;

               case 2:
                  bt_node.flags1 |= B_region;
                  break;

               case 3:
                  bt_node.flags1 |= B_host;
                  break;

               case 4:
                  bt_node.flags1 |= B_hub;
                  break;
            }

            if (strstr (p, "CM")) {
               bt_node.flags1 |= B_CM;
            }

            /* Stick in a CM flag is there is one done manually */
            cm = cm_head;
            while (cm != NULL) {
               if (((addrs[0] == cm->zone) || (cm->zone == -1)) &&
                  (addrs[2] == cm->net) && (node == cm->node)) {
                  bt_node.flags1 |= B_CM;
                  break;
               }
               cm = cm->next;
            }

            write (nodelist_ext, &bt_node, sizeof (struct extrastuff));
         }
         /*-------------------------------------------------------------*
         *--------------------------------------------------------------*/

         if (nodelist_dog != -1) {
            if (node <= 0) {
               if (seanet.numnodes) {
                  write (netlist_dog, &seanet, sizeof (struct netls));
                  seanetcnt += sizeof (struct netls);
               }

               memset (&seanet, 0, sizeof (struct netls));
               seanet.netnum = addrs[2];
               strncpy (seanet.netname, b2, 13);
               p1 = seanet.netname;
               while ((p1 = strchr (p1, '_')) != NULL) {
                  *p1 = ' ';
               }

               strncpy (seanet.netcity, b3, 39);
               p1 = seanet.netcity;
               while ((p1 = strchr (p1, '_')) != NULL) {
                  *p1 = ' ';
               }

               seanet.nodeptr = seanodecnt;
            }

            if (seacnt < 4000) {
               if (seaptr != NULL) {
                  seaptr->idxnet = addrs[2];
                  seaptr->idxnode = node;
                  seaptr->netlptr = seanetcnt;
                  seaptr->nodelptr = seanodecnt;
                  ++seaptr;
               }
            } else {
               seacnt = 3999;
            }

            memset (&seanode, 0, sizeof (struct nodels));
            seanode.nodenum = node;
            strncpy (seanode.nodename, b2, 13);
            p1 = seanode.nodename;
            while ((p1 = strchr (p1, '_')) != NULL) {
               *p1 = ' ';
            }

            strncpy (seanode.nodecity, b3, 39);
            p1 = seanode.nodecity;
            while ((p1 = strchr (p1, '_')) != NULL) {
               *p1 = ' ';
            }

            strncpy (seanode.nodephone, b5, 39);
            if (cur_addr_lev == 4) {
               seanode.havehub = 1;
               seanode.nodehub = addrs[3];
            }
            seanode.nodecost = n_cost;
            seanode.nodebaud = n_baud;
            write (nodelist_dog, &seanode, sizeof (struct nodels));
            ++seanet.numnodes;
            seanodecnt += sizeof (struct nodels);
            ++seacnt;
         }

         if (nodelist_sys != -1) {
            memset (&old_node, 0, sizeof (struct _oldnode));
            old_node.number = node;
            old_node.net = addrs[2];
            old_node.cost = n_cost;
            old_node.rate = n_baud;
            strncpy (old_node.name, b2, 19);
            p1 = old_node.name;
            while ((p1 = strchr (p1, '_')) != NULL) {
               *p1 = ' ';
            }

            strncpy (old_node.phone, b5, 39);
            strncpy (old_node.city, b3, 39);
            p1 = old_node.city;
            while ((p1 = strchr (p1, '_')) != NULL) {
               *p1 = ' ';
            }

            /* Stick in a password if there is one */
            pw = pw_head;
            while (pw != NULL) {
               if (((addrs[0] == pw->zone) || (pw->zone == -1)) &&
                    (addrs[2] == pw->net) && (node == pw->node)) {
                  strncpy (&(old_node.city[strlen (old_node.city) + 1]), pw->pw, 8);
                  break;
               }
               pw = pw->next;
            }

            write (nodelist_sys, &old_node, sizeof (struct _oldnode));
         }

         if (nodelist_idx != -1) {
            if ((node == 0) && (dphone <= 2)) {
               if ((ntyp != 'Z') || (!usezone))
                  n_out = -1;
               else
                  n_out = -2;
            } else {
               n_out = node;
            }

            write (nodelist_idx, &n_out, sizeof (int));
            write (nodelist_idx, &addrs[2], sizeof (int));
         }

         if (dphone == 3) {
            seanet.havehost = 1;
            seanet.nethost = 0;
         }

         if ((ntyp == 'G') || (ntyp == 'I')) {
            seanet.havegate = 1;
            seanet.netgate = node;
         }
      }

      /* Print out the Nodelist.Prn file */
      if ((!this_list) && (nodelist_prn != NULL) && !def) {
         ++prn_pg_lines;

         if (dphone && (dphone <= 3) && (prn_pg_lines >= 40)) {
            header (1);
            prn_pg_lines = 4;
         }

         if (prn_pg_lines >= 60) {
            header (1);
            prn_pg_lines = 4;
         }

         fprintf (nodelist_prn,
                  "%-10.10s %4d %-20.20s %-20.20s %-25.25s %-20.20s %4d %-20.20s\n",
                  b1, n_num, b2, orig_phone, b3, b4, n_baud, p);
      }

      /* Print out the Nodelist.Txt file */
      if ((!this_list) && (nodelist_txt != NULL) && !def) {
         ++txt_pg_lines;

         if (dphone && (dphone <= 3) && (txt_pg_lines >= 40)) {
            header (0);
            txt_pg_lines = 4;
         }

         if (txt_pg_lines >= 60) {
            header (0);
            txt_pg_lines = 4;
         }

         fprintf (nodelist_txt,
                  "%-10.10s %4d %-20.20s %-17.17s %-19.19s %4d\n",
                  b1, n_num, b2, orig_phone, b3, n_baud);
      }

      /* Print out the Fidouser.$$1 file */
      if (fidouser_SS1 != NULL) {
         /* Should we just be on our way? */
         if ((myzone > 0) && (myzone != addrs[0]) && (udata == 2)) {
            continue;
         }

         how_likely (p, dphone, addrs, node, n_baud);

         /* If this is a bad place, make it horrible */
         if (hold || pvt || def)
            likely = 100;

         p = b4;
         b1[1] = b2[1] = b3[1] = b5[1] = '\0';
         p1 = b1;
         while ((*p) && (*p != '_')) {
            *p1++ = *p++;
         }
         *p1 = '\0';

         if (*p != '\0')
            ++p;

         p1 = b2;
         while ((*p) && (*p != '_')) {
            *p1++ = *p++;
         }
         *p1 = '\0';

         if (*p != '\0')
            ++p;

         p1 = b3;
         while ((*p) && (*p != '_')) {
            *p1++ = *p++;
         }
         *p1 = '\0';

         p1 = b5;
         while ((*p) && (*p != '_')) {
            *p1++ = *p++;
         }
         *p1 = '\0';

         if (*p == '_')
            continue;

         b5[0] = toupper (b5[0]);
         b3[0] = toupper (b3[0]);
         b2[0] = toupper (b2[0]);
         b1[0] = toupper (b1[0]);
         strlwr (&b5[1]);
         strlwr (&b3[1]);
         strlwr (&b2[1]);
         strlwr (&b1[1]);
         if (b5[0] != '\0') {
            sprintf (buff, "%s, %s %s %s", b5, b1, b2, b3);
         } else if (b3[0] != '\0') {
            sprintf (buff, "%s, %s %s", b3, b1, b2);
         } else if (b2[0] != '\0') {
            sprintf (buff, "%s, %s", b2, b1);
         } else if (b1[0] != '\0') {
            sprintf (buff, "%s", b1);
         } else {
            continue;
         }
         if ((myzone > 0) && (myzone != addrs[0])) {
            sprintf (b5, "%d:%d", addrs[0], addrs[2]);
         } else {
            sprintf (b5, "%d", addrs[2]);
         }

         fprintf (fidouser_SS1, "%-40.40s%13.13s/%-6d%5d\n", buff, b5, node, likely);
      }
   }

   fclose (f);
   if (fn != NULL)
      fn = fn->next;
}



void header (which)
int which;
{
   if (which == 1)
      {
      if (prn_pagenum != 0)
         {
         fprintf (nodelist_prn, "\n");
         }
      ++prn_pagenum;
      fprintf (nodelist_prn, "%s %d\n", prn_first_line, prn_pagenum);
      fprintf (nodelist_prn, "Type       Node Board's Name         Phone Number         City                      Sysop's Name         Baud Flags\n");
      fprintf (nodelist_prn, "====       ==== ============         ============         ====                      ============         ==== =====\n\n");
      }
   else if (which == 0)
      {
      if (txt_pagenum != 0)
         {
         fprintf (nodelist_txt, "\n");
         }
      ++txt_pagenum;
      fprintf (nodelist_txt, "%s %d\n", txt_first_line, txt_pagenum);
      fprintf (nodelist_txt, "Type       Node Board's Name         Phone Number      City                Baud\n");
      fprintf (nodelist_txt, "====       ==== ============         ============      ====                ====\n");
      }
}



