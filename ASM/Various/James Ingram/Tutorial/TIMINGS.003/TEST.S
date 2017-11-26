* Timings Tester
* by James Ingram, March 1994

	opt	x+,o-,ow-



	include	includes\macros.s
	
	super_on

* keep all timing data intact...
	lea	old(pc),a0

	move.w	$ffff8240.w,(a0)+
	move.b	$fffffa07.w,(a0)+	; enable A
	move.b	$fffffa09.w,(a0)+	; enable B
	move.b	$fffffa13.w,(a0)+	; mask A
	move.b	$fffffa15.w,(a0)+	; mask B
	move.b	$fffffa19.w,(a0)+	; A control
	move.b	$fffffa1b.w,(a0)+	; B control
	move.b	$fffffa1d.w,(a0)+	; C & D control
	move.b	$fffffa1f.w,(a0)+	; A data
	move.b	$fffffa21.w,(a0)+	; B data
	addq.l	#1,a0
	
	move.l	$134.w,(a0)+		; timer A vector
	move.l	$120.w,(a0)+		; timer B vector
	move.l	$114.w,(a0)+		; timer C vector

	
loop:
	lea	intro(pc),a0
	bsr	print_mes
	bsr	inp

	sub.b	#"0",d0
	bmi	loop		; loop if less than 0
	
	cmp.w	#4,d0
	bge	loop		; or > 3!
	
	lsl.w	#2,d0
	lea	routs(pc),a0	; get list of routines
	move.l	(a0,d0.w),a0
	jmp	(a0)		; jump to correct one

routs:
	dc.l	quit
	dc.l	a
	dc.l	b
	dc.l	c

quit:

* restore everything!

	lea	old(pc),a0
	move.w	(a0)+,$ffff8240.w

	move.b	(a0)+,$fffffa07.w	; enable A
	move.b	(a0)+,$fffffa09.w	; enable B
	move.b	(a0)+,$fffffa13.w	; mask A
	move.b	(a0)+,$fffffa15.w	; mask B
	move.b	(a0)+,$fffffa19.w	; A control
	move.b	(a0)+,$fffffa1b.w	; B control
	move.b	(a0)+,$fffffa1d.w	; C & D control
	move.b	(a0)+,$fffffa1f.w	; A data
	move.b	(a0)+,$fffffa21.w	; B data
	addq.l	#1,a0
	
	move.l	(a0)+,$134.w		; timer A vector
	move.l	(a0)+,$120.w		; timer B vector
	move.l	(a0)+,$114.w		; timer C vector

	move.b	#255,$fffffa23.w	; C data

	super_off

	clr.w	-(a7)
	trap	#1


my_a:
	eor.w	#$0ff,$ffff8240.w
	bclr	#5,$fffffa0f.w
	rte

my_b:
	eor.w	#$0f0,$ffff8240.w
	bclr	#0,$fffffa0f.w
	rte

my_c:
	eor.w	#$fff,$ffff8240.w
	bclr	#5,$fffffa11.w
	rte


a:
	lea	atxt(pc),a0
	bsr	get_a_b

* install timer A!!!
	clr.b	$fffffa19.w		; timer A off

	move.l	#my_a,$134.w

	move.b	data,$fffffa1f.w	; data in
	move.b	mode,$fffffa19.w	; control in

	bset.b	#5,$fffffa07.w		; enable ON
	bset.b	#5,$fffffa13.w		; mask ON

	move.w	old,$ffff8240.w		; colour back to normal

	bra	loop



b:
	lea	btxt(pc),a0
	bsr	get_a_b

* initialise B!
	clr.b	$fffffa1b.w		; timer B off
	move.l	#my_b,$120.w

	bset.b	#0,$fffffa13.w
	bset.b	#0,$fffffa07.w		; mask it in

	move.b	data,$fffffa21.w	; data in
	move.b	mode,$fffffa1b.w	; control mode


	move.w	old,$ffff8240.w		; colour back to normal
	bra	loop

c:
* get timer C data
	lea	ctxt(pc),a0
	bsr	print_mes

	lea	input(pc),a0
	bsr	get_inp
	tst.w	d0
	beq	loop


	lea	input+2(pc),a0
	bsr	num_to_bin

	and.w	#7,d0
	move.b	d0,mode

* now data
	bsr	get_data

* initialise!
	and.b	#%00001111,$fffffa1d.w	; C off!

	move.l	#my_c,$114.w		; routine address
	bset	#5,$fffffa09.w
	bset	#5,$fffffa15.w		; mask it in
	
	move.b	data,$fffffa23.w	; data in
	move.b	mode,d0
	lsl.b	#4,d0			; mode in upper nybble
	or.b	$fffffa1d.w,d0		; keep timer D
	move.b	d0,$fffffa1d.w


	bra	loop

get_a_b:
	bsr	print_mes

	lea	input(pc),a0
	bsr	get_inp
	tst.w	d0
	beq	loop		; loop if ENTER pressed

	lea	input+2(pc),a0
	bsr	num_to_bin	; get binary number
	
	tst.l	d1
	bmi	loop		; loop if invalid

* got MODE NUMBER!
	and.w	#15,d0
	move.b	d0,mode

* now get the DATA
	bsr	get_data
	rts


get_data:
	lea	getdata(pc),a0
	bsr	print_mes
	
	lea	input(pc),a0
	bsr	get_inp
	lea	input+2(pc),a0
	bsr	num_to_bin
	
	move.b	d0,data
	rts


atxt:
	dc.b	10,13,10
	dc.b	"TIMER A",10,13
	dc.b	"Enter mode (0 - 15)",10,13,0

btxt:
	dc.b	10,13,10
	dc.b	"TIMER B",10,13
	dc.b	"Enter mode (0-15)",10,13,0

ctxt:
	dc.b	10,13,10
	dc.b	"TIMER C",10,13
	dc.b	"Enter mode (0 - 7)",10,13,0

getdata:
	dc.b	10,13
	dc.b	"Enter DATA value:",10,13,0


input:
	dc.b	10,0
	ds.b	10


intro:
	dc.b	27,"ETimings Tester",10,13
	dc.b	    "--------------",10,13
	dc.b	"by James Ingram, March 1994",10,13,10
	dc.b	"Select:",10,13
	dc.b	"1... Timer A",10,13
	dc.b	"2... Timer B",10,13
	dc.b	"3... Timer C",10,13,10
	dc.b	"0... QUIT",10,13,0
	even

	
	
	include	includes\misc.s

	section	bss

old:
	ds.w	1
	ds.b	12
	ds.l	3

mode	ds.b	1
data	ds.b	1
