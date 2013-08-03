;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              The BBC Total Apathy MegaDemo Source Code                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 									 ;;
;;    *     *  **** *   * *****    **** *   *  **** *     *****  ****	 ;;
;;    *       *     *   *   *     *     *   * *     *     *     *	 ;;
;;    *     * *  ** *****   *     *      * *  *     *     ***    ***	 ;;
;;    *     * *   * *   *   *     *       *   *     *     *         *	 ;;
;;    ***** *  **** *   *   *      ****   *    **** ***** ***** ****	 ;;
;; 									 ;;
;;   Code: The Law   Grafix: Xerud   Music: Chrispy 'Apathetic' Noodle   ;;
;; 									 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              The BBC Total Apathy MegaDemo Source Code                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This was my first 'attempt' at a Megademo-screen (and also a game) so
;; don't expect miracles.... however, Andy's overscan now runs on an STE
;; thanks to a wonderful Welsh BBC person who I won't name.....

	lea	$2000.w,a7		; Save stack

	pea	lynx_rules(pc)	
	move.w	#$26,-(a7)
	trap	#14			; This is the 1st Trap in here!
	addq.l	#6,a7

	clr.w	-(a7)
	trap	#1			; This is the LAST Trap in here!

ram_top		equ $100000
my_ramtop	equ ram_top-$20000
full_base	equ my_ramtop+160+230
dots_base	equ my_ramtop+160+236
bott_base	equ my_ramtop+160+230+(230*228)-70
text_line	equ bott_base+(9*160)
scrl_base	equ bott_base+(160*13)+6

*************************************************************************
************* Game setup and re-initialization routines *****************
*************************************************************************

lynx_rules
	
	bsr save_system_vectors

	bsr music1
	bsr music2
	move.l #music2+4,mus_vbl 

	move.b #$12,$fffffc02.w		; disable mouse
	move.l #$2000,d0		; wait for ikbd to catch up
delay	dbra d0,delay			; with it's updating...
	move.b #$1a,$fffffc02.w		; disable stix

	move.l screen,a0		; clear junk from RAM
.allemp	clr.w (a0)+			; (Andy's menu is bound
	cmp.l #ram_top,a0		;  to fill it with crap!)
	bne.s .allemp

	bsr tit

	move.l screen,a0		; clear junk from RAM
.allem2	clr.w (a0)+			; (Andy's menu is bound
	cmp.l #ram_top,a0		;  to fill it with crap!)
	bne.s .allem2

	lea font16+34+(98*160),a0	; Draw the control
	lea bott_base,a1		; panel in the lower border
	move.l #(160*40)/4,d0		
.grfx	move.l (a0)+,d1
	eor.l #'LAW!',d1		; unscramble the grafix!
	move.l d1,(a1)+		 
	subq.l #1,d0			 
	bne.s .grfx

	lea scrl_base+$32,a0
	move.w #6,d7
.kill	rept 6
	clr.l (a0)+
	clr.l (a0)+
	endr
	lea 112(a0),a0
	dbra d7,.kill

	bsr pre_define			; font offsets
	bsr full_init			; create fullscreen

	move.l #vbl,$70.w		; init fullscreen vbl

creds	move.l #music2+4,mus_vbl
	bsr do_creds			; title screen

	cmp.l #'EXIT',which_key
	beq exit

	bsr music1
	move.l #music1+4,mus_vbl

	move.l $70.w,-(a7)		; save vbl
	move.l #plmus,$70.w		; temp. vbl

	lea $ffff8240.w,a0		; kill pallette!
	rept 8
	clr.l (a0)+
	endr

	bsr clear2			; clear all 4 planes

	lea full_base+8,a1
	move.l block+34+(160*40),d0
	move.l block+34+(160*40)+4,d1
	move.l block+34+(160*41),d3
	move.l block+34+(160*41)+4,d4
	move.l #227,d2
.leftbor	
	move.l d0,(a1)
	move.l d1,4(a1)
	move.l d3,184(a1)
	move.l d4,188(a1)
	lea 230(a1),a1
	subq.l #1,d2
	bne.s .leftbor

	move.w #385,d7			; draw frame accross the top
.tline	moveq.l #0,d0			; and bottom of the screen
	move.w d7,d0
	moveq.l #0,d1
	bsr plot_pix
	moveq.l #0,d0			; and bottom of the screen
	move.w d7,d0
	move.l #230,d1
	bsr plot_pix
	move.w d7,d0
	move.l #230*225,d1
	bsr plot_pix
	move.w d7,d0
	move.l #230*226,d1
	bsr plot_pix
	subq #1,d7
	cmp.w #29,d7
	bne.s .tline

	move.w #225,d7			; draw frame up the screen
.sline	moveq.l #31,d0			; edges (prevents overflow)
	move.l d0,d1
	move.w d7,d1
	mulu #230,d1
	bsr plot_pix
	moveq.l #30,d0			; edges (prevents overflow)
	move.l d0,d1
	move.w d7,d1
	mulu #230,d1
	bsr plot_pix
	moveq.l #0,d1
	move.l d1,d0
	move.w #384,d0
	move.w d7,d1
	mulu #230,d1
	bsr plot_pix
	moveq.l #0,d1
	move.l d1,d0
	move.w #385,d0
	move.w d7,d1
	mulu #230,d1
	bsr plot_pix
	dbra d7,.sline

	bsr make_backdrop

	move.l #'0000',sc1
	move.l #'0000',sc2

	move.l (a7)+,$70.w		; fullscreen vbl
	bsr v_sync
	
reset_game
	move.w #'T1',tur1
	move.w #'T2',tur2
	
	clr.b $fffffc02.w
	move.b $fffffc02.w,d0		; pull 'null' character from IKBD
	bclr.b #6,$fffffa11.w	

	bsr clear			; clear the fullscreen

	move.w #1,do_intro

	bsr check_overflow_score	; Ha! No ":"'s in my scores...
	bsr re_plot_scores		; Update the scores

	move.l #230*113,y_pos1		; set initial x/y/direction
	move.l #230*113,y_pos2
	move.l #33,x_pos1
	move.l #382,x_pos2
	move.b $fffffc02.w,d0		; pull possible crap from IKBD

	move.w #12,way1			; reset initial directions
	move.w #8,way2

	move.w way1,d0			; plot initial player #1
	lea j_tab1(pc),a0
	move.l (a0,d0.w),a0
	jsr (a0)
	bsr plot_1

	move.w way2,d0			; plot initial player #2
	lea j_tab2(pc),a0
	move.l (a0,d0.w),a0
	jsr (a0)
	bsr plot_1

	clr.l ch1			; clear colision detection

	tst.w $fffffc02.w
	bclr.b #6,$fffffa11.w	


**********************************************************************
**************** Gameplay routines and other stuff *******************
**********************************************************************


main	bsr v_sync

	bsr check_direction1		; scan player #1
	move.l computer_flag,a0
	jsr (a0)			; scan player #2/computer

	move.w way1,d0			; plot new player #1
	lea j_tab1(pc),a0
	move.l (a0,d0.w),a0
	jsr (a0)
	bsr plot_1

	move.w way2,d0			; plot new player #2
	lea j_tab2(pc),a0
	move.l (a0,d0.w),a0
	jsr (a0)
	bsr plot_2

	cmp.l #'XXXX',ch1		; Both crashed (Null!)
	beq reset_game
	cmp.w #'XX',ch1			; PL1 crash?
	bne.s not1
	addq.l #1,sc2
	bra reset_game
not1	cmp.w #'XX',ch2			; PL2 crash?
	bne.s .turbo1
	addq.l #1,sc1
	bra reset_game

.turbo1	cmp.w #'T1',tur1
	bne.s .turbo2

	move.w way1,d0			; plot new player #1
	lea j_tab1(pc),a0
	move.l (a0,d0.w),a0
	jsr (a0)
	bsr plot_1

.turbo2	cmp.w #'T2',tur2
	bne.s .check_hit
	move.w way2,d0			; plot new player #2
	lea j_tab2(pc),a0
	move.l (a0,d0.w),a0
	jsr (a0)
	bsr plot_2

.check_hit
	cmp.l #'XXXX',ch1		; Both crashed (Null!)
	beq reset_game
	cmp.w #'XX',ch1			; PL1 crash?
	bne.s not1a
	addq.l #1,sc2
	bra reset_game
not1a	cmp.w #'XX',ch2			; PL2 crash?
	bne.s .pause
	addq.l #1,sc1
	bra reset_game

.pause	cmp.b #$19,$fffffc02.w		; P pushed?
	bne.s .space

	move.b $fffffc02.w,d0		; Kill possible crap data
	move.w #$2000,d0		; and wait a while
.wait	dbra d0,.wait

.hangup	cmp.b #$19,$fffffc02.w		; P pushed again?
	bne.s .hangup

	move.b $fffffc02.w,d0		; Kill possible crap data
	bclr.b #6,$fffffa11.w	

	bsr re_plot_scores		; re-do the scores

	move.b $fffffc02.w,d0		; Kill possible crap data
	bclr.b #6,$fffffa11.w	

	move.w #$2000,d0		; and wait a while
.wait2	dbra d0,.wait2

.space	cmp.b #$01,$fffffc02.w		; 'ESC' pushed?
	bne main
	bsr music2
	bra creds

exit	bsr load_system_vectors

	rts

screen	dc.l my_ramtop

v_sync	move.w frames,d0		; wait v-sync
.holder	cmp.w frames,d0
	beq.s .holder
	rts

check_direction1
	move.b $fffffc02.w,d0
	cmp.b #$1d,d0
	bne.s .othr
	eor.w #'T1',tur1
	bra.s .out1
.othr	cmp.b #$10,d0			; scan up
	bne.s .up
	cmp.w #4,way1
	beq.s .up
	move.w #0,way1
	bra.s .out1
.up	cmp.b #$1e,d0			; scan down
	bne.s .dwn
	cmp.w #0,way1
	beq.s .dwn
	move.w #4,way1
	bra.s .out1
.dwn	cmp.b #$2c,d0			; scan left
	bne.s .lft
	cmp.w #12,way1
	beq.s .lft
	move.w #8,way1
	bra.s .out1
.lft	cmp.b #$2d,d0			; scan right
	bne.s .out1
	cmp.w #8,way1
	beq.s .out1
	move.w #12,way1
.out1	rts

; this will either say:-
; dc.l human
; or
; dc.l computer

computer_flag	dc.l computer

computer
	move.l x_pos2,d0		; get x/y computer
	move.l y_pos2,d1
	move.w way2,d3
	lea test_table(pc),a0
	move.l (a0,d3.w),a0
	jsr (a0)			; call appropriate detection
	tst.w d0			; anything in path
	bmi re_calc_direction		; call if yes

;
; Einstein difficulty routine addition....
;
; From here on in the logic is pretty wild in places,
; but I believe this biker is now intelligent enough
; to call it quits with about 100,000,000,000,000 brain cells....
; (Thats 99,999,999,999,999 more than S.Stallone level)
;

	cmp.l #'HARD',level
	bne _rts

	cmp.w #'T1',tur1
	beq.s do_turbo
	clr.w tur2
	bra.s turbo_out
do_turbo	
	move.w #'T2',tur2
turbo_out
	move.l x_pos1,d0	; get pl1 x/y
	move.l y_pos1,d1
	move.l x_pos2,d2	; get pl2 x/y
	move.l y_pos2,d3

	sub.l d0,d2		; sub pl1x from pl2 x
	sub.l d1,d3		; sub pl1y from pl2 y

	tst.l d2		; -ve?
	bpl check_q
	neg.l d2		; make +ve

check_q	tst.l d3		; -ve?
	bpl within_range_
	neg.l d3		; make +ve

within_range_
	moveq.w #-1,d5		; is player 1 within 50x50 of player 2?
	divu #230,d3		; convert y into axis value
	
	cmp.w #50,d2
	blt.s not_x_
	moveq #1,d5
not_x_	cmp.w #50,d3
	blt.s not_y_
	moveq #1,d5
not_y_	tst.w d5
	bmi einstein		; home in!

_rts	rts

einstein
	moveq.w #-1,d5		; is player 1 within 50x50 of player 2?
	divu #230,d3		; convert y into axis value
	
	cmp.w #2,d2
	blt.s _not_x_
	moveq #1,d5
_not_x_	cmp.w #2,d3
	blt.s _not_y_
	moveq #1,d5
_not_y_	tst.w d5
	bmi _rts		; home in!

	sub.l d2,d3		; check which distance is greater
	bmi xgreat

ygreat	bsr ygreater		; aargh! y distance is greater 
	bra.s xytest
xgreat	bsr xgreater		; aargh! x distance is greater

xytest	move.l x_pos2,d0	; that's all very well, but
	move.l y_pos2,d1	; if I home in on the other player
	move.w way2,d3		; will I die by hitting any trails
	lea test_table(pc),a0	; that stand between us?
	move.l (a0,d3.w),a0
	jsr (a0)
	tst.w d0		; well, whats the answer, matey?
	bmi self_preservation	; you dick, sound collision, hard bank! 
	rts			; pheew! you lucky sod!
	
ygreater
	move.l y_pos1,d0	; the y distance is greater
	move.l y_pos2,d1	; but do I want to go....
	sub.l d0,d1
	bmi.s _godown
	move #0,way2		; up....
	rts
_godown
	move #4,way2		; or down?
	rts
xgreater
	move.l x_pos1,d0	; the x distance is greater
	move.l y_pos2,d1	; but do I want to go....
	sub.l d0,d1
	bmi.s _goright
	move.w #8,way2		; right....
	rts
_goright
	move.w #12,way2		; or left....
	rts

re_calc_direction
	move.l x_pos1,d0	; get pl1 x/y
	move.l y_pos1,d1
	move.l x_pos2,d2	; get pl2 x/y
	move.l y_pos2,d3

	sub.l d0,d2		; sub pl1x from pl2 x
	sub.l d1,d3		; sub pl1y from pl2 y

	tst.l d2		; -ve?
	bpl check_y
	neg.l d2		; make +ve

check_y	tst.l d3		; -ve?
	bpl within_range
	neg.l d3		; make +ve

within_range
	moveq.w #-1,d5		; is player 1 within 50x50 of player 2?
	divu #230,d3		; convert y into axis value
	
	cmp.w #50,d2
	blt.s not_x
	moveq #1,d5
not_x	cmp.w #50,d3
	blt.s not_y
	moveq #1,d5
not_y	tst.w d5
	bpl self_preservation	; not in range, don't home in!

	sub.l d2,d3		; check which distance is greater
	bmi x_great

y_great	bsr y_greater		; aargh! y distance is greater 
	bra.s xy_test
x_great	bsr x_greater		; aargh! x distance is greater

xy_test	move.l x_pos2,d0	; that's all very well, but
	move.l y_pos2,d1	; if I home in on the other player
	move.w way2,d3		; will I die by hitting any trails
	lea test_table(pc),a0	; that stand between us?
	move.l (a0,d3.w),a0
	jsr (a0)
	tst.w d0		; well, whats the answer, matey?
	bmi self_preservation	; you dick, sound collision, hard bank! 
	rts			; pheew! you lucky sod!
	
y_greater
	move.l y_pos1,d0	; the y distance is greater
	move.l y_pos2,d1	; but do I want to go....
	sub.l d0,d1
	bmi.s _go_down
	move #0,way2		; up....
	rts
_go_down
	move #4,way2		; or down?
	rts
x_greater
	move.l x_pos1,d0	; the x distance is greater
	move.l y_pos2,d1	; but do I want to go....
	sub.l d0,d1
	bmi.s _go_right
	move.w #12,way2		; right....
	rts
_go_right
	move.w #8,way2		; or left....
	rts

; up=0  down=4  left=8  right=12

self_preservation	
	move.l x_pos2,d0	; so, you tried to get me killed, huh?
	move.l y_pos2,d1	; good job I have good instincts.....
	move.w way2,d2		; which bleedin' way am I going now?
	lea preserve_table(pc),a0
	move.l (a0,d2),a0
	jsr (a0)		; ok, tactics for that direction....
	move.w d0,way2		; look, buster, I wanna go this way!
	rts

preserve_table
	dc.l ch_left,ch_right,ch_up,ch_down

ch_left	sub.l #2,d0		; I'm hit going up, so if I check left
	bsr test_pix		; I know which way to turn		
	tst.w d0
	bmi.s __right
	move.w #8,d0
	rts
__right	move.w #12,d0
	rts

ch_right
	addq.l #2,d0		; I'm hit going down, so if I check right
	bsr test_pix		; I know which way to turn
	tst.w d0
	bmi.s __left
	move.w #12,d0
	rts
__left	move.w #8,d0
	rts

ch_up	add.l #230*2,d1		; I'm hit going left, so if I check down
	bsr test_pix		; I know my verticals
	tst.w d0
	bmi.s __down
	move.w #4,d0
	rts
__down	move.w #0,d0
	rts

ch_down	sub.l #230*2,d1		; I'm hit going right, so if I check up
	bsr test_pix		; I can drive like I really do!
	tst.w d0
	bmi.s __up
	move.w #0,d0
	rts
__up	move.w #4,d0
	rts

; Routines to check if red alert (collision imminent) should
; be sounded.....

test_table	
	dc.l test_u,test_d,test_l,test_r

test_d	add.l #230*3,d1		; check down... even pixels
	bsr test_pix
	tst.w d0
	beq.s _odd1
	rts
_odd1	move.l x_pos2,d0	; and odd pixels...
	move.l y_pos2,d1
	add.l #230*2,d1
	bra test_pix

test_u	sub.l #230*3,d1		; check above... even pixels
	bsr test_pix
	tst.w d0
	beq.s _odd2
	rts
_odd2	move.l x_pos2,d0	; and odd pixels...
	move.l y_pos2,d1
	sub.l #230*2,d1
	bra test_pix

test_l	subq.l #3,d0		; check left... even pixels
	bsr test_pix
	tst.w d0
	beq.s _odd3
	rts
_odd3	move.l x_pos2,d0	; and odd pixels...
	move.l y_pos2,d1
	subq.l #2,d0
	bra test_pix

test_r	addq.l #3,d0		; well, I think you know the last
	bsr test_pix		; part of this by now.....
	tst.w d0
	beq.s _odd4		; check up,down,left and righ't!
	rts			; the ultimate green cross code.
_odd4	move.l x_pos2,d0
	move.l y_pos2,d1	; TRON would be proud of you.
	addq.l #2,d0		; don't lose your disk!
	bra test_pix


***** ok, dick, if player two crashes now, it's your fault *****

human	move.b $fffffc02.w,d0
	cmp.b #$70,d0
	bne.s .othr
	eor.w #'T2',tur2
	bra.s .out2
.othr	cmp.b #$69,d0			; scan up
	bne.s .up1
	cmp.w #4,way2
	beq.s .up1
	move.w #0,way2
	bra.s .out2
.up1	cmp.b #$6c,d0			; scan down
	bne.s .dwn1
	cmp.w #0,way2
	beq.s .dwn1
	move.w #4,way2
	bra.s .out2
.dwn1	cmp.b #$6d,d0			; scan left
	bne.s .lft1
	cmp.w #12,way2
	beq.s .lft1
	move.w #8,way2
	bra.s .out2
.lft1	cmp.b #$6e,d0			; scan right
	bne.s .out2
	cmp.w #8,way2
	beq.s .out2
	move.w #12,way2
.out2	rts


j_tab1	dc.l up1,down1,left1,right1

up1	sub.l #230,y_pos1	; go up
	rts
down1	add.l #230,y_pos1	; go down
	rts
left1	sub.l #1,x_pos1		; go left
	rts		
right1	add.l #1,x_pos1		; go right
	rts

plot_1	move.l x_pos1,d0	
	move.l y_pos1,d1
	bsr plot_pix
	move.w d6,ch1
	rts

j_tab2	dc.l up2,down2,left2,right2

up2	sub.l #230,y_pos2
	rts
down2	add.l #230,y_pos2
	rts
left2	sub.l #1,x_pos2
	rts
right2	add.l #1,x_pos2
	rts

plot_2	move.l x_pos2,d0
	move.l y_pos2,d1
	bsr plot_pix
	move.w d6,ch2
	rts

plot_pix
	lea dots_base,a1	; base of screen
	lea x_table(pc),a0	; base of x-table
	add d0,d0		; mult x by 4
	add d0,d0
	add.l d0,a0		; add to table address
	add.w (a0)+,a1		; pull offset
	add.l d1,a1		; add to screen address
	move.w (a1),d0		; pull screen contents into d0
	move.w (a0),d1		; pull bit to set
	bset d1,d0		; set bit
	beq.s .ok		; skip if nothing hit
	move.w #'XX',d6		; set flag for collision
	bra.s .out
.ok	move.w #'  ',d6		; clear flag for collision
.out	move.w d0,(a1)		; move to screen
	rts

test_pix
	lea dots_base,a1
	lea x_table(pc),a0
	add d0,d0
	add d0,d0
	add.l d0,a0
	add.w (a0)+,a1
	add.l d1,a1
	move.w (a1),d0	
	move.w (a0),d1
	bset d1,d0
	bne.s .hit
	moveq #0,d0
	rts
.hit	moveq #-1,d0
	rts


xxx	set 0			; table of x-position bits to set 
x_table	rept 29			; and offset to add to scanline
	dc.w xxx,$f
	dc.w xxx,$e
	dc.w xxx,$d
	dc.w xxx,$c
	dc.w xxx,$b
	dc.w xxx,$a
	dc.w xxx,$9
	dc.w xxx,$8
	dc.w xxx,$7
	dc.w xxx,$6
	dc.w xxx,$5
	dc.w xxx,$4
	dc.w xxx,$3
	dc.w xxx,$2
	dc.w xxx,$1
	dc.w xxx,$0
xxx	set xxx+8
	endr


clear	lea dots_base+460,a0
	move.l #225,d0
.er
xxx	set 16
	rept 22
	clr.w xxx(a0)
xxx	set xxx+8
	endr	
	lea 230(a0),a0
	subq.l #1,d0
	cmp.l #2,d0
	bne .er
	rts

make_backdrop
	lea dots_base+454+16,a1
	moveq #7,d6			; 07 vertical
vert	moveq #11,d7			; 11 horizontal
horiz	bsr do_1_block
	lea 16(a1),a1
	subq.l #1,d7
	bne.s horiz
	lea  -176(a1),a1
	lea 230*32(a1),a1
	subq.l #1,d6
	bne.s vert
	rts

do_1_block
	lea block+34,a0
xxx	set 0
yyy	set 0
	rept 32
	move.l xxx(a0),yyy(a1)
	move.w xxx+4(a0),yyy+4(a1)
	move.l xxx+8(a0),yyy+8(a1)
	move.w xxx+12(a0),yyy+12(a1)
xxx	set xxx+160
yyy	set yyy+230
	endr
	rts

clear2	move.l screen,a0
	move.l #(226*230)/4,d0
.er	clr.l (a0)+	
	subq.l #1,d0
	bne.s .er
	rts

kill_pal
	lea $ffff8240.w,a0
	rept 8
	clr.l (a0)+
	endr
	rts

do_pal	lea $ffff8240.w,a0
	clr.w (a0)+
	rept 15
	move.w #$777,(a0)+
	endr
	rts


full_init
	stop	#$2300
	move	#$2700,sr
	clr.b	$ffff8260.w
	move.l	#hbl,$68.w
	move.b	#0,$fffffa07.w
	move.b	#0,$fffffa09.w
	move.b	screen+1,$ffff8201.w
	move.b	screen+2,$ffff8203.w
	move	#$2300,sr
	rts

save_system_vectors
	movem.l $ffff8240.w,d0-7
	movem.l d0-7,_pall
	move.w sr,_sr
	move.w #$2700,sr
	move.l $70.w,_70
	move.l $68.w,_68
	move.b $ffff8260.w,_8260
	move.b $fffffa07.w,_fa07
	move.b $fffffa09.w,_fa09
	move.b $ffff8201.w,_8201
	move.b $ffff8203.w,_8203
	rts

load_system_vectors
	move.w #$2700,sr
	movem.l _pall,d0-7
	movem.l d0-7,$ffff8240.w
	move.l _70,$70.w
	move.l _68,$68.w
	move.b _8260,$ffff8260.w
	move.b _fa07,$fffffa07.w
	move.b _fa09,$fffffa09.w
	move.b _8201,$ffff8201.w
	move.b _8203,$ffff8203.w
	move.b #$80,$fffffc02.w
	move.l #$3000,d0
wait11	dbra d0,wait11
	move.b #$1,$fffffc02.w
	move.l #$8080000,$ffff8800.w	; with no sound on
	move.l #$9090000,$ffff8800.w
	move.l #$a0a0000,$ffff8800.w
	move.w _sr,sr
	rts

vbl
	move.w	#33,bord_cnt		Set up all border killer
	st	vbl_done		All systems go!
	and.w 	#$f1ff,sr		HBL
	and.w	#$f1ff,(a7)		and to stack for RTE
	movem.l d0-a6,-(a7)
	addq.w #1,frames
	tst.w do_intro
	bmi.s .1
	movem.l block+2,d0-7
	movem.l d0-7,$ffff8240.w
.1	bsr scroll
	movem.l (a7)+,d0-a6
	rte

hbl	subq.w	#1,bord_cnt		Right line?
	bpl	_rte			Nope,so exit
	move	#$2700,sr		Yep,kill that border!
	movem.l	d0-d7/a0-a6,-(a7)	Save reggies
	lea	$ff8209,a0		Video address counter low
	lea	$ff8260,a1		Resolution
	move.w	#8,d0			Delay loop 1
.1	nop
	dbf	d0,.1
	clr.b	$ffff820a.w		60 Hz
	moveq	#3,d0			Delay loop 2
.2	nop
	dbf	d0,.2
	move.b	#2,$ffff820a.w		50 Hz
 
	moveq	#0,d0			Takes reggies d0-d3,a0-a1
	moveq	#16,d1
	moveq	#2,d2			constant
	moveq	#0,d3			constant

.wait	move.b	(a0),d0			Sync in
	beq.s	.wait
	sub	d0,d1
	lsl.w	d1,d0
		
;	nop
	moveq	#21,d0		
.del1	nop
	dbf	d0,.del1

	lea	$ff820a,a0		sync modus
	move	#226,d0			Kill 227 standard borders

*** Remove sides

loop1	nop
	nop
	move.b	d2,(a1)			to monochrome
	nop
	move.b	d3,(a1)			to lo-res

	dcb.w 89,$4e71

	move.b	d3,(a0)
	nop
	move.b	d2,(a0)
	dcb.w	11,$4e71
	move.b	d2,(a1)
	nop
	move.b	d3,(a1)
	dcb.w	8,$4e71
	dbf	d0,loop1

*** Remove sides and bottom
	nop
	move.b	d2,(a1)			to monochrome
	nop
	move.b	d3,(a1)			to lo-res
	moveq	#20,d1
.del3	nop
	dbf	d1,.del3
	nop
	nop
	nop
	move.b	d3,(a0)
	nop
	move.b	d2,(a0)
	dcb.w	12,$4e71
	move.b	d2,(a1)
	nop
	move.b	d3,(a1)
	move.b	d3,(a0)			Lower border 60 Hz
	clr.w $ffff8240.w
	dcb.w	10,$4e71
*** next line
	move.b	d2,(a0)			Lower border 50 Hz
	clr.w $ffff8240.w
	tst.w do_intro
	bmi.s .1
	movem.l font16+2,d0-7		Font Pallette!
	movem.l d0-7,$ffff8240.w
.1	move.l mus_vbl,a0
	jsr (a0)
	movem.l	(a7)+,d0-d7/a0-a6
	or.w	#$300,(a7)		Kill HBL interrupt

_rte	rte

plmus	movem.l d0-a6,-(a7)
	lea $ffff8240.w,a0
	rept 8
	clr.l (a0)+
	endr
	move.l mus_vbl,a0
	jsr (a0)
	addq.w #1,frames
	movem.l (a7)+,d0-a6
	rte


music1	incbin tiger1.mus
	even
music2	incbin tiger2.mus
	even


check_overflow_score
	cmp.l #'999:',sc1	; check pl1 for 9999 wrap
	bne.s .1
	move.l #'0000',sc1
.1	cmp.l #'999:',sc2	; check pl2 for 9999 wrap
	bne.s .2
	move.l #'0000',sc2

.2	cmp.b #':',sc1+3	; check for units wrap
	bne.s .3
	move.b #'0',sc1+3
	addq.b #1,sc1+2
	cmp.b #':',sc1+2
	bne.s .3
	move.b #'0',sc1+2
	addq.b #1,sc1+1
	cmp.b #':',sc1+1
	bne.s .3
	move.b #'0',sc1+1
	addq.b #1,sc1

.3	cmp.b #':',sc2+3	; check for units wrap
	bne.s .4
	move.b #'0',sc2+3
	addq.b #1,sc2+2
	cmp.b #':',sc2+2	
	bne.s .4
	move.b #'0',sc2+2
	addq.b #1,sc2+1
	cmp.b #':',sc2+1
	bne.s .4
	move.b #'0',sc2+1
	addq.b #1,sc2

.4	rts


; call with a6=27 character string, a1 address to plot at

ovr_tab	dc.l ovr0,ovr1,ovr2,ovr3,ovr4,ovr5,ovr6,ovr7,ovr8,ovr9,ovra,ovrb
	dc.l ovrc,ovrd,$ffffffff

ovr0	DC.B "    THE B.B.C. PRESENT    ",$ff
ovr1	DC.B "                          ",$FF
ovr2	DC.B "       LIGHT CYCLES       ",$FF
ovr3	DC.B "   THE OVERSCAN VERSION   ",$FF
ovr4	DC.B "                          ",$FF
ovr5	DC.B "         CREDITS:         ",$FF
ovr6	DC.B "                          ",$FF
ovr7	DC.B "  CODING: THE LAW         ",$FF
ovr8	DC.B "  GRAFIX: XERUD           ",$FF
ovr9	DC.B "  SONIXX: CHRISPY NOODLE  ",$FF
ovra	DC.B "                          ",$FF
ovrb	DC.B "--------------------------",$FF
ovrc	DC.B "                          ",$FF
ovrd	DC.B "                          ",$FF
	even 

one_ply	DC.B "   MODE: HUMAN VS C.P.U   ",$FF
two_ply	DC.B "   MODE: HUMAN VS HUMAN   ",$FF
	even
easy	DC.B "   C.P.U IS S. STALLONE   ",$FF
hard	DC.B "   C.P.U IS A. EINSTEIN   ",$FF
	even
lineadd	dc.l 0
lineedd	dc.l 0

do_creds
	move.l $70.w,-(a7)

	move.l #plmus,$70.w
	lea $ffff8240.w,a0
	rept 8
	clr.l (a0)+
	endr

	lea full_base,a0
	move.l #(227*230)/4,d0
wipe	clr.l (a0)+
	subq.l #1,d0
	bne.s wipe

	lea ovr_tab(pc),a0
	lea full_base,a1
.in	move.l (a0)+,a6
	cmp.l #$ffffffff,a6
	beq.s .setup
	cmp.l #ovrc,a6
	bne.s .notlin
	move.l a1,lineadd
.notlin	cmp.l #ovrd,a6
	bne.s .notln2
	move.l a1,lineedd
.notln2	move.l a6,-(a7)
	move.l a0,-(a7)	
	move.l a1,-(a7)
	move.l #overscan_print,jsrhere
	bsr do_a_char
	move.l (a7)+,a1
	move.l (a7)+,a0
	move.l (a7)+,a6
	lea 230*16(a1),a1
	bra.s .in
.setup	move.l #'EASY',level
	move.l lineedd,a1
	lea easy(pc),a6
	bsr do_a_char
	move.l #computer,computer_flag
	move.l lineadd,a1
	lea one_ply(pc),a6
	bsr do_a_char
	move.w #1,do_cols
	move.w #-1,do_intro
	bsr v_sync
	move.l (a7)+,$70.w
	bsr v_sync
	movem.l font16+2,d0-7		; pallette
	movem.l d0-7,$ffff8240.w
.keys	cmp.b #$2,$fffffc02.w
	bne.s .two
	move.l lineadd,a1
	lea one_ply(pc),a6
	bsr do_a_char
	move.l #computer,computer_flag
	bra.s .keys
.two	cmp.b #$3,$fffffc02.w
	bne.s .three
	move.l lineadd,a1
	lea two_ply(pc),a6
	bsr do_a_char
	move.l #human,computer_flag
	bra.s .keys
.three	cmp.b #$4,$fffffc02.w
	bne.s .four
	move.l lineedd,a1
	lea easy(pc),a6
	bsr do_a_char
	move.l #'EASY',level
	bra .keys
.four	cmp.b #$5,$fffffc02.w
	bne.s .space
	move.l lineedd,a1
	lea hard(pc),a6
	bsr.s do_a_char
	move.l #'HARD',level
	bra .keys
.space	cmp.b #$39,$fffffc02.w
	bne.s .esc
	move.l #'EXIT',which_key
	bra.s _exmenu
.esc	cmp.b #$01,$fffffc02.w
	bne .keys
	move.l #'ESC!',which_key
_exmenu	rts

	
; call with a6=14 character string terminated with $ff
; a1-address to print to!

print_line
	move.l #normal_print,jsrhere
	bsr.s do_a_char
	rts

re_plot_scores
	move.l #normal_print,jsrhere
	lea sc1,a6
	lea text_line+8,a1
	bsr.s do_a_char

	lea sc2,a6
	lea text_line+120,a1
	bsr.s do_a_char

	rts

; a6-address of string (term with -1)
; a1-address to plot characters to

do_a_char
	moveq.l #0,d1
	move.b (a6)+,d1
	cmp.b #$ff,d1
	beq.s rts
	sub.w #$20,d1
	add d1,d1
	add d1,d1
	lea ptable,a5
	move.l (a5,d1),a0
	add.l ststart16,a0
	dc.w $4eb9
jsrhere	dc.l 0
	addq.l #8,a1
	bra.s do_a_char
rts	rts

normal_print
xxx	set 0
	rept 15
	move.l xxx(a0),d6
	eor.l #'LAW!',d6
	move.l d6,xxx(a1)
	move.l xxx+4(a0),d6
	eor.l #'LAW!',d6
	move.l d6,xxx+4(a1)
xxx	set xxx+160
	endr
	rts

overscan_print
xxx	set 0
yyy	set 0
	rept 15
	move.l yyy(a0),d6
	eor.l #'LAW!',d6
	move.l d6,xxx(a1)
	move.l yyy+4(a0),d6
	eor.l #'LAW!',d6
	move.l d6,xxx+4(a1)
xxx	set xxx+230
yyy	set yyy+160
	endr
	rts

scroll	
.faster	subq.w #1,scrl
	bne.s .go_scrl

.get2	move.w #6,scrl
	moveq.l #0,d1
	move.l tpnt,a0

.back	move.b (a0),d1
	sub.w #$20,d1
	cmp.b #$df,d1
	bne.s .next

.wrap	move.l #text,tpnt
	bra.s .get2

.next	addq.l #1,tpnt

.next_ch
	add d1,d1
	add d1,d1
	lea ptable2,a1
	move.l (a1,d1),d1	

.out	move.l ststart,A0
	add.l d1,a0
	lea chbuff,a1
	moveq.l #6,d2

.fillbuf
	move.w (a0),d6
	eor.w #'XX',d6
	move.w d6,(a1)+
	lea 160(a0),a0
	subq #1,d2
	bne.s .fillbuf

.go_scrl
	lea chbuff,a0
	lea scrl_base,a1
	moveq.l #5,d2
.rows	lea 160(a1),a1
	lsl.w (a0)+	
	roxl.w $60(a1)
	roxl.w $58(a1)
	roxl.w $50(a1)
	roxl.w $48(a1)
	roxl.w $40(a1)
	roxl.w $38(a1)
	subq #1,d2
	bne.s .rows
.outg	rts


pre_define
	move.l #text,tpnt
	move.l #font+34,ststart
	move.l #font16+34,ststart16

	moveq.l #$1f,d0
	lea ptable,a3
	lea ptable2,a4
.def_1	addq.l #1,d0
	move.l d0,d1
	bsr.s .which_line
	move.l d1,d2
	sub.l #$20,d1
	asl #4,d1
	add.l offset,d1
	move.l d1,(a3)+
	sub.l #$20,d2
	asl #4,d2
	add.l offset2,d2
	move.l d2,(a4)+
	cmp.l #$5e,d0
	bne.s .def_1
	rts

.which_line
	cmp.b #'R',d1
	blt.s .gruff1
	move.l #76*160,offset
	move.l #160+(31*160)*5,offset2
	rts
.gruff1	cmp.b #'H',d1
	blt.s .gruff2
	move.l #61*160,offset
	move.l #160+(31*160)*4,offset2
	rts
.gruff2	cmp.b #'>',d1
	blt.s .gruff3
	move.l #46*160,offset
	move.l #160+(31*160)*3,offset2
	rts
.gruff3	cmp.b #'4',d1
	blt.s .gruff4
	move.l #31*160,offset
	move.l #160+(31*160)*2,offset2
	rts
.gruff4	cmp.b #'*',d1
	blt.s .gruff5
	move.l #16*160,offset
	move.l #160+(31*160),offset2
	rts
.gruff5	move.l #160,offset
	move.l #160,offset2
	rts


tit	stop	#$2300
	move	#$2700,sr
	clr.b	$ffff8260.w
	move.l	#vbl_creds,$70.w
	move.b	#0,$fffffa07.w
	move.b	#0,$fffffa09.w
	move.b screen+1,$ffff8201.w
	move.b screen+2,$ffff8203.w
	
	lea picdat,a0
	move.l screen,a1
	move.l #(200*230)/4,d0
doall	move.l (a0)+,(a1)+
	subq.l #1,d0
	bne.s doall

	move	#$2300,sr

boll	cmp.b #$39,$fffffc02.w
	bne.s boll

	move	#$2700,sr
	move.l	#plmus,$70.w
	move	#$2300,sr
	rts

vbl_creds
	move	#$2700,sr		Yep,kill that border!
	movem.l	d0-d7/a0-a6,-(a7)	Save reggies

	movem.l picpal,d0-7
	movem.l d0-7,$ffff8240.w

	lea paldat,a2

	lea	$ff8209,a0	Video address counter low
	lea	$ff8260,a1	Resolution
	move.w	#9,d0		Delay loop 1
.1a	nop
	dbf	d0,.1a
	clr.b	$ffff820a.w	60 Hz
	moveq	#3,d0		Delay loop 2
.2a	nop
	dbf	d0,.2a
	move.b	#2,$ffff820a.w	50 Hz
 
	moveq	#0,d0		Takes reggies d0-d3,a0-a1
	moveq	#16,d1
	moveq	#2,d2		constant
	moveq	#0,d3		constant

.waita	move.b	(a0),d0		Sync in
	beq.s	.waita
	sub	d0,d1
	lsl.w	d1,d0
		
	nop
	moveq	#21,d0		
.del1a	nop
	dbf	d0,.del1a

	lea	$ff820a,a0	; sync modus
	move	#199,d0		; Kill 227 standard borders

*** Remove sides

loop1a	nop
	move.b	d2,(a1)		; to monochrome
	nop
	move.b	d3,(a1)		; to lo-res

	lea $ffff8240.w,a4
	rept 16
	move.w (a2)+,(a4)+
	endr
	dcb.w  39,$4e71		

	move.b	d3,(a0)
	nop
	move.b	d2,(a0)
	dcb.w	12,$4e71
	move.b	d2,(a1)
	nop
	move.b	d3,(a1)
	dcb.w	8,$4e71
	dbf	d0,loop1a

	move.l mus_vbl,a0
	jsr (a0)

	movem.l	(a7)+,d0-d7/a0-a6
	rte

picpal	incbin credits.pal
	even
picdat	incbin credits.ovr
	even
paldat	rept 27
	dc.w $0,$400,$510,$620,$730,$740,$751,$762,$773,$774,$111
	dc.w $222,$333,$444,$555,$666
	endr
	rept 173
	dc.w $0,$400,$301,$620,$402,$740,$503,$705,$604,$777,$111
	dc.w $222,$333,$444,$555,$666
	endr
	even
font	incbin 7x7.inv
	even
font16	incbin shrink3.inv
	even
block	incbin block2.pi1
	even

text	DC.B "         "
	DC.B "WELCOME TO LIGHT CYCLES, BBC STYLE!   "
	DC.B "OK, FIRST I SUPPOSE I HAD "
	DC.B "BETTER TELL YOU ALL THE KEYS... HERE THEY COME...      "
	DC.B "ON THE TITLE SCREEN YOU CAN PRESS...    "
	DC.B '"1" - SELECT ONE PLAYER MODE    '
	DC.B '"2" - SELECT TWO PLAYER MODE    '
	DC.B '"3" - SELECT STALLONE MODE FOR CPU  (EASY - CPU HAS TURBO ONLY)   '
	DC.B '"4" - SELECT EINSTEIN MODE FOR CPU  (HARD - CPU TOGGLES WITH YOU)   '
	DC.B '"SPACE" - TO QUIT TO MAIN MENU    '
	DC.B '"ESC" - TO ENTER THE GAME GRID    '
	DC.B "    WHILE PLAYING PUSH....    "
	DC.B '"P" - TOGGLE PAUSE MODE    '
	DC.B '"ESC" - QUIT BACK TO CREDIT AND SETUP SCREEN    '
	DC.B "PLAYER ONE.....     "
	DC.B '"Q" - UP   '
	DC.B '"A" - DOWN   '
	DC.B '"Z" - LEFT   '
	DC.B '"X" - RIGHT   '
	DC.B '"CONTROL" - TOGGLE TURBO   '
	DC.B "     PLAYER TWO...  ALL THE FOLLOWING ARE ON THE "
	DC.B "NUMERIC KEYPAD...     "
	DC.B '"9" - UP   '
	DC.B '"6" - DOWN   '
	DC.B '"1" - LEFT   '
	DC.B '"2" - RIGHT   '
	DC.B '"0" - TOGGLE TURBO         '
	DC.B "         RULES         "
	DC.B "TRAVERSE THE GRID TRYING NOT TO HIT ANYTHING, IT'S AS SIMPLE "
	DC.B "AS THAT.......   YEAH, RIGHT....     "
	DC.B "NO POINTS ARE SCORED FOR MUTUAL OBLITERATION!     "
	DC.B "YOU ARE UNABLE TO BACKTRACK INTO YOUR OWN TRAIL!    "
	DC.B "                "
	DC.B "THE DATE IS NOW 12.08.91, WELL OVER 5 MONTHS AFTER THE "
	DC.B "LAST TIME I WAS IN THIS SOURCE FILE. TONIGHT IT GOT FIXED "
	DC.B "SO THAT IT NOW RUNS ON ALL MAKES AND SIZES OF ST'S THAT I CAN "
	DC.B "THINK OF, EXCEPTING THOSE WITH CRAPPY MMU'S AND "
	DC.B "KNACKERED SHIFTERS (XERUD)   "
	DC.B "I AM NOT PROUD OF THIS GAME, BUT IT WORKS, AND IT IS FINISHED! "
	DC.B "APATHY IS NOWHERE NEAR FINISHED. TIME TO DO SOME MORE "
	DC.B "WORK. HOWEVER, THERE IS A PROBLEM. LAST WEEK MY POWER "
	DC.B "PACK DECIDED TO OBLITERATE ITSELF. NO PROBLEM, PUT A FIXED "
	DC.B "ONE IN (THANX APPOLLO). OK, SWITCH ON. DARKNESS. YUP, THE "
	DC.B "ST RESET AND TOOK THE HOUSE SAFETY TRIP SWITCH WITH IT. "
	DC.B "NOW THIS IS NOT REALLY A MAJOR PROBLEM, EXCEPT THAT IT WAS "
	DC.B "10PM AND TOTALLY DARK, AND OUR TRIP SWITCH IS ON ANOTHER FLOOR "
	DC.B "OF THE HOUSE AND CAN ONLY BE REACHED VIA A CHAIR TO STAND ON. "
	DC.B "ANYWAY. TIMESLIP TEN MINUTES TO RESET THIS (AND A LOT OF "
	DC.B "BLOODY SWEARING) AND ANOTHER REBOOT IS ATTEMPTED. JOY OF JOYS, "
	DC.B "MY ST WORKS, HANG ON, I'LL JUST LOAD THIS PROGRA.....  "
	DC.B "WHY ISN'T MY MOUSE WORKING? WAIT A MO. WHY ISN'T MY KEYBOARD "
	DC.B "CLICKING EVEN? ANSWER. THE KEYBOARD CHIP IS KNACKERED. "
	DC.B "OH WELL, BOOT UP MY 800XL FOR A FEW HOURS AND SULK....  "
	DC.B "DATELINE: 2 DAYS LATER. NOOKEY PHONES AND HAS SOMEONE WHO "
	DC.B "WILL FIX MY ST (SEE MAIN MENU FOR MORE DETAILS) THIS HAS NOW "
	DC.B "BEEN DONE, EXCEPT THAT THE RIGHT SHIFT DOESN'T WORK, AND "
	DC.B "IF I TRY -SOME- (NOT ALL) RIGHT-SHIFT COMBINATIONS THEY DON'T "
	DC.B "WORK. OH, WELL, MAYBE TOMORROW I'LL FIX THAT. FOR NOW, MY "
	DC.B "1.08 MACHINE (WITH 4MB SIMMS) IS SORT-OF-WORKING!!!   "
	DC.B "GO READ ANOTHER SCROLLER!              W-R-A-P!   "
	DC.B $FF,$FF
	EVEN

offset			ds.l 1		; offset into grfx for 16x16 font 
offset2			ds.l 1		; offset into grfx for 7x7 font
ptable			ds.l $3f	; space for font table #1
ptable2			ds.l $3f	; space for font table #2
scrl			dc.w 1		; number of scrolls to new char
tpnt			ds.l 1		; pointer to the scrolltext
chbuff			ds.w 16		; space to hold character data
stchar			ds.l 1		; address of font #1
ststart			ds.l 1		; address of font (?)
done_vbl		ds.w 1		; v-sync flag
ststart16		ds.l 1		; address of font
do_cols			dc.w 1		; vbl title/game flag
which_key		ds.l 1		; scan_code from menu
sc1			dc.b "0000",$ff,$ff	; score pl1
sc2			dc.b "0000",$ff,$ff	; score pl2
bord_cnt		ds.w 1		; scans to overscan init
ch1			ds.w 1		; used in cpu control
ch2			ds.w 1		; used in cpu control
frames			ds.w 1		; v-sync flag
x_pos1			dc.l 15		; player #1 x-start
y_pos1			dc.l 230*113	; player #1 y-start
way1			dc.w 12		; player #1 direction
tur1			dc.w 'T1'	; player #1 turbo flag
tur2			dc.w 'T2'	; player #2 turbo flag
level			dc.b 'EASY'	; difficulty level
mus_vbl			ds.l 1		; indirect vbl vector
x_pos2			dc.l 398	; player #2 x-start
y_pos2			dc.l 230*113	; player #2 y-start
vbl_done		ds.w 1		; vbl-sync flag
do_intro		dc.w -1		; credits/game flag
way2			dc.w 8		; player #2 direction
_pall			ds.w 16		; storage for pallette
_sr			ds.w 1		; storage for status register
_70			ds.l 1		; storage for vbl
_68			ds.l 1		; storage for hbl
_8260			ds.b 1		; storage for frequency
_fa07			ds.b 1		; storage for mfp
_fa09			ds.b 1		; storage for mfp
_8201			ds.b 1		; storage for vidptr high
_8203			ds.b 1		; storage for vidptr low
			even

