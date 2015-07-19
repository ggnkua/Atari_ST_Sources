lenoffset=$800	;OFFSET MINIMUM=1
LOAD=$40000
LONG=24154
DEST1=$50000
DEST2=$60000

	MOVE	SR,D0
	AND	#$2000,D0
	BNE.S	SUPER
	CLR.L	-(SP)
	MOVE	#$20,-(SP)
	TRAP	#1
	ADDQ	#6,SP
SUPER:
	MOVE.L	$4BA.W,TIME

	BSR	INITHASH
	CLR.L	DISPLAY
	LEA	DEST1,A3
	LEA	DEST2,A4
	LEA	LOAD,A5
	LEA	LOAD+LONG,A6
LOOP1:
	CMP.L	DISPLAY,A5
	BLO.S	NODI
	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVE.L	A5,D7
	SUB.L	#LOAD,D7
	BSR	HEXA
	MOVE	#13,-(SP)
	MOVE	#2,-(SP)
	TRAP	#1
	ADDQ	#4,SP
	MOVE.L	A5,D0
	ADD.L	#256,D0
	MOVE.L	D0,DISPLAY
	MOVEM.L	(SP)+,D0-D7/A0-A6
NODI:
	BSR	PACK
	CMP.L	A6,A5
	BLO.S	LOOP1

	MOVE.L	NBBITS,D0

	LEA	DEST2,A0
	MOVE.L	A4,A1

	MOVE.L	$4BA.W,D2
	SUB.L	TIME,D2
	ILLEGAL
DISPLAY:DC.L	0
HEXA:
	MOVEQ	#8-1,D6
HEX1:
	ROL.L	#4,D7
	MOVEQ	#$F,D0
	AND	D7,D0
	ADD	#'0',D0
	CMP	#$3A,D0
	BLO.S	HEX2
	ADDQ	#7,D0
HEX2:
	MOVE	D0,-(SP)
	MOVE	#2,-(SP)
	TRAP	#1
	ADDQ	#4,SP
	DBRA	D6,HEX1
	RTS
PACK:
	MOVEQ	#0,D7
;
; RECHERCHE DE CHAINES
;
;
; GESTION HASH-CODE
;
	MOVEQ	#0,D0
	MOVE.B	(A5),D0
	asl	#2,d0
	lea	occur,a0
	add	d0,a0
	move.l	(a0),d0
	beq	FINSTR
loopsearch:
	move.l	d0,a2
;
	MOVE.L	rsoff(a2),a0	;OFFSET RECHERCHE
	MOVE.L	A5,A1
	CMP.L	A0,A1
	BEQ	ERREUR

	CMPM.B	(A0)+,(A1)+
	BNE	ERREUR

	CMPM.B	(A0)+,(A1)+
	BNE	CMPCH2

CMPCH3:
	CMP.L	A6,A0
	BHS.S	CMPCH4
	CMP.L	A6,A1
	BHS.S	CMPCH4

	CMPM.B	(A0)+,(A1)+
	BEQ.S	CMPCH3
	SUBQ	#1,A1
CMPCH4:
	MOVE.L	A1,D1
	SUB.L	A5,D1		;LONGUEUR CHAINE
	CMP.L	#1,D1
	BEQ	ERREUR
;	BEQ	CMPCH2
	MOVE.L	D1,D2

	MOVE.L	A5,D3
	SUB.L	rsoff(a2),D3	;OFFSET
	SUBQ.L	#1,D3		; -1
;
; RECORD ???
;
	CMP	#2,D1		;LONGUEUR CHAINE-2
	BEQ	LEN2
	CMP	#3,D1
	BEQ	LEN3
	CMP	#4,D1
	BEQ	LEN4
	CMP	#5,D1
	BEQ	LEN5
;
; LONGUEUR 6 ET PLUS
;
	MOVEQ	#7+4+4,D0	;7 BITS=100+2 ENTETES
				;4 BITS=LONGUEUR MINIMUM
				;4 BITS=OFFSET MINIMUM
	CMP	#$10+6,D1
	BLO.S	OKLEN6
	ADDQ	#4,D0
	CMP	#$100+6,D1
	BLO.S	OKLEN6
	ADDQ	#4,D0
	CMP	#$1000+6,D1
	BLO.S	OKLEN6
	ADDQ	#4,D0
OKLEN6:

	CMP	#$10,D3
	BLO.S	OKLEN7
	ADDQ	#4,D0
	CMP	#$100,D3
	BLO.S	OKLEN7
	ADDQ	#4,D0
	CMP	#$1000,D3
	BLO.S	OKLEN7
	ADDQ	#4,D0
OKLEN7:
MAXD7:
	ASL.L	#3,D2
	EXT.L	D0
	SUB.L	D0,D2		;D2=NB BITS GAGNES

	CMP.L	D7,D2
	BLS	CMPCH2

	MOVE.L	D0,SAVD0	;NB BITS
	MOVE.L	D1,SAVD1
	MOVE.L	D3,SAVD3
	MOVE.L	A0,D0
	SUBQ.L	#1,D0
	MOVE.L	D0,SAVA0

	MOVE.L	D2,D7
	BRA	CMPCH2
LEN2:
	CMP	#$100,D3
	BHS	CMPCH2
	MOVEQ	#3+8,D0
	BRA	MAXD7
LEN3:
	MOVEQ	#5+4,D0
	CMP	#$10,D3
	BLO	MAXD7
	ADDQ	#4,D0
	CMP	#$100,D3
	BLO	MAXD7
	ADDQ	#4,D0
	CMP	#$1000,D3
	BLO	MAXD7
	BRA	CMPCH2
LEN4:
	MOVEQ	#7+4,D0
	CMP	#$10,D3
	BLO	MAXD7
	ADDQ	#4,D0
	CMP	#$100,D3
	BLO	MAXD7
	ADDQ	#4,D0
	CMP	#$1000,D3
	BLO	MAXD7
	BRA	CMPCH2
LEN5:
	MOVEQ	#7+4,D0
	CMP	#$10,D3
	BLO	MAXD7
	ADDQ	#4,D0
	CMP	#$100,D3
	BLO	MAXD7
	ADDQ	#4,D0
	CMP	#$1000,D3
	BLO	MAXD7
	ADDQ	#4,D0
	BRA	MAXD7
CMPCH2:
	move.l	rsfils(a2),d0
	bne	loopsearch
FINSTR:
	TST.L	D7
	BEQ	NOBITS
;
; D7=NB BITS GAGNES
;
;	MOVE.L	SAVD1,D0	;LONGUEUR
;	MOVE.L	SAVD3,D1	;OFFSET-1
;	MOVE.L	SAVA0,A0
;	ILLEGAL
;NOBUG:
	MOVE.L	SAVD1,D7
SKIPBYT:
	BSR	SKIP_BYTE
	SUBQ.L	#1,D7
	BNE	SKIPBYT
	MOVE.L	SAVD0,D0
	ADD.L	D0,NBBITS
	RTS
NOBITS:
	BSR	SKIP_BYTE

	MOVE.B	-1(A5),D0

	TST.B	D0
	BEQ.S	ZERO
	CMP.B	#$01,D0
	BEQ.S	ZERO
	CMP.B	#$02,D0
	BEQ.S	ZERO
	CMP.B	#$04,D0
	BEQ.S	ZERO
	CMP.B	#$08,D0
	BEQ.S	ZERO
	CMP.B	#$10,D0
	BEQ.S	ZERO
	CMP.B	#$20,D0
	BEQ.S	ZERO
	CMP.B	#$40,D0
	BEQ.S	ZERO
	CMP.B	#$80,D0
	BEQ.S	ZERO

	CMP.B	(A5),D0
	BEQ	DOUBLE
;PUSH:
	MOVE.B	D0,(A4)+
	ADD.L	#9,NBBITS
	RTS
ZERO:	ADDQ.L	#7,NBBITS
	RTS
DOUBLE:
	MOVE.B	D0,(A4)+
	BSR	SKIP_BYTE
	ADD.L	#7+8,NBBITS
	RTS

SKIP_BYTE:
;
; GESTION HASH-CODE
;
	MOVE.L	A5,A0
	SUB.L	OFFSET(PC),A0
	CMP.L	#LOAD,A0
	BLO.S	SKIPDEL
	MOVEQ	#0,D0
	MOVE.B	(A0),D0
	MOVE.L	A0,D1
;	SUBQ.L	#1,D1
	BSR	DELETEHASH
SKIPDEL:
	MOVE.L	A5,D1
	MOVEQ	#0,D0
	MOVE.B	(A5)+,D0
	BRA	INSERTHASH

TIME:	DC.L	0
OFFSET:	DC.L	lenoffset
NBBITS:	DC.L	0
SAVD0:	DC.L	0
SAVD1:	DC.L	0
SAVD3:	DC.L	0
SAVA0:	DC.L	0
ERREUR:	MOVEQ	#-1,D0
	ILLEGAL
;
; GESTION HASH-CODE
;
; entr‚e :
;	d0=octet hash-code
;	d1=offset octet courant
;
; STRUCTURE DE LA TABLE DE HASHAGE :
;	0.L=OFFSET
;	4.L=PTR FILS
;
rsoff=0
rsfils=4

inithash:
	lea	buffer,a0
	move	#lenoffset+1-1-1,d0

	CMP	#-1,D0
	beq.s	nobuf
inithash2:
	addq	#8,a0
	move.l	a0,rsfils-8(a0)
	dbra	d0,inithash2
nobuf:
	clr.l	rsfils(a0)
	move.l	#buffer,ptrfree
	lea	occur,a0
	move	#256-1,d0
inithash3:
	clr.l	(a0)+
	dbra	d0,inithash3
nooff:
	rts

inserthash:
	asl	#2,d0
	lea	occur,a0
	add	d0,a0
	move.l	(a0),d0
	beq.s	cree_pere
noeud_final:
	move.l	d0,a0
	move.l	rsfils(a0),d0
	bne.s	noeud_final
	move.l	ptrfree,rsfils(a0)
	move.l	ptrfree,a0
	move.l	d1,rsoff(a0)
	moveq	#-1,d0
	move.l	rsfils(a0),ptrfree
	beq	bug
	clr.l	rsfils(a0)
	ADDQ	#1,NB
	rts
cree_pere:
	move.l	ptrfree,rsoff(a0)
	move.l	ptrfree,a0
	move.l	d1,rsoff(a0)
	move.l	rsfils(a0),ptrfree
	clr.l	rsfils(a0)
	ADDQ	#1,NB
	rts

deletehash:
	asl	#2,d0
	lea	occur,a0
	add	d0,a0
	move.l	(a0),d0
	beq	bug
	move.l	d0,a1

	moveq	#-2,d0
	cmp.l	rsoff(a1),d1
	bne	bug

	move.l	rsfils(a1),(a0)
	move.l	a1,a0
	move.l	ptrfree,rsfils(a0)
	move.l	a0,ptrfree
	SUBQ	#1,NB
	rts

bug:
	illegal

NB:	DC.W	0
ptrfree:dc.l	0
occur:	blk.l	256,0
buffer:
	blk.b	lenoffset*8+8

	BLK.B	1000
