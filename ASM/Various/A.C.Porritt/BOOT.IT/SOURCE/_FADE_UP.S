;  This boot sector is property of Dattrax Software.  Whilst you may
; use it on any of your own disks for personal use, you may NOT use
; it on any commercial disks - A.C.Porritt.

	opt	o+,w-,s-,x-
	bra.s	boot_prog
	ds.l	14
boot_prog
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
	sub.w	#$110,$ffff8242.w
	bsr	wait_vbl
	move.w	(sp)+,d0
	dbra	d0,loop

; why bother with a return?
; the program will just wait vbl then
; return anyway!!!

wait_vbl
	move	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	rts
msg
	dc.b	"b!Y$,Dattrax SoftwareY%---------------"
	dc.b	"Y'/Virus FreeY+)Written By A.C.Porritt",0