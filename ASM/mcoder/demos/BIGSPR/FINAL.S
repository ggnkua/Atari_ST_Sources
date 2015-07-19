	OUTPUT	FINAL.TOS
	OPT	O+
START = $6000
TOPO8 = 1			;0=topo 8 bits, 1=topo 9 bits
longueur = ((50076)+1)&-2	;LONGUEUR FICHIER DECOMPRESSE

	PEA	MESSAGE(PC)
	MOVE	#9,-(SP)
	TRAP	#1
	ADDQ	#6,SP

;	MOVE	SR,D0
;	AND	#$2000,D0
;	BNE.S	SUPER
	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp
;SUPER:
	move	#$2700,sr
	lea	START,a7

	lea	fin,a2
	lea	debut(pc),a0
	cmp.l	#START+longueur,a0
	bhs.s	debut
;
; d‚place le programme vers le haut de la m‚moire
;
	move.l	a2,a0
	lea	START+longueur+fin-debut,a1
	move.l	a1,a2
	move	#(fin-debut+3)/4-1,d0
transfere
	move.l	-(a0),-(a1)
	dbra	d0,transfere
	jmp	START+longueur
WAITDMA	MACRO
	MOVE	(A0)+,D2
	MOVE	D2,$FFFF8240.W		;plus beau
	ADDX	D2,D2
	ENDM
RDBYTE	macro
	move.l	a2,a5
	move	d1,d0
\@1	add	d2,d2
	bne.s	\@2
	WAITDMA
\@2	bcc.s	\@3
	add	d0,a5
\@3	move	(a5)+,d0
	bpl.s	\@1
	endm
inc	macro
	addq	#1,d0
	endm

nbmeth = 12

debut
;
;	a0=source
;	a1=destination
;	a2=adresse de d‚but de l'arbre (1026+12 octets)
;
	lea	pak(pc),a0
	MOVE.L	A7,a1
	TAS	D0
	NEG	D0

	MOVE.L	a2,a3
	BSR	DECODE0
	MOVE	(a2)+,D1
	moveq	#0,d4
	move.l	a3,a4
	moveq	#256/4-1,d0
clear:	move.l	d4,(a4)+
	dbra	d0,clear
	lea	codes2+12(pc),a4
	moveq	#nbmeth-1,d3
copy:
	bsr	byte
	move.b	d0,d4
	move.b	-(a4),(a3,d4.w)
	dbra	d3,copy
	bra.s	traduit
sure:
	jmp	(A7)
base:
	move.b	d0,(a1)+
traduit:
	RDBYTE

	cmp.l	a3,a5
	bhs.s	sure
	move.b	d0,d4
	move.b	(a3,d4.w),d4
	jmp	base(pc,d4.w)
meth0:
	bsr	byte
	bra.s	base
meth1:
	bsr	byte
	move.b	d0,d6
meth3:
	bsr	byte
	moveq	#0,d3
	move.b	d0,d3
meth2xx:
	move.b	d6,(a1)+
	move.b	d6,(a1)+
meth2x:
	move.b	d6,(a1)+
	dbra	d3,meth2x
	bra.s	traduit
meth2:
	bsr	byte
	move.b	d0,d6

	bsr	byte
	inc
	move.b	d0,d3
	asl	#8,d3
	bsr	byte
	move.b	d0,d3
	bra.s	meth2xx
meth4:
	bsr	byte
	moveq	#0,d3
	move.b	d0,d3
cnt8:
	neg	d3
	lea	-2(a1,d3.w),a4
	bsr	byte
	moveq	#0,d3
	move.b	d0,d3
copy4:
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
meth4x:	move.b	(a4)+,(a1)+
	dbra	d3,meth4x
	bra	traduit
meth5:
	bsr	byte
	moveq	#0,d3
	move.b	d0,d3
cnt16:
	neg	d3
	lea	-2(a1,d3.w),a4
	bsr.s	byte
	inc
	move.b	d0,d3
	asl	#8,d3
	bsr.s	byte
	move.b	d0,d3
	bra.s	copy4
meth6:
	bsr.s	byte
	inc
	move.b	d0,d3
	asl	#8,d3
	bsr.s	byte
	move.b	d0,d3
	bra.s	cnt8
meth7:
	bsr.s	byte
	inc
	move.b	d0,d3
	asl	#8,d3
	bsr.s	byte
	move.b	d0,d3
	bra.s	cnt16
meth8:
	bsr.s	byte
	and	#$ff,d0
	neg	d0
	lea	-2(a1,d0.w),a4

	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+

	bra	traduit
meth9:
	bsr.s	byte
	move.b	d0,d5
	bsr.s	byte
	move.b	d0,d4
	bsr.s	byte
	and	#$ff,d0
	addq	#4,d0
meth9x:
	move.b	d5,(a1)+
	add.b	d4,d5
	dbra	d0,meth9x
	bra	traduit
meth10:
	bsr.s	byte
	move.b	d0,d7
meth11:
	ifne	TOPO8
	move.b	d7,(a1)+
	endc
	bsr.s	byte
	move.b	d0,d4
	moveq	#8-1,d3
meth10x:
	move.b	d7,d0
	add.b	d4,d4
	bcc.s	nomsk1
	bsr.s	byte
nomsk1:
	move.b	d0,(a1)+
	dbra	d3,meth10x
	bra	traduit
byte:
	MOVE.L	a2,a5
	MOVE	D1,D0
X1:	ADD	D2,D2
	BEQ.S	X2
	BCC.S	X3
	ADD	D0,a5
X3:	MOVE	(a5)+,D0
	BPL.S	X1
	rts
X2:
	WAITDMA
	BCC.S	X4
	ADD	D0,a5
X4:	MOVE	(a5)+,D0
	BPL.S	X1
	RTS
DECODE3:
	ADDQ	#2,a3
	PEA	(a3)
	BSR.S	DECODE
	MOVE.L	(A7)+,a5
	MOVE	a3,D0
	SUB	a5,D0
	MOVE	D0,-(a5)
DECODE:
	ADD	D2,D2
	BNE.S	TSTCARY2
DECODE0:
	WAITDMA
TSTCARY2:
	BCC.S	DECODE3

	MOVE	#$8001,D0
L1F2EE:	ADD	D2,D2
	BNE.S	TSTCARY3
	WAITDMA
TSTCARY3:
	ADDX.B	D0,D0
	BCC.S	L1F2EE
	MOVE	D0,(a3)+
	rts
codes2:
	dc.b	meth0-base,meth1-base,meth2-base,meth3-base
	dc.b	meth4-base,meth5-base,meth6-base,meth7-base
	dc.b	meth8-base,meth9-base,meth10-base,meth11-base
MESSAGE
	DC.B	'M-depacker in action',0
	even
pak	INCBIN	BIGSPR14.CMP
	even
fin
