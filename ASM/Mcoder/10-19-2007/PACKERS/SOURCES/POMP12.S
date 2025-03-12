lenoffset=$800	;OFFSET MINIMUM=1
LOAD=$80000
LONG=24154
DEST1=$90000
DEST2=$A0000
XOR=0		;0=HASH PAR XOR
rsoff=0
rsfils=4

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
; GESTION HASH-CODE
;
	MOVEQ	#0,D0
	MOVE.B	(A5),D0
	IF	XOR=0
	MOVE.B	1(A5),D1
	EOR.B	D1,D0
	ENDIF

	asl	#2,d0
	lea	occur,a0
	add	d0,a0
	move.l	(a0),d0
	beq	FINSTR
loopsearch:
	move.l	d0,a2
;
	MOVE.L	rsoff(a2),a0	;OFFSET RECHERCHE

	MOVEQ	#-3,D0
	MOVE.L	A5,A1
	CMP.L	A0,A1
	BEQ	ERREUR

	MOVEQ	#-4,D0
	CMPM.B	(A0)+,(A1)+

	IF	XOR=0
	BNE	CMPCH2
	ELSE
	BNE	ERREUR
	ENDIF

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
	MOVEQ	#-5,D0
	MOVE.L	A1,D1
	SUB.L	A5,D1		;LONGUEUR CHAINE
	CMP.L	#1,D1
	BLE	ERREUR
	MOVE.L	D1,D2

	MOVEQ	#-6,D0
	MOVE.L	A5,D3
	SUB.L	rsoff(a2),D3	;OFFSET
	SUBQ.L	#1,D3		; -1
	BLT	ERREUR
;
; RECORD ???
;
; D1=2 … XXXX
; D3=0 … XXXX
;
	MOVEQ	#2+5+5,D0	;2 BITS="10"+2 ENTETES
				;5 BITS=LONGUEUR MINIMUM
				;5 BITS=OFFSET MINIMUM
;D1=LONGUEUR

	SUBQ.L	#2,D1
	CMP	#$10,D1
	BLO.S	OKLEN6
	ADDQ	#10-5,D0
	CMP	#$100+$10,D1
	BLO.S	OKLEN6
	ADDQ	#15-10,D0
	CMP	#$1000+$100+$10,D1
	BLO.S	OKLEN6
	ADDQ	#19-14,D0
OKLEN6:
;D3=OFFSET

	CMP	#$10,D3
	BLO.S	OKLEN7
	ADDQ	#10-5,D0
	CMP	#$100+$10,D3
	BLO.S	OKLEN7
	ADDQ	#15-10,D0
	CMP	#$1000+$100+$10,D3
	BLO.S	OKLEN7
	ADDQ	#19-15,D0
OKLEN7:
	MOVE.L	D2,D1
	ASL.L	#3,D2
	EXT.L	D0
	SUB.L	D0,D2		;D2=NB BITS GAGNES

	CMP.L	D7,D2
	BLE	CMPCH2

	MOVE.L	D0,SAVD0	;NB BITS
	MOVE.L	D1,SAVD1
	MOVE.L	D3,SAVD3
	MOVE.L	A0,D0
	SUBQ.L	#1,D0
	MOVE.L	D0,SAVA0

	MOVE.L	D2,D7
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
	MOVE.B	D0,(A4)+
	ADD.L	#9,NBBITS
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
	IF	XOR=0
	MOVE.B	1(A0),D1
	EOR.B	D1,D0
	ENDIF

	MOVE.L	A0,D1
;	SUBQ.L	#1,D1
;deletehash:
	asl	#2,d0
	lea	occur,a0
	add	d0,a0
	move.l	(a0),d0
	beq	ERREUR
	move.l	d0,a1

	moveq	#-1,d0
	cmp.l	rsoff(a1),d1
	bne	ERREUR

	move.l	rsfils(a1),(a0)
	move.l	a1,a0
	move.l	ptrfree,rsfils(a0)
	move.l	a0,ptrfree
	SUBQ	#1,NB

SKIPDEL:
	MOVE.L	A5,D1
	MOVEQ	#0,D0
	MOVE.B	(A5)+,D0

	IF	XOR=0
	MOVE	D1,-(SP)
	MOVE.B	(A5),D1
	EOR.B	D1,D0
	MOVE	(SP)+,D1
	ENDIF

;inserthash:
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
	moveq	#-2,d0
	move.l	rsfils(a0),ptrfree
	beq	ERREUR
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

TIME:	DC.L	0
OFFSET:	DC.L	lenoffset
NBBITS:	DC.L	0
SAVD0:	DC.L	0
SAVD1:	DC.L	0
SAVD3:	DC.L	0
SAVA0:	DC.L	0
ERREUR:
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
nooff:	rts

NB:	DC.W	0
ptrfree:dc.l	0
occur:	blk.l	256,0
buffer:
	blk.b	lenoffset*8+8

	BLK.B	1000
