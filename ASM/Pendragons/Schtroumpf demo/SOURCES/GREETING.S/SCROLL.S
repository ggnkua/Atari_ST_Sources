
*	dis megalighty source is dedicated to all those who try
*	to improve demos on ST, i mean to all the people making
*	not only technical demos but dreaming demos....Terence.


*CONTACT : LAURENT DERVAL (THE SERGEANT)
*          68 RUE KELLERMANN
*          28200 CHATEAUDUN
*          FRANCE
          
*          OR

*          FOR CODING...
          
*          ERIC DEZERT (TERENCE / PENDRAGONS)
*          1 RUE LE MOYNE DE BIENVILLE
*          45100 ORLEANS
*          FRANCE



nbli:	equ	8		* hauteur du scrolling

hauteur1:	equ	37		* hauteur du scrolling
hauteur2:	equ	88		* hauteur du scrolling
hauteur3:	equ	131		* hauteur du scrolling

pos1:	equ	hauteur2-1
pos2:	equ	hauteur3-1

posimg:	equ	0		* position de l'image

vsync:	macro
	move.l	$466.w,d0
.\@l1:
	cmp.l	$466.w,d0
	beq.s	.\@l1
	endm

	move.w	sr,d0
	btst	#13,d0
	bne.s	yeah

	clr.	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

yeah:
	LEA	DBSS,A0
	lea	FBSS,a1
.loop1:
	move.b	#0,(a0)+
	cmp.l	a1,a0
	bne.s	.loop1

	move.l	$44e,oldecr

	move.l	#ecrans,d0
	move.b	#0,d0
	add.l	#256,d0
	move.l	d0,log

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,savcol

	move.b	log+1,$ffff8201.w
	move.b	log+2,$ffff8203.w


	move.l	log,a0
	moveq	#0,d0
	move.w	#8000-1,d1
loopcls:
	move.l	d0,(a0)+
	dbf	d1,loopcls

	vsync
	move.b	#0,$ffff8260.w
	vsync

	movem.l	image+2,d0-d7
	movem.l	d0-d7,$ffff8240.w

	lea	image+34,a0
	move.l	log,a1
	lea	posimg*160(a1),a1
	move.w	#7999,d0
looping:
	move.l	(a0)+,(a1)+
	dbf	d0,looping


	bsr	calctexte


	bsr	initmfp

	moveq	#1,d0
	jsr	zik+4

	move.l	#hbl,$68.w
	move.l	#vbl,$70.w

main:
	vsync
	cmp.b	#$39,$fffffc02.w
	bne.s	main


	jsr	zik+8

	bsr	finmfp


error_clavier:
	btst	#5,$fffffc00.w
	beq.s	.noerror

	tst.b	$fffffc02.w
	bra.s	error_clavier
.noerror:

	btst	#0,$fffffc00.w
	beq.s	.vidbuff

	tst.b	$fffffc02.w
	bra.s	error_clavier
.vidbuff:
	movem.l	savcol,d0-d7
	movem.l	d0-d7,$ffff8240.w

	vsync
	move.b	oldecr+1,$ffff8201.w
	move.b	oldecr+2,$ffff8203.w
	vsync


	clr.w	-(sp)
	trap	#1

hbl:	rte

scroll1:
	move.l	log,a0
	lea	hauteur1*160(a0),a0
	move.w	#nbli-1,d7

.loop1:
	moveq	#0,d0
	roxl	d0

st	set	160-8
	rept	20
	roxl	st(a0)
st	set	st-8
	endr

	moveq	#0,d0
	roxl	d0

st	set	160-8
	rept	20
	roxl	st+2(a0)
st	set	st-8
	endr

	moveq	#0,d0
	roxl	d0

st	set	160-8
	rept	20
	roxl	st+4(a0)
st	set	st-8
	endr

	moveq	#0,d0
	roxl	d0

st	set	160-8
	rept	20
	roxl	st+6(a0)
st	set	st-8
	endr

	lea	160(a0),a0
	dbf	d7,.loop1

	lea	-8*160(a0),a0

	move.w	posx1,d6
	subq.w	#1,d6
	bge.s	.ok2

	move.l	pttex1,a1
	move.w	(a1)+,d0
	cmp.l	ftexte1,a1
	blt.s	.ok1
	lea	texte1,a1
.ok1:
	move.w	d0,offl1
	move.l	a1,pttex1
	moveq	#7,d6

.ok2:	
	move.w	d6,posx1

	move.w	offl1,d0
	lea	font1,a2
	adda.w	d0,a2

	moveq	#0,d5
	bset	d6,d5

	

st	set	0
	rept	nbli
	move.b	(a2)+,d0
	and.b	d5,d0
	lsr.b	d6,d0
	or.b	d0,st+152(a0)
	move.b	(a2)+,d0
	and.b	d5,d0
	lsr.b	d6,d0
	or.b	d0,st+152+2(a0)
	move.b	(a2)+,d0
	and.b	d5,d0
	lsr.b	d6,d0
	or.b	d0,st+152+4(a0)
	move.b	(a2)+,d0
	and.b	d5,d0
	lsr.b	d6,d0
	or.b	d0,st+152+6(a0)
st	set	st+160
	endr
	
	rts

scroll2:
	move.l	log,a0
	lea	hauteur2*160(a0),a0
	move.w	#nbli-1,d7

.loop1:
	moveq	#0,d0
	roxl	d0

st	set	160-8
	rept	20
	roxl	st(a0)
st	set	st-8
	endr

	moveq	#0,d0
	roxl	d0

st	set	160-8
	rept	20
	roxl	st+2(a0)
st	set	st-8
	endr

	moveq	#0,d0
	roxl	d0

st	set	160-8
	rept	20
	roxl	st+4(a0)
st	set	st-8
	endr

	moveq	#0,d0
	roxl	d0

st	set	160-8
	rept	20
	roxl	st+6(a0)
st	set	st-8
	endr

	lea	160(a0),a0
	dbf	d7,.loop1

	lea	-8*160(a0),a0

	move.w	posx2,d6
	subq.w	#1,d6
	bge.s	.ok2

	move.l	pttex2,a1
	move.w	(a1)+,d0
	cmp.l	ftexte2,a1
	blt.s	.ok1
	lea	texte2,a1
.ok1:
	move.w	d0,offl2
	move.l	a1,pttex2
	moveq	#7,d6

.ok2:	
	move.w	d6,posx2

	move.w	offl2,d0
	lea	font2,a2
	adda.w	d0,a2

	moveq	#0,d5
	bset	d6,d5

	

st	set	0
	rept	nbli
	move.b	(a2)+,d0
	and.b	d5,d0
	lsr.b	d6,d0
	or.b	d0,st+152(a0)
	move.b	(a2)+,d0
	and.b	d5,d0
	lsr.b	d6,d0
	or.b	d0,st+152+2(a0)
	move.b	(a2)+,d0
	and.b	d5,d0
	lsr.b	d6,d0
	or.b	d0,st+152+4(a0)
	move.b	(a2)+,d0
	and.b	d5,d0
	lsr.b	d6,d0
	or.b	d0,st+152+6(a0)
st	set	st+160
	endr
	
	rts

scroll3:
	move.l	log,a0
	lea	hauteur3*160(a0),a0
	move.w	#nbli-1,d7

.loop1:
	moveq	#0,d0
	roxl	d0

st	set	160-8
	rept	20
	roxl	st(a0)
st	set	st-8
	endr

	moveq	#0,d0
	roxl	d0

st	set	160-8
	rept	20
	roxl	st+2(a0)
st	set	st-8
	endr

	moveq	#0,d0
	roxl	d0

st	set	160-8
	rept	20
	roxl	st+4(a0)
st	set	st-8
	endr

	moveq	#0,d0
	roxl	d0

st	set	160-8
	rept	20
	roxl	st+6(a0)
st	set	st-8
	endr

	lea	160(a0),a0
	dbf	d7,.loop1

	lea	-8*160(a0),a0

	move.w	posx3,d6
	subq.w	#1,d6
	bge.s	.ok2

	move.l	pttex3,a1
	move.w	(a1)+,d0
	cmp.l	ftexte3,a1
	blt.s	.ok1
	lea	texte3,a1
.ok1:
	move.w	d0,offl3
	move.l	a1,pttex3
	moveq	#7,d6

.ok2:	
	move.w	d6,posx3

	move.w	offl3,d0
	lea	font3,a2
	adda.w	d0,a2

	moveq	#0,d5
	bset	d6,d5

	

st	set	0
	rept	nbli
	move.b	(a2)+,d0
	and.b	d5,d0
	lsr.b	d6,d0
	or.b	d0,st+152(a0)
	move.b	(a2)+,d0
	and.b	d5,d0
	lsr.b	d6,d0
	or.b	d0,st+152+2(a0)
	move.b	(a2)+,d0
	and.b	d5,d0
	lsr.b	d6,d0
	or.b	d0,st+152+4(a0)
	move.b	(a2)+,d0
	and.b	d5,d0
	lsr.b	d6,d0
	or.b	d0,st+152+6(a0)
st	set	st+160
	endr
	
	rts

calctexte:
	lea	tex_init1,a0
	lea	texte1,a1
	lea	ftexte1,a5
	bsr	titi
	lea	tex_init2,a0
	lea	texte2,a1
	lea	ftexte2,a5
	bsr	titi
	lea	tex_init3,a0
	lea	texte3,a1
	lea	ftexte3,a5
	bsr	titi
	rts
titi:
loopt:
	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	#-1,d0
	beq	fint

	cmp.b	#32,d0
	bne.s	excla
	move.w	#32*26,(a1)+
	bra	contt
excla:
	cmp.b	#33,d0
	bne.s	inter
	move.w	#32*27,(a1)+
	bra	contt
inter:
	cmp.b	#63,d0
	bne.s	point
	move.w	#32*28,(a1)+
	bra	contt
point:
	cmp.b	#46,d0
	bne.s	vir
	move.w	#32*29,(a1)+
	bra	contt
vir:
	cmp.b	#44,d0
	bne.s	pvir
	move.w	#32*30,(a1)+
	bra	contt
pvir:
	cmp.b	#59,d0
	bne.s	pg
	move.w	#32*31,(a1)+
	bra	contt
pg:
	cmp.b	#40,d0
	bne.s	pd
	move.w	#32*32,(a1)+
	bra	contt
pd:
	cmp.b	#41,d0
	bne.s	chiffre
	move.w	#32*33,(a1)+
	bra	contt

chiffre:
	cmp.b	#48,d0
	blt.s	lettre
	cmp.b	#57,d0
	bgt.s	lettre
	sub.b	#14,d0
	mulu	#32,d0
	move.w	d0,(a1)+
	bra	contt
	
	
lettre:
	cmp.b	#65,d0
	blt.s	contt
	cmp.b	#90,d0
	bgt.s	contt
	sub.w	#65,d0
	lsl.w	#5,d0
	move.w	d0,(a1)+

contt:
	bra	loopt

fint:
	move.l	a1,(a5)+
	rts



initmfp:
	move.w	sr,-(a7)
	move.w	#$2700,sr
	
	lea	$fffffa01.w,a0
	lea	oldmfp,a1
	move.w	#16,d0
	
savemfp:
	move.b	(a0),(a1)+
	addq.l	#2,a0

	dbra	d0,savemfp
	
	movem.l	$100.w,d0-d7		; On sauvegarde les vecteur MFP
	movem.l	d0-d7,oldvec
	movem.l	$120.w,d0-d7
	movem.l	d0-d7,oldvec+$20
	movem.l	$58.w,d0-d7		; Et 68000...
	movem.l	d0-d7,oldvec+$40

	bclr	#3,$fffffa17.w
	
	clr.b	$fffffa19.w 	    Arret Timer A (Reg control)
	clr.b	$fffffa1b.w 	    Arret Timer B (Reg control)

	move.b	#%00000001,$fffffa07.w  On lance le timer B seul
	move.b	#%00000001,$fffffa13.w  Pareil avec le masque
	
	move.b	#%00000000,$fffffa09.w  Pas de Timer C et D
	move.b	#%00000000,$fffffa15.w
	
	
	
	rte
	
finmfp:
	move.w	sr,-(a7)
	move.w	#$2700,sr

	lea	oldmfp,a0
	lea	$fffffa01.w,a1
	move.w	#16,d0
	
restmfp:

	move.b	(a0)+,(a1)
	addq.l	#2,a1

	dbra	d0,restmfp
	
	movem.l	oldvec,d0-d7
	movem.l	d0-d7,$100.w
	movem.l	oldvec+$20,d0-d7
	movem.l	d0-d7,$120.w
	movem.l	oldvec+$40,d0-d7
	movem.l	d0-d7,$58.w

	rte
	

	
vbl:
	move.l	#coul1,$120.w		Vecteur Timer B
	clr.b	$fffffa1b.w	On stoppe le Timer B
	move.b	#36+9,$fffffa21.w	|
	move.b	#8,$fffffa1b.w	| Frequence de 369 Hz
	or.b	#%000000001,$fffffa07.w

	movem.l	d0-a6,-(sp)
	movem.l	image+2,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bsr	scroll2
	bsr	scroll2
	bsr	scroll2
	bsr	scroll2
	bsr	scroll3
	bsr	scroll3
	bsr	scroll3
	jsr	zik
	bsr	scroll1
	bsr	scroll1
*	bsr	scroll1
	movem.l	(sp)+,d0-a6
	addq.l	#1,$466.w
	rte

clip:
	move.l	log,d0
	move.l	phy,log
	move.l	d0,phy
	move.b	log+1,$ffff8201.w
	move.b	log+2,$ffff8203.w
	rts
	
raster1:
	movem.l	a0-a1,-(sp)
	lea	mega2,a0
	lea	$ffff8240.w,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr
	movem.l	(sp)+,a0-a1
	move.l	#coul2,$120.w		Vecteur Timer B
	clr.b	$fffffa1b.w	On stoppe le Timer B
	move.b	#88-40,$fffffa21.w	|
	move.b	#8,$fffffa1b.w	| Frequence de 369 Hz
	or.b	#%000000001,$fffffa07.w
	rte

coul1:
	movem.l	a0-a1,-(sp)
	lea	$ffff8240.w,a1
	move.l	ptcoul1,a0
	rept	40
	move.w	(a0)+,(a1)
	endr
	move.w	#0,(a1)
	move.l	ptcoul1,a0
	addq.w	#2,a0
	cmp.l	#fcouleur1,a0
	blt.s	.ok1
	lea	couleur1,a0
.ok1:
	move.l	a0,ptcoul1
	movem.l	(sp)+,a0-a1
	move.l	#raster1,$120.w		Vecteur Timer B
	clr.b	$fffffa1b.w	On stoppe le Timer B
	move.b	#2,$fffffa21.w	|
	move.b	#8,$fffffa1b.w	| Frequence de 369 Hz
	or.b	#%000000001,$fffffa07.w
	rte	

raster2:
	movem.l	a0-a1,-(sp)
	lea	sgt3,a0
	lea	$ffff8240.w,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr
	movem.l	(sp)+,a0-a1
	move.l	#coul3,$120.w		Vecteur Timer B
	clr.b	$fffffa1b.w	On stoppe le Timer B
	move.b	#131-88-2,$fffffa21.w	|
	move.b	#8,$fffffa1b.w	| Frequence de 369 Hz
	or.b	#%000000001,$fffffa07.w
	rte

raster3:
	movem.l	a0-a1,-(sp)
	lea	greets,a0
	lea	$ffff8240.w,a1
	rept	8
	move.l	(a0)+,(a1)+
	endr
	movem.l	(sp)+,a0-a1
	clr.b	$fffffa1b.w	On stoppe le Timer B
	rte

coul2:
	movem.l	a0-a1,-(sp)
	lea	$ffff8240.w,a1
	move.l	ptcoul2,a0
	rept	40
	move.w	(a0)+,(a1)
	endr
	move.w	#0,(a1)
	move.l	ptcoul2,a0
	addq.w	#2,a0
	cmp.l	#fcouleur1,a0
	blt.s	.ok1
	lea	couleur1,a0
.ok1:
	move.l	a0,ptcoul2

	movem.l	(sp)+,a0-a1
	move.l	#raster2,$120.w		Vecteur Timer B
	clr.b	$fffffa1b.w	On stoppe le Timer B
	move.b	#1,$fffffa21.w	|
	move.b	#8,$fffffa1b.w	| Frequence de 369 Hz
	or.b	#%000000001,$fffffa07.w
	rte	

coul3:
	movem.l	a0-a1,-(sp)
	lea	$ffff8240.w,a1
	move.l	ptcoul3,a0
	rept	40
	move.w	(a0)+,(a1)
	endr
	move.w	#0,(a1)
	move.l	ptcoul3,a0
	addq.w	#2,a0
	cmp.l	#fcouleur1,a0
	blt.s	.ok1
	lea	couleur1,a0
.ok1:
	move.l	a0,ptcoul3
	movem.l	(sp)+,a0-a1
	move.l	#raster3,$120.w		Vecteur Timer B
	clr.b	$fffffa1b.w	On stoppe le Timer B
	move.b	#1,$fffffa21.w	|
	move.b	#8,$fffffa1b.w	| Frequence de 369 Hz
	or.b	#%000000001,$fffffa07.w
	rte	

	section	data

mega2:
	dc.w	0,$013,$024,$035,$046,$156,$266,$376,$477,$112
	dc.w	$223,$334,$445,$556,$667,$766
sgt3:
	dc.w	$000,$210,$320,$430,$540,$650,$651,$211,$221,$231,$241,$252,$262,$273,$274,$777

greets:	dc.w	$000,$677,$567,$456,$345,$234,$123,$012,$767,$756,$645,$534,$423,$312,$201,$777

pal3:	incbin	"a:\greeting.s\pal.pal"
	even

log:	dc.l	$f8000+2
phy:	dc.l	$f8000+2

tex_init1:
	dc.b	"                                     "
	dc.b	"TRALALA TO EVERYBODY ! ONCE AGAIN I AM"
	dc.b	" TYPING A STUPID TEXT IN THIS LAME DEMO "
	dc.b	". FIRST OF ALL DON T FORGET THAT ALL THE"
	DC.B	" SOURCES OF THIS DEMOS ARE ON THIS DISK."
	DC.B	" THE MISSING ONES (SPRITES SCREEN) CAN BE"
	DC.B	" ASKED TO TERENCE FROM PENDRAGONS (MY ADRESS"
	DC.B	" IS IN ONE OF THE SOURCE) . I'M NOW IN SERGEANT"
	DC.B	" HOME WATCHING MONICA SELLES WHO JUST WON THE FRENCH"
	DC.B	" TENNIS OPEN. HAVE YOU EVER WALKED ON SOMEBODY S FOOT ?"
	DC.B	" ( I AM TYPING WHAT I HEAR ON THE TV) . SERGEANT IS COMPLETELY MAD"
	DC.B	" AS A MARRIAGE IS TAKING PLACE ASIDE HIS HOME. SO WE ARE WATCHING PRETTY"
	DC.B	" GIRLS WITH SHORT DRESS WHO ARE PASSING BY. THE SERGEANT CAN T HELP SHOOTING"
	DC.B	" BOUDIN ( THAT MEANS UGLY GIRL) TO THOSE WHO ARE NOT HIS KINDA GIRL."
	DC.B	" HE IS NOW TRYING TO MAKE ME TYPE A ARTICLE FROM AN ENGLISH MAGAZINE TO "
	DC.B	" GET A GOOD ENGLISH TEXT. BEST GAMES ON ST ARE SIERRA S GAMES. FOR EVER ..."
	DC.B	"       I WILL PUT SOME GREETINGS TO PEOPLE I REALLY ENJOY BEING WITH ..."
	DC.B	" SO GREETINGS TO LAURENT DERVAL, JEAN CHARLES MEYRIGNAC, RV AND BENOIT DURAND"
	DC.B	" VINCENT PENNE, PATRICK (L'ABEILLE), PATRICE ROSSY TRUC BIDULE, ERIC DEZERT (HEY THAT S ME !)"
	DC.B	" PATRICK RAYNAUD, BENOIT PASQUERAU, JEAN LUC JOURDAIN, POPOL 28, JUIMEAU LE PINPEC, VLADIMIR (HEY"
	DC.B	" WHAT'S YOUR NAME !) , FREDERIC AND CYRILLE PAYET, JEROME BERGANZO, FABRICE ODERO, JEAN LOUIS, JEAN MARIE,"
	DC.B	" FUCK GOES TO ALEXANDRE AND MANU (LAMERS D ORLEANS) NICKLAS THISELL ."
	DC.B	" REGRETS TO FRANCK HERBERT, SERGE GAINSBOURG, MARYLIN MONROE, PAULINE LAFFONT, JOHN LENNON, OCEAN FRANCE (SCOOP MAN !)"
	DC.B	" . SO LONG BOY AND A LAST WORD TO THE APP : TAKE ALL THIS NAMES , ALL THOSE GUYS ARE CRACKERS OR SWAPPERS !!!"
	DC.B	" (OR LAMER FOR JCM (IDENTITY CARD NUMBER : 179451 , HUOPS IT IS MINE , I MEANT 179365) , HALLOHA TO ALL FUNNY GIRLS ON RTEL"
	DC.B	" CERISE CHIPYNOU EDDIE SANDRA VAMPIRELA SUCEMOILA PECHEMELBA AND LAST BUT NOT LEAST AT ALL LA THEATREUSE !!!"
	DC.B	"                                                                          "
	DC.B	"                                                                          "
	DC.B	" I FORGOT BRIGITTE LAHAIE !!!                                             "
	DC.B	"                                                                          "
	DC.B	"                                                                          "
	DC.B	" KISS TO THE MARRID GIRL ASIDE HERE."
	DC.B	"                   WE WON T WRAP ANYMORE ..............."
	DC.B	"                                                                          "
	DC.B	"                                                                          "
	DC.B	" QUAND JE VAIS SECOUER LA GROSSE JOCELYNE JE SUIS SUR DE TOUT LUI METTRE DEDANS     "
	DC.B	" JE LUI METS DANS SON PTIT VOLCAN OH LA LA OH! QU EST CE QU ELLE PREND    "
	DC.B	" MOI JE VAIS LUI EN METTRE TELLMENT QU ELLE EN AURA PLEIN LES DENTS !!!!!!!"
	DC.B	"              ELMER FOOD BEAT 1990"
	DC.B	"                                                                          "
	DC.B	"                                                                          "
	DC.B	" SOON RELEASE THE SCHTROUMPFETTE DEMO !!!!"
	DC.B	"                                                                          "
	DC.B	"                                                                          "
	dc.b	-1
	DC.B	"                                                                          "
	dc.b	-1

tex_init2:
        dc.b    "   I AM THE BEST OF THE GRAPH , I AM MEGAMERDE "
        dc.b    "   FROM THE PENDRACONS , I AM THE GOD OF THE"
        dc.b    "  MOUSE , I AM THE KING OF NEOMASTER .  "
        dc.b    "         CREDITS FOR THIS MARVELLOUS INTRO ;  CODE BY  TA RACE"
        dc.b    "  OF THE PENDRACONS ,   GRAPHIXES AND PIXELS BY ;     "
        dc.b    "  MEGAMERDE OF THE PENDRACONS AND THE CAPORAL OF THE"
        dc.b    "  PUSHWANCKERS , MUSIC BY ;  NOBODY ... . . .. FUCKING  MUSIC !!!"
        dc.b    "  MY FAVOURITE MUSIC ARE ; METALLICA .. MEGADETH .." 
        dc.b    "  SEPULTURA .. ANTHRAX .. HADES .. VOIVOD .. ACCUSER"
        dc.b    "  .. MEKONG DELTA .. ANNIHILATOR AND ALL BANDS WHO MAKE"
        dc.b    "  ME CRAZY ..  . . Y E A H H H H  ! ! ! ! ! !            "
        dc.b    "  FUCK YOU LE SERGENT !!! YES SIR !!!!  " 
        dc.b    "  . .. .           NODODY IS PERFECT ALSO GREETS TO "
        dc.b    "  THE PENDRAGONS ( ALL MEMBERS EXCEPT MECAGROID ) ..."
        dc.b    "  THE OVERLANDERS ..."
        dc.b    "  FIREHAWKS ( ESPECIALLY ST MICK ) ..."
        dc.b    "  ST CNX ... MCODER ( GOOD GRAPHIST )" 
        dc.b    "  ... LEGACY ( VICKERS AND FURY ) ... POLTERGEITCH"
        dc.b    "  ... DIZZY FROM TOOLS8 ... UNDEAD ... THE MUSIC PLAYER"
        dc.b    "  ( PLAYER.ACC !! ) ... TBC ( ONLY LX ) ... NAOS ..."
        dc.b    "  AND ALL OTHER FRIENDS . "
        dc.b    "   THERE IS ALSO THE GROWING PRACTICE BY PERSONNEL" 
        dc.b    "   MANAGERS OF GIVING LIE DETECTOR TESTS, AND THE"
        dc.b    "   INTENSIVE PROBING OF THE MIND BY PSYCHOLOGICAL"
        dc.b    "   TESTING . ( I NEVER THINK OF THE FUTURE."
        dc.b    "   IT COMES SOON ENOUGH . EINSTEIN (1930) )."
        dc.b    "     . .. . .  WHAT IS MATTER ? NEVER MIND .  "
        dc.b    "     . .. . .  WHAT IS MIND ? NO MATTER . HA HA HA HA HA HA HA !!!! "
        dc.b    "   FOR A YOUNG MAN COULD FLIT AWAY ONE FINE NIGHT" 
        dc.b    "   AND NEVER BE HEARD OF AGAIN , WHILE IF YOU WERE"
        dc.b    "    ENGAGED HE WOULD THINK TWICE ABOUT IT . "
        dc.b    "    FUCK SO TO THE SELLER DEMO THE GAMES CRACKER SELLERS "
        dc.b    "  FUCK TO HOUSE MUSIC FUCK TO REGGAE MUSIC FUCK TO DEPEDE MOCHE" 
        dc.b    "   SHIT SHIT SHIT MUSIC , I KILL THE NRJ TOP 50 AND AMSTRAD USER"
        dc.b    " I SUCK MY BRAIN AND MY PEN-MOUSE AND I LOVE MY NEOMASTER YEAHHH!!"
        dc.b    "    ALLRIGHT  MAN , THE DELIRIUM IS TERMINED , IT IS TIME TO GO ."
        dc.b    "    SEE YOU SEE IN THE OTHER PRODUCTION PENWHACKERS"
        dc.b    "                  FUCK YOU UPSIDE                     "
        dc.b    "                  FUCK YOU DOWN SIDE                  " 
        dc.b    "                   I SAID  FUCK YOU TERENCE !!!!!!!               "
        dc.b    "                   I SAID  FUCK YOU LE SERGENT  !!!!!!!!          "
        dc.b    "                         YES  SIR  !!!!                           "
        dc.b    "                       FUCK MY BRAIN   !!!!!!!!!                 "
        dc.b    "                       FUCK MY HAND    !!!!!!!!!!                "
        DC.B    "                      K C U F   !!!!   K C U F  !!!!              "
        DC.B    "      I AM THE BEST     GRAPHIX     ,    THE BEST FLYFUCKER        "
        DC.B    "          YYYYYYEEEEEEEEEAAAAAAAHHHHHHHHHHH!!!!!!!!!!!!!!!!!      "
        DC.B    "                        OK                                        "
        DC.B    "                                   OK BOSS                         "
        DC.B    "                      I GIVE THE HAND                            " 
        DC.B    "                           HE  HE  HE   STILL  HERE                "
        DC.B    "                            GAG !!                              "              
        DC.B    "                         SURPRISE   !!!!!                         "
        DC.B    "                                                                              "
        dc.b    "    . MEGADETH  JUNE 1991 . . ... . . ...",-1
	DC.B	"                                                                          "
	dc.b	-1
	
tex_init3:
        dc.b    "                        TA GUEULE !!  MEGAMERDE ... "
        dc.b    "    . .. . . .  . .     WELCOME EVERYBODY , IT IS THE SERGEANT ON THE"
        dc.b    "  KEYBOARD OF THE ATARI ST . YES , SIR !!!!!        "
        dc.b    "  CREDITS FOR THIS LITTLE INTRO ;  CODE BY  TERENCE"
        dc.b    "  OF THE PENDRAGONS , GRAPHIXES AND PIXELS BY ;     "
        dc.b    "  MEGADETH OF THE PENDRAGONS AND THE SERGEANT OF THE"
        dc.b    "  BUSHWACKERS , MUSIC BY ;   . ..  OFFBEAT . . .. .   GOOD VIBRATIONS !!! !! ! !"
        dc.b    "  THIS LAME SCREEN WAS MADE DURING THE SCROUMPFE OR " 
        dc.b    "  SCROUPFHE OR SHTROUMPF DEMO ORGANISED BY TERENCE . "
        dc.b    "  ( COOL GUY !! ) .                 MEGAMERDE TA GUEULE !!!      YES SIR !! "
        dc.b    "  IT IS THE GREETINGS SCREEN ,ALSO I AM TO SAY MY"
        dc.b    "  GREETS , BEST REGARDS , HAPPY NEW YEAR , HELLO TO" 
        dc.b    "  THE PENDRAGONS ( ALL MEMBERS EXCEPT MECAGROID ) ..."
        dc.b    "  THE OVERLANDERS ( FUFU , BEEBEE , ZIZI ,"
        dc.b    "  ADSOSO , DOCDOC , STANSTAN , BOOTLE JUICE AND ALL "
        dc.b    "  OTHERS ) ... ST CNNX ( COOL GUYS ) ... MCOTER ( GOD !!)" 
        dc.b    "  ... LEGACY ( VICK AND FURY ) ... POLTERGETCH ... COBRA"
        dc.b    "  ... NAOS ... DNT ... HYSTERIA ... EQUINOX ( A LA TIENNE ,"
        dc.b    "  ETIENNE !! ) ... VGT ... GENESIS ... PHENIX ( MR 40 ) "
        dc.b    "  ... TBC ( SHARPMAN AND DOCTOR PROCKTOR ) ... TSB"
        dc.b    "  ... MAD VISON ... REPLICANTS ( ST WAIK , CAMEO , MAX ) "
        dc.b    "  ... MCS ... SERVAL ... DEFCON 4 ... AND ALL PEOPLE  "
        dc.b    "  WHO HAVE PARTICIPED TO THE TRANSBEAUCE CODING PARTY 2 ."
        dc.b    "  AND NOW , LADIES AND JANTES LE MANS MY GREETS TO  ..              TA GUEULE MEGAMERDE  "
        dc.b    "         MY FRIENDS OUT THE FRANCE ; I SAID HELLO TO ;   "
        dc.b    "  THE MILITARY GERMAN TEAM ... ACF ( HI JACK !! ) ..."
        dc.b    "  NPG ( ALL MEMBERS ) ... NAPALM SOLDIERS ... "
        dc.b    "  POMPEY PIRATES ...   YES  SIR   !!!!    FUCK   YOU   MEGA MERDE      . .. .. . RIRI , FIFI , LOULOU FROM DISNEY CREW" 
        dc.b    "  ... AND ALL OTHERS FRIENDS .   "
        dc.b    "  THE WAR SENSATION THAT THROWS YOU DEEP INTO ENEMY"
        dc.b    "  TERRITORY WITH LITTLE MORE THAN A LOW POWERED, SINGLE SHOT REPEATER"
        dc.b    "  FOR PROTECTION. WITH SUPERIOR MARKSMANSHIP AND LIGHTNING "
        dc.b    "  REACTIONS YOU CAN INCREASE THE ODDS IN YOUR FAVOUR "
        dc.b    "	KILL KILL KILL THE ENEMY LOAD UP AND FIRE  YEAHHHH  !!!"
        dc.b    "  YES IT IS TIME TO QUIT THIS LAME SCREEN  , PLEASE , PLEASE !!!! , P L E A S E ,   " 
        dc.b    "  PRESS THE LONG BAR ( SPACE , NEW FRONTIER , STAR TREK ,"
        dc.b    "  CAPTAIN KIRK AND MISTER SPOOCK ... .. . .) . "
        dc.b    "  BYE BYE  LE SERGENT . BUSHWACKERS . JUNE COSMOS 1991 .."
	dc.b	-1
	DC.B	"                                                                          "
	dc.b	-1

font1:	incbin	"a:\greeting.s\font1.bin"
	even
font2:	incbin	"a:\greeting.s\font2.bin"
	even
font3:	incbin	"a:\greeting.s\font3.bin"
	even

pttex1:	dc.l	texte1
posx1:	dc.w	7
offl1:	dc.w	32*26
pttex2:	dc.l	texte2
posx2:	dc.w	7
offl2:	dc.w	32*26
pttex3:	dc.l	texte3
posx3:	dc.w	7
offl3:	dc.w	32*26

image:
	incbin	"a:\greeting.s\fin*.pi1"		* nom du fichier .pi1
	even

zik:
	incbin	"wicked.dat"
	even

ptcoul1:	dc.l	couleur1
ptcoul2:	dc.l	couleur1+8*3
ptcoul3:	dc.l	couleur1+16*3

couleur1:
        dc.w    $003,$104,$205,$306,$407,$507,$607,$707,$717,$727,$737
        dc.w    $747,$757,$767,$777,$776,$775,$774,$773,$772,$771,$770
        dc.w    $760,$750,$740,$730,$720,$710,$700,$601,$502,$403,$304
        dc.w    $205,$116,$007,$006,$005,$004,$003
fcouleur1:
        dc.w    $003,$104,$205,$306,$407,$507,$607,$707,$717,$727,$737
        dc.w    $747,$757,$767,$777,$776,$775,$774,$773,$772,$771,$770
        dc.w    $760,$750,$740,$730,$720,$710,$700,$601,$502,$403,$304
        dc.w    $205,$116,$007,$006,$005,$004,$003

	section	bss

DBSS:
oldecr:	ds.l	1
savcol:	ds.w	16

oldmfp	ds.b	24
oldvec	ds.l	24

texte1:	ds.b	7000
texte2:	ds.b	7000
texte3:	ds.b	7000

ftexte1:	ds.l	1
ftexte2:	ds.l	1
ftexte3:	ds.l	1

ecrans:	ds.b	256
	ds.b	64000
FBSS:
	end
