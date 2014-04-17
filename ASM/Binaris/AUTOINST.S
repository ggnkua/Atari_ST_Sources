	move.l	#STACK-*,-(sp)	;m‚thode efficace !
	move.l	8(sp),-(sp)	;a partir du d‚but
	clr.w	-(sp)	;libŠre m‚moire
	move.w	#$4a,-(sp)
	trap	#1
	lea.l	12(sp),sp
	tst.l	d0
	bne.s	FIN
	lea	STACK(pc),sp
	
	pea	ACCEUIL(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

BIGLOOP:	pea	KESTION(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	
INPUT:	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	cmpi.b	#27,d0
	beq.s	FIN

	lea.l	CHG(pc),a5	; adr du chg freq
	clr.w	d7	; lecteur en d7

	cmpi.b	#"1",d0
	beq.s	HZ60
	cmpi.b	#"3",d0
	beq.s	BLECHZ60
	cmpi.b	#"7",d0
	beq.s	HZ50
	cmpi.b	#"9",d0
	beq.s	BLECHZ50

	bra.s	INPUT

FIN:	clr.w	-(sp)
	trap	#1

ERROR:	pea	ERREUR(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	bra.s	BIGLOOP

BLECHZ60:
	moveq	#1,d7

HZ60:            
	move.b	#$66,(a5)
	bra.s	INSTALL

BLECHZ50:
	moveq	#1,d7

HZ50:	move.b	#$67,(a5)
INSTALL:	lea.l	ADRBOOT(pc),a6
	move.l	a6,a2
	lea.l	HEADER(pc),a5
	movea.l	a6,a4

	moveq	#8,d0
	bsr.s	RWBOOT

	move.l	(a5)+,(a6)+
	move.w	(a5)+,(a6)+
	clr.w	(a6)+
	lea.l	22(a6),a6
	moveq	#(512-2-2-28)/4+1,d0

COPY:	move.l	(a5)+,(a6)+
	dbf	d0,COPY

	movea.l	a4,a6
	move.w	#$1234,d0
	move.w	#256-1-1,d1

CALC:	sub.w	(a6)+,d0
	dbf	d1,CALC

	move.w	d0,(a6)

	moveq	#9,d0
	bsr.s	RWBOOT

	bra	INPUT

RWBOOT:	pea	$00000001.w
	pea	$00010000
	move.w	d7,-(sp)
	clr.l	-(sp)
	pea	(a2)
	move.w	d0,-(sp)
	trap	#14
	lea.l	20(sp),sp
	tst.b	d0
	bne.s	ERROR
	rts

ACCEUIL:	DC.b "EAR-boot Installator",10,13
	DC.b "Sis boot consists of very much goodies",10,13
	DC.B "60 Hz,2.5 Mo,Auto-set clock..",10,0

KESTION:	DC.b 13,10,"<1> to install on disk A (60 Hz)",13,10
	DC.b "<3> to install on disk B (60 Hz)",13,10,10

	DC.b "<7> to install on disk A (50 Hz)",13,10
	DC.b "<9> to install on disk B (50 Hz)",13,10

	DC.b "<ESC> to quit",10,0

ERREUR:	DC.b 13,10,"Error while floppy operation !!",10,0

	INCLUDE	'BOOT3_3.S'
	
	SECTION	BSS 
ADRBOOT:	DS.b 512

	DS.b 256	;pour la pile
STACK: