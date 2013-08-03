;
; D-Bug Intro #7 (Parallax)
; -------------------------
;
; Coded by Cyrano Jones
;

ramtop		equ $380000		; 1st un-addressable byte
;vbl_timer

	move.l 4(a7),a5			; Gemdos MEM_SHRINK
	lea $2000.w,a7			; Safe Stack on 512!
	move.l #$200,-(a7)
	move.l a5,-(a7)
	move.l #$4a0000,-(a7)
	trap #1
	lea 12(a7),a7

	clr.w -(a7)
	pea -1.w
	move.l (a7),-(a7)
	move.w #5,-(a7)
	trap #14
	lea 12(a7),a7

	pea code(pc)
	move.w #$26,-(a7)
	trap #14
	addq.l #6,a7

	clr.l -(a7)			; $4b program file
	pea comtail(pc)
	move.l loader,-(a7)
	clr.w -(a7)
	move.w #$4b,-(a7)
	trap #1
	lea 14(a7),a7

	move.w #$4c,-(a7)		; Back to Desktop
	trap #1

file1	dc.b "a:\crapgame.one",0
	even
file2	dc.b "a:\crapgame.two",0
	even
loader	ds.l 1
comtail	ds.l 1

code	movem.l $ffff8240.w,d0-7	; save pallette
	movem.l d0-7,old_pall
	move.b $ffff8260.w,old_res	; save resolution
	move.b $ffff8201.w,old_screen+1	; save screen-base
	move.b $ffff8203.w,old_screen+2
	move.l $70.w,-(a7)		; save system bits
	move.l $118.w,-(a7)
	move.l $68.w,-(a7)
	move.l $120.w,-(a7)
	move.b $fffffa07.w,xa07
	move.b $fffffa09.w,xa09
	move.b $fffffa15.w,xa15
	move.b $fffffa1b.w,xa1b

	move.b #$12,d0			; no mouse
	bsr sikbd
	move.b #$1a,d0			; no joysticks
	bsr sikbd
	move.l #my_key,$118.w		; my ikbd routs

	jsr create_shifts		; shift layers
	bsr cls				; clear screen

	moveq.l #1,d0
	bsr music

	movem.l pargfx+2,d0-7		; set new pallette
	movem.l d0-7,$ffff8240.w

	stop #$2300			; wait for v-sync!
	move.w #$2700,sr		; switch all maskable ints off
	clr.b $ffff8260.w		; force low res
	move.l #hbl,$68.w		; set up HBL (system)
	move.l #vbl,$70.w		; set up VBL
	move.b #1,$fffffa07.w		; enable HBL in mfp mask
	bset #0,$fffffa13.w		; set mfp
	clr.b $fffffa09.w		; all other interupts OFF!
	move.l #lower,$120.w		; set up HBL (user)

	move	#$2300,sr		; turn on what was just set

			******** loop code ********

.spc	move.w wait_flag,d0
.holder	cmp.w wait_flag,d0		; wait for top border confirmed
	beq.s .holder
***************************************************************************
******************* VBLish Type Code Goes In Here *************************
***************************************************************************
	move.b screen2+1,$ffff8201.w	; set screenbase
	move.b screen2+2,$ffff8203.w

	move.l screen1,-(a7)		; toggle screens
	move.l screen2,screen1
	move.l (a7)+,screen2

	ifd vbl_timer
	move.w #$3,$ffff8240.w
	endc

	bsr para			; parallax
	bsr crazy_text
	bsr blocky
	bsr music+8

	ifd vbl_timer
	move.w #$0,$ffff8240.w
	endc
***************************************************************************
***************************************************************************
***************************************************************************
	move.b $fffffc02.w,d0
.1	cmp.b #$2,d0
	bne.s .2
	move.l #file1,loader
	bra.s .exit
.2	cmp.b #$3,d0
	bne .spc
	move.l #file2,loader

.exit	move.w #$2700,sr		; all stop!
	move.l (a7)+,$120.w
	move.l (a7)+,$68.w
	move.l (a7)+,$118.w
	move.l (a7)+,$70.w
	move.b xa07,$fffffa07.w
	move.b xa09,$fffffa09.w
	move.b xa15,$fffffa15.w
	move.b xa1b,$fffffa1b.w
	move.l #$8080000,$ffff8800.w	; volume to zero on
	move.l #$9090000,$ffff8800.w	; all 3 channels
	move.l #$a0a0000,$ffff8800.w
	bsr cls				; clear screen
	move.b #$80,d0			; restore ikbd
	bsr sikbd
	move.b #$1,d0			; to power up status
	bsr sikbd
	movem.l old_pall,d0-7
	movem.l d0-7,$ffff8240.w	; restore pallette
	move.b old_res,$ffff8260.w	; restore resolution
	move.b old_screen+1,$ffff8201.w	; restore screenbase
	move.b old_screen+2,$ffff8203.w
	move.w #$2300,sr		; all go!
	rts

sikbd	move.b d0,$fffffc02.w		; send command bytes
.hang	btst #1,$fffffc00.w
	beq.s .hang
	rts

my_key	move.b $fffffc02.w,keybyte
	bclr.b #6,$fffffa11.w
	rte

keybyte	ds.w 1

cls	lea ramtop-($e000*2),a0		; wipe the work and display
	move.l #(($e000*2)/4)-1,d0		; screens
.wiper	clr.l (a0)+
	dbra d0,.wiper
	rts	


bord_cnt	dc.w 33			; the final countdown (top border)
wait_flag	dc.w 0			; done top border flag

vbl	move.w #33,bord_cnt		; set up all border killer
	clr.b $fffffa1b.w		; kill user interupts
	move.b #228,$fffffa21.w		; enable lower border interupt
	move.b #8,$fffffa1b.w		; set in mfp mask
	and.w #$f1ff,(a7)		; run $68 interupt on exit
	rte

 
hbl	subq.w	#1,bord_cnt		; right line?
	bpl	_rte			; nope,so exit

	move	#$2700,sr		; time critical.....
	movem.l	d0-d7/a0-a6,-(a7)	; save reggies
	lea	$ff8209,a0		; video address counter low
	lea	$ff8260,a1		; resolution
	move.w	#9,d0			; delay loop 1
.1	nop
	dbf	d0,.1
	clr.b	$ffff820a.w		; 60 Hz
	moveq	#3,d0			; delay loop 2
.2	nop
	dbf	d0,.2
	move.b	#2,$ffff820a.w		; 50 Hz
	addq.w #1,wait_flag
	movem.l (a7)+,d0-d7/a0-a6
	or.w #$300,(a7)
_rte	rte

lower	movem.l	d0/a1,-(a7)	
	move #$2700,sr			; time critical
        move.w #$fa21,a1
        move.b (a1),d0
.1	cmp.b (a1),d0         		; wait last scanline
        beq .1          
        clr.b $ffff820a.w     		; 60 Hz
        moveq #3,d0
.2     	nop                 		; wait a while
        dbf d0,.2
	move.b #2,$ffff820a.w  		; 50 Hz
	movem.l	(a7)+,d0/a1
	move.b #0,$fffffa1b.w
        bclr #0,$fffffa0f.w  		; end of interrupt 
        rte

; blk_y / blk_dat

blocky	move.l screen1,a6
	lea pargfx+34+64,a5
	move.l blk_y,a0
	move.l (a0)+,d0
	bpl.s .ok
	lea blk_dat,a0
	move.l (a0)+,d0
.ok	move.l a0,blk_y
	add.l #32,d0
	add.l d0,a6
; 64 longs wide
x	set 0
	rept 64
	movem.l x(a5),d0-7/a0-3
	movem.l d0-7/a0-3,x(a6)
	movem.l x+48(a5),d0-7/a0-3
	movem.l d0-7/a0-3,x+48(a6)
x	set x+160
	endr
	rts

para	lea buffer,a5			; screen-base

	move.l xptr1,a0			; get pointer into x-pos (back)
	move.w (a0)+,d0			; pull position
	bpl.s .fetch
	lea xpos1,a0			; reset and reload
	move.w (a0)+,d0
.fetch	move.l a0,xptr1			; save current place

	move.l yptr1,a0			; do the same for the y-pos
	move.w (a0)+,d1
	bpl.s .yetch
	lea ypos1,a0
	move.w (a0)+,d1
.yetch	move.l a0,yptr1

	lea y_table,a0
	add d1,d1
	add d1,d1
	move.w (a0,d1),d3		; grafix offset (vertical)

	lea x_partb,a0		
	add d0,d0
	add d0,d0
	move.l (a0,d0),d0		; grafix offset (horiz)
	
	lea top_tab,a6			; actually the bottom (ooops!)
	move.l (a6,d0),a6		; address of correct block
	swap d0
	add.w d0,a6			; plus 16-pixel offset
	add.w d3,a6			; plus vertical offset

xxx	set 0				; copy it to the top-left
yyy	set 0				; of the screen
	rept 16
	movem.l yyy(a6),d0-3
	movem.l yyy+32(a6),d4-7
	movem.l d0-7,xxx(a5)
yyy	set yyy+64
xxx	set xxx+32
	endr

; ok, now must sprite the other layer on top of this one.

do_top	move.l yptr2,a0			; as before, grab y-position
	move.w (a0)+,d1
	bpl.s .yetch
	lea ypos2,a0
	move.w (a0)+,d1
.yetch	move.l a0,yptr2
	lea y_table,a0
	add d1,d1
	add d1,d1
	move.w (a0,d1),d3		; grafix offset (vert)
	move.w 2(a0,d1),d4		; mask offset (vert)

	move.l xptr2,a0			; and grab x
	move.w (a0)+,d0
	bpl.s .fetch
	lea xpos2,a0
	move.w (a0)+,d0
.fetch	move.l a0,xptr2
	add d0,d0
	add d0,d0
	
	lea x_partb,a0
	move.w (a0,d0),d7		; x-offset (grafix)
	move.w 2(a0,d0),d0		; table offset
	lea back_tab,a6
	move.l (a6,d0),a6		; data pointer
	lea mask_tab,a5
	move.l (a5,d0),a5		; mask pointer
	add.w d7,a6			; add x to pointer

	cmp.w #8,d7			; check for mask overflow
	bne.s .ok
	addq.w #4,a5			; correct mask pointer

.ok	add.w d3,a6			; add vertical to grafix
	add.w d4,a5			; add vertical to mask

	lea buffer,a4			; screenbase
	rept 8*4
	move.l (a5)+,d0
	move.l (a5)+,d1
	and.l d0,(a4)+			; block
	and.l d0,(a4)+
	and.l d1,(a4)+
	and.l d1,(a4)+
	addq.w #8,a5
	endr

	lea buffer,a4			; screenbase
yyy	set 0
	rept 32
	movem.l yyy(a6),d0-3
	or.l d0,(a4)+
	or.l d1,(a4)+
	or.l d2,(a4)+
	or.l d3,(a4)+
yyy	set yyy+32
	endr

blit_line macro offset
	lea	\1+160(a4),a6
	movem.l d0-a3,-(a6)
	movem.l d0-a3,-(a6)
	movem.l d0-7,-(a6)
	movem.l d0-7,-(a6)
	endm

blit_all		
	lea buffer,a5
	move.l screen1,a4		; the screen
xxx	set 0
	rept 32				; make the top line
	movem.l (a5)+,d0-3
	move.l	d0,d4
	move.l	d1,d5
	move.l	d2,d6
	move.l	d3,d7
	move.l	d0,a0
	move.l	d1,a1
	move.l	d2,a2
	move.l	d3,a3
	blit_line xxx
	blit_line xxx+160*32
	blit_line xxx+160*64
	blit_line xxx+160*96
	blit_line xxx+160*128
	blit_line xxx+160*160
	lea 192*160(a4),a4
	blit_line xxx
	blit_line xxx+160*32
	blit_line xxx+160*64
	lea -192*160(a4),a4
xxx	set xxx+160
	endr

	rts

spd_byte	dc.w 0300
crzy_cnt	dc.w 3
current_offset	dc.w 6
next_add	dc.w 7
togl_add	dc.w 1
plotting_addr	dc.l pargfx+34+64+8+(160*10)-7-2

crazy_text
	sub.b #1,crzy_cnt+1
	bmi.s .start_crazy
	rts
.start_crazy
	move.b spd_byte,crzy_cnt+1
	move.l crazy_ptr,a0
	moveq.l #0,d0
.again	move.b (a0)+,d0
	beq.s .again
	move.l a0,crazy_ptr
	tst.b d0
	bpl .plot_character
	ext.w d0
	addq.w #6,d0
	add d0,d0
	add d0,d0
	move.l .jmptab(pc,d0.w),a1
	jmp (a1)
.jmptab	dc.l .wrap
	dc.l .set_speed
	dc.l .right
	dc.l .left
	dc.l .up
	dc.l .down
.set_speed
	move.b (a0)+,spd_byte
	move.l a0,crazy_ptr
	rts
.wrap	bsr .unplot_cursor
	move.l #crazy_txt,crazy_ptr
	move.w #6,current_offset
	move.w #7,next_add
	move.w #1,togl_add
	rts
.right	bsr .unplot_cursor
	move.w next_add,d0
	add.w d0,current_offset
	move.w togl_add,next_add
	move.w d0,togl_add
	bra .plot_cursor
.left	bsr .unplot_cursor
	move.w togl_add,d0
	move.w next_add,togl_add
	move.w d0,next_add
	sub.w d0,current_offset
	bra .plot_cursor
.up	bsr .unplot_cursor
	sub.w #160*9,current_offset
	bra .plot_cursor
.down	bsr .unplot_cursor
	add.w #160*9,current_offset
	bra .plot_cursor
	rts
.plot_character
	bsr .unplot_cursor
	sub.b #' ',d0
	add.w d0,d0
	add.w d0,d0
	lea ascii1,a2
	move.l (a2,d0.w),.grafx

.char	move.l plotting_addr,a1
	dc.w $45f9		; lea ?,a2
.grafx	dc.b 'DBUG'
	add.w current_offset,a1
	move.b (a2),(a1)
	move.b 40(a2),160(a1)
	move.b 80(a2),320(a1)
	move.b 120(a2),480(a1)
	move.b 160(a2),640(a1)
	move.b 200(a2),800(a1)
	move.b 240(a2),960(a1)
	move.b 280(a2),1120(a1)
	move.w next_add,d0
	add.w d0,current_offset
	move.w togl_add,next_add
	move.w d0,togl_add
.plot_cursor
	moveq.l #-1,d7
	move.l plotting_addr,a1
	add.w current_offset,a1
	move.b d7,(a1)
	move.b d7,160(a1)
	move.b d7,320(a1)
	move.b d7,480(a1)
	move.b d7,640(a1)
	move.b d7,800(a1)
	move.b d7,960(a1)
	move.b d7,1120(a1)
	rts
.unplot_cursor
	moveq.l #0,d7
	move.l plotting_addr,a1
	add.w current_offset,a1
	move.b d7,(a1)
	move.b d7,160(a1)
	move.b d7,320(a1)
	move.b d7,480(a1)
	move.b d7,640(a1)
	move.b d7,800(a1)
	move.b d7,960(a1)
	move.b d7,1120(a1)
	rts

; -1 = down
; -2 = up
; -3 = left
; -4 = right
; -5 = set speed followed by speed byte
; -6 = terminate

down	equ -1
up	equ -2
left	equ -3
right	equ -4
speed	equ -5
wrap	equ -6

left_line macro
	dcb.b 21,left
	endm

right_line macro
	dcb.b 21,right
	endm


erase1	MACRO
	dc.b speed,1
	left_line
	dc.b up
	right_line
	dc.b up
	left_line
	dc.b up
	right_line
	dc.b up
	left_line
	dc.b speed,0
	endm

erase2  macro
	dc.b speed,1
	rept 10
	dcb.b 4,up
	dc.b left
	dcb.b 4,down
	dc.b left
	endr
	endm


crazy_ptr	dc.l crazy_txt
;	dc.b "ABCDEFGIJKLMNOPQRSTUV",-1
crazy_txt
	dc.b speed,0
	dc.b "     WELCOME",speed,3,"------",speed,0,"   "
	dc.b down
	dcb.b 20,left
	dc.b "  THIS IS D.BUG 33!",down,down
	dcb.b 19,left
	dc.b "1)  GAME TITLE --1--",down
	dcb.b 20,left
	dc.b "2)  GAME TITLE --2-"
	dc.b speed,127,"-"
	erase1
;	dc.b "ABCDEFGIJKLMNOPQRSTUV",-1
	dc.b down
	dc.b "     INTRO CODE--    ",down
	left_line
	dc.b "     CYRANO JONES    ",down
	left_line
	dc.b "     ............   ",down
	dc.b speed,127," "
	erase2
	dc.b left
	dcb.b 4,up
	dc.b speed,0
;	dc.b "ABCDEFGIJKLMNOPQRSTUV",-1
	dc.b " D.BUG CONSISTS OF:  ",down
	left_line
	dc.b " CYRANO JONES (CODER)",down
	left_line
	dc.b " HOT.KNIFE  (CRACKER)",down
	left_line
	dc.b " ICEMAN!    (CRACKER)",down
	left_line
	dc.b " NEIL       (CRACKER"
	dc.b speed,127,")"
	erase1
;	dc.b "ABCDEFGIJKLMNOPQRSTUV",-1
	dc.b " D.BUG GREETINGS TO: ",down
	left_line
	dc.b " CYNIX, ELITE, UNITY,",down
	left_line
	dc.b " ICS, THE REPLICANTS,",down
	left_line
	dc.b " SUPERIOR, MAD VISION",down
	left_line
	dc.b " OLYMPIAN, GANGSTER-"
	dc.b speed,127,"-"
	erase1
;	dc.b "ABCDEFGIJKLMNOPQRSTUV",-1
	dc.b " MORE GREETINGS TO:  ",down
	left_line
	dc.b " THE PUP, HAL 9000,  ",down
	left_line
	dc.b " THE POMPEY PIRATES, ",down
	left_line
	dc.b " AND ANYONE ELSE WHO ",down
	left_line
	dc.b " HAS DONE US A FAVOU"
	dc.b speed,127,"R"
	erase1
;	dc.b "ABCDEFGIJKLMNOPQRSTUV",-1
	dc.b " W",down,left
	dc.b "W",down,left
	dc.b "W",down,left
	dc.b "W",down,left
	dc.b "W",up,"W",up,"W",down,"W",down,"W"
	dc.b up,left,"W"
	dc.b up,left,"W"
	dc.b up,left,"W"
	dc.b up,left,"W"
	dc.b " R",down,left
	dc.b "R",down,left
	dc.b "R",down,left
	dc.b "R",down,left
	dc.b "R  R",up,left
	dc.b "R",up,left,left,left,"RR",up
	dc.b "R",up,left,left,left,"RR  "
	dc.b " AA",down,left,left,left
	dc.b "A  A",down,left,left,left,left
	dc.b "AAAA",down,left,left,left,left
	dc.b "A  A",down,left,left,left,left
	dc.b "A  A P"
	dc.b up,left,"P"
	dc.b up,left,"P"
	dc.b up,left,"P"
	dc.b up,left,"PPP",down
	dc.b "P",down,left,left,left
	dc.b "PP",down,down
	dc.b speed,127," "
	erase1
	dc.b wrap
	even

font	incbin rawfont.bin
	even

ascii1	
xx	set font
	rept 40
	dc.l xx
xx	set xx+1
	endr
xx	set font+(40*8)
	rept 40
	dc.l xx
xx	set xx+1
	endr


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;; Init Code for parallax ;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

create_shifts			; build a table of pointers
	lea top_tab,a0
	lea back_tab,a1
	lea mask_tab,a2
	lea back_gfx,a3
	lea top_gfx,a4
	lea top_mask,a5
	move.l #16,d0
make_tables
	move.l a3,(a0)+
	move.l a4,(a1)+
	move.l a5,(a2)+
	lea 32*64(a3),a3
	lea 32*64(a4),a4
	lea 32*32(a5),a5
	subq.w #1,d0
	bne.s make_tables

	lea back_tab,a0			; now, copy and shift images
	lea top_tab,a1
	move.l #0,d0
rotate2	move.l (a0)+,a2
	move.l (a1)+,a3
	bsr copy_block
	move.l d0,d1
	tst.w d0
	beq.s next
shifter	movem.l a2-a3,-(a7)
	bsr pre_shifter
	movem.l (a7)+,a2-3
	subq.w #1,d1
	bne.s shifter
next	addq.w #1,d0
	cmp.w #16,d0
	bne.s rotate2

	lea top_gfx,a0			; build the sprite masks
	lea top_mask,a1			; (only for the top layer!)
masking	move.w #2,d0
skipper	move.w (a0)+,d1
	move.w (a0)+,d2
	move.w (a0)+,d3
	move.w (a0)+,d4
	or.w d1,d2
	or.w d3,d2
	or.w d4,d2
	not d2
	move.w d2,d1
	swap d2
	move.w d1,d2
	move.l d2,(a1)+
	subq.w #1,d0
	bne.s skipper
	cmp.l #top_mask,a0
	bne.s masking
	rts

pre_shifter
	move.w #64,d6
nextlin	move.w #4,d7
onepln	sub d5,d5	
	roxl.w 24(a2)
	roxl.w 16(a2)
	roxl.w 8(a2)
	roxl.w (a2)+
	sub d5,d5
	roxl.w 24(a3)
	roxl.w 16(a3)
	roxl.w 8(a3)
	roxl.w (a3)+
	subq.w #1,d7
	bne.s onepln
	lea 24(a2),a2
	lea 24(a3),a3
	subq.w #1,d6
	bne.s nextlin
	rts

copy_block
	lea pargfx+34,a5
	lea pargfx+32+34,a6
xxx	set 0
yyy	set 0
	rept 32
	movem.l xxx(a5),d4-7
	movem.l d4-7,yyy(a2)
	movem.l d4-7,yyy+(32*32)(a2)
	movem.l xxx(a6),d4-7
	movem.l d4-7,yyy(a3)
	movem.l d4-7,yyy+(32*32)(a3)
	
	movem.l xxx+16(a5),d4-7
	movem.l d4-7,yyy+16(a2)
	movem.l d4-7,yyy+(32*32)+16(a2)
	movem.l xxx+16(a6),d4-7
	movem.l d4-7,yyy+16(a3)
	movem.l d4-7,yyy+(32*32)+16(a3)

xxx	set xxx+160
yyy	set yyy+32
	endr
	rts

blk_y	dc.l blk_dat
blk_dat
	incbin block_y6.bin
	incbin block_y4.bin
	incbin block_y3.bin
	incbin block_y.bin
	incbin block_y3.bin
	incbin block_y4.bin
	dc.l $ffffffff
	even

*********************************************************

x_partb	rept 10
	dc.w 0,60,0,56,0,52,0,48,0,44,0,40
	dc.w 0,36,0,32,0,28,0,24,0,20,0,16,0,12,0,8,0,4,0,0
	dc.w 8,60,8,56,8,52,8,48,8,44,8,40
	dc.w 8,36,8,32,8,28,8,24,8,20,8,16,8,12,8,8,8,4,8,0
	endr

ytab	macro
xxx2 	set 0
	rept 32
	dc.w 32*xxx2,16*xxx2
xxx2	set xxx2+1
	endr
	endm

y_table	ytab
	ytab
	ytab
	ytab
	ytab
	ytab
	ytab

xptr1	dc.l xpos1
xpos1	incbin parrx1.bin
xend1	dc.l $ffffffff

xptr2	dc.l xpos2
xpos2	incbin parrx2.bin
xend2	dc.l $ffffffff

yptr1	dc.l ypos1
ypos1	incbin parry1.bin
yend1	dc.l $ffffffff

yptr2	dc.l ypos2
ypos2	incbin parry2.bin
yend2	dc.l $ffffffff

screen1	dc.l ramtop-($e000*1)	; working screen-base
screen2	dc.l ramtop-($e000*2)	; display screen-base

music	incbin an_cool.max
	even

pargfx	incbin dbugblok.dat
		
	section bss

xa07		ds.b 1
xa09		ds.b 1
xa15		ds.b 1
xa1b		ds.b 1
old_res		ds.w 1			; entry resolution
old_screen	ds.l 1			; entry screen address
old_pall	ds.w 16			; entry pallette
back_tab	ds.l 16			; addresses of shifted gfx
top_tab		ds.l 16			; addresses of shifted gfx
mask_tab	ds.l 16			; addresses of shifted masks
back_gfx	ds.b (64*32)*16		; space for backdrop
top_gfx		ds.b (64*32)*16		; space for overlay
top_mask	ds.b (64*16)*16		; space for overlay masks
buffer		ds.l 4*64
