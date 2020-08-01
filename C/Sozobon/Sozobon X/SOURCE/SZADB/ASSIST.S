	.text
	.globl	_trap2
	.globl	_trap3
	.globl	_trap4
	.globl	_trap5
	.globl	_trap6
	.globl	_trap7
	.globl	_trap8
	.globl	_trap9
	.globl	_trapx

	.data
trapno:	.ds.w	1
svmysp:	.ds.l	1

	.text

A7	equ	15*4
PC	equ	A7+4
SR	equ	PC+4
XP	equ	SR+4
SUPV	equ	$2000

_trap2:
	move.w	#2,trapno

btrap:
	move.w	(sp)+,_detail
	move.l	(sp)+,_be_addr
	move.w	(sp)+,_be_instr
	bra	rtrap

_trap3:
	move.w	#3,trapno
	bra	btrap

_trap4:
	move.w	#4,trapno

rtrap:
	movem.l	d0-d7/a0-a6,_regbuf
	move.w	(sp)+,d0	* SR
	move.l	(sp)+,d1	* PC
	tst.w	_running
	beq	myerror

	move.w	d0,d2
	and.w	#SUPV,d2
	bne	frsupv
*trap from user mode
	move.l	a7,_regbuf+XP
	move	usp,a0
	move.l	a0,_regbuf+A7
	bra	frproc
*trap from supv mode
frsupv:
	move.l	a7,_regbuf+A7
	move	usp,a0
	move.l	a0,_regbuf+XP
	
frproc:
	move.l	svmysp,sp
	move.l	d1,-(sp)	* push PC
	move.w	d0,-(sp)	* push SP
	move.w	trapno,-(sp)	* push trapno
	jsr	_trap
myerror:
	* stay with this stack
	jsr	_trap

_trap5:
	move.w	#5,trapno
	bra	rtrap

_trap6:
	move.w	#6,trapno
	bra	rtrap

_trap7:
	move.w	#7,trapno
	bra	rtrap

_trap8:
	move.w	#8,trapno
	bra	rtrap

_trap9:
	move.w	#9,trapno
	bra	rtrap

_trapx:
	move.w	#10,trapno
	bra	rtrap

	.globl	_go
_go:
	move.l	sp,svmysp
	move.w	_regbuf+SR+2,d0
	move.w	d0,d2
	and.w	#SUPV,d2
	bne	gosupv
* going to user mode - user's SSP in XP, user's USP in A7
	move.l	_regbuf+A7,a0		*restore usp
	move	a0,usp
	move.l	_regbuf+XP,a7		*restore ssp
	bra	gocom
* going to system mode - user's SSP in A7, user's USP in XP
gosupv:
	move.l	_regbuf+XP,a0
	move	a0,usp			*restore usp
	move.l	_regbuf+A7,a7		*restore ssp
gocom:
	move.l	_regbuf+PC,-(sp)	*push user's PC
	move.w	d0,-(sp)		*push user's SR
	movem.l	_regbuf,d0-d7/a0-a6	*restore other regs
	rte

	.globl	_bcopy
_bcopy:
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.w	12(sp),d0
	bra	bcd
bclp:
	move.b	(a1)+,(a0)+
bcd:
	dbra	d0,bclp
	rts

	.globl	_wcopy
_wcopy:
	move.l	4(sp),a1
	move.l	8(sp),a0
	move.w	12(sp),d0
	bra	wcd
wclp:
	move.w	(a1)+,(a0)+
wcd:
	dbra	d0,wclp
	rts

	.globl	_getfonts
_getfonts:
	.dc.w	$0a000
	move.l	a1,d0
	rts
