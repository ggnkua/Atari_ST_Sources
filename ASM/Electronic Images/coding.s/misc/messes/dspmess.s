;-----------------------------------------------------------------------;

;-----------------------------------------------------------------------;

; SetVideo() equates.

VERTFLAG	EQU $0100	; double-line on VGA, interlace on ST/TV ;
STMODES		EQU $0080	; ST compatible ;
OVERSCAN	EQU $0040	; Multiply X&Y rez by 1.2, ignored on VGA ;
PAL		EQU $0020	; PAL if set, else NTSC ;
VGA		EQU $0010	; VGA if set, else TV mode ;
COL80		EQU $0008	; 80 column if set, else 40 column ;
BPS16		EQU $0004
BPS8		EQU $0003
BPS4		EQU $0002
BPS2		EQU $0001
BPS1		EQU $0000

; Cache Control Register Equates (CACR)

ENABLE_CACHE		EQU 1   ; Enable instruction cache
FREEZE_CACHE		EQU 2   ; Freeze instruction cache
CLEAR_INST_CACHE_ENTRY	EQU 4   ; Clear instruction cache entry
CLEAR_INST_CACHE	EQU 8   ; Clear instruction cache
INST_BURST_ENABLE	EQU 16  ; Instruction burst enable
ENABLE_DATA_CACHE	EQU 256 ; Enable data cache
FREEZE_DATA_CACHE	EQU 512 ; Freeze data cache
CLEAR_DATA_CACHE_ENTRY	EQU 1024 ; Clear data cache entry
CLEAR_DATA_CACHE	EQU 2048 ; Clear data cache
DATA_BURST_ENABLE	EQU 4096 ; Instruction burst enable
WRITE_ALLOCATE		EQU 8192 ; Write allocate 

linewidth	equ 768

		OPT O+,OW-

demo		EQU 0

letsgo		MOVE.L 4(SP),A5
		MOVE.L $C(A5),A4
		ADD.L $14(A5),A4
		ADD.L $1C(A5),A4
		LEA $100(A4),A4			; proggy size+basepage
		PEA (A4)
		PEA (A5)
		CLR -(SP)
		MOVE #$4A,-(SP)
		TRAP #1				; reserve some memory
		LEA 12(SP),SP
		MOVE.W #-1,-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP
		MOVE.W D0,oldvideo
		MOVE.W #2,-(SP)
		TRAP #14		
		ADDQ.L #2,SP	
		MOVE.L D0,oldbase
		CLR.L -(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.L D0,oldsp

		LEA my_stack,SP
		
		BSR Initscreens
		BSR load_dspprog	
		MOVE.L D0,$FFFFA204.W	;stobe to continue

		MOVE.W #$2700,SR
		LEA oldmfp(PC),A0
		MOVE.L $14.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $114.W,(A0)+
		MOVE.L $120.W,(A0)+
		MOVE.L $134.W,(A0)+
		MOVE.L $13C.W,(A0)+
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.B $FFFFFA19.W,(A0)+
		MOVE.B $FFFFFA1B.W,(A0)+
		MOVE.B $FFFFFA1D.W,(A0)+
		MOVE.B $FFFFFA1f.W,(A0)+
		MOVE.B $FFFFFA21.W,(A0)+
		MOVE.B $FFFFFA23.W,(A0)+
		LEA anrte(PC),A0
		MOVE.L A0,$14.W
		LEA vbl(PC),A0
		MOVE.L A0,$70.W
		MOVE.B #$70,$FFFFFA1D.W
		MOVE.B #0,$FFFFFA07.W
		MOVE.B #0,$fffffa09.W 
		MOVE.B #0,$FFFFFA13.W
		MOVE.B #0,$fffffa15.W 
		BCLR.B #3,$FFFFFA17.W
		MOVE #$2300,SR 
		BSR wait_vbl
		BSR SetScreen
		MOVE.W #STMODES+VGA+VERTFLAG+BPS4,-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP
		BSR cpy_pic		
		BSR wait_vbl

		
.vbl_lp		BSR wait_vbl
		BSR dsp_mess
		CMP.B #$39,$FFFFFC02.W
		BNE.S .vbl_lp

		MOVE #$2700,SR 
		LEA oldmfp(PC),A0
		MOVE.L (A0)+,$14.W
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$114.W
		MOVE.L (A0)+,$120.W
		MOVE.L (A0)+,$134.W
		MOVE.L (A0)+,$13C.W
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.B (A0)+,$FFFFFA19.W
		MOVE.B (A0)+,$FFFFFA1B.W
		MOVE.B (A0)+,$FFFFFA1D.W
		MOVE.B (A0)+,$FFFFFA1F.W
		MOVE.B (A0)+,$FFFFFA21.W
		MOVE.B (A0)+,$FFFFFA23.W
		MOVE.B #$C0,$FFFFFA23.W
		BSET.B #3,$FFFFFA17.W
		BSR flush
		MOVE.W #$2300,SR
		
		MOVE.W oldvideo(PC),-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP
		MOVE.W oldvideo(PC),-(SP)
		MOVE.W #-1,-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.W #5,-(SP)
		TRAP #14
		LEA 14(SP),SP
		MOVE.L oldsp(PC),-(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP

		CLR -(SP)
		TRAP #1

dsp_mess        move.l #40*160,d1
                move.w  #%0001100110100101,$FFFF8930.w
                move.w  #%0100110010010010,$FFFF8932.w


		move.b  #1,$FFFF8935.w  ;49.2khz


		move.b  #3,$FFFF8920.w ; play 4 track,dac to track 1
		move.b  #3,$ffff8936.w ; record 4 track
		move.b  #64,$FFFF8921.w ; 16 bit stereo,
		sf donetransflag
		BSET.B #7,$FFFFFA03.W	; at END of interrupt
		MOVE.L #donetrans,$13C.W
		BSET.B #7,$FFFFFA07.W
		BSET.B #7,$FFFFFA13.W

                bclr    #7,$FFFF8901.w  ; select playback register
		move.l log_base(pc),a1
		lea (a1,d1.l),a2
                jsr     set_dmaaddr
                bset    #7,$FFFF8901.w  ; select playback register
		move.l log_base(pc),a1
		lea 100*160(a1),a1
		lea (a1,d1.l),a2
                jsr     set_dmaaddr
		move.w	#$200+16+1,$ffff8900.w

		not.l $ffff9800.w
;.wait		tst.b donetransflag
;		beq.s .wait
		not.l $ffff9800.w
		rts

donetrans	st donetransflag
		rte
donetransflag	DC.W 0

set_dmaaddr:    move.l  A1,D0
                move.b  D0,$FFFF8907.w
		lsr.l #8,d0
                move.b  D0,$FFFF8905.w ; set start of buffer
		lsr.l #8,d0
                move.b  D0,$FFFF8903.w
                move.l  A2,D0
                move.b  D0,$FFFF8913.w
		lsr.l #8,d0
                move.b  D0,$FFFF8911.w ; set end of buffer
		lsr.l #8,d0
                move.b  D0,$FFFF890f.w
                rts

anrte		RTE

oldvideo	DC.W 0
oldbase		DC.L 0
oldsp		DS.L 1
oldmfp		DS.L 22

; Initialise 3 screens.

Initscreens	LEA log_base(PC),A1
	  	MOVE.L #screens+256,D0
		CLR.B D0
		MOVE.L D0,(A1)+
		ADD.L #192000,D0
		MOVE.L D0,(A1)+
		ADD.L #192000,D0
		MOVE.L D0,(A1)+
		RTS
log_base	DC.L 0
		DC.L 0
		DC.L 0
		DC.W 0

ClearScreens	MOVE.L log_base(PC),D0
		BSR cls
		MOVE.L log_base+4(PC),D0
		BSR cls
		MOVE.L log_base+8(PC),D0
		BRA cls


SetScreen	MOVE.L log_base(PC),D0
		MOVE.B D0,$FFFF820D.W
		LSR.L #8,D0
		MOVE.B D0,$FFFF8203.W
		LSR.L #8,D0
		MOVE.B D0,$FFFF8201.W
		RTS

cls		MOVE.L D0,A0
		MOVE.W #(250*linewidth)/16-1,D2
		MOVEQ #0,D1
.lp		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D2,.lp
		RTS

; Flush keyboard

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
flok		RTS

wait_vbl	MOVE.W $468.W,D0
.waitvb		CMP.W $468.W,D0	
		BEQ.S .waitvb
		RTS

; Little old vbl..

vbl		ADDQ.L #1,$466.W
		RTE 

; Dsp loader

load_dspprog	MOVE.W #1,-(A7)		; ability
		MOVE.L #((DspProgEnd-DspProg)/3),-(A7)	; no. of dsp words
		PEA DspProg(PC)		; buf
		MOVE.W #$6E,-(A7)	; dsp_execboot
		TRAP #14
		LEA 12(A7),A7
		RTS

DspProg		incbin d:\coding.s\messes\mess.bin
DspProgEnd
		EVEN

cpy_pic		LEA pic+34,a0
		move.l log_base,a1
		move.w #7999,d0
.lp		move.l (a0)+,(a1)+
		dbf d0,.lp
		rts

pic		incbin ic.pi1

		SECTION BSS

		DS.L 499
my_stack	DS.L 3
		
		DS.W 768
screens		DS.B 256
		DS.W 768*480
		DS.W 768
