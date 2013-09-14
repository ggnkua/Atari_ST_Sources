;+
; Tstboot.s - Scan all ACSI, SCSI and IDE-AT devices and attempt 
;		to boot from them.
;-

	.globl	_atread
	.globl	_atwrite

.data
msg0:	dc.b	'In Tstblit.prg',13,10,0
.even
msg1:	dc.b	'Read sector 0 failed',13,10,0
.even
msg2:	dc.b	'Read sector 0 succeeded',13,10,0
.even
msg3:	dc.b	'Write last sector failed',13,10,0
.even
msg4:	dc.b	'Write last sector succeeded',13,10,0
.even
msg5:	dc.b	'Read last sector failed',13,10,0
.even
msg6:	dc.b	'Read last sector succeeded',13,10,0
.even
msg7:	dc.b	'Data matched',13,10,0
.even
msg8:	dc.b	'Data did not match',13,10,0
.even

.text	
tbstart:
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,ostack	; ostack = old stack value
	
tb0:	
	pea	msg0		; Entering program!
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp		; clean up stack
	
				; Reading sector 0
	move.w	#$10,-(sp)	; AT unit 0
	move.l	#buf,-(sp)	; buffer address
	move.w	#2,-(sp)	; 1 sector
	move.l	#0,-(sp)	; sector 0
	move.w	#34,-(sp)	; 34 sectors per track
	move.w	#2,-(sp)	; 2 heads
	bsr	_atread		; _atread()
	add.l	#16,sp		; clean up stack
	tst.w	d0		; successful?
	beq	tb1		; if yes -> more testing
				; if no, quit
	pea	msg1		; fail on reading sector 0
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp		; clean up stack
	bra	tbend

tb1:	pea	msg2		; success on reading sector 0
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp		; clean up stack
				; Writing to last sector
	lea	buf,a0		; a0 -> buf
	move.l	$1c2(a0),d1	; d1 = hard disk size
	subq.l	#1,d1		; d1 = last sector
	move.l	d1,-(sp)	; save sector number
	move.w	#$10,-(sp)	; AT unit 0
	move.l	a0,-(sp)	; buffer address
	move.w	#2,-(sp)	; 1 sector
	move.l	d1,-(sp)	; last sector
	move.w	#34,-(sp)	; 34 sectors per track
	move.w	#2,-(sp)	; 2 heads
	bsr	_atwrite	; _atwrite()
	add.l	#16,sp		; clean up stack
	move.l	(sp)+,d1	; restore sector number
	tst.w	d0		; successful?
	beq	tb3		; if yes - more testing
				; if no - quit	
	pea	msg3		; fail on writing last sector
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp		; clean up stack
	bra	tbend

tb3:	pea	msg4		; success on writing last sector
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp		; clean up stack
	
				; Reading last sector
	move.w	#$10,-(sp)	; AT unit 0
	move.l	#buf2,-(sp)	; buffer address
	move.w	#2,-(sp)	; 1 sector
	move.l	d1,-(sp)	; last sector
	move.w	#34,-(sp)	; 34 sectors per track
	move.w	#2,-(sp)	; 2 heads
	bsr	_atread		; _atread()
	add.l	#16,sp		; clean up stack
	tst.w	d0		; successful?
	beq	tb2		; if yes - more testing
				; if no - quit	
	pea	msg5		; fail on reading last sector
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp		; clean up stack
	bra	tbend

tb2:	pea	msg6		; success on reading last sector
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp		; clean up stack
	
				; compare data read with data written
	moveq	#63,d0		; dbra like one less
	lea	buf,a0
	lea	buf2,a1
tb4:	cmpm.l	(a0)+,(a1)+
	bne	tb5
	dbra	d0,tb4

	pea	msg7		; all data matches
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp		; clean up stack
	bra	tbend

tb5:	pea	msg8		; data read differs from data written
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp		; clean up stack
;-


tbend:	move.l	ostack,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	clr.w	-(sp)		; Pterm0()
	trap	#1
	illegal

.bss
ostack:	ds.l	1
buf:	ds.b	512*256
buf2:	ds.b	512*256
tbkeep: