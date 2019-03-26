; this does some wierd stripes on the ST.  Faster processors (Falcon/TT)
; may produce wierder stripes...

	opt	o+,x-,s-,w-
	bra.s	proggy
	ds.l	14
proggy
	pea	msg(pc)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.w	sr,-(sp)
	move.w	#$2700,sr	; unemploy interrupts (well, there is a recession on...)
	move.w	#400,d1
loop2
	move.w	#2520,d0	; wait!  (bigger=more wait)
loop
	subq.w	#1,$ffff8240.l
	dbf	d0,loop
	rept	14
	nop
	endr
	move.w	#$fff,$ffff8240.w
	dbf	d1,loop2
	move.w	(sp)+,sr	; employ interrupts (recession over...we can just see the leafy green shoots of... )
	rts
msg	dc.b	$1b,"E"
	dc.b	"Remember: Seeing stripes is better than",10,13
	dc.b	"     seeing spots!!! - A.C.Porritt",10,13,10,13
	dc.b	"      *** Virus Free Software ***",0