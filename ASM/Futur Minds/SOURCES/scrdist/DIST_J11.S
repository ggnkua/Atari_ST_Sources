;---------------------------------------------------------------;
;	DISTORT-SCROLLER en X et Y		;
;	(c)  ska . nouvelle technique		;
;	V1.2: + routine en "scroll_rout" re-programm‚e.	;
;	V1.3: distort en Y		;
;	V2.0: scroll_rout re-re-programm‚e!	;
;---------------------------------------------------------------;

	output	scrdist0.prg
	opt	d+

	clr.w	-(a7)
	pea	-1.w
	pea	-1.w
	move.w	#5,-(a7)
	trap	#$e
	lea	12(a7),a7

	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7

;---------------------------------------------------------------;
;	Transformation du texte		;
;---------------------------------------------------------------;

	lea	text,a0

debut_test	move.b	(a0)+,d0
	bmi	fin_transfo

tst1	cmp.b	#1,d0
	bne.s	tst2
	lea	2(a0),a0	
	bra	debut_test
tst2	cmp.b	#2,d0
	bne.s	tst5
	lea	2(a0),a0
	bra	debut_test
tst5	cmp.b	#5,d0
	beq	debut_test
tst6	cmp.b	#6,d0
	beq	debut_test
tst10	cmp.b	#10,d0
	bne.s	tst11
	lea	1(a0),a0
	bra	debut_test
tst11	cmp.b	#11,d0
	bne.s	tstfin
	lea	1(a0),a0
	bra	debut_test

tstfin	cmp.b	#'(',d0
	bne.s	.test1
	move.b	#91,-1(a0)
	bra	debut_test
.test1	cmp.b	#')',d0
	bne.s	.test2
	move.b	#92,-1(a0)
	bra	debut_test
.test2	cmp.b	#'?',d0
	bne.s	.test3
	move.b	#93,-1(a0)
	bra	debut_test
.test3	cmp.b	#'!',d0
	bne.s	.test4
	move.b	#94,-1(a0)
	bra	debut_test
.test4	cmp.b	#' ',d0
	bne.s	.fin_test
	move.b	#95,-1(a0)
	bra	debut_test
.fin_test	bra	debut_test

fin_transfo
;---------------------------------------------------------------;
;	Sauvegardes			;
;---------------------------------------------------------------;

	lea	save,a0
	move.l	d0,(a0)+
	move.l	$70.w,(a0)+
	move.l	$68.w,(a0)+
	move.l	$ffff8200.w,(a0)+
	move.l	$fffffa06.w,(a0)+
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,(a0)

;---------------------------------------------------------------;
;	Initialisations			;
;---------------------------------------------------------------;

	move.l	#courbe_y_1,pos_courbe_y

	move.l	#ecran+256,d0
	clr.b	d0
	add.l	#160*272,d0	
	move.l	d0,scroller_adr

	move.l	#ecran+256,d0
	clr.b	d0
	move.l	d0,see_adr

	movem.l	scrol_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w

	clr.l	$fffffa06.w
	move.l	#vbl,$70.w

	moveq	#1,d0
	bsr	zik

;---------------------------------------------------------------;
;	Boucle principale VBL		;
;---------------------------------------------------------------;

start_vbl	move.l	#ecran+256,d1
	clr.b	d1
	add.l	#160*272*2,d1

	move.l	see_adr,d0
	add.l	#8*4*160,d0
	cmp.l	d1,d0
	bhi.s	debut_scrs

	move.l	d0,see_adr
	bra	plus_1280

debut_scrs	sub.l	#160*272*2,d0
	move.l	d0,see_adr

plus_1280	move.l	see_adr,d0
	add.l	#160*272,d0
	move.l	d0,scroller_adr

	move.l	see_adr,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w

	clr.w	flag_vbl
synchro1	tst.w	flag_vbl
	beq.s	synchro1

	move.l	#it_hbl,$68.w
	move.w	#$2100,sr

	lea	$fffffa00.w,a2
	move.b	#228,$21(a2)
	move.b	#8,$1b(a2)
	move.b	#1,$7(a2)
	move.b	#1,$13(a2)
	move.l	#it_timerb,$120.w

	bsr	scroll_rout

	bsr	zik+8

	;not.w	$ffff8240.w
	;dcb.w	127,$4e71
	;not	$ffff8240.w
	cmp.b	#$39,$fffffc02.w
	bne	start_vbl

;---------------------------------------------------------------;
;	Fin du programme		;
;---------------------------------------------------------------;

	moveq	#0,d0
	bsr	zik
	lea	$ffff8800.w,a0
	move.b	#8,(a0)
	clr.b	2(a0)
	move.b	#9,(a0)
	clr.b	2(a0)
	move.b	#10,(a0)
	clr.b	2(a0)

	move.w	#$2300,sr

	lea	save,a0
	move.l	(a0)+,-(a7)
	move.l	(a0)+,$70.w
	move.l	(a0)+,$68.w
	move.l	(a0)+,$ffff8200.w
	move.l	(a0)+,$fffffa06.w
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7

	clr.w	-(a7)
	trap	#1

;---------------------------------------------------------------;
;	Routine SCROLLER:		;
;---------------------------------------------------------------;

scroll_rout	move.w	offset_1,d3
	move.w	d3,d0 

	lea	adr_buffers,a0
	add.w	d0,d0
	add.w	d0,d0
	move.l	0(a0,d0.w),a1 

	move.l	adr_new_Letter,a3
	move.l	adr_old_Letter,a2

	add.w	offset_2,a1
	addq.l	#4,a1 

	lea	232(a1),a5	;largeur buffer
	lea	$3a00(a1),a0
	lea	232(a0),a4

	movem.l	a0-a1,-(a7)

	lea	bidon,a6
	moveq	#31,d0

affiche_mot	rept	2
	move.w	(a3)+,d2
	swap	d2
	move.w	(a2)+,d2
	rol.l	d3,d2
	move.b	d2,(a1)+
	move.w	d2,-5(a1)
	rol.l	#1,d2
	move.b	d2,(a0)+
	move.w	d2,-5(a0) 

	move.w	(a3)+,d2
	swap	d2
	move.w	(a2)+,d2
	rol.l	d3,d2
	move.b	d2,(a1)+
	move.w	d2,(a6)
	move.b	(a6),-5(a1)
	rol.l	#1,d2	
	move.b	d2,(a0)+
	move.w	d2,(a6)
	move.b	(a6),-5(a0)
	endr

	lea	460(a0),a0
	lea	460(a1),a1
	dbf	d0,affiche_mot

	movem.l	(a7)+,a0-a1
	subq.l	#4,a0
	subq.l	#4,a1
	subq.l	#4,a5
	subq.l	#4,a4

	rept	32
	move.l	(a0),(a4)
	move.l	4(a0),4(a4)
	move.l	(a1),(a5)
	move.l	4(a1),4(a5)
	lea	464(a0),a0
	lea	464(a1),a1
	lea	464(a4),a4
	lea	464(a5),a5
	endr	

	addq.w	#2,d3 
	cmp.w	#16,d3 
	beq	next_byte_text

;---------------------------------------------------------------;
;	Routine de distorsion en Y		;
;---------------------------------------------------------------;

distort_y	move.w	d3,offset_1

	move.w	pas_pour_y,d1

	lea	offset_movep+2,a1
	lea	clear_movep+2,a2
	move.l	pos_courbe_y,a0
fin_courbe_y	cmp.l	#courbe_y_1+360,a0
	blo.s	conti_courbe
	move.l	debut_courbe_y,a0
	move.l	a0,pos_courbe_y

conti_courbe
byte	set	0
col	set	0
k	set	0
	rept	5
	move.w	(a0),d0
	add.w	d1,a0
	add.w	#byte,d0
	move.w	d0,col(a1)
	move.w	d0,col+4(a1)
	move.w	d0,k(a2)
	move.w	d0,k+4(a2)
	move.w	(a0),d0
	add.w	d1,a0
	add.w	#byte+1,d0
	move.w	d0,col+8(a1)
	move.w	d0,col+12(a1)
	move.w	d0,k+8(a2)
	move.w	d0,k+12(a2)
	move.w	(a0),d0
	add.w	d1,a0
	add.w	#byte+8,d0
	move.w	d0,col+16(a1)
	move.w	d0,col+20(a1)
	move.w	d0,k+16(a2)
	move.w	d0,k+20(a2)
	move.w	(a0),d0
	add.w	d1,a0
	add.w	#byte+9,d0
	move.w	d0,col+24(a1)
	move.w	d0,col+28(a1)
	move.w	d0,k+24(a2)
	move.w	d0,k+28(a2)
	move.w	(a0),d0
	add.w	d1,a0
	add.w	#byte+$10,d0
	move.w	d0,col+32(a1)
	move.w	d0,col+36(a1)
	move.w	d0,k+32(a2)
	move.w	d0,k+36(a2)
	move.w	(a0),d0
	add.w	d1,a0
	add.w	#byte+$11,d0
	move.w	d0,col+40(a1)
	move.w	d0,col+44(a1)
	move.w	d0,k+40(a2)
	move.w	d0,k+44(a2)
	move.w	(a0),d0
	add.w	d1,a0
	add.w	#byte+$18,d0
	move.w	d0,col+48(a1)
	move.w	d0,col+52(a1)
	move.w	d0,k+48(a2)
	move.w	d0,k+52(a2)
	move.w	(a0),d0
	add.w	d1,a0
	add.w	#byte+$19,d0
	move.w	d0,col+56(a1)
	move.w	d0,col+60(a1)
	move.w	d0,k+56(a2)
	move.w	d0,k+60(a2)
byte	set	byte+$20
col	set	col+36*2-4
k	set	k+64
	endr

	moveq	#0,d0
	move.w	pas_courbe_y,d0
	add.l	d0,pos_courbe_y

;---------------------------------------------------------------;
;	Routine de distorsion en X		;
;---------------------------------------------------------------;

	lea	buffer,a0
	add.w	offset_2,a0

	move.l	scroller_adr,a1
	move.l	a1,a5
	sub.l	#160*272*2,a5

	move.l	adr_courbe,a2
	move.w	vitesse_courbe,d0
	add.w	d0,actuel_courbe
	move.w	long_courbe,d0

	cmp.w	actuel_courbe,d0
	bgt.s	pas_depasse

	clr.w	actuel_courbe

pas_depasse	add.w	actuel_courbe,a2
	move.w	d3,a6 

	moveq	#0,d2 

	lea	mul_3a00,a4

	moveq	#$1f,d0 

put_scroller	move.w	a6,d3
	add.b	(a2),d3
	add.w	depart_courbe,a2
	move.w	d3,d2 
	and.w	#-16,d2
	lsr.w	#1,d2 
	and.w	#15,d3
	add.w	d3,d3 
	add.w	d3,d3 
	move.l	0(a4,d3.w),d3
	add.w	d2,d3 
	lea	(a0),a3
	add.l	d3,a0 
	move.w	d0,-(a7)

	movem.l	(a0)+,d0-d7
offset_movep	movep.l	d0,$0(a1)
	movep.l	d0,$0(a5)
	movep.l	d1,$1(a1)
	movep.l	d1,$0(a5)
	movep.l	d2,$8(a1)
	movep.l	d2,$0(a5)
	movep.l	d3,$9(a1)
	movep.l	d3,$0(a5)
	movep.l	d4,$10(a1)
	movep.l	d4,$0(a5)
	movep.l	d5,$11(a1)
	movep.l	d5,$0(a5)
	movep.l	d6,$18(a1)
	movep.l	d6,$0(a5)
	movep.l	d7,$19(a1)
	movep.l	d7,$0(a5)
	movem.l	(a0)+,d0-d7
	movep.l	d0,$20(a1)
	movep.l	d0,$0(a5)
	movep.l	d1,$21(a1)
	movep.l	d1,$0(a5)
	movep.l	d2,$28(a1)
	movep.l	d2,$0(a5)
	movep.l	d3,$29(a1)
	movep.l	d3,$0(a5)
	movep.l	d4,$30(a1)
	movep.l	d4,$0(a5)
	movep.l	d5,$31(a1)
	movep.l	d5,$0(a5)
	movep.l	d6,$38(a1)
	movep.l	d6,$0(a5)
	movep.l	d7,$39(a1)
	movep.l	d7,$0(a5)
	movem.l	(a0)+,d0-d7
	movep.l	d0,$40(a1)
	movep.l	d0,$0(a5)
	movep.l	d1,$41(a1)
	movep.l	d1,$0(a5)
	movep.l	d2,$48(a1)
	movep.l	d2,$0(a5)
	movep.l	d3,$49(a1)
	movep.l	d3,$0(a5)
	movep.l	d4,$50(a1)
	movep.l	d4,$0(a5)
	movep.l	d5,$51(a1)
	movep.l	d5,$0(a5)
	movep.l	d6,$58(a1)
	movep.l	d6,$0(a5)
	movep.l	d7,$59(a1)
	movep.l	d7,$0(a5)
	movem.l	(a0)+,d0-d7
	movep.l	d0,$60(a1)
	movep.l	d0,$0(a5)
	movep.l	d1,$61(a1)
	movep.l	d1,$0(a5)
	movep.l	d2,$68(a1)
	movep.l	d2,$0(a5)
	movep.l	d3,$69(a1)
	movep.l	d3,$0(a5)
	movep.l	d4,$70(a1)
	movep.l	d4,$0(a5)
	movep.l	d5,$71(a1)
	movep.l	d5,$0(a5)
	movep.l	d6,$78(a1)
	movep.l	d6,$0(a5)
	movep.l	d7,$79(a1)
	movep.l	d7,$0(a5)
	movem.l	(a0)+,d0-d7
	movep.l	d0,$80(a1)
	movep.l	d0,$0(a5)
	movep.l	d1,$81(a1)
	movep.l	d1,$0(a5)
	movep.l	d2,$88(a1)
	movep.l	d2,$0(a5)
	movep.l	d3,$89(a1)
	movep.l	d3,$0(a5)
	movep.l	d4,$90(a1)
	movep.l	d4,$0(a5)
	movep.l	d5,$91(a1)
	movep.l	d5,$0(a5)
	movep.l	d6,$98(a1)
	movep.l	d6,$0(a5)
	movep.l	d7,$99(a1)
	movep.l	d7,$0(a5)

	lea	464(a3),a0
	lea	160(a1),a1
	lea	160(a5),a5
	move.w	(a7)+,d0 
	dbf	d0,put_scroller

	moveq	#0,d0
	moveq	#5-1,d1

clear_movep	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)
	movep.l	d0,0(a1)
	movep.l	d0,0(a5)

	lea	160(a1),a1
	lea	160(a5),a5
	dbf	d1,clear_movep

	rts

;---------------------------------------------------------------;
;	Op‚rations diverses sur le scroller	;
;---------------------------------------------------------------;

next_byte_text	moveq	#0,d3 
	addq.w	#8,offset_2
	cmp.w	#$e8,offset_2
	bne.s	new_letter

	clr.w	offset_2

new_letter	move.l	adr_new_letter,adr_old_letter
	subq.w	#1,demi_lettre
	beq	same_letter 
	move.l	position_text,a4

read_char	moveq	#0,d2 
	addq.l	#1,position_text
	move.b	(a4)+,d2
	bge.s	char_positif 
	lea	text,a4
	move.b	(a4)+,d2
	move.l	a4,position_text

char_positif	cmp.b	#32,d2 
	blt	param_1 
	bne.s	set_adr_letter 
	move.l	#fonte,adr_new_letter
	bra	distort_y 

set_adr_letter	sub.b	#$41,d2 	;2C
	lsl.w	#8,d2 
	add.w	d2,d2 
	add.l	#fonte,d2
	move.l	d2,adr_new_letter
	bra	distort_y 

same_letter	move.w	#2,demi_lettre
	add.l	#$100,adr_new_letter
	bra	distort_y 

;---------------------------------------------------------------;
;	ParamŠtres			;
;---------------------------------------------------------------;

param_1	cmp.b	#1,d2 	; 1: courbe Y -1-
	bne.s	param_2 
	move.l	#courbe_y_1,pos_courbe_y
	move.l	#courbe_y_1,debut_courbe_y
	move.l	#courbe_y_1+360,fin_courbe_y+2
	move.b	(a4)+,pas_pour_y+1
	move.b	(a4)+,pas_courbe_y+1
	addq.l	#2,position_text
	bra	read_char

param_2	cmp.b	#2,d2	; 2: courbe Y -2-
	bne.s	param_5
	move.l	#courbe_y_2,pos_courbe_y
	move.l	#courbe_y_2,debut_courbe_y
	move.l	#courbe_y_2+360,fin_courbe_y+2
	move.b	(a4)+,pas_pour_y+1
	move.b	(a4)+,pas_courbe_y+1
	addq.l	#2,position_text
	bra	read_char

param_5	cmp.b	#5,d2	; 5: courbe X -1-
	bne.s	param_6
	move.l	#courbe_x_1,adr_courbe
	move.w	#1440,long_courbe
	bra	read_char

param_6	cmp.b	#6,d2	; 6: courbe X -2-
	bne.s	param_10
	move.l	#courbe_x_2,adr_courbe
	move.w	#$210,long_courbe
	bra	read_char

param_10	cmp.b	#10,d2	; 10: vitesse courbe X
	bne.s	param_11 	; d'un scroll … l'autre
	move.b	(a4)+,vitesse_courbe+1
	addq.l	#1,position_text
	bra	read_char 

param_11	cmp.b	#11,d2	; 11: vitesse courbe X
	bne.s	param_rien	; d'1 ligne-scrol … l'autre
	move.b	(a4)+,depart_courbe+1
	addq.l	#1,position_text
	bra	read_char 

param_rien	bra	read_char 

;---------------------------------------------------------------;
;	Routines en interruption		;
;---------------------------------------------------------------;
	even
vbl	not.w	flag_vbl
	rte

it_hbl	rept	32
	addq.l	#6,$68.w
	rte
	endr
	subq.l	#6,$68.w
	stop	#$2100
	move.w	#$2700,sr
	or.w	#$300,(a7)
	dcb.w	58,$4e71
	move.b	#0,$ffff820a.w	
	dcb.w	35,$4e71
	move.b	#2,$ffff820a.w
	rte

it_timerb	movem.l	d0/a0,-(a7)

	lea	$ffff8209.w,a0
attend_count	cmp.b	#$d0,(a0)
	blo.s	attend_count
	move.w	#$f0,d0
	sub.b	(a0),d0
	lsr.l	d0,d0

	dcb.w	36,$4e71
	move.b	#0,$ffff820a.w
	dcb.w	17,$4e71
	move.b	#2,$ffff820a.w
	dcb.w	68,$4e71

	clr.b	$fffffa1b.w
	bclr.b	#0,$fffffa0f.w

	movem.l	(a7)+,d0/a0
	rte

;---------------------------------------------------------------;
	DATA			;
;---------------------------------------------------------------;

flag_vbl	dc.w	0

text:	dc.b	5
	dc.b	10,0
	dc.b	11,0
	dc.b	1,0,0
	dc.b	'   WATCH OUT THESE SCROLLS!   LET ME MAKE THESE SCROLLS MOVE STRAIGHT NOW!!'
	dc.b	'              '
	dc.b	10,32
	dc.b	11,0
	dc.b	'NOT SO BAD !  DO YOU WANT TO HAVE A HEAD ACHE NOW?'
	dc.b	'              '
	dc.b	1,0,2
	dc.b	'OK NOW WHAT ABOUT A FULL X DISTORSION TO USE PLENTY OF MACHINE TIME ?' 
	dc.b	'                '
	dc.b	6
	dc.b	10,12
	dc.b	11,6
	dc.b	'OVERSCAN X DISTORSION IS GETTING BORING NOWADAYS   ANYWAY HERE IS A REAL DISTORSION WITHOUT ANY CHEATING!'
	dc.b	'                '
	dc.b	5
	dc.b	10,32
	dc.b	11,1
	dc.b	'I AM TOO MAD FOR STOPPING HERE !   IF I AM DISTORTING IN X AND Y THE WHOLE SCREEN NOW DO YOU THINK IT IS POSSIBLE ON ATARI ?'
	dc.b	'               '
	dc.b	2,2,2
	dc.b	'AAARRRRGGGRRRHHHHHHHHH !!!  OF COURSE IT IS POSSIBLE !  I LOVE THESE WEIRD EFFECTS !!! '
	dc.b	'              '
	dc.b	2,2,4
	dc.b	'WHAT DO YOU THINK OF THIS FAST SCROLLER ROUTINE ?    LOOK OUT FOR MY DEMO !  GOODBYE !'
	dc.b	'              '
	dc.b	2,4,4
	dc.b	-1

	even

adr_new_letter	dc.l	fonte+30*512	;Adresse lettre courante
adr_old_letter	dc.l	fonte+30*512	;Adresse lettre ancienne
position_text	dc.l	text	;Adresse position actuelle text
offset_1	dc.w	0	;offset D3
offset_2	dc.w	0	;offset de 8 en 8
adr_buffers	dc.l	buffer	;Table buffers
	dc.l	buffer+$3a00,buffer+$3a00*2,buffer+$3a00*3,buffer+$3a00*4,buffer+$3a00*5,buffer+$3a00*6,buffer+$3a00*7,buffer+$3a00*8,buffer+$3a00*9,buffer+$3a00*10,buffer+$3a00*11,buffer+$3a00*12,buffer+$3a00*13,buffer+$3a00*14
	dc.l	buffer+$3a00*15
bidon	dc.w	0	;Mot pour le SWAP d'octets
mul_3a00	dc.l	0,$3a00,$3a00*2,$3a00*3,$3a00*4,$3a00*5,$3a00*6,$3a00*7,$3a00*8,$3a00*9,$3a00*10,$3a00*11,$3a00*12,$3a00*13,$3a00*14,$3a00*15
demi_lettre	dc.w	2	;Demi-lettre.

actuel_courbe	dc.w	0	;Position actuelle courbe X
depart_courbe	dc.w	0	;Position courbe X initiale
vitesse_courbe	dc.w	0	;Pas courbe X

pas_pour_y	dc.w	2
pas_courbe_y	dc.w	2

long_courbe	dc.w	0	;longueur en mots courbe en X
adr_courbe	dc.l	0	;Adresse courbe en X

debut_courbe_y	dc.l	0

zik	incbin	warp.snd

courbe_x_1	incbin	courbex4.bin
	incbin	courbex4.bin
courbe_x_2	incbin	courbesx.bin

img	incbin	lookfnt.pi1
fonte	equ	img+34
scrol_pal	equ	img+2

	even
courbe_y_1	incbin	ycourbe6.bin
courbe_y_2	incbin	ycourbe4.bin

;---------------------------------------------------------------------;
	BSS				;
;---------------------------------------------------------------------;
	even
see_adr	ds.l	1
scroller_adr	ds.l	1

pos_courbe_y	ds.l	1
save	ds.l	20

	even
bidon_bof	ds.b	160*272
ecran	ds.b	160*272+256
	ds.b	160*272
	ds.b	160*272
	ds.b	160*272

buffer	ds.b	$3a00*16


