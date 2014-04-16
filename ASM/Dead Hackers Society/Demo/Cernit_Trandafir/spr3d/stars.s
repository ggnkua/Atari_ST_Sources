

		section	text

rnd:		dc.l	1234579

spr3d_stars_init:

		lea	rnd_coords+800,a0

		move.w	#MAX_STARS-1,d7
.xyz
		add.l	rnd(pc),d1
		ror.l	d1,d1
		addq.w	#5,d1
		move.l	d1,rnd
		move.l	d1,d2
		swap	d2
		and.w	#255,d1
		and.w	#63,d2
		add.w	d2,d1			;0-318
		sub.w	#160,d1			;center x
		asl.w	#7,d1
		move.w	d1,(a0)+

		add.l	rnd(pc),d1
		ror.l	d1,d1
		addq.w	#7,d1
		move.l	d1,rnd
		move.l	d1,d2
		swap	d2
		and.w	#127,d1
		and.w	#63,d2
		add.w	d2,d1
		lsr.l	#8,d2
		and.w	#7,d2
		add.w	d2,d1
		add.w	d2,d1			;0-198
		sub.w	#100,d1			;center y
		asl.w	#7,d1
		move.w	d1,(a0)+

		add.l	rnd(pc),d1
		rol.l	d1,d1
		addq.w	#5,d1
		move.l	d1,rnd
		and.w	#255,d1			;0-255 step 2 = 128 iterations
		move.w	d1,(a0)+

		dbf	d7,.xyz

;precalc stars:
		lea	plot_yofs_start+100*2,a3
		lea	plot_xinterl+160*4,a6

		lea	predivs,a5

		move.w	#ITERATIONS-1,d7
.outer:
		lea	rnd_coords+800,a4

		move.w	#MAX_STARS-1,d6
.prepsmc:
		moveq	#0,d2

		movem.w	(a4)+,d0-2
		subq.b	#2,d2
		move.w	d2,-2(a4)
		add.w	#128,d2

		divs.w	d2,d0
		lsl.w	#2,d0
		
		divs.w	d2,d1
		add.w	d1,d1

		move.l	(a6,d0.w),d4
		add.w	(a3,d1.w),d4
		move.l	d4,(a5)+

		dbf	d6,.prepsmc
		dbf	d7,.outer

spr3d_stars:

MAX_STARS equ 150
NO_STARS equ 150
ITERATIONS equ 128
sf_plane equ 6

		move.l	screen_adr,a0
		lea	192*65+sf_plane(a0),a0		
		move.l	cl_buffer0,a1
		jsr	(a1)
		
		move.l	.pos,d0
		add.l	#MAX_STARS*4,d0
		cmp.l	#MAX_STARS*4*ITERATIONS,d0
		blo.s	.nore
		moveq	#0,d0
.nore
		move.l	d0,.pos
		lea	predivs,a1
		lea	(a1,d0.l),a1

		lea	.smctab+2(pc),a5
		move.l	cl_buffer0,a6
		addq.l	#2,a6

		move.w	#NO_STARS-1,d7
.fillsmc:
		move.l	(a1)+,d0
		move.l	d0,(a5)
		addq.l	#6,a5
		move.w	d0,(a6)
		addq.l	#4,a6
		dbf	d7,.fillsmc

		move.l	screen_adr,a0
		lea	192*65+sf_plane(a0),a0		

.smctab:		
		rept	NO_STARS
		or.w	#$0000,$4000(a0)
		endr

		move.l	cl_buffer0,d0
		move.l	cl_buffer1,cl_buffer0
		move.l	d0,cl_buffer1
		rts

.pos:		dc.l	0

stars_extraclear:
		move.l	screen_adr,a0
		lea	192*65+sf_plane(a0),a0		
		move.l	cl_buffer0,a1
		jsr	(a1)
		move.l	screen_adr,a0
		lea	192*65+sf_plane(a0),a0		
		move.l	cl_buffer1,a1
		jsr	(a1)
		move.l	screen_adr2,a0
		lea	192*65+sf_plane(a0),a0		
		move.l	cl_buffer0,a1
		jsr	(a1)
		move.l	screen_adr2,a0
		lea	192*65+sf_plane(a0),a0		
		move.l	cl_buffer1,a1
		jsr	(a1)

		rts
	

smcls1:
		rept	NO_STARS
		clr.w	4000(a0)
		endr
		rts


smcls2:
		rept	NO_STARS
		clr.w	4000(a0)
		endr
		rts

		section	data

plot_yofs_start:
y set 0
	rept 200
	 dc.w	y
y set y+192
	endr

plot_xinterl:
xo set 0
xp set $8000
	rept	320/16
n set 0
	rept	16
	dc.w	(xp>>n)
	dc.w	xo
n set n+1
	endr
xo set xo+8
	endr

cl_buffer0	dc.l	smcls1
cl_buffer1	dc.l	smcls2

	
		
		section	text
