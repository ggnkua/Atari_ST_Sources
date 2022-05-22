;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;
;	 		Phenomena Enigma Demo			 	;
;				 					;
; The RayTraced Fractal!!! Wow and Bloody Hell! 8 Spectrum 512 frames  ;
;				 					;
;   Programming : Martin Griffiths (aka Griff of Electronic Images)	;				 					;
;				 					;
;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;

demo		EQU 0				; 0=gem 1=from DMA disk
	
letsgo		
		IFEQ demo
		CLR.W -(sp)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(sp)
		TRAP #14			; lowres
		LEA 12(sp),sp
		CLR.L -(sp)
		MOVE #$20,-(sp)
		TRAP #1				; supervisor mode.
		ADDQ.L #6,SP

		ELSEIF

		ORG $10000

		ENDC

		MOVE.L SP,oldsp
		LEA my_stack,SP			; our own stack
		IFNE demo
		JSR $508
		ENDC
		BSR Copy_Logo
		BSR Setup_Hscroll

		MOVE #$8240,A0
		LEA old_mfp(PC),A1		; save palette
		MOVEM.L (A0),D0-D7
		MOVEM.L D0-D7,(A1)
		MOVEQ #0,D0
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+			; clear pal
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		BSR SetScreen
		BSR set_ints			; init ints
		BSR Wait_Vbl	
		MOVE.W #$80,D2
		MOVE.W #160,D3
		LEA trig_tab,A1
vbl_lp1		BSR Wait_Vbl	
		ADDQ #4,D2
		AND #$FE,D2
		MOVE.W D3,D1
		MULS (A1,D2),D1
		LSL.L #2,D1
		SWAP D1
		MOVE.W D1,pic_Y
		TST D2
		BNE vbl_lp1
		SUB.W #40,D3
		BNE vbl_lp1

		MOVE.L #lpal,fadein_pal_ptr
		MOVE.L #currpal,fadein_cur_ptr
		MOVE.W #16,fadein_nocols
		ST.B fadeinflag
		ST.B doscroll_flag	

vbl_lp3		BSR Wait_Vbl	
		BTST.B #0,$FFFFFC00.W
		BEQ .cont3
		CMP.B #$39,$FFFFFC02.W		; <SPACE> exits.
		BEQ.S OUT
.cont3		TST.B scrolldone
		BEQ.S vbl_lp3

OUT		MOVE.L #lpal,fadeout_pal_ptr
		MOVE.L #currpal,fadeout_cur_ptr
		MOVE.W #16,fadeout_nocols
		ST.B fadeoutflag
		MOVEQ #30,D7
vbl_lp3a	BSR Wait_Vbl	
		DBF D7,vbl_lp3a

		SF.B doscroll_flag	
		LEA pic+((211+8)*160),A1
		MOVEQ #0,D5
		MOVEQ #8-1,D7
.lp		LEA (A1),A0
		MOVEQ #16-1,D6
.lp1		REPT 40
		MOVE.L D5,(A0)+
		ENDR
		DBF D6,.lp1
		ADD.L #160*220,A1
		DBF D7,.lp

		MOVEQ #0,D3
vbl_lp4		BSR Wait_Vbl	
		MOVE.W D3,pic_Y
		ADDQ.W #1,D3
		CMP.W #160,D3
		BNE vbl_lp4

restore		MOVE #$2700,SR
		BSR flush
		LEA old_mfp,A0
		MOVEM.L (A0)+,D0-D7
		MOVEM.L D0-D7,$FFFF8240.W	; restore pal
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
		MOVE #$2300,SR

		IFEQ demo
		MOVE.L #$00000666,$FFFF8240.W
		MOVE.L #$06660666,$FFFF8244.W
		CLR -(SP)
		TRAP #1

		ELSEIF

		MOVE.L oldsp(PC),SP
		RTS
		ENDC

oldsp		DC.L 0

; Setup MFP etc for interrupts.

set_ints	MOVE.W SR,-(SP)
		MOVE.W #$2700,SR		
		BSR flush			; flush IKBD
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

; Flush keyboard

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
flok		RTS

old_mfp		DS.L 32				; saved mfp vects etc

; Wait for a vbl

Wait_Vbl	MOVE.W vbl_timer(pc),d0
.wait_vbl	CMP.W vbl_timer(pc),d0
		BEQ.S .wait_vbl
		RTS

; The Vbl - simple triggers off timers and clears palette.

first_vbl	MOVEM.L D0-D7/A0-A6,-(SP)
		IFNE demo
		JSR $504
		ENDC
		MOVEM.L (SP)+,D0-D7/A0-A6
		MOVE.L #vbl,$70.W		; install main vbl
		ADDQ #1,vbl_timer
		RTE
			
vbl		MOVE.B #99,$FFFFFA1F.W		; set off timer(top border)
		MOVE.B #4,$FFFFFA19.W
		CLR.B $FFFFFA1B.W
		MOVE.B #48,$FFFFFA21.W		; trigger hbl(for SPX display)
		MOVE.L #setpal1,$120.w
		MOVE.B #8,$FFFFFA1B.W
		TST.B doscroll_flag
		BEQ.S .nodosc
		MOVE.B #163,$FFFFFA21.W		
.nodosc		MOVEM.L D0-A6,-(SP)
		MOVE #$8240,A0
		MOVEQ #0,D0
		REPT 8
		MOVE.L D0,(A0)+
		ENDR
		IFNE demo
		JSR $504
		ENDC
		BSR fadein
		BSR fadeout
		TST.B doscroll_flag
		BEQ.S .nodoscroll
		BSR Do_bufscroll
.nodoscroll
		MOVEM.L (SP)+,D0-A6
		ADDQ #1,vbl_timer
		RTE
doscroll_flag	DC.B 0
scrolldone	DC.B 0

lpal		dc.w $000,$7DF,$E5F,$6CF,$D4F,$5B7,$C3E,$4A6
		dc.w $B2D,$395,$A1C,$284,$90B,$103,$80A,$809
currpal		ds.w 16
vbl_timer	ds.w 1

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
		MOVEM.L currpal(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		MOVEM.L (SP)+,D0-D7/A0-A1
phbl		RTE

no_lines	DC.W 150
pic_Y		DC.W 151

setpal1		MOVE #$2700,SR
		MOVEM.L D0-D1/A0-A4,-(SP)
		MOVE.L #fontrast1,$120.W
		MOVE.L pal_ptr(PC),A3
		MOVEQ #0,D1
		MOVE.B $FFFF8209.W,D1
mod1		SUB.B #0,D1			; subtract low 8 bits(scrn ptr)
		JMP noplist(PC,D1)
noplist		DCB.W 71,$4E71
		DCB.W 128,$4e71
		MOVE #$8240,A4
		MOVE no_lines(PC),D1			; 195 (-1 dbf) lines
		SUBQ #1,D1
		BMI.S nodomain
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
nodomain	TST.B doscroll_flag
		BNE.S .nosc
		CLR.B $FFFFFA1B.W
.nosc		MOVEQ #0,D0
		REPT 8
		MOVE.L D0,(A4)+
		ENDR
		MOVEM.L (sp)+,D0-D1/A0-A4
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

fadein:		tst.b fadeinflag
		beq.s .endfade
		move.l fadein_pal_ptr(pc),a0
		move.l fadein_cur_ptr(pc),a1
		move.w fadein_tim(pc),d0
		move.w fadein_nocols(pc),d7
		subq #1,d7
.lp		bsr calc1
		move.w d3,(a1)+
		dbf d7,.lp
		addq #1,d0
		cmp #$11,d0
		bne.s .notendfade
		clr d0
		sf fadeinflag
.notendfade	move.w d0,fadein_tim
.endfade	rts

fadeout:	tst.b fadeoutflag
		beq.s .endfade
		move.l fadeout_pal_ptr(pc),a0
		move.l fadeout_cur_ptr(pc),a1
		moveq #$10,d0
		sub.w fadeout_tim(pc),d0
		move.w fadeout_nocols(pc),d7
		subq #1,d7
.lp		bsr calc1
		move.w d3,(a1)+
		dbf d7,.lp
		move.w fadeout_tim(pc),d0
		addq #1,d0
		cmp #$11,d0
		bne.s .notendfade
		clr d0
		sf fadeoutflag
.notendfade	move.w d0,fadeout_tim
.endfade	rts

calc1		move.w (a0)+,d1
		move.w d1,d2
		and #$007,d1
		mulu d0,d1
		lsr #4,d1
		move.w d1,d3
		move.w d2,d1
		and #$070,d1
		mulu d0,d1
		lsr #4,d1
		and #$070,d1
		or.w d1,d3
		and #$700,d2
		mulu d0,d2
		lsr #4,d2
		and #$700,d2
		or.w d2,d3
		rts

fadein_pal_ptr	dc.l 0
fadein_cur_ptr	dc.l 0
fadein_nocols	dc.w 0
fadein_tim	dc.w 0
fadeinflag:	dc.b 0
	
fadeout_pal_ptr:dc.l 0
fadeout_cur_ptr:dc.l 0
fadeout_nocols	dc.w 0
fadeout_tim	dc.w 0
fadeoutflag:	dc.b 0	

; Set the Screen address and hardware scroll up etc.

SetScreen	MOVEM.L D0-D7/A0-A6,-(sp)
		MOVE.W ybase_position(PC),D0
		ADDQ.W #1,D0
		CMP.W #8,D0
		BNE.S .ok
		MOVEQ #0,D0
.ok		MOVE.W D0,ybase_position
		MOVE.W D0,D1
		MOVE.W pic_Y(PC),D2
		MOVE #150,D4
		SUB.W D2,D4
		BGE.S .okY
		CLR D4
		CLR D2 
.okY		MOVE.W D4,no_lines
		MOVE.W D2,D3
		MULU #160,D2
		MULU #96,D3
		MULU #160*220,D0
		MULU #(96*150)+32,D1
		ADD.L #pic+(8*160),D0
		ADD.L #pal,D1
		ADD.L D2,D0
		ADD.L D3,D1
		MOVE.L D0,this_base		; this frames base..
		MOVE.L D1,pal_ptr
		
		MOVEQ #0,D1
		MOVE.B D0,D1			; lower byte(screen address)
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W		; upper 16 bits
SetHscroll	MOVE.B D1,mod1+3
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
		MOVEM.L (SP)+,D0-D7/A0-A6
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
		ST.B scrolldone
		MOVE.B (A0),D0
.notwrap	CMP.B #1,D0
		BNE.S .notsetspeed
		MOVE.B 1(A0),ovscrlspeed+1
		ADDQ.L #2,A0
		BRA.S .fetchchar
.notsetspeed	ADD.W D0,D0
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
.updatebuflp	MOVE.W (A6),D3
		SWAP D3
		MOVE.W (A5),D3
		LEA 120(A5),A5 
		LEA 120(A6),A6 
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
		ADD.L #211*160,A2
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
ovthischar	DC.W 64,64
ovtext		DC.B "             --   WOW!!!! JUST TAKE A LOOK AT THIS LITTLE BEAUTY!!"
		DC.B "   BOY DID THIS TAKE A LOT OF HARD WORK TO CODE...     "
		DC.B "   BUT I THINK YOU'LL AGREE THAT THE RESULT IS WELL WORTH IT!!!!!         "      
		DC.B 1,8,"                  "
		DC.B 1,4," FIVE CONVERSION PROGRAMS WERE USED! AND IT TOOK OVERALL ABOUT HALF AN HOUR PER FRAME!!!     "
		DC.B "THE ANIMATION IS MADE UP FROM 8 SPECTRUM 512 PICTURES AND IS ANIMATED USING SYNC SCROLLING.      "
		DC.B "THE ACTUAL ORIGINAL AMIGA FRAMES WERE GENERATED IN A PD RAYTRACING PROGRAM WHICH WAS WRITTEN BY THE AMIGA CODER."
		DC.B " SOME PEOPLE THOUGHT THIS COULD NOT BE CONVERTED TO THE ST... I HOPE I HAVE PROVED THEM WRONG...     "		
		DC.B "I SUSPECT THAT YOU'VE PROBABLY HAD ENOUGH OF THIS PART "
 		DC.B "SO LETS LEAVE THIS PART AND MOVE ON... "
		DC.B "                            "
		DC.B 0
		EVEN

phfontbuf	INCBIN D:\HALLUCIN.DEM\PHN_RAY.FRC\RAY_FRAC.INC\ENIG161P.FNT

; Insert(copy) logo into the frames of the raytraced fractal 

Copy_Logo	LEA logo(PC),A0
		LEA pic+(18*160),A1
		MOVEQ #8-1,D1
.lp2		MOVE.L A0,A2
		MOVE.L A1,A3
		MOVE.W #(32*160)/8-1,D0
.lp		MOVE.L (A2)+,(A3)+
		MOVE.L (A2)+,(A3)+
		DBF D0,.lp
		ADD.L #220*160,A1
		DBF D1,.lp2
		LEA phscbuffer,A0
		MOVE.W #(phbufsize/2*16)-1,D7
.lp3		CLR.W (A0)+
		DBF D7,.lp3
		RTS

trig_tab	dc.l	$0000019B,$032304BE,$064507DE,$09630AF9,$0C7C0E0E 
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
		
		SECTION DATA

logo		INCBIN D:\HALLUCIN.DEM\PHN_RAY.FRC\RAY_FRAC.INC\PHN_LOGO.DAT

pic		ds.w 8*160
		incbin ray_frac.dat
pal		incbin ray_frac.pal

		SECTION BSS
LINE_JMPS	ds.l 7*128
		DS.L 159
my_stack	DS.L 3			; our own stack..

		DS.W 8
phscbuffer	
		REPT 16
		DS.B phbufsize
		ENDR
		DS.W 8


