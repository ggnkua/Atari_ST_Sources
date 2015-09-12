;===========================================================================
;		STE Noistracker v1.0 Replay Code : ROT version
;===========================================================================
;     		    (c)1991 Oberje' of the Fingerbobs
;===========================================================================
;
; This code creates the STE_TRK.ROT file that can be used to play many
; Amiga soundtracker/noisetracker modules. Some soundtracker modules
; do not play quite right, I think this is because Noistracker handles
; sample looping in a slightly different way!
;
; This code is pretty much the original Nosetracker code with a couple
; of subtle changes to allow the PAULA emulation section of the code to
; work! So pretty much all that has changed in the Noisetracker code is
; the addresses used for the chip registers, which have been replaced with
; the PAULA emulators addressess!
;
; See the file STE_TRK.S for instructions on how to use this code.
;
; Thanks to Griff for the tip about playing samples forwards!
; Great stuff dude!
;
;===========================================================================

TIMING	equ	0

; ROT file call hooks

rot_copy	bra	show_message
rot_init	bra	my_init
rot_start	bra	start_music
rot_end		bra	stop_music
rot_vbl		bra	mt_music

message		dc.b	27,"E"
		dc.b	"********************",13,10
		dc.b	"* STE Noistracker  *",13,10
		dc.b	"*  Module Player   *",13,10
		dc.b	"********************",13,10
		dc.b	"*                  *",13,10
		dc.b	"* Coded by.......  *",13,10
		dc.b	"* A.Buchanan       *",13,10
		dc.b	"*                  *",13,10
		dc.b	"* 12KHz            *",13,10
		dc.b	"* Realtime Volume  *",13,10
		dc.b	"* 55% CPU Time     *",13,10
		dc.b	"*                  *",13,10
		dc.b	"* If you want to   *",13,10
		dc.b	"* use this routine *",13,10
		dc.b	"* contact me at..  *",13,10
		dc.b	"*                  *",13,10
		dc.b	"* 6 Carron Terrace *",13,10
		dc.b	"* Stonehaven       *",13,10
		dc.b	"* AB3 2HX          *",13,10
		dc.b	"* Scotland         *",13,10
		dc.b	"*                  *",13,10
		dc.b	"********************",13,10
		dc.b	0
		
		even		

show_message	pea	message(pc)
		move.w	#9,-(a7)
		trap	#1
		addq.l	#2,a7
		move.w	#8,-(a7)
		trap	#1
		addq.l	#2,a7
		rts

;===========================================================================
;===========================================================================
;============================= NOISETRACKER CODE ===========================
;========================= ( Minor changes to code ) =======================
;===========================================================================
;===========================================================================

nbr_ins	dc.w	0

;
; Init changed to accept pre STv2 modules e.g DOC
;
my_init move.l	a0,mt_data	; Music Init
	move.l	#$1d8,const_1+2
	move.l	#$258,const_2+2	; OLD modules
	move.w	#15,nbr_ins
	cmp.l	#'M.K.',$438(a0)	
	bne.s	.small
	move.l	#$3b8,const_1+2
	move.l	#$43c,const_2+2	; NEW modules
	move.w	#31,nbr_ins
	
.small	move.l	a0,a1
	add.l	const_1+2,a1
	moveq	#$7f,d0
	moveq	#0,d1
mt_loop move.l	d1,d2
	subq.w	#1,d0
mt_lop2 move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	mt_loop
	dbf	d0,mt_lop2
	addq.b	#1,d2

	lea	mt_samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	const_2+2,d2
	add.l	a0,d2
	move.l	d2,a2
	move.w	nbr_ins,d0
mt_lop3 clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	asl.l	#1,d1
	add.l	d1,a2
	add.l	#$1e,a0
	dbf	d0,mt_lop3

	move.b	#$6,mt_speed
	clr.b	mt_songpos
	clr.b	mt_counter
	clr.w	mt_pattpos
	rts



mt_end 	rts			; Music OFF

mt_music 
	movem.l	d0-d7/a0-a6,-(a7)
	move.l	mt_data,a0
	addq.b	#$1,mt_counter
	move.b	mt_counter,D0
	cmp.b	mt_speed,D0
	blt.s	mt_nonew	; FX
	clr.b	mt_counter
	bra	mt_getnew	; Play

;
; Do FX
;
mt_nonew 
	lea	mt_voice1(pc),a6	
	lea	chip1(pc),a5
	bsr	mt_checkcom
	lea	mt_voice2(pc),a6
	lea	chip2(pc),a5
	bsr	mt_checkcom
	lea	mt_voice3(pc),a6
	lea	chip3(pc),a5
	bsr	mt_checkcom
	lea	mt_voice4(pc),a6
	lea	chip4(pc),a5
	bsr	mt_checkcom
	bra	mt_endr

;
; FX   Arpeggio
;
mt_arpeggio 
	moveq	#0,d0
	move.b	mt_counter,d0	; Counter
	divs	#$3,d0		;
	swap	d0		; Modulo 3
	cmp.w	#$0,d0
	beq.s	mt_arp2		; Note
	cmp.w	#$2,d0
	beq.s	mt_arp1		; Note + Lo Nibble Half notes

	moveq	#0,d0		; Note + Hi Nibble Half notes
	move.b	$3(a6),d0
	lsr.b	#4,d0
	bra.s	mt_arp3
mt_arp1 moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	bra.s	mt_arp3
mt_arp2 move.w	$10(a6),d2
	bra.s	mt_arp4
mt_arp3 asl.w	#1,d0
	moveq	#0,d1
	move.w	$10(a6),d1
	lea	mt_periods(pc),a0
	moveq	#$24,d7
mt_arploop 
	move.w	(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	mt_arp4
	addq.l	#2,a0
	dbf	d7,mt_arploop
	rts
mt_arp4 move.w	d2,$6(a5)
	rts

;
; PLAY
;
mt_getnew 
	move.l	mt_data,a0
	move.l	a0,a3
	move.l	a0,a2
	add.l	#$c,a3
const_1	add.l	#$3b8,a2
const_2	add.l	#$43c,a0

	moveq	#0,d0
	move.l	d0,d1
	move.b	mt_songpos,d0
	move.b	(a2,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	mt_pattpos,d1

	lea	chip1,a5
	lea	mt_voice1(pc),a6
	bsr.s	mt_playvoice
	lea	chip2,a5
	lea	mt_voice2(pc),a6
	bsr.s	mt_playvoice
	lea	chip3,a5
	lea	mt_voice3(pc),a6
	bsr.s	mt_playvoice
	lea	chip4,a5
	lea	mt_voice4(pc),a6
	bsr.s	mt_playvoice
	bra	mt_setdma

mt_playvoice 
	move.l	(a0,d1.l),(a6)	; ABBB CDEE
	addq.l	#4,d1
	moveq	#0,d2		; D2=0
	move.b	$2(a6),d2	; D2=CD
	and.b	#$f0,d2		; D2=C_
	lsr.b	#4,d2		; D2=_C
	move.b	(a6),d0		; D0=AB
	and.b	#$f0,d0		; D0=A_
	or.b	d0,d2		; D2=AC
	tst.b	d2		;
	beq.s	mt_setregs	; No Ins..
	moveq	#0,d3		;
	lea	mt_samplestarts(pc),a1
	move.l	d2,d4		; D4=AC
	subq.l	#$1,d2		; D2=D2-1
	asl.l	#2,d2		; D2=D2*4
	mulu	#$1e,d4		; D4=D4*30
	move.l	(a1,d2.l),$4(a6)	; Get Sample Start
	move.w	(a3,d4.l),$8(a6)	; Get Sample length
	move.w	$2(a3,d4.l),$12(a6)	; Get Sample volume
	move.w	$4(a3,d4.l),d3		; Get Restart
	tst.w	d3		; 0 = No loop
	beq.s	mt_noloop
	move.l	$4(a6),d2	; Sample Start
	asl.w	#1,d3		; Restart * 2
	add.l	d3,d2		; Sample restart
	move.l	d2,$a(a6)	;
	move.w	$4(a3,d4.l),d0	; Restart+Replen
	add.w	$6(a3,d4.l),d0	;
	move.w	d0,8(a6)	; Sample Length = restart+Replen
	move.w	$6(a3,d4.l),$e(a6)	; Replen
	move.w	$12(a6),$8(a5)		; Volume
	bra.s	mt_setregs
mt_noloop 
	move.l	$4(a6),d2		;
	add.l	d3,d2
	move.l	d2,$a(a6)
	move.w	$6(a3,d4.l),$e(a6)	
	move.w	$12(a6),$8(a5)
mt_setregs 
	move.w	(a6),d0
	and.w	#$fff,d0
	beq	mt_checkcom2
	move.b	$2(a6),d0
	and.b	#$F,d0
	cmp.b	#$3,d0
	bne.s	mt_setperiod
	bsr	mt_setmyport
	bra	mt_checkcom2
mt_setperiod 
	move.w	(a6),$10(a6)
	and.w	#$fff,$10(a6)
	clr.b	$1b(a6)

	move.l	$4(a6),(a5)
	move.w	$8(a6),$4(a5)
	
	move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	bra	mt_checkcom2

mt_setdma 
	lea	chip4,a5
	lea	mt_voice4(pc),a6
	move.l	$a(a6),$a(a5)
	move.w	$e(a6),$e(a5)
	lea	chip3,a5
	lea	mt_voice3(pc),a6
	move.l	$a(a6),$a(a5)
	move.w	$e(a6),$e(a5)
	lea	chip2,a5
	lea	mt_voice2(pc),a6
	move.l	$a(a6),$a(a5)
	move.w	$e(a6),$e(a5)
	lea	chip1,a5
	lea	mt_voice1(pc),a6
	move.l	$a(a6),$a(a5)
	move.w	$e(a6),$e(a5)

	add.w	#$10,mt_pattpos
	cmp.w	#$400,mt_pattpos
	bne.s	mt_endr
mt_nex 	clr.w	mt_pattpos
	clr.b	mt_break
	addq.b	#1,mt_songpos
	and.b	#$7f,mt_songpos
	move.b	mt_songpos,d1
	move.l	mt_data,d2
	add.l	$3b6,d2
	cmp.b	d2,d1
	bne.s	mt_endr
	clr.b	mt_songpos
mt_endr tst.b	mt_break
	bne.s	mt_nex
	bra	render_sample

mt_setmyport 
	move.w	(a6),d2
	and.w	#$fff,d2
	move.w	d2,$18(a6)
	move.w	$10(a6),d0
	clr.b	$16(a6)
	cmp.w	d0,d2
	beq.s	mt_clrport
	bge.s	mt_rt
	move.b	#$1,$16(a6)
	rts
mt_clrport 
	clr.w	$18(a6)
mt_rt 	rts

mt_myport 
	move.b	$3(a6),d0
	beq.s	mt_myslide
	move.b	d0,$17(a6)
	clr.b	$3(a6)
mt_myslide 
	tst.w	$18(a6)
	beq.s	mt_rt
	moveq	#0,d0
	move.b	$17(a6),d0
	tst.b	$16(a6)
	bne.s	mt_mysub
	add.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	bgt.s	mt_myok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
mt_myok move.w	$10(a6),$6(a5)
	rts
mt_mysub 
	sub.w	d0,$10(a6)
	move.w	$18(a6),d0
	cmp.w	$10(a6),d0
	blt.s	mt_myok
	move.w	$18(a6),$10(a6)
	clr.w	$18(a6)
	move.w	$10(a6),$6(a5)
	rts

mt_vib 	move.b	$3(a6),d0
	beq.s	mt_vi
	move.b	d0,$1a(a6)

mt_vi 	move.b	$1b(a6),d0
	lea	mt_sin(pc),a4
	lsr.w	#$2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b	(a4,d0.w),d2
	move.b	$1a(a6),d0
	and.w	#$f,d0
	mulu	d0,d2
	lsr.w	#$6,d2
	move.w	$10(a6),d0
	tst.b	$1b(a6)
	bmi.s	mt_vibmin
	add.w	d2,d0
	bra.s	mt_vib2
mt_vibmin 
	sub.w	d2,d0
mt_vib2 move.w	d0,$6(a5)
	move.b	$1a(a6),d0
	lsr.w	#$2,d0
	and.w	#$3c,d0
	add.b	d0,$1b(a6)
	rts

mt_nop 	move.w	$10(a6),$6(a5)
	rts

mt_checkcom 
	move.w	$2(a6),d0
	and.w	#$fff,d0
	beq.s	mt_nop
	move.b	$2(a6),d0
	and.b	#$f,d0
	tst.b	d0
	beq	mt_arpeggio
	cmp.b	#$1,d0
	beq.s	mt_portup
	cmp.b	#$2,d0
	beq	mt_portdown
	cmp.b	#$3,d0
	beq	mt_myport
	cmp.b	#$4,d0
	beq	mt_vib
	move.w	$10(a6),$6(a5)
	cmp.b	#$a,d0
	beq.s	mt_volslide
	rts

mt_volslide 
	moveq	#0,d0
	move.b	$3(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_voldown
	add.w	d0,$12(a6)
	cmp.w	#$40,$12(a6)
	bmi.s	mt_vol2
	move.w	#$40,$12(a6)
mt_vol2 move.w	$12(a6),$8(a5)
	rts

mt_voldown 
	moveq	#0,d0
	move.b	$3(a6),d0
	and.b	#$f,d0
	sub.w	d0,$12(a6)
	bpl.s	mt_vol3
	clr.w	$12(a6)
mt_vol3 move.w	$12(a6),$8(a5)
	rts

mt_portup 
	moveq	#0,d0
	move.b	$3(a6),d0
	sub.w	d0,$10(a6)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	cmp.w	#$71,d0
	bpl.s	mt_por2
	and.w	#$f000,$10(a6)
	or.w	#$71,$10(a6)
mt_por2 move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	rts

mt_portdown 
	clr.w	d0
	move.b	$3(a6),d0
	add.w	d0,$10(a6)
	move.w	$10(a6),d0
	and.w	#$fff,d0
	cmp.w	#$358,d0
	bmi.s	mt_por3
	and.w	#$f000,$10(a6)
	or.w	#$358,$10(a6)
mt_por3 move.w	$10(a6),d0
	and.w	#$fff,d0
	move.w	d0,$6(a5)
	rts

mt_checkcom2 
	move.b	$2(a6),d0
	and.b	#$f,d0
	cmp.b	#$e,d0
	beq.s	mt_setfilt
	cmp.b	#$d,d0
	beq.s	mt_pattbreak
	cmp.b	#$b,d0
	beq.s	mt_posjmp
	cmp.b	#$c,d0
	beq.s	mt_setvol
	cmp.b	#$f,d0
	beq.s	mt_setspeed
	rts

mt_setfilt 
	rts
	
mt_pattbreak 
	not.b	mt_break
	rts
mt_posjmp 
	move.b	$3(a6),d0
	subq.b	#$1,d0
	move.b	d0,mt_songpos
	not.b	mt_break
	rts
mt_setvol 
	cmp.b	#$40,$3(a6)
	ble.s	mt_vol4
	move.b	#$40,$3(a6)
mt_vol4 move.b	$3(a6),$9(a5)
	rts
mt_setspeed 
	move.b	$3(a6),d0
	and.w	#$1f,d0
	beq.s	mt_rts2
	clr.b	mt_counter
	move.b	d0,mt_speed
mt_rts2 rts

mt_sin 
 dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
 dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18

mt_periods 
 dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a,$021a,$01fc,$01e0
 dc.w $01c5,$01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d,$010d,$00fe
 dc.w $00f0,$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f,$0087
 dc.w $007f,$0078,$0071,$0000,$0000

mt_speed 	dc.b	$6
mt_songpos 	dc.b	$0
mt_pattpos 	dc.w	$0
mt_counter 	dc.b	$0

mt_break 	dc.b	$0
mt_samplestarts ds.l	$1f
mt_voice1 	ds.w	10
		dc.w	0
		ds.w	3
mt_voice2 	ds.w	10
		dc.w	0
		ds.w	3
mt_voice3 	ds.w	10
		dc.w	0
		ds.w	3
mt_voice4 	ds.w	10
		dc.w	0
		ds.w	3

chip1	ds.w	16
chip2	ds.w	16
chip3	ds.w	16
chip4	ds.w	16

;===========================================================================
;===========================================================================
;========================= STE, PAULA EMULATOR CODE ========================
;===========================================================================
;===========================================================================

render_sample
	IFNE	TIMING
	move.w	#$777,$ffff8240.w
	ENDC
	bsr	set_buffers	; Set buffers

	lea	mt_voice1,a6
	lea	chip1,a5
	lea	construct_1,a2
	bsr	render_channel

	lea	mt_voice2,a6
	lea	chip2,a5
	lea	construct_2,a2
	bsr	render_channel

	lea	mt_voice3,a6
	lea	chip3,a5
	lea	construct_3,a2
	bsr	render_channel

	lea	mt_voice4,a6
	lea	chip4,a5
	lea	construct_4,a2
	bsr	render_channel
	IFNE	TIMING
	move.w	#$770,$ffff8240.w
	ENDC

	bsr	mix_voices	; Mix voices together!

	movem.l	(a7)+,d0-d7/a0-a6
	IFNE	TIMING
	move.w	#$777,$ffff8240.w
	ENDC
	rts

;
; VOICEx
; ------
; +$0	.L	ABBB CDEE ( Tracker entry )
; +$4	.L	Sample Start
; +$8	.W	Sample Length ( Words )
; +$a	.L	Sample Restart
; +$e	.W	Sample Repeat Length ( Words )
; +$10	.W	Note
; +$12	.W	Volume
; +$14	.W	*** Not Used ***
; +$16	.B	Tone Portamento : Up/Down Slide
; +$17	.B	Tone Portamento : Speed
; +$18	.B	Tone Portamento : Target Note
; +$1a	.B	Vibrato : Data
; +$1b	.B	Vibrato : Sine Table marker?
;
; CHIPx
; -----
; +$0	.L	Sample Start ( Replacewith Sample End )
; +$4	.W	Sample Length ( Multiply by 2 )
; +$6	.W	Note
; +$8	.W	Volume
; +$a	.L	Sample Restart ( Replacewith Sample RestartEnd )
; +$e	.W	Sample Replen ( Multipy by 2 )
; +$10	.L	Real Sample Length ( -ve )
;

;===========================================================================
;===========================================================================
render_channel
	IFNE	TIMING
	add.w	#$222,$ffff8240.w
	ENDC

	moveq	#0,d0		; ****** INSTRUMENT *********          
	moveq	#0,d1
	
	move.l	$0(a5),d7	; Sample start
	beq.s	.channel_off	; Channel off?
	move.l	d7,a0		; A0=Sample start
	move.l	$a(a5),a3	; Sample restart
	move.w	$4(a5),d0	; Sample length 
	bne.s	.over

	moveq	#-1,d0		;**************************<<<<<<
	move.w	$10(a5),d0	; Get old sample len ( -ve )
	move.w	$12(a5),d1	; Get old sample len ( -ve )
	bra.s	.cont
		
.over	add.l	d0,d0		;
	add.l	d0,a0		; Sample End
	neg.l	d0		; Sample length ( -ve )
	move.w	#0,$4(a5)	; Signal voice playing....
	move.l	a0,$0(a5)	; SAVE!
.cont
	moveq	#0,d4
	move.w	$e(a5),d4	; Sample repeat length ( Hi )
	add.l	d4,d4		;
	add.l	d4,a3		; Sample RestartEnd
	neg.l	d4		; Sample Repeatlength ( -ve )

	lea	frq,a4		; ******** PERIOD *********
	move.w	$6(a5),d7	; Note
	add.w	d7,d7
	add.w	d7,d7		; x4
	move.w	(a4,d7.w),d2	; Frequency Constant ( Hi )
	move.w	2(a4,d7.w),d3	; Frequency Constant ( Lo )

	lea	volume,a4	; ******** VOLUME **********
	move.w	$8(a5),d7	; Volume
	lsl.w	#8,d7		; x 256
	lea	(a4,d7.w),a4	; a4 = volume table

	bsr	make_buf	; Do Rendering

	move.w	d0,$10(a5)	; 
	move.w	d1,$12(a5)	; 

	rts

;
; Channel off. Just fill channel with silence!
;
.channel_off
	move.w	#49,d7		; Loop counter
	moveq	#0,d0
.make_loop
	move.w	d0,(a2)+
	move.w	d0,(a2)+
	move.w	d0,(a2)+
	move.w	d0,(a2)+
	move.w	d0,(a2)+
	dbf	d7,.make_loop
	move.w	d0,(a2)+
	rts

;---------------------------------------------------------------------------
; Calculate one voice
;
; D0 D1 : Sample count
; D2 D3 : Frq const
; D4    : Repeat sample
; 
; A0 = Sample data
; A1 = :
; A2 = Output
; A3 = Sample restart data
; A4 = Volume table
; A5 = CHIP
; A6 = VOICE
;
;---------------------------------------------------------------------------
make_buf
	move.w	#49,d7		; Loop counter
make_loop
	add.w	d3,d1		; Lo - Lo
	addx.w	d2,d0		; Hi - Hi + X
	bcs.s	l0		; Sample finished?
ret_0	move.b	(a0,d0.l),d6	; Get sample
	move.b	(a4,d6.w),d6	; Scale through Volume table
	ext.w	d6
	move.w	d6,(a2)+	; Store in buffer

	add.w	d3,d1		; Lo - Lo
	addx.w	d2,d0		; Hi - Hi + X
	bcs.s	l1		; Sample finished?
ret_1	move.b	(a0,d0.l),d6	; Get sample
	move.b	(a4,d6.w),d6	; Scale through Volume table
	ext.w	d6
	move.w	d6,(a2)+	; Store in buffer

	add.w	d3,d1		; Lo - Lo
	addx.w	d2,d0		; Hi - Hi + X
	bcs.s	l2		; Sample finished?
ret_2	move.b	(a0,d0.l),d6	; Get sample
	move.b	(a4,d6.w),d6	; Scale through Volume table
	ext.w	d6
	move.w	d6,(a2)+	; Store in buffer

	add.w	d3,d1		; Lo - Lo
	addx.w	d2,d0		; Hi - Hi + X
	bcs.s	l3		; Sample finished?
ret_3	move.b	(a0,d0.l),d6	; Get sample
	ext.w	d6		; EXTend
	move.b	(a4,d6.w),d6	; Scale through Volume table
	ext.w	d6
	move.w	d6,(a2)+	; Store in buffer

	add.w	d3,d1		; Lo - Lo
	addx.w	d2,d0		; Hi - Hi + X
	bcs.s	l4		; Sample finished?
ret_4	move.b	(a0,d0.l),d6	; Get sample
	move.b	(a4,d6.w),d6	; Scale through Volume table
	ext.w	d6
	move.w	d6,(a2)+	; Store in buffer

	dbf	d7,make_loop

	add.w	d3,d1		; Lo - Lo
	addx.w	d2,d0		; Hi - Hi + X
	bcs.s	l5		; Sample finished?
ret_5	move.b	(a0,d0.l),d6	; Get sample
	move.b	(a4,d6.w),d6	; Scale through Volume table
	ext.w	d6
	move.w	d6,(a2)+	; Store in buffer

	rts	

l0	moveq	#0,d1	; Repeat value
	move.w	d4,d0	; Sample repeat value
	beq.s	ll0
	move.l	a3,a0	
	bra	ret_0	
ll0	moveq	#0,d2
	moveq	#0,d3
	bra	ret_0
	
l1	moveq	#0,d1	; Repeat value
	move.w	d4,d0	; Sample repeat value
	beq.s	ll1
	move.l	a3,a0	
	bra	ret_1	
ll1	moveq	#0,d2
	moveq	#0,d3
	bra	ret_1

l2	moveq	#0,d1	; Repeat value
	move.w	d4,d0	; Sample repeat value
	beq.s	ll2
	move.l	a3,a0	
	bra	ret_2	
ll2	moveq	#0,d2
	moveq	#0,d3
	bra	ret_2

l3	moveq	#0,d1	; Repeat value
	move.w	d4,d0	; Sample repeat value
	beq.s	ll3
	move.l	a3,a0	
	bra	ret_3	
ll3	moveq	#0,d2
	moveq	#0,d3
	bra	ret_3

l4	moveq	#0,d1	; Repeat value
	move.w	d4,d0	; Sample repeat value
	beq.s	ll4
	move.l	a3,a0	
	bra	ret_4	
ll4	moveq	#0,d2
	moveq	#0,d3
	bra	ret_4

l5	moveq	#0,d1	; Repeat value
	move.w	d4,d0	; Sample repeat value
	beq.s	ll5
	move.l	a3,a0	
	bra	ret_5	
ll5	moveq	#0,d2
	moveq	#0,d3
	bra	ret_5


	
;===========================================================================
;===========================================================================
mix_voices
	lea	construct_1,a0	
	lea	construct_2,a1
	lea	construct_3,a2
	lea	construct_4,a3
	move.l	use_buff,a4	
	move.w	#49,d7
.loop
	rept	5
	move.w	(a0)+,d0	; Ch0
	add.w	(a3)+,d0	; Ch3
	asr.w	#1,d0		; /2
	move.b	d0,(a4)+	; Store LEFT channel
	move.w	(a1)+,d0	; Ch1
	add.w	(a2)+,d0	; Ch2
	asr.w	#1,d0		; /2
	move.b	d0,(a4)+	; Store RIGHT channel
	endr
	dbf	d7,.loop
	move.w	(a0)+,d0	; Ch0
	add.w	(a3)+,d0	; Ch3
	asr.w	#1,d0		; /2
	move.b	d0,(a4)+	; Store LEFT channel
	move.w	(a1)+,d0	; Ch1
	add.w	(a2)+,d0	; Ch2
	asr.w	#1,d0		; /2
	move.b	d0,(a4)+	; Store RIGHT channel
	rts


;----------------------------------------------------------------------------
; Set Buffers
;----------------------------------------------------------------------------
set_buffers
	move.w	#0,$ffff8900.w	; DMA Sound off

	move.l	buff_2,use_buff
	
.over	move.l	buff_1,d4	; Get buffer
	move.l	d4,d5
	move.w	d4,$ffff8906.w	; Set start addr
	lsr.w	#8,d4
	move.w	d4,$ffff8904.w
	swap	d4
	move.w	d4,$ffff8902.w
	add.l	#502,d5
	move.w	d5,$ffff8912.w	; Set end addr
	lsr.w	#8,d5
	move.w	d5,$ffff8910.w
	swap	d5
	move.w	d5,$ffff890e.w
	
	move.w	#1,$ffff8900.w	; DMA sound on
	move.l	buff_1,d0	; Swap buffers
	move.l	buff_2,buff_1
	move.l	d0,buff_2
	rts

	
;===========================================================================
;===========================================================================
stop_music
	move.w	#0,$ffff8900.w	; DMA Sound off
	rts

;===========================================================================
;===========================================================================
start_music	
	move.l	#buffer_1,buff_1	; Set sample buffers
	move.l	#buffer_2,buff_2
	move.b	#7,$ffff8800.w	; Yamaha soundchip off!
	move.b	#$ff,$ffff8802.w
	move.w	#1,$ffff8920.w	; STEREO mode & 6258 Hz

	lea	track_saves,a0
	move.l	#off,d0
	moveq	#0,d1
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	move.l	d0,(a0)+
	move.l	d1,(a0)+


	move.w	#0,$ffff8900.w	; DMA sound on
	rts

;===========================================================================
;===========================================================================

off	ds.l	5

construct_1	ds.w	512
construct_2	ds.w	512
construct_3	ds.w	512
construct_4	ds.w	512

volume	incbin	volume3.bin

frq	incbin	12_khz.frq	; Frequency Table
	
buffer_1	ds.b	1024	; Sample buffer 
buffer_2	ds.b	1024	; Sample buffer

buff_1		ds.l	1
buff_2		ds.l	1
use_buff	ds.l	1

track_saves	ds.l	10	

mt_data		ds.l	1

	end



