 ;--------------------------------------------------------------------------
; Picture Tweening routine V4.
; - Nice 'N' Fast. Lower Memory Usage using 2 pass scanning system.
; (C) Sept,Dec 1992 Griff.
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

		LEA cubeTEXT(pc),a0
		LEA dotsphTEXT(pc),A1
		BSR maketrans_text

		BSR display_trans


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
		LSR.W #8,D0
		MOVE.L D0,$FFFF8200.W
		RTS
;-------------------------------------------------------------------------

vbl		MOVEM.L D0-D7/A0-A6,-(SP)
		MOVEM.L pal(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		MOVEM.L (SP)+,D0-D7/A0-A6
		ADDQ #1,vbl_timer
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

;-------------------------------------------------------------------------
; Text transform Routine.

pic_height	EQU 100
pic_size	EQU 160*pic_height

; Produce the frames of a text tween.
; A0-> source text A1 -> dest text.

maketrans_text	BSR clear_frames
		PEA (A1)
		LEA trans_frames,A2
		LEA (a0),a6
		;BSR Print_text
		lea $e3257e,a6
		MOVEQ #$55,D0
.LP		move.w (a6)+,(a2)
		move.w (a6)+,8(a2)
		move.w (a6)+,16(a2)
		move.w (a6)+,24(a2)
		move.w (a6)+,32(a2)
		move.w (a6)+,40(a2)
		lea 160(a2),a2
		dbf d0,.LP
		LEA last_frame,A2
		MOVE.L (SP)+,A6
		BSR Print_text
		BSR DO_both
		RTS  

DO_both		BSR setup_col_cnts

		LEA trans_frames,A0
		LEA coltestsc_ptrs(PC),A1
		LEA coltestsc_cnt(PC),A2
		LEA colsc_xy,A6
		BSR test_cols

		LEA last_frame,A0
		LEA coltestde_ptrs(PC),A1
		LEA coltestde_cnt(PC),A2
		LEA colde_xy,A6
		BSR test_cols
		BSR calc_grads
		RTS

; Clear frames

clear_frames	LEA trans_frames,A2
		MOVEQ #0,D1
		MOVEQ #33-1,D2
.fr_lp		MOVE.W #(pic_size/16)-1,D0
.cl_lp		MOVE.L D1,(A2)+
		MOVE.L D1,(A2)+
		MOVE.L D1,(A2)+
		MOVE.L D1,(A2)+
		DBF D0,.cl_lp
		DBF D2,.fr_lp
		RTS


display_trans

FUCKIT2		MACRO
		BSR wait_vbl	
		LEA trans_frames+i,A0	
		MOVE.L phy_base(PC),A1
		LEA 50*160(A1),A1
		MOVE.W #(pic_size/16)-1,D0
.lp\@		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		DBF D0,.lp\@
		ENDM

FOREVER		
i		SET 0 
		REPT 33
		FUCKIT2
i		SET i+pic_size				
		ENDR
		MOVEQ #100,D7
		BSR WaitD7Vbls	

		REPT 33
i		SET i-pic_size				
		FUCKIT2
		ENDR
		MOVEQ #100,D7
		BSR WaitD7Vbls	

		CMP.B #$39,key
		BNE FOREVER

		RTS

; Do a pixel colour test.
; A0 -> base to do test on.
; A1 -> 16 ptrs to colour x,y buffers
; A2 -> 16 colour count 

do1tst		MACRO
		CLR D6
		ADD.W D5,D5
		ADDX D6,D6
		ADD.W D4,D4
		ADDX D6,D6
		ADD.W D3,D3
		ADDX D6,D6
		ADD.W d2,D2
		ADDX D6,D6			; colour in D6
		ADD.W D6,D6			; col*2
		ADDQ #1,(A2,D6)			; add 1 to count
.ok\@		
		ENDM

do2tst		MACRO
		CLR D6
		ADD.W D5,D5
		ADDX D6,D6
		ADD.W D4,D4
		ADDX D6,D6
		ADD.W D3,D3
		ADDX D6,D6
		ADD.W d2,D2
		ADDX D6,D6			; colour in D6
		LSL #3,D6			; col * 8
		BEQ.S .ok\@
		MOVE.L (A1,D6),A3		; get ptr
		MOVE.W D0,(A3)+			; store this x
		MOVE.W D1,(A3)+			; store this y
		MOVE.L A3,(A1,D6)		; store ptr
.ok\@		
		ENDM

test_cols	LEA (A0),A4
.pass1		MOVE #(pic_height*20)-1,D1		
.y1_lp		MOVEM.W (A0)+,D2/D3/D4/D5	; fetch bpl 1-4
		REPT 16	
		do1tst
		ENDR				
		DBF D1,.y1_lp

.alloc_ptrs	ADDQ.L #2,A2 
		LEA 8(A1),A0	
		MOVEQ #15-1,D1	
.makelp		MOVE.L A6,(A0)+
		MOVE.L A6,(A0)+
		MOVEQ #0,D0
		MOVE.W (A2)+,D0
		LSL.L #2,D0
		ADD.L D0,A6
		DBF D1,.makelp

.pass2		MOVEQ #0,D1			; y=0
.y2_lp		MOVEQ #0,D0			; x=0
		MOVEQ #20-1,D7
.x2_lp		MOVEM.W (A4)+,D2/D3/D4/D5	; fetch bpl 1-4
		REPT 16	
		do2tst
		ADDQ #1,D0			; x=x+1
		ENDR				
		DBF D7,.x2_lp
		ADDQ #1,D1			; y=y+1
		CMP.W #pic_height,D1
		BNE .y2_lp
		RTS

; Create gradient table for each colour

calc_grads	LEA coltestsc_ptrs+8(PC),A0
		LEA coltestde_ptrs+8(PC),A1
		LEA coltestsc_cnt+2(PC),A2
		LEA coltestde_cnt+2(PC),A3
		LEA c1(PC),A6
		MOVEQ #15-1,D7
.col_grad_lp	MOVE.L (A6)+,cmod
		MOVE.L (A6)+,cmod+4
		MOVE.W (A2)+,D0		; source no crds		
		MOVE.W (A3)+,D1		; dest   no crds
		ADDQ.L #4,A0
		MOVE.L (A0)+,A4		; A4-> source crds
		ADDQ.L #4,A1
		MOVE.L (A1)+,A5		; A5-> dest   crds
		MOVEM.L A0-A3/D7,-(SP)
		LEA mul_160(PC),A2
		LEA bit_offs(PC),A3
		TST.W D0		; no source crds
		BEQ .nonedone		; then none to map so skip
		CMP.W D0,D1
		BGE.S .desthasmore
.sourcehasmore	SUBQ #1,D0
		MOVE.L A5,.res1+2
		ADD.W D1,D1
		ADD.W D1,D1
		MOVE.L A5,.res1c+2
		EXT.L D1
		ADD.L D1,.res1c+2

.lp		MOVEM.W (A5)+,D3-D4	; dest x,y
		MOVEM.W (A4)+,D5-D6
		SUB.W D5,D3
		SUB.W D6,D4
		EXT.L D3
		EXT.L D4
		SWAP D3
		SWAP D4
		ASR.L #5,D3
		ASR.L #5,D4
		EXT.L D5
		EXT.L D6
		SWAP D5
		SWAP D6
		BSR.S trans
.res1c		CMP.L #1234,A5
		BNE.S .oknr1
.res1		MOVE.L #1234,A5
.oknr1		DBF D0,.lp
		BRA.S .done

.desthasmore	MOVE.L A4,.res2+2
		ADD.W D0,D0
		ADD.W D0,D0
		MOVE.L A4,.res2c+2
		EXT.L D0
		ADD.L D0,.res2c+2
		MOVE.W D1,D0
		SUBQ #1,D0
.lp2		MOVEM.W (A5)+,D3-D4	; dest x,y
		MOVEM.W (A4)+,D5-D6
		SUB.W D5,D3
		SUB.W D6,D4
		EXT.L D3
		EXT.L D4
		SWAP D3
		SWAP D4
		ASR.L #5,D3
		ASR.L #5,D4
		EXT.L D5
		EXT.L D6
		SWAP D5
		SWAP D6
		BSR.S trans
.res2c		CMP.L #1234,A4
		BNE.S .oknr2
.res2		MOVE.L #1234,A4
.oknr2		DBF D0,.lp2
.nonedone
.done		MOVEM.L (SP)+,D7/A0-A3
		DBF D7,.col_grad_lp
		RTS

; Do 1 frame of a transform. A0-> base to plot onto.

trans		LEA trans_frames+pic_size,A0
		MOVEQ #31-1,D7
pl_lp		ADD.L D3,D5
		ADD.L D4,D6
		MOVE.L D5,D1
		MOVE.L D6,D2
		SWAP D1
		SWAP D2
		ADD.W D2,D2
		ADD.W D1,D1
		ADD.W D1,D1
		MOVE.L (A3,D1),D1
		ADD.W (A2,D2),D1
		MOVE.L A0,A1
		ADD.W D1,A1
		SWAP D1
		MOVE.W D1,D2
		NOT.W D2
cmod		NOP
		NOP
		NOP
		NOP
		LEA pic_size(A0),A0
		DBF D7,pl_lp
		RTS

c1		OR.W d1,(A1)+
		AND.W d2,(A1)+
		AND.W d2,(A1)+
		AND.W d2,(A1)+

c2		AND.W d2,(A1)+
		OR.W d1,(A1)+
		AND.W d2,(A1)+
		AND.W d2,(A1)+

c3		OR.W d1,(A1)+
		OR.W d1,(A1)+
		AND.W d2,(A1)+
		AND.W d2,(A1)+

c4		AND.W d2,(A1)+
		AND.W d2,(A1)+
		OR.W d1,(A1)+
		AND.W d2,(A1)+

c5		OR.W d1,(A1)+
		AND.W d2,(A1)+
		OR.W d1,(A1)+
		AND.W d2,(A1)+

c6		AND.W d2,(A1)+
		OR.W d1,(A1)+
		OR.W d1,(A1)+
		AND.W d2,(A1)+

c7		OR.W d1,(A1)+
		OR.W d1,(A1)+
		OR.W d1,(A1)+
		AND.W d2,(A1)+

c8		AND.W d2,(A1)+
		AND.W d2,(A1)+
		AND.W d2,(A1)+
		OR.W d1,(A1)+

c9		OR.W d1,(A1)+
		AND.W d2,(A1)+
		AND.W d2,(A1)+
		OR.W d1,(A1)+

c10		AND.W d2,(A1)+
		OR.W d1,(A1)+
		AND.W d2,(A1)+
		OR.W d1,(A1)+

c11		OR.W d1,(A1)+
		OR.W d1,(A1)+
		AND.W d2,(A1)+
		OR.W d1,(A1)+

c12		AND.W d2,(A1)+
		AND.W d2,(A1)+
		OR.W d1,(A1)+
		OR.W d1,(A1)+

c13		OR.W d1,(A1)+
		AND.W d2,(A1)+
		OR.W d1,(A1)+
		OR.W d1,(A1)+

c14		AND.W d2,(A1)+
		OR.W d1,(A1)+
		OR.W d1,(A1)+
		OR.W d1,(A1)+

c15		OR.W d1,(A1)+
		OR.W d1,(A1)+
		OR.W d1,(A1)+
		OR.W d1,(A1)+

i		SET 0
bit_offs	
		REPT 20
		DC.W $8000,i
		DC.W $4000,i
		DC.W $2000,i
		DC.W $1000,i
		DC.W $0800,i
		DC.W $0400,i
		DC.W $0200,i
		DC.W $0100,i
		DC.W $0080,i
		DC.W $0040,i
		DC.W $0020,i
		DC.W $0010,i
		DC.W $0008,i
		DC.W $0004,i
		DC.W $0002,i
		DC.W $0001,i
i		SET i+8
		ENDR

i		SET 0				
mul_160		
		REPT 50
		DC.W i,i+160,i+320,i+480
i		SET i+640
		ENDR

coltestsc_ptrs	DS.L 32
coltestsc_cnt	DS.W 16
coltestde_ptrs	DS.L 32
coltestde_cnt	DS.W 16

; Zero colour frequency counts

setup_col_cnts	LEA coltestsc_cnt(PC),A1
		MOVEQ #0,D0
		REPT 8
		MOVE.L D0,(A1)+
		ENDR
		LEA coltestde_cnt(PC),A1
		REPT 8
		MOVE.L D0,(A1)+
		ENDR
		RTS

; Print up text . A6-> text A2-> base for print

Print_text	LEA font_tab(PC),A3
		MOVE.W (A6)+,D1
		MULU #160,D1
		ADDA D1,A2
.row_lp		MOVE.L A6,A1
		MOVEQ #0,D0
.fnd_length	MOVE.B (A1)+,D1
		BEQ.S .found_rowend
		CMP.B #1,D1
		BEQ.S .found_rowend
		EXT.W D1
		ADD.W D1,D1
		ADD.W #16,D0
		BRA.S .fnd_length
.found_rowend	LSR #1,D0
		NEG D0
		ADD.W #160,D0
.do1line	MOVE.B (A6)+,D1
		BEQ.S .row_done
		CMP.B #1,D1
		BEQ.S .text_done 
		MOVE D0,D7
		AND #15,D7
		LEA font_buf(PC),A0
		EXT.W D1
		ADD.W D1,D1
		ADD.W (A3,D1),A0
		MOVE D0,D3
		LSR #1,D3
		AND #$FFF8,D3
		LEA (A2,D3),A1
		MOVEQ #15,D3
.linep_lp	MOVEQ #0,D1
		MOVEQ #0,D2
		MOVEQ #0,D4
		MOVEQ #0,D5
		MOVE (A0)+,D1
		MOVE (A0)+,D2
		MOVE (A0)+,D4
		MOVE (A0)+,D5
		ROR.L D7,D1
		ROR.L D7,D2
		ROR.L D7,D4
		ROR.L D7,D5
		OR.W D1,(A1)+
		OR.W D2,(A1)+
		OR.W D4,(A1)+
		OR.W D5,(A1)+
		SWAP D1
		SWAP D2
		SWAP D4
		SWAP D5
		MOVEM.W D1-D2/D4-D5,(A1)
		LEA 160-8(A1),A1
		DBRA D3,.linep_lp
		ADD #16,D0
		BRA .do1line
.row_done	LEA 16*160(A2),A2
		BRA .row_lp
.text_done	RTS

font_tab	DCB.W 32,44*128
		DC.W 44*128	   ; space  32
		DC.W 38*128	   ; !      33
		DC.W 44*128	   ;        34
		DC.W 44*128	   ;        35
		DC.W 44*128	   ;        36
		DC.W 44*128	   ;        37
		DC.W 44*128	   ;        38
		DC.W 44*128	   ;        39
		DC.W 42*128	   ; (      40
		DC.W 41*128	   ; )      41
		DC.W 44*128	   ;        42
		DC.W 44*128	   ;        43
		DC.W 37*128	   ; ,      44
		DC.W 40*128	   ; -      45
		DC.W 36*128	   ; .      46
		DC.W 44*128	   ;        47
		DC.W 35*128	   ; 0      48
		DC.W 26*128	   ; 1      49
		DC.W 27*128	   ; 2      50
		DC.W 28*128	   ; 3      51
		DC.W 29*128	   ; 4      52
		DC.W 30*128	   ; 5      53
		DC.W 31*128	   ; 6      54
		DC.W 32*128	   ; 7      55
		DC.W 33*128	   ; 8      56
		DC.W 34*128	   ; 9      57
		DC.W 44*128	   ;        58
		DC.W 44*128	   ;        59
		DC.W 44*128	   ;        60
		DC.W 44*128	   ;        61
		DC.W 44*128	   ;        62
		DC.W 39*128	   ;        63
		DC.W 44*128	   ;        64
i		SET 0
		REPT 26
		DC.W i
i		SET i+128
		ENDR

font_buf	INCBIN FONT1616.DAT
		DS.W 128

cubeTEXT	DC.W 40
		DC.B "YES! FUCKING TRANS",0
		DC.B "GO!!!!!!!!!!!!!!!!",1
		EVEN

dotsphTEXT	DC.W 0
		DC.B "THE BEST CODER IN",0
		DC.B "THE FUCKING WORLD",0
		DC.B "DONT YOU KID YOUR-",0	
		DC.B "SELF SUNNNY!!!!!!!",1
		EVEN


pal		dc.w	$000,$222,$444,$033,$666,$033,$033,$033
		dc.w	$033,$010,$121,$232,$343,$454,$565,$676

		SECTION BSS

screens		DS.B 256
		DS.B 32000
		DS.B 32000
		DS.L 399
my_stack	DS.L 3

colsc_xy	DS.L 24000
colde_xy	DS.L 24000

trans_frames	DS.B pic_size*32
last_frame	DS.B pic_size
