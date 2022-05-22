; New 3d matrix routines. uses NO multiplications.
; original concept by Ben Griffin.
; This version fiddled by Martin Griffiths.

gemrun		EQU 0		; 0 = run from gem
				; 1 = no gem calls	
maxpoints	EQU 400		; Max for 50Hz=408
scx             EQU 159         ; Screen center X.
scy             EQU 99          ; Screen center Y.
squit		EQU 2		; (16-squit) bits for fraction.
dist		EQU 300		; viewpoint distance (perspective)

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
		BSR maketab
		BSR init_ints
		BSR wait_vbl
		MOVEM.L pal(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W

.waitspace	BSR SwapScreens
		move.w #$300,$ffff8240.w
		BSR wait_vbl
		move.w #$000,$ffff8240.w

		BSR clear_oldpoints
		LEA xinc(PC),A6
		BSR rots

		CMP.B #$39,key
		BNE.S .waitspace

		BSR restore_ints
		MOVEM.L old_pal,D0-D7
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

maketab		LEA perstab,A0
		LEA acos,A1
		MOVE #dist+1,D0
		MOVE #32768-dist-2,D1
.lp1		MOVE.L #32768*dist,D2
		DIVS D0,D2
		AND.W #$FFFE,D2
		MOVE.W (A1,D2),(A0)+
		ADDQ #1,D0
		DBF D1,.lp1
		RTS

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
		MOVE.B #$0,$FFFFFA07.W
		MOVE.B #$40,$fffffa09.W
		MOVE.B #$0,$FFFFFA13.W
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

pal		DC.W $000,$777,$000,$000,$000,$000,$000,$000
		DC.W $000,$000,$000,$000,$000,$000,$000,$000

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

; Swap screens.

SwapScreens	LEA log_base(PC),A0
		MOVEM.L (A0)+,D0-D1
		NOT.W (A0)
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		RTS

;-------------------------------------------------------------------------

vbl		ADDQ #1,vbl_timer
		RTE

; Wait for a vbl..

wait_vbl	LEA vbl_timer(PC),A0
		MOVE.W (A0),D0
.wait_vbl	CMP.W (A0),D0
		BEQ.S .wait_vbl
		RTS

WaitD7Vbls	
.wait_lp	BSR wait_vbl
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
frameswitch	DC.W 0

; Clear the old points.

clear_oldpoints	MOVE.L log_base(PC),A0
		MOVEQ #0,D0
		LEA .cse2(PC),A3
		TST.W frameswitch
		BEQ .cse2
		LEA .cse1(PC),A3
.cse1		
		REPT maxpoints	
		MOVE.B D0,2(A0)
		ENDR
		RTS
.cse2		
		REPT maxpoints	
		MOVE.B D0,2(A0)
		ENDR
		RTS

; New rotation routines

rots		
Matrix_make	MOVEM.W (A6)+,D0-D2
		MOVEM.W (A6),D5-D7
	    	ADD.W D0,D5
	    	ADD.W D1,D6
	    	ADD.W D2,D7
		AND #$7FFE,D5
		AND #$7FFE,D6
		AND #$7FFE,D7
		MOVEM.W D5-D7,(A6)
		LEA sin,A0		sine table
		LEA cos,A6		cosine table
		MOVE (A0,D5),D0		sin(xd)
		MOVE (A6,D5),D1		cos(xd)
		MOVE (A0,D6),D2		sin(yd)
		MOVE (A6,D6),D3		cos(yd)
		MOVE (A0,D7),D4		sin(zd)
		MOVE (A6,D7),D5		cos(zd)
		LEA matrix,A1

* sinz*sinx(used twice) - A5
		MOVE D0,D6			sinx
		MULS D4,D6			sinz*sinx
		LSL.L #2,D6
		SWAP D6
		MOVE D6,A5
* sinz*cosx(used twice) - A4
		MOVE D1,D6			cosx
		MULS D4,D6			sinz*cosx
		LSL.L #2,D6
		SWAP D6
		MOVE D6,A4
* Matrix(1,1) cosy*cosx-siny*sinz*sinx
		MOVE D3,D6			cosy
		MULS D1,D6			cosy*cosx
		MOVE A5,D7			sinz*sinx
		MULS D2,D7			siny*sinz*sinx					
		SUB.L D7,D6
		LSL.L #2,D6
		SWAP D6			
		MOVE D6,(A1)+
* Matrix(2,1) siny*cosx+cosy*sinz*sinx 
		MOVE D2,D6
		MULS D1,D6			siny*cosx
		MOVE A5,D7			sinz*sinx
		MULS D3,D7			cosy*sinz*sinx			
		ADD.L D7,D6
		LSL.L #2,D6
		SWAP D6			
		MOVE D6,(A1)+
* Matrix(3,1) -cosz*sinx
		MOVE D5,D6			cosz
		MULS D0,D6			cosz*sinx
		LSL.L #2,D6
		SWAP D6
		NEG D6			-cosz*sinx
		MOVE D6,(A1)+
* Matrix(1,2) -siny*cosz
		MOVE D2,D6			siny
		MULS D5,D6			siny*cosz
		LSL.L #2,D6
		SWAP D6
		NEG D6			-siny*cosz
		MOVE D6,(A1)+
* Matrix(2,2) cosy*cosz		
		MOVE D3,D6			cosy
		MULS D5,D6			cosy*cosz
		LSL.L #2,D6
		SWAP D6
		MOVE D6,(A1)+
* Matrix(3,2) sinz 
		MOVE D4,(A1)+
* Matrix(1,3) cosy*sinx+siny*sinz*cosx
		MOVE D3,D6			cosy
		MULS D0,D6			cosy*sinx
		MOVE A4,D7			sinz*cosx
		MULS D2,D7
		ADD.L D7,D6
		LSL.L #2,D6
		SWAP D6			siny*(sinz*cosx)
		MOVE D6,(A1)+
* Matrix(2,3) siny*sinx-cosy*sinz*cosx
		MULS D0,D2			siny*sinx
		MOVE A4,D7
		MULS D3,D7
		SUB.L D7,D2 
		LSL.L #2,D2
		SWAP D2
		MOVE D2,(A1)+
* Matrix(3,3) cosz*cosx
		MULS D1,D5 
		LSL.L #2,D5
		SWAP D5			cosz*cosx
		MOVE D5,(A1)+

	lea	-18(a1),a0	; a0 -> matrix
	lea	acos,a1		; a1 -> arc-cosine table
	move.w	#$fffe,d6
	movem.w	(a0)+,d1-d3
	and.w	d6,d1
	and.w	d6,d2
	and.w	d6,d3
	move.w	0(a1,d1.w),d1
	move.w	0(a1,d2.w),d2
	move.w	0(a1,d3.w),d3
	move.w d1,md01+2
	neg.w	d1
	move.w d1,md02+2
	move.w d2,md03+2
	neg.w	d2
	move.w d2,md04+2
	move.w d3,md05+2
	neg.w	d3
	move.w d3,md06+2
	movem.w	(a0)+,d1-d3
	and.w	d6,d1		;
	and.w	d6,d2		;
	and.w	d6,d3		;
	move.w	0(a1,d1.w),d1
	move.w	0(a1,d2.w),d2
	move.w	0(a1,d3.w),d3
	move.w d1,md07+2
	neg.w	d1
	move.w d1,md08+2
	move.w d2,md09+2
	neg.w	d2
	move.w d2,md10+2
	move.w d3,md11+2
	neg.w	d3
	move.w d3,md12+2
	movem.w	(a0)+,d1-d3
	and.w	d6,d1
	and.w	d6,d2
	and.w	d6,d3
	move.w	0(a1,d1.w),d1
	move.w	0(a1,d2.w),d2
	move.w	0(a1,d3.w),d3
	move.w d1,md13+2
	neg.w	d1
	move.w d1,md14+2
	move.w d2,md15+2
	neg.w	d2
	move.w d2,md16+2
	move.w d3,md17+2
	neg.w	d3
	move.w d3,md18+2

	lea acos,a0		;a0 -> acos
	lea	points(pc),a1	;cos is in a6
     	move.l	log_base(pc),a5
	
	move.l	(a3),d0		;self-mod. CLS (mono only)
	move.w	(a1)+,d7	;points - 1
	move.l	a6,d4
	moveq #-2,d6

nexp:	move.l	d4,a6		; a6 -> cosine table
	move.l	a6,a2		; a2   "      "
	move.l	a6,a4		; a4   "      "
	add.w (a1)+,a2
	add.w (a1)+,a4
	add.w (a1)+,a6
md01	move.w 2(a2),d1
md02	add.w -2(a2),d1
md03	move.w 2(a2),d2
md04	add.w -2(a2),d2
md05	move.w 2(a2),d3
md06	add.w -2(a2),d3
md07	add.w 2(a4),d1
md08	add.w -2(a4),d1
md09	add.w 2(a4),d2
md10	add.w -2(a4),d2
md11	add.w 2(a4),d3
md12	add.w -2(a4),d3
md13	add.w 2(a6),d1
md14	add.w -2(a6),d1
md15	add.w 2(a6),d2
md16	add.w -2(a6),d2
md17	add.w 2(a6),d3
md18	add.w -2(a6),d3
; now we have d1/d2/d3 as magnitudes in the range -32768 to 32768
; the following code is so contrived and fiddled its unbelievable!
	move.w (a1)+,d5
	lsl.w #6,d5		; scale up... hmmm.............
	move.l d4,a6		; a6 -> cosine table
	add.w (a0,d5),a6
	and d6,d1		;
	and d6,d2		; word lookup
	and d6,d3		;
	move.w (a0,d1),d0	;
	move.w (a0,d2),d1	; arc-cosines.
	move.w (a0,d3),d2	;

	move.w (a6,d2.w),d3	;
	neg.w d2		; cosine jobbies.
	add.w (a6,d2.w),d3	;
	move.w (a6,d1.w),d2	;
	neg.w d1		;
	add.w (a6,d1.w),d2	;
	move.w (a6,d0.w),d1	;
	neg.w d0		;
	add.w (a6,d0.w),d1	;
	and.w d6,d1		;
	and.w d6,d2		;
	asr.w #1,d3
	and.w d6,d3		;	

; perspect

	move.l	d4,a6		
	lea perstab+(1800*2),a2
	add (a2,d3),a6

	move.w (a0,d1),d0	; arc-cosines...
	move.w (a0,d2),d1	;
	move.w (a6,d1.w),d2	; and 
	neg.w d1		; cosine jobbies again.
	add.w (a6,d1.w),d2	;
	move.w (a6,d0.w),d1	;
	neg.w d0		;
	add.w (a6,d0.w),d1	;
	asr.w #3,d1		;
	asr.w #3,d2		;

; and plot ....

	add.w #scx,d1
	clr d0
        move.b xoffs(pc,d1.w),d0		;x offset
	add.w d2,d2
	add.w #(yoffs-xoffs)+(scy*2),d2
        add.w  xoffs(pc,d2.w),d0	   	;the y offs
        move.l  d0,(a3)+			;store the screen word..
	not.w d1
	bset.b	d1,(a5,d0.w)
clipit:	dbra	d7,nexp
	rts

xoffs:
xoff            SET 0
		REPT 20
		DC.B xoff,xoff,xoff,xoff,xoff,xoff,xoff,xoff
xoff		SET xoff+1 		
		DC.B xoff,xoff,xoff,xoff,xoff,xoff,xoff,xoff
xoff		SET xoff+7 		
                ENDR

yoffs:          
yoff            SET 0
                REPT 100
                DC.W yoff,yoff+160
yoff            SET yoff+320
                ENDR

xinc:		dc.w	70*2
zinc:		dc.w    90*2
yinc:		dc.w	100*2
xrot:		dc.w	0
yrot:		dc.w	0
zrot:		dc.w	0

points: 	include sphre400.pod
		;include cubepolr.pob
		;include G:\3d.s\newnomul.3d\spiral.pob

;Trigonometric tables

trig_tab: 	incbin trig1d.dat ; 65k cosine table.
sin:		equ	trig_tab+(3*8192)
cos:		equ	trig_tab+(4*8192)
trig:	  	incbin trig2d.dat ; 65k arccosine table.
acos:		equ	trig+(2*16384)	

		SECTION BSS

matrix		DS.W  9		;for +ve/-ve values..
screens		DS.B 256
		DS.B 32000
		DS.B 32000
		DS.L 299
my_stack	DS.L 2
perstab		DS.W 32768