

; ArtOfNoiseTracker Falcon test
; SSI 50Khz, full stereo version
; v1.0



	section	text

	CLR.L	-(A7)
	MOVE.W	#$20,-(A7)
	TRAP	#1
	addq.l	#6,a7
	
	lea	mod,a6
	moveq	#$00,d0			; Startpos
	jsr	playerstart+0

	move.w	#8,-(a7)
	trap	#1
	addq.l	#2,a7

	jsr	playerstart+4
	clr.w	-(a7)
	trap	#1
















; AON_TEST.S
; ArtOfNoiseTracker Falcon test
; v1.0

;####################################################################
	SECTION	text
PLAYERSTART
; Jumptable
	bra	aonfalc_start		; + 0 initialize
	bra	aonfalc_stop		; + 4 switch off
	bra	aonfalc_nop		; + 8 ?
	bra	aon8_play		; +12 vbl player

aonfalc_start
	move.l	a6,a0
	bsr	aon_init

	lea	aon_data(pc),a6

	move.b	#125,aon_tempo(a6)
	move.w	#0,aon_patcnt(a6)
	lea	mix_data(pc),a6
	move.w	#$0000,(mix_datasize*0)+mix_falcstereo(a6)
	move.w	#$7fff,(mix_datasize*1)+mix_falcstereo(a6)
	move.w	#$7fff,(mix_datasize*2)+mix_falcstereo(a6)
	move.w	#$0000,(mix_datasize*3)+mix_falcstereo(a6)
	move.w	#$1800,(mix_datasize*4)+mix_falcstereo(a6)
	move.w	#$6800,(mix_datasize*5)+mix_falcstereo(a6)
	move.w	#$4800,(mix_datasize*6)+mix_falcstereo(a6)
	move.w	#$3800,(mix_datasize*7)+mix_falcstereo(a6)
	bsr	aonfalc_set_tempo
	bsr	aonfalc_kill_samples

	bsr	aonfalc_start_soundsystem
	bsr	aonfalc_start_interrupts
	rts


aonfalc_stop
	bsr	aonfalc_stop_soundsystem
	bsr	aonfalc_stop_interrupts
	rts




aonfalc_start_interrupts:
	lea	aonfalc_save_interrupts(pc),a0
	move.l	$134.w,(a0)+
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa19.w,(a0)+
	move.b	$fffffa1f.w,(a0)+

	lea	aonfalc_vbl(pc),a0
	move.l	a0,$134.w
	clr.b	$fffffa19.w
	move.b	#1,$fffffa1f.w
	move.b	#8,$fffffa19.w
	bclr	#3,$fffffa17.w

	bset	#5,$fffffa07.w
	bset	#5,$fffffa13.w
	move.b	#%00001100,$ffff8900.w	;set timer-A at record/play end
	move.b	#%10110000,$ffff8901.w
	rts


aonfalc_stop_interrupts:
	lea	aonfalc_save_interrupts(pc),a0
	move.l	(a0)+,$134.w
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa19.w
	move.b	(a0)+,$fffffa1f.w
	clr.w	$ffff8900.w
	rts


aonfalc_save_interrupts:
	dcb.b	20,0
	even


aonfalc_start_soundsystem:
	move.w	#128,-(a7)		;xbios 128, locksnd
	trap	#14
	addq.l	#2,a7
	tst.w	d0
	bmi	aonfalc_error

	move.w	#1,-(a7)		;protocol (No Handshake)
	move.w	#1,-(a7)		;prescale (1 = 49170 Hz)
	move.w	#0,-(a7)		;srcclk   (0 = 25.175 int.)
	move.w	#%1001,-(a7)		;dst      (8 = DAC, 1 = DMAREC)
	move.w	#1,-(a7)		;src      (1 = DSP-Transmit)
	move.w	#139,-(a7)		;xbios 139, devconnect
	trap	#14
	lea	12(a7),a7

	move.w	#1,-(a7)		;16 bit stereo
	move.w	#132,-(a7)		;xbios 132, setmode
	trap	#14
	addq.l	#4,a7

	move.w	#0,-(a7)		;DSP-Rec: off
	move.w	#1,-(a7)		;DSP-Xmit: on
	move.w	#137,-(a7)		;xbios 137, dsptristate
	trap	#14
	addq.l	#6,a7

	bsr	aonfalc_init_dsp
aonfalc_ok:
	moveq	#0,d0
aonfalc_error:
	rts

aonfalc_stop_soundsystem:
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
	bra	aonfalc_ok		;even an error is ok


;---------------------------------------------------------------------
aonfalc_init_dsp:
	move.w	#1,-(a7)		;ability
	pea	(511).w			;codesize
	pea	dsp_routine(pc)		;codeptr
	move.w	#110,-(a7)		;xbios 110, Dsp_ExecBoot
	trap	#14
	lea	12(a7),a7
	bsr	aonfalc_wait_receive
	move.l	$ffffa204.w,d0
	rts

;---------------------------------------------------------------------
aonfalc_wait_receive:
	btst	#0,$ffffa202.w
	beq.s	aonfalc_wait_receive
	rts
aonfalc_wait_transmit:
	btst	#1,$ffffa202.w
	beq.s	aonfalc_wait_transmit
	rts
;---------------------------------------------------------------------




;---------------------------------------------------------------------
aonfalc_set_tempo:
	bset	#7,$ffff8901.w		;set record register
	lea.l	dummy_buffer,a0
	move.l	a0,d0
	moveq	#0,d1

	lea	AON_DATA(PC),a6
	moveq	#0,d1
	move.b	aon_tempo(a6),d1
	lea	mycia_list(pc),a0
	move.w	(a0,d1.w*2),d1
	lsl.l	#2,d1
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

aonfalc_mix_dsp:
	movem.l	d0-a6,-(a7)
	move.b	#$93,$ffffa201.w
.waitcom: btst	#7,$ffffa201.w
	bne.s	.waitcom

	movec	cacr,d0
	move.l	d0,-(a7)
	lea	$ffffa200.w,a6

	bsr	aonfalc_wait_transmit
	move.l	#"TAT",4(a6)
	bsr	aonfalc_wait_receive
	move.l	4(a6),d0
	bsr	aonfalc_wait_transmit

	lea	aon_data,a0
	moveq	#0,d7
	move.w	aon_trackcount(a0),d7
	move.l	d7,4(a6)

	subq.w	#1,d7
	lea	mix_data(pc),a0
.mix_loop:
	  movem.l d7/a0,-(a7)
	  bsr	aonfalc_send_to_dsp
	  movem.l (a7)+,d7/a0
	  lea	mix_datasize(a0),a0
	dbf	d7,.mix_loop

	move.l	(a7)+,d0
	movec	d0,cacr

	movem.l	(a7)+,d0-a6
	rts

;---------------------------------------------------------------------
aon_save_interrupts:
	ds.b	4+6
	even

Master_Volume
	dc.l	31000*4

;---------------------------------------------------------------------
aonfalc_send_to_dsp:
	bsr	aonfalc_wait_receive
	move.l	4(a6),d6		;jump from last time (in bytes)
	and.w	#$fffe,d6
	ext.l	d6

	move.w	mix_falcvolume(a0),d7
	move.l	mix_waveoff(a0),d0
	move.l	mix_wavestart(a0),a3
	moveq	#0,d5
	move.w	mix_period(a0),d5

	tst.b	mix_status(a0)
	beq.s	.sample_off

	add.l	d6,d0			;weiter
	move.l	d0,mix_waveoff(a0)	;speichern
	cmp.l	mix_wavelen(a0),d0
	ble.s	.no_loop

	move.l	mix_replen(a0),d2	;Sampleende erreicht
	cmp.l	#2,d2			;wiederholen
	ble.s	.stop_repeat
	tst.w	d2
	beq.s	.stop_repeat

	sub.l	mix_wavelen(a0),d0	;muss +ve sein. Ueberschritt (Bytes)

	move.l	mix_repstrt(a0),a3
	move.l	mix_replen(a0),d2
	move.l	a3,mix_wavestart(a0)
	move.l	d2,mix_wavelen(a0)

; Calc new mix_waveoff:
; Needs a fix for samples>65K:
	cmp.l	#$10000,d2
	bge.s	.repfix
.repfix_done:
	divu	d2,d0			;d0 = [(overrun) MOD (replen)]
	eor.w	d0,d0
	swap 	d0			;the remainder
	move.l	d0,mix_waveoff(a0)
	bra.s	.loop_done

.repfix_sub:
	sub.l	d2,d0
.repfix:
	cmp.l	d2,d0
	bgt.s	.repfix_sub
	bra.s	.repfix_done


.stop_repeat:
	move.l	mix_repstrt(a0),mix_wavestart(a0)
	move.l	mix_replen(a0),mix_wavelen(a0)
	clr.l	mix_waveoff(a0)
.sample_off:
	lea	aonfalc_dummy_sample(pc),a3
	moveq	#0,d7			;volume 0
	moveq	#0,d5			;period 0
	moveq	#0,d0
	bra.s	.dont_add

.no_loop:
.loop_done:
	add.l	d0,a3
.dont_add:
	move.w	#$7fff,d2
	move.w	mix_falcstereo(a0),d1
	sub.w	d1,d2
	muls.w	d7,d1
	muls.w	d7,d2
	swap	d1
	swap	d2
	ext.l	d1
	ext.l	d2
	muls.l	Master_Volume,d1
	muls.l	Master_Volume,d2
	bsr	aonfalc_wait_transmit
	move.l	d2,4(a6)		;transmit, volume 1
	bsr	aonfalc_wait_transmit
	move.l	d1,4(a6)		;transmit, volume 2

	moveq	#0,d2
	cmp.w	#103,d5
	ble.s	.skip_divide
	move.l	#610685544,d2		;for 49170Hz
	divu.l	d5,d2
.skip_divide:
	bsr	aonfalc_wait_transmit
	move.l	d2,4(a6)

	moveq	#0,d2
	move.b	mix_floatflag(a0),d2
	clr.b	mix_floatflag(a0)
	bsr	aonfalc_wait_transmit
	move.l	d2,4(a6)

	bsr	aonfalc_wait_receive
	move.w	6(a6),d0
	ext.l	d0
	move.l	d0,d3
	asr.l	#2,d0			;sloppy coding ??
	addq.l	#3,d0			;safety
	move.l	d0,d2
	bsr	aonfalc_wait_transmit
	move.l	d0,4(a6)
	lea	6(a6),a5
	tst.l	d2
	ble	aonfalc_no_transmit

; OK now actually send d2 *words* to dsp
	move.l	mix_wavelen(a0),d3
	sub.l	mix_waveoff(a0),d3
	asr.l	d3

	cmp.l	d3,d2
	ble	aonfalc_send_normal

	cmp.l	#2,mix_replen(a0)
	ble	aonfalc_send_silent_end

	move.l	mix_replen(a0),d3
	asr.l	d3

	move.l	mix_wavelen(a0),d0
	sub.l	mix_waveoff(a0),d0
	asr.l	d0
.sendloop2:
	move.l	d0,d4			;number of bytes done
	bsr	aonfalc_send_d0_words	;send them
	sub.l	d4,d2			;dec number of bytes done

	move.l	mix_repstrt(a0),a3	;to start of loop
	cmp.l	d3,d2
	ble	.home_stretch		;do last bit
	move.l	d3,d0			;replength
	bra	.sendloop2		;
.home_stretch
	move.l	d2,d0
	bsr	aonfalc_send_d0_words	;all done!
aonfalc_no_transmit
	rts

;---------------------------------------------------------------------
aonfalc_send_silent_end:
; send last bit of sample:

	move.l	mix_wavelen(a0),d0
	sub.l	mix_waveoff(a0),d0
	asr.l	d0

	sub.l	d0,d2
	bsr	aonfalc_send_d0_words

	move.l	mix_repstrt(a0),a3
	move.l	d2,d0
	subq.l	#1,d0
	bmi	.dont_send
.sendloop:
	move.w	(a3),(a5)
	dbf	d0,.sendloop
.dont_send
	rts

;---------------------------------------------------------------------
; This 'optimizing' not really worth it
aonfalc_send_d0_words
aonfalc_send_normal:
	tst.w	d0
	beq	.dont_send
	move.w	d0,d1
	and.w	#%1111,d1
	neg.w	d1
	lsr.w	#4,d0
	jmp	.send2(pc,d1.w*2)
.sendloop:
	rept	16
	move.w	(a3)+,(a5)
	endr
.send2	dbf	d0,.sendloop
.dont_send
	rts


mycia_list:	include	cialist2.s
		even

































	include	aon_int.s

;========================================================================


;========================================================================
aonfalc_vbl:
	;move.w	#$2500,sr
	bsr	aon8_playcia
	;bclr	#5,$fffffa0f.w		;in-service. Man weiss nie...
	rte

aon8_playcia:
	movem.l	d0-a6,-(sp)
	bsr	aonfalc_set_tempo	;[addition]
	bsr	aonfalc_mix_dsp		;[addition] must come					; after mix_startsamples

	bsr	aon8_play
	lea	mix_bypass(pc),a0
	lea	aon_data,a6
	move.w	aon_trackcount(a6),d7
	subq.w	#1,d7
	bsr	mix_startsamples

	movem.l	(sp)+,d0-a6
	rts

;========================================================================
aonfalc_nop:
	rts



aonfalc_kill_samples:
	lea	mix_data(pc),a0
	lea	aonfalc_dummy_sample(pc),a1
	moveq	#2,d2

	moveq	#8-1,d7
.kill:	move.l	a1,mix_wavestart(a0)
	move.l	a1,mix_repstrt(a0)
	move.l	d2,mix_wavelen(a0)
	move.l	d2,mix_replen(a0)
	move.b	#1,mix_floatflag(a0)
	clr.w	mix_falcvolume(a0)
	clr.w	mix_period(a0)
	lea	mix_datasize(a0),a0
	dbf	d7,.kill
	rts


;--------------------------------------------------------------------
; IN:	a0=bypass-ch
;	d7=anzahl kanäle [minus 1] (bis zu 8 !)

; Ought to optimize this really

mix_startsamples
	moveq	#0,d6
.loop
	moveq	#0,d4
	move	6(a0),d4	; period
	moveq	#0,d5
	move.b	9(a0),d5	; volume
	cmp	#$40,d5
	ble.b	.volok
	moveq	#$40,d5
.volok	move.l	(a0),d0		; samplestart
	moveq	#0,d1
	move	4(a0),d1	; sampledmalen
	add.l	d1,d1		; *2 für bytes
	move.l	10(a0),d2	; repeatstart
	moveq	#0,d3
	move	14(a0),d3	; repeatdmalen
	add.l	d3,d3		; *2 für bytes
	bsr	mix_startsample
.nonewsample
	lea	$10(a0),a0
	addq	#1,d6
	dbf	d7,.loop
	rts

;--------------------------------------------------------------------
; IN:	d0=wavestart
;	d1=wavelen
;	d2=repoff
;	d3=replen
;	d4=period
;	d5=volume
;	d6=channel (0-7)
mix_startsample
	movem.l	d0-a6,-(sp)
	lea	mix_data,a1
	mulu	#mix_datasize,d6
	lea	(a1,d6),a1

	btst	#1,8(a0)
	beq.b	.repeat

	*clr	mix_lastfloat(a1)	;only DSP problem!
	st	mix_floatflag(a1)
	move.b	#1,mix_status(a1)
	move.l	d0,mix_wavestart(a1)
	clr.l	mix_waveoff(a1)
	move.l	d1,mix_wavelen(a1)
.repeat	btst	#0,8(a0)
	beq.b	.norepeat

	move.l	d2,mix_repstrt(a1)
	move.l	d3,mix_replen(a1)

.norepeat
	move.w	d5,mix_falcvolume(a1)

	tst	d4
	beq.b	.noper
	move	d4,mix_period(a1)
.noper	clr.b	8(a0)
	movem.l	(sp)+,d0-a6
	rts


;--------------------------------------------------------------------
;--------------------------------------------------------------------
;--------------------------------------------------------------------
;mix_buff1		dc.l	0	; diese Buffer werden gerade berechnet
;mix_buff2		dc.l	0
;mix_buff3		dc.l	0
;mix_buff4		dc.l	0
;mix_buff1hear		dc.l	0	; diese Buffer werden gerade angehört
;mix_buff2hear		dc.l	0
;mix_buff3hear		dc.l	0
;mix_buff4hear		dc.l	0

;mix_multab64		ds.b	256*65
;mix_mixrate		ds	1	; Period

mix_DATA:

	rsreset
mix_wavestart		rs.l	1
mix_waveoff		rs.l	1
mix_wavelen		rs.l	1
mix_repstrt		rs.l	1
mix_replen		rs.l	1
mix_period		rs.w	1
*mix_period.float	rs.w	1	umgerechnet auf mixrate/addx trick-add
;			float-cnt
;			$ffff= period  125
;			$8000= ...     250
;			$4000= ...     500
;			$2000= ...    1000

*mix_norm.add		rs.w	1
*mix_cnt			rs.w	1
*mix_lastfloat		rs.w	1
mix_status		rs.b	1+1	0=Ch off , 1=Ch plays
*mix_volumeptr		rs.l	1

;Falc Additions:
mix_falcstereo		rs.w	1
mix_falcvolume		rs.w	1
mix_floatflag		rs.w	1


mix_datasize		rs.w	1
			ds.b	mix_datasize*8

mix_bypass		ds.b	$10*8
;--------------------------------------------------------------------


;--------------------------------------------------------------------


;########################################################################
;buffers	ds.b	4*128+60

Dsp_Routine:	incbin	f:\dsp_new\lod\ssi_aon2.dsb
		even
aonfalc_dummy_sample
		dcb.w	100,$0

		section bss
dummy_buffer	ds.l 49170/50*2




;----------------------------------------------------------------------

		section	data
mod
		incbin	e:\tommy\ein.aon
		even

		section	bss
		ds.l	1000
stack:
