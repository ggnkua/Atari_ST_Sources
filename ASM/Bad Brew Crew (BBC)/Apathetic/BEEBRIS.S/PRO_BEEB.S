;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;           Bad Brew Crew "Total Apathy" MegaDemo Source Code           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;									 ;;
;;  	  *****    ******   ******   *****    *****    *    *****	 ;;
;; 	  *    *   *        *        *    *   *    *       *        	 ;;
;; 	  *****    ***      ***      *****    *****    *    ****	 ;;
;; 	  *    *   *        *        *    *   *    *   *        *	 ;;
;; 	  *****    ******   ******   *****    *    *   *   *****	 ;;
;;									 ;;
;;			      Version 2.71ish		 		 ;;
;;									 ;;
;;	 ---------------------------------------------------------	 ;;
;;          Code: The Law  Grafix: Various  Chip FX: Count Zero	  	 ;;
;;          ProTracker by Griff of Inner Circle/Module by Floyd		 ;;
;;									 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This source file is (c) 1991, The Law, Bad Brew Crew "APATHY RULES!"  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; flash caused by MFP interupt $fffffa15.w being disabled is now fixed! ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

debugging		; define for devpac, remove for disk
credit_screen		; define if credits to be assembled
game			; define if game to be assembled

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		ifd debugging
screen		equ $3f8000
hi_screen	equ $3f0000		 ; address of highest screen 4096k
ramtop		equ $400000		 ; guess.....
		endc
		ifnd debugging
screen		equ $78000
hi_screen	equ $70000		 ; address of highest screen 512k
ramtop		equ $80000		 ; guess.....
		endc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		move.l stack,a7
	 	lea $2000.w,a7		; make stack nice'n'safe

		clr.w -(a7)
		pea -1
		pea -1
		move.w #5,-(a7)
		trap #14
		lea 12(a7),a7

		pea code(pc)		; execute in Supervisor
		move.w #$26,-(a7)
		trap #14
	
		move.l stack,a7
		clr.l -(a7)		; and back to Gem.
		trap #1

stack		dc.l 0
scr_end		equ 160			 ; bytes/scanline

waitline	macro			; macro for stable rasters	
					; required during sample playing
		movem.l a0/d0,-(a7)
		move.w #$fa21,a0	; timer data
		move.b (a0),d0
.hangtheraster	cmp.b (a0),d0		; wait for scanline change
		beq.s .hangtheraster

		movem.l (a7)+,a0/d0

		endm


************************* No Traps Below Here!!!!! ***********************

code	move.b $ffff8201.w,old_screen+1	; save old screen address
	move.b $ffff8203.w,old_screen+2	
	move.l a7,start_a7		; save stack

	bsr save_system_vectors		; save mfp status

	ifd credit_screen
	jsr intro			; call tracker intro
	lea mt_data,a0			; then clear out ram
.fuck_derek_md
	clr.w (a0)+
	cmp.l #ramtop,a0
	bne.s .fuck_derek_md

	cmp.b #$10,lastkey		; q from intro?
	beq term			; yup! boo! hiss!
	endc

	ifd game
	move.w #$2700,sr		; no ints!

	lea $ffff8240.w,a0		; black
	moveq #7,d0
.makeb	clr.l (a0)+
	dbra d0,.makeb

	move.l #$4e714e71,d0		; remove all the crud from
	move.w d0,samplay+$26		; the sample player!
	move.l d0,samplay+$28
	move.w d0,samplay+$9ac
	move.l d0,samplay+$9ae

	jsr tracking_init		; make sprite routines

	lea hi_screen,a0		; address of screen #1
	move.l a0,screen1
	sub.l #$10000,a0		; sub a few bytes
	move.l a0,screen2		; address of screen #2

	move.l screen1,bot1		; calc address of lower borders
	move.l screen2,bot2
	move.l #200*160,d0
	add.l d0,bot1
	add.l d0,bot2

	lea -8*160(a0),a0		; 'bounce' area!
wipe	clr.w (a0)+			; and clear out RAM
	cmp.l #ramtop,a0		; (remove the tracker mod)
	bne.s wipe  

	bsr make_num_table		; make a table for the scores

	moveq.l #1,d0			; init chip music
	jsr music

	move.l #vbl,$70.w		; my vertical blank

	move.l #hbl,$120.w		; HBL vector
	bset #0,$fffffa07.w		; M.F.P. set
	bset #0,$fffffa13.w

	move.b #$80,d0			; reset ikbd
	bsr sikbd
	move.b #$1,d0			
	bsr sikbd
	move.b #$12,d0			; then disable mouse
	bsr sikbd

	move.l #ikbd118,$118.w		; my keyboard interupt

	bsr place_panel			; and draw the score panel
	bsr place_well_grafix		; and the well
	bsr credits

	lea copyrite+34,a0		; (c) copyright crap
	move.l screen1,a1
	move.l screen2,a2
	add.l #204*160,a1
	add.l #204*160,a2
	move.l #(26*160)/4,d0
.dcpy	move.l (a0),(a1)+
	move.l (a0)+,(a2)+
	subq.l #1,d0
	bne.s .dcpy

	move.w #$2300,sr		; power up the interupts!
	tst.b $fffffc02.w		; aaaaaaaaaaaarrrrrrrrrggggghhh!

************************************************************************
*     Only run once per game, and that is right at the beginning!      *
************************************************************************

reset	bsr place_well_grafix		; refresh the well
	move.w #0,start_y		; level 0 height    (junked!!)
	move.l #17,start_offset		; screen offset     (junked!!)
	move.w #'00',score-2		; clear score
	move.l #'0000',score		; clear score
	move.w #'00',level		; clear level
	move.w #3,c_down
	move.l #11,levspd		; reset speed to 11 (junked!!)
	move.w #0,lines_done		; and no lines made

	lea score_pic+34+(147*160),a0	; "Push Space To Play"
	bsr line_out

	lea score-2,a0			; send score to screen
	move.l #56+(160*128),a1	
	move.l a1,a2
	bsr print_number

	lea level,a0			; send level number to screen
	move.l #104+(160*88),a1
	move.l a1,a2
	bsr print_number

	bsr init_level			; game setup options

	cmp.b #$10,quitest		; all done?
	beq term			; boo hoo cry mode!

	moveq.l #0,d0			; get the NEXT shape
	move.w random_piece,d0
	add d0,d0
	add d0,d0
	lea piece_table,a0
	move.l (a0,d0),next_shape

	lea score_pic+34+(174*160),a0	; Nothing (clear line)
	bsr line_out

	clr.b prockey			; clear possible key-data
	clr.w joytest			; nothing like covering
	clr.b $fffffc02.w		; all possible bases!

*************************************************************************
*   We get back here every time a piece hits the bottom of the well..   *
*************************************************************************

next_piece
	move.w #1,kill_fa15
	bsr frame_wait

	tst.w donelst				; test for ikbd timeout
	bpl.s .ok
	move.w #1,donelst			; and correct it

.ok	bsr check_overflow_score		; has score overflowed?
	bsr frame_wait				; v-sync

	lea score-2,a0				; lets update the scrore
	move.l #56+(160*128),a1			; screen address to print
	move.l a1,a2
	bsr print_number

	bsr frame_wait				; v-sync

	lea level,a0				; lets update the level
	move.l #104+(160*88),a1	
	move.l a1,a2
	bsr print_number

	cmp.l #'arca',arcade
	bne.s .again
	subq.w #1,c_down
	bpl.s .again
	move.w #3,c_down
	bsr which_arcade_bitz	

.again	move.l levspd,speed			; reset current speed
	move.w #0,drops				; lines dropped this piece
	move.l #7,next_add			; used with MOVEP offsets
	move.l #1,next_sub			; used with MOVEP offsets
	move.l #40000,wibble			; area 'between' screens!
	move.l start_offset,address_offset	; address to draw shape at
	move.w #0,current_rot			; 1st rotaton
	move.w #5,well_x			; starts at 6 accross
	move.w start_y,well_y			; and y down into well
	bsr grab_piece				; fetch from database

	move.w speed+2,around			; init game speed delay

	move.l first_rotate,a1			; get co-ords of piece
	bsr test_positions			; check top of well
	bmi game_over				; branch if no space

	bsr frame_wait
	bsr display_next			; copy next to screen

**************************************************************************
*  This is done every time a piece drops one square....................  *
**************************************************************************

mainloop
	cmp.b #$10,quitest	; 'q' pushed?
	beq term		; yes, lets quit game (boohoo!)

	cmp.b #$01,lastkey	; esc - abort current game
	beq game_over

	cmp.l #1,speed		; fastdrop?
	bne wait
	addq.w #1,drphgt	; fast drop counter
	move.w #1,around

	cmp.w #'40',level
	beq.s kippers

wait	move.l speed,d0		; this loop controls the game speed
	asr d0
waitb	bsr frame_wait
	dbra d0,waitb

kippers	bsr move_em		; update block
	bsr scan_keyboard	; player moved?
	bsr unplot_block	; erase old block
	bsr plot_block		; and plot the current one
	bsr swap_em		; swap screens

	cmp.w #'40',level
	beq.s skipp2

	subq.w #1,around
	bne.s mainloop

skipp2	move.w speed+2,around	; game speed re-init

	lea chk1,a1		; has it hit something below?
	bsr test_positions
	bmi place		; branch if hit!

	addq.w #1,drops		; now increment drop counter
	bsr increment_verticals	; and adjust the table pointers

	bra mainloop		; then loop around

around	dc.w 3			; moves allowed per drop
c_down	dc.w 3			; drops till next arcade active!

mode	dc.l 0
which_arcade_bitz
	bsr get_arcade_level
	cmp.l #'_up_',mode
	beq shift_up
	cmp.l #'rand',mode
	beq random_block	
	rts
shift_up
	bsr move_em
	bsr frame_wait
	move.l screen2,a1
	lea -160*8(a1),a0
	move.w #184,ctr
.loop1	movem.l (a1),d0-7/a2-5
	movem.l d0-7/a2-5,(a0)
	lea 160(a0),a0
	lea 160(a1),a1
	subq.w #1,ctr
	bne.s .loop1
	move.w #8,ctr
	move.l screen2,a1
	lea -8*160(a1),a1
.loop2	movem.l (a1),d0-7/a2-5
	movem.l d0-7/a2-5,(a0)
	lea 160(a0),a0
	lea 160(a1),a1
	subq.w #1,ctr
	bne.s .loop2
	bsr frame_wait
	bsr swap_em
	bsr ascii_up
	bsr frame_wait
	addq.w #1,up_word
	cmp.w #10,up_word
	bne.s .ok
	clr.w up_word
.ok	moveq.l #0,d0
	move.w up_word,d0
	add.w d0,d0
	add.w d0,d0
	lea up_tabl,a0			; get new line for bottom of well!
	add.l d0,a0
	bsr arc_up
	rts
ascii_up
	lea well,a0
	lea well_bot,a1
.move	move.b 12(a0),(a0)+
	cmp.l a0,a1
	bne.s .move
	rts
ctr	dc.w 0

random_block
	bsr frame_wait
	moveq.l #0,d3
	move.w rand_y,d0
	move.w rand_x,d1
	move.w x_off,d2
	lea well,a0
	move.w d0,d3
	mulu #12,d3
	add.w d3,a0
	add.w d1,a0
	cmp.b #'*',(a0)
	beq .rts
	move.b #'*',(a0)
	move.w d0,d3
	mulu #160*8,d3
	add.w d2,d3
	move.l screen1,a0
	move.l screen2,a1
	add.w d3,a0
	add.w d3,a1
	move.l new_colour,a4
	move.l (a4)+,a5
	cmp.l #-1,a5
	bne.s .ok
	lea pcol,a4
	move.l (a4)+,a5
.ok	move.l a4,new_colour
x	set 0
	rept 8
	movep.l x(a5),d0
	movep.l d0,x(a0)
	movep.l d0,x(a1)
x	set x+160
	endr
.rts	rts

new_colour	dc.l pcol
pcol		dc.l wellpic+34+136
		dc.l wellpic+34+137
		dc.l wellpic+34+144
		dc.l wellpic+34+145
		dc.l wellpic+34+152
		dc.l wellpic+34+153
		dc.l -1

rand_x	dc.w 1
rand_y	dc.w 10
x_off	dc.w 1
next_x	dc.w 1
next_x1	dc.w 7
	endc

************************************************************************
*     Restore System To Entry Status (ooer! - sounds a bit rude!)      *
************************************************************************

term	bsr load_system_vectors		; restore MFP
	move.l start_a7,a7		; restore stack

	move.b old_screen+1,$ffff8201.w	; restore screen
	move.b old_screen+2,$ffff8203.w

	move.l #$8080000,$ffff8800.w	; kill soundchip
	move.l #$9090000,$ffff8800.w
	move.l #$a0a0000,$ffff8800.w

	rts	; THIS IS THE LAST INSTRUCTION EXECUTED IN THIS GAME!!!

***********************************************************************
*                 Routine to load the system values                   *
***********************************************************************

load_system_vectors
	move.w #$2700,sr		; kill interupts
	movem.l _pall,d0-7		; restore pallette
	movem.l d0-7,$ffff8240.w
	move.l _70,$70.w		; restore VBL
	move.l _120,$120.w		; restore HBL
	move.l _118,$118.w
	move.b _8260,$ffff8260.w	; restore res
	move.b _fa15,$fffffa15.w
	move.b _fa07,$fffffa07.w	; restore some interupts
	move.b _fa09,$fffffa09.w	; and some more
	bset.b #5,$fffffa15.w		; enable timer C
	bset.b #5,$fffffa09.w		; on all four status bits
	bset.b #5,$fffffa0d.w		
	bset.b #5,$fffffa11.w		
	move.b #$80,d0			; reset ikbd
	bsr sikbd
	move.b #$1,d0
	bsr sikbd
	move.l #$8080000,$ffff8800.w	; with no sound on
	move.l #$9090000,$ffff8800.w
	move.l #$a0a0000,$ffff8800.w
	move.w _sr,sr			; and restore status register
	rts

***********************************************************************
*                 Routine to save the system values                   *
***********************************************************************

save_system_vectors
	movem.l $ffff8240.w,d0-7	; save current pallette
	movem.l d0-7,_pall
	move.w sr,_sr			; save status register
	move.w #$2700,sr		; kill interupts
	move.l $70.w,_70		; save VBL
	move.l $120.w,_120		; save HBL
	move.l $118.w,_118
	move.b $ffff8260.w,_8260	; save res
	move.b $fffffa15.w,_fa15	;
	move.b $fffffa07.w,_fa07	; save some interupts
	move.b $fffffa09.w,_fa09	; and some more
	bclr.b #5,$fffffa15.w		; disable timer C
	bclr.b #5,$fffffa09.w		; on all four status bits
	bclr.b #5,$fffffa0d.w		
	bclr.b #5,$fffffa11.w		
	rts

sikbd	btst.b #1,$fffffc00.w		; wait for data-byte clear
	beq.s sikbd
	move.b d0,$fffffc02.w		; send byte to ikbd
	rts

start_a7	ds.l 1		; storage for stack
old_screen	ds.l 1		; address of entry screen
lastkey		dc.w 0		; last key pushed (not stix)
_pall		ds.w 16		; storage for pallette
_sr		ds.w 1		; storage for status register
_70		ds.l 1		; storage for vbl
_120		ds.l 1		; storage for hbl
_118		ds.l 1		; storage for keyboard
_8260		ds.w 1		; storage for frequency
_fa15		ds.w 1		; storage for mfp
_fa07		ds.w 1		; storage for mfp
_fa09		ds.w 1		; storage for mfp

	ifd game

_rte_	rte

************************************************************************
*                      Routine to wait for one vbl.                    *
************************************************************************

frame_wait
	move.w d0,-(a7)
	move.w vbl_done,d0	
blob	cmp.w vbl_done,d0	
	beq.s blob
	move.w (a7)+,d0
	rts

**********************************************************************
*   Beebris game subroutines follow (and there are a lot of them!)   *
**********************************************************************

place	move.w #1,line_dn	; set flag to +ve
	tst.w drops		; is this first drop?
	beq game_over		; branch if yes to game over routines

	bsr bomb_line		; check to see if a bomb was dropped!
				; (beebris+ version only!)
	bsr plot_well		; plot the shape into the ascii map

	bsr check_for_line	; check for any lines made

	addq.l #1,score		; add one to score
	bsr check_overflow_score

	tst.w drphgt		; on a fast drop?
	beq anyline

	moveq.l #0,d0
	move.w drphgt,d0	; height dropped at fast speed
	clr.w drphgt		; then clear it
	add d0,d0		; mult by 2
addum	addq.l #1,score		; add 1
	bsr check_overflow_score
	subq.w #1,d0	
	bne.s addum

anyline	tst.w line_dn		; now test the flag
	bmi levchk		; and branch if a line is made
	bra next_piece		; go get another piece

levchk	moveq.l #0,d0		; add correct score for No. lines made
	move.w current_drops,d0	; number of lines made last block
	add d0,d0
	lea scoretab,a0		; get score
	move.w (a0,d0),d0
	cmp.w #200,d0		; 4 lines made?
	bne addit
	move.w current_mus,d1	; get current tune
	addq.w #1,d1		; go to next tune
	cmp.w #4,d1		; last tune?
	bne.s .write
	move.w #1,d1		; reset tune
.write	move.w d1,current_mus	; store new tune
	move.l d0,-(a7)
	move.w d1,d0
	jsr music		; re-init music

	bsr sound_off
	movem.l d0-a6,-(a7)	
	lea samplay,a1
	move.l #sam2,(a1)+
	move.l #sam2end-sam2,(a1)+
	move.w #0,(a1)+
	move.w #1,(a1)+
	move.w #1,(a1)+
	jsr samplay+$1c		; fanfare! 4 lines made!
	movem.l (a7)+,d0-a6
	move.w #40,d0		; wait for end of sample
.booom	bsr frame_wait
	dbra d0,.booom

	move.l (a7)+,d0		; add bonus to score
addit	addq.l #1,score
	bsr check_overflow_score
	subq.w #1,d0
	bne.s addit
	bsr sound_on
	bsr frame_wait

	cmp.w #10,lines_done	; have 10 lines been made?
	blt next_piece		; branch if not

	move.w #0,lines_done	; reset line counter
;;
;; lines removed!
;; cmp.l #2,levspd
;; beq uplev..... why?????
;;
	bsr sound_off
	movem.l d0-a6,-(a7)	
	lea samplay,a1
	move.l #sam4,(a1)+
	move.l #sam4end-sam4,(a1)+
	move.w #0,(a1)+
	move.w #1,(a1)+
	move.w #1,(a1)+
	jsr samplay+$1c		; jingle - new level
	movem.l (a7)+,d0-a6
	move.w #50,d0		; wait for end of sample
.booom	bsr frame_wait
	dbra d0,.booom
	bsr sound_on

uplev	move.w #3,c_down
	cmp.w #'40',level	; top level?
	beq next_piece

	addq.w #1,level		; and increment the level
	bsr check_overflow_level	; level number overflowed?
************************************************************************
	bsr res_lev		; reset all values

	cmp.l #'arca',arcade	; arcade mode enabled?
	bne.s .norm
	bsr get_arcade_level	; yes, check for new well data
	bsr process_level
.norm	bra next_piece

res_lev	bsr.s conv		; convert ascii level to value
	bsr.s res_1		; get level speed/height data
	rts

conv	moveq.l #0,d0
	move.b level,d0			; get first digit
	sub.b #'0',d0			; convert from ascii
	mulu #10,d0			; mult by 10
	moveq.l #0,d1
	move.b level+1,d1		; get second digit
	sub.b #'0',d1			; convert from ascii
	add.l d1,d0			; add to first
	rts

res_1	mulu #12,d0			; mult total by 12
	lea lev_table,a0		; lookup table for level values
	move.l (a0,d0),levspd		; game speed
	move.w 6(a0,d0),start_y		; ascii map offset
	move.l 8(a0,d0),start_offset	; screen offset
	rts

arcade	dc.l 0			; flag for 'arca'de mode
get_arcade_level
	bsr conv		; get level number in d0
	lea arc_tab(pc),a0
	add d0,d0
	add d0,d0
	add d0,d0
	add.l d0,a0	
	move.l (a0)+,d0
	move.l d0,mode
	rts

empty	bsr place_well_grafix	; no data, wipe old well
	lea well,a0		
	move.l #23,d0		
.wipe	clr.b 1(a0)
	clr.l 2(a0)
	clr.l 6(a0)
	clr.b 10(a0)
	lea 12(a0),a0
	subq.l #1,d0
	bne.s .wipe
	rts

process_level
	movem.l d0/a0,-(a7)	; clear the well out (screen & ascii)
	bsr empty
	movem.l (a7)+,d0/a0
	cmp.l #'grid',mode
	bne _rts
arc_up	bsr move_em
	move.l (a0)+,a1		; get address of level data
.loop	move.w (a1)+,d1		; height to place line data
	cmp.w #-1,d1		; end of data
	beq .rts
	move.w d1,-(a7)		; save for laters....
	lea well,a0		; address of ascii map
	mulu #12,d1		; and mult by 12 to get offset
	add.w d1,a0		; address of char in ascii map
	move.l (a1),(a0)	; plot blocks into ascii
	move.l 4(a1),4(a0)
	move.l 8(a1),8(a0)
	move.l screen2,a3
	move.w (a7)+,d1		; told ya!
	mulu #160*8,d1		; convert to graphics offset
	add.w d1,a3
	addq.w #1,a3
	moveq.l #7,d2
	moveq.l #1,d3
	moveq.l #10,d1
	lea wellpic+34+136,a4
	addq.w #1,a1
.ploty	cmp.b #'*',(a1)+
	bne.s .done
	bsr.s .plot1
.done	add.w d2,a3
	move.w d2,-(a7)
	move.w d3,d2
	move.w (a7)+,d3
	subq.w #1,d1
	bne.s .ploty
	addq.w #1,a1
	bra .loop
.rts	bsr swap_em
	rts
.plot1
x	set 0
	rept 8
	movep.l x(a4),d7
	movep.l d7,x(a3)
x	set x+160
	endr
	rts

;; arcade level well data-table
;;
;; "none" = normal level (get 10 lines)
;; "_up_" = move blocks up well (get 10 lines)
;; "rand" = random block appearing from time to time (Get 10 lines)
;; "grid" = pre-build grid in the well!
;;
arc_tab	rept 4
	dc.b "none"
	dc.l 0
	dc.b "_up_"
	dc.l 0
	dc.b "grid"
	dc.l boty1
	dc.b "rand"
	dc.l 0
	dc.b "grid"
	dc.l boty2
	dc.b "_up_"
	dc.l 0
	dc.b "grid"
	dc.l lower
	dc.b "none"
	dc.l 0
	dc.b "grid"
	dc.l mid
	dc.b "grid"
	dc.l high
	endr
	dc.l "none"
	dc.l 0

boty1	dc.w 22
	dc.b "** * ** * **"
	dc.l -1
boty2	dc.w 19
	dc.b "*          *"
	dc.w 20
	dc.b "**        **"
	dc.w 21
	dc.b "***      ***"
	dc.w 22
	dc.b "****    ****"
	dc.l -1
lower	dc.w 17
	dc.b "*          *"
	dc.w 18
	dc.b "**         *"
	dc.w 19
	dc.b "****       *"
	dc.w 20
	dc.b "******     *"
	dc.w 21
	dc.b "********   *"
	dc.w 22
	dc.b "********** *"
	dc.l -1
mid	dc.w 17
	dc.b "*    **    *"
	dc.w 18
	dc.b "*   ****   *"
	dc.w 19
	dc.b "*  * ****  *"
	dc.w 20
	dc.b "* ****** * *"
	dc.w 21
	dc.b "**  *  *  **"
	dc.w 22
	dc.b "*****  *****"
	dc.l -1
high	dc.w 12
	dc.b "**        **"
	dc.w 13
	dc.b "**        **"
	dc.w 14
	dc.b "**        **"
	dc.w 15
	dc.b "***      ***"
	dc.w 16
	dc.b "****    ****"
	dc.w 17
	dc.b "*****  *****"
	dc.w 18
	dc.b "**        **"
	dc.w 19
	dc.b "**        **"
	dc.w 20
	dc.b "**        **"
	dc.w 21
	dc.b "**   **   **"
	dc.w 22
	dc.b "** ****** **"
	dc.l -1

up_word	dc.w 0
up_tabl	dc.l make_0,make_1,make_2,make_3,make_4
	dc.l make_5,make_6,make_7,make_8,make_9

make_0	dc.w 22
	dc.b "***      ***"
	dc.l -1
make_1	dc.w 22
	dc.b "****** *****"
	dc.l -1
make_2	dc.w 22
	dc.b "** **  ** **"
	dc.l -1
make_3	dc.w 22
	dc.b "* *  **  * *"
	dc.l -1
make_4	dc.w 22
	dc.b "******** * *"
	dc.l -1
make_5	dc.w 22
	dc.b "* ******** *" 
	dc.l -1
make_6	dc.w 22
	dc.b "*          *"
	dc.l -1
make_7	dc.w 22
	dc.b "**        **"
	dc.l -1
make_8	dc.w 22
	dc.b "*    **    *"
	dc.l -1
make_9	dc.w 22
	dc.b "**** ** ****"
	dc.l -1

;;;;;;;;;;;;;;;;;;;;;
;; Level selection ;;
;;;;;;;;;;;;;;;;;;;;;

reinit	cmp.l #'arca',arcade
	bne.s .rts
	bsr res_lev
	bsr get_arcade_level
	bsr process_level
.rts	rts

init_level
	cmp.b #$10,lastkey		; 'q'
	bne.s .cont0
	move.b #$10,quitest		; force an exit!
	rts
.cont0	btst.b #7,prockey		; fire! (stick)
	beq.s .contz
	bsr reinit
	rts
.contz	cmp.b #$39,lastkey		; space!
	bne.s .cont0a
	bsr reinit
	rts
.cont0a	cmp.b #$2,lastkey		; '1' - beebris mode!
	bne.s .cont0b
	clr.l arcade
	move.w #7,block_num		; reset range
	clr.w random_piece
	bsr place_well_grafix
	bsr erase_ascii
	lea score_pic+34+(33*160),a2	; copy to screen
	bsr mode_plot
	bsr reinit
	bra.s init_level
.cont0b	cmp.b #$3,lastkey		; '2' - beebris+ mode!
	bne.s .cont0c
	clr.l arcade
	move.w #14,block_num		; extend range
	clr.w random_piece
	bsr place_well_grafix
	bsr erase_ascii
	lea score_pic+34+(33*160)+112,a2	; copy to screen
	bsr mode_plot
	bsr reinit
	bra init_level
.cont0c	cmp.b #$4,lastkey		; '3' - arcade mdoe!
	bne.s .cont0d
	move.l #'arca',arcade
	move.w #7,block_num		; reset range
	clr.w random_piece
	lea score_pic+34+(42*160)+112,a2	; copy to screen
	bsr mode_plot
	bsr reinit
	bra init_level
.cont0d	cmp.b #$5,lastkey		; '4' - arcade+ mdoe!
	bne.s .cont1
	move.l #'arca',arcade
	move.w #14,block_num		; extend range
	clr.w random_piece
	lea score_pic+34+(51*160)+112,a2	; copy to screen
	bsr mode_plot
	bsr reinit
	bra init_level
.cont1	cmp.b #$4e,lastkey		; '+' - increment level
	bne.s .cont2
	bsr inc_level
	bsr check_arc
	bra init_level
.cont2	cmp.b #$4a,lastkey		; '-' - decrement level
	bne init_level
	bsr dec_level
	bsr check_arc
	bra init_level

check_arc
	cmp.l #'arca',arcade		; in arcade mode?
	bne.s .rts
	bsr get_arcade_level		; do the well up!
	bsr process_level
.rts	rts

inc_level
	bsr big_delay
	cmp.w #'40',level		; top level reached?
	beq .rts
	addq.w #1,level			; add 1 to level number
	bsr check_overflow_level	; check the ascii
	bsr frame_wait
	lea level,a0			; send new number to scren
	move.l #104+(160*88),a1
	move.l a1,a2
	bsr print_number
	bsr res_lev			; get new values
.rts	rts

dec_level	
	bsr big_delay
	cmp.w #'00',level		; lowest level?
	beq .rts
	subq.w #1,level			; sub 1 from level
	bsr check_overflow_level	; check the ascii
	bsr frame_wait
	lea level,a0
	move.l #104+(160*88),a1		; send new number to screen
	move.l a1,a2
	bsr print_number
	bsr res_lev			; get new values
.rts	rts

big_delay	
	moveq.l #5,d0
.1	bsr frame_wait
	dbra d0,.1
	rts

mode_plot
	move.l screen1,a0		; rout to copy 
	move.l screen2,a1		; 'beebris' or 'beebris+'
	lea 48+(160*68)(a0),a0		; to top of score panel
	lea 48+(160*68)(a1),a1
	moveq.l #7,d0
.plotit	movem.l (a2),d1-6
	movem.l d1-6,(a0)
	movem.l d1-6,(a1)
	movem.l 24(a2),d1-4
	movem.l d1-4,24(a0)
	movem.l d1-4,24(a1)
	lea 160(a0),a0
	lea 160(a1),a1
	lea 160(a2),a2
	subq.l #1,d0
	bne.s .plotit
	rts

; stored as speed, y start (ascii), y start (screen)
gfx	equ 160*8
lev_table
	dc.l 11,0,17,10,0,17,9,0,17,8,0,17
	dc.l 7,0,17,6,0,17,5,0,17,4,0,17
	dc.l 3,0,17,2,0,17				; 0-9

	dc.l 6,1,17+(gfx*1),5,1,17+(gfx*1),4,1,17+(gfx*1),3,1,17+(gfx*1),2,1,17+(gfx*1)  ; 10-14
	dc.l 6,2,17+(gfx*2),5,2,17+(gfx*2),4,2,17+(gfx*2),3,2,17+(gfx*2),2,2,17+(gfx*2)  ; 15-19
	dc.l 6,3,17+(gfx*3),5,3,17+(gfx*3),4,3,17+(gfx*3),3,3,17+(gfx*3),2,3,17+(gfx*3)  ; 20-24
	dc.l 6,4,17+(gfx*4),5,4,17+(gfx*4),4,4,17+(gfx*4),3,4,17+(gfx*4),2,4,17+(gfx*4)  ; 25-29
	dc.l 6,5,17+(gfx*5),5,5,17+(gfx*5),4,5,17+(gfx*5),3,5,17+(gfx*5),2,5,17+(gfx*5)  ; 30-34
	dc.l 6,6,17+(gfx*6),5,6,17+(gfx*6),4,6,17+(gfx*6),3,6,17+(gfx*6),2,6,17+(gfx*6)  ; 35-39

	dc.l 2,7,17+(gfx*7)		; level 40 - no chance!

***********************************************************************
*    The Game Over Routine. Maybe You'll Do Better Next Time, Eh???   *
***********************************************************************

game_over
	lea score_pic+34+(165*160),a0	; "Game Over - Push Space"
	bsr line_out			; send to screen

	bsr frame_wait		; wait for vbl
	bsr sound_off

	movem.l d0-a6,-(a7)
	lea samplay,a1
	move.l #sam3,(a1)+	
	move.l #sam3end-sam3,(a1)+
	move.w #0,(a1)+
	move.w #1,(a1)+
	move.w #1,(a1)+
	jsr samplay+$1c		; game over
	movem.l (a7)+,d0-a6

	move.l #80,d0
.shitty	bsr frame_wait
	dbra d0,.shitty

	bsr sound_on
	bsr erase_ascii
	bra reset		; go start a new game!

erase_ascii
	lea well,a0		; now I must clear out the ascii map
	move.l #23,d0		; of the well
wipe_well
	clr.b 1(a0)
	clr.l 2(a0)
	clr.l 6(a0)
	clr.b 10(a0)
	lea 12(a0),a0
	subq.l #1,d0
	bne.s wipe_well
	rts

sound_off
	move.w #-1,do_mus	; kill music in vbl
	bsr frame_wait
	moveq.l #13,d0		; save ym status
	lea snd_chip(pc),a0
.sav	move.b d0,$ffff8800.w
	move.b $ffff8800.w,(a0)+
	subq.w #1,d0
	bpl.s .sav
	move.l #$8080000,$ffff8800.w
	move.l #$9090000,$ffff8800.w
	move.l #$a0a0000,$ffff8800.w
	bsr frame_wait
	rts

sound_off2
	bsr frame_wait
	moveq.l #13,d0		; save ym status without killing channels
	lea snd_chip(pc),a0
.sav	move.b d0,$ffff8800.w
	move.b $ffff8800.w,(a0)+
	subq.w #1,d0
	bpl.s .sav
	rts

sound_on
	move.l #$8080000,$ffff8800.w	; reload ym status
	move.l #$9090000,$ffff8800.w
	move.l #$a0a0000,$ffff8800.w
 	moveq.l #13,d0
	lea snd_chip(pc),a0
.sav	move.b d0,$ffff8800.w
	move.b (a0)+,$ffff8800.w
	subq.w #1,d0
	bpl.s .sav
	move.l #$8080000,$ffff8800.w
	move.l #$9090000,$ffff8800.w
	move.l #$a0a0000,$ffff8800.w
	bsr frame_wait
	move.w #1,do_mus
	bsr frame_wait
	rts

snd_chip	ds.b 16

************************************************************************
*                  Increment all relevant pointers                     *
************************************************************************

increment_verticals
	addq.w #1,well_y		; ascii position down 1 line
	add.l #160*8,address_offset	; grafix position down 8 scanlines
	rts

************************************************************************
*   This places the piece into the ascii map of the well............   *
************************************************************************

bomb_line
	cmp.l #bld,current_piece	; was that a bomb?
	bne.s _exit_
	lea well,a0		; well ascii map
	move.w well_y,d1	; line finished on
	mulu #12,d1		; by 12
	add.w d1,a0
	move.l #'****',(a0)	; make line full!
	move.l #'****',4(a0)
	move.l #'****',8(a0)
_exit_	rts

plot_well
	lea well,a0		; address of ascii map
	add.w well_x,a0		; add horizontal offsets
	move.w well_y,d1	; get the vertical offset
	mulu #12,d1		; and mult by 12 to get offset
	add.w d1,a0		; address of char in ascii map

	lea character,a1	; ascii table for current shape

	rept 4			; all shapes four lines high!
	cmp.b #'*',(a1)+	; is it a square?
	dc.w $6604		; branch if not (No labels in Rept loops)
	bsr place_star		; yes so plot in the ascii map
	addq.l #1,a0		; jump to next pos
	cmp.b #'*',(a1)+
	dc.w $6604
	bsr place_star
	addq.l #1,a0
	cmp.b #'*',(a1)+
	dc.w $6604
	bsr place_star
	addq.l #1,a0
	cmp.b #'*',(a1)+
	dc.w $6604
	bsr place_star
	add.l #9,a0		; jump to next line!
	endr			; and repeat it all again!

	move.l #40000,wibble	; 'somewhere' between screens!

	rts

place_star
	move.b #'*',(a0)	; plot a star (square) in ascii map
	rts

**********************************************************************
* Check to see if lines are made, and if so, adjust the screen & map *
**********************************************************************

check_for_line
	move.w #0,current_drops
checker	move.w #1,goes		; flag use to check if any lines moved
	lea well_bot,a0		; bottom of the well
	move.l #23,d7		; check upwards for 23 lines		
	move.l #22*8*160,on_screen	; screen offset to current line
check_loopy
	bsr check_well_line	; check for a line
	lea -12(a0),a0		; decrement backwards 1 line in ascii
	sub.l #8*160,on_screen	; decrement backwards 8 on screen
	subq.l #1,d7		; loop around
	bne.s check_loopy
	tst.w goes		; any moved?
	bmi checker		; branch if yes
	bsr sound_on
	rts			; fall out here when finished

check_well_line
	cmp.l #'****',(a0)	; start testing
	bne __rts		; branch if not complete
	cmp.l #'****',4(a0)
	bne __rts
	cmp.l #'****',8(a0)
	bne __rts

	addq.w #1,current_drops	; fall here if line made
	addq.w #1,lines_done	; add 1 line made (level counter)
	move.w #-1,line_dn	; reset flag
	move.w #-1,goes		; reset flag (what? I can't remember this!)
	bsr drop_ascii		; must correct ascii map
	bsr move_em
	bsr frame_wait
	bsr drop_grafix		; and also the screen image!
	bsr swap_em
	bsr sound_off2
	tst.w do_mus
	bmi.s ._do_b
	move.l #$8080000,$ffff8800.w
	move.l #$9090000,$ffff8800.w
	move.l #$a0a0000,$ffff8800.w
	move.w #-1,do_mus
._do_b	bsr _boom_
__rts	rts			; else get to here

bugflag	dc.w -1

process_bounce
	tst.w bugflag
	bmi .rts
.ST	cmp.w #'ST',bugflag
	bne.s .SB
	move.l screen1,xx1
	move.l screen2,xx2
	move.w #-1,bugflag
	rts
.SB	cmp.w #'SB',bugflag
	bne.s .RE
	sub.l #160*8,screen1
	sub.l #160*8,screen2
	move.w #-1,bugflag
	rts
.RE	cmp.w #'RE',bugflag
	bne.s .SW
	move.l xx1,screen1
	move.l xx2,screen2
	move.w #-1,bugflag
	rts
.SW	move.l screen1,tt1
	move.l screen2,screen1
	move.l tt1,screen2
	move.w #-2,bugflag
.rts	rts
xx1	dc.l 0
xx2	dc.l 0
tt1	dc.l 0
	
_boom_
.hang1	move.w #'ST',bugflag	; STore
	bsr frame_wait
	bsr frame_wait
	move.w #'SB',bugflag	; SuBtract  160*8
	movem.l d0-a6,-(a7)
	lea samplay,a1
	move.l #sam1,(a1)+	
	move.l #sam1end-sam1,(a1)+
	move.w #0,(a1)+
	move.w #1,(a1)+
	move.w #1,(a1)+
	jsr samplay+$1c		; boom! sample!
	movem.l (a7)+,d0-a6
	move.w #10,d0
.booom	bsr frame_wait		; wait for sample to finish
	dbra d0,.booom
	move.w #'RE',bugflag
	bsr frame_wait
	bsr frame_wait
	move.w #-1,bugflag
	bsr frame_wait
	rts

do_mus	dc.w 1

drop_ascii
	move.l d7,d0		; number of lines above this one
	move.l a0,a1		; can't trash a0!!!!
buggery
	move.l -12(a1),(a1)	; copy line above in ascii
	move.l -8(a1),4(a1)	; down the screen
	move.l -4(a1),8(a1)
	lea -12(a1),a1
	subq.l #1,d0
	bpl.s buggery
	rts	

drop_grafix
	move.l screen2,a6
	add.l on_screen,a6
	move.l a6,a4		
	lea -8*160(a4),a4	; must get data from 8 line above

	move.w d7,d6		; number of lines in d6
	subq.w #1,d6		; but only copy 1 less
what_a_bummer
	bsr frame_wait		; v-sync (causes a ripple when line made)
xxx	set 0
	rept 8			; block is 8 lines high
	movem.l xxx(a4),d0-5	; grab data from line above
	movem.l d0-5,xxx(a6)	; then screen #2
	movem.l xxx+24(a4),d0-5	; next chunk
	movem.l d0-5,xxx+24(a6)	; place in #2
xxx	set xxx+160		; jump next line
	endr			; 

	lea -160*8(a4),a4	; jump all backwards by 8 lines
	lea -160*8(a6),a6
	subq.w #1,d6		; loop until finished
	bpl what_a_bummer

	rts

swap_em	move.w #'SW',bugflag
.hangit	cmp.w #-2,bugflag
	bne.s .hangit
	move.w #-1,bugflag
	rts

move_em	movem.l d0-a6,-(a7)		; copy the well from the
	move.l screen1,a5		; display screen to the
	move.l screen2,a6		; working screen
xxx	set 0
	rept 194
	movem.l xxx(a5),d0-7/a0-3
	movem.l d0-7/a0-3,xxx(a6)
xxx	set xxx+160
	endr
	movem.l (a7)+,d0-a6
	rts

************************************************************************
*  This tests a position map to see if hit square. Values are in Dbase *
*        Each square can only have up to four positions to test        *
************************************************************************
	
test_positions
	lea well,a0		; address of well ascii
	move.w well_y,d0	; get vertical
	mulu #12,d0		; offset into d0
	add.l d0,a0		; plus vertical offset
	add.w well_x,a0		; plus horizontal offset
	move.l a0,-(a7)		; save on stack
	
check1	add.w (a1)+,a0		; 1st x-check
	move.w (a1)+,d1		; 1sr y-check
	mulu #12,d1
	add.l d1,a0
	cmp.b #'*',(a0)	
	beq stop_me	
check2	move.l (a7),a0		; from stack
	add.w (a1)+,a0		; 2nd x-check
	move.w (a1)+,d1		; 2nd y-check
	mulu #12,d1
	add.l d1,a0
	cmp.b #'*',(a0)
	beq stop_me
check3	move.l (a7),a0		; from stack
	add.w (a1)+,a0		; 3rd x-check
	move.w (a1)+,d1		; 3rd y-check
	mulu #12,d1
	add.l d1,a0
	cmp.b #'*',(a0)
	beq stop_me
check4	move.l (a7),a0		; from stack
	add.w (a1)+,a0		; 4th x-check
	move.w (a1)+,d1		; 4th y-check
	mulu #12,d1
	add.l d1,a0
	cmp.b #'*',(a0)
	beq stop_me
check5	move.l (a7),a0		; from stack
	add.w (a1)+,a0		; 5th x-check
	move.w (a1)+,d1		; 5th y-check
	mulu #12,d1
	add.l d1,a0
	cmp.b #'*',(a0)
	beq stop_me

	addq.l #4,a7		; correct stack
	moveq #1,d0		; here if all clear, set d0 to 0
	rts

stop_me	addq.l #4,a7		; correct stack
	moveq #-1,d0		; here if hit, set d0 to -1
	rts


************************************************************************
*                       Keyboard controls are here                     *
************************************************************************

scan_keyboard

.cont	cmp.b #$10,lastkey	; 'q'
	beq setquit

	cmp.b #$19,lastkey	; 'p'
	beq pause

	move.b prockey,d7	; pull value from ikbd

	move.w #1,donelst

	cmp.b #2,d7		; joys DOWN
	beq turbo

	bclr #2,d7		; joys left/diagonal
	beq .lft
	bsr left
.lft	bclr #3,d7		; joys right/diagonal
	beq .rigt
	bsr right
.rigt	bclr #7,d7		; joys fire!
	beq.s .rot
	bsr rotate
.rot	move.b lastkey,d7
	cmp.b #$4b,d7		; curs left
	beq left
	cmp.b #$4d,d7		; curs right
	beq right
	cmp.b #$48,d7		; curs up! - rotate
	beq rotate
	cmp.b #$50,d7		; cursor down - fast drop piece
	beq turbo

	move.l levspd,speed
	clr.w drphgt

	rts

turbo	move.l #1,speed		; fast speed on!
	rts

setquit	move.b #$10,quitest	; 'q' flagged
	rts

quitest	dc.w 0
drphgt	dc.w 0	

left	clr.w drphgt
	move.l levspd,speed	; reset current speed (abort fast)

	lea lft1,a1		; pointer to left check co-ords
	bsr test_positions	; go test em
	bmi.s _rts		; branch if illegal

	move.w #1,drops
	move.l next_sub,d0	; adjust MOVEP offsets
	sub.l d0,address_offset	; and screen pointer
	bsr swap_nums		; swap MOVEP offsets
	subq.w #1,well_x	; left 1 in ascii
_rts	rts

right	clr.w drphgt
	move.l levspd,speed	; reset speed

	lea rgh1,a1		; pointer to right check co-ords
	bsr test_positions	; go test em
	bmi.s _rts		; branch if illegal

	move.w #1,drops
	move.l next_add,d0	; adjust MOVEP offsets
	add.l d0,address_offset	; and screen pointer
	bsr swap_nums		; SWAP MOVEP offsets
	addq.w #1,well_x	; right 1 in ascii
	rts

rotate	clr.w drphgt
	move.l levspd,speed	; reset speed

	lea rot1,a1		; pointer to next rotation co-ords
	bsr test_positions	; go test em
	bmi.s _rts		; branch if illegal
	
	bsr frame_wait

	bsr frame_wait
	move.w #1,drops
	addq.w #4,current_rot	; pointer to next chatacter
	cmp.w #16,current_rot	; at rotation #4
	bne.s ._rts		; branch if no
	clr.w current_rot	; reset to rotation 0

._rts	bsr jmp_grab_piece	; get piece from database
	rts

swap_nums
	move.l next_add,d0	; exchange the MOVEP offset values
	move.l next_sub,next_add
	move.l d0,next_sub
	rts

pause	lea score_pic+34+(156*160),a0	; "Game Paused - Push P"
	bsr line_out		; send to screen

	move.l #5,d0		; wait 5 frames
.skrew	bsr frame_wait
	subq.l #1,d0
	bne.s .skrew

p_push	cmp.b #$19,lastkey 	; wait for 'P'
	bne.s p_push

	lea score_pic+34+(174*160),a0 ; blank line
	bsr line_out		; send to screen

	move.l #5,d0		; wait 5 frames
.skrew	bsr frame_wait
	subq.l #1,d0
	bne.s .skrew

	rts

***************************************************************************
*                      Routine to Un-plot a block                         *
***************************************************************************

unplot_block	bsr frame_wait

		move.l screen2,a5
		lea savbuff,a4		; with data from the buffer
		move.l wibble,d0
		add.l d0,a5

xxx		set 0		
		rept 32			; blocks are 32 lines high
		movem.l (a4)+,d0-7/a0-3
		movem.l d0-7/a0-3,xxx(a5)
xxx		set xxx+160
		endr

		rts

************************************************************************
*             Grab a completely fresh piece from the Dbase             *
************************************************************************

grab_piece	moveq #0,d0		; clear d0
		move.w random_piece,d0	; vbl counter
		add d0,d0		; times it
		add d0,d0		; by 4
		lea piece_table,a0	; and load table start
		move.l next_shape,current_piece
		move.l (a0,d0),next_shape	; pull pointer


             **************************************
             * Jump here when new rotation needed *
             **************************************

jmp_grab_piece	move.l current_piece,a0	; pointer to current piece
		move.l 12(a0),first_rotate ; data of first rotation
		add.l #80,first_rotate	; offset to position values
					; this was THE BASTARD OF A BUG!!!
		move.w current_rot,d0	; rotation value
		move.l (a0,d0),a0	; get pointer to shape table 
		move.w (a0)+,width	; pull width  (not used!)
		move.w (a0)+,height	; pull height (not used!)

		lea character,a1	; and copy 21 longwords
		rept 25			; of data in the current shape
		move.l (a0)+,(a1)+	; buffer
		endr
		rts

************************************************************************
*    Plot a block to next shape. Warning. Uses MOVEP/odd addressing!   *
************************************************************************

display_next	move.l address_offset,-(a7)	; save attributes
		move.l current_piece,-(a7)
		move.l next_add,-(a7)
		move.l next_sub,-(a7)
		move.l #72+(160*88),address_offset
		move.l #1,next_add
		move.l #7,next_sub
		move.l next_shape,current_piece	; swap for next
		bsr jmp_grab_piece		; get details
		bsr frame_wait			
		bsr move_em	
		bsr frame_wait
		bsr clear_old			; wipe old next
		bsr jmp_into_plot		; plot next (screen #1)
		bsr swap_em
		bsr frame_wait
		bsr move_em
		bsr frame_wait
		bsr clear_old
		bsr jmp_into_plot		; plot next (screen #2)
		bsr swap_em
		move.l (a7)+,next_sub		; restore attributes
		move.l (a7)+,next_add
		move.l (a7)+,current_piece
		move.l (a7)+,address_offset
		bsr jmp_grab_piece		; re-fetch current shape
		rts

clear_old	movem.l score_pic+34+(160*32),d1-2
		move.l screen2,a1
		lea 72+(160*88)(a1),a1
		move.l #31,d0
.kill_Andy	movem.l d1-2,(a1)
		movem.l d1-2,8(a1)
		lea 160(a1),a1
		dbra d0,.kill_Andy
		rts

************************************************************************
*    Plot a block to the screen. Warning. Uses MOVEP/odd addressing!   *
************************************************************************

plot_block	move.l screen2,a0	; address of screen
		lea savbuff,a1		; save buffer
		move.w well_y,d0
		mulu #160*8,d0		; and add offset
		add.l d0,a0	
		move.l d0,wibble	; save for use by un-plotter

xxx		set 0			; save 32 scanlines of screen
		rept 32
		movem.l xxx(a0),d0-5
		movem.l d0-5,(a1)
		movem.l xxx+24(a0),d0-5
		movem.l d0-5,24(a1)
		lea 48(a1),a1
xxx		set xxx+160
		endr

jmp_into_plot	lea character,a0	; current character attributes
		move.l next_add,d0	; adjust MOVEP
		move.l next_sub,d1	; adjust MOVEP
		move.w d0,second	; make positions
		move.w d0,third		; "
		add.w d1,third		; "
		move.w third,fourth	; "
		add.w d0,fourth		; "

		moveq #0,d0		; and clear d0

_0_0		cmp.b #'*',(a0)		; test for '*'
		bne.s _0_1
		move.l #0,d0		; offset
		bsr plot_cube		; draw a block
_0_1		cmp.b #'*',1(a0)
		bne.s _0_2
		move.w second,d0
		bsr plot_cube
_0_2		cmp.b #'*',2(a0)
		bne.s _0_3
		move.w third,d0
		bsr plot_cube
_0_3		cmp.b #'*',3(a0)
		bne.s _1_0
		move.w fourth,d0
		bsr plot_cube
_1_0		cmp.b #'*',4(a0)
		bne.s _1_1
		move.l #160*8,d0	; next line	
		bsr plot_cube
_1_1		cmp.b #'*',5(a0)
		bne.s _1_2
		move.l #160*8,d0
		add.w second,d0
		bsr plot_cube
_1_2		cmp.b #'*',6(a0)
		bne.s _1_3
		move.l #160*8,d0
		add.w third,d0
		bsr plot_cube
_1_3		cmp.b #'*',7(a0)
		bne.s _2_0
		move.l #160*8,d0
		add.w fourth,d0
		bsr plot_cube
_2_0		cmp.b #'*',8(a0)
		bne.s _2_1
		move.l #160*16,d0	; next line
		bsr plot_cube
_2_1		cmp.b #'*',9(a0)
		bne.s _2_2
		move.l #160*16,d0
		add.w second,d0
		bsr plot_cube
_2_2		cmp.b #'*',10(a0)
		bne.s _2_3
		move.l #160*16,d0
		add.w third,d0
		bsr plot_cube
_2_3		cmp.b #'*',11(a0)
		bne.s _3_0
		move.l #160*16,d0
		add.w fourth,d0
		bsr plot_cube
_3_0		cmp.b #'*',12(a0)
		bne.s _3_1
		move.l #160*24,d0	; next line
		bsr plot_cube
_3_1		cmp.b #'*',13(a0)
		bne.s _3_2
		move.l #160*24,d0
		add.w second,d0
		bsr plot_cube
_3_2		cmp.b #'*',14(a0)
		bne.s _3_3
		move.l #160*24,d0
		add.w third,d0
		bsr plot_cube
_3_3		cmp.b #'*',15(a0)
		bne.s _exit
		move.l #160*24,d0
		add.w fourth,d0
 		bsr plot_cube
_exit		rts

plot_cube	move.l screen2,a2	; screen #2
		add.l address_offset,a2
		add.l d0,a2
		move.l current_colour,a3	; colour
xxx		set 0		
		rept 8			; block 8 lines high
		movep.l xxx(a3),d0
		movep.l d0,xxx(a2)
xxx		set xxx+160
		endr
		rts

*********************************************************************
*              Routine to draw the well onto the screen             *
*********************************************************************

place_well_grafix
	move.l screen1,a0	; screen #1
	move.l screen2,a1	; screen #2
	lea -8*160(a0),a0
	lea -8*160(a1),a1
	moveq.l #10,d0		; lines to copy!
	bsr dowell
	move.l screen1,a0	; screen #1
	move.l screen2,a1	; screen #2
	move.l #200,d0		; lines to copy!
	bsr dowell
	rts

dowell	lea wellpic+34,a2	; picture of well
do_well	move.l #12,d1		; 12 longs=96 pixels/4 planes
cruxy	move.l (a2),(a0)+	; send to screen
	move.l (a2)+,(a1)+	; and other screen
	subq.l #1,d1
	bne.s cruxy
	lea 112(a0),a0		; next line
	lea 112(a1),a1
	lea 112(a2),a2
	subq.l #1,d0		; loop around
	bne.s do_well
	rts

************************************************************************
*                 Routine to Draw the score panel frame                *
************************************************************************
	
place_panel
	move.l screen1,a0	; screen #1
	move.l screen2,a1	; screen #2
	lea 48+(160*68)(a0),a0	; normal screen+a bit
	lea 48+(160*68)(a1),a1
	lea score_pic+34+(33*160),a2	; panel grafix
	move.l #113,d0		; panel is 113 lines high (wow!)
do_panl	move.l #28,d1		; copy 28 longs=224 pixels/4 planes
panl	move.l (a2),(a0)+	; to screen #1
	move.l (a2)+,(a1)+	; and screen #2
	subq.l #1,d1
	bne.s panl
	lea 48(a0),a0		; next line
	lea 48(a1),a1
	lea 48(a2),a2
	subq.l #1,d0		; loop around
	bne.s do_panl
	rts

**********************************************************************
*    Routine to plot the credits in the top right of the screen      *
**********************************************************************

credits	lea wellpic+34+48+(8*160),a5
	move.l screen1,a6	; screen not being displayed!
	lea 48(a6),a6 	; add a bit
	bsr dump_creds
	move.l screen2,a6	; screen not being displayed!
	lea 48(a6),a6 	; add a bit
	bsr dump_creds
	rts

dump_creds
xxx	set 0
	rept 61
	move.l xxx(a5),xxx(a6)
	move.l xxx+4(a5),xxx+4(a6)
	move.l xxx+8(a5),xxx+8(a6)
	move.l xxx+12(a5),xxx+12(a6)
	move.l xxx+16(a5),xxx+16(a6)
	move.l xxx+20(a5),xxx+20(a6)
	move.l xxx+24(a5),xxx+24(a6)
	move.l xxx+28(a5),xxx+28(a6)
	move.l xxx+32(a5),xxx+32(a6)
	move.l xxx+36(a5),xxx+36(a6)
	move.l xxx+40(a5),xxx+40(a6)
	move.l xxx+44(a5),xxx+44(a6)
	move.l xxx+48(a5),xxx+48(a6)
	move.l xxx+52(a5),xxx+52(a6)
	move.l xxx+56(a5),xxx+56(a6)
	move.l xxx+60(a5),xxx+60(a6)
	move.l xxx+64(a5),xxx+64(a6)
	move.l xxx+68(a5),xxx+68(a6)
	move.l xxx+72(a5),xxx+72(a6)
	move.l xxx+76(a5),xxx+76(a6)
	move.l xxx+80(a5),xxx+80(a6)
	move.l xxx+84(a5),xxx+84(a6)
	move.l xxx+88(a5),xxx+88(a6)
	move.l xxx+92(a5),xxx+92(a6)
	move.l xxx+96(a5),xxx+96(a6)
	move.l xxx+100(a5),xxx+100(a6)
	move.l xxx+104(a5),xxx+104(a6)
	move.l xxx+108(a5),xxx+108(a6)
xxx	set xxx+160
	endr

	rts

**********************************************************************
*         Routine to send "text" to the bottom of the screen         *
**********************************************************************

; call with a0 address of grafix

line_out	
	move.l screen1,a1	; screen #1
	move.l screen2,a2	; screen #2
	add.l #(182*160)+48,a1	; plus normal offset
	add.l #(182*160)+48,a2	;
	move.l #9,d0		; nine lines high
line_sc	
xxx	set 0
	rept 28			; shift 224 pixels in 4 planes
	move.l xxx(a0),xxx(a1)
	move.l xxx(a0),xxx(a2)
xxx	set xxx+4
	endr
	lea 160(a0),a0		; next line
	lea 160(a1),a1
	lea 160(a2),a2
	subq.l #1,d0		; loop around
	bne line_sc
	rts

;; crap but working ikbd interupt

ikbd118	move.w d0,-(a7)		; uses D0
	move.b $fffffc02.w,d0	; pull data byte
	cmp.w #1,joytest	; is it a packet?
	beq.s .joy		; branch if yes!
	cmp.b #$ff,d0		; is it a packer header?
	bne.s .key		; branch if not
	move.w #1,joytest	; next incoming is packet data
	move.w (a7)+,d0
	bclr.b #6,$fffffa11.w
	rte
.key	move.b d0,lastkey	; this was a key!
	move.w (a7)+,d0
	bclr.b #6,$fffffa11.w
	rte
.joy	clr.w joytest		; clear packet flag
	btst #7,d0		; now test all the bits
	bne.s .not1
	move.b d0,prockey	; and save if needed
	move.w #-1,donelst	; set flag
.not1	btst #1,d0
	bne.s .not2
	move.b d0,prockey
	move.w #-1,donelst
.not2	btst #2,d0
	bne.s .not4
	move.b d0,prockey
	move.w #-1,donelst
.not4	btst #3,d0
	bne.s .not8
	move.w #-1,donelst
	move.b d0,prockey
.not8	cmp.b #$0,d0		; returned to centre?
	bne.s .exit
	tst.w donelst		; has last been processed
	bmi.s .exit
	move.b d0,prockey
.exit	move.w (a7)+,d0
	bclr.b #6,$fffffa11.w
	rte

button	dc.w 0
joytest	dc.w 0
lastjoy	dc.w 0
prockey	dc.w 0
donelst	dc.w 1

**********************************************************************
*               Routine to wait for space to be pressed              *
**********************************************************************

wait_space
	btst.b #7,prockey
	bne.s _rts_
	cmp.b #$39,lastkey	; $39 = space
	bne.s chk_qt
_rts_	rts
chk_qt	cmp.b #$10,lastkey	; $10 = 'q'
	bne.s wait_space
	bra term

**********************************************************************
*       Routine to make the table of number grafix pointers          *
**********************************************************************

make_num_table
	lea numtab,a0		; address of table
	lea score_pic+34,a1	; address of '0'
	move.l #10,d1		; 10 numbers (wow! never!)
add_tab	move.l a1,(a0)+		; copy address
	lea 16(a1),a1		; jump to next grafix
	subq.l #1,d1		; and loop
	bne.s add_tab
	rts

**********************************************************************
*    Routine to print a -ve terminated numeric string to screen      *
**********************************************************************

print_number
	lea numtab,a3		; points to table
	add.l screen1,a1	; points to screen #1
	add.l screen2,a2	; points to screen #2
	moveq.l #0,d1
pr_loop	move.b (a0)+,d1		; pull character			
	bmi bogoff		; get out if ended
	sub.b #'0',d1		; convert to numeric
	add d1,d1
	add d1,d1
	move.l (a3,d1),a4	; pointer to character grfx
	bsr plot_a_number	; plot the grafix
	lea 16(a1),a1		; and jump to next space
	lea 16(a2),a2
	bra pr_loop		; loop around
bogoff	rts		

plot_a_number
xxx	set 0
	rept 32			; copy 32x32 numeral to screen
	movem.l xxx(a4),d2-5
	movem.l d2-5,xxx(a1)
	movem.l d2-5,xxx(a2)
xxx	set xxx+160
	endr
	rts	

*********************************************************************
*  Routines to check if the score / level numbers have overflowed   *
*********************************************************************

check_overflow_score
	cmp.l #'999:',score	; check for 9999 wrap
	bne.s .1
	move.l #'0000',score
	addq.b #1,score-1
	cmp.b #':',score-1
	bne.s .1
	move.b #'0',score-1
	addq.b #1,score-2
	cmp.b #':',score-2
	bne.s .2
	move.b #'0',score-2

.1	cmp.b #':',score+3	; check for units wrap
	bne.s .2
	move.b #'0',score+3
	addq.b #1,score+2
	cmp.b #':',score+2	; check for 10's wrap
	bne.s .2
	move.b #'0',score+2
	addq.b #1,score+1	
	cmp.b #':',score+1	; check for 100's wrap
	bne.s .2
	move.b #'0',score+1
	addq.b #1,score
.2	rts

check_overflow_level
	cmp.b #':',level+1	; overflow
	bne.s .2
	move.b #'0',level+1
	addq.b #1,level
.2	cmp.b #'/',level+1	; underflow(?)
	bne.s .3
	move.b #'9',level+1
	subq.b #1,level
.3	rts

kill_fa15	dc.w 1
**********************************************************************
*                   The Vertical Blanking Routine                    *
**********************************************************************
	
vbl	movem.l d0-a6,-(a7)
	bsr process_bounce

	move.b 	screen1+1,$ffff8201.w	; Set new screen
	move.b 	screen1+2,$ffff8203.w

	tst.w kill_fa15
	bmi.s .set120
	bclr.b #5,$fffffa15.w			; kill timer c
	neg.w kill_fa15

.set120	move.l #hbl,$120.w
	clr.w lines
	move.l #rasters,rastptr

	move.b #4,$fffffa21.w
	move.b #8,$fffffa1b.w

	movem.l score_pic+2,d0-7
	movem.l d0-7,$ffff8240.w

	jsr tracking_vbl

	addq.w #1,random_piece		; Random Piece update
	move.w block_num,d0
	cmp.w random_piece,d0
	bne.s .out
	move.w #0,random_piece
.out	addq.w 	#1,vbl_done		; All systems go!
	move.w next_x,d0
	add.w d0,x_off
	move.w next_x1,next_x
	move.w d0,next_x1
	addq.w #1,rand_x		; random piece for arcade level
	cmp.w #11,rand_x
	bne.s ._y
	move.w #1,rand_x
	move.w #7,next_x
	move.w #1,next_x1
	move.w #1,x_off
._y	addq.w #1,rand_y
	cmp.w #21,rand_y
	bne.s ._m
	move.w #10,rand_y

._m	tst.w do_mus
	bmi.s .doing_sam
	jsr music+6
.doing_sam
	movem.l	(a7)+,d0-a6 
	rte

block_num	dc.w 7

doing_sprites	dc.w 1

ncol		dc.w 0

hbl		waitline
		move.w ncol,$ffff8240.w	; copy to background colour
		move.l a0,-(a7)
		move.l rastptr,a0
		move.w (a0)+,ncol	; next colour to copy
		move.l a0,rastptr
		move.l (a7)+,a0
		addq.w #1,lines
		cmp.w #199/4,lines	; bottom border next?
		bne out

		clr.w ncol		; yes! clear background colour
q		move.w copyrite+2+2,$ffff8242.w	; font pallette
xx		set 4
		rept 3
		move.l copyrite+2+xx,$ffff8240+xx.w
xx		set xx+4
		endr

qq		waitline
		clr.w $ffff8240.w
xx		set 16
		rept 4
		move.l copyrite+2+xx,$ffff8240+xx.w
xx		set xx+4
		endr
ww		waitline

		movem.l a0/d0,-(a7)
		move.w #$fa21,a0
		move.b (a0),d0
hangtheraster	cmp.b (a0),d0
		beq.s hangtheraster
        	clr.b $ffff820a.w     	; 60 Hz
        	moveq #3,d0
.2     		nop                 	; wait a while
        	dbf d0,.2
		move.b #2,$ffff820a.w  	; 50 Hz
		clr.w $ffff8240.w
		movem.l (a7)+,a0/d0
		move.l #.blk,$120.w	; next hbl kills itself!
	        bclr #0,$fffffa0f.w  	; end of interrupt 
	        rte
.blk		move.b #0,$fffffa1b.w	; kill hbl interupts
		move.l #out,$120.w	; just in case.....

out		bclr #0,$fffffa0f.w  	; end of interrupt 
	        rte


lines		dc.w 0			; current scanline
rastptr		dc.l rasters		; pointer to colours
rasters		incbin beebris.pal	; the colours
		even

; ----------------- constant / variable / buffer list ------------------

ascii		ds.l 64		; font table (movep)
		dc.b "00"	; extra score digits
score		dc.b "0000",-1,-1 ; player score
level		dc.b "00",-1,-1	  ; player level
levspd		dc.l 9		; current level speed
start_y		ds.w 1		; starting height (from top)
lines_done	ds.w 1		; number of lines made this level
speed		ds.l 1		; drop speed in frames
drops		ds.w 1		; number of drops made this piece
line_dn		ds.w 1		; flag for line made or not
on_screen	ds.l 1		; address of screen of  made line
roller		dc.w 118	; number of rolls left in credits
rolpos		dc.l wellpic+34+(9*160)+48	; pointer to roll grafix
well_x		ds.w 1		; x into ascii table
well_y		ds.w 1		; y into ascii table
start_offset	ds.l 1		; vertical distance
address_offset	ds.l 1		; x/y combination into screen
numtab		ds.l 10		; table of address of number grafix
next_add	ds.l 1		; going right addition used with MOVEP
next_sub	ds.l 1		; going left addition used with MOVEP
wibble		ds.l 1		; pointer used with the screen buffer
second		ds.w 1		; offset #1 for MOVEP plotter
third		ds.w 1		; offset #2 for MOVEP plotter
fourth		ds.w 1		; offset #3 for MOVEP plotter
screen1		ds.l 1		; address of screen #1
screen2		ds.l 1		; address of screen #2
goes		ds.w 1		; flag used in line checking
dumper		ds.w 1		; used to clear ikbd bytes
vbl_done	ds.w 1		; vbl-sync flag
savbuff		ds.l 12*32	; grafix data under current piece	
random_piece	ds.w 1		; pseudo random counter
current_piece	ds.l 1		; address of current piece tables
next_shape	ds.l 1		; just for Andy.....
current_rot	dc.w 0		; rotational value (0,4,8 or 12)
current_drops	ds.w 1		; fast drops so far
scoretab	dc.w 0,10,50	; score for 1,2,3 or 4 lines!
		dc.w 100,200

************************************************************************
*    Attribute table for current piece - must be left in this order    *
************************************************************************
		
width		ds.w 1		;; width of current shape
height		ds.w 1		;; height of current shape
character	ds.l 4		;; positional *'s of current shape
chk1		ds.l 5		;; table of lower co-ordinates
lft1		ds.l 5		;; table of left co-ordinates
rgh1		ds.l 5		;; table of right co-ordinates
rot1		ds.l 5		;; table of next rotation co-ordinates
current_colour	ds.l 1		;; address of block
first_rotate	ds.l 1		;; co-ords of first rotation

************************************************************************
******************** Beebris Data Tables Here.. ************************
************************************************************************

piece_table	dc.l bl1,bl2,bl3,bl4,bl5,bl6,bl7 ; original shapes (classic)
		dc.l bl8,bl9,bla,blb,blc,bld,ble ; new shapes (future-ver)
	
bl1		dc.l b1r1,b1r2,b1r1,b1r2	; rotation pointers
b1r1		dc.w 1,3			; width, height
		dc.b " *  "
		dc.b " *  "
		dc.b " *  "
		dc.b " *  "
		dc.w 1,4			; x/y offset to check
		dc.w 1,4			; the bottoms
		dc.w 1,4
		dc.w 1,4
		dc.w 1,4
		dc.w 0,0			; x/y offset to check
		dc.w 0,0			; the lefts			
		dc.w 0,1
		dc.w 0,2
		dc.w 0,3
		dc.w 2,0			; x/y offset to check
		dc.w 2,1			; the rights
		dc.w 2,1			
		dc.w 2,2
		dc.w 2,3
		dc.w 0,0			; the co-ordinates of
		dc.w 1,0			; the next rotation of
		dc.w 1,0			; this shape			
		dc.w 2,0
		dc.w 3,0
		dc.l wellpic+34+136		; address of block (col) 

b1r2		dc.w 3,0			; width, height
		dc.b "****"
		dc.b "    "
		dc.b "    "
		dc.b "    "
		dc.w 0,1			; x/y offset to check
		dc.w 1,1			; the bottoms
		dc.w 2,1
		dc.w 3,1
		dc.w 3,1
		dc.w -1,0			; x/y offsets to check
		dc.w -1,0			; the lefts
		dc.w -1,0
		dc.w -1,0
		dc.w -1,0
		dc.w 4,0			; x/y offsets to check
		dc.w 4,0			; the rights
		dc.w 4,0
		dc.w 4,0
		dc.w 4,0
		dc.w 1,0			; co-ordinates of
		dc.w 1,1			; next rotation
		dc.w 1,2
		dc.w 1,3
		dc.w 1,3
		dc.l wellpic+34+136

bl2		dc.l b2r1,b2r2,b2r3,b2r4
b2r1		dc.w 2,2			; width, height
		dc.b " *  "
		dc.b " ** "
		dc.b " *  "
		dc.b "    "
		dc.w 1,3			; x/y offset to check
		dc.w 2,2			; the bottoms
		dc.w 2,2
		dc.w 2,2
		dc.w 2,2
		dc.w 0,0			; x/y offset to check
		dc.w 0,1			; the lefts
		dc.w 0,2
		dc.w 0,2
		dc.w 0,2
		dc.w 2,0			; x/y offset to check
		dc.w 3,1			; the rights
		dc.w 2,2
		dc.w 2,2
		dc.w 2,2
		dc.w 1,1			; the co-ordinates of
		dc.w 0,2			; the next rotation of
		dc.w 1,2			; this shape
		dc.w 2,2
		dc.w 2,2
		dc.l wellpic+34+136

b2r2		dc.w 3,2			; width, height
		dc.b "    "
		dc.b " *  "
		dc.b "*** "
		dc.b "    "
		dc.w 0,3			; x/y offset to check
		dc.w 1,3			; the bottoms
		dc.w 2,3
		dc.w 2,3
		dc.w 2,3
		dc.w 0,1			; x/y offset to check
		dc.w -1,2			; the lefts
		dc.w -1,2
		dc.w -1,2
		dc.w -1,2
		dc.w 2,1			; x/y offset to check
		dc.w 3,2			; the rights
		dc.w 3,2
		dc.w 3,2
		dc.w 3,2
		dc.w 2,0			; the co-ordinates of
		dc.w 1,1			; the next rotation of
		dc.w 2,1			; this shape
		dc.w 2,2
		dc.w 2,2
		dc.l wellpic+34+136

b2r3		dc.w 2,2			; width, height
		dc.b "  * "
		dc.b " ** "
		dc.b "  * "
		dc.b "    "
		dc.w 1,2			; x/y offset to check
		dc.w 2,3			; the bottoms
		dc.w 2,3
		dc.w 2,3
		dc.w 2,3
		dc.w 1,0			; x/y offset to check
		dc.w 0,1			; the lefts
		dc.w 1,2
		dc.w 1,2
		dc.w 1,2
		dc.w 3,0			; x/y offset to check
		dc.w 3,1			; the rights
		dc.w 3,2
		dc.w 3,2
		dc.w 3,2
		dc.w 0,0			; the co-ordinates of
		dc.w 1,0			; the next rotation of
		dc.w 2,0			; this shape
		dc.w 1,1
		dc.w 1,1
		dc.l wellpic+34+136

b2r4		dc.w 3,1			; width, height
		dc.b "*** "
		dc.b " *  "
		dc.b "    "
		dc.b "    "
		dc.w 0,1			; x/y offset to check
		dc.w 1,2			; the bottoms
		dc.w 2,1
		dc.w 2,1
		dc.w 2,1
		dc.w -1,0			; x/y offset to check
		dc.w 0,1			; the lefts
		dc.w 0,1
		dc.w 0,1
		dc.w 0,1
		dc.w 3,0			; x/y offset to check
		dc.w 2,1			; the rights
		dc.w 2,1
		dc.w 2,1
		dc.w 2,1
		dc.w 1,0			; the co-ordinates of
		dc.w 1,1			; the next rotation of
		dc.w 2,1			; this shape
		dc.w 1,2
		dc.w 1,2
		dc.l wellpic+34+136

bl3		dc.l b3r1,b3r1,b3r1,b3r1
b3r1		dc.w 2,1			; width, height
		dc.b " ** "
		dc.b " ** "
		dc.b "    "
		dc.b "    "
		dc.w 1,2			; x/y offset to check
		dc.w 2,2			; the bottoms
		dc.w 2,2
		dc.w 2,2
		dc.w 2,2
		dc.w 0,0			; x/y offset to check
		dc.w 0,1			; the lefts
		dc.w 0,1
		dc.w 0,1
		dc.w 0,1
		dc.w 3,0			; x/y offset to check
		dc.w 3,1			; the rights
		dc.w 3,1
		dc.w 3,1
		dc.w 3,1
		dc.w 1,0			; the co-ordinates of
		dc.w 2,0			; the next rotation of
		dc.w 1,1			; this shape
		dc.w 2,1
		dc.w 2,1
		dc.l wellpic+34+137

bl4		dc.l b4r1,b4r2,b4r1,b4r2
b4r1		dc.w 2,1			; width, height
		dc.b " ** "
		dc.b "**  "
		dc.b "    "
		dc.b "    "
		dc.w 0,2			; x/y offset to check
		dc.w 1,2			; the bottoms
		dc.w 2,1
		dc.w 2,1
		dc.w 2,1
		dc.w 0,0			; x/y offset to check
		dc.w -1,1			; the lefts
		dc.w 0,0
		dc.w 0,0
		dc.w 0,0
		dc.w 3,0			; x/y offset to check
		dc.w 2,1			; the rights
		dc.w 2,1
		dc.w 2,1
		dc.w 2,1
		dc.w 1,0			; the co-ordinates of
		dc.w 1,1			; the next rotation of
		dc.w 2,1			; this shape
		dc.w 2,2
		dc.w 2,2
		dc.l wellpic+34+144

b4r2		dc.w 2,2			; width, height
		dc.b " *  "
		dc.b " ** "
		dc.b "  * "
		dc.b "    "
		dc.w 1,2			; x/y offset to check
		dc.w 2,3			; the bottoms
		dc.w 2,3
		dc.w 2,3
		dc.w 2,3
		dc.w 0,0			; x/y offset to check
		dc.w 0,1			; the lefts
		dc.w 1,2
		dc.w 1,2
		dc.w 1,2
		dc.w 2,0			; x/y offset to check
		dc.w 3,1			; the rights
		dc.w 3,2
		dc.w 3,2
		dc.w 3,2
		dc.w 1,0			; the co-ordinates of
		dc.w 2,0			; the next rotation of
		dc.w 0,1			; this shape
		dc.w 1,1
		dc.w 1,1
		dc.l wellpic+34+144

bl5		dc.l b5r1,b5r2,b5r1,b5r2
b5r1		dc.w 2,1			; width, height
		dc.b "**  "
		dc.b " ** "
		dc.b "    "
		dc.b "    "
		dc.w 0,1			; x/y offset to check
		dc.w 1,2			; the bottoms
		dc.w 2,2
		dc.w 2,2
		dc.w 2,2
		dc.w -1,0			; x/y offset to check
		dc.w 0,1			; the lefts
		dc.w 0,1
		dc.w 0,1
		dc.w 0,1
		dc.w 2,0			; x/y offset to check
		dc.w 3,1			; the rights
		dc.w 3,1
		dc.w 3,1
		dc.w 3,1
		dc.w 1,0			; the co-ordinates of
		dc.w 0,1			; the next rotation of
		dc.w 1,1			; this shape
		dc.w 0,2
		dc.w 0,2
		dc.l wellpic+34+145

b5r2		dc.w 2,1			; width, height
		dc.b " *  "
		dc.b "**  "
		dc.b "*   "
		dc.b "    "
		dc.w 0,3			; x/y offset to check
		dc.w 1,2			; the bottoms
		dc.w 1,2
		dc.w 1,2
		dc.w 1,2
		dc.w 0,0			; x/y offset to check
		dc.w -1,1			; the lefts
		dc.w -1,2
		dc.w -1,2
		dc.w -1,2
		dc.w 2,0			; x/y offset to check
		dc.w 2,1			; the rights
		dc.w 1,2
		dc.w 1,2
		dc.w 1,2
		dc.w 0,0			; the co-ordinates of
		dc.w 1,0			; the next rotation of
		dc.w 1,1			; this shape
		dc.w 2,1
		dc.w 2,1
		dc.l wellpic+34+145

bl6		dc.l b6r1,b6r2,b6r3,b6r4
b6r1		dc.w 2,1			; width, height
		dc.b "*** "
		dc.b "*   "
		dc.b "    "
		dc.b "    "
		dc.w 0,2			; x/y offset to check
		dc.w 1,1			; the bottoms
		dc.w 2,1
		dc.w 2,1
		dc.w 2,1
		dc.w -1,0			; x/y offset to check
		dc.w -1,1			; the lefts
		dc.w -1,1
		dc.w -1,1
		dc.w -1,1
		dc.w 3,0			; x/y offset to check
		dc.w 1,1			; the rights
		dc.w 1,1
		dc.w 1,1
		dc.w 1,1
		dc.w 0,0			; the co-ordinates of
		dc.w 0,1			; the next rotation of
		dc.w 0,2			; this shape
		dc.w 1,2
		dc.w 1,2
		dc.l wellpic+34+152

b6r2		dc.w 2,1			; width, height
		dc.b "*   "
		dc.b "*   "
		dc.b "**  "
		dc.b "    "
		dc.w 0,3			; x/y offset to check
		dc.w 1,3			; the bottoms
		dc.w 1,3
		dc.w 1,3
		dc.w 1,3
		dc.w -1,0			; x/y offset to check
		dc.w -1,1			; the lefts
		dc.w -1,2
		dc.w -1,2
		dc.w -1,2
		dc.w 1,0			; x/y offset to check
		dc.w 1,1			; the rights
		dc.w 2,2
		dc.w 2,2
		dc.w 2,2
		dc.w 2,1			; the co-ordinates of
		dc.w 2,2			; the next rotation of
		dc.w 1,2			; this shape
		dc.w 0,2
		dc.w 0,2
		dc.l wellpic+34+152

b6r3		dc.w 2,1			; width, height
		dc.b "    "
		dc.b "  * "
		dc.b "*** "
		dc.b "    "
		dc.w 0,3			; x/y offset to check
		dc.w 1,3			; the bottoms
		dc.w 2,3
		dc.w 2,3
		dc.w 2,3
		dc.w 1,1			; x/y offset to check
		dc.w -1,2			; the lefts
		dc.w -1,2
		dc.w -1,2
		dc.w -1,2
		dc.w 3,1			; x/y offset to check
		dc.w 3,1			; the rights
		dc.w 3,2
		dc.w 3,2
		dc.w 3,2
		dc.w 0,0			; the co-ordinates of
		dc.w 1,0			; the next rotation of
		dc.w 1,1			; this shape
		dc.w 1,2
		dc.w 1,2
		dc.l wellpic+34+152

b6r4		dc.w 2,1			; width, height
		dc.b "**  "
		dc.b " *  "
		dc.b " *  "
		dc.b "    "
		dc.w 0,1			; x/y offset to check
		dc.w 1,3			; the bottoms
		dc.w 1,3
		dc.w 1,3
		dc.w 1,3
		dc.w -1,0			; x/y offset to check
		dc.w 0,1			; the lefts
		dc.w 0,2
		dc.w 0,2
		dc.w 0,2
		dc.w 2,0			; x/y offset to check
		dc.w 2,1			; the rights
		dc.w 2,2
		dc.w 2,2
		dc.w 2,2
		dc.w 0,0			; the co-ordinates of
		dc.w 1,0			; the next rotation of
		dc.w 2,0			; this shape
		dc.w 0,1
		dc.w 0,1
		dc.l wellpic+34+152

bl7		dc.l b7r1,b7r2,b7r3,b7r4
b7r1		dc.w 2,1			; width, height
		dc.b "    "
		dc.b "*   "
		dc.b "*** "
		dc.b "    "
		dc.w 0,3			; x/y offset to check
		dc.w 1,3			; the bottoms
		dc.w 2,3
		dc.w 2,3
		dc.w 2,3
		dc.w -1,1			; x/y offset to check
		dc.w -1,2			; the lefts
		dc.w -1,2
		dc.w -1,2
		dc.w -1,2
		dc.w 1,1			; x/y offset to check
		dc.w 3,2			; the rights
		dc.w 3,2
		dc.w 3,2
		dc.w 3,2
		dc.w 2,0			; the co-ordinates of
		dc.w 2,1			; the next rotation of
		dc.w 2,2			; this shape
		dc.w 1,2
		dc.w 1,2
		dc.l wellpic+34+153

b7r2		dc.w 2,1			; width, height
		dc.b "  * "
		dc.b "  * "
		dc.b " ** "
		dc.b "    "
		dc.w 1,3			; x/y offset to check
		dc.w 2,3			; the bottoms
		dc.w 2,3
		dc.w 2,3
		dc.w 2,3
		dc.w 0,2			; x/y offset to check
		dc.w 1,0			; the lefts
		dc.w 1,1
		dc.w 1,1
		dc.w 1,1
		dc.w 3,0			; x/y offset to check
		dc.w 3,1			; the rights
		dc.w 3,2
		dc.w 3,2
		dc.w 3,2
		dc.w 0,0			; the co-ordinates of
		dc.w 1,0			; the next rotation of
		dc.w 2,0			; this shape
		dc.w 2,1
		dc.w 2,1
		dc.l wellpic+34+153

b7r3		dc.w 2,1			; width, height
		dc.b "*** "
		dc.b "  * "
		dc.b "    "
		dc.b "    "
		dc.w 0,1			; x/y offset to check
		dc.w 1,1			; the bottoms
		dc.w 2,2
		dc.w 2,2
		dc.w 2,2
		dc.w -1,0			; x/y offset to check
		dc.w 1,1			; the lefts
		dc.w 1,1
		dc.w 1,1
		dc.w 1,1
		dc.w 3,0			; x/y offset to check
		dc.w 3,1			; the rights
		dc.w 3,1
		dc.w 3,1
		dc.w 3,1
		dc.w 0,0			; the co-ordinates of
		dc.w 1,0			; the next rotation of
		dc.w 0,1			; this shape
		dc.w 0,2
		dc.w 0,2
		dc.l wellpic+34+153

b7r4		dc.w 2,1			; width, height
		dc.b "**  "
		dc.b "*   "
		dc.b "*   "
		dc.b "    "
		dc.w 0,3			; x/y offset to check
		dc.w 1,1			; the bottoms
		dc.w 1,1
		dc.w 1,1
		dc.w 1,1
		dc.w -1,0			; x/y offset to check
		dc.w -1,1			; the lefts
		dc.w -1,2
		dc.w -1,2
		dc.w -1,2
		dc.w 2,0			; x/y offset to check
		dc.w 1,1			; the rights
		dc.w 1,2
		dc.w 1,2
		dc.w 1,2
		dc.w 0,1			; the co-ordinates of
		dc.w 0,2			; the next rotation of
		dc.w 1,2			; this shape
		dc.w 2,2
		dc.w 2,2
		dc.l wellpic+34+153

;;;;;;;;;;;; the new pieces are from here down ;;;;;;;;;;;;;;;

bl8		dc.l b8r1,b8r1,b8r1,b8r1
b8r1		dc.w 2,1			; skip header
		dc.b " *  "
		dc.b "*** "
		dc.b " *  "
		dc.b "    "
		dc.w 0,2			; bottoms
		dc.w 1,3
		dc.w 2,2
		dc.w 1,1
		dc.w 0,0
		dc.w 0,0			; lefts
		dc.w -1,1
		dc.w 0,2
		dc.w 1,1
		dc.w 0,2
		dc.w 2,0			; rights
		dc.w 1,1
		dc.w 3,1
		dc.w 2,2
		dc.w 2,2
		dc.w 1,0			; next rot
		dc.w 0,1
		dc.w 2,1
		dc.w 1,2
		dc.w 1,1
		dc.l wellpic+34+136

bl9		dc.l b9r1,b9r2,b9r3,b9r4
b9r1		dc.w 2,1			; skip header
		dc.b "* * "
		dc.b "*** "
		dc.b "    "
		dc.b "    "
		dc.w 0,2			; bottoms
		dc.w 1,2
		dc.w 2,2
		dc.w 2,2
		dc.w 2,2
		dc.w -1,0			; lefts
		dc.w -1,1
		dc.w -1,1
		dc.w -1,1
		dc.w -1,1
		dc.w 3,0			; rights
		dc.w 3,1
		dc.w 3,1
		dc.w 3,1
		dc.w 3,1
		dc.w 1,0			; next rot
		dc.w 2,0
		dc.w 2,1
		dc.w 2,2
		dc.w 1,2
		dc.l wellpic+34+137

b9r2		dc.w 2,1			; skip header
		dc.b " ** "
		dc.b "  * "
		dc.b " ** "
		dc.b "    "
		dc.w 1,3			; bottoms
		dc.w 2,3
		dc.w 2,3
		dc.w 2,3
		dc.w 2,3
		dc.w 0,0			; lefts
		dc.w 1,1
		dc.w 0,2
		dc.w 0,2
		dc.w 0,2
		dc.w 3,0			; rights
		dc.w 3,1
		dc.w 3,2
		dc.w 3,1
		dc.w 3,1
		dc.w 0,0			; next rot
		dc.w 1,0
		dc.w 2,0
		dc.w 0,1
		dc.w 2,1
		dc.l wellpic+34+137

b9r3		dc.w 2,1			; skip header
		dc.b "*** "
		dc.b "* * "
		dc.b "    "
		dc.b "    "
		dc.w 0,2			; bottoms
		dc.w 1,1
		dc.w 2,2
		dc.w 2,2
		dc.w 2,2
		dc.w -1,0			; lefts
		dc.w -1,1
		dc.w -1,1
		dc.w -1,1
		dc.w -1,1
		dc.w 3,0			; rights
		dc.w 3,1
		dc.w 3,1
		dc.w 3,1
		dc.w 3,1
		dc.w 0,0			; next rot
		dc.w 1,0
		dc.w 0,1
		dc.w 0,2
		dc.w 1,2
		dc.l wellpic+34+137

b9r4		dc.w 2,1			; skip header
		dc.b "**  "
		dc.b "*   "
		dc.b "**  "
		dc.b "    "
		dc.w 0,3			; bottoms
		dc.w 1,3
		dc.w 1,3
		dc.w 1,3
		dc.w 1,3
		dc.w -1,0			; lefts
		dc.w -1,1
		dc.w -1,2
		dc.w -1,1
		dc.w -1,1
		dc.w 2,0			; rights
		dc.w 1,1
		dc.w 2,2
		dc.w 2,2
		dc.w 2,2
		dc.w 0,0			; next rot
		dc.w 0,1
		dc.w 1,1
		dc.w 2,1
		dc.w 2,0
		dc.l wellpic+34+137

bla		dc.l bar1,bar2,bar1,bar2
bar1		dc.w 2,1			; skip header
		dc.b "  * "
		dc.b " *  "
		dc.b "*   "
		dc.b "    "
		dc.w 0,3			; bottoms
		dc.w 1,2
		dc.w 2,1
		dc.w 2,1
		dc.w 2,1
		dc.w 1,0			; lefts
		dc.w 0,1
		dc.w -1,2
		dc.w -1,2
		dc.w -1,2
		dc.w 3,0			; rights
		dc.w 2,1
		dc.w 1,2
		dc.w 1,2
		dc.w 1,2
		dc.w 0,0			; next rot
		dc.w 1,1
		dc.w 2,2
		dc.w 2,2
		dc.w 2,2
		dc.l wellpic+34+144

bar2		dc.w 2,1			; skip header
		dc.b "*   "
		dc.b " *  "
		dc.b "  * "
		dc.b "    "
		dc.w 0,1			; bottoms
		dc.w 1,2
		dc.w 2,3
		dc.w 2,3
		dc.w 2,3
		dc.w -1,0			; lefts
		dc.w 0,1
		dc.w 1,2
		dc.w 1,2
		dc.w 1,2
		dc.w 1,0			; rights
		dc.w 2,1
		dc.w 3,2
		dc.w 3,2
		dc.w 3,2
		dc.w 2,0			; next rot
		dc.w 1,1
		dc.w 0,2
		dc.w 0,2
		dc.w 0,2
		dc.l wellpic+34+144

blb		dc.l bbr1,bbr2,bbr1,bbr2
bbr1		dc.w 2,1			; skip header
		dc.b "**  "
		dc.b " *  "
		dc.b " ** "
		dc.b "    "
		dc.w 0,1			; bottoms
		dc.w 1,3
		dc.w 2,3
		dc.w 2,3
		dc.w 2,3
		dc.w -1,0			; lefts
		dc.w 0,1
		dc.w 0,2
		dc.w 0,2
		dc.w 0,2
		dc.w 2,0			; rights
		dc.w 2,1
		dc.w 3,2
		dc.w 3,2
		dc.w 3,2
		dc.w 2,0			; next rot
		dc.w 0,1
		dc.w 1,1
		dc.w 2,1
		dc.w 0,2
		dc.l wellpic+34+145

bbr2		dc.w 2,1			; skip header
		dc.b "  * "
		dc.b "*** "
		dc.b "*   "
		dc.b "    "
		dc.w 0,3			; bottoms
		dc.w 1,2
		dc.w 2,2
		dc.w 2,2
		dc.w 2,2
		dc.w 1,0			; lefts
		dc.w -1,1
		dc.w -1,2
		dc.w -1,2
		dc.w -1,2
		dc.w 3,0			; rights
		dc.w 3,1
		dc.w 1,2
		dc.w 1,2
		dc.w 1,2
		dc.w 0,0			; next rot
		dc.w 1,0
		dc.w 1,1
		dc.w 1,2
		dc.w 2,2
		dc.l wellpic+34+145

blc		dc.l bcr1,bcr2,bcr1,bcr2
bcr1		dc.w 2,1			; skip header
		dc.b " *  "
		dc.b "*   "
		dc.b "    "
		dc.b "    "
		dc.w 0,2			; bottoms
		dc.w 1,1
		dc.w 1,1
		dc.w 1,1
		dc.w 1,1
		dc.w 0,0			; lefts
		dc.w -1,1
		dc.w -1,1
		dc.w -1,1
		dc.w -1,1
		dc.w 2,0			; rights
		dc.w 1,1
		dc.w 1,1
		dc.w 1,1
		dc.w 1,1
		dc.w 0,0			; next rot
		dc.w 1,1
		dc.w 1,1
		dc.w 1,1
		dc.w 1,1
		dc.l wellpic+34+152

bcr2		dc.w 2,1			; skip header
		dc.b "*   "
		dc.b " *  "
		dc.b "    "
		dc.b "    "
		dc.w 0,1			; bottoms
		dc.w 1,2
		dc.w 1,2
		dc.w 1,2
		dc.w 1,2
		dc.w -1,0			; lefts
		dc.w 0,1
		dc.w 0,1
		dc.w 0,1
		dc.w 0,1
		dc.w 1,0			; rights
		dc.w 2,1
		dc.w 2,1
		dc.w 2,1
		dc.w 2,1
		dc.w 1,0			; next rot
		dc.w 0,1
		dc.w 0,1
		dc.w 0,1
		dc.w 0,1
		dc.l wellpic+34+152

bld		dc.l bdr1,bdr1,bdr1,bdr1
bdr1		dc.w 2,1			; skip header
		dc.b "*   "
		dc.b "    "
		dc.b "    "
		dc.b "    "
		dc.w 0,1			; bottoms
		dc.w 0,1
		dc.w 0,1
		dc.w 0,1
		dc.w 0,1
		dc.w -1,0			; lefts
		dc.w -1,0
		dc.w -1,0
		dc.w -1,0
		dc.w -1,0
		dc.w 1,0			; rights
		dc.w 1,0
		dc.w 1,0
		dc.w 1,0
		dc.w 1,0
		dc.w 0,0			; next rot
		dc.w 0,0
		dc.w 0,0
		dc.w 0,0
		dc.w 0,0
		dc.l wellpic+34+153

ble		dc.l ber1,ber2,ber1,ber2
ber1		dc.w  2,1			; skip header
		dc.b " ** "
		dc.b " *  "
		dc.b "**  "
		dc.b "    "
		dc.w 0,3			; bottoms
		dc.w 1,3
		dc.w 2,1
		dc.w 2,1
		dc.w 2,1
		dc.w 0,0			; lefts
		dc.w 0,1
		dc.w -1,2
		dc.w -1,2
		dc.w -1,2
		dc.w 3,0			; rights
		dc.w 2,1
		dc.w 2,2
		dc.w 2,2
		dc.w 2,2
		dc.w 0,0			; next rot
		dc.w 0,1
		dc.w 1,1
		dc.w 2,1
		dc.w 2,2
		dc.l wellpic+34+136

ber2		dc.w  2,1			; skip header
		dc.b "*   "
		dc.b "*** "
		dc.b "  * "
		dc.b "    "
		dc.w 0,2			; bottoms
		dc.w 1,2
		dc.w 2,3
		dc.w 2,3
		dc.w 2,3
		dc.w -1,0			; lefts
		dc.w -1,1
		dc.w 1,2
		dc.w 1,2
		dc.w 1,2
		dc.w 1,0			; rights
		dc.w 3,1
		dc.w 3,2
		dc.w 3,2
		dc.w 3,2
		dc.w 1,0			; next rot
		dc.w 2,0
		dc.w 1,1
		dc.w 1,2
		dc.w 0,2
		dc.l wellpic+34+136

; ------------------------ The Well! In Ascii form ---------------------

		dc.b "*          *"		; these top four
		dc.b "*          *"		; rows are to fix
		dc.b "*          *"		; a bug without
		dc.b "*          *"		; a major re-write!
well		dc.b "*          *"	
		dc.b "*          *"	
		dc.b "*          *"	
		dc.b "*          *"	
		dc.b "*          *"	
		dc.b "*          *"	
		dc.b "*          *"	
		dc.b "*          *"	
		dc.b "*          *"	
		dc.b "*          *"	
		dc.b "*          *"	
		dc.b "*          *"	
		dc.b "*          *"	
		dc.b "*          *"	
		dc.b "*          *"	
		dc.b "*          *"	
		dc.b "*          *"	
		dc.b "*          *"	
		dc.b "*          *"	
		dc.b "*          *"	
		dc.b "*          *"	
		dc.b "*          *"	
well_bot	dc.b "*          *"	
		dc.b "************"
		even

wellpic		incbin tetwell.pi1		; the well+credits
		even
score_pic	incbin scores_2.pi1		; the numerals + panel
		even
current_mus	dc.w 1
music		incbin awesome1.cz
		even
copyrite	incbin copyrite.pi1
		even
samplay		incbin msc_spl.exe
		even
sam1		incbin linemade.spl
sam1end		even
sam2		incbin oooo.spl
sam2end		even
sam3		incbin gameover.spl
sam3end		even
sam4		incbin jingle.spl
sam4end		even

tracking_init
	lea copyrite+34+(26*160),a0
	lea screen+(160*122),a1
	move.l #(20*160)/4,d0
toscr	move.l (a0)+,(a1)+
	subq.l #1,d0
	bne.s toscr

	lea logrout,a1

	lea screen+(160*122),a0		' B
	lea screen,a2
	bsr copy_it
	lea beeb_b,a2
	bsr make_routs
	bsr killtop

	lea screen+(160*122)+8,a0	' E
	lea screen,a2
	bsr copy_it
	lea beeb_e,a2
	bsr make_routs
	bsr killtop

	lea screen+(160*122)+16,a0	' R
	lea screen,a2
	bsr copy_it
	lea beeb_r,a2
	bsr make_routs
	bsr killtop

	lea screen+(160*122)+24,a0	' I
	lea screen,a2
	bsr copy_it
	lea beeb_i,a2
	bsr make_routs
	bsr killtop

	lea screen+(160*122)+32,a0	' S
	lea screen,a2
	bsr copy_it
	lea beeb_s,a2
	bsr make_routs
	bsr killtop

	rts

killtop	lea screen,a0			; erase the to of the screen!
	lea screen+(121*160),a2
.wipeup	clr.l (a0)+
	cmp.l a0,a2
	bne.s .wipeup
	rts

copy_it					; copy 16x13 sprite to screen
xx	set 0
	rept 16
	movem.l xx(a0),d0-1
	movem.l d0-1,xx(a2)
xx	set xx+160
	endr
	rts

old_res	dc.w 0				; entry resolution
old_scr	dc.w 0				; entry screen bytes

tracking_vbl

**** replace Bad brew crew ****
	cmp.l #'BUG!',unplot_b1
	beq SPRITE
	
	move.l unplot_b1,a5		; screen address to replace
	lea save_b1,a6
xx	set 0
	rept 6
	movem.l (a6)+,d0-7
	movem.l d0-3,xx(a5)
	movem.l d4-7,xx+160(a5)
xx	set xx+320
	endr

	move.l unplot_e1,a5		; screen address to replace
	lea save_e1,a6
xx	set 0
	rept 6
	movem.l (a6)+,d0-7
	movem.l d0-3,xx(a5)
	movem.l d4-7,xx+160(a5)
xx	set xx+320
	endr

	move.l unplot_e2,a5		; screen address to replace
	lea save_e2,a6
xx	set 0
	rept 6
	movem.l (a6)+,d0-7
	movem.l d0-3,xx(a5)
	movem.l d4-7,xx+160(a5)
xx	set xx+320
	endr

	move.l unplot_b2,a5		; screen address to replace
	lea save_b2,a6
xx	set 0
	rept 6
	movem.l (a6)+,d0-7
	movem.l d0-3,xx(a5)
	movem.l d4-7,xx+160(a5)
xx	set xx+320
	endr

	move.l unplot_r,a5		; screen address to replace
	lea save_r,a6
xx	set 0
	rept 6
	movem.l (a6)+,d0-7
	movem.l d0-3,xx(a5)
	movem.l d4-7,xx+160(a5)
xx	set xx+320
	endr

	move.l unplot_i,a5		; screen address to replace
	lea save_i,a6
xx	set 0
	rept 6
	movem.l (a6)+,d0-7
	movem.l d0-3,xx(a5)
	movem.l d4-7,xx+160(a5)
xx	set xx+320
	endr

	move.l unplot_s,a5		; screen address to replace
	lea save_s,a6
xx	set 0
	rept 6
	movem.l (a6)+,d0-7
	movem.l d0-3,xx(a5)
	movem.l d4-7,xx+160(a5)
xx	set xx+320
	endr

	move.l unplot_b1b,a5		; screen address to replace
	lea save_b1b,a6
xx	set 0
	rept 6
	movem.l (a6)+,d0-7
	movem.l d0-3,xx(a5)
	movem.l d4-7,xx+160(a5)
xx	set xx+320
	endr

	move.l unplot_e1b,a5		; screen address to replace
	lea save_e1b,a6
xx	set 0
	rept 6
	movem.l (a6)+,d0-7
	movem.l d0-3,xx(a5)
	movem.l d4-7,xx+160(a5)
xx	set xx+320
	endr

	move.l unplot_e2b,a5		; screen address to replace
	lea save_e2b,a6
xx	set 0
	rept 6
	movem.l (a6)+,d0-7
	movem.l d0-3,xx(a5)
	movem.l d4-7,xx+160(a5)
xx	set xx+320
	endr

	move.l unplot_b2b,a5		; screen address to replace
	lea save_b2b,a6
xx	set 0
	rept 6
	movem.l (a6)+,d0-7
	movem.l d0-3,xx(a5)
	movem.l d4-7,xx+160(a5)
xx	set xx+320
	endr

	move.l unplot_rb,a5		; screen address to replace
	lea save_rb,a6
xx	set 0
	rept 6
	movem.l (a6)+,d0-7
	movem.l d0-3,xx(a5)
	movem.l d4-7,xx+160(a5)
xx	set xx+320
	endr

	move.l unplot_ib,a5		; screen address to replace
	lea save_ib,a6
xx	set 0
	rept 6
	movem.l (a6)+,d0-7
	movem.l d0-3,xx(a5)
	movem.l d4-7,xx+160(a5)
xx	set xx+320
	endr

	move.l unplot_sb,a5		; screen address to replace
	lea save_sb,a6
xx	set 0
	rept 6
	movem.l (a6)+,d0-7
	movem.l d0-3,xx(a5)
	movem.l d4-7,xx+160(a5)
xx	set xx+320
	endr


SPRITE ****************** bad brew crew sprite routs ***********************
	lea trk_xe,a4
	lea trk_ye,a5
	lea x_table_trk,a3

beebriS	move.l trackx+24,a1		; get sprite x-point
	move.w (a1)+,d0
	cmp.l a4,a1			; end of table?
	bne.s .write
	lea trk_x+2,a1			; reset pointer
.write	move.l a1,trackx+24
	add d0,d0			; mult d0 by 8
	add d0,d0			; for double long access
	add d0,d0
	move.l 0(a3,d0),a2		; pointer into sprite table
	add.l #beeb_s,a2
	move.l (a2),a2			; address of sprite routine
	move.l bot1,a0		; work screen base
	move.l 4(a3,d0),d1		; horizontal offset
	move.l tracky+24,a1		; get sprite y-point
	add.w (a1)+,d1
	cmp.l a5,a1			; end of table?
	bne.s .write2
	lea trk_y+2,a1			; reset pointer
.write2	move.l a1,tracky+24		
	add.w d1,a0			; add to screen offset
	move.l a0,unplot_s		; save this screen
	move.l bot2,a1
	add.w d1,a1
	move.l a1,unplot_sb
	lea save_s,a6
xxx	set 0
yyy	set 0
	rept 6
	movem.l xxx(a0),d0-3
	movem.l xxx+160(a0),d4-7
	movem.l d0-7,yyy(a6)
	movem.l xxx(a1),d0-3
	movem.l xxx+160(a1),d4-7
	movem.l d0-7,yyy+192(a6)
xxx	set xxx+320
yyy	set yyy+32
	endr
	jsr (a2)			; call sprite routine
	move.l a1,a0
	jsr (a2)

beebrIs	move.l trackx+20,a1		; get sprite x-point
	move.w (a1)+,d0
	cmp.l a4,a1			; end of table?
	bne.s .write
	lea trk_x+2,a1			; reset pointer
.write	move.l a1,trackx+20
	add d0,d0			; mult d0 by 8
	add d0,d0			; for double long access
	add d0,d0
	move.l 0(a3,d0),a2		; pointer into sprite table
	add.l #beeb_i,a2
	move.l (a2),a2			; address of sprite routine
	move.l bot1,a0		; work screen base
	move.l 4(a3,d0),d1		; horizontal offset
	move.l tracky+20,a1		; get sprite y-point
	add.w (a1)+,d1
	cmp.l a5,a1			; end of table?
	bne.s .write2
	lea trk_y+2,a1			; reset pointer
.write2	move.l a1,tracky+20		
	add.w d1,a0			; add to screen offset
	move.l a0,unplot_i		; save this screen
	move.l bot2,a1
	add.w d1,a1
	move.l a1,unplot_ib
	lea save_i,a6
xxx	set 0
yyy	set 0
	rept 6
	movem.l xxx(a0),d0-3
	movem.l xxx+160(a0),d4-7
	movem.l d0-7,yyy(a6)
	movem.l xxx(a1),d0-3
	movem.l xxx+160(a1),d4-7
	movem.l d0-7,yyy+192(a6)
xxx	set xxx+320
yyy	set yyy+32
	endr
	jsr (a2)			; call sprite routine
	move.l a1,a0
	jsr (a2)

beebRis	move.l trackx+16,a1		; get sprite x-point
	move.w (a1)+,d0
	cmp.l a4,a1			; end of table?
	bne.s .write
	lea trk_x+2,a1			; reset pointer
.write	move.l a1,trackx+16
	add d0,d0			; mult d0 by 8
	add d0,d0			; for double long access
	add d0,d0
	move.l 0(a3,d0),a2		; pointer into sprite table
	add.l #beeb_r,a2
	move.l (a2),a2			; address of sprite routine
	move.l bot1,a0		; work screen base
	move.l 4(a3,d0),d1		; horizontal offset
	move.l tracky+16,a1		; get sprite y-point
	add.w (a1)+,d1
	cmp.l a5,a1			; end of table?
	bne.s .write2
	lea trk_y+2,a1			; reset pointer
.write2	move.l a1,tracky+16		
	add.w d1,a0			; add to screen offset
	move.l a0,unplot_r		; save this screen
	move.l bot2,a1
	add.w d1,a1
	move.l a1,unplot_rb
	lea save_r,a6
xxx	set 0
yyy	set 0
	rept 6
	movem.l xxx(a0),d0-3
	movem.l xxx+160(a0),d4-7
	movem.l d0-7,yyy(a6)
	movem.l xxx(a1),d0-3
	movem.l xxx+160(a1),d4-7
	movem.l d0-7,yyy+192(a6)
xxx	set xxx+320
yyy	set yyy+32
	endr
	jsr (a2)			; call sprite routine
	move.l a1,a0
	jsr (a2)

beeBris	move.l trackx+12,a1		; get sprite x-point
	move.w (a1)+,d0
	cmp.l a4,a1			; end of table?
	bne.s .write
	lea trk_x+2,a1			; reset pointer
.write	move.l a1,trackx+12
	add d0,d0			; mult d0 by 8
	add d0,d0			; for double long access
	add d0,d0
	move.l 0(a3,d0),a2		; pointer into sprite table
	add.l #beeb_b,a2
	move.l (a2),a2			; address of sprite routine
	move.l bot1,a0		; work screen base
	move.l 4(a3,d0),d1		; horizontal offset
	move.l tracky+12,a1		; get sprite y-point
	add.w (a1)+,d1
	cmp.l a5,a1			; end of table?
	bne.s .write2
	lea trk_y+2,a1			; reset pointer
.write2	move.l a1,tracky+12		
	add.w d1,a0			; add to screen offset
	move.l a0,unplot_b2		; save this screen
	move.l bot2,a1
	add.w d1,a1
	move.l a1,unplot_b2b
	lea save_b2,a6
xxx	set 0
yyy	set 0
	rept 6
	movem.l xxx(a0),d0-3
	movem.l xxx+160(a0),d4-7
	movem.l d0-7,yyy(a6)
	movem.l xxx(a1),d0-3
	movem.l xxx+160(a1),d4-7
	movem.l d0-7,yyy+192(a6)
xxx	set xxx+320
yyy	set yyy+32
	endr
	jsr (a2)			; call sprite routine
	move.l a1,a0
	jsr (a2)

beEbris	move.l trackx+8,a1		; get sprite x-point
	move.w (a1)+,d0
	cmp.l a4,a1			; end of table?
	bne.s .write
	lea trk_x+2,a1			; reset pointer
.write	move.l a1,trackx+8
	add d0,d0			; mult d0 by 8
	add d0,d0			; for double long access
	add d0,d0
	move.l 0(a3,d0),a2		; pointer into sprite table
	add.l #beeb_e,a2
	move.l (a2),a2			; address of sprite routine
	move.l bot1,a0		; work screen base
	move.l 4(a3,d0),d1		; horizontal offset
	move.l tracky+8,a1		; get sprite y-point
	add.w (a1)+,d1
	cmp.l a5,a1			; end of table?
	bne.s .write2
	lea trk_y+2,a1			; reset pointer
.write2	move.l a1,tracky+8		
	add.w d1,a0			; add to screen offset
	move.l a0,unplot_e2		; save this screen
	move.l bot2,a1
	add.w d1,a1
	move.l a1,unplot_e2b
	lea save_e2,a6
xxx	set 0
yyy	set 0
	rept 6
	movem.l xxx(a0),d0-3
	movem.l xxx+160(a0),d4-7
	movem.l d0-7,yyy(a6)
	movem.l xxx(a1),d0-3
	movem.l xxx+160(a1),d4-7
	movem.l d0-7,yyy+192(a6)
xxx	set xxx+320
yyy	set yyy+32
	endr
	jsr (a2)			; call sprite routine
	move.l a1,a0
	jsr (a2)

bEebris	move.l trackx+4,a1		; get sprite x-point
	move.w (a1)+,d0
	cmp.l a4,a1			; end of table?
	bne.s .write
	lea trk_x+2,a1			; reset pointer
.write	move.l a1,trackx+4
	add d0,d0			; mult d0 by 8
	add d0,d0			; for double long access
	add d0,d0
	move.l 0(a3,d0),a2		; pointer into sprite table
	add.l #beeb_e,a2
	move.l (a2),a2			; address of sprite routine
	move.l bot1,a0		; work screen base
	move.l 4(a3,d0),d1		; horizontal offset
	move.l tracky+4,a1		; get sprite y-point
	add.w (a1)+,d1
	cmp.l a5,a1			; end of table?
	bne.s .write2
	lea trk_y+2,a1			; reset pointer
.write2	move.l a1,tracky+4		
	add.w d1,a0			; add to screen offset
	move.l a0,unplot_e1		; save this screen
	move.l bot2,a1
	add.w d1,a1
	move.l a1,unplot_e1b
	lea save_e1,a6
xxx	set 0
yyy	set 0
	rept 6
	movem.l xxx(a0),d0-3
	movem.l xxx+160(a0),d4-7
	movem.l d0-7,yyy(a6)
	movem.l xxx(a1),d0-3
	movem.l xxx+160(a1),d4-7
	movem.l d0-7,yyy+192(a6)
xxx	set xxx+320
yyy	set yyy+32
	endr
	jsr (a2)			; call sprite routine
	move.l a1,a0
	jsr (a2)

Beebris	move.l trackx,a1		; get sprite x-point
	move.w (a1)+,d0
	cmp.l a4,a1			; end of table?
	bne.s .write
	lea trk_x+2,a1			; reset pointer
.write	move.l a1,trackx
	add d0,d0			; mult d0 by 8
	add d0,d0			; for double long access
	add d0,d0
	move.l 0(a3,d0),a2		; pointer into sprite table
	add.l #beeb_b,a2
	move.l (a2),a2			; address of sprite routine
	move.l bot1,a0		; work screen base
	move.l 4(a3,d0),d1		; horizontal offset
	move.l tracky,a1		; get sprite y-point
	add.w (a1)+,d1
	cmp.l a5,a1			; end of table?
	bne.s .write2
	lea trk_y+2,a1			; reset pointer
.write2	move.l a1,tracky		
	add.w d1,a0			; add to screen offset
	move.l a0,unplot_b1		; save this screen
	move.l bot2,a1
	add.w d1,a1
	move.l a1,unplot_b1b
	lea save_b1,a6
xxx	set 0
yyy	set 0
	rept 6
	movem.l xxx(a0),d0-3
	movem.l xxx+160(a0),d4-7
	movem.l d0-7,yyy(a6)
	movem.l xxx(a1),d0-3
	movem.l xxx+160(a1),d4-7
	movem.l d0-7,yyy+192(a6)
xxx	set xxx+320
yyy	set yyy+32
	endr
	jsr (a2)			; call sprite routine
	move.l a1,a0
	jsr (a2)

	rts

bot1	dc.l 0
bot2	dc.l 0

;;; sprite buffers.....

unplot_b1	dc.b "BUG!"
save_b1		ds.l 4*12
save_b1b	ds.l 4*12
unplot_e1	dc.l 0
save_e1		ds.l 4*12
save_e1b	ds.l 4*12
unplot_e2	dc.l 0
save_e2		ds.l 4*12
save_e2b	ds.l 4*12
unplot_b2	dc.l 0
save_b2		ds.l 4*12
save_b2b	ds.l 4*12
unplot_r	dc.l 0
save_r		ds.l 4*12
save_rb		ds.l 4*12
unplot_i	dc.l 0
save_i		ds.l 4*12
save_ib		ds.l 4*12
unplot_s	dc.l 0
save_s		ds.l 4*12
save_sb		ds.l 4*12
unplot_b1b	dc.l 0
unplot_e1b	dc.l 0
unplot_e2b	dc.l 0
unplot_b2b	dc.l 0
unplot_rb	dc.l 0
unplot_ib	dc.l 0
unplot_sb	dc.l 0

***************************************************************************
*************************** make sprite rout ******************************
***************************************************************************

make_routs	
	lea screen,a0			; graphics data
	moveq.l #16,d5			; 16 shifts
.makeem	move.l a1,(a2)+			; save this address
	bsr do_1			; make routine
	bsr rotate2			; shift right!
	clr.l old_dat			; clear optimise flag #1
	clr.l old_d2			; clear optimise flag #2
	subq.l #1,d5			
	bne.s .makeem
	rts

do_1	lea screen,a0			; screen address
	moveq.l #0,d7			; offset init
looper	tst.l (a0)			; and data
	bne.s hit			; branch if yes
	tst.l 4(a0)			; and data
	bne.s hit			; branch if yes
	bsr nothing			; none!
	cmp.w #121*160,d7		; end of screen?
	bne.s looper
	move.w #$4e75,(a1)+		; write final RTS instruction
	rts

hit	tst.l -8(a0)			; any before?
	beq sprite			; nope! sprite
	tst.l -4(a0)			; any before?
	beq sprite			; nope! sprite
	tst.l 8(a0)			; any after?
	bne block			; yup! block
	tst.l 12(a0)			; any after?
	bne block			; yup! block
	bra sprite			; must be a sprite again!

; routine to take screen data in (a0) and 4(a0) and build the
; fastest possible routine to sprite it witout using MOVEMs.

sprite	move.w (a0),d0			; make mask
	move.w 2(a0),d1
	move.w 4(a0),d2
	move.w 6(a0),d3
	or.w d1,d0
	or.w d2,d0
	or.w d3,d0
	not.w d0
	tst.w d0
	beq .clr		; if 0 then a clear will do!

	move.w #$223c,(a1)+	; move.l #????????,d1
	move.w d0,(a1)+
	move.w d0,(a1)+
	move.w #$c3a8,(a1)+	; and
	move.w d7,(a1)+
	move.w #$c3a8,(a1)+	; and
	move.w d7,(a1)
	add.w #4,(a1)+

.do_or	tst.l (a0)		; check for data present
	bne.s .or1
	add.l #4,a0		; none, skip to next long
	bra.s .sk1		; or's are not needed

.or1	cmp.l #-128,(a0)	; ok, test data for +ve quick validity
	blt.s .lon1		; negative! no quick here
	cmp.l #127,(a0)		
	bgt.s .lon1		; larger than 127. not possible.
	bsr .orq1		; substitute a moveq #??,d2 or d2,????(a0)
	bra.s .sk1		; process next longword

.lon1	move.w #$00a8,(a1)+	; opcode! ori.l #????????,????(a0)
	move.l (a0)+,(a1)+	; data
	move.w d7,(a1)+		; offset

.sk1	tst.l (a0)		; check for data present
	bne.s .or2
	add.l #4,a0		; none - next long please
	bra.s .sk2		; jump out of routine

.or2	cmp.l #-128,(a0)	; test for quick validity
	blt.s .lon2		; negative! 
	cmp.l #127,(a0)
	bgt.s .lon2		; larger than 127. not possible
	bsr .orq2		; substiture a moveq #??,d2 or d2,????(a0)
	bra.s .sk2		; get the hell out

.lon2	move.w #$00a8,(a1)+	; opcode! ori.l #????????,????(a0)
	move.l (a0)+,(a1)+	; data
	move.w d7,(a1)		; offset
	add.w #4,(a1)+ 		; increment offset

.sk2	addq.l #8,d7		; increment offset counter
	bra looper

.clr	move.w #$42a8,(a1)+	; opcode! clr.l ????(a0)
	move.w d7,(a1)+		; offset
	move.w #$42a8,(a1)+	; opcode! clr.l ????(a0)
	move.w d7,(a1)		; offset
	add.w #4,(a1)+		; plus 4
	bra .do_or		; now process the ors

.orq1	move.l (a0)+,d0		; get current long in d0 and increment
	cmp.l old_d2,d0		; same as last quick substitute?
	beq.s .orw1		; skip the moveq.l #??,d2 if yes!
	move.l d0,old_d2	; save this long

	move.b #$74,(a1)+	; opcode! moveq #??,d2
	move.b d0,(a1)+		; data
.orw1	move.w #$85a8,(a1)+	; opcode! or.l d2,????(a0)
	move.w d7,(a1)+		; offset
	rts

.orq2	move.l (a0)+,d0		; get current long in d0 and increment
	cmp.l old_d2,d0		; same as last quick substitute?
	beq.s .orw2		; skip moveq if yes	
	move.l d0,old_d2	; save this long

	move.b #$74,(a1)+	; opcode! moveq #??,d2
	move.b d0,(a1)+		; data
.orw2	move.w #$85a8,(a1)+	; opcode! or.l d2,????(a0)
	move.w d7,(a1)		; offset
	addq.w #4,(a1)+
	rts

old_d2	dc.l 0

; routine to take screen data in (a0) and 4(a0) and make a routine
; to movei.l #????????,????(a0) / offset in d7 at address (a1)

block	tst.l (a0)		; any data?
	bne.s .sk1		; branch if yes
	bsr .clear		; make a clr.l ????(a0)
	bra.s .pt2		

.sk1	bsr .block		; make a block move

.pt2	tst.l (a0)		; any data?
	bne.s .sk2		; branch if yes
	bsr .clear		; make a clr.l ????(a0)
	bra looper		; loop around

.sk2	bsr .block		; make a block move
	bra looper		; loop around

.clear	move.w #$42a8,(a1)+	; opcode! clr.l ????(a0)
	move.w d7,(a1)+		; offset
	addq.l #4,a0		; increment
	addq.w #4,d7
	rts

.block	move.l (a0),d0		; get data
	cmp.l #-128,d0		; check to see if it is in the range
	blt.s .long		; -128 --> +127, and if yes then
	cmp.l #127,d0		; substitute:-
	bgt.s .long		; moveq.l #??,d3 / move.l d3,????(a0)

	cmp.l old_dat,d0	; same as last quick move?
	beq.s .mov		; yes, no need for moveq

	move.l d0,old_dat	; save this long
	move.b #$76,(a1)+	; moveq #??,d3
	move.b d0,(a1)+		; data
.mov	move.w #$2143,(a1)+	; move.l d3,????(a0)
	move.w d7,(a1)+		; offset
	addq.l #4,a0
	addq.w #4,d7
	rts

.long	move.w #$217c,(a1)+	; movei.l #????????,????(a0)
	move.l (a0)+,(a1)+	; data #1
	move.w d7,(a1)+
	addq.w #4,d7
	rts
old_dat	dc.l 0

nothing	addq.l #8,d7		; increment offset
	addq.l #8,a0		; increment source 
	rts

rotate2	lea screen,a4		; address of screen
	move.l #13,d0
.lines	move.l #4,d1
.planes	roxr.w (a4)
	roxr.w 8(a4)
	addq.w #2,a4
	subq.l #1,d1
	bne.s .planes
	lea 152(a4),a4
	subq.l #1,d0
	bne.s .lines
	rts

x_table_trk			; sprite rout offset/screen offset
x	set 0			; for 0-319 (x)
	rept 20
	dc.l 0,x
	dc.l 4,x
	dc.l 8,x
	dc.l 12,x
	dc.l 16,x
	dc.l 20,x
	dc.l 24,x
	dc.l 28,x
	dc.l 32,x
	dc.l 36,x
	dc.l 40,x
	dc.l 44,x
	dc.l 48,x
	dc.l 52,x
	dc.l 56,x
	dc.l 60,x
x	set x+8
	endr

beeb_b	ds.l 16				; sprite routines
beeb_e	ds.l 16				; sprite routines
beeb_r	ds.l 16				; sprite routines
beeb_i	ds.l 16				; sprite routines
beeb_s	ds.l 16				; sprite routines

trackx	dc.l trk_x+208,trk_x+192,trk_x+176		; bee
	dc.l trk_x+160,trk_x+144,trk_x+128,trk_x+112	; bris
	 
trk_x	incbin trk_x.bin
trk_xe

tracky	dc.l trk_y+208,trk_y+192,trk_y+176		; bee
	dc.l trk_y+160,trk_y+144,trk_y+128,trk_y+112	; bris

trk_y	incbin trk_y.bin
trk_ye

logrout	dc.l 0			; sprites trash forward from here!
	even
 
	endc


	ifd credit_screen

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;   			The Beebris Tracker Intro 			 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tspeed	equ 37
	OPT o+,ow-

intro 	movem.l pic1+2,d0-7		; instal pallette
	movem.l d0-7,$ffff8240.w

	lea pic1+34,a0			; copy pic to both 
	move.l titscr1,a1		; screens
	move.l #$7d00/4,d0
.doo	move.l (a0)+,(a1)+
	subq.w #1,d0
	bne.s .doo

	jsr tracker

	move.b titscr1+1,$ffff8201.w	; toggle screens
	move.b titscr1+2,$ffff8203.w

	move.b #$12,$fffffc02.w

.bolux	cmp.b #$10,$fffffc02.w		; q - quit
	bne.s .cspc
	move.b #$10,lastkey
	bra.s .exity
.cspc	cmp.b #$80,$fffffc02.w		; fire!
	beq.s .exity
	cmp.b #$39,$fffffc02.w		; space - game
	bne.s .bolux
	
.exity	move.w #$2700,sr		; kill ints
	lea $ffff8240.w,a0		; kill pallette
	moveq #8,d0
.allblk	clr.l (a0)+
	subq.l #1,d0
	bne.s .allblk
	jsr tracker+4			; kill tracker
	move.w #$2300,sr		; interupts on
	
	rts


titscr1	dc.l hi_screen

pic1	incbin titlemod.pi1


tracker		bra tracker_on
		bra tracker_off
		bra tracker_vbl

tracker_on	BSR Wait_Vbl
		BSR Ste_Test
		BSR Init_Voltab			; initialise volume table.

		LEA mt_data,A0
		BSR mt_init			; initialise mod data.

		BSR init_ints			; and go!

		rts

tracker_off	BSR restore_ints		; restore gem..
		rts

; Save mfp vectors and ints and install our own.(very 'clean' setup rout)

init_ints	MOVEQ #$13,D0			; pause keyboard
		BSR Writeikbd			; (stop from sending)
		MOVE #$2700,SR
		LEA old_stuff+32(PC),A0
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+	; Save mfp registers 
		MOVE.B $FFFFFA1D.W,(A0)+
		MOVE.B $FFFFFA25.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $110.W,(A0)+		; save some vectors
		CLR.B $fffffa07.W
		MOVE.B #$50,$fffffa09.W
		CLR.B $fffffa13.W
		MOVE.B #$50,$fffffa15.W
		BCLR.B #3,$fffffa17.W		; software end of int.
		MOVE.B #0,$FFFFFA1D.W
		lea tracker_vbl(pc),a0
		move.l a0,$70.w
		MOVE.B #tspeed,$FFFFFA25.W
		MOVE.B #1,$FFFFFA1D.W
		MOVE Which_replay(PC),D0
		BSR Select_PlayRout
		LEA sndbuff1(PC),A1
		MOVE #$2300,SR
		MOVEQ #$11,D0			; resume sending
		BSR Writeikbd
		MOVEQ #$12,D0			; kill mouse
		BSR Writeikbd
		BSR flush
		RTS

; Restore mfp vectors and ints.

restore_ints	MOVE.L oldusp(PC),A0
		MOVE.L A0,USP
		MOVEQ #$13,D0			; pause keyboard
		BSR Writeikbd			; (stop from sending)
		MOVE #$2700,SR
		LEA old_stuff+32(PC),A0
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W	; restore mfp
		MOVE.B (A0)+,$FFFFFA1D.W
		MOVE.B (A0)+,$FFFFFA25.W
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$110.W
		BSET.B #3,$FFFFFA17.W
		MOVE #$2300,SR
		MOVEQ #$11,D0			; resume
		BSR Writeikbd		
		MOVEQ #$8,D0			; restore mouse.
		BSR Writeikbd
		BSR flush
		RTS

; Wait for a vbl..

Wait_Vbl	MOVE #37,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		RTS

old_stuff:	DS.L 20
oldres		DS.W 1
oldsp		DS.L 1
oldusp		DS.L 1

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

;-----------------------------------------------------------------------;
									
; The vbl - calls sequencer and vbl filler.

tracker_vbl		MOVEM.L D0-D6/A0/A2-A6,-(SP)
		BSR Vbl_play
		BSR mt_music	
		MOVEM.L (SP)+,D0-D6/A0/A2-A6
		RTE

; Vbl player - this is a kind of 'Paula' Emulator(!)

Vbl_play:	MOVEA.L	buff_ptr(PC),A4
		MOVE.L A1,D0			; current pos in buffer
		CMP.L #endbuff1,d0
		BNE.S .norm
		MOVE.L #sndbuff1,d0		; wooky case(at end of buf)
.norm		MOVE.L D0,buff_ptr
		SUB.L A4,D0
		BEQ skipit
		BHI.S higher
		ADDI.W #$800,D0			; abs
higher		LSR.W #1,D0
		MOVE.L #endbuff1,D1
		SUB.L A4,D1
		LSR.W #1,D1
		CLR.W fillx1			; assume no buf overlap
		CMP.W D1,D0			; check for overlap
		BCS.S higher1
		MOVE.W D1,fillx1		; ok so there was overlap!!
higher1		SUB.W fillx1(PC),D0		; subtract any overlap
		MOVE.W D0,fillx2		; and store main
; A4 points to place to fill
		LEA freqs(PC),A3		; int.w/frac.w freq tab

.voices_1_2	MOVE.L #sndbuff1,buffbase		
		LEA.L ch1s(PC),A5
		MOVE.W amove(pc),D0
		BSR add1			; move voice 1
		LEA.L ch2s(PC),A5
		MOVE.W aadd(pc),D0
		BSR add1			; add voice 2

		LEA $802(A4),A4
.voices_3_4	MOVE.L #sndbuff2,buffbase	
		LEA.L ch3s(PC),A5	
		MOVE.W amove(pc),D0
		BSR add1			; move voice 3	
		LEA.L ch4s(PC),A5	
		MOVE.W aadd(pc),D0
		BSR add1			; add voice 4					; add voice 4
		RTS

; Routine to add/move one voice to buffer. The real Paula emulation part!!

add1		PEA (A4)			; save buff pos
		LEA moda(PC),A2
		MOVE.W D0,(A2)
		MOVE.W D0,modb-moda(A2)		; self modifying
		MOVE.W D0,modc-moda(A2)		; add/move code(see below)
		MOVE.W D0,modd-moda(A2)	
		MOVE.W D0,tmode-moda(A2)	
		MOVE.L (A5),A2			; current sample end address
		MOVEM.W 6(A5),D1/D2		; period/volume
		ADD.W D1,D1
		ADD.W D1,D1			; *4 for lookup
		MOVEM.W 0(A3,D1),D1/D4		; get int.w/frac.w
		MOVE.L voltab_ptr(PC),A6	; base of volume table
		LSL.W #8,D2
		ADD.W D2,A6			; ptr to volume table
		MOVEQ #0,d5
		MOVE.W 4(A5),d5			; sample length
		CMP.L #nulsamp+2,A2
		BNE.S .vcon
		MOVEQ.L	#0,D4			; channel is off.
		MOVEQ.L	#0,D1			; clear all if off.
		MOVE.L voltab_ptr(PC),A6	; zero vol(safety!!)
		CLR.W 16(A5)			; clear frac part
.vcon		NEG.L d5
		MOVE.L A6,D6			; vol ptr
		MOVEQ.L	#0,D2			; clr top byte for sample
; Setup Loop stuff
		MOVE.L 10(a5),A0		; loop addr
		MOVEQ #0,D3
		MOVE.W 14(a5),D3		; loop length
		NEG.L D3
		MOVEM.W D1/D4,loopfreq
		CMP.L #-2,D3
		BNE.S isloop
noloop		MOVE.L D2,loopfreq		; no loop-no frequency
		LEA nulsamp+2(PC),A0	 	; no loop-point to nul
isloop		MOVE.L D3,looplength
		MOVE.W 16(A5),D3		; clear fraction part
		MOVE.W fillx1(PC),D0
		BSR.S taddit			; 
		MOVE.W fillx2(PC),D0
		TST.W fillx1
		BEQ.S nores
		MOVE.L buffbase(PC),A4		; buffer base
nores		BSR.S taddit
		NEG.L d5			; +ve offset(as original!)
		MOVE.L A2,(A5)			; store voice address
		MOVE.W d5,4(A5)			; store offset for next time
		MOVE.W D3,16(A5)		; clear fraction part
skipit		MOVE.L (SP)+,A4
		RTS
	
; Add D0 sample bytes to buffer

taddit		MOVE.W D0,donemain+2		; lets go!!
		LSR #2,D0			; /4 for tspeed
		SUBQ #1,D0			; -1 (dbf)
		BMI.S donemain			; none to do?
makelp		MOVE.B (A2,d5.L),D6		; fetch sample byte
		MOVE.L D6,A6
		MOVE.B (A6),D2			; lookup in vol tab
moda		ADD.W D2,(A4)+			; add/move to buffer(self modified)
		ADD.W D4,D3			; add frac part
		ADDX.W D1,d5			; add ints.(carried thru)
		BCS.S lpvoice1			; voice looped?
CONT1		MOVE.B (A2,d5.L),D6
		MOVE.L D6,A6
		MOVE.B (A6),D2
modb		ADD.W D2,(A4)+
		ADD.W D4,D3			; 
		ADDX.W D1,d5
		BCS.S lpvoice2
CONT2		MOVE.B (A2,d5.L),D6
		MOVE.L D6,A6
		MOVE.B (A6),D2
modc		ADD.W D2,(A4)+
		ADD.W D4,D3			;
		ADDX.W D1,d5
		BCS lpvoice3
CONT3		MOVE.B (A2,d5.L),D6
		MOVE.L D6,A6
		MOVE.B (A6),D2
modd		ADD.W D2,(A4)+			;
		ADD.W D4,D3
		ADDX.W D1,d5
CONT4		DBCS  D0,makelp
		BCS lpvoice4
donemain	MOVE.W #0,D0
		AND #3,D0			; remaining bytes.
		SUBQ #1,D0
		BMI.S yeah
niblp		MOVE.B (A2,d5.L),D6
		MOVE.L D6,A6
		MOVE.B (A6),D2
tmode		ADD.W D2,(A4)+
		ADD.W D4,D3
		ADDX.W D1,d5
CONT5		DBCS D0,niblp
		BCS lpvoicelast
yeah		RTS

buffbase	DS.L 1
loopfreq:	DS.W 2
looplength:	DS.L 1
voltab_ptr	DS.L 1

lpvoice		MACRO
		MOVE.L A0,A2 
		EXT.L D5
		ADD.L looplength(PC),D5		; fetch loop constants
		MOVEM.W loopfreq(PC),D1/D4	; (channel independent)
		MOVEQ #0,D2
		MOVE D2,CCR	
 		BRA \1
		ENDM

lpvoice1:	lpvoice CONT1			;
lpvoice2:	lpvoice CONT2			; loop routs
lpvoice3:	lpvoice CONT3			; (since code is repeated)
lpvoice4:	lpvoice CONT4			;
lpvoicelast:	lpvoice CONT5			;

aadd		ADD.W D2,(A4)+
amove		MOVE.W D2,(A4)+

nulsamp		ds.l 2				; nul sample.
buff_ptr:	dc.l 0
sndbuff1:	ds.w $400			; buffer for voices 1+2
endbuff1:	dc.w -1
sndbuff2	ds.w $400			; buffer for voices 3+4
endbuff2	dc.w -1

fillx1:		DC.W 0
fillx2:		DC.W 0

; Ste Test Routine - Sets 'ste_flg' true if the machine is STE and inits.

ste_flg		DC.W 0
	
Ste_Test	LEA $FFFF8205.W,A5
		MOVEQ #-1,D1
		MOVE.B (A5),D0
		MOVE.B D1,(A5)
		CMP.B (A5),D0
		BEQ .notSTE
		MOVE.B	D0,(a5)
.ste_found	ST ste_flg
		MOVE.W #1,Which_replay
		LEA.L setsam_dat(PC),A6
		MOVEQ #3,D6
.mwwritx	MOVE.W #$7ff,$ffff8924.W
.mwwritx2	CMP.W #$7ff,$ffff8924.W
		BNE.S .mwwritx2
		MOVE.W (A6)+,$ffff8922.W
		DBF D6,.mwwritx
.notSTE		RTS

temp:		dc.l	0
setsam_dat:	dc.w	%0000000011010100  	;mastervol
		dc.w	%0000010010000110  	;treble
		dc.w	%0000010001000110  	;bass
		dc.w	%0000000000000001  	;mixer

; Select The Playback Routine D0.W = 0 to 6

Select_PlayRout:MOVE.W SR,-(SP)
		MOVE #$2700,SR
		MOVE.W D0,Which_replay
		ADD.W D0,D0
		ADD.W D0,D0			; *4 (longword lookup)
		MOVE.L Output_Routs(PC,D0),$110.W
		JSR rout_tab(PC,D0.W)		; jump to setup rout
		MOVE.W (SP)+,SR
		RTS

rout_tab	BRA.W YM2149_Setup
		BRA.W Ste_Setup
		BRA.W Internal_Off
		BRA.W Internal_Off
		BRA.W Internal_Off
		BRA.W Internal_Off
		BRA.W Internal_Off

Which_replay	DC.W 0				; 0 - 6 as below
Output_Routs	DC.L YM2149_Player

; YM2149 Setup rout - turns off ste dma(if machine is st) and clears YM.

YM2149_Setup:	TST.B ste_flg
		BEQ.S .not_ste 
		MOVE.W #0,$FFFF8900.W
.not_ste	BSR Initsoundchip			; init soundchip
		RTS

; Ste Stereo Setup rout - turns off YM 2149 and setsup dma.

Ste_Setup:	TST.B ste_flg
		BEQ.S .not_ste
		BSR Killsoundchip
		MOVE.W #0,$FFFF8900.W
		MOVE.W #$8080,$D0.W		; prime with nul sample
		LEA temp(PC),A6
		MOVE.L #$D0,(A6)			
		MOVE.B 1(A6),$ffff8903.W
		MOVE.B 2(A6),$ffff8905.W	; set start of buffer
		MOVE.B 3(A6),$ffff8907.W
		MOVE.L #$D2,(A6)
		MOVE.B 1(A6),$ffff890f.W
		MOVE.B 2(A6),$ffff8911.W	; and set end of buf
		MOVE.B 3(A6),$ffff8913.W
		MOVE.W #%0000000000000011,$ffff8920.W
		MOVE.W #3,$FFFF8900.W		; dma go!
.not_ste	RTS

; Setup rout for all other output routs - kills both dma and YM sound.

Internal_Off:	TST.B ste_flg
		BEQ.S .not_ste 
		MOVE.W #0,$FFFF8900.W
.not_ste	BSR Killsoundchip
 		RTS

;--------- The 12 bit sample interrupt Routines. They Use D7/A1 ---------;
; YM2149 Soundchip, Replay Cartridge, Replay Professional, Stereo Playback,
; STE Stereo Output, Pro-Sound Designer Cartridge, MV16 Cartridge.

; YM2149 Soundchip output.

YM2149_Player:	move.w (a1)+,d7
		bmi.s .loopit
.contsnd	add.w $800(a1),d7
		lsl #3,d7
		move.l a1,usp
		lea $ffff8800.w,a1		; output
		move.l sound_look+4(pc,d7.w),(a1)
		move.l sound_look(pc,d7.w),d7	; using quartet table.
		movep.l d7,(a1)
		move.l usp,a1
		rte
.loopit		lea sndbuff1(pc),a1
		move.w (a1)+,d7
		bra.w .contsnd
sound_look:	incbin quarfast.tab

; Ste Stereo sound output with volume boost.

Ste_Stereo:	move.w d6,-(sp)
		move.w (a1)+,d7
		bmi.s .loopit
.contsnd	move.w $800(a1),d6
		add.w d6,d6
		add.w d7,d7
		move.w stetab(pc,d6),d6
		move.b stetab(pc,d7),d6
		move.w d6,$d0.w
		move.w (sp)+,d6
		rte
.loopit		lea sndbuff1(pc),a1
		move.w (a1)+,d7
		bra.w .contsnd

stetab		dcb.w 128,$8000
i		set -128
		rept 256
		dc.b i,0
i		set i+1
		endr
		dcb.w 128,$7f00

; ST specific initialisation routines - sets up shadow amiga registers.

STspecific:	LEA  nulsamp+2(PC),A2
		MOVEQ #0,D0
		LEA ch1s(pc),A0
		BSR initvoice
		LEA ch2s(pc),A0
		BSR initvoice			;init shadow regs
		LEA ch3s(pc),A0
		BSR initvoice
		LEA ch4s(pc),A0
		BSR initvoice
		LEA sndbuff1(PC),A0
		MOVE.L A0,buff_ptr
		LEA sndbuff2(PC),A1
		MOVEQ.L	#0,D1
		MOVEQ #$7F,D0
.setbuf1	MOVE.L	D1,(A0)+
		MOVE.L	D1,(A0)+
		MOVE.L	D1,(A0)+
		MOVE.L	D1,(A0)+		; clear 2 ring buffers
		MOVE.L	D1,(A1)+
		MOVE.L	D1,(A1)+
		MOVE.L	D1,(A1)+
		MOVE.L	D1,(A1)+
		DBF D0,.setbuf1
		RTS
initvoice:	MOVE.L A2,(A0)		; point voice to nul sample
		MOVE.W #2,4(A0)	
		MOVE.W D0,6(A0)		; period=0
		MOVE.W D0,8(A0)		; volume=0
		MOVE.L A2,10(A0)	; and loop point to nul sample
		MOVE.W #2,14(A0)
		MOVE.W D0,16(A0)	; clear fraction part.
		RTS

; Initialise Soundchip

Initsoundchip:	LEA $FFFF8800.W,A0
		MOVE.B #7,(A0)			; turn on sound
		MOVE.B #$c0,D0
		AND.B (a0),D0
		OR.B #$38,D0
		MOVE.B d0,2(a0)
		MOVE.W #$0500,d0		; clear out ym2149
.initslp	MOVEP.W	d0,(a0)
		SUB.W #$0100,d0
		BPL.S .initslp
		RTS

; Reset sound chip

Killsoundchip	MOVE.W D0,-(SP)
		MOVE.B #7,$ffff8800.W		
		MOVE.B #7,D0
		OR.B $ffff8800.W,D0
		MOVE.B D0,$ffff8802.W
		MOVE.W (SP)+,D0
		RTS

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
.lp		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		DBF D0,.lp
.alreadyinited	RTS


; Shadow Amiga Registers.
	
ch1s		DS.W 9
ch2s		DS.W 9
ch3s		DS.W 9
ch4s		DS.W 9

;********************************************
;* ----- Protracker V1.1A Playroutine ----- *
;* Lars "Zap" Hamre/Amiga Freelancers 1990  *
;* Bekkeliveien 10, N-2010 STRØMMEN, Norway *
;********************************************

n_cmd		EQU	2  ; W
n_cmdlo		EQU	3  ; low B of n_cmd
n_start		EQU	4  ; L
n_length	EQU	8  ; W
n_loopstart	EQU	10 ; L
n_replen	EQU	14 ; W
n_period	EQU	16 ; W
n_finetune	EQU	18 ; B
n_volume	EQU	19 ; B
n_dmabit	EQU	20 ; W
n_toneportdirec	EQU	22 ; B
n_toneportspeed	EQU	23 ; B
n_wantedperiod	EQU	24 ; W
n_vibratocmd	EQU	26 ; B
n_vibratopos	EQU	27 ; B
n_tremolocmd	EQU	28 ; B
n_tremolopos	EQU	29 ; B
n_wavecontrol	EQU	30 ; B
n_glissfunk	EQU	31 ; B
n_sampleoffset	EQU	32 ; B
n_pattpos	EQU	33 ; B
n_loopcount	EQU	34 ; B
n_funkoffset	EQU	35 ; B
n_wavestart	EQU	36 ; L
n_reallength	EQU	40 ; W

; Initialise module

mt_init	MOVE.L	A0,mt_SongDataPtr
	LEA	mt_mulu(PC),A1
	MOVE.L	A0,D0
	ADD.L	#12,D0
	MOVEQ	#$1F,D1
	MOVEQ	#$1E,D3
mt_lop4	MOVE.L	D0,(A1)+
	ADD.L	D3,D0
	DBRA	D1,mt_lop4
	LEA	$3B8(A0),A1
	MOVEQ	#127,D0
	MOVEQ	#0,D1
	MOVEQ	#0,D2
mt_lop2 MOVE.B	(A1)+,D1
	CMP.B	D2,D1
	BLE.S	mt_lop
	MOVE.L	D1,D2
mt_lop	DBRA	D0,mt_lop2
	ADDQ.W	#1,d2
	ASL.L	#8,D2
	ASL.L	#2,D2
	LEA	4(A1,D2.L),A2
	LEA	mt_SampleStarts(PC),A1
	ADD.W	#$2A,A0
	MOVEQ	#$1E,D0
mt_lop3 CLR.L	(A2)
	MOVE.L	A2,(A1)+
	MOVEQ	#0,D1
	MOVE.B	D1,2(A0)
	MOVE.W	(A0),D1
	ASL.L	#1,D1
	ADD.L	D1,A2
	ADD.L	D3,A0
	DBRA	D0,mt_lop3
	LEA	mt_speed(PC),A1
	MOVE.B	#6,(A1)
	MOVEQ	#0,D0
	MOVE.B	D0,mt_SongPos-mt_speed(A1)
	MOVE.B	D0,mt_counter-mt_speed(A1)
	MOVE.W	D0,mt_PattPos-mt_speed(A1)
	BRA STspecific

; Vbl Sequencer

mt_music
	ADDQ.B	#1,mt_counter
	MOVE.B	mt_counter(PC),D0
	CMP.B	mt_speed(PC),D0
	BLO.S	mt_NoNewNote
	CLR.B	mt_counter
	TST.B	mt_PattDelTime2
	BEQ.S	mt_GetNewNote
	BSR.S	mt_NoNewAllChannels
	BRA	mt_dskip

mt_NoNewNote
	BSR.S	mt_NoNewAllChannels
	BRA	mt_NoNewPosYet

mt_NoNewAllChannels
	LEA	ch1s(pc),A5
	LEA	mt_chan1temp(PC),A6
	BSR	mt_CheckEfx
	LEA	ch2s(pc),A5
	LEA	mt_chan2temp(PC),A6
	BSR	mt_CheckEfx
	LEA	ch3s(pc),A5
	LEA	mt_chan3temp(PC),A6
	BSR	mt_CheckEfx
	LEA	ch4s(pc),A5
	LEA	mt_chan4temp(PC),A6
	BRA	mt_CheckEfx

mt_GetNewNote
	MOVE.L	mt_SongDataPtr(PC),A0
	LEA	12(A0),A3
	LEA	952(A0),A2	;pattpo
	LEA	1084(A0),A0	;patterndata
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	mt_SongPos(PC),D0
	MOVE.B	(A2,D0.W),D1
	ASL.L	#8,D1
	ASL.L	#2,D1
	ADD.W	mt_PattPos(PC),D1

	LEA	ch1s(pc),A5
	LEA	mt_chan1temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	ch2s(pc),A5
	LEA	mt_chan2temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	ch3s(pc),A5
	LEA	mt_chan3temp(PC),A6
	BSR.S	mt_PlayVoice
	LEA	ch4s(pc),A5
	LEA	mt_chan4temp(PC),A6
	BSR.S	mt_PlayVoice
	BRA	mt_SetDMA

mt_PlayVoice
	TST.L	(A6)
	BNE.S	mt_plvskip
	MOVE.W	n_period(A6),6(A5)
mt_plvskip
	MOVE.L	(A0,D1.L),(A6)
	ADDQ.L	#4,D1
	MOVEQ	#0,D2
	MOVE.B	n_cmd(A6),D2
	LSR.B	#4,D2
	MOVE.B	(A6),D0
	AND.B	#$F0,D0
	OR.B	D0,D2
	BEQ	mt_SetRegs
	MOVEQ	#0,D3
	MOVE	D2,D4
	SUBQ.L	#1,D2
	ASL.L	#2,D2
	MULU	#30,D4
	MOVE.L	mt_SampleStarts(PC,D2.L),n_start(A6)
	MOVE.W	(A3,D4.L),n_length(A6)
	MOVE.W	(A3,D4.L),n_reallength(A6)
	MOVE.B	2(A3,D4.L),n_finetune(A6)
	MOVE.B	3(A3,D4.L),n_volume(A6)
	MOVE.W	4(A3,D4.L),D3 ; Get repeat
	TST.W	D3
	BEQ	mt_NoLoop
	MOVE.L	n_start(A6),D2	; Get start
	ASL.W	#1,D3
	ADD.L	D3,D2		; Add repeat
	MOVE.L	D2,n_loopstart(A6)
	MOVE.L	D2,n_wavestart(A6)
	MOVE.W	4(A3,D4.L),D0	; Get repeat
	ADD.W	6(A3,D4.L),D0	; Add replen
	MOVE.W	D0,n_length(A6)
	MOVE.W	6(A3,D4.L),n_replen(A6)	; Save replen
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)	; Set volume
	BRA	mt_SetRegs
mt_SampleStarts	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

mt_NoLoop
	MOVE.L	n_start(A6),D2
	ADD.L	D3,D2
	MOVE.L	D2,n_loopstart(A6)
	MOVE.L	D2,n_wavestart(A6)
	MOVE.W	6(A3,D4.L),n_replen(A6)	; Save replen
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)	; Set volume
mt_SetRegs
	MOVE.W	(A6),D0
	AND.W	#$0FFF,D0
	BEQ	mt_CheckMoreEfx	; If no note
	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0E50,D0
	BEQ.S	mt_DoSetFineTune
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	CMP.B	#3,D0	; TonePortamento
	BEQ.S	mt_ChkTonePorta
	CMP.B	#5,D0
	BEQ.S	mt_ChkTonePorta
	CMP.B	#9,D0	; Sample Offset
	BNE.S	mt_SetPeriod
	BSR	mt_CheckMoreEfx
	BRA.S	mt_SetPeriod

mt_DoSetFineTune
	BSR	mt_SetFineTune
	BRA.S	mt_SetPeriod

mt_ChkTonePorta
	BSR	mt_SetTonePorta
	BRA	mt_CheckMoreEfx

mt_SetPeriod
	MOVEM.L	D1-D2/A2,-(SP)
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	LEA	mt_PeriodTable(PC),A2
	MOVEQ	#36,D2
mt_ftuloop
	CMP.W	(A2)+,D1
	DBHS	D2,mt_ftuloop
	MOVEQ	#0,D1
	MOVE.B	n_finetune(A6),D1
	MULU	#36*2,D1
	MOVE.W	-2(A2,D1.L),n_period(A6)
	MOVEM.L	(SP)+,D1-D2/A2

	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0ED0,D0 			; Notedelay
	BEQ	mt_CheckMoreEfx

	BTST	#2,n_wavecontrol(A6)
	BNE.S	mt_vibnoc
	CLR.B	n_vibratopos(A6)
mt_vibnoc
	BTST	#6,n_wavecontrol(A6)
	BNE.S	mt_trenoc
	CLR.B	n_tremolopos(A6)
mt_trenoc
	MOVE.L	n_start(A6),(A5)		; Set start
	MOVEQ.l	 #0,D0
	MOVE.W	n_length(A6),D0
	ADD.L	D0,D0
	ADD.L	D0,(A5)				; point to end of sample
	MOVE.W	D0,4(A5)			; Set length
	MOVE.W	n_period(A6),6(A5)		; Set period
	BRA	mt_CheckMoreEfx
 
mt_SetDMA
	MOVE.L	D0,-(SP)
	MOVEQ.L	#0,D0
	LEA	ch4s(PC),A5
	LEA	mt_chan4temp(PC),A6
	MOVE.L	n_loopstart(A6),10(A5)
	MOVE.W	n_replen(A6),D0
	ADD.L	D0,D0
	ADD.L	D0,10(A5)
	MOVE.W	D0,14(A5)

	MOVEQ.L	#0,D0
	LEA	ch3s(PC),A5
	LEA	mt_chan3temp(PC),A6
	MOVE.L	n_loopstart(A6),10(A5)
	MOVE.W	n_replen(A6),D0
	ADD.L	D0,D0
	ADD.L	D0,10(A5)
	MOVE.W	D0,14(A5)

	MOVEQ.L	#0,D0
	LEA	ch2s(PC),A5
	LEA	mt_chan2temp(PC),A6
	MOVE.L	n_loopstart(A6),10(A5)
	MOVE.W	n_replen(A6),D0
	ADD.L	D0,D0
	ADD.L	D0,10(A5)
	MOVE.W	D0,14(A5)

	MOVEQ.L	#0,D0
	LEA	ch1s(PC),A5
	LEA	mt_chan1temp(PC),A6
	MOVE.L	n_loopstart(A6),10(A5)
	MOVE.W	n_replen(A6),D0
	ADD.L	D0,D0
	ADD.L	D0,10(A5)
	MOVE.W	D0,14(A5)

	MOVE.L	(SP)+,D0

mt_dskip
	ADD.W	#16,mt_PattPos
	MOVE.B	mt_PattDelTime,D0
	BEQ.S	mt_dskc
	MOVE.B	D0,mt_PattDelTime2
	CLR.B	mt_PattDelTime
mt_dskc	TST.B	mt_PattDelTime2
	BEQ.S	mt_dska
	SUBQ.B	#1,mt_PattDelTime2
	BEQ.S	mt_dska
	SUB.W	#16,mt_PattPos
mt_dska	TST.B	mt_PBreakFlag
	BEQ.S	mt_nnpysk
	SF	mt_PBreakFlag
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(PC),D0
	CLR.B	mt_PBreakPos
	LSL.W	#4,D0
	MOVE.W	D0,mt_PattPos
mt_nnpysk
	CMP.W	#1024,mt_PattPos
	BLO.S	mt_NoNewPosYet
mt_NextPosition	
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(PC),D0
	LSL.W	#4,D0
	MOVE.W	D0,mt_PattPos
	CLR.B	mt_PBreakPos
	CLR.B	mt_PosJumpFlag
	ADDQ.B	#1,mt_SongPos
	AND.B	#$7F,mt_SongPos
	MOVE.B	mt_SongPos(PC),D1
	MOVE.L	mt_SongDataPtr(PC),A0
	CMP.B	950(A0),D1
	BLO.S	mt_NoNewPosYet
	CLR.B	mt_SongPos
mt_NoNewPosYet	
	TST.B	mt_PosJumpFlag
	BNE.S	mt_NextPosition
	RTS

mt_CheckEfx
	BSR	mt_UpdateFunk
	MOVE.W	n_cmd(A6),D0
	AND.W	#$0FFF,D0
	BEQ.S	mt_PerNop
	MOVE.B	n_cmd(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_Arpeggio
	CMP.B	#1,D0
	BEQ	mt_PortaUp
	CMP.B	#2,D0
	BEQ	mt_PortaDown
	CMP.B	#3,D0
	BEQ	mt_TonePortamento
	CMP.B	#4,D0
	BEQ	mt_Vibrato
	CMP.B	#5,D0
	BEQ	mt_TonePlusVolSlide
	CMP.B	#6,D0
	BEQ	mt_VibratoPlusVolSlide
	CMP.B	#$E,D0
	BEQ	mt_E_Commands
SetBack	MOVE.W	n_period(A6),6(A5)
	CMP.B	#7,D0
	BEQ	mt_Tremolo
	CMP.B	#$A,D0
	BEQ	mt_VolumeSlide
mt_Return2
	RTS

mt_PerNop
	MOVE.W	n_period(A6),6(A5)
	RTS

mt_Arpeggio
	MOVEQ	#0,D0
	MOVE.B	mt_counter(PC),D0
	DIVS	#3,D0
	SWAP	D0
	CMP.W	#0,D0
	BEQ.S	mt_Arpeggio2
	CMP.W	#2,D0
	BEQ.S	mt_Arpeggio1
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	LSR.B	#4,D0
	BRA.S	mt_Arpeggio3

mt_Arpeggio1
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#15,D0
	BRA.S	mt_Arpeggio3

mt_Arpeggio2
	MOVE.W	n_period(A6),D2
	BRA.S	mt_Arpeggio4

mt_Arpeggio3
	ASL.W	#1,D0
	MOVEQ	#0,D1
	MOVE.B	n_finetune(A6),D1
	MULU	#36*2,D1
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D1,A0
	MOVEQ	#0,D1
	MOVE.W	n_period(A6),D1
	MOVE.L D3,-(SP)
	MOVEQ	#36,D3
mt_arploop
	MOVE.W	(A0,D0.W),D2
	CMP.W	(A0)+,D1
	BHS.S	.arp4
	DBF	D3,mt_arploop
	MOVE.L (SP)+,D3
	RTS
.arp4	MOVE.W	D2,6(A5)
	MOVE.L (SP)+,D3
	RTS

mt_Arpeggio4
	MOVE.W	D2,6(A5)
	RTS

mt_FinePortaUp
	TST.B	mt_counter
	BNE	mt_Return2
	MOVE.B	#$0F,mt_LowMask
mt_PortaUp
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	mt_LowMask(PC),D0
	MOVE.B	#$FF,mt_LowMask
	SUB.W	D0,n_period(A6)
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#113,D0
	BPL.S	mt_PortaUskip
	AND.W	#$F000,n_period(A6)
	OR.W	#113,n_period(A6)
mt_PortaUskip
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,6(A5)
	RTS	
 
mt_FinePortaDown
	TST.B	mt_counter
	BNE	mt_Return2
	MOVE.B	#$0F,mt_LowMask
mt_PortaDown
	CLR.W	D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	mt_LowMask(PC),D0
	MOVE.B	#$FF,mt_LowMask
	ADD.W	D0,n_period(A6)
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#856,D0
	BMI.S	mt_PortaDskip
	AND.W	#$F000,n_period(A6)
	OR.W	#856,n_period(A6)
mt_PortaDskip
	MOVE.W	n_period(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,6(A5)
	RTS

mt_SetTonePorta
	MOVE.L	A0,-(SP)
	MOVE.W	(A6),D2
	AND.W	#$0FFF,D2
	MOVEQ	#0,D0
	MOVE.B	n_finetune(A6),D0
	MULU	#37*2,D0
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D0,A0
	MOVEQ	#0,D0
mt_StpLoop
	CMP.W	(A0,D0.W),D2
	BHS.S	mt_StpFound
	ADDQ.W	#2,D0
	CMP.W	#37*2,D0
	BLO.S	mt_StpLoop
	MOVEQ	#35*2,D0
mt_StpFound
	MOVE.B	n_finetune(A6),D2
	AND.B	#8,D2
	BEQ.S	mt_StpGoss
	TST.W	D0
	BEQ.S	mt_StpGoss
	SUBQ.W	#2,D0
mt_StpGoss
	MOVE.W	(A0,D0.W),D2
	MOVE.L	(SP)+,A0
	MOVE.W	D2,n_wantedperiod(A6)
	MOVE.W	n_period(A6),D0
	CLR.B	n_toneportdirec(A6)
	CMP.W	D0,D2
	BEQ.S	mt_ClearTonePorta
	BGE	mt_Return2
	MOVE.B	#1,n_toneportdirec(A6)
	RTS

mt_ClearTonePorta
	CLR.W	n_wantedperiod(A6)
	RTS

mt_TonePortamento
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_TonePortNoChange
	MOVE.B	D0,n_toneportspeed(A6)
	CLR.B	n_cmdlo(A6)
mt_TonePortNoChange
	TST.W	n_wantedperiod(A6)
	BEQ	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_toneportspeed(A6),D0
	TST.B	n_toneportdirec(A6)
	BNE.S	mt_TonePortaUp
mt_TonePortaDown
	ADD.W	D0,n_period(A6)
	MOVE.W	n_wantedperiod(A6),D0
	CMP.W	n_period(A6),D0
	BGT.S	mt_TonePortaSetPer
	MOVE.W	n_wantedperiod(A6),n_period(A6)
	CLR.W	n_wantedperiod(A6)
	BRA.S	mt_TonePortaSetPer

mt_TonePortaUp
	SUB.W	D0,n_period(A6)
	MOVE.W	n_wantedperiod(A6),D0
	CMP.W	n_period(A6),D0
	BLT.S	mt_TonePortaSetPer
	MOVE.W	n_wantedperiod(A6),n_period(A6)
	CLR.W	n_wantedperiod(A6)

mt_TonePortaSetPer
	MOVE.W	n_period(A6),D2
	MOVE.B	n_glissfunk(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_GlissSkip
	MOVEQ	#0,D0
	MOVE.B	n_finetune(A6),D0
	MULU	#36*2,D0
	LEA	mt_PeriodTable(PC),A0
	ADD.L	D0,A0
	MOVEQ	#0,D0
mt_GlissLoop
	CMP.W	(A0,D0.W),D2
	BHS.S	mt_GlissFound
	ADDQ.W	#2,D0
	CMP.W	#36*2,D0
	BLO.S	mt_GlissLoop
	MOVEQ	#35*2,D0
mt_GlissFound
	MOVE.W	(A0,D0.W),D2
mt_GlissSkip
	MOVE.W	D2,6(A5) 			; Set period
	RTS

mt_Vibrato
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_Vibrato2
	MOVE.B	n_vibratocmd(A6),D2
	AND.B	#$0F,D0
	BEQ.S	mt_vibskip
	AND.B	#$F0,D2
	OR.B	D0,D2
mt_vibskip
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	BEQ.S	mt_vibskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
mt_vibskip2
	MOVE.B	D2,n_vibratocmd(A6)
mt_Vibrato2
	MOVE.B	n_vibratopos(A6),D0
	LEA	mt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	n_wavecontrol(A6),D2
	AND.B	#$03,D2
	BEQ.S	mt_vib_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.S	mt_vib_rampdown
	MOVE.B	#255,D2
	BRA.S	mt_vib_set
mt_vib_rampdown
	TST.B	n_vibratopos(A6)
	BPL.S	mt_vib_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.S	mt_vib_set
mt_vib_rampdown2
	MOVE.B	D0,D2
	BRA.S	mt_vib_set
mt_vib_sine
	MOVE.B	0(A4,D0.W),D2
mt_vib_set
	MOVE.B	n_vibratocmd(A6),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#7,D2
	MOVE.W	n_period(A6),D0
	TST.B	n_vibratopos(A6)
	BMI.S	mt_VibratoNeg
	ADD.W	D2,D0
	BRA.S	mt_Vibrato3
mt_VibratoNeg
	SUB.W	D2,D0
mt_Vibrato3
	MOVE.W	D0,6(A5)
	MOVE.B	n_vibratocmd(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,n_vibratopos(A6)
	RTS

mt_TonePlusVolSlide
	BSR	mt_TonePortNoChange
	BRA	mt_VolumeSlide

mt_VibratoPlusVolSlide
	BSR.S	mt_Vibrato2
	BRA	mt_VolumeSlide

mt_Tremolo
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_Tremolo2
	MOVE.B	n_tremolocmd(A6),D2
	AND.B	#$0F,D0
	BEQ.S	mt_treskip
	AND.B	#$F0,D2
	OR.B	D0,D2
mt_treskip
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	BEQ.S	mt_treskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
mt_treskip2
	MOVE.B	D2,n_tremolocmd(A6)
mt_Tremolo2
	MOVE.B	n_tremolopos(A6),D0
	LEA	mt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	n_wavecontrol(A6),D2
	LSR.B	#4,D2
	AND.B	#$03,D2
	BEQ.S	mt_tre_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.S	mt_tre_rampdown
	MOVE.B	#255,D2
	BRA.S	mt_tre_set
mt_tre_rampdown
	TST.B	n_vibratopos(A6)
	BPL.S	mt_tre_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.S	mt_tre_set
mt_tre_rampdown2
	MOVE.B	D0,D2
	BRA.S	mt_tre_set
mt_tre_sine
	MOVE.B	0(A4,D0.W),D2
mt_tre_set
	MOVE.B	n_tremolocmd(A6),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#6,D2
	MOVEQ	#0,D0
	MOVE.B	n_volume(A6),D0
	TST.B	n_tremolopos(A6)
	BMI.S	mt_TremoloNeg
	ADD.W	D2,D0
	BRA.S	mt_Tremolo3
mt_TremoloNeg
	SUB.W	D2,D0
mt_Tremolo3
	BPL.S	mt_TremoloSkip
	CLR.W	D0
mt_TremoloSkip
	CMP.W	#$40,D0
	BLS.S	mt_TremoloOk
	MOVE.W	#$40,D0
mt_TremoloOk
	MOVE.W	D0,8(A5)
	MOVE.B	n_tremolocmd(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,n_tremolopos(A6)
	RTS

mt_SampleOffset
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	BEQ.S	mt_sononew
	MOVE.B	D0,n_sampleoffset(A6)
mt_sononew
	MOVE.B	n_sampleoffset(A6),D0
	LSL.W	#7,D0
	CMP.W	n_length(A6),D0
	BGE.S	mt_sofskip
	SUB.W	D0,n_length(A6)
	LSL.W	#1,D0
	ADD.L	D0,n_start(A6)
	RTS
mt_sofskip
	MOVE.W	#$0001,n_length(A6)
	RTS

mt_VolumeSlide
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	LSR.B	#4,D0
	TST.B	D0
	BEQ.S	mt_VolSlideDown
mt_VolSlideUp
	ADD.B	D0,n_volume(A6)
	CMP.B	#$40,n_volume(A6)
	BMI.S	mt_vsuskip
	MOVE.B	#$40,n_volume(A6)
mt_vsuskip
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)
	RTS

mt_VolSlideDown
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
mt_VolSlideDown2
	SUB.B	D0,n_volume(A6)
	BPL.S	mt_vsdskip
	CLR.B	n_volume(A6)
mt_vsdskip
	MOVE.B	n_volume(A6),D0
	MOVE.W	D0,8(A5)
	RTS

mt_PositionJump
	MOVE.B	n_cmdlo(A6),D0
	SUBQ.B	#1,D0
	MOVE.B	D0,mt_SongPos
mt_pj2	CLR.B	mt_PBreakPos
	ST 	mt_PosJumpFlag
	RTS

mt_VolumeChange
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	CMP.B	#$40,D0
	BLS.S	mt_VolumeOk
	MOVEQ	#$40,D0
mt_VolumeOk
	MOVE.B	D0,n_volume(A6)
	MOVE.W	D0,8(A5)
	RTS

mt_PatternBreak
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	MOVE.L	D0,D2
	LSR.B	#4,D0
	MULU	#10,D0
	AND.B	#$0F,D2
	ADD.B	D2,D0
	CMP.B	#63,D0
	BHI.S	mt_pj2
	MOVE.B	D0,mt_PBreakPos
	ST	mt_PosJumpFlag
	RTS

mt_SetSpeed
	MOVE.B	3(A6),D0
	BEQ	mt_Return2
	CLR.B	mt_counter
	MOVE.B	D0,mt_speed
	RTS

mt_CheckMoreEfx
	BSR	mt_UpdateFunk
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	CMP.B	#$9,D0
	BEQ	mt_SampleOffset
	CMP.B	#$B,D0
	BEQ	mt_PositionJump
	CMP.B	#$D,D0
	BEQ.S	mt_PatternBreak
	CMP.B	#$E,D0
	BEQ.S	mt_E_Commands
	CMP.B	#$F,D0
	BEQ.S	mt_SetSpeed
	CMP.B	#$C,D0
	BEQ	mt_VolumeChange
	RTS	

mt_E_Commands
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F0,D0
	LSR.B	#4,D0
	BEQ.S	mt_FilterOnOff
	CMP.B	#1,D0
	BEQ	mt_FinePortaUp
	CMP.B	#2,D0
	BEQ	mt_FinePortaDown
	CMP.B	#3,D0
	BEQ.S	mt_SetGlissControl
	CMP.B	#4,D0
	BEQ	mt_SetVibratoControl
	CMP.B	#5,D0
	BEQ	mt_SetFineTune
	CMP.B	#6,D0
	BEQ	mt_JumpLoop
	CMP.B	#7,D0
	BEQ	mt_SetTremoloControl
	CMP.B	#9,D0
	BEQ	mt_RetrigNote
	CMP.B	#$A,D0
	BEQ	mt_VolumeFineUp
	CMP.B	#$B,D0
	BEQ	mt_VolumeFineDown
	CMP.B	#$C,D0
	BEQ	mt_NoteCut
	CMP.B	#$D,D0
	BEQ	mt_NoteDelay
	CMP.B	#$E,D0
	BEQ	mt_PatternDelay
	CMP.B	#$F,D0
	BEQ	mt_FunkIt
	RTS

mt_FilterOnOff
	RTS	

mt_SetGlissControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,n_glissfunk(A6)
	OR.B	D0,n_glissfunk(A6)
	RTS

mt_SetVibratoControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,n_wavecontrol(A6)
	OR.B	D0,n_wavecontrol(A6)
	RTS

mt_SetFineTune
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	MOVE.B	D0,n_finetune(A6)
	RTS

mt_JumpLoop
	TST.B	mt_counter
	BNE	mt_Return2
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_SetLoop
	TST.B	n_loopcount(A6)
	BEQ.S	mt_jumpcnt
	SUBQ.B	#1,n_loopcount(A6)
	BEQ	mt_Return2
mt_jmploop	MOVE.B	n_pattpos(A6),mt_PBreakPos
	ST	mt_PBreakFlag
	RTS

mt_jumpcnt
	MOVE.B	D0,n_loopcount(A6)
	BRA.S	mt_jmploop

mt_SetLoop
	MOVE.W	mt_PattPos(PC),D0
	LSR.W	#4,D0
	MOVE.B	D0,n_pattpos(A6)
	RTS

mt_SetTremoloControl
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,n_wavecontrol(A6)
	OR.B	D0,n_wavecontrol(A6)
	RTS

mt_RetrigNote
	MOVE.L	D1,-(SP)
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_rtnend
	MOVEQ	#0,D1
	MOVE.B	mt_counter(PC),D1
	BNE.S	mt_rtnskp
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	BNE.S	mt_rtnend
	MOVEQ	#0,D1
	MOVE.B	mt_counter(PC),D1
mt_rtnskp
	DIVU	D0,D1
	SWAP	D1
	TST.W	D1
	BNE.S	mt_rtnend
mt_DoRetrig
	MOVE.L D0,-(SP)
	MOVEQ #0,D0
	MOVE.L	n_start(A6),(A5)		; Set sampledata pointer
	MOVE.W	n_length(A6),D0
	ADD D0,D0
	ADD.L D0,(A5)
	MOVE.W D0,4(A5)				; Set length
	MOVEQ #0,D0
	MOVE.L	n_loopstart(A6),10(A5)		; loop sample ptr
	MOVE.L	n_replen(A6),D0
	ADD D0,D0
	ADD.L D0,10(A5)
	MOVE.W D0,14(A5)
	MOVE.L (SP)+,D0
mt_rtnend
	MOVE.L	(SP)+,D1
	RTS

mt_VolumeFineUp
	TST.B	mt_counter
	BNE	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$F,D0
	BRA	mt_VolSlideUp

mt_VolumeFineDown
	TST.B	mt_counter
	BNE	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	BRA	mt_VolSlideDown2

mt_NoteCut
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	CMP.B	mt_counter(PC),D0
	BNE	mt_Return2
	CLR.B	n_volume(A6)
	MOVE.W	#0,8(A5)
	RTS

mt_NoteDelay
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	CMP.B	mt_counter,D0
	BNE	mt_Return2
	MOVE.W	(A6),D0
	BEQ	mt_Return2
	MOVE.L	D1,-(SP)
	BRA	mt_DoRetrig

mt_PatternDelay
	TST.B	mt_counter
	BNE	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	TST.B	mt_PattDelTime2
	BNE	mt_Return2
	ADDQ.B	#1,D0
	MOVE.B	D0,mt_PattDelTime
	RTS

mt_FunkIt
	TST.B	mt_counter
	BNE	mt_Return2
	MOVE.B	n_cmdlo(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,n_glissfunk(A6)
	OR.B	D0,n_glissfunk(A6)
	TST.B	D0
	BEQ	mt_Return2
mt_UpdateFunk
	MOVEM.L	A0/D1,-(SP)
	MOVEQ	#0,D0
	MOVE.B	n_glissfunk(A6),D0
	LSR.B	#4,D0
	BEQ.S	mt_funkend
	LEA	mt_FunkTable(PC),A0
	MOVE.B	(A0,D0.W),D0
	ADD.B	D0,n_funkoffset(A6)
	BTST	#7,n_funkoffset(A6)
	BEQ.S	mt_funkend
	CLR.B	n_funkoffset(A6)

	CLR.B	n_funkoffset(A6)
	MOVE.L	n_loopstart(A6),D0
	MOVEQ	#0,D1
	MOVE.W	n_replen(A6),D1
	ADD.L	D1,D0
	ADD.L	D1,D0
	MOVE.L	n_wavestart(A6),A0
	ADDQ.L	#1,A0
	CMP.L	D0,A0
	BLO.S	mt_funkok
	MOVE.L	n_loopstart(A6),A0
mt_funkok
	MOVE.L	A0,n_wavestart(A6)
	MOVEQ	#-1,D0
	SUB.B	(A0),D0
	MOVE.B	D0,(A0)
mt_funkend
	MOVEM.L	(SP)+,A0/D1
	RTS

mt_FunkTable dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

mt_VibratoTable	
	dc.b   0, 24, 49, 74, 97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120, 97, 74, 49, 24

mt_PeriodTable
; Tuning 0, Normal
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114

mt_chan1temp	dc.l	0,0,0,0,0,$00010000,0,  0,0,0,0
mt_chan2temp	dc.l	0,0,0,0,0,$00020000,0,  0,0,0,0
mt_chan3temp	dc.l	0,0,0,0,0,$00040000,0,  0,0,0,0
mt_chan4temp	dc.l	0,0,0,0,0,$00080000,0,  0,0,0,0

mt_SongDataPtr	dc.l 0

mt_speed	dc.b 6
mt_counter	dc.b 0
mt_SongPos	dc.b 0
mt_PBreakPos	dc.b 0
mt_PosJumpFlag	dc.b 0
mt_PBreakFlag	dc.b 0
mt_LowMask	dc.b 0
mt_PattDelTime	dc.b 0
mt_PattDelTime2	dc.b 0
		dc.b 0

mt_PattPos	dc.w 0

mt_mulu		dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

freqs		ds.l 2
		incbin freq37.bin		; frequency table. int.w/frac.w
		even

vols		ds.l 64
		incbin pt_volta.dat		; 65 ,256 byte lookups.
		even

		DS.L 399
my_stack	DS.L 4

dir
mt_data		incbin beebris.mod
		ENDC
