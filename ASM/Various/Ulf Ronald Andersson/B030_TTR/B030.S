;----------------------------------------------------------------------------
;File name:	B030.S				Revision date:	1999.01.22
;Created by:	Ulf Ronald Andersson		Creation date:	1997.03.14
;----------------------------------------------------------------------------
	output	.BS
;----------------------------------------------------------------------------
	include	RA_TOS.I
	include	bs_comp\TRACER.I
;----------------------------------------------------------------------------
trace_mode	set	0
;----------------------------------------------------------------------------
FIX_RAM		=	3*Mb+512*Kb	;fixed phystop
USE_RAM		=	FIX_RAM		;$01000000 for TT-RAM, else FIX_RAM
;----------------------------------------------------------------------------
INI_OFF	=	$40000	;offs to ident and init flags
MAP_OFF	=	$40400	;offs to translation tables etc
LIM_OFF	=	$7FF00	;phystop on coldboot must have higher offset
;----------------------------------------------------------------------------
ident_M	macro
ident_beg:
	dc.l	'STe_','B030'
	dc.l	'2.00','1999'
FIX_RAM_p:
	dc.l	FIX_RAM
USE_RAM_p:
	dc.l	USE_RAM
ident_end:
	endm	;ident_M
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
code_beg:
	bra.s	main_code	;boot sector code link
;----------------------------------------------------------------------------
	ds.b	28		;boot sector parts reserved for BIOS use
;----------------------------------------------------------------------------
main_code:
	move.l	a0,-(sp)		;push entry a0
	lea	booter_regs(pc),a0	;a0 -> save area
	movem.l	d0-d7/a0-a6,(a0)	;save entry regs (with a0 incorrect)
	move.l	(sp)+,8*4(a0)		;save correct a0
	move.l	sp,15*4(a0)		;save entry sp in the same reg list
;-------
	move.l	USE_RAM_p(pc),a6
	add.l	#INI_OFF,a6		;a6 -> INI_RAM
	lea	ident_beg(pc),a5	;a5 -> ident_beg
;-------
	clr.l	d7			;clear reboot flag
	moveq	#$01,d3			;d3 = $00000001 \/ shorter code for
	ror.l	#8,d3			;d3 = $01000000 /\ move.l #$1000000,d3
fix_TT_RAM:
	cmpi.l	#$1357BD13,(ramvalid).w	;test TT RAM validity
	bne.s	done_TT_RAM		;done if TT RAM invalid
	cmp.l	(ramtop).w,d3		;test (TT_RAM_base - ramtop)
	bge.s	done_TT_RAM		;done OK if size undefined
	move.l	d3,(ramtop).w		;else lower ramtop to base
	st	d7			;and set reboot flag
done_TT_RAM:
;-------
fix_ST_RAM:
	move.l	FIX_RAM_p(pc),d0	;d0 -> FIX_RAM
	move.l	(phystop).w,d1		;d1 =  phystop
	move.l	d1,d2			;d2 =  phystop
	lsr.l	#1,d2			;d2 =  phystop / 2
	and	#$FFFC,d2		;align d2 to long border
	move.l	d2,sp			;sp -> aligned phystop/2 (pseudo-allocation)
;-------
	cmp.l	d0,d1			;test (phystop - FIX_RAM)
	bhi.s	try_primary_boot	;if phystop is higher, it's not a B030 reboot
try_secondary_boot:
	move.l	a5,a0
	move.l	a6,a1
	moveq	#(ident_end-ident_beg)/2-1,d0
test_ident:
	cmpm	(a1)+,(a6)+
	dbne	d0,test_ident
	beq.s	matched
cold_reset:
	clr.l	(ramvalid).w		;invalidate TT RAM
	clr.l	(memvalid).w		;invalidate ST RAM control
	clr.l	(memval2).w		;invalidate ST RAM
	bra.s	make_reset
;----------------------------------------------------------------------------
try_primary_boot:
	move.b	USE_RAM_p(pc),d2	;test top byte of USE_RAM pointer
	bne.s	.done_LIM_OFF		;NE means TT_RAM, so LIM_OFF is irrelevant
	move.l	d0,d2
	add.l	#LIM_OFF,d2		;d2 -> FIX_RAM+LIM_OFF
	cmp.l	d2,d1			;is 'our' RAM already taken
	blo.s	cold_reset		;then we have to reset cold
.done_LIM_OFF:
	tst.b	d1			;if non-zero, the system is crazy  :-)
	bne.s	cold_reset		;then we also need a cold reset
primary_boot:
	sub.l	d1,d0			;d0 = FIX_RAM-phystop
	add.l	d0,(_memtop).w		;adjust _memtop
	add.l	d0,(_v_bas_ad).w	;adjust _v_basadd
	add.l	d0,(phystop)		;adjust	_phystop
;-------
	moveq	#(ident_end-ident_beg)/2-1,d0
init_ident:
	move	(a5)+,(a6)+
	dbra	d0,init_ident
;-------
	lea	code_beg(pc),a0
	move.l	a0,(a6)+		;store init boot sector address
	clr.l	(a6)+			;clear init state flags
make_reset:
	move.l	(_sysbase).w,a0		;a0 -> OS header (may be a copy)
	move.l	os_selfbeg_p(a0),a0	;a0 -> Original OS header
	move.l	os_reset_p(a0),a0	;a0 -> reset routine
	jmp	(a0)			;perform reset
;----------------------------------------------------------------------------
matched:			;here a6 -> init boot sector pointer
	tst.l	d7		;does TT RAM need reset ?
	bne.s	make_reset	;if so, go reset (warm)
	lea	code_beg(pc),a0
	move.l	a0,(a6)+	;store init boot sector address  a6-> init flags
	clr.l	(a6)+		;clear init state flags  a6 -> room for 'booter'
	move.l	a6,a1		;a1 -> room for 'booter' code
	lea	booter_beg(pc),a0
	moveq	#(booter_end-booter_beg+3)/4-1,d0
copy_booter:
	move.l	(a0)+,(a1)+
	dbra	d0,copy_booter
	jsr	(a6)		;this should never return here !!!
	bra.s	cold_reset	;so if it does, a cold boot is best...
;----------------------------------------------------------------------------
booter_beg:
	gemdos	Fopen,longboot_bin_s(pc),#0	;open file
	move.l	d0,d7				;d7 = handle/error_flag
	ble.s	.error			;.error if negative or zero
	move.l	USE_RAM_p(pc),a3		;a3 -> USE_RAM (program header)
	gemdos	Fread,d7,#$10000,(a3)		;read file
	move.l	d0,d6				;d6 = Fread return value
	gemdos	Fclose,d7			;close file
	move.l	d6,d0				;d0 = Fread return value
	ble.s	.error			;.error if negative or zero
	addq	#4,sp				;pop unwanted return address
	lea	ph_textbeg(a3),a0		;a0 -> textbeg
	lea	RUN_RAM_p(pc),a1
	move.l	a0,(a1)
	lea	(a3),a1				;a1 -> program header
	bsr.s	relocate			;relocate program
	movem.l	booter_regs(pc),d0-d7/a0-a7	;restore all entry regs
	move.l	RUN_RAM_p(pc),-(sp)		;push destination address
	rts					;and jump there by RTS
;
.error:
	rts
;----------------------------------------------------------------------------
	include	"bs_comp\RELOCATE.S"
;----------------------------------------------------------------------------
	ident_M
;----------------------------------------------------------------------------
RUN_RAM_p:
	dc.l	0
booter_regs:
	ds.l	16
longboot_bin_s:
	dc.b	'A:\longboot.bin',0
	EVEN
;----------------------------------------------------------------------------
	trace_CODE
;----------------------------------------------------------------------------
booter_end:
;----------------------------------------------------------------------------
code_end:
code_size	=	code_end-code_beg
;----------------------------------------------------------------------------
sz_pad	MACRO	id,limit,pos
	IFNE	((\2)>(\3))
sz_pad__tmp	set	\2-\3
	dcb.b	sz_pad__tmp,0
;--Note--;	\1 was padded by \<$sz_pad__tmp> bytes. OK!
	ELSEIF
	IFNE	((\3)>(\2))
sz_pad__tmp	set	\3-\2
	FAIL	\1 was too large by \<$sz_pad__tmp> bytes.
	ENDC
	ENDC
	ENDM	;sz_pad
;----------------------------------------------------------------------------
	sz_pad	boot_sector,510,code_size
;
checksum:
	dc.w	0
;----------------------------------------------------------------------------
	END
;----------------------------------------------------------------------------
;End of file:	B030.S
;----------------------------------------------------------------------------
