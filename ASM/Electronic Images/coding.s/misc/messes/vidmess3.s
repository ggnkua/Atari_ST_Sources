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

; Falcon video register equates

voff_nl         EQU $FFFF820E
vwrap           EQU $FFFF8210
_stshift	EQU $FFFF8260
_spshift        EQU $FFFF8266
hht             EQU $FFFF8282
hbb             EQU $FFFF8284
hbe             EQU $FFFF8286
hdb             EQU $FFFF8288
hde             EQU $FFFF828A
hss             EQU $FFFF828C
hfs             EQU $FFFF828E
hee             EQU $FFFF8290
vft             EQU $FFFF82A2
vbb             EQU $FFFF82A4
vbe             EQU $FFFF82A6
vdb             EQU $FFFF82A8
vde             EQU $FFFF82AA
vss             EQU $FFFF82AC

vco_hi          EQU $FFFF82C0
vco             EQU $FFFF82C2

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
		MOVE.L  #$48000000,$FFFF9800.W
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
		BSR cpy_pic		
		BSR wait_vbl
		BSR SetScreen
		BSR wait_vbl
		BSR set_vid
		BSR wait_vbl
		BSR SetScreen

		
.vbl_lp		BSR wait_vbl
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
		MOVE.W #37,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		
		MOVE.L #$F8F800F8,$FFFF9800.W
		MOVE.L oldsp(PC),-(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.W #-1,-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.W #5,-(SP)
		TRAP #14
		LEA 12(SP),SP

		CLR -(SP)
		TRAP #1

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

; Set Video.

set_vid		LEA v1600600_256(PC),A0
		MOVE.W SR,-(SP)
		MOVE.W #$2700,SR
		clr.w (_spshift).w
		move.w  (A0)+,(_spshift).w
		move.b (a0)+,d0
		move.b (a0)+,d1
		tst.b d0
		beq.s .noset_st
		MOVE.B	d1,(_stshift).w
.noset_st       move.w  (A0)+,(voff_nl).w
		move.w #320,(vwrap).w
		addq.l #2,a0
		;MOVE.W  (A0)+,(vwrap).w
                move.w  (A0)+,(vco).w
                move.w  (A0)+,(vco_hi).w
		LEA (hht).w,A1
		MOVE.L (a0)+,(A1)+
		MOVE.L (a0)+,(A1)+
		MOVE.L (a0)+,(A1)+
		MOVE.L (a0)+,(A1)+
		LEA (vft).w,A1
		MOVE.L (a0)+,(A1)+
		MOVE.L (a0)+,(A1)+
		MOVE.L (a0)+,(A1)+
		MOVE.W (SP)+,SR
		RTS

v1600600_16
	DC.W	$0000  ; spshift
	DC.B	-1,$00 ; st shift
	DC.W	$0000 ; next line offset
	DC.W	$0190 ; vwrap
	DC.W	$000A ; vco
	DC.W	$0083 ; vco hi
	DC.W	$003E ; hht
	DC.W	$0032 ; hbb
	DC.W	$0009 ; hbe
	DC.W	$023D ; hdb
	DC.W	$002E ; hde
	DC.W	$0034 ; hss
	DC.W	$0000 ; hfs
	DC.W	$0000 ; hee
	DC.W	$0270 ; vft
	DC.W	$026C ; vbb
	DC.W	$000F ; vbe
	DC.W	$000F ; vdb
	DC.W	$025F ; vde
	DC.W	$026E ; vss

v1600600_256
	DC.W	$0010  ; spshift
	DC.B	-1,$00 ; st shift
	DC.W	$0000 ; next line offset
	DC.W	$0190 ; vwrap
	DC.W	$000A ; vco
	DC.W	$0083 ; vco hi
	DC.W	$003E ; hht
	DC.W	$0032 ; hbb
	DC.W	$0009 ; hbe
	DC.W	$023D ; hdb
	DC.W	$002E ; hde
	DC.W	$0034 ; hss
	DC.W	$0000 ; hfs
	DC.W	$0000 ; hee
	DC.W	$0270+70 ; vft
	DC.W	$026C ; vbb
	DC.W	$005F ; vbe
	DC.W	$005F ; vdb
	DC.W	$025F ; vde
	DC.W	$026E+70 ; vss

v1600600_4
	DC.W	$0100  ; spshift
	DC.B	-1,$00 ; st shift
	DC.W	$0000 ; next line offset
	DC.W	$00c8 ; vwrap
	DC.W	$000A ; vco
	DC.W	$0000 ; vco hi
	DC.W	$003E ; hht
	DC.W	$0032*32 ; hbb
	DC.W	$0009*256 ; hbe
	DC.W	$023D ; hdb
	DC.W	$002E*16 ; hde
	DC.W	$0034 ; hss (+2)
	DC.W	$0000 ; hfs
	DC.W	$0000 ; hee
	DC.W	$0270 ; vft
	DC.W	$026C ; vbb
	DC.W	$000F ; vbe
	DC.W	$000F ; vdb
	DC.W	$025F ; vde
	DC.W	$026E ; vss
	EVEN


	EVEN

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

vbl		MOVEM.L D0-A6,-(SP)
;		BSR SetScreen
		MOVEM.L (SP)+,D0-A6
		ADDQ.L #1,$466.W
		RTE 

pset		MACRO
		ADD.W D4,D4
		ADDX D3,D3		
		ADD.W D5,D5
		ADDX D3,D3	
		ADD.W D6,D6
		ADDX D3,D3	
		ADD.W D7,D7
		ADDX D3,D3	
		MOVE.B D3,(A1)+
		CLR.B (A1)+
		ENDM
cpy_pic		LEA pic+34,a0
		move.l log_base,a2
		move.w #199,d0
.lp		move.l a2,a1
		moveq #20-1,d1	
.ch_lp		movem.w (a0)+,d4-d7
		movem.w d4-d7,(a1)
		add.l #8,a1
;		rept 16
;		pset
;		endr
		dbf d1,.ch_lp
		move #1600-320,d1
.lp2		clr.w (a1)+
		dbf d1,.lp2
		LEA 640(A2),A2
		
		dbf d0,.lp
		rts

pic		incbin ic.pi1

		SECTION BSS

		DS.L 499
my_stack	DS.L 3
		
screens		DS.B 256
