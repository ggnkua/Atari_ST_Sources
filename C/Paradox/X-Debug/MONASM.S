*	opt	ALINK,LATTICE
	IFEQ	__G2&1
	FAIL	broken asm
	ENDC

* various assembly-support routines for Mon (tabs=8)
* ASSUMES 32-bit INTEGERS

* if OLDMEM is defined then uses hacked Lattice malloc etc

	xref	_finish,_remember_doserr,_regs
	xref	_progstate,_proctype,_realproc,_machtype,_machtypeminor
	xref	__tos,_assumptions,_mint_version,_fputype,_loaded_high

STOP_COUNT	equ	10		200ths of a sec

Fopen	equ	$3d
Fread	equ	$3f
Fseek	equ	$42
Pexec	equ	$4b
Malloc	equ	$48

	include	mon.i

* we need keyboard (level 2) and VBL (level 4)
INTS_ON	macro
	and.w	#$f8ff,sr
	or.w	#$0200,sr
	endm

xmovec	macro
	movec	\1,a0
	move.l	a0,\2
	endm

READ_XREGS	macro
	opt	p=68030

	xmovec	vbr,_regs+REG_VBR(a4)
	xmovec	sfc,_regs+REG_SFC(a4)
	xmovec	dfc,_regs+REG_DFC(a4)
	xmovec	cacr,_regs+REG_CACR(a4)
	xmovec	caar,_regs+REG_CAAR(a4)
	xmovec	msp,_regs+REG_MSP(a4)
	xmovec	isp,_regs+REG_ISP(a4)

* and now the MMU regs
	pmove.d	crp,_regs+REG_CRP(a4)
	pmove.d	srp,_regs+REG_SRP(a4)
	pmove.l	tc,_regs+REG_TC(a4)
	pmove.l	tt0,_regs+REG_TT0(a4)
	pmove.l	tt1,_regs+REG_TT1(a4)
	pmove.w	psr,_regs+REG_MMUSR(a4)

	opt	p=68000
	ENDM

* exception installer code; smart to allow MonST mon without probs
* also switches debugger into supervisor mode

	xdef	_init_exceptions,_deinit_exceptions

_init_exceptions
	movem.l	d2/a2,saved2a2(a4)

	move.w	#$4afc,_illegal_op(a4)

	move.l	#(14<<16)+1,-(sp)
	trap	#14
	addq.l	#4,sp
	move.l	d0,io_rec(a4)			for the keybd

	move.l	sp,oldmonusp(a4)
	pea	monssp(a4)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldmonssp(a4)
	move.l	oldmonusp(a4),a0
	move.l	(a0),-(sp)			so we can rts
* check processor & machine via cookie
* also installs new 502 handler
	lea	$502.w,a0
	move.l	(a0),old_502
	move.l	#my_502,(a0)
; now do the processor stuff
	move.l	#'_CPU',d1
	bsr	find_cookie
	bne.s	.nocpu
	move.w	d0,_proctype(a4)
.nocpu	move.l	#'_MCH',d1
	bsr	find_cookie
	bne.s	.nomch
	move.w	d0,_machtypeminor(a4)
	swap	d0
	move.w	d0,_machtype(a4)
.nomch	move.l	#'MiNT',d1
	bsr	find_cookie
	bne.s	.nomint
	bset	#bit_exitpc,_assumptions(a4)
	move.w	d0,_mint_version(a4)
.nomint
	move.w	_proctype(a4),d0	realproc not inited yet
	beq	.ok
* read the 68k registers for useful reg window display
	cmp.w	#30,d0
	bne.s	.nox
	READ_XREGS			030 only
.nox
* >68000s have one entry point for all codes
	movem.l	a3/a5,-(sp)
	lea	extable68k(pc),a3
	lea	oldextable(a4),a5
	cmp.w	#20,_proctype(a4)	(realproc not yet set)
	blt.s	.020
* check for maths processors
	move.l	#'_FPU',d1
	bsr	find_cookie
	bne.s	.nofpu
	swap	d0
	cmp.b	#10,d0
	bcc.s	.nofpu			if unknown cookie
	
	move.l	sp,a0			remember sp
	move.b	.fpulookup(pc,d0.w),d0
	bpl.s	.known
* stupid BIOS doesn't know what it is!
	moveq	#81,d0
	opt	p=68881
	fnop
	fsave	myfpustate(a4)
	opt	p=68000
	cmp.b	#$18,myfpustate+1(a4)
	beq.s	.known			if 68881
	addq.b	#1,d0			else 68882
.known
	move.l	a0,sp			restore SSP
	move.b	d0,_fputype(a4)
	beq.s	.nofpu
* install FPU exceptions if we have one
	lea	extablefpu(pc),a3
.fpulist
	move.w	(a3)+,d0		number
	move.l	(a3)+,d1		addr
	beq.s	.endfpu
	move.l	d1,-(sp)
	move.w	d0,-(sp)
	move.w	#5,-(sp)
	trap	#13
	addq.w	#8,sp
	move.l	d0,(a5)+
	bra.s	.fpulist
.endfpu
	subq.w	#6,a3
	bra.s	.020			then install regular ones


* install 020 exceptions
.nofpu	lea	extable20(pc),a3
.020	move.w	(a3)+,d0
	beq.s	.endex
	addq.w	#4,a3
	pea	ex020(pc)
	cmp.w	#2,d0
	bne.s	.notbus
	cmp.w	#30,_proctype(a4)
	bne.s	.notbus
	move.l	#ex30buserror,(sp)	030 bus errors are special
.notbus	move.w	d0,-(sp)
	move.w	#5,-(sp)
	trap	#13
	move.l	d0,(a5)+
	addq.w	#8,sp
	bra.s	.020

.fpulookup	dc.b	0,0
	dc.b	-1,-1
	dc.b	81,81
	dc.b	82,82
	dc.b	40,40

* install 68k vectors
.ok	movem.l	a3/a5,-(sp)
	lea	extable68k(pc),a3
	lea	oldextable(a4),a5
.ex	move.w	(a3)+,d0
	beq.s	.endex
	move.l	(a3)+,-(sp)			new routine
* only install lineF if relevent
	cmp.w	#11,d0
	bne.s	.notlinef
	cmp.w	#$0106,__tos
	bge.s	.notlinef
	move.l	#-1,(sp)			dont change it
.notlinef
	move.w	d0,-(sp)
	move.w	#5,-(sp)
	trap	#13
	move.l	d0,(a5)+
	addq.w	#8,sp
	bra.s	.ex
.endex	movem.l	(sp)+,a3/a5
	move.w	_proctype(a4),_realproc(a4)

* install other vectors
	move.w	sr,-(sp)
	or.w	#$0700,sr			dont interrupt
	pea	my_timer(pc)
	move.l	#$00050045,-(sp)
	trap	#13
	addq.l	#8,sp
	move.l	d0,old_timer(a4)
	move.w	(sp)+,sr

* and patch the trap vectors
	lea	trap_table,a3
	lea	old_trap,a5
.loop	move.l	(a3)+,-(sp)
	move.w	(a3)+,-(sp)
	move.w	#5,-(sp)
	trap	#13
	addq.w	#8,sp
	move.l	d0,(a5)+
	move.w	#-1,(a5)+
	tst.l	(a3)
	bne.s	.loop

	movem.l	saved2a2(a4),d2/a2

	rts


	xdef	find_cookie

* given d1.l, find the cookie for it
* if found, returns EQ, d0=the value
* else NE
* needs supervisor mode, uses d0/a0
find_cookie
	move.l	$5a0.w,d0
	beq.s	.notfound		if none
	move.l	d0,a0
.cloop	move.l	(a0)+,d0
	beq.s	.notfound
	cmp.l	d0,d1
	beq.s	.gotm2
	addq.w	#4,a0
	bra.s	.cloop
.gotm2	move.l	(a0),d0
	cmp.b	d0,d0
	rts
.notfound
	moveq	#-1,d0
	rts


ex	macro
	dc.w	\1
	dc.l	ex_\2
	endm

extablefpu
	ex	48,fpu
	ex	49,fpu
	ex	50,fpu
	ex	51,fpu
	ex	52,fpu
	ex	53,fpu
	ex	54,fpu
	dc.w	13,0,0			coproc protocol violation
extable20
	dc.w	14,0,0			Format error
	dc.w	56,0,0			MMU config error
extable68k
	ex	2,bus
	ex	3,addr
	ex	4,illegal
	ex	5,div0
	ex	6,chk
	ex	7,trapv
	ex	8,priv
	ex	9,trace
	ex	11,linef		only when relevent
	ex	15,unint
	ex	24,spint
	ex	32,unusedtrap
	ex	32+3,unusedtrap
	ex	32+4,unusedtrap
	ex	32+5,unusedtrap
	ex	32+6,unusedtrap
	ex	32+7,unusedtrap
	ex	32+8,unusedtrap
	ex	32+9,unusedtrap
	ex	32+10,unusedtrap
	ex	32+11,unusedtrap
	ex	32+12,unusedtrap
	ex	32+15,unusedtrap
	dc.w	0

MAXEX	equ	(*-extablefpu-2)/6

* this is same for all processors
_deinit_exceptions
	tst.l	oldmonssp(a4)
	beq	.inuser
	movem.l	d2/a2/a3/a5,-(sp)
	lea	extable68k(pc),a3
	lea	oldextable(a4),a5
	cmp.w	#20,_realproc(a4)
	blt.s	.ex
	lea	extable20(pc),a3
	tst.b	_fputype(a4)
	beq.s	.ex
	lea	extablefpu(pc),a3
.ex	move.w	(a3)+,d0
	beq.s	.endex
	move.l	(a5)+,-(sp)
	move.w	d0,-(sp)
	move.w	#5,-(sp)
	trap	#13
	addq.l	#8,sp
	addq.l	#4,a3
	bra.s	.ex

.endex

	move.l	old_timer(a4),d0
	beq.s	.notimer
	move.l	d0,-(sp)
	move.l	#$00050045,-(sp)
	trap	#13
	addq.w	#8,sp
.notimer
	move.l	old_502(a4),d0
	beq.s	.no502
	move.l	d0,$502.w
.no502	lea	old_trap,a3
	lea	trap_table,a5
.untrap	move.l	(a5)+,d0
	beq.s	.nodos
	move.l	(a3)+,d0
	beq.s	.nodos
	move.l	d0,-(sp)
	move.w	(a5)+,-(sp)
	addq.w	#2,a3
	move.w	#5,-(sp)
	trap	#13
	addq.w	#8,sp
	bra.s	.untrap
.nodos
	movem.l	(sp)+,d2/a2/a3/a5
* get back to user mode
	move.l	(sp),saved2a2(a4)			ret addr
	move.l	oldmonssp(a4),-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	saved2a2(a4),-(sp)
.inuser	rts

******* 68000-only Exception Handlers ************
******* must pass on those that happen in Mon ****

* crude macro; if super exception then pass on
* return NE if not when expected (ie EQ=user program is running)
CHECKWITHIN	macro
	cmp.b	#2,_progstate
	endm

* go to the old handler
OLDEX	macro
	move.l	oldextable+\1,-(sp)
	rts
	endm

ORD	macro
	movem.l	a4/d0,-(sp)
	moveq	#\1,d0
	bra	ordinary_exception
	endm
	
ex_bus	CHECKWITHIN	8
	beq.s	.dobus
	OLDEX	0
.dobus	move.w	6(sp),_regs+REG_MSP+2
	lea	8(sp),sp
	ORD	2

ex_addr	CHECKWITHIN	8
	beq.s	.doaddr
	OLDEX	4
.doaddr	move.w	6(sp),_regs+REG_MSP+2
	lea	8(sp),sp
	ORD	3

ex_illegal
	CHECKWITHIN
	beq.s	.ill
	OLDEX	8
.ill	ORD	4
ex_trace
	CHECKWITHIN
	beq.s	.dotrace
	OLDEX	7*4
.dotrace
	tst.l	special_trace
	beq.s	.dot2
	move.l	special_trace,-(sp)
	rts
.dot2	ORD	9

ex_div0		ORD	5
ex_chk		ORD	6
ex_trapv	ORD	7
ex_priv		ORD	8
ex_linef	ORD	9
ex_unint	ORD	14
ex_spint	ORD	24
ex_trap		ORD	EXNUM_TRAP
ex_unusedtrap	ORD	EXNUM_UNUSEDTRAP

* assumes simple stackframe, d0/a4 pushed, d0=exnumber
ordinary_exception
	GETA4
	move.l	(sp)+,_regs+REG_D0(a4)
	move.l	(sp)+,_regs+REG_A0+16(a4)
	move.w	(sp)+,_regs+REG_SR(a4)
	move.l	(sp)+,_regs+REG_PC(a4)
	move.l	sp,_regs+REG_SSP(a4)

	move.l	savesp(a4),sp		use our stack now
	movem.l	d1-d7/a0-a3,_regs+REG_D0+4(a4)
	movem.l	a5-a6,_regs+REG_A0+20(a4)
	move.l	usp,a0
	move.l	a0,_regs+REG_A0+7*4(a4)
* check for (accidental) exec into trap buffer
report_ex
	move.l	_regs+REG_PC(a4),d1
	cmp.l	#trapbuffer,d1
	blt.s	.no
	cmp.l	#endbuffer,d1
	bgt.s	.no
	move.l	realpc(a4),_regs+REG_PC(a4)
.no	INTS_ON
	movem.l	(sp)+,CREGS2
	clr.l	special_trace(a4)
	rts				with d0=exnumber

ttrap	bclr	#7,(sp)			lose trace bit
	move.l	#ttrap2,special_trace
.not20	rte				do the trap proper

ttrap2	move.l	realpc,2(sp)
	clr.l	special_trace
	tst.w	$59e.w
	beq	ex_trace		if 68k
	bra	got_020ex		CHECK for 68010/020s

********* 68030 exception handling

	opt	p=68020/68881

* called by fpu exceptions 48-54
ex_fpu	CHECKWITHIN
	bne.s	go_old_20
	fsave	-(sp)		save it all
	tst.b	(sp)
	beq.s	.null
	move.w	d0,-(sp)
	move.w	2(sp),d0
	and.w	#$ff,d0
	bset	#3,2(sp,d0.w)
	move.w	(sp)+,d0
.null	frestore	(sp)+
	bra.s	got_020ex

	opt	p=68000

* called by all non-fp exceptions
ex020	CHECKWITHIN
	beq.s	normal_20
* this finds the old vector and goes to it
go_old_20
	clr.l	-(sp)
	movem.l	d0/a0/a1/a4,-(sp)
	GETA4
	lea	extablefpu(pc),a0
	lea	oldextable(a4),a1
	move.w	6+5*4(sp),d0
	and.w	#%111111111111,d0
	lsr.w	#2,d0			from vector offset to vector number
.find	cmp.w	(a0)+,d0
	beq.s	.gotit
	addq.w	#4,a0
	addq.w	#4,a1
	bra.s	.find			had better be there!
.gotit	move.l	(a1),4*4(sp)		set RTS addr
	movem.l	(sp)+,d0/a0/a1/a4
	rts

normal_20
	cmp.w	#(%0010<<12)+$24,6(sp)
	bne.s	got_020ex
	tst.l	special_trace
	beq.s	got_020ex
	move.l	special_trace,-(sp)
	rts
got_020ex
	movem.l	d0/a4,-(sp)
	GETA4
	move.l	(sp)+,_regs+REG_D0(a4)
	move.l	(sp)+,_regs+REG_A0+4*4(a4)
	move.w	(sp)+,_regs+REG_SR(a4)
	move.l	(sp)+,_regs+REG_PC(a4)
	move.w	(sp)+,d0			d0=magic word
	move.l	sp,_regs+REG_SSP(a4)

	move.l	savesp(a4),sp			use our stack
	movem.l	d1-d7/a0-a3,_regs+REG_D0+4(a4)
	movem.l	a5/a6,_regs+REG_A0+5*4(a4)
	move.l	usp,a0
	move.l	a0,_regs+REG_A0+7*4(a4)

	lea	_regs+REG_SSP(a4),a2
	move.l	(a2),a1				ready for further corrections
	lea	_regs+REG_PC(a4),a3

* now, which exception are we?
	move.w	d0,d7				remember full word
	rol.w	#4,d0
	and.w	#%1111,d0			the top 4 bits
	beq.s	.simple				if 4-word
	cmp.w	#%0001,d0
	beq.s	.simple				if interrupt (!)
	cmp.w	#%0010,d0
	beq.s	.6word
	cmp.w	#%1001,d0
	beq.s	.coprocmid
	cmp.w	#%1010,d0
	beq.s	.shortbus
	cmp.w	#%1011,d0
	beq.s	.longbus
* others here, I guess
	moveq	#EXNUM_UNKNOWN,d7
	bra.s	.simple
* six word stack frame has another PC on it, v. handy
.6word	move.l	(a1)+,d0
	cmp.w	#(%0010<<12)+$24,d7
	beq.s	.6wtr				except for Trace,
	move.l	d0,(a3)				get the new PC
.6wtr	move.l	a1,(a2)				remember new SSP
	bra.s	.simple
* coproc mid instruction
.coprocmid
	move.l	(a1)+,(a3)			get the new PC
	addq.w	#4*2,a1
	move.l	a1,(a2)
	bra.s	.simple
* short bus cycle
.shortbus
	lea	12*2(a1),a1
	move.l	a1,(a2)
	bra.s	.simple
* long bus cycle. PC will be crap, unfortunately
.longbus
	lea	(24+18)*2(a1),a1
	move.l	a1,(a2)
* here d7=the magic word, everything else is OK
.simple

* remember the extra registers
	READ_XREGS

	move.w	#%111111111111,d0
	and.w	d7,d0				vector offset
	lsr.w	#2,d0				->exception number
	INTS_ON
	movem.l	(sp)+,CREGS2
	clr.l	special_trace(a4)
	rts

	opt	p=68030

* 030 bus error handler is special, to cope with MMU tricks
	xref	_wplist
ex30buserror
	tst.l	_wplist
	beq	ex020				if none then normal
EXTRABUS	set	4*4
	or.w	#$0700,sr			dont get interrupted!
	movem.l	d0/d1/a0/a1,-(sp)
	move.w	6+EXTRABUS(sp),d0
	rol.w	#4,d0
	and.b	#$f,d0
	cmp.b	#%1011,d0
	beq.s	.longbus
	cmp.b	#%1010,d0
	beq.s	.longbus			really short bus
.oldbus	movem.l	(sp)+,d0/d1/a0/a1
	bra	ex020
.oldbus3
	movem.l	(sp)+,d2/a2
.oldbus2
	movec	d1,dfc			restore it
	pmove.w	saved_psr,psr
	bra.s	.oldbus

; both short & long have things in same place!!
.longbus
	move.w	$a+EXTRABUS(sp),d0	SSW
	btst	#8,d0
	beq.s	.oldbus			if not a data fault
	tst.b	d0
	bmi.s	.oldbus			cannot cope with RMW
	btst	#6,d0
	bne.s	.oldbus			if a Read
* OK, its a write. Was it caused by a WP DCR?
	move.l	$10+EXTRABUS(sp),a0
	movec	dfc,d1			save the DFC
	movec	d0,dfc			FC got from above
	pmove.w	psr,saved_psr		in case program uses it (!)
	ptestw	dfc,(a0),#7,a1
	move.l	a1,d0
	beq.s	.oldbus2		if no DCR
	pmove.w	psr,temp_psr		why cant we use a data reg!
	move.w	temp_psr,d0
	btst	#11,d0
	beq.s	.oldbus2		if not WP violation
* Is it allowed?
EXTRABUS	set	EXTRABUS+4*2
	movem.l	d2/a2,-(sp)
	CHECKWITHIN
	bne	pretend			always pretend so Mon can write to memory
	lea	_wplist,a2
.fprot	move.l	(a2)+,d1
	beq	pretend			if not in list then pretend
	cmp.l	d1,a0
	blt.s	.next			if this<tablestart then try next
	cmp.l	(a2),a0
	bgt.s	.next			or if this>tableend then try next
* find end of protection range for this write
	moveq	#%11<<4,d0
	and.w	$a+EXTRABUS(sp),d0	SSW
	move.l	a0,d2
	add.l	size_table(pc,d0.w*4),d2	end of attempted access
	cmp.l	(a2),d2
	blt	.oldbus3		if part protected
	bra.s	pretend			else its allowed

.next	addq.w	#4,a2
	bra.s	.fprot
* OK, lets pretend to do the write
pretend	bclr	#2,3(a1)		un write-protect
	move.l	a1,last_dcr
	move.l	a0,last_addr
	movec	vbr,a2
	lea	9*4(a2),a2
	move.l	(a2),last_trace
	move.l	#my_trace,(a2)
**BUG	pflush	#0,#0,(a0)		flush all ATC entries for the addr
	dc.l	$f0103810
	movem.l	(sp)+,d2/a2
	movem.l	(sp)+,d0-d1/a0-a1
	move.w	(sp),last_sr
	bclr	#6,(sp)
	bset	#7,(sp)
	rte				and retry
size_table	dc.l	1,4,4,2		%01 is not defined


my_trace
	move.l	a0,-(sp)
	movec	vbr,a0
	move.l	last_trace,9*4(a0)
**BUG	bset	#2,([last_dcr],3)	hey wow! WP the DCR
	move.l	last_dcr,a0
	bset	#2,3(a0)
**	pflush	#0,#0,([last_addr])	this gives line-F - WHY?
	move.l	last_addr,a0
**BUG	pflush	#0,#0,(a0)
	dc.l	$f0103810
	move.l	(sp)+,a0
* copy the 2 trace bits back correctly
	move.w	d0,-(sp)
	move.w	#$3fff,d0
	and.w	d0,2(sp)		lose both on stack
	not.w	d0
	and.w	last_sr,d0		mask all but trace bits
	or.w	d0,2(sp)		put them back
	move.w	(sp)+,d0
	rte


	IFD	OLDMEM

	xref	__addheap,__maxblk,_malloc,_keepheap

* before running something else, we need to allocate some memory
* on our heap. We must do this only once
* we must also stop the C library from doing DOS Mallocs
* we do this by malloc'ing some, the passing it to addheap (!)
BEFOREEXEC	macro
	tst.b	havekept(a4)
	bne.s	.done\@
	st	havekept(a4)
	and.b	#~%11,_keepheap+3(a4)		multiple of 4
	move.l	_keepheap(a4),d0
	beq.s	.done\@				if not required
	move.l	d0,-(sp)
	jsr	_malloc
	addq.w	#4,sp
	tst.l	d0
	beq.s	.done\@				if cannot
	move.l	_keepheap(a4),-(sp)
	move.l	d0,-(sp)
	jsr	__addheap
	addq.w	#8,sp
.done\@	move.l	__maxblk(a4),oldmax(a4)
	clr.l	__maxblk(a4)			stop DOS Mallocs
	endm

* when our child has quit, we can call DOS Malloc again
AFTEREXEC	macro
	move.l	oldmax(a4),__maxblk(a4)
	endm

	ELSEIF
* all-new memory allocator; rather neater!
	XREF	_heapshrink,_unheapshrink
	
* allocate our keepheap area, shrink us down, then free it up
BEFOREEXEC	macro
	jsr	_heapshrink		and lock
	endm
AFTEREXEC	macro
	jsr	_unheapshrink
	endm
	ENDC

* load a program into memory, but don't run it
* C caller: err=load_exec(progname,cmdline,&startpc)
* (cmdline is in C-string format)

	xdef	_start_exec,_resume_exec,_load_exec
	xdef	_kill_prog,_resume_trap,_progbp

	xref	_strlen,_strncpy
	xref	_st_text,_st_data,_st_bss,_st_end
	xref	_basepagetype

	IFEQ	DEMO
	
	xdef	_load_bin_exec,_create_basepage,_start_tsr

_load_exec	PROC
	cargs	#8,.prog.l,.cmd.l,.startptr.l
	lea	-128(sp),sp			string buffer
	move.l	.cmd(a6),-(sp)
	jsr	_strlen
	cmp.l	#124,d0
	ble.s	.shortcmd
	moveq	#124,d0				truncate it
.shortcmd
	move.b	d0,4(sp)			set length byte
	move.l	d0,(sp)
	move.l	.cmd(a6),-(sp)
	pea	4+4+1(sp)
	jsr	_strncpy			dont care if no null
	lea	3*4(sp),sp

	pea	-1.w
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	cmp.l	#4096,d0
	bcc.s	.memok
	moveq	#ERRM_NOSYSMEM,d0
	bra	.xexec
.memok	BEFOREEXEC
	clr.l	-(sp)			dumb env
	pea	4(sp)			our copy of the string
	move.l	.prog(a6),-(sp)
	move.w	#3,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp
	tst.l	d0
	bmi.s	.doserr
	move.l	d0,_progbp(a4)		save bp ptr
	move.l	d0,a0
	move.l	.startptr(a6),a1
	move.l	8(a0),(a1)		text segment start
	move.l	8(a0),_st_text(a4)
	move.l	$10(a0),_st_data(a4)
	move.l	$18(a0),d0
	move.l	d0,_st_bss(a4)
	add.l	$1c(a0),d0
	move.l	d0,_st_end(a4)
	moveq	#0,d0			worked OK
	move.l	d0,_program_timer(a4)
	bra.s	.xexec
.doserr	move.l	d0,-(sp)
	AFTEREXEC
	jsr	_remember_doserr
	addq.l	#4,sp			returns suitable d0
.xexec	lea	128(sp),sp
	ENDPROC

* load a binary prog as if it were executable
_load_bin_exec	PROC
	cargs	#8,.prog.l,.start.l
	moveq	#0,d3			show no file yet
	BEFOREEXEC

	pea	-1.w
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	cmp.l	#4096,d0
	bcc.s	.memok
	moveq	#ERRM_NOSYSMEM,d0
	bra	.xexec
.memok	clr.w	-(sp)
	move.l	.prog(a6),-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq.w	#8,sp
	move.l	d0,d3
	bmi	.doserr			if cannot find it
	bsr	_create_basepage
	tst.l	d0
	bmi.s	.doserr
	move.l	d0,_progbp(a4)		save bp ptr
	move.l	d0,a0
	move.l	.start(a6),a1
	lea	$100(a0),a2		the text seg
	move.l	a2,(a1)			text segment start
	move.l	a2,8(a0)		set in bp
	move.l	a2,_st_text(a4)		TEXT is start addr
* read the file in now
	move.l	4(a0),d4		end of TPA
	sub.l	(a0),d4			start
	sub.l	#$100+$100,d4		less bp and stack
	move.l	a2,-(sp)		where it goes
	move.l	d4,-(sp)
	move.w	d3,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	bmi.s	.doserr			if read error
	cmp.l	d0,d4
	bne.s	.rdsmall
	moveq	#-49,d0			out of memory
	bra.s	.doserr
.rdsmall
	move.l	_st_text(a4),a0
	add.l	a0,d0
	move.l	d0,_st_data(a4)		data=end
	move.l	d0,_st_bss(a4)
	move.l	d0,_st_end(a4)
* clear out from d0 to a0+d4
	bclr	#0,d4
	move.l	d0,a1
	btst	#0,d0
	beq.s	.even
	clr.b	(a1)+
	addq.l	#1,d0
.even	add.l	a0,d4
	sub.l	d0,d4
	ble.s	.nofill
	lsr.l	#2,d4
	beq.s	.nofill			into longs
	move.l	d0,a0
	moveq	#0,d0
.clr	move.l	d0,(a0)+
	subq.l	#1,d4
	bne.s	.clr
.nofill
	moveq	#0,d0
	move.l	d0,_program_timer(a4)
	bra.s	.xexec			worked OK

.doserr	move.l	d0,-(sp)
	AFTEREXEC
	jsr	_remember_doserr
	addq.w	#4,sp			returns suitable d0
.xexec	tst.l	d3
	ble.s	.noclo
	move.w	d0,-(sp)
	move.w	d3,-(sp)
	move.w	#$3e,-(sp)
	trap	#1			close
	addq.w	#4,sp
	move.w	(sp)+,d0
.noclo	ENDPROC

; creates a basepage, maybe using TT special pexec
_create_basepage
	movem.l	d2/a2,-(sp)
	clr.l	-(sp)			dumb env
	move.l	sp,-(sp)		cmd line=nothing
	move.l	_basepagetype(a4),-(sp)
	move.w	#7,-(sp)
	move.w	#$4b,-(sp)
	trap	#1			create a TT basepage
	lea	16(sp),sp
	cmp.l	#-32,d0
	bne.s	.rts			if worked
; the call doesn't exist so use old-fasioned method
	clr.l	-(sp)			dumb env
	move.l	sp,-(sp)		cmd line=nothing
	clr.l	-(sp)			unused
	move.w	#5,-(sp)
	move.w	#$4b,-(sp)
	trap	#1			create a basepage
	lea	16(sp),sp
.rts	movem.l	(sp)+,d2/a2
	rts

_start_tsr
	move.l	4(sp),d0		shrink size
	movem.l	CREGS2,-(sp)
	move.l	sp,savesp(a4)
	tst.b	_loaded_high
	bne.s	.highquit
	clr.w	-(sp)
	move.l	d0,-(sp)
	move.w	#$31,-(sp)
	trap	#1
	illegal
.highquit
	move.l	#$4c0000,-(sp)
	trap	#1
	illegal

	ENDC				of non-demo area

_start_exec
	movem.l	CREGS2,-(sp)
	move.l	sp,savesp(a4)		so we can get back

	lea	execssp(a4),sp
	clr.l	-(sp)
	move.l	_progbp(a4),-(sp)
	clr.l	-(sp)
	move.w	#4,-(sp)		just go
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp
	move.l	d0,-(sp)
	GETA4
	AFTEREXEC
	move.l	_progbp(a4),a0
	btst	#bit_exitpc,_assumptions(a4)
	bne.s	.noxpc
* get the exit PC by v naughty means (doesn't work on MiNT)
	move.l	$7c(a0),a1
	move.l	6(a1),d0
	move.l	d0,_regs+REG_PC(a4)		after the trap
.noxpc
* free up the memory
	move.l	$2c(a0),-(sp)			save env ptr
	move.l	a0,-(sp)
	move.w	#$49,-(sp)
	trap	#1				free prog
	addq.l	#6,sp
	move.w	#$49,-(sp)
	trap	#1				free env
	addq.l	#6,sp
	moveq	#0,d0				'exited'
	move.l	(sp)+,_regs+4(a4)		show return code
* would be useful to extract other regs from BP?
	move.l	savesp(a4),sp
	bra	report_ex

_resume_exec
	clr.l	special_trace(a4)
_resume_exec2
	movem.l	CREGS2,-(sp)
	move.l	sp,savesp(a4)
	move.l	_regs+REG_A0+7*4(a4),a0
	move.l	a0,usp
	move.l	_regs+REG_SSP(a4),a7
	move.w	_realproc(a4),d0
	beq.s	.68k
	clr.w	-(sp)				Four word throwaway
	cmp.w	#30,d0
	bne.s	.68k
* restore 030 regs that Mon may use
	pmove.w	_regs+REG_MMUSR(a4),psr
.68k	move.l	_regs+REG_PC(a4),-(sp)
	move.w	_regs+REG_SR(a4),-(sp)		make stack frame
	movem.l	_regs+REG_D0(a4),d0-d7/a0-a6
	rte

* Tracing over a trap is special
* we Trace the op, then resume it, using a copy of the trap
* to capture the bit
_resume_trap
	move.l	#ttrap,special_trace(a4)
	lea	trapbuffer,a1
	move.l	_regs+REG_PC(a4),a0
	move.w	(a0)+,(a1)			copy the trap
	move.l	a1,_regs+REG_PC(a4)
	move.l	a0,realpc(a4)
	move.w	_regs+REG_SR(a4),d0
	bset	#15,d0
	bclr	#14,d0				set ordinary Trace mode
	bra.s	_resume_exec2			then do it

* terminate the user-program
_kill_prog
	movem.l	CREGS2,-(sp)
	move.l	sp,savesp(a4)
	move.w	#-32,-(sp)			like 'Ctrl-C'
	move.w	#$4c,-(sp)
	trap	#1

	IFNE	0
* required until the Supexec call is fixed in Lattice 5
* C caller: Supexeclong(function,param)

	xdef	_Supexeclong

* 0.l	return addr
* 4.l	fn
* 8.l	param

_Supexeclong
	move.l	8(sp),-(sp)		param
	move.l	4+4(sp),-(sp)		fn
	move.w	#$26,-(sp)
	trap	#14
	lea	10(sp),sp
	rts
	ENDC

	xdef	_junk_keys

* 0.l return
* 4.l key to junk (ignored at present)
* had better be supervisor mode......
_junk_keys
	move.l	io_rec,a0		NOT a4 as called from int
	move.w	6(a0),8(a0)		no atomicy needed
	rts

	xref	_shiftstatus
* called to dump screen - if either shift then sets stop bits
* cannot rely on a4, can only trash a0
my_502	movem.l	a0/d0,-(sp)
	move.l	_shiftstatus,a0
	moveq	#%11,d0
	and.b	(a0),d0
	movem.l	(sp)+,a0/d0
	beq.s	.old502
	move.b	#STOP_COUNT,stop_me
	rts
.old502	move.l	old_502,-(sp)
	rts

my_trap	macro	name
	SECTION	__MERGED,BSS
old_\1	ds.l	1
_stop_\1	ds.w	1
	xdef	_stop_\1
	SECTION	TEXT
my_\1	tst.w	_stop_\1
	bmi.\0	.olddos
	CHECKWITHIN
	bne.\0	.olddos			dont stop Mon
	tst.w	(sp)
	bmi.\0	.olddos			skip if being traced
	movem.l	d0/a0,-(sp)
	move.l	usp,a0
	btst	#13-8,0+8(sp)
	beq.s	.gotsp			if User mode
	lea	6+8(sp),a0		else supervisor
	tst.w	$59e.w
	beq.s	.gotsp
	addq.w	#2,a0
.gotsp	move.w	_stop_\1,d0
	cmp.w	(a0),d0
	IFNC	'\1','dos'
	beq	stopdos
	ELSEIF
	xref	_waitname
	bne	.notme2
	tst.b	_waitname
	beq	stopdos			if user break
	tst.b	_loaded_high
	bne	stopdos			if loaded high
	cmp.w	#Pexec,d0
	bne.s	.notpexec
* OK, I'm waiting for a name: compare them
	cmp.w	#3,2(a0)
	bne	.notme2			only Desk Accs so far
	move.l	4(a0),a0
	bsr	checkname
	beq	stopdos			if name matches
	bra	.notme2
.notpexec
	cmp.w	#Fread,d0
	bne.s	.notfread
	cmp.l	#$1c,4(a0)
	bne.s	.not1c
	move.l	8(a0),last_1c
.not1c	tst.b	stop_read
	bne.s	.stopread
	move.w	#Malloc,_stop_dos
	bra	.notme2

.stopread
**debug	illegal
	move.l	8(a0),d0
	move.l	d0,_st_text
	move.l	last_1c,a0
	add.l	2(a0),d0
	move.l	d0,_st_data
	add.l	6(a0),d0
	move.l	d0,_st_bss
	add.l	$a(a0),d0
	move.l	d0,_st_end
	bra	stopdos			then read
.notfread
	cmp.w	#Fopen,d0
	bne.s	.notfopen
* OK, I'm waiting for a name
	tst.w	6(a0)
	bne.s	.notme2			if not Read
	move.l	2(a0),a0
	bsr	checkname
	bne.s	.notme2
* OK, its an Open, wait for a seek
	move.w	#Fseek,_stop_dos
	bra.s	.notme2
.notfopen
	cmp.w	#Fseek,d0
	bne.s	.notfseek
* if the Seek is $200 then wait for read, else back to fopen
	cmp.l	#$200,2(a0)
	bne.s	.redo			if not from
.stprd	move.w	#Fread,_stop_dos
	bra.s	.notme2

.redo	move.w	#Fopen,_stop_dos
	bra.s	.notme2

.notfseek
	cmp.w	#Malloc,d0
	bne.s	.notmal
	st	stop_read
	bra.s	.stprd
.notmal
	bra.s	.redo			if unexpected, restart from fopen

.notme2
	ENDC
	movem.l	(sp)+,d0/a0
.olddos	move.l	old_\1,-(sp)
	rts
	ENDM

checkname
	move.l	a1,-(sp)
	lea	_waitname,a1
.cmp	move.b	(a1)+,d0
	beq.s	.end
	cmp.b	(a0)+,d0
	beq.s	.cmp
	move.l	(sp)+,a1
	rts
.end	move.l	(sp)+,a1
	tst.b	(a0)
	rts

	SECTION	__MERGED,BSS
old_trap
	my_trap.w	dos
	my_trap.s	bios
	my_trap.s	xbios

* OK, lets convert into a special exception
stopdos
	movem.l	(sp)+,d0/a0
	subq.l	#2,2(sp)		rewind PC to the actual Trap
	tst.w	$59e.w
	beq	ex_trap

* we need to change the type of the exception
* NOT 68010 compatible
.longtrace
	move.w	#EXNUM_TRAP<<2,6(sp)
	bra	ex020

	xref	_romstart,_romend

* called by 200Hz interrupt. May stop program.
* DONT ASSUME A4!!
my_timer
	CHECKWITHIN
	bne.s	.notimer		dont when in me
	addq.l	#1,_program_timer

	tst.b	stop_me
	beq.s	.notimer
	movem.l	a0/d0,-(sp)
	move.b	stop_me,d0
* d0 is the countdown timer byte
.trystop
	subq.b	#1,d0
	beq.s	.stop			if time run out
* try to avoid ROM addresses, if possible
	move.l	8+2(sp),a0
	cmp.l	_romstart,a0
	blt.s	.stop
	cmp.l	_romend,a0
	bge.s	.nostop			saving reduced count
*.stop	bset	#15,8(sp)		set Trace bit
.stop	bset	#7,8(sp)
	bsr	_junk_keys		kill pending presses
	moveq	#0,d0
.nostop	move.b	d0,stop_me
.xtimer	movem.l	(sp)+,a0/d0
.notimer
	move.l	old_timer,-(sp)
	rts


	xdef	_stack_space

* returns free space left on stack
_stack_space
	lea	minssp(a4),a0
	move.l	a7,d0
	sub.l	a0,d0
	rts

savptr	equ	$4a2

	xdef	_realBconin,_realBconstat

_realBconin
	move.l	4(sp),d0
	moveq	#2,d1
	bra.s	bios_gen
_realBconstat
	move.l	4(sp),d0
	moveq	#1,d1
* do bios call d1 safely, with a word parameter of d0
bios_gen
	movem.l	d2/a2,-(sp)
	move.l	savptr.w,old_savptr(a4)
	move.l	#my_savptr,savptr.w
	move.w	d0,-(sp)
	move.w	d1,-(sp)
	trap	#13
	addq.w	#4,sp
	move.l	old_savptr(a4),savptr.w
	movem.l	(sp)+,d2/a2
	rts

; calculate a checksum over a range of memory
	xdef	_checksum
	xref	_peekb
_checksum
	movem.l	d2-d4/a2,-(sp)
	moveq	#0,d2
	moveq	#0,d4
	subq.w	#4,sp			for optimal stack usage
	move.l	4+20(sp),a2		the addr
	move.l	8+20(sp),d3		end addr
	sub.l	a2,d3			calc length
	beq.s	.none
.calc	move.l	a2,(sp)
	addq.w	#1,a2
	jsr	_peekb
	move.b	d0,d4
	add.l	d4,d2			add normally
	addx.l	d2,d2			and shift with carry
	subq.l	#1,d3
	bne.s	.calc
.none	move.l	d2,d0
	addq.w	#4,sp
	movem.l	(sp)+,d2-d4/a2
	rts

; if MMU is present and on then returns address mask, else -1
; requires supervisor mode
	xdef	_procmask
_procmask
	moveq	#-1,d0
	cmp.w	#30,_realproc(a4)
	bne.s	.nommu
	subq.w	#4,sp
	opt	p=68030
	pmove.l	tc,(sp)
	opt	p=68000
	move.l	(sp)+,d1
	bpl.s	.nommu			if disabled
	swap	d1
	and.w	#%1111,d1
	lsr.l	d1,d0			allow for IS values
.nommu	rts

* flush some or all of the caches
* ignored on processors lacking them
* 1=instruction, 2=data, 3=both
* supervisor mode required
* could be smarter and take an address as well, one day
	xdef	_flush_cache
_flush_cache
	move.l	4(sp),d0
	beq.s	.nowt
	cmp.w	#20,_realproc(a4)
	blt.s	.nowt
	opt	p=68020
	movec	cacr,d1
	lsr.b	#1,d0
	bcc.s	.noinst
	bset	#3,d1			lose I cache
.noinst	lsr.b	#1,d0
	bcc.s	.nodata
	bset	#11,d1			lose D cache (ignored on 020)
.nodata	movec	d1,cacr
	opt	p=68000
.nowt	rts

* is the PC etc at the start of a trap handler? bool result
* only call if realproc>=20
	xdef	_start_of_trap
_start_of_trap
	move.w	_regs+REG_SR(a4),d0
	and.w	#%111<<13,d0
	cmp.w	#%001<<13,d0
	bne.s	.ret			if not (Super but no trace)
	opt	p=68010
	movec	vbr,a0
	opt	p=68000
	lea	$80(a0),a0
	moveq	#16-1,d0
	move.l	_regs+REG_PC(a4),d1
.chk	cmp.l	(a0)+,d1
	dbeq	d0,.chk
.ret	seq	d0
	rts

*********************************
*	FPU Support Code	*
*********************************

	opt	p=68020/68881

	xdef	_get_fpu_cregs,_get_fpu_reg

_get_fpu_cregs
	move.l	4(sp),a0
	fsave	-(sp)			save program state
	frestore	myfpustate(a4)	switch into mine
**	fmovem.l	fpiar/fpcr/fpsr,(a0)	BUG
	dc.l	$f210bc00
	frestore	(sp)+
	rts

* get a FP register into ASCII, longword and double format (all optional)
* only called if fpu present
* leaves fpu state alone

_get_fpu_reg	PROC
	cargs	#8,.reg.l,.ascii.l,.long.l,.double.l
	fsave	-(sp)			don't disturb caller
	fmovem.x	fp0,-(sp)
**	fmovem.l	fpiar/fpsr/fpcr,-(sp)	BUG
	dc.l	$f227bc00

	frestore	myfpustate(a4)

	move.l	.reg(a6),d0		reg num
	beq.s	.gotfp			if wants fp0
	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0			d0=number*6
	jmp	.tab-6(pc,d0.w)		powerful jump table!
	
.tab	fmove.x	fp1,fp0
	bra.s	.gotfp
	fmove.x	fp2,fp0
	bra.s	.gotfp
	fmove.x	fp3,fp0
	bra.s	.gotfp
	fmove.x	fp4,fp0
	bra.s	.gotfp
	fmove.x	fp5,fp0
	bra.s	.gotfp
	fmove.x	fp6,fp0
	bra.s	.gotfp
	fmove.x	fp7,fp0
**	bra.s	.gotfp
	
.gotfp	move.l	.long(a6),d0
	beq.s	.nolong
	fmove.x	fp0,(d0.l)		save longwords
.nolong	move.l	.double(a6),d0
	beq.s	.nodbl
	fmove.d	fp0,(d0.l)		indirect via a data reg!!
.nodbl	move.l	.ascii(a6),d0
	beq.s	.noasc
	move.l	d0,a0
	bsr.s	format_fp		save ascii
.noasc
	dc.l	$f21f9c00
**	fmovem.l	(sp)+,fpiar/fpsr/fpcr	BUG
	fmovem.x	(sp)+,fp0
	frestore	(sp)+
	ENDPROC

.zero	dc.l	0

* in: fp0=reg, a0=buffer
* out: uses d0-d3/a0-a1
format_fp
	moveq	#'0',d2
	sub.w	#3*4,sp
	move.l	sp,a1
	fmove.p	fp0,(a1){#-64}		convert to BCD
	
	bfextu	(a1){4:12},d1		get exponent digits 210
	cmp.w	#$fff,d1
	bne.s	.notnan
; exponent of FFF means strange number - check mantisaa
	moveq	#$F,d1
	and.b	3(a1),d1
	or.l	4(a1),d1
	or.l	4(a1),d1
	bne.s	.notinf
	btst	#7,(a1)
	bsr.s	.sign
	move.b	#'ß',(a0)+
	clr.b	(a0)
	rts
.notinf	tst.b	4(a1)
	bne.s	.nan
	move.b	#'S',(a0)+
.nan	move.l	#'NAN'<<8,(a0)		numm termed, don't care if odd
	add.w	#3*4,sp
	rts

.notnan	btst	#7,(a1)
	bsr.s	.sign
; get mantissa
	bfextu	2(a1){12:4},d1		first digit
	add.b	d2,d1
	move.b	d1,(a0)+
	move.b	#'.',(a0)+
	move.l	4(a1),d1		some more digits
	bsr.s	.digits
	move.l	8(a1),d1
	bsr.s	.digits
; put exponent in
	bfextu	(a1){4:12},d1		get exponent digits 210
	bfextu	2(a1){0:4},d0		exponent digits 3
	bfins	d0,d1{16:4}		get full exponent into d1
	move.b	#'E',(a0)+
	btst	#6,(a1)
	bsr.s	.sign
	moveq	#4-1,d3
	swap	d1
	bsr.s	.dloop			do exponent
	clr.b	(a0)
	add.w	#3*4,sp
	rts
.digits	moveq	#8-1,d3			digit counter
.dloop	rol.l	#4,d1
	moveq	#$f,d0
	and.l	d1,d0
	add.b	d2,d0
	move.b	d0,(a0)+
	dbf	d3,.dloop
	rts
.sign	sne	d0
	and.b	#'-'-'+',d0
	add.b	#'+',d0
	move.b	d0,(a0)+
	rts
	
	opt	p=68000
	
	IFNE	DEMO
	
* the demo version contains a complete built-in .ttp file, amongst others

* long get_demo_long(long what)
* what: 0=source start, 1=source len
* 2 = help
* 4 = startup
* -1 = start of prog

	xdef	_get_demo_long
_get_demo_long
	move.l	4(sp),d0
	addq.l	#1,d0
	add.l	d0,d0
	add.l	d0,d0
	lea	demo_lookup,a0
	add.l	d0,a0
	move.l	(a0),d0
	rts

	
* long debug_offset(void)

	xdef	_debug_offset
	xref	___start
	
_debug_offset
	lea	demo_data-$1000,a0
	sub.l	#___start-$1000-$1c,a0
	move.l	a0,d0
	rts

* this version 'loads' a program by making a bp and bunging the data into it

_load_exec	PROC
	cargs	#8,.prog.l,.cmd.l,.startptr.l

	pea	-1.w
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	cmp.l	#4096,d0
	bcc.s	.memok
	moveq	#ERRM_NOSYSMEM,d0
	bra	.xexec
.memok	BEFOREEXEC
* lets make a basepage
	clr.l	-(sp)			simple env
	move.l	sp,-(sp)		null cmd line
	clr.l	-(sp)			no progname
	move.w	#5,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp
	tst.l	d0
	bmi	.doserr			if failed
	
* copy the program into it
	move.l	d0,a5			a5 = basepage
	
	AFTEREXEC
	
	lea	demo_data,a3		a3 = program image
	move.l	2(a3),d0		text size
	add.l	6(a3),d0		+ data size
	lea	$1c(a3),a0		source
	lea	$100(a5),a1		dest
	addq.l	#3,d0
	lsr.l	#2,d0			convert size into longwords
.copy	move.l	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	.copy			copy text & data segments
	
	lea	$100(a5),a0		prog start addr
	add.l	2(a3),a0		+tlen
	add.l	6(a3),a0		+dlen, a0 pts to BSS
	move.l	$a(a3),d0
	beq.s	.nobss
	moveq	#0,d1
.clrbss	move.b	d1,(a0)+		zero minimal BSS
	subq.l	#1,d0
	bne.s	.clrbss
.nobss

* now relocate it
	lea	$1c(a3),a1
	add.l	2(a3),a1
	add.l	6(a3),a1
	add.l	$e(a3),a1		a0=start of reloc area
* this code based on Pexec cookbook p 19
	tst.l	(a1)
	beq.s	.noreloc
	moveq	#0,d0
	lea	$100(a5),a0		a1=program area
	move.l	a0,d1			d1=relocation base
	add.l	(a1)+,a0		a0=addr of first fixup
.2	add.l	d1,(a0)
.4	move.b	(a1)+,d0
	beq.s	.noreloc		on end byte
	cmp.b	#1,d0
	beq.s	.3
	add.w	d0,a0
	bra.s	.2	
.3	add.w	#254,a0
	bra.s	.4
	
.noreloc	
* fixup the bp fields
	lea	$100(a5),a0
	lea	8(a5),a1
	move.l	a0,(a1)+		tstart
	move.l	a0,_st_text(a4)
	move.l	.startptr(a6),a2
	move.l	a0,(a2)
	move.l	2(a3),(a1)+		tlen
	add.l	2(a3),a0
	move.l	a0,(a1)+		dstart
	move.l	a0,_st_data(a4)
	move.l	6(a3),(a1)+		dlen
	add.l	6(a3),a0
	move.l	a0,(a1)+		bstart
	move.l	a0,_st_bss(a4)
	move.l	$a(a3),(a1)+		blen
	add.l	$a(a3),a0
	move.l	a0,_st_end(a4)

	move.l	a5,_progbp(a4)

	moveq	#0,d0
	move.l	d0,_program_timer(a4)
.xexec	ENDPROC
	
.doserr	move.l	d0,-(sp)
	AFTEREXEC
	jsr	_remember_doserr
	addq.l	#4,sp			returns suitable d0
	bra.s	.xexec

	SECTION	DATA,DATA
demo_data	incbin	tutorial\vowels.ttp
	dc.l	0			so read_dbfile stops before EOF

source_start	incbin	tutorial\vowels.c
source_end
	dc.b	0			so demo_read_line stops

help_start	incbin	help.xdb
help_end	dc.b	13,10,0		so fgets stops

var_start	incbin	release\startup.xdb
var_end		dc.b	13,10,0		so fgets stops

demo_lookup	dc.l	___start-$1c
		dc.l	source_start
		dc.l	source_end-source_start
		dc.l	help_start
		dc.l	help_end-help_start
		dc.l	var_start
		dc.l	var_end-var_start

	ENDC


* for the moment
	section	DATA,DATA

trapbuffer	illegal				replaced with trap
		nop
		nop				it hits here
endbuffer	even


trap_table	dc.l	my_dos
		dc.w	32+1
		dc.l	my_bios
		dc.w	32+13
		dc.l	my_xbios
		dc.w	32+14
		dc.l	0

	
	section	__MERGED,BSS
	xdef	_stop_dos,_program_timer

* these are referred to absolutely (plus progstate.b)
special_trace	ds.l	1
realpc		ds.l	1

myfpustate	ds.b	$b8		68882 is largest

old_timer	ds.l	1
old_502		ds.l	1
_program_timer	ds.l	1

last_dcr	ds.l	1
last_trace	ds.l	1
last_addr	ds.l	1
last_sr		ds.w	1
temp_psr	ds.w	1
saved_psr	ds.w	1

stop_me		ds.b	1		countdown timer
havekept	ds.b	1		NE for kept mem alloc
stop_read	ds.b	1		NE for stop on read

last_1c		ds.l	1

saved2a2	ds.l	2

* this MUST be here and initialised during startup
	xdef	_illegal_op
_illegal_op	ds.w	1

old_savptr	ds.l	1
	IFD	OLDMEM
oldmax		ds.l	1		real value of __maxblk
	ENDC
io_rec		ds.l	1
savesp		ds.l	1
oldmonusp	ds.l	1
oldmonssp	ds.l	3
_progbp		ds.l	1		ptr to prog basepage
		ds.l	16		allow for slight errors
minssp		ds.l	4000		main program stack area
monssp		ds.l	3
		ds.l	100		only for Exec call
execssp		ds.l	3
oldextable	ds.l	MAXEX

* keep these together
		ds.w	23*2
my_savptr	ds.w	1

