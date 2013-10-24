



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
	add.w	d0,d0	;ax=ABS(d)*2
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
	add.w	d0,d0
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

	move.w	ax,d7
	sub.w	d0,d7
;d1 now equ (ax-(ay/2)

*plot x,y
	move.w	x,d0
	move.w	y,d1
	bsr	plot


*while (y != y2)	while y<>y2
.loop
	move.w	y,d1
	cmp.w	y2,d1
	beq	.quit

*if d(>=0)
	tst.w	d7
	bmi.s	.over

*x += sx
	move.w	sx,d0
	add.w	d0,x

*d -= ay
	sub.w	ay,d7

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

	move.w	ay,d7
	sub.w	d0,d7
;d1 now equ (ay-(ax/2)



*plot x,y
	move.w	x,d0
	move.w	y,d1
	bsr	plot


*while (x != x2)	while x<>x2
.loop
	move.w	x,d0
	cmp.w	x2,d0
	beq.s	.quit

;d0 already contains X
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
	add.w	#4,a6
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

	and.w	#$f,d2		;get pixel offset

	add.w	d2,d2		;double it to get word offset
	lea	pixel_offsets(pc),a5	;get plot values
	add.w	d2,a5
	move.w	(a5),d0
	or.w	d0,(a6)			;now plot it

		rts



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

