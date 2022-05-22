;-----------------------------------------------------------------------;

;-----------------------------------------------------------------------;

		OPT	D+

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

vhz	        EQU $FFFF820A
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

letsgo		
		CLR.L -(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.L D0,oldsp

		BSR	wait_vbl
		MOVE.W #-1,-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP
		AND.W	#$1FF,D0
		MOVE.W D0,oldvideo
		MOVE.W #2,-(SP)
		TRAP #14		
		ADDQ.L #2,SP	
		MOVE.L D0,oldpbase
		MOVE.W #3,-(SP)
		TRAP #14		
		ADDQ.L #2,SP	
		MOVE.L D0,oldlbase


		LEA my_stack,SP
		LEA TC320_VGA(PC),A6
		BSR set_vid
		
		BSR Initscreens
		BSR cpy_pic		
		
		move.w	#7,-(sp)
		trap	#1
		addq.l	#2,sp
		MOVE.W #-1,-(SP)
		MOVE.L oldlbase(PC),-(SP)
		MOVE.L oldpbase(PC),-(SP)
		MOVE.W #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		MOVE.W oldvideo(PC),-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP

		MOVE.L oldsp(PC),-(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP


		CLR -(SP)
		TRAP #1

anrte		RTE

oldvideo	DC.W 0
oldpbase	DC.L 0
oldlbase	DC.L 0
oldsp		DS.L 1
log_base	DC.L 0

; Initialise 3 screens.

Initscreens	LEA log_base(PC),A1
	  	MOVE.L #screens+256,D0
		CLR.B D0
		MOVE.L D0,(A1)+
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

set_vid		MOVE.W	#37,-(SP)
		TRAP	#14
		ADDQ.L	#2,SP
		move #(_spshift),a1
		clr.w	(a1)
		LEA (hht).w,A1
		MOVE.L (a6)+,(A1)+
		MOVE.L (a6)+,(A1)+
		MOVE.L (a6)+,(A1)+
		MOVE.L (a6)+,(A1)+
		LEA (vft).w,A1
		MOVE.L (a6)+,(A1)+
		MOVE.L (a6)+,(A1)+
		MOVE.L (a6)+,(A1)+
SetScreen	MOVE.L log_base(PC),D0
		MOVE.B D0,$FFFF820D.W
		LSR.L #8,D0
		MOVE.B D0,$FFFF8203.W
		LSR.L #8,D0
		MOVE.B D0,$FFFF8201.W
		move #(voff_nl),a1
	        move.w  (a6)+,(a1)
		move #(vwrap),a1
		MOVE.W  (a6)+,(a1)
		movea #(vco),a1
                move.w  (a6)+,(a1)
		movea #(vco_hi),a1
                move.w  (a6)+,(a1)
		movea #(vhz),a1
                move.w  (a6)+,(a1)
		move #(_spshift),a1
		move.w  (a6),(a1)
		RTS

TC320_VGA	DC.W	$00C6 ; hht
		DC.W	$008D ; hbb
		DC.W	$0015 ; hbe
		DC.W	$02AC ; hdb
		DC.W	$0091 ; hde
		DC.W	$0096 ; hss
		DC.W	$0000 ; hfs
		DC.W	$0000 ; hee
		DC.W	$0419 ; vft
		DC.W	$03FF ; vbb
		DC.W	$003F ; vbe
		DC.W	$003F ; vdb
		DC.W	$03FF ; vde
		DC.W	$0415 ; vss
		DC.W	$0000 ; next line offset
		DC.W	$0140 ; vwrap
		DC.W	$0005 ; vco
		DC.W	$0186 ; vco hi
		DC.W	$0000 ; $ffff820a
		DC.W	$0100 ; spshift

wait_vbl	MOVE.W	#37,-(SP)
		TRAP	#14
		ADDQ.L	#2,SP
		RTS

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
		rept 16
		pset
		endr
		dbf d1,.ch_lp
		LEA 320*2(A2),A2
		dbf d0,.lp
		rts

pic		incbin ic.pi1

		SECTION BSS

		DS.L 399
my_stack	DS.L 3
		
screens		DS.B 256
		ds.b 512000
