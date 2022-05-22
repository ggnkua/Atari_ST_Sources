;-----------------------------------------------------------------------;
;									;
;   Fast Phong shading polygon routines,				;
; 				 by Martin Griffiths August 1993	;
;									;
; - Normal Interpolation with "Moire" dither shading			;
;									;
;-----------------------------------------------------------------------;

linewidth	equ 768

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
		MOVEC.L CACR,D0
		MOVE.L D0,oldCACR

		MOVE.W #$2700,SR
		LEA oldmfp(PC),A0
		MOVE.L $14.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $114.W,(A0)+
		MOVE.L $120.W,(A0)+
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.B $FFFFFA1B.W,(A0)+
		MOVE.B $FFFFFA1D.W,(A0)+
		MOVE.B $FFFFFA21.W,(A0)+
		MOVE.B $FFFFFA23.W,(A0)+
		LEA anrte(PC),A0
		MOVE.L A0,$14.W
		LEA vbl(PC),A0
		MOVE.L A0,$70.W
		LEA anrte(PC),A0
		MOVE.L A0,$114.W 
		MOVE.B #$70,$FFFFFA1D.W
		MOVE.B #$00,$FFFFFA07.W
		MOVE.B #$00,$fffffa09.W 
		MOVE.B #$00,$FFFFFA13.W
		MOVE.B #$00,$fffffa15.W 
		BCLR.B #3,$FFFFFA17.W
		MOVE #$2300,SR 
		BSR Initscreens
		BSR wait_vbl
		BSR SetScreen
		BSR wait_vbl
		MOVE.W #VGA+VERTFLAG+BPS4,-(SP)
		;MOVE.W #PAL+BPS16+OVERSCAN,-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP

;		CLR.L $ffff9800.w
		BSR ClearScreens		
		BSR wait_vbl
		BSR flush

		CLR.L $466.W

.vbl_lp		;BSR ClearIt
		;BSR SwapScreens
		CMP.B #$39,$FFFFFC02.W
		BNE.S .vbl_lp

		MOVE #$2700,SR 
		LEA oldmfp(PC),A0
		MOVE.L (A0)+,$14.W
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$114.W
		MOVE.L (A0)+,$120.W
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.B (A0)+,$FFFFFA1B.W
		MOVE.B (A0)+,$FFFFFA1D.W
		MOVE.B (A0)+,$FFFFFA21.W
		MOVE.B (A0)+,$FFFFFA23.W
		MOVE.B #$C0,$FFFFFA23.W
		BSET.B #3,$FFFFFA17.W
		BSR flush
		MOVE.W #$2300,SR
		MOVE.L oldCACR(PC),d0
		MOVEC.L D0,CACR
		
		MOVE.W oldvideo(PC),-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP
		MOVE.W #37,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		MOVE.W #-1,-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.W #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		MOVE.L oldsp(PC),-(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP

		CLR -(SP)
		TRAP #1

oldvideo	DC.W 0
oldbase		DC.L 0
oldsp		DS.L 1
oldCACR		DS.L 1
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
log_base	DC.L 	0
phy_base	DC.L 	0
		DC.L	 0

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

; Clear screen very quickly.

ClearIt		MOVE.L log_base(PC),A0
		ADD.L #(250*linewidth)-80-(20*linewidth),A0
		MOVEQ #0,D0
		MOVE.L D0,D1
		MOVE.L D0,D2
		MOVE.L D0,D3
		MOVE.L D0,D4
		MOVE.L D0,D5
		MOVE.L D0,D6
		MOVE.L D0,A1
		MOVE.L D0,A2
		MOVE.L D0,A3
		MOVE.L D0,A4
		MOVE.L D0,A5
		MOVE.L D0,A6
		MOVE.W #210-1,D7
.lp		
		REPT 11
		MOVEM.L D0-D6/a1-A6,-(A0) 
		ENDR
		MOVEM.L D0-D6/a1-A2,-(A0) 
		LEA -160(A0),A0
		DBF D7,.lp
		RTS

; Swap Screen ptrs and set hware reg.

SwapScreens    	
.wait		TST.L $466.W
		BEQ.s .wait
		CLR.L $466.W
		MOVE.W #$2700,SR
		LEA log_base(PC),A0
		MOVE.L (A0)+,D0
		MOVE.L (A0)+,-8(A0)
		MOVE.L (A0),-4(A0) 
		MOVE.L D0,(A0) 
		LEA $FFFF8201.W,A0
		LSR.L #8,D0 
		MOVEP.W D0,(A0) 
		MOVE.W #$2300,SR
		RTS 

wait_vbl	MOVE.L $466.W,D0
.waitvb		CMP.L $466.W,D0	
		BEQ.S .waitvb
		RTS

; Little old vbl..

vbl		MOVEM.L D0-A6,-(SP)	
	
		MOVE.L #ENABLE_CACHE+CLEAR_INST_CACHE+ENABLE_DATA_CACHE+CLEAR_DATA_CACHE,D0
		MOVEC.L D0,CACR
		LEA $FFFF8209.W,A0
.wait		TST.B (A0)
		BEQ.S .wait
		DCB.W 3000,$4E71
		NOT.L $FFFF9800.W
		MOVEM.L (SP)+,D0-A6
		ADDQ.L #1,$466.W

anrte		RTE 
currpal		DS.W 16


		SECTION BSS

		DS.L 499
my_stack	DS.L 3
		
		DS.W 768
screens		DS.B 256
		DS.W 768*480
		DS.W 768
