;	Sauvegarde image IFF

;	Tous les registres utilis‚s

;	a6 : screen : adresse ecran a sauver
;	a5 : adresse bloc memoire : 56+3*2^plans+x*y*plans/8
;	d3 : palet. : 0 STE / 1 Falcon
;	d4 : resx   : resolution x
;	d5 : resy   : resolution y
;	d6 : planes : nombre de plans (de 1 a 8)
;	d7 : compr. : compression non implement‚e

save_iff_image	MACRO	ecran,buffer,palette,resx,resy,planes,compression

	movem.l	d0-d7/a0-a6,-(sp)
	move.l	\1,a6
	move.l	\2,a5
	move.l	\3,d3
	move.l	\4,d4
	move.l	\5,d5
	move.l	\6,d6
	move.l	\7,d7

	move	d4,d0	; d4 multiple de 16 pixels
	and	#15,d0
	beq.s	_d4_mult16
	add	#16,d4
	and	#-16,d4
_d4_mult16
	moveq	#56,d0	; d0 taille memoire requise
	moveq	#1,d1	; CAD : 56 octets
	lsl	d6,d1
	mulu	#3,d1	; +     3*2^plans octets
	add	d1,d0
	move	d6,d1
	mulu	d4,d1
	mulu	d5,d1
	lsr.l	#3,d1
	add.l	d1,d1
	add.l	d1,d0	; +     x*y*plans/8 octets
	
	move.l	a5,a4	; a4 sauvegarde adresse buffer

;	Chunk FORM

	move.l	#"FORM",(a5)+
	clr.l	(a5)+
	move.l	#"ILBM",(a5)+
	
;	Chunk BitMap HeaDer

	move.l	#"BMHD",(a5)+
	move.l	#20,(a5)+
	move	d4,(a5)+
	move	d5,(a5)+
	clr.l	(a5)+
	move.b	d6,(a5)+
	clr.b	(a5)+
	move.b	d7,(a5)+
	clr.b	(a5)+
	clr.l	(a5)+
	move	d4,(a5)+
	move	d5,(a5)+
	
;	Chunk Color MAP

	move.l	#"CMAP",(a5)+
	moveq	#1,d0
	lsl	d6,d0
	mulu	#3,d0
	move.l	d0,(a5)+
	lea	palette_ste,a3
	tst	d3
	beq.s	pas_palette_ste
	lea	palette_falcon,a3
pas_palette_ste	moveq	#1,d2
	lsl	d6,d2
	subq	#1,d2	; nb de couleurs dans palette
	move.l	a5,a2
	SUPEXEC	a3
	move.l	a2,a5

;	Chunk BODY	

	move.l	#"BODY",(a5)+
	move	d4,d0
	mulu	d6,d0
	mulu	d5,d0
	lsr.l	#3,d0
	move.l	d0,(a5)+
	
	move.l	a5,a2
	SUPEXEC	#convert_plan
	move.l	a2,a5

;	tst	d7
;	bne.s	compression
;	nop
;	bra.s	fin_body
;compression	nop
;fin_body
		
;	Fin

	movem.l	(sp)+,d0-d7/a0-a6
	bra	end_iff_macro
	
;	Conversion plans image > plans IFF

convert_plan	movem.l	d0-d7,-(sp)
	moveq	#0,d2
	move	d6,d2
	add	d2,d2
	add	d2,d2
	swap	d2
	lsr	#3,d4
	move	d4,d7
	lsr	#1,d7
	addq	#1,d7
	swap	d7
	move	d5,d7
	
	subq	#1,d6	; nb de plans
	move	d6,d3
	mulu	d4,d3
boucle_plan	lea	$ffff8a20.w,a3
	move.l	d2,(a3)+	
	move.l	a6,(a3)+
	move.l	#$ffffffff,(a3)+
	move.l	#$00000002,(a3)+
	move	d3,(a3)+
	move.l	a2,(a3)+
	move.l	d7,(a3)+
	move.l	#$02038000,(a3)
	BLTWAIT	2(a3)

	addq	#8,a6
	add	d4,a2	
	dbra	d6,boucle_plan
	movem.l	(sp)+,d0-d7
	rts

;	Palette STE

palette_ste	movem.l	d0-d2/a1,-(sp)
	move	d2,d0
	lea	$ffff8240.w,a1

boucle_ste	move.b	(a1)+,d1	; rouge
	and	#15,d1
	move.b	d1,d2
	and	#7,d1
	add	d1,d1
	and	#8,d2
	lsr	#3,d2
	add	d2,d1
	lsl	#4,d1
	move.b	d1,(a2)+
	
	move.b	(a1),d1	; vert
	lsr	#4,d1
	and	#15,d1
	move.b	d1,d2
	and	#7,d1
	add	d1,d1
	and	#8,d2
	lsr	#3,d2
	add	d2,d1
	lsl	#4,d1
	move.b	d1,(a2)+
	
	move.b	(a1)+,d1	; bleu
	and	#15,d1
	move.b	d1,d2
	and	#7,d1
	add	d1,d1
	and	#8,d2
	lsr	#3,d2
	add	d2,d1
	lsl	#4,d1
	move.b	d1,(a2)+
	
	dbra	d0,boucle_ste
	movem.l	(sp)+,d0-d2/a1
	rts

;	Palette Falcon

palette_falcon	movem.l	d0-d2/a1,-(sp)
	lea	$ffff9800.w,a1
	move	#255,d2
boucle_falcon	move.l	(a1)+,d0
	ror	#8,d0
	move.l	d0,(a2)+
	subq	#1,a2
	dbra	d2,boucle_falcon
	movem.l	(sp)+,d0-d2/a1
	rts

end_iff_macro
	ENDM
