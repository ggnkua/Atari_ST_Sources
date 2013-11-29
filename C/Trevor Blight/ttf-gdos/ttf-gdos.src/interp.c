/****************** (c) Trevor Blight 2002 ***********************
*
*
* This file is part of ttf-gdos.
*
* ttf-gdos is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public License
* as published by the Free Software Foundation; either version 2
* of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*
********************************************
*
*
*  this file implements part of the true type font interpreter
*  (it is unfinished)
*
******************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <setjmp.h>

#define IBUG 0

#include "ttf.h"
#include "interp.h"
#if IBUG
#include "ibug.h"
#else
#define ibug()
static void nofunc( void ){};
#endif

#define LISTING 0

/* forward declarations of interpreting functions */
static void npushb( void );
static void pushb1( void );
static void pushb2( void );
static void pushb3( void );
static void pushb4( void );
static void pushb5( void );
static void pushb6( void );
static void pushb7( void );
static void pushb8( void );
static void npushw( void );
static void pushw1( void );
static void fdef( void );
static void idup( void );
static void ipop( void );
static void clear( void );
static void swap( void );
static void cindex( void );
static void mindex( void );
static void roll( void );
static void call( void );
static void loopcall( void );
static void lt( void );
static void lteq( void );
static void gt( void );
static void gteq( void );
static void eq( void );
static void neq( void );
static void odd( void );
static void even( void );
static void and( void );
static void or( void );
static void not( void );
static void ws( void );
static void rs( void );
static void add( void );
static void sub( void );
static void idiv( void );
static void mul( void );
static void iabs( void );
static void neg( void );
static void floor( void );
static void ceiling( void );
static void max( void );
static void min( void );
static void getinfo( void );
static void iif( void );
static void jrot( void );
static void jrof( void );
static void jmpr( void );

typedef struct{
   INSTRUCTION *start_address;
   INSTRUCTION *end_address;
} FUNC_DEF;

static int32 *Store;
static uint8 *Store_State;

int32 *stack_Base;
int32 *stack_ptr;

INSTRUCTION *ins_ptr;
static jmp_buf *envp0 = NULL;

static INSTRUCTION *fpgmp;	/* points to copy of font program */
static FUNC_DEF    *fTable;	/* function table definitions */

static void (*ifunc[])( void ) =
{  svtcay,   /* 00 */
   svtcax,   /* 01 */
   spvtcay,  /* 02 */
   spvtcax,  /* 03 */
   nofunc,   /* 04 */
   nofunc,   /* 05 */
   nofunc,   /* 06 */
   nofunc,   /* 07 */
   nofunc,   /* 08 */
   nofunc,   /* 09 */
   spvfs,    /* 0a */
   sfvfs,    /* 0b */
   nofunc,   /* 0c */
   nofunc,   /* 0d */
   nofunc,   /* 0e */
   nofunc,   /* 0f */
   srp0,     /* 10 */
   srp1,     /* 11 */
   srp2,     /* 12 */
   szp0,     /* 13 */
   szp1,     /* 14 */
   szp2,     /* 15 */
   szps,     /* 16 */
   sloop,    /* 17 */
   rtg,      /* 18 */
   rthg,     /* 19 */
   nofunc,   /* 1a */
   nofunc,   /* 1b */
   jmpr,     /* 1c */
   scvtci,   /* 1d */
   nofunc,   /* 1e */
   nofunc,   /* 1f */
   idup,     /* 20 */
   ipop,     /* 21 */
   clear,    /* 22 */
   swap,     /* 23 */
   nofunc,   /* 24 */
   cindex,   /* 25 */
   mindex,   /* 26 */
   nofunc,   /* 27 */
   nofunc,   /* 28 */
   nofunc,   /* 29 */
   loopcall, /* 2a */
   call,     /* 2b */
   fdef,     /* 2c */
   nofunc,   /* 2d */
   mdap0,    /* 2e */
   mdap1,    /* 2f */
   nofunc,   /* 30 */
   nofunc,   /* 31 */
   nofunc,   /* 32 */
   nofunc,   /* 33 */
   nofunc,   /* 34 */
   nofunc,   /* 35 */
   nofunc,   /* 36 */
   nofunc,   /* 37 */
   nofunc,   /* 38 */
   ip,       /* 39 */
   nofunc,   /* 3a */
   nofunc,   /* 3b */
   alignrp,  /* 3c */
   rtdg,     /* 3d */
   miap0,    /* 3e */
   miap1,    /* 3f */
   npushb,   /* 40 */
   npushw,   /* 41 */
   ws,       /* 42 */
   rs,       /* 43 */
   wcvtp,    /* 44 */
   rcvt,     /* 45 */
   gc0,      /* 46 */
   gc1,      /* 47 */
   scfs,     /* 48 */
   nofunc,   /* 49 */
   nofunc,   /* 4a */
   mppem,    /* 4b */
   nofunc,   /* 4c */
   nofunc,   /* 4d */
   nofunc,   /* 4e */
   nofunc,   /* 4f */
   lt,       /* 50 */
   lteq,     /* 51 */
   gt,       /* 52 */
   gteq,     /* 53 */
   eq,       /* 54 */
   neq,      /* 55 */
   odd,      /* 56 */
   even,     /* 57 */
   iif,      /* 58 */
   nofunc,   /* 59 */
   and,      /* 5a */
   or,       /* 5b */
   not,      /* 5c */
   deltap1,  /* 5d */
   sdb,      /* 5e */
   sds,      /* 5f */
   add,      /* 60 */
   sub,      /* 61 */
   idiv,     /* 62 */
   mul,      /* 63 */
   iabs,     /* 64 */
   neg,      /* 65 */
   floor,    /* 66 */
   ceiling,  /* 67 */
   round_gr, /* 68 */
   round_bl, /* 69 */
   round_wh, /* 6a */
   nofunc,   /* 6b */
   nround_gr,/* 6c */
   nround_bl,/* 6d */
   nround_wh,/* 6e */
   nofunc,   /* 6f */
   wcvtf,    /* 70 */
   deltap2,  /* 71 */
   deltap3,  /* 72 */
   deltac1,  /* 73 */
   deltac2,  /* 74 */
   deltac3,  /* 75 */
   sround,   /* 76 */
   nofunc,   /* 77 */
   jrot,     /* 78 */
   jrof,     /* 79 */
   roff,     /* 7a */
   nofunc,   /* 7b */
   rutg,     /* 7c */
   rdtg,     /* 7d */
   nofunc,   /* 7e */
   nofunc,   /* 7f */
   nofunc,   /* 80 */
   nofunc,   /* 81 */
   nofunc,   /* 82 */
   nofunc,   /* 83 */
   nofunc,   /* 84 */
   scanctrl, /* 85 */
   nofunc,   /* 86 */
   nofunc,   /* 87 */
   getinfo,  /* 88 */
   nofunc,   /* 89 */
   roll,     /* 8a */
   max,      /* 8b */
   min,      /* 8c */
   scantype, /* 8d */
   instctrl, /* 8e */
   nofunc,   /* 8f */
   nofunc,   /* 90 */
   nofunc,   /* 91 */
   nofunc,   /* 92 */
   nofunc,   /* 93 */
   nofunc,   /* 94 */
   nofunc,   /* 95 */
   nofunc,   /* 96 */
   nofunc,   /* 97 */
   nofunc,   /* 98 */
   nofunc,   /* 99 */
   nofunc,   /* 9a */
   nofunc,   /* 9b */
   nofunc,   /* 9c */
   nofunc,   /* 9d */
   nofunc,   /* 9e */
   nofunc,   /* 9f */
   nofunc,   /* a0 */
   nofunc,   /* a1 */
   nofunc,   /* a2 */
   nofunc,   /* a3 */
   nofunc,   /* a4 */
   nofunc,   /* a5 */
   nofunc,   /* a6 */
   nofunc,   /* a7 */
   nofunc,   /* a8 */
   nofunc,   /* a9 */
   nofunc,   /* aa */
   nofunc,   /* ab */
   nofunc,   /* ac */
   nofunc,   /* ad */
   nofunc,   /* ae */
   nofunc,   /* af */
   pushb1,   /* b0 */
   pushb2,   /* b1 */
   pushb3,   /* b2 */
   pushb4,   /* b3 */
   pushb5,   /* b4 */
   pushb6,   /* b5 */
   pushb7,   /* b6 */
   pushb8,   /* b7 */
   pushw1,   /* b8 */
   pushw1,   /* b9 */
   pushw1,   /* ba */
   pushw1,   /* bb */
   pushw1,   /* bc */
   pushw1,   /* bd */
   pushw1,   /* be */
   pushw1,   /* bf */
   mdrp,     /* c0 */
   mdrp,     /* c1 */
   mdrp,     /* c2 */
   mdrp,     /* c3 */
   mdrp,     /* c4 */
   mdrp,     /* c5 */
   mdrp,     /* c6 */
   mdrp,     /* c7 */
   mdrp,     /* c8 */
   mdrp,     /* c9 */
   mdrp,     /* ca */
   mdrp,     /* cb */
   mdrp,     /* cc */
   mdrp,     /* cd */
   mdrp,     /* ce */
   mdrp,     /* cf */
   mdrp,     /* d0 */
   mdrp,     /* d1 */
   mdrp,     /* d2 */
   mdrp,     /* d3 */
   mdrp,     /* d4 */
   mdrp,     /* d5 */
   mdrp,     /* d6 */
   mdrp,     /* d7 */
   mdrp,     /* d8 */
   mdrp,     /* d9 */
   mdrp,     /* da */
   mdrp,     /* db */
   mdrp,     /* dc */
   mdrp,     /* dd */
   mdrp,     /* de */
   mdrp,     /* df */
   mirp,     /* e0 */
   mirp,     /* e1 */
   mirp,     /* e2 */
   mirp,     /* e3 */
   mirp,     /* e4 */
   mirp,     /* e5 */
   mirp,     /* e6 */
   mirp,     /* e7 */
   mirp,     /* e8 */
   mirp,     /* e9 */
   mirp,     /* ea */
   mirp,     /* eb */
   mirp,     /* ec */
   mirp,     /* ed */
   mirp,     /* ee */
   mirp,     /* ef */
   mirp,     /* f0 */
   mirp,     /* f1 */
   mirp,     /* f2 */
   mirp,     /* f3 */
   mirp,     /* f4 */
   mirp,     /* f5 */
   mirp,     /* f6 */
   mirp,     /* f7 */
   mirp,     /* f8 */
   mirp,     /* f9 */
   mirp,     /* fa */
   mirp,     /* fb */
   mirp,     /* fc */
   mirp,     /* fd */
   mirp,     /* fe */
   mirp      /* ff */
}; /* ifunc[] */


void interpret( INSTRUCTION *start_adr, INSTRUCTION *end_adr )
{
jmp_buf my_env;
jmp_buf *sav_envp0 = envp0;
/*   return; <<< */
   ins_ptr = start_adr;
   if( setjmp( my_env ) != 0 ) {
      /* a jump has occurred from an inner block.
      ** if its destination is outside this block,
      ** jump to the next outer block
      */
      if( ( ins_ptr < start_adr ) || ( ins_ptr > end_adr ) ) {
         iprintf(( "jump out of block\n" ));
         assert( sav_envp0 != NULL ); /* illegal if outermost block */
         longjmp( *sav_envp0, 1 );
      } /* if */
   } /* if */
   envp0 = &my_env;

   assert( ins_ptr <= end_adr );
   while( ins_ptr < end_adr ) {	/* don't execute end instruction */
      if(!LISTING) {
        ibug();
        (*ifunc[*ins_ptr++])();
      }
      else {
         ins_ptr = ilist( ins_ptr );
	 putchar( '\n' );
      } /* if */
   } /* while */
   envp0 = sav_envp0;
} /* interpret() */


/******************
*  scan instruction,
*  return address of next instruction
******************/
static INSTRUCTION *iscan(  register INSTRUCTION *sip )
{
register INSTRUCTION instruction_code = *sip++;
   if( instruction_code == 0x40 ) {	/* NPUSHB */
   int n = *sip++;	/* nr bytes */
      sip += n;
   }
   else if( instruction_code == 0x41 ) {	/* pushn words */
   int n = *sip++;	/* nr words */
      sip += 2*n;
   }
   else if( (instruction_code&0xf8) == 0xb0 ) {	/* push bytes */
   int n = instruction_code&7;	/* nr bytes */
      sip += n+1;
   }
   else if( (instruction_code&0xf8) == 0xb8 ) {	/* pushn words */
   int n = instruction_code&7;	/* nr words */
      sip += 2*n + 2;
   } /* if */
   return sip;
} /* iscan() */


/******************
*  managing the stack
******************/

static void ipop( void )
{
   (void)pop();
} /* ipop() */

static void idup( void )
{
uint32 e1 = pop();
   iprintf(( "idup: %ld\n", e1 ));
   *stack_ptr++ = e1;
   *stack_ptr++ = e1;
} /* idup() */

static void clear( void )
{
   iprintf(( "clear stack\n" ));
   stack_ptr = stack_Base;
} /* clear() */

static void swap( void )
{
uint32 e1, e2;
   e1 = pop();
   e2 = pop();
   iprintf(( "swap: (e2 <-> e1) is (%ld <-> %ld)\n",  e2, e1 ));
   *stack_ptr++ = e1;
   *stack_ptr++ = e2;
} /* swap */

static void cindex( void )
{
uint16 k = pop();
   assert( stack_ptr >= stack_Base+k );
   iprintf(( "copy index %d: push %ld\n",  k, stack_ptr[-k] ));
   *stack_ptr = stack_ptr[-k];
   stack_ptr++;
} /* cindex */

static void mindex( void )
{
uint16 k = pop();
uint32 t;
register int32 *sp;
   assert( stack_ptr >= stack_Base+k );
   sp = stack_ptr-k;
   t = *sp;
   while( --k>0 ) {
      *sp = sp[1];
      sp++;
   } /* while */
   *sp = t;
   iprintf(( "mindex %d: move %ld to top)\n",  k, stack_ptr[-k] ));
   assert( sp+1 == stack_ptr );
} /* mindex */

static void roll( void )
{
uint32 t;
register int32 *sp = stack_ptr;
   assert( sp >= stack_Base+3 );
   t = sp[-3];
   sp[-3] = sp[-2];
   sp[-2] = sp[-1];
   sp[-1] = t;
   iprintf(( "roll sp->%ld->%ld->%ld\n", stack_ptr[-1], stack_ptr[-2], stack_ptr[-3] ));
} /* roll */


/******************
*  logical functions
******************/

static void lt( void )
{
int32 e1, e2;
   e1 = pop();
   e2 = pop();
   iprintf(( "lt: (e2 < e1) is (%ld < %ld) => %d\n",  e2, e1, e2<e1 ));
   *stack_ptr++ = (e2<e1);
} /* lt */

static void lteq( void )
{
int32 e1, e2;
   e1 = pop();
   e2 = pop();
   iprintf(( "lteq: (e2 <= e1) is (%ld <= %ld) => %d\n",  e2, e1, e2<=e1 ));
   *stack_ptr++ = (e2<=e1);
} /* lt */

static void gt( void )
{
int32 e1, e2;
   e1 = pop();
   e2 = pop();
   iprintf(( "gt: (e2 > e1) is (%ld > %ld) => %d\n",  e2, e1, e2>e1 ));
   *stack_ptr++ = (e2>e1);
} /* gt */

static void gteq( void )
{
int32 e1, e2;
   e1 = pop();
   e2 = pop();
   iprintf(( "gteq: (e2 >= e1) is (%ld >= %ld) => %d\n",  e2, e1, e2>=e1 ));
   *stack_ptr++ = (e2>=e1);
} /* gteq */

static void eq( void )
{
int32 e1, e2;
   e1 = pop();
   e2 = pop();
   iprintf(( "eq: (e2 == e1) is (%ld == %ld) => %d\n",  e2, e1, e2==e1 ));
   *stack_ptr++ = (e2==e1);
} /* eq */

static void neq( void )
{
uint32 e1, e2;
   e1 = pop();
   e2 = pop();
   iprintf(( "neq: (e2 != e1) is (%ld != %ld) => %d\n",  e2, e1, e2!=e1 ));
   *stack_ptr++ = (e2!=e1);
} /* neq */

static void odd( void )
{
register F26Dot6 e1;
F26Dot6 old;
   old = e1 = pop();
   e1 = do_round(e1);
   assert( (e1&63L) == 0 );	/* e1 is an integer */
   *stack_ptr = (e1&64) != 0;
   iprintf(( "odd: (%ld) => %s\n", e1, *stack_ptr ? "TRUE" : "FALSE" ));
   stack_ptr++;
} /* odd() */

static void even( void )
{
register F26Dot6 e1;
F26Dot6 old;
   old = e1 = pop();
   e1 = do_round(e1);
   assert( (e1&63L) == 0 );	/* e1 is an integer */
   *stack_ptr = (e1&64) == 0;
   iprintf(( "even: (%ld) => %s\n", e1, *stack_ptr ? "TRUE" : "FALSE" ));
   stack_ptr++;
} /* even() */

static void and( void )
{
uint32 e1, e2;
   e1 = pop();
   e2 = pop();
   iprintf(( "and: (e2 && e1) is (%ld && %ld) => %d\n",  e2, e1, e2&&e1 ));
   *stack_ptr++ = (e2&&e1);
} /* and */

static void or( void )
{
uint32 e1, e2;
   e1 = pop();
   e2 = pop();
   iprintf(( "or: (e2 or e1) is (%ld or %ld) => %d\n",  e2, e1, e2 || e1 ));
   *stack_ptr++ = (e2||e1);
} /* or */

static void not( void )
{
uint32 e1;
   e1 = pop();
   iprintf(( "not: !e1 is !%ld) => %d\n",  e1, !e1 ));
   *stack_ptr++ = !e1;
} /* not */


/******************
*  arithmetic functions
******************/

static void add( void )
{
F26Dot6 e1, e2;
   e1 = pop();
   e2 = pop();
   iprintf(( "add: (e2 + e1) is (%ld + %ld) => %ld\n",  e2, e1, e2+e1 ));
   *stack_ptr++ = e2+e1;
} /* add */

static void sub( void )
{
F26Dot6 e1, e2;
   e1 = pop();
   e2 = pop();
   iprintf(( "sub: (e2 - e1) is (%ld - %ld) => %ld\n",  e2, e1, e2-e1 ));
   *stack_ptr++ = e2-e1;
} /* sub */

static void idiv( void )
{
F26Dot6 e1, e2;
   e1 = pop();
   e2 = pop();
   iprintf(( "idiv: (e2 / e1) is (%ld / %ld) => %ld\n",  e2, e1, (e2<<6)/e1 ));
   *stack_ptr++ = (e2<<6)/e1;  /** <<<< overflow?? **/
} /* idiv */

static void mul( void )
{
F26Dot6 e1, e2;
   e1 = pop();
   e2 = pop();
   iprintf(( "mul: (e2 * e1) is (%ld * %ld) => %ld\n",  e2, e1, (e2*e1)>>6 ));
   *stack_ptr++ = e2*e1>>6;  /** <<<< overflow?? **/
} /* mul */

static void iabs( void )
{
F26Dot6 e1;
   e1 = pop();
   iprintf(( "iabs(e1) is iabs(%ld) => %ld\n",  e1, e1>=0 ? e1 : -e1 ));
   *stack_ptr++ = (e1>=0 ? e1 : -e1);
} /* iabs */

static void neg( void )
{
register F26Dot6 e1;
   e1 = pop();
   iprintf(( "neg(e1) is neg(%ld) => %ld\n",  e1,  -e1 ));
   *stack_ptr++ = -e1;
} /* neg */

static void floor( void )
{
register F26Dot6 e1;
F26Dot6 old;
   old = e1 = pop();
   e1 &= ~63L;
   *stack_ptr++ = e1;
   iprintf(( "floor(%ld) => %ld\n", old, e1 ));
   assert( (e1&63) == 0 );	/* e1 is an integer */
   assert( (e1+64) > old );
   assert( e1 <= old );
} /* floor */

static void ceiling( void )
{
register F26Dot6 e1;
F26Dot6 old;
   old = e1 = pop();
   e1 += 63L;
   e1 &= ~63L;
   *stack_ptr++ = e1;
   iprintf(( "ceiling(%ld) => %ld\n", old, e1 ));
   assert( (e1&63) == 0 );	/* e1 is an integer */
   assert( (e1-64) < old );
   assert( e1 >= old );
} /* ceiling */

static void max( void )
{
F26Dot6 e1, e2;
   e1 = pop();
   e2 = pop();
   iprintf(( "max(%ld, %ld) => %d\n",  e2, e1, e1>e2 ? e1 : e2 ));
   *stack_ptr++ = e1>e2 ? e1 : e2;
} /* max() */

void min( void )
{
F26Dot6 e1, e2;
   e1 = pop();
   e2 = pop();
   iprintf(( "max(%ld, %ld) => %d\n",  e2, e1, e1<e2 ? e1 : e2 ));
   *stack_ptr++ = e1<e2 ? e1 : e2;
} /* min() */


/******************
*  push functions
******************/

static void npushb( void )
{
register int n = *ins_ptr++;
   iprintf(( "npush %d bytes, %u ... \n", n, ins_ptr[0] ));
   while( n-- > 0 ) {
      *stack_ptr++ = *ins_ptr++;
   } /* while */
   assert( stack_ptr <= stack_Base + maxpp->maxStackElements );
} /* pushb() */


static void pushb1( void )
{
   iprintf(( "pushb(1) %u\n", ins_ptr[0] ));
   *stack_ptr++ = *ins_ptr++;
   assert( stack_ptr <= stack_Base + maxpp->maxStackElements );
} /* pushb1() */


static void pushb2( void )
{
   iprintf(( "pushb(2) %u %u\n", ins_ptr[0], ins_ptr[1] ));
   *stack_ptr++ = *ins_ptr++;
   *stack_ptr++ = *ins_ptr++;
   assert( stack_ptr <= stack_Base + maxpp->maxStackElements );
} /* pushb2() */


static void pushb3( void )
{
   iprintf(( "pushb(3) %u %u %u\n", ins_ptr[0], ins_ptr[1], ins_ptr[2] ));
   *stack_ptr++ = *ins_ptr++;
   *stack_ptr++ = *ins_ptr++;
   *stack_ptr++ = *ins_ptr++;
   assert( stack_ptr <= stack_Base + maxpp->maxStackElements );
} /* pushb3() */


static void pushb4( void )
{
   iprintf(( "pushb(4) %u %u %u %u\n", ins_ptr[0], ins_ptr[1], ins_ptr[2], ins_ptr[3] ));
   *stack_ptr++ = *ins_ptr++;
   *stack_ptr++ = *ins_ptr++;
   *stack_ptr++ = *ins_ptr++;
   *stack_ptr++ = *ins_ptr++;
   assert( stack_ptr <= stack_Base + maxpp->maxStackElements );
} /* pushb4() */


static void pushb5( void )
{
   iprintf(( "pushb(5) %u %u %u %u %u\n", ins_ptr[0], ins_ptr[1], ins_ptr[2], ins_ptr[3], ins_ptr[4] ));
   *stack_ptr++ = *ins_ptr++;
   *stack_ptr++ = *ins_ptr++;
   *stack_ptr++ = *ins_ptr++;
   *stack_ptr++ = *ins_ptr++;
   *stack_ptr++ = *ins_ptr++;
   assert( stack_ptr <= stack_Base + maxpp->maxStackElements );
} /* pushb5() */


static void pushb6( void )
{
   iprintf(( "pushb(6) %u %u %u %u %u %u\n",
                 ins_ptr[0], ins_ptr[1], ins_ptr[2], ins_ptr[3], ins_ptr[4], ins_ptr[5] ));
   *stack_ptr++ = *ins_ptr++;
   *stack_ptr++ = *ins_ptr++;
   *stack_ptr++ = *ins_ptr++;
   *stack_ptr++ = *ins_ptr++;
   *stack_ptr++ = *ins_ptr++;
   *stack_ptr++ = *ins_ptr++;
   assert( stack_ptr <= stack_Base + maxpp->maxStackElements );
} /* pushb6() */


static void pushb7( void )
{
   iprintf(( "pushb(7) %u %u %u %u %u %u %u\n",
                      ins_ptr[0], ins_ptr[1], ins_ptr[2], ins_ptr[3], ins_ptr[4], ins_ptr[5], ins_ptr[6] ));
   *stack_ptr++ = *ins_ptr++;
   *stack_ptr++ = *ins_ptr++;
   *stack_ptr++ = *ins_ptr++;
   *stack_ptr++ = *ins_ptr++;
   *stack_ptr++ = *ins_ptr++;
   *stack_ptr++ = *ins_ptr++;
   *stack_ptr++ = *ins_ptr++;
   assert( stack_ptr <= stack_Base + maxpp->maxStackElements );
} /* pushb7() */


static void pushb8( void )
{
   iprintf(( "pushb(8) %u %u %u %u %u %u %u %u\n",
                ins_ptr[0], ins_ptr[1], ins_ptr[2], ins_ptr[3], ins_ptr[4], ins_ptr[5], ins_ptr[6], ins_ptr[7] ));
   *stack_ptr++ = *ins_ptr++;
   *stack_ptr++ = *ins_ptr++;
   *stack_ptr++ = *ins_ptr++;
   *stack_ptr++ = *ins_ptr++;
   *stack_ptr++ = *ins_ptr++;
   *stack_ptr++ = *ins_ptr++;
   *stack_ptr++ = *ins_ptr++;
   *stack_ptr++ = *ins_ptr++;
   assert( stack_ptr <= stack_Base + maxpp->maxStackElements );
} /* pushb8() */


static void npushw( void )
{
register int n = *ins_ptr++;
register uint16 w;
   iprintf(( "npush %d words, %d ...\n", n, 256*ins_ptr[0]+ins_ptr[1] ));
   while( n-- > 0 ) {
      w = *ins_ptr++;
      w = (w<<8) + *ins_ptr++;
      *stack_ptr++ = (int32)w;
   } /* while */
   assert( stack_ptr <= stack_Base + maxpp->maxStackElements );
} /* npushw() */


static void pushw1( void )
{
register int n = ins_ptr[-1]&7;
register uint16 w;
   iprintf(( "push(%d) words, %d ...\n", n+1, 256*ins_ptr[0]+ins_ptr[1] ));
   while( n-- >= 0 ) {
      w = *ins_ptr++;
      w = (w<<8) + *ins_ptr++;
      *stack_ptr++ = (int32)w;
   } /* while */
   assert( stack_ptr <= stack_Base + maxpp->maxStackElements );
} /* pushw1() */


/******************
*  controlling flow
******************/

/******************
*  scan an if instruction
*  return address of next instruction after else & end addresses
*  if no else found, set else address to NULL
******************/
static INSTRUCTION *ifscan( register INSTRUCTION *ip, INSTRUCTION **else_adr )
{
INSTRUCTION *r = NULL;
INSTRUCTION *t;
register BYTE c;

   do {
      c = *ip;
      ip = iscan( ip );
      if( c == 0x58 ) {	/* IF */
         ip = ifscan( ip, &t );
      }
      else if( c == 0x1b ) {	/* ELSE */
	 assert( r == NULL );
	 r = ip;
      } /* if */
   } while( c != 0x59 );  /* EIF */
   *else_adr = r;
   return ip;
} /* ifscan() */

static void iif( void )
{
INSTRUCTION *end_adr, *else_adr, *stop_adr;
   iprintf(( "if (%s)\n", stack_ptr[-1]? "TRUE" : "FALSE" ));
   end_adr = ifscan( ins_ptr, &else_adr );
   if( pop() ) {
      stop_adr = (else_adr!=NULL ? else_adr : end_adr) - 1;
      assert( *stop_adr == (else_adr ? 0x1b : 0x59 )); /* ELSE, EIF */
      interpret( ins_ptr, stop_adr );
      assert( ins_ptr == stop_adr );
   }
   else if( else_adr != NULL ) {
      ins_ptr = else_adr;
      stop_adr = end_adr-1;
      assert( *stop_adr == 0x59 ); /* EIF */
      interpret( else_adr, stop_adr );
      assert( ins_ptr == stop_adr );
   } /* if */
   iprintf(( "end if\n" ));
   ins_ptr = end_adr;
} /* iif() */

static void jrot( void )
{
int32 offset;
int32 e;
   iprintf(( "jrot (%s) %ld\n", stack_ptr[-1]? "TRUE" : "FALSE", stack_ptr[-2] ));
   e = pop();
   offset = pop();
   if( e != 0 ) {
      ins_ptr += offset-1;
      longjmp( *envp0, 1 );
   } /* if */
} /* jrot() */

static void jrof( void )
{
int32 offset;
int32 e;
   iprintf(( "jrof (%s), %ld\n", stack_ptr[-1]? "TRUE" : "FALSE", stack_ptr[-2] ));
   e = pop();
   offset = pop();
   if( e == 0 ) {
      ins_ptr += offset-1;
      longjmp( *envp0, 1 );
   } /* if */
} /* jrof() */

static void jmpr( void )
{
int32 offset;
   iprintf(( "jmpr %ld\n", stack_ptr[-1] ));
   offset = pop();
   ins_ptr += offset-1;
   longjmp( *envp0, 1 );
} /* jrot() */


/******************
*  read & write store
******************/

static void ws( void )
{
uint16 loc;
int32  val;
   val = pop();
   loc = pop();
   iprintf(( "store[%d] := %ld\n", loc, val ));
   if( Store_State[loc] == 1 ) {
      iprintf(( "warning: overwriting unused store[%d]", loc ));
      iprintf(( "\n", getchar() ));
   } /* if */
   assert( loc < maxpp->maxStorage );
   Store[loc] = val;
   Store_State[loc] = 1;
} /* ws() */

static void rs( void )
{
uint16 loc = pop();
   iprintf(( "push store[%d] := %ld\n", loc, Store[loc] ));
   assert( loc < maxpp->maxStorage );
   if( Store_State[loc] == 0 ) {
      iprintf(( "warning: reading unset store[%d]", loc ));
      iprintf(( "\n", getchar() ));
   } /* if */
   *stack_ptr++ = Store[loc];
   assert( stack_ptr <= stack_Base + maxpp->maxStackElements );
   Store_State[loc] = 3;
} /* rs() */


/******************
*  define & call a function
******************/

static void fdef( void )
{
register uint8 fnr = pop();

   iprintf(( "defining func %d\n", fnr ));
   assert( fnr < maxpp->maxFunctionDefs );
   fTable[fnr].start_address = ins_ptr;
   while( *ins_ptr != 0x2d ) { 	/* ENDF */
#if LISTING
   INSTRUCTION *ip0 = ilist( ins_ptr );
       putchar( '\n' );
#endif
       ins_ptr = iscan( ins_ptr );
#if LISTING
       assert( ins_ptr == ip0 );
#endif
   } /* while */
#if LISTING
   ilist( ins_ptr ); iprintf( "\n\n" );	/* ENDF ins */
#endif
   fTable[fnr].end_address = ins_ptr;
   ins_ptr++;
} /* fdef() */

static void call( void )
{
register uint8 fnr = pop();
INSTRUCTION * const sav_ip = ins_ptr;
#if IBUG
INSTRUCTION * const sav_prg_start = prg_start;
char *sav_prg_str = prg_str;
char s[8];
   sprintf( s, "[%d]", fnr );
   iprintf(( "calling func %s\n", s ));
   prg_start = fTable[fnr].start_address;
   prg_str = s;
#endif
   assert( fnr < maxpp->maxFunctionDefs );
   interpret( fTable[fnr].start_address, fTable[fnr].end_address );
   iprintf(( "return from func %d\n", fnr ));
   assert( *ins_ptr == 0x2d ); 	/* ENDF */
   ins_ptr = sav_ip;
#if IBUG
   prg_str = sav_prg_str;
   prg_start = sav_prg_start;
#endif
} /* call() */

static void loopcall( void )
{
register uint8 fnr = pop();
register uint32 count = pop();
INSTRUCTION * const sav_ip = ins_ptr;
#if IBUG
INSTRUCTION * const sav_prg_start = prg_start;
char *sav_prg_str = prg_str;
char s[8];
   sprintf( s, "[%d]", fnr );
   iprintf(( "loop calling func %s %ld times\n", s, count ));
   prg_str = s;
#endif
   assert( fnr < maxpp->maxFunctionDefs );
   while( count-- > 0 ) {
#if IBUG
      prg_start = fTable[fnr].start_address;
#endif
      interpret( fTable[fnr].start_address, fTable[fnr].end_address );
      assert( *ins_ptr == 0x2d ); 	/* ENDF */
      iprintf(( "call function %d %ld more times\n\n", fnr, count ));
   } /* while */
   ins_ptr = sav_ip;
#if IBUG
   prg_start = sav_prg_start;
   prg_str = sav_prg_str;
#endif
} /* loopcall() */


static void getinfo( void )
{
uint32 sel = pop();
   iprintf(( "getinfo, %s%s%s\n",
                     sel&1?", version":"", sel&2?", rotatn":"", sel&4?", stretch":"" ));
   *stack_ptr++ = 0;
} /* getinfo() */

/******************
*  font program
*  this is run only when the font is first used
******************/
void pr_fpgm( const void *tableptr, const uint32 length )
{
   iprintf(( "font program, %ld instructions\n", length ));
   stack_ptr = stack_Base = malloc( maxpp->maxStackElements*sizeof(*stack_Base) );
   assert( stack_Base );
   Store = malloc( maxpp->maxStorage*sizeof(*Store) );
   assert( Store );
   Store_State = malloc( maxpp->maxStorage*sizeof(*Store_State) );
   assert( Store_State );
   memset( Store_State, 0, maxpp->maxStorage*sizeof(*Store_State) );
   fpgmp = tableptr;
   fTable = malloc( maxpp->maxFunctionDefs * sizeof(FUNC_DEF) );
   assert( fTable );

#if IBUG
   prg_start = fpgmp;
   prg_str = "fnt";
   reset_ibug();
#endif
   interpret( fpgmp, fpgmp + length );

} /* pr_fpgm() */


void free_interp( void ) {
   free( stack_Base );
   free( Store );
   free( Store_State );
   free( fTable );
   free_interp1();
} /* free_interp */


/********************* end of interp.c **********************/

