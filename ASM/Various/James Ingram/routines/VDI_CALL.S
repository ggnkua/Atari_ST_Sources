* VDI Calls
*  by James Ingram, 1993


	ifd	link_library
	MODULE	VDI_CALLS
	XDEF	open_vwork,vwk_handle
	XDEF	close_vwork
	
	XREF	vdi
	XREF	get_res
	endc



open_vwork:
* open a virtual workstation!
* expect phys handle in d0
	move.w	d0,d7

	move.w	#2,-(a7)

	moveq	#8,d0
open_vwork_loop:
	move.w	#1,-(a7)
	dbra	d0,open_vwork_loop

	bsr	get_res
	addq.w	#2,d0
	move.w	d0,-(a7)

	move.w	d7,-(a7)

	move.w	#vdi_open_virtual_workstation,-(a7)
	bsr	vdi

	move.w	d0,vwk_handle

	rts


close_vwork:
* Close a virtual workstation!
	move.w	#vdi_close_virtual_workstation,-(a7)
	bsr	vdi
	rts



	ifd	link_library
	section	bss
	endc

vwk_handle:
	ds.w	1




