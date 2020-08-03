;                               THE STARBOOT 3
;
;
;                         (c)NulloS\\DNT le 13/10/91
;
;
;
;Cette version affiche 2700 ‚toiles en parallaxe 6 plans, le tout en 1 VBL
;(c'est la limite de la routine).
;
;
NB_STARS	equ	150*6
Y_OFF1	equ	19
Y_OFF2	equ	50
TEST	EQU	1


	IFEQ	TEST
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	move.l	d0,2(sp)
	bsr	DEBUT
	trap	#1
	clr.w	(sp)
	trap	#1
	ENDC

DEBUT	equ	*

	IFEQ	TEST
	lea	buffer(pc),a5
	ELSEIF
	move.l	$432.w,a5
	ENDC
	tst.b	$44c.w
	bne	Exit
	lea	x_buffer(a5),a6
	clr.w	(a5)+		;compt_ecran=0
	move.l	a6,a4		;
	moveq	#0,d0		;petit pr‚calcul (on a la
init0	move.w	d0,d2		;place alors on peut)
	not.w	d2		;toutes les coordonn‚es
	andi.w	#%1111,d2		;en x sont converties
	moveq	#0,d3		;par avance en offset ‚cran
	bset	d2,d3		;et en pixel.
	move.w	d3,(a6)+		;
	move.w	d0,d2		;
	lsr.w	#1,d2		;
	andi.w	#%1111111111111000,d2	;
	move.w	d2,(a6)+		;
	move.w	d0,d2		;
	addq.w	#1,d0		;
	cmpi.w	#320,d0		;
	bne.s	init0		;

	move.l	a6,(a5)+		;starbase
	move.w	#NB_STARS-1,d6	;
init1	bsr.s	random		;randomize:r‚sultat 24 bits
	divu	#320,d0		;modulo 320
	swap	d0		;
	lsl.w	#2,d0		;*4 pour exploiter le pr‚calcul
	move.w	d0,(a6)+		;
	bsr.s	random		;idem sur y
	divu	#2*(200-Y_OFF2),d0	;2* car 2^24/200>2^16
	swap	d0		;
	lsr.w	#1,d0		;compense le 2*
	mulu.w	#160,d0		;offset ‚cran
	move.w	d0,(a6)+		;stocke
	dbf	d6,init1		;
	bra.s	suite		;

random	move.w	#17,-(sp)
	trap	#14
	addq.l	#2,sp
break	rts

deplace
	move.w	(a1)+,(a6)+	;transfert de routine
	cmp.l	a3,a1		;de a1 … a3 vers a6
	blt.s	deplace		;
	rts			;


suite	move.l	a6,(a5)+		;adr_cls
	move.w	#NB_STARS-1,d0	;pour chaque tripl‚ d'‚toiles
init3	move.l	#$225a3280,(a6)+	;g‚nŠre le code d'effacement
	move.l	#$33400000+Y_OFF1*160,(a6)+ ;
	move.l	#$33400000+Y_OFF2*160,(a6)+ ;
	dbf	d0,init3		;
	lea	retour(pc),a1	;puis la routine "retour"
	lea	part2(pc),a3	;juste derriere
	bsr.s	deplace		;
	moveq	#NB_STARS/6-1,d0	;et pour chaque tripl‚ d'‚toile
init35	lea	part2(pc),a1	;d'un plan, g‚nŠre son affichage
	lea	part3(pc),a3	;
	bsr.s	deplace		;hop!
	subq.b	#1,d0		;un de plus
	bne.s	init35		;encore ?
	move.l	a3,a1		;
	lea	endroutine(pc),a3	;puis routine finale
	bsr.s	deplace		;

	move.l	$44e.w,-(sp)	;
	adda.w	#256,a6		;vient ensuite l'‚cran
	move.l	a6,d6		;
	clr.b	d6		;
	movea.l	d6,a6		;
	bsr.s	aff_ecran		;
	move.l	a6,(a5)+		;ecran1
	move.l	(sp),(a5)+		;ecran2

	lea	32000(a6),a6	;
	move.l	a6,(a5)+		;savebase1		
	lea	NB_STARS*4(a6),a0	;place pour sauvegarde du fond
	move.l	a0,(a5)+		;savebase2
	move.w	#2*NB_STARS-1,d0	;idem
init4	move.l	d6,(a6)+		;rien … effacer dans un premier
	dbf	d0,init4		;temps

	movea.l	(sp),a6		;init l'affichage
	bsr.s	aff_ecran		;

	movem.l	c_for_stars(pc),d0-4	;couleurs
	move.l	d4,d5		;copie les derniŠres
	move.l	d4,d6		;couleurs qui sont
	move.l	d4,d7		;les mˆmes
	movem.l	d0-7,$ffff8240.w	;
;20+6+2+2+2+6=36 octets (au lieu de 44 si palette entiere stockee)
	

	move.l	$fffffa06.w,-(sp)	;IT du MFP
	clr.l	$fffffa06.w	;
	move.l	$70.w,-(sp)	;
	lea	VBL(pc),a0		;
	move.l	a0,$70.w		;
wait	tst.b	$fffffc02.w	;
	ble.s	wait		;
	move.l	(sp)+,$70.w	;
	move.l	(sp)+,$fffffa06.w	;
	movea.l	(sp)+,a6		;
aff_ecran
	clr.w	-(sp)		;
	move.l	a6,-(sp)		;Positionne l'‚cran et
	move.l	a6,-(sp)		;redemande la basse r‚solution
	move.w	#5,-(sp)		;(-> cls)
	trap	#14		;
	lea	12(sp),sp		;
Exit	pea	message(pc)	;
	move.w	#9,-(sp)		;petit message...
	trap	#1		;
	addq.l	#6,sp		;
the_end	rts			;
;On pourrait aussi ne pas faire le lea 12(sp),sp et remplacer le addq.l #6,sp
;par un seul lea 18(sp),sp mais dans ce cas l… on perd la possibilit‚ de
;mettre la routine Exit...Ceci est une modif de derniŠre minute pour que le
;boot affiche un message mˆme en cas de mauvaise r‚solution de l'‚cran

VBL
	IFNE	TEST
	movea.l	$432.w,a5
	ENDC
	IFEQ	TEST
	lea	buffer(pc),a5
	ENDC
	bchg.b	#2,1(a5)		;compt_ecran=0
	move.w	(a5),d1		;swaping ‚cran
	movea.l	savebase1(a5,d1.w),a2	;
	movea.l	a2,a6		;
	moveq	#0,d0		;pr‚pare l'effacement
	move.l	adr_cls(a5),-(sp)	;
	rts			;

retour
	move.l	ecran1(a5,d1.w),d3	;routine qui a lieu aprŠs
	move.l	savebase1(a5,d1.w),a6	;l'effacement de l'‚cran
	lea	bcl1(pc),a1	;Adresse de boucle pour
	move.l	starbase(a5),a5	;le code d'affichage
	move.w	#320*4,d1		;maximum des X
	moveq	#6*4,d7		;vitesse du plan courant
bcl1	move.w	d7,d6		;
	subq.w	#1*4,d6		;
	lsr.w	#3,d6		;
	add.w	d6,d6		;
	movea.l	d3,a3		;
	adda.w	d6,a3		;


part2	move.w	(a5),d0		;8
	sub.w	d7,d0		;4
	bpl.s	bcl2_s		;8/12
	add.w	d1,d0		;4/0
bcl2_s	move.w	d0,(a5)+		;8
	movea.l	a3,a0		;4
	move.l	0(a4,d0.w),d2	;20
	add.w	(a5)+,d2		;8
	adda.w	d2,a0		;8
	swap	d2		;4
	move.l	a0,(a6)+		;12
	or.w	d2,(a0)		;8
	or.w	d2,160*Y_OFF1(a0)	;12
	or.w	d2,160*Y_OFF2(a0)	;12


part3	subq.w	#4,d7		;vitesse suivante
	beq.s	endvbl		;y'en a plus
	jmp	(a1)		;boucle
endvbl	lsr.w	#8,d3		;nouvel ‚cran
	move.l	d3,$ffff8200.w	;
	rte			;
endroutine


	SECTION	DATA
message
;		dc.b	27,'Y',43,47,'STARBOOT 3'
;		dc.b	27,'Y',45,47,190,' DNT~1992',$d,$a
		dc.b	27,'Y',43,43,169,240,'TH',238,127,'STARBOOT',127,'3',240,170
		dc.b	27,'Y',45,44,190,'92',32,239,209,199,199,208,'S//DNT',191,$d,$a
PLAN1	equ	$122
PLAN2	equ	$233
PLAN3	equ	$455
TXT	equ	$700


c_for_stars	dc.w	$000,PLAN1,PLAN2,PLAN2,PLAN3,PLAN3,PLAN3,PLAN3
		dc.w	TXT,TXT ;TXT,TXT,TXT,TXT,TXT,TXT
FIN		equ	*

compt_ecran	equ	0
starbase		equ	2
adr_cls		equ	6
ecran1		equ	10
ecran2		equ	14
savebase1		equ	18
savebase2		equ	22
x_buffer		equ	26
starbuffer		equ	26+320*4

	IFEQ	TEST
	SECTION	BSS
save_USP	ds.l	1
buffer	ds.l	42256
	ENDC
