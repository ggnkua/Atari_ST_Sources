; ----------
; Trifide 2+
; ----------

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

yes	equ	1
no	equ	0

ice	equ	no
atom	equ	yes

	opt	o+

	text
begin
	bra	start
	dc.b	'Unpacked,trained & repacked by '
	dc.b	'MUG U.K',191,' 23/10/97 - mikemee@lineone.net - '
	
	dc.b	'This game has 4 seperate parts to depack, so rip'
	dc.b	'the chunks out properly :) .... '

	dc.b	'RT97',0
	even

start	clr.w	-(a7)
	move.l	#-1,-(a7)
	move.l	#-1,-(a7)
	move.w	#5,-(a7)		;setscreen
	trap	#$e
	adda.l	#$c,a7

	dc.w	$a00a

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

no_train	
	clr.l	-(a7)
	move.w	#$20,-(a7)		;super
	trap	#1
	addq.l	#6,a7
	move.l	d0,old_sp

;
; This bit of code depacks all the four files into their
; correct addresses.  Had to alter the original routine due to
; Atomik being a much better packer :)
;
	lea	packed1(pc),a0
	move.l	a0,-(a7)
	move.l	#packed2,a0	; was adda.l #$xxxx,a0
	move.l	a0,-(a7)
	move.l	#packed3,a0
	move.l	a0,-(a7)
	move.l	#packed4,a0
	lea	$60000,a1
	bsr.s	depack
	movea.l	(a7)+,a0
	lea	$58000,a1
	bsr.s	depack
	movea.l	(a7)+,a0
	lea	$50000,a1
	bsr.s	depack
	movea.l	(a7)+,a0
	lea	$13f1a,a1
	bsr.s	depack
	lea	$26ddc,a0
	lea	$50000,a1
makezero	clr.l	(a0)+
	cmpa.l	a0,a1
	bne.s	makezero

;
; Will sir be cheating ?  I'll just check .....
	cmp.b	#1,infinite

; No ..
	bne.s	run_game

; Oh sir, can't you play this properly yet ?

	move.w	#$63,$13f1a+$2e30	; 99 Lives - should be enough ?


run_game	nop
	nop

	dc.w	$a009

	move.l	#old_sp,-(sp)
	move.w	#$20,-(a7)		;super
	trap	#1
	addq.l	#6,a7
	
	jmp	$13f1a

get_key	move.w	#8,-(a7)		;cnecin
	trap	#1
	addq.l	#2,a7
	rts

; include appropriate depack source code

	ifne	ice
	include	'ice_a0a1.s'
	elseif
	include	'depack35.s'
	endc

	data

infinite	dc.b	0
	even

introtxt	dc.b	27,'E'
	dc.b	'----------',13,10
	dc.b	'Trifide 2+',13,10
	dc.b	'----------',13,10,10
	dc.b	'Unpacked, trained & repacked by:',13,10,10
	dc.b	'MUG U.K',191,' on 23/10/97!',13,10,10

	dc.b	'Another ancient game gets a cheat',13,10
	dc.b	'thrust upon it (after a lot of hassle',13,10
	dc.b	'due to the way it was packed by LSD!).',13,10,10

	dc.b	"'T' for trainer, SPACE to depack.",13,10,10,0
	even

new_pal	dc.w	$000,$000,$000,$000
	dc.w	$000,$000,$000,$000
	dc.w	$000,$000,$000,$000
	dc.w	$000,$000,$000,$777

old_sp	dc.l	0

packed1	incbin	'trif1.atm'
	even

packed2	incbin	'trif2.atm'
	even

packed3	incbin	'trif3.atm'
	even

packed4	incbin	'trif4.atm'
	even

zuend	dc.b	'RT97'
	dc.w	0
	even
