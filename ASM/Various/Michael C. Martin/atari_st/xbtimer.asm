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

	move.l	#intro,a0		; Print greeting
	bsr	outstr

lp:	move.l	#cr,a0			; Print header
	bsr	outstr
	move.l	counter,d0		; and counter value
	bsr	outhex			; (updated by timer handler)
	bra.s	lp			; looping forever

	move.l	#unreachable_msg,a0	; Can't happen!
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
	move.l	#-1,-(sp)		; Read vector
	move.w	#$102,-(sp)		; for $102 (terminate)
	move.w	#5,-(sp)		; Setexec()
	trap	#13			; BIOS call
	addq.l	#8,sp
	move.l	d0,oldterm		; Save original terminate vector
	move.l	#terminate,-(sp)	; And set the vector to our new one
	move.w	#$102,-(sp)
	move.w	#5,-(sp)
	trap	#13
	addq.l	#8,sp
	move.l	#tick,-(sp)		; Configure timer interrupt...
	move.w	#0,-(sp)		; 256 counts per call
	move.w	#7,-(sp)		; delay mode, 200 clocks per count
	move.w	#0,-(sp)		; on Timer A
	move.w	#31,-(sp)		; Xbtimer()
	trap	#14			; XBIOS
	add.l	#12,sp
	rts

;;; ----------------------------------------------------------------------
;;;   terminate: Custom terminate handler. Fix vectors, turn off timer,
;;;              and proceed with exit.
;;; ----------------------------------------------------------------------
terminate:
	move.l	#tick,-(sp)		; Configure timer interrupt...
	move.w	#0,-(sp)
	move.w	#0,-(sp)		; Disable timer
	move.w	#0,-(sp)		; on Timer A
	move.w	#31,-(sp)		; Xbtimer()
	trap	#14			; XBIOS
	add.l	#12,sp
	bclr.b	#5,$fffa0f		; Ack maybe-pending IRQ
	move.l	oldterm,-(sp)		; Restore original terminate vector
	move.w	#$102,-(sp)
	move.w	#5,-(sp)
	trap	#13
	addq.l	#8,sp
	;; We could return to the original dispatcher here, but let's
	;; print a nice message and quit cleanly so we don't give an
	;; error message.
	;; We can't use GEMDOS (and thus Cconws()) inside the handler, so we
	;; loop with Bconout() instead
	move.l	#goodbye,a3
	subq.l	#6,sp
.bye:	clr.w	4(sp)
	move.b	(a3)+,5(sp)
	beq.s	.done
	move.w	#2,2(sp)
	move.w	#3,(sp)
	trap	#13
	bra.s	.bye
.done:	addq.l	#4,sp
	clr.w	(sp)
	trap	#1

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
	trap	#1			; Cconout (GEMDOS)
	addq.l	#4,sp
	bra.s	.out
.done:	addq.l	#2,sp			; Pop the 0 terminator
	rts				; and return

;;; ----------------------------------------------------------------------
;;;   outstr: Print the null-terminated string in a0 to console.
;;;           Trashes a0-a2/d0-d2.
;;; ----------------------------------------------------------------------
outstr:	move.l	a0,-(sp)		; Address of string
	move.w	#9,-(sp)		; Cconws()
	trap	#1			; GEMDOS
	addq.l	#6,sp
	rts

	data
counter:
	dc.l	0

intro:	dc.b	"MFP Timer Demonstration",13,10,"Press Ctrl-C to exit",13,10,0
cr:	dc.b	13,"Timer: ",0
unreachable_msg:
	dc.b	13,10,"Big yikes!",13,10
	dc.b	"Somehow reached unreachable code!",13,10,0
goodbye:
	dc.b	13,10,"Timer interrupted. Shutting down.",13,10,0
	bss
oldterm:
	ds.l	1
