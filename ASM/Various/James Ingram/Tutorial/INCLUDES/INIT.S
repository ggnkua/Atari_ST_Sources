* routine to initialise the screen display
* by James Ingram, Febuary 1994

* to be INCLUDED in other sources...

initialise:

* turn off the mouse
	move.w	#34,-(a7)
	trap	#14		; get table
	addq.l	#2,a7
	
	move.l	d0,a0
	move.l	16(a0),mouse_vec	; store mouse vector

	pea	0.w
	pea	0.w
	pea	0.w
	trap	#14		; mouse off
	lea	12(a7),a7


* get the LOGICAL screen instead of the PHYSICAL.
* This helps when using MONST or MON
* because MON always messes around with the screen address.

	move.w	#3,-(a7)
	trap	#14
	addq.l	#2,a7
	move.l	d0,logbase	; keep old screen address

	move.w	#4,-(a7)
	trap	#14		; get res
	addq.l	#2,a7
	move.w	d0,res		; store it

* now I get the palette
	move.l	#$ffff8240,a0
	lea	pal(pc),a1

	movem.l	(a0),d0-7
	movem.l	d0-7,(a1)	; just 2 instructions store the palette!

* now put me into low res...
	moveq	#0,d0
	moveq	#-1,d1
	bsr	set_scrn

	rts


logbase	ds.l	1
res	ds.w	1
pal	ds.b	32
mouse_vec	ds.l	1

set_scrn:
* set screen using parameters in d0 and d1
	move.w	d0,-(a7)
	move.l	d1,-(a7)
	move.l	d1,-(a7)
	move.w	#5,-(a7)
	trap	#14
	lea	12(a7),a7
	rts


restore:
* restore screen to how it was!
* first the res & screen address

	move.w	res,d0
	move.l	logbase,d1
	bsr	set_scrn

* now the old palette back again!
	lea	pal(pc),a0
	move.l	#$ffff8240,a1

	movem.l	(a0),d0-7
	movem.l	d0-7,(a1)

* turn the mouse back on...
	move.l	mouse_vec,-(a7)
	pea	mouse_params(pc)
	move.w	#1,-(a7)
	clr.w	-(a7)
	trap	#14		; turn mouse on
	lea	12(a7),a7

	rts

mouse_params:
	dc.b	0,1,1,1



