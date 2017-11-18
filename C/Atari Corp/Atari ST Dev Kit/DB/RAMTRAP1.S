* program to install a helper for debugging:
* simply provide a ram "hook" on trap 1.
*
* You can't provide the hook on the EXIT side of
* Pexec; it is allowed to fall through without
* the linking trick.
*

.include atari

	Super
	move.l	$84,otrap1
	move.l	#ntrap1,$84
	User
	Ptermres #$180,#0

	dc.l	"RMT1"
	dc.l	go2old
	dc.l	newret

ntrap1:
	move.l	usp,a0
	btst.b	#5,(sp)
	beq.s	.user
	lea.l	6(sp),a0
	tst.w	_longframe
	beq.s	.user
	addq.l	#2,a0
.user:	cmp.w	#$4b,(a0)
	beq.s	go2old
	move.l	2(sp),retsav
	move.l	#newret,2(sp)
go2old:
	move.l	otrap1(PC),a0
	jmp	(a0)

newret:
	move.l	retsav(PC),a0
	jmp	(a0)

otrap1:	dc.l	0
retsav:	dc.l	0
