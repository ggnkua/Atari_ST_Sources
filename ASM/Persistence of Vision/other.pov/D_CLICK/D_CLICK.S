***********************************************
* Auto double-click program in desktop window *
***********************************************

	opt	o+,ow-

MAX_TICKS	equ	200*2


	SECTION	TEXT

****************
* Main program *
****************

start
	bra.s	code
	dc.b	'< Auto Double-Click Version 1.0'
	dc.b	' (C) 1991 by Boris of'
	dc.b	' "Persistence of Vision" >'
	even
code
	move.l	sp,a5
	move.l	4(a5),a5	;get basepage
	move.l	$C(a5),d0	;text segment size
	add.l	$14(a5),d0	;data segment size
	add.l	$1C(a5),d0	;bss segment size
	add.l	#$100,d0	;basepage size
	lea	reserved_len(pc),a0
	move.l	d0,(a0)
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	clr.w	-(sp)
	move.w	#$4A,-(sp)
	trap	#1
	add.l	#12,sp

	pea	set_vectors(pc)
	move.w	#38,-(sp)
	trap	#14
	addq.w	#6,sp

	clr.w	-(sp)
	move.l	reserved_len(pc),-(sp)
	move.w	#49,-(sp)
	trap	#1


***************
* Subroutines *
***************

checker
	movem.l	a0-a1,-(sp)
	move.l	mouse_vec(pc),a0
	move.l	(a0),a1
	cmp.l	old_mouse,a1
	beq.s	.end
	move.l	a1,old_mouse
	move.w	sr,-(sp)
	or.w	#$700,sr
	move.l	#return,(a0)
	move.l	#auto_click,$114.w
	move.w	(sp)+,sr
.end	movem.l	(sp)+,a0-a1
	move.l	old_timer_c,-(sp)
	rts

auto_click
	movem.l	a0-a2,-(sp)
	lea	count_down(pc),a2
	subq.w	#1,(a2)
	beq.s	.restore
	cmp.w	#4,(a2)
	bgt.s	.end
	lea	button,a0
	move.l	old_mouse,a1
	jsr	(a1)
	eor.b	#2,button
.end	movem.l	(sp)+,a0-a2
	move.l	old_timer_c(pc),-(sp)
	rts
.restore
	move.l	mouse_vec,a0
	move.l	old_mouse,(a0)
	move.l	old_timer_c,$114.w
	movem.l	(sp)+,a0-a2
	move.l	old_timer_c(pc),-(sp)
	rts


set_vectors
	move.w	#$2700,sr
	move.w	#34,-(sp)		; Get kbdvbase.
	trap	#14
	addq.w	#2,sp
	move.l	d0,a0
	lea	16(a0),a1
	move.l	a1,mouse_vec
	move.l	(a1),old_mouse		; Save old mouse vec.
	lea	old_timer_c(pc),a0
	move.l	$114.w,(a0)
	lea	checker(pc),a0
	move.l	a0,$114.w
	move.w	#$2300,sr
return	rts


	SECTION	DATA

count_down	dc.w	MAX_TICKS

button		dc.b	$fa,0,0,0


	SECTION	BSS

old_timer_c	ds.l	1
old_mouse	ds.l	1
mouse_vec	ds.l	1

reserved_len	ds.l	1
