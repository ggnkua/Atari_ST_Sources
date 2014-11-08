; ------------
; Army Moves +
; ------------

; -------------------------------------------------------------------
; Unpacked, Trained & Repacked by MUG U.K(tm) of Regression Therapy !
; -------------------------------------------------------------------

; Bits removed/altered:
; ---------------------
;
; a) Removed Ozzwalds' Text Encryption!
; b) Improved the trainer option!
; c) Repacked game data using ICE v2.40
; d) A few optimizations
; -------------------------------------------------------------------
	opt	o+

	text
begin
	bra.s	start
	dc.b	'Unpacked,trained & repacked by '
	dc.b	'MUG U.K',191,' 26/9/97 - mikemee@lineone.net - '
	dc.b	'More coming soon! :)',0

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
        bsr.s   unpack

;
; Will sir be cheating ?  I'll just check .....
	cmp.b	#1,infinite

; No ..
	bne.s	run_game

; Oh sir, can't you play this properly yet ?
	move.b	#$ff,$1d995
	move.b	#$ff,$1e149

run_game	nop
	nop
	move	#$2700,sr
	jmp	$505b2

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

unpack  lea     packed(pc),a0
	lea	$1d814,a1

        include 'ice_a0a1.s'

	data
	
infinite	dc.b	0
	even

introtxt	dc.b	27,'E'
	dc.b	'------------',13,10
	dc.b	'Army Moves +',13,10
	dc.b	'------------',13,10,10
	dc.b	'Unpacked, not-trained & repacked by:',13,10,10
	dc.b	'MUG U.K',191,' on 26/9/97!',13,10,10
	dc.b	"This game already had a trainer !  It",13,10
	dc.b	'made less work for me to do :)',13,10,10
	dc.b	'I also removed the loading picture ....',13,10,10
	dc.b	'Hi to all on the Pacifist Mailing List!',13,10,10  
	dc.b	"'T' for trainer, SPACE to depack.",13,10,10
	dc.b	0
	even

new_pal	dc.w	$000,$000,$000,$000
	dc.w	$000,$000,$000,$000
	dc.w	$000,$000,$000,$000
	dc.w	$000,$000,$000,$777

packed	incbin	'armymove.ice'
	even

zuend	dc.b	'RT97'
	dc.w	0
	even
