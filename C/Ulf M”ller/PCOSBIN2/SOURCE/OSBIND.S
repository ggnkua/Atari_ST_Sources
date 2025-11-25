; Lovingly swiped from Eric Smith's mntlib.
; Pure C version 13-6-92 um

	.globl	gemdos
	.globl	xbios
	.globl	bios

	.text
	.even

gemdos:
	lea	20(sp),a0		; 4 bytes for ret addr + 16 for parameters
	movem.l	a2,-(sp)	; save reggie that TOS clobbers but that
						; PureC thinks functions should preserve
	move.l	-(a0),-(sp)	; max. of 16 bytes parameters to trap #1
	move.l	-(a0),-(sp)
	move.l	-(a0),-(sp)
	move.l	-(a0),-(sp)
	move.w d0, -(sp)	; function number passed in d0
	trap	#1			; go do the trap
	lea	16+2(sp),sp		; pop parameters
	movem.l	(sp)+,a2	; restore reggie
	rts					; return

bios:
	lea	24(sp),a0
	movem.l	a2,-(sp)
	move.l	-(a0),-(sp)
	move.l	-(a0),-(sp)
	move.l	-(a0),-(sp)
	move.l	-(a0),-(sp)
	move.l	-(a0),-(sp)
	move.w d0, -(sp)
	trap	#13
	lea	20+2(sp),sp
	movem.l	(sp)+,a2
	rts

xbios:
	lea	32(sp),a0
	movem.l	a2,-(sp)
	move.l	-(a0),-(sp)
	move.l	-(a0),-(sp)
	move.l	-(a0),-(sp)
	move.l	-(a0),-(sp)
	move.l	-(a0),-(sp)
	move.l	-(a0),-(sp)
	move.l	-(a0),-(sp)
	move.w d0, -(sp)
	trap	#14
	lea	28+2(sp),sp
	movem.l	(sp)+,a2
	rts

.end