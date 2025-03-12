;
; nouveau d‚packers optimis‚s avec relogeur
;
; 10/04/90
; 10/05/91 r‚vision+cleanage relogeur...
;
; D5,A6 inutilis‚s dans le d‚packer !!!
;
OFFSETMIN=2
nbmeth=12
MARK=1
TOPO8=1
ajuste=12		;12 pour Ivanho‚

WAITDMA	MACRO
;.\@	CMP.L	ADRESSE_DERNIER_OCTET_CHARGE,A0	;ATTENTE DMA DISK
;	BHS.S	.\@
	MOVE	(A0)+,D2
;	MOVE	D2,$FFFF8240.W			;plus beau
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

LITTLE_PLACE=$50

;
; DECRUNCHER MIXTE (HUFFMANN+PACK)
;
DECRUNCH0:
	DC.W	$601A
	DC.L	0
	DC.L	0
	DC.L	0
	DC.L	0
	DC.L	0
	DC.L	0
	DC.W	-1		;PAS DE RELOCATION
.base_page:
;
; on recopie le fichier pack‚ … la fin du fichier d‚pack‚
;
	move.l	.length(pc),d0
	lea	.pack(pc),a0
	add.l	d0,a0			;ptr source
	move.l	a0,a3

	lea	.pack+ajuste(pc),a1
	add.l	.longueur(pc),a1	;ptr dest
	move.l	a1,a2
	move.l	a2,a0
	sub.l	d0,a0

	addq.l	#7,d0
	lsr.l	#3,d0
.move_it:
	move.l	-(a3),-(a1)
	move.l	-(a3),-(a1)
	dbra	d0,.move_it

;	a0=source
;	a1=destination
;	a2=adresse de d‚but de l'arbre (1026+256 octets)

	lea	.pack(pc),a1

	bsr	.decomp

	lea	.base_page-$100(pc),a2
	lea	.pack(PC),A3
	TST	$1A(A3)
	BNE.S	.NORELOC
	MOVE.L	2(A3),A0
	ADD.L	6(A3),A0
	add.l	$e(a3),a0		;SKIPPE LABELS !!!!
	LEA	$1C(A3),A1
	add.l	a1,a0

	MOVE.L	(A0)+,D0
	BEQ.S	.NORELOC
	ADD.L	D0,A1
	MOVE.L	8(a2),D0
	MOVEQ	#0,D1
.RELOC1	ADD	D1,A1
	SUBQ.B	#1,D1
	BNE.S	.RELOC2
	LEA	$FE-1(A1),A1
	BRA.S	.RELOC3
.RELOC2	ADD.L	D0,(A1)
.RELOC3	MOVE.B	(A0)+,D1
	BNE.S	.RELOC1
.NORELOC
	MOVE.L	2(A3),d0
	MOVE.L	d0,$C(a2)
	MOVE.L	6(A3),$14(a2)
	MOVE.L	$A(A3),$1C(a2)
	ADD.L	8(a2),d0
	MOVE.L	d0,$10(a2)
	ADD.L	$14(a2),d0
	MOVE.L	d0,$18(a2)
	move.l	d0,a5

	movem.l	.MOVER(pc),d0-d3
	movem.l	d0-d3,LITTLE_PLACE(a2)	;on claque le d‚placeur
					;dans la Basepage !!!
	LEA	$1C(A3),A0
	MOVE.L	.longueur(PC),D2
	lea	.pack+ajuste+1026+256(pc),a3
	add.l	d2,a3

	ADDQ.L	#3,D2
	LSR.L	#2,D2
	lea	.base_page(pc),a1
	MOVEQ	#0,D0
	jmp	LITTLE_PLACE(a2)

.MOVER	MOVE.L	(A0)+,(A1)+	;16 octets
	SUBQ.L	#1,D2
	BNE.S	.MOVER
.CLEARER
	MOVE.L	D0,(A5)+
	CMP.L	A3,A5
	BLO.S	.CLEARER
	BRA	.MOVER+256-LITTLE_PLACE
.decomp
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
	moveq	#nbmeth-1,d3
.copy:
	bsr	.byte
	move.b	d0,d4
	move.b	(a4)+,(a3,d4.w)
	dbra	d3,.copy
	bra.s	.traduit
.sure:
	rts
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
	lea	-OFFSETMIN(a1,d3.w),a4
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
	lea	-OFFSETMIN(a1,d3.w),a4
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
	lea	-OFFSETMIN(a1,d0.w),a4

	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+

	bra	.traduit
.meth9:
	bsr.s	.byte
	move.b	d0,d3
	bsr.s	.byte
	move.b	d0,d4
	bsr.s	.byte
	and	#$ff,d0
	addq	#4,d0
.meth9x:
	move.b	d3,(a1)+
	add.b	d4,d3
	dbra	d0,.meth9x
	bra	.traduit
.meth10:
	bsr.s	.byte
	move.b	d0,d7
.meth11:
	ifne	TOPO8
	move.b	d7,(a1)+
	endc
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
	BNE.S	.TSTCARY1
.DECODE0:
	WAITDMA
.TSTCARY1:
	BCC.S	.DECODE3

	MOVE	#$8001,D0
.GETBIT:ADD	D2,D2
	BNE.S	.TSTCARY2
	WAITDMA
.TSTCARY2:
	ADDX.B	D0,D0
	BCC.S	.GETBIT
	MOVE	D0,(a3)+
	rts
.codes2:
	dc.b	.meth11-.base,.meth10-.base,.meth9-.base,.meth8-.base
	dc.b	.meth7-.base,.meth6-.base,.meth5-.base,.meth4-.base
	dc.b	.meth3-.base,.meth2-.base,.meth1-.base,.meth0-.base
	IFEQ	MARK
	DC.B	'MCMP'
	ENDC
	even
.length:dc.l	0		;longueur fichier pack‚ (pair)
.longueur:dc.l	0		;longueur fichier d‚pack‚ (pair)
.pack:
ENDCRUNCH0
;
; DECRUNCHER HUFFMANN
;
DECRUNCH1:
	DC.W	$601A
	DC.L	0
	DC.L	0
	DC.L	0
	DC.L	0
	DC.L	0
	DC.L	0
	DC.W	-1		;PAS DE RELOCATION
.base_page:
;
; on recopie le fichier pack‚ … la fin du fichier d‚pack‚
;
	move.l	.length(pc),d0
	lea	.pack(pc),a0
	add.l	d0,a0			;ptr source
	move.l	a0,a3

	lea	.pack+ajuste(pc),a1
	add.l	.longueur(pc),a1	;ptr dest
	move.l	a1,a2
	move.l	a2,a0
	sub.l	d0,a0

	addq.l	#7,d0
	lsr.l	#3,d0
.move_it:
	move.l	-(a3),-(a1)
	move.l	-(a3),-(a1)
	dbra	d0,.move_it

;	a0=source
;	a1=destination
;	a2=adresse de d‚but de l'arbre (1026 octets)

	lea	.pack(pc),a1

	bsr	.decomp

	lea	.base_page-$100(pc),a2
	lea	.pack(PC),A3
	TST	$1A(A3)
	BNE.S	.NORELOC
	MOVE.L	2(A3),A0
	ADD.L	6(A3),A0
	add.l	$e(a3),a0		;SKIPPE LABELS !!!!
	LEA	$1C(A3),A1
	add.l	a1,a0

	MOVE.L	(A0)+,D0
	BEQ.S	.NORELOC
	ADD.L	D0,A1
	MOVE.L	8(a2),D0
	MOVEQ	#0,D1
.RELOC1	ADD	D1,A1
	SUBQ.B	#1,D1
	BNE.S	.RELOC2
	LEA	$FE-1(A1),A1
	BRA.S	.RELOC3
.RELOC2	ADD.L	D0,(A1)
.RELOC3	MOVE.B	(A0)+,D1
	BNE.S	.RELOC1
.NORELOC
	MOVE.L	2(A3),d0
	MOVE.L	d0,$C(a2)
	MOVE.L	6(A3),$14(a2)
	MOVE.L	$A(A3),$1C(a2)
	ADD.L	8(a2),d0
	MOVE.L	d0,$10(a2)
	ADD.L	$14(a2),d0
	MOVE.L	d0,$18(a2)
	move.l	d0,a5

	movem.l	.MOVER(pc),d0-d3
	movem.l	d0-d3,LITTLE_PLACE(a2)

	LEA	$1C(A3),A0
	MOVE.L	.longueur(PC),D2
	lea	.pack+ajuste+1026(pc),a3
	add.l	d2,a3

	ADDQ.L	#3,D2
	LSR.L	#2,D2
	lea	.base_page(pc),a1
	MOVEQ	#0,D0
	jmp	LITTLE_PLACE(a2)

.MOVER	MOVE.L	(A0)+,(A1)+	;16 octets
	SUBQ.L	#1,D2
	BNE.S	.MOVER
.CLEARER
	MOVE.L	D0,(A5)+
	CMP.L	A3,A5
	BLO.S	.CLEARER
	JMP	(A4)
.decomp
;
;	a0=source
;	a1=destination
;	a2=adresse de d‚but de l'arbre (1026 octets)
;
	TAS	D0
	NEG	D0

	MOVE.L	a2,a3
	BSR.s	.DECODE0
	MOVE	(a2)+,D1
	bra.s	.traduit
.base:
	move.b	d0,(a1)+
.traduit:
	RDBYTE

	cmp.l	a3,a5
	blo.s	.base
	rts
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
	BNE.S	.TSTCARY1
.DECODE0:
	WAITDMA
.TSTCARY1:
	BCC.S	.DECODE3

	MOVE	#$8001,D0
.GETBIT:ADD	D2,D2
	BNE.S	.TSTCARY2
	WAITDMA
.TSTCARY2:
	ADDX.B	D0,D0
	BCC.S	.GETBIT
	MOVE	D0,(a3)+
	rts
	IFEQ	MARK
	DC.B	'MHUF'
	ENDC
	even
.length:dc.l	0		;longueur fichier pack‚ (pair)
.longueur:dc.l	0		;longueur fichier d‚pack‚ (pair)
.pack:
ENDCRUNCH1

;
; DECRUNCHER PACK
;
DECRUNCH2:
	DC.W	$601A
	DC.L	0
	DC.L	0
	DC.L	0
	DC.L	0
	DC.L	0
	DC.L	0
	DC.W	-1		;PAS DE RELOCATION
.base_page:
;
; on recopie le fichier pack‚ … la fin du fichier d‚pack‚
;
	move.l	.length(pc),d0
	lea	.pack(pc),a0
	add.l	d0,a0			;ptr source
	move.l	a0,a3

	lea	.pack+ajuste(pc),a1
	add.l	.longueur(pc),a1	;ptr dest
	move.l	a1,a2
	move.l	a2,a0
	sub.l	d0,a0

	addq.l	#7,d0
	lsr.l	#3,d0
.move_it:
	move.l	-(a3),-(a1)
	move.l	-(a3),-(a1)
	dbra	d0,.move_it

;	a0=source
;	a1=destination
;	a2=adresse de d‚but de l'arbre (256 octets)

	lea	.pack(pc),a1

	bsr	.decomp

	lea	.base_page-$100(pc),a2
	lea	.pack(PC),A3
	TST	$1A(A3)
	BNE.S	.NORELOC
	MOVE.L	2(A3),A0
	ADD.L	6(A3),A0
	add.l	$e(a3),a0		;SKIPPE LABELS !!!!
	LEA	$1C(A3),A1
	add.l	a1,a0

	MOVE.L	(A0)+,D0
	BEQ.S	.NORELOC
	ADD.L	D0,A1
	MOVE.L	8(a2),D0
	MOVEQ	#0,D1
.RELOC1	ADD	D1,A1
	SUBQ.B	#1,D1
	BNE.S	.RELOC2
	LEA	$FE-1(A1),A1
	BRA.S	.RELOC3
.RELOC2	ADD.L	D0,(A1)
.RELOC3	MOVE.B	(A0)+,D1
	BNE.S	.RELOC1
.NORELOC
	MOVE.L	2(A3),d0
	MOVE.L	d0,$C(a2)
	MOVE.L	6(A3),$14(a2)
	MOVE.L	$A(A3),$1C(a2)
	ADD.L	8(a2),d0
	MOVE.L	d0,$10(a2)
	ADD.L	$14(a2),d0
	MOVE.L	d0,$18(a2)
	move.l	d0,a5

	movem.l	.MOVER(pc),d0-d3
	movem.l	d0-d3,LITTLE_PLACE(a2)

	LEA	$1C(A3),A0
	MOVE.L	.longueur(PC),D2
	lea	.pack+ajuste+256(pc),a3
	add.l	d2,a3

	ADDQ.L	#3,D2
	LSR.L	#2,D2
	lea	.base_page(pc),a1
	MOVEQ	#0,D0
	jmp	LITTLE_PLACE(a2)

.MOVER	MOVE.L	(A0)+,(A1)+	;16 octets
	SUBQ.L	#1,D2
	BNE.S	.MOVER
.CLEARER
	MOVE.L	D0,(A5)+
	CMP.L	A3,A5
	BLO.S	.CLEARER
	BRA	.MOVER+256-LITTLE_PLACE
.decomp
;
;	a0=source
;	a1=destination
;	a2=adresse de d‚but de l'arbre (256 octets)
;
	moveq	#0,d4
	move.l	a2,a4
	moveq	#256/4-1,d0
.clear:	move.l	d4,(a4)+
	dbra	d0,.clear
	lea	.codes2(pc),a4
	moveq	#nbmeth-1,d3
.copy:
	move.b	(a0)+,d4
	move.b	(a4)+,(a2,d4.w)
	dbra	d3,.copy
	moveq	#0,d0
	bra.s	.traduit
.sure:
	rts
.base:
	move.b	d0,(a1)+
.traduit:
	cmp.l	a2,a0
	bhs.s	.sure
	move.b	(a0)+,d0
	move.b	(a2,d0.w),d4
	jmp	.base(pc,d4.w)
.meth0	move.b	(a0)+,(a1)+
	bra.s	.traduit
.meth1:
	move.b	(a0)+,d6
.meth3:
	moveq	#0,d3
.meth2xx:
	move.b	(a0)+,d3
	move.b	d6,(a1)+
	move.b	d6,(a1)+
.meth2x:
	move.b	d6,(a1)+
	dbra	d3,.meth2x
	bra.s	.traduit
.meth2:
	move.b	(a0)+,d6
	bsr.s	.byte8
	bra.s	.meth2xx
.meth4:
	moveq	#0,d3
.cnt8:
	move.b	(a0)+,d3
	neg	d3
	lea	-OFFSETMIN(a1,d3.w),a4
	moveq	#0,d3
.copy4:
	move.b	(a0)+,d3
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
.meth4x:move.b	(a4)+,(a1)+
	dbra	d3,.meth4x
	bra.S	.traduit
.meth5:
	moveq	#0,d3
.cnt16:
	move.b	(a0)+,d3
	neg	d3
	lea	-OFFSETMIN(a1,d3.w),a4
	bsr.s	.byte8
	bra.s	.copy4
.meth6:
	bsr.s	.byte8
	bra.s	.cnt8
.meth7:
	bsr.s	.byte8
	bra.s	.cnt16
.meth8:
	clr	d3
	move.b	(a0)+,d3
	neg	d3
	lea	-OFFSETMIN(a1,d3.w),a4

	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+

	bra.s	.traduit
.meth9:
	move.b	(a0)+,d3
	move.b	(a0)+,d4
	clr	d0
	move.b	(a0)+,d0
	addq	#4,d0
.meth9x:
	move.b	d3,(a1)+
	add.b	d4,d3
	dbra	d0,.meth9x
	bra	.traduit
.meth10:
	move.b	(a0)+,d7
.meth11:
	ifne	TOPO8
	move.b	d7,(a1)+
	endc
	move.b	(a0)+,d4
	moveq	#8-1,d3
.meth10x:
	move.b	d7,d0
	add.b	d4,d4
	bcc.s	.nomsk1
	move.b	(a0)+,d0
.nomsk1:
	move.b	d0,(a1)+
	dbra	d3,.meth10x
	bra	.traduit
.byte8:
	move.b	(a0)+,d3
	addq.b	#1,d3
	asl	#8,d3
	rts
.codes2:
	dc.b	.meth11-.base,.meth10-.base,.meth9-.base,.meth8-.base
	dc.b	.meth7-.base,.meth6-.base,.meth5-.base,.meth4-.base
	dc.b	.meth3-.base,.meth2-.base,.meth1-.base,.meth0-.base
	IFEQ	MARK
	DC.B	'MPAK'
	ENDC
	even
.length:dc.l	0		;longueur fichier pack‚ (pair)
.longueur:dc.l	0		;longueur fichier d‚pack‚ (pair)
.pack:
ENDCRUNCH2
