; --------
; Plutos +
; --------

; -------------------------------------------------------------------
; Unpacked, Trained & Repacked by MUG U.K(tm) of Regression Therapy !
; -------------------------------------------------------------------

; Bits removed/altered:
; ---------------------
;
; a) Removed Ozzwalds' Text Encryption!
; b) Added a trainer option
; c) Repacked game data using Atomik 3.5e
; d) A few optimizations
;
; Original size of program:	47060
; New size of program:	32863 (Thanks to Atomik)
; -------------------------------------------------------------------

	opt	o+

	text
begin
	bra.s	start
	dc.b	'Unpacked,trained & repacked by '
	dc.b	'MUG U.K',191,' 23/9/97 - mikemee@lineone.net - '
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

no_train	
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,old_sp
	
	bsr.s	unpack

;
; Will sir be cheating ?  I'll just check .....
	cmp.b	#1,infinite

; No ..
	bne.s	run_game

; Oh sir, can't you play this properly yet ?

; Crap fuel cheat
; Was removed seeing as I found infinite lives for both players 
;	move.w	#$0000,$1c10e	; SUB.W #1 -> SUB.W #0 :)

; Infinite lives for both players
	move.b	#$4a,$1161a+$28b6
	move.b	#$4a,$1161a+$29bc

run_game	nop
	nop

	move.l	#old_sp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

; Set up some registers as per original hack/pack

	move.l	#$590be,d0
	movea.l	#$1151a,a5
	movea.l	#$2d69e,a7


	jmp	$1165c

get_key	move.w	#8,-(a7)		;cnecin
	trap	#1
	addq.l	#2,a7
	rts

unpack	lea	packed_data(pc),a0
	lea	$1161a,a1

	include	'depack35.s'

	data

infinite	dc.b	0
	even

old_sp	dc.l	0

introtxt	dc.b	27,'E'
	dc.b	'--------',13,10
	dc.b	'Plutos +',13,10
	dc.b	'--------',13,10,10
	dc.b	'Unpacked, trained & repacked by:',13,10,10
	dc.b	'MUG U.K',191,' on 21/9/97!',13,10,10

	dc.b	'All hacking done using Pacifist (0.46)',13,10
	dc.b	'and TOSBox emulators!',13,10,10

	dc.b	'Due to the keyboard not emulated very',13,10
	dc.b	'well in Pacifist, play this game using',13,10
	dc.b	'a proper joystick, or it crashes!',13,10,10
	
	dc.b	"'T' for trainer, SPACE to depack.",13,10,10,0
	even

new_pal	dc.w	$000,$000,$000,$000
	dc.w	$000,$000,$000,$000
	dc.w	$000,$000,$000,$000
	dc.w	$000,$000,$000,$777

packed_data	incbin	'plutos.atm'
	even

zuend	dc.b	'RT97'
	dc.w	0
	even