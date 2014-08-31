;
; Copyright 1990-2006 Alexandre Lemaresquier, Raphael Lemoine
;                     Laurent Chemla (Serial support), Daniel Verite (AmigaOS support)
;
; This file is part of Adebug.
;
; Adebug is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; Adebug is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with Adebug; if not, write to the Free Software
; Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
;

Compile			equ	0
STACK_SECURITY	equ	4*1024
;  #[ REMs + EQUates:
;
; Evaluateur 128 bits (format entier) pour ADEBUG version 68xxx.
;
; Operateurs geres:
; ( ) { } [ ] ?: + - * / & | ^ << >> < > <= >= != == =
; X++ X-- ++X --X += -= *= /= ~= ^= <<= >>= &= |= && ||
; SOB, EOB, LOB, LPREV, LNEXT, MOD, WATCH, WHILE, SVAR
;
; Format des TOKENS:
;
; operateur:	1.w numero de l'operateur
;		1.w #ID
;
; operande:	4.l valeur
;		1.l pointeur d'indirection
;		1.l flags divers
;			7 bits: extensions futures
;			1 bit:	heritage du format du fils
;			1 bit:	toujours 0 ( -> resultat positif )
;			7 bits:	formats autorises
;			4 bits:	preinc, postinc, predec, postdec
;			1 bit:	flag de 'string'
;			3 bits:	format (0=byte, 1=word, 2=long, 3=single
;				4=double, 5=extended, 6=packed)
;				size (byte=1 word=2 long=4 single=4
;				double=8, extended=12 packed=12)
;			8 bits:	format du nombre (0=rien, +=registre
;				-1=memory, -2=variable -3=routine)
;
; formats par defaut:
;
Default_BYTE		equ	0
Default_WORD		equ	1
Default_LONG		equ	2
Default_SINGLE		equ	3
Default_DOUBLE		equ	4
Default_EXTENDED	equ	5
Default_PACKED		equ	6
;
; bits de formats autorises et valeurs de formats:
;
Eval_BYTE		equ	1
Eval_WORD		equ	2
Eval_LONG		equ	4
Eval_SINGLE		equ	8
Eval_DOUBLE		equ	$10
Eval_EXTENDED		equ	$20
Eval_PACKED		equ	$40
;
; #ID des registres reconnus
;
_D0			equ	1
_D1			equ	2
_D2			equ	3
_D3			equ	4
_D4			equ	5
_D5			equ	6
_D6			equ	7
_D7			equ	8
_A0			equ	9
_A1			equ	10
_A2			equ	11
_A3			equ	12
_A4			equ	13
_A5			equ	14
_A6			equ	15
_A7			equ	16
_VBR			equ	17
_ISP			equ	18
_MSP			equ	19
_SSP			equ	20
_SP			equ	21
_SR			equ	22
_PC			equ	23
_CCR			equ	24
_CACR			equ	25
_CAAR			equ	26
_SFC			equ	27
_DFC			equ	28
_TC			equ	29
_CRP			equ	30
_SRP			equ	31
_TT0			equ	32
_TT1			equ	33
_MMUSR			equ	34
_FP0			equ	35
_FP1			equ	36
_FP2			equ	37
_FP3			equ	38
_FP4			equ	39
_FP5			equ	40
_FP6			equ	41
_FP7			equ	42
_FPCR			equ	43
_FPSR			equ	44
_FPIAR			equ	45
_W1			equ	46
_W2			equ	47
_W3			equ	48
_W4			equ	49
_W5			equ	50
_CW			equ	51
;
;  #] REMs + EQUates:
;  #[ In work:
;
; finir:
;		+---------------------------------------+
;		| compilation des expressions a evaluer |
;		+---------------------------------------+
;
;  #] In work:
;  #[ Main:

evaluate:
 movem.l d2-d7/a1-a5,-(sp)
;  #[ Compile:
 IFNE Compile
 st compile_flag(a6)
 tst.b compile_flag(a6)
 beq.s .no_compile_init
 lea compile_buffer(a6),a1
 move.l a1,compile_pointer(a6)
.no_compile_init:
 ENDC
;  #] Compile:
 bsr Evaluate
 tst.l d0
 bmi.s .error
;  #[ Compile:
 IFNE Compile
 tst.b compile_flag(a6)
 beq.s .no_compile_test
 lea compile_buffer(a6),a1
 jsr (a1)
.no_compile_test:
 ENDC
;  #] Compile:
 lea result_buffer(a6),a1
 move.l $c(a1),d0
 movem.l (sp)+,d2-d7/a1-a5
 moveq #0,d1
 rts
.error:
 movem.l (sp)+,d2-d7/a1-a5
 moveq #-1,d1
 rts

;  #] Main:
;  #[ Global variables init:

Evaluate:
 bra.s .1
.evaluate_loop:
 tst.b evaluate_one_string_flag(a6)
 bne.s .error_in_cut
.1:
 bsr .Evaluate
 tst.w d0
 bmi.s .error_in_cut
 cmp.b #';',(a0)+
 beq.s .evaluate_loop
 subq.w #1,a0
.end_cut:
 rts
.error_in_cut:
 moveq #-1,d0
 rts

.Evaluate:
 clr.w par_number(a6)
 clr.w acc_number(a6)
 clr.w bracket_number(a6)
 clr.l result_buffer(a6)
 clr.l result_buffer+4(a6)
 clr.l result_buffer+8(a6)
 clr.l result_buffer+$c(a6)

;  #] Global variables init:
;  #[ Evaluator init:

_evaluate:
;  #[ Compile:
 IFNE Compile
 tst.b compile_flag(a6)
 beq.s .no_compile_save
.compile_save:
 bsr comp_save_context
.no_compile_save:
 ENDC
;  #] Compile:
 move.l reserved_stack_addr(a6),d1
 add.l #STACK_SECURITY,d1
 cmp.l d1,sp
 bgt.s .no_stack_error
 moveq #-1,d0
 rts
.no_stack_error: 
 movem.l d2-d7/a1-a5,-(sp)
 lea Start_of_context(a6),a5
 move.l #End_of_context-Start_of_context,d0
 lsr.w #6,d0
 subq.w #1,d0
 moveq	#0,d1
.save_context:
 move.l (a5),-(sp)
 move.l	d1,(a5)+
 move.l (a5),-(sp)
 move.l	d1,(a5)+
 move.l (a5),-(sp)
 move.l	d1,(a5)+
 move.l (a5),-(sp)
 move.l	d1,(a5)+
 move.l (a5),-(sp)
 move.l	d1,(a5)+
 move.l (a5),-(sp)
 move.l	d1,(a5)+
 move.l (a5),-(sp)
 move.l	d1,(a5)+
 move.l (a5),-(sp)
 move.l	d1,(a5)+
 move.l (a5),-(sp)
 move.l	d1,(a5)+
 move.l (a5),-(sp)
 move.l	d1,(a5)+
 move.l (a5),-(sp)
 move.l	d1,(a5)+
 move.l (a5),-(sp)
 move.l	d1,(a5)+
 move.l (a5),-(sp)
 move.l	d1,(a5)+
 move.l (a5),-(sp)
 move.l	d1,(a5)+
 move.l (a5),-(sp)
 move.l	d1,(a5)+
 move.l (a5),-(sp)
 move.l	d1,(a5)+
 dbf d0,.save_context
 link a4,#-$400
 link a5,#-$400
 move.l a4,initial_a4(a6) 
 move.l a5,initial_a5(a6)
 move.l sp,a3
 st op_flag(a6)
 clr.w token_number(a6)
 sf preinc_flag(a6)
 sf predec_flag(a6)
 moveq #0,d0
 move.b (a0),d0
 beq _empty_string
 cmp.b #')',d0				; end of level
 beq _empty_string
 cmp.b #']',d0				; end of parameter(s)
 beq _empty_string
 cmp.b #'}',d0				; end of level
 beq _empty_string
 cmp.b #':',d0				; end of <if then> expression
 beq _empty_string
 cmp.b #',',d0				; end of parameter
 beq _empty_string

;  #] Evaluator init:
;  #[ Main loop:

_loop:
 moveq #0,d0
 move.b (a0),d0
 beq _end_with_match
 addq.w #1,a0
 lea tokens_table,a1
 add.w	d0,d0
 add.w	d0,d0
 move.l 0(a1,d0.w),-(sp)
 beq.s .not_classic_token
 add.l (sp)+,a1
 move.b (a0),d0
 jsr (a1)
 beq _loop
 bra _syntax_error

.not_classic_token:
 subq.w #1,a0
 bsr Extract_number
 bsr _test_if_operator
 beq _loop
 cmp.w #-2,d0
 beq _syntax_error
 bsr _test_if_variable
 beq _loop
 cmp.w #-2,d0
 beq _syntax_error
 bsr _test_if_constant
 beq _loop
 cmp.w #-2,d0
 beq.s _syntax_error
 bsr _test_if_register
 beq _loop
 cmp.w #-2,d0
 beq.s _syntax_error
 tst.b evaluate_decimal_flag(a6)
 bne.s .default_decimal
 bsr _hexa_string2
 beq _loop
 bra.s _syntax_error
.default_decimal:
 bsr _decimal_string2
 beq _loop
 bra.s _syntax_error


;  #] Main loop:
;  #[ Evaluator exit:

_empty_string:
;  #[ Compile:
 IFNE Compile
 tst.b compile_flag(a6)
 beq.s .no_compile_empty
 moveq #-2,d0
 moveq #1,d1
 bsr comp_store_dx
 bsr comp_restore_context
.no_compile_empty:
 ENDC
;  #] Compile:
 addq.w #1,a0
 moveq #-2,d0
 move.l initial_a5(a6),a5
 move.l initial_a4(a6),a4
 unlk a5
 unlk a4
 lea End_of_context(a6),a5
 move.l #End_of_context-Start_of_context,d1
 lsr.w #6,d1
 subq.w #1,d1
.restore_context:
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 dbf d1,.restore_context
 move.l result_buffer+$c(a6),d1
 movem.l (sp)+,d2-d7/a1-a5
 rts
 
_syntax_error:
;  #[ Compile:
 IFNE Compile
 tst.b compile_flag(a6)
 beq.s .no_compile_error
 moveq #-1,d0
 moveq #1,d1
 bsr comp_store_dx
 bsr comp_restore_context
.no_compile_error:
 ENDC
;  #] Compile:
 move.l a3,sp
 move.l initial_a5(a6),a5
 move.l initial_a4(a6),a4
 unlk a5
 unlk a4
 lea End_of_context(a6),a5
 move.l #End_of_context-Start_of_context,d1
 lsr.w #6,d1
 subq.w #1,d1
.restore_context:
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 dbf d1,.restore_context
 movem.l (sp)+,d2-d7/a1-a5
 moveq #-1,d0
 rts

_end_no_match:
 cmp.w #1,token_number(a6)
 ble.s Exit_evaluator
 bsr eval_op
 bra.s _end_no_match

_end_with_match:
 tst.w par_number(a6)
 bne.s _syntax_error
 tst.w acc_number(a6)
 bne.s _syntax_error
 tst.w bracket_number(a6)
 bne.s _syntax_error 
 move.w token_number(a6),d0
 beq.s _syntax_error
 cmp.w #1,d0
 beq.s Exit_evaluator
 bsr eval_op
 bra.s _end_with_match
Exit_evaluator:
 tst.b preinc_flag(a6)
 beq.s .no_preinc
.preinc:
 or.b #$80,2(a4)
.no_preinc:
 tst.b predec_flag(a6)
 beq.s .no_predec
.predec:
 or.b #$20,2(a4)
.no_predec:
 sf preinc_flag(a6)
 sf predec_flag(a6)
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr unary_INC_DEC
 lea result_buffer(a6),a1
 moveq #0,d0
 move.b 1(a4),d0
 lsl.w #8,d0
 move.b 2(a4),d0
 and.b #7,d0
 movem.l (a4),d4-d5
 movem.l d4-d5,result_flags_buffer(a6)
 movem.l 8(a4),d4-d7
 movem.l d4-d7,(a1)
 sf evaluating_pre(a6)
 st evaluating_post(a6)
 move.l d0,-(sp)
 bsr unary_INC_DEC
 move.l (sp)+,d0
 move.l initial_a5(a6),a5
 move.l initial_a4(a6),a4
 unlk a5
 unlk a4
 lea End_of_context(a6),a5
 move.l #End_of_context-Start_of_context,d1
 lsr.w #6,d1
 subq.w #1,d1
.restore_context:
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 move.l (sp)+,-(a5)
 dbf d1,.restore_context
;  #[ Compile:
 IFNE Compile
 tst.b compile_flag(a6)
 beq.s .no_compile_empty
 moveq #0,d0
 moveq #1,d1
 bsr comp_store_dx
 bsr comp_restore_context
.no_compile_empty:
 ENDC
;  #] Compile:
 move.l result_buffer+$c(a6),d1
 movem.l (sp)+,d2-d7/a1-a5
 rts

;  #] Evaluator exit:
;  #[ Tokens management:

_test_if_operator:
 tst.b op_flag(a6)
 beq _syntax_error
 lea operators_token,a1
.another_one:
 lea evaluator_buffer(a6),a2
 move.l (a1)+,d1
 beq .not_found
 moveq #0,d0
.loop:
 move.b (a2)+,d0
 beq.s .1
 cmp.w #'a',d0
 blt.s .not_lower
 cmp.w #'z',d0
 bgt.s .not_lower
 and.w #$df,d0
.not_lower:
 cmp.b (a1)+,d0
 beq.s .loop
.get_end_of_token:
 tst.b (a1)+
 bne.s .get_end_of_token
 move.l a1,d0
 btst #0,d0
 beq.s .another_one
 addq.w #1,a1
 bra.s .another_one
.1:
 tst.b (a1)+
 bne.s .get_end_of_token
 move.l d1,a1
 jsr (a1)
 cmp.w #-1,d0
 beq.s .not_found
 tst.w d0
 bmi.s .error
 sf noformat_flag(a6)
 rts
.error:
 moveq #-2,d0
 rts
.not_found:
 moveq #-1,d0
 rts

_test_if_variable:
 lea evaluator_buffer(a6),a2
 bsr check_if_ro
 tst.l d0
 bmi .not_routine
 tst.b now_op(a6)
 bne _syntax_error
 tst.b op_flag(a6)
 beq _syntax_error
 cmp.b #'(',(a0)
 bne.s .no_parameters
 lea parameters_buffer(a6),a1
 move.l a1,parameters_pointer(a6)
 lea string_buffer(a6),a1
 move.l a1,string_pointer(a6)
 addq.w #1,a0
 moveq #0,d2
.parameters:
 bsr _evaluate
 tst.w d0
 bpl.s .correct_parameter
 not.w d0
 beq .error
.empty: 
 clr.l result_buffer+$c(a6)
 clr.l result_flags_buffer(a6)
 clr.l result_flags_buffer+4(a6)
.correct_parameter:
 btst #3,result_flags_buffer+2(a6)
 beq.s .no_string
.string:
 move.l a0,-(sp)
 move.l result_flags_buffer+4(a6),a0
 move.l string_pointer(a6),a1
 move.l a1,result_buffer+$c(a6)
 move.l d2,-(sp)
 bsr Extract_string
 move.l (sp)+,d2
 clr.b (a1)+
 move.l a1,string_pointer(a6)
 move.l (sp)+,a0
.no_string:
 move.l parameters_pointer(a6),a1
 move.l result_buffer+$c(a6),(a1)+
 addq.l #4,parameters_pointer(a6)
 addq.l #1,d2
 addq.w #1,a0
 cmp.b #')',-1(a0)
 beq.s .after_parameters
 cmp.b #',',-1(a0)
 bne .error
 bra.s .parameters
.no_parameters:
 moveq #0,d2
.after_parameters:
 move.l d2,d0
 move.l parameters_pointer(a6),a1
 add.l d2,d2
 add.l d2,d2
 sub.l d2,a1
; a0=pointeur sur la routine
; a1=pointeur sur les parametres ( 0 si param. number=0 )
; d0=nb. de parametres
 movem.l a0-a1,-(sp)
 move.l eval_ro_address(a6),a0
 bsr execute_ro
 movem.l (sp)+,a0-a1
 move.l d0,d7
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 movem.l d4-d7,-(a4)
 bsr neg_not_management
 move.w #$0702,d0
 bsr Store_number_size
 sf op_flag(a6)
 sf noformat_flag(a6)
 addq.w #1,token_number(a6)
 sf 3(a4)
 moveq #0,d0
 rts

.not_routine:
 cmp.b #'[',(a0)
 beq .array
 moveq #-1,d1
 moveq #0,d2
 bsr find_in_table
 tst.l d0
 bmi .not_found
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 move.l d1,d7
 movem.l d4-d7,-(a4)
 bsr neg_not_management
 move.w #$0702,d0
 bsr Store_number_size
 lea evaluator_buffer(a6),a2
 bsr Eval_strlen
 move.l a0,4(a4)				; stockage de l'adresse
 sub.l d0,4(a4)					; de la chaine...
 move.b #-2,3(a4)
 sf op_flag(a6)
 addq.w #1,token_number(a6)
.end:
 moveq #0,d0
 rts

.array:
 addq.w #1,a0
 move.b evaluate_decimal_flag(a6),-(sp)
 st evaluate_decimal_flag(a6)
 moveq #0,d2
 bsr _evaluate
 move.b (sp)+,evaluate_decimal_flag(a6)
 tst.w d0
 bmi.s .error
 cmp.b #']',(a0)+
 bne.s .error
 tst.l result_buffer(a6)
 bne.s .error
 tst.l result_buffer+4(a6)
 bne.s .error
 tst.l result_buffer+8(a6)
 bne.s .error
 tst.w result_buffer+$c(a6)
 bne.s .error
 move.w result_buffer+$e(a6),d0
 bmi.s .error
 movem.l d2/a0-a1,-(sp)
 lea evaluator_buffer(a6),a0
 lea result_buffer(a6),a1
 IFNE sourcedebug
 bsr get_array_elem_value
 ELSEIF
 moveq #-1,d0
 ENDC
 movem.l (sp)+,d2/a0-a1
 tst.w d0
 bmi.s .error
 movem.l d0-d1,-(sp)
 move.l result_buffer+$c(a6),d7
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 movem.l d4-d7,-(a4)
 bsr neg_not_management
 movem.l (sp)+,d0-d1
 bsr Store_number_size
 move.l d1,4(a4)
 sf op_flag(a6)
 sf noformat_flag(a6)
 addq.w #1,token_number(a6)
 st 3(a4)
 moveq #0,d0
 rts
 
.not_found:
 moveq #-1,d0
 rts
.error:
 moveq #-2,d0
 rts

_test_if_constant:
 tst.b op_flag(a6)
 beq _syntax_error
 lea constants_tokens,a1
.constant_loop:
 lea evaluator_buffer(a6),a2
 move.l a1,d0
 tst.l (a1)+
 beq.s .not_found
 addq.w #2,a1
 moveq #0,d1
.character_loop:
 move.b (a2)+,d1
 beq.s .test_end_of_constant
 cmp.w #'a',d1
 blt.s .not_lower
 cmp.w #'z',d1
 bgt.s .not_lower
.lower:
 and.w #$df,d1
.not_lower:
 tst.b (a1)
 beq.s .get_next_token
 cmp.b (a1)+,d1
 beq.s .character_loop
.get_next_token:
 tst.b (a1)+
 bne.s .get_next_token
 move.l a1,d1
 btst #0,d1
 beq.s .constant_loop
 addq.w #1,a1
 bra.s .constant_loop
.test_end_of_constant:
 tst.b (a1)
 bne.s .get_next_token
.found:
 move.l d0,a1
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 move.l (a1)+,d7
 movem.l d4-d7,-(a4)
 bsr neg_not_management
 move.w (a1)+,d0
 bsr Store_number_size
 or.w #$0100,(a4)			; flag d'heritage des attributs
 sf op_flag(a6)
 sf noformat_flag(a6)
 addq.w #1,token_number(a6)
 sf 3(a4)
.end:
 moveq #0,d0
 rts
.not_found:
 moveq #-1,d0
 rts
.error:
 moveq #-2,d0
 rts

_test_if_register:
 tst.b op_flag(a6)
 beq _syntax_error
 lea registers_token,a1
.another_one:
 lea evaluator_buffer(a6),a2
 move.l (a1)+,d1
 beq .not_found
 add.l a6,d1
 moveq #0,d0
.loop:
 move.b (a2)+,d0
 beq.s .1
 cmp.w #'a',d0
 blt.s .not_lower
 cmp.w #'z',d0
 bgt.s .not_lower
 and.w #$df,d0
.not_lower:
 tst.b (a1)
 beq.s .end_of_token
 cmp.b (a1)+,d0
 beq.s .loop
.get_end_of_token:
 tst.b (a1)+
 bne.s .get_end_of_token
.end_of_token:
 addq.w #3,a1
 move.l a1,d0
 btst #0,d0
 beq.s .another_one
 addq.w #1,a1
 bra.s .another_one
.1:
 tst.b (a1)+
 bne.s .get_end_of_token
 moveq #0,d2
 move.b (a1)+,d2
 move.b (a1)+,d0
 move.b (a1)+,d3
 move.l d1,a1
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 moveq #0,d7
 moveq #0,d1
 move.b d2,d1
 cmp.b #_SP,d3
 bne.s .not_sp
.sp:
 lea a7_buf(a6),a1
 btst #5,sr_buf(a6)
 beq.s .end_stacks
.super:
 bra.s .ssp
.not_sp:
 cmp.b #_SSP,d3
 bne.s .end_stacks
.ssp:
 IFNE _68030
 btst #4,sr_buf(a6)
 beq.s .isp
.msp:
 lea msp_buf(a6),a1
 bra.s .end_stacks
.isp:
 lea isp_buf(a6),a1
 ELSEIF
 lea ssp_buf(a6),a1
 ENDC ;de _68030
.end_stacks:
 cmp.b #_CW,d3
 bne.s .not_current_window
 move.w window_selected(a6),d7
 lsl.w #2,d7
 lea current_window_table,a1
 move.l -4(a1,d7.w),a1
 move.l (a1),a1
 add.l a6,a1
.not_current_window:
 add.w d1,d1
 jmp .registers_size(pc,d1.w)
.registers_size:
 bra.s .byte
 bra.s .word
 bra.s .long
 bra.s .single
 bra.s .double
 bra.s .extended
 bra.s .packed
.byte:
 move.b (a1),d7
 bra.s .after_size
.word:
 move.w (a1),d7
 bra.s .after_size
.long:
 move.l (a1),d7
 bra.s .after_size
.single:
 move.l (a1),d7
 bra.s .after_size
.double:
 move.l (a1),d6
 move.l 4(a1),d7
 bra.s .after_size
.extended:
 move.l (a1),d5
 move.l 4(a1),d6
 move.l 8(a1),d7
 bra.s .after_size
.packed:
 move.l (a1),d5
 move.l 4(a1),d6
 move.l 8(a1),d7
.after_size:
 movem.l d4-d7,-(a4)
 move.w d0,-(sp)
 bsr neg_not_management
 move.l a1,-(a4)
 clr.l -(a4)				
 move.b d2,2(a4)
 move.w (sp)+,d0
 move.b d0,1(a4)			; (allowed sizes)
 sf op_flag(a6)
 addq.w #1,token_number(a6)
 tst.b preinc_flag(a6)
 beq.s .no_preinc
.preinc:
 or.b #$80,2(a4)
.no_preinc:
 tst.b predec_flag(a6)
 beq.s .no_predec
.predec:
 or.b #$20,2(a4)
.no_predec:
 sf preinc_flag(a6)
 sf predec_flag(a6)
 move.b d3,3(a4)
.end:
 moveq #0,d0
 rts
.not_found:
 moveq #-1,d0
 rts
.syntax_error:
 moveq #-2,d0
 rts

_end_of_expression:
 addq.w #4,sp
.loop:
 cmp.w #1,token_number(a6)
 ble.s .Exit_evaluator
 bsr eval_op
 bra.s .loop
.Exit_evaluator:
 subq.w #1,a0
 bra Exit_evaluator

_end_of_parameter:
 addq.w #4,sp
.loop:
 cmp.w #1,token_number(a6)
 ble.s .Exit_evaluator
 bsr eval_op
 bra.s .loop
.Exit_evaluator:
 subq.w #1,a0
 bra Exit_evaluator

_binary_string:
 tst.b now_op(a6)
 bne _syntax_error
 tst.b op_flag(a6)
 beq _syntax_error
 bsr Extract_number
 bsr Convert_binary_string
 bmi.s .error
 movem.l d4-d7,-(a4)
 bsr neg_not_management
 move.w #$7f06,d0
 bsr Store_number_size
 sf op_flag(a6)
 sf noformat_flag(a6)
 addq.w #1,token_number(a6)
 sf 3(a4)
;  #[ Compile:
 IFNE Compile
 tst.b compile_flag(a6)
 beq.s .no_compile_store
 bsr comp_store_string
.no_compile_store:
 ENDC
;  #] Compile:
 moveq #0,d0
 rts
.error:
 moveq #-1,d0
 rts

_octal_string:
 tst.b now_op(a6)
 bne _syntax_error
 tst.b op_flag(a6)
 beq _syntax_error
 bsr Extract_number
 bsr Convert_octal_string
 bmi.s .error
 movem.l d4-d7,-(a4)
 bsr neg_not_management
 move.w #$7f06,d0
 bsr Store_number_size
 sf op_flag(a6)
 sf noformat_flag(a6)
 addq.w #1,token_number(a6)
 sf 3(a4)
;  #[ Compile:
 IFNE Compile
 tst.b compile_flag(a6)
 beq.s .no_compile_store
 bsr comp_store_string
.no_compile_store:
 ENDC
;  #] Compile:
 moveq #0,d0
 rts
.error:
 moveq #-1,d0
 rts

_decimal_string:
 tst.b now_op(a6)
 bne _syntax_error
 tst.b op_flag(a6)
 beq _syntax_error
 bsr Extract_number
 bsr Convert_decimal_string
 bmi.s .error
 movem.l d4-d7,-(a4)
 bsr neg_not_management
 move.w #$7f06,d0
 bsr Store_number_size
 sf op_flag(a6)
 sf noformat_flag(a6)
 addq.w #1,token_number(a6)
 sf 3(a4)
;  #[ Compile:
 IFNE Compile
 tst.b compile_flag(a6)
 beq.s .no_compile_store
 bsr comp_store_string
.no_compile_store:
 ENDC
;  #] Compile:
 moveq #0,d0
 rts
.error:
 moveq #-1,d0
 rts

_decimal_string2:
 tst.b now_op(a6)
 bne _syntax_error
 tst.b op_flag(a6)
 beq _syntax_error
 bsr Convert_decimal_string
 bmi.s .error
 movem.l d4-d7,-(a4)
 bsr neg_not_management
 move.w #$7f06,d0
 bsr Store_number_size
 sf op_flag(a6)
 sf noformat_flag(a6)
 addq.w #1,token_number(a6)
 sf 3(a4)
;  #[ Compile:
 IFNE Compile
 tst.b compile_flag(a6)
 beq.s .no_compile_store
 bsr comp_store_string
.no_compile_store:
 ENDC
;  #] Compile:
 moveq #0,d0
 rts
.error:
 moveq #-1,d0
 rts

_hexa_string:
 tst.b now_op(a6)
 bne _syntax_error
 tst.b op_flag(a6)
 beq _syntax_error
 bsr Extract_number
 bsr Convert_hexa_string
 bmi.s .error
 movem.l d4-d7,-(a4)
 bsr neg_not_management
 move.w #$7f06,d0
 bsr Store_number_size
 sf op_flag(a6)
 sf noformat_flag(a6)
 addq.w #1,token_number(a6)
 sf 3(a4)
;  #[ Compile:
 IFNE Compile
 tst.b compile_flag(a6)
 beq.s .no_compile_store
 bsr comp_store_string
.no_compile_store:
 ENDC
;  #] Compile:
 moveq #0,d0
 rts
.error:
 moveq #-1,d0
 rts

_hexa_string2:
 tst.b now_op(a6)
 bne _syntax_error
 tst.b op_flag(a6)
 beq _syntax_error
 bsr Convert_hexa_string
 bmi.s .error
 movem.l d4-d7,-(a4)
 bsr neg_not_management
 move.w #$7f06,d0
 bsr Store_number_size
 sf op_flag(a6)
 sf noformat_flag(a6)
 addq.w #1,token_number(a6)
 sf 3(a4)
;  #[ Compile:
 IFNE Compile
 tst.b compile_flag(a6)
 beq.s .no_compile_store
 bsr comp_store_string
.no_compile_store:
 ENDC
;  #] Compile:
 moveq #0,d0
 rts
.error:
 moveq #-1,d0
 rts

_breakpoint_string:
 tst.b now_op(a6)
 bne _syntax_error
 tst.b op_flag(a6)
 beq _syntax_error
 IFNE sourcedebug
 cmp.b #'#',(a0)
 beq.s _line_number_string
 ENDC ;de sourcedebug
 bsr Extract_number
 bsr Convert_hexa_string
 bmi.s .error
 tst.l d4
 bne _syntax_error
 tst.l d5
 bne _syntax_error
 tst.l d6
 bne _syntax_error
 move.l d7,d0
 bsr get_bkpt_address
 cmp.l #-1,d0
 beq .error
 move.l d0,d7
 movem.l d4-d7,-(a4)
 bsr neg_not_management
 move.w #$0402,d0
 bsr Store_number_size
 sf op_flag(a6)
 sf noformat_flag(a6)
 addq.w #1,token_number(a6)
 sf 3(a4)
 moveq #0,d0
 rts
.error:
 moveq #-1,d0
 rts

 IFNE sourcedebug
_line_number_string:
 addq.w #1,a0
 bsr Extract_number
 bsr Convert_decimal_string
 bmi.s .error
 tst.l d4
 bne _syntax_error
 tst.l d5
 bne _syntax_error
 tst.l d6
 bne _syntax_error
 move.l d7,d0
 bsr get_eval_source_line
 beq.s .error
 move.l d0,d7
 movem.l d4-d7,-(a4)
 bsr neg_not_management
 move.w #$0402,d0
 bsr Store_number_size
 sf op_flag(a6)
 sf noformat_flag(a6)
 addq.w #1,token_number(a6)
 sf 3(a4)
 moveq #0,d0
 rts
.error:
 moveq #-1,d0
 rts

get_eval_source_line:
	movem.l	d7/a0-a1,-(sp)
	tst.l	source_ptr(a6)
	beq.s	.error
	subq.l	#1,d0
	move.l	source_ptr(a6),a0
	move.l	source_len(a6),d1
	bsr	get_source_line
	beq	.error
	move.l	d0,a0
	bsr	get_code_addr
	beq	.error
	move.l	d0,d7
	;verifier s'il s'agit du module courant
	bsr	get_source_name
	cmp.l	source_name_addr(a6),a0
	bne.s	.error
	move.l	d7,d0
.end:
	movem.l	(sp)+,d7/a0-a1
	rts
.error:
	moveq	#0,d0
	bra.s	.end

 ENDC	;de sourcedebug

_string_string:
 tst.b now_op(a6)
 bne _syntax_error
 tst.b op_flag(a6)
 beq _syntax_error
 moveq #0,d2
 lea evaluator_buffer(a6),a1
 subq.w #1,a0
 bsr Extract_string
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 moveq #0,d7
 move.w	d2,-(sp)
 cmp.w #$10,d2
 bge .store_all
 lea evaluator_buffer(a6),a1
 tst.w d2
 beq .after_store
 subq.w #1,d2
.store_str:
 move.b (a1)+,d0
 bsr .shift
 or.b d0,d7
 dbf d2,.store_str
 bra.s .after_store
.store_all:
 bsr .store_four_characters
 move.l d0,d7
 bsr .store_four_characters
 move.l d0,d6
 bsr .store_four_characters
 move.l d0,d5
 bsr .store_four_characters
 move.l d0,d4
.after_store:
 move.w	(sp)+,d2
 movem.l d4-d7,-(a4)
 bsr neg_not_management
 move.w #$7f06|8,d0
 bsr Store_number_size
 move.l a0,4(a4)
 ext.l	d2
 sub.l d2,4(a4)
 subq.l #2,4(a4)
 sf op_flag(a6)
 st noformat_flag(a6)
 addq.w #1,token_number(a6)
 sf 3(a4)
;  #[ Compile:
 IFNE Compile
 tst.b compile_flag(a6)
 beq.s .no_compile_store
 bsr comp_store_string
.no_compile_store:
 ENDC
;  #] Compile:
 moveq #0,d0
 rts

.shift:
 rept 8
 lsl.l #1,d7
 roxl.l #1,d6
 roxl.l #1,d5
 roxl.l #1,d4
 endr
 rts

.store_four_characters:
 move.b -4(a1),d0
 lsl.w #8,d0
 move.b -3(a1),d0
 lsl.l #8,d0
 move.b -2(a1),d0
 lsl.l #8,d0
 move.b -1(a1),d0
 subq.w #4,a1
 rts

_if_then_op:
 move.w token_number(a6),d0
 beq _syntax_error
 cmp.w #1,d0
 beq.s .finish
 bsr eval_op
 bra.s _if_then_op
.finish:
 tst.l 8(a4)					
 bne.s .right
 tst.l 12(a4)					
 bne.s .right
 tst.l 16(a4)					
 bne.s .right
 tst.l 20(a4)					
 bne.s .right
.wrong:
 bsr Right_Wrong_match
 addq.w #1,a0
 bsr _evaluate
 cmp.w #-2,d0
 bne.s .1
 lea result_buffer(a6),a1
 moveq #0,d4
 rept 4
 move.l d4,(a1)+
 endr
 moveq #6,d0
.1:
 tst.w d0
 bmi _syntax_error
 move.w d0,-(sp)
 lea result_buffer(a6),a1
 movem.l (a1),d4-d7
 lea 24(a4),a4					
 movem.l d4-d7,-(a4)
 bsr neg_not_management
 move.w (sp)+,d0
 bsr Store_number_size
 sf op_flag(a6)
 sf now_op(a6)
 moveq #0,d0
 rts

.right:
 bsr _evaluate
 cmp.b #':',(a0)+
 bne _syntax_error
 cmp.w #-2,d0
 bne.s .2
 lea result_buffer(a6),a1
 moveq #0,d4
 rept 4
 move.l d4,(a1)+
 endr
 moveq #6,d0
.2:
 tst.w d0
 bmi _syntax_error
 move.w d0,-(sp)
 lea result_buffer(a6),a1
 movem.l (a1),d4-d7
 lea 24(a4),a4					
 movem.l d4-d7,-(a4)
 bsr neg_not_management
 move.w (sp)+,d0
 bsr Store_number_size
 sf op_flag(a6)
 sf now_op(a6)
 bsr Right_Wrong_match
 moveq #0,d0
 rts

Right_Wrong_match:
 moveq #0,d1
.loop:
 move.b (a0)+,d0
 beq.s .end_match
 addq.w #1,d1
 cmp.b #'(',d0
 beq.s .loop
 cmp.b #'[',d0
 beq.s .loop
 cmp.b #'{',d0
 beq.s .loop
 subq.w #1,d1
 cmp.b #':',d0
 beq.s .test_if_end_of_expression
 cmp.b #')',d0
 beq.s .test_if_end_of_level
 cmp.b #']',d0
 beq.s .test_if_end_of_level
 cmp.b #'}',d0
 beq.s .test_if_end_of_level
 bra.s .loop 
.test_if_end_of_level:
 subq.w #1,d1
 bpl.s .loop
 bra.s .end_match
.test_if_end_of_expression:
 tst.w d1
 bne.s .loop
.end_match:
 subq.w #1,a0
 rts

_else_op:
 addq.w #4,sp
 subq.w #1,a0
 bra _end_no_match

_add_preinc_postinc_op:
 IFNE 	AMIGA
 tst.b op_flag(a6)
 st op_flag(a6)
 ELSEIF
 tas op_flag(a6)
 ENDC
 bne.s .preinc
 cmp.b #'+',(a0)
 beq.s .postinc
 cmp.b #'=',(a0)
 beq.s .add_equal
 cmp.b #'+',(a0)
 bne.s .dyadic_plus
.preinc:
 cmp.b #'+',(a0)
 bne.s .monadic_plus
 addq.w #1,a0
 tst.b predec_flag(a6)
 bne.s .error
 IFNE 	AMIGA
 tst.b preinc_flag(a6)
 st preinc_flag(a6)
 ELSEIF
 tas preinc_flag(a6)
 ENDC
 bne.s .error
 sf now_op(a6)
 moveq #0,d0
 rts
.monadic_plus:
 sf now_op(a6)
 moveq #0,d0
 rts
.dyadic_plus:
 move.l #' +'|$00000000,-(a5)
 clr.l -4(a5)
 sf now_op(a6)
 moveq #0,d0
 rts
.postinc:
 addq.w #1,a0
 sf op_flag(a6)
 st now_op(a6)
 btst #6,2(a4)
 bne.s .error
 btst #4,2(a4)
 bne.s .error
 or.b #$40,2(a4)
 moveq #0,d0
 rts
.error:
 moveq #-1,d0
 rts
.add_equal:
 move.l #'+='|$00160000,-(a5)
 clr.l -4(a5)
 addq.w #1,a0
 sf now_op(a6)
 moveq #0,d0
 rts

_sub_predec_postdec_op:
 IFNE 	AMIGA
 tst.b op_flag(a6)
 st op_flag(a6)
 ELSEIF
 tas op_flag(a6)
 ENDC
 bne.s .predec
 cmp.b #'-',(a0)
 beq.s .postdec
 cmp.b #'=',(a0)
 beq.s .sub_equal
 cmp.b #'-',(a0)
 bne.s .dyadic_sub
.predec: 
 cmp.b #'-',(a0)
 bne.s .monadic_sub
 addq.w #1,a0
 tst.b preinc_flag(a6)
 bne.s .error
 IFNE 	AMIGA
 tst.b predec_flag(a6)
 st predec_flag(a6)
 ELSEIF
 tas predec_flag(a6)
 ENDC
 bne.s .error
 sf now_op(a6)
 moveq #0,d0
 rts
.monadic_sub:
 not.b neg_flag(a6)
 sf now_op(a6)
 moveq #0,d0
 rts
.dyadic_sub:
 move.l #' -'|$00030000,-(a5)
 clr.l -4(a5)
 sf now_op(a6)
 moveq #0,d0
 rts
.postdec:
 addq.w #1,a0
 sf op_flag(a6)
 st now_op(a6)
 btst #6,2(a4)
 bne.s .error
 btst #4,2(a4)
 bne.s .error
 or.b #$10,2(a4)
 moveq #0,d0
 rts
.error:
 moveq #-1,d0
 rts
.sub_equal:
 move.l #'-='|$00170000,-(a5)
 clr.l -4(a5)
 addq.w #1,a0
 sf now_op(a6)
 moveq #0,d0
 rts

_mulu_op:
 IFNE 	AMIGA
 tst.b op_flag(a6)
 st op_flag(a6)
 ELSEIF
 tas op_flag(a6)
 ENDC
; bne _syntax_error
 bne.s .C_indirection
 cmp.b #'=',(a0)
 beq.s .mulu_equal
 move.l #' *'|$00060000,-(a5)
 clr.l -4(a5)
 sf now_op(a6)
 moveq #0,d0
 rts
.mulu_equal:
 move.l #'*='|$00180000,-(a5)
 clr.l -4(a5)
 addq.w #1,a0
 sf now_op(a6)
 moveq #0,d0
 rts
.C_indirection:
 addq.w #1,C_ind_counter(a6)
 sf now_op(a6)
 moveq #0,d0
 rts
 
_divu_op:
 IFNE 	AMIGA
 tst.b op_flag(a6)
 st op_flag(a6)
 ELSEIF
 tas op_flag(a6)
 ENDC
 bne _syntax_error
 cmp.b #'=',(a0)
 beq.s .divu_equal
 move.l #' /'|$00070000,-(a5)
 clr.l -4(a5)
 sf now_op(a6)
 moveq #0,d0
 rts
.divu_equal:
 move.l #'/='|$00190000,-(a5)
 clr.l -4(a5)
 addq.w #1,a0
 sf now_op(a6)
 moveq #0,d0
 rts

_and_logand_op:
 IFNE 	AMIGA
 tst.b op_flag(a6)
 st op_flag(a6)
 ELSEIF
 tas op_flag(a6)
 ENDC
 bne.s .amper_op
 cmp.b #'&',(a0)
 beq.s .logand
 cmp.b #'=',(a0)
 beq.s .and_equal
.and:
 move.l #' &'|$00080000,-(a5)
 clr.l -4(a5)
 sf now_op(a6)
 moveq #0,d0
 rts
.logand:
 move.l #'&&'|$00090000,-(a5)
 clr.l -4(a5)
 sf now_op(a6)
 addq.w #1,a0
 moveq #0,d0
 rts
.and_equal:
 move.l #'&='|$001d0000,-(a5)
 clr.l -4(a5)
 sf now_op(a6)
 addq.w #1,a0
 moveq #0,d0
 rts
.amper_op:
 move.b neg_flag(a6),-(sp)
 move.b not_flag(a6),-(sp)
 bsr Extract_number
 bsr _test_if_variable
 move.b (sp)+,not_flag(a6)
 move.b (sp)+,neg_flag(a6)
 bmi _syntax_error
 addq.w #4,a4
 move.l (a4)+,d1
 lea 12(a4),a4
 move.l d1,(a4)
 clr.l -(a4)
 clr.l -(a4)
 clr.l -(a4)
 bsr neg_not_management
 move.w #$0702,d0
 bsr Store_number_size
 sf 3(a4)
 moveq #0,d0
 rts

_or_logor_op:
 IFNE 	AMIGA
 tst.b op_flag(a6)
 st op_flag(a6)
 ELSEIF
 tas op_flag(a6)
 ENDC
 bne _syntax_error
 cmp.b #'|',(a0)
 beq.s .logor
 cmp.b #'=',(a0)
 beq.s .or_equal
.or:
 move.l #' |'|$000a0000,-(a5)
 clr.l -4(a5)
 sf now_op(a6)
 moveq #0,d0
 rts
.logor:
 move.l #'||'|$000b0000,-(a5)
 clr.l -4(a5)
 sf now_op(a6)
 addq.w #1,a0
 moveq #0,d0
 rts
.or_equal:
 move.l #'|='|$001e0000,-(a5)
 clr.l -4(a5)
 sf now_op(a6)
 addq.w #1,a0
 moveq #0,d0
 rts

_not_op:
 cmp.b #'=',(a0)
 beq.s .not_equal
 tst.b op_flag(a6)
 beq _syntax_error
 not.b not_flag(a6)
 sf now_op(a6)
 moveq #0,d0
 rts
.not_equal:
 IFNE AMIGA
 tst.b op_flag(a6)
 st op_flag(a6)
 ELSEIF
 tas op_flag(a6)
 ENDC
 bne _syntax_error
 move.l #'~='|$001a0000,-(a5)
 clr.l -4(a5)
 addq.w #1,a0
 sf now_op(a6)
 moveq #0,d0
 rts

_eor_op:
 IFNE 	AMIGA
 tst.b op_flag(a6)
 st op_flag(a6)
 ELSEIF
 tas op_flag(a6)
 ENDC
 bne _syntax_error
 cmp.b #'=',(a0)
 beq.s .eor_equal
 move.l #' ^'|$000c0000,-(a5)
 clr.l -4(a5)
 sf now_op(a6)
 moveq #0,d0
 rts
.eor_equal:
 move.l #'^='|$001f0000,-(a5)
 clr.l -4(a5)
 sf now_op(a6)
 addq.w #1,a0
 moveq #0,d0
 rts
 
_inf_infeq_lsl_op:
 IFNE 	AMIGA
 tst.b op_flag(a6)
 st op_flag(a6)
 ELSEIF
 tas op_flag(a6)
 ENDC
 bne _syntax_error
 move.b (a0),d0
 cmp.b #'<',d0
 beq.s .lsl
 cmp.b #'=',d0
 beq.s .infeq
.inf:
 move.l #' <'|$000d0000,-(a5)
 clr.l -4(a5)
 sf now_op(a6)
 moveq #0,d0
 rts
.infeq:
 move.l #'<='|$000e0000,-(a5)
 clr.l -4(a5)
 sf now_op(a6)
 addq.w #1,a0
 moveq #0,d0
 rts
.lsl:
 cmp.b #'=',1(a0)
 beq.s .lsl_equal
 move.l #'<<'|$000f0000,-(a5)
 clr.l -4(a5)
 sf now_op(a6)
 addq.w #1,a0
 moveq #0,d0
 rts
.lsl_equal:
 move.l #'L='|$001b0000,-(a5)
 clr.l -4(a5)
 sf now_op(a6)
 addq.w #2,a0
 moveq #0,d0
 rts

_sup_supeq_lsr_op:
 IFNE 	AMIGA
 tst.b op_flag(a6)
 st op_flag(a6)
 ELSEIF
 tas op_flag(a6)
 ENDC
 bne _syntax_error
 move.b (a0),d0
 cmp.b #'>',d0
 beq.s .lsr
 cmp.b #'=',d0
 beq.s .supeq
.sup:
 move.l #' >'|$00100000,-(a5)
 clr.l -4(a5)
 sf now_op(a6)
 moveq #0,d0
 rts
.supeq:
 move.l #'>='|$00110000,-(a5)
 clr.l -4(a5)
 sf now_op(a6)
 addq.w #1,a0
 moveq #0,d0
 rts
.lsr:
 cmp.b #'=',1(a0)
 beq.s .lsr_equal
 move.l #'>>'|$00120000,-(a5)
 clr.l -4(a5)
 sf now_op(a6)
 addq.w #1,a0
 moveq #0,d0
 rts
.lsr_equal:
 move.l #'R='|$001c0000,-(a5)
 clr.l -4(a5)
 sf now_op(a6)
 addq.w #2,a0
 moveq #0,d0
 rts

_affect_equal_op:
 IFNE 	AMIGA
 tst.b op_flag(a6)
 st op_flag(a6)
 ELSEIF
 tas op_flag(a6)
 ENDC
 bne _syntax_error
 cmp.b #'=',(a0)
 beq.s .equal
.affect:
 move.l #' ='|$00130000,-(a5)
 clr.l -4(a5)
 sf now_op(a6)
 moveq #0,d0
 rts
.equal:
 move.l #'=='|$00140000,-(a5)
 clr.l -4(a5)
 sf now_op(a6)
 addq.w #1,a0
 moveq #0,d0
 rts

_different_not_op: 
 cmp.b #'=',(a0)
 beq.s .different
.not:
 tst.b op_flag(a6)
 beq _syntax_error
 not.b not_flag(a6)
 sf now_op(a6)
 moveq #0,d0
 rts
.different:
 IFNE 	AMIGA
 tst.b op_flag(a6)
 st op_flag(a6)
 ELSEIF
 tas op_flag(a6)
 ENDC
 bne _syntax_error
 move.l #'!='|$00150000,-(a5)
 clr.l -4(a5)
 sf now_op(a6)
 addq.w #1,a0
 moveq #0,d0
 rts

_size:
 tst.b op_flag(a6)
 bne _syntax_error
 moveq #0,d0
 move.b 1(a4),d1
 move.b (a0),d0
 cmp.w #'a',d0
 blt.s .no_conv
 cmp.w #'z',d0
 bgt.s .no_conv
.conv:
 bclr #5,d0
.no_conv:
 cmp.b #'B',d0
 beq.s .byte
 cmp.b #'W',d0
 beq.s .word
 cmp.b #'L',d0
 beq.s .long
 cmp.b #'S',d0
 beq.s .single
 cmp.b #'D',d0
 beq.s .double
 cmp.b #'E',d0
 beq.s .extended
 cmp.b #'P',d0
 beq.s .packed
.error:
 moveq #-1,d0
 rts
.end:
 bsr _Convert_format
 bmi.s .error
 and.b #$0f,d0
 and.b #$f0,2(a4)			
 or.b d0,2(a4)				
 st now_op(a6)
 addq.w #1,a0 
 moveq #0,d0
 rts
.byte:
 btst #0,d1
 beq.s .error
 moveq #0,d0
 bra.s .end
.word:
 btst #1,d1
 beq.s .error
 moveq #1,d0
 bra.s .end
.long:
 btst #2,d1
 beq.s .error
 moveq #2,d0
 bra.s .end
.single:
 btst #3,d1
 beq.s .error
 moveq #3,d0
 bra.s .end
.double:
 btst #4,d1
 beq.s .error
 moveq #4,d0
 bra.s .end
.extended:
 btst #5,d1
 beq.s .error
 moveq #5,d0
 bra.s .end
.packed:
 btst #6,d1
 beq.s .error
 moveq #6,d0
 bra.s .end

_open_par:
 tst.b op_flag(a6)
 beq _syntax_error
 addq.w #1,par_number(a6)
.another_expression:
 bsr _evaluate
 tst.w d0
 bmi _syntax_error
 cmp.b #';',(a0)+
 beq.s .another_expression
 cmp.b #')',-1(a0)
 bmi _syntax_error
 move.w d0,-(sp)
 lea result_buffer(a6),a1
 movem.l (a1),d4-d7
 movem.l d4-d7,-(a4)
 bsr neg_not_management
 move.w (sp)+,d0
 bsr Store_number_size
 sf op_flag(a6)
 st now_op(a6)
 subq.w #1,par_number(a6)
 addq.w #1,token_number(a6)
 moveq #0,d0
 rts

_close_par:
 addq.w #4,sp
.loop:
 cmp.w #1,token_number(a6)
 ble.s .Exit_evaluator
 bsr eval_op
 bra.s .loop
.Exit_evaluator:
 move.b #$7f,1(a4)
 or.b #2,2(a4)
 subq.w #1,a0
 bra Exit_evaluator

_open_acc:
 tst.b op_flag(a6)
 beq _syntax_error
 addq.w #1,acc_number(a6)
.another_expression:
 bsr _evaluate
 tst.w d0
 bmi _syntax_error
 cmp.b #';',(a0)+
 beq.s .another_expression
 cmp.b #'}',-1(a0)
 bne _syntax_error
 btst #0,result_flags_buffer(a6)
 beq.s .no_attributes_recover
 lea result_buffer(a6),a1
 movem.l (a1),d4-d7
 move.l d7,a1
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 moveq #0,d7
 movem.l d4-d7,-(a4)
 move.l a1,-(a4)
 move.l result_flags_buffer(a6),-(a4)
 bclr #0,(a4)
 bra.s .after_attributes_recover
.no_attributes_recover:
 lea result_buffer(a6),a1
 movem.l (a1),d4-d7
 move.l d7,a1
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 moveq #0,d7
 movem.l d4-d7,-(a4)
 move.l a1,-(a4)
 clr.l -(a4)
 move.b #$7f,1(a4)
 move.b #2,2(a4)
.after_attributes_recover:
 cmp.b #'.',(a0)
 bne.s .current_size			; may be attributes recover
 addq.w #1,a0
 sf op_flag(a6)				; *
 st now_op(a6)				; *
 bsr _size
 bmi _syntax_error
.current_size:
 move.w 2(a4),d0				
 lsr.w #8,d0
 and.w #$f,d0
 add.w d0,d0
 add.w d0,d0
 jmp .size_management(pc,d0.w)
.size_management:
 bra .assume_byte
 bra .assume_word
 bra .assume_long
 bra .assume_single
 bra .assume_double
 bra .assume_extended
 bra .assume_packed
.assume_byte:
 _JSR test_if_readable3
 tst.b readable_buffer(a6)
 bne .error
 move.b (a1),d7
 bra .after_size
.assume_word:
 _JSR test_if_readable2
 tst.w readable_buffer(a6)
 bne .error
 move.b (a1),d7
 lsl.w #8,d7
 move.b 1(a1),d7
 bra .after_size
.assume_long:
.assume_single:
 _JSR test_if_readable
 tst.l readable_buffer(a6)
 bne .error
 move.b (a1),d7
 lsl.w #8,d7
 move.b 1(a1),d7
 lsl.l #8,d7
 move.b 2(a1),d7
 lsl.l #8,d7
 move.b 3(a1),d7
 bra .after_size
.assume_double:
 _JSR test_if_readable
 tst.l readable_buffer(a6)
 bne .error
 addq.w #4,a1
 _JSR test_if_readable
 tst.l readable_buffer(a6)
 bne .error
 subq.w #4,a1
 move.b (a1),d6
 lsl.w #8,d6
 move.b 1(a1),d6
 lsl.l #8,d6
 move.b 2(a1),d6
 lsl.l #8,d6
 move.b 3(a1),d6
 move.b 4(a1),d7
 lsl.w #8,d7
 move.b 5(a1),d7
 lsl.l #8,d7
 move.b 6(a1),d7
 lsl.l #8,d7
 move.b 7(a1),d7
 bra .after_size
.assume_extended:
.assume_packed:
 _JSR test_if_readable
 tst.l readable_buffer(a6)
 bne .error
 addq.w #4,a1
 _JSR test_if_readable
 tst.l readable_buffer(a6)
 bne .error
 addq.w #4,a1
 _JSR test_if_readable
 tst.l readable_buffer(a6)
 bne .error
 addq.w #4,a1
 _JSR test_if_readable
 tst.l readable_buffer(a6)
 bne .error
 lea -12(a1),a1
 move.b (a1),d5
 lsl.w #8,d5
 move.b 1(a1),d5
 lsl.l #8,d5
 move.b 2(a1),d5
 lsl.l #8,d5
 move.b 3(a1),d5
 move.b 4(a1),d6
 lsl.w #8,d6
 move.b 5(a1),d6
 lsl.l #8,d6
 move.b 6(a1),d6
 lsl.l #8,d6
 move.b 7(a1),d6
 move.b 8(a1),d7
 lsl.w #8,d7
 move.b 9(a1),d7
 lsl.l #8,d7
 move.b $a(a1),d7
 lsl.l #8,d7
 move.b $b(a1),d7
.after_size:
 addq.w #8,a4					
 movem.l d4-d7,(a4)
 bsr neg_not_management
 subq.w #8,a4					
 sf op_flag(a6)
 st now_op(a6)
 subq.w #1,acc_number(a6)
 addq.w #1,token_number(a6)
 tst.b preinc_flag(a6)
 beq.s .no_preinc
.preinc:
 or.b #$80,2(a4)
.no_preinc:
 tst.b predec_flag(a6)
 beq.s .no_predec
.predec:
 or.b #$20,2(a4)
.no_predec:
 sf preinc_flag(a6)
 sf predec_flag(a6)
 st 3(a4)
 moveq #0,d0
 rts
.error:
 moveq #-1,d0
 rts

_close_acc:
 addq.w #4,sp
.loop:
 cmp.w #1,token_number(a6)
 ble.s .Exit_evaluator
 bsr eval_op
 bra.s .loop
.Exit_evaluator:
 subq.w #1,a0
 btst #0,(a4)				; attributes recover ???
 bne Exit_evaluator
 or.b #$7f,1(a4)
 and.b #$fc,2(a4)
 or.b #2,2(a4)
 bra Exit_evaluator

_close_bracket:
 addq.w #4,sp
 subq.w #1,a0
 bra _end_no_match

_comma:
 addq.w #4,sp
 bra _end_no_match

neg_not_management:
 movem.l d3-d7,-(sp)
 tst.b neg_flag(a6)
 beq.s .not_neg
 not.l (a4)
 not.l 4(a4)
 not.l 8(a4)
 not.l $c(a4)
 movem.l (a4),d4-d7
 moveq #0,d0
 addq.l #1,d7
 addx.l d0,d6
 addx.l d0,d5
 addx.l d0,d4
 movem.l d4-d7,(a4)
.not_neg:
 tst.b not_flag(a6)
 beq.s .not_not
 not.l (a4)
 not.l 4(a4)
 not.l 8(a4)
 not.l $c(a4)
.not_not:
 sf neg_flag(a6)
 sf not_flag(a6)
 movem.l (sp)+,d3-d7
 rts

_start_of_block_op:
 move.b (a0),d0
 cmp.b #'(',d0
 bne.s .not_found
 addq.w #1,a0
 bsr Extract_block_name
 bmi.s .error
 move.w #BLWORD,d0
 moveq #0,d1
 lea evaluator_buffer(a6),a2
 bsr find_in_table
 tst.w d0
 bmi.s .error
 move.l d1,a2
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 move.l (a2),d7
 movem.l d4-d7,-(a4)
 bsr neg_not_management
 move.w #$0702,d0
 bsr Store_number_size
 sf op_flag(a6)
 sf now_op(a6)
 addq.w #1,token_number(a6)
 sf 3(a4)
.end:
 moveq #0,d0
 rts
.error:
 moveq #-2,d0
 rts
.not_found:
 moveq #-1,d0
 rts

_end_of_block_op:
 move.b (a0),d0
 cmp.b #'(',d0
 bne.s .not_found
 addq.w #1,a0
 bsr Extract_block_name
 bmi.s .error
 move.w #BLWORD,d0
 moveq #0,d1
 lea evaluator_buffer(a6),a2
 bsr find_in_table
 tst.w d0
 bmi.s .error
 move.l d1,a2
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 move.l 4(a2),d7
 movem.l d4-d7,-(a4)
 bsr neg_not_management
 move.w #$0702,d0
 bsr Store_number_size
 sf op_flag(a6)
 sf now_op(a6)
 addq.w #1,token_number(a6)
 sf 3(a4)
.end:
 moveq #0,d0
 rts
.error:
 moveq #-2,d0
 rts
.not_found:
 moveq #-1,d0
 rts

_length_of_block_op:
 move.b (a0),d0
 cmp.b #'(',d0
 bne.s .not_found
 addq.w #1,a0
 bsr Extract_block_name
 bmi.s .error
 move.w #BLWORD,d0
 moveq #0,d1
 lea evaluator_buffer(a6),a2
 bsr find_in_table
 tst.w d0
 bmi.s .error
 move.l d1,a2
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 move.l 4(a2),d7
 sub.l (a2),d7
 addq.l #1,d7
 movem.l d4-d7,-(a4)
 bsr neg_not_management
 move.w #$0702,d0
 bsr Store_number_size
 sf op_flag(a6)
 sf now_op(a6)
 addq.w #1,token_number(a6)
 sf 3(a4)
.end:
 moveq #0,d0
 rts
.error:
 moveq #-2,d0
 rts
.not_found:
 moveq #-1,d0
 rts

_previous_label_op:
 move.b (a0),d0
 cmp.b #'(',d0
 bne.s .not_found
 addq.w #1,a0
 bsr _evaluate
 tst.w d0
 bmi.s .error
 cmp.b #')',(a0)+
 bne.s .error
 btst #3,result_flags_buffer+2(a6)
 bne.s .error
 move.l result_buffer+$c(a6),d7
 moveq #-1,d0
 bra.s next_previous_op
.error:
 moveq #-2,d0
 rts
.not_found:
 moveq #-1,d0
 rts

_next_label_op:
 move.b (a0),d0
 cmp.b #'(',d0
 bne.s .not_found
 addq.w #1,a0
 bsr _evaluate
 tst.w d0
 bmi.s .error
 cmp.b #')',(a0)+
 bne.s .error
 btst #3,result_flags_buffer+2(a6)
 bne.s .error
 move.l result_buffer+$c(a6),d7
 moveq #1,d0
 bra.s next_previous_op
.error:
 moveq #-2,d0
 rts
.not_found:
 moveq #-1,d0
 rts

next_previous_op:
 bsr internal_next_previous_in_table
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 move.l d0,d7
 movem.l d4-d7,-(a4)
 bsr neg_not_management
 move.w #$0702,d0
 bsr Store_number_size
 sf op_flag(a6)
 sf now_op(a6)
 addq.w #1,token_number(a6)
 sf 3(a4)
.end:
 moveq #0,d0
 rts

_modulo_op:
 move.b (a0),d0
 cmp.b #'(',d0
 bne .not_found
 addq.w #1,a0
 bsr _evaluate
 tst.w d0
 bmi.s .error
 cmp.b #',',(a0)+
 bne.s .error
 btst #3,result_flags_buffer+2(a6)
 bne.s .error
 movem.l result_buffer(a6),d4-d7
 bsr _evaluate
 tst.w d0
 bmi.s .error
 cmp.b #')',(a0)+
 bne.s .error
 btst #3,result_flags_buffer+2(a6)
 bne.s .error
 movem.l result_buffer(a6),d0-d3
 exg d0,d4
 exg d1,d5
 exg d2,d6
 exg d3,d7
 lea evaluator_buffer(a6),a1
 movem.l d0-d7,(a1)
 bsr DIVU
 bmi.s .error
 movem.l 16(a1),d0-d3
 bsr MULU
 movem.l (a1),d0-d3
 bsr SUB
 movem.l d4-d7,-(a4)
 bsr neg_not_management
 move.w #$7f06,d0
 bsr Store_number_size
 sf op_flag(a6)
 sf now_op(a6)
 addq.w #1,token_number(a6)
 sf 3(a4)
.end:
 moveq #0,d0
 rts
.error:
 moveq #-2,d0
 rts
.not_found:
 moveq #-1,d0
 rts

_while_op:
 sf d3
 move.b (a0),d0
 cmp.b #'(',d0
 bne .not_found
 addq.w #1,a0
 sub.l a2,a2
.until_loop:
 move.l a0,-(sp)
 bsr _evaluate
 tst.w d0
 bmi .error
 lea result_buffer(a6),a1 
 rept 4
 tst.l (a1)+
 bne.s .continue_loop
 endr
 bra.s .exit_loop
.continue_loop:
 tst.b d3
 bne.s .exit_loop
 bsr .until_inkey
 cmp.b #',',(a0)+
 bne.s .error
 btst #3,result_flags_buffer+2(a6)
 bne.s .error
 movem.l result_buffer(a6),d4-d7
 bsr _evaluate
 tst.w d0
 bmi.s .error
 cmp.b #')',(a0)
 bne.s .error
 btst #3,result_flags_buffer+2(a6)
 bne.s .error
 move.l a0,a2
 move.l (sp)+,a0
 bra .until_loop
.exit_loop:
 move.l a2,d0
 beq.s .match_end_of_expression
 move.l a2,a0
 cmp.b #')',(a0)+
 bne.s .error
 addq.w #4,sp
 lea result_buffer(a6),a1
 movem.l (a1),d4-d7
 movem.l d4-d7,-(a4)
 bsr neg_not_management
 move.w #$7f06,d0
 bsr Store_number_size
 sf op_flag(a6)
 sf now_op(a6)
 addq.w #1,token_number(a6)
 sf 3(a4)
.end:
 moveq #0,d0
 rts
.error:
 addq.w #4,sp
 moveq #-2,d0
 rts
.not_found:
 moveq #-1,d0
 rts

.until_inkey:
 movem.l d0-d2/a0-a2,-(sp)
 _JSR inkey
 cmp.w #$1b,d0
 bne.s .exit_inkey
 st d3
.exit_inkey:
 movem.l (sp)+,d0-d2/a0-a2
 rts

.match_end_of_expression:
 moveq #0,d1
 cmp.b #',',(a0)+
 bne.s .error
.match_par_loop:
 move.b (a0)+,d0
 beq.s .error
 cmp.b #'(',d0
 bne.s .not_open_par
 addq.w #1,d1
.not_open_par:
 cmp.b #')',d0
 bne.s .match_par_loop
 subq.w #1,d1
 bpl.s .match_par_loop
 subq.w #1,a0
 move.l a0,a2
 bra .exit_loop 

_watch_op:
 move.b (a0),d0
 cmp.b #'(',d0
 bne .not_found
 addq.w #1,a0
 bsr _evaluate
 tst.w d0
 bmi.s .error
 cmp.b #')',(a0)+
 bne.s .error
 btst #3,result_flags_buffer+2(a6)
 bne.s .error
 move.l a0,-(sp)
 move.l test_instruction(a6),-(sp)
 move.l result_buffer+$c(a6),a1
 move.l a1,test_instruction(a6)
 lea line_buffer(a6),a0
 _JSR disassemble_line
 move.l (sp)+,test_instruction(a6)
 move.l (sp)+,a0
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 tst.w d0
 bmi.s .nothing
 lea instruction_descriptor(a6),a1
 tst.w _I_branchf(a1)
 beq.s .nothing
 move.l _I_branchaddr(a1),d7
 bra.s .store_result
.nothing:
 moveq #0,d7
.store_result:
 movem.l d4-d7,-(a4)
 bsr neg_not_management
 move.w #$7f06,d0
 bsr Store_number_size
 sf op_flag(a6)
 sf now_op(a6)
 addq.w #1,token_number(a6)
 sf 3(a4)
.end:
 moveq #0,d0
 rts
.error:
 moveq #-2,d0
 rts
.not_found:
 moveq #-1,d0
 rts

_set_var_op:
 move.b (a0),d0
 cmp.b #'(',d0
 bne .not_found
 addq.w #1,a0
 bsr Extract_number
 cmp.b #')',(a0)
 bne.s .error
 movem.l d0-d2/a0-a2,-(sp)
 move.w #LAWORD,d0
 lea evaluator_buffer(a6),a0
 sub.l a1,a1
 bsr put_in_table
 tst.w d0
 movem.l (sp)+,d0-d2/a0-a2
 bmi.s .error
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 moveq #0,d7
 movem.l d4-d7,-(a4)
 bsr neg_not_management
 move.w #$0702,d0
 bsr Store_number_size
 lea evaluator_buffer(a6),a2
 bsr Eval_strlen
 move.l a0,4(a4)				; stockage de l'adresse
 sub.l d0,4(a4)					; de la chaine...
 move.b #-2,3(a4)
 sf op_flag(a6)
 addq.w #1,a0
 addq.w #1,token_number(a6)
.end:
 moveq #0,d0
 rts
.error:
 moveq #-2,d0
 rts
.not_found:
 moveq #-1,d0
 rts

internal_next_previous_in_table:
 move.l a0,-(sp)
 movem.l d0-d1,-(sp)
 move.l current_var_nb(a6),d0
 move.l var_tree_addr(a6),d1
 move.l d7,a1
 lea comp_var_tree_2(pc),a0
 bsr trouve2
 movem.l (sp)+,d0-d1
 bmi.s .not_symbol
.symbol: 
 add.l d0,d7
.not_symbol:
 tst.w d0
 bmi.s .get_previous
.get_next:
 move.l current_var_nb(a6),d6
 beq .not_found
 mulu #VAR_TREE_SIZE,d6
 add.l var_tree_addr(a6),d6
.next_loop:
 move.l a0,d0
 cmp.l d0,d6
 beq.s .not_found
 move.l (a0),d0
 cmp.l d7,d0
 bhi.s .next_found
 beq.s .next_found
 lea VAR_TREE_SIZE(a0),a0
 bra.s .next_loop
.next_found:				; test VAR type
 move.l a1,-(sp)
 move.l VAR_TREE_VAR(a0),a1
 move.l 4(a1),d0
 cmp.w #LAWORD,4(a1)
 movem.l (sp)+,a1
 bne.s .next_loop
 bra.s .get_var
.get_previous:
 move.l current_var_nb(a6),d6
 beq.s .not_found
 mulu #VAR_TREE_SIZE,d6
 move.l var_tree_addr(a6),d5
 add.l d5,d6
 move.l a0,d0
 cmp.l d0,d6
 bne.s .previous_loop
 lea -VAR_TREE_SIZE(a0),a0
.previous_loop:
 move.l a0,d0
 cmp.l d0,d5
 bhi.s .not_found
 move.l (a0),d0
 cmp.l d0,d7
 bhi.s .previous_found
 beq.s .previous_found
 lea -VAR_TREE_SIZE(a0),a0
 bra.s .previous_loop
.previous_found:			; test VAR type
 move.l a1,-(sp)
 move.l VAR_TREE_VAR(a0),a1
 move.l 4(a1),d0
 cmp.w #LAWORD,4(a1)
 movem.l (sp)+,a1
 bne.s .next_loop
.get_var:
 move.l VAR_TREE_VAR(a0),a1
 move.l 6(a1),d0
 bra.s .end
.not_found:
 moveq #0,d0
.end:
 move.l (sp)+,a0
 rts

 IFNE sourcedebug
_source_op:
 move.b (a0),d0
 cmp.b #'(',d0
 bne .not_found
 addq.w #1,a0
 bsr _evaluate
 tst.w d0
 bmi.s .error
 cmp.b #')',(a0)+
 bne.s .error
 btst #3,result_flags_buffer+2(a6)
 bne.s .error
 movem.l result_buffer+$c(a6),d0
; cmp.l pc_buf(a6),d0
; bne.s .search
; move.l source_pc_ptr(a6),d0
; bra.s .get
;.search:
 bsr eval_get_source_addr
;.get:
 tst.l d0
 beq.s .error
 move.l d0,d7
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 movem.l d4-d7,-(a4)
 bsr neg_not_management
 move.w #$7f02,d0
 bsr Store_number_size
 sf op_flag(a6)
 sf now_op(a6)
 addq.w #1,token_number(a6)
 sf 3(a4)
.end:
 moveq #0,d0
 rts
.error:
 moveq #-2,d0
 rts
.not_found:
 moveq #-1,d0
 rts

eval_get_source_addr:
	movem.l	d1-d2/a0-a1,-(sp)
	bsr	get_source_addr
	movem.l	(sp)+,d1-d2/a0-a1
	rts

_sizeof_op:
 move.b (a0),d0
 cmp.b #'(',d0
 bne .not_found
 addq.w #1,a0
 move.l a0,a1
.l1:
 move.b (a1)+,d0
 beq.s .error
 cmp.b #')',d0
 bne.s .l1
 subq.w #1,a1
 move.b (a1),-(sp)
 move.l a1,-(sp)
 clr.b (a1)
 moveq #0,d0
 bsr get_var_by_name
 move.l a0,a1
 move.l (sp)+,a0
 move.b (sp)+,(a0)
 addq.w #1,a0
 tst.l d1
 bmi.s .error
 _JSR get_sizeof	;calculer la taille
 move.l d0,d7
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 movem.l d4-d7,-(a4)
 bsr neg_not_management
 move.w #$7f02,d0
 bsr Store_number_size
 sf op_flag(a6)
 sf now_op(a6)
 addq.w #1,token_number(a6)
 sf 3(a4)
.end:
 moveq #0,d0
 rts
.error:
 moveq #-2,d0
 rts
.not_found:
 moveq #-1,d0
 rts

 ENDC	; de sourcedebug
  
;  #] Tokens management:
;  #[ Stacks management:

eval_op:
 lea operators_table,a1
.loop:
 moveq #0,d2
 move.w (a1)+,d0
 beq.s .end_eval
 bmi.s .right_to_left
.left_to_right:
 movem.l a4-a5,-(sp)
 move.l initial_a4(a6),a4
 move.l initial_a5(a6),a5
.1:
 cmp.l 4(sp),a5
 beq.s .token_finished
 move.l -(a5),d1
 cmp.w d0,d1
 bne.s .not_good_token
 move.w d2,-(sp)
 move.l d1,a2
 bsr L_R_Get_numbers
 IFNE Compile
 bsr comp_L_R_Get_numbers
 ENDC
 bsr Proceed_calculation
 bmi _syntax_error			; logical shift,...
 move.w (sp)+,d2
 addq.w #1,d2
 bsr _Update_Stacks
 bra.s .1
.not_good_token:
 lea -24(a4),a4				
 bra.s .1
.token_finished:
 sub.w d2,token_number(a6)
 movem.l (sp)+,a4-a5
 IFNE Compile
 tst.b compile_flag(a6)
 beq.s .no_comp_tf
 bsr comp_token_finished
.no_comp_tf:
 ENDC
 add.w d2,d2
 add.w d2,a5
 add.w d2,a5
 mulu #12,d2				
 add.w d2,a4
 bra.s .loop
.end_eval:
 rts

.right_to_left:
 and.w #$7fff,d0
 movem.l a4-a5,-(sp)
 subq.w #4,a5
.2:
 cmp.l initial_a5(a6),a5
 beq.s .token_finished
 addq.w #4,a5
 move.l (a5),d1
 cmp.w d0,d1
 bne.s .not_good_token
 move.w d2,-(sp)
 move.l d1,a2
 bsr R_L_Get_numbers
 bsr Proceed_calculation
 bmi _syntax_error			; bad affect,...
 move.w (sp)+,d2
 addq.w #1,d2
 bsr _Update_Stacks
 bra.s .2

_Update_Stacks:
 movem.l a4-a5,-(sp)
.1:
 tst.l -4(a5)
 beq.s .2
 move.l -48(a4),d0			
 move.l d0,-24(a4)			
 move.l -44(a4),d0			
 move.l d0,-20(a4)			
 move.l -40(a4),d0			
 move.l d0,-16(a4)			
 move.l -36(a4),d0			
 move.l d0,-12(a4)			
 move.l -32(a4),d0			
 move.l d0,-8(a4)			
 move.l -28(a4),d0			
 move.l d0,-4(a4)			
 sub.w #24,a4				
 subq.w #4,a5
 bra.s .1
.2:
 clr.l -(a4)
 clr.l -(a4)
 clr.l -(a4)
 clr.l -(a4)
 clr.l -(a4)
 clr.l -(a4)				
 move.l 4(sp),a5
.3:
 move.l -(a5),d0
 beq.s .4
 move.l d0,4(a5)
 bra.s .3
.4:
 clr.l (a5)
 movem.l (sp)+,a4-a5
 rts

Proceed_calculation:
 move.l d1,-(sp)
 move.l a2,d1
 swap d1
 add.w d1,d1
 add.w d1,d1
 IFNE Compile
 tst.b compile_flag(a6)
 beq.s .no_comp_proceed
 lea .operations(pc),a2
 add.w d1,a2
 exg a2,d0
 bsr comp_put_bsr
 exg a2,d0
.no_comp_proceed:
 ENDC
 move.l d1,a2
 move.l (sp)+,d1
 jmp .operations(pc,a2.w)
.operations:
 _NOOPTI
 bra _eval_plus				; 0
 bra _eval_error			; 1
 bra _eval_error			; 2
 bra _eval_minus			; 3
 bra _eval_error			; 4
 bra _eval_error			; 5
 bra _eval_mulu				; 6
 bra _eval_divu				; 7
 bra _eval_and				; 8
 bra _eval_logand			; 9
 bra _eval_or				; $a
 bra _eval_logor			; $b
 bra _eval_eor				; $c
 bra _eval_inf				; $d
 bra _eval_infequal			; $e
 bra _eval_lsl				; $f
 bra _eval_sup				; $10
 bra _eval_supequal			; $11
 bra _eval_lsr				; $12
 bra _eval_affect			; $13
 bra _eval_equal			; $14
 bra _eval_different			; $15
 bra _eval_plus_equal			; $16
 bra _eval_minus_equal			; $17
 bra _eval_mulu_equal			; $18
 bra _eval_divu_equal			; $19
 bra _eval_not_equal			; $1a
 bra _eval_lsl_equal			; $1b
 bra _eval_lsr_equal			; $1c
 bra _eval_and_equal			; $1d
 bra _eval_or_equal			; $1e
 bra _eval_eor_equal			; $1f
 _OPTI

_eval_plus:
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr INC_DEC
 bsr ADD
 sf evaluating_pre(a6)
 st evaluating_post(a6)
 bsr INC_DEC
 movem.l d4-d7,-(a4)
 move.w #$7f06,d0
 bsr Store_number_size
 sf 3(a4)
 moveq #0,d0
 rts

_eval_error:
 moveq #-1,d0
 movem.l d4-d7,-(a4)
 moveq #6,d0
 bsr Store_number_size
 sf 3(a4)
 moveq #-1,d0
 rts

_eval_minus:
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr INC_DEC
 bsr SUB
 sf evaluating_pre(a6)
 st evaluating_post(a6)
 bsr INC_DEC
 movem.l d4-d7,-(a4)
 move.w #$7f06,d0
 bsr Store_number_size
 sf 3(a4)
 moveq #0,d0
 rts

_eval_mulu:
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr INC_DEC
 bsr MULU
 sf evaluating_pre(a6)
 st evaluating_post(a6)
 bsr INC_DEC
 movem.l d4-d7,-(a4)
 move.w #$7f06,d0
 bsr Store_number_size
 sf 3(a4)
 moveq #0,d0
 rts

_eval_divu:
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr INC_DEC
 bsr DIVU
 bmi.s .error
 sf evaluating_pre(a6)
 st evaluating_post(a6)
 bsr INC_DEC
 movem.l d4-d7,-(a4)
 move.w #$7f06,d0
 bsr Store_number_size
 sf 3(a4)
 moveq #0,d0
 rts
.error:
 moveq #-1,d0
 rts

_eval_and:
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr INC_DEC
 bsr AND
 sf evaluating_pre(a6)
 st evaluating_post(a6)
 bsr INC_DEC
 movem.l d4-d7,-(a4)
 move.w #$7f06,d0
 bsr Store_number_size
 sf 3(a4)
 moveq #0,d0
 rts

_eval_logand:
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr INC_DEC
 bsr LOG_AND
 sf evaluating_pre(a6)
 st evaluating_post(a6)
 bsr INC_DEC
 movem.l d4-d7,-(a4)
 move.w #$7f06,d0
 bsr Store_number_size
 sf 3(a4)
 moveq #0,d0
 rts

_eval_or:
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr INC_DEC
 bsr OR
 sf evaluating_pre(a6)
 st evaluating_post(a6)
 bsr INC_DEC
 movem.l d4-d7,-(a4)
 move.w #$7f06,d0
 bsr Store_number_size
 sf 3(a4)
 moveq #0,d0
 rts

_eval_logor:
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr INC_DEC
 bsr LOG_OR
 sf evaluating_pre(a6)
 st evaluating_post(a6)
 bsr INC_DEC
 movem.l d4-d7,-(a4)
 move.w #$7f06,d0
 bsr Store_number_size
 sf 3(a4)
 moveq #0,d0
 rts

_eval_eor:
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr INC_DEC
 bsr EOR
 sf evaluating_pre(a6)
 st evaluating_post(a6)
 bsr INC_DEC
 movem.l d4-d7,-(a4)
 move.w #$7f06,d0
 bsr Store_number_size
 sf 3(a4)
 moveq #0,d0
 rts

_eval_inf:
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr INC_DEC
 bsr INF
 sf evaluating_pre(a6)
 st evaluating_post(a6)
 bsr INC_DEC
 movem.l d4-d7,-(a4)
 move.w #$7f06,d0
 bsr Store_number_size
 sf 3(a4)
 moveq #0,d0
 rts

_eval_infequal:
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr INC_DEC
 bsr INF_EQUAL
 sf evaluating_pre(a6)
 st evaluating_post(a6)
 bsr INC_DEC
 movem.l d4-d7,-(a4)
 move.w #$7f06,d0
 bsr Store_number_size
 sf 3(a4)
 moveq #0,d0
 rts

_eval_lsl:
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr INC_DEC
 bsr LSL
 bmi.s .error
 sf evaluating_pre(a6)
 st evaluating_post(a6)
 bsr INC_DEC
 movem.l d4-d7,-(a4)
 move.w #$7f06,d0
 bsr Store_number_size
 sf 3(a4)
 moveq #0,d0
 rts
.error:
 moveq #-1,d0
 rts

_eval_sup:
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr INC_DEC
 bsr SUP
 sf evaluating_pre(a6)
 st evaluating_post(a6)
 bsr INC_DEC
 movem.l d4-d7,-(a4)
 move.w #$7f06,d0
 bsr Store_number_size
 sf 3(a4)
 moveq #0,d0
 rts

_eval_supequal:
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr INC_DEC
 bsr SUP_EQUAL
 sf evaluating_pre(a6)
 st evaluating_post(a6)
 bsr INC_DEC
 movem.l d4-d7,-(a4)
 move.w #$7f06,d0
 bsr Store_number_size
 sf 3(a4)
 moveq #0,d0
 rts

_eval_lsr:
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr INC_DEC
 bsr LSR
 bmi.s .error
 sf evaluating_pre(a6)
 st evaluating_post(a6)
 bsr INC_DEC
 movem.l d4-d7,-(a4)
 move.w #$7f06,d0
 bsr Store_number_size
 sf 3(a4)
 moveq #0,d0
 rts
.error:
 moveq #-1,d0
 rts

_eval_affect:
 movem.l a1-a2,-(sp)
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr INC_DEC
 bsr AFFECT
 bmi.s .error
 sf evaluating_pre(a6)
 st evaluating_post(a6)
 movem.l d4-d7,-16(a4)
 bsr INC_DEC
 movem.l d4-d7,-(a4)
 move.w #$7f06,d0
 bsr Store_number_size
 movem.l (sp)+,a1-a2
 sf 3(a4)
 moveq #0,d0
 rts
.error:
 movem.l (sp)+,a1-a2
 moveq #-1,d0
 rts

_eval_equal:
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr INC_DEC
 bsr EQUAL
 sf evaluating_pre(a6)
 st evaluating_post(a6)
 bsr INC_DEC
 movem.l d4-d7,-(a4)
 move.w #$7f06,d0
 bsr Store_number_size
 sf 3(a4)
 moveq #0,d0
 rts

_eval_different:
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr INC_DEC
 bsr DIFFERENT
 sf evaluating_pre(a6)
 st evaluating_post(a6)
 bsr INC_DEC
 movem.l d4-d7,-(a4)
 move.w #$7f06,d0
 bsr Store_number_size
 sf 3(a4)
 moveq #0,d0
 rts

_eval_plus_equal:
 movem.l a1-a2,-(sp)
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr INC_DEC
 bsr ADD
 bsr AFFECT
internal_x_equal:
 bmi.s .error
 sf evaluating_pre(a6)
 st evaluating_post(a6)
 movem.l d4-d7,-16(a4)
 bsr INC_DEC
 movem.l d4-d7,-(a4)
 move.w #$7f06,d0
 bsr Store_number_size
 movem.l (sp)+,a1-a2
 sf 3(a4)
 moveq #0,d0
 rts
.error:
 movem.l (sp)+,a1-a2
 moveq #-1,d0
 rts

_eval_minus_equal:
 movem.l a1-a2,-(sp)
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr INC_DEC
 bsr SUB
 bsr AFFECT
 bra.s internal_x_equal

_eval_mulu_equal:
 movem.l a1-a2,-(sp)
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr INC_DEC
 bsr MULU
 bsr AFFECT
 bra.s internal_x_equal

_eval_divu_equal:
 movem.l a1-a2,-(sp)
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr INC_DEC
 bsr DIVU
 bmi internal_x_equal
 bsr AFFECT
 bra internal_x_equal

_eval_not_equal:
 movem.l a1-a2,-(sp)
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr INC_DEC
 bsr NOT
 bsr AFFECT
 bra internal_x_equal

_eval_lsl_equal:
 movem.l a1-a2,-(sp)
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr INC_DEC
 bsr LSL
 bmi internal_x_equal
 bsr AFFECT
 bra internal_x_equal

_eval_lsr_equal:
 movem.l a1-a2,-(sp)
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr INC_DEC
 bsr LSR
 bmi internal_x_equal
 bsr AFFECT
 bra internal_x_equal

_eval_and_equal:
 movem.l a1-a2,-(sp)
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr INC_DEC
 bsr AND
 bmi internal_x_equal
 bsr AFFECT
 bra internal_x_equal

_eval_or_equal:
 movem.l a1-a2,-(sp)
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr INC_DEC
 bsr OR
 bmi internal_x_equal
 bsr AFFECT
 bra internal_x_equal

_eval_eor_equal:
 movem.l a1-a2,-(sp)
 st evaluating_pre(a6)
 sf evaluating_post(a6)
 bsr INC_DEC
 bsr EOR
 bmi internal_x_equal
 bsr AFFECT
 bra internal_x_equal

;  #] Stacks management:
;  #[ Numbers management:

Extract_number:
 movem.l d0-d1/a1-a3,-(sp)
 lea evaluator_buffer(a6),a2
 lea	tokens_table,a3
.next_char:
 moveq	#0,d0
 move.b (a0)+,d0
 move.b	d0,d1
 beq.s	.end
 cmp.b	#';',d1
 beq.s	.end
 add.w	d0,d0
 add.w	d0,d0
 tst.l	0(a3,d0.w)
 bne.s	.end
 move.b	d1,(a2)+
 bra.s .next_char
.end:
 clr.b (a2)
 subq.w #1,a0
 movem.l (sp)+,d0-d1/a1-a3
 rts

Extract_block_name:
 lea evaluator_buffer(a6),a2
.loop:
 move.b (a0)+,d0
 beq.s .error
 cmp.b #')',d0
 beq.s .end
 move.b d0,(a2)+
 bra.s .loop
.end:
 clr.b (a2)
 moveq #0,d0
 rts
.error:
 moveq #-1,d0
 rts

Extract_string:
 move.b (a0)+,d0
.loop:
 move.b (a0)+,d1
 beq _syntax_error
 cmp.b d0,d1
 beq.s .end_extract_string
 move.b d1,(a1)+
 addq.w #1,d2
 bra.s .loop
.end_extract_string:
 clr.b (a1)
 rts

Store_number_size:
 clr.l -(a4)
 clr.l -(a4)
 ror.l #8,d0
 move.b d0,1(a4)
 swap d0
 and.w #$0f00,d0
 or.w d0,2(a4)				
 tst.b preinc_flag(a6)
 beq.s .no_preinc
.preinc:
 or.b #$80,2(a4)
.no_preinc:
 tst.b predec_flag(a6)
 beq.s .no_predec
.predec:
 or.b #$20,2(a4)
.no_predec:
 move.w C_ind_counter(a6),d3
 beq.s .not_C_indirection
 cmp.b #2,2(a4)
 bne.s .error
.C_indirection:
 subq.w #1,d3
 bmi.s .not_C_indirection
;
 move.l a2,-(sp)
 move.l 20(a4),a2
 move.b (a2),20(a4)
 move.b 1(a2),21(a4)
 move.b 2(a2),22(a4)
 move.b 3(a2),23(a4)
 move.l (sp)+,a2
 clr.l 4(a4)
;
 bra.s .C_indirection
.not_C_indirection:
 clr.w C_ind_counter(a6)
 sf preinc_flag(a6)
 sf predec_flag(a6)
 rts
.error:
 addq.w #4,sp
 bra _syntax_error

R_L_Get_numbers:
 lea 48(a4),a4

L_R_Get_numbers:
 move.l -24(a4),eval_tmp1(a6)
 move.l -20(a4),eval_tmp2(a6)
 movem.l -16(a4),d0-d3
 move.l -48(a4),eval_tmp1bis(a6)
 move.l -44(a4),eval_tmp2bis(a6)
 movem.l -40(a4),d4-d7
 rts

;  #] Numbers management:
;  #[ Conversion management:

Convert_binary_string:
 movem.l d1-d2/a1,-(sp)
 lea evaluator_buffer(a6),a1
 moveq #0,d0
 moveq #0,d1
 move.w #128,d2
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 moveq #0,d7
.loop:
 move.b (a1)+,d0
 beq.s .end
 sub.w #'0',d0
 bmi.s .error
 cmp.w #1,d0
 bgt.s .error
 roxr.w #1,d0
 addx.l d7,d7
 addx.l d6,d6
 addx.l d5,d5
 addx.l d4,d4
 addq.w #1,d1
 dbf d2,.loop
 bra.s .error
.end:
 swap d1
 lsr.l #5,d1
 tst.w d1
 beq.s .really_end
 add.l #$00010000,d1
.really_end:
 swap d1
 move.w d1,d0
 movem.l (sp)+,d1-d2/a1
 rts
.error:
 moveq #-1,d0
 movem.l (sp)+,d1-d2/a1
 rts

Convert_octal_string:
 movem.l d1-d2/a1,-(sp)
 lea evaluator_buffer(a6),a1
 moveq #0,d0
 moveq #0,d1
 moveq #42,d2
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 moveq #0,d7
.loop:
 move.b (a1)+,d0
 beq.s .end
 sub.w #'0',d0
 bmi.s .error
 cmp.w #7,d0
 bgt.s .error
.no_error:
 lsl.b #5,d0 
 rept 3
 roxl.b #1,d0
 addx.l d7,d7
 addx.l d6,d6
 addx.l d5,d5
 addx.l d4,d4
 endr
 addq.w #3,d1
 dbf d2,.loop
 bra.s .error
.end:
 swap d1
 lsr.l #5,d1
 tst.w d1
 beq.s .really_end
 add.l #$00010000,d1
.really_end:
 swap d1
 move.w d1,d0
 movem.l (sp)+,d1-d2/a1
 rts
.error:
 moveq #-1,d0
 movem.l (sp)+,d1-d2/a1
 rts

Convert_decimal_string:
 movem.l d1-d3/a1-a2,-(sp)
 lea evaluator_buffer(a6),a1
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 moveq #0,d7
.loop:
 moveq #0,d0
 move.b (a1)+,d0
 beq.s .end
 sub.w #'0',d0
 bmi.s .error
 cmp.w #9,d0
 bgt.s .error
 move.w d0,a2
 add.l d4,d4
 addx.l d5,d5
 addx.l d6,d6
 addx.l d7,d7
 move.l d4,d0
 move.l d5,d1
 move.l d6,d2
 move.l d7,d3
 rept 2
 add.l d4,d4
 addx.l d5,d5
 addx.l d6,d6
 addx.l d7,d7
 endr
 add.l d3,d7
 addx.l d2,d6
 addx.l d1,d5
 addx.l d0,d4
 moveq #0,d0
 moveq #0,d1
 move.w a2,d0
 add.l d0,d7
 addx.l d1,d6
 addx.l d1,d5
 addx.l d1,d4
 bra .loop
.end:
 moveq #0,d0
 movem.l (sp)+,d1-d3/a1-a2
 rts
.error:
 moveq #-1,d0
 movem.l (sp)+,d1-d3/a1-a2
 rts

Convert_hexa_string:
 movem.l d1-d2/a1-a2,-(sp)
 lea evaluator_buffer(a6),a1
 lea .hextab(pc),a2
 moveq #0,d0
 moveq #0,d1
 moveq #32,d2
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 moveq #0,d7
.loop:
 move.b (a1)+,d0
 ble.s .end
 move.b 0(a2,d0.w),d0
 bmi.s .error
.no_error:
 lsl.b #4,d0 
 rept 4
 roxl.b #1,d0
 addx.l d7,d7
 addx.l d6,d6
 addx.l d5,d5
 addx.l d4,d4
 endr
 addq.w #4,d1
 dbf d2,.loop
 bra.s .error
.end:
 bmi.s .error
 swap d1
 lsr.l #5,d1
 tst.w d1
 beq.s .really_end
 add.l #$00010000,d1
.really_end:
 swap d1
 move.w d1,d0
 movem.l (sp)+,d1-d2/a1-a2
 rts
.error:
 moveq #-1,d0
 movem.l (sp)+,d1-d2/a1-a2
 rts

.hextab:
 dc.b -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
 dc.b -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
 dc.b -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
 dc.b +0,+1,+2,+3,+4,+5,+6,+7,+8,+9,-1,-1,-1,-1,-1,-1
 dc.b -1,10,11,12,13,14,15,-1,-1,-1,-1,-1,-1,-1,-1,-1
 dc.b -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
 dc.b -1,10,11,12,13,14,15,-1,-1,-1,-1,-1,-1,-1,-1,-1
 dc.b -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1

_Convert_format:
 movem.l 8(a4),d4-d7			
 move.w 2(a4),d1			
 lsr.w #8,d1
 and.w #$f,d1
 btst #3,d1
 bne.s .error
 cmp.w d0,d1
 bge.s .Reduce_number

.Extend_number:
 move.b d0,d0
 rts

.Reduce_number:
 subq.w #6,d1
 neg.w d1
 add.w d1,d1
 add.w d1,d1
 jmp .reduce(pc,d1.w)
.reduce:
 _NOOPTI
 bsr _packed_to_extended
 bsr _extended_to_double
 bsr _double_to_single
 bsr _single_to_long
 bsr _long_to_word
 bsr _word_to_byte
 _OPTI
 movem.l d4-d7,8(a4)
 move.b d0,d0
 rts

.error:
 moveq #-1,d0
 rts

_byte_to_word:
 cmp.w #1,d0
 blt.s .end
 ext.w d7
.end:
 rts

_word_to_long:
 cmp.w #2,d0
 blt.s .end
 ext.l d7
.end:
 rts

_long_to_single:
 rts

_single_to_double:
 cmp.w #4,d0
 blt.s .end
 moveq #0,d6
 btst #31,d7
 beq.s .end
 not.l d6
.end:
 rts

_double_to_extended:
 cmp.w #5,d0
 blt.s .end
 moveq #0,d5
 btst #31,d6
 beq.s .end
 moveq #-1,d5
.end:
 rts

_extended_to_packed:
 rts

_packed_to_extended:
 rts

_extended_to_double:
 cmp.w #5,d0
 bge.s .end
 moveq #0,d4
 moveq #0,d5
.end:
 rts

_double_to_single:
 cmp.w #4,d0
 bge.s .end
 moveq #0,d6
.end:
 rts

_single_to_long:
 rts

_long_to_word:
 cmp.w #2,d0
 bge.s .end
 and.l #$ffff,d7
.end:
 rts

_word_to_byte:
 cmp.w #1,d0
 bge.s .end
 and.w #$ff,d7
.end:
 rts

;  #] Conversion management:
;  #[ 128 bits operations:
;  #[ 128 bits ADD:

; IN:	d0->d3: number1
;	d4->d7: number2
; OUT:	d4->d7: number1+number2
ADD:
 movem.l a0-a1,-(sp)
 lea _128_bits_buffer2+$10(a6),a0
 movem.l d0-d7,-(a0)
 move.l a0,a1
 lea $10(a0),a0
 lea $20(a1),a1
 and.w #0,ccr
 rept 4
 addx.l -(a0),-(a1)
 endr
 movem.l (a1)+,d4-d7
 movem.l (sp)+,a0-a1
 rts

;  #] 128 bits ADD:
;  #[ 128 bits SUB:

; IN:	d0->d3: number1
;	d4->d7: number2
; OUT:	d4->d7: number1-number2
SUB:
 movem.l a0-a1,-(sp)
 lea _128_bits_buffer2+$10(a6),a0
 movem.l d0-d7,-(a0)
 move.l a0,a1
 lea $10(a0),a0
 lea $20(a1),a1
 and.w #0,ccr
 rept 4
 subx.l -(a1),-(a0)
 endr
 movem.l (a0)+,d4-d7
 movem.l (sp)+,a0-a1
 rts

;  #] 128 bits SUB:
;  #[ 128 bits MULU:

; IN:	d0->d3: number1
;	d4->d7: number2
; OUT:	d4->d7: number1*number2
MULU:
 movem.l d0-d3/a0-a1,-(sp)
 lea _128_bits_buffer1(a6),a0
 movem.l d4-d7,(a0)
 lea $10(a0),a0
 movem.l d4-d7,(a0)
 lea _128_bits_buffer3(a6),a0
 rept 4
 clr.l (a0)+
 endr
 move.l d3,d4
 bsr.s .32_128_mul
 move.l d2,d4
 bsr.s .32_128_mul
 move.l d1,d4
 bsr.s .32_128_mul
 move.l d0,d4
 bsr.s .32_128_mul
 lea _128_bits_buffer3(a6),a0
 movem.l (a0)+,d4-d7
 movem.l (sp)+,d0-d3/a0-a1
 rts

.32_128_mul:
 moveq #31,d7
.loop:
 asr.l #1,d4
 bcc.s .bit_clr
.bit_set:
 bsr.s .internal_add
.bit_clr:
 bsr.s .internal_mul
 dbf d7,.loop
 rts

.internal_add:
 lea _128_bits_buffer1+$10(a6),a0
 lea _128_bits_buffer3+$10(a6),a1
 and.w #0,ccr
 rept 4
 addx.l -(a0),-(a1)
 endr
 rts

.internal_mul:
 lea _128_bits_buffer1+$10(a6),a0
 lea _128_bits_buffer2+$10(a6),a1
 and.w #0,ccr
 rept 4
 addx.l -(a1),-(a0)
 endr
 rept 4
 move.l (a0)+,(a1)+
 endr
 rts

;  #] 128 bits MULU:
;  #[ 128 bits DIVU:

; IN:	d0->d3: number1
;	d4->d7: number2
; OUT:	d4->d7: number1/number2
DIVU:
 movem.l a1-a3,-(sp)
 tst.l d4
 bne.s .not_null
 tst.l d5
 bne.s .not_null
 tst.l d6
 bne.s .not_null
 tst.l d7
 beq .error
.not_null:
 lea _128_bits_buffer1(a6),a1
 rept 4
 clr.l (a1)+
 endr
 lea _128_bits_buffer2(a6),a2
 rept 4
 clr.l (a2)+
 endr
 lea _128_bits_buffer3(a6),a3
 rept 4
 clr.l (a3)+
 endr
 move.w #$7f,-(sp)
.loop:
 and #0,ccr
 rept 4
 move.l -(a1),-(a2)
 endr
 lea 16(a1),a1
 lea 16(a2),a2
 and #0,ccr
 rept 4
 addx.l -(a2),-(a1)
 endr
 lea 16(a1),a1
 lea 16(a2),a2
 and #0,ccr
 lsl.l #1,d3
 roxl.l #1,d2
 roxl.l #1,d1
 roxl.l #1,d0
 rept 8
 roxl.w -(a3)
 endr
 lea 16(a3),a3
 cmp.l -16(a3),d4
 bhi.s .bit_clear
 cmp.l -12(a3),d5
 bhi.s .bit_clear
 cmp.l -8(a3),d6
 bhi.s .bit_clear
 cmp.l -4(a3),d7
 bhi.s .bit_clear
.bit_set:
 rept 3
 addq.l #1,-(a1)
 bcc.s .end_add
 endr
 addq.l #1,-(a1)
.end_add:
 lea _128_bits_buffer1+16(a6),a1
 movem.l d0-d3,-(sp)
 lea -16(a3),a3
 movem.l (a3)+,d0-d3
 and #0,ccr
 subx.l d7,d3
 subx.l d6,d2
 subx.l d5,d1
 subx.l d4,d0
 movem.l d0-d3,-(a3)
 movem.l (sp)+,d0-d3
 lea 16(a3),a3
.bit_clear:
 subq.w #1,(sp)
 bpl .loop
.end:
 addq.w #2,sp
 lea -16(a1),a1
 movem.l (a1),d4-d7
 movem.l (sp)+,a1-a3
 moveq #0,d0
 rts
.error:
 movem.l (sp)+,a1-a3
 moveq #-1,d0
 rts

;  #] 128 bits DIVU:
;  #[ 128 bits AND:

; IN:	d0->d3: number1
;	d4->d7: number2
; OUT:	d4->d7: number1&number2
AND:
 and.l d0,d4
 and.l d1,d5
 and.l d2,d6
 and.l d3,d7
 rts

;  #] 128 bits AND:
;  #[ 128 bits OR:

; IN:	d0->d3: number1
;	d4->d7: number2
; OUT:	d4->d7: number1|number2
OR:
 or.l d0,d4
 or.l d1,d5
 or.l d2,d6
 or.l d3,d7
 rts

;  #] 128 bits OR:
;  #[ 128 bits EOR:

; IN:	d0->d3: number1
;	d4->d7: number2
; OUT:	d4->d7: number1^number2
EOR:
 eor.l d0,d4
 eor.l d1,d5
 eor.l d2,d6
 eor.l d3,d7
 rts

;  #] 128 bits EOR:
;  #[ 128 bits LSL:

; IN:	d0->d3: number1
;	d4->d7: number2
; OUT:	d4->d7: number1<<number2
LSL:
 tst.l d4
 bne.s .overflow
 tst.l d5
 bne.s .overflow
 tst.l d6
 bne.s .overflow
 cmp.l #128,d7
 exg.l d0,d4
 exg.l d1,d5
 exg.l d2,d6
 exg.l d3,d7
 bgt.s .overflow
 subq.w #1,d3
 bmi.s .end
.logical_left:
 and.w #0,ccr
 addx.l d7,d7
 addx.l d6,d6
 addx.l d5,d5
 addx.l d4,d4
 dbf d3,.logical_left
.end:
 rts
.overflow:
;
;
 rts

;  #] 128 bits LSL:
;  #[ 128 bits LSR:

; IN:	d0->d3: number1
;	d4->d7: number2
; OUT:	d4->d7: number1>>number2
LSR:
 tst.l d4
 bne.s .overflow
 tst.l d5
 bne.s .overflow
 tst.l d6
 bne.s .overflow
 cmp.l #128,d7
 bgt.s .overflow
 exg.l d0,d4
 exg.l d1,d5
 exg.l d2,d6
 exg.l d3,d7
 subq.w #1,d3
 bmi.s .end
.logical_right:
 and.w #0,ccr
 roxr.l #1,d4
 roxr.l #1,d5
 roxr.l #1,d6
 roxr.l #1,d7
 dbf d3,.logical_right
.end:
 rts
.overflow:
;
;
 rts

;  #] 128 bits LSR:
;  #[ 128 bits Inf:

; IN:	d0->d3: number1
;	d4->d7: number2
; OUT:	d4->d7: -1/0 (true/false)
INF:
 cmp.l d0,d4
 bhi.s .true
 cmp.l d1,d5
 bhi.s .true
 cmp.l d2,d6
 bhi.s .true
 cmp.l d3,d7
 bhi.s .true
.false:
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 moveq #0,d7
 rts
.true:
 moveq #-1,d4
 moveq #-1,d5
 moveq #-1,d6
 moveq #-1,d7
 rts

;  #] 128 bits Inf:
;  #[ 128 bits Sup:

; IN:	d0->d3: number1
;	d4->d7: number2
; OUT:	d4->d7: -1/0 (true/false)
SUP:
 cmp.l d4,d0
 bhi.s .true
 cmp.l d5,d1
 bhi.s .true
 cmp.l d6,d2
 bhi.s .true
 cmp.l d7,d3
 bhi.s .true
.false:
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 moveq #0,d7
 rts
.true:
 moveq #-1,d4
 moveq #-1,d5
 moveq #-1,d6
 moveq #-1,d7
 rts

;  #] 128 bits Sup:
;  #[ 128 bits Inf equal:

; IN:	d0->d3: number1
;	d4->d7: number2
; OUT:	d4->d7: -1/0 (true/false)
INF_EQUAL:
 cmp.l d0,d4
 bhi.s .true
 cmp.l d1,d5
 bhi.s .true
 cmp.l d2,d6
 bhi.s .true
 cmp.l d3,d7
 bhi.s .true
 beq.s .true
.false:
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 moveq #0,d7
 rts
.true:
 moveq #-1,d4
 moveq #-1,d5
 moveq #-1,d6
 moveq #-1,d7
 rts

;  #] 128 bits Inf equal:
;  #[ 128 bits Sup equal:

; IN:	d0->d3: number1
;	d4->d7: number2
; OUT:	d4->d7: -1/0 (true/false)
SUP_EQUAL:
 cmp.l d4,d0
 bhi.s .true
 cmp.l d5,d1
 bhi.s .true
 cmp.l d6,d2
 bhi.s .true
 cmp.l d7,d3
 bhi.s .true
 beq.s .true
.false:
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 moveq #0,d7
 rts
.true:
 moveq #-1,d4
 moveq #-1,d5
 moveq #-1,d6
 moveq #-1,d7
 rts

;  #] 128 bits Sup equal:
;  #[ 128 bits Equal:

; IN:	d0->d3: number1
;	d4->d7: number2
; OUT:	d4->d7: -1/0 (true/false)
EQUAL:
 cmp.l d0,d4
 bne.s .false
 cmp.l d1,d5
 bne.s .false
 cmp.l d2,d6
 bne.s .false
 cmp.l d3,d7
 bne.s .false
.true:
 moveq #-1,d4
 moveq #-1,d5
 moveq #-1,d6
 moveq #-1,d7
 rts
.false:
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 moveq #0,d7
 rts

;  #] 128 bits Equal:
;  #[ 128 bits Different:

; IN:	d0->d3: number1
;	d4->d7: number2
; OUT:	d4->d7: -1/0 (true/false)
DIFFERENT:
 cmp.l d0,d4
 bne.s .true
 cmp.l d1,d5
 bne.s .true
 cmp.l d2,d6
 bne.s .true
 cmp.l d3,d7
 bne.s .true
.false:
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 moveq #0,d7
 rts
.true:
 moveq #-1,d4
 moveq #-1,d5
 moveq #-1,d6
 moveq #-1,d7
 rts

;  #] 128 bits Different:
;  #[ 128 bits Affect:

; IN:	d0->d3: number1
;	d4->d7: number2
; OUT:	d4->d7: number2
AFFECT:
 move.b eval_tmp1+3(a6),d0
 beq .may_be_error
 bpl .register_affect
 cmp.b #-1,d0
 beq .memory_affect 
 cmp.b #-2,d0
 beq.s .variable_affect
 bra .error				; routine affect...

.variable_affect:
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 move.l a0,-(sp)
 move.l eval_tmp2(a6),a0
 bsr Extract_number
 lea evaluator_buffer(a6),a2
 moveq #-1,d0
 moveq #0,d1
 movem.l a0-a2,-(sp)
 bsr find_in_table
 movem.l (sp)+,a0-a2
 move.l d1,d3
 lea evaluator_buffer(a6),a0
 move.b eval_tmp1+2(a6),d0
 and.w #7,d0
 beq.s .var_byte_affect
 cmp.w #1,d0
 beq.s .var_word_affect
 cmp.w #2,d0
 beq .var_long_affect
 move.l (sp)+,a0
 bra .error

.var_byte_affect:
 move.w #LAWORD,d0
 and.l #$ff,d7
 and.l #$ffffff00,d3
 or.l d3,d7
 move.l d7,a1
 bsr put_in_table
 tst.l d0
 movem.l (sp)+,a0
 bpl.s .end
 move.l a0,-(sp)
 lea evaluator_buffer(a6),a0
 move.w #EQWORD,d0
 move.l d7,a1
 bsr put_in_table
 tst.l d0
 movem.l (sp)+,a0
 bmi .error
.end:
 moveq #0,d0
 rts

.var_word_affect:
 move.w #LAWORD,d0
 and.l #$ffff,d7
 and.l #$ffff0000,d3
 or.l d3,d7
 move.l d7,a1
 bsr put_in_table
 tst.l d0
 movem.l (sp)+,a0
 bpl.s .end
 move.l a0,-(sp)
 lea evaluator_buffer(a6),a0
 move.w #EQWORD,d0
 move.l d7,a1
 bsr put_in_table
 tst.l d0
 movem.l (sp)+,a0
 bmi .error
 bra .end

.var_long_affect:
 move.w #LAWORD,d0
 move.l d7,a1
 bsr put_in_table
 tst.l d0
 movem.l (sp)+,a0
 bpl.s .end
 move.l a0,-(sp)
 lea evaluator_buffer(a6),a0
 move.w #EQWORD,d0
 move.l d7,a1
 bsr put_in_table
 tst.l d0
 movem.l (sp)+,a0
 bmi .error
 bra .end

.register_affect:
 ext.w d0
 subq.w #1,d0
 add.w d0,d0
 add.w d0,d0
 jmp .reg_affect(pc,d0.w)
.reg_affect:
 _NOOPTI
 bra .long_affect				; D0
 bra .long_affect				; D1
 bra .long_affect				; D2
 bra .long_affect				; D3
 bra .long_affect				; D4
 bra .long_affect				; D5
 bra .long_affect				; D6
 bra .long_affect				; D7
 bra .long_affect				; A0
 bra .long_affect				; A1
 bra .long_affect				; A2
 bra .long_affect				; A3
 bra .long_affect				; A4
 bra .long_affect				; A5
 bra .long_affect				; A6
 bra .long_affect				; A7
 bra .long_affect				; VBR
 bra .long_affect				; ISP
 bra .long_affect				; MSP
 bra .long_affect				; SSP
 bra .long_affect				; SP
 bra .word_affect				; SR
 bra .long_affect				; PC
 bra .byte_affect				; CCR
 bra .long_affect				; CACR
 bra .long_affect				; CAAR
 bra .byte_affect				; SFC
 bra .byte_affect				; DFC
 bra .long_affect				; TC
 bra .double_affect				; CRP
 bra .double_affect				; SRP
 bra .long_affect				; TT0
 bra .long_affect				; TT1
 bra .word_affect				; MMUSR
 bra .packed_affect				; FP0
 bra .packed_affect				; FP1
 bra .packed_affect				; FP2
 bra .packed_affect				; FP3
 bra .packed_affect				; FP4
 bra .packed_affect				; FP5
 bra .packed_affect				; FP6
 bra .packed_affect				; FP7
 bra .word_affect				; FPCR
 bra .long_affect				; FPSR
 bra .long_affect				; FPIAR
 bra .long_affect				; W1
 bra .long_affect				; W2
 bra .long_affect				; W3
 bra .long_affect				; W4
 bra .long_affect				; W5
 bra .long_affect				; CW
 _OPTI

.byte_affect:
 move.l eval_tmp2(a6),a1
 move.b d7,(a1)
 bra .it_was_byte

.word_affect:
 move.l eval_tmp2(a6),a1
 move.b eval_tmp1+2(a6),d0
 and.w #7,d0
 beq.s .word_b
.word_w:
 move.w d7,(a1)
 bra .it_was_word
.word_b:
 move.b d7,1(a1)
 bra .it_was_byte

.long_affect:
 cmp.w #(_W1*4)-4,d0
 blt.s .no_window_affect
 cmp.w #(_CW*4)-4,d0
 bgt.s .no_window_affect
 move.l eval_tmp2(a6),a1
 move.b eval_tmp1+2(a6),d0
 and.w #7,d0
 beq.s .long_window_b
 cmp.b #1,d0
 beq.s .long_window_w
.long_window_l:
 move.l d7,(a1)
 move.l d7,window_buffer+$a(a6)
 bra .it_was_long
.long_window_w:
 move.w d7,2(a1)
 move.w d7,window_buffer+$a(a6)
 bra .it_was_word
.long_window_b:
 move.b d7,3(a1)
 move.b d7,window_buffer+$a(a6)
 bra .it_was_byte
.no_window_affect:

 cmp.w #(_SP*4)-4,d0
 bne.s .no_sp_affect
.sp_affect:
 lea a7_buf(a6),a2
 btst #5,sr_buf(a6)
 beq.s .after_stack_test
 bra.s .ssp_affect
.no_sp_affect:

 cmp.w #(_SSP*4)-4,d0
 bne.s .no_ssp_affect
.ssp_affect: 
 move.w #(_ISP*4)-4,d0
 btst #4,sr_buf(a6)
 beq.s .no_ssp_affect
 move.w #(_MSP*4)-4,d0
.no_ssp_affect:

 move.l eval_tmp2(a6),a2
 cmp.w #(_ISP*4)-4,d0
 beq.s .isp_affect
 cmp.w #(_MSP*4)-4,d0
 bne.s .no_xsp_affect
.msp_affect:
 btst #4,sr_buf(a6)
 beq.s .after_stack_test
 lea ssp_buf(a6),a2
 bra.s .after_stack_test
.isp_affect:
 btst #4,sr_buf(a6)
 bne.s .after_stack_test
 lea ssp_buf(a6),a2
.after_stack_test:

 move.l eval_tmp2(a6),a1
 move.b eval_tmp1+2(a6),d0
 and.w #7,d0
 beq.s .xsp_long_b
 cmp.b #1,d0
 beq.s .xsp_long_w
.xsp_long_l:
 move.l d7,(a1)
 move.l d7,(a2)
 bra .it_was_long
.xsp_long_w:
 move.w d7,2(a1)
 move.w d7,2(a2)
 bra .it_was_word
.xsp_long_b:
 move.b d7,3(a1)
 move.b d7,3(a2)
 bra .it_was_byte

.no_xsp_affect:
 cmp.w #(_PC*4)-4,d0
 bne.s .no_pc_affect
 st relock_pc_flag(a6)			;;;;
.no_pc_affect:
 move.l eval_tmp2(a6),a1
 move.b eval_tmp1+2(a6),d0
 and.w #7,d0
 beq.s .long_b
 cmp.b #1,d0
 beq.s .long_w
.long_l:
 move.l d7,(a1)
 bra .it_was_long
.long_w:
 move.w d7,2(a1)
 bra .it_was_word
.long_b:
 move.b d7,3(a1)
 bra .it_was_byte

.double_affect:
 move.l eval_tmp2(a6),a1
 move.b eval_tmp1+2(a6),d0
 and.w #7,d0
 beq.s .double_b
 cmp.b #1,d0
 beq.s .double_w
 cmp.w #2,d0
 beq.s .double_l
 cmp.w #3,d0
 beq.s .double_l			; single
.double_d:
 move.l d6,(a1)
 move.l d7,4(a1)
 bra.s .it_was_double
.double_l:
 move.l d7,4(a1)
 bra.s .it_was_long
.double_w:
 move.w d7,6(a1)
 bra.s .it_was_word
.double_b:
 move.b d7,7(a1)
 bra.s .it_was_byte

.packed_affect:
 move.l eval_tmp2(a6),a1
 move.b eval_tmp1+2(a6),d0
 and.w #7,d0
 beq.s .packed_b
 cmp.b #1,d0
 beq.s .packed_w
 cmp.w #2,d0
 beq.s .packed_l
 cmp.w #3,d0
 beq.s .packed_l			; single
 cmp.w #4,d0
 beq.s .packed_d
.packed_p:				; extended + packed
 move.l d5,(a1)
 move.l d6,4(a1)
 move.l d7,8(a1)
.it_was_packed:
 moveq #0,d4
 moveq #0,d0
 rts
.packed_d:
 move.l d6,4(a1)
 move.l d7,8(a1)
.it_was_double:
 moveq #0,d4
 moveq #0,d5
 moveq #0,d0
 rts
.packed_l:
 move.l d7,8(a1)
.it_was_long:
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 moveq #0,d0
 rts
.packed_w:
 move.w d7,$a(a1)
.it_was_word:
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 and.l #$ffff,d7
 moveq #0,d0
 rts
.packed_b:
 move.b d7,$b(a1)
.it_was_byte:
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 and.l #$ff,d7
 moveq #0,d0
 rts

.memory_affect:
 move.b eval_tmp1+2(a6),d1
 move.l eval_tmp2(a6),a1
 and.w #7,d1
 add.w d1,d1
 add.w d1,d1
 jmp .mem_affect(pc,d1.w)
.mem_affect:
 _NOOPTI
 bra .mem_byte
 bra .mem_word
 bra .mem_long
 bra .mem_long
 bra .mem_double
 bra .mem_packed
 bra .mem_packed
 _OPTI
.mem_byte:
 move.l a0,-(sp)
 move.l a1,a0
 bsr test_if_writable1
 movem.l (sp)+,a0
 bne .error
 move.b d7,(a1)
 bra.s .it_was_byte

.mem_word:
 move.l a0,-(sp)
 move.l a1,a0
 bsr test_if_writable2
 movem.l (sp)+,a0
 bne .error
 move.l d7,-(sp)
 move.b d7,1(a1)
 lsr.w #8,d7
 move.b d7,(a1)
 move.l (sp)+,d7
 bra .it_was_word

.mem_long:
 move.l a0,-(sp)
 move.l a1,a0
 bsr test_if_writable
 movem.l (sp)+,a0
 bne .error
 move.l d7,-(sp)
 move.b d7,3(a1)
 lsr.l #8,d7
 move.b d7,2(a1)
 lsr.l #8,d7
 move.b d7,1(a1)
 lsr.w #8,d7
 move.b d7,(a1)
 move.l (sp)+,d7
 bra .it_was_long

.mem_double:
 move.l a0,-(sp)
 move.l a1,a0
 bsr test_if_writable
 movem.l (sp)+,a0
 bne .error
 move.l a0,-(sp)
 move.l a1,a0
 addq.w #4,a0
 bsr test_if_writable
 movem.l (sp)+,a0
 bne .error
 movem.l d6-d7,-(sp)
 move.b d6,3(a1)
 lsr.l #8,d6
 move.b d6,2(a1)
 lsr.l #8,d6
 move.b d6,1(a1)
 lsr.w #8,d6
 move.b d6,(a1)
 move.b d7,7(a1)
 lsr.l #8,d7
 move.b d7,6(a1)
 lsr.l #8,d7
 move.b d7,5(a1)
 lsr.w #8,d7
 move.b d7,4(a1)
 movem.l (sp)+,d6-d7
 bra .it_was_double

.mem_packed:
 move.l a0,-(sp)
 move.l a1,a0
 bsr test_if_writable
 movem.l (sp)+,a0
 bne .error
 move.l a0,-(sp)
 move.l a1,a0
 addq.w #4,a0
 bsr test_if_writable
 movem.l (sp)+,a0
 bne .error
 move.l a0,-(sp)
 move.l a1,a0
 bsr test_if_writable
 movem.l (sp)+,a0
 bne .error
 move.l a0,-(sp)
 move.l a1,a0
 addq.w #4,a0
 bsr test_if_writable
 movem.l (sp)+,a0
 bne .error
 movem.l d5-d7,-(sp)
 move.b d5,3(a1)
 lsr.l #8,d5
 move.b d5,2(a1)
 lsr.l #8,d5
 move.b d5,1(a1)
 lsr.w #8,d5
 move.b d5,(a1)
 move.b d6,7(a1)
 lsr.l #8,d6
 move.b d6,6(a1)
 lsr.l #8,d6
 move.b d6,5(a1)
 lsr.w #8,d6
 move.b d6,4(a1)
 move.b d7,$b(a1)
 lsr.l #8,d7
 move.b d7,$a(a1)
 lsr.l #8,d7
 move.b d7,9(a1)
 lsr.w #8,d7
 move.b d7,8(a1)
 movem.l (sp)+,d5-d7
 bra .it_was_packed

.may_be_error:
 tst.b evaluating_prepost(a6)
 beq.s .error
 moveq #0,d0
 rts
.error:
 moveq #-1,d0
 rts

;  #] 128 bits Affect:
;  #[ 128 bits INC/DEC:

INC_DEC:
 st evaluating_prepost(a6)
 movem.l d0-d7,-(sp)
 movem.l eval_tmp1(a6),d0-d3
 movem.l d0-d3,-(sp)
 move.b eval_tmp1bis+2(a6),d0
 and.w #$f0,d0
 tst.b evaluating_post(a6)
 bne.s .first_post
.first_pre:
 and.w #$a0,d0
 bra.s .after_first_choice
.first_post:
 and.w #$50,d0 
.after_first_choice:
 tst.w d0
 beq.s .after_first_one
 btst #7,d0
 bne.s .first_inc
 btst #6,d0
 bne.s .first_inc
 btst #5,d0
 bne.s .first_dec
 btst #4,d0
 beq.s .after_first_choice
.first_dec:
 moveq #-1,d4
 moveq #-1,d5
 moveq #-1,d6
 moveq #-1,d7
 bra.s .first_one
.first_inc:
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 moveq #1,d7
.first_one:
 movem.l -40(a4),d0-d3
 add.l d3,d7
 addx.l d2,d6
 addx.l d1,d5
 addx.l d0,d4
 move.l eval_tmp1bis(a6),eval_tmp1(a6)
 move.l eval_tmp2bis(a6),eval_tmp2(a6)
 bsr AFFECT
 movem.l d4-d7,-40(a4)
.after_first_one:
 movem.l (sp),d0-d3
 move.l d0,eval_tmp1(a6)
 move.l d1,eval_tmp2(a6)
 move.b eval_tmp1+2(a6),d0
 and.w #$f0,d0
 tst.b evaluating_post(a6)
 bne.s .second_post
.second_pre:
 and.w #$a0,d0
 bra.s .after_second_choice
.second_post:
 and.w #$50,d0 
.after_second_choice:
 tst.w d0
 beq.s .after_second_one
 btst #7,d0
 bne.s .second_inc
 btst #6,d0
 bne.s .second_inc
 btst #5,d0
 bne.s .second_dec
 btst #4,d0
 beq.s .after_second_choice
.second_dec:
 moveq #-1,d4
 moveq #-1,d5
 moveq #-1,d6
 moveq #-1,d7
 bra.s .second_one
.second_inc:
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 moveq #1,d7
.second_one:
 movem.l -16(a4),d0-d3
 add.l d3,d7
 addx.l d2,d6
 addx.l d1,d5
 addx.l d0,d4
 bsr AFFECT
 movem.l d4-d7,-16(a4)
.after_second_one:
 movem.l (sp)+,d0-d3
 movem.l d0-d3,eval_tmp1(a6)
 movem.l (sp)+,d0-d7
 tst.b evaluating_pre(a6)
 beq.s .no_update
 movem.l -40(a4),d4-d7
 movem.l -16(a4),d0-d3
.no_update:
 sf evaluating_prepost(a6)
 rts

unary_INC_DEC:
 st evaluating_prepost(a6)
 move.l (a4),eval_tmp1(a6)
 move.l 4(a4),eval_tmp2(a6)
 move.b eval_tmp1+2(a6),d0
 and.w #$f0,d0
 tst.b evaluating_post(a6)
 bne.s .post
.pre:
 and.w #$a0,d0
 bra.s .after_choice
.post:
 and.w #$50,d0 
.after_choice:
 tst.w d0
 beq.s .end
 btst #7,d0
 bne.s .inc
 btst #6,d0
 bne.s .inc
 btst #5,d0
 bne.s .dec
 btst #4,d0
 beq.s .end
.dec:
 moveq #-1,d4
 moveq #-1,d5
 moveq #-1,d6
 moveq #-1,d7
 bra.s .treat
.inc:
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 moveq #1,d7
.treat:
 movem.l 8(a4),d0-d3
 add.l d3,d7
 addx.l d2,d6
 addx.l d1,d5
 addx.l d0,d4
 bsr AFFECT
 movem.l d4-d7,8(a4)
.end:
 sf evaluating_prepost(a6)
 rts

;  #] 128 bits INC/DEC:
;  #[ 128 bits Log. AND:

; IN:	d0->d3: number1
;	d4->d7: number2
; OUT:	d4->d7: 0/-1
LOG_AND:
 tst.l d0
 bne.s .test_second
 tst.l d1
 bne.s .test_second
 tst.l d2
 bne.s .test_second
 tst.l d3
 beq.s .wrong
.test_second:
 tst.l d4
 bne.s .right
 tst.l d5
 bne.s .right
 tst.l d6
 bne.s .right
 tst.l d7
 bne.s .right
.wrong:
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 moveq #0,d7
 rts
.right:
 moveq #-1,d4
 moveq #-1,d5
 moveq #-1,d6
 moveq #-1,d7
 rts

;  #] 128 bits Log. AND:
;  #[ 128 bits Log. OR:

; IN:	d0->d3: number1
;	d4->d7: number2
; OUT:	d4->d7: 0/-1
LOG_OR:
 tst.l d0
 bne.s .right
 tst.l d1
 bne.s .right
 tst.l d2
 bne.s .right
 tst.l d3
 bne.s .right
 tst.l d4
 bne.s .right
 tst.l d5
 bne.s .right
 tst.l d6
 bne.s .right
 tst.l d7
 bne.s .right
.wrong:
 moveq #0,d4
 moveq #0,d5
 moveq #0,d6
 moveq #0,d7
 rts
.right:
 moveq #-1,d4
 moveq #-1,d5
 moveq #-1,d6
 moveq #-1,d7
 rts

;  #] 128 bits Log. OR:
;  #[ 128 bits NOT:

; IN:	d4->d7: number1
; OUT:	d4->d7: ~number1
NOT:
 not.l d4
 not.l d5
 not.l d6
 not.l d7
 rts

;  #] 128 bits NOT:
;  #] 128 bits operations:
;  #[ Bus error management:

test_if_writable:
 movem.l d0-d1/d6-d7/a0-a1,-(sp)
 moveq #0,d6
 lea test_if_writable_berror(pc),a1
 move.l a1,d0
 bsr set_berr
 move.l d0,d7
.test_if_writable4:
 move.b (a0),d0
 sf (a0)
 move.b d0,(a0)+
 move.b (a0),d0
 sf (a0)
 move.b d0,(a0)+
internal_test_if_writable2:
 move.b (a0),d0
 sf (a0)
 move.b d0,(a0)+
internal_test_if_writable1:
 move.b (a0),d0
 sf (a0)
 move.b d0,(a0)+
 move.l d7,d0
 bsr set_berr
 tst.w d6
 movem.l (sp)+,d0-d1/d6-d7/a0-a1
 rts

test_if_writable_berror:
 moveq #-1,d6
 IFNE _68030
 tst.b chip_type(a6)
 beq.s .68000
 bclr #0,$a(sp)
 rte
.68000:
 ENDC
 addq.w #8,sp
 rte

test_if_writable2:
 movem.l d0-d1/d6-d7/a0-a1,-(sp)
 moveq #0,d6
 lea test_if_writable_berror(pc),a1
 move.l a1,d0
 bsr set_berr
 move.l d0,d7
 bra.s internal_test_if_writable2

test_if_writable1:
 movem.l d0-d1/d6-d7/a0-a1,-(sp)
 moveq #0,d6
 lea test_if_writable_berror(pc),a1
 move.l a1,d0
 bsr set_berr
 move.l d0,d7
 bra.s internal_test_if_writable1

;  #] Bus error management:
;  #[ Miscellaneous:

eval_help:
;
;
;
 rts

_div:
 movem.l d2/d6-d7,-(sp)
 moveq #0,d6
 moveq #31,d7
.loop:	
 add.l d2,d2
 roxl.l d1
 roxl.l d6
 cmp.l d0,d6
 blt.s .clrbt
 addq #1,d2
 sub.l d0,d6
.clrbt:	
 dbf d7,.loop
 move.l d2,d1
 movem.l (sp)+,d2/d6-d7
 rts

;--- In ---
;d0=numero
;--- Out ---
;d0=@
get_bkpt_address:
 movem.l d5-d7/a0-a5,-(sp)
 move.l d0,d7
 move.l breaks_addr(a6),a5
 move.l current_breaks_nb(a6),d5
 beq.s .not_found
.l1:
 cmp.w 8(a5),d7
 beq.s .break_found
 move.l a5,a0
 _JSR _get_next_break
 bmi.s .not_found
 move.l a0,a5
 subq.l #1,d5
 bpl.s .l1
.not_found:
 moveq #-1,d0
 bra.s .end
.break_found:
 move.l (a5),d0
 tst.w 10(a5)
 bge.s .end
 move.l 12(a5),d0
.end:
 movem.l (sp)+,d5-d7/a0-a5
 tst.l d0
 rts

Eval_strlen:
 move.l a2,-(sp)
.loop:
 tst.b (a2)+
 bne .loop
 sub.l (sp)+,a2
 move.l a2,d0
 subq.l #1,d0
 rts

;  #] Miscellaneous:
 IFNE Compile
;  #[ Compile routines:

comp_save_context:
 move.l a0,-(sp)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 move.l compile_pointer(a6),a0
 move.w #$4afc,(a0)+			; illegal *** test ***
 move.l #$4e54fc00,(a0)+		; link a4,#-$400
 move.w #$2f0c,(a0)+			; move.l a4,-(sp)
 addq.l #8,compile_pointer(a6)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 move.l (sp)+,a0
 rts

comp_restore_context:
 move.l a0,-(sp)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 move.l compile_pointer(a6),a0
 move.w #$285f,(a0)+			; move.l (sp)+,a4
 move.w #$4e5c,(a0)+			; unlk a4
 move.w #$4e75,(a0)+			; rts
 addq.l #6,compile_pointer(a6)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 move.l (sp)+,a0
 rts

; d0 = address
comp_put_bsr:
 movem.l d1/a0,-(sp)
 move.l compile_pointer(a6),a0
 move.w #$6100,(a0)+			; bsr
 move.l a0,d1
 sub.l d0,d1
 cmp.w #$7f,d0
 bgt.s .bsr_w
 cmp.w #-$80,d0
 blt.s .bsr_w
.bsr_b:					; .b
 move.b d0,-1(a0)
 addq.l #2,compile_pointer(a6)
 bra.s .end
.bsr_w:					; .w
 move.w d1,(a0)+
 addq.l #4,compile_pointer(a6)
.end:
 movem.l (sp)+,d1/a0
 rts

comp_store_a4:
 move.l a0,-(sp)
 move.l compile_pointer(a6),a0
 move.l #$48e40f00,(a0)+		; movem.l d4-d7,-(a4)
 addq.l #4,compile_pointer(a6)
 move.l (sp)+,a0
 rts

; d0 = offset
comp_take_d0d3_a4:
 move.l a0,-(sp)
 move.l compile_pointer(a6),a0
 move.l #$4cec000f,(a0)+		; movem.l xx(a4),d0-d3
 move.w d0,(a0)
 addq.l #6,compile_pointer(a6)
 move.l (sp)+,a0
 rts

; d0 = offset
comp_take_d4d7_a4:
 move.l a0,-(sp)
 move.l compile_pointer(a6),a0
 move.l #$4cec00f0,(a0)+		; movem.l xx(a4),d4-d7
 move.w d0,(a0)
 addq.l #6,compile_pointer(a6)
 move.l (sp)+,a0
 rts

; d0 = number
; d1 = register 
comp_store_dx:
 move.l a0,-(sp)
 move.l compile_pointer(a6),a0
 add.w d1,d1
 cmp.l #-$80,d0
 blt.s .move
 cmp.l #$7f,d0
 bgt.s .move
.moveq:
 move.w #$7000,(a0)			; moveq #$xx,dx
 or.b d1,(a0)+
 move.b d0,(a0)+
 addq.l #2,compile_pointer(a6)
 move.l (sp)+,a0
 rts
.move:
 move.w #$203c,(a0)+			; move.l #$xxxxxxxx,dx
 or.b d1,-2(a0)
 move.l d0,(a0)+
 addq.l #6,compile_pointer(a6)
 move.l (sp)+,a0
 rts

comp_store_string:
 movem.l d0-d1/a0,-(sp)
 move.l 8(a4),d0
 moveq #4,d1
 bsr comp_store_dx
 move.l $c(a4),d0
 moveq #5,d1
 bsr comp_store_dx
 move.l $10(a4),d0
 moveq #6,d1
 bsr comp_store_dx
 move.l $14(a4),d0
 moveq #7,d1
 bsr comp_store_dx
 bsr comp_store_a4
 move.l compile_pointer(a6),a0 
 tst.l 4(a4)
 bne.s .not_null1
 bsr.s .null
 bra.s .after_null1
.not_null1:
 move.w #$293c,(a0)+			; move.l #$xxxxxxxx,-(a4)
 move.l 4(a4),(a0)+
 addq.l #6,compile_pointer(a6)
.after_null1:
 tst.l (a4)
 bne.s .not_null2
 bsr .null
 bra.s .after_null2
.not_null2:
 move.w #$293c,(a0)+			; move.l #$xxxxxxxx,-(a4)
 move.l (a4),(a0)+
 addq.l #6,compile_pointer(a6)
.after_null2:
 movem.l (sp)+,d0-d1/a0
 rts
.null:
 move.w #$42a4,(a0)+			; clr.l -(a4)
 addq.l #2,compile_pointer(a6)
 rts

comp_token_finished:
 movem.l d2/a0,-(sp)
 mulu #24,d2
 beq.s .end
 move.l compile_pointer(a6),a0
 move.w #$49ec,(a0)+			; lea xx(a4),a4
 move.w d2,(a0)+
 addq.l #4,compile_pointer(a6)
.end:
 movem.l (sp)+,d2/a0
 rts

comp_L_R_Get_numbers:
;
;
;
 rts

;  #] Compile routines:
 ENDC
