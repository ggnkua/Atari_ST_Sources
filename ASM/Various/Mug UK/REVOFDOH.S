; ----------------------------
; Arkanoid 2 - Revenge of Doh+
; ----------------------------

; -------------------------------------------------------------------
; Unpacked, Trained & Repacked by MUG U.K(tm) of Regression Therapy !
; -------------------------------------------------------------------

; Bits removed/altered:
; ---------------------
;
; a) Removed Ozzwalds' Text Encryption!
; b) Added a trainer option
; c) Repacked game data using ICE v2.40
; d) A few optimizations
;; -------------------------------------------------------------------

	opt	o+

	text
begin
	bra.s	start
	dc.b	'Unpacked,trained & repacked by '
	dc.b	'MUG U.K',191,' 23/10/97 - mikemee@lineone.net - '
	dc.b	'RT97',0
	even

start	clr.w	-(a7)
	move.l	#-1,-(a7)
	move.l	#-1,-(a7)
	move.w	#5,-(a7)		;setscreen
	trap	#$e
	adda.l	#$c,a7

	pea	new_pal(pc)
	move.w	#6,-(a7)
	trap	#14
	addq.w	#6,a7

	pea	introtxt(pc)
	move.w	#9,-(a7)		;cconws
	trap	#1
	addq.w	#6,a7
;
; Test keyboard for 'T' or any other key
;	
	move.b	#0,infinite	; Clear infinite lives flag
key_loop	bsr.s	get_key
	cmp.b	#$74,d0		; 't' pressed
	beq.s	yes_train
	cmp.b	#$54,d0		; 'T' pressed
	beq.s	yes_train
	cmp.b	#$20,d0		; SPACE pressed
	beq.s	no_train
	bra.s	key_loop

yes_train	move.b	#1,infinite	; Yes, we want to cheat

no_train	bsr.s	go_super
	bsr.s	depackit

;
; Will sir be cheating ?  I'll just check .....
	cmp.b	#1,infinite

; No ..
	bne.s	run_game

; Oh sir, can't you play this properly yet ?

	move.b	#$50,$628d9
	move.b	#$50,$628e1


run_game	nop
	nop
;	bsr.s	go_super
	jmp	$60000

get_key	move.w	#8,-(a7)		;cnecin
	trap	#1
	addq.l	#2,a7
	rts

go_super	movea.l	(a7)+,a6
	clr.l	-(a7)
	move.w	#$20,-(a7)		;super
	trap	#1
	addq.l	#6,a7
	jmp	(a6)

depackit	lea	packed(pc),a0
	lea	$20000,a1

	include	'ice_a0a1.s'

	data

infinite	dc.b	0
	even

introtxt	dc.b	27,'E'
	dc.b	'------------',13,10
	dc.b	'Arkanoid 2 +',13,10
	dc.b	'------------',13,10,10
	dc.b	'Unpacked, not-trained & repacked by:',13,10,10
	dc.b	'MUG U.K',191,' on 23/10/97!',13,10,10
	dc.b	'Trainer was already done on this one!',13,10,10

	dc.b	'If anyone on the net has an unpacked',13,10
	dc.b	'version of this game, please email me',13,10
	dc.b	'at: mikemee@lineone.net !',13,10,10

	dc.b	'There are some interesting bits of',13,10
	dc.b	'source code left in memory I want to',13,10
	dc.b	'take a proper look at :)',13,10,10

	dc.b	"'T' for trainer, SPACE to depack.",13,10,10,0
	even

new_pal	dc.w	$000,$000,$000,$000
	dc.w	$000,$000,$000,$000
	dc.w	$000,$000,$000,$000
	dc.w	$000,$000,$000,$777

packed	incbin	'revofdoh.ice'
	even

zuend	dc.b	'RT97'
	dc.w	0
	even
