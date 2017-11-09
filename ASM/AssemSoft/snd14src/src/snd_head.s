;
; SNDH testprogram
; 
; January 4, 2000
; Anders Eriksson / Odd Skancke
; ae@dhs.nu         ozk@atari.org
; 
; snd_head.s


**********************************
gsinfo:		reg d0-a6
get_songinfo:	movem.l	gsinfo,-(sp)

	;Make sure the timer-setup structure is cleared
		lea	timer_setup(pc),a0
		movea.l	a0,a2
		moveq	#(TimFreq_ssize/2)-1,d0
.clr_tf:	clr.w	(a0)+
		dbra	d0,.clr_tf

		move.w	#'TA',d2
		bsr.s	.get_timerval
		bcc.s	.ntA
		move.w	d0,timerA_freq(a2)
		move.b	d1,timerA_div(a2)
		move.b	d2,timerA_data(a2)
		moveq	#'A',d0
		bra	.done_timers
.ntA:		move.w	#'TB',d2
		bsr.s	.get_timerval
		bcc.s	.ntB
		move.w	d0,timerB_freq(a2)
		move.b	d1,timerB_div(a2)
		move.b	d2,timerB_data(a2)
		moveq	#'B',d0
		bra	.done_timers
.ntB:		move.w	#'TC',d2
		bsr.s	.get_timerval
		bcc.s	.ntC
		move.w	d0,timerC_freq(a2)
		move.b	d1,timerC_div(a2)
		move.b	d2,timerC_data(a2)
		moveq	#'C',d0
		bra	.done_timers
.ntC:		move.w	#'TD',d2
		bsr.s	.get_timerval
		bcc.s	.use_deftimer
		move.w	d0,timerD_freq(a2)
		move.b	d1,timerD_div(a2)
		move.b	d2,timerD_data(a2)
		moveq	#'D',d0
		bra.s	.done_timers

.get_timerval:	bsr	search_sndh_wp
		beq.s	.no_TV_found
		lea	-20(sp),sp
		movea.l	sp,a0
		move.l	d2,a1
		moveq	#9,d0
.cpy_TV:	move.b	(a1)+,(a0)+
		beq.s	.got_asciTV
		dbra	d0,.cpy_TV
.got_asciTV:	movea.l	sp,a0
		move.l	d2,a1
		jsr	ascidectobin
		bcc.s	.asciconv_error
		lea	20(sp),sp
		move.l	#12288,d2
		divu.w	d0,d2
		moveq	#7,d1
		and.l	#$ffff,d2
		or.b	#1,ccr
		rts
.asciconv_error:lea	20(sp),sp
.no_TV_found:	and.b	#-2,ccr
		rts
		
.use_deftimer:	move.w	#50,timerC_freq(a2)
		move.b	#246,timerC_data(a2)
		move.b	#7,timerC_div(a2)
		moveq	#'C',d0
		bset	#31,d0
		lea	-4(sp),a1
		move.w	#'50',(a1)
		clr.b	2(a1)
		
.done_timers:	lea	t_method(pc),a2
		tst.l	d0
		bpl.s	.no_t_def
		move.b	#'*',(a2)+
.no_t_def:	lea	t_timer(pc),a0
.cpy_ts:	move.b	(a0)+,(a2)+
		bne.s	.cpy_ts
		move.b	d0,-1(a2)
		move.b	#',',(a2)+
		move.b	#' ',(a2)+
.cpy_speed:	move.b	(a1)+,(a2)+
		bne.s	.cpy_speed
		move.b	#'H',-1(a2)
		move.b	#'z',(a2)+
		clr.b	(a2)

;...........................................................................................
	;Search for composer info..
.composer:	lea	t_no_inf(pc),a2
		move.l	#'COMM',d2
		bsr	search_sndh
		beq.s	.no_comm
		move.l	d2,a2
.no_comm:	move.l	a2,composer_txt

;..................................................................................
	;Search for Title info
		lea	t_no_inf(pc),a2
		move.l	#'TITL',d2
		bsr	search_sndh
		beq.s	.no_titl
		move.l	d2,a2
.no_titl:	move.l	a2,title_txt

;..................................................................................
	;Search for Ripper info
		lea	t_no_inf(pc),a2
		move.l	#'RIPP',d2
		bsr	search_sndh
		beq.s	.no_ripp
		move.l	d2,a2
.no_ripp:	move.l	a2,ripper_txt

         	
;..................................................................................
	;Search for conversion info
		lea	t_no_inf(pc),a2
		move.l	#'CONV',d2
		bsr	search_sndh
		beq.s	.no_conv
		move.l	d2,a2
.no_conv:	move.l	a2,conversion_txt

;..................................................................................
	;Search for ## (number of tunes) info
		lea	t_no_inf(pc),a2
		move.w	#'##',d2
		bsr	search_sndh_w
		bne.s	.sngs

		lea	t_songs(pc),a2
		move.w	#1,songs
		move.b	#'0',(a2)
		move.b	#'1',1(a2)
		clr.b	2(a2)
		bra.s	.no_sngs

.sngs:		lea	t_songs(pc),a2
		move.w	d2,(a2)

		move.w	#$FF,d1
		and.w	d2,d1           ; 10^0
		lsr.w	#8,D2           ; 10^1

		subi.b	#'0',d2
		subi.b	#'0',d1
		mulu	#10,d2
		add.w	d1,d2
		move.w	d2,songs
.no_sngs:	move.l	#t_songs,songs_txt

		move.w	#1,current_sng
;..................................................................................
	;Check for !V tag (!V = play off VBI)
		clr.b	use_vbl
		move.w	#'!V',d2
		bsr	search_sndh_w
		beq.s	.no_vblmode

	;Make user select use of VBI or Timer C
		lea	vbi_or_tc(pc),a0
		bsr	print_text
.sel_vort:	bsr	get_key
		cmp.b	#'t',d0
		beq.s	.vbi_use_c
		cmp.b	#'v',d0
		bne.s	.sel_vort

		lea	timer_setup(pc),a2
		clr.w	timerA_freq(a2)
		clr.w	timerB_freq(a2)
		clr.w	timerC_freq(a2)
		clr.w	timerD_freq(a2)
		lea	t_vblon(pc),a2
		st	use_vbl
		bra.s	.set_method_inf
				
.vbi_use_c:	lea	t_method(pc),a2
.vget_end:	tst.b	(a2)+
		bne.s	.vget_end
		subq.l	#1,a2
		move.l	a0,-(sp)
		lea	t_vbiovr(pc),a0
.cpy_vbiovr:	move.b	(a0)+,(a2)+
		bne.s	.cpy_vbiovr
		move.l	(sp)+,a0
.no_vblmode:	lea	t_method(pc),a2
.set_method_inf:move.l	a2,method_txt
;..................................................................................
	;Check for MuMo tag (music mon)
		clr.b	musicmon
		move.l	#'MuMo',d2
		bsr	search_sndh
		beq.s	.mumon_checked
		st.b	musicmon
.mumon_checked:
		movem.l	(sp)+,gsinfo
		rts
;..................................................................................
vbi_or_tc:	dc.b "Found !V tag!! Actually use VBI",13,10
		dc.b "or use default timer (Timer C)?",13,10
		dc.b "T = timer, V = VBI",0
		even
;..................................................................................
search_sndh:	movea.l	song_address(pc),a3
		move.w	#MAX_HEADER-1,d7
		move.l	(a3)+,d1
.search_sndh:	cmp.l	d2,d1
		beq.s	.wow
		lsl.l	#8,d1
		move.b	(a3)+,d1
		dbra	d7,.search_sndh
		moveq	#0,d2
		rts
.wow:		move.l	a3,d2
		rts
;..................................................................................
search_sndh_w:	movea.l	song_address(pc),a3
		move.w	#MAX_HEADER-1,d7
		move.w	(a3)+,d1
.search_sndh:	cmp.w	d2,d1
		beq.s	.wow
		lsl.w	#8,d1
		move.b	(a3)+,d1
		dbra	d7,.search_sndh
		moveq	#0,d2
		rts
.wow:		move.b	(a3)+,d2
		lsl.w	#8,d2
		move.b	(a3)+,d2
		rts
;..................................................................................
search_sndh_wp:	movea.l	song_address(pc),a3
		move.w	#MAX_HEADER-1,d7
		move.w	(a3)+,d1
.search_sndh:	cmp.w	d2,d1
		beq.s	.wow
		lsl.w	#8,d1
		move.b	(a3)+,d1
		dbra	d7,.search_sndh
		moveq	#0,d2
		rts
.wow:		move.l	a3,d2
		rts
;..................................................................................
ascidectobin:	movem.l	d1-3/a0-1,-(sp)
		moveq	#0,d0
		movea.l	a0,a1
.adecbin1:	tst.b	(a1)+
		bne.s	.adecbin1
		subq.l	#1,a1
		move.l	a1,d1
		sub.l	a0,d1
		subq.l	#1,d1
		blt.s	.ok
		moveq	#0,d2
		moveq	#0,d3
		bra.s	.adecbin3
.adecbin2:	move.l	d0,d2
		lsl.l	#2,d0
		add.l	d2,d0
		lsl.l	#1,d0
.adecbin3:	move.b	(a0)+,d3
		cmp.b	#48,d3
		blo.s	.error
		cmp.b	#57,d3
		bhi.s	.error
		sub.b	#48,d3
		add.l	d3,d0
		dbra	d1,.adecbin2
.ok:		or.b	#1,ccr
		bra.s	.exit
.error:		and.b	#-2,ccr
.exit:		movem.l	(sp)+,d1-3/a0-1
		rts
;..................................................................................
print_text:	movem.l	d0-2/a0-2,-(sp)
		move.l	a0,-(sp)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp
		movem.l	(sp)+,d0-2/a0-2
		rts
print_text_cl:	move.l	a0,-(sp)
		bsr	print_text
		lea	.crlf(pc),a0
		bsr	print_text
		move.l	(sp)+,a0
		rts
.crlf:		dc.b 13,10,0,0
;..................................................................................
get_key:	movem.l	d1-2/a0-2,-(sp)
		move.w	#1,-(sp)
		trap	#1
		addq.l	#2,sp
		and.l	#$ff,d0
		cmp.b	#65,d0
		blo.s	.exit
		cmp.b	#90,d0
		bhi.s	.exit
		add.b	#32,d0

.exit		movem.l	(sp)+,d1-2/a0-2
		rts

		section	bss

composer_txt:	ds.l	1					;Address of composer text
title_txt:	ds.l	1					;Address of title text
ripper_txt:	ds.l	1					;address of ripper text
conversion_txt:	ds.l	1					;Address of conversion text
songs_txt:	ds.l	1
method_txt:	ds.l	1

songs:		ds.w	1
current_sng:	ds.w	1

		section	text