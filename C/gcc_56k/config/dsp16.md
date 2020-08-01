;;- Machine description for the Motorola dsp561XX for GNU C compiler
;;   Copyright ( C ) 1988 Free Software Foundation, Inc.
;;
;;	$Header: /usr1/dsp/cvsroot/source/gcc/config/dsp16.md,v 1.2 91/09/18 15:34:41 jeff Exp $
;;      $Id: dsp16.md,v 1.2 91/09/18 15:34:41 jeff Exp $
;;
;; This file is part of GNU CC.

;; GNU CC is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 1, or ( at your option )
;; any later version.

;; GNU CC is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU CC; see the file COPYING.  If not, write to
;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

;;- See file "rtl.def" for documentation on define_insn, match_*, et. al.

;;- cpp macro #define NOTICE_UPDATE_CC in file tm.h handles condition code
;;- updates for most instructions.

;;  %letter escapes for operand printing. (via PRINT_OPERAND).
;;  %d - print the accumulator name, disregard MEM_IN_STRUCT kludge.
;;  %e - print 1 after accumulator operand. No affect on non-accum reg.
;;  %f - print x: or y: before memory reference operand.
;;  %g - print alternate of x or y half-register.
;;  %h - print 0 after accumulator operand.
;;  %i - strip the 0/1 off an x or y half-register.
;;  %j - n register associated with r register.
;;  %k - print 2 after accumulator operand.
;;  %m - print the source reg name, without a trailing 0 or 1.
;;  %o - print the accumulator name with a trailing 10.

;;  %p - output this as a pointer size constant.
;;  %q - output this as an integer size constant.
;;  %r - output this as a long size constant.

;;
;;  ...........................................................................
;;
;;          MOVES, LOADS, STORES
;;
;;  ...........................................................................
;;

    
;; allow a PSImode value to be loaded into any register, but preferentially
;; load it into an A register. The A must come last - otherwise we risk 
;; messing up the code that does subunion stuff.

( define_expand "movpsi"
  [ ( set
      ( match_operand:PSI 0 "general_operand" "" )
      ( match_operand:PSI 1 "general_operand" "" ))
  ]
  ""
  "
{
    if ( MEM == GET_CODE ( operands[0] ) &&
	( MEM == GET_CODE ( operands[1] ) ||
	 CONSTANT_P ( operands[1] ) ||
	 CONST_DOUBLE == GET_CODE ( operands[1] )))
    {
	operands[1] = force_reg ( PSImode, operands[1] );
    }
}" )

( define_insn ""
  [ ( set
      ( match_operand:PSI 0 "register_operand" "=*D,*S*DA,m,*S*DA,*S*DA" )
      ( match_operand:PSI 1 "general_operand" "*S*D,*S*DA,*S*DA,m,i" ))
  ]
  ""
  "*
{
    return move_pointer ( operands );
}" "1" )

( define_insn ""
  [ ( set
      ( match_operand:PSI 0 "general_operand" "=*D,*S*DA,m,*S*DA,*S*DA" )
      ( match_operand:PSI 1 "register_operand" "*S*D,*S*DA,*S*DA,m,i" ))
  ]
  ""
  "*
{
    return move_pointer ( operands );
}" "1" )

( define_expand "movqi"
  [ ( set
      ( match_operand:QI 0 "general_operand" "" )
      ( match_operand:QI 1 "general_operand" "" ))
  ]
  ""
  "
{
    if ( MEM == GET_CODE ( operands[0] ) &&
	( MEM == GET_CODE ( operands[1] ) ||
	 CONSTANT_P ( operands[1] ) ||
	 CONST_DOUBLE == GET_CODE ( operands[1] )))
    {
	operands[1] = force_reg ( QImode, operands[1] );
    }
}" )

( define_insn ""
  [ ( set
      ( match_operand:QI 0 "register_operand" "=*D,*S,<>m,*S*D,*S*D" )
      ( match_operand:QI 1 "general_operand" "*S*A*D,*S*A*D,*S*A*D,<>m,i" ))
  ]
  ""
  "*
{
    return move_singleword ( operands );
}" "1" )

( define_insn ""
  [ ( set
      ( match_operand:QI 0 "general_operand" "=*D,*S,<>m,*S*D,*S*D" )
      ( match_operand:QI 1 "register_operand" "*S*A*D,*S*A*D,*S*A*D,<>m,i" ))
  ]
  ""
  "*
{
    return move_singleword ( operands );
}" "1" )

( define_expand "movsi"
  [ ( set
      ( match_operand:SI 0 "general_operand" "" )
      ( match_operand:SI 1 "general_operand" "" ))
  ]
  ""
  "
{
    if ( MEM == GET_CODE ( operands[0] ) &&
	( MEM == GET_CODE ( operands[1] ) ||
	 CONSTANT_P ( operands[1] ) ||
	 CONST_DOUBLE == GET_CODE ( operands[1] )))
    {
	operands[1] = force_reg ( SImode, operands[1] );
    }
}" )

( define_insn ""
  [ ( set
      ( match_operand:SI 0 "register_operand" "=*D,*S,<>m,*S*D,*S*D" )
      ( match_operand:SI 1 "general_operand" "*S*A*D,*S*A*D,*S*A*D,<>m,i" ))
  ]
  ""
  "*
{
    return move_singleword ( operands );
}" "1" )

( define_insn ""
  [ ( set
      ( match_operand:SI 0 "general_operand" "=*D,*S,<>m,*S*D,*S*D" )
      ( match_operand:SI 1 "register_operand" "*S*A*D,*S*A*D,*S*A*D,<>m,i" ))
  ]
  ""
  "*
{
    return move_singleword ( operands );
}" "1" )

( define_expand "movdi"
  [ ( set
      ( match_operand:DI 0 "general_operand" "" )
      ( match_operand:DI 1 "general_operand" "" ))
  ]
  ""
  "
{
    if ( MEM == GET_CODE ( operands[0] ) &&
	( MEM == GET_CODE ( operands[1] ) ||
	 CONSTANT_P ( operands[1] ) ||
	 CONST_DOUBLE == GET_CODE ( operands[1] )))
    {
	operands[1] = force_reg ( DImode, operands[1] );
    }
}" )

( define_insn ""
  [ ( set
      ( match_operand:DI 0 "register_operand" "=*D,*S,<>m,*D*S,*D*S" )
      ( match_operand:DI 1 "general_operand" "*D*S,*D*S,*D*S,<>m,Gi" ))
  ]
  ""
  "*
{
    return move_doubleword ( 0, operands );
}" "1" )

( define_insn ""
  [ ( set
      ( match_operand:DI 0 "general_operand" "=*D,*S,<>m,*D*S,*D*S" )
      ( match_operand:DI 1 "register_operand" "*D*S,*D*S,*D*S,<>m,Gi" ))
  ]
  ""
  "*
{
    return move_doubleword ( 0, operands );
}" "1" )

( define_expand "movsf"
  [ ( set
      ( match_operand:SF 0 "general_operand" "" )
      ( match_operand:SF 1 "general_operand" "" ))
  ]
  ""
  "
{
    if ( MEM == GET_CODE ( operands[0] ) &&
	( MEM == GET_CODE ( operands[1] ) ||
	 CONSTANT_P ( operands[1] ) ||
	 CONST_DOUBLE == GET_CODE ( operands[1] )))
    {
	operands[1] = force_reg ( SFmode, operands[1] );
    }
}" )

( define_insn ""
  [ ( set
      ( match_operand:SF 0 "register_operand" "=*D,*S,<>m,*D*S,*D*S" )
      ( match_operand:SF 1 "general_operand" "*D*S,*D*S,*D*S,<>m,G" ))
  ]
  ""
  "*
{
    return move_doubleword ( 1, operands );
}" "1" )

( define_insn ""
  [ ( set
      ( match_operand:SF 0 "general_operand" "=*D,*S,<>m,*D*S,*D*S" )
      ( match_operand:SF 1 "register_operand" "*D*S,*D*S,*D*S,<>m,G" ))
  ]
  ""
  "*
{
    return move_doubleword ( 1, operands );
}" "1" )

( define_expand "movdf"
  [ ( set
      ( match_operand:DF 0 "general_operand" "" )
      ( match_operand:DF 1 "general_operand" "" ))
  ]
  ""
  "
{
    if ( MEM == GET_CODE ( operands[0] ) &&
	( MEM == GET_CODE ( operands[1] ) ||
	 CONSTANT_P ( operands[1] ) ||
	 CONST_DOUBLE == GET_CODE ( operands[1] )))
    {
	operands[1] = force_reg ( DFmode, operands[1] );
    }
}" )
  
( define_insn ""
  [ ( set
      ( match_operand:DF 0 "register_operand" "=*D,*S,<>m,*D*S,*D*S" )
      ( match_operand:DF 1 "general_operand" "*D*S,*D*S,*D*S,<>m,G" ))
  ]
  ""
  "*
{
    return move_doubleword ( 1, operands );
}" "1" )

( define_insn ""
  [ ( set
      ( match_operand:DF 0 "general_operand" "=*D,*S,<>m,*D*S,*D*S" )
      ( match_operand:DF 1 "register_operand" "*D*S,*D*S,*D*S,<>m,G" ))
  ]
  ""
  "*
{
    return move_doubleword ( 1, operands );
}" "1" )

;;
;;  ...........................................................................
;;
;;          BLOCKMOVES
;;
;;  ...........................................................................
;;

( define_expand "movstrsi"
  [ ( parallel [ ( set ( match_operand:BLK 0 "memory_operand" "" )
		       ( match_operand:BLK 1 "memory_operand" "" ))
		 ( use ( match_operand:SI 2 "general_operand" "" ))
		 ( use ( match_operand:SI 3 "general_operand" "" )) ] )
  ]
  ""
  "
{
    rtx op0_reg, op1_reg, cpy_reg;

    op0_reg = gen_reg_rtx ( PSImode );
    emit_move_insn ( op0_reg, force_reg ( PSImode, XEXP ( operands[0], 0 )));
    
    op1_reg = gen_reg_rtx ( PSImode );
    emit_move_insn ( op1_reg, force_reg ( PSImode, XEXP ( operands[1], 0 )));
    
    cpy_reg = gen_reg_rtx ( DImode );

    if ( CONST_DOUBLE == GET_CODE ( operands[2] ))
    {
	operands[2] = gen_rtx ( CONST_INT, VOIDmode, 
			       CONST_DOUBLE_LOW ( operands[2] ));
    }
    
    emit_insn (
	       gen_rtx ( PARALLEL, VOIDmode,
			gen_rtvec ( 7,
				   gen_rtx ( CLOBBER, VOIDmode, op0_reg ),
				   gen_rtx ( CLOBBER, VOIDmode, op1_reg ),
				   gen_rtx ( USE, VOIDmode, operands[2] ),
				   gen_rtx ( CLOBBER, VOIDmode, cpy_reg ),
				   gen_rtx ( SET, VOIDmode, operands[0],
					    operands[1] ),
				   gen_rtx ( USE, VOIDmode, op0_reg ),
				   gen_rtx ( USE, VOIDmode, op1_reg ))));
    DONE;
}" )

( define_insn ""
  [ ( parallel [ ( clobber ( match_operand:PSI 0 "register_operand" "=A" ))
		 ( clobber ( match_operand:PSI 1 "register_operand" "=A" ))
		 ( use ( match_operand:SI 2 "immediate_operand" "i" ))
		 ( clobber ( match_operand:DI 3 "register_operand" "=*D*S" ))
		 ( set ( match_operand:BLK 4 "memory_operand" "" )
		       ( match_operand:BLK 5 "memory_operand" "" ))
		 ( use ( match_operand:PSI 6 "register_operand" "0" ))
		 ( use ( match_operand:PSI 7 "register_operand" "1" )) ] )
  ]
""
"*
{
    operands[8] = gen_label_rtx ( );

    if ( 'l' == memory_model )
    {
	if ( IS_SRC_OR_MPY_P ( REGNO ( operands[3] )))
	{
	    return \"do	#%c2,%l8\;move	l:(%1)+,%m3\;move	%m3,l:(%0)+\\n%l8\";
	}
	else
	{
	    return \"do	#%c2,%l8\;move	l:(%1)+,%o3\;move	%o3,l:(%0)+\\n%l8\";
	}
    }
    else /* single mem space. */
    {
	RETURN_DSP ( \"do	#%c2,%l8\;move	@:(%1)+,%3\;move	%3,@:(%0)+\\n%l8\" );
    }
}" )

;;
;;  ...........................................................................
;;
;;          ADDITIONS
;;
;;  ...........................................................................
;;

;; We provide quick software emulation via a subroutine that emulates
;; a floating point instruction.

( define_insn "adddf3"
  [ ( set ( match_operand:DF 0 "general_operand" "=D" )
          ( plus:DF ( match_operand:DF 1 "general_operand" "0" )
                    ( match_operand:DF 2 "general_operand" "D" ))) 
  ]
  ""
  "*
{
    int op0_is_a = ( DSP16_A_REGNUM == REGNO ( operands[0] ));
    int op2_is_a = ( DSP16_A_REGNUM == REGNO ( operands[2] ));
    
    if ( op0_is_a )
    {
	if ( op2_is_a )
	{
	    return \"jsr	fadd_aa\";
	}
	else
	{
	    return \"jsr	fadd_ba\";
	}
    }
    else
    {
	if ( op2_is_a )
	{
	    return \"jsr	fadd_ab\";
	}
	else
	{
	    return \"jsr	fadd_bb\";
	}
    }
}" )	

( define_insn "addsf3"
  [ ( set ( match_operand:SF 0 "general_operand" "=D" )
          ( plus:SF ( match_operand:SF 1 "general_operand" "0" )
                    ( match_operand:SF 2 "general_operand" "D" ))) 
  ]
  ""
  "*
{
    int op0_is_a = ( DSP16_A_REGNUM == REGNO ( operands[0] ));
    int op2_is_a = ( DSP16_A_REGNUM == REGNO ( operands[2] ));
    
    if ( op0_is_a )
    {
	if ( op2_is_a )
	{
	    return \"jsr	fadd_aa\";
	}
	else
	{
	    return \"jsr	fadd_ba\";
	}
    }
    else
    {
	if ( op2_is_a )
	{
	    return \"jsr	fadd_ab\";
	}
	else
	{
	    return \"jsr	fadd_bb\";
	}
    }
}" )	

;; Note that we MUST provide for inc/dec with a constant of one. The reload
;; pass may arbitrarily spill a regsiter post/pre inc/dec and will attempt to
;; perform the increment on the fly by itself. It does not consult the code
;; generator to see whether ( PSI <= PSI + CONST_INT ) is a valid insn.

( define_insn "addpsi3"
  [ ( set ( match_operand:PSI 0 "register_operand" "=*D,*A" )
	  ( plus:PSI 
	    ( match_operand:PSI 1 "register_operand" "0,0" )
	    ( match_operand:SI 2 "general_operand" "*D*S,i" )))
  ]
  ""
  "*
{
    if ( which_alternative )
    {
	switch ( INTVAL ( operands[2] ))
	{
	case 0:
	    return \"\";
	    
	case 1:
	    return \"move	(%0)+\";
	    
	case -1:
	    return \"move	(%0)-\";
	    
	default:
	    if ( load_n_reg_p ( operands[0], operands[2] ))
	    {
		return \"move	#%p2,%j0\;move	(%0)+%j0\";
	    }
	    else
	    {
		return \"move	(%0)+%j0\";
	    }
	}
    }
    else
    {
	return \"add	%2,%0\";
    }
}" )

;; we need this extra shape because addition commutes. 

( define_insn ""
  [ ( set ( match_operand:PSI 0 "register_operand" "=*D,*A" )
	  ( plus:PSI 
	    ( match_operand:SI 1 "general_operand" "*D*S,i" )
	    ( match_operand:PSI 2 "register_operand" "0,0" )))
  ]
  ""
  "*
{
    if ( which_alternative )
    {
	switch ( INTVAL ( operands[2] ))
	{
	case 0:
	    return \"\";
	    
	case 1:
	    return \"move	(%0)+\";
	    
	case -1:
	    return \"move	(%0)-\";
	    
	default:
	    if ( load_n_reg_p ( operands[0], operands[2] ))
	    {
		return \"move	#%p1,%j0\;move	(%0)+%j0\";
	    }
	    else
	    {
		return \"move	(%0)+%j0\";
	    }
	}
    }
    else
    {
	return \"add	%1,%0\";
    }
}" )

;; this insn is here because insn_extract does not detect commutable operands.

( define_insn ""
  [ ( set ( match_operand:PSI 0 "register_operand" "=*D" )
	  ( plus:PSI 
	    ( match_operand:SI 1 "register_operand" "*D*S" )
	    ( match_operand:PSI 2 "register_operand" "0" )))
  ]
  ""
  "add	%1,%0" )

( define_insn "addsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "=*D" )
          ( plus:SI ( match_operand:SI 1 "register_operand" "0" )
                    ( match_operand:SI 2 "register_operand" "*S*D" ))) 
  ]
  ""
  "*
{
    if ( REGNO ( operands[2] ) == REGNO ( operands[0] ))
    {
	return \"asl	%0\";
    }
    else
    {
	return \"add	%2,%0\";
    }
}" )

;;( define_insn ""
;;  [ ( set ( match_operand:SI 0 "register_operand" "=*D" )
;;     ( plus:SI ( match_operand:SI 1 "register_operand" "%0" )
;;               ( match_operand:PSI 2 "register_operand" "*S*D" ))) 
;;  ]
;;  ""
;;  "*
;;{
;;    if ( REGNO ( operands[2] ) == REGNO ( operands[0] ))
;;    {
;;	return \"asl	%0\";
;;    }
;;    else
;;    {
;;	return \"add	%2,%0\";
;;    }
;;}" )

( define_insn "adddi3"
  [ ( set ( match_operand:DI 0 "register_operand" "=*D" )
          ( plus:DI ( match_operand:DI 1 "register_operand" "0" )
                    ( match_operand:DI 2 "register_operand" "*S*D" ))) ]
  ""
  "*
{
    if ( IS_SRC_OR_MPY_P ( REGNO ( operands[2] )))
    {
	return \"add     %i2,%0\";
    }
    else
    {
	if ( REGNO ( operands[2] ) == REGNO ( operands[0] ))
	{
	    return \"asl	%0\";
	}
	else
	{
	    return \"add	%2,%0\";
	}
    }
}" )

;;
;;  ...........................................................................
;;
;;          SUBTRACTIONS
;;
;;  ...........................................................................
;;

;; We provide quick software emulation via a subroutine that emulates
;; a floating point instruction.

( define_insn "subdf3"
  [ ( set ( match_operand:DF 0 "general_operand" "=D" )
          ( minus:DF ( match_operand:DF 1 "general_operand" "0" )
                     ( match_operand:DF 2 "general_operand" "D" ))) 
  ]
  ""
  "*
{
    int op0_is_a = ( DSP16_A_REGNUM == REGNO ( operands[0] ));
    int op2_is_a = ( DSP16_A_REGNUM == REGNO ( operands[2] ));
    
    if ( op0_is_a )
    {
	if ( op2_is_a )
	{
	    return \"jsr	fsub_aa\";
	}
	else
	{
	    return \"jsr	fsub_ba\";
	}
    }
    else
    {
	if ( op2_is_a )
	{
	    return \"jsr	fsub_ab\";
	}
	else
	{
	    return \"jsr	fsub_bb\";
	}
    }
}" )	

( define_insn "subsf3"
  [ ( set ( match_operand:SF 0 "general_operand" "=D" )
          ( minus:SF ( match_operand:SF 1 "general_operand" "0" )
                     ( match_operand:SF 2 "general_operand" "D" ))) 
  ]
  ""
  "*
{
    int op0_is_a = ( DSP16_A_REGNUM == REGNO ( operands[0] ));
    int op2_is_a = ( DSP16_A_REGNUM == REGNO ( operands[2] ));
    
    if ( op0_is_a )
    {
	if ( op2_is_a )
	{
	    return \"jsr	fsub_aa\";
	}
	else
	{
	    return \"jsr	fsub_ba\";
	}
    }
    else
    {
	if ( op2_is_a )
	{
	    return \"jsr	fsub_ab\";
	}
	else
	{
	    return \"jsr	fsub_bb\";
	}
    }
}" )	

;; There are really two ways that subtraction can be used with pointers:
;; 1) PSI <= PSI - SI, and 2) SI <= PSI - PSI. Because of the way that the
;; GNU CC is structured in optabs.c, subtraction type (1) must be labeled as
;; subpsi3. Version 1.7 of optabs.c has code that, when turned on, will allow
;; you use type (2) as subpsi3. Currently, the shape for type (2) should
;; never be used: c-typeck.c converts the operands of a (2) to SImode before
;; the subtraction. This has no effect on us currently, however, if we should
;; try to use the address alu for PSImode adds and subtracts, it will.

;; Addendum: the shape for (2) could actually be generated by the DSP loop
;; optimization code in computing the number of loop iterations.

;; Note that we MUST provide for inc/dec with a constant of one. The reload
;; pass may arbitrarily spill a regsiter post/pre inc/dec and will attempt to
;; perform the increment on the fly by itself. It does not consult the code
;; generator to see whether ( PSI <= PSI + CONST_INT ) is a valid insn.

( define_insn "subpsi3"
  [ ( set ( match_operand:PSI 0 "register_operand" "=*D,*A" )
	  ( minus:PSI
	    ( match_operand:PSI 1 "register_operand" "0,0" )
	    ( match_operand:SI 2 "general_operand" "*D*S,i" )))
  ]
  ""
  "*
{
    if ( which_alternative )
    {
	switch ( INTVAL ( operands[2] ))
	{
	case 0:
	    return \"\";
	    
	case 1:
	    return \"move	(%0)-\";
	    
	case -1:
	    return \"move	(%0)+\";
	    
	default:
	    if ( load_n_reg_p ( operands[0], operands[2] ))
	    {
		return \"move	#%p2,%j0\;move	(%0)-%j0\";
	    }
	    else
	    {
		return \"move	(%0)-%j0\";
	    }
	}
    }
    else
    {
	return \"sub	%2,%0\";
    }
}" )

( define_insn ""
  [ ( set ( match_operand:SI 0 "register_operand" "=*D" )
	  ( minus:PSI 
	    ( match_operand:PSI 1 "register_operand" "0" )
	    ( match_operand:PSI 2 "register_operand" "*D*S" )))
  ]
  ""
  "sub	%2,%0" )

( define_insn "subsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
     ( minus:SI ( match_operand:SI 1 "register_operand" "0" )
                ( match_operand:SI 2 "register_operand" "*S*D" ))) ]
  ""
  "*
{
    if ( REGNO ( operands[2] ) == REGNO ( operands[0] ))
    {
	return \"clr	%0\";
    }
    else
    {
	return \"sub	%2,%0\";
    }
}" )

( define_insn "subdi3"
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
     ( minus:DI ( match_operand:DI 1 "register_operand" "0" )
                ( match_operand:DI 2 "register_operand" "*S*D" )))
  ]
  ""
  "*
{
    if ( IS_SRC_OR_MPY_P ( REGNO ( operands[2] )))
    {
	return \"sub     %i2,%0\";
    }
    else
    {
	if ( REGNO ( operands[2] ) == REGNO ( operands[0] ))
	{
	    return \"clr	%0\";
	}
	else
	{
	    return \"sub	%2,%0\";
	}
    }
}" )

;;
;;  ...........................................................................
;;
;;          MULTIPLICATIONS AND DIVISIONS
;;
;;  ...........................................................................
;;

;; We provide quick software emulation via a subroutine that emulates
;; a floating point instruction.

( define_insn "muldf3"
  [ ( set ( match_operand:DF 0 "general_operand" "=D" )
          ( mult:DF ( match_operand:DF 1 "general_operand" "0" )
                    ( match_operand:DF 2 "general_operand" "D" ))) 
  ]
  ""
  "*
{
    int op0_is_a = ( DSP16_A_REGNUM == REGNO ( operands[0] ));
    int op2_is_a = ( DSP16_A_REGNUM == REGNO ( operands[2] ));
    
    if ( op0_is_a )
    {
	if ( op2_is_a )
	{
	    return \"jsr	fmpy_aa\";
	}
	else
	{
	    return \"jsr	fmpy_ba\";
	}
    }
    else
    {
	if ( op2_is_a )
	{
	    return \"jsr	fmpy_ab\";
	}
	else
	{
	    return \"jsr	fmpy_bb\";
	}
    }
}" )	

( define_insn "mulsf3"
  [ ( set ( match_operand:SF 0 "general_operand" "=D" )
          ( mult:SF ( match_operand:SF 1 "general_operand" "0" )
                    ( match_operand:SF 2 "general_operand" "D" ))) 
  ]
  ""
  "*
{
    int op0_is_a = ( DSP16_A_REGNUM == REGNO ( operands[0] ));
    int op2_is_a = ( DSP16_A_REGNUM == REGNO ( operands[2] ));
    
    if ( op0_is_a )
    {
	if ( op2_is_a )
	{
	    return \"jsr	fmpy_aa\";
	}
	else
	{
	    return \"jsr	fmpy_ba\";
	}
    }
    else
    {
	if ( op2_is_a )
	{
	    return \"jsr	fmpy_ab\";
	}
	else
	{
	    return \"jsr	fmpy_bb\";
	}
    }
}" )	

;; We have two shapes for mac+ and two shapes for mac-, because the mult may
;; turn up as either operand of the plus/minus.

( define_insn ""
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( plus:SI ( match_operand:SI 1 "register_operand" "0" )
		    ( mult:SI ( match_operand:SI 2 "register_operand" "%S" )
			      ( match_operand:SI 3 "register_operand" "R" ))))
  ]
  ""
  "imac	%2,%3,%0" )

( define_insn ""
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( plus:SI ( mult:SI ( match_operand:SI 1 "register_operand" "%S" )
			      ( match_operand:SI 2 "register_operand" "R" ))
		    ( match_operand:SI 3 "register_operand" "0" )))
  ]
  ""
  "imac	%1,%2,%0" )

( define_insn ""
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( minus:SI ( match_operand:SI 1 "register_operand" "0" )
		     ( mult:SI ( match_operand:SI 2 "register_operand" "%S" )
			       ( match_operand:SI 3 "register_operand" "R" ))))
  ]
  ""
  "neg	%0;imac	%2,%3,%0;neg	%0"

;; we have a quick (breaks calling convention rules) subr. act as an inst.

( define_insn "muldi3"
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
          ( mult:DI ( match_operand:DI 1 "register_operand" "0" )
                    ( match_operand:DI 2 "register_operand" "D" ))) 
  ]
  ""
  "*
{
    int op0_is_a = ( DSP16_A_REGNUM == REGNO ( operands[0] ));
    int op2_is_a = ( DSP16_A_REGNUM == REGNO ( operands[2] ));
    
    if ( op0_is_a )
    {
	if ( op2_is_a )
	{
	    return \"jsr	lmpy_aa\";
	}
	else
	{
	    return \"jsr	lmpy_ba\";
	}
    }
    else
    {
	if ( op2_is_a )
	{
	    return \"jsr	lmpy_ab\";
	}
	else
	{
	    return \"jsr	lmpy_bb\";
	}
    }
}" )	


;; normal, boring mults follow.

( define_insn "mulsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( mult:SI ( match_operand:SI 1 "register_operand" "%S" )
		    ( match_operand:SI 2 "register_operand" "R" ))) 
  ]
  ""
  "impy	%2,%1,%0" )

( define_insn "umulsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( umult:SI ( match_operand:SI 1 "register_operand" "%S" )
		     ( match_operand:SI 2 "register_operand" "R" )))
  ]
  ""
  "impy	%2,%1,%0" )

;; We provide quick software emulation via a subroutine that emulates
;; a floating point instruction.

( define_insn "divdi3"
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
          ( div:DI ( match_operand:DI 1 "register_operand" "0" )
                   ( match_operand:DI 2 "register_operand" "D" ))) 
  ]
  ""
  "*
{
    int op0_is_a = ( DSP16_A_REGNUM == REGNO ( operands[0] ));
    int op2_is_a = ( DSP16_A_REGNUM == REGNO ( operands[2] ));
    
    if ( op0_is_a )
    {
	if ( op2_is_a )
	{
	    return \"jsr	ldiv_aa\";
	}
	else
	{
	    return \"jsr	ldiv_ba\";
	}
    }
    else
    {
	if ( op2_is_a )
	{
	    return \"jsr	ldiv_ab\";
	}
	else
	{
	    return \"jsr	ldiv_bb\";
	}
    }
}" )	

( define_insn "divdf3"
  [ ( set ( match_operand:DF 0 "general_operand" "=D" )
          ( div:DF ( match_operand:DF 1 "general_operand" "0" )
                   ( match_operand:DF 2 "general_operand" "D" ))) 
  ]
  ""
  "*
{
    int op0_is_a = ( DSP16_A_REGNUM == REGNO ( operands[0] ));
    int op2_is_a = ( DSP16_A_REGNUM == REGNO ( operands[2] ));
    
    if ( op0_is_a )
    {
	if ( op2_is_a )
	{
	    return \"jsr	fdiv_aa\";
	}
	else
	{
	    return \"jsr	fdiv_ba\";
	}
    }
    else
    {
	if ( op2_is_a )
	{
	    return \"jsr	fdiv_ab\";
	}
	else
	{
	    return \"jsr	fdiv_bb\";
	}
    }
}" )	

( define_insn "divsf3"
  [ ( set ( match_operand:SF 0 "general_operand" "=D" )
          ( div:SF ( match_operand:SF 1 "general_operand" "0" )
                   ( match_operand:SF 2 "general_operand" "D" ))) 
  ]
  ""
  "*
{
    int op0_is_a = ( DSP16_A_REGNUM == REGNO ( operands[0] ));
    int op2_is_a = ( DSP16_A_REGNUM == REGNO ( operands[2] ));
    
    if ( op0_is_a )
    {
	if ( op2_is_a )
	{
	    return \"jsr	fdiv_aa\";
	}
	else
	{
	    return \"jsr	fdiv_ba\";
	}
    }
    else
    {
	if ( op2_is_a )
	{
	    return \"jsr	fdiv_ab\";
	}
	else
	{
	    return \"jsr	fdiv_bb\";
	}
    }
}" )	

( define_expand "divsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "" )
	  ( div:SI ( match_operand:SI 1 "register_operand" "" )
		   ( match_operand:SI 2 "register_operand" "" )))
  ]
  ""
  "
{
    emit_insn (
	       gen_rtx ( PARALLEL, VOIDmode,
			gen_rtvec ( 3,
				   gen_rtx ( SET, VOIDmode, operands[0],
					    gen_rtx ( DIV, SImode, 
						     operands[1],
						     operands[2] )),
				   gen_rtx ( CLOBBER, VOIDmode, 
					    gen_reg_rtx ( SImode )),
				   gen_rtx ( CLOBBER, VOIDmode, 
					    gen_reg_rtx ( SImode )))));
    DONE;
}" )

( define_insn ""
  [ ( parallel [ ( set ( match_operand:SI 0 "register_operand" "=D" )
		       ( div:SI ( match_operand:SI 1 "register_operand" "0" )
				( match_operand:SI 2 "register_operand" "S" )))
		 ( clobber ( match_operand:SI 3 "register_operand" "=D" ))
		 ( clobber ( match_operand:SI 4 "register_operand" "=S" )) ] )
  ]
  ""
  "*
{
    operands[5] = gen_label_rtx ( );
    
    return  \"tfr	%0,%3\;abs	%0\;clr	%0	%e0,%4\;move	%4,%h0\;asl	%0\;rep	#$10\;div	%2,%0\;eor	%2,%3\;jpl	%l5\;neg	%0\\n%l5\;move	%h0,%0\";

}" )

;;
;;  ...........................................................................
;;
;;          NEGATIONS
;;
;;  ...........................................................................
;;

;; We provide quick software emulation via a subroutine that emulates
;; a floating point instruction.

( define_insn "negdf2"
  [ ( set ( match_operand:DF 0 "general_operand" "=D" )
          ( neg:DF ( match_operand:DF 1 "general_operand" "0" )))
  ]
  ""
  "*
{
    if ( DSP16_A_REGNUM == REGNO ( operands[0] ))
    {
	return \"jsr	fneg_a\";
    }
    else
    {
	return \"jsr	fneg_b\";
    }
}" )	

( define_insn "negsf2"
  [ ( set ( match_operand:SF 0 "general_operand" "=D" )
          ( neg:SF ( match_operand:SF 1 "general_operand" "0" )))
  ]
  ""
  "*
{
    if ( DSP16_A_REGNUM == REGNO ( operands[0] ))
    {
	return \"jsr	fneg_a\";
    }
    else
    {
	return \"jsr	fneg_b\";
    }
}" )	

( define_insn "negsi2"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( neg:SI ( match_operand:SI 1 "register_operand" "0" )))
  ]
  ""
  "neg	%0" )

( define_insn "negdi2"
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
	  ( neg:DI ( match_operand:DI 1 "register_operand" "0" )))
  ]
  ""
  "neg	%0" )

;;
;;  ...........................................................................
;;
;;          ABSOLUTE VALUES
;;
;;  ...........................................................................
;;

( define_insn "abssi2"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( abs:SI ( match_operand:SI 1 "register_operand" "0" ) ) ) ]
  ""
  "abs	%0" )

( define_insn "absdi2"
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
	  ( abs:DI ( match_operand:DI 1 "register_operand" "0" ) ) ) ]
  ""
  "abs	%0" )

;;
;;  ...........................................................................
;;
;;          LOGICAL AND
;;
;;  ...........................................................................
;;

( define_insn "andsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( and:SI ( match_operand:SI 1 "register_operand" "0" )
		   ( match_operand:SI 2 "register_operand" "S" ) ) ) ]
  ""
  "and	%2,%0\;move	%e0,%0" )

( define_insn "anddi3"
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
	  ( and:DI ( match_operand:DI 1 "register_operand" "0" )
		   ( match_operand:DI 2 "register_operand" "S" ) ) ) ]
  ""
  "*
{
    RETURN_DSP ( \"and	%g2,%0	%h0,@:(r6)\;move	%e0,%h0\;move	@:(r6),%e0\;and	%2,%0\;move	%e0,@:(r6)\;move	%h0,%0\;move	@:(r6),%h0\" );
}" )

;;
;;  ...........................................................................
;;
;;          LOGICAL INCLUSIVE OR
;;
;;  ...........................................................................
;;

( define_insn "iorsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( ior:SI ( match_operand:SI 1 "register_operand" "0" )
		   ( match_operand:SI 2 "register_operand" "S" ) ) ) ]
  ""
  "or	%2,%0\;move	%e0,%0" )

( define_insn "iordi3"
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
	  ( ior:DI ( match_operand:DI 1 "register_operand" "0" )
		   ( match_operand:DI 2 "register_operand" "S" ) ) ) ]
  ""
  "*
{
    RETURN_DSP ( \"or	%g2,%0	%h0,@:(r6)\;move	%e0,%h0\;move	@:(r6),%e0\;or	%2,%0\;move	%e0,@:(r6)\;move	%h0,%0\;move	@:(r6),%h0\" );
}" )

;;
;;  ...........................................................................
;;
;;          LOGICAL EXCLUSIVE OR
;;
;;  ...........................................................................
;;

( define_insn "xorsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( xor:SI ( match_operand:SI 1 "register_operand" "0" )
		   ( match_operand:SI 2 "register_operand" "S" ) ) ) ]
  ""
  "eor	%2,%0\;move	%e0,%0" )

( define_insn "xordi3"
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
	  ( xor:DI ( match_operand:DI 1 "register_operand" "0" )
		   ( match_operand:DI 2 "register_operand" "S" ) ) ) ]
  ""
  "*
{
    RETURN_DSP ( \"eor	%g2,%0	%h0,@:(r6)\;move	%e0,%h0\;move	@:(r6),%e0\;eor	%2,%0\;move	%e0,@:(r6)\;move	%h0,%0\;move	@:(r6),%h0\" );
}" )

;;
;;  ...........................................................................
;;
;;          ONE'S COMPLEMENT
;;
;;  ...........................................................................
;;

( define_insn "one_cmplsi2"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( not:SI ( match_operand:SI 1 "register_operand" "0" ))) 
  ]
  ""
  "not	%0\;move	%e0,%0" )

( define_insn "one_cmpldi2"
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
	  ( not:DI ( match_operand:DI 1 "register_operand" "0" )))
  ]
  ""
  "*
{
    RETURN_DSP ( \"not	%0	%h0,@:(r6)\;move	%e0,%h0\;move	@:(r6),%e0\;not	%0\;move	%e0,@:(r6)\;move	%h0,%0\;move	@:(r6),%h0\" );
}" )

;;
;;  ...........................................................................
;;
;;          ARITHMETIC SHIFTS
;;
;;  ...........................................................................
;;

;; note that we preceed each shift insn by an unnamed insn. the unnamed insn
;; is used to catch shifts with constant shift counts before said constants
;; are promoted to registers. 

( define_insn ""
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( ashift:SI ( match_operand:SI 1 "register_operand" "0" )
		      ( match_operand:SI 2 "immediate_operand" "i" )))
  ]
  ""
  "*
{
    if ( 1 == INTVAL ( operands[2] ))
    {
	return \"asl	%0\;move	%e0,%0\";
    }
    else if ( 2 == INTVAL ( operands[2] ))
    {
	return \"asl	%0\;asl	%0\;move	%e0,%0\";
    }
    else
    {
	operands[3] = copy_rtx ( operands[2] );
	INTVAL ( operands[3] ) &= 0xfff;
	    
	if ( TARGET_REP )
	{
	    return \"rep	#%c3\;asl	%0\;move	%e0,%0\";
	}
	else
	{
	    operands[4] = gen_label_rtx ( );
	    
	    return \"do	#%c3,%l4\;asl	%0\\n%l4\;move	%e0,%0\";
	}
    }
}" )

( define_insn "ashlsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( ashift:SI ( match_operand:SI 1 "register_operand" "0" )
		      ( match_operand:SI 2 "general_operand" "D" )))
  ]
  ""
  "*
{
    operands[3] = gen_label_rtx ( );
    
    if ( TARGET_REP )
    {
	return \"tst	%2\;jeq	%l3\;rep	%2\;asl	%0\;move	%e0,%0\\n%l3\";
    }
    else
    {
	operands[4] = gen_label_rtx ( );
	
	return \"tst	%2\;jeq	%l3\;do	%2,%l4\;asl	%0\\n%l4\;move	%e0,%0\\n%l3\";
    }
}")

( define_insn ""
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( ashiftrt:SI ( match_operand:SI 1 "register_operand" "0" )
			( match_operand:SI 2 "immediate_operand" "i" )))
  ]
  ""
  "*
{
    if ( 1 == INTVAL ( operands[2] ))
    {
	return \"move	%e0,%0\;asr	%0\;move	%e0,%0\";
    }
    else if ( 2 == INTVAL ( operands[2] ))
    {
	return \"move	%e0,%0\;asr	%0\;asr	%0\;move	%e0,%0\";
    }
    else
    {
	operands[3] = copy_rtx ( operands[2] );
	INTVAL ( operands[3] ) &= 0xfff;
	
	if ( TARGET_REP )
	{
	    return \"move	%e0,%0\;rep	#%c3\;asr	%0\;move	%e0,%0\";
	}
	else
	{
	    operands[4] = gen_label_rtx ( );
	    
	    return \"move	%e0,%0\;do	#%c3,%l4\;asr	%0\\n%l4\;move	%e0,%0\";
	}
    }
}" )

( define_insn "ashrsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
     ( ashiftrt:SI ( match_operand:SI 1 "register_operand" "0" )
                   ( match_operand:SI 2 "general_operand" "D" )))
  ]
  ""
  "*
{
    operands[3] = gen_label_rtx ( );
    
    if ( TARGET_REP )
    {
	return \"tst	%2\;jeq	%l3\;move	%e0,%0\;rep	%2\;asr	%0\;move	%e0,%0\\n%l3\";
    }
    else
    {
	operands[4] = gen_label_rtx ( );
	
	return \"tst	%2\;jeq	%l3\;move	%e0,%0\;do	%2,%l4\;asr	%0\\n%l4\;move	%e0,%0\\n%l3\";
    }
}")

( define_insn ""
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
     ( ashift:DI ( match_operand:DI 1 "register_operand" "0" )
                 ( match_operand:SI 2 "immediate_operand" "i" )))
  ]
  ""
  "*
{
    if ( 1 == INTVAL ( operands[2] ))
    {
	return \"asl	%0\";
    }
    else if ( 2 == INTVAL ( operands[2] ))
    {
	return \"asl	%0\;asl	%0\";
    }
    else
    {
	operands[3] = copy_rtx ( operands[2] );
	INTVAL ( operands[3] ) &= 0xfff;
	
	if ( TARGET_REP )
	{
	    return \"rep	#%c3\;asl	%0\";
	}
	else
	{
	    operands[4] = gen_label_rtx ( );
	    
	    return \"do	#%c3,%l4\;asl	%0\\n%l4\";
	}
    }
}" )

( define_insn "ashldi3"
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
     ( ashift:DI ( match_operand:DI 1 "register_operand" "0" )
                 ( match_operand:SI 2 "general_operand" "D" )))
  ]
  ""
  "*
{
    operands[3] = gen_label_rtx ( );
    
    if ( TARGET_REP )
    {
	return \"tst	%d2\;jeq	%l3\;rep	%2\;asl	%0\\n%l3\";
    }
    else
    {
	return \"tst	%d2\;jeq	%l3\;do	%2,%l3\;asl	%0\\n%l3\";
    }
}")

( define_insn ""
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
     ( ashiftrt:DI ( match_operand:DI 1 "register_operand" "0" )
                   ( match_operand:SI 2 "immediate_operand" "i" )))
  ]
  ""
  "*
{
    if ( 1 == INTVAL ( operands[2] ))
    {
	RETURN_DSP ( \"move	%h0,@:(r6)\;move	%e0,%0\;move	@:(r6),%h0\;asr	%0\" );
    }
    else if ( 2 == INTVAL ( operands[2] ))
    {
	RETURN_DSP ( \"move	%h0,@:(r6)\;move	%e0,%0\;move	@:(r6),%h0\;asl	%0\;asr	%0\" );
    }
    else
    {
	operands[3] = copy_rtx ( operands[2] );
	INTVAL ( operands[3] ) &= 0xfff;
	
	if ( TARGET_REP )
	{
	    RETURN_DSP ( \"move	%h0,@:(r6)\;move	%e0,%0\;move	@:(r6),%h0\;rep	#%c3\;asr	%0\" );
	}
	else
	{
	    operands[4] = gen_label_rtx ( );
	    
	    RETURN_DSP ( \"move	%h0,@:(r6)\;move	%e0,%0\;move	@:(r6),%h0\;do	#%c3,%l4\;asr	%0\\n%l4\" );
	}
    }
}" )

( define_insn "ashrdi3"
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
     ( ashiftrt:DI ( match_operand:DI 1 "register_operand" "0" )
                   ( match_operand:SI 2 "general_operand" "D" )))
  ]
  ""
  "*
{
    operands[3] = gen_label_rtx ( );

    if ( TARGET_REP )
    {
	RETURN_DSP ( \"move	%h0,@:(r6)\;move	%e0,%0\;move	@:(r6),%h0\;tst	%d2\;jeq	%l3\;rep	%2\;asr	%0\\n%l3\" );
    }
    else
    {
	RETURN_DSP ( \"move	%h0,@:(r6)\;move	%e0,%0\;move	@:(r6),%h0\;tst	%d2\;jeq	%l3\;do	%2,%l3\;asr	%0\\n%l3\" );
    }
}")

;;
;;  ...........................................................................
;;
;;          LOGICAL SHIFTS
;;
;;  ...........................................................................
;;

;; note that we preceed each shift insn by an unnamed insn. the unnamed insn
;; is used to catch shifts with constant shift counts before said constants
;; are promoted to registers. 

( define_insn ""
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
     ( lshift:SI ( match_operand:SI 1 "register_operand" "0" )
                 ( match_operand:SI 2 "immediate_operand" "i" )))
  ]
  ""
  "*
{
    if ( 1 == INTVAL ( operands[2] ))
    {
	return \"lsl	%0\";
    }
    else if ( 2 == INTVAL ( operands[2] ))
    {
	return \"lsl	%0\;lsl	%0\";
    }
    else
    {
	operands[3] = copy_rtx ( operands[2] );
	INTVAL ( operands[3] ) &= 0xfff;
	
	if ( TARGET_REP )
	{
	    return \"rep	#%c3\;lsl	%0\";
	}
	else
	{
	    operands[4] = gen_label_rtx ( );
	    
	    return \"do	#%c3,%l4\;lsl	%0\\n%l4\";
	}
    }
}" )

( define_insn "lshlsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
     ( lshift:SI ( match_operand:SI 1 "register_operand" "0" )
                 ( match_operand:SI 2 "general_operand" "D" )))
  ]
  ""
  "*
{
    operands[3] = gen_label_rtx ( );
    
    if ( TARGET_REP )
    {
	return \"tst	%2\;jeq	%l3\;rep	%2\;lsl	%0\\n%l3\";
    }
    else
    {
	return \"tst	%2\;jeq	%l3\;do	%2,%l3\;lsl	%0\\n%l3\";
    }
}")

( define_insn ""
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
     ( lshiftrt:SI ( match_operand:SI 1 "register_operand" "0" )
                   ( match_operand:SI 2 "immediate_operand" "i" )))
  ]
  ""
  "*
{
    if ( 1 == INTVAL ( operands[2] ))
    {
	return \"lsr	%0\";
    }
    else if ( 2 == INTVAL ( operands[2] ))
    {
	return \"lsr	%0\;lsr	%0\";
    }
    else
    {
	operands[3] = copy_rtx ( operands[2] );
	INTVAL ( operands[3] ) &= 0xfff;
	
	if ( TARGET_REP )
	{
	    return \"rep	#%c3\;lsr	%0\";
	}
	else
	{
	    operands[4] = gen_label_rtx ( );
	    
	    return \"do	#%c3,%l4\;lsr	%0\\n%l4\";
	}
    }
}" )

( define_insn "lshrsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
     ( lshiftrt:SI ( match_operand:SI 1 "register_operand" "0" )
                   ( match_operand:SI 2 "general_operand" "D" )))
  ]
  ""
  "*
{
    operands[3] = gen_label_rtx ( );
    
    if ( TARGET_REP )
    {
	return \"tst	%2\;jeq	%l3\;rep	%2\;lsr	%0\\n%l3\";
    }
    else
    {
	return \"tst	%2\;jeq	%l3\;do	%2,%l3\;lsr	%0\\n%l3\";
    }
}")

( define_insn ""
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
     ( lshift:DI ( match_operand:DI 1 "register_operand" "0" )
                 ( match_operand:SI 2 "immediate_operand" "i" )))
  ]
  ""
  "*
{
    if ( 1 == INTVAL ( operands[2] ))
    {
	return \"asl	%0\";
    }
    else if ( 2 == INTVAL ( operands[2] ))
    {
	return \"asl	%0\;asl	%0\";
    }
    else
    {
	operands[3] = copy_rtx ( operands[2] );
	INTVAL ( operands[3] ) &= 0xfff;
	
	if ( TARGET_REP )
	{
	    return \"rep	#%c3\;asl	%0\";
	}
	else
	{	
	    operands[4] = gen_label_rtx ( );
	    
	    return \"do	#%c3,%l4\;asl	%0\\n%l4\";
	}
    }
}" )

( define_insn "lshldi3"
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
     ( lshift:DI ( match_operand:DI 1 "register_operand" "0" )
                 ( match_operand:SI 2 "general_operand" "D" )))
  ]
  ""
  "*
{
    operands[3] = gen_label_rtx ( );

    if ( TARGET_REP )
    {
	return \"tst	%d2\;jeq	%l3\;rep	%2\;asl	%0\\n%l3\";
    }
    else
    {
	return \"tst	%d2\;jeq	%l3\;do	%2,%l3\;asl	%0\\n%l3\";
    }
}")

( define_insn ""
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
     ( lshiftrt:DI ( match_operand:DI 1 "register_operand" "0" )
                   ( match_operand:SI 2 "immediate_operand" "i" )))
  ]
  ""
  "*
{
    if ( 1 == INTVAL ( operands[2] ))
    {
	return \"move	#0,%k0\;asr	%0\";
    }
    else if ( 2 == INTVAL ( operands[2] ))
    {
	return \"move	#0,%k0\;asr	%0\;asr	%0\";
    }
    else
    {
	operands[3] = copy_rtx ( operands[2] );
	INTVAL ( operands[3] ) &= 0xfff;
	
	if ( TARGET_REP )
	{
	    return \"move	#0,%k0\;rep	#%c3\;asr	%0\";
	}
	else
	{
	    operands[4] = gen_label_rtx ( );
	    
	    return \"move	#0,%k0\;do	#%c3,%l4\;asr	%0\\n%l4\";
	}
    }
}" )

( define_insn "lshrdi3"
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
     ( lshiftrt:DI ( match_operand:DI 1 "register_operand" "0" )
                   ( match_operand:SI 2 "general_operand" "D" )))
  ]
  ""
  "*
{
    operands[3] = gen_label_rtx ( );
    
    if ( TARGET_REP )
    {
	return \"tst	%d2\;jeq	%l3\;move	#0,%k0\;rep	%2\;asr	%0\\n%l3\";
    }
    else
    {
	return \"tst	%d2\;jeq	%l3\;move	#0,%k0\;do	%2,%l3\;asr	%0\\n%l3\";
    }
}")

;;
;;  ...........................................................................
;;
;;          ROTATIONS
;;
;;  ...........................................................................
;;

;; note that we preceed each shift insn by an unnamed insn. the unnamed insn
;; is used to catch shifts with constant shift counts before said constants
;; are promoted to registers. 

( define_insn ""
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
     ( rotate:SI ( match_operand:SI 1 "register_operand" "0" )
                 ( match_operand:SI 2 "immediate_operand" "i" )))
  ]
  ""
  "*
{
    if ( 1 == INTVAL ( operands[2] ))
    {
	return \"rol	%0\";
    }
    else if ( 2 == INTVAL ( operands[2] ))
    {
	return \"rol	%0\;rol	%0\";
    }
    else
    {
	operands[3] = copy_rtx ( operands[2] );
	INTVAL ( operands[3] ) &= 0xfff;
	
	if ( TARGET_REP )
	{
	    return \"rep	#%c3\;rol	%0\";
	}
	else
	{
	    operands[4] = gen_label_rtx ( );
	    
	    return \"do	#%c3,%l4\;rol	%0\\n%l4\";
	}
    }
}" )

( define_insn "rotlsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
     ( rotate:SI ( match_operand:SI 1 "register_operand" "0" )
                 ( match_operand:SI 2 "general_operand" "D" )))
  ]
  ""
  "*
{
    operands[3] = gen_label_rtx ( );
    
    if ( TARGET_REP )
    {
	return \"tst	%2\;jeq	%l3\;rep	%2\;rol	%0\\n%l3\";
    }
    else
    {
	return \"tst	%2\;jeq	%l3\;do	%2,%l3\;rol	%0\\n%l3\";
    }
}")

( define_insn ""
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
     ( rotatert:SI ( match_operand:SI 1 "register_operand" "0" )
                   ( match_operand:SI 2 "immediate_operand" "i" )))
  ]
  ""
  "*
{
    if ( 1 == INTVAL ( operands[2] ))
    {
	return \"ror	%0\";
    }
    else if ( 2 == INTVAL ( operands[2] ))
    {
	return \"ror	%0\;ror	%0\";
    }
    else
    {
	operands[3] = copy_rtx ( operands[2] );
	INTVAL ( operands[3] ) &= 0xfff;
	
	if ( TARGET_REP )
	{
	    return \"rep	#%c3\;ror	%0\";
	}
	else
	{
	    operands[4] = gen_label_rtx ( );
	    
	    return \"do	#%c3,%l4\;ror	%0\\n%l4\";
	}
    }
}" )

( define_insn "rotrsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
     ( rotatert:SI ( match_operand:SI 1 "register_operand" "0" )
                   ( match_operand:SI 2 "general_operand" "D" )))
  ]
  ""
  "*
{
    operands[3] = gen_label_rtx ( );
    
    if ( TARGET_REP )
    {
	return \"tst	%2\;jeq	%l3\;rep	%2\;ror	%0\\n%l3\";
    }
    else
    {
	return \"tst	%2\;jeq	%l3\;do	%2,%l3\;ror	%0\\n%l3\";
    }
}")

;;
;;  ...........................................................................
;;
;;          COMPARISONS
;;
;;  ...........................................................................
;;

;; We provide quick software emulation via a subroutine that emulates
;; a floating point instruction.

( define_insn "cmpdf"
  [ ( set ( cc0 )
          ( compare ( match_operand:DF 0 "register_operand" "D" )
                    ( match_operand:DF 1 "register_operand" "D" )))
  ]
  ""
  "*
{
    int op0_is_a = ( DSP16_A_REGNUM == REGNO ( operands[0] ));
    int op1_is_a = ( DSP16_A_REGNUM == REGNO ( operands[1] ));
    
    if ( op0_is_a )
    {
	if ( op1_is_a )
	{
	    return \"jsr	fcmp_aa\";
	}
	else
	{
	    return \"jsr	fcmp_ba\";
	}
    }
    else
    {
	if ( op1_is_a )
	{
	    return \"jsr	fcmp_ab\";
	}
	else
	{
	    return \"jsr	fcmp_bb\";
	}
    }
}" )	

( define_insn "cmpsf"
  [ ( set ( cc0 )
          ( compare ( match_operand:SF 0 "register_operand" "D" )
                    ( match_operand:SF 1 "register_operand" "D" )))
  ]
  ""
  "*
{
    int op0_is_a = ( DSP16_A_REGNUM == REGNO ( operands[0] ));
    int op1_is_a = ( DSP16_A_REGNUM == REGNO ( operands[1] ));
    
    if ( op0_is_a )
    {
	if ( op1_is_a )
	{
	    return \"jsr	fcmp_aa\";
	}
	else
	{
	    return \"jsr	fcmp_ba\";
	}
    }
    else
    {
	if ( op1_is_a )
	{
	    return \"jsr	fcmp_ab\";
	}
	else
	{
	    return \"jsr	fcmp_bb\";
	}
    }
}" )	

( define_insn "cmppsi"
  [ ( set ( cc0 )
          ( compare ( match_operand:PSI 0 "register_operand" "D" )
                    ( match_operand:PSI 1 "register_operand" "D" )))
  ]
  ""
  "*
{
    extern enum mdep_cc_info next_cc_use ( );
    extern rtx next_cc_relevancy ( );
    rtx relevant_insn, relevant_body;
    
    /* sometimes this compiler manages attempt ( compare ( reg x ) ( reg x )).
       the condition codes implied by this are obvious. we peek down the insn
       chain and discover the next_cc0_relevancy ( ). if we discover
       that the ccs are being set gratuitiously, we ignore this compare, 
       otherwise we change the cc0 consumer to be a constant load in the case
       of an Scond or a hard branch or nop in the case of a Bcond. */

    if ( REGNO ( operands[0] ) == REGNO ( operands[1] ))
    {
	relevant_insn = next_cc_relevancy ( insn );
	relevant_body = PATTERN ( relevant_insn );
	
	if ( JUMP_INSN == GET_CODE ( relevant_insn ))
	{
	    if (( IF_THEN_ELSE == GET_CODE ( relevant_body =
					    XEXP ( relevant_body, 1 ))) &&
		( CONST_INT != 
		 GET_CODE ( XEXP ( relevant_body, 0 ))))
	    {
		if (( GEU == GET_CODE ( XEXP ( relevant_body, 0 ))) ||
		    ( GE == GET_CODE ( XEXP ( relevant_body, 0 ))) ||
		    ( LEU == GET_CODE ( XEXP ( relevant_body, 0 ))) ||
		    ( LE == GET_CODE ( XEXP ( relevant_body, 0 ))) ||
		    ( EQU == GET_CODE ( XEXP ( relevant_body, 0 ))) ||
		    ( EQ == GET_CODE ( XEXP ( relevant_body, 0 ))))
		{
		    /* change ineq into const1_rtx because x == x always. */

		    if ( pc_rtx == XEXP ( XEXP ( PATTERN ( relevant_insn ),
						1 ), 1 ))
		    {
			delete_insn ( relevant_insn );
		    }
		    else
		    {
			INSN_CODE ( relevant_insn ) = -1;

			XEXP ( PATTERN ( relevant_insn ), 1 ) =
			    XEXP ( XEXP ( PATTERN ( relevant_insn ), 1 ), 1 );
		    }
		}
		else
		{
		    /* otherwise change ineq into const0_rtx. */
		    
		    if ( pc_rtx == XEXP ( XEXP ( PATTERN ( relevant_insn ),
						1 ), 1 ))
		    {
			INSN_CODE ( relevant_insn ) = -1;

			XEXP ( PATTERN ( relevant_insn ), 1 ) =
			    XEXP ( XEXP ( PATTERN ( relevant_insn ), 1 ), 2 );
		    }
		    else
		    {
			delete_insn ( relevant_insn );
		    }
		}
	    }
	}
	else if (( INSN == GET_CODE ( relevant_insn )) &&
		 ( PARALLEL == GET_CODE ( relevant_body )) &&
		 ( SET == GET_CODE ( relevant_body = 
				    XVECEXP ( relevant_body, 0, 0 ))) &&
		 ( 0 == strcmp ( \"ee\",
				GET_RTX_FORMAT ( GET_CODE ( XEXP ( relevant_body, 1 ))))) &&
		 ( cc0_rtx == XEXP ( XEXP ( relevant_body, 1 ), 0 )))
	{
	    if (( GEU == GET_CODE ( XEXP ( relevant_body, 1 ))) ||
		( GE == GET_CODE ( XEXP ( relevant_body, 1 ))) ||
		( LEU == GET_CODE ( XEXP ( relevant_body, 1 ))) ||
		( LE == GET_CODE ( XEXP ( relevant_body, 1 ))) ||
		( EQU == GET_CODE ( XEXP ( relevant_body, 1 ))) ||
		( EQ == GET_CODE ( XEXP ( relevant_body, 1 ))))
	    {
		/* change ineq into const1_rtx because x == x always. */

		XEXP ( relevant_body, 1 ) = const1_rtx;
	    }
	    else 
	    {
		/* otherwise change ineq into const0_rtx. */

		XEXP ( relevant_body, 1 ) = const0_rtx;
	    }
	    INSN_CODE ( relevant_insn ) = -1;
	}
	return \"\";
    }
    
    if ( CC_UNSIGNED == next_cc_use ( insn ))
    {
	cc_status.mdep = CC_UNSIGNED;
	return \"move	#0,%k0\;move	#0,%k1\;cmp	%1,%0\";
    }
    else
    {
	cc_status.mdep = CC_SIGNED;
	return \"cmp	%1,%0\";
    }
}" )

( define_insn ""
  [ ( set ( cc0 )
          ( compare ( match_operand:SI 0 "register_operand" "D" )
                    ( match_operand:SI 1 "register_operand" "D" )))
  ]
  "UNSIGNED_COMPARE_P ( insn )"
  "*
{
    extern enum mdep_cc_info next_cc_use ( );
    extern rtx next_cc_relevancy ( );
    rtx relevant_insn, relevant_body;
    
    /* sometimes this compiler manages attempt ( compare ( reg x ) ( reg x )).
       the condition codes implied by this are obvious. we peek down the insn
       chain and discover the next_cc0_relevancy ( ). if we discover
       that the ccs are being set gratuitiously, we ignore this compare, 
       otherwise we change the cc0 consumer to be a constant load in the case
       of an Scond or a hard branch or nop in the case of a Bcond. */

    if ( REGNO ( operands[0] ) == REGNO ( operands[1] ))
    {
	relevant_insn = next_cc_relevancy ( insn );
	relevant_body = PATTERN ( relevant_insn );
	
	if ( JUMP_INSN == GET_CODE ( relevant_insn ))
	{
	    if (( IF_THEN_ELSE == GET_CODE ( relevant_body =
					    XEXP ( relevant_body, 1 ))) &&
		( CONST_INT != 
		 GET_CODE ( XEXP ( relevant_body, 0 ))))
	    {
		if (( GEU == GET_CODE ( XEXP ( relevant_body, 0 ))) ||
		    ( GE == GET_CODE ( XEXP ( relevant_body, 0 ))) ||
		    ( LEU == GET_CODE ( XEXP ( relevant_body, 0 ))) ||
		    ( LE == GET_CODE ( XEXP ( relevant_body, 0 ))) ||
		    ( EQU == GET_CODE ( XEXP ( relevant_body, 0 ))) ||
		    ( EQ == GET_CODE ( XEXP ( relevant_body, 0 ))))
		{
		    /* change ineq into const1_rtx because x == x always. */

		    if ( pc_rtx == XEXP ( XEXP ( PATTERN ( relevant_insn ),
						1 ), 1 ))
		    {
			delete_insn ( relevant_insn );
		    }
		    else
		    {
			INSN_CODE ( relevant_insn ) = -1;

			XEXP ( PATTERN ( relevant_insn ), 1 ) =
			    XEXP ( XEXP ( PATTERN ( relevant_insn ), 1 ), 1 );
		    }
		}
		else
		{
		    /* otherwise change ineq into const0_rtx. */
		    
		    if ( pc_rtx == XEXP ( XEXP ( PATTERN ( relevant_insn ),
						1 ), 1 ))
		    {
			INSN_CODE ( relevant_insn ) = -1;

			XEXP ( PATTERN ( relevant_insn ), 1 ) =
			    XEXP ( XEXP ( PATTERN ( relevant_insn ), 1 ), 2 );
		    }
		    else
		    {
			delete_insn ( relevant_insn );
		    }
		}
	    }
	}
	else if (( INSN == GET_CODE ( relevant_insn )) &&
		 ( PARALLEL == GET_CODE ( relevant_body )) &&
		 ( SET == GET_CODE ( relevant_body = 
				    XVECEXP ( relevant_body, 0, 0 ))) &&
		 ( 0 == strcmp ( \"ee\",
				GET_RTX_FORMAT ( GET_CODE ( XEXP ( relevant_body, 1 ))))) &&
		 ( cc0_rtx == XEXP ( XEXP ( relevant_body, 1 ), 0 )))
	{
	    if (( GEU == GET_CODE ( XEXP ( relevant_body, 1 ))) ||
		( GE == GET_CODE ( XEXP ( relevant_body, 1 ))) ||
		( LEU == GET_CODE ( XEXP ( relevant_body, 1 ))) ||
		( LE == GET_CODE ( XEXP ( relevant_body, 1 ))) ||
		( EQU == GET_CODE ( XEXP ( relevant_body, 1 ))) ||
		( EQ == GET_CODE ( XEXP ( relevant_body, 1 ))))
	    {
		/* change ineq into const1_rtx because x == x always. */

		XEXP ( relevant_body, 1 ) = const1_rtx;
	    }
	    else 
	    {
		/* otherwise change ineq into const0_rtx. */

		XEXP ( relevant_body, 1 ) = const0_rtx;
	    }
	    INSN_CODE ( relevant_insn ) = -1;
	}
	return \"\";
    }
    
    cc_status.mdep = CC_UNSIGNED;

    return \"move	#0,%k0\;move	#0,%k1\;cmp	%1,%0\";
}" )

( define_insn "cmpsi"
  [ ( set ( cc0 )
          ( compare ( match_operand:SI 0 "register_operand" "D" )
                    ( match_operand:SI 1 "register_operand" "*S*D" )))
  ]
  ""
  "*
{
    extern enum mdep_cc_info next_cc_use ( );
    extern rtx next_cc_relevancy ( );
    rtx relevant_insn, relevant_body;
    
    /* sometimes this compiler manages attempt ( compare ( reg x ) ( reg x )).
       the condition codes implied by this are obvious. we peek down the insn
       chain and discover the next_cc0_relevancy ( ). if we discover
       that the ccs are being set gratuitiously, we ignore this compare, 
       otherwise we change the cc0 consumer to be a constant load in the case
       of an Scond or a hard branch or nop in the case of a Bcond. */

    if ( REGNO ( operands[0] ) == REGNO ( operands[1] ))
    {
	relevant_insn = next_cc_relevancy ( insn );
	relevant_body = PATTERN ( relevant_insn );
	
	if ( JUMP_INSN == GET_CODE ( relevant_insn ))
	{
	    if (( IF_THEN_ELSE == GET_CODE ( relevant_body =
					    XEXP ( relevant_body, 1 ))) &&
		( CONST_INT != 
		 GET_CODE ( XEXP ( relevant_body, 0 ))))
	    {
		if (( GEU == GET_CODE ( XEXP ( relevant_body, 0 ))) ||
		    ( GE == GET_CODE ( XEXP ( relevant_body, 0 ))) ||
		    ( LEU == GET_CODE ( XEXP ( relevant_body, 0 ))) ||
		    ( LE == GET_CODE ( XEXP ( relevant_body, 0 ))) ||
		    ( EQU == GET_CODE ( XEXP ( relevant_body, 0 ))) ||
		    ( EQ == GET_CODE ( XEXP ( relevant_body, 0 ))))
		{
		    /* change ineq into const1_rtx because x == x always. */

		    if ( pc_rtx == XEXP ( XEXP ( PATTERN ( relevant_insn ),
						1 ), 1 ))
		    {
			delete_insn ( relevant_insn );
		    }
		    else
		    {
			INSN_CODE ( relevant_insn ) = -1;

			XEXP ( PATTERN ( relevant_insn ), 1 ) =
			    XEXP ( XEXP ( PATTERN ( relevant_insn ), 1 ), 1 );
		    }
		}
		else
		{
		    /* otherwise change ineq into const0_rtx. */
		    
		    if ( pc_rtx == XEXP ( XEXP ( PATTERN ( relevant_insn ),
						1 ), 1 ))
		    {
			INSN_CODE ( relevant_insn ) = -1;

			XEXP ( PATTERN ( relevant_insn ), 1 ) =
			    XEXP ( XEXP ( PATTERN ( relevant_insn ), 1 ), 2 );
		    }
		    else
		    {
			delete_insn ( relevant_insn );
		    }
		}
	    }
	}
	else if (( INSN == GET_CODE ( relevant_insn )) &&
		 ( PARALLEL == GET_CODE ( relevant_body )) &&
		 ( SET == GET_CODE ( relevant_body = 
				    XVECEXP ( relevant_body, 0, 0 ))) &&
		 ( 0 == strcmp ( \"ee\",
				GET_RTX_FORMAT ( GET_CODE ( XEXP ( relevant_body, 1 ))))) &&
		 ( cc0_rtx == XEXP ( XEXP ( relevant_body, 1 ), 0 )))
	{
	    if (( GEU == GET_CODE ( XEXP ( relevant_body, 1 ))) ||
		( GE == GET_CODE ( XEXP ( relevant_body, 1 ))) ||
		( LEU == GET_CODE ( XEXP ( relevant_body, 1 ))) ||
		( LE == GET_CODE ( XEXP ( relevant_body, 1 ))) ||
		( EQU == GET_CODE ( XEXP ( relevant_body, 1 ))) ||
		( EQ == GET_CODE ( XEXP ( relevant_body, 1 ))))
	    {
		/* change ineq into const1_rtx because x == x always. */

		XEXP ( relevant_body, 1 ) = const1_rtx;
	    }
	    else 
	    {
		/* otherwise change ineq into const0_rtx. */

		XEXP ( relevant_body, 1 ) = const0_rtx;
	    }
	    INSN_CODE ( relevant_insn ) = -1;
	}
	return \"\";
    }    

    cc_status.mdep = CC_SIGNED;

    return \"cmp	%1,%0\";
}" )

( define_insn ""
  [ ( set ( cc0 )
          ( compare ( match_operand:DI 0 "register_operand" "D" )
                    ( match_operand:DI 1 "register_operand" "D" )))
  ]
  "UNSIGNED_COMPARE_P( insn )"
  "*
{
    extern enum mdep_cc_info next_cc_use ( );
    extern rtx next_cc_relevancy ( );
    rtx relevant_insn, relevant_body;
    
    /* sometimes this compiler manages attempt ( compare ( reg x ) ( reg x )).
       the condition codes implied by this are obvious. we peek down the insn
       chain and discover the next_cc0_relevancy ( ). if we discover
       that the ccs are being set gratuitiously, we ignore this compare, 
       otherwise we change the cc0 consumer to be a constant load in the case
       of an Scond or a hard branch or nop in the case of a Bcond. */

    if ( REGNO ( operands[0] ) == REGNO ( operands[1] ))
    {
	relevant_insn = next_cc_relevancy ( insn );
	relevant_body = PATTERN ( relevant_insn );
	
	if ( JUMP_INSN == GET_CODE ( relevant_insn ))
	{
	    if (( IF_THEN_ELSE == GET_CODE ( relevant_body =
					    XEXP ( relevant_body, 1 ))) &&
		( CONST_INT != 
		 GET_CODE ( XEXP ( relevant_body, 0 ))))
	    {
		if (( GEU == GET_CODE ( XEXP ( relevant_body, 0 ))) ||
		    ( GE == GET_CODE ( XEXP ( relevant_body, 0 ))) ||
		    ( LEU == GET_CODE ( XEXP ( relevant_body, 0 ))) ||
		    ( LE == GET_CODE ( XEXP ( relevant_body, 0 ))) ||
		    ( EQU == GET_CODE ( XEXP ( relevant_body, 0 ))) ||
		    ( EQ == GET_CODE ( XEXP ( relevant_body, 0 ))))
		{
		    /* change ineq into const1_rtx because x == x always. */

		    if ( pc_rtx == XEXP ( XEXP ( PATTERN ( relevant_insn ),
						1 ), 1 ))
		    {
			delete_insn ( relevant_insn );
		    }
		    else
		    {
			INSN_CODE ( relevant_insn ) = -1;

			XEXP ( PATTERN ( relevant_insn ), 1 ) =
			    XEXP ( XEXP ( PATTERN ( relevant_insn ), 1 ), 1 );
		    }
		}
		else
		{
		    /* otherwise change ineq into const0_rtx. */
		    
		    if ( pc_rtx == XEXP ( XEXP ( PATTERN ( relevant_insn ),
						1 ), 1 ))
		    {
			INSN_CODE ( relevant_insn ) = -1;

			XEXP ( PATTERN ( relevant_insn ), 1 ) =
			    XEXP ( XEXP ( PATTERN ( relevant_insn ), 1 ), 2 );
		    }
		    else
		    {
			delete_insn ( relevant_insn );
		    }
		}
	    }
	}
	else if (( INSN == GET_CODE ( relevant_insn )) &&
		 ( PARALLEL == GET_CODE ( relevant_body )) &&
		 ( SET == GET_CODE ( relevant_body = 
				    XVECEXP ( relevant_body, 0, 0 ))) &&
		 ( 0 == strcmp ( \"ee\",
				GET_RTX_FORMAT ( GET_CODE ( XEXP ( relevant_body, 1 ))))) &&
		 ( cc0_rtx == XEXP ( XEXP ( relevant_body, 1 ), 0 )))
	{
	    if (( GEU == GET_CODE ( XEXP ( relevant_body, 1 ))) ||
		( GE == GET_CODE ( XEXP ( relevant_body, 1 ))) ||
		( LEU == GET_CODE ( XEXP ( relevant_body, 1 ))) ||
		( LE == GET_CODE ( XEXP ( relevant_body, 1 ))) ||
		( EQU == GET_CODE ( XEXP ( relevant_body, 1 ))) ||
		( EQ == GET_CODE ( XEXP ( relevant_body, 1 ))))
	    {
		/* change ineq into const1_rtx because x == x always. */

		XEXP ( relevant_body, 1 ) = const1_rtx;
	    }
	    else 
	    {
		/* otherwise change ineq into const0_rtx. */

		XEXP ( relevant_body, 1 ) = const0_rtx;
	    }
	    INSN_CODE ( relevant_insn ) = -1;
	}
	return \"\";
    }
    
    cc_status.mdep = CC_UNSIGNED;

    return \"move	#0,%k0\;move	#0,%k1\;cmp	%1,%0\";
}" )

( define_insn "cmpdi"
  [ ( set ( cc0 )
          ( compare ( match_operand:DI 0 "register_operand" "D" )
                    ( match_operand:DI 1 "register_operand" "D" )))
  ]
  ""
  "*
{
    extern enum mdep_cc_info next_cc_use ( );
    extern rtx next_cc_relevancy ( );
    rtx relevant_insn, relevant_body;
    
    /* sometimes this compiler manages attempt ( compare ( reg x ) ( reg x )).
       the condition codes implied by this are obvious. we peek down the insn
       chain and discover the next_cc0_relevancy ( ). if we discover
       that the ccs are being set gratuitiously, we ignore this compare, 
       otherwise we change the cc0 consumer to be a constant load in the case
       of an Scond or a hard branch or nop in the case of a Bcond. */

    if ( REGNO ( operands[0] ) == REGNO ( operands[1] ))
    {
	relevant_insn = next_cc_relevancy ( insn );
	relevant_body = PATTERN ( relevant_insn );
	
	if ( JUMP_INSN == GET_CODE ( relevant_insn ))
	{
	    if (( IF_THEN_ELSE == GET_CODE ( relevant_body =
					    XEXP ( relevant_body, 1 ))) &&
		( CONST_INT != 
		 GET_CODE ( XEXP ( relevant_body, 0 ))))
	    {
		if (( GEU == GET_CODE ( XEXP ( relevant_body, 0 ))) ||
		    ( GE == GET_CODE ( XEXP ( relevant_body, 0 ))) ||
		    ( LEU == GET_CODE ( XEXP ( relevant_body, 0 ))) ||
		    ( LE == GET_CODE ( XEXP ( relevant_body, 0 ))) ||
		    ( EQU == GET_CODE ( XEXP ( relevant_body, 0 ))) ||
		    ( EQ == GET_CODE ( XEXP ( relevant_body, 0 ))))
		{
		    /* change ineq into const1_rtx because x == x always. */

		    if ( pc_rtx == XEXP ( XEXP ( PATTERN ( relevant_insn ),
						1 ), 1 ))
		    {
			delete_insn ( relevant_insn );
		    }
		    else
		    {
			INSN_CODE ( relevant_insn ) = -1;

			XEXP ( PATTERN ( relevant_insn ), 1 ) =
			    XEXP ( XEXP ( PATTERN ( relevant_insn ), 1 ), 1 );
		    }
		}
		else
		{
		    /* otherwise change ineq into const0_rtx. */
		    
		    if ( pc_rtx == XEXP ( XEXP ( PATTERN ( relevant_insn ),
						1 ), 1 ))
		    {
			INSN_CODE ( relevant_insn ) = -1;

			XEXP ( PATTERN ( relevant_insn ), 1 ) =
			    XEXP ( XEXP ( PATTERN ( relevant_insn ), 1 ), 2 );
		    }
		    else
		    {
			delete_insn ( relevant_insn );
		    }
		}
	    }
	}
	else if (( INSN == GET_CODE ( relevant_insn )) &&
		 ( PARALLEL == GET_CODE ( relevant_body )) &&
		 ( SET == GET_CODE ( relevant_body = 
				    XVECEXP ( relevant_body, 0, 0 ))) &&
		 ( 0 == strcmp ( \"ee\",
				GET_RTX_FORMAT ( GET_CODE ( XEXP ( relevant_body, 1 ))))) &&
		 ( cc0_rtx == XEXP ( XEXP ( relevant_body, 1 ), 0 )))
	{
	    if (( GEU == GET_CODE ( XEXP ( relevant_body, 1 ))) ||
		( GE == GET_CODE ( XEXP ( relevant_body, 1 ))) ||
		( LEU == GET_CODE ( XEXP ( relevant_body, 1 ))) ||
		( LE == GET_CODE ( XEXP ( relevant_body, 1 ))) ||
		( EQU == GET_CODE ( XEXP ( relevant_body, 1 ))) ||
		( EQ == GET_CODE ( XEXP ( relevant_body, 1 ))))
	    {
		/* change ineq into const1_rtx because x == x always. */

		XEXP ( relevant_body, 1 ) = const1_rtx;
	    }
	    else 
	    {
		/* otherwise change ineq into const0_rtx. */

		XEXP ( relevant_body, 1 ) = const0_rtx;
	    }
	    INSN_CODE ( relevant_insn ) = -1;
	}
	return \"\";
    }
    
    cc_status.mdep = CC_SIGNED;

    return \"cmp	%1,%0\";
}" )

;;
;;  ...........................................................................
;;
;;          TESTS
;;
;;  ...........................................................................
;;

( define_insn "tstpsi"
  [ ( set ( cc0 )
	  ( match_operand:PSI 0 "register_operand" "D" )) ]
  ""
  "*
{
    if ( CC_UNSIGNED == ( cc_status.mdep = next_cc_use ( insn )))
    {
	return \"move	#0,%k0\;tst	%0\";
    }
    else
    {
	return \"tst	%0\";
    }
}" )

( define_insn "tstsi"
  [ ( set ( cc0 )
	  ( match_operand:SI 0 "register_operand" "D" )) ]
  ""
  "*
{
    if ( CC_UNSIGNED == ( cc_status.mdep = next_cc_use ( insn )))
    {
	return \"move	#0,%k0\;tst	%0\";
    }
    else
    {
	return \"tst	%0\";
    }
}" )

( define_insn "tstdi"
  [ ( set ( cc0 )
	  ( match_operand:DI 0 "general_operand" "D" )) ]
  ""
  "*
{
    if ( CC_UNSIGNED == ( cc_status.mdep = next_cc_use ( insn )))
    {
	return \"move	#0,%k0\;tst	%0\";
    }
    else
    {
	return \"tst	%0\";
    }
}" )

;;
;;  ...........................................................................
;;
;;          SCALAR CONVERSIONS USING TRUNCATION
;;
;;  ...........................................................................
;;

( define_insn "truncsipsi2"
  [ ( set ( match_operand:PSI 0 "register_operand" "=A" )
	  ( truncate:PSI
	    ( match_operand:SI 1 "register_operand" "=*S*D" )))
  ]
  ""
  "move	%e1,%0" )

( define_insn "truncdisi2"
  [ ( set ( match_operand:SI 0 "general_operand" "=*S*D" )
	  ( truncate:SI
	    ( match_operand:DI 1 "general_operand" "*S*D" )))
  ]
  ""
  "*
{
    switch ( which_alternative )
    {
    case 0:
	if ( IS_SRC_OR_MPY_P ( REGNO ( operands[1] )))
	{
	    return \"move	%g1,%0\";
	}
	else
	{
	    return \"move	%h1,%0\";
	}
    }
}")
	
;;
;;  ...........................................................................
;;
;;          SCALAR CONVERSIONS USING ZERO EXTENSION
;;
;;  ...........................................................................
;;

( define_expand "zero_extendqisi2"
  [ ( set ( match_operand:SI 0 "register_operand" "" )
	  ( zero_extend:SI
	    ( match_operand:QI 1 "register_operand" "" )))
  ]
  ""
  "
{
    if ( SUBREG == GET_CODE ( operands[1] ))
    {
	operands[1] = copy_rtx ( SUBREG_REG ( operands[1] ));
    }
    else
    {
	operands[1] = copy_rtx ( operands[1] );
    }	
    operands[1] = gen_rtx ( SUBREG, SImode, operands[1], 0 );
    
    emit_insn ( gen_rtx ( SET, VOIDmode, operands[0], operands[1] ));

    DONE;
}" )

( define_insn "zero_extendpsisi2"
  [ ( set ( match_operand:SI 0 "general_operand" "=*D*S" )
	  ( zero_extend:SI 
	    ( match_operand:PSI 1 "general_operand" "*A*D*S" )))
  ]
  ""
  "*
{
    /* we may want to add mem-ref as an opt. later. */

    if ( REGNO ( operands[0] ) == REGNO ( operands[1] ))
    {
	return \"\";
    }
    
    return \"move	%1,%0\";
}")

( define_insn "zero_extendsidi2"
  [ ( set ( match_operand:DI 0 "general_operand" "=&*S*D" )
	  ( zero_extend:DI 
	    ( match_operand:SI 1 "general_operand" "*S*D" )))
  ]
  ""
  "*
{
    if ( DST_REGS == REGNO_REG_CLASS ( REGNO ( operands[0] )))
    {
	return \"clr	%0\;move	%1,%h0\";
    }
    else
    {
	return \"move	%1,%0\;move	#0,%g0\";
    }
}")

;;
;;  ...........................................................................
;;
;;          SCALAR CONVERSIONS USING SIGN EXTENSION
;;
;;  ...........................................................................
;;

( define_expand "extendqisi2"
  [ ( set ( match_operand:SI 0 "register_operand" "" )
	  ( sign_extend:SI
	    ( match_operand:QI 1 "register_operand" "" )))
  ]
  ""
  "
{
    if ( SUBREG == GET_CODE ( operands[1] ))
    {
	operands[1] = copy_rtx ( SUBREG_REG ( operands[1] ));
    }
    else
    {
	operands[1] = copy_rtx ( operands[1] );
    }
    operands[1] = gen_rtx ( SUBREG, SImode, operands[1], 0 );
    
    emit_insn ( gen_rtx ( SET, VOIDmode, operands[0], operands[1] ));

    DONE;
}" )

( define_insn "extendsidi2"
  [ ( set ( match_operand:DI 0 "general_operand" "=S" )
	  ( sign_extend:DI 
	    ( match_operand:SI 1 "general_operand" "D" )))
  ]
  ""
  "move	%1,%0\;move	%k1,%g0" )

( define_insn "extendpsisi2"
  [ ( set ( match_operand:SI 0 "general_operand" "=D" )
	  ( sign_extend:SI 
	    ( match_operand:PSI 1 "general_operand" "*A*S" )))
  ]
  ""
  "*
{
    /* we may want to add mem-ref as an opt. later. */

    if ( DST_REGS == REGNO_REG_CLASS ( REGNO ( operands[0] )) &&
	ADDR_REGS != REGNO_REG_CLASS ( REGNO ( operands[1] )) &&
	! MEM_IN_STRUCT_P ( operands[0] ) &&
	! MEM_IN_STRUCT_P ( operands[1] ))
    {
	return \"tfr	%1,%0\";
    }
    else
    {
	return \"move	%1,%0\";
    }
}")

;;
;;  ...........................................................................
;;
;;          CONVERSIONS BETWEEN FLOAT AND DOUBLE
;;
;;  ...........................................................................
;;

;;
;;  ...........................................................................
;;
;;          CONVERSIONS BETWEEN FLOATING POINT AND INTEGER
;;
;;  ...........................................................................
;;

 ;; Using the signed routine at this point - this is a bug.

( define_insn "floatunssidf2"
  [ ( set ( match_operand:DF 0 "register_operand" "=D" )
	  ( unsigned_float:DF 
	    ( match_operand:SI 1 "register_operand" "0" )))
  ]
  ""
  "*
{
    if ( DSP16_A_REGNUM == REGNO ( operands[0] ))
    {
	return \"jsr	floatsidf_a\";
    }
    else
    {
	return \"jsr	floatsidf_b\";
    }
}" )

 ;; Using the signed routine at this point - this is a bug.

( define_insn "floatunssisf2"
  [ ( set ( match_operand:SF 0 "register_operand" "=D" )
	  ( unsigned_float:SF 
	    ( match_operand:SI 1 "register_operand" "0" )))
  ]
  ""
  "*
{
    if ( DSP16_A_REGNUM == REGNO ( operands[0] ))
    {
	return \"jsr	floatsidf_a\";
    }
    else
    {
	return \"jsr	floatsidf_b\";
    }
}" )

( define_insn "floatsidf2"
  [ ( set ( match_operand:DF 0 "register_operand" "=D" )
	  ( float:DF 
	    ( match_operand:SI 1 "register_operand" "0" )))
  ]
  ""
  "*
{
    if ( DSP16_A_REGNUM == REGNO ( operands[0] ))
    {
	return \"jsr	floatsidf_a\";
    }
    else
    {
	return \"jsr	floatsidf_b\";
    }
}" )
	
( define_insn "floatsisf2"
  [ ( set ( match_operand:SF 0 "register_operand" "=D" )
	  ( float:SF 
	    ( match_operand:SI 1 "register_operand" "0" )))
  ]
  ""
  "*
{
    if ( DSP16_A_REGNUM == REGNO ( operands[0] ))
    {
	return \"jsr	floatsidf_a\";
    }
    else
    {
	return \"jsr	floatsidf_b\";
    }
}" )

( define_insn "fixdfsi2"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( fix:SI 
	    ( match_operand:DF 1 "register_operand" "0" )))
  ]
  ""
  "*
{
    if ( DSP16_A_REGNUM == REGNO ( operands[0] ))
    {
	return \"jsr	fixdfsi_a\";
    }
    else
    {
	return \"jsr	fixdfsi_b\";
    }
}" )

( define_insn "fixsfsi2"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( fix:SI 
	    ( match_operand:SF 1 "register_operand" "0" )))
  ]
  ""
  "*
{
    if ( DSP16_A_REGNUM == REGNO ( operands[0] ))
    {
	return \"jsr	fixdfsi_a\";
    }
    else
    {
	return \"jsr	fixdfsi_b\";
    }
}" )

( define_insn "fixunsdfsi2"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( unsigned_fix:SI 
	    ( match_operand:DF 1 "register_operand" "0" )))
  ]
  ""
  "*
{
    if ( DSP16_A_REGNUM == REGNO ( operands[0] ))
    {
	return \"jsr	fixunsdfsi_a\";
    }
    else
    {
	return \"jsr	fixunsdfsi_b\";
    }
}" )

( define_insn "fixunssfsi2"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( unsigned_fix:SI 
	    ( match_operand:SF 1 "register_operand" "0" )))
  ]
  ""
  "*
{
    if ( DSP16_A_REGNUM == REGNO ( operands[0] ))
    {
	return \"jsr	fixunsdfsi_a\";
    }
    else
    {
	return \"jsr	fixunsdfsi_b\";
    }
}" )

 ;; Using the signed routine at this point - this is a bug.

( define_insn "floatunsdidf2"
  [ ( set ( match_operand:DF 0 "register_operand" "=D" )
	  ( unsigned_float:DF 
	    ( match_operand:DI 1 "register_operand" "0" )))
  ]
  ""
  "*
{
    if ( DSP16_A_REGNUM == REGNO ( operands[0] ))
    {
	return \"jsr	floatdidf_a\";
    }
    else
    {
	return \"jsr	floatdidf_b\";
    }
}" )

 ;; Using the signed routine at this point - this is a bug.

( define_insn "floatunsdisf2"
  [ ( set ( match_operand:SF 0 "register_operand" "=D" )
	  ( unsigned_float:SF 
	    ( match_operand:DI 1 "register_operand" "0" )))
  ]
  ""
  "*
{
    if ( DSP16_A_REGNUM == REGNO ( operands[0] ))
    {
	return \"jsr	floatdidf_a\";
    }
    else
    {
	return \"jsr	floatdidf_b\";
    }
}" )

( define_insn "floatdidf2"
  [ ( set ( match_operand:DF 0 "register_operand" "=D" )
	  ( float:DF 
	    ( match_operand:DI 1 "register_operand" "0" )))
  ]
  ""
  "*
{
    if ( DSP16_A_REGNUM == REGNO ( operands[0] ))
    {
	return \"jsr	floatdidf_a\";
    }
    else
    {
	return \"jsr	floatdidf_b\";
    }
}" )
	
( define_insn "floatdisf2"
  [ ( set ( match_operand:SF 0 "register_operand" "=D" )
	  ( float:SF 
	    ( match_operand:DI 1 "register_operand" "0" )))
  ]
  ""
  "*
{
    if ( DSP16_A_REGNUM == REGNO ( operands[0] ))
    {
	return \"jsr	floatdidf_a\";
    }
    else
    {
	return \"jsr	floatdidf_b\";
    }
}" )

( define_insn "fixdfdi2"
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
	  ( fix:DI 
	    ( match_operand:DF 1 "register_operand" "0" )))
  ]
  ""
  "*
{
    if ( DSP16_A_REGNUM == REGNO ( operands[0] ))
    {
	return \"jsr	fixdfdi_a\";
    }
    else
    {
	return \"jsr	fixdfdi_b\";
    }
}" )

( define_insn "fixsfdi2"
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
	  ( fix:DI 
	    ( match_operand:SF 1 "register_operand" "0" )))
  ]
  ""
  "*
{
    if ( DSP16_A_REGNUM == REGNO ( operands[0] ))
    {
	return \"jsr	fixdfdi_a\";
    }
    else
    {
	return \"jsr	fixdfdi_b\";
    }
}" )

( define_insn "fixunsdfdi2"
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
	  ( unsigned_fix:DI 
	    ( match_operand:DF 1 "register_operand" "0" )))
  ]
  ""
  "*
{
    if ( DSP16_A_REGNUM == REGNO ( operands[0] ))
    {
	return \"jsr	fixunsdfdi_a\";
    }
    else
    {
	return \"jsr	fixunsdfdi_b\";
    }
}" )

( define_insn "fixunssfdi2"
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
	  ( unsigned_fix:DI 
	    ( match_operand:SF 1 "register_operand" "0" )))
  ]
  ""
  "*
{
    if ( DSP16_A_REGNUM == REGNO ( operands[0] ))
    {
	return \"jsr	fixunsdfdi_a\";
    }
    else
    {
	return \"jsr	fixunsdfdi_b\";
    }
}" )

( define_expand "fix_truncdfsi2"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( fix:SI 
	    ( match_operand:DF 1 "register_operand" "0" )))
  ]
  ""
  "" )

( define_expand "fix_truncsfsi2"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( fix:SI 
	    ( match_operand:SF 1 "register_operand" "0" )))
  ]
  ""
  "" )

( define_expand "fixuns_truncdfsi2"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( unsigned_fix:SI 
	    ( match_operand:DF 1 "register_operand" "0" )))
  ]
  ""
  "" )

( define_expand "fixuns_truncsfsi2"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( unsigned_fix:SI 
	    ( match_operand:SF 1 "register_operand" "0" )))
  ]
  ""
  "" )

( define_expand "fix_truncdfdi2"
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
	  ( fix:DI 
	    ( match_operand:DF 1 "register_operand" "0" )))
  ]
  ""
  "" )

( define_expand "fix_truncsfdi2"
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
	  ( fix:DI 
	    ( match_operand:SF 1 "register_operand" "0" )))
  ]
  ""
  "" )

( define_expand "fixuns_truncdfdi2"
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
	  ( unsigned_fix:DI 
	    ( match_operand:DF 1 "register_operand" "0" )))
  ]
  ""
  "" )

( define_expand "fixuns_truncsfdi2"
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
	  ( unsigned_fix:DI 
	    ( match_operand:SF 1 "register_operand" "0" )))
  ]
  ""
  "" )

;;
;;  ...........................................................................
;;
;;          CONDITIONAL JUMPS
;;
;;  ...........................................................................
;;

( define_insn "do"
  [ ( parallel
      [ ( clobber ( cc0 ))
	( use ( match_operand:SI 0 "general_operand" "*D*S,J" ))
	( set ( pc ) ( if_then_else ( eq ( cc0 ) ( const_int 0 ))
				    ( label_ref ( match_operand 1 "" "" ))
				    ( pc )))
      ] )
  ]
  ""
  "*
{
    extern void record_address_regs_used ( );
    
    /* we must scan forward and make sure that there is at least one non-do
     * insn between this insn and the target label. If not, 86 the loop. 
     * BTW, a nop instruction doesn't count.
     */
    rtx scan = insn;
    
    while ( scan && ( operands[1] != scan ))
    {
	if (( INSN == GET_CODE ( scan )) && 
	    ( const0_rtx != PATTERN ( scan )))
	{
	    break;
	}
        scan = NEXT_INSN ( scan );
    }
    
    if ( ! scan )
    {
	/* do without corresponding od ! */
	abort ( );
    }
    if (( scan == operands[1] ) ||
	( which_alternative && ( 1 == INTVAL ( operands[0] ))))
    {
	/* we're not really doing a do; record that no conflicts are 
	 * possible.
	 */
	record_address_regs_used ( const0_rtx );

	/* decrement the number of uses at the target label. */

	-- LABEL_NUSES ( operands[1] );

	return \"\";
    }

    /* record potential r/n register conflicts. */
    record_address_regs_used ( PATTERN ( scan ));

    if ( which_alternative )
    {
	return \"do	#%c0,%l1\";
    }
    else
    {
	if ( IS_SRC_OR_MPY_P ( REGNO ( operands[0] )))
	{
	    return \"do	%0,%l1\";
	}
	else
	{
	    return \"do	%e0,%l1\";
	}
    }
}" )

;; This shape should match the back-branch insn and produce no real code.
;; It is a placeholder so that the compiler knows that the do loop target
;; label is implicitly a branch.

( define_insn "od"
  [ ( parallel 
      [ ( clobber ( cc0 ))
	( set ( pc ) ( match_operand 0 "" "" ))
      ] )
  ]
  ""
  "*
{
    rtx scan = PREV_INSN ( insn );
    
    while ( scan && 
	   (( INSN != GET_CODE ( scan )) || 
	    /* ignore latent nop insns! */
	    ( const0_rtx == PATTERN ( scan ))) &&
	   ( JUMP_INSN != GET_CODE ( scan )))
    {
	scan = PREV_INSN ( scan );
    }
    if ( ! scan )
    {
	/* od without corresponding do ! */
	abort ( );
    }
    if ( JUMP_INSN == GET_CODE ( scan ))
    {
	/* pop the stack - no chance of conflict. */
	(void) conflicting_address_regs_set_p ( const0_rtx );
	
	/* but hey- auto bonejob! we can't have a jmp as the last insn
	   within the DO! */

	return \"nop\";
    }
    if ( INSN == GET_CODE ( scan ))
    {
	/* if we have a conflict, emit a noop to sw interlock. */
	if ( conflicting_address_regs_set_p ( PATTERN ( scan )))
	{
	    return \"nop\";
	}
    }
    return \"\";
}" )

( define_insn ""
  [ ( parallel [ ( set ( match_operand:SI 0 "register_operand" "=D,D" )
		       ( match_operand:SI 1 "general_operand" "i,!*D*S*A" ))
		 ( clobber 
		   ( match_operand:SI 2 "register_operand" "=*D*S*A,*D*S*A" ))
		 ])
  ]
  ""
  "*
{
    switch ( which_alternative )
    {
    case 0:
	if ( 0 == INTVAL ( operands[1] ))
	{
	    return \"clr	%0\";
	}
	else
	{
	    return \"move	#>1,%0\";
	}

    case 1:
	if ( DST_REGS == REGNO_REG_CLASS ( REGNO ( operands[1] )))
	{
	    return \"move	%e1,%0\";
	}
	else
	{
	    return \"move	%1,%0\";
	}
    }
}" )

( define_expand "seq"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( eq ( cc0 ) ( const_int 0 ))) ]
  ""
  "
{
    rtx clobber_exp = gen_rtx ( CLOBBER, VOIDmode, gen_reg_rtx ( SImode ));
    rtx set_exp = gen_rtx ( SET, VOIDmode, operands[0],
			   gen_rtx ( EQ, VOIDmode, cc0_rtx, const0_rtx ));
        
    emit_insn ( gen_rtx ( PARALLEL, VOIDmode,
			 gen_rtvec ( 2, set_exp, clobber_exp )));
    DONE;
}" )
    
( define_insn ""
  [ ( parallel [ ( set ( match_operand:SI 0 "register_operand" "=&D" )
		       ( eq ( cc0 ) ( const_int 0 )))
		 ( clobber ( match_operand:SI 1 "register_operand" "=*S*D" ))
		 ])
  ]
  ""
  "move	#>1,%1\;move	#0,%0\;teq	%1,%0" )

( define_insn "beq"
  [ ( set ( pc )
	  ( if_then_else ( eq ( cc0 )
			      ( const_int 0 ) )
			 ( label_ref ( match_operand 0 "" "" ) )
			 ( pc ) ) ) ]
  ""
  "jeq	%l0" )

( define_expand "sequ"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( equ ( cc0 ) ( const_int 0 ))) ]
  ""
  "
{
    rtx clobber_exp = gen_rtx ( CLOBBER, VOIDmode, gen_reg_rtx ( SImode ));
    rtx set_exp = gen_rtx ( SET, VOIDmode, operands[0],
			   gen_rtx ( EQU, VOIDmode, cc0_rtx, const0_rtx ));
        
    emit_insn ( gen_rtx ( PARALLEL, VOIDmode,
			 gen_rtvec ( 2, set_exp, clobber_exp )));
    DONE;
}" )
    
( define_insn ""
  [ ( parallel [ ( set ( match_operand:SI 0 "register_operand" "=&D" )
		       ( equ ( cc0 ) ( const_int 0 )))
		 ( clobber ( match_operand:SI 1 "register_operand" "=*S*D" ))
		 ])
  ]
  ""
  "move	#>1,%1\;move	#0,%0\;teq	%1,%0" )

( define_insn "bequ"
  [ ( set ( pc )
	  ( if_then_else ( equ ( cc0 )
			      ( const_int 0 ) )
			 ( label_ref ( match_operand 0 "" "" ) )
			 ( pc ) ) ) ]
  ""
  "jeq	%l0" )

( define_expand "sne"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( ne ( cc0 ) ( const_int 0 ))) ]
  ""
  "
{
    rtx clobber_exp = gen_rtx ( CLOBBER, VOIDmode, gen_reg_rtx ( SImode ));
    rtx set_exp = gen_rtx ( SET, VOIDmode, operands[0],
			   gen_rtx ( NE, VOIDmode, cc0_rtx, const0_rtx ));
        
    emit_insn ( gen_rtx ( PARALLEL, VOIDmode,
			 gen_rtvec ( 2, set_exp, clobber_exp )));
    DONE;
}" )
    
( define_insn ""
  [ ( parallel [ ( set ( match_operand:SI 0 "register_operand" "=&D" )
		       ( ne ( cc0 ) ( const_int 0 )))
		 ( clobber ( match_operand:SI 1 "register_operand" "=*S*D" ))
		 ])
  ]
  ""
  "move	#>1,%1\;move	#0,%0\;tne	%1,%0" )

( define_insn "bne"
  [ ( set ( pc )
	  ( if_then_else ( ne ( cc0 )
			      ( const_int 0 ) )
			 ( label_ref ( match_operand 0 "" "" ) )
			 ( pc ) ) ) ]
  ""
  "jne	%l0" )

( define_expand "sneu"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( neu ( cc0 ) ( const_int 0 ))) ]
  ""
  "
{
    rtx clobber_exp = gen_rtx ( CLOBBER, VOIDmode, gen_reg_rtx ( SImode ));
    rtx set_exp = gen_rtx ( SET, VOIDmode, operands[0],
			   gen_rtx ( NEU, VOIDmode, cc0_rtx, const0_rtx ));
        
    emit_insn ( gen_rtx ( PARALLEL, VOIDmode,
			 gen_rtvec ( 2, set_exp, clobber_exp )));
    DONE;
}" )
    
( define_insn ""
  [ ( parallel [ ( set ( match_operand:SI 0 "register_operand" "=&D" )
		       ( neu ( cc0 ) ( const_int 0 )))
		 ( clobber ( match_operand:SI 1 "register_operand" "=*S*D" ))
		 ])
  ]
  ""
  "move	#>1,%1\;move	#0,%0\;tne	%1,%0" )

( define_insn "bneu"
  [ ( set ( pc )
	  ( if_then_else ( neu ( cc0 )
			      ( const_int 0 ) )
			 ( label_ref ( match_operand 0 "" "" ) )
			 ( pc ) ) ) ]
  ""
  "jne	%l0" )

( define_expand "sgt"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( gt ( cc0 ) ( const_int 0 ))) ]
  ""
  "
{
    rtx clobber_exp = gen_rtx ( CLOBBER, VOIDmode, gen_reg_rtx ( SImode ));
    rtx set_exp = gen_rtx ( SET, VOIDmode, operands[0],
			   gen_rtx ( GT, VOIDmode, cc0_rtx, const0_rtx ));
        
    emit_insn ( gen_rtx ( PARALLEL, VOIDmode,
			 gen_rtvec ( 2, set_exp, clobber_exp )));
    DONE;
}" )
    
( define_insn ""
  [ ( parallel [ ( set ( match_operand:SI 0 "register_operand" "=&D" )
		       ( gt ( cc0 ) ( const_int 0 )))
		 ( clobber ( match_operand:SI 1 "register_operand" "=*S*D" ))
		 ])
  ]
  ""
  "move	#>1,%1\;move	#0,%0\;tgt	%1,%0" )

( define_insn "bgt"
  [ ( set ( pc )
	  ( if_then_else ( gt ( cc0 )
			      ( const_int 0 ) )
			 ( label_ref ( match_operand 0 "" "" ) )
			 ( pc ) ) ) ]
  ""
  "jgt	%l0" )

( define_expand "sgtu"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( gtu ( cc0 ) ( const_int 0 ))) ]
  ""
  "
{
    rtx clobber_exp = gen_rtx ( CLOBBER, VOIDmode, gen_reg_rtx ( SImode ));
    rtx set_exp = gen_rtx ( SET, VOIDmode, operands[0],
			   gen_rtx ( GTU, VOIDmode, cc0_rtx, const0_rtx ));
        
    emit_insn ( gen_rtx ( PARALLEL, VOIDmode,
			 gen_rtvec ( 2, set_exp, clobber_exp )));
    DONE;
}" )
    
( define_insn ""
  [ ( parallel [ ( set ( match_operand:SI 0 "register_operand" "=&D" )
		       ( gtu ( cc0 ) ( const_int 0 )))
		 ( clobber ( match_operand:SI 1 "register_operand" "=*S*D" ))
		 ])
  ]
  ""
  "move	#>1,%1\;move	#0,%0\;tgt	%1,%0" )

( define_insn "bgtu"
  [ ( set ( pc )
	  ( if_then_else ( gtu ( cc0 )
			       ( const_int 0 ) )
			 ( label_ref ( match_operand 0 "" "" ) )
			 ( pc ) ) ) ]
  ""
  "jgt	%l0" )

( define_expand "slt"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( lt ( cc0 ) ( const_int 0 ))) ]
  ""
  "
{
    rtx clobber_exp = gen_rtx ( CLOBBER, VOIDmode, gen_reg_rtx ( SImode ));
    rtx set_exp = gen_rtx ( SET, VOIDmode, operands[0],
			   gen_rtx ( LT, VOIDmode, cc0_rtx, const0_rtx ));
        
    emit_insn ( gen_rtx ( PARALLEL, VOIDmode,
			 gen_rtvec ( 2, set_exp, clobber_exp )));
    DONE;
}" )
    
( define_insn ""
  [ ( parallel [ ( set ( match_operand:SI 0 "register_operand" "=&D" )
		       ( lt ( cc0 ) ( const_int 0 )))
		 ( clobber ( match_operand:SI 1 "register_operand" "=*S*D" ))
		 ])
  ]
  ""
  "move	#>1,%1\;move	#0,%0\;tlt	%1,%0" )

( define_insn "blt"
  [ ( set ( pc )
	  ( if_then_else ( lt ( cc0 )
			      ( const_int 0 ) )
			 ( label_ref ( match_operand 0 "" "" ) )
			 ( pc ) ) ) ]
  ""
  "jlt	%l0" )

( define_expand "sltu"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( ltu ( cc0 ) ( const_int 0 ))) ]
  ""
  "
{
    rtx clobber_exp = gen_rtx ( CLOBBER, VOIDmode, gen_reg_rtx ( SImode ));
    rtx set_exp = gen_rtx ( SET, VOIDmode, operands[0],
			   gen_rtx ( LTU, VOIDmode, cc0_rtx, const0_rtx ));
        
    emit_insn ( gen_rtx ( PARALLEL, VOIDmode,
			 gen_rtvec ( 2, set_exp, clobber_exp )));
    DONE;
}" )
    
( define_insn ""
  [ ( parallel [ ( set ( match_operand:SI 0 "register_operand" "=&D" )
		       ( ltu ( cc0 ) ( const_int 0 )))
		 ( clobber ( match_operand:SI 1 "register_operand" "=*S*D" ))
		 ])
  ]
  ""
  "move	#>1,%1\;move	#0,%0\;tlt	%1,%0" )

( define_insn "bltu"
  [ ( set ( pc )
	  ( if_then_else ( ltu ( cc0 )
			       ( const_int 0 ) )
			 ( label_ref ( match_operand 0 "" "" ) )
			 ( pc ) ) ) ]
  ""
  "jlt	%l0" )

( define_expand "sge"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( ge ( cc0 ) ( const_int 0 ))) ]
  ""
  "
{
    rtx clobber_exp = gen_rtx ( CLOBBER, VOIDmode, gen_reg_rtx ( SImode ));
    rtx set_exp = gen_rtx ( SET, VOIDmode, operands[0],
			   gen_rtx ( GE, VOIDmode, cc0_rtx, const0_rtx ));
        
    emit_insn ( gen_rtx ( PARALLEL, VOIDmode,
			 gen_rtvec ( 2, set_exp, clobber_exp )));
    DONE;
}" )
    
( define_insn ""
  [ ( parallel [ ( set ( match_operand:SI 0 "register_operand" "=&D" )
		       ( ge ( cc0 ) ( const_int 0 )))
		 ( clobber ( match_operand:SI 1 "register_operand" "=*S*D" ))
		 ])
  ]
  ""
  "move	#>1,%1\;move	#0,%0\;tge	%1,%0" )

( define_insn "bge"
  [ ( set ( pc )
	  ( if_then_else ( ge ( cc0 )
			      ( const_int 0 ) )
			 ( label_ref ( match_operand 0 "" "" ) )
			 ( pc ) ) ) ]
  ""
  "jge	%l0" )

( define_expand "sgeu"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( geu ( cc0 ) ( const_int 0 ))) ]
  ""
  "
{
    rtx clobber_exp = gen_rtx ( CLOBBER, VOIDmode, gen_reg_rtx ( SImode ));
    rtx set_exp = gen_rtx ( SET, VOIDmode, operands[0],
			   gen_rtx ( GEU, VOIDmode, cc0_rtx, const0_rtx ));
        
    emit_insn ( gen_rtx ( PARALLEL, VOIDmode,
			 gen_rtvec ( 2, set_exp, clobber_exp )));
    DONE;
}" )
    
( define_insn ""
  [ ( parallel [ ( set ( match_operand:SI 0 "register_operand" "=&D" )
		       ( geu ( cc0 ) ( const_int 0 )))
		 ( clobber ( match_operand:SI 1 "register_operand" "=*S*D" ))
		 ])
  ]
  ""
  "move	#>1,%1\;move	#0,%0\;tge	%1,%0" )

( define_insn "bgeu"
  [ ( set ( pc )
	  ( if_then_else ( geu ( cc0 )
			       ( const_int 0 ) )
			 ( label_ref ( match_operand 0 "" "" ) )
			 ( pc ) ) ) ]
  ""
  "jge	%l0" )

( define_expand "sle"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( le ( cc0 ) ( const_int 0 ))) ]
  ""
  "
{
    rtx clobber_exp = gen_rtx ( CLOBBER, VOIDmode, gen_reg_rtx ( SImode ));
    rtx set_exp = gen_rtx ( SET, VOIDmode, operands[0],
			   gen_rtx ( LE, VOIDmode, cc0_rtx, const0_rtx ));
        
    emit_insn ( gen_rtx ( PARALLEL, VOIDmode,
			 gen_rtvec ( 2, set_exp, clobber_exp )));
    DONE;
}" )
    
( define_insn ""
  [ ( parallel [ ( set ( match_operand:SI 0 "register_operand" "=&D" )
		       ( le ( cc0 ) ( const_int 0 )))
		 ( clobber ( match_operand:SI 1 "register_operand" "=*S*D" ))
		 ])
  ]
  ""
  "move	#>1,%1\;move	#0,%0\;tle	%1,%0" )

( define_insn "ble"
  [ ( set ( pc )
	  ( if_then_else ( le ( cc0 )
			      ( const_int 0 ) )
			 ( label_ref ( match_operand 0 "" "" ) )
			 ( pc ) ) ) ]
  ""
  "jle	%l0" )

( define_expand "sleu"
  [ ( set ( match_operand:SI 0 "register_operand" "=D" )
	  ( leu ( cc0 ) ( const_int 0 ))) ]
  ""
  "
{
    rtx clobber_exp = gen_rtx ( CLOBBER, VOIDmode, gen_reg_rtx ( SImode ));
    rtx set_exp = gen_rtx ( SET, VOIDmode, operands[0],
			   gen_rtx ( LEU, VOIDmode, cc0_rtx, const0_rtx ));
        
    emit_insn ( gen_rtx ( PARALLEL, VOIDmode,
			 gen_rtvec ( 2, set_exp, clobber_exp )));
    DONE;
}" )
    
( define_insn ""
  [ ( parallel [ ( set ( match_operand:SI 0 "register_operand" "=&D" )
		       ( leu ( cc0 ) ( const_int 0 )))
		 ( clobber ( match_operand:SI 1 "register_operand" "=*S*D" ))
		 ])
  ]
  ""
  "move	#>1,%1\;move	#0,%0\;tle	%1,%0" )

( define_insn "bleu"
  [ ( set ( pc )
	  ( if_then_else ( leu ( cc0 )
			       ( const_int 0 ) )
			 ( label_ref ( match_operand 0 "" "" ) )
			 ( pc ) ) ) ]
  ""
  "jle	%l0" )


;;
;;  ...........................................................................
;;
;;          CONDITIONAL JUMPS WITH INVERTED REGISTER ALLOCATION
;;
;;  ...........................................................................
;;

( define_insn ""
  [ ( set ( pc )
	  ( if_then_else ( eq ( cc0 )
			      ( const_int 0 ) )
			 ( pc )
			 ( label_ref ( match_operand 0 "" "" ) ) ) ) ]
  ""
  "jne	%l0" )

( define_insn ""
  [ ( set ( pc )
	  ( if_then_else ( equ ( cc0 )
 		 	       ( const_int 0 ) )
			 ( pc )
			 ( label_ref ( match_operand 0 "" "" ) ) ) ) ]
  ""
  "jne	%l0" )

( define_insn ""
  [ ( set ( pc )
	  ( if_then_else ( ne ( cc0 )
			      ( const_int 0 ) )
			 ( pc )
			 ( label_ref ( match_operand 0 "" "" ) ) ) ) ]
  ""
  "jeq	%l0" )

( define_insn ""
  [ ( set ( pc )
	  ( if_then_else ( neu ( cc0 )
			       ( const_int 0 ) )
			 ( pc )
			 ( label_ref ( match_operand 0 "" "" ) ) ) ) ]
  ""
  "jeq	%l0" )

( define_insn ""
  [ ( set ( pc )
	  ( if_then_else ( gt ( cc0 )
			      ( const_int 0 ) )
			 ( pc )
			 ( label_ref ( match_operand 0 "" "" ) ) ) ) ]
  ""
  "jle	%l0" )

( define_insn ""
  [ ( set ( pc )
	  ( if_then_else ( gtu ( cc0 )
			       ( const_int 0 ) )
			 ( pc )
			 ( label_ref ( match_operand 0 "" "" ) ) ) ) ]
  ""
  "jle	%l0" )

( define_insn ""
  [ ( set ( pc )
	  ( if_then_else ( lt ( cc0 )
			      ( const_int 0 ) )
			 ( pc )
			 ( label_ref ( match_operand 0 "" "" ) ) ) ) ]
  ""
  "jge	%l0" )

( define_insn ""
  [ ( set ( pc )
	  ( if_then_else ( ltu ( cc0 )
			       ( const_int 0 ) )
			 ( pc )
			 ( label_ref ( match_operand 0 "" "" ) ) ) ) ]
  ""
  "jge	%l0" )

( define_insn ""
  [ ( set ( pc )
	  ( if_then_else ( ge ( cc0 )
			      ( const_int 0 ) )
			 ( pc )
			 ( label_ref ( match_operand 0 "" "" ) ) ) ) ]
  ""
  "jlt	%l0" )

( define_insn ""
  [ ( set ( pc )
	  ( if_then_else ( geu ( cc0 )
			       ( const_int 0 ) )
			 ( pc )
			 ( label_ref ( match_operand 0 "" "" ) ) ) ) ]
  ""
  "jlt	%l0" )


( define_insn ""
  [ ( set ( pc )
	  ( if_then_else ( le ( cc0 )
			      ( const_int 0 ) )
			 ( pc )
			 ( label_ref ( match_operand 0 "" "" ) ) ) ) ]
  ""
  "jgt	%l0" )


( define_insn ""
  [ ( set ( pc )
	  ( if_then_else ( leu ( cc0 )
			       ( const_int 0 ) )
			 ( pc )
			 ( label_ref ( match_operand 0 "" "" ) ) ) ) ]
  ""
  "jgt	%l0" )


;;
;;  ...........................................................................
;;
;;          CONDITIONALY STORE ZERO OR NON-ZERO
;;
;;  ...........................................................................
;;

;;
;;  ...........................................................................
;;
;;          UNCONDITIONAL JUMP
;;
;;  ...........................................................................
;;

( define_insn "jump"
  [ ( set ( pc )
	  ( label_ref ( match_operand 0 "" "" ) ) ) ]
  ""
  "jmp	%l0" )


;;
;;  ...........................................................................
;;
;;          TABLE JUMP ( SWITCH IMPLEMENTATION )
;;
;;  ...........................................................................
;;

( define_insn "tablejump"
  [ ( set ( pc ) ( match_operand:PSI 0 "register_operand" "A" ) )
    ( use ( label_ref ( match_operand 1 "" "" ) ) ) ]
  ""
  "jmp	(%0)" )


;;
;;  ...........................................................................
;;
;;          SUBROUTINE CALLS
;;
;;  ...........................................................................
;;

( define_expand "call"
  [ ( call ( match_operand:PSI 0 "general_operand" "mA" )
	   ( match_operand:SI 1 "immediate_operand" "i" ))
  ]
  ""
  "
{
    emit_insn ( 
	       gen_rtx ( PARALLEL,
			VOIDmode,
			gen_rtvec ( 1,
				   gen_rtx ( CALL, 
					    VOIDmode,
					    operands[0], operands[1] ))));
    DONE;
}" )

( define_insn ""
  [ ( parallel [ ( call ( match_operand:PSI 0 "general_operand" "mA" )
			( match_operand:SI 1 "immediate_operand" "i" )) ] )
  ]
  ""
  "*
{
    clear_n_reg_values ( );
    
    switch ( INTVAL ( operands[1] ))
    {
    case 0:
	return \"jsr	%0\";
	
    case 1:
	return \"jsr	%0\;move	(r6)-\";
	
    case 2:
	return \"jsr	%0\;move	(r6)-\;move	(r6)-\";
	
    default:
	return \"jsr	%0\;move	#%p1,n6\;move	(r6)-n6\";
    }
}" )

( define_expand "call_value"
  [ ( set ( match_operand 0 "" "" )
	  ( call ( match_operand:PSI 1 "general_operand" "mA" )
		 ( match_operand:SI 2 "immediate_operand" "i" )))
  ]
  ""
  "
{
    emit_insn ( 
	       gen_rtx ( PARALLEL, VOIDmode,
			gen_rtvec ( 1,
				   gen_rtx ( SET, VOIDmode,
					    operands[0],
					    gen_rtx ( CALL, VOIDmode,
						     operands[1],
						     operands[2] )))));
    DONE;
}" )

( define_insn ""
  [ ( parallel [ ( set ( match_operand 0 "" "" )
		       ( call ( match_operand:PSI 1 "general_operand" "mA" )
			      ( match_operand:SI 2 "immediate_operand" "i" )))
	       ] )
  ]
  ""
  "*
{
    clear_n_reg_values ( );
    
    switch ( INTVAL ( operands[2] ))
    {
    case 0:
	return \"jsr	%1\";
	
    case 1:
	return \"jsr	%1\;move	(r6)-\";
	
    case 2:
	return \"jsr	%1\;move	(r6)-\;move	(r6)-\";
	
    default:
	return \"jsr	%1\;move	#%p2,n6\;move	(r6)-n6\";
    }
}" )


;;
;;  ...........................................................................
;;
;;          NOP
;;
;;  ...........................................................................
;;

( define_insn "nop"
  [ ( const_int 0 ) ]
  ""
  "*
{
    rtx peek = PREV_INSN ( insn );
    
    while (( peek ) && 
	   (( NOTE == GET_CODE ( peek )) ||
	    (( JUMP_INSN == GET_CODE ( peek )) &&
	     ( PARALLEL == GET_CODE ( PATTERN ( peek ))))))
    {
	peek = PREV_INSN ( peek );
    }
    if (( ! peek ) || ( CODE_LABEL != GET_CODE ( peek )) ||
	( ! LABEL_NUSES ( peek )))
    {
	return \"\";
    }
    
    peek = NEXT_INSN ( insn );
    while (( peek ) && 
	   (( NOTE == GET_CODE ( peek )) ||
	    (( JUMP_INSN == GET_CODE ( peek )) &&
	     ( PARALLEL == GET_CODE ( PATTERN ( peek ))))))
    {
	peek = NEXT_INSN ( peek );
    }
    if (( ! peek ) || 
	( ! LABEL_NUSES ( peek )) ||
	(( CODE_LABEL != GET_CODE ( peek )) && 
	 ( const0_rtx != PATTERN ( peek ))))
    {
	return \"\";
    }

    return \"nop\";
}" )

;; This insn is needed because jump.c doesn't realize that this is really
;; a nop.

( define_insn "" [ ( set ( pc ) ( pc )) ] "" "" )

( define_insn "probe" 
  [ ( parallel [ ( const_int 0 ) ] ) ]
  ""
  "*
{
    if ( TARGET_STACK_CHECK )
    {
	return \"jsr	F__stack_check\";
    }
    else
    {
	return \"\";
    }
}" )

;;
;;  ...........................................................................
;;
;;          PEEPHOLE OPTIMIZATIONS
;;
;;  ...........................................................................
;;

;; this sequence can be introduced by the do loop generation code. a 
;; reasonable data flow analysis and optimization phase will (in the future)
;; clean it up.

( define_peephole 
  [ ( set ( match_operand:SI 0 "register_operand" "=*D" )
	  ( minus:SI ( match_operand:SI 1 "register_operand" "0" )
		     ( match_operand:SI 2 "register_operand" "*S*D" )))
    ( set ( match_dup 0 )
	  ( plus:SI ( match_dup 1 )
		    ( match_dup 2 )))
  ]
  "( ! rtx_equal_p (operands[0], operands[2] ))" 
  "" )

;;- Local variables:
;;- mode:emacs-lisp
;;- comment-start: ";;- "
;;- eval: ( set-syntax-table ( copy-sequence ( syntax-table ) ) )
;;- eval: ( modify-syntax-entry ?[ "(]" )
;;- eval: ( modify-syntax-entry ?] ")[" )
;;- eval: ( modify-syntax-entry ?{ "(}" )
;;- eval: ( modify-syntax-entry ?} "){" )
;;- End:

