/* subroutines for insn-output.c for motorola dsp56000/1
   copyright ( c ) 1988 free software foundation, inc.

   $Id: out-dsp56k.c,v 1.43 91/12/02 15:52:43 jeff Exp $

this file is part of gnu cc.

gnu cc is distributed in the hope that it will be useful,
but without any warranty.  no author or distributor
accepts responsibility to anyone for the consequences of using it
or for whether it serves any particular purpose or works at all,
unless he says so in writing.  refer to the gnu cc general public
license for full details.

everyone is granted permission to copy, modify and redistribute
gnu cc, but only under the conditions described in the
gnu cc general public license.	 a copy of this license is
supposed to have been given to you along with gnu cc so you
can know your rights and responsibilities.  it should be in a
file named copying.  among other things, the copyright notice
and this notice must be preserved on all copies.  */


#ifndef file
#include <stdio.h>
#endif

#include <string.h>
#if defined ( _MSDOS )
extern void *malloc( );
#endif

#include <ctype.h>

#include "flags.h"
#include "tree.h"
#if ! defined( _INTELC32_ )
#include "hard-reg-set.h"
#else
#include "hardrset.h"
#endif

char mem_space = 'y';
char memory_model = 'y';

func_attributes current_func_info = FUNC_NO_INFO;

static char local_call_used_regs[] = CALL_USED_REGISTERS;
enum reg_class regno_reg_class ( );

int FirstSave;

void
PushRegs ( file )
    FILE* file;
{
    int reg_index;

    FirstSave = -1;
    
    for ( reg_index = 0; reg_index < FIRST_PSEUDO_REGISTER; ++ reg_index )
    {
	if ( regs_ever_live[ reg_index ] && 
	    ! local_call_used_regs[ reg_index ] )
	{
	    if ( 0 > FirstSave )
	    {
		FirstSave = reg_index;
	    }
	    
	    if ( DST_REGS == REGNO_REG_CLASS ( reg_index ))
	    {
		if ( 'l' == memory_model )
		{
		    fprintf ( file, "\
	move	%c10,l:(r6)+\n", *reg_names[ reg_index ] );
		}
		else
		{
		    fprintf ( file, "\
	move	%s0,%c:(r6)+\n\
	move	%s1,%c:(r6)+\n", reg_names[ reg_index ], mem_space,
			     reg_names[ reg_index ], mem_space );
		}
		
	    }
	    else if ( SRC_REGS == REGNO_REG_CLASS ( reg_index ) ||
		     MPY_REGS == REGNO_REG_CLASS ( reg_index ))
	    {
		if ( 'l' == memory_model )
		{
		    /* try to save x or y as a pair. */
		    if ( reg_index & 1 )
		    {
			/* x1 or y1 */
			if ( ! ( regs_ever_live[ reg_index - 1 ] &&
				! local_call_used_regs[ reg_index - 1 ] ))
			{
			    /* was the 0 portion saved ? if so, then we
			       don't need to do anything, else save the 1 ! */

			    fprintf ( file, "\
	move	%s,%c:(r6)+\n", reg_names[ reg_index ], mem_space );
			}
		    }
		    else
		    {
			/* x0 or y0 */
			if ( regs_ever_live[ reg_index + 1 ] && 
			    ! local_call_used_regs[ reg_index + 1 ] )
			{
			    /* are we also saving the 1 portion ? if so,
			       save the 1 as well as the 0 with an l: move.
			       otherwise, just save the 0. */
			    fprintf ( file, "\
	move	%c,l:(r6)+\n", *reg_names[ reg_index ] );
			}
			else
			{
			    fprintf ( file, "\
	move	%s,%c:(r6)+\n", reg_names[ reg_index ], mem_space );
			}
		    }
		}
		else
		{
		    fprintf ( file, "\
	move	%s,%c:(r6)+\n", reg_names[ reg_index ], mem_space );
		}
	    }
	    else
	    {
		fprintf ( file, "\
	move	%s,%c:(r6)+\n", reg_names[ reg_index ], mem_space );
	    }
	    
	}
    }
}

void
PopRegs ( file )
    FILE* file;
{
    int reg_index = FIRST_PSEUDO_REGISTER;
    int first_save = 0;
    
#define SAVE_CHECK \
{\
    if ( ! first_save )\
    {\
	first_save = 1;\
	fprintf ( file, "\tmove	(r6)-\n" );\
    }\
}


    while ( -- reg_index >= 0 )
    {
	if ( regs_ever_live[ reg_index ] && 
	    ! local_call_used_regs[ reg_index ] )
	{
	    SAVE_CHECK;
	    
	    if ( DST_REGS == REGNO_REG_CLASS ( reg_index ))
	    {
		if ( reg_index == FirstSave )
		{
		    if ( 'l' == memory_model )
		    {
			fprintf ( file, "\
	move	l:(r6),%c\n", *reg_names[ reg_index ] );
		    }
		    else
		    {
			fprintf ( file, "\
	move	%c:(r6)-,%s\n\
	move	%c:(r6),%s0\n", mem_space, reg_names[ reg_index ],
				 mem_space, reg_names[ reg_index ] );
		    }
		}
		else
		{
		    if ( 'l' == memory_model )
		    {
			fprintf ( file, "\
	move	l:(r6)-,%c\n", *reg_names[ reg_index ] );
		    }
		    else
		    {
			fprintf ( file, "\
	move	%c:(r6)-,%s\n\
	move	%c:(r6)-,%s0\n", mem_space, reg_names[ reg_index ],
				 mem_space, reg_names[ reg_index ] );
		    }
		}
	    }
	    else if ( SRC_REGS == REGNO_REG_CLASS ( reg_index ) ||
		     MPY_REGS == REGNO_REG_CLASS ( reg_index ))
	    {
		if ( 'l' == memory_model )
		{
		    if ( reg_index & 1 )
		    {
			/* x1 or y1 */
			if ( ! ( regs_ever_live[ reg_index -1 ] && 
				! local_call_used_regs[ reg_index - 1 ] ))
			{
			    /* if the 0 portion wasn't saved we need to
			       restore the 1, otherwise do nothing. */

			    if ( reg_index == FirstSave )
			    {
				fprintf ( file, "\
	move	%c:(r6),%s\n", mem_space, reg_names[ reg_index ] );
			    }
			    else
			    {
				fprintf ( file, "\
	move	%c:(r6)-,%s\n", mem_space, reg_names[ reg_index ] );
			    }
			}
		    }
		    else
		    {
			/* x0 or y0 */
			if ( regs_ever_live[ reg_index + 1 ] && 
			    ! local_call_used_regs[ reg_index + 1 ] )
			{
			    /* if the 1 portion was also saved, then we
			       need to to do an l: restore, otherwise a y:. */

			    if ( reg_index == FirstSave )
			    {
				fprintf ( file, "\
	move	l:(r6),%c\n", *reg_names[ reg_index ] );
			    }
			    else
			    {
				fprintf ( file, "\
	move	l:(r6)-,%c\n", *reg_names[ reg_index ] );
			    }
			}
			else
			{
			    if ( reg_index == FirstSave )
			    {
				fprintf ( file, "\
	move	%c:(r6),%s\n", mem_space, reg_names[ reg_index ] );
			    }
			    else
			    {
				fprintf ( file, "\
	move	%c:(r6)-,%s\n", mem_space, reg_names[ reg_index ] );
			    }
			}
		    }
		}
		else
		{
		    if ( reg_index == FirstSave )
		    {
			fprintf ( file, "\
	move	%c:(r6),%s\n", mem_space, reg_names[ reg_index ] );
		    }
		    else
		    {
			fprintf ( file, "\
	move	%c:(r6)-,%s\n", mem_space, reg_names[ reg_index ] );
		    }
		}
	    }
	    else
	    {
		if ( reg_index == FirstSave )
		{
		    fprintf ( file, "\
	move	%c:(r6),%s\n", mem_space, reg_names[ reg_index ] );
		}
		else
		{
		    fprintf ( file, "\
	move	%c:(r6)-,%s\n", mem_space, reg_names[ reg_index ] );
		}
	    }
	}
    }
}

int
go_if_legitimate_address ( mode, x, strict )
    int mode;
    rtx x;
    int strict;
{
    /* constant pointer */

    if ( CONSTANT_ADDRESS_P ( x ) )
    {
	return 1;
    }

    /* note that REG_OK_STRICT may NOT be defined here! */
    /* register pointer */

    if ( REG_P ( x ) && 
	(( strict ) ? 
	 ( REGNO_OK_FOR_INDEX_P ( REGNO ( x ))) :
	 ( REG_OK_FOR_INDEX_P ( x ))))
    {
	return 1;
    }
    
    /* register arithmetic */
    
    switch ( GET_CODE ( x ) )
    {
    case SUBREG:
	return go_if_legitimate_address ( mode, XEXP ( x, 0 ), strict );
					 
    case POST_DEC:
    case POST_INC:
    case PRE_INC:
    case PRE_DEC:
	if ( REG_P ( XEXP ( x, 0 )) && 
	    (( strict ) ? 
	     ( REGNO_OK_FOR_INDEX_P ( REGNO ( XEXP ( x, 0 )))) :
	     ( REG_OK_FOR_INDEX_P ( XEXP ( x, 0 )))))
	{
	    return 1;
	}
	break;
	
    case PLUS:
	if ( REG_P ( XEXP ( x, 0 )) && 
	    ( Pmode == GET_MODE ( XEXP ( x, 0 ))) &&
	    ( CONST_INT == GET_CODE ( XEXP ( x, 1 ))) &&
	    (( strict ) ? 
	     ( REGNO_OK_FOR_INDEX_P ( REGNO ( XEXP ( x, 0 )))) :
	     ( REG_OK_FOR_INDEX_P ( XEXP ( x, 0 )))))
	{
	    return 1;
	}

	if ( REG_P ( XEXP ( x, 1 )) && 
	    ( Pmode == GET_MODE ( XEXP ( x, 1 ))) &&
	    ( CONST_INT == GET_CODE ( XEXP ( x, 0 ))) &&
	    (( strict ) ? 
	     ( REGNO_OK_FOR_INDEX_P ( REGNO ( XEXP ( x, 1 )))) :
	     ( REG_OK_FOR_INDEX_P ( XEXP ( x, 1 )))))
	{
	    return 1;
	}
    }
    return 0;
}

void
print_operand_address ( file, addr )
    FILE* file;
    rtx addr;
{
    register rtx reg0;
    register rtx reg1;

    switch ( GET_CODE ( addr ) )
    {

    case REG:
	fprintf ( file, "(%s)", reg_names[ REGNO ( addr )] );
	break;

    case POST_INC:
	fprintf ( file, "(%s)+", reg_names[ REGNO ( XEXP ( addr, 0 ) )] );
	break;

    case POST_DEC:
	fprintf ( file, "(%s)-", reg_names[ REGNO ( XEXP ( addr, 0 ) )] );
	break;

    case PLUS:
	abort ( );
	
    default:
	output_addr_const ( file, addr );
    }
}

void
notice_update_cc ( exp, insn )
    rtx exp;
    rtx insn;
{
    if ( PARALLEL == GET_CODE ( exp ))
    {
	rtx call_insn = XVECEXP ( exp, 0, 0 );
	if ( GET_CODE ( call_insn ) == SET &&
	     GET_CODE ( XEXP ( call_insn, 1 )) == CALL )
	{
	    cc_status.flags = 0;
	    cc_status.value1 = cc0_rtx;
	    cc_status.value2 = gen_rtx ( REG, SImode, DSP56_A_REGNUM );
	    cc_status.mdep = CC_SIGNED;
	}
	else
	{
	    CC_STATUS_INIT;
	}
    }
    else if ( SET == GET_CODE ( exp ))
    {
	switch ( GET_CODE ( SET_DEST ( exp )))
	{
	case CC0:
	    cc_status.flags = 0;
	    cc_status.value1 = SET_DEST ( exp );
	    cc_status.value2 = SET_SRC ( exp );
	    break;
	    
	case REG:
	    CC_STATUS_INIT;
	}
    }
    else
    {
	CC_STATUS_INIT;
    }
}

rtx
next_cc_relevancy ( insn )
    rtx insn;
{
    rtx peek = NEXT_INSN ( insn );
    
    for ( ; NULL != peek; peek = NEXT_INSN ( peek ))
    {
	switch ( GET_CODE( peek ))
	{
	case JUMP_INSN:
	case CALL_INSN:
	case CODE_LABEL:
	case BARRIER:
	    return peek;
	    
	case INSN:
	    if (( PARALLEL == GET_CODE ( PATTERN ( peek ))) &&
		( SET == GET_CODE ( XVECEXP ( PATTERN ( peek ), 0, 0 ))) &&
		( 0 == strcmp ( GET_RTX_FORMAT ( GET_CODE ( XEXP ( XVECEXP ( PATTERN ( peek ), 0, 0 ), 1 ))), "ee" )) &&
		( cc0_rtx == XEXP ( XEXP ( XVECEXP ( PATTERN ( peek ), 0, 0 ), 1 ), 0 )))
	    {
		return peek;
	    }
	}
    }
    return insn;
}

enum mdep_cc_info
next_cc_use ( insn )
    rtx insn;
{
    enum rtx_code jump_code;
    rtx peek = NEXT_INSN ( insn );
    
    for ( ; NULL != peek; peek = NEXT_INSN ( peek ))
    {
	if ( JUMP_INSN == GET_CODE ( peek ))
	{
	    break;
	}
	if ( CALL_INSN == GET_CODE ( peek ) ||
	    CODE_LABEL == GET_CODE ( peek ) ||
	    BARRIER == GET_CODE ( peek ) )
	{
	    return CC_UNKNOWN;
	}
	if ( INSN == GET_CODE ( peek ) &&
	    PARALLEL == GET_CODE ( PATTERN ( peek )) &&
	    SET == GET_CODE ( XVECEXP ( PATTERN ( peek ), 0, 0 )) &&
	    0 == strcmp ( GET_RTX_FORMAT ( GET_CODE ( XEXP ( XVECEXP ( PATTERN ( peek ), 0, 0 ), 1 ))), "ee" ) &&
	    ( cc0_rtx == XEXP ( XEXP ( XVECEXP ( PATTERN ( peek ), 0, 0 ), 1 ), 0 ) ||
	     cc0_rtx == XEXP ( XEXP ( XVECEXP ( PATTERN ( peek ), 0, 0 ), 1 ), 1 )))
	{
	    jump_code = GET_CODE ( XEXP ( XVECEXP ( PATTERN ( peek ), 0, 0 ), 1 ));
	    
	    if ( GEU == jump_code || GTU == jump_code || LEU == jump_code
		|| LTU == jump_code )
	    {
		return CC_UNSIGNED;
	    }
	    else
	    {
		return CC_SIGNED;
	    }
	}
    }

    if (( NULL == peek ) || 
	( JUMP_INSN != GET_CODE ( peek )) ||
	( SET != GET_CODE ( PATTERN ( peek ))) ||
	( IF_THEN_ELSE != GET_CODE ( XEXP ( PATTERN ( peek ), 1 ))))
    {
	return CC_UNKNOWN;
    }
    jump_code = GET_CODE ( XEXP ( XEXP ( PATTERN ( peek ), 1 ), 0 ));
    
    if ( GEU == jump_code || GTU == jump_code || LEU == jump_code
	|| LTU == jump_code || EQU == jump_code || NEU == jump_code )
    {
	return CC_UNSIGNED;
    }
    else
    {
	return CC_SIGNED;
    }
}

/* hard_regno_mode_ok -
 * this global function implements the tm-m56k.h file macro of the same name.
 * a 1 is returned if regno can be used to hold a value of type mode.
 */

int
hard_regno_mode_ok ( regno, mode )
    int regno;
    int mode;
{
    switch ( mode )
    {
    case VOIDmode:
	return 1;
	
    case SFmode:
    case DFmode:
    case DImode:
	/* for doubles, floats, and longs, we need 48-bit registers. */
	if ( DSP56_X0_REGNUM == regno || DSP56_Y0_REGNUM == regno ||
	    DSP56_A_REGNUM == regno || DSP56_B_REGNUM == regno )
	{
	    return 1;
	}
	else
	{
	    return 0;
	}
	break;

    case PSImode:
	/* for pointers we can use any register. */
	return 1;
	
    default:
	/* for all other cases, we assume that a 24-bit reg is needed. */
	if ( regno < 6 )
	{
	    return 1;
	}
	else
	{
	    return 0;
	}
	break;
    }
}

/* modes_tieable_p -
 * this global function implements the tm-m56k.h file macro of the same name.
 * a 1 is returned if both modes can always use the same pseudo register.
 */

int
modes_tieable_p ( mode1, mode2 )
    int mode1;
    int mode2;
{
    if ( mode1 == mode2 )
    {
	return 1;
    }
    
    switch ( mode1 )
    {
    case SFmode:
    case DFmode:
    case DImode:
	if ( SFmode == mode2 || DFmode == mode2 || DImode == mode2 )
	{
	    return 1;
	}
	else
	{
	    return 0;
	}
	break;
    }
    return 0;
}

/* regno_reg_class -
 * this global function implements the tm-m56k.h file macro of the same name.
 * the class number of the smallest class containing reg number regno is
 * returned.
 */

enum reg_class
regno_reg_class ( regno )
    int regno;
{
    switch ( regno )
    {
    case DSP56_X0_REGNUM:
    case DSP56_Y0_REGNUM:
	return MPY_REGS;
	
    case DSP56_X1_REGNUM:
    case DSP56_Y1_REGNUM:
	return SRC_REGS;

    case DSP56_A_REGNUM:
    case DSP56_B_REGNUM:
	return DST_REGS;

    default:
	if ( regno < 14 )
	{
	    return ADDR_REGS;
	}
	return ALL_REGS;
    }
}


/* reg_class_from_letter -
 * this global function implements the tm-m56k.h file macro of the same name.
 * the class number of the given letter is returned.
 */

enum reg_class
reg_class_from_letter ( c )
    char c;
{
    switch ( c )
    {
    case 'S':
	return SRC_REGS;
    case 'D':
	return DST_REGS;
    case 'A':
	return ADDR_REGS;
    case 'R':
	return MPY_REGS;
	
    default:
	return NO_REGS;
    }
}

/* reg_class_from_letter -
 * this global function implements the tm-m56k.h file macro of the same name.
 * the max number of consecutive registers needed per mode is returned.
 */

int
class_max_nregs ( class, mode )
    int class;
    int mode;
{
    if (( SFmode == mode || DFmode == mode || DImode == mode ) &&
	( SRC_REGS == class ))
    {
	return 2;
    }
    else
    {
	return 1;
    }
}

/* ---------------------------------------------------------------- *\
   
   name         dgetmant

   synopsis     dgetmant(dfptval, wordnum)
                double dfptval;
		int wordnum;

   description
      Inputs:
         dfptval = double precision value from which mantissa is extracted
         wordnum:  0 = upper 20 bits (leading 1 suppressed)
         1 = lower 32 bits

   return value 

\* ---------------------------------------------------------------- */

long dgetmant(dfptval, wordnum)
double dfptval;
int    wordnum;
{
   long *ivalptr;

   ivalptr = (long *) &dfptval;

#if defined( _MSDOS ) || defined( MIPSEL )
   if (wordnum == 0)
      return( ((*(ivalptr+1))) & 0x000fffffL);
   else   /* lower word */
      return( *(ivalptr) );
#else
   if (wordnum == 0)
      return( ((*ivalptr)) & 0x000fffff);
   else   /* lower word */
      return( *(ivalptr+1) );
#endif
}
 


long dgetexp(dfptval)
double dfptval;
{
   long *ivalptr;

   ivalptr = (long *) &dfptval;
#if defined( _MSDOS ) || defined( MIPSEL )
   ivalptr++;
#endif
   return( ((*ivalptr)>>20) & 0x07ff );       /* masks sign bit too */
}

union real_extract adjusted_dval;

void
dtok ( file, davey )
    FILE* file;
    double davey;
{
    union real_extract dval;
    unsigned long   L_word, H_word, tmp, tmp2, dsgn;
    long   increase_exponent;
    
    dval.d = davey;

    if ( dval.d == 0 )
    {
	H_word = L_word = 0;
    }
    else
    {
	L_word = dgetexp(dval.d);       /* ieee exponent */
	H_word = dgetmant(dval.d,0);    /* grab upper 20 bits of double */
	tmp2=dgetmant(dval.d,1);        /* lower 32 bits of ieee mantissa */

	/* ieee denormalized number */
	if ( L_word == 0 )
	{
	    L_word++; /* try it*/

	    /* normalize it */	    
	    while ( ! ( H_word & 0x100000 ) )
	    {
		L_word -- ;      /* exponent decreases */
		H_word <<= 1 ;   /* shift entire 52 bit ieee mantissa left */
		
		if ( tmp2 & 0x80000000l )
		{
		    H_word |= 1 ;
		}
	       
		tmp2 <<= 1 ;
	    }
	}

	/* normalized ieee number with implied leading 1 */
	else
	{
	    H_word |= 0x00100000;      /* add leading 1 */
	}
       
	H_word <<= 10;
	tmp = ((tmp2 & 0xc0000000) >> 1);   /* grab lower 2 bits */
	tmp >>= 21;                         /* ------------------- */
	H_word |= tmp;                      /* combine upper and lower */
	increase_exponent=0;

	/* round up for 1/2 lsb of kp mantissa */
	if ( tmp2 & 0x20000000l )
	{
	    if ( H_word >= 0x7fffff00 )
	    {
		increase_exponent = 1;
		H_word += 0x100;
		H_word >>= 1;
	    }
	    
	    else
	    {
		H_word += 0x100;
	    }
	}


#if defined( _MSDOS ) || defined( MIPSEL )
	dsgn = ( * (long *) &(dval.i[1]) ) & 0x80000000l;
#else   /* real computers */
	dsgn = ( * (long *) &(dval.i[0]) ) & 0x80000000l;
#endif

	/* check for negative value in ieee format */
	if ( dsgn )
	{
	    H_word = -H_word;
	}  
       
	H_word >>= 8;
	L_word -= 1023;             /* IEEE double precision bias  */
	L_word += 8191;             /* kevFP little precision bias */
	L_word ++;                  /* lameFP s.xxx..xx */
	L_word += increase_exponent; /* in case rounding modified exponent */
	
	/* negative weird case ( -0.5 == 800000  not c00000 ) */
	if ( (H_word & 0x800000) && (H_word & 0x400000) )
	{
	    H_word <<= 1;
	    L_word--;
	}  
    }
   
    
    if ( NULL != file )
    {
	if ( 'l' == memory_model )
	{
	    fprintf ( file, "\tdc\t$%06x%06x\n", H_word & 0xffffff,
		     L_word & 0xffffff );
	}
	else
	{
	    fprintf ( file, "\tdc\t$%06x\n\tdc\t$%06x\n", L_word & 0xffffff,
		     H_word & 0xffffff );
	}
    }
    
    adjusted_dval.i[1] = ( 0x00ffffff & H_word );
    adjusted_dval.i[0] = ( 0x00ffffff & L_word );
}


int
local_first_parm_offset ( fundecl ) 
    tree fundecl;
{
    tree arg_list;
    
#if 0
    if (( NULL == fundecl ) ||
	( NULL == ( arg_list = DECL_ARGUMENTS ( fundecl ))))
    {
	return -4;
    }
    
    return - int_size_in_bytes ( DECL_ARG_TYPE ( arg_list )) + -3;
#else
    return -2;
#endif    
}

void
print_operand ( file, x, code )
    FILE* file;
    rtx x;
    char code;
{
    rtx ensure_pointer_result_size ( );
    rtx ensure_integer_result_size ( );
    
    if ( 'p' == code )
    {
	x = ensure_pointer_result_size ( copy_rtx ( x ));

	output_addr_const ( file, x );
	return;
    }
    else if ( 'q' == code )
    {
	x = ensure_integer_result_size ( copy_rtx ( x ));

	output_addr_const ( file, x );
	return;
    }
    
    switch ( GET_CODE ( x ) )
    {
    case REG:
	switch ( code )
	{
	case 'd':
	    fprintf ( file, "%s", reg_names[ REGNO ( x ) ] );
	    break;
	    
	case 'e':
	    if ( DST_REGS == REGNO_REG_CLASS ( REGNO ( x )))
	    {
		if ( MEM_IN_STRUCT_P ( x ))
		{
		    /* see comment in final.c */
		    fprintf ( file, "%s0", reg_names[ REGNO ( x ) ] );
		}
		else
		{
		    fprintf ( file, "%s1", reg_names[ REGNO ( x ) ] );
		}
	    }
	    else
	    {
		fprintf ( file, "%s", reg_names[ REGNO ( x ) ] );
	    }
	    break;
	    
	case 'g':
	    fprintf ( file, "%s", reg_names[ REGNO ( x ) ^ 1 ] );
	    break;
	    
	case 'h':
	    fprintf ( file, "%s0", reg_names[ REGNO ( x ) ] );
	    break;

	case 'i':
	    fprintf ( file, "%c", *( reg_names[ REGNO ( x ) ] ));
	    break;

	case 'j':
	    fprintf ( file, "n%c", * ( reg_names[ REGNO ( x ) ] + 1 ));
	    break;
	    
	case 'k':
	    fprintf ( file, "%s2", reg_names[ REGNO ( x ) ] );
	    break;
	    
	case 'm':
	    fprintf ( file, "%c", (reg_names[ REGNO ( x ) ])[0] );
	    break;
	    
	case 'o':
	    fprintf ( file, "%c10", (reg_names[ REGNO ( x ) ])[0] );
	    break;
	    
	default:
	    if ( MEM_IN_STRUCT_P ( x ))
	    {
		/* see comment in final.c */
		fprintf ( file, "%s0", reg_names[ REGNO ( x ) ] );
	    }
	    else
	    {
		fprintf ( file, "%s", reg_names[ REGNO ( x ) ] );
	    }
	    break;
	}
	break;
	
    case MEM:
	switch ( code )
	{
	case 'f':
	    /* print out a 'l' instead of an x or y when we need to */
	    if (( 'l' == memory_model ) && 
		(( DImode == GET_MODE ( x )) ||
		 ( SFmode == GET_MODE ( x )) ||
		 ( DFmode == GET_MODE ( x ))))
	    {
		fprintf ( file, "l:" );
	    }
	    else
	    {
		fprintf ( file, "%c:", mem_space );
	    }
	    output_address ( ensure_pointer_result_size 
			    ( copy_rtx ( XEXP ( x, 0 ))));
	    break;
	    
	default:
	    output_address ( ensure_pointer_result_size 
			    ( copy_rtx ( XEXP ( x, 0 ))));
	}
	return;

    case CONST_INT:
	if ( 0 == ( INTVAL ( x ) >> 8 ))
	{
	    fprintf ( file, "#>$%02x", INTVAL ( x ) );
	}
	else
	{
	    fprintf ( file, "#>$%06x", INTVAL ( x ) );
	}
	return;

    default:
#if 0
	fprintf ( file, "#" );
	if ( CONSTANT_ADDRESS_P ( x ))
	{
	    output_addr_const ( file, x );
	}
	else
	{
	    output_operand ( x, 'c' );
	}
#endif
	abort ( );
    }
}

void
simplify_cse_victims ( first )
    rtx first;
{
    rtx point, elem;
    
    while ( first )
    {
	/* is it a 3 element PARALLEL ? */
	if (( INSN == GET_CODE ( first )) &&
	    ( point = PATTERN ( first ), PARALLEL == GET_CODE ( point )) &&
	    ( 3 == XVECLEN ( point, 0 )) &&

	    /* is the 1st element a ( SET ( REG ) ( REG / CONST_INT )) ? */
	    ( elem = XVECEXP ( point, 0, 0 ), SET == GET_CODE ( elem )) &&
	    ( REG == GET_CODE ( SET_DEST ( elem ))) &&
	    (( REG == GET_CODE ( SET_SRC ( elem ))) ||
	     ( CONST == GET_CODE ( SET_SRC ( elem ))) ||
	     ( CONST_INT == GET_CODE ( SET_SRC ( elem )))) &&

	    /* is the 2nd element a ( CLOBBER ( REG )) ? */
	    ( elem = XVECEXP ( point, 0, 1 ), CLOBBER == GET_CODE ( elem )) &&
	    ( REG == GET_CODE ( XEXP ( elem, 0 ))) &&

	    /* is the 3rd element a ( CLOBBER ( REG )) ? */
	    ( elem = XVECEXP ( point, 0, 2 ), CLOBBER == GET_CODE ( elem )) &&
	    ( REG == GET_CODE ( XEXP ( elem, 0 ))))
	{
	    /* we've got a blown-out div template ! substitute with a simple
	       ( SET ( REG ) ( REG / CONST_INT )) (note: really the 1st 
	       element of the parallel). */

	    PATTERN ( first ) = XVECEXP ( point, 0, 0 );
	}
	first = NEXT_INSN ( first );
    }
}


static int
mpy_insn_p ( insn )
    rtx insn;
{
    return (( INSN == GET_CODE ( insn )) &&
	    ( SET == GET_CODE ( PATTERN ( insn ))) &&
	    ( REG == GET_CODE ( SET_DEST ( PATTERN ( insn )))) &&
	    ( MULT == GET_CODE ( SET_SRC ( PATTERN ( insn )))));
}

static int
mac_insn_p ( insn )
    rtx insn;
{
    /* mac +/- shape detector. */
    return (( INSN == GET_CODE ( insn )) &&
	    ( SET == GET_CODE ( PATTERN ( insn ))) &&
	    ( REG == GET_CODE ( SET_DEST ( PATTERN ( insn )))) &&
	    (( PLUS == GET_CODE ( SET_SRC ( PATTERN ( insn )))) ||
	     ( MINUS == GET_CODE ( SET_SRC ( PATTERN ( insn ))))) &&
	    (( MULT == GET_CODE ( XEXP ( SET_SRC ( PATTERN ( insn )), 0 ))) ||
	     ( MULT == GET_CODE ( XEXP ( SET_SRC ( PATTERN ( insn )), 1 )))));
}

static rtx
mac_addative_input ( mac )
    rtx mac;
{
    return ( MULT == GET_CODE ( XEXP ( SET_SRC ( PATTERN ( mac )), 0 ))) ?
	XEXP ( SET_SRC ( PATTERN ( mac )), 1 ) :
	    XEXP ( SET_SRC ( PATTERN ( mac )), 0 );
}

void
reduce_norm_freq ( first )
    rtx first;
{
    /* point to the last insn.
       search up the list for each mac insn:
           detemine the addative_input.
	   foreach insn in LOG_LINKS( point ):
	       if insn SETs the addative_input, and insn is a mac or mpy, and
	          there are no reload generated references to the operand
		  between these two instructions, then:
	           mark the pointed to mac as not needing input normalization
		   mark the mpy/mac insn as not needing output normalization.
       
       the templates for mpy/mac will check for these flags. */

    rtx last = first, point;
    
    /* find the last insn, search up from it */
    while ( NULL != NEXT_INSN ( last ))
    {
	last = NEXT_INSN ( last );
    }

    while ( last != first )
    {
	if ( mac_insn_p ( last ))
	{
	    rtx add_in = mac_addative_input ( last );
	    rtx insn_chain = LOG_LINKS ( last );
	    
	    while ( NULL != insn_chain )
	    {
		rtx this_insn = XEXP ( insn_chain, 0 );

		if ((( mac_insn_p ( this_insn )) ||
		     ( mpy_insn_p ( this_insn ))) &&
		    ( add_in == SET_DEST ( PATTERN ( this_insn ))) &&
		    ( ! reg_used_between_p ( add_in, this_insn, last )))
		{
		    /* kludge up: re-use existing flags, in_struct and used, 
		       to inhibit the emission of normalization code at the
		       front and back end of mac (and mpy) instructions. */

		    /* turn off last's pre-norm. */
		    MEM_IN_STRUCT_P ( last ) = 1;
		    
		    /* turn off this_insn's post-norm. */
		    RTX_UNCHANGING_P ( this_insn ) = 1;
		}
		insn_chain = XEXP ( insn_chain, 1 );
	    }
	}
	last = PREV_INSN ( last );
    }
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
    current_func_info |= FUNC_HAS_STACK_PARMS;

    return FUNCTION_ARG (cum, mode, type, named);
}

#define N_REG_COUNT 8
#define FIRST_N_REG 6

static rtx current_n_reg_value[ N_REG_COUNT ];

void
clear_n_reg_values ( )
{
    int i = N_REG_COUNT;
    
    while ( i -- )
    {
	current_n_reg_value[i] = NULL;
    }
}

int
load_n_reg_p ( reg, new_value )
    rtx reg, new_value;
{
    if ( current_n_reg_value[ REGNO ( reg ) - FIRST_N_REG ] &&
	rtx_equal_p ( current_n_reg_value[ REGNO ( reg ) - FIRST_N_REG ], 
		      new_value ) &&
	CONSTANT_P ( new_value ))
    {
	return 0;
    }
    else
    {
	current_n_reg_value[ REGNO ( reg ) - FIRST_N_REG ] =  new_value;

	return 1;
    }
}
	
/* sort the compares into the signed and unsigned varieties. */
void
sort_compares ( insns )
    rtx insns;
{
    while ( insns )
    {
	if (( INSN == GET_CODE ( insns )) &&
	    ( SET == GET_CODE ( PATTERN ( insns ))) &&
	    ( cc0_rtx == SET_DEST ( PATTERN ( insns ))) &&
	    ( CC_UNSIGNED == next_cc_use ( insns )))
	{
	    /* note that this is an unsigned (slow) compare. we must
	       re-recog it in case this means we'll match a different
	       insn. making the insn code -1 ensures that recog will 
	       be re-run. */
	    UNSIGNED_COMPARE_P ( insns ) = 1;
	    INSN_CODE ( insns ) = -1;
	}
	insns = NEXT_INSN ( insns );
    }
}

char*
move_singleword ( operands )
    rtx *operands;
{
    extern char mem_space;
    
    if (( rtx_equal_p ( operands[0], operands[1] )) &&
	(( REG != GET_CODE ( operands[0] )) ||
	 ( ! MEM_IN_STRUCT_P ( operands[0] ))) &&
	(( REG != GET_CODE ( operands[1] )) ||
	 ( ! MEM_IN_STRUCT_P ( operands[1] ))))
    {
	/* if we're doing a nop move, return a null string. note that
	   an insn could look like a nop move isasmuchas rtx_equal_p returns
	   true; however the MEM_IN_STRUCT_P kludge used by alter_subreg ( )
	   (final.c) may indicate a move from the LSW of a long to an int
	   in the same accumulator. */

	return "";
    }
    
    switch ( which_alternative )
    {
    case 0:
	if ( MEM_IN_STRUCT_P ( operands[0] ) || 
	    MEM_IN_STRUCT_P ( operands[1] ))
	{
	    return "move	%1,%0";
	}
	else
	{
	    return "tfr	%1,%0";
	}

    case 1:
	return "move	%e1,%0";
	
    case 2:
	if ( PLUS == GET_CODE ( XEXP ( operands[0], 0 )))
	{
	    if ( REG == GET_CODE ( XEXP ( XEXP ( operands[0], 0 ), 0 )))
	    {
		operands[2] = XEXP ( XEXP ( operands[0], 0 ), 0 );
		operands[3] = XEXP ( XEXP ( operands[0], 0 ), 1 );
	    }
	    else
	    {
		operands[2] = XEXP ( XEXP ( operands[0], 0 ), 1 );
		operands[3] = XEXP ( XEXP ( operands[0], 0 ), 0 );
	    }
	    
	    if ( CONST_INT != GET_CODE ( operands[3] ))
	    {
		if ( load_n_reg_p ( operands[2], operands[3] ))
		{
		    RETURN_DSP ( "move	#%p3,%j2\n\tmove	%e1,@:(%2+%j2)" );
		}
		else
		{
		    RETURN_DSP ( "move	%e1,@:(%2+%j2)" );
		}
	    }
	    
	    switch ( INTVAL ( operands[3] ))
	    {
	    case 0:
		RETURN_DSP ( "move	%e1,@:(%2)" );
		    
	    case 1:
		if ( REGNO ( operands[2] ) != REGNO ( operands[1] ))
		{
		    RETURN_DSP ( "move	(%2)+\n\tmove	%e1,@:(%2)-" );
		}
		    
	    case -1:
		if ( REGNO ( operands[2] ) != REGNO ( operands[1] ))
		{
		    RETURN_DSP ( "move	(%2)-\n\tmove	%e1,@:(%2)+" );
		}
		
	    default:
		if ( load_n_reg_p ( operands[2], operands[3] ))
		{
		    RETURN_DSP ( "move	#%p3,%j2\n\tmove	%e1,@:(%2+%j2)" );
		}
		else
		{
		    RETURN_DSP ( "move	%e1,@:(%2+%j2)" );
		}
	    }
	}
	else
	{
	    return "move	%e1,%f0";
	}
	
    case 3:
	if ( PLUS == GET_CODE ( XEXP ( operands[1], 0 )))
	{
	    if ( REG == GET_CODE ( XEXP ( XEXP ( operands[1], 0 ), 0 )))
	    {
		operands[2] = XEXP ( XEXP ( operands[1], 0 ), 0 );
		operands[3] = XEXP ( XEXP ( operands[1], 0 ), 1 );
	    }
	    else
	    {
		operands[2] = XEXP ( XEXP ( operands[1], 0 ), 1 );
		operands[3] = XEXP ( XEXP ( operands[1], 0 ), 0 );
	    }
	    
	    if ( CONST_INT != GET_CODE ( operands[3] ))
	    {
		if ( load_n_reg_p ( operands[2], operands[3] ))
		{
		    RETURN_DSP ( "move	#%p3,%j2\n\tmove	@:(%2+%j2),%0" );
		}
		else
		{
		    RETURN_DSP ( "move	@:(%2+%j2),%0" );
		}
	    }
	    
	    switch ( INTVAL ( operands[3] ))
	    {
	    case 0:
		RETURN_DSP ( "move	@:(%2),%0" );
		    
	    case 1:
		if ( REGNO ( operands[0] ) != REGNO ( operands[2] ))
		{
		    RETURN_DSP ( "move	(%2)+\n\tmove	@:(%2)-,%0" );
		}
		    
	    case -1:
		if ( REGNO ( operands[0] ) != REGNO ( operands[2] ))
		{
		    RETURN_DSP ( "move	(%2)-\n\tmove	@:(%2)+,%0" );
		}
		
	    default:
		if ( load_n_reg_p ( operands[2], operands[3] ))
		{
		    RETURN_DSP ( "move	#%p3,%j2\n\tmove	@:(%2+%j2),%0" );
		}
		else
		{
		    RETURN_DSP ( "move	@:(%2+%j2),%0" );
		}
	    }
	}
	else
	{
	    return "move	%f1,%0";
	}
	
    case 4:
	if ( 0 == INTVAL ( operands[1] ))
	{
	    if ( DST_REGS == REGNO_REG_CLASS ( REGNO ( operands[0] )))
	    {
		return "clr	%0";
	    }
	    else
	    {
		return "move	#%c1,%0";
	    }
	}
	else
	{
	    return "move	#>%q1,%0";
	}
    }
}

char*
move_doubleword ( is_float_p, operands )
    int is_float_p;
    rtx *operands;
{
    extern char mem_space;
    extern union real_extract adjusted_dval;

    if ( rtx_equal_p ( operands[0], operands[1] ))
    {
	return "";
    }
    
    switch ( which_alternative )
    {
    case 0:
	if ( IS_SRC_OR_MPY_P ( REGNO ( operands[1] )))
	{
	    if ( MEM_IN_STRUCT_P ( operands[0] )  ||
		MEM_IN_STRUCT_P ( operands[1] ))
	    {
		return "move	%g1,%0\n\tmove	%1,%h0";
	    }
	    else
	    {
		return "tfr	%g1,%0\n\tmove	%1,%h0";
	    }
	}
	else
	{
	    if ( MEM_IN_STRUCT_P ( operands[0] )  ||
		MEM_IN_STRUCT_P ( operands[1] ))
	    {
		return "move	%1,%0";
	    }
	    else
	    {
		return "tfr	%1,%0";
	    }
	}

    case 1:
	if ( IS_SRC_OR_MPY_P ( REGNO ( operands[1] )))
	{
	    return "move	%g1,%g0\n\tmove	%1,%0";
	}
	else
	{
	    return "move	%e1,%g0\n\tmove	%h1,%0";
	}

    case 2:
	if ( 'l' == memory_model )
	{
	    if ( PLUS == GET_CODE ( XEXP ( operands[0], 0 )))
	    {
		if ( REG == GET_CODE ( XEXP ( XEXP ( operands[0], 0 ), 0 )))
		{
		    operands[2] = XEXP ( XEXP ( operands[0], 0 ), 0 );
		    operands[3] = XEXP ( XEXP ( operands[0], 0 ), 1 );
		}
		else
		{
		    operands[2] = XEXP ( XEXP ( operands[0], 0 ), 1 );
		    operands[3] = XEXP ( XEXP ( operands[0], 0 ), 0 );
		}
		
		if ( CONST_INT != GET_CODE ( operands[3] ))
		{
		    if ( IS_SRC_OR_MPY_P ( REGNO ( operands[1] )))
		    {
			if ( load_n_reg_p ( operands[2], operands[3] ))
			{
			    return "move	#%p3,%j2\n\tmove	%m1,l:(%2+%j2)";
			}
			else
			{
			    return "move	%m1,l:(%2+%j2)";
			}
		    }
		    else
		    {
			if ( load_n_reg_p ( operands[2], operands[3] ))
			{
			    return "move	#%p3,%j2\n\tmove	%o1,l:(%2+%j2)";
			}
			else
			{
			    return "move	%o1,l:(%2+%j2)";
			}
		    }
		}
		
		switch ( INTVAL ( operands[3] ))
		{
		case 0:
		    if ( IS_SRC_OR_MPY_P ( REGNO ( operands[1] )))
		    {
			return "move	%m1,l:(%2)";
		    }
		    else
		    {
			return "move	%o1,l:(%2)";
		    }
		    
		case 1:
		    if ( IS_SRC_OR_MPY_P ( REGNO ( operands[1] )))
		    {
			return "move	(%2)+\n\tmove	%m1,l:(%2)-";
		    }
		    else
		    {
			return "move	(%2)+\n\tmove	%o1,l:(%2)-";
		    }
		    
		case -1:
		    if ( IS_SRC_OR_MPY_P ( REGNO ( operands[1] )))
		    {
			return "move	(%2)-\n\tmove	%m1,l:(%2)+";
		    }
		    else
		    {
			return "move	(%2)-\n\tmove	%o1,l:(%2)+";
		    }
		    
		default:
		    if ( IS_SRC_OR_MPY_P ( REGNO ( operands[1] )))
		    {
			if ( load_n_reg_p ( operands[2], operands[3] ))
			{
			    return "move	#%p3,%j2\n\tmove	%m1,l:(%2+%j2)";
			}
			else
			{
			    return "move	%m1,l:(%2+%j2)";
			}
		    }
		    else
		    {
			if ( load_n_reg_p ( operands[2], operands[3] ))
			{
			    return "move	#%p3,%j2\n\tmove	%o1,l:(%2+%j2)";
			}
			else
			{
			    return "move	%o1,l:(%2+%j2)";
			}
		    }
		}
	    }
	    else
	    {
		if ( IS_SRC_OR_MPY_P ( REGNO ( operands[1] )))
		{
		    return "move	%m1,%f0";
		}
		else
		{
		    return "move	%o1,%f0";
		}
	    }
	}
	else /* memory_model is x or y. */
	{
	    if ( PLUS == GET_CODE ( XEXP ( operands[0], 0 )))
	    {
		if ( REG == GET_CODE ( XEXP ( XEXP ( operands[0], 0 ), 0 )))
		{
		    operands[2] = XEXP ( XEXP ( operands[0], 0 ), 0 );
		    operands[3] = XEXP ( XEXP ( operands[0], 0 ), 1 );
		}
		else
		{
		    operands[2] = XEXP ( XEXP ( operands[0], 0 ), 1 );
		    operands[3] = XEXP ( XEXP ( operands[0], 0 ), 0 );
		}
		
		if ( CONST_INT != GET_CODE ( operands[3] ))
		{
		    if ( IS_SRC_OR_MPY_P ( REGNO ( operands[1] )))
		    {
			if ( load_n_reg_p ( operands[2], operands[3] ))
			{
			    RETURN_DSP ( "move	#%p3,%j2\n\tmove	(%2)+\n\tmove	(%2)+%j2\n\tmove	%g1,@:(%2)-\n\tmove	%1,@:(%2)-%j2" );
			}
			else
			{
			    RETURN_DSP ( "move	(%2)+\n\tmove	(%2)+%j2\n\tmove	%g1,@:(%2)-\n\tmove	%1,@:(%2)-%j2" );
			}
		    }
		    else
		    {
			if ( load_n_reg_p ( operands[2], operands[3] ))
			{
			    RETURN_DSP ( "move	#%p3,%j2\n\tmove	(%2)+\n\tmove	(%2)+%j2\n\tmove	%e1,@:(%2)-\n\tmove	%h1,@:(%2)-%j2" );
			}
			else
			{
			    RETURN_DSP ( "move	(%2)+\n\tmove	(%2)+%j2\n\tmove	%e1,@:(%2)-\n\tmove	%h1,@:(%2)-%j2" );
			}
		    }
		}
		
		switch ( INTVAL ( operands[3] ))
		{
		case 0:
		    if ( IS_SRC_OR_MPY_P ( REGNO ( operands[1] )))
		    {
			RETURN_DSP ( "move	%1,@:(%2)+\n\tmove	%g1,@:(%2)-" );
		    }
		    else
		    {
			RETURN_DSP ( "move	%h1,@:(%2)+\n\tmove	%e1,@:(%2)-" );
		    }
		    
		case 1:
		    if ( IS_SRC_OR_MPY_P ( REGNO ( operands[1] )))
		    {
			RETURN_DSP ( "move	(%2)+\n\tmove	%1,@:(%2)+\n\tmove	%g1,@:(%2)-\n\tmove	(%2)-" );
		    }
		    else
		    {
			RETURN_DSP ( "move	(%2)+\n\tmove	%h1,@:(%2)+\n\tmove	%e1,@:(%2)-\n\tmove	(%2)-" );
		    }
		    
		case -1:
		    if ( IS_SRC_OR_MPY_P ( REGNO ( operands[1] )))
		    {
			RETURN_DSP ( "move	(%2)-\n\tmove	%g1,@:(%2)-\n\tmove	%1,@:(%2)+\n\tmove	(%2)+" );
		    }
		    else
		    {
			RETURN_DSP ( "move	(%2)-\n\tmove	%e1,@:(%2)-\n\tmove	%h1,@:(%2)+\n\tmove	(%2)+" );
		    }
		    
		default:
		    if ( IS_SRC_OR_MPY_P ( REGNO ( operands[1] )))
		    {
			if ( load_n_reg_p ( operands[2], operands[3] ))
			{
			    RETURN_DSP ( "move	#%p3,%j2\n\tmove	(%2)+\n\tmove	(%2)+%j2\n\tmove	%g1,@:(%2)-\n\tmove	%1,@:(%2)-%j2" );
			}
			else
			{
			    RETURN_DSP ( "move	(%2)+\n\tmove	(%2)+%j2\n\tmove	%g1,@:(%2)-\n\tmove	%1,@:(%2)-%j2" );
			}
		    }
		    else
		    {
			if ( load_n_reg_p ( operands[2], operands[3] ))
			{
			    RETURN_DSP ( "move	#%p3,%j2\n\tmove	(%2)+\n\tmove	(%2)+%j2\n\tmove	%e1,@:(%2)-\n\tmove	%h1,@:(%2)-%j2" );
			}
			else
			{
			    RETURN_DSP ( "move	(%2)+\n\tmove	(%2)+%j2\n\tmove	%e1,@:(%2)-\n\tmove	%h1,@:(%2)-%j2" );
			}
		    }
		}
	    }
	    else if ( POST_INC == GET_CODE ( XEXP ( operands[0], 0 )))
	    {
		operands[2] = XEXP ( XEXP ( operands[0], 0 ), 0 );
		
		if ( IS_SRC_OR_MPY_P ( REGNO ( operands[1] )))
		{
		    RETURN_DSP ( "move	%1,@:(%2)+\n\tmove	%g1,@:(%2)+" );
		}
		else
		{
		    RETURN_DSP ( "move	%h1,@:(%2)+\n\tmove	%e1,@:(%2)+" );
		}
	    }
	    else if ( POST_DEC == GET_CODE ( XEXP ( operands[0], 0 )))
	    {
		operands[2] = XEXP ( XEXP ( operands[0], 0 ), 0 );
		
		if ( IS_SRC_OR_MPY_P ( REGNO ( operands[1] )))
		{
		    if ( load_n_reg_p ( operands[2], 
				       gen_rtx ( CONST_INT, VOIDmode, 3 )))
		    {
			RETURN_DSP ( "move	#3,%j2\n\tmove	%1,@:(%2)+\n\tmove	%g1,@:(%2)-%j2" );
		    }
		    else
		    {
			RETURN_DSP ( "move	%1,@:(%2)+\n\tmove	%g1,@:(%2)-%j2" );
		    }
		}
		else
		{
		    if ( load_n_reg_p ( operands[2], 
				       gen_rtx ( CONST_INT, VOIDmode, 3 )))
		    {
			RETURN_DSP ( "move	#3,%j2\n\tmove	%h1,@:(%2)+\n\tmove	%e1,@:(%2)-%j2" );
		    }
		    else
		    {
			RETURN_DSP ( "move	%h1,@:(%2)+\n\tmove	%e1,@:(%2)-%j2" );
		    }
		}
	    }
	    else if ( REG == GET_CODE ( XEXP ( operands[0], 0 )))
	    {
		operands[2] = XEXP ( operands[0], 0 );
		
		if ( IS_SRC_OR_MPY_P ( REGNO ( operands[1] )))
		{
		    RETURN_DSP ( "move	%1,@:(%2)+\n\tmove	%g1,@:(%2)-" );
		}
		else
		{
		    RETURN_DSP ( "move	%h1,@:(%2)+\n\tmove	%e1,@:(%2)-" );
		}
	    }
	    else
	    {
		if ( IS_SRC_OR_MPY_P ( REGNO ( operands[1] )))
		{
		    return "move	%1,%f0\n\tmove	%g1,%f0+1";
		}
		else
		{
		    return "move	%h1,%f0\n\tmove	%e1,%f0+1";
		}
	    }
	}
	
    case 3:
	if ( 'l' == memory_model )
	{
	    if ( PLUS == GET_CODE ( XEXP ( operands[1], 0 )))
	    {
		if ( REG == GET_CODE ( XEXP ( XEXP ( operands[1], 0 ), 0 )))
		{
		    operands[2] = XEXP ( XEXP ( operands[1], 0 ), 0 );
		    operands[3] = XEXP ( XEXP ( operands[1], 0 ), 1 );
		}
		else
		{
		    operands[2] = XEXP ( XEXP ( operands[1], 0 ), 1 );
		    operands[3] = XEXP ( XEXP ( operands[1], 0 ), 0 );
		}
		
		if ( CONST_INT != GET_CODE ( operands[3] ))
		{
		    if ( IS_SRC_OR_MPY_P ( REGNO ( operands[0] )))
		    {
			if ( load_n_reg_p ( operands[2], operands[3] ))
			{
			    return "move	#%p3,%j2\n\tmove	l:(%2+%j2),%m0";
			}
			else
			{
			    return "move	l:(%2+%j2),%m0";
			}
		    }
		    else
		    {
			if ( load_n_reg_p ( operands[2], operands[3] ))
			{
			    return "move	#%p3,%j2\n\tmove	l:(%2+%j2),%0";
			}
			else
			{
			    return "move	l:(%2+%j2),%0";
			}
		    }
		}
		
		switch ( INTVAL ( operands[3] ))
		{
		case 0:
		    if ( IS_SRC_OR_MPY_P ( REGNO ( operands[0] )))
		    {
			return "move	l:(%2),%m0";
		    }
		    else
		    {
			return "move	l:(%2),%0";
		    }
		    
		case 1:
		    if ( IS_SRC_OR_MPY_P ( REGNO ( operands[0] )))
		    {
			return "move	(%2)+\n\tmove	l:(%2)-,%m0";
		    }
		    else
		    {
			return "move	(%2)+\n\tmove	l:(%2)-,%0";
		    }
		    
		case -1:
		    if ( IS_SRC_OR_MPY_P ( REGNO ( operands[0] )))
		    {
			return "move	(%2)-\n\tmove	l:(%2)+,%m0";
		    }
		    else
		    {
			return "move	(%2)-\n\tmove	l:(%2)+,%0";
		    }
		    
		default:
		    if ( IS_SRC_OR_MPY_P ( REGNO ( operands[0] )))
		    {
			if ( load_n_reg_p ( operands[2], operands[3] ))
			{
			    return "move	#%p3,%j2\n\tmove	l:(%2+%j2),%m0";
			}
			else
			{
			    return "move	l:(%2+%j2),%m0";
			}
		    }
		    else
		    {
			if ( load_n_reg_p ( operands[2], operands[3] ))
			{
			    return "move	#%p3,%j2\n\tmove	l:(%2+%j2),%0";
			}
			else
			{
			    return "move	l:(%2+%j2),%0";
			}
		    }
		}
	    }
	    else
	    {
		if ( IS_SRC_OR_MPY_P ( REGNO ( operands[0] )))
		{
		    return "move	%f1,%m0";
		}
		else
		{
		    return "move	%f1,%0";
		}
	    }
	}
	else /* memory_model is x or y */
	{
	    if ( PLUS == GET_CODE ( XEXP ( operands[1], 0 )))
	    {
		if ( REG == GET_CODE ( XEXP ( XEXP ( operands[1], 0 ), 0 )))
		{
		    operands[2] = XEXP ( XEXP ( operands[1], 0 ), 0 );
		    operands[3] = XEXP ( XEXP ( operands[1], 0 ), 1 );
		}
		else
		{
		    operands[2] = XEXP ( XEXP ( operands[1], 0 ), 1 );
		    operands[3] = XEXP ( XEXP ( operands[1], 0 ), 0 );
		}
		
		if ( CONST_INT != GET_CODE ( operands[3] ))
		{
		    if ( IS_SRC_OR_MPY_P ( REGNO ( operands[0] )))
		    {
			if ( load_n_reg_p ( operands[2], operands[3] ))
			{
			    RETURN_DSP ( "move	#%p3,%j2\n\tmove	(%2)+\n\tmove	(%2)+%j2\n\tmove	@:(%2)-,%g0\n\tmove	@:(%2)-%j2,%0" );
			}
			else
			{
			    RETURN_DSP ( "move	(%2)+\n\tmove	(%2)+%j2\n\tmove	@:(%2)-,%g0\n\tmove	@:(%2)-%j2,%0" );
			}
		    }
		    else
		    {
			if ( load_n_reg_p ( operands[2], operands[3] ))
			{
			    RETURN_DSP ( "move	#%p3,%j2\n\tmove	(%2)+\n\tmove	(%2)+%j2\n\tmove	@:(%2)-,%0\n\tmove	@:(%2)-%j2,%h0" );
			}
			else
			{
			    RETURN_DSP ( "move	(%2)+\n\tmove	(%2)+%j2\n\tmove	@:(%2)-,%0\n\tmove	@:(%2)-%j2,%h0" );
			}
		    }
		}
		
		switch ( INTVAL ( operands[3] ))
		{
		case 0:
		    if ( IS_SRC_OR_MPY_P ( REGNO ( operands[0] )))
		    {
			RETURN_DSP ( "move	(%2)+\n\tmove	@:(%2)-,%g0\n\tmove	@:(%2),%0" );
		    }
		    else
		    {
			RETURN_DSP ( "move	(%2)+\n\tmove	@:(%2)-,%0\n\tmove	@:(%2),%h0" );
		    }
		    
		case 1:
		    if ( IS_SRC_OR_MPY_P ( REGNO ( operands[0] )))
		    {
			RETURN_DSP ( "move	(%2)+\n\tmove	(%2)+\n\tmove	@:(%2)-,%g0\n\tmove	@:(%2)-,%0" );
		    }
		    else
		    {
			RETURN_DSP ( "move	(%2)+\n\tmove	(%2)+\n\tmove	@:(%2)-,%0\n\tmove	@:(%2)-,%h0" );
		    }
		    
		case -1:
		    if ( IS_SRC_OR_MPY_P ( REGNO ( operands[0] )))
		    {
			RETURN_DSP ( "move	(%2)-\n\tmove	@:(%2)-,%g0\n\tmove	@:(%2)+,%0\n\tmove	(%2)+" );
		    }
		    else
		    {
			RETURN_DSP ( "move	(%2)-\n\tmove	@:(%2)-,%0\n\tmove	@:(%2)+,%h0\n\tmove	(%2)+" );
		    }
		    
		default:
		    if ( IS_SRC_OR_MPY_P ( REGNO ( operands[0] )))
		    {
			if ( load_n_reg_p ( operands[2], operands[3] ))
			{
			    RETURN_DSP ( "move	#%p3,%j2\n\tmove	(%2)+\n\tmove	(%2)+%j2\n\tmove	@:(%2)-,%g0\n\tmove	@:(%2)-%j2,%0" );
			}
			else
			{
			    RETURN_DSP ( "move	(%2)+\n\tmove	(%2)+%j2\n\tmove	@:(%2)-,%g0\n\tmove	@:(%2)-%j2,%0" );
			}
		    }
		    else
		    {
			if ( load_n_reg_p ( operands[2], operands[3] ))
			{
			    RETURN_DSP ( "move	#%p3,%j2\n\tmove	(%2)+\n\tmove	(%2)+%j2\n\tmove	@:(%2)-,%0\n\tmove	@:(%2)-%j2,%h0" );
			}
			else
			{
			    RETURN_DSP ( "move	(%2)+\n\tmove	(%2)+%j2\n\tmove	@:(%2)-,%0\n\tmove	@:(%2)-%j2,%h0" );
			}
		    }
		}
	    }
	    else if ( POST_INC == GET_CODE ( XEXP ( operands[1], 0 )))
	    {
		operands[2] = XEXP ( XEXP ( operands[1], 0 ), 0 );
		
		if ( IS_SRC_OR_MPY_P ( REGNO ( operands[0] )))
		{
		    if ( load_n_reg_p ( operands[2], 
				       gen_rtx ( CONST_INT, VOIDmode, 2 )))
		    {
			RETURN_DSP ( "move	#2,%j2\n\tmove	(%2)+\n\tmove	@:(%2)-,%g0\n\tmove	@:(%2)+%j2,%0" );
		    }
		    else
		    {
			RETURN_DSP ( "move	(%2)+\n\tmove	@:(%2)-,%g0\n\tmove	@:(%2)+%j2,%0" );
		    }
		}
		else
		{
		    if ( load_n_reg_p ( operands[2], 
				       gen_rtx ( CONST_INT, VOIDmode, 2 )))
		    {
			RETURN_DSP ( "move	#2,%j2\n\tmove	(%2)+\n\tmove	@:(%2)-,%0\n\tmove	@:(%2)+%j2,%h0" );
		    }
		    else
		    {
			RETURN_DSP ( "move	(%2)+\n\tmove	@:(%2)-,%0\n\tmove	@:(%2)+%j2,%h0" );
		    }
		}
	    }
	    else if ( POST_DEC == GET_CODE ( XEXP ( operands[1], 0 )))
	    {
		operands[2] = XEXP ( XEXP ( operands[1], 0 ), 0 );
		
		if ( IS_SRC_OR_MPY_P ( REGNO ( operands[0] )))
		{
		    if ( load_n_reg_p ( operands[2], 
				       gen_rtx ( CONST_INT, VOIDmode, 2 )))
		    {
			RETURN_DSP ( "move	#2,%j2\n\tmove	(%2)+\n\tmove	@:(%2)-,%g0\n\tmove	@:(%2)-%j2,%0" );
		    }
		    else
		    {
			RETURN_DSP ( "move	(%2)+\n\tmove	@:(%2)-,%g0\n\tmove	@:(%2)-%j2,%0" );
		    }
		}
		else
		{
		    if ( load_n_reg_p ( operands[2], 
				       gen_rtx ( CONST_INT, VOIDmode, 2 )))
		    {
			RETURN_DSP ( "move	#2,%j2\n\tmove	(%2)+\n\tmove	@:(%2)-,%0\n\tmove	@:(%2)-%j2,%h0" );
		    }
		    else
		    {
			RETURN_DSP ( "move	(%2)+\n\tmove	@:(%2)-,%0\n\tmove	@:(%2)-%j2,%h0" );
		    }
		}
	    }
	    else if ( REG == GET_CODE ( XEXP ( operands[1], 0 )))
	    {
		operands[2] = XEXP ( operands[1], 0 );
		
		if ( IS_SRC_OR_MPY_P ( REGNO ( operands[0] )))
		{
		    RETURN_DSP ( "move	(%2)+\n\tmove	@:(%2)-,%g0\n\tmove	@:(%2),%0" );
		}
		else
		{
		    RETURN_DSP ( "move	(%2)+\n\tmove	@:(%2)-,%0\n\tmove	@:(%2),%h0" );
		}
	    }
	    else
	    {
		if ( IS_SRC_OR_MPY_P ( REGNO ( operands[0] )))
		{
		    return "move	%f1+1,%g0\n\tmove	%f1,%0";
		}
		else
		{
		    return "move	%f1+1,%0\n\tmove	%f1,%h0";
		}
	    }
	}
	
    case 4:
	if ( is_float_p )
	{
	    union real_extract* watcom_stink =
		(union real_extract*) &CONST_DOUBLE_LOW ( operands[1] );
	    
	    dtok ( NULL, watcom_stink->d );
	    	
	    operands[2] =
		gen_rtx ( CONST_INT, VOIDmode, adjusted_dval.i[1] );
	
	    operands[3] = 
		gen_rtx ( CONST_INT, VOIDmode, adjusted_dval.i[0] );
	    
	    if ( IS_SRC_OR_MPY_P ( REGNO ( operands[0] )))
	    {
		return "move	#>%q2,%g0\n\tmove	#>%q3,%0";
	    }
	    else
	    {
		if ( 0 == INTVAL ( operands[3] ))
		{
		    if ( 0 == INTVAL ( operands[2] ))
		    {
			return "clr	%0";
		    }
		    else
		    {
			return "move	#>%q2,%0";
		    }
		}
		else
		{
		    return "move	#>%q2,%0\n\tmove	#>%q3,%h0";
		}
	    }
	}
	else /* not a floating constant. */
	{
	    if ( CONST_INT == GET_CODE ( operands[1] ))
	    {
		if ( IS_SRC_OR_MPY_P ( REGNO ( operands[0] )))
		{
		    if ( 0 == INTVAL ( operands[1] ))
		    {
			return "move	#0,%g0\n\tmove	#%c1,%0";
		    }
		    else if ( 0 > INTVAL ( operands[1] ))
		    {
			return "move	#-1,%g0\n\tmove	#>%q1,%0";
		    }
		    else
		    {
			return "move	#0,%g0\n\tmove	#>%q1,%0";
		    }
		}
		else
		{
		    if ( 0 == INTVAL ( operands[1] ))
		    {
			return "clr	%0";
		    }
		    else if ( 0 > INTVAL ( operands[1] ))
		    {
			return "move	#-1,%0\n\tmove	#>%q1,%h0";
		    }
		    else
		    {
			return "move	#0,%0\n\tmove	#>%q1,%h0";
		    }
		}
	    }
	    
	    operands[2] =
		gen_rtx ( CONST_INT, VOIDmode, 
			 (( CONST_DOUBLE_LOW ( operands[1] ) >> 24 ) & 0x0000ff ) |
			 (( CONST_DOUBLE_HIGH ( operands[1] ) << 8 ) & 0xffff00 ));
	    operands[3] = 
		gen_rtx ( CONST_INT, VOIDmode,
			 ( CONST_DOUBLE_LOW ( operands[1] ) & 0xffffff ));
	    
	    if ( IS_SRC_OR_MPY_P ( REGNO ( operands[0] )))
	    {
		if ( rtx_equal_p ( operands[2], operands[3] ))
		{
		    return "move	#>%q2,%g0\n\tmove	%g0,%0";
		}
		else
		{
		    return "move	#>%q2,%g0\n\tmove	#>%q3,%0";
		}
	    }
	    else
	    {
		if ( 0 == INTVAL ( operands[3] ))
		{
		    if ( 0 == INTVAL ( operands[2] ))
		    {
			return "clr	%0";
		    }
		    else
		    {
			return "move	#>%q2,%0";
		    }
		}
		else
		{
		    if ( rtx_equal_p ( operands[2], operands[3] ))
		    {
			return "move	#>%q2,%0\n\tmove	%0,%h0";
		    }
		    else
		    {
			return "move	#>%q2,%0\n\tmove	#>%q3,%h0";
		    }
		}
	    }
	}
    }
}

char*
move_pointer ( operands )
    rtx *operands;
{
    extern char mem_space;
    
    if ( rtx_equal_p ( operands[0], operands[1] ))
    {
	return "";
    }
    
    switch ( which_alternative )
    {
    case 0:
	if ( MEM_IN_STRUCT_P ( operands[0] ) || 
	    MEM_IN_STRUCT_P ( operands[1] ))
	{
	    return "move	%1,%0";
	}
	else
	{
	    return "tfr	%1,%0";
	}

    case 1:
	return "move	%e1,%0";
	
    case 2:
	if ( PLUS == GET_CODE ( XEXP ( operands[0], 0 )))
	{
	    if ( REG == GET_CODE ( XEXP ( XEXP ( operands[0], 0 ), 0 )))
	    {
		operands[2] = XEXP ( XEXP ( operands[0], 0 ), 0 );
		operands[3] = XEXP ( XEXP ( operands[0], 0 ), 1 );
	    }
	    else
	    {
		operands[2] = XEXP ( XEXP ( operands[0], 0 ), 1 );
		operands[3] = XEXP ( XEXP ( operands[0], 0 ), 0 );
	    }
	    
	    if ( CONST_INT != GET_CODE ( operands[3] ))
	    {
		if ( load_n_reg_p ( operands[2], operands[3] ))
		{
		    RETURN_DSP ( "move	#%p3,%j2\n\tmove	%e1,@:(%2+%j2)" );
		}
		else
		{
		    RETURN_DSP ( "move	%e1,@:(%2+%j2)" );
		}
	    }
	    
	    switch ( INTVAL ( operands[3] ))
	    {
	    case 0:
		RETURN_DSP ( "move	%e1,@:(%2)" );
		    
	    case 1:
		if ( REGNO ( operands[1] ) != REGNO ( operands[2] ))
		{
		    RETURN_DSP ( "move	(%2)+\n\tmove	%e1,@:(%2)-" );
		}
		    
	    case -1:
		if ( REGNO ( operands[1] ) != REGNO ( operands[2] ))
		{
		    RETURN_DSP ( "move	(%2)-\n\tmove	%e1,@:(%2)+" );
		}
		
	    default:
		if ( load_n_reg_p ( operands[2], operands[3] ))
		{
		    RETURN_DSP ( "move	#%p3,%j2\n\tmove	%e1,@:(%2+%j2)" );
		}
		else
		{
		    RETURN_DSP ( "move	%e1,@:(%2+%j2)" );
		}
	    }
	}
	else
	{
	    return "move	%e1,%f0";
	}
	
    case 3:
	if ( PLUS == GET_CODE ( XEXP ( operands[1], 0 )))
	{
	    if ( REG == GET_CODE ( XEXP ( XEXP ( operands[1], 0 ), 0 )))
	    {
		operands[2] = XEXP ( XEXP ( operands[1], 0 ), 0 );
		operands[3] = XEXP ( XEXP ( operands[1], 0 ), 1 );
	    }
	    else
	    {
		operands[2] = XEXP ( XEXP ( operands[1], 0 ), 1 );
		operands[3] = XEXP ( XEXP ( operands[1], 0 ), 0 );
	    }
	    
	    if ( CONST_INT != GET_CODE ( operands[3] ))
	    {
		if ( load_n_reg_p ( operands[2], operands[3] ))
		{
		    RETURN_DSP ( "move	#%p3,%j2\n\tmove	@:(%2+%j2),%0" );
		}
		else
		{
		    RETURN_DSP ( "move	@:(%2+%j2),%0" );
		}
	    }
	    
	    switch ( INTVAL ( operands[3] ))
	    {
	    case 0:
		RETURN_DSP ( "move	@:(%2),%0" );
		    
	    case 1:
		if ( REGNO ( operands[0] ) != REGNO ( operands[2] ))
		{
		    RETURN_DSP ( "move	(%2)+\n\tmove	@:(%2)-,%0" );
		}
		    
	    case -1:
		if ( REGNO ( operands[0] ) != REGNO ( operands[2] ))
		{
		    RETURN_DSP ( "move	(%2)-\n\tmove	@:(%2)+,%0" );
		}
		
	    default:
		if ( load_n_reg_p ( operands[2], operands[3] ))
		{
		    RETURN_DSP ( "move	#%p3,%j2\n\tmove	@:(%2+%j2),%0" );
		}
		else
		{
		    RETURN_DSP ( "move	@:(%2+%j2),%0" );
		}
	    }
	}
	else
	{
	    return "move	%f1,%0";
	}
	
    case 4:
	if ( 0 == INTVAL ( operands[1] ) ||
	    ADDR_REGS == REGNO_REG_CLASS ( REGNO ( operands[0] )))
	{
	    if ( DST_REGS == REGNO_REG_CLASS ( REGNO ( operands[0] )))
	    {
		return "clr	%0";
	    }
	    else
	    {
		return "move	#%c1,%0";
	    }
	}
	else
	{
	    return "move	#>%c1,%0";
	}
    }
}

#if 0
int
local_constant_address_p ( x )
    rtx x;
{
    static int found_label_or_symbol_p ( );
    
    switch ( GET_CODE ( x ))
    {
    case LABEL_REF:
    case SYMBOL_REF:
	return 1;

    case CONST:
	return found_label_or_symbol_p ( XEXP ( x, 0 ));

    default:
	return 0;
    }
}

static int
found_label_or_symbol_p ( x )
    rtx x;
{
    if (( LABEL_REF == GET_CODE ( x )) || ( SYMBOL_REF == GET_CODE ( x )))
    {
	return 1;
    }
    else
    { 
	char *p, *fmt = GET_RTX_FORMAT ( GET_CODE ( x ));
	
	p = fmt;

	while ( 'e' == *p )
	{
	    if ( found_label_or_symbol_p ( XEXP ( x, p - fmt )))
	    {
		return 1;
	    }
	    ++ p;
	}
    }
    return 0;
}
#endif

/* the following is a lot of bullshit to ensure that constants in the 
   assembly output *in no way* ever assume that the assembler will discard
   the carry from arithmetic operations on constants. */

static rtx ensure_signed_pointer_offsets ( );
static rtx ensure_signed_int_offsets ( );
static int find_symbol ( );

rtx
ensure_pointer_result_size ( x )
    rtx x;
{
    int mask = (~((-1) << POINTER_SIZE ));
    
    if ( CONST_INT == GET_CODE ( x ))
    {
	INTVAL ( x ) &= mask;
    }
    else if ( find_symbol ( x ))
    {
	x = ensure_signed_pointer_offsets ( x );
    }
    else
    {
	char *p, *fmt = GET_RTX_FORMAT ( GET_CODE ( x ));
	
	p = fmt;
	
	while ( '\0' != ( *p ))
	{
	    if ( 'e' == ( *p ))
	    {
		XEXP ( x, p - fmt ) =
		    ensure_pointer_result_size ( XEXP ( x, p - fmt ));
	    }
	    ++ p;
	}
    }
    return x;
}

rtx
ensure_integer_result_size ( x )
    rtx x;
{
    int mask = (~((-1) << BITS_PER_UNIT ));

    if ( CONST_INT == GET_CODE ( x ))
    {
	INTVAL ( x ) &= mask;
    }
    else if ( find_symbol ( x ))
    {
	x = ensure_signed_int_offsets ( x );
    }
    else
    {
	char *p, *fmt = GET_RTX_FORMAT ( GET_CODE ( x ));
	
	p = fmt;
	
	while ( '\0' != ( *p ))
	{
	    if ( 'e' == ( *p ))
	    {
		XEXP ( x, p - fmt ) = 
		    ensure_integer_result_size ( XEXP ( x, p - fmt ));
	    }
	    ++ p;
	}
    }
    return x;
}

static rtx
ensure_signed_pointer_offsets ( x )
    rtx x;
{
    if ( CONST_INT == GET_CODE ( x ))
    {
 	INTVAL ( x ) = (( INTVAL ( x ) << ( HOST_BITS_PER_INT - POINTER_SIZE ))
 			>> ( HOST_BITS_PER_INT - POINTER_SIZE ));
    }
    else
    {
	char *p, *fmt = GET_RTX_FORMAT ( GET_CODE ( x ));
	
	p = fmt;
	
	while ( '\0' != ( *p ))
	{
	    if ( 'e' == ( *p ))
	    {
		XEXP ( x, p - fmt ) =
		    ensure_signed_pointer_offsets ( XEXP ( x, p - fmt ));
	    }
	    ++ p;
	}
    }
    return x;
}

static rtx
ensure_signed_int_offsets ( x )
    rtx x;
{
    if ( CONST_INT == GET_CODE ( x ))
    {
 	INTVAL ( x ) =(( INTVAL ( x ) << ( HOST_BITS_PER_INT - BITS_PER_UNIT ))
		       >> ( HOST_BITS_PER_INT - BITS_PER_UNIT ));
    }
    else
    {
	char *p, *fmt = GET_RTX_FORMAT ( GET_CODE ( x ));
	
	p = fmt;
	
	while ( '\0' != ( *p ))
	{
	    if ( 'e' == ( *p ))
	    {
		XEXP ( x, p - fmt ) = 
		    ensure_signed_int_offsets ( XEXP ( x, p - fmt ));
	    }
	    ++ p;
	}
    }
    return x;
}

static int
find_symbol ( x )
    rtx x;
{
    int found_symbol = 0;
    char *p, *fmt = GET_RTX_FORMAT ( GET_CODE ( x ));

    if ( SYMBOL_REF == GET_CODE ( x ))
    {
	return 1;
    }
    
    p = fmt;
    
    while ( '\0' != ( *p ))
    {
	if ( 'e' == ( *p ))
	{
	    found_symbol |= find_symbol ( XEXP ( x, p - fmt ));
	}
	++ p;
    }
    return found_symbol;
}

#include "config/dsp.c"
