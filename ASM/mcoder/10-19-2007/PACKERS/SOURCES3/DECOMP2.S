	LEA	$80000,A0	;SOURCE
	LEA	$100000,A1	;DEST
;
;	a0=source
;	a1=destination
;	a2=adresse de d‚but de l'arbre (1026+256 octets)
;
	LEA	HUFFTAB,A2
	BSR	DECOMP

COMP:
	LEA	$180000,A0
	LEA	$100000,A1
O:	CMPM.L	(A0)+,(A1)+
	BEQ.S	O
	ILLEGAL

TOPO8=1				;0=topo 8 bits, 1=topo 9 bits

WAITDMA:MACRO
	MOVE	(A0)+,D2
;	MOVE	D2,$FFFF8240.W		;plus beau
	ADDX	D2,D2
	ENDM

nbmeth=12
DECOMP:
;
;	a0=source
;	a1=destination
;	a2=adresse de d‚but de l'arbre (1026+12 octets)
;
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
	RTS
base:
	move.b	d0,(a1)+
traduit:
	move.l	a2,a5
	move	d1,d0
rdbyt1:	add	d2,d2
	bne.s	rdbyt2
	WAITDMA
rdbyt2:	bcc.s	rdbyt3
	add	d0,a5
rdbyt3:	move	(a5)+,d0
	bpl.s	rdbyt1

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
	moveq	#0,d3
meth2xx:
	bsr	byte
	move.b	d0,d3
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
	addq	#1,d0
	move.b	d0,d3
	asl	#8,d3
	bra.s	meth2xx
meth4:
	moveq	#0,d3
cnt8:
	bsr	byte
	move.b	d0,d3
	neg	d3
	lea	-2(a1,d3.w),a4
	moveq	#0,d3
copy4:
	bsr	byte
	move.b	d0,d3
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
meth4x:	move.b	(a4)+,(a1)+
	dbra	d3,meth4x
	bra.s	traduit
meth5:
	moveq	#0,d3
cnt16:
	bsr.s	byte
	move.b	d0,d3
	neg	d3
	lea	-2(a1,d3.w),a4
	bsr.s	byte
	addq	#1,d0
	move.b	d0,d3
	asl	#8,d3
	bra.s	copy4
meth6:
	bsr.s	byte
	addq	#1,d0
	move.b	d0,d3
	asl	#8,d3
	bra.s	cnt8
meth7:
	bsr.s	byte
	addq	#1,d0
	move.b	d0,d3
	asl	#8,d3
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
	if	TOPO8=1
	move.b	d7,(a1)+
	endif
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
	even
HUFFTAB:
	BLK.B	1026+256
	EVEN
