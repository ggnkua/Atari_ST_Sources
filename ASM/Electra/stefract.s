;****************************************
;** Fractal scroller for the STE       **
;** Coded by Jesper Rudberg 	   **
;**			   **
;** Use arrow keys to scroll.
;** Keys 1-5 change colors.
;** While the screen is blue it's
;** Calculating. 0 to 40 minutes depending 
;** on the size and depth.
;**
;** It simply lays the fractal in 
;** memory and you can scroll around
;** and have a look at Mandelbrot.
;**
;** Don't blame me if it bombs out
;** becuase it was my first one so
;** all the routs can be very inflexible 
;** and bad coded. 
;**
;** Have fun with it. It's Public Domain!!!!!!
;** When you make a better version please sread 
;** the sources it's more fun for everybody!!!
;**              
;** Cange left,right,top,bottom to ZOOM not the zoom variables!!!!
;**
;**     Kasper of Electra
;**
;**********************************************************************
zoom	equ 	4096		egentligen 2^zoom2
zoom2	equ 	12		flyttals utj„mning???
;*****************************************************************
left	equ	-25000*zoom/10000   	this is the zooms
right	equ	5000*zoom/10000
top	equ	-11500*zoom/10000
bottom	equ	11500*zoom/10000

it_nr	equ	24		Depth 
max_x	equ	320*2		X-size
max_y	equ	200*2		Y-size
;******************************************************************


	clr.w	-(sp)		super
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,-(sp)

	move.w	#37,-(sp)		wait for vbl
	trap	#14
	addq.l	#2,sp
	move.b	#0,$ff8260		low res

	move.l	#scr,d5		s„tt min screen
	add.l	#256,d5
	;move.b	#0,d5		
	move.l	d5,screen		save screen address
	lsr.l	#8,d5
	move.b	d5,$ff8203		middle byte
	lsr.l	#8,d5
	move.b	d5,$ff8201		high byte


	move.l	screen,a0		clr screen
	move.l	#1280*max_y/2,d0
	moveq	#0,d1
cs	move.b	d1,(a0)+
	sub.l	#1,d0
	bge	cs
	

	jsr	drw_clc		init draw
	jsr	mk_tt		init x scroll 
	
	lea	start_a0(pc),a0	ladda mainpekare
	move.l	#right,a4		y start
	move.l	#bottom,a5		x start
	move.l	#left,d1		y slut 
	move.l	#top,d2		x slut 
	sub.l	a4,d1
	divs	#max_x,d1		x diff
	sub.l	a5,d2		
	divs	#max_y,d2		y diff
	move.w	d1,8(a0)		spara diffs
	move.w	d2,10(a0)
	
	move.w	#max_y-1,d5		
y_loop	move.w	#max_x-1,d6
x_loop	jsr	iter		calc point
	jsr	draw		draw point
	add.w	8(a0),a4		”ka x	
	dbf	d6,x_loop
	
	move.w	#right,a4		x reset
	add.w	10(a0),a5		”ka y
	cmp.b	#$39,$fffffc02	space?
	beq.s	wait
	dbf	d5,y_loop		
				
	lea	$ffff8240.w,a0	load colors
	movem.l	pal3,d0-d7	
	movem.l	d0-d7,(a0)	
	
wait	move.b	3(a0),$ff8201	high byte
	move.b	4(a0),$ff8203	middle byte
	move.b	5(a0),$ff820d	low byte
	move.w	#37,-(sp)		wait for vbl
	trap	#14
	addq.l	#2,sp
	lea	scr_dat(pc),a0
	move.w	(a0),$ff8264	scr pix
	move.w	6(a0),$ff820e	resten
	
	lea	x_sct(pc),a1	
	add.w	8(a0),a1		right x-scroll
	move.w	(a1)+,(a0)		update scroll registers
	move.l	(a1)+,2(a0)
	move.w	(a1)+,6(a0)
	move.l	10(a0),d0		+y-scroll
	add.l	d0,2(a0)
	
	
	
	cmp.b	#$4b,$fffffc02	left cursor?
	bne	not_h
	add.w	#8,8(a0)		go left!
	cmp.w	#320*4*6,8(a0)	to big?
	ble	not_h	
	sub.w	#8,8(a0)		go back

not_h	cmp.b	#$4d,$fffffc02	right cursor?
	bne	not_v
	sub.w	#8,8(a0)		go right!
	tst.w	8(a0)		to small?
	bge	not_v
	add.w	#8,8(a0)		go back

not_v	cmp.b	#$50,$fffffc02	cursor down?
	bne 	not_n
	add.l	#160*4,10(a0)	go down
	cmp.l	#max_y*160*4,10(a0)	bottom?
	ble	not_n
	sub.l	#160*4,10(a0)	go back
	
not_n	cmp.b	#$48,$fffffc02	cursor up?
	bne 	not_u
	sub.l	#160*4,10(a0)	go up
	tst.l	10(a0)		top?
	bge	not_u
	add.l	#160*4,10(a0)	go back
not_u	cmp.b	#2,$fffffc02	1?
	bne 	not_1
	lea	$ffff8240.w,a0	load pal
	movem.l	pal,d0-d7	
	movem.l	d0-d7,(a0)	
not_1	cmp.b	#3,$fffffc02	2?
	bne 	not_2
	lea	$ffff8240.w,a0	load pal2
	movem.l	pal2,d0-d7	
	movem.l	d0-d7,(a0)	
not_2	cmp.b	#4,$fffffc02	3?
	bne 	not_3
	lea	$ffff8240.w,a0	load pal3
	movem.l	pal3,d0-d7	
	movem.l	d0-d7,(a0)	
not_3	cmp.b	#5,$fffffc02	4?
	bne 	not_4
	lea	$ffff8240.w,a0	load pal4
	movem.l	pal4,d0-d7	
	movem.l	d0-d7,(a0)	
not_4	cmp.b	#6,$fffffc02	5?
	bne 	not_5
	lea	$ffff8240.w,a0	load pal5
	movem.l	pal5,d0-d7	
	movem.l	d0-d7,(a0)	
not_5

	cmp.b	#$39,$fffffc02	space?
	bne	wait
	move.w	#$003,$ff8240	color reset
	move.w	#$777,$ff8246

	move.w	#0,$ff820c		reset scroll
	move.w	#0,$ff820e
	move.w	#0,$ff8264

	
	clr.w	-(sp)
	trap	#1

;*************************
;* Makes x-scroll table **
;***************************************
mk_tt	lea	x_sct(pc),a0	
	move.l	screen,d5		
	move.w	#80-1,d4		width in words
s_2	move.l	#80*3,d2		rest of screen
	move.w	#16-1,d0		
s_1	move.w	d0,d1		get counter
	sub.w	#16-1,d1		upside down
	neg	d1
	move.w	d1,(a0)+		save pixel
	cmp.w	#1,d1 		1 pixel?
	bne	dd 
	sub.w	#4,d2		
	 	
dd	move.l	d5,(a0)+		save byte
	move.w	d2,(a0)+
	dbf	d0,s_1
	add.l	#8,d5		scoll 16 pix
	dbf	d4,s_2
	rts
;***********************************
iter	move.l	#0,d1		clr re
	move.l	d1,d2		clr im		
	move.l	d1,a2		clr im
	moveq	#zoom2,d7		
	moveq	#it_nr-1,d0
	
go_on	sub.l	d2,d1		a^2+(b*i)^2
	asr.l	d7,d1		lite mindre
	add.w	a4,d1		+re pos=klar re
	
	move.w	a2,d2		h„mta old re
	move.w	d1,a2		spara ny re
	
	add.w	d2,d2		2*a
	muls	d4,d2		*b
	asr.l    	d7,d2		lite mindre
	add.w	a5,d2		klar im
	move.w	d2,d4		spara ny im		
	
	muls	d1,d1		a^2
	muls	d2,d2		b^2		
	move.l	d2,d3		
	add.l	d1,d3	
	cmp.l	#4*zoom*zoom,d3	
	ble.s	aa
	rts

aa	dbf	d0,go_on
	rts
;**************
;* Draw point *
;***************************************************
draw	move.w	d6,d1		x
	move.w	d5,d2		y
	add.w	#1,d0		f„rg
	
	move.l	screen,a3
	
	lea 	x_preps(pc),a2	x_preps tabellen i a2
	add.w	d1,d1		x
	add.w	d1,d1		x
	add.w	d1,a2		x till x
	move.w	(a2)+,d1		get or v„rde
	add.w	(a2),a3		get x-byte
	
	lea	y_preps(pc),a2	y_preps tabellen i a2
	add.w	d2,d2		y
	add.w	d2,d2		y
	add.w	d2,a2		y till y
	add.l	(a2),a3
	
	add.w	d0,d0		f„rg *4=r„tt rout
	add.w	d0,d0
	lea	routs(pc),a2	
	add.w	d0,a2		
	move.l	(a2),a2
	jmp	(a2)		rita!!
	
;********************
;*  Make draw table *
;********************************************
;** y ***********************************
drw_clc	lea	y_preps(pc),a0
	move.l	#max_y-1,d0		200 rader
dr_cy	move.l	d0,d2		
	sub.w	#max_y-1,d2
	neg	d2
	muls	#160*4,d2		160 bytes per rad
	move.l	d2,(a0)+		spara till y_preprtabellen
	dbf	d0,dr_cy
;** x ***********************************
	lea	x_preps(pc),a0
	move.l	#320*4-1,d0		320 pixels per rad
dr_cx	move.l	d0,d2		
	sub.w	#320*4-1,d2
	neg	d2
	divu	#16,d2		
	move.l	d2,d3		spara d2
	lsl.w	#3,d3		*8(ratt byte/word)	
		
	swap	d2
	move.w	#15,d4		
	sub.w	d2,d4		15-d2(ratt bit (omvant))
	move.w	#1,d2		
	lsl.w	d4,d2		ratt or varde
	swap	d2		or vardet overst
	move.w	d3,d2		byte vardet underst
	move.l	d2,(a0)+		spara i x_prepstabellen
	dbf	d0,dr_cx
	rts	
;*******************************************************************	
routs	dc.l	draw15,draw14,draw13,draw12,draw11
	dc.l	draw10,draw8,draw8,draw7,draw6,draw5
	dc.l	draw4,draw3,draw2,draw1,draw0,draw0
	dc.l	draw0,draw0,draw0,draw0,draw0,draw0
	dc.l	draw0,draw0,draw0,draw0,draw0,draw0
	dc.l	draw0,draw0,draw0,draw0,draw0,draw0
;*******************************************************************	
draw0	rts			color 0

draw1	or.w	d1,(a3)		color 1
	rts		
draw2	or.w	d1,2(a3)		color 2
	rts	
draw3	or.w	d1,(a3)+		color 3
	or.w	d1,(a3)
	rts	
draw4	or.w	d1,4(a3)		color 4
	rts	
draw5	or.w	d1,(a3)		color 5
	or.w	d1,4(a3)
	rts			
draw6	or.w	d1,2(a3)		color 6
	or.w	d1,4(a3)
	rts	
draw7	or.w	d1,(a3)+		color 7
	or.w	d1,(a3)+
	or.w	d1,(a3)
	rts
draw8	or.w	d1,6(a3)		color 8
	rts	
draw9	or.w	d1,(a3)		color 9
	or.w	d1,6(a3)
	rts	
draw10	or.w	d1,2(a3)		color 10
	or.w	d1,6(a3)
	rts	
draw11	or.w	d1,(a3)		color 11
	or.w	d1,2(a3)
	or.w	d1,6(a3)
	rts	
draw12	or.w	d1,4(a3)		color 12
	or.w	d1,6(a3)
	rts	
draw13	or.w	d1,(a3)		color 13
	or.w	d1,4(a3)
	or.w	d1,6(a3)
	rts	
draw14	or.w	d1,2(a3)		color 14
	or.w	d1,4(a3)
	or.w	d1,6(a3)
	rts	
draw15	or.w	d1,(a3)+		color 15
	or.w	d1,(a3)+
	or.w	d1,(a3)+
	or.w	d1,(a3)	
	rts	
;*******************************************************************	
start_a0
re	dc.w 	0	0(a0)
im	dc.w	0	2(a0)
z_re	dc.w	0	4(a0)
z_im	dc.w	0 	6(a0)
re_del	dc.w	0 	8(a0)
im_del	dc.w	0	10(a0)

scr_dat	
hscroll	dc.w	0	(a0)
screen	dc.l	0	2(a0)
linewid	dc.w	80*3	6(a0)
x_pos	dc.w	0	8(a0)
y_pos	dc.l	0
	
pal	dc.w	$f00,$700,$e00,$600,$d00,$500,$c00,$400
	dc.w	$b00,$300,$a00,$200,$900,$100,$800,$000
pal2	dc.w	$000,$800,$100,$900,$200,$a00,$300,$b00
	dc.w	$400,$c00,$500,$d00,$600,$e00,$700,$f00
pal3	dc.w	$000,$080,$010,$090,$020,$0a0,$030,$0b0
	dc.w	$040,$0c0,$050,$0d0,$060,$0e0,$070,$0f0
pal4	dc.w	$000,$880,$110,$990,$220,$aa0,$330,$bb0
	dc.w	$440,$cc0,$550,$dd0,$660,$ee0,$770,$ff0
pal5	dc.w	$000,$808,$101,$909,$202,$a0a,$303,$b0b
	dc.w	$404,$c0c,$505,$d0d,$606,$e0e,$707,$f0f
	section bss
x_sct	ds.w	320*4*4
y_preps	ds.w	200*10	
x_preps	ds.l	320*10
scr	ds.b	max_x*max_y/2	
