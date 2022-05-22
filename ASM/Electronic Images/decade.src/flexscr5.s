* FLEXI SCROLLER By Griff
* (C) JANUARY 1990

		OPT O+,OW-

demo		EQU 0

		IFEQ demo
		CLR -(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		ENDC

* Setup lots of stuff ready for the demo

		MOVE #$2700,SR
		MOVE.L SP,oldsp
		LEA my_stack,SP
		MOVE #$8240,A0
		CLR.L (A0)+
		CLR.L (A0)+
		CLR.L (A0)+
		CLR.L (A0)+
		CLR.L (A0)+
		CLR.L (A0)+
		CLR.L (A0)+
		CLR.L (A0)+
		MOVE.L #screens+256,D0
		CLR.B D0
		MOVE.L D0,log_base
		MOVE.L D0,D1
		LSR #8,D1
		MOVE.L D1,$FFFF8200.W
		MOVE.L D0,log_base1
		ADD.L #17*160,log_base1
		ADD.L #42240,D0
		MOVE.L D0,phy_base
		MOVE.L D0,phy_base1
		ADD.L #17*160,phy_base1
init		LEA old_mfp,A0
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.B $FFFFFA1B.W,(A0)+
		MOVE.B $FFFFFA21.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $120.W,(A0)+
		CLR.B $FFFFFA07.W
		CLR.B $FFFFFA09.W
		CLR.B $FFFFFA13.W
		CLR.B $FFFFFA15.W
		BCLR.B #3,$FFFFFA17.W
		MOVE.L #first_vbl,$70.W
		MOVE #$2300,SR

		MOVEQ #1,D0
		JSR music+28
		BSR cls
		BSR convertvu
		BSR Init_tiles
		BSR setupbuf
		LEA table,A0
		LEA trig,A1
		LEA 180(A1),A2
		MOVE.L log_base1(PC),A3
		MOVEQ #1,D5
		BSR wave4
		BSR clearvert
		BSR copy_led
		BSR flush
		MOVE.B #$12,$FFFFFC02.W
		MOVE #$2700,SR
		MOVE.B #1,$FFFFFA07.W
		MOVE.B #1,$FFFFFA13.W
		MOVE.L #vbl,$70.W
		MOVE #$2300,SR

* Here is the main prog loop
* - clear the old screen.
* - scroll 'normal' scroll.
* - construct rotation scroll.

vbl_lp	LEA vbl_timer(PC),A0
		MOVE (A0),D0
wait_vbl	CMP (A0),D0
		BEQ.S wait_vbl
		LEA scr_point(PC),A1
		MOVE.L (A1)+,A0
		MOVE (A1),D5
		BNE.S pos_ok
		ADDQ.L #1,A0
		MOVE.B (A0),D0
		BNE.S no_res
		LEA text(PC),A0 
no_res	CMP.B #"w",D0
		BEQ newwave
continue	MOVEQ #16,D5
pos_ok	SUBQ #2,D5
		MOVE D5,(A1)
		MOVE.L A0,-(A1)
		CLR D0
		MOVE.B (A0),D0
		SUB.B #32,D0
		LSL #5,D0
		LEA fontbuf(PC),A1         
		ADDA.W D0,A1
l_scroll	LEA scr_buf(PC),A0
		REPT 15
		MOVE (A1)+,D1
		LSR D5,D1
		MOVE (A0),D2
		ADD D2,D2
		ADD D2,D2
		OR D1,D2
		MOVE D2,(A0)+
		ENDR
* Scroll the address buffer.
move_buf	MOVE.L buf_ptr(PC),A0
		LEA 2560(A0),A0
		CMP.L #endscbuf,A0
		BNE.S notresp
		LEA scbuffer,A0
notresp 	MOVE.L A0,buf_ptr
		ADDQ.L #4,A0
		LEA jmp_tab(PC),A6
count		SET 0
		REPT 15
		MOVEM.L (A0)+,D0-D7/A1-A5
		MOVEM.L D0-D7/A1-A5,-56(A0)
		MOVEM.L (A0)+,D0-D7/A1-A5
		MOVEM.L D0-D7/A1-A5,-56(A0)
		MOVEM.L (A0)+,D0-D7/A1-A5
		MOVEM.L D0-D7/A1-A5,-56(A0)
		CLR D0
		MOVE.B scr_buf+count(PC),D0
		ADD D0,D0
		ADD D0,D0
		MOVE.L (A6,D0),-(A0)
		ADDQ.L #8,A0
count		SET count+2
		ENDR
		BSR do_flexscrl
		BRA vbl_lp

end		MOVE #$2700,SR
		MOVEQ #0,D0
		JSR music+28
		LEA old_mfp,A0
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.B (A0)+,$FFFFFA1B.W
		MOVE.B (A0)+,$FFFFFA21.W
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$120.W
		BSET.B #3,$FFFFFA17.W
		BSR flush
		IFEQ demo
		MOVE #$2300,SR
		MOVE.B #$8,$FFFFFC02.W
		MOVE #$777,$FFFF8240.W
		MOVE #$000,$FFFF8246.W
		CLR -(SP)
		TRAP #1
		ENDC
		MOVE.L oldsp(PC),SP
		RTS
oldsp		DC.L 0

* Calculation subrouts for rotation
* scroll...(loadsa waveforms!)

newwave	MOVEM.L A0-A1,-(SP)
		CLR D0
		MOVE.B 1(A0),D0
		ADD D0,D0
		ADD D0,D0
		MOVE.L wave_tab(PC,D0),A6
		LEA table,A0
		LEA trig,A1
		LEA 180(A1),A2
		MOVE.L log_base1,A3
		MOVEQ #1,D5
		JSR (A6)
		MOVEM.L (SP)+,A0-A1
		ADDQ.L #2,A0
.wait		TST switch
		BEQ.S .wait
		BRA continue

wave_tab	DC.L wave0
		DC.L wave1
		DC.L wave2
		DC.L wave3
		DC.L wave4
		DC.L wave5

* normal circle

wave0		MOVEQ #14,D7
y_calclp0	MOVE #319,D6
x_calclp0	MOVE D6,D2
		ADD D2,D2
		MOVE 40(A1,D2),D0
		MOVE 40(A2,D2),D1
		MOVE D7,D2
		ADD #64,D2
		MULS D2,D0
		MULS D2,D1
		LSL.L #2,D0
		LSL.L #2,D1
		SWAP D0
		SWAP D1
		ADD #160,D0
		ADD #100,D1
		MOVE D1,D2
		ADD D1,D1
		ADD D1,D1
		ADD D2,D1
		LSL #5,D1
		MOVE D0,D2
		NOT D0
		AND #15,D0
		CLR D3
		BSET D0,D3
		MOVE D3,(A0)+
		LSR #1,D2
		AND #$FFF8,D2
		MOVE.L A3,A4
		ADD D2,D1
		ADDQ #6,D1
		ADDA.W D1,A4
		MOVE.L A4,(A0)+
		DBF D6,x_calclp0
		DBF D7,y_calclp0
		MOVE.L phy_base1(PC),A3
		DBF D5,wave0
		RTS

* circle at 43 degrees

wave1		MOVEQ #14,D7
y_calclp1	MOVE #319,D6
x_calclp1	MOVE D6,D2
		ADD D2,D2
		MOVE 40(A1,D2),D0
		MOVE 126(A2,D2),D1
		MOVE D7,D2
		ADD #62,D2
		MULS D2,D0
		MULS D2,D1
		LSL.L #2,D0
		LSL.L #2,D1
		SWAP D0
		SWAP D1
		ADD #160,D0
		ADD #100,D1
		MOVE D1,D2
		ADD D1,D1
		ADD D1,D1
		ADD D2,D1
		LSL #5,D1
		MOVE D0,D2
		NOT D0
		AND #15,D0
		CLR D3
		BSET D0,D3
		MOVE D3,(A0)+
		LSR #1,D2
		AND #$FFF8,D2
		MOVE.L A3,A4
		ADD D2,D1
		ADDQ #6,D1
		ADDA.W D1,A4
		MOVE.L A4,(A0)+
		DBF D6,x_calclp1
		DBF D7,y_calclp1
		MOVE.L phy_base1(PC),A3
		DBF D5,wave1
		RTS

* Smooth double sinus wave * 40

wave2		MOVEQ #14,D7
y_calclp2	BSR edgestop1
		MOVE #319-65,D6
x_calclp2	MOVE D6,D2
		ADD D2,D2
		ADD D2,D2
		MOVE 40(A2,D2),D1
		MULS #40,D1
		LSL.L #2,D1
		SWAP D1
		MOVE D6,D0
		NEG d0
		ADD #320-33,D0
		ADD #100,D1
		SUB D7,D1
		MOVE D1,D2
		ADD D1,D1
		ADD D1,D1
		ADD D2,D1
		LSL #5,D1
		MOVE D0,D2
		NOT D0
		AND #15,D0
		CLR D3
		BSET D0,D3
		MOVE D3,(A0)+
		LSR #1,D2
		AND #$FFF8,D2
		MOVE.L A3,A4
		ADD D2,D1
		ADDQ #6,D1
		ADDA.W D1,A4
		MOVE.L A4,(A0)+
		DBF D6,x_calclp2
		BSR edgestop2
		DBF D7,y_calclp2
		MOVE.L phy_base1(PC),A3
		DBF D5,wave2
		RTS

* figure of eight...

wave3		MOVEQ #14,D7
y_calclp3	MOVE #319,D6
x_calclp3	MOVE D6,D2
		ADD D2,D2
		MOVE 126(A2,D2),D0
		MOVE 40(A2,D2),D1
		MULS D0,D1
		LSL.L #2,D1
		SWAP D1
		MULS #80,D0
		MULS #80,D1
		LSL.L #2,D0
		LSL.L #2,D1
		SWAP D0
		SWAP D1
		SUB d7,d0
		ADD #160,D0
		ADD #64,D1
		MOVE D1,D2
		ADD D1,D1
		ADD D1,D1
		ADD D2,D1
		LSL #5,D1
		MOVE D0,D2
		NOT D0
		AND #15,D0
		CLR D3
		BSET D0,D3
		MOVE D3,(A0)+
		LSR #1,D2
		AND #$FFF8,D2
		MOVE.L A3,A4
		ADD D2,D1
		ADDQ #6,D1
		ADDA.W D1,A4
		MOVE.L A4,(A0)+
		DBF D6,x_calclp3
		DBF D7,y_calclp3
		MOVE.L phy_base1(PC),A3
		DBF D5,wave3
		RTS

* Straight scroller

wave4		MOVEQ #14,D7
y_calclp4	BSR edgestop1
		MOVE #319-65,D6
x_calclp4	MOVE D6,D0
		MOVE D7,D1
		NEG D1
		ADD #96,D1
		NEG D0
		ADD #320-33,D0
		MOVE D1,D2
		ADD D1,D1
		ADD D1,D1
		ADD D2,D1
		LSL #5,D1
		MOVE D0,D2
		NOT D0
		AND #15,D0
		CLR D3
		BSET D0,D3
		MOVE D3,(A0)+
		LSR #1,D2
		AND #$FFF8,D2
		MOVE.L A3,A4
		ADD D2,D1
		ADDQ #6,D1
		ADDA.W D1,A4
		MOVE.L A4,(A0)+
		DBF D6,x_calclp4
		BSR edgestop2
		DBF D7,y_calclp4
		MOVE.L phy_base1(PC),A3
		DBF D5,wave4
		RTS

* Smooth double sinus wave * 20 ...

wave5		MOVEQ #14,D7
y_calclp5	BSR edgestop1
		MOVE #319-65,D6
x_calclp5	MOVE D6,D2
		ADD D2,D2
		ADD D2,D2
		MOVE 40(A2,D2),D1
		MULS #20,D1
		LSL.L #2,D1
		SWAP D1
		MOVE D6,D0
		NEG d0
		ADD #320-33,D0
		ADD #108,D1
		SUB D7,D1
		MOVE D1,D2
		ADD D1,D1
		ADD D1,D1
		ADD D2,D1
		LSL #5,D1
		MOVE D0,D2
		NOT D0
		AND #15,D0
		CLR D3
		BSET D0,D3
		MOVE D3,(A0)+
		LSR #1,D2
		AND #$FFF8,D2
		MOVE.L A3,A4
		ADD D2,D1
		ADDQ #6,D1
		ADDA.W D1,A4
		MOVE.L A4,(A0)+
		DBF D6,x_calclp5
		BSR edgestop2
		DBF D7,y_calclp5
		MOVE.L phy_base1(PC),A3
		DBF D5,wave5
		RTS

edgestop1	CLR.W (A0)+
		MOVE.L A4,(A0)+
		BRA edgestop2
		RTS
edgestop2	REPT 32
		CLR.W (A0)+
		MOVE.L A4,(A0)+
		ENDR
		RTS

* Vbl to play music\inc timer...

first_vbl	ADDQ #1,vbl_timer
		RTE

vbl		MOVE #$2500,SR
		MOVEM.L D0-A6,-(SP)
		CLR.B $FFFFFA1B.W
		MOVE.L #hbl1,$120.W
		MOVE.B #33,$FFFFFA21.W
		MOVE.B #8,$FFFFFA1B.W
		BTST.B #0,$FFFFFC00.W
		BEQ not_key
		MOVE.B $FFFFFC02.W,D0
		CMP.B #$39,D0
		BNE not_key
		PEA end(PC)
		MOVE #$2700,-(SP)
		RTE
not_key	LEA log_base(PC),A0
		MOVE.L (A0)+,D0
		MOVE.L (A0)+,D1
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR #8,D1
		MOVE.L D1,$FFFF8200.W
		NOT switch
		ADDQ #1,vbl_timer
		MOVE #$8240,A0
		MOVE.L #$00000777,(A0)+
		MOVE.L #$01110222,(A0)+
		MOVE.L #$03330444,(A0)+
		MOVE.L #$05550101,(A0)+
		MOVE.L #$07770323,(A0)+
		MOVE.L #$04340545,(A0)+
		MOVE.L #$00540043,(A0)+
		MOVE.L #$00320212,(A0)+

; Plot parallax tiles onto the screen

Tiles		LEA para_ptr,A0
		MOVE (A0),D0
		ADDQ #4,D0
		AND #8191,D0
		MOVE D0,(A0)+
		ADDA.W D0,A0
		MOVE (A0)+,D0
		MOVE (A0)+,D1
		MOVE.L log_base(PC),A0
		LEA 31200-16(A0),A0
		LEA tiles,A1
		MOVEQ #31,D2
		AND D2,D0		
		AND D2,D1		
		MOVEQ #10,D2
		LSL D2,D0
		LSL #4,D1
		ADD D1,D0
		ADDA.W D0,A1
		LEA -5120(A0),A2
		LEA -10240(A0),A3
		LEA -15360(A0),A4
		LEA -20480(A0),A5
		MOVE #32,A6
		REPT 32
		MOVEM.L (A1)+,D0-D3
		MOVE.L D0,D4
		MOVE.L D1,D5
		MOVE.L D2,D6
		MOVE.L D3,D7
		MOVEM.L D0-D7,-(A0)
		MOVEM.L D0-D7,-(A0)
		MOVEM.L D0-D7,-(A0)
		MOVEM.L D0-D7,-(A0)
		MOVEM.L D0-D7,-(A2)
		MOVEM.L D0-D7,-(A2)
		MOVEM.L D0-D7,-(A2)
		MOVEM.L D0-D7,-(A2)
		MOVEM.L D0-D7,-(A3)
		MOVEM.L D0-D7,-(A3)
		MOVEM.L D0-D7,-(A3)
		MOVEM.L D0-D7,-(A3)
		MOVEM.L D0-D7,-(A4)
		MOVEM.L D0-D7,-(A4)
		MOVEM.L D0-D7,-(A4)
		MOVEM.L D0-D7,-(A4)
		MOVEM.L D0-D7,-(A5)
		MOVEM.L D0-D7,-(A5)
		MOVEM.L D0-D7,-(A5)
		MOVEM.L D0-D7,-(A5)
		SUB A6,A0
		SUB A6,A2
		SUB A6,A3
		SUB A6,A4
		SUB A6,A5
		ENDR

; The vertical disting scrollers rout.

vscroll	lea vscr_point(PC),A1
		move.l (a1)+,a0
		move.w (a1),d5
		addq #4,d5
		cmp #32,d5
		bne.s vpos_ok
		addq.l #1,a0
		moveq #0,d5
vpos_ok	move.b (a0),d0
		bne vnotend
		lea vtext(PC),a0
vnotend	move.w d5,(a1)
		move.l a0,-(a1)
		moveq #0,d0
		move.b (a0),d0
		sub.b #32,d0
		lsl #5,d0               
		add.w d5,d0
		lea vfontbuf,A1         
		adda.w d0,A1
		move.l vbuf_ptr(pc),a0
		addq.l #8,a0
		cmp.l #vscrbuf1+(231*4),a0
		ble.s notzip
		lea vscrbuf1,a0
notzip	move.l a0,vbuf_ptr
		moveq #0,d0
		moveq #0,d1
		move.w (a1)+,D0
		move.w (a1)+,D1
i		set 0
		rept 16
		movem.l d0-d1,i-8(a0)
		movem.l d0-d1,i+(232*4)-8(a0)
		add.l d0,d0
		add.l d1,d1
i		set i+(231*8)
		endr
		lea vertwaveptr(pc),a0
		move.l (a0),a2
		subq.l #2,a2
		cmp.l #vertwave,a2
		bne.s notvwvewr
		lea vertwaveend-462,a2
notvwvewr	move.l a2,(a0)
copyvscroll	move.l vbuf_ptr(pc),a0
		lea 100(a0),a0
		move.l log_base(pc),a1
i		set 6
j		set -100
		rept 50
		move.w (a2)+,d1
		move.l j(a0,d1),d0
		move.l d0,i(a1)
		move.l d0,i+144(a1)
i		set i+160
j		set j+4
		endr
		lea 200(a0),a0
j		set -100
		rept 50
		move.w (a2)+,d1
		move.l j(a0,d1),d0
		move.l d0,i(a1)
		move.l d0,i+144(a1)
i		set i+160
j		set j+4
		endr
		lea 200(a0),a0
j		set -100
		rept 50
		move.w (a2)+,d1
		move.l j(a0,d1),d0
		move.l d0,i(a1)
		move.l d0,i+144(a1)
i		set i+160
j		set j+4
		endr
		lea 200(a0),a0
j		set -100
		rept 50
		move.w (a2)+,d1
		move.l j(a0,d1),d0
		move.l d0,i(a1)
		move.l d0,i+144(a1)
i		set i+160
j		set j+4
		endr
		lea 200(a0),a0
		lea 32000(a1),a1
i		set 6
j		set -100
		rept 30
		move.w (a2)+,d1
		move.l j(a0,d1),d0
		move.l d0,i(a1)
		move.l d0,i+144(a1)
i		set i+160
j		set j+4
		ENDR

Vu_meter	MOVE.L log_base(PC),A5
 		add.l #33120,a5
		lea $ffff8800.w,a6
		moveq #$f,D7
		move.b #$8,(a6)
		move.b (a6),d0
		and.w	d7,d0
		lea.l	65+8(a5),a0		
		bsr printbar
		moveq #11,d0
		move.w vbl_timer(pc),d1
		lsr #1,d1
		and #3,d1
		add d1,d0
		lea.l (160*6)+65+8(a5),a0		
		bsr printbar
		move.b #$a,(a6)
		move.b (a6),d0
		and.w	d7,d0
		lea (160*12)+65+8(A5),a0		
		bsr printbar
		movem.l (a7)+,d0-a6
		rte

printbar	lea vus+(4*4)(pc),a1
		lea vus+(12*4)(pc),a2

greenplot	macro
		subq #1,d0
		bpl.s zok\@
		lea vus(pc),a1
		lea vus+(8*4)(pc),a2
		movem.l (a1),d1-d4
zok\@		movep.l d1,i(a0)
		movep.l d1,j(a0)
		movep.l d2,i+160(a0)
		movep.l d2,j+160(a0)
		movep.l d3,i+320(a0)
		movep.l d3,j+320(a0)
		movep.l d4,i+480(a0)
		movep.l d4,j+480(a0)
		endm

redplot	macro
		subq #1,d0
		bpl.s xok\@
		lea vus+(8*4)(pc),a2
		movem.l (a2),d1-d4
xok\@		movep.l d1,i(a0)
		movep.l d1,j(a0)
		movep.l d2,i+160(a0)
		movep.l d2,j+160(a0)
		movep.l d3,i+320(a0)
		movep.l d3,j+320(a0)
		movep.l d4,i+480(a0)
		movep.l d4,j+480(a0)
		endm

		movem.l (a1),d1-d4
i		set 0
j		set 7
		greenplot
i		set i-1
j 		set j+1
		greenplot
i		set i-7
j 		set j+7
		greenplot
i		set i-1
j 		set j+1
		greenplot
i		set i-7
j 		set j+7
		greenplot
i		set i-1
j 		set j+1
		greenplot
i		set i-7
j 		set j+7
		greenplot
i		set i-1
j 		set j+1
		greenplot
i		set i-7
j 		set j+7
		greenplot
i		set i-1
j 		set j+1
		greenplot
i		set i-7
j 		set j+7
		greenplot
i		set i-1
j 		set j+1
		movem.l (a2),d1-d4
		redplot
i		set i-7
j 		set j+7
		redplot
i		set i-1
j 		set j+1
		redplot
i		set i-7
j 		set j+7
		redplot
		rts

convertvu	lea vus(pc),a0
		lea (a0),a1
		moveq #15,d7
convv_lp	movep.l (a0),d0
		move.l d0,(a1)+
		addq.l #8,a0
		dbf d7,convv_lp
		rts

vus		incbin FLEXSCRL.INC\flexvu.dat

vertwaveptr	DC.L vertwaveend-462
vbuf_ptr	DC.L vscrbuf1
vscr_point	DC.L vtext
vpix_pos	DC.W 0
vtext		
 DC.B "      "
 DC.B	"      YES!   THE FLEXISCROLL IS HERE!   WELL, NOT THIS SCROLLER, BUT THE ONE IN THE MIDDLE OF THE SCREEN!  *MASTER* HERE, TO RATTLE YOU ALL AGAIN, WITH STORIES FULL OF CRAP!   RIGHT, LET'S HAVE A QUICK WORD ABOUT SOFTWARE HOUSES.. WITH SOME "
 DC.B	"GAMES THEY RELEASE... ONES WHOSE WORK I ADMIRE, FOR VARIOUS THINGS... BULLFROG... IMAGEWORKS... ASSEMBLY LINE - VERY GOOD CONTRIBUTIONS, IN VIRTUALLY EVERY AREA OF A GAME... OCEAN - WHO HAVE CERTAINLY IMPROVED SINCE THEIR START ON THE ST... "
 DC.B	"SALES CURVE... ELECTRONIC ARTS... ANCO - FOR KICK OFF/2... NOVAGEN - DAMOCLES, NEED I SAY MORE!... THALION - NICE CODING, GRAPHICS, MUSIC, ALL THESE FINE, BUT NOT NEARLY ENOUGH PUT TOWARDS GAMEPLAY - WARP IS THE MAIN "
 DC.B	"CRITICISM, BUT IT MAKES THE GAME!!... THAT'S IT FOR THE SOFTWARE HOUSES... JUST TO WRAP US THIS SCROLLTEXT (AS I AM QUITE TIRED AND CAN'T BE BOTHERED TO TYPE OUT MUCH MORE!) JUST THE STATUS ON THIS FUCKING EXCELLENT DEMO OF OURS... A FEW "
 DC.B	"SCREENS HAVE BEEN PACKED AND WRITTEN TO THE DISK... WE'RE STILL WAITING FOR HOTLINE'S SCREEN THOUGH, BUT THAT SHOULD BE HERE IN A FEW HOURS TIME (WE HOPE!)... THIS DEMO IS HOPED TO BE SENT OUT THIS COMING MONDAY/TUESDAY, WELL, YOU KNOW THIS"
 DC.B	" BY NOW, OR AT LEAST YOU HAVE THE DEMO!... OK, THAT'S IT REALLY, LET'S WRAP IT ALL UP....................             YEP, WE'RE REPEATING IT NOW..........              "
		DC.B 0
		EVEN

vertwave	incbin FLEXSCRL.INC\vertwave.dat
		DS.w 60
vertwaveend

hbl1		MOVE.L A0,USP
		CLR.B $FFFFFA1B.W
		MOVE #$8244,A0
		MOVE.L #$00220033,(A0)+
		MOVE.L #$00440102,(A0)+
		MOVE.L #$02030304,(A0)+
		MOVE.L #$07770777,(A0)+
		MOVE.L #$07770777,(A0)+
		MOVE.L #$07770777,(A0)+
		MOVE.L #$07770777,(A0)+
		MOVE.L #bot_bord,$120.W
		MOVE.B #199-33,$FFFFFA21.W
		MOVE.B #8,$FFFFFA1B.W
		MOVE.L USP,A0
		RTE

bot_bord	MOVE #$2700,SR
		MOVE.W D0,-(SP)
		MOVE.L A1,USP
		CLR D0
		DCB.W 19,$4E71
		MOVE.B $ffff8209.w,D0
		JMP NOPLIST-96(PC,D0)
NOPLIST	DCB.W 40,$4E71
		CLR.B $FFFFFA1B.W
		MOVE #$8240,A1
		MOVE.L #$00000777,(A1)+
		MOVE.L #$01110222,(A1)+
		MOVE.L #$03330444,(A1)+
		MOVE.L #$05550314,(A1)+
		MOVE.L #$07770200,(A1)+
		MOVE.L #$04000600,(A1)+
		MOVE.L #$00200040,(A1)+
		MOVE.L #$00600777,(A1)+
		MOVE.B #0,$FF820A
		DCB.W 10,$4E71
		MOVE.W (SP)+,D0
		MOVE.L USP,A1
		MOVE.B #2,$FF820A
		BSR music+6+28
		RTE

* Plot the flexscroll from the jump table

do_flexscrl	LEA table,A0
		TST switch
		BEQ.S first_case
		LEA 6*320*15(A0),A0
first_case	MOVE.L buf_ptr(PC),A2
		MOVE #(40*15)-1,D6
loop		MOVE.L (A2)+,A3
		JMP (A3)

* Construct the rotation scroll
* from the normal scroller

* macro to plot 8 pixels from the
* precalcualted data - quickly!!

t		MACRO
id		SET 0		
		
		IFC '\1','1'
		MOVE (A0)+,D2
		MOVE.L (A0)+,A1
		OR D2,(A1)
		ELSEIF
id		SET id+6
		ENDC
		
		IFC '\2','1'
		IFNE id
		LEA id(A0),A0
		ENDC
		MOVE (A0)+,D2
		MOVE.L (A0)+,A1
		OR D2,(A1)
id		SET 0		
		ELSEIF
id		SET id+6
		ENDC
		
		IFC '\3','1'
		IFNE id
		LEA id(A0),A0
		ENDC
		MOVE (A0)+,D2
		MOVE.L (A0)+,A1
		OR D2,(A1)
id		SET 0		
		ELSEIF
id		SET id+6
		ENDC
		
		IFC '\4','1'
		IFNE id
		LEA id(A0),A0
		ENDC
		MOVE (A0)+,D2
		MOVE.L (A0)+,A1
		OR D2,(A1)
id		SET 0		
		ELSEIF
id		SET id+6
		ENDC
		
		IFC '\5','1'
		IFNE id
		LEA id(A0),A0
		ENDC
		MOVE (A0)+,D2
		MOVE.L (A0)+,A1
		OR D2,(A1)
id		SET 0		
		ELSEIF
id		SET id+6
		ENDC
		
		IFC '\6','1'
		IFNE id
		LEA id(A0),A0
		ENDC
		MOVE (A0)+,D2
		MOVE.L (A0)+,A1
		OR D2,(A1)
id		SET 0		
		ELSEIF
id		SET id+6
		ENDC
		IFC '\7','1'
		IFNE id
		LEA id(A0),A0
		ENDC
		MOVE (A0)+,D2
		MOVE.L (A0)+,A1
		OR D2,(A1)
id		SET 0		
		ELSEIF
id		SET id+6
		ENDC
		
		IFC '\8','1'
		IFNE id
		LEA id(A0),A0
		ENDC
		MOVE (A0)+,D2
		MOVE.L (A0)+,A1
		OR D2,(A1)
id		SET 0		
		ELSEIF
id		SET id+6
		ENDC
		IFNE id
		LEA id(A0),A0
		ENDC
		DBF D6,loop
		RTS
		ENDM

jmp_tab	DC.L c0,c1,c2,c3,c4,c5,c6,c7,c8,c9
		DC.L c10,c11,c12,c13,c14,c15,c16,c17,c18,c19
		DC.L c20,c21,c22,c23,c24,c25,c26,c27,c28,c29
		DC.L c30,c31,c32,c33,c34,c35,c36,c37,c38,c39
		DC.L c40,c41,c42,c43,c44,c45,c46,c47,c48,c49
		DC.L c50,c51,c52,c53,c54,c55,c56,c57,c58,c59
		DC.L c60,c61,c62,c63,c64,c65,c66,c67,c68,c69
		DC.L c70,c71,c72,c73,c74,c75,c76,c77,c78,c79
		DC.L c80,c81,c82,c83,c84,c85,c86,c87,c88,c89
		DC.L c90,c91,c92,c93,c94,c95,c96,c97,c98,c99
		DC.L c100,c101,c102,c103,c104,c105,c106,c107,c108,c109
		DC.L c110,c111,c112,c113,c114,c115,c116,c117,c118,c119
		DC.L c120,c121,c122,c123,c124,c125,c126,c127,c128,c129
		DC.L c130,c131,c132,c133,c134,c135,c136,c137,c138,c139
		DC.L c140,c141,c142,c143,c144,c145,c146,c147,c148,c149
		DC.L c150,c151,c152,c153,c154,c155,c156,c157,c158,c159
		DC.L c160,c161,c162,c163,c164,c165,c166,c167,c168,c169
		DC.L c170,c171,c172,c173,c174,c175,c176,c177,c178,c179
		DC.L c180,c181,c182,c183,c184,c185,c186,c187,c188,c189
		DC.L c190,c191,c192,c193,c194,c195,c196,c197,c198,c199
		DC.L c200,c201,c202,c203,c204,c205,c206,c207,c208,c209
		DC.L c210,c211,c212,c213,c214,c215,c216,c217,c218,c219
		DC.L c220,c221,c222,c223,c224,c225,c226,c227,c228,c229
		DC.L c230,c231,c232,c233,c234,c235,c236,c237,c238,c239
		DC.L c240,c241,c242,c243,c244,c245,c246,c247,c248,c249
		DC.L c250,c251,c252,c253,c254,c255

c0		t 0,0,0,0,0,0,0,0
c1		t 0,0,0,0,0,0,0,1
c2  		t 0,0,0,0,0,0,1,0
c3		t 0,0,0,0,0,0,1,1
c4		t 0,0,0,0,0,1,0,0
c5		t 0,0,0,0,0,1,0,1
c6		t 0,0,0,0,0,1,1,0
c7		t 0,0,0,0,0,1,1,1
c8		t 0,0,0,0,1,0,0,0
c9		t 0,0,0,0,1,0,0,1
c10		t 0,0,0,0,1,0,1,0
c11		t 0,0,0,0,1,0,1,1
c12		t 0,0,0,0,1,1,0,0
c13		t 0,0,0,0,1,1,0,1
c14		t 0,0,0,0,1,1,1,0
c15		t 0,0,0,0,1,1,1,1
c16		t 0,0,0,1,0,0,0,0
c17		t 0,0,0,1,0,0,0,1
c18		t 0,0,0,1,0,0,1,0
c19		t 0,0,0,1,0,0,1,1
c20		t 0,0,0,1,0,1,0,0
c21		t 0,0,0,1,0,1,0,1
c22		t 0,0,0,1,0,1,1,0
c23		t 0,0,0,1,0,1,1,1
c24		t 0,0,0,1,1,0,0,0
c25		t 0,0,0,1,1,0,0,1
c26		t 0,0,0,1,1,0,1,0
c27		t 0,0,0,1,1,0,1,1
c28		t 0,0,0,1,1,1,0,0
c29		t 0,0,0,1,1,1,0,1
c30		t 0,0,0,1,1,1,1,0
c31		t 0,0,0,1,1,1,1,1
c32		t 0,0,1,0,0,0,0,0				
c33		t 0,0,1,0,0,0,0,1
c34  		t 0,0,1,0,0,0,1,0
c35		t 0,0,1,0,0,0,1,1
c36		t 0,0,1,0,0,1,0,0
c37		t 0,0,1,0,0,1,0,1
c38		t 0,0,1,0,0,1,1,0
c39		t 0,0,1,0,0,1,1,1
c40		t 0,0,1,0,1,0,0,0
c41		t 0,0,1,0,1,0,0,1
c42		t 0,0,1,0,1,0,1,0
c43		t 0,0,1,0,1,0,1,1
c44		t 0,0,1,0,1,1,0,0
c45		t 0,0,1,0,1,1,0,1
c46		t 0,0,1,0,1,1,1,0
c47		t 0,0,1,0,1,1,1,1
c48		t 0,0,1,1,0,0,0,0
c49		t 0,0,1,1,0,0,0,1
c50		t 0,0,1,1,0,0,1,0
c51		t 0,0,1,1,0,0,1,1
c52		t 0,0,1,1,0,1,0,0
c53		t 0,0,1,1,0,1,0,1
c54		t 0,0,1,1,0,1,1,0
c55		t 0,0,1,1,0,1,1,1
c56		t 0,0,1,1,1,0,0,0
c57		t 0,0,1,1,1,0,0,1
c58		t 0,0,1,1,1,0,1,0
c59		t 0,0,1,1,1,0,1,1
c60		t 0,0,1,1,1,1,0,0
c61		t 0,0,1,1,1,1,0,1
c62		t 0,0,1,1,1,1,1,0
c63		t 0,0,1,1,1,1,1,1
c64		t 0,1,0,0,0,0,0,0				
c65		t 0,1,0,0,0,0,0,1
c66  		t 0,1,0,0,0,0,1,0
c67		t 0,1,0,0,0,0,1,1
c68		t 0,1,0,0,0,1,0,0
c69		t 0,1,0,0,0,1,0,1
c70		t 0,1,0,0,0,1,1,0
c71		t 0,1,0,0,0,1,1,1
c72		t 0,1,0,0,1,0,0,0
c73		t 0,1,0,0,1,0,0,1
c74		t 0,1,0,0,1,0,1,0
c75		t 0,1,0,0,1,0,1,1
c76		t 0,1,0,0,1,1,0,0
c77		t 0,1,0,0,1,1,0,1
c78		t 0,1,0,0,1,1,1,0
c79		t 0,1,0,0,1,1,1,1
c80		t 0,1,0,1,0,0,0,0
c81		t 0,1,0,1,0,0,0,1
c82		t 0,1,0,1,0,0,1,0
c83		t 0,1,0,1,0,0,1,1
c84		t 0,1,0,1,0,1,0,0
c85		t 0,1,0,1,0,1,0,1
c86		t 0,1,0,1,0,1,1,0
c87		t 0,1,0,1,0,1,1,1
c88		t 0,1,0,1,1,0,0,0
c89		t 0,1,0,1,1,0,0,1
c90		t 0,1,0,1,1,0,1,0
c91		t 0,1,0,1,1,0,1,1
c92		t 0,1,0,1,1,1,0,0
c93		t 0,1,0,1,1,1,0,1
c94		t 0,1,0,1,1,1,1,0
c95		t 0,1,0,1,1,1,1,1
c96		t 0,1,1,0,0,0,0,0				
c97		t 0,1,1,0,0,0,0,1
c98  		t 0,1,1,0,0,0,1,0
c99		t 0,1,1,0,0,0,1,1
c100		t 0,1,1,0,0,1,0,0
c101		t 0,1,1,0,0,1,0,1
c102		t 0,1,1,0,0,1,1,0
c103		t 0,1,1,0,0,1,1,1
c104		t 0,1,1,0,1,0,0,0
c105		t 0,1,1,0,1,0,0,1
c106		t 0,1,1,0,1,0,1,0
c107		t 0,1,1,0,1,0,1,1
c108		t 0,1,1,0,1,1,0,0
c109		t 0,1,1,0,1,1,0,1
c110		t 0,1,1,0,1,1,1,0
c111		t 0,1,1,0,1,1,1,1
c112		t 0,1,1,1,0,0,0,0
c113		t 0,1,1,1,0,0,0,1
c114		t 0,1,1,1,0,0,1,0
c115		t 0,1,1,1,0,0,1,1
c116		t 0,1,1,1,0,1,0,0
c117		t 0,1,1,1,0,1,0,1
c118		t 0,1,1,1,0,1,1,0
c119		t 0,1,1,1,0,1,1,1
c120		t 0,1,1,1,1,0,0,0
c121		t 0,1,1,1,1,0,0,1
c122		t 0,1,1,1,1,0,1,0
c123		t 0,1,1,1,1,0,1,1
c124		t 0,1,1,1,1,1,0,0
c125		t 0,1,1,1,1,1,0,1
c126		t 0,1,1,1,1,1,1,0
c127		t 0,1,1,1,1,1,1,1
c128		t 1,0,0,0,0,0,0,0				
c129		t 1,0,0,0,0,0,0,1
c130 		t 1,0,0,0,0,0,1,0
c131		t 1,0,0,0,0,0,1,1
c132		t 1,0,0,0,0,1,0,0
c133		t 1,0,0,0,0,1,0,1
c134		t 1,0,0,0,0,1,1,0
c135		t 1,0,0,0,0,1,1,1
c136		t 1,0,0,0,1,0,0,0
c137		t 1,0,0,0,1,0,0,1
c138		t 1,0,0,0,1,0,1,0
c139		t 1,0,0,0,1,0,1,1
c140		t 1,0,0,0,1,1,0,0
c141		t 1,0,0,0,1,1,0,1
c142		t 1,0,0,0,1,1,1,0
c143		t 1,0,0,0,1,1,1,1
c144		t 1,0,0,1,0,0,0,0
c145		t 1,0,0,1,0,0,0,1
c146		t 1,0,0,1,0,0,1,0
c147		t 1,0,0,1,0,0,1,1
c148		t 1,0,0,1,0,1,0,0
c149		t 1,0,0,1,0,1,0,1
c150		t 1,0,0,1,0,1,1,0
c151		t 1,0,0,1,0,1,1,1
c152		t 1,0,0,1,1,0,0,0
c153		t 1,0,0,1,1,0,0,1
c154		t 1,0,0,1,1,0,1,0
c155		t 1,0,0,1,1,0,1,1
c156		t 1,0,0,1,1,1,0,0
c157		t 1,0,0,1,1,1,0,1
c158		t 1,0,0,1,1,1,1,0
c159		t 1,0,0,1,1,1,1,1
c160		t 1,0,1,0,0,0,0,0				
c161		t 1,0,1,0,0,0,0,1
c162 		t 1,0,1,0,0,0,1,0
c163		t 1,0,1,0,0,0,1,1
c164		t 1,0,1,0,0,1,0,0
c165		t 1,0,1,0,0,1,0,1
c166		t 1,0,1,0,0,1,1,0
c167		t 1,0,1,0,0,1,1,1
c168		t 1,0,1,0,1,0,0,0
c169		t 1,0,1,0,1,0,0,1
c170		t 1,0,1,0,1,0,1,0
c171		t 1,0,1,0,1,0,1,1
c172		t 1,0,1,0,1,1,0,0
c173		t 1,0,1,0,1,1,0,1
c174		t 1,0,1,0,1,1,1,0
c175		t 1,0,1,0,1,1,1,1
c176		t 1,0,1,1,0,0,0,0
c177		t 1,0,1,1,0,0,0,1
c178		t 1,0,1,1,0,0,1,0
c179		t 1,0,1,1,0,0,1,1
c180		t 1,0,1,1,0,1,0,0
c181		t 1,0,1,1,0,1,0,1
c182		t 1,0,1,1,0,1,1,0
c183		t 1,0,1,1,0,1,1,1
c184		t 1,0,1,1,1,0,0,0
c185		t 1,0,1,1,1,0,0,1
c186		t 1,0,1,1,1,0,1,0
c187		t 1,0,1,1,1,0,1,1
c188		t 1,0,1,1,1,1,0,0
c189		t 1,0,1,1,1,1,0,1
c190		t 1,0,1,1,1,1,1,0
c191		t 1,0,1,1,1,1,1,1
c192		t 1,1,0,0,0,0,0,0				
c193		t 1,1,0,0,0,0,0,1
c194 		t 1,1,0,0,0,0,1,0
c195		t 1,1,0,0,0,0,1,1
c196		t 1,1,0,0,0,1,0,0
c197		t 1,1,0,0,0,1,0,1
c198		t 1,1,0,0,0,1,1,0
c199		t 1,1,0,0,0,1,1,1
c200		t 1,1,0,0,1,0,0,0
c201		t 1,1,0,0,1,0,0,1
c202		t 1,1,0,0,1,0,1,0
c203		t 1,1,0,0,1,0,1,1
c204		t 1,1,0,0,1,1,0,0
c205		t 1,1,0,0,1,1,0,1
c206		t 1,1,0,0,1,1,1,0
c207		t 1,1,0,0,1,1,1,1
c208		t 1,1,0,1,0,0,0,0
c209		t 1,1,0,1,0,0,0,1
c210		t 1,1,0,1,0,0,1,0
c211		t 1,1,0,1,0,0,1,1
c212		t 1,1,0,1,0,1,0,0
c213		t 1,1,0,1,0,1,0,1
c214		t 1,1,0,1,0,1,1,0
c215		t 1,1,0,1,0,1,1,1
c216		t 1,1,0,1,1,0,0,0
c217		t 1,1,0,1,1,0,0,1
c218		t 1,1,0,1,1,0,1,0
c219		t 1,1,0,1,1,0,1,1
c220		t 1,1,0,1,1,1,0,0
c221		t 1,1,0,1,1,1,0,1
c222		t 1,1,0,1,1,1,1,0
c223		t 1,1,0,1,1,1,1,1
c224		t 1,1,1,0,0,0,0,0				
c225		t 1,1,1,0,0,0,0,1
c226 		t 1,1,1,0,0,0,1,0
c227		t 1,1,1,0,0,0,1,1
c228		t 1,1,1,0,0,1,0,0
c229		t 1,1,1,0,0,1,0,1
c230		t 1,1,1,0,0,1,1,0
c231		t 1,1,1,0,0,1,1,1
c232		t 1,1,1,0,1,0,0,0
c233		t 1,1,1,0,1,0,0,1
c234		t 1,1,1,0,1,0,1,0
c235		t 1,1,1,0,1,0,1,1
c236		t 1,1,1,0,1,1,0,0
c237		t 1,1,1,0,1,1,0,1
c238		t 1,1,1,0,1,1,1,0
c239		t 1,1,1,0,1,1,1,1
c240		t 1,1,1,1,0,0,0,0
c241		t 1,1,1,1,0,0,0,1
c242		t 1,1,1,1,0,0,1,0
c243		t 1,1,1,1,0,0,1,1
c244		t 1,1,1,1,0,1,0,0
c245		t 1,1,1,1,0,1,0,1
c246		t 1,1,1,1,0,1,1,0
c247		t 1,1,1,1,0,1,1,1
c248		t 1,1,1,1,1,0,0,0
c249		t 1,1,1,1,1,0,0,1
c250		t 1,1,1,1,1,0,1,0
c251		t 1,1,1,1,1,0,1,1
c252		t 1,1,1,1,1,1,0,0
c253		t 1,1,1,1,1,1,0,1
c254		t 1,1,1,1,1,1,1,0
c255		t 1,1,1,1,1,1,1,1

* Clear the entire screen buffer(about 96k) - 2 screens + bot borders.

cls		MOVE.L log_base,A0
		MOVEQ #0,D0
		MOVE #4999,D1
cls_lp	MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		DBF D1,cls_lp
		RTS

* Setup scroll buffer.

setupbuf	LEA scbuffer,A0
		MOVE.L jmp_tab(PC),D1
		MOVE #(640*4)-1,D0
settab	MOVE.L D1,(A0)+
		DBF D0,settab
		RTS

* Pre-shift tiles

Init_tiles	LEA tiles,A5
		LEA tile1(PC),A6
		MOVE.L A5,A1
		MOVEQ #31,D5
shift_lp	MOVE.L A6,A0
		LEA 496(A0),A2
		MOVEQ #31,D6
cpy_lp	MOVEM.L (A2),D0-D3
		MOVEM.L D0-D3,(A1)
		MOVEM.L D0-D3,512(A1)
		LEA 16(A1),A1
		LEA -16(A2),A2
		DBF D6,cpy_lp
		LEA 1024(A2),A2
		LEA 512(A1),A1
		MOVEQ #31,D6
Sline_lp	MOVEQ #2,D7
pl_lp		LSR (A0)
		ROXR 8(A0)
		CLR D0
		ROXR D0
		OR D0,(A0)+
		DBF D7,pl_lp 
		LEA 10(A0),A0
		DBF D6,Sline_lp
		DBF D5,shift_lp

* Combine two tiles.

combine_two	MOVEQ #31,D7
		LEA tiles,A0
		LEA 512(A0),A2
tile_lp	LEA tile2(PC),A1
		MOVEQ #31,D6
spr1_lp	MOVEQ #1,D4
chn_lp	MOVEM.W (A1)+,D0-D3
		MOVE D0,D5
		OR D1,D5
		OR D2,D5
		NOT D5
		AND D5,(A0)
		OR D0,(A0)+
		AND D5,(A0)
		OR D1,(A0)+
		AND D5,(A0)
		OR D2,(A0)
		AND D5,(A2)
		OR D0,(A2)+
		AND D5,(A2)
		OR D1,(A2)+
		AND D5,(A2)
		OR D2,(A2)
		ADDQ.L #4,A0
		ADDQ.L #4,A2
		DBF D4,chn_lp
		DBF D6,spr1_lp
		LEA 512(A0),A0
		LEA 512(A2),A2
		LEA tile2(PC),A1
		MOVEQ #31,D6
.Sline_lp	MOVEQ #2,D1
.pl_lp	LSR (A1)
		ROXR 8(A1)
		CLR D0
		ROXR D0
		OR D0,(A1)+
		DBF D1,.pl_lp 
		LEA 10(A1),A1
		DBF D6,.Sline_lp
moveup	LEA tile2(PC),A3
		MOVEM.L (A3),D0-D3
		MOVEM.L D0-D3,-(SP)
		MOVEQ #30,D5
moveuplp	MOVEM.L 16(A3),D0-D3
		MOVEM.L D0-D3,(A3)
		LEA 16(A3),A3
		DBF D5,moveuplp
		MOVEM.L (SP)+,D0-D3
		MOVEM.L D0-D3,(A3)
		DBF D7,tile_lp
		RTS

copy_led	MOVE.L log_base,A0
		MOVE.L phy_base,A1
		lea 32000(a0),a0
		lea 32000(a1),a1
		LEA ledblock,A2
		MOVE #(5120/4)-1,D0
cpyb_lp	MOVE.L (A2)+,D1
		MOVE.L D1,(A0)+
		MOVE.L D1,(A1)+
		DBF D0,cpyb_lp
		MOVE.L log_base,A0
		MOVE.L phy_base,A1
		LEA logoblock,A2
		MOVE #(5120/4)-1,D0
cpyba_lp	MOVE.L (A2)+,D1
		MOVE.L D1,(A0)+
		MOVE.L D1,(A1)+
		DBF D0,cpyba_lp
		RTS

* flush the keyboard buffer

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S fldone
		MOVE.B $FFFFFC02.W,D0
		BRA flush
fldone	RTS

clearvert	LEA VERT,A0
		MOVE #(232*2*16)-1,D0
clrvert	CLR.L (A0)+
		DBF D0,clrvert
		RTS

tile1		dc.l	$0000FFE0,$FFE00000,$000107FE,$07FF0000,$C030BFF0 
		dc.l	$FFF00000,$0C030FFD,$0FFF0000,$E018DFF8,$FFF80000 
		dc.l	$18071FFB,$1FFF0000,$700CEFFC,$FFFC0000,$300E3FF7 
		dc.l	$3FFF0000,$3806F7FE,$FFFE0000,$601C7FEF,$7FFF0000 
		dc.l	$1C03FBFF,$FFFF0000,$C038FFDF,$FFFF0000,$0E01FDFF 
		dc.l	$FFFF0000,$8070FFBF,$FFFF0000,$0700FEFF,$FFFF0000 
		dc.l	$00E0FF7F,$FFFF0000,$0380FF7F,$FFFF0000,$01C0FEFF 
		dc.l	$FFFF0000,$01C0FFBF,$FFFF0000,$0380FDFF,$FFFF0000 
		dc.l	$F0E00FDF,$FFFF0000,$073FFBC0,$FFFF0000,$F87007EF 
		dc.l	$FFFF0000,$0E7FF780,$FFFF0000,$1C38E3F7,$FFFF0000 
		dc.l	$1C0CEFF3,$FFFF0000,$0C1CF3FB,$FFFF0000,$380CDFF3 
		dc.l	$FFFF0000,$DC0E23FD,$FFFF0000,$700CBFF3,$FFFF0000 
		dc.l	$F80507FE,$FFFF0000,$A00C7FF3,$FFFF0000,$F0050FFB 
		dc.l	$FFFF0000,$A00CDFF3,$FFFF0000,$F80F07F3,$FFFF0000 
		dc.l	$F00CCFF3,$FFFF0000,$DC1E23E7,$FFFF0000,$780CE7F3 
		dc.l	$FFFF0000,$CE3C31CF,$FFFF0000,$3C0CF3F3,$FFFF0000 
		dc.l	$0778F89F,$FFFF0000,$1E00F9FF,$FFFF0000,$02F0FD3F 
		dc.l	$FFFF0000,$0F00FCFF,$FFFF0000,$01E0FE7F,$FFFF0000 
		dc.l	$0780FE7F,$FFFF0000,$03C0FCFF,$FFFF0000,$03C0FF3F 
		dc.l	$FFFF0000,$0780F9FF,$FFFF0000,$01E0FF9F,$FFFF0000 
		dc.l	$0F01F3FE,$FFFF0000,$80F07FCF,$FFFF0000,$1E03E7FC 
		dc.l	$FFFF0000,$C0783FE7,$FFFF0000,$3C06CFF8,$FFFE0000 
		dc.l	$603C1FF3,$7FFF0000,$780C9FF0,$FFFC0000,$301E0FF9 
		dc.l	$3FFF0000,$F0183FE0,$FFF80000,$180F07FC,$1FFF0000 
		dc.l	$E0307FC0,$FFF00000,$0C0703FE,$0FFF0000,$0020FFC0 
		dc.l	$FFE00000,$040003FF,$07FF0000 
tile2		dc.l	$00040006,$00080000,$0038003C,$00000000,$000C000E 
		dc.l	$00100000,$00380038,$00070000,$001C205E,$C0200000 
		dc.l	$0038003F,$00000000,$4128C53C,$38C00000,$00100018 
		dc.l	$00200000,$05C80DFC,$02000000,$00100018,$00200000 
		dc.l	$034803FC,$00000000,$0018001C,$00200000,$026003FC 
		dc.l	$04000000,$00280038,$00440000,$047007FE,$08000000 
		dc.l	$0044006C,$00820000,$0C320FFF,$10000000,$008200C6 
		dc.l	$01010000,$127F1FFF,$E0000000,$01018183,$02000000 
		dc.l	$E1FDF3FF,$00000000,$8200C301,$04000000,$00ECE1EF 
		dc.l	$00100000,$D400F600,$08000000,$00CC00CF,$00300000 
		dc.l	$E800EC00,$10000000,$00440047,$00B80000,$F000F800 
		dc.l	$00000000,$006F006F,$00900000,$B000B800,$40000000 
		dc.l	$007B007F,$00800000,$20003000,$C0000000,$01F101FF 
		dc.l	$00000000,$A000B000,$40000000,$00E100FF,$01000000 
		dc.l	$E000F800,$00000000,$00D100DF,$01200000,$60006400 
		dc.l	$98000000,$0189018F,$02700000,$38003A00,$C4000000 
		dc.l	$03CA8BCE,$74310000,$3D003DC0,$C2000000,$747C77FC 
		dc.l	$88030000,$1BA01FB1,$E0400000,$8038FCF8,$00070000 
		dc.l	$00680BEE,$F0110000,$00388078,$00070000,$70197879 
		dc.l	$80060000,$00190039,$00060000,$F806F81F,$00000000 
		dc.l	$001B003B,$00040000,$B800F806,$04000000,$000B001B 
		dc.l	$00040000,$0C00BC00,$02000000,$000E001F,$00000000 
		dc.l	$02000E00,$01000000,$000E001F,$00000000,$01000300 
		dc.l	$00800000,$000C001E,$00000000,$00800180,$00400000 
		dc.l	$00040006,$00080000,$004000C0,$00200000,$00040006 
		dc.l	$00080000,$00600060,$00100000 

vbl_timer	DC.W 0
scr_point	DC.L text
pix_pos	DC.W 0
switch	DC.W 0
log_base	DC.L 0
phy_base	DC.L 0
log_base1	DC.L 0
phy_base1	DC.L 0

buf_ptr	DC.L scbuffer
text		
 DC.B "                 WOTS ALL THIS THEN???          IS THIS ALL WE GET???       THIS SCROLLINE IS REALLY BORING.... "
 DCB.B 20,32
 DC.B "w",5,"THATS A LITTLE BIT BETTER... AFTER ALL THIS IS A ONE BIT SCROLLER (NEVER BEFORE ACHIEVED ON AN ST!) LETS STRETCH THINGS A BIT... "
 DCB.B 20,32
 DC.B "w",2,"    THIS SCROLLINE CAN TAKE ALMOST ANY FORM I WANT, SO LET'S CHANGE WAVEFORM AGAIN, PERHAPS TO SOMETHING A BIT ROUNDER.... "
 DCB.B 20,32
 DC.B "w",0," FUCK YOU WILD COPPER!!!  WILD COPPER ARE AN AMIGA CREW WHO SAID THIS COULD NOT BE DONE ON AN ST!!! THEY DID IT AT 25HZ WE DO IT(!) AT 50HZ WITH LOTS OF OTHER STUFF!!! "
 DC.B "  THE CREDITS FOR THE FLEXISCROLL GO TO ME (GRIFF) - CODING AND FONTS AND TO MASTER - BACKGROUND TILES, VU-METER AND LOGO. AS USUAL THE 'FUCKING' ACE MUSIC IS BY COUNT ZERO "
 DC.B "  THE GREETINGS CAN BE FOUND IN THE DISTING SCROLLINE AT THE SIDES... RIGHT NOW I THINK WE SHOULD CHANGE WAVEFORM AGAIN... "
 DCB.B 20,32
 DC.B "w",1," I WOULD CHALLENGE TLB OR TCB TO TRY AND BEAT THIS BUT I KNOW THEY COULDN'T BEAT IT SO I WON'T!!! COMING UP(!) ARE SOME HINTS ABOUT HOW TO ACHEIVE THE HARDWARE OR 'SYNC' SCROLL TECHNIQUE USED IN SEVERAL SCREENS IN THIS DEMO... "
 DCB.B 20,32
 DC.B "w",3," IF YOU CAN READ THIS SCROLLER THEN EITHER YOU ARE CRACKER LOOKING AT THIS TEXT FROM MONST OR YOUR NAME IS ARCHIE(BECAUSE OF THE WAY YOUR FACE IS SHAPED!)... 'SYNC' SCROLL HINT:PISS OFF AND WRITE YOUR OWN LIKE I DID (TLB TAKE NOTE)"
 DC.B "   SERIOUSLY THOUGH THE ST HAS A HIDDEN REGISTER IN THE KEYBOARD CHIP WHICH CAN SHIFT MEMORY ABOUT WITHOUT INVOLVING THE PROCESSOR. THE KEYBOARD CHIP IS ACTUALLY VERY SIMILAR TO THE C64'S CPU. "
 DC.B "TO ACHEIVE SYNC SCROLL YOU WILL NEED A DATA SHEET ON THE KEYBOARD CHIP AND A MC6510 MACHINE CODE MANUAL...   END OF HINT....           "
 DCB.B 20,32
 DC.B "w",0,"    WELL THAT WRAPS UP THIS SCROLLINE ITS TIME TO DO WHAT EVER SCROLLINE IN LIFE HAS TO DO... "         
 DCB.B 20,32
 DC.B "w",3," LOOP....      "
 DCB.B 20,32
 DC.B "    w",4,"  ",0
		EVEN

scr_buf	DS.W 16
fontbuf	dc.l	$00000000,$00000000,$00000000,$00000000,$00000000 
		dc.l	$00000000,$00000000,$00000000,$01000380,$03800380 
		dc.l	$03800380,$03800100,$01000100,$00000000,$01000380 
		dc.l	$01000000,$0C300C30,$0C300C30,$0C300000,$00000000 
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000060 
		dc.l	$0C600C60,$0C780FE0,$3C600C60,$0C780FE0,$3C600C60 
		dc.l	$0C600C00,$00000000,$01000100,$03E00D30,$19301900 
		dc.l	$1D000FC0,$03F00138,$31183118,$11300FE0,$01000100 
		dc.l	$1E023304,$21083310,$1E200040,$00800100,$02000478 
		dc.l	$08CC1084,$20CC4078,$00000000,$03000480,$0C400C40 
		dc.l	$0C800700,$0E1C1B08,$33083190,$31A030C4,$18E40F38 
		dc.l	$00000000,$0C001E00,$0E000600,$0C003800,$00000000 
		dc.l	$00000000,$00000000,$00000000,$00000000,$00180030 
		dc.l	$006000C0,$01800180,$03000300,$03000300,$03000180 
		dc.l	$018000C0,$00600030,$18000C00,$06000300,$01800180 
		dc.l	$00C000C0,$00C000C0,$00C00180,$01800300,$06000C00 
		dc.l	$00000180,$318C1998,$0DB007E0,$03C007E0,$0DB01998 
		dc.l	$318C0180,$00000000,$00000000,$00000180,$01800180 
		dc.l	$01800180,$1FF81FF8,$01800180,$01800180,$01800000 
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000000 
		dc.l	$00000000,$018003C0,$01C000C0,$00C00180,$00000000 
		dc.l	$00000000,$00000000,$1FF01FF0,$00000000,$00000000 
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000000 
		dc.l	$00000000,$00000000,$018003C0,$03C00180,$00000000 
		dc.l	$000C0018,$00180030,$00600060,$00C00180,$01800300 
		dc.l	$06000600,$0C001800,$18003000,$03C00660,$0C300C30 
		dc.l	$18181818,$18181818,$18181818,$0C300C30,$066003C0 
		dc.l	$00000000,$00800180,$0F800180,$01800180,$01800180 
		dc.l	$01800180,$01800180,$01800FF0,$00000000,$07C00860 
		dc.l	$10301030,$1C300C70,$006000C0,$01800300,$06100C10 
		dc.l	$1FF01FF0,$00000000,$03C00460,$0C300C30,$00300060 
		dc.l	$01C00060,$00300030,$18301830,$086007C0,$00000000 
		dc.l	$00200060,$00E00160,$02600460,$08601060,$20603FFC 
		dc.l	$00600060,$006001F8,$00000000,$00100FE0,$0FC00800 
		dc.l	$08000BC0,$0C600030,$00300030,$18301830,$086007C0 
		dc.l	$00000000,$03E00630,$0C300C00,$18001BC0,$1C601830 
		dc.l	$18301830,$18301830,$0C6007C0,$00000000,$1FF01FE0 
		dc.l	$10201040,$10400080,$00800080,$01800180,$01800180 
		dc.l	$01800180,$00000000,$03C00660,$0C300C30,$0E300760 
		dc.l	$03C007E0,$0C701838,$18181818,$0C3007E0,$00000000 
		dc.l	$07C00C60,$18301830,$18301830,$18300C70,$07B00030 
		dc.l	$00601860,$18C00F80,$00000000,$00000000,$00000100 
		dc.l	$03800380,$01000000,$00000000,$01000380,$03800100 
		dc.l	$00000000,$00000000,$00000100,$03800380,$01000000 
		dc.l	$00000000,$01000380,$03800080,$00800100,$00000018 
		dc.l	$00300060,$00C00180,$03000600,$03000180,$00C00060 
		dc.l	$00300018,$00000000,$00000000,$00000000,$1FF01FF0 
		dc.l	$00000000,$00001FF0,$1FF00000,$00000000,$00000000 
		dc.l	$00001800,$0C000600,$03000180,$00C00060,$00C00180 
		dc.l	$03000600,$0C001800,$00000000,$07C00860,$10301C30 
		dc.l	$0C300060,$00C00180,$01000100,$00000000,$03000300 
		dc.l	$00000000 
		dc.l	$07F01C18,$300C30E6,$63666666,$66666666,$666463D8 
		dc.l	$30003000,$1C1807E0,$00000000,$01800180,$02C002C0 
		dc.l	$02C00460,$04600460,$0FF00830,$08301018,$10187C7E 
		dc.l	$00000000,$3FE00C30,$0C180C18,$0C180C30,$0FE00C18 
		dc.l	$0C0C0C0C,$0C0C0C0C,$0C183FF0,$00000000,$03E40C34 
		dc.l	$180C1804,$30043000,$30003000,$30003000,$18081808 
		dc.l	$0C1003E0,$00000000,$3FC00C30,$0C180C18,$0C0C0C0C 
		dc.l	$0C0C0C0C,$0C0C0C0C,$0C180C18,$0C303FC0,$00000000 
		dc.l	$3FF80C18,$0C080C48,$0C400CC0,$0FC00CC0,$0C400C40 
		dc.l	$0C080C08,$0C183FF8,$00000000,$3FF80C18,$0C080C48 
		dc.l	$0C400CC0,$0FC00CC0,$0C400C40,$0C000C00,$0C003F00 
		dc.l	$00000000,$03C80C28,$18181808,$30083000,$300030FC 
		dc.l	$30183018,$18181838,$0C580398,$00080000,$7C7C1830 
		dc.l	$18301830,$18301830,$1FF01830,$18301830,$18301830 
		dc.l	$18307C7C,$00000000,$07E00180,$01800180,$01800180 
		dc.l	$01800180,$01800180,$01800180,$018007E0,$00000000 
		dc.l	$01F80060,$00600060,$00600060,$00600060,$00601860 
		dc.l	$18601060,$08C00780,$00000000,$3F3C0C10,$0C200C20 
		dc.l	$0C400C80,$0CC00DC0,$0E600C60,$0C300C30,$0C183F3C 
		dc.l	$00000000,$3F000C00,$0C000C00,$0C000C00,$0C000C00 
		dc.l	$0C000C08,$0C080C08,$0C183FF8,$00000000,$781E381C 
		dc.l	$3C2C2C2C,$2C2C2E4C,$264C264C,$278C238C,$238C210C 
		dc.l	$210C783E,$00000000,$787C1C10,$1C101610,$16101310 
		dc.l	$13101190,$10D010D0,$10701070,$10307C10,$00000000 
		dc.l	$03C00C30,$18181818,$300C300C,$300C300C,$300C300C 
		dc.l	$18181818,$0C3003C0,$00000000,$3FF00C18,$0C0C0C0C 
		dc.l	$0C0C0C0C,$0C180FF0,$0C000C00,$0C000C00,$0C003F00 
		dc.l	$00000000,$03C00C30,$18181818,$300C300C,$300C300C 
		dc.l	$300C318C,$1A581A58,$0E7003E0,$00640038,$3FE00C30 
		dc.l	$0C180C18,$0C180C18,$0C300FC0,$0C600C30,$0C300C32 
		dc.l	$0C323F1C,$00000000,$03D00C30,$18101810,$1C001F00 
		dc.l	$0FC003F0,$00F81038,$10181818,$143013C0,$00000000 
		dc.l	$3FFC318C,$21842184,$21840180,$01800180,$01800180 
		dc.l	$01800180,$01800FF0,$00000000,$7E7C1810,$18101810 
		dc.l	$18101810,$18101810,$18101810,$18101C10,$0E2007C0 
		dc.l	$00000000,$7E3E1808,$18080C10,$0C100C10,$06200620 
		dc.l	$06200340,$03400380,$01800180,$00000000,$7BEE31C4 
		dc.l	$31C431C4,$19681968,$1A681A68,$1A680C30,$0C300C30 
		dc.l	$0C300C30,$00000000,$7E7C1810,$0C200C20,$06400680 
		dc.l	$03800380,$02C004C0,$08600860,$10307CFC,$00000000 
		dc.l	$3E3C0C10,$0C100620,$06200340,$03400180,$01800180 
		dc.l	$01800180,$018007E0,$00000000,$0FF80C18,$08300860 
		dc.l	$006000C0,$01800180,$03000608,$06080C08,$18181FF8 
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000000 
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000000 
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000000 
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000000 
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000000 
		dc.l	$00000000,$00000000,$00000000,$00000000 

music		INCBIN FLEXSCRL.INC\INTRO.CZI
		EVEN

trig		REPT 2
		dc.l $0000011D,$023B0359,$04760593,$06B007CC,$08E80A03 
		dc.l $0B1D0C36,$0D4E0E65,$0F7B1090,$11A412B6,$13C614D6 
		dc.l $15E316EF,$17F91901,$1A071B0C,$1C0E1D0E,$1E0B1F07 
		dc.l $200020F6,$21EA22DB,$23C924B5,$259E2684,$27662846 
		dc.l $292329FC,$2AD32BA5,$2C752D41,$2E092ECE,$2F8F304D 
		dc.l $310631BC,$326E331C,$33C6346C,$350E35AC,$364636DB 
		dc.l $376C37F9,$38823906,$39853A00,$3A773AE9,$3B563BBF 
		dc.l $3C233C83,$3CDE3D34,$3D853DD1,$3E193E5C,$3E993ED2 
		dc.l $3F073F36,$3F603F85,$3FA63FC1,$3FD83FE9,$3FF63FFD 
		dc.l $40003FFD,$3FF63FE9,$3FD83FC1,$3FA63F85,$3F603F36 
		dc.l $3F073ED2,$3E993E5C,$3E193DD1,$3D853D34,$3CDE3C83 
		dc.l $3C233BBF,$3B563AE9,$3A773A00,$39853906,$388237F9 
		dc.l $376C36DB,$364635AC,$350E346C,$33C6331C,$326E31BC 
		dc.l $3106304D,$2F8F2ECE,$2E092D41,$2C752BA5,$2AD329FC 
		dc.l $29232846,$27662684,$259E24B5,$23C922DB,$21EA20F6 
		dc.l $20001F07,$1E0B1D0E,$1C0E1B0C,$1A071901,$17F916EF 
		dc.l $15E314D6,$13C612B6,$11A41090,$0F7B0E65,$0D4E0C36 
		dc.l $0B1D0A03,$08E807CC,$06B00593,$04760359,$023B011D 
		dc.l $0000FEE3,$FDC5FCA7,$FB8AFA6D,$F950F834,$F718F5FD 
		dc.l $F4E3F3CA,$F2B2F19B,$F085EF70,$EE5CED4A,$EC3AEB2A 
		dc.l $EA1DE911,$E807E6FF,$E5F9E4F4,$E3F2E2F2,$E1F5E0F9 
		dc.l $E001DF0A,$DE16DD25,$DC37DB4B,$DA62D97C,$D89AD7BA 
		dc.l $D6DDD604,$D52DD45B,$D38BD2BF,$D1F7D132,$D071CFB3 
		dc.l $CEFACE44,$CD92CCE4,$CC3ACB94,$CAF2CA54,$C9BAC925 
		dc.l $C894C807,$C77EC6FA,$C67BC600,$C589C517,$C4AAC441 
		dc.l $C3DDC37D,$C322C2CC,$C27BC22F,$C1E7C1A4,$C167C12E 
		dc.l $C0F9C0CA,$C0A0C07B,$C05AC03F,$C028C017,$C00AC003 
		dc.l $C000C003,$C00AC017,$C028C03F,$C05AC07B,$C0A0C0CA 
		dc.l $C0F9C12E,$C167C1A4,$C1E7C22F,$C27BC2CC,$C322C37D 
		dc.l $C3DDC441,$C4AAC517,$C589C600,$C67BC6FA,$C77EC807 
		dc.l $C894C925,$C9BACA54,$CAF2CB94,$CC3ACCE4,$CD92CE44 
		dc.l $CEFACFB3,$D071D132,$D1F7D2BF,$D38BD45B,$D52DD604 
		dc.l $D6DDD7BA,$D89AD97C,$DA62DB4B,$DC37DD25,$DE16DF0A 
		dc.l $E000E0F9,$E1F5E2F2,$E3F2E4F4,$E5F9E6FF,$E807E911 
		dc.l $EA1DEB2A,$EC3AED4A,$EE5CEF70,$F085F19B,$F2B2F3CA 
		dc.l $F4E3F5FD,$F718F834,$F950FA6D,$FB8AFCA7,$FDC5FEE3 
		ENDR
ledblock	INCBIN FLEXSCRL.INC\FLEXBOT1.DAT
logoblock	INCBIN FLEXSCRL.INC\FLEXLOG1.DAT
para_ptr	DC.W 0
parawave	INCBIN FLEXSCRL.INC\PARAWAVE.DAT
vfontbuf	dc.l $00000000,$00000000,$00000000,$00000000,$00000000
		dc.l $00000000,$00000000,$00000000,$07800780,$07800780
		dc.l $07800780,$07800780,$07800300,$00000300,$07800300
		dc.l $00000000,$3CF03EF8,$0E381C70,$30C00000,$00000000
		dc.l $00000000,$00000000,$00000000,$00000000,$00000000
		dc.l $00000CC0,$0CC07FF8,$7FF80CC0,$0CC07FF8,$7FF80CC0
		dc.l $0CC00000,$00000000,$07E00FFC,$1FFE3EFE,$3E7C1F80
		dc.l $0FF007FC,$63FE7FFE,$7FFE7FFE,$7FFC07E0,$00000000
		dc.l $180F3C1E,$663C6678,$3CF019E0,$03C00780,$0F301E78
		dc.l $3CCC78CC,$F078E030,$00000000,$1FC03FE0,$78E07DE0
		dc.l $3FC01F00,$3F8C7BDC,$FBFCFFFC,$FFFC7FFE,$7FFF3FCF
		dc.l $00000000,$3C003E00,$0E001C00,$30000000,$00000000
		dc.l $00000000,$00000000,$00000000,$00000000,$03800780
		dc.l $0F000F00,$1E001C00,$1C001C00,$1C001E00,$0F000F00
		dc.l $07800380,$00000000,$01C001E0,$00F000F0,$00780038
		dc.l $00380038,$00380078,$00F000F0,$01E001C0,$00000000
		dc.l $00000000,$07006730,$77703FE0,$1FC01FC0,$3FE07770
		dc.l $67300700,$00000000,$00000000,$00000000,$00000700
		dc.l $07000700,$3FE03FE0,$07000700,$07000000,$00000000
		dc.l $00000000,$00000000,$00000000,$00000000,$00000000
		dc.l $00000000,$00003C00,$3E000E00,$1C003000,$00000000
		dc.l $00000000,$00000000,$1FC01FC0,$00000000,$00000000
		dc.l $00000000,$00000000,$00000000,$00000000,$00000000
		dc.l $00000000,$00000000,$0C001E00,$1E000C00,$00000000
		dc.l $000F001E,$003C0078,$00F001E0,$03C00780,$0F001E00
		dc.l $3C007800,$F000E000,$00000000,$0FE03FF8,$7C7C783C
		dc.l $783C783C,$783C7BBC,$7FFC7FFC,$3FFC3FF8,$1FF00FE0
		dc.l $00000000,$07800F80,$1F803F80,$07800780,$07800FC0
		dc.l $3FF03FF0,$3FF03FF0,$3FF03FF0,$00000000,$1FE01FF0
		dc.l $3FF03CF0,$1DF003E0,$07E00FC0,$1F8C3FFC,$3FFC3FFC
		dc.l $3FFC39F8,$00000000,$1FF01FF8,$3FF83CF8,$1DF803F0
		dc.l $03F8007C,$38FC3FFC,$3FFC3FF8,$3FF01FE0,$00000000
		dc.l $03F007F0,$0FF01FF0,$3FF03DF0,$79F07FF0,$7FF87FF8
		dc.l $7FF87FF8,$7FF803E0,$00000000,$0FF80FF8,$1F781E00
		dc.l $3FE03FF0,$01F8007C,$30FC3FFC,$3FFC3FF8,$3FF01FE0
		dc.l $00000000,$0FF01FF8,$1F783E00,$3FC07FF0,$7FF87C7C
		dc.l $7CFC7FFC,$7FFC7FF8,$3FF01FE0,$00000000,$1FF81FF8
		dc.l $1E781E78,$00F000F0,$01E003E0,$03C007C0,$0FC01FC0
		dc.l $3FC03FC0,$00000000,$0FF81FFC,$3E3E3F7E,$1FFC07F0
		dc.l $1F7C3E3E,$7F7F7FFF,$7FFF3FFE,$3FFE1FFC,$00000000
		dc.l $07E00FF8,$1E7C1E7E,$1FFE0FDE,$07BE607E,$7FFE7FFE
		dc.l $7FFE7FFC,$3FF81FF0,$00000000,$00000000,$00000000
		dc.l $00000E00,$1F000E00,$00000000,$0E001F00,$0E000000
		dc.l $00000000,$00000000,$00000000,$00000E00,$1F000E00
		dc.l $00001E00,$1F000700,$0E001800,$00000000,$003C0078
		dc.l $00F001E0,$03C00780,$0F000780,$03C001E0,$00F00078
		dc.l $003C001C,$00000000,$00000000,$00000000,$7FE07FE0
		dc.l $00007FE0,$7FE00000,$00000000,$00000000,$00000000
		dc.l $3C001E00,$0F000780,$03C001E0,$00F001E0,$03C00780
		dc.l $0F001E00,$3C003800,$00000000,$3FE07FF8,$78FC7E7C
		dc.l $3EF803F0,$07E007C0,$07E003C0,$000003C0,$07E003C0,$00000000
		dc.l $0FE03FF8,$7C7CF83E,$F3DEF7FE,$F77EF77E,$F7FCFBF0
		dc.l $FC007FFC,$3FFC0FFC,$00000000,$1FFC1FFC,$0F780770
		dc.l $07700FF8,$1F7C3E3E,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F
		dc.l $00000000,$3FFC3FFE,$1F3E0F7E,$0FFE0FF8,$1F7C3E3E
		dc.l $7F7F7FFF,$7FFF7FFF,$7FFE7FFC,$00000000,$07FC1FFE
		dc.l $3F1E3E3E,$7E3C7E00,$7F007F8F,$7FFF3FFF,$3FFF1FFF
		dc.l $0FFE03FC,$00000000,$3FF03FF8,$1F7C0F3E,$0F1F0F1F
		dc.l $1F1F3F1F,$7F3F7FFF,$7FFF7FFF,$7FFE7FFC,$00000000
		dc.l $3FFE3FFE,$1F9E0F00,$0F700FF0,$1F803F0F,$7FBF7FFF
		dc.l $7FFF7FFF,$7FFF7FFF,$00000000,$3FFE3FFE,$1F9E0F00
		dc.l $0F700FF0,$1FC03F00,$7FE07FE0,$7FE07FE0,$7FE07FE0
		dc.l $00000000,$07FC1FFE,$3F1E3E3E,$7E3C7E00,$7E007F0F
		dc.l $7FFF3FFF,$3FFF1FFF,$0FF703E3,$00000000,$3F7E3F7E
		dc.l $1E3C0E38,$0E780FF8,$1F3C3E3E,$7F7F7F7F,$7F7F7F7F
		dc.l $7F7F7F7F,$00000000,$0FC00FC0,$07800780,$07800780
		dc.l $07800FC0,$3FF03FF0,$3FF03FF0,$3FF03FF0,$00000000
		dc.l $03F003F0,$01E001E0,$01E001E0,$01E043E0,$7FE07FE0
		dc.l $7FE07FE0,$7FE03FC0,$00000000,$1F1E1F3E,$0E780EF0
		dc.l $0FE00FF0,$1E783E7C,$7F7F7F7F,$7F7F7F7F,$7F7F7F3F
		dc.l $00000000,$3FC03FC0,$1F800F00,$0F000F00,$1F9E3FFE
		dc.l $7FFE7FFE,$7FFE7FFE,$7FFE7FFE,$00000000,$3E3E3F7E
		dc.l $1FFC0FF8,$0FF80EB8,$1EBC3E3E,$7F7F7F7F,$7F7F7F7F
		dc.l $7F7F7F7F,$00000000,$3C7E3E7E,$1F7C0FF8,$0FF80FF8
		dc.l $1F3C3F1E,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$00000000
		dc.l $0FE03FF8,$7C7CF83E,$F83EF83E,$F83EFBBE,$FFFEFFFE
		dc.l $7FFC3FF8,$1FF00FE0,$00000000,$3FFC3FFE,$1F3E0F7E
		dc.l $0FFE0FFC,$1F803F80,$7FC07FE0,$7FE07FE0,$7FE07FE0
		dc.l $00000000,$0FE03FF8,$7C7CF83E,$F83EF83E,$F83EFBBE
		dc.l $FFFEFFFE,$7FFC3FF8,$1FF00FE0,$039803F8,$3FF83FFE
		dc.l $1F3E0F7C,$0FF80FF8,$1F3C3F1E,$7F7F7F7F,$7F7F7F7F
		dc.l $7F7F7F7F,$00000000,$0FF81FFE,$1F7E0F3C,$0FC007F0
		dc.l $01FC21FE,$7FFF7FFF,$7FFF7FFF,$7FFE7FFC,$00000000
		dc.l $3FF03FF0,$3FF037B0,$07800780,$07800FC0,$3FF03FF0
		dc.l $3FF03FF0,$3FF03FF0,$00000000,$3F7E3F7E,$1E3C1E3C
		dc.l $1E3C1E3C,$3E3C3F7E,$7FFF7FFF,$7FFF7FFF,$3FFF1FDE 
		dc.l $00000000,$3F7E3F7E,$1E3C1C1C,$1E3C1F7C,$3FFE3FFE 
		dc.l $1FFC0FF8,$0FF807F0,$07F003E0,$00000000,$FBDFFBDF 
		dc.l $FBDE79CE,$79CE7BDE,$7FFE7FFF,$FFFFFFFF,$FFFFFFFF 
		dc.l $7FFF3BDE,$00000000,$3F7E3F7E,$1E3C0F78,$07F007F0 
		dc.l $1F7C3E3E,$7F7F7F7F,$7F7F7F7F,$7F7F7F7F,$00000000 
		dc.l $3F7E3F7E,$1E3C0F78,$07F007F0,$0FE07FE0,$7FE07FE0 
		dc.l $7FE07FE0,$7FC07F80,$00000000,$3FF03FF0,$3FF038F0 
		dc.l $01F003E0,$07E00FCE,$1FBE3FFE,$3FFE3FFE,$3FFE3FFE 
		dc.l $00000000,$00000000,$00000000,$00000000,$00000000 
		dc.l $00000000,$00000000,$00000000,$00000000 

		EVEN
		SECTION BSS
old_mfp	DS.L 6
old_vbl	DS.L 1
		DS.L 299
my_stack	DS.L 1
VERT		ds.l 2
vscrbuf1	ds.l 231*2
vertbufs	rept 15
		ds.l 231*2
		endr
		ds.l 200
		
tiles		DS.L 16*512
scbuffer	DS.L 640*4
endscbuf	
screens	DS.B 256
		DS.B 42240
		DS.B 42240
		EVEN
table		

