; D‚compression IMA4 et r‚‚chantillonnage !!

	IFND	TST_OVER
TST_OVER:	equ	1
TST_OVERFLOW	macro
	bvc.s	*+14		; .pas_overflow
	bpl.s	*+8		; .neg_overflow
;.pos_overflow:
	move.w	#$7fff,\1
	bra.s	*+6		; .pas_overflow
;.neg_overflow:
	move.w	#-$8000,\1
;.pas_overflow:
	endm
	ENDC

precalc_ima4:
	lea	step_table(pc),a0
	lea	ima4_step_table(pc),a1
	moveq	#89-1,d0
.one_entry:
	moveq	#15,d1
	moveq	#0,d2
.calcul_one:
	move.w	(a0),d3
	moveq	#0,d4
	btst	#2,d2
	beq.s	.no_bit_2
	add.w	d3,d4
.no_bit_2:
	lsr.w	d3
	btst	#1,d2
	beq.s	.no_bit_1
	add.w	d3,d4
.no_bit_1:
	lsr.w	d3
	btst	#0,d2
	beq.s	.no_bit_0
	add.w	d3,d4
.no_bit_0:
	lsr.w	d3
	add.w	d3,d4
	btst	#3,d2
	beq.s	.no_bit_4
	neg.w	d4
.no_bit_4:	
	move.w	d4,(a1)+
	addq.w	#1,d2
	dbf	d1,.calcul_one
	addq.w	#2,a0
	dbf	d0,.one_entry
	rts	
	
calcul_index:	MACRO
	add.w	(\1,\2.w*2),\3	; calcul du nouvel index
	bpl.s	*+6		; .check_index
	clr.w	\3
	bra.s	*+12		; .ok_index
;.check_index:
	cmp.w	#88*16,\3
	bls.s	*+6		; .ok_index
	move.w	#88*16,\3
;.ok_index:
	ENDM

calcul_sample:	MACRO
	add.w	(\1,\2.w*2),\3	; calcul du nouvel ‚chantillon
	TST_OVERFLOW	\3
*	bvc.s	*+14		; .ok_scale
*	bpl.s	*+8		; .bigger
*	move.w	#$7fff,\3
*	bra.s	*+6		; .ok_scale
*;.bigger:
*	move.w	#-$8000,\3
*;.ok_scale:
	ENDM

	
mono_ima_4_bits:
	lea	(a1,d1.l),a2	; Adr de fin du son … r‚‚chantillonner
	move.l	16(a0),a3	; Adr du buffer destination
	lea	ima4_step_table(pc),a4
	lea	index_table(pc),a0
	move.w	block_align(pc),d7
	swap	d7			;
	move.w	resample_speed2(pc),d7	;
	add.b	d7,d7
	clr.w	d5		;
	clr.w	d6
	lea	(a1),a6
.depack_block:	
	lea	(a6),a1
	swap	d7		;
	lea	(a1,d7.w),a6
	swap	d7		;
	cmp.l	a6,a2
	bge.s	.start_block
	rts
.start_block:
	move.w	(a1)+,d2
	ror.w	#8,d2
	move.w	(a1)+,d4
	lsr.w	#8,d4
	and.w	#$7f,d4
	asl.w	#4,d4
	cmp.w	#88*16,d4
	bls.s	.go_block
	move.w	#88*16,d4
.go_block:
	move.b	(a1)+,d6	; on traite deux ‚chantillons … la fois
	move.w	d6,d1
	and.w	#$f,d1		; premier ‚chantillon
	move.w	d4,d0		; l'index est d‚j… pr‚multipli‚ par 16
	or.w	d1,d0		; ajoute l'offset pour le pr‚calc
	calcul_sample	a4,d0,d2
	calcul_index	a0,d1,d4
	move.w	d2,d3		; copie sample
	lsr.w	#4,d6		; deuxiŠme ‚chantillon
	move.w	d4,d0
	or.w	d6,d0
	calcul_sample	a4,d0,d2
	calcul_index	a0,d6,d4
	ror.w	#8,d2
	move.b	d2,d3
	rol.w	#8,d2
	move.w	d3,(a3)+
	add.b	d7,d5
	bcc.s	.no_resample
	move.b	d3,(a3)+	; un ‚chantillon
.no_resample:	
	cmp.l	a1,a6
	bgt.s	.go_block
	bra	.depack_block

stereo_ima_4_bits:
	lea	(a1,d1.l),a2	; Adr de fin du son … r‚‚chantillonner
	move.l	16(a0),a3	; Adr du buffer destination
	lea	ima4_step_table(pc),a4
	lea	index_table(pc),a0
	move.w	block_align(pc),d7
	swap	d7			;
	move.w	resample_speed2(pc),d7	;
	add.b	d7,d7
	clr.l	d6
	lea	(a1),a6
.depack_block:	
	lea	(a6),a1
	swap	d7
	lea	(a1,d7.w),a6
	swap	d7
	cmp.l	a6,a2
	bge.s	.start_block
	rts
.start_block:
	move.w	(a1)+,d2
	ror.w	#8,d2
	move.w	(a1)+,d4
	lsr.w	#8,d4
	and.w	#$7f,d4
	asl.w	#4,d4
	cmp.w	#88*16,d4
	bls.s	.read_right
	move.w	#88*16,d4
.read_right:
	swap	d2
	move.w	(a1)+,d2
	ror.w	#8,d2
	swap	d4
	move.w	(a1)+,d4
	lsr.w	#8,d4
	and.w	#$7f,d4
	asl.w	#4,d4
	cmp.w	#88*16,d4
	bls.s	.go_block
	move.w	#88*16,d4
.go_block:
	move.w	(a1)+,d6	; on traite deux ‚chantillons … la fois
	lsl.l	#8,d6
	swap	d2
	lsr.w	#8,d6
	swap	d4
	swap	d6
	move.w	d6,d1
	and.w	#$f,d1		; premier ‚chantillon
	move.w	d4,d0		; l'index est d‚j… pr‚multipli‚ par 16
	or.w	d1,d0		; ajoute l'offset pour le pr‚calc
	calcul_sample	a4,d0,d2
	calcul_index	a0,d1,d4
	move.w	d2,d3		; copie sample
	swap	d3
	lsr.w	#4,d6		; deuxiŠme ‚chantillon
	move.w	d4,d0
	or.w	d6,d0
	calcul_sample	a4,d0,d2
	calcul_index	a0,d6,d4
	move.w	d2,d3
	swap	d4
	swap	d3
	clr.w	d6	; efface futur mot de poids fort pour boucle suivante
	swap	d2
	swap	d6
	move.w	d6,d1
	and.w	#$f,d1		; premier ‚chantillon
	move.w	d4,d0		; l'index est d‚j… pr‚multipli‚ par 16
	or.w	d1,d0		; ajoute l'offset pour le pr‚calc
	calcul_sample	a4,d0,d2
	calcul_index	a0,d1,d4
	ror.w	#8,d2
	move.b	d2,d3		; copie sample
	rol.w	#8,d2
	swap	d3
	lsr.w	#4,d6		; deuxiŠme ‚chantillon
	move.w	d4,d0
	or.w	d6,d0
	calcul_sample	a4,d0,d2
	calcul_index	a0,d6,d4
	ror.w	#8,d2
	move.b	d2,d3
	rol.w	#8,d2
	move.l	d3,(a3)+
	add.b	d7,d5
	bcc.s	.no_resample
	move.w	d3,(a3)+	; un ‚chantillon
.no_resample:	
	cmp.l	a1,a6
	bgt	.go_block
	bra	.depack_block

	DATA
step_table:
	dc.w	7,8,9,10,11,12,13,14
	dc.w	16,17,19,21,23,25,28,31
	dc.w	34,37,41,45,50,55,60,66
	dc.w	73,80,88,97,107,118,130,143
	dc.w	157,173,190,209,230,253,279,307
	dc.w	337,371,408,449,494,544,598,658
	dc.w	724,796,876,963,1060,1166,1282,1411
	dc.w	1552,1707,1878,2066,2272,2499,2749,3024
	dc.w	3327,3660,4026,4428,4871,5358,5894,6484
	dc.w	7132,7845,9630,9493,10442,11487,12635,13899
	dc.w	15289,16818,18500,20350,22385,24623,27086,29794
	dc.w	32767
	
index_table:
;	dc.w	-1,-1,-1,-1,2,4,6,8
	dc.w	-1*16,-1*16,-1*16,-1*16,2*16,4*16,6*16,8*16
	dc.w	-1*16,-1*16,-1*16,-1*16,2*16,4*16,6*16,8*16
	
	BSS
ima4_step_table:
	ds.w	16*89
	TEXT