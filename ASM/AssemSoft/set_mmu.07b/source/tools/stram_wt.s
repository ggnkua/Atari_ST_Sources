*********************************************************************************
* TAB Setting = 8								*
*										*
* 	Program: STRAM_WT							*
* 	Version: 0.2								*
*	Purpose: Translation Tree cache-mode = Write Trough  setter		*
*	Author:  Odd Skancke - AssemSoft productions.				*
*	Status:  FreeWare - Only to be distributed with MiNT kernel releases.	*
*										*
* STRAM_WT is a small tool that sets cache mode to Write Trough in page		*
* descriptors from logical address 0x00000000 up to 0x00E00000 (ST RAM area)	*
*										*
* These sources was created with QED for use with GenTT.ttp assembler (DevPac)	*
*										*
*********************************************************************************
		comment HEAD=1
		opt p=68040

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

		lea	regs(pc),a0
		bsr	get_cpuregs
		move.l	cpur_tc(a0),d0
		btst	#tc_enable,d0
		beq.s	terminate

		clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		move.l	d0,-(sp)
		move.w	#$20,-(sp)

		movec	cacr,d0
		move.l	d0,-(sp)
		moveq	#0,d0
		movec	d0,cacr
		cpusha	bc
		nop
		pflusha
		nop

		lea	regs(pc),a0
		move.l	cpur_urp(a0),a0
		moveq	#0,d0
		move.l	#14*1024*1024,d2
		moveq	#1,d1
		move.l	#(c_writetrough<<d_cache_pos),pd_flags
		move.l	#(3<<d_cache_pos),pd_mask

		move.w	#8192,page_size
		bsr	set_mmu_tree
		move.l	(sp)+,d0
		movec	d0,cacr

		trap	#1
		addq.l	#6,sp

terminate:	clr.l	-(sp)
		trap	#1

		include	..\common\getcpu_r.s

	;a0 = root table
	;D0 = Physical address
	;d2 = Size of block to modify

set_mmu_tree:
	;Check page size and clear the bits we dont want to be set in the page-descriptors.
		cmp.w	#8192,page_size
		beq.s	.ini_8kp
		and.l	#(1<<d_writeprotect)|(3<<d_cache_pos)|(1<<d_super)|(1<<d_u0)|(1<<d_u1)|(1<<d_global)|(1<<d_ur0),pd_flags
		and.l	#(1<<d_writeprotect)|(3<<d_cache_pos)|(1<<d_super)|(1<<d_u0)|(1<<d_u1)|(1<<d_global)|(1<<d_ur0),pd_mask
		not.l	pd_mask

		bra.s	.create_more
.ini_8kp:	and.l	#(1<<d_writeprotect)|(3<<d_cache_pos)|(1<<d_super)|(1<<d_u0)|(1<<d_u1)|(1<<d_global)|(1<<d_ur0)|(1<<d_ur1),pd_flags
		and.l	#(1<<d_writeprotect)|(3<<d_cache_pos)|(1<<d_super)|(1<<d_u0)|(1<<d_u1)|(1<<d_global)|(1<<d_ur0)|(1<<d_ur1),pd_mask
		not.l	pd_mask


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
	;No pointer  table! - ERROR
		and.b	#-2,ccr
		rts

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
	;No pointer table! - ERROR
		and.b	#-2,ccr
		rts

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
		beq.s	.pd_error		;Yes, we can't allow that.

	;Check if indirect here..

		bsr.s	.mod_pd_flags

	;Now we add the size of the page to the logical/phyical addresses
	;and subtract page size from size of block to setup in this pass.
.no_4kpd_mod:	add.l	#1024*4,d0		;Next logical address
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
		beq.s	.pd_error

	;Check for indirect here..

		bsr	.mod_pd_flags

		add.l	#1024*8,d0
		add.l	#1024*8,d1
		sub.l	#1024*8,d2
		bhi	.create_more

.ok_done:	or.b	#1,ccr
		rts

.pd_error:	and.b	#-2,ccr
		rts

.mod_pd_flags:	move.l	pd_mask(pc),d7
		and.l	d7,(a2,d6.l)
		move.l	pd_flags(pc),d7
		or.l	d7,(a2,d6.l)
.no_pd_mod:	rts


		bss
pd_flags:	ds.l 1	;Page descriptor flags
pd_mask:	ds.l 1	;Page descriptor mask

page_size:	ds.w 1
regs:		ds.b cpur_ssize

		ds.b 4*1024
newstack:	ds.l 1

		end
