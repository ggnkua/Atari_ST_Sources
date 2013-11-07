*-------------------------------------------------------*
			text
*-------------------------------------------------------*

page_size		=	8192

*-------------------------------------------------------*
initialise_pmmu:
*-------------------------------------------------------*
	move.l		#-1,bss_handle
	move.l		#-1,display_handle
	ifd		use_xmmu
	move.l		#'XMMU',d0
	bsr		cookie_search
	tst.l		d0
	bmi.s		.npmu
	move.l		4(a0),a0
	move.l		pmmu_read(a0),pmmu_read_rout
	move.l		pmmu_write(a0),pmmu_write_rout
	move.l		pmmu_cmc(a0),pmmu_cbc_rout
	move.l		pmmu_cmn(a0),pmmu_noc_rout
	bsr		mark_bss
	bsr		mark_display
	endc
.npmu:	rts

*-------------------------------------------------------*
mark_bss:
*-------------------------------------------------------*
*	Allocate space for BSS pages			*
*-------------------------------------------------------*
	lea		bss_start,a0
	lea		bss_all_end,a1
	moveq		#13,d2
	move.l		a0,d0
	move.l		a1,d1
	add.l		#page_size-1,d1
	lsr.l		d2,d0
	lsr.l		d2,d1
	sub.l		d0,d1
	lsl.l		#2,d1
	move.l		d1,d0
	movem.l		a0-a1,-(sp)
	moveq		#VRAM_preferred,d1
	bsr		allocate_chunk
	movem.l		(sp)+,a0-a1
	tst.l		d0
	ble.s		.nbss
	move.l		d0,bss_handle
	move.l		d0,a2
	movem.l		a0-a2,-(sp)
	jsr		([pmmu_read_rout.l])
	movem.l		(sp)+,a0-a2
	jsr		([pmmu_cbc_rout.l])
.nbss:	rts

*-------------------------------------------------------*
mark_display:
*-------------------------------------------------------*
*	Allocate space for display pages		*
*-------------------------------------------------------*
	move.l		display_start,a0
	move.l		display_size,d0
	lea		(a0,d0.l),a1
	moveq		#13,d2
	move.l		a0,d0
	move.l		a1,d1
	add.l		#page_size-1,d1
	lsr.l		d2,d0
	lsr.l		d2,d1
	sub.l		d0,d1
	lsl.l		#2,d1
	move.l		d1,d0
	movem.l		a0-a1,-(sp)
	moveq		#VRAM_preferred,d1
	bsr		allocate_chunk
	movem.l		(sp)+,a0-a1
	tst.l		d0
	ble.s		.ndsp
	move.l		d0,display_handle
	move.l		d0,a2
	movem.l		a0-a2,-(sp)
	jsr		([pmmu_read_rout.l])
	movem.l		(sp)+,a0-a2
	jsr		([pmmu_noc_rout.l])
.ndsp:	rts

*-------------------------------------------------------*
restore_pmmu:
*-------------------------------------------------------*
	bsr		unmark_bss
	bsr		unmark_display
	rts

*-------------------------------------------------------*
unmark_bss:
*-------------------------------------------------------*
	move.l		bss_handle,d0
	ble.s		.err
	move.l		d0,a2
	lea		bss_start,a0
	lea		bss_all_end,a1
	jsr		([pmmu_write_rout.l])
	move.l		bss_handle,d0
	bsr		deallocate_chunk
.err	rts

*-------------------------------------------------------*
unmark_display:
*-------------------------------------------------------*
	move.l		display_handle,d0
	ble.s		.err
	move.l		d0,a2
	move.l		display_start,a0
	move.l		display_size,d0
	lea		(a0,d0.l),a1
	jsr		([pmmu_write_rout.l])
	move.l		display_handle,d0
	bsr		deallocate_chunk
.err	rts

*---------------------------------------------------------------*
cookie_search:
*---------------------------------------------------------------*
	move.l		cookie_jar.w,a0
.loop:	cmp.l		(a0),d0
	beq.s		.find
	tst.l		(a0)
	beq.s		.fail
	addq.l		#8,a0
	bra.s		.loop
.find:	moveq		#0,d0
	bra.s		.end
.fail:	moveq		#-1,d0
.end:	rts

*-------------------------------------------------------*
			bss
*-------------------------------------------------------*
			
pmmu_resident:		ds.l	1
pmmu_read_rout:		ds.l	1
pmmu_write_rout:	ds.l	1
pmmu_cbc_rout:		ds.l	1
pmmu_noc_rout:		ds.l	1
bss_handle:		ds.l	1
display_handle:		ds.l	1

*-------------------------------------------------------*
			text
*-------------------------------------------------------*
			