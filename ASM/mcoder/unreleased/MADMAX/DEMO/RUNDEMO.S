CPU=0
DMALOAD=1

long=159000
decr=$68000
ram=decr-1026-256
load=ram-long

	pea	file(pc)
	move	#$3d,-(sp)	;Open
	trap	#1
	addq	#6,sp
	move.l	d0,d7
	bmi	erreur

	pea	load
	pea	long
	move	d7,-(sp)
	move	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bmi.s	erreur
;
; on ne close pas le fichier (inutile)
;
	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	move	#$2700,sr
	lea	$80000,sp

	lea	DECRUNCHER(pc),a0
	lea	FIN_DECRUNCHER(pc),a1
	lea	decr,a2
copy	move.l	(a0)+,(a2)+
	cmp.l	a1,a0
	blo.s	copy
	jmp	decr

erreur:
	illegal
file:	dc.b	'MCODER.CMP',0
	even
;
; nouveau d‚packer optimis‚ !!!
;
; D5 INUTILISE !!!
;
WAITDMA	MACRO
	IFEQ	DMALOAD
.\@	cmp.l	buffer.w,a0
	bhs.s	.\@
	ENDC
	MOVE	(A0)+,D2
	IFEQ	CPU
	MOVE	D2,$FFFF8240.W		;plus beau
	ENDC
	ADDX	D2,D2
	ENDM
RDBYTE	macro
	move.l	a2,a5
	move	d1,d0
.\@1	add	d2,d2
	bne.s	.\@2
	WAITDMA
.\@2	bcc.s	.\@3
	add	d0,a5
.\@3	move	(a5)+,d0
	bpl.s	.\@1
	endm
;
; DECRUNCHER MIXTE (HUFFMANN+PACK)
;
DECRUNCHER:
	lea	load,a0
	lea	$4800.w,a1
	LEA	ram,a2
;
;	a0=source
;	a1=destination
;	a2=adresse de d‚but de l'arbre (1026+256 octets)
;
	TAS	D0
	NEG	D0

	MOVE.L	a2,a3
	BSR	.DECODE0
	MOVE	(a2)+,D1
	moveq	#0,d4
	move.l	a3,a4
	moveq	#256/4-1,d0
.clear:	move.l	d4,(a4)+
	dbra	d0,.clear
	lea	.codes2(pc),a4
	moveq	#12-1,d3
.copy:
	bsr	.byte
	move.b	d0,d4
	move.b	(a4)+,(a3,d4.w)
	dbra	d3,.copy
	bra.s	.traduit
.sure:
	jmp	$4800.w
.base:
	move.b	d0,(a1)+
.traduit:
	RDBYTE

	cmp.l	a3,a5
	bhs.s	.sure
	move.b	d0,d4
	move.b	(a3,d4.w),d4
	jmp	.base(pc,d4.w)
.meth0:
	bsr	.byte
	bra.s	.base
.meth1:
	bsr	.byte
	move.b	d0,d6
.meth3:
	moveq	#0,d3
.meth2xx:
	bsr	.byte
	move.b	d0,d3
	move.b	d6,(a1)+
	move.b	d6,(a1)+
.meth2x:
	move.b	d6,(a1)+
	dbra	d3,.meth2x
	bra.s	.traduit
.meth2:
	bsr	.byte
	move.b	d0,d6

	bsr	.byte8
	bra.s	.meth2xx
.meth4:
	moveq	#0,d3
.cnt8:
	bsr	.byte
	move.b	d0,d3
	neg	d3
	lea	-2(a1,d3.w),a4
	moveq	#0,d3
.copy4:
	bsr	.byte
	move.b	d0,d3
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
.meth4x:move.b	(a4)+,(a1)+
	dbra	d3,.meth4x
	bra.S	.traduit
.meth5:
	moveq	#0,d3
.cnt16:
	bsr.s	.byte
	move.b	d0,d3
	neg	d3
	lea	-2(a1,d3.w),a4
	bsr.s	.byte8
	bra.s	.copy4
.meth6:
	bsr.s	.byte8
	bra.s	.cnt8
.meth7:
	bsr.s	.byte8
	bra.s	.cnt16
.meth8:
	bsr.s	.byte
	and	#$ff,d0
	neg	d0
	lea	-2(a1,d0.w),a4

	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+

	bra	.traduit
.meth9:
	bsr.s	.byte
	move.b	d0,d4
	bsr.s	.byte
	move.b	d0,d3
	bsr.s	.byte
	and	#$ff,d0
	addq	#4,d0
.meth9x:
	move.b	d4,(a1)+
	add.b	d3,d4
	dbra	d0,.meth9x
	bra	.traduit
.meth10:
	bsr.s	.byte
	move.b	d0,d7
.meth11:
	move.b	d7,(a1)+
	bsr.s	.byte
	move.b	d0,d4
	moveq	#8-1,d3
.meth10x:
	move.b	d7,d0
	add.b	d4,d4
	bcc.s	.nomsk1
	bsr.s	.byte
.nomsk1:
	move.b	d0,(a1)+
	dbra	d3,.meth10x
	bra	.traduit
.byte8:
	bsr.s	.byte
	addq.b	#1,d0
	move.b	d0,d3
	asl	#8,d3
	rts
.byte:
	MOVE.L	a2,a5
	MOVE	D1,D0
.X1:	ADD	D2,D2
	BEQ.S	.X2
	BCC.S	.X3
	ADD	D0,a5
.X3:	MOVE	(a5)+,D0
	BPL.S	.X1
	rts
.X2:
	WAITDMA
	BCC.S	.X4
	ADD	D0,a5
.X4:	MOVE	(a5)+,D0
	BPL.S	.X1
	RTS
.DECODE3:
	ADDQ	#2,a3
	PEA	(a3)
	BSR.S	.DECODE
	MOVE.L	(sp)+,a5
	MOVE	a3,D0
	SUB	a5,D0
	MOVE	D0,-(a5)
.DECODE:
	ADD	D2,D2
	BNE.S	.TSTCARY2
.DECODE0:
	WAITDMA
.TSTCARY2:
	BCC.S	.DECODE3

	MOVE	#$8001,D0
.L1F2EE:ADD	D2,D2
	BNE.S	.TSTCARY3
	WAITDMA
.TSTCARY3:
	ADDX.B	D0,D0
	BCC.S	.L1F2EE
	MOVE	D0,(a3)+
	rts
.codes2:
	dc.b	.meth11-.base,.meth10-.base,.meth9-.base,.meth8-.base
	dc.b	.meth7-.base,.meth6-.base,.meth5-.base,.meth4-.base
	dc.b	.meth3-.base,.meth2-.base,.meth1-.base,.meth0-.base
FIN_DECRUNCHER
