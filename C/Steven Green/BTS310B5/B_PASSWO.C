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
/*                      BinkleyTerm Password Processor                      */
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
/*  This module is based largely on a similar module in OPUS-CBCS V1.03b.   */
/*  The original work is (C) Copyright 1987, Wynn Wagner III. The original  */
/*  author has graciously allowed us to use his code in this work.          */
/*                                                                          */
/*--------------------------------------------------------------------------*/

#include <stdio.h>
#include <signal.h>
#include <ctype.h>
#include <conio.h>
#include <string.h>

#include "bink.h"
#include "msgs.h"
#include "password.h"
#include "session.h"
#include "nodeproc.h"

/*
 * Variables
 */

char *remote_password = NULL;
char tmp_password[9];

/*--------------------------------------------------------------------------*/
/* N PASSWORD                                                               */
/* Check remote's password against what we think it should be               */
/* Only display status messages if message==TRUE                            */
/*--------------------------------------------------------------------------*/

int n_password (ADDR *addr, char *theirs, BOOLEAN message)
{
   int got_one;

	if(!n_getpassword(addr))	/* Find our session password */
		return 0;				/* If we dont have one then caller override */


   	if ((remote_password != NULL) && (remote_password[0]))
    {
    	got_one = 2;
      	if ((theirs != NULL) && (theirs[0]))
        {
        	got_one = 1;

         	if (!strnicmp (theirs, remote_password, 8))
            {
            	if(message)
	            	status_line (msgtxt[M_PROTECTED_SESSION]);
            	return 0;
            }
      	}
                
		if(message)
	      	status_line (msgtxt[M_PWD_ERROR],
                    Pretty_Addr_Str (addr),
                    theirs,
                    remote_password );

/*
      	SENDCHARS (snitty_message, strlen (snitty_message), 0);

      	while (!OUT_EMPTY () && CARRIER)
         	time_release ();
*/

      	return got_one;
   	}
   	return 0;
}


/*--------------------------------------------------------------------------*/
/* N GET PASSWORD                                                           */
/* Find the nodelist entry for this system and point remote_password at     */
/* its password if any                                                      */
/*--------------------------------------------------------------------------*/

int n_getpassword (pw_addr)
ADDR *pw_addr;
{
   remote_password = NULL;                       /* Default to no password   */
   newnodedes.Password[0] = '\0';

   if (!nodefind (pw_addr, 0))                   /* find the node in the list */
      {
      remote_password = NULL;
      return (0);                                /* return failure if can't  */
      }

   if (newnodedes.Password[0] != '\0')           /* If anything there,       */
      {
      memset (tmp_password, 0, 9);
      strncpy (tmp_password, &newnodedes.Password[0], 8);
      
      remote_password = (char *) tmp_password;	 /* Point at it              */
      return (1);                                /* Successful attempt       */
      }
   else
      {
      /* No password involved */
      return (0);
      }
}