	.title	'Install MADMAC From AUTO Folder'

;----------------
;
;  2-Nov-1986 lmd	Hacked it up (we need example programs, right?)
;


;----------------
;
;    Shrink as small as possible (by relocating to the commandline
;    part of the basepage) and exec MAC.PRG from the root of the
;    boot disk.This example program is for floppy disk users who
;    don't like installing MADMAC manually every time they boot.
;
;    This leaves a *small* memory fragment, less than $100 bytes.
;
;    The coding style here is, er . . . bizarre.  I suggest the reader
;    treat it as an excercise in paranoia, and not as an example
;    of good coding practice.  As jwt sez, "this should only be
;    attempted by experienced software engineers."  Or madpersons.
;
;
	bra.w	movedown		; branch to shrinker
BEGIN:	lea	END(pc),sp		; then come back here and init stack
	move.l	d0,-(sp)		; = amount to keep
	move.l	a1,-(sp)		; -> basepage
	move.l	d1,-(sp)		; push WORD 0x0000 and function number
	trap	#1			; do Mshrink()
	add.w	#12,sp			; (cleanup)

	clr.l	-(sp)			; null enviroment string
	pea	progtail(pc)		; -Q switch
	pea	progpath(pc)		; -> program to exec
	move.l	d7,-(sp)		; subfunc=0, function=Pexec()
	trap	#1

	clr.w	-(sp)			; terminate, return code = OK
	trap	#1
	illegal				; "cannot happen"
	

progpath:	dc.b	'\\MAC.PRG',0	; program to exec, in the root dir
progtail:	dc.b	'*-q',0		; command tail (the '*' gets clobbered)

		dcb.b	64,0		; 64 bytes of user stack
END:					; end of kept part


;----------------
;
;    Copy code from BEGIN to END into commandline area of basepage;
;    this code (and everything beyond it) is thrown away by an
;    Mshrink() in the kept portion.
;
;    Returns:	d0 = amount of memory to keep;
;		d1 = Mshrink code + word of zero
;		d7 = Pexec code + subfunction zero
;		a1 -> process's basepage
;
;
movedown:
	move.l	4(sp),a1		; a1 -> basepage
	lea	$80(a1),a2		; a2 -> basepage's command tail area
	lea	BEGIN(pc),a0		; a0 -> start kept portion (right now)
	move.w	#END-BEGIN+1,d0		; d0 = size (bytes-1) of kept portion
.1:	move.b	(a0)+,(a2)+		; copy a byte
	dbra	d0,.1			;	until we're done
	move.l	#$80+END-BEGIN,d0	; d0 = amount to keep on Mshrink
	move.l	#$004a0000,d1		; d1 = Mshrink + word of zero
	move.l	#$004b0000,d7		; d7 = Pexec + subfunction zero
	jmp	$80(a1)			; jump back to kept portion
