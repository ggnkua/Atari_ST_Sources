		text
open_accessory	rts

close_accessory rts

appl_terminate	rts

quitting:	jsr	set_super
		move.w	sr,d3
		or.w	#$700,sr
		;move.l	Hz50_reloc,a0
		;move.l	HZ50_oldvect(a0),-(sp)
		;move.w	#$100,-(sp)
		;move.w	#5,-(sp)
		;trap	#13
		;addq.l	#8,sp
		move.w	d3,sr
		jsr	set_user
		
		;lea	demoes,a0

		move.l	demoes,d2
		beq.s	.done

.free_it:	move.l	d2,a0
		move.l	d_texture(a0),d1
		beq.s	.no_texture
		bsr	mem_free
.no_texture:	move.l	d_basepage(a0),d1
		beq.s	.no_bp
		bsr	mem_free
.no_bp:		move.l	d_next(a0),d2
		beq.s	.done
		move.l	a0,d1
		bsr	mem_free
		bra.s	.free_it

.done:		move.w	adjv+adjv_fghandle(pc),d0
		bsr	textframe_killgroup
		jsr	delete_cobject
		rts


;Zoomed = 288*170, non zoomed = 144*85
;linewidth-576/288
zoom_mode	movem.l	d0-a6,-(sp)
	
		jsr	begin_upd
		jsr	begin_mcont
		move.l	point_bss(a5),a0
		lea	zoom_pop(pc),a2
		bsr	getmouse
		move.l	int_out+2(a6),pu_x(a2)
		moveq	#0,d0
		move.b	d_zoom(a0),d0
		addq.w	#1,d0
		move.w	d0,pu_current(a2)
		jsr	popup
		jsr	end_mcont
		jsr	end_upd
		
		move.w	pu_returnobj(a2),d0
		cmp.w	#P1_ZOOM1X,d0
		beq.s	.unzoom		
		bra.s	.full_it
	
.unzoom		btst	#w_full_f,win_flags+3(a5)
		beq	.exit
		bclr	#w_full_f,win_flags+3(a5)
		move.l	win_px(a5),d1
		moveq	#0,d0
		move.l	win_pw(a5),d2
		bsr	set_owin_xywh
		clr.b	d_zoom(a0)
		move.l	d_rout1x(a0),d_rout(a0)
		move.l	d_sslj(a0),d_mscnljmp(a0)
		bra	.exit
	
	
.full_it	cmp.w	#P1_ZOOM2X,d0
		beq.s	.2x
		cmp.w	#P1_ZOOM4X,d0
		beq.s	.4x
		bra	.exit

.2x		cmp.b	#1,d_zoom(a0)
		beq.s	.exit
		move.l	d_rout2x(a0),d0
		beq.s	.exit
		moveq	#1,d3
		bra.s	.got_x

.4x		cmp.b	#2,d_zoom(a0)
		beq.s	.exit
		move.l	d_rout4x(a0),d0
		beq.s	.exit
		moveq	#2,d3
	
.got_x		move.l	d0,d_rout(a0)
	
		move.l	win_x(a5),d1
		tst.b	d_zoom(a0)
		bne.s	.already_zoom
		move.l	d1,win_px(a5)
		move.l	win_w(a5),win_pw(a5)

.already_zoom	bset	#w_full_f,win_flags+3(a5)
		move.b	d3,d_zoom(a0)
		move.l	win_wx(a5),d1
		move.w	d_xres(a0),d2
		lsl.w	d3,d2
		swap	d2
		move.w	d_yres(a0),d2
		lsl.w	d3,d2
		moveq	#0,d0
		bsr	win_calc

		cmp.w	win_my(a5),d1
		bge.s	.y_ok
		move.w	win_my(a5),d1
.y_ok		swap	d1
		cmp.w	win_mx(a5),d1
		bge.s	.x_ok
		move.w	win_mx(a5),d1
.x_ok		swap	d1

		bsr	set_owin_xywh

		move.l	d_sslj(a0),d0
		lsl.l	d3,d0
		move.l	d0,d_mscnljmp(a0)

.exit		movem.l	(sp)+,d0-a6
		rts
	
;-----------------------------------------------------------
do_demo		bsr	begin_upd

		move.l	Hz50_reloc,a3
		addq.l	#1,HZ50_fps+FPS_frames(a3)
		addq.l	#1,HZ50_fps+FPS_updates(a3)

		;bsr	fps
	
		move.l	demoes,d0
		beq.s	.exit

.loop:		move.l	d0,a4
		movem.l	d1/a4,-(sp)
		move.l	d_winbss(a4),d0
		beq.s	.next
		move.l	d0,a5
		bsr	run_demo
.next		movem.l	(sp)+,d1/a4
		move.l	d_next(a4),d0
		bne.s	.loop
	
.exit		;move.l	Hz50_reloc,a3
		tst.l	HZ50_fps+FPS_real(a3)
		beq	.exit_loop

;		tst.b	save_stats
;		beq.s	.no_save
;		subq.b	#1,save_stats
;		bne.s	.no_save	
;		bsr	save_statistics
;.no_save
		bsr	get_stats
		btst	#w_open_f,win_flags+3(a5)
		beq	.exit_loop

		move.b	afps_updflag(pc),d3
		beq	.exit_loop
	
		move.l	HZ50_fps+FPS_real(a3),d0
		clr.l	HZ50_fps+FPS_real(a3)	
		lsr.b	#1,d3
		bcc.s	.nupd_real
		lea	afps_real(pc),a0
		bsr	bintodec

.nupd_real	lsr.b	#1,d3
		bcc.s	.nupd_average
		lea	afps_average(pc),a0
		move.l	HZ50_fps+FPS_average(a3),d0
		bsr	bintodec

.nupd_average	lsr.b	#1,d3
		bcc.s	.nupd_seconds
		lea	afps_updates(pc),a0
		move.l	HZ50_fps+FPS_updates(a3),d0
		bsr	bintodec

.nupd_seconds	lsr.b	#1,d3
		bcc.s	.nupd_update
		lea	afps_seconds(pc),a0
		move.l	HZ50_fps+FPS_seconds(a3),d0
		bsr	bintodec
	
.nupd_update	move.l	obj_addr(a5),a0
		moveq	#0,d1
		move.l	misc_buff1(a6),a1
		moveq	#FPSCURNT1,d0
		bsr	prepare_object
		move.b	afps_updflag(pc),d3
		lsr.b	#1,d3
		bcc.s	.nd_1
		bsr	justdraw_object

.nd_1		lsr.b	#1,d3
		bcc.s	.nd_2
		move.w	#FPSAVRGE1,d0
		bsr	justdraw_object
	
.nd_2		lsr.b	#1,d3
		bcc.s	.nd_3
		move.w	#FPSUPDS1,d0
		bsr	justdraw_object
	
.nd_3		lsr.b	#1,d3
		bcc.s	.exit_loop
		move.w	#FPSRUNT1,d0
		bsr	justdraw_object
		
.exit_loop	bsr	end_upd
		rts

		
run_demo	tst.b	clipping
		beq.s	.no_clipcheck
	
		WIND_GET	win_handle(a5),#11
	
	;check if the 1st rectangle of the window covers the complete
	;work area. If not, we need to use vdi to copy the correct parts
		move.l	win_wx(a5),d1
		cmp.w	int_out+4(a5),d1
		blt	.vdi_clip
		swap	d1
		cmp.w	int_out+2(a5),d1
		blt	.vdi_clip
		swap	d1
		move.l	win_ww(a5),d2
		cmp.w	int_out+8(a6),d2
		bgt	.vdi_clip
		swap	d2
		cmp.w	int_out+6(a6),d2
		bgt	.vdi_clip
		swap	d2

	;Check if the area is within the screen
		bsr	screen_clip
		bcc	.vdi_exit	;No part visible
		bvs	.vdi_clip	;Some parts visible

		move.w	win_flags+2(a5),d0
		and.w	#(1<<w_icon_f)+(1<<w_bari_f),d0
		beq.s	.clip_checked
		bra	.vdi_clip

	;When we get here, we know the whole work area of the window is free
	;And the coordinates of the window is in D1 and D2
.no_clipcheck	move.l	win_wx(a5),d1
		move.l	win_ww(a5),d2
.clip_checked	tst.b	outp_flag
		bne	.direct
	
		clr.l	d_scnl_jump(a4)

		move.l	#screen_buffer,d_scrnadr(a4)

		move.l	d_rout(a4),a0
		movem.l	d1-2/a0-6,-(sp)
		jsr	(a0)
		movem.l	(sp)+,d1-2/a0-6

		;move.l	win_wx(a5),d1
		;move.l	win_ww(a5),d2
		add.l	d1,d2
		sub.l	#$10001,d2
		
		lea	demo_mfdb,a2
		move.l	#dst_md,dst_mfdb(a6)
		move.l	#screen_buffer,MFDB_addr(a2)
		move.l	d_xres(a4),d3
		moveq	#0,d0
		move.b	d_zoom(a4),d0
		beq.s	.blit
		lsl.l	d0,d3	
.blit		move.l	d3,MFDB_width(a2)
		move.l	d3,d0
		swap	d0
		add.w	#15,d0
		lsr.w	#4,d0
		move.w	d0,MFDB_wdwidth(a2)	
		VRO_CPYFM	work_handle(a6),#3,<l>,#0,d3,d1,d2,a2,dst_mfdb(a6)
.vdi_exit	rts	

;***************** VDI CLIP *************************
;Somewhat hard to read cause of my attempt to optimize it. That is, all the vdi paramter
;setups (read/writes to ram) is almost always having a non RAM hitting instruction
;between them.
.vdi_clip	move.l	int_out+6(a6),d2
		beq.s	.vdi_exit
		move.l	int_out+2(a6),d1
		bsr	screen_clip
		bcc	.clip_loop
	
		clr.l	d_scnl_jump(a4)

		move.l	#screen_buffer,d_scrnadr(a4)

	;Execute the demo routine
		move.l	d_rout(a4),a0
		movem.l	d1-2/a0-6,-(sp)
		jsr	(a0)
		movem.l	(sp)+,d1-2/a0-6

		;VS_CLIP	work_handle(a6),#0

	;D1, D2 = X, Y, width and height of 1st rectangle
	;Set up the MFDBs
		lea	demo_mfdb(pc),a2
		move.l	#screen_buffer,MFDB_addr(a2)
		move.l	d_xres(a4),d3
		moveq	#0,d0
		move.b	d_zoom(a4),d0
		beq.s	.blit_clip
		lsl.l	d0,d3	
.blit_clip	move.l	d3,MFDB_width(a2)
		move.l	d3,d0
		move.l	a2,contrl+14(a6)	;Source mfdb
		swap	d0
		add.w	#15,d0
		move.l	#dst_md,contrl+18(a6)	;Dest mfdb
		lsr.w	#4,d0
		move.w	d0,MFDB_wdwidth(a2)	

	;Put the destination coords
		move.l	d2,d0
		move.l	d1,ptsin+8(a6)
		add.l	d1,d0
		sub.l	#$10001,d0
		move.l	d0,ptsin+12(a6)

	;Calc coords into the mfdb
		sub.w	win_wy(a5),d1
		add.w	d1,d2
		move.l	#$6d0004,contrl(a6)	;vro_cpyfm opcode
		swap	d1
		move.w	#1,contrl+6(a6)		;For the vdi call
		subq.w	#1,d2
		move.w	#3,intin(a6)		;Mode 3 (replace)
		swap	d2
		sub.w	win_wx(a5),d1
		add.w	d1,d2
		move.w	work_handle(a6),contrl+12(a6)	;VDI handle
		swap	d1
		move.l	d1,ptsin(a6)
		subq.w	#1,d2
		swap	d2
		move.l	d2,ptsin+4(a6)

	;Call vdi to do the vro_cpyfm
		move.l	vdipb(a6),d1
		moveq	#115,d0
		trap	#2
	
.clip_loop	move.l	#$10001,d6
.clip_lop1	WIND_GET	,#12
		move.l	int_out+6(a6),d2
		beq.s	.clip_done
		move.l	int_out+2(a6),d1
		bsr	screen_clip
		bcc.s	.clip_lop1
	
	;Put the destination coords
		move.l	d2,d0
		move.l	d1,ptsin+8(a6)
		add.l	d1,d0
		sub.l	d6,d0
		move.l	d0,ptsin+12(a6)

	;Calc coords into the mfdb
		sub.l	win_wx(a5),d1
		add.l	d1,d2
		move.l	d1,ptsin(a6)
		sub.l	d6,d2
		move.l	d2,ptsin+4(a6)

	;Call vdi to do the vro_cpyfm
		move.l	vdipb(a6),d1
		moveq	#115,d0
		trap	#2
		bra.s	.clip_lop1
.clip_done	rts


.direct		move.l	phys_screen(a6),a0
		moveq	#0,d0
		move.w	win_wx(a5),d0
		lsl.l	#1,d0
		adda.l	d0,a0

		moveq	#0,d0
		move.w	screen_x(a6),d0
		lsl.l	#1,d0
		move.l	d0,d1
		mulu.w	win_wy(a5),d0
		add.l	d0,a0
	
		move.l	a0,d_scrnadr(a4)
	
		sub.l	d_mscnljmp(a4),d1

		move.l	d1,d_scnl_jump(a4)

		move.l	d_rout(a4),a0
		movem.l	a0-6,-(sp)
		jsr	(a0)
		movem.l	(sp)+,a0-6
.exit		rts
	
	
conv_15bmode	movem.l	d0-a6,-(sp)
	
		move.l	demoes,d0
		beq.s	.exit

.convert:	move.l	d0,a3
		move.l	d_init(a3),d0
		beq.s	.next
		move.l	d0,a0
		jsr	(a0)
		move.l	d_texture(a3),a0
		move.l	d_texturesize(a3),d0
		lsr.l	#1,d0
		jsr	CDots15BitConv
.next		move.l	d_next(a3),d0
		bne.s	.convert
	
.exit:		move.b	#2,gfxmode
		movem.l	(sp)+,d0-a6
		bsr	set_gfxmode
		rts

conv_16bmode	movem.l	d0-a6,-(sp)

		move.l	demoes,d0
		beq.s	.exit
		
.convert:	move.l	d0,a3
		move.l	d_init(a3),d0
		beq.s	.next
		move.l	d0,a0
		jsr	(a0)
		move.l	d_texture(a3),a0
		move.l	d_texturesize(a3),d0
		lsr.l	#1,d0
		jsr	Nova16BitConv
.next:		move.l	d_next(a3),d0
		bne.s	.convert

.exit:		move.b	#1,gfxmode
		movem.l	(sp)+,d0-a6
		bsr	set_gfxmode
		rts

conv_15bmmode	movem.l	d0-a6,-(sp)

		move.l	demoes,d0
		beq.s	.exit

.convert:	move.l	d0,a3
		move.l	d_init(a3),d0
		beq.s	.next
		move.l	d0,a0
		jsr	(a0)
		move.l	d_texture(a3),a0
		move.l	d_texturesize(a3),d0
		lsr.l	#1,d0
		jsr	Moto15BitConv
.next:		move.l	d_next(a3),d0
		bne.s	.convert

.exit:		move.b	#3,gfxmode
		movem.l	(sp)+,d0-a6
		bsr	set_gfxmode
		rts

conv_videlmode	movem.l	d0-a6,-(sp)

		move.l	demoes,d0
		beq.s	.exit

.convert:	move.l	d0,a3
		move.l	d_init(a3),d0
		beq.s	.next
		move.l	d0,a0
		jsr	(a0)
.next:		move.l	d_next(a3),d0
		bne.s	.convert

.exit:		clr.b	gfxmode
		movem.l	(sp)+,d0-a6
		bsr	set_gfxmode
		rts
	

; This routine gotta be completely re-locatable, because we have
; to move this routine into super memory, so that memoryprotection
; isn't a problem.
Hz50_demoes:	dc.l	0
old_etv_vect:	dc.l	0
fps_struct:	dcb.b	FPS_ssize,0
Hz50_calls:	lea	fps_struct(pc),a0

		subq.b	#1,FPS_second(a0)
		bne.s	.done_fps

.ok:		move.l	FPS_frames(a0),FPS_real(a0)	;put last seconds fps for read
		clr.l	FPS_frames(a0)			;okey.. let's clear and do it again..
		;clr.b	FPS_second(a0)			;
		move.b	#49,FPS_second(a0)
		
		addq.l	#1,FPS_seconds(a0)		;total seconds in progress
		move.l	FPS_seconds(a0),d0		;get all secs
		move.l	FPS_updates(a0),d1		;get all updates done
		divu.l	d0,d1				;get average fps
		move.l	d1,FPS_average(a0)		;store average fps
		;bra.s	.done_fps			;rts


.done_fps:	move.l	Hz50_demoes(pc),d1
		beq.s	.exit

.do_50hz:	move.l	d1,a4
		tst.w	d_winh(a4)
		beq.s	.next
		move.l	d_50hz(a4),d1
		beq.s	.next
		move.l	d1,a0
		movem.l	d0-1/a4,-(sp)
		jsr	(a0)
		movem.l	(sp)+,d0-1/a4
.next:		move.l	d_next(a4),d1
		bne.s	.do_50hz

.exit:		move.l	old_etv_vect(pc),a0
		jmp	(a0)
Hz50_end:
