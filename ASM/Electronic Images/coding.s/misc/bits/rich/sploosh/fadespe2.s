; Spectrum .SPU Piccy shower.
; Fader!

gemrun		EQU 0

letsgo		
		IFEQ gemrun
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
		MOVE.B #$00,$FFFF8E21.W
		ENDC

		LEA my_stack,SP
		BSR Generate_spu_fade

set_ints	MOVE #$2700,SR
		BSR flush			; flush IKBD
		MOVE.B #$12,$FFFFFC02.W		; kill mouse
		LEA old_mfp+32,A0
		MOVEM.L $FFFF8240.W,D0-D7
		MOVEM.L D0-D7,-32(A0)
		MOVE.B $FFFFFA07.W,(A0)+
	        MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
        	MOVE.B $FFFFFA15.W,(A0)+
	        MOVE.B $FFFFFA19.W,(A0)+	; save all vectors
        	MOVE.B $FFFFFA1F.W,(A0)+	; that we change
		MOVE.L $68.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $120.W,(A0)+
		MOVE.L $134.W,(A0)+
	        MOVE.B #0,$FFFFFA07.W		; timer a and hbl
	        CLR.B $FFFFFA09.W		
        	MOVE.B #0,$FFFFFA13.W		
		CLR.B $FFFFFA15.W
		MOVE.L #vbl,$70.W
		BCLR.B #3,$FFFFFA17.W		; soft end of interrupt
		MOVE #$2300,SR
		LEA screen+256,a0
		MOVE.L A0,D0
		CLR.B D0
		MOVE.L D0,log_base
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W		; upper 16 bits
		BSR wait_vbl
		BSR Copy_pic			

		MOVEQ #15-1,D7
.fadein_lp	BSR wait_vbl
		BSR wait_vbl
		BSR wait_vbl
		SUB.L #199*96,pal_off
		DBF D7,.fadein_lp

; Little demo which scrolls the screen vertically to oblivion!
		
wait_key	BSR wait_vbl			; obvious!
		CMP.B #$39,$FFFFFC02.W		; <SPACE> exits.
		BNE.S wait_key

		MOVEQ #15-1,D7
.fadeout_lp	BSR wait_vbl
		BSR wait_vbl
		BSR wait_vbl
		ADD.L #199*96,pal_off
		DBF D7,.fadeout_lp

wait_key2	BSR wait_vbl			; obvious!
		CMP.B #$39,$FFFFFC02.W		; <SPACE> exits.
		BNE.S wait_key2

restore		MOVE #$2700,SR
		LEA old_mfp,A0
		MOVEM.L (A0)+,D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		BSR flush
		MOVE.B #$8,$FFFFFC02.W
		MOVE.B (A0)+,$FFFFFA07.W
	        MOVE.B (A0)+,$FFFFFA09.W
        	MOVE.B (A0)+,$FFFFFA13.W	; restore mfp
        	MOVE.B (A0)+,$FFFFFA15.W
	        MOVE.B (A0)+,$FFFFFA19.W
            	MOVE.B (A0)+,$FFFFFA1F.W
		MOVE.L (A0)+,$68.W
		MOVE.L (A0)+,$70.W		; and vects
		MOVE.L (A0)+,$120.W
		MOVE.L (A0)+,$134.W
		BSET.B #3,$FFFFFA17.W
		MOVE #$2300,SR

		MOVE.B #$FF,$FFFF8E21.W
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

oldsp		DS.L 1
oldbase		DS.L 1
oldres		DS.W 1

; Wait for one vbl
; (d0 destroyed)

wait_vbl	MOVE.W vbl_timer(PC),D0
.wait		CMP.W vbl_timer(PC),D0
		BEQ.S .wait
		RTS

pic_ptr		DC.L sploosh_spu
pal_off		DC.L 15*96*199

vbl		MOVEM.L D0-D7/A0-A6,-(SP)
		MOVE #$8240,A0
		MOVEQ #0,D0
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+			; clear palette
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L pic_ptr(PC),A0
		LEA 32000(A0),A0
		ADD.L pal_off(PC),A0
		MOVE #$8240,A1
		REPT 8
		MOVE.L (A0)+,(A1)+
		ENDR

		ADDQ #1,vbl_timer
		MOVEQ #0,D0
		MOVE #$8209,A0
waits		MOVE.B (A0),D0
		BEQ.S	waits
		MOVEQ #10,D1
		SUB.B D0,D1
		LSL.B D1,D0
		MOVEQ #31,D0
delay_lp	DBF D0,delay_lp
		NOP
		NOP
		MOVE #$C4,D1
		MOVE.L pic_ptr(PC),A3
		LEA 32032(A3),A3
		ADD.L pal_off(PC),A3
		MOVE #$8240,A4

dopal		LEA (A4),A0
		LEA (A4),A1
		LEA (A4),A2
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		NOP
		NOP
		DBF D1,dopal
		NOP
		LEA (A4),A0
		LEA (A4),A1
		LEA (A4),A2
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		LEA (A4),A0
		LEA (A4),A1
		LEA (A4),A2
		LEA -$4A60(A3),A4
		NOP
		NOP
		NOP	 
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A4)+,(A2)+
		MOVE.L (A4)+,(A2)+
		MOVE.L (A4)+,(A2)+
		MOVE.L (A4)+,(A2)+
		MOVE.L (A4)+,(A2)+
		MOVE.L (A4)+,(A2)+
		MOVE.L (A4)+,(A2)+
		MOVE.L (A4)+,(A2)+
evbl:		MOVEM.L (SP)+,D0-D7/A0-A6
		RTE


; Copy the piccy to the screen.

Copy_pic	MOVE.L pic_ptr(PC),A0
		MOVE.L log_base(PC),A1
		MOVE #1999,D1
cpy_lp1		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		DBF D1,cpy_lp1 
		RTS

;

Generate_spu_fade
		lea fadetab,a4
		move  #$f00,d4		; R mask
		move  #$0f0,d5		; G mask
		move  #$00f,d6		; B mask
		move.w #$100,a2
		move.w #$010,a3
		move.w #$fff-1,d7
.mfade_lp	move.w #$fff-1,d0
		sub.w d7,d0
		move.w d0,d2
		add.w d0,d0
		and.w #$eee,d0
		and.w #$888,d2
		lsr.w #3,d2
		or.w d2,d0
		move.w d0,d2
		and.w d4,d2
		beq.s .R_done
		sub.w a2,d0
.R_done		move.w d0,d2
		and.w d5,d2
		beq.s .G_done
		sub.w a3,d0
.G_done 	move.w d0,d2
		and.w d6,d2
		beq.s .B_done
		subq.w #$001,d0
.B_done		move.w d0,d2
		and.w #$111,d2
		lsl.w #3,d2
		lsr.w #1,d0
		and.w #$777,d0
		or.w d2,d0
		move.w D0,(a4)+
		dbf d7,.mfade_lp

		move.l pic_ptr(PC),A0
		lea 32000(A0),A0
		lea 96*199(A0),A1
		lea fadetab,a4
		move #(199*15)-1,d7
.col_lp		
		rept 48
		move.w (a0)+,d0
		add.w d0,d0
		move.w (a4,d0),(a1)+
		endr		
		dbf d7,.col_lp
		rts

; Flush keyboard

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
flok		RTS

log_base	DC.L 0
vbl_timer	DC.W 0

		SECTION DATA

sploosh_spu	INCBIN SPLOOSH.SPU
		SECTION BSS
		DS.W 15*48*199
fadetab		ds.w $fff

old_mfp		DS.L 32			; saved mfp vects etc
		DS.L 399
my_stack	DS.L 3			; our own stack..

screen		DS.B 256
		DS.B 32000

 