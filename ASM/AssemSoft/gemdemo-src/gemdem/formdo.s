		text
do_about	move.l	misc_buff2(a6),a1
		bsr	prepare_object

	;Objects that is not to be "toggled" is processed here.
	;Example of object processed here can be the parent object in a slider implementation
	;that causes page up/down/left/right actions. The parent should not be "toggled"
	;becuase then the child of it will be overdrawn.

		move.l	#$80000001,d1	;Bit 31=clear bits, 0 drawing depth,
		bsr	toggle_objstat
	
	;Objects that is to be acted upon while the button is pressed
	;goes here before the "bsr check_objevnt"
	
		bsr	check_objevnt
		bcc	.exit
	
	;Objects that is not to be acted upon until the mouse button is released.
	;If the mouse cursor leaves the object before the button is release, just
	;exit.	

		cmp.w	#ABOUT_EXIT,d0
		bne.s	.n1

		bsr	delete_window

	;The routine "chk_for_upd" is used to check if the window has moved or
	;changed during the processig of the selected button, like a non-modal fsel.
		bsr	chk_for_upd
		bra.s	.exit

.n1		bra.s	.exit
	;bsr	chk_for_upd
	;bra.s	.exit

.n2		nop
.exit		moveq	#1,d1	;Bit to toggle within obj_state
		bsr	toggle_objstat	;Do it!
.no_draw_exit	rts
	
***** Act-upon-stuff routine ****
do_settings	move.l	misc_buff2(a6),a1
		bsr	prepare_object

	;Objects that is not to be "toggled" is processed here.
	;Example of object processed here can be the parent object in a slider implementation
	;that causes page up/down/left/right actions. The parent should not be "toggled"
	;becuase then the child of it will be overdrawn.

		bsr	check_objevnt
		bcc	.exit

		cmp.w	#OUTPUT,d0
		bne.s	.n1
		not.b	outp_flag
		bsr	set_output
		bra	.no_draw_exit

.n1		cmp.w	#OUTPUT1,d0
		bne.s	.n2	
		not.b	outp_flag
		bsr	set_output
		bra	.no_draw_exit

.n2		cmp.w	#CONVNO1,d0
		blo.s	.n3
		cmp.w	#CONV15BM1,d0
		bgt.s	.n3
		subq.w	#4,d0
.n2_doconv	moveq	#(1<<OS_SELECTED)+(1<<OS_CROSSED),d1
		moveq	#CONVNO,d2
		moveq	#CONV15BM,d3
		bsr	obj_radio
		cmp.w	#CONVNO,d0
		bne.s	.n2_nono
		bsr	conv_videlmode
		bra.s	.no_draw_exit
.n2_nono	cmp.w	#CONV15B,d0
		bne.s	.n2_no15
		bsr	conv_15bmode
		bra	.no_draw_exit
.n2_no15	cmp.w	#CONV16B,d0
		bne	.n2_no16
		bsr	conv_16bmode
		bra	.no_draw_exit
.n2_no16	cmp.w	#CONV15BM,d0
		bne	.no_draw_exit
		bsr	conv_15bmmode
		bra	.no_draw_exit
	
.n3		cmp.w	#CONVNO,d0
		blo.s	.n4
		cmp.w	#CONV15BM,d0
		bgt.s	.n4
		bra.s	.n2_doconv

.n4		cmp.w	#CLIP,d0
		bne.s	.n5
.clipp		not.b	clipping
		bsr	set_clipping
		bra.s	.no_draw_exit
.n5		cmp.w	#CLIP1,d0
		beq.s	.clipp
		bra.s	.no_draw_exit
		
		move.l	#$80000001,d1	;Bit 31=clear bits, 0 drawing depth,
		bsr	toggle_objstat
	
	;Objects that is to be acted upon while the button is pressed
	;goes here before the "bsr check_objevnt"
	
		;bsr	check_objevnt
		;bcc	.exit

	
	;Objects that is not to be acted upon until the mouse button is released.
	;If the mouse cursor leaves the object before the button is release, just
	;exit.	
		bra.s	.exit


	;The routine "chk_for_upd" is used to check if the window has moved or
	;changed during the processig of the selected button, like a non-modal fsel.
.chk_exit	bsr	chk_for_upd
		bra.s	.exit
		nop

.exit		moveq	#1,d1	;Bit to toggle within obj_state
		bsr	toggle_objstat	;Do it!
.no_draw_exit	rts

*******
do_stats	move.l	misc_buff2(a6),a1
		bsr	prepare_object
	
		;move.l	#$80000001,d1
		;bsr	toggle_objstat
	
		bsr	check_objevnt
		bcc.s	.no_draw_exit
	
		cmp.w	#FPSCURNT,d0
		beq.s	.curnt
		cmp.w	#FPSCURNT1,d0
		beq.s	.curnt
		cmp.w	#FPSAVRGE,d0
		beq.s	.average
		cmp.w	#FPSAVRGE1,d0
		beq.s	.average
		cmp.w	#FPSUPDS,d0
		beq.s	.updates
		cmp.w	#FPSUPDS1,d0
		beq.s	.updates
		cmp.w	#FPSRUNT,d0
		beq.s	.runtime
		cmp.w	#FPSRUNT1,d0
		beq.s	.runtime
		nop
		bra.s	.no_draw_exit
.curnt		move.w	#FPSCURNT1,d0
		bchg	#0,afps_updflag
		bra.s	.chk_exit
.average	move.w	#FPSAVRGE1,d0
		bchg	#1,afps_updflag
		bra.s	.chk_exit
.updates	move.w	#FPSUPDS1,d0
		bchg	#2,afps_updflag
		bra.s	.chk_exit
.runtime	move.w	#FPSRUNT1,d0
		bchg	#3,afps_updflag
		bra.s	.chk_exit
		nop

.chk_exit	bsr	chk_for_upd
.exit		moveq	#(1<<OS_SELECTED)+(1<<OS_DISABLED),d1
		bsr	toggle_objstat
.no_draw_exit	rts


	
*******
do_adjustvals	move.l	misc_buff2(a6),a1
		bsr	prepare_object

		move.l	#$80000001,d1	;Bit 31=clear bits, 0 drawing depth,
		bsr	toggle_objstat
	
	;Objects that is to be acted upon while the button is pressed
	;goes here before the "bsr check_objevnt"
		bsr	check_objevnt
		bcc	.exit

		move.l	adjv+adjv_demo,d1
		beq	.exit
		move.l	d1,a2
		move.w	adjv+adjv_fghandle,d7
	
		move.l	d_ctrl1_step(a2),d2
		cmp.w	#ADJ_V1INC,d0
		beq.s	.v1_inc
		cmp.w	#ADJ_V1DEC,d0
		beq.s	.v1_dec

		move.l	d_ctrl2_step(a2),d2
		cmp.w	#ADJ_V2INC,d0
		beq.s	.v2_inc
		cmp.w	#ADJ_V2DEC,d0
		beq.s	.v2_dec

		move.l	d_ctrl3_step(a2),d2
		cmp.w	#ADJ_V3INC,d0
		beq	.v3_inc
		cmp.w	#ADJ_V3DEC,d0
		beq	.v3_dec
	
		move.l	d_ctrl4_step(a2),d2
		cmp.w	#ADJ_V4INC,d0
		beq	.v4_inc
		cmp.w	#ADJ_V4DEC,d0
		beq	.v4_dec
	
		move.l	d_ctrl5_step(a2),d2
		cmp.w	#ADJ_V5INC,d0
		beq	.v5_inc
		cmp.w	#ADJ_V5DEC,d0
		beq	.v5_dec
	
		move.l	d_ctrl6_step(a2),d2
		cmp.w	#ADJ_V6INC,d0
		beq	.v6_inc
		cmp.w	#ADJ_V6DEC,d0
		beq	.v6_dec
		bra	.exit

.v1_inc		add.l	d2,d_ctrl1_value(a2)
		bra.s	.v1_upd
.v1_dec		sub.l	d2,d_ctrl1_value(a2)
.v1_upd		movem.l	d0-2/a0-2,-(sp)
		moveq	#0,d1
		move.l	d_ctrl1_value(a2),d0
		bsr	.update
		movem.l	(sp)+,d0-2/a0-2
		bra	.exit

.v2_inc		add.l	d2,d_ctrl2_value(a2)
		bra.s	.v2_upd
.v2_dec		sub.l	d2,d_ctrl2_value(a2)
.v2_upd		movem.l	d0-2/a0-2,-(sp)
		moveq	#1,d1
		move.l	d_ctrl2_value(a2),d0
		bsr.s	.update
		movem.l	(sp)+,d0-2/a0-2
		bra	.exit

.v3_inc		add.l	d2,d_ctrl3_value(a2)
		bra.s	.v3_upd
.v3_dec		sub.l	d2,d_ctrl3_value(a2)
.v3_upd		movem.l	d0-2/a0-2,-(sp)
		moveq	#2,d1
		move.l	d_ctrl3_value(a2),d0
		bsr.s	.update
		movem.l	(sp)+,d0-2/a0-2
		bra.s	.exit
	
.v4_inc		add.l	d2,d_ctrl4_value(a2)
		bra.s	.v4_upd
.v4_dec		sub.l	d2,d_ctrl4_value(a2)
.v4_upd		movem.l	d0-2/a0-2,-(sp)
		moveq	#3,d1
		move.l	d_ctrl4_value(a2),d0
		bsr.s	.update
		movem.l	(sp)+,d0-2/a0-2
		bra.s	.exit
	
.v5_inc		add.l	d2,d_ctrl5_value(a2)
		bra.s	.v5_upd
.v5_dec		sub.l	d2,d_ctrl5_value(a2)
.v5_upd		movem.l	d0-2/a0-2,-(sp)
		moveq	#4,d1
		move.l	d_ctrl5_value(a2),d0
		bsr.s	.update
		movem.l	(sp)+,d0-2/a0-2
		bra.s	.exit

.v6_inc		add.l	d2,d_ctrl6_value(a2)
		bra.s	.v6_upd
.v6_dec		sub.l	d2,d_ctrl6_value(a2)
.v6_upd		movem.l	d0-2/a0-2,-(sp)
		moveq	#5,d1
		move.l	d_ctrl6_value(a2),d0
		bsr.s	.update
		movem.l	(sp)+,d0-2/a0-2
		bra.s	.exit

.update		move.l	d1,-(sp)
		lea	number,a0
		bsr	bintodec
		move.l	a0,a1
		move.l	(sp)+,d1
		move.w	d7,d0
		bsr	textframe_newtext
		rts
	
	
.exit		moveq	#1,d1	;Bit to toggle within obj_state
		bsr	toggle_objstat	;Do it!
.no_draw_exit	rts
***********************************************
set_adjustvals	movem.l	d0-a6,-(sp)
	
		bsr	get_adjustvals
	
		move.l	adjv+adjv_demo,d0
		beq	.exit
		move.l	d0,a3
		move.w	adjv+adjv_fghandle,d7

		move.l	obj_addr(a5),-(sp)
	
		moveq	#ADJ_V1NAME,d0
		move.l	misc_buff1(a6),a1
		bsr	prepare_object
		moveq	#0,d6
		move.l	d_ctrl1_name(a3),a2
		move.l	d_ctrl1_value(a3),d5
		bsr.s	.set_it
	
		move.w	#ADJ_V2NAME,d0
		moveq	#1,d6
		move.l	d_ctrl2_name(a3),a2
		move.l	d_ctrl2_value(a3),d5
		bsr.s	.set_it
	
		move.w	#ADJ_V3NAME,d0
		moveq	#2,d6
		move.l	d_ctrl3_name(a3),a2
		move.l	d_ctrl3_value(a3),d5
		bsr.s	.set_it

		move.w	#ADJ_V4NAME,d0
		moveq	#3,d6
		move.l	d_ctrl4_name(a3),a2
		move.l	d_ctrl4_value(a3),d5
		bsr.s	.set_it

		move.w	#ADJ_V5NAME,d0
		moveq	#4,d6
		move.l	d_ctrl5_name(a3),a2
		move.l	d_ctrl5_value(a3),d5
		bsr.s	.set_it

		move.w	#ADJ_V6NAME,d0
		moveq	#5,d6
		move.l	d_ctrl6_name(a3),a2
		move.l	d_ctrl6_value(a3),d5
		bsr.s	.set_it
		addq.l	#4,sp
		bra	.exit

	;D0 = Index of slot name
	;D5 = Value to put into frame holding value
	;D6 = Frame number holding the value
	;D7 = FrameGroup handle
	
	;A1 = Rectangle list
	;A2 = String containing Slot name to set
	
.set_it		movem.l	d0-a6,-(sp)
		move.l	16*4(sp),a0	;Object tree

		cmpa.l	#0,a2	;Unused entry
		bne.s	.used	;Nope
	
	;Last entry
		lea	vslot_unused,a2
		moveq	#0,d2
		bsr	set_tetxt_obj
	
		moveq	#1<<OS_DISABLED,d2
		move.l	#($8000<<16)+(OF_TOUCHEXIT),d3
		move.l	d2,d1
		bsr	change_objstat
	
		subq.w	#2,d0
		move.l	d2,d1
		bsr	change_objstat
		move.l	d3,d1
		bsr	change_objflag

		subq.w	#1,d0
		move.l	d2,d1
		bsr	change_objstat
		move.l	d3,d1
		bsr	change_objflag

		subq.w	#1,d0
		bsr	change_objstat
		lea	vslot_zero,a1
		move.w	d7,d0
		move.w	d6,d1
		move.l	#1<<tf_updf_redraw,d3
		bsr	textframe_newtext
		bra.s	.setit_exit
	

.used		move.l	#($8000<<16)+(1<<OS_DISABLED),d2
		moveq	#1<<OF_TOUCHEXIT,d3

		move.l	d2,d1
		bsr	change_objstat

		subq.w	#2,d0
		move.l	d2,d1
		bsr	change_objstat
		move.l	d3,d1
		bsr	change_objflag
	
		subq.w	#1,d0
		move.l	d2,d1
		bsr	change_objstat
		move.l	d3,d1
		bsr	change_objflag

		subq.w	#1,d0
		move.l	d2,d1
		bsr	change_objstat
		addq.w	#4,d0
	
		moveq	#0,d2
		bsr	set_tetxt_obj
	
		move.l	d5,d0
		lea	number,a0
		bsr	bintodec
		move.l	a0,a1
		move.w	d7,d0
		move.w	d6,d1
		move.l	#1<<tf_updf_redraw,d3
		bsr	textframe_newtext
.setit_exit	movem.l	(sp)+,d0-a6
		rts
	
.exit		movem.l	(sp)+,d0-a6
		rts
	
	
***********************************************
setoutp	reg d0-a6
set_output	movem.l	setoutp,-(sp)

		move.l	dwin_bss(a6),a5
		move.l	obj_addr(a5),a0
	
		moveq	#0,d1
		move.l	misc_buff2(a6),a1
		moveq	#OUTPUT1,d0
		bsr	prepare_object
	
		lea	outp_vdi(pc),a2
		tst.b	outp_flag
		beq.s	.set_vdi
		lea	outp_direct(pc),a2
		bsr.s	.set_stuff
		bra.s	.exit

.set_vdi	bsr.s	.set_stuff
		bra.s	.exit

.set_stuff	moveq	#0,d2
		bsr	set_tetxt_obj
		moveq	#ME_OUTPUT,d0
		move.l	menu_addr(a6),a0
		bsr	set_menu_text
		rts

.exit		movem.l	(sp)+,setoutp
		rts

set_clipping	movem.l	d0-a6,-(sp)

		move.l	dwin_bss(a6),a5
		move.l	obj_addr(a5),a0
	
		moveq	#0,d1
		move.l	misc_buff2(a6),a1
		moveq	#CLIP1,d0
		bsr	prepare_object
	
		lea	clip_off(pc),a2
		lea	mclp_off(pc),a3
		tst.b	clipping
		beq.s	.set_vdi
		lea	clip_on(pc),a2
		lea	mclp_on(pc),a3
		bsr.s	.set_stuff
		bra.s	.exit

.set_vdi	bsr.s	.set_stuff
		bra.s	.exit

.set_stuff	moveq	#0,d2
		bsr	set_tetxt_obj
		moveq	#0,d2
		move.l	a3,a2
		move.l	menu_addr(a6),a0
		moveq	#ME_CLIP,d0
		bsr	set_menu_text
		rts

.exit		movem.l	(sp)+,d0-a6
		rts
		

*********************************
set_gfxmode	movem.l	d0-a6,-(sp)

		move.l	dwin_bss(a6),a5
		move.l	obj_addr(a5),a0
	
		moveq	#0,d0
		move.b	gfxmode,d0
		add.w	#CONVNO,d0
		move.l	misc_buff2(a6),a1
		bsr	prepare_object
		moveq	#CONVNO,d2
		moveq	#CONV15BM,d3
		move.l	#(1<<OS_SELECTED)+(1<<OS_CROSSED),d1
		bsr	obj_radio
	
		move.l	menu_addr(a6),a0
		moveq	#0,d0
		move.b	gfxmode,d0
		add.w	#ME_CONVNO,d0
		move.l	#(1<<OS_CHECKED),d1
		move.w	#ME_CONVNO,d2
		move.w	#ME_CONV15BM,d3
		bsr	obj_radio
	
		movem.l	(sp)+,d0-a6
		rts
	
