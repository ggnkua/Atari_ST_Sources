
;	A very simple example assembly application which runs as
;	either a program or a desk accessory. Does no window or
;	menubar handling. I figure anyone who does that in assembly
;	is a little crazy.
;	(With all due respect to the many excellent crazy programmers
;	out there...)

;	Assemble with Hisoft Devpac or anything with similar macros
;	"Real men don't use Macros..."
;	"It's just an example (whimper whimper)"

;       by Samuel Streeper
;       Copyright 1989 Antic Publishing

	include	gemmacro.s

start
	lea		start,a5
	suba	#$100,a5		a5 -> base page

	lea		stack,sp

	moveq	#0,D5
	tst.l	36(A5)			Parent basepage pointer clear if ACC
	sne		D5				D5 set if application
	move	D5,app
	beq     cont			is an accessory

	move.l	$c(a5),d0		text len
	add.l	$14(a5),d0		data len
	add.l	$1c(a5),d0		BSS len
	add.l	#$100,d0		basepage

	move.l	d0,-(sp)
	move.l	a5,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1				shrink memory
	lea	12(sp),sp

cont
	appl_init
	move.w	d0,ap_id		store the application id

	tst		app
	beq		c1

							;I am a program
	graf_mouse	#0			set the mouse to an arrow
	form_alert	#1,#prgalert
	clr		-(sp)
	trap	#1

c1:							;I am a desk accessory
	menu_register	ap_id,#menu

							;the main loop of the application
							;only interested in message events
waitforevent
	evnt_mesag	#messagebuf
	move.l	#messagebuf,a0
	move.w	(a0),d0			;message type
	cmp.w	#40,d0
	beq	open_acc
	bra.s	waitforevent

open_acc
	form_alert	#1,#accalert
	bra	waitforevent

	SECTION	DATA

;all C strings must end in a null
menu	dc.b	'  prgacc demo',0

accalert dc.b	'[1][Running as a Desk Accessory|Yow!][ OK ]',0

prgalert dc.b	'[1][Running as a Program|Yow!][ OK ]',0

;global constants
	SECTION	BSS

app			ds.w 1
ap_id		ds.w 1
messagebuf	ds.b 16

		ds.l	200
stack	ds.w	1


	IFEQ	__LK
	include	aeslib.s
	ENDC
