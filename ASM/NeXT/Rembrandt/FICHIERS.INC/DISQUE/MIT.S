	move.l	a3,a6
	move.w	#WAT_INTR,pimgr_wat3(a3)
	bsr		Get_Time
;copie de l'image plus bas.
	move.l	a0,a2	;a2=image source (en haut)
	move.l	a2,a3
	add.l	d1,a3	;a3=image dest (en bas)
	move.l	d1,d2	;d2=taille image
.c:	move.b	(a2)+,(a3)+
	subq.l	#1,d2
	bne.s	.c
;copie effectu‚e !
;maintenant, l'entrelacement lui-mˆme !
DUMMY:
								;a2: image 256 source
	move.l	a0,a5				;a5: image 256 dest (sauvegarde)
	move.l	a0,a3				;a3= image 256 dest
	move.l	a3,a4
	add.l	d1,a4				;a4: bas de l'image dest
	move.w	glob_larg(a1),d3	;d3=longueur d'une ligne
	move.w	d3,d4				;d4=longueur d'une ligne sauvegarde
	
; une ligne toutes les 8, commencement … 0:
	move.w	d4,d5
	mulu.w	#7,d5	;d5=offset
	subq.l	#1,d4
.l081:	move.w	d4,d3
.l08:	move.b	(a2)+,(a3)+
		dbf	d3,.l08
	lea.l	0(a3,d5.l),a3	;ligne suivante !
	cmp.l	a3,a4
	bhi.s	.l081
	
;une ligne toutes les 8, commencement … 4
	move.l	a5,a3
	moveq	#0,d3
	move.w	d4,d3
	ADDQ.L	#1,D3
	lsl.l	#2,d3
	lea.l	0(a3,d3.l),a3
	;offset identique !
.l481:	move.w	d4,d3
.l48:	move.b	(a2)+,(a3)+
		dbf	d3,.l48
	lea.l	0(a3,d5.l),a3	;ligne suivante !
	cmp.l	a3,a4
	bhi.s	.l481
	
;une ligne toutes les 4, commencement … 2
	ADDQ.L	#1,D4
	move.w	d4,d5
	mulu	#3,d5
	move.l	a5,a3
	moveq	#0,d3
	move.w	d4,d3
	lsl.l	d3
	SUBQ.L	#1,D4
	lea.l	0(a3,d3.l),a3
.l241:	move.w	d4,d3
.l24:	move.b	(a2)+,(a3)+
		dbf	d3,.l24
	lea.l	0(a3,d5.l),a3	;ligne suivante !
	cmp.l	a3,a4
	bhi.s	.l241

;une ligne toutes les 2, commencement … 1
	ADDQ.L	#1,D4
	move.w	d4,d5	;offset=1 ligne
	move.l	a5,a3
	lea.l	0(a3,d4.w),a3
	SUBQ.L	#1,D4
.l121:	move.w	d4,d3
.l12:	move.b	(a2)+,(a3)+
		dbf	d3,.l12
	lea.l	0(a3,d5.w),a3	;ligne suivante !
	cmp.l	a3,a4
	bhi.s	.l121	
	bsr.s	Set_Time
	move.l	a6,a3
	move.w	TIMER+2(pc),pimgr_t3(a3)	

no_inter:
