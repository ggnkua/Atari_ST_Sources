playdma
; In: a0 - start address of sample
;     a1 - end address of sample
;     d0 - 0: play once ; 1: play looped
;	    d1 - 0=stereo, 1=mono
;	    d2 - 0=6258Hz, 1=12517Hz, 2=25033Hz, 3=50066Hz
	movem.l d3-d5,-(sp)
	move.l a0,d3
	move.l d3,d4
	move.l d3,d5
	and.l #$000000ff,d3
	and.l #$0000ff00,d4
	and.l #$00ff0000,d5
	lsr.l #8,d4
	lsr.l #8,d5
	lsr.l #8,d5
	move.b d5,$ffff8903
	move.b d4,$ffff8905
	move.b d3,$ffff8907
	move.l a1,d3
	move.l d3,d4
	move.l d3,d5
	and.l #$000000ff,d3
	and.l #$0000ff00,d4
	and.l #$00ff0000,d5
	lsr.l #8,d4
	lsr.l #8,d5
	lsr.l #8,d5
	move.b d5,$ffff890f
	move.b d4,$ffff8911
	move.b d3,$ffff8913
	cmp.b #0,d1
	bne .notstereo
	bra .donestereo
.notstereo
	add.b #128,d2
.donestereo
	move.w d2,$ffff8920
	cmp.b #0,d0
	bne .playlooped
	move.w #1,$ffff8900 ; play once
	bra .donelooped
.playlooped
	move.w #3,$ffff8900 ; play looped
.donelooped
	movem.l (sp)+,d3-d5
	rts

playdmastop
	move.w #0,$ffff8900 ; turn off DMA sound
	rts
