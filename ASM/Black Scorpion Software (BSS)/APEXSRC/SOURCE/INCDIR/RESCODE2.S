
*-----------------------------------------------------------------*
keep_video:
*-----------------------------------------------------------------*
	jsr		Get_KV_monitor
*-----------------------------------------------------------------*
	move.l	#old_set,patch_struct_ptr
	jsr		read_registers
*-----------------------------------------------------------------*
	move.l	patch_struct_ptr,a0
	move.w	patch_code(a0),GEM_MODECODE
	rts
	
*-----------------------------------------------------------------*
Get_KV_monitor:
*-----------------------------------------------------------------*
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
	move.l	a0,d0
	move.b	d0,d1
	lsr.w		#8,d0
	move.l	d0,$FFFF8200.w
	move.b	d1,$FFFF820D.w
*-----------------------------------------------------------------*
	move.l	#old_set,patch_struct_ptr
	jsr		load_registers
*-----------------------------------------------------------------*
	rts

*-----------------------------------------------------------------*
set_video:
*-----------------------------------------------------------------*
	and.w		#%0111111111111111,d0
	moveq		#-1,d7
	tst.b		KV_VGA_FLAG
	beq.s		.rgb
	bclr		#pal_bit,d7
	bclr		#os_bit,d7
.rgb	and.w		d7,d0
	lea		video_modes,a1
.next	move.w	patch_code(a1),d1
	cmp.w		#-1,d1
	beq.s		.rts
	and.w		d7,d1
	cmp.w		d0,d1
	beq.s		.go
	lea		patch_slen(a1),a1
	bra.s		.next	
.go	move.l	a0,d0
	move.b	d0,d1
	lsr.w		#8,d0
	move.l	d0,$FFFF8200.w
	move.b	d1,$FFFF820D.w
	move.l	a1,patch_struct_ptr
	jsr		load_registers
.rts	rts

*-----------------------------------------------------------------*

	include	incdir\videl.s

*-----------------------------------------------------------------*

GEM_MODECODE:	ds.w	1
GEM_SCREEN:	ds.l	1

old_set:	ds.b	patch_slen

vwork_w:	ds.w	1
vwork_h:	ds.w	1

vvbi_t:		ds.w	1
video_data:		ds.w	1
video_list:		ds.l	1
video_kept:		ds.l	11
;video_store:	ds.l	11
compat_mode:	ds.b	1
force_hard:		ds.b	1
change_done:	ds.b	1
fs_installed:	ds.b	1
KV_VGA_FLAG:	ds.b	1
			even

*-----------------------------------------------------------------*

