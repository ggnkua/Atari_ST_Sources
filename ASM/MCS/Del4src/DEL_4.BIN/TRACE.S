	move.w	#$2700,sr
	move.l	#vbl_wait,$70.w
	move.w	#$2300,sr
	stop	#$2300
	stop	#$2300

	lea	deb(pc),a0
	lea	$c00(a0),a1
	lea	$78000,a2
reloc
	move.l	(a0)+,(a2)+
	cmp.l	a0,a1
	bge.s	reloc

	jmp	$78000
vbl_wait
	rte
deb
	org	$78000
	moveq	#0,d7
	lea	fuck,a0
	move.l	#new,$24.w
	ori.w	#$8000,sr

	nop
decode
	incbin	final.bin
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
	move.l	#decode,2(sp)
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
	ds.l	1
fuck
	ds.l	1
	dc.b	'fin!'