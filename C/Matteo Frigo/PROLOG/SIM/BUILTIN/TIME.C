/************************************************************************
*									*
* The SB-Prolog System							*
* Copyright SUNY at Stony Brook, 1986; University of Arizona, 1987	*
*									*
************************************************************************/

/*-----------------------------------------------------------------
SB-Prolog is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY.  No author or distributor
accepts responsibility to anyone for the consequences of using it
or for whether it serves any particular purpose or works at all,
unless he says so in writing.  Refer to the SB-Prolog General Public
License for full details.

Everyone is granted permission to copy, modify and redistribute
SB-Prolog, but only under the conditions described in the
SB-Prolog General Public License.   A copy of this license is
supposed to have been given to you along with SB-Prolog so you
can know your rights and responsibilities.  It should be in a
file named COPYING.  Among other things, the copyright notice
and this notice must be preserved on all copies. 
------------------------------------------------------------------ */
/* time.c */

#include <sys/time.h>
#include <sys/resource.h>
#include "builtin.h"

b_CPUTIME()   /* reg1: miliseconds */
{
    int           msec;
    msec =  clock()*5;
    if (!unify(reg[1], MAKEINT(msec)))
       {FAIL0;}
}


b_STATS()   /* reg1: code to indicate desired stat; reg2: returned stat */
{
   register LONG     op1;
   register LONG_PTR top;
   int               stat;

   op1 = reg[1];  DEREF(op1);
   switch ((int)(INTVAL(op1))) {
      case  0: 
               stat = clock()*5;
               break;
      case  1: stat = maxmem;                  /* max available stack size */
               break;
      case  2: stat = local_bottom - ((breg < ereg) ? breg : ereg - *(cpreg-5));
               break;                          /* local stack in use */
      case  3: stat = local_bottom-mlocaltop;  /* local stack max used */
               break;
      case  4: stat = hreg-heap_bottom;        /* heap stack used */
               break;
      case  5: stat = mheaptop-heap_bottom;    /* max heap used */
               break;
      case  6: stat = maxpspace;               /* max available perm space */
               break;
      case  7: stat = ((int) curr_fence - (int) pspace)/4;
               break;                         /* perm space in use */
      case  8: stat = maxtrail;               /* max available trail size */
               break;
      case  9: stat = trail_bottom-trreg;     /* trail stack in use */
               break;
      case 10: stat = trail_bottom-mtrailtop; /* max trail stk used */
               break;
      case 11: stat = ((breg < ereg) ? breg : ereg - *(cpreg-5)) - hreg;
               break;
      default: stat = 0;
	       break;
   }
   if (!unify(reg[2], MAKEINT(stat))) 
      {FAIL0;}
}
