 * The z-demo
 * First programm in pure assembler coded by Ziggy Stardust
 * in July 1990.
 * OVERLANDERS.
	include	"util.s"

validmus	equ	1
tstvit		equ	0
				
debut:
	move.l	a7,olda7
	START
	dc.w	$a00a
	clr.w	-(a7)
	move.w	#$20,-(a7)
	trap	#1	
	addq.l	#4,a7			
      	jmp	main
      	
hardc:
	rts
chargeprg:
	move.l	olda7,a5
	
	move.l	#$100,-(a7)	;Retrecissement de l'espace memoire
	move.l	a5,-(a7)	;Pour laisser plus de place … l'application
	move.w	#0,-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	adda.l	#12,a7
	
	pea	com
	pea	com
	pea	nomprog
	move.w	#0,-(a7)
	move.w	#$4b,-(a7)
	trap	#1
	adda.l	#16,a7
	clr.w	-(a7)
	trap	#1

*	include	"\ZIGGY1.OVR\inter.s"      	
      	include	"\ZIGGY1.OVR\loadcmp.s"
      	ifne	validmus
      	incBIN	\ZIGGY1.OVR\sync.S
      	endc
repc:
	ext.w	d0
	neg.w	d0
	move.b	(a0)+,d1
looprepc:
	move.b	d1,(a1)+
	dbra	d0,looprepc
	bra	loopdect
      	
main:
	move.b	#18,$fffc02
	move.b	#2,$ff820a	;50Hz
	move.l	#hardc,$502
	move.b	#%110,$484
	move.l	$44e,ec1
	move.l	ec1,oldec
	lea	ecran,a0
	move.l	a0,d0
	and.l	#$ffffff00,d0
	move.l	d0,(ec2)
	lea	$ff8240,a0
	rept	8
	clr.l	(a0)+	
	endr
	jsr	decale
       	vsync
	move.b	$ff8260,oldrez
	move.b	#0,$ff8260

	move.w	#3,-(a7)
	trap	#14
	addq.l	#2,a7
	move.l	d0,a1
	lea	image+32,a0
	jsr	decomp
	move.l	ec1,a0
	move.l	ec2,a1
	move.w	#32000/4-1,d0
loopcop12:
	move.l	(a0)+,(a1)+
	dbra	d0,loopcop12
	jsr	decalovers
	pea	image
	move.w	#6,-(a7)
	trap	#14
	addq.l	#6,a7
 	ifne	validmus
	jsr	set_mus
	endc
	
	lea	texteini,a0
	lea	texte,a1
loopdect:
	move.b	(a0)+,d0
	cmpi.b	#-127,d0
	beq	findect
	tst.b	d0
	blt	repc
	move.b	d0,(a1)+
	bra.s	loopdect
findect:
	move.b	#-127,(a1)+

*	jsr	set_rout
	
mainloop:			;Boucle principale
	move.l	ec1,a0
	move.l	ec2,ec1
	move.l	a0,ec2
	move.w	#-1,-(a7)
	move.l	ec2,-(a7)
	move.l	ec1,-(a7)
	move.w	#5,-(a7)
	trap	#14
	adda.l	#12,a7
	ifne	tstvit
	move.w	#$777,$ff8240
	endc
	vsync
	ifne	tstvit
	move.w	#$000,$ff8240
	endc
	jsr	clsscreen
	
	move.l	addx,d7
	move.l	d7,d6
	lsr.l	#5,d6
	lsl.l	#5,d6
	sub.l	d6,d7
	lsr.l	#5,d6
	lea	texte,a6
	add.l	d6,a6
	moveq.l	#10,d6
	sub.w	d7,d6
loopscroll:			;Scroll des lettres

	move.b	(a6)+,d0
	move.b	d0,d5
	cmpi.b	#-127,d0
	beq	finscroll
	ext.w	d0
	tst.w	d0
	blt	badcar
	cmpi.w	#39,d0
	bgt	badcar
	move.l	d6,d1
	
	tst.b	qsin
	bne	sintexte
	
	move.w	#170,d2	
	jmp	contexte
sintexte:

	lea	sinus,a0
	move.l	d1,d7
	add.l	#32,d7
	lsr.w	#1,d7
	add.w	addy,d7
	move.b	(a0,d7.w),d2
	ext.w	d2
	asr.w	#1,d2
	addi.w	#65,d2
contexte:
	jsr	afflettre
badcar:	
	addi.w	#32,d6
	cmpi.w	#304,d6
	blt	loopscroll

contscroll:

	cmpi.w	#'1',d5
	bne	contnosin
	clr.b	qsin
contnosin:
	cmpi.w	#'2',d5
	bne	contsetsin
	move.b	#1,qsin
contsetsin:

	cmpi.w	#'3',d5
	bne	contsetcls
	move.b	#1,qcls
contsetcls:
	cmpi.w	#'4',d5
	bne	contnocls
	move.b	#0,qcls
contnocls:

	cmpi.w	#'5',d5
	bne	contsetspr
	move.b	#1,qspr
contsetspr:
	cmpi.w	#'6',d5
	bne	contnospr
	move.b	#0,qspr
contnospr:

	move.w	addy,d0
	subq.w	#2,d0
	tst.w	d0
	bgt	addy320
	addi.w	#320,d0
addy320:
	move.w	d0,addy
	move.l	addx,d0
	addq.l	#4,d0
	move.l	d0,addx
	
	tst.b	qspr
	beq	finsprite
	lea	ziggy,a6
	moveq.l	#0,d7
	move.w	decspr,d7
loopsprite:			;Affichage des sprites		
	addi.w	#16,d7
	cmpi.w	#320,d7
	blt	contmd7
	subi.w	#320,d7
contmd7:
	moveq.l	#0,d0
	move.b	(a6)+,d0
	tst.w	d0
	beq	finsprite
	subi.w	#'A',d0
	tst.w	d0
	blt	loopsprite
	cmpi.w	#39,d0
	bgt	loopsprite
	
	lea	sinus,a0
	move.b	(a0,d7.w),d1
	ext.w	d1
	neg.w	d1
	
	move.l	d7,d6
	add.l	#80,d6
	move.b	(a0,d6.w),d2
	ext.w	d2
	
	move.w	angx,d6
	move.b	(a0,d6.w),d6
	ext.w	d6
	muls	d6,d1
	divs	#80,d1
	
	move.w	angy,d6
	move.b	(a0,d6.w),d6
	ext.w	d6
	muls	d6,d2
	divs	#150,d2
	
	addi.w	#144,d1
	addi.w	#70,d2
	jsr	afflettre
	jmp	loopsprite 
	
finsprite:

	move.w	decspr,d0
	subq.w	#3,d0
	tst.w	d0
	bge	contmuld0
	addi.w	#320,d0
contmuld0:
	move.w	d0,decspr
	
	move.w	angy,d0
	subq.w	#4,d0
	tst.w	d0
	bge	contmulangy
	addi.w	#320,d0
contmulangy:
	move.w	d0,angy
	
	move.w	angx,d0
	subq.w	#3,d0
	tst.w	d0
	bge	contmulangx
	addi.w	#320,d0
contmulangx:
	move.w	d0,angx
	
	moveq.l	#0,d7
	move.w	#320+80,d7
	sub.w	decspr,d7
	move.w	#80,d5
	tst.b	qspr
	bne	looppoint
	move.w	#150,d5
looppoint:			;Affichage des points
	move.w	#320+80,d6
	sub.w	decspr,d6
	add.w	d5,d6
	addq.w	#2,d7
	cmp.w	d6,d7
	bge	finpoint
	
	lea	sinus,a0
	move.b	(a0,d7.w),d1
	ext.w	d1
	
	move.l	d7,d6
	add.l	#80,d6
	move.b	(a0,d6.w),d2
	ext.w	d2
	
	move.w	angy,d6
	move.b	(a0,d6.w),d6
	ext.w	d6
	muls	d6,d1
	divs	#100,d1
	
	move.w	angx,d6
	move.b	(a0,d6.w),d6
	ext.w	d6
	muls	d6,d2
	divs	#150,d2
	
	addi.w	#160,d1
	addi.w	#70,d2
	jsr	plot
	jmp	looppoint
finpoint:
	
	move.w	#$b,-(a7)	;Test des touches
	trap	#1
	addq.l	#2,a7
	tst.l	d0
	beq	mainloop
	move.w	#8,-(a7)
	trap	#1
	addq.l	#2,a7
	cmpi.w	#'p',d0
	bne	contpause
	wait
contpause:
	cmpi.w	#' ',d0
	beq	fin
	jmp	mainloop	
	
finscroll:
	clr.l	addx	
	bra	contscroll
	
fin:	
	move.b	#$8,$fffc02
	move.b	#%111,$484
	ifne	validmus
	jsr	unset_mus
	endc
*	jsr	stoprout
	move.w	#7,-(a7)
	move.w	#2,-(a7)
	trap	#1
	addq.l	#4,a7
	move.w	#-1,-(a7)
	move.l	oldec,-(a7)
	move.l	oldec,-(a7)
	move.w	#5,-(a7)
	trap	#14
	adda.l	#12,a7
	move.w	#32000/4-1,d0
	move.l	oldec,a0
loopcl:
	clr.l	(a0)+
	dbra	d0,loopcl
	vsync
	move.b	oldrez,$ff8260
	move.w	#0,$ff8240
	move.w	#$555,$ff8240+6
	move.w	#$555,$ff8240+30
	move.w	#0,-(a7)
	move.w	#$40,-(a7)
	trap	#1
	addq.l	#4,a7
	dc.w	$a009
	jmp	chargeprg
	
decale:				;Effectue les d‚calage des lettres …
				; l'avance, pour be faster!!!
	move.w	#15,d0
	lea	lettred,a0
	
loopdecd:
	move.w	#799,d1
	lea	lettres,a1
	
loopdecl:
	moveq.l	#0,d2
	move.w	(a1)+,d2
	lsl.l	d0,d2
	moveq.l	#0,d3
	move.w	(a1)+,d3
	lsl.l	d0,d3
	move.l	d3,d4
	swap	d4
	or.w	d4,d2
	move.l	d2,(a0)+
	move.w	d3,(a0)+
	dbra	d1,loopdecl
	
	dbra	d0,loopdecd
	
	rts		
decalovers:	;Toujours pour la meme raison, les d‚calages du
		;OVERLANDERS sont fait d'avance (cela prend 51Kb)

	lea	overs,a1
	move.w	#15,d0
loopov1:
	move.l	ec1,a0
	adda.l	#137*160,a0
	move.w	#20*80-1,d1
loopov2:
	moveq.l	#0,d2
	move.w	(a0),d2
	lsl.l	d0,d2
	move.w	d2,(a1)
	swap	d2
	or.w	d2,-8(a1)
	addq.l	#2,a0
	addq.l	#2,a1
	dbra	d1,loopov2
	
	dbra	d0,loopov1
	
	move.l	ec1,a0
	adda.l	#137*160,a0
	lea	overs+20*160*16,a1
	move.w	#20,d0
	jsr	bmove32
	
	rts
	
plot:		;Affichage d'un point (sur le plan 3) x:d1, y:d2.
	and.l	#$ffff,d1
	and.l	#$ffff,d2
	move.l	d1,d0
	and.w	#$f,d0
	move.l	ec1,a0
	asr.w	#4,d1
	asl.w	#3,d1
	mulu	#160,d2
	add.l	d1,a0
	add.l	d2,a0
	addq.l	#6,a0
	move.w	#15,d1
	sub.w	d0,d1
	move.w	(a0),d0
	bset	d1,d0
	move.w	d0,(a0)
	rts
afflettre:	;Affichage d'une lettre. No: D0, X: D1, Y: D2. Super, non?

	and.l	#$ffff,d2
	move.w	d1,d3		;Initialisation des adresses
	and.w	#$f,d3
	mulu	#4800,d3
	mulu	#6*20,d0
	lea	lettred,a0
	add.l	d3,a0
	add.l	d0,a0
	move.l	$44e,a1
	mulu	#160,d2
	addq.l	#6,a1		;Affichage uniquement sur le 3eme plan!
	add.l	d2,a1
	asr.w	#4,d1
	asl.w	#3,d1
	ext.l	d1
	add.l	d1,a1
	
	rept	20		;Attention, on affiche!!!
	move.l	(a0),d0
	move.w	4(a0),d1
	or.w	d0,8(a1)
	swap.w	d0
	or.w	d0,(a1)
	or.w	d1,16(a1)
	addq.l	#6,a0
	add.l	#160,a1
	endr
	
	rts

clsscreen:			; Efface les deux fenetres d'‚cran
	tst.b	qcls
	bne	contcls1
	tst.w	ncls
	bgt	contcls2
	move.w	#9,ncls
contcls1:
	move.l	ec1,a0		; Addresse de l'‚cran
	adda.l	#6+160*8,a0	; Ligne 8 … 140, sur le plan No3
	move.w	#136-8+5,d0		
	jsr	clsp	
contcls2:
	subi.w	#1,ncls
	move.l	ec1,a0
	adda.l	#6+169*160,a0	; Line 170 … 190, toujours plan 3
	move.w	#21,d0		
	jsr	clsp	
	
	move.w	#20-1,d0	; Affichage du OVERLANDERS
	lea	overs,a0
	move.l	ec1,a1
	adda.l	#137*160,a1
	move.w	decover,d1
	lea	sinus,a3
	moveq.l	#0,d3
	move.b	(a3,d1.w),d3
	ext.w	d3
	muls	#8,d3
	divs	#100,d3
	muls	#20*160,d3
	addi.l	#20*160*8,d3
	lea	table,a3
	move.l	d3,(a3)

loopaffover:
	move.l	(a3)+,d3
	lea	(a0,d3.l),a2	
	adda.l	#16,a2
	adda.l	#16,a1
	rept	32
	move.l	(a2)+,(a1)+
	endr
	adda.l	#16,a1
	adda.l	#160,a0
	dbra	d0,loopaffover
	
	move.w	incdecover,d1
	asr.w	#6,d1
	move.w	decover,d0
	add.w	d1,d0
	cmpi.w	#320,d0
	blt	csub320
	subi.w	#320,d0
csub320:
	move.w	d0,decover
	
	move.w	incdecover,d0
	addq.w	#1,d0
	cmpi.w	#20*64,d0
	blt	csubinc320
	subi.w	#20*64,d0
csubinc320:
	move.w	d0,incdecover
	
	lea 	(table+4*19),a0
	lea	4(a0),a1
	rept	19
	move.l	-(a0),-(a1)
	endr
	
	rts
	
bmove32:
	rept	40
	move.l	(a0)+,(a1)+
	endr
	dbra	d0,bmove32
	rts
	
clsp:
	moveq.l	#0,d1
loopclsp:			;Efface a partir de A0, sur D0 lignes
				;du pixel 16 … 304, sur un seul plan.
*	move.w	d1,(a0)
	move.w	d1,8(a0)	
	move.w	d1,16(a0)
	move.w	d1,24(a0)
	move.w	d1,32(a0)
	move.w	d1,40(a0)
	move.w	d1,48(a0)
	move.w	d1,56(a0)
	move.w	d1,64(a0)
	move.w	d1,72(a0)
	move.w	d1,80(a0)
	move.w	d1,88(a0)	
	move.w	d1,96(a0)
	move.w	d1,104(a0)
	move.w	d1,112(a0)
	move.w	d1,120(a0)
	move.w	d1,128(a0)
	move.w	d1,136(a0)
	move.w	d1,144(a0)
*	move.w	d1,152(a0)
	adda.l	#160,a0

	dbra	d0,loopclsp
	
	rts
	
texteini:
	incbin	"\ZIGGY1.OVR\texte"
	dc.b	-127,-127
	even
ziggy:
	dc.b	"\ZIGGY1.OVR\ALLIANCE",0
	even
image:
	incbin	"\ZIGGY1.OVR\coucou.cmp"
	even
lettres:
	incbin	"\ZIGGY1.OVR\lettres"
	even
sinus:
	incbin	"\ZIGGY1.OVR\sinus"
	even
nomprog:
	dc.b	"\ZIGGY1.OVR\allian.mfi",0
com:
	dc.l	0
	
decover: 	dc.w	0
incdecover	dc.w	0
addx:	dc.l	0
addy:	dc.w	320
decspr:	dc.w	0
angx:	dc.w	0
angy:	dc.w	0
sensy:	dc.w	-1
oldec	dc.l	0
ec1	dc.l	0
ec2	dc.l	0
oldrez	dc.b	0
qsin	dc.b	0
table	dcb.l	8*160*20,20
qcls	dc.b	1
ncls	dc.w	9
qspr	dc.b	1
	
	section	bss
	
lettred:
	ds.b	80000
ecran:
	ds.b	35000
nothing:
	ds.b	256		;Rien du tout... (Tres interessant, non?)
overs:
	ds.b	20*160*18	; un peu + 51200 Octets pour les diff‚rends
				; d‚calage du OVERLANDERS
texte:
	ds.b	10000
olda7:
	ds.l	1

	end							