init_bss	bset	#d_mous_f,dialog_flags+1(a6)
		bset	#d_gsbx_f,dialog_flags+1(a6)
	
	;Setting up the BSS for window holding settings dialog..
		move.l	dwin_bss(a6),a5
		moveq	#0,d0
		moveq	#SETTINGS,d1
		GET_TREE_ADDR
		beq	quit
		move.l	a0,d7
		INIT_DWIND_RSC Settings

		move.l	#do_settings,obj_rout(a5)
		move.l	#wt_settings,win_title(a5)
		move.l	#wti_settings,win_ititle(a5)
		move.l	#update_it,win_redraw(a5)
		move.l	#setdcoord,win_moved(a5)
		move.l	#barify_dw,win_fulled(a5)
	
		move.l	dwin_bss(a6),a5
		adda.w	dwin_bsssize(a6),a5
		moveq	#0,d0
		moveq	#ABOUT,d1
		GET_TREE_ADDR
		beq	quit
		move.l	a0,d7
		INIT_DWIND_RSC	About
		move.l	#wt_about,win_title(a5)
		move.l	#wti_about,win_ititle(a5)
		move.l	#do_about,obj_rout(a5)
		move.l	#update_it,win_redraw(a5)
		move.l	#setdcoord,win_moved(a5)
		move.l	#barify_dw,win_fulled(a5)
	
		bsr	get_adjustvals
		moveq	#0,d0
		moveq	#ADJUST,d1
		GET_TREE_ADDR
		beq	quit
		move.l	a0,d7
		INIT_DWIND_RSC Adjust
	
		move.l	#wt_adj,win_title(a5)
		move.l	#wti_adj,win_ititle(a5)
		move.l	#do_adjustvals,obj_rout(a5)
		move.l	#update_it,win_redraw(a5)
		move.l	#setdcoord,win_moved(a5)
		move.l	#barify_dw,win_fulled(a5)
	
		bsr	init_adjustvals

		bsr	get_stats
		moveq	#0,d0
		moveq	#STATS,d1
		GET_TREE_ADDR
		beq	quit
		move.l	a0,d7
		INIT_DWIND_RSC	Stats
	
		move.l	#wt_stats,win_title(a5)
		move.l	#wti_stats,win_ititle(a5)
		move.l	#do_stats,obj_rout(a5)
		move.l	#update_it,win_redraw(a5)
		move.l	#setdcoord,win_moved(a5)
		move.l	#barify_dw,win_fulled(a5)
	
		bsr	get_loading
		moveq	#0,d0
		moveq	#LOADING,d1
		GET_TREE_ADDR
		beq	quit
		move.l	a0,d7
		INIT_DWIND_RSC	Loading
		move.l	#update_it,win_redraw(a5)
		move.l	#setdcoord,win_moved(a5)

		moveq	#0,d0
		moveq	#ZOOMPOP,d1
		GET_TREE_ADDR
		beq	quit
	IFNE	use_aslb
		jsr	inst_dialdraw
	ENDC	;use_aslb
	

		moveq	#0,d0
		moveq	#MENU,d1
		GET_TREE_ADDR
		beq	quit
		move.l	a0,menu_addr(a6)
		tst.b	acc_flag(a6)
		bne.s	.acc
		MENU_BAR	a0,#1
	
.acc		bsr	set_output
		bsr	set_clipping
