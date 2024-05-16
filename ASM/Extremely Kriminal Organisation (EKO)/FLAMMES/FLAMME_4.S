; a assembler avec flamme_x.lod ou avec flamme_y.lod ......


	opt d+
	opt o+

	include	d:\devpac\sources\macro\dsp.mcr

	move.l	#0,-(sp)	; passage en mode super viseur
	move.w	#$20,-(sp)	; fct 20 du trap 1 avec param 0
	trap	#1
	addq.l	#6,sp		; on restore le pile
	move.l	d0,save_stk
	move.l	usp,a0			
	move.l	a0,save_usp

	move.l	#$ffff9800,a0
	lea	sauv_coul,a1
	move.l	#255,d0
coulsave
	move.l	(a0)+,(a1)+
	dbf	d0,coulsave


	move.w	#-1,-(sp)	; recupere ds d0 le mode actuel
	move.w	#88,-(sp)	; fct 88 du trap 14
	trap	#14
	addq.l	#4,sp
	move.w	d0,old_mode

	move.b	$ff8201,old_adr+1	; ancienne adresse de l'ecran
	move.b	$ff8203,old_adr+2
	move.b	$ff820d,old_adr+3

	move.l	#ecran,d0
	addq.l	#4,d0
	and.l	#$fffffffc,d0
	move.l	d0,adr_ecr

	move.w	#0,-(sp)	; change de mode
	move.l	d0,-(sp)	; adr de l'ecran
	move.l	d0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp


	move.w	#%001100100,-(sp)	; 320*200 en 65536 couleurs
	move.w	#88,-(sp)		; fct 88 du trap 14
	trap	#14
	addq.l	#4,sp

	or.b	#1,$ffff82c3.w


	lea	sauv_vect,a0	; sauvegarde des vecteurs
	move.l	$70.w,(a0)+	; vbl
	move.b	$ffa07,(a0)+	; iera
	move.b	$ffa09,(a0)+	; ierb
	move.b	$ffa0b,(a0)+	; ipra
	move.b	$ffa0d,(a0)+	; iprb
	move.b	$ffa0f,(a0)+	; isra
	move.b	$ffa11,(a0)+	; isrb
	move.b	$ffa13,(a0)+	; imra
	move.b	$ffa15,(a0)+	; imrb
	dc.w	$a00a		; on coupe pas la souris ????????
	move.b	#$12,$fffffc02.w

	Dsp_lock
	Dsp_flushsubroutines
	Dsp_loadprog dsp,3,buffer

	bsr	clr_scr
	lea	palette_pc,a0
	move.w	#0,(a0)+
	move.w	#0,(a0)+
	move.w	#0,(a0)+
	move.w	#0,(a0)+
	move.b	#0,(a0)+

	bsr	make_palette


	clr.b	$ffa07		; couper les interuptions
	clr.b	$ffa09
	clr.b	$ffa13		
	clr.b	$ffa15

	movec	cacr,d0
	move.w	d0,save_cacr
	bset	#0,d0
	bclr	#8,d0
	movec	d0,cacr
	move.l	#routine,$70.w
bcl:
	movec	cacr,d0
	bclr	#1,d0
	bset	#0,d0
	bset	#8,d0
	bclr	#9,d0
	movec	d0,cacr



	moveq	#0,d1
	move.w	compteur,d0
	subq	#1,d0
	bpl.s	.send

	move.l	#$3260,d0
	moveq.l	#24,d1
	lea	chaine,a1
	bsr	send_letter
	move.w	#100,compteur
	bra.s	no_insert

.send	btst	#1,$ffffa202.w
	beq.s	.send	
	move.l	d1,$ffffa204.w

	move.w	d0,compteur
	move.l	#0,$ffff9800	

no_insert
	move.l	#$ffffa206,a6
	move.l	adr_ecr,a0
	move.w	#120-1,d0
.rec	btst	#0,$ffffa202.w
	beq.s	.rec
	move.w	#24-1,d5
.rec1	
	move.w	(a6),d1
	move.w	d1,(a0)+
	move.w	d1,(a0)+
	move.w	(a6),d1
	move.w	d1,(a0)+
	move.w	d1,(a0)+
	move.w	(a6),d1
	move.w	d1,(a0)+
	move.w	d1,(a0)+
	move.w	(a6),d1
	move.w	d1,(a0)+
	move.w	d1,(a0)+
	move.w	(a6),d1
	move.w	d1,(a0)+
	move.w	d1,(a0)+
	move.w	(a6),d1
	move.w	d1,(a0)+
	move.w	d1,(a0)+
	move.w	(a6),d1
	move.w	d1,(a0)+
	move.w	d1,(a0)+
	move.w	(a6),d1
	move.w	d1,(a0)+
	move.w	d1,(a0)+
	dbf	d5,.rec1
	dbf	d0,.rec
	move.l	#0,$ffff9800	
	movec	cacr,d0
	bclr	#1,d0
	bset	#0,d0
	bset	#8,d0
	bclr	#9,d0
	bset	#1,d0
	movec	d0,cacr


	cmp.b	#$39,$fffc02
	beq.s	.fin
	move.w	synchro,d0
.wait	cmp.w	synchro,d0
	beq.s	.wait
	bra	bcl

.fin:
	move.w	synchro,d0
.wait1	cmp.w	synchro,d0
	beq.s	.wait1

	move.w	save_cacr,d0
	movec	d0,cacr

	lea	sauv_vect,a0
	move.l	(a0)+,$70.w	; vbl
	move.b	(a0)+,$ffa07	; iera
	move.b	(a0)+,$ffa09	; ierb
	move.b	(a0)+,$ffa0b	; ipra
	move.b	(a0)+,$ffa0d	; iprb
	move.b	(a0)+,$ffa0f	; isra
	move.b	(a0)+,$ffa11	; isrb
	move.b	(a0)+,$ffa13	; imra
	move.b	(a0)+,$ffa15	; imrb
	dc.w	$a009		; on ne restore pas la souris ????
	move.b	#$08,$fffffc02.w

	Dsp_unlock

	move.w	old_mode,-(sp)	; 320*200 en 256 couleurs
	move.w	#3,-(sp)	; change de mode
	move.l	old_adr,-(sp)	; adr de l'ecran
	move.l	old_adr,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#14,sp

	move.l	#$ffff9800,a0
	lea	sauv_coul,a1
	move.l	#255,d0
coulsave2
	move.l	(a1)+,(a0)+
	dbf	d0,coulsave2

	move.l	save_usp,a0
	move.l	a0,usp
	move.l	save_stk,-(sp)		
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.l	-(sp)
	trap	#1

compteur	dc.w	50	

routine:
	addq.w	#1,synchro
	rte

clr_scr
	move.l	#0,$ffff9800.w
	
	move.l	adr_ecr,a0
	move.l	#160*200-1,d0
.re	clr.l	(a0)+
	dbf	d0,.re
	rts

send	btst	#1,$ffffa202.w
	beq.s	send	
	move.l	d7,$ffffa204.w
	rts


make_palette
	lea	palette_pc,a0
	lea	table_col,a1
	move.w	#255,d2
.re
	move.b	(a0)+,d0
	and.w	#$3f,d0
	lsr.w	#1,d0
	lsl.w	#8,d0
	lsl.w	#3,d0
	move.b	(a0)+,d1
	and.w	#$3f,d1
	lsl.w	#5,d1
	add.w	d1,d0
	move.b	(a0)+,d1
	and.w	#$3f,d1
	lsr.w	#1,d1
	add.w	d1,d0
	move.w	d0,(a1)+
	addq	#1,a0
.send2	btst	#1,$ffffa202.w
	beq.s	.send2	
	ext.l	d0
	move.l	d0,$ffffa204.w
	dbf	d2,.re
	move.w	#255,d0
.send	btst	#1,$ffffa202.w
	beq.s	.send	
	move.l	#-1,$ffffa204.w
	dbf	d0,.send

	rts	


send_letter
; en entree adresse ou mettre la lettre ds d0
; longueur de la chaine en pixel ds d1
; adresse de la chaine ds a1 
	moveq	#0,d7
	move.w	d0,d7
	bsr	send
	moveq	#0,d7
	move.w	d1,d7
	bsr	send
	lsr.w	#3,d1
	subq	#1,d1
	moveq	#0,d0
	moveq	#7,d5
.let0
	move.l	a1,a3
	move.w	d1,d4
.let
	moveq	#0,d2
	lea	font+140,a0
	add.l	d0,a0
	move.b	(a3)+,d2
	sub.b	#$61,d2
	add.w	d2,a0	
	move.b	(a0),d2
	moveq	#7,d6
.let1
	moveq	#0,d7
	btst	d6,d2
	bne.s	.let2
	moveq	#1,d7
.let2
	bsr	send
	dbf	d6,.let1
	dbf	d4,.let
	add.l	#80,d0
	dbf	d5,.let0
	rts

chaine	dc.b	"eko"
	even

palette_pc
cpt	set	0
	rept	16
	dc.b	0,0,cpt,0
cpt	set	cpt+1
	endr

cpt	set	0
	rept	16
	dc.b	cpt,0,16-cpt,0
cpt	set	cpt+1
	endr

cpt	set	0
	rept	48
	dc.b	16+cpt,0,0,0
cpt	set	cpt+1
	endr

cpt	set	0
	rept	64
	dc.b	63,cpt,0,0
cpt	set	cpt+1
	endr

cpt	set	0
	rept	64
	dc.b	63,63,cpt,0
cpt	set	cpt+1
	endr

	rept	160
	dc.b	63,63,63,0
	endr

;palette_pc

	incbin	d:\flammes\palette.dat
	even

dsp		dc.b	'd:\flammes\flamm5.lod',0
	even

font	incbin	font.pnt

adr_buff_flamme1	dc.l	buff_flamme1
adr_buff_flamme2	dc.l	buff_flamme2

	section bss
save_cacr	ds.w	1
synchro		ds.w	1
old_mode	ds.w	1
old_adr		ds.l	1
adr_ecr		ds.l	1
save_usp	ds.l	1
save_stk	ds.l	1
sauv_coul	ds.l	256
table_col	ds.w	256

sauv_vect	ds.l	16
buff_flamme1	ds.w	320*201
buff_flamme2	ds.w	320*201
ecran		ds.b	768*240+4
buffer		ds.b	27000