; ---------
; Wizball +
; ---------

; -------------------------------------------------------------------
; Unpacked, Trained & Repacked by MUG U.K(tm) of Regression Therapy !
; -------------------------------------------------------------------

; Bits removed/altered:
; ---------------------
;
; a) Added a trainer option
; b) Repacked game data using ICE v2.40 which made it bigger, 
;    but the game depacks faster!!
;
; Original size of program:	111894
; New size of program:	117303 ('coz JAM is better than ICE!)
; -------------------------------------------------------------------

	opt o+,ow+

	text
	bra.s	begin
	dc.b	'Unpacked,trained & repacked by '
	dc.b	'MUG U.K',191,' 20/9/97 - mikemee@lineone.net - '
	dc.b	'More coming soon! :)',0
	even
begin
	lea	$77d00,a7		; new stack below screen

	clr.w	-(a7)		; low resolution
	pea	$78000		; 512k screen boundary
	move.l	(a7),-(a7)	;
	move.w	#5,-(a7)		; set screen
	trap	#$e
	lea	12(a7),a7

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

no_train	pea	start(pc)
	move.w	#$26,-(a7)		;supexec
	trap	#$e

start	lea	pic_pak,a0	; depack picture to screen
	lea	$77fde,a1
        bsr     depack

	movem.l	$77fe0,d0-d7	; change palette for unpacked pic
	movem.l	d0-d7,$ff8240.l

	lea	game_pak,a0	; depack main game data
	lea	$17fde,a1
        bsr.s   depack

	lea	$80000,a7		; stack now at top of 512K memory

	lea	l0002(pc),a0	; relocate this routine to near top
	lea	$77d00,a1
	move.l	#$d0,d0
l0001	move.b	(a0)+,(a1)+
	dbf	d0,l0001
	move	#$2300,sr

;
; Test infinite lives flag and then run game ?
;

	cmp.b	#1,infinite
	bne.s	run_game

	move.l	#$4e714e71,$5ad90	; NOP out SUB.W #1,$58FC4 !!
	move.w	#$4e71,$5ad94	

run_game	jmp	$58000

;
; This is the routine that is relocated to $77d00
; It moves 8302 bytes of data from $37fde to $ffde
;

l0002	movea.l	(a7),a2
	lea	$37fde,a0
	lea	$ffde,a1
	move.l	#$1f60,d0		; 8032 bytes
l0003	move.l	(a0)+,(a1)+
	dbf	d0,l0003
	jmp	(a2)

get_key	move.w	#8,-(a7)		;cnecin
	trap	#1
	addq.l	#2,a7
	rts

        include 'ice_a0a1.s'

	data

infinite	dc.b	0
	even

introtxt	dc.b	27,'E'
	dc.b	'--------',13,10
	dc.b	'Wizball+',13,10
	dc.b	'--------',13,10,10
	dc.b	'Unpacked, trained & repacked by:',13,10,10
	dc.b	'MUG U.K',191,' on 20/9/97!',13,10,10
	dc.b	'All coding done using Pacifist (0.46)',13,10
	dc.b	'and TOSBox emulators!',13,10,10
	dc.b	'Hi to all on the Pacifist Mailing List!',13,10,10  
	dc.b	"'T' for trainer, SPACE to depack.",13,10,10,0
	even

new_pal	dc.w	$000,$000,$000,$000
	dc.w	$000,$000,$000,$000
	dc.w	$000,$000,$000,$000
	dc.w	$000,$000,$000,$777

game_pak	incbin	'chunk_1.ice'
	even

pic_pak	incbin	'chunk_2.ice'
	even

the_end	dc.b	'RT97'
	even
