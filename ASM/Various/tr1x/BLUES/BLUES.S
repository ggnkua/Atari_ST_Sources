; "Blues", Atari ST/STE Intro 128B
; lame code by tr1x
; requirements: original Atari ST/STE
; screen resolution: ST Low
; version: 1.0
; release date: 2019-12-07

	opt	o+

offsetx	equ	31
offsety	equ	35

	section	text

	move.w #32,-(a7)
	trap #1

	; switch cursor off
	move.w	#0,-(sp)
	move.w	#21,-(sp)
	trap	#14
	addq.l	#6,sp

	; Line-A initialization
	dc.w	$a000
	move.l	a0,a5	; Line-A variables

	; call XBIOS's function Random for a 24-bit random number
loop1:	move.w	#$11,-(sp)
	trap	#14
	move.w	d0,d3
	move.w	d0,d2
	and.w   #%01111111,d2
	add.w	#offsety,d2
	lsr.w	#$08,d3
	add.w	#offsetx,d3

	; put a pixel
	move.w	d2,$100+4
	move.w	d3,$100+2
	move.l	#$100+2,12(a5)
	move.w 	d0,$100
	move.l	#$100,8(a5)
	dc.w	$a001

	; slowly rotate color palette
	dbf.b	d5,loop1
	move.w	#$ff,d5

	add.b	#$01,d4
	and.b	#$0f,d4
	move.b	d4,d7
	btst.b	#$03,d4
	beq.b	skip1
	eor.b	#$07,d7
skip1:	move.l	#$ffff8240+$02,a2
	move.w	#$0e,d6
loop2:	move.w	(a2),-(a2)
	add.w	#$04,a2
	dbf.b	d6,loop2
	move.w	d7,$ffff8240+$1e

	bra.b	loop1
