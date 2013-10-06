; Non-SSI AON player for demos
;
; Original Amiga: Bastian Spiegel
; Falcon version: Steve Tattersall.
;
; Completely unoptimised. Please laugh at my code!
;










;---------------------------------------------------------------------

tracks_to_play	equ	4	; keep at 4 unless DSP program changed!
cia		equ	1	; 1 = allows CIA timing
hertz		equ	1	; 1 = 25, 2 = 33


;---------------------------------------------------------------------
tracker_player
	bra.w	aonfalc_initialize_soundsystem	; x+0
	bra.w	aonfalc_initialize_module	; x+4, a0 = moduleaddr,
						;      d0 = start pattern

	bra.w	aonfalc_initialize_interrupts	; x+8
	bra.w	aonfalc_stop_interrupts		; x+12
	bra.w	aonfalc_stop_soundsystem	; x+16


;---------------------------------------------------------------------

;start_tracker:
stop_tracker
	jsr	tracker_player+12
	jsr	tracker_player+16
	rts


;--------------------------- Macros ---------------------------
wait_transmit	macro
	btst	#1,$ffffa202.w
	beq.s	*-6
	endm

wait_receive	macro
	btst	#0,$ffffa202.w
	beq.s	*-6
	endm




;---------------------------------------------------------------------
aonfalc_initialize_soundsystem:

	bsr	aonfalc_init_dsp

	move.w	#1,-(a7)		;protocol (No Handshake)
	ifeq	hertz-2
	  move.w #2,-(a7)		;prescale (2 = 32Khz)
	else
	  move.w #3,-(a7)
	endc
	move.w	#0,-(a7)		;srcclk   (0 = 25.175 int.)
	move.w	#%1000,-(a7)		;dst      (8 = DAC)
	move.w	#0,-(a7)		;src      (1 = DMA-Play)
	move.w	#139,-(a7)		;xbios 139, devconnect
	trap	#14
	lea	12(a7),a7

	move.w	#0,-(a7)		;8 bit stereo
	move.w	#132,-(a7)		;xbios 132, setmode
	trap	#14
	addq.l	#4,a7

	move.w	#0,-(a7)		;DSP-Rec: off
	move.w	#0,-(a7)		;DSP-Xmit: off
	move.w	#137,-(a7)		;xbios 137, dsptristate
	trap	#14
	addq.l	#6,a7

	move.w	#2,-(a7)		;prescale = 3, 25KHz
	move.w	#6,-(a7)		;cmd 6, prescale
	move.w	#130,-(a7)		;xbios 130, soundcmd
	trap	#14
	addq.l	#6,a7

	;bsr	aonfalc_init_dsp

aonfalc_ok:
	moveq	#0,d0
aonfalc_error:
	rts

;---------------------------------------------------------------------
aonfalc_initialize_module:
	bsr	aon_init

	lea	aon_data(pc),a6
	move.b	#125,aon_tempo(a6)
	move.w	#0,aon_patcnt(a6)
	bsr	aon8_play
	bsr	aon8_playfx
	bsr	aon8_play_part2
	bsr	aonfalc_set_tempo

	lea	mix_bypass(pc),a0
	lea	aon_data,a6
	move.w	aon_trackcount(a6),d7
	subq.w	#1,d7
	bsr	mix_startsamples
	rts

;---------------------------------------------------------------------
aonfalc_initialize_interrupts
	lea	aonfalc_save_interrupts,a0
	move.l	$134.w,(a0)+
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa19.w,(a0)+
	move.b	$fffffa1f.w,(a0)+

	move.b	#%00001100,$ffff8900.w	;set timer-A at record/play end
	move.b	#%00000011,$ffff8901.w	;set play buffer, dmaplay on

	 lea	aonfalc_vbl(pc),a0
	 move.l	a0,$134.w
	 clr.b	$fffffa19.w
	 move.b	#1,$fffffa1f.w
	 move.b	#8,$fffffa19.w
	 bclr	#3,$fffffa17.w
	 bset	#5,$fffffa07.w
	 bset	#5,$fffffa13.w
	rts

;---------------------------------------------------------------------
aonfalc_stop_interrupts:
	lea	aonfalc_save_interrupts,a0
	move.l	(a0)+,$134.w
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa19.w
	move.b	(a0)+,$fffffa1f.w
	rts

;---------------------------------------------------------------------
aonfalc_stop_soundsystem:
	clr.w	$ffff8900.w
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
	jsr	Dsp_Library
	rts

;---------------------------------------------------------------------
;
;	Main VBL-Routine
;
;---------------------------------------------------------------------
aonfalc_vbl:
	movem.l	d0-a6,-(a7)

	move.b	#$80+$13,$ffffa201.w

.pending:
	btst	#7,$ffffa201.w		; wait till command pending
	bne.s	.pending		; is cleared
.pending2:
	btst	#2,$ffffa202.w		; wait until xfr pending bit
	beq.s	.pending2		; is cleared, before
					; we try to send any data
	bsr	Save_Host_Internals

	move.w	#$2500,sr


.wait	bsr	aonfalc_wait_receive
	move.l	$ffffa204.w,d0		; d0 should be 'TAT'
	cmp.l	#"TAT",d0
	bne.s	.wait


	bsr	aonfalc_wait_transmit
	move.l	TempoCount,$ffffa204.w
	move.l	TempoCount,ReceiveCount
	bsr	aonfalc_set_tempo

;aonfalc_mix_dsp:
	lea	mix_data+mix_datasize*0(pc),a0
	bsr	aonfalc_send_to_dsp
	lea	aon_channels+aon_chdatasize*0(pc),a4	; do effect command
	 jsr	aon_dofx(pc)

	lea	mix_data+mix_datasize*1(pc),a0
	bsr	aonfalc_send_to_dsp
	lea	aon_channels+aon_chdatasize*1(pc),a4	; do effect command
	 jsr	aon_dofx(pc)

	lea	mix_data+mix_datasize*2(pc),a0
	bsr	aonfalc_send_to_dsp
	lea	aon_channels+aon_chdatasize*2(pc),a4	; do effect command
	 jsr	aon_dofx(pc)

	lea	mix_data+mix_datasize*3(pc),a0
	bsr	aonfalc_send_to_dsp
	lea	aon_channels+aon_chdatasize*3(pc),a4	; do effect command
	 jsr	aon_dofx(pc)

; Do the interpreter:
	lea	aon_data(pc),a6
	bsr	aon8_play_part2

; Get mixed sample
	bsr	aonfalc_receive_data			;Endsample kriegen

	bsr	Restore_Host_Internals

skip_aonfalc_play:
	bsr	aon8_play
; Update Paula registers:
	lea	mix_bypass(pc),a0
	lea	aon_data,a6
	move.w	aon_trackcount(a6),d7
	subq.w	#1,d7
	bsr	mix_startsamples

	movem.l	(a7)+,d0-a6
	rte

;---------------------------------------------------------------------
aonfalc_send_to_dsp:
	lea	$ffffa200.w,a6
	lea	4(a6),a4
._1	btst	#0,$ffffa202.w
	beq.s	._1

	move.w	6(a6),d6		;jump from last time (in bytes)
	and.w	#$fffe,d6
	ext.l	d6

	moveq	#0,d7
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
	blt.s	.no_loop

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
	muls.l	Master_Volume,d7
	move.l	d7,(a4)			;transmit, volume 1

	moveq	#0,d2
	cmp.w	#103,d5
	blt.s	.skip_divide

	ifeq	hertz-2
	  move.l #458014158,d2		;for 2*32780Hz
	else
	  move.l #610685504,d2		;for 25Khz
	endc
	divu.l	d5,d2
.skip_divide:
	;bsr	aonfalc_wait_transmit
	move.l	d2,(a4)
	bsr	aonfalc_wait_receive
	move.l	(a4),d0
	ext.l	d0
	move.l	d0,d3
	asr.l	#2,d0			;sloppy coding
	addq.l	#3,d0			;safety
	move.l	d0,d2

	;bsr	aonfalc_wait_transmit
	move.l	d0,(a4)
	lea	6(a6),a5
	tst.l	d2
	ble	aonfalc_no_transmit

; OK now actually send d2 *words* to dsp
	move.l	mix_wavelen(a0),d3
	sub.l	mix_waveoff(a0),d3
	asr.l	d3

	cmp.l	d3,d2
	blt	aonfalc_send_normal

	cmp.l	#2,mix_replen(a0)
	ble	aonfalc_send_silent_end

	move.l	mix_replen(a0),d3
	asr	d3
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
; This 'optimizing' not really worth it
aonfalc_send_it:
aonfalc_send_normal:
aonfalc_send_d0_words:
	tst.w	d0
	beq	.dont_fetch
	move.w	d0,d1
	and.w	#%11111,d1
	neg.w	d1
	asr.w	#5,d0
	jmp	(.fetch2,pc,d1.w*2)
.fetchloop:
	rept	32
	move.w	(a3)+,(a5)
	endr
.fetch2:dbf	d0,.fetchloop

.dont_fetch:
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
aonfalc_wait_receive:
	btst	#0,$ffffa202.w
	beq.s	aonfalc_wait_receive
	rts
aonfalc_wait_transmit:
	btst	#1,$ffffa202.w
	beq.s	aonfalc_wait_transmit
	rts



;---------------------------------------------------------------------
aonfalc_receive_data:
	bsr	aonfalc_wait_receive
	move.l	ReceiveCount,d0
	move.l	dummy_buffers(pc),a0
	lea	$ffffa206.w,a3
	tst.w	d0
	beq	.dont_fetch
	move.w	d0,d1
	and.w	#%11111,d1
	neg.w	d1
	asr.w	#5,d0
	jmp	.fetch2(pc,d1.w*2)
.fetchloop:
	rept	32
	move.w	(a3),(a0)+
	endr
.fetch2:dbf	d0,.fetchloop
.dont_fetch:
	rts
;---------------------------------------------------------------------








;---------------------------------------------------------------------
aonfalc_set_tempo:
	bclr	#7,$ffff8901.w		;set play registers
	movem.l	dummy_buffers,d0-d1
	exg.l	d0,d1
	movem.l	d0-d1,dummy_buffers

	moveq	#0,d1
	lea	aon_data(pc),a6
	move.b	aon_tempo(a6),d1
	lea	mycia_list(pc),a0
	move.w	(a0,d1.w*2),d1
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






;---------------------------------------------------------------------
	include	protect.s














;---------------------------------------------------------------------
aon_save_interrupts:
	ds.b	4+6
	even

Master_Volume
	ds.l	1
























;--------------------------------------------------------------------
; IN:	a0=bypass-ch
;	d7=anzahl kanaele [minus 1] (bis zu 8 !)

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
	st	mix_trigger(a1)
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
.noper
	move.b	8(a0),d0		;mine
	or.b	d0,mix_trigger(a1)	;mine
	clr.b	8(a0)
	movem.l	(sp)+,d0-a6
	rts


;--------------------------------------------------------------------
;--------------------------------------------------------------------
;--------------------------------------------------------------------


;--------------------------------------------------------------------

; ## AON-INCLUDES ##

aon.songinfo_mfver	=0
aon.songinfo_maxpos	=1
aon.songinfo_respos	=2

aon.instrtypeSample8bit	=0
aon.instrtypeSynth1	=1

			rsreset
instr_control		rs.b	1	; Instr-Type (check out aon.instrtypexxxxx)
instr_volume		rs.b	1	; volume 0-64
instr_finetune		rs.b	1	; finetune -7 to 7  bits 4-7 are unused
instr_waveform		rs.b	1	; waveform 0-63

; Sample 8 bit
			rsset	4
sample8_dmaoffset	rs.l	1	; Sampleoffset/2 (words)
sample8_dmalen		rs.l	1	; Samplelen/2 (words)
sample8_dmarepoffset	rs.l	1	; Repeatstrt/2 (words)
sample8_dmareplen	rs.l	1	; Repeatlen/2 (words)

; Wavetable 8 bit
			rsset	4
synth8_partwaveDmaLen	rs.b	1	; in words (--> up to 512 bytes)
	rs.b	1	; Unused
	rs.b	1
	rs.b	1
	rs.b	1
	rs.b	1

synth8_VIBpara		rs.b	1	; the same param. like with effect '4'
synth8_vibdelay		rs.b	1	; framecnt
synth8_vibwave		rs.b	1	; sine,triangle,rectangle
synth8_WAVEspd		rs.b	1	; framecnt
synth8_WAVElen		rs.b	1
synth8_WAVErep		rs.b	1
synth8_WAVEreplen	rs.b	1
synth8_WAVErepCtrl	rs.b	1	; 0=Repeatnormal/1=Backwards/1=PingPong

			rsset	32-4
instr_Astart		rs.b	1	; Vol_startlevel
instr_Aadd		rs.b	1	; Zeit bis maximalLevel
instr_Aend		rs.b	1	; Vol_endlevel
instr_Asub		rs.b	1	; Zeit bis endlevel


;--------------------------------------------------------------------

;========================================================================
; IN:	d0=Startpos
;	a0=Moduleadr
; OUT:	d0= result (0=ok,-1=error occured)
AON_INIT
	movem.l	d1-d7/a0-a6,-(sp)
	move.l	d0,-(a7)

	lea	aon_channels,a4
	move	#aon_chdatasize*2-1,d7
.clrch	clr.l	(a4)+
	dbf	d7,.clrch

	move.l	(a0),d0
	move.b	d0,d1
	lsr.l	#8,d0
	cmp.l	#"AON",d0
	bne	aon_notinitalized

	bsr	aonfalc_set_tracks

	move.l	(a7)+,d0
	lea	aon_data(pc),a6
	move.b	#6,aon_speed(a6)
	clr.b	aon_framecnt(a6)
	move.b	d0,aon_pos(a6)

	move.l	a0,aon_modulestart(a6)
	move.l	#"INFO",d0
	bsr	aon_searchchunk
	move.l	a1,aon_statdata(a6)

	move.l	#"NAME",d0
	bsr	aon_searchchunk
	move.l	a1,aon_namedata(a6)
	move.l	#"AUTH",d0
	bsr	aon_searchchunk
	move.l	a1,aon_authdata(a6)
	move.l	#"DATE",d0
	bsr	aon_searchchunk
	move.l	a1,aon_datedata(a6)	;all additions!

	move.l	#"ARPG",d0
	bsr.w	aon_searchchunk
	move.l	a1,aon_arpdata(a6)
	move.l	#"PLST",d0
	bsr.w	aon_searchchunk
	move.l	a1,aon_posdata(a6)
	move.l	#"PATT",d0
	bsr.w	aon_searchchunk
	move.l	a1,aon_pattdata(a6)

	move.l	#"INST",d0
	bsr.w	aon_searchchunk

	lea	aon_instrstarts(a6),a2
	moveq	#61-1,d7
aon_initinstradrtab
	move.l	a1,(a2)+
	lea	32(a1),a1
	dbf	d7,aon_initinstradrtab

	move.l	#"WLEN",d0
	bsr.w	aon_searchchunk
	move.l	a1,a3			; a3=ptr on wlen-tab
	move.l	#"WAVE",d0
	bsr.w	aon_searchchunk		; a1=ptr on wave-adr0
	lea	aon_wavestarts(a6),a2
	move.l	a1,d0
	moveq	#64-1,d7
aon_initwavetab
	move.l	d0,(a2)+
	add.l	(a3)+,d0
	dbf	d7,aon_initwavetab

	lea	aon_channels+aon_trackvol(pc),a0
	moveq	#64,d0
	move	d0,aon_chdatasize*0(a0)
	move	d0,aon_chdatasize*1(a0)
	move	d0,aon_chdatasize*2(a0)
	move	d0,aon_chdatasize*3(a0)
	move	d0,aon_chdatasize*4(a0)
	move	d0,aon_chdatasize*5(a0)
	move	d0,aon_chdatasize*6(a0)
	move	d0,aon_chdatasize*7(a0)

	movem.l	(sp)+,d1-d7/a0-a6
	moveq	#0,d0
	rts

aon_searchchunk
	move.l	a0,a1
.search	cmp.l	(a1),d0
	beq.b	.ok
	addq.l	#2,a1
	bra.b	.search
.ok	addq.l	#8,a1
	rts


AON_NOTINITALIZED
	movem.l	(sp)+,d1-d7/a0-a6
	moveq	#-1,d0		; yep,seems that an error
	rts			; has occured... bad luck..!

; a6=data
; get new step ...!
AON_GETDACHANNEL
	move.b	2(a0),aon_fxCOM(a4)	; needed l8r on
	and.b	#$3f,aon_fxcom(a4)
	move	2(a0),d0
	and	#$3fff,d0
	move.b	d0,d1
	move.b	d0,aon_fxDAT(a4)
	cmp.b	#$d,aon_fxcom(a4)
	bne.b	.nobreak
	cmp.b	#$100-4,aon_patcnt+1(a6)
	bne.b	.nobreak
	move.b	#$100-8,aon_patcnt+1(a6)
.nobreak

	and.b	#$f0,d0
	and.b	#$0f,d1

	clr.b	aon_stepfxcnt(a4)

	cmp.b	#16,aon_fxcom(a4)	; 'g' volset
	bne.b	.novoldel
	move.b	aon_fxdat(a4),d2
	and.b	#$f,d2
	move.b	d2,aon_stepfxcnt(a4)
	bra.b	aon_gdc_nomoreFX
.novoldel
	cmp	#$0ec0,d0
	bne.s	aon_gdc_nonotecut	; note cut ?
	move.b	d1,aon_stepfxcnt(a4)
	bra.b	aon_gdc_nomoreFX
aon_gdc_nonotecut
	cmp	#$0ee0,d0		; pattern delay?
	bne.s	aon_gdc_nopatdelay
	tst.b	aon_patdelaycnt+1(a6)	; delaying ?
	bpl.s	aon_gdc_nopatdelay
	move.b	d1,aon_patdelaycnt+1(a6) ; start delay!
	bra.b	aon_gdc_nomoreFX
aon_gdc_nopatdelay
	cmp	#$0e60,d0		; pattern loop?
	bne.s	aon_gdc_noloopreset
	cmp.b	#$f0,aon_loopcnt(a6)	; loop over flag set ?
	beq.s	aon_gdc_noloopreset
	tst.b	d1			; no loop?
	beq.s	aon_gdc_noloopreset

	tst.b	aon_loopcnt(a6)
	bne.s	aon_gdc_dothatloopin
	move.b	d1,aon_loopcnt(a6)	; write counter
aon_gdc_dothatloopin
	subq.b	#1,aon_loopcnt(a6)	; continue looping!
	bne.s	aon_gdc_notjustlooped
	move.b	#$f0,aon_loopcnt(a6)	; loop over flag
aon_gdc_notjustlooped
	move.b	#-1,aon_loopflag(a6)
aon_gdc_noloopreset
aon_gdc_nomoreFX
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d5			; flag for useoldinstr
	move.b	1(a0),d1		; Get Instrnr.
	and.b	#%00111111,d1		; skip unused bits
	subq.b	#1,d1
	bpl.s	aon_gdc_notoldinstr	; -1-> old instr
	tst.l	aon_instrptr(a4)	; get last instrptr
	beq	aon_gdc_nonewnote	; no instrument ?!!
					; then exit
	move.l	aon_instrptr(a4),a2	; last instrptr
	move.b	(a0),d2
	and.b	#63,d2			; no note?
	beq	aon_gdc_nonewinstr	; then pause !
	moveq	#1,d5			; flag for useoldinstr
	cmp.b	#3,aon_fxcom(a4)
	beq	aon_gdc_nonewinstr
	cmp.b	#5,aon_fxcom(a4)
	beq	aon_gdc_nonewinstr
	cmp.b	#27,aon_fxcom(a4)
	beq	aon_gdc_nonewinstr
	cmp.b	#28,aon_fxcom(a4)
	beq	aon_gdc_nonewinstr
	bra.b	aon_gdc_useoldinstr
aon_gdc_notoldinstr
	move.b	(a0),d2
	and.b	#63,d2			; no note?
	bne.s	aon_gdc_notchangerepeat	; then only set repeat

	add.b	d1,d1
	add.b	d1,d1
	lea	aon_instrstarts(a6),a2
	move.l	(a2,d1),a2

	tst.b	instr_control(a2)
	bne.w	aon_gdc_resetvolume.etc	;aon_gdc_notsameinstr

	cmp.l	aon_instrptr(a4),a2
	beq	aon_gdc_resetvolume.etc
	move.l	a2,aon_instrptr(a4)	; save in channeldata
	move.b	#01,aon_chflag(a4)	; 01=NEW REPEATWAVE
	bra.w	aon_startrepeat
aon_gdc_notchangerepeat
	clr.l	aon_oldsampoff(a4)

	add.b	d1,d1
	add.b	d1,d1
	lea	aon_instrstarts(a6),a2
	move.l	(a2,d1),a2

	cmp.l	aon_instrptr(a4),a2
	bne.s	aon_gdc_notsameinstr
	cmp.b	#3,aon_fxcom(a4)
	beq	aon_gdc_resetvolume.etc
	cmp.b	#5,aon_fxcom(a4)
	beq	aon_gdc_resetvolume.etc
	cmp.b	#27,aon_fxcom(a4)
	beq	aon_gdc_resetvolume.etc
	cmp.b	#28,aon_fxcom(a4)
	beq	aon_gdc_resetvolume.etc
aon_gdc_notsameinstr
	move.l	a2,aon_instrptr(a4)	; save in channeldata
aon_gdc_useoldinstr

	clr.b	aon_vibCONT(a4)
	bsr	aon_initADSR

	tst.b	instr_control(a2)	; Synthmode on??
	beq	aon_startsample

; ---- INIT SYNTHETIC INSTRUMENT ---------------	16-juli-1994
aon_gdc_initsynth
	move.b	#1,aon_chMODE(a4)

	move	aon_fxcom(a4),d0
	move.b	d0,d1
	and.b	#$f0,d0

	cmp	#$0e90,d0		; retrig note?
	bne.s	.noretrigging
	and.b	#$0f,d1
	move.b	d1,aon_stepfxcnt(a4)
.noretrigging

	lea	aon_wavestarts(a6),a3

	move.b	(a0),d2			; Alter Fehler: Bei
	and.b	#63,d2			; Wechsel des Instr.
	beq	aon_gdc_resetvolume.etc	; wurde «perslide» re-
	clr	aon_perslide(a4)	; settet!

	moveq	#0,d3
	cmp.b	#17,aon_fxcom(a4)	; 'h'  synthcontrol?!
	bne.b	.noth
	move.b	aon_fxdat(a4),d3
.noth
	btst	#4,d3
	bne	.initvib

	cmp	#$0ed0,d0		; delay note?
	bne.s	.notdelaynote
	and.b	#$0f,d1
	move.b	d1,aon_stepfxcnt(a4)
	bra.b	.startrepeat
.notdelaynote
	move.b	#3,aon_chflag(a4)	; 3=New WAVE
.startrepeat

	moveq	#0,d0
	move.b	instr_waveform(a2),d0	; Nr. of waveform
	move.b	d0,aon_actwavenr(a4)
	add	d0,d0
	add	d0,d0			; *4 (longword!)
	move.l	(a3,d0.l),d1		; Get address..
; d1=Address of actual waveform
	cmp.l	aon_waveform(a4),d1
	bne.b	.notsamewaveU
	clr.b	aon_chflag(a4)

	tst.b	aon_synthWAVECONT(a4)	; Wave
	bne	.initVIB		; NICHT resetten!!

.notsamewaveU
	move.l	d1,aon_waveform(a4)

.checkoffset
	moveq	#0,d0
	move.b	synth8_partwaveDMALen(a2),d0

	cmp.b	#9,aon_fxcom(a4)
	bne.b	.notoffset
	moveq	#0,d2
	move.b	aon_fxdat(a4),d2
	mulu	d0,d2
	add.l	d1,d2
	move.l	d2,d1
;aon_synthwaveactptr(a4)
	tst.b	aon_synthWAVESTOP(a4)
	beq.b	.notoffset
	move.l	d1,aon_synthwaveactptr(a4)
	move.l	d1,aon_repeatstrt(a4)
	bra	.initVIB
.notoffset
	tst.b	aon_synthWAVESTOP(a4)
	bne.b	.initVIB

	move.l	d1,aon_synthwaveactptr(a4)


	move	aon_wavelen(a4),aon_oldwavelen(a4)

	move	d0,aon_wavelen(a4)
	move	d0,aon_replen(a4)

	add	d0,d0
	move.l	d0,aon_synthWAVEaddbytes(a4)

	moveq	#0,d2
	move.b	synth8_WAVErep(a2),d2
	mulu	d0,d2
	add.l	d1,d2
	move.l	d2,aon_repeatstrt(a4)

	moveq	#0,d2
	move.b	synth8_WAVElen(a2),d2
	mulu	d0,d2
	add.l	d1,d2
	move.l	d2,aon_synthWAVEendptr(a4)

	moveq	#0,d2
	move.b	synth8_WAVErep(a2),d2
	mulu	d0,d2
	add.l	d1,d2
	move.l	d2,aon_synthWAVErepptr(a4)

	moveq	#0,d2
	move.b	synth8_WAVEreplen(a2),d2
	add.b	synth8_WAVErep(a2),d2
	mulu	d0,d2
	add.l	d1,d2
	move.l	d2,aon_synthWAVErependptr(a4)

	move.b	synth8_WAVEspd(a2),aon_synthWAVEcnt(a4)
	move.b	synth8_WAVEspd(a2),aon_synthWAVEspd(a4)
	move.b	synth8_WAVErepctrl(a2),aon_synthWAVERepctrl(a4)


; Vibrato initalisieren
.initvib
;	btst	#0,d3	; Restart
;	beq.b	.vibke	; Volume
;	clr.b	aon_synthENV(a4)	; Envelope ?!?
;.vibke
	clr.b	aon_vibON(a4)
	cmp.b	#3,synth8_vibwave(a2)	; 'Off' ?!
	beq.b	.vibOFF

	moveq	#0,d1
	move.b	synth8_vibdelay(a2),d1
	move	d1,aon_vibratotrigdelay(a4)
	moveq	#0,d1
	move.b	synth8_vibpara(a2),d1
	bne.b	.vib
	move	#-2,aon_vibratotrigdelay(a4)
	bra.b	.novib
.vib	move.l	a2,-(sp)
	bsr	aon_dofx_vibratoPARAM	; set parameters
	move.l	(sp)+,a2
	move.b	synth8_vibwave(a2),d0
	ror.b	#3,d0
	and.b	#%10011111,aon_vibratoampl(a4)
	or.b	d0,aon_vibratoampl(a4)
	move.b	#1,aon_vibCONT(a4)
	
.novib
	bra	aon_gdc_resetvolume.etc
.vibOFF	move.b	#"!",aon_vibon(a4)
	bra	aon_gdc_resetvolume.etc

; --------------------- INIT SAMPLE8BIT INSTRUMENT ----------------------
aon_startsample

	move.b	#"!",aon_vibON(a4)
	clr.b	aon_chMODE(a4)
	move	aon_fxcom(a4),d0
	move.b	d0,d1
	and.b	#$f0,d0

	cmp	#$0ed0,d0		; delay note?
	bne.s	aon_gdc_notdelaynote
	and.b	#$0f,d1
	move.b	d1,aon_stepfxcnt(a4)
	bra.b	aon_startrepeat
aon_gdc_notdelaynote
	cmp	#$0e90,d0		; retrig note?
	bne.s	aon_gdc_noretrigging
	and.b	#$0f,d1
	move.b	d1,aon_stepfxcnt(a4)
aon_gdc_noretrigging
	move.b	#03,aon_chflag(a4)	; 03=New SAMPLEWAVE
aon_startrepeat
	lea	aon_wavestarts(a6),a3

;	cmp.b	#$3,aon_fxcom(a4)
;	beq.w	.resetper
;		cmp.b	#$5,aon_fxcom(a4)
;		bne.b	.noresetper
;.resetper
	move.b	(a0),d2			; Alter Fehler: Bei
	and.b	#63,d2			; Wechsel des Instr.
	beq.b	.noresetper		; wurde «perslide» re-
	clr	aon_perslide(a4)	; settet!
.noresetper	

	moveq	#0,d0
	move.b	instr_waveform(a2),d0	; Nr. of waveform
	move.b	d0,aon_actwavenr(a4)
	add	d0,d0
	add	d0,d0			; *4 (longword!)
	move.l	(a3,d0.l),d1		; Get address..
; d1=Address of actual waveform

	move.l	sample8_dmalen(a2),d4
	move	aon_wavelen(a4),aon_oldwavelen(a4)
	move	d4,aon_wavelen(a4)

	tst.l	sample8_dmareplen(a2)	; Is there any repeat?!
	bne.b	sample8_TheresARepeat
	move.l	a2,-(sp)
	lea	aon_leer(pc),a2
	move.l	a2,aon_repeatstrt(a4)
	move.l	(sp)+,a2
	move	#1,aon_replen(a4)
	bra.b	sample8_theresNoRepeat
sample8_theresARepeat

	move.l	sample8_dmarepoffset(a2),d2

	tst.b	aon_oversize(a6)
	bne.b	sample8_notzerorep
	tst.l	d2
	bne.b	sample8_NotzeroRep	; sonst sind keine
					; samples >128k möglich
	move.l	d1,aon_repeatstrt(a4)	;!!!!!!!!!!!!!!!!
	move	sample8_dmareplen+2(a2),aon_replen(a4)
	bra.b	sample8_zeroRep
sample8_NotzeroRep
	move.l	d2,d3			; save repeatstart in WORDS
	add.l	d2,d2
	add.l	d1,d2
	move.l	d2,aon_repeatstrt(a4)
	moveq	#0,d2
	move	sample8_dmareplen+2(a2),d2 ; get repeatlen
	move	d2,aon_replen(a4)	; replen in WORDS

	tst.b	aon_oversize(a6)
	bne.b	sample8_zerorep
	add	d3,d2			; replen+repstart=wavelen
	move	d2,aon_wavelen(a4)

sample8_zeroRep
sample8_theresNorepeat
	move.l	sample8_dmaoffset(a2),d2
	add.l	d2,d2	; get bytesize!

	move.l	aon_oldsampoff(a4),d4
	lsr.l	#1,d4
	sub	d4,aon_wavelen(a4)	; offset from last com

	cmp.b	#9,aon_fxcom(a4)	; effect 'SAMPOFF'
	bne.s	aon_gdc_nonewsampoff	; no ??

	moveq	#0,d3
	move.b	aon_fxdat(a4),d3	; get offset
	lsl	#8,d3			; ->*256

	move.l	d3,d4
	lsr.l	#1,d4
	sub	d4,aon_wavelen(a4)
	bpl.s	aon_gdc_usesampoff
	move.l	aon_repeatstrt(a4),aon_waveform(a4)
	move	aon_replen(a4),aon_wavelen(a4)
	bra.b	aon_gdc_offendofsample
aon_gdc_usesampoff
	add.l	d3,aon_oldsampoff(a4)
aon_gdc_nonewsampoff	
	add.l	d1,d2			; Realstart of wave
	add.l	aon_oldsampoff(a4),d2	; add offset
	move.l	d2,aon_waveform(a4)
aon_gdc_offendofsample
aon_gdc_resetvolume.etc

	tst.b	d5
	bne.s	aon_gdc_nonewinstr
	move.b	instr_volume(a2),aon_volume(a4)
; -----------------------------------

aon_gdc_nonewinstr

	moveq	#0,d0
	move.b	(a0),d0	; Get note
	and.b	#%00111111,d0
	bne.s	aon_gdc_notefound	; 0=Pause

	move.b	aon_lastnote(a4),d0	; Use last note!
	beq	aon_gdc_nonewnote
	cmp	#60,d0
	bgt	aon_gdc_nonewnote	; >B-3? -->pause!!!
	bra.b	aon_gdc_getarpeggio	; no instr retrig!!

aon_gdc_notefound	
	clr.b	aon_slideflag(a4)
	move.b	d0,aon_lastnote(a4)
	cmp	#60,d0
	bgt	aon_gdc_nonewnote	; >B-3? -->pause!!!

aon_gdc_getarpeggio
	move.l	aon_arpdata(a6),a3
	moveq	#0,d2
	moveq	#0,d3
	move.b	2(a0),d2
	move.b	1(a0),d3
	and.b	#%11000000,d2		; upper
	and.b	#%11000000,d3		; and lower 2 bits
	rol.b	#6,d2			; of arp.nr to use
	rol.b	#4,d3
	or.b	d2,d3			; *4 (4bytes/arp)

	lea	(a3,d3.l),a3		; get pointer on arpdat

	moveq	#0,d2
	move.b	instr_finetune(a2),d2	; get da finetune!!
	add	d2,d2
	move	(a5,d2.l),d2		; *120 (pertabsize)

	subq.b	#1,d0			; skip 'pause' mark
	add	d0,d0
	add	d0,d2			; offset in pertab

	cmp.b	#27,aon_fxcom(a4)
	beq	aon_arpslide
	cmp.b	#28,aon_fxcom(a4)
	beq	aon_arpslide
	cmp.b	#5,aon_fxcom(a4)
	beq.b	aon_arpslide
	cmp.b	#3,aon_fxcom(a4)
	bne.b	aon_notarpslide
aon_arpslide		move.b	(a0),d0
	and.b	#$3f,d0
	beq.b	aon_notarpslide
	move.b	#1,aon_slideflag(a4)
	lea	aon_periods(pc),a1
	move	(a1,d2.l),d1

	move	aon_period(a4),d0
	add	aon_perslide(a4),d0
	sub	d1,d0			; -actual periode=diff.
	move	d0,aon_perslide(a4)

;;;;;bra	aon_notarpslide

AON_notarpslide
	lea	aon_arpeggiotab(a4),a1
	cmp	#-1,2(a1)		; arpeggio im letzten
	bne.b	aon_NoArpReset		; step aktiv ?!
	clr	aon_arpeggiooff(a4)
	clr.b	aon_arpeggiocnt(a4)
aon_noarpreset
	tst.b	aon_fxcom(a4)
	bne.b	aon_gdc_noproarp
	tst.b	aon_fxdat(a4)
	beq.s	aon_gdc_noproarp
; Protracker-Arpeggio (fxcom=0) auslesen
	moveq	#0,d0
	moveq	#0,d1
	move.b	aon_fxdat(a4),d0
	move.b	d0,d1
	and.b	#$f0,d0
	and.b	#$0f,d1
	lsr.b	#4,d0
	add	d0,d0
	add	d1,d1
	move	d2,(a1)+
	add	d2,d0
	add	d2,d1
	move	d0,(a1)+
	move	d1,(a1)+
	bra.b	aon_gdc_arpend
aon_gdc_noproarp
; Professional arpeggio
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a3)+,d0		; 1.nibble=anzahl arpeggios
	move.b	d0,d1
	lsr.b	#4,d0
	beq.b	aon_gdc_emptyarp	; arp_entry leer?!?!
	and.b	#$f,d1
	add	d1,d1
	add	d2,d1
	move	d1,(a1)+
	subq.b	#1,d0
	beq.b	aon_gdc_arpend
AON_GDC_writearps
	moveq	#0,d1
	moveq	#0,d3
	move.b	(a3)+,d1		; 2 nibbles holen
	move.b	d1,d3
	lsr.b	#4,d1
	and.b	#$f,d3
	add	d1,d1
	add	d3,d3
	add	d2,d1
	move	d1,(a1)+
	subq.b	#1,d0
	beq.b	aon_gdc_arpend
	add	d2,d3
	move	d3,(a1)+
	subq.b	#1,d0
	bne.b	aon_gdc_writearps
aon_gdc_arpend
	move	#-1,(a1)
aon_gdc_nonewnote
	rts
aon_gdc_emptyarp
	clr	aon_arpeggiooff(a4)
	move.b	aon_arpeggiospd(a4),aon_arpeggiocnt(a4)
	subq.b	#1,aon_arpeggiocnt(a4)
	move	d2,(a1)+
	bra.b	aon_gdc_arpend
;========================================================================
; Vol-Envelope initalisieren
;
; Start		0-255
; Add 0-255 bis	255
; Sub 0-255 bis
; End		0-255

;
; a2=Instrumentdata
; a4=Channeldata
aon_initADSR:		
	cmp.b	#17,aon_fxcom(a4)
	bne.b	.notH
	move.b	aon_fxdat(a4),d3
	btst	#0,d3
	bne.b	.exit
.notH
	move.b	instr_Astart(a2),aon_synthVOL(a4)
	move.b	instr_Aadd(a2),d0
	beq.b	.noADSR
	move.b	d0,aon_synthADD(a4)
	move.b	instr_Asub(a2),aon_synthSUB(a4)
	move.b	instr_Aend(a2),aon_synthEND(a4)

	move.b	#1,aon_synthENV(a4)	; Envelope ADD
.exit	rts

.noADSR	move.b	#127,aon_synthVOL(a4)
	clr.b	aon_synthENV(a4)	; Envelope OFF
	rts

;========================================================================
; dont change a1!!!!!!1
; a4=chptr
AON_DOSYNTH
	clr.b	aon_vibDONE(a4)
	tst.b	aon_chflag(a4)
	bne	.exit
	tst.b	aon_chMODE(a4)		; isssees n sample?!
	beq	.exitSMPL
	tst.l	aon_waveform(a4)	; keine wellenform !?!
	beq	.exit

	tst.b	aon_synthwaveSTOP(a4)
	bne.w	.nonewwave

	addq.b	#1,aon_synthWAVEcnt(a4)
	move.b	aon_synthWAVEspd(a4),d0
	cmp.b	aon_synthWAVEcnt(a4),d0	; framecnt
	bgt	.nonewWAVE
	clr.b	aon_synthWAVEcnt(a4)
	move.l	aon_synthWAVEaddbytes(a4),d0
	add.l	d0,aon_synthWAVEactptr(a4)

	tst.l	d0			; partwave wandert nach links?!?!
	bpl.b	.rightloop
	move.l	aon_synthWAVErepptr(a4),d0	; links clippen
	cmp.l	aon_synthWAVEactptr(a4),d0
	ble.b	.notwaveend
	bra.b	.jumprepeat
.rightloop
	move.l	aon_synthWAVEendptr(a4),d0	;rechts clippen
	cmp.l	aon_synthWAVEactptr(a4),d0
	bgt.b	.notwaveend
.jumprepeat
	tst.b	aon_synthWAVERepctrl(a4)
	beq.b	.normalrep
	cmp.b	#1,aon_synthWAVERepctrl(a4)
	beq.b	.backrep

.pingpong
	move.l	aon_synthWAVErependptr(a4),aon_synthWAVEendptr(a4)
	move.l	aon_synthwaveaddbytes(a4),d0
	sub.l	d0,aon_synthWAVEactptr(a4)
	neg.l	d0
	move.l	d0,aon_synthwaveaddbytes(a4)
	bra.b	.notwaveend

.normalrep
	move.l	aon_synthWAVErepptr(a4),aon_synthWAVEactptr(a4)
	move.l	aon_synthWAVErependptr(a4),aon_synthWAVEendptr(a4)
	bra.b	.notwaveend
.backrep
	move.l	aon_synthwaveRependptr(a4),aon_synthwaveActptr(a4)
	move.l	aon_synthwaveaddbytes(a4),d0
	bmi.b	.alreadyNeg
	neg.l	d0
	tst.b	aon_synthWAVESTOP(a4)
	bne.b	.notwaveend
.alreadyNeg
	add.l	d0,aon_synthWAVEactptr(a4)
	move.l	d0,aon_synthwaveaddbytes(a4)
.notwaveend
	move.b	#1,aon_chflag(a4)	; new repoff

;	cmp.b	#9,aon_fxcom(a4)
;	beq.b	.setit
.setit	move.l	aon_synthWAVEactptr(a4),aon_repeatstrt(a4)
.nonewWAVE


.exitSMPL
; DO Envelope

	tst.b	aon_synthENV(a4)
	beq.b	.dovib
	moveq	#0,d0
	move.b	aon_synthVOL(a4),d0
	cmp.b	#1,aon_synthENV(a4)
	bne.b	.decay
	add.b	aon_synthADD(a4),d0
	bpl.b	.newVOL
	moveq	#127,d0
	move.b	#2,aon_synthENV(A4)
	bra.b	.newVOL
.decay	sub.b	aon_synthSUB(a4),d0
	cmp.b	aon_synthEND(a4),d0
	bgt.b	.newVOL
	move.b	aon_synthEND(a4),d0
	clr.b	aon_synthENV(a4)
.newVOL	move.b	d0,aon_synthVOL(a4)


; Vibrato
.dovib
	cmp.b	#"!",aon_vibON(a4)
	beq.b	.vibok
	cmp	#-1,aon_vibratoTRIGdelay(a4)
	bne	.delayvib
	move.b	#1,aon_vibON(a4)
	bra.b	.vibok
.delayvib
	subq	#1,aon_vibratoTRIGdelay(a4)
.vibok

.exit
	cmp.b	#1,aon_vibON(a4)
	bne.b	.VIBoff
	bra	aon_dofx_viboldampl
.VIBoff	rts

;========================================================================
; a4=channelptr
; don't use a1
AON_DOFX
	lea	aon_data(pc),a6

	tst.b	aon_vibCONT(a4)
	bne.b	.dauervibrato
	move.b	#"!",aon_vibON(a4)
.dauervibrato

	addq.b	#1,aon_arpeggiocnt(a4)
	move.b	aon_arpeggiospd(a4),d0	; time for arpeggio
	cmp.b	aon_arpeggiocnt(a4),d0	; tone-change ?!
	bgt.s	aon_dofx_nonewarpval

	clr.b	aon_arpeggiocnt(a4)	; clear counter

aon_dofx_newarpval
	move	aon_arpeggiooff(a4),d1	; offset in tab
	lea	aon_arpeggiotab(a4),a3
	moveq	#0,d7
	move	(a3,d1),d7		; get act. note
	bpl.s	aon_dofx_notarpend
	clr	aon_arpeggiooff(a4)
	bra.b	aon_dofx_newarpval
aon_dofx_notarpend
	lea	aon_periods(pc),a3
	move	(a3,d7.l),d0		; get periode
	move	d0,aon_period(a4)	; store in chdata
	addq.b	#2,aon_arpeggiooff+1(a4) ; next value
	and.b	#$0f,aon_arpeggiooff+1(a4)
aon_dofx_nonewarpval

	lea	aon_doSYNTH(pc),a2
	move.l	a2,-(sp)
;bsr	aon_dosynth

	moveq	#0,d0
	moveq	#0,d1
	move.b	aon_fxdat(a4),d1

	move.b	aon_fxcom(a4),d0
	beq.w	aon_dofx_end

	tst.b	aon_framecnt(a6)
	beq.b	aon_dofx_atonce

	cmp.b	#1,d0
	beq.w	aon_dofx_portamentoup
	cmp.b	#$2,d0
	beq.w	aon_dofx_portamentodown
	cmp.b	#$3,d0
	beq.w	aon_dofx_toneslide
	cmp.b	#$4,d0
	beq	aon_dofx_vibrato
	cmp.b	#$5,d0
	beq	aon_dofx_glissvolumeslide
	cmp.b	#$6,d0
	beq	aon_dofx_vibvolumeslide
	cmp.b	#$a,d0
	beq	aon_dofx_volumeslide
aon_dofx_atonce
	cmp.b	#$b,d0
	beq	aon_dofx_breakto
	cmp.b	#$c,d0
	beq	aon_dofx_setvolume
	cmp.b	#$d,d0
	beq	aon_dofx_breakpat
	cmp.b	#$e,d0
	beq	aon_dofx_ecommands
	cmp.b	#$f,d0
	beq	aon_dofx_setspd
	cmp.b	#16,d0		'g'
	beq	aon_dofx_setvoldel
	cmp.b	#18,d0		'i'
	beq	aon_dofx_setwaveadsrspd
	cmp.b	#19,d0		'j'
	beq	aon_dofx_setarpspd
	cmp.b	#20,d0		'k'
	beq	aon_dofx_vibsetvolume
	cmp.b	#21,d0		'l'
	beq	aon_dofx_portvolslideUP
	cmp.b	#22,d0		'm'
	beq	aon_dofx_portvolslideDOWN
	cmp.b	#23,d0		'n'
	beq	aon_dofx_togglenoiseavoid
	cmp.b	#24,d0		'o'
	beq	aon_dofx_toggleoversize
	cmp.b	#25,d0		'p'
	beq	aon_dofx_fineVOLslidevib
	cmp.b	#26,d0		'q'
	beq	aon_dofx_synthdrums
	cmp.b	#27,d0		'r'
	beq	aon_dofx_setvolumePort
	cmp.b	#28,d0		's'
	beq	aon_dofx_finevolslidePort
	cmp.b	#29,d0		't'
	beq	aon_dofx_settrackvol
	cmp.b	#30,d0		'u'
	beq	aon_dofx_setwavecont
	cmp.b	#33,d0		'x'
	beq	aon_dofx_externalevent
aon_dofx_end
	rts
; --------------------------------------------------------------------
; $1
aon_dofx_portamentoup
	sub	d1,aon_perslide(a4)
	rts
; --------------------------------------------------------------------
; $2
aon_dofx_portamentodown
	add	d1,aon_perslide(a4)
	rts
; --------------------------------------------------------------------
; $3
aon_dofx_toneslide
	tst.b	d1
	beq.b	aon_dofx_toneslideNOW
	move.b	d1,aon_glissspd(a4)
aon_dofx_toneslideNOW
	tst.b	aon_slideflag(a4)
	beq.b	.exit
	move.b	aon_glissspd(a4),d1
	tst	aon_perslide(a4)
	beq.b	aon_dofx_end
	bpl.b	.sub
	add	d1,aon_perslide(a4)
	bmi.b	aon_dofx_end
	clr	aon_perslide(a4)
	rts
.sub	sub	d1,aon_perslide(a4)
	bpl.b	aon_dofx_end
	clr	aon_perslide(a4)
.exit	rts
; --------------------------------------------------------------------
; $4
aon_dofx_vibrato
	move.b	#1,aon_vibON(a4)
aon_dofx_vibratoPARAM
	tst.b	d1
	beq.b	.goon		; Vibrato-Parameter
	move.b	d1,d2		; setzen!!
	and.b	#$f0,d1
	lsr.b	#4,d1
	beq.b	.oldspd
	move.b	d1,aon_vibratospd(a4)
.oldspd	and.b	#$0f,d2
	beq.s	.goon
	and.b	#$f0,aon_vibratoampl(a4)
	or.b	d2,aon_vibratoampl(a4)
.goon	rts

; Einsprung um Vibrato-Effekt zu erzeugen
aon_dofx_viboldampl	
	tst.b	aon_vibdone(a4)	; Nur ·1· Vibrato zur Zeit
	bne.b	aon_dofx_vibnotend
	move.b	#1,aon_vibdone(a4)

	moveq	#0,d2
	move.b	aon_vibratoampl(a4),d2
	and.b	#%01100000,d2
	beq.s	aon_dofx_vibSINE
	cmp.b	#32,d2
	beq.s	aon_dofx_vibRAMPDOWN
	lea	aon_vibrato_square(pc),a2
	bra.b	aon_dofx_vibSQUARE
aon_dofx_vibRAMPDOWN
	lea	aon_vibrato_rampdown(pc),a2
	bra.b	aon_dofx_vibsquare
aon_dofx_vibSINE
	lea	aon_vibrato_sine(pc),a2
aon_dofx_vibSQUARE
	move.b	aon_vibratopos(a4),d2
	moveq	#0,d0

	move.b	(a2,d2),d2		; vibrato-value
	move.b	aon_vibratoampl(a4),d0
	and.b	#$f,d0
	mulu	d0,d2			; *vibrato amplitude
	lsr	#7,d2

	move	aon_period(a4),d0	; period (smaller)

	btst	#7,aon_vibratoampl(a4)	; negativ ?
	beq.s	aon_dofx_vibpositiv
	sub	d2,d0
	bra.b	aon_dofx_vibnegativ
aon_dofx_vibpositiv
	add	d2,d0
aon_dofx_vibnegativ
	move	d0,aon_period(a4)

	move.b	aon_vibratospd(a4),d0
	add.b	d0,aon_vibratopos(a4)
	btst	#5,aon_vibratopos(a4)
	beq.s	aon_dofx_vibnotend
	and.b	#$1f,aon_vibratopos(a4)
	bchg	#7,aon_vibratoampl(a4)	; toggle pos/neg
aon_dofx_vibnotend
	rts
; --------------------------------------------------------------------
; $5
aon_dofx_glissvolumeslide
	move	d1,-(sp)
	moveq	#0,d1
	bsr	aon_dofx_toneslideNOW
	move	(sp)+,d1
	bra.b	aon_dofx_volumeslide
; --------------------------------------------------------------------
; $6
aon_dofx_vibvolumeslide
	move	d1,-(sp)
	bsr	aon_dofx_viboldampl
	move	(sp)+,d1
	bra	aon_dofx_volumeslide
; --------------------------------------------------------------------
; $A
aon_dofx_volumeslide
	move.b	d1,d2
	and.b	#$0f,d1
	and.b	#$f0,d2
	lsr.b	#4,d2
	tst.b	d2			; Protracker-Kompatibilität:
	bne.s	aon_dofx_vsok1		; Wenn volume slide up <>0
				; dann volume slide down nicht beachten!!
	sub.b	d1,aon_volume(a4)
	bpl.s	aon_dofx_vsok1
	clr.b	aon_volume(a4)
aon_dofx_vsok1
	add.b	d2,aon_volume(a4)
	cmp.b	#64,aon_volume(a4)
	bls.s	aon_dofx_vsOK2
	move.b	#64,aon_volume(a4)
aon_dofx_vsok2
	rts

; --------------------------------------------------------------------
; $B
aon_dofx_breakto
	subq.b	#1,d1
	move.b	d1,aon_pos(a6)
	move	#$ff00,aon_patcnt(a6)
	rts
; --------------------------------------------------------------------
; $C
aon_dofx_setvolume
	move.b	d1,aon_volume(a4)
	rts
; --------------------------------------------------------------------
; $D
aon_dofx_breakpat
	move.b	d1,d0		; e.g	$32 -> #32
	and.b	#$0f,d1
	and.b	#$f0,d0
	lsr.b	#1,d0		; -> $30->$18=#24
	move.b	d0,d2
	lsr.b	#3,d2		; -> $18/8->$03
	add.b	d2,d0		; #24+3
	add.b	d2,d0		; #27+3 (=#30)
	add.b	d1,d0		; +2!
	add.b	d0,d0		; =#32
	add.b	d0,d0		; ->*4
	or	#$ff00,d0	; add breakflag
	move	d0,aon_patcnt(a6)
	rts
; --------------------------------------------------------------------
; $F
aon_dofx_setspd
	tst.b	d1
	beq.b	aon_dofx_replayend

	cmp.b	#32,d1
	bhi.b	.settempo2
	move.b	d1,aon_speed(a6)
.quit	rts

.settempo2
	cmp.b	#200,d1
	bhi.b	.quit

; SET DMA-TEMPO HERE....
;   Seems to be the usual cia-value. ?
	move.b	d1,aon_tempo(a6)

	;move.l	#aon_timerval,d0
	;divu	d1,d0

aon_dofx_settempo		
	;move.b	d0,$bfd600	; MSB	Timer setzen
	;lsr	#8,d0		; 8-15
	;move.b	d0,$bfd700	; LSB
aon_dofx_vbireplay
	rts

aon_dofx_replayend
	clr.b	aon_speed(a6)
aon_resettimer
	move.b	#125,aon_tempo(a6)
	;move.b	#$6c,$bfd600	600
	;move.b	#$37,$bfd700	700
	rts




; --------------------------------------------------------------------------
; | E1- FineSlide Up                  E1x : value			   |
; | E2- FineSlide Down                E2x : value			   |
; | E3- Glissando Control             E3x : 0-off, 1-on (use with tonep.)  |
; | E4- Set Vibrato Waveform          E4x : 0-sine, 1-ramp down, 2-square  |
; | E5- Set Loop                      E5x : set loop point		   |
; | E6- Jump to Loop                  E6x : jump to loop, play x times     |
; | E7- Set Tremolo Waveform          E7x : 0-sine, 1-ramp down. 2-square  |
; | E8- NOT USED							   |
; | E9- Retrig Note                   E9x : retrig from note + x vblanks   |
; | EA- Fine VolumeSlide Up           EAx : add x to volume		   |
; | EB- Fine VolumeSlide Down         EBx : subtract x from volume	   |
; | EC- NoteCut                       ECx : cut from note + x vblanks	   |
; | ED- NoteDelay                     EDx : delay note x vblanks	   |
; | EE- PatternDelay                  EEx : delay pattern x notes	   |
; | EF- Invert Loop                   EFx : speed	   		   |
; $Ex

aon_dofx_ECOMMANDS
	move.b	d1,d0
	and.b	#$0f,d1
	and.b	#$f0,d0
	beq.s	aon_dofx_setfilter
	cmp.b	#$10,d0
	beq.s	aon_dofx_fineportamentoup
	cmp.b	#$20,d0
	beq.s	aon_dofx_fineportamentodn
	cmp.b	#$40,d0
	beq.s	aon_dofx_setvibratowave
	cmp.b	#$50,d0
	beq.w	aon_dofx_setlooppoint
	cmp.b	#$60,d0
	beq	aon_dofx_jump2loop
	cmp.b	#$90,d0
	beq	aon_dofx_retrignote
	cmp.b	#$a0,d0
	beq	aon_dofx_finevolup
	cmp.b	#$b0,d0
	beq	aon_dofx_finevoldn
	cmp.b	#$c0,d0
	beq	aon_dofx_notecut
	cmp.b	#$d0,d0
	beq	aon_dofx_retrignote
	rts
; --------------------------------------------------------------------
; $E0
aon_dofx_setfilter
	tst.b	d1
	beq.s	aon_dofx_filteron
	;bset	#1,$bfe001

	rts
aon_dofx_filteron
	;bclr	#1,$bfe001
	rts


; --------------------------------------------------------------------
; $E1
aon_dofx_fineportamentoup
	tst.b	aon_framecnt(a6)
	bne.s	aon_dofx_tool8
	sub	d1,aon_perslide(a4)
aon_dofx_tool8
	rts
; --------------------------------------------------------------------
; $E2
aon_dofx_fineportamentodn
	tst.b	aon_framecnt(a6)
	bne.s	aon_dofx_tool82
	add	d1,aon_perslide(a4)
aon_dofx_tool82
	rts
; --------------------------------------------------------------------
; $E4
aon_dofx_setvibratowave
	and.b	#3,d1
	ror.b	#3,d1
	and.b	#%10011111,aon_vibratoampl(a4)
	or.b	d1,aon_vibratoampl(a4)
	rts
; --------------------------------------------------------------------
; $E5
aon_dofx_setlooppoint
	move.b	aon_patcnt+1(a6),d0
	subq.b	#4,d0
	cmp.b	aon_looppoint(a6),d0
	beq.s	aon_dofx_justloopin
	move.b	d0,aon_looppoint(a6)
	clr.b	aon_loopcnt(a6)
aon_dofx_justloopin	rts
; --------------------------------------------------------------------
; $E6
aon_dofx_jump2loop
	tst.b	d1
	beq.s	aon_dofx_setlooppoint
	rts
; --------------------------------------------------------------------
; $E9
aon_dofx_retrignote
	tst.b	aon_stepfxcnt(a4)
	bne.s	aon_dofx_noretrig
	move.b	#3,aon_chflag(a4)
	move.b	#$ef,aon_fxcom(a4)
	rts
aon_dofx_noretrig
	subq.b	#1,aon_stepfxcnt(a4)
	rts
; --------------------------------------------------------------------
; $EA
aon_dofx_finevolup
	tst.b	aon_framecnt(a6)
	bne.s	aon_dofx_volresisup
	add.b	d1,aon_volume(a4)
	cmp.b	#64,aon_volume(a4)
	ble.s	aon_dofx_volresisup
	move.b	#64,aon_volume(a4)
aon_dofx_volresisup
	rts
; --------------------------------------------------------------------
; $EB
aon_dofx_finevoldn
	tst.b	aon_framecnt(a6)
	bne.s	aon_dofx_volresisdn
	sub.b	d1,aon_volume(a4)
	bpl.s	aon_dofx_volresisdn
	clr.b	aon_volume(a4)
aon_dofx_volresisdn
	rts
; --------------------------------------------------------------------
; $EC
aon_dofx_notecut
	tst.b	aon_stepfxcnt(a4)
	bne.s	.nonotecut
	clr.b	aon_volume(a4)
	rts
.nonotecut
	subq.b	#1,aon_stepfxcnt(a4)
	rts
; --------------------------------------------------------------------
; 'g'
aon_dofx_setvoldel
	tst.b	aon_stepfxcnt(a4)
	bne.b	.novolset
	and.b	#$f0,d1
	lsr.b	#4,d1
	add.b	d1,d1
	add.b	d1,d1
	addq.b	#4,d1
	move.b	d1,aon_volume(a4)
	rts
.novolset
	subq.b	#1,aon_stepfxcnt(a4)
	rts
; --------------------------------------------------------------------
; 'i'
aon_dofx_setwaveadsrspd
	move.b	d1,d2
	and.b	#$f0,d1
	lsr.b	#4,d1
	move.b	d1,aon_synthWAVEspd(a4)
	rts
; --------------------------------------------------------------------
; 'j'
aon_dofx_setarpspd
	and.b	#$f,d1
	beq.b	.not
	move.b	d1,aon_arpeggiospd(a4)
.not	rts
; --------------------------------------------------------------------
; 'k'
aon_dofx_vibsetvolume
	move	d1,-(sp)
	bsr	aon_dofx_viboldampl
	move	(sp)+,d1
	bra	aon_dofx_setvolume
; --------------------------------------------------------------------
; 'l'
aon_dofx_portvolslideUP
	lea	aon_nibbletab(pc),a0
	move	d1,d2
	lsr.b	#4,d1
	and.b	#$f,d2
	move.b	(a0,d1),d1
	bpl.b	.up1
	neg.b	d1
	bsr	aon_dofx_finevolDN
	bra.b	.down1
.up1	bsr	aon_dofx_finevolUP
.down1
	tst.b	aon_framecnt(a6)
	beq.b	.out
	moveq	#0,d1
	move.b	d2,d1
	bsr	aon_dofx_portamentoup

.out	rts

aoN_nibbletab
	dc.b	0,1,2,3,4,5,6,7,-8,-7,-6,-5,-4,-3,-2,-1

; --------------------------------------------------------------------
; 'm'
aon_dofx_portvolslideDOWN
	lea	aon_nibbletab(pc),a0
	move	d1,d2
	lsr.b	#4,d1
	and.b	#$f,d2
	move.b	(a0,d1),d1
	bpl.b	.up1
	neg.b	d1
	bsr	aon_dofx_finevolDN
	bra.b	.down1
.up1	bsr	aon_dofx_finevolUP
.down1
	tst.b	aon_framecnt(a6)
	beq.b	.out
	moveq	#0,d1
	move.b	d2,d1
	bsr	aon_dofx_portamentoDOWN

.out	rts
; --------------------------------------------------------------------
; 'n'
aon_dofx_togglenoiseavoid
	move.b	d1,aon_noiseavoid(a6)
	rts
; --------------------------------------------------------------------
; 'o'
aon_dofx_toggleoversize
	move.b	d1,aon_oversize(a6)
	rts
; --------------------------------------------------------------------
; 'p'
aon_dofx_fineVOLslidevib
	move	d1,-(sp)
	bsr	aon_dofx_viboldampl
	move	(sp)+,d1
aon_dofx_fineVOlUpDown
	moveq	#0,d2
	move.b	d1,d2
	lsr.b	#4,d2
	beq.b	.no
	move	d2,d1
	bra	aon_dofx_finevolup
.no	and.b	#$f,d1
	bra	aon_dofx_finevoldn
; --------------------------------------------------------------------
; 'q'
aon_dofx_synthdrums
	move	d1,d2
	lsr	#4,d1
	lsl	#3,d1
	bsr	aon_dofx_portamentodown
	move	d2,d1
	and	#$f,d1
	bra	aon_dofx_volumeslide
; --------------------------------------------------------------------
; 'r'
aon_dofx_setvolumePort
	move	d1,-(sp)
	bsr	aon_dofx_toneslideNOW
	move	(sp)+,d1
	bra	aon_dofx_setvolume
; --------------------------------------------------------------------
; 's'
aon_dofx_finevolslidePort
	move	d1,-(sp)
	bsr	aon_dofx_toneslideNOW
	move	(sP)+,d1
	bra	aon_dofx_fineVOlUpDown
; --------------------------------------------------------------------
; 't'
aon_dofx_settrackvol
	move	d1,aon_trackvol(a4)
	rts
; --------------------------------------------------------------------
; 'u'
;
aon_dofx_setwavecont
	move.b	d1,d2
	and.b	#$f,d1
	move.b	d1,aon_synthWAVECONT(a4)
	lsr.b	#4,d2
	move.b	d2,aon_synthWAVESTOP(a4)
	rts
; --------------------------------------------------------------------
; 'v'
; --------------------------------------------------------------------
; 'w'
; --------------------------------------------------------------------
; 'x'
aon_dofx_externalevent
	tst.b	aon_framecnt(a6)	; nur 1* aufrufen!!!
	beq.b	.yo
	rts
.yo	lea	aon_event(pc),a0	; pc-relativ bleiben
	move.b	d1,(a0)
	rts
; --------------------------------------------------------------------
; 'y'
aon_dofx_externalevent2
	tst.b	aon_framecnt(a6)	; nur 1* aufrufen!!!
	beq.b	.yo
	rts
.yo	lea	aon_event+1(pc),a0	; pc-relativ bleiben
	move.b	d1,(a0)
	rts
; --------------------------------------------------------------------
; 'z'
aon_dofx_externalevent3
	tst.b	aon_framecnt(a6)	; nur 1* aufrufen!!!
	beq.b	.yo
	rts
.yo	lea	aon_event+2(pc),a0	; pc-relativ bleiben
	move.b	d1,(a0)
	rts
; --------------------------------------------------------------------

;========================================================================
AON_STARTINSTR.1
	move	aon_fxcom(a4),d0
	and	#$0ff0,d0
	cmp	#$0ed0,d0
	beq.w	aon_strtinsonlyrep.1

	btst	#1,aon_chflag(a4)	; bit1= aonflag=2 or 3
	beq.b	aon_strtins.notset1

	tst.b	aon_noiseavoid(a6)
	beq.b	.letsknack
	cmp	#255,aon_oldwavelen(a4)
	bhi.b	.letsknack
	tst	aon_oldwavelen(a4)
	beq.b	.letsknack
	cmp	#255,aon_wavelen(a4)
	ble.b	aon_strtins.notset1
.letsknack
	bset	d7,d1
aon_strtins.notset1

	move	aon_period(a4),d0	; baseper+arpeggio
	add	aon_perslide(a4),d0	; portamento value
.checkhiper
	cmp	#103,d0
	bhs.b	.noperalert
	moveq	#103,d0
.noperalert
	move	d0,$6(a5)

	moveq	#0,d0
	move.b	aon_volume(a4),d0
	moveq	#0,d2
	move.b	aon_synthVOL(a4),d2
	lsr.b	#1,d2
	mulu	d2,d0
	lsr	#6,d0
	mulu	aon_trackvol(a4),d0
	lsr	#6,d0
	move.b	d0,$9(a5)

	btst	#1,aon_chflag(a4)
	beq.s	aon_strtinsonlyrep.1
	move.l	aon_waveform(a4),$0(a5)
	move	aon_wavelen(a4),$4(a5)

aon_strtinsonlyrep.1
	addq.b	#1,d7
aon_strtinsonlyrep.2
	lea	aon_chdatasize(a4),a4
	lea	$10(a5),a5
	rts






AON_STARTINSTR.2
	move	aon_fxcom(a4),d0
	and	#$0ff0,d0
	cmp	#$0ed0,d0
	beq.s	aon_strtinsonlyrep.1


	move.l	aon_repeatstrt(a4),(a5)
	move	aon_replen(a4),$4(a5)
	clr.b	aon_chflag(a4)
	bra.b	aon_strtinsonlyrep.1



;========================================================================

aon_event	dc.b	0,0,0		; z.b für demo-synchronisation
						; Uses v,w,x commands
		even
AON_leer	ds.b	30
AON_hi		dc.b	64,64
AON_multab120	dc	120*0,120*1,120*2,120*3,120*4,120*5,120*6,120*7
		dc	120*8,120*9,120*10,120*11,120*12,120*13,120*14,120*15

AON_PERIODS
	DC.B	$0D,$60,$0C,$A0,$0B,$E8,$0B,$40	;16 finetunes,5 octaves
	DC.B	$0A,$98,$0A,$00,$09,$70,$08,$E8
	DC.B	$08,$68,$07,$F0,$07,$80,$07,$14
	DC.B	$06,$B0,$06,$50,$05,$F4,$05,$A0
	DC.B	$05,$4C,$05,$00,$04,$B8,$04,$74
	DC.B	$04,$34,$03,$F8,$03,$C0,$03,$8A
	DC.B	$03,$58,$03,$28,$02,$FA,$02,$D0
	DC.B	$02,$A6,$02,$80,$02,$5C,$02,$3A
	DC.B	$02,$1A,$01,$FC,$01,$E0,$01,$C5
	DC.B	$01,$AC,$01,$94,$01,$7D,$01,$68
	DC.B	$01,$53,$01,$40,$01,$2E,$01,$1D
	DC.B	$01,$0D,$00,$FE,$00,$F0,$00,$E2
	DC.B	$00,$D6,$00,$CA,$00,$BE,$00,$B4
	DC.B	$00,$AA,$00,$A0,$00,$97,$00,$8F
	DC.B	$00,$87,$00,$7F,$00,$78,$00,$71
	DC.B	$0D,$48,$0C,$88,$0B,$D4,$0B,$2C
	DC.B	$0A,$88,$09,$F4,$09,$64,$08,$DC
	DC.B	$08,$5C,$07,$E4,$07,$74,$07,$08
	DC.B	$06,$A4,$06,$44,$05,$EA,$05,$96
	DC.B	$05,$44,$04,$FA,$04,$B2,$04,$6E
	DC.B	$04,$2E,$03,$F2,$03,$BA,$03,$84
	DC.B	$03,$52,$03,$22,$02,$F5,$02,$CB
	DC.B	$02,$A2,$02,$7D,$02,$59,$02,$37
	DC.B	$02,$17,$01,$F9,$01,$DD,$01,$C2
	DC.B	$01,$A9,$01,$91,$01,$7B,$01,$65
	DC.B	$01,$51,$01,$3E,$01,$2C,$01,$1C
	DC.B	$01,$0C,$00,$FD,$00,$EF,$00,$E1
	DC.B	$00,$D5,$00,$C9,$00,$BD,$00,$B3
	DC.B	$00,$A9,$00,$9F,$00,$96,$00,$8E
	DC.B	$00,$86,$00,$7E,$00,$77,$00,$71
	DC.B	$0D,$30,$0C,$70,$0B,$C0,$0B,$14
	DC.B	$0A,$78,$09,$E0,$09,$54,$08,$CC
	DC.B	$08,$50,$07,$D8,$07,$68,$06,$FC
	DC.B	$06,$98,$06,$38,$05,$E0,$05,$8A
	DC.B	$05,$3C,$04,$F0,$04,$AA,$04,$66
	DC.B	$04,$28,$03,$EC,$03,$B4,$03,$7E
	DC.B	$03,$4C,$03,$1C,$02,$F0,$02,$C5
	DC.B	$02,$9E,$02,$78,$02,$55,$02,$33
	DC.B	$02,$14,$01,$F6,$01,$DA,$01,$BF
	DC.B	$01,$A6,$01,$8E,$01,$78,$01,$63
	DC.B	$01,$4F,$01,$3C,$01,$2A,$01,$1A
	DC.B	$01,$0A,$00,$FB,$00,$ED,$00,$E0
	DC.B	$00,$D3,$00,$C7,$00,$BC,$00,$B1
	DC.B	$00,$A7,$00,$9E,$00,$95,$00,$8D
	DC.B	$00,$85,$00,$7D,$00,$76,$00,$70
	DC.B	$0D,$18,$0C,$5C,$0B,$A8,$0B,$00
	DC.B	$0A,$64,$09,$D0,$09,$40,$08,$BC
	DC.B	$08,$40,$07,$C8,$07,$58,$06,$F0
	DC.B	$06,$8C,$06,$2E,$05,$D4,$05,$80
	DC.B	$05,$32,$04,$E8,$04,$A0,$04,$5E
	DC.B	$04,$20,$03,$E4,$03,$AC,$03,$78
	DC.B	$03,$46,$03,$17,$02,$EA,$02,$C0
	DC.B	$02,$99,$02,$74,$02,$50,$02,$2F
	DC.B	$02,$10,$01,$F2,$01,$D6,$01,$BC
	DC.B	$01,$A3,$01,$8B,$01,$75,$01,$60
	DC.B	$01,$4C,$01,$3A,$01,$28,$01,$18
	DC.B	$01,$08,$00,$F9,$00,$EB,$00,$DE
	DC.B	$00,$D1,$00,$C6,$00,$BB,$00,$B0
	DC.B	$00,$A6,$00,$9D,$00,$94,$00,$8C
	DC.B	$00,$84,$00,$7D,$00,$76,$00,$6F
	DC.B	$0D,$00,$0C,$44,$0B,$94,$0A,$EC
	DC.B	$0A,$50,$09,$BC,$09,$30,$08,$AC
	DC.B	$08,$30,$07,$BC,$07,$4C,$06,$E4
	DC.B	$06,$80,$06,$22,$05,$CA,$05,$76
	DC.B	$05,$28,$04,$DE,$04,$98,$04,$56
	DC.B	$04,$18,$03,$DE,$03,$A6,$03,$72
	DC.B	$03,$40,$03,$11,$02,$E5,$02,$BB
	DC.B	$02,$94,$02,$6F,$02,$4C,$02,$2B
	DC.B	$02,$0C,$01,$EF,$01,$D3,$01,$B9
	DC.B	$01,$A0,$01,$88,$01,$72,$01,$5E
	DC.B	$01,$4A,$01,$38,$01,$26,$01,$16
	DC.B	$01,$06,$00,$F7,$00,$E9,$00,$DC
	DC.B	$00,$D0,$00,$C4,$00,$B9,$00,$AF
	DC.B	$00,$A5,$00,$9C,$00,$93,$00,$8B
	DC.B	$00,$83,$00,$7C,$00,$75,$00,$6E
	DC.B	$0C,$E8,$0C,$2C,$0B,$80,$0A,$D8
	DC.B	$0A,$3C,$09,$AC,$09,$20,$08,$9C
	DC.B	$08,$20,$07,$AC,$07,$3C,$06,$D4
	DC.B	$06,$74,$06,$16,$05,$C0,$05,$6C
	DC.B	$05,$1E,$04,$D6,$04,$90,$04,$4E
	DC.B	$04,$10,$03,$D6,$03,$9E,$03,$6A
	DC.B	$03,$3A,$03,$0B,$02,$E0,$02,$B6
	DC.B	$02,$8F,$02,$6B,$02,$48,$02,$27
	DC.B	$02,$08,$01,$EB,$01,$CF,$01,$B5
	DC.B	$01,$9D,$01,$86,$01,$70,$01,$5B
	DC.B	$01,$48,$01,$35,$01,$24,$01,$14
	DC.B	$01,$04,$00,$F5,$00,$E8,$00,$DB
	DC.B	$00,$CE,$00,$C3,$00,$B8,$00,$AE
	DC.B	$00,$A4,$00,$9B,$00,$92,$00,$8A
	DC.B	$00,$82,$00,$7B,$00,$74,$00,$6D
	DC.B	$0C,$D0,$0C,$18,$0B,$68,$0A,$C4
	DC.B	$0A,$2C,$09,$98,$09,$10,$08,$8C
	DC.B	$08,$10,$07,$9C,$07,$30,$06,$C8
	DC.B	$06,$68,$06,$0C,$05,$B4,$05,$62
	DC.B	$05,$16,$04,$CC,$04,$88,$04,$46
	DC.B	$04,$08,$03,$CE,$03,$98,$03,$64
	DC.B	$03,$34,$03,$06,$02,$DA,$02,$B1
	DC.B	$02,$8B,$02,$66,$02,$44,$02,$23
	DC.B	$02,$04,$01,$E7,$01,$CC,$01,$B2
	DC.B	$01,$9A,$01,$83,$01,$6D,$01,$59
	DC.B	$01,$45,$01,$33,$01,$22,$01,$12
	DC.B	$01,$02,$00,$F4,$00,$E6,$00,$D9
	DC.B	$00,$CD,$00,$C1,$00,$B7,$00,$AC
	DC.B	$00,$A3,$00,$9A,$00,$91,$00,$89
	DC.B	$00,$81,$00,$7A,$00,$73,$00,$6D
	DC.B	$0C,$B8,$0C,$00,$0B,$54,$0A,$B0
	DC.B	$0A,$18,$09,$88,$08,$FC,$08,$7C
	DC.B	$08,$04,$07,$90,$07,$24,$06,$BC
	DC.B	$06,$5C,$06,$00,$05,$AA,$05,$58
	DC.B	$05,$0C,$04,$C4,$04,$7E,$04,$3E
	DC.B	$04,$02,$03,$C8,$03,$92,$03,$5E
	DC.B	$03,$2E,$03,$00,$02,$D5,$02,$AC
	DC.B	$02,$86,$02,$62,$02,$3F,$02,$1F
	DC.B	$02,$01,$01,$E4,$01,$C9,$01,$AF
	DC.B	$01,$97,$01,$80,$01,$6B,$01,$56
	DC.B	$01,$43,$01,$31,$01,$20,$01,$10
	DC.B	$01,$00,$00,$F2,$00,$E4,$00,$D8
	DC.B	$00,$CC,$00,$C0,$00,$B5,$00,$AB
	DC.B	$00,$A1,$00,$98,$00,$90,$00,$88
	DC.B	$00,$80,$00,$79,$00,$72,$00,$6C
	DC.B	$0E,$2C,$0D,$60,$0C,$A0,$0B,$E8
	DC.B	$0B,$40,$0A,$98,$0A,$00,$09,$70
	DC.B	$08,$E8,$08,$68,$07,$F0,$07,$80
	DC.B	$07,$16,$06,$B0,$06,$50,$05,$F4
	DC.B	$05,$A0,$05,$4C,$05,$00,$04,$B8
	DC.B	$04,$74,$04,$34,$03,$F8,$03,$C0
	DC.B	$03,$8B,$03,$58,$03,$28,$02,$FA
	DC.B	$02,$D0,$02,$A6,$02,$80,$02,$5C
	DC.B	$02,$3A,$02,$1A,$01,$FC,$01,$E0
	DC.B	$01,$C5,$01,$AC,$01,$94,$01,$7D
	DC.B	$01,$68,$01,$53,$01,$40,$01,$2E
	DC.B	$01,$1D,$01,$0D,$00,$FE,$00,$F0
	DC.B	$00,$E2,$00,$D6,$00,$CA,$00,$BE
	DC.B	$00,$B4,$00,$AA,$00,$A0,$00,$97
	DC.B	$00,$8F,$00,$87,$00,$7F,$00,$78
	DC.B	$0E,$10,$0D,$48,$0C,$88,$0B,$D4
	DC.B	$0B,$2C,$0A,$8C,$09,$F0,$09,$64
	DC.B	$08,$DC,$08,$5C,$07,$E4,$07,$74
	DC.B	$07,$08,$06,$A4,$06,$44,$05,$EA
	DC.B	$05,$96,$05,$46,$04,$F8,$04,$B2
	DC.B	$04,$6E,$04,$2E,$03,$F2,$03,$BA
	DC.B	$03,$84,$03,$52,$03,$22,$02,$F5
	DC.B	$02,$CB,$02,$A3,$02,$7C,$02,$59
	DC.B	$02,$37,$02,$17,$01,$F9,$01,$DD
	DC.B	$01,$C2,$01,$A9,$01,$91,$01,$7B
	DC.B	$01,$65,$01,$51,$01,$3E,$01,$2C
	DC.B	$01,$1C,$01,$0C,$00,$FD,$00,$EE
	DC.B	$00,$E1,$00,$D4,$00,$C8,$00,$BD
	DC.B	$00,$B3,$00,$A9,$00,$9F,$00,$96
	DC.B	$00,$8E,$00,$86,$00,$7E,$00,$77
	DC.B	$0D,$F8,$0D,$30,$0C,$70,$0B,$C0
	DC.B	$0B,$14,$0A,$78,$09,$E0,$09,$54
	DC.B	$08,$CC,$08,$50,$07,$D8,$07,$68
	DC.B	$06,$FC,$06,$98,$06,$38,$05,$E0
	DC.B	$05,$8A,$05,$3C,$04,$F0,$04,$AA
	DC.B	$04,$66,$04,$28,$03,$EC,$03,$B4
	DC.B	$03,$7E,$03,$4C,$03,$1C,$02,$F0
	DC.B	$02,$C5,$02,$9E,$02,$78,$02,$55
	DC.B	$02,$33,$02,$14,$01,$F6,$01,$DA
	DC.B	$01,$BF,$01,$A6,$01,$8E,$01,$78
	DC.B	$01,$63,$01,$4F,$01,$3C,$01,$2A
	DC.B	$01,$1A,$01,$0A,$00,$FB,$00,$ED
	DC.B	$00,$DF,$00,$D3,$00,$C7,$00,$BC
	DC.B	$00,$B1,$00,$A7,$00,$9E,$00,$95
	DC.B	$00,$8D,$00,$85,$00,$7D,$00,$76
	DC.B	$0D,$DC,$0D,$18,$0C,$5C,$0B,$A8
	DC.B	$0B,$00,$0A,$64,$09,$D0,$09,$40
	DC.B	$08,$BC,$08,$40,$07,$C8,$07,$58
	DC.B	$06,$EE,$06,$8C,$06,$2E,$05,$D4
	DC.B	$05,$80,$05,$32,$04,$E8,$04,$A0
	DC.B	$04,$5E,$04,$20,$03,$E4,$03,$AC
	DC.B	$03,$77,$03,$46,$03,$17,$02,$EA
	DC.B	$02,$C0,$02,$99,$02,$74,$02,$50
	DC.B	$02,$2F,$02,$10,$01,$F2,$01,$D6
	DC.B	$01,$BC,$01,$A3,$01,$8B,$01,$75
	DC.B	$01,$60,$01,$4C,$01,$3A,$01,$28
	DC.B	$01,$18,$01,$08,$00,$F9,$00,$EB
	DC.B	$00,$DE,$00,$D1,$00,$C6,$00,$BB
	DC.B	$00,$B0,$00,$A6,$00,$9D,$00,$94
	DC.B	$00,$8C,$00,$84,$00,$7D,$00,$76
	DC.B	$0D,$C4,$0D,$00,$0C,$44,$0B,$94
	DC.B	$0A,$EC,$0A,$50,$09,$BC,$09,$30
	DC.B	$08,$AC,$08,$30,$07,$B8,$07,$4C
	DC.B	$06,$E2,$06,$80,$06,$22,$05,$CA
	DC.B	$05,$76,$05,$28,$04,$DE,$04,$98
	DC.B	$04,$56,$04,$18,$03,$DC,$03,$A6
	DC.B	$03,$71,$03,$40,$03,$11,$02,$E5
	DC.B	$02,$BB,$02,$94,$02,$6F,$02,$4C
	DC.B	$02,$2B,$02,$0C,$01,$EE,$01,$D3
	DC.B	$01,$B9,$01,$A0,$01,$88,$01,$72
	DC.B	$01,$5E,$01,$4A,$01,$38,$01,$26
	DC.B	$01,$16,$01,$06,$00,$F7,$00,$E9
	DC.B	$00,$DC,$00,$D0,$00,$C4,$00,$B9
	DC.B	$00,$AF,$00,$A5,$00,$9C,$00,$93
	DC.B	$00,$8B,$00,$83,$00,$7B,$00,$75
	DC.B	$0D,$AC,$0C,$E8,$0C,$2C,$0B,$80
	DC.B	$0A,$D8,$0A,$3C,$09,$AC,$09,$20
	DC.B	$08,$9C,$08,$20,$07,$AC,$07,$3C
	DC.B	$06,$D6,$06,$74,$06,$16,$05,$C0
	DC.B	$05,$6C,$05,$1E,$04,$D6,$04,$90
	DC.B	$04,$4E,$04,$10,$03,$D6,$03,$9E
	DC.B	$03,$6B,$03,$3A,$03,$0B,$02,$E0
	DC.B	$02,$B6,$02,$8F,$02,$6B,$02,$48
	DC.B	$02,$27,$02,$08,$01,$EB,$01,$CF
	DC.B	$01,$B5,$01,$9D,$01,$86,$01,$70
	DC.B	$01,$5B,$01,$48,$01,$35,$01,$24
	DC.B	$01,$14,$01,$04,$00,$F5,$00,$E8
	DC.B	$00,$DB,$00,$CE,$00,$C3,$00,$B8
	DC.B	$00,$AE,$00,$A4,$00,$9B,$00,$92
	DC.B	$00,$8A,$00,$82,$00,$7B,$00,$74
	DC.B	$0D,$90,$0C,$D0,$0C,$18,$0B,$68
	DC.B	$0A,$C4,$0A,$2C,$09,$98,$09,$10
	DC.B	$08,$8C,$08,$10,$07,$9C,$07,$30
	DC.B	$06,$C8,$06,$68,$06,$0C,$05,$B4
	DC.B	$05,$62,$05,$16,$04,$CC,$04,$88
	DC.B	$04,$46,$04,$08,$03,$CE,$03,$98
	DC.B	$03,$64,$03,$34,$03,$06,$02,$DA
	DC.B	$02,$B1,$02,$8B,$02,$66,$02,$44
	DC.B	$02,$23,$02,$04,$01,$E7,$01,$CC
	DC.B	$01,$B2,$01,$9A,$01,$83,$01,$6D
	DC.B	$01,$59,$01,$45,$01,$33,$01,$22
	DC.B	$01,$12,$01,$02,$00,$F4,$00,$E6
	DC.B	$00,$D9,$00,$CD,$00,$C1,$00,$B7
	DC.B	$00,$AC,$00,$A3,$00,$9A,$00,$91
	DC.B	$00,$89,$00,$81,$00,$7A,$00,$73
	DC.B	$0D,$78,$0C,$B8,$0C,$00,$0B,$54
	DC.B	$0A,$B0,$0A,$18,$09,$88,$08,$FC
	DC.B	$08,$7C,$08,$04,$07,$90,$07,$24
	DC.B	$06,$BC,$06,$5C,$06,$00,$05,$AA
	DC.B	$05,$58,$05,$0C,$04,$C4,$04,$7E
	DC.B	$04,$3E,$04,$02,$03,$C8,$03,$92
	DC.B	$03,$5E,$03,$2E,$03,$00,$02,$D5
	DC.B	$02,$AC,$02,$86,$02,$62,$02,$3F
	DC.B	$02,$1F,$02,$01,$01,$E4,$01,$C9
	DC.B	$01,$AF,$01,$97,$01,$80,$01,$6B
	DC.B	$01,$56,$01,$43,$01,$31,$01,$20
	DC.B	$01,$10,$01,$00,$00,$F2,$00,$E4
	DC.B	$00,$D8,$00,$CB,$00,$C0,$00,$B5
	DC.B	$00,$AB,$00,$A1,$00,$98,$00,$90
	DC.B	$00,$88,$00,$80,$00,$79,$00,$72


;========================================================================
AON_vibrato_sine
; ripped from ptreplay2.3
	dc.b	0,24,49,74,97,120,141,161
	dc.b	180,197,212,224,235,244,250,253
	dc.b	255,253,250,244,235,224,212,197
	dc.b	180,161,141,120,97,74,49,24	; ->32 bytes
AON_vibrato_rampdown
	dc.b	255,248,240,232,224,216,208,200,192,184,176,168,160,152,144
	dc.b	136,128,120,112,104,96,88,80,72,64,56,48,40,32,24,16,8
AON_vibrato_square
	dcb.b	32,255

;========================================================================

;========================================================================
;---------------------- Neuen Step auslesen -------------------------
aon8_playnewstep

;	TST.B	REPLAYSTATUS+MAIN_DATA
;	BEQ	AON8_PLAYCURRENT_NONEWPOSX

	cmp.b	#$ff,aon_patcnt(a6)
	beq	aon8_breakpat

; read new step
aon8_getstep
	tst.b	aon_patdelaycnt+1(a6)
	bmi.s	aon8_nopatdelay
	beq.s	aon8_nopatdelay
	subq.b	#1,aon_patdelaycnt+1(a6)
	bra.w	aon8_playcurrent_nonewposX
aon8_nopatdelay
	move.b	#-1,aon_patdelaycnt+1(a6)
	
	lea	aon_channels,a4
	lea	aon_multab120,a5	; needed for periodtab

	moveq	#0,d0
	MOVE.b	ACTEDITPATTERN,D0
	move.l	aon_pattdata(a6),a0	; get start of patdat

	mulu.w	aon_patternmultiplier(a6),d0	; patnr*1024=patoff
	lea	(a0,d0.l),a0		; add to start of data

	moveq	#0,d1
	move	aon_patcnt(a6),d1	; pos in pattern

;	MOVE.B	D1,DISPPATCNT+MAIN_DATA

	mulu.w	aon_trackcount(a6),d1
	lea	(a0,d1.l),a0		; add pattcounter

; a0=pointer on actual step
	jsr	aon_getdachannel	; get first channel

	move.w	aon_trackcount(a6),d7
	subq.w	#2,d7
.getchan1
	 lea	aon_chdatasize(a4),a4
	 addq.l	#4,a0
	 move.w	d7,-(a7)
	 jsr	aon_getdachannel	; get second channel, etc
	 move.w	(a7)+,d7
	dbf	d7,.getchan1

	tst.b	aon_loopflag(a6)
	beq.s	aon8_nolooping
	clr.b	aon_loopflag(a6)
	move.b	aon_looppoint(a6),aon_patcnt+1(a6)
	bra.b	aon8_playcurrent_nonewposX
aon8_nolooping
	addq.b	#4,aon_patcnt+1(a6)
	bne.b	aon8_playcurrent_nonewposX  ; End of pattern??
aon8_breakpat		

	clr.b	aon_patdelaycnt+1(a6)
	clr	aon_looppoint(a6)

;	CMP.B	#REPLAYST_PAT,REPLAYSTATUS+MAIN_DATA
;	BEQ.B	AON8_PLAYCURRENT2

	addq.b	#1,aon_pos(a6)			; pos=pos+1
	move.l	aon_statdata(a6),a3
	move.b	aon.songinfo_maxpos(a3),d0	; get maxpos
	cmp.b	aon_pos(a6),d0			; End of song ??
	bhi	aon8_playcurrent2

	move.b	aon.songinfo_respos(a3),aon_pos(a6) ; Get restart pos!
aon8_playcurrent2
	tst.b	aon_patcnt(a6)
	beq.b	aon8_playcurrent_nonewposX
	clr.b	aon_patcnt(a6)

	moveq	#0,d7
	move.b	aon_pos(a6),d7
	move.l	aon_posdata(a6),a1	; get start of posdat
	moveq	#0,d0
	move.b	(a1,d7),d0		; d7=act. pos + choff

;	CMP.B	#REPLAYST_ALL,REPLAYSTATUS+MAIN_DATA
;	BNE.S	AON8_DONTSETPATNR2
	MOVE.B	D0,ACTEDITPATTERN

AON8_DONTSETPATNR2
	bra	aon8_getstep
aon8_playcurrent_nonewposX
	rts
;========================================================================
AON8_STARTINSTR.1
	move	aon_fxcom(a4),d0
	and	#$0ff0,d0
	cmp	#$0ed0,d0
	beq.b	aon8_strtinsonlyrep.1

	move	aon_period(a4),d0	; baseper+arpeggio
	add	aon_perslide(a4),d0	; portamento value
.checkhiper
	cmp	#103,d0
	bhs.b	.noperalert
	moveq	#103,d0
.noperalert
	move	d0,$6(a5)
	move.b	aon_chflag(a4),$8(a5)
	moveq	#0,d0
	move.b	aon_volume(a4),d0
	moveq	#0,d2
	move.b	aon_synthVOL(a4),d2
	mulu	d2,d0
	lsr	#6,d0
	mulu	aon_trackvol(a4),d0
	or.b	#$80,8(a5)		;MINE
	lsr	#6,d0
	move.b	d0,$9(a5)

	move.l	aon_waveform(a4),$0(a5)
	move	aon_wavelen(a4),$4(a5)
aon8_strtinsonlyrep.1
	addq.b	#1,d7
aon8_strtinsonlyrep.2
	lea	aon_chdatasize(a4),a4
	lea	$10(a5),a5
	rts

AON8_STARTINSTR.2
	move	aon_fxcom(a4),d0
	and	#$0ff0,d0
	cmp	#$0ed0,d0
	beq.b	aon8_strtinsonlyrep.1
.sample2
	move.l	aon_repeatstrt(a4),10(a5)
	move	aon_replen(a4),14(a5)
	clr.b	aon_chflag(a4)
	bra.b	aon8_strtinsonlyrep.1
;--------------------------------------------------------------------
acteditpattern		ds.b	2




*************************************************************************
; ________________________________________________________________________
; 			
;                      -<>-O art.of.noise.replay v1.6 O-<>-		
; 	   coded by twice/lego! '93/4		
; ________________________________________________________________________

;========================================================================
AON8_PLAY
	lea	aon_data,a6
	addq.b	#1,aon_framecnt(a6)
	move.b	aon_speed(a6),d0
	beq.b	aon8_playcurrent_nonewpos2
	cmp.b	aon_framecnt(a6),d0
	bhi	aon8_playcurrent_nonewpos2
	clr.b	 aon_framecnt(a6)

	bsr	aon8_playnewstep
aon8_playcurrent_nonewpos2
;---------------------- Effekte & Samplestarts ----------------------
	lea	aon_data,a6
	moveq	#0,d7
	move.b	aon_pos(a6),d7
	move.l	aon_posdata(a6),a1	; get start of posdat
	moveq	#0,d0
	move.b	(a1,d7),d0		; d7=act. pos + choff
	MOVE.B	D0,ACTEDITPATTERN
	RTS

AON8_PLAYFX		
	lea	aon_data(pc),a6
	lea	aon_dofx,a1
	lea	aon_channels,a4	; do effect command
	 jsr	(a1)
	 lea	aon_chdatasize(a4),a4
	 jsr	(a1)
	 lea	aon_chdatasize(a4),a4
	 jsr	(a1)
	 lea	aon_chdatasize(a4),a4
	 jsr	(a1)
	 lea	aon_chdatasize(a4),a4
	rts

aon8_play_part2
	lea	aon_data,a6
	moveq	#0,d1	; Make channel-mask
	moveq	#0,d7
	lea	aon8_startinstr.1(pc),a1
	lea	aon_channels,a4		; do effect command
	lea	mix_bypass,a5
	 jsr	(a1)
	 jsr	(a1)
	 jsr	(a1)
	 jsr	(a1)
	lea	aon_channels,a4		; do effect command
	lea	mix_bypass,a5
	moveq	#0,d7
	lea	aon8_startinstr.2(pc),a1
	 jsr	(a1)
	 jsr	(a1)
	 jsr	(a1)
	 jsr	(a1)
	rts

;-------------------------
aonfalc_set_tracks:
	lea	aon_data(pc),a6
	sub.b	#"0",d1			;was ASCII!
	moveq	#0,d0
	move.b	d1,d0
	move.w	d0,aon_trackcount(a6)

	move.w	d0,d1
	mulu.w	#1024/4,d1
	move.w	d1,aon_patternmultiplier(a6)

	move.l	#67000*4,d2
	divu.l	d0,d2
	move.l	d2,Master_Volume
	rts

mycia_list:
	ifeq	hertz-2
	 include cia_33.s
	else
	 include cia_25.s
	endc

Dsp_Library	include	new_os4.s
		even

;---------------------------------------------------------------------
TempoCount	dc.l	10
ReceiveCount	dc.l	10
dummy_buffers	dc.l	dummy_buffer1
		dc.l	dummy_buffer2


;---------------------------------------------------------------------
aonfalc_dummy_sample	dcb.w	20,$00
aonfalc_save_interrupts ds.b	4+6
dummy_buffer1		ds.l	400
dummy_buffer2		ds.l	400
			even


;---------------------------------------------------------------------
* Aon_Data Offsets
			rsreset
aon_pos			rs.b	1	;actual pos while replaying 
aon_framecnt		rs.b	1	;0-aon_speed
aon_patcnt		rs.w	1	;-1= break pat
aon_looppoint		rs.b	1
aon_loopcnt		rs.b	1
aon_loopflag		rs.b	1
aon_statdata		rs.l	1	;address of static data in module
aon_arpdata		rs.l	1	;Pointer on arpeggio lists
aon_posdata		rs.l	1	;address of position tab
aon_pattdata		rs.l	1	;Pointer on patterns	(1st)
aon_patdelaycnt		rs.w	1
aon_wavestarts		rs.b	256	;adrs of waveforms (0-63)
aon_instrstarts		rs.b	256	;adrs of instruments (1-61)
aon_modulestart		rs.l	1	;Start of module
aon_replayMode		rs.b	1	;0=VBI,1=CIA A&B
aon_tempo		rs.b	1	;tempo 32-255 (bei cia-use speed=6)
aon_noiseavoid		rs.b	1
aon_oversize		rs.b	1
aon_dmaflag		rs.b	1+1
aon_dmacon		rs.w	1
aon_speed		rs.b	1	;0=off , 1-255
oldaudio		rs.l	1

; Falc additions:
aon_namedata		rs.l	1	;address of modname
aon_authdata		rs.l	1	;address of tommy... oops author
aon_datedata		rs.l	1	;address of date

aon_trackcount		rs.w	1	;number of tracks
aon_patternmultiplier	rs.w	1	;bytes/pattern
aon_stepmultiplier	rs.w	1	;bytes/step

aon_datasize		rs.w	1



;========================================================================
AON_DATA
;¯¯¯¯¯¯¯
			dcb.b	aon_datasize,0

AON_CHANNELS
;¯¯¯¯¯¯¯¯¯¯¯
			rsreset
aon_chflag		rs.b	1	;<>0 = new wave! (1=sample,2=synth)
aon_lastnote		rs.b	1	;well,the last note I guess ?!!!!
aon_waveform		rs.l	1	;wavestart
aon_wavelen		rs.w	1	;wavelen/2 (dma!)
aon_oldwavelen		rs.w	1	;to avoid noise when using rep <512bytes
aon_repeatstrt		rs.l	1	;repeatwavestart
aon_replen		rs.w	1	;repeat-lenght/2 (dma!)
aon_instrptr		rs.l	1	;POINTER oN ACT. INSTRDATA
aon_volume		rs.b	1	;Act.Volume (written into register)

aon_stepfxcnt		rs.b	1	;notecut/delay/retrig

aon_chMODE		rs.b	1	;0=sample8,1=synth8
aon_vibratospd		rs.b	1
aon_vibratoampl		rs.b	1
aon_vibratopos		rs.b	1
aon_vibratotrigdelay	rs.w	1	;-1=already triggered

aon_period		rs.w	1	;Act.periode (written into register)
					;(including slide up/down etc..)
aon_perslide		rs.w	1	;Added to periode (e.g. 4 portamento)

aon_arpeggiooff		rs.w	1
aon_arpeggiotab		rs.b	16	;7 øffsets (+ endmark) in per.tab
aon_arpeggiospd		rs.b	1	;Frame-Change-Speed
aon_arpeggiocnt		rs.b	1	;Countdown

aon_synthWAVEactPTR	rs.l	1	;actptr	(absolute waveform-adressen!!)
aon_synthWAVEendPTR	rs.l	1	;endwaveptr
aon_synthWAVErepPTR	rs.l	1	;anfang des repeat-teils
aon_synthWAVErependPTR	rs.l	1	:ende des repeat teils
aon_synthWAVEaddbytes	rs.l	1	;addiere/subtrahiere xxxx bytes
aon_synthWAVEcnt	rs.b	1	;framecnt
aon_synthWAVEspd	rs.b	1	;wechsel der waveform jeden n-ten frame
aon_synthWAVErepctrl	rs.b	1	;0=normal,1=back,2=pingpong
aon_synthWAVECONT	rs.b	1	;0=normal,1=wave durchlaufen lassen
aon_synthADD		rs.b	1
aon_synthSUB		rs.b	1
aon_synthEND		rs.b	1
aon_synthENV		rs.b	1	;0=NO AR envelope
aon_synthVOL		rs.b	1	;akt. adsr byte (*volume/64=abs vol!!)
aon_vibON		rs.b	1	;1=Do Vibrato!
aon_synthwaveSTOP	rs.b	1	;1=dont continue wave until U10
aon_vibDONE		rs.b	1	;1=Vibrato done
aon_vibCONT		rs.b	1+1	;1=Dauervibrato(wavetable),0=Only '4'etc


aon_fxCOM		rs.b	1	;Effect-Command
aon_fxDAT		rs.b	1	;Effect-Parameter

aon_oldsampoff		rs.l	1	;used for '9' effect
aon_glissspd		rs.w	1	;speed for '3' effect

aon_slideflag		rs.b	1	;<>0=Sliding active
aon_actwavenr		rs.b	1

aon_trackvol		rs.w	1	;64=max,0=track mute

aon_chdatasize		rs.w	1
			ds.b	aon_chdatasize*8
			even


;--------------------------------------------------------------------
mix_DATA:
			rsreset
mix_trigger		rs.w	1
mix_wavestart		rs.l	1
mix_waveoff		rs.l	1
mix_wavelen		rs.l	1
mix_repstrt		rs.l	1
mix_replen		rs.l	1
mix_period		rs.w	1
mix_status		rs.b	1+1	0=Ch off , 1=Ch plays
 ;Falc Additions:
mix_falcstereo		rs.w	1
mix_falcvolume		rs.w	1
mix_datasize		rs.w	1
			dcb.b	mix_datasize*8,0

mix_bypass		dcb.b	$10*8,0
			even

