	import dsp_bootbin
	import dsp_bootlen
	import dsp_codebin
	import dsp_codelen
	export dsp_load

dsp_load:
	movem.l	d0-a6,-(sp)
	bsr	dsp_reset
	bsr	dsp_uplbootstrap
;	bsr	dsp_uplcode
;	bsr	dsp_start
	movem.l	(sp)+,d0-a6
	rts

dsp_reset:
	move.b	#14,$ffff8800.w
	move.b	$ffff8800.w,d0
	and.b	#$ef,d0
	move.b	d0,$ffff8802.w
	or.b	#$10,d0
	move.b	d0,$ffff8802.w
	
; wait ?
	clr.l	$4ba.w
.wait:
	cmp.l	#10,$4ba.w
	bne.w	.wait

	move.b	#14,$ffff8800.w
	move.b	$ffff8800.w,d0
	and.b	#$ef,d0
	move.b	d0,$ffff8802.w
	
	move.b	#$80,$ffffa200.w
	
	rts
	
dsp_uplbootstrap:
	move.l	dsp_bootbin,a0
	move.w	dsp_bootlen,d0
	move.w	#512,d1
	sub.w	d0,d1
	subq.w	#1,d0
.uploadl:
	btst.b	#1,$ffffa202.w
	beq.s	.uploadl
	move.b	(a0)+,$ffffa205.w
	move.b	(a0)+,$ffffa206.w
	move.b	(a0)+,$ffffa207.w
	dbra	d0,.uploadl

	subq.w	#1,d1
.paddingl:
	btst.b	#1,$ffffa202.w
	beq.s	.paddingl
	move.b	#0,$ffffa205.w
	move.b	#0,$ffffa206.w
	move.b	#0,$ffffa207.w
	dbra	d1,.paddingl
	rts
	
dsp_uplcode:
	move.l	dsp_codebin,a0
	move.w	dsp_codelen,d0
	subq.w	#1,d0
.uploadl:
	btst.b	#1,$ffffa202.w
	beq.s	.uploadl
	move.b	(a0)+,$ffffa205.w
	move.b	(a0)+,$ffffa206.w
	move.b	(a0)+,$ffffa207.w
	dbra	d0,.uploadl
	rts
	
dsp_start:
.wait:
	btst.b	#1,$ffffa202.w
	beq.s	.wait
	move.l	#3,$ffffa204.w
	rts
	