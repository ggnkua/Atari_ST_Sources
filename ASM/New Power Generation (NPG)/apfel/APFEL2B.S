	section text
FALSE		equ	0
TRUE		equ	-1
XRES		equ	320*2
YRES		equ	240*2

main:
	move.l	4(a7),a3		base page
	move.l	$c(a3),d0		text len
	add.l	$14(a3),d0		data len
	add.l	$1c(a3),d0		BSS len
	add.l	#$100,d0		basepage
	move.l	d0,-(sp)
	move.l	a3,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1			shrink memory
	lea	12(sp),sp
	pea     prg(pc)
	move.w  #38,-(sp)
	trap    #14
	addq.l  #6,sp
	clr	-(sp)
	trap	#1
;****************************************************************
prg:
	jsr	open_screen
	tst.w	d0
	beq.s	.forget_it
	jsr	init_dsp
	tst.w	d0
	beq.s	.forget_it
	jsr	make_colors
	jsr	make_fractal
	jsr	show_fractal
.main_loop:
	jsr	zoom
	tst	exit
	bne.s	.exit
 	jsr	make_fractal
	jsr	show_fractal
	jsr	show_kreuz
	bra.s	.main_loop
.exit:
	jsr	close_dsp
.forget_it:
	jsr	close_screen
	rts
;****************************************************************
show_kreuz:
	move.l	ScreenAdr,a0
	add.l	#240*640,a0
	move.l	#640/16-1,d0
.xloop:
	eor.l	#-1,6(a0)
	lea	16(a0),a0
	dbra	d0,.xloop
	move.l	ScreenAdr,a0
	add.l	#640/2,a0
	move.l	#480-1,d0
.yloop:
	eor.l	#$80008000,6(a0)
	lea	640(a0),a0
	dbra	d0,.yloop
	rts

;****************************************************************
zoom:
	move.l	realmax,d7
	sub.l	realmin,d7
	asr.l	d7
	move.l	imagmax,d6
	sub.l	imagmin,d6
	asr.l	d6
	move.b	$fffffc02.w,d0
	cmp.b	#57,d0
	beq	.exit
	cmp.b	#1,d0
	bne.s	.next0
 	rts
.next0:
	cmp.b	#59,d0
	bne.s	.next1
	lea	puffer,a0
	add.w	#32,maxzahl
	sub.l	d7,realmax
	sub.l	d6,imagmax
 	rts
.next1:
	cmp.b	#60,d0
	bne.s	.next2
	lea	puffer,a0
	lea	XRES(a0),a0
	add.w	#32,maxzahl
	add.l	d7,realmin
	sub.l	d6,imagmax
 	rts
.next2:
	cmp.b	#61,d0
	bne.s	.next3
	lea	puffer,a0
	add.l	#XRES*YRES,a0
	add.w	#32,maxzahl
	sub.l	d7,realmax
	add.l	d6,imagmin
	rts
.next3:
	cmp.b	#62,d0
	bne.s	.next4
	lea	puffer,a0
	add.l	#XRES*YRES+XRES,a0
	add.w	#32,maxzahl
	add.l	d7,realmin
	add.l	d6,imagmin
	rts
.next4:
	bra	zoom
.exit:
	move.w	#-1,exit
	rts
exit:	dc.w	0
;****************************************************************
make_colors:
	lea	$ffff9800.w,a0
	moveq	#0,d0
.red_loop:
	move.l	d0,d1
	lsl.w	#8,d1
	lsl.w	#2,d1
	swap	d1
	move.l	d1,(a0)+
	addq	#1,d0
	cmp.w	#64,d0
	bne.s	.red_loop
	moveq	#0,d0
.green_loop:
	moveq	#63,d2
	sub.w	d0,d2
	lsl.w	#8,d2
	lsl.w	#2,d2
	move.l	d0,d1
	lsl.w	#2,d1
	or.w	d2,d1
	swap	d1
	clr	d1
	move.l	d1,(a0)+
	addq	#1,d0
	cmp.w	#64,d0
	bne.s	.green_loop
	
	moveq	#0,d0
.blue_loop:
	moveq	#63,d2
	sub.w	d0,d2
	lsl.w	#2,d2
	swap	d2
	clr	d2
	move.l	d0,d1
	lsl.w	#2,d1
	or.l	d2,d1
	move.l	d1,(a0)+
	addq	#1,d0
	cmp.w	#64,d0
	bne.s	.blue_loop
	moveq	#63,d0
.yellow_loop:
	move.l	d0,d1
	lsl.w	#2,d1
	move.l	d1,(a0)+
	subq	#1,d0
	bpl.s	.yellow_loop
	rts
;****************************************************************
open_screen:
;0:Reserviert
;f:Interlace
;s:ST-Kompatibel
;o:Overscan
;p:50hz=1
;v:vga-switch
;8:640 Punkte
;nnn:Farbebenen:1,2,4,8,16/0,1,2,3,4

;First get Screen Memory in st ram !
;Mxalloc
	move.w	#0,-(sp)
	move.l	#XRES*YRES+10000,-(sp)
	move.w	#68,-(sp)
	trap	#1
	lea	8(sp),sp
	cmp.l	#0,d0
	bgt.s	.found_mem
	move.l	#XRES*YRES+10000,-(sp)
	move.w	#72,-(sp)
	trap	#1
	lea	6(sp),sp
	cmp.l	#0,d0
	bgt.s	.found_mem
	clr.l	d0
	rts
.found_mem:

	move.l	d0,my_screen

	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,oldphyscreen

	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,oldlogscreen

	move.w  #-1,-(sp)
	move.l	my_screen,d0
	and.l	#$fffffff0,d0
	add.l	#$10,d0
	move.l	d0,Screen1
	move.l	d0,ScreenAdr
	move.l	d0,-(sp)
	move.l	d0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
 
	move.w  #-1,-(sp)
	move.w  #88,-(sp)
	trap    #14
	addq.l  #4,sp
	move.w	d0,oldmode
	move.w	d0,d7
	and.w	#$fff8,d7
	;		  0000000fsopv8nnn
	and.w	#%0111111000000000,d7
	or.w	#%1000000100001011,d7
	move.w  #89,-(sp)
	trap	#14
	addq.l	#2,sp
	cmp.w	#2,d0
	bne.s	.no_VGA
	eor.w	#%100010000,d7
.no_VGA:
	move.w	d7,-(sp)
	move.w  #88,-(sp)
	trap    #14
	addq.l  #4,sp 
	lea	$ffff9800.w,a1
	lea	save_color,a0
	move.w	#255,d0
.copy:
	move.l	(a1)+,(a0)+
	dbra	d0,.copy
	jsr	cls_screen
	move.l	#-1,d0
	rts
;****************************************************************
cls_screen:
	move.l	ScreenAdr,a0
	move.l	#XRES*YRES/4-1,d0
	moveq	#0,d1
.cls_loop:
	move.l	d1,(a0)+
	subq.l	#1,d0
	bne.s	.cls_loop
	rts
;****************************************************************
init_dsp:
	move.w	#104,-(sp)
	trap	#14
	addq.l	#2,sp	;Dsp_Lock
	tst.w	d0
	bmi.s	.forget_it
	pea	dsp_puffer
	clr.w	-(sp)
	pea	lod_name
	move.w	#108,-(sp)
	trap	#14		;dsp_load_prg
	add.l	#12,sp
	tst.w	d0
	bmi.s	.forget_it
	moveq	#TRUE,d0
	rts
.forget_it:
	moveq	#FALSE,d0
	rts
close_dsp:
	move.w	#105,-(sp)
	trap	#14		;dsp_unlock
	addq.l	#2,sp	;Dsp_Lock
	rts
;*********************************************************
show_fractal:
	move.l	ScreenAdr,a1
	lea	puffer,a0
	move.w	#YRES-1,d6
.yloop:
	moveq	#XRES/16-1,d7
.xloop:
	moveq	#16/2-1,d5
.wloop:
 	move.w	(a0)+,d0
 	rept	2
	add.w	d0,d0
	addx.w	d4,d4
	swap	d4
	add.w	d0,d0
	addx.w	d4,d4
	swap	d4
	
	add.w	d0,d0
	addx.w	d3,d3
	swap	d3
	add.w	d0,d0
	addx.w	d3,d3
	swap	d3
	
	add.w	d0,d0
	addx.w	d2,d2
	swap	d2
	add.w	d0,d0
	addx.w	d2,d2
	swap	d2
	
	add.w	d0,d0
	addx.w	d1,d1
	swap	d1
	add.w	d0,d0
	addx.w	d1,d1
	swap	d1
	endr
	
	dbra	d5,.wloop
	movem.l	d1-d4,(a1)
	lea		16(a1),a1
	dbra	d7,.xloop
	dbra	d6,.yloop
	rts
;*********************************************************
make_fractal:
	lea		$ffffa202.w,a0         ;DSP ready

	move.l	ScreenAdr,a5
	jsr		rechne_delta
FIRST:		

	move.w	#YRES/2-1,d6
	lea		puffer,a6
	move.l	realdelta,d4
	lsl.l	d4
	move.l	imagdelta,d5
	lsl.l	d5
	move.l	imagmin,d1
.yloop:
	move.l	realmin,d0
	move.w	#XRES/2-1,d7
.xloop:
	jsr		START_ITERATION
	move.b	d2,(a6)
	addq.l	#2,a6
	add.l	d4,d0
	dbra	d7,.xloop
	add.l	d5,d1
	lea		XRES(a6),a6
	move.l	#-1,4(a5)
	clr.l	(a5)
	clr.l	8(a5)
	clr.l	12(a5)
	lea		XRES(a5),a5
	dbra	d6,.yloop
	move.l	ScreenAdr,a5
SECOND:		
	lea		puffer,a6
	move.w	#YRES/2-1,d6
	move.l	imagmin,d1
.yloop:
	move.l	realmin,d0
	add.l	realdelta,d0
	move.w	#XRES/2-1,d7
.xloop:
	move.b	(a6),d2
	cmp.b	2(a6),d2
	beq.s	.same
	
	jsr		START_ITERATION
.same:
	move.b	d2,1(a6)
	addq.l	#2,a6
	
	add.l	d4,d0
	dbra	d7,.xloop
	
	add.l	d5,d1
	lea		XRES(a6),a6
	move.l	#-1,8(a5)
	lea		XRES(a5),a5
	dbra	d6,.yloop
	
	move.l	ScreenAdr,a5
THIRD:	
	lea		puffer,a6
	move.w	#YRES/2-1,d6
	move.l	realdelta,d4
	move.l	imagmin,d1
	add.l	imagdelta,d1
.yloop:	
	move.l	realmin,d0
	move.w	#XRES-1,d7
.xloop:
	move.b	(a6),d2
	cmp.b	XRES*2(a6),d2
	beq.s	.same
	jsr		START_ITERATION
.same:
	move.b	d2,XRES(a6)
	addq.l	#1,a6
	add.l	d4,d0
	dbra	d7,.xloop
	
	add.l	d5,d1
	lea		XRES(a6),a6
	move.l	#-1,12(a5)
	move.l	#-1,(a5)
	lea	XRES(a5),a5
	dbra	d6,.yloop
	
	rts
;---------------------------------------------------------
;Iterationsschleife:
;šbergabe: 
;		Realzahl=d0
;		Imagzahl=d1
START_ITERATION:		
	moveq	#0,d2
	move.w	maxzahl,d2
.wait3:	
	btst 	#1,(a0)         ;DSP ready
	beq.s	.wait3
	move.l	d2,2(a0)
	
.wait1:	
	btst 	#1,(a0)
	beq.s	.wait1
	move.l	d0,2(a0)

.wait2:	
	btst 	#1,(a0)
	beq.s	.wait2
	move.l	d1,2(a0)
.waitr:	
	btst 	#0,(a0)
	beq.s	.waitr
	move.l	2(a0),d2
.exit:	
	rts
;---------------------------------------------------------
;Berechnung der delta's
rechne_delta:
	move.l	realmax,d0
	sub.l	realmin,d0
	divs.l	#XRES,d0
	move.l	d0,realdelta

	move.l	imagmax,d0
	sub.l	imagmin,d0
	divs.l	#YRES,d0
	move.l	d0,imagdelta
	rts
;***************************************************************
close_screen:
	
	lea		$ffff9800.w,a0
	lea		save_color,a1
	move.w	#255,d0
.copy:
	move.l	(a1)+,(a0)+
	dbra	d0,.copy
	move.w	oldmode,-(sp)
	move.w  #88,-(sp)
   	trap    #14
	addq.l  #4,sp 
	move.w	#-1,-(sp)
	move.l	oldphyscreen,-(sp)
	move.l	oldlogscreen,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts
;*********************************************************
		section data
;2^21
realmin:	dc.l	$ffc00000	;-2
realmax:	dc.l	$00266666	;1.2
imagmin:	dc.l	$ffd80000	;-1.25
imagmax:	dc.l	$00280000	;1.25

maxzahl:	dc.w	128		;Iterationstiefe
realdelta:	dc.l	0		;muž noch berechnet werden
imagdelta:	dc.l	0
anz_iterations:	dc.w	0
;*********************************************************
	
lod_name:	dc.b	"apfel2.lod",0
	even
configuration:	dc.w	0
;****************************************************************
		section bss
save_color:	ds.l	256
my_screen:	ds.l	1
Screen1:	ds.l	1	;prepare Screen
ScreenAdr:	ds.l	1
oldmode:	ds.w	1
oldphyscreen:	ds.l	1
oldlogscreen:	ds.l	1
dsp_puffer:	ds.l	1000
puffer:		ds.b	XRES*YRES
;***********************************************************************************
; Code: Roland Spatzenegger
