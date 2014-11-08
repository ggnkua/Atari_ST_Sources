; -----------
; Arkanoid 3+
; -----------

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
;
; Original size of program:	47060
; New size of program:	41787 (Thanks to ICE v2.40!)
; -------------------------------------------------------------------

	opt	o+

	text
begin
	bra.s	start
	dc.b	'Unpacked,trained & repacked by '
	dc.b	'MUG U.K',191,' 07/10/97 - mikemee@lineone.net - '
	dc.b	'More coming soon! :)',0

start	clr.w	-(a7)
	move.l	#$78000,-(a7)
	move.l	#$78000,-(a7)
	move.w	#5,-(a7)		;setscreen
	trap	#$e
	adda.l	#$c,a7

	dc.w	$a00a

	pea	newpal(pc)
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

no_train	pea	$77ff8

	move.w	#$20,-(a7)		;super
	trap	#1
	addq.l	#6,a7
	move.l	d0,old_sp

	lea	picture,a0
	lea	$5ffde,a1
	bsr	depack

	lea	$60000,a0
	lea	$78000,a1
	move.w	#$7d00,d0
l0006	move.b	(a0)+,(a1)+
	dbf	d0,l0006

	move.w	#$003,$ffff825e.w

	lea	game,a0
	lea	$30000,a1
	bsr	depack

	lea	$78000,a0
	lea	$28000,a1
	move.w	#$7d00,d0
relo_loop	move.b	(a0)+,(a1)+
	dbf	d0,relo_loop

	move.l	old_sp,-(a7)
	move.w	#$20,-(a7)		;super
	trap	#1
	addq.l	#6,a7

;
; Will sir be cheating ?  I'll just check .....
	cmp.b	#1,infinite

; No ..
	bne.s	run_game

; Oh sir, can't you play this properly yet ?

	move.b	#$4A,$3342E


run_game	dc.w	$a009
	nop
	nop
	jmp	$30000

	include	'ice_a0a1.s'

get_key	move.w	#8,-(a7)		;cnecin
	trap	#1
	addq.l	#2,a7
	rts

newpal	dc.w	$0000,$0700,$0370,$0730
	dc.w	$0660,$0077,$0040,$0400 
	dc.w	$0555,$0333,$0625,$0777 
	dc.w	$0007,$0006,$0004,$0777 

old_sp	dc.l	2

infinite	dc.b	1
	even

introtxt	dc.b	27,'E'
	dc.b	'------------',13,10
	dc.b	'Arkanoid 3 +',13,10
	dc.b	'------------',13,10,10
	dc.b	'Unpacked, trained & repacked by:',13,10,10
	dc.b	'MUG U.K',191,' on 07/10/97!',13,10,10
	dc.b	'Hi to all on the Pacifist Mailing List!',13,10,10  
	dc.b	"'T' for trainer, SPACE to depack.",13,10,10
	dc.b	"Press 1/2 to start 1/2 player game!",13,10
	dc.b	0
	even

game	incbin	'ark3_gam.ice'
	even

picture	incbin	'ark3_pic.ice'
	even