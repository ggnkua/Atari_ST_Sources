hour	equ	16
minute	equ	21
second	equ	45
year	equ	91
month	equ	10
day	equ	12

;TEST	equ 	1


* --------------------------------------------------
* cart_mpb.s install 'MPB*' cookie type #1 cartridge
* --------------------------------------------------
p_cookie = $5a0
longfram = $59e
resvalid = $426
resvecto = $42a
resmagic = $31415926
membot   = $432
trap13   = $b4
_hz_200	= $4ba
cookie   = 'MPB*'
	IFD	TEST
	jmp	start(pc)
	ELSEIF
	org	$fa0000
	ENDC
* -------------------------------------------------
ca_magic	dc.l	$abcdef42
ca_next	dc.l	0
ca_init	dc.l	$00000000
ca_run	dc.l	start
ca_time	dc.w	2048*hour+32*minute+second
ca_date	dc.w	512*(year-80)+32*month+day
ca_size	dc.l	ende-start
ca_name	dc.b	"TESTFILE.PRG",0
	even
* -------------------------------------------------
start	
	pea	flimmer(pc)
	move	#$26,-(sp)
	trap	#14
	addq	#6,sp
	pea	text(pc)
	move	#9,-(sp)
	trap	#1
	addq	#6,sp
	move	#1,-(sp)
	trap	#1
	addq	#2,sp
exit	clr	-(sp)
	trap	#1
flimmer
	moveq	#0,d6
	move.b	$fb0001,d6
	and.b	#$0f,d6
	mulu	#200,d6
	move.l	_hz_200.w,d7
	lea	$ffff8240.w,a0
.flimramer	
	addq	#1,(a0)
	move.l	_hz_200.w,d0
	sub.l	d7,d0
	cmp.l	d6,d0
	blt.s	.flimramer
	rts
text	dc.b	"Boot-flimmer in cartridge by Unit Seventeen",13,10
	dc.b	"Press any key to continue...",0
ende:
