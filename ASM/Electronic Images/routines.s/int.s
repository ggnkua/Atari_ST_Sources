;--------------------------------------------------------------------------
;
;         'Clean' setup routine and some general routines.
;
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
		MOVE.B #$00,$FFFFFA07.W
		MOVE.B #$40,$fffffa09.W
		MOVE.B #$00,$FFFFFA13.W
		MOVE.B #$40,$fffffa15.W
		BCLR.B #3,$fffffa17.W		; software end of int.
		LEA vbl(PC),A0
		MOVE.L A0,$70.W			; set our vbl
		LEA key_rout(PC),A0
		MOVE.L A0,$118.W		; and our keyrout.
		CLR key			
		MOVE.B #$00,$FFFFFA0F.W
		MOVE.B #$00,$FFFFFA11.W		; dummy service.
		MOVE.B #$00,$FFFFFA0B.W
		MOVE.B #$00,$FFFFFA0D.W		; clear any pendings
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

vbl		ADDQ #1,vbl_timer
		RTE

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

		SECTION BSS

screens		DS.B 256
		DS.B 32000
		DS.B 32000
		DS.L 299
my_stack	DS.L 2