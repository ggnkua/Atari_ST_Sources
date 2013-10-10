;
; 50Hz screen syncroniser.
;
; Written by T.A.King Copyright 1993 Ninth Wave Software
;
; This routine uses the Level 4 interrupt at location $70 to install
; a 50Hz counter. It is a patch which means that the address originally
; at $70 is stored in a JMP instruction at the end of the user interrupt
; routine.
;

	bra	wait_vbi
	bra	stop
	bra	waitvbi
	bra	swap_sync
;
; ~C:swap_sync%(frames,l:physical%,l:logical%)
;
swap_sync
	movem.l	d0-3/a0-3,-(a7)
	move	36(a7),d1		; gt number of frame to wait
	move.l	38(a7),a2		; screen
	move.l	42(a7),a1
swap	lea	frame_count(pc),a0
.pause	move	(a0),d0
	cmp	d1,d0
	blt.s	.pause
	movem.l	d0/a0,-(a7)
	move	#-1,-(a7)
	move.l	a1,-(a7)
	move.l	a2,-(a7)
	move	#5,-(a7)
	trap	#14
	add.l	#12,a7
	movem.l	(a7)+,d0/a0
	move	(a0),d0
.delay	cmp 	(a0),d0
	beq.s	.delay
	clr	(a0)
	movem.l	(a7)+,d0-3/a0-3
	rts

;
; ~C:wait_vbi%()
;
wait_vbi
	movem.l	d0-7/a0-1,-(a7)
	lea	setup(pc),a0
	bset	#0,(a0)
	bne.s	.done			; already setup
	lea	init(pc),a0
	pea	(a0)
	move	#38,-(a7)		; run initialiser in supervisor mode
	trap	#14
	addq.l	#6,a7
.done	movem.l	(a7)+,d0-7/a0-1
	rts
init	lea	vbi(pc),a0
	lea	vexit+2(pc),a1
	move.l	$70.w,(a1)		; repatch level 4 interrupt
	move.l	a0,$70.w		; install new level 4 routine
	rts
;
; ~C:stop%()
;
stop	movem.l	d0-7/a0-1,-(a7)
	lea	setup(pc),a0
	bclr	#0,(a0)
	beq.s	.done
	lea	stp(pc),a0
	pea	(a0)
	move	#38,-(a7)		; run stop interrupt in supervisor
	trap	#14
	addq.l	#6,a7
.done	movem.l	(a7)+,d0-7/a0-1
	rts
stp	lea	vexit+2(pc),a1		; get original level 4 address
	move.l	(a1),$70.w		; reinstall it
	rts
;
; ~C:wait%(frames)
;
waitvbi	movem.l	d0-1/a0,-(a7)
	move	16(a7),d1		; get number of frame to wait
	lea	frame_count(pc),a0
.wait	move	(a0),d0
.delay	cmp 	(a0),d0
	beq.s	.delay
	cmp	(a0),d1
	bge.s	.wait
	clr	(a0)
	movem.l	(a7)+,d0-1/a0
	rts

vbi	move.l	a0,-(a7)		; heres the 50Hz VBL routine
	lea	frame_count(pc),a0
	addq	#1,(a0)			; increase counter
	move.l	(a7)+,a0
vexit	jmp	$0.l			; here's the patch

setup		dc.w	0
frame_count	dc.w	0