; -------------
; Eagles Nest +
; -------------

; -------------------------------------------------------------------
; Unpacked, Trained & Repacked by MUG U.K(tm) of Regression Therapy !
; -------------------------------------------------------------------

; Bits removed/altered:
; ---------------------
;
; a) Removed Ozzwalds' Text Encryption!
; b) Added a trainer option
; c) Repacked game data using Atomik 3.5
; d) A few optimizations
; -------------------------------------------------------------------

	opt	o+

	text

	bra.s	start
	dc.b	'Unpacked,trained & repacked by '
	dc.b	'MUG U.K',191,' 23/10/97 - mikemee@lineone.net - '
	dc.b	'RT97',0
	even

start	lea	$80000,a7

	clr.w	-(a7)
	move.l	#$78000,-(a7)
	move.l	#$78000,-(a7)
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
key_loop	bsr	get_key
	cmp.b	#$74,d0		; 't' pressed
	beq.s	yes_train
	cmp.b	#$54,d0		; 'T' pressed
	beq.s	yes_train
	cmp.b	#$20,d0		; SPACE pressed
	beq.s	no_train
	bra.s	key_loop

yes_train	move.b	#1,infinite	; Yes, we want to cheat

no_train	clr.l	-(a7)
	move.w	#$20,-(a7)		;super
	trap	#1
	addq.l	#6,a7

	clr.w	$ff8240
	clr.w	$ff825e

;
; Do Eagles Nest picture
;
do_pic2
	lea	$77fde,a1
	lea	pic_2,a0
	bsr.s	depack

	movem.l	$77fe0,d0-d7
	movem.l	d0-d7,$ff8240

;
; Depack main game data
;

do_game
	lea	$20000,a1
	lea	game,a0
	bsr.s	depack

	move.l	#$abcdef,$41c.l

	cmp.b	#1,infinite
	bne.s	run_game

; Memory locations for variables
;
; $700dc = Keys
; $7009c = Ammo  
; $7009e = Hits

	move.w	#$4e71,$20000+$514e4	; No Bullets decrease
	move.w	#$4e71,$20000+$532f6	; No Hits increase
	move.w	#$4e71,$20000+$52aae	; No Keys decrease


run_game
	jmp	$70000

get_key	move.w	#8,-(a7)		;cnecin
	trap	#1
	addq.l	#2,a7
	rts

	include	'depack35.s'

	data

infinite	dc.b	0
	even

introtxt	dc.b	27,'E'
	dc.b	'----------------------',13,10
	dc.b	'Into The Eagles Nest +',13,10
	dc.b	'---------------------',13,10,10
	dc.b	'Unpacked, trained & repacked by:',13,10,10
	dc.b	'MUG U.K',191,' on 23/10/97!',13,10,10
	dc.b	'One of my favourite games on both the',13,10
	dc.b	'ZX Spectrum or Atari ST !',13,10,10
	dc.b	'Trainer gives infinite hits, ammo and',13,10
	dc.b	'keys - you must pick 1 key up though :)',13,10,10
	dc.b	"'T' for trainer, SPACE to depack.",13,10,10,0
	even

new_pal	dc.w	$000,$000,$000,$000
	dc.w	$000,$000,$000,$000
	dc.w	$000,$000,$000,$000
	dc.w	$000,$000,$000,$777

game	incbin	'game.atm'
	even

pic_2	incbin	'pic2.atm'
	even

endbit	dc.b	'RT97'
	end