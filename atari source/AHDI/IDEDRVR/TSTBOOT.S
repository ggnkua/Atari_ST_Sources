;+
; Tstboot.s - Scan all ACSI, SCSI and IDE-AT devices and attempt 
;		to boot from them.
;-

	.globl	_dmaread
	.globl	_dmawrite

.data
msg0:	dc.b	'In Tstboot.prg',13,10,0
.even
msg1:	dc.b	'Read sector 0 fails',13,10,0
.even
msg2:	dc.b	'Read sector 0 successes',13,10,0
.even
msg3:	dc.b	'Write last sector fails',13,10,0
.even
msg4:	dc.b	'Write last sector successes',13,10,0
.even
msg5:	dc.b	'Read last sector fails',13,10,0
.even
msg6:	dc.b	'Read last sector successes',13,10,0
.even
msg7:	dc.b	'Data matches',13,10,0
.even
msg8:	dc.b	'Data does not match',13,10,0
.even

.text	
tbstart:
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,ostack	; ostack = old stack value
	
;	moveq	#8,d4		; start with SCSI unit 0
;	moveq	#0,d4		; start with ACSI unit 0
tb0:	
	pea	msg0		; Entering program!
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp		; clean up stack
	
				; Reading sector 0
;	move.w	d4,-(sp)	; dev #
	move.w	#$10,-(sp)	; AT unit 0
	move.l	#buf,-(sp)	; buffer address
	move.w	#1,-(sp)	; 1 sector
	move.l	#0,-(sp)	; sector 0
	bsr	_dmaread	; _dmaread()
	add.l	#12,sp		; clean up stack
	tst.w	d0		; successful?
	beq	tb1		; if yes -> more testing
				; if no, quit
	pea	msg1		; fail on reading sector 0
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp		; clean up stack
	bra	tbend

;+	
;	cmpi.w	#8,d4		; else, ACSI units scanned?
;	blt	tbend		; yes - no bootable unit - done
;	moveq	#0,d4		; else, start with ACSI unit 0
;	bra	tb0
;-

tb1:	pea	msg2		; success on reading sector 0
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp		; clean up stack

;+
				; Writing to last sector
	lea	buf,a0		; a0 -> buf
	move.l	$1c2(a0),d1	; d1 = hard disk size
	subq.l	#1,d1		; d1 = last sector
	move.l	d1,-(sp)	; save sector number
;	move.w	d4,-(sp)	; dev #
	move.w	#$10,-(sp)	; AT unit 0
	move.l	a0,-(sp)	; buffer address
	move.w	#1,-(sp)	; 1 sector
	move.l	d1,-(sp)	; last sector
	bsr	_dmawrite	; _dmawrite()
	add.l	#12,sp		; clean up stack
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
;	move.w	d4,-(sp)	; dev #
	move.w	#$10,-(sp)	; AT unit 0
	move.l	#buf2,-(sp)	; buffer address
	move.w	#1,-(sp)	; 1 sector
	move.l	d1,-(sp)	; last sector
	bsr	_dmaread	; _dmaread()
	add.l	#12,sp		; clean up stack
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


;+
;	move.w	#$0ff,d0	; checksum $100 words
;	moveq	#0,d1		; d1 = 0; initialise sum
;	movea.l	_dskbufp,a0	; a0 -> root sector image
;	adda.l	#$200,a0
;	movea.l	a0,a1		; a1 -> root sector image
;tb2:	add.w	(a0)+,d1	; add next word
;	dbra	d0,tb2		; until all words are added
;	
;	cmpi.w	#$1234,d1	; sum ?= magic number $1234
;	beq	tb3		; yes - continue boot process
;
;	pea	msg3		; print announcement
;	move.w	#9,-(sp)
;	trap	#1
;	addq.w	#6,sp		; clean up stack
;	
;	addq.w	#1,d4		; else, try next unit
;	bra	tb0
;	
;tb3:	pea	msg4		; print announcement
;	move.w	#9,-(sp)
;	trap	#1
;	addq	#6,sp		; clean up stack
;
;	movea.l	4(sp),a0	; a0 -> basepage
;	move.l	$c(a0),d0	; d0 = size of text
;	add.l	$14(a0),d0	; d0 = size of (text + data)
;	add.l	$1c(a0),d0	; d0 = size of (text + data + bss)
;	add.l	#$0100,d0	; d0 = size of (text + data + bss + basepage)
;	move.l	d0,-(sp)	; new size
;	move.l	a0,-(sp)	; -> basepage
;	clr.w	-(sp)		; WORD 0
;	move.w	#$4a,-(sp)	; Mshrink()
;	trap	#1
;	adda	#12,sp
;	
;	move.l	#$444d4172,d3	; d3 = "DMAr"
;	moveq	#0,d5		; no user-preference
;	jsr	(a1)		; continue boot process
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
buf:	ds.b	512
buf2:	ds.b	512
tbkeep: