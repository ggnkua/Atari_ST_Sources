;----------------------------------------------------------------------------
;File name:	FAL_CART.S			Revision date:	1999.01.22
;Created by:	Ulf Ronald Andersson		Creation date:	1997.03.14
;----------------------------------------------------------------------------
	output	.BIN
;----------------------------------------------------------------------------
	include	RA_TOS.I
	include	RA_XB.I
	include	bs_comp\TRACER.I
;----------------------------------------------------------------------------
trace_mode	set	0
;----------------------------------------------------------------------------
;fix_ram is the place where B030 boots this LONGBOOT program
;----------------------------------------------------------------------------
INI_OFF	=	$40000	;offs to ident and init flags
BS_OFFS	=	$40010	;offs to boot sector pointer
IZF_OFF	=	$40014	;offs to initialization flags
MAP_OFF	=	$40400	;offs to translation tables etc
LIM_OFF	=	$7FF00	;phystop on coldboot must have higher offset
;----------------------------------------------------------------------------
	TEXT
;----------------------------------------------------------------------------
	struct	ckt
	long	ckt_name;
	long	ckt_invalid
	long	ckt_value
	long	ckt_iz_f
	long	ckt_iz_v
	d_end	ckt
;----------------------------------------------------------------------------
fix_ram:
	move.l	a0,-(sp)		;push entry a0 to stack
	lea	booter_regs(pc),a0	;a0 -> save area
	movem.l	d0-d7/a0-a6,(a0)	;save most entry regs (not a0/a7)
	move.l	(sp)+,8*4(a0)		;save entry a0, popping from stack
	move.l	sp,15*4(a0)		;save entry a7  (stack pointer)
;
	moveq	#$01,d3			;d3 = $00000001 \/ shorter code for
	ror.l	#8,d3			;d3 = $01000000 /\ move.l #$1000000,d3
fix_TT_RAM:
	cmpi.l	#$1357BD13,(ramvalid).w	;test TT RAM validity
	bne.s	done_TT_RAM		;done if TT RAM invalid
	cmp.l	(ramtop).w,d3		;test (TT_RAM_base - ramtop)
	bge.s	done_TT_RAM		;done OK if size undefined
	move.l	d3,(ramtop).w		;else lower ramtop to base
make_reset:
	move.l	(_sysbase).w,a0		;a0 -> OS header (may be a copy)
	move.l	os_selfbeg_p(a0),a0	;a0 -> Original OS header
	move.l	os_reset_p(a0),a0	;a0 -> reset routine
	jmp	(a0)			;perform reset
;
done_TT_RAM:
;
	lea	loc_stk_top(pc),sp	;sp -> loc_stk_top
	lea	(fix_ram+MAP_OFF).l,a6	;-> global map_beg
	lea	map_beg(pc),a5		;-> local  map_beg
	jsr	fix_cookies
	bsr	CLS_sub
activation:
	bsr	fix_tables
	bsr	CPU_8MHz			;use ST CPU speed
	bsr	Blit_8MHz			;use ST Blitter speed
	bsr	Bus_ST				;use ST Bus (on Falcon)
	bset	#1,(hw_syn).w			;use ST PAL video timing (just simulated)
	cmp.l	#30,ckt_value+cookie_CPU-map_beg(a6)	;68030 CPU installed ?
	bne.s	done_030_fix			;else skip 030 patches
	trace	'c'
	move.l	CACR_NC_val-map_beg(a6),d0	;d0 = value to disable cache
	movec.l	d0,CACR				;store d0 as cache control bits
	trace	'p'
	pmove.l	TC_passive-map_beg(a6),tc	;disable TC translation
	pmove.l	TT0_active-map_beg(a6),tt0	;set TT0
	pmove.l	TT1_active-map_beg(a6),tt1	;set TT1
	pmove.d	CRP_fixval-map_beg(a6),srp	;setup new SRP  (but not used)
	pmove.d	CRP_fixval-map_beg(a6),crp	;setup new CRP
	pmove.l	TC_active-map_beg(a6),tc	;activate new TC
done_030_fix:
	movem.l	booter_regs(pc),d0-d7/a0-a7	;restore all TOS call regs
	rts
;
;----------------------------------------------------------------------------
CPU_8MHz:
	cmp.l	#$00030000,ckt_value+cookie_MCH-map_beg(a5)	;Falcon ?
	bne.s	exit_comp_div
	move.b	(hw_f30_comp_div).w,d0
	bclr	#f30_comp_cpu_b,d0			;8MHz CPU
	bra.s	set_comp_div
;-------------------------------------
CPU_16MHz:
	cmp.l	#$00030000,ckt_value+cookie_MCH-map_beg(a5)	;Falcon ?
	bne.s	exit_comp_div
	move.b	(hw_f30_comp_div).w,d0
	bset	#f30_comp_cpu_b,d0			;16MHz CPU
	bra.s	set_comp_div
;-------------------------------------
Blit_8MHz:
	cmp.l	#$00030000,ckt_value+cookie_MCH-map_beg(a5)	;Falcon ?
	bne.s	exit_comp_div
	move.b	(hw_f30_comp_div).w,d0
	bclr	#f30_comp_blit_b,d0			;8MHz Blitter
	bra.s	set_comp_div
;-------------------------------------
Blit_16MHz:
	cmp.l	#$00030000,ckt_value+cookie_MCH-map_beg(a5)	;Falcon ?
	bne.s	exit_comp_div
	move.b	(hw_f30_comp_div).w,d0
	bset	#f30_comp_blit_b,d0			;16MHz Blitter
	bra.s	set_comp_div
;-------------------------------------
Bus_ST:
	cmp.l	#$00030000,ckt_value+cookie_MCH-map_beg(a5)	;Falcon ?
	bne.s	exit_comp_div
	move.b	(hw_f30_comp_div).w,d0
	bclr	#f30_comp_bus_b,d0			;ST Bus
	bra.s	set_comp_div
;-------------------------------------
Bus_Falcon:
	cmp.l	#$00030000,ckt_value+cookie_MCH-map_beg(a5)	;Falcon ?
	bne.s	exit_comp_div
	move.b	(hw_f30_comp_div).w,d0
	bset	#f30_comp_bus_b,d0			;Falcon Bus
set_comp_div:
	move.b	d0,(hw_f30_comp_div).w
exit_comp_div:
	rts						;return to caller
;----------------------------------------------------------------------------
booter_regs:
	ds.l	16
;----------------------------------------------------------------------------
	trace_CODE
;----------------------------------------------------------------------------
fix_cookies:
	lea	ckt_array(pc),a1
set_cookies_loop:
	movem.l	(a1)+,d0-d4
	tst.l	d0
	ble.s	done_cookies
;
	lea	(_cookies).w,a0
	tst.l	(a0)
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
	addq	#4,a0				;a0 -> found cookie value in cookie jar
	lea	-sizeof_ckt(a1),a3		;a3 -> ckt struct in local array
	sub.l	a5,a3				;a3 = dist from map_beg to ckt
;
	move.l	a0,a2				;a2 -> found cookie value in cookie jar
	tst.l	(fix_ram+IZF_OFF).l			;initialized yet ?
	beq.s	.use_value_ia2			;else use the newfound cookie
	tst.l	ckt_invalid(a6,a3)		;is cookie already validated ?
	bne.s	.use_value_ia2			;else use the newfound cookie
.old_cookie_src:
	lea	ckt_value(a6,a3),a2		;a2 -> cookie value in global map
.use_value_ia2:
	move.l	(a2),ckt_value(a5,a3)		;store new/old cookie locally
	move.l	(a2),ckt_value(a6,a3)		;store new/old cookie globally
	clr.l	ckt_invalid(a5,a3)		;flag local cookie as valid
	clr.l	ckt_invalid(a6,a3)		;flag global cookie as valid
	tst.l	d3			;patch this cookie ?
	beq.s	.done_cookie
	move.l	d4,(a0)			;patch cookie to STE value
.done_cookie:
	bra.s	set_cookies_loop
;
done_cookies:
	rts
;----------------------------------------------------------------------------
CLS_sub:
	gemdos	Cconws,CLS_s(pc)
	rts
;----------------------------------------------------------------------------
CLS_s:	dc.b	ESC,'E',CR,LF
	dc.b	NUL
	EVEN
;----------------------------------------------------------------------------
fix_tables:
	trace	't'
	move.l	a6,d0
	add.l	d0,CRP_fixval-map_beg+4(a5)	;relocate CRP fix address
;
	move.l	a5,a0				;a0 -> local map_beg
	move.l	a6,a1				;a1 -> global map_beg
	move.w	#(map_end-map_beg+3)/4-1,d0	;d0 = (longs-1) of map area
.loop:						;loop start
	move.l	(a0)+,(a1)+			;copy local long to global
	dbra	d0,.loop			;loop back for all longs
	move.l	#-1,(fix_ram+IZF_OFF).l		;flag RAM initialization done
	trace	'T'
	rts
;----------------------------------------------------------------------------
map_beg:
;------;
map_pos	set	0
;------;
SYS_RAM	MACRO
	dc.l	((map_pos<<16)|$01)
map_pos	set	map_pos+1
	ENDM
;------;
TPA_RAM	MACRO
	dc.l	((map_pos<<16)|$41)
map_pos	set	map_pos+1
	ENDM
;------;
TOS_ROM	MACRO
	dc.l	((map_pos<<16)|$01)
map_pos	set	map_pos+1
	ENDM
;------;
resIO_1	MACRO
	dc.l	((map_pos<<16)|$41|($FF<<24))
map_pos	set	map_pos+1
	ENDM
;------;
cartROM	MACRO
	dc.l	((map_pos<<16)|$41)
map_pos	set	map_pos+1
	ENDM
;------;
resIO_2	MACRO
	dc.l	((map_pos<<16)|$41|($FF<<24))
map_pos	set	map_pos+1
	ENDM
;------;
hard_IO	MACRO
	dc.l	((map_pos<<16)|$41|($FF<<24))
map_pos	set	map_pos+1
	ENDM
;------;
PMMU_map:
	repeat	$01-$00,SYS_RAM
	repeat	$E0-$01,TPA_RAM
	repeat	$F0-$E0,TOS_ROM
	repeat	$FA-$F0,resIO_1
	repeat	$FC-$FA,cartROM
	repeat	$FF-$FC,resIO_2
	repeat	1,hard_IO
;------;
TC_passive:	dc.l	0				;passive value for tc
TT0_active:	dc.l	0				;no TT0 translation
TT1_active:	dc.l	0				;no TT1 translation
;;;TT1_active:	dc.l	$FF008507			;Transparent IO translation
CACR_NC_val:	dc.l	$00000A0A			;CACR value for no cache
CRP_fixval:	dc.l	$80000002,PMMU_map-map_beg	;fix value for crp
TC_active:	dc.l	$80F88100			;fix value for tc
;----------------------------------------------------------------------------
def_cookie	MACRO	name,valid,value,iz_f,iz_v
cookie\1:
	dc.l	'\1',\2,\3,\4,\5
	ENDM	;def_cookie
;
ckt_array:
	def_cookie	_CPU,-1,0,0,$0000001E
	def_cookie	_MCH,-1,0,0,$00010000
	def_cookie	_SND,-1,0,1,$00000003
	dc.l	-1
;
	EVEN
map_end:
;----------------------------------------------------------------------------
loc_stack:
loc_stk_top	=	loc_stack+$1000
;----------------------------------------------------------------------------
code_end:
code_size	=	code_end-fix_ram
;----------------------------------------------------------------------------
	IFNE	(code_size>65536)
	FAIL	"Code exceeds 65536 bytes (Max size for this file)"
	ENDC
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	FAL_CART.S
;----------------------------------------------------------------------------
