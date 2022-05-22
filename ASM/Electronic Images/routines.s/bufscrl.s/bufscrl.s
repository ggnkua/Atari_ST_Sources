;--------------------------------------------------------------------------
;  Buffer scroll routine....
;  by Martin Griffiths July 1992
;--------------------------------------------------------------------------

gemrun		EQU 0				; 0 = run from gem
						; 1 = no gem calls	

noy_lines	equ 192
scrl_bufwid	equ 144				

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
		BSR buildscrlbuffs
		BSR init_ints
.vbl_lp
		;not.w $ffff8240.w
		BSR wait_vbl
		;not.w $ffff8240.w
		BSR SwapScreens
		BSR copy_scroll_buffer
		move.w #4000,d0
.lp		dbf d0,.lp

		CMP.B #$4D,key
		BNE.S .notright
		MOVEQ #2,D0
		BSR scroll_right
.notright	CMP.B #$4B,key
		BNE.S .notleft
		MOVEQ #2,D0
		BSR scroll_left
.notleft	CMP.B #$39,key
		BNE.S .vbl_lp

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
		MOVE.B #$00,$fffffa07.W
		MOVE.B #$40,$fffffa09.W
		MOVE.B #$00,$fffffa13.W
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

old_stuff	DS.L 32
old_pal		DS.W 16
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
		LEA 32000(A0),A0
		MOVE.L A0,(A1)+
		BSR cls
		MOVE.L log_base(PC),D0
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		RTS

; Clear a 32k screen. a0 -> screen.

cls		MOVE.L A0,A2
		MOVEQ #0,D0
		MOVE.W #2000-1,D1
.cls_lp		MOVE.L D0,(A2)+
		MOVE.L D0,(A2)+
		MOVE.L D0,(A2)+
		MOVE.L D0,(A2)+
		DBF D1,.cls_lp
		RTS

SwapScreens	LEA log_base(PC),A0
		MOVEM.L (A0)+,D0-D1
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR.W #8,D1
		MOVE.L D1,$FFFF8200.W
		RTS

;-------------------------------------------------------------------------

vbl		MOVEM.L D0-A6,-(SP)
		MOVEM.L pal(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		MOVEM.L (SP)+,D0-A6

		ADDQ #1,vbl_timer
		RTE

; Wait for a vbl..

wait_vbl	LEA vbl_timer(PC),A0
		MOVE.W (A0),D0
.wait_vbl	CMP.W (A0),D0
		BEQ.S .wait_vbl
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

;---------------------------------------------------------------------
; Buffer scroller routines

		RSRESET
tot_xpos	RS.W 1
buf_xpos	RS.W 1
rightplot_offy	RS.W 1
leftplot_offy	RS.W 1
rightmap_offy	RS.W 1
leftmap_offy	RS.W 1
count_in	RS.W 1
draw_rightflag	RS.B 1
draw_leftflag	RS.B 1
bufscrlvarsize	RS.B 0

bufscrl_vars	DS.B bufscrlvarsize

; Scroll right. D0 = amount to scroll by.

scroll_right	LEA bufscrl_vars(PC),A6
		MOVE.W count_in(A6),D6
		ADD.W D0,D6
		CMP.W #15,D6
		BLE.S .ok1
		MOVE.W buf_xpos(A6),D3
		LSR.W #1,D3
		AND.W #$FFF8,D3
		MOVE.W D3,rightplot_offy(A6)
		MOVE.W tot_xpos(A6),D3
		LSR.W #3,D3			;32
		AND.W #$FFFC,D3			;*4
		MOVE.W D3,rightmap_offy(A6)
		ST.B Draw_rightflag(A6)
		SF.B Draw_leftflag(A6)
		AND.W #15,D6
.ok1		MOVE.W D6,count_in(A6)
		ADD.W D0,tot_xpos(A6)
		ADD.W D0,buf_xpos(A6)
		CMP.W #(scrl_bufwid*2),buf_xpos(A6)
		BLT.S .ok2
		SUB.W #(scrl_bufwid*2),buf_xpos(A6)
.ok2		TST.B Draw_rightflag(A6)
		BEQ .nodraw
		LEA scrl_buffer1,A2
		ADD.W rightplot_offy(A6),A2
		MOVE.W D6,D0
		LSR.W #1,D0
		MULU #noy_lines*scrl_bufwid,D0
		ADD.L D0,A2
		LEA map+(9*4),A4
		ADD.W rightmap_offy(A6),A4
		LEA ship(PC),A5
		BTST.B #3,rightplot_offy+1(A6)
		BNE .inmiddle
		REPT noy_lines/32
		lea (a5),a0
		add.l (a4),a0			; get address of block
		lea 8(a0),a1
		moveq #32-1,d7
		bsr plot1tile_colmn
		LEA 32*scrl_bufwid(A2),A2
		LEA shoff(A4),A4
		ENDR
		RTS
.inmiddle	REPT noy_lines/32
		lea 8(a5),a0
		add.l (a4),a0			; get address of block
		lea (a5),a1
		add.l 4(a4),a1
		moveq #32-1,d7
		bsr plot1tile_colmn
		LEA 32*scrl_bufwid(A2),A2
		LEA shoff(A4),A4
		ENDR
.nodraw		RTS
		
; Scroll left. D0 = amount to scroll by.

scroll_left	LEA bufscrl_vars(PC),A6
		SUB.W D0,tot_xpos(A6)
		SUB.W D0,buf_xpos(A6)
		BGE.S .ok2
		ADD.W #(scrl_bufwid*2),buf_xpos(A6)
.ok2		MOVE.W count_in(A6),D6
		SUB.W D0,D6
		BGE.S .ok1
		MOVE.W buf_xpos(A6),D3
		LSR.W #1,D3
		AND.W #$FFF8,D3
		MOVE.W D3,leftplot_offy(A6)
		MOVE.W tot_xpos(A6),D3
		LSR.W #3,D3			;32
		AND.W #$FFFC,D3			;*4
		MOVE.W D3,leftmap_offy(A6)
		SF.B Draw_rightflag(A6)
		ST.B Draw_leftflag(A6)
		AND.W #15,D6
.ok1		MOVE.W D6,count_in(A6)
		TST.B Draw_leftflag(A6)
		BEQ .nodraw
		LEA scrl_buffer1,A2
		ADD.W leftplot_offy(A6),A2
		MOVE.W D6,D0
		LSR.W #1,D0
		MULU #noy_lines*scrl_bufwid,D0
		ADD.L D0,A2
		LEA map,A4
		ADD.W leftmap_offy(A6),A4
		LEA ship(PC),A5
		BTST.B #3,leftplot_offy+1(A6)
		BNE .inmiddle
		REPT noy_lines/32
		lea (a5),a0
		add.l (a4),a0			; get address of block
		lea 8(a0),a1
		moveq #32-1,d7
		bsr plot1tile_colmn
		LEA 32*scrl_bufwid(A2),A2
		LEA shoff(A4),A4
		ENDR
		RTS
.inmiddle	REPT noy_lines/32
		lea 8(a5),a0
		add.l (a4),a0			; get address of block
		lea (a5),a1
		add.l 4(a4),a1
		moveq #32-1,d7
		bsr plot1tile_colmn
		LEA 32*scrl_bufwid(A2),A2
		LEA shoff(A4),A4
		ENDR
.nodraw		RTS

; Buffer copy routine.

copy_scroll_buffer
		LEA bufscrl_vars(PC),A6
		LEA scrl_buffer1,A0
		MOVE.W count_in(A6),D0
		LSR.W #1,D0
		MULU #noy_lines*scrl_bufwid,D0
		ADD.L D0,A0
		MOVE.W buf_xpos(A6),D0
		LSR.W #1,D0
		AND.W #$FFF8,D0
		LSR.W #1,D0
		MOVE.L .copybufjmptab(PC,D0),A2
		MOVE.L log_base(PC),A6
		LEA 8(A6),A6
		MOVE.W #noy_lines-1,D7
		JMP (A2)
.copybufjmptab	DC.L .cse1,.cse2,.cse3,.cse4,.cse5,.cse6,.cse7,.cse8,.cse9
		DC.L .cse10,.cse11,.cse12,.cse13,.cse14,.cse15,.cse16,.cse17,.cse18

.cse1		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1-A5,(A6)
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1-A5,48(A6)
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1-A5,96(A6)
		LEA 160(A6),A6
		DBF D7,.cse1
		RTS
.cse2		MOVEM.L (A0)+,D0-D6/A1-A5
		MOVEM.L D0-D1,136(A6)		
		MOVEM.L D2-D6/A1-A5,(A6)
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1-A5,40(A6)
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1-A5,88(A6)
		LEA 160(A6),A6
		DBF D7,.cse2
		RTS
.cse3		MOVEM.L (A0)+,D0-D6/A1-A5
		MOVEM.L D0-D3,128(A6)		
		MOVEM.L D4-D6/A1-A5,(A6)
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1-A5,32(A6)
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1-A5,80(A6)
		LEA 160(A6),A6
		DBF D7,.cse3
		RTS
.cse4		MOVEM.L (A0)+,D0-D6/A1-A5
		MOVEM.L D0-D5,120(A6)		
		MOVEM.L D6/A1-A5,(A6)
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1-A5,24(A6)
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1-A5,72(A6)
		LEA 160(A6),A6
		DBF D7,.cse4
		RTS
.cse5		MOVEM.L (A0)+,D0-D6/A1-A5
		MOVEM.L D0-D6/A1,112(A6)		
		MOVEM.L A2-A5,(A6)
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1-A5,16(A6)
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1-A5,64(A6)
		LEA 160(A6),A6
		DBF D7,.cse5
		RTS
.cse6		MOVEM.L (A0)+,D0-D6/A1-A5
		MOVEM.L D0-D6/A1-A3,104(A6)		
		MOVEM.L A4-A5,(A6)
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1-A5,8(A6)
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1-A5,56(A6)
		LEA 160(A6),A6
		DBF D7,.cse6
		RTS
.cse7		MOVEM.L (A0)+,D0-D6/A1-A5
		MOVEM.L D0-D6/A1-A5,96(A6)		
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1-A5,(A6)
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1-A5,48(A6)
		LEA 160(A6),A6
		DBF D7,.cse7
		RTS
.cse8		MOVEM.L (A0)+,D0-D6/A1-A5
		MOVEM.L D0-D6/A1-A5,88(A6)		
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D1,136(A6)
		MOVEM.L D2-D6/A1-A5,(A6)
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1-A5,40(A6)
		LEA 160(A6),A6
		DBF D7,.cse8
		RTS
.cse9		MOVEM.L (A0)+,D0-D6/A1-A5
		MOVEM.L D0-D6/A1-A5,80(A6)		
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D3,128(A6)
		MOVEM.L D4-D6/A1-A5,(A6)
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1-A5,32(A6)
		LEA 160(A6),A6
		DBF D7,.cse9
		RTS
.cse10		MOVEM.L (A0)+,D0-D6/A1-A5
		MOVEM.L D0-D6/A1-A5,72(A6)		
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D5,120(A6)
		MOVEM.L D6/A1-A5,(A6)
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1-A5,24(A6)
		LEA 160(A6),A6
		DBF D7,.cse10
		RTS
.cse11		MOVEM.L (A0)+,D0-D6/A1-A5
		MOVEM.L D0-D6/A1-A5,64(A6)		
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1,112(A6)
		MOVEM.L A2-A5,(A6)
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1-A5,16(A6)
		LEA 160(A6),A6
		DBF D7,.cse11
		RTS
.cse12		MOVEM.L (A0)+,D0-D6/A1-A5
		MOVEM.L D0-D6/A1-A5,56(A6)		
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1-A3,104(A6)
		MOVEM.L A4-A5,(A6)
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1-A5,8(A6)
		LEA 160(A6),A6
		DBF D7,.cse12
		RTS
.cse13		MOVEM.L (A0)+,D0-D6/A1-A5
		MOVEM.L D0-D6/A1-A5,48(A6)		
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1-A5,96(A6)
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1-A5,(A6)
		LEA 160(A6),A6
		DBF D7,.cse13
		RTS
.cse14		MOVEM.L (A0)+,D0-D6/A1-A5
		MOVEM.L D0-D6/A1-A5,40(A6)		
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1-A5,88(A6)
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D2-D6/A1-A5,(A6)
		MOVEM.L D0-D1,136(A6)
		LEA 160(A6),A6
		DBF D7,.cse14
		RTS
.cse15		MOVEM.L (A0)+,D0-D6/A1-A5
		MOVEM.L D0-D6/A1-A5,32(A6)		
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1-A5,80(A6)
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D4-D6/A1-A5,(A6)
		MOVEM.L D0-D3,128(A6)
		LEA 160(A6),A6
		DBF D7,.cse15
		RTS
.cse16		MOVEM.L (A0)+,D0-D6/A1-A5
		MOVEM.L D0-D6/A1-A5,24(A6)		
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1-A5,72(A6)
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D6/A1-A5,(A6)
		MOVEM.L D0-D5,120(A6)
		LEA 160(A6),A6
		DBF D7,.cse16
		RTS
.cse17		MOVEM.L (A0)+,D0-D6/A1-A5
		MOVEM.L D0-D6/A1-A5,16(A6)		
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1-A5,64(A6)
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L A2-A5,(A6)
		MOVEM.L D0-D6/A1,112(A6)
		LEA 160(A6),A6
		DBF D7,.cse17
		RTS
.cse18		MOVEM.L (A0)+,D0-D6/A1-A5
		MOVEM.L D0-D6/A1-A5,8(A6)		
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L D0-D6/A1-A5,56(A6)
		MOVEM.L (A0)+,D0-D6/A1-A5		
		MOVEM.L A4-A5,(A6)
		MOVEM.L D0-D6/A1-A3,104(A6)
		LEA 160(A6),A6
		DBF D7,.cse18
		RTS


shoff		equ 564			Length of one map row. IMPORTANT!

; Construct the eight screens!!!!!
; This is very important since it is called after a demo
; has been looked at to redraw the map at the place they were at.

buildscrlbuffs	LEA bufscrl_vars(PC),A6
		move.w #30*32,tot_xpos(a6)
		lea scrl_buffer1,a2		; start of buffers
		move.l map_ptr,a5		; build first one
		lea ship,a6			; start of blocks
		moveq #0,d6
.build_buf_lp	lea (A5),A4 
		moveq #(noy_lines/32)-1,d4
.build_1row	rept 9
		lea (a6),a0
		add.l (a4),a0			; get address of block
		lea 8(a0),a1
		moveq #32-1,d7
		bsr plot1tile_colmn
		lea 8(a2),a2
		lea 8(a6),a0
		add.l (a4)+,a0			; get address of block
		lea (a6),a1
		add.l (a4),a1
		moveq #32-1,d7
		bsr plot1tile_colmn
		lea 8(a2),a2
		endr
		lea 31*scrl_bufwid(A2),A2
		lea shoff-36(a4),a4
		dbf d4,.build_1row
		addq.w #2,d6
		cmp.w #16,d6
		bne .build_buf_lp		
		rts

; Routine to plot a column of upto 1 whole tile.
; A0 -> tile 1 gfx A1 -> tile 2 gfx
; A2 -> location to plot tile into(i.e scroll buffer).
; D6 = shift value. 
; D7 = no. of lines-1 (rows) to plot(a tile is upto 32 pixels high)

plot1tile_colmn:
		LEA (A2),A3
		CMP.W #8,D6
		BGT.S .cse2
.plot_lp	MOVEM.W (A1)+,D0-D3
		SWAP D0
		SWAP D1
		SWAP D2
		SWAP D3
		MOVE.W (A0)+,D0
		MOVE.W (A0)+,D1
		MOVE.W (A0)+,D2
		MOVE.W (A0)+,D3
		ROL.L D6,D0
		ROL.L D6,D1
		ROL.L D6,D2
		ROL.L D6,D3
		MOVEM.W D0-D3,(A3)
		LEA 8(A0),A0		
		LEA 8(A1),A1		
		LEA scrl_bufwid(A3),A3
		DBF D7,.plot_lp
		RTS
.cse2		NEG D6
		ADD.W #16,D6
.plot_lp2	MOVEM.W (A0)+,D0-D3
		SWAP D0
		SWAP D1
		SWAP D2
		SWAP D3
		MOVE.W (A1)+,D0
		MOVE.W (A1)+,D1
		MOVE.W (A1)+,D2
		MOVE.W (A1)+,D3
		ROR.L D6,D0
		ROR.L D6,D1
		ROR.L D6,D2
		ROR.L D6,D3
		MOVEM.W D0-D3,(A3)
		LEA 8(A0),A0		
		LEA 8(A1),A1		
		LEA scrl_bufwid(A3),A3
		DBF D7,.plot_lp2
		NEG D6
		ADD.W #16,D6
		RTS

pal:		incbin mainmenu.pal
ship:		incbin menutile.dat
map_ptr		dc.l map+(30*4)

map		incbin mainmenu.map
		incbin mainmenu.map


		SECTION BSS
scrl_buffer1	DS.B scrl_bufwid*noy_lines
scrl_buffer2	DS.B scrl_bufwid*noy_lines
scrl_buffer3	DS.B scrl_bufwid*noy_lines
scrl_buffer4	DS.B scrl_bufwid*noy_lines
scrl_buffer5	DS.B scrl_bufwid*noy_lines
scrl_buffer6	DS.B scrl_bufwid*noy_lines
scrl_buffer7	DS.B scrl_bufwid*noy_lines
scrl_buffer8	DS.B scrl_bufwid*noy_lines

screens		DS.B 256
		DS.B 32000
		DS.B 32000
		DS.L 299
my_stack	DS.L 2