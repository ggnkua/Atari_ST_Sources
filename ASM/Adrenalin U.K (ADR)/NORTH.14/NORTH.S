*
* NORTHSIDE menu converted from Erik Plankton's bit for KNOCK KNOCK
*
* Code does NOT use O/S (except for set super/user)
*
* All code ½ Machine System Data¿ of Persistence Of Vision
* Dec '91
*
*
	bsr	set_super
	or.b	#2,$ffff820a.w		;50hz
	movem.l	$ffff8240.w,d0-d7	;get old pal
	movem.l	d0-d7,old_pal
	move.l	$44e.w,org_screen_base	;get screen base
	clr.b	$ffff8260.w		;low rez
	move.b	#$12,$fffffc02.w	;no mouse

	bsr	set_up		;set up screen for flipping
	lea	screen_base,a6
	move.l	(a6),4(a6)

;************************************************************************
;*                      	LAP 9					*
;*                              -----					*
;* Stolen by: MAC SYS DATA of P.O.V. 25/11/91 21:23                     *
;*      From: MAGGIE 4							*
;* Include files:-                                                      *
;*                 LAP9.MUS into TUNE					*
;************************************************************************

; only one tune
	moveq	#1,d0
	jsr	tune

	lea	old_wave_1,a0
	lea	old_wave_2,a1
	move.l	a0,d0
	move.l	a1,d1
	eor.l	d0,d1
	move.w	d1,old_wave_switch

	bsr	scroll

	bsr	show_pic

	bsr	start_interrupts

wait	bsr	vsync

	bsr	set_screen

	bsr	set_rasters

	move.w	old_wave_switch,d0
	and.l	#$ff,d0
	eor.l	d0,old_wave_pointer

	bsr	clear_scroll

	bsr	bounce_logo



	cmp.b	#$01,key+1		;exit with ESCape
	beq	exit



	move.w	key,d0
	bsr	change_hz

	cmp.w	#$c53,d0
	beq	reset

	lea	demo_keys,a0
.next	move.w	(a0)+,d1
	bmi	wait
	cmp.b	d1,d0
	beq.s	.run
	bra.s	.next

.run	and.w	#$ff00,d1
	lsr.w	#8,d1
	lsl.w	#2,d1
	lea	filenames,a0
	add.w	d1,a0
	move.l	(a0),a0

	lea	$200.w,a1
	REPT	4
	move.l	(a0)+,(a1)+
	ENDR


	move.w	sr,-(sp)
	or.w	#$700,sr
	move.l	old_118,$118.w
	move.l	old_70,$70.w
	move.l	old_120,$120.w
	move.b	a07_bak,$fffffa07.w
	move.b	a09_bak,$fffffa09.w
	move.b	a13_bak,$fffffa13.w
	move.b	a17_bak,$fffffa17.w
	clr.b	$fffffa1b.w
	move.w	(sp)+,sr

	move.l	#0,d0
	jsr	tune
stop_tune
	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)

	movem.l	black,d0-d7
	movem.l	d0-d7,$ffff8240.w

	tst.w	hz_col
	beq.s	.skip
	clr.b	$ffff820a.w
.skip	move.l	org_screen_base,d6
	lsr.l	#8,d6
	lea	$ffff8201.w,a5
	movep.w	d6,(a5)

	move.b	#$8,$fffffc02.w
	bsr	set_user

	clr.w	-(sp)
	trap	#1


exit	move.w	sr,-(sp)
	or.w	#$700,sr
	move.l	old_118,$118.w
	move.l	old_70,$70.w
	move.l	old_120,$120.w
	move.b	a07_bak,$fffffa07.w
	move.b	a09_bak,$fffffa09.w
	move.b	a13_bak,$fffffa13.w
	move.b	a17_bak,$fffffa17.w
	clr.b	$fffffa1b.w
	move.w	(sp)+,sr

	move.l	#0,d0
	jsr	tune

	lea	$ffff8800.w,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)

	movem.l	old_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.l	org_screen_base,d6
	lsr.l	#8,d6
	lea	$ffff8201.w,a5
	movep.w	d6,(a5)

	move.b	#1,$ffff8260.w		;med rez for assem

	move.b	#$8,$fffffc02.w
	bsr	set_user

	clr.w	-(sp)
	trap	#1



reset	move.l	$4.w,-(sp)
	rts


change_hz
	tst.w	clock
	bne.s	.end
	cmp.b	#$0b,d0
	beq.s	.ok
	cmp.b	#$70,d0
	beq.s	.ok
	rts
.ok	eor.w	#$002,hz_col
	move.w	#10,clock
	rts
.end	subq.w	#1,clock
	rts



*******************
* CUSTOM ROUTINES *
*******************
clear_scroll
	move.l	old_wave_pointer,a1
	move.l	(a1),a1
	move.w	#40-1,d0
	moveq	#0,d2
	move.w	d2,d3
	move.w	d2,d4
.loop	move.l	screen_base,a0
	move.w	(a1)+,d1
	addq.w	#6,a0
	move.l	a0,a2
	add.w	d1,a0
	REPT	11
	move.b	d3,(a0,d2.w)
	lea	160(a0),a0
	ENDR
	lea	(31-11-8)*160(a0),a0
	REPT	8
	move.b	d3,(a0,d2.w)
	lea	160(a0),a0
	ENDR

	not.w	d4
	bpl.s	.word
	addq.w	#1,d2
	bra.s	.la
.word	addq.w	#7,d2
.la	move.l	a2,a0
	dbf	d0,.loop

; now scroll the bastard

scroll	move.l	screen_base,a1
	addq.w	#6,a1
	cmp.l	#waves_end,wave_pointer
	blt.s	.no_reset
	move.l	#waves,wave_pointer
.no_reset
	move.l	wave_pointer,a6

	move.l	old_wave_pointer,a5
	move.l	a6,(a5)

	lea	font_offsets,a2
	lea	font,a3
	move.l	scroll_pointer,a4
	move.l	a4,a5

	moveq	#0,d4
	moveq	#40,d5
	move.w	char_offset,d6
next_char
	move.b	(a5),d7		;get a letter
	sub.b	#32,d7		;rid of ASCII
	ext.w	d7

	moveq	#0,d0
	move.l	a3,a0
	move.b	(a2,d7),d0
	mulu	#(31*4),d0
	add.w	d0,a0
	move.w	d6,d0
	mulu	#31,d0		;char depth 31 deep
	add.w	d0,a0

.column
	moveq	#0,d1
	move.w	(a6)+,d1
	move.l	a1,-(sp)
	add.w	d1,a1
OFF	set	0
	REPT	31
	move.b	(a0)+,OFF(a1)
OFF	set	OFF+160
	ENDR
	move.l	(sp)+,a1

	subq.w	#1,d5
	beq.s	.finish

	addq.w	#1,a1		;lower byte of word
	tst.w	d4
	beq.s	.skip		;if D4=0 then do next word
	addq.w	#6,a1		;else goto next word on screen
.skip	not.w	d4
	addq.w	#1,d6		;character offset
	and.w	#3,d6
	bne	.column

	addq.w	#1,a5		;scroll pointer
	tst.b	(a5)		;is end of text?
	bpl	next_char	;NO!
	lea	scroll_text,a5	;do reset scrolline
	bra	next_char

.finish
	addq.w	#1,char_offset
	and.w	#3,char_offset
	bne.s	.end
	addq.w	#1,a4
	tst.b	(a4)
	bpl.s	.end
	lea	scroll_text,a4
.end	move.l	a4,scroll_pointer
	addq.l	#4,wave_pointer
	rts






bounce_logo
; clear old bounce
	move.w	bounce_offset,d0
	sub.w	#1,d0
	and.w	#1023,d0
	lea	bounce_table,a1
	add.b	d0,d0
	move.w	0(a1,d0.w),d0
	mulu	#160,d0

	sub.w	#160*4,d0
	bpl.s	.se
	clr.l	d0

.se	move.l	screen_base,a2
	add.w	d0,a2
	lea	52*160(a2),a3
	moveq	#0,d1
OFF	set 0
	REPT	20*9		;clear 4 lines
	move.w	d1,OFF(a2)
	move.w	d1,OFF(a3)
OFF	set OFF+8
	ENDR


	move.w	bounce_offset,d0
	and.w	#1023,d0
	add.b	d0,d0			;double line offset
	move.w	0(a1,d0.w),d0
	mulu	#160,d0
	lea	pic+34,a0
	move.l	screen_base,a1
	add.w	d0,a1

;now print the fuckin' logo.
	move.w	#53-1,d0	;logo depth
.loop
OFF	set 0
	REPT	20
	move.w	OFF(a0),OFF(a1)
OFF	set OFF+8
	ENDR
	lea	160(a0),a0
	lea	160(a1),a1
	dbf	d0,.loop

	add.w	#1,bounce_offset

	rts




set_rasters
	lea	rast_colours,a0
	move.w	#200-1,d0
.lo	move.w	hz_col,(a0)+
	dbf	d0,.lo

	lea	colour_bar,a0
	lea	rast_colours,a1
	lea	raster_path,a2
	move.w	path_ptr,d2
	moveq	#30-1,d0		;number of rasterbars
.loop
	move.l	a0,a4
	move.l	a1,a3
	add.w	(a2,d2),a3

	move.w	(a4)+,(a3)+		;width of bar - 1 line =word


	add.w	#(2*3),d2		;gap between lines
	and.w	#(2*256)-1,d2
	add.w	#2,a0		;increase through colours
	dbf	d0,.loop
	add.w	#6,path_ptr
	and.w	#(2*256)-1,path_ptr
	rts


new_120
	move.w	$300.w,$ffff8240.w

	movem.l	d6/a6,-(sp)
	move.l	raster_pos,a6
	move.w	(a6)+,$300.w
	move.l	a6,raster_pos

	move.w	800(a6),$ffff8240+2.w	;ERIK PLANKTON logo colour
	move.l	420(a6),$ffff8240+12.w

	move.w	380(a6),d6
	swap	d6
	move.w	380(a6),d6

	move.l	d6,$ffff8240+28.w

	move.l	d6,$ffff8240+16.w	;scrollers colours
	move.l	d6,$ffff8240+20.w

	movem.l	(sp)+,d6/a6
null	rte


new_70	clr.w	vsync_flag
	clr.b	$fffffa1b.w
	move.l	#new_120,$120.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	hz_col,$ffff8240.w
	movem.l	pic+4,d0-d6
	movem.l	d0-d6,$ffff8242.w

	bsr	tune+8

	move.l	raster_pos,a6
	move.w	(a6)+,$300.w
	move.l	a6,raster_pos

	movem.l	(sp)+,d0-d7/a0-a6
	move.l	#rast_colours,raster_pos
	rte

new_118	movem.l	d0,-(sp)
	move.b	$fffffc02.w,d0
	cmp.b	#$1d,d0
	bne.s	.k1
	bset	#2,key
.k1	cmp.b	#$9d,d0
	bne.s	.k2
	bclr	#2,key
.k2	cmp.b	#$38,d0
	bne.s	.k3
	bset	#3,key
.k3	cmp.b	#$b8,d0
	bne.s	.k4
	bclr	#3,key
.k4	move.b	d0,key+1
	bclr	#6,$fffffa11.w
	movem.l	(sp)+,d0
	rte


vsync	move.w	#-1,vsync_flag
aa	tst.w	vsync_flag
	bne.s	aa
	rts


***********************
* SUBROUTINES SECTION *
***********************
set_up	move.l	#screens,d0
	clr.b	d0
	move.l	d0,screen_base
	move.l	d0,d1
	add.l	#32000,d1
	eor.l	d0,d1
	move.l	d1,scr_xor
	rts

start_interrupts
	move.w	#$2700,sr
	move.l	$70.w,old_70
	move.l	$120.w,old_120
	move.l	$118.w,old_118
	move.l	#new_70,$70.w
	move.l	#null,120.w
	move.l	#new_118,$118.w
	move.b	$fffffa07.w,a07_bak
	move.b	$fffffa09.w,a09_bak
	move.b	$fffffa13.w,a13_bak
	move.b	$fffffa17.w,a17_bak
	clr.b	$fffffa1b.w
	move.b	#1,$fffffa07.w
	move.b	#$40,$fffffa09.w
	move.b	#1,$fffffa13.w
	bclr.b	#3,$fffffa17.w
	move.w	#$2300,sr
	rts

set_screen
	lea	screen_base,a6
	move.l	(a6),d6
	move.l	d6,4(a6)
	move.l	scr_xor,d7
	eor.l	d7,d6
	move.l	d6,screen_base
	lsr.l	#8,d6
	lea	$ffff8201.w,a5
	movep.w	d6,(a5)
	rts






set_super
	clr.l	-(sp)		;Set super stack equal
	move.w	#$20,-(sp)	; to user stack before call
	trap	#1
	addq.l	#6,sp		;correct stack
	move.l	d0,stack_save	;save old supervisor stack value
	rts
set_user
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1		;back to user
	addq.l	#6,sp		;correct stack
	rts


show_pic
	lea	pic+34,a0
	move.l	screen_base,a1
	lea	32000(a1),a2
	move.w	#32000/4-1,d0
.loop	move.l	(a0),(a1)+
	move.l	(a0)+,(a2)+
	dbf	d0,.loop
	rts

****************
  SECTION DATA
****************


pic	incbin	north.pi1

tune	incbin	lap9.mus
	even



scroll_pointer	dc.l	init_scroll_text+7

init_scroll_text
	dcb.b	100," "
scroll_text
 dc.b "      IVOR BIGGUN PRESENTS - NORTHSIDE MENU 14.       "
 DC.B "  MENU CODED BY MAC SYS DATA OF P.O.V.,   GRAFIX BY OZ AND M.S.D.,     "
 DC.B "MUSIC BY LAP (COMPOSITION 9).           "
 DC.B "NOTHSIDE TEXT HERE...        "
 DC.B "                         BYE........................"
 DC.B "...................................................."
 DC.B "                                                    "
 dc.b $ff
	even
char_offset	dc.w	0
font	dcb.b	31*4,0
	incbin	1plane.fnt
	even
old_wave_switch	dc.w	0
old_wave_pointer
	dc.l	old_wave_1
old_wave_1	dc.l	waves
old_wave_2	dc.l	waves
wave_pointer	dc.l	waves
waves		incbin	sine1.dat"
waves_end	incbin	sine1.dat"
	even
font_offsets
;          !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
 dc.b	0,41,43,00,00,00,00,46,44,45,00,00,38,42,39,48

;        0  1  2  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @
 dc.b	27,28,29,30,31,32,33,34,35,36,40,00,00,00,00,47,00

;        A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q
 dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17

;        R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c
 dc.b	18,19,20,21,22,23,24,25,26,40,00,41,00,00,00,00,00,00

;        d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u
 dc.b	50,00,00,00,00,00,00,00,00,48,00,00,00,00,00,49,00,00





colour_bar
 dc.w	$0ff,$07f,$06f,$05f,$04f,$03f,$02f,$01f
 dc.w	$00f,$107,$206,$305,$405,$503,$602,$701
 dc.w	$f00,$f80,$f10,$f90,$f20,$fa0,$f30,$fb0
 dc.w	$f40,$fc0,$f50,$fd0,$f60,$fe0

path_ptr	dc.w	0

raster_path	incbin	RASTER.PTH

rast_colours
	dcb.w	200,0

hz_col	dc.w	0000		;null byte due to the way I did it

	dcb.w	11,$000		;don't do no rasters in logo

; Holy shit loads of raster colour like things for the scroller.
	dc.w	$800,$100,$900
	dc.w	$200,$a00,$300,$b00,$480,$c10,$590
	dc.w	$d20,$6a0,$e30,$7b0,$f40,$7c0,$650
	dc.w	$5d0,$468,$3e1,$279,$1f2,$0fa,$0f3
	dc.w	$0fb,$074,$0ec,$065,$0dd,$056,$0ce
	dc.w	$047,$0bf,$83e

	dc.w	$1a6,$92d,$295,$a1c,$304,$b0b,$483
	dc.w	$c1a,$592,$d29,$6a1,$e38,$7b0,$f48
	dc.w	$7c1,$e59,$6d2,$d6a,$5e3,$c7b,$4f4
	dc.w	$b6c,$355,$a4d,$236,$92e,$117,$80f
	dc.w	$006,$805,$104,$903,$202,$a01
	dc.w	$300,$b80,$410,$c90,$520,$da0,$630
	dc.w	$eb0,$740,$fc0,$f50,$fd0,$f60,$fe0
	dc.w	$f70,$ff0,$770,$ee0,$660,$dd0,$550
	dc.w	$cc0,$440,$bb0,$338,$aa1,$229,$992
	dc.w	$11a,$883,$00b,$004,$00c,$005,$00d
	dc.w	$006,$00e,$007,$08f
	dc.w	$01f,$09f,$02f,$0a7,$03e,$0b6
	dc.w	$04d,$0c5,$05c,$0d4,$06b,$0e3,$07a
	dc.w	$0f2,$0f9,$071,$0e8,$060,$0d0,$050
	dc.w	$0c0,$040,$0b0,$030,$0a0,$020,$090
	dc.w	$818,$181,$909,$202,$a0a,$303,$b0b
	dc.w	$404,$c0c,$505,$d0d,$606,$e0e,$707
	dc.w	$f0f,$f07,$f0e,$f06,$f0d,$f05,$f0c
	dc.w	$f04,$f0b,$f03,$f0a,$f82,$f19,$f91
	dc.w	$f28,$fa0,$f30,$fb0,$f40,$fc0,$f50
	dc.w	$fd0,$f60,$fe0,$f70,$ff0

	dc.w	$770,$660,$550,$440,$330,$220,$110
;colours for ERIK LOGO
	dc.w	$800,$800,$100,$100,$900,$900,$200,$200,$a00,$a00
	dc.w	$300,$300,$b00,$b00,$400,$400,$c00,$c00,$500,$500
	dc.w	$d00,$d00,$600,$600,$e00,$e00,$700,$700,$f00,$f00

	dc.w	$f80,$f80,$f10,$f10,$f90,$f90,$f20,$f20,$fa0,$fa0
	dc.w	$f30,$f30,$fb0,$fb0,$f40,$f40,$fc0,$fc0,$f50,$f50
	dc.w	$fd0,$fd0,$f60,$f60,$fe0,$fe0,$f70,$f70,$ff0,$ff0

	dc.w	$ff8,$ff8,$ff1,$ff1,$ff9,$ff9,$ff2,$ff2,$ffa,$ffa
	dc.w	$ff3,$ff3,$ffb,$ffb,$ff4,$ff4,$ffc,$ffc,$ff5,$ff5
	dc.w	$ffd,$ffd,$ff6,$ff6,$ffe,$ffe,$ff7,$ff7,$fff,$fff

	dc.w	$7ff,$7ff,$eff,$eff,$6ff,$6ff,$dff,$dff,$5ff,$5ff
	dc.w	$cff,$cff,$4ff,$4ff,$bff,$bff,$3ff,$3ff,$aff,$aff
	dc.w	$2ff,$2ff,$9ff,$9ff,$1ff,$1ff,$8ff,$8ff,$0ff,$0ff

	dc.w	$07f,$07f,$0ef,$0ef,$06f,$06f,$0df,$0df,$05f,$05f
	dc.w	$0cf,$0cf,$04f,$04f,$0bf,$0bf,$03f,$03f,$0af,$0af
	dc.w	$02f,$02f,$09f,$09f,$01f,$01f,$08f,$08f,$00f,$00f

	dc.w	$087,$087,$01e,$01e,$096,$096,$02d,$02d,$0a5,$0a5
	dc.w	$03c,$03c,$0b4,$0b4,$04b,$04b,$0c3,$0c3,$05a,$05a
	dc.w	$0d2,$0d2,$069,$069,$0e1,$0e1,$078,$078,$0f0,$0f0

	dc.w	$070,$070,$0e0,$0e0,$060,$060,$0d0,$0d0,$050,$050
	dc.w	$0c0,$0c0,$040,$040,$0b0,$0b0,$030,$030,$0a0,$0a0
	dc.w	$020,$020,$090,$090,$010,$010,$080,$080,$000,$000



bounce_offset	dc.w	0
bounce_table	incbin	bounce.pth


demo_keys
	dc.b	0, $02		;keyboard 1
	dc.b	1, $03		;   "     2
	dc.b	2, $04
	dc.b	3, $05
	dc.b	4, $06		;   "     5

	dc.b	0, $6d		;keypad 1
	dc.b	1, $6e
	dc.b	2, $6f
	dc.b	3, $6a
	dc.b	4, $6b		;   "   5

	dc.b	-1, -1
filenames
	dc.l	exec1
	dc.l	exec2
	dc.l	exec3
	dc.l	exec4
	dc.l	exec5


exec1	dc.b	"filename.1",0
	even
exec2	dc.b	"filename.2",0
	even
exec3	dc.b	"filename.3",0
	even
exec4	dc.b	"filename.4",0
	even
exec5	dc.b	"filename.5",0
	even

clock	dc.w	10

black	dcb.w	16,0

****************
 SECTION BSS
****************
screen_base	ds.l	1
		ds.l	1
scr_xor		ds.l	1
org_screen_base	ds.l	1
old_pal		ds.w	16
stack_save	ds.l	1

vsync_flag	ds.w	1
old_70		ds.l	1
old_120		ds.l	1
old_118		ds.l	1
a07_bak		ds.w	1
a09_bak		ds.w	1
a13_bak		ds.w	1
a17_bak		ds.w	1
key		ds.w	1

raster_pos	ds.l	1

	ds.b	256
screens	ds.b	32000
	ds.b	32000
