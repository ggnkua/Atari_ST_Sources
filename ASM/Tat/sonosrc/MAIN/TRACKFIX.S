;----------------------------------------------------
; "Twiddle" music

fix_music:
	move.l	aon_modulestart(a6),a0
	move.l	#"PLST",d0

	move.l	a0,a1
.search	cmp.l	(a1),d0
	beq.b	.ok
	addq.l	#2,a1
	bra.b	.search
.ok	addq.l	#8,a1

	lea	new_patterns,a0
	moveq	#$44-1,d0
.copy	move.b	(a0)+,(a1)+
	dbf	d0,.copy
	rts

	dc.b	$0d			;nearly null pattern
	dc.b	$0e,$0f,$10,$11
	dc.b	$12,$12,$13
	dc.b	$13,$14

new_patterns:
melody_pattern = *-new_patterns
	; Melody intro
	dc.b	$15
	dc.b	$16,$17,$18,$19

	; Beat kicks in, cymbal
beat1_pattern = *-new_patterns
	dc.b	$1e,$1e,$1a
	; Roll
	dc.b	$21
	; Square wave added
	dc.b	$1b,$1d,$22
	; Roll
	dc.b	$23

cymbals_pattern = *-new_patterns
	; Cymbals left/right (explosion?)
	dc.b	$24

	; Staccato, slow build
	dc.b	$25,$26,$27
	dc.b	$2b,$2c
	dc.b	$28,$29,$2a	;,$29,$2a

	; Staccato build
	dc.b	$20,$33		;,$20
	dc.b	$20,$2d
	dc.b	$2e,$2f
	dc.b	$31,$32
	dc.b	$30,$00

	; JMJ bits (can't be removed)
	dc.b	$34,$35,$36,$37
end_pattern = *-new_patterns
	; STOP!
	dcb.b	20,$38			;repeats indefinitely
	;dc.b	$38

	dc.b	$07,$07
	dc.b	$02,$03,$04,$05
	dc.b	$06,$07,$08,$09
	dc.b	$0a,$0b,$0c
	; restart

	ifne 0
original_patterns:
	dc.b	$0d			;nearly null pattern
	dc.b	$0e,$0f,$10,$11
	dc.b	$12,$12,$12,$12
	dc.b	$13,$13,$14,$15
	dc.b	$16,$17,$18,$19
	; Beat kicks in
	dc.b	$1e,$1e,$1a,$21
	dc.b	$1b,$1d,$22,$23
	dc.b	$24,$25,$26,$27
	dc.b	$2b,$2c,$28,$29

	dc.b	$2a,$29,$2a,$20,$33,$20
	dc.b	$20,$2d,$2e,$2f
	dc.b	$31,$32
	dc.b	$30,$30,$30,$30
	dc.b	$30,$00
	dc.b	$34,$35,$36,$37
	; STOP!
	dc.b	$38
	dc.b	$07,$07
	dc.b	$02,$03,$04,$05
	dc.b	$06,$07,$08,$09
	dc.b	$0a,$0b,$0c
	; restart
	endc

	even
