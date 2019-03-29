;-----------------------------------------------------------------------------
; Wibbly Wobbly Distorter thingy v1.0
; Thanks must go to The Zogg for the sine-table and for the 2 extra tricks
; i have learnt while coding this!
; Programmed by Tony B!
; Devpac v2.25, tabs =10
;-----------------------------------------------------------------------------


	opt	o+,ow-


height		=	31



	movea.l	4(sp),a5
	pea	$200.w
	pea	(a5)
	pea	$4a0000
	trap	#1
	lea	$c(sp),sp

	pea	0.w
	move	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,old_stk

	move.b	#$12,$fffffc02.w
	clr.b	$484.w

	move.l	$44e.w,old44e
	clr	-(sp)
	pea	$70000
	pea	$70000
	move	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	
	movem.l	pal(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
	
	lea	$70000,a0
	move	#7999,d0
cls	clr.l	(a0)+
	dbf	d0,cls

*---------
	bsr	preshift_logo
	bsr	convert_dist
*---------

*---------
scan	move	$468.w,d0
vs	cmp	$468.w,d0
	beq.s	vs
	
	moveq	#16,d0		;true red (CPU) time
sync	move.b	$ffff8209.w,d1
	beq.s	sync
	sub.b	d1,d0
	lsl.b	d0,d0
	
	move	#$700,$ffff8240.w
	bsr	distorter
	clr	$ffff8240.w
	
	cmp.b	#$39,$fffffc02.w
	bne.s	scan
*---------

	move.b	#8,$fffffc02.w
	move.l	#gempal,$45a.w
	move.l	old44e(pc),d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w
	
	move.b	#-1,$484.w
	
	move.l	old_stk(pc),-(sp)
	move	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	clr	-(sp)
	trap	#1


*---------preshift 4 bitplane logo
preshift_logo
	lea	logo_table(pc),a2
	moveq	#15-1,d0		;15 copies of logo (+1 original)

shift_logo
	move.l	(a2)+,a0		;source address
	move.l	(a2),a1		;destination address

	moveq	#height-1,d1
do_a_line
	moveq	#4-1,d2		;number of planes

do_plane
i	set	0
	rept	10		;9 + 1 extra word for preshift
	move	i(a0),i(a1)	;copy 16 pixels in plane
i	set	i+8
	endr
i	set	0
	rept	10
	roxr	i(a1)		;shift 16 pixels in plane
i	set	i+8	
	endr

	addq	#2,a0		;next plane
	addq	#2,a1
	dbf	d2,do_plane

	lea	160-8(a0),a0	;next line
	lea	160-8(a1),a1

	dbf	d1,do_a_line
	dbf	d0,shift_logo	;next logo
	rts


*---------draw lines of gfx from pointers in dist_table!
distorter	moveq	#0,d0		;for line offsets
	moveq.l	#0,d3
	moveq	#-8,d2		;for offset into table
	moveq	#height-1,d1
	
	move.l	dist_off(pc),a0	;pos in dist table
	
dist_loop	move.l	(a0)+,a1		;get sprite addr
	move.l	(a0)+,a2		;get screen addr

	cmp.l	#-1,a1		;end of table?
	bne.s	ok
	lea	dist_table(pc),a0	;reload table
	moveq	#-8,d2		;reset offset pointer
	bra.s	dist_loop
	
ok	add	d0,a1		;goto next line on logo
	add	d0,a2		;goto next on screen

	move.l	d3,-8(a2)		;clear sides
	move.l	d3,-4(a2)
	move.l	d3,80(a2)
	move.l	d3,84(a2)
	
	movem.l	(a1),a3/d5/d4/d6/d7/a4/a5/a6
	movem.l	a3/d5/d4/d6/d7/a4/a5/a6,(a2)
	movem.l	32(a1),a3/d5/d4/d6/d7/a4/a5/a6
	movem.l	a3/d5/d4/d6/d7/a4/a5/a6,32(a2)
	movem.l	64(a1),a3/d5/d4/d6	;blit gfx in 4 planes
	movem.l	a3/d5/d4/d6,64(a2)
	
	add	#160,d0		;next line on screen/logo

	addq	#8,d2		;next screen pos. & shifted sprite
	dbf	d1,dist_loop	;do next line

*---------basically the next line saves you having to store more 'wave'
*---------data than necessary. If you have tried to write your own then
*---------you'll know what i mean!! (I learnt this from Zogg by the way!)

	sub	d2,a0		;go back for next time!
	move.l	a0,dist_off	;store for next time

	rts


*---------convert screen offsets and shift offsets into 1 table
*---------for speed U know!!! This is another trick(!) i learnt
*---------from Zogg of The Watchmen (Thanx you my friend!!).

convert_dist
	lea	wave_table(pc),a0	;list of screen offsets
	lea	$70000+(160*60)+32,a1
	lea	logo_table(pc),a2	;address of preshifted sprites
	lea	dist_table(pc),a3	;address of new dist table

convert	move	(a0)+,d0		;get the X co-ord
	move	d0,d1
	tst	d0
	bpl.s	ok_convert_it
	rts			;finished conversion

ok_convert_it
	and	#$f,d1		;get offset into table (0-15)
	lsl	#2,d1		;which is a pointer to a shifted
	move.l	(a2,d1.w),(a3)+	;sprite. now store sprite addr!

	and	#$fff0,d0		;calc screen X pos.
	ror	d0

	lea	(a1,d0.w),a4	;new X pos.
	move.l	a4,(a3)+		;store screen addr

	bra.s	convert


*---------
	data
old44e	dc.l	0
old_stk	dc.l	0
gempal	dc.w	$777,$700,$070,$000,$007,$707,$077,$555
	dc.w	$333,$733,$373,$773,$337,$737,$377,$000

dist_off	dc.l	dist_table

* stored as pixel offsets from left hand side of screen!
* this was taken from the Cosmic Demo "NoName" screen by Zogg!
wave_table
	rept	32
	dc.w	16
	endr
	rept	2
	dc.w	20,24,26,28,29,30,31,31,32,32
	dc.w	32,31,31,30,29,28,26,24,20,16
	dc.w	12,08,06,04,03,02,01,01,00,00
	dc.w	00,01,01,02,03,04,06,08,12,16
	endr
	rept	2
	dc.w	20,24,26,28,29,30,31,31,32,32
	dc.w	32,31,31,30,29,28,26,24,20,16
	endr
	rept	2
	dc.w	12,08,06,04,03,02,01,01,00,00
	dc.w	00,01,01,02,03,04,06,08,12,16
	endr
	rept	3
	dc.w	16,18,19,19,18,16,14,13,13,14
	endr
	rept	32
	dc.w	16
	endr

	dc.w	-1

* when converted with screen data from 'wave_table' and sprite data
* from 'logo_table' this holds the screen address and shifted sprite
* to display!!!

dist_table
	rept	254
	dc.l	0,0		;sprite addr,screen addr
	endr

	dc.l	-1,-1

*---------pointers to each shifted logo
logo_table	
i	set	0
	rept	16
	dc.l	logo+i
i	set	i+(height*160)
	endr

pal	dc.w	$888,$208,$3B88,$C400
	dc.w	$3D98,$620,$730,$748
	dc.w	$750,$5F60,$6002,$9813
	dc.w	$E024,$7835,$8C6,$705F

logo	incbin	bbc_now5.dat
