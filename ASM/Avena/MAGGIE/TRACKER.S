; Non SSI tracker player for the Maggie 18 intro
;
;
;
;


start_tracker:
	jsr	tracker_player+0
	tst.l	d0
	bmi	error
	lea	module,a0
	jsr	tracker_player+4
	jsr	tracker_player+8
	rts

stop_tracker
	jsr	tracker_player+12
	jsr	tracker_player+16
	rts

; *---------------------------------*
; *|                               |*
; *| New Protracker Player Routine |*
; *| Tat/Digital_Chaos January '95 |*
; *|                               |*
; *---------------------------------*
; Non-SSI DSP Version for Useless Demo
; 13. Mai '95




cia	equ	1				;allow CIA timing

tracker_player
	bra.w	track_initialize_soundsystem	; x+0
	bra.w	track_initialize_module		; x+4, a0 = moduleaddr
	bra.w	track_initialize_interrupts	; x+8
	bra.w	track_stop_interrupts		; x+12
	bra.w	track_stop_soundsystem		; x+16

;---------------------------------------------------------------------
; All routines return in d0:
; 0   - if all OK
; -xx - if error

;---------------------------------------------------------------------
track_initialize_soundsystem:
	move.w	#128,-(a7)		;xbios 128, locksnd
	trap	#14
	addq.l	#2,a7
	;tst.w	d0
	;bmi	track_error		;ignore whether it's locked

; UnConnect the multiplexer:
	move.w	#1,-(a7)		;protocol (No Handshake)
	move.w	#3,-(a7)		;prescale (3 = 25Khz)
	move.w	#0,-(a7)		;srcclk   (0 = 25.175 int.)
	move.w	#%1000,-(a7)		;dst      (8 = DAC)
	move.w	#0,-(a7)		;src      (1 = DMA-Play)
	move.w	#139,-(a7)		;xbios 139, devconnect
	trap	#14
	lea	12(a7),a7

; Set 8-Bit Stereo:
; (Seems to make no difference)
	move.w	#0,-(a7)		;8 bit stereo
	move.w	#132,-(a7)		;xbios 132, setmode
	trap	#14
	addq.l	#4,a7

; Set the DSP-Transmit off:
	move.w	#0,-(a7)		;DSP-Rec: off
	move.w	#0,-(a7)		;DSP-Xmit: off
	move.w	#137,-(a7)		;xbios 137, dsptristate
	trap	#14
	addq.l	#6,a7

; Set 25 Khz
	move.w	#2,-(a7)		;prescale = 3, 25KHz
	move.w	#6,-(a7)		;cmd 6, prescale
	move.w	#130,-(a7)		;xbios 130, soundcmd
	trap	#14
	addq.l	#6,a7

; Install Dsp Routine:
	bsr	track_init_dsp

track_ok:
	moveq	#0,d0
track_error:
	rts

;---------------------------------------------------------------------
track_initialize_module:
	pea	(a0)
	lea	track_1_data,a0
	bsr	clear_tracks
	lea	track_2_data,a0
	bsr	clear_tracks
	lea	track_3_data,a0
	bsr	clear_tracks
	lea	track_4_data,a0
	bsr	clear_tracks

	move.l	(a7)+,a6
	bsr	pt_InitMusic		;Initialize the Mod
	bsr	pt_PlayMusic
	bsr	track_set_tempo
	rts

clear_tracks
	clr.l	(a0)+
	clr.w	(a0)+
	clr.w	(a0)+
	clr.w	(a0)+
	clr.l	(a0)+
	clr.w	(a0)+
	rts

;---------------------------------------------------------------------
track_initialize_interrupts
	lea	track_save_interrupts,a0
	move.l	$134.w,(a0)+
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa19.w,(a0)+
	move.b	$fffffa1f.w,(a0)+

	bsr	track_set_tempo
	move.b	#%00001100,$ffff8900.w	;set timer-A at record/play end
	move.b	#%00000011,$ffff8901.w	;set play buffer, dmaplay on


	 lea	track_vbl(pc),a0
	 move.l	a0,$134.w
	 clr.b	$fffffa19.w
	 move.b	#1,$fffffa1f.w
	 move.b	#8,$fffffa19.w
	 bclr	#3,$fffffa17.w
	 bset	#5,$fffffa07.w
	 bset	#5,$fffffa13.w
	rts

;---------------------------------------------------------------------
track_stop_interrupts:
	lea	track_save_interrupts,a0
	move.l	(a0)+,$134.w
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa19.w
	move.b	(a0)+,$fffffa1f.w
	clr.w	$ffff8900.w
	rts

;---------------------------------------------------------------------
track_stop_soundsystem:
        move.w	#1,-(a7)
        move.w	#0,-(a7)
        move.w	#0,-(a7)
        move.w	#8,-(a7)		; Dac....
        move.w	#0,-(a7)		; ...connected to nothing
        move.w	#139,-(a7)
        trap	#14
        lea	12(a7),a7

; Set the DSP-Transmit off:
	move.w	#0,-(a7)		;DSP-Rec: off
	move.w	#0,-(a7)		;DSP-Xmit: off
	move.w	#137,-(a7)		;xbios 137, dsptristate
	trap	#14
	addq.l	#6,a7

	move.w	#129,-(a7)
	trap	#14
	addq.l	#2,a7
	bra	track_ok		;even an error is ok


;---------------------------------------------------------------------
track_init_dsp:
	jsr	Dsp_Library
	rts

;---------------------------------------------------------------------
;
;	Main VBL-Routine
;
;---------------------------------------------------------------------
track_vbl:
	movem.l	d0-a6,-(a7)
	move.b	#$93,$ffffa201.w
.waitcom:
	btst	#7,$ffffa201.w
	bne.s	.waitcom

	bsr	track_wait_transmit
	move.l	TempoCount,$ffffa204.w
	move.l	TempoCount,ReceiveCount
	lea	$ffffa200.w,a6
	bsr	track_set_tempo
	bsr	track_wait_receive
	move.l	$ffffa204.w,d0		; d0 should be 'TAT'
	moveq	#0,d0
	lea	track_1_data(pc),a0
	bsr	track_send_to_dsp
	moveq	#1,d0
	lea	track_2_data(pc),a0
	bsr	track_send_to_dsp
	moveq	#2,d0
	lea	track_3_data(pc),a0
	bsr	track_send_to_dsp
	moveq	#3,d0
	lea	track_4_data(pc),a0
	bsr	track_send_to_dsp
	bsr	pt_PlayMusic
	bsr	track_receive_data

.wait_ok:
	bsr	track_wait_receive
	move.l	$ffffa204.w,d0
	cmp.w	#"OK",d0
	bne.s	.wait_ok

	bsr	track_wait_transmit
	move.l	#"BIZ",$ffffa204.w
.wait_ready:
	btst	#2,$fffffa202.w
	beq.s	.wait_ready

	movem.l	(a7)+,d0-a6
	rte

;---------------------------------------------------------------------
track_save_interrupts:
	ds.b	4+6
	even

Master_Volume
	dc.w	60000			;WORD!

;---------------------------------------------------------------------
track_send_to_dsp:
	bsr	track_wait_receive
	move.l	4(a6),d6		;jump from last time
	and.w	#$fffe,d6
	ext.l	d6
	move.l	SamAddress(a0),a3

	move.w	DFF096,d1
	btst	d0,d1
	beq.s	.silent_sample		;We don't need to move
	st	PseudoAddr(a0)
	tas	SamAddress(a0)		;neat!
	beq	.new_sample

	add.l	d6,a3
	asr.l	d6			;this works in WORDS
	moveq	#0,d1
	move.w	SamLength(a0),d1
	sub.l	d6,d1
	bpl.s	.no_repeat

	moveq	#0,d2
	move.w	PseudoLoop(a0),d2
	beq.s	.stop_repeat
	cmp.w	#1,d2			;no repeating?
	beq.s	.stop_repeat

	move.l	PseudoAddr(a0),a3
	neg.l	d1
	divu	d2,d1			;d1 = [(overrun) MOD (pseudoloop)]
	swap 	d1			;the remainder
	ext.l	d1
	sub.l	d1,d2
	lea	(a3,d1.w*2),a3
	move.l	d2,d1			;a bit messy?
; Now offset the sample pointer:
	bra.s	.set_repeat

; Sample stops after this.... set everything to 'silence'
.stop_repeat:
.silent_sample:
	move.w	#1,d1
	move.l	PseudoAddr(a0),a3
	move.w	d1,PseudoLoop(a0)
.set_repeat:
.no_repeat:
	move.l	a3,SamAddress(a0)
	move.w	d1,SamLength(a0)

.new_sample
	move.w	SamVolume(a0),d0	
	mulu.w	Master_Volume,d0
	bsr	track_wait_transmit
	move.l	d0,4(a6)		;transmit, volume

	moveq	#0,d0
	moveq	#0,d2
	move.w	SamPeriod(a0),d0
	cmp.w	#107,d0
	blt.s	.skip_divide
	move.l	#610685544,d2		;for 49170Hz
	divu.l	d0,d2
.skip_divide:
	bsr	track_wait_transmit
	move.l	d2,4(a6)

	bsr	track_wait_receive
	move.l	4(a6),d0
	move.w	d0,d3
	asr.w	#2,d0			;sloppy coding ??
	addq.w	#3,d0			;safety
	move.w	d0,d2
	bsr	track_wait_transmit
	move.l	d0,4(a6)
	lea	6(a6),a5
	tst.l	d2
	ble	track_no_transmit
	move.w	SamLength(a0),d3
	cmp.w	d3,d2
	blt	track_send_normal
	cmp.w	#1,PseudoLoop(a0)
	ble	track_send_silent_end
	move.w	PseudoLoop(a0),d3
; ...otherwise we do the loop:
; when we get to the end, 
	move.w	SamLength(a0),d0	;starting no to copy (till end)
.sendloop2:
	move	d0,d4			;number of bytes done
	bsr	track_send_d0_words	;send them
	sub.w	d4,d2			;dec number of bytes done
	move.l	PseudoAddr(a0),a3	;to start of loop
	cmp.w	d3,d2
	ble	.home_stretch		;do last bit
	move.w	d3,d0			;replength
	bra	.sendloop2		;
.home_stretch
	move.w	d2,d0
	bsr	track_send_d0_words	;all done!
track_no_transmit
	rts

;---------------------------------------------------------------------
track_send_silent_end:
; send last bit of sample:

	move.w	SamLength(a0),d0
	sub.w	d0,d2
	bsr	track_send_d0_words
; ....then send silence

	move.l	PseudoAddr(a0),a3
	move.w	d2,d0
	subq.w	#1,d0
	bmi	.dont_send
.sendloop:
	move.w	(a3),(a5)
	dbf	d0,.sendloop
.dont_send
	rts

;---------------------------------------------------------------------
; 'optimizing' not really worth it
track_send_d0_words
track_send_normal:
	subq.w	#1,d0
	bmi	.dont_send
.sendloop:
	move.w	(a3)+,(a5)
	dbf	d0,.sendloop
.dont_send
	rts

;---------------------------------------------------------------------
track_wait_receive:
	btst	#0,$ffffa202.w
	beq.s	track_wait_receive
	rts
track_wait_transmit:
	btst	#1,$ffffa202.w
	beq.s	track_wait_transmit
	rts
;---------------------------------------------------------------------
track_receive_data:
	move.l	ReceiveCount,d0
	subq.w	#1,d0
	bmi.s	.dont_rec

	move.l	dummy_buffers,a0
	lea	$ffffa206.w,a3
	bsr	track_wait_receive
.rec:	move.w	(a3),(a0)+
	dbf	d0,.rec
.dont_rec:
	rts
;---------------------------------------------------------------------

track_dummy_sample:
	dcb.w	30,$00

	include	f:\source\track\pt3\pt3_int.s

;---------------------------------------------------------------------
track_set_tempo:
	bclr	#7,$ffff8901.w		;set play registers
	movem.l	dummy_buffers,d0-d1
	exg.l	d0,d1
	movem.l	d0-d1,dummy_buffers

	moveq	#0,d1
	move.w	RealTempo(pc),d1
	lea	mycia_list(pc),a0
	move.w	(a0,d1.w*2),d1

	asr.w	#1,d1			;original values are for 50Khz!
	move.l	d1,TempoCount

	lsl.l	#1,d1			;8 bit, stereo --> *2
	add.l	d0,d1
; Set frame start:
	move.b	d0,$ffff8907.w
	lsr.l	#8,d0
	move.b	d0,$ffff8905.w
	lsr.l	#8,d0
	move.b	d0,$ffff8903.w
; Set frame end:
	move.b	d1,$ffff8913.w
	lsr.l	#8,d1
	move.b	d1,$ffff8911.w
	lsr.l	#8,d1
	move.b	d1,$ffff890f.w
	rts

TempoCount	dc.l	10
ReceiveCount	dc.l	10
dummy_buffers	dc.l	dummy_buffer1
		dc.l	dummy_buffer2

mycia_list	include	cia_list.s
		even

Dsp_Library	include	new_os.s
		cnop	0,4

;---------------------------------------------------------------------
		section	bss
dummy_buffer1	ds.l	400
dummy_buffer2	ds.l	400

		section	data
Dsp_Routine:
		incbin	f:\dsp_new\lod\new_os2.dsb

		even
; NOTE: I have lost my copy of this module. Those wishing
;  for a runnable version should insert their own module here.

module:		;incbin	maggie.mod
		even