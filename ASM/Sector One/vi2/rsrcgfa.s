	move.l	4(sp),a6	;sauvegarde l'adresse du fichier.RSC

	dc.w	$a000
	moveq	#0,d7
	move.l	-460(a0),a0	;adresse du header de fonte par d‚faut
	move	44(a0),d7	;demi-hauteur de la fonte
	add	d7,d7		;hauteur de la fonte

	move.w	20(a6),d6	;nombre d'objets
	move.w	18(a6),d5	;index sur le tableau d'arbres
	move.l	0(a6,d5.w),a5
	add.l	a6,a5		;a5 = adresse du tableau
	moveq	#0,d5
	move.w	32(a6),d5	;d5 = nombre de bit images
	move.l	a6,a4
	moveq	#0,d0
	move.w	16(a6),d0	;adr rel. des Frimages
	add.l	d0,a4		;a4 = adresse des frimages
	tst.w	d5
	beq.s	rl_ob_reloc

	moveq	#1,d0
rl_im_reloc
	move.l	(a4)+,a0
	add.l	a6,a0
	move.l	(a0),a1
	add.l	a6,a1
	move.l	a1,(a0)
	addq.l	#1,d0
	cmp.w	d5,d0
	bls.s	rl_im_reloc

rl_ob_reloc
	moveq	#1,d0
rl_next_ob
	move.w	6(a5),d4
	and	#$ff,d4

	cmp	#$1A,d4		;G_BUTTON
	beq.s	rl_string
	cmp	#$1C,d4		;G_STRING
	beq.s	rl_string
	cmp	#$20,d4		;G_TITLE
	beq.s	rl_string
	cmp	#$15,d4		;G_TEXT
	beq.s	rl_text_icon
	cmp	#$16,d4		;G_BOXTEXT
	beq.s	rl_text_icon
	cmp	#$1D,d4		;G_FTEXT
	beq.s	rl_text_icon
	cmp	#$1E,d4		;G_FBOXTEXT
	beq.s	rl_text_icon
	cmp	#$1F,d4		;G_ICON
	beq.s	rl_text_icon
	cmp	#$17,d4		;G_IMAGE
	beq.s	rl_image
	cmp	#$18,d4		;G_USERDEF
	beq.s	rl_userdef
	cmp	#$14,d4		;G_BOX
	beq.s	rl_box
	cmp	#$19,d4		;G_IBOX
	beq.s	rl_box
	cmp	#$1B,d4		;G_BOXCHAR
	beq.s	rl_box

	moveq	#-1,d0
	rts

rl_string
	move.l	$C(a5),a0
	add.l	a6,a0
	move.l	a0,$C(a5)
	bra.s	rl_box
rl_text_icon
	move.l	$C(a5),a0
	add.l	a6,a0
	move.l	a0,$C(a5)
	move.l	(a0),d1
	add.l	a6,d1
	move.l	d1,(a0)
	move.l	4(a0),d1
	add.l	a6,d1
	move.l	d1,4(a0)
	move.l	8(a0),d1
	add.l	a6,d1
	move.l	d1,8(a0)
	bra.s	rl_box
rl_image
	move.l	$C(a5),a0
	add.l	a6,a0
	move.l	a0,$C(a5)
	move.l	(a0),d1
	add.l	a6,d1
	move.l	d1,(a0)
	bra.s	rl_box
rl_userdef
	move.l	$C(a5),a0
	add.l	a6,a0
	move.l	a0,$C(a5)
	move.l	(a0),d1
	add.l	a6,d1
	move.l	d1,(a0)
	move.l	4(a0),d1
	add.l	a6,d1
	move.l	d1,4(a0)
rl_box
	moveq	#0,d1
	move.b	$11(a5),d1
	lsl.l	#3,d1
	add.b	$10(a5),d1
	move.w	d1,$10(a5)
	moveq	#0,d1
	move.b	$13(a5),d1
	mulu.w	d7,d1
	add.b	$12(a5),d1
	move.w	d1,$12(a5)
	moveq	#0,d1
	move.b	$15(a5),d1
	lsl.l	#3,d1
	add.b	$14(a5),d1
	move.w	d1,$14(a5)
	moveq	#0,d1
	move.b	$17(a5),d1
	mulu.w	d7,d1
	add.b	$16(a5),d1
	move.w	d1,$16(a5)
	lea	$18(a5),a5
	addq.l	#1,d0
	cmp.w	d6,d0
	bls	rl_next_ob
	moveq	#0,d0
	rts
