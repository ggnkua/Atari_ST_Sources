************************************************************************
* Zippy's Mega Overscan Scroller Demo V2.08                            *
*                                                                      *
* As far as I know this version includes full screen routs that will   *
* work on most ST's (Including STE's !!!!)                             *
*                                                                      *
* I 've included clock cycle counts for the crucial bits of the border *
* killing code in case you want to mess about with it yourself.        *
*                                                                      *
************************************************************************

	opt s-
	clr.l -(sp)			;super mode
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	move.l d0,olds			;save old stack
	move.w #4,-(sp)			;save old rez
	trap #14
	addq.l #2,sp
	move.w d0,oldrez
	move.w #2,-(sp)			;save old screen base
	trap #14
	addq.l #2,sp
	move.l d0,oldbase
	move.w #0,-(sp)			;go low-res
	pea $78000
	pea $78000
	move.w #5,-(sp)
	trap #14
	add.l #12,sp
	eor.b #3,$484.w
	lea $7fffe,sp			;new stack			*
	movem.l $ffff8240.w,d0-d7	;save old pallete
	movem.l d0-d7,oldpal
	bsr v_sync
	movem.l black,d0-d7		;black pallete
	movem.l d0-d7,$ffff8240.w
	movem.l (pic1+2),d0-d7		;get pallete
	movem.l d0-d7,newpal		;store pallete
	lea $50000,a0			;clear screens			*
cls1	clr.l (a0)+
	clr.l (a0)+
	cmp.l #$7fff0,a0						*
	blt cls1
	move.l #music,musoff		;init music pointer
	bsr intro			;do little text intro
ex	bsr makescr			;make flip screens for logo
	bsr makedat			;make big-scroll code
	bsr pcs				;pre-calc scroller
	bsr psf				;pre-shift font
	movem.l newpal,d0-d7		;get new pallete
	movem.l d0-d7,$ffff8240.w	;set new pallete

	jsr full			;go mega-intro !!

	move.l #$0707ffff,$ffff8800.w	;clear sound registers
	move.l #$08080000,$ffff8800.w
	move.l #$09090000,$ffff8800.w
	move.l #$0a0a0000,$ffff8800.w
	movem.l black,d0-d7		;black pallete
	movem.l d0-d7,$ffff8240.w
	lea $30000,a0			;clear screens			*
cls	clr.l (a0)+
	clr.l (a0)+
	cmp.l #$7fff0,a0						*
	blt cls
	movem.l oldpal,d0-d7		;restore old pallete
	movem.l d0-d7,$ffff8240.w
	eor.b #3,$484.w
	move.w oldrez,-(sp)		;restore old screen base
	move.l oldbase,-(sp)		;and old rez
	move.l oldbase,-(sp)
	move.w #5,-(sp)
	trap #14
	add.l #12,sp
	move.l #$140,$bc.w
	lea crack(pc),a0
	lea intro(pc),a2
	lea $140.w,a1
.1	move.w (a0)+,(a1)+
	cmp.l a0,a2
	bne.s .1
	move.l olds,-(sp)		;restore old stack
	move.w #$20,-(sp)		;and user mode
	trap #1
	addq.l #6,sp
	clr.w -(sp)			;terminate
	trap #1

crack	nop
	nop
	move.l a0,$140.w
	move.l 2(sp),a0
	move.w #$4dfa,-2(a0)
	subq.l #2,2(sp)
	add.l #$4ee7c,a0
	move.l #$4e714e71,(a0)
	move.l $140.w,a0
	rte

intro	lea (logo+32),a0		;start of logo
	lea $7aa90,a1			;middle of screen
	move.w #649,d0			;counter
clogo1	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	dbf d0,clogo1
	bsr v_sync
	lea logo,a0			;fade up logo colours
	bsr fade_up
	moveq #110,d7			;pause
.1	bsr v_sync
	move.l #$000600ff,-(sp)
	trap #1
	addq.l #4,sp
	cmp.b #' ',d0
	beq .2
	dbf d7,.1
	lea logo,a0			;fade down logo colours
	bsr fade_dn
	moveq #35,d0			;pause
	bsr wait
	lea text1,a0			;display message 1
	bsr print
	lea font1,a0			;fade up font colours
	bsr fade_up
	moveq #85,d0			;pause
	bsr wait
	lea font1,a0			;fade down font colours
	bsr fade_dn
	moveq #35,d0			;pause
	bsr wait
	lea (text1+20),a0		;display message 2
	bsr print
	lea font1,a0			;fade up font colours
	bsr fade_up
	moveq #85,d0			;pause
	bsr wait
	lea font1,a0			;fade down font colours
	bsr fade_dn
	moveq #35,d0			;pause
	bsr wait
	lea (text1+40),a0		;display message 3
	bsr print
	lea font1,a0			;fade up font colours
	bsr fade_up
	moveq #85,d0			;pause
	bsr wait
	lea font1,a0			;fade down font colours
	bsr fade_dn
	rts
.2	lea logo,a0
	bsr fade_dn
	moveq #35,d0
	bsr wait
	move.w #$6022,ex
	rts
	
clr	lea $78000,a0			;clear screen at $78000
	movem.l black,d1-d7/a4-a6
	move.w #199,d0			;200 lines
.1	movem.l d1-d7/a4-a6,(a0)	;fast clear
	movem.l d1-d7/a4-a6,40(a0)
	movem.l d1-d7/a4-a6,80(a0)
	movem.l d1-d7/a4-a6,120(a0)
	lea $a0(a0),a0			;next line
	dbf d0,.1
	rts

print	move.l a0,-(sp)			;save text pointer
	bsr clr				;clear screen
	move.l (sp)+,a0			;restore text pointer
	lea $7b980,a1			;middle of screen
	lea font_tab,a2			;font pointer table (A-Z only!)
	moveq #19,d7			;20 chars accross screen
.1	moveq #0,d0
	move.b (a0)+,d0			;get char
	cmp.b #' ',d0			;check for space
	beq .2
	sub.b #'A',d0			;calc offset
	lsl.l #2,d0			;in font table
	move.l 0(a2,d0.w),a3		;get address of char
	movem.l (a3),d1-d2		;copy char
	movem.l d1-d2,(a1)		;onto screen
	movem.l ($a0*1)(a3),d1-d2
	movem.l d1-d2,($a0*1)(a1)
	movem.l ($a0*2)(a3),d1-d2
	movem.l d1-d2,($a0*2)(a1)
	movem.l ($a0*3)(a3),d1-d2
	movem.l d1-d2,($a0*3)(a1)
	movem.l ($a0*4)(a3),d1-d2
	movem.l d1-d2,($a0*4)(a1)
	movem.l ($a0*5)(a3),d1-d2
	movem.l d1-d2,($a0*5)(a1)
	movem.l ($a0*6)(a3),d1-d2
	movem.l d1-d2,($a0*6)(a1)
	movem.l ($a0*7)(a3),d1-d2
	movem.l d1-d2,($a0*7)(a1)
	movem.l ($a0*8)(a3),d1-d2
	movem.l d1-d2,($a0*8)(a1)
	movem.l ($a0*9)(a3),d1-d2
	movem.l d1-d2,($a0*9)(a1)
	movem.l ($a0*10)(a3),d1-d2
	movem.l d1-d2,($a0*10)(a1)
	movem.l ($a0*11)(a3),d1-d2
	movem.l d1-d2,($a0*11)(a1)
	movem.l ($a0*12)(a3),d1-d2
	movem.l d1-d2,($a0*12)(a1)
	movem.l ($a0*13)(a3),d1-d2
	movem.l d1-d2,($a0*13)(a1)
	movem.l ($a0*14)(a3),d1-d2
	movem.l d1-d2,($a0*14)(a1)
	movem.l ($a0*15)(a3),d1-d2
	movem.l d1-d2,($a0*15)(a1)
.2	lea 8(a1),a1			;next position
	dbf d7,.1			;next char
	rts

wait	bsr v_sync			;wait for vertical sync
	dbf d0,wait			;d0 times....
	rts

v_sync	movem.l d0-a6,-(sp)		;save all registers
	move.w #37,-(sp)		;wait sync
	trap #14
	addq.l #2,sp
	movem.l (sp)+,d0-a6		;restore and exit
	rts

fade_up	moveq #0,d7			;initial max R value
	moveq #0,d6			;initial max G value
	moveq #0,d5			;initial max B value
	moveq #7,d3			;8 fades (from 0 to 7)
	move.l a0,-(sp)			;save pallete pointer
.2	moveq #15,d4			;16 colours
	move.l (sp),a0			;get pallete pointer
	lea $ffff8240.w,a1		;point to screen pallete
	bsr v_sync			;wait
	bsr v_sync			;for
	bsr v_sync			;it !!
.1	move.w (a0)+,d0			;get a colour from pallete
	move.w d0,d1			;copy
	move.w d0,d2			;copy
	and.w #$700,d0			;split R value
	and.w #$070,d1			;split G value
	and.w #$007,d2			;split B value
	cmp.w d0,d5			;Is fade value higher than R value?
	bgt.s .3
	move.w d5,d0			;If not, make colour = fade value
.3	cmp.w d1,d6			;Is fade value higher than G value?
	bgt.s .4
	move.w d6,d1			;If not, make colour = fade value
.4	cmp.w d2,d7			;Is fade value higher than B value?
	bgt.s .5
	move.w d7,d2			;If not, make colour = fade value
.5	or.w d2,d1			;merge G and B
	or.w d1,d0			;merge R, G and B
	move.w d0,(a1)+			;display RGB value
	dbf d4,.1			;next colour
	add.w #$100,d5			;fade up 1 R value (max)
	add.w #$010,d6			;fade up 1 G value (max)
	add.w #$001,d7			;fade up 1 B value (max)
	dbf d3,.2			;next fade
	tst.l (sp)+			;tidy stack
	rts

fade_dn	move.w #$700,d5			;see comments for fade_up
	move.w #$070,d6			;goes from 7 to 0 in steps of 1,
	move.w #$007,d7			;instead of 0 to 7 in steps of 1 !!
	moveq #7,d3
	move.l a0,-(sp)
.2	moveq #15,d4
	move.l (sp),a0
	lea $ffff8240.w,a1
	bsr v_sync
	bsr v_sync
	bsr v_sync
.1	move.w (a0)+,d0
	move.w d0,d1
	move.w d0,d2
	and.w #$700,d0
	and.w #$070,d1
	and.w #$007,d2
	cmp.w d0,d5
	bgt.s .3
	move.w d5,d0
.3	cmp.w d1,d6
	bgt.s .4
	move.w d6,d1
.4	cmp.w d2,d7
	bgt.s .5
	move.w d7,d2
.5	or.w d2,d1
	or.w d1,d0
	move.w d0,(a1)+
	dbf d4,.1
	sub.w #$100,d5
	sub.w #$010,d6
	sub.w #$001,d7
	dbf d3,.2
	tst.l (sp)+
	rts


scroll1	move.l messpt,a1		;get scroll pointer
	lea font,a2			;and shifted font address
	moveq #19,d0			;20 chars
sc1	moveq #0,d1
	move.b (a1)+,d1			;get char
	lsl.w #6,d1			;*64
	lea $0(a2,d1.w),a3		;start of char
	move.w 2(a3),(a0)
	move.w 6(a3),($a0*1)(a0)
	move.w 10(a3),($a0*2)(a0)
	move.w 14(a3),($a0*3)(a0)
	move.w 18(a3),($a0*4)(a0)
	move.w 22(a3),($a0*5)(a0)
	move.w 26(a3),($a0*6)(a0)
	move.w 30(a3),($a0*7)(a0)
	move.w 34(a3),($a0*8)(a0)
	move.w 38(a3),($a0*9)(a0)
	move.w 42(a3),($a0*10)(a0)
	move.w 46(a3),($a0*11)(a0)
	move.w 50(a3),($a0*12)(a0)
	move.w 54(a3),($a0*13)(a0)
	move.w 58(a3),($a0*14)(a0)
	move.w 62(a3),($a0*15)(a0)
	lea 8(a0),a0
	dbf d0,sc1
	move.l #scroll2,(js1+2)		;do rout 2 next time
	rts

scroll2	move.l messpt,a1		;get scroll pointer
	lea (font+$f00),a2		;and shifted font address
	moveq #0,d1
	move.b (a1)+,d1			;get first clipped char
	lsl.w #6,d1			;*64
	lea $0(a2,d1.w),a3		;start of char
	move.w 2(a3),(a0)
	move.w 6(a3),($a0*1)(a0)
	move.w 10(a3),($a0*2)(a0)
	move.w 14(a3),($a0*3)(a0)
	move.w 18(a3),($a0*4)(a0)
	move.w 22(a3),($a0*5)(a0)
	move.w 26(a3),($a0*6)(a0)
	move.w 30(a3),($a0*7)(a0)
	move.w 34(a3),($a0*8)(a0)
	move.w 38(a3),($a0*9)(a0)
	move.w 42(a3),($a0*10)(a0)
	move.w 46(a3),($a0*11)(a0)
	move.w 50(a3),($a0*12)(a0)
	move.w 54(a3),($a0*13)(a0)
	move.w 58(a3),($a0*14)(a0)
	move.w 62(a3),($a0*15)(a0)
	moveq #18,d0			;19 chars
sc2	moveq #0,d1
	move.b (a1)+,d1			;get char
	lsl.w #6,d1			;*64
	lea $0(a2,d1.w),a3		;start of char
	movem.l (a3),d1-d7
	move.w d1,8(a0)
	swap d1
	or.w d1,(a0)
	move.w d2,($a0*1+8)(a0)
	swap d2
	or.w d2,($a0*1)(a0)
	move.w d3,($a0*2+8)(a0)
	swap d3
	or.w d3,($a0*2)(a0)
	move.w d4,($a0*3+8)(a0)
	swap d4
	or.w d4,($a0*3)(a0)
	move.w d5,($a0*4+8)(a0)
	swap d5
	or.w d5,($a0*4)(a0)
	move.w d6,($a0*5+8)(a0)
	swap d6
	or.w d6,($a0*5)(a0)
	move.w d7,($a0*6+8)(a0)
	swap d7
	or.w d7,($a0*6)(a0)
	movem.l 28(a3),d1-d7
	move.w d1,($a0*7)+8)(a0)
	swap d1
	or.w d1,($a0*7)(a0)
	move.w d2,($a0*8+8)(a0)
	swap d2
	or.w d2,($a0*8)(a0)
	move.w d3,($a0*9+8)(a0)
	swap d3
	or.w d3,($a0*9)(a0)
	move.w d4,($a0*10+8)(a0)
	swap d4
	or.w d4,($a0*10)(a0)
	move.w d5,($a0*11+8)(a0)
	swap d5
	or.w d5,($a0*11)(a0)
	move.w d6,($a0*12+8)(a0)
	swap d6
	or.w d6,($a0*12)(a0)
	move.w d7,($a0*13+8)(a0)
	swap d7
	or.w d7,($a0*13)(a0)
	movem.l 56(a3),d1-d2
	move.w d1,($a0*14)+8)(a0)
	swap d1
	or.w d1,($a0*14)(a0)
	move.w d2,($a0*15+8)(a0)
	swap d2
	or.w d2,($a0*15)(a0)
	lea $8(a0),a0
	dbf d0,sc2
	moveq #0,d1
	move.b (a1)+,d1			;get last clipped char
	lsl.w #6,d1			;*64
	lea $0(a2,d1.w),a3		;start of char
	movem.l -2(a3),d0-d7
	or.w d0,(a0)
	or.w d1,($a0*1)(a0)
	or.w d2,($a0*2)(a0)
	or.w d3,($a0*3)(a0)
	or.w d4,($a0*4)(a0)
	or.w d5,($a0*5)(a0)
	or.w d6,($a0*6)(a0)
	or.w d7,($a0*7)(a0)
	movem.l 26(a3),d0-d7
	or.w d0,($a0*8)(a0)
	or.w d1,($a0*9)(a0)
	or.w d2,($a0*10)(a0)
	or.w d3,($a0*11)(a0)
	or.w d4,($a0*12)(a0)
	or.w d5,($a0*13)(a0)
	or.w d6,($a0*14)(a0)
	or.w d7,($a0*15)(a0)
	move.l #scroll3,(js1+2)		;do rout 3 next time
	rts

scroll3	move.l messpt,a1		;get scroll pointer
	lea (font+$1e00),a2		;and shifted font address
	moveq #0,d1
	move.b (a1)+,d1			;get first clipped char
	lsl.w #6,d1			;*64
	lea $0(a2,d1.w),a3		;start of char
	move.b 2(a3),(a0)
	move.b 6(a3),($a0*1)(a0)
	move.b 10(a3),($a0*2)(a0)
	move.b 14(a3),($a0*3)(a0)
	move.b 18(a3),($a0*4)(a0)
	move.b 22(a3),($a0*5)(a0)
	move.b 26(a3),($a0*6)(a0)
	move.b 30(a3),($a0*7)(a0)
	move.b 34(a3),($a0*8)(a0)
	move.b 38(a3),($a0*9)(a0)
	move.b 42(a3),($a0*10)(a0)
	move.b 46(a3),($a0*11)(a0)
	move.b 50(a3),($a0*12)(a0)
	move.b 54(a3),($a0*13)(a0)
	move.b 58(a3),($a0*14)(a0)
	move.b 62(a3),($a0*15)(a0)
	moveq #18,d0			;19 chars
sc3	moveq #0,d1
	move.b (a1)+,d1			;get chars
	lsl.w #6,d1			;*64
	lea $0(a2,d1.w),a3		;start of char
	move.b 1(a3),1(a0)
	move.b 2(a3),8(a0)
	move.b 5(a3),($a0*1+1)(a0)
	move.b 6(a3),($a0*1+8)(a0)
	move.b 9(a3),($a0*2+1)(a0)
	move.b 10(a3),($a0*2+8)(a0)
	move.b 13(a3),($a0*3+1)(a0)
	move.b 14(a3),($a0*3+8)(a0)
	move.b 17(a3),($a0*4+1)(a0)
	move.b 18(a3),($a0*4+8)(a0)
	move.b 21(a3),($a0*5+1)(a0)
	move.b 22(a3),($a0*5+8)(a0)
	move.b 25(a3),($a0*6+1)(a0)
	move.b 26(a3),($a0*6+8)(a0)
	move.b 29(a3),($a0*7+1)(a0)
	move.b 30(a3),($a0*7+8)(a0)
	move.b 33(a3),($a0*8+1)(a0)
	move.b 34(a3),($a0*8+8)(a0)
	move.b 37(a3),($a0*9+1)(a0)
	move.b 38(a3),($a0*9+8)(a0)
	move.b 41(a3),($a0*10+1)(a0)
	move.b 42(a3),($a0*10+8)(a0)
	move.b 45(a3),($a0*11+1)(a0)
	move.b 46(a3),($a0*11+8)(a0)
	move.b 49(a3),($a0*12+1)(a0)
	move.b 50(a3),($a0*12+8)(a0)
	move.b 53(a3),($a0*13+1)(a0)
	move.b 54(a3),($a0*13+8)(a0)
	move.b 57(a3),($a0*14+1)(a0)
	move.b 58(a3),($a0*14+8)(a0)
	move.b 61(a3),($a0*15+1)(a0)
	move.b 62(a3),($a0*15+8)(a0)
	lea $8(a0),a0
	dbf d0,sc3
	moveq #0,d1
	move.b (a1)+,d1			;get last clipped char
	lsl.w #6,d1			;*64
	lea $0(a2,d1.w),a3		;start of char
	move.b 1(a3),1(a0)
	move.b 5(a3),($a0*1+1)(a0)
	move.b 9(a3),($a0*2+1)(a0)
	move.b 13(a3),($a0*3+1)(a0)
	move.b 17(a3),($a0*4+1)(a0)
	move.b 21(a3),($a0*5+1)(a0)
	move.b 25(a3),($a0*6+1)(a0)
	move.b 29(a3),($a0*7+1)(a0)
	move.b 33(a3),($a0*8+1)(a0)
	move.b 37(a3),($a0*9+1)(a0)
	move.b 41(a3),($a0*10+1)(a0)
	move.b 45(a3),($a0*11+1)(a0)
	move.b 49(a3),($a0*12+1)(a0)
	move.b 53(a3),($a0*13+1)(a0)
	move.b 57(a3),($a0*14+1)(a0)
	move.b 61(a3),($a0*15+1)(a0)
	move.l #scroll4,(js1+2)		;do rout 4 next time
	rts

scroll4	move.l messpt,a1		;get scroll pointer
	lea (font+$2d00),a2		;and shifted font address
	moveq #0,d1
	move.b (a1)+,d1			;get first clipped char
	lsl.w #6,d1			;*64
	lea $0(a2,d1.w),a3		;start of char
	move.w 2(a3),(a0)
	move.w 6(a3),($a0*1)(a0)
	move.w 10(a3),($a0*2)(a0)
	move.w 14(a3),($a0*3)(a0)
	move.w 18(a3),($a0*4)(a0)
	move.w 22(a3),($a0*5)(a0)
	move.w 26(a3),($a0*6)(a0)
	move.w 30(a3),($a0*7)(a0)
	move.w 34(a3),($a0*8)(a0)
	move.w 38(a3),($a0*9)(a0)
	move.w 42(a3),($a0*10)(a0)
	move.w 46(a3),($a0*11)(a0)
	move.w 50(a3),($a0*12)(a0)
	move.w 54(a3),($a0*13)(a0)
	move.w 58(a3),($a0*14)(a0)
	move.w 62(a3),($a0*15)(a0)
	moveq #18,d0			;19 chars
sc4	moveq #0,d1
	move.b (a1)+,d1			;get char
	lsl.w #6,d1			;*64
	lea $0(a2,d1.w),a3		;start of char
	movem.l (a3),d1-d7
	move.w d1,8(a0)
	swap d1
	or.w d1,(a0)
	move.w d2,($a0*1+8)(a0)
	swap d2
	or.w d2,($a0*1)(a0)
	move.w d3,($a0*2+8)(a0)
	swap d3
	or.w d3,($a0*2)(a0)
	move.w d4,($a0*3+8)(a0)
	swap d4
	or.w d4,($a0*3)(a0)
	move.w d5,($a0*4+8)(a0)
	swap d5
	or.w d5,($a0*4)(a0)
	move.w d6,($a0*5+8)(a0)
	swap d6
	or.w d6,($a0*5)(a0)
	move.w d7,($a0*6+8)(a0)
	swap d7
	or.w d7,($a0*6)(a0)
	movem.l 28(a3),d1-d7
	move.w d1,($a0*7)+8)(a0)
	swap d1
	or.w d1,($a0*7)(a0)
	move.w d2,($a0*8+8)(a0)
	swap d2
	or.w d2,($a0*8)(a0)
	move.w d3,($a0*9+8)(a0)
	swap d3
	or.w d3,($a0*9)(a0)
	move.w d4,($a0*10+8)(a0)
	swap d4
	or.w d4,($a0*10)(a0)
	move.w d5,($a0*11+8)(a0)
	swap d5
	or.w d5,($a0*11)(a0)
	move.w d6,($a0*12+8)(a0)
	swap d6
	or.w d6,($a0*12)(a0)
	move.w d7,($a0*13+8)(a0)
	swap d7
	or.w d7,($a0*13)(a0)
	movem.l 56(a3),d1-d2
	move.w d1,($a0*14)+8)(a0)
	swap d1
	or.w d1,($a0*14)(a0)
	move.w d2,($a0*15+8)(a0)
	swap d2
	or.w d2,($a0*15)(a0)
	lea $8(a0),a0
	dbf d0,sc4
	moveq #0,d1
	move.b (a1)+,d1			;get last clipped char
	lsl.w #6,d1			;*64
	lea $0(a2,d1.w),a3		;start of char
	movem.l -2(a3),d0-d7
	or.w d0,(a0)
	or.w d1,($a0*1)(a0)
	or.w d2,($a0*2)(a0)
	or.w d3,($a0*3)(a0)
	or.w d4,($a0*4)(a0)
	or.w d5,($a0*5)(a0)
	or.w d6,($a0*6)(a0)
	or.w d7,($a0*7)(a0)
	movem.l 26(a3),d0-d7
	or.w d0,($a0*8)(a0)
	or.w d1,($a0*9)(a0)
	or.w d2,($a0*10)(a0)
	or.w d3,($a0*11)(a0)
	or.w d4,($a0*12)(a0)
	or.w d5,($a0*13)(a0)
	or.w d6,($a0*14)(a0)
	or.w d7,($a0*15)(a0)
	move.l #scroll1,(js1+2)		;do rout 1 next time
	move.l messpt,a0		;get scroll pointer
	cmp.b #$ff,21(a0)		;end of scroller ?
	bne.s notes
	lea (text-1),a0			;reset to start
notes	addq.l #1,a0
	move.l a0,messpt		;update scroll pointer
	rts

psf	lea font,a1			;first font image
	move.l a1,a2
	add.l #$f00,a2			;second font image
	move.l a2,a3
	add.l #$f00,a3			;third font image
	move.l a3,a4
	add.l #$f00,a4			;fourth font image
	clr.w (a1)+			;spaces
	clr.w (a2)+			;for
	clr.w (a3)+			;left
	clr.w (a4)+			;shifts
	lea fonttab,a6			;font in screen format
	moveq #59,d0			;60 chars
ps1	moveq #59,d1			;but start from 0
	sub.w d0,d1
	lsl.w #2,d1			;*4
	move.l $0(a6,d1.w),a0		;get char address
	moveq #15,d2			;16 lines in char
ps2	move.w (a0),(a1)+
	clr.w (a1)+
	move.w (a0),(a2)+
	clr.w (a2)+
	move.w (a0),(a3)+
	clr.w (a3)+
	move.w (a0),(a4)+
	clr.w (a4)+
	lea $a0(a0),a0
	dbf d2,ps2
	dbf d0,ps1
	lea (font+$f00),a0		;first pre-shift font
	move.w #3,d0			;by 4 pixels
	bsr psl				;pre-shift left d0 pixels at a0
	lea (font+$1e00),a0		;second pre-shift font
	move.w #7,d0			;by 8 pixels
	bsr psl				;pre-shift left d0 pixels at a0
	lea (font+$2d00),a0		;third pre-shift font
	move.w #11,d0			;by 12 pixels
	bsr psl				;pre-shift left d0 pixels at a0
	rts

psl	move.l a0,a1
	add.l #$efe,a1			;end of font
	move.w #$77f,d1			;length in words
psl1	roxl (a1)			;shift 1 pixel left
	subq.l #2,a1			;go backwards through font
	dbf d1,psl1
	dbf d0,psl
	rts

pcs	lea text,a0			;start of scroll text
pcs1	sub.b #' ',(a0)+		;pre-calc
	cmp.b #$ff,(a0)			;until end
	bne pcs1
	move.l #text,messpt		;set-up scroll pointer
	lea fonttab,a0			;add font start address
af	add.l #fontdat,(a0)+		;to font table
	cmp.l #text,a0
	blt af
	move.l #$50006,oldadd		;init old buffer		*
	rts

makescr	lea (pic1+34),a0		;start of first pic
	lea $50000,a1							*
ms1	move.l (a0)+,(a1)+
	cmp.l #$57d00,a1						*
	blt ms1
	lea (pic2+34),a0		;start of second pic
	lea $57d00,a1							*
ms2	move.l (a0)+,(a1)+
	cmp.l #$5fa00,a1						*
	blt ms2
	lea (pic3+34),a0		;start of third pic
	lea $5fa00,a1							*
ms3	move.l (a0)+,(a1)+
	cmp.l #$67700,a1						*
	blt ms3
	lea $50280,a0			;4 pixels into screen
	lea $68000,a1
ms4	move.l (a0)+,(a1)+
	cmp.l #$67700,a0		;until end of screens
	blt ms4
	rts

makedat	lea $31c00,a0							*
	lea $30900,a1							*
	move.l #$60000002,(a1)+		;branch for vertical offset
	move.w #$4eb9,d0		;$4eb9 = JSR
	moveq #27,d2			;first 28 lines
m2	moveq #7,d1			;of 8 pixels lines each
m1	move.w d0,(a1)+			;JSR
	move.l a0,(a1)+			;address
	move.l #$2e182287,(a1)+		; = move.l (a0)+,d7/move.l d7,(a1)
	move.l #$24872687,(a1)+		; = move.l d7,(a2)/move.l d7,(a3)
	move.l #$28874e71,(a1)+		; = move.l d7,(a4)/nop
	dbf d1,m1
	add.l #$f06,a0			;6*320 long
	dbf d2,m2
	move.l a1,a5
	lea nobot,a6			;patch no bottom border code
ma0	move.w (a6)+,(a1)+
	cmp.l #go,a6			;until end
	blt ma0
	moveq #7,d7			;8 pixels lines to patch
sna	addq.l #2,a5
	tst.l (a5)			;find JSR $0
	bne sna
	move.l a0,(a5)			;and patch to pixel line address
	dbf d7,sna
	add.l #$f06,a0			;6*320 long
	moveq #2,d2			;do last 3 lines (28+1+3=32)
ma2	moveq #7,d1			;of 8 pixel lines
ma1	move.w d0,(a1)+			;JSR
	move.l a0,(a1)+			;address
	move.l #$2e182287,(a1)+		; = move.l (a0)+,d7/move.l d7,(a1)
	move.l #$24872687,(a1)+		; = move.l d7,(a2)/move.l d7,(a3)
	move.l #$28874e71,(a1)+		; = move.l d7,(a4)/nop
	dbf d1,ma1
	add.l #$f06,a0			;6*320 long
	dbf d2,ma2
	move.w #$4e75,(a1)+		;$4e75 = RTS

	lea $31c00,a0							*
	lea (picture+34),a1		;start of text picture
	move.w #31,d2			;32 lines per char
m4	move.l #$60000002,(a0)+		;horizontal offset
	moveq #5,d7			;6 rows
m9	moveq #19,d1			;of 20 chars
m3	move.l (a1)+,d4			;get four bitplanes
	move.l (a1)+,d5			;into d4/d5
	moveq #15,d3			;16 pixels per word plane
m5	rol.l #1,d4			;get most significant bit
	rol.l #1,d5			;by shifting left
	moveq #0,d0
	move.w d4,d6
	and.l #1,d6			;is bit set ?
	add.b d6,d0			;add 0 or 1
	swap d4				;get next plane
	move.w d4,d6
	and.l #1,d6			;is bit set ?
	lsl.b #1,d6			;shift for priority
	add.b d6,d0			;add 0 or 2
	swap d4				;return to old plane
	move.w d5,d6
	and.l #1,d6			;is bit set ?
	lsl.b #2,d6			;shift for priority
	add.b d6,d0			;add 0 or 4
	swap d5				;get next plane
	move.w d5,d6
	and.l #1,d6			;is bit set ?
	lsl.b #3,d6			;shift for priority
	add.b d6,d0			;add 0 or 8
	swap d5				;return to old plane
	or.w #$3c80,d0			;$3c80 = MOVE.W Dn,(A6)
	move.w d0,(a0)+			;put into list
	dbf d3,m5
	dbf d1,m3
	lea $1360(a1),a1
	dbf d7,m9
	lea -$7760(a1),a1
	move.w #$4e75,(a0)+		;end with RTS
	dbf d2,m4
	lea $31c68,a0							*
	lea oldx,a1			;save horizontal end words
	moveq #31,d0
m6	move.w (a0),(a1)+
	move.w #$4e75,(a0)		;and replace with RTS
	add.l #$f06,a0			;next horizontal line
	dbf d0,m6
	move.l #$31c68,retx						*
	rts

full	move.w sr,-(sp)			;save sr
	move.w #$2700,sr		;disable ints
	move.b $ffff820a.w,oldhz
	move.b $fffffa07.w,old07	;save interrupt enable a
	move.b $fffffa09.w,old09	;save interrupt enable b
	move.b $fffffa13.w,old13	;save interrupt mask a
	move.l $118.w,old118		;save key int
	move.l $120.w,old120		;save old hbl
	move.l $68.w,old68		;save old hbl
	move.b #1,$fffffa07.w		;enable timer b
	move.b #1,$fffffa13.w		;mask all other ints
	clr.b $fffffa09.w		;disable all b ints
	move.l #ret,$118.w		;disable key int
	move.l $70.w,old70		;save old vbl vector
	move.l #fullvbl,$70.w		;install my vbl handler
	move.l #ret,$120.w		;install my hbl
	move.l #full68,$68.w		;install my hbl
	stop #$2300

main	clr.w go
cc	tst.w go
	beq.s cc
	move.b $fffffc02.w,d0		;check keyboard
	cmp.b #$39,d0			;space pressed
	beq exit
	cmp.b #$1c,d0
	beq exit1

	move.l oldadd,a0		;get last plotted scroller
	moveq #15,d0			;16 lines high
	moveq #0,d1			;clear old scroller
qp	move.w d1,(a0)
	move.w d1,$08(a0)
	move.w d1,$10(a0)
	move.w d1,$18(a0)
	move.w d1,$20(a0)
	move.w d1,$28(a0)
	move.w d1,$30(a0)
	move.w d1,$38(a0)
	move.w d1,$40(a0)
	move.w d1,$48(a0)
	move.w d1,$50(a0)
	move.w d1,$58(a0)
	move.w d1,$60(a0)
	move.w d1,$68(a0)
	move.w d1,$70(a0)
	move.w d1,$78(a0)
	move.w d1,$80(a0)
	move.w d1,$88(a0)
	move.w d1,$90(a0)
	move.w d1,$98(a0)
	lea $a0(a0),a0
	dbf d0,qp

	move.l texscr,a0		;get current screen
cso	add.l #$146,a0			;correct for required bitplane
css	add.l #$a0,(cso+2)		;one line lower (or higher)
csc	cmp.l #$9886,(cso+2)		;hit bottom (or top) of screen ?
	bne scok
	eor.w #$200,css			;toggle ADD/SUB (Self Modify !)
	eor.l #$99c0,(csc+2)		;toggle top/bottom (Self Modify !)
scok	move.l a0,oldadd		;save address for next clear
js1	jsr scroll1			;do scroller

bigs	cmp.w #$e9e,$31c02						*
	bne nors
	lea $31c68,a0							*
	lea oldx,a1			;restore old horizontal end words
	move.l retx,a2			;to current horizontal position
	moveq #31,d0			;32 lines
rs	move.w #$2,-$66(a0)		;scroller wrapped, so restart
	move.w (a1),(a2)
	move.w (a0),(a1)+
	move.w #$4e75,(a0)		;end with RTS
	lea $f06(a0),a0
	lea $f06(a2),a2
	dbf d0,rs
	move.l #$31c68,retx						*
	bra main

nors	moveq #31,d0			;32 horizontal lines to update
	move.l retx,a0			;get current horizontal position
	addq.l #2,retx			;and update (scroll)
	lea oldx,a1
	lea $31c02,a2							*
nl1	addq.w #2,(a2)			;increase initial branch offset
	move.w (a1),(a0)
	move.w 2(a0),(a1)+
	move.w #$4e75,2(a0)		;end with RTS
	lea $f06(a0),a0
	lea $f06(a2),a2
	dbf d0,nl1
	bra main			;and round again !!


exit1	move.b #0,oldhz
exit	move.w #$2700,sr		;disable ints
	clr.b $fffffc02.w		;clear keypress
	move.l old118,$118.w		;restore key int
	move.l old68,$68.w		;restore old hbl
	move.l old120,$120.w		;restore old hbl
	move.l old70,$70.w		;restore old vbl
	move.b old13,$fffffa13.w	;restore old mask
	move.b old07,$fffffa07.w	;restore old int enable a
	move.b old09,$fffffa09.w	;restore old int enable b
	move.b oldhz,$ffff820a.w
	stop #$2300			;wait with sr=$2300
	rte


fullvbl	move.w #33,count		;33 scan lines
	and.w #$f1ff,(sp)
ret	rte

full68	subq.w #1,count			;33 lines counted?
	bpl.s ret			;no
	move.w #$2700,sr		;disable ints
	movem.l d0-a6,-(sp)		;save all regs
	move.b (screen+1),$ffff8201.w	;new screen high byte
	move.b (screen+2),$ffff8203.w	;new screen low byte
	lea $ffff8209,a0		;screen low byte
	lea $ffff8260,a1		;rez
	clr.w $ffff8240.w		;black above scroller
	moveq #5,d0
pp1	nop
	dbf d0,pp1
	clr.b $ffff820a.w		;60 hz
	moveq #3,d0
pp2	nop
	dbf d0,pp2
	move.b #2,$ffff820a.w		;50 hz
	moveq #$10,d2			;compensate
wait1	move.b (a0),d3			;8 cycles
	beq.s wait1			;10 cycles
					;(or 8 cycles if not equal)

	sub.b d3,d2			;adjust for screeen low byte
	lsl.b d2,d2			;(d2*2)+6 cycles

	rept 67				;268 cycles
	nop				;70*4
	endr				;
 	lea $ffff8240.w,a6
	movem.w (picture+2),d0-d6	;get pallete for big scroller
	lea coltab,a0			;12 cycles
	lea $10(a6),a1			;8 cycles
	lea 4(a1),a2			;8 cycles
	lea 4(a2),a3			;8 cycles
	lea 4(a3),a4			;8 cycles

	jsr $30900							*

ptok	clr.w $ffff8240.w		;black below scroller
	move.l musoff,a0		;get music address
	move.b #0,$ffff8800.w		;fast music player !!
	move.b (a0)+,$ffff8802.w
	move.b #2,$ffff8800.w
	move.b (a0)+,$ffff8802.w
	move.b #4,$ffff8800.w
	move.b (a0)+,$ffff8802.w
	move.b #6,$ffff8800.w
	move.b (a0)+,$ffff8802.w
	move.b #7,$ffff8800.w
	move.b (a0)+,$ffff8802.w
	move.b (a0)+,d0
	move.b d0,d1
	and.w #$f,d0
	and.w #$f0,d1
	ror.w #4,d1
	move.b #1,$ffff8800.w
	move.b d0,$ffff8802.w
	move.b #3,$ffff8800.w
	move.b d1,$ffff8802.w
	move.b (a0)+,d0
	move.b d0,d1
	and.w #$f,d0
	and.w #$f0,d1
	ror.w #4,d1
	move.b #5,$ffff8800.w
	move.b d0,$ffff8802.w
	move.b #8,$ffff8800.w
	move.b d1,$ffff8802.w
	move.b (a0)+,d0
	move.b d0,d1
	and.w #$f,d0
	and.w #$f0,d1
	ror.w #4,d1
	move.b #9,$ffff8800.w
	move.b d0,$ffff8802.w
	move.b #10,$ffff8800.w
	move.b d1,$ffff8802.w
	cmp.l #picture,a0		;end of music
	blt nom
	lea music,a0			;restart music
nom	move.l a0,musoff		;current music address

	move.l screen,texscr		;save screen for scroller address
eo1	add.l #$18000,screen						*
	eor.w #$200,eo1			;toggle SUB/ADD (Self Modify !)
	cmp.w #$04b9,eo1		;do 4 pixel vertical scroll
	beq noca
cl	add.l #$500,screen		;8 pixel vertical scroll
cl1	cmp.l #$5d200,screen						*
	bne noca
	eor.l #$fb00,(eo1+2)		;go backwards
	neg.l (cl+2)			;toggle +/-
	eor.l #$d200,(cl1+2)						*
noca	movem.l (sp)+,d0-a6		;restore all regs
	move.w #1,go			;ok, main code now
	or.w #$300,(sp)			;enable ints
	rte

nobot	rept 3				;extended for bottom border kill !!
	jsr 0
	move.l (a0)+,d7
	move.l d7,(a1)
	move.l d7,(a2)
	move.l d7,(a3)
	move.l d7,(a4)
	nop
	endr
	jsr 0
	move.b #0,$ffff820a.w		;16 cycles
	move.l d0,-(sp)			;14 cycles
	clr.l d0			;6 cycles
	move.l (sp)+,d0			;12 cycles
	move.b #2,$ffff820a.w		;16 cycles
	rept 4
	jsr 0
	move.l (a0)+,d7
	move.l d7,(a1)
	move.l d7,(a2)
	move.l d7,(a3)
	move.l d7,(a4)
	nop
	endr

go		dc.w 0
texscr		dc.l 0
oldadd		dc.l 0
messpt		dc.l 0
oldret		dc.w 0
count		dc.w 0
screen		dc.l $00050000						*
oldpal		dc.l 0,0,0,0,0,0,0,0
newpal		dc.l 0,0,0,0,0,0,0,0
black		dc.l 0,0,0,0,0,0,0,0,0,0
musoff		dc.l 0
old07		dc.w 0
old09		dc.w 0
old13		dc.w 0
old68		dc.l 0
old70		dc.l 0
old118		dc.l 0
old120		dc.l 0
oldbase		dc.l 0
oldrez		dc.w 0
olds		dc.l 0	
oldhz		dc.w 0
retx		dc.l 0
oldx		ds.l 16
fonttab		dc.l $0000,$0008,$0010,$0018,$0020,$0028,$0030,$0038,$0040,$0048
		dc.l $0050,$0058,$0060,$0068,$0070,$0078,$0080,$0088,$0090,$0098
		dc.l $0a00,$0a08,$0a10,$0a18,$0a20,$0a28,$0a30,$0a38,$0a40,$0a48
		dc.l $0a50,$0a58,$0a60,$0a68,$0a70,$0a78,$0a80,$0a88,$0a90,$0a98
		dc.l $1400,$1408,$1410,$1418,$1420,$1428,$1430,$1438,$1440,$1448
		dc.l $1450,$1458,$1460,$1468,$1470,$1478,$1480,$1488,$1490,$1498
text		dc.b "                                                                                                  "
		dc.b " TUESDAY 8TH MARCH 1994, 1930 HOURS......   YOUR OLD FRIENDS ARE BACK ONCE AGAIN.....   THIS TIME WE CAN ONLY OFFER YOU THIS SHAREWARE ADVENTURE, BUT AS I'M SURE YOU WILL AGREE IT IS BETTER THAN NOTHING"
		DC.B " AND OF COURSE THE PASSWORD PROTECTION"
		DC.B " WAS JUST CRYING OUT TO BE HACKED.......            I'VE PUT THE SAVE GAME FILE THAT I USED TO TEST THE CRACK ON DISK 2 SO YOU CAN JUST LOAD THAT AND PROGRESS IMMEDIATELY TO THE FUNLAND IF YOU GET STUCK!               "
		DC.B "    THIS WAS A PRETTY WEIRD PROTECTION TO REMOVE, NOT BECAUSE IT WAS WELL PROTECTED (IT WAS PACKED THREE TIMES), BUT SIMPLY BECAUSE IT WAS WRITTEN WITH THE STOS COMPILER...... AS YOU CAN NO DOUBT IMAGINE"
		DC.B " THIS DOES NOT EXACTLY PRODUCE DECENT, READABLE, STREAMLINED ASSEMBLER. IN FACT IT PRODUCES SOME OF THE MOST SHITTY CODE I'VE SEEN IN A LONG WHILE.             "
		DC.B "        IT'S BEEN MONTHS SINCE OUR LAST RELEASE BUT REST ASSURED THAT SO LONG AS THE OCCASIONAL NEW TITLE COMES OUT WE WILL CONTINUE TO CRACK THEM....."
		DC.B "    IT HARDLY SEEMS WORTH SELLING MY ST NOW AS I PAID A FORTUNE FOR IT BACK IN 1987 (ANYONE REMEMBER THE OLD SUMMER PACK AND SUPER PACK!),"
		DC.B " AND IT'S WORTH BUGGER ALL NOW ANYWAY, SO YOU CAN LOOK FORWARD TO SOME MORE CRACKS FROM US AS SOON AS ANYTHING ELSE IS RELEASED!       "
		DC.B "     THAT'S ABOUT ALL FOR NOW, JUST TIME FOR A QUICK MESSAGE TO ANYONE WHO MAY OF WRITTEN TO THE PO BOX OVER THE LAST MONTHS.........       "
		DC.B "    I HAVE ONLY RECENTLY RECEIVED ANY OF THE MAIL THAT WAS EVER SENT TO THE PO BOX AS THE GUY WHO COLLECTS IT (AND SKYWALKER) WERE NOT EXACTLY CONSCIENTIOUS WHEN IT CAME TO SENDING IT ON TO ME!    "
		DC.B "       ANY OF THE LETTERS ASKING FOR SOFTWARE OR CONTAINING MONEY OR DISKS WERE NOT PASSED ON TO ME, SO PLEASE DON'T BLAME US IF THEY HAVE NOT BEEN ANSWERED OR RETURNED!!!            "
		DC.B "       THERE WERE WELL OVER 100 LETTERS SOME OVER 1 YEAR OLD AND I HAVE READ THROUGH THEM ALL OVER THE LAST FEW WEEKS.          WE ARE CURRENTLY COMPILING A LIST OF EVERYONE WHO WROTE AND IF ANY DECENT NEW TITLE"
		DC.B " EVER COMES OUT THEN WE'LL RELEASE IT WITH A NEW INTRO AND A THANK YOU LIST TO EVERYONE WHO SUPPORTED US BY WRITING...........         SO DON'T BIN YOUR OLD ST FOR THE MOMENT.....          "
		DC.B "      ONE LAST THING ABOUT THE LETTERS......    THEY WERE SENT IN FROM SUCH EXOTIC LOCATIONS AS POLAND, SLOVENIA, CZECHOSLOVAKIA, ICELAND, SWEDEN, FINLAND, GREECE, GERMANY, HOLLAND, FRANCE, SPAIN, AUSTRALIA, NEW ZEALAND AND"
		DC.B " OF COURSE SCOTLAND, ENGLAND AND WALES (NONE FROM NORTHERN IRELAND AND JUST ONE FROM THE REPUBLIC!), BUT THE INTERESTING THING WAS THAT NOT ONE FEMALE TOOK THE TIME TO WRITE.....  MAYBE THE ONLY PEOPLE TO STILL HAVE AN INTEREST"
		DC.B " IN THE ST SCENE ARE SOME OF THE DIE HARD GUYS FROM THE OLD DAYS......         "
		DC.B "            THAT'S ALL FOR NOW, TIME TO WRAP IT UP.     "
		DC.B "                                                      "
		dc.b $ff
		even
coltab		dc.l $00030003,$00030003,$00040004,$00040004
		dc.l $00050005,$00050005,$00060006,$00060006
		dc.l $00070007,$00070007,$00370037,$00370037
		dc.l $00470047,$00470047,$00570057,$00570057
		dc.l $00670067,$00670067,$00770077,$00770077
		dc.l $03770377,$03770377,$04770477,$04770477
		dc.l $05770577,$05770577,$06770677,$06770677
		dc.l $07770777,$07770777,$07760776,$07760776
		dc.l $07750775,$07750775,$07740774,$07740774
		dc.l $07730773,$07730773,$07700770,$07700770
		dc.l $07600760,$07600760,$07500750,$07500750
		dc.l $07400740,$07400740,$07300730,$07300730
		dc.l $07000700,$07000700,$07030703,$07030703
		dc.l $07040704,$07040704,$07050705,$07050705
		dc.l $07060706,$07060706,$07070707,$07070707
		dc.l $07370737,$07370737,$07470747,$07470747
		dc.l $07570757,$07570757,$07670767,$07670767
		dc.l $07770777,$07770777,$06770677,$06770677
		dc.l $05770577,$05770577,$04770477,$04770477
		dc.l $03770377,$03770377,$00770077,$00770077
		dc.l $00760076,$00760076,$00750075,$00750075
		dc.l $00740074,$00740074,$00730073,$00730073
		dc.l $00700070,$00700070,$03700370,$03700370
		dc.l $04700470,$04700470,$05700570,$05700570
		dc.l $06700670,$06700670,$07700770,$07700770
		dc.l $07600760,$07600760,$07500750,$07500750
		dc.l $07400740,$07400740,$07300730,$07300730
		dc.l $07000700,$07000700,$07030703,$07030703
		dc.l $07040704,$07040704,$07050705,$07050705
		dc.l $07060706,$07060706,$07070707,$07070707
		dc.l $06070607,$06070607,$05070507,$05070507
		dc.l $04070407,$04070407,$03070307,$03070307
		dc.l $00070007,$00070007,$00370037,$00370037
		dc.l $00470047,$00470047,$00570057,$00570057
		dc.l $00670067,$00670067,$00770077,$00770077
		dc.l $03770377,$03770377,$04770477,$04770477
		dc.l $05770577,$05770577,$06770677,$06770677
		dc.l $07770777,$07770777,$07760776,$07760776
		dc.l $07750775,$07750775,$07740774,$07740774
		dc.l $07730773,$07730773,$07700770,$07700770
		dc.l $07600760,$07600760,$07500750,$07500750
		dc.l $07400740,$07400740,$07300730,$07300730
		dc.l $07000700,$07000700,$07030703,$07030703
		dc.l $07040704,$07040704,$07050705,$07050705
		dc.l $07060706,$07060706,$07070707,$07070707
		dc.l $07370737,$07370737,$07470747,$07470747
		dc.l $07570757,$07570757,$07670767,$07670767
		dc.l $07770777,$07770777,$06770677,$06770677
		dc.l $05770577,$05770577,$04770477,$04770477
		dc.l $03770377,$03770377,$00770077,$00770077
		dc.l $00760076,$00760076,$00750075,$00750075
		dc.l $00740074,$00740074,$00730073,$00730073
		dc.l $00700070,$00700070,$03700370,$03700370
		dc.l $04700470,$04700470,$05700570,$05700570
		dc.l $06700670,$06700670,$07700770,$07700770
		dc.l $07600760,$07600760,$07500750,$07500750
		dc.l $07400740,$07400740,$07300730,$07300730
		dc.l $07000700,$07000700,$07030703,$07030703
		dc.l $07040704,$07040704,$07050705,$07050705
		dc.l $07060706,$07060706,$07070707,$07070707
		dc.l $07370737,$07370737,$07470747,$07470747
		dc.l $07570575,$07570757,$07670767,$07670767
		dc.l $07770777,$07770777,$07760776,$07760776
		dc.l $07750775,$07750775,$07740774,$07740774

music		incbin 'bmx_mus.fst'
picture		incbin 'cyn_mess.pi1'
fontdat		incbin '1_plane.fnt'
font		ds.l 3850
pic1		incbin 'cynix1.pi1'
pic2		incbin 'cynix2.pi1'
pic3		incbin 'cynix3.pi1'
logo		incbin 'cyn_logo.bin'
text1		dc.b '   CODING BY ABSU   '
		dc.b ' GRAPHICS BY WIZPOP '
		dc.b '  MUSIC BY MAD MAX  '
font_tab	dc.l font1+0+32,font1+8+32,font1+16+32,font1+24+32,font1+32+32,font1+40+32
		dc.l font1+48+32,font1+56+32,font1+64+32,font1+72+32,font1+80+32,font1+88+32
		dc.l font1+96+32,font1+104+32,font1+112+32,font1+120+32,font1+128+32
		dc.l font1+136+32,font1+144+32,font1+152+32
		dc.l font1+2720+32,font1+2728+32,font1+2736+32,font1+2744+32
		dc.l font1+2752+32,font1+2760+32
font1		incbin 'font'
