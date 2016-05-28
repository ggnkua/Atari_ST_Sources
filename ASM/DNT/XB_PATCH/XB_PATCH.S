;Petit patch pour le TOS 4.02, qui permet de remettre le Xbios dans
;des conditions d'utilisation compatible avec ce qui se passe sur
;STE...

	include	tos_030.s
	include	hard_sys.s

start	bra.w	install

header	dc.l	"XBRA"
	dc.l	"xbip"
oldxb	dc.l	0
myxb	lea	8(sp),a0		;Dans une routine Xbios,
	btst.b	#5,(sp)		;on a le droit d'utiliser
	bne.s	*+4		;d0-d2/a0-a2 sans sauvegarde.
	move.l	usp,a0		;
	cmpi.w	#5,(a0)		;
	beq.s	setscreen		;Si cet appel nous concerne...
	cmpi.w	#88,(a0)		;
	beq.s	vsetmode		;
	jmp	([oldxb.w,pc])	;

vsetmode	bsr.s	palsave		;Vsetmode: non seulement la palette
	move.l	a0,-(sp)		;mais aussi le passage "anti-cls"
	dc.w	$a00a		;
	move.l	(sp)+,a0		;
	move.l	_v_bas_ad.w,-(sp)	;
	move.b	$ffff8007.w,-(sp)	;On empˆche les erreurs de bus, et
	bclr.b	#5,$ffff8007.w	;on balance l'‚cran hors de la RAM,
	move.l	phystop.w,_v_bas_ad.w	;donc le cls est inactif.
	bsr.s	call		;vroom
	lea	20(sp),sp		;
	move.b	(sp)+,$ffff8007.w	;
	move.l	(sp)+,_v_bas_ad.w	;
	move.l	d0,-(sp)		;
	dc.w	$a009		;Remet la souris.
	move.l	(sp)+,d0		;
	bsr.s	palback		;
	rte			;

setscreen	bsr.s	palsave		;Setscreen: le mˆme, mais sans
	bsr.s	call		;changement de palette.
	lea	20(sp),sp		;Donc en la sauvegardant
	bsr.s	palback		;
	rte			;

palsave	lea	buff(pc),a1	;Rien … dire, si ce n'est
	lea	v_color.w,a2	;que cela coule de source.
	moveq	#7,d1		;
	move.l	(a2)+,(a1)+	;
	dbf	d1,*-2		;
	lea	v_color030.w,a2	;Adresse couleurs falcon
	move.w	#255,d1		;
	move.l	(a2)+,(a1)+	;
	dbf	d1,*-2		;
	rts			;
palback	clr.l	colorptr.w		;
	lea	buff(pc),a1	;
	lea	v_color.w,a2	;
	moveq	#7,d1		;
	move.l	(a1)+,(a2)+	;
	dbf	d1,*-2		;
	lea	v_color030.w,a2	;
	move.w	#255,d1		;
	move.l	(a1)+,(a2)+	;
	dbf	d1,*-2		;
	rts			;

call	moveq	#8-1,d0		;8 mots de paramŠtre maxi
.param	move.w	(a0,d0.w*2),-(sp)	;
	dbf	d0,.param		;
	clr.w	-(sp)		;stackframe 0
	move.l	16+2(sp),-(sp)	;shunte le RTE
	move.w	sr,-(sp)		;
	jmp	([oldxb.w,pc])	;vroom
buff	equ	*

install	clr.l	-(sp)		;
	Gemdos	Super		;En superviseur, on est mieux..
	move.l	d0,-(sp)		;
	movea.l	$b8.w,a0		;
.look	cmpi.l	#"XBRA",-12(a0)	;Cherche la chaŒne XBRA.
	bne.s	.ok		;-> chaŒne finie, stop!
	cmpi.l	#"xbip",-8(a0)	;C'est nous ?
	beq.s	.deja		;vivi, on arrˆte tout
	move.l	-(a0),a0		;Non, maillon suivant
	bra.s	.look		;
.deja	Gemdos	Super		;
	pea	abort(pc)		;
	Gemdos	Cconws
	Gemdos	Pterm0

.ok	move.w	#buff+1024+32-(header-128),a6;Taille n‚cessaire en rusant
	lea	header(pc),a0	;
	lea	start-256(pc),a1	;Test gadget: la page de base est bien
	cmpa.l	8(sp),a1		;256 octet avant le code ???
	beq.s	.gag		;
	lea	128(a6),a6		;non (!), donc on se calme,
	lea	start(pc),a1	;et on s'installe normalement.

.gag	lea	128(a1),a1		;On se place dans la commandline.
	lea	12(a1),a2		;Conserve l'adresse du nouveau
.copy	move.b	(a0)+,(a1)+	;vecteur, et installe le tout.
	cmpa.l	#buff,a0		;
	bne.s	.copy		;


	move.l	a2,d1		;Et pan, on s'enchaŒne dans les
	subq.l	#4,a2		;rŠgles de l'art. cf article
	lea	$b8.w,a1		;du DNT-Paper 6.
.hop	cas2.l	d0:d2,d1:d0,(a1):(a2)	;
	bne.s	.hop		;

	Gemdos	Super		;On se casse, bˆtement...
	pea	present(pc)	;
	Gemdos	Cconws		;
	clr.w	-(sp)		;
	move.l	a6,-(sp)		;
	Gemdos	Ptermres		;

	section	data
abort	dc.b	"XB_PATCH d‚j… install‚",$d,$a,0
present	dc.b	"XB_PATCH 1.0 est install‚",$d,$a,0
