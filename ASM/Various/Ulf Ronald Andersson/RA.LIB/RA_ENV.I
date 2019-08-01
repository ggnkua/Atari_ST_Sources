;----------------------------------------------------------------------------
;File name:	RA_ENV.I			Revision date:	1999.01.31
;Creator:	Ulf Ronald Andersson		Creation date:	1994.08.31
;(c)1994 by:	Ulf Ronald Andersson		All rights reserved
;Released as:	FREEWARE		(NB: commercial sales forbidden!)
;----------------------------------------------------------------------------
;Purpose:	Macro library for environmemt handler
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	ifnd	RA_ENV_defined
RA_ENV_defined	set	1
;
;----------------------------------------------------------------------------
	include	RA_SYS.I
;----------------------------------------------------------------------------
;Library macros:
;
;old_env_base	  d0 -> basepage of oldest env from basepage (a0)
;
;measure_args	  d0 = total size of d0 args (a0) (as needed in env)
;measure_env	  d0 = total size of env (a0)
;measure_var	  d0 = size of current string (a0)
;next_env_var	  d0 -> next var in env (a0) (even NUL) / NULL
;next_value	  d0 -> value of env var (a0) / E_FILNF
;
;ultoa_8hex	  conv d0 to 8 ascii hex (a0),  d0 = a0+8
;
;eval_number	  d0 = numeric value of prefixed ($=hex) string (a0)
;eval_hex_num	  d0 = numeric value of hex string (a0)
;eval_dec_num	  d0 = numeric value of decimal string (a0)
;eval_bin_num	  d0 = numeric value of binary string (a0)
;eval_base_d0	  d0 = numeric value of string (a0) in base d0
;
;make_env_var  Make new var (a0) in env (a1), d0= a0 / E_ACCDN
;kill_env_var  Kill old var (a0) in env (a1), d0= a0 / E_FILNF
;find_env_var  Find old var (a0) in env (a1), d0 -> var / E_FILNF
;eval_env_var  d0 = numeric value of env var / E_RANGE / E_FILNF
;
;NB: 'measure_args' needs d0/a0 as per RA_APP.I 'arg_cnt/arg_ptr'
;NB: 'eval_...' routines return E_RANGE in d0 at failed conversion
;NB: 'next_...' do not flag NUL strings as errors, but you must test for it.
;----------------------------------------------------------------------------
;NB: You must include the following line somewhere after the macro calls
;	"make	ENV_links"
;NB: That will cause the needed routines to be included at that point.
;NB: You may do this several times (after further calls), and at each
;NB: point only the 'newly' referenced routines will be added to the code.
;NB: A dummy reference macro exists, so routines can be added to code even
;NB: without calling them.  The macro is '_uniref', used as below:
;	"_uniref oldest base"
;----------------------------------------------------------------------------
;	Macro definitions:
;----------------------------------------------------------------------------
;
ENV_links	macro
		_unidef	old_env_base
		_unidef	ultoa_8hex
		_unidef	measure_args
		_unidef	measure_env
		_unidef	measure_var
		_unidef	make_env_var
		_unidef	kill_env_var
		_unidef	find_env_var
		_unidef	eval_env_var
		_unidef	eval_number
		_unidef	next_env_var
		_unidef	next_value
		_unidef	eval_number
		_unidef	eval_base_d0
		endm	;ENV_links
;
;----------------------------------------------------------------------------
;Macro:	old_env_base
;Entry:	a0 -> basepage
;Exit:	d0 -> basepage of oldest valid environment
;
old_env_base	macro
	_uniref	old_env_base
	bsr	old_env_base_code
	endm	;old_env_base
;
;
old_env_base_code	macro
	movem.l	d1/a0/a1,-(sp)
.loop:
	move.l	a0,d0			;d0 = current basepage ptr
	move.l	bp_parent_p(a0),d1
	ble.s	.exit_loop		;exit if no parent
	move.l	d1,a0			;a0 = next older basepage ptr
	cmp.l	bp_parent_p(a0),d0
	beq.s	.exit_loop		;exit at self_parent
	move.l	bp_environ_p(a0),d1
	ble.s	.exit_loop		;exit at invalid environ_p
	move.l	d1,a1			;a1 = next older environment ptr
	tst.b	(a1)
	bne.s	.loop			;loop until empty environment found
	tst.b	1(a1)
	bne.s	.loop			;loop until empty environment found
.exit_loop:
	movem.l	(sp)+,d1/a0/a1
	rts
	endm	;old_env_base_code
;
;----------------------------------------------------------------------------
;Macro:	ultoa_8hex
;Entry:	d0 =	unsigned long for conversion
;  "	a0 ->	8 byte ascii buffer
;Exit:	No regs altered
;
ultoa_8hex	macro
	_uniref	ultoa_8hex
	bsr	ultoa_8hex_code
	endm	;ultoa_8hex
;
;
ultoa_8hex_code	macro
	movem.l	d1-d2/a0,-(sp)	;push registers
	moveq	#8-1,d2		;prep d2 for 8 digits
.loop:				;loop: to convert 8 digits to ascii
	rol.l	#4,d0		;  shift d0 top digit to low byte
	move.b	d0,d1		;  copy d0 low byte to d1
	and	#$0F,d1		;  isolate low digit in d1
	add	#'0',d1		;  convert to ascii based on '0'
	cmp	#'9',d1		;  digit ok ?
	bls.s	.got_digit	;  go store that ascii if '0'..'9'
	add	#'A'-'9'-1,d1	;  reconvert to ascii based at 'A'-10
.got_digit:
	move.b	d1,(a0)+	;  store new ascii digit
	dbra	d2,.loop	;loop] for 8 digits
	move.l	a0,d0		;return d0 -> beyond new string
	movem.l	(sp)+,d1-d2/a0	;pull registers
	rts
	endm	;ultoa_8hex_code
;
;----------------------------------------------------------------------------
;Macro:	measure_args
;Entry:	a0 -> argument string
;  "	d0 =  argument count  (+1 for progname)
;Exit:	d0 =  total sum of string lengths
;
measure_args	macro
	_uniref	measure_args
	_uniref	next_env_var
	bsr	measure_args_code
	endm	;measure_args
;
;
measure_args_code	macro
	movem.l	d1/a0,-(sp)
	tst.l	4(sp)
	beq.s	.exit		;NULL ptr => zero size
	move.l	d0,d1
	subq	#1,d1
	ble.s	.exit		;zero real args => zero size
	next_env_var		;pass program name arg
	move.l	d0,a0
	subq	#1,d1
.loop_1:
	tst.b	(a0)
	beq.s	.exit		;exit at NUL arg
.loop_2:
	tst.b	(a0)+
	bne.s	.loop_2
	dbra	d1,.loop_1
.exit:
	sub.l	4(sp),a0
	move.l	a0,d0
	movem.l	(sp)+,d1/a0
	rts			;return d0 = total size of argument strings
	endm	;measure_args_code
;
;----------------------------------------------------------------------------
;Macro:	measure_env
;Entry:	a0 -> environment
;Exit:	d0 =  total size of environment
;
measure_env	macro
	_uniref	measure_env
	bsr	measure_env_code
	endm	;measure_env
;
;
measure_env_code	macro
	move.l	a0,-(sp)
	move.l	a0,d0
	beq.s	.exit	;NULL ptr => zero size
.loop:
	tst.b	(a0)+
	bne.s	.loop
	tst.b	(a0)+
	bne.s	.loop
.exit:
	sub.l	(sp),a0
	move.l	a0,d0
	movea.l	(sp)+,a0
	rts		;return d0 = environment size (incl termination)
	endm	;measure_env_code
;
;----------------------------------------------------------------------------
;Macro:	measure_var
;Entry:	a0 -> string
;Exit:	d0 =  total size of string (incl NUL), unless NULL
;
measure_var	macro
	_uniref	measure_var
	bsr	measure_var_code
	endm	;measure_var
;
;
measure_var_code	macro
	move.l	a0,-(sp)
	move.l	a0,d0
	beq.s	.exit	;NULL ptr => zero size
.loop:
	tst.b	(a0)+
	bne.s	.loop
.exit:
	sub.l	(sp),a0
	move.l	a0,d0
	movea.l	(sp)+,a0
	rts		;return d0 = environment size (incl termination)
	endm	;measure_var_code
;
;----------------------------------------------------------------------------
;Macro:	eval_env_var
;Entry:	a0 -> var_name
;  "	a1 -> environment
;Exit:	d0 =  converted ULONG, unless E_RANGE
;
eval_env_var	macro
	_uniref	eval_env_var
	_uniref	eval_number
	bsr	eval_env_var_code
	endm
;
;
eval_env_var_code	macro
	movem.l	a0/a1,-(sp)
	find_env_var
	ble.s	.exit
	move.l	d0,a0
	next_value
	ble.s	.exit
	move.l	d0,a0
	eval_number
.exit:
	movem.l	(sp)+,a0/a1
	rts
	endm	;eval_env_var_code
;
;----------------------------------------------------------------------------
;Macro:	kill_env_var
;Entry:	a0 -> var_name
;  "	a1 -> environment
;Exit:	d0 -> altered environment, unless E_FILNF  (var not found)
;
kill_env_var	macro
	_uniref	kill_env_var
	bsr	kill_env_var_code
	endm	;kill_env_var
;
;
kill_env_var_code	macro
	find_env_var
	tst.l	d0
	ble.s	.exit		;exit with d0 = error code if not found
	movem.l	a0-a1,-(sp)	;push registers
	move.l	d0,a0		;a0 -> found var, == move destination
	next_env_var
	move.l	d0,a1		;a1 -> next var, == move source
.loop_1:			;loop: move all remaining strings in env
	move.b	(a1)+,(a0)+	;  move 1'st byte of a string
	beq.s	.env_end	;exit loop at end of environment
.loop_2:			;  loop: move rest of string
	move.b	(a1)+,(a0)+	;    move a byte of string
	bne.s	.loop_2		;  loop] until string terminates
	bra.s	.loop_1		;loop] for entire environment
;
.env_end:
	clr.b	(a0)+		;ensure environment termination
	movem.l	(sp)+,a0-a1	;pull registers
	move.l	a1,d0		;return d0 -> altered env
.exit:
	rts
	endm	;kill_env_var
;
;----------------------------------------------------------------------------
;Macro:	make_env_var
;Entry:	a0 -> var_name
;  "	a1 -> environment
;Exit:	d0 -> altered environment, unless E_ACCDN  (var already exists
;
;NB: 'make_env_var' does not check sizes,
;    so caller must be sure env (a1) has enough room.
;
make_env_var	macro
	_uniref	make_env_var
	_uniref	measure_env
	bsr	make_env_var_code
	endm	;make_env_var
;
;
make_env_var_code	macro
	find_env_var
	move.l	d0,-(sp)
	moveq	#E_ACCDN,d0	;prep error flag 'access denied'
	tst.l	(sp)+
	bgt.s	.exit		;exit with d0 = error code if found
	tst.b	(a0)
	beq.s	.exit		;exit with d0 = error code for NUL var
	movem.l	a0-a1,-(sp)	;push registers
	move.l	a1,a0		;a0 -> env
	measure_env		;d0 = total size of env
	add.l	d0,a1		;a1 -> beyond env
	subq.l	#1,a1		;a1 -> termination NUL of env
	cmp.l	#2,d0		;empty environment ?
	bne.s	.get_str	;if not, go keep a1 as move destination
	subq.l	#1,a1		;a1 -> NUL string in empty environment
.get_str:
	move.l	(sp),a0		;a0 -> new string for env
.loop:				;loop: copy entire new string
	move.b	(a0)+,(a1)+	;  copy a byte of new string
	bne.s	.loop		;loop] until string terminated
	clr.b	(a1)+		;terminate env
	movem.l	(sp)+,a0-a1	;pull registers
	move.l	a1,d0		;return d0 -> altered env
.exit:
	rts
	endm	;make_env_var
;
;----------------------------------------------------------------------------
;Macro:	find_env_var
;Entry:	a0 -> var_name
;  "	a1 -> environment
;Exit:	d0 -> found var name, unless E_FILNF  (var not found)
;
find_env_var	macro
	_uniref	find_env_var
	bsr	find_env_var_code
	endm	;find_env_var
;
;
find_env_var_code	macro
	movem.l	d1/a0-a3,-(sp)	;push registers
	move.l	a1,d0
	beq.s	.env_end	;NULL env ptr => error
	move.l	a0,d0
	beq.s	.env_end	;NULL var ptr => error
	move.l	a0,a2		;a2 -> var to find
.next_var_loop:			;loop: check vars in env
	move.l	a1,a3		;  a3 -> possible found var (untested)
	move.l	a2,a0
	tst.b	(a1)		;  environment end ?
	beq.s	.env_end
.var_loop:			;  loop: check a var in env
	move.b	(a1)+,d0	;    termination of var in env ?
	beq.s	.next_var_loop	;loop] at premature (erroneous) end of var
	cmp.b	(a0)+,d0	;    sought var char identical to env ?
	bne.s	.skip_rest	;    exit to skip rest if different
	cmp.b	#'=',d0		;    end of var ?
	bne.s	.var_loop	;  loop] check entire name
.found_var:
	move.l	a3,d0		;return d0 -> found string
	bra.s	.exit		;go exit sub
;
.skip_rest:
	cmp.b	#'=',d0		;  was env char a var name terminator ?
	bne.s	.skip_rest_loop	;  if not we must pass this var
	tst.b	-1(a0)		;  was name char a string terminator ?
	beq.s	.found_var	;  if so, we succeeded after all !
.skip_rest_loop:		;  loop: ignore value in env
	tst.b	(a1)+		;    string termination ?
	bne.s	.skip_rest_loop	;  loop] skip entire string
	bra.s	.next_var_loop	;loop] test more vars
;
.env_end:
	moveq	#E_FILNF,d0	;return d0 = E_FILNF, var not found
.exit:
	movem.l	(sp)+,d1/a0-a3	;pull registers
	rts
	endm	;find_env_var_code
;
;----------------------------------------------------------------------------
;Macro:	next_env_var
;Entry:	a0 -> any pos in environment
;Exit:	d0 -> next string (may be NUL), unless NULL
;
next_env_var	macro
	_uniref	next_env_var
	bsr	next_env_var_code
	endm	;next_env_var
;
;
next_env_var_code	macro
	move.l	a0,-(sp)	;push a0
	move.l	a0,d0
	beq.s	.exit		;NULL ptr => exit (returning NULL)
.loop:				;loop: pass a string in env
	tst.b	(a0)+		;termination of string ?
	bne.s	.loop		;loop] pass entire string
	move.l	a0,d0		;return d0 -> found var
.exit:
	move.l	(sp)+,a0	;pull a0
	rts
	endm	;next_env_var_code
;
;----------------------------------------------------------------------------
;Macro:	next_value
;Entry:	a0 -> any pos in environment
;Exit:	d0 -> next value string (may be NUL), unless E_FILNF
;
next_value	macro
	_uniref	next_value
	bsr	next_value_code
	endm	;next_value
;
;
next_value_code	macro
	move.l	a0,-(sp)	;push a0
	move.l	a0,d0
	beq.s	.error		;NULL ptr => error
.loop:				;loop: pass var to value point
	move.b	(a0)+,d0	;  termination of string in env ?
	beq.s	.error		;go exit if no value found
	cmp.b	#'=',d0		;  end of var name ?
	bne.s	.loop		;loop] pass entire name of var
	move.l	a0,d0		;return d0 -> found value
	bra.s	.exit
;
.error:
	moveq	#E_FILNF,d0	;return d0 = E_FILNF, value not found
.exit:
	move.l	(sp)+,a0	;pull a0
	rts
	endm	;next_value_code
;
;----------------------------------------------------------------------------
;Macro:	eval_number
;Entry:	a0 -> ascii of number to evaluate
;Exit:	d0 =  converted ULONG, unless E_RANGE
;
eval_number	macro
	_uniref	eval_number
	bsr	eval_number_code
	endm	;eval_number
;
;
eval_number_code	macro
	move.l	a0,-(sp)	;push a0
	move.l	a0,d0
	beq.s	.bad_value	;NULL ptr => error
	moveq	#10,d0		;assume decimal base
	cmp.b	#'0',(a0)	;first char possibly digit ?
	bhs.s	.eval_number	;if so, go evaluate number
	moveq	#16,d0		;assume hexadecimal base
	cmp.b	#'$',(a0)+	;'$' present as hex prefix ?
	bhs.s	.eval_number	;if so, go evaluate number
	moveq	#2,d0		;assume binary base
	cmp.b	#'%',-1(a0)	;'%' present as binary prefix ?
	bhs.s	.eval_number	;if so, go evaluate number
.bad_value:
	moveq	#E_RANGE,d0	;return E_RANGE for illegal value
	bra.s	.exit
;
.eval_number:
	eval_base_d0
.exit:
	movea.l	(sp)+,a0	;pull a0
	rts
	endm	;eval_number_code
;
;----------------------------------------------------------------------------
;Macro:	eval_hex_num
;Entry:	a0 -> ascii of hex number to evaluate
;Exit:	d0 =  converted ULONG, unless E_RANGE
;
eval_hex_num	macro
	_uniref	eval_base_d0
	bsr	eval_hex_num_code
	endm	;eval_hex_num
;
;----------------------------------------------------------------------------
;Macro:	eval_dec_num
;Entry:	a0 -> ascii of decimal number to evaluate
;Exit:	d0 =  converted ULONG, unless E_RANGE
;
eval_dec_num	macro
	_uniref	eval_base_d0
	bsr	eval_dec_num_code
	endm	;eval_dec_num
;
;----------------------------------------------------------------------------
;Macro:	eval_bin_num
;Entry:	a0 -> ascii of binary number to evaluate
;Exit:	d0 =  converted ULONG, unless E_RANGE
;
eval_bin_num	macro
	_uniref	eval_base_d0
	bsr	eval_bin_num_code
	endm	;eval_bin_num
;
;----------------------------------------------------------------------------
;Macro:	eval_base_d0
;Entry:	a0 -> ascii of binary number to evaluate
;  "	d0 =  number base for conversion
;Exit:	d0 =  converted ULONG, unless E_RANGE
;
eval_base_d0	macro
	_uniref	eval_base_d0
	bsr	eval_base_d0_ia0
	endm	;eval_base_d0
;
eval_base_d0_code	macro
	bra.s	eval_base_d0_ia0
;
eval_bin_num_code:			;evaluate binary string at (a0)
	moveq	#2,d0
	bra.s	eval_base_d0_ia0
;
eval_dec_num_code:			;evaluate decimal string at (a0)
	moveq	#10,d0
	bra.s	eval_base_d0_ia0
;
eval_hex_num_code:			;evaluate hexadecimal string at (a0)
	moveq	#16,d0
eval_base_d0_ia0:		;evaluate string at (a0) in base d0
	movem.l	d1-d3/a0,-(sp)	;push registers
	move	d0,d3		;d3 = number base
	move.l	a0,d0
	beq.s	.bad_value	;NULL ptr => error
	tst.b	(a0)
	beq.s	.bad_value	;return error if no digits present
	clr.l	d1		;pre_clear total value
	clr.l	d0		;pre_clear digit value
.get_value_loop:
	move.b	(a0)+,d0
	beq.s	.got_value	;return value at end of string
	sub.b	#'0',d0
	blo.s	.bad_value	;return error for digit too low
	cmp.b	#9,d0
	bls.s	.test_base	;go test digits 0..9 as-is
	add.b	#'0'+$A-'A',d0	;adjust for letters as digits
	cmp.b	#10,d0
	blo.s	.bad_value	;return error for illegal characters
.test_base:
	cmp.b	d3,d0
	bhs.s	.bad_value	;return error for digit too high	
.good_digit:
	move.l	d1,d2
	swap	d2
	mulu	d3,d2
	swap	d2
	tst	d2
	bne.s	.bad_value	;return error for value overflow
	clr	d2
	mulu	d3,d1
	add.l	d2,d1
	bcs.s	.bad_value	;return error for unsigned overflow
	add.l	d0,d1
	bcc.s	.get_value_loop	;loop for more digits if no overflow
.bad_value:
	moveq	#E_RANGE,d0	;return E_RANGE for illegal value
	bra.s	.exit
;
.got_value:
	move.l	d1,d0		;return value of decimal number
.exit:
	movem.l	(sp)+,d1-d3/a0	;pull registers
	rts
	endm	;eval_base_d0_code
;
;----------------------------------------------------------------------------
	endc	;RA_ENV_defined
;----------------------------------------------------------------------------
;End of file:	RA_ENV.I
;----------------------------------------------------------------------------
