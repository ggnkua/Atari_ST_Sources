;------------------------------------------------------------
; Revenge Of The Mutant Camels
; ----------------------------
;
; Original hack/pack by Was (Not Was)
;
; New pack with trainer option by MUG U.K(tm), November 1997
;------------------------------------------------------------
	text

	opt	o+

	bra	start

		;0123456789012345678901234567890123456789
realtxt	
	dc.b	27,'E'
	dc.b	27,'p'
	dc.b	'Revenge Of The Mutant Camels+',13,10
	dc.b	27,'q'
	dc.b	'-----------------------------',13,10,10

	dc.b	'Unpacked/Trained/Repacked by MUG U.K',191,13,10,10

	dc.b	'A great game from yesteryear, but not a',13,10
	dc.b	'patch on the original C64 version :)',13,10,10

	dc.b	'Press T for Trainer, Space to continue.',13,10
	dc.b	0

old_sp	dc.l	0

start	movea.l	4(a7),a5
	move.l	#$1e582,d0
	sub.l	a5,d0
	move.l	d0,-(a7)
	move.l	a5,-(a7)
	clr.w	-(a7)
	move.w	#$4a,-(a7)		;mshrink
	trap	#1
	adda.l	#$c,a7

	dc.w	$a00a

	clr.l	-(a7)
	move.w	#$20,-(a7)		;super
	trap	#1
	addq.l	#6,a7
	move.l	d0,old_sp

	clr.w	-(a7)
	move.l	#$70000,-(a7)
	move.l	#$70000,-(a7)
	move.w	#5,-(a7)		;setscreen
	trap	#$e
	adda.l	#$c,a7

	move.w	#0,$ff8240.l
	move.w	#$777,$ff825e.l

	pea	realtxt(pc)
	move.w	#9,-(a7)		;cconws
	trap	#1
	addq.l	#6,a7

;
; Test keyboard for 'T' or any other key
;	
	move.b	#0,infin	; Clear infinite lives flag

key_loop	move.w	#8,-(a7)		;cnecin
	trap	#1
	addq.l	#2,a7

	cmp.b	#$74,d0		; 't' pressed
	beq.s	yes_train
	cmp.b	#$54,d0		; 'T' pressed
	beq.s	yes_train
	cmp.b	#$20,d0		; SPACE pressed
	beq.s	no_train
	bra.s	key_loop

yes_train	move.b	#1,infin	; Yes, we want to cheat

;
; Depack the game
; 
no_train
	lea	packed(pc),a0
	lea	$13f1a,a1
	bsr	depack

	cmp.b	#1,infin
	bne.s	nocheat

	clr.w	$13f1a+$1ea
;
; Do all the relocation stuff before running game
;
nocheat	lea	$13f1a,a0
	adda.l	#$a668,a0
	lea	$40000,a1
	move.l	#$4000,d0
	bsr	relocate
	bra	run_game

patch	lea	$40000,a0
	adda.l	#$3b80,a0
	adda.l	#$32c8,a0
	lea	$70000,a1
	move.l	#$f00,d0
	bsr	relocate
	lea	$6b2c8,a1
	lea	$40000,a0
	adda.l	#$3b80,a0
	move.l	#$cb2,d0
	bsr	relocate
	lea	$40000,a0
	lea	$2a980,a1
	move.l	#$ee0,d0
	bra	relocate

run_game
	move.l	old_sp,-(a7)
	move.w	#$20,-(a7)		;super
	trap	#1
	addq.l	#6,a7

	move.l	#$13e1a,4(a7)
	move.l	#$4e714e71,$13f4e
	move.w	#$4ef9,$163e6
	move.l	#patch,$163e8
	jmp	$13f1a

relocate	
	move.l	(a0),(a1)+
	clr.l	(a0)+
	dbf	d0,relocate
	rts

	include	'depack35.s'

infin	dc.b	0
	even

packed	incbin	'revenge.atm'
	even
