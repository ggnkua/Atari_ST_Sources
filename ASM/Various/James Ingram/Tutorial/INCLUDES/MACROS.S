* misc macros
* by James Ingram, March 1994

super_on	macro
	clr.l	-(a7)
	move.w	#32,-(a7)
	trap	#1		; super mode on
	addq.l	#6,a7
	move.l	d0,-(a7)
	endm

super_off	macro
	move.w	#32,-(a7)
	trap	#1
	addq.l	#6,a7
	endm

cls	macro
	move.w	#3,-(a7)
	trap	#14
	addq.l	#2,a7

	move.l	d0,a0
	move.w	#32000/4-1,d0
clear_the_screen:
	clr.l	(a0)+
	dbra	d0,clear_the_screen
	endm


init_chip	macro
* initialise sound chip
	move.w	#$8800,a0

	move.l	#init_mus,a2

do_init_mus:
	move.w	(a2)+,d0
	bmi.s	end_init_mus

	movep.w	d0,(a0)
	bra.s	do_init_mus

init_mus:
	dc.w	$0000
	dc.w	$0100
	dc.w	$0200
	dc.w	$0300
	dc.w	$0400
	dc.w	$0500
	dc.w	$0600
	dc.b	$07,%01111111
	dc.w	$0d00

	dc.w	-1

end_init_mus:
	endm



* Macro definitions for timers

enable_a	equ	$fffffa07
enable_b	equ	$fffffa09
mask_a	equ	$fffffa13
mask_b	equ	$fffffa15
a_control	equ	$fffffa19
b_control	equ	$fffffa1b
cd_control	equ	$fffffa1d
a_data	equ	$fffffa1f
b_data	equ	$fffffa21
vector	equ	$fffffa17

bit_a	equ	5
bit_b	equ	0
bit_c	equ	5


keep_timers	macro
* keep all timing data intact...
	move.l	#old,a0
	move.b	enable_a.w,(a0)+	; enable A
	move.b	enable_b.w,(a0)+	; enable B
	move.b	mask_a.w,(a0)+		; mask A
	move.b	mask_b.w,(a0)+		; mask B
	move.b	a_control.w,(a0)+	; A control
	move.b	b_control.w,(a0)+	; B control
	move.b	cd_control.w,(a0)+	; C & D control
	move.b	a_data.w,(a0)+		; A data
	move.b	b_data.w,(a0)+		; B data
	move.b	vector.w,(a0)+
	
	move.l	$134.w,(a0)+		; timer A vector
	move.l	$120.w,(a0)+		; timer B vector
	endm


restore_timers	macro
	move.l	#old,a0

	move.b	(a0)+,enable_a.w	; enable A
	move.b	(a0)+,enable_b.w	; enable B
	move.b	(a0)+,mask_a.w		; mask A
	move.b	(a0)+,mask_b.w		; mask B
	move.b	(a0)+,a_control.w	; A control
	move.b	(a0)+,b_control.w	; B control
	move.b	(a0)+,cd_control.w	; C & D control
	move.b	(a0)+,a_data.w		; A data
	move.b	(a0)+,b_data.w		; B data
	move.b	(a0)+,vector.w
	
	move.l	(a0)+,$134.w		; timer A vector
	move.l	(a0)+,$120.w		; timer B vector
	endm

old	macro
old:
	ds.b	12
	ds.l	2

old_70	ds.l	1
	endm

c_off	macro
	move.b	mask_b.w,-(a7)
	bclr.b	#5,mask_b.w
	endm

c_on	macro
	move.b	(a7)+,mask_b.w
	endm


put1	macro

c	set	0

	rept	4

	movem.l	(a1)+,d1-7
	movep.l	d1,c(a0)
	movep.l	d2,c+160(a0)
	movep.l	d3,c+320(a0)
	movep.l	d4,c+480(a0)
	movep.l	d5,c+640(a0)
	movep.l	d6,c+800(a0)
	movep.l	d7,c+960(a0)	; 7 lines done

c	set	c+1120

	endr



* done 28 LONGWORDs - just 4 more to do
	movem.l	(a1)+,d1-4
	movep.l	d1,c(a0)
	movep.l	d2,c+160(a0)
	movep.l	d3,c+320(a0)
	movep.l	d4,c+480(a0)

	endm


put2	macro
* do it all over again for the next byte...

c	set	1
	rept	4

	movem.l	(a1)+,d1-7
	movep.l	d1,c(a0)
	movep.l	d2,c+160(a0)
	movep.l	d3,c+320(a0)
	movep.l	d4,c+480(a0)
	movep.l	d5,c+640(a0)
	movep.l	d6,c+800(a0)
	movep.l	d7,c+960(a0)	; 7 lines done

c	set	c+1120
	endr

* done 28 LONGWORDs - just 4 more to do
	movem.l	(a1)+,d1-4
	movep.l	d1,c+0(a0)
	movep.l	d2,c+160(a0)
	movep.l	d3,c+320(a0)
	movep.l	d4,c+480(a0)


	endm


calc_chars	macro
	move.l	#font,d0	; 1st char address
	move.l	#chars,a0	; address of list
	moveq	#60-1,d1	; do 60 chars

.loop:
	move.l	d0,(a0)+	; put address in list
	add.l	#512,d0		; next address
	dbra	d1,.loop
	endm


free_mem	macro
	move.l	4(a7),a5
	move.l	#stack,a7
	move.l	$c(a5),a0
	add.l	$14(a5),a0
	add.l	$1c(a5),a0
	lea	$100(a0),a0
	pea	(a0)
	pea	(a5)
	clr.w	-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	lea	12(a7),a7
	endm

