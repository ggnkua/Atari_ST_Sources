	pea	0
	move	#$20,-(sp)
	trap	#1
	move.l	d0,sp

	bsr	tstprint
	tst	d0
	beq	busy

	move	#'B',d0
	bsr	writebyte2printer

exit	clr.w	-(sp)
	trap	#1

busy	pea	printerbusy
	move	#9,-(sp)
	trap	#1
	addq	#6,sp

	move	#7,-(sp)
	trap	#1
	addq	#2,sp

	bra	exit
printerbusy
	dc.b	'Printer Is Not Responding',0
	even

**  test print status 0=busy -1=ready for data
tstprint	moveq	#-1,d0
	btst	#0,$FFFFFA01.w
	beq.s	.printready
	moveq	#0,d0
.printready
	rts

**  d0 = character
writebyte2printer
	move	d0,-(sp)
	move.b	#7,$FFFF8800.w		set port b as output
	or.b	#$80,$FFFF8802.w

	move.b	#15,$FFFF8800.w		write character 2 port b
	move.b	d0,$FFFF8802.w

	move.b	#14,$FFFF8800.w		get port a bits
	move.b	$FFFF8800.w,d0
	and	#$de,d0			turn off bit 5
	move.b	#14,$FFFF8800.w		write to port a
	move.b	d0,$FFFF8802.w

	move.b	#14,$FFFF8800.w		get port a bits
	move.b	$FFFF8800.w,d0
	or	#$20,d0			turn on port a bit 5
	move.b	#14,$FFFF8800.w		right changes
	move.b	d0,$FFFF8802.w
	move	(sp)+,d0
	rts

