;;; Hello world for the Atari ST (non-GEM)
;;; This uses BIOS and GEMDOS calls to output a string to the TOS
;;; console, then read a key from it to give the string a chance to
;;; be read before returning control to GEM.

	move.l	#msg,a3
lp:	clr.w	d0
	move.b	(a3)+,d0
	beq.s	done
	move.w	d0,-(a7)		; Character to print
	move.w	#2,-(a7)		; Print to console
	move	#3,-(a7)		; Bconout function
	trap	#13			; BIOS call
	addq.l	#6,a7
	bra.s	lp
done:	move.w	#2,-(a7)		; Read from console
	move.w	#2,-(a7)		; Bconin function
	trap	#13			; BIOS call
	addq.l	#4,a7
	clr.w	-(a7)			; Pterm0 function
	trap	#1			; GEMDOS call

msg:	dc.b	"Hello, world!",13,10,13,10
	dc.b	"Now waiting for the world",13,10
	dc.b	"to press a key...",0
