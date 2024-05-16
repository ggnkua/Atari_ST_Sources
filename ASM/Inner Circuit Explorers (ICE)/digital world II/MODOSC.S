;-------------  single pixel plot routine  ----------------
; 	2 screens.... 	Stereo-oscilloscope to check DMA snd
;		    by Techwave
; with y add table.... 

fill:		move.l	screen1,a0
		move.l	screen2,a1
 		add.w	#32000,a1
clrlp:		move.w	#0,(a0)+
		cmp.l	a0,a1
		bne.s 	clrlp

low:		move.w #0,-(sp)
		move.l #-1,-(sp)
		move.l #-1,-(sp)
		move.w #5,-(sp)
		trap #14
		lea 12(sp),sp

		move.w	#0,$ffff8240.w
		move.w	#$f44,$ffff8242.w

start:		jsr 	relocate
	
		lea 	module,a0
		lea 	noise+$c398,a1
	
		move.l 	#endmodule,d7
		lsr.l 	#2,d7
move_modul:
		move.l 	(a0)+,(a1)+
		dbf 	d7,move_modul
	 
		bsr.s	music_start
	
key:		cmp.b 	#185,$fffffc02.w
		bne.s 	key
		bsr.l 	back
		rts
	
relocate:
		lea	noise,a5		; start noise route
		lea	$1c(a5),a0
		move.l	a0,d1
		lea	$2(a5),a6
		move.l	(a6)+,d0
		add.l	(a6)+,d0
		add.l	(a6)+,d0
		add.l	(a6)+,d0
		move.l	a0,a1
		add.l	d0,a1
		move.l	(a1)+,d0
		add.l	d0,a0
		add.l	d1,(a0)

rel_main:
		move.b 	(a1)+,d0
		and.l 	#$ff,d0
		cmp.w 	#$1,d0
		blt.s 	end_rel		; less than
		beq.s	rel_1
		add.l	d0,a0
		add.l	d1,(a0)
		bra.s	rel_main

rel_1:		lea 	$fe(a0),a0
		bra.s	rel_main

end_rel:	lea 	$1C(a5),a0
		rts


music_start:	move.w 	#$2700,sr
		move.l 	$70.w,oldvbl
		move.l 	#vbl,$70.w
		bsr.s 	init_music
		move.w 	#$2300,sr
		rts

; -----------------------------------------------------	

vbl:		bsr.L	vbl2
		movem.l d0/d1/a3,-(sp)
		move.w 	#$020,$ffff8240.w
		move.l 	frames,a3
		jsr 	noise+$5124
		bsr 	set_frame
		move.b 	#0,$ffff8901.w
		move.b 	#1,$ffff8901.w
		bsr 	change_frame
		move.w 	#$000,$ffff8240.w
		movem.l (sp)+,d0/d1/a3
		rte

; -----------------------------------------------------	

init_music:
		jsr 	noise+$bc1a
		jsr 	noise+$26e
		jsr 	noise+$4390
		bsr.s 	init_dma
		move.w 	#$4e75,noise+$b5d4
		move.l 	#$4e714e71,noise+$513c
		rts

init_dma:	move.l 	frames+4,d0		; startframe
		bsr.s 	set_frame2
	
		move.w 	#$7ff,$ffff8924.w	; to mw mask
		lea	mw_set,a0		; microwire settings
		lea	$fffff8922.w,a1		; mw data		
	
		move.w	(a1),d7			; save previous
mw_loop:	move.w 	(a0)+,(a1)
mw_wait:	cmp.w	(a1),d7
		bne.s	mw_wait
		cmp.l	#mw_setend,a0
		bne.s	mw_loop

		move.b 	#$01,$ffff8921.w	; 25 kHz stereo.
		rts

set_frame:
		move.l 	frames,d0		; startframe
set_frame2:	move.l 	d0,d1
		add.l 	#500,d1

		move.b 	d0,$ffff8907.w
		lsr.l 	#8,d0
		move.b 	d0,$ffff8905.w
		lsr.l 	#8,d0
		move.b 	d0,$ffff8903.w

		move.b 	d1,$ffff8913.w
		lsr.l 	#8,d1
		move.b 	d1,$ffff8911.w
		lsr.l 	#8,d1
		move.b 	d1,$ffff890f.w
		rts

change_frame:
		move.l 	frames,d0
		move.l 	frames+4,d1
		exg 	d0,d1
		move.l 	d0,frames
		move.l 	d1,frames+4
		rts

; -----------------------------------------------------	
; -----------------------------------------------------	

back:		move.w 	#$2700,sr
		move.l 	oldvbl,$70
		move.w 	#1,-(sp)
		move.l 	#-1,-(sp)
		move.l 	#-1,-(sp)
		move.w 	#5,-(sp)
		trap 	#14
		lea 	12(sp),sp
		move.w 	#$003,$ffff8240.w
		move.w 	#$777,$ffff8246.w
		move.b 	#0,$ffff8901.w		; stop dma
		move.w 	#$2300,sr
		rts

mw_set:		dc.w	%10011000000+40		; master    0-40
		dc.w	%10101000000+20		; left	    0-20
		dc.w	%10100000000+20		; right	    0-20
		dc.w	%10010000000+6		; treble    0-12 (6=0dB)
		dc.w	%10001000000+8		; bass      0-12 (6=0dB)
		dc.w	%10000000000+2		; mix       0-03
mw_setend:

oldvbl:		dc.l	0
frames:		dc.l 	noise,noise+$b61a

noise:		equ	$50000

module:		equ	$80000
endmodule:	equ	$80000+150000

; stereo oscilloscope


vbl2:		move.w	#$100,$ffff8240.w
		movem.l d0-d7/a0-a6,-(sp)

		move.l	screen1,d0
		sub.l	#6400,d0
		move.b	d0,$ffff8209.w
		lsr.w	#8,d0
		move.b	d0,$ffff8207.w
		swap	d0
		move.b	d0,$ffff8205.w
		move.l	screen1,d0
		move.l	screen2,d1
		move.l	d0,screen2
		move.l	d1,screen1

		tst.b	clrflg
		beq.s	noclr
		bsr.s	pixels_clear

noclr:
		move.b	$ffff8909.w,d0
		lsl.w	#8,d0
		move.b	$ffff890b.w,d0
		lsl.l	#8,d0
		move.b	$ffff890d.w,d0
		move.l	d0,a1			; dmasnd address
	
		bsr.s	pixels_out

		st	clrflg

		movem.l (sp)+,d0-d7/a0-a6
		move.w	#$0,$ffff8240.w
		rts
;-----------------------------------------------------	Subroutines

pixels_clear:
		lea	clraddrs,a0

		tst.b	scrnflg
		beq.s	noext
		add.w	#200*4,a0
noext:		moveq	#0,d0
		move.w	#200/4-1,d7		; even
clrline:	move.l	(a0)+,a1
		move.w	d0,(a1)
		move.l	(a0)+,a1
		move.w	d0,(a1)
		move.l	(a0)+,a1
		move.w	d0,(a1)
		move.l	(a0)+,a1
		move.w	d0,(a1)
		dbf	d7,clrline
		rts

;----------------------------------------------	

pixels_out:
		lea	clraddrs,a2

		not.b	scrnflg
		bne.s	new
		add.w	#200*4,a2

new:	
		move.w	#32,d6
		move.w	#320-132,d5

		move.w	#200/2-1,d7

oscillo_l:
		moveq	#0,d0		; x
		moveq	#0,d1		; y
		lea	yadd_tab,a3
		
		;move.w	d6,d0
		move.b	128(a1),d0
		sub.b	#128,d0
		lsr.b	#1,d0
		;add.w	#40,d0

		move.b	(a1)+,d1

		sub.b	#128,d1
		lsr.b	#2,d1		; pixels in y

		bsr.s	xyput
		move.l	a0,(a2)+	;screen address
		addq.w	#1,d6

oscillo_r:	moveq	#0,d0		; x
		moveq	#0,d1		; y
		lea	yadd_tab,a3
		
		;move.w	d5,d0
		move.b	128(a1),d0
		sub.b	#128,d0
		lsr.b	#1,d0
		add.w	#320-120,d0

		move.b	(a1)+,d1

		sub.b	#128,d1
		lsr.b	#2,d1		; pixels in y

		bsr.s	xyput
		move.l	a0,(a2)+	;screen address

		addq.w	#1,d5
		dbf	d7,oscillo_l
		rts

;----------------------------------------------
; converts x & y values to scrmem and plot on position!
; d0 = xvalue	d1 = yvalue

xyput:	
		move.l 	screen1,a0
		move.w	#$8000,d2

; y convert algorithm

		lsl.w	#1,d1
		add.w 	(a3,d1.w),a0	; add to screen

; x convert algorithm

		cmp.w 	#15,d0     
		bhi.s	xcon	 	; higher than 15 ?
		lsr.w 	d0,d2		; rotate

		or.w	d2,(a0)		; pixel out
		rts

xcon:		ror.l	#4,d0		; /16
		lsl.w	#3,d0		; *8
		add.w	d0,a0		; add to screen
		rol.l	#4,d0		; 4 bits = $f
		and.w	#$000f,d0
		lsr.w 	d0,d2		; rotate

		or.w	d2,(a0)		; pixel out
		rts	

;------------------------------------- 	variables and saved data

xvalue:		dc.w 0
yvalue:		dc.w 0

scrnflg:	dc.b 0
clrflg:		dc.b 0

even
screen1:	dc.l $f8000-64000
screen2:	dc.l $f8000-32000


clraddrs:	blk.l	640,$f8000

yadd_tab:
dc.w 	0,160,320,480,640,800,960,1120,1280,1440,1600,1760
dc.w 	1920,2080,2240,2400,2560,2720,2880,3040,3200,3360
dc.w 	3520,3680,3840,4000,4160,4320,4480,4640,4800,4960
dc.w 	5120,5280,5440,5600,5760,5920,6080,6240,6400,6560
dc.w 	6720,6880,7040,7200,7360,7520,7680,7840,8000,8160
dc.w 	8320,8480,8640,8800,8960,9120,9280,9440,9600,9760
dc.w 	9920
dc.w 	10080,10240,10400,10560,10720,10880,11040,11200
dc.w 	11360,11520,11680,11840,12000,12160,12320,12480
dc.w 	12640,12800,12960,13120,13280,13440,13600,13760
dc.w 	13920,14080,14240,14400,14560,14720,14880,15040
dc.w 	15200,15360,15520,15680,15840,16000,16160,16320
dc.w 	16480,16640,16800,16960,17120,17280,17440,17600
dc.w 	17760,17920,18080,18240,18400,18560,18720,18880
dc.w 	19040,19200,19360,19520,19680,19840,20000,20160
dc.w 	20320,20480,20640,20800,20960,21120,21280,21440
dc.w 	21600,21760,21920,22080,22240,22400,22560,22720
dc.w 	22880,23040,23200,23360,23520,23680,23840,24000
dc.w 	24160,24320,24480,24640,24800,24960,25120,25280
dc.w 	25440,25600,25760,25920,26080,26240,26400,26560
dc.w 	26720,26880,27040,27200,27360,27520,27680,27840
dc.w 	28000,28160,28320,28480,28640,28800,28960,29120
dc.w 	29280,29440,29600,29760,29920,30080,30240,30400
dc.w 	30560,30720,30880,31040,31200,31360,31520,31680
dc.w 	31840,32000
