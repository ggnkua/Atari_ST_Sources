;	opt	L5
	opt	o+,ow2-
	OUTPUT	FIN.PRG
;
; meilleures couleurs :
;	1=vert clair
;	4=bleu clair
;	6=blanc
;	14=orange clair
;	15=jaune
;
symetrie=224-24-1
FINAL=0			;0=FINAL
color=15
fast_coeur=0
depart=112/8*16-64+8
arrivee=112-5-3
fastcopy=0		;0=copie en user
nb_coeurs=14
tailley=80-8		;taille du bonhomme
plusrapide=1
DEBUG=1-FINAL		;0=debugger
PRG=1			;0=.PRG
DOWNLOAD=1-FINAL
ecran0=$80000-32000
ecran1=ecran0-32000
ramtop=ecran1
hauteur=176
largeur=224
basemfp=$40
;
	rsreset
cpt2		rs.w	1
dist		rs.w	1
compteur	rs.w	1
long		rs.b	0
;
WAITVBL:MACRO
	moveq	#\1,d0
.\@:
	cmp	sync.w,d0
	bhi.s	.\@
	clr	sync.w
	ENDM

CPU	MACRO
	tst.b	TAB.w
	beq.s	.\@
	move	#\1,$ffff8240.w
.\@
	ENDM

	IFEQ	FINAL
	section	text
	movem.l	moveit(pc),d0-d7
	movem.l	d0-d7,$70600-32

	lea	code(pc),a0
	lea	debutcode,a1
	move.l	a1,a2
	move	#(fincode-debutcode)/4,d0
	jmp	$70600-32
moveit:	move.l	(a0)+,(a1)+
	dbra	d0,moveit
	jmp	(a2)
	ENDC

	IFEQ	PRG
	section	text
;
; d‚placement du programme en $800
;
	move	sr,d0
	and	#$2000,d0
	bne.s	super
	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp
super:
	move	#$2700,sr
	lea	code(pc),a0
	lea	$800.w,a1
	lea	fincode,a2

	lea	$80000,sp
	movem.l	moveit(pc),d0-d7
	movem.l	d0-d7,-(sp)
	jmp	(sp)

moveit:	move.l	(a0)+,(a1)+
	MOVE	A0,$FFFF8240.W
	cmp.l	a2,a1
	blo.s	moveit
	jmp	$800.w
	ENDC

	offset	$800
startclear:
touches		ds.b	$80-2
joystick0	ds.b	1
joystick1	ds.b	1
ecran:		ds.l	1
sync:		ds.w	1
nbvbl:		ds.w	1
TAB:		ds.b	1
affpic:		ds.b	1
	even
mul160:		ds.w	hauteur
flag:		ds.w	1
flag2:		ds.w	1
coordx:		ds.w	1
nbplan:		ds.w	1
onemore:	ds.w	1
cpt:		ds.w	1
count:		ds.w	1
etape:		ds.w	1
decalages_fleurs:ds.l	8
decalages_map:	ds.l	16
decalages_homme:ds.l	16
topram:		ds.l	1
fade:		ds.w	1	;0=no fade
				;1=fade in
				;-1=fade out
tint:		ds.w	1	;0=couleur d‚part
countfade:	ds.w	1
bobcoeur:	ds.b	long*17
vary:		ds.w	1
diry:		ds.w	1
ptrpal:		ds.l	1
;
ptr1:		ds.l	1
duree:		ds.w	1

posx:		ds.w	1
posy:		ds.w	1
ptrmes:		ds.l	1
divmess:	ds.w	1
palette:	ds.w	16

	ifeq	fast_coeur
coeurs_decale:
	ds.l	16*nb_coeurs
	endc
endclear:
	LIST
	even
	NOLIST
	section	text
code:
	org	$10000
pile:
debutcode:
	move	#$2700,sr
	moveq	#0,d0
	move.l	d0,a0
	movep.l	d0,$fffffa01(a0)
	movep.l	d0,$fffffa09(a0)
	movep.l	d0,$fffffa11(a0)
	movep.l	d0,$fffffa19(a0)

	lea	pile(pc),sp

	lea	startclear.w,a0
	move	#(endclear-startclear)/4,d0
clearvar:clr.l	(a0)+
	dbra	d0,clearvar

	move.l	#ecran0,d0
	move.l	d0,ecran.w
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	ifeq	DEBUG
	bsr	debugger
	endc

	bsr	initkbd
	clr.b	TAB.w
;
; initialisations avant lancement programme
;
	LEA	mul160.w,a0
	moveq	#24,d0
	move	#hauteur-1,d1
.mul160	move	d0,(a0)+
	add	#160,d0
	dbra	d1,.mul160

	move.l	#vbl,$70.w
	clr	fade.w

	moveq	#1,d0
	bsr	musique

	move	#$2300,sr

	lea	ramtop,a0
	lea	$80000,a1
	moveq	#0,d0
fill_mem:move.l	d0,(a0)+
	cmp.l	a1,a0
	blo.s	fill_mem
	clr	tint.w
	clr	countfade.w

	clr	nbvbl.w
bc:	tst	nbvbl.w
	beq.s	bc
	clr.b	$ffff8260.w
	move.b	#2,$ffff820a.w
restart:
	bsr	predecale_tout
.no3
	tst	fade.w
	bne.s	.no3

	clr	sync.w
	clr.b	affpic.w
	move.l	#realpalette,ptrpal.w
	move	#1,fade.w
	clr	etape.w
	move	#depart,flag.w
	clr	flag2.w
	clr	cpt.w
	clr	count.w
	move	#-32,coordx.w
;
; affichage du THE END en bas
;
	lea	the_end,a0
	lea	ecran0+178*160+(160-$30)/2,a1
	lea	ecran1+178*160+(160-$30)/2,a2
	moveq	#20-1,d7	;nb lignes
.aff1
	moveq	#$60/2/8-1,d6
.aff2
	move.l	(a0)+,d0
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	addq	#4,a1
	addq	#4,a2
	dbra	d6,.aff2
	lea	160-$60/2(a1),a1
	lea	160-$60/2(a2),a2
	dbra	d7,.aff1

main:
	CPU	$555
	moveq	#1,d0
	cmp	#4,etape.w
	blo.s	.waitvbl
	moveq	#2,d0
.waitvbl:
	cmp	sync.w,d0
	bhi.s	.waitvbl
	clr	sync.w
	clr	$ffff8240.w
	move.l	ecran.w,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w
	eor.l	#ecran0^ecran1,ecran.w

;.waitk	tst.b	touches+$39.w
;	beq.s	.waitk
;	clr.b	touches+$39.w

	move	#$97-1,d0
	move.l	ecran.w,a1
	lea	24(a1),a1

	moveq	#0,d7
	move	flag.w,d7
	cmp	#3,etape.w
	bhs.s	.noscr1
	addq	#1,d7		;scrolle de 1 en 1
	divu	#112/8*16,d7
	swap	d7
	move	d7,flag.w
.noscr1:
	moveq	#15,d6
	and	d7,d6
	eor	d6,d7
	add	d6,d6
	add	d6,d6
	lea	decalages_map.w,a0
	move.l	(a0,d6.w),a0

	lsr	#2,d7
	bsr	affiche
;
; affichage des fleurs
;
; a1 positionn‚
;
	moveq	#$19-1,d0

	moveq	#0,d7
	move	flag2.w,d7
	cmp	#3,etape.w
	bhs.s	.noscr2
	addq	#1,d7		;scrolle de 1 en 1
	divu	#112/8*8,d7
	swap	d7
	move	d7,flag2.w
.noscr2
	moveq	#7,d6
	eor	d6,d7
	and	d7,d6
	eor	d6,d7
	add	d6,d6
	add	d6,d6
	lea	decalages_fleurs.w,a0
	move.l	(a0,d6.w),a0

	lsr	#1,d7
	bsr	affiche

	move	etape.w,-(sp)

	CPU	$070

	bsr	gere_homme
	CPU	$700

	bsr	gere_femme

	CPU	$007
	move	(sp)+,d0
	cmp	#4,d0
	blo	main
	lea	IMAGEHOMME+8(pc),A0
	bsr	affiche_bonhomme

	WAITVBL	10
	move.l	ecran.w,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w
;	WAITVBL	10

	lea	fincode,a6
	ifeq	fastcopy
	moveq	#0,d7

;	movem.l	(a6)+,d0-d7/a0-a5
;	movem.l	d0-d7/a0-a5,-1(a7)

.gen
	move.l	#$4cde3fff,(a6)+
	move.l	#$48ef3fff,(a6)+
	move	d7,(a6)+
	add	#56,d7
	move.l	#$4cde3fff,(a6)+
	move.l	#$48ef3fff,(a6)+
	move	d7,(a6)+
	add	#160-56,d7
	cmp	#160*hauteur,d7
	blo.s	.gen
	move	#$4afc,(a6)+
	endc

	move.l	ecran.w,a0		;source
	lea	24(a0),a0
	move.l	a6,ptr1.w
	move	#hauteur-1,d1
.push
	moveq	#largeur/2/4-1,d0
.push2
	move.l	(a0)+,(a6)+
	dbra	d0,.push2
	lea	160-112(a0),a0
	dbra	d1,.push

	ifeq	fast_coeur
;
; a6=d‚but m‚moire libre
;
	bsr	genere_coeurs
	endc

	bsr	initcoeurs
	bsr	init_message
	move	#800,duree.w
	clr	sync.w
	WAITVBL	1
.bcl2
	eor.l	#ecran0^ecran1,ecran.w

	ifeq	fastcopy
	move.l	#.ret,$10.w

	moveq	#24,d0
	add.l	ecran.w,d0
	move	#$300,sr
	move.l	ptr1.w,a6
	move.l	d0,a7
	jmp	fincode
.ret
	addq	#6,sp
	elseif
	move.l	ptr1,a0
	move.l	ecran.w,a1
	lea	24(a1),a1
	move	#hauteur-1,d0
	bsr	display0
	endc
	bsr	affiche_message
	CPU	$070
	bsr	animcoeurs
	CPU	$555
	WAITVBL	1
	cmp	#16,duree.w
	bne.s	.nofade
	move	#-1,fade.w
.nofade
	move.l	ecran.w,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w
	clr	$ffff8240.w

	subq	#1,duree.w
	bne.s	.bcl2

	bra	restart

	eor.l	#ecran0^ecran1,ecran.w
	move.l	ecran.w,a0
	move	#200*160/4-1,d0
	moveq	#0,d1
.cls	move.l	d1,(a0)+
	dbra	d0,.cls

	lea	pic,a0
	move.l	ecran.w,a1
	lea	((200-$ad)/2)*160+24(a1),a1
	move	#$ad-1,d7		;nb lignes
.loopy
	moveq	#$d0/16-1,d6		;nb colonnes
.loopx
	move.l	(a0)+,(a1)+
	move	(a0)+,(a1)+
	addq	#2,a1
	dbra	d6,.loopx
	lea	160-$d0/2(a1),a1
	dbra	d7,.loopy

	lea	fincode,a6
	move.l	#$33580006,d0
.genmov:move.l	d0,(a6)+
	addq	#8,d0
	cmp	#32000,d0
	blo.s	.genmov
	move	#$4e75,(a6)+

.wfade	tst	fade.w
	bne.s	.wfade
	move.l	#secondpal,ptrpal.w
	st	affpic.w
	move	#1,fade.w
	clr	sync.w
	WAITVBL	1
	move.l	ecran.w,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w

.wspc
	CPU	$700
	lea	fincode,a0
	move.l	ecran.w,a1
;	jsr	fincode
	CPU	$555
	WAITVBL	1

	tst.b	touches+$39.w
	beq.s	.wspc
	clr.b	touches+$39.w

	move	#-1,fade.w
.wfade2
	tst	fade.w
	bne.s	.wfade2

	move.l	ecran.w,a0
	move	#32000/4-1,d0
	moveq	#0,d1
.cls2	move.l	d1,(a0)+
	dbra	d0,.cls2

	bra	restart
gere_homme:
	move	etape.w,d0
	add	d0,d0
	add	d0,d0
	jmp	.stages(pc,d0.w)
.stages
	bra.w	.etape0
	bra.w	.etape1
	bra.w	.etape2
	bra.w	.etape3
	bra.w	.etape4
	illegal
.etape4:
.etape0:rts
.etape1:
	tst	fade.w
	bne.s	.etape11
	move	#1,fade.w
	addq	#1,etape.w
.etape11:
	rts
.etape2:
;
; affichage d'un sprite 80*80 (homme)
;
;	move	#224+16,d1
;	sub	flag.w,d1
	move	#symetrie,d1
	sub	coordx.w,d1

	cmp	#arrivee,d1
	bhi.s	.nohomme
	addq	#1,etape.w
	move	#10,cpt.w
.nohomme:
.etape3:
;	move	#224+16,d1
;	sub	flag.w,d1
	move	#symetrie,d1
	sub	coordx.w,d1

	move	#$97-tailley,d2	;y
	clr	d3
	move.b	IMAGEHOMME+4(pc),d3
	move	#tailley,d4
	bra	affiche_homme

;.etape3:
;	lea	IMAGEHOMME(pc),A0
;	bra	affiche_bonhomme

gere_femme:
	move	etape.w,d0
	add	d0,d0
	add	d0,d0
	jmp	.stages(pc,d0.w)
.stages
	bra.w	.etape0
	bra.w	.etape1
	bra.w	.etape2
	bra.w	.etape3
	bra.w	.etape4
	illegal
.etape0:
	bsr.s	affichecourse
	addq	#1,coordx.w
	cmp	#largeur,coordx.w
	ble.s	.goodx
	addq	#1,etape.w
	move	#-32,coordx.w
	move	#-1,fade.w
.goodx
	rts
.etape1:
	rts
.etape2:
	bsr.s	affichecourse
	addq	#1,coordx.w
	rts
.etape3:
	bsr.s	affiche_arret
	subq	#1,cpt.w
	bne.s	.nochg
	addq	#1,etape.w
	move	#100,cpt.w
.nochg	rts

.etape4:
	bra.s	affiche_arret

affiche_bonhomme
	move.l	(a0)+,a6	;ptr bitmap
	clr	d3
	move.b	(a0)+,d3	;dX
	clr	d4
	move.b	(a0)+,d4	;dY
	subq	#8,d4

	move.b	(a0)+,d2
	ext	d2
;	move	#224+16,d1
;	sub	flag.w,d1

	move	#symetrie,d1
	sub	coordx.w,d1

	add	d2,d1

	move	#$97,d2
	sub	d4,d2
	bra	bob

affiche_arret:
	moveq	#5,d0
	bra.s	affichemeuf
affichecourse:
;
	move	cpt.w,d0
	subq	#1,count.w
	bpl.s	.low
	move	#6-1,count.w
	addq	#1,d0
	cmp	#5,d0
	blo.s	.low
	clr	d0
.low	move	d0,cpt.w
affichemeuf
	asl	#3,d0
	lea	IMAGEFEMME(pc),A0
	add	d0,a0

	move.l	(a0)+,a6	;ptr bitmap
	clr	d3
	move.b	(a0)+,d3	;dX
	clr	d4
	move.b	(a0)+,d4	;dY

	move.b	(a0)+,d1
	ext	d1
	add	coordx.w,d1

	move	#$97,d2
	sub	d4,d2
	bra	bob

initcoeurs:
	lea	bobcoeur.w,a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#17-1,d7
initl:
	move	d0,cpt2(a0)
	move	d1,compteur(a0)
	move	#800,dist(a0)		;OFSET

	add	#30,d0
	addq	#2,d1
	cmp	#nb_coeurs*2,d1
	blo.s	tot
	moveq	#0,d1
tot:
	lea	long(a0),a0
	dbf	d7,initl
	move	#100,vary.w
	move	#-1,diry.w
	rts

animcoeurs:
	lea	bobcoeur.w,a0
	moveq	#17-1,d7
corlo:
	move	compteur(a0),d0
	lsr	#1,d0
	lea	IMAGECOEURS(pc),a2
	asl	#3,d0
	add	d0,a2

	ifeq	fast_coeur
	asl	#6-3,d0
	lea	coeurs_decale.w,a5
	add	d0,a5
	endc

	move.l	(a2)+,a6	;a6=ptr bitmap
	clr	d3
	move.b	(a2)+,d3	;d3=dx
	clr	d4
	move.b	(a2)+,d4	;d4=dy
	move.b	(a2)+,d0
	ext	d0		;recentrage en X

	lea	sinus(pc),a1

	add	cpt2(a0),a1
	move.b	(a1)+,d1
	move.b	(a1)+,d2
	ext	d1
	ext	d2
	move	dist(a0),d6
	muls	vary.w,d1
	muls	vary.w,d2
	divs	d6,d1
	divs	d6,d2

	add	d0,d1
	add	#112,d1		;d1=X
	add	#76+8,d2	;d2=Y
	sub	d4,d2

	ifeq	fast_coeur
	moveq	#$f,d0
	and	d1,d0
	eor	d0,d1
	add	d0,d0
	add	d0,d0
	move.l	(a5,d0.w),a1
	asr	#1,d1
	move.l	ecran.w,a2
	add	d2,d2
	lea	mul160.w,a3
	add	(a3,d2.w),a2
	add	d1,a2
;
; d1=X
; d2=Y
; d3=dX
; d4=dY	(toujours 15)
;
	jsr	(a1)

	elseif

	movem.l	d7/a0,-(sp)
	bsr	bob
	movem.l	(sp)+,d7/a0
	endc

	addq	#1,compteur(a0)
	cmp	#nb_coeurs*2,compteur(a0)
	blo.s	.goodc
	clr	compteur(a0)
.goodc

	addq	#2,cpt2(a0)
	and	#511,cpt2(a0)

	cmp	#100,dist(a0)
	bmi.s	nored
	subq	#4,dist(a0)
nored:
	lea	long(a0),a0
	dbf	d7,corlo

	move	diry.w,d0
	add	vary.w,d0
	move	d0,vary.w

	cmp	#1,d0
	bpl.s	aaa
	neg	diry.w
aaa:	cmp	#100,d0
	bmi.s	bbb
	neg	diry.w
bbb:	rts

init_message:
	clr	posx.w
	clr	posy.w
	move.l	#message,ptrmes.w
	clr	divmess.w
	rts
affiche_message:
	add	#65536/2,divmess.w
	bcc.s	.fini
	move.l	ptrmes.w,a0
	clr	d0
	move.b	(a0)+,d0
	bmi.s	.fini
	move.l	a0,ptrmes.w
	tst.b	d0
	bne.s	.not0
	clr	posx.w
	addq	#1,posy.w
.fini	rts
.not0
	sub.b	#' ',d0
	asl	#3,d0
	lea	fonte(pc),a0
	add	d0,a0

	move	posy.w,d0
	mulu	#112*8,d0
	move.l	ptr1.w,a1
	add	d0,a1
	move	posx.w,d0
	lsr	#1,d0
	bcc.s	.pair
	addq	#1,a1
.pair
	asl	#3,d0
	add	d0,a1
	move.l	a1,a2
	move	a2,d0
	lsr	#1,d0
	bcc.s	.pair2
	addq	#6,a2
.pair2	addq	#1,a2

	moveq	#8-1,d7
	moveq	#$7f,d6
.loop
	move.b	(a0)+,d0
	move	d0,d2
	lsr.b	#1,d2
	bcc.s	.bit0
	and.b	d6,(a2)
	and.b	d6,2(a2)
	and.b	d6,4(a2)
	and.b	d6,6(a2)
	and.b	d6,112(a2)
	and.b	d6,112+2(a2)
	and.b	d6,112+4(a2)
	and.b	d6,112+6(a2)
.bit0
	not.b	d2
	and.b	d2,(a1)
	and.b	d2,2(a1)
	and.b	d2,4(a1)
	and.b	d2,6(a1)
	and.b	d2,112(a1)
	and.b	d2,112+2(a1)
	and.b	d2,112+4(a1)
	and.b	d2,112+6(a1)

	move	d0,d1
	not	d1

	ifeq	color&%0001
	and.b	d1,(a1)
	elseif
	or.b	d0,(a1)
	endc

	ifeq	color&%0010
	and.b	d1,2(a1)
	elseif
	or.b	d0,2(a1)
	endc

	ifeq	color&%0100
	and.b	d1,4(a1)
	elseif
	or.b	d0,4(a1)
	endc

	ifeq	color&%1000
	and.b	d1,6(a1)
	elseif
	or.b	d0,6(a1)
	endc

	lea	112(a1),a1
	lea	112(a2),a2
	dbra	d7,.loop

	addq	#1,posx.w
	rts
	ifeq	fast_coeur
genere_coeurs:
	lea	IMAGECOEURS,a0	;source
	lea	coeurs_decale.w,a1
	moveq	#nb_coeurs-1,d7
.c1
	moveq	#0,d6		;d‚calage
.c2
	move.l	a6,(a1)+
	moveq	#15-1,d5	;nb lignes verticalement
	move.l	(a0),a2
	sub.l	a5,a5		;offset ‚cran
.c3
	moveq	#0,d0
	move	(a2)+,d0
	ror.l	d6,d0
	moveq	#0,d1
	move	(a2)+,d1
	ror.l	d6,d1
	moveq	#0,d2
	move	(a2)+,d2
	ror.l	d6,d2
	moveq	#0,d3
	move	(a2)+,d3
	ror.l	d6,d3
	move	d0,d4
	or	d1,d4
	or	d2,d4
	or	d3,d4
	not	d4

	bsr.s	genins
	addq	#8,a5

	swap	d0
	swap	d1
	swap	d2
	swap	d3

	move	d0,d4
	or	d1,d4
	or	d2,d4
	or	d3,d4
	not	d4
	bsr.s	genins
	lea	160-8(a5),a5

	dbra	d5,.c3

	move	#$4e75,(a6)+
	addq	#1,d6
	cmp	#16,d6
	blo.s	.c2

	addq	#8,a0
	dbra	d7,.c1
	rts
genins:
	movem.l	d0/d2,-(sp)
	swap	d0
	move	d4,d0
	swap	d4
	move	d0,d4

	move	d1,d0
	swap	d2
	move	d3,d2

	tst.l	d4
	beq.s	.bigbug
	not.l	d4
	beq.s	.nothing

	cmp.l	d4,d0
	beq.s	.noand1

	tst.l	d0
	beq.s	.0

	bsr.s	genand1
	bra.s	.01
.0
	bsr.s	genand2
	bra.s	.00
.noand1
	tst.l	d0
	beq.s	.00
.01	bsr.s	genor1
.00

	addq	#4,a5
	cmp.l	d4,d2
	beq.s	.noand2
	tst.l	d2
	beq.s	.bigbug
	bsr.s	genand1
	bra.s	.1
.noand2
	tst.l	d2
	beq.s	.bigbug
.1	bsr.s	genor2
	subq	#4,a5

.nothing
	movem.l	(sp)+,d0/d2
	rts
.bigbug:dc.l	$4a780001

genand1:
	cmp	#0,a5
	beq.s	.goodoff

	move	#$45ea,(a6)+
	move	a5,(a6)+
	sub.l	a5,a5
.goodoff
;	move	#$02aa,(a6)+	;and.l #xxx,d(a2)
	move	#$0292,(a6)+	;and.l #xxx,d(a2)
	not.l	d4
	move.l	d4,(a6)+	;mask
	not.l	d4
;	move	a5,(a6)+
	rts
genand2:
	cmp	#0,a5
	beq.s	.goodoff

	move	#$45ea,(a6)+
	move	a5,(a6)+
	sub.l	a5,a5
.goodoff
;	move	#$02aa,(a6)+	;and.l #xxx,d(a2)
	move	#$029a,(a6)+	;and.l #xxx,d(a2)
	not.l	d4
	move.l	d4,(a6)+	;mask
	not.l	d4
	subq	#4,a5
;	move	a5,(a6)+
	rts
genor1:
	cmp	#0,a5
	beq.s	.goodoff

	move	#$45ea,(a6)+
	move	a5,(a6)+
	sub.l	a5,a5
.goodoff
	move	#$009a,(a6)+	;or.l #xxx,(a2)+
	move.l	d0,(a6)+	;plan0 et 1
	subq	#4,a5
	rts
genor2:
	cmp	#0,a5
	beq.s	.goodoff

	move	#$45ea,(a6)+
	move	a5,(a6)+
	sub.l	a5,a5
.goodoff
	move	#$009a,(a6)+	;or.l #xxx,(a2)+
	move.l	d2,(a6)+	;plan2 et 3
	subq	#4,a5
	rts
	endc

vbl:
	addq	#1,nbvbl.w
	movem.l	d0-d7/a0-a6,-(sp)

	bsr	fondu
	movem.l	palette.w,d0-d7
	movem.l	d0-d7,$ffff8240.w

	bsr	musique+4

	tst.b	touches+$f.w
	beq.s	.notab
	clr.b	touches+$f.w
	not.b	TAB.w
.notab
	ifeq	DEBUG
	tst.b	touches+$e.w
	beq.s	.noplantage
	dc.l	$4a780001
.noplantage
	endc

	IFNE	FINAL
	tst.b	touches+$1d.w	;CTRL
	beq.s	.noreset
	tst.b	touches+$2e.w	;C
	beq.s	.noreset

	IFEQ	DOWNLOAD
	MOVE.L	#$06060000,$FFFF8800.W
	MOVE.L	#$08080000,$FFFF8800.W
	MOVE.L	#$09090000,$FFFF8800.W
	MOVE.L	#$0A0A0000,$FFFF8800.W
	JMP	UPLOAD
.NOUPL
	ELSE
	clr.l	$426.w
	move.l	4.w,a0
	jmp	(a0)
	ENDC
.noreset
	ENDC

	clr.b	$fffffa1b.w
	move.l	#hbl,basemfp+$20.w
	or.b	#1,$fffffa07.w
	or.b	#1,$fffffa13.w
	move.b	#176,$fffffa21.w
	move.b	#8,$fffffa1b.w

	movem.l	(sp)+,d0-d7/a0-a6
	rte
hbl:
	clr.b	$fffffa1b.w
	addq	#1,sync.w
	tst.b	affpic.w
	bne.s	.nocol
	move.l	#$07620213,$ffff8242.w
	rte
.nocol
	clr.l	$ffff8242.w
	rte

;basemfp	equ	$40
;
; am‚liorations possible :
;	- mettre le tableau touches … une adresse multiple de 256
;	  (ca fait gagner l'empilement de a0)
;	- mettre ces routines dans le bas de la m‚moire
;	  (changement du vecteur par MOVE.W)
;	- d‚gager TST.B au d‚but
;	- enlever la routine JOYST0 !!!
;
;	offset	$100
;touches		ds.b	$80-2
;joystick0	ds.b	1
;joystick1	ds.b	1
;	section	text
;
; nouvelle routine de clavier (trŠs) optimis‚e
;
initkbd:
	move.b	#$10,$fffffa17.w

.videkey
	tst.b	$fffffc00.w
	bpl.s	.vide
	tst.b	$fffffc02.w
	bra.s	.videkey
.vide
	move.b	#3,$fffffc00.w
	move.b	#$96,$fffffc00.w

.wikbd	btst	#1,$fffffc00.w
	beq.s	.wikbd
	move.b	#$12,$fffffc02.w	;d‚sactiver souris

	move.l	#kbd,basemfp+$18.w
	or.b	#$40,$fffffa09.w
	or.b	#$40,$fffffa15.w

	lea	touches.w,a0
	moveq	#($80-2)/2-1,d0
	moveq	#0,d1
.clear	move	d1,(a0)+
	dbra	d0,.clear
	clr.b	joystick0.w
	clr.b	joystick1.w
	rts

keybug:	move	#$2700,sr
1$	addq	#7,$ffff8240.w
	bra.s	1$
kbd:
	tst.b	$fffffc00.w
	bpl.s	keybug
	move	d0,-(sp)
;	clr	d0
;	move.b	$fffffc02.w,d0
;	addq.b	#2,d0
	move	#2,d0
	add.b	$fffffc02.w,d0
	bcs.s	codefe
	pea	(a0)
	bclr	#7,d0
	movea	d0,a0
	seq	touches-2(a0)
	move.l	(sp)+,a0
	move	(sp)+,d0
	rte
codefe:
	bne.s	keyff
	move.l	#joyst0,basemfp+$18.w
	move	(sp)+,d0
	rte
keyff	move.l	#joyst1,basemfp+$18.w
	move	(sp)+,d0
	rte
joyst0:
	move.b	$fffffc02.w,joystick0.w
	move.l	#kbd,basemfp+$18.w
	rte
joyst1:
	move.b	$fffffc02.w,joystick1.w
	move.l	#kbd,basemfp+$18.w
	rte

movem8	macro
	move.l	(a0)+,\1(a1)
	move.l	(a0)+,\1+4(a1)
	endm

movem16	macro
	movem.l	(a0)+,d1-d4
	movem.l	d1-d4,\1(a1)
	endm

movem24	macro
	movem.l	(a0)+,d1-d6
	movem.l	d1-d6,\1(a1)
	endm

movem32	macro
	movem.l	(a0)+,d1-d7/a2
	movem.l	d1-d7/a2,\1(a1)
	endm

movem40	macro
	movem.l	(a0)+,d1-d7/a2-a4
	movem.l	d1-d7/a2-a4,\1(a1)
	endm

movem48	macro
	movem.l	(a0)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,\1(a1)
	endm

affiche:
	jmp	.code(pc,d7.w)
.code:
	bra.w	display0
	bra.w	display8
	bra.w	display16
	bra.w	display24
	bra.w	display32
	bra.w	display40
	bra.w	display48
	bra.w	display56
	bra.w	display64
	bra.w	display72
	bra.w	display80
	bra.w	display88
	bra.w	display96
	bra.w	display104

display0:
.loop
	movem48	0
	movem48	12*4
	movem16	12*4*2
	lea	160(a1),a1
	dbra	d0,.loop
	rts

display8:
.loop
	movem8	224/2-8
	movem48	0
	movem48	12*4
	movem8	12*4*2
	lea	160(a1),a1
	dbra	d0,.loop
	rts

display16:
.loop
	movem16	224/2-8*2
	movem48	0
	movem48	12*4
	lea	160(a1),a1
	dbra	d0,.loop
	rts

display24:
.loop
	movem24	224/2-8*3
	movem48	0
	movem40	12*4
	lea	160(a1),a1
	dbra	d0,.loop
	rts

display32:
.loop
	movem32	224/2-8*4
	movem48	0
	movem32	12*4
	lea	160(a1),a1
	dbra	d0,.loop
	rts

display40:
.loop
	movem40	224/2-8*5
	movem48	0
	movem24	12*4
	lea	160(a1),a1
	dbra	d0,.loop
	rts

display48:
.loop
	movem48	224/2-8*6
	movem48	0
	movem16	12*4
	lea	160(a1),a1
	dbra	d0,.loop
	rts

display56:
.loop
	movem8	224/2-8*6-8
	movem48	224/2-8*6
	movem48	0
	movem8	12*4
	lea	160(a1),a1
	dbra	d0,.loop
	rts

display64:
.loop
	movem16	224/2-8*6-8*2
	movem48	224/2-8*6
	movem48	0
	lea	160(a1),a1
	dbra	d0,.loop
	rts

display72:
.loop
	movem24	224/2-8*6-8*3
	movem48	224/2-8*6
	movem40	0
	lea	160(a1),a1
	dbra	d0,.loop
	rts

display80:
.loop
	movem32	224/2-8*6-8*4
	movem48	224/2-8*6
	movem32	0
	lea	160(a1),a1
	dbra	d0,.loop
	rts

display88:
.loop
	movem40	224/2-8*6-8*5
	movem48	224/2-8*6
	movem24	0
	lea	160(a1),a1
	dbra	d0,.loop
	rts

display96:
.loop
	movem48	224/2-8*6-8*6
	movem48	224/2-8*6
	movem16	0
	lea	160(a1),a1
	dbra	d0,.loop
	rts

display104:
.loop
	movem8	224/2-8*6-8*6-8
	movem48	224/2-8*6-8*6
	movem48	224/2-8*6
	movem8	0
	lea	160(a1),a1
	dbra	d0,.loop
	rts

predecale_tout:
predecale_map:
	lea	map,a5		;source
	lea	fincode,a6	;dest
	lea	decalages_map.w,a4
	move.l	a5,(a4)+
	moveq	#15-1,d7	;nb images … d‚caler
.loop1
	move.l	a6,a3
	move.l	a6,(a4)+
	move	#$97-1,d6	;nb lignes … pr‚d‚caler
.loop2
	moveq	#4-1,d5		;nb plans … pr‚d‚caler
	clr	d2		;constante
.loop3
	move	112-8(a5),d1
	add	d1,d1
x	set	112
	rept	112/8
x	set	x-8
	move	x(a5),d0
	addx	d0,d0
	move	d0,x(a6)
	endr

	ifne	x
	fail
	endc

	addx	d2,d1
	move	d1,112-8(a6)
	addq	#2,a5
	addq	#2,a6
	dbra	d5,.loop3
	subq	#8,a5
	subq	#8,a6

	lea	224/2(a5),a5
	lea	224/2(a6),a6
	dbra	d6,.loop2
	move.l	a3,a5
	dbra	d7,.loop1
;
; d‚calage des fleurs en bas...
;
;	a6=fin de la m‚moire pr‚d‚cal‚e
;
decale_fleurs:
	lea	fleurs,a5	;source
	lea	decalages_fleurs.w,a4
	move.l	a5,(a4)+
	move	#$c000,d4
	moveq	#7-1,d7		;nb images … d‚caler
.loop1
	move.l	a6,a3
	move.l	a6,(a4)+
	moveq	#$19-1,d6	;nb lignes … pr‚d‚caler
.loop2
	moveq	#4-1,d5		;nb plans … pr‚d‚caler
.loop3
	move	(a5),d1
	ror	#2,d1
	move	d1,d3
	and	d4,d3
	eor	d3,d1

x	set	8
	rept	112/8-1
	move	x(a5),d0
	ror	#2,d0

	eor	d3,d0
	eor	d0,d3
	and	d4,d3
	eor	d3,d0

	move	d0,x(a6)
x	set	x+8
	endr

	ifne	x-112
	fail
	endc

	or	d3,d1
	move	d1,(a6)
	addq	#2,a5
	addq	#2,a6
	dbra	d5,.loop3
	subq	#8,a5
	subq	#8,a6

	lea	224/2(a5),a5
	lea	224/2(a6),a6
	dbra	d6,.loop2
	move.l	a3,a5
	dbra	d7,.loop1
;
; routine efficace de pr‚d‚calage de sprites...
;	sans calcul de masque
;
; entr‚e :
;	a6=ptr ram libre
;
predecale_homme

const	equr	d2
reste1	equr	d4
reste2	equr	d5
cptplan	equr	d7

	lea	IMAGEHOMME(pc),A5
	lea	decalages_homme.w,a4

	moveq	#0,d6
1$
;	tst	d6
;	bne.s	.nostock
;	move.l	(a5),(a4)+	;pointeur bitmap quand d‚calage de 0 !!!!
;	bra	.optim
;.nostock
	move.l	a6,(a4)+	;poke pointeur bitmap

	move.l	(a5),a3
	move.b	4(a5),d2
	subq.b	#1,d2
	and	#$f,d2		;nb pixels … droite
	clr	d0
	move.b	4(a5),d0
	move	#tailley,d1

	add	#15,d0
	lsr	#4,d0

	move	d0,nbplan.w	;nbplan=d0 et nblig=d1

	clr	onemore.w
	add	d6,d2		;nb pixels aprŠs d‚calage=nb pixels+d‚calage
	cmp	#16,d2		;est-ce que ‡a rajoute un plan ??
	blo.s	7$
	st	onemore.w
	addq	#1,d0
7$
;
;	d0=nb plans (minimum : 1 !!!)
;	d1=nb lignes
;
	lea	planes(pc),a1
	move	d6,const
	add	const,const
	add	const,const
	move.l	(a1,const.w),const

	subq	#2,nbplan.w
2$
	move.l	(a3)+,d0
	ror.l	d6,d0
	move.l	d0,reste1
	and.l	const,reste1
	eor.l	reste1,d0
	move.l	d0,(a6)+

	move.l	(a3)+,d0
	ror.l	d6,d0
	move.l	d0,reste2
	and.l	const,reste2
	eor.l	reste2,d0
	move.l	d0,(a6)+

	move	nbplan.w,cptplan
	bmi.s	4$
3$
	swap	reste1
	swap	reste2

	move.l	(a3)+,d0
	ror.l	d6,d0
	eor.l	reste1,d0
	eor.l	d0,reste1
	and.l	const,reste1
	eor.l	reste1,d0
	move.l	d0,(a6)+

	move.l	(a3)+,d0
	ror.l	d6,d0
	eor.l	reste2,d0
	eor.l	d0,reste2
	and.l	const,reste2
	eor.l	reste2,d0
	move.l	d0,(a6)+

	dbra	cptplan,3$
4$
	tst	onemore.w
	beq.s	5$

	swap	reste1
	swap	reste2

	move.l	reste1,(a6)+
	move.l	reste2,(a6)+
5$
	subq	#1,d1		;dec nblig
	bne.s	2$
.optim
	addq	#1,d6
	cmp	#16,d6
	blo	1$
	move.l	a6,topram.w
;
; masquage de l'homme avec le fond...
;
	lea	decalages_homme.w,a6
	lea	decalages_map.w,a5
	moveq	#0,d7
	lea	IMAGEHOMME(pc),A4
.msk1
	moveq	#$f,d0
	add.b	4(a4),d0
	add	d7,d0
	lsr	#4,d0
	move	#tailley-1,d1
;
;	d0=nb plans (minimum : 1 !!!)
;	d1=nb lignes-1
;
	move.l	(a6)+,a0	;ptr sprite homme

	move	d7,d2
	neg	d2
	and	#$f,d2
	add	d2,d2
	add	d2,d2
	move.l	(a5,d2.w),a1	;ptr fond
	tst	d2
	bne.s	.ok
	addq	#8,a1
.ok

	lea	($97-tailley)*112(a1),a1
	subq	#1,d0
.msk2
	move.l	a1,a2
	move	d0,d2
.msk3
	move.l	(a0)+,d3
	move.l	(a0)+,d4
	move.l	d3,d5
	or.l	d4,d5
	move.l	d5,d6
	swap	d6
	or.l	d6,d5
	not.l	d5
	move.l	d5,d6

	and.l	(a2)+,d5
	and.l	(a2)+,d6
	or.l	d3,d5
	or.l	d4,d6
	movem.l	d5/d6,-8(a0)

	dbra	d2,.msk3
	lea	112(a1),a1
	dbra	d1,.msk2
	addq	#1,d7
	cmp	#16,d7
	blo.s	.msk1
	rts
planes	DC.L	$00000000,$80008000,$C000C000,$E000E000
	DC.L	$F000F000,$F800F800,$FC00FC00,$FE00FE00
	DC.L	$FF00FF00,$FF80FF80,$FFC0FFC0,$FFE0FFE0
	DC.L	$FFF0FFF0,$FFF8FFF8,$FFFCFFFC,$FFFEFFFE
;
; routine d'affichage des sprites
; nouvelle routine de sprite d‚calant
;
bob:
;
; A6=d‚but du bitmap du sprite
; d1=coord X
; d2=coord Y
; d3=largeur
; d4=hauteur
;
	moveq	#15,d5
	add	d5,d3
	and	d3,d5
	sub	d5,d3

	lsr	#1,d3		;d3=nboctets/ligne … afficher
;
; registres en entr‚e :
;
;	a6=adresse Bitmap du sprite
;	A1=adresse base ‚cran
;	D1=coordonn‚e X haut gauche
;	D2=coordonn‚e Y haut gauche
;	D3=nb octets de largeur=((largeur en pixels+15)and $FFF0)/2
;	D4=hauteur du sprite
;
	cmp	#hauteur,d2
	blo.s	.cliphau
	bge.s	.retsp		;trop en bas
	neg	d2
	sub	d2,d4
	bls.s	.retsp
	mulu	d3,d2
	add	d2,a6
	move	mul160.w,d2
	bra.s	.noclipbas
.retsp	rts
.cliphau
	move	d2,d0
	add	d4,d0

	add	d2,d2
	lea	mul160.w,a1
	move	(a1,d2.w),d2	;d2=offset ‚cran

	sub	#hauteur,d0
	bls.s	.noclipbas
	sub	d0,d4
.noclipbas

	moveq	#$F,d0		;isole d‚calage et efface flags clipping
	and	d1,d0
	add	d0,d5

	sub	d0,d1
	add	d0,d0		;*4
	add	d0,d0

	asr	#1,d1		;(X and $FFF0)/2
	cmp	#largeur/2,d1	;<160 ?
	blo.s	.clipgau
	bge.s	.retsp		;sprite trop … droite
	neg	d1
	sub	d1,d3		;calcule nb plans restants
	blo.s	.retsp
	move	d1,a3
	add	a3,a6
	or.b	#$40,d0		;indique clipping … gauche
	bra.s	.pacl
.clipgau
	sub.l	a3,a3
	add	d1,d2		;offset Y
	add	d3,d1
	sub	#largeur/2,d1	;>nb plans dans une ligne ?
	blo.s	.noclipdro
	tas	d0		;indique clipping … droite
	sub	d1,d3		;calcul nb plans restants
	move	d1,a3
	bra.s	.pacl
.noclipdro
	cmp	#16,d5
	bhs.s	.pacl
	tas	d0
.pacl
	move.l	ecran.w,a1
	add	d2,a1

	move	#160,a2
	sub	d3,a2
	subq	#1,d4
	lsr	#3,d3
;
; entr‚e :
;	d3=nb plans … afficher
;	d4=nb lignes … afficher
;	a6=ptr bitmap sprite
;	a1=ptr bitmap ‚cran
;	a2=incr‚ment pour ‚cran
;	a3=incr‚ment pour sprite
;
	JMP	newsprite(pc,d0.w)
newsprite:
	incbin	e:\includes\sprite.bin
;
; affichage d'un sprite clipp‚ pr‚d‚cal‚
;
; entr‚e :
;	d1=coordx
;	d2=coordy
;	d3=largeur
;	d4=hauteur
;
; affichage d'un sprite plein avec masquage sur les cot‚s
;
fin_fast3:rts
affiche_homme:
	moveq	#$f,d5
	and	d1,d5
	eor	d5,d1
	add	d5,d3		;nb pixels de largeur

	add	d5,d5
	add	d5,d5
	lea	decalages_homme.w,a2
	move.l	(a2,d5.w),a2	;a2=d‚but bitmap

	add	#15,d3
	and	#$FFF0,d3
	lsr	#1,d3		;d3=nboctets/ligne … afficher

	cmp	#hauteur,d2
	blo.s	1$
	bge.s	fin_fast3

	neg	d2
	sub	d2,d4
	bls.s	fin_fast3
	mulu	d3,d2
	add	d2,a2
	move	mul160.w,d2
	bra.s	2$
1$
	move	d2,d0
	add	d4,d0

	lea	mul160.w,a1
	add	d2,d2
	move	(a1,d2.w),d2

	sub	#hauteur,d0
	bls.s	2$
	sub	d0,d4
2$
	asr	#1,d1
	cmp	#largeur/2,d1
	blo.s	3$
	bge.s	fin_fast3
	neg	d1
	sub	d1,d3
	bls.s	fin_fast3
	move	d1,a3		;coefficient de clipping
	add	a3,a2		;+1/2 pour mask
	bra.s	4$
3$
	add	d1,d2		;offset ‚cran
	add	d3,d1
	sub.l	a3,a3
	sub	#largeur/2,d1
	blo.s	4$
	move	d1,a3
	sub	d1,d3
4$
;
; calcul de la nouvelle adresse de branchement
;
; ici :
;
;	d2=offset ‚cran
;	d3=nb plans*8
;	d4=nb lignes
;
	move.l	ecran.w,a1
	add	d2,a1		;adresse ‚cran

	lsr	#1,d3
	subq	#1,d4
	cmp	#tailley-1,d4
	bne.s	.bug
	jmp	newfast2(pc,d3.w)
.bug	dc.l	$4a780001

move8	macro
	move.l	(a2)+,\1(a1)
	move.l	(a2)+,\1+4(a1)
;	movem.l	(a2)+,d0-d1
;	movem.l	d0-d1,\1(a1)
	endm
move16	macro
	movem.l	(a2)+,d0-d3
	movem.l	d0-d3,\1(a1)
	endm
move24	macro
	movem.l	(a2)+,d0-d3/d6-d7
	movem.l	d0-d3/d6-d7,\1(a1)
	endm
move32	macro
	movem.l	(a2)+,d0-d3/d6-d7/a4/a5
	movem.l	d0-d3/d6-d7/a4/a5,\1(a1)
	endm
move40	macro
	movem.l	(a2)+,d0-d3/d5-d7/a4-a6
	movem.l	d0-d3/d5-d7/a4-a6,\1(a1)
	endm

newfast2
	dc.l	$4a780001
	bra.w	.spr16
	bra.w	.spr32
	bra.w	.spr48
	bra.w	.spr64
	bra.w	.spr80
	dc.l	$4a780001
.spr16					;sprite 16 de large
.1
	move8	0
	add.l	a3,a2			;clippe en X
	lea	160(a1),a1
	dbra	d4,.1
	rts
.spr32					;sprite 32 de large
.2
	move16	0
	add.l	a3,a2			;clippe en X
	lea	160(a1),a1
	dbra	d4,.2
	rts
.spr48					;sprite 48 de large
.3
	move24	0
	add.l	a3,a2			;clippe en X
	lea	160(a1),a1
	dbra	d4,.3
	rts
.spr64					;sprite 64 de large
	ifeq	plusrapide
.4
	move32	0
	add.l	a3,a2			;clippe en X
	lea	160(a1),a1
	dbra	d4,.4
	elseif
x	set	0
	rept	tailley
	move32	x
	add.l	a3,a2
x	set	x+160
	endr
	endc
	rts
.spr80					;sprite 64 de large
	move.l	a3,d0
	bne	.bug
x	set	0
	rept	tailley
	move40	x
x	set	x+160
	endr
	rts

.bug	dc.l	$4a780001

;
; fade
;
fondu:
	move	fade.w,d0
	beq.s	.nofondu

	add	#65536/4,countfade.w	;toutes les 2 VBL
	bcc.s	.nofondu

	move	tint.w,d1
	tst	d0
	bmi.s	.fadein
	eor	#7,d1
.fadein
	move.l	ptrpal.w,a0
	lea	palette.w,a1
	moveq	#16-1,d0
.loop
	move	(a0)+,d2

	moveq	#$7,d3
	and	d2,d3

FADE	MACRO
;	cmp	d1,\1
;	bls.s	.\@
;	move	d1,\1
;.\@
	sub	d1,\1
	bhs.s	.\@
	clr	\1
.\@
	ENDM

	FADE	D3
	lsr	#4,d2
	moveq	#$7,d4
	and	d2,d4
	FADE	D4
	lsr	#4,d2
	and	#$7,d2
	FADE	D2
	asl	#4,d2
	add	d4,d2
	asl	#4,d2
	add	d3,d2

	move	d2,(a1)+

	dbra	d0,.loop

	addq	#1,tint.w
	cmp	#8,tint.w
	blo.s	.nofondu
	clr	fade.w
	clr	tint.w
	clr	countfade.w
.nofondu:
	rts

realpalette:
	DC.W	$000,$560,$350,$030,$557,$127,$777,$020
	DC.W	$447,$337,$006,$400,$520,$631,$743,$754
secondpal:
	dc.w	$000,$111,$222,$333,$444,$555,$666,$777
	dcb.w	8,$770

musique:incbin	E:\INCLUDES\TOKI7.BIN

	IFEQ	DOWNLOAD
UPLOAD:	INCBIN	E:\INCLUDES\REMOTE.BIN
	ENDC
	ifeq	DEBUG
debugger:incbin	E:\INCLUDES\debugger.bin
	endc

IMAGEFEMME:
	dc.l	FEMME+0,$24420000
	dc.l	FEMME+$630,$1F430000+$400
	dc.l	FEMME+$A60,$1A430000+$700
	dc.l	FEMME+$E90,$20420000+$200
	dc.l	FEMME+$12B0,$1C430000+$700
	dc.l	FEMME+$16E0,$13430000+$a00
IMAGEHOMME:
	dc.l	HOMME+0,$3C500000
	dc.l	HOMME+$A00,$1B510800

;$E($692)
IMAGECOEURS:
	DC.L	COEURS2+$0,$F0F0000
	DC.L	COEURS2+$78,$F0F0000
	DC.L	COEURS2+$F0,$B0F0200
	DC.L	COEURS2+$168,$70F0400
	DC.L	COEURS2+$1E0,$40F0500
	DC.L	COEURS2+$258,$90F0300
	DC.L	COEURS2+$2D0,$D0F0100
	DC.L	COEURS2+$348,$F0F0000
	DC.L	COEURS2+$3C0,$E0F0000
	DC.L	COEURS2+$438,$C0F0100
	DC.L	COEURS2+$4B0,$70F0400
	DC.L	COEURS2+$528,$40F0600
	DC.L	COEURS2+$5A0,$A0F0300
	DC.L	COEURS2+$618,$D0F0100

message:
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	0
	dc.b	"     YOUR QUEST IS OVER",0
	dc.b	0

	dc.b	" The evil forces have been",0
	dc.b	"  conquered.",0
	dc.b	" TOKI, the warrior,",0
	dc.b	"  embraces his lover MIHO",0
	dc.b	"  in joy.",0
	dc.b	" Now, your quest has ended.",0
	dc.b	" But, can you repeat your",0
	dc.b	"  glory ?",$ff
	even
fonte:	incbin	E:\INCLUDES\fonte.dat

COEURS2:incbin	coeurs2.dat
sinus:	incbin	"coeur.tbl"

HOMME:	incbin	homme.dat
FEMME:	incbin	femme.dat
fleurs:	incbin	fleur.dat
map:	incbin	decor.dat
the_end:incbin	end2.dat
pic:	incbin	pic5.dat
fincode:
