;	MEGA-DIS-DRAWER      
;
;debut:07/07/91
;fin  :07/07/91
;dure du scroll text:	3'17''
;taille en RAM      :	275411 octets
;fichier a inclure  :   syncdat .inc
;		graphchr.inc
;		logo2   .img
;		zichiden.		
; REMARQUE: la routine de ligne utilise ici est la 3eme version
;de mes routines de ligne, elle n'est pas encore aussi rapide que ma 5eme
;version,mais elle propose deja 1 bonne rapidite de tracage... 
; elle est parametrable de maniere a pouvoir l'utilise en full,ou en normal
; ou meme en ecran virtuel de taille quelconque(cf les notes au debut
; de la routine).toutefois elle est prevu pour 4 plans forcement...
; le reste du code n'es pas de bonne facture(code en 4 heures) sorry!!!
;
;	code de PrinST


;====================================
;	CONSTANTES...
;====================================
RED1 = 32		;se sont les parametre de la pressision du mvt
RED2 = 5		; RED1=2^RED2 , 0<RED2<9
;====================================
;	MACROS
;====================================
;
; macro de generation d'1 raster full,ma version qui tourne
;normalement de partout.ecrivez moi dans le k contraire!!!!
;
raster	macro
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	move.b	d1,$ffff8260.w
	move.b	d0,$ffff8260.w
	move	(a4)+,$ffff8242.w
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	move.b	d0,$ffff820a.w
	move.b	d1,$ffff820a.w
	nop
	nop
	move	(a6)+,$ffff825e.w
	move	(a5)+,$ffff8240.w
	move.b	d1,$ffff8260.w	
	move.b	d0,$ffff8260.w
	endm

;====================================
	section	text
;====================================
	pea	prog
	move	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	
	clr	-(sp)
	trap	#1
;====================================
;	programme superuser
;====================================	
prog	move.w 	#$2700,sr
	bra	progr
	
	DC.B "  IF YOU READ THIS TEXT,YOU ARE A RIPPER, FELICITATION BECAUSE US PROTECTION LOST!!!!"
;====================================
;	sauver la palette
;====================================
progr	moveq	#1,d0
	jsr	zic
	lea	$ffff8240.w,a1
	lea 	savpal,a0
	rept 8
	move.l 	(a1)+,(a0)+
	endr
;====================================
;	installer le new ecran
;====================================
	move.b	$ffff8201,vff8201
	move.b	$ffff8203,vff8203
	clr.b 	vbig	
	move.l 	#datasync+1,possync
	move.l 	#fullscr,adrful
	move.l	#fullscr,d0
	move.l	d0,a0
;====================================
;	effacer l'ecran
;====================================
	lea	fullscr,a0
	move	#230*200-1,d0
eff	clr.l	(a0)+
	dbra	d0,eff
;====================================
;	afficher l'ecran
;====================================
	lea	fullscr+230*20+18,a0
	lea	(a0),a1
	add.l	#230*160,a1
	lea	(a1),a2
	add.l	#230*160,a2
	lea	(a2),a3
	add.l	#230*160,a3
	lea	(a3),a5
	add.l	#230*160,a5
	lea	logo,a4
	move	#119,d0
aff	rept	20
	move.l	(a4),144(a0)
	move.l	(a4),(a0)+
	move.l	(a4),144(a1)
	move.l	(a4),(a1)+
	move.l	(a4),144(a2)
	move.l	(a4),(a2)+
	move.l	(a4),144(a3)
	move.l	(a4),(a3)+
	move.l	(a4),144(a5)
	move.l	(a4)+,(a5)+
	endr
	lea	150(a0),a0
	lea	150(a1),a1
	lea	150(a2),a2
	lea	150(a3),a3
	lea	150(a5),a5
	dbra	d0,aff
;====================================
;	init variables
;====================================
	move.l	#fullscr,adrful
	move.l	#fullscr2,adrful2
	move.l	#fullscr3,adrful3
	move.l	#fullscr4,adrful4
	move.l	#fullscr5,adrful5
	move.b	#8,txtf
	move.l	#text,adrtxt
;====================================
;	boucle principale
;====================================
bigbcl
;====================================
;	synchro VBL
;====================================
	lea 	$ffff8209.w,a6
	move.w 	#159,d7
	move.b 	$ffff8203.w,d5
vsync1	cmp.b 	$ffff8207.w,d5
	bne.s 	vsync1
;====================================
;	init couleur a 0
;====================================
	clr.l	$ffff8240.w
	clr.l	$ffff8244.w
	clr.l	$ffff8248.w
	clr.l	$ffff824c.w
	clr.l	$ffff8250.w
	clr.l	$ffff8254.w
	clr.l	$ffff8258.w
	clr.l	$ffff825c.w
;====================================
;	le scroll...
;====================================
;	dabord en RAM
	lea	txtbuf+28*8*2,a0
	rept	28*8
	roxl	-(a0)
	endr
	subq.b	#1,txtf
	tst.b	txtf
	bne.s	I0
	move.b	#8,txtf
	addq.l	#1,adrtxt
	move.l	adrtxt,a0
	moveq	#0,d0
	move.b	(a0),d0
	sub	#32,d0
	lsl	#3,d0
	lea	chrgfx,a1
	add.l	d0,a1
	lea	txtbuf+27*2,a2
	rept	8
	move.b	(a1)+,(a2)
	lea	28*2(a2),a2
	endr
	cmp.l	#endtext,a0
	bne.s	I0
	move.l	#text,adrtxt
I0
;	on copi sur l'ecran
	lea	txtbuf,a1
	move.l	adrful,a0
	add.l	#230*151,a0
	rept	28
	move	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	rept	28
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	rept	28
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	rept	28
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	rept	28
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	rept	28
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	rept	28
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	rept	28
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	lea	txtbuf,a1
	move.l	adrful,a0
	add.l	#230*151+2,a0
	rept	28
	move	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	rept	28
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	rept	28
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	rept	28
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	rept	28
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	rept	28
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	rept	28
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	rept	28
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	lea	txtbuf,a1
	move.l	adrful,a0
	add.l	#230*151+4,a0
	rept	28
	move	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	rept	28
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	rept	28
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	rept	28
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	rept	28
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	rept	28
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	rept	28
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	rept	28
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	lea	txtbuf,a1
	move.l	adrful,a0
	add.l	#230*151+6,a0
	rept	28
	move	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	rept	28
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	rept	28
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	rept	28
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	rept	28
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	rept	28
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	rept	28
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
	rept	28
	move.w	(a1)+,(a0)
	addq.l	#8,a0
	endr
	addq.l	#6,a0
;====================================
;	la zico
;====================================
	movem.l	d0-a6,-(sp)
	jsr	zic+8
	movem.l	(sp)+,d0-a6
;====================================
;	routine de sync
;====================================
	moveq	#18,d6
vsync2	tst.b 	(a6)
	beq.s 	vsync2
	sub.b 	(a6),d6
	lsr.l 	d6,d6
;
;	ici le sync...
;
	lea 	$ffff820a.w,a0
	lea 	$ffff8260.w,a1
	moveq 	#0,d0
	moveq 	#2,d1
	rept 51
	nop
	endr
	moveq 	#14,d6
	move.l 	possync,a2
sync	nop
	move.b 	(a2)+,(a0)
	nop
	move.b 	d1,(a0)
	rept 12
	nop
	endr
	move.b 	(a2),(a1)
	nop
	move.b 	d0,(a1)
	rept 10
	nop
	endr
	move.b 	(a2)+,(a1)
	nop
	nop
	move.b 	d0,(a1)
	rept 83
	nop
	endr
	dbra 	d6,sync
	lea	new_pal,a0
	lea	$ffff8240.w,a1
	movem.l	(a0),d2/d3/d4/d5/d6/d7/a2/a3
	lea	raster,a4
	lea	raster2,a5
	lea	raster3,a6
	rept	99
	nop
	endr	
	movem.l	d2/d3/d4/d5/d6/d7/a2/a3,(a1)
;
;	c parti pour tout l'ecran!!!!
;
	rept	160
	raster
	endr

;====================================
;     fin du full... temps mort.
;====================================
	clr.l	$ffff8240.w
	clr.l	$ffff8244.w
	clr.l	$ffff8248.w
	clr.l	$ffff824c.w
	clr.l	$ffff8250.w
	clr.l	$ffff8254.w
	clr.l	$ffff8258.w
	clr.l	$ffff825c.w
;====================================
;	la line qui promenne...
;====================================
	addq.l	#1,AX1
	cmp.l	#230*RED1,X1
	blt.s	P1
	subq.l	#2,AX1
P1	addq.l	#1,AY1
	cmp.l	#80*RED1,Y1
	blt.s	P2
	subq.l	#2,AY1
P2	addq.l	#1,AX2
	cmp.l	#230*RED1,X2
	blt.s	P3
	subq.l	#2,AX2
P3	addq.l	#1,AY2
	cmp.l	#80*RED1,Y2
	blt.s	P4
	subq.l	#2,AY2
P4	move.l	AX1,d0
	add.l	d0,X1
	move.l	AY1,d0
	add.l	d0,Y1
	move.l	AX2,d0
	add.l	d0,X2
	move.l	AY2,d0
	add.l	d0,Y2
	move.l	X1,d0
	move.l	Y1,d1
	move.l	X2,d2
	move.l	Y2,d3
	lsr.l	#RED2,d0
	lsr.l	#RED2,d1
	lsr.l	#RED2,d2
	lsr.l	#RED2,d3
	move.l	adrful,a0
	bsr	line
	cmp.b	#$62,-$3fe
	bne.s	C1
	bsr	new_def
;====================================
;     swishing sur les 5 ecrans
;====================================
C1	move.l	adrful,d0
	move.l	adrful2,adrful
	move.l	adrful3,adrful2
	move.l	adrful4,adrful3
	move.l	adrful5,adrful4
	move.l	d0,adrful5
;====================================
;	routine de calcul du sync
;====================================
ste1	move.l	adrful,a0
	move.l 	a0,d0
	sub.l	#2704,d0
	move.l 	d0,d1
	and.l 	#254,d1
	lsl 	#4,d1
	move.l 	#datasync,d2
	add.l 	d1,d2
	move.l 	d2,a0
	addq.l 	#1,d2
	move.l 	d2,possync
	moveq 	#0,d1
	move.b 	(a0),d1
	lsl 	#8,d1
	and.l 	#$ffff00,d0
	sub.l 	d1,d0
	lsr.l 	#8,d0
	move.b 	d0,$ffff8203.w
	lsr 	#8,d0
	move.b 	d0,$ffff8201.w
;====================================
;	sorti par mis a 2 de vbig 
;====================================
	cmp.b 	#$39,-$3fe.w
	beq.s	sorti
	jmp 	bigbcl
sorti
;====================================
;	Fin de la demo sortie...
;====================================
	move.b 	vff8201,$ffff8201.w
	move.b 	vff8203,$ffff8203.w
	move.w 	#$2000,sr
	lea 	$ffff8240.w,a0
	lea 	savpal,a1
	rept 8
	move.l 	(a1)+,(a0)+
	endr
	move.l	#$08080000,$ffff8800.w
	nop
	move.l	#$09090000,$ffff8800.w
	nop
	move.l	#$0a0a0000,$ffff8800.w
	nop
	rts
;====================================
;  routine de nouvelle trajectoire
;====================================
new_def	movem.l	d0-a6,-(sp)
	move	#$2300,sr
	clr.b	clavier
	move.l	$70.w,-(sp)
	move.l	#vbl,$70

bc1	addq.l	#2,X1
	addq.l	#3,X2
	addq.l	#1,Y1
	addq.l	#4,Y2
	cmp.l	#430*RED1,X1
	blt.s	A1
	move.l	#30*RED1,X1
A1	cmp.l	#430*RED1,X2
	blt.s	A2
	move.l	#30*RED1,X2
A2	cmp.l	#155*RED1,Y1
	blt.s	A3
	move.l	#5*RED1,Y1
A3	cmp.l	#155*RED1,Y2
	blt.s	A4
	move.l	#5*RED1,Y2
A4	move.b	clavier,d0
	cmp.b	#$62+$80,d0
	bne	bc1

	clr.l	AX1
	clr.l	AY1
	clr.l	AX2
	clr.l	AY2
	move.l	#fullscr,a0
	move	#230*200-1,d0
eff2	clr.l	(a0)+
	dbra	d0,eff2
	lea	fullscr+230*20+18,a0
	lea	(a0),a1
	add.l	#230*160,a1
	lea	(a1),a2
	add.l	#230*160,a2
	lea	(a2),a3
	add.l	#230*160,a3
	lea	(a3),a5
	add.l	#230*160,a5
	lea	logo,a4
	move	#119,d0
aff2	rept	20
	move.l	(a4),144(a0)
	move.l	(a4),(a0)+
	move.l	(a4),144(a1)
	move.l	(a4),(a1)+
	move.l	(a4),144(a2)
	move.l	(a4),(a2)+
	move.l	(a4),144(a3)
	move.l	(a4),(a3)+
	move.l	(a4),144(a5)
	move.l	(a4)+,(a5)+
	endr
	lea	150(a0),a0
	lea	150(a1),a1
	lea	150(a2),a2
	lea	150(a3),a3
	lea	150(a5),a5
	dbra	d0,aff2
	
	move.w	#$2700,sr
	move.l	(sp)+,$70.w
	movem.l	(sp)+,d0-a6
	rts
vbl	
	move.b	-$3fe,clavier
	movem.l	d0-a6,-(sp)
	jsr	zic+8
	movem.l	(sp)+,d0-a6
	rte
clavier	dc.w	1
;====================================
;    PrinST routine de ligne V 3
;====================================
line
NBPTMAX = 487 ; nb points grand max => sqr(Xmax^2+Ymax^2)
NBPTMX  = 460 ; nb points horizontal
NBPTMY  = 165 ; nb points verticaux
NBOCLIN = 230 ; nb d'octets par ligne
;
;   parametre    d0:X1
;	     d1:Y1
;	     d2:X2
;	     d3:Y2
;	     A0:adresse ecran
;
	cmp	d0,d2
	bgt.s	linec
	exg	d0,d2
	exg	d1,d3
linec	cmp	d0,d2
	bne.s	cas12345
	cmp	d1,d3
	bgt.s	cas6
	move	d1,d5
	sub.l	d3,d5
	mulu 	#NBOCLIN,d1
	move.l	d0,d2
	lsr.l	#4,d0
	lsl.l	#3,d0
	and.l	#$f,d2
	move.l 	#$8000,d3
	lsr.l	d2,d3
	add.l	d0,a0
	add.l	d1,a0
	mulu	#6,d5
	lea	line1,a1
	sub.l	d5,a1
	jmp	(a1)		
cas6	move.l	d3,d5
	sub.l	d1,d5 
	mulu 	#NBOCLIN,d1
	move.l	d0,d2
	lsr.l	#4,d0
	lsl.l	#3,d0
	and 	#$f,d2
	move 	#%1000000000000000,d3
	lsr 	d2,d3
	add.l	d0,a0
	add.l	d1,a0
	mulu	#6,d5
	lea	line2,a1
	sub.l	d5,a1
	jmp	(a1)
cas12345  cmp.l	d1,d3
	bne.s	cas1234
	move.l	d2,d5
	sub.l	d0,d5 
	mulu 	#NBOCLIN,d1
	add.l	d1,a0
	move.l	d0,d1
	lsr.l	#4,d0
	lsl.l	#3,d0
	and.l	#$f,d1
	add.l	d0,a0
	move	#$8000,d0
	lsr	d1,d0
	lea	line3,a1
	mulu	#12,d5
	sub.l	d5,a1
	jmp	(a1)
cas1234	cmp.l	d1,d3
	bgt	cas23
	move.l	d2,d4
	move.l	d1,d5
	sub.l	d0,d4
	sub.l	d3,d5
	cmp.l	d4,d5
	bgt.s	cas4
	move	#$4000,d6
	mulu	#NBOCLIN,d1
	add.l	d1,a0
	move.l	d0,d1
	lsr.l	#4,d0
	lsl.l	#3,d0
	add.l	d0,a0
	and.l	#$f,d1
	move	#$8000,d0
	move	d0,d3
	lsr	d1,d0
	move	#$4000,d1
	move	d4,d7
	mulu	#24,d7
	lea	line5,a1
	sub.l	d7,a1
	jmp	(a1)
cas4	move	#$4000,d6
	mulu	#NBOCLIN,d1
	add.l	d1,a0
	move.l	d5,d7
	move.l	d0,d1
	lsr	#4,d1
	lsl	#3,d1
	add.l	d1,a0
	and.l	#$f,d0
	move	#$8000,d2
	lsr	d0,d2
	move	#$4000,d0
	lea	line6,a1
	mulu	#24,d7
	sub.l	d7,a1
	jmp	(a1)
cas23	move.l	d2,d4
	move.l	d3,d5
	sub.l	d0,d4
	sub.l	d1,d5
	cmp.l	d4,d5
	bgt.s	cas3
	move	#$4000,d6
	mulu	#NBOCLIN,d1
	add.l	d1,a0
	move.l	d0,d1
	lsr.l	#4,d0
	lsl.l	#3,d0
	add.l	d0,a0
	move	#$8000,d0
	and	#$f,d1
	lsr	d1,d0
	move.w	#$4000,d1
	lea	line8,a1
	move	d4,d7
	mulu	#24,d7
	sub.l	d7,a1
	jmp	(a1)
cas3	move.l	#$4000,d6
	mulu 	#NBOCLIN,d1
	add.l	d1,a0
	move.l	d0,d1
	lsr 	#4,d1
	lsl 	#3,d1
	add.l	d1,a0
	and	#$f,d0
	move 	#$8000,d2
	lsr 	d0,d2
	lea	linea,a1
	move.l	d5,d7
	mulu	#24,d7
	sub.l	d7,a1
	move.w	#$4000,d0
	jmp	(a1)
	rept	NBPTMY
	or 	d3,(a0)
	lea	-NBOCLIN(a0),a0
	endr
line1	rts
	rept	NBPTMY
	or 	d3,(a0)
	lea	NBOCLIN(a0),a0
	endr
line2	rts
	rept	NBPTMX
	ror 	d0
	btst	#15,d0
	dc.w	$6702  
	addq.l	#8,a0
	or 	d0,(a0)
	endr
line3	rts
	rept	NBPTMAX
	lea	-NBOCLIN(a0),a0
	sub	d4,d6
	cmp	d0,d6
	dc.w	$6e0c 
	ror	d2
	add	d5,d6
	btst	#15,d2
	dc.w	$6702 
	addq.l	#8,a0
	or	d2,(a0)
	endr
line6	rts
	rept	NBPTMAX
	lea	NBOCLIN(a0),a0
	sub 	d4,d6
	cmp 	d0,d6
	dc.w	$6e0c
	ror 	#1,d2
	add 	d5,d6
	btst	#15,d2
	dc.w	$6702
	addq.l	#8,a0
	or 	d2,(a0)
	endr
linea	rts
	rept	NBPTMAX
	cmp	d1,d6
	dc.w	$6d06	
	sub	d4,d6
	lea	-NBOCLIN(a0),a0
	ror	d0
	btst	#15,d0
	dc.w	$6702	
	addq.l	#8,a0
	add	d5,d6
	or	d0,(a0)
	endr
line5	rts
	rept	NBPTMAX
	cmp	d1,d6
	dc.w	$6d06
	sub	d4,d6
	lea	NBOCLIN(a0),a0
	add	d5,d6
	ror	d0
	btst	#15,d0
	dc.w	$6702
	addq.l	#8,a0
	or	d0,(a0)
	endr
line8	rts
;====================================
	section	data
;====================================
new_pal	dc.l	$01110000,$01010202,$03030404,$05050606,$07070717,$07270737,$07470757,$07670777
pal	dc.w	0,$444,$555,0,$666,0,0,0,$777,0,0,0,0,0,0,0,0
raster	rept	10
	dc.w	$440,$550,$660,$770,$671,$572,$473,$374,$275,$175,$076,$077
	dc.w	$066,$055,$044,$134,$224,$314,$404,$505,$606,$707,$617,$527
	dc.w	$437,$347,$257,$167,$077,$076,$175,$275,$374,$473,$572,$671
	dc.w	$771,$662,$553,$444
	endr
raster2	rept	155
	dc.w	$111
	endr
	dc.w	$2,$4,$6,$7,$7
raster3	rept	150
	dc.w	$777
	endr
	dc.w	$777,$777,$666,$666,$555,$444,$333,$222
datasync	incbin syncdata.bin
chrgfx	incbin graphchr.inc
logo	incbin logo2.img
zic	incbin zichiden.mad
X1	dc.l	30*RED1
Y1	dc.l	5*RED1
X2	dc.l	430*RED1
Y2	dc.l	155*RED1
AX1	dc.l	0
AX2	dc.l	0
AY1	dc.l	0
AY2	dc.l	0

text	dc.b	"    Welcome in the hidden screen of the space demo. The code was given by PrinST of megabusters and the music by Mad Max..."
	dc.b	" If you don't like the drawer wave form PRESS SLOWLY - HELP -... this demo don't use TRIGONOMETRICAL FUNCTION!"
	dc.b	" and NOTHING is precalculed. The drawer routine is my very hard work product .i can draw 15 diagonals full screen line in one VBL time processor!!"
	dc.b	" But ziggy stardust said to my:<< i cant make 274 line in one vbl!!!,1 line in one HBL time!!!>> so mine is very bad!!! OR ziggy is a very great"
	dc.b	" coder... GUDUL had say me that he had a 14 diagonals (but no fullscreen) line in one vbl. so i'm not so bad !!!"
	dc.b	" Congratulations, you have found the Hiddenscreen ,and this one was hardly hide by Jaile in the main menu ."
	dc.b	" A personnal message to Djaybee: Your main menu is good but could you not make a SPACE main menu ?? " 	
	dc.b	" But you are allways making what you want .This this now the end of this scrolltext so see you soon, PrinST of MegabuSTers          coded the 7th Juny 1991 in 3 hours..."
 	dc.b	" (But all the routs were made before)       LET'S WRAP..... Remember THE MEGABUSTERS RULES  and .... press HELP to see infinits trajectory ."
	dc.b	"                                                                                 "
endtext	dc.b	"                       "
;====================================
	section	bss
;====================================
adrful	ds.l	1
adrful2	ds.l	1
adrful3	ds.l	1
adrful4	ds.l	1
adrful5	ds.l	1
adrtxt	ds.l	1
possync	ds.l	1

savpal	ds.w	16
txtbuf	ds.w	28*8

vff8201	ds.b	1
vff8203	ds.b	1
vbig	ds.b	1
syncf	ds.b	1
txtf	ds.b	1
	even
	ds.b	2300
fullscr	ds.b	230*160
fullscr2	ds.b	230*160
fullscr3	ds.b	230*160
fullscr4	ds.b	230*160
fullscr5	ds.b	230*160
