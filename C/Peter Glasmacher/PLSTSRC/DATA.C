/************************************************************************
*************************************************************************
** NOTE:                                                               **
**   This Module is part of the ATARI ST Implementation of Parselst    **
**   It should NOT be used for general reference. Please read the com- **
**   plete Disclaimer either at the TOP of PARSELST.C.                 **
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
#include "types.h"

PWTRP pw_head = NULL;
PHTRP ph_head = NULL;
BDTRP bd_head = NULL;
DLTRP dl_head = NULL;
COTRP co_head = NULL;
ETTRP et_head = NULL;
CMTRP cm_head = NULL;
FNLST fn_head;
PWTRP pw;
PHTRP ph;
BDTRP bd;
DLTRP dl;
COTRP co;
ETTRP et;
CMTRP cm;
FNLSTP fn;
FNLSTP tfn;

char intl_pre_dl[30];
char intl_post_dl[30];
char t_str[128];
char country[10];
int intl_cost = 0;
int maxbaud = 9600;
int out_type = -1;
int rdata = 1;
int udata = 0;
int nlist = 1;
int doreport = 1;
int nodash = 0;
int comments = 0;
int newopus = 0;
int oldopus = 0;
int binkley = 0;
int myzone = -1;
int mynet;
int mynode;
int nzones;
int nregions;
int nnets;
int nhubs;
int ndown;
int nredirect;
int nnodes;
int likely;
int usezone;
int fidoprn;
int fidotxt;
int do_index;
int do_points;
int sealist = 0;
int quickbbs = 0;
int starnet = 0;
int wait = 0;
char nl[1000];
