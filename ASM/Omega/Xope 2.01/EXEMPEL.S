; Xope example.
; Made by Micael Hildenborg.
; Omega.

; IMPORTANT!!!
; The routine waits until the X key has been released, if the routine
; halts, the try to press the X key.


; This example uses my standard main routine. Andthis routine feutures
; an error handler that can take a bug. If a bus, address or illegal
; instruction occurs, then the error handler restores all IRQs and
; hardware registers and jumps back to Devpac, and shows bombs.
; You can also make a reset back to Devpac, if a very serious error
; occur. But, this routine is not idiot safe...


*** Equostates ***

dator:		equ	0	; 0=tt, 1=ste
e_handle:		equ	0	; error handle on/off
prog:		equ	0	; .prg version on/off

		ifeq	dator
resreg:		equ	$ffff8262
		endc

		ifeq	dator-1
resreg:		equ	$ffff8260
		endc
	
*** Main start ***

start:
	move.w	#4,-(sp)
	trap	#14
	addq.w	#2,sp
	move.w	d0,res

	pea	init(pc)
	move.w	#38,-(Sp)
	trap	#14
	addq.w	#6,sp
	
	move.w	res,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	ifeq	prog
	move.w	#0,-(sp)
	move.w	#11,-(sp)
	trap	#13
	addq.w	#4,sp
	endc
	
	clr.w	-(sp)
	trap	#1
	
init:
	ifne	e_handle
	move.l	a7,stackp	
	endc
	
key_x_wait:
	move.w	#37,-(sp)
	trap	#14
	addq.w	#2,sp

	ifeq	prog
	move.b	$fffffc02.w,d0
	cmp.b	#$ad,d0		; x+$80
	bne.s	key_x_wait
	endc
	
	clr.b	resreg.w

	ifeq	dator
	movec	cacr,d0
	move.l	d0,cashe_reg
	movec	caar,d0
	move.l	d0,cashe_reg1
	movec	vbr,d0
	move.l	d0,vb_addr
	endc
	
	move.w	#$2700,sr

	movem.l	$64.w,d0-d6
	movem.l	d0-d6,l1_7i
	
	ifne	e_handle
	movem.l	$8.w,d0-d2
	movem.l	d0-d2,errors
	move.l	d0,b_error1+2
	move.l	d1,a_error1+2
	move.l	d2,ill_inst1+2
	move.l	$42a.w,resvec
	move.b	#7,$ffff8800.w
	move.b	$ffff8800.w,snd_cnfg
	move.b	#14,$ffff8800.w
	move.b	$ffff8800.w,snd_cnfg+1
	endc
	
	lea	mfp1dat,a0
	lea	$fffffa01.w,a1
	bsr	savemfp
	clr.b	$fffffa07.w
	clr.b	$fffffa13.w
	clr.b	$fffffa09.w
	clr.b	$fffffa15.w
	bclr	#3,$fffffa17.w

	ifeq	dator
	lea	mfp2dat,a0
	lea	$fffffa81.w,a1
	bsr	savemfp
	clr.b	$fffffa87.w
	clr.b	$fffffa93.w
	clr.b	$fffffa89.w
	clr.b	$fffffa95.w
	bclr	#3,$fffffa97.w
	endc

	lea	video,a0
	
	move.b	$ffff8201.w,(a0)+	
	move.b	$ffff8203.w,(a0)+	
	move.b	$ffff820d.w,(a0)+	
	move.b	$ffff820a.w,(a0)+	
	move.w	resreg.w,(a0)+	

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,(a0)
	lea	32(a0),a0

	ifeq	dator
	lea	$ffff8400.w,a1
	moveq	#127,d0
.loop1:
	move.l	(a1)+,(a0)+
	dbra	d0,.loop1
	endc
	
	move.l	#scrblock+255,d0
	clr.b	d0
	move.l	d0,screen
	move.l	d0,a0
	add.l	#32000,d0
	move.l	d0,screen+4
	
	move.l	#15999,d1
.loop2:
	clr.l	(a0)+
	dbra	d1,.loop2
	
	move.b	screen+1,$ffff8201.w
	move.b	screen+2,$ffff8203.w
	clr.b	$ffff820d.w

	lea	$64.w,a0
	lea	return,a1
	moveq	#6,d0
.loop3:
	move.l	a1,(a0)+
	dbra	d0,.loop3
	
	move.l	#vbl,$70.W

	ifne	e_handle
	move.l	#b_error,$8.w	
	move.l	#a_error,$c.w	
	move.l	#ill_inst,$10.w
	move.l	#reset,$42a.w
	move.l	#$31415926,$426.w
	endc

	lea	parameters,a0
	bsr	polygon_mupp	; Xope startup.
	move.l	a0,variabler	
	move.l	a1,hoppa
	move.l	a2,hoppa3
	move.l	a3,hoppa4

	move.w	#$2300,sr

.loop4:
	tst.w	vblflag
	beq.s	.loop4
	clr.w	vblflag

main_loop:
	lea	screen(pc),a0
	lea	4(a0),a1
	move.l	(a1),d0
	move.l	(a0),(a1)
	move.l	d0,(a0)
	move.b	2(a0),$ffff8203.w
	swap	d0
	move.b	d0,$ffff8201.w
	
	jsr	main

.loop:
	tst.w	vblflag
	beq.s	.loop
	clr.w	vblflag

	cmp.b	#$b9,$fffffc02.w	; space+$80
	bne.s	main_loop
	
ende:
	move.w	#$2700,sr
	
	ifeq	dator
	move.l	cashe_reg,d0
	movec	d0,cacr
	move.l	cashe_reg1,d0
	movec	d0,caar
	move.l	vb_addr,d0
	movec	d0,vbr
	endc

	movem.l	l1_7i,d0-d6
	movem.l	d0-d6,$64.w
	
	ifne	e_handle
	movem.l	errors,d0-d2
	movem.l	d0-d2,$8.w
	move.l	resvec,$42a.w
	clr.l	$426.w
	endc
	
	lea	mfp1dat,a0
	lea	$fffffa01.w,a1
	bsr	setmfp

	ifeq	dator
	lea	mfp2dat,a0
	lea	$fffffa81.w,a1
	bsr	setmfp
	endc

	lea	video,a0
	move.b	(a0)+,$ffff8201.w	
	move.b	(a0)+,$ffff8203.w	
	move.b	(a0)+,$ffff820d.w	
	move.b	(a0)+,$ffff820a.w	
	move.w	(a0)+,resreg.w	

	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,$ffff8240.w

	ifeq	dator
	lea	$ffff8400.w,a1
	moveq	#127,d0
.loop2:
	move.l	(a0)+,(a1)+
	dbra	d0,.loop2
	endc
	
	move.w	#$2300,sr
	rts
	
	
savemfp:
	moveq	#23,d0
.loop:
	move.b	(a1),(a0)+
	addq.w	#2,a1
	dbra	d0,.loop
	
	moveq	#0,d2
	move.w	#10000,d0
.loop1:
	move.b	-18(a1),d1
	cmp.b	d1,d2
	bhi.s	.jump
	move.b	d1,d2
.jump:
	dbra	d0,.loop1
	move.b	d2,(a0)+
	moveq	#0,d2
	move.w	#10000,d0
.loop2:
	move.b	-16(a1),d1
	cmp.b	d1,d2
	bhi.s	.jump1
	move.b	d1,d2
.jump1:
	dbra	d0,.loop2
	move.b	d2,(a0)+
	moveq	#0,d2
	move.w	#10000,d0
.loop3:
	move.b	-14(a1),d1
	cmp.b	d1,d2
	bhi.s	.jump2
	move.b	d1,d2
.jump2:
	dbra	d0,.loop3
	move.b	d2,(a0)+
	moveq	#0,d2
	move.w	#10000,d0
.loop4:
	move.b	-12(a1),d1
	cmp.b	d1,d2
	bhi.s	.jump3
	move.b	d1,d2
.jump3:
	dbra	d0,.loop4
	move.b	d2,(a0)+
	rts
	
setmfp:
	moveq	#23,d0
.loop:
	move.b	(a0)+,(a1)
	addq.w	#2,a1
	dbra	d0,.loop
	move.b	(a0)+,-18(a1)
	move.b	(a0)+,-16(a1)
	move.b	(a0)+,-14(a1)
	move.b	(a0)+,-12(a1)
	rts
		
*** Error handler:

	ifne	e_handle

b_error:
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	ende
	movem.l	(sp)+,d0-d7/a0-a6
b_error1:
	jmp	0

a_error:
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	ende
	movem.l	(sp)+,d0-d7/a0-a6
a_error1:
	jmp	0

ill_inst:
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	ende
	movem.l	(sp)+,d0-d7/a0-a6
ill_inst1:
	jmp	0

reset:
	move.w	#$2700,sr

	move.l	stackp,a7
	bsr	ende

	lea	pack,a1
	lea	$fffffc00.w,a0
	moveq	#3,d0
.loop:
	move.b	(a0),d1
	btst	#1,d1
	beq.s	.loop
	move.b	(a1)+,2(a0)
	dbra	d0,.loop
	
	moveq	#127,d0
.loop1:
	move.w	#999,d1
.loop2:
	nop
	dbra	d1,.loop2
	move.b	2(a0),d1
	dbra	d0,.loop1

	dc.w	$a000
	
	move.b	#7,$ffff8800.w
	move.b	snd_cnfg,$ffff8802.w
	move.b	#14,$ffff8800.w
	move.b	snd_cnfg+1,$ffff8802.w
	rts
	
	endc
	
*** Interrupt area ***	

vbl:
	move.w	#-1,vblflag
	rte	

return:
	rte
	

*** Main area ***


main:
	tst.b	$ffff8209.w		; test if visible scanline.
	beq.s	main
	
	move.w	#$30,$ffff8240.w

;	bsr	clear_screen		; clear screen

*******************************************
; Main loop
*******************************************

	move.l	variabler,a0
	
	move.w	#$203,(a0)+		; Three edges, both sides visible.
	move.w	#$000,(a0)+		; bitplane 0
	
	move.w	#0,(a0)+
	move.w	#0,(a0)+
	
	move.w	#100,(a0)+
	move.w	#10,(a0)+

	move.w	#150,(a0)+
	move.w	#100,(a0)+

	move.l	hoppa,a0
	jsr	(a0)
	
	move.w	#$fff,$ffff8240.w
	rts
	
*** clear screen 320*200*4 ***

clear_screen:
	ifeq	dator
	move.l	screen,a0
	move.w	#7999,d0
.loop:
	clr.l	(a0)+
	dbra	d0,.loop
	endc
	
	ifeq	dator-1
	move.w	#2,$ffff8a2e.w
	move.w	#16000,$ffff8a36.w
	clr.b	$ffff8a3b.w
	move.l	screen,$ffff8a32.w
	move.w	#1,$ffff8a38.w
	move.b	#192,$ffff8a3c.w
	endc
	rts

*** Data section ***

pack:	dc.b	$80,$1,$12,$1a

variabler:	dc.l	0
hoppa:		dc.l	0
hoppa3:		dc.l	0
hoppa4:		dc.l	0

parameters:
	dc.w	0
	dc.l	buffert
	dc.l	screen
	dc.w	0,0,-1000
	dc.w	319,199,1000

polygon_mupp:
	incbin	"e:\sources\polygons\bin\xope2_01.img"

	section bss

	ds.l	4096


	ifne	e_handle
errors:		ds.l	3
resvec:		ds.l	1
stackp:		ds.l	1
snd_cnfg:		ds.w	1
	endc


cashe_reg:	ds.l	1
cashe_reg1:	ds.l	1
vb_addr:		ds.l	1
res:		ds.w	1
video:		ds.w	275
l1_7i:		ds.l	7
mfp1dat:		ds.b	28
mfp2dat:		ds.b	28
savesp:		ds.l	1	

screen:		Ds.l	2
vblflag:		ds.w	0

scrblock:	
	ds.l	16000+64

buffert:
	ds.l	131*256
