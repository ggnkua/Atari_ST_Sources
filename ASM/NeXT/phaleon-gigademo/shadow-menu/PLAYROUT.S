* player BIPBIP LAP
* version avec repeat param‚trable (FFT)

	opt	o+

	PEA	0.W
	MOVE	#$20,-(SP)
	TRAP	#1
	ADDQ.L	#6,SP
LOADER
	move	$ffff8240.w,s_color
	move.b	#2,$484.w

	bsr.s	init

loop	move	#$25,-(a7)
	trap	#14
	addq.l	#2,a7
	lea	$ffff8209.w,a0
wait	move.b	(a0),d0
	beq.s	wait
	neg.w	d0
	lsl.l	d0,d0
	move.w	#0,$ffff8240.w
	bsr.s 	vbl
	move.w	#$777,$ffff8240.w
	cmp.b 	#$39,$fffffc02.w
	bne.s 	loop
	
sortir	bsr.s	cut
	move	s_color,$ffff8240.w
	clr	-(sp)
	trap	#1
cut	clr.l	$4d2.w
	move.b	#7,$484.w 
	move.l	#$08080000,$ffff8800.w
	move.l	#$09090000,$ffff8800.w
	move.l	#$0a0a0000,$ffff8800.w
	rts

s_color	ds.w	1


		*****************************************
		*	        PLAYER 			*
		*	MUSIQUE Sound Chip LAP		*
		*****************************************

*********************************
*	routine de pre-init	*
*********************************

init 
	movem.l d0-d2/a0-a3,-(a7)
	LEA	DATA_LAP_MUSIX(PC),A0
	BSR.S	NETOYAGE
	lea	wc_adresse(pc),a1
	MOVE.L	A0,(A1)
	lea 	position_pattern(pc),a1
	move	4(a0),(a1)
	bsr 	read_note
	movem.l (a7)+,d0-d2/a0-a3
	rts

*************************************************
*	routine a executer ttes les vbls	*
*************************************************
vbl 
	movem.l	a0-a3/d0-d3,-(sp)
	lea	$ffff8800.w,a2

	lea	compteur_vitesse(pc),a0
	subq	#1,(a0)

	bne	soundengine
	bsr	read_note
	movem.l (sp)+,a0-a3/d0-d3
	rts

inter	tst.b	d0
	bmi.s	.rts
	movem.l	a0-a1,-(a7)
	lea	priorite(pc),a1
	move.b	#1,(a1)
	lea	infos_voies(pc),a0
	lea	wc_adresse(pc),a1
	movea.l	(a1),a1
	add.w	14(a1),d0
	add	(a1),a1
	and	#$ff,d0
	add	d0,d0
	add	d0,a1
	move.w 	(a1),offset_adr_son+voie_3(a0)
	move.b	#1,flag_son+voie_3(a0)
	movem.l	(a7)+,a0-a1
.rts	rts
NETOYAGE:
	LEA	INFOS_VOIES(PC),A1
	MOVEQ	#2,D0
.LOOP	CLR	pos_sequence(A1)
	CLR.B	transposition(A1)
	CLR.B	seq(A1)
	CLR.L	sequence(A1)
	CLR.B	note(A1)
	CLR.B	son(A1)
	CLR	offset_adr_son(A1)
	CLR	frequence(A1)
	CLR.B	flag_son(A1)
	CLR.B	transp_son(A1)
	LEA	TAILLE_INFO(A1),A1
	DBF	D0,.LOOP

	LEA	manu(PC),A1
	CLR	(A1)
	CLR	2(A1)
	CLR	4(A1)
	CLR	6(A1)
	CLR	8(A1)
	CLR	10(A1)
	CLR.B	13(A1)
	CLR.B	15(A1)
	CLR.B	17(A1)
	CLR.B	19(A1)
	CLR.B	21(A1)
	CLR.B	23(A1)
	MOVE.B	#%11111000,25(A1)

	RTS


*********************************
*	gestion partition	*
*********************************
read_note

	lea 	position_pattern(pc),a1
	lea 	infos_voies(pc),a0
	lea	wc_adresse(pc),a2
	movea.l	(a2),a2
	move 	voie_2+pos_sequence(a0),d0
	cmp	10(a2),d0
	bne.s 	.mesure_pas_fini
					
	move	6(a2),d0
	cmp 	(a1),d0
	bne.s 	.pas_fin_music

	move	8(a2),(a1)
	bra.s 	.saute_ajout

.pas_fin_music
	addq 	#1,(a1)
.saute_ajout
	clr 	pos_sequence(a0)
	clr 	pos_sequence+voie_2(a0)
	clr 	pos_sequence+voie_3(a0)

********************************		lecture de la mesure
.mesure_pas_fini

	moveq 	#0,d1
	move 	(a1),d1
	add	2(a2),a2
	move.l	a2,a1
	mulu 	#12,d1
	adda 	d1,a1

	lea	priorite(pc),a2
	tst.b	(a2)
	beq.s	yop
	addq.w	#2,pos_sequence+voie_3(a0)
	moveq	#1,d2
	bra.s	superloop

yop	moveq	#2,d2
superloop
	move.b	(a1)+,seq(a0)
	move.b	(a1)+,transposition(a0)
	move.b	(a1)+,transp_son(a0)
	move.b	(a1)+,d1

	moveq	#0,d1
	move.b	seq(a0),d1
	lea	wc_adresse(pc),a2
	movea.l	(a2),a2
	mulu	10(a2),d1
	ADD	14(A2),A2
	add	d1,a2
	add	pos_sequence(a0),a2
	move.l	a2,sequence(a0)
	move.l	a2,a3
 
	moveq	#0,d0
	move.b	1(a2),son(a0)
	beq.s 	.pas_de_son
	move.b	transp_son(a0),d0
	add.b	d0,son(a0)

***************************** gestion des sons ******

.pas_de_son 
	move.b	son(a0),d0
	bne.s	z1

	tst.b	flag_son(a0)
	bne.s	r1
z1

	lea	wc_adresse(pc),a2
	movea.l	(a2),a2
	add	(a2),a2
	and	#$ff,d0
	add	d0,d0
	add	d0,a2
	move.w 	(a2),offset_adr_son(a0)
	move.b	#1,flag_son(a0)
r1 
 
************************************	frequence de la note
	moveq	#0,d0
	move.b 	(a3),d0
	beq.s	fin_gestion_voie

	add.b	transposition(a0),d0	
	move.b	d0,note(a0)
 
	lea 	table_frequence(pc),a2
	add	d0,d0
	add	d0,a2
	move.w	(a2),frequence(a0)

fin_gestion_voie
	addq.w	#2,pos_sequence(a0)
	lea	taille_info(a0),a0
	dbra	d2,superloop

	lea	compteur_vitesse(pc),a0
	lea	wc_adresse(pc),a2
	movea.l	(a2),a2
	move.w	12(a2),(a0)
	rts


*************************************************
*	Lecture effets (sons), restitution	*
*************************************************
soundengine
	lea	infos_voies(pc),a1
	tst.b	flag_son(a1)
	beq.s	.pas_effet_voie_1	
	moveq	#0,d2
	bsr.s	gere_effet_son
.pas_effet_voie_1

	lea	infos_voies+voie_2(pc),a1
	tst.b	flag_son(a1)
	beq.s	.pas_effet_voie_2
	moveq	#1,d2
	bsr.s	gere_effet_son
.pas_effet_voie_2

	lea 	infos_voies+voie_3(pc),a1
	tst.b	flag_son(a1)
	beq.s	.pas_effet_voie_3
	moveq	#2,d2
	bsr.s	gere_effet_son
.pas_effet_voie_3

***********************************	restitution yamhaha
	lea	registre(pc),a0
	movem.l	(a0)+,d0-d3
	movep.l	d0,(a2)
	movep.l	d1,(a2)
	movep.l	d2,(a2)
	movep.l	d3,(a2)

	movem.l	(sp)+,a0-a3/d0-d3
	rts


*********************************
*	Gestion des sons	*
*********************************
gere_effet_son
	lea	wc_adresse(pc),a0
	movea.l	(a0),a0
	add	(a0),a0
	add	offset_adr_son(a1),a0

effet_boucle
	cmp.b	#-1,(a0)
	beq	ret_force1

	cmpi.b	#$f0,(a0)
	bne.s	f1
	moveq	#8,d0
	add	d2,d0
	move.b	d0,(a2)
	move.b	1(a0),2(a2)
	addq	#2,offset_adr_son(a1)
	bra.s	GERE_EFFET_SON
f1
 	cmpi.b	#$f1,(a0)
	bne.s	f2
	moveq	#8,d0
	lea	reg7(pc),a3
	bset	d2,(a3)
	add	d2,d0
	move.b	d0,(a2)
	move.b	#16,2(a2)
	move.b	#11,(a2)
	move.b	1(a0),2(a2)
	move.l	#$0c0c0000,(a2)
	move.l	#$0d0d0e0e,(a2)
	addq.w	#2,offset_adr_son(a1)
	bra	fin_effet
f2
	cmpi.b	#$f2,(a0)
	bne.s	f3
	MOVEQ	#0,D0
	move.b	1(a0),d0
	lea	reg7(pc),a0
	move.b	d0,-2(a0)
	move.B	d2,d0
	bset.B	d0,(a0)
	addq.B	#3,d0
	bclr.B	d0,(a0)
	addq.W	#2,offset_adr_son(a1)
	bra	fin_effet
f3
	cmpi.b	#$f3,(a0)
	bne.s	f4
	moveq	#0,d0
	move.b	1(a0),d0
	add.w	d0,frequence(a1)
	addq	#2,offset_adr_son(a1)
	bra	fin_effet
f4
	cmpi.b	#$f4,(a0)
	bne.s	f5
	moveq	#0,d0
	move.b	1(a0),d0
	sub	d0,frequence(a1)
	addq	#2,offset_adr_son(a1)
	bra	fin_effet
f5
	cmpi.b	#$f5,(a0)
	bne.s	f6
	moveq	#0,d0
	move.b	note(a1),d0
	add.b	1(a0),d0
	and	#$7f,d0
	add	d0,d0
	lea	table_frequence(pc),a0
	add	d0,a0
	move	(a0),frequence(a1)
	addq	#2,offset_adr_son(a1)
	bra	fin_effet
f6
	cmpi.b	#$f6,(a0)
	bne.s	f7
	moveq	#0,d0
	move.b	1(a0),d0
	sub	d0,offset_adr_son(a1)
	bra	tt
f7
	cmpi.b	#$f7,(a0)
	bne.s	f8
	moveq	#0,d0
	lea	priorite(pc),a3
	clr.b	(a3)
	bra	ret_force1
		
F8	cmpi.B	#$F8,(A0)
	bne.b	f9
	lea	wc_adresse(pc),a3
	movea.l	(a3),a3
	move.b	1(a0),11(a3)
	addq.w	#2,offset_adr_son(a1)
	bra	fin_effet

F9	cmpi.B	#$F9,(A0)
	bne.b	fa
	moveq.l	#0,d0
	move.L	d2,d0
	addq.b	#8,d0
	move.b	d0,(a2)
	move.b	#16,2(a2)
	move.b	#11,(a2)
	move.b	1(a0),2(a2)
	move.b	#12,(a2)
	move.b	2(a0),2(a2)
	move.b	#13,(a2)
	move.b	3(a0),2(a2)
	addq.w	#4,offset_adr_son(a1)
	bra	fin_effet
	
Fa	cmpi.B	#$Fa,(A0)
	bne.b	fb
	move.l	#$0B0B0000,(a2)
	move.l	#$0C0C0000,(a2)
	move.l	#$0D0D0000,(a2)
	addq.w	#1,offset_adr_son(a1)
	bra	gere_effet_son

fb	
fC	cmpi.b	#$fC,(a0)
	bne.b	fD
	lea	reg7(pc),a3
	move.b	d2,d0
	addq.b	#3,d0
	bclr.B	d0,(a3)
	move.b	1(a0),-2(a3)
	addq.w	#2,offset_adr_son(a1)
	bra	fin_effet
fd
	cmpi.b	#$fd,(a0)
	bne.s	fe
	moveq	#0,d0
	MOVEQ	#0,D1
	move.b	1(a0),d1
	lea	reg7(pc),a0
	bset	d2,(a0)

	move.b	note(a1),d0
	lea	table_frequence(pc),a0
	add	#$30,d0
	and	#$7f,d0
	add	d0,d0
	add	d0,a0

	move.b	#11,(a2)
	move.b	1(a0),2(a2)
	move.l	#$0c0c0000,(a2)
	LEA	sauve_gras(PC),A3

	MOVE.B	1(A0),(A3)
	move.b	#13,(a2)
	move.b	d1,2(a2)
	moveq	#8,d1
	add	d2,d1
	move.b	d1,(a2)
	move.b	#16,2(a2)

	addq.w	#2,offset_adr_son(a1)
	bra.s 	fin_effet

fe	cmpi.b	#$fe,(a0)
	bne.b	e0
	moveq.l	#0,d0
	move.b	1(a0),d0	
	bmi.s	fe_suite
	add.b	note(a1),d0
	bra.s	fe_suite2
fe_suite
	subi.b	#$80,d0
fe_suite2
	lea	table_frequence(pc),a0
	add.W	d0,d0
	add.l	d0,a0
	move.w	(a0),d0
	and.l	#$ffff,d0
	move.w	d0,frequence(a1)
	addq.w	#2,offset_adr_son(a1)
	bra.S	fin_effet

e0
f00
	cmpi.b	#$00,(a0)
	bne.s	f01
	addq	#1,offset_adr_son(a1)
	bra.s	fin_effet
f01
	cmpi.b	#$01,(a0)
	bne.s	f02
	MOVEQ	#0,D0
	lea	reg7(pc),a3
	bclr.B	d2,(a3)
	move.B	d2,d0
	addq.B	#3,d0
	bset.B	d0,(a3)
	addq.W	#1,offset_adr_son(a1)
	bra	gere_effet_son
f02

F03	cmpi.b	#$03,(a0)
	bne.b	RET_FORCE1
	move.b	1(a0),d0	
	LEA	sauve_gras(PC),A3
	add.B	d0,(a3)
	move.b	#11,(a2)
	move.b	(A3),2(a2)
	addq.w	#2,OFFSET_ADR_SON(a1)
	
f04	

fin_effet 
	move	frequence(a1),d0
	lea	manu(pc),a0
	move.w	d0,(a0)

	lea	reg0(pc),a0
	add	d2,d2
	add	d2,d2
	add	d2,a0
	move.b	d0,(a0)
	move.b	manu(pc),2(a0)

tt
	rts

ret_force1
	move.w	frequence(a1),d0
	lea	manu(pc),a0
	move.w	d0,(a0)

	lea	reg0(pc),a0
	move	d2,d3
	add	d2,d2
	add	d2,d2
	add	d2,a0
	move.b	d0,(a0)
	move.b	manu(pc),2(a0)

	clr.b	flag_son(a1)

	lea	reg7(pc),a0
	addq	#3,d3
	bset	d3,(a0)
	rts

	section data

************ taille des bloc info sur chaque voie
	rsreset
pos_sequence	rs.w	1	*0
transposition	rs.b	1	*2
seq		rs.b	1	*3
sequence	rs.l	1	*4
note		rs.b	1	*8
son		rs.b	1	*9
offset_adr_son	rs.w	1	*10
frequence	rs.w	1	*12
flag_son	rs.b	1	*14
transp_son	rs.b	1	*15

voie_1=0
voie_2=__rs
voie_3=__rs*2
taille_info=__rs
infos_voies	ds.b	__rs*3

	even
manu	ds.w	1
compteur_vitesse	ds.w	1
position_pattern	ds.w	1
sauve_gras	DC.B	0,0
priorite	dc.b	0,0

registre	dc.b	0
reg0	dc.b	0
	dc.b	1
reg1	dc.b	0
	dc.b	2
reg2	dc.b	0
	dc.b	3
reg3	dc.b	0
	dc.b	4
reg4	dc.b	0
	dc.b	5
reg5	dc.b	0
	dc.b	6
reg6 	dc.b	0
	dc.b	7
reg7	dc.b	%11111000
	EVEN

table_frequence
	dc.w	$eee,$e17,$d4d,$c8e,$bd9,$b2f
	dc.w	$a8e,$9f7,$967,$8e0,$861,$7e8,$777,$70b 
	dc.w	$6a6,$647,$5ec,$597,$547,$4fb,$4b3,$470 
	dc.w	$430,$3f4,$3bb,$385,$353,$323,$2f6,$2cb 
	dc.w	$2a3,$27d,$259,$238,$218,$1fa,$1dd,$1c2 
	dc.w	$1a9,$191,$17b,$165,$151,$13e,$12c,$11c 
	dc.w	$10c,$fd,$ee,$e1,$d4,$c8,$bd,$b2  
	dc.w	$a8,$9f,$96,$8e,$86,$7e,$77,$70  
	dc.w	$6a,$64,$5e,$59,$54,$4f,$4b,$47  
	dc.w	$43,$3f,$3b,$38,$35,$32,$2f,$2c  
	dc.w	$2a,$27,$25,$23,$21,$1f,$1d,$1c
	dc.w	$1a,$19,$17,$16,$15,$13,$12,$11,$10,$f
	EVEN
WC_adresse:	dc.l	0
