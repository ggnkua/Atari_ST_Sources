; a assembler avec flamme_x.lod ou avec flamme_y.lod ......


	opt d+

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

	move.l	#ecran1,d0
	addq.l	#4,d0
	and.l	#$fffffffc,d0
	move.l	d0,adr_ecr1
	move.l	#ecran2,d0
	addq.l	#4,d0
	and.l	#$fffffffc,d0
	move.l	d0,adr_ecr2

	move.w	#%001100100,-(sp)	; 320*200 en 65536 couleurs
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
	Dsp_execprog dsp,dsp_size,3

	move.l	adr_ecr,a0
	bsr	clr_scr
	move.l	adr_ecr1,a0
	bsr	clr_scr
	move.l	adr_ecr2,a0
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
	bsr	converti_img

	move.l	#routine,$70.w
	move.l	adr_ecr1,d0
	bsr	adr_ecr_to_screen

	bsr	affiche_code_gen
	bsr	lissage
	
	move.l	adr_ecr2,d0
	bsr	adr_ecr_to_screen

	move.l	adr_ecr,a0
	bsr	clr_scr
	move.l	adr_ecr1,a0
	bsr	clr_scr
	bsr	affiche_code_gen_in_dsp
	move.l	adr_ecr,d0
	bsr	adr_ecr_to_screen
	move	#0,synchro
.re2	tst.w	synchro
	beq.s	.re2	
	or.b	#1,$ffff82c3.w

bcl:
	movec	cacr,d0
	bclr	#1,d0
	bset	#0,d0
	bset	#8,d0
	bclr	#9,d0
	movec	d0,cacr



	moveq	#0,d1

.send	btst	#1,$ffffa202.w
	beq.s	.send	
	move.l	d1,$ffffa204.w

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

	move.l	adr_tab_flamme,a0
	move.b	(a0)+,d0
	move.l	a0,adr_tab_flamme
	tst.b	d0
	bmi.s	.fin
	beq.s	.send11
.send1	btst	#1,$ffffa202.w
	beq.s	.send1	
	move.l	#1,$ffffa204.w
	bra.s	.no_aleat
.send11	btst	#1,$ffffa202.w
	beq.s	.send11	
	move.l	#2,$ffffa204.w
.no_aleat
	cmp.b	#2,d0
	bne.s	.couille
	bsr	affiche_code_gen_in_dsp


.couille


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
	bsr	lissage

	move.w	synchro,d0
.wait2	cmp.w	synchro,d0
	beq.s	.wait2

	eor.b	#1,$ffff82c3.w

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



	move.l	adr_ecr2,d0
	bsr	adr_ecr_to_screen
	Dsp_unlock

	move.l	adr_ecr1,physique
	move.l	adr_ecr1,work
	move.l	adr_ecr,logique
	bsr	copy_ecr
	bsr	prepa_map


	clr.b	$ffa07		; couper les interuptions
	clr.b	$ffa09
	clr.b	$ffa13		
	clr.b	$ffa15
	move.l	#routine,$70.w


	bsr	demo_loop_mapping

	move	#0,synchro
.wai	move.w	synchro,d0
	cmp.w	#100,d0
	bne.s	.wai	


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

adr_ecr_to_screen
	swap	d0
	move.b	d0,$ffff8201.w
	swap	d0
	rol.w	#8,d0
	move.b	d0,$ffff8203.w
	rol.w	#8,d0
	move.b	d0,$ffff820d.w
	rts

routine:
	addq.w	#1,synchro
	rte

clr_scr
	move.l	#0,$ffff9800.w
	
	move.l	#192*240-1,d0
.re	
	clr.l	(a0)+
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



lissage
	move.l	adr_ecr,a0
	move.l	adr_ecr2,a1
	move.w	#120-1,d6
.re2	move.w	#384/2-1,d7
.re1
	moveq	#0,d0
	moveq	#0,d1
	move.w	(a0),d0
	
	move.w	4(a0),d1
	move.w	d0,(a1)+
	move.w	d0,d2
	move.w	d1,d3
	move.w	d0,d4
	move.w	d1,d5

	add.l	d1,d0
	lsr.l	#1,d0	
	and.w	#%1111100000000000,d0

	and.w	#%11111100000,d2
	and.w	#%11111100000,d3
	add.w	d3,d2
	lsr.w	#1,d2	
	and.w	#%11111100000,d2

	and.w	#%11111,d4
	and.w	#%11111,d5
	add.w	d5,d4
	lsr.w	#1,d4	

	add.w	d4,d0
	add.w	d2,d0

	move.w	d0,(a1)+			
	addq	#4,a0


	dbf	d7,.re1
	add.w	#768,a1
	dbf	d6,.re2

	move.l	adr_ecr2,a1
	move.l	a1,a2
	add.l	#768,a2
	move.l	a1,a0
	add.l	#768*2,a0

	
	move.w	#120-1-1,d6
.re21	move.w	#384-1,d7
.re11
	moveq	#0,d0
	moveq	#0,d1
	move.w	(a0)+,d0
	move.w	(a1)+,d1
	move.w	d0,d2
	move.w	d1,d3
	move.w	d0,d4
	move.w	d1,d5
	add.l	d0,d1
	lsr.l	#1,d1	
	and.w	#%1111100000000000,d1
	and.w	#%11111100000,d2
	and.w	#%11111100000,d3
	add.w	d2,d3
	lsr.w	#1,d3	
	and.w	#%11111100000,d3
	and.w	#%11111,d4
	and.w	#%11111,d5
	add.w	d4,d5
	lsr.w	#1,d5	
	add.w	d5,d1
	add.w	d3,d1

	move.w	d1,(a2)+			
	dbf	d7,.re11
	add.w	#768,a1
	add.w	#768,a0
	add.w	#768,a2
	dbf	d6,.re21
	move.w	#384/2-1,d0
.reli	move.l	(a1)+,(a2)+
	dbf	d0,.reli	
	
	rts

converti_img
	lea	code_gen,a1
	lea	img1,a0
	add.l	#224,a0
	move.w	#75-1,d4
.re0bis	
	move.w	#20-1,d3
	moveq	#0,d7
.re0
	moveq	#15,d0
	move.w	(a0),d1

.re	btst	d0,d1
	bne.s	.ya_qqchose
	addq	#1,d7
	subq	#2,d0
	bpl.s	.re
	addq	#8,a0
	dbf	d3,.re0
	add.w	#160,a0
	move.w	#-1,(a1)+
	dbf	d4,.re0bis
	rts	
.ya_qqchose
	move.w	d7,(a1)+
	moveq	#0,d6
.reb	btst	d0,d1
	beq.s	.ya_rien
	addq	#1,d6
	subq	#2,d0
	bpl.s	.reb
	addq	#8,a0
	moveq	#15,d0
	move.w	(a0),d1
	dbf	d3,.reb

.ya_rien
	move.w	d6,(a1)+
	moveq	#0,d7
	bra.s	.re

copy_ecr
	move.l	adr_ecr,a0
	move.l	adr_ecr1,a1
	move.l	adr_ecr2,a2
	move.w	#192*120-1,d0
.re
	move.l	(a2),(a0)+
	move.l	(a2)+,(a1)+	
	move.l	(a2),(a0)+
	move.l	(a2)+,(a1)+	
	dbf	d0,.re
	rts	

affiche_code_gen
	move.l	adr_ecr,a0
	add.l	#768*20,a0
	lea	code_gen,a1
	move.l	a0,a2
	move.w	#75-1,d7
	moveq	#-1,d6
.re1
	add.l	#64,a2
.re
	move.w	(a1)+,d0
	bmi.s	.fin_li	
	lea	(a2,d0.w*4),a2
	move.w	(a1)+,d0
	subq	#1,d0
.re2	move.l	d6,(a2)+
	dbf	d0,.re2
	bra.s	.re
.fin_li	
	lea	768(a0),a0
	move.l	a0,a2
	dbf	d7,.re1	
	rts	

affiche_code_gen_in_dsp
.send0	btst	#1,$ffffa202.w
	beq.s	.send0	
	move.l	#3,$ffffa204.w

	lea	code_gen,a1
	move.l	#$500+192*20,a0
	move.l	a0,a2
	move.w	#75-1,d7
	moveq	#-1,d6
.re1
	add.l	#16,a2
.re
	move.w	(a1)+,d0
	bmi.s	.fin_li	
	add.w	d0,a2
.send1	btst	#1,$ffffa202.w
	beq.s	.send1	
	move.l	a2,$ffffa204.w


	move.w	(a1)+,d0
	add.w	d0,a2
	ext.l	d0
.send11	btst	#1,$ffffa202.w
	beq.s	.send11	
	move.l	d0,$ffffa204.w

	bra.s	.re
.fin_li	
	lea	192(a0),a0
	move.l	a0,a2
	dbf	d7,.re1	
	moveq	#0,d7
.send	btst	#1,$ffffa202.w
	beq.s	.send	
	move.l	d7,$ffffa204.w
	rts

	include	d:\nop\gour_lib.s

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
adr_tab_flamme
	dc.l	tab_flamme

tab_flamme
	dc.b	0
	rept	200
	dc.b	1
	endr
	dc.b	2
	rept	70
	dc.b	1
	endr

	dc.b	-1
	even
	
img1		incbin	e:\prism2\flamme2.pnt
		even

dsp		incbin	d:\flammes\flamm6.p56
dsp_size	equ	(*-dsp)/3
		even
dsp1		incbin	d:\texture\gouraud2.p56
dsp_size1	equ	(*-dsp1)/3
		even

adr_buff_eff	dc.l	buff_eff1,buff_eff3
		dc.l	buff_eff3,buff_eff1
adr_buffer	dc.l	0
incremente_obj	dc.w	3
decremente_obj	dc.w	0
wait_fin	dc.w	30*25
wait_fin2	dc.w	190


	section bss
compte_eff	ds.w	1
buff_eff1	ds.l	250
buff_eff3	ds.l	250
save_cacr	ds.w	1
synchro		ds.w	1
old_mode	ds.w	1
old_adr		ds.l	1
adr_ecr		ds.l	1
adr_ecr1	ds.l	1
adr_ecr2	ds.l	1
save_usp	ds.l	1
save_stk	ds.l	1
sauv_coul	ds.l	256
table_col	ds.w	256

sauv_vect	ds.l	16
ecran		ds.w	768*240+4
ecran1		ds.w	768*240+4
ecran2		ds.w	768*240+4
buffer		ds.b	27000
code_gen	ds.l	10000