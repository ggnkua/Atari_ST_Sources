; "Shades", Atari ST/STE Intro 128B
; lame code by tr1x
; requirements: original Atari ST/STE
; screen resolution: ST Low
; version: 1.0
; release date: 2019-12-07

	opt	o+

width	equ	32
offsetx	equ	16
offsety	equ	35

	section	text

	move.w #32,-(a7)
	trap #1

	; switch cursor off
	move.w	#0,-(sp)
	move.w	#21,-(sp)
	trap	#14
	addq.l	#6,sp

	; generate color palette
	move.w	#$000f,d0
	move.w	#$ffff8240+$20,a1
loop1	move.w	d0,-(a1)
	cmp.w	#$8,d0
	bcs.s	skip1
	asl.w	#$8,d0
	move.w	d0,(a1)
	lsr.w	#$8,d0
skip1	sub.w	#$0001,d0
	bpl.b	loop1

	; Line-A initialization
	dc.w	$a000
	move.l	a0,a5	; Line-A variables

	; call XBIOS's function Random for a 24-bit random number
loop2:	move.w	#$11,-(sp)
	trap	#14
	move.w	d0,d3
	move.w	d0,d2
	and.w   #%01111111,d2
	add.w	#offsety,d2
	lsr.w	#$08,d3
	and.w	#%11111111,d3
	add.w	#offsetx,d3

	; draw a shade line
	move.w	d2,$100+4
	move.w	#width,d4
	move.w	d3,$100+2
loop3:	add.w	#1,$100+2
	move.l	#$100+2,12(a5)
	dc.w	$a002
	add.w	#1,d0
	move.w	d0,$100
	move.l	#$100,8(a5)
	dc.w	$a001
	dbf.w	d4,loop3

	bra.b	loop2
