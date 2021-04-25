;##############################################################################
;
; Accesory startup for use with sozobon C. Will allow use of much of dlibs
;  but not file output (needs a look into what happens in dstart. But this
;  will do and anyone keen can use the appropriate traps.
;
;	Author David Woakes, 8 Maxwell St, Edinburgh, EH10 5HU.
;
;##############################################################################
	.text
	.globl	_start
_start:	move.l	#stack,sp
	adda.l	stksiz,sp
	jsr	_main
	move.w	#0,-(sp)
	move.w	#$4c,-(sp)
	trap	#1

	.globl	_gemdos
_gemdos:
	move.l	(a7)+,L3
	trap	#1
	bra	L1

	.globl	_bios
_bios:
	move.l	(a7)+,L3
	trap	#13
	bra	L1

	.globl	_xbios
_xbios:
	move.l	(a7)+,L3
	trap	#14
	bra	L1

	.globl	_bdos
_bdos:
	move.l	(a7),L3
	move.l	a6,(a7)
	movea.l	a7,a6
	tst.l	-(a6)
	move.w	8(a6),d0
	move.l	10(a6),d1
	trap	#2
	movea.l	(a7)+,a6
L1:
	cmpa.l	$000016a8,a7
	bgt	L2
	move.l	#$0000149c,-(a7)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	move.w	#65535,-(a7)
	move.w	#76,-(a7)
	trap#1
L2:
	move.l	L3,-(a7)
	rts

	.data
stksiz:	dc.l	4096	
	.bss
L3:
	.ds.w	2
stack:	.ds.l	1024
	.end
