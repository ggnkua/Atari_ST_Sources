;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                    Total Apathy Megademo Source Code                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;									 ;;
;; 	   ****   *   ****  *        ******   ***    ***   *   *	 ;;
;; 	   *   *     *                   *   *   *  *   *  ** **	 ;;
;; 	   *   *  *  *  **  *  ****    **    *   *  *   *  * * *	 ;;
;; 	   *   *  *  *   *  *         *      *   *  *   *  *   *	 ;;
;; 	   ****   *   ***   *        ******   ***    ***   *   *	 ;;
;;									 ;;
;;  	       Code by Law, Grafix by NAMCO, Sample by DURAN   	 	 ;;
;;									 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                    Total Apathy Megademo Source Code                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;
;; NOTES: 08/03/2004
;;
;; Added a 24 bit -> 8bit gray -> 16 grayshade downsampler so the RGB
;; image can be displayed in it's entirity in 16 colours. Still 512k :-)
;;
;;
;; NOTES: 05/03/2004
;;
;; The image MUST be saved as a 320x200x24bit RGB *INTERLEAVED* image
;; ie, 8 bit red, 8 bit green, 8 bit blue with *NO* padding or formatting
;; Paint Shop Pro can do this for you
;;
;; The sample is in god knows what format (its 11 years old) but the code
;; makes me think its in unsigned binary. It is DEFINATLY 15khz tho
;; (check the replay routine)
;;
;; At the time I wrote this, there were NO 24bpp images around, and I
;; barely managed to fit a 32k degas image into 512k systems... this image
;; is now 188k and still runs in 512k ram :-)  (At least on STEEM it does
;; NOTE: Not verified on real ST)
;;
;; So, what you have here is a screen that only a few people ever saw, and
;; even then they only saw a 16 colour zoomer..... and not the 24bpp
;; conversion screen you have here
;;
;; D-BUG Forever
;;
;; CJ... Until its my turn to swing around the sun and surface again.....
;;

debugging
	ifd debugging
ramtop	equ $400000
	elseif
ramtop	equ $80000
	endc

	lea $2000.w,a7
	pea code(pc)
	move.w #$26,-(a7)
	trap #14
	addq.w #6,a7
	clr.l -(a7)
	trap #1

delay	macro	clock_cycles
x\@	set	0
	ifne	\1>20
x\@	set	((\1)/12)*12
	moveq	#(\1)/12-2,d0
	dbf	d0,*
	moveq	#0,d0
	endc
	dcb.w	(\1-x\@)/4,$4e71
	endm

code	move.w #$2700,sr
	move.b $ffff8201.w,old_scr
	move.b $ffff8203.w,old_scr+1
	move.b $fffffa07.w,old_mfp
	move.b $fffffa09.w,old_mfp+1
	move.b $ffff8260.w,old_res
	movem.l $ffff8240.w,d0-7
	movem.l d0-7,old_pal
	move.l $70.w,old_vbl
	move.l $68.w,old_hbl
	move.b #0,$fffffa07.w
	move.b #0,$fffffa09.w
	move.b #0,$ffff8260.w

	moveq	#15,d0
	lea	$ffff8240.w,a1
.xxblk	clr.w	(a1)+
	dbf	d0,.xxblk

	move.b screen1+1,$ffff8201.w
	move.b screen1+2,$ffff8203.w

	move.l screen1,a1		; grayscale conversion!
	lea picture,a0
	move.w #(320*200)/16,d0
.bwcopy	clr.l (a1)
	clr.l 4(a1)
	moveq #$f,d3			; 16 pixel
	move.w #%1000000000000000,d2
.pixel
	move.l d0,-(a7)
	move.l d2,-(a7)
	moveq #0,d0
	moveq #0,d1
	moveq #0,d2
	move.b (a0)+,d0
	move.b (a0)+,d1
	move.b (a0)+,d2
	asr.w #2,d0
	asr.w #2,d2
	asr.w #1,d1
	add.w d0,d1
	add.w d2,d1			; d1 now contains 0-255 value

	move.l (a7)+,d2
	move.l (a7)+,d0

	asr.w #4,d1			; downsample
	and.w #$f,d1
	add.w d1,d1
	add.w d1,d1
	lea .bwjmp,a4
	move.l	(a4,d1),a3
	jmp (a3)
.bwjmp	dc.l .xout,.p1,.p2,.p3,.p4,.p5,.p6,.p7,.p8,.p9,.pa,.pb,.pc,.pd,.pe,.pf

.p1	or.w	d2,(a1)		; 0001
	bra 	.xout
.p2	or.w	d2,2(a1)	; 0010
	bra	.xout
.p3	or.w	d2,(a1)		; 0011
	or.w	d2,2(a1)
	bra	.xout
.p4	or.w	d2,4(a1)	; 0100
	bra	.xout
.p5	or.w	d2,4(a1)	; 0101
	or.w	d2,(a1)
	bra	.xout
.p6	or.w	d2,4(a1)	; 0110
	or.w	d2,2(a1)	
	bra	.xout
.p7	or.w	d2,(a1)		; 0111
	or.w	d2,2(a1)
	or.w	d2,4(a1)	
	bra	.xout
.p8	or.w	d2,6(a1)	; 1000
	bra	.xout
.p9	or.w	d2,6(a1)	; 1001
	or.w	d2,(a1)
	bra	.xout
.pa	or.w	d2,6(a1)	; 1010
	or.w	d2,2(a1)
	bra	.xout
.pb	or.w	d2,6(a1)	; 1011
	or.w	d2,2(a1)
	or.w	d2,(a1)
	bra	.xout
.pc	or.w	d2,6(a1)	; 1100
	or.w	d2,4(a1)
	bra	.xout
.pd	or.w	d2,6(a1)	; 1101
	or.w	d2,4(a1)
	or.w	d2,(a1)
	bra	.xout
.pe	or.w	d2,6(a1)	; 1110
	or.w	d2,4(a1)
	or.w	d2,2(a1)
	bra	.xout
.pf	or.w	d2,6(a1)	; 1111
	or.w	d2,4(a1)
	or.w	d2,2(a1)
	or.w	d2,(a1)

.xout	ror.w	d2
	dbf.w	d3,.pixel
	lea	8(a1),a1
	dbf 	d0,.bwcopy

	move.l	#bwvbl,$70.w
	move.w	#$2300,sr
	stop #$2300

	move.w	#15,d7		; times round loop
.xup	lea	bw_pal,a0
	lea $ffff8240.w,a1
	move.w	d7,-(a7)
	move.w	#$1,d7
	bsr	.fade
	move.w	(a7)+,d7
	move.w	#3,d4
.xxxh	move.w	bwcnt,d5
.xhol	cmp.w	bwcnt,d5
	beq.s	.xhol
	dbf	d4,.xxxh
	dbf	d7,.xup

	move.l	#5*60,d7
.holdl	move.w	bwcnt,d6
.holdx	cmp.w	bwcnt,d6
	beq.s	.holdx
	dbf.w	d7,.holdl

	move.w	#15,d7		; times round loop
.xup2	lea	black_pal,a0
	lea $ffff8240.w,a1
	move.w	d7,-(a7)
	move.w	#$ffff,d7
	bsr	.fade
	move.w	(a7)+,d7
	move.w	#3,d4
.xxxh2	move.w	bwcnt,d5
.xhol2	cmp.w	bwcnt,d5
	beq.s	.xhol2
	dbf	d4,.xxxh2
	dbf	d7,.xup2



	jsr init_colours

	moveq.l #0,d0
	lea $ffff8800.w,a0
	move.b d0,(a0)
	move.b d0,2(a0)
	move.b #1,(a0)
	move.b d0,2(a0)
	move.b #2,(a0)
	move.b d0,2(a0)
	move.b #3,(a0)
	move.b d0,2(a0)
	move.b #4,(a0)
	move.b d0,2(a0)
	move.b #5,(a0)
	move.b d0,2(a0)
	move.b #7,(a0)
	move.w #-1,2(a0)
	move.b #8,(a0)
	move.b d0,2(a0)
	move.b #9,(a0)
	move.b d0,2(a0)
	move.b #$a,(a0)
	move.b d0,2(a0)
	
	move.l #sample1,d0
	sub.l #sample,d0
	divu #310,d0
	move.w d0,frames
	subq.w #1,d0
	move.w d0,frames1

	lea sample,a0
	lea sample1,a1
.addie	add.b #-$80,(a0)+
	cmp.l a0,a1
	bne.s .addie

	lea samarea+(sample1-sample)+1,a0
	lea sample1+1,a1
	lea sample,a2
.double	moveq.l #0,d0
	move.b -(a1),d0
	asl.w #3,d0
	move.w d0,-(a0)
	cmp.l a1,a2
	bne.s .double

	move.l screen1,a0
	lea ramtop,a1
.wipe	clr.w (a0)+
	cmp.l a0,a1
	bne.s .wipe

	lea sample,a5
	move.w #$2300,sr
	stop #$2300
	move.l #vbl,$70.w
	move.l #hbl,$68.w

.space	clr.w vbl_done
.space1	tst.w vbl_done
	beq.s .space1
	bsr print
	bsr swap
	cmp.b #$39,$fffffc02.w
	bne.s .space

	bra out

.fade	move.w	#15,d6		; colours
.xcol	move.w (a1),d0		; get current colour
	move.w (a0)+,d1		; get required colour
	move.w	d1,d2
	move.w	d1,d3
	and.w	#$0700,d1
	and.w	#$0070,d2
	and.w	#$0007,d3
	move.w	d0,d5
	move.w	d0,d4
	and.w	#$0700,d4
	cmp.w	d1,d4
	beq.s	.o1
	tst.w	d7
	bmi	.d1
	add.w	#$0100,d5
	bra	.o1
.d1	sub.w	#$0100,d5

.o1	move.w	d0,d4
	and.w	#$0070,d4
	cmp.w	d2,d4
	beq.s	.o2
	tst.w	d7
	bmi	.d2
	add.w	#$0010,d5
	bra	.o2
.d2	sub.w	#$0010,d5

.o2	move.w	d0,d4
	and.w	#$0007,d4
	cmp.w	d3,d4
	beq.s	.o3
	tst.w	d7
	bmi	.d3
	add.w	#$0001,d5
	bra	.o3
.d3	sub.w	#$0001,d5

.o3	move.w	d5,(a1)+
	dbf	d6,.xcol

	rts


bwvbl	add.w	#1,bwcnt
	rte

bwcnt	dc.w	0
black_pal	ds.w 16

out	move.w #$2700,sr
	move.l old_vbl,$70.w
	move.l old_hbl,$68.w
	move.l #$8080000,$ffff8800.w
	move.l #$9090000,$ffff8800.w
	move.l #$a0a0000,$ffff8800.w
	movem.l old_pal,d0-7
	movem.l d0-7,$ffff8240.w
	move.b old_mfp,$fffffa07.w
	move.b old_mfp+1,$fffffa09.w
	move.b old_scr,$ffff8201.w
	move.b old_scr+1,$ffff8203.w
	move.b old_res,$ffff8260.w
	move.w #$2300,sr
	rts

print	move.w #39,d0
	move.l tpnt,a0
	moveq.l #1,d2
	moveq.l #7,d3
	lea prbuff(pc),a2
loop	cmp.b #$39,$fffffc02.w
	bne.s .1
	addq.l #4,a7
	bra out
.1	moveq.l #0,d1
	move.b (a0)+,d1
	sub.b #' ',d1
	add d1,d1
	add d1,d1
	lea ascii,a1
	move.l (a1,d1),a1
x	set 0
y	set 0
	rept 8
	move.b x(a1),y(a2)
x	set x+40
y	set y+160
	endr
	add.l d2,a2
	move.l d2,-(a7)
	move.l d3,d2
	move.l (a7)+,d3
	bsr frame
	dbra d0,loop
	move.l a0,tpnt
	cmp.b #-1,(a0)
	bne.s .rts
	move.l #text,tpnt
.rts	rts

updown	dc.w 1

swap	move.w #210,d0
	clr.w vbl_done
.wait	cmp.w #$39,$fffffc02.w
	beq space_push
	tst.w vbl_done
	beq.s .wait
	clr.w vbl_done
	dbra d0,.wait
	neg.w updown
	bpl up
down	lea prbuff(pc),a0
	move.l screen1,a1
	lea 160*10(a1),a1
	moveq.l #7,d2
.down
x	set 0
	rept 40
	clr.w x+160(a1)
	move.w x(a0),x(a1)
x	set x+8
	endr
	lea 160(a1),a1
	lea 160(a0),a0
	bsr frame
	bsr frame
	bsr frame
	dbra d2,.down
	rts
space_push
	addq.l #4,a7
	rts

up	lea prbuff+(9*160)(pc),a0
	move.l screen1,a1
	lea 160*19(a1),a1
	moveq.l #7,d2
.up
x	set 0
	rept 40
	clr.w x-160(a1)
	move.w x(a0),x(a1)
x	set x-8
	endr
	lea -160(a1),a1
	lea -160(a0),a0
	bsr frame
	bsr frame
	bsr frame
	dbra d2,.up
	rts

frame	clr.w vbl_done
.test	tst.w vbl_done
	beq.s .test
	cmp.w #$39,$fffffc02.w
	beq space_push
	rts
prbuff	ds.b 160*9
	ds.l 2
tpnt	dc.l text
;	dc.b "0123456789012345678901234567890123456789"
text
	DC.B " HI DUDES AND WELCOME ONE AND ALL TO--- "
	DC.B "       ....  THE ZOOM ROOM! ....        "
	DC.B "                                        "
	DC.B "       AND NOW, THE CREDITS-----        "
	DC.B "       ALL CODE BY: CYRANO JONES        "
	DC.B "     AUDIO: HOTHEAD BY DURAN DURAN      "
	DC.B "     IMAGE: SOUL CALIBUR (C) NAMCO      "
	DC.B "                                        "
	DC.B "  THIS IS A 15KHZ SAMPLE WITH A 24 BIT  "
	DC.B "   (16 MILLION COLOURS) 320X200 IMAGE   "
	DC.B " DOWN SAMPLED TO 512 COLOURS AND ZOOMED "
	DC.B "                                        " 

	DC.B "  LETS ENTER THE MYSTERIOUS WRAP TUBE!  "
	DC.B -1
	even

vbl_done	dc.w	0
bord_cnt	dc.w	32

vbl	move.w #1,vbl_done
	move.b screen1+1,$ffff8201.w
	move.b screen1+2,$ffff8203.w
	lea $ffff8800.w,a3
	lea samtab,a6
	and.w	#$f1ff,(a7)	;Enable HBL interrupt
	rte

_rte	move.l a6,a4
	moveq.l #0,d7		; 4 clocks
	move.w (a5)+,d7		; 8 clocks
	add.w d7,a4		; 4 clocks
	move.l (a4)+,d7		; 12 clocks
	movep.l d7,(a3)
	move.w (a4),d7		; 8 clocks
	movep.w d7,(a3)
	rte



old_stack	dc.l 0		

raster	ds.w 7
	dc.w $200,$400,$500,$700
	dc.w $600,$400,$300,$200
	ds.w 20

hbl	subq.w	#1,bord_cnt	;Right line?
	bpl	_rte
	move.l	#hbl2,$68.w
	stop	#$2100
hbl2
	move	#$2700,sr	;Yep,kill that border!
	addq.l	#6,a7		;Correct stack from 2nd interrupt
	move.l	#hbl,$68.w	;Restore HBL vector
	movem.l d0-a4/a6,-(a7)
	delay	204
	clr.b	$ffff820a.w	;60 Hz
	delay	76
	move.b	#2,$ffff820a.w	;50 Hz

	move.l a7,old_stack
	lea $ffff8242.w,a7

	move.w #32,bord_cnt

	move.l x_ptr,a0
	move.w (a0)+,d1
	bpl.s .gety
	lea xvals,a0
	move.w (a0)+,d1
.gety	move.l a0,x_ptr

	move.l y_ptr,a0
	move.l (a0)+,d0
	bpl.s .doneit
	lea yvals,a0
	move.l (a0)+,d0
.doneit	move.l a0,y_ptr
	lea colours,a1		** d3/d4 Constants
	add.l d0,a1
	add.w d1,a1

	lea $ffff8800.w,a3		** Sample player registers **
	subq.w #1,frames		**
	bpl.s .ok			** a3 pointer to $ffff8800.w
	move.w frames1,frames		** a5 pointer to sample data
	lea sample,a5
.ok
	moveq	#0,d6			** sync in registers
	moveq	#16,d7			** d6/d7/a6 trashed!!!
	lea 	samtab,a6
	move.l  a6,usp
	lea	$ffff8209.w,a6
	lea	raster(pc),a0

.wait	move.b	(a6),d6
	beq.s	.wait
	sub.w	d6,d7
	lsl.w	d7,d6
	delay	120
	move.l #640,d4			**
	lea $ffff8240.w,a2		** a1    pointer to colours
	jmp rout1

*****
rout1
*****
	lea 0(a1),a1
	move.l #66,d3		
line1	MACRO
	dcb.w 33,$3499		; move.w (a1)+,(a2)  -  12 each	
	move.w (a0)+,(a7)
	move.w (a5)+,d7		; 8 clocks
	move.l usp,a4		; 4 clocks
	add.w d7,a4		; 4 clocks
	move.l (a4)+,d7		; 12 clocks
	movep.l d7,(a3)
	move.w (a4),d7		; 8 clocks
	movep.w d7,(a3)
	sub.w d3,a1		
	ENDM
	rept 27
	line1
	nop
	nop
	line1
	nop
	nop
	line1
	nop
	nop
	line1
	nop
	nop
	line1
	nop
	nop
	line1
	nop
	nop
	line1
	nop
	nop
	line1
	nop
	nop
	line1
	nop
	nop
	line1
	add.l d4,a1
	endr
	line1
	nop
	nop
	line1
	nop
	nop
	line1
	nop
	nop
	line1
	nop
	nop
	line1
	nop
	nop
	line1
	nop
	nop
	line1
	clr.w (a2)
	move.l old_stack,a7

	movem.l (a7)+,d0-a4/a6
	or.w	#$0300,(a7)	;Kill HBL interrupt
	rte



init_colours
	lea picture+(320*200*3),a0	; a0 points to final pixel triplet
	lea colours+(320*200*2)-2,a1	; a1 points to end of colour bank
	move.l #(320*200),d0	; d0 is number of 24 bit pixels to do
.loop	bsr .pull1
	subq.l #1,d0
	bne.s .loop
	rts

.pull1
	moveq #0,d1
	moveq #0,d2
	moveq #0,d3
	move.b -(a0),d3		; blue
	move.b -(a0),d2		; green
	move.b -(a0),d1		; red
	ror.w #5,d1
	ror.w #5,d2
	ror.w #5,d3
	and.w #$0007,d1
	and.w #$0007,d2
	and.w #$0007,d3

	rol.w #4,d2
	rol.w #8,d1
	or.w d1,d3
	or.w d2,d3
	move.w d3,-(a1)
	rts

screen1	dc.l ramtop-($e000*1)

samtab
      DC.B   $08,$0C,$09,$0B,$0A,$09,$00,$00
      DC.B   $08,$0C,$09,$0B,$0A,$09,$00,$00
      DC.B   $08,$0D,$09,$08,$0A,$08,$00,$00
      DC.B   $08,$0B,$09,$0B,$0A,$0B,$00,$00
      DC.B   $08,$0D,$09,$09,$0A,$05,$00,$00
      DC.B   $08,$0C,$09,$0B,$0A,$08,$00,$00
      DC.B   $08,$0D,$09,$09,$0A,$02,$00,$00
      DC.B   $08,$0D,$09,$08,$0A,$06,$00,$00
      DC.B   $08,$0C,$09,$0B,$0A,$07,$00,$00
      DC.B   $08,$0D,$09,$07,$0A,$07,$00,$00
      DC.B   $08,$0C,$09,$0B,$0A,$06,$00,$00
      DC.B   $08,$0C,$09,$0A,$0A,$09,$00,$00
      DC.B   $08,$0B,$09,$0B,$0A,$0A,$00,$00
      DC.B   $08,$0C,$09,$0B,$0A,$02,$00,$00
      DC.B   $08,$0C,$09,$0B,$0A,$00,$00,$00
      DC.B   $08,$0C,$09,$0A,$0A,$08,$00,$00
      DC.B   $08,$0D,$09,$06,$0A,$04,$00,$00
      DC.B   $08,$0D,$09,$05,$0A,$05,$00,$00
      DC.B   $08,$0D,$09,$05,$0A,$04,$00,$00
      DC.B   $08,$0C,$09,$09,$0A,$09,$00,$00
      DC.B   $08,$0D,$09,$04,$0A,$03,$00,$00
      DC.B   $08,$0B,$09,$0B,$0A,$09,$00,$00
      DC.B   $08,$0C,$09,$0A,$0A,$05,$00,$00
      DC.B   $08,$0B,$09,$0A,$0A,$0A,$00,$00
      DC.B   $08,$0C,$09,$09,$0A,$08,$00,$00
      DC.B   $08,$0B,$09,$0B,$0A,$08,$00,$00
      DC.B   $08,$0C,$09,$0A,$0A,$00,$00,$00
      DC.B   $08,$0C,$09,$0A,$0A,$00,$00,$00
      DC.B   $08,$0C,$09,$09,$0A,$07,$00,$00
      DC.B   $08,$0B,$09,$0B,$0A,$07,$00,$00
      DC.B   $08,$0C,$09,$09,$0A,$06,$00,$00
      DC.B   $08,$0B,$09,$0B,$0A,$06,$00,$00
      DC.B   $08,$0B,$09,$0A,$0A,$09,$00,$00
      DC.B   $08,$0B,$09,$0B,$0A,$05,$00,$00
      DC.B   $08,$0A,$09,$0A,$0A,$0A,$00,$00
      DC.B   $08,$0B,$09,$0B,$0A,$02,$00,$00
      DC.B   $08,$0B,$09,$0A,$0A,$08,$00,$00
      DC.B   $08,$0C,$09,$07,$0A,$07,$00,$00
      DC.B   $08,$0C,$09,$08,$0A,$04,$00,$00
      DC.B   $08,$0C,$09,$07,$0A,$06,$00,$00
      DC.B   $08,$0B,$09,$09,$0A,$09,$00,$00
      DC.B   $08,$0C,$09,$06,$0A,$06,$00,$00
      DC.B   $08,$0A,$09,$0A,$0A,$09,$00,$00
      DC.B   $08,$0C,$09,$07,$0A,$03,$00,$00
      DC.B   $08,$0B,$09,$0A,$0A,$05,$00,$00
      DC.B   $08,$0B,$09,$09,$0A,$08,$00,$00
      DC.B   $08,$0B,$09,$0A,$0A,$03,$00,$00
      DC.B   $08,$0A,$09,$0A,$0A,$08,$00,$00
      DC.B   $08,$0B,$09,$0A,$0A,$00,$00,$00
      DC.B   $08,$0B,$09,$09,$0A,$07,$00,$00
      DC.B   $08,$0B,$09,$08,$0A,$08,$00,$00
      DC.B   $08,$0A,$09,$0A,$0A,$07,$00,$00
      DC.B   $08,$0A,$09,$09,$0A,$09,$00,$00
      DC.B   $08,$0C,$09,$01,$0A,$01,$00,$00
      DC.B   $08,$0A,$09,$0A,$0A,$06,$00,$00
      DC.B   $08,$0B,$09,$08,$0A,$07,$00,$00
      DC.B   $08,$0A,$09,$0A,$0A,$05,$00,$00
      DC.B   $08,$0A,$09,$09,$0A,$08,$00,$00
      DC.B   $08,$0A,$09,$0A,$0A,$02,$00,$00
      DC.B   $08,$0A,$09,$0A,$0A,$01,$00,$00
      DC.B   $08,$0A,$09,$0A,$0A,$00,$00,$00
      DC.B   $08,$09,$09,$09,$0A,$09,$00,$00
      DC.B   $08,$0A,$09,$08,$0A,$08,$00,$00
      DC.B   $08,$0B,$09,$08,$0A,$01,$00,$00
      DC.B   $08,$0A,$09,$09,$0A,$06,$00,$00
      DC.B   $08,$0B,$09,$07,$0A,$04,$00,$00
      DC.B   $08,$0A,$09,$09,$0A,$05,$00,$00
      DC.B   $08,$09,$09,$09,$0A,$08,$00,$00
      DC.B   $08,$0A,$09,$09,$0A,$03,$00,$00
      DC.B   $08,$0A,$09,$08,$0A,$06,$00,$00
      DC.B   $08,$0A,$09,$09,$0A,$00,$00,$00
      DC.B   $08,$09,$09,$09,$0A,$07,$00,$00
      DC.B   $08,$09,$09,$08,$0A,$08,$00,$00
      DC.B   $08,$0A,$09,$08,$0A,$04,$00,$00
      DC.B   $08,$09,$09,$09,$0A,$06,$00,$00
      DC.B   $08,$0A,$09,$08,$0A,$01,$00,$00
      DC.B   $08,$09,$09,$09,$0A,$05,$00,$00
      DC.B   $08,$09,$09,$08,$0A,$07,$00,$00
      DC.B   $08,$08,$09,$08,$0A,$08,$00,$00
      DC.B   $08,$09,$09,$09,$0A,$02,$00,$00
      DC.B   $08,$09,$09,$08,$0A,$06,$00,$00
      DC.B   $08,$09,$09,$09,$0A,$00,$00,$00
      DC.B   $08,$09,$09,$07,$0A,$07,$00,$00
      DC.B   $08,$08,$09,$08,$0A,$07,$00,$00
      DC.B   $08,$09,$09,$07,$0A,$06,$00,$00
      DC.B   $08,$09,$09,$08,$0A,$02,$00,$00
      DC.B   $08,$08,$09,$08,$0A,$06,$00,$00
      DC.B   $08,$09,$09,$06,$0A,$06,$00,$00
      DC.B   $08,$08,$09,$07,$0A,$07,$00,$00
      DC.B   $08,$08,$09,$08,$0A,$04,$00,$00
      DC.B   $08,$08,$09,$07,$0A,$06,$00,$00
      DC.B   $08,$08,$09,$08,$0A,$02,$00,$00
      DC.B   $08,$07,$09,$07,$0A,$07,$00,$00
      DC.B   $08,$08,$09,$06,$0A,$06,$00,$00
      DC.B   $08,$08,$09,$07,$0A,$04,$00,$00
      DC.B   $08,$07,$09,$07,$0A,$06,$00,$00
      DC.B   $08,$08,$09,$06,$0A,$05,$00,$00
      DC.B   $08,$08,$09,$06,$0A,$04,$00,$00
      DC.B   $08,$07,$09,$06,$0A,$06,$00,$00
      DC.B   $08,$07,$09,$07,$0A,$04,$00,$00
      DC.B   $08,$08,$09,$05,$0A,$04,$00,$00
      DC.B   $08,$06,$09,$06,$0A,$06,$00,$00
      DC.B   $08,$07,$09,$06,$0A,$04,$00,$00
      DC.B   $08,$07,$09,$05,$0A,$05,$00,$00
      DC.B   $08,$06,$09,$06,$0A,$05,$00,$00
      DC.B   $08,$06,$09,$06,$0A,$04,$00,$00
      DC.B   $08,$06,$09,$05,$0A,$05,$00,$00
      DC.B   $08,$06,$09,$06,$0A,$02,$00,$00
      DC.B   $08,$06,$09,$05,$0A,$04,$00,$00
      DC.B   $08,$05,$09,$05,$0A,$05,$00,$00
      DC.B   $08,$06,$09,$05,$0A,$02,$00,$00
      DC.B   $08,$05,$09,$05,$0A,$04,$00,$00
      DC.B   $08,$05,$09,$04,$0A,$04,$00,$00
      DC.B   $08,$05,$09,$05,$0A,$02,$00,$00
      DC.B   $08,$04,$09,$04,$0A,$04,$00,$00
      DC.B   $08,$04,$09,$04,$0A,$03,$00,$00
      DC.B   $08,$04,$09,$04,$0A,$02,$00,$00
      DC.B   $08,$04,$09,$03,$0A,$03,$00,$00
      DC.B   $08,$03,$09,$03,$0A,$03,$00,$00
      DC.B   $08,$03,$09,$03,$0A,$02,$00,$00
      DC.B   $08,$03,$09,$02,$0A,$02,$00,$00
      DC.B   $08,$02,$09,$02,$0A,$02,$00,$00
      DC.B   $08,$02,$09,$02,$0A,$01,$00,$00
      DC.B   $08,$01,$09,$01,$0A,$01,$00,$00
      DC.B   $08,$02,$09,$01,$0A,$00,$00,$00
      DC.B   $08,$01,$09,$01,$0A,$00,$00,$00
      DC.B   $08,$01,$09,$00,$0A,$00,$00,$00
      DC.B   $08,$00,$09,$00,$0A,$00,$00,$00
      DC.B   $08,$0E,$09,$0D,$0A,$0C,$00,$00
      DC.B   $08,$0F,$09,$03,$0A,$00,$00,$00
      DC.B   $08,$0F,$09,$03,$0A,$00,$00,$00
      DC.B   $08,$0F,$09,$03,$0A,$00,$00,$00
      DC.B   $08,$0F,$09,$03,$0A,$00,$00,$00
      DC.B   $08,$0F,$09,$03,$0A,$00,$00,$00
      DC.B   $08,$0F,$09,$03,$0A,$00,$00,$00
      DC.B   $08,$0E,$09,$0D,$0A,$0B,$00,$00
      DC.B   $08,$0E,$09,$0D,$0A,$0B,$00,$00
      DC.B   $08,$0E,$09,$0D,$0A,$0B,$00,$00
      DC.B   $08,$0E,$09,$0D,$0A,$0B,$00,$00
      DC.B   $08,$0E,$09,$0D,$0A,$0B,$00,$00
      DC.B   $08,$0E,$09,$0D,$0A,$0B,$00,$00
      DC.B   $08,$0E,$09,$0D,$0A,$0B,$00,$00
      DC.B   $08,$0E,$09,$0D,$0A,$0A,$00,$00
      DC.B   $08,$0E,$09,$0D,$0A,$0A,$00,$00
      DC.B   $08,$0E,$09,$0D,$0A,$0A,$00,$00
      DC.B   $08,$0E,$09,$0D,$0A,$0A,$00,$00
      DC.B   $08,$0E,$09,$0C,$0A,$0C,$00,$00
      DC.B   $08,$0E,$09,$0D,$0A,$00,$00,$00
      DC.B   $08,$0D,$09,$0D,$0A,$0D,$00,$00
      DC.B   $08,$0D,$09,$0D,$0A,$0D,$00,$00
      DC.B   $08,$0D,$09,$0D,$0A,$0D,$00,$00
      DC.B   $08,$0D,$09,$0D,$0A,$0D,$00,$00
      DC.B   $08,$0D,$09,$0D,$0A,$0D,$00,$00
      DC.B   $08,$0D,$09,$0D,$0A,$0D,$00,$00
      DC.B   $08,$0E,$09,$0C,$0A,$0B,$00,$00
      DC.B   $08,$0E,$09,$0C,$0A,$0B,$00,$00
      DC.B   $08,$0E,$09,$0C,$0A,$0B,$00,$00
      DC.B   $08,$0E,$09,$0C,$0A,$0B,$00,$00
      DC.B   $08,$0E,$09,$0C,$0A,$0B,$00,$00
      DC.B   $08,$0E,$09,$0C,$0A,$0B,$00,$00
      DC.B   $08,$0E,$09,$0C,$0A,$0B,$00,$00
      DC.B   $08,$0E,$09,$0C,$0A,$0B,$00,$00
      DC.B   $08,$0E,$09,$0C,$0A,$0A,$00,$00
      DC.B   $08,$0E,$09,$0C,$0A,$0A,$00,$00
      DC.B   $08,$0E,$09,$0C,$0A,$0A,$00,$00
      DC.B   $08,$0E,$09,$0C,$0A,$0A,$00,$00
      DC.B   $08,$0D,$09,$0D,$0A,$0C,$00,$00
      DC.B   $08,$0D,$09,$0D,$0A,$0C,$00,$00
      DC.B   $08,$0E,$09,$0C,$0A,$09,$00,$00
      DC.B   $08,$0E,$09,$0C,$0A,$09,$00,$00
      DC.B   $08,$0E,$09,$0C,$0A,$05,$00,$00
      DC.B   $08,$0E,$09,$0C,$0A,$00,$00,$00
      DC.B   $08,$0E,$09,$0C,$0A,$00,$00,$00
      DC.B   $08,$0E,$09,$0B,$0A,$0B,$00,$00
      DC.B   $08,$0E,$09,$0B,$0A,$0B,$00,$00
      DC.B   $08,$0E,$09,$0B,$0A,$0B,$00,$00
      DC.B   $08,$0E,$09,$0B,$0A,$0B,$00,$00
      DC.B   $08,$0E,$09,$0B,$0A,$0A,$00,$00
      DC.B   $08,$0E,$09,$0B,$0A,$0A,$00,$00
      DC.B   $08,$0E,$09,$0B,$0A,$0A,$00,$00
      DC.B   $08,$0D,$09,$0D,$0A,$0B,$00,$00
      DC.B   $08,$0D,$09,$0D,$0A,$0B,$00,$00
      DC.B   $08,$0D,$09,$0D,$0A,$0B,$00,$00
      DC.B   $08,$0E,$09,$0B,$0A,$09,$00,$00
      DC.B   $08,$0E,$09,$0B,$0A,$09,$00,$00
      DC.B   $08,$0E,$09,$0B,$0A,$09,$00,$00
      DC.B   $08,$0D,$09,$0C,$0A,$0C,$00,$00
      DC.B   $08,$0D,$09,$0D,$0A,$0A,$00,$00
      DC.B   $08,$0E,$09,$0B,$0A,$07,$00,$00
      DC.B   $08,$0E,$09,$0B,$0A,$00,$00,$00
      DC.B   $08,$0E,$09,$0B,$0A,$00,$00,$00
      DC.B   $08,$0D,$09,$0D,$0A,$09,$00,$00
      DC.B   $08,$0D,$09,$0D,$0A,$09,$00,$00
      DC.B   $08,$0E,$09,$0A,$0A,$09,$00,$00
      DC.B   $08,$0D,$09,$0D,$0A,$08,$00,$00
      DC.B   $08,$0D,$09,$0D,$0A,$07,$00,$00
      DC.B   $08,$0D,$09,$0D,$0A,$04,$00,$00
      DC.B   $08,$0D,$09,$0D,$0A,$00,$00,$00
      DC.B   $08,$0E,$09,$0A,$0A,$04,$00,$00
      DC.B   $08,$0E,$09,$09,$0A,$09,$00,$00
      DC.B   $08,$0E,$09,$09,$0A,$09,$00,$00
      DC.B   $08,$0D,$09,$0C,$0A,$0B,$00,$00
      DC.B   $08,$0E,$09,$09,$0A,$08,$00,$00
      DC.B   $08,$0E,$09,$09,$0A,$08,$00,$00
      DC.B   $08,$0E,$09,$09,$0A,$07,$00,$00
      DC.B   $08,$0E,$09,$08,$0A,$08,$00,$00
      DC.B   $08,$0E,$09,$09,$0A,$01,$00,$00
      DC.B   $08,$0C,$09,$0C,$0A,$0C,$00,$00
      DC.B   $08,$0D,$09,$0C,$0A,$0A,$00,$00
      DC.B   $08,$0E,$09,$08,$0A,$06,$00,$00
      DC.B   $08,$0E,$09,$07,$0A,$07,$00,$00
      DC.B   $08,$0E,$09,$08,$0A,$00,$00,$00
      DC.B   $08,$0E,$09,$07,$0A,$05,$00,$00
      DC.B   $08,$0E,$09,$06,$0A,$06,$00,$00
      DC.B   $08,$0D,$09,$0C,$0A,$09,$00,$00
      DC.B   $08,$0E,$09,$05,$0A,$05,$00,$00
      DC.B   $08,$0E,$09,$04,$0A,$04,$00,$00
      DC.B   $08,$0D,$09,$0C,$0A,$08,$00,$00
      DC.B   $08,$0D,$09,$0B,$0A,$0B,$00,$00
      DC.B   $08,$0E,$09,$00,$0A,$00,$00,$00
      DC.B   $08,$0D,$09,$0C,$0A,$06,$00,$00
      DC.B   $08,$0D,$09,$0C,$0A,$05,$00,$00
      DC.B   $08,$0D,$09,$0C,$0A,$02,$00,$00
      DC.B   $08,$0C,$09,$0C,$0A,$0B,$00,$00
      DC.B   $08,$0C,$09,$0C,$0A,$0B,$00,$00
      DC.B   $08,$0D,$09,$0B,$0A,$0A,$00,$00
      DC.B   $08,$0D,$09,$0B,$0A,$0A,$00,$00
      DC.B   $08,$0D,$09,$0B,$0A,$0A,$00,$00
      DC.B   $08,$0D,$09,$0B,$0A,$0A,$00,$00
      DC.B   $08,$0C,$09,$0C,$0A,$0A,$00,$00
      DC.B   $08,$0C,$09,$0C,$0A,$0A,$00,$00
      DC.B   $08,$0C,$09,$0C,$0A,$0A,$00,$00
      DC.B   $08,$0D,$09,$0B,$0A,$09,$00,$00
      DC.B   $08,$0D,$09,$0B,$0A,$09,$00,$00
      DC.B   $08,$0D,$09,$0A,$0A,$0A,$00,$00
      DC.B   $08,$0D,$09,$0A,$0A,$0A,$00,$00
      DC.B   $08,$0D,$09,$0A,$0A,$0A,$00,$00
      DC.B   $08,$0C,$09,$0C,$0A,$09,$00,$00
      DC.B   $08,$0C,$09,$0C,$0A,$09,$00,$00
      DC.B   $08,$0C,$09,$0C,$0A,$09,$00,$00
      DC.B   $08,$0D,$09,$0B,$0A,$06,$00,$00
      DC.B   $08,$0C,$09,$0B,$0A,$0B,$00,$00
      DC.B   $08,$0C,$09,$0C,$0A,$08,$00,$00
      DC.B   $08,$0D,$09,$0B,$0A,$00,$00,$00
      DC.B   $08,$0D,$09,$0B,$0A,$00,$00,$00
      DC.B   $08,$0C,$09,$0C,$0A,$07,$00,$00
      DC.B   $08,$0C,$09,$0C,$0A,$06,$00,$00
      DC.B   $08,$0C,$09,$0C,$0A,$05,$00,$00
      DC.B   $08,$0C,$09,$0C,$0A,$03,$00,$00
      DC.B   $08,$0C,$09,$0C,$0A,$01,$00,$00
      DC.B   $08,$0C,$09,$0B,$0A,$0A,$00,$00
      DC.B   $08,$0D,$09,$0A,$0A,$05,$00,$00
      DC.B   $08,$0D,$09,$0A,$0A,$04,$00,$00
      DC.B   $08,$0D,$09,$0A,$0A,$02,$00,$00
      DC.B   $08,$0D,$09,$09,$0A,$08,$00,$00
      DC.B   $08,$0D,$09,$09,$0A,$08,$00,$00
      DC.B   $05,$06,$05,$05,$04,$05,$29,$01
      DC.B   $1F,$01,$08,$02,$06,$02,$01,$04
L0016:DC.B   $13,$00
L0017:DC.B   $11,$00

;; x 143 y 87

x_ptr	dc.l xvals
xvals
xxx	set 0
	rept 288
	dc.w xxx
	dc.w xxx
xxx	set xxx+2
	endr
xxx1	set 288*2
	rept 288
	dc.w xxx1
	dc.w xxx1
xxx1	set xxx1-2
	endr
q1	set 0
	rept 143
	dc.w q1
q1	set q1+2
	endr

	incbin coordsx.bin
e1	set 143*2
	rept 143
	dc.w e1
e1	set e1-2
	endr

	dc.l $ffffffff
y_ptr	dc.l yvals
yvals
	incbin coordsy.bin
w1	set 87*640
	rept 86
	dc.l w1
w1	set w1-640
	endr

xxxx	set 0
	rept 170
	dc.l xxxx
	dc.l xxxx
xxxx	set xxxx+640
	endr
xxxx1	set 170*640
	rept 82
	dc.l xxxx1
	dc.l xxxx1
xxxx1	set xxxx1-640
	endr 
	dc.l $ffffffff

frames	dc.w 0
frames1	dc.w 0

font	incbin rawfont.bin
	even

ascii	
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

old_vbl	dc.l 0
old_hbl	dc.l 0
old_scr	dc.w 0
old_mfp	dc.w 0
old_pal	ds.w 16
old_res	dc.w 0

samptr	dc.l sample
sample	incbin hothead.spl
sample1
	even
samarea	ds.l 1
duffer	dc.l 0
colours	equ *+78000 		; length of sample
picture	incbin namco2.raw	; 320x200x24 RAW RGB Planar
	even
bw_pal
	dc.w $000,$001
	dc.w $001,$111
	dc.w $112,$222
	dc.w $223,$333
	dc.w $334,$444
	dc.w $445,$555
	dc.w $556,$666
	dc.w $667,$777
	

