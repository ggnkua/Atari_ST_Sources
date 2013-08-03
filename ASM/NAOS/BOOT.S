**   Demo St Mag / NAOS    **
** Boot secteur de la Demo **
** … sauver sous BOOT.S    **

Read_sector	MACRO
	move.w	\1,-(sp)	; combien
	move.w	\2,-(sp)	; face
	move.w	\3,-(sp)	; piste
	move.w	\4,-(sp)	; sect. depart
	move.w	#0,-(sp)	; disk A
	clr.l	-(sp)
	move.l	\5,-(sp)
	move.w	#8,-(sp)
	trap	#14
	lea	20(sp),sp
	ENDM

	cmp.b	#$36,$fffffc02.w
	bne.s	go_on
	rts
go_on
	bclr.b	#0,$484.w
; Structure disque pour les autres modules
	move.w	#Nb_of_trk,MaxTrack
	
; Fondu vers le noir
	move.w	#$777,d0
	moveq	#7,d1
Fade	lea	$ffff8240.w,a0
	REPT	8
	move.l	d0,(a0)+
	ENDR
	bsr	Vsync
	bsr	Vsync
	sub.w	#$111,d0
	dbf	d1,Fade

* Lecture de la table acces disque
; a5 = pointeur de chargement
Lect	lea	@Bootbuffer,a5
	lea	StockTable(pc),a0
	move.l	a5,(a0)
	Read_sector	#1,#0,#0,#2,a5
	lea	512(a5),a5

* Lecture du Gestionnaire
	lea	StockGest(pc),a0
	move.l	a5,(a0)
	move.l	StockTable(pc),a6
	move.w	(a6)+,d7
	Read_sector	d7,#0,#0,#3,a5
	mulu	#512,d7
	lea	GestSize(pc),a0
	move.l	d7,(a0)
	add.l	d7,a5

* Lecture de Loader
	lea	StockLoader(pc),a0
	move.l	a5,(a0)
; trouve info loader dans la Table
	moveq	#0,d7
	moveq	#0,d6	; pist 0
	move.w	(a6)+,d5	; sect depart pist 0
load	move.w	(a6)+,d7	; nb sect 
	bmi.s	fdc_loaded	
	Read_sector	d7,#0,d6,d5,a5
	mulu	#512,d7
	add.l	d7,a5
	addq.w	#1,d6
	moveq	#1,d5	; sect 1
	bra.s	load
fdc_loaded	
	move.w	#$2700,sr
	lea	Debut(pc),a0
	lea	Fin(pc),a1
	move.l	a5,a2
.trsf	move.l	(a0)+,(a2)+
	cmpa.l	a0,a1
	bcc.s	.trsf
	jmp	(a5)
	
* Transfert du Loader
Debut	move.l	(a6)+,d7	; taille du loader
	lsr.l	#2,d7
	addq.l	#1,d7
	move.l	StockLoader(pc),a0
	lea	@Load,a1
.trsf	move.l	(a0)+,(a1)+
	subq.l	#1,d7
	bne.s	.trsf	

* Transfert de la Table
	move.l	a6,a0
	lea	@Table,a1
	move.w	#127,d7
.trsf2	move.l	(a0)+,(a1)+
	dbf	d7,.trsf2

* Transfert du gestionnaire
	move.l	StockGest(pc),a0
	lea	@Gest,a1
	move.l	GestSize(pc),d7
	lsr.l	#2,d7
	addq.l	#1,d7
.trsf3	move.l	(a0)+,(a1)+
	subq.l	#1,d7
	bne.s	.trsf3	
	
JMP	jmp	@Gest

StockGest		dc.l	0
GestSize		dc.l	0
StockTable		dc.l	0
StockLoader	dc.l	0
Fin

Vsync	move.w	$468.w,d2	; synchro VBL
.1	cmp.w	$468.w,d2
	beq.s	.1
	rts
