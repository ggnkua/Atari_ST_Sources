/* Subroutines for insn-output.c for Motorola dsp96000
   Copyright ( C ) 1988 Free Software Foundation, Inc.

   $Id: out-dsp96k.c,v 1.23 91/07/31 17:25:28 pete Exp $

This file is part of GNU CC.

GNU CC is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY.  No author or distributor
accepts responsibility to anyone for the consequences of using it
or for whether it serves any particular purpose or works at all,
unless he says so in writing.  Refer to the GNU CC General Public
License for full details.

Everyone is granted permission to copy, modify and redistribute
GNU CC, but only under the conditions described in the
GNU CC General Public License.	 A copy of this license is
supposed to have been given to you along with GNU CC so you
can know your rights and responsibilities.  It should be in a
file named COPYING.  Among other things, the copyright notice
and this notice must be preserved on all copies.  */


static char Version[]
    = "$Header: /usr1/dsp/cvsroot/source/gcc/config/out-dsp96k.c,v 1.23 91/07/31 17:25:28 pete Exp $";


#ifndef FILE
#include <stdio.h>
#endif
#include <ctype.h>

#include <string.h>
/* #include <malloc.h> */

#include "flags.h"
#include "tree.h"

#if defined ( _DOS_ )
extern void *malloc( );
#endif

extern FILE* asm_out_file;
extern char call_used_regs[];
extern char regs_ever_live[];
extern int frame_pointer_needed;

# define LAST_DATA_REGISTER 23
char LocalBusy[FIRST_PSEUDO_REGISTER];
int FirstSave;

/* initialized here for the first function; reinitialized for each subsequent
   function in toplev.c */
func_attributes current_func_info = FUNC_NO_INFO;

char mem_space;
char memory_model;

static char* RegNames[] = REGISTER_NAMES;

static char* SFregs[] =
{
    "d0.s", "????", "????", "d1.s", "????", "????",
    "d2.s", "????", "????", "d3.s", "????", "????",
    "d4.s", "????", "????", "d5.s", "????", "????",
    "d6.s", "????", "????", "d7.s", "????", "????",

    "????", "????", "????", "????", "????", "????",
    "????", "????", "????", "????", "????", "????",
    "????", "????", "????", "????", "????", "????",
    "????", "????", "????", "????", "????", "????",
    "????", "????", "????", "????", "????", "????",
    "????", "????", "????", "????", "????", "????",
    "????", "????", "????", "????", "????", "????",
    "????", "????", "????", "????", "????", "????",
};


static char* DFregs[] =
{
    "d0.d", "????", "????", "d1.d", "????", "????",
    "d2.d", "????", "????", "d3.d", "????", "????",
    "d4.d", "????", "????", "d5.d", "????", "????",
    "d6.d", "????", "????", "d7.d", "????", "????",

    "????", "????", "????", "????", "????", "????",
    "????", "????", "????", "????", "????", "????",
    "????", "????", "????", "????", "????", "????",
    "????", "????", "????", "????", "????", "????",
    "????", "????", "????", "????", "????", "????",
    "????", "????", "????", "????", "????", "????",
    "????", "????", "????", "????", "????", "????",
    "????", "????", "????", "????", "????", "????",
};


static char* SIregs[] =
{
    "d0.l", "d0.m", "d0.h", "d1.l", "d1.m", "d1.h",
    "d2.l", "d2.m", "d2.h", "d3.l", "d3.m", "d3.h",
    "d4.l", "d4.m", "d4.h", "d5.l", "d5.m", "d5.h",
    "d6.l", "d6.m", "d6.h", "d7.l", "d7.m", "d7.h",
    "r0",   "r1",   "r2",   "r3",   "r4",   "r5",  "r6", "r7",
    "n0",   "n1",   "n2",   "n3",   "n4",   "n5",  "n6", "n7"
};


static char* 
Rname ( Regno, Mode )
    int Regno;
    enum machine_mode Mode;
{
    switch ( Mode )
    {
    case SFmode:
	return ( SFregs[Regno] );

    case DFmode:
	return ( DFregs[Regno] );

    default:
	return ( SIregs[Regno] );
    }
}

static void 
SetLocalBusy ()
{
    int i;
    int j;

    /* Store register usage ingo in LocalBusy. */
    for ( i = 0; i < FIRST_PSEUDO_REGISTER; i++ )
    {
	LocalBusy[i]
	    = ( ( 0 != regs_ever_live[i] )
	       && ( 0 == call_used_regs[i] ) ) ? i : 0;
    }
    
    /* Update LocalBusy to denote register pairs. */
    for ( i = 0; i < LAST_DATA_REGISTER; i += 3 )
    {
	/* First look for .l/.m pairs */
	if ( 0 != LocalBusy[i] && 0 != LocalBusy[i + 1] )
	{
	    LocalBusy[i] = i + 1;
	    LocalBusy[i + 1] = 0;
	    continue;
	}

	/* Next look for .l/.l pairs */
	for ( j = i + 3; j < LAST_DATA_REGISTER; j += 3 )
	{
	    if ( 0 != LocalBusy[i] && 0 != LocalBusy[j] )
	    {
		LocalBusy[i] = j;
		LocalBusy[j] = 0;
		break;
	    }
	}
    }
    
    /* Get the index in LocalBusy of the first register or pair saved */
    for ( FirstSave = -1, i = 0; i < FIRST_PSEUDO_REGISTER; i++ )
    {
	if ( 0 != LocalBusy[i] )
	{
	    FirstSave = i;
	    break;
	}
    }
}


static void 
PushRegs ( file )
    FILE* file;
{
    int i;

    FirstSave = -1;
    
    if ( 'l' != memory_model )
    {
	for ( i = 0; i < FIRST_PSEUDO_REGISTER; ++ i )
	{
	    if (( 0 != regs_ever_live[i] ) && ( 0 == call_used_regs[i] ))
	    {
		if ( 0 > FirstSave )
		{
		    FirstSave = i;
		}
		
		fprintf ( file, "\tmove	%s,%c:(r6)+\n",
			 Rname ( i, SImode ), mem_space );
	    }
	}
	return;
    }
    
    for ( i = 0; i < FIRST_PSEUDO_REGISTER; i++ )
    {
	if ( 0 == LocalBusy[i] )
	{
	    continue;
	}

	if ( i == LocalBusy[i] )
	{
	    if ( 0 > FirstSave )
	    {
		FirstSave = i;
	    }

	    fprintf ( file, "\tmove\t%s,y:(r6)+\n", Rname ( i, SImode ) );
	    continue;
	}

	/* .l/.m pair ? */
	if ( ( i + 1 ) == LocalBusy[i] )
	{
	    if ( 0 > FirstSave )
	    {
		FirstSave = i;
	    }

	    fprintf ( file, "\tmove\td%d.ml,l:(r6)+\n", i / 3 );
	    continue;
	}
	
	/* .l/.l pair */
	if ( 0 > FirstSave )
	{
	    FirstSave = i;
	}

	fprintf ( file, "\tmove\t%s,x:(r6)+ %s,y:\n",
		 Rname ( i, SImode ),
		 Rname ( LocalBusy[i], SImode ) );
    }
}


static void 
PopRegs ( file )
    FILE* file;
{
    int i;
    int first_save = 0;

#define SAVE_CHECK \
{\
    if ( ! first_save )\
    {\
	first_save = 1;\
	fprintf ( file, "\tmove	(r6)-\n" );\
    }\
}
    
    if ( 'l' != memory_model )
    {
	for ( i = FIRST_PSEUDO_REGISTER - 1; 0 <= i; -- i )
	{
	    if (( 0 != regs_ever_live[i] ) && ( 0 == call_used_regs[i] ))
	    {
		SAVE_CHECK;

		if ( i == FirstSave )
		{
		    fprintf ( file, "\tmove	%c:(r6),%s\n", mem_space,
			     Rname ( i, SImode ));
		}
		else
		{
		    fprintf ( file, "\tmove	%c:(r6)-,%s\n", mem_space,
			     Rname ( i, SImode ));
		}
	    }
	}
	return;
    }
    
    for ( i = FIRST_PSEUDO_REGISTER - 1; i > 0; i-- )
    {
	if ( 0 == LocalBusy[i] )
	{
	    continue;
	}

	SAVE_CHECK;
	if ( i == LocalBusy[i] )
	{
	    /* The last pop cannot adjust the stack pointer. */
	    if ( i == FirstSave )
	    {
		fprintf ( file, "\tmove\ty:(r6),%s\n", Rname ( i, SImode ) );
	    }
	    else
	    {
		fprintf ( file, "\tmove\ty:(r6)-,%s\n", Rname ( i, SImode ) );
	    }

	    continue;
	}

	/* The last pop cannot adjust the stack pointer. */
	if ( i == FirstSave )
	{
	    /* .l/.m pair ? */
	    if ( ( i + 1 ) == LocalBusy[i] )
	    {
		fprintf ( file, "\tmove\tl:(r6),d%d.ml\n", i / 3 );
		continue;
	    }
	
	    /* .l/.l pair */
	    fprintf ( file, "\tmove\tx:(r6),%s y:,%s\n",
		     Rname ( i, SImode ),
		     Rname ( LocalBusy[i], SImode ) );
	}
	else
	{
	    /* .l/.m pair ? */
	    if ( ( i + 1 ) == LocalBusy[i] )
	    {
		fprintf ( file, "\tmove\tl:(r6)-,d%d.ml\n", i / 3 );
		continue;
	    }

	    /* .l/.l pair */
	    fprintf ( file, "\tmove\tx:(r6)-,%s y:,%s\n",
		     Rname ( i, SImode ),
		     Rname ( LocalBusy[i], SImode ) );
	}
    }
}

/*
 * Replace an address of the form Frame-pointer + Constant with an
 * address that uses the Stack-pointer and a computed offset.
 */
rtx 
fix_frame_pointer_address ( Addr, Depth )
    rtx Addr;
    int Depth;
{
    int Offset;
    int Regno;

    SetLocalBusy ();

    if ( PLUS != GET_CODE ( Addr )
	|| XEXP ( Addr, 0 ) != frame_pointer_rtx
	|| CONST_INT != GET_CODE ( XEXP ( Addr, 1 ) ) )
    {
	return ( Addr );
    }
    
    Offset = INTVAL ( XEXP ( Addr, 1 ) );

    for ( Regno = 0; Regno < FIRST_PSEUDO_REGISTER; Regno++ )
    {
	if ( 0 != LocalBusy[Regno] )
	{
	    --Offset;
	}
    }

    return ( plus_constant ( stack_pointer_rtx, Offset ) );
}


int 
go_if_legitimate_address ( Mode, X, Strict )
    int Mode;
    rtx X;
    int Strict;
{
    /* constant pointer */
    if ( CONSTANT_ADDRESS_P ( X ) )
    {
	return ( 1 );
    }

    /* register pointer */
    if ( REG_P ( X ) )
    {
	if ( ! Strict )
	{
	    return ( 1 );
	}

	if ( REGNO_OK_FOR_BASE_P ( REGNO ( X ) ) )
	{
	    return ( 1 );
	}

	return ( 0 );
    }

    switch ( GET_CODE ( X ) )
    {

    case PRE_DEC:
    case POST_DEC:
    case POST_INC:
	if ( REG_P ( XEXP ( X, 0 ) ) )
	{
	    if ( !Strict )
	    {
		return ( 1 );
	    }

	    if ( REGNO_OK_FOR_BASE_P ( REGNO ( XEXP ( X, 0 ) ) ) )
	    {
		return ( 1 );
	    }
	}

	return ( 0 );

    case CONST_INT:
 	return ( 1 );

    case PLUS:
	if ( REG_P ( XEXP ( X, 0 ) )
	     && ( CONSTANT_ADDRESS_P ( XEXP ( X, 1 ) ) ) )
	{
	    if ( ! Strict )
	    {
		return ( 1 );
	    }

	    if ( REGNO_OK_FOR_BASE_P ( REGNO ( XEXP ( X, 0 ) ) ) )
	    {
		/* register + constant int */
		return ( 1 );
	    }

	    return ( 0 );
	}

	if ( REG_P ( XEXP ( X, 1 ) )
	    && ( CONSTANT_ADDRESS_P ( XEXP ( X, 0 ) ) ) )
	{
	    if ( ! Strict )
	    {
		return ( 1 );
	    }

	    if ( REGNO_OK_FOR_BASE_P ( REGNO ( XEXP ( X, 1 ) ) ) )
	    {
		/* register + constant int */
		return ( 1 );
	    }

	    return ( 0 );
	}

    default:
	return ( 0 );
    }
}

void 
print_operand ( file, X, Code )
    FILE* file;
    rtx X;
    char Code;
{
    if ( 'n' == Code )
    {
	fprintf ( file, "\n" );
	return;
    }
    
    switch ( GET_CODE ( X ) )
    {
	
    case REG:
	/*
	 * Registers need special handling on m96k. When they are targets
	 * of moves, data alu registers must be suffiexed by .l,.m,.h,.s
	 * or .d Operands that may need this extension use the Code 'z'.
	 */
	if ( 'z' == Code )
	{
	    fprintf ( file, "%s", Rname ( REGNO ( X ), GET_MODE ( X ) ) );
	    return;
	}

	fprintf ( file, "%s", RegNames [REGNO ( X )] );
	return;

    case MEM:
	output_address ( XEXP ( X, 0 ) );
	return;

    case LABEL_REF:
    case SYMBOL_REF:
	fprintf ( file, "#" );
	output_addr_const ( file, X );
	return;

    case CONST_INT:
	fprintf ( file, "#%d", INTVAL ( X ) );
	return;

    case CONST_DOUBLE:
	if ( GET_MODE ( X ) == SFmode )
	{
	    union { double d; int i[2]; } u;
	    union { float f; int i; } u1;
	    u.i[0] = CONST_DOUBLE_LOW ( X );
	    u.i[1] = CONST_DOUBLE_HIGH ( X );
	    u1.f = u.d;

	    if ( Code == 'f' )
	    {
		fprintf ( file, "%.9g", u1.f );
		return;
	    }

	    fprintf ( file, "#$%x", u1.i );
	    return;
	}

	if ( GET_MODE ( X ) != DImode )
	{
	    union { double d; int i[2]; } u;
	    u.i[0] = CONST_DOUBLE_LOW ( X );
	    u.i[1] = CONST_DOUBLE_HIGH ( X );

	    fprintf ( file, "%.20g", u.d );
	    return;
	}

    default:
	fprintf ( file, "#" );
	output_addr_const ( file, X );
    }
}


print_operand_address ( file, Addr )
    FILE* file;
    rtx Addr;
{
    register rtx Reg0;
    register rtx Reg1;

    switch ( GET_CODE ( Addr ) )
    {

    case REG:
	fprintf ( file, "(%s)", RegNames [REGNO ( Addr )] );
	break;

    case POST_INC:
	fprintf ( file, "(%s)+", RegNames [REGNO ( XEXP ( Addr, 0 ) )] );
	break;

    case POST_DEC:
	fprintf ( file, "(%s)-", RegNames [REGNO ( XEXP ( Addr, 0 ) )] );
	break;

    case PRE_DEC:
	fprintf ( file, "-(%s)", RegNames [REGNO ( XEXP ( Addr, 0 ) )] );
	break;

    case PLUS:
	Reg0 = XEXP ( Addr, 0 );
	Reg1 = XEXP ( Addr, 1 );

	if ( CONSTANT_ADDRESS_P ( Reg0 ))
	{
	    fprintf ( file, "(" );
	    print_operand ( file, Reg1, 'c' );
	    fprintf ( file, "+" );
	    output_addr_const ( file, Reg0 );
	    fprintf ( file, ")" );
	    return;
	}

	if ( CONSTANT_ADDRESS_P ( Reg1 ))
	{
	    fprintf ( file, "(" );
	    print_operand ( file, Reg0, 'c' );
	    fprintf ( file, "+" );
	    output_addr_const ( file, Reg1 );
	    fprintf ( file, ")" );
	    return;
	}

	fatal ( "unknown PLUS case in PRINT_OPERAND_ADDRESS" );
	return;

    default:
	output_addr_const ( file, Addr );
    }
}


asm_output_opcode ( file, Opcode )
    FILE* file;
    char* Opcode;
{
}

void 
notice_update_cc ( Exp, Insn )
    rtx Exp;
    rtx Insn;
{
    if ( SET == GET_CODE ( Exp ) )
    {
	switch ( GET_CODE ( SET_DEST ( Exp ) ) )
	{

	case CC0:
	    cc_status.flags = 0;
	    cc_status.value1 = SET_DEST ( Exp );
	    cc_status.value2 = SET_SRC ( Exp );
	    break;
	    
	case REG:
	    switch ( GET_CODE ( SET_SRC ( Exp ) ) )
	    {
	    case CALL:
		if ( SImode == GET_MODE ( SET_DEST ( Exp )))
		{
		    cc_status.flags = 0;
		    cc_status.value1 = SET_DEST ( Exp );
		    cc_status.value2 = SET_SRC ( Exp );
		}
		else
		{
		    CC_STATUS_INIT;
		}
		break;
		
	    case MEM:
	    case REG:
	    case EQ:
	    case NE:
	    case GT:
	    case GTU:
	    case GE:
	    case GEU:
	    case LT:
	    case LTU:
	    case LE:
	    case LEU:
		CC_STATUS_INIT;
		break;

	    default:
		CC_STATUS_INIT;
		break;
	    }
	    
	    break;

	case MEM:
	    CC_STATUS_INIT;
	    break;
	}
    }
}

/* right now, we only handle the following types of mem expressions:
   ( MEM ( PLUS REG CA ))
   ( MEM ( CA ))
   where CA is CONSTANT_ADDRESS_P */

static rtx
gen_mem_plus_const_int_from_mem ( mem, const_int )
    rtx mem;
    int const_int;
{
    rtx addr = XEXP ( mem, 0 );
    
    switch ( GET_CODE ( addr ))
    {
    case PLUS:
	if (( REG == GET_CODE ( XEXP ( addr, 0 ))) &&
	    ( CONSTANT_ADDRESS_P ( XEXP ( addr, 1 ))))
	{
	    return gen_rtx ( MEM, GET_MODE ( mem ),
			    gen_rtx ( PLUS, Pmode,
				     XEXP ( addr, 0 ),
				     gen_rtx ( CONST, Pmode,
					      gen_rtx ( PLUS, Pmode,
						       XEXP ( addr, 1 ),
			       gen_rtx ( CONST_INT, VOIDmode, const_int )))));
	}
	else if (( REG == GET_CODE ( XEXP ( addr, 1 ))) &&
		 ( CONSTANT_ADDRESS_P ( XEXP ( addr, 0 ))))
	{
	    return gen_rtx ( MEM, GET_MODE ( mem ),
			    gen_rtx ( PLUS, Pmode,
				     XEXP ( addr, 1 ),
				     gen_rtx ( CONST, Pmode,
					      gen_rtx ( PLUS, Pmode,
						       XEXP ( addr, 0 ),
			       gen_rtx ( CONST_INT, VOIDmode, const_int )))));
	}
	else
	{
	    abort ( );
	}
	
    default:
	if ( CONSTANT_ADDRESS_P ( addr ))
	{
	    return gen_rtx ( MEM, GET_MODE ( mem ),
			    gen_rtx ( CONST, Pmode,
				     gen_rtx ( PLUS, Pmode, addr,
					      gen_rtx ( CONST_INT, VOIDmode,
						       const_int ))));
	}
	abort ( );
    }
    abort ( );
}

int
local_first_parm_offset ( fundecl )
    tree fundecl;
{
    return -2;
}

int
is_in_reg_p ( operand )
    rtx operand;
{
    while ( SUBREG == GET_CODE ( operand ))
    {
	operand = XEXP ( operand, 0 );
    }
    
    return ( REG == GET_CODE ( operand ));
}

/* this extraneous function is needed because the MetaWare C compiler
   can't handle the comma operator with pointer values. */

rtx
local_function_incoming_arg ( cum, mode, type, named )
    CUMULATIVE_ARGS cum;
    enum machine_mode mode;
    tree type;
    int named;
{
    if ( 2 <= cum || BLKmode == mode || 0 == named )
    {
	current_func_info |= FUNC_HAS_STACK_PARMS;
	return NULL;
    }
    return gen_rtx ( REG, ( mode ), 3 * cum );
}

#include "dsp.c"

