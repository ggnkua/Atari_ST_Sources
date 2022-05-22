;--------------------------------------------------------------------------
; Overscan under interrupt!!!!
;--------------------------------------------------------------------------

gemrun		EQU 0				; 0 = run from gem
						; 1 = no gem calls	
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
		move.b #$00,$ffff8e21.w
		ENDC
		LEA my_stack,SP
		MOVEM.L $FFFF8240.W,D0-D7
		MOVEM.L D0-D7,old_pal
		BSR init_2screens
		BSR init_ints

.waitspace	CMP.B #$39,key
		BNE.S .waitspace

		BSR restore_ints
		MOVEM.L old_pal(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		IFEQ gemrun
		move.b #$ff,$ffff8e21.w
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
		ENDC

;-------------------------------------------------------------------------
; Interrupt setup routines

; Save mfp vectors and ints and install our own.(very 'clean' setup rout)

init_ints	MOVEQ #$13,D0			; pause keyboard
		BSR Writeikbd			; (stop from sending)
		MOVE #$2700,SR
		LEA old_stuff(PC),A0
		MOVE.L USP,A1
		MOVE.L A1,(A0)+
		MOVE.L $68.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $B0.W,(A0)+
		MOVE.L $110.W,(A0)+
		MOVE.L $118.W,(A0)+
		MOVE.L $120.W,(A0)+
		MOVE.L $134.W,(A0)+
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA0B.W,(A0)+
		MOVE.B $FFFFFA0D.W,(A0)+
		MOVE.B $FFFFFA0F.W,(A0)+
		MOVE.B $FFFFFA11.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+	; restore mfp
		MOVE.B $FFFFFA17.W,(A0)+
		MOVE.B $FFFFFA19.W,(A0)+
		MOVE.B $FFFFFA1B.W,(A0)+
		MOVE.B $FFFFFA1D.W,(A0)+
		MOVE.B $FFFFFA1F.W,(A0)+
		MOVE.B $FFFFFA21.W,(A0)+
		MOVE.B $FFFFFA25.W,(A0)+
		MOVE.B #$01,$FFFFFA07.W
		MOVE.B #$40,$fffffa09.W
		MOVE.B #$01,$FFFFFA13.W
		MOVE.B #$40,$fffffa15.W
		BCLR.B #3,$fffffa17.W		; software end of int.
		LEA first_vbl(PC),A0
		MOVE.L A0,$70.W			; set our vbl
		LEA key_rout(PC),A0
		MOVE.L A0,$118.W		; and our keyrout.
		CLR key			
		MOVE.B #$00,$FFFFFA0F.W
		MOVE.B #$00,$FFFFFA11.W		; dummy service.
		MOVE.B #$00,$FFFFFA0B.W
		MOVE.B #$00,$FFFFFA0D.W		; clear any pendings
		clr.b $fffffa1b.w
		MOVE #$2300,SR
		MOVEQ #$11,D0			; resume sending
		BSR Writeikbd
		MOVEQ #$12,D0			; kill mouse
		BSR Writeikbd
		BSR flush
		RTS

; Restore mfp vectors and ints.

restore_ints	MOVEQ #$13,D0			; pause keyboard
		BSR Writeikbd			; (stop from sending)
		MOVE #$2700,SR
		LEA old_stuff(PC),A0
		MOVE.L (A0)+,A1
		MOVE.L A1,USP
		MOVE.L (A0)+,$68.W
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$B0.W
		MOVE.L (A0)+,$110.W
		MOVE.L (A0)+,$118.W
		MOVE.L (A0)+,$120.W
		MOVE.L (A0)+,$134.W
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA0B.W
		MOVE.B (A0)+,$FFFFFA0D.W
		MOVE.B (A0)+,$FFFFFA0F.W
		MOVE.B (A0)+,$FFFFFA11.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W	; restore mfp
		MOVE.B (A0)+,$FFFFFA17.W
		MOVE.B (A0)+,$FFFFFA19.W
		MOVE.B (A0)+,$FFFFFA1B.W
		MOVE.B (A0)+,$FFFFFA1D.W
		MOVE.B (A0)+,$FFFFFA1F.W
		MOVE.B (A0)+,$FFFFFA21.W
		MOVE.B (A0)+,$FFFFFA25.W
		MOVE #$2300,SR
		MOVEQ #$11,D0			; resume
		BSR Writeikbd		
		MOVEQ #$8,D0			; restore mouse.
		BSR Writeikbd
		BSR flush
		RTS

old_pal		DS.W 16
old_stuff:	DS.L 32
oldres		DS.W 1
oldbase		DS.L 1
oldsp		DS.L 1

; Allocate and Initialise(clear) screen memory.

init_2screens	LEA log_base(PC),A1
		MOVE.L #screens+256,D0
		CLR.B D0
		MOVE.L D0,A0
		MOVE.L A0,(A1)+
		BSR cls
		ADD.L #32000,A0
		MOVE.L A0,(A1)+
		BSR cls
		MOVE.L phy_base(PC),D0
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		RTS

; Clear a 32k screen. a0 -> screen.

cls		MOVE.L A0,A2
		MOVEQ #0,D0
		MOVE.W #(32000/16)-1,D1
.cls_lp		MOVE.L D0,(A2)+
		MOVE.L D0,(A2)+
		MOVE.L D0,(A2)+
		MOVE.L D0,(A2)+
		DBF D1,.cls_lp
		RTS

; Swap Screen ptrs and set hardware reg for next frame.

SwapScreens	LEA log_base(PC),A0
		MOVEM.L (A0)+,D0-D1
		NOT.W (A0)
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR.W #8,D1
		MOVE.L D1,$FFFF8200.W
		RTS
;-------------------------------------------------------------------------

; Wait for a vbl.... 
; D0/A0 trashed.

wait_vbl	LEA vbl_timer(PC),A0
		MOVE.W (A0),D0
.wait_vbl	CMP.W (A0),D0
		BEQ.S .wait_vbl
		RTS

; Wait for D7 vbls.
; D7/D0/A0 trashed

WaitD7Vbls	LEA vbl_timer(PC),A0
		SUBQ #1,D7
.wait_lp	MOVE.W (A0),D0
.wait_vbl	CMP.W (A0),D0
		BEQ.S .wait_vbl
		DBF D7,.wait_lp
		RTS

; Flush IKBD

flush		BTST.B #0,$FFFFFC00.W		; any waiting?
		BEQ.S .flok			; exit if none waiting.
		MOVE.B $FFFFFC02.W,D0		; get next in queue
		BRA.S flush			; and continue
.flok		RTS

; Write d0 to IKBD

Writeikbd	BTST.B #1,$FFFFFC00.W
		BEQ.S Writeikbd			; wait for ready
		MOVE.B D0,$FFFFFC02.W		; and send...
		RTS

; Keyboard handler interrupt routine...

key_rout	MOVE #$2500,SR			; ipl 5 for 'cleanness' 
		MOVE D0,-(SP)
		MOVE.B $FFFFFC00.W,D0
		BTST #7,D0			; int req?
		BEQ.S .end			
		BTST #0,D0			; 
		BEQ.S .end
		MOVE.B $FFFFFC02.W,key		; store keypress
.end		MOVE (SP)+,D0
		RTE
key		DC.W 0
vbl_timer	DC.W 0
log_base	DC.L 0
phy_base	DC.L 0
frame_switch	DC.W 0

first_vbl	MOVE.L #vbl,$70.W
		RTE
			
vbl		MOVE #$2700,SR
		CLR.B $FFFFFA1B.W
		MOVE.B #9,$FFFFFA21.W
            MOVE.L #hbl1,$120.W
		MOVE.B #8,$FFFFFA1B.W
		MOVE.B #1,$FFFFFA21.W
		ADDQ #1,vbl_timer
		MOVEM.L D0-D1/a0-a1,-(SP)
		MOVEQ #0,D0
		MOVE.W number(PC),D0
		CMP lowest(PC),D0
		BGE.S ok1
		MOVE.W D0,lowest
ok1		MOVE lowest(PC),D0
		BSR num_print
		MOVEM.L (SP)+,D0-D1/A0-A1
		MOVEM.L D0/A0,-(SP)
		MOVE #$8209,A0
		CLR D0
.wait		MOVE.B (A0),D0
		BEQ.S .wait
		MOVEQ #$10,D1
		SUB.W D0,D1
		LSL D1,D0
		DCB.W 7*128,$4E71
		MOVEQ #0,D0
		DCB.W 75,$4E71
		MOVE #$8260,A0
		MOVE.B #2,$FFFF8260.W
		MOVE.B D0,$FFFF8260.W
		DCB.W 10-7,$4E71
		MOVEM.L (SP)+,D0/A0
		MOVE.B #2,$FFFF8260.W
		MOVE.B #0,$FFFF8260.W

		RTE
number		DC.W 255
lowest		DC.W 255

o1		EQU 10
o2		EQU 10

hbl1		MOVE.W D6,-(SP)
		MOVE.B $FFFF8209.W,D6
		SUB.B #2,D6
		NOT.B D6
		AND.B #15,D6
		LSR.B D6,D6
		DCB.W 46,$4E71
		CLR D6
		MOVE.L A0,USP
		MOVE #$820A,A0
		MOVE.B D6,(A0)
		MOVE.B #2,(A0)
		MOVE.L USP,A0
		MOVE.L #hbl2,$120.w
		DCB.W o1-7,$4E71
		MOVE.B #2,$FFFF8260.W
		MOVE.B D6,$FFFF8260.W
		DCB.W o2,$4E71
		MOVE.B #2,$FFFF8260.W
		MOVE.B D6,$FFFF8260.W
		MOVE.W (SP)+,D6
		RTE

hbl2		MOVE.W D6,-(SP)
		MOVE.B $FFFF8209.W,D6
		SUB.B #8,D6
		NOT.B D6
		AND.B #15,D6
		LSR.B D6,D6
		DCB.W 46,$4E71
		CLR D6
		MOVE.L A0,USP
		MOVE #$820A,A0
		MOVE.B D6,(A0)
		MOVE.B #2,(A0)
		MOVE.L USP,A0
		MOVE.L #hbl3,$120.w
		DCB.W o1-7,$4E71
		MOVE.B #2,$FFFF8260.W
		MOVE.B D6,$FFFF8260.W
		DCB.W o2,$4E71
		MOVE.B #2,$FFFF8260.W
		MOVE.B D6,$FFFF8260.W
		MOVE.W (SP)+,D6
		RTE

hbl3		MOVE.W D6,-(SP)
		MOVE.B $FFFF8209.W,D6
		SUB.B #14,D6
		NOT.B D6
		AND.B #15,D6
		LSR.B D6,D6
		DCB.W 46,$4E71
		CLR D6
		MOVE.L A0,USP
		MOVE #$820A,A0
		MOVE.B D6,(A0)
		MOVE.B #2,(A0)
		MOVE.L USP,A0
		MOVE.L #hbl4,$120.w
		DCB.W o1-7,$4E71
		MOVE.B #2,$FFFF8260.W
		MOVE.B D6,$FFFF8260.W
		DCB.W o2,$4E71
		MOVE.B #2,$FFFF8260.W
		MOVE.B D6,$FFFF8260.W
		MOVE.W (SP)+,D6
		RTE

hbl4		MOVE.W D6,-(SP)
		MOVE.B $FFFF8209.W,D6
		SUB.B #20,D6
		NOT.B D6
		AND.B #15,D6
		LSR.B D6,D6
		DCB.W 46,$4E71
		CLR D6
		MOVE.L A0,USP
		MOVE #$820A,A0
		MOVE.B D6,(A0)
		MOVE.B #2,(A0)
		MOVE.L USP,A0
		MOVE.L #hbl5,$120.w
		DCB.W o1-7,$4E71
		MOVE.B #2,$FFFF8260.W
		MOVE.B D6,$FFFF8260.W
		DCB.W o2,$4E71
		MOVE.B #2,$FFFF8260.W
		MOVE.B D6,$FFFF8260.W
		MOVE.W (SP)+,D6
		RTE

hbl5		MOVE.W D6,-(SP)
		MOVE.B $FFFF8209.W,D6
		SUB.B #26,D6
		NOT.B D6
		AND.B #15,D6
		LSR.B D6,D6
		DCB.W 46,$4E71
		CLR D6
		MOVE.L A0,USP
		MOVE #$820A,A0
		MOVE.B D6,(A0)
		MOVE.B #2,(A0)
		MOVE.L USP,A0
		MOVE.L #hbl6,$120.w
		DCB.W o1-7,$4E71
		MOVE.B #2,$FFFF8260.W
		MOVE.B D6,$FFFF8260.W
		DCB.W o2,$4E71
		MOVE.B #2,$FFFF8260.W
		MOVE.B D6,$FFFF8260.W
		MOVE.W (SP)+,D6
		RTE

hbl6		MOVE.W D6,-(SP)
		MOVE.B $FFFF8209.W,D6
		SUB.B #32,D6
		NOT.B D6
		AND.B #15,D6
		LSR.B D6,D6
		DCB.W 46,$4E71
		CLR D6
		MOVE.L A0,USP
		MOVE #$820A,A0
		MOVE.B D6,(A0)
		MOVE.B #2,(A0)
		MOVE.L USP,A0
		MOVE.L #hbl7,$120.w
		DCB.W o1-7,$4E71
		MOVE.B #2,$FFFF8260.W
		MOVE.B D6,$FFFF8260.W
		DCB.W o2,$4E71
		MOVE.B #2,$FFFF8260.W
		MOVE.B D6,$FFFF8260.W
		MOVE.W (SP)+,D6
		RTE

hbl7		MOVE.W D6,-(SP)
		MOVE.B $FFFF8209.W,D6
		SUB.B #38,D6
		NOT.B D6
		AND.B #15,D6
		LSR.B D6,D6
		DCB.W 46,$4E71
		CLR D6
		MOVE.L A0,USP
		MOVE #$820A,A0
		MOVE.B D6,(A0)
		MOVE.B #2,(A0)
		MOVE.L USP,A0
		MOVE.L #hbl8,$120.w
		DCB.W o1-7,$4E71
		MOVE.B #2,$FFFF8260.W
		MOVE.B D6,$FFFF8260.W
		DCB.W o2,$4E71
		MOVE.B #2,$FFFF8260.W
		MOVE.B D6,$FFFF8260.W
		MOVE.W (SP)+,D6
		RTE

hbl8		MOVE.W D6,-(SP)
		MOVE.B $FFFF8209.W,D6
		SUB.B #44,D6
		NOT.B D6
		AND.B #15,D6
		LSR.B D6,D6
		DCB.W 46,$4E71
		CLR D6
		MOVE.L A0,USP
		MOVE #$820A,A0
		MOVE.B D6,(A0)
		MOVE.B #2,(A0)
		MOVE.L USP,A0
		MOVE.L #hbl1,$120.w
		DCB.W o1-7,$4E71
		MOVE.B #2,$FFFF8260.W
		MOVE.B D6,$FFFF8260.W
		DCB.W o2,$4E71
		MOVE.B #2,$FFFF8260.W
		MOVE.B D6,$FFFF8260.W
		MOVE.W (SP)+,D6
		RTE

* Routine to print an unsigned word in decimal - D0.L. 
* D0-D1/A0-A1 smashed!

num_print	MOVE.L log_base(PC),A0
		DIVU #10000,D0	
		BSR.S	digi_prin
		ADDQ.L #1,A0	
		CLR D0		
		SWAP D0		
		DIVU #1000,D0 	
		BSR.S	digi_prin
		ADDQ.L #7,A0
		CLR D0	
		SWAP D0	
		DIVU #100,D0
		BSR.S	digi_prin
		ADDQ.L #1,A0	
		CLR D0
		SWAP D0
		DIVU #10,D0		
		BSR.S	digi_prin
		ADDQ.L #7,A0
		CLR D0
		SWAP D0
digi_prin	MOVE D0,D1
		LSL #3,D1
		LEA font_data(PC,D1),A1
		MOVE.B (A1)+,(A0)		
		MOVE.B (A1)+,160(A0)
		MOVE.B (A1)+,320(A0)
		MOVE.B (A1)+,480(A0)
		MOVE.B (A1)+,640(A0)
		MOVE.B (A1)+,800(A0)
		MOVE.B (A1)+,960(A0)
		MOVE.B (A1)+,1120(A0)
		RTS

font_data	DC.B $7C,$C6,$C6,$00,$C6,$C6,$7C,$00	"O"
		DC.B $18,$18,$18,$00,$18,$18,$18,$00	"1"
		DC.B $7C,$06,$06,$7C,$C0,$C0,$7C,$00	"2"
		DC.B $7C,$06,$06,$7C,$06,$06,$7C,$00	"3"
		DC.B $C6,$C6,$C6,$7C,$06,$06,$06,$00	"4"
		DC.B $7C,$C0,$C0,$7C,$06,$06,$7C,$00	"5"
		DC.B $7C,$C0,$C0,$7C,$C6,$C6,$7C,$00	"6"
		DC.B $7C,$06,$06,$00,$06,$06,$06,$00	"7"
		DC.B $7C,$C6,$C6,$7C,$C6,$C6,$7C,$00	"8"
		DC.B $7C,$C6,$C6,$7C,$06,$06,$7C,$00	"9"

		SECTION BSS

screens		DS.B 256
		DS.B 32000
		DS.B 32000
		DS.L 299
my_stack	DS.L 2
