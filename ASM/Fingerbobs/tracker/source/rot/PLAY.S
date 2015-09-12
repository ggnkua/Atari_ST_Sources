;-------------------------------------------------------------------------
;
; Fingerbobs STE Noisetracker Module Player 
; ROT file player
;
; 6/2/91 (c)1990 A.Buchanan ( Oberje' )
;
; Play a Noisetracker/Soundtracker module using STE DMA soundchip.
;
;-------------------------------------------------------------------------

start	bsr	reloc		; Relocate player module
	pea	run		; Execute program in supervisor mode
	move.w	#$26,-(a7)
	trap	#14
	addq.l	#6,a7
	clr	-(a7)		; Exit
	trap	#1

;
; Main program
;
run	move.b	#$12,$fffffc02.w	; Mouse off

	move.l	#1,d0		; 12 KHz
	move.l	#music_at,a0	; Module start addr
	bsr	code+28+4	; Init
	bsr	code+28+8	; Start
	move.l	#vbl,$4d6.w	; VBL

program move.w	#37,-(a7)	; Space to stop
	trap	#14		
	addq.l	#2,a7		
	move.w	#$ff,-(a7)	
	move.w	#6,-(a7)	
	trap	#1		
	addq.l	#4,a7		
	tst.w	d0		
	beq	program		
	cmp.b	#" ",d0
	bne	program
	
	move.l	#0,$4d6.w	; VBL Off
	bsr	code+28+12	; Stop
	move.b	#$8,$fffffc02.w	; Mouse on
	rts

vbl	bsr	code+28+16		; VBL
	rts

;
; Relocate .ROT file
;
reloc	lea	code(PC),a0
	move.l	2(a0),d0
	add.l	$6(a0),d0
	add.l	$E(a0),d0
	lea	$1C(a0),a0
	move.l	a0,a1
	move.l	a0,a2
	move.l	a0,d1
	add.l	d0,a1
	move.l	(a1)+,d0
	add.l	d0,a2
	add.l	d1,(a2)
	moveq	#0,d0
rel_lp	move.b	(a1)+,d0
	beq.s	reldone
	cmp.b	#1,d0
	beq.s	rel_1
	add.l	d0,a2
	add.l	d1,(a2)
	bra.s	rel_lp
rel_1	lea	$fe(a2),a2
	bra.s	rel_lp
reldone	rts

code	incbin	ste.rot			; Tracker .ROT code

	even

music_at	incbin	<your module here>



