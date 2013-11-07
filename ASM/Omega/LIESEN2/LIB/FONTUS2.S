* New font in GEM & TOS!
* By Niclas Pennskog, Jason of Unit 17
*

	opt	x-,f+

	output	d:\fontus4.prg
*	output	c:\starters\fontus.prg

start	bra	program

font
*	incbin	a:\h_fonts\blue16x8.fnt	* 8*16
*	incbin	a:\h_fonts\jas_8_16.fnt	* 8*16
*	incbin	a:\h_fonts\ibm_1.fnt	* 8*16
*	incbin	a:\h_fonts\computer.fnt	* 8*16
*	incbin	a:\h_fonts\cursive.fnt	* 8*16
*	incbin	a:\h_fonts\desktop.fnt	* 8*16
*	incbin	a:\h_fonts\eight.fnt	* 8*16
*	incbin	a:\h_fonts\fraktur.fnt	* 8*16
*	incbin	a:\h_fonts\italic.fnt	* 8*16
*	incbin	a:\h_fonts\kids.fnt	* 8*16
*	incbin	a:\h_fonts\mac_08.fnt	* 8*16
*	incbin	a:\h_fonts\mac_16.fnt	* 8*16
	incbin	a:\h_fonts\rockwell.fnt	* 8*16
*	incbin	a:\h_fonts\script.fnt	* 8*16
*	incbin	a:\h_fonts\stencil.fnt	* 8*16
*	incbin	a:\h_fonts\system.fnt	* 8*16
*	incbin	a:\h_fonts\thin_1.fnt	* 8*16
*	incbin	a:\h_fonts\thin_2.fnt	* 8*16
*	incbin	a:\h_fonts\thin_3.fnt	* 8*16


*	incbin	a:\h_fonts\gem_6x6.fnt	* 6*6
*	incbin	a:\h_fonts\gem_8x8.fnt	* 8*8
*	incbin	a:\h_fonts\blue_8x8.fnt	* 8*8
*	incbin	a:\h_fonts\blue_6x6.fnt	* 6*6
*	incbin	a:\h_fonts\ibm_2.fnt	* 8*8
	even

keep_mem	equ	*-start

***

program	move.w	#$51,-(sp)		; get TT screen resolution
	trap	#14
	addq.w	#2,sp
	cmp.w	#$0400,d0
	beq.s	skip_hi_check

	move.w	#4,-(sp)		; get screen resolution
	trap	#14
	addq.w	#2,sp

	cmp.w	#2,d0		; only execute if hi rez
	bne	stop
skip_hi_check
	dc.w	$a000
	move.l	-$1cc(a0),a1	* def_font -> a1 (for GEM)
	move.l	#font,$4c(a1)	* font -> Adress to fontdata (for GEM)
	move.l	#font,-$16(a0)	* font -> v_fnt_ad (8*16, Monospace) (for TOS)

exit	pea	text(pc)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7

	clr.w	-(sp)		; etm = 0
	move.l	#$100+keep_mem,-(sp)	; protected area
	move.w	#$31,-(sp)		; Ptermres
	trap	#1

stop	pea	text2(pc)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7

	clr.w	-(a7)
	trap	#1

*****

text	dc.b	27,'p New Font 0.9 '
	dc.b	27,'q by Jason of Unit 17.'
	dc.b	$a,$d,$a,$d,0

text2	dc.b	'Error! Monochrome only!!!'
	dc.b	$a,$d,$a,$d,0
	even

	end
