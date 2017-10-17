*********************************************************************************
* TAB Setting = 8								*
*										*
* 	Program: SET_MMU							*
* 	Version: 0.7 beta							*
*	Purpose: Translation Tree builder for 040/060.				*
*	Author:  Odd Skancke - AssemSoft productions.				*
*	Status:  FreeWare - Only to be distributed with MiNT kernel releases.	*
*										*
* SET_MMU is a small program that is run from the AUTO folder. When run, it	*
* reads a configuration file, MMUSETUP.CNF, from which it builds a Translation	*
* Tree and obtains other CPU settings. Developed especially for Hades on a 	*
* Hades 060.									*
*										*
* These sources was created with QED for use with GenTT.ttp assembler (DevPac)	*
*										*
*********************************************************************************
mc060:	= 0	;Set to 0 to assemble for 040, 1 to assemble for 060.
		;If enuff complaints arrive, I will include routines to check
		;the _CPU cookie. 

		comment HEAD=1
		opt p=68040

	include	..\header\mmudefs.h
	include	..\header\gemdos.h
	include	..\header\keys.h
	include	..\header\atari.h
	include	parseblk.h

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

		bsr	turn_off_all		

		pea	start_mess
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp

		bsr	read_config
		bcc	error_terminate

		tst.w	splitram_f
		beq.s	.no_split

		bsr	split_ram

.no_split:	move.l	conf_blkstart(pc),a0
		move.w	conf_entries(pc),d0
		beq	tq
		subq.w	#1,d0
		lea	mmu_tree(pc),a1

.cpy_allcnf:	move.w	#(parsd_ssize/2)-1,d1
.cpy_pcnf:	move.w	(a0)+,(a1)+
		dbra	d1,.cpy_pcnf
		dbra	d0,.cpy_allcnf

		move.l	a1,d0
		add.l	#~msk_rootp_addr,d0
		and.l	#msk_rootp_addr,d0
		move.l	d0,root_table
		move.l	#mmu_tree,conf_blkstart
		bsr	print_config

		bsr	mmusetup
		bcc	error_terminate

		bsr	mmu_start

		move.l	next_free(pc),d0
		sub.l	#start_up,d0
		add.l	#$100,d0

		clr	-(a7)
		move.l	d0,-(sp)
		move.w	#49,-(sp)
		trap	#1

error_terminate:lea	et_m(pc),a6
		bsr	print_a6
		lea	key_m(pc),a6
		bsr	print_a6
		move.w	#7,-(sp)
		trap	#1
		addq.l	#2,sp

tq:		clr.w	-(sp)
		trap	#1

		data
start_mess:	dc.b 13,10,"**************************************************"
		dc.b 13,10,"*  Set MMU v0.7b (c)1999 AssemSoft Productions   *"
		dc.b 13,10,"* Translation Tree Builder for the Hades040/060  *"
		dc.b 13,10,"**************************************************",13,10,0
et_m:		dc.b "Set MMU -> Mission aborted!! - no tranlation tree built!",13,10,0
key_m:		dc.b "Set MMU -> Press a key to resume!",13,10,0

		text

split_ram:	clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,-(sp)
		move.w	#$20,-(sp)

		move.l	ramtop.w,d2
		bne.s	.already_set
		move.l	reset_pc.w,a2
		move.l	phystop.w,ramtop.w
		move.l	#$00e00000,phystop.w
		move.l	phystop.w,_memtop.w

		jmp	(a2)
.already_set:	
.exit:		trap	#1
		addq.l	#6,sp
		rts

		include	intepret.s

;------------------------------------------------------
print_config:	movem.l	d0-a6,-(sp)

		lea	crlf_m(pc),a6
		jsr	print_a6

		lea	setps_m(pc),a6
		moveq	#0,d0
		move.w	page_size(pc),d0
		jsr	bintodec
		jsr	print_a0

		lea	setitt0_m(pc),a6
		move.l	set_itt0(pc),d0
		jsr	bintohex
		jsr	print_a0

		lea	setdtt0_m(pc),a6
		move.l	set_dtt0(pc),d0
		jsr	bintohex
		jsr	print_a0

		lea	setitt1_m(pc),a6
		move.l	set_itt1(pc),d0
		jsr	bintohex
		jsr	print_a0

		lea	setdtt1_m(pc),a6
		move.l	set_dtt1(pc),d0
		jsr	bintohex
		jsr	print_a0

		lea	setcacr_m(pc),a6
		move.l	set_cacr(pc),d0
		jsr	bintobin
		jsr	print_a0

		lea	crlf_m(pc),a6
		jsr	print_a6

		;bra.s	.exit

		move.l	conf_blkstart(pc),a3
		move.w	conf_entries(pc),d3
		beq	.exit
		subq.w	#1,d3

.print_conf:	move.l	parsd_lstart(a3),d0
		lea	setlog_m(pc),a6
		jsr	bintohex
		jsr	print_a0

		move.l	parsd_pstart(a3),d0
		lea	setphys_m(pc),a6
		jsr	bintohex
		jsr	print_a0

		move.l	parsd_blksize(a3),d0
		lea	setsize_m(pc),a6
		jsr	bintodec
		jsr	print_a0

		move.l	parsd_pdflags(a3),d0
		lea	setpd_m(pc),a6
		jsr	bintobin
		jsr	print_a0

		move.l	parsd_mcpy_s(a3),d0
		lea	setmcpys_m(pc),a6
		jsr	bintohex
		jsr	print_a0
		move.l	parsd_mcpy_d(a3),d0
		lea	setmcpyd_m(pc),a6
		jsr	bintohex
		jsr	print_a0
		move.l	parsd_mcpy_size(a3),d0
		lea	setmcpysiz_m(pc),a6
		jsr	bintodec
		jsr	print_a0

		lea	crlf_m(pc),a6
		jsr	print_a6
		lea	parsd_ssize(a3),a3
		dbra	d3,.print_conf

.exit:		movem.l	(sp)+,d0-a6
		rts		

		data
setps_m:	dc.b "Page Szie      -> ",0
setitt0_m:	dc.b "itt0           -> ",0
setdtt0_m:	dc.b "dtt0           -> ",0
setitt1_m:	dc.b "itt1           -> ",0
setdtt1_m:	dc.b "dtt1           -> ",0
setcacr_m:	dc.b "cacr           -> ",0
setlog_m:	dc.b "Logical Start  -> ",0
setphys_m:	dc.b "Physical start -> ",0
setsize_m:	dc.b "Size of block  -> ",0
setpd_m:	dc.b "Initial pdf    -> ",0
setmcpys_m:	dc.b "mcpy - source  -> ",0
setmcpyd_m:	dc.b "mcpy - destin  -> ",0
setmcpysiz_m:	dc.b "mcpy - size    -> ",0
;----------------------------------------------------------
		text
;------------------------------------------------------------
print_a0:	movem.l	d0-a6,-(sp)

		move.l	a6,-(sp)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp

		movem.l	(sp),d0-a6

		move.l	a0,-(sp)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp

		pea	.crlf
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp

.exit:		movem.l	(sp)+,d0-a6
		rts
.crlf:		dc.b 13,10,0,0

print_a0_nc:	movem.l	d0-a6,-(sp)

		move.l	a6,-(sp)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp

		movem.l	(sp),d0-a6
		move.l	a0,-(sp)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp

.exit:		movem.l	(sp)+,d0-a6
		rts

print_a6:	movem.l	d0-a6,-(sp)

		move.l	a6,-(sp)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp

		movem.l	(sp)+,d0-a6
		rts
;---------------------------------------------------------

mmu_start:	movem.l	d0-a6,-(sp)

		clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,-(sp)


		moveq	#0,d0
		movec	d0,cacr
		cpusha	bc
		nop
	IFNE	mc060
		move.l	#$210,d0
	ELSEIF	;mc060
		moveq	#0,d0
	ENDC	;mc060
		movec	d0,tc
		pflusha
		nop
		moveq	#0,d0
		movec	d0,itt0
		movec	d0,dtt0
		movec	d0,itt1
		movec	d0,dtt0

		move.l	root_table(pc),d0
		movec	d0,urp
		movec	d0,srp

	;	moveq	#2,d0
	;	movec	d0,dfc
	;	nop
	;	pflusha
	;	moveq	#6,d0
	;	movec	d0,dfc
	;	nop
	;	pflusha

		;move.l	#($8000<<16)|(1<<ttr_enable)|(%10<<ttr_super_pos)|(c_writetrough<<ttr_cache_pos),d0
		;movec	d0,itt0
		;movec	d0,dtt0
		;move.l	#($803f<<16)|(1<<ttr_enable)|(%10<<ttr_super_pos)|(c_precise<<ttr_cache_pos),d0
		;movec	d0,itt1
		;movec	d0,dtt1		

		move.l	set_itt0(pc),d0
		movec	d0,itt0
		move.l	set_dtt0(pc),d0
		movec	d0,dtt0
		move.l	set_itt1(pc),d0
		movec	d0,itt1
		move.l	set_dtt1(pc),d0
		movec	d0,dtt1

		move.l	set_cacr(pc),d0
	IFEQ	mc060
		and.l	#(1<<31)|(1<<15),d0
	ENDC	;mc060
		movec	d0,cacr

	IFEQ	mc060
		move.l	#(1<<tc_enable),d0
	ELSEIF	;mc060
		move.l	#(1<<tc_enable)|(c_precise<<tc_dco_pos)|(c_precise<<tc_dci_pos),d0	;|(1<<tc_nad)|(1<<tc_nai)|(1<<tc_fotc)|(1<<tc_fitc),d0
	ENDC	;mc060
		cmp.w	#8192,page_size
		bne.s	.no_8k
		or.l	#1<<tc_pagesize,d0
.no_8k:		movec	d0,tc

	IFNE	mc060
		moveq	#1,d0
		dc.w	$4e7b,$808	;movec d0,pcr
	ENDC	;mc060

		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp

		movem.l	(sp)+,d0-a6
		rts

turn_off_all:	movem.l	d0-a6,-(sp)

		move.l	#0,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,-(sp)
		move.w	#$20,-(sp)

		moveq	#0,d0
		movec	d0,cacr
		cpusha	bc
		nop

	IFNE	mc060
		move.l	#$210,d0
	ELSEIF	;mc060
		moveq	#0,d0
	ENDC	;mc060
		movec	d0,tc
		move.l	#1<<6,d0
		movec	d0,itt0
		movec	d0,itt1
		movec	d0,dtt0
		movec	d0,dtt1
		pflusha
		nop
		trap	#1
		addq.l	#6,sp
		movem.l	(sp)+,d0-a6
		rts



;=======================================================

;=======================================================
mmusetup:
make_mmu_tree:
		move.l	root_table(pc),a0
		move.l	a0,d0
		add.l	#~msk_rootp_addr+1,d0
		move.l	d0,next_free
		moveq	#127,d0
.clear_root:	clr.l	(a0)+
		dbra	d0,.clear_root

	;	move.l	root_table(pc),a0
	;	move.l	stram_start_l(pc),d0
	;	move.l	stram_start_p(pc),d1
	;	move.l	stram_size(pc),d2
	;	move.l	stram_mode(pc),d3
	;	bsr	create_table

	;	move.w	#8192,page_size

		move.l	root_table(pc),a0
		move.l	conf_blkstart(pc),a1
		move.w	conf_entries(pc),d7
		subq.w	#1,d7

.build_tt:	move.l	parsd_lstart(a1),d0
		move.l	parsd_pstart(a1),d1
		move.l	parsd_blksize(a1),d2
		move.l	parsd_pdflags(a1),d3
		bsr	create_table
		bcc.s	.error
		bsr	mcpy_check
		lea	parsd_ssize(a1),a1
		dbra	d7,.build_tt
		or.b	#1,ccr
		rts

.error:		lea	overlap_m(pc),a6
		bsr	print_a6
		and.b	#-2,ccr
		rts

mcpy_check:	movem.l	d0-a6,-(sp)

		move.l	a1,a6
		move.l	#0,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,-(sp)
		move.w	#$20,-(sp)

		move.w	sr,-(sp)
		move.w	#$2700,sr

		move.l	a6,a1
		move.l	parsd_mcpy_size(a1),d0
		beq.s	.exit
		movea.l	parsd_mcpy_s(a1),a2
		movea.l	parsd_mcpy_d(a2),a3

.cpy:		move.l	(a2)+,(a3)+
		subq.l	#4,d0
		bne.s	.cpy

.exit:		move.w	(sp)+,sr
		trap	#1
		addq.l	#6,sp
		movem.l	(sp)+,d0-a6
		rts

		data
overlap_m:	dc.b 13,10,"Set MMU -> Two block overlapped eachother!!",13,10
		dc.b "Set MMU -> Check your configuration and try again",13,10,0
		text
;===============================================================================

;Input
	;D0 = Logical start address
	;D1 = Physical start address
	;D2 = Size of block (must be divisible by page size)
	;D3 = Mode of this block.

create_table:	movem.l	d0-a6,-(sp)
	;Check page size and clear the bits we dont want to be set in the page-descriptors.
		cmp.w	#8192,page_size
		beq.s	.ini_8kp
		and.l	#(1<<d_writeprotect)|(3<<d_cache_pos)|(1<<d_super)|(1<<d_u0)|(1<<d_u1)|(1<<d_global)|(1<<d_ur0),d3
		bra.s	.create_more
.ini_8kp:	and.l	#(1<<d_writeprotect)|(3<<d_cache_pos)|(1<<d_super)|(1<<d_u0)|(1<<d_u1)|(1<<d_global)|(1<<d_ur0)|(1<<d_ur1),d3

	;Take the logical address and create offsets into root and pointer tables
	;D4 = index into root table
	;D5 = Index into pointer table
.create_more:	move.l	d0,d4
		rol.l	#7,d4
		and.l	#%1111111,d4
		lsl.w	#2,d4
		move.l	d0,d5
		swap	d5
		and.l	#%111111100,d5

	;Get root-table descriptor, contains base-address of the poiner table to use.
		move.l	(a0,d4.l),d6

	;Check if the descriptor is valid. (or resident). 
		move.b	d6,d7
		and.b	#2,d7			;Check udp field.
		bne.s	.pnttab_there		;This descriptor is valid
	;The pointer table has to be created..
		bsr	create_pointertable

	;The root descriptor is the base address to the poitner table.
	;Now get the pointer table descriptor, using the intex in D5
.pnttab_there:	and.l	#msk_pnttab_addr,d6	;Maks out the pointer table base address in root descriptor
		move.l	d6,a1			;Pointer table base address in A1
		move.l	(a1,d5.l),d6		;Get pointer table descriptor out of the pointer table

	;Is this pointer table descriptor valid? Now it means that the page table does not
	;yet exist if not valid.
		move.b	d6,d7
		and.b	#2,d7
		bne.s	.pagtab_there
	;Create new page table
		bsr	create_pagetable

	;The pointer table descriptor contains the base address of the page table we need.
	;First check if we use 8Kb or 4Kb pages..
.pagtab_there:	cmp.w	#8192,page_size
		beq.s	.8k_page

	;4k pages
	;Ok, now mask out the base address of the page table in the pointer table descriptor
		and.l	#msk_4kpt_addr,d6
		move.l	d6,a2			;A2 = Base address of page table
		move.l	d0,d6			;We need the index into the page table,
						;taken from the logial address

	;Bits 12 - 17 of the logical address contains the page table index for 4K pages.
		lsl.l	#6,d6			;Shift bit 12 to bit 18 (into high word + 2 to mul by 4)
		swap	d6			;Now page index is at correct bit location
		and.l	#%11111100,d6		;Mask out the index
		move.l	(a2,d6.l),d4		;Get page descriptor
		and.b	#3,d4			;Is this descriptor already used?
		bne.s	.overlap_error		;Yes, we can't allow that.

	;Now we can setup this page descriptor to point to the desired physical address
	;and or in the desired descriptor bits/modes (cache mode and such)
		move.l	d1,d4			;D1 contains the physical address
		and.l	#msk_4kpd_paddr,d4	;Mask off excessive bits
		or.b	#1,d4			;Make descriptor valid
		or.w	d3,d4			;OR in the mode
		move.l	d4,(a2,d6.l)		;Store this descriptor

	;Now we add the size of the page to the logical/phyical addresses
	;and subtract page size from size of block to setup in this pass.
		add.l	#1024*4,d0		;Next logical address
		add.l	#1024*4,d1		;Next physical address
		sub.l	#1024*4,d2		;Block of memory covered by this page
		bhi	.create_more		;There's more, just loop
		bra.s	.ok_done		;Ok, done.

	;Exactly the same as above, but for 8Kb pages..
.8k_page:	and.l	#msk_8kpt_addr,d6
		move.l	d6,a2
		move.l	d0,d6
		lsl.l	#5,d6
		swap	d6
		and.l	#%1111100,d6
		move.l	(a2,d6.l),d4
		and.b	#3,d4
		bne.s	.overlap_error

	;8k page init
		move.l	d1,d4
		and.l	#msk_8kpd_paddr,d4
		or.b	#1,d4
		or.w	d3,d4
		move.l	d4,(a2,d6.l)
		add.l	#1024*8,d0
		add.l	#1024*8,d1
		sub.l	#1024*8,d2
		bhi	.create_more

.ok_done:	movem.l	(sp)+,d0-a6
		or.b	#1,ccr
		rts

.overlap_error:	and.b	#-2,ccr
		movem.l	(sp)+,d0-a6
		rts

;Create a new pagetable (pointer leve descriptor), clear it and return the
;address in D6 and store address in the pointer table at (a1,d5.l)
;	A0 = root table
;	A1 = pointer table
;	D4 = root table index
;	D5 = pointer table index
create_pagetable:
		move.l	next_free(pc),d7		;Address of next free location
		move.l	d7,d6
		cmp.w	#8192,page_size
		beq.s	.8kp

	;Create 4k page table
.4kp:		and.l	#~msk_4kpt_addr,d6		;Already on a "size of 4K page-table" boundary?
		beq.s	.4kp_nf_ok			,Yes
		add.l	#(~msk_4kpt_addr)+1,d7		;Add size of page table..
		and.l	#msk_4kpt_addr,d7		;..then align to size of pagetable.
.4kp_nf_ok:	move.l	d7,d6				;D6 = Base address of new page table
		add.l	#(~msk_4kpt_addr)+1,d7		;Update the next_free pointer
		move.l	d7,next_free			;Save
		move.l	d6,a2				;A2 = Base address of new page table
		or.b	#2,d6				;Or in %10 in the PDT field
		move.l	d6,(a1,d5.l)			;Store this descriptor in the pointer table (pointer level)
		moveq	#(((~msk_4kpt_addr)+1)/4)-1,d7	;Size of page table / 4
.4kp_clr_pt:	clr.l	(a2)+				;Make sure all descriptors in the new page table are invalidated
		dbra	d7,.4kp_clr_pt
		rts

	;Create 8K page table .. same as for the 4K page table, but.. heheh.
.8kp:		and.l	#~msk_8kpt_addr,d6
		beq.s	.8kp_nf_ok
		add.l	#(~msk_8kpt_addr)+1,d7
		and.l	#msk_8kpt_addr,d7
.8kp_nf_ok:	move.l	d7,d6
		add.l	#(~msk_8kpt_addr)+1,d7
		move.l	d7,next_free
		move.l	d6,a2
		or.b	#2,d6
		move.l	d6,(a1,d5.l)
		moveq	#(((~msk_8kpt_addr)+1)/4)-1,d7		
.8kp_clr_pt:	clr.l	(a2)+
		dbra	d7,.8kp_clr_pt
		rts

	;A0 = root table base
	;D4 = root table index
	;D5 = Pointer table index

	;Return new pointertable base in D6, and store it in the root-table at (a0,d4.l)
create_pointertable:
		move.l	next_free(pc),d7			;Get next free location
		move.l	d7,d6
		and.l	#~msk_pnttab_addr,d6			;Already on 512 byte boundary?
		beq.s	.nf_ok					;yes
	;Fix address to next whole 512 byte boudary
		add.l	#(~msk_pnttab_addr)+1,d7
		and.l	#msk_pnttab_addr,d7
.nf_ok:		move.l	d7,d6
		add.l	#(~msk_pnttab_addr)+1,d7		;Add the bytes needed (512)
		move.l	d7,next_free
		move.l	d6,a1
		or.b	#2,d6
		move.l	d6,(a0,d4.l)
		moveq	#(((~msk_pnttab_addr)+1)/4)-1,d7

.clr_pt:	clr.l	(a1)+
		dbra	d7,.clr_pt
		rts

	include	..\common\bintohex.s
	include	..\common\bintodec.s
	include	..\common\bintobin.s

		bss
cnf_cpur_b:
splitram_f:	ds.w 1
page_size:	ds.w 1
set_itt0:	ds.l 1
set_dtt0:	ds.l 1
set_itt1:	ds.l 1
set_dtt1:	ds.l 1
set_cacr:	ds.l 1
cnf_cpur_e:	ds.l 0

		even
root_table:	ds.l 1
next_free:	ds.l 1
		ds.b 128*5
mmu_tree:	ds.b (128*4)
		ds.b 4*1024*1024

		ds.b 4*1024
newstack:	ds.b 4
		end 		
