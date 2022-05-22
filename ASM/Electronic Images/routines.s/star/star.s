;------------------------------------------------------------------------
; 3d Starfield for Oberje's Mega Animated Scroller Screen!
; Hello Andrew. The starfield contains 324 stars and takes about 20% cpu
; time. If you want to lower the number then you will need to generate
; a new random number table of X.W,Y.W,Z.W values.
; The range for X is -160 to 160
;               Y  " -100 to 100
;               Z    =256
; It is best to spray dots with a spray can in Degas(middle of screen)
; and then write a small gfa proggy to test the screen and record the
; positions. Anyway you can experiment and See for yourself.
; There is an Alternative random number tables on the disk :-
; RAND_176.XYZ  - 176 stars!(11%)
; RAND_131.XYZ  - 131 stars!(8%)
; If you change the random number table you must change the below equate.
;-------------------------------------------------------------------------

no_strs		EQU 131
		
		CLR -(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		CLR -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE #$2700,SR
		LEA stack,SP
		MOVE #$8240,A0
		MOVEM.L (A0),D0-D7
		MOVEM.L D0-D7,old_mfp
		REPT 8
		CLR.L (A0)+
		ENDR
		BSR Genstars
		BSR flush
		MOVE.L log_base(PC),A0
		BSR Clrscreen
		MOVE.L phy_base(PC),A0
		BSR Clrscreen
		LEA old_mfp+32(PC),A0
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.L $68.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $110.W,(A0)+
		MOVE.L $120.W,(A0)+
		CLR.B $FFFFFA07.W
		CLR.B $FFFFFA09.W
		CLR.B $FFFFFA13.W
		CLR.B $FFFFFA15.W
		MOVE.L #my_vbl,$70.W
		MOVEM.L demo_pal(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		MOVE #$2300,SR

; The main vbl loop - clears old stars then draws new.
; The screen is of course double buffered!

vbloop		LEA log_base(PC),A0
		MOVEM.L (A0)+,D0-D1
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		MOVE #$000,$FFFF8240.W
		MOVE vbl_timer(PC),D0
.waitvbl	CMP vbl_timer(PC),D0
		BEQ.S .waitvbl
		MOVE #$700,$FFFF8240.W
		BSR Clearstars
		BSR Plotstars
		BTST.B #0,$FFFFFC00.W
		BEQ vbloop
		CMP.B #$39,$FFFFFC02.W
		BNE vbloop

restore		MOVE #$2700,SR
		BSR flush
		LEA old_mfp(PC),A0
		MOVEM.L (A0)+,D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.L (A0)+,$68.W
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$110.W
		MOVE.L (A0)+,$120.W
		MOVE #$2300,SR
		CLR -(SP)
		TRAP #1
old_mfp		DS.L 15

demo_pal	DC.W $000,$333,$555,$777,$000,$000,$000,$000
		DC.W $000,$000,$000,$000,$000,$000,$000,$000

; Clear the stars.

Clearstars	MOVE.L log_base(PC),A0
		MOVEQ #0,D0
		NOT frameswitch
		BNE .cse2
.cse1		MOVE.L #.a1,which_old
.a1	
		REPT no_strs
		MOVE.L D0,2(A0)
		ENDR
		RTS
.cse2		MOVE.L #.b1,which_old
.b1	
		REPT no_strs
		MOVE.L D0,2(A0)
		ENDR
		RTS

; Plot those darn stars!

Plotstars	MOVE.L log_base(PC),A0
		LEA offsets(PC),A1
		MOVE.L which_old(PC),A5
		MOVE.L (A5),D5
draw1		MOVE.L (A1),A2		
		MOVE.W (A2)+,D5		
		BGE.S .restart
		MOVE.L no_strs*4(A1),A2	
		MOVE.W (A2)+,D5		
.restart	MOVE.L (A2)+,D4
		OR.L D4,(A0,D5)
		MOVE.L A2,(A1)+		
		MOVE.L D5,(A5)+		
enddraw1	DS.B (no_strs-1)*(enddraw1-draw1)
		RTS

; Write d0 to IKBD

writeikbd	BTST.B #1,$FFFFFC00.W
		BEQ.S writeikbd
		MOVE.B D0,$FFFFFC02.W
		RTS

; Flush keyboard

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
flok		RTS

my_vbl		ADDQ.W #1,vbl_timer
		RTE

vbl_timer	DC.W 0

; This bit generates a big table of numbers which are co-ords
; for every star position. Memory wasting but quite fast. 

Genstars	LEA big_buf,A0
		LEA stars,A1		star co-ords
		LEA offsets(PC),A2
		LEA res_offsets(PC),A3
		MOVE #no_strs-1,D7
genstar_lp	MOVE.L A0,(A3)+			save reset offset
		MOVE.L A0,(A2)+			save curr offset
		MOVEM.W (A1)+,D4-D6		get x/y/z
		EXT.L D4			extend sign
		EXT.L D5
		ASL.L #8,D4
		ASL.L #8,D5
thisstar_lp	MOVE.L D4,D0 
		MOVE.L D5,D1
		MOVE.L D6,D2
		SUBQ #3,D6			z=z-3 (perspect)
		DIVS D2,D0			x/z(perspect)
		DIVS D2,D1			y/z(perspect)
		ADD #160,D0			add offsets
		ADD #100,D1			
		CMP #319,D0
		BHI.S Star_off
		CMP #199,D1
		BHI.S Star_off
		MOVE D0,D3
		MULU #160,D1
		LSR #1,D0
		AND.W #$FFF8,D0
		ADD.W D0,D1
		MOVE.W D1,(A0)+
		NOT D3
		AND #15,D3
		MOVEQ #0,D1
		BSET D3,D1
		ASR #6,D2
		TST D2
		BLE.S white
		CMP #1,D2
		BEQ.S white
		CMP #2,D2
		BEQ.S c2
c1		MOVE.W D1,(A0)+
		CLR.W (A0)+
		BRA thisstar_lp
white		MOVE.W D1,(A0)+
		MOVE.W D1,(A0)+
		BRA thisstar_lp
c2		MOVE.L D1,(A0)+
		BRA thisstar_lp
Star_off	MOVE.L #-1,(A0)+
		MOVE.W #-1,(A0)+
		DBF D7,genstar_lp
Randoffsets	LEA offsets(PC),A0
		LEA seed,A2
		MOVE #no_strs-2,D7
rands		MOVEM.L (A0),D0/D1
		SUB.L D0,D1
		DIVU #6,D1
		MOVEQ #0,D2
		MOVE (A2),D2		
		ROL #1,D2			
		EOR #54321,D2
		SUBQ #1,D2		
		MOVE D2,(A2)	
		DIVU D1,D2						
		CLR.W D2
		SWAP D2
		MULU #6,D2
		ADD.L D2,D0
		MOVE.L D0,(A0)+
		DBF D7,rands			
Repeatrout	LEA draw1(PC),A0
		LEA enddraw1(PC),A1
		MOVE #no_strs-2,D7
.lp1		MOVE #(enddraw1-draw1)-1,D6
.lp2		MOVE.B (A0)+,(A1)+
		DBF D6,.lp2
		DBF D7,.lp1
		RTS

; Clear screen -> A0

Clrscreen	MOVEQ #0,D1
		MOVE #1999,D0
.lp		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D0,.lp
		RTS

log_base	DC.L $2F0000
phy_base	DC.L $2F8000
frameswitch	DC.W 0
which_old	DC.L 0

stars		INCBIN D:\ROUTINES.S\STAR\rand_131.xyz
seed		DC.W $9753
		SECTION BSS
offsets		DS.L no_strs
res_offsets	DS.L no_strs
		DS.L 199
stack		DS.L 1
big_buf

