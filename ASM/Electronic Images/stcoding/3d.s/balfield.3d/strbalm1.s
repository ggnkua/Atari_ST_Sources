;-----------------------------------------------------------------------;
; 3d Space field using sprites(balls etc),				;
; Coded after seeing the Red sector Cebit'90 starfield demo!!!!		;
; (C) April 1991 Martin Griffiths. (Griff of The Inner Circle).		;
; This routine uses 'intelligent' sprite routines so that a minimum	;
; amount of masking is done and unused lines are NOT drawn to screen!	;
; Please NOTE this is not a lame perspective changing starfield!!!!	;
; Each Star(ball) is rotated about x,y,z and uses MULS perspective	;
;-----------------------------------------------------------------------;

; Up to 70 balls but 65 since music and fades(so it doesn't go over frame)

no_balls	EQU 65			

letsgo		CLR -(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14			; low res
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1				; super visor
		ADDQ.L #6,SP

		MOVE #$2700,SR
		LEA stack,SP
		LEA $FFFF8240.W,A0
		MOVEM.L (A0),D0-D7
		MOVEM.L D0-D7,old_cols
		REPT 8
		CLR.L (A0)+
		ENDR
		BSR Initscreens
		BSR InitBall_field
		BSR set_ints
		MOVE.B #$12,$FFFFFC02.W
		MOVEM.L ballpal1(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		MOVE #$2300,SR

* This is the main program loop

Star_frame	
;		MOVE.W #$700,$FFFF8240.W
		MOVE vbl_timer(PC),D0
wait_vbl	CMP vbl_timer(PC),D0		; wait vbl
		BEQ.S wait_vbl
;		MOVE.W #$000,$FFFF8240.W
		LEA log_base(PC),A0
		MOVE.L (A0)+,D0
		MOVE.L (A0)+,D1
		NOT.W (A0)			; switch screens
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR #8,D1
		MOVE.L D1,$FFFF8200.W		; set hardware...

		BSR clear_balls
		BSR BMatrix_make
		BSR Trans_balls
		BSR Plot_em

 		CMP.B #$39+$80,$FFFFFC02.W	; space to exit...
		BNE Star_frame		

Exit		MOVE #$2700,SR
		BSR rest_ints
		MOVE.B #$8,$FFFFFC02.W
		MOVEM.L old_cols(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		MOVE #$2300,SR
		CLR -(SP)			; bye for now...
		TRAP #1			

; My little vbl interrupt.

my_vbl		ADDQ #1,vbl_timer
		RTE

ballpal1	dc.w	$000,$100,$200,$310,$420,$531,$642,$764
		dc.w	$700,$700,$700,$700,$700,$700,$700,$700

; Initialisation and restore interrupt routs.

set_ints	move #$2700,sr
		lea old_stuff(pc),a0
		move.l $70.w,(a0)+
		lea my_vbl(pc),a1
		move.l a1,$70.w
		lea $fffffa00.w,a1
		movep.w 7(a1),d0
		move.w d0,(a0)+
		movep.w 13(a1),d0
		move.w d0,(a0)+
		moveq #0,d0
		movep.w d0,7(a1)
		movep.w d0,13(a1)
		move #$2300,sr
		bsr flush
		rts

rest_ints	move #$2700,sr
		lea old_stuff(pc),a0
		move.l (a0)+,$70.w
		lea $fffffa00.w,a1
		move.w (a0)+,d0
		movep.w d0,7(a1)
		move.w (a0)+,d0
		movep.w d0,13(a1)
		bsr flush
		move #$2300,sr
		rts

; Flush keyboard Buffer

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S .flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
.flok		RTS

old_stuff	ds.l 10
old_cols	ds.w 16
log_base 	DC.L 0
phy_base 	DC.L 0
switch		DS.W 1
vbl_timer	DS.W 1

; Allocate space for screens and clear them + make standard *160 table.

Initscreens	lea log_base(pc),a1
		move.l #screens+256,d0
		clr.b d0
		move.l d0,(a1)+
		add.l #42240,d0
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
		move #1999,d1
.cls		move.l d0,(a0)+
		move.l d0,(a0)+
		move.l d0,(a0)+
		move.l d0,(a0)+
		dbf d1,.cls
		rts

;------------------------------------------------------------------------;


; Calculate a translation matrix (and do rotation sequence!)
; D0-D7/A0-A6 smashed. (which basically means all of them!)

BMatrix_make	LEA ballseqdata(PC),A3
		SUBQ #1,seq_timer(A3)
		BNE.S .nonew
		MOVE.L seq_ptr(A3),A1
		TST (A1)
		BPL.S .notendseq
		MOVE.L restart_ptr(A3),A1 
.notendseq	MOVE.W (A1)+,seq_timer(A3)
		MOVE.W (A1)+,addangx(A3)
		MOVE.W (A1)+,addangy(A3)
		MOVE.W (A1)+,addangz(A3)	; store new incs..
		MOVE.W (A1)+,zspeed+2
		MOVE.L A1,seq_ptr(A3)
.nonew		LEA angles(pc),a5
		LEA trig_tab,A0			; sine table
		LEA 512(A0),A2			; cosine table
		MOVEM.W (A5),D5-D7    		; get current x,y,z ang	
		ADD addangx(A3),D5
		ADD addangy(A3),D6		; add increments
		ADD addangz(A3),D7
		AND #$7FE,D5
		AND #$7FE,D6
		AND #$7FE,D7
		MOVEM.W D5-D7,(A5)   	
		MOVE (A0,D5),D0			sin(xd)
		MOVE (A2,D5),D1			cos(xd)
		MOVE (A0,D6),D2			sin(yd)
		MOVE (A2,D6),D3			cos(yd)
		MOVE (A0,D7),D4			sin(zd)
		MOVE (A2,D7),D5			cos(zd)
		LEA BM11+2(PC),A1
* sinz*sinx(used twice) - A3
		MOVE D0,D6			sinx
		MULS D4,D6			sinz*sinx
		ADD.L D6,D6
		SWAP D6
		MOVE D6,A3
* sinz*cosx(used twice) - A4
		MOVE D1,D6			cosx
		MULS D4,D6			sinz*cosx
		ADD.L D6,D6
		SWAP D6
		MOVE D6,A4
* Matrix(1,1) cosy*cosx-siny*sinz*sinx
		MOVE D3,D6			cosy
		MULS D1,D6			cosy*cosx
		MOVE A3,D7			sinz*sinx
		MULS D2,D7			siny*sinz*sinx					
		SUB.L D7,D6
		ADD.L D6,D6
		SWAP D6			
		MOVE D6,(A1)
* Matrix(2,1) siny*cosx+cosy*sinz*sinx 
		MOVE D2,D6
		MULS D1,D6			siny*cosx
		MOVE A3,D7			sinz*sinx
		MULS D3,D7			cosy*sinz*sinx			
		ADD.L D7,D6
		ADD.L D6,D6
		SWAP D6			
		MOVE D6,BM21-BM11(A1)
* Matrix(3,1) -cosz*sinx
		MOVE D5,D6			cosz
		MULS D0,D6			cosz*sinx
		ADD.L D6,D6
		SWAP D6
		NEG D6				-cosz*sinx
		MOVE D6,BM31-BM11(A1)
* Matrix(1,2) -siny*cosz
		MOVE D2,D6			siny
		MULS D5,D6			siny*cosz
		ADD.L D6,D6
		SWAP D6
		NEG D6				-siny*cosz
		MOVE D6,BM12-BM11(A1)
* Matrix(2,2) cosy*cosz		
		MOVE D3,D6			cosy
		MULS D5,D6			cosy*cosz
		ADD.L D6,D6
		SWAP D6
		MOVE D6,BM22-BM11(A1)
* Matrix(3,2) sinz 
		MOVE D4,BM32-BM11(A1)
* Matrix(1,3) cosy*sinx+siny*sinz*cosx
		MOVE D3,D6			cosy
		MULS D0,D6			cosy*sinx
		MOVE A4,D7			sinz*cosx
		MULS D2,D7
		ADD.L D7,D6
		ADD.L D6,D6
		SWAP D6				siny*(sinz*cosx)
		MOVE D6,BM13-BM11(A1)
* Matrix(2,3) siny*sinx-cosy*sinz*cosx
		MULS D0,D2			siny*sinx
		MOVE A4,D7
		MULS D3,D7
		SUB.L D7,D2 
		ADD.L D2,D2
		SWAP D2
		MOVE D2,BM23-BM11(A1)
* Matrix(3,3) cosz*cosx
		MULS D1,D5 
		ADD.L D5,D5
		SWAP D5				cosz*cosx
		MOVE D5,BM33-BM11(A1)
		RTS				

; Sequence data for ball starfield
		
		RSRESET

seq_timer	RS.W 1
seq_ptr		RS.L 1
addangx		RS.W 1
addangy		RS.W 1
addangz		RS.W 1
restart_ptr	RS.L 1

ballseqdata	DC.W 1
		DC.L ballsequence 
		DS.W 3
		DC.L restart

ballsequence	DC.W 1,0,6,0,50
restart		DC.W 100,0,6,0,50
		DC.W 100,6,0,0,50
		DC.W 100,0,0,6,50
		DC.W 50,2,2,4,58
		DC.W 50,4,4,2,54
		DC.W 50,6,6,0,50
		DC.W 50,8,4,0,54
		DC.W 50,6,2,0,58
		DC.W 50,6,0,0,50
		DC.W -1
angles		DC.W 0,0,0

; Rout to translate my lovely balls!!

Trans_balls	LEA balls_pos,A1		; co-ords
zspeed		MOVE.W #20,A0			; z speed
		MOVE.W #160,A2			; x centre
		MOVE.W #108,A3			; y centre
		LEA translated+(no_balls*6),A4   ; translated storage
		MOVE #1023,A5			; max Z
		MOVE #-1024,A6
		MOVEQ #no_balls-1,D7		; no. of stars
star_lp		MOVE.W (A1)+,D0			; get x
		MOVE.W (A1)+,D1			; get y
		MOVE.W (A1),D2			; get z
		SUB A0,D2			; move thru z
		CMP A6,D2			; is object off z plane?
		BMI Star_off			; yes then reset it
cont1		MOVE D2,(A1)+			; otherwise store...
		MOVE D0,D3			
		MOVE D1,D4			; dup
		MOVE D2,D5
* Calculate x co-ordinate		
BM11		MULS #0,D0			
BM21		MULS #0,D4			; mat mult
BM31		MULS #0,D5
		ADD.L D4,D0
		ADD.L D5,D0			; x
		MOVE D3,D6
		MOVE D1,D4
		MOVE D2,D5
* Calculate y co-ordinate		
BM12		MULS #0,D3
BM22		MULS #0,D1			; mat mult
BM32		MULS #0,D5
		ADD.L D3,D1
		ADD.L D5,D1			; y
* Calculate z co-ordinate
BM13		MULS #0,D6
BM23		MULS #0,D4			; mat mult
BM33		MULS #0,D2
		ADD.L D6,D2
		ADD.L D4,D2			; z
		ADD.L D0,D0
		ADD.L D1,D1
		SWAP D0
		SWAP D1
		SWAP D2
		ADD #512,D2			; z+160
		CMP A5,D2
		BCC offz
		ADD.W D2,D2
		MOVE.W perstab(PC,D2),D3
		MULS D3,D0
		MULS D3,D1
		SWAP D0
		SWAP D1
		ADD A2,D0			; x+xcentre
		ADD A3,D1			; y+ycentre
		MOVEM.W D0-D2,-(A4)
		DBF D7,star_lp			
		RTS
perstab		DS.W $400

offz		MOVEQ #-20,D1
		MOVEM.W D0-D2,-(A4) ; z<=0 then do not draw!! 	
		DBF D7,star_lp			
		RTS
			
; Random number generator (not particular random!!!)

; Star went off Z plane so generate new random star x/y

Star_off	ADD #2048,D2			; reset z
		ADD D4,D0		
		ADD.W #$573,D0
		MULU #$45F7,D0			; RAND X
		ROR.W #6,D0
		SWAP D0
		CLR.W D0
		SWAP D0
		DIVU #1400,D0
		SWAP D0
		SUB #700,D0
		ADD D3,D1			
		ADD.W #$573,D1
		MULU #$45F7,D1			; RAND Y
		ROR.W #6,D1
		SWAP D1
		CLR.W D1
		SWAP D1
		AND #1023,D1
		SUB #512,D1 
		MOVEM.W D0-D1,-4(A1)		; store new rand x
		BRA cont1

; Random number generator for initial ball positions...

BRandom_gen	LEA balls_pos,A3
		MOVE #no_balls-1,D4
.f_rand_x	BSR BRand
		DIVU #1400,D0
		SWAP D0
		SUB #700,D0
		BEQ.S .f_rand_x
		MOVE D0,(A3)+
.f_rand_y	BSR BRand
		AND #1023,D0
		SUB #512,D0
		BEQ.S .f_rand_y
		MOVE D0,(A3)+
		BSR BRand
		AND #$7FF,D0
		SUB #$400,D0
		MOVE D0,(A3)+
		DBF D4,.f_rand_x
		RTS

BRand		ADD D4,D0
		ADD.W #$573,D0
		MULU #$45F7,D0
		ROR.W #6,D0
		SWAP D0
		CLR.W D0
		SWAP D0
		RTS

; Plot the balls to the screen

Plot_em		LEA bold_pos1+2,A3		; assume case 1
		TST switch
		BNE.S .case_1
.case_2		LEA bold_pos2+2,A3		; no its case 2!
.case_1		LEA blmul_160,A1
		LEA translated,A4		; translated co-ords
		LEA ballxlookup,A5
		LEA ballzlookup,A6		; z lookup(ball size)
		MOVE.L log_base(pc),d3
		MOVE.W #319-16,D4		; clip x
		MOVE.W #215,D5			; clip y
		MOVE.L #sprroutptrs,D6
		PEA (A3)
		MOVE.W #no_balls-1,D7
.plot_lp	MOVEM.W (A4)+,D0-D2
		CMP D5,D1			; clip y
		BCC .noplot
		CMP D4,D0			; clip x
		BCC .noplot
		MOVE.L D3,A2			; screen base in A2
		ADD D0,D0
		ADD D0,D0			; x*4
		MOVE.L (A5,D0),D0
		ADD D1,D1			
		ADD.W (A1,D1),D0		; add screen line
		ADD.W D0,A2
		MOVE.W D0,(A3)+			; store screen offset
		SWAP D0
		MOVE.W (A6,D2),D2		; add z buf ptr.(sprite size) 
		ADD.W D2,D0
		MOVE.W D2,(A3)+			; store size(0-7)*64
		MOVE.L D6,A0
		MOVE.L (A0,D0),A0
		JSR (A0)
.noplot		DBF D7,.plot_lp
		MOVE.L (SP)+,A0
		SUB.L A0,A3
		MOVE.W A3,D0
		LSR #2,D0
		MOVE.W D0,-2(A0)		; store no. of sprites
		RTS

; Rout to clear the balls/ stars whatever...

clear_balls	MOVE.L log_base(PC),A0
		LEA bold_pos1,A2		; assume case 1
		TST switch
		BNE.S .case_1
.case_2		LEA bold_pos2,A2		; no its case 2!
.case_1		MOVE.W (A2)+,D7			; no of sprites to clear!
		SUBQ #1,D7
		BMI .out 
		MOVEQ #0,D0
		MOVEQ #0,D1
		MOVEQ #0,D2
		MOVEQ #0,D3
.starclear	MOVE.L A0,A1
		ADD.W (A2)+,A1
		MOVE.W (A2)+,D4
		ADD.W D4,D4
		JMP .jmpclear(PC,D4)
.jmpclear	MOVEM.L D0-D3,(A1)
		MOVEM.L D0-D3,160(A1)
		MOVEM.L D0-D3,320(A1)
		MOVEM.L D0-D3,480(A1)
		MOVEM.L D0-D3,640(A1)
		MOVEM.L D0-D3,800(A1)
		MOVEM.L D0-D3,960(A1)
		MOVEM.L D0-D3,1120(A1)
		MOVEM.L D0-D3,1280(A1)
		MOVEM.L D0-D3,1440(A1)
		MOVEM.L D0-D3,1600(A1)
		MOVEM.L D0-D3,1760(A1)
		MOVEM.L D0-D3,1920(A1)
		MOVEM.L D0-D3,2080(A1)
		MOVEM.L D0-D3,2240(A1)
		MOVEM.L D0-D3,2400(A1)
		DBF D7,.starclear
		RTS
		DS.W 64-(3*15)-2-3

		MOVEM.L D0-D3,160(A1)
		MOVEM.L D0-D3,320(A1)
		MOVEM.L D0-D3,480(A1)
		MOVEM.L D0-D3,640(A1)
		MOVEM.L D0-D3,800(A1)
		MOVEM.L D0-D3,960(A1)
		MOVEM.L D0-D3,1120(A1)
		MOVEM.L D0-D3,1280(A1)
		MOVEM.L D0-D3,1440(A1)
		MOVEM.L D0-D3,1600(A1)
		MOVEM.L D0-D3,1760(A1)
		MOVEM.L D0-D3,1920(A1)
		MOVEM.L D0-D3,2080(A1)
		MOVEM.L D0-D3,2240(A1)
		DBF D7,.starclear
		RTS
		DS.W 64-(3*14)-3

		MOVEM.L D0-D3,320(A1)
		MOVEM.L D0-D3,480(A1)
		MOVEM.L D0-D3,640(A1)
		MOVEM.L D0-D3,800(A1)
		MOVEM.L D0-D3,960(A1)
		MOVEM.L D0-D3,1120(A1)
		MOVEM.L D0-D3,1280(A1)
		MOVEM.L D0-D3,1440(A1)
		MOVEM.L D0-D3,1600(A1)
		MOVEM.L D0-D3,1760(A1)
		MOVEM.L D0-D3,1920(A1)
		MOVEM.L D0-D3,2080(A1)
		DBF D7,.starclear
		RTS
		DS.W 64-(3*12)-3

		MOVEM.L D0-D3,480(A1)
		MOVEM.L D0-D3,640(A1)
		MOVEM.L D0-D3,800(A1)
		MOVEM.L D0-D3,960(A1)
		MOVEM.L D0-D3,1120(A1)
		MOVEM.L D0-D3,1280(A1)
		MOVEM.L D0-D3,1440(A1)
		MOVEM.L D0-D3,1600(A1)
		MOVEM.L D0-D3,1760(A1)
		MOVEM.L D0-D3,1920(A1)
		DBF D7,.starclear
		RTS
		DS.W 64-(3*10)-3

		MOVEM.L D0-D3,640(A1)
		MOVEM.L D0-D3,800(A1)
		MOVEM.L D0-D3,960(A1)
		MOVEM.L D0-D3,1120(A1)
		MOVEM.L D0-D3,1280(A1)
		MOVEM.L D0-D3,1440(A1)
		MOVEM.L D0-D3,1600(A1)
		MOVEM.L D0-D3,1760(A1)
		DBF D7,.starclear
		RTS
		DS.W 64-(3*8)-3

		MOVEM.L D0-D3,800(A1)
		MOVEM.L D0-D3,960(A1)
		MOVEM.L D0-D3,1120(A1)
		MOVEM.L D0-D3,1280(A1)
		MOVEM.L D0-D3,1440(A1)
		MOVEM.L D0-D3,1600(A1)
		DBF D7,.starclear
		RTS
		DS.W 64-(3*6)-3

		MOVEM.L D0-D3,960(A1)
		MOVEM.L D0-D3,1120(A1)
		MOVEM.L D0-D3,1280(A1)
		MOVEM.L D0-D3,1440(A1)
		DBF D7,.starclear
		RTS
		DS.W 64-(3*4)-3

		MOVEM.L D0-D3,1120(A1)
		MOVEM.L D0-D3,1280(A1)
		DBF D7,.starclear
		RTS
		DS.W 64-(3*2)-3
.out		RTS

; Initialise 'ball' starfield...
; - Preshift sprites using the 'intelligent' shifting rout.
; - make up the perspective table. (for muls perspective).
; - Generate the initial random sprite positions(x,y,z).
; - Generate the *160 table + 32 extra words for vert clipping.

InitBall_field	BSR Makeballrouts
		BSR makeperstab
		BSR BRandom_gen
		BSR makezlookup
		BSR makexlookup
		BSR make160table
		CLR.W bold_pos1
		CLR.W bold_pos2
		RTS

; Create *160 starfield

make160table	LEA blmul_160,a0			; create *160 lookup
		MOVE #-16*160,d0
		MOVE #215,d1
.m160lp		MOVE.w d0,(a0)+
		ADD #160,d0
		DBF D1,.m160lp
		RTS

; Rout to create the sprite routines (calls below rout)

makeperstab	LEA perstab(PC),A0
		MOVEQ #0,D0
		MOVE.L #32767*500,D7
.mplp		MOVE.W D0,D1
		MOVE.L D7,D6
		ADD #500,D1
		DIVS D1,D6
		MOVE.W D6,(A0)+
		ADDQ #1,D0
		CMP #$400,D0
		BNE.S .mplp
		RTS

; Create x lookup e.g for each 320 pixels (x and 15)*4 .W / chunk offset.

makexlookup	LEA ballxlookup,A0
		MOVEQ #0,D1
		MOVEQ #19,D0
.mkexlp1	MOVEQ #0,D3
		MOVEQ #15,D2
.mkexlp2	MOVE.W D3,(A0)+
		MOVE.W D1,(A0)+
		ADDQ #4,D3
		DBF D2,.mkexlp2
		ADDQ #8,D1
		DBF D0,.mkexlp1
		RTS

; Z lookup 128 words 0*64,1*64 to 7*64(for 8 sprite sizes)

makezlookup	LEA ballzlookup,A0
		MOVEQ #0,D2
		MOVEQ #7,D0
.makez1lp	MOVEQ #127,D1
.makez2lp	MOVE.W D2,(A0)+
		DBF D1,.makez2lp
		ADD #64,D2
		DBF D0,.makez1lp		
		RTS

; Create optimised sprite routs for each size sprite in field.

Makeballrouts	LEA ball16,A0
		LEA shiftedball,A1
		LEA sprroutptrs,A6
		MOVEQ #7,D0
.lp		MOVE.L A0,Sprite_addr
		MOVEM.L D0/A0,-(SP)
		BSR Shift_sprite
		MOVEM.L (SP)+,D0/A0
		LEA 8*16(A0),A0
		DBF D0,.lp
		RTS

; Routine to shift a 4 plane sprite A1 -> to buffer for shifted sprite.
; Creates routine which is intelligently constructed.
; I reckon the code this now produces is about as optimum as possible!! 

Shift_sprite	MOVEA.L	Sprite_addr(PC),A2
		LEA tempdatabuf(PC),A0
		MOVEQ #0,D0
		MOVEQ #16-1,D1
.moveto		MOVE.L (A2)+,(A0)+ 
		MOVE.L (A2)+,(A0)+ 
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		DBF D1,.moveto
		MOVEQ #15,D0
Spr_Shift_lp	MOVE.W D0,-(SP)
		LEA tempdatabuf(PC),A2
		MOVE.L A1,(A6)+
		MOVEQ #16-1,D6
		CLR D0
init_mask	MOVEQ #1,D7
.lp		MOVEM.L	(A2)+,D1-D2
		MOVE.L D1,D3		
		OR.L D2,D3		; 1+3/2+4
		MOVE.W D3,D5
		SWAP D3
		OR.W D3,D5 		; d5 has mask
		BNE.S .tisdata		; if not 0 we have sprite data
		ADDQ #8,D0		; otherwise skip chunk
		BRA .nextline
.tisdata	TST D0			; we have sprite data
		BEQ.S .noskip 					
		CMP #8,D0
		BNE.S .notquicky
		MOVE.W daddq8(PC),(A1)+
		BRA.S .reset
.notquicky	MOVE.W dlea(PC),(A1)+	; so if need be advance 
		MOVE.W D0,(A1)+		; scr ptr from previous
.reset		CLR D0			; misses and reset
.noskip		NOT.W D5
		BNE.S .needsmask	; zero mask do with 'moves'
		MOVE.W dmove2(PC),(A1)+
		MOVE.L D1,(A1)+
		MOVE.W dmove2(PC),(A1)+
		MOVE.L D2,(A1)+
		BRA .nextline
; Needs to be masksed
.needsmask	MOVE.W dmove1(PC),(A1)+ ;MOVE.L #$12345678,D0
		MOVE.W D5,(A1)+
		MOVE.W D5,(A1)+
.planes12	TST.L D1
		BNE.S .yespl12
		MOVE.W dand2(PC),(A1)+  ;AND.L D0,(A2)+
		BRA.S .planes34
.yespl12	CMP.L #127,D1
		BPL.S .norm12
		CMP.L #-128,D1
		BMI.S .norm12
		AND #$00FF,D1
		OR #$7200,D1		;MOVEQ #XX,D0
		MOVE.W dand1(PC),(A1)+  ;AND.L D0,(A2)
		MOVE.W D1,(A1)+
		MOVE.W dor1(PC),(A1)+
		BRA.S .planes34
.norm12		MOVE.W dand1(PC),(A1)+  ;AND.L D0,(A2)
		MOVE.W dor(PC),(A1)+	;OR.L #$12345678,(A2)+
		MOVE.L D1,(A1)+
.planes34	TST.L D2
		BNE.S .yespl34
		MOVE.W dand2(PC),(A1)+  ;AND.L D0,(A2)+
		BRA.S .nextline
.yespl34	CMP.L #127,D2
		BPL.S .norm34
		CMP.L #-128,D2
		BMI.S .norm34
		AND #$00FF,D2
		OR #$7200,D2		;MOVEQ #XX,D0
		MOVE.W dand1(PC),(A1)+  ;AND.L D0,(A2)
		MOVE.W D2,(A1)+
		MOVE.W dor1(PC),(A1)+
		BRA.S .nextline
.norm34		MOVE.W dand1(PC),(A1)+  ;AND.L D0,(A2)
		MOVE.W dor(PC),(A1)+	;OR.L #$12345678,(A2)+
		MOVE.L D2,(A1)+
.nextline	DBF D7,.lp
		ADD #160-16,D0
		DBF D6,init_mask
		MOVE drts(PC),(A1)+
		LEA tempdatabuf(PC),A0
		MOVEQ #16-1,D1
shiftit		REPT 4
		LSR (A0)+
		ROXR 6(A0)
		ENDR
		LEA 8(A0),A0
		DBF D1,shiftit
		MOVE.W (SP)+,D0
		DBF D0,Spr_Shift_lp
		RTS

dmove1		MOVE.L #$12345678,D0
dmove2		MOVE.L #$12345678,(A2)+
dand1		AND.L D0,(A2)
dand2		AND.L D0,(A2)+
dor		OR.L #$12345678,(A2)+
dor1		OR.L D1,(A2)+
dlea		LEA 4(A2),A2
daddq4		ADDQ.W #4,A2
daddq8		ADDQ.W #8,A2
drts		RTS

Sprite_addr	DC.L 0
tempdatabuf	DS.W 128

ball16		incbin balls16.spr

;------------------------------------------------------------------------;

trig_tab	dc.w	$0000,$00C9,$0192,$025B,$0324,$03ED,$04B6,$057E 
		dc.w	$0647,$0710,$07D9,$08A1,$096A,$0A32,$0AFB,$0BC3 
		dc.w	$0C8B,$0D53,$0E1B,$0EE3,$0FAB,$1072,$1139,$1200 
		dc.w	$12C7,$138E,$1455,$151B,$15E1,$16A7,$176D,$1833 
		dc.w	$18F8,$19BD,$1A82,$1B46,$1C0B,$1CCF,$1D93,$1E56 
		dc.w	$1F19,$1FDC,$209F,$2161,$2223,$22E4,$23A6,$2467 
		dc.w	$2527,$25E7,$26A7,$2767,$2826,$28E5,$29A3,$2A61 
		dc.w	$2B1E,$2BDB,$2C98,$2D54,$2E10,$2ECC,$2F86,$3041 
		dc.w	$30FB,$31B4,$326D,$3326,$33DE,$3496,$354D,$3603 
		dc.w	$36B9,$376F,$3824,$38D8,$398C,$3A3F,$3AF2,$3BA4 
		dc.w	$3C56,$3D07,$3DB7,$3E67,$3F16,$3FC5,$4073,$4120 
		dc.w	$41CD,$4279,$4325,$43D0,$447A,$4523,$45CC,$4674 
		dc.w	$471C,$47C3,$4869,$490E,$49B3,$4A57,$4AFA,$4B9D 
		dc.w	$4C3F,$4CE0,$4D80,$4E20,$4EBF,$4F5D,$4FFA,$5097 
		dc.w	$5133,$51CE,$5268,$5301,$539A,$5432,$54C9,$555F 
		dc.w	$55F4,$5689,$571D,$57B0,$5842,$58D3,$5963,$59F3 
		dc.w	$5A81,$5B0F,$5B9C,$5C28,$5CB3,$5D3D,$5DC6,$5E4F 
		dc.w	$5ED6,$5F5D,$5FE2,$6067,$60EB,$616E,$61F0,$6271 
		dc.w	$62F1,$6370,$63EE,$646B,$64E7,$6562,$65DD,$6656 
		dc.w	$66CE,$6745,$67BC,$6831,$68A5,$6919,$698B,$69FC 
		dc.w	$6A6C,$6ADB,$6B4A,$6BB7,$6C23,$6C8E,$6CF8,$6D61 
		dc.w	$6DC9,$6E30,$6E95,$6EFA,$6F5E,$6FC0,$7022,$7082 
		dc.w	$70E1,$7140,$719D,$71F9,$7254,$72AE,$7306,$735E 
		dc.w	$73B5,$740A,$745E,$74B1,$7503,$7554,$75A4,$75F3 
		dc.w	$7640,$768D,$76D8,$7722,$776B,$77B3,$77F9,$783F 
		dc.w	$7883,$78C6,$7908,$7949,$7989,$79C7,$7A04,$7A41 
		dc.w	$7A7C,$7AB5,$7AEE,$7B25,$7B5C,$7B91,$7BC4,$7BF7 
		dc.w	$7C29,$7C59,$7C88,$7CB6,$7CE2,$7D0E,$7D38,$7D61 
		dc.w	$7D89,$7DB0,$7DD5,$7DF9,$7E1C,$7E3E,$7E5E,$7E7E 
		dc.w	$7E9C,$7EB9,$7ED4,$7EEF,$7F08,$7F20,$7F37,$7F4C 
		dc.w	$7F61,$7F74,$7F86,$7F96,$7FA6,$7FB4,$7FC1,$7FCD 
		dc.w	$7FD7,$7FE0,$7FE8,$7FEF,$7FF5,$7FF9,$7FFC,$7FFE 
		dc.w	$7FFF,$7FFE,$7FFC,$7FF9,$7FF5,$7FEF,$7FE8,$7FE0 
		dc.w	$7FD7,$7FCD,$7FC1,$7FB4,$7FA6,$7F96,$7F86,$7F74 
		dc.w	$7F61,$7F4C,$7F37,$7F20,$7F08,$7EEF,$7ED4,$7EB9 
		dc.w	$7E9C,$7E7E,$7E5E,$7E3E,$7E1C,$7DF9,$7DD5,$7DB0 
		dc.w	$7D89,$7D61,$7D38,$7D0E,$7CE2,$7CB6,$7C88,$7C59 
		dc.w	$7C29,$7BF7,$7BC4,$7B91,$7B5C,$7B25,$7AEE,$7AB5 
		dc.w	$7A7C,$7A41,$7A04,$79C7,$7989,$7949,$7908,$78C6 
		dc.w	$7883,$783F,$77F9,$77B3,$776B,$7722,$76D8,$768D 
		dc.w	$7640,$75F3,$75A4,$7554,$7503,$74B1,$745E,$740A 
		dc.w	$73B5,$735E,$7306,$72AE,$7254,$71F9,$719D,$7140 
		dc.w	$70E1,$7082,$7022,$6FC0,$6F5E,$6EFA,$6E95,$6E30 
		dc.w	$6DC9,$6D61,$6CF8,$6C8E,$6C23,$6BB7,$6B4A,$6ADB 
		dc.w	$6A6C,$69FC,$698B,$6919,$68A5,$6831,$67BC,$6745 
		dc.w	$66CE,$6656,$65DD,$6562,$64E7,$646B,$63EE,$6370 
		dc.w	$62F1,$6271,$61F0,$616E,$60EB,$6067,$5FE2,$5F5D 
		dc.w	$5ED6,$5E4F,$5DC6,$5D3D,$5CB3,$5C28,$5B9C,$5B0F 
		dc.w	$5A81,$59F3,$5963,$58D3,$5842,$57B0,$571D,$5689 
		dc.w	$55F4,$555F,$54C9,$5432,$539A,$5301,$5268,$51CE 
		dc.w	$5133,$5097,$4FFA,$4F5D,$4EBF,$4E20,$4D80,$4CE0 
		dc.w	$4C3F,$4B9D,$4AFA,$4A57,$49B3,$490E,$4869,$47C3 
		dc.w	$471C,$4674,$45CC,$4523,$447A,$43D0,$4325,$4279 
		dc.w	$41CD,$4120,$4073,$3FC5,$3F16,$3E67,$3DB7,$3D07 
		dc.w	$3C56,$3BA4,$3AF2,$3A3F,$398C,$38D8,$3824,$376F 
		dc.w	$36B9,$3603,$354D,$3496,$33DE,$3326,$326D,$31B4 
		dc.w	$30FB,$3041,$2F86,$2ECC,$2E10,$2D54,$2C98,$2BDB 
		dc.w	$2B1E,$2A61,$29A3,$28E5,$2826,$2767,$26A7,$25E7 
		dc.w	$2527,$2467,$23A6,$22E4,$2223,$2161,$209F,$1FDC 
		dc.w	$1F19,$1E56,$1D93,$1CCF,$1C0B,$1B46,$1A82,$19BD 
		dc.w	$18F8,$1833,$176D,$16A7,$15E1,$151B,$1455,$138E 
		dc.w	$12C7,$1200,$1139,$1072,$0FAB,$0EE3,$0E1B,$0D53 
		dc.w	$0C8B,$0BC3,$0AFB,$0A32,$096A,$08A1,$07D9,$0710 
		dc.w	$0647,$057E,$04B6,$03ED,$0324,$025B,$0192,$00C9 
		dc.w	$0000,$FF37,$FE6E,$FDA5,$FCDC,$FC13,$FB4A,$FA82 
		dc.w	$F9B9,$F8F0,$F827,$F75F,$F696,$F5CE,$F505,$F43D 
		dc.w	$F375,$F2AD,$F1E5,$F11D,$F055,$EF8E,$EEC7,$EE00 
		dc.w	$ED39,$EC72,$EBAB,$EAE5,$EA1F,$E959,$E893,$E7CD 
		dc.w	$E708,$E643,$E57E,$E4BA,$E3F5,$E331,$E26D,$E1AA 
		dc.w	$E0E7,$E024,$DF61,$DE9F,$DDDD,$DD1C,$DC5A,$DB99 
		dc.w	$DAD9,$DA19,$D959,$D899,$D7DA,$D71B,$D65D,$D59F 
		dc.w	$D4E2,$D425,$D368,$D2AC,$D1F0,$D134,$D07A,$CFBF 
		dc.w	$CF05,$CE4C,$CD93,$CCDA,$CC22,$CB6A,$CAB3,$C9FD 
		dc.w	$C947,$C891,$C7DC,$C728,$C674,$C5C1,$C50E,$C45C 
		dc.w	$C3AA,$C2F9,$C249,$C199,$C0EA,$C03B,$BF8D,$BEE0 
		dc.w	$BE33,$BD87,$BCDB,$BC30,$BB86,$BADD,$BA34,$B98C 
		dc.w	$B8E4,$B83D,$B797,$B6F2,$B64D,$B5A9,$B506,$B463 
		dc.w	$B3C1,$B320,$B280,$B1E0,$B141,$B0A3,$B006,$AF69 
		dc.w	$AECD,$AE32,$AD98,$ACFF,$AC66,$ABCE,$AB37,$AAA1 
		dc.w	$AA0C,$A977,$A8E3,$A850,$A7BE,$A72D,$A69D,$A60D 
		dc.w	$A57F,$A4F1,$A464,$A3D8,$A34D,$A2C3,$A23A,$A1B1 
		dc.w	$A12A,$A0A3,$A01E,$9F99,$9F15,$9E92,$9E10,$9D8F 
		dc.w	$9D0F,$9C90,$9C12,$9B95,$9B19,$9A9E,$9A23,$99AA 
		dc.w	$9932,$98BB,$9844,$97CF,$975B,$96E7,$9675,$9604 
		dc.w	$9594,$9525,$94B6,$9449,$93DD,$9372,$9308,$929F 
		dc.w	$9237,$91D0,$916B,$9106,$90A2,$9040,$8FDE,$8F7E 
		dc.w	$8F1F,$8EC0,$8E63,$8E07,$8DAC,$8D52,$8CFA,$8CA2 
		dc.w	$8C4B,$8BF6,$8BA2,$8B4F,$8AFD,$8AAC,$8A5C,$8A0D 
		dc.w	$89C0,$8973,$8928,$88DE,$8895,$884D,$8807,$87C1 
		dc.w	$877D,$873A,$86F8,$86B7,$8677,$8639,$85FC,$85BF 
		dc.w	$8584,$854B,$8512,$84DB,$84A4,$846F,$843C,$8409 
		dc.w	$83D7,$83A7,$8378,$834A,$831E,$82F2,$82C8,$829F 
		dc.w	$8277,$8250,$822B,$8207,$81E4,$81C2,$81A2,$8182 
		dc.w	$8164,$8147,$812C,$8111,$80F8,$80E0,$80C9,$80B4 
		dc.w	$809F,$808C,$807A,$806A,$805A,$804C,$803F,$8033 
		dc.w	$8029,$8020,$8018,$8011,$800B,$8007,$8004,$8002 
		dc.w	$8001,$8002,$8004,$8007,$800B,$8011,$8018,$8020 
		dc.w	$8029,$8033,$803F,$804C,$805A,$806A,$807A,$808C 
		dc.w	$809F,$80B4,$80C9,$80E0,$80F8,$8111,$812C,$8147 
		dc.w	$8164,$8182,$81A2,$81C2,$81E4,$8207,$822B,$8250 
		dc.w	$8277,$829F,$82C8,$82F2,$831E,$834A,$8378,$83A7 
		dc.w	$83D7,$8409,$843C,$846F,$84A4,$84DB,$8512,$854B 
		dc.w	$8584,$85BF,$85FC,$8639,$8677,$86B7,$86F8,$873A 
		dc.w	$877D,$87C1,$8807,$884D,$8895,$88DE,$8928,$8973 
		dc.w	$89C0,$8A0D,$8A5C,$8AAC,$8AFD,$8B4F,$8BA2,$8BF6 
		dc.w	$8C4B,$8CA2,$8CFA,$8D52,$8DAC,$8E07,$8E63,$8EC0 
		dc.w	$8F1F,$8F7E,$8FDE,$9040,$90A2,$9106,$916B,$91D0 
		dc.w	$9237,$929F,$9308,$9372,$93DD,$9449,$94B6,$9525 
		dc.w	$9594,$9604,$9675,$96E7,$975B,$97CF,$9844,$98BB 
		dc.w	$9932,$99AA,$9A23,$9A9E,$9B19,$9B95,$9C12,$9C90 
		dc.w	$9D0F,$9D8F,$9E10,$9E92,$9F15,$9F99,$A01E,$A0A3 
		dc.w	$A12A,$A1B1,$A23A,$A2C3,$A34D,$A3D8,$A464,$A4F1 
		dc.w	$A57F,$A60D,$A69D,$A72D,$A7BE,$A850,$A8E3,$A977 
		dc.w	$AA0C,$AAA1,$AB37,$ABCE,$AC66,$ACFF,$AD98,$AE32 
		dc.w	$AECD,$AF69,$B006,$B0A3,$B141,$B1E0,$B280,$B320 
		dc.w	$B3C1,$B463,$B506,$B5A9,$B64D,$B6F2,$B797,$B83D 
		dc.w	$B8E4,$B98C,$BA34,$BADD,$BB86,$BC30,$BCDB,$BD87 
		dc.w	$BE33,$BEE0,$BF8D,$C03B,$C0EA,$C199,$C249,$C2F9 
		dc.w	$C3AA,$C45C,$C50E,$C5C1,$C674,$C728,$C7DC,$C891 
		dc.w	$C947,$C9FD,$CAB3,$CB6A,$CC22,$CCDA,$CD93,$CE4C 
		dc.w	$CF05,$CFBF,$D07A,$D134,$D1F0,$D2AC,$D368,$D425 
		dc.w	$D4E2,$D59F,$D65D,$D71B,$D7DA,$D899,$D959,$DA19 
		dc.w	$DAD9,$DB99,$DC5A,$DD1C,$DDDD,$DE9F,$DF61,$E024 
		dc.w	$E0E7,$E1AA,$E26D,$E331,$E3F5,$E4BA,$E57E,$E643 
		dc.w	$E708,$E7CD,$E893,$E959,$EA1F,$EAE5,$EBAB,$EC72 
		dc.w	$ED39,$EE00,$EEC7,$EF8E,$F055,$F11D,$F1E5,$F2AD 
		dc.w	$F375,$F43D,$F505,$F5CE,$F696,$F75F,$F827,$F8F0 
		dc.w	$F9B9,$FA82,$FB4A,$FC13,$FCDC,$FDA5,$FE6E,$FF37 
		dc.w	$0000,$00C9,$0192,$025B,$0324,$03ED,$04B6,$057E 
		dc.w	$0647,$0710,$07D9,$08A1,$096A,$0A32,$0AFB,$0BC3 
		dc.w	$0C8B,$0D53,$0E1B,$0EE3,$0FAB,$1072,$1139,$1200 
		dc.w	$12C7,$138E,$1455,$151B,$15E1,$16A7,$176D,$1833 
		dc.w	$18F8,$19BD,$1A82,$1B46,$1C0B,$1CCF,$1D93,$1E56 
		dc.w	$1F19,$1FDC,$209F,$2161,$2223,$22E4,$23A6,$2467 
		dc.w	$2527,$25E7,$26A7,$2767,$2826,$28E5,$29A3,$2A61 
		dc.w	$2B1E,$2BDB,$2C98,$2D54,$2E10,$2ECC,$2F86,$3041 
		dc.w	$30FB,$31B4,$326D,$3326,$33DE,$3496,$354D,$3603 
		dc.w	$36B9,$376F,$3824,$38D8,$398C,$3A3F,$3AF2,$3BA4 
		dc.w	$3C56,$3D07,$3DB7,$3E67,$3F16,$3FC5,$4073,$4120 
		dc.w	$41CD,$4279,$4325,$43D0,$447A,$4523,$45CC,$4674 
		dc.w	$471C,$47C3,$4869,$490E,$49B3,$4A57,$4AFA,$4B9D 
		dc.w	$4C3F,$4CE0,$4D80,$4E20,$4EBF,$4F5D,$4FFA,$5097 
		dc.w	$5133,$51CE,$5268,$5301,$539A,$5432,$54C9,$555F 
		dc.w	$55F4,$5689,$571D,$57B0,$5842,$58D3,$5963,$59F3 
		dc.w	$5A81,$5B0F,$5B9C,$5C28,$5CB3,$5D3D,$5DC6,$5E4F 
		dc.w	$5ED6,$5F5D,$5FE2,$6067,$60EB,$616E,$61F0,$6271 
		dc.w	$62F1,$6370,$63EE,$646B,$64E7,$6562,$65DD,$6656 
		dc.w	$66CE,$6745,$67BC,$6831,$68A5,$6919,$698B,$69FC 
		dc.w	$6A6C,$6ADB,$6B4A,$6BB7,$6C23,$6C8E,$6CF8,$6D61 
		dc.w	$6DC9,$6E30,$6E95,$6EFA,$6F5E,$6FC0,$7022,$7082 
		dc.w	$70E1,$7140,$719D,$71F9,$7254,$72AE,$7306,$735E 
		dc.w	$73B5,$740A,$745E,$74B1,$7503,$7554,$75A4,$75F3 
		dc.w	$7640,$768D,$76D8,$7722,$776B,$77B3,$77F9,$783F 
		dc.w	$7883,$78C6,$7908,$7949,$7989,$79C7,$7A04,$7A41 
		dc.w	$7A7C,$7AB5,$7AEE,$7B25,$7B5C,$7B91,$7BC4,$7BF7 
		dc.w	$7C29,$7C59,$7C88,$7CB6,$7CE2,$7D0E,$7D38,$7D61 
		dc.w	$7D89,$7DB0,$7DD5,$7DF9,$7E1C,$7E3E,$7E5E,$7E7E 
		dc.w	$7E9C,$7EB9,$7ED4,$7EEF,$7F08,$7F20,$7F37,$7F4C 
		dc.w	$7F61,$7F74,$7F86,$7F96,$7FA6,$7FB4,$7FC1,$7FCD 
		dc.w	$7FD7,$7FE0,$7FE8,$7FEF,$7FF5,$7FF9,$7FFC,$7FFE 

		SECTION BSS
		DS.L 199
stack		DS.L 2
		DS.B 17*160
screens		DS.B 256
		DS.B 42240
		DS.B 42240
		DS.B 256
		DS.B 17*160
workspace
; Sprite starfield workspace usage.
sprroutptrs	EQU workspace
ballzlookup	EQU sprroutptrs+(16*8*4)
ballxlookup	EQU ballzlookup+(128*8*2)+8
blmul_160	EQU ballxlookup+(20*4*16)
balls_pos	EQU blmul_160+432
bold_pos1	EQU balls_pos+(no_balls*6)
bold_pos2	EQU bold_pos1+(no_balls*4)+4
translated	EQU bold_pos2+(no_balls*4)+4
shiftedball	EQU translated+(no_balls*6)

