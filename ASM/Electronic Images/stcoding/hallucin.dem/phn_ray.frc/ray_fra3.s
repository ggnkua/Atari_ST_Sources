;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;
;	 		Phenomena Enigma Demo			 	;
;									;
;   Programming : Martin Griffiths (aka Griff of Electronic Images)	;				 					;
;				 					;
;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;

demo		EQU 0				; 0=run from gem else disk

letsgo
		IFEQ demo	
		CLR -(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14			; ensure lowres
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1				; supervisor mode
		ADDQ.L #6,SP
		ENDC

Men_start_here	MOVE #$2700,SR			; kill all ints
		LEA my_stack,SP			; our own stack
		MOVEM.L $FFFF8240.W,D0-D7
		LEA old_mfp(PC),A0		; save palette
		MOVEM.L D0-D7,(A0)
		MOVE #$8240,A0
		MOVEQ #0,D0
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+			; clear pal
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		BSR Copy_Logo
		BSR Setup_Hscroll
		BSR set_ints			; init ints
		MOVE.W #$2300,SR		; and lets go!

; Little demo which scrolls the screen vertically to oblivion!
		
vbl_lp		BTST.B #0,$FFFFFC00.W
		BEQ vbl_lp
		CMP.B #$39+$80,$FFFFFC02.W	; <SPACE> exits.
		BNE.S vbl_lp

restore		MOVE #$2700,SR
		BSR flush
		LEA old_mfp,A0
		MOVEM.L (A0)+,D0-D7
		MOVEM.L D0-D7,$FFFF8240.W	; restore pal

		MOVE.B #$8,$FFFFFC02.W
		MOVE.B (A0)+,$FFFFFA07.W
	        MOVE.B (A0)+,$FFFFFA09.W
        	MOVE.B (A0)+,$FFFFFA13.W	; restore mfp
        	MOVE.B (A0)+,$FFFFFA15.W
	        MOVE.B (A0)+,$FFFFFA19.W
            	MOVE.B (A0)+,$FFFFFA1F.W
		MOVE.L (A0)+,$68.W
		MOVE.L (A0)+,$70.W		; and vects
		MOVE.L (A0)+,$120.W
		MOVE.L (A0)+,$134.W
		BSET.B #3,$FFFFFA17.W
		MOVE #$2300,SR
		CLR -(SP)			; see ya!
		TRAP #1

; Setup MFP etc for interrupts.

set_ints	MOVE.W SR,-(SP)
		BSR flush			; flush IKBD
		MOVE.B #$12,$FFFFFC02.W		; kill mouse
		LEA old_mfp+32,A0
		MOVE.B $FFFFFA07.W,(A0)+
	        MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
        	MOVE.B $FFFFFA15.W,(A0)+
	        MOVE.B $FFFFFA19.W,(A0)+	; save all vectors
        	MOVE.B $FFFFFA1F.W,(A0)+	; that we change
		MOVE.L $68.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $120.W,(A0)+
		MOVE.L $134.W,(A0)+
	        MOVE.B #$21,$FFFFFA07.W		; timer a and hbl
	        CLR.B $FFFFFA09.W		
        	MOVE.B #$21,$FFFFFA13.W		
		CLR.B $FFFFFA15.W
		CLR.B $FFFFFA19.W		; clear em out
		CLR.B $FFFFFA1B.W
		MOVE.L #phbl,$68.W
		MOVE.L #first_vbl,$70.W
		MOVE.L #syncscroll,$134.W	; and set our vectors
		BCLR.B #3,$FFFFFA17.W		; soft end of interrupt
		MOVE.W (SP)+,SR
		RTS

old_mfp		DS.L 32				; saved mfp vects etc

; The Vbl - simple triggers off timers and clears palette.

first_vbl	MOVE.L #vbl,$70.W		; install main vbl
		RTE
			
vbl		CLR.B $FFFFFA19.W
		MOVE.B #99,$FFFFFA1F.W		; set off timer(top border)
		MOVE.B #4,$FFFFFA19.W
		CLR.B $FFFFFA1B.W
		MOVE.B #48,$FFFFFA21.W		; trigger hbl(for SPX display)
		MOVE.L #setpal1,$120.w
		MOVE.B #8,$FFFFFA1B.W
		MOVE.B #162,$FFFFFA21.W		
		MOVEM.L D0-A6,-(SP)
		MOVE #$8240,A0
		MOVEQ #0,D0
		REPT 8
		MOVE.L D0,(A0)+
		ENDR
		BSR Do_bufscroll
		MOVEM.L (SP)+,D0-A6
		RTE

logo_pal	dc.w	$000,$7DF,$E5F,$6CF,$D4F,$5B7,$C3E,$4A6
		dc.w	$B2D,$395,$A1C,$284,$90B,$103,$80A,$809

syncscroll	MOVE #$2100,SR			; ipl=1(hbl)
		STOP #$2100			; wait for processor hbl
		MOVE #$2700,SR			; (we are now synced with 8 cycles!!!)
		CLR.B $FFFFFA19.W
		MOVEM.L D0-D7/A0-A1,-(SP)
		DCB.W 60,$4E71
		MOVE.B #0,$FFFF820A.W		; zap into 60hz
		DCB.W 6,$4E71
		CLR D1				; top border removed!!
		MOVE #$8209,A0	
		MOVE.B #2,$FFFF820A.W		; switch back to 50hz
syncloop	MOVE.B (A0),D1
		BEQ.S	syncloop		
		MOVEQ #16,D2
		SUB D1,D2
		LSL D2,D1			; sync with screen.
		MOVEQ #27,d1
delayloop1	DBF D1,delayloop1
		MOVE #$8260,A1
hl1		JSR nothing
hl2		JSR nothing
hl3		JSR nothing
hl4		JSR nothing			; the 7 line cases
hl5		JSR nothing
hl6		JSR nothing
hl7		JSR nothing
		MOVEM.L logo_pal(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		MOVEM.L (SP)+,D0-D7/A0-A1
phbl		RTE

setpal1		MOVE #$2700,SR
		MOVEM.L D0-D1/A0-A4,-(SP)
		MOVE.L #fontrast1,$120.W
		MOVE.L pal_ptr(PC),A3
		MOVEQ #0,D1
		MOVE.B $FFFF8209.W,D1
mod1		SUB #0,D1			; subtract low 8 bits(scrn ptr)
		JMP noplist(PC,D1)
noplist		DCB.W 75,$4E71
		DCB.W 128,$4e71
		MOVE #150-1,D1			; 195 (-1 dbf) lines
		MOVE #$8240,A4
		LEA (A4),A0
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+		; initialise pal
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
dopal		LEA (A4),A0
		LEA (A4),A1
		LEA (A4),A2
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		NOP
		NOP
		DBF D1,dopal
		MOVEM.L (SP)+,D0-D1/A0-A4
		BSR SetScreen
		RTE

scroller_pal	DS.W 16

fontrast1	MOVE.W #$223,$FFFF8242.W
		CLR.B $FFFFFA1B.W
		MOVE.L #fontrast2,$120.W
		MOVE.B #1,$FFFFFA21.W
		MOVE.B #8,$FFFFFA1B.W
		RTE
fontrast2	MOVE.W #$224,$FFFF8242.W
		MOVE.L #fontrast3,$120.W
		RTE
fontrast3	MOVE.W #$335,$FFFF8242.W
		MOVE.L #fontrast4,$120.W
		RTE
fontrast4	MOVE.W #$336,$FFFF8242.W
		MOVE.L #fontrast5,$120.W
		RTE
fontrast5	MOVE.W #$447,$FFFF8242.W
		MOVE.L #fontrast6,$120.W
		RTE
fontrast6	MOVE.W #$557,$FFFF8242.W
		MOVE.L #fontrast7,$120.W
		RTE
fontrast7	MOVE.W #$667,$FFFF8242.W
		MOVE.L #fontrast8,$120.W
		RTE
fontrast8	MOVE.W #$777,$FFFF8242.W
		MOVE.L #fontrast9,$120.W
		RTE
fontrast9	MOVE.W #$111,$FFFF8242.W
		MOVE.L #fontrast10,$120.W
		RTE
fontrast10	MOVE.W #$222,$FFFF8242.W
		MOVE.L #fontrast11,$120.W
		RTE
fontrast11	MOVE.W #$333,$FFFF8242.W
		MOVE.L #fontrast12,$120.W
		RTE
fontrast12	MOVE.W #$444,$FFFF8242.W
		MOVE.L #fontrast13,$120.W
		RTE
fontrast13	MOVE.W #$555,$FFFF8242.W
		MOVE.L #fontrast14,$120.W
		RTE
fontrast14	MOVE.W #$666,$FFFF8242.W
		MOVE.L #fontrast15,$120.W
		RTE
fontrast15	MOVE.W #$667,$FFFF8242.W
		MOVE.L #fontrast16,$120.W
		RTE
fontrast16	MOVE.W #$777,$FFFF8242.W
		MOVE.L #fontrast17,$120.W
		RTE
fontrast17	MOVEM.L D0/A0,-(SP)
		MOVE #$8240,A0
		MOVEQ #0,D0
		REPT 8
		MOVE.L D0,(A0)+
		ENDR
		CLR.B $FFFFFA1B.W
		MOVEM.L (SP)+,D0/A0
		RTE

; Set the Screen address and hardware scroll up etc.

SetScreen	MOVE.W ybase_position(PC),D0
		ADDQ.W #1,D0
		CMP.W #8,D0
		BNE.S .ok
		MOVEQ #0,D0
.ok		MOVE.W D0,ybase_position
		MOVE.W D0,D1
		MULU #160*220,D0
		MULU #(96*150)+32,D1
		ADD.L #pic+(8*160),D0
		ADD.L #pal,D1
		MOVE.L D1,pal_ptr
		MOVE.L D0,this_base		; this frames base..
		
		MOVEQ #0,D1
		MOVE.B D0,D1			; lower byte(screen address)
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W		; upper 16 bits
SetHscroll	MOVE.W D1,mod1+2
		MULU #7*2,D1
		LEA LINE_JMPS,A0
		LEA hl1+2(PC),A1
		ADDA.W D1,A0			; self modifies
		MOVE.L (A0)+,(A1)		; the jsr for the
		MOVE.L (A0)+,hl2-hl1(A1)	; hscroll case
		MOVE.L (A0)+,hl3-hl1(A1)
		MOVE.L (A0)+,hl4-hl1(A1)
		MOVE.L (A0)+,hl5-hl1(A1)
		MOVE.L (A0)+,hl6-hl1(A1)
		MOVE.L (A0)+,hl7-hl1(A1)
		RTS

ybase_position	DC.W 0
pal_ptr		DC.L pal
this_base	DC.L pic+(8*160)
sc_x1		DC.W 0

; This table contains the various border removal combinations
; for adding 0 bytes,8 bytes,16 bytes etc etc....

ROUT_TAB	DC.L nothing     ;=0          ;0      
		DC.L length_2    ;=-2         ;1
		DC.L length24    ;=+24        ;2
		DC.L rightonly   ;=+44        ;3
		DC.L wholeline   ;=+70        ;4
		DC.L length26    ;=+26        ;5
		DC.L length_106  ;=-106!      ;6 !!!

ROUTS		DC.B 0,0,0,0,0,0,0 ;
		DC.B 6,4,3,1,1,1,0 ;
		DC.B 6,4,3,1,1,0,0 ;
		DC.B 6,4,3,1,0,0,0 ;
		DC.B 6,4,3,0,0,0,0 ;
		DC.B 6,4,2,2,1,0,0 ;
		DC.B 6,4,2,2,0,0,0 ;
		DC.B 6,5,4,2,0,0,0 ;
		DC.B 6,5,5,4,0,0,0 ;
		DC.B 2,1,1,1,0,0,0 ;
		DC.B 2,1,1,0,0,0,0 ;
		DC.B 2,1,0,0,0,0,0 ;
		DC.B 2,0,0,0,0,0,0 ;
		DC.B 5,0,0,0,0,0,0 ;
		DC.B 6,4,4,1,1,1,0 ;
		DC.B 6,4,4,1,1,0,0 ;
		DC.B 6,4,4,1,0,0,0 ;32
		DC.B 6,4,4,0,0,0,0 ;
		DC.B 6,4,2,2,2,0,0 ;
		DC.B 3,1,1,1,0,0,0 ;
		DC.B 3,1,1,0,0,0,0 ;
		DC.B 3,1,0,0,0,0,0 ;
		DC.B 3,0,0,0,0,0,0 ;
		DC.B 2,2,1,0,0,0,0 ;
		DC.B 2,2,0,0,0,0,0 ;
		DC.B 5,2,0,0,0,0,0 ;
		DC.B 5,5,0,0,0,0,0 ;
		DC.B 6,4,4,2,1,1,0 ;
		DC.B 6,4,4,2,1,0,0 ;
		DC.B 6,4,4,2,0,0,0 ;
		DC.B 6,5,4,4,0,0,0 ;
		DC.B 4,1,1,1,1,0,0 ;
		DC.B 4,1,1,1,0,0,0 ;64
		DC.B 4,1,1,0,0,0,0 ;
		DC.B 4,1,0,0,0,0,0 ;
		DC.B 4,0,0,0,0,0,0 ;
		DC.B 2,2,2,0,0,0,0 ;72
		DC.B 5,2,2,0,0,0,0 ;
		DC.B 5,5,2,0,0,0,0 ;
		DC.B 5,5,5,0,0,0,0 ;
		DC.B 6,4,4,2,2,1,0 ;
		DC.B 6,4,4,2,2,0,0 ;
		DC.B 3,3,1,1,0,0,0 ;
		DC.B 3,3,1,0,0,0,0 ;
		DC.B 3,3,0,0,0,0,0 ;
		DC.B 4,2,1,1,0,0,0 ;
		DC.B 4,2,1,0,0,0,0 ;
		DC.B 4,2,0,0,0,0,0 ;
		DC.B 5,4,0,0,0,0,0 ;
		DC.B 5,2,2,2,0,0,0 ;
		DC.B 5,5,2,2,0,0,0 ;
		DC.B 5,5,5,2,0,0,0 ;
		DC.B 6,4,4,4,0,0,0 ;
		DC.B 6,4,4,2,2,2,0 ;
		DC.B 4,3,1,1,1,0,0 ;
		DC.B 4,3,1,1,0,0,0 ;
		DC.B 4,3,1,0,0,0,0 ;
		DC.B 4,3,0,0,0,0,0 ;
		DC.B 4,2,2,1,0,0,0 ;
		DC.B 4,2,2,0,0,0,0 ;	
		DC.B 5,4,2,0,0,0,0 ;120
		DC.B 5,5,4,0,0,0,0 ;
		DC.B 5,5,2,2,2,0,0 ;
		DC.B 5,5,5,2,2,0,0 ;
		DC.B 6,4,4,4,2,0,0 ;128
		DC.B 3,3,3,1,0,0,0 ;130
		DC.B 3,3,3,0,0,0,0 ;132
		DC.B 4,4,1,1,1,0,0 ;134
		DC.B 4,4,1,1,0,0,0 ;136
		DC.B 4,4,1,0,0,0,0 ;138
		DC.B 4,4,0,0,0,0,0 ;140
		DC.B 4,2,2,2,0,0,0 ;142
		DC.B 5,4,2,2,0,0,0 ;144
		DC.B 5,5,4,2,0,0,0 ;146
		DC.B 5,5,5,4,0,0,0 ;148
		DC.B 5,5,5,2,2,2,0 ;150
		DC.B 6,4,4,4,2,2,0 ;152
		DC.B 4,3,3,1,1,0,0 ;154
		DC.B 4,3,3,1,0,0,0 ;156
		DC.B 4,3,3,0,0,0,0 ;158
		DC.B 4,5,4,0,1,1,1 ;160
		DC.B 4,4,2,1,0,0,0 ;162
		DC.B 4,4,2,0,0,0,0 ;164
		DC.B 5,4,4,0,0,0,0 ;166
		DC.B 5,4,2,2,2,0,0 ;168
		DC.B 5,5,4,2,2,0,0 ;170
		DC.B 5,5,5,4,2,0,0 ;172
		DC.B 6,4,4,4,4,0,0 ;174
		DC.B 3,3,3,3,0,0,0 ;176
		DC.B 4,4,3,1,1,1,0 ;178
		DC.B 4,4,3,1,1,0,0 ;180
		DC.B 4,4,3,1,0,0,0 ;182
		DC.B 4,4,3,0,0,0,0 ;184
		DC.B 4,4,2,2,1,0,0 ;186
		DC.B 4,4,2,2,0,0,0 ;188
		DC.B 5,4,4,2,0,0,0 ;190
		DC.B 5,5,4,4,0,0,0 ;192
		DC.B 5,5,4,2,2,2,0 ;194
		DC.B 5,5,5,4,2,2,0 ;196
		DC.B 6,4,4,4,4,2,0 ;198
		DC.B 4,3,3,3,1,0,0 ;200
		DC.B 4,3,3,3,0,0,0 ;202
		DC.B 4,4,4,1,1,1,0 ;204
		DC.B 4,4,4,1,1,0,0 ;206
		DC.B 4,4,4,1,0,0,0 ;208
		DC.B 4,4,4,0,0,0,0 ;210
		DC.B 4,4,2,2,2,0,0 ;212
		DC.B 5,4,4,2,2,0,0 ;214
		DC.B 5,5,4,4,2,0,0 ;216
		DC.B 5,5,5,4,4,0,0 ;218
		DC.B 3,3,3,3,3,0,0 ;220
		DC.B 6,4,4,4,4,2,2 ;222
		DC.B 4,4,3,3,1,1,0 ;224
		DC.B 4,4,3,3,1,0,0 ;226
		DC.B 4,4,3,3,0,0,0 ;228
		DC.B 4,4,4,2,1,1,0 ;230
		DC.B 4,4,4,2,1,0,0 ;232
		DC.B 4,4,4,2,0,0,0 ;234
		DC.B 5,4,4,4,0,0,0 ;236
		DC.B 5,4,4,2,2,2,0 ;238
		DC.B 5,5,4,4,2,2,0 ;240
		DC.B 5,5,5,4,4,2,0 ;242
		DC.B 6,4,4,4,4,4,0 ;244
		DC.B 4,3,3,3,3,0,0 ;246
		DC.B 4,4,4,3,1,1,1 ;248
		DC.B 4,4,4,3,1,1,0 ;250
		DC.B 4,4,4,3,1,0,0 ;252
		DC.B 4,4,4,3,0,0,0 ;254
		EVEN

; Overscan one whole screen line

wholeline	MOVE.B #2,$FFFF8260.W
		MOVE.B #0,$FFFF8260.W
		DCB.W 87,$4E71
		MOVE.B #0,$FFFF820A.W
		MOVE.B #2,$FFFF820A.W
		DCB.W 8,$4e71
		MOVE.B #1,$FFFF8260.W
		MOVE.B #0,$FFFF8260.W
		RTS

; Right border only

rightonly	DCB.W 95,$4E71
		MOVE.B #0,$FFFF820A.W
		MOVE.B #2,$FFFF820A.W
		DCB.W 16,$4e71
		RTS

; Miss one word -2 bytes

length_2	DCB.W 93,$4E71
		MOVE.B #0,$FFFF820A.W
		MOVE.B #2,$FFFF820A.W
		DCB.W 18,$4e71
		RTS
   
; Do nothing        

nothing		DCB.W 119,$4E71
		RTS

; 24 bytes extra per line

length24	MOVE.B #2,$FFFF8260.W
		MOVE.B #0,$FFFF8260.W
		DCB.W 86,$4E71
		MOVE.B #0,$FFFF820A.W
		MOVE.B #2,$FFFF820A.W
		DCB.W 9,$4E71
		MOVE.B #1,$FFFF8260.W
		MOVE.B #0,$FFFF8260.W
		RTS		

; +26 bytes 

length26	MOVE.B #2,$FFFF8260.W
		MOVE.B #0,$FFFF8260.W
		DCB.W 103,$4E71
		MOVE.B #1,$FFFF8260.W    
		MOVE.B #0,$FFFF8260.W
		RTS		

; -106 bytes 

length_106	DCB.W 41,$4E71
		MOVE.B #2,$FFFF8260.W
		MOVE.B #0,$FFFF8260.W
		DCB.W 70,$4e71
		RTS		

; Setup Hardware scroll jump table. (128 tables of 7 32 bit addresses)

Setup_Hscroll	LEA ROUTS(PC),A0
		LEA ROUT_TAB(PC),A1
		LEA LINE_JMPS,A2
		MOVEQ #127,D2	
.jlp		MOVEQ #6,D1
.ilp		CLR D0
		MOVE.B (A0)+,D0
		ADD D0,D0
		ADD D0,D0
		MOVE.L (A1,D0),(A2)+
		DBF D1,.ilp
		DBF D2,.jlp
		RTS

;-----------------------------------------------------------------------;
; 16*16 1 plane Buffer Scroller (This one has variable speeds 1,2,4etc) ;
; By Martin Griffiths May 1991. (alias Griff of the Inner Circle)....	;
;-----------------------------------------------------------------------;

nolines		EQU 16
linewid		EQU 84
phbufsize	EQU nolines*linewid

Do_bufscroll	LEA ovscr_point(PC),A1		; ->some variables
		MOVE.L (A1)+,A0			; curr text ptr
		MOVE (A1)+,D6			; pixel offset
		ADD ovscrlspeed(PC),D6		; pix offset+speed
		AND #15,D6			; next 16 pix?
		BNE.S .notnchar			; no then skip
		ADDQ.W #2,(A1)			; onto next chunk 
		CMP #linewid/2,(A1)		; in pix buffer.
		BNE.S .noreset			; reached end of buffer?		
		CLR (A1)			; if yes reset buffer position
.noreset	ADDQ.L #1,A0			; next letter...
		MOVE.W ovthischar+2(PC),ovthischar ; cycle characters.
		MOVEQ #0,D0
.fetchchar	MOVE.B (A0),D0	
		BNE.S .notwrap			; end of text?
		LEA ovtext(PC),A0		; yes restart text
		MOVE.B (A0),D0
.notwrap	CMP.B #1,D0
		BNE.S .notsetspeed
		MOVE.B 1(A0),ovscrlspeed+1
		ADDQ.L #2,A0
		BRA.S .fetchchar
.notsetspeed	SUB.B #32,D0			; ascii normalise
		LSL #5,D0
		MOVE.W D0,ovthischar+2
.notnchar	MOVE D6,-(A1)			; otherwise restore
		MOVE.L A0,-(A1)
		LEA phfontbuf(PC),A5     	; character addr    
		LEA (A5),A6
		ADDA.W ovthischar(PC),A5
		ADDA.W ovthischar+2(PC),A6
		MOVE.W ovscx(PC),D0
		MULU #phbufsize,d0
		LEA (phscbuffer)-2,A3
		ADD.L D0,A3
		ADD ovscrlpos(PC),A3
		LEA 2(A3),A1
		MOVE.W ovscrlspeed(PC),D4	; scroll speed
		SUBQ #1,D4
		MULU #12,D4			; *14(for jmp thru)
		LEA .jmpthru(PC),A4
		SUB.W D4,A4			; jmp address
		MOVEQ #nolines-1,D1
.updatebuflp	MOVE.W (A6)+,D3
		SWAP D3
		MOVE.W (A5)+,D3 
		ROL.L D6,D3
		MOVE.W D3,(linewid/2)(A3)	; update the buffers		
		MOVE.W D3,(A3)
		MOVE.L A3,A2
		JMP (A4)
		REPT 15				; e.g number of buffers
		LEA phbufsize(A2),A2		; to update = speed!
		ROL.L #1,D3
		MOVE.W D3,(linewid/2)(A2)
		MOVE.W D3,(A2)
		ENDR
.jmpthru	LEA linewid(A3),A3
		DBF D1,.updatebuflp
		MOVE.L this_base(PC),A2
		ADD.L #210*160,A2
		MOVEQ #16-1,D2
.lp		
i		SET 0
		REPT 20
		MOVE.W (A1)+,i(A2)
i		SET i+8
		ENDR
		LEA linewid-40(A1),A1
		LEA 160(A2),A2
		DBF D2,.lp
		RTS

ovscr_point	DC.L ovtext
ovscx		DC.W 0
ovscrlpos	DC.W 0
ovscrlspeed	DC.W 4
ovthischar	DS.W 4
ovtext		DC.B "                        WELL HOW ABOUT THAT!!!!!! (HE HE) IT'S ANOTHER UNDERSCAN SCREEN!!"
		DC.B " (SORRY DELTAFORCE!)  OK OK, SO ITS JUST A LOUSY BLUE BORDER WITH A SLOW STARFIELD.....         "
		DC.B 1,8,"                  "
		DC.B 1,4,"  BUT LET US APPROACH THIS FROM SOME NEW ANGLES.....          ",1,8,"                   "
		DC.B 1,4,"                               YEAH! A HIDDEN LINE VECTOR PYRAMID.....          ",1,8,"                    "      
		DC.B 1,4,"                               AND A ROTATING INNER CIRCLE LOGO......         ",1,8,"                    "
		DC.B 1,4,"         BUT NOW LET US....      SPIN IT!     ",1,1," ",1,2," ",1,8,"                  "
		DC.B 1,4,"     WELL THIS PART IS A CONVERSION OF MY FAVOURITE AMIGA DEMO... CALLED 'ENIGMA' AND IS BY PHENOMENA....      "
		DC.B " OKAY SO THE AMIGA VERSION WAS A BIT FASTER BUT THE ST HAS NO BLITTER TO DRAW LINES AND FILL AREAS, SO WHAT DO YOU EXPECT?!"
		DC.B " ANYWAY THIS VERSION IS MUCH SMOOTHER THAN THE AMIGA ONE CUS THEY USED WOBBLY 3D ROUTS TO GAIN EXTRA SPEED.....        "
		DC.B 1,8,"                    "
		DC.B 1,4," OK... LETS MOVE THAT CUBE......       ",1,8,"                 "
		DC.B 1,4,"  WELL I HOPE YOU LIKED THIS PART! IT TOOK ME TWO DAYS TO CODE SO YA BETTER LIKE IT...        "
		DC.B "LETS LEAVE THIS PART AND GO ONTO SOME MORE INTERESTING(?) ROUTINES......          "
		DC.B 1,8,"                           "
		DC.B 1,4,"                                     " 
		DC.B 0
		EVEN

phfontbuf	dc.l	$00000000,$00000000,$00000000,$00000000,$00000000 
		dc.l	$00000000,$00000000,$00000000,$07800FC0,$0FC00FC0 
		dc.l	$0FC00FC0,$07800780,$07800300,$03000000,$03000780 
		dc.l	$03000000,$0C300E38,$0E380E38,$0C300000,$00000000 
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000060 
		dc.l	$0C600C78,$0FF83FE0,$3C600C60,$0C780FF8,$3FE03C60 
		dc.l	$0C600C00,$00000000,$07D81DF8,$39B83D88,$3F803FC0 
		dc.l	$1FF00FF8,$03FC21FC,$31BC399C,$3DB837F0,$01800000 
		dc.l	$1E063F0E,$331C3F38,$1E7000E0,$01C00380,$07000E78 
		dc.l	$1CFC38CC,$70FCE078,$00000000,$0F001CC0,$38603860 
		dc.l	$3CC01F80,$0F1E1F8C,$77C8F3F0,$F1F0F0FA,$78FE1F3C 
		dc.l	$00000000,$0C001E00,$1E000600,$04000800,$00000000 
		dc.l	$00000000,$00000000,$00000000,$00000000,$00180030 
		dc.l	$007000E0,$01E001E0,$03C003C0,$03C003C0,$01E001E0 
		dc.l	$00E00070,$00300018,$18000C00,$0E000700,$07800780 
		dc.l	$03C003C0,$03C003C0,$07800780,$07000E00,$0C001800 
		dc.l	$00000180,$318C1998,$0DB007E0,$03C007E0,$0DB01998 
		dc.l	$318C0180,$00000000,$00000000,$00000180,$01800180 
		dc.l	$01800180,$1FF81FF8,$01800180,$01800180,$01800000 
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000000 
		dc.l	$00000000,$018003C0,$03C000C0,$00800100,$00000000 
		dc.l	$00000000,$00000000,$1FF01FF0,$00000000,$00000000 
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000000 
		dc.l	$00000000,$00000000,$018003C0,$03C00180,$00000000 
		dc.l	$003C0078,$007800F0,$01E001E0,$03C00780,$07800F00 
		dc.l	$1E001E00,$3C007800,$7800F000,$03C00E70,$1C381C38 
		dc.l	$3C3C3C3C,$3C3C3C3C,$3C3C3C3C,$1C381C38,$0E7003C0 
		dc.l	$00000000,$01800F80,$07800780,$07800780,$07800780 
		dc.l	$07800780,$07800780,$07801FE0,$00000000,$07F00E78 
		dc.l	$1E381E38,$1E380C78,$007800F0,$03E007C0,$0F001C08 
		dc.l	$1FF81FF8,$00000000,$03E007F0,$08780038,$00300060 
		dc.l	$01F00078,$003C0C3C,$1E3C1E7C,$0CF807F0,$00000000 
		dc.l	$00300070,$00F001F0,$02F004F0,$08F010F0,$3FFC3FFC 
		dc.l	$00F000F0,$00F001F8,$00000000,$0FF00FF0,$0FE00800 
		dc.l	$0FC00FF0,$0FF80078,$00380C38,$1E381E78,$0CF007E0 
		dc.l	$00000000,$00E003C0,$07800F00,$1E003FC0,$7E707C38 
		dc.l	$7C3C7C3C,$7C3C3C3C,$1E7807E0,$00000000,$1FF01FE0 
		dc.l	$1FE010C0,$11C001C0,$03C00380,$07800780,$07800F80 
		dc.l	$0F800F80,$00000000,$03C00E70,$1C381C38,$1E381F70 
		dc.l	$0FE007F0,$0CF8183C,$381C381C,$3C381FE0,$00000000 
		dc.l	$07E01E70,$3C383C3C,$3C3C3C3C,$3C3C1E7C,$07FC00F8 
		dc.l	$00F001E0,$03C00F00,$00000000,$00000000,$00000300 
		dc.l	$07800780,$03000000,$00000000,$03000780,$07800300 
		dc.l	$00000000,$00000000,$00000300,$07800780,$03000000 
		dc.l	$00000000,$03000780,$07800180,$01000200,$00000078 
		dc.l	$007000E0,$01C00180,$03000600,$03000180,$01C000E0 
		dc.l	$00700078,$00000000,$00000000,$00000000,$1FF01FF0 
		dc.l	$00000000,$00001FF0,$1FF00000,$00000000,$00000000 
		dc.l	$00001E00,$0E000700,$03800180,$00C00060,$00C00180 
		dc.l	$03800700,$0E001E00,$00000000,$07F00E78,$1E381E38 
		dc.l	$0C380078,$0FF00FE0,$0C000000,$0C001E00,$1E000C00,$00000000 
		dc.l	$0FE01FF0,$3C383818,$381838F8,$39F83998,$39F838F0 
		dc.l	$38003C08,$1FF80FF0,$00000000,$00E001E0,$02F002F0 
		dc.l	$02F00478,$04780478,$0FFC083C,$083C101E,$383E7C7F 
		dc.l	$00000000,$7FE03EF0,$1E781E78,$1E781EF0,$1FE01EF8 
		dc.l	$1E7C1E3C,$1E3C1E7C,$3EF87FF0,$00000000,$03EC0F3C 
		dc.l	$1E1C1E0C,$3E043E00,$3E003E00,$3E003E00,$1E081F38 
		dc.l	$0FF003E0,$00000000,$7FC03EF0,$1E781E3C,$1E3C1E3C 
		dc.l	$1E3C1E3C,$1E3C1E3C,$1E3C1E78,$3EF07FC0,$00000000 
		dc.l	$7FF83E78,$1E181E08,$1E601EE0,$1FE01EE0,$1E601E08 
		dc.l	$1E181E78,$3EF87FF8,$00000000,$7FF83E78,$1E181E08 
		dc.l	$1E601EE0,$1FE01EE0,$1E601E00,$1E001E00,$3F007F80 
		dc.l	$00000000,$03EC0F3C,$1E1C1E0C,$3E043E00,$3E003E7E 
		dc.l	$3E3C3E3C,$1E3C1F3C,$0FFC03EC,$00000000,$FEFE7C7C 
		dc.l	$3C783C78,$3C783C78,$3FF83C78,$3C783C78,$3C783C78 
		dc.l	$7C7CFEFE,$00000000,$0FF007E0,$03C003C0,$03C003C0 
		dc.l	$03C003C0,$03C003C0,$03C003C0,$07E00FF0,$00000000 
		dc.l	$03FC01F8,$00F000F0,$00F000F0,$00F000F0,$18F03CF0 
		dc.l	$3CF038F0,$18E00FC0,$00000000,$7FBE3F18,$1E301E60 
		dc.l	$1EC01FC0,$1FC01FE0,$1FF01EF8,$1E7C1E3E,$3F1F7FBF 
		dc.l	$00000000,$7F803F00,$1E001E00,$1E001E00,$1E001E00 
		dc.l	$1E081E18,$1E381E78,$3EF87FF8,$00000000,$FC1F3C1E 
		dc.l	$3E2E3E2E,$2E2E2F4E,$2F4E274E,$278E278E,$238E230E 
		dc.l	$711EF83F,$00000000,$7E7C1E38,$1F101F10,$17101790 
		dc.l	$139013D0,$11F010F0,$10F01070,$38707C30,$00000000 
		dc.l	$07E01E78,$1C3C3C3C,$781E781E,$781E781E,$781E781E 
		dc.l	$3C3C1C38,$1E7807E0,$00000000,$7FF03EF8,$1E7C1E3C 
		dc.l	$1E3C1E7C,$1EF81FF0,$1E001E00,$1E001E00,$3F007F80 
		dc.l	$00000000,$07E01E78,$1C3C3C3C,$781E781E,$781E781E 
		dc.l	$781E781E,$3C3C1C38,$1E7807E0,$01C000F0,$7FE03EF0 
		dc.l	$1E781E78,$1E781EF0,$1FE01FF0,$1EF81E78,$1E7C1E3C 
		dc.l	$3E3C7F3E,$00000000,$03D81CF8,$38383C08,$3F003FC0 
		dc.l	$1FF00FF8,$03FC20FC,$303C381C,$3C3837F0,$00000000 
		dc.l	$7FFE7BDE,$73CE63C6,$43C203C0,$03C003C0,$03C003C0 
		dc.l	$03C003C0,$07E00FF0,$00000000,$FF7C7E10,$3C103C10 
		dc.l	$3C103C10,$3C103C10,$3C103C10,$3C103C10,$1E200FC0 
		dc.l	$00000000,$FF3E7E1C,$3C081E10,$1E101E10,$0F200F20 
		dc.l	$0F200740,$07C00780,$03800380,$00000000,$FBF771E2 
		dc.l	$71E271E2,$39743974,$3A743A74,$3A741C38,$1C381C38 
		dc.l	$1C381C38,$00000000,$FF7C7C38,$3E201E20,$0F400F80 
		dc.l	$07C007C0,$03E005E0,$08F00878,$38FC7DFE,$00000000 
		dc.l	$7F3C3E10,$1E100F20,$0F200740,$07C003C0,$03C003C0 
		dc.l	$03C003C0,$07E00FF0,$00000000,$1FFE1E3C,$187810F0 
		dc.l	$00F001E0,$03C003C0,$07800F04,$0F0C1E1C,$1E3C3FFC 
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000000 
		dc.l	$00000000,$00000000,$00000000,$00000000 


; Flush keyboard

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
flok		RTS

; Insert(copy) logo into the frames of the raytraced fractal 

Copy_Logo	LEA logo(PC),A0
		LEA pic+(16*160),A1
		MOVEQ #8-1,D1
.lp2		MOVE.L A0,A2
		MOVE.L A1,A3
		MOVE.W #(33*160)/16-1,D0
.lp		MOVE.L (A2)+,(A3)+
		MOVE.L (A2)+,(A3)+
		MOVE.L (A2)+,(A3)+
		MOVE.L (A2)+,(A3)+
		DBF D0,.lp
		ADD.L #220*160,A1
		DBF D1,.lp2
		RTS

		SECTION DATA
LINE_JMPS	
logo		incbin ray_frac.inc\phn_logo.dat
pic		ds.w 8*160
		incbin ray_frac.dat
pal		;incbin ray_frac.pal

		SECTION BSS

		DS.W 8
phscbuffer	REPT 16
		DS.B phbufsize
		ENDR
		DS.W 8

		DS.L 199
my_stack	DS.L 2			; our own stack..
