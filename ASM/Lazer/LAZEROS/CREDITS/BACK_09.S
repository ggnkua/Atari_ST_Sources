;Credits screen for dba-intro (Lazer/Dba)
;Don't blame us if the code is ugly, we were forced by aliens!!



 	OUTPUT	h:\dba\back.PRG

	jmp	main		;See the 3d-part for the exact docs
	bra	init_rout	;Only the vbl_rout is documented
	bra	exit_rout	;here...
	bra	do_once
	bra	do_vbl

;-----------------------------------------------------------
	include startup.s
	include	demo.s
;-----------------------------------------------------------
BLITTER = $ffff8a00

HALFTONE	= 0
SRC_XINC	= 32
SRC_YINC	= 34
SRC_ADDR	= 36
ENDMASK1	= 40
ENDMASK2	= 42
ENDMASK3	= 44
DST_XINC	= 46
DST_YINC	= 48
DST_ADDR	= 50
X_COUNT		= 54
Y_COUNT		= 56
HOP		= 58
OP		= 59
LINE_NUM	= 60
SKEW		= 61

FHOP_SOURCE	= 1
FHOP_HALFTONE	= 0
FSKEWFXSR	= 7
FSKEWNFSR	= 6
FLINEBUSY	= 7
FLINEHOG	= 6
FLINESMUDGE	= 5

MHOP_SOURCE	= $02
MHOP_HALFTONE	= $01
MSKEWFXSR	= $80
MSKEWNFSR 	= $40
MLINEBUSY	= $80
MLINEHOG	= $40
MLINESMUDGE	= $20


;-----------------------------------------------------------
main
	shrink_memory

	bsr	init
	save_stack
	bsr	phoenix_init

	save_interrupts
	set_interrupts

	move.w	#32/2,$ffff820e
	bsr	moir
	bsr	black

.main_loop
	move.l	scr1,d0
	move.l	scr2,scr1
	move.l	d0,scr2
	setscreen
	vsync
	
	lea	colors,a0
	lea	$ffff9800,a1
	move.w	#255,d0
.2	move.l	(a0)+,(a1)+
	dbf	d0,.2

	bsr	show_text	

	bsr	parallax
	

	tst.w	exit_flag
	beq.s	.exit

	move.b	key,old_key
	move.b	$fffffc02.w,key
	cmp.b	#$39,key
	bne	.main_loop

.exit

	restore_interrupts
	bsr	phoenix_exit
	restore_stack
	bsr	exit
	terminate
;-----------------------------------------------------------
init_rout
	move.l	a0,parameters

	move.l	parameters,a0
	move.l	WORK_SCREEN(a0),scr1
	move.l	SHOW_SCREEN(a0),scr2

	rts
;-----------------------------------------------------------
exit_rout
	rts
;-----------------------------------------------------------
do_once
	move.l	parameters,a0
	move.w	#2,SCREEN_COUNT(a0)	;this part uses 2 screens
	move.w	#TRUE,SCREEN_SWAP(a0)	;they are to be swapped

	move.l	parameters,a0
	move.w	#TRUE,PALETTE_UPDATE(a0) ;The palette is to be changed
	move.l	#colors,PALETTE(a0)

	move.l	parameters,a0
	lea	rgb_320x240x256_cin,a1  ; and change rez
	move.l	a1,SCRMODE(a0)
	move.w	#TRUE,SCRMODE_UPDATE(a0)

	move.l	parameters,a0
	move.l	WORK_SCREEN(a0),scr1
	move.l	SHOW_SCREEN(a0),scr2
	bsr	clrscr
	move.w	#32/2,$ffff820e
	bsr	black			; Some inits for this screen
	bsr	moir			; Place inits/precalcs here

ll	bra.s	ll

;-----------------------------------------------------------

;This Vbl-rout is called by the os. Care! Not rte at the end. 
;The os handles this for you.

do_vbl


	move.l	parameters,a0
	move.w	#TRUE,SCRMODE_UPDATE(a0)	
	lea	rgb_320x240x256_cin,a1
	move.l	a1,SCRMODE(a0)
	move.w	#TRUE,SCRMODE_UPDATE(a0)

	move.w	#32/2,$ffff820e

	move.l	parameters,a0
	move.l	WORK_SCREEN(a0),scr1
	move.l	SHOW_SCREEN(a0),scr2

	move.w	#TRUE,PALETTE_UPDATE(a0)
	move.l	#colors,PALETTE(a0)
	
	bsr	show_text	; And do your own effects routs

	bsr	parallax
	
	demo_swapscreens

	rts
;-----------------------------------------------------------
;-> a0...palette
set_palette

	lea	coltab3,a1
	move.w	#155,d0
.1	move.l	(a1)+,(a0)+
	dbf	d0,.1

	rts
;-----------------------------------------------------------
show_text

	add.w	#1,timer
	
	cmp.w	#2,timer
	bne.s	.1
	move.l	scr1,a0
	add.l	#(320+32)*20,a0
	add.w	#10,a0
	lea	text1,a1
	moveq	#0,d0		;x_skew
	bsr	set_blitter_t
	bsr	clr_dummen_pixel
.1
	cmp.w	#3,timer
	bne.s	.1a
	move.l	scr1,a0
	add.l	#(320+32)*20,a0
	add.w	#10,a0
	lea	text1,a1
	moveq	#0,d0		;x_skew
	bsr	set_blitter_t
	bsr	clr_dummen_pixel
.1a

	cmp.w	#10,timer
	blt.s	.2
	cmp.w	#150,timer
	bgt.s	.2
	bsr	fade_in_all
.2

	cmp.w	#600,timer
	blt.s	.3a
	cmp.w	#650,timer
	bgt.s	.3a
	bsr	fade_out	;1.mal ausblenden
.3a

	cmp.w	#652,timer
	bne.s	.4
	move.l	scr1,a0
	add.l	#(320+32)*20,a0
	add.w	#10,a0
	lea	text2,a1
	moveq	#0,d0		;x_skew
	bsr	set_blitter_t
.4
	cmp.w	#653,timer
	bne.s	.4a
	move.l	scr1,a0
	add.l	#(320+32)*20,a0
	add.w	#10,a0
	lea	text2,a1
	moveq	#0,d0		;x_skew
	bsr	set_blitter_t
.4a

	cmp.w	#660,timer
	blt.s	.5a
	cmp.w	#710,timer
	bgt.s	.5a
	bsr	fade_in
.5a

;----
	cmp.w	#900,timer
	blt.s	.8a
	cmp.w	#950,timer
	bgt.s	.8a
	bsr	fade_out	;2.mal ausblenden
.8a

	cmp.w	#952,timer
	bne.s	.9
	move.l	scr1,a0
	add.l	#(320+32)*20,a0
	add.w	#10,a0
	lea	text3,a1
	moveq	#0,d0		;x_skew
	bsr	set_blitter_t
.9
	cmp.w	#953,timer
	bne.s	.9a
	move.l	scr1,a0
	add.l	#(320+32)*20,a0
	add.w	#10,a0
	lea	text3,a1
	moveq	#0,d0		;x_skew
	bsr	set_blitter_t
.9a

	cmp.w	#960,timer
	blt.s	.aa
	cmp.w	#1010,timer
	bgt.s	.aa
	bsr	fade_in
.aa


	cmp.w	#1460,timer
	blt.s	.6a
	cmp.w	#1560,timer
	bgt.s	.6a
	bsr	fade_out_all
.6a

	cmp.w	#1600,timer
	bne.s	.22
	clr.w	exit_flag
.22
	rts
;-----------------------------------------------------------
clr_dummen_pixel

	move.l	scr1,a0
	add.l	#10,a0
	add.l	#(320+32)*192+16*14,a0
	move.l	#0,(a0)

	rts
;-----------------------------------------------------------
fade_in
	lea	coltab3,a1
	lea	colors,a0
	move.l	#1,d0		;1,3,7,15,...
	move.w	#255,anz
	bsr	xxxx
	rts
;-----------------------------------------------------------
fade_out

	lea	coltab2,a1
	lea	colors,a0
	move.l	#1,d0		;1,3,7,15,...
	move.w	#255,anz
	bsr	xxxx
	rts
;-----------------------------------------------------------
fade_in_all

	lea	coltab3,a1
	lea	colors,a0
	move.l	#1,d0		;1,3,7,15,...
	move.w	#255,anz
	bsr	xxxx
	rts
;-----------------------------------------------------------
fade_out_all

	lea	coltab1,a1
	lea	colors,a0
	move.l	#1,d0		;1,3,7,15,...
	move.w	#255,anz
	bsr	xxxx
	rts
;-----------------------------------------------------------
xxxx
	add.w	#1,fade_speed
	and.w	d0,fade_speed
	bne	.exit_fade

	move.w	#-1,d4

	moveq	#0,d1
	moveq	#0,d2

	move.w	anz,d0
.1
	move.l	(a0),temp_col

	move.b	(a0),d1
	and.b	#%11111100,d1
	move.b	(a1),d2
	and.b	#%11111100,d2
	cmp.w	d2,d1
	blt.s	.fade_up
	cmp.w	d2,d1
	bgt.s	.fade_down
	bra.s	.r_fade_ready
.fade_up
	clr.w	d4
	add.b	#$04,temp_col
	bra.s	.r_fade_ready
.fade_down
	clr.w	d4
	sub.b	#$04,temp_col
.r_fade_ready


	move.b	1(a0),d1
	and.b	#%11111100,d1
	move.b	1(a1),d2
	and.b	#%11111100,d2
	cmp.w	d2,d1
	blt.s	.fade_up2
	cmp.w	d2,d1
	bgt.s	.fade_down2
	bra.s	.g_fade_ready
.fade_up2
	clr.w	d4
	add.b	#$04,temp_col+1
	bra.s	.g_fade_ready
.fade_down2
	clr.w	d4
	sub.b	#$04,temp_col+1
.g_fade_ready

	move.b	3(a0),d1
	and.b	#%11111100,d1
	move.b	3(a1),d2
	and.b	#%11111100,d2
	cmp.w	d2,d1
	blt.s	.fade_up3
	cmp.w	d2,d1
	bgt.s	.fade_down3
	bra.s	.b_fade_ready
.fade_up3
	clr.w	d4
	add.b	#$04,temp_col+3
	bra.s	.b_fade_ready
.fade_down3
	clr.w	d4
	sub.b	#$04,temp_col+3
.b_fade_ready
	move.l	temp_col,(a0)+
	addq	#4,a1
	dbf	d0,.1

.exit_fade
	rts
;-----------------------------------------------------------
moir

	move.l	scr1,a0
	move.l	scr2,a1
	addq	#6,a0
	addq	#6,a1
	move.w	#%0101010101010101,d2

	move.w	#238,d1
.1
	not.w	d2
	moveq	#19,d0
.2	move.w	d2,(a0)
	move.w	d2,(a1)
	lea	16(a0),a0
	lea	16(a1),a1
	dbf	d0,.2
	lea	32(a0),a0
	lea	32(a1),a1
	dbf	d1,.1

	rts
;-----------------------------------------------------------
black

	move.l	scr1,a0
	move.l	scr2,a1
	addq	#8,a0
	addq	#8,a1
	move.w	#-1,d2

	move.w	#238,d1
.1
	moveq	#19,d0
.2	move.w	d2,(a0)
	move.w	d2,(a1)
	lea	16(a0),a0
	lea	16(a1),a1
	dbf	d0,.2
	lea	32(a0),a0
	lea	32(a1),a1
	dbf	d1,.1

	rts
;-----------------------------------------------------------
parallax

	lea	wave1,a2
	add.w	waveptr1,a2
	add.w	#4,waveptr1
	cmp.w	#4*360,waveptr1
	bne.s	.1
	clr.w	waveptr1
.1	move.l	scr1,a0
	sub.w	#16,a0
	lea	bitmap1,a1
	add.w	(a2),a1		;x_word
	move.w	2(a2),d0	;x_skew
	bsr	set_blitter
	
	
	lea	wave2,a2
	add.w	waveptr2,a2
	add.w	#4,waveptr2
	cmp.w	#4*360,waveptr2
	bne.s	.2
	clr.w	waveptr2
.2	move.l	scr1,a0
	addq	#2,a0
	sub.w	#16,a0
	lea	bitmap2,a1
	add.w	(a2),a1		;x_word
	move.w	2(a2),d0	;x_skew
	bsr	set_blitter

	lea	wave3,a2
	add.w	waveptr3,a2
	add.w	#4,waveptr3
	cmp.w	#4*360,waveptr3
	bne.s	.3
	clr.w	waveptr3
.3	move.l	scr1,a0
	addq	#4,a0
	sub.w	#16,a0
	lea	bitmap3,a1
	add.w	(a2),a1		;x_word
	move.w	2(a2),d0	;x_skew
	bsr	set_blitter

	rts
;-----------------------------------------------------------
set_blitter

	lea	BLITTER,a6

	move.w	#2,SRC_XINC(a6)
	move.w	#2+20*2,SRC_YINC(a6)
	move.w	#16,DST_XINC(a6)
	move.w	#16*3,DST_YINC(a6)
	move.b	#MHOP_SOURCE,HOP(a6)
	move.b	#3,OP(a6)
	move.l	a1,SRC_ADDR(a6)
	move.l	a0,DST_ADDR(a6)
	move.w	#20,X_COUNT(a6)
	move.w	#239,Y_COUNT(a6)
	move.w	#$ffff,ENDMASK1(a6)
	move.w	#$ffff,ENDMASK2(a6)
	move.w	#$ffff,ENDMASK3(a6)
	move.b	d0,SKEW(a6)

	move.b	#MLINEBUSY+MLINEHOG,LINE_NUM(a6)


	rts
;-----------------------------------------------------------
set_blitter_t

	lea	BLITTER,a6

	move.w	#2,SRC_XINC(a6)
	move.w	#2,SRC_YINC(a6)
	move.w	#16,DST_XINC(a6)
	move.w	#16*3,DST_YINC(a6)
	move.b	#MHOP_SOURCE,HOP(a6)
	move.b	#3,OP(a6)
	move.l	a1,SRC_ADDR(a6)
	move.l	a0,DST_ADDR(a6)
	move.w	#20,X_COUNT(a6)
	move.w	#199,Y_COUNT(a6)
	move.w	#$ffff,ENDMASK1(a6)
	move.w	#$ffff,ENDMASK2(a6)
	move.w	#$ffff,ENDMASK3(a6)
	move.b	d0,SKEW(a6)

	move.b	#MLINEBUSY+MLINEHOG,LINE_NUM(a6)


	rts
;-----------------------------------------------------------



;-----------------------------------------------------------
clrscr
	move.l	scr1,a5
	move.l	scr2,a6
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	move.l	d0,a0
	move.l	d0,a1
	move.l	d0,a2

	move.w	#489,d7
.1	
	rept	10
	movem.l	d0-d6/a0-a2,(a5)
	movem.l	d0-d6/a0-a2,(a6)
	lea	40(a5),a5
	lea	40(a6),a6
	endr
	dbf	d7,.1
	rts
;-----------------------------------------------------------
vbl

old_vbl	jmp	$12345678
	rte
;-----------------------------------------------------------
init
	clr_bss

	super_on
	mouse_off

	cache_on

        move.l  $44e.w,old_screen
	save_resolution

	move.l	#screens+256,d0
	clr.b	d0
	move.l	d0,scr1
	add.l	#384*240*2,d0
	move.l	d0,scr2
	add.l	#384*240*2,d0
	move.l	d0,scr3

	move.l	scr1,d0
	setscreen

	*lea	rgb_384x240x256,a0
	lea	rgb_320x240x256_cin,a0
	set_resolution

	move.l	#0,$ffff9800.w
        rts
;-----------------------------------------------------------
exit
	
	move.l	old_screen,d0
	setscreen
	restore_resolution

	mouse_on
	super_off
	rts
;-----------------------------------------------------------



;-----------------------------------------------------------
scr1		dc.l	0
scr2		dc.l	0
scr3		dc.l	0

exit_flag	dc.w	-1

timer		dc.w	0

waveptr1	dc.w	0
waveptr2	dc.w	0
waveptr3	dc.w	0

temp_col	dc.l	0
anz		dc.w	0
fade_speed	dc.w	0

xx		dc.w	1
;-----------------------------------------------------------
coltab3	
	dc.l	$0		;BG

	REPT	16
	dc.l	0
	ENDR

	REPT 2
	dc.l	$300020		
	dc.l	$0,0,$200030,$0,$280018,$0,$180018	;woobel
	ENDR

	REPT	(256-32)/8
	dc.l	$500040		
	dc.l	$200020,$200020,$400050,$200020,$480058,$200020,$380038	
				;text
	ENDR

	


coltab2	
	REPT	16
	dc.l	$0		;BG
	dc.l	$300040,0,$200030,$0,$280018,$0
	dc.l	$180018
	dc.l	$0,0,0,0,0,0,0,0	;moir
	ENDR

coltab1
	REPT	256
	dc.l	0
	ENDR

colors	
	REPT	256
	dc.l	-1
	ENDR

;-----------------------------------------------------------
bitmap1		incbin	daten\map1.dat
bitmap2		incbin	daten\map2.dat
bitmap3		incbin	daten\map3.dat

wave1		incbin	daten\wave1.dat
wave2		incbin	daten\wave2.dat
wave3		incbin	daten\wave3.dat

text1		incbin	code.dat
text2		incbin	rest.dat
text3		incbin	cred.dat
;-----------------------------------------------------------

	even

	section bss

	ds.l	1000
mystack		ds.l	0

start_bss
screens		ds.b	3*384*240*2+256
end_bss
