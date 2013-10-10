*
* BORIS,
*       This is MY fixed version of the C you sent. I noticed that there
* was a PLOT missing so after consulting my book and a Pascal source I
* inserted one.
*
* This routine draws a line (not optimised). The test is to draw a line
* from the centre to the edges of the screen (it works!!!)
*
*
* MSD  30-4-95 @ 9:55 PM
*


yes=1
no=0

DOWNLOAD=yes


		ifne	DOWNLOAD
		include	transmit.s		;include Transmit code
		org	$30000		;origin to start of code in memory
Code_Start
Exec_Addr
mycode
		endc


		bsr	set_up



	clr.l	$462
		move.w	#100,y1	;middle
		move.w	#160,x1	;of screen
		move.w	#0,d4	;x2
		move.w	#0,d5	;y2

;draw top left to top right
		move.w	#320-1,d0
tl2tr		movem.w	d0/d4/d5,-(sp)
		move.w	d4,x2
		move.w	d5,y2
		bsr	 do_letter
		movem.w	(sp)+,d0/d4/d5
		add.w	#1,d4
		dbf	d0,tl2tr



;draw top right to bottom right
		move.w	#100,y1	;middle
		move.w	#160,x1	;of screen
		move.w	#320,d4	;x2
		move.w	#0,d5	;y2

		move.w	#200-1,d0
tr2br		movem.w	d0/d4/d5,-(sp)
		move.w	d4,x2
		move.w	d5,y2
		bsr	 do_letter
		movem.w	(sp)+,d0/d4/d5
		add.w	#1,d5
		dbf	d0,tr2br



;draw bottom right to bottom left
		move.w	#100,y1	;middle
		move.w	#160,x1	;of screen
		move.w	#320,d4	;x2
		move.w	#200,d5	;y2

		move.w	#320-1,d0
br2bl		movem.w	d0/d4/d5,-(sp)
		move.w	d4,x2
		move.w	d5,y2
		bsr	 do_letter
		movem.w	(sp)+,d0/d4/d5
		sub.w	#1,d4
		dbf	d0,br2bl





;draw bottom left to top left
		move.w	#100,y1	;middle
		move.w	#160,x1	;of screen
		move.w	#0,d4	;x2
		move.w	#200,d5	;y2

		move.w	#200-1,d0
bl2tl		movem.w	d0/d4/d5,-(sp)
		move.w	d4,x2
		move.w	d5,y2
		bsr	do_letter
		movem.w	(sp)+,d0/d4/d5
		sub.w	#1,d5
		dbf	d0,bl2tl

	move.l	$462.w,$200.w
		move.w	pic+2,$ffff8240.w

	move.l	$200.w,d0		;print how long routine takes
	bsr	printn
		

wait		bsr	tst_key
		tst.l	d0
		beq.s	wait		main_loop

		bsr	set_old_palette

		move.w	org_rez,$ffff8260.w

	move.b	#$8,$fffffc02.w

		ifeq	DOWNLOAD
	bsr	set_user
		else
		move.l	4.w,a0
		jmp	(a0)
		endc

	clr.w	-(sp)
	trap	#1


printn		move.l	scr_now,a0
		move.l	d0,d3
offset		set	0
		rept	24
		clr.l	offset(a0)
		clr.l	offset+4(a0)
		clr.l	offset+8(a0)
		clr.l	offset+12(a0)
offset		set	offset+160
		endr

		add.w	#160*8,a0
		lea	number4+1(pc),a4
		move.l	d3,d2
		rept	2
		move.b	d2,d1
		and.b	#$f,d1
		move.b	d1,-(a4)
		move.b	d2,d1
		lsr.w	#4,d1
		move.b	d1,-(a4)
		lsr.l	#8,d2
		endr
						;cycles
		lea	number1(pc),a4		; 8
		move.w	#2-1,d0			; 8
.digits		move.b	(a4)+,d4		; 8
		and.w	#$f,d4			;12
		cmp.b	#$a,d4			; 8
		blt.s	.ok			;12
		add.w	#7,d4			; 8
.ok		add.w	#16,d4			; 8
		mulu	#5,d4			;40?
		lea	font(pc),a2		; 8
		lea	(a2,d4.w),a2		;16
		move.b	(a2)+,(a0)		;16
		move.b	(a2)+,160(a0)		;16
		move.b	(a2)+,320(a0)		;16
		move.b	(a2)+,480(a0)		;16
		move.b	(a2)+,640(a0)		;16
		move.b	(a4)+,d4		; 8
		and.w	#$f,d4			;12
		cmp.b	#$a,d4			; 8
		blt.s	.ok2			;12
		add.w	#7,d4			; 8
.ok2		add.w	#16,d4			; 8
		mulu	#5,d4			;40?
		lea	font(pc),a2		; 8
		lea	(a2,d4.w),a2		;16
		move.b	(a2)+,1(a0)		;16
		move.b	(a2)+,161(a0)		;16
		move.b	(a2)+,321(a0)		;16
		move.b	(a2)+,481(a0)		;16
		move.b	(a2)+,641(a0)		;16
		add.w	#8,a0			;16
		dbf	d0,.digits		;16+12n
		rts
number1		dc.b	0
number2		dc.b	0
number3		dc.b	0
number4		dc.b	0











***************************************************************
* based on the following C source
*
* a classic Bresenham line drawer
*
* #define ABS(x) (x>0?x:-x)		//get positive value of number
* #define SGN(x) (x>0?1:(x==0?0:-1))	//get sign of number (-1,0,1)
*
* /*draw line from (x1,y1) to (x2,y2) */
*
* DDA2 (short x1,short y1,short x2,short y2)
* (
*   short d,x,y,ax,ay,sx,sy,dx,dy;
*
*   d = x2-x1; ax=ABS(d)*2; sx=SGN(d);
*   d = y2-y1; ay=ABS(d)*2; sy=SGN(d);
*
*   x = x1; y = y1;
*   if (ax>ay)
*   {
*     d = ay-(ax/2);
*     plot (x,y);
*     while (x != x2)	//while x does not equal x2
*     {
*       plot (x,y);
*       if (d >= 0)
*       {
*         y += sy;
*         d -= ax;
*       }
*       x += sx;
*       d += ay;
*     }
*   }
* else
*   {
*     d = ax-(ay/2);
*     plot (x,y);
*     while (y != y2)	//while y does not equal y2
*     {
*       if (d >= 0)
*       {
*         x += sx;
*         d -= ay;
*       }
*
**** plot x,y   (MSD's FIX)
*
*
*     y += sy;
*     d += ax;
*     }
*   }
* }
***************************************************************



; Converted from 'C' source... (and I don't even know 'C' !)

do_letter
	moveq	#0,d0
	moveq	#0,d1

**** Calc X values ************
;d=x2-x1
	move.w	x2,d0
	move.w	x1,d1
	sub.w	d1,d0
	bpl.s	xplus		;check the result is ABS
;no so make ABS
	neg.w	d0


;sx=SGN(d)
	move.w	#-1,sx
	bra.s	xoverplus
xplus	move.w	#1,sx
xoverplus


;ax=ABS(d)*2
	lsl.w	#1,d0	;ax=ABS(d)*2
	move.w	d0,ax

**************************************************

**** Calc Y values ************
;d=y2-y1
	move.w	y2,d0
	move.w	y1,d1
	sub.w	d1,d0
	bpl.s	yplus		;check the result is ABS

;no so make ABS
	neg.w	d0

;sy=SGN(d)
	move.w	#-1,sy
	bra.s	yoverplus
yplus	move.w	#1,sy
yoverplus

;ay=ABS(d)*2
	lsl.w	#1,d0
	move.w	d0,ay
*******************************************


; x=x1
	move.w	x1,x


; y=y1
	move.w	y1,y



;if (ax>ay)
	move.w	ax,d0
	cmp.w	ay,d0
	bgt.s	axbigger






;else if (ax<ay) then do this
;

*d = ax-(ay/2)
	move.w	ay,d0	;let d0=ay/2
	lsr.w	#1,d0	;d0 now equ ay/2

	move.w	ax,d1
	sub.w	d0,d1
;d1 now equ (ax-(ay/2)
	move.w	d1,d7


*plot x,y
	move.w	x,d0
	move.w	y,d1
	bsr	plot


*while (y != y2)	while y<>y2
.loop
	move.w	y,d0
	cmp.w	y2,d0
	beq	.quit

*if d(>=0)
	tst.w	d7
	bmi.s	.over

*x += sx
	move.w	sx,d0
	add.w	d0,x

*d -= ay
	move.w	ay,d0
	sub.w	d0,d7

.over

************ MSD fix here!! ******* (After looking at a Pascal source!
		move.w	x,d0
		move.w	y,d1
		bsr	plot




*y += sy
	move.w	sy,d0
	add.w	d0,y


*d += ax
	add.w	ax,d7

	bra.s	.loop

.quit	rts












;if (ax>ay) then do axbigger
axbigger
;d=(ay-(ax/2)
	move.w	ax,d0	;let d0=ax/2
	lsr.w	#1,d0	;d0 now equ ax/2

	move.w	ay,d1
	sub.w	d0,d1
;d1 now equ (ay-(ax/2)
	move.w	d1,d7


*plot x,y
	move.w	x,d0
	move.w	y,d1
	bsr	plot


*while (x != x2)	while x<>x2
.loop
	move.w	x,d0
	cmp.w	x2,d0
	beq.s	.quit

	move.w	x,d0
	move.w	y,d1
	bsr	plot


;if (d>=0)
	tst.w	d7
	bmi.s	.over


*y += sy
	move.w	sy,d0
	add.w	d0,y

*d -= ax
	sub.w	ax,d7

.over
*x += sx
	move.w	sx,d0
	add.w	d0,x


*d += ay
	add.w	ay,d7

	bra.s	.loop
.quit	rts















* Plot
*
* On entry  d0=x
*           d1=y
*
plot
	move.l	scr_now,a6

;multiply y axis offset by line width (*160)
	lsl.w	#5,d1		*32
	move.w	d1,d2
	lsl.w	#2,d1		*128
	add.w	d2,d1		=160

	move.w	d0,d2
;divide x offset by 16 for word values then *8 for low rez
	lsr.w	#1,d0
	and.w	#$1f8,d0
	add.w	d1,d0		;add y offset to word offset
	add.w	d0,a6		;add word + y offset to screen start


	and.w	#$f,d2			;get pixel offset

	lsl.w	#1,d2			;double it to get word offset
	lea	pixel_offsets(pc),a5	;get plot values
	move.w	0(a5,d2.w),d0
	or.w	d0,(a6)			;now plot it

		rts


***********************
* SUBROUTINES SECTION *
***********************
v_sync	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts

tst_key	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

get_key	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts


set_user
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	rts


set_old_palette
	lea	old_palette,a0
set_pal	lea	$ffff8240.w,a1
	movem.l	(a0),d0-d7
	movem.l	d0-d7,(a1)
	rts




set_up
		ifeq	DOWNLOAD
		clr.l	-(sp)		;supervisor
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,stack_save
		endc

		move.b	#$12,$fffffc02.w	;DI mouse

		move.w	#3,-(sp)	;get screen base
		trap	#14
		addq.l	#2,sp
		move.l	d0,screen_base

		move.b	$ffff8260.w,org_rez

		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,old_palette

		clr.b	$ffff8260.w

		movem.l	pic+2,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.l	#screens,d0
		clr.b	d0
		move.l	d0,scr_now
		move.l	d0,d1
		add.l	#32000,d1
		eor.l	d0,d1
		move.l	d1,scr_xor

		lea	pic+34,a0
		move.l	scr_now,a1
		move.l	a1,a2
		add.l	#32000,a2
		move.w	#32000/4-1,d0
.show		move.l	(a0),(a1)+
		move.l	(a0)+,(a2)+
		dbf	d0,.show

set_screen	move.l	scr_now,d6
		move.l	scr_xor,d7
		eor.l	d7,d6
		move.l	d6,scr_now
		lsr.l	#8,d6
		lea	$ffff8201.w,a6
		movep.w	d6,(a6)
		rts

	ifeq	DOWNLOAD
*******************
   SECTION DATA
*******************
	endc

pixel_offsets
		dc.w	%1000000000000000
		dc.w	%0100000000000000
		dc.w	%0010000000000000
		dc.w	%0001000000000000
		dc.w	%0000100000000000
		dc.w	%0000010000000000
		dc.w	%0000001000000000
		dc.w	%0000000100000000
		dc.w	%0000000010000000
		dc.w	%0000000001000000
		dc.w	%0000000000100000
		dc.w	%0000000000010000
		dc.w	%0000000000001000
		dc.w	%0000000000000100
		dc.w	%0000000000000010
		dc.w	%0000000000000001

font		incbin	g:\down\font.dat

pic	incbin	f:\pics\oz\grn_man.pi1


Code_End


	ifeq	DOWNLOAD
*******************
   SECTION BSS
*******************
	endc

stack_save	ds.l	1
screen_base	ds.l	1
org_rez		ds.w	1
old_palette	ds.w	16
scr_now		ds.l	1
scr_xor		ds.l	1

x1		ds.w	1
x2		ds.w	1
y1		ds.w	1
y2		ds.w	1

ax		ds.w	1
ay		ds.w	1

sx		ds.w	1
sy		ds.w	1

x		ds.w	1
y		ds.w	1

black		ds.w	16


		ds.b	256
screens		ds.b	32000
		ds.b	32000

		ifne	DOWNLOAD

myend
Code_Length	equ	Code_End-Code_Start
CODE_LENGTH	equ	myend-mycode

		endc
