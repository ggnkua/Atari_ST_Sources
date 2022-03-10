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
#include <ctype.h>
#include <time.h>

#include "types.h"
#include "externs.h"
#include "pl.h"
void size_report (void)
{
   printf ("Network Size Report:\n\n");
   printf ("Total Nodes Processed        = %d\n", nnodes);
   printf ("Nodes Deleted (Down)         = %d\n", ndown);
   printf ("Nodes ReDirected to Host/Hub = %d\n", nredirect);
   printf ("---------------------------------------\n");
   nnodes = nnodes - ndown - nredirect;
   printf ("Total Nodes Open for mail    = %d\n", nnodes);
   printf ("Zone Coordinators Listed     = %d\n", nzones);
   printf ("Regional Coordinators Listed = %d\n", nregions);
   printf ("Network Coordinators Listed  = %d\n", nnets);
   printf ("Hub Coordinators Listed      = %d\n", nhubs);
   printf ("=======================================\n");
   nnodes = nnodes - nzones - nregions - nnets - nhubs;
   printf ("Total Independent Nodes      = %d\n\n", nnodes);
}


