;;- Machine description for the Motorola 96000 for GNU C compiler
;;   Copyright ( C ) 1988 Free Software Foundation, Inc.
;;
;;      $Header: /usr1/dsp/cvsroot/source/gcc/config/dsp96k.md,v 1.32 92/02/28 15:24:43 jeff Exp $
;;      $Id: dsp96k.md,v 1.32 92/02/28 15:24:43 jeff Exp $
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


;;
;;  ...........................................................................
;;
;;          MOVES, LOADS, STORES
;;
;;  ...........................................................................
;;

( define_expand "movsi" 
  [ ( set
      ( match_operand:SI 0 "general_operand" "" )
      ( match_operand:SI 1 "general_operand" "" ))
  ]
  ""
  "
{
    /* gcc will, by default, generate mem-mem and mem-const moves, even 
       though the insn templates clearly show that these sorts of moves are
       not supported by the target architecture. These moves will exist
       in the rtl until the reload pass, where they will be broken into 
       multiple insns. 

       we attept to break the insn as early as possible (when it is generated)
       in order that the optimizer might make use of the information. this
       also reduces spill code, which is very important when one considers
       the way that gcc loosely generates reloads.

       All of the scalar movXX templates use this technique. */

    if (( ! is_in_reg_p ( operands[0] )) && ( ! is_in_reg_p ( operands[1] )))
    {
	operands[1] = force_reg ( SImode, operands[1] );
    }
}" )

( define_insn ""
  [ ( set
      ( match_operand:SI 0 "general_operand" "=d,<>m,r,r" )
      ( match_operand:SI 1 "general_operand"  "d,r,<>m,g" ))
  ]
  ""
  "*
{
    switch ( which_alternative )
    {
	
    case 0:
	RETURN_DSP ( \"tfr	%1,%0\" );
    
    case 1:
    	RETURN_DSP ( \"move	%z1,@:%0\" );

    case 2:
	RETURN_DSP ( \"move	@:%1,%z0\" );
 
    default:
	RETURN_DSP ( \"move	%z1,%z0\" );
    }
}" )

( define_expand "movqi"
  [ ( set
      ( match_operand:QI 0 "general_operand" "" )
      ( match_operand:QI 1 "general_operand" "" ))
  ]
  ""
  "
{
    /* this is exactly the same as movsi. gcc requires that QImode be
       supported, so we can't just provide movsi et al. */

    if (( ! is_in_reg_p ( operands[0] )) && ( ! is_in_reg_p ( operands[1] )))
    {
	operands[1] = force_reg ( QImode, operands[1] );
    }
}" )

( define_insn ""
  [ ( set
      ( match_operand:QI 0 "general_operand" "=d,<>m,r,r" )
      ( match_operand:QI 1 "general_operand"  "d,r,<>m,g" ))
  ]
  ""
  "*
{
    switch ( which_alternative )
    {
	
    case 0:
	RETURN_DSP ( \"tfr	%1,%0\" );
    
    case 1:
    	RETURN_DSP ( \"move	%z1,@:%0\" );

    case 2:
	RETURN_DSP ( \"move	@:%1,%z0\" );
 
    default:
	RETURN_DSP ( \"move	%z1,%z0\" );
    }
}" )

;; This partial DImode support is provided so that the reload pass and
;; the constant folder won't run into trouble when dealing with multiply
;; results.

( define_insn "movdi"
  [ ( set
      ( match_operand:DI 0 "general_operand" "=D,m,D,D" )
      ( match_operand:DI 1 "general_operand" "m,D,D,i" ))
  ]
  ""
  "*
{
    switch ( which_alternative )
    {
    case 0:
	if ( 'l' == memory_model )
	{
	    RETURN_DSP ( \"move	l:%1,%0.ml\" );
	}
	else
	{
	    switch ( GET_CODE ( XEXP ( operands[1], 0 )))
	    {
	    case REG:
		operands[2] = XEXP ( operands[1], 0 );

		RETURN_DSP ( 
			 \"move	@:(%2)+,%0.m\;move	@:(%2)-,%0.l\" );

	    case PLUS:
	    default:
		/* we have a constant address. */
		operands[2] =
		    gen_mem_plus_const_int_from_mem ( operands[1], 1 );

		RETURN_DSP ( \"move	@:%1,%0.m\;move	@:%2,%0.l\" );
	    }
	}
	
    case 1:
	if ( 'l' == memory_model )
	{
	    RETURN_DSP ( \"move	%1.ml,l:%0\" );
	}
	else
	{
	    switch ( GET_CODE ( XEXP ( operands[0], 0 )))
	    {
	    case REG:
		operands[2] = XEXP ( operands[0], 0 );

		RETURN_DSP ( 
			 \"move	%1.m,@:(%2)+\;move	%1.l,@:(%2)-\" );

	    case PLUS:
	    default:
		operands[2] =
		    gen_mem_plus_const_int_from_mem ( operands[0], 1 );

		RETURN_DSP ( \"move	%1.m,@:%0\;move	%1.l,@:%2\" );
	    }
	}
	
    case 2:
	RETURN_DSP ( \"tfr	%1.l,%0.l	%1.m,%0.m\" );

    case 3:
	if ( INTVAL ( operands[1] ) < 0 )
	{
	    RETURN_DSP ( \"move	#%c1,%0.l\;move	#-1,%0.m\" );
	}
	else
	{
	    RETURN_DSP ( \"move	#%c1,%0.l\;move	#0,%0.m\" );
	}
    }
}" )

( define_expand "movdf"
  [ ( set
      ( match_operand:DF 0 "general_operand" "" )
      ( match_operand:DF 1 "general_operand" "" ))
  ]
  ""
  "
{
    if (( ! is_in_reg_p ( operands[0] )) && ( ! is_in_reg_p ( operands[1] )))
    {
	operands[1] = force_reg ( DFmode, operands[1] );
    }
}" )
    
( define_insn ""
  [ ( set 
      ( match_operand:DF 0 "general_operand" "=f,f,<>m" )
      ( match_operand:DF 1 "general_operand"  "f,<>m,f" ))
  ]
  ""
  "*
{
    switch ( which_alternative )
    {

    case 0:
	RETURN_DSP ( \"ftfr.x	%1,%0\" );

    case 1:
	if ( 'l' == memory_model )
	{
	    RETURN_DSP ( \"move	l:%1,%z0\" );
	}
	else
	{
	    switch ( GET_CODE ( XEXP ( operands[1], 0 )))
	    {
	    case POST_INC:

		RETURN_DSP ( 
		\"move	@:%1,d8.m\;move	@:%1,d8.l\;move	d8.ml,%z0\" );
		
	    case POST_DEC:

		operands[2] = XEXP ( operands[1], 0 );
		RETURN_DSP ( 
		\"move	@:(%2)+,d8.m\;move	@:(%2)-,d8.l\;move	d8.ml,%z0\;move	(%2)-\;move	(%2)-\" );

	    case REG:

		operands[2] = XEXP ( operands[1], 0 );
		RETURN_DSP (
		\"move	@:(%2)+,d8.m\;move	@:(%2)-,d8.l\;move	d8.ml,%z0\" );

	    case PLUS:
	    default:
		operands[2] = 
		    gen_mem_plus_const_int_from_mem ( operands[1], 1 );
		    
		RETURN_DSP (
		\"move	@:%1,d8.m\;move	@:%2,d8.l\;move	d8.ml,%z0\" );
	    }
	}

    case 2:
	if ( 'l' == memory_model )
	{
	    RETURN_DSP ( \"move	%z1,l:%0\" );
	}
	else
	{
	    switch ( GET_CODE ( XEXP ( operands[0], 0 )))
	    {
	    case POST_INC
:
		RETURN_DSP (
		\"move	%z1,d8.ml\;move	d8.m,@:%0\;move	d8.l,@:%0\" );
		
	    case POST_DEC:

		operands[2] = XEXP ( operands[0], 0 );
		RETURN_DSP (
		\"move	%z1,d8.ml\;move	d8.m,@:(%2)+\;move	d8.l,@:(%2)-\;move	(%2)-\;move	(%2)-\" );
		
	    case REG:

		operands[2] = XEXP ( operands[0], 0 );
		RETURN_DSP (
		\"move	%z1,d8.ml\;move	d8.m,@:(%2)+\;move	d8.l,@:(%2)-\" );

	    case PLUS:
	    default:
		operands[2] = 
		    gen_mem_plus_const_int_from_mem ( operands[0], 1 );

		RETURN_DSP ( 
		\"move	%z1,d8.ml\;move	d8.m,@:%0\;move	d8.l,@:%2\" );
	    }
	}
    }
}" )

( define_expand "movsf"
  [ ( set
      ( match_operand:SF 0 "general_operand" "" )
      ( match_operand:SF 1 "general_operand" "" ))
  ]
  ""
  "
{
    if (( ! is_in_reg_p ( operands[0] )) && ( ! is_in_reg_p ( operands[1] )))
    {
	operands[1] = force_reg ( SFmode, operands[1] );
    }
}" )
    
( define_insn ""
  [ ( set ( match_operand:SF 0 "general_operand" "=f,f,<>m" )
	  ( match_operand:SF 1 "general_operand"  "f,<>m,f" ))
  ]
  ""
  "*
{
    switch ( which_alternative )
    {
    case 0:
	RETURN_DSP ( \"ftfr.s	%1,%0\" );

    case 1:
	RETURN_DSP ( \"move	@:%1,%z0\" );

    case 2:
    	RETURN_DSP ( \"move	%z1,@:%0\" );
    }
}" )

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
    rtx dbl_reg, op0_reg, op1_reg;
    
    op0_reg = gen_reg_rtx ( SImode );
    emit_move_insn ( op0_reg, force_reg ( SImode, XEXP ( operands[0], 0 )));
    
    op1_reg = gen_reg_rtx ( SImode );
    emit_move_insn ( op1_reg, force_reg ( SImode, XEXP ( operands[1], 0 )));
    
    dbl_reg = gen_reg_rtx ( DFmode );

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
				   gen_rtx ( CLOBBER, VOIDmode, dbl_reg ),
				   gen_rtx ( SET, VOIDmode, operands[0],
					    operands[1] ),
				   gen_rtx ( USE, VOIDmode, op0_reg ),
				   gen_rtx ( USE, VOIDmode, op1_reg ))));
    
    DONE;
}" )

( define_insn ""
  [ ( parallel [ ( clobber ( match_operand:SI 0 "register_operand" "=a" ))
		 ( clobber ( match_operand:SI 1 "register_operand" "=a" ))
		 ( use ( match_operand:SI 2 "immediate_operand" "i" ))
		 ( clobber ( match_operand:DF 3 "register_operand" "=f" ))
		 ( set ( match_operand:BLK 4 "memory_operand" "" )
		       ( match_operand:BLK 5 "memory_operand" "" ))
		 ( use ( match_operand:SI 6 "register_operand" "0" ))
		 ( use ( match_operand:SI 7 "register_operand" "1" )) ] )
  ]
""
"*
{
    if ( MOVE_RATIO_96 > INTVAL ( operands[2] ))
    {
	static int copy_len, init = 0;
	static char *copy, *buffer;
	char *cp_point;
	int i = 1;
	
	if ( ! init )
	{
	    if ( 'l' == memory_model )
	    {
		copy = \"move	l:(%1)+,%3.ml\;move	%3.ml,l:(%0)+\;\";
	    }
	    else if ( 'y' == memory_model )
	    {
		copy = \"move	y:(%1)+,%3.l\;move	%3.l,y:(%0)+\;\";
	    }
	    else
	    {
		copy = \"move	x:(%1)+,%3.l\;move	%3.l,x:(%0)+\;\";
	    }
	    copy_len = strlen ( copy );
	    buffer = malloc ( copy_len * MOVE_RATIO_96 + 3 );
	}
	buffer[0] = '\\0';

	for ( ; i <= INTVAL ( operands[2] ); ++ i )
	{
	    strcat ( buffer, copy );
	}

	return buffer;
    }
    else
    {
	operands[8] = gen_label_rtx ( );
	
	if ( 'l' != memory_model )
	{
	    RETURN_DSP ( \"do	#%c2,%l8\;move	@:(%1)+,%3.l\;move	%3.l,@:(%0)+\\n%l8\" );
	}
	else
	{
	    RETURN_DSP ( \"do	#%c2,%l8\;move	l:(%1)+,%3.ml\;move	%3.ml,l:(%0)+\\n%l8\" );
	}
    }
}" )

;;
;;  ...........................................................................
;;
;;          ADDITIONS
;;
;;  ...........................................................................
;;

( define_insn ""
  [ ( set ( match_operand:SI 0 "register_operand" "=*d,*a" )
	  ( plus:SI ( match_operand:SI 1 "register_operand" "0,0" )
		    ( match_operand:SI 2 "increment_operand" "K,K" ) ) ) ]
  ""
  "*
{
    switch ( INTVAL ( operands[2] ) )
    {

    case 1:
	return ( 0 == which_alternative )
	    ?
		\"inc	%0\"
		    :
			\"move	(%0)+\";

    case 2:
	return ( 0 == which_alternative )
	    ?
		\"inc	%0\\
		\;inc	%0\"
		    :
			\"move	(%0)+\\
			\;move	(%0)+\";

    case -1:
	return ( 0 == which_alternative )
	    ?
		\"dec	%0\"
		    :
			\"move	(%0)-\";

    case -2:
	return ( 0 == which_alternative )
	    ?
		\"dec	%0\\
		\;dec	%0\"
		    :
			\"move	(%0)-\\
			\;move	(%0)-\";

    default:
	abort ( );
    }
}" "{ TRUE }" )

( define_insn ""
  [ ( set ( match_operand:SI 0 "register_operand" "=d,??da" )
	  ( plus:SI ( match_operand:SI 1 "general_operand" "0,a" )
		    ( match_operand:SI 2 "general_operand" "d,i" )))
  ]
  ""
  "*
{
    if ( which_alternative ) 
    {
	return \"lea	(%1+%c2),%z0\";
    }
    else
    {
	return \"add	%2,%0\";
    }
}" )

( define_expand "addsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "=d,da" )
	  ( plus:SI ( match_operand:SI 1 "register_operand" "%0,a" )
		    ( match_operand:SI 2 "general_operand" "d,i" ) ) ) ]
  ""
  "
{
    emit_insn (
	       gen_rtx (
			SET,
			SImode,
			operands[0],
			gen_rtx (
				 PLUS,
				 SImode,
				 operands[1],
				 operands[2] ) ) );
    DONE;
}" )

( define_insn "adddf3"
  [ ( set ( match_operand:DF 0 "register_operand" "=f" )
	  ( plus:DF ( match_operand:DF 1 "register_operand" "0" )
		    ( match_operand:DF 2 "register_operand" "f" ) ) ) ]
  ""
  "fadd.x	%2,%0" )

( define_insn "addsf3"
  [ ( set ( match_operand:SF 0 "register_operand" "=f" )
	  ( plus:SF ( match_operand:SF 1 "register_operand" "0" )
		    ( match_operand:SF 2 "register_operand" "f" ) ) ) ]
  ""
  "fadd.s	%2,%0" )


;;
;;  ...........................................................................
;;
;;          SUBTRACTIONS
;;
;;  ...........................................................................
;;

( define_insn ""
  [ ( set ( match_operand:SI 0 "register_operand" "=d,=a" )
	  ( minus:SI ( match_operand:SI 1 "register_operand" "0,0" )
		    ( match_operand:SI 2 "increment_operand" "K,K" ) ) ) ]
  ""
  "*
{
    switch ( INTVAL ( operands[2] ) )
    {

    case 1:
	return ( 0 == which_alternative )
	    ?
		\"dec	%0\"
		    :
			\"move	(%0)-\";

    case 2:
	return ( 0 == which_alternative )
	    ?
		\"dec	%0\\
		\;dec	%0\"
		    :
			\"move	(%0)-\\
			\;move	(%0)-\";

    case -1:
	return ( 0 == which_alternative )
	    ?
		\"inc	%0\"
		    :
			\"move	(%0)+\";

    case -2:
	return ( 0 == which_alternative )
	    ?
		\"inc	%0\\
		\;inc	%0\"
		    :
			\"move	(%0)+\\
			\;move	(%0)+\";

    default:
	abort ( );
    }
}" "{ TRUE }" )

( define_insn ""
  [ ( set ( match_operand:SI 0 "register_operand" "=d,??da" )
	  ( minus:SI ( match_operand:SI 1 "general_operand" "0,a" )
		     ( match_operand:SI 2 "general_operand" "d,i" )))
  ]
  ""
  "*
{
    if ( which_alternative )
    {
	return \"lea	(%1+-%c2),%z0\";
    }
    else
    {
	return \"sub	%2,%0\";
    }
}" )

( define_expand "subsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "=d,=d=a" )
	  ( minus:SI ( match_operand:SI 1 "register_operand" "0,a" )
		     ( match_operand:SI 2 "general_operand" "d,i" ) ) ) ]
  ""
  "
{
    emit_insn (
	       gen_rtx (
			SET,
			SImode,
			operands[0],
			gen_rtx (
				 MINUS,
				 SImode,
				 operands[1],
				 operands[2] ) ) );
    DONE;
}" )

( define_insn "subdf3"
  [ ( set ( match_operand:DF 0 "register_operand" "=f" )
	  ( minus:DF ( match_operand:DF 1 "register_operand" "0" )
		     ( match_operand:DF 2 "register_operand" "f" ) ) ) ]
  ""
  "fsub.x %2,%0" )

( define_insn "subsf3"
  [ ( set ( match_operand:SF 0 "register_operand" "=f" )
	  ( minus:SF ( match_operand:SF 1 "register_operand" "0" )
		     ( match_operand:SF 2 "register_operand" "f" ) ) ) ]
  ""
  "fsub.s %2,%0" )



;;
;;  ...........................................................................
;;
;;          DIVISION & MODULUS
;;
;;  ...........................................................................
;;

;;
;;  ...........................................................................
;;
;;          MULTIPLICATIONS
;;
;;  ...........................................................................
;;

( define_expand "mulsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "=d" )
	  ( mult:SI ( match_operand:SI 1 "register_operand" "d" )
		    ( match_operand:SI 2 "register_operand" "d" )))
  ]
  ""
  "
{
    rtx final_res = operands[0];
    rtx intrm_res = gen_reg_rtx ( DImode );
    
    emit_insn ( 
	       gen_rtx ( SET, VOIDmode, intrm_res,
			gen_rtx ( SIGN_EXTEND, DImode, 
				 gen_rtx ( MULT, SImode, operands[1],
					  operands[2] ))));
    emit_insn (
	       gen_rtx ( SET, VOIDmode, final_res,
			gen_rtx ( TRUNCATE, SImode, intrm_res )));
    DONE;
}" )

( define_insn ""
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
	  ( sign_extend:DI
	    ( mult:SI ( match_operand:SI 1 "register_operand" "d" )
		      ( match_operand:SI 2 "register_operand" "d" ))))
  ]
  ""
  "mpys	%2,%1,%0" )

;; The following three insns are provided to accommodate for strength 
;; reduction in the presence of 64 bit mpy results.

( define_insn ""
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
	  ( sign_extend:DI
	    ( neg:SI ( match_operand:SI 1 "register_operand" "0" ))))
  ]
  ""
  "neg	%0" )

( define_insn "" 
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
	  ( sign_extend:DI
	    ( match_operand:SI 1 "register_operand" "0" )))
  ]
  ""
  "" )

( define_insn ""
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
	  ( sign_extend:DI
	    ( match_operand:SI 1 "immediate_operand" "i" )))
  ]
  ""
  "move	#%c1,%z0" )

( define_expand "umulsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "=d" )
	  ( umult:SI ( match_operand:SI 1 "register_operand" "d" )
		     ( match_operand:SI 2 "register_operand" "d" )))
  ]
  ""
  "
{
    rtx final_res = operands[0];
    rtx intrm_res = gen_reg_rtx ( DImode );
    
    emit_insn ( 
	       gen_rtx ( SET, VOIDmode, intrm_res,
			gen_rtx ( ZERO_EXTEND, DImode,
				 gen_rtx ( UMULT, SImode, operands[1],
					  operands[2] ))));
    emit_insn (
	       gen_rtx ( SET, VOIDmode, final_res,
			gen_rtx ( TRUNCATE, SImode, intrm_res )));
    DONE;
}" )

( define_insn ""
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
	  ( zero_extend:DI 
	    ( umult:SI ( match_operand:SI 1 "register_operand" "d" )
		       ( match_operand:SI 2 "register_operand" "d" ))))
  ]
  ""
  "mpyu	%2,%1,%0" )

;; The following three insns are provided to accommodate for strength 
;; reduction in the presence of 64 bit mpy results.

( define_insn ""
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
	  ( zero_extend:DI
	    ( neg:SI ( match_operand:SI 1 "register_operand" "0" ))))
  ]
  ""
  "neg	%0" )

( define_insn "" 
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
	  ( zero_extend:DI
	    ( match_operand:SI 1 "register_operand" "0" )))
  ]
  ""
  "" )

( define_insn ""
  [ ( set ( match_operand:DI 0 "register_operand" "=D" )
	  ( zero_extend:DI
	    ( match_operand:SI 1 "immediate_operand" "i" )))
  ]
  ""
  "move	#%c1,%z0" )

( define_insn "muldf3"
  [ ( set ( match_operand:DF 0 "register_operand" "=f" )
	  ( mult:DF ( match_operand:DF 1 "register_operand" "f" )
		    ( match_operand:DF 2 "register_operand" "f" )))
  ]
  ""
  "fmpy.x	%2,%1,%0" )

( define_insn "mulsf3"
  [ ( set ( match_operand:SF 0 "register_operand" "=f" )
	  ( mult:SF ( match_operand:SF 1 "register_operand" "f" )
		    ( match_operand:SF 2 "register_operand" "f" )))
  ]
  ""
  "fmpy.s	%2,%1,%0" )

;;
;;  ...........................................................................
;;
;;          NEGATIONS
;;
;;  ...........................................................................
;;

( define_insn "negsi2"
  [ ( set ( match_operand:SI 0 "register_operand" "=d" )
	  ( neg:SI ( match_operand:SI 1 "register_operand" "0" )))
  ]
  ""
  "neg	%0" )

( define_insn "negdf2"
  [ ( set ( match_operand:DF 0 "register_operand" "=f" )
	  ( neg:DF ( match_operand:DF 1 "register_operand" "0" )))
  ]
  ""
  "fneg.x	%0" )

( define_insn "negsf2"
  [ ( set ( match_operand:SF 0 "register_operand" "=f" )
	  ( neg:SF ( match_operand:SF 1 "register_operand" "0" )))
  ]
  ""
  "fneg.s	%0" )

;;
;;  ...........................................................................
;;
;;          ABSOLUTE VALUES
;;
;;  ...........................................................................
;;

( define_insn "abssi2"
  [ ( set ( match_operand:SI 0 "register_operand" "=d" )
	  ( abs:SI ( match_operand:SI 1 "register_operand" "0" ) ) ) ]
  ""
  "abs	%0" )


( define_insn "abssf2"
  [ ( set ( match_operand:SF 0 "register_operand" "=f" )
	  ( abs:SI ( match_operand:SF 1 "register_operand" "0" ) ) ) ]
  ""
  "fabs.s	%0" )


( define_insn "absdf2"
  [ ( set ( match_operand:DF 0 "register_operand" "=f" )
	  ( abs:SI ( match_operand:DF 1 "register_operand" "0" ) ) ) ]
  ""
  "fabs.x	%0" )


;;
;;  ...........................................................................
;;
;;          LOGICAL AND
;;
;;  ...........................................................................
;;

( define_insn "andsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "=d" )
	  ( and:SI ( match_operand:SI 1 "register_operand" "0" )
		   ( match_operand:SI 2 "register_operand" "d" ) ) ) ]
  ""
  "and	%2,%0" )

( define_insn "andcbsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "=d" )
	  ( and:SI ( match_operand:SI 1 "register_operand" "0" )
		   ( not:SI ( match_operand:SI 2 "register_operand" "d" ) ) ) ) ]
  ""
  "andc	%2,%0" )


;;
;;  ...........................................................................
;;
;;          LOGICAL INCLUSIVE OR
;;
;;  ...........................................................................
;;

( define_insn "iorsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "=d" )
	  ( ior:SI ( match_operand:SI 1 "register_operand" "0" )
		   ( match_operand:SI 2 "register_operand" "d" ) ) ) ]
  ""
  "or	%2,%0" )

( define_insn "iorcbsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "=d" )
	  ( ior:SI ( match_operand:SI 1 "register_operand" "0" )
		   ( not:SI ( match_operand:SI 2 "register_operand" "d" ) ) ) ) ]
  ""
  "orc	%2,%0" )


;;
;;  ...........................................................................
;;
;;          LOGICAL EXCLUSIVE OR
;;
;;  ...........................................................................
;;

( define_insn "xorsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "=d" )
	  ( xor:SI ( match_operand:SI 1 "register_operand" "0" )
		   ( match_operand:SI 2 "register_operand" "d" ) ) ) ]
  ""
  "eor	%2,%0" )


;;
;;  ...........................................................................
;;
;;          ONE'S COMPLEMENT
;;
;;  ...........................................................................
;;

( define_insn "one_cmplsi2"
  [ ( set ( match_operand:SI 0 "register_operand" "=d" )
	  ( not:SI ( match_operand:SI 1 "register_operand" "0" ) ) ) ]
  ""
  "not	%0" )


;;
;;  ...........................................................................
;;
;;          ARITHMATIC SHIFTS
;;
;;  ...........................................................................
;;

( define_insn "ashlsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "=d,=d,=d" )
	  ( ashift:SI ( match_operand:SI 1 "register_operand" "0,0,0" )
		      ( match_operand:SI 2 "general_operand" "J,n,h" ) ) ) ]
  ""
  "*
{
    switch ( which_alternative )
    {

    case 0:
	return \"asl	%0\";

    case 1:
	return \"asl	%2&$1f,%0\";
	
    case 2:
	return \"asl	%2.h,%0\";
    }
}" )

( define_insn "ashrsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "=d,=d,=d" )
	  ( ashiftrt:SI ( match_operand:SI 1 "register_operand" "0,0,0" )
			( match_operand:SI 2 "general_operand" "J,n,h" ) ) ) ]
  ""
  "*
{
    switch ( which_alternative )
    {

    case 0:
	return \"asr	%0\";

    case 1:
	return \"asr	%2&$1f,%0\";
	
    case 2:
	return \"asr	%2.h,%0\";
    }
}" )


;;
;;  ...........................................................................
;;
;;          LOGICAL SHIFTS
;;
;;  ...........................................................................
;;

( define_insn "lshlsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "=d,=d,=d" )
	  ( lshift:SI ( match_operand:SI 1 "register_operand" "0,0,0" )
			( match_operand:SI 2 "general_operand" "J,n,h" ) ) ) ]
  ""
  "*
{
    switch ( which_alternative )
    {

    case 0:
	return \"lsl	%0\";

    case 1:
	return \"lsl	%2&$1f,%0\";
	
    case 2:
	return \"lsl	%2.h,%0\";
    }
}" )


( define_insn "lshrsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "=d,=d,=d" )
	  ( lshiftrt:SI ( match_operand:SI 1 "register_operand" "0,0,0" )
			( match_operand:SI 2 "general_operand" "J,n,h" ) ) ) ]
  ""
  "*
{
    switch ( which_alternative )
    {

    case 0:
	return \"lsr	%0\";

    case 1:
	return \"lsr	%2&$1f,%0\";
	
    case 2:
	return \"lsr	%2.h,%0\";
    }
}" )


;;
;;  ...........................................................................
;;
;;          ROTATIONS
;;
;;  ...........................................................................
;;

( define_insn "rotlsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "=d" )
	  ( rotate:SI ( match_operand:SI 1 "register_operand" "0" )
		      ( match_operand:SI 2 "general_operand" "J" ) ) ) ]
  ""
  "rol	%0" )

( define_insn "rotrsi3"
  [ ( set ( match_operand:SI 0 "register_operand" "=d" )
	  ( rotatert:SI ( match_operand:SI 1 "register_operand" "0" )
			( match_operand:SI 2 "general_operand" "J" ) ) ) ]
  ""
  "ror	%0" )

;;
;;  ...........................................................................
;;
;;          COMPARISONS
;;
;;  ...........................................................................
;;

( define_insn "cmpsi"
  [ ( set ( cc0 )
	  ( compare ( match_operand:SI 0 "register_operand" "d" )
		    ( match_operand:SI 1 "register_operand" "d" ) ) ) ]
  ""
  "*
{
    cc_status.mdep = INTEGER_CCS;

    return \"cmp	%1,%0\";
}" )

( define_insn "cmpdf"
  [ ( set ( cc0 )
	  ( compare ( match_operand:DF 0 "register_operand" "f" )
		    ( match_operand:DF 1 "register_operand" "f" ) ) ) ]
  ""
  "*
{
    cc_status.mdep = FLOAT_CCS;
    
    return \"fcmp	%1,%0\";
}" )

( define_insn "cmpsf"
  [ ( set ( cc0 )
	  ( compare ( match_operand:SF 0 "register_operand" "f" )
		    ( match_operand:SF 1 "register_operand" "f" ) ) ) ]
  ""
  "*
{
    cc_status.mdep = FLOAT_CCS;
    
    return \"fcmp	%1,%0\";
}" )

;;
;;  ...........................................................................
;;
;;          TESTS
;;
;;  ...........................................................................
;;

( define_insn "tstsi"
  [ ( set ( cc0 )
	  ( match_operand:SI 0 "register_operand" "d,a" ) ) ]
  ""
  "*
{
    return ( 0 == which_alternative )
	?
	    \"tst	%0\"
		:
		    \"moveta	(%0)\";
}" )

( define_insn "tstdf"
  [ ( set ( cc0 )
	  ( match_operand:DF 0 "register_operand" "f" ) ) ]
  ""
  "ftst	%0" )

( define_insn "tstsf"
  [ ( set ( cc0 )
	  ( match_operand:SF 0 "register_operand" "f" ) ) ]
  ""
  "ftst	%0" )


;;
;;  ...........................................................................
;;
;;          SCALAR CONVERSIONS USING TRUNCATION
;;
;;  ...........................................................................
;;

( define_insn "truncsiqi2"
  [ ( set ( match_operand:QI 0 "register_operand" "=d" )
	  ( truncate:QI ( match_operand:SI 1 "register_operand" "d" )))
  ]
  ""
  "*
{
    if ( operands[0] == operands[1] )
    {
	return \"\";
    }
    else
    {
	return \"tfr	%1,%0\";
    }
}" )

( define_insn "trunchiqi2"
  [ ( set ( match_operand:QI 0 "register_operand" "=d" )
	  ( truncate:QI ( match_operand:HI 1 "register_operand" "d" )))
  ]
  ""
  "*
{
    if ( operands[0] == operands[1] )
    {
	return \"\";
    }
    else
    {
	return \"tfr	%1,%0\";
    }
}" )

( define_insn "truncsihi2"
  [ ( set ( match_operand:HI 0 "register_operand" "=d" )
	  ( truncate:HI ( match_operand:SI 1 "register_operand" "d" ))) 
  ]
  ""
  "*
{
    if ( operands[0] == operands[1] )
    {
	return \"\";
    }
    else
    {
	return \"tfr	%1,%0\";
    }
}" )

( define_insn "truncdisi2"
  [ ( set ( match_operand:SI 0 "register_operand" "=d" )
	  ( truncate:SI ( match_operand:DI 1 "register_operand" "D" ))) 
  ]
  ""
  "*
{
    if ( REGNO ( operands[0] ) == REGNO ( operands[1] ))
    {
	return \"\";
    }
    else
    {
	return \"tfr	%1,%0\";
    }
}" )

;;
;;  ...........................................................................
;;
;;          SCALAR CONVERSIONS USING ZERO EXTENSION
;;
;;  ...........................................................................
;;

( define_insn "zero_extendhisi2"
  [ ( set ( match_operand:SI 0 "register_operand" "=d" )
	  ( zero_extend:SI ( match_operand:HI 1 "register_operand" "d" )))
  ]
  ""
  "*
{
    if ( operands[0] == operands[1] )
    {
	return \"\";
    }
    else
    {
	return \"tfr	%1,%0\";
    }
}" )

( define_insn "zero_extendqihi2"
  [ ( set ( match_operand:HI 0 "register_operand" "=d" )
	  ( zero_extend:HI ( match_operand:QI 1 "register_operand" "d" )))
  ]
  ""
  "*
{
    if ( operands[0] == operands[1] )
    {
	return \"\";
    }
    else
    {
	return \"tfr	%1,%0\";
    }
}" )

( define_insn "zero_extendqisi2"
  [ ( set ( match_operand:SI 0 "register_operand" "=d" )
	  ( zero_extend:SI ( match_operand:QI 1 "register_operand" "d" ))) 
  ]
  ""
  "*
{
    if ( operands[0] == operands[1] )
    {
	return \"\";
    }
    else
    {
	return \"tfr	%1,%0\";
    }
}" )

( define_insn "zero_extendsidi2"
  [ ( set ( match_operand:DI 0 "register_operand" "=D,D" )
	  ( zero_extend:DI ( match_operand:SI 1 "general_operand" "d,i" ))) 
  ]
  ""
  "*
{
    if ( which_alternative )
    {
	return \"move	#%c1,%0\";
    }

    if ( REGNO ( operands[0] ) == REGNO ( operands[1] ))
    {
	return \"\";
    }
    else
    {
	return \"tfr	%1,%0\";
    }
}" )

;;
;;  ...........................................................................
;;
;;          SCALAR CONVERSIONS USING SIGN EXTENSION
;;
;;  ...........................................................................
;;

( define_insn "extendhisi2"
  [ ( set ( match_operand:SI 0 "register_operand" "=d" )
	  ( sign_extend:SI ( match_operand:HI 1 "register_operand" "d" )))
  ]
  ""
  "*
{
    if ( operands[0] == operands[1] )
    {
	return \"\";
    }
    else
    {
	return \"tfr	%1,%0\";
    }
}" )

( define_insn "extendqihi2"
  [ ( set ( match_operand:HI 0 "register_operand" "=d" )
	  ( sign_extend:HI ( match_operand:QI 1 "register_operand" "d" )))
  ]
  ""
  "*
{
    if ( operands[0] == operands[1] )
    {
	return \"\";
    }
    else
    {
	return \"tfr	%1,%0\";
    }
}" )

( define_insn "extendqisi2"
  [ ( set ( match_operand:SI 0 "register_operand" "=d" )
	  ( sign_extend:SI ( match_operand:QI 1 "register_operand" "d" )))
  ]
  ""
  "*
{
    if ( operands[0] == operands[1] )
    {
	return \"\";
    }
    else
    {
	return \"tfr	%1,%0\";
    }
}" )

( define_insn "extendsidi2"
  [ ( set ( match_operand:DI 0 "register_operand" "=D,D" )
	  ( sign_extend:DI ( match_operand:SI 1 "general_operand" "d,i" )))
  ]
  ""
  "*
{
    if ( which_alternative )
    {
	return \"move	#%c1,%0\";
    }

    if ( REGNO ( operands[0] ) == REGNO ( operands[1] ))
    {
	return \"\";
    }
    else
    {
	return \"tfr	%1,%0\";
    }
}" )

;;
;;  ...........................................................................
;;
;;          CONVERSIONS BETWEEN FLOAT AND DOUBLE
;;
;;  ...........................................................................
;;

( define_insn "extendsfdf2"
  [ ( set ( match_operand:DF 0 "register_operand" "=f" )
	  ( float_extend:DF ( match_operand:SF 1 "register_operand" "f" )))
  ]
  ""
  "ftfr.x	%1,%0" )

( define_insn "truncdfsf2"
  [ ( set ( match_operand:SF 0 "register_operand" "=f" )
	  ( float_truncate:SF ( match_operand:DF 1 "register_operand" "f" )))
  ]
  ""
  "ftfr.s	%1,%0" )

;;
;;  ...........................................................................
;;
;;          CONVERSIONS BETWEEN FLOATING POINT AND INTEGER
;;
;;  ...........................................................................
;;

( define_insn "floatunssidf2"
  [ ( set ( match_operand:DF 0 "register_operand" "=f" )
	  ( unsigned_float:DF 
	    ( match_operand:SI 1 "register_operand" "0" )))
  ]
  ""
  "floatu.x	%0" )

( define_insn "floatunssisf2"
  [ ( set ( match_operand:SF 0 "register_operand" "=f" )
	  ( unsigned_float:SF 
	    ( match_operand:SI 1 "register_operand" "0" )))
  ]
  ""
  "floatu.s	%0" )

( define_insn "floatsidf2"
  [ ( set ( match_operand:DF 0 "register_operand" "=f" )
	  ( float:DF 
	    ( match_operand:SI 1 "register_operand" "0" )))
  ]
  ""
  "float.x	%0" )

( define_insn "floatsisf2"
  [ ( set ( match_operand:SF 0 "register_operand" "=f" )
	  ( float:SF 
	    ( match_operand:SI 1 "register_operand" "0" )))
  ]
  ""
  "float.s	%0" )

( define_insn "fixdfsi2"
  [ ( set ( match_operand:SI 0 "register_operand" "=d" )
	  ( fix:SI 
	    ( match_operand:DF 1 "register_operand" "=f" )))
  ]
  ""
  "*
{
    if ( REGNO ( operands[0] ) == REGNO ( operands[1] ))
    {
	return \"intrz	%0\";
    }
    else
    {
	return \"intrz	%1\;tfr	%1,%0\";
    }
}" )

( define_insn "fixsfsi2"
  [ ( set ( match_operand:SI 0 "register_operand" "=d" )
	  ( fix:SI 
	    ( match_operand:SF 1 "register_operand" "=f" )))
  ]
  ""
  "*
{
    if ( REGNO ( operands[0] ) == REGNO ( operands[1] ))
    {
	return \"intrz	%0\";
    }
    else
    {
	return \"intrz	%1\;tfr	%1,%0\";
    }
}" )

( define_insn "fixunsdfsi2"
  [ ( set ( match_operand:SI 0 "register_operand" "=d" )
	  ( unsigned_fix:SI 
	    ( match_operand:DF 1 "register_operand" "=f" )))
  ]
  ""
  "*
{
    if ( REGNO ( operands[0] ) == REGNO ( operands[1] ))
    {
	return \"inturz	%0\";
    }
    else
    {
	return \"inturz	%1\;tfr	%1,%0\";
    }
}" )

( define_insn "fixunssfsi2"
  [ ( set ( match_operand:SI 0 "register_operand" "=d" )
	  ( unsigned_fix:SI 
	    ( match_operand:SF 1 "register_operand" "=f" )))
  ]
  ""
  "*
{
    if ( REGNO ( operands[0] ) == REGNO ( operands[1] ))
    {
	return \"inturz	%0\";
    }
    else
    {
	return \"inturz	%1\;tfr	%1,%0\";
    }
}" )

( define_insn "ftruncdf2"
  [ ( set ( match_operand:DF 0 "register_operand" "=f" )
	  ( float_truncate:DF 
	    ( match_operand:DF 1 "register_operand" "0" )))
  ]
  ""
  "fint	%0" )

( define_insn "ftruncsf2"
  [ ( set ( match_operand:SF 0 "register_operand" "=f" )
	  ( float_truncate:SF 
	    ( match_operand:SF 1 "register_operand" "0" )))
  ]
  ""
  "fint	%0" )

( define_expand "fix_truncdfsi2"
  [ ( set ( match_operand:SI 0 "register_operand" "=d" )
	  ( fix:SI 
	    ( match_operand:DF 1 "register_operand" "0" )))
  ]
  ""
  "" )

( define_expand "fix_truncsfsi2"
  [ ( set ( match_operand:SI 0 "register_operand" "=d" )
	  ( fix:SI 
	    ( match_operand:SF 1 "register_operand" "0" )))
  ]
  ""
  "" )

( define_expand "fixuns_truncdfsi2"
  [ ( set ( match_operand:SI 0 "register_operand" "=d" )
	  ( unsigned_fix:SI 
	    ( match_operand:DF 1 "register_operand" "0" )))
  ]
  ""
  "" )

( define_expand "fixuns_truncsfsi2"
  [ ( set ( match_operand:SI 0 "register_operand" "=d" )
	  ( unsigned_fix:SI 
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

;; This shape should match the do loop shape. 

( define_insn "do"
  [ ( parallel
      [ ( clobber ( cc0 ))
	( use ( match_operand:SI 0 "general_operand" "d,L" ))
	( set ( pc ) ( if_then_else ( eq ( cc0 ) ( const_int 0 ))
				    ( label_ref ( match_operand 1 "" "" ))
				    ( pc )))
      ] )
  ]
  ""
  "*
{
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
    record_address_regs_used ( scan );

    if ( which_alternative )
    {
	if ( 0xfff00000 & INTVAL ( operands[0] ))
	{
	    return \"move	#%c0,d8.l\;do	d8.l,%l1\";
	}
	else
	{
	    return \"do	#%c0,%l1\";
	}
    }
    else
    {
	return \"do	%z0,%l1\";
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
	if ( conflicting_address_regs_set_p ( scan ))
	{
	    return \"nop\";
	}
    }
    return \"\";
}" )

( define_insn "beq"
  [ ( set ( pc )
	  ( if_then_else ( eq ( cc0 )
			      ( const_int 0 ) )
			 ( label_ref ( match_operand 0 "" "" ) )
			 ( pc ) ) ) ]
  ""
  "*
{
    if ( FLOAT_CCS == cc_prev_status.mdep )
    {
	return \"fjeq	%l0\";
    }
    return \"jeq	%l0\";
}" )

( define_insn "bne"
  [ ( set ( pc )
	  ( if_then_else ( ne ( cc0 )
			      ( const_int 0 ) )
			 ( label_ref ( match_operand 0 "" "" ) )
			 ( pc ) ) ) ]
  ""
  "*
{
    if ( FLOAT_CCS == cc_prev_status.mdep )
    {
	return \"fjne	%l0\";
    }
    return \"jne	%l0\";
}" )

( define_insn "bgt"
  [ ( set ( pc )
	  ( if_then_else ( gt ( cc0 )
			      ( const_int 0 ) )
			 ( label_ref ( match_operand 0 "" "" ) )
			 ( pc ) ) ) ]
  ""
  "*
{
    if ( FLOAT_CCS == cc_prev_status.mdep )
    {
	return \"fjgt	%l0\";
    }
    return \"jgt	%l0\";
}" )

( define_insn "bgtu"
  [ ( set ( pc )
	  ( if_then_else ( gtu ( cc0 )
			       ( const_int 0 ) )
			 ( label_ref ( match_operand 0 "" "" ) )
			 ( pc ) ) ) ]
  ""
  "*
{
    if ( COMPARE != GET_CODE ( cc_prev_status.value2 ))
    {
	return \"jne	%l0\";
    }
    else
    {
	return \"jhi	%l0\";
    }
}" )

( define_insn "blt"
  [ ( set ( pc )
	  ( if_then_else ( lt ( cc0 )
			      ( const_int 0 ) )
			 ( label_ref ( match_operand 0 "" "" ) )
			 ( pc ) ) ) ]
  ""
  "*
{
    if ( FLOAT_CCS == cc_prev_status.mdep )
    {
	return \"fjlt	%l0\";
    }
    return \"jlt	%l0\";
}" )

( define_insn "bltu"
  [ ( set ( pc )
	  ( if_then_else ( ltu ( cc0 )
			       ( const_int 0 ) )
			 ( label_ref ( match_operand 0 "" "" ) )
			 ( pc ) ) ) ]
  ""
  "*
{
    if ( COMPARE != GET_CODE ( cc_prev_status.value2 ))
    {
	return \"\";
    }
    else
    {
	return \"jlo	%l0\";
    }
}" )

( define_insn "bge"
  [ ( set ( pc )
	  ( if_then_else ( ge ( cc0 )
			      ( const_int 0 ) )
			 ( label_ref ( match_operand 0 "" "" ) )
			 ( pc ) ) ) ]
  ""
  "*
{
    if ( FLOAT_CCS == cc_prev_status.mdep )
    {
	return \"fjge	%l0\";
    }
    return \"jge	%l0\";
}" )

( define_insn "bgeu"
  [ ( set ( pc )
	  ( if_then_else ( geu ( cc0 )
			       ( const_int 0 ) )
			 ( label_ref ( match_operand 0 "" "" ) )
			 ( pc ) ) ) ]
  ""
  "*
{
    if ( COMPARE != GET_CODE ( cc_prev_status.value2 ))
    {
	return \"jmp	%l0\";
    }
    else
    {
	return \"jhs	%l0\";
    }
}")

( define_insn "ble"
  [ ( set ( pc )
	  ( if_then_else ( le ( cc0 )
			      ( const_int 0 ) )
			 ( label_ref ( match_operand 0 "" "" ) )
			 ( pc ) ) ) ]
  ""
  "*
{
    if ( FLOAT_CCS == cc_prev_status.mdep )
    {
	return \"fjle	%l0\";
    }
    return \"jle	%l0\";
}" )

( define_insn "bleu"
  [ ( set ( pc )
	  ( if_then_else ( leu ( cc0 )
			       ( const_int 0 ) )
			 ( label_ref ( match_operand 0 "" "" ) )
			 ( pc ) ) ) ]
  ""
  "*
{
    if ( COMPARE != GET_CODE ( cc_prev_status.value2 ))
    {
	return \"jeq	%l0\";
    }
    else
    {
	return \"jls	%l0\";
    }
}")


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
  "*
{
    if ( FLOAT_CCS == cc_prev_status.mdep )
    {
	return \"fjne	%l0\";
    }
    return \"jne	%l0\";
}" )

( define_insn ""
  [ ( set ( pc )
	  ( if_then_else ( ne ( cc0 )
			      ( const_int 0 ) )
			 ( pc )
			 ( label_ref ( match_operand 0 "" "" ) ) ) ) ]
  ""
  "*
{
    if ( FLOAT_CCS == cc_prev_status.mdep )
    {
	return \"fjeq	%l0\";
    }
    return \"jeq	%l0\";
}" )

( define_insn ""
  [ ( set ( pc )
	  ( if_then_else ( gt ( cc0 )
			      ( const_int 0 ) )
			 ( pc )
			 ( label_ref ( match_operand 0 "" "" ) ) ) ) ]
  ""
  "*
{
    if ( FLOAT_CCS == cc_prev_status.mdep )
    {
	return \"fjle	%l0\";
    }
    return \"jle	%l0\";
}" )

( define_insn ""
  [ ( set ( pc )
	  ( if_then_else ( gtu ( cc0 )
			       ( const_int 0 ) )
			 ( pc )
			 ( label_ref ( match_operand 0 "" "" ) ) ) ) ]
  ""
  "*
{
    if ( COMPARE != GET_CODE ( cc_prev_status.value2 ))
    {
	return \"jeq	%l0\";
    }
    else
    {
	return \"jls	%l0\";
    }
}")

( define_insn ""
  [ ( set ( pc )
	  ( if_then_else ( lt ( cc0 )
			      ( const_int 0 ) )
			 ( pc )
			 ( label_ref ( match_operand 0 "" "" ) ) ) ) ]
  ""
  "*
{
    if ( FLOAT_CCS == cc_prev_status.mdep )
    {
	return \"fjge	%l0\";
    }
    return \"jge	%l0\";
}" )

( define_insn ""
  [ ( set ( pc )
	  ( if_then_else ( ltu ( cc0 )
			       ( const_int 0 ) )
			 ( pc )
			 ( label_ref ( match_operand 0 "" "" ) ) ) ) ]
  ""
  "*
{
    if ( COMPARE != GET_CODE ( cc_prev_status.value2 ))
    {
	return \"jmp	%l0\";
    }
    else
    {
	return \"jhs	%l0\";
    }
}")

( define_insn ""
  [ ( set ( pc )
	  ( if_then_else ( ge ( cc0 )
			      ( const_int 0 ) )
			 ( pc )
			 ( label_ref ( match_operand 0 "" "" ) ) ) ) ]
  ""
  "*
{
    if ( FLOAT_CCS == cc_prev_status.mdep )
    {
	return \"fjlt	%l0\";
    }
    return \"jlt	%l0\";
}" )

( define_insn ""
  [ ( set ( pc )
	  ( if_then_else ( geu ( cc0 )
			       ( const_int 0 ) )
			 ( pc )
			 ( label_ref ( match_operand 0 "" "" ) ) ) ) ]
  ""
  "*
{
    if ( COMPARE != GET_CODE ( cc_prev_status.value2 ))
    {
	return \"\";
    }
    else
    {
	return \"jlo	%l0\";
    }
}" )

( define_insn ""
  [ ( set ( pc )
	  ( if_then_else ( le ( cc0 )
			      ( const_int 0 ) )
			 ( pc )
			 ( label_ref ( match_operand 0 "" "" ) ) ) ) ]
  ""
  "*
{
    if ( FLOAT_CCS == cc_prev_status.mdep )
    {
	return \"fjgt	%l0\";
    }
    return \"jgt	%l0\";
}" )

( define_insn ""
  [ ( set ( pc )
	  ( if_then_else ( leu ( cc0 )
			       ( const_int 0 ) )
			 ( pc )
			 ( label_ref ( match_operand 0 "" "" ) ) ) ) ]
  ""
  "*
{
    if ( COMPARE != GET_CODE ( cc_prev_status.value2 ))
    {
	return \"jne	%l0\";
    }
    else
    {
	return \"jhi	%l0\";
    }
}")

;;
;;  ...........................................................................
;;
;;          CONDITIONALY STORE ZERO OR NON-ZERO
;;
;;  ...........................................................................
;;

( define_insn "seq"
  [ ( set ( match_operand:SI 0 "general_operand" "=d" )
	  ( eq ( cc0 ) ( const_int 0 ))) 
  ]
  ""
  "*
{
    if ( COMPARE != GET_CODE ( cc_prev_status.value2 ))
    {
	if (( DFmode == GET_MODE ( cc_prev_status.value2 )) ||
	    ( SFmode == GET_MODE ( cc_prev_status.value2 )))
	{
	    return \"move	#0,%z0\;inc	%0	ffeq\";
	}
    }
    else
    {
	if (( DFmode == GET_MODE ( XEXP ( cc_prev_status.value2, 0 ))) ||
	    ( SFmode == GET_MODE ( XEXP ( cc_prev_status.value2, 0 ))))
	{
	    return \"move	#0,%z0\;inc	%0	ffeq\";
	}
    }
    return \"move	#0,%z0\;inc	%0	ifeq\";
}" )

( define_insn "sne"
  [ ( set ( match_operand:SI 0 "general_operand" "=d" )
	  ( ne ( cc0 ) ( const_int 0 )))
  ]
  ""
  "*
{
    if ( COMPARE != GET_CODE ( cc_prev_status.value2 ))
    {
	if (( DFmode == GET_MODE ( cc_prev_status.value2 )) ||
	    ( SFmode == GET_MODE ( cc_prev_status.value2 )))
	{
	    return \"move	#0,%z0\;inc	%0	ffne\";
	}
    }
    else
    {
	if (( DFmode == GET_MODE ( XEXP ( cc_prev_status.value2, 0 ))) ||
	    ( SFmode == GET_MODE ( XEXP ( cc_prev_status.value2, 0 ))))
	{
	    return \"move	#0,%z0\;inc	%0	ffne\";
	}
    }
    return \"move	#0,%z0\;inc	%0	ifne\";
}" )

( define_insn "sgt"
  [ ( set ( match_operand:SI 0 "general_operand" "=d" )
	  ( gt ( cc0 ) ( const_int 0 ))) 
  ]
  ""
  "*
{
    if ( COMPARE != GET_CODE ( cc_prev_status.value2 ))
    {
	if (( DFmode == GET_MODE ( cc_prev_status.value2 )) ||
	    ( SFmode == GET_MODE ( cc_prev_status.value2 )))
	{
	    return \"move	#0,%z0\;inc	%0	ffgt\";
	}
    }
    else
    {
	if (( DFmode == GET_MODE ( XEXP ( cc_prev_status.value2, 0 ))) ||
	    ( SFmode == GET_MODE ( XEXP ( cc_prev_status.value2, 0 ))))
	{
	    return \"move	#0,%z0\;inc	%0	ffgt\";
	}
    }
    return \"move	#0,%z0\;inc	%0	ifgt\";
}" )

( define_insn "sgtu"
  [ ( set ( match_operand:SI 0 "general_operand" "=d" )
	  ( gtu ( cc0 ) ( const_int 0 ))) 
  ]
  ""
  "*
{
    if ( COMPARE != GET_CODE ( cc_prev_status.value2 ))
    {
	if (( DFmode == GET_MODE ( cc_prev_status.value2 )) ||
	    ( SFmode == GET_MODE ( cc_prev_status.value2 )))
	{
	    return \"move	#0,%z0\;inc	%0	ffne\";
	}
	else
	{
	    return \"move	#0,%z0\;inc	%0	ifne\";
	}
    }
    else
    {
	if (( DFmode == GET_MODE ( XEXP ( cc_prev_status.value2, 0 ))) ||
	    ( SFmode == GET_MODE ( XEXP ( cc_prev_status.value2, 0 ))))
	{
	    return \"move	#0,%z0\;inc	%0	ffhi\";
	}
    }
    return \"move	#0,%z0\;inc	%0	ifhi\";
}" )

( define_insn "slt"
  [ ( set ( match_operand:SI 0 "general_operand" "=d" )
	  ( lt ( cc0 ) ( const_int 0 ))) 
  ]
  ""
  "*
{
    if ( COMPARE != GET_CODE ( cc_prev_status.value2 ))
    {
	if (( DFmode == GET_MODE ( cc_prev_status.value2 )) ||
	    ( SFmode == GET_MODE ( cc_prev_status.value2 )))
	{
	    return \"move	#0,%z0\;inc	%0	fflt\";
	}
    }
    else
    {
	if (( DFmode == GET_MODE ( XEXP ( cc_prev_status.value2, 0 ))) ||
	    ( SFmode == GET_MODE ( XEXP ( cc_prev_status.value2, 0 ))))
	{
	    return \"move	#0,%z0\;inc	%0	fflt\";
	}
    }
    return \"move	#0,%z0\;inc	%0	iflt\";
}" )

( define_insn "sltu"
  [ ( set ( match_operand:SI 0 "general_operand" "=d" )
	  ( ltu ( cc0 ) ( const_int 0 ))) 
  ]
  ""
  "*
{
    if ( COMPARE != GET_CODE ( cc_prev_status.value2 ))
    {
	return \"move	#0,%z0\";
    }
    else
    {
	if (( DFmode == GET_MODE ( XEXP ( cc_prev_status.value2, 0 ))) ||
	    ( SFmode == GET_MODE ( XEXP ( cc_prev_status.value2, 0 ))))
	{
	    return \"move	#0,%z0\;inc	%0	fflo\";
	}
    }
    return \"move	#0,%z0\;inc	%0	iflo\";
}" )

( define_insn "sge"
  [ ( set ( match_operand:SI 0 "general_operand" "=d" )
	  ( ge ( cc0 ) ( const_int 0 ))) 
  ]
  ""
  "*
{
    if ( COMPARE != GET_CODE ( cc_prev_status.value2 ))
    {
	if (( DFmode == GET_MODE ( cc_prev_status.value2 )) ||
	    ( SFmode == GET_MODE ( cc_prev_status.value2 )))
	{
	    return \"move	#0,%z0\;inc	%0	ffge\";
	}
    }
    else
    {
	if (( DFmode == GET_MODE ( XEXP ( cc_prev_status.value2, 0 ))) ||
	    ( SFmode == GET_MODE ( XEXP ( cc_prev_status.value2, 0 ))))
	{
	    return \"move	#0,%z0\;inc	%0	ffge\";
	}
    }
    return \"move	#0,%z0\;inc	%0	ifge\";
}" )

( define_insn "sgeu"
  [ ( set ( match_operand:SI 0 "general_operand" "=d" )
	  ( geu ( cc0 ) ( const_int 0 ))) 
  ]
  ""
  "*
{
    if ( COMPARE != GET_CODE ( cc_prev_status.value2 ))
    {
	return \"move	#1,%z0\";
    }
    else
    {
	if (( DFmode == GET_MODE ( XEXP ( cc_prev_status.value2, 0 ))) ||
	    ( SFmode == GET_MODE ( XEXP ( cc_prev_status.value2, 0 ))))
	{
	    return \"move	#0,%z0\;inc	%0	ffhs\";
	}
    }
    return \"move	#0,%z0\;inc	%0	ifhs\";
}" )

( define_insn "sle"
  [ ( set ( match_operand:SI 0 "general_operand" "=d" )
	  ( le ( cc0 ) ( const_int 0 ))) 
  ]
  ""
  "*
{
    if ( COMPARE != GET_CODE ( cc_prev_status.value2 ))
    {
	if (( DFmode == GET_MODE ( cc_prev_status.value2 )) ||
	    ( SFmode == GET_MODE ( cc_prev_status.value2 )))
	{
	    return \"move	#0,%z0\;inc	%0	ffle\";
	}
    }
    else
    {
	if (( DFmode == GET_MODE ( XEXP ( cc_prev_status.value2, 0 ))) ||
	    ( SFmode == GET_MODE ( XEXP ( cc_prev_status.value2, 0 ))))
	{
	    return \"move	#0,%z0\;inc	%0	ffle\";
	}
    }
    return \"move	#0,%z0\;inc	%0	ifle\";
}" )

( define_insn "sleu"
  [ ( set ( match_operand:SI 0 "general_operand" "=d" )
	  ( leu ( cc0 ) ( const_int 0 ))) 
  ]
  ""
  "*
{
    if ( COMPARE != GET_CODE ( cc_prev_status.value2 ))
    {
	if (( DFmode == GET_MODE ( cc_prev_status.value2 )) ||
	    ( SFmode == GET_MODE ( cc_prev_status.value2 )))
	{
	    return \"move	#0,%z0\;inc	%0	ffeq\";
	}
	else
	{
	    return \"move	#0,%z0\;inc	%0	ifeq\";
	}
    }
    else
    {
	if (( DFmode == GET_MODE ( XEXP ( cc_prev_status.value2, 0 ))) ||
	    ( SFmode == GET_MODE ( XEXP ( cc_prev_status.value2, 0 ))))
	{
	    return \"move	#0,%z0\;inc	%0	ffls\";
	}
    }
    return \"move	#0,%z0\;inc	%0	ifls\";
}" )

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
  "jmp	(%l0)" )


;;
;;  ...........................................................................
;;
;;          TABLE JUMP ( SWITCH IMPLEMENTATION )
;;
;;  ...........................................................................
;;

( define_insn "tablejump"
  [ ( set ( pc ) ( match_operand:SI 0 "register_operand" "a" ) )
    ( use ( label_ref ( match_operand 1 "" "" ) ) ) ]
  ""
  "jmp (%0)" )


;;
;;  ...........................................................................
;;
;;          SUBROUTINE CALLS
;;
;;  ...........................................................................
;;

( define_insn "call"
  [ ( call ( match_operand:SI 0 "general_operand" "<>ma" )
	   ( match_operand:SI 1 "immediate_operand" "i" )) 
  ]
  ""
  "*
{
    CC_STATUS_INIT;

    switch ( INTVAL ( operands[1] ))
    {
    case 0:
	return \"jsr	%0\";

    case 1:
	return \"jsr	%0\;move	(r6)-\";
	
    case 2:
	return \"jsr	%0\;move	(r6)-\;move	(r6)-\";
	
    default:
	return \"jsr	%0\;move	#%c1,n6\;move	(r6)-n6\";
    }
}" )

( define_insn "call_value"
  [ ( set ( match_operand 0 "" "" )
	  ( call ( match_operand:SI 1 "general_operand" "<>ma" )
		 ( match_operand:SI 2 "immediate_operand" "i" )))
  ]
  ""
  "*
{
    switch ( INTVAL ( operands[2] ))
    {
    case 0:
	return \"jsr	%1\";
	
    case 1:
	return \"jsr	%1\;move	(r6)-\";
	
    case 2:
	return \"jsr	%1\;move	(r6)-\;move	(r6)-\";
	
    default:
	return \"jsr	%1\;move	#%c2,n6\;move	(r6)-n6\";
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

;;
;;  ...........................................................................
;;
;;          PEEPHOLE OPTIMIZATIONS
;;
;;  ...........................................................................
;;

;;- Local variables:
;;- mode:emacs-lisp
;;- comment-start: ";;- "
;;- eval: ( set-syntax-table ( copy-sequence ( syntax-table ) ) )
;;- eval: ( modify-syntax-entry ?[ "(]" )
;;- eval: ( modify-syntax-entry ?] ")[" )
;;- eval: ( modify-syntax-entry ?{ "(}" )
;;- eval: ( modify-syntax-entry ?} "){" )
;;- End:

