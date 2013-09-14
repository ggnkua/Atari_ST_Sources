.include "atari.s"

;+
; To test dmarw()
;-

.globl	_dmarw

MAXSCSI	equ	15
;+
; For debugging purposes
; try reading root sector of all available ACSI and SCSI devices.
;-
main:	Bconout	#2,#'*'		; show that we're starting
	Bconout	#2,#27
	Bconout	#2,#'v'
	_Super

	moveq	#MAXSCSI,d0	; d0 = dev #
next0:	move.w	d0,-(sp)
	move.w	d0,-(sp)	; dev #
	move.l	#buf,-(sp)	; buffer address
	move.w	#1,-(sp)	; count
	move.l	#0,-(sp)	; sector
	move.w	#0,-(sp)	; it's a read
	bsr	_dmarw
	tst.w	d0		; successful
	bne	fail0
	Bconout	#2,#'S'		; success!
	bra	write0
fail0:	Bconout	#2,#'F'		; failure

write0:	move.w	#1,(sp)		; it's a write
	bsr	_dmarw
	add.w	#14,sp		; clean up stack
	tst.w	d0		; successful
	bne	fail1
	Bconout	#2,#'S'		; success!
	bra	next1
fail1:	Bconout	#2,#'F'		; failure

next1:	Bconout	#2,#' '		; success!
	move.w	(sp)+,d0
	dbra	d0,next0

	Bconin	#2,#' '
	Pterm0

.bss
buf:	ds.b	512		; buffer
