;
; Test de Fractale de Mandelbrot
;
	output	e:\sector1\yo.tos
	opt	o+,ow-,x+,p=68030

xres	equ	160
yres	equ	100
vidmode	equ	0

xinc	equ	($30<<18)/xres	; 3.0 / 2 / xres
yinc	equ	$0<<18		; 0.0
xcnt	equ	-$08<<18	; -0.5 / 2
ycnt	equ	$00<<18		; 0.0 / 2

;TEST

; 1.5 * 100 / 160 = 1.875 = 1+7/8

	IFD	TEST
	pea	hopla(pc)
	move	#$26,-(sp)	; Supexec
	trap	#14
	addq.l	#6,sp

	clr	-(sp)
	trap	#1

	ELSE

	include	'video.s'

	ENDC

hopla
	move	#$4242,-(sp)
	pea	(dsp_code_end-dsp_code)/3.w
	pea	dsp_code(pc)
	move	#$6d,-(sp)	; Dsp_ExecProg
	trap	#14
	lea	12(sp),sp

; Align the screen buffer to a multiple of 4.
	lea	screen,a6
	move.l	a6,d0
	addq.l	#2,d0
	and.w	#-4,d0
	move.l	d0,a6

	IFND	TEST
; Set the screen address
	lsr	#8,d0
	move.l	d0,$ffff8200.w
	move.l	a6,d0
	move.b	d0,$ffff820d.w

; Set the screen mode
	moveq	#vidmode,d0
	bsr	set_video_mode
	ENDC

	lea	dbltbl+64*64*4(pc),a0
	lea	palette(pc),a1
	move	#64*64-1,d0
tblcalc_loop
	move	d0,d1
	and	#$3f,d1
	move.w	(a1,d1.w*2),d2
	swap	d2
	move	d0,d1
	lsr	#6,d1
	and	#$3f,d1
	move.w	(a1,d1.w*2),d2
	move.l	d2,-(a0)
	dbra	d0,tblcalc_loop

	lea	$ffffa202.w,a0
	lea	$ffffa204.w,a1
.bla6	btst	#1,(a0)
	beq.s	.bla6
	move.l	#xres,(a1)
	move.l	#yres,(a1)

	lea	dbltbl(pc),a3

	move.l	a6,a5
	move.l	$4ba.w,d0
	sub.l	#strtime,d0
	move.l	d0,orgtimr
restart

; Here we calculate the position of the center of the screen in the fractal image	
	move.l	$4ba.w,d0
	sub.l	orgtimr(pc),d0
	mulu	speed(pc),d0
	lsr.l	d0
	cmp	#endtime,d0
	bpl	the_end

	lea	tvalues(pc),a0
; Later I'll code some dichotomic research
search_loop
	cmp	(a0)+,d0
	bgt.s	search_loop
; Ok, we've found the interval.
	subq	#2,a0
	move	(a0),d2
	move	-(a0),d1
	lea	-npoints*6-2(a0),a1	; X coord addr of the far left point
	bsr	bspline_calc
	move	d6,d3
	lea	-npoints*4-2(a0),a1	; Y coord addr of the far left point
	bsr	bspline_calc
	move	d6,d4
	lea	-npoints*2-2(a0),a1	; Z coord addr of the far left point
	bsr	bspline_calc
	moveq	#10,d1
	lsl.l	d1,d6
	divu.l	#xres,d6

	moveq	#10,d1
	lsl.l	d1,d3			; X coord of the center << 22
	lsl.l	d1,d4			; Y coord of the center << 22

	move.l	a5,a6
	lea	$ffffa202.w,a0
	lea	$ffffa204.w,a1
.bla6	btst	#1,(a0)
	beq.s	.bla6
;	move.l	#xinc,(a1)
;	move.l	#yinc,(a1)
	move.l	d6,(a1)
	move.l	#0,(a1)
	move.l	d3,(a1)
	move.l	d4,(a1)

;	IFND	TEST
;yo	cmp.b	#$81,$fffffc02.w
;	bne.s	yo
;	ENDC

	lea	$ffffa202.w,a0
	lea	$ffffa204+2.w,a1
;	lea	dbltbl(pc),a3
	moveq	#0,d2

	move	#yres-1,d0
main_loop
	lea	buffer(pc),a2
	moveq	#xres/2/16-1,d1
.bcl	btst	#0,(a0)
	beq.s	.bcl
sec_bcl
	rept	16
	move.w	(a1),(a2)+
	endr
	dbra	d1,sec_bcl

	lea	buffer(pc),a2
	moveq	#xres/2/16-1,d1
sec2_bcl
	rept	16
	move	(a2)+,d2
	move.l	(a3,d2.l*4),(a6)+
	endr
	dbra	d1,sec2_bcl

	dbra	d0,main_loop

	IFND	TEST
	cmp.b	#$b9,$fffffc02.w
	bne	restart
	ENDC
the_end
	rts

; calculate a B-spline coordinate (-32768ócoords<32767)
; d0 : x coordinate (d1ód0<d2)
; d1 : lower bound of the interval
; d2 : upper bound of the interval
; a1 : pointer to P1, P2, P3, and P4.
; return :
; d6 : the coordinate
bspline_calc
	movem.l	d0-d5/d7,-(sp)
	moveq	#16,d7		; number of bits for the decimals section of t and w
	sub	d1,d0
	sub	d1,d2

	lsl.l	d7,d0
	divu.l	d2,d0		; t << DB
	moveq	#1,d1
	lsl.l	d7,d1		; 1 << DB
	sub.l	d0,d1		; w << DB (w=(1-t))

	move	d1,d2
	mulu	d2,d2		; wý << 2DB
	lsr.l	d7,d2		; wý << DB
	move	d2,d3
	mulu	d1,d3		; wþ << 2DB
	lsr.l	d7,d3		; wþ << DB
	move	(a1)+,d6
	ext.l	d6
	muls.l	d3,d6		; P1*wþ << DB

	move	d0,d4
	mulu	d4,d4		; tý << 2DB
	lsr.l	d7,d4		; tý << DB
	move	d4,d5
	mulu	d0,d5		; tþ << 2DB
	lsr.l	d7,d5		; tþ << DB
	move.l	d5,d0
	add.l	d0,d0
	add.l	d5,d0		; 3tþ << DB
	move.l	d4,d1
	add.l	d1,d1
	add.l	d4,d1
	add.l	d1,d1		; 6tý << DB
	sub.l	d1,d0		; (3tþ-6tý) << DB
	moveq	#4,d4
	lsl.l	d7,d4		; 4 << DB
	add.l	d4,d0		; (3tþ-6tý+4) << DB
	move	(a1)+,d1
	ext.l	d1
	muls.l	d1,d0		; P2*(3tþ-6tý+4) << DB
	add.l	d0,d6

	move.l	d3,d0
	add.l	d0,d0
	add.l	d3,d0		; 3wþ << DB
	move.l	d2,d1
	add.l	d1,d1
	add.l	d2,d1
	add.l	d1,d1		; 6wý << DB
	sub.l	d1,d0		; (3wþ-6wý) << DB
	add.l	d4,d0		; (3wþ-6wý+4) << DB
	move	(a1)+,d1
	ext.l	d1
	muls.l	d1,d0		; P3*(3wþ-6wý+4) << DB
	add.l	d0,d6

	move	(a1)+,d1
	ext.l	d1
	muls.l	d1,d5		; P4*tþ << DB
	add.l	d5,d6

	divs.l	#6,d6
	lsr.l	d7,d6


	movem.l	(sp)+,d0-d5/d7
	rts


	section	data
dsp_code
	incbin	'mandel.p56'
dsp_code_end
	even
palette	dc.w	0 ;$07f3
	dc.w	$07fc,$07f9,$07f6,$07f3,$07f0,$07ed,$07ea,$07e7,$07e4,$07e1
	dc.w	$1fe0,$37e0,$4fe0,$67e0,$7fe0,$97e0,$afe0,$c7e0,$dfe0,$f7e0
	dc.w	$ff20,$fe60,$fda0,$fce0,$fc20,$fb60,$faa0,$f9e0,$f920,$f860
	dc.w	$f803,$f806,$f809,$f80c,$f80f,$f812,$f815,$f818,$f81b,$f81e
	dc.w	$e01f,$c81f,$b01f,$981f,$801f,$681f,$501f,$381f,$201f,$081f
	dc.w	$00df,$019f,$025f,$031f,$03df,$049f,$055f,$061f,$06df,$079f



; Point format = x coord * 1024, y coord * 1024, time value (might change later), 
points
;xcoords	dc.w	-2500, -1900,-1800,-1700,-1500,-1200,-1000, -800, -750, -750, -750, -500,  500
;ycoords	dc.w	    0,    20,   50,   70,  100,  400,  300,  200,    0,  400,  500,  700,  800
;zcoords	dc.w	  100,   300,  400,  450,  200,  200,  200,  200,  200,  200,  200,  200,  200
;tvalues	dc.w	   -1,     0, 2000, 4000, 7000,10000,12000,14000,16000,17000,18000,21000,26000

;xcoords	dc.w	 -10160,-10160,-10160,-10160
;xcoords	dc.w	 -5000,-5000,-5000,-5000
;ycoords	dc.w	   3200,  3200,  3200,  3200
;zcoords	dc.w	  7000, 7000, 7000, 7000
;tvalues	dc.w	   -1,    0, 5000, 7000

xcoords	dc.w	 -5280,-5180,-5080,-4800,-4500,-4200,-3800,-3000,-2000
ycoords	dc.w	  1800, 1500, 1300, 1200, 1250, 1300, 1100, 1000, 1300
zcoords	dc.w	  8000,  40,  20,  20,  40,  40,  20, 100, 160
tvalues	dc.w	    -1,    0, 2000, 4000, 6000, 7000, 8000,10000,12000

npoints equ	(*-tvalues)/2
strtime	equ	0
endtime	equ	10000
speed	dc.w	1

	section	bss
orgtimr	ds.l	1
buffer	ds.w	xres
dbltbl	ds.l	64*64
dbltbl2	ds.l	64*64
screen	ds.w	xres*yres+1
