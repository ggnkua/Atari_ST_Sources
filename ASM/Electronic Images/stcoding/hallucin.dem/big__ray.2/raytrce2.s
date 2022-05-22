;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;
;				 					;
;			 BIGGIE Raytraced bit		 		;
;				 					;
;   Programming : Jose Commins (aka The Phantom of Electronic Images)   ;
;		: Martin Griffiths (aka Griff of Electronic Images)	;				 					;
;				 					;
;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;

demo		EQU 0				; 0=gem 1=from DMA disk
	
letsgo		
		IFEQ demo
		MOVE.W #4,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		MOVE.W D0,oldres
		MOVE.W #2,-(SP)
		TRAP #14		
		ADDQ.L #2,SP	
		MOVE.L D0,oldbase
		CLR -(SP)
		PEA -1.W
		PEA -1.W
		MOVE.W #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.L D0,oldsp
		MOVE.B #0,$FFFF8E21.W

		ELSEIF

		ORG $10000
		MOVE.L SP,oldsp

		ENDC

		LEA my_stack,SP			; our own stack
		MOVE #$8240,A0
		MOVEQ #0,D0
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+			; clear pal
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		IFNE demo
		JSR $508
		ENDC
		BSR movepic
		BSR SetScreen
		BSR set_ints			; init ints
		MOVE #(30*50)-1,D7
vbl_lp3		MOVE.W D7,-(SP)
		BSR Wait_Vbl	
		BTST.B #0,$FFFFFC00.W
		BEQ.S .cont
		CMP.B #$39,$FFFFFC02.W		; <SPACE> exits.
		BEQ.S restore
.cont		MOVE.W (SP)+,D7
		DBF D7,vbl_lp3

restore		MOVE #$2700,SR
		BSR flush
		LEA old_mfp,A0
		MOVE.B (A0)+,$FFFFFA07.W
	        MOVE.B (A0)+,$FFFFFA09.W
        	MOVE.B (A0)+,$FFFFFA13.W	; restore mfp
        	MOVE.B (A0)+,$FFFFFA15.W
	        MOVE.B (A0)+,$FFFFFA19.W
            	MOVE.B (A0)+,$FFFFFA1F.W
		MOVE.L (A0)+,$68.W
		MOVE.L (A0)+,$70.W		; and vects
		MOVE.L (A0)+,$134.W
		MOVE #$2300,SR

		IFEQ demo
		MOVE.L #$07770000,$FFFF8240.W
		MOVE.L #$00000000,$FFFF8244.W
		MOVE.L oldsp(PC),-(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.W oldres(PC),-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.W #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		CLR -(SP)
		TRAP #1
oldbase		DS.L 1
oldres		DS.W 1
		ELSEIF

		MOVE.L oldsp(PC),SP
		RTS
		ENDC

oldsp		DC.L 0

; Setup MFP etc for interrupts.

set_ints	MOVE.W SR,-(SP)
		MOVE.W #$2700,SR		
		BSR flush			; flush IKBD
		LEA old_mfp,A0
		MOVE.B $FFFFFA07.W,(A0)+
	        MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
        	MOVE.B $FFFFFA15.W,(A0)+
	        MOVE.B $FFFFFA19.W,(A0)+	; save all vectors
        	MOVE.B $FFFFFA1F.W,(A0)+	; that we change
		MOVE.L $68.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $134.W,(A0)+
	        MOVE.B #$20,$FFFFFA07.W		; timer a and hbl
	        CLR.B $FFFFFA09.W		
        	MOVE.B #$20,$FFFFFA13.W		
		CLR.B $FFFFFA15.W
		CLR.B $FFFFFA19.W		; clear em out
		MOVE.L #phbl,$68.W
		MOVE.L #first_vbl,$70.W
		MOVE.L #syncscroll,$134.W	; and set our vectors
		BCLR.B #3,$FFFFFA17.W		; soft end of interrupt
		MOVE.W (SP)+,SR
		RTS

; Flush keyboard

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
flok		RTS

old_mfp		DS.L 32				; saved mfp vects etc

; Wait for a vbl

Wait_Vbl	MOVE.W vbl_timer(pc),d0
.wait_vbl	CMP.W vbl_timer(pc),d0
		BEQ.S .wait_vbl
		RTS

; The Vbl - simple triggers off timers and clears palette.

first_vbl	MOVEM.L D0-D7/A0-A6,-(SP)
		IFNE demo
		JSR $504
		ENDC
		MOVEM.L (SP)+,D0-D7/A0-A6
		MOVE.L #vbl,$70.W		; install main vbl
		ADDQ #1,vbl_timer
		RTE
			
vbl		MOVE.B #99,$FFFFFA1F.W		; set off timer(top border)
		MOVE.B #4,$FFFFFA19.W
		MOVEM.L D0-A6,-(SP)
		MOVE #$8240,A0
		MOVEQ #0,D0
		REPT 8
		MOVE.L D0,(A0)+
		ENDR
		IFNE demo
		JSR $504
		ENDC
		MOVEM.L (SP)+,D0-A6
		ADDQ #1,vbl_timer
		RTE

vbl_timer	ds.w 1

syncscroll	MOVE #$2100,SR			; ipl=1(hbl)
		STOP #$2100			; wait for processor hbl
		MOVE #$2700,SR			; (we are now synced with 8 cycles!!!)
		CLR.B $FFFFFA19.W
		MOVEM.L D0-D7/A0-A6,-(SP)
		DCB.W 50,$4E71
		MOVE.B #0,$FFFF820A.W		; zap into 60hz
		DCB.W 6,$4E71
		CLR D1				; top border removed!!
		MOVE #$8209,A0	
		MOVE.B #2,$FFFF820A.W		; switch back to 50hz
syncloop	MOVE.B (A0),D1
		BEQ.S	syncloop		
		MOVEQ #16,D2
		SUB D1,D2
		LSL D2,D1			; sync with screen.
		DCB.W 53,$4E71
                moveq #0,D2
                moveq #2,D3
	        moveq #33-1,D4
		MOVE.L pal_ptr(PC),A3
                lea $FFFF8240.w,A4
                lea $FFFF8209.w,A5
                lea $FFFF820A.w,A6
                lea (A4),A0
                lea (A4),A1
                lea (A4),A2
                move.l A0,A5
		move.w #227-1,d7

                move.l  (A3)+,(A0)+
                move.l  (A3)+,(A0)+
                move.l  (A3)+,(A0)+
                move.l  (A3)+,(A0)+
                move.l  (A3)+,(A0)+
                move.l  (A3)+,(A0)+
                move.l  (A3)+,(A0)+
                move.l  (A3)+,(A0)+

dopal:          lea     (A4),A0
                lea     (A4),A1
                lea     (A4),A2
                move.l  (A3)+,(A0)+
                move.l  (A3)+,(A0)+
                move.l  (A3)+,(A0)+
                move.l  (A3)+,(A0)+
                move.l  (A3)+,(A0)+
                move.l  (A3)+,(A0)+
                move.l  (A3)+,(A0)+
                move.l  (A3)+,(A0)+
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A2)+
                move.l  (A3)+,(A2)+
                move.l  (A3)+,(A2)+
                move.l  (A3)+,(A2)+
                move.l  (A3)+,(A2)+
                move.l  (A3)+,(A2)+
                move.l  (A3)+,(A2)+
                move.l  (A3)+,(A2)+
                nop
                nop
                dbra    D7,dopal

                lea     (A4),A2
                lea     (A4),A1
                move.l  (A3)+,(A5)+
                move.l  (A3)+,(A5)+
                move.l  (A3)+,(A5)+
                move.l  (A3)+,(A5)+
                move.l  (A3)+,(A5)+
                move.l  (A3)+,(A5)+
                move.l  (A3)+,(A5)+
                move.l  (A3)+,(A5)+
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A2)+
                move.l  (A3)+,(A2)+
                move.l  (A3)+,(A2)+
                move.l  (A3)+,(A2)+
                move.l  (A3)+,(A2)+
                move.b  D2,(A6)
		nop
                move.b  D3,(A6)
                move.l  (A3)+,(A2)+

                move.l  (A3)+,(A2)+
                move.l  (A3)+,(A2)+

dopal2:         lea     (A4),A0
                lea     (A4),A1
                lea     (A4),A2
                move.l  (A3)+,(A0)+
                move.l  (A3)+,(A0)+
                move.l  (A3)+,(A0)+
                move.l  (A3)+,(A0)+
                move.l  (A3)+,(A0)+
                move.l  (A3)+,(A0)+
                move.l  (A3)+,(A0)+
                move.l  (A3)+,(A0)+
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A2)+
                move.l  (A3)+,(A2)+
                move.l  (A3)+,(A2)+
                move.l  (A3)+,(A2)+
                move.l  (A3)+,(A2)+
                move.l  (A3)+,(A2)+
                move.l  (A3)+,(A2)+
                move.l  (A3)+,(A2)+
                nop
                nop
                dbra    D4,dopal2

		MOVEQ #0,D0
		REPT 8
		MOVE.L D0,(A4)+
		ENDR
		MOVEM.L (SP)+,D0-D7/A0-A6
		BSR SetScreen
phbl		RTE

; Set the Screen address and hardware scroll up etc.

SetScreen	MOVEM.L D0-D7/A0-A6,-(sp)
		MOVE.W ybase_position(PC),D0
		ADDQ.W #1,D0
		CMP.W #8,D0
		BNE.S .ok
		MOVEQ #0,D0
.ok		MOVE.W D0,ybase_position
		MOVE.W D0,D1
		MULU #160*264,D0
		MULU #(96*264)+32,D1
		ADD.L picbase_ptr(PC),D0
		ADD.L palbase_ptr(PC),D1
		MOVE.L D1,pal_ptr
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W		; upper 16 bits
		MOVEM.L (SP)+,D0-D7/A0-A6
		RTS
ybase_position	DC.W 0
pal_ptr		DC.L 0
			
movepic		LEA pic+256(PC),A0
		MOVE.L A0,D0
		CLR.B D0
		MOVE.L D0,A1
		MOVE.L D0,picbase_ptr
		ADD.L #col-gfx,D0
		MOVE.L D0,palbase_ptr
		MOVE.L D0,pal_ptr
		MOVE.L #((264*160*8)+(((264*96)+32)*8))/4-1,D0
		MOVEQ #0,D1
.lp		MOVE.L (A0),(A1)+
		MOVE.L D1,(A0)+
		SUBQ.L #1,D0
		BNE.S .lp
		RTS

picbase_ptr	DC.L 0
palbase_ptr	DC.L 0

		SECTION DATA

pic		DS.B 256
gfx		incbin ray2.gfx
col		incbin ray2.pal

		SECTION BSS

		DS.L 299
my_stack	DS.L 3			; our own stack..
