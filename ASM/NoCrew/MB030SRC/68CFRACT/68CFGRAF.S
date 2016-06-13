; A mandelbrot fractal generator. Uses MC68030 only.
; This is the 'coast-walking' version.
; Author: Fredrik Noring, February 1994.

; Graphic module.
	section	text

* Color plotter.
* d0 = x coordinate multiplyed by 4.
* d1 = y coordinate multiplyed by 4.
* d7 = iteration level.
color	lea	sx_tab(pc),a3
	lea	sy_tab(pc),a4
	move.l	screen(pc),a0
	move.l	(a3,d0.l),d0
	lea	(a0,d0.l),a5
	move.l	(a4,d1.l),d0
	cmp.l	miter(pc),d7
	bne.s	.ok
	clr.w	(a5,d0.l)
	rts
.ok	move.l	d7,d2
	and.l	#$ff,d2		; Only 256 colors.
	lea	palett(pc),a6
	lsl.l	#1,d2
	move.w	(a6,d2.l),(a5,d0.l)
	rts

scolor	move.l	(a3,d2.l),d4
	lea	(a0,d4.l),a6
	move.l	(a4,d3.l),d4
	cmp.l	miter(pc),d7
	bne.s	.ok
	clr.w	(a6,d4.l)
	rts
.ok	move.w	d6,(a6,d4.l)
.ncolor	rts

* Palett precalculator.
mk_pal	lea	palett(pc),a0
	move.l	screen(pc),a1
	lea	(SCREEN_W-COLORS)/2*2(a1),a1
	move.w	#COLORS-1,d0
.1	move.w	(a0)+,(a1)+
	dbra	d0,.1
	rts

* Save old_mode, old_phys and old_log etc.
get_video
	* Save old screen-mode.
	move.w	#-1,-(sp)
	move.w	#88,-(sp)
	trap	#14		; VsetMode
	addq.w	#4,sp
	move.w	d0,old_mode
	* Save old physical screen address.
	move.w	#2,-(sp)
	trap	#14		; Physbase
	addq.w	#2,sp
	move.l	d0,old_phys
	* Save old logical screen address.
	move.w	#3,-(sp)
	trap	#14		; Logbase
	addq.w	#2,sp
	move.l	d0,old_log
	rts

* Restores resolution and screen.
set_video
	* Restore resolution and screen address.
	move.w	old_mode,-(sp)
	move.w	#3,-(sp)
	move.l	old_phys,-(sp)
	move.l	old_log,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	14(sp),sp
	rts

* Sets resolution, screen address and offset to next line.
new_video
	* Set screen address at an even 256 address.
	move.l	#screen_mem+256,d0
	and.l	#$ffffff00,d0
	move.l	d0,screen

	* Set resolution and screen address.
	move.w	#MODE,-(sp)
	move.w	#3,-(sp)
	move.l	screen(pc),-(sp)
	move.l	screen(pc),-(sp)
	move.w	#5,-(sp)
	trap	#14		; Vsetscreen
	lea	14(sp),sp

	* Black border.
	clr.l	$ffff9800.w
	rts

* Clear screen.
cls	move.l	screen(pc),a0
	move.l	screen_w(pc),d0
	mulu.l	screen_h(pc),d0
	add.l	d0,d0
	add.l	d0,a0
	movem.l	void(pc),d2-d7/a1-a2
	move.l	screen_h(pc),d0
	subq.l	#1,d0
.1	move.l	screen_w(pc),d1
	lsr.l	#4,d1
	subq.l	#1,d1
.2	movem.l	d2-d7/a1-a2,-(a0)
	dbra	d1,.2
	dbra	d0,.1
	rts

	section	data
screen		dc.l	0
palett		incbin	palett.dat	; Precalculated true color palett.

	section	bss
old_mode	ds.w	1
old_phys	ds.l	1
old_log		ds.l	1
old_pal		ds.w	256
