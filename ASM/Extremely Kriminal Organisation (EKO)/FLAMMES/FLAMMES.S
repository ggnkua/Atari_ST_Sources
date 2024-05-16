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


	move.w	#%000100100,-(sp)	; 320*200 en 256 couleurs
	move.w	#88,-(sp)		; fct 88 du trap 14
	trap	#14
	addq.l	#4,sp

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
	bset	#8,d0
	movec	d0,cacr
	move.l	#routine,$70.w
bcl:
	move.l	adr_ecr,a1
	add.l	#172*640,a1
	

	move.l	adr_ecr,a0
	add.l	#20*640,a0
	move.w	#320*77-1,d0
.rec	btst	#0,$ffffa202.w
	beq.s	.rec
.rec1	move.w	$ffffa206.w,d1
	move.w	d1,(a0)+
	move.w	d1,-(a1)
	dbf	d0,.rec1										


	cmp.b	#$39,$fffc02
	beq.s	.fin
	move.w	synchro,d0
.wait	cmp.w	synchro,d0
*	beq.s	.wait
	bra.s	bcl

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
.send2	btst	#1,$ffffa202.w
	beq.s	.send2	
	ext.l	d0
	move.l	d0,$ffffa204.w
	dbf	d2,.re
	rts	
	


palette_pc
	incbin	d:\flammes\palette.dat
	even

dsp		dc.b	'd:\flammes\flamme_y.lod',0
	even

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
ecran		ds.b	640*200+4
buffer		ds.b	27000