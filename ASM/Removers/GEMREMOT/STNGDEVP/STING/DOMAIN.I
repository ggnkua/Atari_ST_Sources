;----------------------------------------------------------------------------
; File name:	DOMAIN.I			Revision date:	1998.09.08
; Authors:	Ronald Andersson		Creation date:	1997.08.01
;----------------------------------------------------------------------------
; Purpose:	Defines constants and macros which are useful in handling
;		domain names and IP addresses, including some conversions.
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	IFND	STinG_DOMAIN_defined
STinG_DOMAIN_defined	set	1
;----------------------------------------------------------------------------
	include	RA_STRUC.I	;needed for C-style structure definitions
	include	RA_SYS.I	;needed for lots of things...
;----------------------------------------------------------------------------
;NB: Having used any of the macros, you have to include a call like this:
;
;		make	DOMAIN_links
;
;    This must be somewhere in the executable code, after all the macros
;    that are to be used in the program have been called at least once.
;    Thus a suitable place is usually at the end of the 'TEXT' section.
;----------------------------------------------------------------------------
;Available macros and their usage:
;
;char	*is_domname(char *string, len)	=> a0->domain_name/NULL, passing whitespace
;char	*is_dip(char *string)		=> a0->dotted_ip/NULL, passing whitespace
;char	*is_unblank(char *string)	=> a0->unblank_string/NULL, passing whitespace
;char	*next_dip(char *string)		=> a0->char_after_next_comma/NULL
;char	*skip_space(char *string)	=> a0->next_unblank/terminator, passing whitespace
;uint32	diptobip(char *s_p)			a0->dotted_IP => d0= binary_IP
;char	*biptodip(uint32 ip_n, char *s_p)	d0==binary_IP => a0->dotted_IP
;char	*biptodrip(uint32 ip_n, char *s_p)	d0==binary_IP => a0->dotted_reversed_IP
;char *pass_RRname(char *data_p, char *pos_p, char *dest_p)	passes DNS records
;----------------------------------------------------------------------------
DOMAIN_links	MACRO
	_unidef	is_domname,is_dip,is_unblank
	_unidef	next_dip,skip_space
	_unidef	diptobip,biptodip,biptodrip
	_unidef	pass_RRname
	ENDM	;DOMAIN_links
;----------------------------------------------------------------------------
;char	*is_domname(char *string, len)	/* flags -> domain name */
;
is_domname	MACRO	string_p,len
	PUREC_func.\0	is_domname,2,7,\1,\2
	ENDM	;is_domname
;------------------------------------
is_domname_code	MACRO
	movem.l	d1-d2/a1,-(sp)
	move.l	a0,d1		;NULL string ?
	beq.s	.exit
	move.l	a0,a1		;a1 = a0 = string
	move	d0,d2		;d2 = len
	ble.s	.label_bad
	skip_space	(a0)	;string passed to non-blank
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
	movem.l	(sp)+,d1-d2/a1
	rts			;return a0 -> domname
;
.test_char:
	move.b	(a1)+,d1	;d1 = current char
	beq.s	.label_bad
	cmp.b	#'.',d1
	beq.s	.label_start
	tst	d2
	beq.s	.test_alfa
	cmp.b	#'-',d1
	beq.s	.label_char
	cmp.b	#'0',d1
	blo.s	.label_bad
	cmp.b	#'9',d1
	bls.s	.label_char
.test_alfa:
	st	d2
	cmp.b	#'A',d1
	blo.s	.label_bad
	cmp.b	#'Z',d1
	bls.s	.label_char
	cmp.b	#'a',d1
	blo.s	.label_bad
	cmp.b	#'z',d1
	bls.s	.label_char
.label_bad:
	suba.l	a0,a0		;return NULL on error
.exit:
	movem.l	(sp)+,d1-d2/a1
	rts
	ENDM	;is_domname_code
;----------------------------------------------------------------------------
;char	*is_dip(char *string)		/* flags -> dotted ip */
;
is_dip	MACRO	string_p
	PUREC_func.\0	is_dip,1,3,\1
	ENDM	;is_dip
;------------------------------------
is_dip_code	MACRO
	movem.l	d1/a1,-(sp)
	move.l	a0,d0
	beq.s	.exit
	skip_space	(a0)
	move.l	a0,a1
	moveq	#3,d1
.loop:
	move.b	(a0)+,d0
	cmp.b	#'.',d0
	bne.s	.try_digits
	dbra	d1,.loop
	bra.s	.make_null
;
.try_digits:
	cmp.b	#'0',d0
	blo.s	.test_dip
	cmp.b	#'9',d0
	bls.s	.loop
.test_dip:
	tst	d1
	bne.s	.make_null
	move.l	a1,a0
.exit:
	movem.l	(sp)+,d1/a1
	rts
;
.make_null:
	suba.l	a0,a0
	movem.l	(sp)+,d1/a1
	rts
	ENDM	;is_dip_code
;----------------------------------------------------------------------------
;char	*is_unblank(char *string)	/* flags -> unblank string */
;
is_unblank	MACRO	string_p
	PUREC_func.\0	is_unblank,1,3,\1
	ENDM	;is_unblank
;------------------------------------
is_unblank_code	MACRO
	move.l	a0,d0
	beq.s	.exit
	skip_space	(a0)
	tst.b	(a0)
	bne.s	.exit
	suba.l	a0,a0
.exit:
	rts
	ENDM	;is_unblank_code
;----------------------------------------------------------------------------
;char	*next_dip(char *string)		/* passes comma-separated arguments */
;
next_dip	MACRO	string_p
	PUREC_func.\0	next_dip,1,3,\1
	ENDM	;next_dip
;------------------------------------
next_dip_code	MACRO
.loop:
	move.l	a0,d0
	beq.s	.exit
	move.b	(a0)+,d0
	beq.s	.back_a0		;refuse to pass terminator
	cmp.b	#';',d0
	beq.s	.pass_tail	;pass entire comment
	cmp.b	#',',d0
	bne.s	.loop	;accept comma as separator
	skip_space	(a0)
	rts
;
.pass_tail:
	tst.b	(a0)+
	bne.s	.pass_tail	;pass all non-terminators
.back_a0:
	subq	#1,a0		;back a0 to terminator
.exit:
	rts
	ENDM	;next_dip_code
;----------------------------------------------------------------------------
;char	*skip_space(char *string)	/* skips leading spaces & tabs */
;
skip_space	MACRO	string_p
	PUREC_func.\0	skip_space,1,3,\1
	ENDM	;skip_space
;------------------------------------
skip_space_code	MACRO
.loop:
	move.l	a0,d0
	beq.s	.exit
	move.b	(a0)+,d0
	cmp.b	#' ',d0		;space ?
	beq.s	.loop		;pass leading spaces
	cmp.b	#$09,d0		;HT ?
	beq.s	.loop		;pass leading tabs
	subq	#1,a0
.exit:
	rts
	ENDM	;skip_space_code
;----------------------------------------------------------------------------
;uint32	diptobip(char *s_p)
;
diptobip	MACRO	string_p
	PUREC_func.\0	diptobip,1,3,\1
	ENDM	;diptobip
;------------------------------------
diptobip_code	MACRO
	movem.l	d1-d2,-(sp)
	skip_space	(a0)
	moveq	#-1,d0
	cmp.b	#'0',(a0)
	blo.s	.exit
	cmp.b	#'9',(a0)
	bhi.s	.exit
	clr.l	d0
	moveq	#4-1,d2
.loop_1:
	clr	d1
.loop_2:
	cmp.b	#'0',(a0)
	blo.s	.exit_loop_2
	cmp.b	#'9',(a0)
	bhi.s	.exit_loop_2
	mulu	#10,d1
	add.b	(a0)+,d1
	sub	#'0',d1
	and	#$FF,d1
	bra.s	.loop_2
;
.exit_loop_2:
	lsl.l	#8,d0
	or.l	d1,d0
	cmp.b	#'.',(a0)+
	beq.s	.next_loop_1
	subq	#1,a0
.next_loop_1:
	dbra	d2,.loop_1
.exit:
	movem.l	(sp)+,d1-d2
	rts
	ENDM	;diptobip_code
;----------------------------------------------------------------------------
;char	*biptodip(uint32 ip_n, char *s_p)
;
biptodip	MACRO	ip_n,string_p
	PUREC_func.\0	biptodip,2,$E,\1,\2
	ENDM	;biptodip
;------------------------------------
biptodip_code	MACRO
	movem.l	d1-d2,-(sp)
	moveq	#4-1,d2
.loop:
	move.l	a0,a1			;a1 = a0 = start of next number
	rol.l	#8,d0
	clr.l	d1
	move.b	d0,d1
	divu	#100,d1
	beq.s	.hundreds_done
	add.b	#'0',d1
	move.b	d1,(a0)+
	clr.w	d1
.hundreds_done:
	swap	d1
	divu	#10,d1
	bne.s	.use_tens_digit
	cmpa.l	a0,a1			;no hundreds digit ?
	beq.s	.tens_done
.use_tens_digit:
	add.b	#'0',d1
	move.b	d1,(a0)+
	clr.w	d1
.tens_done:
	swap	d1
	add.b	#'0',d1
	move.b	d1,(a0)+
	move.b	#'.',(a0)+
	dbra	d2,.loop
	clr.b	-(a0)
	move.l	a0,d0
	movem.l	(sp)+,d1-d2
	rts
	ENDM	;biptodip_code
;----------------------------------------------------------------------------
;char	*biptodrip(uint32 ip_n, char *s_p)
;
biptodrip	MACRO	ip_n,string_p
	PUREC_func.\0	biptodrip,2,$E,\1,\2
	ENDM	;biptodrip
;------------------------------------
biptodrip_code	MACRO
	movem.l	d1-d2,-(sp)
	moveq	#4-1,d2
.loop:
	move.l	a0,a1			;a1 = a0 = start of next number
	clr.l	d1
	move.b	d0,d1
	divu	#100,d1
	beq.s	.hundreds_done
	add.b	#'0',d1
	move.b	d1,(a0)+
	clr.w	d1
.hundreds_done:
	swap	d1
	divu	#10,d1
	bne.s	.use_tens_digit
	cmpa.l	a0,a1			;no hundreds digit ?
	beq.s	.tens_done
.use_tens_digit:
	add.b	#'0',d1
	move.b	d1,(a0)+
	clr.w	d1
.tens_done:
	swap	d1
	add.b	#'0',d1
	move.b	d1,(a0)+
	move.b	#'.',(a0)+
	ror.l	#8,d0
	dbra	d2,.loop
	clr.b	-(a0)
	move.l	a0,d0
	movem.l	(sp)+,d1-d2
	rts
	ENDM	;biptodrip_code
;----------------------------------------------------------------------------
;char *pass_RRname(char *data_p, char *pos_p, char *dest_p)
;
pass_RRname	MACRO	data_p,pos_p,dest_p
	PUREC_func.\0	pass_RRname,3,$3F,\1,\2,\3
	ENDM	;pass_RRname
;------------------------------------
pass_RRname_code	MACRO
	movem.l	d1-d2/a1-a2,-(sp)
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
	movem.l	(sp)+,d1-d2/a1-a2
	rts
	ENDM	;pass_RRname_code
;----------------------------------------------------------------------------
	ENDC	;STinG_DOMAIN_defined
;----------------------------------------------------------------------------
; End of file:	DOMAIN.I
;----------------------------------------------------------------------------
