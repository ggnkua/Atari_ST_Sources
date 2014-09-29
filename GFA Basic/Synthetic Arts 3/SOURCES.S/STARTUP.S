InitProgram	move.l	a7,a5
	move.l	4(a5),a5	* BasePage
	moveq	#2,d0
	add.l	$c(a5),d0	* TEXT LEN
	add.l	$14(a5),d0	* DATA LEN
	add.l	$1c(a5),d0	* BSS LEN
	and.w	#-2,d0
	move.l	d0,a0
	IFD	StackSize
	add.l	#256+($7ffffffe&StackSize),a0
	ELSE
	lea	1024(a0),a0
	ENDC
	lea	0(a0,a5.l),sp
	
	pea	(a0)
	pea	(a5)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bne.s	.InitError
	bsr.s	main
	clr.w	-(sp)
	bra.s	.ZeEnd
.InitError	move.w	#-39,-(sp)
.ZeEnd	move.w	#$4c,-(sp)
	trap	#1
	dc.b	"Nucleus!"
main
