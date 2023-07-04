	opt	alink,lattice

* TT-specific MMU support code
* BEWARE: done using AMP assembler, so Pxxx liable to be broken

	IFEQ	__G2>42
	FAIL	this assembler cant do MMUs
	ENDC

	include	mon.i


OTHER_TT0	equ	$027D8107

	xdef	_asm_mmu_init,_asm_mmu_reset

	xref	_realproc,check_rw_long,_malloc
	xref	_machtype,_regs

ALIGN	macro	dreg,what
	add.l	#\2,\1
	and.b	#~(\2-1),\1
	endm

* ALL CALLS REQUIRE SUPERVISOR MODE!!!!!!!!
	opt	p=68030

PAGESIZE	macro	dreg,scratch
	subq.w	#4,sp
	pmove.l	tc,(sp)
	move.l	(sp)+,\2
*	bpl	.nommumap
	swap	\2
	lsr.w	#20-16,\2
	and.w	#%111,\2		page size bits
	move.l	#256,\1
	lsl.l	\2,\1
	endm
	
* before these are called, the caller has checked that the MMU
* can cope with what is about to be asked
* using this call:

; if MMU is recognised and allowed format return 1, else return 0
; requires supervisor mode
	xdef	_test_mmu
_test_mmu
	subq.w	#8,sp
	moveq	#0,d0
	cmp.w	#30,_realproc(a4)
	bne.s	.ret
	pmove.l	tc,(sp)
	move.l	(sp),d1
	bpl.s	.ret			if disabled
* we can only cope with the standard TT configuration
	cmp.l	#$80f04445,d1
	bne.s	.ret
	pmove.l	tt0,(sp)
	cmp.l	#$017e8107,(sp)
	beq.s	.tt0ok
	cmp.l	#OTHER_TT0,(sp)
	bne.s	.ret
.tt0ok	pmove.l	tt1,(sp)
	cmp.l	#$807e8507,(sp)
	bne.s	.ret
	pmove.d	crp,(sp)
	cmp.l	#$80000002,(sp)
	bne.s	.ret
* we dont check the table address of the CRP cos we dont care
* we dont check the SRP cos it must be disabled
	moveq	#1,d0			return TRUE
.ret	addq.w	#8,sp
	rts

* type word: 0=all, 1=ST, 2=TT RAM
	xref	_undo_mmlist,_undo_count

_asm_mmu_init
	PROC
	cargs	#8,.type.l,.remember.l,.count.l
	move.l	.type(a6),d1		the type
	bne.s	.notz
	moveq	#3,d1			all means TT+ST
.notz	btst	#0,d1
	beq.s	.nost
* ST RAM is from 0M to 8M in steps of 1M
	sub.l	a0,a0			start from 0
	move.l	#$00100000-1,a1
	move.l	.remember(a6),a2
.addst	moveq	#0,d0
	bsr	expand_ram
	bne	.exit			if failed
	move.l	a2,.remember(a6)
	move.l	.count(a6),a3
	addq.w	#1,(a3)
* try the next 1M block, if we can
	add.l	#$00100000,a0
	add.l	#$00100000,a1
	movem.l	d1/a0/a1,-(sp)
	jsr	check_rw_long
	movem.l	(sp)+,d1/a0/a1
	beq.s	.addst

.nost	btst	#1,d1
	beq	.nott

* TT RAM is higher and, by default, is only a level 2 table
	cmp.w	#2,_machtype(a4)
	bne	.nott
	move.l	#$01000000,a2
	move.l	a2,a0
	jsr	check_rw_long
	bne	.nott			if none at all
	ptestr	#0,(a2),#7,a1
	move.l	a1,d0
	beq	.exitnodcr
	pmove.w	psr,the_psr
	moveq	#%111,d0
	and.w	the_psr,d0
	subq.w	#2,d0
	bne	.exitwronglevel
	move.l	(a1),d0
	and.b	#%11110000,d0
	cmp.l	d0,a2
	bne	.exitvirtual
	move.l	a1,-(sp)		the DCR that needs patching
* we start by allocating a level 3 table
	pea	16*4+16.w
	jsr	_malloc
	addq.w	#4,sp
	move.l	(sp)+,a1
	tst.l	d0
	beq	.exitnoram
	ALIGN	d0,16
	move.l	d0,a0			the new table
	moveq	#%10,d1
	or.l	d0,d1			d1=new table entry
	moveq	#16-1,d0
.fill2	move.l	a2,(a0)
	or.l	#1,(a0)+
	add.l	#$00100000,a2
	dbf	d0,.fill2		build it
	move.l	.remember(a6),a2
	move.l	a1,(a2)+
	move.l	(a1),(a2)+
	move.l	a2,.remember(a6)
	move.l	.count(a6),a3
	addq.w	#1,(a3)
	move.l	d1,(a1)			set the new DCR
	pflusha
* now we can expand the level 3 table as required
	move.l	#$01000000,a0
	move.l	#$01100000-1,a1
	move.l	.remember(a6),a2
.addtt	moveq	#0,d0
	bsr	expand_ram
	bne	.exit			if failed
	move.l	a2,.remember(a6)
	move.l	.count(a6),a3
	addq.w	#1,(a3)
* try the next 1M block, if we can
	add.l	#$00100000,a0
	add.l	#$00100000,a1
	movem.l	a0/a1,-(sp)
	jsr	check_rw_long
	movem.l	(sp)+,a0/a1
	beq.s	.addtt

* we have to change TT0 else it transparently translates 01xx xxxx
	lea	old_tt0(a4),a0
	tst.l	(a0)
	bne.s	.gotold
	pmove.l	tt0,(a0)		save it in case we change it
.gotold	move.l	#OTHER_TT0,-(sp)	translate 02xx xxxx
	pmove.l	(sp),tt0
	move.l	(sp)+,_regs+REG_TT0(a4)	keep windows up-to-date

.nott	moveq	#0,d0
	bra.s	.exit
.exitnodcr
	moveq	#ERR_NODCR,d0
	bra.s	.exit
.exitwronglevel
	moveq	#ERR_BADLEVEL,d0
	bra.s	.exit
.exitnoram
	moveq	#ERR_NOMEMORY,d0
	bra.s	.exit
.exitvirtual
	moveq	#ERR_VIRTUAL,d0
.exit	ENDPROC

_asm_mmu_reset
	PROC
	cargs	#8,.remember.l,.count.l
	move.l	.count(a6),d0
	beq.s	.none
	move.l	.remember(a6),a0
.loop	move.l	-(a0),d1		old contents
	move.l	-(a0),a1
	move.l	d1,(a1)
	subq.w	#1,d0
	bne.s	.loop
.none	lea	old_tt0(a4),a0
	tst.l	(a0)
	beq.s	.nott0
	pmove.l	(a0),tt0
.nott0	pflusha
	moveq	#0,d0
	ENDPROC

* the caller must ensure that this is RAM; we check to see if it overlaps with Mon
	xdef	_asm_wprotect
_asm_wprotect
	PROC
	cargs	#8,.start.l,.end.l,.remember.l,.count.l
	PAGESIZE	d1,d0

	move.l	.start(a6),a0
	bsr	check_not_mon
	bne	.x			if overlaps
	move.l	.end(a6),a0
	bsr	check_not_mon
	bne	.x			if overlaps

	moveq	#0,d0			RSN proper FC bits

* check that its not in range of a TT register
	move.l	.start(a6),a0
	subq.w	#2,sp
	ptestw	d0,(a0),#0
	pmove.w	psr,(sp)
	move.w	(sp)+,d1
	btst	#6,d1
	bne	.not_tt

	move.l	.count(a6),a3
	move.l	.start(a6),a5
	
* must add to mem loop before adding to table
* must be added in correct place
	lea	_wplist(a4),a0
.gend	move.l	(a0)+,d2
	addq.w	#4,a0
	beq.s	.gotend
	cmp.l	a5,d2
	beq.s	.gotsame		if same addr then replace
	blt.s	.gend
	bra.s	.addwp			if needs insertion
.gotend	subq.w	#8,a0
	move.l	a5,(a0)+
	move.l	.end(a6),(a0)+
	clr.l	(a0)
	bra.s	.loop
.gotsame
	subq.w	#8,a0
	move.l	a5,(a0)+
	move.l	.end(a6),(a0)+
	bra.s	.loop
* make room then insert
.addwp	lea	-8(a0),a1		where its going to go
.fend	tst.l	(a0)+
	addq.w	#4,a0
	bne.s	.fend
	subq.w	#8,a0			points to null (which must be copied)
.mvback	cmp.l	a1,a0
	blt.s	.nomv
	move.l	(a0),8(a0)
	move.l	4(a0),8+4(a0)
	subq.w	#8,a0
	bra.s	.mvback
.nomv	move.l	a5,(a1)+
	move.l	.end(a6),(a1)+

.loop	ptestr	d0,(a5),#7,a1
	move.l	a1,d2
	beq.s	.nodcr
	btst	#2,3(a1)
	bne.s	.next			if already marked
	move.l	.remember(a6),a2
	move.l	a1,(a2)+
	move.l	(a1),(a2)+
	move.l	a2,.remember(a6)
	bset	#2,3(a1)		mark as WP
	addq.w	#1,(a3)
.next	add.l	d1,a5
	cmp.l	.end(a6),a5
	bcs.s	.loop			do whole range
	pflusha
	moveq	#0,d0
	bra.s	.x
.not_tt	moveq	#ERR_TTREG,d0
	bra.s	.x
.nodcr	moveq	#ERR_NODCR,d0
.x	ENDPROC

* we remove ourselves from the wplist - only remove from the DCR
* if no-one else in range
	xdef	_asm_wclear
_asm_wclear
	PROC
	cargs	#8,.start.l,.remember.l,.count.l

	move.l	.start(a6),a5
	lea	_wplist,a1
.findme	move.l	(a1)+,d0
	beq.s	.notfound
	addq.w	#4,a1
	cmp.l	d0,a5
	bne.s	.findme
* OK, found it. Kill from wplist, then check for overlaps
	move.l	-4(a1),a3			a3=end addr
	lea	-8(a1),a0			the empty slot
.back	move.l	(a1)+,(a0)+
	beq.s	.endwplist
	move.l	(a1)+,(a0)+
	bra.s	.back				do the list
.endwplist
* no sort required - still in order (Delete doesn't change it)

	PAGESIZE	d1,d0
* get the offending DCR: Note: assumes range doesnt span >2 DCRs
	moveq	#0,d0			RSN proper FC bits

	ptestr	d0,(a5),#7,a1
	move.l	a1,d2
	beq.s	.nodcr			d2=start DCR
	ptestr	d0,(a3),#7,a1
	move.l	a1,d3
	beq.s	.nodcr			d3=end DCR
* does anyone else in the wplist have a hold on this DCR?
	lea	_wplist,a0
.chkdcr	move.l	(a0)+,d1
	beq.s	.nohold
	move.l	d1,a1
	ptestr	d0,(a1),#7,a2
	cmp.l	a2,d2
	beq.s	.holddcr
	cmp.l	a2,d3
	beq.s	.holddcr
	addq.w	#4,a0
	bra.s	.chkdcr
.nohold	move.l	d2,a1
	bclr	#2,3(a1)
	move.l	d3,a1
	bclr	#2,3(a1)
	pflusha
* RSN tidy up remember list?
.holddcr
	moveq	#0,d0
	bra.s	.x
.nodcr	moveq	#ERR_NODCR,d0
	bra.s	.x
.notfound
	moveq	#ERR_BADP,d0
.x	ENDPROC

	xdef	expand_ram

* a0=start of block. a1=last byte of block, a2=remember area
* d0=FC typing required
* returns d0 with error code
* uses a2/d0 only
expand_ram
	movem.l	a0-a1/a3-a5/d1-d7,-(sp)
	move.l	a2,a5

	ptestr	d0,(a0),#7,a2
	ptestr	d0,(a1),#7,a3
	cmp.l	a2,a3
	bne	.diffdcr
	move.l	a2,d0
	beq	.nodcr
	pmove.w	psr,the_psr

	moveq	#%111,d0
	and.w	the_psr,d0
	cmp.w	#3,d0
	bne	.wronglevel
	move.l	(a2),d0
	clr.b	d0
	cmp.l	d0,a0
	bne	.virtual		if mapped differently
* get the page size
	subq.w	#4,sp
	pmove.l	tc,(sp)
	move.l	(sp)+,d1
	bpl	.nommumap
	swap	d1
	lsr.w	#20-16,d1
	and.w	#%111,d1		page size bits
	move.l	#256,d3
	lsl.l	d1,d3
* alloc the table
	movem.l	d1-d2/a0-a2,-(sp)
	move.l	#32*4+16,-(sp)		ASSUMES layout
	jsr	_malloc
	addq.w	#4,sp
	movem.l	(sp)+,d1-d2/a0-a2
	tst.l	d0
	beq	.nomemory
	ALIGN	d0,16
	move.l	d0,a3			the new table addr
	move.l	a3,-(sp)		save it
	moveq	#32-1,d0
.fill	move.l	a0,d1
	or.b	#1,d1			DT=%01=page descriptor
	move.l	d1,(a3)+
	add.l	d3,a0
	dbf	d0,.fill
	move.l	a2,(a5)+		remember ptr to DCR
	move.l	(a2),(a5)+		and its old contents
	moveq	#%10,d0
	or.l	(sp)+,d0
	move.l	d0,(a2)			set the new DCR
	pflusha
	moveq	#0,d0
.xx	move.l	a5,a2
	movem.l	(sp)+,a0-a1/a3-a5/d1-d7
	rts
.diffdcr	moveq	#ERR_DCRDIFF,d0
	bra.s	.xx
.nodcr	moveq	#ERR_NODCR,d0
	bra.s	.xx
.wronglevel
	moveq	#ERR_BADLEVEL,d0
	bra.s	.xx
.virtual	moveq	#ERR_VIRTUAL,d0
	bra.s	.xx
.nommumap	moveq	#ERR_NOMMU,d0
	bra.s	.xx
.nomemory
	moveq	#ERR_NOMEMORY,d0
	bra.s	.xx

* see if a0 lies within Mons workspace area, returns error if so
* workspace defined as start of Mons DATA to end_of_world
* d1.l=page size on entry
* also ensures level is OK
	xref	___start,_end_of_world
check_not_mon
	move.l	_end_of_world(a4),d0
	beq.s	.x
	ptestr	#0,(a0),#7,a2			a2=the input DCR
	move.l	a2,d0
	beq.s	.x				if no DCR (!)
	subq.w	#2,sp
	pmove.w	psr,(sp)
	moveq	#%111,d0
	and.w	(sp)+,d0
	subq.w	#4,d0
	bne.s	.wronglevel
	move.l	___start-$100+$10,a1		start of DATA
.check
	ptestr	#0,(a1),#7,a3
	cmp.l	a3,a2
	beq.s	.overlaps
	add.l	d1,a1				add page size
	cmp.l	_end_of_world(a4),a1
	blt.s	.check
	moveq	#0,d0
.x	rts
.overlaps
	moveq	#ERR_OVERLAPS,d0
	rts
.wronglevel
	moveq	#ERR_BADLEVEL,d0
	rts

* returns non-zero if address is RAM mapped and writable, else zero
* only works on MMU page boundaries

	xdef	_test_mmu_write
_test_mmu_write

	moveq	#0,d0
	
	cmp.w	#30,_realproc(a4)
	bne.s	.rts

	move.l	4(sp),a0		the address
	ptestw	d0,(a0),#7,a1

	subq.w	#2,sp
	pmove.w	psr,(sp)
	move.w	(sp)+,d1

	btst	#10,d1
	bne.s	.rts			if Invalid
	btst	#11,d1
	bne.s	.rts			if Write Protected

	cmp.l	a1,d0
	beq.s	.rts			if no mapping
	move.l	(a1),d1
	clr.b	d1
	move.l	a0,d0
	clr.b	d0
	cmp.l	d0,d1			address same?
	sne	d0			return non-zero if different i.e. RAM mapped
	ext.w	d0
.rts	rts
		
	xdef	_wplist

MAXWP	equ	10			RSN check this

	section	__MERGED,BSS
the_psr	ds.w	1
old_tt0	ds.l	1
_wplist	ds.l	2*MAXWP
