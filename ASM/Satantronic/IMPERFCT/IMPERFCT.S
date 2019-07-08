*		ImPerfect (3D star with rays)
*		512 b intro for Atari Falcon 060 (FPU + VGA version)
*		by -XI-/Satantronic
*		version 2   save:0.28   date:26.05.2019   time:13:38

		opt	d-

scr_w:		equ	320				; screen width  (x - in pixels)
scr_h:		equ	240				; screen height (y - in pixels)
scr_d:		equ	2				; screen (one pixel) color depth  (in bytes)
;psox		equ	20				; pixels skipped on x
;psoy		equ	20				; pixels skipped on y
sox		equ	3				; speed on x
soy		equ	1				; speed on y

; ---------------------------------------------
		section text
; ---------------------------------------------

start:		move.l	#$00580134,-(sp)		; Vsetmode ($134 = TC,320*240, VGA, PAL, Double-line on VGA)
		trap	#14				; XBIOS ($58)
		addq.l	#4,sp

		clr.l	-(sp)				; super()
		move.w	#$20,-(sp)			;
		trap	#1				;
		addq.l	#6,sp				;

		lea	scrnbfr(pc),a2			; init fillvr too
		move.l	a2,d0				; set screen address
		adda.l	#scr_w*scr_d*$40,a2		; next init fillvr 
		move.l	d0,d1				;
		lsr.w   #8,d0				;
		move.b  d0,$ffff8203.w			;
		swap    d0				;
		move.b  d0,$ffff8201.w			;
		move.b  d1,$ffff820d.w			;
		
		fmove.s	#$427ea5dd,fp7			; ball3D init
		sub.l	a5,a5				; sphere size = 0
		moveq	#20,d4				; psox = psoy

mainloop:	move.w	#$25,-(sp)			; vsync
		trap	#14				; XBIOS ($25)
		addq.l	#2,sp				; !!! it DESTROYS a1 register

		lea	(ix.w,pc),a1			; ix to a1


ball3D:		move.w	a5,d0				;move.b	(sphsiz.w,pc),d0
		fmove.b	d0,fp6

		;move.w	(2,a1),d7			;move.w	iy,d7
ly		fmove.w	d7,fp0
		fdiv.x	fp7,fp0
		fmove.x	fp0,fp1
		fcos.x	fp0
		fmul.x	fp6,fp0				; fp0 - ys
		fsin.x	fp1
		fmul.x	fp6,fp1				; fp1 - part of xs
		
		move.w	(a1),d6				;move.w	ix,d6
lx		fmove.w	d6,fp2
		fdiv.x	fp7,fp2
		fcos.x	fp2

		fmul.x	fp1,fp2
		fmove.w	fp2,d0
		move.w	d0,d2
		add.w	#scr_w/2,d0
		fmove.w	fp0,d3
		moveq	#scr_h/2-8,d1
		add.w	d3,d1
		
		asr.w	d2
		add.w	#scr_w/2,d2
		asr.w	d3
		add.w	#scr_h/2-8,d3

		;clr.w	d4
		bsr	line

		add.w	d4,d6				;add.w	#psox,d6
		cmp.w	#200,d6
		blt.s	lx
		add.w	d4,d7				;add.w	#psoy,d7
		cmp.w	#200,d7
		blt.s	ly

		; end of drawing loops

		moveq	#sox,d0				; animation = change on x
		;lea	(ix.w,pc),a1
		add.w	(a1),d0
		divu.w	d4,d0				;divu.w	#psox,d0			; modulo
		swap	d0
		move.w	d0,(a1)+			; write ix
		
		moveq	#soy,d0				; animation = change on y
		;lea	(iy.w,pc),a1
		add.w	(a1),d0
		divu.w	d4,d0				;divu.w	#psoy,d0			; modulo
		swap	d0
		move.w	d0,(a1)				; write iy		
		
		subq.w	#4,a1				;lea	(bs.w,pc),a1
		tst.b	(a1)				; bs
		bmi.s	.bigger
.smaller:		
		subq.w	#1,a5
		tst.w	a5 				;cmp.w	#50,a5
		bge.s	end
		subq.b	#1,(a1)				; bs--
		;bra.s	end
.bigger:
		addq.w	#1,a5
		cmp.w	#127,a5				;160
		blt.s	end
		addq.b	#1,(a1)				; bs++
end:

; --------------------------------------------------------------------------------
; Simple DoSound Music Player v0.06 (use: a3,a4,a6 + xbios destroy d0,d1, a0,a1)
; --------------------------------------------------------------------------------
musicplayer:	lea	musicposition(pc),a3		;musicposition
		lea	musictempo(pc),a4		;channel A = DoSoundData
		lea 	ch2(pc),a6			;channel B

		subq.b	#1,(a4)				;musictempo
		bne.s 	end2
		move.b	#10,(a4)+			;musictempo
		
		addq.b	#1,(a3)				;musicposition
.cont0		cmp.b	#8,(a3)				;musicposition 4b
		bne.s	.cont1
.p2		move.l	#$020b0307,(a6)			;ch2 (4,a4)8b

.cont1		cmp.b	#16,(a3)			;musicposition
		bne.s	.cont2
.p3		move.l	#$00680109,(a4)			;ch1 6b

.cont2		cmp.b	#24,(a3)			;musicposition
		bne.s	.cont3
.p4		move.l	#$02770307,(a6)			;ch2 (4,a4)8b

.cont3		cmp.b	#32,(a3)			;musicposition
		bne.s 	.cont4
		clr.b	(a3)				;musicposition
.p1		move.l	#$00610108,(a4)			;ch1 6b
		move.l	#$02470306,(a6)			;ch2 (4,a4)8b

.cont4		pea	(a4)				; sounddata buffer
		move.w	#32,-(sp)			; DoSound
		trap	#14				; XBIOS ($20)
		addq.l	#6,sp				; !!! it DESTROYS d0,d1, a0,a1 registers
; --------------------------------------------------------------------------------

end2:


fillvr:		move.l	a2,a0				;lea	scrnbfr,a0	; fill after 38 empty lines on top
							;adda.l	#scr_w*scr_d*$38,a0			
		move.w	(2,a1),d0			;move.w	iy,d0				; get fading color 
		move.w	d0,d7
		add.w	#$f800,d0			; from red to pink
		move.w	d0,d1				; cost 6b more than direct color
		swap	d0
		add.w	d1,d0
		
.l2		move.w	#scr_w*scr_d*96/4-1,d6		; fill 128 lines with bg color
.l1		move.l	d0,(a0)+			;move.l	#$ffe0ffe0,(a0)+
		dbra	d6,.l1	
		

		bra	mainloop

; --------------------------------------------------------------------------------
; TC line - imperfect ;) v0.44 (use: d0-5,a6)
; --------------------------------------------------------------------------------
line:		cmp.w   d2,d0   			;draw lines from left to right
		ble.s   ok
		exg     d0,d2
		exg     d1,d3

ok		move.w	#scr_w*scr_d,d5			; Y-Inc (Length of a Scanline)

		sub.w	d1,d3				;d3 = shortenLenght = abs(y2-y1)
		bpl.s	.cont1				;
		neg.w	d3				;
		neg.w   d5      			;Inc Y must be Dec Y		
		
.cont1		lea	(scrnbfr.w,pc,d0.w*2),a6	;lea	([effect_scrn.w,pc],d0.w*2),a6	; pixel screen address according to X !!! 6 bytes
		muls.w	#scr_w*scr_d,d1			; pixel screen address according to Y
		adda.l	d1,a6

		sub.w	d0,d2				;d2 = longerLenght = abs(x2-x1)
		bpl.s	.cont2				;
		neg.w     d2				;

.cont2		move.w	#$8000,d0			; i=0.5
		cmp.w	d3,d2				;if (abs(y2-y1) >= abs(x2-x1))
		sls	d1				; set flag 00=xLonger, ff=yLonger
		bpl.s	.cont3
		exg	d2,d3				; Swap d2<->d3 => d2 = longerLenght = abs(y2-y1) and d3 = shortenLenght = abs(x2-x1)

.cont3		bne.s	cont4
		moveq	#-1,d3				;move.w	#$ffff,d3 ; $ffff instead of $10000, dirty hack for decInc = 0; 

xLonger:
.loop		add.w	d3,d0				; i+=decInc;
		bcc.s	.incx
.incy		add.w	d5,a6				; inc y (next line on screen)
.incx		;move.w	d4,(a6)+			; Draw Pixel with Color in d4
		clr.w	(a6)+				; inc x
		dbra	d2,.loop
		rts
		
cont4		swap	d3				;else decInc = (shortenLenght << 16) / longerLenght;
		clr.w	d3				;
		divu.w  d2,d3				; 
		tst.b	d1
		beq.s	xLonger				;if (yLonger)
		
yLonger:
.loop		add.w	d3,d0				; i+=decInc;
		bcs.s	.incx	
.incy		;move.w	d4,(a6)				; Draw Pixel with Color in d4
		clr.w	(a6)
		add.w	d5,a6				; inc y (next line on screen)
		dbra	d2,.loop
		rts
.incx		;move.w	d4,(a6)+			; Draw Pixel with Color in d4
		clr.w	(a6)+				; inc x
		add.w	d5,a6				; inc y (next line on screen)
		dbra	d2,.loop
		rts
		
; ---------------------------------------------
		section data
; ---------------------------------------------

		even

bs		dc.b	$ff				; $ff - size is going to be bigger, 0 - size is going to be smaller
musictempo:	dc.b	10
sounddata:
ch1		dc.b	0,$61				; channel A pitch lo
		dc.b	1,$08				; channel A pitch hi
ch2		dc.b	2,$47				; channel B pitch lo
		dc.b	3,$06				; channel B pitch hi
		dc.b	7,$fc				; 11 111 100
		dc.b	8,$10				; channel A amplitude: envelope
		dc.b	9,$10				; channel B amplitude: envelope
		;dc.b	11,0				; envelope period hi
		dc.b	12,10				; envelope period lo
		dc.b	13,$08				; envelope type: \____
		dc.b	$ff,0				; end of buffer

; ---------------------------------------------
		section bss
; ---------------------------------------------

		even
		ds.w	1
ix		ds.w	1
iy		ds.w	1
		ds.l	1
		ds.b	1
musicposition:	ds.b	1
		ds.l	320+70
		ds.l	12*scr_w*scr_d
scrnbfr:	ds.b	scr_w*scr_h*scr_d		; screen buffer

