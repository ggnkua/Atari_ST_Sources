; -------------
; Moon Patrol
; -------------

; -------------------------------------------------------------------
; Unpacked, Not-Trained & Repacked by MUG U.K(tm) of Regression Therapy !
; -------------------------------------------------------------------

; Bits removed/altered:
; ---------------------
;
; a) Removed Ozzwalds' Text Encryption!
; b) Repacked game data using Atomik 3.5
; c) A few optimizations
; -------------------------------------------------------------------

	opt	o+

	text
begin
	bra.s	start
	dc.b	'Unpacked,not-trained & repacked by '
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
;	move.b	#0,infinite	; Clear infinite lives flag
;key_loop	bsr.s	get_key
;	cmp.b	#$74,d0		; 't' pressed
;	beq.s	yes_train
;	cmp.b	#$54,d0		; 'T' pressed
;	beq.s	yes_train
;	cmp.b	#$20,d0		; SPACE pressed
;	beq.s	no_train
;	bra.s	key_loop

	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

;yes_train	move.b	#1,infinite	; Yes, we want to cheat

no_train	bsr.s	go_super
	bsr.s	depackit

;
; Will sir be cheating ?  I'll just check .....
;	cmp.b	#1,infinite

; No ..
;	bne.s	run_game

; Oh sir, can't you play this properly yet ?

;	move.b	#$NOCHEAT,BOLLOCKS!


run_game	nop
	nop
	bsr.s	go_super
	jmp	$1b73a

;get_key	move.w	#8,-(a7)		;cnecin
;	trap	#1
;	addq.l	#2,a7
;	rts

go_super	movea.l	(a7)+,a6
	clr.l	-(a7)
	move.w	#$20,-(a7)		;super
	trap	#1
	addq.l	#6,a7
	jmp	(a6)

depackit	lea	packed(pc),a0
	lea	$1b73a,a1

	include	'depack35.s'

	data

;infinite	dc.b	0
;	even

introtxt	dc.b	27,'E'
	dc.b	'-----------',13,10
	dc.b	'Moon Patrol',13,10
	dc.b	'-----------',13,10,10
	dc.b	'Unpacked, not-trained & repacked by:',13,10,10
	dc.b	'MUG U.K',191,' on 23/10/97!',13,10,10

	dc.b	'This is the 2nd of these Williams games',13,10
	dc.b	"that I've not been able to do a cheat",13,10
	dc.b	'for - the code is a nightmare to wade',13,10
	dc.b	'through.  Best of luck if you attempt',13,10
	dc.b	'a trainer on this (and email me if you',13,10
	dc.b	'work one out !).  Addy at start of code.',13,10,10

	dc.b	'Hi to all in the #effect channel I was',13,10
	dc.b	'yakking to tonight (approx. 10pm)!',13,10,10

	dc.b	"Any key to start depacking this game.",13,10,10,0
	even

new_pal	dc.w	$000,$000,$000,$000
	dc.w	$000,$000,$000,$000
	dc.w	$000,$000,$000,$000
	dc.w	$000,$000,$000,$777

packed	incbin	'moonpatr.atm'
	even

zuend	dc.b	'RT97'
	dc.w	0
	even
