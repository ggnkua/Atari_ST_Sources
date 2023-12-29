	text
evnt_keyboard	cmp.b	#'0',d7
		blt.s	.no_dwin
		cmp.b	#'9',d7
		bgt.s	.no_dwin
		bra.s	.open_dwin

.no_dwin	cmp.b	#Asc_ctrl_r,d7
		beq	.zero_fps
		cmp.b	#Asc_ctrl_d,d7
		beq.s	.open_setting
		cmp.b	#Asc_ctrl_s,d7
		beq.s	.open_stats
		cmp.b	#Asc_ctrl_m,d7
		beq.s	.chng_outpmode
		cmp.b	#Asc_ctrl_l,d7
		beq.s	.clipping
		lsr.w	#8,d7
		cmp.b	#Key_f1,d7
		beq.s	.conv_none
		cmp.b	#Key_f2,d7
		beq.s	.conv_16b
		cmp.b	#Key_f3,d7
		beq.s	.conv_15b
		cmp.b	#Key_f4,d7
		beq.s	.conv_15bm
		ror.w	#8,d7
		bra.s	.not_used
	
.open_dwin	moveq	#0,d0
		move.b	d7,d0
		sub.b	#'0',d0
		bsr	open_demowindow
		bra.s	.used

.open_stats	bsr	open_stats
		bra.s	.used
.open_setting	bsr	open_settings
		bra.s	.used
.chng_outpmode	not.b	outp_flag
		bsr	set_output
		bra.s	.used
.clipping	not.b	clipping
		bsr	set_clipping
		bra.s	.used
.conv_none	bsr	conv_videlmode
		bra.s	.used
.conv_15b	bsr	conv_15bmode
		bra.s	.used
.conv_16b	bsr	conv_16bmode
		bra.s	.used
.conv_15bm	bsr	conv_15bmmode
		bra.s	.used

.zero_fps:	move.l	Hz50_reloc,a0
		clr.l	HZ50_fps+FPS_real(a0)
		clr.l	HZ50_fps+FPS_average(a0)
		clr.l	HZ50_fps+FPS_updates(a0)
		clr.l	HZ50_fps+FPS_seconds(a0)
		clr.l	HZ50_fps+FPS_frames(a0)
		;clr.b	HZ50_fps+FPS_second(a0)
		move.b	#49,HZ50_fps+FPS_second(a0)
		bra.s	.used
		nop
.used		and.b	#-2,ccr
		rts
.not_used	or.b	#1,ccr
		rts
	


