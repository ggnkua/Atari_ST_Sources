* get rid of bottom border
* by James Ingram, March 1994

	opt	o-,ow-


b_lines	equ	199

	include	\includes\macros.s


	super_on
	bsr	initialise
	keep_timers

* get screen address
	move.l	#scrn,d0
	add.l	#255,d0
	clr.b	d0
	move.l	d0,screen

	move.l	d0,a6

* set the screen address
	move.l	d0,d1
	moveq	#-1,d0
	bsr	set_scrn

	movem.l	my_pal,d0-7
	movem.l	d0-7,$ffff8240.w

* fill screen with junk, to show effect

	move.w	#screen_len/4-1,d1
fill:
	move.l	#$aaaaaaaa,(a6)+
	dbra	d1,fill


* set up timer b
	clr.b	b_control.w	; timer B off

	move.l	#my_120,$120.w	; routine address in
	
* set timer B mask to on
	bset.b	#0,mask_a.w
	bset.b	#0,enable_a.w
* VBL will always initialise the timer B routine.


	move.l	$70.w,-(a7)
	move.l	#my_70,$70.w
	bsr	inp
	move.l	(a7)+,$70.w


	restore_timers
	bsr	restore
	super_off
	clr.w	-(a7)
	trap	#1


my_70:
* simply set up timer B to do the work....

	clr.b	b_control.w		; timer B off!
	move.b	#b_lines,b_data.w	; counter in
	move.b	#8,b_control.w		; timer B on!

	rte


my_120:
* I arrive here somewhere in the middle of the bottom line!

	movem.l	d0/a0,-(a7)

	move.w	#b_data,a0	; get timer B counter address

	move.b	(a0),d0		; get count value
.pause:
	cmp.b	(a0),d0		; wait for it to change
	beq.s	.pause		; (EXACTLY on next line now!)


* into 60 Hz
	eor.b	#2,$ffff820a.w

	rept	15
	nop
	endr

* back into 50 Hz
	eor.b	#2,$ffff820a.w

	movem.l	(a7)+,d0/a0
	bclr	#0,$fffffa0f.w
	rte



my_pal	incbin	\includes\spr_pal.dat

	include	\includes\misc.s
	include	\includes\init.s


	section	bss

	old		; old timers data

scrn:
	ds.b	256	; byte boundary
s:
	ds.b	32000	; main screen
	ds.b	32*160	; bottom border
screen_len	equ	*-s

screen	ds.l	1



