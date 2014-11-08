; ----------
; 3D Galax +
; ----------

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
	dc.b	'MUG U.K',191,' 22/10/97 - mikemee@lineone.net - '
	dc.b	'RT97',0
	even

start	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	move.l	d0,old_sp

	lea	$80000,a7

	dc.w	$a00a

	clr.w	-(a7)
	move.l	#$60000,-(a7)
	move.l	#$60000,-(a7)
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

no_train	nop
	
	move.w	#0,$ff825e.l

	lea	packed(pc),a0
	lea	$31e62,a1
;	lea	$40000,a1
;	suba.l	#$e19e,a1
	bsr	depack

;	lea	$40000,a1
;	suba.l	#$e19e,a1

	lea	$31e62,a1
	lea	$1161a,a0
	move.l	#$70ce,d0
l0006	move.w	(a1),(a0)+
	clr.w	(a1)+
	dbf	d0,l0006

	move.l	#old_sp,-(a7)
	move.w	#$20,-(a7)		;super
	trap	#1
	addq.l	#6,sp

	lea	$77ff8,a7

	move.w	#$4e71,$1162e
	lea	patch(pc),a1
	lea	$12176,a0
	moveq	#6,d0
l0007	move.l	(a1)+,(a0)+
	dbf	d0,l0007

;
; Will sir be cheating ?  I'll just check .....
	cmp.b	#1,infinite

; No ..
	bne.s	run_game

; Oh sir, can't you play this properly yet ?

	clr.w	$1161a+$596
	clr.w	$1161a+$6fa


run_game
	jmp	$1161a

patch	move.l	#$100000,d0
pat_loop	subq.l	#1,d0
	cmp.l	#0,d0
	bne.s	pat_loop
	rts

get_key	move.w	#8,-(a7)		;cnecin
	trap	#1
	addq.l	#2,a7
	rts


	include	'ice_a0a1.s'

	data

old_sp	dc.l	0

infinite	dc.b	0
	even

introtxt	dc.b	27,'E'
	dc.b	'----------',13,10
	dc.b	'3D Galax +',13,10
	dc.b	'----------',13,10,10
	dc.b	'Unpacked, trained & repacked by:',13,10,10
	dc.b	'MUG U.K',191,' on 22/10/97!',13,10,10
	dc.b	"One of Benn Daglishs' better tunes :)",13,10,10
	dc.b	"'T' for trainer, SPACE to depack.",13,10,10,0
	even

new_pal	dc.w	$000,$000,$000,$000
	dc.w	$000,$000,$000,$000
	dc.w	$000,$000,$000,$000
	dc.w	$000,$000,$000,$777

packed	incbin	'galax.ice'
	even

zuend	dc.b	'RT97'
	dc.w	0
	even
