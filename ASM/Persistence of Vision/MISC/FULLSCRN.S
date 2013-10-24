; SYSTEM: Atari ST   LANGUAGE: 68000 assembly
; DATE STARTED:20/12/90  DATE COMPLETED:20/12/90
; Written by Wayne J. Smithson (c) WJS Design.

; FULL SCREEN TEST
; Creates screen that is 230 bytes across x 244 lines (offset 160 bytes).
; Visible screen is offset 8 bytes and is 192 bytes across (384 pixels).
; Screen size > Memory: 56280 Picture:46848

	org $20000

	include systemeq.s
* Equates
no_1meg	equ 0
grab_screen	equ 0
finished	equ 0

screen_1	equ $70000

* stack and permanent variables.
runprog:
begprog	bra skip_var
	ds.l 64
stack	dc.l 0

meg_1	dc.b 0
	even
* palettes
blackp	dc.w $000,$000,$000,$000,$000,$000,$000,$000
	dc.w $000,$000,$000,$000,$000,$000,$000,$000
whitep	dc.w $777,$777,$777,$777,$777,$777,$777,$777
	dc.w $777,$777,$777,$777,$777,$777,$777,$777
wjs_palette	dc.w $000,$407,$306,$205,$104,$003,$002,$001
	dc.w $000,$704,$603,$502,$401,$300,$200,$100

*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*
	include joykeym.s

* initial set up.
skip_var	move.w #$2700,sr		;disable interupts.
	lea stack(pc),a7		;load stack pointer.
	lea variables_base,a6
	bsr kill_sys		;kill ST & set keyboard.
	clr.b meg_1
	IF no_1meg=0
	lea 1024*1024-1,a0		;check for 1Mb:
	move.w #255,d0
@loop	move.b d0,(a0)
	move.b (a0),d1
	cmp.b d0,d1
	bne.s @pop
	dbra d0,@loop
	st.b meg_1
	ENDIF
@pop	lea palette0\w,a0
	REPT 8
	clr.l (a0)+
	ENDR

	lea screen_1,a0		;clear full screen:
	move.w #(230*244+160)/4,d0
@clear	clr.l (a0)+
	dbra d0,@clear

	lea picture(pc),a4		;copy full-screen:
	lea screen_1+160+8,a5
	move.w #244-1,d7
@next	move.w #192/4-1,d6
@line	move.l (a4)+,(a5)+
	dbra d6,@line
	lea 230-192(a5),a5
	dbra d7,@next

	lea wjs_palette(pc),a0		;set palette:
	lea palette0\w,a1
	REPT 8
	move.l (a0)+,(a1)+
	ENDR

@xx	bsr get_top_screen
	bsr install_no_top
	bsr get_bot_screen
	bsr install_no_bottom
	bsr install_no_borders

***** do your code here **
	moveq #0,d0
	move.l #230*0,d1
	move.l #230*100,d2
	moveq #0,d3
@move
	lea screen_1+168+6,a0		;move logo 1:
	add.l d1,a0
	btst #0,d3
	bne.s @up_1
	bsr draw_logo_down
	add.l #230,d1
	cmp.w #230*(244-57),d1
	bls.s @do_2
	bset #0,d3
	bra.s @do_2

@up_1	bsr draw_logo_up
	sub.l #230,d1
	bpl.s @do_2
	bclr #0,d3

@do_2	lea screen_1+168+96+6,a0	;move logo 2:
	add.l d2,a0
	btst #1,d3
	bne.s @up_2
	bsr draw_logo_down
	add.l #230,d2
	cmp.w #230*(244-57),d2
	bls.s @move
	bset #1,d3
	bra.s @move

@up_2	bsr draw_logo_up
	sub.l #230,d2
	bpl.s @move
	bclr #1,d3
	bra.s @move


draw_logo_down
	lea logopic,a1

	REPT 96/8			;clear 1st line:
	move.w d0,(a0)+
	addq.l #6,a0
	ENDR
	lea 230-96(a0),a0

	REPT 56			;draw logo:
	REPT 96/8
	move.w (a1)+,(a0)+
	addq.l #6,a0
	ENDR
	lea 230-96(a0),a0
	ENDR

	REPT 96/8
	move.w (a1)+,(a0)+
	addq.l #6,a0
	ENDR

	rts

draw_logo_up
	lea logopic,a1

	REPT 57			;draw logo:
	REPT 96/8
	move.w (a1)+,(a0)+
	addq.l #6,a0
	ENDR
	lea 230-96(a0),a0
	ENDR

	REPT 96/8			;clear last line:
	move.w d0,(a0)+
	addq.l #6,a0
	ENDR

	rts

********************************************************************************
********************************************************************************
* Get rid of all borders.
install_no_borders
	move.w #$2700,sr
	move.l #vbl_no_borders,vbl_vect\w
	move.l #hbl_no_borders_1,hbl_vect\w
	move.w #$2000,sr
	rts

vbl_no_borders
	clr.w vbl_called(a6)
	bset #1,syncmode\w		;50hz.
	move.w top_start(a6),top_counter(a6)
	subq.w #1,top_counter(a6)
	move.l #hbl_no_borders_1,hbl_vect\w
	move.w #$2000,(a7)
	rte

hbl_no_borders_1
	subq.w #1,top_counter(a6)
	bne @exit
	movem.l a0-a1/d4-d7,-(a7)
	move.l #hbl_no_borders_2,hbl_vect\w
	stop #$2100			;stops 68000 until next hbl.
	movem.l (a7)+,a0-a1/d4-d7
	move.w #$2300,(a7)		;no more hbl's.
@exit	rte

hbl_no_borders_2
* Do top border extend:
	REPT 99+1
	nop
	ENDR
	bclr #1,syncmode\w		;flip to 60hz.
	nop
 	nop
	nop
	bset #1,syncmode\w		;back to 50hz.

	REPT 8
	nop
	ENDR

* Do left/rite border extend:
	move.b #$20,d7		;stabalise:
@waitonscr	cmp.b vidcntrlo\w,d7
	bls.s @waitonscr
	move.b #$70,d7
	sub.b vidcntrlo\w,d7
	asl.w d7,d7

	REPT 61
	nop
	ENDR

	moveq #2,d6
	moveq #0,d7
	lea syncmode\w,a0
	lea resolution\w,a1

;	moveq #0,d6
;	moveq #7,d7
;	lea palette0\w,a0
;	lea palette1\w,a1

	move.w #252,d5		;-1 for dbf;-1 for line b4.
	sub.w bottom_start(a6),d5

@loopit
	move.w #2,d4	(8)
@x	dbra d4,@x		(40)
	nop

	move.b d6,(a1)	(8)	;hi-res for left border.
	move.b d7,(a1)	(8)	;lo-res.

	moveq #28,d4	(4)
@xx	dbra d4,@xx		(352)

	move.b d7,(a0)	(8)	;60hz for RITE border.
	move.b d6,(a0)	(8)	;50hz.

	moveq #2,d4		(4)
@xxx	dbra d4,@xxx	(40)

	move.b d6,(a1)	(8)	;hi-res to stop rite border.
	move.b d7,(a1)	(8)	;lo-res.

	dbra d5,@loopit	(12/16)

* Do bottom border extend:

	move.w #2,d4	(8)
@y	dbra d4,@y		(40)

	move.b d6,(a1)	(8)	;hi-res for left border.
	move.b d7,(a1)	(8)	;lo-res.

	moveq #28,d4	(4)
@yy	dbra d4,@yy		(352)

	move.b d7,(a0)	(8)	;60hz for RITE border.
	move.b d6,(a0)	(8)	;50hz.

	moveq #2,d4		(4)
@yyy	dbra d4,@yyy	(40)

	move.b d6,(a1)	(8)	;hi-res to stop rite border.
	move.b d7,(a1)	(8)	;lo-res.

	nop		(4)

	bclr #1,syncmode\w		;60hz for bottom border.
	nop
	nop
	nop
	bset #1,syncmode\w		;50hz.

* Do rest of rite/left border extend:

	move.w #16-1,d5		;-1 for dbf;-1 for line b4.
@loopit2
	move.b d6,(a1)	(8)	;hi-res for left border.
	move.b d7,(a1)	(8)	;lo-res.

	moveq #28,d4	(4)
@zz	dbra d4,@zz		(352)

	move.b d7,(a0)	(8)	;60hz for RITE border.
	move.b d6,(a0)	(8)	;50hz.

	moveq #2,d4		(4)
@zzz	dbra d4,@zzz	(40)

	move.b d6,(a1)	(8)	;hi-res to stop rite border.
	move.b d7,(a1)	(8)	;lo-res.

	move.w #2,d4	(8)
@z	dbra d4,@z		(40)
	nop

	dbra d5,@loopit2	(10)

	move.w #$2300,(a7)
	rte

********************************************************************************
********************************************************************************

* Find out where top of screen is.
get_top_screen
	bclr #1,syncmode\w			;default to 60hz.
	move.l #screen_1,screen_address(a6)		;set up screen base:
	move.b screen_address+1(a6),scrbasehi\w
	move.b screen_address+2(a6),scrbaselo\w
	st.b got_top_flag(a6)
	clr.w vbl_called(a6)
	lea vbl_get_top(pc),a0
	move.l a0,vbl_vect\w
	lea hbl_get_top(pc),a0
	move.l a0,hbl_vect\w
	move.w #$2000,sr			;allow vbl/hbl.
@wait3vbl	cmp.w #3,vbl_called(a6)
	blt.s @wait3vbl
@wait	tst.b got_top_flag(a6)
	beq.s @wait
	move.w #$2700,sr
	bset #1,syncmode\w			;back to 50hz.
	rts

vbl_get_top	addq.w #1,vbl_called(a6)
	clr.b got_top_flag(a6)
	clr.w top_start(a6)
	rte

hbl_get_top	move.w d0,-(a7)
	move.w #7,d0
@delay	dbra d0,@delay
	tst.b got_top_flag(a6)
	bne.s @exit
	move.b vidcntrlo\w,d0
	nop
	nop
	nop
	nop
	cmp.b vidcntrlo\w,d0
	bne.s @changed
	addq.w #1,top_start(a6)
	move.w (a7)+,d0
	rte
@changed	st.b got_top_flag(a6)
@exit	move.w (a7)+,d0
rte_ptr	rte

* Get rid of top border.
install_no_top
	move.l #vbl_no_top,vbl_vect\w
	move.l #hbl_no_top,hbl_vect\w
	move.w #$2000,sr
	rts

vbl_no_top
	clr.w vbl_called(a6)
	bset #1,syncmode\w			;50hz.
	move.w top_start(a6),top_counter(a6)
	subq.w #1,top_counter(a6)
	move.l #hbl_no_top,hbl_vect\w
	move.w #$2000,(a7)
	rte

hbl_no_top
	subq.w #1,top_counter(a6)
	bne @exit
	move.l #hbl_no_top2,hbl_vect\w
	clr.b first_hbl(a6)
	stop #$2100			;stops 68000 until next hbl.
@exit	rte

hbl_no_top2
	REPT 100
	nop
	ENDR
	bclr #1,syncmode\w			;flip to 60hz.
	nop
	nop
	nop
	bset #1,syncmode\w			;back to 50hz.
	move.w #$2300,(a7)
	rte

*******************************************************************************

* Find out where bottom of screen is.
get_bot_screen
	lea rte_ptr(pc),a0
	move.l a0,mfplevel8\w
	move.b #0,tbcr\w		;timer b stop.
	bset #0,iera\w		;enable timer b.
	bset #0,imra\w
	st.b vbl_called(a6)
@waitvbl	tst.b vbl_called(a6)		;wait for vbl:
	bne.s @waitvbl
	st.b vbl_called(a6)
@waitvbl2	tst.b vbl_called(a6)		;wait for vbl:
	bne.s @waitvbl2
	move.b #255,tbdr\w		;lines to wait.
	move.b #8,tbcr\w		;event count mode.
	st.b vbl_called(a6)
@waitvbl3	tst.b vbl_called(a6)		;wait for vbl again:
	bne.s @waitvbl3
	moveq #0,d0
	move.b tbdr\w,d0		;read actual value.
	move.w d0,bottom_start(a6)
	move.b #0,tbcr\w		;timer b stop.
	bclr #0,iera\w		;disable timer b.
	bclr #0,imra\w
	rts

* Install bottom border removal.
install_no_bottom
	move.w #$2700,sr
	lea vbl_no_topbot(pc),a0
	move.l a0,vbl_vect\w
	move.w #$2000,sr
	lea timerb_bot(pc),a0
	move.l a0,mfplevel8\w
	move.b #0,tbcr\w		;timer b stop.
	bset #0,iera\w		;enable timer b.
	bset #0,imra\w
	rts

vbl_no_topbot
	move.w d0,-(a7)
	clr.w vbl_called(a6)
	bset #1,syncmode\w		;50hz.
	move.w top_start(a6),top_counter(a6)
	subq.w #1,top_counter(a6)
	move.l #hbl_no_top,hbl_vect\w
	move.w #254,d0		;set up for bottom:
	sub.w bottom_start(a6),d0
	move.b #0,tbcr\w		;timer b stop.
	move.b d0,tbdr\w
	move.b #8,tbcr\w		;event count mode.
	move.w (a7)+,d0
	move.w #$2000,(a7)
	rte

timerb_bot
	REPT 124
	nop
	ENDR
;	move.w #$700,palette0\w
	bclr #1,syncmode\w		;flip to 60hz.
	REPT 3
	nop
	ENDR
;	move.w #$000,palette0\w
	bset #1,syncmode\w		;back to 50hz.
	bclr #0,isra\w		;flag interrupt serviced.
	rte

picture	incbin files\back1.bin
logopic	incbin files\wjslogo1.bin

*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*
* Variables
		rsreset
screen_address	rs.l 1
vbl_called		rs.w 1
bottom_start	rs.w 1
top_start		rs.w 1
top_counter		rs.w 1
got_top_flag	rs.b 1
first_hbl		rs.b 1
test_flag		rs.b 1

variables_size	rs.b 0
variables_base	ds.b variables_size

	end runprog

