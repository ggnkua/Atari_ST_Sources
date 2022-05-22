;-----------------------------------------------------------------------;
;              Quicky Little Fullscreen Intro for ELITE			;
;									;
; Programmed by Griff of Electronic Images (Inner Circle) December 91. 	;
;									;
; Contains the following :-						;
; Starfield with 512 stars. (a sort of fake 3d starfield using modulos.);
; 16*16 sideways disting scroller bouncing (rastered).			;
; A little text display at the top with some nice colours through it..	;
;-----------------------------------------------------------------------;

; To whom it may concern :-

; 1. This Intro uses loadsa memory - it require 450k to run.
;    I think this means it might just run from an auto folder on half meg?
; 2. No facility has been provided to chain programs -
;    you can write your own, since it may be dma etc.
; 3. Basically if you want to change the colours/music/etc then code it
;    yourself

demo		EQU 0			; gem/disk

no_strs		EQU 512			; no of stars(not changable!!!)

letsgo
		IFEQ demo
		MOVE #2,-(SP)
		TRAP #14		; save old phybase
		ADDQ.L #2,SP
		MOVE.L D0,old_base
		MOVE #4,-(SP)
		TRAP #14		
		ADDQ.L #2,SP		; save old res
		MOVE.W D0,old_rez
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

		BRA start

music		INCBIN \ELITEINT.INC\MARTY2.CZI
		EVEN

start		MOVE #$2700,SR
		LEA stack,SP	
		MOVEM.L $FFFF8240.W,D0-D7
		MOVEM.L D0-D7,old_cols
		MOVEQ #1,D0
		BSR music+28	
		BSR Initscreens		; reserve screens/clear em
		BSR makeperstab		;
		BSR Random_gen		; setup the starfield
		BSR gen_masks		; tables etc...
		BSR Init_StarSeq	;
		BSR set_ints
		MOVE #$2300,SR
		BSR wait_vbl

; This is the main program loop

Star_frame	
		BSR wait_vbl
		MOVEM.L colours(pc),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		BSR music+28+6
		BSR Swap_Screens	
		BSR clear_stars		;
		BSR Seq_stars		; various bits
		BSR WriteText		;
		BSR DistyScroll

		BTST.B #0,$FFFFFC00.W
		BEQ.S Star_frame
		CMP.B #$39,$FFFFFC02.W	; exit on space
		BNE Star_frame		

Exit		MOVEM.L old_cols(pc),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		MOVEQ #0,D0
		BSR music+28	
		BSR rest_ints
		IFEQ demo
		MOVE.W old_rez(PC),-(SP)
		MOVE.L old_base(PC),-(SP)
		MOVE.L old_base(PC),-(SP)
		MOVE #5,-(SP)
		TRAP #14		; lowres
		LEA 12(SP),SP
		CLR -(SP)
		TRAP #1			
		ENDC

; Initialisation interrupts (mfp etc) and various vectors.

set_ints	MOVE.W SR,-(SP)
		MOVE.W #$2700,SR
		LEA old_stuff(pc),A0
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
		MOVE.B #$21,$FFFFFA07.W
		MOVE.B #0,$FFFFFA09.W
		MOVE.B #$21,$FFFFFA13.W
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

old_stuff	DS.L 16
old_cols	DS.W 16
old_base	DS.L 1
old_rez		DS.W 1

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
		add.l #58368,d0
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
		move #(58368/16)-1,d1
.cls		move.l d0,(a0)+
		move.l d0,(a0)+
		move.l d0,(a0)+
		move.l d0,(a0)+
		dbf d1,.cls
		rts

; Routines for Initialision of Starfield.

makeperstab	LEA humungus_table,A1
		MOVE.L #(350*32767/512)*384,D7
		MOVE #350+$200,D1
		MOVE.W #$100-1,D2
.lp		MOVE.L D7,D6
		DIVS D1,D6
		MOVE.W #-256,D4
		MOVE.W #512-1,D3
.lp2		MOVE.W D4,D5
		MULS D6,D5
		ADD.L D5,D5
		SWAP D5
		ADD.W D5,D5
		ADD.W D5,D5
		MOVE.W D5,(A1)+
		ADDQ #1,D4
		DBF D3,.lp2
		SUBQ #2,D1
		DBF D2,.lp
		RTS

Random_gen	LEA stars,A3
		LEA (no_strs*4)(A3),A4
		MOVE #no_strs-1,D4
		MOVE.W #$2354,D0		;seed
.f_rand_x	BSR Rand
		MOVE.W D0,D1
		AND #$3FE,D1
		MOVE D1,(A3)+
.f_rand_y	BSR Rand
		MOVE.W D0,D1
		AND #$3FE,D1
		MOVE D1,(A3)+
		MOVE.L -4(A3),(A4)+
		DBF D4,.f_rand_x
Mul_160_crt	LEA mul_160,A0			;create *160 table
		MOVEQ #32-1,D0
.lp1		CLR.W (A0)+
		MOVE.W #(132*230),(A0)+
		DBF D0,.lp1
		MOVE.L #53000,D2
		MOVEQ #0,D0
		MOVE #320-1,D1
.mul_lp		ADD.L D2,D0
		MOVE.L D0,D3
		SWAP D3
		SUB.L #130,D3
		MULS #230,D3
		CLR.W (A0)+
		MOVE.W D3,(A0)+
		DBF D1,.mul_lp
		MOVEQ #32-1,D0
.lp2		CLR.W (A0)+
		MOVE.W #(136*230),(A0)+
		DBF D0,.lp2
		RTS

gen_masks 	LEA plot_masks,A0
		MOVEQ #0,D0
		MOVE.L #$11900,D2
		MOVE #384-1,D7
.masklp		ADD.L D2,D0
		MOVE.L D0,D3
		SWAP D3
		MOVE.W D3,D4
		CLR D5
		NOT D3
		AND #15,D3
		BSET D3,D5
		MOVE.W D5,(A0)+
		LSR #1,D4
		AND.W #$FFF8,D4
		MOVE.W D4,(A0)+
		DBF D7,.masklp
		RTS

Rand		ADD D4,D0
		ADD.W #$573,D0
		MULU #$45F7,D0
		ROR.W #6,D0
		RTS

log_base 	DC.L 0
phy_base 	DC.L 0
switch		DS.W 1
vbl_timer	DS.W 1
colours		DC.W $000,$222,$444,$444,$666,$666,$666,$666
		DC.W $777,$777,$777,$777,$777,$777,$777,$777

clear_stars	MOVE.L log_base(pc),A0		; screen base
		LEA (130*230)+(10*160)(A0),A0
		MOVEQ #0,D0
		TST switch
		BNE old_pos1
old_pos2	
		REPT 154
		MOVE.W D0,2(A0)
		ENDR
		ADDQ.W #2,A0
		REPT 170
		MOVE.W D0,2(A0)
		ENDR
		ADDQ.W #2,A0
		REPT 160
		MOVE.W D0,2(A0)
		ENDR
		RTS
old_pos1	
		REPT 154
		MOVE.W D0,2(A0)
		ENDR
		ADDQ.W #2,A0
		REPT 170
		MOVE.W D0,2(A0)
		ENDR
		ADDQ.W #2,A0
		REPT 160
		MOVE.W D0,2(A0)
		ENDR
		RTS


Init_StarSeq	LEA starfield_struc(PC),A0
		MOVE.L #star_seq,starseq_ptr(A0)
		MOVE.L #star_seq,starresseq_ptr(A0)
		MOVE.W #1,star_seqtimer(A0)
		BRA.W Seq_stars

star_seq	DC.W 256,0,0,18,0,48
		DC.W 128,4,4,18,0,48
		DC.W 128,0,0,18,0,48
		DC.W 128,4,4,18,0,48

		DC.W 128,4,4,0,18,48
		DC.W 128,0,0,0,18,48
		DC.W 128,4,4,0,18,48

		DC.W 256,4,4,18,18,48
		DC.W 128,4,0,18,18,48
		DC.W 128,4,8,18,18,48
		DC.W 128*4,8,4,18,18,48
		DC.W -1
		
; Do Starfield sequence - hmm... this is still a bit difficult to use.

		RSRESET
star_seqtimer	RS.W 1
starseq_ptr	RS.L 1
starresseq_ptr	RS.L 1
xyz		RS.B 0
x		RS.W 1
y		RS.W 1
z		RS.W 1
xyzang		RS.B 0
xang		RS.W 1
zang		RS.W 1
xspeed		RS.W 1
yspeed		RS.W 1
zspeed		RS.W 1
xang_inc	RS.W 1
zang_inc	RS.W 1
star_strucsize	RS.B 1

starfield_struc	DS.B star_strucsize

Seq_stars	LEA starfield_struc(PC),A6
		SUBQ #1,star_seqtimer(A6)	; next sequence?
		BNE.S .nonew
		MOVE.L starseq_ptr(A6),A0	; ok...
		MOVE.W (A0)+,star_seqtimer(A6)
		MOVE.W (A0)+,xang_inc(A6)
		MOVE.W (A0)+,zang_inc(A6)
		MOVE.W (A0)+,xspeed(A6)		; read next seq
		MOVE.W (A0)+,yspeed(A6)		; vals
		MOVE.W (A0)+,zspeed(A6)
		CMP.W #-1,(A0)			; end of seq?
		BNE.S .notendseq
		MOVE.L starresseq_ptr(A6),A0	; yes then restart
.notendseq	MOVE.L A0,starseq_ptr(A6)	; store seq ptr
.nonew		MOVEM.W xyzang(A6),D0-D1
		ADD xang_inc(A6),D0
		ADD zang_inc(A6),D1
		AND.W #$7FE,D0
		AND.W #$7FE,D1
		MOVEM.W D0-D1,xyzang(A6)
		LEA trig_tab,A1
		LEA $200(A1),A2
		MOVE.W (A2,D1),D2
		MOVE.W (A1,D0),D1
		MOVE.W (A1,D0),D0
		MULS xspeed(A6),D0
		MULS yspeed(A6),D1
		MULS zspeed(A6),D2
		ADD.L D0,D0
		SWAP D0
		ADD.L D1,D1		
		SWAP D1
		ADD.L D2,D2
		SWAP D2
		MOVEM.W xyz(A6),D3-D5
		ADD D0,D3
		ADD D1,D4
		ADD D2,D5
		AND.W #$7FC,D5
		MOVEM.W D3-D5,xyz(A6)
		RTS

plot1		MACRO
		MOVE.W (A1)+,D0
		MOVE.W (A1)+,D1
		ADD D3,D0
		ADD D4,D1
		AND.W D7,D0
		AND.W D7,D1
		MOVE.W (A6,D0),D0
		MOVE.W (A6,D1),D1
		MOVE.L (A5,D0),D0
		MOVE.W 2(A4,D1),D2
		ADD D0,D2
		MOVE.L D2,(A3)+			; store pos
		SWAP D0
		OR D0,\1(A0,D2)

		MOVE.W (A1)+,D0
		MOVE.W (A1)+,D1
		ADD D3,D0
		ADD D4,D1
		AND.W D7,D0
		AND.W D7,D1
		MOVE.W (A6,D0),D0
		MOVE.W (A6,D1),D1
		MOVE.L (A5,D0),D0
		MOVE.W 2(A4,D1),D2
		ADD D0,D2
		MOVE.L D2,(A3)+			; store pos
		SWAP D0
		OR D0,\1(A0,D2)
		LEA 1024(A6),A6
		ENDM

; Mr Vbl.

first_vbl	MOVE.L #vbl,$70.W
		ADDQ #1,vbl_timer
		RTE
			
vbl		CLR.B $FFFFFA19.W
		MOVE.B #99,$FFFFFA1F.W
		MOVE.L #overscantop,$134.W
		MOVE.B #4,$FFFFFA19.W
		CLR.B $FFFFFA1B.W
		MOVE.B #8,$FFFFFA21.W
		MOVE.L #overmain,$120.W
		MOVE.B #8,$FFFFFA1B.W
		ADDQ #1,vbl_timer
		RTE

; top border take out rout. (by processor hbl sync)

overscantop	MOVE #$2100,SR			;top border synchronisation
		STOP #$2100			;by processor hbl
		MOVE #$2700,SR
		CLR.B $FFFFFA19.W
		DCB.W 80,$4E71
		MOVE.B #0,$FFFF820A.W		; 60hz
		DCB.W 18,$4E71			
		MOVE.B #2,$FFFF820A.W		; 50hz and top border
		RTE				; is removed.

; Now the mega messy main overscan code.

overmain	MOVE #$2700,SR
		CLR.B $FFFFFA1B.W
		MOVEM.L D0-D7/A0-A6,-(SP)
		CLR D1
syncloop	MOVE.B $FFFF8209.W,D1
		JMP .noplist(PC,D1)
.noplist	DCB.W 48,$4E71
		MOVE.L SP,savesp
		MOVE.L log_base(pc),A0		; screen base
		LEA (130*230)+(10*160)(A0),A0
		LEA stars,A1			; star co-ords
		MOVEM.W starfield_struc+xyz(PC),D3-D5
		ADD.W D5,A1
		LEA old_pos1(PC),A3		
		LEA old_pos2(PC),A4
		MOVE.W switch(PC),D0
		BNE.S .cse2
.cse1		MOVE.L A4,A3
.cse2		LEA mul_160+(384*2),A4		; mul 160 table
		LEA plot_masks+(384*2),A5	; point masks
		LEA humungus_table,A6
		LEA 1024*11(A6),A6
		MOVE.W #$3FE,D7
		MOVE.L (A3),D2
		MOVE.L toprast_ptr(PC),A2
		MOVE #$8240,A7
		REPT 38
		MOVE.W (A2)+,(A7)		; top raster line
		ENDR
		MOVE.W #$000,$FFFF8240.W
		LEA mainrasts(PC),A2
		DCB.W 2,$4E71

do1colour	MACRO
		MOVE.L (A2)+,D0
		MOVE.L D0,(A7)+
		MOVE.L D0,(A7)+
		MOVE.L D0,(A7)+
		MOVE.L D0,(A7)
		ENDM

; Plot First layer

		MOVEQ #77-1,D5
.layer1		DCB.W 3,$4E71	
		MOVE.W #$8250,A7
		MOVE.B #2,$ffff8260.w
		MOVE.B #0,$ffff8260.w
		do1colour
		plot1 0
 		MOVE.B #0,$ffff820a.w
		MOVE.B #2,$ffff820a.w
		DCB.W 8,$4e71	
		MOVE.B #1,$ffff8260.w
		MOVE.B #0,$ffff8260.w
		DCB.W 1,$4E71	
		DBF D5,.layer1	
	
		DCB.W 2,$4E71	
		MOVE.W #$8250,A7
		MOVE.B #2,$ffff8260.w
		MOVE.B #0,$ffff8260.w
		do1colour
		ADDQ.W #2,A3
		DCB.W 87-2-15,$4E71	
 		MOVE.B #0,$ffff820a.w
		MOVE.B #2,$ffff820a.w
		DCB.W 8,$4e71	
		MOVE.B #1,$ffff8260.w
		MOVE.B #0,$ffff8260.w
		DCB.W 3,$4E71	

; Plot Second layer

		MOVEQ #85-1,D5
.layer2		DCB.W 3,$4E71	
		MOVE.W #$8250,A7
		MOVE.B #2,$ffff8260.w
		MOVE.B #0,$ffff8260.w
		do1colour
		plot1 2
 		MOVE.B #0,$ffff820a.w
		MOVE.B #2,$ffff820a.w
		DCB.W 8,$4e71	
		MOVE.B #1,$ffff8260.w
		MOVE.B #0,$ffff8260.w
		DCB.W 1,$4E71	
		DBF D5,.layer2

		DCB.W 2,$4E71	
		MOVE.W #$8250,A7
		MOVE.B #2,$ffff8260.w
		MOVE.B #0,$ffff8260.w
		do1colour
		ADDQ.W #2,A3
		DCB.W 87-2-15,$4E71	
 		MOVE.B #0,$ffff820a.w
		MOVE.B #2,$ffff820a.w
		DCB.W 8,$4e71	
		MOVE.B #1,$ffff8260.w
		MOVE.B #0,$ffff8260.w
		DCB.W 3,$4E71	
		MOVEQ #55-1,D5

; Plot Last layer

.layer3a	DCB.W 3,$4E71	
		MOVE.W #$8250,A7
		MOVE.B #2,$ffff8260.w
		MOVE.B #0,$ffff8260.w
		do1colour
		plot1 4
 		MOVE.B #0,$ffff820a.w
		MOVE.B #2,$ffff820a.w
		DCB.W 8,$4e71	
		MOVE.B #1,$ffff8260.w
		MOVE.B #0,$ffff8260.w
		DCB.W 1,$4E71	
		DBF D5,.layer3a

BOT_BORD	MOVE.B #0,$ffff820a.w
		MOVE.B #2,$ffff8260.w		; overscan
		MOVE.B #0,$ffff8260.w		; the bottom border
		MOVE.B #2,$ffff820a.w		; (with full overscan)
		MOVE.W #$8250,A7
		do1colour
		DCB.W 81-15,$4E71	
 		MOVE.B #0,$ffff820a.w
		MOVE.B #2,$ffff820a.w
		DCB.W 8,$4e71	
		MOVE.B #1,$ffff8260.w
		MOVE.B #0,$ffff8260.w
		DCB.W 3,$4E71	

		MOVEQ #25-1,D5			; second half of layer 3
.layer3b	DCB.W 3,$4E71	
		MOVE.W #$8250,A7
		MOVE.B #2,$ffff8260.w
		MOVE.B #0,$ffff8260.w
		do1colour
		plot1 4
 		MOVE.B #0,$ffff820a.w
		MOVE.B #2,$ffff820a.w
		DCB.W 8,$4e71	
		MOVE.B #1,$ffff8260.w
		MOVE.B #0,$ffff8260.w
		MOVEQ #0,D0
		DBF D5,.layer3b
		MOVE #$8240,A7
		MOVE.L botrast_ptr(PC),A2
		REPT 38
		MOVE.W (A2)+,(A7)		; bottom raster line
		ENDR
		REPT 8
		MOVE.L D0,(A7)+
		ENDR
		MOVE.L savesp(PC),SP

		LEA toprast_ptr(PC),A0
		MOVE.L (A0),D0
		ADDQ.L #2,D0
		CMP.L #topbotrasts+sizerasts,d0
		BNE.S .nottopwr
		SUB.L #sizerasts,D0
.nottopwr	MOVE.L D0,(A0)+

		MOVE.L (A0),D0
		SUBQ.L #2,D0
		CMP.L #topbotrasts,D0
		BNE.S .notbotwr
		ADD.L #sizerasts,D0
.notbotwr	MOVE.L D0,(A0)

		MOVEM.L (SP)+,D0-D7/A0-A6
phbl		RTE
savesp		DC.L 0

toprast_ptr	DC.L topbotrasts
botrast_ptr	DC.L topbotrasts+78
topbotrasts	INCBIN \ELITEINT.INC\TOPBOTRT.PAL
endrasts
sizerasts	EQU (endrasts-topbotrasts)-82

littlefont	INCBIN \ELITEINT.INC\MET_03.FN8
		EVEN

; Raster table 1 longword per line in from COLOUR.W,COLOUR.W (for speed)
; (in this case I repeat colours 4 times since I could not be bothered to
; work out a large 250 line palette - change this if you want....)

mainrasts	DCB.L 8,$07770777
		DCB.L 4,$00200020
		DCB.L 4,$00300030
		DCB.L 4,$00400040
		DCB.L 4,$00500050
		DCB.L 4,$00600060
		DCB.L 4,$00700070
		DCB.L 4,$01700170
		DCB.L 4,$02700270
		DCB.L 4,$03700370
		DCB.L 4,$04700470
		DCB.L 4,$05700570
		DCB.L 4,$06700670
		DCB.L 4,$07700770
		DCB.L 4,$07710771
		DCB.L 4,$07720772
		DCB.L 4,$07730773
		DCB.L 4,$07740774
		DCB.L 4,$07750775
		DCB.L 4,$07760776
		DCB.L 4,$07670767
		DCB.L 4,$07570757
		DCB.L 4,$07470747
		DCB.L 4,$07370737
		DCB.L 4,$07270727
		DCB.L 4,$07170717
		DCB.L 4,$07070707
		DCB.L 4,$06070607
		DCB.L 4,$05070507
		DCB.L 4,$04070407
		DCB.L 4,$03070307
; below main text bit
		DCB.L 4,$00200020
		DCB.L 4,$00300030
		DCB.L 4,$00500050
		DCB.L 4,$00700070
		DCB.L 4,$00700070
		DCB.L 4,$00500050
		DCB.L 4,$00300030
		DCB.L 4,$00200020

		DCB.L 4,$02200220
		DCB.L 4,$03300330
		DCB.L 4,$05500550
		DCB.L 4,$07700770
		DCB.L 4,$07700770
		DCB.L 4,$05500550
		DCB.L 4,$03300330
		DCB.L 4,$02200220

		DCB.L 4,$00220022
		DCB.L 4,$00330033
		DCB.L 4,$00550055
		DCB.L 4,$00770077
		DCB.L 4,$00770077
		DCB.L 4,$00550055
		DCB.L 4,$00330033
		DCB.L 4,$00220022

		DCB.L 4,$00120012
		DCB.L 4,$00010001
		DCB.L 4,$01010101
		DCB.L 4,$02020202
		DCB.L 4,$04040404
		DCB.L 4,$05050505
		DCB.L 4,$06060606
		DCB.L 4,$07070707

; Text Displayer (top)

WriteText	TST.B wtextflag
		BNE .nodo		
		SUBQ.B #1,wtexttimer
		BGE .nodo
		MOVE.B #1,wtexttimer
		MOVE.L log_base(pc),A3		; screen base
		MOVE.L phy_base(pc),A4		; screen base
		LEA (8*230)+(10*160)+30(A3),A3
		LEA (8*230)+(10*160)+30(A4),A4
		MOVEQ #0,D0
		MOVE.W wtext_cnt(PC),D0
		DIVU #42,D0
		MOVE.W D0,D1
		SWAP D0				; remainder
		MULU #230*8,D1			; line offset
		MOVEQ #0,D2
		LSR #1,D0
		ADDX D2,D1
		LSL #3,D0
		ADD.W D0,D1

		ADD.W D1,A3
		ADD.W D1,A4

		LEA littlefont-(32*8)(PC),A1
		MOVE.L wtext_ptr(PC),A2
		MOVEQ #0,D0
		MOVE.B (A2)+,D0
		BNE.S .notend			
		ST wtextflag
		BRA.S .nodo
.notend		MOVE.L A2,wtext_ptr
		LSL #3,D0			; *8 (offy)
		ADD.W D0,A1
i		SET 0
		REPT 8
		MOVE.B (A1),i(A3)
		MOVE.B (A1)+,i(A4)
i		SET i+230
		ENDR
		ADDQ #1,wtext_cnt
.nodo		RTS

wtextflag	DC.B 0
wtexttimer	DC.B 0
wtext_ptr	DC.L wtext
wtext_scrnpos	DC.L 0
wtext_cnt	DC.W 0

;		     "012345678901234567890123456789012345678901"

; The text at the top of the screen

wtext		DC.B "******************************************" 
		DC.B "*                                        *"
		DC.B "*                 ELITE                  *"
		DC.B "*                                        *"
		DC.B "*                PRESENT...              *"
		DC.B "*                                        *"
		DC.B "*    YET ANOTHER BLOODY CRACKED GAME!    *"
		DC.B "*                                        *"
		DC.B "*  CRACKED, PACKED AND FILED BY XXXXXX   *"
		DC.B "*                                        *"
		DC.B "*  ORIGINAL SUPPLIED BY MR XXXXXXXXXXXX  *"
		DC.B "*                                        *"
		DC.B "*  INTRO BY GRIFF OF THE INNER CIRCLE.   *"
		DC.B "*                                        *"
		DC.B "******************************************",0
		EVEN

; 16*16 1 plane Disting scroller (C) Martin Griffiths Sept 1990.
; This takes about 15-16 raster lines...

nolines		EQU 16
linewid		EQU 128
bufsize		EQU nolines*linewid

DistyScroll	MOVEM.L dist_tab+2(PC),D0-D7
		MOVEM.L D0-D7,dist_tab
		MOVE dist_ang(PC),D0
		ADD dist_step(PC),D0
		AND #$3FE,D0
yep		MOVE D0,dist_ang
		MOVE dister(PC),D1
		ADD dist_step(PC),D1
		CMP maxi_dist(PC),D1
		BLE.S notwang
 		SUB maxi_dist(PC),D1
sel_wave	MOVE.L wave_ptr(PC),A1
		LEA dist_step(PC),A2
		MOVE (A1)+,(A2)+
		BPL.S nrapwave 
		LEA wave_tab(PC),A1
		MOVE (A1)+,-2(A2)
nrapwave	MOVE.L (A1)+,(A2)+
		MOVE.L A1,wave_ptr
notwang		MOVE D1,dister
		LEA dist_sintab(PC),A1		; ptr to sin table
		MOVE (A1,D0),D0			; sin(xd)
		MULS size(PC),D0		; *size (magnitude of wave)
		LSL.L #2,D0				
		SWAP D0				; normalise
		ADD #48,D0
		ADD D0,D0
		ADD D0,D0			; x4
		MOVE.W D0,dist_tab+30		; place in table
; Update scroll buffers/ptrs etc
		LEA scr_point(PC),A1
		MOVE.L (A1)+,A0			; curr text ptr
		MOVE.L (A1)+,A3			; curr pix buffer ptr
		MOVE (A1),D6			; pixel offset
		LEA bufsize*2(A3),A3		; skip buffers(BUFFERS*speed)
		ADDQ #2,D6			; pix offset+speed
		AND #15,D6			; next 16 pix?
		BNE.S pos_ok			; no then skip
		ADDQ.W #2,scrlpos		; onto next chunk 
		CMP #linewid/2,scrlpos		; in pix buffer.
		BNE.S nowrapscr			; reached end of buffer?		
		CLR scrlpos			; if yes reset buffer position
nowrapscr	LEA scbuffer(PC),A3		; reset pixel chunk offset
		ADDQ.L #1,A0			; next letter...
pos_ok		MOVEQ #0,D0
		TST.B 1(A0)	
		BNE.S notwrap			; end of text?
		LEA text(PC),A0			; yes restart text
notwrap		MOVE D6,(A1)			; otherwise restore
		MOVE.L A3,-(A1)			
		MOVE.L A0,-(A1)
		MOVEQ #0,D0
		MOVEQ #0,D1
		MOVE.B (A0)+,D0
		MOVE.B (A0),D1			; must be plotted
		LEA fontbuf(PC),A5     		; character addr    
		LEA (A5),A6
		SUB.B #32,D0			; normalise asci char
		SUB.B #32,D1
		LSL #5,D0              		; *128 font offset
		LSL #5,D1              		;      "
		ADDA.W D0,A5
		ADDA.W D1,A6
norm		ADD scrlpos(PC),A3
i		SET 0
		REPT nolines
		MOVE.W (A6)+,D3
		SWAP D3
		MOVE.W (A5)+,D3 
		ROL.L D6,D3
		MOVE.W D3,i+(linewid/2)-2(A3)	
		MOVE.W D3,i-2(A3)
		ROL.L #1,D3
		MOVE.W D3,i+(linewid/2)-2+bufsize(A3)
		MOVE.W D3,i-2+bufsize(A3)
i		SET i+linewid
		ENDR
; Copy scroller to screen.
Copy_Scroller	MOVE.L log_base(PC),A2		; screen base
		LEA (10*160)+(123*230)+6+8(A2),A2
		LEA trig_tab(PC),A1	
		MOVE.W dist_bounceptr(PC),D0
		ADDQ #8,D0
		AND.W #$3FE,D0
		MOVE.W D0,dist_bounceptr
		MOVEQ #-94,D1
		MULS (A1,D0),D1
		ADD.L D1,D1
		SWAP D1
		ADD #97,D1
		MULU #230,D1
		ADD.W D1,A2
		LEA scbuffer(PC),A0
		ADD scrlpos(PC),A0
		LEA dist_tab(PC),A3
		LEA xtab(PC),A4
		MOVE.W scx(PC),D0
		ADD D0,D0
		ADD D0,D0
		ADD.W D0,A4			; add pix offset
		MOVEQ #0,D7
i		SET 0
		REPT 5
		MOVE.W D7,i(A2)
		MOVE.W D7,i+8(A2)
		MOVE.W D7,i+16(A2)
		MOVE.W D7,i+24(A2)
		MOVE.W D7,i+32(A2)
		MOVE.W D7,i+40(A2)
		MOVE.W D7,i+48(A2)
		MOVE.W D7,i+56(A2)
		MOVE.W D7,i+64(A2)
		MOVE.W D7,i+72(A2)
		MOVE.W D7,i+80(A2)
		MOVE.W D7,i+88(A2)
		MOVE.W D7,i+96(A2)
		MOVE.W D7,i+104(A2)
		MOVE.W D7,i+112(A2) 
		MOVE.W D7,i+120(A2) 
		MOVE.W D7,i+128(A2)
		MOVE.W D7,i+136(A2)
		MOVE.W D7,i+144(A2)
		MOVE.W D7,i+152(A2)
		MOVE.W D7,i+160(A2)
		MOVE.W D7,i+168(A2)
		MOVE.W D7,i+176(A2)
		MOVE.W D7,i+184(A2)
		MOVE.W D7,i+192(A2)
i		SET i+230
		ENDR
j		SET 0
		REPT nolines
		MOVE.W (A3)+,D0
		LEA j(A0),A1
		ADD.L (A4,D0),A1
		MOVE.W (a1)+,i(A2)
		MOVE.W (a1)+,i+8(A2)
		MOVE.W (a1)+,i+16(A2)
		MOVE.W (a1)+,i+24(A2)
		MOVE.W (a1)+,i+32(A2)
		MOVE.W (a1)+,i+40(A2)
		MOVE.W (a1)+,i+48(A2)
		MOVE.W (a1)+,i+56(A2)
		MOVE.W (a1)+,i+64(A2)
		MOVE.W (a1)+,i+72(A2)
		MOVE.W (a1)+,i+80(A2)
		MOVE.W (a1)+,i+88(A2)
		MOVE.W (a1)+,i+96(A2)
		MOVE.W (a1)+,i+104(A2)
		MOVE.W (a1)+,i+112(A2) 
		MOVE.W (a1)+,i+120(A2) 
		MOVE.W (a1)+,i+128(A2)
		MOVE.W (a1)+,i+136(A2)
		MOVE.W (a1)+,i+144(A2)
		MOVE.W (a1)+,i+152(A2)
		MOVE.W (a1)+,i+160(A2)
		MOVE.W (a1)+,i+168(A2)
		MOVE.W (a1)+,i+176(A2)
		MOVE.W (a1)+,i+184(A2)
		MOVE.W (a1)+,i+192(A2)
j		SET j+linewid
i		SET i+230
		ENDR 
		REPT 4
		MOVE.W D7,i(A2)
		MOVE.W D7,i+8(A2)
		MOVE.W D7,i+16(A2)
		MOVE.W D7,i+24(A2)
		MOVE.W D7,i+32(A2)
		MOVE.W D7,i+40(A2)
		MOVE.W D7,i+48(A2)
		MOVE.W D7,i+56(A2)
		MOVE.W D7,i+64(A2)
		MOVE.W D7,i+72(A2)
		MOVE.W D7,i+80(A2)
		MOVE.W D7,i+88(A2)
		MOVE.W D7,i+96(A2)
		MOVE.W D7,i+104(A2)
		MOVE.W D7,i+112(A2) 
		MOVE.W D7,i+120(A2) 
		MOVE.W D7,i+128(A2)
		MOVE.W D7,i+136(A2)
		MOVE.W D7,i+144(A2)
		MOVE.W D7,i+152(A2)
		MOVE.W D7,i+160(A2)
		MOVE.W D7,i+168(A2)
		MOVE.W D7,i+176(A2)
		MOVE.W D7,i+184(A2)
		MOVE.W D7,i+192(A2)
i		SET i+230
		ENDR
		RTS

dist_bounceptr	DC.W 0
scr_point	DC.L text
which_buf	DC.L scbuffer
scx		DC.W 0
scrlpos		DC.W 0
inletswitch	DC.W 0

; The text for the disty scroller

text		dc.b "        GREETINGS GO TO THE FOLLOWING PEOPLE.... FRED,TED,BILLY THE FISH,SHARON,TRACY,WAYNE,TREV,JOE BLOGGS ETC ETC...          "
		dc.b 0
		EVEN
fontbuf		INCBIN \ELITEINT.INC\met_05.f16
dist_ang	DC.W 0
dist_step	DC.W 4
maxi_dist	DC.W 512
size		DC.W 48
dister		DC.W 0
wave_ptr	DC.L wave_tab
wave_tab	DC.W 4,512,48
		DC.W 4,512,32
		DC.W 12,512,16
		DC.W 48,8192,4
		DC.W 64,4096,1
		DC.W 8,512,16
		DC.W 8,512,32
		DC.W -1

dist_tab	DCB.W nolines+3,48

i		SET 0
xtab		REPT 10
		DC.L i
		DC.L i+(bufsize*1)
		DC.L i+(bufsize*2)
		DC.L i+(bufsize*3)
		DC.L i+(bufsize*4)
		DC.L i+(bufsize*5)
		DC.L i+(bufsize*6)
		DC.L i+(bufsize*7)
		DC.L i+(bufsize*8)
		DC.L i+(bufsize*9)
		DC.L i+(bufsize*10)
		DC.L i+(bufsize*11)
		DC.L i+(bufsize*12)
		DC.L i+(bufsize*13)
		DC.L i+(bufsize*14)
		DC.L i+(bufsize*15)
i		SET i+2
		ENDR

dist_sintab	rept 2
		dc.l	$0000019B,$032304BE,$064507DE,$09630AF9,$0C7C0E0E 
		dc.l	$0F8C111A,$1293141B,$158F1710,$187D19F7,$1B5C1CCE 
		dc.l	$1E2B1F93,$20E62244,$238E24E1,$261F2766,$289929D4 
		dc.l	$2AFA2C27,$2D412E5F,$2F6B307B,$31783279,$33673458 
		dc.l	$35363616,$36E437B3,$3871392E,$39DA3A85,$3B203BB9 
		dc.l	$3C413CC7,$3D3E3DB0,$3E143E73,$3EC43F0F,$3F4E3F85 
		dc.l	$3FB03FD3,$3FEB3FFA,$40003FFA,$3FEB3FD2,$3FB03F83 
		dc.l	$3F4E3F0C,$3EC43E6F,$3E143DAB,$3D3E3CC1,$3C413BB2 
		dc.l	$3B203A7E,$39DA3926,$387137AA,$36E4360C,$3536344D 
		dc.l	$3367326E,$3178306F,$2F6B2E53,$2D412C1A,$2AFA29C6 
		dc.l	$28992758,$261F24D2,$238E2235,$20E61F83,$1E2B1CBE 
		dc.l	$1B5C19E7,$187D1700,$158F140A,$12931109,$0F8C0DFC 
		dc.l	$0C7C0AE8,$096307CC,$064504AC,$03230189,$0000FE64 
		dc.l	$FCDCFB41,$F9BAF821,$F69CF506,$F383F1F1,$F073EEE5 
		dc.l	$ED6CEBE4,$EA70E8EF,$E782E608,$E4A3E331,$E1D4E06C 
		dc.l	$DF19DDBB,$DC71DB1E,$D9E0D899,$D766D62B,$D505D3D8 
		dc.l	$D2BED1A0,$D094CF84,$CE87CD86,$CC98CBA7,$CAC9C9E9 
		dc.l	$C91BC84C,$C78EC6D1,$C625C57A,$C4DFC446,$C3BEC338 
		dc.l	$C2C1C24F,$C1EBC18C,$C13BC0F0,$C0B1C07A,$C04FC02C 
		dc.l	$C014C005,$C000C005,$C014C02D,$C04FC07C,$C0B1C0F3 
		dc.l	$C13BC190,$C1EBC254,$C2C1C33E,$C3BEC44D,$C4DFC581 
		dc.l	$C625C6D9,$C78EC855,$C91BC9F3,$CAC9CBB2,$CC98CD91 
		dc.l	$CE87CF90,$D094D1AC,$D2BED3E5,$D505D639,$D766D8A7 
		dc.l	$D9E0DB2D,$DC71DDCA,$DF19E07C,$E1D4E341,$E4A3E618 
		dc.l	$E782E8FF,$EA70EBF5,$ED6CEEF6,$F073F203,$F383F517 
		dc.l	$F69CF833,$F9BAFB53,$FCDCFE76
		endr

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
		DS.W 2
scbuffer	REPT 16
		DS.B bufsize
		ENDR
		DS.W 2

mul_160		DS.L 384
plot_masks	DS.L 384
stars 		DS.L no_strs*2
humungus_table	DS.B 512*512

		DS.L 129
stack		DS.L 3	
		DS.B 460
screens		DS.B 256
		DS.B 58368
		DS.B 58368
