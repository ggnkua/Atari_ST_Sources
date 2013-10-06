;-----------------------------------------------------------------------;
; 7 line Sync Scroll Routine (screen on any WORD boundary version)	;
; Programmed by Griff of Electronic Images (Inner Circle).		;
; This is one of the fastest and most reliable sync scroll routs...	;
; it works on all ST's and STE and is the one use in 'Things Not to do' ;
;-----------------------------------------------------------------------;
; Some Quick notes about this source
;
; 1.The top border is removed with a timer A call.
; 2.Straight after the switch back to 50hz(from the border change)
;   the processor is synced with the screen.(using standard method)
; 3.The following 7 scanlines are used in removing different borders 
;   (i.e different line lengths) to get the sync scroll effect.
; 4.The 7 vectors(1 for each scanline) are setup in the vbl, this
;   'programs' how many bytes to be missed.  

screen		EQU $F0000			; screen address.

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
		LEA my_stack,SP
		BSR Copy_pic			; copy piccy to screeb
		BSR SETUPSCROLL

set_ints	MOVE #$2700,SR
		BSR flush			; flush IKBD
		MOVE.B #$12,$FFFFFC02.W		; kill mouse
		LEA old_mfp+32,A0
		MOVEM.L $FFFF8240.W,D0-D7
		MOVEM.L D0-D7,-32(A0)
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
		MOVE.L #vbl,$70.W
		MOVE.L #syncscroll,$134.W	; and set our vectors
		MOVE.L #setpal1,$120.w
		BCLR.B #3,$FFFFFA17.W		; soft end of interrupt
		MOVE #$2300,SR

; Little demo which scrolls the screen vertically to oblivion!
		
wait_key	BSR wait_vbl			; obvious!
		MOVE.L log_base(PC),D0
		ADD.L #160,D0			
		MOVE.L D0,log_base		
		MOVE.W D0,D1
		AND #$FF,D1
		MOVE D1,sc_x1			; lower byte(screen address)
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W		; upper 16 bits
		CMP.B #$39,$FFFFFC02.W		; <SPACE> exits.
		BNE.S wait_key

restore		MOVE #$2700,SR
		LEA old_mfp,A0
		MOVEM.L (A0)+,D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		BSR flush
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

; Wait for one vbl
; (d0 destroyed)

wait_vbl	MOVE.W vbl_timer(PC),D0
.wait		CMP.W vbl_timer(PC),D0
		BEQ.S .wait
		RTS

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
		DC.B 6,4,4,4,2,0,0 ;
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
		DC.B 4,4,2,1,1,0,0 ;160
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

		even
			
vbl		CLR.B $FFFFFA19.W
		MOVE.B #99,$FFFFFA1F.W		; set off timer(top border)
		MOVE.B #4,$FFFFFA19.W
		CLR.B $FFFFFA1B.W
		MOVE.B #26,$FFFFFA21.W		
		MOVE.B #8,$FFFFFA1B.W
		MOVEM.L D0/A0-A1,-(SP)
		MOVE #$8240,A0
		MOVEQ #0,D0
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+			; clear palette
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE sc_x1(PC),D0
		AND #$FF,D0
		MULU #7*2,D0
		LEA LINE_JMPS(PC),A0
		LEA hl1+2(PC),A1
		ADDA.W D0,A0			; self modifies
		MOVE.L (A0)+,(A1)		; the jsr for the
		MOVE.L (A0)+,hl2-hl1(A1)	; hscroll case
		MOVE.L (A0)+,hl3-hl1(A1)
		MOVE.L (A0)+,hl4-hl1(A1)
		MOVE.L (A0)+,hl5-hl1(A1)
		MOVE.L (A0)+,hl6-hl1(A1)
		MOVE.L (A0)+,hl7-hl1(A1)
		MOVEM.L (SP)+,D0/A0-A1
		ADDQ #1,vbl_timer
		RTE

syncscroll	MOVE #$2100,SR			; ipl=1(hbl)
		STOP #$2100			; wait for processor hbl
		MOVE #$2700,SR			; (we are now synced with 8 cycles!!!)
		CLR.B $FFFFFA19.W
		MOVEM.L D0-D7/A0-A1,-(SP)
		DCB.W 60,$4E71
		MOVE.B #0,$FFFF820A.W		; zap into 60hz
		DCB.W 7,$4E71
		CLR D1				; top border removed!!
		MOVE #$8209,A0	
		MOVE.B #2,$FFFF820A.W		; switch back to 50hz
syncloop	MOVE.B (A0),D1
		BEQ.S	syncloop		
		MOVEQ #10,D2
		SUB D1,D2
		LSL D2,D1			; sync with screen.
		MOVEQ	#28,d1
delayloop1	DBF D1,delayloop1
		DCB.W 2,$4E71			
hl1		JSR 0
hl2		JSR 0
hl3		JSR 0
hl4		JSR 0				; the 7 line cases
hl5		JSR 0
hl6		JSR 0
hl7		JSR 0
		MOVEM.L (SP)+,D0-D7/A0-A1
phbl		RTE

setpal1		MOVEM.L A0-A1,-(SP)
		LEA pic+2(PC),A0
		LEA $FFFF8240.W,A1
		REPT 8
		MOVE.L (A0)+,(A1)+		; set palette
		ENDR				; for rest of screen
		MOVEM.L (SP)+,A0-A1
		CLR.B $FFFFFA1B.W
		RTE

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

* Right border only

rightonly	DCB.W 95,$4E71
		MOVE.B #0,$FFFF820A.W
		MOVE.B #2,$FFFF820A.W
		DCB.W 16,$4e71
		RTS

* Miss one word -2 bytes

length_2	DCB.W 93,$4E71
		MOVE.B #0,$FFFF820A.W
		MOVE.B #2,$FFFF820A.W
		DCB.W 18,$4e71
		RTS
   
* Do nothing        

nothing		DCB.W 119,$4E71
		RTS

* 24 bytes extra per lineE

length24	MOVE.B #2,$FFFF8260.W
		MOVE.B #0,$FFFF8260.W
		DCB.W 86,$4E71
		MOVE.B #0,$FFFF820A.W
		MOVE.B #2,$FFFF820A.W
		DCB.W 9,$4E71
		MOVE.B #1,$FFFF8260.W
		MOVE.B #0,$FFFF8260.W
		RTS		

* +26 bytes 

length26	MOVE.B #2,$FFFF8260.W
		MOVE.B #0,$FFFF8260.W
		DCB.W 103,$4E71
		MOVE.B #1,$FFFF8260.W    
		MOVE.B #0,$FFFF8260.W
		RTS		

* -106 bytes 

length_106	DCB.W 41,$4E71
		MOVE.B #2,$FFFF8260.W
		MOVE.B #0,$FFFF8260.W
		DCB.W 70,$4e71
		RTS		

; SETUP HARDWARE SCROLL ROUTS...

SETUPSCROLL	LEA ROUTS(PC),A0
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

; Copy the piccy to the screen.

Copy_pic	LEA pic+34(PC),A0
		MOVE.L log_base(PC),A1
		MOVE #(27*160)/4-1,D1
.clr		CLR.L (A1)+
		DBF D1,.clr
		MOVE #1999,D1
cpy_lp1		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		DBF D1,cpy_lp1 
		RTS

LINE_JMPS	DS.L 7*128

; Flush keyboard

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
flok		RTS

log_base	DC.L screen
sc_x		DC.W 8
sc_x1		DC.W 0
vbl_timer	DC.W 0

		SECTION DATA

pic		INCBIN D:\GRAFIK\BILD\PI1\ANXIETY.PI1

		SECTION BSS

old_mfp		DS.L 30			; saved mfp vects etc
		DS.L 249
my_stack	DS.L 2			; our own stack..

	