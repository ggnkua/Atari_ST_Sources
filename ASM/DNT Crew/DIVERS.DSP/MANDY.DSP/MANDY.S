	include	tos_030.s
	include	hard_sys.s
;
;Programme d'exploitation de la routine de calcul de Mandelbrot au DSP.
;
;Consultez le fichier DSPXBIOS.TXT pour plus d'information sur la
;programmation de la bibliothŠque de fonction DSP du Xbios...
;
;
;(C)oderight NulloS/DNT-Crew 1993-94
;
	opt	o+
	opt	w-
resolx	equ	128*8		;Taille de la fenˆtre d'affichage
resoly	equ	128*8		;zoom‚ 8 fois.

;test	equ	0		;Si on veut lancer du bureau

	ifd	test
	StartUp	512
	dc.w	$a00a
	clr.l	-(sp)
	Gemdos	Super
	move.l	d0,-(sp)
	bsr.s	mandy
	Gemdos	Super
	dc.w	$a009
	Gemdos	Pterm0
	endc

mandy	movea.l	_sysbase.w,a0	;
	cmpi.w	#$400,2(a0)	;Bonne machine ?
	blt	hello		;
	move.w	#-1,-(sp)		;Sauve la r‚solution actuelle.
	Xbios	-Vsetmode		;
	move.l	d0,(sp)		;
	movea.l	_v_bas_ad.w,a5	;sauve l'adresse vid‚o
	IFND	test
	lea	$400000-320*240*2,a6	;On s'installe sauvagement
	ELSE
	move.l	#endbuffer-320*240*2+256,d0
	clr.b	d0		;Depuis le Gem, un peu plus propre.
	move.l	d0,a6
	ENDC
	moveq	#_65kc,d0		;True-Color 320*200
	bsr	set_rez		;
	exg	a5,a6		;
.setdsp;	move.w	#ability,-(sp)	;On ignore purement et simplement
	pea	codesize/3.w	;l'ability!... car le Xbios aussi!
	pea	codeptr(pc)	;
	Xbios	-Dsp_ExecBoot	;Paf, ex‚cute le programme DSP
	lea	10(sp),sp		;Corrige un grand coup la pile

	move.l	a5,a4		;
	moveq.l	#(resoly*resolx)>>16,d0;Nombre de mots DSP … recevoir,
	swap	d0		;ici tous les pixels.
.getword	moveq	#64,d2		;
	btst	d2,hisr+HST_base.w	;HRDF ?
	beq.s	.getword		;
	sub.l	hrx+HST_base.w,d2	;oui, lire la donn‚e DSP
	moveq	#15,d3		;Transformer la profondeur
	and.w	d2,d3		;trouv‚e par le DSP en un
	ror.w	#4,d3		;pixel true-color valable.
	or.w	d3,d2		;Formule pifom‚trique pour
	rol.w	#5,d2		;avoir un r‚sultat agr‚able
	or.w	d3,d2		;… l'oeil, si possible.
	move.w	d2,-(a4)		;
	subq.l	#1,d0		;
	bne.s	.getword		;
	
DoLoop	lea	Vars+posz(pc),a3	;Maintenant, lance le zooom
	moveq	#0,d0		;
	move.w	(a3),d0		;
	move.w	-(a3),d1		;
	add.w	d1,d0		;
	beq.s	.negz		;Ne cherchez pas trop …
	cmpi.w	#989,d0		;comprendre, ‡a n'a aucune
	bne.s	.okz		;importance, c'est une gestion
.negz	neg.w	d1		;optimis‚e (enfin j'espŠre!)
.okz	move.w	d1,(a3)+		;des paramŠtres z (coeff de zoom)
	move.w	d0,(a3)+		;et position de la fenˆtre de
	addq.l	#1,d0		;visualisation sur l'image
	move.l	d0,d1		;1024*1024 renvoy‚e par le
	ror.l	#8-1,d0		;DSP.
	swap	d0		;
	moveq	#2-1,d5		;
	lea	incy-speedy(a3),a2	;
.deplace	move.l	(a3),d3		;
	move.w	(a3),d2		;
	add.w	d2,d3		;
	bgt.s	.okxy		;
	beq.s	.negxy		;
	moveq	#0,d3		;
.negxy	neg.w	d2		;
.okxy	move.w	#resolx,d4		;
	sub.w	d1,d4		;
	cmp.w	d3,d4		;
	bgt.s	*+6		;
	move.w	d4,d3		;
	neg.w	d2		;
	move.w	d2,(a3)+		;
	move.w	d3,(a3)+		;
	swap	d3		;
	move.l	d0,(a2)+		;
	move.l	d3,(a2)+		;
	dbf	d5,.deplace	;



	move.l	(a3)+,d3		;Positions X et Y de la fenˆtre
	move.l	(a3)+,d2		;sur l'image 1024*1024.
	moveq	#128-1,d7		;128 lignes … afficher
	lea	((16+(184-128)/2)*320*2+(320-128)/2*2.w,a5),a1;adresse ‚cran
putline	move.l	d2,d0		;
	lsr.l	#8,d0		;
	clr.b	d0		;
	lea	(a4,d0.l*8),a0	;On se place dans l'image 1024*1024.
	movem.l	(a3),d0-d1		;
	add.w	d0,d1		;
	swap	d0		;On r‚cupŠre l'incr‚ment pour
	swap	d1		;avancer en X.
	moveq	#128/4-1,d6	;
putpix
	REPT	4
	move.w	(a0,d1.w*2),(a1)+	;Et pof, affichage
	addx.l	d0,d1		;avance dans l'image
	ENDR
	dbf	d6,putpix
	add.l	d3,d2		;Ligne suivante
	lea	((320-128)*2.w,a1),a1	;etc...
	dbf	d7,putline		;
	tst.b	KBD_data.w		;Finito ?
bb	bmi	DoLoop		;Non, alors continue

	move.l	(sp)+,d0		;
set_rez	move.w	d0,-(sp)		;Remet la r‚solution
	move.w	#3,-(sp)		;
	move.l	a6,-(sp)		;
	move.l	a6,-(sp)		;
	Xbios	Setscreen030	;
hello	pea	present(pc)	;
	Gemdos	Cconws		;
	rts			;Et cassos.

present	dc.b	"DSP exploding a 1024*1024*51 Bulb-Mapped",$d,$a
	dc.b	"ÚÉÅÛþ",9,"MandelZoom: 11s in boot!"

Vars
	rsreset
speedz	rs.w	1
	dc.w	1

posz	rs.w	1
	dc.w	$0

speedy	rs.w	1
	dc.w	2

centry	rs.w	1
	dc.w	resoly*23/80

speedx	rs.w	1
	dc.w	-3

centrx	rs.w	1
	dc.w	resolx*75/80

incy	rs.l	1
posy	rs.l	1
incx	rs.l	1
posx	rs.l	1

codeptr	incbin	mandy.b56
codesize	equ	*-codeptr

	ifd	test
	bss
buffer	ds.w	resolx*resoly+320*240
	ds.b	256
endbuffer
	endc