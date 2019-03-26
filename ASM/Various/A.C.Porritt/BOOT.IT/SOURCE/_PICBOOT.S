; this one displays a picture then returns.  The picture can be called
; <anything>.PIC - The file should be 32000 bytes of picture in low-res
; then 32 bytes of palette.  To do this, if you have STOS (very useful
; BASIC)  type RESERVE AS SCREEN 5 : LOAD "MYPIC.NEO/PI1",5
; then BSAVE "MYPIC.PIC",START(5) TO START(5)+32032

	opt	o+,w-,s-,x-
	bra.s	Boot_prog
	ds.l	14
Boot_prog
	bsr	wait_vbl
	move.w	#7,d0
	lea	$ffff8240,a0
clpalt
	move.l	#-1,(a0)+
	dbra	d0,clpalt
	pea	msg(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	move.l	$44e,a0
	move.w	#22,d0
loopa
	move.w	#(20*4)-1,d1
loopb
	move.w	(a0),d2
	lsr.w	#1,d2
	move.w	d2,(a0)
	lea	8(a0),a0
	dbra	d1,loopb
	lea	160*4(a0),a0
	dbra	d0,loopa
	move.w	#$777,$ffff8242.w
	move.w	#6,d0
loop
	move.w	d0,-(sp)
	bsr	wait_vbl
	sub.w	#$110,$ffff8242.w	; change to 1 if
	*sub.w	#$111,$ffff8240.w	; this line is in
	bsr	wait_vbl
	move.w	(sp)+,d0
	dbra	d0,loop
	clr.w	-(sp)
	pea	fname(pc)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	move.l	$44e,a0
	lea	-32256(a0),a0
	move.w	d0,-(sp)
	move.l	a0,-(sp)
	move.l	#32032,-(sp)
	move.w	d0,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.l	#12,sp
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	move.w	#6,d0
	lea	$ffff8244,a0
fadn1
	movem.w	d0/a0,-(sp)
	bsr.s	wait_vbl
	bsr.s	wait_vbl
	add.w	#$110,$ffff8242		; change me too!
	movem.w	(sp)+,d0/a0
	clr.l	(a0)+
	dbra	d0,fadn1
	move.w	#7999,d0
	move.l	$44e,a1
	lea	-32256(a1),a0
scrcopy
	move.l	(a0)+,(a1)+
	dbra	d0,scrcopy
	move.l	a0,-(sp)
	bsr.s	wait_vbl
	move.l	(sp)+,a0
	movem.l	(a0),d0-7
	movem.l	d0-7,$ffff8240

wait_vbl
	move	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	rts
msg
	dc.b	"b!Y$,Dattrax SoftwareY%---------------"
	dc.b	"Y'/Virus FreeY+)Written By A.C.Porritt",0
fname	dc.b	"A:\*.PIC",0
