; Mandelbrot Generator V2 Coded by Martin Griffiths 
; (C) August 1993.

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

ystart		EQU -$1200
xstart		EQU -$1B00
yinc		EQU $16*2
xinc		EQU $E*2

; Numbers in following format
; 16bit(one word) structure
;  15   14 13 12   11 10 9....0
; sign   integer	   fraction

		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.L D0,oldsp
		MOVE.W #-1,-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP
		MOVE.W D0,oldvideo
		MOVE.W #2,-(SP)
		TRAP #14		
		ADDQ.L #2,SP	
		MOVE.L D0,oldbase
		BSR save_pal
		BSR Initscreens
		
		MOVE.W #PAL+BPS16,-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP

		MOVE #2,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		MOVE.L D0,A1
cls		MOVE.L A1,A0
		MOVE #1999,D0
		MOVEQ #0,D1
clslp		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D0,clslp

		LEA palette(pc),a5
		MOVE.L A1,A0
		MOVE.L #$4000000,A4
		MOVE #200,d2
		MOVE #ystart,A3
y_lp		MOVE #xstart,A2
		MOVE #320-1,D4
xpixel_lp	MOVEQ #0,D5
		MOVEQ #0,D6
		MOVEQ #0,D0
		MOVE.L D5,A6
		MOVEQ #63,D3
iterate_lp	SUB.L D0,A6		; x2-y2
		MOVE.L A6,D7
		ASL.L #4,D7
		SWAP D7
		ADD.W A2,D7		; x=x2-y2+u	
		MULS D5,D6		; y*x
		ASL.L #5,D6		; *2
		SWAP D6
		ADD.W A3,D6		; y=(2*x*y)+v
		MOVE D7,D5		
		MULS D7,D7		; x*x
		MOVE.L D7,A6	; x2=x*x
		MOVE D6,D0
		MULS D0,D0		; y*y
		ADD.L D0,D7		; x2+y2
		CMP.L A4,D7		; >=4
		DBHI D3,iterate_lp
plot		MOVE.W (A5,D3*2),(A0)+
		LEA xinc(A2),A2
		DBF D4,xpixel_lp
		LEA yinc(A3),A3
		DBF D2,y_lp
		MOVE #$2300,SR
		MOVE #7,-(SP)
		TRAP #1
		ADDQ.L #2,SP

		BSR rest_pal
		MOVE.W #-1,-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.W #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		MOVE.W oldvideo(pc),-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP
		MOVE.L oldsp(PC),-(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		CLR -(SP)
		TRAP #1
		
		dc.w 0
palette		
;                         RRRRRGGGGGSBBBBB
;		dc.w     %1234512345123450

tc_rgb		MACRO
		DC.W (\1<<11)+(\2<<6)+\3
		ENDM
i		SET 1
		REPT 30
		tc_rgb 0,0,i
i		SET i+1
		ENDR
i		SET 1
		REPT 31
		tc_rgb 0,i,31
i		SET i+1
		ENDR
		tc_rgb 1,31,31
		tc_rgb 2,31,31
		tc_rgb 3,31,31
		
save_pal	MOVEM.L $FFFF8240.W,D0-D7
		MOVEM.L D0-D7,old_pal
		LEA $FFFF9800.W,A0
		LEA old_falcpal,A1
		MOVE #256-1,D0
.save_pallp	MOVE.L (A0)+,(A1)+
		DBF D0,.save_pallp		
		RTS

rest_pal	MOVEM.L old_pal,D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		LEA old_falcpal,A0
		LEA $FFFF9800.W,A1
		MOVE #256-1,D0
.rest_pallp	MOVE.L (A0)+,(A1)+
		DBF D0,.rest_pallp		
		RTS

Initscreens	MOVE.L #screen+256,d0
		CLR.B D0
		MOVE.W #-1,-(SP)
		MOVE.L D0,-(SP)
		MOVE.L D0,-(SP)
		MOVE.W #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		MOVE.W #37,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		RTS


oldvideo	DS.W 1
oldbase		DS.L 1
oldsp		DS.L 1

		SECTION BSS 
old_pal		DS.W 16
old_falcpal	DS.L 256
screen		DS.B 256
		DS.B 128000
