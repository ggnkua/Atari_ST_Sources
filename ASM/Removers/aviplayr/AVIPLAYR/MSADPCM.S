; D‚compression MSADPCM (DSP) et r‚‚chantillonnage !!
	
; Macro d'envoi et de r‚ception de donn‚es (DSP)
; \1 est un registre d'adresse initialis‚ … $ffffa200.w
; \3 est un flag qui force ou non le handshaking
SEND_DSP	macro
	IF	\?3
	  IFNE	\3
	    btst	#1,2(\1)
	    beq.s	*-6
	  ENDC
	ENDIF
	IFC	'\0','L'
	  move.l	\2,4(\1)
	ELSE
	  IFC	'\0','B'
	    move.b	\2,7(\1)
	  ELSE
	    move.w	\2,6(\1)
	  ENDC
	ENDC
	endm

RECEIVE_DSP	macro
	IF	\?3
	  IFNE	\3
	    btst	#0,2(\1)
	    beq.s	*-6
	  ENDC
	ENDIF
	IFC	'\0','L'
	  move.l	4(\1),\2
	ELSE
	  IFC	'\0','B'
	    move.b	7(\1),\2
	  ELSE
	    move.w	6(\1),\2
	  ENDC
	ENDC
	endm

WAIT_DSP	macro
	btst	#\2,2(\1)
	beq.s	*-6
	endm

precalc_msadpcm:
	Dsp_lock
	Dsptristate	#1,#1
	Dsp_requestuniqueability
	Dsp_execprog	dsp_prog(pc),#(dsp_prog_end-dsp_prog)/3,d0
	Dsp_unlock
	rts
	
	TEXT
calcul_delta:	macro
	mulu.w	(\1,\2.w*2),\3	; ATTENTION : \2 est sign‚
	lsr.l	#8,\3		; l'adresse du tableau (\1)
	cmp.w	#16,\3		; est donc au milieu des precalcs
	bhs.s	*+6		; .ok_index
	move.w	#16,\3
;.ok_index:
	endm
	
calcul_new_sample:	macro
; le premier paramŠtre \1 permet de savoir si c'est coef1 ou coef2 dans le
; mot de poids faible de \2
; \1=0 si \2.w=coef2
; \1=1 si \2.w=coef1
; \3=Sample2, \4.w=Sample1
; \5=NewSample
; \6.w=ErrorDelta (4 bits sign‚)
; \7.w=Delta
	move.w	\4,\5
	IFEQ	\1
	muls.w	\2,\3	; coef2*Sample2
	swap	\2	; ‚change coef1 et coef2
	muls.w	\2,\5	; coef1*Sample1
	ELSE
	muls.w	\2,\5	; coef1*Sample1
	swap	\2	; ‚change coef1 et coef2
	muls.w	\2,\3	; coef2*Sample2
	ENDC
	add.l	\5,\3	; fait la somme
	asr.l	#8,\3	; et calcule la partie entiŠre
	move.w	\6,\5	; l'‚chantillon sign‚
	muls.w	\7,\5	; Delta*ErrorDelta
	add.l	\3,\5	; on ajoute le tout et on v‚rifie les d‚passements
	bmi.s	*+16	;.check_under
	cmp.l	#$7fff,\5
	ble.s	*+20	;.ok_over
	move.w	#$7fff,\5
	bra.s	*+14	;.ok_over
;.check_under:
	cmp.l	#-$8000,\5
	bge.s	*+6	;.ok_over
	move.w	#-$8000,\5
;.ok_over:	
	move.w	\4,\3	; Sample2 <- Sample1
	move.w	\5,\4	; Sample1 <- New_Sample
	endm

mono_msadpcm_4_bits:
	lea	(a1,d1.l),a2	; Adr de fin du son … r‚‚chantillonner
	move.l	16(a0),a3	; Adr du buffer destination
	lea	$ffffa200.w,a5
	move.w	block_align(pc),d7
	move.w	resample_speed2(pc),d6
	add.b	d6,d6
	clr.l	d5		; pour resampling
	lea	(a1),a6
.depack_block:	
	lea	(a6),a1
	lea	(a1,d7.w),a6
	cmp.l	a6,a2
	bge.s	.start_block
	rts
.disable_msadpcm:
	move.w	#1,sound_disabled
	rts
.start_block:
	SEND_DSP.l	a5,#$1,1
	clr.w	d0
	move.b	(a1)+,d0	; Lit Predictor
	SEND_DSP.w	a5,d0,1
	move.w	(a1)+,d0	; Lit Delta
	ror.w	#8,d0
	SEND_DSP.w	a5,d0,1
	move.w	(a1)+,d0	; Lit Sample1
	move.b	d0,(a3)+
	ror.w	#8,d0
	SEND_DSP.w	a5,d0,1
	move.w	(a1)+,d0	; Lit Sample2
	move.b	d0,(a3)+
	add.b	d6,d5
	bcc.s	.no_resampl
	move.b	d0,(a3)+
.no_resampl:
	ror.w	#8,d0
	SEND_DSP.w	a5,d0,1
	move.w	d7,d4
	subq.w	#7,d4
	SEND_DSP.w	a5,d4,1
	lsr.w	d4			; le driver DSP travaille avec des mots
	bcc.s	.no_one_more_byte	; donc si le nb d'octets est impair
.one_more_byte:
	SEND_DSP.b	a5,(a1)+,1
	RECEIVE_DSP.w	a5,d0,1
	move.w	d0,(a3)+		; il est possible d'envoyer le
	add.b	d6,d5			; premier octet s‚par‚ment
	bcc.s	.no_resample_extra_byte
	move.b	d0,(a3)+
.no_resample_extra_byte:
.no_one_more_byte:
	subq.w	#1,d4	
.go_block:
	SEND_DSP.w	a5,(a1)+,1
	RECEIVE_DSP.w	a5,d0,1
;	lsl.l	#8,d0
;	RECEIVE_DSP.w	a5,d0,1
;	lsr.l	#8,d0
	move.w	d0,(a3)+
	add.b	d6,d5
	bcc.s	.no_resample
	move.b	d0,(a3)+
.no_resample:
	RECEIVE_DSP.w	a5,d0
;	lsl.l	#8,d0
;	RECEIVE_DSP.w	a5,d0,1
;	lsr.l	#8,d0
	move.w	d0,(a3)+
	add.b	d6,d5
	bcc.s	.no_resample2
	move.b	d0,(a3)+
.no_resample2:
	dbf	d4,.go_block
	bra	.depack_block

stereo_msadpcm_4_bits:
	lea	(a1,d1.l),a2	; Adr de fin du son … r‚‚chantillonner
	move.l	16(a0),a3	; Adr du buffer destination
	lea	coef1_table(pc),a4
	lea	adaption_table(pc),a0
	move.w	block_align(pc),d7
	swap	d7			;
	move.w	resample_speed2(pc),d7	;
	add.b	d7,d7
	clr.l	d4		; pour resampling
	lea	(a1),a6
.depack_block:	
	lea	(a6),a1
	swap	d7		;
	lea	(a1,d7.w),a6
	swap	d7		;
	cmp.l	a6,a2
	bge.s	.start_block
	rts
.disable_msadpcm:
	move.w	#1,sound_disabled
	rts
.start_block:
	clr.w	d0
	move.b	(a1)+,d0	; Lit Predictor
	cmp.w	#7,d0
	bgt.s	.disable_msadpcm
	move.w	(a4,d0.w*2),d6
	swap	d6
	move.w	coef2_table-coef1_table(a4,d0.w*2),d6
	move.w	(a1)+,d3	; Lit Delta
	ror.w	#8,d3
	move.w	(a1)+,d4	; Lit Sample1
	ror.w	#8,d4
	move.w	(a1)+,d5	; Lit Sample2
	ror.w	#8,d5
	move.l	d6,a5
	clr.w	d0
	move.b	(a1)+,d0
	cmp.w	#7,d0
	bgt.s	.disable_msadpcm
	move.w	(a4,d0.w*2),d6
	swap	d6
	move.w	coef2_table-coef1_table(a4,d0.w*2),d6
	swap	d3
	move.w	(a1)+,d3	; Delta
	ror.w	#8,d3
	move.w	(a1)+,d0	; Sample1
	ror.w	#8,d0
	swap	d5
	move.w	(a1)+,d5	; Sample2
	ror.w	#8,d5
	swap	d0		; Sample1 gauche dans poids faible
	swap	d3		; Delta gauche dans poids faible
.go_block:
; utilise D0.w,D1.l,D2.l,D3.l,D4.l,D5.l,D6.l,D7.l
	move.b	(a1)+,d2	; on traite deux ‚chantillons … la fois
	bfins	d2,d2{8:4}
	asr.b	#4,d2		; 4 bits sign‚
	ext.w	d2		; donc on signe
	move.w	d5,d0		; sauve Sample2 droite
	exg	d6,a5		; Coef de gauche dans D6
	swap	d5		; on passe … gauche Sample2
	calcul_new_sample	0,d6,d5,d4,d1,d2,d3
	swap	d6
	bfins	d0,d5{0:16}	; r‚cupŠre Sample2 droite
	move.w	d1,d0
	swap	d3		; on sauve delta de droite
	move.w	d3,d1
	swap	d3		; pour calcul de delta gauche
	calcul_delta	a0,d2,d3
	swap	d0		; on prepare Sample1 droite
	swap	d3		; on passe … droite Delta
	move.w	d1,d3		; on reprend le delta
	swap	d2
	asr.b	#4,d2
	ext.w	d2
	bfins	d5,d2{0:16}	; on sauve Sample2 gauche
	exg	d6,a5		; Coef de droite dans D6
	swap	d5		; on passe … droite Sample2 gauche
	calcul_new_sample	0,d6,d5,d0,d1,d2,d3
	swap	d6
	swap	d2
	bfins	d2,d5{0:16}	; on r‚cupŠre Sample2 gauche
	swap	d2
	swap	d0		; on sauve dans un coin Sample1 droite
	ror.w	#8,d1
	move.b	d1,d0	
	swap	d3		; on sauve delta de gauche
	move.w	d3,d1
	swap	d3		; pour calcul de delta droite
	calcul_delta	a0,d2,d3
	swap	d3		; on repasse … gauche Delta
	move.w	d1,d3		; on reprend le delta
	move.w	d0,(a3)+
	swap	d4
	add.b	d7,d4
	bcc.s	.no_resample
	move.b	d0,(a3)+	; un ‚chantillon
.no_resample:	
	swap	d4
	cmp.l	a1,a6
	bgt	.go_block
	bra	.depack_block

	DATA
coef1_table:
	dc.w	256,512,0,192,240,460,392

coef2_table:
	dc.w	0,-256,0,64,0,-208,-232

; Table de calcul de delta (index sign‚)
	dc.w	768,614,512,409,307,230,230,230
adaption_table:
	dc.w	230,230,230,230,307,409,512,614

dsp_prog:
	dcb.b	744,0
*	incbin	'msadpcm.p56'
dsp_prog_end:
	even
	TEXT
