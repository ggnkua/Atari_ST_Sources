
vbl	=	$70

*-----------------------------------------------------------------*
keep_video:
*-----------------------------------------------------------------*
	jsr		Get_KV_monitor
	sf		fs_installed

	lea		$B8.w,a0	; trap #14
	move.l	#'äFSC',d0	; Fs cookie.
	bsr		FindXbra
	cmp.l		#0,a0
	beq.s		.nofs
	st		fs_installed

.nofs	tst.b		KV_VGA_FLAG
	bne.s		.no0
	st		compat_mode
.no0	push.w	#-1
	push.w	#88
	trap		#14
	addq		#4,sp
	move.w	d0,GEM_MODECODE
	tst.b		force_hard
	beq.s		.nx
	sf		compat_mode
.nx	lea		read_regs,a0
	bsr		vbi_call
	rts
	
vbi_call:
	move.l	a0,vbl_callcode
	nop
	move.b	#2,vblflag
	nop
	move.l	vbl.w,vbl_exit
	nop
	move.l	#vbl_setup,vbl.w
.wvb:	nop
	tst.b		vblflag
	bne.s		.wvb
	rts	
	
vbl_exit:	ds.l	1
vblflag:	ds.l	1

Get_KV_monitor:
	sf		KV_VGA_FLAG
	push.w	#89
	trap		#14
	addq		#2,sp
	tst.w		d0
	beq.s		.mono
	cmp.w		#2,d0
	seq		KV_VGA_FLAG
	moveq		#0,d0
	rts
.mono	moveq		#-1,d0
	rts

*-----------------------------------------------------------------*
unkeep_video:
*-----------------------------------------------------------------*
	move.w	GEM_MODECODE,d1
	and.w		#compat,d1
	bne		.compset
	tst.b		compat_mode
	bne.s		.compset
	pea		(a0)
	pea		(a0)
	push.w	#37
	trap		#14
	addq		#2,sp
	pop.l		d0
	move.b	d0,d1
	lsr.w		#8,d0
	move.l	d0,$FFFF8200.w
	move.b	d1,$FFFF820D.w
	lea		video_kept,a0
	jsr		setmode
	pop.l		a0
	move.w	GEM_MODECODE,d0
	and.w		#7,d0
	cmp.w		#bpl1,d0
	bne.s		.rts
	tst.b		fs_installed
	beq.s		.rts
.compset
	push.l	a0
	push.w	GEM_MODECODE
	push.w	#-1
	push.l	a0
	push.l	a0
	push.w	#5
	trap		#14
	lea		12(sp),sp
	push.w	#88
	trap		#14
	addq		#4,sp
	pop.l		a0
.rts	rts

setmode:
	move.l	a0,reg_buffer
	lea		write_regs,a0
	bsr		vbi_call
	rts

vbl_setup:
	tst.b		vblflag
	bne.s		.dec
	pushall
	jsr		([vbl_callcode.l])
	popall
	move.l	vbl_exit,vbl.w
	nop
	jmp		([vbl_exit.l])
.dec:	subq.b	#1,vblflag
	jmp		([vbl_exit.l])

read_regs:
	move.l	$FFFF8264.w,d1
	movem.l	$FFFF8282.w,d2-5 
	movem.l	$FFFF82A2.w,a0/d6-d7
	move.l	$FFFF82C0.w,a1
	move.w	$FFFF820A.w,a2
	move.l	$FFFF820E.w,d0
	movem.l	a0-2/d0-7,video_kept
	rts
	
write_regs:
	move.l	reg_buffer,a3	
	movem.l	(a3),a0-2/d0-7
	move.l	d1,$FFFF8264.w
	movem.l	d2-5,$FFFF8282.w
	movem.l	a0/d6-7,$FFFF82A2.w
	move.l	a1,$FFFF82C0.w
	move.w	a2,$FFFF820A.w
	move.l	d0,$FFFF820E.w
	rts

vbl_callcode:	ds.l		1
reg_buffer:		ds.l		1

*-----------------------------------------------------------------*
set_video:
*-----------------------------------------------------------------*
	tst.b		compat_mode
	bne.s		.compset
	and.w		#$7FFF,d0
	moveq		#-1,d7
	tst.b		KV_VGA_FLAG
	beq.s		.rgb
	bclr		#pal_bit,d7
	bclr		#os_bit,d7
.rgb	and.w		d7,d0
	lea		video_modes,a1
.next	move.w	(a1)+,d1
	cmp.w		#-1,d1
	beq.s		.rts
	and.w		d7,d1
	cmp.w		d0,d1
	beq.s		.go
	lea		46-2(a1),a1
	bra.s		.next	
.go	move.l	a1,video_list
	move.l	a0,d0
	move.b	d0,d1
	lsr.w		#8,d0
	move.l	d0,$FFFF8200.w
	move.b	d1,$FFFF820D.w
;	movem.l	([video_list.l]),a0-2/d0-7
	move.l	a1,a0
	jsr		setmode
	bra.s		.rts
.compset
	push.w	d0
	push.w	#-1
	push.l	a0
	push.l	a0
	push.w	#5
	trap		#14
	lea		12(sp),sp
	push.w	#88
	trap		#14
	addq		#4,sp
.rts	rts

		IFD		REMOVE_FS

*--------------------------------------------------------------------------*
* Fix up FS XBRA on trap #14 handler. We don't remove the XBRA as this could
* cause us later hassels finding it again in the case of a multitasking
* environment - things could be moved or removed. Instead we patch the FS
* XBRA code to do a straight jump through ( Saving the original code of
* course for later replacement )
*
* This method is maybe a bit Paranoid, but it should always work.
*--------------------------------------------------------------------------*
RemoveFS:	movem.l	a2-a6/d2-d7,-(sp)
		move.w	sr,d0
		move.w	d0,-(sp)
		move.w	#$2700,sr	; make sure nothing can mess us up.
		lea		$B8.w,a0	; trap #14
		move.l	#'äFSC',d0	; Fs cookie.
		bsr		FindXbra
		cmp.l		#0,a0
		beq.s		.out
		st		compat_mode
		move.l	a0,FS_CodeP
		lea		FS_Code,a1
		move.l	(a0),(a1)+
		move.l	4(a0),(a1)+
		lea		FS_NewCode,a2
		lea		-4(a0),a3
		move.l	a3,2(a2)	; fix up -> in "move.l" instr
		move.l	(a2)+,(a0)+
		move.l	(a2)+,(a0)+
.out:		move.w	(sp)+,d0
		move.w	d0,sr
		movem.l	(sp)+,a2-a6/d2-d7
		rts

****
* Code to patch over old XBRA.
****
FS_NewCode:	move.l	FS_NewCode,-(sp)
		rts
FS_NewCodeE:

****
* Necessary vars..
****
		BSS
FS_CodeP:	ds.l		1
FS_Code:	ds.w		6
		TEXT

*--------------------------------------------------------------------------*
* Restore FS onto trap #14 handler.. Just copy's back old image of code.
*--------------------------------------------------------------------------*
RestoreFS:	movem.l	a2-a6/d2-d7,-(sp)
		move.w	sr,d0
		move.w	d0,-(sp)
		move.w	#$2700,sr	; make sure nothing can mess us up.
		move.l	FS_CodeP,a0
		cmp.l		#0,a0
		beq.s		.out
		lea		FS_Code,a1
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
.out:		move.w	(sp)+,d0
		move.w	d0,sr
		movem.l	(sp)+,a2-a6/d2-d7
		rts

		ENDC

*--------------------------------------------------------------------------*
* Search for Xbra Cookie, 'Cookie' in d0.
* 	Returns address of routine (12 bytes infront of start of XBRA header)
*	in a0 or 0 if not found
*--------------------------------------------------------------------------*
FindXbra:	move.l	d2,-(sp)
		move.l	(a0),a1
		move.l	#'XBRA',d1
		moveq		#0,d2
.lp:		cmp.l		-12(a1),d1
		bne.s		.out
		cmp.l		-8(a1),d0
		beq.s		.found
		move.l	-4(a1),a1
		bra.s		.lp
.found:	move.l	a1,d2		
.out:		move.l	d2,a0
		move.l	(sp)+,d2
		rts


*-----------------------------------------------------------------*

;store_video:
;	push.w	#37
;	trap		#14
;	addq		#2,sp
;	move.l	$FFFF820E.w,d0
;	move.l	$FFFF8264.w,d1
;	movem.l	$FFFF8282.w,d2-5 
;	movem.l	$FFFF82A2.w,a0/d6-d7
;	move.l	$FFFF82C0.w,a1
;	move.w	$FFFF820A.w,a2
;	movem.l	a0-2/d0-7,video_store
;	move.w	NEW_MODECODE,video_data
;	move.l	#mode_name,sysfile_name
;	move.l	#video_data,sysfile_ptr
;	move.l	#2+(11*4),sysfile_size
;	jsr		WRITE_SYSFILE
;	rts
;mode_name:
;	dc.b		"apex.vid",0
;	even

GEM_MODECODE:	ds.w	1

vvbi_t:		ds.w	1
video_data:		ds.w	1
video_list:		ds.l	1
video_kept:		ds.l	11
;video_store:	ds.l	11
compat_mode:	ds.b	1
force_hard:		ds.b	1
fs_installed:	ds.b	1
KV_VGA_FLAG:	ds.b	1
			even

*-----------------------------------------------------------------*
