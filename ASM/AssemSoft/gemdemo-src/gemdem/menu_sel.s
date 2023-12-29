	text
menu_selected	move.l	6(a3),d0
		swap	d0
		cmp.w	#MT_ABOUT,d0
		beq.s	men_about
		cmp.w	#MT_FILE,d0
		beq.s	men_file
		cmp.w	#MT_OPTIONS,d0
		beq	men_options
		cmp.w	#MT_DEMOES,d0
		beq	men_demoes
	
menu_done	move.w	6(a3),d0
		move.l	menu_addr(a6),a0
		MENU_TNORMAL	a0,d0,#1
		rts
	
men_about	swap	d0
		cmp.w	#ME_ABOUT,d0
		bne.s	menu_done		;remove when about dialog present
		bsr	open_about
		bra.s	menu_done
	
men_file	swap	d0

.mf1		cmp.w	#ME_QUIT,d0
		bne.s	.mf2
		jmp	app_terminate

.mf2		cmp.w	#ME_STATS,d0
		bne.s	.mf3
		bsr	open_stats
		bra	menu_done

.mf3		bra	menu_done

**
men_demoes	swap	d0
		cmp.w	#ME_LDEM0,d0
		blo.s	.mdem1
		cmp.w	#ME_LDEM9,d0
		bhi.s	.mdem1
		sub.w	#ME_LDEM0,d0
		jsr	open_demowindow
		bra	menu_done
.mdem1		bra	menu_done
	
**
men_options	swap	d0
		cmp.w	#ME_SETTINGS,d0
		bne.s	.mo1
		bsr	open_settings
		bra	menu_done
.mo1		cmp.w	#ME_CONVNO,d0
		bne.s	.mo2
		bsr	conv_videlmode
		clr.b	gfxmode
		bra	menu_done
.mo2		cmp.w	#ME_CONV15B,d0
		bne.s	.mo3
		bsr	conv_15bmode
		move.b	#1,gfxmode
		bra	menu_done
.mo3		cmp.w	#ME_CONV16B,d0
		bne.s	.mo4
		bsr	conv_16bmode
		move.b	#2,gfxmode
		bra	menu_done
	
.mo4		cmp.w	#ME_OUTPUT,d0
		bne.s	.mo5
		not.b	outp_flag
		bsr	set_output
		bra	menu_done
.mo5		cmp.w	#ME_CLIP,d0
		bne.s	.mo6
		not.b	clipping
		bsr	set_clipping
		bra	menu_done
.mo6		cmp.w	#ME_CONV15BM,d0
		bne.s	.mo7
		bsr	conv_15bmmode
		bra	menu_done
.mo7		bra	menu_done



