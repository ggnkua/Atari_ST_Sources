;-----------------------------------------------------------------------;
;             		    Vertical Mayhem				;
;                                 by					;
;                           Martin Griffiths				;
;-----------------------------------------------------------------------;

; Ok... here is the source, its not very well commented or well written,
; but it works(just about), hope its useful to someone.
; Griff ,March 1994.

		OUTPUT VM.PRG

		OPT O+,OW-

; SetVideo() equates.

VERTFLAG	EQU $0100	; double-line on VGA, interlace on ST/TV ;
STMODES		EQU $0080	; ST compatible ;
OVERSCAN	EQU $0040	; Multiply X&Y rez by 1.2, ignored on VGA ;
PAL		EQU $0020	; PAL if set, else NTSC ;
VGA		EQU $0010	; VGA if set, else TV mode ;
COL80		EQU $0008	; 80 column if set, else 40 column ;
BPS16		EQU $0004
BPS8		EQU $0003
BPS4		EQU $0002
BPS2		EQU $0001
BPS1		EQU $0000

; Cache Control Register Equates (CACR)

ENABLE_CACHE		EQU 1   ; Enable instruction cache
FREEZE_CACHE		EQU 2   ; Freeze instruction cache
CLEAR_INST_CACHE_ENTRY	EQU 4   ; Clear instruction cache entry
CLEAR_INST_CACHE	EQU 8   ; Clear instruction cache
INST_BURST_ENABLE	EQU 16  ; Instruction burst enable
ENABLE_DATA_CACHE	EQU 256 ; Enable data cache
FREEZE_DATA_CACHE	EQU 512 ; Freeze data cache
CLEAR_DATA_CACHE_ENTRY	EQU 1024 ; Clear data cache entry
CLEAR_DATA_CACHE	EQU 2048 ; Clear data cache
DATA_BURST_ENABLE	EQU 4096 ; Instruction burst enable
WRITE_ALLOCATE		EQU 8192 ; Write allocate 

mus_vol		EQU 10
linewid		EQU 320
gemrun		EQU 0			; 0 = run from gem
					; 1 = no gem calls	
timing		EQU 0			; 0 = no timing bar. 1=timing

		BRA.W letsgo
		DC.B "This game is *CRAP*, "
		DC.B "it was written in 1 week in August 1992 for the Amiga."
		DC.B "The game was destined for a coverdisk, but I was only "
		DC.B "paid half the money I was promised... anyway it took about "
		DC.B "3 hours to port.. - Griff."
		EVEN	
letsgo		
		IFEQ gemrun
		MOVE.W #2,-(SP)
		TRAP #14		
		ADDQ.L #2,SP	
		MOVE.L D0,oldbase
		MOVE.W #-1,-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP
		MOVE.W D0,oldvideo
		CLR.L -(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.L D0,oldsp
		MOVE.W #89,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		AND.B #1,D0
		TST.B D0
		BEQ wrongmonitor
		ENDC

		LEA my_stack,SP
		BSR save_pal
		MOVE.W #$8240,A0
		MOVE.W #$9800,A1
		MOVEQ #0,D0
		MOVEQ #16-1,D1
.lp		MOVE.W D0,(A0)+
		MOVE.L D0,(A1)+
		DBF D1,.lp

		BSR connect_sound	
		BSR init_musrotfile		;;
		BSR Genstars			;;
		BSR Preshift_numbs		;;
		BSR prepare_sprites		;;
		BSR init_2screens		
		MOVE #37,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		MOVE.W #PAL+BPS8,-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14			;; better to do with 
		ADDQ.L #4,SP			;; xbios(5)...

		BSR init_ints			;;
.GAME_LP	BSR titlescreen
		BSR Play_game
		BSR dohighscores
		BRA.S .GAME_LP

.out		BSR restore_ints
		IFEQ gemrun
		MOVE.W oldvideo(PC),-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP
		MOVE.W #37,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		BSR rest_pal
		MOVE.W #-1,-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.W #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
outmon		MOVE.L oldsp(PC),-(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		CLR -(SP)
		TRAP #1
		ENDC

wrongmonitor	PEA montext(PC)
		MOVE.W #9,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.W #1,-(SP)
		TRAP #1
		ADDQ.L #2,SP
		BRA.S outmon

montext		DC.B 27,"ESorry, this game requires a TV or Color (SC1224) Monitor.",10,13
		DC.B "Press any key.",0
		EVEN

;-------------------------------------------------------------------------
; Interrupt setup routines

; Save mfp vectors and ints and install our own.(very 'clean' setup rout)

init_ints	MOVEQ #$13,D0			; pause keyboard
		BSR Writeikbd			; (stop from sending)
		
		MOVE #$2700,SR
		MOVEQ #$12,D0			; kill mouse
		BSR Writeikbd

		LEA old_stuff(PC),A0
		MOVE.L USP,A1
		MOVE.L A1,(A0)+
		MOVE.L $68.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $B0.W,(A0)+
		MOVE.L $110.W,(A0)+
		MOVE.L $118.W,(A0)+
		MOVE.L $120.W,(A0)+
		MOVE.L $134.W,(A0)+
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA0B.W,(A0)+
		MOVE.B $FFFFFA0D.W,(A0)+
		MOVE.B $FFFFFA0F.W,(A0)+
		MOVE.B $FFFFFA11.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+	; restore mfp
		MOVE.B $FFFFFA17.W,(A0)+
		MOVE.B $FFFFFA19.W,(A0)+
		MOVE.B $FFFFFA1B.W,(A0)+
		MOVE.B $FFFFFA1D.W,(A0)+
		MOVE.B $FFFFFA1F.W,(A0)+
		MOVE.B $FFFFFA21.W,(A0)+
		MOVE.B $FFFFFA25.W,(A0)+
		MOVE.B #$00,$FFFFFA07.W
		MOVE.B #$40,$fffffa09.W
		MOVE.B #$00,$FFFFFA13.W
		MOVE.B #$40,$fffffa15.W
		BCLR.B #3,$fffffa17.W		; software end of int.
		LEA vbl(PC),A0
		MOVE.L A0,$70.W			; set our vbl
		LEA key_rout(PC),A0
		MOVE.L A0,$118.W		; and our keyrout.
		CLR key			
		MOVE.B #$00,$FFFFFA0F.W
		MOVE.B #$00,$FFFFFA11.W		; dummy service.
		MOVE.B #$00,$FFFFFA0B.W
		MOVE.B #$00,$FFFFFA0D.W		; clear any pendings
		MOVEQ #$15,D0			; set joystick interrogate
		BSR Writeikbd			; -mode.
		MOVE #$2300,SR
		MOVEQ #$11,D0			; resume sending
		BSR Writeikbd
		BSR flush
		RTS

; Restore mfp vectors and ints.

restore_ints	MOVEQ #$13,D0			; pause keyboard
		BSR Writeikbd			; (stop from sending)
		MOVE #$2700,SR
		LEA old_stuff(PC),A0
		MOVE.L (A0)+,A1
		MOVE.L A1,USP
		MOVE.L (A0)+,$68.W
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$B0.W
		MOVE.L (A0)+,$110.W
		MOVE.L (A0)+,$118.W
		MOVE.L (A0)+,$120.W
		MOVE.L (A0)+,$134.W
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA0B.W
		MOVE.B (A0)+,$FFFFFA0D.W
		MOVE.B (A0)+,$FFFFFA0F.W
		MOVE.B (A0)+,$FFFFFA11.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W	; restore mfp
		MOVE.B (A0)+,$FFFFFA17.W
		MOVE.B (A0)+,$FFFFFA19.W
		MOVE.B (A0)+,$FFFFFA1B.W
		MOVE.B (A0)+,$FFFFFA1D.W
		MOVE.B (A0)+,$FFFFFA1F.W
		MOVE.B (A0)+,$FFFFFA21.W
		MOVE.B (A0)+,$FFFFFA25.W
		MOVE #$2300,SR
		MOVEQ #$11,D0			; resume
		BSR Writeikbd		
		MOVEQ #$8,D0			; restore mouse.
		BSR Writeikbd
		BSR flush
		RTS

old_stuff:	DS.L 32
oldbase		DS.L 1
oldvideo	DS.W 1
oldsp		DS.L 1

; Connect sound

connect_sound	moveq #0,d0
		moveq #0,d1
		bsr settracks
		moveq #0,d0
		bsr setmontracks
		moveq #0,d0
		moveq #8,d1
		moveq #0,d2
		moveq #1,d3
		moveq #1,d4
		bsr devconnect
		RTS

settracks	move.w d1,-(sp)
		move.w d0,-(sp)
		move.w #133,-(sp)
		trap #14
		addq.l #6,sp
		rts
setmontracks	move.w d0,-(sp)
		move.w #134,-(sp)
		trap #14
		addq.l #4,sp
		rts
devconnect	move.w d4,-(sp)
		move.w d3,-(sp)
		move.w d2,-(sp)
		move.w d1,-(sp)
		move.w d0,-(sp)
		move.w #139,-(sp)
		trap #14
		lea 12(sp),sp
		rts

; Save palette

save_pal	MOVEM.L $FFFF8240.W,D0-D7
		MOVEM.L D0-D7,old_pal
		LEA $FFFF9800.W,A0
		LEA old_falcpal,A1
		MOVE #256-1,D0
.save_pallp	MOVE.L (A0)+,(A1)+
		DBF D0,.save_pallp		
		RTS

rest_pal	MOVEM.L old_pal,D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		LEA old_falcpal,A0
		LEA $FFFF9800.W,A1
		MOVE #256-1,D0
.rest_pallp	MOVE.L (A0)+,(A1)+
		DBF D0,.rest_pallp		
		RTS
old_falcpal	DS.L 256
old_pal		DS.W 16

; Allocate and Initialise(clear) screen memory.

init_2screens	LEA log_base(PC),A1
		MOVE.L #screens+256,D0
		CLR.B D0
		MOVE.L D0,A0
		MOVE.L A0,(A1)+
		BSR cls
		ADD.L #32256*2,A0
		MOVE.L A0,(A1)+
		BSR cls
		MOVE.L phy_base(PC),D0
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		RTS

; Clear a 32k screen. a0 -> screen.

cls		MOVE.L A0,A2
		MOVEQ #0,D0
		MOVE.W #(32256*2/16)-1,D1
.cls_lp		MOVE.L D0,(A2)+
		MOVE.L D0,(A2)+
		MOVE.L D0,(A2)+
		MOVE.L D0,(A2)+
		DBF D1,.cls_lp
		RTS

copypic_toboth	move.l log_base(pc),a1
		move.l phy_base(pc),a2
		move.w #200-1,d6
.lp		moveq #20-1,d7	
.li_lp		move.w (a0),(a1)+
		move.w (a0)+,(a2)+
		move.w (40*1)-2(a0),(a1)+
		move.w (40*1)-2(a0),(a2)+
		move.w (40*2)-2(a0),(a1)+
		move.w (40*2)-2(a0),(a2)+
		move.w (40*3)-2(a0),(a1)+
		move.w (40*3)-2(a0),(a2)+
		move.w (40*4)-2(a0),(a1)+
		move.w (40*4)-2(a0),(a2)+
		ADDQ.L #6,A1
		ADDQ.L #6,A2
		dbf d7,.li_lp
		lea 160(a0),a0
		dbf d6,.lp
		rts

; Swap Screen ptrs and set hardware reg for next frame.

SwapScreens	LEA log_base(PC),A0
		MOVEM.L (A0)+,D0-D1
		NOT.W (A0)
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR.W #8,D0
		MOVE.L D0,$FFFF8200.W
		RTS
;-------------------------------------------------------------------------

vbl		MOVEM.L D0-D7/A0-A6,-(SP)
		LEA currpal(PC),A0
		LEA $FFFF9800.W,A1
		MOVEQ #32-1,D0
.lp		MOVE.W (A0)+,D2
		MOVEQ #0,D3
.do_r		MOVE.W D2,D3
		AND.W #$F00,D3
		SWAP D3
		LSL.L #4,D3
.do_g		MOVEQ #0,D1
		MOVE.W D2,D1
		AND.W #$0F0,D1
		SWAP D1
		OR.L D1,D3
.do_b		AND.W #$00F,D2
		LSL.W #4,D2
		MOVE.W D2,D3
		MOVE.L D3,(A1)+
		DBF D0,.lp
		MOVEQ #$16,D0	
		BSR Writeikbd		; interrogate the joy pos.
		TST.B star_flag
		BEQ.S .nostarf
		BSR Clearstars
		BSR Plotstars
.nostarf	JSR rotfile+8+28
		BSR fade_to
		;not.w $ffff8240.w
		MOVEM.L (SP)+,D0-D7/A0-A6
		ADDQ #1,vbl_timer
		RTE

; Wait for a vbl.... 
; D0/A0 trashed.

wait_vbl	LEA vbl_timer(PC),A0
		MOVE.W (A0),D0
.wait_vbl	CMP.W (A0),D0
		BEQ.S .wait_vbl
		RTS

; Wait for D7 vbls.
; D7/D0/A0 trashed

WaitD7Vbls	LEA vbl_timer(PC),A0
		SUBQ #1,D7
.wait_lp	MOVE.W (A0),D0
.wait_vbl	CMP.W (A0),D0
		BEQ.S .wait_vbl
		DBF D7,.wait_lp
		RTS

; Flush IKBD

flush		BTST.B #0,$FFFFFC00.W		; any waiting?
		BEQ.S .flok			; exit if none waiting.
		MOVE.B $FFFFFC02.W,D0		; get next in queue
		BRA.S flush			; and continue
.flok		RTS

; Write d0 to IKBD

Writeikbd	BTST.B #1,$FFFFFC00.W
		BEQ.S Writeikbd			; wait for ready
		MOVE.B D0,$FFFFFC02.W		; and send...
		RTS

; Keyboard handler interrupt routine...

key_rout	MOVE #$2500,SR			; ipl 5 for 'cleanness' 
		MOVE.L D0,-(SP)
		MOVE.B $FFFFFC00.W,D0
		BTST #7,D0			; int req?
		BEQ.S .end			
		BTST #0,D0			; 
		BEQ.S .end
		MOVE.B $FFFFFC02.W,D0
		CMP.B #$FD,D0
		BEQ.S .joyevent1
		MOVE.B D0,key		; store keypress
.end		MOVE.L (SP)+,D0
		RTE

.joyevent1	MOVE.L #.joy1,$118.W
		BRA.S .end
.joy1		MOVE.B $FFFFFC02.W,joy1
		MOVE.L #.joy2,$118.W
		RTE
.joy2		MOVE.B $FFFFFC02.W,joy2
		MOVE.L #key_rout,$118.W
		RTE

joy1		DC.B 0
joy2		DC.B 0

key		DC.W 0
vbl_timer	DC.W 0
log_base	DC.L 0
phy_base	DC.L 0
frame_switch	DC.W 0

;----------------------------------------------------------
; Fade routs.

currpal		DS.L 32
blank_pal	DS.L 32

; Trigger a fade.
; A0 -> current palette.
; A1 -> palette to fade to.

TrigFadeTo	LEA fadeto_vars(pc),a5
		MOVE.L A0,fadeto_curptr(a5)
		MOVE.L A1,fadeto_palptr(a5)
		MOVE.W #32,fadeto_nocols(a5)
		MOVE.W #16,fadeto_cnt(a5)
		MOVE.B #3,fadeto_tim(a5)
		MOVE.B #3,fadeto_spd(a5)
		ST.B fadetoflag(a5)
		RTS

; Trigger a Fade from one palette to another.(and wait for fade to finish)

; A0 -> current palette.
; A1 -> palette to fade to.

FadeTo		LEA fadeto_vars(pc),a5
		MOVE.L A0,fadeto_curptr(a5)
		MOVE.L A1,fadeto_palptr(a5)
		MOVE.W #32,fadeto_nocols(a5)
		MOVE.W #16,fadeto_cnt(a5)
		MOVE.B #3,fadeto_tim(a5)
		MOVE.B #3,fadeto_spd(a5)
		ST.B fadetoflag(a5)
.notfaded	TST.B fadetoflag(a5)
		BNE.S .notfaded
		RTS

; Nice 'n' flexible rout to fade from one palette to another.
; A5 -> fade variables structure as below :-

		rsreset
fadeto_curptr	rs.l 1			; current palette(from -> dest)
fadeto_palptr	rs.l 1			; destination palette
fadeto_nocols	rs.w 1			; no of colours in palette
fadeto_cnt	rs.w 1			; count until fade is done.
fadeto_tim	rs.b 1			; vbl count
fadeto_spd	rs.b 1			; vbl fade delay speed
fadetoflag:	rs.b 1			; fade flag(true if fading)
fadeto_varsize	rs.b 1			; structure size

Fade_to		lea fadeto_vars(pc),a5
		tst.b fadetoflag(a5)	; fading ?
		beq .nofadeto	
		subq.b #1,fadeto_tim(a5) ; vbl count-1
		bgt .nofadeto
		move.b fadeto_spd(a5),fadeto_tim(a5)   ; reset speed (vbl count)
		subq #1,fadeto_cnt(a5)	; faded -> totally?
		bne.s .okstillfade
		sf.b fadetoflag(a5)	; yes signal fade done.
		move #8,fadeto_cnt(a5)  ; and reset for next fade. 
.okstillfade	move.l fadeto_curptr(a5),a0 	; pal to fade FROM
		move.l fadeto_palptr(a5),a1	; ptr to pal to fade TO.
		move.l #$f00,d4	; R mask
		move.l #$0f0,d5	; G mask
		move.l #$00f,d6	; B mask
		move.w fadeto_nocols(a5),d7
		subq #1,d7
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

fadeto_vars:	ds.b fadeto_varsize
		even

;-------------------------------------------------------------------------

;
; The title screen.
;

titlescreen:	BSR wait_vbl
		SF star_flag
		BSR wait_vbl
		MOVEQ #3,D0
		MOVEQ #0,D1
		JSR rotfile+12+28
cont_title	BSR wait_vbl
		BSR init_stars
		BSR init_2screens
		LEA logo,A0 
		MOVE.L phy_base(PC),A1 
		LEA 320+(16*7)(A1),A1 
		MOVEQ #64-1,D7 
.lp		
		REPT 8
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		ADDQ.L #8,A1
		ENDR
		LEA 320-(8*16)(A1),A1 
		DBF D7,.lp 


		LEA titletext1(PC),A6
		BSR Print_Text
		BSR print_seltext
		BSR wait_vbl
		BSR wait_vbl
		ST star_flag
		BSR wait_vbl
.GO		LEA currpal(PC),A0
		LEA titlepal(PC),A1
		BSR FadeTo	
		CLR.B joy2
		MOVE.W #600,waitcount
.wait		BSR wait_vbl
		BTST.B #1,joy2
		BEQ.S .notdown 
		MOVE.W #600,waitcount
		MOVE.W #2,selected_game
.notdown	BTST.B #0,joy2
		BEQ.S .notup
		MOVE.W #700,waitcount
		MOVE.W #1,selected_game
.notup		BSR print_seltext
		BTST.B #7,joy2
		BNE.S .gamego
		SUBQ #1,waitcount
		BLE.S showhighs
		BRA.S .wait
.gamego		CLR.B joy2
		BSR fademusicdown
		LEA currpal(PC),A0
		LEA blank_pal(PC),A1
		BSR FadeTo	
		CLR.B key
		BSR wait_vbl
		SF star_flag
		BSR wait_vbl
		RTS

; Show highscore table.

showhighs	BSR wait_vbl
		LEA currpal(PC),A0
		LEA blank_pal(PC),A1
		BSR FadeTo	
		CLR.B key
		BSR wait_vbl
		SF star_flag
		BSR wait_vbl
		BSR init_stars
		BSR init_2screens
		BSR printhighscores	
		BSR wait_vbl
		ST star_flag
		BSR wait_vbl
		LEA currpal(PC),A0
		LEA highscre_pal(PC),A1
		BSR FadeTo	
		MOVE.W #500,waitcount
.wait1		BSR wait_vbl
		BTST.B #7,joy2
		BNE.S .outshowh
		SUBQ #1,waitcount
		BNE.S .wait1
.outshowh	LEA currpal(PC),A0
		LEA blank_pal(PC),A1
		BSR FadeTo	
		BSR wait_vbl
		CLR.B joy2
		BSR wait_vbl
		SF star_flag
		BSR wait_vbl
		BRA.W cont_title

waitcount	DC.W 0

print_seltext	LEA sel_text1(PC),A6
		CMP.W #1,selected_game
		BEQ.S .ok
		LEA sel_text2(PC),A6
.ok		BRA Print_text

selected_game	DC.W 1

;
; Main Game routines.
;


; Play that game!

Play_Game	BSR wait_vbl
		LEA main_screenpic+64,A0 
		BSR copypic_toboth 

		BSR Init_gamevars
		BSR wait_vbl
.startgamemus	
		LEA game_vars(PC),A6
		MOVE.W game_type(A6),D0
		EXT.L D0
		MOVEQ #0,D1
		JSR rotfile+12+28
		BSR wait_vbl
		LEA currpal(PC),A0 
		LEA main_screenpic,A1 
		BSR TrigFadeTo	 


.main_vbl_lp	BSR SwapScreens
		IFNE timing
		MOVE.L #$F0,$FFFF9800.W
		ENDC
		BSR wait_vbl
		LEA game_vars(PC),A6
		TST.B play_flag(A6)
		BEQ.S .updating 
		BSR checkifgameover
		TST.B gameover_flag(A6)
		BNE.S .out
		LEA gamegrid,A0		; copy current grid
		LEA gamegridD,A1	; to a work grid
		BSR copy_gamegrid	;
		BSR letusermove		; user control
		BSR Drawincurrcolumn	; draw in current column
		BSR makecolfall		; make column fall
.updating	BSR update_grid 
		BSR DrawGrid
		BSR DrawNextColUp	; update next column up thingy.
		BSR DrawGameStatus	; and draw score/level/blocks.
		BRA.S .main_vbl_lp	
.out		BSR fademusicdown	
		MOVEQ #25,D7
		BSR WaitD7Vbls
		LEA currpal(PC),A0
		LEA blank_pal(PC),A1
		BSR FadeTo	
		BSR wait_vbl
		CLR.B joy2
		CLR.B key
		BRA wait_vbl

; Graphics routs.

; Rout to draw score/level/no. of blocks.
; what a piece of crap.

DrawGameStatus	
		BSR DrawGameScore
		BSR DrawGameLevel
		BSR DrawGameBlocks
		RTS

; Draw game "score" in status panel

DrawGameScore	MOVE.W score(A6),D7
		EXT.L D7
		DIVU #10000,D7
		MOVEQ #48,D0
		MOVEQ #97,D1
		BSR draw_a_numb
		SWAP D7
		EXT.L D7
		DIVU #1000,D7
		MOVEQ #56,D0
		MOVEQ #97,D1
		BSR draw_a_numb
		SWAP D7
		EXT.L D7
		DIVU #100,D7
		MOVEQ #64,D0
		MOVEQ #97,D1
		BSR draw_a_numb
		SWAP D7
		EXT.L D7
		DIVU #10,D7
		MOVEQ #72,D0
		MOVEQ #97,D1
		BSR draw_a_numb
		SWAP D7
		MOVEQ #80,D0
		MOVEQ #97,D1
		BSR draw_a_numb
		RTS

; Draw game "level" in status panel

DrawGameLevel	MOVE.W level(A6),D7
		EXT.L D7
		DIVU #10,D7
		MOVEQ #60+1,D0
		MOVEQ #127,D1
		BSR draw_a_numb
		SWAP D7
		EXT.L D7
		MOVEQ #68+1,D0
		MOVEQ #127,D1
		BSR draw_a_numb
		RTS

; Draw no. of "blocks" in status panel

DrawGameBlocks	MOVE.W blocks(A6),D7
		EXT.L D7
		DIVU #100,D7
		MOVEQ #56+2,D0
		MOVE #155,D1
		BSR draw_a_numb
		SWAP D7
		EXT.L D7
		DIVU #10,D7
		MOVEQ #64+2,D0
		MOVE #155,D1
		BSR draw_a_numb
		SWAP D7
		MOVEQ #72+2,D0
		MOVE #155,D1
		BSR draw_a_numb
		RTS

; Draw a number D0 = X D1 = Y D7 = no.

draw_a_numb	LEA numbs_buf,A0
		MOVE.W D7,D6
		MULU #9*28*16,D6
		MOVE.L log_base(PC),A1
		MOVEQ #15,D2
		AND.W D0,D2
		SUB.W D2,D0
		EXT.L D0
		MULU #linewid,D1
		ADD.L D0,D1
		ADD.L D1,A1		; a1-> screen
		MULU #9*28,D2
		ADD.L D6,A0		; a0-> sprite
		ADD.L D2,A0		
		MOVEQ #9-1,D6
.lp		MOVEM.W (A1),D0-D4
		MOVE.L (A0)+,D5
		AND.W D5,D0
		AND.W D5,D1
		AND.W D5,D2
		AND.W D5,D3
		AND.W D5,D4
		OR.W (A0)+,D0
		OR.W (A0)+,D1
		OR.W (A0)+,D2
		OR.W (A0)+,D3
		OR.W (A0)+,D4
		MOVEM.W D0-D4,(A1)
		MOVEM.W 16(A1),D0-D4
		MOVE.L (A0)+,D5
		AND.W D5,D0
		AND.W D5,D1
		AND.W D5,D2
		AND.W D5,D3
		AND.W D5,D4
		OR.W (A0)+,D0
		OR.W (A0)+,D1
		OR.W (A0)+,D2
		OR.W (A0)+,D3
		OR.W (A0)+,D4
		MOVEM.W D0-D4,16(A1)
		LEA linewid(A1),A1
		DBF D6,.lp
		RTS

; Draws next column up into its little slot 
 
DrawNextColUp	LEA main_screenpic+64,A3 
		MOVE.L log_base(PC),A4 
		LEA (13*200)+8(A3),A3 
		LEA (13*linewid)+(4*16)(A4),A4 
		LEA next_column(A6),A5 
		REPT 3 
		MOVEQ #0,D3 
		MOVE.W (A5)+,D4 
		BSR draw_sprite 
		LEA (16*200)(A3),A3 
		LEA (16*linewid)(A4),A4 
		ENDR 
		RTS 

; Draw the main grid. 
 
DrawGrid	LEA main_screenpic+64,A3 
		MOVE.L log_base(PC),A4 
		LEA (8*200)+(7*2)(A3),A3 
		LEA (8*linewid)+(7*16)(A4),A4 
		LEA fade_grid+(24*3)+6(PC),A2 
		LEA gamegridD+(24*3)+6(PC),A5 
		REPT 6 
		MOVE.W (A2)+,D3 
		MOVE.W (A5)+,D4 
		BSR draw_sprite 
		ADDQ.L #2,A3 
		ADD.L #16,A4 
		MOVE.W (A2)+,D3 
		MOVE.W (A5)+,D4 
		BSR draw_sprite 
		ADDQ.L #2,A3 
		ADD.L #16,A4 
		MOVE.W (A2)+,D3 
		MOVE.W (A5)+,D4 
		BSR draw_sprite 
		ADDQ.L #2,A3 
		ADD.L #16,A4 
		MOVE.W (A2)+,D3 
		MOVE.W (A5)+,D4 
		BSR draw_sprite 
		ADDQ.L #2,A3 
		ADD.L #16,A4 
		MOVE.W (A2)+,D3 
		MOVE.W (A5)+,D4 
		BSR draw_sprite 
		ADDQ.L #2,A3 
		ADD.L #16,A4 
		MOVE.W (A2)+,D3 
		MOVE.W (A5)+,D4 
		BSR draw_sprite 
		LEA (16*200)-(5*2)(A3),A3 
		LEA (16*linewid)-(5*16)(A4),A4 
		LEA 12(A2),A2 
		LEA 12(A5),A5 
		ENDR 
 
		LEA 200(A3),A3 
		LEA linewid(A4),A4 
		REPT 6 
		MOVE.W (A2)+,D3 
		MOVE.W (A5)+,D4 
		BSR draw_sprite 
		ADDQ.L #2,A3 
		ADD.L #16,A4 
		MOVE.W (A2)+,D3 
		MOVE.W (A5)+,D4 
		BSR draw_sprite 
		ADD.L #2,A3 
		ADD.L #16,A4 
		MOVE.W (A2)+,D3 
		MOVE.W (A5)+,D4 
		BSR draw_sprite 
		ADDQ.L #2,A3 
		ADD.L #16,A4 
		MOVE.W (A2)+,D3 
		MOVE.W (A5)+,D4 
		BSR draw_sprite 
		ADDQ.L #2,A3 
		ADD.L #16,A4 
		MOVE.W (A2)+,D3 
		MOVE.W (A5)+,D4 
		BSR draw_sprite 
		ADDQ.L #2,A3 
		ADD.L #16,A4 
		MOVE.W (A2)+,D3 
		MOVE.W (A5)+,D4 
		BSR draw_sprite 
		LEA (16*200)-(5*2)(A3),A3 
		LEA (16*linewid)-(5*16)(A4),A4 
		LEA 12(A2),A2 
		LEA 12(A5),A5 
		ENDR 
 
		RTS 
 
; Draw sprite. (GIGGLE GIGGLE)...... 
; D3 = mask no. D4 = sprite no. 
		 
draw_sprite	LEA shifted_sprites,A0 
		LEA spr_tab(PC),A1 
		ADD.W (A1,D4*2),A0 
		LEA fademasks(PC),A1 
		LSL #5,D3 
		ADD.W D3,A1 
i		SET 0 
j		SET 0 
		REPT 16 
		MOVE.W j(A3),D0 
		MOVE.W j+40(A3),D1
		MOVE.W j+80(A3),D2 
		MOVE.W j+120(A3),D3
		MOVE.W j+160(A3),D4
		MOVE.W (A0)+,D5 
		MOVE.W (A1)+,D7 
		OR.W D7,D5 
		NOT.W D7 
		AND.W D5,D0 
		AND.W D5,D1 
		AND.W D5,D2 
		AND.W D5,D3 
		AND.W D5,D4 
		MOVEM.W (A0)+,D5/D6 
		AND.W D7,D5
		OR.W D5,D0 
		AND.W D7,D6 
		OR.W D6,D1 
		MOVEM.W (A0)+,D5/D6 
		AND.W D7,D5 
		OR.W D5,D2 
		AND.W D7,D6 
		OR.W D6,D3 
		AND.W (A0)+,D7 
		OR.W D7,D4 
		MOVEM.W D0-D4,i(A4)	; 
i		SET i+linewid 
j		SET j+200
		ENDR 
		RTS 
 
i		SET 0 
spr_tab		
		REPT 12 
		DC.W i*16*12 
i		SET i+1 
		ENDR 

; A set of 16 masks to "de-materialise" blocks.
fademasks	
		DC.W %0000000000000000
		DC.W %0000000000000000
		DC.W %0000000000000000
		DC.W %0000000000000000
		DC.W %0000000000000000
		DC.W %0000000000000000
		DC.W %0000000000000000
		DC.W %0000000000000000
		DC.W %0000000000000000
		DC.W %0000000000000000
		DC.W %0000000000000000
		DC.W %0000000000000000
		DC.W %0000000000000000
		DC.W %0000000000000000
		DC.W %0000000000000000
		DC.W %0000000000000000

		DC.W %0000100001000000
		DC.W %0000001000000100
		DC.W %0010000000000010
		DC.W %0001000010000000
		DC.W %0000100001000000
		DC.W %0000000010000100
		DC.W %1000010000000000
		DC.W %0000000000100010
		DC.W %0001001000000000
		DC.W %0000000010100000
		DC.W %0001000000010000
		DC.W %0000001000001000
		DC.W %0000100001000000
		DC.W %0010000000000100
		DC.W %0000001000000010
		DC.W %0010000000100000

		DC.W %0100100101000000
		DC.W %0010001000100100
		DC.W %0010001010000010
		DC.W %0001001010001000
		DC.W %1000100001001000
		DC.W %0010100010000100
		DC.W %1001010000010000
		DC.W %0001000100100010
		DC.W %0001001000010010
		DC.W %0100100010100000
		DC.W %0001001001010000
		DC.W %0100001000001010
		DC.W %0000100001001001
		DC.W %0010010000010100
		DC.W %0001000010100010
		DC.W %0010101000100000

		DC.W %0100100101001010
		DC.W %0010101010100100
		DC.W %0010001010100110
		DC.W %1001001010001001
		DC.W %1000101001001010
		DC.W %1010100010100100
		DC.W %1001010010010010
		DC.W %1001000100101010
		DC.W %0101001001010010
		DC.W %0101100010101000
		DC.W %0101001001010100
		DC.W %0101001001001010
		DC.W %0010100101001001
		DC.W %0011010010010100
		DC.W %0101010010100010
		DC.W %0010101010100100

		DC.W %0110100101101010
		DC.W %1010101010110100
		DC.W %0110101010100110
		DC.W %1001011010101001
		DC.W %1100101001101010
		DC.W %1010101010100110
		DC.W %1001010110010110
		DC.W %1001100110101010
		DC.W %0101101011010010
		DC.W %0101101010101100
		DC.W %0101001101010110
		DC.W %0101101011001010
		DC.W %0010110101101001
		DC.W %0011011010011100
		DC.W %0101010110101010
		DC.W %1010101010101100

		DC.W %1110110101101010
		DC.W %1010101111110100
		DC.W %0110101110101110
		DC.W %1001111010111001
		DC.W %1100111011101010
		DC.W %1010101010110111
		DC.W %1101010111010110
		DC.W %1101110110101010
		DC.W %1101101011011010
		DC.W %0111101010101101
		DC.W %1101001111010110
		DC.W %0101111011011010
		DC.W %0011110101111001
		DC.W %0111011110011100
		DC.W %0101011110101110
		DC.W %1010101110101101

		DC.W %1110111101111010
		DC.W %1011101111110110
		DC.W %1110101111101110
		DC.W %1011111011111001
		DC.W %1110111011111010
		DC.W %1011101010111111
		DC.W %1111010111110110
		DC.W %1101111110111010
		DC.W %1101111011111010
		DC.W %0111111010111101
		DC.W %1111001111011110
		DC.W %0101111111011110
		DC.W %1011110111111001
		DC.W %1111011110011101
		DC.W %0111011110101111
		DC.W %1110101111101101

		DC.W %1110111111111011
		DC.W %1111101111111110
		DC.W %1111101111101111
		DC.W %1111111111111001
		DC.W %1110111111111110
		DC.W %1011101111111111
		DC.W %1111011111111110
		DC.W %1101111111111110
		DC.W %1101111011111111
		DC.W %1111111110111101
		DC.W %1111101111011111
		DC.W %0111111111111110
		DC.W %1111110111111101
		DC.W %1111011111011111
		DC.W %1111011111101111
		DC.W %1111101111101111

		DC.W %1111111111111111
		DC.W %1111111111111111
		DC.W %1111111111111111
		DC.W %1111111111111111
		DC.W %1111111111111111
		DC.W %1111111111111111
		DC.W %1111111111111111
		DC.W %1111111111111111
		DC.W %1111111111111111
		DC.W %1111111111111111
		DC.W %1111111111111111
		DC.W %1111111111111111
		DC.W %1111111111111111
		DC.W %1111111111111111
		DC.W %1111111111111111
		DC.W %1111111111111111

; Print centred text. A6-> TEXT.

Print_text	MOVE.L phy_base(PC),A2
		MOVE.W (A6)+,D1
		MULU #320,D1
		ADDA.L D1,A2 
.row_lp		MOVE.L A6,A1
		MOVEQ #0,D0
.fnd_length	MOVE.B (A1)+,D1
		BEQ.S .found_rowend
		CMP.B #1,D1
		BEQ.S .found_rowend
		EXT.W D1
		ADD.W D1,D1
		ADDQ.W #8,D0
		BRA.S .fnd_length
.found_rowend	LSR #1,D0
		NEG D0
		ADD.W #160,D0
.do1line	MOVE.B (A6)+,D1
		BEQ .row_done
		CMP.B #1,D1
		BEQ .text_done 
		MOVE D0,D2
		AND #15,D2
		LEA font_buf(PC),A0
		EXT.W D1
		SUB.B #32,D1
		LSL.W #3,D1
		ADD.W D1,A0
		MOVE D0,D3
		AND #$FFF0,D3
		MOVE.L A2,A1
		ADD.W D3,A1
		TST.W D1
		BEQ .is_space
i		SET 6
		REPT 8
		MOVEQ #0,D1
		MOVE.B (A0)+,D1
		ROR.L D2,D1
		OR.W D1,i(A1)
		SWAP D1
		OR.W D1,i+16(A1)
i		SET i+320
		ENDR
		ADDQ #8,D0
		BRA .do1line
.is_space	MOVE.L #$FF,D1
		ROR.L D2,D1
		NOT.L D1
i		SET 6
		REPT 8
		AND.W D1,i(A1)
		SWAP D1
		AND.W D1,i+16(A1)
		SWAP D1
i		SET i+320
		ENDR
		ADDQ #8,D0
		BRA .do1line
.row_done	LEA 8*320(A2),A2
		BRA .row_lp
.text_done	RTS

font_buf	INCBIN GFX\MET_09.FN8

titletext1	DC.W 72
		DC.B " ",0
		DC.B "Coded by Martin Griffiths",0
		DC.B "Graphics by Andy Jones",0
		DC.B "Music by Yan and Dens Design",0
		DC.B " ",0
		DC.B " ",0
		DC.B "Select Game Type",0
		DC.B " ",0
		DC.B " ",0
		DC.B " ",0
		DC.B " ",0
		DC.B " ",0
		DC.B " ",0
		DC.B " ",0
		DC.B "An Electronic Images Production",0
		DC.B "Public Domain, Copy Freely",1
		EVEN

sel_text1	DC.W 144
		DC.B "> Game 1 : Childs Play!   ",0
		DC.B " ",0
		DC.B "  Game 2 : Heaven and Hell",1
		EVEN

sel_text2	DC.W 144
		DC.B "  Game 1 : Childs Play!   ",0
		DC.B " ",0
		DC.B "> Game 2 : Heaven and Hell",1
		EVEN

; Highscore routine.

dohighscores	BSR wait_vbl
		SF star_flag
		BSR wait_vbl
		BSR init_stars
		BSR init_2screens
		LEA game_vars(PC),A6
		MOVE.W score(A6),D0
		BSR is_scorehigh
		TST.B D1
		BEQ .nohighscore
		MOVE.L A0,score_ptr
		MOVE.B D1,high_flag
		MOVE.B D3,high_pos
		LEA gothigh_text(PC),A6
		BSR Print_text
		BSR printhighscores	
		BSR wait_vbl
		ST star_flag
		BSR wait_vbl
		MOVEQ #4,D0
		MOVEQ #0,D1
		JSR rotfile+12+28
		BSR wait_vbl
		LEA currpal(PC),A0
		LEA highscre_pal(PC),A1
		BSR FadeTo	
		CLR.B key
		CLR.W scorein_ptr

.inputname	BSR wait_vbl
		MOVE.W #600-1,D0
.dlp		DBF D0,.dlp
		MOVE.B key(PC),D0
		AND.W #$FF,D0
		CMP.B #$1C,D0
		BEQ .input_done
		MOVE.W scorein_ptr(PC),D1
		MOVE.L score_ptr(PC),A5
		CMP.B #$0E,D0
		BNE.S .notbackspc
		TST.W D1
		BEQ.S .notbackspc
		SUBQ #1,D1
		MOVE.B #'.',(A5,D1.W)
		BRA.S .cont_inp
.notbackspc	CMP.W #14,D1
		BEQ.S .no_inp
		LEA ascii_table(PC),A4
		MOVE.B (A4,D0),D0
		BEQ.S .no_inp
		MOVE.B D0,(A5,D1)
		ADDQ #1,D1
.cont_inp	MOVE.W D1,scorein_ptr
		MOVEQ #0,D4
		MOVE.B high_pos(PC),D4
		MOVE.L D4,D5
		MULU #12,D5
		ADD.W #36-12,D5
		MOVE.W D5,D0
		BSR clear_line
		BSR print1score
.no_inp		CLR.B key
		BRA .inputname
.input_done	BSR wait_vbl
		MOVE.W #191,D0
		BSR clear_line
		CLR.B key
.wait		BTST.B #7,joy2
		BEQ.S .wait		
		BSR fademusicdown	
		LEA currpal(PC),A0
		LEA blank_pal(PC),A1
		BSR FadeTo	
		BSR wait_vbl
		CLR.B key
		CLR.B joy2
		RTS

.nohighscore	BSR printhighscores	
		LEA failhigh_text(PC),A6
		BSR Print_text
		BSR wait_vbl
		ST star_flag
		BSR wait_vbl
		MOVEQ #4,D0
		MOVEQ #0,D1
		JSR rotfile+12+28
		BSR wait_vbl
		LEA currpal(PC),A0
		LEA highscre_pal(PC),A1
		BSR FadeTo	
.wait1		BTST.B #7,joy2
		BEQ.S .wait1
		BSR fademusicdown	
		LEA currpal(PC),A0
		LEA blank_pal(PC),A1
		BSR FadeTo	
		BSR wait_vbl
		CLR.B joy2
		RTS

high_flag	DC.B 0
high_pos	DC.B 0
score_ptr	DC.L 0
scorein_ptr	DC.W 0

clear_line	MULU #linewid,D0
.clrsc		MOVE.L phy_base(PC),A4
		LEA (5*16)+6(A4,D0.L),A4
		MOVEQ #0,D1
		MOVEQ #8-1,D2
.lp
i		SET 0
		REPT 11
		MOVE.W D1,i(A4)
i		SET i+16
		ENDR
		LEA linewid(A4),A4
		DBF D2,.lp
		RTS

ascii_table	DC.B	0,0,'1234567890-=',0,0,'QWERTYUIOP[]',13,0,'ASDFGHJKL-','`','`',0
		DC.B	'#ZXCVBNM,./',0,0,0,' ',0
		DC.B	0,0,0,0,0,0,0,0,0,0		'Function keys.
		DC.B	0,0,0,0,0,'-',0,0,0,'+',0,0
		DC.B	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		DC.B	0,0,'()/*7894561230.',13
		DC.B	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		DS.B 130
		EVEN

; Print up the highscore table.

printhighscores	LEA highscores(PC),A6
		BSR Print_text
		LEA high_tab(PC),A5
		MOVEQ #1,D4
		MOVEQ #36,D5
		MOVEQ #12-1,D6
.lp		BSR print1score
		ADDQ #1,D4
		ADD #12,D5
		DBF D6,.lp
		RTS

; Print a score
; a5 -> score 14 character, 1 word score.
; d4 = score no. d5 -> y position to print at. 

print1score	LEA formatscore(PC),A6
		MOVE.W D5,(A6)+
		MOVE.W #$2020,(A6)+
		MOVE.L D4,D3
		DIVU #10,D3
		ADD.B #'0',D3
		MOVE.B D3,(A6)+
		SWAP D3
		ADD.B #'0',D3
		MOVE.B D3,(A6)+
		MOVE.B #' ',(A6)+
		REPT 14
		MOVE.B (A5)+,(A6)+
		ENDR
		MOVE.B #' ',(A6)+
		MOVE.W (A5)+,D0
		EXT.L D0
		DIVU #10000,D0
		ADD.B #'0',D0
		MOVE.B D0,(A6)+
		SWAP D0
		EXT.L D0
		DIVU #1000,D0
		ADD.B #'0',D0
		MOVE.B D0,(A6)+
		SWAP D0
		EXT.L D0
		DIVU #100,D0
		ADD.B #'0',D0
		MOVE.B D0,(A6)+
		SWAP D0
		EXT.L D0
		DIVU #10,D0
		ADD.B #'0',D0
		MOVE.B D0,(A6)+
		SWAP D0
		ADD.B #'0',D0
		MOVE.B D0,(A6)+
		MOVE.B #' ',(A6)+
		MOVE.B #' ',(A6)+
		MOVE.B #1,(A6)+
		LEA formatscore(PC),A6
		BRA Print_text
		
formatscore	DS.B 34

; Does the score get into the highscore table?
; D0 = score

is_scorehigh	LEA high_tab(PC),A0
		ST D1			; assume is in highscore table.
		MOVEQ #12-1,D2
.lp		CMP.W 14(A0),D0
		BGE.S .foundit
		LEA 16(A0),A0
		DBF D2,.lp		
		SF D1			; signal not got a highscore
		RTS
; ok... tis in highscore table.... a0-> place in table.
.foundit	MOVEQ #12,D3
		SUB.W D2,D3		; highscore number
		SUBQ #1,D2
		BMI.S .atbottom
		LEA high_tab+(10*16)(PC),A1
		LEA high_tab+(11*16)(PC),A2
.shift_lp	
		REPT 4
		MOVE.L (A1)+,(A2)+
		ENDR
		LEA -32(A1),A1
		LEA -32(A2),A2
		DBF D2,.shift_lp
.atbottom	MOVE.L A0,A1
		REPT 14
		MOVE.B #".",(A1)+	; nul name
		ENDR
		MOVE.W D0,(A1)+		; place score in table.
		RTS

highscores	DC.W 12	
		DC.B "HALL OF FAME",1
		EVEN

gothigh_text	DC.W 191
		DC.B "ENTER YOUR NAME",1 
		EVEN
failhigh_text	DC.W 191
		DC.B "YOU DIDN'T MAKE IT!",1 
		EVEN

high_tab	DC.B "MARTIN........"
		DC.W 12000
		DC.B "E.I..........."
		DC.W 11000
		DC.B "DAVE.........."
		DC.W 10000
		DC.B "YAN..........."
		DC.W 9000
		DC.B "KOTSKA........"
		DC.W 8000
		DC.B "DEBBIE........"
		DC.W 7000
		DC.B "JAMIE........."
		DC.W 6000
		DC.B "WAYNE........."
		DC.W 5000
		DC.B "WILL.........."
		DC.W 4000
		DC.B "GEORGE........"
		DC.W 3000
		DC.B "LYNDON........"
		DC.W 2000
		DC.B "JOHN.........."
		DC.W 1000

;-------------------------------------------------------------------------

; Logic routines.

Init_gamevars	LEA game_vars(PC),A6
		MOVE.W selected_game(PC),game_type(A6)
		MOVE.W vbl_timer(PC),D0	; get timer
		MULU #56791,D0		; to use as random seed.
		ADD.L #712345679,D0	; add a constant(!!)
		MOVE.L D0,rndseed	; and we have a random seed!
		CLR.W score(A6)
		MOVE.W #1,level(A6)
		CLR.W blocks(A6)
		CLR.W blocksthislevel(A6)
		BSR gen_randomcolmn
		MOVEM.W D0-D2,this_column(A6)
		BSR gen_randomcolmn
		MOVEM.W D0-D2,next_column(A6)
		MOVE.W #2*2,curr_x(A6)
		MOVE.W #-3,curr_y(A6)
		ST.B play_flag(A6)
		SF.B update_flag(A6)
		SF.B gameover_flag(A6)
		SF.B fading_flag(A6)
		SF.B shuffling_flag(A6)
		SF.B falling_flag(A6)
		CLR.W fade_cnt(A6)
		BSR controlgamespeed
		LEA blankgrid(PC),A0		
		LEA gamegrid(PC),A1		
		BSR copy_gamegrid 		
		LEA blankgrid(PC),A0		
		LEA gamegridD(PC),A1		
		BSR copy_gamegrid 		
		LEA blankgrid(PC),A0		
		LEA delete_grid(PC),A1		
		BSR copy_gamegrid 		
		LEA blankgrid(PC),A0		
		LEA fade_grid(PC),A1		
		BSR copy_gamegrid 		

		RTS

; Game level\speed control - based on number of blocks got.

controlgamespeed
		LEA game1speedcont(PC),A0
		CMP.W #2,game_type(A6)
		BNE.S .tis1
		LEA game2speedcont(PC),A0
.tis1		MOVE.W level(A6),D0		; get current level
		MOVE.W blocksthislevel(A6),D1	; and blocks got so
		SUBQ #1,D0			; level-1
		ADD.W D0,D0 		
		ADD.W D0,D0 			;*4
		CMP.W (A0,D0.W),D1		; got enough blocks?
		BLT.S .notnextlevel		; (to advance level)
		SUB.W (A0,D0.W),D1
		MOVE.W D1,blocksthislevel(A6)
		CMP.W #10,level(A6)		; level 10=max
		BEQ.S .notnextlevel		; yup?
		ADDQ #1,level(A6)		; otherwise inc level
.notnextlevel	MOVE.W level(A6),D0		; get level
		SUBQ #1,D0			; level-1
		ADD.W D0,D0 		
		ADD.W D0,D0 			;*4
		MOVE.W 2(A0,D0.W),game_speed(A6) ; game speed based on level

		MOVE.W game_speed(A6),game_timr(A6) ; reset timer
		RTS

; Game speedup table. in the form:
; no. of blocks you need to get to move up a level. (WORD)
; the game speed (vbl count) for this level. (WORD)

game1speedcont	DC.W 30,8
		DC.W 30,7
		DC.W 40,6
		DC.W 50,5
		DC.W 60,4
		DC.W 80,3
		DC.W 120,2
		DC.W 160,1
		DC.W 300,1
		DC.W 500,0
		DC.W 500,0

game2speedcont	DC.W 15,8
		DC.W 20,7
		DC.W 25,6
		DC.W 30,5
		DC.W 50,4
		DC.W 70,3
		DC.W 100,2
		DC.W 150,1 ; aim is to get 450 blocks.
		DC.W 250,0
		DC.W 250,0
		DC.W 250,0

; User control bit

letusermove	TST.B falling_flag(A6)
		BNE .nomoves
		LEA gamegridD+(24*3)+6(PC),A5
		MOVE.W curr_x(A6),D1
		MOVE.W curr_y(A6),D2
		MULU #24,D2
		ADD.W D2,A5
		ADD.W D1,A5 
.checkright	BTST.B #3,joy2		; right?
		BEQ.S .noright		; no then dont move right
		BTST.B #3,lastjoy2	; ok... move right
		BEQ.S .okmoveright
		SUBQ #1,right_rept
		BNE.S .noright
.okmoveright	MOVE.W #2,right_rept
		CMP.W #10,curr_x(A6)	; at right edge?
		BEQ.S .noright		; yup, then no move right
		TST.W 2(A5)
		BNE.S .noright		
		TST.W 2+24(A5)		; check there are no blocks
		BNE.S .noright		; to the right
		TST.W 2+48(A5)
		BNE.S .noright		
		ADDQ.W #2,curr_x(A6)
.noright	
.checkleft	BTST.B #2,joy2
		BEQ.S .noleft
		BTST.B #2,lastjoy2	; ok... move right
		BEQ.S .okmoveleft
		SUBQ #1,left_rept
		BNE.S .noleft
.okmoveleft	MOVE.W #2,left_rept

		CMP.W #0,curr_x(A6)	; at right edge?
		BEQ.S .noleft		; yup, then no move right
		TST.W -2(A5)
		BNE.S .noleft
		TST.W -2+24(A5)		; check there are no blocks
		BNE.S .noleft		; to the left.
		TST.W -2+48(A5)
		BNE.S .noleft
		SUBQ.W #2,curr_x(A6)
.noleft		
.checkdown	BTST.B #1,lastjoy2	; down is held down?
		BNE.S .notdown		; yup then skip
		BTST.B #1,joy2
		BEQ.S .notdown		; down?
		ST.B falling_flag(A6)
.notdown	
.checkrotate	BTST.B #7,joy2
		BEQ.S .notrotate	; insert - i.e rotate block
		BTST.B #7,lastjoy2	; ok... move right
		BEQ.S .okrot
		SUBQ #1,rot_rept
		BNE.S .notrotate
.okrot		MOVE.W #4,rot_rept
		MOVEM.W this_column(A6),D1-D3
		MOVE.W D3,this_column(A6)
		MOVE.W D1,this_column+2(A6)
		MOVE.W D2,this_column+4(A6)
.notrotate
.nomoves	MOVE.B key(PC),lastkey
		MOVE.B joy2(PC),lastjoy2
		CLR.B key
		CLR.B joy2
		RTS
lastjoy2	DC.B 0
lastkey		DC.B 0
right_rept	DC.W 2
left_rept	DC.W 2
rot_rept	DC.W 4

; Draws in current column into grid.

Drawincurrcolumn
		LEA gamegridD+(24*3)+6(PC),A5
		MOVE.W curr_x(A6),D1
		MOVE.W curr_y(A6),D2
		MULU #24,D2
		ADD.W D2,A5
		ADD.W D1,A5 
		MOVEM.W this_column(A6),D0-D2
		MOVE.W D0,(A5)
		MOVE.W D1,24(A5)
		MOVE.W D2,48(A5)
		RTS

; Make column fall.

makecolfall	TST.B falling_flag(A6)
		BNE.S .falling_quick
		SUBQ #1,game_timr(A6)		; fall speed
		BGE.S .out
		MOVE.W game_speed(A6),game_timr(A6)  ; reset speed
.falling_quick	LEA gamegridD+(24*3)+6(PC),A5
		MOVE.W curr_x(A6),D1
		MOVE.W curr_y(A6),D2
		CMP.W #9,D2
		BEQ.S .has_hit			; hit floor?
		MULU #24,D2
		ADD.W D2,A5
		ADD.W D1,A5
		TST.W 24*3(A5)			; hit layer beneath?
		BNE.S .has_hit 				 
		ADDQ #1,curr_y(A6)		; otherwise move down
.out		RTS
.has_hit	ST.B update_flag(A6)		; has hit so trigger update.
		SF.B falling_flag(A6)
		RTS

; When a columns hits the floor or a layer this comes into action.

update_grid	TST.B update_flag(A6)
		BEQ.S .noupdate
		SF.B play_flag(A6)
		TST.B fading_flag(A6)		; OK WE ARE UPDATING
		BNE.S dobitfade 		; FADING? NO THEN SKIP
		TST.B shuffling_flag(A6)	; SHUFFLING DOWN? NO...
		BNE doshuffle			; YUP... DO SHUFFLE
.notshuffling	BSR scan_grid			; 
		TST.B D1
		BEQ.S reset_update		; update has finished
		ST.B fading_flag(A6)		; no then continue.
		CLR.W fade_cnt(A6)
.noupdate	RTS

; An update has been finished - i.e column has been placed and no lines
; found or all rows/verticals etc have been deleted and the grid updated.
; so now setup vars for next falling column

reset_update	SF.B update_flag(A6)    ; update finished
		ST.B play_flag(A6)	; so continue with playing
		MOVE.W #2*2,curr_x(A6)  ; reset new block position
		MOVE.W #-3,curr_y(A6)   ;
		MOVEM.W next_column(A6),D0-D2
		MOVEM.W D0-D2,this_column(A6)
		BSR gen_randomcolmn
		MOVEM.W D0-D2,next_column(A6)
		BSR controlgamespeed

		LEA gamegridD(PC),A0	; copy updated grid
		LEA gamegrid(PC),A1		; to main grid
		BSR copy_gamegrid 	;
		RTS

; Fades out the blocks that are in a line
; (de-materialise them and then clear the blocks from the grid.)

dobitfade	MOVE.W fade_cnt(A6),D1
		CMP.W #8,D1
		BEQ.S .fadedone
		ADDQ #1,D1
		MOVE.W D1,fade_cnt(A6)
		LEA delete_grid+(3*24)+6(PC),A4
		LEA fade_grid+(3*24)+6(PC),A5
		MOVEQ #12-1,D2
.lp		MOVEQ #0,D0
.lp1		TST.W (A4,D0)
		BEQ.S .notthisone
		MOVE.W D1,(A5,D0)
.notthisone	ADDQ #2,D0
		CMP.W #14,D0
		BNE.S .lp1
		LEA 24(A4),A4
		LEA 24(A5),A5
		DBF D2,.lp
		RTS

; The blocks have been faded out, so delete the blocks from the grid.
; and set the shuffling flag.

.fadedone	LEA fade_grid+6(PC),A3
		LEA delete_grid+6(PC),A4
		LEA gamegridD+6(PC),A5
		MOVEQ #0,D4		; counter for number of blocks
		MOVEQ #15-1,D2
		MOVEQ #0,D3
.clp		MOVEQ #0,D0
.clp1		TST.W (A4,D0)
		BEQ.S .cnotthisone
		MOVE.W D3,(A3,D0)	; reset fade grid.
		MOVE.W D3,(A4,D0)	; delete "delete" marker
		MOVE.W D3,(A5,D0)	; delete block from grid.
		ADDQ #1,D4
.cnotthisone	ADDQ #2,D0
		CMP.W #14,D0
		BNE.S .clp1
		LEA 24(A3),A3
		LEA 24(A4),A4
		LEA 24(A5),A5
		DBF D2,.clp
		ADD.W D4,blocks(A6)	; add number of blocks to total
		ADD.W D4,blocksthislevel(A6)
		SF.B fading_flag(A6)
		ST.B shuffling_flag(A6)
		RTS

; Shuffles all blocks with nothing below them down 1.
; when NO shuffling is done when this is called shuffling is turned off.

shuffle		MACRO
		MOVE.W -(A4),D0		; get this line
		BNE.S .nodown\@
		TST.W -24(A4)		; check line above
		BEQ.S .nodown\@		; if its not empty
		MOVE.W -24(a4),(A4)	; then shuffle above to bottom
		CLR.W -24(A4)
		ST D2
.nodown\@
		ENDM

doshuffle	LEA gamegridD+(15*24)-6(PC),A4
		SF D2
		MOVEQ #15-1,D1
.lp		shuffle
		shuffle
		shuffle
		shuffle
		shuffle
		shuffle
		LEA -12(A4),A4
		SUBQ #1,D1
		BNE .lp
		MOVE.B D2,shuffling_flag(A6)
		RTS

; Scans grid and builds a flag grid for blocks to delete.
; return d1 true or false if any lines were found.

scan_grid	LEA gamegridD+6(PC),A5
		LEA delete_grid+6(PC),A4
		MOVEQ #15-1,D7	; scan top 3 and main 12.
		SF D1
		MOVEQ #2,D2
.row_lp		
		REPT 6
		BSR checkit
		LEA 2(A4),A4
		LEA 2(A5),A5
		ENDR
		LEA 12(A4),A4
		LEA 12(A5),A5
		DBF D7,.row_lp		
		RTS

; Check for the 4 ways of get a row.
; vertical   : |
; horizontal : -
; diagonal1  : /
; diagonal2  : \

checkit 	MOVE.W (A5),D0		; fetch block
		CMP.W D2,D0	 	; 0,1,2 are not "coloured" blocks
		BLE .out

.checkhorz1	CMP.W 2(A5),D0
		BNE.S .checkvert
		CMP.W 4(A5),D0
		BNE.S .checkvert
		MOVE.W #-1,(A4)
		MOVE.W #-1,2(A4)
		MOVE.W #-1,4(A4)
		ADD.W #10*10,score(A6)
		ST D1
		CMP.W 6(A5),D0
		BNE.S .checkvert
		MOVE.W #-1,6(A4)
		CMP.W 8(A5),D0
		BNE.S .checkvert
		MOVE.W #-1,8(A4)
		ADD.W #10*10,score(A6)
		CMP.W 10(A5),D0
		BNE.S .checkvert
		ADD.W #40*10,score(A6)
		MOVE.W #-1,10(A4)

.checkvert	CMP.W 24*1(A5),D0
		BNE.S .checkdiag1
		CMP.W 24*2(A5),D0
		BNE.S .checkdiag1
		MOVE.W #-1,(A4)
		MOVE.W #-1,24*1(A4)
		MOVE.W #-1,24*2(A4)
		ADD.W #10*10,score(A6)
		ST D1
		CMP.W 24*3(A5),D0
		BNE.S .checkdiag1
		MOVE.W #-1,24*3(A4)
		CMP.W 24*4(A5),D0
		BNE.S .checkdiag1
		MOVE.W #-1,24*4(A4)
		ADD.W #10*10,score(A6)
		CMP.W 24*5(A5),D0
		BNE.S .checkdiag1
		MOVE.W #-1,24*5(A4)
		ADD.W #40*10,score(A6)

.checkdiag1	CMP.W (24*1)-2(A5),D0
		BNE.S .checkdiag2
		CMP.W (24*2)-4(A5),D0
		BNE.S .checkdiag2
		MOVE.W #-1,(A4)
		MOVE.W #-1,(24*1)-2(A4)
		MOVE.W #-1,(24*2)-4(A4)
		ADD.W #20*10,score(A6)
		ST D1
		CMP.W (24*3)-6(A5),D0
		BNE.S .checkdiag2
		MOVE.W #-1,(24*3)-6(A4)
		CMP.W (24*4)-8(A5),D0
		BNE.S .checkdiag2
		MOVE.W #-1,(24*4)-8(A4)
		ADD.W #20*10,score(A6)
		CMP.W (24*5)-10(A5),D0
		BNE.S .checkdiag2
		MOVE.W #-1,(24*5)-10(A4)
		ADD.W #80*10,score(A6)

.checkdiag2	CMP.W (24*1)+2(A5),D0
		BNE.S .out
		CMP.W (24*2)+4(A5),D0
		BNE.S .out
		MOVE.W #-1,(A4)
		MOVE.W #-1,(24*1)+2(A4)
		MOVE.W #-1,(24*2)+4(A4)
		ADD.W #20*10,score(A6)
		ST D1
		CMP.W (24*3)+6(A5),D0
		BNE.S .out
		MOVE.W #-1,(24*3)+6(A4)
		CMP.W (24*4)+8(A5),D0
		BNE.S .out
		MOVE.W #-1,(24*4)+8(A4)
		ADD.W #20*10,score(A6)
		CMP.W (24*5)+10(A5),D0
		BNE.S .out
		MOVE.W #-1,(24*5)+10(A4)
		ADD.W #80*10,score(A6)

.out		RTS

; Check for game over.
; (happens when any blocks are left above the main screen after update).

checkifgameover	LEA gamegrid+6(PC),A0
		MOVEQ #0,D0
		REPT 3
		OR.L (A0)+,D0 
		OR.L (A0)+,D0 
		OR.L (A0)+,D0 
		LEA 12(A0),A0
		ENDR
		TST.L D0
		SNE gameover_flag(A6)
		RTS

; Copy a gamegrid from a0 -> a1

copy_gamegrid	MOVEQ #(12+6)-1,D7
.lp		MOVEM.L (A0)+,D0-D5
		MOVEM.L D0-D5,(A1)
		LEA 24(A1),A1
		DBF D7,.lp
		RTS

; Generate 3 random numbers d0/d1/d2 respectively
;

gen_randomcolmn	CMP.W #2,game_type(A6)
		BEQ.S game2rnd
game1rnd	BSR.S Rand
		MOVE.L D0,D1	
		BSR.S Rand	
		MOVE.L D0,D2	
		BSR.S Rand	
.rand1		CMP.W #800,D0
		BHS.S .ok1
		MOVEQ #1,D0
		BRA.S .rand2
.ok1		AND.W #3,D0		; 0-3
		ADDQ.W #7,D0		
.rand2		CMP.W #800,D1
		BHS.S .ok2
		MOVEQ #1,D1
		BRA.S .rand3
.ok2		AND.W #3,D1		; 0-3
		ADDQ.W #7,D1		
.rand3		CMP.W #800,D2
		BHS.S .ok3
		MOVEQ #1,D2
		BRA.S .rand4
.ok3		AND.W #3,D2		; 0-3
		ADDQ.W #7,D2		
.rand4		RTS

game2rnd	BSR.S Rand
		MOVE.L D0,D1	
		BSR.S Rand	
		MOVE.L D0,D2	
		BSR.S Rand	
.rand1		CMP.W #1600,D0
		BHS.S .ok1
		MOVEQ #2,D0
		BRA.S .rand2
.ok1		AND.W #3,D0		; 0-3
		ADDQ.W #3,D0		
.rand2		CMP.W #1600,D1
		BHS.S .ok2
		MOVEQ #2,D1
		BRA.S .rand3
.ok2		AND.W #3,D1		; 0-3
		ADDQ.W #3,D1		
.rand3		CMP.W #1600,D2
		BHS.S .ok3
		MOVEQ #2,D2
		BRA.S .rand4
.ok3		AND.W #3,D2		; 0-3
		ADDQ.W #3,D2		
.rand4		RTS

; Random number generator. Returns with number in D0.
; This is a tad slooow... it takes about 650 cycles.

Rand:           movem.l D1-D2,-(SP)
                move.l  rndseed(PC),D1
                move.l  #2147001325,D2
                bsr     mul             ; 32 bit multiply
                add.l   D6,D7
                move.l  D7,D0
                addi.l  #715136305,D0
                move.l  D0,rndseed
                swap    D0
                clr.w   D0
                swap    D0
                movem.l (SP)+,D1-D2
                rts

rndseed:        DC.L 712345679

; 32 bit multiply.  <540 cycles MAX.  Faster than the 'other' methods.
; Multiply D1 by D2; 64-bit result in D6 & D7.  D6 is MSL and D7 LSL.
; Returns with most significant in D6 and least significant in D7.

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
lmul2:          rts


; Game variables

		RSRESET
game_type	RS.W 1		; game type. (1 or 2)
this_column	RS.W 3		; this columns sprite nos(i.e colours)
next_column	RS.W 3		; next columns sprite nos(i.e colours)
score		RS.W 1		; current score
level		RS.W 1		; current level
blocks		RS.W 1		; current no. blocks
blocksthislevel	RS.W 1		; current no. of blocks got so far this level
curr_x		RS.W 1		; current columns x pos
curr_y		RS.W 1		; current columns y pos
play_flag	RS.B 1		; play flag - move column or not.
update_flag	RS.B 1		; update flag - when column is placed
				; we need to check for columns etc.
gameover_flag	RS.B 1		; game over flag
fading_flag	RS.B 1 		; blocks are fading flag
fade_cnt	RS.W 1		;
shuffling_flag	RS.B 1		;
falling_flag	RS.B 1		; falling flag - i.e down was pressed.
game_speed	RS.W 1		; game vbl speed before each down movement
game_timr	RS.W 1		; current vbl count of game speed

joy_tmr		RS.W 1		
gamevar_ssize	RS.B 0

game_vars	DS.B gamevar_ssize
		EVEN

blankgrid	DS.W 18*12

; Current game grid. (without current column drawn in)

gamegrid	DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ;
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ;
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ;
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ;
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ;
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ;

; Game grid to draw to screen

		DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ; HMMMM...
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ;
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ;

gamegridD	DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ;
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ;
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ;
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ;
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ;
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ;

		DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ; HMMM....
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ;
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ;

; Flag grid containing 0 if block is to stay.(i.e not be deleted).

delete_grid	DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ;
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ;
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ;
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ;
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ;
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ;

; Fade grid. contains bitfade table no. for each block.

fade_grid	DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ;
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ;
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ;
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ;
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ;
		DC.W 0,0,0,0,0,0,0,0,0,0,0,0 ;

; Preshift score font.

Preshift_numbs	LEA numbs_buf,A0
		LEA numb_font(PC),A2
		MOVEQ #10-1,D5
.spr_lp		MOVE.W D5,-(SP)
		MOVEQ #0,D6
.sh_lp		MOVE.L A2,A1
		MOVEQ #9-1,D7
.li_lp		MOVEQ #0,D0
		MOVEQ #0,D1
		MOVEQ #0,D2
		MOVEQ #0,D3
		MOVEQ #0,D4
		MOVEQ #-1,D5
		MOVE (A1),D0 
		MOVE 10*2*1(A1),D1 
		MOVE 10*2*2(A1),D2 
		MOVE 10*2*3(A1),D3 
		MOVE 10*2*4(A1),D4
		AND.W #$FF00,D0
		AND.W #$FF00,D1
		AND.W #$FF00,D2
		AND.W #$FF00,D3
		AND.W #$FF00,D4
		MOVE D0,D5
		OR D1,D5
		OR D2,D5
		OR D3,D5
		OR D4,D5
		NOT D5
		ROR.L D6,D0
		ROR.L D6,D1
		ROR.L D6,D2
		ROR.L D6,D3
		ROR.L D6,D4
		ROR.L D6,D5
		MOVE D5,(A0)+
		MOVE D5,(A0)+
		MOVE D0,(A0)+
		MOVE D1,(A0)+
		MOVE D2,(A0)+
		MOVE D3,(A0)+
		MOVE D4,(A0)+
		SWAP D0
		SWAP D1
		SWAP D2
		SWAP D3
		SWAP D4
		SWAP D5
		MOVE D5,(A0)+
		MOVE D5,(A0)+
		MOVE D0,(A0)+
		MOVE D1,(A0)+
		MOVE D2,(A0)+
		MOVE D3,(A0)+
		MOVE D4,(A0)+
		LEA 10*2*5(A1),A1
		DBF D7,.li_lp	
		ADDQ #1,D6
		CMP #16,D6
		BNE .sh_lp
		ADDQ.L #2,A2
		MOVE.W (SP)+,D5
		DBF D5,.spr_lp
		RTS

; Preshift game sprites (there are 11 in all). 
		 
prepare_sprites	LEA shifted_sprites,A0 
		LEA gamesprites,A2 
		MOVEQ #11-1,D6
.spr_lp		MOVEQ #16-1,D7 
.li_lp		MOVE (A2),D0 
		MOVE 11*2*1(A2),D1 
		MOVE 11*2*2(A2),D2 
		MOVE 11*2*3(A2),D3 
		MOVE 11*2*4(A2),D4
		MOVE D0,D5
		OR D1,D5 
		OR D2,D5 
		OR D3,D5 
		OR D4,D5 
		NOT D5
		MOVE D5,(A0)+ 
		MOVE D0,(A0)+ 
		MOVE D1,(A0)+ 
		MOVE D2,(A0)+ 
		MOVE D3,(A0)+ 
		MOVE D4,(A0)+ 
		LEA 11*2*5(A2),A2
		DBF D7,.li_lp	
		LEA -(11*2*5*16)+2(A2),A2
		DBF D6,.spr_lp 
		RTS 
 
; Prepare score font for blitter format. 
 
;Preshift_numbs	LEA numbs_buf,A0 
;		LEA numb_font,A2 
;		MOVEQ #10-1,D6
;.spr_lp	MOVEQ #9-1,D7 
;.li_lp		MOVE (A2),D0 
;		MOVE 10*2*1(A2),D1 
;		MOVE 10*2*2(A2),D2 
;		MOVE 10*2*3(A2),D3 
;		MOVE 10*2*4(A2),D4
;		MOVE D0,D5
;		OR D1,D5 
;		OR D2,D5 
;		OR D3,D5 
;		OR D4,D5 
;		MOVE D5,(A0)+ 
;		MOVE D5,(A0)+ 
;		MOVE D5,(A0)+ 
;		MOVE D5,(A0)+ 
;		MOVE D5,(A0)+
;		MOVEM.W D0-D4,(10*9)-10(A0)
;		LEA 10*2*5(A2),A2
;		DBF D7,.li_lp	
;		LEA -(10*2*5*9)+2(A2),A2
;		LEA 10*9(A0),A0
;		DBF D6,.spr_lp 
;		RTS





;------------------------------------------------------------------------; 
; Starfield shite. 
 
star_flag	DC.W 0 
 
no_strs		EQU 131 
 
init_stars	LEA clstars(PC),A0 
		MOVEQ #0,D0 
		MOVE #no_strs-1,D1 
.lp		ADDQ.L #2,A0
		MOVE.L D0,(A0)+ 
		DBF D1,.lp	 
		RTS 
	 
; Clear the stars. 
 
Clearstars	MOVE.L phy_base(PC),A0 
		LEA 320*100(A0),A0
clstars		
		REPT no_strs 
		EOR.W #0,2(A0)
		ENDR 
		RTS 
 
; Plot those darn stars! 
 
Plotstars	MOVE.L phy_base(PC),A0 
		LEA 320*100(A0),A0
		LEA offsets(PC),A1 
		LEA clstars(PC),A5 
		MOVE.L (A5),D4
		MOVE.W #no_strs-1,D7
.lp		MOVE.L (A1),A2		 
		MOVE.W (A2)+,D4 
		BEQ.S .restart 
.contrestart	MOVE.W (A2)+,D5		 
		MOVE.L A0,A3 
		ADDA.W D5,A3 
		MOVE.W (A3),D3 
		OR.W 2(A3),D3 
		OR.W 4(A3),D3 
		OR.W 6(A3),D3 
		NOT.W D3 
		AND.W D3,D4
		ADD.W (A2)+,D5 
		OR.W D4,(A0,D5.W) 
		MOVE.L A2,(A1)+		 
		MOVE.L D4,(A5)+ 
		MOVE.W D5,(A5)+ 
		DBF D7,.lp	 
		RTS 
.restart	MOVE.L (no_strs+1)*4(A1),A2	 
		MOVE.W (A2)+,D4 
		BRA.S .contrestart
 
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
		SUBQ #3,D6			;z=z-3 (perspect) 
		DIVS D2,D0			;x/z(perspect) 
		DIVS D2,D1			;y/z(perspect) 
		ADD #160,D0			;add offsets 
		ADD #100,D1			 
		CMP #319,D0 
		BHI.S Star_off 
		CMP #199,D1 
		BHI.S Star_off 
		MOVE D0,D3 
		MULU #320,D1 
		AND.W #$FFF0,D0 
		EXT.L D0
		ADD.L D0,D1 
		SUB.L #320*100,D1
		NOT D3 
		AND #15,D3 
		MOVEQ #0,D0 
		BSET D3,D0 
		MOVE.W D0,(A0)+ 
		MOVE.W D1,(A0)+ 
		ASR #6,D2 
		TST D2 
		BLE.S white 
		CMP #1,D2 
		BEQ.S white 
		CMP #2,D2 
		BEQ.S c2 
c1		MOVE.W #2*2,(A0)+ 
		BRA thisstar_lp 
white		MOVE.W #0,(A0)+
		BRA thisstar_lp 
c2		MOVE.W #2,(A0)+ 
		BRA thisstar_lp 
Star_off	MOVE.L #0,(A0)+ 
		MOVE.W #0,(A0)+ 
		DBF D7,genstar_lp 
		MOVE.L A0,(A3)+			;save reset offset 
		MOVE.L A0,(A2)+			;save curr offset 
 
Randoffsets	LEA offsets(PC),A0 
		LEA seed,A2 
		MOVE #no_strs-1,D7 
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
		RTS 

stars		INCBIN rand_131.xyz 
seed		DC.W $9753 
offsets		DS.L no_strs+1 
res_offsets	DS.L no_strs+1 
 
;------------------------------------------------------------------------; 

; Initialise music rotfile.

init_musrotfile	MOVE.B #mus_vol,$ffff893A.w
		MOVE.B #(mus_vol*16),$ffff893B.w
		LEA rotfile,A0
		MOVE.L 2(A0),D0
		ADD.L $6(A0),D0
		ADD.L $E(A0),D0
		LEA $1C(A0),A0
		MOVE.L A0,A1
		MOVE.L A0,A2
		MOVE.L A0,D1
		ADD.L D0,A1
		MOVE.L (A1)+,D0
		ADD.L D0,A2
		ADD.L D1,(A2)
		MOVEQ #0,D0
rel_lp		MOVE.B (A1)+,D0
		BEQ.S rel_done
		CMP.B #1,D0
		BEQ.S rel_1
		ADD.L D0,A2
		ADD.L D1,(A2)
		BRA.S rel_lp
rel_1		LEA $FE(A2),A2
		BRA.S rel_lp
rel_done	;move.w #-1,rotfile+24+28
		JMP rotfile+4+28

fademusicdown	BSR wait_vbl
		MOVEQ #0,D0
		MOVEQ #1,D1
		JSR rotfile+12+28
	      	LEA rotfile+28,A0 
 	        ADD.L 20(A0),A0		
.waitfade	BTST #0,(A0)		
          	BNE.S .waitfade
		BSR wait_vbl
		BSR wait_vbl
		JSR rotfile+16+28
		BSR wait_vbl
		BSR wait_vbl
		BRA wait_vbl

titlepal	dc.w	$000,$bbb,$777,$700,$333,$339,$b30,$353 
		dc.w	$66f,$fb0,$909,$b75,$090,$d0d,$fff,$0d0
 		ds.w	16

highscre_pal	dc.w	$000,$bbb,$777,$000,$333,$000,$000,$000 
		dc.w    $66f,$66f,$66f,$66f,$66f,$66f,$66f,$66f
 		ds.w	16

		SECTION DATA

logo		INCBIN GFX\NEWLOGO.DAT
numb_font	INCBIN GFX\NUMBS.DAT
gamesprites	INCBIN GFX\SPRITES.DAT
main_screenpic	INCBIN GFX\backgrnd.img
rotfile		INCBIN MAYHEM.MUS
		EVEN

		SECTION BSS

shifted_sprites	ds.b 11*(16*12) 
numbs_buf	DS.B 10*(16*9*28)
screens		DS.B 256
		DS.B 32256*2
		DS.B 32256*2
		DS.L 399
my_stack	DS.L 2
big_buf		DS.B 56000

