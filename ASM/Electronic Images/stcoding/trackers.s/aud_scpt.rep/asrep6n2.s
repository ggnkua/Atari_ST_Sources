* Audio Sculpture Replay Routines - Soundchip only.
* This Version uses no registers at all!! Allows upto 19 Khz Replay!!!

player	equ $e0000
__OUTPUT	equ 0
ASreplayIrqFrq	equ 60		; timer speed(base freq)
tune	equ 96		; fine tune thingy

	opt o-

main	clr.l -(sp)		Enter Supervisor Mode
	move #$20,-(sp)
	trap #1
	addq.l #6,sp
	lea stack,sp

	bsr ASreplayInstall	Start playing music
	
.wait	btst.b #0,$fffffc00.w
	beq.s .wait
	cmp.b #$b9,$fffffc02.w	Wait for space without operating system
	bne .wait
	
	bsr ASreplayDeInstall	Stop playing music

_save_usp	move #$22,-(a7)		Release all keys
	trap #14
	addq.l #2,a7
	clr -(a7)		Terminate
	trap #1
	
Amplitudes	ds.l 8
__sq_ptr	equ $3b8 $1d8
__ptrn_ptr	equ $43c $258
__DEF_SPEED	equ 6

__BUF_LEN	equ 2048	2048 for internal sound at the moment...

pref_volume	dc.b 1
	even

* Interrupt generation

GenIrqFrq	st GenIrq_flg
	move.l #player,ASreplayIrqPtr
	jsr gen_frq
	jsr i_voltab
	sf GenIrq_flg
initsoundchip:	LEA $ffff8800.w,a0
	MOVE.B #7,(a0)		; turn on sound
	MOVE.B #$c0,d0
	AND.B (a0),d0
	OR.B #$38,d0
	MOVE.B d0,2(a0)
	MOVE.W #$0500,d0	;
.initslp	MOVEP.W d0,(a0)
	SUB.W #$0100,d0
	BPL.S .initslp
	rts

* Pointers to cmd strings used while generating the different IRQs
	
ASreplayIrqPtr	dc.l 0
ASreplayOutput	dc.w __OUTPUT

* The sequencer initialisation

ASreplayInit	move.l a_data_ptr(pc),a0
	add #__sq_ptr,a0
	move.b -2(a0),a_maxpart+1
	
	moveq #127,d0
	moveq #0,d1
.i1	move.l d1,d2
	subq #1,d0
	bmi.s .mend
.i2	move.b (a0)+,d1
	cmp.b d2,d1
	bgt.s .i1
	dbf d0,.i2
	
.mend	move.b d2,a_maxptrn
	addq.b #1,d2
	move.l a_data_ptr(pc),a0
	lea a_sample2(pc),a1
	moveq #10,d1
	lsl.l d1,d2
	add.l #__ptrn_ptr,d2
	add.l a0,d2
	move.l d2,d5
	moveq #30,d7
	moveq #0,d0
.i4	move.l d2,a2
	move.l a2,(a1)+
	moveq #0,d1
	move 42(a0),d1
	asl.l d1
	add.l d1,d2
	add #30,a0
	dbra d7,.i4 
	move.l d2,(a1)

.i5	lea a_sample2-4(pc),a6
	moveq #30,d7
	move.l a1,a0
	lea frequency_lst,a3
	move.l a3,a4
	move.l a0,a5
.i6	move.l (a0),a1
	move.l -(a0),a2
	moveq #31,d1
	moveq #0,d6
.i7	rept 8
	move.l d6,-(a3)
	endr
	dbra d1,.i7
	bra .incopy
	
.copy	move -(a1),-(a3)
.incopy	cmp.l a1,a2
	blt .copy
	clr.l (a3)

	move.l a3,-(a6)
 	subq #1,d7
	bpl .i6

	move.l #$80808080,d0
.i8b	eor.l d0,(a3)+
	cmp.l a4,a3
	blt .i8b
	move.l #$08000000,$ffff8888.w
	move.l #$09000000,$ffff8888.w
	move.l #$0a000000,$ffff8888.w
	clr.l a_partnrplay
	clr a_partnote
	move.l a_data_ptr(pc),a0
	move.b __sq_ptr-2(a0),a_maxpart+1
	move.b __sq_ptr-1(a0),e_crpres+1

a_rept_i	move.l a_data_ptr(pc),a0
	add #42,a0
	lea a_sample1(pc),a1
	lea a_repeat1(pc),a6
	moveq #30,d0
.l0	cmp #1,6(a0)
	beq.s .set80
	move.l (a1),a2		Start
	move.l a2,a5		
	add (a0),a2
	add (a0),a2
	move.l a2,d5		Real end
	add.l #1024,d5
	lea (a2),a3
	add 4(a0),a5		
	add 4(a0),a5
	move.l a5,d4		Repeat Start
	move.l a5,(a6)+
	bra .c2

.l2	move (a5)+,(a2)+
	cmp.l a3,a5
	blt .v0
.c2	move.l d4,a5
.v0	cmp.l d5,a2
	blt .l2	
	bra .c0

.set80	move.l (a1),a2
	add (a0),a2
	add (a0),a2
	move.l a2,(a6)+
	moveq #31,d1
	move.l #$80808080,d2
.l1	rept 8
	move.l d2,(a2)+
	endr
	dbra d1,.l1
.c0	lea 30(a0),a0
	lea 4(a1),a1
	dbra d0,.l0
	rts

* The sequencer routines...

ASreplay	addq #1,a_counter
	addq #1,a_arp_cnt
	addq #1,a_time
	move a_speed(pc),d0
	cmp a_counter(pc),d0
	bls a_seq
	
	tst a_delay_time
	bne a_plutt
	
	move a_speed(pc),d0
	lsr #1,d0
	cmp a_counter(pc),d0
	bne.s a_plutt
	
	tst.b a_break_flg
	beq.s .no_break
	
.xuxx	sf a_break_flg
	clr a_partnote
	bra.s .higher
	
.no_break	move a_nxt_partnote(pc),d0
	bmi.s .norm
	
	move d0,a_partnote
	move #-1,a_nxt_partnote
	bra.s .stop
	
.norm	add #16,a_partnote	Spara gammal adr o ny adr...
	and #$3f0,a_partnote
	bne.s .stop
	
.higher	addq #1,a_partnrplay+2
	move a_nxtpart(pc),d0
	bmi .no_posjmp
	
	move d0,a_partnrplay+2
	move #-1,a_nxtpart
	
.no_posjmp	move.l a_partnrplay(pc),d0
	cmp a_maxpart(pc),d0
	blt.s .stop
	
	move e_crpres(pc),a_partnrplay+2
	
.stop	move.l a_data_ptr(pc),a0
	lea __sq_ptr(a0),a1

a_plutt	lea audio0(pc),a5
	lea a_aud1temp(pc),a6
	moveq #3,d5
.l0	move #$fff,d0
	and r_command(a6),d0
	beq.s .c0
	moveq #15,d0
	and.b r_command(a6),d0
	add d0,d0
	lea a_chkcom_lst(pc),a0
	add (a0,d0),a0
	jsr (a0)
.c0	lea audio1-audio0(a5),a5
	lea a_aud2temp-a_aud1temp(a6),a6
	dbra d5,.l0
	rts

a_chkcom_lst	
za	set a_chkcom_lst
	dc a_arp-za,a_portup-za,a_portdown-za,a_myport-za,a_vib-za
	dc a_toneovol-za
	dc a_vibovol-za
	dc a_tremolo-za
	rept 2
	dc a_null-za
	endr
	dc a_volslide-za
	rept 3
	dc a_null-za
	endr
	dc a_b_parser-za,a_null-za
	dc a_set_speed-za
	
a_b_parser	move #$f0,d0
	moveq #15,d1
	move.b r_cmd_param(a6),d2
	and d2,d0
	lsr #3,d0
	and d2,d1
	lea .lst(pc),a1
	add (a1,d0),a1
	jmp (a1)
.lst	
za	set .lst
	rept 9
	dc a_null-za
	endr
	dc a_retrigg-za
	rept 2
	dc a_null-za
	endr
	dc a_notecut-za,a_notedelay-za,a_null-za,a_null-za

a_set_speed	tst.b r_cmd_param(a6)
	beq .nope
	move.b r_cmd_param(a6),a_arp_speed
.nope	rts

a_arp	move (a6),d0
	and #$3ff,d0
	beq.s .old
	clr a_arp_cnt
.old	moveq #0,d0
	move a_arp_cnt(pc),d0
	moveq #0,d1
	move.b a_arp_speed(pc),d1
	divu d1,d0
	and.l #$ffff,d0
	divu #3,d0
	swap d0
	tst.b d0
	beq.s .l2
	cmp.b #2,d0
	beq.s .l1
	moveq #0,d0
	move.b r_cmd_param(a6),d0
	lsr.b #4,d0
	bra.s .l3
.l1	moveq #15,d0
	and.b r_cmd_param(a6),d0
.l3	move r_period(a6),d1
	move.l period_to_note_ptr,a1
	moveq #0,d2
	move.b (a1,d1),d2
	add d0,d2
	add d2,d2
	move a_arpeggio(pc,d2),d2
	beq.s .l2
	move d2,AudPeriod(a5)
	move d2,AudPeriodSet(a5)
	rts
.l2	move r_period(a6),d2
	move d2,AudPeriod(a5)
	move d2,AudPeriodSet(a5)
	rts

	dc $358,$358
a_arpeggio	dc $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c
	dc $023a,$021a,$01fc,$01e0,$01c5,$01ac,$0194,$017d
	dc $0168,$0153,$0140,$012e,$011d,$010d,$00fe,$00f0
	dc $00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097
	dc $008f,$0087,$007f,$0078,$0071,0
	dcb 16,0

a_setmyport	move (a6),d1		Fetch dest period
	and #$3ff,d1
	beq.s a_myport		No per=port
	move d1,r_destination(a6)	24(a6)=dest per
	move r_period(a6),d0	Curr per
	clr.b r_porta_dir(a6)		Clr dir
	cmp d0,d1		
	beq.s .clrport		Same per
	bge.s .rt
	move.b #1,r_porta_dir(a6)	Set dir
	rts
.clrport	clr r_destination(a6)	Clr port
.rt	rts

a_myport	move.b r_cmd_param(a6),d0		CHK for speed!
	beq.s a_myslide
	move.b d0,r_my_speed(a6)	23(a6)=speed
	clr.b r_cmd_param(a6)	No over-selection...
a_myslide	tst r_destination(a6)		destPeriod present?
	beq.s .rts
	moveq #0,d0
	move.b r_my_speed(a6),d0	Fetch speed!
	tst.b r_porta_dir(a6)	Select direction!
	bne.s .mysub
	add d0,r_period(a6)	Increment period!
	move r_destination(a6),d0	Fetch dest period
	cmp r_period(a6),d0	Target reached?
	bgt.s .myok
	move r_destination(a6),r_period(a6)	Set target...
	clr r_destination(a6)		No more portamento...
.myok	move r_period(a6),AudPeriod(a5)	Set period
	move r_period(a6),AudPeriodSet(a5)
	rts
	
.mysub	sub d0,r_period(a6)	Decrement period
	move r_destination(a6),d0		Fetch dest period
	cmp r_period(a6),d0	Target reached?
	blt.s .myok
	move r_destination(a6),r_period(a6)	Set target
	clr r_destination(a6)		No more port
	move r_period(a6),AudPeriod(a5)	Set period
	move r_period(a6),AudPeriodSet(a5)
.rts	rts


a_toneovol	bsr a_myslide
	bra a_voldown

a_vibovol	bsr a_viyy
	bra a_voldown
	
a_vib	move.b r_cmd_param(a6),d0
	beq.s a_viyy
	move.b d0,r_vib_dta(a6)
a_viyy	moveq #0,d1
	move.b r_vibrato(a6),d0
	beq .sine
	cmp.b #1,d0
	bne.s .pulse
	move.b r_vib_cnt(a6),d1
	bpl.s .set
	not.b d1
	bra.s .set
.pulse	not.b d1
	bra.s .set
.sine	moveq #$1f*4,d0
	and.b r_vib_cnt(a6),d0
	lsr #2,d0
	lea a_sin(pc),a1
	move.b (a1,d0),d1
.set	moveq #15,d0
	and.b r_vib_dta(a6),d0
	mulu d0,d1
	lsr #6,d1
	move r_period(a6),d0
	tst.b r_vib_cnt(a6)
	bmi.s .vibmin
	add d1,d0
	bra.s .vib2
.vibmin	sub d1,d0
.vib2	move d0,AudPeriod(a5)
	move d0,AudPeriodSet(a5)
	moveq #-16,d0
	and.b r_vib_dta(a6),d0
	lsr.b #2,d0
	add.b d0,r_vib_cnt(a6)
.vi	rts

a_tremolo	move.b r_cmd_param(a6),d0
	beq.s .old
	move.b d0,r_treold(a6)
.old	moveq #0,d1
	move.b r_tremolo(a6),d0
	beq.s .sine
	cmp.b #1,d0
	bne.s .pulse
	move.b r_trepos(a6),d1
	bpl.s .set
	not.b d1
	bra.s .set
.pulse	not.b d1
	bra.s .set
.sine	moveq #$1f*4,d0
	and.b r_trepos(a6),d0
	lsr #2,d0
	lea a_sin(pc),a1
	move.b (a1,d0),d1
.set	moveq #15,d0
	and.b r_treold(a6),d0
	mulu d0,d1
	lsr #6,d1
	move.b r_volume(a6),d0
	tst.b r_trepos(a6)
	bmi.s .vibmin
	add d1,d0
	bra.s .vib2
.vibmin	sub d1,d0
.vib2	bpl.s .ko0
	moveq #0,d0
	bra.s .go
.ko0	cmp #64,d0
	ble.s .go
	moveq #64,d0
.go	move.b d0,r_volume(a6)
	move.b d0,AudVolume(a5)
	moveq #-16,d0
	and.b r_treold(a6),d0
	lsr.b #2,d0
	add.b d0,r_trepos(a6)
.vi	rts
	
a_volslide	move.b r_cmd_param(a6),d0
	bne.s .nu
	move.b r_oldvolsld(a6),d0
.nu	move.b d0,r_oldvolsld(a6)
	and.b #$f0,d0
	beq.s a_voldown
	lsr.b #4,d0
	add.b d0,r_volume(a6)
	cmp.b #64,r_volume(a6)
	bmi.s a_vol3
	move.b #64,r_volume(a6)
	move.b r_volume(a6),AudVolume(a5)
a_null	rts

a_voldown	moveq #15,d0
	and.b r_cmd_param(a6),d0
	sub.b d0,r_volume(a6)
	bpl.s a_vol3
	clr.b r_volume(a6)
a_vol3	move.b r_volume(a6),AudVolume(a5)
	rts


a_fineportaup	move d1,d0
	bra.s a_portup_in
a_portup	moveq #0,d0
	move.b r_cmd_param(a6),d0
a_portup_in	beq.s .c0
	move.b d0,r_porta_speed(a6)
.c0	move.b r_porta_speed(a6),d0
	sub d0,r_period(a6)
	move r_period(a6),d0
	cmp #$71,d0
	bge.s .por2
	moveq #$71,d0
	and #$f000,r_command(a6)
.por2	move d0,AudPeriod(a5)
	move d0,r_period(a6)
	move d0,AudPeriodSet(a5)
	rts
	
a_fineportadown	move d1,d0
	bra.s a_portdown_in
a_portdown	moveq #0,d0
	move.b r_cmd_param(a6),d0
a_portdown_in	beq.s .c0
	move.b d0,r_porta_speed(a6)
.c0	move.b r_porta_speed(a6),d0
	add d0,r_period(a6)
	move r_period(a6),d0
	cmp #$358,d0
	ble.s .por3
	move #$358,d0
	clr.b r_porta_speed(a6)
	and #$f000,r_command(a6)
.por3	move d0,AudPeriod(a5)
	move d0,r_period(a6)
	move d0,AudPeriodSet(a5)
	rts
	
* The actual sequencer routine

a_seq	clr a_time
	tst a_delay_time
	beq.s .goforit
	
	subq #1,a_delay_time
	bra.s .x
	
.goforit	move.l a_data_ptr(pc),a0
	lea 12(a0),a3
	lea __sq_ptr(a0),a1
	move a_partnrplay+2(pc),d0
	moveq #0,d1
	move.b (a1,d0),d1
	
	lsl.l #8,d1
	lsl.l #2,d1
	lea __ptrn_ptr(a0),a0
	add a_partnote(pc),a0
	add.l d1,a0

	lea audio0(pc),a5
	lea a_aud1temp(pc),a6
	moveq #3,d5
.l0	bsr.s a_playit
.gah	lea audio1-audio0(a5),a5
	lea a_aud2temp-a_aud1temp(a6),a6
	lea 4(a0),a0
	dbra d5,.l0
	
.x	clr a_counter
	rts
   
* The real sequencer routine...
   
a_playit	move.l (a0),(a6)
	move #$ff0,d2
	and r_command(a6),d2
	cmp #$ed0,d2
	beq a_null
	
a_playshit	and #$f00,d2
	cmp #$300,d2
	beq .no_new_sample
	
	move.b r_command(a6),d2
	and #$f0,d2		Lownibble
	lsr #4,d2
	moveq #16,d0
	and.b (a6),d0
	or d0,d2
	beq.s .nosamplechange
	
	move.b d2,AudLastInstr(a5)
	move d2,AudInstr(a5)
	add d2,d2
	move d2,d0
	add d2,d2		d2=INSTR*4
	move d0,d1
	lsl #4,d0
	sub d1,d0
	lea a_repeats(pc),a1
	move.l (a1,d2),r_restart(a6)	RESTART
	lea a_samples(pc),a1
	move.l (a1,d2),d1
	move.l d1,r_start_ptr(a6)	START
	moveq #0,d2
	move (a3,d0),d2		LEN
	add.l d2,d2
	add.l d2,d1		START+LEN=
	move.l d1,r_end_ptr(a6)	END
	move.b 3(a3,d0),d0
	move.b d0,r_volume(a6)	Volume
	move.b d0,AudVolume(a5)
	
.nosamplechange	move (a6),d0		Period
	and #$3ff,d0
	beq.s .no_new_sample
	
	move d0,r_period(a6)
	move d0,AudPeriod(a5)	FRQ - Float
	move d0,AudPeriodSet(a5)	FRQ - Fix
	move d0,AudPeriodMidi(a5)	FRQ - Midi
	move.l r_start_ptr(a6),(a5)	START
	move.l r_end_ptr(a6),AudEnd(a5)	END
	move.l r_restart(a6),AudRestart(a5)
	
.no_new_sample	move r_command(a6),d0
	and #$fff,d0
	beq a_null
	
	lsr #7,d0
	and #$1e,d0
	lea a_com_lst(pc),a1
	add (a1,d0),a1
	jmp (a1)

a_com_lst	
za	set a_com_lst
	dc a_arp-za,a_portup-za,a_portdown-za,a_setmyport-za,a_vib-za
	dc a_toneovol-za
	dc a_vibovol-za
	dc a_tremolo-za
	dc a_phase2-za
	dc a_phase-za
	dc a_volslide-za,a_posjmp-za,a_setvol-za
	dc a_break-za,a_e_parser-za,a_setspeed-za
	
a_e_parser	move #$f0,d0
	moveq #15,d1
	move.b r_cmd_param(a6),d2
	and d2,d0
	lsr #3,d0
	and d2,d1
	lea .lst(pc),a1
	add (a1,d0),a1
	jmp (a1)
.lst	
za	set .lst
	dc a_filter-za,a_fineportaup-za,a_fineportadown-za
	dc a_setglissctrl-za,a_setvibratoctrl-za,a_setfinetune-za
	dc a_dbf-za,a_settremoloctrl-za,a_stoppus-za
	dc a_retrigg-za,a_volfineup-za,a_volfinedown-za
	dc a_notecut-za,a_notedelay-za,a_ptrndelay-za,a_funkit-za
	
a_setglissctrl	and #1,d1
	move.b d1,r_glissando(a6)
	rts

a_setvibratoctrl
	and #3,d1
	move.b d1,r_vibrato(a6)
	rts

a_setfinetune	move.b d1,r_finetune(a6)
	rts

a_settremoloctrl
	and #3,d1
	move.b d1,r_tremolo(a6)
	rts

a_retrigg	beq.s .fex		!
	moveq #0,d0
	move a_time(pc),d0
	beq.s .fex
	divu d1,d0
	swap d0
	tst d0
	bne.s .x
.fex	move.l r_start_ptr(a6),(a5)	START
	move.l r_end_ptr(a6),AudEnd(a5)	END
	move.l r_restart(a6),AudRestart(a5)
.x	rts

a_volfineup	beq.s .nu
	move.b d1,r_oldvolsld(a6)	!
.nu	move.b r_oldvolsld(a6),d1
	add.b d1,r_volume(a6)
	cmp.b #$40,r_volume(a6)
	bls.s .x
	move.b #$40,r_volume(a6)
.x	move.b r_volume(a6),AudVolume(a5)
	rts

a_volfinedown	beq.s .nu		!
	move.b d1,r_oldvolsld(a6)
.nu	move.b r_oldvolsld(a6),d1
	sub.b d1,r_volume(a6)
	bpl.s .x
	clr.b r_volume(a6)
.x	move.b r_volume(a6),AudVolume(a5)
	rts

a_notecut	beq.s .nu
	move.b d1,r_oldnotecut(a6)
.nu	move.b r_oldnotecut(a6),d1
	cmp a_time(pc),d1	!
	bne.s .x
	clr.b r_volume(a6)
	move.b r_volume(a6),AudVolume(a5)
.x	rts

a_notedelay	beq.s .nu
	move.b d1,r_oldnotedel(a6)
.nu	move.b r_oldnotedel(a6),d1
	cmp a_time(pc),d1
	bne.s .x
	and #$f000,r_command(a6)
	move.l a_data_ptr,a3
	lea 12(a3),a3
	bsr a_playshit
	clr.l (a6)
.x	rts

a_ptrndelay	beq.s .nu
	move.b d1,r_oldptrndel(a6)
.nu	move.b r_oldptrndel(a6),d1
	tst a_delay_time
	bne.s .x
	move d1,a_delay_time
.x	rts

a_funkit	rts

a_dbf	bne.s .running
	move a_partnote(pc),r_ptrnpos(a6)
	rts
.running	tst.b r_dbfcnt(a6)
	bne.s .noset
	move.b d1,r_dbfcnt(a6)
	bra.s .go
.noset	subq.b #1,r_dbfcnt(a6)
	beq.s .x
.go	move r_ptrnpos(a6),a_nxt_partnote
.x	rts
	
a_stoppus	cmp.b #$e,d1
	beq.s .stoppus
	move.b #$dd,a_fake_flg
	st a_break_flg
	rts
.stoppus	clr a_partnote
	move #31,a_counter
	
	addq #1,a_partnrplay+2
	move.l a_data_ptr,a0
	lea __sq_ptr(a0),a1

	rts

a_phase	moveq #0,d1
	move.b r_cmd_param(a6),d1
	beq.s .nostore
	
	move.b d1,r_phase(a6)
	
.nostore	move.b r_phase(a6),d1
	lsl.l #8,d1
	move.l r_end_ptr(a6),d0
	sub.l r_start_ptr(a6),d0
	cmp.l d1,d0
	blt.s .x
	
	tst.l (a5)
	beq .x
	add.l d1,r_start_ptr(a6)
	add.l d1,(a5)
.x	rts

a_phase2	moveq #0,d1
	move.b r_cmd_param(a6),d1
	beq.s .nu
	move.b d1,r_phase2(a6)
.nu	move.b r_phase2(a6),d1
	tst.l (a5)
	beq.s .x
	add.l d1,(a5)
	rts
.x	add.l d1,AudPtr(a5)
	rts
	
a_posjmp	move.b r_cmd_param(a6),d0
	and #$7f,d0
	move d0,a_nxtpart
	st a_break_flg
	sf a_fake_flg
	rts

a_setvol	move.b r_cmd_param(a6),d0
	beq.s .vol0
	cmp.b #64,d0
	ble.s .vol4
	moveq #64,d0
.vol4	move.b d0,r_volume(a6)
	move.b d0,r_cmd_param(a6)
	move.b d0,AudVolume(a5)
	rts
	
.vol0	tst.b pref_volume
	bne.s .uargh
	lea null,a1
	move.l a1,AudEnd(a5)
	move.l a1,AudRestart(a5)
	move.l a1,AudEndTmp(a5)
	move.l a1,AudRestartTmp(a5)
.uargh	move.b d0,r_volume(a6)
	move.b d0,AudVolume(a5)
	rts

a_setspeed	moveq #0,d0
	move.b r_cmd_param(a6),d0
	cmp #31,d0
	ble.s .ok0
	moveq #31,d0
.ok0	cmp #2,d0
	bhs.s .ok1
	moveq #2,d0
.ok1	move.b d0,r_cmd_param(a6)
	move d0,a_speed
	clr a_counter
	rts

a_break	st a_break_flg
	clr.b a_fake_flg
	rts

a_filter	move.b r_cmd_param(a6),r_filter(a6)
	rts

a_nxt_partnote	dc -1
a_delay_time	dc 0
a_arp_cnt	dc 0
a_arp_speed	dc.b 1
a_fake_flg	dc.b 0
a_sin	dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
	dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18
	
	rsreset
B„„„„„„„„„h	rs 1	0
r_command	rs.b 1	2
r_cmd_param	rs.b 1	3
r_start_ptr	rs.l 1	4
r_end_ptr	rs.l 1	8
r_restart	rs.l 1	12
r_period	rs 1	16
r_volume	rs 1	18
r_chn_switch	rs.b 1	20
r_filter	rs.b 1	21
r_porta_dir	rs.b 1	22
r_my_speed	rs.b 1	23
r_destination	rs 1	24
r_vib_dta	rs.b 1	26
r_vib_cnt	rs.b 1	27
r_porta_speed	rs.b 1	28
r_dbfcnt	rs.b 1	29
r_ptrnpos	rs 1	30
r_phase	rs.b 1	32
r_phase2	rs.b 1
r_oldvolsld	rs.b 1
r_oldnotecut	rs.b 1
r_oldnotedel	rs.b 1
r_oldptrndel	rs.b 1
r_finetune	rs.b 1
r_tremolo	rs.b 1
r_glissando	rs.b 1
r_vibrato	rs.b 1
r_treold	rs.b 1
r_trepos	rs.b 1

a_aud1temp	dc.l 0	0  Current cmd/note
	dc.l 0	4  Start
	dc.l null	8  End
	dc.l null	12 Restart
	dc 0	16 Period
	dc.b 0,0	18 Volym,0
	dc.b 1	20 Channel ON/OFF
	dc.b 0	21 Filter
	dc.b 0	22 #3
	dc.b 0	23 #3
	dc 0	24 #3
	dc.b 0	26 #4
	dc.b 0	27 #4
	dc.b 0	28 #1/#2
	dc.b 0
	dc 0
	ds.b 12
	
a_aud2temp	ds.l 2
	dc.l null,null
	ds 1
	ds.b 2
	ds.b 4
	ds 1
	ds.b 6
	ds.b 12
	
a_aud3temp	ds.l 2
	dc.l null,null
	ds 1
	ds.b 2
	ds.b 4
	ds 1
	ds.b 6
	ds.b 12
	
a_aud4temp	ds.l 2
	dc.l null,null
	ds 1
	ds.b 2
	ds.b 4
	ds 1
	ds.b 6
	ds.b 12
	
a_time	dc 0
a_speed	dc 0
a_partnrplay	dc.l 0
a_counter	dc 0
a_partnote	dc 0
a_samples	dc.l 0
a_sample1	ds.l 31
end_s_adr	dc.l frequency_lst
a_sample2	ds.l 32
a_repeats	dc.l 0
a_repeat1	ds.l 31
a_maxpart	dc 1
a_nxtpart	dc -1
a_break_flg	dc.b 0
a_maxptrn	dc.b 1
e_crpres	dc 0

	rsreset
AudStart	rs.l 1
AudPeriod	rs 1
AudVolume	rs 1
AudEnd	rs.l 1
AudRestart	rs.l 1
AudMute	rs.b 1
AudLastInstr	rs.b 1
AudEndTmp	rs.l 1
AudRestartTmp	rs.l 1
AudInstr	rs 1
AudPeriodSet	rs 1
AudPeriodMidi	rs 1
AudPeriod32	rs.l 1
AudVolumePtr	rs.l 1
AudPtr	rs 1
AudLoPtr	rs 1
AudPrecision	rs 1

audio0	dc.l null	0  start
	dc 0	4  period	SetPeriodFlagoPeriod f”r ASconvert
	dc 0	6  volume*256
	dc.l null	8  end
	dc.l null	12 restart
	dc.b 1	16 channel on/off
	dc.b 0	17 last instr
	dc.l null	18 endb
	dc.l null	22 restartb
	dc 0	26 instr
	dc 0	28 period	PeriodF”rFrekvensTabellsKrafs
	dc 0	30 period	PeriodF”rMidikravs
	dc.l 0	32 32-bit period
	dc.l 0	36 Volume Pointer
	dc 0	40 Current pointer for audio channel
	dc 0	42 Lower part of pointer for this voice
	dc 0	44 Precision for this channel
	
audio1	dc.l null
	ds 2
	dc.l null,null
	dc.b 1,0
	dc.l null,null
	dc 0,0,0
	ds.l 2
	ds 3
	
audio2	dc.l null
	ds 2
	dc.l null,null
	dc.b 1,0
	dc.l null,null
	dc 0,0,0
	ds.l 2
	ds 3
	
audio3	dc.l null
	ds 2
	dc.l null,null
	dc.b 1,0
	dc.l null,null
	dc 0,0,0
	ds.l 2
	ds 3

* Convert to data for replay buffer generation and interrupt!

ASconvert	lea audio0(pc),a0
	move.l a_frqtab_ptr,a1
	lea Amplitudes,a2
	
	moveq #3,d5
	
.l0	tst.b AudMute(a0)
	beq.s .c0
	
	moveq #0,d0
	move AudVolume(a0),d0
	add.l a_voltab_ptr(pc),d0
	move.l d0,AudVolumePtr(a0)
	
	move.l (a0),d0
	beq.s .c1
	clr.l (a0)
	move.l d0,AudPtr(a0)
	clr AudPrecision(a0)
	move.l AudEnd(a0),AudEndTmp(a0)
	move.l AudRestart(a0),AudRestartTmp(a0)
	
.c1	move AudPeriod(a0),d0
	beq.s .c0
	
	and #$3ff,d0
	add d0,d0
	add d0,d0
	move.l (a1,d0),AudPeriod32(a0)
	
.c0	move.l AudPtr(a0),a6
	move.b (a6),d2
	
	move.l AudPtr(a0),d1
	sub.l AudEndTmp(a0),d1	Sample End Passed?
	ble.s .c3
	
	move.l AudEndTmp(a0),d0	
	sub.l AudRestartTmp(a0),d0	A (EndSpl-ReptStart) = ReptLen!
	beq.s .c2		-> NoRepeat InstallNull
	
	divu d0,d1
	swap d1
	move.l AudRestartTmp(a0),a6
	add d1,a6
	cmp.l AudEndTmp(a0),a6
	bhi.s .c2
	move.l a6,AudPtr(a0)	B Mod A + ReptStart = New Reptstart
	bra.s .c3
	
.c2	move.l AudRestartTmp(a0),AudPtr(a0)

.c3	move.l AudPtr(a0),a3
	moveq #0,d0
	move.b (a3),d0
	tst.b pref_volume
	beq .noscaling
	move.l AudVolumePtr(a0),a5
	move.b (a5,d0),d0
.noscaling	tst.b d0
	bpl .ok
	not d0
.ok	and #$7f,d0
	move d0,(a2)+
	move AudPeriod(a0),(a2)+
	move.l a3,(a2)+

	lea audio1-audio0(a0),a0
	
	dbra d5,.l0
	rts

* ASreplayDriver
* Driver for the ring buffer in which the data is stored for the
* replay interrupt/audio dma read.

ASreplayDriver	
	move.l $110.w,a4
	sub.l #player,a4
	move.l a4,d2
	divu #12,d2
	add.l #ste_buf,d2
	cmp.l #end_ste_buf,d2
	bne.s .go
	move.l #ste_buf,d2
.go	move.l d2,d3
	sub.l ste_buf_ptr(pc),d3
	
	cmp.l #__BUF_LEN,d3
	blo .hit
	beq .wrap
	
	move.l ste_buf_ptr(pc),last_wrt

.wrap	move.l ste_buf_ptr(pc),d2

.hit	move.l d2,d4
	move.l last_wrt(pc),a0
	sub.l a0,d2
	bpl .onepartonly
	
	move.l d4,-(a7)
	
	move.l ste_buf_ptr(pc),d4
	add.l #__BUF_LEN,d4
	bsr ste_cnt
	
	move.l (a7)+,d4
	
	move.l ste_buf_ptr(pc),a0
.onepartonly	bsr ste_cnt

	move.l a0,last_wrt
	
.x	
	rts

* Volume control and floating frequency for interrupt driven sound!

ste_cnt	sub.l a0,d4
	lsr.w #1,d4
	subq #1,d4
	bmi .ok3
	movem.l d4/a0,-(a7)
w	set audio2-audio0
	lea audio0(pc),a3
	move.l AudPeriod32(a3),a1	; Voice 1
	move.l AudVolumePtr(a3),d2
	moveq #0,d0
	move AudPrecision(a3),d0
	move.l AudPtr(a3),a5
	move.l w+AudPeriod32(a3),a2	; Voice 2
	move.l w+AudVolumePtr(a3),d3
	moveq #0,d1
	move w+AudPrecision(a3),d1
	move.l w+AudPtr(a3),a6
	move.l a1,d5
	swap d5
	move.l d5,a1	
	move.l a2,d5
	swap d5
	move.l d5,a2
	swap d0
	swap d1
	moveq #0,d5
.l0	moveq #0,d6		4
	add.l a1,d0		8
	addx d6,d0
	add.l a2,d1		8
	addx d6,d1
	move.b (a5,d0),d2	16
	move.l d2,a3		4
	move.b (a3),d6		8
	move.b (a6,d1),d3	16
	move.l d3,a3		4
	move.b (a3),d5		8
	add d5,d6		4
	move d6,(a0)+		8
	dbra d4,.l0		12 / 116
	swap d0
	swap d1
	lea audio0(pc),a3
	add.l d0,AudLoPtr(a3)
	bcc.s .ok0
	addq #1,AudPtr(a3)
.ok0	add.l d1,w+AudLoPtr(a3)
	bcc.s .ok1
	addq #1,w+AudPtr(a3)
.ok1	movem.l (a7)+,d4/a0
	lea audio1-audio0(a3),a3
	move.l AudPeriod32(a3),a1	; Voice 2
	move.l AudVolumePtr(a3),d2
	moveq #0,d0
	move AudPrecision(a3),d0
	move.l AudPtr(a3),a5
	move.l w+AudPeriod32(a3),a2	; Voice 3
	move.l w+AudVolumePtr(a3),d3
	moveq #0,d1
	move w+AudPrecision(a3),d1
	move.l w+AudPtr(a3),a6
	move.l a1,d5
	swap d5
	move.l d5,a1	
	move.l a2,d5
	swap d5
	move.l d5,a2
	swap d0
	swap d1

	move.l A0,D5
	sub.l #ste_buf,D5
	mulu #12,D5
	lea player+4,A4
	add.l D5,A4

	moveq #0,d5
.l1	moveq #0,d6		4
	add.l a1,d0		8
	addx d6,d0
 	add.l a2,d1		8
	addx d6,d1
	move.b (a5,d0),d2	16
	move.l d2,a3		4
	move.b (a3),d6		8
	move.b (a6,d1),d3	16
	move.l d3,a3		4
	move.b (a3),d5		8
	add d5,d6		4
	add (a0)+,d6		12
	add.w D6,D6		;2
	move.w cliptab(PC,D6),d6	;4
	move.w d6,(A4)		;4
	move.b d6,8(A4)		;4
	lea 24(a4),a4
	dbra d4,.l1		12 / 120
	swap d0
	swap d1
	lea audio1(pc),a3
	add.l d0,AudLoPtr(a3)
	bcc.s .ok2
	addq #1,AudPtr(a3)
.ok2	add.l d1,w+AudLoPtr(a3)
	bcc.s .ok3
	addq #1,w+AudPtr(a3)
.ok3	rts
		
digi2	MACRO
	dc.b	(($\1>>8)&15),(($\1>>4)&15)
	dc.b	(($\2>>8)&15),(($\2>>4)&15)
	dc.b	(($\3>>8)&15),(($\3>>4)&15)
	dc.b	(($\4>>8)&15),(($\4>>4)&15)
	dc.b	(($\5>>8)&15),(($\5>>4)&15)
	dc.b	(($\6>>8)&15),(($\6>>4)&15)
	dc.b	(($\7>>8)&15),(($\7>>4)&15)
	dc.b	(($\8>>8)&15),(($\8>>4)&15)
	ENDM

cliptab	dcb.w	$180,0		* bottom clip area
conv2	digi2	000,000,200,300,400,500,510,600
	digi2	600,620,700,720,730,800,800,820
	digi2	830,900,910,920,930,940,950,951
	digi2	A00,A20,A30,A40,A50,A50,A52,A60
	digi2	A62,A70,A71,B00,B10,B30,B40,B40
	digi2	B50,B52,B60,B61,B70,B71,B72,B73
	digi2	B80,B81,B83,B84,B90,C00,C20,C30
	digi2	C40,C50,C51,C52,C60,C62,C70,C72
	digi2	C73,C80,C80,C82,C83,C90,C90,C92
	digi2	c93,c94,c95,c95,ca0,d00,d20,d30
	digi2	d40,d50,d50,d52,d60,d62,d70,d71
	digi2	d73,d74,d80,d82,d83,d90,d90,d92
	digi2	d93,d94,d95,d95,da0,da1,da3,da4
	digi2	da4,da5,da5,da6,da6,da7,da7,db0
	digi2	db1,db2,db3,db4,db5,db5,db6,e00
	digi2	e10,e30,e40,e41,e50,e52,e60,e61
	digi2	e70,e71,e73,e74,e80,e81,e83,e84
	digi2	e90,e92,e93,e94,e95,e95,ea0,ea1
	digi2	ea3,ea4,ea4,ea5,ea5,ea6,ea6,ea7
	digi2	ea7,ea7,eb0,eb2,eb3,eb4,eb5,eb5
	digi2	eb5,eb6,eb6,eb7,eb7,eb7,eb8,eb8
	digi2	eb8,eb8,eb9,ec0,ec1,ec3,ec4,ec4
	digi2	ec5,f00,f10,f30,f40,f41,f50,f52
	digi2	f60,f61,f70,f71,f73,f74,f80,f82
	digi2	f83,f84,f90,f92,f93,f94,f95,f95
	digi2	fa0,fa1,fa3,fa4,fa4,fa5,fa5,fa6
	digi2	fa6,fa7,fa7,fb0,fb0,fb2,fb3,fb4
	digi2	fb5,fb5,fb6,fb6,fb6,fb7,fb7,fb7
	digi2	fb8,fb8,fb8,fb8,fb9,fc0,fc1,fc3
	digi2	fc4,fc4,fc5,fc5,fc6,fc6,fc7,fc7
	digi2	fc7,fc7,fc8,fc8,fc8,fc8,fc9,fc9
	digi2	fc9,fc9,fc9,fc9,fca,fd0,fd1,fd3
	REPT	32			* top clip area
	digi2	fd3,fd3,fd3,fd3,fd3,fd3,fd3,fd3
	ENDR

MakePeriods	move.l period_to_note_ptr,a0
	add #$400,a0
	lea a_arpeggio,a1
	move #1023,d0
	moveq #0,d2
.l0	cmp (a1),d0
	bge .c0
	lea 2(a1),a1
	cmp #$23,d2
	beq .c0
	addq #1,d2
.c0	move.b d2,-(a0)
	dbra d0,.l0
	rts


* Generate frequency table

gen_frq	moveq #ASreplayIrqFrq,d5
	cmp #8,ASreplayOutput
	blt .noste
	moveq #49,d5
.noste	mulu #tune,d5

	move.l a_frqtab_ptr,a0
	addq #4,a0
	moveq #1,d0
.ml1	moveq #0,d2
	move d0,d2
	lsl.l #4,d2
	move.l d5,d3
	divu d2,d3
	move d3,(a0)+
	clr d3
	divu d2,d3
	move d3,(a0)+
	addq #1,d0
	cmp #1024,d0
	blt .ml1
	ifne __OUTPUT>8
	jsr GenFrequency
	endc
.x	rts

* Audio Sculpture 50Hz Sequencer Interrupt
* Could be put in VerticalBlank if there is no need to be running with
* correct speed on monochrome monitor or on a 60 Hz machine as for example
* the TT.

AS50HzIrq	movem.l d0-d7/a0-a6,-(a7)
	not.w $ffff8240.w	
	bsr ASreplay
	bsr ASconvert
	bsr ASreplayDriver
	not.w $ffff8240.w	
	movem.l (a7)+,d0-d7/a0-a6
a_null_irq	rte
	
* Generate various tables for the replay routs

Gurkorna	move.l null_ptr,a0
	moveq #31,d0
	move.l #$80808080,d1
.l7	rept 8
	move.l d1,(a0)+
	endr
	dbra d0,.l7
	rts

* Initialize the 65*256 byte velocity conversion tables

i_voltab	move.l a_voltab_ptr(pc),a0
	moveq #0,d0
.l0	move.l d0,d1
	lsl.l #8,d1
	move #255,d2
	moveq #0,d3
	move #$80,d3
	move d0,d4
	lsr #1,d4
	sub d4,d3
.l1	move.b d3,(a0)+
	swap d3
	add.l d1,d3
	swap d3
	dbra d2,.l1
	addq #4,d0
	cmp #257,d0
	blt .l0
	rts

* The actual initialization of the replay routines

ASreplayInstall	lea a_voltab,a0
	add #255,a0
	move.l a0,d0
	and #$ff00,d0
	move.l d0,a_voltab_ptr
	
	lea end_s_adr(pc),a0
	move.l (a0),a1
	moveq #30,d0
.l0	sub #$400,a1
	move.l a1,-(a0)
	dbra d0,.l0
	
	ifne __OUTPUT>7
	move.l ste_buf_ptr,a0
	move #1023,d0
	ifne __OUTPUT>7
	move.l #$80808080,d1
	elseif
	move.l #$02000200,d1
	endc
.l1	move.l d1,(a0)+
	dbra d0,.l1
	endc
	bsr GenIrqFrq
	bsr Gurkorna
	bsr MakePeriods
	bsr i_voltab
	bsr makequickplay
	bsr ASreplayInit
	bsr gen_frq

* To be removed in the routine which comes with Audio Sculpture!
	
a	set 0
	rept __BUF_LEN/1024	PreGenerateBuffer - The first buffer
	move.l ste_buf_ptr,a0	
	add #1024*a,a0
	move.l a0,d4
	add.l #1024,d4
	jsr ste_cnt
	move.l a0,last_wrt
	jsr ASconvert
a	set a+1
	endr
	move.l ste_buf_ptr,last_wrt

	
	move.l null_ptr,a0
	move.l a0,audio0
	move.l a0,audio1
	move.l a0,audio2
	move.l a0,audio3
	lea audio0,a1
	lea a_aud1temp,a2
	moveq #3,d0
.l2	move.l a0,(a1)
	move.l a0,AudStart(a1)
	move.l a0,AudRestart(a1)
	move.l a0,AudEnd(a1)
	move.l a0,AudRestartTmp(a1)
	move.l a0,AudEndTmp(a1)
	move.l a0,r_end_ptr(a2)
	move.l a0,r_restart(a2)
	lea audio1-audio0(a1),a1
	lea a_aud2temp-a_aud1temp(a2),a2
	dbra d0,.l2

	move #$2700,sr
	bsr _store_all
	move.b #$00,$fffffa07.w
	move.b #$10,$fffffa09.w
	move.b #$00,$fffffa13.w
	move.b #$10,$fffffa15.w
	bclr #3,$fffffa17.w	
	clr.b $fffffa1d.w
	move.b #ASreplayIrqFrq,$fffffa25.w
	move.b #1,$fffffa1d.w
	move.l #AS50HzIrq,$70.w
	move.l ASreplayIrqPtr(pc),$110.w
	lea ste_buf(pc),a4

	move #$2300,sr
	rts

* Quiet!

ASreplayDeInstall
	move #$2700,sr
	bsr _fetch_all
	move.b #$90,$fffffa23.w
	move.l #$0700ff00,$ffff8800.w
	move.l #$08000000,$ffff8888.w
	move.l #$09000000,$ffff8888.w
	move.l #$0a000000,$ffff8888.w
	move #$2300,sr
	rts

* Store Exception vectors... Allow operating system elimination...

_store_all	lea _save_area,a1
	move.b $ffff8260.w,(a1)+
	move.b $ffff820a.w,(a1)+
	move.b $ffff8001.w,(a1)+
	lea $fffffa01.w,a0
	moveq #23,d0
.l0	move.b (a0),(a1)+
	lea 2(a0),a0
	dbra d0,.l0
	addq.l #1,a1
	lea 8.w,a0
	moveq #77,d0
.l1	move.l (a0)+,(a1)+
	dbra d0,.l1
	rts

* Fetch Exception vectors... Reinstall operating system...
	
_fetch_all	lea _save_area,a0
	tst.b (a0)+
	move.b (a0)+,$ffff820a.w
	move.b (a0)+,$ffff8001.w
	lea $fffffa01.w,a1
	moveq #23,d0
.l1	move.b (a0)+,(a1)
	lea 2(a1),a1
	dbra d0,.l1
	addq.l #1,a0
	lea 8.w,a1
	moveq #77,d0
.l0	move.l (a0)+,(a1)+
	dbra d0,.l0
	rts

; YM2149 Soundchip - Create the Quick play buffer.

makequickplay	lea player,a0
	move.l a0,a1
	movem.l playonesam(pc),d0-d5
	move #$400-2,d7
.make_lp	lea 24(a0),a0
	move.w a0,d4
	movem.l d0-d5,-24(a0)
	dbf d7,.make_lp
	move.w a1,d4
	movem.l d0-d5,(a0)
	rts

playonesam	move.l #$08000000,$ffff8800.w		; 8 bytes
	move.l #$09000000,$ffff8800.w		; 8 bytes
	move.w #2,$112.w			; 6 bytes
	rte					; 2 bytes

* Misc Params

GenIrq_flg	dc 0
ste_buf_ptr	dc.l ste_buf		Pointer to the buffer which is in internal mode no more than 16384 bytes in front of the instruction reading it...
a_voltab_ptr	dc.l 0		Pointer to the 256-byte boundary aligned volume tables

last_wrt	dc.l ste_buf		Pointer to the last updated address in the circular output buffer
a_data_ptr	dc.l a_data		Pointer to the bottom of the current module in memory
a_eof_ptr	dc.l a_eof		Pointer to the top of the module
a_frqtab_ptr	dc.l a_frqtab
period_to_note_ptr
	dc.l period_to_note
null_ptr	dc.l null

ste_buf	ds.l __BUF_LEN/4
end_ste_buf	dc.w -1
	ds.w 32

	section data

a_data	incbin b:\6beat.mod
	even
a_eof

__N_SAMPLES	equ 31

	section bss
	
	ds.l 256*__N_SAMPLES
frequency_lst	ds.l 38

_save_area	ds.l 128			512	Vector and Hardware registers save area

	cnop 0,4
a_voltab	ds.w 128
	ds.l 4224
	ds.w 128
	
null	ds.w 512			1024	Null sample where all pointers are while playing nothing
period_to_note	ds.l 256			1024	Conversion table from Amiga period to Absolute note number
a_frqtab	ds.l 1024			4096	Conversion table from Amiga Period to Audio Sculpture Fixed Point Interval
	
	ds.l 199
stack	ds.l 3