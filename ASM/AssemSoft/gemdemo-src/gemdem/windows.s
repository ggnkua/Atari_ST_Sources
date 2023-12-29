		text
	;Window #2
open_about	movem.l	d0-a6,-(sp)
		move.l	dwin_bss(a6),a5
		adda.w	dwin_bsssize(a6),a5
		move.w	#(1<<NAME)+(1<<CLOSER)+(1<<MOVER),d1
		bsr	open_dwinsub
		movem.l	(sp)+,d0-a6
		rts
	
	;Window #5
get_loading	move.l	d0,-(sp)
		move.l	dwin_bss(a6),a5
		moveq	#0,d0
		move.w	dwin_bsssize(a6),d0
		mulu	#5,d0
		add.l	d0,a5
		move.l	(sp)+,d0
		rts

open_loading	movem.l	d0-a6,-(sp)
		bsr.s	get_loading
		moveq	#0,d1
		bsr	open_dwinsub
		movem.l	(sp)+,d0-a6
		rts
	
	
	;Window #1
get_settings	move.l	dwin_bss(a6),a5
		rts
	
open_settings	movem.l	d0-a6,-(sp)
		move.l	dwin_bss(a6),a5
		move.w	#(1<<NAME)+(1<<CLOSER)+(1<<FULLER)+(1<<MOVER)+(1<<SMALLER),d1
		bsr	open_dwinsub
		movem.l	(sp)+,d0-a6
		rts

	;Window #3
get_adjustvals	move.l	d0,-(sp)
		move.l	dwin_bss(a6),a5
		move.w	dwin_bsssize(a6),d0
		lsl.w	#1,d0
		adda.w	d0,a5
		move.l	(sp)+,d0
		rts

open_adjustvals	movem.l	d0-a6,-(sp)
		bsr.s	get_adjustvals
		move.w	#(1<<NAME)+(1<<CLOSER)+(1<<FULLER)+(1<<MOVER)+(1<<SMALLER),d1
		bsr	open_dwinsub
		bsr.s	init_adjustvals
		movem.l	(sp)+,d0-a6
		rts
		
init_adjustvals	bclr	#w_botm_f,win_flags+2(a5)

		move.l	point_bss(a5),d0
		beq.s	.init_bss
		bsr	textframe_moved
		bra	.ok_exit
	
.init_bss	lea	adjv,a4
		move.l	a4,point_bss(a5)
		moveq	#0,d0
		moveq	#6,d1
		bsr	textframe_create
		move.w	d0,adjv_fghandle(a4)
		move.w	d0,d7
		move.l	obj_addr(a5),a0

		move.l	a0,-(sp)
	
		moveq	#ADJ_V1VAL,d0
		;bsr	obj_relativxy
		bsr	obj_rel_wrkxy

		add.w	win_woy(a5),d1
		move.l	d1,d3
		swap	d3
		add.w	win_wox(a5),d3
		swap	d3

		move.l	d2,d4
		moveq	#0,d1
		moveq	#tf_t_line,d2
		suba.l	a1,a1
		suba.l	a2,a2
		move.l	d7,d0
		move.w	#12,d5
		moveq	#0,d6
		suba.l	a0,a0
		bsr	textframe_install
	
		move.l	a0,-(sp)
		lea	adjv_font,a0
		move.w	d7,d0
		moveq	#0,d1
		bsr	textframe_fntchange
		move.l	(sp)+,a0

		move.l	tframe_edbss(a0),a0
		move.l	edl_dvdi(a0),-(sp)
		move.l	edl_norm_vdih(a0),d6
		swap	d6
		move.l	d6,-(sp)
	
		moveq	#ADJ_V2VAL,d0
		moveq	#1,d1
		bsr.s	.instlfrm
		moveq	#ADJ_V3VAL,d0
		moveq	#2,d1
		bsr.s	.instlfrm
		moveq	#ADJ_V4VAL,d0
		moveq	#3,d1
		bsr.s	.instlfrm
		moveq	#ADJ_V5VAL,d0
		moveq	#4,d1
		bsr.s	.instlfrm
		moveq	#ADJ_V6VAL,d0
		moveq	#5,d1
		bsr.s	.instlfrm	
		bra.s	.continue

.instlfrm	move.l	12(sp),a0
		move.l	d1,d3
		;moveq	#ADJ_V2VAL,d0
		;bsr	obj_relativxy
		bsr	obj_rel_wrkxy
		exg.l	d1,d3
		add.w	win_woy(a5),d3
		swap	d3
		add.w	win_wox(a5),d3
		swap	d3
		move.l	d2,d4
		;moveq	#1,d1
		moveq	#tf_t_line,d2
		suba.l	a1,a1
		move.w	d7,d0
		moveq	#12,d5
		move.l	4(sp),d6
		move.l	8(sp),a0
		bsr	textframe_install

		rts
	
.continue	lea	12(sp),sp
		move.l	#adjv_after,win_after(a5)
		bra.s	.ok_exit
		nop
	
.ok_exit	or.b	#1,ccr
.exit		rts	

	;Window #4
get_stats	move.l	d0,-(sp)
		move.l	dwin_bss(a6),a5
		moveq	#0,d0
		move.w	dwin_bsssize(a6),d0
		mulu	#3,d0
		adda.w	d0,a5
		move.l	(sp)+,d0
		rts

open_stats	movem.l	d0-a6,-(sp)
		bsr.s	get_stats
		move.w	#(1<<NAME)+(1<<CLOSER)+(1<<FULLER)+(1<<MOVER)+(1<<SMALLER),d1
		bsr.s	open_dwinsub
		movem.l	(sp)+,d0-a6
		rts
		
init_stats	movem.l	d0-a6,-(sp)

		bsr.s	get_stats
		move.l	obj_addr(a5),a0
	
		moveq	#0,d2
		lea	afps_real,a2
		moveq	#FPSCURNT1,d0
		bsr	set_tetxt_obj

		moveq	#0,d2
		moveq	#FPSAVRGE1,d0
		lea	afps_average,a2
		bsr	set_tetxt_obj
	
		moveq	#0,d2
		moveq	#FPSUPDS1,d0
		lea	afps_updates,a2
		bsr	set_tetxt_obj
	
		moveq	#0,d2
		moveq	#FPSRUNT1,d0
		lea	afps_seconds,a2
		bsr	set_tetxt_obj
	
		movem.l	(sp)+,d0-a6
		rts

*****************************
* Open a dialog window
open_dwinsub	tst.w	win_handle(a5)
		bne.s	.created
		move.w	d1,win_type(a5)
		clr.w	win_flags+2(a5)
.created	move.w	dwin_flags(a6),d1
		clr.b	win_flags+2(a5)
		and.w	#$ff00,d1
		or.w	d1,win_flags+2(a5)
		bsr	open_dwindow
		bcc.s	.error
.ok		or.b	#1,ccr
.error		rts

	
dwin_clicked	movem.l	d0-a6,-(sp)
		bsr	wait_br_timer
		bcs.s	.open_it
		bra.s	.err_exit	
.open_it
		and.w	#(1<<ks_rshft)+(1<<ks_lshft),d2
		bne.s	.open_adj
		bsr	win_set_topped
		bra.s	.ok_exit	
.open_adj	move.l	point_bss(a5),a0
		move.l	a0,adjv+adjv_demo
		bsr	get_adjustvals
		bsr	delete_window
		bsr	set_adjustvals
		lea	d_name(a0),a1
		move.l	a1,d6
		move.l	d6,win_title(a5)
		bsr	open_adjustvals	
.ok_exit	or.b	#1,ccr
		bra.s	.exit
.err_exit	and.b	#-2,ccr
.exit		movem.l	(sp)+,d0-a6
		rts
	

	;D0 = Number of demo to open
open_demowindow	movem.l	d0-a6,-(sp)

		move.l	demoes,d1
		beq.s	.no_demo
		move.l	d1,a0
		tst.w	d0
		beq.s	.got_entry
		subq.w	#1,d0

.get_demo:	move.l	d_next(a0),d1
		beq.s	.no_demo
		move.l	d1,a0
		dbra	d0,.get_demo

.got_entry	bsr.s	open_demowin

.exit:		movem.l	(sp)+,d0-a6
		rts
.no_demo:	and.b	#-2,ccr
		bra.s	.exit			

open_demowin	tst.l	d_rout(a0)
		beq	.no_demo
		tst.w	d_winh(a0)
		beq.s	.open_it

		move.l	d_winbss(a0),a5
		bsr	win_set_topped
		bra.s	.exit
			
.open_it	bsr	find_freeowbss
		bcc	.err
		move.w	owin_gadgets(a6),win_type(a5)
		lea	d_name(a0),a1
		move.l	a1,win_title(a5)
		clr.l	win_flags(a5)
		move.w	owin_flags(a6),win_flags+2(a5)
		moveq	#0,d0
		move.l	#$100030,d1
		;move.l	#(144<<16)+100,d2
		move.l	d_xres(a0),d2
		bsr	win_calc
		move.l	d1,win_x(a5)
		move.l	d2,win_w(a5)
		bsr	open_owindow
		bcc	.err
		move.l	a0,point_bss(a5)
		move.l	a5,d_winbss(a0)
		;move.w	win_handle(a5),demo_winh1
		move.w	win_handle(a5),d_winh(a0)
		;move.l	#setcoord,win_moved(a5)
		move.l	#move_dwin,win_moved(a5)
		move.l	#.cls_win,win_close(a5)
		move.l	#zoom_mode,win_fulled(a5)
		move.l	#dwin_clicked,win_button(a5)
		or.b	#1,ccr
		bra.s	.exit
.no_demo
.err		and.b	#-2,ccr
.exit		rts

.cls_win	movem.l	a0/d0,-(sp)
		move.l	point_bss(a5),a0
		move.l	d_sslj(a0),d_mscnljmp(a0)
		clr.w	d_winh(a0)
		clr.l	d_winbss(a0)
		clr.l	point_bss(a5)
		clr.b	d_zoom(a0)
		move.l	d_rout1x(a0),d_rout(a0)
		movem.l	(sp)+,a0/d0
		rts

move_dwin	move.l	8(a3),d1
		move.l	win_w(a5),d2
		bsr	set_owin_xywh
		rts
	


nomem		movem.l	d0-a6,-(sp)
		FORM_ALERT	#3,#no_memalrt
		movem.l	(sp)+,d0-a6
		rts
	
	