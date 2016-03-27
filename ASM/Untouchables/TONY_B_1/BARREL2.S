;   The barrel roller!
;   Barrel can be any size...this routine assumes the picture is
;   Degas low res and is drawn in 4 bit-planes, and is full width
;   of screen and is full length of screen!!!
;
;   Original Code by Tony Bennett
;
;   Devpak v2.23     tabs set at 10


	opt	x+

	movea.l	4(sp),a5
	pea	$200.w
	pea	(a5)
	pea	$4a0000
	trap	#1
	lea	$c(sp),sp

	pea	start(pc)
	move	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	
	clr	-(sp)
	trap	#1



*------------------
start	move.b	#$12,$fffffc02.w

	move.l	#barrel_gfx+2,$45a.w
	
	clr.b	$ffff8260.w
	move.l	#$70000,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w

	lea	barrel_gfx+34(pc),a0;make a duplicate so when the end
	lea	extra_lines,a1	;of gfx is reached, it looks as if
	move	#160*90/8,d0	;it is drawing begin again, but it 
copy_48	move.l	(a0)+,(a1)+	;really doesn't end till 90 lines
	move.l	(a0)+,(a1)+	;later..when the whole gfx is reset
	dbf	d0,copy_48	;& we start drawing from top again!
	
	lea	$70000,a0
cls	clr.l	(a0)+
	cmpa.l	#$78000,a0
	blt.s	cls


*------------------
scan:	move	#37,-(sp)		;aaaarrrghghlioiipp the O/S
	trap	#14
	addq.l	#2,sp
	
	
	lea	barrel_gfx+34(pc),a0
	move	pic_offset(pc),d0
	add	d0,a0		;get pic offset for scroll effect
	cmp	#160*200,d0
	bne.s	get_off
	clr	pic_offset
	
get_off	add	#160,pic_offset	;speed factor (160,320,640)
	
	lea	$70000,a1
	lea	bend(pc),a2

val	set	0
	rept	45		;lines high
	movem.l	(a0),d0-d7/a3-a6	;draw a line in 4-planes!
	movem.l	d0-d7/a3-a6,val(a1)
	movem.l	48(a0),d0-d7/a3-a6
	movem.l	d0-d7/a3-a6,val+48(a1)
	movem.l	96(a0),d0-d7/a3-a6
	movem.l	d0-d7/a3-a6,val+96(a1)
	movem.l	144(a0),d0-d7/a3-a6
	movem.l	d0-d7/a3-a6,val+144(a1)
val	set	val+160
	
	add	(a2)+,a0		;next pic offset for barrel image
	endr
	
	cmp.b	#$39,$fffffc02.w
	bne	scan


	move.b	#8,$fffffc02.w
	move.l	#gempal,$45a.w
	
	rts




*------------------
gempal:	dc.w	$777,$700,$070,$000,$007,$707,$077,$555
	dc.w	$333,$733,$373,$773,$337,$737,$377,$000

;   each value represents a line of (offset from) the picture!
bend	dc.w	160,960,640,480,480,320,320,320
	dc.w	160,160,320,160,160,160,160,160
	dc.w	160,160,160,160,160,160
	dc.w	160,160,160,160,160,160,160
	dc.w	160,160,160,160,160,320,160,160
	dc.w	320,320,320,480,480,640,960,960

pic_offset:
	ds.w	1

barrel_gfx:
	incbin	b:\tec_v8.pi1
extra_lines:
	dcb.b	160*90,0
