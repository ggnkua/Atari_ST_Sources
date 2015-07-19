;
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
;
; DECRUNCHER HUFFMANN
;
DECRUNCH1:
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
.length:dc.l	0		;longueur fichier pack‚ (pair)
.longueur:dc.l	0		;longueur fichier d‚pack‚ (pair)
.pack:
ENDCRUNCH1
