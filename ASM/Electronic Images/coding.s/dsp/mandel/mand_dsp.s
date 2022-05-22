; Mandelbrot Generator V2 Coded by Martin Griffiths 
; (C) August 1993. (DSP :) )

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

		MOVE.W #PAL+BPS16+VERTFLAG+COL80,-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP

fmlp		BSR mandel
		move.l mdx,d0
		lsr.l #1,d0
		move.l d0,mdx
		move.l mdy,d1
		lsr.l #1,d1
		move.l d1,mdy
		add.l d0,mx1
		add.l d0,mx1
		add.l d1,my1
		add.l d1,my1
		MOVE #7,-(SP)
		TRAP #1
		ADDQ.L #2,SP
		CMP.B #' ',D0
		BNE.S fmlp
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
		BSR rest_pal
		MOVE.L oldsp(PC),-(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		CLR -(SP)
		TRAP #1

; MandelBrot (DSP..)

width		EQU 400
height		EQU 400
mx1		DC.L $97800000
my1		DC.L $93256789
mdx		DC.L $40000000
mdy		DC.L $40000000

mandel		BSR load_dspprog

		CLR.L $FFFFA204.W
		move.l mx1,d0		;x1
		move.l my1,d2		;y1
		move.l mdx,d1		;dx
		move.l mdy,d3		;dy

		divu.l #width,d1
		lsr.l #8-2,d1
		divu.l #height,d3
		lsr.l #8-2,d3

		lsr.l #8,d0
		MOVE.L d0,$FFFFA204.W
		lsr.l #8,d2
		MOVE.L d2,$FFFFA204.W
		MOVE.L d1,$FFFFA204.W
		MOVE.L d3,$FFFFA204.W
		move.l #width,$ffffa204.w
		move.l #height,$ffffa204.w
		MOVE.L #256,$FFFFA204.W
		LEA palette(pc),a5
		MOVE #2,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		MOVE.L D0,A0
		LEA 120*2(A0),A0
		LEA $FFFFA202.W,A1
		LEA $FFFFA206.W,A2
		MOVE.W #height-1,D6
ploty_lp	MOVE.W #width-1,D7
plot_lp		BTST.B #0,(A1)
		BEQ.S plot_lp
		MOVE.W (A2),D3
		MOVE.W (A5,D3*2),(A0)+
		DBF D7,plot_lp
		LEA 240*2(A0),A0
		DBF D6,ploty_lp
		rts

		
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
		tc_rgb 0,15,i
		tc_rgb 15,0,i
		tc_rgb 15,15,i
i		SET i+1
		ENDR
i		SET 1
		REPT 31
		tc_rgb 0,i,31
		tc_rgb 10,i,31
		tc_rgb 15,i,31
		tc_rgb 20,i,31
i		SET i+1
		ENDR
		tc_rgb 17,0,31
		tc_rgb 17,31,0
		tc_rgb 19,0,0
		tc_rgb 20,0,31
		tc_rgb 0,0,0
 		tc_rgb 17,0,31
		tc_rgb 17,31,0
		tc_rgb 19,0,0
		tc_rgb 20,0,31
		tc_rgb 0,0,0
		
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

; Dsp loader

load_dspprog	MOVE.W #1,-(A7)		; ability
		MOVE.L #((DspProgEnd-DspProg)/3),-(A7)	; no. of dsp words
		PEA DspProg(PC)		; buf
		MOVE.W #$6E,-(A7)	; dsp_execboot
		TRAP #14
		LEA 12(A7),A7
		RTS

DspProg		incbin mandel3.bin
DspProgEnd
		EVEN

oldvideo	DS.W 1
oldbase		DS.L 1
oldsp		DS.L 1

		SECTION BSS 
old_pal		DS.W 16
old_falcpal	DS.L 256
screen		DS.B 256
		DS.B 512000
