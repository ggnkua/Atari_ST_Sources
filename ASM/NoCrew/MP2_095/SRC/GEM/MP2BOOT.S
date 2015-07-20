; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;              - DSP loader -
;        a NoCrew production MCMXCV
;
;         (c) Copyright NoCrew 1995
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; Main module.

	import dsp_bootbin
	import dsp_bootlen
	import dsp_codebin
	import dsp_codelen
	export dsp_load

	text

dsp_load:
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	DSP_allocate
	bsr	DSP_reset
	bsr	DSP_go
	movem.l	(sp)+,d0-d7/a0-a6
	rts

DSP_allocate:
	move.l	dsp_bootbin,a0
	lea	DSP_mem,a1
	move.w	dsp_bootlen,d0

	move.l	#512,d1
	moveq	#0,d2
.next:	subq.w	#6,d0
	bmi.s	.exit
	addq.w	#4,a0	; Must be program memory
	move.w	(a0)+,d3	; address
	cmp.w	#$7ea9,d3
	beq.s	.ok

.no:	sub.l	d2,d3
	subq.w	#1,d3
	bmi.s	.ok

	subq.w	#1,d1
	bmi.s	.exit
.zero:	clr.w	(a1)+
	clr.b	(a1)+
	addq.l	#1,d2
	dbra	d3,.zero

.ok:	subq.w	#3,d0
	bmi.s	.exit
	moveq	#0,d3
	move.w	(a0)+,d3
	lsl.l	#8,d3
	move.b	(a0)+,d3
.copy:	subq.w	#1,d3
	bmi.s	.next
	subq.w	#3,d0
	bmi.s	.exit
	subq.w	#1,d1
	bmi.s	.exit
	move.w	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	addq.l	#1,d2
	bra.s	.copy
.exit:	move.l	d2,d0
	rts

; Power up 'n power down.
DSP_reset:
	move.w	sr,d2
	move.w	#$2700,sr
	move.b	#$e,$ffff8800.w
	move.b	$ffff8800.w,d0
	and.b	#$ef,d0
	move.b	d0,$ffff8802.w
	or.b	#$10,d0
	move.b	d0,$ffff8802.w
	move.w	d2,sr

; Wait 0.04 sec for DSP power down.
	move.l	$4ba.w,d0
	addq.l	#2,d0
.wait:
	cmp.l	$4ba.w,d0
	bgt.s	.wait

; Power up again.
	move.w	#$2700,sr
	move.b	#$e,$ffff8800.w
	move.b	$ffff8800.w,d0
	and.b	#$ef,d0
	move.b	d0,$ffff8802.w
	move.w	d2,sr
	rts

; Load system startup code
DSP_go:
	lea	DSP_mem,a0
	move.w	#512-1,d0
.next:	btst.b	#1,$ffffa202.w
	beq.s .next
	move.b	(a0)+,$ffffa205.w
	move.b	(a0)+,$ffffa206.w
	move.b	(a0)+,$ffffa207.w
	dbra	d0,.next

	; Load DSP binary
	move.l	dsp_codebin,a0
	move.w	dsp_codelen,d0
	subq.w	#1,d0
	bmi.s	.no_way
.copy:	btst.b	#1,$ffffa202.w
	beq.s	.copy
	move.b	(a0)+,$ffffa205.w
	move.b	(a0)+,$ffffa206.w
	move.b	(a0)+,$ffffa207.w
	dbra	d0,.copy

	; Launch DSP binary
.go:	btst.b	#1,$ffffa202.w
	beq.s	.go
	move.l	#3,$ffffa204.w
.no_way:	rts

	data
DSP_mem:	ds.b	512*3

	end

	

