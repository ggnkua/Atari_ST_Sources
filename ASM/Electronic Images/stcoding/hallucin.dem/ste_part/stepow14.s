;-----------------------------------------------------------------------;
;    		       STE Fullscreen Power Demo			;
;				 by					;
;                  Electronic Images of Inner Circle 			;
;                   (C) January 1992 - April 1992. 			;
;									;
;  Coding : Griff        Grafix : Master       Music : Count Zero    	;
;									;
;-----------------------------------------------------------------------;

;---------------------------------------;
; 'Copper table'!! is as follows :- 	;
; Screen Addr   .L		    	;
; pix offset    .W			;
; border colour .W			;
;---------------------------------------;

demo		EQU 0			; gem/disk

effectstart	EQU 1
effect1		EQU 1
effect2		EQU 1
effect3		EQU 1
effect4		EQU 1
effect5		EQU 1
effect6		EQU 1
effect7		EQU 1
effect8		EQU 1
effect9		EQU 1

letsgo
		IFEQ demo
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

		ELSEIF

		ORG $10000

		ENDC

		MOVE.L SP,oldsp
		LEA stack,SP	
		MOVEM.L $FFFF8240.W,D0-D7
		MOVEM.L D0-D7,old_cols
		JSR init_mrmusic
		JSR Gen_Para
		BSR InitMainScroll	
		BSR ClearTables
		BSR set_ints			; ok lets go!
		CLR.L vbl_extrarout
		BSR wait_vbl

; Begining bit where scroller moves from top to bottom

		IFNE effectstart
		MOVE.L #routstart,rout_ptr
		MOVE #1150-1,D7
.lp		BSR wait_vbl
		DBF D7,.lp
		MOVEQ #101,D7
.lp1		MOVE.L D7,-(SP)
		LEA MainScrollStruc(PC),A6
		MOVE.W D7,scrl_ybase(A6)
		MOVE.W D7,D6
		LSL #3,D6
		BSR wait_vbl
		MOVE.L physcrtable_ptr(PC),A1
		MOVE.L #blankarea,-8(A1,D6)
		MOVE.L #blankarea,(A1,D6)
		MOVE.L (SP)+,D7
		ADDQ #1,D7
		CMP.W #211,D7
		BNE.S .lp1
		ENDC
		LEA MainScrollStruc(PC),A6
		MOVE.W #210,scrl_ybase(A6)

;------------------------

; Parallax bars 1

		IFNE effect3
		MOVEQ #25-1,D7
.v1		BSR wait_vbl
		DBF D7,.v1
		JSR apppararasts
		MOVEQ #25-1,D7
.v2		BSR wait_vbl
		DBF D7,.v2

Parabars1	BSR wait_vbl
		MOVE.L #rout1,rout_ptr
		LEA parapal1,A0
		MOVEQ #3,D0
		BSR trigfade
		MOVE #250-1,D7
Vlp3		MOVE.L D7,-(SP)
		BSR SwapTables
		BSR wait_vbl
		JSR ParaWave1
		MOVE.L (SP)+,D7
		DBF D7,Vlp3
.trigfadeout1	LEA blank_pal,A0
		MOVEQ #3,D0
		BSR trigfade
		MOVEQ #60-1,D7
Vlp3a		MOVE.L D7,-(SP)
		BSR SwapTables
		BSR wait_vbl
		JSR ParaWave1
		MOVE.L (SP)+,D7
		DBF D7,Vlp3a
		ENDC

; Parallax bars 2

		IFNE effect4
Parabars2	BSR wait_vbl
		MOVE.L #rout1,rout_ptr
		LEA parapal1,A0
		MOVEQ #3,D0
		BSR trigfade
		MOVE #250-1,D7
Vlp4		MOVE.L D7,-(SP)
		BSR SwapTables
		BSR wait_vbl
		JSR ParaWave2
		MOVE.L (SP)+,D7
		DBF D7,Vlp4
.trigfadeout1	LEA blank_pal,A0
		MOVEQ #3,D0
		BSR trigfade
		MOVEQ #60-1,D7
Vlp4a		MOVE.L D7,-(SP)
		BSR SwapTables
		BSR wait_vbl
		JSR ParaWave2
		MOVE.L (SP)+,D7
		DBF D7,Vlp4a

		ENDC

; Parallax bars 3
		
		IFNE effect5
Parabars3	BSR wait_vbl
		MOVE.L #rout2,rout_ptr
		LEA parapal1,A0
		MOVEQ #3,D0
		BSR trigfade
		MOVE #350-1,D7
Vlp5		MOVE.L D7,-(SP)
		BSR SwapTables
		BSR wait_vbl
		MOVE.L (SP)+,D7
		DBF D7,Vlp5
.trigfadeout1	LEA blank_pal,A0
		MOVEQ #3,D0
		BSR trigfade
		MOVEQ #60-1,D7
Vlp5a		MOVE.L D7,-(SP)
		BSR SwapTables
		BSR wait_vbl
		MOVE.L (SP)+,D7
		DBF D7,Vlp5a
		ENDC

; Parallax bars 4

		IFNE effect6
Parabars4	BSR wait_vbl
		MOVE.L #rout3,rout_ptr
		LEA parapal1,A0
		MOVEQ #3,D0
		BSR trigfade
		MOVE #350-1,D7
Vlp6		MOVE.L D7,-(SP)
		BSR SwapTables
		BSR wait_vbl
		MOVE.L (SP)+,D7
		DBF D7,Vlp6
.trigfadeout1	LEA blank_pal,A0
		MOVEQ #3,D0
		BSR trigfade
		MOVEQ #60-1,D7
Vlp6a		MOVE.L D7,-(SP)
		BSR SwapTables
		BSR wait_vbl
		MOVE.L (SP)+,D7
		DBF D7,Vlp6a
		ENDC

; Parallax bars 5

		IFNE effect7
Parabars5	MOVE.L #rout4,rout_ptr
		BSR wait_vbl
		LEA parapal1,A0
		MOVEQ #3,D0
		BSR trigfade
		MOVE #450-1,D7
Vlp7		MOVE.L D7,-(SP)
		BSR SwapTables
		BSR wait_vbl
		MOVE.L (SP)+,D7
		DBF D7,Vlp7
.trigfadeout1	LEA blank_pal,A0
		MOVEQ #3,D0
		BSR trigfade
		MOVEQ #60-1,D7
Vlp7a		MOVE.L D7,-(SP)
		BSR SwapTables
		BSR wait_vbl
		MOVE.L (SP)+,D7
		DBF D7,Vlp7a
		ENDC

; Parallax bars 6

		IFNE effect8
Parabars6	MOVE.L #rout5,rout_ptr
		BSR wait_vbl
		LEA parapal1,A0
		MOVEQ #3,D0
		BSR trigfade
		MOVE #250-1,D7
Vlp8		MOVE.L D7,-(SP)
		BSR SwapTables
		BSR wait_vbl
		MOVE.L (SP)+,D7
		DBF D7,Vlp8
.trigfadeout1	LEA blank_pal,A0
		MOVEQ #3,D0
		BSR trigfade
		MOVEQ #60-1,D7
Vlp8a		MOVE.L D7,-(SP)
		BSR SwapTables
		BSR wait_vbl
		MOVE.L (SP)+,D7
		DBF D7,Vlp8a
		MOVEQ #20-1,D7
.v1		MOVE.L D7,-(SP)
		BSR wait_vbl
		MOVE.L (SP)+,D7
		DBF D7,.v1
		JSR dapppararasts
		MOVEQ #20-1,D7
.v2		MOVE.L D7,-(SP)
		BSR wait_vbl
		MOVE.L (SP)+,D7
		DBF D7,.v2
		ENDC

; Straight picture dist.

		IFNE effect1
piccydist	BSR wait_vbl
		MOVE.L #rout1,rout_ptr
		LEA picture1+2,A0
		MOVEQ #2,D0
		BSR trigfade
		MOVE.W #850-1,D7
Vlp1		MOVE.L D7,-(SP)
		BSR SwapTables
		BSR wait_vbl
		JSR do_piccydist1
		MOVE.L (SP)+,D7
		DBF D7,Vlp1
.trigfadeout	LEA blank_pal,A0
		MOVEQ #2,D0
		BSR trigfade
		MOVEQ #58-1,D7
Vlp1a		MOVE.L D7,-(SP)
		BSR SwapTables
		BSR wait_vbl
		JSR do_piccydist1
		MOVE.L (SP)+,D7
		DBF D7,Vlp1a
		ENDC

; Straight picture dist with flip

		IFNE effect2
piccydist2	BSR wait_vbl
		MOVE.L #rout6,rout_ptr
		LEA picture1+2,A0
		MOVEQ #2,D0
		BSR trigfade
		MOVE.W #900-1,D7
Vlp2		MOVE.L D7,-(SP)
		BSR SwapTables
		BSR wait_vbl
		JSR do_piccydist2
		MOVE.L (SP)+,D7
		DBF D7,Vlp2
.trigfadeout	LEA blank_pal,A0
		MOVEQ #2,D0
		BSR trigfade
		MOVEQ #58-1,D7
Vlp2a		MOVE.L D7,-(SP)
		BSR SwapTables
		BSR wait_vbl
		JSR do_piccydist2
		MOVE.L (SP)+,D7
		DBF D7,Vlp2a
		ENDC

; Call plasmas

		IFNE effect9
		JSR do_plasma
		ENDC

Exit		MOVEM.L old_cols(pc),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		BSR rest_ints
		IFEQ demo
		CLR -(SP)
		TRAP #1			
		ENDC

		MOVE.L oldsp(PC),SP
		RTS
oldsp		DC.L 0

; Screen Address Table/bit offset routines

; Initialise tables to point at blank space (every line)

ClearTables	LEA log_scrtable(PC),A0
		LEA phy_scrtable(PC),A1
		MOVE.L #blankarea,D0
		MOVEQ #0,D1
		MOVE.W #280-1,D2
.lp		MOVE.L D0,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D0,(A1)+
		MOVE.L D1,(A1)+
		DBF D2,.lp
		RTS

; Swap over the table pointers

SwapTables	LEA logscrtable_ptr(PC),A0
		MOVEM.L (A0)+,D0/D1
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		RTS

logscrtable_ptr	DC.L log_scrtable
physcrtable_ptr	DC.L phy_scrtable

log_scrtable	DS.L 280*2
phy_scrtable	DS.L 280*2

; Initialisation interrupts (mfp etc) and various vectors.

set_ints	MOVE.W SR,-(SP)
		MOVE.W #$2700,SR
		LEA old_stuff(pc),A0
		MOVE.W $FFFF820E.W,(A0)+
		MOVE.W $FFFF8264.W,(A0)+
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
		MOVE.B #$20,$FFFFFA07.W
		MOVE.B #0,$FFFFFA09.W
		MOVE.B #$20,$FFFFFA13.W
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
		MOVE.W (A0)+,$FFFF820E.W
		MOVE.W (A0)+,$FFFF8264.W
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
		CLR.W $ffff8900.w
		BSR flush
		MOVE.W (SP)+,SR
		RTS

; Flush keyboard Buffer

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S .flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
.flok		RTS

old_stuff	DS.L 20
old_cols	DS.W 16

; Wait for one vbl..

wait_vbl	;MOVE.W #$700,$FFFF8240.W
		MOVE vbl_timer(PC),D0
.wait_vbl	CMP vbl_timer(PC),D0		
		BEQ.S .wait_vbl
		;MOVE.W #$000,$FFFF8240.W
		RTS

vbl_timer	DS.W 1

;-------------------------------------------------------------------------
; Some Fade Routines
; Fade Colours from current palette TO a new palette.

Fade_to		lea fadeto_vars(pc),a5
		tst.b 7(a5)		; fading ?
		beq.s .nofadeto	
		subq.b #1,6(a5)		; vbl count-1
		bge.s .nofadeto
		move.b 8(a5),6(a5)	; reset speed (vbl count)
		subq #1,4(a5)		; faded -> totally?
		bne.s .okstillfade
		sf.b 7(a5)		; yes signal fade done.
		move.w #8,4(a5)		; and reset for next fade. 
.okstillfade	lea curr_pal(pc),a0	; pal to fade FROM
		move.l (a5),a1		; ptr to pal to fade TO.
		move  #$700,d4		; R mask
		moveq #$070,d5		; G mask
		moveq #$007,d6		; B mask
		moveq #15,d7
.col_lp		move.w (a0),d0		; curr value
		move.w (a1)+,d1
		move.w d0,d2
		move.w d1,d3
		and.w d4,d2
		and.w d4,d3
		cmp.w d3,d2
		beq.s .R_done
		blt.s .R_add
		sub.w #$100,d0
		bra.s .R_done
.R_add		add.w #$100,d0
.R_done		move.w d0,d2
		move.w d1,d3
		and.w d5,d2
		and.w d5,d3
		cmp.w d3,d2
		beq.s .G_done
		blt.s .G_add
		sub.w #$010,d0
		bra.s .G_done
.G_add		add.w #$010,d0
.G_done 	move.w d0,d2
		move.w d1,d3
		and.w d6,d2
		and.w d6,d3
		cmp.w d3,d2
		beq.s .B_done
		blt.s .B_add
		subq.w #$001,d0
		bra.s .B_done
.B_add		addq.w #$001,d0
.B_done		move.w D0,(a0)+
		dbf d7,.col_lp
.nofadeto	rts

; Trigger a fade and wait for fade out.
; A0 -> pal D0 = fade speed (vbl count)

trigfadeW	bsr wait_vbl
		lea fadeto_vars(PC),A6
		move.l a0,(a6)
		St 7(a6)
		move.b d0,8(a6)
.wait		tst.b 7(a6)
		bne.s .wait
		bsr wait_vbl
		rts

; Trigger a fade with no wait for fade out.
; A0 -> pal D0 = fade speed (vbl count)

trigfade	lea fadeto_vars(PC),A6
		move.l a0,(a6)
		St 7(a6)
		move.b d0,6(a6)
		move.b d0,8(a6)
		rts

; Fade Red , Green and Blue in seperately waiting for each
; A0 -> pal D0 = fade speed (vbl count)

trigfadeRGB	bsr wait_vbl
		lea fadeto_vars(PC),A6
		lea rgb_temp(pc),a2
		move.l a2,(a6)
		move.b d0,8(a6)
		move.w #$070,d1
		bsr doRGBfade
		move.w #$770,d1
		bsr doRGBfade
		move.w #$777,d1

doRGBfade	move.b #0,6(a6)
		move.l a0,a1
		move.l a2,a3
		moveq #15,d0
.lp		move.w (a1)+,d2
		and.w d1,d2
		move.w d2,(a3)+
		dbf d0,.lp
		St 7(a6)
.wait		tst.b 7(a6)
		bne.s .wait
		rts

rgb_temp	ds.w 16
blank_pal	ds.w 16

fadeto_vars
fadeto_palptr:	dc.l 0
fadeto_cnt	dc.w 8  ;4
fadeto_tim	dc.b 0  ;6
fadetoflag:	dc.b 0	;7
fadetospeed	dc.b 3  ;8

;-------------------------------------------------------------------------

; 48*48 STE scroller (very fast and takes a constant cpu time)
; -> A6 points to data structure

		RSRESET
scr_type	RS.W 1
scr_point	RS.L 1
scr_restart	RS.L 1
scrl_ybase	RS.W 1
scrlspeed	RS.W 1
scrx		RS.W 1
scrlpos		RS.W 1
hwpixoffset	RS.W 1
curr_char	RS.W 1
scrollbufptr	RS.L 1
scrlstrucsize	RS.B 0

scroll48	MOVE.L scr_point(A6),A3
		MOVEM.W scrx(A6),D0/D1/D2/D3  ;scrx/scrlpos/hwpixoffset/currchar
		ADD.W scrlspeed(A6),D2
		AND.W #15,D2
		BNE .not_next
		ADDQ #8,D1
		CMP #224,D1
		BNE.S .ok
		CLR D1
.ok		ADD #384,D0
		CMP #3*384,D0
		BNE.S .not_next
		CLR D3
		MOVE.B (A3)+,D3
		BNE.S .not_wrap
		MOVE.L scr_restart(A6),A3
.not_wrap	CMP.B #"s",D3
		BNE.S .notspeedset
		MOVE.B (A3)+,scrlspeed+1(A6)
		MOVE.B (A3)+,D3
.notspeedset	ADD D3,D3
		ADD D3,D3
		MOVEQ #0,D0
.not_next	MOVE.L scrollbufptr(A6),A1
		ADD D1,A1
		MOVE.L A3,scr_point(A6)	      ; scr_point
		MOVEM.W D0/D1/D2/D3,scrx(A6)  ; scrx/scrlpos/hwpixoffset
		LEA char_tab(PC),A2
		MOVE.L (A2,D3),A0
		ADDA.W D0,A0
i		SET 216
		REPT 12
		MOVEM.L (A0)+,D0-D7
		MOVEM.L D0-D1,i(a1)
		MOVEM.L D0-D1,i-224(a1)
i		SET i+448
		MOVEM.L D2-D3,i(a1)
		MOVEM.L D2-D3,i-224(a1)
i		SET i+448
		MOVEM.L D4-D5,i(a1)
		MOVEM.L D4-D5,i-224(a1)
i		SET i+448
		MOVEM.L D6-D7,i(a1)
		MOVEM.L D6-D7,i-224(a1)
i		SET i+448
		ENDR
place_intable	MOVE.L frametable_ptr,a0
		MOVE.W scrl_ybase(A6),D0
		LSL #3,D0
		ADD.W D0,A0
		MOVE.W hwpixoffset(A6),D0
		SWAP D0
		CLR.W D0
		REPT 47
		MOVE.L A1,(A0)+
		MOVE.L D0,(A0)+
		LEA 448(A1),A1
		ENDR
		RTS

; Initialise main scrolltext rout

InitMainScroll	LEA MainScrollStruc(PC),A6
		CLR.W scr_type(A6)
		MOVE.L #maintext,scr_point(A6)
		MOVE.L #maintext,scr_restart(A6)
		MOVE.W #100,scrl_ybase(A6)
		MOVE.W #4,scrlspeed(A6)
		MOVE.L #scroll48buf,scrollbufptr(A6)
		RTS

MainScrollStruc	DS.B scrlstrucsize	

maintext		
 dc.b "    OK... SO WE HAVE A LITTLE SCROLLER, BUT I SUPPOSE WE BETTER START THE DEMO...   "
 dc.b "    LET US BEGIN! ...WELCOME TO THE UNFINISHED STE POWER DEMO......!   s",8,"       s",4
 dc.b "    CRAPPY CODE BY GRIFF OF ELECTRONIC IMAGES...   s",8,"       s",4
 dc.b "    CRAPPY MUSIC BY COUNT ZERO...   s",8,"       s",4
 dc.b "    CRAPPY GRAPHIX BY MASTER...   s",8,"       s",4
 dc.b "    I (GRIFF) HOPE YOU ENJOY THESE FEW EFFECTS , BUT THERE WILL BE MANY"
 dc.b " MORE IN THE FINAL DEMONSTRATION....         "
 dc.b "    A BIG HELLO TO ALL THOSE PEOPLE WE HAVE MET HERE IN SNOWY SWEDEN,"
 dc.b " WE HOPE TO MEET YOU AGAIN SOMETIME......   "
 dc.b " AN EVEN BIGGER !HELLO! TO ELECTRA FOR MAKING THE CONVENTION "
 dc.b " POSSIBLE.. WE HOPE THERE WILL BE ANOTHER ONE SOMEDAY...   " 
 dc.b " BYE FOR NOW AND ENJOY.....                                        "       
 dc.b "                                                                   "
 dc.b "                                                                   "
 dc.b "                                                                   "
 dc.b "                                                                   "
 dc.b "                                                                   "
 dc.b "                                                                   "
 dc.b "                                                                   "
 dc.b "                                                                   "
 dc.b "                                                                   "
 dc.b "                                                                   "
 dc.b "                                                                   "
 dc.b "                                                                   "
 DC.B 0 
 
		EVEN

char_tab	
		rept 33
		dc.l bigfontspce
		endr
		dc.l bigfont+(30*1152)		; !
		dc.l bigfontspce 		; "
		dc.l bigfontspce 		; #
		dc.l bigfontspce 		; $
		dc.l bigfontspce 		; %
		dc.l bigfontspce 		; &
		dc.l bigfont+(29*1152)		; '
		dc.l bigfont+(32*1152)		; (
		dc.l bigfont+(33*1152)		; )
		dc.l bigfontspce 		; *
		dc.l bigfontspce 		; +
		dc.l bigfont+(28*1152)		; ,
		dc.l bigfont+(26*1152)		; -
		dc.l bigfont+(27*1152)		; .
		dc.l bigfontspce 		; /
		dc.l bigfontspce 		; 0
		dc.l bigfontspce 		; 1
		dc.l bigfontspce 		; 2
		dc.l bigfontspce 		; 3 
		dc.l bigfontspce 		; 4
		dc.l bigfontspce 		; 5
		dc.l bigfontspce 		; 6
		dc.l bigfontspce 		; 7
		dc.l bigfontspce 		; 8
		dc.l bigfontspce 		; 9
		dc.l bigfontspce 		; :
		dc.l bigfontspce 		; ;
		dc.l bigfontspce 		; <
		dc.l bigfontspce 		; =
		dc.l bigfontspce 		; >
		dc.l bigfont+(31*1152)		; ?
		dc.l bigfontspce 		; @
i		set 0
		rept 26
		dc.l bigfont+i
i		set i+1152
		endr

bigfontpal	DC.L $00000045
		DC.L $01010212
		DC.L $03230434
		DC.L $05450034
		DC.L $00010012
		DC.L $00230000
		DC.L $00000000
		DC.L $00000000

; Disty bits

picheight	EQU 208

calc_dist	LEA dist_ang(PC),A1
		MOVE (A1),D0
		ADD dist_step(PC),D0
		AND #$3FF,D0
		MOVE D0,(A1)
		MOVE dister(pc),D1
		ADD dist_step(PC),D1
		CMP maxi_dist(PC),D1
		BLE.S notwang
 		SUB maxi_dist(PC),D1
		MOVE.L wave_ptr(PC),A1
		LEA dist_step(PC),A2
		MOVE (A1)+,(A2)+
		BPL.S nrapwave 
		LEA wave_tab(PC),A1
		MOVE (A1)+,-2(A2)
nrapwave	MOVE.L (A1)+,(A2)+
		MOVE.L A1,wave_ptr
notwang		MOVE D1,dister
		LEA trig_tab(PC),A0
		MOVE (A0,D0),D0
		MULS size(PC),D0
		LSL.L #2,D0
		SWAP D0
		ADD #64+224,D0
		MOVE dist_ptr(PC),D1
		ADDQ #8,D1
		CMP #picheight*8,D1
		BNE.S .notendbuf
		CLR D1
.notendbuf	MOVE.W D1,dist_ptr
		MOVEQ #15,D2
		AND D0,D2
		SUB D2,D0
		LSR #1,D0
		LEA picture1+34,A1
		ADD.W D0,A1 
		LEA disttab(PC,D1),A0
		MOVE.L A1,((picheight-1)*8)(A0)
		MOVE.L D2,((picheight-1)*8)+4(A0)
		MOVE.L A1,-8(A0)
		MOVE.L D2,-4(A0)
		RTS

		DC.L picture1+34+144,0
disttab		
		REPT picheight
		DC.L picture1+34+144,0
		DC.L picture1+34+144,0
		ENDR

trig_tab	
		rept 2
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
dist_ptr	DC.W 0
dist_ang	DC.W 0
dist_step	DC.W 2
maxi_dist	DC.W 1024
size		DC.W 0
dister		DC.W 0
wave_ptr	DC.L wave_tab
wave_tab	DC.W 32,4096,3
		DC.W 2,512,64
		DC.W 4,512,40
		DC.W 4,512,60
		DC.W 24,1024,6
		DC.W 6,1024,8
		DC.W 6,512,30
		DC.W 6,1024,0
		DC.W 6,1024,0
		DC.W -1

;------------------------------------------------------------------------

; Vbls.

first_vbl	MOVE.L #vbl,$70.W
		ADDQ #1,vbl_timer
		RTE
			
vbl		MOVEM.L D0-D7/A0-A6,-(SP)
		CLR.B $FFFFFA19.W
		MOVE.B #98,$FFFFFA1F.W
		MOVE.L #overscantop,$134.W
		MOVE.B #4,$FFFFFA19.W
		MOVEM.L curr_pal(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		MOVE.W #0,$FFFF8264.W
		MOVE.L physcrtable_ptr(PC),frametable_ptr
		LEA MainScrollStruc(PC),A6
		BSR scroll48
		JSR Seq
		MOVE.L vbl_extrarout(PC),D0
		BEQ.S .okno
		MOVE.L D0,A0
		JSR (A0)
.okno		MOVEM.L (SP)+,D0-D7/A0-A6
		ADDQ #1,vbl_timer
		BTST.B #0,$FFFFFC00.W
		BEQ.S .nokey
		CMP.B #$39,$FFFFFC02.W
		BNE.S .nokey
		MOVE.L #Exit,2(SP)
.nokey		RTE

vbl_extrarout	DC.L 0
frametable_ptr	DC.L 0
bptrs		DC.L 0,0
curr_pal	DS.W 16

;------------------------------------------------------------------------
;------------------------------------------------------------------------

; OverScan stuff
; uses A5/A6 D0/D6/D7
rout_ptr	DC.L rout1

; Some Macros for overscan bits and pieces

setscrli	MACRO
		MOVEP.L D6,$3-$60(a6)
		SWAP D7
		MOVE.W D7,$FFFF8264.W
		MOVE.B #2,(a6)
		MOVE.B D0,(a6)
		ENDM

rdnextli	MACRO
 		MOVE.B d0,$FFFF820A.W
		MOVE.B #2,$FFFF820A.W
		MOVE.L (A5)+,D6
		MOVE.L (A5)+,D7
		MOVE.W #$8240,A0
		NOP
		MOVE.B #1,(a6)
		MOVE.W D7,(A0)
		MOVE.B D0,(a6)
		ENDM

Call_inOverScan	macro
		setscrli
		jsr \1
		rdnextli	
		endm

Call_inOverScan2 macro
		setscrli
		move.w #\2,d1
		jsr \1
		rdnextli	
		endm

setapal		MACRO
		setscrli
		LEA \1,A0
		MOVE #$8240,A1
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		DCB.W 90-45,$4E71
		rdnextli	
		ENDM

setapalplasma	MACRO
		setscrli
		LEA \1,A0
		MOVE #$8242,A1
		MOVE.W (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		DCB.W 45+2,$4E71
		rdnextli	
		ENDM


remove_botbord	MACRO
		MOVEP.L D6,$3-$60(a6)
		NOP
		MOVE.B D0,$FFFF820A.W
		MOVE.B #2,(a6)			
		MOVE.B D0,(a6)			; the bottom border
		MOVE.B #2,$FFFF820A.W		
		;MOVE.W D7,$FFFF8264.W
		DCB.W 90-4,$4E71	
		rdnextli	
		ENDM

overscantop	MOVE #$2100,SR			; top border synchronisation
		STOP #$2100			; by processor hbl
		MOVE.W #$2700,SR
		MOVEM.L D0-D7/A0-A6,-(SP)
		CLR.B $FFFFFA19.W
		DCB.W 52,$4E71
		MOVE.B #0,$FFFF820A.W
		DCB.W 10,$4E71
		MOVEQ #0,D0
		MOVEQ #$2F,D1
		MOVE #$8209,A0
		MOVE.B #2,$FFFF820A.W
.syncloop	MOVE.B (A0),D0
		BEQ.S .syncloop
		SUB.B D0,D1
		LSL D1,D0
		MOVE #$8260,a6
		MOVEQ #0,D0
		DCB.W 69-13-4-4-4,$4E71
		MOVE.L frametable_ptr,a5
		MOVE.L (A5)+,D6
		MOVE.L (A5)+,D7
		MOVE.W D7,$FFFF8240.W
		SWAP D7
		MOVE.L rout_ptr(PC),A1
		JSR (A1)

		MOVE #$8240,A0
		MOVEQ #0,D0
		REPT 8
		MOVE.L D0,(A0)+
		ENDR
		MOVE.L #blankarea+256,D6
		LSR #8,D6
		MOVE.L D6,$FFFF8200.W

storevc		move.w dur1+vcon(pc),d0
		beq.s vcoff1
		lea	dur1+saddr(pc),a5	
		move.l	newvc1(pc),(a5)
vcoff1		move.w dur2+vcon(pc),d0
		beq.s vcoff2
		lea	dur2+saddr(pc),a5
		move.l	newvc2(pc),(a5)
vcoff2		move.w dur3+vcon(pc),d0
		beq.s vcoff3
		lea	dur3+saddr(pc),a5
		move.l	newvc3(pc),(a5)
vcoff3		move.w dur4+vcon(pc),d0
		beq.s vcoff4
		lea	dur4+saddr(pc),a5
		move.l	newvc4(pc),(a5)
vcoff4		
		lea 	bptrs,A5
		movem.l (A5),D0-D1
		exg	D0,D1
		movem.l D0-D1,(A5)

		JSR Set_DMA
		JSR Fade_to

		MOVEM.L (SP)+,D0-D7/A0-A6
phbl		RTE
savesp		DC.L 0

; Rout start -> general, just plays mod and set "copper" lines

routstart	setapal          bigfontpal    ; 1   48*48 scroller palette switch
		Call_inOverScan  Make_STEbuf   ; 73  ste tracker buffer creation
		Call_inOverScan2 Waitlines,135 ; 135 do nothing 
		Call_inOverScan2 Waitlines,19  ; 19  do nothing
		remove_botbord                 ; 1   bye bye bot border
		Call_inOverScan2 Waitlines,28  ; 28  do nothing
		RTS

; Rout 1 -> general, just plays mod and set "copper" lines

rout1		Call_inOverScan  Make_STEbuf   ; 73  ste tracker buffer creation
		Call_inOverScan2 Waitlines,135 ; 135 do nothing 
		setapal          bigfontpal    ; 1   48*48 scroller palette switch
		Call_inOverScan2 Waitlines,19  ; 19  do nothing
		remove_botbord                 ; 1   bye bye bot border
		Call_inOverScan2 Waitlines,28  ; 28  do nothing
		RTS

; Rout 2 -> does parallax rasters effect 3 (disty wibbly thingy)

rout2		Call_inOverScan  Make_STEbuf   ; 73  ste tracker buffer creation
		Call_inOverScan  ParaWave3o    ; 92  parawave3
		Call_inOverScan2 Waitlines,43  ; 43  do nothing
		setapal          bigfontpal    ; 1   48*48 scroller palette switch
		Call_inOverScan2 Waitlines,19  ; 19  do nothing
		remove_botbord                 ; 1   bye bye bot border
		Call_inOverScan2 Waitlines,28  ; 28  do nothing
		RTS

; Rout 3 -> does 32 layer parallax effect 

rout3		Call_inOverScan  Make_STEbuf   ; 73  ste tracker buffer creation
		Call_inOverScan  ParaWave4o    ; 92  parawave3
		Call_inOverScan2 Waitlines,43  ; 43  do nothing
		setapal          bigfontpal    ; 1   48*48 scroller palette switch
		Call_inOverScan2 Waitlines,19  ; 19  do nothing
		remove_botbord                 ; 1   bye bye bot border
		Call_inOverScan2 Waitlines,28  ; 28  do nothing
		RTS

; Rout 4 -> MANIC does parallax rasters effect 3 (disty wibbly thingy)

rout4		Call_inOverScan  Make_STEbuf   ; 73  ste tracker buffer creation
		Call_inOverScan  ParaWave5o    ; 92  parawave3
		Call_inOverScan2 Waitlines,43  ; 43  do nothing
		setapal          bigfontpal    ; 1   48*48 scroller palette switch
		Call_inOverScan2 Waitlines,19  ; 19  do nothing
		remove_botbord                 ; 1   bye bye bot border
		Call_inOverScan2 Waitlines,28  ; 28  do nothing
		RTS

; Rout 5 -> 32 LAYER parallax effect 3 (pivot)

rout5		Call_inOverScan  Make_STEbuf   ; 73  ste tracker buffer creation
		Call_inOverScan  ParaWave6o    ; 92  parawave3
		Call_inOverScan2 Waitlines,43  ; 43  do nothing
		setapal          bigfontpal    ; 1   48*48 scroller palette switch
		Call_inOverScan2 Waitlines,19  ; 19  do nothing
		remove_botbord                 ; 1   bye bye bot border
		Call_inOverScan2 Waitlines,28  ; 28  do nothing
		RTS

; Rout 6 -> picture flipper

rout6		Call_inOverScan  Make_STEbuf   ; 73  ste tracker buffer creation
		Call_inOverScan  flipo         ; 102  parawave3
		Call_inOverScan2 Waitlines,33  ; 33  do nothing 
		setapal          bigfontpal    ; 1   48*48 scroller palette switch
		Call_inOverScan2 Waitlines,19  ; 19  do nothing
		remove_botbord                 ; 1   bye bye bot border
		Call_inOverScan2 Waitlines,28  ; 28  do nothing
		RTS

; Rout 10 -> plasmas effects

rout10		setapalplasma    plasmapal     ; 1   48*48 scroller palette switch
		Call_inOverScan  Make_STEbuf   ; 73  ste tracker buffer creation
		Call_inOverScan2 Waitlines,134 ; 134  do nothing
		setapal          bigfontpal    ; 1   48*48 scroller palette switch
		Call_inOverScan2 Waitlines,19  ; 19  do nothing
		remove_botbord                 ; 1   bye bye bot border
		Call_inOverScan2 Waitlines,28  ; 28  do nothing
		RTS

;-----------------------------------------------------------------------

; Waits D1 lines (overscan), minimum of 3 lines.

Waitlines	DCB.W 90-5-2-1-5,$4E71
		SUBQ #3,D1
.lp		DCB.W 5,$4E71
		rdnextli	
		setscrli
		DCB.W 90-5-3,$4E71
		DBF D1,.lp
		DCB.W 4,$4E71
		rdnextli	
		setscrli
		DCB.W 90-4,$4E71
		RTS


;
; Mr music stuff
;

; Mr Music player

mke1_vc		macro
		move.b (a1),d1		;8
		add.b (a2),d1		;8
		move.b d1,(a7)+		;8
		add (a3)+,a1		;12
		add (a4)+,a2       	;12
		endm			;48

Make_STEbuf	move.l sp,savestesp
setupfor_1_2	move.l bptrs,a7
		move.l newvc1,a1
		move.l newvc3,a2
		lea notes,a3
		move.l a3,a4
		add.w dur1+note,a3
		add.w dur3+note,a4
		DCB.W 90-29-(4*12)-5-5,$4E71
		mke1_vc
		mke1_vc
		mke1_vc
		mke1_vc
		rdnextli	

		REPT 35
		setscrli
		mke1_vc
		mke1_vc
		mke1_vc
		mke1_vc
		mke1_vc
		mke1_vc
		mke1_vc
		dcb.w 6,$4e71
		rdnextli	
		ENDR

setupfor_3_4	setscrli
		mke1_vc
		move.l a1,newvc1
		move.l a2,newvc3
		move.l bptrs,a7
		addq.l #1,a7
		move.l newvc2,a1
		move.l newvc4,a2
		lea notes,a3
		move.l a3,a4
		add.w dur2+note,a3
		add.w dur4+note,a4
		DCB.W 90-31-10-(3*12)-12,$4E71
		mke1_vc
		mke1_vc
		mke1_vc
		rdnextli	

		REPT 35
		setscrli
		mke1_vc
		mke1_vc
		mke1_vc
		mke1_vc
		mke1_vc	
		mke1_vc	
		mke1_vc	
		dcb.w 6,$4e71
		rdnextli	
		ENDR

		setscrli
		mke1_vc
		mke1_vc
		move.l a1,newvc2
		move.l a2,newvc4
		DCB.W 90-(2*12)-10-4-4,$4E71
		move.l savestesp(pc),sp
		rts
savestesp	dc.l 0

init_mrmusic:
.SteSet	LEA.L setsam_dat(PC),A6
	MOVE.W #$7ff,$ffff8924
	MOVEQ #3,D6
.mwwritx	
	CMP.W #$7ff,$ffff8924
	BNE.S .mwwritx			; setup the PCM chip
	MOVE.W (A6)+,$ffff8922
	DBF D6,.mwwritx
	LEA bptrs,A0
	LEA buffer1(PC),A1
	MOVE.L A1,(A0)+
	LEA buffer2(PC),A1
	MOVE.L A1,(A0)+
	bsr gentabs			; Generate note tables.
	lea.l dur1(pc),a0
	bsr initvoice
	lea.l dur2(pc),a0		; initialise each
	bsr initvoice			; voices' channel data
	lea.l dur3(pc),a0
	bsr initvoice
	lea.l dur4(pc),a0
	bsr initvoice
	bsr find_tune			; find voices
	bsr find_samples		; find samples
	bsr Seq
	rts

; THIS IS THE SEQUENCER - Call this once per VBL.

loadvc	macro
	lea dur\1(pc),a0	
	move.w	vcon(a0),d1
	bne.s	vcson\@
	lea nul_sample(pc),A\1
	bra.s endloadvc1\@
vcson\@	move.l	off(a0),d1
	beq.s	not\@
	move.l	d1,saddr(a0)
not\@	move.l	saddr(a0),A\1
endloadvc1\@
	endm

Seq	lea	dur1(pc),a2		; Play channel 1 song.
	bsr	mr_music
	lea	dur2(pc),a2		; Play channel 2 song.
	bsr	mr_music
	lea	dur3(pc),a2		; Play channel 3 song.
	bsr	mr_music
	lea	dur4(pc),a2		; Play channel 4 song.
	bsr	mr_music
	loadvc 1
	loadvc 2
	loadvc 3
	loadvc 4
	movem.l a1-a4,newvc1
	rts

; Voice data structure

	rsreset
dur:	rs.w	1
note:	rs.w	1
loop:	rs.w	1
snote:	rs.w	1
scount:	rs.w	1
slide:	rs.w	1
slidin:	rs.w	1
craddr:	rs.l	1
vcon:	rs.w	1
off:	rs.l	1
new:	rs.w	1
sptr:	rs.l	1
	rs.l	1
saddr	rs.l	1
dsize	rs.b	1	

dur1:	ds.b	dsize
dur2:	ds.b	dsize
dur3:	ds.b	dsize
dur4:	ds.b	dsize

newvc1	dc.l 	0
newvc2	dc.l 	0
newvc3	dc.l 	0
newvc4	dc.l 	0
tuneptr:  dc.l tune			; pointer to tune data
slistptr: dc.l vceset			; pointer to voiceset
sampptr:  dc.l 0			; sample data start(set by driver) 
buffer1	ds.w 500
buffer2	ds.w 500

temp:	dc.l	0
setsam_dat:
	dc.w	%0000010010000110  	;treble
	dc.w	%0000010001000110  	;bass
	dc.w	%0000000000000001  	;mixer
	dc.w	%0000000011010100  	;mastervol

Set_DMA	MOVE.L	D1,temp			
	MOVE.B	temp+1(pc),$ffff8903.w
	MOVE.B	temp+2(pc),$ffff8905.w
	MOVE.B	temp+3(pc),$ffff8907.w
	ADD.L 	#500,D1
	MOVE.L	D1,temp
	MOVE.B	temp+1(pc),$ffff890f.w
	MOVE.B	temp+2(pc),$ffff8911.w
	MOVE.B	temp+3(pc),$ffff8913.w
	MOVE.W	#%0000000000000001,$ffff8920.w
	MOVE.W	#1,$ffff8900.w
	RTS

; MUSIC CONTROLLER (THIS CALLS ALL THE SUBROUTINES)

mr_music:
	move.l	saddr(a2),off(a2)
loop_test:
	move.l	sampptr(pc),a1		; Get samples start address.
	move.l	a1,d0			; For addition.
	move.l	craddr(a2),a0		; Get current sample address.
	add.l	(a0)+,d0		; Get sample offset in D0.
	moveq	#0,d1
	move.w	(a0)+,d1		; Get sample length in D1.
	add.l	d1,d0			; Add sample length to D0.
	cmp.l	off(a2),d0		; Is it over length?
	bgt.s	noendl			; Nope... No loop yet.
	clr.w	new(a2)			; Yep...  Not new sample.
	tst.w	loop(a2)		; Loop sample?
	bne.s	loopit			; Yep... Loop test.
	clr.w	vcon(a2)		; If no loop, no play.
	clr.w	slidin(a2)		; No slide.
	bra.s	noendl
loopit:	sub.l	off(a2),d0		; Get excess playback.
	move.l	sampptr(pc),a1		; Get samples start address.
	move.l	a1,d1			; For addition.
	add.l	-6(a0),d1		; Now is sample address.
	move.l	d1,off(a2)		; Store it.
	moveq	#0,d1
	move.w	(a0)+,d1		; Get sample offset.
	sub.l	d0,d1			; Minus excess.
	add.l	d1,off(a2)		; Add to sample base address.
	bra.s endlooptest
noendl:	clr.l	off(a2)			; Don't reset pointer!
	clr.w	new(a2)
endlooptest:
	tst.w	(a2)			; Is duration on channel on?
	bne.s	nonew			; Nope... Keep on playing sample.
	move.l	sptr(a2),a0		; Yep... Get song pointer.
	tst.w	(a0)			; Pattern command or end?
	bpl.s	noend			; No... Get command.
	cmpi.w	#-9999,(a0)		; End of song?
	bne.s	pattern			; No, then it's a pattern loop.
	move.l	sptr+4(a2),a0		; Yes... Restore song pointer.
	bra.s	noend
pattern:bsr	do_loop			; Do pattern loops.
noend:	move.w	(a0)+,d2		; Get command word.
	btst	#0,d2			; NEW SAMPLE?
	beq.s	nosamp
	bsr	new_sample		; Go to sample routine.
nosamp:	btst	#1,d2			; NEW NOTE?
	beq.s	nonote
	bsr	new_note		; Yep... Go to note routine.
nonote:	btst	#2,d2			; SLIDE?
	beq.s	nslide			; Yep... Go to slide routine.
	bsr	slide_note
nslide:	btst	#3,d2
	beq.s	norest
	bsr	rest
norest:	move.l	a0,sptr(a2)		; Store new song pointer.
	btst	#14,d2			; Loop on this channel?
	beq.s	noloop
	move.w	#1,loop(a2)		; Yes... Signal loop flag.
	bra.s	yesl
noloop:	clr.w	loop(a2)		; No... Clear loop flag.
yesl:
nonew:	subq.w	#1,(a2)			; Countdown for next command.

; Slide test.

slideit:tst.w	slidin(a2)		; Are we sliding?
	beq.s	donesl			; Nope... So skip.
	move.w	note(a2),d0		; Yes... Get current note.
	cmp.w	6(a2),d0		; Is it = to destination note?
	beq.s	skipsl			; Yes... Stop sliding.
	subq.w	#1,scount(a2)		; No... Do slide rate...
	bne.s	donesl
	move.w	slide(a2),scount(a2)
	cmp.w	6(a2),d0		; Compare both notes.
	bgt.s	subit
	add.w	#512,note(a2)		; Source > dest, so slide up.
	bra.s	donesl			; Continue sliding.
subit:	sub.w	#512,note(a2)		; Source < dest, so slide down.
	bra.s	donesl			; Continue sliding.
skipsl:	clr.w	slidin(a2)		; Signal no slide.
donesl:	rts

new_sample:
	move.l	sampptr(pc),a1		; Get samples start address.
	move.l	a1,d1			; Into D1 for addition.
	move.l slistptr(pc),a1		; Get sample address table.
	move.w	(a0)+,d0		; Get sample number
	lsl.w	#3,d0			; x 8 bytes per entry.
	adda.w	d0,a1			; Now A1 points to sample entries.
	add.l	(a1),d1			; = Sample address.
	move.l	d1,off(a2)		; Store it.
	move.w	#1,new(a2)		; Signal new sample.
	move.l	a1,craddr(a2)		; And store pointer for others.
	move.w	#1,vcon(a2)		; Enable playback.
	rts

new_note:
	move.l	sampptr(pc),a1		; Get samples start address.
	move.l	a1,d1			; For addition.
	tst.w	loop(a2)		; Am I looping?
	bne.s	on			; Yes.. Do loop.
	move.l	craddr(a2),a1		; No... Get sample pointer.
	add.l	(a1),d1			; And make it start of sample.
	move.l	d1,off(a2)		; Store new address.
	move.w	#1,new(a2)		; Signal new sample.
on:	move.w	(a0)+,d0		; Yes... Get note.
	moveq	#9,d1
	lsl.w	d1,d0			; x 512 bytes for tables.
	move.w	d0,note(a2)		; Now new note.
	move.w	(a0)+,(a2)		; And new duration.
	move.w	#1,vcon(a2)		; Enable playback.
	rts

slide_note:
	move.w	(a0)+,d0		; Slide to note...
	moveq	#9,d1
	lsl.w	d1,d0			; (X 512 for table)
	move.w	d0,6(a2)
	move.w	(a0)+,d0		; Get slide delay value.
	move.w	d0,slide(a2)		; Put it in storage.
	move.w	d0,scount(a2)		; And in the counter.
	move.w	#1,slidin(a2)		; Signal slide in progress.
	move.w	(a0)+,dur(a2)		; Get duration.
	rts

rest:	move.w	(a0)+,(a2)		; Get duration of rest.
	clr.w	vcon(a2)		; And don't play.
	rts

do_loop:move.w	(a0)+,d0		; Get loop signal.
	move.b	(a0)+,d0		; Get loop value.
	move.b	(a0)+,d1		; Get loop counter.
	bne.s	keeplp			; Zero? No, more loops.
	move.b	d0,-1(a0)		; Restore loop counter.
	addq.w	#2,a0			; And go past loop address.
	tst.w	(a0)			; Is it a pattern command?
	bpl.s	moresng			; No, then play whatever.
	cmpi.w	#-9999,(a0)
	bne.s	do_loop
	move.l	sptr+4(a2),a0		; Yes... Restore song pointer.
moresng:rts
keeplp:	subq.b	#1,d1			; Increase loop counter.
	move.b	d1,-1(a0)		; Store counter.
	sub.w	(a0),a0			; And loop back to address.
	rts

nul_sample
	dcb.b 7*256,$0

; ROUTINE FOR GENERATING 64 256 WORD NOTE TABLES. RETURNS WITH A5 POINTING
; TO END OF TABLES.

gentabs:lea	notes,a5
	lea	notetab(pc),a6		; Address of note table.
	moveq	#64-1,d3		; 64 notes.
nxtnote:move.l	(a6)+,d6		; Get note int and frac.
	moveq	#0,d5			; Clear D5.
	swap	d6			; Access to int part.
	move.w	d6,d4			; And into lower D5.
	clr.w	d6			; Get rid of D6 integer part.
	swap	d6			; Restore D6 mow only frac part.
	move.w	#256-1,d7		; 256 note skips. (20 to see!)
addem:	swap	d5			; Access to int.
	move.w	d4,d5			; Restore int.
	swap	d5			; And make upper D5 int.
	add.l	d6,d5			; Add frac & overflow =1 to D5.
	swap	d5			; Get int part.
	move.w	d5,(a5)+		; Store note skip value.
	swap	d5			; Restore D5 back to normal.
	dbra	d7,addem		; Do for 256 skips.
	dbra	d3,nxtnote		; Do for 64 notes.
	rts

; FIND TUNE. (Needed every time a new tune is played).

find_tune:
	move.l	tuneptr(pc),a0		; Get tune pointer.
	move.w	#-9999,d0
	lea dur1(pc),a1
	move.l	a0,sptr(a1)		; Store the channel's tune addr.
	move.l	a0,sptr+4(a1)		; Twice for the player.
srchnt2:cmp.w	(a0)+,d0	
	bne.s	srchnt2
	lea dur2(pc),a1
	move.l	a0,sptr(a1)
	move.l	a0,sptr+4(a1)		
srchnt3:cmp.w	(a0)+,d0
	bne.s	srchnt3
	lea dur3(pc),a1
	move.l	a0,sptr(a1)
	move.l	a0,sptr+4(a1)
srchnt4:cmp.w	(a0)+,d0
	bne.s	srchnt4
	lea dur4(pc),a1
	move.l	a0,sptr(a1)
	move.l	a0,sptr+4(a1)		
	rts

; FIND SAMPLES

find_samples:
	lea slistptr(pc),a1
	move.l	(a1),a0			; Get voice set address.
	lea sampptr(pc),a1
.find	tst.w	(a0)			; See if negative.
	addq.w #8,a0
	bpl.s	.find			; No...  Continue search.
	subq.w	#6,a0
	move.l	a0,(a1)			; Store samples addresses.
	
	lea endvceset,a2
	move.b #$80,d2
.lp	move.b (a0),d0
	eor.b d2,d0
	ext.w d0
	asr.w #1,d0
	move.b d0,(a0)+
	cmp.l a2,a0
	bne.s .lp
	rts				; Return.

; Initialise one channel's data pointed to by A0.

initvoice:
	move #5,dur(a0)
	clr note(a0)
	clr loop(a0)
	clr slide(a0)
	clr slidin(a0)
	lea.l nul_sample(pc),a1
	move.l a1,craddr(a0)
	move.w #1,vcon(a0)
	move.l a1,off(a0)
	clr.w new(a0)
	move.l a1,saddr(a0)
	rts

; 64 notes to generate tables...  Int and frac parts in word pairs.
; Generated using note formula in GFA Basic V3. Base freq: 440Hz.

notetab:DC.W	$0,$2596,$0,$27D3,$0,$2A31,$0,$2CB3  ; 11khz samples
	DC.W	$0,$2F5B,$0,$322C,$0,$3528,$0,$3851  ; at 12.5khz
	DC.W	$0,$3BAB,$0,$3F37,$0,$42F9,$0,$46F5
	DC.W	$0,$4B2D,$0,$4FA6,$0,$5462,$0,$5967
	DC.W	$0,$5EB7,$0,$6459,$0,$6A51,$0,$70A3
	DC.W	$0,$7756,$0,$7E6F,$0,$85F3,$0,$8DEA
	DC.W	$0,$965B,$0,$9F4C,$0,$A8C4,$0,$B2CE
	DC.W	$0,$BD6F,$0,$C8B3,$0,$D4A2,$0,$E147
	DC.W	$0,$EEAD,$0,$FCDE,$1,$BE7,$1,$1BD5
	DC.W	$1,$2CB6,$1,$3E98,$1,$5189,$1,$659C
	DC.W	$1,$7ADF,$1,$9167,$1,$A945,$1,$C28F
	DC.W	$1,$DD5A,$1,$F9BC,$2,$17CF,$2,$37AB
	DC.W	$2,$596C,$2,$7D30,$2,$A313,$2,$CB38
	DC.W	$2,$F5BF,$3,$22CE,$3,$528B,$3,$851E
	DC.W	$3,$BAB4,$3,$F379,$4,$2F9E,$4,$6F57
	DC.W	$4,$B2D9,$4,$FA60,$5,$4627,$5,$9670

;------------------------------------------------------------------------
;------------------------------------------------------------------------
;------------------------------------------------------------------------

; Parallax scrolling bars bits.

apppararasts	lea toprasts(pc),a2
.lp		JSR wait_vbl
		JSR insert_pararasts
		JSR SwapTables
		JSR insert_pararasts
		JSR SwapTables
		ADDQ.L #2,A2
		CMP.L #here+2,A2
		BNE.S .lp
		RTS

dapppararasts	lea here(pc),a2
.lp		JSR wait_vbl
		JSR insert_pararasts
		JSR SwapTables
		JSR insert_pararasts
		JSR SwapTables
		SUBQ.L #2,A2
		CMP.L #toprasts,A2
		BNE.S .lp
		RTS

insert_pararasts
		move.l a2,-(sp)
		move.l logscrtable_ptr,a0
		addq.w #6,a0
		lea 207*8(a0),a1
		moveq #13-1,d1
.lp		move.w (a2)+,d0
		move.w d0,(a0)
		move.w d0,(a1)
		addq.w #8,a0
		subq.w #8,a1
		dbf d1,.lp
		move.l (sp)+,a2
		rts

toprasts	DS.W 16
here		dc.w $001
		dc.w $002
		dc.w $113
		dc.w $224
		dc.w $335
		dc.w $446
		dc.w $556
		dc.w $667
		dc.w $777
		dc.w $666
		dc.w $444
		dc.w $333
		dc.w $111

parapal1	dc.w	$000,$507,$406,$305,$204,$103,$002,$001
		dc.w	$700,$700,$700,$700,$700,$700,$700,$700

; Wave 1 - Standard left scrolling parralax columns

ParaWave1	MOVE.L logscrtable_ptr,A0
		LEA 14*8(A0),A0
		LEA lineaddrlookup1(PC),A2
		ADDQ #8,.para1mod+2
.para1mod	MOVE.W #0,D1
		AND.W #$1FC,D1
		MOVE.L (A2,D1),D1
		MOVEQ #0,D0
		MOVE #180-1,D6
.line_lp	MOVE.L D1,(A0)+
		MOVE.L D0,(A0)+
		DBF D6,.line_lp
		RTS

; Wave 2 - Standard scrolling parralax columns moving in a sin wave.

ParaWave2	MOVE.L logscrtable_ptr,A0
		LEA 14*8(A0),A0
		LEA sintable1(PC),A1
		LEA lineaddrlookup1(PC),A2
		LEA ParaWave2Sin(PC),A3
		MOVEM.W (A3)+,D2-D5 
		MOVE.W #$7FF,D0
		AND.W D0,D2
		AND.W D0,D3
		AND.W D0,D4
		AND.W D0,D5
		MOVE.W (A1,D2),D1
		ADD.W (A1,D3),D1
		ADD.W (A1,D4),D1
		ADD.W (A1,D5),D1
		AND.W #$1FC,D1
		MOVE.L (A2,D1),D1
		MOVEQ #0,D0
		MOVE #180-1,D6
.line_lp	MOVE.L D1,(A0)+
		MOVE.L D0,(A0)+
		DBF D6,.line_lp
		ADDQ.W #8,-(A3)
		ADDQ.W #8,-(A3)
		ADDQ.W #8,-(A3)
		ADDQ.W #8,-(A3)
		RTS
ParaWave2Sin	DC.W 0,0,0,0

; Wave 3 - Scrolling parralax columns disting!
;          (with quatruple sine tables! and moving left! wow!)

ParaWave3o	DCB.W 90-5-34-5,$4E71
		MOVE.L SP,savespp		;5
		SUB.L A7,A7			;2
		LEA sintable1(PC),A1		;2
		LEA lineaddrlookup1(PC),A2	;2
		LEA ParaWave3Sin(PC),A3		;2
		MOVEM.W (A3)+,D2-D5		;6
		LEA para3mod(PC),A3 		;2
		ADDQ.W #8,(A3)			;4
		MOVE.L physcrtable_ptr,A4	;5
		LEA 14*8(A4),A4			;2
		MOVE #90-1,D1			;2=32
		DCB.W 4,$4E71
.lp		SWAP D1		 ;1
		rdnextli	
		setscrli
		DCB.W 90-3-1-84-1,$4E71
		REPT 2
		MOVE.W #$7FF,D1  ;2
		AND.W D1,D2	 ;1
		AND.W D1,D3	 ;1
		AND.W D1,D4      ;1
		AND.W D1,D5      ;1
		MOVE.W (A1,D2),D1;4
		ADD.W (A1,D3),D1 ;4
		ADD.W (A1,D4),D1 ;4
		ADD.W (A1,D5),D1 ;4
		ADD.W (A3),D1	 ;2
		LSR #1,D1	 ;2
		AND.W #$1FC,D1   ;2
		MOVE.L (A2,D1),(A4)+ ;7
		MOVE.L A7,(A4)+	;3
		ADDQ.W #4,D2	;1
		ADDQ.W #2,D3	;1
		ADDQ.W #6,D4	;1
		ADDQ.W #4,D5	;1
		ENDR
		SWAP D1		;1
		DBF D1,.lp
		rdnextli	
		setscrli
		LEA ParaWave3Sin+8(PC),A3	;2
		ADD #$E,-(A3)
		ADD #10,-(A3)
		ADD #6,-(A3)
		ADD #$FFF8,-(A3)
		MOVE.L savespp(PC),SP
		DCB.W 90-4-4-(4*5)-2,$4E71
		RTS
para3mod	DC.W 0
ParaWave3Sin	DC.W 0,0,0,0
savea3		DC.L 0
savespp		DC.L 0

; ParaWave 4
; Wave 4 - 32 layer parralax.

ParaWave4o	DCB.W 90-5-40-5,$4E71
		MOVE.L SP,savespp	;5
		SUB.L A7,A7		;2
		MOVE.L physcrtable_ptr,A2  5;
		LEA 14*8(A2),A2		;2
		LEA sintable2(PC),A1	;2
		LEA ParaWave4Sin(PC),A3 ;2
		LEA para4mod(PC),A4 	;2
		MOVE.W (A4),D0		;2
		ADD.W #208,D0		;2
		CMP.W #208*$20,D0	;2
		BNE.S .notwrap		;3
		CLR.W D0	 	;
.notwrap	MOVE.W D0,(A4)		;2
		MOVEM.W (A3)+,D2-D5 	;6
		MOVE #90-1,D1		;2
		DCB.W 4,$4E71
.lp		SWAP D1		 ;1
		rdnextli	
		setscrli
		DCB.W 89-3-1-80,$4E71
		REPT 2 
		MOVE.W #$7FF,D1	;2
		AND.W D1,D4	;1
		MOVE.W (A1,D4),D1 ;4
		ADD.W (A1,D4),D1  ;4
		ADD.W (A1,D4),D1  ;4
		ADD.W (A1,D4),D1  ;4
		LSR #1,D1	;2
		AND.W #$FC,D1	;2
		LEA lineaddrlookup2(PC),A3
		MOVE.L (A3,D1),a3 ;5
		ADD.W (A4),a3  ;3
		MOVE.L a3,(A2)+ ;3
		MOVE.L A7,(A2)+ ;3
		ADDQ.W #8,D4	;1
		ENDR
		SWAP D1		;1
		DBF D1,.lp	;3
		rdnextli	
		setscrli
		MOVE.L savespp(PC),SP
		DCB.W 90-4-4,$4E71
		RTS

para4mod	DC.W 0 
ParaWave4Sin	DCB.W 4,230

; Wave 5 - MANIC Scrolling parralax columns disting!
;          (with quatruple sine tables! and moving left! wow!)

ParaWave5o	DCB.W 90-5-35-5,$4E71
		MOVE.L SP,savespp		;5
		SUB.L A7,A7			;2
		LEA sintable1(PC),A1		;2
		LEA lineaddrlookup1(PC),A2	;2
		LEA ParaWave5Sin(PC),A3		;2
		MOVEM.W (A3)+,D2-D5		;6
		LEA para5mod(PC),A3 		;2
		ADD.W #24,(A3)			;4
		MOVE.L physcrtable_ptr,A4	;5
		LEA 14*8(A4),A4			;2
		MOVE #90-1,D1			;2=32
		MOVE.W #$7FF,D4	  	;2
		DCB.W 2,$4E71
.lp		SWAP D1		 ;1
		rdnextli	
		setscrli
		DCB.W 90-3-1-82-1,$4E71
		REPT 2
		AND.W D4,D2	 ;1
		AND.W D4,D3	 ;1
		AND.W D4,D5      ;1
		MOVE.W (A1,D2),D1;4
		ADD.W (A1,D3),D1 ;4
		ADD.W (A1,D2),D1 ;4
		ADD.W (A1,D5),D1 ;4
		ADD.W (A3),D1	 ;2
		LSR #1,D1	 ;2
		AND.W #$1FC,D1   ;2
		MOVE.L (A2,D1),(A4)+ ;7
		MOVE.L A7,(A4)+	;3
		ADD.W #12,D2	;1
		ADD.W #16,D3	;1
		ADD.W #18,D5	;1
		ENDR
		SWAP D1		;1
		DBF D1,.lp
		rdnextli	
		setscrli
		LEA ParaWave5Sin+8(PC),A3	;2
		ADD #12,-(A3)
		ADD #14,-(A3)
		ADD #26,-(A3)
		ADD #34,-(A3)
		MOVE.L savespp(PC),SP
		DCB.W 90-4-4-(4*5)-2,$4E71
		RTS
para5mod	DC.W 0
ParaWave5Sin	DC.W 0,0,0,0

; ParaWave 6
; Wave 6 - 32 layer PIVOTTED parralax.

ParaWave6o	DCB.W 90-5-40-5,$4E71
		MOVE.L SP,savespp	;5
		SUB.L A7,A7		;2
		MOVE.L physcrtable_ptr,A2  5;
		LEA 14*8(A2),A2		;2
		LEA sintable2(PC),A1	;2
		LEA ParaWave6Sin(PC),A3 ;2
		LEA para6mod(PC),A4 	;2
		MOVE.W (A4),D0		;2
		ADD.W #208,D0		;2
		CMP.W #208*$20,D0	;2
		BNE.S .notwrap		;3
		CLR.W D0	 	;
.notwrap	MOVE.W D0,(A4)		;2
		MOVEM.W (A3)+,D2-D5 	;6
		MOVE #90-1,D1		;2
		DCB.W 4,$4E71
.lp		SWAP D1		 ;1
		rdnextli	
		setscrli
		DCB.W 89-3-1-78,$4E71
		REPT 2 
		MOVE.W #$7FF,D1	;2
		AND.W D1,D2    ;1
		AND.W D1,D4	;1
		MOVE.W (A1,D2),D1 ;4
		ADD.W (A1,D2),D1  ;4
		ADD.W (A1,D4),D1  ;4
		ADD.W (A1,D4),D1  ;4
		LSR #1,D1	;2
		AND.W #$FC,D1	;2
		LEA lineaddrlookup2(PC),A3
		MOVE.L (A3,D1),a3 ;5
		MOVE.L a3,(A2)+ ;3
		MOVE.L A7,(A2)+ ;3
		ADDQ.W #8,D2	;1
		ADDQ.W #8,D4	;1
		ENDR
		SWAP D1		;1
		DBF D1,.lp	;3
		rdnextli	
		setscrli
		LEA ParaWave6Sin+8(PC),A3 ;2
		ADD.W #16,-(A3)
		ADD.W #16,-(A3)
		SUB.W #16,-(A3)
		SUB.W #16,-(A3)
		MOVE.L savespp(PC),SP
		DCB.W 90-4-4-(5*4)-2,$4E71
		RTS

para6mod	DC.W 0 
ParaWave6Sin	DCB.W 4,230

i		SET 8
lineaddrlookup2	
		REPT $40
		DC.L PARAframes+i
i		SET i+(208*$20)
		ENDR

i		SET 8
lineaddrlookup1	
		REPT $80
		DC.L frame_buf+i
i		SET i+208
		ENDR

; Straightforward piccy dist

do_piccydist1	LEA disttab(PC),A0
		ADD.W dist_ptr(PC),A0
		MOVE.L logscrtable_ptr,A1
		MOVEQ #0,D1
		MOVE.L #160,D2
		MOVE.W curr_pal(PC),D4
		REPT 4
		MOVE.W D4,6(A1)
		ADDQ.W #8,A1
		ENDR
		REPT 200
		MOVEM.L (A0)+,D0/D3
		ADD.L D1,D0
		ADD.L D2,D1
		MOVE.L D0,(A1)+
		MOVE.W D3,(A1)+
		MOVE.W D4,(A1)+
		ENDR
		REPT 4
		MOVE.W D4,6(A1)
		ADDQ.W #8,A1
		ENDR
		BSR calc_dist
		BSR calc_dist
		RTS

; flipping piccy dist

do_piccydist2	
		JSR calc_dist
		JSR calc_dist
		LEA disttab(PC),A0
		ADD.W dist_ptr(PC),A0
		MOVE.L logscrtable_ptr,A5
		MOVE.W flipframecnt(PC),D0
		ADDQ.W #1,flipframecnt
		CMP.W #90,flipframecnt
		BNE.S .ok
		CLR.W flipframecnt
.ok		MULU #2*200,d0
		LEA fliptable,A2
		ADD.L D0,A2
		MOVE.L A0,distptr
		MOVE.L A2,flipptr
		MOVEQ #0,D1
		MOVE.L #blankarea,D0
		MOVE.W curr_pal(PC),D1
		MOVE.L D0,D2
		MOVE.L D1,D3
		MOVE.L D0,D4
		MOVE.L D1,D5
		MOVE.L D0,D6
		MOVE.L D1,D7
		LEA 208*8(A5),A5
		REPT 52
		MOVEM.L D0-D7,-(A5)
		ENDR
		RTS

flipframecnt	DC.W 0

; Flipper

flipo		DCB.W 90-5-5-32,$4E71
		MOVE.L SP,savespp		;5
		MOVE.L physcrtable_ptr,A1	;5
		MOVE.L flipptr,A2		;5
		MOVE.L distptr,A7		;5
		MOVE.W curr_pal,D4		;4
		LEA 4*8(A1),A1			;2
		MOVEQ #0,D1			;1
		MOVE.L #160,D2			;3
		MOVE #100-1,D5			;2=13
		DCB.W 4,$4E71
.lp		NOP
		rdnextli	
		setscrli
		DCB.W 90-3-1-(2*21),$4E71
		REPT 2
		MOVE.L (A7)+,A3 ;3
		MOVE.L (A7)+,D3 ;3
		ADD.L D1,A3	;3
		ADD.L D2,D1	;2
		MOVE.L A1,A4  	;1
		ADD.W (A2)+,A4	;3
		MOVE.L A3,(A4)+	;3
		MOVE.W D3,(A4)+	;2
		MOVE.W D4,(A4)+	;2
		ENDR
		DBF D5,.lp
		rdnextli	
		setscrli
		MOVE.L savespp(PC),SP
		DCB.W 90-4-4,$4E71
		RTS
flipptr		DC.L fliptable
distptr		DC.L disttab

; Generate 16 layers of scrolling parrallax columns.

Gen_Para	LEA PARAframes,A3
		MOVE.W #$40/2,framecnt
		MOVE.L #framesprites+(15*16),A4
		MOVE.W #16,-(SP)
layer_lp	MOVEQ.L	#$7F,D2
		LEA frame_buf,A0
		MOVE.L #$898,inframecnt
		SUBQ.W #2,framecnt
xlayer_lp	MOVE.L inframecnt(PC),D5
contlayer	MOVE.L D5,D3
		MOVE.W framecnt(PC),D4
		MULS D4,D3
		ADDI.W #$B,D4
		DIVS D4,D3
		NEG.W D3
		ADD.W D5,D3
		ADDI.W #$800+(208*2),D3
		CMPI.W #$800+(208*4),D3
		BHI ontonext
		SUB.W #$800,D3
		BLT donelay
		LSR #1,d3
; Draw 32*1 sprite - real time shift rout... (simple but very fast).
draw		MOVEM.L D2-D5,-(SP)
		MOVE D3,D5	
		AND #15,D5		; shift amount in word
		LSR #1,D3
		AND #$FFF8,D3		; row offset
		MOVE.L A0,A1		; -> OUTPUT AREA
		ADDA D3,A1		; screen addr
		MOVEQ #-1,D7
		LSR.W D5,D7		; masks for start
		MOVE.W D7,D6
		SWAP D7
		MOVE.W D6,D7		; longword!!
		MOVE.L D7,D6
		NOT.L D6
		ADDQ.L #8,A1		; we plot middle first!!
		MOVEM.L (A4),D0-D3	; mask 'n' 4 planes data
		ROR.L D5,D0 
		ROR.L D5,D1 
		ROR.L D5,D2 		; shift the 32 pixels
		ROR.L D5,D3 
		MOVEQ #0,D4
		AND.W D0,(A1)
 		OR.W D1,(A1)+
		AND.W D0,(A1)
 		OR.W D2,(A1)+
		AND.W D0,(A1)		; plot MIDDLE chunk
 		OR.W D3,(A1)+
		ADDQ.L #2,A1
		SWAP D2
		MOVE.W D2,D1		; D1.L plane1./plane2.w
		SWAP D4
		MOVE.W D4,D3		; D3.L plane3./plane4.w
		MOVE.L D0,D4
		SWAP D4			; hmmmm....
		MOVE.W D4,D0		; longword mask.
		MOVE.L D0,D4
		OR.L D7,D0		; mask for END chunk
		OR.L D6,D4		; mask for START chunk
		MOVE.L D1,D2
		AND.L D6,D2
		AND.L D0,(A1)
 		OR.L D2,(A1)+		; plot END chunk
		MOVE.L D3,D2
		AND.L D6,D2
		AND.L D0,(A1)
 		OR.L D2,(A1)+
		AND.L D7,D1		; mask off START chunk
		AND.L D7,D3		
		LEA -24(A1),A1		; -> first chunk
		AND.L D4,(A1)
 		OR.L D1,(A1)+
		AND.L D4,(A1)		; plot START chunk
 		OR.L D3,(A1)+
		MOVEM.L (SP)+,D2-D5

ontonext	SUBI.W #$80,D5
		BRA contlayer
donelay		LEA 208(A0),A0
		SUBQ.L #1*2,inframecnt
		DBF D2,xlayer_lp
		LEA -16(A4),A4
		LEA frame_buf,A2
		MOVEQ #$20-1,D7
.lp		
		REPT 52
		MOVE.L (A2)+,(A3)+
		ENDR
		LEA (208*3)(A2),A2
		DBF D7,.lp
		SUBQ #1,(SP)
		BNE layer_lp
		ADDQ.L #2,SP
		RTS
framecnt	DC.W 0
inframecnt	DC.L 0

;-----------------------------------------------------------------------;
;              FullScreen Plasmas!! (Colour Cycling!)			;
;-----------------------------------------------------------------------;

do_plasma	MOVE.L #rout1,rout_ptr
		JSR wait_vbl
		JSR ClearTables
		JSR wait_vbl
		JSR wait_vbl
		JSR wait_vbl
		JSR wait_vbl
		JSR apppararasts
		JSR wait_vbl
		JSR wait_vbl
		JSR wait_vbl
		JSR wait_vbl
		JSR wait_vbl
		JSR SwapTables
		BSR insert_pararasts
		MOVE.L #rout10,rout_ptr
		JSR wait_vbl
		MOVE.L physcrtable_ptr,A0
		MOVE.L #cycle,vbl_extrarout
		LEA 14*8(A0),A0
		LEA screens,A1
		MOVE.W #180-1,D1
.lp		MOVE.L A1,(A0)+
		CLR.L (A0)+
		LEA 224(A1),A1
		DBF D1,.lp
		LEA plasma4(PC),A2		
		BSR Make_plasma
		MOVE #200-1,D7
.lp1		JSR wait_vbl
		dbf d7,.lp1
		LEA plasma3(PC),A2		
		BSR Make_plasma
		MOVE #200-1,D7
.lp2		JSR wait_vbl
		dbf d7,.lp2
		LEA plasma6(PC),A2		
		BSR Make_plasma
		MOVE #200-1,D7
.lp3		JSR wait_vbl
		dbf d7,.lp3
		MOVE #180-1,D7
		MOVE.L physcrtable_ptr,A0
		LEA 14*8(A0),A0
		LEA blankarea+256,A1
		MOVE.W #180-1,D1
.lp4		MOVE.L A1,(A0)+
		CLR.L (A0)+
		JSR wait_vbl
		DBF D1,.lp4
		JSR wait_vbl
		JSR wait_vbl
		JSR wait_vbl
		JSR wait_vbl
		JSR wait_vbl
		JSR dapppararasts
		JSR wait_vbl
		JSR wait_vbl
		JSR wait_vbl
		JSR wait_vbl
		JSR wait_vbl
		JSR wait_vbl
		JSR wait_vbl
		RTS

cycle		LEA plasmapal,A0	;2
		MOVE.L A0,A1
		MOVE.W (A0)+,D0		;2
		REPT 15
		MOVE.W (A0)+,(A1)+
		ENDR
		MOVE.W D0,(A1)+		;2
		MOVE.L physcrtable_ptr,A0
		MOVE.W plasmapal,D0
i		SET (14*8)+6
		REPT 180
		MOVE.W D0,i(A0)
i		SET i+8
		ENDR
		RTS

; Plasma shite

Make_plasma	LEA screens,A0
		LEA trig_tab1(PC),A1
		LEA (A1),A3
		MOVEQ #0,D7
.y_lp		MOVEQ #27,D6	
		MOVEQ #0,D5
		LEA (A1),A4
.x_lp		
		REPT 16
		JSR (A2)
		AND #15,D4
		LSR #1,D4
		ROXL (A0)+ 
		LSR #1,D4
		ROXL (A0)+ 
		LSR #1,D4
		ROXL (A0)+
		LSR #1,D4
		ROXL (A0)
		ADDQ #1,D5
		SUBQ.L #6,A0
		ENDR 
		ADDQ.L #8,A0
		DBF D6,.x_lp
		JSR wait_vbl
		ADDQ #1,D7
		CMP #207,D7
		BNE .y_lp
		RTS


plasma3		MOVE.W D7,D4
		SUB.W D5,d4
		MULS (A4),D4
		ADDQ.L #4,A4
		ADD.L D4,D4
		SWAP D4
		RTS

plasma4		MOVE.W D7,D4
		ADD.W #30,D4		
		LSL.W #7,D4
		MULS 100(A4),D4
		ADDQ.L #2,A4
		ADD.L D4,D4
		SWAP D4
		RTS


plasma6		MOVE.W D5,D0
		ADD.W D6,D0
		MULS D0,D0
		DIVU D4,D0
		MOVEQ #-$66+8,D1
		ADD.W D7,D1
		MULS D1,D1
		DIVS D5,D1
		ADD.L D1,D0
		MOVE.L D0,D4
		RTS	


plasmapal	DC.W	$600,$F00,$F10,$F20,$F30,$FC0,$FD0,$FE0
		DC.W	$FF0,$0FF,$0EF,$05F,$04F,$0AF,$09F,$00F

; Standard Tables...

trig_tab1	dc.w	$0000,$00C9,$0192,$025B,$0324,$03ED,$04B6,$057E 
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

sintable1	INCBIN g:\HALLUCIN.DEM\STE_PART\STEPOW.INC\tripsin1.tab
sintable2	INCBIN g:\HALLUCIN.DEM\STE_PART\STEPOW.INC\tripsin2.tab
framesprites	INCBIN g:\HALLUCIN.DEM\STE_PART\STEPOW.INC\ST_BLOCK.DAT


		SECTION DATA

vceset:		INCBIN g:\HALLUCIN.DEM\STE_PART\STEPOW.INC\FOIL.eit
endvceset:
		EVEN
tune:		INCBIN g:\HALLUCIN.DEM\STE_PART\STEPOW.INC\FOIL.SNG
		EVEN
bigfontspce	DS.W 768
bigfont		INCBIN g:\HALLUCIN.DEM\STE_PART\STEPOW.INC\bigfont1.DAT
		EVEN
picture1	INCBIN g:\HALLUCIN.DEM\STE_PART\STEPOW.INC\IC.PI1
blankarea	DS.L 40*8
fliptable	INCBIN g:\HALLUCIN.DEM\STE_PART\STEPOW.INC\ROTATE.DAT
		SECTION BSS
notes:		DS.W 16384
		DS.L 199
stack		DS.L 3	
		DS.W 16
scroll48buf	DS.W 224*48
		DS.W 16
screens		DS.B 230*208*2
workspace	DS.B 150000

; Parallax bars workspace

frame_buf	EQU workspace
PARAframes	EQU workspace+(208*$80)
