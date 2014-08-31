;----------------------------------------------------------------------------
;File name:	LONGBOOT.S			Revision date:	1999.01.22
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
	lea	loc_stk_top(pc),sp	;sp -> loc_stk_top
	lea	(fix_ram+MAP_OFF).l,a6	;-> global map_beg
	lea	map_beg(pc),a5		;-> local  map_beg
	jsr	fix_cookies
	xbios	Getrez
	move	d0,entry_rez-map_beg(a5)	;remember entry rez
	beq.s	keep_entry_rez			;don't change from ST Low
	cmp	#2,d0
	beq.s	keep_entry_rez			;don't change from ST High
	xbios	Setscreen,-1.w,-1.w,#0		;Set ST Low
keep_entry_rez:
	move.l	(_sysbase).w,a0		;a0 -> TOS header copy
	move.l	a0,a1			;a1 -> TOS header copy
	move.l	os_selfbeg_p(a1),a1	;a1 -> TOS header original (we hope)
find_original_TOS:
	cmpa.l	os_selfbeg_p(a1),a1	;is it really TOS header original
	bne.s	find_original_TOS	;else loop back to find it
	move.l	a1,a3			;a3 = a1 -> TOS header original
	lea	loc_os_head(pc),a2	;a2 -> room for local header copy
	moveq	#3*16/4-1,d0		;d0 = dbra count for longs of header
copy_header_loop:			;loop to copy all longs of header
	move.l	(a0)+,(a2)+		;copy one long of header copy
	dbra	d0,copy_header_loop	;loop back for entire header (48 bytes)
	lea	loc_os_head(pc),a2	;a2 -> local header copy
	move.l	a3,os_selfbeg_p(a2)
main_loop:
	lea	prompt_s(pc),a3
	bsr	prompt_sub
	move.l	d0,d1
	cmp.b	#'a',d0
	blo.s	.have_char
	cmp.b	#'z',d0
	bhi.s	.have_char
	add.b	#'A'-'a',d0
.have_char:
	lea	boot_commands_s(pc),a0
	lea	boot_commands_t(pc),a1
.search_loop:
	move.w	(a1)+,d2
	move.b	(a0)+,d3
	beq.s	main_loop
	cmp.b	d3,d0
	bne.s	.search_loop
	move.b	d0,command_char
	jmp	(a5,d2.w)
;----------------------------------------------------------------------------
command_ESC:
command_SPC:
	bsr	CLS_sub
activation:
	bsr	fix_tables
	tst.b	memptr_fix_f-map_beg(a6)
	beq	done_memptr_fix
	trace	'm'
	lea	loc_os_head-map_beg(a6),a0
	move.l	a0,(_sysbase).w
	move.l	(_sysbase).w,a0			;a0 -> OS header copy
	move.l	os_selfbeg_p(a0),a0		;a0 -> True OS header
	move.l	os_gem_mpb_p(a0),a0		;a0 -> GEM mpb
	cmp.l	#$87654321,(a0)+		;check GEM mpb validity
	bne.s	done_lomem_fix			;skip fix if GEM mpb invalid
	move.l	(a0),d0				;d0 -> end of GEM BSS
	move.l	(_membot).w,d1			;d1 -> current lomem
	cmp.l	d0,d1				;check if same as we want
	beq.s	done_lomem_fix			;if same, no fix is needed
	blt.s	done_lomem_fix			;if lower, no fix is needed
	move.l	d0,(_membot)			;fix lomem in '_membot' ptr
	cmp.l	(themd+4).w,d1			;was free mem at lomem ?
	bne.s	done_lomem_fix			;if not, fix is complete
	move.l	d0,(themd+4).w			;fix memptr in 'themd' struct
	sub.l	d0,d1				;d1 = size difference
	add.l	d1,(themd+8).w			;adjust size in 'themd' struct
done_lomem_fix:
	move.l	(phystop).w,d0			;d0 -> system RAM end
	sub.l	#32000,d0			;d0 -> RAM end - new screen size
	and.l	#-$200,d0			;d0 -> new screen base (mult of $200)
	move.l	d0,a0				;a0 -> new screen base
	move.w	entry_rez-map_beg(a5),d3	;d3 = entry rez
	cmp.w	#2,d3				;booting ST High ?
	beq.s	setup_rez			;do not change from ST High
	clr.w	d3				;enforce ST Low
setup_rez:
	move.l	(_v_bas_ad).w,a1		;a1 -> old screen
	cmp.l	(_memtop).w,a1			;did _memtop -> old screen ? (untrue on Falcon!)
	seq	_memtop_adj_f-map_beg(a5)	;flag this in _memtop_adj_f
	move.l	a1,d1				;d1 = old screen base
	sub.l	(themd+4).w,d1			;d1 = old screen base - free RAM base
	cmp.l	(themd+8).w,d1			;did free RAM end at old screen base ? (true on Falcon)
	seq	themd_adj_f-map_beg(a5)		;flag this in themd_adj_f
	xbios	Setscreen,(a0),(a0),d3		;activate new screen
	bset	#1,(hw_syn).w
	xbios	Vsync				;\/ Give TOS time to 'swallow'
	xbios	Vsync				;/\ the new screen settings !
	tst.b	_memtop_adj_f-map_beg(a5)	;was _memtop -> old screen ?
	beq.s	.done_memtop			;if not, go leave _memtop as is
	move.l	(_v_bas_ad).w,(_memtop).w	;make _memtop -> new screen
.done_memtop:
	tst.b	themd_adj_f-map_beg(a5)		;did themd base+size == old screen base ?
	beq.s	.done_themd_size		;if not, go leave themd size as is
	move.l	(_v_bas_ad).w,d1		;d1 = new screen base
	sub.l	(themd+4).w,d1			;d1 = new screen base - free RAM base
	move.l	d1,(themd+8).w			;make free RAM end at new screen base
.done_themd_size:
done_memptr_fix:
	trace	'M'
	bsr	fix_MHz8
	cmp.l	#30,ckt_value+cookie_CPU-map_beg(a6)	;68030 CPU installed ?
	bne.s	done_030_fix			;else skip 030 patches
	trace	'c'
	move.l	CACR_NC_val-map_beg(a6),d0	;d0 = value to disable cache
	movec.l	d0,CACR				;store d0 as cache control bits
	tst.b	PMMU_fix_f-map_beg(a6)
	beq.s	done_PMMU_fix
	trace	'p'
	lea	TC_TTx_iz_val-map_beg(a6),a0
	pmove.l	(a0),tc				;disable TC translation
	pmove.l	(a0),tt0			;disable TT0 translation
	pmove.l	(a0),tt1			;disable TT1 translation
	pmove.d	CRP_active-map_beg(a6),srp	;setup new SRP  (but not used)
	pmove.d	CRP_active-map_beg(a6),crp	;setup new CRP
	pmove.l	TC_active-map_beg(a6),tc	;activate new TC
done_PMMU_fix:
	trace	'P'
	tst.b	Cach_act_f-map_beg(a6)
	beq.s	done_CACR_fix
	move.l	CACR_AC_val-map_beg(a6),d0	;d0 = value to disable cache
	movec.l	d0,CACR				;store d0 as cache control bits
done_CACR_fix:
done_030_fix:
	trace	'C'
	trace	'e'
	tst.b	TPA_clr_fix_f-map_beg(a6)
	beq.s	done_TPA_clr
	move.l	(themd+8).w,d0			;d0 = bytes of free RAM
	move.l	(themd+4).w,a0			;a0 -> free RAM start
	lsr.l	#2,d0				;d0 = longs of free RAM
	subq.l	#1,d0				;d0 = long dbra count
	swap	d0				;d0 = reversed long dbra count
clear_mem_lp_1:					;loop for block of 65536 longs
	swap	d0				;d0 = normal long dbra count
clear_mem_lp_2:					;loop for each long
	clr.l	(a0)+				;clear one long
	dbra	d0,clear_mem_lp_2		;count down one long
	swap	d0				;d0 = reversed long dbra count
	dbra	d0,clear_mem_lp_1		;count down 65536 longs
done_TPA_clr:
	cmp.b	#ESC,command_char
	bne.s	boot_alien_sector
boot_normally:
	trace	'N'
	bra.w	execution
;
boot_alien_sector:
	trace	'b'
	move.l	(fix_ram+BS_OFFS).l,a4	;a4 -> old bootsector base
	move.l	a4,d0
	ble.s	boot_normally
	move.l	(hdv_boot).w,a0
	jsr	(a0)
	tst.w	d0
	bne.s	boot_normally
	move.l	(_dskbufp).w,a4		;a4 -> new bootsector base
	move.l	booter_regs-map_beg+15*4(a5),a0	;a0 =  entry boot SP
	move.l	a4,-(a0)			;push a4 on boot stack
	move.l	a0,booter_regs-map_beg+15*4(a5)	;resave updated boot SP
	trace	'B'
	move	(_bootdev).w,d0
	add.b	d0,somefile_any_s
	move.l	#1000,d0
	add.l	d0,(_hz_200).w
	lsr.l	#2,d0
	add.l	d0,(_frclock).w
	add.l	d0,(_vbclock).w
	xbios	Vsync
	xbios	Vsync
	gemdos	Fopen,somefile_any_s(pc),#0
	tst.l	d0
	bmi.s	.not_open
	gemdos	Fclose,d0
.not_open:
execution:
	trace	'E'
	movem.l	booter_regs(pc),d0-d7/a0-a7	;restore all TOS call regs
	tst.b	breakpoint_fix_f
	beq.s	done_breakpoint
	move.l	breakpoint_code(pc),-128(sp)
	jmp	-128(sp)
;
breakpoint_code:
	illegal
done_breakpoint:
	rts
;
somefile_any_s:	dc.b	'A:\somefile.any'
		EVEN
;----------------------------------------------------------------------------
booter_regs:
	ds.l	16
;----------------------------------------------------------------------------
	trace_CODE
;----------------------------------------------------------------------------
	include	"bs_comp\SEEMEM.S"
;----------------------------------------------------------------------------
command_I:
	lea	info_s(pc),a3
	bsr	prompt_sub
	bra	main_loop
;----------------------------------------------------------------------------
command_S:
	lea	$400.w,a0
	bsr	seemem
	bra	main_loop
;----------------------------------------------------------------------------
command_Z:
	gemdos	Cconws,rezchg_prompt_s(pc)
	dc.w	$a000
	bsr	disp_long
	gemdos	Cconws,rezchg_tail_s(pc)
	bsr	get_long
	beq	main_loop
	move	d0,d1
	swap	d1
	cmp	#1,d1
	bhi.s	.F030_rez
	beq.s	.TT_rez
.ST_rez:
	xbios	Setscreen,-1.w,-1.w,d0
	bra	main_loop
;
.TT_rez:
	xbios	EsetShift,d0
	bra	main_loop
;
.F030_rez:
	cmp	#2,d1
	bhi	main_loop
	xbios	VsetMode,d0
	bra	main_loop
;----------------------------------------------------------------------------
command_T:
	st	TPA_clr_fix_f-map_beg(a5)
	bra	main_loop
;----------------------------------------------------------------------------
command_M:
	sf	memptr_fix_f-map_beg(a5)
	bra	main_loop
;----------------------------------------------------------------------------
command_P:
	sf	PMMU_fix_f-map_beg(a5)
	bra	main_loop
;----------------------------------------------------------------------------
command_C:
	sf	Cach_fix_f-map_beg(a5)
	bra	main_loop
;----------------------------------------------------------------------------
command_ctrl_C:
	st	Cach_act_f-map_beg(a5)
	bra	main_loop
;----------------------------------------------------------------------------
command_B:
	st	breakpoint_fix_f-map_beg(a5)
	bra	main_loop
;----------------------------------------------------------------------------
command_F:
	sf	MHz8_fix_f-map_beg(a5)
	bra	main_loop
;----------------------------------------------------------------------------
command_R:
	sf	TPA_clr_fix_f-map_beg(a5)
	st	Cach_fix_f-map_beg(a5)
	st	MHz8_fix_f-map_beg(a5)
	st	PMMU_fix_f-map_beg(a5)
	st	memptr_fix_f-map_beg(a5)
	sf	Cach_act_f-map_beg(a5)
	sf	breakpoint_fix_f-map_beg(a5)
	bra	main_loop
;----------------------------------------------------------------------------
command_X:
	gemdos	Pexec,#0,debugger_s(pc),null_s(pc),null_s(pc)
	bra	main_loop
;----------------------------------------------------------------------------
fix_tables:
	trace	't'
	move.l	a6,d0
	add.l	d0,CRP_active-map_beg+4(a5)	;relocate CRP fix address
;
	tst.b	Cach_fix_f-map_beg(a5)
	bne.s	.done_cache_patch
	lea	PMMU_map(pc),a0			;a0 -> PMMU entry for $00000000
	move	#$E0-1,d1			;d1=dbra count for RAM descriptors
.patch_cache_loop:
	bclr	#6,3(a0)
	addq	#4,a0
	dbra	d0,.patch_cache_loop
.done_cache_patch:
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
fix_MHz8:
	cmp.l	#$00030000,ckt_value+cookie_MCH-map_beg(a5)	;Falcon ?
	bne.b	done_MHz8_fix
	trace	'f'
	tst.b	MHz8_fix_f-map_beg(a5)
	beq.s	set_16MHz
	trace	'8'
	move.b	(hw_f30_comp_div).w,d0
	bclr	#f30_comp_cpu_b,d0			;8MHz CPU
	bclr	#f30_comp_blit_b,d0			;8MHz Blitter
	bclr	#f30_comp_bus_b,d0			;8MHz Bus
	bra.s	set_MHz_d0
;
set_16MHz:
	trace	'H'
	move.b	(hw_f30_comp_div).w,d0
	bset	#f30_comp_cpu_b,d0			;16MHz CPU
	bset	#f30_comp_blit_b,d0			;16MHz Blitter
	bset	#f30_comp_bus_b,d0			;16MHz Bus
set_MHz_d0:
	move.b	d0,(hw_f30_comp_div).w
done_MHz8_fix:
	trace	'F'
	rts				;return to caller
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
prompt_sub:
	bsr.s	CLS_sub
	gemdos	Cconws,(a3)
	gemdos	Crawcin
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
info_s:
	dc.b	'----------------------------------------',CR,LF
	dc.b	' B030 v1.1  by  Ulf Ronald Andersson    ',CR,LF
	dc.b	' Email address = dlanor@ettnet.se       ',CR,LF
	dc.b	' Webpage = http://www.ettnet.se/~dlanor/',CR,LF
	dc.b	'----------------------------------------',CR,LF
	dc.b	'B030 is bugtested on TT, Falcon, Mega ST',CR,LF
	dc.b	"(Though it's not really needed on an ST)",CR,LF
	dc.b	'----------------------------------------',CR,LF
	dc.b	'B030 can disable caching via both CACR  ',CR,LF
	dc.b	'and PMMU. Then most  OS  drivers can not',CR,LF
	dc.b	'undo it again (eg: HDDRIVER), so we can ',CR,LF
	dc.b	'now run programs needing slow speed from',CR,LF
	dc.b	'harddisk, with drivers that enable cache',CR,LF
	dc.b	'(Since their doing so has no effect.)   ',CR,LF
	dc.b	'----------------------------------------',CR,LF
	dc.b	'B030 checks _MCH cookie, so that Falcon-',CR,LF
	dc.b	'specific  stuff is only used on Falcons.',CR,LF
	dc.b	'(8MHz/16MHz option only works on Falcon)',CR,LF
	dc.b	'----------------------------------------',CR,LF
	dc.b	'Send me feedback if you need any changes',CR,LF
	dc.b	'I can only fix problems I am aware of ! ',CR,LF
	dc.b	'Making me aware of them is your job...  ',CR,LF
	dc.b	'----------------------------------------',CR,LF
	dc.b	'Press any key to go back to main page.  ',CR,LF
	dc.b	'----------------------------------------'
	dc.b	NUL
	EVEN
;----------------------------------------------------------------------------
rezchg_prompt_s:
	dc.b	ESC,'E'
	dc.b	'----------------------------------------',CR,LF
	dc.b	' B030 v1.1  by  Ulf Ronald Andersson    ',CR,LF
	dc.b	' Email address = dlanor@ettnet.se       ',CR,LF
	dc.b	' Webpage = http://www.ettnet.se/~dlanor/',CR,LF
	dc.b	'----------------------------------------',CR,LF
	dc.b	'You may now enter a code to be used for ',CR,LF
	dc.b	'changing the resolution temporarily. At ',CR,LF
	dc.b	'exit from B030 the resolution will again',CR,LF
	dc.b	'be switched back to the one active when ',CR,LF
	dc.b	'the main menu was first displayed. This ',CR,LF
	dc.b	'temporary rez change only exists here to',CR,LF
	dc.b	'simplify investigation of TOS variations',CR,LF
	dc.b	'----------------------------------------',CR,LF
	dc.b	'Add the following offset to use various ',CR,LF
	dc.b	'methods of rez change:                  ',CR,LF
	dc.b	'00000 => low word used as Setscreen mode',CR,LF
	dc.b	'10000 => low word used as EsetShift mode',CR,LF
	dc.b	'20000 => low word used as Vsetmode mode ',CR,LF
	dc.b	'Higher offsets cancel the rez change, as',CR,LF
	dc.b	'is also the result of a blank entry.    ',CR,LF
	dc.b	'----------------------------------------',CR,LF
	dc.b	'Btw: Your screen variable base, formerly',CR,LF
	dc.b	'called "line_a base" is at $',NUL
rezchg_tail_s:
	dc.b	ESC,'K',CR,LF
	dc.b	'----------------------------------------',CR,LF
	dc.b	'Enter mode in hex digits: ',NUL
	dc.b	NUL
	EVEN
;----------------------------------------------------------------------------
prompt_s:
	dc.b	'----------------------------------------',CR,LF
	dc.b	' B030 v1.1  by  Ulf Ronald Andersson    ',CR,LF
	dc.b	' Email address = dlanor@ettnet.se       ',CR,LF
	dc.b	' Webpage = http://www.ettnet.se/~dlanor/',CR,LF
	dc.b	'----------------------------------------',CR,LF
	dc.b	'Your system will soon emulate an STE as ',CR,LF
	dc.b	'far as possible.  Choose options here...',CR,LF
	dc.b	'----------------------------------------',CR,LF
	dc.b	'  "I"  => read more info about B030     ',CR,LF
	dc.b	'  "S"  => browse system variables       ',CR,LF
	dc.b	'  "Z"  => Rez change (temporarily)      ',CR,LF
	dc.b	'  "M"  => memory ptr fix = OFF  (def=ON)',CR,LF
	dc.b	'  "P"  => PMMU = OFF            (def=ON)',CR,LF
	dc.b	'  "C"  => PMMU anti-cache = OFF (def=ON)',CR,LF
	dc.b	'ctrl-C => CACR caching = ON    (def=OFF)',CR,LF
	dc.b	'  "B"  => Exit breakpoint = ON (def=OFF)',CR,LF
	dc.b	'  "T"  => TPA clearing = ON    (def=OFF)',CR,LF
	dc.b	'  "F"  => set Falcon to 16MHz (def=8MHz)',CR,LF
	dc.b	'  "R"  => Restore default settings      ',CR,LF
	dc.b	'  "X"  => Execute A:\DEBUGGER.PRG now   ',CR,LF
	dc.b	'Space  => Boot, trying floppy bootsector',CR,LF
	dc.b	'Escape => Boot, but no floppy bootsector',CR,LF
	dc.b	'----------------------------------------',CR,LF
	dc.b	'NB: HDDRIVER fails if CACR caching is ON'
	dc.b	NUL
	EVEN
;----------------------------------------------------------------------------
boot_commands_s:
	dc.b	'ISZTMPC',('C'&$1F),'BFRX ',ESC
	dc.b	NUL
	EVEN
;
boot_commands_t:
	dc.w	command_I-map_beg
	dc.w	command_S-map_beg
	dc.w	command_Z-map_beg
	dc.w	command_T-map_beg
	dc.w	command_M-map_beg
	dc.w	command_P-map_beg
	dc.w	command_C-map_beg
	dc.w	command_ctrl_C-map_beg
	dc.w	command_B-map_beg
	dc.w	command_F-map_beg
	dc.w	command_R-map_beg
	dc.w	command_X-map_beg
	dc.w	command_SPC-map_beg
	dc.w	command_ESC-map_beg
;
debugger_s:
	dc.b	'debugger.prg',NUL
	EVEN
null_s:
	dc.l	NUL
;----------------------------------------------------------------------------
map_beg:
;------;
map_pos	set	0
;------;
SYS_RAM	MACRO
	dc.l	((map_pos<<16)|$41)
map_pos	set	map_pos+1
	ENDM
;------;
TPA_RAM	MACRO
	dc.l	((map_pos<<16)|$41)
map_pos	set	map_pos+1
	ENDM
;------;
TOS_ROM	MACRO
	dc.l	((map_pos<<16)|$41)
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
TC_TTx_iz_val:	dc.l	0
CACR_NC_val:	dc.l	$00000A0A			;CACR value for no cache
CACR_AC_val:	dc.l	$00000909			;CACR value for active cache
CRP_active:	dc.l	$80000002,PMMU_map-map_beg	;fix value for crp
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
loc_os_head:
	ds.b	3*16
;
entry_rez:	dc.w	0		;patched at init
;
TPA_clr_fix_f:		dc.b	0
memptr_fix_f:		dc.b	-1
PMMU_fix_f:		dc.b	-1
Cach_fix_f:		dc.b	-1
Cach_act_f:		dc.b	0
breakpoint_fix_f:	dc.b	0
MHz8_fix_f:		dc.b	-1
;
_memtop_adj_f:		dc.b	0
themd_adj_f:		dc.b	0
;
command_char:		dc.b	0
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
;End of file:	LONGBOOT.S
;----------------------------------------------------------------------------
