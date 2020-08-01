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
/* other.c */

#include "builtin.h"
#include  <errno.h>
#include <ctype.h>
#include  <sys/types.h>
#include "syscall.h"

extern float    floatval();
extern LONG_PTR insert();
extern WORD     d_trace, d_hitrace;
/* extern WORD     errno; */
extern LONG     maxmem, maxpspace, maxtrail;
extern LONG	simpath;

static BYTE perm = PERM;

FILE   *curr_in, *curr_out;   /* current input, output streams */

/*
typedef union {
       CHAR_PTR name;
       LONG     num;
} call_args;
*/
typedef unsigned int call_args;

static call_args call_arg[10];
static CHAR      s[256];

b_GET_SIMPATH() /* X */
{
    if (!unify(reg[1], simpath)) {FAIL0;}
}

b_SYSTEM0()  /* reg1: a list of int (string) for CShell commands */
{
   register LONG     op1;
   register LONG_PTR top;
   CHAR     s[256];

   op1 = reg[1];  DEREF(op1);
   namestring(GET_STR_PSC(op1), s);
   if (!unify(MAKEINT(system(s)), reg[2]))
      {FAIL0;}
}


getgenargs(rno)
WORD rno;
{  /* rno is number of register containing list of args
    * This routine converts them into array cal_arg, and
    * returns the number of args
    */
   register LONG     op2, op3;
   register LONG_PTR top;
   PSC_REC_PTR       psc_ptr;
   WORD              i;

   op2 = reg[rno];  DEREF(op2);
   i = 1;
   while (!ISNIL(op2)) {
      UNTAG(op2);
      op3 = FOLLOW(op2);  DEREF(op3);
      if (ISATOM(op3)) {
         psc_ptr = GET_STR_PSC(op3);
         if (IS_ORDI(psc_ptr)) {
            namestring(psc_ptr, s);
            call_arg[i] = (call_args) s;
         } else if (IS_BUFF(psc_ptr))
            call_arg[i] = (call_args) GET_NAME(psc_ptr);
      }
      else if (ISINTEGER(op3)) call_arg[i] = INTVAL(op3);
      else
         quit("Unknown syscall argument\n");
      op2 += 4;
      DEREF(op2);
      i++;
   }
   return i;
}


b_SYSCALL()  /* reg1: call #; reg2: list of parameters; reg3: returned value */
{
    register LONG     op1;
    register LONG_PTR top;
    int               n, r;

    op1 = reg[1];  DEREF(op1);
    n   = INTVAL(op1);              /* syscall number */
    switch (getgenargs(2)) {
      case  1: r = syscall(n);
               break;
      case  2: r = syscall(n, call_arg[1]);
               break;
      case  3: r = syscall(n, call_arg[1], call_arg[2]);
               break;
      case  4: r = syscall(n, call_arg[1], call_arg[2], call_arg[3]);
               break;
      case  5: r = syscall(n, call_arg[1], call_arg[2], call_arg[3],
                              call_arg[4]);
               break;
      case  6: r = syscall(n, call_arg[1], call_arg[2], call_arg[3],
                              call_arg[4], call_arg[5]);
               break;
      case  7: r = syscall(n, call_arg[1], call_arg[2], call_arg[3],
                              call_arg[4], call_arg[5], call_arg[6]);
               break;
      default: quit( "Too many arguments for syscall\n" );
               break;
   }
   if (!unify(reg[3], MAKEINT(r)))
      {FAIL0;}
}


b_ERRNO()
{
   if (!unify( reg[1], MAKEINT(errno)))
      {FAIL0;}
}


b_CALL()  /* reg1: The predicate to be called */
{
   callv_sub();  /* since cpreg has been saved by call "call",
                    should not be saved again, the same as exec */
}


b_LOAD()
{  /* reg1: the byte code file to be loaded
    * reg2: the return code, 0 => success
    */
   register LONG     op1;
   register LONG_PTR top;
   PSC_REC_PTR	     psc_ptr;

   op1 = reg[1];  DEREF(op1);
   psc_ptr = GET_STR_PSC(op1);
           
   if (!unify(MAKEINT(dyn_loader(psc_ptr)), reg[2]))
      {FAIL0;}
}


b_STATISTICS()
{
   print_statistics();
}


b_STATISTICS0()
{
   if (!unify(reg[1], MAKEINT(maxpspace*sizeof(LONG))))
      {FAIL0;}     /* max program area */
   if (!unify(reg[2], MAKEINT((((LONG)curr_fence-(LONG)pspace)))))
      {FAIL0;}     /* program area in use */
   if (!unify(reg[3], MAKEINT((hreg-heap_bottom))))
      {FAIL0;}     /* global stack in use */
   if (!unify(reg[4], MAKEINT((ereg<breg?ereg:breg)-hreg)))
      {FAIL0;}     /* stack area (local, global) free */
   if (!unify(reg[5], MAKEINT(local_bottom-(ereg<breg?ereg:breg))))
      {FAIL0;}     /* local stack in use */
   if (!unify(reg[6], MAKEINT(maxmem*sizeof(LONG))))
      {FAIL0;}     /* total stack area size */
   if (!unify(reg[7], MAKEINT(maxtrail*sizeof(LONG))))
      {FAIL0;}     /* total trail size */
   if (!unify(reg[8], MAKEINT(trreg-tstack)))
      {FAIL0;}
}


b_TRACE()
{
   hitrace = 1;
}


b_PILTRACE()
{
   trace = 1;
}


b_UNTRACE()
{
   hitrace = trace = 0;
}

/*
b_DETRACE()
{
   hitrace = d_hitrace;
   trace = d_trace;
}
*/

b_SYMTYPE()  /* reg1 term, reg2 type field of psc-entry of root sym of term */
{
   register LONG     op1;
   register LONG_PTR top;

   op1 = reg[1];
typd:
   switch (TAG(op1)) {
      case FREE: NDEREF(op1, typd);
      case LIST:
      case NUM : quit("Symtype: illegal first arg\n");
      case CS  : if (!unify(MAKEINT(GET_ETYPE(GET_STR_PSC(op1))), reg[2]))
                    {FAIL0;}
   }
}


b_HASHVAL()  /* reg1 Arg, reg2 size of hashtab, reg3 hashval for this arg */
{
   register LONG     op1, op2, op3;
   register LONG_PTR top;

   op1 = reg[1];
   op2 = reg[2];  DEREF(op2);  op2 = INTVAL(op2);
   op3 = reg[3];  DEREF(op3);
sotd0:
   switch(TAG(op1)) {
      case FREE: NDEREF(op1, sotd0);
                 printf("Indexing for asserted predicate with var arg\n");
                 FAIL0;
      case NUM : if (ISINTEGER(op1))
                    op1 = INTVAL(op1);
                 else
                    op1 = (LONG)(floatval(op1));
                 break;
      case LIST: op1 = *((LONG_PTR)UNTAGGED(list_str));
                 break;
      case CS  : op1 = (LONG)GET_STR_PSC(op1);
                 break;
   }
   if (!unify(op3, MAKEINT(IHASH(op1, op2))))
      {FAIL0;}
}


b_FLAGS()
{  /* reg1 contains number of bit to get or set (must be integer);
    * reg2 contains setting of 0 or 1,
    * or is variable and setting will be returned
    */
   register LONG     op1, op2, res;
   register LONG_PTR top;

   op1 = reg[1];  DEREF(op1);  op1 = INTVAL(op1);
   op2 = reg[2];  DEREF(op2);
   if (ISNONVAR(op2)) {
      if (op1 > 9)
         flags[op1-10] = op2;
      else {
         op2 = INTVAL(op2);
         switch (op1) {
            case 0: trace      = op2;  break;
            case 1: hitrace    = op2;  break;
            case 2: overflow_f = op2;  break;
            case 3: trace_sta  = op2;  break;
         }
         call_intercept = hitrace | trace_sta;
      }
   } else {
      if (op1 > 9)
         res = flags[op1-10];
      else {
         switch (op1) {
            case 0: res = trace;       break;
            case 1: res = hitrace;     break;
            case 2: res = overflow_f;  break;
            case 3: res = trace_sta;   break;
         }
         res = MAKEINT(res);
      }
      FOLLOW(op2) = res;
   }
}


print_statistics()
{
    LONG_PTR lstktop;

    if (breg < ereg)
       lstktop = breg;
    else
       lstktop = ereg - *(cpreg-5);

    printf("Maximum available stack size: %d\n", maxmem);
    printf("  Local stack: %d in use, %d max used.\n",
           local_bottom-lstktop, local_bottom-mlocaltop);
    printf("  Heap stack: %d in use, %d max used.\n",
           hreg-heap_bottom, mheaptop-heap_bottom);

    printf("Permanent space: %d, %d in use.\n", maxpspace,
           ((int) curr_fence - (int) pspace)/4);

    printf("Trail stack: %d, %d in use, %d max used.\n",
           maxtrail, trail_bottom-trreg, trail_bottom-mtrailtop);
}


b_READNAME()
{  /* Ch, Name, NextCh: reads a sequence of letters, digits
    * dollar signs and underscores, makes the sequence into a
    * constant and inserts it into the PSC table if necessary,
    * and returns a pointer to the PSC entry as Name.  NextCh is
    * the first character read which cannot join this sequence.
    *
    * It is assumed that reg1 contains a character; and that regs
    * 2 and 3 are free.  No checking is done here.  This builtin
    * is only supposed to be called from $read_tokens/3 anyway.
    */

   register LONG     op;
   register LONG_PTR top;
   CHAR     pname[STR_LIM], ch;
   CHAR_PTR name;
   WORD     len = 1;
   WORD     done = 0;
   LONG     ptr;

   op = reg[1];  DEREF(op);  op = INTVAL(op);

   name = pname;
   *name++ = (CHAR)op;   /* first character in the sequence */

   while (!done && len <= STR_LIM) {
      ch = getc(curr_in);
      if (isalpha(ch) || isdigit(ch) || ch == '$' || ch ==  '_') {
         *name++ = ch;
         len++;
      } else {
         *name = '\0';
         done = 1;
      }
   }

   if (ch == EOF) {
      clearerr(curr_in);
      printf("! unexpected end of file after %s\n", pname);
   }
   if (len > STR_LIM) {
      *name = '\0';
      len--;
      printf("*** Name of constant too long: %s\n", pname);
   }

   ptr = (LONG)insert(pname, len, 0, &perm) | CS_TAG;
   if (!unify(reg[2], ptr))
       {FAIL0;}
   op = reg[3];  DEREF(op);
   FOLLOW(op) = MAKEINT(ch);
   PUSHTRAIL(op);
}
