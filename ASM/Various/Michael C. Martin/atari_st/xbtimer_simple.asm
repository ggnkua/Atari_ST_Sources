;;; ----------------------------------------------------------------------
;;;  Programmable timer sample program for the Atari ST
;;;    Written by Michael Martin, 2021
;;;    Based on C sample code by Jwahar R. Bammi, 1986
;;; ----------------------------------------------------------------------
	text

	move.l	#config_tick,-(sp)	; Config timer and ^C handler
	move.w	#38,-(sp)		; with SupExec()
	trap	#14			; in XBIOS
	addq.l	#6,sp

	move.l	#intro,a0
	bsr	outstr

lp:	move.l	#cr,a0			; Print header
	bsr	outstr
	move.l	counter,d0		; and counter value
	bsr	outhex			; (updated by timer handler)
	move.w	#2,-(sp)		; Check keyboard
	move.w	#1,-(sp)		; Bconstat()
	trap	#13			; BIOS
	addq.l	#4,sp
	tst.w	d0
	beq.s	lp			; looping while no keys ready

	move.l	#unconfig_tick,-(sp)
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp

	move.w	#2,-(sp)		; From keyboard
	move.w	#2,-(sp)		; Bconin()
	trap	#13			; BIOS
	addq.l	#4,sp

	move.l	#goodbye,a0
	bsr	outstr
	clr.w	-(sp)
	trap	#1

;;; ----------------------------------------------------------------------
;;;   tick: Called by the timer A interrupt handler
;;; ----------------------------------------------------------------------
tick:	addq.l	#1,counter		; Bump counter
	bclr.b	#5,$fffa0f		; Acknowledge interrupt
	rte

;;; ----------------------------------------------------------------------
;;;   config_tick: Sets up the terminate and timer handlers. Must be
;;;                called in Supervisor mode.
;;;                Trashes a0-a2/d0-d2.
;;; ----------------------------------------------------------------------
config_tick:
	move.l	#tick,-(sp)		; Configure timer interrupt...
	move.w	#0,-(sp)		; 256 counts per call
	move.w	#7,-(sp)		; delay mode, 200 clocks per count
	move.w	#0,-(sp)		; on Timer A
	move.w	#31,-(sp)		; Xbtimer()
	trap	#14			; XBIOS
	add.l	#12,sp
	rts

;;; ----------------------------------------------------------------------
;;;   unconfig_tick: Fix vectors, acknowledge any possibly-pending IRQ.
;;; ----------------------------------------------------------------------
unconfig_tick:
	move.l	#tick,-(sp)		; Configure timer interrupt...
	move.w	#0,-(sp)
	move.w	#0,-(sp)		; Disable timer
	move.w	#0,-(sp)		; on Timer A
	move.w	#31,-(sp)		; Xbtimer()
	trap	#14			; XBIOS
	add.l	#12,sp
	bclr.b	#5,$fffa0f		; Ack maybe-pending IRQ
	rts

;;; ----------------------------------------------------------------------
;;;   outhex: Print the 32-bit number in d0 to console.
;;;           Trashes a0-a2/d0-d2.
;;; ----------------------------------------------------------------------
outhex:	move.w	#0,-(sp)		; Push 0 terminator on stack
	moveq	#7,d2			; Then push 7 hex digits in order
.calc:	move.w	d0,d1
	and.w	#15,d1			; Isolate lowest hex digit
	cmp.w	#9,d1			; 0-9?
	ble.s	.dec
	addq.w	#7,d1			; if not, correct for A-F
.dec:	add.w	#48,d1			; Then convert to ASCII
	move.w	d1,-(sp)		; and push it on the stack
	lsr.l	#4,d0			; Next hex digit
	dbra	d2,.calc		; Next iteration
.out:	tst.w	(sp)			; Loop until we hit the 0 terminator
	beq.s	.done
	move.w	#2,-(sp)		; And print the characters with
	move.w	#3,-(sp)		; Bconout()
	trap	#13			; BIOS
	addq.l	#6,sp
	bra.s	.out
.done:	addq.l	#2,sp			; Pop the 0 terminator
	rts				; and return

;;; ----------------------------------------------------------------------
;;;   outstr: Print the null-terminated string in a0 to console.
;;;           Trashes a0-a2/d0-d2.
;;; ----------------------------------------------------------------------
outstr:	move.l	a3,-(sp)
	move.l	a0,a3
	subq.l	#6,sp
.lp:	clr.w	4(sp)
	move.b	(a3)+,5(sp)
	beq.s	.done
	move.w	#2,2(sp)
	move.w	#3,(sp)
	trap	#13
	bra.s	.lp
.done:	addq.l	#6,sp
	move.l	(sp)+,a3
	rts

	data
counter:
	dc.l	0

intro:	dc.b	"MFP Timer Demonstration",13,10
	dc.b	"Press any key to exit",13,10,0
cr:	dc.b	13,"Timer: ",0
goodbye:
	dc.b	13,10,"Timer interrupted. Shutting down.",13,10,0
