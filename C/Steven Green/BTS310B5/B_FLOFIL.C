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
/*                    BinkleyTerm .FLO file Processor                       */
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
/*                                                                          */
/*--------------------------------------------------------------------------*/

#include <stdio.h>
#include <signal.h>
#ifndef LATTICE
#include <io.h>
#endif
#include <conio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#ifdef __TOS__
#include <ext.h>
#else
#include <sys\types.h>
#include <sys\stat.h>
#include <fcntl.h>
#endif

#include "bink.h"
#include "msgs.h"
#include "com.h"
#include "zmodem.h"
#include "session.h"


BOOLEAN send_flo(char *fname, int (*callback)(char *))
{
   	FILE *fp;
   	char s[80];
   	char *sptr;
   	int i,j;
   	struct stat buf;

   	long current, last_start;

   	if (!stat (fname, &buf))
    {
    	if ((fp = fopen (fname, read_binary_plus)) == NULL)
        {
        	got_error (msgtxt[M_OPEN_MSG], fname);
            return TRUE;
        }

        current = 0L;
        while (!feof (fp))
        {
        	s[0] = 0;
            last_start = current;
            fgets (s, 79, fp);

            sptr = s;

            for (i = 0; sptr[i]; i++)
               	if (sptr[i] <= ' ')
                  	sptr[i] = 0;

            current = ftell (fp);

            if (sptr[0] == TRUNC_AFTER)
            {
               	sptr++;
               	i = TRUNC_AFTER;
            }
            else if (sptr[0] == SHOW_DELETE_AFTER)
            {
               	sptr++;
               	i = SHOW_DELETE_AFTER;
            }
            else
            	i = NOTHING_AFTER;

            if ((!sptr[0]) || (sptr[0] == ';'))
            {
            	continue;
            }

            if (sptr[0] != '~')
            {
            	if (stat (sptr, &buf))            /* file exist? */
                {
                	got_error (msgtxt[M_FIND_MSG], sptr);
                  	continue;
                }
               	else if (!buf.st_size)
                {
                	continue;                      /* 0 length? */
                }

               	j = (*callback) (sptr);
               	if (!j)
                {
                	fclose (fp);
                  	net_problems = TRUE;
                  	return FALSE;
                }

               	/*--------------------------------------------*/
               	/* File was sent.  Flag file name             */
               	/*--------------------------------------------*/
               	fseek (fp, last_start, SEEK_SET);
               	putc ('~', fp);                   /* flag it */
               	fflush (fp);
               	rewind (fp);                      /* clear any eof flags */
               	fseek (fp, current, SEEK_SET);

               	if (j == SPEC_COND)               /* if "Funny" success,   */
                	continue;                  /* don't delete/truncate */

               	if (i == TRUNC_AFTER)
                {
                	CLEAR_IOERR ();
                  	i = open (sptr, O_CREAT|O_TRUNC|O_BINARY|O_WRONLY, DEFAULT_MODE);
                  	status_line (msgtxt[M_TRUNC_MSG], sptr);
                  	close (i);
               	}
               	else if (i == SHOW_DELETE_AFTER)
                {
                	CLEAR_IOERR ();
                  	unlink (sptr);
                  	status_line (msgtxt[M_UNLINKING_MSG], sptr);
                }
               	else if (i == DELETE_AFTER)
                {
                	CLEAR_IOERR ();
                  	unlink (sptr);
                }
        	}
        }                                    /* while */

        fclose (fp);
    	unlink (fname);
	}                                       /* !stat */
	return TRUE;
}

/*--------------------------------------------------------------------------*/
/* do_FLOfile (send files listed in .FLO files)                             */
/*   returns TRUE (1) for good xfer, FALSE (0) for bad                      */
/*--------------------------------------------------------------------------*/

BOOLEAN do_FLOfile (char *ext_flags, int (*callback)(char *) , ADDR *ad)
{
   	char fname[80];
   	char *HoldName;

   	HoldName = HoldAreaNameMunge(ad);

   	/*--------------------------------------------------------------------*/
   	/* Send files listed in ?LO files (attached files)                    */
   	/*--------------------------------------------------------------------*/


	while(*ext_flags)
    {
		char c = *ext_flags++;

		if(caller && (c == 'H') && !check_holdonus(ad, (char**)NULL))
	    	continue;

      	sprintf (fname, "%s%s.%cLO", HoldName, Hex_Addr_Str(ad), c);
		if(!send_flo(fname, callback))
			return FALSE;

#ifdef IOS
		sprintf(fname, "%s%s.%cFT", HoldName, Addr36(ad), c);
		if(!send_flo(fname, callback))
			return FALSE;
#endif
	}

   	return TRUE;
}
