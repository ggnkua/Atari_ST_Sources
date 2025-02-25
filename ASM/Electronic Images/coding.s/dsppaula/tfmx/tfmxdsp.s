;-----------------------------------------------------------------------;
; 50khz 4 channel ProTracker Player using DSP. (interpolated)		;
; By Martin Griffiths (C) June-August 1993				;
; Paula Emulator 2.0b!! (about 15 scanlines...)				;
;-----------------------------------------------------------------------;

		clr.l	-(a7)
		move.w	#$20,-(a7)
		trap	#1			; supervisor
		addq.l #6,sp
		move.l d0,savesp
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

; The Player.

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

freq		EQU 246			; timer a frequency
extra_samps	EQU 3			; safety margin extra bytes

M_Setup		BRA.W Setup_Module 
M_On		BRA.W Start_music 
M_Off		BRA.W Stop_music 

Setup_Module	
init_tfmx1	Lea T2_Song,a0
		Move.l	a0,d0
		Lea T2_Smpl,a0
		Move.l	a0,d1
		Bsr T2_Replay+$14
		Bsr T2_Replay+$8
		Moveq	#0,d0		; Tune Number
		Bsr T2_Replay+$c

		MOVE.W #1,-(A7)		; 16 bit stereo
		MOVE.W #$84,-(A7)	; setmode
		TRAP #14
		ADDQ.L #4,A7
		RTS

Stop_music	MOVE.L Old_A(PC),$134.W
		MOVE.B Old_19(PC),$fffffa19.W
		MOVE.B Old_1f(PC),$fffffa1f.W
		BCLR #5,$fffffa07.W
		BCLR #5,$fffffa13.W
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

music_int	MOVE.W #$2500,SR
		MOVEM.L	A0-A6/D0-D7,-(A7)
		MOVE.L $FFFF9800.W,-(SP)
		MOVE.L #$F7000000,$FFFF9800.W
		MOVEQ #0,D7
		MOVE.W D7,$FFFFA206.W	; strobe -> signal dsp to go!
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

		MOVE.W shadow_dff09c,d0
		and.W shadow_dff09a,d0
		btst #0,d0
		beq.s .1
		LEA ch1s(PC),A1
		LEA     L00B8(PC),A5
		MOVE.B cur_lpflag(A1),(A5)
.1		btst #1,d0
		beq.s .2

		LEA ch2s(PC),A1
		  LEA     L00B9(PC),A5
		MOVE.B cur_lpflag(A1),(A5)
.2		btst #2,d0
		beq.s .3

		LEA ch3s(PC),A1
  		LEA     L00BA(PC),A5
		MOVE.B cur_lpflag(A1),(A5)
.3		btst #3,d0
		beq.s .4

		LEA ch4s(PC),A1
  		LEA     L00BB(PC),A5
		MOVE.B cur_lpflag(A1),(A5)
.4
		BSR Play_T2	

		MOVE.L (SP)+,$FFFF9800.W
		MOVEM.L	(A7)+,A0-A6/D0-D7
		RTE

; Send 1 voice to the dsp.

send_voice	LEA $ffffa204.w,A6		
		MOVEQ #0,D0
		MOVE.W sam_vol(A1),d0
		CMP.W #$40,D0
		BLS.S .volok
		MOVEQ #$40,D0
.volok		SWAP D0
.wait1		BTST #1,$FFFFA202.W		;; sync 
		BEQ.S .wait1			;; 
		MOVE.L D0,(A6)			; send volume
		MOVEQ #0,D0
		MOVEQ #0,D1
		MOVE.W sam_period(A1),D0
		BEQ.S .zero
		MOVE.L #$24665268,D1
		DIVU.L D0,D1
		cmp.l #$7fffff,d1		; limit frequency
		ble.s .zero			; (shouldnt happen!)
		move.l #$7fffff,d1		; 
.zero		MOVE.L D1,(a6)			; send freq
.wait2		BTST #0,$FFFFA202.W		;; sync 
		BEQ.S .wait2			;; 
		MOVE.L (A6),D5			; get no. of samples
		ADDQ #extra_samps,D5		; + extra
		MOVE.W shadow_dmacon(PC),D3	; dma control (!)
		MOVE.L D5,(A6)			; send no. of samples to do.

.setup_paula	MOVE.L sam_start(A1),D2
		BMI.S .nosetnewmains
		MOVE.L D2,cur_start(A1)
		MOVE.L D2,cur_lpstart(A1)
		MOVE.L D2,cur_pos(A1)
		MOVE.L #-1,sam_start(A1)
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
		BMI.S .nosetnewloops
		MOVE.L D2,cur_lpstart(A1)
		MOVE.L #-1,sam_lpstart(A1)
.nosetnewloops	MOVEQ #0,D0
		MOVE.W sam_lplength(A1),D0
		BMI.S .nosetnewloopl
		MOVE.L cur_lpstart(A1),D2
		ADD.L D0,D0
		ADD.L D0,D2
		MOVE.L D2,cur_lpend(A1)
		MOVE.W #-1,sam_lplength(A1)
.nosetnewloopl	
		CLR.W 1(a6)			; clear top 16 msbits
		SUBQ.W #extra_samps,D5
		LEA $FFFFA207.W,A6		; point to lsbyte
		BTST D6,D3			; voice dma on?
		BEQ dmaisoff			; no, then send zeros...
 
		MOVE.L cur_end(A1),A2
		MOVE.L cur_lpend(A1),A3
		MOVE.L cur_pos(A1),A0		; current voice address
		MOVE.L cur_start(A1),A4
		MOVE.L cur_lpstart(A1),A5
		MOVE.B cur_lpflag(A1),D3
		BSR.S do_vce
		MOVE.B D3,cur_lpflag(A1)
		MOVE.L A0,cur_pos(A1)	; store new address
		MOVEQ #extra_samps,D5

do_vce		TST.B D3		; sample looping?
		BEQ.S vc_main_cont
		BRA.S vclp_cont

vc_main_lp	MOVE.B (A0)+,(A6)
vc_main_cont	CMP.L A2,A0
		DBGE D5,vc_main_lp
		BLT.S vce_done
hit_looppoint	ST D3 
		MOVE.L A5,A0
		DBF D5,vc_loop_lp
		RTS
vc_loop_lp	MOVE.B (A0)+,(A6)
vclp_cont	CMP.L A3,A0
		DBGE D5,vc_loop_lp
		BLT.S vce_done
vclp_resetlp	MOVE.L A5,A0
		DBF D5,vc_loop_lp
vce_done	RTS

dmaisoff	ADDQ #extra_samps-1,D5
vce_isoff	NOP
		NOP
		NOP
		MOVE.B D7,(A6)
vce_isoffcont	DBF D5,vce_isoff
		RTS


; Paula emulation storage structure.

ch1s		DS.B sam_vcsize
ch2s		DS.B sam_vcsize			; shadow channel regs
ch3s		DS.B sam_vcsize
ch4s		DS.B sam_vcsize
shadow_dmacon	DS.W 1
shadow_filter	DS.W 1

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

move_dff09a	MACRO
.setdma\@	MOVE.W D4,saved4			; save D4
		MOVE.W \1,D4
		BTST #15,D4			; set or clear?
		BNE.S .setbits\@		
.clearbits\@	NOT.W D4			; zero so clear
		AND.W D4,shadow_dff09a		; mask bits in dmacon
		BRA.S .dmacon_set\@		; and exit...
.setbits\@	OR.W D4,shadow_dff09a		; not zero so set 'em
.dmacon_set\@	MOVE.W saved4,D4			; restore D4
		ENDM

move_dff09c	MACRO
.setdma\@	MOVE.W D4,saved4		; save D4
		MOVE.W \1,D4
		BTST #15,D4			; set or clear?
		BNE.S .setbits\@		
.clearbits\@	NOT.W D4			; zero so clear
		AND.W D4,shadow_dff09c		; mask bits in dmacon
		BRA.S .dmacon_set\@		; and exit...
.setbits\@	OR.W D4,shadow_dff09c		; not zero so set 'em
.dmacon_set\@	MOVE.W saved4,D4			; restore D4
		ENDM
saved4		DC.W 0
shadow_dff09a	dc.w 0
shadow_dff09c	dc.w 0

move_samstart	MACRO
		TST.L sam_start(A4)
		BGE.S .setloop\@
		MOVE.L \1,sam_start(A4)
		BRA.S .done\@
.setloop\@	MOVE.L \1,sam_lpstart(A4)
.done\@
		ENDM

move_samlength	MACRO
		TST.W sam_length(A4)
		BGE.S .setloop\@
		MOVE.W \1,sam_length(A4)
		BRA.S .done\@
.setloop\@	MOVE.W \1,sam_lplength(A4)
.done\@
		ENDM

; The player

Play_T2:	
Replay_T2:	Bsr.s	T2_Replay+$4
		Rts

	opt c-,o-

T2_Replay:	
  BRA     L00AA 
  BRA     L0000 
  BRA     L00AA 
  BRA     L00AB 
  BRA     L0095 
  BRA     L00B2 
  BRA     L00AA 
  BRA     L00AA 
  BRA     L009E 
  BRA     L00AB 
  BRA     L00A0 
  BRA     L00A4 
  BRA     L00AA 
  BRA     L00AA 
  BRA     L00AA 
  RTS 
  DC.B   $0E,$EE
  BRA     L00AC 
  BRA     L00AA 
  BRA     L00AA 
  BRA     L00AA 
  BRA     L00AA 
  BRA     L00AA 
  BRA     L00AA 
L0000:MOVEM.L A0-A6/D0-D7,-(A7) 
  LEA     L00B6(PC),A6
  MOVE.L  16(A6),-(A7)
  MOVE.W  56(A6),D0 
  BEQ.S   L0005 
 ; move_dmacon d0 
  MOVEQ   #9,D1 
  BTST    #0,D0 
  BEQ.S   L0001 
  MOVE.W  D1,ch1s+sam_period
L0001:BTST    #1,D0 
  BEQ.S   L0002 
  MOVE.W  D1,ch2s+sam_period
L0002:BTST    #2,D0 
  BEQ.S   L0003 
  MOVE.W  D1,ch3s+sam_period
L0003:BTST    #3,D0 
  BEQ.S   L0004 
  MOVE.W  D1,ch4s+sam_period
L0004:CLR.W   56(A6)
L0005:TST.B   22(A6)
  BNE.S   L0006 
  BRA     L0008 
L0006:BSR     L0038 
  TST.B   14(A6)
  BMI.S   L0007 
  BSR   L000A 
L0007:LEA     L00B8(PC),A5
  MOVE.W  128(A5),ch1s+sam_period
  LEA     L00B9(PC),A5
  MOVE.W  128(A5),ch2s+sam_period
  LEA     L00BA(PC),A5
  MOVE.W  128(A5),ch3s+sam_period
  LEA     L00BB(PC),A5
  MOVE.W  128(A5),ch4s+sam_period
  TST.W   54(A6)
  BEQ.S   L0008 
 move_dmacon 54(a6)
  CLR.W   54(A6)
L0008:MOVE.L  (A7)+,16(A6)
  MOVEM.L (A7)+,A0-A6/D0-D7 
L0009:RTS 
L000A:LEA     L00BC(PC),A5
  MOVEA.L 0(A6),A4
  SUBQ.W  #1,20(A6) 
  BPL.S   L0009 
  MOVE.W  6(A5),20(A6)
L000B:MOVEA.L A5,A0 
  CLR.B   13(A6)
  BSR.S   L000D 
  TST.B   13(A6)
  BNE.S   L000B 
  BSR.S   L000C 
  TST.B   13(A6)
  BNE.S   L000B 
  BSR.S   L000C 
  TST.B   13(A6)
  BNE.S   L000B 
  BSR.S   L000C 
  TST.B   13(A6)
  BNE.S   L000B 
  BSR.S   L000C 
  TST.B   13(A6)
  BNE.S   L000B 
  BSR.S   L000C 
  TST.B   13(A6)
  BNE.S   L000B 
  RTS 
L000C:ADDQ.L  #4,A0 
L000D:CMPI.B  #-$70,72(A0)
  BCS.S   L000E 
  CMPI.B  #-2,72(A0)
  BNE.S   L000F 
  ST      72(A0)
  MOVE.B  73(A0),D0 
  BRA     L009E 
L000E:LEA     L00BE(PC),A1
  ST      21(A1)
  TST.B   106(A0) 
  BEQ.S   L0010 
  SUBQ.B  #1,106(A0)
L000F:RTS 
L0010:MOVE.W  104(A0),D0
  ADD.W   D0,D0 
  ADD.W   D0,D0 
  MOVEA.L 40(A0),A1 
  MOVE.L  0(A1,D0.W),16(A6) 
  MOVE.B  16(A6),D0 
  CMP.B   #-$10,D0
  BCC.S   L0013 
  MOVE.B  D0,D7 
  CMP.B   #-$40,D0
  BCC.S   L0011 
  CMP.B   #$7F,D0 
  BCS.S   L0011 
  MOVE.B  19(A6),106(A0)
  CLR.B   19(A6)
L0011:MOVE.B  73(A0),D1 
  ADD.B   D1,D0 
  CMP.B   #-$40,D7
  BCC.S   L0012 
  ANDI.B  #$3F,D0 
L0012:MOVE.B  D0,16(A6) 
  MOVE.L  16(A6),D0 
  BSR     L0095 
  CMP.B   #-$40,D7
  BCC.S   L0015 
  CMP.B   #$7F,D7 
  BCS.S   L0015 
  BRA     L001F 
L0013:ANDI.W  #$F,D0
  ADD.W   D0,D0 
  ADD.W   D0,D0 
  JMP     L0014(PC,D0.W)
L0014:BRA     L0016 
  BRA     L0019 
  BRA     L001D 
  BRA     L001E 
  BRA     L0020 
  BRA     L0021 
  BRA     L0021 
  BRA     L0021 
  BRA     L0022 
  BRA     L0023 
  BRA     L0015 
  BRA     L0024 
  BRA     L0021 
  BRA     L0015 
  BRA     L0020 
L0015:ADDQ.W  #1,104(A0)
  BRA     L0010 
L0016:ST      72(A0)
  MOVE.W  4(A5),D0
  CMP.W   2(A5),D0
  BNE.S   L0017 
  MOVE.W  0(A5),4(A5) 
  BRA.S   L0018 
L0017:ADDQ.W  #1,4(A5)
L0018:BSR     L0025 
  ST      13(A6)
  RTS 
L0019:TST.B   74(A0)
  BEQ.S   L001A 
  CMPI.B  #-1,74(A0)
  BEQ.S   L001B 
  SUBQ.B  #1,74(A0) 
  BRA.S   L001C 
L001A:ST      74(A0)
  BRA.S   L0015 
L001B:MOVE.B  17(A6),D0 
  SUBQ.B  #1,D0 
  MOVE.B  D0,74(A0) 
L001C:MOVE.W  18(A6),104(A0)
  BRA     L0010 
L001D:MOVE.B  17(A6),D0 
  MOVE.B  D0,72(A0) 
  ADD.W   D0,D0 
  ADD.W   D0,D0 
  MOVEA.L 42(A6),A1 
  MOVE.L  0(A1,D0.W),D0 
  ADD.L   A4,D0 
  MOVE.L  D0,40(A0) 
  MOVE.W  18(A6),104(A0)
  BRA     L0010 
L001E:MOVE.B  17(A6),106(A0)
L001F:ADDQ.W  #1,104(A0)
  RTS 
L0020:ST      72(A0)
  RTS 
L0021:MOVE.L  16(A6),D0 
  BSR     L0095 
  BRA     L0015 
L0022:MOVE.L  40(A0),136(A0)
  MOVE.W  104(A0),168(A0) 
  MOVE.B  17(A6),D0 
  MOVE.B  D0,72(A0) 
  ADD.W   D0,D0 
  ADD.W   D0,D0 
  MOVEA.L 42(A6),A1 
  MOVE.L  0(A1,D0.W),D0 
  ADD.L   A4,D0 
  MOVE.L  D0,40(A0) 
  MOVE.W  18(A6),104(A0)
  BRA     L0010 
L0023:MOVE.L  136(A5),40(A5)
  MOVE.W  168(A5),104(A5) 
  BRA     L0015 
L0024:MOVE.B  18(A6),D1 
  ANDI.W  #7,D1 
  ADD.W   D1,D1 
  ADD.W   D1,D1 
  MOVE.B  17(A6),D0 
  MOVE.B  D0,72(A5,D1.W)
  MOVE.B  19(A6),73(A5,D1.W)
  ANDI.W  #$7F,D0 
  ADD.W   D0,D0 
  ADD.W   D0,D0 
  MOVEA.L 42(A6),A1 
  MOVE.L  0(A1,D0.W),D0 
  ADD.L   A4,D0 
  MOVE.L  D0,40(A5,D1.W)
  CLR.L   104(A5,D1.W)
  ST      74(A5,D1.W) 
  BRA     L0015 
L0025:MOVEM.L A0-A1,-(A7) 
L0026:MOVE.W  4(A5),D0
  LSL.W   #4,D0 
  MOVEA.L 38(A6),A0 
  ADDA.W  D0,A0 
  MOVEA.L 42(A6),A1 
  MOVE.W  (A0)+,D0
  CMP.W   #-$1002,D0
  BNE.S   L0028 
  MOVE.W  (A0)+,D0
  ADD.W   D0,D0 
  ADD.W   D0,D0 
  JMP     L0027(PC,D0.W)
L0027:BRA     L002F 
  BRA     L0030 
  BRA     L0034 
  BRA     L002F 
  BRA     L0035 
L0028:MOVE.W  D0,72(A5) 
  BMI.S   L0029 
  CLR.B   D0
  LSR.W   #6,D0 
  MOVE.L  0(A1,D0.W),D0 
  ADD.L   A4,D0 
  MOVE.L  D0,40(A5) 
  CLR.L   104(A5) 
  ST      74(A5)
L0029:MOVEM.W (A0)+,D0-D6 
  MOVE.W  D0,76(A5) 
  BMI.S   L002A 
  CLR.B   D0
  LSR.W   #6,D0 
  MOVE.L  0(A1,D0.W),D0 
  ADD.L   A4,D0 
  MOVE.L  D0,44(A5) 
  CLR.L   108(A5) 
  ST      78(A5)
L002A:MOVE.W  D1,80(A5) 
  BMI.S   L002B 
  CLR.B   D1
  LSR.W   #6,D1 
  MOVE.L  0(A1,D1.W),D0 
  ADD.L   A4,D0 
  MOVE.L  D0,48(A5) 
  CLR.L   112(A5) 
  ST      82(A5)
L002B:MOVE.W  D2,84(A5) 
  BMI.S   L002C 
  CLR.B   D2
  LSR.W   #6,D2 
  MOVE.L  0(A1,D2.W),D0 
  ADD.L   A4,D0 
  MOVE.L  D0,52(A5) 
  CLR.L   116(A5) 
  ST      86(A5)
L002C:MOVE.W  D3,88(A5) 
  BMI.S   L002D 
  CLR.B   D3
  LSR.W   #6,D3 
  MOVE.L  0(A1,D3.W),D0 
  ADD.L   A4,D0 
  MOVE.L  D0,56(A5) 
  CLR.L   120(A5) 
  ST      90(A5)
L002D:MOVE.W  D4,92(A5) 
  BMI.S   L002E 
  CLR.B   D4
  LSR.W   #6,D4 
  MOVE.L  0(A1,D4.W),D0 
  ADD.L   A4,D0 
  MOVE.L  D0,60(A5) 
  CLR.L   124(A5) 
  ST      94(A5)
L002E:MOVEM.L (A7)+,A0-A1 
  RTS 
L002F:CLR.B   22(A6)
  MOVEM.L (A7)+,A0-A1 
  RTS 
L0030:TST.W   36(A6)
  BEQ.S   L0031 
  BMI.S   L0032 
  SUBQ.W  #1,36(A6) 
  BRA.S   L0033 
L0031:MOVE.W  #-1,36(A6)
  ADDQ.W  #1,4(A5)
  BRA     L0026 
L0032:MOVE.W  2(A0),D0
  SUBQ.W  #1,D0 
  MOVE.W  D0,36(A6) 
L0033:MOVE.W  (A0),4(A5)
  BRA     L0026 
L0034:MOVE.W  (A0),6(A5)
  MOVE.W  (A0),20(A6) 
  ADDQ.W  #1,4(A5)
  BRA     L0026 
L0035:ADDQ.W  #1,4(A5)
  LEA     L00BE(PC),A1
  TST.W   0(A1) 
  BNE     L0026 
  MOVE.W  #1,0(A1)
  MOVE.B  3(A0),31(A6)
  MOVE.B  1(A0),32(A6)
  MOVE.B  1(A0),33(A6)
  BEQ.S   L0036 
  MOVE.B  #1,15(A6) 
  MOVE.B  30(A6),D0 
  CMP.B   31(A6),D0 
  BEQ.S   L0037 
  BCS     L0026 
  NEG.B   15(A6)
  BRA     L0026 
L0036:MOVE.B  31(A6),30(A6) 
L0037:MOVE.B  #0,15(A6) 
  CLR.W   0(A1) 
  BRA     L0026 
L0038:LEA     L00B8(PC),A5
  BSR.S   L0039 
  LEA     L00B9(PC),A5
  BSR.S   L0039 
  LEA     L00BA(PC),A5
  BSR.S   L0039 
  LEA     L00BB(PC),A5
L0039:MOVEA.L 76(A5),A4 
  TST.B   0(A5) 
  BEQ.S   L003A 
  BPL     L0057 
L003A:TST.W   62(A5)
  BMI.S   L003B 
  SUBQ.W  #1,62(A5) 
  BRA.S   L003C 
L003B:CLR.B   60(A5)
  CLR.B   61(A5)
L003C:MOVE.L  124(A5),D0
  BEQ.S   L003D 
  CLR.L   124(A5) 
  CLR.B   60(A5)
  BSR     L0095 
  MOVE.B  61(A5),60(A5) 
L003D:TST.B   3(A5) 
  BEQ.S   L0040 
  MOVE.L  44(A5),D0 
  ADD.L   80(A5),D0 
  MOVE.L  D0,44(A5) 
  TST.W   94(A5)
  BEQ.S   L003E 
  MOVE.L  D0,88(A5) 
  BRA.S   L003F 

L003E:
  move_samstart D0

L003F:SUBI.B  #1,3(A5)
  BNE.S   L0040 
  MOVE.B  27(A5),3(A5)
  NEG.L   80(A5)
L0040:TST.W   94(A5)
  BEQ     L0049 
  MOVEA.L 88(A5),A0 
  MOVE.L  96(A5),D4 
  MOVE.L  108(A5),D5
  MOVEA.L 84(A5),A1 
  ADDA.L  8(A6),A1
  MOVE.W  94(A5),D7 
  MOVE.W  92(A5),D6 
  MOVE.B  106(A5),D3
  MOVEQ   #0,D0 
  MOVE.B  $00000043.L,D1
L0041:ADD.L   D5,D4 
  SWAP    D0
  ADD.L   D4,D0 
  SWAP    D0
  AND.W   D6,D0 
  MOVE.B  0(A0,D0.W),D2 
  TST.B   D3
  BEQ.S   L0045 
  CMP.B   D1,D2 
  BEQ.S   L0044 
  BGT.S   L0043 
  SUBX.B  D3,D1 
  BVS.S   L0044 
  CMP.B   D1,D2 
  BGE.S   L0044 
L0042:MOVE.B  D1,(A1)+
  DBF     D7,L0041
  BRA.S   L0046 
L0043:ADDX.B  D3,D1 
  BVS.S   L0044 
  CMP.B   D1,D2 
  BGT.S   L0042 
L0044:MOVE.B  D2,D1 
L0045:MOVE.B  D2,(A1)+
  DBF     D7,L0041
L0046:MOVE.B  D1,67(A5) 
  TST.B   D3
  BEQ.S   L0047 
  MOVE.W  116(A5),D0
  ADD.W   D0,106(A5)
  SUBQ.W  #1,112(A5)
  BNE.S   L0047 
  MOVE.W  114(A5),112(A5) 
  NEG.W   116(A5) 
L0047:MOVE.W  104(A5),D0
  EXT.L   D0
  ADD.L   D0,96(A5) 
  SUBQ.W  #1,100(A5)
  BNE.S   L0048 
  MOVE.W  102(A5),100(A5) 
  BEQ.S   L0048 
  NEG.W   104(A5) 
L0048:MOVE.W  118(A5),D0
  EXT.L   D0
  ADD.L   D0,108(A5)
  SUBQ.W  #1,120(A5)
  BNE.S   L0049 
  MOVE.W  122(A5),120(A5) 
  BEQ.S   L0049 
  NEG.W   118(A5) 
L0049:TST.B   38(A5)
  BEQ.S   L004C 
  MOVE.B  32(A5),D0 
  EXT.W   D0
  ADD.W   D0,36(A5) 
  MOVE.W  40(A5),D0 
  MOVE.W  36(A5),D1 
  BEQ.S   L004A 
  ANDI.L  #$FFFF,D0 
  ADDI.W  #$800,D1
  MULU    D1,D0 
  LSL.L   #5,D0 
  SWAP    D0
L004A:TST.W   48(A5)
  BNE.S   L004B 
  MOVE.W  D0,128(A5)
L004B:SUBQ.B  #1,39(A5) 
  BNE.S   L004C 
  MOVE.B  38(A5),39(A5) 
  EORI.B  #-1,32(A5)
  ADDQ.B  #1,32(A5) 
L004C:TST.W   48(A5)
  BEQ.S   L0050 
  SUBQ.B  #1,35(A5) 
  BNE.S   L0050 
  MOVE.B  34(A5),35(A5) 
  MOVE.W  40(A5),D1 
  MOVEQ   #0,D0 
  MOVE.W  50(A5),D0 
  CMP.W   D1,D0 
  BEQ.S   L004D 
  BCS.S   L004F 
  MOVE.W  #$100,D2
  SUB.W   48(A5),D2 
  MULU    D2,D0 
  LSR.L   #8,D0 
  CMP.W   D1,D0 
  BEQ.S   L004D 
  BCC.S   L004E 
L004D:CLR.W   48(A5)
  MOVE.W  40(A5),D0 
L004E:ANDI.W  #$7FF,D0
  MOVE.W  D0,50(A5) 
  MOVE.W  D0,128(A5)
  BRA.S   L0050 
L004F:MOVE.W  48(A5),D2 
  ADDI.W  #$100,D2
  MULU    D2,D0 
  LSR.L   #8,D0 
  CMP.W   D1,D0 
  BEQ.S   L004D 
  BCC.S   L004D 
  BRA.S   L004E 
L0050:TST.B   28(A5)
  BEQ.S   L0054 
  TST.B   29(A5)
  BEQ.S   L0051 
  SUBQ.B  #1,29(A5) 
  BRA.S   L0054 
L0051:MOVE.B  28(A5),29(A5) 
  MOVE.B  30(A5),D0 
  CMP.B   24(A5),D0 
  BGT.S   L0053 
  MOVE.B  31(A5),D1 
  SUB.B   D1,24(A5) 
  BMI.S   L0052 
  CMP.B   24(A5),D0 
  BGE.S   L0052 
  BRA.S   L0054 
L0052:MOVE.B  30(A5),24(A5) 
  CLR.B   28(A5)
  BRA.S   L0054 
L0053:MOVE.B  31(A5),D1 
  ADD.B   D1,24(A5) 
  CMP.B   24(A5),D0 
  BLE.S   L0052 
L0054:TST.B   15(A6)
  BEQ.S   L0055 
  SUBQ.B  #1,32(A6) 
  BNE.S   L0055 
  MOVE.B  33(A6),32(A6) 
  MOVE.B  15(A6),D0 
  ADD.B   D0,30(A6) 
  MOVE.B  31(A6),D0 
  CMP.B   30(A6),D0 
  BNE.S   L0055 
  CLR.B   15(A6)
  LEA     L00BE(PC),A0
  CLR.W   0(A0) 
L0055:MOVEQ   #0,D1 
  MOVE.B  30(A6),D1 
  MOVEQ   #0,D0 
  MOVE.B  24(A5),D0 
  BTST    #6,D1 
  BNE.S   L0056 
  ADD.W   D0,D0 
  ADD.W   D0,D0 
  MULU    D1,D0 
  LSR.W   #8,D0 
L0056:MOVE.W  D0,sam_vol(A4)
L0057:TST.B   0(A5) 
  BEQ.S   L0058 
  BPL.S   L0059 
  TST.W   18(A5)
  BEQ.S   L005A 
  SUBQ.W  #1,18(A5) 
L0058:RTS 
L0059:CLR.W   16(A5)
  CLR.W   18(A5)
  ST      0(A5) 
  ST      26(A5)
  ST      1(A5) 
  move_dff09a 70(a5)
  move_dff09c 70(a5)
L005A:MOVEA.L 12(A5),A0 
  MOVE.W  16(A5),D0 
  ADD.W   D0,D0 
  ADD.W   D0,D0 
  MOVE.L  0(A0,D0.W),16(A6) 
  MOVEQ   #0,D0 
  MOVE.B  16(A6),D0 
  CLR.B   16(A6)
  ADD.W   D0,D0 
  ADD.W   D0,D0 
  JMP     L005B(PC,D0.W)
L005B:BRA     L005E 
  BRA     L0061 
  BRA     L0063 
  BRA     L0068 
  BRA     L0069 
  BRA     L006F 
  BRA     L0074 
  BRA     L0075 
  BRA     L007A 
  BRA     L0079 
  BRA     L0083 
  BRA     L007F 
  BRA     L0081 
  BRA     L0076 
  BRA     L0077 
  BRA     L0082 
  BRA     L0073 
  BRA     L0065 
  BRA     L0066 
  BRA     L005F 
  BRA     L0084 
  BRA     L0088 
  BRA     L0089 
  BRA     L007E 
  BRA     L008A 
  BRA     L008B 
  BRA     L006A 
  BRA     L006F 
  BRA     L006D 
  BRA     L006E 
  BRA     L006F 
  BRA     L0078 
  BRA     L005D 
  BRA     L005D 
  BRA     L008C 
  BRA     L008D 
  BRA     L008F 
  BRA     L0091 
  BRA     L0090 
  BRA     L0092 
  BRA     L0093 
  BRA     L0094 
L005C:ADDQ.W  #1,16(A5) 
  TST.B   1(A5) 
  ST      1(A5) 
  BPL     L005A 
  RTS 

L005D:ADDQ.W  #1,16(A5) 
  BRA     L005A 
L005E:CLR.B   28(A5)
  CLR.B   38(A5)
  CLR.W   48(A5)
  CLR.W   94(A5)
L005F:ADDQ.W  #1,16(A5) 
  MOVE.B  17(A6),1(A5)
  BNE.S   L0060 
  ST      1(A5) 
;  move_dmacon 22(a5) 
  BRA     L005A 
L0060:SUBQ.B  #1,1(A5)
  MOVE.W  22(A5),D0 
  OR.W    D0,56(A6) 
  RTS 

L0061:
  move_dff09a 70(a5)
  move_dff09c 70(a5)
  MOVE.W  16(A6),18(A5) 
  BEQ.S   L0062 
  BSR     L003D 


L0062:ADDQ.W  #1,16(A5) 
  MOVE.W  20(A5),D0 
  OR.W    D0,54(A6) 
  BRA     L005A 

L0063:CLR.B   3(A5) 
  MOVE.L  16(A6),D0 
  ADD.L   4(A6),D0
L0064:MOVE.L  D0,44(A5) 
  move_samstart D0

  ADDQ.W  #1,16(A5) 
  BRA     L005A 

L0065:MOVE.B  17(A6),3(A5)
  MOVE.B  17(A6),27(A5) 
  MOVE.W  18(A6),D1 
  EXT.L   D1
  MOVE.L  D1,80(A5) 
  MOVE.L  44(A5),D0 
  ADD.L   D1,D0 
  TST.W   94(A5)
  BEQ.S   L0064 
  MOVE.L  D0,44(A5) 
  MOVE.L  D0,88(A5) 
  ADDQ.W  #1,16(A5) 
  BRA     L005A 

L0066:MOVE.W  18(A6),D0 
  MOVE.W  52(A5),D1 
  ADD.W   D0,D1 
  MOVE.W  D1,52(A5) 
  TST.W   94(A5)
  BEQ.S   L0067 
  MOVE.W  D1,92(A5) 
  ADDQ.W  #1,16(A5) 
  BRA     L005A 

L0067:
	move_samlength	d1

  ADDQ.W  #1,16(A5) 
  BRA     L005A 

L0068:MOVE.W  18(A6),52(A5) 
  MOVE.W  18(A6),D1
	move_samlength	d1


  ADDQ.W  #1,16(A5) 
  BRA     L005A 

L0069:MOVE.W  18(A6),18(A5) 
  BRA     L005C 
L006A:
 CLR.B   0(A5) 
  move_dff09a 68(A5)

  BRA     L005C 


L006D:MOVE.B  17(A6),D0 
  CMP.B   5(A5),D0
  BCC     L005D 
  MOVE.W  18(A6),16(A5) 
  BRA     L005A 
L006E:MOVE.B  17(A6),D0 
  CMP.B   24(A5),D0 
  BCC     L005D 
  MOVE.W  18(A6),16(A5) 
  BRA     L005A 
L006F:TST.B   26(A5)
  BEQ.S   L0070 
  CMPI.B  #-1,26(A5)
  BEQ.S   L0071 
  SUBQ.B  #1,26(A5) 
  BRA.S   L0072 
L0070:ST      26(A5)
  ADDQ.W  #1,16(A5) 
  BRA     L005A 
L0071:MOVE.B  17(A6),D0 
  SUBQ.B  #1,D0 
  MOVE.B  D0,26(A5) 
L0072:MOVE.W  18(A6),16(A5) 
  BRA     L005A 
L0073:TST.B   54(A5)
  BNE.S   L006F 
  ADDQ.W  #1,16(A5) 
  BRA     L005A 
L0074:MOVE.B  17(A6),D0 
  ANDI.L  #$7F,D0 
  MOVEA.L 46(A6),A0 
  ADD.W   D0,D0 
  ADD.W   D0,D0 
  ADDA.W  D0,A0 
  MOVE.L  (A0),D0 
  ADD.L   0(A6),D0
  MOVE.L  D0,12(A5) 
  MOVE.W  18(A6),16(A5) 
  ST      26(A5)
  BRA     L0057 
L0075:CLR.B   0(A5) 
  RTS 
L0076:MOVE.W  8(A5),D0
  ADD.W   D0,D0 
  ADD.W   8(A5),D0
  ADD.W   18(A6),D0 
  MOVE.B  D0,24(A5) 
  ADDQ.W  #1,16(A5) 
  BRA     L005A 
L0077:MOVE.B  19(A6),24(A5) 
  ADDQ.W  #1,16(A5) 
  BRA     L005A 
L0078:MOVE.B  4(A5),D2
  LEA     L005C(PC),A1
  BRA.S   L007B 
L0079:MOVEQ   #0,D2 
  LEA     L005C(PC),A1
  BRA.S   L007B 
L007A:MOVE.B  5(A5),D2
  LEA     L005C(PC),A1
L007B:MOVE.B  17(A6),D0 
  ADD.B   D2,D0 
  ANDI.B  #$3F,D0 
  EXT.W   D0
  ADD.W   D0,D0 
  LEA     L00C0(PC),A0
  MOVE.W  0(A0,D0.W),D0 
  MOVE.W  10(A5),D1 
  ADD.W   18(A6),D1 
  BEQ.S   L007C 
  ADDI.W  #$100,D1
  MULU    D1,D0 
  LSR.L   #8,D0 
L007C:MOVE.W  D0,40(A5) 
  TST.W   48(A5)
  BNE.S   L007D 
  MOVE.W  D0,128(A5)
L007D:JMP     (A1)
L007E:MOVE.W  18(A6),40(A5) 
  TST.W   48(A5)
  BNE     L005D 
  MOVE.W  18(A6),128(A5)
  BRA     L005D 
L007F:MOVE.B  17(A6),34(A5) 
  MOVE.B  #1,35(A5) 
  TST.W   48(A5)
  BNE.S   L0080 
  MOVE.W  40(A5),50(A5) 
L0080:MOVE.W  18(A6),48(A5) 
  BRA     L005D 
L0081:MOVE.B  17(A6),D0 
  MOVE.B  D0,38(A5) 
  LSR.B   #1,D0 
  MOVE.B  D0,39(A5) 
  MOVE.B  19(A6),32(A5) 
  MOVE.B  #1,33(A5) 
  TST.W   48(A5)
  BNE     L005D 
  MOVE.W  40(A5),128(A5)
  CLR.W   36(A5)
  ADDQ.W  #1,16(A5) 
  BRA     L005A 
L0082:MOVE.B  18(A6),28(A5) 
  MOVE.B  17(A6),31(A5) 
  MOVE.B  18(A6),29(A5) 
  MOVE.B  19(A6),30(A5) 
  ADDQ.W  #1,16(A5) 
  BRA     L005A 
L0083:CLR.B   28(A5)
  CLR.B   38(A5)
  CLR.W   48(A5)
  CLR.W   94(A5)
  CLR.B   3(A5) 
  BRA     L005D 
L0084:TST.B   54(A5)
  BEQ     L005D 
  TST.B   26(A5)
  BEQ.S   L0085 
  CMPI.B  #-1,26(A5)
  BEQ.S   L0086 
  SUBQ.B  #1,26(A5) 
  BRA.S   L0087 
L0085:ST      26(A5)
  BRA     L005D 
L0086:MOVE.B  19(A6),D0 
  SUBQ.B  #1,D0 
  MOVE.B  D0,26(A5) 
L0087:RTS 


L0088:MOVE.L  12(A5),56(A5) 
  MOVE.W  16(A5),64(A5) 
  MOVE.B  17(A6),D0 
  ANDI.L  #$7F,D0 
  MOVEA.L 46(A6),A0 
  ADD.W   D0,D0 
  ADD.W   D0,D0 
  ADDA.W  D0,A0 
  MOVE.L  (A0),D0 
  ADD.L   0(A6),D0
  MOVE.L  D0,12(A5) 
  MOVE.W  18(A6),16(A5) 
  BRA     L0057 
L0089:MOVE.L  56(A5),12(A5) 
  MOVE.W  64(A5),16(A5) 
  BRA     L005D 

L008A:MOVE.L  16(A6),D0 
  ADD.L   D0,44(A5) 
  move_samstart 44(a5)
  LSR.W   #1,D0 
  SUB.W   D0,52(A5) 
  MOVE.W  52(A5),D1
	move_samlength	d1
  ADDQ.W  #1,16(A5) 
  BRA     L005A 

L008B:CLR.B   3(A5) 
  MOVE.L  4(A6),44(A5)
  move_samstart 4(a6)
  MOVE.W  #1,52(A5) 
	move_samlength	#1
  ADDQ.W  #1,16(A5) 
  BRA     L005A 

L008C:CLR.B   3(A5) 
  MOVE.L  16(A6),D0 
  ADD.L   4(A6),D0
  MOVE.L  D0,88(A5) 
  MOVE.L  D0,44(A5) 
  MOVE.L  4(A6),D0
  ADD.L   84(A5),D0 
  move_samstart d0
  ADDQ.W  #1,16(A5) 
  BRA     L005A 

L008D:
  MOVE.W  16(A6),D0 
 ASR.W #1,D0
  BNE.S   L008E 
  MOVE.W  #$100,D0
L008E:
  EXT.L D0
	move_samlength	d0
  MOVE.W  16(A6),D0 
  SUBQ.W  #1,D0 
  ANDI.W  #$FF,D0 
  MOVE.W  D0,94(A5) 
  MOVE.W  18(A6),92(A5) 
  MOVE.W  18(A6),52(A5) 
  ADDQ.W  #1,16(A5) 
  BRA     L005A 

L008F:MOVE.L  16(A6),D0 
  LSL.L   #8,D0 
  MOVE.L  D0,96(A5) 
  ADDQ.W  #1,16(A5) 
  BRA     L005A 
L0090:MOVE.L  16(A6),108(A5)
  ADDQ.W  #1,16(A5) 
  BRA     L005A 
L0091:MOVE.W  16(A6),100(A5)
  MOVE.W  16(A6),102(A5)
  MOVE.W  18(A6),104(A5)
  ADDQ.W  #1,16(A5) 
  BRA     L005A 
L0092:MOVE.W  16(A6),120(A5)
  MOVE.W  16(A6),122(A5)
  MOVE.W  18(A6),118(A5)
  ADDQ.W  #1,16(A5) 
  BRA     L005A 
L0093:MOVE.B  19(A6),106(A5)
  MOVE.B  18(A6),D0 
  EXT.W   D0
  LSL.W   #4,D0 
  MOVE.W  D0,116(A5)
  MOVE.W  16(A6),112(A5)
  MOVE.W  16(A6),114(A5)
  ADDQ.W  #1,16(A5) 
  BRA     L005A 
L0094:ADDQ.W  #1,16(A5) 
  CLR.W   94(A5)
  TST.B   17(A6)
  BEQ     L005A 
  CLR.L   96(A5)
  CLR.W   100(A5) 
  CLR.W   102(A5) 
  CLR.W   104(A5) 
  CLR.L   108(A5) 
  CLR.W   120(A5) 
  CLR.W   122(A5) 
  CLR.W   118(A5) 
  CLR.B   106(A5) 
  CLR.W   116(A5) 
  CLR.W   112(A5) 
  CLR.W   114(A5) 
  BRA     L005A 

L0095:MOVEM.L A4-A6/D0,-(A7)
  LEA     L00B6(PC),A6
  MOVE.L  16(A6),-(A7)
  LEA     L00B7(PC),A5
  MOVE.L  D0,16(A6) 
  MOVE.B  18(A6),D0 
  ANDI.W  #$F,D0
  ADD.W   D0,D0 
  ADD.W   D0,D0 
  MOVEA.L 0(A5,D0.W),A5 
  MOVE.B  16(A6),D0 
  CMP.B   #-4,D0
  BNE.S   L0096 
  MOVE.B  17(A6),60(A5) 
  MOVE.B  19(A6),D0 
  MOVE.W  D0,62(A5) 
  BRA     L009B 
L0096:TST.B   60(A5)
  BNE     L009B 
  TST.B   D0
  BPL     L009A 
  CMP.B   #-9,D0
  BNE.S   L0097 
  MOVE.B  17(A6),31(A5) 
  MOVE.B  18(A6),D0 
  LSR.B   #4,D0 
  ADDQ.B  #1,D0 
  MOVE.B  D0,29(A5) 
  MOVE.B  D0,28(A5) 
  MOVE.B  19(A6),30(A5) 
  BRA     L009B 
L0097:CMP.B   #-$A,D0 
  BNE.S   L0098 
  MOVE.B  17(A6),D0 
  ANDI.B  #-2,D0
  MOVE.B  D0,38(A5) 
  LSR.B   #1,D0 
  MOVE.B  D0,39(A5) 
  MOVE.B  19(A6),32(A5) 
  MOVE.B  #1,33(A5) 
  CLR.W   36(A5)
  BRA.S   L009B 
L0098:CMP.B   #-$B,D0 
  BNE.S   L0099 
  CLR.B   54(A5)
  BRA.S   L009B 
L0099:CMP.B   #-$41,D0
  BCC.S   L009C 
L009A:MOVE.B  19(A6),D0 
  EXT.W   D0
  MOVE.W  D0,10(A5) 
  MOVE.B  18(A6),D0 
  LSR.B   #4,D0 
  ANDI.W  #$F,D0
  MOVE.B  D0,9(A5)
  MOVE.B  17(A6),D0 
  MOVE.B  D0,7(A5)
  MOVE.B  5(A5),4(A5) 
  MOVE.B  16(A6),5(A5)
  MOVEA.L 46(A6),A4 
  ADD.W   D0,D0 
  ADD.W   D0,D0 
  ADDA.W  D0,A4 
  MOVEA.L (A4),A4 
  ADDA.L  0(A6),A4
  MOVE.L  A4,12(A5) 
  MOVE.B  #1,0(A5)
  MOVE.B  #1,54(A5) 
L009B:MOVE.L  (A7)+,16(A6)
  MOVEM.L (A7)+,A4-A6/D0
  RTS 
L009C:MOVE.B  17(A6),34(A5) 
  MOVE.B  #1,35(A5) 
  TST.W   48(A5)
  BNE.S   L009D 
  MOVE.W  40(A5),50(A5) 
L009D:CLR.W   48(A5)
  MOVE.B  19(A6),49(A5) 
  MOVE.B  16(A6),D0 
  ANDI.W  #$3F,D0 
  MOVE.B  D0,5(A5)
  ADD.W   D0,D0 
  LEA     L00C0(PC),A4
  MOVE.W  0(A4,D0.W),40(A5) 
  BRA.S   L009B 
L009E:MOVE.L  A5,-(A7)
  LEA     L00B7(PC),A5
  ANDI.W  #$F,D0
  ADD.W   D0,D0 
  ADD.W   D0,D0 
  MOVEA.L 0(A5,D0.W),A5 
  TST.B   60(A5)
  BNE.S   L009F 
  move_dff09a 70(A5)
;  move_dmacon 22(a5)
  CLR.B   0(A5) 

  CLR.W   94(A5)
L009F:MOVEA.L (A7)+,A5
  RTS 
L00A0:MOVEM.L A5-A6,-(A7) 
  LEA     L00B6(PC),A6
  LEA     L00BE(PC),A5
  MOVE.W  #1,0(A5)
  MOVE.B  D0,31(A6) 
  SWAP    D0
  MOVE.B  D0,32(A6) 
  MOVE.B  D0,33(A6) 
  BEQ.S   L00A1 
  MOVE.B  30(A6),D0 
  MOVE.B  #1,15(A6) 
  CMP.B   31(A6),D0 
  BEQ.S   L00A2 
  BCS.S   L00A3 
  NEG.B   15(A6)
  BRA.S   L00A3 
L00A1:MOVE.B  31(A6),30(A6) 
L00A2:CLR.B   15(A6)
  CLR.W   0(A5) 
L00A3:MOVEM.L (A7)+,A5-A6 
  RTS 
L00A4:LEA     L00BE(PC),A0
  RTS 
  MOVEM.L A4-A6/D1-D3,-(A7) 
  LEA     L00B6(PC),A6
  LEA     L00B7(PC),A4
  MOVE.W  D0,D2 
  MOVEA.L 50(A6),A5 
  LSL.W   #3,D2 
  MOVE.B  2(A5,D2.W),D3 
  TST.B   14(A6)
  BPL.S   L00A5 
  MOVE.B  4(A5,D2.W),D3 
L00A5:ANDI.W  #$F,D3
  ADD.W   D3,D3 
  ADD.W   D3,D3 
  MOVEA.L 0(A4,D3.W),A4 
  LSL.W   #6,D3 
  MOVE.B  5(A5,D2.W),D1 
  BCLR    #7,D1 
  CMP.B   61(A4),D1 
  BCC.S   L00A6 
  TST.W   62(A4)
  BPL.S   L00A8 
L00A6:CMP.B   66(A4),D2 
  BNE.S   L00A7 
  TST.W   62(A4)
  BMI.S   L00A7 
  BTST    #7,5(A5,D2.W) 
  BNE.S   L00A8 
L00A7:MOVE.L  0(A5,D2.W),D0 
  ANDI.L  #-$F01,D0 
  OR.W    D3,D0 
  MOVE.L  D0,124(A4)
  MOVE.B  D1,61(A4) 
  MOVE.W  6(A5,D2.W),62(A4) 
  MOVE.B  D2,66(A4) 
L00A8:MOVEM.L (A7)+,A4-A6/D1-D3 
  RTS 
L00A9:CLR.B   0(A6) 
  CLR.L   60(A6)
  CLR.W   94(A6)
  RTS 

L00AA:MOVE.L  A6,-(A7)
  LEA     L00B6(PC),A6
  CLR.B   22(A6)
  CLR.W   54(A6)
  LEA     L00B8(PC),A6
  BSR.S   L00A9 
  LEA     L00B9(PC),A6
  BSR.S   L00A9 
  LEA     L00BA(PC),A6
  BSR.S   L00A9 
  LEA     L00BB(PC),A6
  BSR.S   L00A9 
  move_dmacon #$000f
  LEA     L00BE(PC),A6
  CLR.B   21(A6)
  MOVEA.L (A7)+,A6
  RTS 
L00AB:MOVEM.L A0-A6/D1-D7,-(A7) 
  LEA     L00B6(PC),A6
  MOVE.B  D0,29(A6) 
  BSR.S   L00AD 
  MOVEM.L (A7)+,A0-A6/D1-D7 
  RTS 
L00AC:MOVEM.L A0-A6/D1-D7,-(A7) 
  LEA     L00B6(PC),A6
  ORI.W   #$100,D0
  MOVE.W  D0,28(A6) 
  BSR.S   L00AD 
  MOVEM.L (A7)+,A0-A6/D1-D7 
  RTS 
L00AD:BSR     L00AA 
  CLR.B   22(A6)
  MOVEA.L 0(A6),A4
  MOVE.B  29(A6),D0 
  ANDI.W  #$1F,D0 
  ADD.W   D0,D0 
  ADDA.W  D0,A4 
  LEA     L00BC(PC),A5
  MOVE.B  14(A6),D1 
  BMI     L00AE 
  ANDI.W  #$1F,D1 
  ADD.W   D1,D1 
  LEA     L00BD(PC),A0
  ADDA.W  D1,A0 
  MOVE.W  4(A5),(A0)
  MOVE.B  7(A5),65(A0)
L00AE:MOVE.W  256(A4),4(A5) 
  MOVE.W  256(A4),0(A5) 
  MOVE.W  320(A4),2(A5) 
  MOVE.W  384(A4),D2
  BTST    #0,28(A6) 
  BEQ.S   L00AF 
  LEA     L00BD(PC),A0
  ADDA.W  D0,A0 
  MOVE.W  (A0),4(A5)
  MOVEQ   #0,D2 
  MOVE.B  65(A0),D2 
L00AF:MOVE.W  #$1C,D1 
  LEA     L00BF(PC),A4
L00B0:MOVE.L  A4,40(A5,D1.W)
  MOVE.W  #-$100,72(A5,D1.W)
  CLR.L   104(A5,D1.W)
  SUBQ.W  #4,D1 
  BPL.S   L00B0 
  MOVE.W  D2,6(A5)
  TST.B   29(A6)
  BMI.S   L00B1 
  MOVEA.L 0(A6),A4
  BSR     L0025 
L00B1:CLR.B   13(A6)
  CLR.W   20(A6)
  ST      36(A6)
  MOVE.B  29(A6),14(A6) 
  CLR.B   28(A6)
  CLR.W   54(A6)
  LEA     L00BE(PC),A4
  CLR.W   0(A4) 
  CLR.B   21(A4)
  MOVE.B  #1,22(A6) 
  RTS 
L00B2:MOVEM.L A4-A6,-(A7) 
  LEA     L00B6(PC),A6
  MOVE.L  #$40400000,30(A6) 
  CLR.B   15(A6)
  MOVE.L  D0,0(A6)
  MOVE.L  D1,4(A6)
  MOVEA.L D1,A4 
  CLR.L   (A4)
  MOVE.L  D1,8(A6)
  MOVEA.L D0,A4 
  MOVE.L  464(A4),D1
  ADD.L   D0,D1 
  MOVE.L  D1,38(A6) 
  MOVE.L  468(A4),D1
  ADD.L   D0,D1 
  MOVE.L  D1,42(A6) 
  MOVE.L  472(A4),D1
  ADD.L   D0,D1 
  MOVE.L  D1,46(A6) 
  ADDI.L  #$200,D0
  MOVE.L  D0,50(A6) 
  TST.L   24(A6)
  BNE     L00B3 
  MOVE.L  $00000070.L,24(A6)
L00B3:
  LEA     L00BC(PC),A5
  MOVE.W  #5,6(A5)
  LEA     L00BD(PC),A6
  MOVE.W  #$1F,D0 
L00B4:MOVE.W  #5,64(A6) 
  CLR.W   128(A6) 
  CLR.W   (A6)+ 
  DBF     D0,L00B4
  LEA     L00B7(PC),A4
  LEA     L00B8(PC),A5
  MOVE.L  A5,(A4)+
  LEA     L00B9(PC),A5
  MOVE.L  A5,(A4)+
  LEA     L00BA(PC),A5
  MOVE.L  A5,(A4)+
  LEA     L00BB(PC),A5
  MOVE.L  A5,(A4)+
  MOVEQ   #$B,D0
L00B5:MOVE.L  -16(A4),(A4)+ 
  DBF     D0,L00B5
  MOVEM.L (A7)+,A4-A6 
  RTS 
L00B6:DS.W    15
  DC.B   '@@',$00,$00,$00,$00,$FF,$FF 
  DS.W    10
L00B7:DS.W    32
L00B8:DS.W    10
  DC.B   $82,$01,$00,$01,$00,$00,$00,$00
  DS.W    20
  DC.B   $80,$80,$00,$80,$00,$00,$00,$82
  DC.L   ch1s,0
  DS.W    1 
  DC.B   $00,$04,$00,$00,$00,$00,$00,$00
  DS.W    18
L00B9:DS.W    10
  DC.B   $82,$02,$00,$02,$00,$00,$00,$00
  DS.W    20
  DC.B   $81,$00,$01,$00,$00,$00,$00,$82
  DC.L   ch2s,0
  DS.W    1 
  DC.B   $01,$04,$00,$00,$00,$00,$00,$00
  DS.W    18
L00BA:DS.W    10
  DC.B   $82,$04,$00,$04,$00,$00,$00,$00
  DS.W    20
  DC.B   $82,$00,$02,$00,$00,$00,$00,$82
  DC.L   ch3s,0
  DS.W    1 
  DC.B   $02,$04,$00,$00,$00,$00,$00,$00
  DS.W    18
L00BB:DS.W    10
  DC.B   $82,$08,$00,$08,$00,$00,$00,$00
  DS.W    20
  DC.B   $84,$00,$04,$00,$FF,$FF,$FE,'z'
  DC.L   ch4s,0
  DS.W    1 
  DC.B   $03,$04,$00,$00,$00,$00,$00,$00
  DS.W    18
L00BC:DS.W    3 
  DC.B   $00,$06,$00,$00,$00,$00,$00,$00
  DS.W    93
L00BD:DS.W    96
L00BE:DS.W    19
L00BF:DC.B   $F4,$00,$00,$00,$F0,$00,$00,$00

L00C0:DC.B   $06,$AE,$06,'N',$05,$F4,$05,$9E
  DC.B   $05,'M',$05,$01,$04,$B9,$04,'u'
  DC.B   $04,'5',$03,$F9,$03,$C0,$03,$8C
  DC.B   $03,'X',$03,'*',$02,$FC,$02,$D0
  DC.B   $02,$A8,$02,$82,$02,'^',$02,';'
  DC.B   $02,$1B,$01,$FD,$01,$E0,$01,$C6
  DC.B   $01,$AC,$01,$94,$01,'}',$01,'h'
  DC.B   $01,'T',$01,'@',$01,'/',$01,$1E
  DC.B   $01,$0E,$00,$FE,$00,$F0,$00,$E3
  DC.B   $00,$D6,$00,$CA,$00,$BF,$00,$B4
  DC.B   $00,$AA,$00,$A0,$00,$97,$00,$8F
  DC.B   $00,$87,$00,'',$00,'x',$00,'q'
  DC.B   $00,$D6,$00,$CA,$00,$BF,$00,$B4
  DC.B   $00,$AA,$00,$A0,$00,$97,$00,$8F
  DC.B   $00,$87,$00,'',$00,'x',$00,'q'
  DC.B   $00,$D6,$00,$CA,$00,$BF,$00,$B4
	opt o+

Old_A		DC.L 0
Old_19		DC.B 0
Old_1f		DC.B 0

; Dsp Code

DspProg		incbin a56.bin
DspProgEnd
		EVEN

;T2_Song:	incbin	t2music1.SON
;		even
;T2_Smpl:	incbin t2speech
;		incbin	t2music1.Smp

T2_Song:	incbin	d:\tfmxmods\mdat.ath
		even
T2_Smpl:	incbin	d:\tfmxmods\smpl.ath
