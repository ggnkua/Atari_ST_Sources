;----------------------------------------------------------------------------
;File name:	CHKMAPFM.S			Revision date:	1999.03.23
;Created by:	Ulf Ronald Andersson		Creation date:	1999.03.20
;----------------------------------------------------------------------------
	output	.BIN
;----------------------------------------------------------------------------
	include	RA_TOS.I
	include	RA_XB.I
	include	bs_comp\TRACER.I
	include	CT2BUS.I
;----------------------------------------------------------------------------
trace_mode	set	0
;----------------------------------------------------------------------------
	TEXT
;----------------------------------------------------------------------------
	struct	ckt
	long	ckt_name;
	long	ckt_value
	d_end	ckt
;----------------------------------------------------------------------------
fix_ram:
	move.l	a0,-(sp)		;push entry a0 to stack
	lea	booter_regs(pc),a0	;a0 -> save area
	movem.l	d0-d7/a0-a6,(a0)	;save most entry regs (not a0/a7)
	move.l	(sp)+,8*4(a0)		;save entry a0, popping from stack
	move.l	sp,15*4(a0)		;save entry a7  (stack pointer)
;
	lea	loc_stk_top(pc),sp	;sp -> loc_stk_top
	lea	map_beg(pc),a5		;-> local  map_beg
	lea	old_TC(pc),a4		;a4 -> old_TC, base of reg table
	moveq	#-1,d4			;set d4 as 'map unchanged' flag
;
	jsr	fix_cookies		;read relevant cookies from sustem
	cmp.l	#$00030000,ckt_value+cookie_MCH-map_beg(a5)	;Falcon machine ?
	bne.s	done_mapping					;else skip remapping
	cmp.l	#30,ckt_value+cookie_CPU-map_beg(a5)		;68030 CPU installed ?
	bne.s	done_mapping					;else skip remapping
;
	pmove.l	tc,0(a4)			;store old_TC
	pmove.l	tt0,4(a4)			;store old_TT0
	pmove.l	tt1,8(a4)			;store old_TT1
	pmove.d	crp,12(a4)			;store old_CRP
	pmove.d	srp,20(a4)			;store old_SRP
;
	jsr	fix_tables		;adapt PMMU tables to boot mode
;
	tst	booter_regs-map_beg(a5)		;test d0 from mapper entry
	bmi.s	done_mapping			;leave PMMU unchanged for query
	pmove.l	TC_passive-map_beg(a5),tc	;disable TC translation
	pmove.l	TT0_active-map_beg(a5),tt0	;set TT0
	pmove.l	TT1_active-map_beg(a5),tt1	;set TT1
	pmove.d	CRP_fixval-map_beg(a5),srp	;setup new SRP  (but not used)
	pmove.d	CRP_fixval-map_beg(a5),crp	;setup new CRP
	pmove.l	TC_active-map_beg(a5),tc	;activate new TC
	clr.l	d4				;clear d4 as 'map unchanged' flag
done_mapping:
	move.l	a4,d0				;store -> old_TC as exit d0
	move.l	d4,d1				;store 'map unchanged' flag as exit d1
	movem.l	2*4+booter_regs(pc),d2-d7/a0-a7	;restore most regs, keep results in d0,d1
	rts
;----------------------------------------------------------------------------
booter_regs:
	ds.l	16
;----------------------------------------------------------------------------
	trace_CODE
;----------------------------------------------------------------------------
fix_cookies:
	lea	ckt_array(pc),a1
set_cookies_loop:
	movem.l	(a1)+,d0-d1
	tst.l	d0
	ble.s	done_cookies
;
	lea	(_cookies).w,a0

	beq.s	.done_cookie
	move.l	(a0),a0
.cookie_loop:
	tst.l	(a0)
	beq.s	.done_cookie
	cmp.l	(a0),d0
	beq.s	.found
	addq	#8,a0
	bra.s	.cookie_loop
;
.found:
	lea	-sizeof_ckt(a1),a3		;a3 -> ckt struct in local array
	sub.l	a5,a3				;a3 = dist from map_beg to ckt
	move.l	ckt_value(a0),ckt_value(a5,a3)	;store new cookie locally
.done_cookie:
	bra.s	set_cookies_loop
;
done_cookies:
	rts
;----------------------------------------------------------------------------
fix_tables:
	moveq	#-1,d3			;d3 = flag for remapping refusal, in case of errors
	tst	booter_regs-map_beg(a5)	;test if caller wants remapping, or just a query
	bmi.s	done_tables		;if not remapping, ignore tables
	lea	old_TC(pc),a0
	lea	TC_active(pc),a1
	cmpm.l	(a0)+,(a1)+		;check TC
	bne.s	done_tables
	cmpm.l	(a0)+,(a1)+		;check TT0
	bne.s	done_tables
	cmpm.l	(a0)+,(a1)+		;check TT1
	bne.s	done_tables
	move.l	(a0)+,d0		;d0 = old CRP first long
	move.l	(a1)+,d1		;d1 = planned CRP first long
	eor.l	d1,d0			;d0 = diffs of CRP first long
	and.l	#$FFFF0003,d0		;d0 = relevant diffs of CRP first long
	bne.s	done_tables
	move.l	(a0)+,a0		;a0 -> old CRP map base
	cmp.l	#$1000,a0		;too low ?
	blo.s	done_tables
	cmp.l	#$00E00000,a0		;too high ?
	bhs.s	done_tables
	lea	-sizeof_TOSBUS(a0),a0	;a0 -> potential TOSBUS id structure
	move.l	a0,a2			;a2 -> potential TOSBUS id structure
	lea	my_TOSBUS(pc),a1
	cmpm.l	(a0)+,(a1)+		;check first id long
	bne.s	done_tables
	cmpm.l	(a0)+,(a1)+		;check second id long
	bne.s	done_tables		;if everything matches, this is a restore
have_restore:
	moveq	#1,d3			;d3 = 1 to flag map remapping
	move.l	a2,a0			;a0 -> found TOSBUS id structure
	lea	my_TOSBUS(pc),a1	;a1 -> local TOSBUS id structure
	moveq	#sizeof_TOSBUS-1,d0	;prep to copy TOSBUS id data
.loop:
	move.b	(a0)+,(a1)+		;copy TOSBUS id data
	dbra	d0,.loop		;loop back for all data
done_tables:
	move.l	d3,booter_regs-map_beg(a5)	;store flag for later test
	rts
;----------------------------------------------------------------------------
map_beg:
;----------------------------------------------------------------------------
my_TOSBUS:
	def_TOSBUS
;----------------------------------------------------------------------------
PMMU_map:	;This is just a dummy to keep the def_TOSBUS macro happy
;-------
TC_passive:	dc.l	0			;passive value for tc
;-------
old_TC:		dc.l	0
old_TT0:	dc.l	0
old_TT1:	dc.l	0
old_CRP:	dc.l	0,0
old_SRP:	dc.l	0,0
TT_mask_p:	dc.l	0
;----------------------------------------------------------------------------
def_cookie	MACRO	name,valid,value,iz_f,iz_v
cookie\1:
	dc.l	'\1',\2
	ENDM	;def_cookie
;
ckt_array:
	def_cookie	_CPU,$0000001E
	def_cookie	_MCH,$00010000
	dc.l	-1
;
	EVEN
map_end:
;----------------------------------------------------------------------------
loc_stack:
loc_stk_top	=	loc_stack+$1000
;----------------------------------------------------------------------------
code_end:
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	CHKMAPFM.S
;----------------------------------------------------------------------------
