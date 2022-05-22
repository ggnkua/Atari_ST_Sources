;-----------------------------------------------------------------------;
; 50khz 4 channel ProTracker Player using DSP. 				;
; By Martin Griffiths (C) June-August 1993				;
; Paula Emulator 3.0! 							;
;-----------------------------------------------------------------------;

		clr.l	-(a7)
		move.w	#$20,-(a7)
		trap	#1			; supervisor
		addq.l #6,sp
		move.l d0,savesp
		lea 	Module,a0
		bsr	M_Setup
		bsr	M_On
		move.w	#7,-(a7)
		trap	#1
		addq.l	#2,a7
		bsr	M_Off

		move.l	savesp,-(a7)
		move.w	#$20,-(a7)
		trap	#1			; supervisor
		addq.l #6,sp

		clr.w	-(a7)
		trap	#1

savesp		dc.l 0

;
; The Player.
;

int_flag	EQU 1			; 1 for linear interpolation
freq		EQU 246			; timer a frequency

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
cur_lpflag	RS.W 1
sam_vcsize	RS.B 1			; structure size.


M_Setup		BRA.W Setup_Module 
M_On		BRA.W Start_music 
M_Off		BRA.W Stop_music 

Setup_Module	BSR pp_Init 
		MOVE.W #1,-(A7)		; 16 bit stereo
		MOVE.W #$84,-(A7)	; setmode
		TRAP #14
		ADDQ.L #4,A7
		RTS

Stop_music	MOVE.W SR,-(SP)
		MOVE.W #$2700,SR
		MOVE.L Old_A(PC),$134.W
		MOVE.B Old_19(PC),$fffffa19.W
		MOVE.B Old_1f(PC),$fffffa1f.W
		BCLR #5,$fffffa07.W
		BCLR #5,$fffffa13.W
		MOVE.W (SP)+,SR
		MOVE.W #1,-(A7)
		MOVE.W #0,-(A7)
		MOVE.W #0,-(A7)
		MOVE.W #8,-(A7)
		MOVE.W #0,-(A7)
		MOVE.W #$8B,-(A7)	; devconnect
		TRAP #14
		LEA 12(A7),A7
		RTS

Start_music	MOVE.B $fffffa19.W,Old_19
		MOVE.B $fffffa1f.W,Old_1f
		MOVE.L $134.W,Old_A
		MOVE.W #1,-(A7)		; protocol	= disable handshake
		MOVE.W #0,-(A7)		; prescale	= 1
		MOVE.W #0,-(A7)		; srclk		= 25.175
		MOVE.W #8,-(A7)		; dst		= dac
		MOVE.W #1,-(A7)		; src		= dspxmit
		MOVE.W #$8B,-(A7)	; devconnect
		TRAP #14
		LEA 12(A7),A7
		MOVE.W #0,-(A7)		; tristate dsprec
		MOVE.W #1,-(A7)		; enable   dspxmit
		MOVE.W #$89,-(A7)	; dsptristate
		TRAP #14
		ADDQ.W #6,A7	

		MOVE.W #1,-(A7)	; ability
		MOVE.L #((DspProgEnd-DspProg)/3),-(A7)	; no. of dsp words
		PEA DspProg(PC)	; buf
		MOVE.W #$6E,-(A7)	; dsp_execboot
		TRAP #14
		LEA 12(A7),A7
		MOVE.W SR,-(SP)
		MOVE.W #$2700,SR
		BCLR #3,$fffffa17.W
		CLR.B $fffffa19.w
		MOVE.L #music_int,$134.W
		BSET #5,$fffffa07.W
		BSET #5,$fffffa13.W
		MOVE.B #freq,$fffffa1f.W
		MOVE.B #7,$fffffa19.W
		MOVE.W (SP)+,SR
		RTS

; Music Interrupt

music_int	TAS.B player_sem
		BNE .out
		MOVEM.L	A0-A6/D0-D7,-(A7)
		MOVE.L $FFFF9800.W,-(SP)
		MOVE.L #$F7000000,$FFFF9800.W
		MOVE.B #%00000000,$FFFFA200.W	; interrupt mode
		BSET.B #7,$FFFFA200.W
		BCLR.B #7,$FFFFA201.W
		MOVE.B #19,$FFFFA201.W		; host command 2
		BSET.B #7,$FFFFA201.W
		LEA $FFFFA207.W,A6		; point to lsbyte
.wait1		BTST.B #1,$FFFFA202.W
		BEQ.S .wait1
		MOVE.L #int_flag,$FFFFA204.W	; signal dsp to go!
		MOVE.W #$2500,SR
		MOVEQ #0,D7
		LEA ch1s(PC),A1
		MOVEQ #0,D6
		BSR.S send_voice
		LEA ch2s(PC),A1
		MOVEQ #1,D6
		BSR.S send_voice
		LEA ch3s(PC),A1
		MOVEQ #2,D6
		BSR.S send_voice
		LEA ch4s(PC),A1
		MOVEQ #3,D6
		BSR.S send_voice
		Lea Module,A0
		BSR pp_Music
		;clr.w ch1s+sam_vol
		;clr.w ch2s+sam_vol
		;clr.w ch3s+sam_vol
		;clr.w ch4s+sam_vol
.wait		BTST #0,$FFFFA202.W		 
		BEQ.S .wait			 
		TST.W $FFFFA206.W		
		MOVE.L (SP)+,$FFFF9800.W
		MOVEM.L	(A7)+,A0-A6/D0-D7
.out		;BCLR.B #5,$FFFFFA0F.W
		SF player_sem
		RTE
player_sem	DC.W 0

; Send 1 voice to the dsp.

send_voice	
.setup_paula	MOVE.L sam_start(A1),D2
		BEQ.S .nosetnewmains
		MOVE.L D2,cur_start(A1)
		MOVE.L D2,cur_lpstart(A1)
		MOVE.L D2,cur_pos(A1)
		MOVE.L #0,sam_start(A1)
		SF cur_lpflag(A1)
.nosetnewmains	MOVEQ #0,D0
		MOVE.W sam_length(A1),D0
		BMI.S .nosetnewmainl
		CMP.W #1,D0
		BNE.S .ok
		MOVEQ #0,D0
.ok		MOVE.L cur_start(A1),D2
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
		CMP.W #1,D0
		BNE.S .ok1
		MOVEQ #0,D0
.ok1		MOVE.L cur_lpstart(A1),D2
		ADD.L D0,D0
		ADD.L D0,D2
		MOVE.L D2,cur_lpend(A1)
		MOVE.W #-1,sam_lplength(A1)
.nosetnewloopl	
		MOVEQ #0,D0
		MOVE.W sam_vol(A1),d0
		CMP.W #$40,D0
		BLS.S .volok
		MOVEQ #$40,D0
.volok		SWAP D0
.wait1		BTST #1,-5(A6)			;; sync 
		BEQ.S .wait1			;; 
		MOVE.L D0,-3(A6)		; send volume
		MOVEQ #0,D0
		MOVEQ #0,D1
		MOVE.W sam_period(A1),D0
		BEQ.S .zero
		MOVE.L #$24665268,D1
		DIVU.L D0,D1
		CMP.L #$7fffff,D1		; limit frequency
		BLE.S .zero			; (shouldnt happen!)
		MOVE.L #$7fffff,D1		; 
.zero		MOVE.L D1,-3(a6)		; send freq
.wait2		BTST #0,-5(A6)			;; sync 
		BEQ.S .wait2			;; 
		MOVE.L -3(A6),D5		; get no. of samples
		CLR.W -2(a6)			; clear top 16 msbits
		BTST D6,shadow_dmacon+1		; voice dma on?
		BEQ dmaisoff			; no, then send zeros...
 
		MOVE.L cur_end(A1),A2
		MOVE.L cur_lpend(A1),A3
		MOVE.L cur_pos(A1),A0		; current voice address
		MOVE.L cur_start(A1),A4
		MOVE.L cur_lpstart(A1),A5
		MOVE.B cur_lpflag(A1),D3
do_vce		TST.B D3		; sample looping?
		BNE.S in_loop
in_main		CMP.L A4,A2		; sample start = sample end?
		BLE.S vce_isoffcont
		BRA.S vc_main_cont
in_loop		CMP.L A5,A3
		BLE.S vce_isoffcont
		BRA.S vclp_cont
vc_main_lp	
.wait		BTST.B #1,-5(A6)
		BEQ.S .wait
		MOVE.B (A0)+,(A6)
vc_main_cont	CMP.L A2,A0
		DBEQ D5,vc_main_lp
		BNE.S vce_done
hit_looppoint	ST D3
		MOVE.L A5,A0
		CMP.L A5,A3
		BLE.S vce_isoffcont
		BRA.S vclp_cont
vc_loop_lp	
.wait		BTST.B #1,-5(A6)
		BEQ.S .wait
		MOVE.B (A0)+,(A6)
vclp_cont	CMP.L A3,A0
		DBEQ D5,vc_loop_lp
		BNE.S vce_done
vclp_resetlp	MOVE.L A5,A0
		DBF D5,vc_loop_lp
vce_done
.wait		BTST.B #1,-5(A6)
		BEQ.S .wait
		MOVE.B (A0),(A6)
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

; Paula emulation storage structure.


ch1s		DS.B sam_vcsize
ch2s		DS.B sam_vcsize			; shadow channel regs
ch3s		DS.B sam_vcsize
ch4s		DS.B sam_vcsize
shadow_dmacon	DS.W 1

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

global_vol	dc.w 0
music_on	dc.w 0

*********************************************************************
*							            *
*                 -=+ ProPacker routines V1.0A +=-                  *
*							            *
* Made by: Azatoth/Pha     Created: 91-07-11  Last change: 92-04-16 *
*							            *
*********************************************************************

; Note:
; This is version A with regsets from irqs !!!
; Interrupts must be enabled !!!
; Some commands are not implemented yet !!!
; There is much left to optimize !!!
; This replay can easily be made pc-independent
; For speed reasons vibrato and tremolo must 
; always be set with both parameters !!!
; Assembled with AsmOne1.07b !!!

		RSRESET
pc_Command	rs.l	1			Channel structure
pc_Start	rs.l	1
pc_Length	rs.w	1
pc_LoopStart	rs.l	1
pc_RepLen	rs.w	1
pc_Period	rs.w	1
pc_FineTune	rs.b	1
pc_Volume	rs.b	1
pc_DmaBit	rs.w	1
pc_PortSpeed	rs.w	1
pc_WantedPeriod	rs.w	1
pc_VibratoCmd	rs.b	1
pc_VibratoPos	rs.b	1
pc_TremoloCmd	rs.b	1
pc_TremoloPos	rs.b	1
pc_WaveControl	rs.b	1
pc_GlissFunk	rs.b	1
pc_SamOffset	rs.b	1
pc_PattPos	rs.b	1
pc_LoopCount	rs.b	1
pc_FuncOffset	rs.b	1
pc_WaveStart	rs.l	1
pc_PackCnt	rs.w	1
pc_FnTOffset	rs.w	1
pc_SizeOff	rs.w	0

		RSRESET
ps_Length	rs.w	1			Sample data structure
ps_FineTune	rs.b	1
ps_Volume	rs.b	1
ps_Restart	rs.w	1
ps_RepLen	rs.w	1
ps_SamOffset	rs.l	1
ps_FnTOffset	rs.w	1
ps_SizeOff	rs.b	0

		RSRESET
pm_SamData	rs.b	31*ps_SizeOff		Main structure
pm_SongPos	rs.w	1
pm_SongLength	rs.w	1
pm_PattCnt	rs.w	1
pm_Speed	rs.b	1
pm_Counter	rs.b	1
pm_PlayAdr	rs.l	1
pm_RetrigInd	rs.w	1
pm_PattPoses	rs.l	128
pm_PattData	rs.b	0

********************** ProPacker init routine ***********************
* a0.l <= Module

pp_Init		clr.w pm_SongPos(a0)			;
		move	#64,pm_PattCnt(a0)		;
		clr	pp_Chn1Struct+pc_PackCnt	;
		clr	pp_Chn2Struct+pc_PackCnt	;
		clr	pp_Chn3Struct+pc_PackCnt	;
		clr	pp_Chn4Struct+pc_PackCnt	;

		move	pm_SongLength(a0),pp_SongLength+2
		move	pm_SongPos(a0),d1
		lea	pm_PattPoses(a0),a1
		move.l	(a1,d1.w),d0
		lea	(a0,d0.l),a1
		move.l	a1,pm_PlayAdr(a0)
		clr	pm_RetrigInd(a0)
		rts

********************** ProPacker end routine ************************

pp_End		
		rts

********************* ProPacker replay routine **********************
* a0.l <= Module			       Used regs: d0-d7/a1-a5
* a6.l <= CustomBase

pp_Music	subq.b	#1,pm_Counter(a0)
		bhi	pp_NoNotes

		move.l	pm_PlayAdr(a0),a2
		move	#$8000,pp_DmaconTemp
		lea	pp_Chn1Struct(pc),a1
		lea	ch1s,a5
		bsr	pp_PlayVoice
		lea	pp_Chn2Struct(pc),a1
		lea	ch2s,a5
		bsr	pp_PlayVoice
		lea	pp_Chn3Struct(pc),a1
		lea	ch3s,a5
		bsr	pp_PlayVoice
		lea	pp_Chn4Struct(pc),a1
		lea	ch4s,a5
		bsr	pp_PlayVoice
		move.l	a2,pm_PlayAdr(a0)
		
;		move.b	#$19,$bfde00

		subq	#1,pm_PattCnt(a0)
		bgt.s	pp_Return
		move	#64,pm_PattCnt(a0)
		clr	pp_Chn1Struct+pc_PackCnt
		clr	pp_Chn2Struct+pc_PackCnt
		clr	pp_Chn3Struct+pc_PackCnt
		clr	pp_Chn4Struct+pc_PackCnt	
		addq	#4,pm_SongPos(a0)
pp_SongLength	cmp	#$0000,pm_SongPos(a0)
		blo.s	pp_NotEOS
		clr	pm_SongPos(a0)
pp_NotEOS	lea	pm_PattPoses(a0),a1
		add	pm_SongPos(a0),a1
		move.l	(a1),d0
		lea	(a0,d0.l),a1
		move.l	a1,pm_PlayAdr(a0)

pp_Return	move.b	pm_Speed(a0),pm_Counter(a0)
		move_dmacon pp_DmaconTemp
		move.l	pp_Chn1Struct+pc_LoopStart(pc),ch1s+sam_lpstart
		move.l	pp_Chn2Struct+pc_LoopStart(pc),ch2s+sam_lpstart
		move.l	pp_Chn3Struct+pc_LoopStart(pc),ch3s+sam_lpstart
		move.l	pp_Chn4Struct+pc_LoopStart(pc),ch4s+sam_lpstart
		move	pp_Chn1Struct+pc_RepLen(pc),ch1s+sam_lplength
		move	pp_Chn2Struct+pc_RepLen(pc),ch2s+sam_lplength
		move	pp_Chn3Struct+pc_RepLen(pc),ch3s+sam_lplength
		move	pp_Chn4Struct+pc_RepLen(pc),ch4s+sam_lplength
	
		rts

pp_NoNotes	lea	pp_Chn1Struct(pc),a1		Effects
		lea	ch1s,a5
		moveq	#4-1,d7
pp_CmdLoop2	move.b	pc_Command+2(a1),d0
		and	#$f,d0
		add	d0,d0
		move	pp_Every(pc,d0.w),d0
		moveq	#0,d1
		move.b	pc_Command+3(a1),d1
		jsr	pp_Every(pc,d0.w)
		add	#pc_SizeOff,a1
		lea	sam_vcsize(a5),a5
		dbf	d7,pp_CmdLoop2

;		move.b	pm_RetrigInd(a0),$bfde00
		clr	pm_RetrigInd(a0)
		rts

*********************************************************************

pp_Every	dc.w	pp_Arpeggio-pp_Every
		dc.w	pp_PortUp-pp_Every
		dc.w	pp_PortDown-pp_Every
		dc.w	pp_TonePort-pp_Every
		dc.w	pp_Vibrato-pp_Every
		dc.w	pp_PortSlide-pp_Every
		dc.w	pp_VibSlide-pp_Every
		dc.w	pp_Tremolo-pp_Every
		dc.w	pp_NotImp-pp_Every
		dc.w	pp_NotImp-pp_Every
		dc.w	pp_VolSlide-pp_Every
		dc.w	pp_NotImp-pp_Every
		dc.w	pp_NotImp-pp_Every
		dc.w	pp_NotImp-pp_Every
		dc.w	pp_ECmds1-pp_Every
		dc.w	pp_NotImp-pp_Every


pp_DmaconTemp	dc.w	0
pp_Chn1Struct	dc.l	0,0,0,0,0,$00010000,0,0,0,0,0
pp_Chn2Struct	dc.l	0,0,0,0,0,$00020000,0,0,0,0,0
pp_Chn3Struct	dc.l	0,0,0,0,0,$00040000,0,0,0,0,0
pp_Chn4Struct	dc.l	0,0,0,0,0,$00080000,0,0,0,0,0

**************************** PlayVoice ******************************
* a0.l <= Module			       Used regs: d0-d6/a0-a4
* a1.l <= Channel struct (AutoAdded)
* a2.l <= Play data	 (AutoAdded)
* a5.l <= Sound regs	 (AutoAdded)
* a6.l <= CustomBase

ere		move_dmacon	d0
		rts

pp_MulList	dc.w	00*ps_SizeOff,01*ps_SizeOff,02*ps_SizeOff,03*ps_SizeOff
		dc.w	04*ps_SizeOff,05*ps_SizeOff,06*ps_SizeOff,07*ps_SizeOff
		dc.w	08*ps_SizeOff,09*ps_SizeOff,10*ps_SizeOff,11*ps_SizeOff
		dc.w	12*ps_SizeOff,13*ps_SizeOff,14*ps_SizeOff,15*ps_SizeOff
		dc.w	16*ps_SizeOff,17*ps_SizeOff,18*ps_SizeOff,19*ps_SizeOff
		dc.w	20*ps_SizeOff,21*ps_SizeOff,22*ps_SizeOff,23*ps_SizeOff
		dc.w	24*ps_SizeOff,25*ps_SizeOff,26*ps_SizeOff,27*ps_SizeOff
		dc.w	28*ps_SizeOff,29*ps_SizeOff,30*ps_SizeOff,31*ps_SizeOff

pp_PlayVoice	addq	#1,pc_PackCnt(a1)
		blt.s	pp_NoNew
		move.l	(a2)+,pc_Command(a1)
		tst	(a2)
		bge.s	pp_NoNew
		move	(a2)+,pc_PackCnt(a1)
pp_NoNew	move.b	pc_Command+0(a1),d0
		beq	pp_NoSample
		ext	d0
		add	d0,d0
		move	pp_MulList(pc,d0.w),d0
		lea	pm_SamData-ps_SizeOff(a0,d0.w),a3
		move.l	ps_SamOffset(a3),d1
		lea	(a0,d1.l),a4
		move.l	a4,pc_Start(a1)
		move	ps_Length(a3),pc_Length(a1)
		move	ps_FnTOffset(a3),pc_FnTOffset(a1)
		move.b	ps_Volume(a3),pc_Volume(a1)
		move	ps_Restart(a3),d0
		beq.s	pp_NoLoop
		add	d0,a4
		add	d0,a4
		add	ps_RepLen(a3),d0
		move	d0,pc_Length(a1)
pp_NoLoop	move.l	a4,pc_LoopStart(a1)
		move	ps_RepLen(a3),pc_RepLen(a1)
		move.b	pc_Volume(a1),9(a5)

pp_NoSample	move.b	pc_Command+1(a1),d2
		beq.s	pp_NoNote

		ext	d2
		add	pc_FnTOffset(a1),d2

		move.b	pc_Command+2(a1),d0
		and.b	#$f,d0
		move	pp_PeriodTable-2(pc,d2.w),d2
		subq.b	#3,d0
		beq	pp_SetPort
		subq.b	#2,d0
		beq	pp_SetPort
		move	d2,pc_Period(a1)
		subq.b	#4,d0
		bne.s	pp_NoSamOffset
		bsr	pp_SamOffset
pp_NoSamOffset	move	pc_Command+2(a1),d0
		and	#$0ff0,d0
		cmp	#$0ed0,d0
		beq.s	pp_GoHome

		move	pc_DmaBit(a1),d0
		or	d0,pp_DmaconTemp
		bsr ere
		move.l	pc_Start(a1),(a5)
		move	pc_Length(a1),4(a5)
pp_NoNote	move	pc_Period(a1),6(a5)

		move.b	pc_Command+2(a1),d0
		and	#$f,d0
		add	d0,d0
		move	pp_Note(pc,d0.w),d0
		moveq	#0,d1
		move.b	pc_Command+3(a1),d1
		jmp	pp_Note(pc,d0.w)


pp_Note		dc.w	pp_NotImp-pp_Note
		dc.w	pp_NotImp-pp_Note
		dc.w	pp_NotImp-pp_Note
		dc.w	pp_TonePort-pp_Note
		dc.w	pp_NotImp-pp_Note
		dc.w	pp_TonePort-pp_Note
		dc.w	pp_VibSlide-pp_Note
		dc.w	pp_NotImp-pp_Note
		dc.w	pp_NotImp-pp_Note
		dc.w	pp_NotImp-pp_Note
		dc.w	pp_NotImp-pp_Note
		dc.w	pp_PosJump-pp_Note
		dc.w	pp_SetVolume-pp_Note
		dc.w	pp_PattBrk-pp_Note
		dc.w	pp_ECmds2-pp_Note
		dc.w	pp_SetSpeed-pp_Note

pp_GoHome	rts

		;	C   C#  D   D#  E   F   F#  G   G#  A   A#  H  	Oct FnT
		
pp_PeriodTable	dc.w	856,808,762,720,678,640,604,570,538,508,480,453   1   1
		dc.w	428,404,381,360,339,320,302,285,269,254,240,226   2
		dc.w	214,202,190,180,170,160,151,143,135,127,120,113   3
		dc.w	850,802,757,715,674,637,601,567,535,505,477,450	  1   2
		dc.w	425,401,379,357,337,318,300,284,268,253,239,225   2
		dc.w	213,201,189,179,169,159,150,142,134,126,119,113   3
		dc.w	844,796,752,709,670,632,597,563,532,502,474,447   o   3
		dc.w	422,398,376,355,335,316,298,282,266,251,237,224   s
		dc.w	211,199,188,177,167,158,149,141,133,125,118,112   v
		dc.w	838,791,746,704,665,628,592,559,528,498,470,444       4
		dc.w	419,395,373,352,332,314,296,280,264,249,235,222
		dc.w	209,198,187,176,166,157,148,140,132,125,118,111
		dc.w	832,785,741,699,660,623,588,555,524,495,467,441       5
		dc.w	416,392,370,350,330,312,294,278,262,247,233,220
		dc.w	208,196,185,175,165,156,147,139,131,124,117,110
		dc.w	826,779,736,694,655,619,584,551,520,491,463,437       6
		dc.w	413,390,368,347,328,309,292,276,260,245,232,219
		dc.w	206,195,184,174,164,155,146,138,130,123,116,109
		dc.w	820,774,730,689,651,614,580,547,516,487,460,434       7
		dc.w	410,387,365,345,325,307,290,274,258,244,230,217       
		dc.w	205,193,183,172,163,154,145,137,129,122,115,109
		dc.w	814,768,725,684,646,610,575,543,513,484,457,431      -8
		dc.w	407,384,363,342,323,305,288,272,256,242,228,216
		dc.w	204,192,181,171,161,152,144,136,128,121,114,108
		dc.w	907,856,808,762,720,678,640,604,570,538,508,480      -9
		dc.w	453,428,404,381,360,339,320,302,285,269,254,240
		dc.w	226,214,202,190,180,170,160,151,143,135,127,120
		dc.w	900,850,802,757,715,675,636,601,567,535,505,477     -10
		dc.w	450,425,401,379,357,337,318,300,284,268,253,238
		dc.w	225,212,200,189,179,169,159,150,142,134,126,119
		dc.w	894,844,796,752,709,670,632,597,563,532,502,474     -11
		dc.w	447,422,398,376,355,335,316,298,282,266,251,237
		dc.w	223,211,199,188,177,167,158,149,141,133,125,118
		dc.w	887,838,791,746,704,665,628,592,559,528,498,470     -12
		dc.w	444,419,395,373,352,332,314,296,280,264,249,235
		dc.w	222,209,198,187,176,166,157,148,140,132,125,118
		dc.w	881,832,785,741,699,660,623,588,555,524,494,467     -13
		dc.w	441,416,392,370,350,330,312,294,278,262,247,233
		dc.w	220,208,196,185,175,165,156,147,139,131,123,117
		dc.w	875,826,779,736,694,655,619,584,551,520,491,463     -14
		dc.w	437,413,390,368,347,328,309,292,276,260,245,232
		dc.w	219,206,195,184,174,164,155,146,138,130,123,116
		dc.w	868,820,774,730,689,651,614,580,547,516,487,460     -15
		dc.w	434,410,387,365,345,325,307,290,274,258,244,230
		dc.w	217,205,193,183,172,163,154,145,137,129,122,115
		dc.w	862,814,768,725,684,646,610,575,543,513,484,457     -16
		dc.w	431,407,384,363,342,323,305,288,272,256,242,228
		dc.w	216,203,192,181,171,161,152,144,136,128,121,114

****************************** Commands *****************************
* d1.w <= Command byte
* a0.l <= Module			       Used regs: d0-d6/a3-a4
* a1.l <= Channel struct
* a5.l <= Sound regs
* a6.l <= CustomBase
* sr.? <= tst.b d1

pp_Arpeggio	beq	pp_NoArp
		moveq	#0,d0
		move.b	pm_Speed(a0),d0
		subq.b	#1,d0
		sub.b	pm_Counter(a0),d0
		divs	#3,d0
		swap	d0
		tst	d0
		beq.s	pp_Arpeggio2
		cmp	#2,d0
		beq.s	pp_Arpeggio1
		moveq	#0,d0
		move.b	d1,d0
		lsr.b	#4,d0
		bra.s	pp_Arpeggio3
pp_Arpeggio1	moveq	#0,d0
		move.b	d1,d0
		and.b	#$f,d0
		bra.s	pp_Arpeggio3
pp_Arpeggio2	move	pc_Period(a1),d2
		bra.s	pp_Arpeggio4
pp_Arpeggio3	add	d0,d0
		moveq	#0,d1
		move.b	pc_FineTune(a1),d1
		mulu	#2*36,d1
		lea	pp_PeriodTable(pc),a4
		add.l	d1,a4
		moveq	#0,d1
		move	pc_Period(a1),d1
		moveq	#36-1,d6
pp_arploop	move	(a4,d0.w),d2
		cmp	(a4),d1
		bhs.s	pp_Arpeggio4
		addq	#2,a4
		dbf	d6,pp_arploop
pp_NoArp	rts
pp_Arpeggio4	move	d2,6(a5)
		rts

pp_PortUp	sub	d1,pc_Period(a1)
		cmp	#113,pc_Period(a1)
		bpl.s	.NotMin
		move	#113,pc_Period(a1)
.NotMin		move	pc_Period(a1),6(a5)
		rts

pp_PortDown	add	d1,pc_Period(a1)
		cmp	#856,pc_Period(a1)
		bmi.s	.NotMax
		move	#856,pc_Period(a1)
.NotMax		move	pc_Period(a1),6(a5)
		rts

pp_SetPort	move	d2,pc_WantedPeriod(a1)
		rts

pp_PortSlide	bsr	pp_VolSlide
		tst.b	d1
pp_TonePort	beq.s	.PortNoChange
		move	d1,pc_PortSpeed(a1)
.PortNoChange	move	pc_PortSpeed(a1),d0
		move	pc_WantedPeriod(a1),d2
		sub	pc_Period(a1),d2
		beq.s	.Return
		bgt.s	.Pos		
		neg	d2
		sub	d0,pc_Period(a1)
		bra.s	.Continue
.Pos		add	d0,pc_Period(a1)
.Continue	cmp	d0,d2
		bge.s	.SlideMore
		move	pc_WantedPeriod(a1),pc_Period(a1)
.SlideMore	move	pc_Period(a1),6(a5)
.Return		rts

pp_Vibrato	beq.s	pp_NoParas1
		move.b	d1,pc_VibratoCmd(a1)
pp_NoParas1	move.b	pc_VibratoPos(a1),d0
		lsr	#2,d0
		and	#$1f,d0
		moveq	#0,d2
		move.b	pp_VibratoTable(pc,d0.w),d2
		move.b	pc_VibratoCmd(a1),d3
		move	d3,d4
		and	#$f,d3
		mulu	d3,d2
		lsr	#7,d2
		tst.b	pc_VibratoPos(a1)
		bpl.s	pp_NoNeg
		neg	d2
pp_NoNeg	add	pc_Period(a1),d2
		move	d2,6(a5)
		lsr.b	#2,d4
		and	#$3c,d4
		add.b	d4,pc_VibratoPos(a1)
		rts

pp_Tremolo	beq.s	pp_NoParas2
		move.b	d1,pc_TremoloCmd(a1)
pp_NoParas2	move.b	pc_TremoloPos(a1),d0
		lsr	#2,d0
		and	#$1f,d0
		moveq	#0,d2
		move.b	pp_VibratoTable(pc,d0.w),d2
		move.b	pc_TremoloCmd(a1),d3
		move	d3,d4
		and	#$f,d3
		mulu	d3,d2
		lsr	#7,d2
		tst.b	pc_TremoloPos(a1)
		bmi.s	pp_TreSub
		neg	d2
pp_TreSub	neg	d2
 		add.b	pc_Volume(a1),d2
		bge.s	pp_TreOk1
		clr	d2
pp_TreOk1	cmp.b	#$40,d2
		ble.s	pp_TreOk2
		moveq	#$40,d2
pp_TreOk2	move	d2,8(a5)
		lsr.b	#2,d4
		and	#$3c,d4
		add.b	d4,pc_TremoloPos(a1)
		rts

pp_VibratoTable	dc.b 	0,24,49,74,97,120,141,161,180,197,212,224,235,244,250
		dc.b	253,255,253,250,244,235,224,212,197,180,161,141,120,97
		dc.b	74,49,24

pp_VibSlide	bsr	pp_NoParas1
pp_VolSlide	move.b	d1,d0
		lsr.b	#4,d1
		beq.s	pp_VolSlideDown
pp_VolSlideUp	add.b	d1,pc_Volume(a1)
		cmp.b	#$40,pc_Volume(a1)
		bmi.s	pp_vsdskip
		move.b	#$40,pc_Volume(a1)
		bra.s	pp_vsdskip
pp_VolSlideDown	and.b	#$f,d0
		sub.b	d0,pc_Volume(a1)
		bpl.s	pp_vsdskip
		clr.b	pc_Volume(a1)
pp_vsdskip	move.b	pc_Volume(a1),8(a5)
		rts

pp_SetVolume	move.b	d1,pc_Volume(a1)
		move	d1,8(a5)
		rts

pp_PosJump	add	d1,d1
		add	d1,d1
		move	d1,pm_SongPos(a0)
pp_PattBrk	clr	pm_PattCnt(a0)
		rts

pp_SetSpeed	move.b	d1,pm_Speed(a0)
		rts

pp_SamOffset	move.b	pc_Command+3(a1),d1
		beq	pp_NoNew1
		move.b	d1,pc_SamOffset(a1)
pp_NoNew1	moveq	#0,d1
		move.b	pc_SamOffset(a1),d1
		lsl	#7,d1
		sub	d1,pc_Length(a1)
		add	d1,d1
		add.l	d1,pc_Start(a1)
		rts

pp_ECmds1	move	d1,d0
		lsr	#4,d0
		add	d0,d0
		move	pp_ECmdList1(pc,d0.w),d0
		and	#$f,d1
		jmp	pp_ECmdList1(pc,d0.w)

pp_ECmdList1	dc.w	pp_Filter-pp_ECmdList1
		dc.w	pp_NotImp-pp_ECmdList1
		dc.w	pp_NotImp-pp_ECmdList1
		dc.w	pp_NotImp-pp_ECmdList1
		dc.w	pp_NotImp-pp_ECmdList1
		dc.w	pp_SetFnTune-pp_ECmdList1
		dc.w	pp_NotImp-pp_ECmdList1
		dc.w	pp_NotImp-pp_ECmdList1
		dc.w	pp_NotImp-pp_ECmdList1
		dc.w	pp_RetrigNote-pp_ECmdList1
		dc.w	pp_NotImp-pp_ECmdList1
		dc.w	pp_NotImp-pp_ECmdList1
		dc.w	pp_NoteCut-pp_ECmdList1
		dc.w	pp_NoteDelay-pp_ECmdList1
		dc.w	pp_NotImp-pp_ECmdList1
		dc.w	pp_NotImp-pp_ECmdList1

pp_ECmds2	move	d1,d0
		lsr	#4,d0
		add	d0,d0
		move	pp_ECmdList2(pc,d0.w),d0
		and	#$f,d1
		jmp	pp_ECmdList2(pc,d0.w)

pp_ECmdList2	dc.w	pp_Filter-pp_ECmdList2
		dc.w	pp_PortUp-pp_ECmdList2
		dc.w	pp_PortDown-pp_ECmdList2
		dc.w	pp_NotImp-pp_ECmdList2
		dc.w	pp_NotImp-pp_ECmdList2
		dc.w	pp_SetFnTune-pp_ECmdList2
		dc.w	pp_NotImp-pp_ECmdList2
		dc.w	pp_NotImp-pp_ECmdList2
		dc.w	pp_NotImp-pp_ECmdList2
		dc.w	pp_RetrigNote-pp_ECmdList2
		dc.w	pp_VolSlideUp-pp_ECmdList2
		dc.w	pp_VolFineDown-pp_ECmdList2
		dc.w	pp_NoteCut-pp_ECmdList2
		dc.w	pp_NoteDelay-pp_ECmdList2
		dc.w	pp_NotImp-pp_ECmdList2
		dc.w	pp_NotImp-pp_ECmdList2

pp_Filter	add.b	d1,d1
		and.b	#$fd,$bfe001
		or.b	d1,$bfe001
		rts	

pp_SetFnTune	move	d1,d0
		lsl	#6,d0
		lsl	#3,d1
		add	d0,d1
		move	d1,pc_FnTOffset(a1)
		rts

pp_VolFineDown	move	d1,d0
		bra	pp_VolSlideDown

pp_NoteCut	move.b	pm_Speed(a0),d0
		sub.b	pm_Counter(a0),d0
		cmp.b	d0,d1
		bne.s	pp_NoCut
		clr.b	pc_Volume(a1)
		move	#0,8(a5)
pp_NoCut	rts

pp_RetrigNote	beq.s	pp_GetBack
		moveq	#0,d0
		move.b	pm_Speed(a0),d0
		sub.b	pm_Counter(a0),d0
		divu	d1,d0
		swap	d0
		tst	d0
		bne.s	pp_GetBack
		move	pc_DmaBit(a1),d1
		move_dmacon	d1
		or	d1,pp_DmaconTemp
		move.l	pc_Start(a1),(a5)
		move	pc_Length(a1),4(a5)
		move	pc_Period(a1),6(a5)
		move.b	#$19,pm_RetrigInd(a0)
pp_GetBack	rts

pp_NoteDelay	move.b	pm_Speed(a0),d0
		sub.b	pm_Counter(a0),d0
		cmp.b	d0,d1
		bne	pp_NoDelay
		move	pc_DmaBit(a1),d1
		move_dmacon	d1
		or	d1,pp_DmaconTemp
		move.l	pc_Start(a1),(a5)
		move	pc_Length(a1),4(a5)
		move	pc_Period(a1),6(a5)
		move.b	#$19,pm_RetrigInd(a0)
pp_NoDelay	rts

pp_NotImp	rts

******************* End of ProPacker routines ***********************
*********************************************************************

Old_A		DC.L 0
Old_19		DC.B 0
Old_1f		DC.B 0
		EVEN

; Dsp Code

DspProg		incbin dspaula.bin
DspProgEnd
		EVEN

Module		INCBIN "INGAME.pp"
