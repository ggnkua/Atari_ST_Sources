; *********************************************
; ** SUPER DUPER REPLAYER!!    (Optimized!!) **
; *********************************************

;* Matthew Simmonds' Music Routine coded by Krister Wombell.

sf_instr 	equ $16		;Song file offsets
sf_ident 	equ $3B8
sf_length 	equ $3BC
sf_restart 	equ $3BD
sf_parts	equ $3BE
sf_patterns 	equ $7C0
in_type		equ 0
in_length 	equ 22
in_spvol	equ 24
in_repeat 	equ 26
in_replen 	equ 28
in_size		equ 30

; Init patterns/music etc

ct_init		move.l ct_data_ptr,a0
		lea sf_patterns(a0),a1
		lea pattslook(pc),a2	; Make pattern look up table
		moveq #127,d0
.loop		move.l a1,(a2)+
		lea 256(a1),a1
		dbra d0,.loop
		lea sf_parts(a0),a1
		moveq #0,d0
		move.b sf_length(a0),d0
		add.w d0,d0
		add.w d0,d0
		subq.w #1,d0
		moveq #0,d1
.loop2		move.b (a1),d2
		cmp.b d1,d2
		bls.s .ok
		move.b d2,d1
.ok		addq.l #2,a1
		dbra d0,.loop2
		addq.w #1,d1
		mulu #256,d1		;256 bytes per pattern
		lea sf_patterns(a0),a1
		lea (a1,d1),a1
		lea sf_instr(a0),a2
		lea samplesinfo(pc),a3
		moveq #30,d0
.loop3		move.l a3,a4
		move.l a1,(a4)+		;Store address of sample
		moveq #0,d1		;Get length
		move.w in_length(a2),d1
		move.w d1,(a4)+		;Store length
		add.l d1,d1		;Length * 2
		move.l #nullsamp,(a4)+	;Default is no replen
		move.w in_replen(a2),(a4)+  ;Store replen
		move.w in_spvol(a2),(a4)+
		cmp.w #1,in_replen(a2)	;If repeat present
		beq.s .noreplen		;Then add to
		moveq #0,d2
		move.w in_repeat(a2),d2
		lea (a1,d2.l),a6	;Sample address
		move.l a6,-8(a4)	;And store
.noreplen	add.l d1,a1		;Add length*2 -> addr of next sample
.skip		lea in_size(a2),a2
		lea 16(a3),a3
		dbra d0,.loop3
		lea ct_vibtab+32,a1	;Point to next tab
		moveq #13,d0
		moveq #1,d2
.loop4		lea ct_vibtab(pc),a0
		move.l a1,a2
		moveq #31,d1
.loop5		moveq #0,d3
		move.b (a0)+,d3
		mulu d2,d3
		lsr.w #8,d3
		move.b d3,(a2)+
		dbra d1,.loop5
		addq.w #1,d2
		lea 32(a1),a1
		dbra d0,.loop4
		lea ct_vibtab(pc),a0
		moveq #31,d0
.loop6		clr.b (a0)+
		dbra d0,.loop6
		lea ct_vars(pc),a5
		clr.l position(a5)
		clr.l ct_dma(a5)
		clr.l ct_count(a5)
		move.w #6,ct_speed(a5)
		move_dmacon #$f
		rts

; Vbl Sequencer..

ct_music	lea ct_vars(pc),a5
		addq.w #1,ct_count(a5)
		move.w ct_speed(a5),d0
		cmp.w ct_count(a5),d0
		beq ct_new
		lea ch1s(pc),a1
		lea current(pc),a2
		bsr.s ct_checkcom
		lea ch2s(pc),a1
		lea current+vi_size(pc),a2
		bsr.s ct_checkcom
		lea ch3s(pc),a1
		lea current+vi_size*2(pc),a2
		bsr.s ct_checkcom
		lea ch4s(pc),a1
		lea current+vi_size*3(pc),a2
		bsr.s ct_checkcom
.no_play	rts
ct_checkcom	moveq #0,d0
		move.b vi_command+2(a2),d0
		add.w d0,d0
		add.w d0,d0
		jmp comtab1(pc,d0.w)
comtab1		bra.w ct_arpeggio
		bra.w ct_portup
		bra.w ct_portdown
		bra.w ct_myport
		bra.w ct_vib
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_volslide
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
ct_arpeggio	tst.b vi_command+3(a2)
		bne.s .yep
		rts
.yep		move.w ct_count(a5),d0
		move.b ct_arplist(pc,d0.w),d0
		beq ct_rts
		cmp.b #2,d0
		beq.s .arp2
.arp1		move.b vi_command+3(a2),d0
		lsr.w #4,d0
		bra.s .arpdo
.arp2		move.b vi_command+3(a2),d0
		and.w #$F,d0
.arpdo		lea periods(pc),a0
		add.w d0,d0
		move.w vi_note(a2),d1
		add.w d0,d1
		move.w (a0,d1),d0
		move.w d0,sam_period(a1)
		move.w d0,vi_period(a2)
		rts
ct_arplist	dc.b 0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1
ct_portup	moveq #0,d0
		move.b vi_command+3(a2),d0
		sub.w d0,vi_period(a2)
		move.w vi_period(a2),d0
		cmp.w #$71,d0
		bhs.s .ok
		move.w #$71,vi_period(a2)
		move.w #$71,d0
.ok		move.w d0,sam_period(a1)
		rts
ct_portdown	moveq #0,d0
		move.b vi_command+3(a2),d0
		add.w d0,vi_period(a2)
		move.w vi_period(a2),d0
		cmp.w #$358,d0
		bmi.s .ok
		and.w #$F000,vi_period(a2)
		or.w #$358,vi_period(a2)
.ok		move.w d0,sam_period(a1)
		rts
ct_myport	move.b vi_command+3(a2),d0
		beq.s .slide
		move.b d0,vi_tspeed(a2)
		clr.b vi_command+3(a2)
.slide		tst.w vi_tperiod(a2)
		beq.s .skip
		moveq #0,d0
		move.b vi_tspeed(a2),d0
		tst.b vi_tdir(a2)
		bne.s .minus
		add.w d0,vi_period(a2)
		move.w vi_tperiod(a2),d0
		cmp.w vi_period(a2),d0
		bgt.s .ok
		bra.s .done
.minus		sub.w d0,vi_period(a2)
		move.w vi_tperiod(a2),d0
		cmp.w vi_period(a2),d0
		blt.s .ok
.done		move.w vi_tperiod(a2),vi_period(a2)
		clr.w vi_tperiod(a2)
.ok		move.w vi_period(a2),sam_period(a1)
.skip		rts
ct_vib		move.b vi_command+3(a2),d0
		beq.s .vib2
		move.b d0,vi_vspeed(a2)
.vib2		move.b vi_vframe(a2),d0
		lsr.w #2,d0
		and.w #$1F,d0
		move.b vi_vspeed(a2),d1
		and.w #$F,d1
		lsl.w #5,d1		;*32
		lea ct_vibtab(pc),a0
		add.w d1,a0		;Point to right tab
		moveq #0,d2
		move.b (a0,d0),d2
		add.w d2,d2
		move.w vi_period(a2),d0
		tst.b vi_vframe(a2)
		bmi.s .vibsub
		add.w d2,d0
		bra.s .vib3
.vibsub		sub.w d2,d0
.vib3		move.w d0,sam_period(a1)
		move.b vi_vspeed(a2),d0
		lsr.w #2,d0
		and.w #$3C,d0
		add.b d0,vi_vframe(a2)
		rts
ct_volslide	moveq #0,d0
		move.b vi_command+3(a2),d0
		cmp.b #16,d0
		bcs.s .down
		lsr.b #4,d0
		add.w vi_volume(a2),d0
		cmp.w #64,d0
		bmi.s .vol2
		moveq #64,d0
		bra.s .vol2
.down		and.b #$F,d0
		neg.w d0
		add.w vi_volume(a2),d0
		bpl.s .vol2
		moveq #0,d0
.vol2		move.w d0,vi_volume(a2)
		move.w d0,sam_vol(a1)
ct_rts		rts
ct_new		clr.w ct_count(a5)
		move.l ct_data_ptr,a3
		lea sf_parts(a3),a3
		move.w position(a5),d0
		lsl.w #3,d0
		lea (a3,d0),a3
		clr.w ct_dma(a5)
		lea ch1s(pc),a1
		lea current(pc),a2
		moveq #1,d7
		bsr ct_playnote
		lea ch2s(pc),a1
		lea current+vi_size(pc),a2
		moveq #2,d7
		bsr ct_playnote
		lea ch3s(pc),a1
		lea current+vi_size*2(pc),a2
		moveq #4,d7
		bsr ct_playnote
		lea ch4s(pc),a1
		lea current+vi_size*3(pc),a2
		moveq #8,d7
		bsr ct_playnote
		tst.w ct_break(a5)
		bne.s .newpat
		addq.w #4,patpos(a5)
		cmp.w #64*4,patpos(a5)
		bne.s .notend
.newpat		clr.w ct_break(a5)
		clr.w patpos(a5)
		addq.w #1,position(a5)
		move.l ct_data_ptr,a6
		move.b sf_length(a6),d0
		cmp.b position+1(a5),d0
		bne.s .notend
		move.l ct_data_ptr,a6
		move.b sf_restart(a6),position+1(a5)
.notend		or.w #$8200,ct_dma(a5)
		lea.l ch1s(PC),a1
		lea current(pc),a2
		rept 4
		moveq #0,d3
		move.l vi_repeat(a2),sam_lpstart(a1)
		move.w vi_replen(a2),d3
		add.l d3,d3
		add.l d3,sam_lpstart(a1)
		move.w d3,sam_lplength(a1)
		lea sam_vcsize(a1),a1
		lea vi_size(a2),a2
		endr
.setdma		move.w ct_vars+ct_dma(pc),d7
		move_dmacon d7
		rts

ct_playnote	moveq #0,d0
		move.b (a3),d0		;Get pat num
		add.w d0,d0
		add.w d0,d0
		lea pattslook(pc),a0
		move.l (a0,d0),a0
		add.w patpos(a5),a0
		move.l (a0),vi_command(a2)
		tst.b vi_command+1(a2)
		beq.s .setreg
		moveq #0,d0
		move.b vi_command+1(a2),d0	;Get samp num.
		lsl.w #4,d0		;*16
		lea samplesinfo-16,a0	;Add to samples info
		lea (a0,d0),a0
		move.l (a0)+,vi_addr(a2)
		move.w (a0)+,vi_length(a2)
		move.l (a0)+,vi_repeat(a2)
		move.w (a0)+,vi_replen(a2)
		move.w (a0),vi_volume(a2)
.setreg		move.w vi_volume(a2),sam_vol(a1)
		moveq #0,d0
		move.b vi_command(a2),d0 ;Get note
		cmp.b #168,d0		;Check for edges of table
		beq.s .com2
		lea periods(pc),a0
		move.b 1(a3),d1
		beq.s .notrans
		ext.w d1
		add.w d1,d1
		add.w d1,d0
.notrans	move.w d0,vi_note(a2)
		move.w (a0,d0),d0
		cmp.b #3,vi_command+2(a2)
		bne.s .setper
		move.w d0,vi_tperiod(a2)
		clr.b vi_tdir(a2)
		cmp.w vi_period(a2),d0
		beq.s .port1
		bge.s .com2
		addq.b #1,vi_tdir(a2)
		bra.s .com2
.port1		clr.w vi_tperiod(a2)
		bra.s .com2
.setper		;move_dmacon d7
		move.w d0,sam_period(a1)
		move.w d0,vi_period(a2)
		clr.b vi_vframe(a2)
		or.w d7,ct_dma(a5)
		move.l vi_addr(a2),sam_start(a1)
		moveq #0,d3
		move.w vi_length(a2),d3
		add.l d3,d3
		add.l d3,sam_start(a1)
		move.w d3,sam_length(a1)
.com2		bsr ct_checkcom2
.voiceoff	addq.l #2,a3
		rts

ct_checkcom2	moveq #0,d0
		move.b vi_command+2(a2),d0	;Command
		add.w d0,d0
		add.w d0,d0
		jmp comtab2(pc,d0)
comtab2		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_rts
		bra.w ct_songjmp
		bra.w ct_setvol
		bra.w ct_pattbreak
		bra.w ct_filter
		bra.w ct_setspeed
ct_filter	;move.b vi_command+3(a2),d0
		;beq.s .off
		;bset #1,$BFE001
		rts

ct_songjmp	moveq #0,d0
		move.b vi_command+3(a2),d0
		subq.b #1,d0		;Posup rountine correction
		move.w d0,position(a5)
ct_pattbreak	move.w #1,ct_break(a5)
		clr.l vi_command(a2)
		rts
ct_setvol	moveq #0,d0
		move.b vi_command+3(a2),d0
		move.w d0,sam_vol(a1)
		move.w d0,vi_volume(a2)
		rts
ct_setspeed	move.b vi_command+3(a2),d0
		beq.s .nope
		move.w d0,ct_speed(a5)
.nope		rts

		*******************************
		*** Equates and data below! ***
		*******************************

		rsreset
vi_period	rs.w 1		;Period value
vi_volume	rs.w 1		;Default volume
vi_instr	rs.w 1		;Sample number
vi_addr		rs.l 1		;Start of sample
vi_length	rs.w 1		;Length of sample
vi_repeat	rs.l 1		;Repeat address
vi_replen 	rs.w 1		;Repeat length
vi_type		rs.w 1		;Synth=0  Sample=1
vi_command 	rs.l 1		;Period.b Sample.b command.n comval.b
vi_note		rs.w 1		;Period table offset
vi_tdir		rs.b 1		;Which way to slide period
vi_tspeed	rs.b 1		;Speed to slide period
vi_tperiod 	rs.w 1		;Period to slide to
vi_vspeed	rs.b 1		;Speed to warble
vi_vframe	rs.b 1		;Speed count
vi_free		rs.w 1		;Is voice free to use?
vi_size		rs.b 0
		rsreset
position	rs.w 1		;Song position
patpos		rs.w 1		;Which note
ct_count	rs.w 1		;Countdown
ct_speed	rs.w 1		;Speed
ct_dma		rs.w 1		;DMA value
ct_break	rs.w 1		;Pattern break
oldlev6		rs.l 1
chipsize	rs.w 0

periods		dc.w $1AC0,$1940,$17D0,$1680,$1530,$1400,$12E0,$11D0,$10D0,$0FE0,$0F00,$0E28
		dc.w $0D60,$0CA0,$0BE8,$0B40,$0A98,$0A00,$0970,$08E8,$0868,$07F0,$0780,$0714
		dc.w $06B0,$0650,$05F4,$05A0,$054C,$0500,$04B8,$0474,$0434,$03F8,$03C0,$038A
		dc.w $0358,$0328,$02FA,$02D0,$02A6,$0280,$025C,$023A,$021A,$01FC,$01E0,$01C5
		dc.w $01AC,$0194,$017D,$0168,$0153,$0140,$012E,$011D,$010D,$00FE,$00F0,$00E2
		dc.w $00D6,$00CA,$00BE,$00B4,$00AA,$00A0,$0097,$008F,$0087,$007F,$0078,$0071
		dc.w 0,0,0

pattslook	ds.l 128	;Pointers to patterns
samplesinfo 	ds.b 31*16	;Samplesinfo  addr,len,rep,replen,vol
ct_vibtab	dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
		dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18
		ds.b 14*32
nullsamp	dc.l 0
current		ds.b vi_size*4
ct_vars		ds.b chipsize
ct_data_ptr	dc.l 0
