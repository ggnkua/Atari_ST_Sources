; ************************************************************************
; *                                                                      *
; *   Affichage de sprites 8 plans avec flip horizontal et/ou vertical   *
; *   by Dumbo - XXŠme siŠcle                                            *
; *                                                                      *
; *   Format du sprite :                                                 *
; *     - Largeur.w-1 en mots pour 1 plan  (nbr de pixels / 16)          *
; *     - Hauteur.w-1 en lignes                                          *
; *     - Donn‚es : plans entrelac‚s par mots                            *
; *                                                                      *
; ************************************************************************


_lwidth:	EQU	640	; Longueur d'une ligne video en octets



	TEXT



	move.w	#$20,-(sp)
	trap	#1
	move.w	#3,(sp)
	trap	#14
	addq.l	#2,sp
	addq.l	#1,d0
	move.l	d0,adraff
	lea.l	sprite(pc),a0
	move.l	a0,adrspr
	move.w	#1,-(sp)
loooop:	bsr	affsprite_fliphv
	subq.w	#1,(sp)
	bne.s	loooop
	addq.l	#2,sp
	move.w	#7,-(sp)
	trap	#1
	clr.w	(sp)
	trap	#1





; *****************************************
; Affichage de sprite sans effet
; Cr‚ation automatique du masque
; Vitesse : 52 blocs de 128x128 par seconde
;           35 pour une adresse impaire
; Regitres utilis‚s : d0-d7/a0-a2
; *****************************************

affsprite_noflip:

	move.l	adrspr(pc),a0
	move.l	adraff(pc),a1
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	move.w	#_lwidth,d5
	move.w	a1,d2
	btst	#0,d2		; Teste la parit‚ de l'adresse
	bne.s	affspr_nf_imp
	moveq	#16,d6
afsply:	move.w	d0,d2
	move.l	a1,a2
afsplx:	move.w	(a0)+,d3
	REPT	7
	or.w	(a0)+,d3
	ENDR
	not.w	d3
	move.w	d3,d4
	swap	d3
	move.w	d4,d3
	sub.w	d6,a0
	REPT	4
	and.l	d3,(a2)
	move.l	(a0)+,d4
	or.l	d4,(a2)+
	ENDR
	dbra	d2,afsplx
	add.w	d5,a1
	dbra	d1,afsply
	rts

affspr_nf_imp:
	moveq	#13,d6
afsplyi:	move.w	d0,d2
	move.l	a1,a2
afsplxi:	move.w	(a0)+,d3
	REPT	7
	or.w	(a0)+,d3
	ENDR
	sub.w	#16,a0
	not.w	d3
	move.w	d3,d4
	lsr.w	#8,d3		; Masque des adresse impaires
	REPT	7
	and.b	d3,(a2)
	move.b	(a0),d7
	or.b	d7,(a2)
	addq.l	#2,a0
	addq.l	#2,a2
	ENDR
	and.b	d3,(a2)
	move.b	(a0),d7
	or.b	d7,(a2)+
	sub.w	d6,a0
	REPT	7
	and.b	d4,(a2)
	move.b	(a0),d7
	or.b	d7,(a2)
	addq.l	#2,a0
	addq.l	#2,a2
	ENDR
	and.b	d4,(a2)
	move.b	(a0)+,d7
	or.b	d7,(a2)
	sub.w	d6,a2
	dbra	d2,afsplxi
	add.w	d5,a1
	dbra	d1,afsplyi
	rts



; *****************************************
; Affichage de sprite avec flip vertical
; Cr‚ation automatique du masque
; Vitesse : 52 blocs de 128x128 par seconde
;           35 pour une adresse impaire
; Registres utilis‚s : d0-d7/a0-a2
; *****************************************

affsprite_flipv:

	move.l	adrspr(pc),a0
	move.l	adraff(pc),a1
	move.w	(a0)+,d0
	move.w	(a0)+,d1
	move.w	d1,d2
	move.w	#_lwidth,d5
	mulu.w	d5,d2
	add.l	d2,a1
	move.w	a1,d2
	btst	#0,d2
	bne.s	affspr_fv_imp
	moveq	#16,d6
afspfvly:	move.w	d0,d2
	move.l	a1,a2
afspfvlx:	move.w	(a0)+,d3
	REPT	7
	or.w	(a0)+,d3
	ENDR
	not.w	d3
	move.w	d3,d4
	swap	d3
	move.w	d4,d3
	sub.w	d6,a0
	REPT	4
	and.l	d3,(a2)
	move.l	(a0)+,d4
	or.l	d4,(a2)+
	ENDR
	dbra	d2,afspfvlx
	sub.w	d5,a1
	dbra	d1,afspfvly
	rts

affspr_fv_imp:
	moveq	#13,d6
afspfvlyi:	move.w	d0,d2
	move.l	a1,a2
afspfvlxi:	move.w	(a0)+,d3
	REPT	7
	or.w	(a0)+,d3
	ENDR
	sub.w	#16,a0
	not.w	d3
	move.w	d3,d4
	lsr.w	#8,d3		; Masque des adresse impaires
	REPT	7
	and.b	d3,(a2)
	move.b	(a0),d7
	or.b	d6,(a2)
	addq.l	#2,a0
	addq.l	#2,a2
	ENDR
	and.b	d3,(a2)
	move.b	(a0),d7
	or.b	d7,(a2)+
	sub.w	d6,a0
	REPT	7
	and.b	d4,(a2)
	move.b	(a0),d7
	or.b	d7,(a2)
	addq.l	#2,a0
	addq.l	#2,a2
	ENDR
	and.b	d4,(a2)
	move.b	(a0)+,d7
	or.b	d7,(a2)
	sub.w	d7,a2
	dbra	d2,afspfvlxi
	sub.w	d5,a1
	dbra	d1,afspfvlyi
	rts



; *****************************************
; Affichage de sprite avec flip horizontal
; Cr‚ation automatique du masque
; Vitesse : 30 blocs de 128x128 par seconde
;           24 pour une adresse impaire
; Registres utilis‚s : d0-d7/a0-a3
; *****************************************

affsprite_fliph:
	move.l	adrspr(pc),a0	; a0 adresse du sprite
	move.l	adraff(pc),a1	; a1 adresse d'affichage
	lea.l	octenvers(pc),a2	; a2 pointe table d'octets
	move.w	(a0)+,d0
	move.w	d0,d2		; d2 = largeur
	addq.w	#1,d0
	lsl.w	#4,d0
	add.w	d0,a1		; a1 pointe l'angle H-D
	move.w	(a0)+,d1		; d1 = hauteur
	move.w	a1,d0
	btst	#0,d0
	bne	affspr_fh_imp
	move.w	#255,d0
	move.w	d2,-(sp)
afspfhly:	move.l	a1,a3		; a3 adresse d'affichage utilis‚e
	move.w	(sp),d2		; d2 compteur x utilis‚
afspfhlx:

; Constitution du masque
	move.w	(a0)+,d7
	REPT	7
	or.w	(a0)+,d7
	ENDR
	move.w	d7,d6
	lsr.w	#8,d6
	and.w	d0,d7
	move.b	(a2,d6.w),d6	; Inversion des bits du masque
	move.b	(a2,d7.w),d7
	lsl.w	#8,d7
	add.w	d6,d7
	not.w	d7
; Affichage des 8 plans
	moveq	#1,d3		; 2 * 4 = 8 plans
afspfhlp:	REPT	4
	move.w	-(a3),d6
	and.w	d7,d6		; d6 = combinaison masque-dest.
	move.w	-(a0),d5
	move.w	d5,d4		; Source dans d4 et d5
	lsr.w	#8,d4		; D‚composition en 2 octets
	and.w	d0,d5
	move.b	(a2,d4.w),d4	; Inversion des bits
	move.b	(a2,d5.w),d5
	lsl.w	#8,d5
	add.w	d4,d5
	add.w	d5,d6		; Addition de la source … d6
	move.w	d6,(a3)		; Affiche … l'‚cran
	ENDR
	dbra	d3,afspfhlp
	add.w	#16,a0		; S‚rie suivante de 8 plans

	dbra	d2,afspfhlx
	add.w	#_lwidth,a1	; Ligne suivante
	dbra	d1,afspfhly
	addq.l	#2,sp		; On remet la pile … flot
	rts

affspr_fh_imp:
	moveq	#0,d5
	add.w	#15,a1
	moveq	#15,d6
	move.w	#255,d7
afspfhlyi:	move.w	d2,d0		; d0 = largeur
	move.l	a1,a3
afspfhlxi:	move.w	(a0)+,d3
	REPT	6
	or.w	(a0)+,d3
	ENDR
	or.w	(a0),d3
	not.w	d3
	move.w	d3,d4
	and.w	d7,d4
	lsr.w	#8,d3
	move.b	(a2,d3.w),d3
	move.b	(a2,d4.w),d4
	subq.l	#2,a3
	and.b	d3,(a3)
	move.b	(a0),d5
	move.b	(a2,d5.w),d5
	or.b	d5,(a3)
	REPT	7
	subq.l	#2,a0
	subq.l	#2,a3
	and.b	d4,(a3)
	move.b	(a0),d5
	move.b	(a2,d5.w),d5
	or.b	d5,(a3)
	ENDR
	add.w	d6,a0
	subq.l	#1,a3
	REPT	7
	and.b	d3,(a3)
	move.b	(a0),d5
	move.b	(a2,d5.w),d5
	or.b	d5,(a3)
	subq.l	#2,a0
	subq.l	#2,a3
	ENDR
	and.b	d3,(a3)
	move.b	(a0),d5
	move.b	(a2,d5.w),d5
	or.b	d5,(a3)
	add.w	d6,a0
	add.w	d6,a3
	dbra	d0,afspfhlxi
	add.w	#_lwidth,a1
	dbra	d1,afspfhlyi
	rts



; ****************************************************
; Affichage de sprite avec flip horizontal et vertical
; Cr‚ation automatique du masque
; Vitesse : 30 blocs de 128x128 par seconde
;           24 pour une adresse impaire
; Registres utilis‚s : d0-d7/a0-a3
; ****************************************************

affsprite_fliphv:
	move.l	adrspr(pc),a0	; a0 adresse du sprite
	move.l	adraff(pc),a1	; a1 adresse d'affichage
	lea.l	octenvers(pc),a2	; a2 pointe table d'octets
	move.w	(a0)+,d0
	move.w	d0,d2		; d2 = largeur
	addq.w	#1,d0
	lsl.w	#4,d0
	add.w	d0,a1		; a1 pointe … droite du sprite
	move.w	(a0)+,d1		; d1 = hauteur
	move.w	d1,d0
	mulu.w	#_lwidth,d0
	add.l	d0,a1		; a1 pointe maintenant l'angle B-D
	move.w	a1,d0
	btst	#0,d0
	bne	affspr_fhv_imp
	move.w	d2,-(sp)
	move.w	#255,d0
afspfhvly:	move.l	a1,a3		; a3 adresse d'affichage utilis‚e
	move.w	(sp),d2		; d2 compteur x utilis‚
afspfhvlx:

; Constitution du masque
	move.w	(a0)+,d7
	REPT	7
	or.w	(a0)+,d7
	ENDR
	move.w	d7,d6
	lsr.w	#8,d6
	and.w	d0,d7
	move.b	(a2,d6.w),d6	; Inversion des bits du masque
	move.b	(a2,d7.w),d7
	lsl.w	#8,d7
	add.w	d6,d7
	not.w	d7
; Affichage des 8 plans
	moveq	#1,d3		; 2 * 4 = 8 plans
afspfhvlp:	REPT	4
	move.w	-(a3),d6
	and.w	d7,d6		; d6 = combinaison masque-dest.
	move.w	-(a0),d5
	move.w	d5,d4		; Source dans d4 et d5
	lsr.w	#8,d4		; D‚composition en 2 octets
	and.w	d0,d5
	move.b	(a2,d4.w),d4	; Inversion des bits
	move.b	(a2,d5.w),d5
	lsl.w	#8,d5
	add.w	d4,d5
	add.w	d5,d6		; Addition de la source … d6
	move.w	d6,(a3)		; Affiche … l'‚cran
	ENDR
	dbra	d3,afspfhvlp
	add.w	#16,a0		; S‚rie suivante de 8 plans

	dbra	d2,afspfhvlx
	sub.w	#_lwidth,a1	; Ligne suivante
	dbra	d1,afspfhvly
	addq.l	#2,sp
	rts

affspr_fhv_imp:
	moveq	#0,d5
	add.w	#15,a1
	moveq	#15,d6
	move.w	#255,d7
afspfhvlyi:
	move.w	d2,d0		; d0 = largeur
	move.l	a1,a3
afspfhvlxi:
	move.w	(a0)+,d3
	REPT	6
	or.w	(a0)+,d3
	ENDR
	or.w	(a0),d3
	not.w	d3
	move.w	d3,d4
	and.w	d7,d4
	lsr.w	#8,d3
	move.b	(a2,d3.w),d3
	move.b	(a2,d4.w),d4
	subq.l	#2,a3
	and.b	d3,(a3)
	move.b	(a0),d5
	move.b	(a2,d5.w),d5
	or.b	d5,(a3)
	REPT	7
	subq.l	#2,a0
	subq.l	#2,a3
	and.b	d4,(a3)
	move.b	(a0),d5
	move.b	(a2,d5.w),d5
	or.b	d5,(a3)
	ENDR
	add.w	d6,a0
	subq.l	#1,a3
	REPT	7
	and.b	d3,(a3)
	move.b	(a0),d5
	move.b	(a2,d5.w),d5
	or.b	d5,(a3)
	subq.l	#2,a0
	subq.l	#2,a3
	ENDR
	and.b	d3,(a3)
	move.b	(a0),d5
	move.b	(a2,d5.w),d5
	or.b	d5,(a3)
	add.w	d6,a0
	add.w	d6,a3
	dbra	d0,afspfhvlxi
	sub.w	#_lwidth,a1
	dbra	d1,afspfhvlyi
	rts





	DATA

octenvers:		; Tous les nombres de 0 … 255 les bits … l'envers
	DC.b	$00,$80,$40,$C0,$20,$A0,$60,$E0
	DC.b	$10,$90,$50,$D0,$30,$B0,$70,$F0
	DC.b	$08,$88,$48,$C8,$28,$A8,$68,$E8
	DC.b	$18,$98,$58,$D8,$38,$B8,$78,$F8
	DC.b	$04,$84,$44,$C4,$24,$A4,$64,$E4
	DC.b	$14,$94,$54,$D4,$34,$B4,$74,$F4
	DC.b	$0C,$8C,$4C,$CC,$2C,$AC,$6C,$EC
	DC.b	$1C,$9C,$5C,$DC,$3C,$BC,$7C,$FC
	DC.b	$02,$82,$42,$C2,$22,$A2,$62,$E2
	DC.b	$12,$92,$52,$D2,$32,$B2,$72,$F2
	DC.b	$0A,$8A,$4A,$CA,$2A,$AA,$6A,$EA
	DC.b	$1A,$9A,$5A,$DA,$3A,$BA,$7A,$FA
	DC.b	$06,$86,$46,$C6,$26,$A6,$66,$E6
	DC.b	$16,$96,$56,$D6,$36,$B6,$76,$F6
	DC.b	$0E,$8E,$4E,$CE,$2E,$AE,$6E,$EE
	DC.b	$1E,$9E,$5E,$DE,$3E,$BE,$7E,$FE
	DC.b	$01,$81,$41,$C1,$21,$A1,$61,$E1
	DC.b	$11,$91,$51,$D1,$31,$B1,$71,$F1
	DC.b	$09,$89,$49,$C9,$29,$A9,$69,$E9
	DC.b	$19,$99,$59,$D9,$39,$B9,$79,$F9
	DC.b	$05,$85,$45,$C5,$25,$A5,$65,$E5
	DC.b	$15,$95,$55,$D5,$35,$B5,$75,$F5
	DC.b	$0D,$8D,$4D,$CD,$2D,$AD,$6D,$ED
	DC.b	$1D,$9D,$5D,$DD,$3D,$BD,$7D,$FD
	DC.b	$03,$83,$43,$C3,$23,$A3,$63,$E3
	DC.b	$13,$93,$53,$D3,$33,$B3,$73,$F3
	DC.b	$0B,$8B,$4B,$CB,$2B,$AB,$6B,$EB
	DC.b	$1B,$9B,$5B,$DB,$3B,$BB,$7B,$FB
	DC.b	$07,$87,$47,$C7,$27,$A7,$67,$E7
	DC.b	$17,$97,$57,$D7,$37,$B7,$77,$F7
	DC.b	$0F,$8F,$4F,$CF,$2F,$AF,$6F,$EF
	DC.b	$1F,$9F,$5F,$DF,$3F,$BF,$7F,$FF

sprite:	DC.w	7	; Largeur - 1 en multiples de 16 pixels
	DC.w	127	; Hauteur - 1
	REPT	64
	DC.w	$5555,$3333,$0F0F,$00FF,$0000,$0000,$0000,$0
	DC.w	$5555,$3333,$0F0F,$00FF,$FFFF,$0000,$0000,$0
	DC.w	$5555,$3333,$0F0F,$00FF,$0000,$FFFF,$0000,$0
	DC.w	$5555,$3333,$0F0F,$00FF,$FFFF,$FFFF,$0000,$0
	DC.w	$5555,$3333,$0F0F,$00FF,$0000,$0000,$FFFF,$0
	DC.w	$5555,$3333,$0F0F,$00FF,$FFFF,$0000,$FFFF,$0
	DC.w	$5555,$3333,$0F0F,$00FF,$0000,$FFFF,$FFFF,$0
	DC.w	$5555,$3333,$0F0F,$00FF,$FFFF,$FFFF,$FFFF,$0
	DC.w	$AAAA,$8888,$A0A0,$AA00,$AAAA,$AAAA,$AAAA,$0
	DC.w	$AAAA,$8888,$A0A0,$AA00,$0000,$AAAA,$AAAA,$0
	DC.w	$AAAA,$8888,$A0A0,$AA00,$AAAA,$0000,$AAAA,$0
	DC.w	$AAAA,$8888,$A0A0,$AA00,$0000,$0000,$AAAA,$0
	DC.w	$AAAA,$8888,$A0A0,$AA00,$AAAA,$AAAA,$0000,$0
	DC.w	$AAAA,$8888,$A0A0,$AA00,$0000,$AAAA,$0000,$0
	DC.w	$AAAA,$8888,$A0A0,$AA00,$AAAA,$0000,$0000,$0
	DC.w	$AAAA,$8888,$A0A0,$AA00,$0000,$0000,$0000,$0
	ENDR



	BSS

adrspr:	DS.l	1	; Adresse du sprite
adraff:	DS.l	1	; Adresse d'affichage
masque_buffer:		; Zone de cr‚ation du masque
	DS.b	16384
