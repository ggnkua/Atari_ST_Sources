	****************************************
	**          ATTENTION !!!	     **
	**			     **
	**	PAS DE SORTIE !!!	     **
	**			     **
	**	 	 	     **
	****************************************	



adr_scr= 		$78000+160*174	*  position scroll
nbre_ligne=	24
ecr= 		$78000+160*180+8*2	*  position vu_metre

	
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	move.w	#0,-(sp)
	move.l	#$78000,-(sp)
	move.l	#$78000,-(sp)
	move.w	#5,-(sp)
	trap	#14
	adda.l	#12,sp
	
	CLR.L	$FF8240
	CLR.L	$FF8244
	CLR.L	$FF8248
	CLR.L	$FF824C
	CLR.L	$FF8250
	CLR.L	$FF8254
	CLR.L	$FF8248
	CLR.L	$FF824C
	
	
	
	dc.w $a00a
	move.b #$12,$fffc02
	
	lea	$78000,a0
	lea	pic+34,a1
	move.l	#32000-1,d0
	
copypic
	move.b	(a1)+,(a0)+
	dbf	d0,copypic
	
	movem.l	pic+2,d0-d7
	movem.l	d0-d7,$ff8240
	

	move.b	#2,$ff820a	
	

	
	lea	$78000,a0
	lea	buffer,a1
	moveq	#17,d0
copybuf
	movem.l	(a0),d1-d6
	movem.l	d1-d6,(a1)
	
	
	lea	160(a0),a0
	lea	24(a1),a1
	dbf	d0,copybuf
	

	LEA	music,A0
	
	MOVE.L	#music+$34E0,$A4(A0)
	MOVE.L	#music+$8B0,$202(A0)
	MOVE.L	#music+$8B0,$87C(A0)

	
	lea	music2,a0
	move.l	#music2+$86e,$1aa(a0)
	move.l	#music2+$86f,$828(a0)
	move.l	#music2+$86e,$83c(a0)
	

	LEA	music2,A0
	MOVE.L	A0,D0
	LEA	$C3E(A0),A0
	CMPI.L	#$89A0,(A0)
	BNE.S	suitee
	MOVEQ	#3,D2
repe	MOVE.L	(A0),D1
	SUBI.L	#$7D52,D1
	ADD.L	D0,D1
	MOVE.L	D1,(A0)+
	DBF	D2,repe
suitee	
	

	
	
	
	MOVEQ	#1,D0
	JSR	music2
	JSR	music2+$8
	
	MOVEQ	#2,D0
	JSR	music
	JSR	music+$8
	
	move.l	#key,$118
	move.l	#vbl,$70

bcle
	
	cmp.b	#$3b,$fffc02
	beq	music1
	cmp.b	#$3c,$fffc02
	beq	music_2
	cmp.b	#$3d,$fffc02
	beq	music3
	cmp.b	#$3e,$fffc02
	beq	music4
	cmp.b	#$3f,$fffc02
	beq	music5
	cmp.b	#$40,$fffc02
	beq	music6
	cmp.b	#$41,$fffc02
	beq	music7
	
	bra	bcle
music1
	move.l	#1,zic
	jmp	bcle	
music_2
	move.l	#2,zic
	jmp	bcle	
music3
	move.l	#3,zic
	jmp	bcle	
music4
	move.l	#4,zic
	jmp	bcle	
music5
	move.l	#5,zic
	jmp	bcle	
music6
	move.l	#6,zic
	jmp	bcle	
music7
	move.l	#7,zic
	jmp	bcle	







	
scroll
go	clr.l	d0
	movea.l	compteur,a0
	move.B	(a0),d0
	cmp.b	#0,d0
	beq 	red
	
go2	
	sub.b	#39,d0
	
	cmp.b	#-7,d0
	beq	p1
	cmp.b	#-6,d0
	beq	p2
	cmp.b	#-4,d0
	beq	p3
	cmp.b	#22,d0
	beq	p4
	cmp.b	#24,d0
	beq	p5
	cmp.b	#46,d0
	bhs	p6
	cmp.b	#36,d0
	bhs	p7
	cmp.b	#26,d0
	bhs	p8
	cmp.b	#10,d0
	bhs	p9
	mulu.w	#16,d0
	move.w	d0,pos
	jmp	scrl2
p1
	move.w	#160*25*5,pos
	
	jmp	scrl2
p2
	move.w	#160*25*5+16,pos
	jmp	scrl2
p3
	move.w	#160*25*5+32,pos
	jmp	scrl2
p4
	move.w	#160*25*5+48,pos
	jmp	scrl2
p5
	move.w	#160*25*5+64,pos
	jmp	scrl2
p6
	move.w	#160*25*4,pos
	sub.b	#46,d0
	mulu.w	#16,d0
	add.w	d0,pos
	jmp	scrl2

p7
	move.w	#160*25*3,pos
	sub.b	#36,d0
	mulu.w	#16,d0
	add.w	d0,pos
	jmp	scrl2

p8
	move.w	#160*25*2,pos
	sub.b	#26,d0
	mulu.w	#16,d0
	add.w	d0,pos
	jmp	scrl2
p9
	move.w	#160*25,pos
	sub.b	#10,d0
	mulu.w	#16,d0
	add.w	d0,pos
	jmp	scrl2


	
	
	
	
	
	
	
scrl2	lea	adr_scr,a0
	lea	font+34,a6
	adda.w	pos,a6
	adda.l	de,a6
	move.l	a6,a1
	
	move.w	#nbre_ligne,d0
ligne
	
	
	move.b	1(a0),(a0)
	move.b	8(a0),1(a0)
	move.b	9(a0),8(a0)
	move.b	16(a0),9(a0)
	move.b	17(a0),16(a0)
	move.b	24(a0),17(a0)
	move.b	25(a0),24(a0)
	move.b	32(a0),25(a0)
	move.b	33(a0),32(a0)
	move.b	40(a0),33(a0)
	move.b	41(a0),40(a0)
	move.b	48(a0),41(a0)
	move.b	49(a0),48(a0)
	move.b	56(a0),49(a0)
	move.b	57(a0),56(a0)
	move.b	64(a0),57(a0)
	move.b	65(a0),64(a0)
	move.b	72(a0),65(a0)
	move.b	73(a0),72(a0)
	move.b	80(a0),73(a0)
	move.b	81(a0),80(a0)
	move.b	88(a0),81(a0)
	move.b	89(a0),88(a0)
	move.b	96(a0),89(a0)
	move.b	97(a0),96(a0)
	move.b	104(a0),97(a0)
	move.b	105(a0),104(a0)
	move.b	112(a0),105(a0)
	move.b	113(a0),112(a0)
	move.b	120(a0),113(a0)
	move.b	121(a0),120(a0)
	move.b	128(a0),121(a0)
	move.b	129(a0),128(a0)
	move.b	136(a0),129(a0)
	move.b	137(a0),136(a0)
	move.b	144(a0),137(a0)
	move.b	145(a0),144(a0)
	move.b	152(a0),145(a0)
	move.b	153(a0),152(a0)
	
	move.b	(a1),153(a0)
	
	
	move.b	3(a0),2(a0)
	move.b	10(a0),3(a0)
	move.b	11(a0),10(a0)
	move.b	18(a0),11(a0)
	move.b	19(a0),18(a0)
	move.b	26(a0),19(a0)
	move.b	27(a0),26(a0)
	move.b	34(a0),27(a0)
	move.b	35(a0),34(a0)
	move.b	42(a0),35(a0)
	move.b	43(a0),42(a0)
	move.b	50(a0),43(a0)
	move.b	51(a0),50(a0)
	move.b	58(a0),51(a0)
	move.b	59(a0),58(a0)
	move.b	66(a0),59(a0)
	move.b	67(a0),66(a0)
	move.b	74(a0),67(a0)
	move.b	75(a0),74(a0)
	move.b	82(a0),75(a0)
	move.b	83(a0),82(a0)
	move.b	90(a0),83(a0)
	move.b	91(a0),90(a0)
	move.b	98(a0),91(a0)
	move.b	99(a0),98(a0)
	move.b	106(a0),99(a0)
	move.b	107(a0),106(a0)
	move.b	114(a0),107(a0)
	move.b	115(a0),114(a0)
	move.b	122(a0),115(a0)
	move.b	123(a0),122(a0)
	move.b	130(a0),123(a0)
	move.b	131(a0),130(a0)
	move.b	138(a0),131(a0)
	move.b	139(a0),138(a0)
	move.b	146(a0),139(a0)
	move.b	147(a0),146(a0)
	move.b	154(a0),147(a0)
	move.b	155(a0),154(a0)
	
	move.b	2(a1),155(a0)
	
	
	move.b	5(a0),4(a0)
	move.b	12(a0),5(a0)
	move.b	13(a0),12(a0)
	move.b	20(a0),13(a0)
	move.b	21(a0),20(a0)
	move.b	28(a0),21(a0)
	move.b	29(a0),28(a0)
	move.b	36(a0),29(a0)
	move.b	37(a0),36(a0)
	move.b	44(a0),37(a0)
	move.b	45(a0),44(a0)
	move.b	52(a0),45(a0)
	move.b	53(a0),52(a0)
	move.b	60(a0),53(a0)
	move.b	61(a0),60(a0)
	move.b	68(a0),61(a0)
	move.b	69(a0),68(a0)
	move.b	76(a0),69(a0)
	move.b	77(a0),76(a0)
	move.b	84(a0),77(a0)
	move.b	85(a0),84(a0)
	move.b	92(a0),85(a0)
	move.b	93(a0),92(a0)
	move.b	100(a0),93(a0)
	move.b	101(a0),100(a0)
	move.b	108(a0),101(a0)
	move.b	109(a0),108(a0)
	move.b	116(a0),109(a0)
	move.b	117(a0),116(a0)
	move.b	124(a0),117(a0)
	move.b	125(a0),124(a0)
	move.b	132(a0),125(a0)
	move.b	133(a0),132(a0)
	move.b	140(a0),133(a0)
	move.b	141(a0),140(a0)
	move.b	148(a0),141(a0)
	move.b	149(a0),148(a0)
	move.b	156(a0),149(a0)
	move.b	157(a0),156(a0)
	
	move.b	4(a1),157(a0)
	
	
	
	
	
	
	lea	160(a0),a0
	lea	160(a1),a1
	dbra	d0,ligne
	add.l	#1,de1
	cmp.l	#2,de1
	beq	plus
	cmp.l	#4,de1
	beq	plus2
	add.l	#1,de
	rts
plus
	add.l	#7,de
	rts
plus2
	
	move.l	#0,de1
	move.l	#0,de
	addq.l	#1,compteur
	rts
red	
	move.l	#text,compteur
	clr.l	d0
	movea.l	compteur,a0
	move.B	(a0),d0
	
	JMP	go2
	
	
	
gauche
	
	roxl	128(a0)
	roxl	120(a0)
	roxl	112(a0)
	roxl	104(a0)
	roxl	96(a0)
	roxl	88(a0)
	roxl	80(a0)
	roxl	72(a0)
	roxl	64(a0)
	roxl	56(a0)
	roxl	48(a0)
	roxl	40(a0)
	roxl	32(a0)
	roxl	24(a0)
	
	roxl	130(a0)
	roxl	122(a0)
	roxl	114(a0)
	roxl	106(a0)
	roxl	98(a0)
	roxl	90(a0)
	roxl	82(a0)
	roxl	74(a0)
	roxl	66(a0)
	roxl	58(a0)
	roxl	50(a0)
	roxl	42(a0)
	roxl	34(a0)
	roxl	26(a0)
	
	roxl	132(a0)
	roxl	124(a0)
	roxl	116(a0)
	roxl	108(a0)
	roxl	100(a0)
	roxl	92(a0)
	roxl	84(a0)
	roxl	76(a0)
	roxl	68(a0)
	roxl	60(a0)
	roxl	52(a0)
	roxl	44(a0)
	roxl	36(a0)
	roxl	28(a0)
	rts
droite
	
	roxr	24(a0)
	roxr	32(a0)
	roxr	40(a0)
	roxr	48(a0)
	roxr	56(a0)
	roxr	64(a0)
	roxr	72(a0)
	roxr	80(a0)
	roxr	88(a0)
	roxr	96(a0)
	roxr	104(a0)
	roxr	112(a0)
	roxr	120(a0)
	roxr	128(a0)
	
	
	
	roxr	26(a0)
	roxr	34(a0)
	roxr	42(a0)
	roxr	50(a0)
	roxr	58(a0)
	roxr	66(a0)
	roxr	74(a0)
	roxr	82(a0)
	roxr	90(a0)
	roxr	98(a0)
	roxr	106(a0)
	roxr	114(a0)
	roxr	122(a0)
	roxr	130(a0)
	
	
	
	roxr	28(a0)
	roxr	36(a0)
	roxr	44(a0)
	roxr	52(a0)
	roxr	60(a0)
	roxr	68(a0)
	roxr	76(a0)
	roxr	84(a0)
	roxr	92(a0)
	roxr	100(a0)
	roxr	108(a0)
	roxr	116(a0)
	roxr	124(a0)
	roxr	132(a0)
	
	rts

deformation
	
	
	lea	waveform,a1
	move.w	position_def,d0
	add.w	d0,a1
	cmp.b	#2,(a1)
	bne	cont_def1
	lea	waveform,a1
	move.w	#0,position_def
cont_def1
	
	lea	$78000+21*160,a0
	
	move.l	#31,d0
copyl
	cmp.b	#2,(a1)
	bne	cont_1
	move.w	#0,position_def
	lea	waveform,a1
	
cont_1	cmp.b	#0,(a1)
	beq	no_change
	cmp.b	#-1,(a1)
	beq	gauche_def
	bsr	droite
	bra	no_change
gauche_def	
	bsr	gauche
no_change
	
	lea	1(a1),a1
	lea	160(a0),a0
	dbf	d0,copyl
	add.w	#1,position_def
	rts
	
vu_metre
	jsr	voix1
	move.b	level1,d1
	cmp.b	d1,d0
	bhs	cont1
	sub.b	#1,d1
	cmp.b	#0,d1
	bhs	c1
	move.b	#0,d1
c1	move.b	d1,d0
cont1	move.b	d0,level1

	moveq	#15,d1
	sub.b	d0,d1
	lea	$78006+160*160+8*6,a0
	bsr	vu
	
	
	jsr	voix2
	
	move.b	level2,d1
	cmp.b	d1,d0
	bhs	cont2
	sub.b	#1,d1
	cmp.b	#0,d1
	bhs	c2
	move.b	#0,d1
c2	move.b	d1,d0
cont2	move.b	d0,level2

	moveq	#15,d1
	sub.b	d0,d1
	lea	$78006+160*160+8*9,a0
	bsr	vu
	
	jsr	voix3
	move.b	level3,d1
	cmp.b	d1,d0
	bhs	cont3
	sub.b	#1,d1
	cmp.b	#0,d1
	bhs	c3
	move.b	#0,d1
c3	move.b	d1,d0
cont3	move.b	d0,level3
	
	moveq	#15,d1
	sub.b	d0,d1
	lea	$78006+160*160+8*12,a0
	bsr	vu
	
	
	rts
voix1
	clr.l	d0
	move.b	#8,$ff8800
	move.b	$ff8800,d0
	and.b	#15,d0
	rts
voix2
	clr.l	d0
	move.b	#9,$ff8800
	move.b	$ff8800,d0
	and.b	#15,d0
	rts
voix3
	clr.l	d0
	move.b	#10,$ff8800
	move.b	$ff8800,d0
	and.b	#15,d0
	rts
vu	
	moveq	#0,d2
copy_barre
	move.w	#$ffff,(a0)
	move.w	#$ffff,-160(a0)
	move.w	#$ffff,-320(a0)
	move.b	#$ff,8(a0)
	move.b	#$ff,-160+8(a0)
	move.b	#$ff,-320+8(a0)
	
	lea	-800(a0),a0
	*addq.b	#2,d2
	*cmp.b	#8,d2
	*bne	oncont
	*moveq	#0,d2
	*lea	-8(a0),a0


oncont	
	dbf	d0,copy_barre
	
	
copy_cls
	clr.w	(a0)
	clr.w	-160(a0)
	clr.w	-320(a0)
	clr.b	8(a0)
	clr.b	-160+8(a0)
	clr.b	-320+8(a0)
	
	
	lea	-800(a0),a0
	dbf	d1,copy_cls
	
	rts
zicmu
	cmp.l	#0,zic
	bne	newz
	rts
newz	
	cmp.l	#5,zic
	bhs	newz2
	
	move.b	#0,zic3
	
	move.l	zic,d0
	move.l	zic2,d1
	
	cmp.l	d0,d1
	beq	nonewzax
	MOVE.B	#0,$FFFFFA1D.W
	MOVE.B	#$3E,$FFFFFA23.W
	lea	$ff8800,a0
	move.l	#$08080000,(a0)
	move.l	#$09090000,(a0)
	move.l	#$0a0a0000,(a0)
	
	jsr	music2
	move.l	zic,zic2
	clr.l	zic
nonewzax	rts
newz2
	move.b	#1,zic3
	
	move.l	zic,d0
	move.l	zic2,d1
	cmp.l	d0,d1
	beq	nonewzax2
	MOVE.B	#0,$FFFFFA1D.W
	MOVE.B	#$3E,$FFFFFA23.W
	lea	$ff8800,a0
	move.l	#$08080000,(a0)
	move.l	#$09090000,(a0)
	move.l	#$0a0a0000,(a0)
	sub.l	#4,d0
	
	jsr	music
	move.l	zic,zic2
	clr.l	zic
nonewzax2	rts
	
	
	
	
	

depla
	lea	buffer,a0
	lea	$78000,a1
	moveq	#0,d1
	move.b	where,d1
	mulu	#160,d1
	
	adda.l	d1,a1

	bsr	logo_recopy
	
	cmp.b	#1,where1
	bne	conti1
	sub.b	#1,where
	bra	conti2
conti1
	add.b	#1,where
conti2
	
	cmp.b	#40,where
	bne	conti3
	move.b	#1,where1
conti3
	cmp.b	#0,where
	bne	conti4
	move.b	#0,where1
conti4
	
	
	lea	buffer,a0
	lea	$78000+8*17,a1
	moveq	#0,d1
	move.b	where2,d1
	mulu	#160,d1
	
	adda.l	d1,a1

	bsr	logo_recopy
	
	cmp.b	#1,where12
	bne	conti12
	add.b	#1,where2
	bra	conti22
conti12
	sub.b	#1,where2
conti22
	
	cmp.b	#40,where2
	bne	conti32
	move.b	#0,where12
conti32
	cmp.b	#0,where2
	bne	conti42
	move.b	#1,where12
conti42

	
	rts







logo_recopy
	moveq	#17,d0
copy_logo
	movem.l	(a0),d1-d6
	movem.l	d1-d6,(a1)
	
	
	lea	24(a0),a0
	lea	160(a1),a1
	dbf	d0,copy_logo
	rts
	




vbl	
	
	move.l	pic+4,$ffff8242.w
	move.l	pic+8,$ffff8246.w
	move.l	pic+12,$ffff824a.w
	move.w	pic+14,$ffff824e.w
	
	bsr	scroll
	bsr	zicmu
	
	move.l	font+4,$ffff8242.w
	move.l	font+8,$ffff8246.w
	move.l	font+12,$ffff824a.w
	move.w	font+14,$ffff824e.w
	
	
	cmp.b	#0,zic3
	bne	ot
	jsr	music2+4
	bra	ot2
ot	jsr	music+4
ot2
	
	bsr	vu_metre  
	bsr	deformation
	bsr	depla
	
	rte

	
key	rte

	



text	
	dc.b	"                                                "
	dc.b	"  BABEBIBOBU !!!!!! HERE ME ( ORION ) AGAIN !!!   ........ AS YOU CAN SEE IT , AND ABOVE ALL  LISTEN TO IT , YOU ARE IN THE SOUNDTRACK DEPARTMENT OF THE FUZION MUSIC SYSTEM   ..............."
	DC.B	" THERE ARE SEVEN SOUNDTRACK MUZAXX HERE ... PRESS F1 TO F7 TO SELECT A MUZIK ....... NOW THE CREDITS : CODE BY ORION  , DRAGON BY A GAME NAMED DYNASTY WAR , FONTS BY I DON'T KNOW !!! , AND MUZAXX BY ME ......."
	DC.B	"                             NO , THAT'S A JOKE , THE MUSICS HAVE BEEN MADE BY MAD MAX ( OF COURSE !!! ) , AND COME FROM 2 MAGNIFICS THALION 'S GAMES   : CHAMBERS OF SHAOLIN ( F1-F4 ) , AND THE SEVEN GATES OF JAMBALA ( F5-F7 )  "
	DC.B	"............ AND NOW MY GREETINGS :  FIRST , I WANT TO THANK A LOT AXE OF DELIGHT FOR HIS GREAT ICE PACKER ........ AND I WANT TO THANK ALSO YODA FROM THE EMPIRE WHO MADE THE 2 V8 MUSIC SYSTEM .... THEY ARE VERY GOOD BUT I THOUGHT"
	DC.B	" THAT THERE WEREN'T ENOUGH MAD MAX MUSICS , SO I MADE THIS MUSIC SYSTEM .... AND NOW I THINK THAT THEY WILL BE COMPLEMENTARY  .............  "
	dc.b	" AND I THANK AT LAST NASTY WHO HELPED ME , AND WHO SUPPORTED ME ............ "
	dc.b	"NORMAL GREETINGS TO ALL CREWS ON THE ATARI AND ESPECIALLY HMD AND IMPACT , BLUEMAX AND "
	DC.B	"TEC OF V8 ............    "
	DC.B	" THEN I SEND MY PERSONNAL GREETINGS : BIG HELLO TO ALL MY OLD GOOD FRIENDS , I HOPE TO SEE YOU AGAIN ONE DAY :   HI TO GENESIS ( BON REDEMARRAGE SUR ST !!! , A BIENTOT ) , GRAFIX ( A BIENTOT ) , MA-C ( TU PEUX M'ENVOYER DES NEW "
	DC.B	"PICS ... ) , LITTLE PAPA  , MAGUY , ARTAX , BLUEBIRD ( BONNE T.D ) AND FINALLY BIG HELLO TO THE OTHERS MEMBERS OF FUZION : THE DRAGON ( N'OUBLIE PAS LES NEWS ... ), THE DEVIL ( CODE , CODE , CODE !!! )"
	DC.B	" , SQUAT ( ENVOIE MOI DES PICS .... ) , AND FULCRUM WHO I GIVE THE KEYBOARD  ( ALTHOUGH THERE ARE 500 KILOMETERS BEETWEN US !!!!! ) .....   SO , A BIENTOT GUYS ..........  BYE BYE EVERYBODY ............. SEE YA SOON !!!!.........."
	  
	DC.B	0
	
music	incbin	sndtrk_j
music2	incbin	sndtrk
font	incbin	backup.pi1
pic	incbin	deform3.pi1


waveform	
	rept	32*2*2
	dc.b	0
	endr
	
	
	rept	10
	dc.b	0,1,0,0,1,0,0,0
	dc.b	0,0,0,-1,0,0,-1,0
	dc.b	0,-1,0,0,-1,0,0,0
	dc.b	0,0,0,1,0,0,1,0
	endr
	
	
	
	rept	32
	dc.b	1,0,1,0
	endr
	rept	32
	dc.b	-1,0,-1,0
	endr
	rept	32
	dc.b	-1,0,-1,0
	endr
	rept	32
	dc.b	1,0,1,0
	endr
	
	rept	16
	dc.b	0
	endr
	
	
	
	rept	5*2
	dc.b	0,1,0,1,0,1,0,1
	dc.b	-1,0,-1,0,-1,0,-1,0
	dc.b	-1,0,-1,0,-1,0,-1,0
	dc.b	1,0,1,0,1,0,1,0
	endr
	
	
	
	dc.b	1,1,1,1,1,1,1,1
	rept	24
	dc.b	0,0,0
	endr
	dc.b	1,1,1,1,1,1,1,1
	rept	24
	dc.b	0,0,0
	endr
	
	
	
	rept	10*2
	dc.b	0,1,0,1,0,1,0,0
	dc.b	0,0,-1,0,-1,0,-1,0
	dc.b	-1,0,-1,0,-1,0,0,0
	dc.b	0,0,1,0,1,0,1,0
	endr
	
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1
	rept	24
	dc.b	0,0,0
	endr
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1
	rept	24
	dc.b	0,0,0
	endr
	
	rept	10*2
	dc.b	0,0,1,0,0,1,0,0
	dc.b	0,0,-1,0,0,-1,0,0
	dc.b	0,0,-1,0,0,-1,0,0
	dc.b	0,0,1,0,0,1,0,0
	endr
	
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1
	rept	24
	dc.b	0,0,0
	endr
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1
	rept	24
	dc.b	0,0,0
	endr
	
	rept	10*2
	dc.b	1,1,1,1,1,1,1,1
	dc.b	0,0,0
	dc.b	-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	0,0,0
	endr
	
	dc.b	1,1,1,1,1,1,1,1
	rept	24
	dc.b	0,0,0
	endr
	dc.b	1,1,1,1,1,1,1,1
	rept	24
	dc.b	0,0,0
	endr
	
	
	rept	32
	dc.b	1,0,-1,1,0
	endr
	rept	32
	dc.b	-1,0,1,-1,0
	endr
	rept	32
	dc.b	-1,0,1,-1,0
	endr
	rept	32
	dc.b	1,0,-1,1,0
	endr
	
	
	rept	15  
	dc.b	0,1,0,1,0,1,0,1
	dc.b	0,0,0,0
	dc.b	-1,0,-1,0,-1,0,-1,0
	dc.b	-1,0,-1,0,-1,0,-1,0
	dc.b	0,0,0,0
	dc.b	0,1,0,1,0,1,0,1
	endr
	
	rept	32
	dc.b	1,0,1
	endr
	rept	32
	dc.b	-1,0,-1
	endr
	rept	32
	dc.b	-1,0,-1
	endr
	rept	32
	dc.b	1,0,1
	endr
	
	rept	10
	dc.b	1,1,0,1,0,1,0,1
	dc.b	0,0,0,0
	dc.b	-1,0,-1,0,-1,0,-1,-1
	dc.b	-1,0,-1,0,-1,0,-1,-1
	dc.b	0,0,0,0
	dc.b	1,1,0,1,0,1,0,1
	endr
	
	rept	10
	dc.b	0,1,1,1,1,1,0,1,1,1,1,0,1
	dc.b	0,0,0,0
	dc.b	-1,0,-1,0,-1,-1,-1,-1,-1,-1,-1,-1
	dc.b	0,-1,-1,-1,-1,-1,-1,-1,-1,0,-1,0,-1
	dc.b	0,0,0,0
	dc.b	1,0,1,0,1,1,1,1,1,1,1,1
	endr
	
	rept	32
	dc.b	1,0,-1,1
	endr
	rept	32
	dc.b	-1,0,1,-1
	endr
	rept	32
	dc.b	-1,0,1,-1
	endr
	rept	32
	dc.b	1,0,-1,1
	endr
	
	
	rept	32*4
	dc.b	1,0,0,-1,1,-1
	endr
	
	
	rept	32*2
	dc.b	0
	endr
	
	dc.b	2


compteur	dc.l	text
pos	dc.w	0	
suite	dc.w	0
de	dc.l	0
de1	dc.l	0

position_def	
	dc.w	0	
level1	dc.b	0
level2	dc.b	0
level3	dc.b	0
zic	dc.l	1
zic2	dc.l	0
zic3	dc.b	0
where	dc.b	0	
where1	dc.b	0	
where2	dc.b	40	
where12	dc.b	0	
buffer	ds.l	4*3*48
	
