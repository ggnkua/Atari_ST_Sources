	text

hz_200	equ	$04ba

	;; Save original sound state in d6.
	move.w	#7,-(sp)
	clr.w	-(sp)
	move.w	#28,-(sp)
	trap	#14
	addq.l	#6,sp
	move.l	d0,d6

	move.w	#16,d0			; Channel A uses envelope
	move.w	#8,d1
	bsr	sndreg
	move.w	#18,d0			; 4 second decay period
	move.w	#11,d1
	bsr	sndreg
	move.w	#122,d0
	move.w	#12,d1
	bsr	sndreg

	lea	scale,a3
	moveq	#7,d3
loop:	move.w	(a3)+,d0		; Load and set frequency
	clr.w	d1
	bsr	sndreg
	lsr.w	#8,d0
	moveq	#1,d1
	bsr	sndreg
	move.w	#62,d0			; Enable channel A
	moveq	#7,d1
	bsr	sndreg
	clr.w	d0			; Gate envelope w/ decay pattern
	move.w	#13,d1
	bsr	sndreg
	move.l	#90,-(sp)		; Hold note for 450 ms
	bsr	delay
	addq.l	#4,sp
	tst.w	d3			; Is this the last note?
	beq	next
	move.w	#63,d0			; If not, cut note for 50 ms
	moveq	#7,d1
	bsr	sndreg
	move.l	#10,-(sp)
	bsr	delay
	addq.l	#4,sp
next:	dbra	d3,loop

	move.l	#810,-(sp)		; Hold final note for 4.5s total
	bsr	delay
	addq.l	#4,sp
	clr.w	d0			; Channel A volume to 0
	moveq	#8,d1
	bsr	sndreg
	move.b	d6,d0			; Restore original channel config
	moveq	#7,d1
	bsr	sndreg
	clr.w	-(sp)			; End program
	trap	#1


;;; Write the byte value in d0 to the sound register in d1.
;;; Preserves all registers!
sndreg:	movem.l	d0-d2/a0-a2,-(sp)
	and.w	#15,d1
	or.w	#128,d1
	move.w	d1,-(sp)
	and.w	#255,d0
	move.w	d0,-(sp)
	move.w	#28,-(sp)
	trap	#14
	addq.l	#6,sp
	movem.l	(sp)+,d0-d2/a0-a2
	rts

;;; delay (longword ticks)
;;; Delay for 'ticks' of the 200hz system clock. Multiply d0 by 5
;;; to get the delay time in milliseconds.
;;; Trashes d0-d2,a0-a2.
delay:	clr.l	-(sp)			; Enter supervisor mode
	move.w	#32,-(sp)		; Super()
	trap	#1			; GEMDOS. User stack in d0.
	move.l	d0,2(sp)		; Set up stack for restoring user mode
	move.w	#32,(sp)

	move.l	10(sp),d0		; d0 = target duration
	add.l	hz_200,d0		; d0 = target time
.buzz:	cmp.l	hz_200,d0		; Wait until timer hits target
	bhi.s	.buzz
	trap	#1			; Restore user mode
	addq.l	#6,sp			; Restore stack
	rts

	data
scale:	dc.w	478,426,379,358,319,284,253,239
