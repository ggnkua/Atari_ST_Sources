;
; SNDH testprogram
; 
; May 14, 2000
; Anders Eriksson / Odd Skancke
; ae@dhs.nu         ozk@atari.org
; 
; snd_play.s


hw_mfp		=	$fffffa00
hw_mfpgpip	=	$fffffa01
hw_mfpaer	=	$fffffa03
hw_mfpddr	=	$fffffa05
hw_mfpiera	=	$fffffa07
hw_mfpierb	=	$fffffa09
hw_mfpipra	=	$fffffa0b
hw_mfpiprb	=	$fffffa0d
hw_mfpisra	=	$fffffa0f
hw_mfpisrb	=	$fffffa11
hw_mfpimra	=	$fffffa13
hw_mfpimrb	=	$fffffa15
hw_mfpvr	=	$fffffa17
hw_mfptacr	=	$fffffa19
hw_mfptbcr	=	$fffffa1b
hw_mfptcdcr	=	$fffffa1d
hw_mfptadr	=	$fffffa1f
hw_mfptbdr	=	$fffffa21
hw_mfptcdr	=	$fffffa23
hw_mfptddr	=	$fffffa25
hw_mfpscr	=	$fffffa27
hw_mfpucr	=	$fffffa29
hw_mfprsr	=	$fffffa2b
hw_mfptsr	=	$fffffa2d
hw_mfpudr	=	$fffffa2f

iera		=	$7
ierb		=	$9
imra		=	$13
imrb		=	$15
vr		=	$17
tacr		=	$19
tbcr		=	$1b
tcdcr		=	$1d
tadr		=	$1f
tbdr		=	$21
tcdr		=	$23
tddr		=	$25

vec_buserr	=	$8
vec_div0	=	$14
vec_privilege	=	$20
vec_spurious	=	$60

vec_VBI		=	$70		;Vblank
vec_timer_d	=	$110		;Bit 4 in IERB. Timer D interrupt vector (RS232 baud rate generator, not used in Falcon030)
vec_timer_c	=	$114		;Bit 5 in IERB. Timer C interrupt vector (200Hz system clock)
vec_timer_b	=	$120		;bit 0 in IERA. Timer B (Horizontal blank counter)
vec_timer_a	=	$134		;bit 5 in IERA. Timer A (DMA sound complete)

conterm		=	$484

hw_giselect	=	$ffff8800
hw_giwrite	=	$ffff8802



		section	text


save_hdw:	movem.l	d0-a6,-(sp)

		clr.b	hw_mfptacr.w			;Stop Timer A    
	
		move.w	sr,-(sp)
		move.w	#$2700,sr
		
		lea	save_hardware(pc),a0
	
		;move.w	$FFFF8242.w,(a0)+
		move.w	$0484.w,(a0)+
		move.b	hw_mfptacr.w,(a0)+
		move.b	hw_mfptbcr.w,(a0)+
		move.b	hw_mfpvr.w,(a0)+
		move.b	hw_mfpimra.w,(a0)+
		move.b	hw_mfpimrb.w,(a0)+
		move.b	hw_mfpiera.w,(a0)+
		move.b	hw_mfpierb.w,(a0)+
		move.b	hw_mfptadr.w,(a0)+
		move.b	hw_mfptddr.w,(a0)+
		move.b	hw_mfptbdr.w,(a0)+
		move.l	vec_timer_d.w,(a0)+
		move.l	vec_timer_c.w,(a0)+
		move.l	vec_timer_a.w,(a0)+
		move.l	vec_timer_b.w,(a0)+
		move.l	vec_buserr.w,(a0)+		; Exceptions (fr Falcon!)
		move.l	vec_div0.w,(a0)+		; Zero Divide
		move.l	vec_privilege.w,(a0)+		; Privilege Violation

		moveq	#8-1,d7
		lea	vec_spurious.w,a1		; Spurious IRQ + Autovecs (Timer)...
.sav_autov:	move.l	(a1)+,(a0)+
		dbra	d7,.sav_autov
	
		move.w	(sp)+,sr
		
		jsr	get_cpu_type
		cmp.w	#20,d0
		blt.s	.no_cache
		opt	p=68030
		movec	cacr,d1
		move.l	d1,(a0)+
		opt	p=68000
.no_cache:	
		movem.l	(sp)+,d0-a6
		rts

restore_hdw:	movem.l	d0-a6,-(sp)

		clr.b	hw_mfptacr.w			; Stop Timer A    

		move.w	sr,-(sp)
		move.w	#$2700,sr

		lea	save_hardware(pc),a0

		;move.w	(a0)+,$ffff8242.w
		move.w	(a0)+,$0484.w
		move.b	(a0)+,hw_mfptacr.w
		move.b	(a0)+,hw_mfptbcr.w
		move.b	(a0)+,hw_mfpvr.w
		move.b	(a0)+,hw_mfpimra.w
		move.b	(a0)+,hw_mfpimrb.w
		move.b	(a0)+,hw_mfpiera.w
		move.b	(a0)+,hw_mfpierb.w
		move.b	(a0)+,hw_mfptadr.w
		move.b	(a0)+,hw_mfptddr.w
		move.b	(a0)+,hw_mfptbdr.w
		move.l	(a0)+,vec_timer_d.w
		move.l	(a0)+,vec_timer_c.w
		move.l	(a0)+,vec_timer_a.w
		move.l	(a0)+,vec_timer_b.w
		move.l	(a0)+,vec_buserr.w
		move.l	(a0)+,vec_div0.w
		move.l	(a0)+,vec_privilege.w

		moveq	#8-1,d7
		lea	vec_spurious.w,a1
.res_autov:	move.l	(a0)+,(a1)+
		dbra	d7,.res_autov
		
		move.w	(sp)+,sr
		
		jsr	get_cpu_type
		cmp.w	#20,d0
		blt.s	.no_cache
		opt	p=68030
		move.l	(a0)+,d1
		movec	d1,cacr
		opt	p=68000
.no_cache:
		movem.l	(sp)+,d0-a6
		rts
;-------------------------------------------------------------------------------------
start_play:	movem.l	d0-a6,-(sp)

		tst.b	playing
		bne	.exit

		bsr	set_super
		
		bsr	save_hdw
	
		jsr	get_cpu_type
		cmp.w	#20,d0
		blt.s	.no_shadow
		move.w	#$2700,sr
		move.l	#bus_error,vec_buserr.w
		move.l	#.rte,d0
		move.l	d0,vec_spurious.w
		move.l	d0,vec_div0.w
		move.l	d0,vec_privilege.w
		move.w	#$2300,sr

.no_shadow:	bclr	#0,conterm.w			; Tastaturklick aus (nur bei Backgrd.)    

		lea	hw_mfp.w,a0
		lea	timer_setup(pc),a2

		tst.b	use_vbl
		bne.s	.use_vbl
		
		move.w	timerA_freq(a2),d0
		bne	.use_tA

		move.w	timerB_freq(a2),d0
		bne	.use_tB

		move.w	timerC_freq(a2),d0
		bne	.use_tC
		
		move.w	timerD_freq(a2),d0
		bne.s	.use_tD
		
		tst.b	use_vbl
		beq.s	.use_vbl
		tst.b	musicmon
		bne	.start_it

.use_vbl:	clr.w	timerA_freq(a2)
		clr.w	timerB_freq(a2)
		clr.w	timerD_freq(a2)
		clr.w	timerC_freq(a2)
		move.w	#50,speed_Hz
		move.w	#50,timediv
		move.l	#calledplay_vbi,callplay_exit
		move.l	vec_VBI.w,old_vbl
		move.l	#timer_a,vec_VBI.w
		bra	.start_it	
		
.force_tA:	moveq	#50,d0
		move.w	d0,timerC_freq(a2)
		move.b	#246,timerC_data(a2)
		move.b	#7,timerC_div(a2)
		clr.b	use_vbl
		bra	.use_tC

.use_tD:	move.w	#$2700,sr
		move.w	d0,speed_Hz
		move.w	d0,timediv
		and.b	#%11110000,tcdcr(a0)		;Stop timer D
		move.l	#calledplay_tD,callplay_exit
		move.l	#timer_a,vec_timer_d.w		;Set new Timer A Interrupt routine    
		bclr	#3,vr(a0)			;Set "Automatic End-of-Interrupt" mode    
		bset	#4,imrb(a0)			;Interrupt mask for Timer A    
		bset	#4,ierb(a0)			;Turn on the interrup for Timer A    
		move.b	timerD_data(a2),speed
		move.b	speed(pc),tddr(a0)		;Set the Timer A data register    
		move.b	timerD_div(a2),d0
		and.b	#7,d0
		or.b	d0,tcdcr(a0)	 		; Timer mit Vorteiler 1:200 starten    
		bra	.start_it

.use_tA:	move.w	#$2700,sr
		move.w	d0,speed_Hz
		move.w	d0,timediv
		clr.b	tacr(a0)			;Stop Timer A    
		move.l	#calledplay_tA,callplay_exit
		move.l	#timer_a,vec_timer_a.w		;Set new Timer A Interrupt routine    
		bclr	#3,vr(a0)			;Set "Automatic End-of-Interrupt" mode    
		bset	#5,imra(a0)			;Interrupt mask for Timer A    
		bset	#5,iera(a0)			;Turn on the interrup for Timer A    
		move.b	timerA_data(a2),speed
		move.b	speed(pc),tadr(a0)		;Set the Timer A data register    
		move.b	timerA_div(a2),tacr(a0) 	; Timer mit Vorteiler 1:200 starten    
		bra	.start_it

.use_tB:	move.w	#$2700,sr
		move.w	d0,speed_Hz
		move.w	d0,timediv
		clr.b	tbcr(a0)
		move.l	#calledplay_tB,callplay_exit
		move.l	#timer_a,vec_timer_b.w		;Set new Timer A Interrupt routine    
		bclr	#3,vr(a0)			;Set "Automatic End-of-Interrupt" mode    
		bset	#0,imra(a0)			;Interrupt mask for Timer A    
		bset	#0,iera(a0)			;Turn on the interrup for Timer A    
		move.b	timerB_data(a2),speed
		move.b	speed(pc),tbdr(a0)		;Set the Timer A data register    
		move.b	timerB_div(a2),tbcr(a0)		; Timer mit Vorteiler 1:200 starten    
		bra	.start_it

.use_tC:	move.w	#$2700,sr
		move.w	d0,speed_Hz
		move.w	d0,timediv
		move.l	vec_timer_c.w,old_tC
		move.w	#200,tC_Hz
		move.l	#timer_c,vec_timer_c.w

.start_it:	moveq	#0,d0
		move.w	current_sng(pc),d0
		movea.l	song_address(pc),a0
		move.l	musicmon_buff(pc),d1
		jsr	(A0)				; Soundinit    
		stop	#$2300				; ab geht's...    

		st.b	playing
		bsr	set_user
.exit:		movem.l	(sp)+,d0-a6
		rts

.rte:		rte
;-------------------------------------------------------------------------------------
stop_play:	movem.l	d0-a6,-(sp)

		tst.b	playing
		beq	.exit
		
		bsr	set_super
		
		move.w	sr,-(sp)
		
		move.l	sp,.stacksave
	
		lea	temp_stack,sp

		move.w	#$2700,sr

		movea.l	song_address(pc),a0
		moveq	#0,d0
		jsr	4(a0)
		
		move.w	#$2700,sr
		tst.b	use_vbl
		beq.s	.no_vbl
		move.l	old_vbl,vec_VBI.w
		clr.l	old_vbl
		bra.s	.notC
		
.no_vbl:	lea	timer_setup(pc),a0
		tst.w	timerA_freq(a0)
		beq.s	.notA
		clr.b	hw_mfptacr.w			;Stop Timer A
.notA:		tst.w	timerB_freq(a0)
		beq.s	.notB
		clr.b	hw_mfptbcr.w
.notB:		tst.w	timerD_freq(a0)
		beq.s	.notD
		and.b	#%11110000,hw_mfptcdcr.w
.notD:		tst.w	timerC_freq(a0)
		beq.s	.notC

		move.l	old_tC(pc),vec_timer_c.w
.notC:		

		move.l	.stacksave,sp
		move.w	(sp),sr
		
		bsr	restore_hdw
		clr.l	old_vbl

		move.w	#$2700,sr
		move.b	#$8,hw_giselect.w
		move.b	#0,hw_giwrite.w
		move.b	#$9,hw_giselect.w
		move.b	#0,hw_giwrite.w
		move.b	#$a,hw_giselect.w
		move.b	#0,hw_giwrite.w
	
		move.l	.stacksave,sp
		move.w	(sp)+,sr
	
		sf.b	playing
		sf.b	pause
		bsr	set_user

.exit:		movem.l	(sp)+,d0-a6
		rts	

.stacksave:	ds.l	1
.srsave:	ds.w	1
;-------------------------------------------------------------------------------------
new_play:	movem.l	d0-a6,-(sp)

		tst.b	playing
		beq.s	.not_playing
		bsr	stop_play
		
.not_playing:	bsr	set_super

		moveq	#0,d0
		move.w	current_sng(pc),d0
		movea.l	song_address(pc),a0
		jsr	(A0)				; Soundinit    

		bsr	set_user

		movem.l	(sp)+,d0-a6
		rts
;-------------------------------------------------------------------------------------
;This is the timer routine used for timer A, B and D. Also used when installing as vbl rout.

timer_a:        movem.l	D0-A6,-(SP)
              
		tst.b	pause
		beq.s	.no_pause
		
		moveq	#0,d0
		lea	hw_giselect.w,a0
		move.b	#8,(a0)
		lea	hw_giwrite.w,a1
		clr.b	(a1)
		move.b	#9,(a0)
		clr.b	(a1)
		move.b	#$a,(a0)
		clr.b	(a1)
		
		bra.s	.end_tima
	
.no_pause:	movea.l	song_address(pc),a0
		jsr	8(A0)	; Sound spielen

		subq.w	#1,timediv
		bne.s	.end_tima
		move.w	speed_Hz(pc),timediv		;#50,timediv

		moveq	#60,d2
		lea	hours(pc),a0
		move.b	5(a0),d0
		addq.b	#1,d0
		move.b	4(a0),d1
		cmp.b	d2,d0
		bls.s	.time_ok
		clr.b	d0
		addq.b	#1,d1
		cmp.b	d2,d1
		bls.s	.time_ok
		clr.b	d1
		addq.l	#1,(a0)

.time_ok:	move.b	d0,5(a0)
		move.b	d1,4(a0)
		move.b	11(a0),d0
		addq.b	#1,d0
		move.b	10(a0),d1
		cmp.b	d2,d0
		bls.s	.time_ok1
		clr.b	d0
		addq.b	#1,d1
		cmp.b	d2,d1
		bls.s	.time_ok1
		clr.b	d1
		addq.l	#1,6(a0)
.time_ok1:	move.b	d0,11(a0)
		move.b	d1,10(a0)
		
.end_tima:	movem.l	(SP)+,D0-A6
		move.l	callplay_exit(pc),-(sp)
		rts

callplay_exit:	ds.l	1

calledplay_tA:	and.b	#%11011111,hw_mfpisra.w		 ; da SEI
		move.b	speed(pc),hw_mfptadr.w
		rte
calledplay_tB:	and.b	#%11111110,hw_mfpisra.w
		move.b	speed(pc),hw_mfptbdr.w
		rte
calledplay_tD:	and.b	#%11101111,hw_mfpisrb.w
		move.b	speed(pc),hw_mfptddr.w
		rte
calledplay_vbi:
.vbl_end:	move.l	old_vbl(pc),-(sp)
		rts
;--------------------------------------------------------------------------------------
timer_c:	move.l	d0,-(sp)
		move.w	speed_Hz(pc),d0
		sub.w	d0,tC_Hz
		ble.s	.do_tc
		move.l	(sp),d0
.no_do:		move.l	old_tC(pc),(sp)
		rts
		
.do_tc:		move.l	(sp)+,d0
		movem.l	D0-A6,-(SP)

		move.w	sr,-(sp)
		move.w	#$2300,sr

		add.w	#200,tC_Hz

		tst.b	pause
		beq.s	.no_pause
	
		moveq	#0,d0
		lea	hw_giselect.w,a0
		move.b	#8,(a0)
		lea	hw_giwrite.w,a1
		clr.b	(a1)
		move.b	#9,(a0)
		clr.b	(a1)
		move.b	#$a,(a0)
		clr.b	(a1)
		
		bra.s	.end_tima
	
.no_pause:	movea.l	song_address(pc),a0
		jsr	8(A0)	; Sound spielen

		subq.w	#1,timediv
		bne.s	.end_tima
		move.w	speed_Hz(pc),timediv		;#50,timediv

		moveq	#60,d2
		lea	hours(pc),a0
		move.b	5(a0),d0
		addq.b	#1,d0
		move.b	4(a0),d1
		cmp.b	d2,d0
		bls.s	.time_ok
		clr.b	d0
		addq.b	#1,d1
		cmp.b	d2,d1
		bls.s	.time_ok
		clr.b	d1
		addq.l	#1,(a0)

.time_ok:	move.b	d0,5(a0)
		move.b	d1,4(a0)
		move.b	11(a0),d0
		addq.b	#1,d0
		move.b	10(a0),d1
		cmp.b	d2,d0
		bls.s	.time_ok1
		clr.b	d0
		addq.b	#1,d1
		cmp.b	d2,d1
		bls.s	.time_ok1
		clr.b	d1
		addq.l	#1,6(a0)
.time_ok1:	move.b	d0,11(a0)
		move.b	d1,10(a0)
		
.end_tima:	move.w	(sp)+,sr
		movem.l	(SP)+,D0-A6
		move.l	old_tC(pc),-(sp)
		rts
;---------------------------------------------------------------------------------------
force_play:	movem.l	d0-a6,-(sp)

		tst.l	song_address
		beq	.end_tima
		tst.b	playing
		beq	.end_tima
		tst.b	pause
		bne	.end_tima

		tst.w	timer_setup+timerC_freq
		beq	.end_tima
		bsr	set_super
		bsr.s	.play_it
		bsr.s	.play_it
		bsr.s	.play_it
		bsr.s	.play_it
		bsr.s	.play_it
		bsr.s	.play_it
		bsr	set_user
		bra.s	.end_tima
						
.play_it:	movea.l	song_address(pc),a0

		move.w	sr,-(sp)
		move.w	#$2700,sr
		jsr	8(A0)	; Sound spielen
		move.w	(sp)+,sr
		
		subq.w	#1,timediv
		bne.s	.end
		move.w	speed_Hz(pc),timediv

		moveq	#60,d2
		lea	hours(pc),a0
		move.b	5(a0),d0
		addq.b	#1,d0
		move.b	4(a0),d1
		cmp.b	d2,d0
		bls.s	.time_ok
		clr.b	d0
		addq.b	#1,d1
		cmp.b	d2,d1
		bls.s	.time_ok
		clr.b	d1
		addq.l	#1,(a0)

.time_ok:	move.b	d0,5(a0)
		move.b	d1,4(a0)
		move.b	11(a0),d0
		addq.b	#1,d0
		move.b	10(a0),d1
		cmp.b	d2,d0
		bls.s	.time_ok1
		clr.b	d0
		addq.b	#1,d1
		cmp.b	d2,d1
		bls.s	.time_ok1
		clr.b	d1
		addq.l	#1,6(a0)
.time_ok1:	move.b	d0,11(a0)
		move.b	d1,10(a0)
.end:		rts

.end_tima:	movem.l	(SP)+,D0-A6
		rts

;---------------------------------------------------------------------------------------
toggle_pause:	tst.b	pause
		beq.s	.set_on
		bsr.s	set_pause_off
		rts
.set_on		bsr.s	set_pause_on
		rts

set_pause_on:	movem.l	d0/a0-2,-(sp)

		tst.b	pause
		bne.s	.exit

		bsr	set_super
		move.w	sr,-(sp)
		move.w	#$2700,sr
		
		lea	timer_setup(pc),a0
		lea	pause_save(pc),a1
		clr.w	(a1)
		clr.b	2(a1)

		tst.w	timerA_freq(a0)
		bne.s	.chk_B
		move.b	hw_mfptacr.w,(a1)
		clr.b	hw_mfptacr.w
.chk_B:		tst.w	timerB_freq(a0)
		bne.s	.chk_D
		move.b	hw_mfptbcr.w,1(a1)
		clr.b	hw_mfptbcr.w
.chk_D:		tst.w	timerD_freq(a0)
		bne.s	.pause_set
		move.b	hw_mfptcdcr.w,2(a1)
		and.b	#%11110000,hw_mfptcdcr.w
.pause_set:	st.b	pause
		move.w	(sp)+,sr
		bsr	set_user
		
.exit		movem.l	(sp)+,d0/a0-2
		rts

set_pause_off:	movem.l	d0/a0-2,-(sp)

		tst.b	pause
		beq.s	.exit
		
		bsr	set_super
		move.w	sr,-(sp)
		move.w	#$2700,sr
		
		lea	pause_save(pc),a0
		move.b	(a0)+,d0
		beq.s	.no_A
		move.b	d0,hw_mfptacr.w
.no_A:		move.b	(a0)+,d0
		beq.s	.no_B
		move.b	d0,hw_mfptbcr.w
.no_B:		move.b	(a0),d0
		beq.s	.no_D
		and.b	#7,d0
		and.b	#%11110000,hw_mfptcdcr.w
		or.b	d0,hw_mfptcdcr.w
.no_D:		sf.b	pause
		move.w	(sp)+,sr
		bsr	set_user
		
.exit:		movem.l	(sp)+,d0/a0-2
		rts
		
;------------------------------------------------------------------------------
set_super:	movem.l	d0-a6,-(sp)
		move.l	#1,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		tst.w	d0
		bne.s	.insuper
		clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,sav_usp
.insuper:	movem.l	(sp)+,d0-a6
		rts

set_user:	movem.l	d0-a6,-(sp)
		move.l	#1,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		tst.w	d0
		beq.s	.inuser
		move.l	sav_usp(pc),-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
.inuser:	movem.l	(sp)+,d0-a6
		rts
sav_usp:	ds.l	1

;------------------------------------------------------------------------------
gcputyp:	reg d1/a0
get_cpu_type:	movem.l	gcputyp,-(sp)
		move.l	#'_CPU',d1
		bsr	find_cookie
		tst.l	d0
		bmi.s	.m68000		
		move.l	4(a0),d0
		bra.s	.exit
.m68000:	moveq	#0,d0
.exit:		movem.l	(sp)+,gcputyp
		rts

find_cookie:	move.l	$5a0.w,d0		;Get address of cookie jar in D0
		beq.s	.nojar			;If zero, there's no jar.
		move.l	d0,a0			;Move the address of the jar to A0
.search:	tst.l	(a0)			;Is this jar entry the last one ?
		beq.s	.nofind			;Yes, the cookie was not found
		cmp.l	(a0),d1			;Does this cookie match what we're looking for?
		beq.s	.foundit		;Yes, it does.
		addq.l	#8,a0			;Advance to the next jar entry
		bra.s	.search			;And start over
.nofind:	moveq	#-1,d0			;A negative (-1) means cookie not found
		rts
.nojar:		moveq	#-2,d0			;A negative (-2) means there's no jar
		rts
.foundit:	moveq	#0,d0			;A null in D0 means the cookie was found.
.exit:		rts

;------------------------------------------------------------------------------
***** FALCON 030 ROUTINEN *****
;f030_shadow:    ;>PART 'Buserror-Shadowregs'
; =====================================================
; Program called py the CPU in case of BUS ERROR
; it will try to correct it if it's due to an acces
; to shadowed YM register(s)
; =====================================================
bus_error:	move    #$2700,SR      	 	; IPL 7
		move.l  D0,.sav_d0
		move.l  A0,.sav_a0

		moveq   #0,D0
		move.w  $0A(SP),D0      	; SSW
		btst    #8,D0           	; data/retry
		beq     .reprise        	; retry
		btst    #6,D0           	; read/write
		beq.s   .ecriture       	; write

.lecture:	bclr    #8,D0           	; will do a retry
		move.w  D0,$0A(SP)      	; change stack frame
		cmpi.w  #$FF88,$11(SP)  	; bits 8-23 = psg?
		bne.s   .no_psg_r       	; no => bye bye
		move.b  $FFFF8800.w,D0  	; read psg
		move.b  D0,$2C(SP)
		move.b  D0,$2D(SP)
		move.b  D0,$2E(SP)
		move.b  D0,$2F(SP)
		bra     .exit
.no_psg_r:	clr.l   $2C(SP)
		bra     .exit

.ecriture:	bclr    #8,D0
		move.w  D0,$0A(SP)
		cmpi.w  #$FF88,$11(SP)
		bne.s   .no_psg_w
		andi.b  #$02,$13(SP)
		bne.s   .ff8802
.ff8800:	andi.w  #$30,D0         	; oper size
		lsr.w   #4,D0
		beq.s   .size_13
		cmpi.w  #2,D0
		beq.s   .size_12
.size_11:	move.b  $1B(SP),$FFFF8800.w
		bra     .exit
.size_12:	move.b  $1A(SP),$FFFF8800.w
		bra     .exit
.size_13:	;move.l #$FC000000,$FFFF9800.w
		move.b  $18(SP),$FFFF8800.w
		move.b  $1A(SP),$FFFF8802.w
		bra     .exit

.ff8802:	andi.w  #$30,D0
		lsr.w   #4,D0
		beq.s   .size_23
		cmpi.w  #2,D0
		beq.s   .size_22
.size_21:	move.b  $1B(SP),$FFFF8802.w
		bra.s   .exit
.size_22:	move.b  $1A(SP),$FFFF8802.w
		bra.s   .exit
.size_23:	move.b  $18(SP),$FFFF8802.w
		move.b  $1A(SP),$FFFF8800.w
		bra.s   .exit

.no_psg_w:	;move.l #$FC000000,$FFFF9800.w
		bra.s   .exit

.reprise:	btst    #14,D0
		beq.s   .etageB
		btst    #15,D0
		beq.s   .etageC
		bra.s   .exit

.etageB:	bclr    #12,D0
		move.w  D0,$0A(SP)
		cmpi.w  #$0A,6(SP)      	; frame type A?
		bne.s   .frameBB
.frameBA:	movea.l 2(SP),A0
		move.l  A0,$0E(SP)
		bra.s   .exit
.frameBB:	movea.l $24(SP),A0
		move.w  -2(A0),$0E(SP)
		bra.s   .exit

.etageC:	bclr    #13,D0
		move.w  D0,$0A(SP)
		cmpi.w  #$0A,6(SP)
		bne.s   .frameCB
.frameCA:	movea.l 2(SP),A0
		move.w  2(A0),$0C(SP)
		bra.s   .exit
.frameCB:	movea.l $24(SP),A0
		move.w  -2(A0),$0C(SP)

.exit:		movea.l .sav_a0,A0
		move.l  .sav_d0,D0
		rte

.sav_d0:	DC.L 0
.sav_a0:	DC.L 0


		section	data	

tC_Hz:		dc.w 200			;Timer C speed, 200 Hz.
playing:	dc.b 0
pause:		dc.b 0

		section	bss

speed_Hz:	ds.w 1
timediv:	ds.w 1
speed:		ds.b 1
use_vbl:	ds.b 1
musicmon:	ds.b 1

		even

hours:		ds.l 1
mins:		ds.b 1 	;+4
secs:		ds.b 1	;+5

shours:		ds.l 1	;+6
smins:		ds.b 1	;+10
ssecs:		ds.b 1	;+11

;saveu:		ds.l	1
;saves:		ds.l	1
old_vbl:	ds.l	1
old_tC:		ds.l	1
save_hardware:	ds.b	100
save_cols:	ds.l	8
musicmon_buff:	ds.l	1

pause_save	ds.b	4

	;This temporary stack is necessary because I found some tunes totally destroyed the stack!!
	;See the source..

		ds.l	200
temp_stack:	ds.l	200


		rsreset
timerA_freq:	rs.w	1
timerA_div:	rs.b 	1
timerA_data:	rs.b	1

timerB_freq:	rs.w	1
timerB_div:	rs.b	1
timerB_data:	rs.b	1

timerC_freq:	rs.w	1
timerC_div:	rs.b	1
timerC_data:	rs.b	1

timerD_freq:	rs.w	1
timerD_div:	rs.b	1
timerD_data:	rs.b	1
TimFreq_ssize:	= __RS

timer_setup:	ds.b	TimFreq_ssize

		section	text
