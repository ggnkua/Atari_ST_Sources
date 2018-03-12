palette		equ	$ff8240
timer		equ	$4ba

	xref	_protect

	bss

pall	ds.w	16

	data

rwabs	dc.l	0	
old14	dc.l	0
count	dc.w	0

	text

alert:
	move.w	#16-1,d0
	lea	pall,a0
	lea	palette,a1
sav:	move.w	(a1),(a0)+
	move.w	#0,(a1)+	* black!
	dbra	d0,sav

	move.w	#10,count
flash:
	lea	palette,a0
	eor.w	#$0777,(a0)
	move.l	timer,d0
	add.l	#100,d0		* one seconds
wait:	cmp.l	timer,d0
	bhi	wait
	sub.w	#1,count
	bne	flash

	move.w	#16-1,d0
	lea	pall,a1
	lea	palette,a0
sav1:	move.w	(a1)+,(a0)+
	dbra	d0,sav1

	rts

*****************************************************************************
*
* rwabs(int:rw,long:buf,int:count,int:recnum,int:dev)
*         45    6789     ab        cd           ef
*
*****************************************************************************
rwflag	equ	$4
buffer	equ	$6
count	equ	$a
record	equ	$c
device	equ	$e

diskvector:
	move.w	rwflag(sp),d0
	and.w	#1,d0
	beq	perform		* not writting
	lea	_protect,a0
	add.w	device(sp),a0
	tst.b	(a0)		* protected
	beq	perform		* nope
	bsr	alert
	moveq	#-13,d0
	rts
perform:
	move.l	rwabs,a0
	jmp	(a0)

*
*  stack frame
*   8(sp) first parm
*   6(sp) function
*   2(sp) ret adr
*    (sp) sr


* funct  L    L  dev
*  67  8901 2345  6
vector:				* trap #14
	move.l	sp,a0
	move.w	(sp),d0
	btst	#13,d0		; Super mode?
	bne	b_supr
	move.l	usp,a0		; usp
	sub.w	#6,a0
b_supr:
	cmp.w	#9,6(a0)
	beq	clip
	cmp.w	#10,6(a0)
	beq	clip
	
func:	move.l	old14,a0		; traps run in super
	jmp	(a0)			; back to future!

clip:
	move.w	16(a0),d0
	and.w	#1,d0
	lea	_protect,a0
	add.w	d0,a0
	tst.b	(a0)		* protected
	beq	func		* nope

	bsr	alert
	moveq	#-13,d0
	rte

trp14	equ	$b8

	globl	_hookup
_hookup:
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	add.w	#6,sp
	move.l	d0,-(sp)
	
	move.l	#$476,a0
	move.l	(a0),rwabs
	move.l	#diskvector,(a0)

	lea	trp14,a0
	move.l	(a0),old14
	move.l	#vector,(a0)

	move.w	#$20,-(sp)
	trap	#1
	add.w	#6,sp
	rts

