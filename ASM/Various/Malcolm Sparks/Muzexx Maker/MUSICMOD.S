; @ of data in a0
	movem.l	d0-d7/a0-a6,-(sp)
	add	#8,a0
	move.l	a0,Mmusic
	move.l	a0,a1
	move.l	a1,a2
	lea	Mchan1,a0
	move	#2,d4
.prepare
	move	#1,Mdur(a0)	
	move.l	a2,a3
	add	(a1)+,a3
	move.l	a3,Madd(a0)
	move.l	a3,Mold_add(a0)
	lea	Mstack(a0),a4
	move.l	a4,Mstackp(a0)
	add	#400,a0
	dbra	d4,.prepare
	
	lea	Mchan1,a0
	move	#8,Mtone(a0)
	move	#1,Mnoise(a0)
	move	#246,Mboth(a0)
	add	#400,a0
	move	#16,Mtone(a0)
	move	#2,Mnoise(a0)
	move	#237,Mboth(a0)
	add	#400,a0
	move	#32,Mtone(a0)
	move	#4,Mnoise(a0)
	move	#219,Mboth(a0)
	
	move	#248,Mmixer
	
	move.b	#7,$ff8800
	move.b	#248,$ff8802
	move.b	#8,$ff8800
	move.b	#0,$ff8802
	move.b	#9,$ff8800
	move.b	#0,$ff8802
	move.b	#10,$ff8800
	move.b	#0,$ff8802
	
	move.b	#7,Minuse
	move.b	#0,Mmute
	
	move	#2,d4
	lea	Mchan1,a0
.init_loop
	move.l	#0,Mvol(a0)
	move.l	#0,Mvol_wa(a0)
	move.l	#0,Mvol_fl(a0)
	move.l	#0,Mvol_ff(a0)
	move.l	#0,Mvol_fa(a0)
	move.l	#0,Mpit_lev(a0)
	move.l	#0,Mpit_wa(a0)
	move.l	#0,Mpit_fl(a0)
	move.l	#0,Mpit_ff(a0)
	move.l	#0,Mpit_fa(a0)
	add	#400,a0
	dbra	d4,.init_loop
	
	movem.l	(sp)+,d0-d7/a0-a6
	rts

	even
Mmusic	dc.l	0
Minuse	dc.b	0
	even
Mmute	dc.b	0
	even

	rsreset
Madd	rs.l	1
Mold_add	rs.l	1
Mvol	rs.l	1
Mpit	rs.l	1
Mdur	rs.w	1
Mrest	rs.w	1
Mgliss	rs.l	1
Mnoise	rs.w	1
Mtone	rs.w	1
Mboth	rs.w	1
Mvol_ptr	rs.l	1
Mvol_st	rs.l	1
Mvol_dur	rs.w	1
Mvol_wl	rs.l	1
Mvol_wc	rs.w	1
Mvol_wa	rs.l	1
Mvol_reps	rs.w	1
Mvol_fl	rs.l	1
Mvol_ff	rs.l	1
Mvol_fa	rs.l	1
Mpit_ptr	rs.l	1
Mpit_st	rs.l	1
Mpit_lev	rs.l	1
Mpit_dur	rs.w	1
Mpit_wl	rs.l	1
Mpit_wc	rs.w	1
Mpit_wa	rs.l	1
Mpit_reps	rs.w	1
Mpit_fl	rs.l	1
Mpit_ff	rs.l	1
Mpit_fa	rs.l	1
Mpit_base	rs.l	1
Mstackp	rs.l	1
Mstack	rs.l	20

Mchan1	ds.b	400
Mchan2	ds.b	400
Mchan3	ds.b	400
Mmixer	ds.w	1
Mpd_v	ds.l	1
Mpd_sl	ds.l	1

; --------------------------------------------------
; M) Yo lamers! Are you ready- this is the music interrupt.
Minterrupt
; Usual procedure on entry:
	movem.l	d0-d3/a0-a3,-(sp)
	
	lea	Mchan1,a0
	move	#8,d3
	move	#2,d2	Do the following three times
.mloop	
	btst	d2,Minuse
	beq	.exit
	subq	#1,Mdur(a0)
	beq	.new_note
.ret_note
	tst	Mrest(a0)
	bne	.exit
	subq	#1,Mvol_dur(a0)
	beq	.new_vol
.ret_vol	
	move.l	Mvol(a0),d0
	move.l	Mvol_wa(a0),d1
	beq	.skip	no wave fx	
	add.l	d1,d0
	
	move.l	Mvol_fa(a0),d1
	add.l	d1,Mvol_wa(a0)
	move.l	Mvol_ff(a0),d1
	add.l	d1,Mvol_wl(a0)
	
	subq	#1,Mvol_wc(a0)
	bne	.skip
	neg.l	Mvol_wa(a0)
	neg.l	Mvol_fa(a0)
	
	move	Mvol_wl(a0),Mvol_wc(a0)
.skip
	add.l	Mvol_fl(a0),d0
	move.l	d0,Mvol(a0)
	move.b	Mvol+1(a0),d0
	ext	d0
	
	tst.b	Mmute
	bne	.next_wave
	
	move.b	d3,$ff8800
	move.b	d0,$ff8802
.next_wave
	subq	#1,Mpit_dur(a0)
	beq	.new_pit
.ret_pit
	move.l	Mpit(a0),d0
	add.l	Mgliss(a0),d0
	add.l	Mpit_fl(a0),d0
	move.l	Mpit_wa(a0),d1
	beq	.skip2	no wave fx
	
	add.l	d1,d0
	
	move.l	Mpit_fa(a0),d1
	add.l	d1,Mpit_wa(a0)
	move.l	Mpit_ff(a0),d1
	add.l	d1,Mpit_wl(a0)
	
	subq	#1,Mpit_wc(a0)
	bne	.skip2
	neg.l	Mpit_wa(a0)
	neg.l	Mpit_fa(a0)
	
	move	Mpit_wl(a0),Mpit_wc(a0)
.skip2
	move.l	d0,Mpit(a0)
	add.l	Mpit_lev(a0),d0	add level

	swap	d0
	move	d3,d1
	add	d1,d1
	sub	#16,d1
	move.b	d1,$ff8800
	move.b	d0,$ff8802
	lsr	#8,d0
	addq	#1,d1
	move.b	d1,$ff8800
	move.b	d0,$ff8802

.exit	add	#400,a0
	add	#1,d3
	dbra	d2,.mloop
	
	move.l	Mpd_sl,d1
	add.l	d1,Mpd_v
	move.b	#11,$ff8800
	move.b	Mpd_v+1,$ff8802
	move.b	#12,$ff8800
	move.b	Mpd_v,$ff8802
	movem.l	(sp)+,d0-d3/a0-a3
	rts
	
; - - - - - - - - - - - - - - - - - - - - - - - - - - - 
.new_vol
	move.l	Mvol_ptr(a0),a1
	add.l	#10,Mvol_ptr(a0)	
	move	2(a1),Mvol_dur(a0)	get duration
	bmi	.end_vol
	move.b	5(a1),d0
	bne	.noise_gen
.ret_noise
	move.b	4(a1),d0
	ext	d0
	ext.l	d0
	swap	d0
	move.l	d0,Mvol(a0)	put on volume level
	
	cmp	#16,Mvol(a0)
	bpl	.variable
	
	move.l	#0,Mvol_wa(a0)
	move.b	6(a1),d0
	ext	d0
	move	d0,d1
	beq	.no_vw
	swap	d0
	clr	d0
	move.l	d0,Mvol_wl(a0)
	move.b	7(a1),d0
	ext	d0
	ext.l	d0
	asl.l	#8,d0
	divu	d1,d0
	ext.l	d0
	asl.l	#8,d0
	move.l	d0,Mvol_wa(a0)
	add	#1,d1
	asr	#1,d1
	move	d1,Mvol_wc(a0)
.no_vw	
	move.l	#0,Mvol_fl(a0)
	btst	#0,8(a1)	check level slide in
	beq	.no_vfl
	move.b	14(a1),d0
	sub.b	4(a1),d0
	ext	d0
	ext.l	d0
	asl.l	#8,d0
	divs	2(a1),d0
	ext.l	d0
	asl.l	#8,d0
	move.l	d0,Mvol_fl(a0)
.no_vfl
	move.l	#0,Mvol_ff(a0)
	btst	#2,8(a1)	check wavelength slide in
	beq	.no_vff
	move.b	16(a1),d0
	sub.b	6(a1),d0
	ext	d0
	ext.l	d0
	asl.l	#8,d0
	divs	2(a1),d0
	ext.l	d0
	asl.l	#8,d0
	move.l	d0,Mvol_ff(a0)
.no_vff
	move.l	#0,Mvol_fa(a0)
	btst	#1,8(a1)	check amplitude slide in
	beq	.no_vfa
	move.b	17(a1),d0
	sub.b	7(a1),d0
	ext	d0
	ext.l	d0
	asl.l	#8,d0
	divs	2(a1),d0
	ext.l	d0
	asl.l	#8,d0
	move.l	d0,Mvol_fa(a0)
.no_vfa
	move.b	8(a1),d0
	and	#$30,d0
	beq	.ret_vol
	cmp	#$10,d0
	beq	.tone
	cmp	#$20,d0
	beq	.noise
	cmp	#$30,d0
	beq	.both
	bra	.ret_vol
.tone
	move	Mmixer,d0
	and	Mboth(a0),d0
	or	Mtone(a0),d0
	move	d0,Mmixer
	move.b	#7,$ff8800
	move.b	d0,$ff8802	
	bra	.ret_vol		
.noise
	move	Mmixer,d0
	and	Mboth(a0),d0
	or	Mnoise(a0),d0
	move	d0,Mmixer
	move.b	#7,$ff8800
	move.b	d0,$ff8802	
	bra	.ret_vol		
.both
	move	Mmixer,d0
	and	Mboth(a0),d0
	move	d0,Mmixer
	move.b	#7,$ff8800
	move.b	d0,$ff8802	
	bra	.ret_vol		
.noise_gen
	move.b	#6,$ff8800
	move.b	d0,$ff8802	put on noise
	bra	.ret_noise
.end_vol
	sub	#10,Mvol_ptr(a0)
	move	#2000,Mvol_dur(a0)
	move.l	#0,Mvol(a0)
	move.l	#0,Mvol_wa(a0)
	move.l	#0,Mvol_fl(a0)
	move.l	#0,Mvol_ff(a0)
	move.l	#0,Mvol_fa(a0)
	bra	.ret_vol

.variable
	swap	d0
	and	#$f,d0
	move.b	#13,$ff8800	
	move.b	d0,$ff8802	envelope shape
	
	move	6(a1),Mpd_v
	clr	Mpd_v+2
		
	move.l	#0,Mpd_sl
	btst	#0,8(a1)	check level slide in
	beq	.no_vfa
	move	16(a1),d0
	sub	6(a1),d0
	ext.l	d0
	asl.l	#8,d0
	divs	2(a1),d0
	ext.l	d0
	asl.l	#8,d0
	move.l	d0,Mpd_sl
	move.l	#0,Mvol_wa(a0)
	move.l	#0,Mvol_wl(a0)
	move	#0,Mvol_wc(a0)
	move.l	#0,Mvol_fa(a0)
	move.l	#0,Mvol_ff(a0)
	move.l	#0,Mvol_fl(a0)
	bra	.no_vfa

; - - - - - - - - - - - - - - - - - - 
.new_pit
	move.l	Mpit_ptr(a0),a1
	add.l	#10,Mpit_ptr(a0)	DICKHEAD!
	move	2(a1),Mpit_dur(a0)	get duration
	bmi	.end_pit
	move	Mpit_base(a0),Mpit(a0)
	move.b	4(a1),d0
	ext	d0
	ext.l	d0
	swap	d0
	move.l	d0,Mpit_lev(a0)
	move.l	#0,Mpit_wa(a0)
	move.b	6(a1),d0
	ext	d0
	move	d0,d1
	beq	.no_pw
	swap	d0
	clr	d0
	move.l	d0,Mpit_wl(a0)
	move.b	7(a1),d0
	ext	d0
	ext.l	d0
	asl.l	#8,d0
	divu	d1,d0
	ext.l	d0
	asl.l	#8,d0
	move.l	d0,Mpit_wa(a0)
	add	#1,d1
	asr	#1,d1
	move	d1,Mpit_wc(a0)
.no_pw	
	move.l	#0,Mpit_fl(a0)
	btst	#0,8(a1)	check level slide in
	beq	.no_pfl
	move.b	14(a1),d0
	sub.b	4(a1),d0
	ext	d0
	ext.l	d0
	asl.l	#8,d0
	divs	2(a1),d0
	ext.l	d0
	asl.l	#8,d0
	move.l	d0,Mpit_fl(a0)
.no_pfl
	move.l	#0,Mpit_ff(a0)
	btst	#2,8(a1)	check wavelength slide in
	beq	.no_pff
	move.b	16(a1),d0
	sub.b	6(a1),d0
	ext	d0
	ext.l	d0
	asl.l	#8,d0
	divs	2(a1),d0
	ext.l	d0
	asl.l	#8,d0
	move.l	d0,Mpit_ff(a0)
.no_pff
	move.l	#0,Mpit_fa(a0)
	btst	#1,8(a1)	check amplitude slide in
	beq	.no_pfa
	move.b	17(a1),d0
	sub.b	7(a1),d0
	ext	d0
	ext.l	d0
	asl.l	#8,d0
	divs	2(a1),d0
	ext.l	d0
	asl.l	#8,d0
	move.l	d0,Mpit_fa(a0)
.no_pfa
	bra	.ret_pit
.end_pit
	sub	#10,Mpit_ptr(a0)
	move	#2000,Mpit_dur(a0)
	move.l	#0,Mpit_lev(a0)
	move.l	#0,Mpit_wa(a0)
	move.l	#0,Mpit_fl(a0)
	move.l	#0,Mpit_ff(a0)
	move.l	#0,Mpit_fa(a0)
	bra	.ret_pit
	
; - - - - - - - - - - - - - - - - - - 
.new_note
	move.l	Madd(a0),a1
	move.b	9(a1),d0
	bmi	.rts
	btst	#6,d0
	bne	.loops
	add.l	#10,Madd(a0)	no loops?, then increment address
	move	4(a1),Mdur(a0)
	bmi	.end_song
	move	6(a1),Mpit(a0)
	move	6(a1),Mpit_base(a0)
	move.l	Mmusic,a2
	add	6(a2),a2	env header
	move.b	8(a1),d0
	ext	d0
	subq	#1,d0
	asl	#2,d0	4 bytes per envelope
	move.l	a2,a3
	move	(a3,d0),d1
	add	d1,a3
	move.l	a3,Mvol_ptr(a0)
	move.l	a3,Mvol_st(a0)
	move.l	a2,a3
	move	2(a3,d0),d1
	add	d1,a3
	move.l	a3,Mpit_ptr(a0)
	move.l	a3,Mpit_st(a0)

	move	#1,Mvol_dur(a0)
	move	#1,Mpit_dur(a0)
	btst	#0,9(a1)	test for rest
	bne	.set_rest
	btst	#1,9(a1)	test for gliss
	bne	.set_gliss
	move.l	#0,Mgliss(a0)
	move	#0,Mrest(a0)
	bra	.ret_note
.set_rest
	move	#0,Mvol(a0)		no level &
	move.l	#0,Mvol_wa(a0)	no wave fx
	move	#-1,Mrest(a0)
	move.b	d3,$ff8800
	move.b	#0,$ff8802
	bra	.exit
.set_gliss
	move	#0,Mrest(a0)
	move	16(a1),d0
	sub	6(a1),d0
	ext.l	d0
	asl.l	#8,d0
	divs	4(a1),d0
	ext.l	d0
	asl.l	#8,d0
	move.l	d0,Mgliss(a0)
	bra	.ret_note
.loops
	move.b	9(a1),d0
	and	#$3f,d0	isolate bits
	beq	.new_loop
	sub.b	#1,d0	decrement counter
	bne	.loop_run
	and.b	#$c0,9(a1)
	add	#10,a1	next note
	move.l	a1,Madd(a0)
	bra	.new_note
.new_loop
	move.b	8(a1),d0
;	or.b	d0,9(a1)	get new loop	
.loop_run
	move.l	a1,a2
	add	6(a1),a2	offset end of loop
 	bset	#7,9(a2)	RTS flag set
	
	move.l	Mstackp(a0),a2	stack pointer
	move.l	a1,(a2)	push on (stack grows down)
	add.l	#4,Mstackp(a0)

	and.b	#$c0,9(a1)
	or.b	d0,9(a1)
	add	4(a1),a1	jump to start of loop
	move.l	a1,Madd(a0)
	bra	.new_note	get this 1st note
.rts
	bclr	#7,9(a1)	clear the bit
	sub.l	#4,Mstackp(a0)
	move.l	Mstackp(a0),a1
	move.l	(a1),Madd(a0)
	bra	.new_note	
.end_song
	move.l	Mold_add(a0),Madd(a0)
	bclr	d2,Minuse
	move	#-1,Mvol(a0)
	move.b	d3,$ff8800
	move.b	#0,$ff8802
	bra	.exit
