;-----------------------------------------------------------------------;
;  The End Part - Credits / Various Greetings / Messages etc etc.	;
;  16khz 4 channel NoisePacker Music. (full volume variation)		;								;
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


start		LEA my_stack,SP
		BSR init_screen			; setup screen
		BSR SETUPSCROLL			; setup hscroll
		BSR init_vertstar
		IFNE demo
		JSR $508
		ENDC
		MOVE.W #$2700,SR
		MOVEQ #1,D0
		MOVEQ #0,D1
		BSR rotfile+4			; go!
		BSR set_ints			; setup ints
		MOVE #$2300,SR			; go!
		BSR small_delay
		BSR small_delay			; delay
		BSR Fade_in			; fade in screen
		IFNE demo
.lp		BRA.S .lp
		ELSEIF
wait_key	BSR wait_vbl
		CMP.B #$39,$FFFFFC02.W
		BNE.S wait_key
restore		MOVE #$2700,SR			; if run from assem
		BSR restore_ints		; restore old stuff
		MOVE #$2300,SR
		CLR -(SP)			; and then exit...
		TRAP #1
		ENDC				; otherwise...!!
		
; Initialise ints and vectors.

set_ints:	MOVEQ #$1A,D0			; joysticks off
		BSR Write_ikbd
		MOVEQ #$12,D0			; mouse off.
		BSR Write_ikbd
		BSR flush			; flush keyboard
		LEA old_mfp+32(PC),A0
		MOVEM.L $FFFF8240.W,D0-D7
		MOVEM.L D0-D7,-32(A0)
		MOVE.B $FFFFFA07.W,(A0)+
	        MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
        	MOVE.B $FFFFFA15.W,(A0)+
	        MOVE.B $FFFFFA19.W,(A0)+	; save mfp
	        MOVE.B $FFFFFA1D.W,(A0)+	
        	MOVE.B $FFFFFA1F.W,(A0)+
	        MOVE.B $FFFFFA25.W,(A0)+	
		MOVE.L $68.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $110.W,(A0)+
		MOVE.L $120.W,(A0)+
		MOVE.L $134.W,(A0)+
            	MOVE.B #$21,$FFFFFA07.W
		MOVE.B #$10,$fffffA09.W		; set our ints
        	MOVE.B #$21,$FFFFFA13.W
		MOVE.B #$10,$fffffA15.W
		CLR.B $FFFFFA0F.W
		CLR.B $FFFFFA11.W		; service ints
		CLR.B $FFFFFA19.W
		CLR.B $FFFFFA1B.W		
		MOVE.B #0,$fffffa1d.W
		MOVE.B #speed,$fffffa25.W	; timer d speed
		MOVE.B #1,$fffffa1d.W
		MOVE.L #phbl,$68.W
		MOVE.L #vbl,$70.W
		MOVE.L #toggle_super,$B0.W
		MOVE.L player_ptr(PC),$110.W
		MOVE.L #setpal1,$120.w
		MOVE.L #syncscroll,$134.W
		BCLR.B #3,$FFFFFA17.W		; software end of int.
		CLR.B $FFFFFA0B.W
		CLR.B $FFFFFA0D.W		; clear pendings
		LEA buffer(PC),A5
		LEA $FFFF8800.W,A6
		RTS
player_ptr	DC.L 0

; Restore ints
		IFEQ demo
restore_ints:	LEA old_mfp(PC),A0
		MOVEM.L (A0)+,D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		BSR flush
		MOVEQ #$8,D0
		BSR Write_ikbd
		MOVE.B (A0)+,$FFFFFA07.W
	        MOVE.B (A0)+,$FFFFFA09.W
        	MOVE.B (A0)+,$FFFFFA13.W
	        MOVE.B (A0)+,$FFFFFA15.W
        	MOVE.B (A0)+,$FFFFFA19.W
        	MOVE.B (A0)+,$FFFFFA1D.W
	        MOVE.B (A0)+,$FFFFFA1F.W
        	MOVE.B (A0)+,$FFFFFA25.W
		MOVE.L (A0)+,$68.W
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$110.W
		MOVE.L (A0)+,$120.W
		MOVE.L (A0)+,$134.W
		BSET.B #3,$FFFFFA17.W
		RTS
		ENDC

; Reserve Space for + clear screen

init_screen	MOVE.L #screen+256,d0
		CLR.B D0
		MOVE.L D0,log_base
		MOVE.L D0,phy_base
		MOVE.L D0,A0
		MOVE #((160*500)/16)-1,D1
		MOVEQ #0,D0
.clr		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		DBF D1,.clr
		RTS

; Mr Vbl

vbl		CLR.B $FFFFFA19.W
		MOVE.B #99,$FFFFFA1F.W
		MOVE.B #4,$FFFFFA19.W
		CLR.B $FFFFFA1B.W
		MOVE.B #28,$FFFFFA21.W
		MOVE.B #8,$FFFFFA1B.W
		MOVEM.L D0-D6/A0-A4,-(SP)
		MOVE #$8240,A0
		MOVEQ #0,D0
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		BSR set_screen	
		BSR erase_vertstars
		BSR plot_stars
		BSR Vbl_play
		MOVE.L log_base(PC),D0
		ADD.L screen_offy(PC),D0
		MOVE.L D0,phy_base
		BSR plot_vertscrl
		;MOVE.W #$400,$FFFF8240.W
		MOVEM.L (SP)+,D0-D6/A0-A4
		ST vbl_flag
		RTE

endvbl		MOVEM.L A0/A1,-(SP)
		LEA curr_pal(PC),A0
		MOVE #$8240,A1
		REPT 8
		MOVE.L (A0)+,(A1)+
		ENDR
		MOVEM.L (SP)+,A0/A1
		ST vbl_flag
		RTE

set_screen	MOVE sc_x1(PC),D0
		MULU #7*2,D0
		LEA LINE_JMPS(PC),A0
		LEA hl1+2(PC),A1
		ADDA.W D0,A0
		MOVE.L (A0)+,(A1)
		MOVE.L (A0)+,hl2-hl1(A1)
		MOVE.L (A0)+,hl3-hl1(A1)
		MOVE.L (A0)+,hl4-hl1(A1)
		MOVE.L (A0)+,hl5-hl1(A1)
		MOVE.L (A0)+,hl6-hl1(A1)
		MOVE.L (A0)+,hl7-hl1(A1)
		MOVE.L log_base(PC),D0
		ADD.L screen_offy(PC),D0
		MOVE.W D0,D1
		AND #$FF,D1
		MOVE D1,sc_x1
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		RTS

; 25 Vbl delay

small_delay	MOVEQ #24,D0
.last_delay	BSR wait_vbl
		DBF D0,.last_delay
		RTS

; Fade to white(ready for reset)

fadetowhite 	LEA credits_pal(PC),A0
		MOVEQ #15,D0
.lp		MOVE.W #$777,(A0)+
		DBF D0,.lp
		BRA Fade_in

; Fade in rout.

Fade_in		LEA curr_pal(PC),A0
		LEA credits_pal(PC),A1
		MOVEQ #6,D5		
.fade_lp	MOVEQ #6-1,D0
.spd_lp		BSR wait_vbl
		DBF D0,.spd_lp
		MOVEQ #15,D6
.col_lp		MOVE (A0),D0		; reg value
		MOVE (A1)+,D1		; dest value
		MOVE D0,D2
		MOVE D1,D3
		AND #$700,D2
		AND #$700,D3
		CMP D2,D3		
		BLE.S .R_done
		ADD #$100,D0
.R_done		MOVE D0,D2
		MOVE D1,D3
		AND #$070,D2
		AND #$070,D3
		CMP D2,D3
		BLE.S .G_done
		ADD #$010,D0
.G_done 	MOVE D0,D2
		MOVE D1,D3
		AND #$007,D2
		AND #$007,D3
		CMP D2,D3
		BLE.S .B_done
		ADDQ #$001,D0
.B_done		MOVE D0,(A0)+
		DBF D6,.col_lp
		LEA -32(A0),A0	
		LEA -32(A1),A1
		DBF D5,.fade_lp
		RTS

; Fade out rout.

Fade_out	MOVEQ #6,D5		
.fade_lp	LEA curr_pal(PC),A0
		MOVEQ #4-1,D0
.spd_lp		BSR wait_vbl
		DBF D0,.spd_lp
		MOVEQ #15,D6
.col_lp		MOVE (A0),D0		reg value
		MOVE D0,D2
		AND #$700,D2
		BEQ.S .R_done
		SUB #$100,D0
.R_done		MOVE D0,D2
		AND #$070,D2
		BEQ.S .G_done
		SUB #$010,D0
.G_done 	MOVE D0,D2
		AND #$007,D2
		BEQ.S .B_done
		SUBQ #$001,D0
.B_done		MOVE D0,(A0)+
		DBF D6,.col_lp
		DBF D5,.fade_lp
		RTS
wait_vbl	TST.B vbl_flag
		BEQ.S wait_vbl
		SF vbl_flag
		RTS
vbl_flag	DC.W 0

credits_pal	dc.w	$000,$222,$444,$033,$666,$033,$033,$033
		dc.w	$033,$010,$121,$232,$343,$454,$565,$676

curr_pal	DS.W 16

;-----------------------------------------------------------------------------;
; Sideways Starfield and Associated Routs

novert_stars    EQU 25                  ; 100 stars per plane

init_vertstar:  lea     vert_starcoords(pc),A6
                moveq   #3-1,D5         ; 3 planes
.genvertpl_lp:  move.w  #novert_stars-1,D7 ;stars-1
.genvert_lp:    bsr     Rand
                divu    #320,D0
                swap    D0
                move.w  D0,D1
                and.w   #15,D0
                move.w  #$8000,D3
                lsr.w   D0,D3
                move.w  D3,(A6)+
                lsr.w   #1,D1
                and.w   #$FFF8,D1
                bsr     Rand
                divu    #203,D0
                swap    D0
                mulu    #160,D0
                add.w   D1,D0
                move.w  D0,(A6)+
                dbra    D7,.genvert_lp
                dbra    D5,.genvertpl_lp
                rts

; Plot sideways starfield to screen!

plot_stars:	lea     vert_starcoords(pc),A1
                movea.l phy_base(PC),A2 ;screen base
		LEA (27*160)(A2),A2
		move.l a2,old_starbase
                lea     vertcse1(PC),A3
                move.l  (A3),D0
		move.w  #32640,D3
                move.w  #320,D2         ;speed for plane 1

starpl1		macro
		move.w  (A1)+,D0        ;mask
                move.w  (A1),D1         ;scrn offset
                sub.w   D2,D1
                bge.s   .ok\@
                add.w   D3,D1
.ok\@           move.w  D1,(A1)+
		move.l 	a2,a4
		add.w	d1,a4
		move.w (a4)+,d4
		or.w (a4)+,d4 
		or.w (a4)+,d4 
		or.w (a4),d4
		not.w d4
		and.w d4,d0
                or.w  D0,-6+\1(A4) 	;plot to screen
		ifne \1
		addq.w #\1,d1
		endc
		not.w d0
                move.l  D0,(a3)+        ;save position
		move.w  d1,(a3)+
		endm

.starplane_lp:  
		rept novert_stars   
		starpl1 0
		endr
                add.w   #160,D2         ; inc speed
		rept novert_stars   
		starpl1 2
		endr
                add.w   #160,D2         ; inc speed
		rept novert_stars   
		starpl1 4
		endr
                rts

; Erase that starfield

erase_vertstars:movea.l old_starbase(PC),A0
vertcse1:      	REPT novert_stars*3
                and  #$1234,2(A0)
                ENDR
		rts
old_starbase	dc.l screen

;-----------------------------------------------------------------------------;
; General Routines/tables

; Random number generator. Returns with number in D0.
; This is a tad slooow... it takes about 650 cycles.

Rand:           movem.l D1-D2/D7,-(SP)
                move.l  rndseed(PC),D1
                move.l  #2147001325,D2
mul:            move.l  D1,D3
                move.l  D2,D4
                swap    D3
                swap    D4
                move.w  D1,D7
                mulu    D2,D7
                move.w  D3,D6
                mulu    D4,D6
                mulu    D1,D4
                mulu    D2,D3
                add.l   D3,D4
                move.w  D4,D3
                swap    D3
                clr.w   D3
                clr.w   D4
                addx.w  D3,D4
                swap    D4
                add.l   D3,D7
                addx.l  D4,D6
                tst.l   D1
                bpl.s   lmul1
                sub.l   D2,D6
lmul1:          tst.l   D2
                bpl.s   lmul2
                sub.l   D1,D6
lmul2:          add.l   D6,D7
                move.l  D7,D0
                addi.l  #715136305,D0
                move.l  D0,rndseed
                swap    D0
                clr.w   D0
                swap    D0
                movem.l (SP)+,D1-D2/D7
                rts

rndseed:        DC.L 712345679

vert_starcoords:DS.L novert_stars*3

;---------------------------------------------------------------;
; Griff's sync scroll this is a new version which		;
; takes  7 scanlines.(and on a word boundary!!!)		;
; Is compaitable with 99% of st's including STE!  		;
;---------------------------------------------------------------;

; This table contains the various border removal combinations
; for adding 0 bytes,8 bytes,16 bytes etc etc....

ROUT_TAB	DC.L nothing     ;=0          0      
		DC.L length_2    ;=-2         1
		DC.L length24    ;=+24        2
		DC.L rightonly   ;=+44        3
		DC.L wholeline   ;=+70        4
		DC.L length26    ;=+26        5
		DC.L length_106  ;=-106!      6

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

playtake	EQU 32

playST		move.w (a5)+,d7			;2
		add.w $800(a5),d7
		tst.w (a5)
		bge.s .ok			
		move.l a2,a5
.ok		add d7,d7			;1
		add d7,d7			;1
		move.l (a1,d7.w),d7		;6
		movep.l	d7,(a6)			;6
		rts

playSTE		move.w (a5)+,d7			;2
		move.w $800(a5),d1
		tst.w (a5)
		bge.s .ok			
		move.l a2,a5
.ok		move.b (a4,d7),$d0.w
		move.b (a4,d1),$d0+1.w
		nop
		nop
		rts

play1		MACRO
		JSR (A3)
		ENDM	

syncscroll	CLR.B $FFFFFA1D.W
		CLR.B $FFFFFA19.W
		MOVEM.L D0-D1/A0-A4,-(SP)
		MOVE #$2100,SR
		STOP #$2100
		MOVE #$2700,SR
		LEA playST(PC),A2
		LEA playSTE(PC),A3
		MOVE.B ste_flag(PC),D0
		BNE.S .ok
		MOVE.L A2,A3
.ok		LEA ste_tab(PC),A4
		LEA buffer(PC),A2
		LEA sndtab(PC),A1
		play1
		DCB.W 70-playtake,$4E71
		MOVE.B #0,$FFFF820A.W
		MOVE #$8209,A0
		CLR D0
		DCB.W 15,$4E71
		MOVE.B #2,$FFFF820A.W
syncloop	MOVE.B (A0),D0
		BEQ.S	syncloop
		MOVEQ #10,D1
		SUB D0,D1
		LSL D1,D0
		DCB.W 16,$4E71
		play1
		DCB.W 75-playtake,$4E71
hl1		JSR 0
hl2		JSR 0
hl3		JSR 0
hl4		JSR 0
hl5		JSR 0
hl6		JSR 0
hl7		JSR 0
		MOVE.B #1,$FFFFFA1D.W
		MOVEM.L (SP)+,D0-D1/A0-A4
phbl		RTE

setpal1		MOVE.W #$2500,SR
		PEA (A0)
		PEA (A1)
		LEA curr_pal(PC),A0
		MOVE #$8240,A1
		REPT 8
		MOVE.L (A0)+,(A1)+
		ENDR
		CLR.B $FFFFFA1B.W
		MOVE.L (SP)+,A1
		MOVE.L (SP)+,A0
		RTE


* Overscan one whole screen line - works on STE.

wholeline	MOVE.B #2,$FFFF8260.W
		MOVE.B #0,$FFFF8260.W
		DCB.W 41,$4E71
		play1
		DCB.W 87-playtake-41,$4E71
		MOVE.B #0,$FFFF820A.W
		MOVE.B #2,$FFFF820A.W
		DCB.W 8,$4e71
		MOVE.B #1,$FFFF8260.W
		MOVE.B #0,$FFFF8260.W
		RTS

* Right border only - works on STE!

rightonly	DCB.W 8,$4E71
		DCB.W 41,$4E71
		play1
		DCB.W 87-playtake-41,$4E71
		MOVE.B #0,$FFFF820A.W
		MOVE.B #2,$FFFF820A.W
		DCB.W 16,$4e71
		RTS

* Miss one word -2 bytes   - works on STE

length_2	DCB.W 49,$4E71
		play1
		DCB.W 93-playtake-49,$4E71
		MOVE.B #0,$FFFF820A.W
		MOVE.B #2,$FFFF820A.W
		DCB.W 18,$4e71
		RTS
   
* Do nothing              - works on STE!! 

nothing		DCB.W 8,$4E71
		DCB.W 41,$4E71
		play1
		DCB.W 111-playtake-41,$4E71
		RTS

* 24 bytes extra per line - works on STE

length24	MOVE.B #2,$FFFF8260.W
		MOVE.B #0,$FFFF8260.W
		DCB.W 41,$4E71
		play1
		DCB.W 86-playtake-41,$4E71
		MOVE.B #0,$FFFF820A.W
		MOVE.B #2,$FFFF820A.W
		DCB.W 9,$4E71
		MOVE.B #1,$FFFF8260.W
		MOVE.B #0,$FFFF8260.W
		RTS		

* +26 bytes  - works on ste although on ST's perhaps wobble may occur.

length26	MOVE.B #2,$FFFF8260.W
		MOVE.B #0,$FFFF8260.W
		DCB.W 41,$4E71
		play1
		DCB.W 103-playtake-41,$4E71
		MOVE.B #1,$FFFF8260.W     
		MOVE.B #0,$FFFF8260.W
		RTS		

* -106 bytes 

length_106	DCB.W 41,$4E71
		MOVE.B #2,$FFFF8260.W
		MOVE.B #0,$FFFF8260.W
		play1
		DCB.W 70-playtake,$4e71
		RTS		

* SETUP HARDWARE SCROLL ROUTS

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

LINE_JMPS	DS.L 7*128

* Flush keyboard

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
flok		RTS

; Write D0 to IKBD

Write_ikbd	BTST.B #1,$FFFFFC00.W
		BEQ.S Write_ikbd
		MOVE.B D0,$FFFFFC02.W
		RTS

; Vertical scroll routine!

vert_lines	EQU 203

plot_vertscrl:	LEA infont_off(PC),A0
		TST.B 16(A0)
		BNE .tisdone
		MOVE.L 6(A0),D0
		CMP.L #(vert_lines)*160,D0
		BNE.S .notres
		MOVEQ #0,D0
.notres		ADD.L #160,D0
		MOVE.L D0,6(A0)
		MOVE.L 2(A0),A1
		MOVE.W (A0),D0
		ADD #8,D0
		CMP #16*8,D0			; next text row?
		BNE.S .notnextlne
		MOVEQ #0,D0			; reset offest in char
		ADD.W 14(A0),A1			; increment scrl pointer
		ADDQ.L #1,A1			; by no_lets+1
		TST.B (A1)
		BNE.S .notwrap			; wrap?
		ST 16(A0)
		BRA .tisdone
.notwrap	MOVE.L A1,A2		
.search		MOVE.B (A2)+,D1			; find width of text row
		BNE.S .search
		SUB.L A1,A2
		MOVE.W A2,D1
		SUBQ.W #1,D1			; no chars
		MOVE.W D1,14(A0)
		LSL #3,D1			; no_chars*8
		MOVE #160,D2			; 160-(no_chars*8)
		SUB D1,D2
		MOVE.W D2,D1
		AND #15,D2
		MOVE.W D2,10(A0)		; pix offset
		LSR #1,D1
		AND #$FFF8,D1
		MOVE.W D1,12(A0)		; word offy
.notnextlne 	MOVE.W D0,(A0)
		MOVE.L A1,2(A0)
		LEA cool16fnt,A2
		ADD.W D0,A2
		MOVE.L log_base(PC),A3
		LEA (25*160)+160(A3),A3
		ADD.L 6(A0),A3			; +line offset
		LEA (vert_lines*160)(A3),A4
		MOVEQ #0,D0
		MOVEQ #0,D1
		MOVEQ #0,D2
		MOVEQ #0,D3
		MOVEQ #0,D4
		MOVEQ #0,D5
		MOVEQ #0,D6
		MOVE.L D6,A1
		REPT 5
		MOVEM.L D0-D6/A1,-(A3)
		MOVEM.L D0-D6/A1,-(A4)
		ENDR
		MOVE.L 2(A0),A1
		ADD.W 12(A0),A3			; +word offset
		MOVE.W 10(A0),D2		; shift modulo
		MOVE.W 14(A0),D0		; no of lets
		SUBQ #1,D0			; -1 for dbf
		LEA fntofflookup(PC),A0
.lp		MOVEQ #0,D4
		MOVE.B (A1)+,D4
		ADD.W D4,D4
		MOVE.L A2,A4
		ADD.W (A0,D4),A4
		MOVEQ #0,D4
		MOVEQ #0,D5
		MOVEQ #0,D6
		MOVEQ #0,D1
		MOVE.W (A4)+,D4
		MOVE.W (A4)+,D5
		MOVE.W (A4)+,D6
		MOVE.W (A4)+,D1
		ROR.L D2,D4
		ROR.L D2,D5
		ROR.L D2,D6
		ROR.L D2,D1
		OR.W D4,(A3)+
		OR.W D5,(A3)+
		OR.W D6,(A3)+
		OR.W D1,(A3)+
		SWAP D5
		MOVE.W D5,D4
		SWAP D1
		MOVE.W D1,D6
		MOVEM.L D4/D6,(A3)
		MOVEM.L -8(A3),D1/D3
		MOVEM.L D1/D3/D4/D6,(vert_lines*160)-8(A3)
		DBF D0,.lp 
.tisdone	RTS

fntofflookup	DCB.W 32,44*128
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

infont_off	DC.W -8			;0
scrl_ptr	DC.L scrluptext		;2
screen_offy	DC.L 0			;6
screen_shft	DC.W 0			;10
screen_offset	DC.W 0			;12
no_lets		DC.W 1			;14
finished	DC.W 0			;16

scrluptext	DC.B " ",0," ",0," ",0
		DC.B " ",0," ",0," ",0
		DC.B " ",0," ",0
		DC.B " ",0
		DC.B "HALLUCINATIONS",0
		DC.B " ",0
		DC.B "WAS BROUGHT TO YOU",0
		DC.B " ",0
		DC.B "BY",0
		DC.B " ",0
		DC.B "ELECTRONIC IMAGES",0
		DC.B " ",0
		DC.B "OF",0
		DC.B " ",0
		DC.B "THE INNER CIRCLE",0
		DC.B " ",0," ",0," ",0
		DC.B "- CODING -",0
		DC.B " ",0
		DC.B " ",0
		DC.B "GRIFF",0
		DC.B "THE PHANTOM",0
		DC.B " ",0," ",0," ",0
		DC.B "- GRAPHIX -",0
		DC.B " ",0
		DC.B " ",0
		DC.B "MASTER",0
		DC.B " ",0," ",0," ",0
		DC.B "- MUSIC -",0
		DC.B " ",0
		DC.B " ",0
		DC.B "SYNERGY",0
		DC.B " ",0," ",0," ",0
		DC.B "- THIS MUSIC! -",0
		DC.B " ",0
		DC.B " ",0
		DC.B "FIREFOX AND TIP",0
		DC.B " ",0," ",0," ",0
		DC.B "- DIGISYNTH CODING -",0
		DC.B " ",0
		DC.B " ",0
		DC.B " GRIFF",0
		DC.B " ",0," ",0," ",0
		DC.B "- MEGA THANX TO -",0
		DC.B " ",0
		DC.B " ",0
		DC.B "MASTER",0
		DC.B "(FOR BEING LAZY!)",0
		DC.B " ",0
		DC.B "PHENOMENA (AMIGA)",0
		DC.B "(FOR INSPIRATION)",0
		DC.B " ",0," ",0," ",0
		DC.B "- GREETS TO -",0
		DC.B " ",0
		DC.B "FINGERBOBS",0
		DC.B "DYNAMIC DUO",0
		DC.B "ST SQUAD",0
		DC.B "RUSS",0
		DC.B "ELECTRA",0
		DC.B "CHAOS",0
		DC.B "LAZER",0
		DC.B "TLB",0
		DC.B "TORMENT",0
		DC.B "OVERLANDERS",0
		DC.B "HOTLINE",0
		DC.B "DELTA FORCE",0
		DC.B "SYNC",0
		DC.B "SILENTS",0
		DC.B "KNIGHTHAWKS",0
		DC.B "OMEGA",0
		DC.B "LYNX",0
		DC.B "PHALANX",0
		DC.B "ALLIANCE(S)",0
		DC.B "ULM",0
		DC.B "SEWERSOFT",0
		DC.B "TCB",0
		DC.B "ARMADA",0
		DC.B "NEXT",0
		DC.B "TEX",0
		DC.B "ELITE",0
		DC.B "BBC",0
		DC.B "SUB HUMANS",0
		DC.B "SUPERIOR",0
		DC.B "SYNDICATE",0	
		DC.B "POMPEY PIRATES",0
		DC.B "PIXEL TWINS",0
		DC.B "UNTOUCHABLES",0
		DC.B "AND EVERYONE ELSE...",0
		DC.B " ",0
		DC.B "---------------",0
		DC.B " ",0," ",0," ",0
		DC.B "- AMIGA GREETS TO -",0
		DC.B " ",0
		DC.B "PHENOMENA",0
		DC.B "ANARCHY",0
		DC.B "SILENTS",0
		DC.B "CRUSADERS",0
		DC.B "REBELS",0
		DC.B "BUDBRAIN",0
		DC.B "SCOOPEX",0
		DC.B "RED SECTOR",0
		DC.B "KEFRENS",0
		DC.B "QUARTEX",0
		DC.B "DEXION",0
		DC.B "AXIS",0
		DC.B " ",0
		DC.B "---------------",0
		DC.B " ",0," ",0," ",0
		DC.B "- MY PERSONAL -",0
		DC.B "- GREETS GO TO -",0
		DC.B " ",0
		DC.B "NIC AND THE REST!",0
		DC.B " ",0
		DC.B "STEWART GILRAY",0
		DC.B " ",0
		DC.B "ANDREW BUCHCAN",0
		DC.B " ",0
		DC.B "IAN KEOGH",0
		DC.B " ",0
		DC.B "ARCHIE AND CO.",0
		DC.B " ",0
		DC.B "MARCUS AND CO.",0
		DC.B " ",0
		DC.B "CRAZE (OF CHAOS)",0
		DC.B " ",0
		DC.B "KEITH MCMURTRIE",0
		DC.B " ",0
		DC.B "TIM AND CO.",0
		DC.B " ",0
		DC.B "JAMES(CARDIFF)",0
		DC.B " ",0
		DC.B "NIGEL (STICK)",0
		DC.B " ",0
		DC.B "MIKE(CARTERTON)",0
		DC.B " ",0
		DC.B "PHOTON(OF LAZER)",0
		DC.B " ",0
		DC.B "MR BEE (OVR)",0
		DC.B " ",0
		DC.B "HUMUNGUS (OVR)",0
		DC.B " ",0
		DC.B "DOUGE DE MAUVE",0
		DC.B " ",0
		DC.B "---------------",0
		DC.B " ",0," ",0," ",0
		DC.B "- ALSO SOME LOCAL -",0
		DC.B "- GREETS TO -",0
		DC.B " ",0
		DC.B "BEALER",0
		DC.B "(TRACEY OR SHARON?)",0
		DC.B "(DOES IT MATTER???)",0
		DC.B " ",0
		DC.B "DODGE",0
		DC.B "(TRIPPED LATELY?)",0
		DC.B " ",0
		DC.B "SCHMOO",0
		DC.B "(HOPE U GET TO UNI)",0
		DC.B " ",0
		DC.B "JONATHAN",0
		DC.B "(I OWE YA A DRINK!)",0
		DC.B " ",0
		DC.B "DAZZER",0
		DC.B "(HOWS THE CAR..)",0
		DC.B " ",0
		DC.B "TRUMPSKI",0
		DC.B "(!!RAVE ON!!)",0
		DC.B " ",0
		DC.B "---------------",0
		DC.B " ",0," ",0," ",0

		DC.B "- SOME UNI -",0
		DC.B "- GREETS TO -",0
		DC.B " ",0
		DC.B "WAAAAAAAYYYNNNE!!",0
		DC.B "(SORRY AS USUAL...)",0
		DC.B " ",0

		DC.B "LYNDON",0
		DC.B "(MR SPLIFF)",0
		DC.B " ",0

		DC.B "DUNCAN",0
		DC.B "(MR MENSA MK 2)",0
		DC.B " ",0

		DC.B "ANDY",0
		DC.B "(FOOK AWF!)",0
		DC.B " ",0

		DC.B "GEORGE",0
		DC.B "(MR BALL CONTROL)",0
		DC.B " ",0

		DC.B "STO",0
		DC.B "(MR LEG CONTROL)",0
		DC.B " ",0

		DC.B "BO",0
		DC.B "(MR METAL)",0
		DC.B " ",0

		DC.B "TABITHA",0
		DC.B "(AKA THE SQUIRREL)",0
		DC.B "(GOOOOOODDDDAAAAY!)",0
		DC.B " ",0

		DC.B "NICK THE ALKI",0
		DC.B "(WOMAN TROUBLE?)",0
		DC.B " ",0

		DC.B "ALI WIGGY",0
		DC.B "(AKA MR CHESTWIG)",0
		DC.B " ",0

		DC.B "AND THE REST...",0
		DC.B " ",0
		DC.B " ",0
		DC.B "---------------",0

		DC.B " ",0," ",0," ",0
		DC.B "- HARDWARE USED -",0
		DC.B "- MAKING THIS DEMO -"
		DC.B " ",0
		DC.B " ",0
		DC.B "ATARI 1040STFM",0
		DC.B "ATARI 520 STE(4MB)",0
		DC.B "SONY TRINITRON T.V",0
		DC.B "AMIGA 500 + 512K",0
		DC.B "CASIO FX-115N",0
		DC.B " ",0," ",0," ",0
		DC.B "- SOFTWARE USED -",0
		DC.B "- MAKING THIS DEMO -"
		DC.B " ",0
		DC.B " ",0
		DC.B "DEVPAC ST V2.25",0
		DC.B "TURBO ASM V1.76",0
		DC.B "GFA BASIC V3.5",0
		DC.B "DEGAS ELITE",0
		DC.B "FCOPY PRO",0
		DC.B "ALTAIR PACKER 3.3",0
		DC.B "BOOTRAM 2 BY JMR!",0
		DC.B " ",0," ",0," ",0
		DC.B "COMING SOON(!!)",0
		DC.B "FROM INNER CIRCLE ",0
		DC.B " ",0
		DC.B "THE GENETIX DEMO",0
		DC.B "(A 2 DISK MEGA DEMO)",0 
		DC.B " ",0," ",0," ",0
		DC.B " ",0," ",0," ",0
		DC.B "- THE END -",0
		DC.B " ",0
		DC.B "AN INNER CIRCLE",0
		DC.B "PRODUCTION (C) 1992",0
		DC.B " ",0," ",0," ",0
		DC.B " ",0," ",0
		DC.B 0,0

		EVEN


log_base	DC.L 0
phy_base	DC.L 0
sc_x1		DC.W 0
vbl_timer	DC.W 0
old_mfp		DS.L 34

;-----------------------------------------------------------------------;
;									;
;	     Noise-Packer Replay Routine (ST/STE driver)		;
;									;
; 	   Programmed By Martin Griffiths August 31st 1991		;
;									;
;-----------------------------------------------------------------------;
; This Version uses A5/A6/D7 - leaves 28000 cycles free at 16khz.(ap 20%)

rotfile		BRA.W Vbl_play
		BRA.W Init_ST
		BRA.W stop_ints
		DC.L vol_bitflag-rotfile

speed		EQU 39

freq_tab	DS.L 1
		INCBIN FREQ39.BIN

Init_ST		LEA vol_bitflag(PC),A0	
		BSET #0,(A0)		; still fading.
		LEA fadeINflag(PC),A0
		SF (A0)			; reset fade IN flag 
		LEA fadeOUTflag(PC),A0
		SF (A0)			; reset fade OUT flag
		TST.B D0		
		BNE.S .init_music

; Deinitialise music - turn off/fade out.

.deinit_music	TST.B D1		; any fade down?
		BNE.S .trigfadedown
		LEA global_vol(PC),A0
		MOVE.W #$0,(A0) 	; turn off music
		RTS
.trigfadedown	LEA fadeOUTflag(PC),A0
		ST.B (A0)+
		MOVE.B D1,(A0)+
		MOVE.B D1,(A0)+
		RTS

; Initialise music - turn on/fade in.

.init_music	TST.B D1
		BNE.S .trigfadein
		LEA global_vol(PC),A0
		MOVE.W #$40,(A0) 	; assume no fade in.
		BSR mt_init
		BRA STspecific
.trigfadein	LEA global_vol(PC),A0
		MOVE.W #$0,(A0) 	; ensure zero to start with!
		LEA fadeINflag(PC),A0
		ST.B (A0)+
		MOVE.B D1,(A0)+
		MOVE.B D1,(A0)+
		BSR mt_init
		BRA STspecific

vol_bitflag	DC.W 0
global_vol	DC.W 0
fadeOUTflag	DC.B 0
fadeOUTcurr	DC.B 0
fadeOUTspeed	DC.B 0
fadeINflag	DC.B 0
fadeINcurr	DC.B 0
fadeINspeed	DC.B 0
		EVEN

; Vbl player - This is THE  'Paula' Emulator.

Vbl_play:	MOVE.B music_on(PC),D0		; music on?
		BEQ skipit			; if not skip all!

.do_fadein	LEA fadeINflag(PC),A0
		TST.B (A0)			; are we fadeing down?
		BEQ.S .nofadein
		SUBQ.B #1,1(A0)			; curr count-1
		BNE.S .nofadein
		MOVE.B 2(A0),1(A0)		; reset count
		LEA global_vol(PC),A1
		CMP #$40,(A1)			; reached max?
		BLT.S .notinyet
		SF (A0)				; global vol=$40!
		LEA vol_bitflag(PC),A1
		BCLR #0,(A1)			; signal fade done
		BRA.S .nofadein
.notinyet	ADDQ #1,(A1)			; global vol+1
.nofadein
.do_fadedown	LEA fadeOUTflag(PC),A0
		TST.B (A0)			; are we fadeing down?
		BEQ.S .nofadedown
		SUBQ.B #1,1(A0)			; curr count-1
		BNE.S .nofadedown
		MOVE.B 2(A0),1(A0)		; reset count
		LEA global_vol(PC),A1
		TST.W (A1)
		BNE.S .notdownyet
		SF (A0)				; global vol=0!
		LEA vol_bitflag(PC),A1
		BCLR #0,(A1)			; signal fade done
		BRA.S .nofadedown
.notdownyet	SUBQ #1,(A1)			; global vol-1
.nofadedown	
		MOVE.B ste_flag(PC),D0
		BEQ.S .notste
		BSR Set_DMA
.notste		MOVE.L lastwrt_ptr(PC),A4	; A4 points to place to fill
		MOVE.L A5,D0			; read current frame(ST)
		LEA lastwrt_ptr(PC),A0
		MOVE.L D0,(A0)
		SUB.L A4,D0
		BEQ skipit
		BHI.S higher
		ADDI.W #$800,D0			; abs
higher		LSR.W #1,D0
		LEA endbuffer(PC),A0
		MOVE.L A0,D1
		SUB.L A4,D1
		LSR.W #1,D1
		LEA fillx1(PC),A0
		CLR.W (A0)			; assume no buf overlap
		CMP.W D1,D0			; check for overlap
		BCS.S higher1
		MOVE.W D1,(A0)			; ok so there was overlap!!
higher1		SUB.W (A0),D0			; subtract any overlap
		MOVE.W D0,2(A0)			; and store main
		LEA.L Voice1Set(PC),A0		; Setup Chan 1
		LEA.L ch1s(PC),A3
		MOVEQ #0,D4
		BSR SetupVoice		
		LEA.L Voice2Set(PC),A0		;      "     2
		LEA.L ch2s(PC),A3
		MOVEQ #1,D4
		BSR SetupVoice		
		LEA.L Voice3Set(PC),A0  	;      "     3
		LEA.L ch3s(PC),A3
		MOVEQ #2,D4
		BSR SetupVoice
		LEA.L Voice4Set(PC),A0  	;      "     4
		LEA.L ch4s(PC),A3
		MOVEQ #3,D4
		BSR SetupVoice
		BSR Goforit
		TRAP #12
		BRA mt_music			; jump to sequencer
exitvbl		TRAP #12
skipit		RTS

		RSRESET
Vaddr		RS.L 1
Vfrac		RS.W 1
Voffy		RS.W 1
Vfreq		RS.L 1				; structure produced
Vvoltab		RS.W 1				; from 'paula' data
Vlpaddr		RS.L 1
Vlpoffy		RS.W 1
Vlpfreq		RS.L 1

; Routine to add/move one voice to buffer. The real Paula emulation part!!

SetupVoice	MOVE.L sam_start(A3),A2		; current sample end address(shadow amiga!)
		MOVEM.W sam_length(A3),D0/D1/D2	; offset/period/volume
		MULU global_vol(PC),D2
		LSR #6,D2			; /64
		ADD.W D1,D1
		ADD.W D1,D1
		LEA freq_tab(PC),A1
		MOVE.L (A1,D1),D1
zero		LSL.W #8,D2			; offset into volume tab
		NEG.W D0			; negate sample offset
		MOVE.W shadow_dmacon(PC),D6
		BTST D4,D6
		BNE.S .vcon2
		MOVEQ #0,D1			; clear freq if off.
		MOVEQ #0,D2			; volume off for safety!!
.vcon2		LEA nulsamp+2(PC),A1
		CMP.L A1,A2
		BNE.S .vcon
		MOVEQ #0,D1			; clear freq if off.
		MOVEQ #0,D2			; volume off for safety!!
.vcon		MOVE.L sam_lpstart(A3),A1	; loop addr
		MOVE.W sam_lplength(A3),D5	; loop length
		NEG.W D5			; negate it.
		MOVE.L D1,D6			; freq on loop
		CMP.W #-2,D5
		BNE.S isloop
.noloop		MOVEQ #0,D6			; no loop-no frequency
		LEA nulsamp+2(PC),A1		; no loop-point to nul
isloop		SWAP D1
		SWAP D6
		MOVE.L A2,(A0)+			; store address
		MOVE.W sam_frac(A3),(A0)+	; store fraction
		MOVE.W D0,(A0)+			; store offset
		MOVE.L D1,(A0)+			; store int.w/frac.w
		MOVE.W D2,(A0)+			; address of volume tab.
		MOVE.L A1,(A0)+			; store loop addr
		MOVE.W D5,(A0)+			; store loop offset.
		MOVE.L D6,(A0)+			; store loop freq int.w/frac.w
		RTS

; Make that buffer! (channels are paired together!)

Goforit		PEA (A4)			; save buff ptr
channels12	MOVE.L Voice1Set(PC),A0		; ptr to end of each sample!
		MOVE.L Voice2Set(PC),A1
		MOVE.L Voice1Set+Vfrac(PC),D0	; frac.w/int.w offset
		MOVE.L Voice2Set+Vfrac(PC),D1
		MOVE.L Voice1Set+Vfreq(PC),A2	; frac.w/int.w freq
		MOVE.L Voice2Set+Vfreq(PC),A3	
		MOVE.W fillx1(PC),D6	
		BSR add12			; fill first bit
		MOVE.W fillx2(PC),D6
		MOVE.W fillx1(PC),D4
		BEQ.S .nores
		LEA.L buffer(pc),A4		; (overlap case)
.nores		BSR add12			; and do remaining
		LEA ch1s(PC),A3
		NEG.W D0			; +ve offset(as original!)
		MOVE.L A0,sam_start(A3)		; store voice address
		MOVE.W D0,sam_length(A3)	; store offset for next time
		SWAP D0
		MOVE.W D0,sam_frac(A3)		; store frac part
		LEA ch2s(PC),A3
		NEG.W D1		
		MOVE.L A1,sam_start(A3)		; same for chan 2
		MOVE.W D1,sam_length(A3)		
		SWAP D1
		MOVE.W D1,sam_frac(A3)	
		MOVE.L (SP)+,A4

		LEA $802(A4),A4

channels34	MOVE.L Voice3Set(PC),A0		; ptr to end of each sample!
		MOVE.L Voice4Set(PC),A1
		MOVE.L Voice3Set+Vfrac(PC),D0	; frac.w/int.w offset
		MOVE.L Voice4Set+Vfrac(PC),D1
		MOVE.L Voice3Set+Vfreq(PC),A2
		MOVE.L Voice4Set+Vfreq(PC),A3	; frac.w/int.w freq
		MOVE.W fillx1(PC),D6	
		BSR add34			; fill first bit
		MOVE.W fillx2(PC),D6
		MOVE.W fillx1(PC),D4
		BEQ.S .nores
		LEA.L buffer1(pc),A4		; (overlap case)
.nores		BSR add34			; and do remaining
		LEA ch3s(PC),A3
		NEG.W D0			
		MOVE.L A0,sam_start(A3)			
		MOVE.W D0,sam_length(A3)	; as above
		SWAP D0
		MOVE.W D0,sam_frac(A3)		
		LEA ch4s(PC),A3
		NEG.W D1		
		MOVE.L A1,sam_start(A3)			
		MOVE.W D1,sam_length(A3)		
		SWAP D1
		MOVE.W D1,sam_frac(A3)	
		RTS

; Move channels 1 and 2 to the buffer.

add12		SUBQ #1,D6			; -1 (dbf)
		BMI exitadd12			; none to do!?
.make_chans1_2	TRAP #12
		MOVEQ #0,D4
		MOVE.L voltab_ptr(PC),D2
		MOVE.W Voice1Set+Vvoltab(PC),D4
		ADD.L D4,D2			; volume tab chan 1
		MOVE.L voltab_ptr(PC),D3
		MOVE.W Voice2Set+Vvoltab(PC),D4
		ADD.L D4,D3			; volume tab chan 2
		MOVEQ #0,D4
		MOVEQ #0,D5
make12lp	MOVE.B (A0,D0.W),D2
		MOVE.L D2,A7
		MOVE.B (A7),D4
		MOVE.B (A1,D1.W),D3
		MOVE.L D3,A7
		MOVE.B (A7),D5
		ADD.W D5,D4
		MOVE.W D4,(A4)+
		MOVEQ #0,D4
		ADD.L A2,D0
		ADDX D4,D0
		BGE.S lpvc1
contlp1		ADD.L A3,D1
		ADDX D4,D1
contlp2		DBGE D6,make12lp
		BGE.S lpvc2
		TRAP #12
exitadd12	RTS

lpvc1		MOVE.L Voice1Set+Vlpfreq(PC),A2
		MOVE.L Voice1Set+Vlpaddr(PC),A0		; loop voice 1
		ADD.W  Voice1Set+Vlpoffy(PC),D0		
		BRA.S contlp1

lpvc2		MOVE.L Voice2Set+Vlpfreq(PC),A3
		MOVE.L Voice2Set+Vlpaddr(PC),A1		;      "     2
		ADD.W  Voice2Set+Vlpoffy(PC),D1		
		BRA.S contlp2

; Add channels 3 and 4 channels 1+2 and create soundchip buffer play.

add34		SUBQ #1,D6			; -1(dbf)
		BMI exitadd34			; none to do?
.make_chans3_4	TRAP #12
		MOVEQ #0,D4
		MOVE.L voltab_ptr(PC),D2
		MOVE.W Voice3Set+Vvoltab(PC),D4
		ADD.L D4,D2			; volume tab chan 3
		MOVE.L voltab_ptr(PC),D3
		MOVE.W Voice4Set+Vvoltab(PC),D4
		ADD.L D4,D3			; volume tab chan 4
		MOVEQ #0,D4
		MOVEQ #0,D5
make34lp	MOVE.B (A0,D0.W),D2
		MOVE.L D2,A7
		MOVE.B (A7),D4
		MOVE.B (A1,D1.W),D3
		MOVE.L D3,A7
		MOVE.B (A7),D5
		ADD.W D5,D4
		MOVE.W D4,(A4)+
		MOVEQ #0,D4
		ADD.L A2,D0
		ADDX D4,D0
		BGE.S lpvc3
contlp3		ADD.L A3,D1
		ADDX D4,D1
contlp4		DBGE D6,make34lp
		BGE.S lpvc4
		TRAP #12
exitadd34	RTS

lpvc3		MOVE.L Voice3Set+Vlpfreq(PC),A2
		MOVE.L Voice3Set+Vlpaddr(PC),A0		; loop voice 3
		ADD.W  Voice3Set+Vlpoffy(PC),D0
		BRA.S contlp3

lpvc4		MOVE.L Voice4Set+Vlpfreq(PC),A3
		MOVE.L Voice4Set+Vlpaddr(PC),A1		;      "     4
		ADD.W  Voice4Set+Vlpoffy(PC),D1	
		BRA.S contlp4

; YM 2149 interrupt - fucking bastard shite ST chip(designer cunts)

player		MOVE.W (A5)+,D7
		ADD.W $800(A5),D7
		TST.W (A5)
		BMI.S .reset
.cont		ADD.W D7,D7
		ADD.W D7,D7
		MOVE.L sndtab(PC,D7),D7
		MOVEP.L D7,(A6)	
		RTE
.reset		LEA buffer(PC),A5
		BRA.S .cont
sndtab		INCBIN 2CHANSND.TAB	

playerSTE	MOVE.W (A5)+,D7
		MOVE.W $800(A5),A6
		TST.W (A5)
		BMI.S .reset
.cont		MOVE.B ste_tab(PC,D7),$d0.w
		MOVE.W A6,D7
		MOVE.B ste_tab(PC,D7),$d1.w
		RTE
.reset		LEA buffer(PC),A5
		BRA.S .cont

ste_tab		dcb.b 128,$80
i		set -128
		rept 256
		dc.b i
i		set i+1
		endr
		dcb.b 128,$7f

buffer		DS.W $400	; circular(ring) buffer
endbuffer	DC.W -1
buffer1		DS.W $400
endbuffer1	DC.W -1

		DS.L 2
nulsamp		DS.L 4		; nul sample
lastwrt_ptr 	DC.L 0		; last pos within ring buffer
music_on	DC.B 0		; music on flag
ste_flag	DC.B 0		; STE flag!
fillx1		DC.W 0		; circular buffer
fillx2		DC.W 0		; amounts(main and wrap amounts)
voltab_ptr	DC.L 0		; ptr to volume table
initialval	DC.L 0

; Paula emulation storage structure.

		RSRESET

sam_start	RS.L 1				; sample start
sam_length	RS.W 1				; sample length
sam_period	RS.W 1				; sample period(freq)
sam_vol		RS.W 1				; sample volume
sam_lpstart	RS.L 1				; sample loop start
sam_lplength	RS.W 1	 			; sample loop length
sam_frac	RS.W 1				; sample fraction(freq part)
sam_vcsize	RS.B 1				; structure size.

ch1s		DS.B sam_vcsize
ch2s		DS.B sam_vcsize			; shadow channel regs
ch3s		DS.B sam_vcsize
ch4s		DS.B sam_vcsize
shadow_dmacon	DS.W 1

Voice1Set	DS.L 7
Voice2Set	DS.L 7		; voice data (setup from 'paula' data)
Voice3Set	DS.L 7
Voice4Set	DS.L 7

move_dmacon	MACRO
		MOVE.W D3,saved3
		MOVE.W \1,d3
		BTST #15,D3			; set or clear?
		BNE.S .setbits\@		
.clearbits\@	NOT.W D3			; zero so clear
		AND.W D3,shadow_dmacon		; mask bits in dmacon
		BRA.S .dmacon_set\@		; and exit...
.setbits\@	OR.W d3,shadow_dmacon		; not zero so set 'em
.dmacon_set\@	MOVE.W saved3(pc),D3
		ENDM

; ST specific initialise - sets up shadow amiga registers etc

STspecific:	BSR Ste_Test
		;clr.b ste_flag
		LEA nulsamp+2(PC),A2
		MOVEQ #0,D0
		LEA ch1s(pc),A0
		BSR initvoice
		LEA ch2s(pc),A0
		BSR initvoice
		LEA ch3s(pc),A0
		BSR initvoice
		LEA ch4s(pc),A0
		BSR initvoice
		BSR Init_Voltab
		BSR Init_Buffer
		BSR start_ints
		LEA music_on(PC),A0
		ST (A0)
.nostartdma	RTS

; A0-> voice data (paula voice) to initialise.

initvoice:	MOVE.L	A2,sam_start(A0)    ; point voice to nul sample
		MOVE.W	#2,sam_length(A0)		
		MOVE.W	D0,sam_period(A0)   ; period=0
		MOVE.W	D0,sam_vol(A0)	    ; volume=0
		MOVE.L	A2,sam_lpstart(A0)  ; and loop point to nul sample
		MOVE.W	#2,sam_lplength(A0)
		MOVE.W	D0,sam_frac(A0)	    ; clear fraction part
		RTS

start_ints	LEA buffer(PC),A1
		LEA lastwrt_ptr(PC),A0
		MOVE.L A1,(A0)
		LEA ste_flag(PC),A0
		TST.B (A0)
		BEQ Setup_YM2149
Ste_Setup	LEA playerSTE(PC),A0
		MOVE.L A0,player_ptr
		LEA.L setsam_dat(PC),A1
		MOVEQ #3,D6
.mwwritx	MOVE.W #$7ff,$ffff8924.W
.mwwritx2	CMP.W #$7ff,$ffff8924.W
		BNE.S .mwwritx2			; setup the PCM chip
		MOVE.W (A1)+,$ffff8922.W
		DBF D6,.mwwritx
		CLR.B $FFFF8901.W
		BSR Set_DMA
		MOVE.B #%00000011,$FFFF8921.W 	; 50khz
		MOVE.B #3,$FFFF8901.W	  	; start STE dma.
.exitste	RTS

Set_DMA		LEA temp(PC),A1			
		LEA $d0.w,A0		
		MOVE.L A0,(A1)			
		MOVE.B 1(A1),$ffff8903.W
		MOVE.B 2(A1),$ffff8905.W	; set start of buffer
		MOVE.B 3(A1),$ffff8907.W
		LEA 2(A0),A0
		MOVE.L A0,(A1)
		MOVE.B 1(A1),$ffff890f.W
		MOVE.B 2(A1),$ffff8911.W	; set end of buffer
		MOVE.B 3(A1),$ffff8913.W
		RTS 
		
; Setup for ST YM2149

Setup_YM2149	LEA player(PC),A0
		MOVE.L A0,player_ptr
		MOVE #$8800,A0
		MOVE.B #7,(A0)
		MOVE.B #$C0,D0
		AND.B (A0),D0
		OR.B #$38,D0			; init ym2149
		MOVE.B D0,2(A0)
		MOVE #$600,D0
.setup		MOVEP.W D0,(A0)
		SUB #$100,D0
		BPL.S .setup
		RTS

; Turn off the music i.e restore old interrupts and clear soundchip.

stop_ints	LEA music_on(PC),A0		
		SF (A0)				; signal music off.
		LEA ste_flag(PC),A0
		TST.B (A0)			; ST or STE turn off?
		BEQ.S .ok			; ST?
		MOVE.B #0,$FFFF8901.W		; nop kill STE dma.
.ok		RTS
toggle_super	BCHG #13,(SP)			; toggle user/super
		RTE

save_stuff	DS.L 5

; The STE test rout...

Ste_Test	LEA ste_flag(PC),A1
		SF (A1)				; assume ST
		LEA $FFFF8205.W,A5
		MOVE.B #%10101011,D1
		MOVE.B (A5),D0
		MOVE.B D1,(A5)
		CMP.B (A5),D0
		BEQ .notSTE
		MOVE.B	D0,(a5)
.ste_found	ST (A1)				; well sorry its STE!
.notSTE		RTS

temp:		dc.l	0
setsam_dat:	dc.w	%0000000011010100  	;mastervol
		dc.w	%0000010010000110  	;treble
		dc.w	%0000010001000110  	;bass
		dc.w	%0000000000000001  	;mixer

; Make sure Volume lookup table is on a 256 byte boundary.

Init_Voltab	LEA vols+256(PC),A0
		MOVE.L A0,D0
		CLR.B D0
		LEA voltab_ptr(PC),A1
		TST.L (A1)
		BNE.S .alreadyinited
		MOVE.L D0,(A1)
		MOVE.L D0,A1
		MOVE.W #(16640/16)-1,D0
.lp		REPT 4
		MOVE.L (A0)+,(A1)+
		ENDR
		DBF D0,.lp
.alreadyinited	RTS

Init_Buffer	LEA buffer+$800(PC),A0
		MOVEQ.L #0,D0
		MOVE.L D0,D1
		MOVE.L D0,D2
		MOVE.L D0,D3
		MOVE.L D0,D4
		MOVE.L D0,D5
		MOVE.L D0,D6
		MOVE.L D0,A1
		MOVEQ #($800/64)-1,D7
.lp		MOVEM.L D0-D6/A1,-(A0)
		MOVEM.L D0-D6/A1,-(A0)
		DBF D7,.lp
		RTS

vols		ds.l 64
		INCBIN pt_volta.dat
		EVEN

; Enigma Replay

mt_init:
  LEA     mt_data(pc),A4
  LEA     L0023(PC),A6
  MOVEQ   #2,D0 
  MOVEQ   #0,D1 
  MOVEA.L A4,A3 
L0000:ADDA.W  (A4)+,A3
  MOVE.L  A3,(A6)+
  DBF     D0,L0000
  MOVE.W  (A4)+,D0
  ADDA.L  D0,A3 
  MOVE.L  D1,(A6)+
  MOVE.L  #$1060100,(A6)+ 
  MOVE.W  #-$8000,(A6)+ 
  MOVE.L  D1,(A6)+
  MOVE.L  #cmd1,(A6)+
  MOVE.L  #cmd2,(A6)+
  MOVE.L  #cmd3,(A6)+
  MOVE.L  #cmd4,(A6)+
  MOVE.L  #cmd5,(A6)+
  MOVE.L  #cmd6,(A6)+
  MOVE.L  #cmd7,(A6)+
  MOVE.L  #cmd8,(A6)+
  MOVE.L  #cmd9,(A6)+
  MOVE.L  #cmd10,(A6)+
  MOVE.L  #cmd11,(A6)+
  MOVE.L  #cmd12,(A6)+
  MOVE.L  #cmd13,(A6)+
  MOVEQ   #0,D0 
  MOVEA.L A4,A6 
  ADDA.W  -8(A4),A6 
  SUBA.W  #$C,A6
L0001:MOVE.L  A3,(A4) 
  MOVEA.L A3,A2 
  MOVE.W  14(A4),D0 
  ADD.W   D0,D0 
  ADDA.L  D0,A2 
  MOVE.L  A2,8(A4)
  MOVE.W  4(A4),D0
  ADD.W   D0,D0 
  ADDA.L  D0,A3 
  ADDA.W  #$10,A4 
  CMPA.L  A4,A6 
  BNE.S   L0001 
  RTS 

mt_music:
  MOVEQ   #0,D6 
  LEA     ch4s(PC),A4
  LEA     L0025(PC),A7
  SUBQ.B  #1,(A7) 
  BHI     L000E 
  LEA     L0023(PC),A3
  MOVEA.L (A3)+,A0
  ADDA.W  6(A7),A0
  MOVE.W  (A0),D0 
  MOVEA.L (A3)+,A0
  ADDA.W  D0,A0 
  MOVEA.L (A3)+,A1
  ADDA.W  8(A7),A1
  LEA     L0027(PC),A2
  MOVEQ   #8,D0 
  MOVEQ   #0,D5 
L0002:MOVEQ   #0,D1 
  MOVE.W  (A0)+,D1
  LEA     0(A1,D1.L),A3 
  MOVE.B  (A3)+,D1
  MOVE.B  (A3)+,D3
  MOVE.B  D3,D4
  LSR.B #4,D4
  MOVE.B D4,ld7+1
  MOVE.B  (A3)+,D4
  MOVE.B  D1,D2 
  ANDI.W  #1,D2 
  BEQ.S   L0003 
  MOVEQ   #$10,D2 
L0003:
  LEA     mt_data-8(PC),A3
  OR.B    ld7+1(pc),D2 
  BNE.S   L0004 
  MOVE.B  1(A2),D2
  LSL.W   #4,D2 
  ADDA.W  D2,A3 
  BRA.S   L0005 
L0004:MOVE.B  D2,1(A2)
  LSL.W   #4,D2 
  ADDA.W  D2,A3 
  MOVE.W  6(A3),4(A2) 
L0005:ANDI.W  #$F,D3
  MOVE.B  D3,2(A2)
  MOVE.B  D4,3(A2)
  ANDI.W  #$FE,D1 
  BEQ.S   L0006 
  MOVE.W  L0007(PC,D1.W),ld7 
  SUBQ.W  #3,D3 
  BEQ     L000C 
  SUBQ.W  #2,D3 
  BEQ     L000C 
  OR.W    D0,D5 
  MOVE.B  D1,(A2) 
  MOVE.B  D6,49(A2) 
  MOVE.W  ld7(pc),24(A2)

  MOVE.L D1,saved1 
  MOVEQ #0,D1
  MOVE.L  (A3)+,sam_start(A4)
  MOVE.W  (A3)+,D1
  ADD.L D1,D1
  MOVE.W D1,sam_length(A4) 
  ADD.L D1,sam_start(A4)
  MOVE.L saved1(PC),D1

  ADDQ.W  #2,A3 
  MOVE.L  (A3)+,72(A2)
  MOVE.W  (A3)+,76(A2)
  SUBQ.W  #6,D3 
  BMI.S   L0008 
  ADD.W   D3,D3 
  ADD.W   D3,D3 
  MOVEA.L 42(A7,D3.W),A3
  JMP     (A3)
L0006:SUBI.W  #$B,D3
  BMI.S   L0008 
  ADD.W   D3,D3 
  ADD.W   D3,D3 
  MOVEA.L 42(A7,D3.W),A3
L0007:JMP     (A3)
  DC.B   $03,'X',$03,'(',$02,$FA,$02,$D0
  DC.B   $02,$A6,$02,$80,$02,'\',$02,':'
  DC.B   $02,$1A,$01,$FC,$01,$E0,$01,$C5
  DC.B   $01,$AC,$01,$94,$01,'}',$01,'h'
  DC.B   $01,'S',$01,'@',$01,'.',$01,$1D
  DC.B   $01,$0D,$00,$FE,$00,$F0,$00,$E2
  DC.B   $00,$D6,$00,$CA,$00,$BE,$00,$B4
  DC.B   $00,$AA,$00,$A0,$00,$97,$00,$8F
  DC.B   $00,$87,$00,'',$00,'x',$00,'q'
L0008:MOVE.W  24(A2),sam_period(A4)
L0009:MOVE.W  4(A2),sam_vol(A4) 
  ADDQ.W  #6,A2 
  LEA -sam_vcsize(A4),A4
  LSR.W   #1,D0 
  BNE     L0002 
  move_dmacon D5
  MOVE.B  D5,5(A7)
  MOVE.B  1(A7),(A7)

set_lpshite
  LEA     L0028(PC),A0
  LEA     ch4s(PC),A1
  REPT 4
  MOVEQ #0,D1
  MOVE.L (A0)+,sam_lpstart(A1) 
  MOVE.W (A0)+,D1
  ADD.L D1,D1
  MOVE.W  D1,sam_lplength(A1) 
  ADD.L D1,sam_lpstart(A1)
  LEA -sam_vcsize(A1),A1
  ENDR
  MOVE.W  L0026(PC),D1
  move_dmacon D1

  MOVEA.L L0023(PC),A0
  BSET    #0,2(A7)
  BEQ.S   L000A 
  ADDQ.W  #3,8(A7)
  CMPI.W  #$C0,8(A7)
  BNE.S   L000B 
L000A:MOVE.W  D6,8(A7)
  ADDQ.W  #2,6(A7)
  MOVE.W  6(A7),D0
  CMP.W   -4(A0),D0 
  BNE.S   L000B 
  MOVE.W  -2(A0),6(A7)
L000B:
  BRA.W exitvbl 

cmd10
  MOVE.B  D4,5(A2)
  BRA   L0008 

cmd11
  MOVE.W  D6,2(A7)
  BRA   L0008 

cmd9
  MOVE.W  D6,2(A7)
  MOVE.B  D4,7(A7)
  BRA   L0008 

cmd13
  MOVE.B  D4,1(A7)
  BRA     L0008 

cmd12		; filt!
  BRA     L0008 
L000C:MOVE.B  D6,50(A2) 
  MOVE.W ld7(PC),D2
  MOVE.W  D2,26(A2) 
  CMP.W   24(A2),D2
  BEQ.S   L000D 
  BGE     L0009 
  MOVE.B  #1,50(A2) 
  BRA     L0009 
L000D:MOVE.W  D6,26(A2) 
  BRA     L0009 
L000E:LEA     L0027(PC),A0
  MOVEQ   #3,D0 
L000F:MOVEQ   #0,D1 
  MOVE.B  2(A0),D1
  BEQ.S   L0010 
  SUBQ.W  #8,D1 
  BHI.S   L0010 
  ADDQ.W  #7,D1 
  ADD.W   D1,D1 
  ADD.W   D1,D1 
  MOVEA.L 10(A7,D1.W),A3
  JMP     (A3)
L0010:ADDQ.W  #6,A0 
  LEA -sam_vcsize(A4),A4
  DBF     D0,L000F
  BRA.W exitvbl
cmd1
  MOVEQ   #0,D2 
  MOVE.B  3(A0),D2
  SUB.W   D2,24(A0) 
  CMPI.W  #$71,24(A0) 
  BPL.S   L0011 
  MOVE.W  #$71,24(A0) 
L0011:MOVE.W  24(A0),sam_period(A4)
  BRA.S   L0010 

cmd2
  MOVEQ   #0,D2 
  MOVE.B  3(A0),D2
  ADD.W   D2,24(A0) 
  CMPI.W  #$358,24(A0)
  BMI.S   L0012 
  MOVE.W  #$358,24(A0)
L0012:MOVE.W  24(A0),sam_period(A4)
  BRA.S   L0010

cmd8
  MOVEQ   #0,D2 
  MOVE.B  (A7),D2 
  SUB.B   1(A7),D2
  NEG.B   D2
  MOVE.B  L0017(PC,D2.W),D2 
  BEQ.S   L0016 
  SUBQ.B  #2,D2 
  BEQ.S   L0013 
  MOVE.B  3(A0),D2
  LSR.W   #3,D2 
  ANDI.W  #$E,D2
  BRA.S   L0014 
L0013:MOVE.B  3(A0),D2
  ANDI.W  #$F,D2
  ADD.W   D2,D2 
L0014:ADD.B   (A0),D2 
  CMP.W   #$48,D2 
  BLS.S   L0015 
  MOVEQ   #$48,D2 
L0015:LEA     L0007(PC),A3
  MOVE.W  0(A3,D2.W),sam_period(A4)
  BRA     L0010 
L0016:MOVE.W  24(A0),sam_period(A4)
  BRA     L0010 
L0017:DC.B   $00,$01,$02,$00,$01,$02,$00,$01
  DC.B   $02,$00,$01,$02,$00,$01,$02,$00
  DC.B   $01,$02,$00,$01,$02,$00,$01,$02
  DC.B   $00,$01,$02,$00,$01,$02,$00,$01
L0018:DC.B   $00,$18,'1Jax',$8D,$A1 
  DC.B   $B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
  DC.B   $FF,$FD,$FA,$F4,$EB,$E0
  ADDA.W  D5,A2 
  CMP.L   -(A1),D2
  OR.W    D6,$614A.W
  MOVE.W  (A0)+,-(A0)

cmd4 
  MOVE.B  3(A0),D3
  BEQ.S   L0019 
  MOVE.B  D3,48(A0) 
cmd6
L0019:MOVE.B  49(A0),D3 
  LSR.B   #2,D3 
  ANDI.W  #$1F,D3 
  MOVEQ   #0,D2 
  MOVE.B  L0018(PC,D3.W),D2 
  MOVE.B  48(A0),D3 
  ANDI.W  #$F,D3
  MULU    D3,D2 
  LSR.W   #7,D2 
  MOVE.W  24(A0),D3 
  TST.B   49(A0)
  BMI.S   L001A 
  ADD.W   D2,D3 
  BRA.S   L001B 
L001A:SUB.W   D2,D3 
L001B:MOVE.W  D3,sam_period(A4)
  MOVE.B  48(A0),D3 
  LSR.B   #2,D3 
  ANDI.W  #$3C,D3 
  ADD.B   D3,49(A0) 
  CMP.B   #$14,D1 
  BNE     L0010 

cmd7
L001C:MOVE.B  3(A0),D2
  ADD.B   D2,5(A0)
  BMI.S   L001E 
  CMPI.B  #$40,5(A0)
  BMI.S   L001D 
  MOVE.W  #$40,4(A0)
L001D:MOVE.W  4(A0),sam_vol(A4) 
  BRA     L0010 
L001E:MOVE.W  D6,4(A0)
  MOVE.W  4(A0),sam_vol(A4) 
  BRA     L0010 

cmd3
  MOVE.B  3(A0),D2
  BEQ.S   L001F 
  MOVE.B  D2,29(A0) 

cmd5
L001F:MOVE.W  26(A0),D2 
  BEQ.S   L0021 
  MOVE.W  28(A0),D3 
  TST.B   50(A0)
  BNE.S   L0022 
  ADD.W   D3,24(A0) 
  CMP.W   24(A0),D2 
  BGT.S   L0020 
  MOVE.W  D2,24(A0) 
  MOVE.W  D6,26(A0) 
L0020:MOVE.W  24(A0),sam_period(A4)
L0021:CMP.B   #$10,D1 
  BEQ.S   L001C 
  BRA     L0010 
L0022:SUB.W   D3,24(A0) 
  CMP.W   24(A0),D2 
  BLT.S   L0020 
  MOVE.W  D2,24(A0) 
  MOVE.W  D6,26(A0) 
  MOVE.W  24(A0),sam_period(A4)
  CMP.B   #$10,D1 
  BEQ     L001C 
  BRA     L0010 

saved3 	DC.W 0
saved1	DC.L 0

ld7 dc.w 0

L0023:DCB.W    6,0 
L0024:DCB.W    2,0 
L0025:DCB.W    2,0 
L0026:DCB.W    29,0
L0027:DCB.W    36,0
L0028:DCB.W    12,0
      DS.L     2

		SECTION DATA
cool16fnt	INCBIN FONT1616.DAT
		DS.W 128
mt_data		INCBIN ENIGMA.NP1
		EVEN

		SECTION BSS
		DS.L 249
my_stack	DS.L 2
screen		DS.B 256
		DS.B 500*160


