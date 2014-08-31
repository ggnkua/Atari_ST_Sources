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
FIX_RAM		=	512*Kb	;fixed phystop
;----------------------------------------------------------------------------
INI_OFF	=	$40000	;offs to ident and init flags
MAP_OFF	=	$40400	;offs to translation tables etc
LIM_OFF	=	$7FF00	;phystop on coldboot must have higher offset
;----------------------------------------------------------------------------
	SECTION	TEXT
;----------------------------------------------------------------------------
code_beg:
	bra.s	main_code	;boot sector code link
;----------------------------------------------------------------------------
	ds.b	28		;boot sector parts reserved for BIOS use
;----------------------------------------------------------------------------
boot_ref:
	dc.l	'STE_','B030'
	dc.l	'URAn','1998'
;----------------------------------------------------------------------------
main_code:
	move.l	a0,-(sp)		;push entry a0
	lea	booter_regs(pc),a0	;a0 -> save area
	movem.l	d0-d7/a0-a6,(a0)	;save entry regs (with a0 incorrect)
	move.l	(sp)+,8*4(a0)		;save correct a0
	lea	(FIX_RAM+INI_OFF).l,a6	;a6 -> INI_RAM
	lea	boot_ref(pc),a5		;a5 -> boot_ref
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
fix_ST_RAM:
	move.l	#FIX_RAM,d0		;d0 -> FIX_RAM
	move.l	(phystop).w,d1		;d1 =  phystop
	move.l	d1,d2			;d2 =  phystop
	lsr.l	#1,d2			;d2 =  phystop / 2
	and	#$FFFC,d2		;align d2 to long border
	move.l	d2,a0			;a0 -> aligned phystop/2
	exg	a0,sp			;sp -> aligned phystop/2  a0 -> old sp
	pea	(a0)			;push old sp
	move.l	(_memtop).w,d2		;d2 -> end of free ST RAM
	move.l	(_v_bas_ad).w,d3	;d3 -> base of video RAM
	cmp.l	d0,d1			;test (phystop - FIX_RAM)
	bls.s	secondary_boot		;if not higher, go test secondary boot
primary_boot:
	cmp.l	#FIX_RAM+LIM_OFF,d1	;is 'our' RAM already taken
	blo.s	cold_reset		;then we have to reset cold
	tst.b	d1			;if non-zero, the system is crazy  :-)
	bne.s	cold_reset		;then we also need a cold reset
	sub.l	d1,d0			;d0 = FIX_RAM-phystop
	add.l	d0,(_memtop).w		;adjust _memtop
	add.l	d0,(_v_bas_ad).w	;adjust _v_basadd
	add.l	d0,(phystop)		;adjust	_phystop
done_ST_RAM:
	move.l	(a5)+,(a6)+		;\/ copy primary
	move.l	(a5)+,(a6)+		;/\ identifier
	move.l	(a5)+,(a6)+		;\/ copy secondary
	move.l	(a5)+,(a6)+		;/\ identifier
	lea	code_beg(pc),a0
	move.l	a0,(a6)+		;store init boot sector address
	clr.l	(a6)+			;clear init state flags
make_reset:
	move.l	(_sysbase).w,a0		;a0 -> OS header (may be a copy)
	move.l	os_selfbeg_p(a0),a0	;a0 -> Original OS header
	move.l	os_reset_p(a0),a0	;a0 -> reset routine
	jmp	(a0)			;perform reset
;----------------------------------------------------------------------------
secondary_boot:
	cmp.l	(a5)+,(a6)+	;test first long of primary id
	bne.s	cold_reset
	cmp.l	(a5)+,(a6)+	;test second long of primary id
	beq.s	matched
cold_reset:
	clr.l	(ramvalid).w		;invalidate TT RAM
	clr.l	(memvalid).w		;invalidate ST RAM control
	clr.l	(memval2).w		;invalidate ST RAM
	bra.s	make_reset
;----------------------------------------------------------------------------
matched:			;here a6 -> secondary id (2 longs, not tested)
	tst.l	d7		;does TT RAM need reset ?
	bne.s	make_reset
	addq	#8,a6		;a6 -> init boot sector pointer
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
	lea	(FIX_RAM).l,a4			;a4 -> textbeg
	lea	-ph_textbeg(a4),a3		;a3 -> program header
	gemdos	Fread,d7,#$10000,(a3)		;read file
	move.l	d0,d6				;d6 = Fread return value
	gemdos	Fclose,d7			;close file
	move.l	d6,d0				;d0 = Fread return value
	ble.s	.error			;.error if negative or zero
	addq	#4,sp				;pop unwanted return address
	lea	(a4),a0				;a0 -> textbeg
	lea	(a3),a1				;a1 -> program header
	bsr.s	relocate			;relocate program
	move.l	(sp)+,sp			;restore entry sp
	movem.l	booter_regs(pc),d0-d7/a0-a6	;restore all other entry regs
	jmp	(FIX_RAM).l
;
.error:
	rts
;----------------------------------------------------------------------------
	include	"bs_comp\RELOCATE.S"
;----------------------------------------------------------------------------
longboot_bin_s:
	dc.b	'A:\longboot.bin',0
	EVEN
booter_regs:
	ds.l	15
;----------------------------------------------------------------------------
	trace_CODE
;----------------------------------------------------------------------------
booter_end:
;----------------------------------------------------------------------------
code_end:
code_size	=	code_end-code_beg
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
