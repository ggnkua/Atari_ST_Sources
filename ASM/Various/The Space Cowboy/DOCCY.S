; this is just a pre-release version of a doc displayer.
; please don't complain about the messy code or speed of it as it is not
; finished!!!!!!  I labeled it so you can follow it better.
; the text that was used originally was deemed unsuitable for public
; viewing so you get lots of boring stars instead.

* The problem is that it will not work properly when it is assembled like
* a normal prg and run from the desktop, assemble it to memory and run it
* in devpac and it works perfectly, now assemble it to disk and re-boot
* the machine (med res), run the assembled prg... and watch it screw up
* Why does it only work from devpac???   I found that resolution changes
* (to med res) in the code make it screw up also, what does devpac do that
* the desktop doesn't???

*       PLEASE HELP ME  its driving me up the wall!!!!!!    <T.S.C.>

; Coded in Devpac v2.04 (old)  -  Tabs set to 10.

printat	macro	\1,\2,\3,\4
	move.b	#\1,pr_col+2	the ink
	move.b	#\2,d1
	add.b	#32,d1	
	move.b	d1,pr_loc+2	the row
	move.b	#\3,d2
	add.b	#32,d2
	move.b	d2,pr_loc+3	the column	
	move.l	\4,a3
	move.l	a3,-(sp)
	move.l	#pr_col,a3
	move.l 	a3,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	(sp)+,a3	retrieve the address of message
	move.l 	a3,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	endm

pages	equ	4		amount of pages

	pea	0.w		supervisor mode
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,oldsp

	bclr	#0,$484.w		no key click
	bclr	#1,$484.w		no key repeat

	move.b	#$12,$fffffc02.w	bye bye Mr mouse
* this is the one!
	bsr	wrap		set VT52 to wrap mode!
;	bsr	home		cursor home

	move.l	#1,pagecount	init stuff
	bsr	clear		
	lea	text,a0		a0 points to text
	lea	buffer,a1		a1 points to buffer
	bsr	first_p		display the first page

mainloop	cmp.b	#$48,$fffffc02.w	check for cursor up
	bne.s	chk_down		no so next key check
	bra.s	higher	
chk_down	cmp.b	#$50,$fffffc02.w	cursor down
	bne.s	chk_quit		
	bra	lower
chk_quit	cmp.b	#$01,$fffffc02.w	escape key
	bne.s	mainloop	
	bra	quit

higher	cmp.l	#1,pagecount	are we at the first page?
	beq.s	mainloop		yes so cant go up anymore
	subq.l	#1,pagecount   not on first page, sub 1 from page count
	bsr	vsync
;	bsr	home		home position
	bsr	clear		cls
	lea	buffer,a1		get the buffer
	lea 	-3200(a0),a0		up a page so sub 3200 bytes (20*80)
; i.e.  80 bytes per line and 20 lines
	moveq.l	#20-1,d0		loop 20 times
loop1
	rept	20		handy command, saves typing a lot!
	move.l	(a0)+,(a1)+	copy text to buffer
	endr
	dbf	d0,loop1		branch until false
	clr.b	null		null terminate the text
	printat	15,2,0,#buffer
;	bsr	print		print it
	bra	mainloop		go back to main loop


lower	cmp.l	#pages,pagecount	are we on the last page?
	beq	mainloop		yes so cant go down no more
	addq.l	#1,pagecount	if going down add 1 to page count
	bsr	vsync
;	bsr	home		home position
	bsr	clear		cls

;	lea	buffer,a1		down 1 line (ingnore for now)
;	add	#80,a0		
;	sub	#1840,a0		

	lea	buffer,a1		get buffer
	moveq.l	#20-1,d0		loop 20 times
loop2	
	rept	20
	move.l	(a0)+,(a1)+	copy text to buffer
	endr
	dbf	d0,loop2
	clr.b	null		null terminate the text
	printat	15,2,0,#buffer
;	bsr.s	print		print it
	bra	mainloop		back to main loop

first_p	lea	buffer,a1		come on you must get this 
	moveq.l	#20-1,d0		by now?
lop2	
	rept	20
	move.l	(a0)+,(a1)+
	endr
	dbf	d0,lop2
	clr.b	null
	printat	15,2,0,#buffer
;	bsr.s	print
	bra	mainloop	

clear	pea	robby		clear screen rout
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

print	move.l	#buffer,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

wrap	move.l	#wrapcode,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts


home	pea	homey		home position
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

quit	move.b	#8,$fffffc02.w	mouse back
	bset	#0,$484.w		key repeat and click back on
	bset	#1,$484.w

	pea	oldsp		user mode
	move.w	#$20,-(sp)
	trap	#1
 	addq.l	#6,sp

	pea	0.w		exit
	trap	#1

vsync	move.l	$466.w,d1		wait for next vbl
vwait	cmp.l	$466.w,d1
	beq.s	vwait
	rts

	data
oldsp	dc.l	0
pr_col	dc.b 27,"b",15		no zero here! ,0
pr_loc	dc.b 27,"Y",32,32,0,0	dynamic variables, liable to change!
wrapcode	dc.b	27,"v",0

	even

robby	dc.b	$1b,$45,0
homey	dc.b 	27,"H",0

	section bss

pagecount	ds.l	1
buffer	ds.l	400
null	ds.b	0

	section data

		*12345678901234567890123456789012345678901234567890123456789012345678901234567890*
	
text	dc.b	"   22 22 22  ******************************************************  22 22 22   "
	dc.b	"  333 22 333  ****************************************************  333 22 333  "
	dc.b	" 4444 22 4444  **************************************************  4444 22 4444 "
	dc.b	"0******************************************************************************!"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"********************************************************************************"
	dc.b	"t0hough!!!!!!!!..........                                                       "
	dc.b	"q1                                                                              "
	dc.b	"e2                                                                              "
	dc.b	"g3                                                                              "
	dc.b	"94                                                                              "
	dc.b	"85                                                                              "
	dc.b	"76                                                                              "
	dc.b	"67                                                                              "
	dc.b	"58                                                                              "
	dc.b	"49                                                                              "
	dc.b	"30                                                                              "
	dc.b	"2s                                                                              "
	dc.b	"1a                                                                              "
	dc.b	"033000000                                                             ",0
	

