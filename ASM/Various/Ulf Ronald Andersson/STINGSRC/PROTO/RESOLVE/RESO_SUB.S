;----------------------------------------------------------------------------
;File name:	RESO_SUB.S			Revision date:	1997.05.13
;Revised by:	Ulf Ronald Andersson		Creation date:	1997.04.11
;Created by:	Ulf Ronald Andersson		Version:	0.01
;----------------------------------------------------------------------------
;Purpose:	Support functions for STiK 2 DNS resolver
;----------------------------------------------------------------------------
;
	.export	sys_timer_supx	;peek at system clock _200_hz
;
	.export	is_domname	;=NULL if argument is not ptr to domain name
	.export	is_dip		;=NULL if argument is not ptr to dotted ip
	.export	is_unblank	;=NULL if argument not ptr to nonblank string
;NB: is_unblank returns ptr to first nonblank char in string
;
	.export skip_space	;passes leading blanks
	.export next_dip	;passes next comma unless semicolon breaks (comment)
	.export	diptobip	;Conv dotted IP to binary IP, ignores leading spaces/tabs
	.export	biptodip	;Conv binary IP to dotted IP
	.export	biptodrip	;Conv binary IP to dotted reverse IP
;
	.export	pass_RRname	;expands a DNS domain name
;
	.export	illegal		;AMON breakpoint function
	.export illegal_n	;AMON D0 flagged breakpoint function
;
;-------------------------------------------------------------------------------------)
;long	sys_timer_supx(void)
;
sys_timer_supx:
	move.l	($4BA).w,d0
	rts
;
;end of function sys_timer_supx
;-------------------------------------------------------------------------------------)
;char	*is_domname(char *string, len)	/* flags -> domain name */
;
is_domname:
	move.l	a0,d1		;NULL string ?
	beq.s	.exit
	move.l	a0,a1		;a1 = a0 = string
	move	d0,d2		;d2 = len
	ble.s	.label_bad
	bsr	skip_space	;string passed to non-blank
	move.l	a0,d0
	sub.l	a1,d0		;d0 = passed length
	sub	d0,d2		;reduce total length by passed blanks
	ble.s	.label_bad
	move.l	a0,a1		;a1 = a0 = non_blank string
	move	d2,d0		;d0 = remaining len
.label_start:
	clr	d2		;d2 = 0  indicates label starts
.label_char:
	dbra	d0,.test_char	;test len characters
	tst	d2		;last label empty ?
	beq.s	.label_bad
.label_ok:
	rts			;return a0 -> domname
;
.test_char:
	move.b	(a1)+,d1	;d1 = current char
	beq.s	.label_bad	;error on premature terminator
	cmp.b	#'.',d1		;label separator ?
	beq.s	.label_start	;go start new label test
	tst	d2		;label lead char ?
	beq.s	.test_alfa	;go test label lead char  (must be alpha)
	cmp.b	#'-',d1
	beq.s	.label_char	;go try next char after '-'
	cmp.b	#'0',d1
	blo.s	.label_bad	;error if less than decimal digit
	cmp.b	#'9',d1
	bls.s	.label_char	;go try next char after decimal digit
.test_alfa:
	st	d2		;flag next char as non-leading
	cmp.b	#'A',d1
	blo.s	.label_bad	;error if less than 'A'
	cmp.b	#'Z',d1
	bls.s	.label_char	;go try next char after A..Z
	cmp.b	#'a',d1
	blo.s	.label_bad	;error if less than 'a'
	cmp.b	#'z',d1
	bls.s	.label_char	;go try next char after a..z
.label_bad:
	suba.l	a0,a0		;return NULL on error
.exit:
	rts
;
;-------------------------------------------------------------------------------------)
;char	*is_dip(char *string)		/* flags -> dotted ip */
;
is_dip:
	move.l	a0,d0
	beq.s	.exit
	bsr	skip_space
	move.l	a0,a1
	moveq	#4-1,d1		;prep to test four digit groups
.loop_1:			;loop start for each group
	move.b	(a0)+,d0	;get first character in group
	cmp.b	#'0',d0
	blo.s	make_null	;error if non-digit leading group
	cmp.b	#'9',d0
	bhi.s	make_null	;error if non-digit leading group
.loop_2:			;loop start for nonleading chars of group
	move.b	(a0)+,d0	;get next group character/separator
	cmp.b	#'.',d0
	bne.s	.try_digits	;go test digits if not separator
	dbra	d1,.loop_1	;loop back for new group unless four done
	bra.s	make_null	;error if four separators found
;
.try_digits:
	cmp.b	#'0',d0
	blo.s	.test_term	;go test termination at non-digit
	cmp.b	#'9',d0
	bls.s	.loop_2		;loop back for next nonleading char of group
.test_term:
	tst.b	d0		;string terminator ?
	bne.s	make_null	;error on bad terminator
	tst	d1		;d1 == 0 ?  (four groups found ?)
	bne.s	make_null	;error if too few groups
	move.l	a1,a0		;return -> tested dip
.exit:
	rts
;
;-------------------------------------------------------------------------------------)
;char	*is_unblank(char *string)	/* flags -> unblank string */
;
is_unblank:
	move.l	a0,d0
	beq.s	exit_unblank
	bsr	skip_space
	tst.b	(a0)
	bne.s	exit_unblank
make_null:
	suba.l	a0,a0
exit_unblank:
	rts
;
;-------------------------------------------------------------------------------------)
;char	*next_dip(char *string)		/* passes comma-separated arguments */
;char	*skip_space(char *string)	/* skips leading spaces & tabs */
;
next_dip:
	move.l	a0,d0
	beq.s	exit_space
	move.b	(a0)+,d0
	beq.s	back_a0		;refuse to pass terminator
	cmp.b	#';',d0
	beq.s	pass_tail	;pass entire comment
	cmp.b	#',',d0
	bne.s	next_dip	;accept comma as separator
skip_space:
	move.l	a0,d0
	beq.s	exit_space
	move.b	(a0)+,d0
	cmp.b	#' ',d0		;space ?
	beq.s	skip_space	;pass leading spaces
	cmp.b	#$09,d0		;HT ?
	beq.s	skip_space	;pass leading tabs
back_a0:
	subq	#1,a0
exit_space:
	rts
;
pass_tail:
	tst.b	(a0)+
	bne.s	pass_tail	;pass all non-terminators
	subq	#1,a0		;back a0 to terminator
	rts
;
;end of functions skip_space & next_dip
;-------------------------------------------------------------------------------------)
;uint32	diptobip(char *s_p)
;
diptobip:
	bsr.s	skip_space
	moveq	#-1,d0
	cmp.b	#'0',(a0)
	blo.s	exit_diptobip
	cmp.b	#'9',(a0)
	bhi.s	exit_diptobip
	clr.l	d0
	moveq	#4-1,d2
diptobip_loop_1:
	clr	d1
diptobip_loop_2:
	cmp.b	#'0',(a0)
	blo.s	exit_diptobip_loop_2
	cmp.b	#'9',(a0)
	bhi.s	exit_diptobip_loop_2
	mulu	#10,d1
	add.b	(a0)+,d1
	sub	#'0',d1
	and	#$FF,d1
	bra.s	diptobip_loop_2
;
exit_diptobip_loop_2:
	lsl.l	#8,d0
	or.l	d1,d0
	cmp.b	#'.',(a0)+
	beq.s	next_diptobip_loop_1
	subq	#1,a0
next_diptobip_loop_1:
	dbra	d2,diptobip_loop_1
exit_diptobip:
	rts
;
;end of function diptobip
;-------------------------------------------------------------------------------------)
;char	*biptodip(uint32 ip_n, char *s_p)
;
biptodip:
	moveq	#4-1,d2
biptodip_loop:
	move.l	a0,a1			;a1 = a0 = start of next number
	rol.l	#8,d0
	clr.l	d1
	move.b	d0,d1
	divu	#100,d1
	beq.s	biptodip_hundreds_done
	add.b	#'0',d1
	move.b	d1,(a0)+
	clr.w	d1
biptodip_hundreds_done:
	swap	d1
	divu	#10,d1
	bne.s	.use_tens_digit
	cmpa.l	a0,a1			;no hundreds digit ?
	beq.s	biptodip_tens_done
.use_tens_digit:
	add.b	#'0',d1
	move.b	d1,(a0)+
	clr.w	d1
biptodip_tens_done:
	swap	d1
	add.b	#'0',d1
	move.b	d1,(a0)+
	move.b	#'.',(a0)+
	dbra	d2,biptodip_loop
	clr.b	-(a0)
	move.l	a0,d0
	rts
;
;end of function biptodip
;-------------------------------------------------------------------------------------)
;char	*biptodrip(uint32 ip_n, char *s_p)
;
biptodrip:
	moveq	#4-1,d2
biptodrip_loop:
	move.l	a0,a1			;a1 = a0 = start of next number
	clr.l	d1
	move.b	d0,d1
	divu	#100,d1
	beq.s	biptodrip_hundreds_done
	add.b	#'0',d1
	move.b	d1,(a0)+
	clr.w	d1
biptodrip_hundreds_done:
	swap	d1
	divu	#10,d1
	bne.s	.use_tens_digit
	cmpa.l	a0,a1			;no hundreds digit ?
	beq.s	biptodrip_tens_done
.use_tens_digit:
	add.b	#'0',d1
	move.b	d1,(a0)+
	clr.w	d1
biptodrip_tens_done:
	swap	d1
	add.b	#'0',d1
	move.b	d1,(a0)+
	move.b	#'.',(a0)+
	ror.l	#8,d0
	dbra	d2,biptodrip_loop
	clr.b	-(a0)
	move.l	a0,d0
	rts
;
;end of function biptodrip
;-------------------------------------------------------------------------------------)
;char *pass_RRname(char *data_p, char *pos_p, char *dest_p)
;
pass_RRname:
	move.l	a2,-(sp)
	move.l	8(sp),a2
	clr.l	d2
.loop_2:
	clr	d0
	move.b	(a1)+,d0
	beq.s	.exit
	bpl.s	.no_compr
	and	#$3F,d0		;d0 == compression mark ?
	lsl	#8,d0
	move.b	(a1)+,d0	;d0 = compressed label
	tst.l	d2		;done some expansion ?
	bne.s	.keep_d2
	move.l	a1,d2		;d2 = a1 -> type beyond current name name
.keep_d2:
	lea	-12(a0,d0),a1	;a1 -> expansion label
	bra.s	.loop_2		;go expand label
;
.no_compr:
	move.l	a2,d1		;dest_p == NULL ?
	beq.s	.skip_1
	subq	#1,d0
.loop_1:
	move.b	(a1)+,(a2)+	;store string
	dbra	d0,.loop_1
	move.b	#'.',(a2)+	;store '.'
	bra.s	.loop_2
;
.skip_1:
	add	d0,a1		;pass string
	bra.s	.loop_2
;
.exit:
	move.l	a2,d1		;dest_p == NULL ?
	beq.s	.skip_2
	cmp.b	#'.',-(a2)
	bne.s	.skip_2
	clr.b	(a2)
.skip_2:
	tst.l	d2		;done some expansion ?
	bne.s	.return_d2
	move.l	a1,d2		;d2 = a1 -> type beyond current name
.return_d2:
	movem.l	(sp)+,a2
	move.l	d2,a0
	rts
;
;-------------------------------------------------------------------------------------)
;void	illegal(void)
;void	illegal_n(int16)
;
illegal:
illegal_n:
	illegal
	rts
;
;end of functions illegal_n & illegal
;-------------------------------------------------------------------------------------)
;
            .end
;
;----------------------------------------------------------------------------
;End of file:	RESO_SUB.S
;----------------------------------------------------------------------------
