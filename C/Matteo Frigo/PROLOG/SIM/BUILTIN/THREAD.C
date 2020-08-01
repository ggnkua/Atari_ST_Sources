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
#include	"builtin.h"

#ifdef	 THREADED
#define	 JUMP_TABLE_SIZE	128
extern   LONG	jumtable[ JUMP_TABLE_SIZE ];
#endif

b_THREAD()
{
   	register LONG       op1, op2;
	register LONG_PTR   top;

	op1 = reg[1];
	DEREF(op1);
	op2 = reg[2];
	DEREF(op2);

#ifdef  THREADED
	op1 = MAKEINT(jmptable[INTVAL(op1)]);
#endif
	
	if(!unify(op1, op2)) { 
		FAIL0;
	}
}
