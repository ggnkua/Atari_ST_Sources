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
*     as not  being created  from the original source code. No other    *
*     executable  versions may be  distributed without  the             *
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
*     (I hate legalease). In other words, if you don't know what to do  *
*     with it,  don't use it,  and if you are brave enough to use it,   *
*     you're on your own.                                               *
*                                                                       *
* Spark Software may be contacted by modem at (603) 888-8179            *
* (node 1:132/101) on the public FidoNet network, or at the address     *
* given above.                                                          *
*-----------------------------------------------------------------------*/
/*----------------------------------------------------------------------*
*  This is the Parselst Implementation for the ATARI ST Line of  68000  *
*  Computers running under TOS. It was ported, cause I needed a Nodelist*
*  producer for  the BinkleyTerm/ST Implementation.                     *
*  Please don'nt nerve Bob Hartmann with question to this piece of code.*
*  He provided the original.                                            *
*  Bob Hartmann and Spark Software still own the copyright for this code*
*  Questions can be sent to:                                            *
*                                                                       *
*  Peter Glasmacher                                                     *
*  2250 Monroe Street #123                      Schuerbankstr.15        *
*  Santa Clara,CA 95050                         D-4600 Dortmund 41      *
*  USA                                          West Germany            *
*                                                                       *
*  FIDO 1:143/9 (408)-985-1538                  1:143/9 via 2:507/1     *
*-----------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#ifdef ST
#  include <tos.h>
#else
# include <fcntl.h>
#include <io.h>
#endif
#include "types.h"
#include "externs.h"
fast_open (name, mode)
char *name;
int mode;
{
int f;
   f = open(name,mode|O_RDWR);
   return (f);
}

fast_close (f)
int f;
{
   return(close(f));
}

fast_write (f, st, l)
int f;
char *st;
unsigned int l;
{
   return(write(f,st,l));
}

fast_read (f, st, l)
int f;
char *st;
unsigned int l;
{
   return(read(f,st,l));
}
