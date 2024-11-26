;-----------------------------------------------------------------------------
; Wibbly Wobbly Bouncy Distorter thingy v1.1
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
	
;	moveq	#16,d0		;true red (CPU) time
;sync	move.b	$ffff8209.w,d1
;	beq.s	sync
;	sub.b	d1,d0
;	lsl.b	d0,d0
	
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
	moveq.l	#0,d3		;for clearing data
	moveq	#-8,d2		;for offset into table
	moveq	#height-1,d1
	move.l	dist_off(pc),a0	;pos in dist table
	
	cmp.b	#$66,$fffffc02.w	;* key to stop bounce
	beq	dist_loop
	
	
*---------first the bouncing!
get_wave
	move.l	boff(pc),a5	;bounce offset
	move	(a5)+,smc+2	;get offset
	tst	(a5)		;end of table?
	bpl.s	wave_it
	move.l	#btab,boff	;reset table
	bra.s	get_wave
	
wave_it
	move.l	a5,boff		;store for next time


*---------this is the very slow 'clear old sprite shit' procedure!
*---------don't hassle me about it, i ain't got time to do it proper!

	lea	$70000+(160*60)+32,a2
	moveq	#20-1,d6
clr
i	set	0
	rept	13		;clear 20 lines at top
	move.l	d3,i(a2)
	move.l	d3,4+i(a2)
i	set	i+8
	endr
	lea	160(a2),a2
	dbf	d6,clr

	lea	$70000+(160*91)+32,a2
	moveq	#20-1,d6
clr2
i	set	0
	rept	13
	move.l	d3,i(a2)		;20 lines at bottom
	move.l	d3,4+i(a2)
i	set	i+8
	endr
	lea	160(a2),a2
	dbf	d6,clr2


*---------this is the actual distorter!
dist_loop	move.l	(a0)+,a1		;get sprite addr
	move.l	(a0)+,a2		;get screen addr

smc	add	#0,a2		;add bounce offset to screen
	
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
	
*---------if you want to speed things up, then you can double the offset
*---------into the dist table like thus ....
*	addq	#8,a0

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
	and	#$f,d1		;mask lower 4 bits
	lsl	#2,d1		;offset gives sprite ptr in table
	move.l	(a2,d1.w),(a3)+	;store sprite addr

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
wave_table
	dcb.w	52,16
	rept	2
	dc.w	20,24,26,28,29,30,31,31,32,32
	dc.w	32,31,31,30,29,28,26,24,20,16
	dc.w	12,08,06,04,03,02,01,01,00,00
	dc.w	00,01,01,02,03,04,06,08,12,16
	endr
	rept	3
	dc.w	16,18,19,19,18,16,14,13,13,14
	endr
	dcb.w	36,16
	rept	3
	dc.w	16,17,18,19,20,21,22,23,24,25
	dc.w	25,24,23,22,21,20,19,18,17,16
	endr
	dcb.w	32,16
	dc.w	17,18,19,20,21,22,23,24,25,26,27
	dc.w	28,29,30,31,32,33,34,35,36,37
	dc.w	38,39,40,41,42,43,44,45,46,47
	dc.w	48,49,50,51,52,53,54,55
	rept	3
	dc.w	56,58,59,59,58,56,54,53,53,54
	endr
	dc.w	53,51,49,47,45,43,41,39,37,35
	dc.w	33,31,29,27,25,23,21,19,17,16
	dcb.w	36,16
	dc.w	14,12,10,8,6,4,2,0
	dc.w	4,10,12,13,14,15
	dcb.w	36,16

	dc.w	-1

* when converted with screen data from 'wave_table' and sprite data
* from 'logo_table' this holds the screen address and shifted sprite
* to display!!!

dist_table
	rept	465
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
	
boff	dc.l	btab

btab	dc.w	0,160,160,160,320,320,320,480,480,640,640,800,800,960,1120
	dc.w	1280,1440,1600,1760,1920,2080,2240,2400,2400,2560,2560,2720,2720,2880
	dc.w	2880,2880,3040,3040,3040,3200,3200,3200,3200
	dc.w	3040,3040,3040,2880,2880,2880,2720,2720,2560,2560,2400,2400
	dc.w	2240,2080,1920,1760,1600,1440,1280,1120,960,800,800,640,640
	dc.w	480,480,320,320,320,160,160,160,0,0,0,-1
	
pal	dc.w	$888,$208,$3B88,$C400
	dc.w	$3D98,$620,$730,$748
	dc.w	$750,$5F60,$6002,$9813
	dc.w	$E024,$7835,$8C6,$705F

logo	incbin	bbc_now5.dat

