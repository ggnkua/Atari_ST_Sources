;-----------------------------------------------------------------------;
;                 Intro #3 For 'Awesome' Compacting Group		;
;          Coded by Griff of Electronic Images. 29/06/1991		;
;-----------------------------------------------------------------------;
; Some notes about this Intro Written for the truely awesome AWESOME!!	;
; - The First part is a starfield composed of 131 stars and 3d rotating ;
;   vector logo coupled with Digidrum Music. (Not My fastest routs!)	;
; - The second part is a simple picture + 48 line overscan scroller...  ;
;   However it also contains 8 khz NoiseTracker (full Volume variation)	;
;   on all four channels - this quite difficult to do with overscan!	;
;   + a little 8*8 scroller at the top of the screen which is rastered. ;
;-----------------------------------------------------------------------;
; (I would not advise using a module over 140k since it may not work on
;   1/2 meg machines....)

; The key definitions are down below somewhere!

intro		EQU 0
no_lines	EQU 47
linewid		EQU 104*4
bufsize		EQU no_lines*linewid 

		SECTION TEXT

		OPT O+,OW-
Start		BRA.W letsgo
env		DC.L 0
letsgo		MOVE.L SP,A5			; save sp
		MOVE.L SP,oldsp
		LEA stack,SP
		MOVE.L 4(A5),A5
		MOVE.L #300,-(SP)		; length to reserve
		MOVE.L A5,-(SP)			; addr to reserve from
		MOVE.L #$4A0000,-(SP)		; memory shrink
		TRAP #1				; gemdos
		LEA 12(SP),SP			; correct stack
		MOVE #4,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		CMP #2,D0			; hires?
		BEQ exitme			; yes then fuckoff to desktop
		MOVE D0,oldres
		CLR -(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14			; lowres
		LEA 12(SP),SP

		PEA maincode(PC)
		MOVE #38,-(SP)
		TRAP #14			; run the main bit
		ADDQ.L #6,SP 

		MOVE.L oldsp(PC),SP

		MOVE.W oldres(PC),-(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14			; restore res
		LEA 12(SP),SP

.clearmemory	LEA clearpal(PC),A0
		LEA end_of_code,A1
		MOVEQ #0,D0
.clearmem	MOVE.L D0,(A0)+
		CMP.L A0,A1
		BGT.S .clearmem

		PEA env(PC)			
		PEA env(PC)			
		MOVE.L (SP),-(SP)
		MOVE.L fileptr(PC),-(SP)	;ptr to path + filename
		MOVE.L #$4B0000,-(SP)		;p_exec
		TRAP #1		
		LEA 16(SP),SP
exitme		CLR -(SP)
		TRAP #1

; Here tis the main code...

maincode	MOVEM.L $FFFF8240.W,D0-D7
		MOVEM.L D0-D7,old_stuff		; save palette
		MOVE #$777,D7			; fade down screen
.lp1		MOVEQ #2,D6
.lp		MOVE #37,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		DBF D6,.lp
		MOVE.W D7,$FFFF8240.W
		SUB #$111,D7
		BPL.S .lp1
		MOVE #$2700,SR
		LEA old_stuff+32(PC),A0
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA0B.W,(A0)+
		MOVE.B $FFFFFA0D.W,(A0)+
		MOVE.B $FFFFFA0F.W,(A0)+
		MOVE.B $FFFFFA11.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.B $FFFFFA17.W,(A0)+
		MOVE.B $FFFFFA19.W,(A0)+
		MOVE.B $FFFFFA1B.W,(A0)+
		MOVE.B $FFFFFA1D.W,(A0)+
		MOVE.B $FFFFFA1F.W,(A0)+
		MOVE.B $FFFFFA21.W,(A0)+
		MOVE.B $FFFFFA23.W,(A0)+
		MOVE.B $FFFFFA25.W,(A0)+
		MOVE.L $68.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $110.W,(A0)+
		MOVE.L $114.W,(A0)+
		MOVE.L $120.W,(A0)+
		MOVE.L $134.W,(A0)+
		MOVE.L $FFFF8200.W,(A0)+
		BSR clearpal
		BSR Initscreens
		IFEQ intro
		JSR create160tb
		ENDC
		BSR flush
		CLR.B $FFFFFA07.W
		CLR.B $FFFFFA09.W
		CLR.B $FFFFFA13.W
		CLR.B $FFFFFA15.W
		BCLR.B #3,$fffffa17.W
		IFEQ intro
		MOVE.L #vect_vbl,$70.W
		MOVE.L #star_pal,pal_ptr
		IFEQ intro
		JSR Genstars
		ENDC

		MOVEQ #1,D0
		BSR music+4
		BSR music+8
		MOVE #$2300,SR			; go for first intro

vbwait1st	BTST.B #0,$fffffc00.w
		BEQ.S vbwait1st
		MOVE.B $fffffc02.w,d0
		CMP.B #$39+$80,d0		; space bar exits first intro
		BNE.S vbwait1st
		MOVE.W #8,fadeingO
.waitfadedown	TST fadeingO			; wait for fade out...
		BNE.S .waitfadedown		; Second part starts around about here!
		MOVE #$2700,SR
		ENDC
		MOVE.L #$08000000,$FFFF8800.W
		MOVE.L #$09000000,$FFFF8800.W
		MOVE.L #$0A000000,$FFFF8800.W
		MOVE.L #$0700FF00,$FFFF8800.W
		BSR clearpal
		BSR Initscreens
DELAY		MOVE.L #290000,D0
.lp		SUBQ.L #1,D0
		BNE.S .lp
		MOVE #18000,D0
		LEA big_buf,A0
.lp1		CLR.W (A0)+
		DBF D0,.lp1
		BSR Copypic
		MOVE.B #$1,$fffffa07.W
		MOVE.B #$10,$fffffa09.W
		MOVE.B #$1,$fffffa13.W
		MOVE.B #$10,$fffffa15.W
		CLR.B $FFFFFA1B.W
		CLR.B $fffffa19.W
		MOVE.L #my_vbl,$70.W
		MOVE.L #topbord_over,$110.w
		MOVE.L #piccy+2,pal_ptr
		BSR flush
		MOVEQ #1,D0
		JSR czimusic+28
		MOVE #$2300,SR				; lets go!

vbwait		BTST.B #0,$FFFFFC00.W
		BEQ.S vbwait 
		MOVE.B $fffffc02.w,d0

; Here are the Key definations......

CHECKKEY1	CMP.B #1+1,d0
		BLT vbwait
		CMP.B #NOKEYS+1,d0
		BGT vbwait

; Restore gem then Chain the selected file.

		MOVE #$2700,SR
		AND #$7F,D0
		SUBQ #2,D0
		ADD D0,D0
		ADD D0,D0
		LEA fileptrs(PC),A6
		MOVE.L (A6,D0),fileptr

DEMOOUT		LEA old_stuff(PC),A0
		MOVEM.L (A0)+,D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA0B.W
		MOVE.B (A0)+,$FFFFFA0D.W
		MOVE.B (A0)+,$FFFFFA0F.W
		MOVE.B (A0)+,$FFFFFA11.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.B (A0)+,$FFFFFA17.W
		MOVE.B (A0)+,$FFFFFA19.W
		MOVE.B (A0)+,$FFFFFA1B.W
		MOVE.B (A0)+,$FFFFFA1D.W
		MOVE.B (A0)+,$FFFFFA1F.W
		MOVE.B (A0)+,$FFFFFA21.W
		MOVE.B (A0)+,$FFFFFA23.W
		MOVE.B (A0)+,$FFFFFA25.W
		MOVE.L (A0)+,$68.W
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$110.W
		MOVE.L (A0)+,$114.W
		MOVE.L (A0)+,$120.W
		MOVE.L (A0)+,$134.W
		MOVE.L (A0)+,$FFFF8200.W
		MOVE.B #$C0,$FFFFFA23.W
		BSET.B #3,$FFFFFA17.W
		MOVEQ #0,D0
		JSR czimusic+28
		BSR flush
		MOVE #$2300,SR
		MOVE #37,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		RTS

old_stuff	DS.L 32
oldres		DS.W 1
oldsp		DC.L 0

fileptr		DC.L 0
fileptrs	DC.L filename1
		DC.L filename2
		DC.L filename3
		DC.L filename4
		DC.L filename5

; The filenames - change this to the names of the program
; you wish to run when each key is pressed i.e filname1 for key 1 !!!

NOKEYS		EQU  5					number of keys

filename1	DC.B "A:\ROBO.JIM",0
		EVEN
filename2	DC.B "A:\SPIN.JIM",0
		EVEN
filename3	DC.B "A:\GENST2.PRG",0
		EVEN
filename4	DC.B "A:\GAME4.PRG",0
		EVEN
filename5	DC.B "A:\GAME5.PRG",0
		EVEN

; Set all cols to zero and reset fade rout.

clearpal	lea $ffff8240.w,a0
		lea curr_pal(pc),a1
		moveq #0,d0
		moveq #7,d1
.lp		move.l d0,(a0)+
		move.l d0,(a1)+
		dbf d1,.lp
		move.w #7,fadeing
		move.w #4,fadeing1
		clr.w scrlflag
		rts

; Write D0 to IKBD

Write_ikbd	BTST.B #1,$FFFFFC00.W
		BEQ.S Write_ikbd
		MOVE.B D0,$FFFFFC02.W
		RTS

; Flush keyboard

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
flok		RTS


music		incbin a:\awesome.inc\wings2.mus
		even

; Init screens - screen allocation and clearing...

Initscreens	lea log_base(pc),a1
		move.l #screens+256,d0
		clr.b d0
		move.l d0,(a1)+
		add.l #44800,d0
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
		move #(44800/16)-1,d1
.cls		move.l d0,(a0)+
		move.l d0,(a0)+
		move.l d0,(a0)+
		move.l d0,(a0)+
		dbf d1,.cls
		rts

; Copy Picture to logical screens.

Copypic		lea piccy+34,A0
		move.l log_base(pc),a1
		lea 8*160(a1),a1
		move #7999,d0
		moveq #0,d1
.lp		move.l (a0),(a1)+
		move.l d1,(a0)+
		dbf d0,.lp
		rts

; The vbl - calls sequencer and vbl filler

my_vbl		clr.b $fffffa1d.w
		move.b #99,$fffffa25.w
		move.b #4,$fffffa1d.w
		clr.b $FFFFFA1B.w
		move.b #1,$FFFFFA21.w
		move.b #8,$FFFFFA1B.w
		move.l #hbl1,$120.w
		movem.l d0-d7/a0-a6,-(sp)
		movem.l curr_pal(pc),D0-D7
		movem.l D0-D7,$FFFF8240.W		; set piccy pal
		move.w #$333,$ffff8242.w
		move.w #$333,$ffff8250.w
		jsr czimusic+28+6
		bsr Bufscrl8
		bsr bufscrl
		bsr Fade_in				; fade in piccy
		movem.l (sp)+,d0-d7/a0-a6
		rte

topbord_over	CLR.B $FFFFFA1D.W
		MOVE.L #phbl2,$68.W
		MOVE #$2100,SR
		STOP #$2100
		MOVE.W #$2700,SR
		DCB.W 86,$4E71
		MOVE.B #0,$FFFF820A.W
		DCB.W 18,$4E71
		MOVE.B #2,$FFFF820A.W
		RTE

phbl2		RTE

hbl_cnt		DC.W 33

hbl1		move.w #$444,$ffff8242.w
		move.w #$444,$ffff8250.w
		move.l #hbl2,$120.w
		rte

hbl2		move.w #$555,$ffff8242.w
		move.w #$555,$ffff8250.w
		move.l #hbl3,$120.w
		rte

hbl3		move.w #$666,$ffff8242.w
		move.w #$666,$ffff8250.w
		move.l #hbl4,$120.w
		rte
hbl4		move.w #$777,$ffff8242.w
		move.w #$777,$ffff8250.w
		move.l #hbl5,$120.w
		rte
hbl5		move.w #$666,$ffff8242.w
		move.w #$666,$ffff8250.w
		move.l #hbl6,$120.w
		rte

hbl6		move.w #$555,$ffff8242.w
		move.w #$555,$ffff8250.w
		move.l #hbl7,$120.w
		rte
hbl7		move.w #$444,$ffff8242.w
		move.w #$444,$ffff8250.w
		move.l #hbl8,$120.w
		rte

hbl8		move.w curr_pal+2(pc),$ffff8242.w
		move.w curr_pal+16(pc),$ffff8250.w
		move.w #$2500,sr
		move.l #bot_bordover,$120.w
		clr.b $FFFFFA1B.W
		move.b #199,$FFFFFA21.W
		move.b #8,$FFFFFA1B.W
		rte

bot_bordover	MOVE.W #$2500,SR
		MOVEM.L D2-D3/A0-A6,-(SP)
		MOVE #$8209,A0
		MOVEQ #96,D2
.syncb		CMP.B (A0),D2
		BEQ.S .syncb
		MOVE.B (A0),D2
		LEA noplist-96(PC),A0
		JMP (A0,D2) 
noplist		DCB.W 81,$4E71 
		MOVE #$8240,A4
		LEA fontbuf+2,A5
		MOVE.L (A5)+,(A4)+
		MOVE.L (A5)+,(A4)+
		DCB.W 5,$4E71
		MOVE.B #2,$ffff8260.w
		MOVE.B #0,$ffff8260.w
		MOVE.L (A5)+,(A4)+
		MOVE.L (A5)+,(A4)+
		MOVE.L (A5)+,(A4)+
		MOVE.L (A5)+,(A4)+
		MOVE.L (A5)+,(A4)+
		MOVE.L (A5)+,(A4)+
		MOVE.L endbase(PC),A4
		MOVE.L endptr1(PC),A5
		MOVE.L endptr2(PC),A6
		DCB.W 87-42,$4E71	
 		MOVE.B #0,$ffff820a.w
		MOVE.B #2,$ffff820a.w	
		DCB.W 8,$4E71
		MOVE.B #1,$ffff8260.w
		MOVE.B #0,$ffff8260.w
i		SET 0
j		SET 0

do1end		MACRO
		MOVEP.L j(A5),D2
		MOVEP.L j(A6),D3
		MOVEP.L D2,i+200(A4)
		MOVEP.L D3,i+201(A4)
		MOVEP.L D2,i-8(A4)
		MOVEP.L D3,i-7(A4)
j		SET j+160
i		SET i+linewid
		ENDM

		REPT 20
		DCB.W 9,$4E71		
		MOVE.B #2,$ffff8260.w
		MOVE.B #0,$ffff8260.w
		do1end
		do1end
		DCB.W 87-72,$4E71	
 		MOVE.B #0,$ffff820a.w
		MOVE.B #2,$ffff820a.w	
		DCB.W 8,$4e71	
		MOVE.B #1,$ffff8260.w
		MOVE.B #0,$ffff8260.w
		ENDR

.botbord	DCB.W 5,$4E71
		MOVE.B #0,$ffff820a.w
		MOVE.B #2,$ffff8260.w
		MOVE.B #0,$ffff8260.w
		MOVE.B #2,$ffff820a.w
		do1end
		DCB.W 83-36,$4E71	
 		MOVE.B #0,$ffff820a.w
		MOVE.B #2,$ffff820a.w	
		DCB.W 8,$4e71	
		MOVE.B #1,$ffff8260.w
		MOVE.B #0,$ffff8260.w

		REPT 3
		DCB.W 9,$4E71		
		MOVE.B #2,$ffff8260.w
		MOVE.B #0,$ffff8260.w
		do1end
		do1end
		DCB.W 87-72,$4E71	
 		MOVE.B #0,$ffff820a.w
		MOVE.B #2,$ffff820a.w	
		DCB.W 8,$4e71	
		MOVE.B #1,$ffff8260.w
		MOVE.B #0,$ffff8260.w
		ENDR

		REPT 24
		DCB.W 9,$4E71		
		MOVE.B #2,$ffff8260.w
		MOVE.B #0,$ffff8260.w
		DCB.W 87,$4E71	
 		MOVE.B #0,$ffff820a.w
		MOVE.B #2,$ffff820a.w	
		DCB.W 8,$4e71	
		MOVE.B #1,$ffff8260.w
		MOVE.B #0,$ffff8260.w
		ENDR
		MOVEQ #0,D2
		MOVE #$8240,A0
		REPT 8
		MOVE.L D2,(A0)+
		ENDR
		MOVEM.L (SP)+,D2-D3/A0-A6
		RTE

; Fade in rout

Fade_in		TST fadeing
		BEQ nofade
		SUBQ #1,fadeing1
		BNE nofade
		MOVE #4,fadeing1
		SUBQ #1,fadeing
		LEA curr_pal(PC),A0
		MOVE.L pal_ptr(PC),A2
		MOVEQ #15,D4
col_lp		MOVE (A0),D0		reg value
		MOVE (A2)+,D1		dest value
		MOVE D0,D2
		MOVE D1,D3
		AND #$700,D2
		AND #$700,D3
		CMP D2,D3		
		BLE.S R_done
		ADD #$100,D0
R_done		MOVE D0,D2
		MOVE D1,D3
		AND #$070,D2
		AND #$070,D3
		CMP D2,D3
		BLE.S G_done
		ADD #$010,D0
G_done 		MOVE D0,D2
		MOVE D1,D3
		AND #$007,D2
		AND #$007,D3
		CMP D2,D3
		BLE.S B_done
		ADDQ #$001,D0
B_done		MOVE D0,(A0)+
		DBF D4,col_lp
		RTS
nofade		MOVE #-1,scrlflag
		RTS

pal_ptr		DC.L 0
curr_pal	DS.W 16
fadeing		DC.W 7
fadeing1	DC.W 4
scrlflag	DC.W 0

; Fade out rout

Fade_out	TST fadeingO
		BEQ nofade
		SUBQ #1,fadeingO1
		BNE nofade
		MOVE #4,fadeingO1
		SUBQ #1,fadeingO
		LEA curr_pal(PC),A0
		MOVE #$700,D5
		MOVEQ #$070,D6
		MOVEQ #$007,D1
		MOVEQ #15,D4
.col_lp		MOVE (A0),D0		reg value
		MOVE D0,D2
		AND D5,D2
		BEQ.S .R_done
		SUB #$100,D0
.R_done		MOVE D0,D2
		AND D6,D2
		BEQ.S .G_done
		SUB #$010,D0
.G_done 	MOVE D0,D2
		AND D1,D2
		BEQ.S .B_done
		SUBQ #$001,D0
.B_done		MOVE D0,(A0)+
		DBF D4,.col_lp
.nofade		RTS

fadeingO	DC.W 0
fadeingO1	DC.W 4

log_base	DC.L 0
phy_base	DC.L 0
switch		DC.W 0

; Buffer Scroll Routine By Griff Nov 1990. (20% cpu time)

bufscrl		TST.B delay_timer		; has scroller stopped?
		BEQ.S .notstopped
		SUBQ.B #1,delay_timer
		BEQ.S .notstopped		; countdown....
		RTS
.notstopped	LEA scr_point(PC),A6
		MOVE.L (A6)+,A0			; curr text ptr
		MOVE.L (A6)+,A3			; curr pix buffer ptr
		MOVE (A6),D5			; pixel offset
		LEA bufsize(A3),A3
		ADDQ #8,D5			; add 8(8 pixel step)
		CMP #16,D5			; end of chunk?
		BNE.S .pos_ok			; no then skip
		ADDQ.W #8,scrlpos		; onto next chunk 
		CMP #208,scrlpos		; in pix buffer.
		BNE.S .nowrapscr		; reached end of buffer?		
		CLR scrlpos			; if yes reset buffer position
.nowrapscr	LEA scbuffer,A3			; reset pixel chunk offset
		MOVEQ #0,D5			; + pix position
		ADDQ #8,inletswitch		; font is 64 wide
		CMP.W #3*8,inletswitch
		BNE.S .pos_ok 			; so there are two chunks
		CLR inletswitch
		ADDQ.L #1,A0			; after 64 pixs,next letter...
.pos_ok		MOVEQ #0,D0
		CMP.B #'s',(A0)
		BNE.S .notstop
		MOVE.B 1(A0),delay_timer	; move delay
		ADDQ.L #2,A0			; skip past chars!!
.notstop	TST.B 1(A0)	
		BNE.S .notwrap			; end of text?
		LEA text(PC),A0			; yes restart text
.notwrap	MOVE D5,(A6)			; otherwise restore
		MOVE.L A3,-(A6)			
		MOVE.L A0,-(A6)			
		MOVEQ #0,D0
		MOVE.B (A0)+,D0
		SUB.B #32,D0			; normalise asci char
		ADD D0,D0
		ADD D0,D0
		LEA CHARDAT,A6
		MOVE.L (A6,D0),A6
		MOVE.W inletswitch(PC),D1
		ADDA.W D1,A6
		LEA 8(A6),A4			; point to 2nd chunk
		CMP #2*8,D1			; are we in 2nd chunk
		BNE.S .norm 			; already?
		MOVEQ #0,D0			; 1st chunk of next char
		MOVE.B (A0),D0			; must be plotted
		CMP.B #'s',D0
		BNE.S .notcon
		MOVEQ #32,D0
.notcon		SUB.B #32,D0
		ADD D0,D0
		ADD D0,D0
		LEA CHARDAT,A4         
		MOVE.L (A4,D0),A4

.norm		ADD scrlpos(PC),A3
		CMP #8,D5			; small optimisation
		BGE morethan8
		MOVE.L A6,endptr1
		LEA 1(A6),A6
		MOVE.L A6,endptr2
		BRA copy_buf

morethan8	LEA 1(A6),A6
		MOVE.L A6,endptr1
		MOVE.L A4,endptr2

copy_buf	MOVE.L A3,endbase
		MOVE.L which_buf(PC),A0
		ADD scrlpos(PC),A0
		MOVE.L log_base(PC),A2		; screen base
		ADD.L #(208*160)+460+8,A2

		MOVEQ #no_lines-1,D7
.draw_lp	MOVEM.L (A0)+,D0-D5/A3-A6
		MOVEM.L D0-D5/A3-A6,(A2)
		MOVEM.L (A0)+,D0-D5/A3-A6
		MOVEM.L D0-D5/A3-A6,40(A2)
		MOVEM.L (A0)+,D0-D5/A3-A6
		MOVEM.L D0-D5/A3-A6,80(A2)	; ZAP onto screen!
		MOVEM.L (A0)+,D0-D5/A3-A6
		MOVEM.L D0-D5/A3-A6,120(A2)
		MOVEM.L (A0)+,D0-D5/a3-a6
		MOVEM.L D0-D5/a3-a6,160(A2)
		LEA linewid-200(a0),a0
		LEA 230(A2),A2
		DBF D7,.draw_lp
		RTS
endptr1		DC.L screens+256+(208*160)+460+8
endptr2		DC.L screens+256+(208*160)+460+8
endbase		DC.L scbuffer
scr_point	DC.L text
which_buf	DC.L scbuffer
scx		DC.W 0
scrlpos		DC.W 0
inletswitch	DC.W 0
delay_timer	DC.W 0

; Hi James, Type you text here. Type 's' followed by delay in seconds * 50 
; e.g to stop scroller for 3 seconds you would type :-
; DC.B "FUCK MY ARSE!","s",50*3      ;the maximum delay is five seconds!

text		dc.b " WELCOME TO.......  AWESOME    CD 4  s",3*50,"  .......HOPE YOU LIKE THIS JAMES... BYE BYE..    "

		dc.b 0
		EVEN

;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;
; 8*8 Buffer Scroller Routine.... takes hardly any cpu time...		;
;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;

b8scrlspeed	EQU 2

b8nolines	EQU 8
b8linewid	EQU 84
b8bufsize	EQU b8nolines*b8linewid

Bufscrl8	MOVE.L b8sc_scr_point(PC),A0	;curr text ptr
		MOVE.L b8sc_which_buf(PC),A3	;curr pix buffer ptr
		MOVE b8sc_scx(PC),D2		;pixel offset
		LEA b8bufsize*b8scrlspeed(A3),A3 ;skip 2 buffers(2 pix step)	
		ADDQ #b8scrlspeed,D2		;add 2(2 pixel step)
		CMP #16,D2			;end of chunk?
		BNE.S .pos_ok			;no then skip
		ADDQ.W #2,b8sc_scrlpos		;onto next chunk 
		CMP #b8linewid/2,b8sc_scrlpos	;in pix buffer.
		BNE.S .nowrapscr		;reached end of buffer?		
		CLR b8sc_scrlpos		;if yes reset buffer position
.nowrapscr	LEA b8sc_scbuffer,A3		;reset pixel chunk offset
		MOVEQ #0,D2			;+ pix position
		ADDQ.L #2,A0			;after 32 pixs,next letter...
.pos_ok		TST.B 1(A0)	
		BNE.S .notwrap			;end of text?
		LEA b8sc_text(PC),A0		;yes restart text
.notwrap	MOVE D2,b8sc_scx		;otherwise restore
		MOVE.L A3,b8sc_which_buf
		MOVE.L A0,b8sc_scr_point
		MOVEQ #0,D0
		MOVEQ #0,D1
		MOVE.B (A0)+,D0
		MOVE.B (A0),D1
		LEA smllfont(PC),A0  		;character addr    
		LEA (A0),A2
		SUB.B #32,D0			;normalise asci char
		SUB.B #32,D1			
		LSL #3,D0              		;*64 font offset
		LSL #3,D1              		
		ADDA.W D0,A0
		ADDA.W D1,A2
		ADD b8sc_scrlpos(PC),A3
		MOVEQ #b8nolines-1,D0
.addin		MOVEQ #0,D3
		MOVE.B (A0)+,D3
		LSL #8,D3 
		MOVE.B (A2)+,D3 
		ROL.L D2,D3
		MOVE.W D3,-2(A3)
		MOVE.W D3,(b8linewid/2)-2(A3)
		SWAP D3
		OR.W D3,-4(A3)
		OR.W D3,(b8linewid/2)-4(A3)
		SWAP D3
i		SET 0
		REPT b8scrlspeed-1
i		SET i+b8bufsize
		ROL.L #1,D3
		MOVE.W D3,-2+i(A3)
		MOVE.W D3,(b8linewid/2)-2+i(A3)
		SWAP D3
		OR.W D3,-4+i(A3)
		OR.W D3,(b8linewid/2)-4+i(A3)
		ENDR
		LEA b8linewid(A3),A3
		DBF D0,.addin
		
.copy_buf	MOVE.L log_base(PC),A0	screen base
		ADDQ.L #6,A0
		MOVE.L b8sc_which_buf(pc),A2
		ADD b8sc_scrlpos(PC),A2
		MOVEQ #b8nolines-1,D0
.copy_lp	MOVE.L (A2)+,(A0)
		MOVE.L (A2)+,16(A0)
		MOVE.L (A2)+,32(A0)
		MOVE.L (A2)+,48(A0)
		MOVE.L (A2)+,64(A0)
		MOVE.L (A2)+,80(A0)
		MOVE.L (A2)+,96(A0)
		MOVE.L (A2)+,112(A0)
		MOVE.L (A2)+,128(A0)
		MOVE.L (A2)+,144(A0)
		LEA b8linewid-40(A2),A2
		LEA 160(A0),A0
		DBF D0,.copy_lp
		RTS

b8sc_scr_point	DC.L b8sc_text
b8sc_which_buf	DC.L b8sc_scbuffer
b8sc_scx	DC.W 0
b8sc_scrlpos	DC.W 0
b8sc_finbarr	DC.W 0

b8sc_text	dc.b "              YO! JAMES YOU LAMER!!!!  THIS MUSIC WAS DONE BY COUNT ZERO IN A FEW HOURS AT THE TLT CONVENTION IN SWEDEN.... HOPE YA LIKE IT..... NEVER USED BEFORE... SO YOU HAVE A GREAT HONOUR....                "
		dc.b 0,0

		EVEN

smllfont	dc.l	$00000000,$00000000,$1C1C1C1C,$1C001C1C,$00666666 
		dc.l	$00000000,$0066FF66,$66FF6600,$183E603C,$067C1800 
		dc.l	$3033060C,$18306606,$1C361C38,$6F663B00,$38381830 
		dc.l	$00000000,$0C183030,$3030180C,$30180C0C,$0C0C1830 
		dc.l	$00663CFF,$3C660000,$0018187E,$18180000,$00000000 
		dc.l	$1C1C1C30,$0000007E,$00000000,$00000000,$1C1C1C00 
		dc.l	$03060C18,$3060C080,$003C7E66,$667E3C00,$18387818 
		dc.l	$18187C00,$78CC660C,$30627E00,$7C664C18,$06C37F00 
		dc.l	$0C1C3C6C,$CCFE0C00,$3E303C06,$06E67C00,$0E38E0DC 
		dc.l	$C6C67C00,$FC8C1830,$60606000,$7CC6F65C,$C6C67C00 
		dc.l	$78CCC67E,$060C7800,$38383800,$38383800,$38383800 
		dc.l	$38383870,$060C1830,$180C0600,$00007E00,$007E0000 
		dc.l	$6030180C,$18306000,$003C660C,$18001800,$003C666E 
		dc.l	$6E603E00,$E070786C,$667E67E0,$00FC667C,$666343FE 
		dc.l	$1C366660,$60666C78,$00F84C66,$66664EFC,$00FC4470 
		dc.l	$6062FE00,$00FE6278,$6060F000,$1C3662C0,$C0DFCC78 
		dc.l	$E067667E,$6666E607,$7E5A1818,$185A7E00,$7E180C0C 
		dc.l	$C6663E00,$E0666C78,$786CE603,$F0606060,$6663FE00 
		dc.l	$E0667E7E,$6666E607,$E066767E,$6E66E607,$007E4666 
		dc.l	$66667E00,$00FC4666,$7C6060E0,$007E4666,$66647E07 
		dc.l	$00FC4666,$7C6CE603,$003E3238,$1C8E86FE,$FEB2B030 
		dc.l	$30303860,$00E06766,$66667E00,$E0616366,$6C787060 
		dc.l	$E0666666,$7E7E6600,$E067361C,$386CE607,$C3E7663C 
		dc.l	$1818D870,$00FE8C18,$3062FE00,$003E3838,$38383E00 
		dc.l	$80C06030,$180C0603,$007C1C1C,$1C1C7C00,$00183C7E 
		dc.l	$18181818,$00000000,$0000FF00,$0C181C1C,$00000000 
		dc.l	$0000007C,$CCCC7F00,$00E0607C,$6666FC00,$0000003C 
		dc.l	$60603C00,$000E0C7C,$CCCC7600,$00003C66,$7E603E00 
		dc.l	$0E1A1818,$3E181878,$00063C66,$663E607E,$E060607C 
		dc.l	$6666E700,$00180038,$18183C00,$0006000E,$0606663C 
		dc.l	$00E0606C,$786CE603,$38181818,$18181C00,$0000C07E 
		dc.l	$6A6A6B00,$0000C07C,$6666F700,$0000003C,$66663C00 
		dc.l	$0000FC66,$667C60E0,$00007ECC,$CC7C0C0E,$0000DC66 
		dc.l	$6060F000,$00007E62,$18067E00,$0000187E,$18180E00 
		dc.l	$0000EE66,$66663B00,$0000E762,$74381000,$0000C6D6 
		dc.l	$FE7C6C00,$0000663C,$183C6600,$00006666,$663E067C 
		dc.l	$00007E4C,$18327E00,$00183C7E,$7E183C00,$18181818 
		dc.l	$18181818,$00000018,$18000000,$08183878,$38180800 

		IFEQ intro

; Vbl for little vector intro

no_strs		EQU 131

vect_vbl	MOVE.L D0,-(SP)
		MOVEM.L curr_pal,D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		LEA log_base,A0
		MOVEM.L (A0)+,D0-D1
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR #8,D1
		MOVE.L D1,$FFFF8200.W
		JSR Fade_in
		JSR Fade_out
		JSR music
		BSR Clearstars
		BSR Plotstars
		BSR clear1plscreen
		LEA AWESOME,A5
		JSR Show_obj	
		MOVE.L (SP)+,D0
		RTE

star_pal	DC.W $000,$777,$555,$000,$333,$000,$000,$000
		DC.W $777,$777,$777,$777,$777,$777,$777,$777

; Clear last plane of screen - reasonably quickly...

clear1plscreen	MOVE.L log_base,A0
		ADDQ.L #6,A0
		MOVEQ #0,D1
		MOVEQ #24,D0
i		SET 0
.lp		REPT 160
		MOVE.W D1,i(A0)
i		SET i+8
		ENDR
		LEA 1280(A0),A0
		DBF D0,.lp
		RTS

; Clear the stars.

Clearstars	MOVE.L log_base,A0
		MOVEQ #0,D0
		NOT frameswitch
		BNE .cse2
.cse1		MOVE.L #.a1,which_old
.a1	
		REPT no_strs
		MOVE.W D0,2(A0)
		ENDR
		RTS
.cse2		MOVE.L #.b1,which_old
.b1	
		REPT no_strs
		MOVE.W D0,2(A0)
		ENDR
		RTS

; Plot those darn stars!

Plotstars	MOVE.L log_base,A0
		LEA offsets,A1
		MOVE.L which_old(PC),A5
		MOVE.L (A5),D5
draw1		MOVE.L (A1),A2		
		MOVE.W (A2)+,D5		
		BGE.S .restart
		MOVE.L no_strs*4(A1),A2	
		MOVE.W (A2)+,D5		
.restart	MOVE.W (A2)+,D4
		OR.W D4,(A0,D5)
		MOVE.L A2,(A1)+		
		MOVE.L D5,(A5)+		
enddraw1	DS.B (no_strs-1)*(enddraw1-draw1)
		RTS

; This bit generates a big table of numbers which are co-ords
; for every star position. Memory wasting but quite fast. 

Genstars	LEA big_buf,A0
		LEA stars,A1		star co-ords
		LEA offsets,A2
		LEA res_offsets,A3
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
		MOVE.W D1,(A0)+
		ASR #6,D2
		TST D2
		BLE.S white
		CMP #1,D2
		BEQ.S white
		CMP #2,D2
		BEQ.S c2
c1		ADDQ #4,-4(A0)
		BRA thisstar_lp
white		BRA thisstar_lp
c2		ADDQ #2,-4(A0)
		BRA thisstar_lp
Star_off	MOVE.L #-1,(A0)+
		DBF D7,genstar_lp
Randoffsets	LEA offsets,A0
		LEA seed,A2
		MOVE #no_strs-2,D7
rands		MOVEM.L (A0),D0/D1
		SUB.L D0,D1
		DIVU #4,D1
		MOVEQ #0,D2
		MOVE (A2),D2		
		ROL #1,D2			
		EOR #54321,D2
		SUBQ #1,D2		
		MOVE D2,(A2)	
		DIVU D1,D2						
		CLR.W D2
		SWAP D2
		MULU #4,D2
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

frameswitch	DC.W 0
which_old	DC.L 0
stars		INCBIN a:\awesome.inc\rand_131.xyz
seed		DC.W $9753

; Create *160 table

create160tb	LEA mul_tab(PC),A0
		MOVEQ #0,D0					;create *160 table
		MOVE #199,D1
mke_t160_lp	MOVE D0,(A0)+
		ADD #160,D0
		DBF D1,mke_t160_lp
		RTS

;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;
; Routine to transform and draw a 3 dimensional Vectorline object.	;
; On entry:A5 points to shape data of shape to draw.				;
; On exit:D0-D7/A0-A6 Smashed!							;
;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;

; Calculate a rotational matrix,from the angle data pointed by A5.
; D0-D4/A0-A1 smashed.(of no consequence since we only need to keep A5)

Show_obj	LEA seqdata(PC),A3
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
		MOVE.W (A1)+,zspeed
		MOVE.L A1,seq_ptr(A3)
.nonew		LEA trig_tab(pc),A0		; sine table
		LEA 512(A0),A2			; cosine table
		MOVEM.W (A5)+,D5-D7    		; get current x,y,z ang	
		ADD addangx(A3),D5
		ADD addangy(A3),D6		; add increments
		ADD addangz(A3),D7
		AND #$7FE,D5
		AND #$7FE,D6
		AND #$7FE,D7
		MOVEM.W D5-D7,-6(A5)   	
		MOVE (A0,D5),D0			sin(xd)
		MOVE (A2,D5),D1			cos(xd)
		MOVE (A0,D6),D2			sin(yd)
		MOVE (A2,D6),D3			cos(yd)
		MOVE (A0,D7),D4			sin(zd)
		MOVE (A2,D7),D5			cos(zd)
		LEA M11+2(PC),A1
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
		MOVE D6,M21-M11(A1)
* Matrix(3,1) -cosz*sinx
		MOVE D5,D6			cosz
		MULS D0,D6			cosz*sinx
		ADD.L D6,D6
		SWAP D6
		NEG D6				-cosz*sinx
		MOVE D6,M31-M11(A1)
* Matrix(1,2) -siny*cosz
		MOVE D2,D6			siny
		MULS D5,D6			siny*cosz
		ADD.L D6,D6
		SWAP D6
		NEG D6				-siny*cosz
		MOVE D6,M12-M11(A1)
* Matrix(2,2) cosy*cosz		
		MOVE D3,D6			cosy
		MULS D5,D6			cosy*cosz
		ADD.L D6,D6
		SWAP D6
		MOVE D6,M22-M11(A1)
* Matrix(3,2) sinz 
		MOVE D4,M32-M11(A1)
* Matrix(1,3) cosy*sinx+siny*sinz*cosx
		MOVE D3,D6			cosy
		MULS D0,D6			cosy*sinx
		MOVE A4,D7			sinz*cosx
		MULS D2,D7
		ADD.L D7,D6
		ADD.L D6,D6
		SWAP D6				siny*(sinz*cosx)
		MOVE D6,M13-M11(A1)
* Matrix(2,3) siny*sinx-cosy*sinz*cosx
		MULS D0,D2			siny*sinx
		MOVE A4,D7
		MULS D3,D7
		SUB.L D7,D2 
		ADD.L D2,D2
		SWAP D2
		MOVE D2,M23-M11(A1)
* Matrix(3,3) cosz*cosx
		MULS D1,D5 
		ADD.L D5,D5
		SWAP D5				cosz*cosx
		MOVE D5,M33-M11(A1)

; Transform and perspect co-ords.
; A5 -> x,y,z.w offsets for co-ords,D7 source co-ords x,y,z.w
; A1 -> to a storage place for the resultant x,y co-ords.
; D0-D7/A0-A4 smashed.

		MOVE (A5)+,D7			;get no of verts
		LEA new_coords(PC),A1		;storage place new x,y co-ords
		MOVE.L zspeed(PC),D6
Trans_verts	;MOVE.L (A5)+,addoffx+2
		;MOVE.L (A5)+,addoffy+2
		ADDQ.L #8,A5
		ADD.L D6,(A5)
		MOVE.L (A5)+,addoffz+2		;(after this a5-> d7 x,y,z co-ords
		MOVEA #160,A3			;centre x
		MOVEA #100,A4			;centre y
		SUBQ #1,D7			;verts-1
trans_lp	MOVEM.W (A5)+,D0-D2		;x,y,z
		MOVE D0,D3	
		MOVE D1,D4			;dup
		MOVE D2,D5
; Calculate x co-ordinate		
M11		MULS #0,D0			
M21		MULS #0,D4			;mat mult
M31		MULS #0,D5
		ADD.L D4,D0
		ADD.L D5,D0
		MOVE D3,D6
		MOVE D1,D4
		MOVE D2,D5
; Calculate y co-ordinate		
M12		MULS #0,D3
M22		MULS #0,D1			;mat mult
M32		MULS #0,D5
		ADD.L D3,D1
		ADD.L D5,D1
; Calculate z co-ordinate
M13		MULS #0,D6
M23		MULS #0,D4			;mat mult
M33		MULS #0,D2
		ADD.L D6,D2
		ADD.L D4,D2
; Combine and Perspect
addoffz		ADD.L #0,D2
		ADD.L D2,D2
		SWAP D2
		ASR.L #8,D0
		ASR.L #8,D1
		DIVS D2,D0
		DIVS D2,D1
		ADD A3,D0			;x scr centre
		ADD A4,D1			;y scr centre
		MOVE D0,(A1)+			;new x co-ord
		MOVE D1,(A1)+			;new y co-ord
		DBF D7,trans_lp
; A5 -> total no of lines to draw. 
drawlines	MOVE (A5)+,D7
		SUBQ #1,D7
; A5 -> line list
		MOVE.L log_base,A1
		LEA bit_offs(PC),A2
		LEA mul_tab(PC),A3
		LEA new_coords(PC),A6		co-ords
drawline_lp	MOVE (A5)+,D1			;1st offset to vertex list
		MOVE (A5)+,D2			;2nd offset to vertex list
		MOVEM (A6,D1),D0-D1		;get x1,y1
		MOVEM (A6,D2),D2-D3		;"  x2,y2

xmax		EQU 319
ymax		EQU 199

;-----------------------------------------------------------------------;
; Routine to draw a 1 plane line,the line is clipped if necessary.	;
; D0-D3 holds x1,y1/x2,y2 A1 -> screen base. A2 -> x bit+chunk lookup	;
; D0-D6/A0 smashed.       A3 -> * 160 table				;
;-----------------------------------------------------------------------;

Drawline	MOVE.L A1,A0
clipony		CMP.W D1,D3			; y2>=y1?(Griff superclip)!
		BGE.S y2big
		EXG D1,D3			; re-order
		EXG D0,D2
y2big		TST D3				; CLIP ON Y
		BLT	nodraw			; totally below window? <ymin
		CMP.W #ymax,D1
		BGT	nodraw			; totally above window? >ymax
		CMP.W #ymax,D3			; CLIP ON YMAX
		BLE.S okmaxy			; check that y2<=ymax 
		MOVE #ymax,D5
		SUB.W	D3,D5			; ymax-y
		MOVE.W D2,D4
		SUB.W	D0,D4			; dx=x2-x1
		MULS	D5,D4			; (ymax-y)*(x2-x1)
		MOVE.W D3,D5
		SUB.W	D1,D5			; dy
		DIVS	D5,D4			; (ymax-y)*(x2-x1)/(y2-y1)
		ADD.W	D4,D2
		MOVE #ymax,D3			; y1=0
okmaxy		TST.W	D1			; CLIP TO YMIN
		BGE.S cliponx
		MOVEQ #0,D5
		SUB.W	D1,D5			; ymin-y
		MOVE.W D2,D4
		SUB.W	D0,D4			; dx=x2-x1
		MULS	D5,D4			; (ymin-y1)*(x2-x1)
		MOVE.W D3,D5
		SUB.W	D1,D5			; dy
		DIVS	D5,D4			; (ymin-y)*(x2-x1)/(y2-y1)
		ADD.W	D4,D0
		MOVEQ #0,D1			; y1=0
cliponx		CMP.W	D0,D2			; CLIP ON X				
		BGE.S	x2big
		EXG	D0,D2			; reorder
		EXG	D1,D3
x2big		TST.W	D2			; totally outside <xmim
		BLT	nodraw
		CMP.W #xmax,D0			; totally outside >xmax
		BGT	nodraw
		CMP.W #xmax,D2			; CLIP ON XMAX
		BLE.S	okmaxx	
		MOVE.W #xmax,D5
		SUB.W	D2,D5			; xmax-x2
		MOVE.W D3,D4
		SUB.W	D1,D4			; y2-y1
		MULS D5,D4			; (xmax-x1)*(y2-y1)
		MOVE.W D2,D5
		SUB.W	D0,D5			; x2-x1
		DIVS D5,D4			; (xmax-x1)*(y2-y1)/(x2-x1)
		ADD.W	D4,D3
		MOVE.W #xmax,D2
okmaxx		TST.W	D0
		BGE.S	.gofordraw
		MOVEQ #0,D5			; CLIP ON XMIN
		SUB.W	D0,D5			; xmin-x
		MOVE.W D3,D4
		SUB.W	D1,D4			; y2-y1
		MULS D5,D4			; (xmin-x)*(y2-y1)
		MOVE.W D2,D5
		SUB.W	D0,D5			; x2-x1
		DIVS D5,D4			; (xmin-x)*(y2-y1)/(x2-x1)
		ADD.W	D4,D1
		MOVEQ #0,D0			; x=xmin
.gofordraw	MOVE.W D2,D4
		SUB.W	D0,D4			; dx
		MOVE.W D3,D5
		SUB.W	D1,D5			; dy
		ADD D2,D2
		ADD D2,D2
		MOVE.L (A2,D2),D6		; mask/chunk offset
		ADD D3,D3
		ADD (A3,D3),D6			; add scr line
		ADDA.W D6,A0			; a0 -> first chunk of line
		SWAP D6				; get mask
		MOVE.W #-160,D3
		TST.W	D5			; draw from top to bottom?
		BGE.S	bottotop
		NEG.W	D5			; no so negate vals
		NEG.W	D3
bottotop	CMP.W	D4,D5			; dy>dx?
		BLT.S	dxbiggerdy

; DY>DX Line drawing case

dybiggerdx	MOVE.W D5,D1			; yes!
		BEQ nodraw			; dy=0 nothing to draw(!)
		ASR.W	#1,D1			; e=2/dy
		MOVE.W D5,D2
		SUBQ.W #1,D2			; lines to draw-1(dbf)
.lp		OR.W D6,(A0)
		ADDA.W D3,A0
		SUB.W	D4,D1
		BGT.S	.nostep
		ADD.W	D5,D1
		ADD.W	D6,D6
		DBCS D2,.lp
		BCC.S .drawn
		SUBQ.W #8,A0
		MOVEQ	#1,D6
.nostep		DBF D2,.lp
.drawn		OR.W	D6,(A0)
nodraw		DBF D7,drawline_lp
		RTS

; DX>DY Line drawing case

dxbiggerdy	CLR.W	D2
		MOVE.W D4,D1
		ASR.W	#1,D1			; e=2/dx
		MOVE.W D4,D0
		SUBQ.W #1,D0
.lp		OR.W	D6,D2
		SUB.W	D5,D1
		BGE.S	.nostep
		OR.W D2,(A0)
		ADDA.W D3,A0
		ADD.W	D4,D1
		CLR.W	D2
.nostep		ADD.W	D6,D6
		DBCS	D0,.lp
		BCC.S	.drawn
.wrchnk		OR.W	D2,(A0)
		SUBQ.W #8,A0
		CLR.W	D2
		MOVEQ	#1,D6
		DBF	D0,.lp
.drawn		OR.W D6,D2
		OR.W	D2,(A0)
		DBF D7,drawline_lp
		RTS

		SECTION DATA

i		SET 6
bit_offs	REPT 20
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

new_coords	DS.W 200

zspeed		dc.l 0

; Sequence data 
		
		RSRESET

seq_timer	RS.W 1
seq_ptr		RS.L 1
addangx		RS.W 1
addangy		RS.W 1
addangz		RS.W 1
restart_ptr	RS.L 1

seqdata		DC.W 1
		DC.L sequence 
		DS.W 3
		DC.L restart

sequence	DC.W 140,8,0,0,-30
restart		DC.W 128,12,0,0,0
		DC.W 256,12,0,12,0
		DC.W 512,12,2,12,0
		DC.W -1

AWESOME		Dc.W 0,1024,0
		DC.W 31
		DC.L 0,0,$1200*65536
.aP		DC.W -700,-100,0
		DC.W -500,100,0
		DC.W -500,-100,0
		DC.W -500,0,0  
		DC.W -600,0,0
.wP		DC.W -440,-100,0
		DC.W -400,0,0
		DC.W -360,-100,0
		DC.W -300,100,0
.eP		DC.W -100,100,0
		DC.W -300,40,0
		DC.W -200,0,0
		DC.W -300,-40,0
		DC.W -100,-100,0
.sP		DC.W 100,-40,0
		DC.W -100,40,0
		DC.W 100,100,0
.oP		DC.W 100,0,0
		DC.W 200,100,0
		DC.W 300,0,0
		DC.W 200,-100,0		 
.mP		DC.W 300,-100,0
		DC.W 360,100,0
		DC.W 400,0,0
		DC.W 440,100,0
		DC.W 500,-100,0
.eEP		DC.W 500,100,0
		DC.W 540,100,0
		DC.W 500,0,0
		DC.W 600,0,0
		DC.W 700,-100,0
		DC.W 26
.al		DC.W 00*4,01*4 
		DC.W 01*4,02*4
		DC.W 03*4,04*4
.wl		DC.W 01*4,05*4
		DC.W 05*4,06*4
		DC.W 06*4,07*4
		DC.W 07*4,08*4
.el		DC.W 09*4,10*4
		DC.W 10*4,11*4
		DC.W 11*4,12*4
		DC.W 12*4,13*4
.sl		DC.W 13*4,14*4
		DC.W 14*4,15*4
		DC.W 15*4,16*4
.ol		DC.W 17*4,18*4
		DC.W 18*4,19*4
		DC.W 19*4,20*4
		DC.W 20*4,17*4
.ml		DC.W 21*4,22*4
		DC.W 22*4,23*4
		DC.W 23*4,24*4
		DC.W 24*4,25*4
.eEl		DC.W 25*4,26*4
		DC.W 26*4,27*4
		DC.W 28*4,29*4
		DC.W 25*4,30*4

mul_tab		DS.W 200
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
		ENDC

;-----------------------------------------------------------------------;
piccy		INCBIN A:\AWESOME.INC\PICCY.PI1
		EVEN
CHARDAT		DC.L	FONTDAT2+(160*48*3)+(24*2)	;SPACE
		DC.L	FONTDAT2+(160*48*2)+(24*4)	;!
		DC.L	FONTDAT2+(160*48*2)+(24*5)	;"
		DC.L	FONTDAT2+(160*48*3)+(24*2)	;SPACE
		DC.L	FONTDAT2+(160*48*3)+(24*2)	;SPACE
		DC.L	FONTDAT2+(160*48*3)+(24*2)	;SPACE
		DC.L	FONTDAT2+(160*48*3)+(24*2)	;SPACE
		DC.L	FONTDAT2+(160*48*2)+(24*6)	;'
		DC.L	FONTDAT2+(160*48*3)+(24*0)	;(
		DC.L	FONTDAT2+(160*48*3)+(24*1)	;)
		DC.L	FONTDAT2+(160*48*3)+(24*2)	;SPACE
		DC.L	FONTDAT2+(160*48*3)+(24*2)	;SPACE
		DC.L	FONTDAT2+(160*48*2)+(24*0)	;,
		DC.L	FONTDAT2+(160*48*2)+(24*1)	;-
		DC.L	FONTDAT2+(160*48*1)+(24*5)	;.
		DC.L	FONTDAT2+(160*48*3)+(24*2)	;SPACE
		DC.L	FONTDAT2+(160*48*3)+(24*4)	;0 (ACTUALLY O)
		DC.L	FONTDAT2+(160*48*0)+(24*2)	;1
		DC.L	FONTDAT2+(160*48*0)+(24*3)	;2
		DC.L	FONTDAT2+(160*48*0)+(24*4)	;3
		DC.L	FONTDAT2+(160*48*0)+(24*5)	;4
		DC.L	FONTDAT2+(160*48*1)+(24*0)	;5
		DC.L	FONTDAT2+(160*48*1)+(24*1)	;6
		DC.L	FONTDAT2+(160*48*1)+(24*2)	;7
		DC.L	FONTDAT2+(160*48*1)+(24*3)	;8
		DC.L	FONTDAT2+(160*48*1)+(24*4)	;9
		DC.L	FONTDAT2+(160*48*2)+(24*2)	;:
		DC.L	FONTDAT2+(160*48*2)+(24*3)	;;
		DC.L	FONTDAT2+(160*48*3)+(24*2)	;SPACE
		DC.L	FONTDAT2+(160*48*3)+(24*2)	;SPACE
		DC.L	FONTDAT2+(160*48*3)+(24*2)	;SPACE
		DC.L	FONTDAT2+(160*48*3)+(24*3)	;?
		DC.L	FONTDAT2+(160*48*3)+(24*2)	;SPACE
ADD		SET	0			;LETTERS A-X
		REPT	4
		DC.L	FONTDAT+ADD
		DC.L	FONTDAT+ADD+24
		DC.L	FONTDAT+ADD+48
		DC.L	FONTDAT+ADD+72
		DC.L	FONTDAT+ADD+96
		DC.L	FONTDAT+ADD+120
ADD		SET	ADD+160*48
		ENDR
		DC.L	FONTDAT2			;Y
		DC.L	FONTDAT2+24		;Z

fontbuf		
FONTBIN		INCBIN	A:\PICS\EXLFONT1.PI1
		INCBIN	A:\PICS\EXLFONT2.PI1
FONTDAT		EQU	FONTBIN+34
FONTDAT2	EQU	FONTBIN+32066+34
		EVEN
		IFEQ intro
offsets		DS.L no_strs
res_offsets	DS.L no_strs
		ENDC

czimusic 	INCBIN GO.CZI
		EVEN
	
		SECTION BSS
		DS.L 399			
stack		DS.L 8				; stack space

		DS.W 16
b8sc_scbuffer	rept 16
		DS.W b8bufsize/2
		endr

		DS.W 16
scbuffer	
big_buf		REPT 2
		DS.W bufsize/2
		ENDR
		DS.W 16

screens		DS.B 256
		DS.B 44800*2			; screen space
end_of_code	
