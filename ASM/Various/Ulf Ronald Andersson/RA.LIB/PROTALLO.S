;----------------------------------------------------------------------------
;File name:	PROTALLO.S		Revision date:	1998.08.14
;Created by:	Ulf Ronald Andersson	Creation date:	1992.02.03
;----------------------------------------------------------------------------
;should be included in TEXT section of program,
;somewhere behind the entry routines.
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	ifnd	PROTALLO_defined
PROTALLO_defined	set	1
;----------------------------------------------------------------------------
	include	RA_TOS.I
	include	RA_JAR.I
	include	FIND_MPB.S
;----------------------------------------------------------------------------
		rsreset
prot_ramloss	rs.l	1
prot_movedist	rs.l	1
prot_movesize	rs.l	1
prot_mpb	rs.l	1
prot_struct_size	rs.b	0
;----------------------------------------------------------------------------
; void	*protallo(int KB_size)	;uses d0-d2/a0-a2
;
protallo:
	link	a6,#-18
	movem.l	a4,-(sp)
	eval_cookie	#'MagX'
	move.l	d0,MagX_p
	spl	MagX_f
	lea	prot_struct,a4
	clr.l	d0
	move	8(a6),d0		;d0 = KB_size
	add.l	prot_ramloss(a4),d0
	swap	d0			;d0 = (size_INF + prot_ramloss) * 65536
	lsr.l	#6,d0			;d0 = (size_INF + prot_ramloss) * 1024
	add.l	#$1FE,d0		;add $1FE to allow screen basing
	move.l	d0,-10(a6)		;RAM_need= d0
	and	#-$200,d0		;ensures screen at 512_byte multiple
	move.l	d0,prot_movedist(a4)
	gemdos	Malloc,?	;d0= Malloc(-1)
	move.l	d0,-6(a6)		;Free_RAM= d0
	sub.l	-10(a6),d0		;d0= Free_RAM - RAM_need
	tst	MagX_f
	beq.s	.done_header
	sub.l	#16,d0			;shrink d0 a bit for MagiX headers
.done_header:
	gemdos	Malloc,d0	;d0= Malloc(Free_RAM - RAM_need)
	move.l	d0,-14(a6)		;store void *UNwantedp
	ble.s	.prot_failed
	gemdos	Malloc,-10(a6)	;d0= Malloc(RAM_need)
	move.l	d0,-18(a6)		;store void *WANTED_RAM_p
	gemdos	Mfree|_IND,-14(a6)	;Mfree(UNwantedp)
	move.l	-18(a6),d0		;d0 = WANTED_RAM_p
	ble.s	.prot_failed
	add.l	-10(a6),d0		;d0 = WANTED_RAM_p + RAM_need
	cmp.l	(_memtop).w,d0
	bne.s	.prot_fail_release
;
	tst	MagX_f
	bne.s	.MagX_mcb_found
	move.l	-10(a6),-(sp)		;push RAM_need
	move.l	-18(a6),-(sp)		;push WANTED_RAM_p
	bsr	find_mpb		;find_mpb(WANTED_RAM_p, RAM_need)
	addq	#8,sp
	tst.l	d0			;MPB calculated ok ?
	bgt.s	.TOS_mpb_found		;if so, go use it...!
.prot_fail_release:
	gemdos	Mfree|_IND,-18(a6)
.prot_failed:
	clr.l	d0			;NULL return pointer flags failure
	bra	.exit_prot
;
.MagX_mcb_found:
	move.l	-18(a6),a2
	lea	-16(a2),a2		;a2 -> mcb of WANTED_RAM_p
	cmp.l	#'KROM',(a2)+		;test and => a2 -> size long in mcb
	bne.s	.prot_failed		;exit on error
	bra.s	.adjust_locations
;
.TOS_mpb_found:
	move.l	a0,prot_mpb(a4)
	move.l	a0,a2		;a2-> MPB root vector group
	move.l	4(a2),a2		;a2-> MPB of *WANTED_RAM_p
	lea	8(a2),a2		;a2-> size long in MPB of WANTED_RAM_p
.adjust_locations:
	move.l	(phystop).w,d0
	sub.l	(_memtop).w,d0
	and	#-2,d0
	move.l	d0,prot_movesize(a4)
	move.l	(_memtop).w,a0		;a0->old _memtop for data destination
	move.l	a0,a1
	move.l	prot_movedist(a4),d0
	sub.l	d0,a1			;a1->new _memtop for data source
	sub.l	d0,(a2)		;shrink MPB, so we can lock up properly!!! 
	move.l	prot_movesize(a4),d0
	move	d0,d1
	lsr.l	#7,d0			;move as halfpages for speed
	lsr	#1,d1			;move 2 data words per routine word
	and	#$1E,d1			;move halfpage remnant on first entry
	neg	d1			;use negative offset
	pea	.move_ref(pc,d1)	;push entry address
	rts				;enter loop
;
.screen_lp1:				;Loop 1 start
	rept	32
	move.l	(a0)+,(a1)+		;move 128 bytes per loop
	endr
.move_ref:
	dbra	d0,.screen_lp1		;loop back
;
	move.l	(_v_bas_ad).w,d0
	cmp.l	(_memtop).w,d0
	blo.s	.keep_screen
	cmp.l	(phystop).w,d0
	bhs.s	.keep_screen
	sub.l	prot_movedist(a4),d0
	move.l	d0,(screenpt).w
	xbios	Vsync
	clr.l	(screenpt).w
.keep_screen:
	move.l	prot_movedist(a4),d0
	sub.l	d0,(_memtop).w		;lower _memtop
	sub.l	d0,(phystop).w		;lower _phystop  (new area protected!)
	gemdos	Mfree|_IND,-18(a6)	;release unused part of MPB/mcb
	move.l	(phystop).w,d0
.exit_prot:
	movem.l	(sp)+,a4
	unlk	a6
	rts			;return d0= headptr  prot_movedist= prot area size
;----------------------------------------------------------------------------
	make	JAR_links
;----------------------------------------------------------------------------
	_unilab	MagX_p
	IFNE	_uni_flag
	dc.l	0
	ENDC
	_unilab	MagX_f
	IFNE	_uni_flag
	dc.w	0
	ENDC
;----------------------------------------------------------------------------
prot_struct:	ds.b	prot_struct_size
	even
;----------------------------------------------------------------------------
	endc	;PROTALLO_defined
;----------------------------------------------------------------------------
;	end of file:	PROTALLO.S
;----------------------------------------------------------------------------
