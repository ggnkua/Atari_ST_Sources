*	coma.s
*
* GEMDOS command interpreter assembly language interface
*
* Originally written by JSL.
*
* MODIFICATION HISTORY
*
*	11 Mar 85	JSL	Changed critical error handler vector number.
*	11 Mar 85	SCC	Changed get sup mode to use new TRAP #1 function.
*	12 Mar 85	SCC	Added get sup mode stack clean up.
*	13 Mar 85	SCC	Changed get sup mode stuff to new format.
*	20 Mar 85	JSL	Added super() & user()
*	22 Mar 85	SCC	Added devector() to restore old extended vectors.
*	27 Mar 85	SCC	Modified mycrit's abort handling to return error #.
*	28 Mar 85	SCC	Installed JSL's changes of 20 Mar 85.
*	11 Apr 85	SCC	Modified myterm() to do a f_reset before longjmp()ing
*				back into the CLI.
*	14 Apr 85	SCC	Backed out modification myterm().  There is no more
*				freset() function.  It was not the right fix to the
*				problem it tried to solve.
*       10 May 85       SCC     CLI's stack increased to 200 longs
*	20 May 85	LTG	Created in_term and rm_term functions
*	06 Aug 85	LTG	Added _cli as an alternate entry point.
* NAMES
*
*	JSL	Jason S. Loveman
*	SCC	Steven C. Cavender


	.text
	.globl	_in_term
	.globl	_rm_term
	.globl	_xbrkpt
	.globl	_cpmopen
	.globl	_cpmcreate
	.globl	_cpmclose
	.globl	_cpmread
	.globl	_cpmwrite
	.globl	_cmain
	.globl	_div10
	.globl	_mod10
	.globl	_xoscall
	.globl	_bios
	.globl	_xsetjmp
	.globl	_xlongjmp
	.globl	_exeflg
	.globl	_jb
	.globl	_devector					* SCC  22 Mar 85
	.globl	_super						* JSL  20 Mar 85
	.globl	_user						* JSL  20 Mar 85
	.globl	_cli
_cli:
_main:	move.l	#mystak,a5
	move.l	4(sp),-(a5)
	clr.l	-(a5)		* bogus return address
	move.l	a5,sp
	move.l	4(sp),a5
	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	#0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp

	clr.l	-(sp)		* toggle into sup mode		* SCC  13 Mar 85
	move.w	#$20,-(sp)	* to do BIOS calls		* SCC  13 Mar 85
	trap	#1						* SCC  13 Mar 85
	move.l	d0,2(sp)	* save SSP back in stack	* SCC  13 Mar 85
*
	move.l	#mycrit,-(sp)
	move	#$101,-(sp)					* JSL  11 Mar 85
	move	#5,-(sp)
	trap	#13		* set/get critical error
	add.l	#8,sp
	move.l	d0,ocrit
	jsr	_in_term					* LTG  20 May 85
*
	move.w	#$20,(sp)	* toggle back out to user mode	* SCC  13 Mar 85
	trap	#1						* SCC  13 Mar 85
	addq.l	#6,sp						* SCC  13 Mar 85
	jmp	_cmain	* leave basepage on stack
*
_devector:							* SCC  22 Mar 85
	clr.l	-(sp)		* toggle into sup mode		* SCC  22 Mar 85
	move.w	#$20,-(sp)	* to do BIOS calls		* SCC  22 Mar 85
	trap	#1						* SCC  22 Mar 85
	move.l	d0,2(sp)	* save SSP back in stack	* SCC  22 Mar 85

	move.l	ocrit,-(sp)	* restore crit err vector	* SCC  22 Mar 85
	move.w	#$101,-(sp)					* SCC  22 Mar 85
	move.w	#5,-(sp)					* SCC  22 Mar 85
	trap	#13						* SCC  22 Mar 85
	add.l	#8,sp						* SCC  22 Mar 85
*
	jsr	_rm_term					* LTG  20 May 85
	move.w	#$20,(sp)	* toggle back out to user mode	* SCC  22 Mar 85
	trap	#1						* SCC  22 Mar 85
	addq.l	#6,sp						* SCC  22 Mar 85
	rts							* SCC  22 Mar 85
*
_in_term:							* LTG  20 May 85
	move.l	#myterm,-(sp)					* LTG  20 May 85
	move	#$102,-(sp)					* LTG  20 May 85
	move	#5,-(sp)					* LTG  20 May 85
	trap	#13		* set/get terminate vector	* LTG  20 May 85
	add.l	#8,sp						* LTG  20 May 85
	move.l	d0,oterm					* LTG  20 May 85
	rts							* LTG  20 May 85
*
_rm_term:							* LTG  20 May 85
	move.l	oterm,-(sp)	* restore terminate vector	* SCC  22 Mar 85
	move.w	#$102,-(sp)					* SCC  22 Mar 85
	move.w	#5,-(sp)					* SCC  22 Mar 85
	trap	#13						* SCC  22 Mar 85
	add.l	#8,sp						* SCC  22 Mar 85
	rts

*
_super:	clr.l	-(sp)						* JSL  20 Mar 85
	move	#$20,-(sp)					* JSL  20 Mar 85
	trap	#1						* JSL  20 Mar 85
	addq.l	#6,sp						* JSL  20 Mar 85
	move.l	d0,savess					* JSL  20 Mar 85
	rts							* JSL  20 Mar 85
*								* JSL  20 Mar 85
_user:	move.l	savess,-(sp)					* JSL  20 Mar 85
	move	#$20,-(sp)					* JSL  20 Mar 85
	trap	#1						* JSL  20 Mar 85
	addq.l	#6,sp						* JSL  20 Mar 85
	rts							* JSL  20 Mar 85

myterm:	cmp	#0,_exeflg	* is this my child's term
	beq	itsme

	rts

* I never terminate (need to distinguish 2nd level command.com (ie. batch)

itsme:
	andi.w	#$5fff,sr	* return to user mode

	move	#1,-(sp)
	move.l	#_jb,-(sp)
	jsr	_xlongjmp
*
mycrit:	move.l	#aris,a0
	jsr	bprt
	move	#2,-(sp)
	move	#2,-(sp)	* conin
	trap	#13
	addq.l	#4,sp
	and	#$5f,d0		* upcase
	cmp.b	#'A',d0
	beq	acrit

	cmp.b	#'R',d0
	beq	rcrit

	cmp.b	#'I',d0
	bne	mycrit

* ignore the failure, continue processing
icrit:	clr.l	d0
	rts

* abort the offending process
acrit:	move.w	4(sp),d0
	ext.l	d0
	rts

* retry the operation
rcrit:	move	#1,d0
	swap	d0
	rts
*
bprt:	clr.l	d0
	move.b	(a0)+,d0
	cmp.b	#0,d0
	beq	nomoch
	move.l	a0,-(sp)
	move	d0,-(sp)
	move	#2,-(sp)	* device handle
	move	#3,-(sp)	* conout function
	trap	#13
	addq.l	#6,sp
	move.l	(sp)+,a0
	jmp	bprt
nomoch:	rts
*
_xbrkpt:	illegal
	rts
*
_xsetjmp: link	a6,#0
	move.l	8(a6),a0
	move.l	0(a6),(a0)+
	lea	8(a6),a1
	move.l	a1,(a0)+
	move.l	4(a6),(a0)
	clr.l	d0
	unlk	a6
	rts

_xlongjmp: link	a6,#0
	move	12(a6),d0
	tst	d0
	bne	okrc
	move	#1,d0
okrc:	move.l	8(a6),a0
	move.l	(a0)+,a6
	move.l	(a0)+,a7
	move.l	(a0),-(sp)
	rts
*
_bios:	move.l	(sp)+,biosav
	trap	#13
	move.l	biosav,-(sp)
	rts
*
_div10:	link	a6,#0
	move.l	8(a6),d0
	divu	#10,d0
	swap	d0
	clr	d0
	swap	d0
	unlk	a6
	rts

_mod10:	link	a6,#0
	move.l	8(a6),d0
	divu	#10,d0
	clr	d0
	swap	d0
	unlk	a6
	rts
* call dosjr from within itself (or from linked-in shell)
_xoscall:
	move.l	(sp)+,retshell
	trap	#1
	move.l	retshell,-(sp)
	rts
*
parse:	lea	cpmfcb,a1
	cmp.b	#'9',(a0)
	bgt	nousr
	move.b	(a0)+,d0
	sub.b	#'0',d0
	ext.w	d0
	move	d0,d1
	cmp.b	#':',(a0)
	beq	dousr
	cmp.b	#'9',(a0)
	bgt	dousr
	move.b	(a0)+,d0
	sub.b	#'0',d0
	ext.w	d0
	mulu	#10,d1
	add	d0,d1
dousr:	move	#32,d0
	trap	#2
*	add	#1,a0
nousr:	cmp.b	#':',(a0)
	beq	nodrv
	cmp.b	#':',1(a0)
	bne	nodrv
	move.b	(a0)+,d0
	sub.b	#'@',d0
	bra	gotdrv
nodrv:	clr.b	d0
gotdrv:	move.b	d0,(a1)+	* store into fcb
	cmp.b	#':',(a0)
	bne	nownam
	add	#1,a0
nownam:	move	#7,d1
donam:	cmp.b	#'.',(a0)
	beq	endnam
	tst.b	(a0)
	beq	endnam
	move.b	(a0)+,(a1)+
	dbf	d1,donam
endnam:	tst	d1
	blt	nowext
padnam:	move.b	#' ',(a1)+
	dbf	d1,padnam
nowext:	move	#2,d1
	tst.b	(a0)
	beq	doext
	add	#1,a0
doext:	tst.b	(a0)
	beq	endext
	move.b	(a0)+,(a1)+
	dbf	d1,doext
endext:	tst	d1
	blt	filfcb
padext:	move.b	#' ',(a1)+
	dbf	d1,padext
filfcb:	move	#23,d1
dofil:	clr.b	(a1)+
	dbf	d1,dofil
	rts

_cpmopen:
	link	a6,#0
	movem.l	d1-d7/a0-a5,-(sp)
	move.l	8(a6),a0
	bsr	parse
	move.l	#cpmfcb,d1
	move	#15,d0
	trap	#2
	clr.b	cpmfcb+32
	movem.l	(sp)+,d1-d7/a0-a5
	unlk	a6
	rts

_cpmcreate:
	link	a6,#0
	movem.l	d1-d7/a0-a5,-(sp)
	move.l	8(a6),a0
	bsr	parse
	move.l	#cpmfcb,d1
	move	#22,d0
	trap	#2
	movem.l	(sp)+,d1-d7/a0-a5
	unlk	a6
	rts

_cpmclose:
	link	a6,#0
	movem.l	d1-d7/a0-a5,-(sp)
	move.l	#cpmfcb,d1
	move	#16,d0
	trap	#2
	movem.l	(sp)+,d1-d7/a0-a5
	unlk	a6
	rts
_cpmread:
	link	a6,#0
	movem.l	d1-d7/a0-a5,-(sp)
	move.l	8(a6),d1
	move	#26,d0
	trap	#2
	move.l	#cpmfcb,d1
	move	#20,d0
	trap	#2
	movem.l	(sp)+,d1-d7/a0-a5
	unlk	a6
	rts

_cpmwrite:
	link	a6,#0
	movem.l	d1-d7/a0-a5,-(sp)
	move.l	8(a6),d1
	move	#26,d0
	trap	#2
	move.l	#cpmfcb,d1
	move	#21,d0
	trap	#2
	movem.l	(sp)+,d1-d7/a0-a5
	unlk	a6
	rts

	.data
aris:	.dc.b	13,10,'(A)bort, (R)etry, or (I)gnore ?',0

	.bss
	.even
savess:	.ds.l	1						* JSL  20 Mar 85
ocrit:	.ds.l	1
oterm:	.ds.l	1
biosav:	.ds.l	1
retshell: .ds.l	1
cpmfcb:	.ds.b	36
	.ds.l	800   						* LTG  15 May 85
mystak:	.ds.l	1
	.end

