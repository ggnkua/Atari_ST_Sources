; MATHS.S: Additional integer maths and logic module
; Copyright <C> John Redmond 1989, 1990
; Public domain for non-commercial use.
;
	section	text
	even
;
;_XDMOD:	(u64,u64--u64,u64)
_xdmod: movem.l d2-d6,-(a7)
	moveq	#63,d6		;loop counter
	pop	d4
	pop	d5		;divisor
	pop	d2
	pop	d3		;dividend
	moveq	#0,d0
	moveq	#0,d1
.xdmlp: add.l	d3,d3
	addx.l	d2,d2
	addx.l	d1,d1	
	addx.l	d0,d0		;shift dividend left
	sub.l	d5,d1
	subx.l	d4,d0
	bcs	.xdm5		;if cannot divide
	addq.w	#1,d3
	dbra	d6,.xdmlp
	bra	.xdm6
.xdm5:	add.l	d5,d1		;cancel subtraction
	addx.l	d4,d0
	dbra	d6,.xdmlp
.xdm6:	push	d1
	push	d0		;remainder
	push	d3
	push	d2		;quotient
	movem.l (a7)+,d2-d6
	rts
;
;_DMOD: (n32,n32--rem32,quot32)
_dmod:	pop	d0
	move.l	d0,-(a7)	;save divisor sign
	move.l	d0,-(a7)	;will be quotient sign
	move.l	d0,-(a7)	;divisor
	move.l	(a6),d0		;dividend
	eor.l	d0,4(a7)	;net sign
	bsr	_abs		;abs dividend
	push	(a7)+
	bsr	_abs		;abs divisor
	bsr	_udmod
	move.l	(a7)+,d0	;quotient sign back
	bpl	.dmz
	bsr	_negate		;quotient
.dmx:	move.l	(a7)+,d0	;divisor sign back
	bmi	.dmy
	pop	-(a7)		;quotient
	bsr	_negate		;remainder
	push	(a7)+		;quotient
.dmy:	rts
.dmz:	move.l	(a7)+,d0	;divisor sign back
	bpl	.dmy
	pop	-(a7)		;quotient
	bsr	_negate		;remainder
	push	(a7)+		;quotient
	rts
;
; _DIV: (n32,n32--n32)
_div:	bsr	_dmod
	move.l	(a6)+,(a6)
	rts
;
; _USSMOD (u32,u32,u32--u32,u32)
_ussmod: pop	-(a7)		;divisor
	bsr	_uxmult
	push	(a7)+
	push	#0
	bsr	_xdmod		;64-bit division
	pop	d0
	pop	d1
	move.l	d1,(a6)		;trim results to 32 bits
	rts
;
_ssmod: pop	d0		;divisor
	move.l	d0,-(a7)	;divisor sign
	move.l	d0,-(a7)	;will be overall sign
	move	4(a6),d1
	eor.l	d1,(a7)
	move.l	8(a6),d1
	eor.l	d1,(a7)		;result sign
	move.l	d0,-(a7)	;save divisor
	pop	-(a7)
	bsr	_abs
	push	(a7)+
	bsr	_abs
	bsr	_uxmult
	push	(a7)+		;divisor
	bsr	_abs
	clr.l	-(a6)		;64 bits
	bsr	_xdmod		;64-bit division
	addq.l	#4,a6		;trim quotient to 32 bits
	move.l	(a7)+,d0	;quotient sign back
	bpl	.dmz
	bsr	_negate		;quotient
.dmx:	move.l	(a6)+,(a6)	;trim remainder
	move.l	(a7)+,d0	;divisor sign back
	bmi	.dmy
	pop	-(a7)		;quotient
	bsr	_negate		;remainder
	push	(a7)+		;quotient
.dmy:	rts
.dmz:	move.l	(a6)+,(a6)	;trim remainder
	move.l	(a7)+,d0	;divisor sign back
	bpl	.dmy
	pop	-(a7)		;quotient
	bsr	_negate		;remainder
	push	(a7)+		;quotient
	rts
;
_ssl:	bsr	_ssmod
	move.l	(a6)+,(a6)	;drop remainder
	rts
;
; _MOD: (n32,n32--n32)
_mod:	bsr	_dmod
	addq.l	#4,a6
	rts
;
_mult:	pop	d0
	move.l	d0,-(a7)	;for product sign
	move.l	d0,-(a7)	;multiplier
	pop	d0
	eor.l	d0,4(a7)	;overall sign
	push	d0
	bsr	_abs
	push	(a7)+		;multiplier back
	bsr	_abs
	bsr	_uxmult
	addq.l	#4,a6		;drop top 32 bits
	tst.l	(a7)+
	bpl	.multx
	bsr	_negate
.multx:
	rts
;
; _XMULT: (n32,n32--n64)
_xmult: move.l	d5,-(a7)
	move.l	(a6),d5
	move.l	4(a6),d0	;get net sign
	eor.l	d0,d5
	move.l	d5,-(a7)
	bsr	_abs
	move.l	(a6)+,-(a7)
	bsr	_abs
	move.l	(a7)+,-(a6)
	bsr	_uxmult
	tst.l	(a7)+		;get sign back
	bpl	.xmultx
	bsr	_xnegate
.xmultx: move.l (a7)+,d5
	rts
;
_abs:	pop	d0
	bpl	.absx
	neg.l	d0
.absx	push	d0
	rts
;
_xabs:	tst.w	(a6)		;64-bit
	bpl	.xabsx
	neg.l	4(a6)
	negx.l	(a6)
.xabsx	rts
;
_min:	pop	d0
	pop	d1
	cmp.l	d1,d0
	ble	.mx
	move.l	d1,d0
.mx:	push	d0
	rts
;
_max:	pop	d0
	pop	d1
	cmp.l	d1,d0
	bge	.mx
	move.l	d1,d0
.mx:	push	d0
	rts
;
	section	data
	even
;
;	dc.b	$81,'*'!$80
;	ptrs	_mult,14
;
	dc.b	$82,'D*',$a0
	ptrs	_xmult,16
;
	dc.b	$84,'/MOD',$A0
	ptrs	_dmod,18
;
	dc.b	$82,'*/',$a0
	ptrs	_ssl,16
;
	dc.b	$86,'U*/MOD',$a0
	ptrs	_ussmod,20
;
	dc.b	$85,'*/MO','D'!$80
	ptrs	_ssmod,18
;
;	dc.b	$81,'/'!$80
;	ptrs	_div,14
;
;	dc.b	$83,'MO','D'!$80
;	ptrs	_mod,16
;
	dc.b	$86,'UD/MOD',$a0
	ptrs	_xdmod,20
;
	dc.b	$83,'MI','N'!$80
	ptrs	_min,16
;
	dc.b	$83,'MA','X'!$80
	ptrs	_max,16
;
;	dc.b	$83,'AB','S'!$80
;	ptrs	_abs,16
;
	dc.b	$84,'DABS',$a0
	ptrs	_xabs,18
;
