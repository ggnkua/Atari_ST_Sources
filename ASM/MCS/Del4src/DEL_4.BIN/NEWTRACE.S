
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq	#6,sp

	moveq	#0,d7
	lea	fuck,a0
	move.l	#new,$24.w
	ori.w	#$8000,sr

	nop
decode
	incbin	coded.bin
fin_code
	nop
new
	move.w	d7,(a0)
	move.l	2(sp),a0
	move.w	(a0),d7
	cmp.l	#fin_code,a0
	beq.s	fin_trace
	bsr	protect_d7
jmp
	rte
fin_trace
	move.l	#jmp,$24.w
	move.l	#fin_protect,2(sp)
	rte
protect_d7
	move.l	#new,a1
	move.w	(a1)+,d0
	cmp.l	#jmp,a1
	bne.s	pas_jmp
	move.l	#new,a1
pas_jmp
	move.l	a1,protect_d7+2
	move.w	fin_trace+6,d6
	sub.l	a2,a2
	move	d6,a2
	move.l	(a2),a2
	sub.l	#decode,a2
	move	a2,d6
	eor	d6,d0
	eor	d0,d7
	move.w	#$4e71,(a0)
	rts

fin_protect
	move.w	#0,-(sp)
	pea	fname
	move.w	#$3c,-(sp)
	trap	#1
	addq	#8,sp
	move.w	d0,handle
	
	pea	decode
	move.l	#fin_code-decode,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	lea	12(sp),sp

	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq	#4,sp

	clr.l	-(sp)
	trap	#1
handle
	ds.l	1
fname
	dc.b	"final.bin",0
	even
	ds.l	1
fuck
	ds.l	1