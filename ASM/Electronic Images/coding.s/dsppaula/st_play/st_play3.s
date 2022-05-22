;-----------------------------------------------------------------------;
; 50khz 4 channel ProTracker Player using DSP. 				;
; (Now with TEMPO...)							;
; By Martin Griffiths (C) June-December 1993				;
; Paula Emulator 3.7! 							;
;-----------------------------------------------------------------------;

		clr.l	-(a7)
		move.w	#$20,-(a7)
		trap	#1			; supervisor
		addq.l #6,sp
		move.l d0,savesp
		move.w #$1900,Mad_Music+($244c24-$2449d4)
		move.w #$1900,Mad_Music+($244b60-$2449d4)
		;move.w #$1900,Mad_Music+($23b1c6-$23afb4)
		;move.w #$1900,Mad_Music+($23b0ea-$23afb4)
		BSR 	M_SaveSound	
		moveq 	#2,d0
		bsr	M_Setup
		bsr	M_On
keyloop		cmp.b 	#$39,$fffffc02.w
		bne.s keyloop
		;move.w	#7,-(a7)
		;trap	#1
		;addq.l	#2,a7
		bsr	M_Off
		bsr 	M_RestSound	

		move.l	savesp(pc),-(a7)
		move.w	#$20,-(a7)
		trap	#1			; supervisor
		addq.l #6,sp

		clr.w	-(a7)
		trap	#1

savesp		dc.l 0
myrte		rte

; The Player.

; Macro to move parameter '\1' into the shadow dma register...
; (Remember - bit 15 of 'dmacon' determines clearing or setting of bits!)

move_dmacon	MACRO
.setdma\@	MOVE.W D4,-(Sp)			; save D4
		MOVE.W \1,D4
		BTST #15,D4			; set or clear?
		BNE.S .setbits\@		
.clearbits\@	NOT.W D4			; zero so clear
		AND.W D4,shadow_dmacon		; mask bits in dmacon
		BRA.S .dmacon_set\@		; and exit...
.setbits\@	OR.W D4,shadow_dmacon		; not zero so set 'em
.dmacon_set\@	MOVE.W (sp)+,D4			; restore D4
		ENDM

int_flag	EQU 0      			; 1 for linear interpolation
wait_flag	EQU 0			; wait for dsp to finish flag.
pre_div		EQU 1			; pre divider(frequency)
freq		EQU ((25175000)/(pre_div+1))/256

M_SaveSound	BRA.W Save_Sound
M_Setup		BRA.W Mad_Music
M_On		BRA.W Start_music 
M_Off		BRA.W Stop_music 
M_RestSound	BRA.W Restore_Sound

Save_Sound	LEA old_stuff(PC),A0
		MOVE.W SR,-(SP)
		MOVE.W #$2700,SR
		MOVE.L $134.W,(a0)+
		MOVE.W $ffff8900.W,(A0)+
		MOVE.W $ffff8920.W,(A0)+
		MOVE.L $ffff8930.W,(A0)+
		MOVE.W $ffff8934.W,(A0)+
		MOVE.W $ffff8936.W,(A0)+
		MOVE.W $ffff8938.W,(A0)+
		MOVE.W $ffff893A.W,(A0)+
		MOVE.B $fffffa17.W,(A0)+
		MOVE.B $fffffa19.W,(A0)+
		MOVE.B $fffffa1f.W,(A0)+
		MOVE.W (SP)+,SR
		RTS

Restore_Sound	LEA old_stuff(PC),A0
		MOVE.W SR,-(SP)
		MOVE.W #$2700,SR
		MOVE.L (a0)+,$134.W
		MOVE.W (a0)+,$ffff8900.W
		MOVE.W (a0)+,$ffff8920.W
		MOVE.L (a0)+,$ffff8930.W
		MOVE.W (a0)+,$ffff8934.W
		MOVE.W (a0)+,$ffff8936.W
		MOVE.W (a0)+,$ffff8938.W
		MOVE.W (a0)+,$ffff893A.W
		MOVE.B (a0)+,$fffffa17.W
		MOVE.B (a0)+,$fffffa19.W
		MOVE.B (a0)+,$fffffa1f.W
		MOVE.W (SP)+,SR
		RTS

Start_music	BSR dsp_boot
		move.b  #pre_div,$FFFF8935.w  	;49.2khz
                move.b  #2,$FFFF8937.w		;CODEC <- Multiplexor
                move.b  #3,$FFFF8938.w		;L+R <- Soundchip(NOT ADC!)
		MOVE.W SR,-(SP)
		MOVE.W #$2700,SR
.wait1		BTST.B #0,$FFFFA202.W
		BEQ.S .wait1
		MOVE.L $FFFFA204.W,D0		; get dummy
		AND.L #$FFFFFF,D0
		CMP.L #$123456,D0
		BNE.S .wait1
.wait2		
		BTST.B #1,$FFFFA202.W
		BEQ.S .wait2
		MOVE.L #freq,$FFFFA204.W	; send dsp frequency to play at.
                MOVE #%1000000110011001,$FFFF8930.w	; dma output 25mhz clock,no handshake
                MOVE #%1011100100011101,$FFFF8932.w	; dsp out -> dac
                MOVE #0,$FFFF8920.w 		; 16 bit stereo,50khz,play 1 track,dac to track 1
		BCLR #7,$FFFF8901.w  		; select playback register
		BCLR #3,$fffffa17.W		; soft end of interrupt
		MOVE.B #0,$FFFFFA19.W
		MOVE.L #music_int,$134.W
		BSET.B #5,$FFFFFA07.W		;iera
		BSET.B #5,$FFFFFA13.W		;imra
		MOVE.B #1,$FFFFFA1F.W
		MOVE.B #8,$FFFFFA19.W
		MOVE.W (SP)+,SR
		BSR Set_DMA
		MOVE #1024+3,$FFFF8900.W	; DMA ON,timer a int
		MOVE.B #8,$FFFF8800.W
		MOVE.B #0,$FFFF8802.W
		MOVE.B #9,$FFFF8800.W
		MOVE.B #0,$FFFF8802.W
		MOVE.B #10,$FFFF8800.W
		MOVE.B #0,$FFFF8802.W
		;MOVE.W #125,ch1s+sam_period
		;move.l	#SquareWave,ch1s+sam_start
		;move.w	#1,ch1s+sam_length

		;MOVE.W #125,ch2s+sam_period
		;move.l	#SquareWave,ch2s+sam_start
		;move.w	#1,ch2s+sam_length

		;MOVE.W #125,ch3s+sam_period
		;move.l	#SquareWave,ch3s+sam_start
		;move.w	#1,ch3s+sam_length

		MOVE.W #0,ch4s+sam_vol
		MOVE.W #126,ch4s+sam_period
		RTS

Stop_music	MOVE.W SR,-(SP)
		MOVE.W #$2700,SR
		MOVE.B #0,$FFFFFA19.W		; STOP INT
		MOVE.W #0,$FFFF8900.W		; STOP DMA
		BCLR.B #5,$FFFFFA07.W		; iera
		BCLR.B #5,$FFFFFA07.W		; iera
		MOVE.W (SP)+,SR
		RTS

; Music Interrupt

		RSRESET
sam_start	RS.L 1			; sample start
sam_length	RS.W 1			; sample length
sam_period	RS.W 1			; sample period(freq)
sam_vol		RS.W 1			; sample volume
sam_lpstart	RS.L 1			; sample loop start
sam_lplength	RS.W 1	 		; sample loop length
cur_start	RS.L 1
cur_end		RS.L 1
cur_lpstart	RS.L 1
cur_lpend	RS.L 1
cur_pos		RS.L 1
cur_lpflag	RS.B 1
cur_haslpflag	RS.B 1
sam_vcsize	RS.B 1			; structure size.

music_int	;TAS.B player_sem
		;BNE .out
		BSR Set_DMA
		MOVE.W #$2500,SR
		MOVE.B #$80+19,$FFFFA201.W		; host command 2
		MOVEM.L	D0-D7/A0-A6,-(A7)
.waitdspexcp	BTST #7,$FFFFA201.w
		BNE.S .waitdspexcp		
		MOVE.L $FFFF9800.W,-(SP)
		MOVE.L #$F7000000,$FFFF9800.W
		NOT.W $FFFF8240.W
;.wait		move.b	$FFFFA202.w,d0
;		and.b	#$18,d0
;		cmp.b	#$18,d0
;		bne.s	.wait
		LEA $FFFFA207.W,A6		; point to lsbyte
.wait		BTST.B #1,-5(A6)
		BEQ.S .wait
		MOVE.L #int_flag,$FFFFA204.W	; signal dsp to go!
.wait8		BTST.B #1,-5(A6)
		BEQ.S .wait8
		MOVE.L #0,$FFFFA204.W
		;MOVE.L vces_8_flag,$FFFFA204.W

		LEA ch1s(PC),A1
		BSR setup_paula
		LEA ch2s(PC),A1
		BSR setup_paula
		LEA ch3s(PC),A1
		BSR setup_paula
		LEA ch4s(PC),A1
		BSR setup_paula
		MOVEQ #0,D7
		LEA ch1s(PC),A1
		MOVEQ #0,D6
		BSR send_voice
		LEA ch2s(PC),A1
		MOVEQ #1,D6
		BSR send_voice
		LEA ch3s(PC),A1
		MOVEQ #2,D6
		BSR send_voice
		LEA ch4s(PC),A1
		MOVEQ #3,D6
		BSR send_voice


.wait1		BTST #1,$FFFFA202.W		 
		BEQ.S .wait1
		MOVE.L #wait_flag,$FFFFA204.W
		IFNE wait_flag
.wait2		BTST #0,$FFFFA202.W		 
		BEQ.S .wait2
		TST.W $FFFFA206.W		
		ENDC
		BSR ST_Music
		move_dmacon #$800f
		NOT.W $FFFF8240.W
		MOVE.L (SP)+,$FFFF9800.W
		MOVEM.L	(A7)+,D0-D7/A0-A6
		BCLR.B #5,$FFFFFA0F.W
		;SF player_sem
.out		RTE

setup_paula	MOVE.L sam_start(A1),D2
		BEQ.S .nosetnewmains
		MOVE.L D2,cur_start(A1)
		MOVE.L D2,cur_lpstart(A1)
		MOVE.L D2,cur_pos(A1)
		MOVE.L #0,sam_start(A1)
		SF cur_lpflag(A1)
.nosetnewmains	MOVEQ #0,D0
		MOVE.W sam_length(A1),D0
		BMI.S .nosetnewmainl
		MOVE.L cur_start(A1),D2
		ADD.L D0,D0
		ADD.L D0,D2
		MOVE.L D2,cur_end(A1)
		MOVE.L D2,cur_lpend(A1)
		MOVE.W #-1,sam_length(A1)
.nosetnewmainl	MOVE.L sam_lpstart(A1),D2
		BEQ.S .nosetnewloops
		MOVE.L D2,cur_lpstart(A1)
		MOVE.L #0,sam_lpstart(A1)
.nosetnewloops	MOVEQ #0,D0
		MOVE.W sam_lplength(A1),D0
		BMI.S .nosetnewloopl
		MOVE.L cur_lpstart(A1),D2
		ADD.L D0,D0
		ADD.L D0,D2
		MOVE.L D2,cur_lpend(A1)
		MOVE.W #-1,sam_lplength(A1)
.nosetnewloopl	RTS


; Send 1 voice to the dsp.

send_voice	MOVEQ #0,D0
		MOVE.W sam_vol(A1),d0
		CMP.W #$40,D0
		BLS.S .volok
		MOVEQ #$40,D0
.volok		SWAP D0
.sync		BTST #1,-5(A6)			;;;
		BEQ.S .sync			; send volume 
		MOVE.L D0,-3(A6)		;;; 
.wait1		BTST #1,-5(A6)			;;;
		BEQ.S .wait1			; send 
		CLR.B -2(A6)			;   period
		MOVE.W sam_period(A1),-1(a6)	;;;
.wait2		BTST #0,-5(A6)			; 
		BEQ.S .wait2			; 
		MOVE.W -1(A6),D5		; get no. of samples
		BTST D6,shadow_dmacon+1		; voice dma on?
		BEQ dmaisoff			; no, then send zeros...
		MOVE.L cur_end(A1),A2
		MOVE.L cur_lpend(A1),A3
		MOVE.L cur_pos(A1),A0		; current voice address
		MOVE.L cur_start(A1),A4
		MOVE.L cur_lpstart(A1),A5
		MOVE.B cur_lpflag(A1),D3
		CLR.W -2(a6)			; clear top 16 msbits
do_vce		TST.B D3			; sample looping?
		BNE.S in_loop
in_main		CMP.L A4,A2			; sample start = sample end?
		BLE.S vce_isoffcont
		BRA.S vc_main_cont
in_loop		CMP.L A5,A3
		BLE.S vce_isoffcont
		BRA.S vclp_cont
vc_main_lp	MOVE.B (A0)+,(A6)
vc_main_cont	CMP.L A2,A0
		DBGE D5,vc_main_lp
		BLT.S vce_done
hit_looppoint	ST D3
		MOVE.L A5,A0
		CMP.L A5,A3
		BEQ.S vce_isoffcont
		BRA.S vclp_cont
vc_loop_lp	MOVE.B (A0)+,(A6)
vclp_cont	CMP.L A3,A0
		DBGE D5,vc_loop_lp
		BLT.S vce_done
vclp_resetlp	MOVE.L A5,A0
		DBF D5,vc_loop_lp
vce_done	MOVE.B (A0),(A6)
vce_done1	MOVE.B D3,cur_lpflag(A1)
		MOVE.L A0,cur_pos(A1)	; store new address
		RTS

dmaisoff	BRA.S vce_isoffcont
vce_isoff	
.wait		BTST.B #1,-5(A6)
		BEQ.S .wait
		MOVE.B D7,(A6)
vce_isoffcont	DBF D5,vce_isoff
.wait		BTST.B #1,-5(A6)
		BEQ.S .wait
		MOVE.B D7,(A6)
		BRA.S vce_done1
RealTempo 	DC.W 125
; Set DMA to buffer(buffer len based on TEMPO)

Set_DMA		MOVEM.L D0/D1,-(SP)
		MOVE.L #dummy,d0
		MOVEQ #0,D1
		MOVE.W RealTempo(PC),D1
		MOVE.W ciaem_tab(PC,D1.W*2),D1
		LSL.L #1,D1
		ADD.L D0,D1
setptrs		MOVE.B d0,$FFFF8907.W
		LSR.L #8,D0
		MOVE.B d0,$FFFF8905.W
		LSR.L #8,D0
		MOVE.B d0,$FFFF8903.W	
		MOVE.B d1,$FFFF8913.W
		LSR.L #8,D1
		MOVE.B d1,$FFFF8911.W
		LSR.L #8,D1
		MOVE.B d1,$FFFF890f.W
		MOVEM.L (SP)+,D0/D1
		RTS
ciaem_tab	INCBIN d:\coding.s\dsppaula\CIA_EMU.TAB

; Paula emulation storage structure.

ch1s		DS.B sam_vcsize
ch2s		DS.B sam_vcsize			; shadow channel regs
ch3s		DS.B sam_vcsize
ch4s		DS.B sam_vcsize
ch5s		DS.B sam_vcsize
ch6s		DS.B sam_vcsize			; shadow channel regs
ch7s		DS.B sam_vcsize
ch8s		DS.B sam_vcsize

shadow_dmacon	DS.W 1
shadow_filter	DS.W 1
player_sem	DC.W 0

; Reset DSP, and load boot.

dsp_boot	move	sr,-(a7)
		move.w	#$2700,sr
		move.b	#$E,$FFFF8800.w
		move.b	$FFFF8800.w,d0
		or.b	#$10,d0
		move.b	d0,$FFFF8802.w
		rept 8
		nop
		endr
		and.b	#$EF,d0
		move.b	d0,$FFFF8802.w
		move.w	(a7)+,sr
		LEA DspProg(PC),A0
		move.w #512-1,d0
.lp		move.b (a0)+,$FFFFA205.w
		move.w (a0)+,$FFFFA206.w
		dbf d0,.lp
		move.b	#0,$FFFFA200.w
		rts

*****************************************************************************
* SOUND-CHIP EMULATOR			    				    *
*****************************************************************************

		rsreset

st_tone_per	rs.w	1
st_volume	rs.w	1
st_tone_on_flag	rs.b	1
st_nois_on_flag	rs.b	1
st_playing_sq	rs.b	1	
		rs.b	1
chan_size	rs.b	0

st_channel1	ds.b	chan_size
st_channel2	ds.b	chan_size
st_channel3	ds.b	chan_size
env_freq:	dc.l 	0

ST_Music
	bsr 	gen_noise
	bsr	Mad_Music+8

	movem.l	d0/d1,-(sp)
	moveq	#0,d0
	move.b	#12,$ffff8800.w
	move.b	$ffff8802.w,d0
	lsl.w 	#8,d0
	move.b	#11,$ffff8800.w
	move.b	$ffff8802.w,d0
	;move.l	#$7000,d1
	;divu.l	d0,d1
	move.l	d0,env_freq
	movem.l	(sp)+,d0/d1

	lsr.w	#8,d7
	lea	st_channel1(pc),a3
	lsr.w	#8,d0
	move.b	d0,d1
	move.w	d1,st_tone_per(a3)
	move.w	a0,d0
	lsr.w	#8,d0
	move.w	d0,st_volume(a3)
	btst	#0,d7
	seq	st_tone_on_flag(a3)
	btst	#3,d7
	seq	st_nois_on_flag(a3)
	
	lea	st_channel2(pc),a3
	lsr.w	#8,d2
	move.b	d2,d3
	move.w	d3,st_tone_per(a3)
	move.w	a1,d0
	lsr.w	#8,d0
	move.w	d0,st_volume(a3)
	btst	#1,d7
	seq	st_tone_on_flag(a3)
	btst	#4,d7
	seq	st_nois_on_flag(a3)
	
	lea	st_channel3(pc),a3
	lsr.w	#8,d4
	move.b	d4,d5
	move.w	d5,st_tone_per(a3)
	move.w	a2,d0
	lsr.w	#8,d0
	move.w	d0,st_volume(a3)
	btst	#2,d7
	seq	st_tone_on_flag(a3)
	btst	#5,d7
	seq	st_nois_on_flag(a3)
	
	lea	logtable(pc),a3
	lea 	envl1(pc),a4
	lea	ch1s(pc),a5
	lea	st_channel1(pc),a6
	bsr	do_st_chan
	lea 	envl2(pc),a4
	lea	ch2s(pc),a5
	lea	st_channel2(pc),a6
	bsr	do_st_chan
	lea 	envl3(pc),a4
	lea	ch3s(pc),a5
	lea	st_channel3(pc),a6
	bsr	do_st_chan
	rts

do_st_chan
	move.w	st_tone_per(a6),d1
	muls.w 	#($10000+50688)/4,d1
	lsl.l 	#2,d1
	swap d1
	move.w	d1,sam_period(a5)
	tst.b 	st_tone_on_flag(a6)
	beq.s 	st_vce_off
	move.w 	st_volume(a6),d0
	btst	#4,d0
	beq.s	noenv
	sf	st_playing_sq(a6)
	move.l	a4,sam_start(a5)
	move.w	#Envlength/2,sam_length(a5)
	move.w	#63,sam_vol(a5)
	move.w	#75,sam_period(a5)
	bsr	gen_env
	rts
noenv:	tst.b	st_playing_sq(a6)
	bne.s	alreadysq
	move.l	#SquareWave,sam_start(a5)
	move.w	#16/2,sam_length(a5)
	st	st_playing_sq(a6)
alreadysq:
	move.w	(a3,d0.w*8),sam_vol(a5)
	rts
st_vce_off
	move.w	#0,sam_vol(a5)
	rts



	btst	#11,d7
	beq.s	noise0
	moveq.w	#0,d0
noise0
	btst	#12,d7
	beq.s	noise1
	moveq.w	#0,d1
noise1
	btst	#13,d7
	beq.s	noise2
	moveq.w	#0,d2
noise2

	cmp.w	d0,d1
	blt.s	d1notlessthan
	exg	d1,d0
d1notlessthan
	cmp.w	d0,d2
	blt.s	d2notlessthan
	exg	d2,d0
d2notlessthan

;	btst	#11,d7
;	beq.s	Noiseon
;	btst	#12,d7
;	beq.s	Noiseon
;	btst	#13,d7
;	beq.s	Noiseon
;	move.w	#0,ch4s+sam_vol
;	move.w	#0,ch4s+sam_period
;Noisereturn
;	rts
;
;Noiseon
;	move.l #noise,ch4s+sam_lpstart
;	move.w	#16/2,ch4s+sam_lplength
;	lsr.w	#8,d6
;	;lsl.w #6,d6
;	add.w	#128,d6
;	lsl.w #4,d6
;	muls.w #($10000+50688)/4,d6
;	lsl.l 	#2,d6
;	swap 	d6
;	move.w	d6,ch4s+sam_period
;	add.w	d1,d0
;	add.w	d2,d0
;	ext.l	d0
;	divu	#3,d0
;	move.w	d0,ch4s+sam_vol
;	bra.s	Noisereturn

gen_noise
	lea noise,a0
	move.w #16,d1
noise_lp:
	bsr Rand
	and.w	#7,d0
.lp1	move.b	#$7f,(a0)+
	subq #1,d1
	beq.s noise_done
	dbf 	d0,.lp1
	bsr 	Rand
	and.w	#7,d0
.lp2	move.b	#$80,(a0)+
	subq #1,d1
	beq.s noise_done
	dbf 	d0,.lp2
	bra.s	 noise_lp
noise_done:
	rts

Rand	move.w seed(pc),d0
	eor.W #$19f7,D0
	ADD.W #$573,D0
	MULU #$f5Fe,D0
	SWAP D0
	ROR.W #6,D0
	move.w d0,seed
	not.w d0
	RTS
seed	dc.w $a797

gen_env
	ext.l	d1
	;moveq	#0,d2
	;moveq	#0,d3
	move.l	frac1,d2
	move.l	frac2,d3
	lea	EnvelopeA(pc),a0
	move.l	#4714996*2,d6
	divu.l	d1,d6
	
	move.l	#3579545,d7
	divu.l	d1,d7
	lsl.l	#8,d7
	divu.l	env_freq(pc),d7
	move.w	#16-1,d0
.lp	swap	d2
	swap	d3
	and.w	#15,d2
	and.w	#255,d3
	move.b	Squarewave(pc,d2),d4
	;ext.w	d4
	;muls	(a0,d3*2),d4	
	;asr.w 	#8,d4
	move.b	d4,(a4)+
	swap 	d2
	swap	d3
	add.l	d6,d2
	add.l	d7,d3
	dbf 	d0,.lp
env_done:
	move.l	d2,frac1
	move.l	d3,frac2

	rts
frac1	dc.l 0
frac2	dc.l 0

Squarewave	rept	16
		dcb.b	8,$80
		dcb.b	8,$7f
		endr
;EnvShift	equ 	1
;Envlength	equ	2
;EnvelopeA	dc.w	$7f00,$ff00

EnvShift	equ 	7
Envlength	equ	256
EnvelopeA	
i 		set -128
		rept 128
		dc.w 	i
i 		set i+2
		endr
		rept 128
i 		set i-2
		dc.w 	i
		endr
noise:		ds.b	16
envl1:		ds.b	Envlength
envl2:		ds.b	Envlength
envl3:		ds.b	Envlength

logtable
	dc.w	0,1,1,1,1,1,1,2,2,2,2,2,2,2,2,3
	dc.w	3,3,3,3,4,4,4,4,5,5,5,6,6,7,7,7
	dc.w	8,9,9,10,10,11,12,13,13,14,15,16,17,19,20,21
	dc.w	23,24,26,27,29,31,33,36,38,41,43,46,49,53,56,60
	dc.w	64

; Dsp Code

old_stuff	DS.L 10

DspProg		incbin d:\coding.s\dsppaula\dspaula.bin
DspProgEnd	DS.B (3*512)-(*-DspProg)
		EVEN

dummy		

Mad_Music	;incbin starwrs.mus
		;incbin BIGSPRTE.mus
		incbin roll_out.mus
		;incbin ny2vibr.mus
		;incbin techtron.mus
