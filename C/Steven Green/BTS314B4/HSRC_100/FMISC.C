/*=============================================================================

                              HydraCom Version 1.00

                         A sample implementation of the
                   HYDRA Bi-Directional File Transfer Protocol

                             HydraCom was written by
                   Arjen G. Lentz, LENTZ SOFTWARE-DEVELOPMENT
                  COPYRIGHT (C) 1991-1993; ALL RIGHTS RESERVED

                       The HYDRA protocol was designed by
                 Arjen G. Lentz, LENTZ SOFTWARE-DEVELOPMENT and
                            Joaquim H. Homrighausen
                  COPYRIGHT (C) 1991-1993; ALL RIGHTS RESERVED


  Revision history:
  06 Sep 1991 - (AGL) First tryout
  .. ... .... - Internal development
  11 Jan 1993 - HydraCom version 1.00, Hydra revision 001 (01 Dec 1992)


  For complete details of the Hydra and HydraCom licensing restrictions,
  please refer to the license agreements which are published in their entirety
  in HYDRACOM.C and LICENSE.DOC, and also contained in the documentation file
  HYDRACOM.DOC

  Use of this file is subject to the restrictions contained in the Hydra and
  HydraCom licensing agreements. If you do not find the text of this agreement
  in any of the aforementioned files, or if you do not have these files, you
  should immediately contact LENTZ SOFTWARE-DEVELOPMENT and/or Joaquim 
  Homrighausen at one of the addresses listed below. In no event should you
  proceed to use this file without having accepted the terms of the Hydra and
  HydraCom licensing agreements, or such other agreement as you are able to
  reach with LENTZ SOFTWARE-DEVELOMENT and Joaquim Homrighausen.


  Hydra protocol design and HydraCom driver:         Hydra protocol design:
  Arjen G. Lentz                                     Joaquim H. Homrighausen
  LENTZ SOFTWARE-DEVELOPMENT                         389, route d'Arlon
  Langegracht 7B                                     L-8011 Strassen
  3811 BT  Amersfoort                                Luxembourg
  The Netherlands
  FidoNet 2:283/512, AINEX-BBS +31-33-633916         FidoNet 2:270/17
  arjen_lentz@f512.n283.z2.fidonet.org               joho@ae.lu

  Please feel free to contact us at any time to share your comments about our
  software and/or licensing policies.

=============================================================================*/

#include "hydracom.h"


#define NAMELEN  13
#define LINELEN  64


static char xfer_log[PATHLEN];
static boolean xfer_logged;
static char xfer_pathname[PATHLEN];
static char xfer_real[NAMELEN],
            xfer_temp[NAMELEN];
static long xfer_fsize,
            xfer_ftime;


void unique_name (char *pathname)
{
        static char *suffix = ".000";
        register char *p;
        register int   n;

        if (fexist(pathname)) {
           p = pathname;
           while (*p && *p!='.') p++;
           for (n=0; n<4; n++) {
               if (!*p) {
                  *p     = suffix[n];
                  *(++p) = '\0';
               }
               else
                  p++;
           }
           
           while (fexist(pathname)) {
                 p = pathname + ((int) strlen(pathname)) - 1;
                 if (!isdigit(*p))
                    *p = '0';
                 else {
                    for (n=3; n--;) {
                        if (!isdigit(*p)) *p = '0';
                        if (++(*p) <= '9') break;
                        else               *p-- = '0';
                    }/*for*/
                 }
           }/*while(exist)*/
        }/*if(exist)*/
}/*unique_name()*/


char *xfer_init (char *fname, long fsize, long ftime)
{
        char  linebuf[LINELEN + 1];
        char  bad_real[NAMELEN],
              bad_temp[NAMELEN];
        long  bad_fsize,
              bad_ftime;
        char *p;
        FILE *fp;

        if (single_done)
           return (NULL);

        strcpy(xfer_real,fname);
        xfer_fsize = fsize;
        xfer_ftime = ftime;

        mergepath(xfer_pathname,download,xfer_real);
        if (fexist(xfer_pathname)) {
           struct stat f;

           stat(xfer_pathname,&f);
           if (xfer_fsize == f.st_size && xfer_ftime == f.st_mtime)
              return (NULL);                            /* already have file */
        }

        mergepath(xfer_log,download,"BAD-XFER.LOG");

        if ((fp = sfopen(xfer_log,"rt",DENY_WRITE)) != NULL) {
           while (fgets(linebuf,LINELEN,fp)) {
                 sscanf(linebuf,"%s %s %ld %lo",
                                bad_real, bad_temp, &bad_fsize, &bad_ftime);
                 if (!strcmp(xfer_real,bad_real) &&
                     xfer_fsize == bad_fsize && xfer_ftime == bad_ftime) {
                    mergepath(xfer_pathname,download,bad_temp);
                    if (fexist(xfer_pathname)) {
                       fclose(fp);
                       strcpy(xfer_temp,bad_temp);

                       xfer_logged = true;
                       return (xfer_pathname);
                    }
                 }
           }

           fclose(fp);
        }

        strcpy(xfer_pathname,download);
        p = xfer_pathname + ((int) strlen(xfer_pathname));
        strcat(xfer_pathname,"BAD-XFER.000");
        unique_name(xfer_pathname);
        strcpy(xfer_temp,p);

        xfer_logged = false;
        return (xfer_pathname);
}/*xfer_init()*/


boolean xfer_bad (void)
{
        struct stat f;
        FILE *fp;
        int n;

        if (single_file[0])
           single_done = true;

        if (xfer_logged)                        /* Already a logged bad-xfer */
           return (true);

        n = ((int) strlen(xfer_real)) - 1;
        if (n > 3 &&
            (!strcmp(&xfer_real[n-3],".PKT") || !strcmp(&xfer_real[n-3],".REQ"))) {
           xfer_del();
           return (false);                      /* don't recover .PKT / .REQ */
        }

        stat(xfer_pathname,&f);
        if (noresume || f.st_size < 1024L) {     /* not allowed/worth saving */
           xfer_del();
           return (false);
        }

        if ((fp = sfopen(xfer_log,"at",DENY_WRITE)) != NULL) {
           fprintf(fp,"%s %s %ld %lo\n",
                     xfer_real, xfer_temp, xfer_fsize, xfer_ftime);
           fclose(fp);

           return (true);                             /* bad-xfer logged now */
        }

        xfer_del();
        return (false);                             /* Couldn't log bad-xfer */
}/*xfer_bad()*/


char *xfer_okay (void)
{
        static char new_pathname[PATHLEN];
        char *p;

        strcpy(new_pathname,download);
        p = new_pathname + ((int) strlen(new_pathname));   /* start of fname */
        if (single_file[0]) {
           strcat(new_pathname,single_file);           /* add override fname */
           single_done = true;
        }
        else {
           strcat(new_pathname,xfer_real);                 /* add real fname */
           unique_name(new_pathname);                      /* make it unique */
        }
        rename(xfer_pathname,new_pathname);           /* rename temp to real */
        if (!nostamp && xfer_ftime)
           setstamp(new_pathname,xfer_ftime);               /* set timestamp */

        if (xfer_logged)                         /* delete from bad-xfer log */
           xfer_del();

        return (strcmp(p,xfer_real) ? p : NULL);              /* dup rename? */
}


void xfer_del (void)
{
        char  new_log[PATHLEN];
        char  linebuf[LINELEN + 1];
        char  bad_real[NAMELEN],
              bad_temp[NAMELEN];
        long  bad_fsize,
              bad_ftime;
        FILE *fp, *new_fp;
        boolean left;

        if (fexist(xfer_pathname))
           unlink(xfer_pathname);

        if ((fp = sfopen(xfer_log, "rt", DENY_WRITE)) != NULL) {
           mergepath(new_log,download,"BAD-XFER.$$$");
           if ((new_fp = sfopen(new_log, "wt", DENY_ALL)) != NULL) {
              left = false;
              while (fgets(linebuf,LINELEN,fp)) {
                    sscanf(linebuf,"%s %s %ld %lo",
                                   bad_real, bad_temp, &bad_fsize, &bad_ftime);
                    if (strcmp(xfer_real,bad_real) ||
                        strcmp(xfer_temp,bad_temp) ||
                        xfer_fsize != bad_fsize || xfer_ftime != bad_ftime) {
                       fputs(linebuf,new_fp);
                       left = true;
                    }
              }
              fclose(fp);
              fclose(new_fp);
              unlink(xfer_log);
              if (left) rename(new_log,xfer_log);
              else      unlink(new_log);
           }
           else
              fclose(fp);
        }
}/*xfer_del()*/

/* end of fmisc.c */
