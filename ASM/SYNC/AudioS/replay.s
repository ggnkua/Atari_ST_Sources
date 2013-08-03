
_prg_base

	opt o-

	jmp main(pc)

* Audio Sculpture Replay Routines
*
* (c) 1991 Bengt Sj”len, Synchron Assembly and Expose Software
* Dedicated...

* This routine is delivered together with Audio Sculpture to make it
* possible for you, dear user, to incorporate the music you have
* composed in Audio Sculpture into your own programs, demos, games or
* whatever. These routines may be used freely in both private and
* commercial software as long as it is clearly expressed in the program
* that the routine comes from Audio Sculpture.

* The source is quite long due to the fact that 11 replay routines exist
* here but most of it is written condititionally meaning that no unused
* code will be present in your program. It is written in Devpac2
* but should run well in any assembler which can handle conditional code
* and local variables! The TEXT segment will be about 5800 bytes on any
* of the output selections and the base BSS area will be 8800 bytes, adding
* 16384 for internal sound(The mixing table for YM2149), 17400 for 
* volume control(Volume conversion tables) and 18000 for output modes 9 and 
* 10(Step table for the different frequencies).

* How to use this replay sourcefile...

__OUTPUT	equ 0

* With this variable you set which output mode to use!
*
*   0 Mono YM2149
*   1 Mono ST-Replay
*   2 Mono Centronics
*   3 Stereo YM2149+ST-Replay
*   4 Stereo YM2149+Centronics
*   5 Stereo ST-Replay+Centronics
*   6 Stereo Playback Cartridge
*   7 MV16+ST-Replay Professional (12-bit)
*   8 STE/TT Audio DMA with full fixed point frequency control
*   9 STE/TT Audio DMA 50kHz Mode with quantized frequencies
*  10 STE/TT Extended Audio DMA (16-bit) with quantized frequencies

__VOLUME	equ 1

* With this variable you select volume control on or off.
* 
*   0 Volume Control Off
*   1 Volume Control On

__OVERSAMP	equ 0

* With this variable you select oversampling on or off. Only available
* in output mode 8.

ste_cfrq	dc.b 2

* With this variable you select the frequency of the STE/TT audio DMA.
*
*   0  6259 Hz
*   1 12517 Hz
*   2 25033 Hz
*   3 50066 Hz

ASreplayIrqFrq	dc.b 45

* This sets the frequency of the interrupt in internal replay to
* 614400/ASreplayIrqFrq that is in this case 16.6 kHz...

tune	dc 96

* With this variable the syntheseizer can be tuned. This value is exactly
* the same as the one in the tune option in Audio Sculpture!

* If no trap accesses and such crap are used registers a4 and d7 may be
* used by the interrupts without saving on stack which gains quite some
* time. To force this, resulting in that a4 and d7 must not be touched by
* your programs, put a zero in the following variable. Notice that
* means that you must run your own vertical blanks and keyboard routines
* so TimerC and VBL interrupt must be removed. This is automagically
* done in the routine ASreplayInstall when needed...

__TRAPPED	equ 1

* This is your module which should absolutely be at the end of your
* data segment...

	section data

a_data	incbin \*.mod
a_eof

* ...and immedeately followed by the "ds" area in the bss segment. This
* area should be the number of instruments used in your module mulptiplied
* by 1024 bytes large, even though you only have to enter the number of
* instruments used here:

__N_SAMPLES	equ 31

	section bss
	
	ds.l 256*__N_SAMPLES
	
	section text

Amplitudes	ds.l 8	* Structure containing for each channel of sound:
		* The current amplitude.w from 0 to 127, the current
		* period.w, a pointer.l to the last read byte in the
		* sample... Quite useful for making oscilloscopes,
		* spectrum analyzers and volume leds!


__sq_ptr	equ $3b8 $1d8
__ptrn_ptr	equ $43c $258
__DEF_SPEED	equ 6

__BUF_LEN	equ 2048	2048 for internal sound at the moment...

pref_volume	dc.b __VOLUME


	ifne (__OUTPUT=0)!(__OUTPUT=3)!(__OUTPUT=4)
__OFFSET	equ $4000
__TABLE	equ 1
	else
__OFFSET	equ $1000
__TABLE	equ 0
	endc




* Interrupt generation
*
* Puts together different interrupt routines for different outputs and
* sets up pointers to buffers as well as generating a frequency table
* which is tuned so that it is independent of the interrupt frequency
* 
* Dedicated to Anna / Written by Bengtus / Copyright 1991 Synchron Assembly

GenIrqFrq	st GenIrq_flg

	move ASreplayOutput,d1
	add d1,d1
	add d1,d1
	lea pref_irq_tab(pc),a0
	move.l (a0,d1),a0
	jsr GenIrq
	
	jsr gen_frq
	
	ifne __VOLUME
	jsr i_voltab
	endc
	
	tst.b ste_flg
	beq.s .c1
	
	clr.b $ffff8901.w
	
.c1	sf GenIrq_flg

	cmp #2,ASreplayOutput
	beq .centronics
	cmp #4,ASreplayOutput
	beq .centronics
	cmp #5,ASreplayOutput
	beq .centronics
	move.l #$7007f00,$ffff8800.w
	rts
.centronics	move.l #$700ff00,$ffff8800.w
	rts

	
* Pointers to cmd strings used while generating the different IRQs

pref_irq_tab	dc.l int_m_cmd,rep_m_cmd,cen_m_cmd
	dc.l ir_s_cmd,ic_s_cmd,rc_s_cmd
	dc.l fafb_s_cmd
	dc.l pro_m_cmd
	rept 3
	dc.l null_cmd
	endr
	
ASreplayIrqPtr	dc.l a_gnu
ASreplayOutput	dc __OUTPUT

GenIrq	lea a_gnu,a1
	lea -2(a1),a2
	move.l a2,ASmodifyPtr
.l0	moveq #0,d0
	move.b (a0)+,d0
	bmi GenIrqBas
	add d0,d0
	add d0,d0
	move.l cmd_lst(pc,d0),a2
	lea (a2),a3
.scan	cmp #$4e75,(a3)+
	bne .scan
	lea -2(a3),a3
.l1	cmp.l a2,a3
	bls .l0
	move -(a3),-(a1)
	bra .l1

cmd_lst	dc.l cde_int4,cde_update4,cde_int2,cde_rep4,cde_cen4
	dc.l cde_cen2,cde_rep2,cde_reb2,cde_pro4,cde_update2a
	dc.l stackd7,cde_update2b,stacka4,stuckd7,stucka4,cde_rec2
	
null_cmd	dc.b -1
int_m_cmd	dc.b 0,1,10,-1
rep_m_cmd	dc.b 3,1,10,-1
cen_m_cmd	dc.b 4,1,10,-1
ir_s_cmd	dc.b 2,14,11,6,9,12,10,-1
ic_s_cmd	dc.b 2,11,5,9,10,-1
rc_s_cmd	dc.b 13,14,6,11,5,9,12,10,-1
fafb_s_cmd	dc.b 13,14,15,11,7,9,12,10,-1
pro_m_cmd	dc.b 13,8,1,10,-1

GenIrqBas	move.l a1,ASreplayIrqPtr
	lea (a1),a0
	lea ASmodifyPtr(pc),a2
.l0	cmp #$3e3a,(a0)
	bne .c0
	addq #2,a0
	move #__OFFSET,(a0)
	move.l a0,(a2)
	bra GenIrqBasPtr
.c0	lea 2(a0),a0
	cmp.l #a_gnu,a0
	blt .l0
	
GenIrqBasPtr	lea (a1),a0
.l0	cmp #$5479,(a0)
	beq .hit
	cmp #$5879,(a0)
	bne .c0
.hit	move.l (a2),2(a0)
	lea 6(a0),a0
	bra .l1
.c0	lea 2(a0),a0
	cmp.l #a_gnu,a0
	blt .l0
.l1	cmp #__OFFSET+__BUF_LEN-2,(a0)
	bne .c1
	move.l (a2),2(a0)
	bra .c1b
.c1	lea 2(a0),a0
	cmp.l #a_gnu,a0
	blt .l1
.c1b	lea (a1),a0
.l2	cmp #$3e3b,(a0)
	bne .c2
	move.l (a2),d0
	sub.l a0,d0
	move.b d0,3(a0)
	addq #2,d0
	move d0,-2(a0)
	bra .x
.c2	lea 2(a0),a0
	cmp.l #a_gnu,a0
	blt .l2
.x	move.l (a2),a0
	add #16384,a0
	move.l a0,ste_buf_ptr
	move.l a0,last_wrt
	rts

stackd7	
	ifne __TRAPPED
	move d7,-(a7)
	endc
	rts

stacka4	
	ifne __TRAPPED
	move.l a4,-(a7)
	endc
	rts

stuckd7	
	ifne __TRAPPED
	move (a7)+,d7
	endc
	rts

stucka4	
	ifne __TRAPPED
	move.l (a7)+,a4
	endc
	rts
	
cde_update4	move kanan(pc),d7	12
kanan	equ *-2
	addq #2,kanan		20
	and #__OFFSET+__BUF_LEN-2,kanan	24
	rts

cde_update2a	move banan(pc),d7	12
banan	equ *-2
	rts
	
cde_update2b	move banan(pc),d7	12
	move banan+2(pc,d7),d7	16
	addq #4,banan		20
	and #__OFFSET+__BUF_LEN-2,banan	24
	rts
	
cde_int4	lsl #4,d7		  16 YM 2149 - 4 Voices
	move.l .gnu(pc,d7),$ffff8888.w	  32
	move.l .gnu+4(pc,d7),$ffff8888.w  32
	move.l .gnu+8(pc,d7),$ffff8888.w  32
	ifne __TRAPPED
	move (a7)+,d7		  8
	endc
	rts
	
.gnu	movem.l .gnu(pc,d7),d6-d7/a4	  44
	movem.l d6-d7/a4,$ffff8888.w	  36
	rts

cde_int2	add #256,d7
	lsl #4,d7		  16 YM2149 - 2 Voices
	move.l .gnu(pc,d7),$ffff8888.w	  32
	move.l .gnu+4(pc,d7),$ffff8888.w  32
	move.l .gnu+8(pc,d7),$ffff8888.w  32
	ifne __TRAPPED
	move (a7)+,d7		  8
	endc
	rts
.gnu
	
cde_rep4	
	ifne __TRAPPED
	move.l a4,-(a7)		12 ST Replay - 4 Voices
	endc
	lsr #1,d7		8
	lea $fa0000,a4		12
	tst.b (a4,d7)		16
	ifne __TRAPPED
	move.l (a7)+,a4		12
	move (a7)+,d7		8
	endc
	rts

cde_cen4	lsr #2,d7		12 Centronics - 4 Voices
	move #$f00,$ffff8888.w	16
	move.b d7,$ffff888a.w	12 
	ifne __TRAPPED
	move (a7)+,d7		8
	endc
	rts

cde_reb2	lea $fb0200,a4		12
	tst.b (a4,d7)		16
	rts

cde_rec2	lea $fb0000,a4		12
	tst.b (a4,d7)		16
	rts

cde_rep2	lea $fa0000,a4		12
	tst.b (a4,d7)		16
	rts

cde_cen2	lsr #1,d7		2  Centronics - 2 Voices
	move #$f00,$ffff8888.w	16
	move.b d7,$ffff888a.w	8
	rts

cde_pro4	
	ifne __TRAPPED
	move.l a4,-(a7)
	endc
	add d7,d7		4
	add d7,d7		4
	lea $fa0000,a4		12
	tst.b (a4,d7)		16
	ifne __TRAPPED
	move.l (a7)+,a4
	endc
	rts








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
*
* Driver for the ring buffer in which the data is stored for the
* replay interrupt/audio dma read.

ASreplayDriver	
	ifne __TRAPPED
	movem.l d6-d7/a4,-(a7)
	else
	move.l d6,-(a7)
	endc

	tst.b DmaLick
	beq .flash

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
	bra .x
	
.flash	cmp #8,ASreplayOutput
	bhs .ste	
	
	move.l ASmodifyPtr(pc),a0	Interrupt...
	move (a0),d2
	add d2,a0
	move.l a0,d2
	bra .go
	
.ste	moveq #0,d2		AudioDMA...
	move.b $ffff8909.w,d2
	swap d2
	move.b $ffff890b.w,d2
	ror #8,d2
	move.b $ffff890d.w,d2
	
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
	ifne __TRAPPED
	movem.l (a7)+,d6-d7/a4
	else
	move.l (a7)+,d6
	endc
	rts










	ifne (__OUTPUT<3)!((__OUTPUT>6)&(__OUTPUT<8))
	
	ifne __VOLUME
	
* Volume control and floating frequency for interrupt driven sound!
*	
* Approx. execution time (112+120)*frq/8000000 of processor time on
* 8 MHz ST... -> 29% CPU time for 10kHz

ste_cnt	sub.l a0,d4
	lsr d4
	subq #1,d4
	bmi .ok3
	
	movem.l d4/a0,-(a7)
	
w	set audio2-audio0

	lea audio0(pc),a3
	
	move.l AudPeriod32(a3),a1	Voice 1
	move.l AudVolumePtr(a3),d2
	moveq #0,d0
	move AudPrecision(a3),d0
	move.l AudPtr(a3),a5
	
	move.l w+AudPeriod32(a3),a2	Voice 2
	move.l w+AudVolumePtr(a3),d3
	moveq #0,d1
	move w+AudPrecision(a3),d1
	move.l w+AudPtr(a3),a6

	moveq #0,d5
	
.l0	add.l a1,d0		8
	add.l a2,d1		8
	
	swap d0		4
	swap d1		4
	
	moveq #0,d6		4
	move.b (a5,d0),d2	16
	move.l d2,a3		4
	move.b (a3),d6		8
	move.b (a6,d1),d3	16
	move.l d3,a3		4
	move.b (a3),d5		8
	add d5,d6		4
	move d6,(a0)+		8

	swap d0		4
	swap d1		4

	dbra d4,.l0		12 / 116
	
	lea audio0(pc),a3
	
	add.l d0,AudLoPtr(a3)
	bcc.s .ok0
	addq #1,AudPtr(a3)
.ok0	add.l d1,w+AudLoPtr(a3)
	bcc.s .ok1
	addq #1,w+AudPtr(a3)
.ok1	
	movem.l (a7)+,d4/a0

	lea audio1-audio0(a3),a3
	
	move.l AudPeriod32(a3),a1	Voice 1
	move.l AudVolumePtr(a3),d2
	moveq #0,d0
	move AudPrecision(a3),d0
	move.l AudPtr(a3),a5
	
	move.l w+AudPeriod32(a3),a2	Voice 2
	move.l w+AudVolumePtr(a3),d3
	moveq #0,d1
	move w+AudPrecision(a3),d1
	move.l w+AudPtr(a3),a6

	moveq #0,d5
	
.l1	add.l a1,d0		8
 	add.l a2,d1		8

	swap d0		4
	swap d1		4

	moveq #0,d6		4
	move.b (a5,d0),d2	16
	move.l d2,a3		4
	move.b (a3),d6		8
	move.b (a6,d1),d3	16
	move.l d3,a3		4
	move.b (a3),d5		8
	add d5,d6		4
	add d6,(a0)+		12
	
	swap d0		4
	swap d1		4
	
	dbra d4,.l1		12 / 120
	
	lea audio1(pc),a3
	
	add.l d0,AudLoPtr(a3)
	bcc.s .ok2
	addq #1,AudPtr(a3)
.ok2	add.l d1,w+AudLoPtr(a3)
	bcc.s .ok3
	addq #1,w+AudPtr(a3)
.ok3	rts

	else

* No volume control but floating frequency for interrupt driven sound!
*	
* Approx. execution time (112+120)*frq/8000000 of processor time on
* 8 MHz ST... -> 29% CPU time for 10kHz

ste_cnt	sub.l a0,d4
	lsr d4
	subq #1,d4
	bmi .ok3
	
	movem.l d4/a0,-(a7)
	
w	set audio2-audio0

	lea audio0(pc),a3
	
	move.l AudPeriod32(a3),a1	Voice 1
	moveq #0,d0
	move AudPrecision(a3),d0
	move.l AudPtr(a3),a5
	
	move.l w+AudPeriod32(a3),a2	Voice 2
	moveq #0,d1
	move w+AudPrecision(a3),d1
	move.l w+AudPtr(a3),a6

	moveq #0,d5
	
.l0	add.l a1,d0		8
	add.l a2,d1		8
	
	swap d0		4
	swap d1		4
	
	moveq #0,d6		4
	move.b (a5,d0),d6	16
	move.b (a6,d1),d5	16
	add d5,d6		4
	move d6,(a0)+		8

	swap d0		4
	swap d1		4

	dbra d4,.l0		12 / 116
	
	lea audio0(pc),a3
	
	add.l d0,AudLoPtr(a3)
	bcc.s .ok0
	addq #1,AudPtr(a3)
.ok0	add.l d1,w+AudLoPtr(a3)
	bcc.s .ok1
	addq #1,w+AudPtr(a3)
.ok1	
	movem.l (a7)+,d4/a0

	lea audio1-audio0(a3),a3
	
	move.l AudPeriod32(a3),a1	Voice 1
	moveq #0,d0
	move AudPrecision(a3),d0
	move.l AudPtr(a3),a5
	
	move.l w+AudPeriod32(a3),a2	Voice 2
	moveq #0,d1
	move w+AudPrecision(a3),d1
	move.l w+AudPtr(a3),a6

	moveq #0,d5
	
.l1	add.l a1,d0		8
 	add.l a2,d1		8

	swap d0		4
	swap d1		4

	moveq #0,d6		4
	move.b (a5,d0),d6	16
	move.b (a6,d1),d5	16
	add d5,d6		4
	add d6,(a0)+		12
	
	swap d0		4
	swap d1		4
	
	dbra d4,.l1		12 / 120
	
	lea audio1(pc),a3
	
	add.l d0,AudLoPtr(a3)
	bcc.s .ok2
	addq #1,AudPtr(a3)
.ok2	add.l d1,w+AudLoPtr(a3)
	bcc.s .ok3
	addq #1,w+AudPtr(a3)
.ok3	rts

	endc
	endc

	ifne (__OUTPUT>2)&(__OUTPUT<7)
	
	ifne __VOLUME
	
* Volume control and floating frequency for interrupt driven sound!
*	
* Approx. execution time (112+120)*frq/8000000 of processor time on
* 8 MHz ST... -> 29% CPU time for 10kHz

ste_cnt	sub.l a0,d4
	lsr #2,d4
	subq #1,d4
	bmi .ok3
	
	movem.l d4/a0,-(a7)
	
w	set audio2-audio0

	lea audio0(pc),a3
	
	move.l AudPeriod32(a3),a1	Voice 1
	move.l AudVolumePtr(a3),d2
	moveq #0,d0
	move AudPrecision(a3),d0
	move.l AudPtr(a3),a5
	
	move.l w+AudPeriod32(a3),a2	Voice 2
	move.l w+AudVolumePtr(a3),d3
	moveq #0,d1
	move w+AudPrecision(a3),d1
	move.l w+AudPtr(a3),a6

	moveq #0,d5
	
.l0	add.l a1,d0		8
	add.l a2,d1		8
	
	swap d0		4
	swap d1		4
	
	moveq #0,d6		4
	move.b (a5,d0),d2	16
	move.l d2,a3		4
	move.b (a3),d6		8
	move.b (a6,d1),d3	16
	move.l d3,a3		4
	move.b (a3),d5		8
	add d5,d6		4
	move d6,(a0)		8
	lea 4(a0),a0

	swap d0		4
	swap d1		4

	dbra d4,.l0		12 / 116
	
	lea audio0(pc),a3
	
	add.l d0,AudLoPtr(a3)
	bcc.s .ok0
	addq #1,AudPtr(a3)
.ok0	add.l d1,w+AudLoPtr(a3)
	bcc.s .ok1
	addq #1,w+AudPtr(a3)
.ok1	
	movem.l (a7)+,d4/a0

	lea audio1-audio0(a3),a3
	
	move.l AudPeriod32(a3),a1	Voice 1
	move.l AudVolumePtr(a3),d2
	moveq #0,d0
	move AudPrecision(a3),d0
	move.l AudPtr(a3),a5
	
	move.l w+AudPeriod32(a3),a2	Voice 2
	move.l w+AudVolumePtr(a3),d3
	moveq #0,d1
	move w+AudPrecision(a3),d1
	move.l w+AudPtr(a3),a6
	lea 2(a0),a0

	moveq #0,d5
	
.l1	add.l a1,d0		8
 	add.l a2,d1		8

	swap d0		4
	swap d1		4

	moveq #0,d6		4
	move.b (a5,d0),d2	16
	move.l d2,a3		4
	move.b (a3),d6		8
	move.b (a6,d1),d3	16
	move.l d3,a3		4
	move.b (a3),d5		8
	add d5,d6		4
	move d6,(a0)		12
	lea 4(a0),a0
	
	swap d0		4
	swap d1		4
	
	dbra d4,.l1		12 / 120
	
	lea -2(a0),a0
	lea audio1(pc),a3
	
	add.l d0,AudLoPtr(a3)
	bcc.s .ok2
	addq #1,AudPtr(a3)
.ok2	add.l d1,w+AudLoPtr(a3)
	bcc.s .ok3
	addq #1,w+AudPtr(a3)
.ok3	rts

	else

* No volume control but floating frequency for interrupt driven sound!
*	
* Approx. execution time (112+120)*frq/8000000 of processor time on
* 8 MHz ST... -> 29% CPU time for 10kHz

ste_cnt	sub.l a0,d4
	lsr #2,d4
	subq #1,d4
	bmi .ok3
	
	movem.l d4/a0,-(a7)
	
w	set audio2-audio0

	lea audio0(pc),a3
	
	move.l AudPeriod32(a3),a1	Voice 1
	moveq #0,d0
	move AudPrecision(a3),d0
	move.l AudPtr(a3),a5
	
	move.l w+AudPeriod32(a3),a2	Voice 2
	moveq #0,d1
	move w+AudPrecision(a3),d1
	move.l w+AudPtr(a3),a6

	moveq #0,d5
	
.l0	add.l a1,d0		8
	add.l a2,d1		8
	
	swap d0		4
	swap d1		4
	
	moveq #0,d6		4
	move.b (a5,d0),d6	16
	move.b (a6,d1),d5	16
	add d5,d6		4
	move d6,(a0)+		8

	swap d0		4
	swap d1		4

	dbra d4,.l0		12 / 116
	
	lea audio0(pc),a3
	
	add.l d0,AudLoPtr(a3)
	bcc.s .ok0
	addq #1,AudPtr(a3)
.ok0	add.l d1,w+AudLoPtr(a3)
	bcc.s .ok1
	addq #1,w+AudPtr(a3)
.ok1	
	movem.l (a7)+,d4/a0

	lea audio1-audio0(a3),a3
	
	move.l AudPeriod32(a3),a1	Voice 1
	moveq #0,d0
	move AudPrecision(a3),d0
	move.l AudPtr(a3),a5
	
	move.l w+AudPeriod32(a3),a2	Voice 2
	moveq #0,d1
	move w+AudPrecision(a3),d1
	move.l w+AudPtr(a3),a6

	moveq #0,d5
	
.l1	add.l a1,d0		8
 	add.l a2,d1		8

	swap d0		4
	swap d1		4

	moveq #0,d6		4
	move.b (a5,d0),d6	16
	move.b (a6,d1),d5	16
	add d5,d6		4
	move d6,(a0)+		12
	
	swap d0		4
	swap d1		4
	
	dbra d4,.l1		12 / 120
	
	lea audio1(pc),a3
	
	add.l d0,AudLoPtr(a3)
	bcc.s .ok2
	addq #1,AudPtr(a3)
.ok2	add.l d1,w+AudLoPtr(a3)
	bcc.s .ok3
	addq #1,w+AudPtr(a3)
.ok3	rts

	endc
	endc










	ifne __OUTPUT=8
	ifeq __OVERSAMP
	
	
* (132+124)*frq/8000000

ste_cnt	sub.l a0,d4
	lsr d4
	subq #1,d4
	bmi .ok3
	
	movem.l d4/a0,-(a7)
	
w	set audio2-audio0

	lea audio0(pc),a3
	
	move.l AudPeriod32(a3),a1	Voice 1
	move.l AudVolumePtr(a3),d2
	moveq #0,d0
	move AudPrecision(a3),d0
	move.l AudPtr(a3),a5
	
	move.l w+AudPeriod32(a3),a2	Voice 2
	move.l w+AudVolumePtr(a3),d3
	moveq #0,d1
	move w+AudPrecision(a3),d1
	move.l w+AudPtr(a3),a6

	moveq #0,d5
	moveq #0,d6		4
	move #$80,d7
	
.l0	add.l a1,d0		8
	add.l a2,d1		8
	
	swap d0		4
	swap d1		4
	
	move.b (a5,d0),d2	16
	move.l d2,a3		4
	move.b (a3),d6		8
	move.b (a6,d1),d3	16
	move.l d3,a3		4
	move.b (a3),d5		8
	add d5,d6		4
	lsr d6		8
	eor d7,d6		4
	move d6,(a0)+		8

	swap d0		4
	swap d1		4

	dbra d4,.l0		12 / 124
	
	lea audio0(pc),a3
	
	add.l d0,AudLoPtr(a3)
	bcc.s .ok0
	addq #1,AudPtr(a3)
.ok0	add.l d1,w+AudLoPtr(a3)
	bcc.s .ok1
	addq #1,w+AudPtr(a3)
.ok1	
	movem.l (a7)+,d4/a0

	lea audio1-audio0(a3),a3
	
	move.l AudPeriod32(a3),a1	Voice 1
	move.l AudVolumePtr(a3),d2
	moveq #0,d0
	move AudPrecision(a3),d0
	move.l AudPtr(a3),a5
	
	move.l w+AudPeriod32(a3),a2	Voice 2
	move.l w+AudVolumePtr(a3),d3
	moveq #0,d1
	move w+AudPrecision(a3),d1
	move.l w+AudPtr(a3),a6

	moveq #0,d5
	moveq #0,d6		4
	
.l1	add.l a1,d0		8
 	add.l a2,d1		8

	swap d0		4
	swap d1		4

	move.b (a5,d0),d2	16
	move.l d2,a3		4
	move.b (a3),d6		8
	move.b (a6,d1),d3	16
	move.l d3,a3		4
	move.b (a3),d5		8
	add d5,d6		4
	lsr d6		8
	eor d7,d6		4
	move.b d6,(a0)+		8
	lea 1(a0),a0		8
	
	swap d0		4
	swap d1		4
	
	dbra d4,.l1		12 / 132
	
	lea audio1(pc),a3
	
	add.l d0,AudLoPtr(a3)
	bcc.s .ok2
	addq #1,AudPtr(a3)
.ok2	add.l d1,w+AudLoPtr(a3)
	bcc.s .ok3
	addq #1,w+AudPtr(a3)
.ok3	rts

	else
	
* 344*frq/8000000

ste_cnt	sub.l a0,d4
	lsr #2,d4
	subq #1,d4
	bmi .ok3
	
	movem.l d4/a0,-(a7)
	
w	set audio2-audio0

	lea audio0(pc),a3
	
	move.l AudPeriod32(a3),a1	Voice 1
	move.l AudVolumePtr(a3),d2
	moveq #0,d0
	move AudPrecision(a3),d0
	move.l AudPtr(a3),a5
	
	move.l w+AudPeriod32(a3),a2	Voice 2
	move.l w+AudVolumePtr(a3),d3
	moveq #0,d1
	move w+AudPrecision(a3),d1
	move.l w+AudPtr(a3),a6

	moveq #0,d5
	move.l tabben_ptr,a4
	move .old0(pc),d7
	
.l0	add.l a1,d0		8
	add.l a2,d1		8
	
	swap d0		4
	swap d1		4
	
	moveq #0,d6		4
	move.b (a5,d0),d2	16
	move.l d2,a3		4
	move.b (a3),d6		8
	move.b (a6,d1),d3	16
	move.l d3,a3		4
	move.b (a3),d5		8
	add d5,d6		4
	
	add d6,d7		4
	move.b (a4,d7),(a0)	20
	move d6,d7		4
	add d6,d6		4
	move.b (a4,d6),2(a0)	24
	lea 4(a0),a0		8

	swap d0		4
	swap d1		4

	dbra d4,.l0		12 / 172
	
	move d7,.old0
	lea audio0(pc),a3
	
	add.l d0,AudLoPtr(a3)
	bcc.s .ok0
	addq #1,AudPtr(a3)
.ok0	add.l d1,w+AudLoPtr(a3)
	bcc.s .ok1
	addq #1,w+AudPtr(a3)
.ok1	
	movem.l (a7)+,d4/a0

	lea audio1-audio0(a3),a3
	
	move.l AudPeriod32(a3),a1	Voice 1
	move.l AudVolumePtr(a3),d2
	moveq #0,d0
	move AudPrecision(a3),d0
	move.l AudPtr(a3),a5
	
	move.l w+AudPeriod32(a3),a2	Voice 2
	move.l AudVolumePtr(a3),d3
	moveq #0,d1
	move w+AudPrecision(a3),d1
	move.l w+AudPtr(a3),a6

	moveq #0,d5
	move .old1(pc),d7
	addq #1,a0
	
.l1	add.l a1,d0		8
 	add.l a2,d1		8

	swap d0		4
	swap d1		4

	moveq #0,d6		4
	move.b (a5,d0),d2	16
	move.l d2,a3		4
	move.b (a3),d6		8
	move.b (a6,d1),d3	16
	move.l d3,a3		4
	move.b (a3),d5		8
	add d5,d6		4

	add d6,d7		4
	move.b (a4,d7),(a0)	20
	move d6,d7		4
	add d6,d6		4
	move.b (a4,d6),2(a0)	24
	lea 4(a0),a0		8
	
	swap d0		4
	swap d1		4
	
	dbra d4,.l1		12 / 172
	subq #1,a0
	
	move d7,.old1
	
	lea audio1(pc),a3
	
	add.l d0,AudLoPtr(a3)
	bcc.s .ok2
	addq #1,AudPtr(a3)
.ok2	add.l d1,w+AudLoPtr(a3)
	bcc.s .ok3
	addq #1,w+AudPtr(a3)
.ok3	rts
.old0	dc $100
.old1	dc $100

	endc	
	endc















 	ifne __OUTPUT=10

ste_cnt	sub.l a0,d4
	lsr #1,d4
	move d4,d5
.recurse	sub #250,d4
	ble .calculate
	move d4,-(a7)
	move #250,d5
	bsr .calculate
	move (a7)+,d4
	move d4,d5
	bra .recurse
	
.calculate	subq #1,d5
	bmi .x
	
	lea audio0,a4
	move.l period_to_note_ptr,a3
	lea frequency_lst,a2
	
w	set audio1-audio0

	moveq #0,d0
	move AudPeriodSet(a4),d1
	move.b (a3,d1),d0
	add d0,d0
	add d0,d0
	move.l (a2,d0),a1
	
	move w+AudPeriodSet(a4),d1
	move.b (a3,d1),d0
	add d0,d0
	add d0,d0
	move.l (a2,d0),d1
	sub.l a1,d1
	move d1,.l0+2
	
	move 2*w+AudPeriodSet(a4),d1
	move.b (a3,d1),d0
	add d0,d0
	add d0,d0
	move.l (a2,d0),d1
	sub.l a1,d1
	move d1,.l0+6
	
	move 3*w+AudPeriodSet(a4),d1
	move.b (a3,d1),d0
	add d0,d0
	add d0,d0
	move.l (a2,d0),d1
	sub.l a1,d1
	move d1,.l0+10
	
	move AudVolume(a4),d1
	lsr d1
	move w+AudVolume(a4),d3
	lsr d3
	move 2*w+AudVolume(a4),d2
	lsr d2
	move 3*w+AudVolume(a4),d4
	lsr d4
	
	move.l a_voltab_ptr(pc),a6
	
	move.l AudPtr(a4),a2
	move.l 2*w+AudPtr(a4),a3
	move.l 3*w+AudPtr(a4),a5
	move.l w+AudPtr(a4),a4
	
	move #$80,d0
	moveq #0,d6		4
	moveq #0,d7		4
	
.l0	add 0(a1),a4		16	Update pointers
	add 0(a1),a3		16
	add 0(a1),a5		16
	add (a1)+,a2		12
	
	move.b (a2),d1		8	Amplitude Calculations
	move d1,d6		4
	add d6,d6		4
	move (a6,d6),d7		16
	
	move.b (a3),d2		8
	move d2,d6		4
	add d6,d6		4
	add (a6,d6),d7		16
	
	move.b (a4),d3		8
	move d3,d6		4
	add d6,d6		4
	add (a6,d6),d7		16
	
	move.b (a5),d4		8
	move d4,d6		4
	add d6,d6		4
	add (a6,d6),d7		16
	
	eor d0,d7		4
	move d7,(a0)+		8
	
	dbra d5,.l0		12 / 212
	
	lea audio0,a1
	move.l a2,AudPtr(a1)
	move.l a3,2*w+AudPtr(a1)
	move.l a4,w+AudPtr(a1)
	move.l a5,3*w+AudPtr(a1)
	
.x	rts

	endc
	
	
	
	
	
	
	
	
	
	
	
	
	
	ifne __OUTPUT=9
	ifne __VOLUME=1

* 200*frq/8000000

ste_cnt	sub.l a0,d4
	lsr #1,d4
	move d4,d5
.recurse	sub #250,d4
	ble .calculate
	move d4,-(a7)
	move d5,-(a7)
	move #250,d5
	bsr .calculate
	move (a7)+,d5
	move (a7)+,d4
	move d4,d5
	bra .recurse
.calculate	subq #1,d5
	bmi .x
	
	lea audio0,a4
	move.l period_to_note_ptr,a3
	lea frequency_lst,a2
	
w	set audio1-audio0

	moveq #0,d0
	move AudPeriodSet(a4),d1
	move.b (a3,d1),d0
	add d0,d0
	add d0,d0
	move.l (a2,d0),a1
	
	move w+AudPeriodSet(a4),d1
	move.b (a3,d1),d0
	add d0,d0
	add d0,d0
	move.l (a2,d0),d1
	sub.l a1,d1
	move d1,.l0+2
	
	move 2*w+AudPeriodSet(a4),d1
	move.b (a3,d1),d0
	add d0,d0
	add d0,d0
	move.l (a2,d0),d1
	sub.l a1,d1
	move d1,.l0+6
	
	move 3*w+AudPeriodSet(a4),d1
	move.b (a3,d1),d0
	add d0,d0
	add d0,d0
	move.l (a2,d0),d1
	sub.l a1,d1
	move d1,.l0+10
	
	move.l AudVolumePtr(a4),d1
	move.l w+AudVolumePtr(a4),d3
	move.l 2*w+AudVolumePtr(a4),d2
	move.l 3*w+AudVolumePtr(a4),d4
	
	move.l AudPtr(a4),a2
	move.l 2*w+AudPtr(a4),a3
	move.l 3*w+AudPtr(a4),a5
	move.l w+AudPtr(a4),a4
	
	move #$80,d0
	moveq #0,d6		4
	moveq #0,d7		4
	
.l0	add 2(a1),a4		16	Update pointers
	add 2(a1),a3		16
	add 2(a1),a5		16
	add (a1)+,a2		12
	
	move.b (a2),d1		8	Amplitude Calculations
	move.l d1,a6		4
	move.b (a6),d7		8
	move.b (a3),d2		8
	move.l d2,a6		4
	move.b (a6),d6		8
	add d6,d7		4
	lsr d7		8
	eor d0,d7		4
	move.b d7,(a0)+		8
	
	move.b (a4),d3		8
	move.l d3,a6		4
	move.b (a6),d7		8
	move.b (a5),d4		8
	move.l d4,a6		4
	move.b (a6),d6		8
	add d6,d7		4
	lsr d7		8
	eor d0,d7		4
	move.b d7,(a0)+		8
	
	dbra d5,.l0		12 / 200
	
	lea audio0,a1
	move.l a2,AudPtr(a1)
	move.l a3,2*w+AudPtr(a1)
	move.l a4,w+AudPtr(a1)
	move.l a5,3*w+AudPtr(a1)
	
.x	rts

	else

* 152*frq

ste_cnt	sub.l a0,d4
	lsr #1,d4
	move d4,d5
.recurse	sub #250,d4
	ble .calculate
	move d4,-(a7)
	move d5,-(a7)
	move #250,d5
	bsr .calculate
	move (a7)+,d5
	move (a7)+,d4
	move d4,d5
	bra .recurse
	
.calculate	subq #1,d5
	bmi .x

	moveq #0,d6
	moveq #0,d7
	lea audio0,a4
	move.l period_to_note_ptr,a3
	lea frequency_lst,a2
	
w	set audio1-audio0

	moveq #0,d0
	move AudPeriodSet(a4),d1
	move.b (a3,d1),d0
	add d0,d0
	add d0,d0
	move.l (a2,d0),a1
	
	move w+AudPeriodSet(a4),d1
	move.b (a3,d1),d0
	add d0,d0
	add d0,d0
	move.l (a2,d0),d1
	sub.l a1,d1
	move d1,.l0+2
	
	move 2*w+AudPeriodSet(a4),d1
	move.b (a3,d1),d0
	add d0,d0
	add d0,d0
	move.l (a2,d0),d1
	sub.l a1,d1
	move d1,.l0+6
	
	move 3*w+AudPeriodSet(a4),d1
	move.b (a3,d1),d0
	add d0,d0
	add d0,d0
	move.l (a2,d0),d1
	sub.l a1,d1
	move d1,.l0+10
	
	move.l AudPtr(a4),a2
	move.l 2*w+AudPtr(a4),a3
	move.l 3*w+AudPtr(a4),a5
	move.l w+AudPtr(a4),a4

	move #$80,d0
	moveq #0,d6		4
	moveq #0,d7		4
	
.l0	add 2(a1),a4		16	Update pointers
	add 2(a1),a3		16
	add 2(a1),a5		16
	add (a1)+,a2		12
	
	move.b (a2),d7		8	Amplitude Calculations
	move.b (a3),d6		8
	add d6,d7		4
	lsr d7		8
	eor d0,d7		4
	move.b d7,(a0)+		8
	
	move.b (a4),d6		8
	move.b (a5),d7		8
	add d6,d7		4
	lsr d7		8
	eor d0,d7		4
	move.b d7,(a0)+		8
	
	dbra d5,.l0		12 / 152
	
	lea audio0,a1
	move.l a2,AudPtr(a1)
	move.l a3,2*w+AudPtr(a1)
	move.l a4,w+AudPtr(a1)
	move.l a5,3*w+AudPtr(a1)
.x	rts

	endc
	endc




	ifne (__OUTPUT=0)!(__OUTPUT=3)!(__OUTPUT=4)

* Mixing table generation algorithm for YM2149
*
* Dedicated to Johanna... / Written by Bengtus! / ½ 1991 Synchron Assembly!

YM2149tableGen	lea a_tab,a1
	move #1023,d0
.clr	move.l #$8000000,(a1)+
	move.l #$9000000,(a1)+
	move.l #$a000000,(a1)+
	st -1(a1)
	clr.l (a1)+
	dbra d0,.clr
	
	lea index,a0
	lea a_tab+320*16,a1
	move #384,d4
	moveq #0,d0
.l0	moveq #0,d1
.l1	moveq #0,d2
.l2	moveq #0,d3
	move (a0,d0),d3
	add (a0,d1),d3
	add (a0,d2),d3
	mulu #340,d3
	lsr.l #8,d3
	cmp d4,d3
	bhs .x
	lsl #4,d3
	lea (a1,d3),a2
	move d0,d3
	lsr d3
	move.b d3,10(a2)
	move d1,d3
	lsr d3
	move.b d3,6(a2)
	move d2,d3
	lsr d3
	move.b d3,2(a2)
	sf 11(a2)
.x	addq #2,d2
	cmp #32,d2
	blt .l2
	addq #2,d1
	cmp #32,d1
	blt .l1
	addq #2,d0
	cmp #32,d0
	blt .l0

PostProcessing	lea a_tab,a0
	moveq #0,d0
	moveq #0,d1
	moveq #0,d2
	move #1023,d3
.l0	tst.b 11(a0)
	beq .n0
	move.b d0,2(a0)
	move.b d1,6(a0)
	move.b d2,10(a0)
	sf 11(a0)
	bra .n1
.n0	move.b 2(a0),d0
	move.b 6(a0),d1
	move.b 10(a0),d2
.n1	lea 16(a0),a0
	dbra d3,.l0

	rts

index	dc 0,0,0,1,2,3,5,6,9,$e,$16,$20,$33,$50,$88,$f3
	endc






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

gen_frq	moveq #0,d5
	move.b ASreplayIrqFrq(pc),d5
	cmp #8,ASreplayOutput
	blt .noste
	moveq #49,d5
.noste	mulu tune(pc),d5
	ifne __OUTPUT>7
	add.l d5,d5
	ifne __OVERSAMP&(__OUTPUT=8)
	add.l d5,d5
	endc
	moveq #0,d0
	move.b ste_cfrq(pc),d0
	lsr.l d0,d5
	endc
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
*
* Could be put in VerticalBlank if there is no need to be running with
* correct speed on monochrome monitor or on a 60 Hz machine as for example
* the TT.

AS50HzIrq	tst.b AS50HzRunning
	bne .x
	
	st AS50HzRunning
	
	move #$2300,sr
	movem.l d0-d5/a0-a3/a5-a6,-(a7)
	
	cmp #8,ASreplayOutput
	bhs .ste
	
	tst.b DmaLick		Interrupt...
	beq .nxt
	
	clr.b $fffffa19.w
	move.l ASreplayIrqPtr(pc),$134.w
	move.b ASreplayIrqFrq(pc),$fffffa1f.w
	move.b #1,$fffffa19.w
	move.l ASmodifyPtr(pc),a0
	move #__OFFSET,(a0)
	sf DmaLick
	bra .nxt
	
.ste	tst.b DmaLick		Audio DMA
	beq .nxto
	
	clr.b $ffff8901.w
	
.nxto	move.l ste_buf_ptr(pc),d1
	move.l d1,d0
	move.b d0,$ffff8907.w
	rol #8,d0
	move.b d0,$ffff8905.w
	swap d0
	move.b d0,$ffff8903.w
	add.l #__BUF_LEN,d1
	move.b d1,$ffff8913.w
	rol #8,d1
	move.b d1,$ffff8911.w
	swap d1
	move.b d1,$ffff890f.w
	
	tst.b DmaLick
	beq .nxt
	
	move.b ste_cfrq,$ffff8921.w
	move.b #3,$ffff8901.w
	sf DmaLick
	
.nxt	move.b DmaKick(pc),DmaLick
	sf DmaKick
	
	tst.b GenIrq_flg	Sequence Tabu
	bne .exo

	bsr ASreplay
	bsr ASconvert
	bsr ASreplayDriver

.exo	movem.l (a7)+,d0-d5/a0-a3/a5-a6
	sf AS50HzRunning
	
	tst.b AS50HzTriple
	beq .zijuttu
	
	addq #1,AS50HzDouble
	cmp #2,AS50HzDouble
	blt .ziljad
	
	movem.l d0-d5/a0-a3/a5-a6,-(a7)
	rept 2
	bsr ASreplay
	bsr ASconvert
	endr
	movem.l (a7)+,d0-d5/a0-a3/a5-a6
	clr AS50HzDouble
	st DmaKick
	
.ziljad	sf AS50HzTriple
	rte
	
.zijuttu	sf AS50HzTriple
	clr AS50HzDouble
	rte
	
.x	st AS50HzTriple
a_null_irq	rte
	
AS50HzRunning	dc.b 0
DmaLick	dc.b 0
DmaKick	dc.b 0

AS50HzTriple	dc 0
AS50HzDouble	dc 0
















	
* Generate various tables for the replay routs

Gurkorna	
	ifne __OVERSAMP&(__OUTPUT=8)
	move.l tabben_ptr,a0
	moveq #0,d0
	move #1023,d1
.q1	move d0,d2
	addq #2,d2
	lsr #2,d2
	cmp #$100,d2
	blt .gah
	moveq #-1,d2
.gah	eor.b #$80,d2
	move.b d2,(a0)+
	addq #1,d0
	dbra d1,.q1
	endc
	
	move.l null_ptr,a0
	moveq #31,d0
	move.l #$80808080,d1
.l7	rept 8
	move.l d1,(a0)+
	endr
	dbra d0,.l7
	
	rts







* Initialize the 65*256 byte velocity conversion tables

	ifne __VOLUME
i_voltab	
	ifne __OUTPUT=10
	move.l a_voltab_ptr(pc),a0
	moveq #0,d0
.l2	move.l d0,d1
	lsl.l #8,d1
	lsl.l #5,d1
	move #255,d2
	moveq #0,d3
	move #$1000,d3
	move d0,d4
	lsl #4,d4
	sub d4,d3
.l3	move d3,(a0)+
	swap d3
	add.l d1,d3
	swap d3
	dbra d2,.l3
	addq #8,d0
	cmp #257,d0
	blt .l2
	else
	move.l a_voltab_ptr(pc),a0
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
	endc
	rts
	endc















	
	
	
	
	
	
	
	
	
	ifne __OUTPUT>8
	
* Generate locked frequency tables for output modes 9 and 10!
	
GenFrequency	lea frequency_lst,a0
	move.l frequency_ptr,a1
	lea a_arpeggio,a3
	move.l a_frqtab_ptr,a5
	
.l0	move (a3)+,d0
	beq .x
	move.l a1,(a0)+
	add d0,d0
	add d0,d0
	move.l (a5,d0),d0
	moveq #0,d1
	move #249,d2
.l1	move.l d1,d3
	add.l d0,d1
	swap d3
	swap d1
	sub d1,d3
	swap d1
	neg d3
	move d3,(a1)+
	dbra d2,.l1
	bra .l0
.x	rts
	endc









* The actual initialization of the replay routines
* Setup pointers, buffers, interrupts and 

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
	
	move #$4e73,a_gnu
	
	ifne __OUTPUT>7
	move.l ste_buf_ptr,a0
	move #1023,d0
	ifne __OUTPUT>7
	move.l #$80808080,d1
	else
	move.l #$02000200,d1
	endc
.l1	move.l d1,(a0)+
	dbra d0,.l1
	endc
	
	ifne (__OUTPUT=0)!(__OUTPUT=3)!(__OUTPUT=4)
	bsr YM2149tableGen
	endc
	bsr GenIrqFrq
	bsr Gurkorna
	jsr MakePeriods
	ifne __VOLUME
	jsr i_voltab
	endc
	jsr ASreplayInit
	bsr gen_frq
	
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
	
	st DmaKick

i	move #$2700,sr
	bsr _store_all
	move.l ASreplayIrqPtr,$134.w
	move.l #AS50HzIrq,$110.w
	ifeq __TRAPPED
	move.l #a_null_irq,$70.w
	move.l #a_null_irq,$114.w
	clr.b $fffffa1d.w
	endc
	or.l #$200010,$fffffa06.w
	or.l #$200010,$fffffa12.w
	clr.b $fffffa19.w
	and.b #$f0,$fffffa1d.w
	move.b #246,$fffffa25.w
	or.b #7,$fffffa1d.w	
	bclr #3,$fffffa17.w	
	move #$2300,sr
	
	rts




* Quiet!

ASreplayDeInstall
	move #$2700,sr
	ifne (__OUTPUT>7)
	clr.b $ffff8901.w
	endc
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
	tst.b ste_flg
	beq .nxt
	clr.b $ffff8901.w
.nxt	rts







* The main routine... initialization of this God damned thing!

main	clr.l -(a7)		Enter Supervisor Mode
	move #$20,-(a7)
	trap #1
	move.l d0,2(a7)
	
	bsr ASreplayInstall	Start playing music
	
	ifne __TRAPPED
	move #7,-(a7)		Wait for key with operating system
	trap #1
	addq #2,a7
	else
.wait	cmp.b #$b9,$fffffc02.w	Wait for space without operating system
	bne .wait
	endc
	
	bsr ASreplayDeInstall	Stop playing music

_save_usp	move #$22,-(a7)		Release all keys
	trap #14
	addq #2,a7
	move.l d0,a0
	clr.l $6c(a0)
	trap #1		User Mode
	clr (a7)		Terminate
	trap #1
















* Misc Params

	ifne __OUTPUT>7
ste_flg	dc -1		STE
	else
ste_flg	dc 0		ST
	endc
ASmodifyPtr	ds.l 1		Pointer to the PC-relative pointer inside the interrupt routine
GenIrq_flg	dc 0
ste_buf_ptr	dc.l ste_buf		Pointer to the buffer which is in internal mode no more than 16384 bytes in front of the instruction reading it...
a_voltab_ptr	dc.l 0		Pointer to the 256-byte boundary aligned volume tables

save_usp	dc.l 0
last_wrt	dc.l ste_buf		Pointer to the last updated address in the circular output buffer

	ifne __OUTPUT>8		Pointer to the bottom of the frequency tables for output mode 9 and 10
frequency_ptr	dc.l frequency
	endc
a_data_ptr	dc.l a_data		Pointer to the bottom of the current module in memory
a_eof_ptr	dc.l a_eof		Pointer to the top of the module
a_frqtab_ptr	dc.l a_frqtab
period_to_note_ptr
	dc.l period_to_note
tabben_ptr	dc.l tabben
null_ptr	dc.l null
	
	cnop 0,4

	section bss

frequency_lst	
	ifne __OUTPUT>8			152	The table of pointers to the frequency tables for output mode 9 and 10
	ds.l 38
	endc
_save_area	ds.l 128			512	Vector and Hardware registers save area
	ds 49			100	This is the area in which the interrupt routine is generated
a_gnu	ds 1

	ifne (__OUTPUT=0)!(__OUTPUT=3)!(__OUTPUT=4)	16384	The Internal Mixing tables in 1024 levels, 4 long words per level
a_tab	ds.l 4096
	else
a_frqtab	ds.l 1024			4096	Conversion table from Amiga Period to Audio Sculpture Fixed Point Interval
	endc

ste_buf	ds __BUF_LEN>>1+32		2112	The circular buffer in which all ST and STE sounds are generated before being played
a_voltab	
	ifne __VOLUME			17408	65 Volume tables aligned to a 256-byte boundary
	ds 128
	ds.l 4224
	ds 128
	endc
	
tabben	
	ifne __OVERSAMP&(__OUTPUT=8)			1024	Oversampling tables used by output mode 8
	ds.b 1024
	endc
	
null	ds 512			1024	Null sample where all pointers are while playing nothing
period_to_note	ds.l 256			1024	Conversion table from Amiga period to Absolute note number
	ifne __TABLE
a_frqtab	ds.l 1024			4096	Conversion table from Amiga Period to Audio Sculpture Fixed Point Interval
	endc
	ifne __OUTPUT>8			18000	Frequency tables used for output modes 9 and 10
frequency	ds 36*250
	endc
_prg_end


