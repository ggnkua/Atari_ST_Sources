*********************************************************************************
* TAB Setting = 8								*
*										*
* 	Program: MMUDump							*
* 	Version: 0.6 beta							*
*	Purpose: Dump the MMU settings of 040/060.				*
*	Author:  Odd Skancke - AssemSoft productions.				*
*	Status:  FreeWare - Only to be distributed with MiNT kernel releases.	*
*										*
* MMUDump is a little tool that will print the CPU register settings, and if	*
* the MMU is enabled, will let you choose to dump the current MMU tree.		*
*										*
* These sources was created with QED for use with GenTT.ttp assembler (DevPac)	*
*										*
*********************************************************************************
mc060:	= 1	;Set to 0 to assemble for 040, 1 to assemble for 060.
		;If enuff complaints arrive, I will include routines to check
		;the _CPU cookie. 

		comment HEAD=1
		opt p=68040
		output .tos

stack_size:	= 2*1024

	include	..\header\mmudefs.h
	include	..\header\gemdos.h

		text

start_up:	move.l	4(sp),a5	;Address of basepage in A5
		move.l	#newstack,sp	;Set new stack address
		move.l	bp_tlen(a5),d0	;Lenght of program in D0
		add.l	bp_dlen(a5),d0	;Add lenght of data segment
		add.l	bp_blen(a5),d0	;Then the lengh of BSS area
		add.l	#$100,d0	;finally, the basepage size
		move.l	d0,-(sp)	;Number of byte to reserve
		move.l	a5,-(sp)	;From this address
		clr.w	-(sp)		;Dummy
		move.w	#$4a,-(sp)	;Mshrink()
		trap	#1
		lea	12(sp),sp

	;Print the intro-message
		pea	intro_m
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp

	;Get the cpu register settings
		lea	mmureg_contents(pc),a0
		bsr	get_cpuregs

	;Dump contents of URP and SRP
print_mmur:	lea	number(pc),a0
		lea	urp_m(pc),a6
		lea	mmureg_contents(pc),a1

		moveq	#1,d7
.p_mmur:	move.l	(a1)+,d0
		bsr	bintohex
		bsr	print_a0
		adda.l	#srp_m-urp_m,a6
		dbra	d7,.p_mmur

	;Dump TC
		move.l	(a1)+,d0
		bsr	bintohex
		bsr	print_a0_nc
		bsr	print_tc_info		;Print extra info
		adda.l	#srp_m-urp_m,a6

	;Dump the four TTR's
		moveq	#3,d7
.p_ttr:		move.l	(a1)+,d0
		bsr	bintohex
		bsr	print_a0_nc
		bsr	print_ttr_info		;print extra info
		adda.l	#srp_m-urp_m,a6
		dbra	d7,.p_ttr

	;Dump the SFC and DFC
		moveq	#2,d7
.p_rest:	move.l	(a1)+,d0
		bsr	bintohex
		bsr	print_a0
		adda.l	#srp_m-urp_m,a6
		dbra	d7,.p_rest

	;Test if MMU is enabled and print the results
		lea	mmureg_contents(pc),a1
		move.l	cpur_tc(a1),d0
		lea	mmu_m(pc),a6
		btst	#tc_enable,d0
		bne.s	.mmu_en
	;If MMU is disabled, we wont give the user the option to dump the MMU-tree
		lea	disabled_m(pc),a0
		bsr	print_a0
		bra	quit
	;If the MMU is enabled, we give the user the option to dump the MMU-tree.
.mmu_en:	lea	enabled_m(pc),a0
.mmu_state:	bsr	print_a0
		lea	dump_tree_q(pc),a6
		bsr	print_a6
		move.w	#7,-(sp)
		trap	#1
		addq.l	#2,sp
		cmp.b	#"y",d0
		beq.s	.dodump
		cmp.b	#"Y",d0
		bne	quit

	;We're gonna dump the tree pointed to by the URP register
.dodump:	move.l	cpur_urp(a1),a0
		move.w	page_size,d0
		bsr	dump_mmu_tree	
		bra	quit

		data
dump_tree_q:	dc.b 13,10," Do you want to dump the MMU tree? (y/n)",13,10,0
		text

	;Dump info about the TC bit settings passed in D0
print_tc_info:	movem.l	d0-a6,-(sp)

	;-- print page size --
		lea	crlf(pc),a6
		bsr	print_a6
		lea	indent_m(pc),a6
		bsr	print_a6

		lea	pagesize_m(pc),a6
		move.l	d0,d2
		btst	#tc_pagesize,d2
		beq.s	.4k
		move.l	#8192,d0
		move.w	d0,page_size
		bra.s	.p_ps
.4k:		move.l	#4096,d0
		move.w	d0,page_size
.p_ps:		lea	number(pc),a0
		bsr	bintodec
		bsr	print_a0

	IFNE	mc060
		lea	indent_m(pc),a6

		btst	#tc_nad,d2
		beq.s	.no_nad
		lea	tc_nad_m(pc),a0
		bsr	print_a0

.no_nad:	btst	#tc_nai,d2
		beq.s	.no_nai
		lea	tc_nai_m(pc),a0
		bsr	print_a0
.no_nai:
		btst	#tc_fotc,d2
		beq.s	.fdc
		lea	tc_hdcm_m(pc),a0
		bra.s	.p_dcm
.fdc:		lea	tc_fdcm_m(pc),a0
.p_dcm:		bsr	print_a0

		btst	#tc_fitc,d2
		beq.s	.fic
		lea	tc_hicm_m(pc),a0
		bra.s	.p_icm
.fic:		lea	tc_ficm_m(pc),a0
.p_icm:		bsr	print_a0

		bsr	print_a6

		move.l	d2,d0
		move.l	#tc_dci_pos-2,d1
		lsr.l	d1,d2
		and.l	#%1100,d2
		lea	cachmode(pc),a0
		lea	tc_defic_m(pc),a6
		move.l	(a0,d2.l),a0
		addq.l	#1,a0
		bsr	print_a0

		lea	indent_m(pc),a6
		bsr	print_a6

		move.l	d0,d2
		move.l	#tc_dco_pos-2,d1
		lsr.l	d1,d2
		and.l	#%1100,d2
		lea	cachmode(pc),a0
		lea	tc_defdc_m(pc),a6
		move.l	(a0,d2.l),a0
		addq.l	#1,a0
		bsr	print_a0

		lea	indent_m(pc),a6
		btst	#tc_dwo,d0
		beq.s	.no_wp
		lea	tc_defwpon_m(pc),a0
		bra.s	.p_wp
.no_wp:		lea	tc_defwpof_m(pc),a0
.p_wp:		bsr	print_a0
	ENDC	;mc060

		movem.l	(sp)+,d0-a6
		rts		

		data

pagesize_m:	dc.b "page size is ",0
	IFNE	mc060
tc_nad_m:	dc.b "no allocate in data ATC",0
tc_nai_m:	dc.b "no allocate in inst ATC",0
tc_fdcm_m:	dc.b "full data ATC caching (64 entries)",0
tc_hdcm_m:	dc.b "1/2 data ATC caching (32 entries)",0
tc_ficm_m:	dc.b "full inst ATC caching (64 entries)",0
tc_hicm_m:	dc.b "1/2 inst ATC caching (32 entries)",0
tc_defdc_m:	dc.b "default data cache-mode -",0
tc_defic_m:	dc.b "default inst cache-mode -",0
tc_defwpon_m:	dc.b "Default writeprotect ON",0
tc_defwpof_m:	dc.b "Default writeprotect OFF",0
	ENDC	;mc060

		text
	;Print info about the TTR bit setting passed in D0
print_ttr_info:	movem.l	d0-a6,-(sp)

		btst	#ttr_enable,d0
		beq.s	.da
		lea	enabled_m(pc),a6
		bra.s	.p1
.da:		lea	disabled_m(pc),a6
.p1:		bsr	print_a6

		move.l	d0,d1
		move.l	#ttr_super_pos-2,d2
		lsr.l	d2,d1
		and.l	#%1100,d1
		lea	ttr_super_msgs(pc),a6
		move.l	(a6,d1.l),a6
		bsr	print_a6

		move.l	d0,d1
		move.l	#ttr_cache_pos-2,d2
		lsr.l	d2,d1
		and.l	#%1100,d1
		lea	cachmode(pc),a6
		move.l	(a6,d1.l),a6
		bsr	print_a6

		btst	#ttr_wp,d0
		beq.s	.no_wp
		lea	wp_m(pc),a6
		bsr	print_a6
.no_wp:		lea	crlf(pc),a6
		bsr	print_a6
		movem.l	(sp)+,d0-a6
		rts

		data
ttr_fc20_m:	dc.b ", Match only when FC2 = 0 (user mode)",0
ttr_fc21_m:	dc.b ", Match only when FC2 = 1 (super mode)",0
ttr_fcign_m:	dc.b ", Ignore FC2 when matching",0

		even
ttr_super_msgs:	dc.l ttr_fc20_m,ttr_fc21_m,ttr_fcign_m,ttr_fcign_m

		text

		include	..\common\getcpu_r.s

	;Terminate
quit:		pea	outro_m
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp
		clr.w	-(sp)
		trap	#1


	include	..\common\dumptree.s
	include	..\common\bintohex.s
	include	..\common\bintodec.s

		data
intro_m:	dc.b 13,10," MMUDump v0.6 (c) 1999 AssemSoft Productions",13,10
		dc.b "  Written in 100% Assembly, using DevPac",13,10,13,10
		dc.b "----------------------- DUMP  BEGIN -----------------------",13,10,13,10,0
outro_m:	dc.b 13,10,"-----------------------  DUMP  END  -----------------------",13,10,0

urp_m:		dc.b "URP    -> ",0
srp_m:		dc.b "SRP    -> ",0
tcr_m:		dc.b "TCR    -> ",0
itt0_m:		dc.b "ITTR 0 -> ",0
dtt0_m:		dc.b "DTTR 0 -> ",0
itt1_m:		dc.b "ITTR 1 -> ",0
dtt1_m:		dc.b "DTTR 1 -> ",0
sfc_m:		dc.b "SFC    -> ",0
dfc_m:		dc.b "DFC    -> ",0
cacr_m:		dc.b "CACR   -> ",0
indent_m:	dc.b "          ",0

mmu_m:		dc.b "Paged address translation is ",0
disabled_m:	dc.b " - disabled",0
enabled_m:	dc.b " - enabled",0



		bss
		even
page_size:	ds.w 1
mmureg_contents:ds.b cpur_ssize

		bss
		even
		ds.b	stack_size
newstack:	ds.l	1

		end
