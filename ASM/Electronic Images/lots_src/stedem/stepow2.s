;-----------------------------------------------------------------------;
;									;
; Programmed by Griff of Electronic Images (Inner Circle) January 1991. ;
;									;
; Contains the following :-						;
;									;
;-----------------------------------------------------------------------;

demo		EQU 0			; gem/disk

letsgo
		IFEQ demo
		CLR -(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14		; lowres
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1			; supervisor
		ADDQ.L #6,SP	
		ENDC

		MOVE #$2700,SR
		LEA stack,SP	
		MOVEM.L $FFFF8240.W,D0-D7
		MOVEM.L D0-D7,old_cols
		BSR Initscreens		; reserve screens/clear em
		BSR set_ints
		MOVE #$2300,SR

* This is the main program loop

Star_frame	
		;MOVE.W #$700,$FFFF8240.W
		BSR wait_vbl
		;MOVE.W #$000,$FFFF8240.W

		BTST.B #0,$FFFFFC00.W
		BEQ.S Star_frame
		CMP.B #$39,$FFFFFC02.W
		BNE Star_frame		

Exit		MOVEM.L old_cols(pc),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		BSR rest_ints
		CLR -(SP)
		TRAP #1			

; Initialisation interrupts (mfp etc) and various vectors.

set_ints	MOVE.W SR,-(SP)
		MOVE.W #$2700,SR
		LEA old_stuff(pc),A0
		MOVE.W $FFFF820E.W,(A0)+
		MOVE.W $FFFF8264.W,(A0)+
		MOVE.L $68.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $120.W,(A0)+
		MOVE.L $134.W,(A0)+
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.B $FFFFFA17.W,(A0)+
		MOVE.B $FFFFFA19.W,(A0)+
		MOVE.B $FFFFFA1B.W,(A0)+
		MOVE.B $FFFFFA1F.W,(A0)+
		MOVE.B $FFFFFA21.W,(A0)+
		MOVE.L #phbl,$68.w
		MOVE.L #first_vbl,$70.w
		MOVE.B #$20,$FFFFFA07.W
		MOVE.B #0,$FFFFFA09.W
		MOVE.B #$20,$FFFFFA13.W
		MOVE.B #0,$FFFFFA15.W
		CLR.B $FFFFFA19.W
		CLR.B $FFFFFA1B.W
		BCLR.B #3,$FFFFFA17.W
		BSR flush
		MOVE.W (SP)+,SR
		RTS

; Restore previous(gem) interrupts (mfp etc) and various vectors.

rest_ints	MOVE.W SR,-(SP)
		MOVE.W #$2700,SR
		LEA old_stuff(pc),A0
		MOVE.W (A0)+,$FFFF820E.W
		MOVE.W (A0)+,$FFFF8264.W
		MOVE.L (A0)+,$68.W
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$120.W
		MOVE.L (A0)+,$134.W
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.B (A0)+,$FFFFFA17.W
		MOVE.B (A0)+,$FFFFFA19.W
		MOVE.B (A0)+,$FFFFFA1B.W
		MOVE.B (A0)+,$FFFFFA1F.W
		MOVE.B (A0)+,$FFFFFA21.W
		BSR flush
		MOVE.W (SP)+,SR
		RTS

; Flush keyboard Buffer

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S .flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
.flok		RTS

old_stuff	DS.L 20
old_cols	DS.W 16

; Swap screens and set h/ware reg.

Swap_Screens	LEA log_base(PC),A0
		MOVE.L (A0)+,D0
		MOVE.L (A0)+,D1
		NOT.W (A0)			; switch screens
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR #8,D1
		MOVE.L D1,$FFFF8200.W		; set hardware...
		RTS

; Wait for one vbl..

wait_vbl	MOVE vbl_timer(PC),D0
.wait_vbl	CMP vbl_timer(PC),D0		
		BEQ.S .wait_vbl
		RTS


; Allocate space for screens and clear them + make standard *160 table.

Initscreens	lea log_base(pc),a1
		move.l #screens+256,d0
		clr.b d0
		move.l d0,(a1)+
		add.l #57856,d0
		move.l d0,(a1)+
		move.l log_base(pc),a0
		bsr clear_screen
		move.l phy_base(pc),a0
		bsr clear_screen
		move.l log_base(pc),d0
		lsr #8,d0
		move.l d0,$ffff8200.w
		rts

; Clear screen ->A0

clear_screen	moveq #0,d0
		move #(57856/16)-1,d1
.cls		move.l d0,(a0)+
		move.l d0,(a0)+
		move.l d0,(a0)+
		move.l d0,(a0)+
		dbf d1,.cls
		rts

log_base 	DC.L 0
phy_base 	DC.L 0
switch		DS.W 1
vbl_timer	DS.W 1
colours		DC.W $000,$222,$444,$444,$666,$666,$666,$666
		DC.W $777,$777,$777,$777,$777,$777,$777,$777

* The Full Overscan routine!

first_vbl	MOVE.L #vbl,$70.W
		ADDQ #1,vbl_timer
		RTE
			
vbl		CLR.B $FFFFFA19.W
		MOVE.B #99,$FFFFFA1F.W
		MOVE.L #overscantop,$134.W
		MOVE.B #4,$FFFFFA19.W
		MOVEM.L D0-D7/A0-A6,-(SP)
		MOVEM.L colours(pc),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		MOVE.W #0,$FFFF8264.W

		BSR scroll48

		MOVEM.L (SP)+,D0-D7/A0-A6
		ADDQ #1,vbl_timer
		RTE


overscantop	MOVE #$2100,SR			;top border synchronisation
		STOP #$2100			;by processor hbl
		MOVE.W #$2700,SR
		MOVEM.L D0-D7/A0-A6,-(SP)
		CLR.B $FFFFFA19.W
		DCB.W 52,$4E71
		MOVE.B #0,$FFFF820A.W
		DCB.W 10,$4E71
		MOVEQ #0,D0
		MOVEQ #$2F,D1
		MOVE #$8209,A0
		MOVE.B #2,$FFFF820A.W
.syncloop	MOVE.B (A0),D0
		BEQ.S .syncloop
		SUB.B D0,D1
		LSL D1,D0
		MOVE.L SP,savesp
		MOVE #$820A,A0
		MOVE #$8260,A1
		MOVEQ #0,D0
		MOVEQ #2,D2
		DCB.W 61,$4E71

		MOVE #208-1,D5
.layer1		DCB.W 5,$4E71	
		MOVE.B #2,$ffff8260.w
		MOVE.B #0,$ffff8260.w
		DCB.W 87,$4E71
 		MOVE.B #0,$ffff820a.w
		MOVE.B #2,$ffff820a.w
		DCB.W 8,$4e71	
		MOVE.B #1,$ffff8260.w
		MOVE.B #0,$ffff8260.w
		DCB.W 1,$4E71	
		DBF D5,.layer1	

		DCB.W 127-16-42-17-5-2-2,$4E71
		DCB.W 128,$4E71
		LEA $FFFF8240.W,A6
		MOVE.L #$00000045,(A6)+
		MOVE.L #$01010212,(A6)+
		MOVE.L #$03230434,(A6)+
		MOVE.L #$05450034,(A6)+
		MOVE.L #$00010012,(A6)+
		MOVE.L #$00230000,(A6)+
		MOVE.L #$00000000,(A6)+
		MOVE.L #$00000000,(A6)+

		LEA $ffff8203.w,A6
		MOVE.L scrl_base(PC),D7
		MOVE.W hwlinewidscrl48(PC),D5
		MOVE.W hwpixoffset(PC),D6
		MOVE.W D5,$FFFF820E.W
		MOVE.W D6,$FFFF8264.W
		MOVEP.L D7,(a6)

		DCB.W 16,$4E71

		MOVE #18-1,D5
.lp1		DCB.W 7,$4E71	
		MOVE.B D2,(A1)
		MOVE.B D0,(A1)
		DCB.W 91,$4E71
 		MOVE.B D0,(a0)
		MOVE.B D2,(a0)
		DCB.W 10,$4e71	
		MOVE.B #1,$FFFF8260.W
		MOVE.B #0,$FFFF8260.W
		DCB.W 1,$4E71	
		DBF D5,.lp1
	
.BOT_BORD	NOP
		NOP
		NOP
		MOVE.B D0,(A0)
		NOP
		MOVE.B D2,(A1)			; overscan
		MOVE.B D0,(A1)			; the bottom border
		MOVE.B D2,(a0)			; (with full overscan)
		NOP
		DCB.W 88,$4E71	
 		MOVE.B D0,(a0)
		MOVE.B D2,(a0)
		DCB.W 10,$4e71	
		MOVE.B #1,$FFFF8260.W
		MOVE.B #0,$FFFF8260.W
		DCB.W 3,$4E71	

		MOVEQ #29-1,D5
.lp2		DCB.W 7,$4E71	
		MOVE.B D2,(A1)
		MOVE.B D0,(A1)
		DCB.W 91,$4E71
 		MOVE.B D0,(a0)
		MOVE.B D2,(a0)
		DCB.W 10,$4e71	
		MOVE.B #1,$FFFF8260.W
		MOVE.B #0,$FFFF8260.W
		DCB.W 1,$4E71	
		DBF D5,.lp2	

		MOVE.L #blankarea+256,D7
		LEA $ffff8203.w,A6
		MOVEP.L D7,(a6)
		LSR.W #8,D7
		MOVE.L D7,$FFFF8200.W 
		MOVE.L savesp(PC),SP
		MOVEM.L (SP)+,D0-D7/A0-A6
phbl		RTE
savesp		DC.L 0

; 48*48 STE scroller (very fast and takes a constant cpu time)

scrlspeed	EQU 4

scroll48	MOVE.L scr_point(PC),A3
		MOVEM.W scrx(PC),D0/D1/D7   ;scrx/scrlpos/hwpixoffset
		ADDQ.W #scrlspeed,D7
		AND.W #15,D7
		BNE .not_next
		ADDQ #8,D1
		CMP #224,D1
		BNE.S .ok
		CLR D1
.ok		ADD #384,D0
		CMP #3*384,D0
		BNE.S .not_next
		MOVE.B (A3)+,D0
		BNE.S .not_wrap
		LEA text(PC),A3
.not_wrap	MOVEQ #0,D0
.not_next	LEA scroll48buf,A1
		ADD D1,A1
		MOVEM.L A1/A3,scrl_base ; scrl_base/scr_point
		MOVEM.W D0/D1/D7,scrx	; scrx/scrlpos/hwpixoffset
		MOVEQ #109+3,D5
		TST D7
		BEQ.S .iszero
		SUBQ #4,D5
.iszero		MOVE.W D5,hwlinewidscrl48 
		CLR D1
		MOVE.B (A3)+,D1
		ADD D1,D1
		ADD D1,D1
		LEA char_tab(PC),A2
		MOVE.L (A2,D1),A0
		ADDA.W D0,A0
i		SET 216
		REPT 12
		MOVEM.L (A0)+,D0-D7
		MOVEM.L D0-D1,i(a1)
		MOVEM.L D0-D1,i-224(a1)
i		SET i+448
		MOVEM.L D2-D3,i(a1)
		MOVEM.L D2-D3,i-224(a1)
i		SET i+448
		MOVEM.L D4-D5,i(a1)
		MOVEM.L D4-D5,i-224(a1)
i		SET i+448
		MOVEM.L D6-D7,i(a1)
		MOVEM.L D6-D7,i-224(a1)
i		SET i+448
		ENDR
		RTS

hwlinewidscrl48	DC.W 109

scrx		DC.W 0
scrlpos		DC.W 0
hwpixoffset	DC.W 0
scrl_base	DC.L 0
scr_point	DC.L text
text		
 dc.b "...WELCOME TO THE STE POWER DEMO, CODED BY GRIFF OF ELECTRONIC IMAGES"
 DC.B 0
 
		EVEN


char_tab	rept 33
		dc.l bigfontspce
		endr
		dc.l bigfont+(30*1152)		; !
		dc.l bigfontspce 		; "
		dc.l bigfontspce 		; #
		dc.l bigfontspce 		; $
		dc.l bigfontspce 		; %
		dc.l bigfontspce 		; &
		dc.l bigfont+(29*1152)		; '
		dc.l bigfont+(32*1152)		; (
		dc.l bigfont+(33*1152)		; )
		dc.l bigfontspce 		; *
		dc.l bigfontspce 		; +
		dc.l bigfont+(28*1152)		; ,
		dc.l bigfont+(26*1152)		; -
		dc.l bigfont+(27*1152)		; .
		dc.l bigfontspce 		; /
		dc.l bigfontspce 		; 0
		dc.l bigfontspce 		; 1
		dc.l bigfontspce 		; 2
		dc.l bigfontspce 		; 3 
		dc.l bigfontspce 		; 4
		dc.l bigfontspce 		; 5
		dc.l bigfontspce 		; 6
		dc.l bigfontspce 		; 7
		dc.l bigfontspce 		; 8
		dc.l bigfontspce 		; 9
		dc.l bigfontspce 		; :
		dc.l bigfontspce 		; ;
		dc.l bigfontspce 		; <
		dc.l bigfontspce 		; =
		dc.l bigfontspce 		; >
		dc.l bigfont+(31*1152)		; ?
		dc.l bigfontspce 		; @
i		set 0
		rept 26
		dc.l bigfont+i
i		set i+1152
		endr

bigfontspce	DS.W 768
bigfont		INCBIN  d:\STEPOW.INC\bigfont1.DAT
		EVEN

		SECTION BSS
		DS.L 299
stack		DS.L 3	
blankarea	DS.L 40*16
screens		DS.B 256
		DS.B 57856
		DS.B 57856

		DS.W 8
scroll48buf	DS.W 224*48
		DS.W 8
