; --------------------------------------------------------------------
; Several routines
; --------------------------------------------------------------------

	.EXPORT	swap
	.EXPORT	mode_68000
	.EXPORT	current_freq
	.EXPORT	freq_falcon
	.EXPORT poke

TRUE	equ	1
FALSE	equ 0

	text
	
swap:
	swap	d0
	rts	

poke:
	move.b	d1,(a0,d0)
	rts

; ------------------------------------------------------------------
; 68000 state on mega STe
; returns FALSE/TRUE in d0 if 16MHz+cache is OFF/ON
; ------------------------------------------------------------------

mode_68000:
	movem.l	d1-d7/a0-a6,-(a7)
	pea		test_68(pc)
	move.w	#$26,-(a7)
	trap	#14
	addq.l	#6,a7
	movem.L	(a7)+,d1-d7/a0-a6
	move.w	r_68,d0
	rts
	
test_68:
	moveq	#0,d0
	move.b	$ffff8e21.w,d0
	and.w	#3,d0
	cmpi.w	#3,d0
	bne.b	pas_16
	move.w	#0,r_68
	rts
pas_16:
	move.w	#8,r_68
	rts
	
r_68: ds.w 1

; ------------------------------------------------------------------
; Current Frequency on STe, MSTe or TT
; returns in d0 the current replay frequency
; ------------------------------------------------------------------

current_freq:
	movem.l	d1-d7/a0-a6,-(a7)
	pea		test_freq(pc)
	move.w	#$26,-(a7)
	trap	#14
	addq.l	#6,a7
	movem.l	(a7)+,d1-d7/a0-a6
	move.w	r_freq,d0
	rts
	
test_freq:
	moveq	#0,d0
	move.b	$ffff8921.w,d0
	move.w	d0,r_freq
	rts
	
r_freq:	ds.w	1

; -----------------------------------------------------------------------
; Returns in d0 if the FALCON030 speed is 8 or 16MHZ (FALSE/TRUE)
; -----------------------------------------------------------------------

freq_falcon:
	movem.l	d1-d7/a0-a6,-(a7)
	pea		test_falcon(pc)
	move.w	#$26,-(a7)
	trap	#14
	addq.l	#6,a7
	movem.l	(a7)+,d1-d7/a0-a6
	move.w	r_freq,d0
	rts
	
test_falcon:
	btst	#0,$ffff8007.w
	beq.s	r_false
	move.w	#1,r_freq
	rts
r_false:
	move.w	#0,r_freq
	rts	