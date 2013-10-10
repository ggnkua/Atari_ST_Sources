	bra	ste_sound
	bra	ste_sample
	bra	ste_playing

ste_off	movem.l	d1-d3/a0-a3,-(a7)	
	bsr	super_on
	clr.b	$ffff8901.w
	bsr	super_off
	movem.l	(a7)+,d1-d3/a0-a3
	rts
	
ste_playing
	movem.l	d1-d3/d7/a0-a3,-(a7)	
	bsr	super_on
	moveq	#-1,d7
	lea	$ffff8900.w,a0
	move.b	$3(a0),d0
	cmp.b	$9(a0),d0
	bne.s	.play
	move.b	$5(a0),d0
	cmp.b	$b(a0),d0
	bne.s	.play
	move.b	$7(a0),d0
	cmp.b	$d(a0),d0
	bne.s	.play
.noplay	moveq	#0,d7
.play	bsr	super_off
	move.l	d7,d0
	movem.l	(a7)+,d1-d3/d7/a0-a3
	rts
;
; ste_sample(l:start,l:length,frequency,loop,mode)
;		
ste_sample
	movem.l	d1-d3/a0-a3,-(a7)	
	bsr	super_on
	lea	$ffff8900.w,a0
	clr	(a0)			; stop DMA
	move.b	33(a7),$3(a0)		; start address
	move.b	34(a7),$5(a0)
	move.b	35(a7),$7(a0)
	move.l	36(a7),d0
	add.l	32(a7),d0
	move.l	d0,-(a7)
	move.b	1(a7),$f(a0)		; end address
	move.b	2(a7),$11(a0)
	move.b	3(a7),$13(a0)
	addq.l	#4,a7
	move	40(a7),d0
	and	#%11,d0
	tst	44(a7)
	bne.s	.stereo
.mono	or	#128,d0
.stereo	move	d0,$20(a0)		; frequency and stereo/mono
	move	#1,d0
	tst	42(a7)
	beq.s	.once
.loop	or	#2,d0
.once	move	d0,(a0)			; start DMA
	bsr.s	super_off
	movem.l	(a7)+,d1-d3/a0-a3
	rts
;
; ste_sound(volume,bass,treble,mixer)
;	
ste_sound
	movem.l	d1-d3/a0-a3,-(a7)	
	bsr.s	super_on
	lea	$ffff8900.w,a0
	lea	ste_regs(pc),a1
	moveq	#32,d2
	moveq	#3,d1
.lp	move	(a7,d2),d3
	move	(a1)+,d0
	and	(a1)+,d3
	or	d3,d0
	move	#$7ff,$ffff8924.w
	nop
	move	d0,$ffff8922.w
	addq	#2,d2
	dbf	d1,.lp
	bsr.s	super_off
	movem.l	(a7)+,d1-d3/a0-a3
	rts

super_on
	clr.l	-(a7)
	move	#$20,-(a7)
	trap	#1			; put in supervisor mode
	addq.l	#6,a7
	lea	save_sp(pc),a0
	move.l	d0,(a0)
	rts

super_off
	lea	save_sp(pc),a0
	move.l	(a0),-(a7)
	move	#$20,-(a7)
	trap	#1			; back to user mode
	addq.l	#6,a7
	rts
	
ste_regs
	dc.w	%0000010011000000,%111111	; master volume
	dc.w	%0000010001000000,%001111	; bass
	dc.w	%0000010010000000,%001111	; treble
	dc.w	%0000010000000000,%000011	; mixer

save_sp ds.l	1