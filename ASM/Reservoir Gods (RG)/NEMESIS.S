***********************************
*=================================*
* RESERVOIR GODS LIBRARY ROUTINES *
*=================================*
*       |                  |      *
*       |  NEMESIS LIBRARY |      *
*       |                  |      *
***********************************
* CODE: MR. PINK | (C): 11/07/97  *
***********************************

**************************************************************************
	SECTION TEXT
**************************************************************************

rlnem_nemesis_constructor
	bsr	rlnem_read_nemesis_cookie
	move.l	d0,rlnem_old_nemesis_mode
	tst.l	d0
	bmi	.no_nem
	cmp.w	#2,rlsc_monitor_type(a0)
	beq.s	.no_nem
	lea	rlnem_rgb_vbl,a0
	jsr	rlvc_install_vbl_routine
.no_nem	rts

rlnem_nemesis_deconstructor
	move.l	rlnem_old_nemesis_mode,d0
	bsr	rlnem_set_nemesis_mode
	lea	rlnem_rgb_vbl,a0
	jsr	rlvc_remove_vbl_routine
	rts

rlnem_set_nemesis_mode
	move.l	d0,-(a7)
	and.w	#3,d0
	jsr	([rlnem_nemesis_routs,d0.w*4])
	move.l	(a7)+,d0
	rts

rlnem_nemesis_routs
	dc.l	rlnem_nemesis_off
	dc.l	rlnem_nemesis_lo
	dc.l	rlnem_nemesis_hi
	dc.l	rlnem_nemesis_off

rlnem_nemesis_off:
	movem.l	a0,-(a7)
	bsr	rlnem_set_nemesis_rgb
	jsr	rlvc_wait_vbl
	movea.w	#$fc04,a0
	move.b	#3,(a0)
	move.b	#-$6b,(a0)
	subq.w	#4,a0
	move.b	#3,(a0)
	move.b	#-$6a,(a0)
	bset	#0,$ffff8007.w	;68030 16 mhz
	bset	#2,$ffff8007.w	;blitter 16mhz
	move.l	(a7)+,a0
	rts

rlnem_nemesis_lo:
	movem.l	a0,-(a7)
	bsr	rlnem_set_nemesis_rgb
	jsr	rlvc_wait_vbl
	movea.w	#$fc04,a0
	move.b	#3,(a0)
	move.b	#-$6b,(a0)
	subq.w	#4,a0
	move.b	#3,(a0)
	move.b	#-$2a,(a0)
	bset.b	#0,$ffff8007.w	;68030 16 mhz
	bclr.b	#2,$ffff8007.w	;blitter 8 mhz
	move.l	(a7)+,a0
	rts

rlnem_nemesis_hi:
	movem.l	a0,-(a7)
	bsr	rlnem_set_nemesis_rgb
	jsr	rlvc_wait_vbl
	movea.w	#$fc04,a0
	move.b	#3,(a0)
	move.b	#-$2b,(a0)
	subq.w	#4,a0
	move.b	#3,(a0)
	move.b	#-$2a,(a0)
	bclr.b	#2,$ffff8007.w	;blitter 8mhz
	move.l	(a7)+,a0
	rts

rlnem_read_nemesis_cookie:
	movem.l	d1/a0,-(a7)

	movea.l	$5a0.w,a0
	move.l	#$4e737064,d0
	bra.s	.first

.check	cmp.l	d0,d1
	beq.s	.found
	addq.w	#8,a0
.first	move.l	(a0),d1
	bne.s	.check

	moveq	#-1,d0
	movem.l	(a7)+,a0/d1
	rts

.found	move.l	4(a0),d0
	movem.l	(a7)+,a0/d1
	rts

rlnem_write_nemesis_cookie:
	movem.l	d0-d2/a0,-(a7)

	movea.l	$5a0.w,a0
	move.l	#$4e737064,d2
	bra.s	.first

.check	cmp.l	d2,d1
	beq.s	.found
	addq.w	#8,a0
.first	move.l	(a0),d1
	bne.s	.check

	movem.l	(a7)+,d0-d2/a0
	rts

.found	move.l	d0,4(a0)
	movem.l	(a7)+,d0-d2/a0
	rts
	
rlnem_set_nemesis_rgb
	move.l	a0,-(a7)

	bsr	rlnem_read_nemesis_cookie
	bne	.vga

	lea	rlsc_screen_space,a0
	cmp.w	#2,rlsc_monitor_type(a0)
	beq.s	.vga

	btst.b	#2,$ffff82c1.w
	bne.s	.vga
	bset.b	#2,$ffff82c1.w

.vga	move.l	(a7)+,a0
	rts	

rlnem_rgb_vbl:
	btst.b	#2,$ffff82c1.w
	bne.s	.vga
	bset.b	#2,$ffff82c1.w
.vga	rts

rlnem_old_nemesis_mode:	dc.l	0