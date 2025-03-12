; Byte errr ...'Word' bender coded by Tony B!
; Based on a poor explanation in another well known ST Disk Mag..!!
; Written by Tony Bennett using Devpac v2.25
; tabs =10


width		=	9	;in bytes/8
height		=	32
tab_len		=	(53*8)-30	;amount of word values in table-1



	opt	x+,o+,ow-


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

	clr.b	$ffff8260.w
	move.l	$44e.w,old44e
	move.l	#$70000,d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w
	
	move.l	#gfx+4,$45a.w
	
	lea	$70000,a0
clr	clr.l	(a0)+
	cmpa.l	#$78000,a0
	blt.s	clr

*---------
scan	move.l	$466.w,d0
vs	cmp.l	$466.w,d0
	beq.s	vs

	move	#$700,$ffff8240.w	;CPU time taken, in red!
	bsr.s	bender
	clr	$ffff8240.w
	
	cmp.b	#$39,$fffffc02.w
	bne.s	scan
*---------

	move.b	#8,$fffffc02.w
	move.l	#gempal,$45a.w
	move.l	old44e(pc),d0
	lsr	#8,d0
	move.l	d0,$ffff8200.w
	
	move.l	old_stk(pc),-(sp)
	move	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	
	clr	-(sp)
	trap	#1


*---------calc the screen offsets for each 16 pixel block!

bender	lea	sine_wave(pc),a0	;sine wave
	move	(a0),d2		;store for clear offset
	lea	putline+2(pc),a1	;self modifying code addr
	moveq	#0,d0
	
	rept	width
	move	(a0)+,d1		;get offset
	add	d0,d1		;screen offset
	move	d1,(a1,d0)	;new offset in planes 1,2
	addq	#4,d1		;next instruction (same word)
	addq	#4,d0		;advance 8 pixels
	move	d1,(a1,d0)	;same offset in planes 3,4
	
	addq	#4,d0		;advance 8 pixels more =1 word
	endr

*---------rotate whole wave table backwards by 1 word for next time!
*---------this is how we get new addresses every vbi for each block
*---------of the logo....geddit!!? (A block being 16 pixels, of course!)

	lea	sine_wave(pc),a0	;wrap around offset table!
	move	(a0),d0		;store 1st value cos it gets
	rept	tab_len/2		;wiped over on the next instruction
	move.l	2(a0),(a0)+	;second value back one
	endr			;and so on ....
	move	d0,(a0)		;1st value back in position

*---------clear gfx!
*---------this clear rout., although not optimized, ain't too bad
*---------when you think about it...huh!?

wave	lea	$70000+(160*40)+40,a0;screen addr
	lea	160*5(a0),a2	;base of draw addr
	add	d2,a0		;new base of clear addr
	
	moveq	#height+25-1,d0	;the plus value should be the
				;largest gap in the sine wave
				;from the 1st word to the last
				;word in 1 line of the block!
	moveq.l	#0,d1
clr_logo
i	set	0
	rept	width		;there are faster ways, i know,
	move.l	d1,i(a0)		;but this does not matter here..
	move.l	d1,i+4(a0)
i	set	i+8
	endr
	
	lea	160(a0),a0
	
	dbf	d0,clr_logo

*---------draw gfx!

	lea	gfx+128(pc),a1	;logo addr
	moveq	#height-1,d0
draw
*---------draw 16 pixels at new screen offset, then next 16 at next
*---------screen offset, and so on for width of logo!!

putline	rept	width
	move.l	(a1)+,~0(a2)	;draw 8 bytes
	move.l	(a1)+,~0(a2)	;in 4 planes
	endr

	lea	160(a2),a2	;next line on screen
	lea	160-8*width(a1),a1	;next line on logo

	dbf	d0,draw

	rts


*---------
	data
sine_wave		;just offsets from the screen addr!
	dc.w 13120,12800,12640,12480,12320,12000,11840,11680
	dc.w 11680,11520,11360,11360,11200,11200,11200,11200
	dc.w 11200,11200,11200,11360,11360,11520,11680,11680
	dc.w 11840,12000,12320,12480,12640,12800,12960
	dc.w 13120,12800,12480,12160,11840,11520,11200,11040
	dc.w 10720,10560,10400,10080,9920,9920,9760,9600
	dc.w 9600,9600,9600,9600,9600,9600,9760,9920
	dc.w 9920,10080,10400,10560,10720,11040,11200,11520
	dc.w 11840,12160,12480,12800,12960
	dc.w 13120,12640,12160,11680,11360,10880,10400,10080
	dc.w 9760,9440,9120,8800,8640,8320,8160,8160
	dc.w 8000,8000,8000,8000,8000,8160,8160,8320
	dc.w 8640,8800,9120,9440,9760,10080,10400,10880
	dc.w 11360,11680,12160,12640,12960
	dc.w 13120,12640,12160,11680,11200,10720,10240,9920
	dc.w 9440,9120,8800,8320,8000,7680,7520,7200
	dc.w 7040,6880,6720,6560,6400,6400,6400,6400
	dc.w 6400,6400,6560,6720,6880,7040,7200,7520
	dc.w 7680,8000,8320,8800,9120,9440,9920,10240
	dc.w 10720,11200,11680,12160,12640,12960
	dc.w 13120,12640,12160,11680,11360,10880,10400,10080
	dc.w 9600,9280,8800,8480,8160,7840,7520,7200
	dc.w 6880,6560,6240,6080,5760,5600,5440,5280
	dc.w 5120,4960,4960,4800,4800,4800,4800,4800
	dc.w 4800,4800,4960,4960,5120,5280,5440,5600
	dc.w 5760,6080,6240,6560,6880,7200,7520,7840
	dc.w 8160,8480,8800,9280,9600,10080,10400,10880
	dc.w 11360,11680,12160,12640,12960
	dc.w 13120,12480,12000,11520,11040,10400,9920,9440
	dc.w 8960,8480,8000,7680,7200,6720,6400,6080
	dc.w 5600,5280,4960,4800,4480,4160,4000,3840
	dc.w 3680,3520,3360,3200,3200,3200,3200,3200
	dc.w 3200,3200,3360,3520,3680,3840,4000,4160
	dc.w 4480,4800,4960,5280,5600,6080,6400,6720
	dc.w 7200,7680,8000,8480,8960,9440,9920,10400
	dc.w 11040,11520,12000,12480,12960
	dc.w 13120,12480,11840,11200,10720,10080,9440,8960
	dc.w 8320,7840,7200,6720,6240,5760,5280,4960
	dc.w 4480,4160,3680,3360,3040,2720,2560,2240
	dc.w 2080,1920,1760,1600,1600,1600,1600,1600
	dc.w 1600,1600,1760,1920,2080,2240,2560,2720
	dc.w 3040,3360,3680,4160,4480,4960,5280,5760
	dc.w 6240,6720,7200,7840,8320,8960,9440,10080
	dc.w 10720,11200,11840,12480,12960
	dc.w 13120,12320,11680,11040,10240,9600,8960,8320
	dc.w 7680,7040,6400,5920,5280,4800,4320,3840
	dc.w 3360,2880,2400,2080,1600,1280,1120,800
	dc.w 640,320,160,160,0,0,0,0
	dc.w 0,160,160,320,640,800,1120,1280
	dc.w 1600,2080,2400,2880,3360,3840,4320,4800
	dc.w 5280,5920,6400,7040,7680,8320,8960,9600
	dc.w 10240,11040,11680,12320,12960


old44e	dc.l	0
old_stk	dc.l	0
gempal	dc.w	$777,$700,$070,$000,$007,$707,$077,$555
	dc.w	$333,$733,$373,$773,$337,$737,$377,$000

gfx	incbin	phtal_n5.neo
