;
;
;
;
;	4k intro, april '97 -
;
;	steve tattersall
;
;	create the file 4K.PRG, then pack using Atomik as a DATA file
;
;
;
;
;
;
;
;
;
;





screenlines		equ	240
bytesperline		equ	320*2
lines			equ	240
pixels			equ	320

exit			equ	1
bss			equ	1
print			equ	0

worldsize		equ	$2000
number_of_fish		equ	100		;however many you want!

;----------------------------------------------------------------
; the demo is pc-relative to save on the size of the depack code...
;
		opt	p+			;must be pc-relative
		opt	nodebug			;rather important











; -------------------------------------------------------------------------

* Obvious things:
OFF		equ	0
ON		equ	1



*--------------------------- Macros ---------------------------
wait_transmit	macro
	btst	#1,$ffffa202.w
	beq.s	*-6
	endm

wait_receive	macro
	btst	#0,$ffffa202.w
	beq.s	*-6
	endm


start:
		ifne	print
		pea	printstring(pc)
		move.w	#9,-(a7)
		trap	#1
		move.w	#8,-(a7)
		trap	#1
		addq.l	#8,a7
		endc

		clr.l	-(a7)
		move.w	#$20,-(a7)
		trap	#1
		addq.l	#6,a7			;use existing stacks

		ifne	exit
		movec	cacr,d0
		move.l	d0,-(a7)
		endc

		lea	offset_base(pc),a6
		lea	$ffffa204.w,a5

		ifne	bss
		move.l	a6,a0
		move	#$10000-1,d0
.clear		clr.l	(a0)+
		dbf	d0,.clear
		endc

		move.l	#bytesperline*lines+256,d1
		move.l	$44e.w,d0
		sub.b	d0,d0
		sub.l	d1,d0
		move.l	d0,logic-offset_base(a6)
		sub.l	d1,d0
		move.l	d0,physic-offset_base(a6)
		sub.l	d1,d0
		move.l	d0,third-offset_base(a6)

;--------------------------------------------------------------
;
;
;	general initialisation
;
;
;--------------------------------------------------------------

initialize_routine:
		ifne	exit
		move.l	$44e.w,old_44e-offset_base(a6)
		endc

		move.w	#$114,-(a7)
		move.w	#3,-(a7)
		move.l	physic(pc),-(a7)
		move.l	logic(pc),-(a7)
		move.w	#5,-(a7)
		trap	#14
		;lea.l	14(a7),a7
		move.w	#1,-(a7)
		pea	codelen.w		;note longword
		pea	code(pc)
		move.w	#109,-(a7)
		trap	#14
		lea	12+14(a7),a7

;--------------------------------------------------------------

		ifeq	exit
		clr.l	$fffffa06.w		;interrupts off
		clr.l	$ffff9800.w		;black background
		endc

;--------------------------------------------------------------
; get sine wave:
		lea	sinewave(pc),a0
		move.w	#512-1,d0
.get:		 ;wait_receive
		move.l	(a5),(a0)+
		dbf	d0,.get	


;--------------------------------------------------------------
; send division table:
; can send it backwards to save space? ;-)
; ... but then uses more dsp memory

		moveq	#0,d0
.sendy:
		move.l	#$7fffff,d1
		tst.w	d0
		beq	.skipdiv
		divu.l	d0,d1
.skipdiv:	 ;wait_transmit
		move.l	d1,(a5)
		addq.l	#1,d0
		cmp.w	#384,d0
		bne.s	.sendy

;--------------------------------------------------------------
;
;
;	main screen loop
;
;
;--------------------------------------------------------------

		bsr	send_texmap2
		bsr	create_fishes

		move.l	#$0009,d0
		movec	d0,cacr

;--------------------------------------------------------------
.infinite:
		bsr	create_frame

		ifne	exit
		cmp.b	#$39,$fffffc02.w
		bne.s	.infinite
;--------------------------------------------------------------

		move.w	#2,-(a7)
		move.l	old_44e(pc),-(a7)
		move.l	old_44e(pc),-(a7)
		move.w	#5,-(a7)
		trap	#14
		lea	12(a7),a7

		move.l	(a7)+,d0
		movec	d0,cacr

		clr.w	-(a7)
		trap	#1
		else
		bra	.infinite
		endc


;--------------------------------------------------------------
;
;
;	frame creation routine
;
;
;--------------------------------------------------------------
create_frame:
		bsr	clearscreen

; rotate our world:
		movem.l	rotation_x-offset_base(a6),d0/d1/d2
		add.l	#2,d0
		add.l	#1,d1
		add.l	#1,d2
		moveq.l	#$20,d2
		movem.l	d0/d1/d2,rotation_x-offset_base(a6)

		move.w	#number_of_fish-1,d0
		lea	object_1_data(pc),a0
.fishloop:	move.w	d0,-(a7)
		pea	(a0)
		bsr	start_one_object
		move.l	(a7)+,a0
		lea	object_size(a0),a0
		move.w	(a7)+,d0
		dbf	d0,.fishloop

		; now falls through!!
;--------------------------------------------------------------
screen_swap:
		move.l	logic-offset_base(a6),d0
		move.l	third-offset_base(a6),logic-offset_base(a6)
		move.l	physic-offset_base(a6),third-offset_base(a6)
		move.l	d0,physic-offset_base(a6)
		lsr.w	#8,d0
		move.l	d0,$ffff8200.w
		rts

;--------------------------------------------------------------
start_one_object:
		move.l	a0,current_object-offset_base(a6)
		move.l	a0,a1
		moveq	#3-1,d1
.fishmove
		move.l	(a1),d0
		sub.l	object_speedx-object_x(a1),d0
		and.l	#worldsize*2-1,d0
		sub.l	#worldsize,d0
		move.l	d0,(a1)+
		dbf	d1,.fishmove


;--------------------------------------------------------------

send_viewpoint:
		moveq	#3-1,d0			;for view pos
		lea	viewer_z-offset_base(a6),a2
.loop:
		move.l	(a0)+,d1
		add.l	(a2)+,d1
		 wait_transmit
		move.l	d1,(a5)
		dbf	d0,.loop

		lea	camera_z-offset_base(a6),a2
		moveq	#3-1,d0			;for view pos
.loop2:
		move.l	(a2)+,d1
		move.l	d1,(a5)
		dbf	d0,.loop2

		move.l	viewer_size-offset_base(a6),(a5)

;--------------------------------------------------------------
makematrixobject:
		movem.l	rotation_x-offset_base(a6),d0/d1/d2
		move.w	#$ff,d3
		and.w	d3,d0
		and.w	d3,d1
		and.w	d3,d2
		lea	coswave(pc),a0
		lea	sinewave(pc),a1

		 wait_transmit
		move.l	(a0,d0.w*4),(a5)
		move.l	(a1,d0.w*4),(a5)
		move.l	(a0,d1.w*4),(a5)
		move.l	(a1,d1.w*4),(a5)
		move.l	(a0,d2.w*4),(a5)
		move.l	(a1,d2.w*4),(a5)
		bra	draw_object




;--------------------------------------------------------------
; note: this routine clears a little bit more memory than is
;       needed... so be careful
;

myscreensize	equ	bytesperline*screenlines
reptval     	equ	(myscreensize/13/4)
remainder	equ	(myscreensize-(reptval*13*4))/4

clearscreen:
		movem.l	d0-a6,-(a7)
		move.l	logic(pc),a6
		add.l	#myscreensize,a6
		movem.l	clearbytes(pc),d1-a5
		move.w	#(reptval+1)-1,d0
.wipe:		movem.l d1-a5,-(a6)
		dbf	d0,.wipe

		movem.l	(a7)+,d0-a6

drawing_done:	rts


;--------------------------------------------------------------






;--------------------------------------------------------------
;
;
;	3d draw routine
;
;
;--------------------------------------------------------------
draw_object:
		move.l	logic-offset_base(a6),a4
		add.l	#(pixels/2)*2+bytesperline*(lines/2),a4
		move.w	#bytesperline,d7
		lea	$ffffa206.w,a1
handleloop:
		wait_receive
		move.w	(a1),d0
		bmi.s	drawing_done

		wait_receive
		move.w	(a1),d6			;get top_height
		muls.w	d7,d6			;can't replace this??
		lea	(a4,d6.l),a0
		move.w	(a1),d1
		subq.w	#1,d1
		bmi.s	.dontdo
.printpoly:
		 wait_receive
		move.w	(a1),d2
		lea	(a0,d2.w*2),a3

		 wait_receive
		move.w	(a1),d3
		subq.w	#1,d3
		bmi.s	.next

		 ;wait_receive
.pp	 	move.w	(a1),(a3)+
		dbra	d3,.pp
.next		add.l	d7,a0

		dbf	d1,.printpoly
.dontdo		bra.s	handleloop









;--------------------------------------------------------------
send_texmap2:
		; wait_transmit
		;move.l	#tex,(a5)

		moveq	#64-1,d7
		moveq	#-31,d1
.line:
		moveq	#64-1,d6
		moveq	#-31,d0
		move.w	d1,d2
		muls	d2,d2
.pixel:
		move.w	d0,d3
		muls	d3,d3
		add.l	d2,d3
		asr.l	#4,d3
		 ;wait_transmit
		move.w	(colour_table,pc,d3.w*2),$ffffa206.w
		addq.w	#1,d0		
		dbf	d6,.pixel
		addq.w	#1,d1		
		dbf	d7,.line
		rts


;--------------------------------------------------------------
		rsreset
object_x	rs.l	1
object_y	rs.l	1
object_z	rs.l	1
object_speedx	rs.l	1
object_speedy	rs.l	1
object_speedz	rs.l	1
object_size	rs.b	1

; "Time to swim wit' da fishes"
;
;
;
;
;
create_fishes:
		lea	object_1_data(pc),a0
		move.w	#number_of_fish-1,d7

.fishloop:
		moveq	#3-1,d6
.fishxyz:
		bsr	get_random
		and.w	#worldsize*2-1,d0
		sub.w	#worldsize,d0
		ext.l	d0
		move.l	d0,(a0)+
		dbf	d6,.fishxyz

		bsr	get_random
		and.w	#255,d0
		add.w	#worldsize+32,d0
		ext.l	d0
		move.l	d0,(a0)+

		moveq	#2-1,d6
.fishspd	bsr	get_random
		and.w	#15,d0
		add.w	#worldsize,d0
		ext.l	d0
		move.l	d0,(a0)+
		dbf	d6,.fishspd

		dbf	d7,.fishloop
		rts

; This just generates a crap random number to make all the
; positions and speeds of the fish

get_random:	movem.w	random_seed(pc),d0/d1/d2
		add.w	d2,d1
		add.w	d1,d0
		add.w	#23,d0
		mulu.w	#59,d0
		mulu.w	#29,d1
		add.w	#17,d1
		mulu.w	#9,d2
		addq.w	#7,d2
		movem.w	d0/d1/d2,random_seed-offset_base(a6)
		rts



;--------------------------------------------------------------
			section data
;--------------------------------------------------------------

camera_z:		
viewer_distance:	dc.l	worldsize
camera_x:		dc.l	0
camera_y:		dc.l	0


viewer_size:		dc.l	8000*2


;--------------------------------------------------------------
;	dsp routines
;--------------------------------------------------------------

code:
			incbin	d:\dsp\asm\4k.cld
			;incbin	d:\dsp\asm\4k\4k10.cld
codelen 		equ	(*-code)/3					

			even

;--------------------------------------------------------------
;	3d objects
;--------------------------------------------------------------

			ifne	print
printstring:		dc.b	27,"esmall, but beautifully formed...",0
			even
			endc


;--------------------------------------------------------------
;	graphics
;--------------------------------------------------------------
; This is the colour table for the fish texture map
; values are true colour screen values
; It starts with "white" then goes down to black

colour_table:
o		set	%1111111111111111
		dcb.w	2,o
		rept	7
		dc.w	o
o		set	o-$041*4
		endr				;---> red
		rept	31/4
		dc.w	o
o		set	o-(4*$800)		;---> black
		dc.w	o
		endr
		rept	2
		dc.w	o
o		set	o+$841+$800		;---> blue
		endr

		dcb.w	16,o

;--------------------------------------------------------------
			section	bss
			ds.l	100		;just to be sure

offset_base		equ	*
logic			ds.l	1
physic			ds.l	1
third			ds.l	1

			ifne	exit
old_44e			ds.l	1
			endc

clearbytes		ds.l	16

viewer_z:		ds.l	1
viewer_x:		ds.l	1
viewer_y:		ds.l	1

current_object:		ds.l	1
rotation_x:		ds.l	1
rotation_y:		ds.l	1
rotation_z:		ds.l	1

random_seed		ds.w	3

object_1_data:		ds.b	object_size*number_of_fish

coswave			equ	*+(4*64)
sinewave		ds.l	256*2

			ds.l	300
stack

