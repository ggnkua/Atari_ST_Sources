* see line 62!
* oh, and read 'read_me.gor' first!

*** ROB NORTHEN EXTERNAL PROTECTION CRACKER ***
* For the new version as used in Castle Master
* This is not perfect... it will run the program and save the decrypted
* PRG onto drive B. Sometimes...
* (And as soon as he updates his protection, this is useless!)

start	pea	(end-start)+256.w
	pea	start-256(pc)
	pea	$4a0000		reserve memory
	trap	#1
	lea	12(sp),sp

	lea	stack(pc),sp

	clr.l	-(sp)
	move.w	#$20,-(sp)		supervisor
	trap	#1

	pea	input(pc)
	move.w	#9,-(sp)		input prompt
	trap	#1
	pea	filename(pc)
	move.w	#9,-(sp)
	trap	#1
	pea	cursor(pc)
	move.w	#9,-(sp)
	trap	#1
	lea	18(sp),sp

	pea	inputline(pc)
	move.w	#$a,-(sp)		input filename
	trap	#1
	addq.l	#6,sp

	pea	envcom(pc)
	move.l	(sp),-(sp)
	pea	filename(pc)
	pea	$4b0003		load and set up
	trap	#1
	lea	16(sp),sp
	tst.l	d0
	bmi.s	error

	move.l	d0,a0		basepage addr

	lea	12(a0),a0		to text len pointer
	move.l	a0,compare+6		write addr of that
	move.l	(a0),compare+2	write byte there

	lea	$8.w,a0		save all exception
	lea	tex(pc),a1		vectors, interrupts,
	move.w	#($200-$8)/2-1,d1	etc. etc.
save	move.w	(a0)+,(a1)+
	dbf	d1,save

	move.l	$114.w,oldtimerC+2	save old timer C
	move.l	#mytimerC,$114.w	patch my timer C
	
	move.b	#2,$fffffa23.w		faster you nazi swine (!)
	move.b	#%01110000,$fffffa1d.w

	clr.l	-(sp)
	move.l	d0,-(sp)
	clr.l	-(sp)
	pea	$4b0004		run rob's shit...
	trap	#1
** never gets to here **

error	pea	text(pc)
	move.w	#9,-(sp)		error message
	trap	#1
	move.w	#8,-(sp)		wait for key
	trap	#1
	addq.l	#8,sp
	clr.w	-(sp)		bye!
	trap	#1



mytimerC	eor.w	#$77,$ffff8240	muck up colors

* these 00000000s are overwritten -- see above

compare	cmp.l	#$00000000,$00000000	decrypted yet?
	beq	notyet		no

	movem.l	d0-d7/a0-a6,-(sp)
	
	move.w	#$2700,sr		yes! kill interrupts
	move.w	#$70,$ffff8240.w	green screen
	lea	tex(pc),a0		restore exceptions etc.
	lea	$8.w,a1
	move.w	#($200-$8)/4-1,d0
copy	move.l	(a0)+,(a1)+
	dbf	d0,copy

	move.b	#7,$484.w		keyclick on (ok, maybe)

	clr.l	$426.w		kill rob's anti-reset
	clr.l	$42a.w

	movem.l	(sp)+,d0-d7/a0-a6

	move.l	2(sp),a6		a6=text
	lea	-256(a6),a6		a6=basepage
* create an exec header
	move.w	#$601a,228(a6)	exec header
	move.l	12(a6),230(a6)	write text len
	move.l	20(a6),234(a6)	write data len
	move.l	28(a6),238(a6)	write bss len
	lea	228(a6),a5
	move.l	2(a5),d0
	add.l	6(a5),d0
	add.l	#32,d0
	move.l	d0,len+2
	clr.w	-(sp)
* save using same filename to drive B
	move.b	#'B',filename
	pea	filename(pc)
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	pea	(a5)
len	pea	0
	move.w	d0,-(sP)
	move.w	d0,d7
	move.w	#$40,-(sp)
	trap	#1
	lea	12(sp),sp
	move.w	d7,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
* die now, because the system is probably shot to hell anyway
	jmp	$fc0000
notyet	
oldtimerC	jmp	0		do old timer C


	data
	ds.l	400
stack	ds.l	1
envcom	dc.w	0		null environment/command

text	dc.b	27,"E",7,"File not found. Hit it...",0

input	dc.b	27,"E",27,"e","CrakRob by The Alien.",13,10,10
	dc.b	"Cracks Rob Northen's latest",13,10
	dc.b	"external protection...",13,10,10
	dc.b	"Program to crack? >",0
cursor	dc.b	27,"e",27,"Y",37,51,0

inputline	dc.b	128		max 128 chars
	dc.b	13		8 given chars
filename	dc.b	"A:\HACK_V2.PRG"		default filename
	bss
	ds.b	120		128 chars buffer

tex	ds.l	$200-$8/4		space to save exceptions
end