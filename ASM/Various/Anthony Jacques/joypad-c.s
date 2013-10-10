**************************************************
*
* Jagpad Extension for STOS
*
* V0.1
*
* Compiler version
*

	OUTPUT	JOYPAD.ECZ

* Offsets to parts of the extension

START	dc.l	PARA-START
	dc.l	DATA-START
	dc.l	LIB1-START

* here is the library catalogue - ie length of each routine

CATALOG	dc.w	LIB2-LIB1	; I have 1 routine + 1 dummy
	dc.w	LIBEX-LIB2
* Here is the parameter table header

PARA	dc.w	2,2
	dc.w	pdummy-PARA
	dc.w	pjoypad-PARA

* Here are the actual parameter definitions

pdummy		dc.b	0,1,1,0
pjoypad		dc.b	0,0,1,1,0

* Here is the data space

	EVEN

DATA	bra	COLDST

c1numpad	ds.l	1
c2numpad	ds.l	1	


* Initialisation code

COLDST	lea	END(pc),a2
	clr.l	d0
	rts

END	rts



************************************************
*
* My instructions / functions
*

LIB1	dc.w	0
	rts


* Joypad
LIB2	dc.w	0
	move.l	$92c(a5),a3
	move.l	0(a3,d1.w),a3
	move.l	(a6)+,-(sp)

	bsr	jpd

	move.l	(sp)+,d0

	tst.l	d0
	beq	prt0

	move.l	d6,d3
prt0	move.l	d3,d4
	andi.l	#%1111000000000000000000000,d4
	lsr.l	#4,d4
	andi.l	#%11111111111111111,d3
	or.l	d4,d3

	move.l	d3,-(a6)

	rts

* Function performs joypad read.
* Returns :-
* d3.l contains c1numpad,c1midbuts,c1firebuts,c1joypad
* d6.l = c2numpad,c2midbuts,c2firebuts,c2joypad


jpd	clr.l	d0
	clr.l	d1
	clr.l	d2
	clr.l	d3
	clr.l	d4
	clr.l	d5
	clr.l	d6
	clr.l	d7
	move.l	#0,a0
	move.l	#0,c1numpad-DATA(a3)
	move.l	#0,c2numpad-DATA(a3)

* read row 1

	move.w	#$ffee,d0
	bsr	read_controller

	move.w	d1,d0
	andi.w	#1,d0
	move.b	d0,d3

	move.w	d1,d0
	andi.w	#2,d0
	lsr.w	#1,d0
	move.b	d0,d4

	move.w	d1,d0
	andi.w	#4,d0
	lsr.w	#2,d0
	move.b	d0,d6

	move.w	d1,d0
	andi.w	#8,d0
	lsr.w	#3,d0
	move.b	d0,d7

	move.w	d2,d0
	andi.w	#$f00,d0
	lsr.w	#8,d0
	move.b	d0,d5

	move.w	d2,d0
	andi.w	#$f000,d0
	lsr.w	#8,d0
	lsr.w	#4,d0
	move.l	d0,a0

* read row 2

	move.w	#$ffdd,d0
	bsr	read_controller

	move.w	d1,d0
	andi.w	#2,d0
	or.b	d0,d4

	move.w	d1,d0
	andi.w	#8,d0
	lsr.w	#2,d0
	or.b	d0,d7

	move.w	d2,d0
	andi.w	#$f00,d0
	lsr.w	#8,d0
	move.w	d0,c1numpad-DATA(a3)

	move.w	d2,d0
	andi.w	#$f000,d0
	lsr.w	#8,d0
	lsr.w	#4,d0
	move.w	d0,c2numpad-DATA(a3)

* read row 3

	move.w	#$ffbb,d0
	bsr	read_controller

	move.w	d1,d0
	andi.w	#2,d0
	lsl.w	#1,d0
	or.b	d0,d4

	move.w	d1,d0
	andi.w	#8,d0
	lsr.w	#1,d0
	or.b	d0,d7

	move.w	d2,d0
	andi.w	#$f00,d0
	lsr.w	#4,d0
	or.l	d0,c1numpad-DATA(a3)

	move.w	d2,d0
	andi.w	#$f000,d0
	lsr.w	#8,d0
	or.l	d0,c2numpad-DATA(a3)

* read row 4

	move.w	#$ff77,d0
	bsr	read_controller

	move.w	d1,d0
	andi.w	#2,d0
	or.b	d0,d3

	move.w	d1,d0
	andi.w	#8,d0
	lsr.w	#2,d0
	or.b	d0,d6

	move.w	d2,d0
	andi.w	#$f00,d0
	or.l	d0,c1numpad-DATA(a3)

	move.w	d2,d0
	andi.w	#$f000,d0
	lsr.w	#4,d0
	or.l	d0,c2numpad-DATA(a3)

	lsl.l	#7,d3	; d3 contains xxxx,c1midbuts,c1firebuts,c1joypad
	lsl.l	#4,d4
	or.l	d4,d3
	or.l	d5,d3	

	lsl.l	#7,d6	; d6 = xxxx,c2midbuts,c2firebuts,c2joypad
	lsl.l	#4,d7
	or.l	d7,d6
	move.l	a0,d2
	or.l	d2,d6

	move.l	c1numpad-DATA(a3),d2	; d2 = c1numpad
	lsl.l	#5,d2
	move.l	c2numpad-DATA(a3),d5	; d5 = c2numpad
	lsl.l	#5,d5

	or.l	d2,d3
	or.l	d5,d6

	rts

read_controller
	move.w	d0,$ff9202
	move.w	$ff9200,d1
	move.w	$ff9202,d2

	andi.w	#$f,d1
	andi.w	#$ff00,d2

	not.w	d1
	not.w	d2

	rts


*** The end.....

LIBEX	dc.w	0