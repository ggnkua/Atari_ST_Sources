;Loader. Directement issu de Rising Force/Japtro. Valable ici pour une
;79 pistes/10 secteurs.


	...
	...
	JSR	CHARGEZ
	...
	...


CHARGEZ
	CLR.L	AJOUT
MODADRDEP	EQU	*+2
	LEA	DATA_FILES,A0
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
	MOVE	(A0)+,D0	Face
	MOVE	(A0)+,D1	Piste
	MOVE	(A0)+,D2	Nb sect
	MOVE	(A0)+,OFF7_DEP	Offset de d‚part
	MOVE.L	(A0)+,TAILLE	Taille du prg
	MOVE.L	A0,MODADRDEP	Automodifie. Si tu appelles CHARGEZ … nouveau
			;il prend automatiquement les datas suivants
			;dans DATA_FILES.
	JSR	TRACK_LOADING	Il charge tout.
	LEA	ADR_LOAD,A0
OFF7_DEP	EQU	*+2
	LEA	0(A0),A0	A0=adresse exacte du d‚but du fichier
			;TAILLE contient sa taille en octets.
	
	;JSR	D_PACK
	;JSR	RELOC
	;JMP	ADR_LOAD
	RTS

TRACK_LOADING	
	LEA	FACE(PC),A0
	MOVE	D0,(A0)
	LEA	PISTE(PC),A1
	LEA	PISTE2(PC),A2
	MOVE	D1,(A1)
	MOVE	D1,(A2)
	LEA	NB_SECT(PC),A0
	CMPI.L	#10,D2
	BLE.S	PAS_PLUS_DE_10
	MOVE.L	D2,D3
	DIVS	#10,D3
	MOVEQ	#0,D4
	MOVEQ	#0,D5
	MOVE	D3,D4	NB * 10 SECT A LIRE
	SWAP	D3
	MOVE	D3,D5	ET RESTE
	SUBQ.L	#1,D4
AGAIN	
	MOVEM.L	D4/A0-A2,-(SP)
	MOVE	#10,(A0)
	JSR	LOADING
	LEA	AJOUT(PC),A3
	ADD.L	#512*10,(A3)
	MOVEM.L	(SP)+,D4/A0-A2
	ADDQ	#1,(A1)
	ADDQ	#1,(A2)
	DBF	D4,AGAIN
	TST.L	D3
	BEQ.S	FINIz
	TST	D5
	BEQ.S	FINIz
	MOVE	D5,(A0)
	JSR	LOADING
	BRA.S	FINIz
PAS_PLUS_DE_10	MOVE	D2,(A0)
	JSR	LOADING
FINIz	RTS

LOADING
	LEA	ADR_LOAD,A0
AJOUT	EQU	*+2
	ADDA.L	#0,A0
	movea.l	a0,a1
	lea	$FFFF8604.W,a6
	st	$43E.W
	moveq	#0,d0
FACE	EQU	*+2
	move	#0,D1
	bsr	Set_drive
Tracks:	move.w	#$86,d2
PISTE	EQU	*+2
	move.w	#0,d3
	bsr.S	WD_write
	move.w	#$80,d2
	moveq	#%00010001,d3
	bsr.s	WD_write
Wait_Tracks:	bsr.S	Wait_done
	moveq	#0,d0
CHARGE:	move.l	a0,d1
	move.b	d1,$FFFF860D.W
	lsr.l	#8,d1
	move.b	d1,$FFFF860B.W
	lsr.l	#8,d1
	move.b	d1,$FFFF8609.W
DMA_in:	move.w	#$90,2(a6)
	move.w	#$190,2(a6)
	move.w	#$90,d2
	moveq	#1,d3
	bsr.s	WD_write
	move.w	#$82,d2
PISTE2	EQU	*+2
	move.w	#0,d3
	bsr.s	WD_write
	addq.w	#1,d0
	move.w	#$84,d2
	move.w	d0,d3
	bsr.s	WD_write
	move.w	#$80,d2
	move.w	#%10000000,d3
	bsr.s	WD_write
	bsr.s	Wait_done
	adda.l	#512,a0
NB_SECT	EQU	*+2
	cmpi.w	#0,d0
	bne.s	CHARGE
	move.b	#7,d0
	bsr.s	Select
	sf	$43E.W
	movea.l	a1,a0
	RTS
;	jmp	(a0)
WD_write:	move.w	d2,2(a6)
	move.w	d3,(a6)
Attend:	moveq	#40,d1
Attend1:dbf	d1,Attend1
	rts
Wait_done:	bsr.s	Attend
Wait:	btst	#5,$FFFFFa01.W
	bne.s	Wait
	rts
;Set_drive:	moveq	#5,d0
;Select:	move.w	sr,-(a7)
;	ori.w	#$700,sr
;	move.b	#$e,$ffFF8800.W
;	move.b	$ffFF8800.W,d1
;	andi.b	#$f8,d1
;	or.b	d0,d1
;	move.b	d1,$ffFF8802.W
;	move.w	(a7)+,sr
;	rts
Set_drive:
	move.w	d0,d4
	cmpi.w	#1,d0
	bgt.s	End_set
	addq.b	#1,d4
	lsl.b	#1,d4
	or.w	d1,d4
	eori.b	#7,d4
	andi.b	#7,d4
	MOVE.L	D4,D0
;	moveq	#5,d0		Selectionner le drive A	
Select:	move.w	sr,-(a7)
	ori.w	#$700,sr
	move.b	#$e,$fFFf8800.W
	move.b	$fFFf8800.W,d1
	andi.b	#$f8,d1
	or.b	d0,d1
	move.b	d1,$fFFf8802.W
	move.w	(a7)+,sr
End_set	rts

DATA_FILES

	DC	0	Face (0 ou 1)
	DC	0	Piste (0 … 78/81 suivant ton formatage)
	DC	1	Nombre de secteurs … lire
	DC	0	Offset...
	DC.L	512	Taille exacte du fichier...

	DC	0	|Exemples...
	DC	1	|Ce sont les donn‚es pour le 2eme
	DC	250	|fichier … charger. Tu les places
	DC	50	|… la suite, comme ‡a.
	DC.L	127258	|

	BSS
TAILLE	DS.L	1
ADR_LOAD	DS.B	50000
