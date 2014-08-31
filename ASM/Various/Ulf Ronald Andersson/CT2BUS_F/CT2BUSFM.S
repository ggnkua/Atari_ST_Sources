;----------------------------------------------------------------------------
;File name:	CT2BUSFM.S			Revision date:	1999.05.17
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
	move.l	a4,a0
	lea	my_CT2BUS+CT2BUS_TC(pc),a1
	move.l	(a0)+,(a1)+			;save old TC
	move.l	(a0)+,(a1)+			;save old TT0
	move.l	(a0)+,(a1)+			;save old TT1
	move.l	(a0)+,(a1)+			;save old CRP first long
	and	#$0003,-2(a1)
	move.l	(a0)+,(a1)+			;save old CRP map base
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
	bne.s	check_TOS
	cmpm.l	(a0)+,(a1)+		;check TT0
	bne.s	check_TOS
	cmpm.l	(a0)+,(a1)+		;check TT1
	bne.s	check_TOS
	move.l	(a0)+,d0		;d0 = old CRP first long
	move.l	(a1)+,d1		;d1 = planned CRP first long
	eor.l	d1,d0			;d0 = diffs of CRP first long
	and.l	#$FFFF0003,d0		;d0 = relevant diffs of CRP first long
	bne.s	check_TOS
	move.l	(a0)+,a0		;a0 -> old CRP map base
	cmp.l	#$1000,a0		;too low ?
	blo.s	check_TOS
	cmp.l	#$00E00000,a0		;too high ?
	bhs.s	check_TOS
	lea	-sizeof_CT2BUS(a0),a0	;a0 -> potential CT2BUS id structure
	lea	my_CT2BUS(pc),a1
	cmpm.l	(a0)+,(a1)+		;check first id long
	bne.s	check_TOS
	cmpm.l	(a0)+,(a1)+		;check second id long
	beq.s	done_tables		;if everything matches, this is just a rerun...
check_TOS:
	cmp.l	#$1357BD13,(ramvalid).w	;is TT_RAM valid as per 'ramtop' ?
	bne.s	not_TOS_7		;if not, go assume another boot mode
	move.l	(ramtop),d0		;d0 = ramtop -> end of TT_RAM available to GEMDOS
	cmp.l	#$01000000,d0		;compare against TT_RAM base address
	ble.s	not_TOS_7		;if invalid, go assume another boot mode
	move.l	d0,a0			;a0 = d0 -> end of TT_RAM available to GEMDOS
	and.l	#$FFFFFF,d0		;d0 = masked to 3 byte offset within 16 MB block
	cmp.l	#$F7A000,d0		;does this match standard TOS 7.x TT_RAM limit
	bne.s	done_tables		;if not, things are weird, so avoid remapping
	move.l	a0,TT_mask_p		;store TT_mask_p -> TT_RAM address to mask (TOS + initial PMMU map)
have_TOS_7:
	moveq	#2,d3			;d3 = 2 for TOS 7 mode
	bsr.s	map_TOS_7_sub
	bra.s	done_tables		;ok, all is ready for TOS 7 mapping...
;
not_TOS_7:
have_TOS_4:
	moveq	#1,d3			;d3 = 1 for TOS 4.x or compatibility mode
	bsr.s	map_TOS_4_sub
done_tables:
	move.l	d3,booter_regs-map_beg(a5)	;store flag for later test
	rts
;----------------------------------------------------------------------------
map_TOS_4_sub:
	lea	non_24bit_t(pc),a0
	lea	($01<<24).l,a1
	bsr.s	fix_pd_table
	lea	TTST_t(pc),a0
	lea	(NULL).w,a1
	bsr.s	fix_pd_table
	rts
;----------------------------------------------------------------------------
map_TOS_7_sub:
	bsr	map_TOS_4_sub		;start from TOS 4 mapping
;-------
	move.l	TT_mask_p,a0		;a0 -> TT_RAM address to mask (TOS + initial PMMU map)
	move.l	a0,d0			;d0 = $xxF7A000
	and.l	#$FF000000,d0		;d0 = $xx000000
	rol.l	#8,d0			;d0 = $000000xx 16MB bank number of last valid TT_RAM bank
	move	d0,TT_mask_bkn
;-------
	lea	PMMU_map+4(pc),a1	;a1 -> td of first TT-RAM bank
	subq	#1,d0			;d0 = $xx-1  number of TT-RAM banks before the last one
	beq.s	.init_TT_mask
	subq	#1,d0			;d0 = prep for dbra
	move.l	#$04000001,d1		;d1 = pd of 1st TT-RAM bank
	move.l	#$01000000,d2		;d2 = pd step for 16MB block
.init_valid_TT_RAM:
	move.l	d1,(a1)+
	add.l	d2,d1
	dbra	d0,.init_valid_TT_RAM
.init_TT_mask:
	lea	TT_xx_RAM_map+3,a0	;a0 = td for secondary map of last TT_RAM bank
	move.l	a0,(a1)+
	moveq	#127,d0
	sub	TT_mask_bkn(pc),d0
	ble.s	.done_main_TT_RAM
	subq	#1,d0			;prep for dbra
.init_invalid_TT_RAM:
	clr.l	(a1)+			;store invalid page descriptors for absent RAM
	dbra	d0,.init_invalid_TT_RAM
.done_main_TT_RAM:
;-------
	lea	TT_xx_RAM_t(pc),a0	;a0 -> fixup table for secondary map of last TT-RAM bank
	move.l	TT_mask_p(pc),d0	;d0 = TT_mask_p
	and.l	#($7F<<24),d0		;d0 = $xx000000, base of last TT-RAM block (masked at end)
	move.l	d0,a1			;a1 -> base of last TT-RAM 16MB bank
	bsr.s	fix_pd_table		;fixup last TT_RAM map via table
;-------
	lea	TOS_RAM_t(pc),a0	;a0 -> fixup table for secondary map of TOS RAM
	move.l	TT_mask_p(pc),a1	;a1 -> masked TT_RAM area, where TOS is stored (logical adr)
	add.l	#$03000000,a1		;a1 =  physical base of CT2B TT_RAM holding TOS
	bsr.s	fix_pd_table		;fixup TOS_RAM map via table
;-------
	rts				;return to caller
;----------------------------------------------------------------------------
fix_pd_table:
	movem.l	d0-d4/a0-a2,-(sp)	;push entry registers
	move.l	(a0)+,d0		;d0 = td_type
	cmp	#3,d0			;td_type for long descriptors ?
	beq.s	fix_long_pd_table
fix_short_pd_table:
	move.l	(a0)+,a2		;a2 -> PMMU map
	move.l	(a0)+,d2		;d2 = pd physical address step
.loop_1:
	move.l	(a0)+,d4		;d4 = number of entries in patch block
	beq.s	done_pd_table
	subq.l	#1,d4			;d4 = prep for dbra
	move.l	(a0)+,d3		;d3 = physical offset of patch
.loop_2:
	move.l	a1,d0			;d0 = raw physical address
	add.l	d3,d0			;d0 = adjusted physical address
	move.l	d0,(a2)+		;store pd physical address (with status bits)
	add.l	d2,a1			;step physical address
	dbra	d4,.loop_2		;loop back for more
	sub.l	#$10000,d4		;more to patch by long count ?
	bpl.s	.loop_2			;loop back for all left to patch
	bra.s	.loop_1			;loop back for more patch blocks
;-------
fix_long_pd_table:
	move.l	(a0)+,a2		;a2 -> PMMU map
	move.l	(a0)+,d2		;d2 = pd physical address step
.loop_1:
	move.l	(a0)+,d4		;d4 = number of entries in patch block
	beq.s	done_pd_table
	subq.l	#1,d4			;d4 = prep for dbra
	move.l	(a0)+,d1		;d1 = status long of patch
	move.l	(a0)+,d3		;d3 = physical offset of patch
.loop_2:
	move.l	d1,(a2)+		;store pd status long
	move.l	a1,d0			;d0 = raw physical address
	add.l	d3,d0			;d0 = adjusted physical address
	move.l	d0,(a2)+		;store pd physical address
	add.l	d2,a1			;step physical address
	dbra	d4,.loop_2		;loop back for more
	sub.l	#$10000,d4		;more to patch by long count ?
	bpl.s	.loop_2			;loop back for all left to patch
	bra.s	.loop_1			;loop back for more patch blocks
;-------
done_pd_table:
	movem.l	(sp)+,d0-d4/a0-a2	;pull entry registers
	rts				;return to caller
;----------------------------------------------------------------------------
non_24bit_t:
	dc.l	2,non_24bit_map,1<<24		;td_type, map_base, step_size
	dc.l	127,$01				;normal TT_RAM     $01xxxxxx..$7Fxxxxxx
	dc.l	127,$41				;uncached extra_IO $80xxxxxx..$FExxxxxx
	dc.l	0
;-------
TTST_t:
	dc.l	3,TTST_map,1<<11				;td_type, map_base, step_size
	dc.l	($000800-$000000)>>11,$8000FD01,0		;supervisor SYS_VAR
	dc.l	($E00000-$000800)>>11,$8000FC01,0		;normal ST_RAM
	dc.l	($F00000-$E00000)>>11,$8000FC05,0		;readonly TOS_ROM
	dc.l	($FA0000-$F00000)>>11,$8000FD41,$FF<<24		;supervisor uncached reserved_IO
	dc.l	($FC0000-$FA0000)>>11,$8000FC45,0		;uncached readonly cartROM
	dc.l	($FF0000-$FC0000)>>11,$8000FC05,0		;readonly old_ROM
	dc.l	($1000000-$FF0000)>>11,$8000FD41,$FF<<24	;supervisor uncached TTST_IO
	dc.l	0
;-------
TT_xx_RAM_t:
	dc.l	3,TT_xx_RAM_map,1<<11			;td_type, map_base, step_size
	dc.l	($F7A000-$000000)>>11,$8000FC01,0	;  validate $xx000000-$xxF79FFF
	dc.l	($FFA000-$F7A000)>>11,$8000FC05,0	;  readonly $xxF7A000-$xxFF9FFF
	dc.l	($1000000-$FFA000)>>11,0,0		;invalidate $xxFFA000-$xxFFffFF
	dc.l	0
;-------
TOS_RAM_t:
	dc.l	3,TTST_map+($E00000>>11)*8,1<<11
	dc.l	($E80000-$E00000)>>11,$8000FC01,0	;readonly TOS_RAM
	dc.l	0
;-------
TC_passive:	dc.l	0			;passive value for tc
;-------
old_TC:		dc.l	0
old_TT0:	dc.l	0
old_TT1:	dc.l	0
old_CRP:	dc.l	0,0
old_SRP:	dc.l	0,0
TT_mask_p:	dc.l	0
TT_mask_bkn:	dc.w	0
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
;----------------------------------------------------------------------------
loc_stack:
	ds.b	8192
loc_stk_top:
;----------------------------------------------------------------------------
mapres_base:
mapres_offs = ((mapres_base-fix_ram)&$FF)
mapres_pads = (($100-mapres_offs)&$FF)
	ds.b	mapres_pads
map_beg:			;This label is at a page boundary
;----------------------------------------------------------------------------
	ds.b	$100-sizeof_CT2BUS
my_CT2BUS:
	def_CT2BUS
;----------------------------------------------------------------------------
PMMU_map:
	dc.l	TTST_map+3			;mapped TTST block $00xxxxxx
non_24bit_map:
	ds.l	254				;TT_RAM & extra_IO $01xxxxxx..$FExxxxxx
	dc.l	TTST_map+3			;mapped TTST block $FFxxxxxx
;-------
TTST_map:	ds.b	(((16*Mb)>>11)*8)
TT_xx_RAM_map:	ds.b	(((16*Mb)>>11)*8)
;----------------------------------------------------------------------------
code_end:
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	CT2BUSFM.S
;----------------------------------------------------------------------------
