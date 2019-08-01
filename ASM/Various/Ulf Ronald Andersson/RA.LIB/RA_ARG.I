;----------------------------------------------------------------------------
;File name:	RA_ARG.I			Revision date:	1998.08.14
;Creator:	Ulf Ronald Andersson		Creation date:	1992.11.30
;(c)1992 by:	Ulf Ronald Andersson		All rights reserved
;Released as:	FREEWARE			(NB: commercial sales forbidden!)
;File purpose:	Code library for ARGV handler
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	ifnd	RA_ARG_defined
RA_ARG_defined	set	1
;
;----------------------------------------------------------------------------
;Remarks:
;	This file should be included at the head of a program to make it
;	able to access program arguments easily.
;	It defines a macro start_arg, which you must use in the program
;       to initialize it.  It expects to find the command line untouched
;	in the basepage (offset $80) and will also detect the use of ARGV.
;
;Required variables:
;
;basepage_p	-> program's base page
;
;NB:	This can be defined by including RA_APP.S
;
;Defined variables:
;
;rz		relative zero for internal references
;		This will only be defined here if undefined on entry
;
;arg_cnt	== number of strings on command line
;arg_ptr	-> NUL_separated argument strings + final NUL
;
;NB:	Both of the above include a dummy program name (first string==NUL).
;----------------------------------------------------------------------------
	include	RA_TOS.I
;----------------------------------------------------------------------------
start_arg	MACRO	;NB: very long macro
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
	_unilab	rz
RA_ARGV_init:
	lea	rz(pc),a6		;a6 -> local ref
	move.l	basepage_p(pc),a5	;a5 -> basepage
	gemdos	Fsetdta,.local_dta(pc)
	moveq	#1,d3			;argc = 1
	clr	d1
	lea	bp_arglen(a5),a0
	move.b	(a0)+,d1
	cmp	#$7F,d1
	bhs.s	.try_argv_arg
.cmd_line_arg:
	clr	d2			;unflag separator
	lea	bp_arglen(a5),a3	;a3 -> arg string (result)
	move.l	a3,a1			;a1 -> arg string (reconstruction)
	clr	d1
	move.b	(a1),d1			;d1 = total arg length
	clr.b	(a1)+			;(a1)+ = dummy name string
	move.l	a1,a0			;a0 -> arg string (analysis)
	clr.b	(a0,d1)			;terminate arg string
	clr.b	1(a0,d1)		;terminate arg group
	tst	d1
	ble	.done_arg		;exit if no arg
.scan_tail_next_arg:
	move.b	(a0)+,d0
	beq.s	.scan_tail_end
	cmp.b	#' ',d0
	bls.s	.scan_tail_next_arg
	addq	#1,d3			;increment arg count
	clr	d2			;unflag separator
.scan_tail_next_char:
	cmp.b	#'"',d0
	beq.s	.scan_tail_quote_1
	cmp.b	#"'",d0
	bne.s	.scan_tail_no_quote
.scan_tail_quote_1:
	move.b	(a0)+,d1
	beq.s	.scan_tail_end
	cmp.b	d0,d1
	bne.s	.scan_tail_quote_2
	cmp.b	(a0),d1
	bne.s	.scan_tail_end_quote
	addq	#1,a0		;so double quotes give quote-char
.scan_tail_quote_2:
	move.b	d1,(a1)+	;copy quoted char
	bra.s	.scan_tail_quote_1
;
.scan_tail_no_quote:
	move.b	d0,(a1)+	;copy normal char
.scan_tail_end_quote:
	move.b	(a0)+,d0
	beq.s	.scan_tail_end
	cmp.b	#' ',d0
	bhi.s	.scan_tail_next_char
	clr.b	(a1)+		;change separator from SPC to NUL at destination
	st	d2		;flag separator
	bra.s	.scan_tail_next_arg
;
.scan_tail_end:
	clr.b	(a1)		;terminate arg string
	clr.b	1(a1)		;terminate arg group
.scan_tail_ended:
	bra	.done_arg
;
.try_argv_arg:
	move.l	bp_environ_p(a5),a0	;a0 -> environment strings
	move.l	a0,d0
	beq.s	.cmd_line_arg
	move.b	(a0)+,d0
	beq.s	.scan_env_next_var
.scan_env_1:
	cmp.b	#'A',d0
	bne.s	.scan_env_end_var
	move.b	(a0)+,d0
	beq.s	.scan_env_next_var
	cmp.b	#'R',d0
	bne.s	.scan_env_end_var
	move.b	(a0)+,d0
	beq.s	.scan_env_next_var
	cmp.b	#'G',d0
	bne.s	.scan_env_end_var
	move.b	(a0)+,d0
	beq.s	.scan_env_next_var
	cmp.b	#'V',d0
	bne.s	.scan_env_end_var
	move.b	(a0)+,d0
	beq.s	.scan_env_next_var
	cmp.b	#'=',d0
	bne.s	.scan_env_end_var
	tst.b	(a0)+
	bne.s	.done_arg		;exit if nonstandard ARGV=
	clr.b	-6(a0)			;\/ Cut environment
	clr.b	-5(a0)			;/\ at ARGV= start
	move.l	a0,a3			;a3 -> first arg string (prog name)
	tst.b	(a0)+
	beq.s	.done_arg
.scan_env_2:
	tst.b	(a0)+
	bne.s	.scan_env_2
.scan_env_3:
	tst.b	(a0)+
	beq.s	.done_arg
	addq	#1,d3
.scan_env_4:
		tst.b	(a0)+
	bne.s	.scan_env_4
	bra.s	.scan_env_3
;
.scan_env_end_var:
	move.b	(a0)+,d0
	bne.s	.scan_env_end_var
.scan_env_next_var:
	move.b	(a0)+,d0
	bne.s	.scan_env_1
	bra	.cmd_line_arg
;
.null_str:
	dc.l	0
.local_dta:
	ds.b	44
;
.done_arg:
	move	d3,d0
	bne.s	.keep_arg
	lea	.null_str(pc),a3
.keep_arg:
	move.l	a3,a0
	move.l	a3,arg_ptr-rz(a6)
	move	d0,arg_cnt-rz(a6)
	bra.s	RA_ARGV_exit
;
arg_cnt:
	dc.w	0
arg_ptr:
	dc.l	0
;
RA_ARGV_exit:
;----------------------------------------------------------------------------
	ENDM	;start_arg	NB: ends VERY long macro
;----------------------------------------------------------------------------
	endc	;RA_ARG_defined
;----------------------------------------------------------------------------
;End of file:	RA_ARG.I
;----------------------------------------------------------------------------
