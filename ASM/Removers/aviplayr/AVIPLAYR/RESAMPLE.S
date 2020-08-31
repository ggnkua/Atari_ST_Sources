; Routine de r‚‚chantillonnage
* En n'utilisant pas de pr‚calculs
*	lea	(a1,d1.l),a2	; Adr de fin du son … r‚‚chantillonner
*	move.l	16(a0),a3	; Adr du buffer destination
*	lea	(a1),a4		; Debut du son dans A4
*	move.l	#RESAMPLE_SPD,d0; = (22050/25000)*256 = periode 
*	moveq	#0,d1		; t ( ST MAG nø 76 page 49 )
*	move.b	(a1)+,(a3)	; On va r‚‚chantillonner … 25000 Hz 
*	moveq	#$80,d7		; pour faire ‡a bien
*	eor.b	d7,(a3)+	; On signe
**	moveq	#0,d5
*.resample_sound:
*	add.l	d0,d1		; t+=periode
*	move.l	d1,d2
*	lsr.l	#8,d2		; Divise par 256
*	lea	(a4,d2.l),a1
*	move.b	(a1)+,d3
*	eor.b	d7,d3
*	ext.w	d3
*	move.b	(a1),d4
*	eor.b	d7,d4
*	ext.w	d4
*	move.b	d1,d5		; Partie d‚cimale dans D5
*	beq.s	.t_entier	; Si il n'y en a pas => t est entier
*	moveq	#0,d6		; Sinon
*	sub.b	d1,d6		; On va calculer
*	mulu.w	d6,d3		; le nouvel ‚chantillon
*	mulu.w	d5,d4
*	add.w	d4,d3
*	lsr.w	#8,d3
*.t_entier:
*	move.b	d3,(a3)+	; Echantillon sauv‚
*	cmp.l	a1,a2
*	bgt.s	.resample_sound

precalcul_resampling:
	move.l	#resampling,a0
	move.w	#255,d0			; pour r‚‚chantillonner !!!!!
	moveq	#0,d1
	moveq	#0,d5
.une_decimale:
	move.w	#255,d2
	moveq	#0,d3
.all_values:
	move.b	d1,d5
	moveq	#0,d6
	sub.b	d1,d6
	tst.b	d1
	bne.s	.no_zero_value
	move.w	#256,d6
.no_zero_value:
	move.l	d3,d4
	eor.b	#$80,d4
	ext.w	d4
	muls.w	d6,d4
	move.w	d4,(a0)+
	move.l	d3,d4
	eor.b	#$80,d4
	ext.w	d4
	muls.w	d5,d4
	move.w	d4,(a0)+
	addq.w	#1,d3
	dbf	d2,.all_values
	addq.w	#1,d1
	dbf	d0,.une_decimale
	rts

mono_8_bits:
	lea	(a1,d1.l),a2	; Adr de fin du son … r‚‚chantillonner
	move.l	16(a0),a3	; Adr du buffer destination
	lea	resampling(pc),a5
	move.w	resample_speed(pc),d0	; = (22050/25000)*256 = periode 
	lsl.w	#8,d0		; On pr‚multiplie par 256
	clr.l	d1		; On r‚‚chantillonne … 25000 Hz
	clr.w	d3
	clr.w	d4
	move.b	(a1)+,d3
	move.b	(a1)+,d4	
	move.b	d3,(a3)
	eor.b	#$80,(a3)+
.resample_sound:
	add.w	d0,d1		; t+=periode
	bcc.s	.no_carry
	move.b	d4,d3
	move.b	(a1)+,d4
.no_carry:
	lea	(a5,d1.l*4),a6	; Partie d‚cimale par 256*4=1024
	move.w	(a6,d3.w*4),d6	; on calcule le barycentre (d3,frac) (d4,1-frac)
	add.w	2(a6,d4.w*4),d6	; le calcul achev‚,
	lsr.w	#8,d6		; on remet le r‚sultat … l'‚chelle
	move.b	d6,(a3)+	; et on le sauve
	cmp.l	a1,a2		; fini ?
	bgt.s	.resample_sound
	rts

stereo_8_bits:
	lea	(a1,d1.l),a2	; Adr de fin du son … r‚‚chantillonner
	move.l	16(a0),a3	; Adr du buffer destination
	lea	resampling(pc),a5
	move.w	resample_speed(pc),d0	; = (22050/25000)*256 = periode 
	lsl.w	#8,d0		; pr‚multiplie par 256
	move.w	(a1)+,(a3)	; On va r‚‚chantillonner … 25000 Hz 
	eor.w	#$8080,(a3)+	; On signe
;	move.b	(a1)+,(a3)
;	eor.b	#$80,(a3)+
	clr.l	d1
	clr.w	d3
	clr.w	d4
	clr.w	d5
	clr.w	d7
	move.b	(a1)+,d3
	move.b	(a1)+,d5
	move.b	(a1)+,d4
	move.b	(a1)+,d7
.resample_sound2:
	add.w	d0,d1		; t+=periode
	bcc.s	.no_carry2
	move.b	d4,d3
	move.b	(a1)+,d4
	move.b	d7,d5
	move.b	(a1)+,d7
.no_carry2:
	lea	(a5,d1.l*4),a6	; Multiplie par 4 ( donc par 256*4=1024 )
	move.w	(a6,d3.w*4),d6
	move.w	(a6,d5.w*4),d2
	add.w	2(a6,d4.w*4),d6
	add.w	2(a6,d7.w*4),d2
	lsr.w	#8,d2
	move.b	d2,d6
	move.w	d6,(a3)+	; Echantillon sauv‚ (st‚r‚o)
	cmp.l	a1,a2
	bgt.s	.resample_sound2
	rts
	
;mono_16_bits:
;	lea	(a1,d1.l),a2	; Adr de fin du son … r‚‚chantillonner
;	move.l	16(a0),a3	; Adr du buffer destination
;	move.l	#resampling2,a5
;	move.b	#RESAMPLE_SPD,d0	; = (22050/25000)*256 = periode 
;	lsl.w	#8,d0		; pr‚multiplie par 256
;	clr.l	d1		; On r‚‚chantillonne … 25000 Hz
;	clr.w	d3
;	clr.w	d4
;	addq.w	#1,a1
;	move.b	(a1),d3
;	move.b	2(a1),d4
;	addq.w	#4,a1
;	move.b	d3,(a3)+
;.resample_sound_16:
;	add.w	d0,d1		; t+=periode
;	bcc.s	.no_carry16
;	move.b	d4,d3
;	move.b	(a1),d4
;	addq.w	#2,a1
;.no_carry16:
;	lea	(a5,d1.l*4),a6	; multiplie par 4 (donc par 256*4=1024)
;	move.w	(a6,d3.w*4),d6
;	add.w	2(a6,d4.w*4),d6
;	lsr.w	#8,d6
;	move.b	d6,(a3)+	; Echantillon sauv‚
;	cmp.l	a1,a2
;	bgt.s	.resample_sound_16
;	rts

;stereo_16_bits:
;	lea	(a1,d1.l),a2	; Adr de fin du son … r‚‚chantillonner
;	move.l	16(a0),a3	; Adr du buffer destination
;	move.l	#resampling2,a5
;	move.b	#RESAMPLE_SPD,d0	; = (22050/25000)*256 = periode 
;	lsl.w	#8,d0		; pr‚multiplie par 256
;	clr.l	d1		; on r‚‚chantillonne … 25000 Hz
;	clr.w	d3
;	clr.w	d4
;	clr.w	d5
;	clr.w	d7
;	addq.w	#1,a1
;	move.b	(a1),d3
;	move.b	2(a1),d5
;	move.b	4(a1),d4
;	move.b	6(a1),d7
;	addq.w	#8,a1
;	move.b	d3,(a3)+
;	move.b	d5,(a3)+
;.resample_sound2_16:
;	add.w	d0,d1		; t+=periode
;	bcc.s	.no_carry2_16
;	move.b	d4,d3
;	move.b	(a1),d4
;	move.b	d7,d5
;	move.b	2(a1),d7
;	addq.w	#4,a1
;.no_carry2_16:
;	lea	(a5,d1.l*4),a6	; Multiplie par 4 ( donc par 256*4=1024 )
;	move.w	(a6,d3.w*4),d6
;	move.w	(a6,d5.w*4),d2
;	add.w	2(a6,d4.w*4),d6
;	add.w	2(a6,d7.w*4),d2
;	lsr.w	#8,d2
;	move.b	d2,d6
;	move.w	d6,(a3)+	; Echantillon sauv‚
;	cmp.l	a1,a2
;	bgt.s	.resample_sound2_16
;	rts
	
fmono_8_bits:
	lea	(a1,d1.l),a2	; Adr de fin du son … r‚‚chantillonner
	move.l	16(a0),a3	; Adr du buffer destination
	move.b	#$80,d7		; pour signer
	move.w	resample_speed2(pc),d5
	clr.w	d0
.resample_sound:
	move.b	(a1)+,d1
	eor.b	d7,d1
	move.b	d1,(a3)+
	add.b	d5,d0
	bcc.s	.no_resample
	move.b	d1,(a3)+
.no_resample:
	cmp.l	a1,a2		; fini ?
	bgt.s	.resample_sound
	rts

fstereo_8_bits:
	lea	(a1,d1.l),a2	; Adr de fin du son … r‚‚chantillonner
	move.l	16(a0),a3	; Adr du buffer destination
	move.w	#$8080,d7	; pour signer
	move.w	resample_speed2(pc),d5
	clr.w	d0
.resample_sound:
	move.w	(a1)+,d1
	eor.w	d7,d1
	move.w	d1,(a3)+
	add.b	d5,d0
	bcc.s	.no_resample
	move.w	d1,(a3)+
.no_resample:
	cmp.l	a1,a2		; fini ?
	bgt.s	.resample_sound
	rts

mono_16_bits:	
fmono_16_bits:
	lea	(a1,d1.l),a2	; Adr de fin du son … r‚‚chantillonner
	move.l	16(a0),a3	; Adr du buffer destination
	move.w	resample_speed2(pc),d5
	clr.w	d0
.resample_sound:
	move.w	(a1)+,d1
	rol.w	#8,d1
	bfins	d1,d1{0:16}
	move.l	d1,(a3)+
	add.b	d5,d0
	bcc.s	.no_resample
	move.l	d1,(a3)+
.no_resample:
	cmp.l	a1,a2		; fini ?
	bgt.s	.resample_sound
	rts
	
stereo_16_bits:
fstereo_16_bits:
	lea	(a1,d1.l),a2	; Adr de fin du son … r‚‚chantillonner
	move.l	16(a0),a3	; Adr du buffer destination
	move.w	resample_speed2(pc),d5
	clr.w	d0
.resample_sound:
	move.l	(a1)+,d1
	swap	d1
	rol.w	#8,d1
	swap	d1
	rol.w	#8,d1
	move.l	d1,(a3)+
	add.b	d5,d0
	bcc.s	.no_resample
	move.l	d1,(a3)+
.no_resample:
	cmp.l	a1,a2		; fini ?
	bgt.s	.resample_sound
	rts
