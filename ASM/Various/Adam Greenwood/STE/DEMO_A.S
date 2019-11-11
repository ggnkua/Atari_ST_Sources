* STE DMA sound example program A.

* Load and play a sample

* Copyright 1991 A Greenwood.

* Feel free to change and use any of this code.

* Source code written with Devpac 2
* local variables etc. may need changing for other assemblers

* First the constants

* DMA Sound chip registers
mode	equ	$ff8920		stereo/Mono & frequency
enable	equ	$ff8900		enable register
f_strt_h	equ	$ff8902		frame start high
f_end_h	equ	$ff890e		frame end high

* Start of main program

start	move.l	a7,a5           
	move.l	#newstack,a7	set new stack	
	move.l	4(a5),a5		get basepage
	move.l	$c(a5),d0		get legth of text segment
	add.l	$14(a5),d0	add length of data segment
	add.l	$1c(a5),d0	add length of uninit BSS
	add.l	#$100,d0		add length of basepage
	move.l	d0,-(a7)		push length to reserve
	move.l	a5,-(a7)		start address to modify
	move.w	#0,-(a7)		zero
	move.w	#$4a,-(a7)	shrink memory
	trap	#1
	add.l	#$c,a7

	clr.l	-(a7)		set supervisor mode
	move.w	#32,-(a7)
	trap	#1
	addq	#6,a7
	move.l	d0,save_stk	save value of old stack

* call routines
	
	jsr	load_spl		load sample
	jsr	playit		play sample
	
* Sound will now play without further attention
	
.getkey	move.w	#7,-(a7)		Get keypress
	trap	#1
	addq	#2,a7		Returns d0.l

	swap	d0		highword is keyscan code

	cmp.b	#57,d0		spacebar = quit.
	bne.s	.getkey
	bra	fin

* Routine to load a sample into memory
* Gets length of sample, allocates memory
* then loads sample
* a6 = filename address

load_spl	movem.l	d0-d7/a0-a6,-(a7)
	
	move.w	#2,-(a7)		find file
	move.l	#fname,-(a7)	d0.l = -33 fnf
	move.w	#78,-(a7)		else d0.l = DTA address
	trap	#1		creates DTA including
	addq	#8,a7		file size
	
	move.w	#47,-(a7)		get DTA address
	trap	#1
	addq	#2,a7

	move.l	d0,a0
	move.l	26(a0),d7		d7 = length of file

	move.l	d7,-(a7)
	move.w	#72,-(a7)
	trap	#1		allocate memory
	addq	#6,a7
	addq	#1,d0
	bclr	#0,d0		d0 = start of allocated mem

	move.l	d0,d6		d6 = start of sample
	add.l	d7,d0		d0 = end of sample

	move.l	d6,smpl_strt	save start/end addresses
	move.l	d0,smpl_end

	move.w	#0,-(a7)
	move.l	#fname,-(a7)
	move.w	#61,-(a7)		open file
	trap	#1
	move.w	d0,d5
	add.w	#8,a7

	move.l	d6,-(a7)
	move.l	d7,-(a7)		read sample
	move.w	d5,-(a7)
	move.w	#63,-(a7)
	trap	#1
	add.w	#12,a7

	move.w	d5,-(a7)
	move.w	#62,-(a7)		close file
	trap	#1
	addq	#4,a7
	
	movem.l	(a7)+,d0-d7/a0-a6
	rts

* Routine which plays sample

playit	move.w	#0,d0
	move.b	freq,d0		combine frequency and 
	move.w	ster,d1		stereo/mono
	or.w	d1,d0		to set mode	
	move.w	d0,mode

	move.l	smpl_strt,d0
	move.l	smpl_end,d1
	jsr	sample_ad		set frame address
	move.w	#3,enable		enable sound, repeat mode

	rts

* Routine to set start and end addresses for a sample
* d0.l = start address
* d1.l = end address
* uses movep to set alternate bytes

sample_ad	movem.l	d0-d1/a0,-(a7)

	move.l	#f_strt_h,a0	frame start high
	movep.w	d0,3(a0)		set start mid & low
	swap	d0
	move.b	d0,1(a0)		set start high
	
	move.l	#f_end_h,a0	frame end high
	movep.w	d1,3(a0)		set end mid & low
	swap	d1
	move.b	d1,1(a0)		set end high

	movem.l	(a7)+,d0-d1/a0
	rts

* Return to user mode and exit

fin	move.w	#0,enable		turn off sound
	
	lea	save_stk,a6	get value of original stack
	move.l	(a6),-(a7)
	move.w	#32,-(a7)
	trap	#1		return to user mode
	addq	#6,a7

	move.w	#0,-(a7)		exit program
	trap	#1
	addq	#2,a7

	section	data

* filename for sample

fname	dc.b	'GUN1.SPL',0

* Playback frequency for ALL samples
* 0 = 6.25 KHz, 1 = 12.5 KHz, 2 = 25 KHz, 3 = 50 KHz

freq	dc.b	2

	even
	
* Stereo/Mono mode
* $00 = stereo, $80 = mono

ster	dc.w	$80

	section	bss

	even

save_stk	ds.l	1

	ds.l	250
newstack	ds.l	1

* storage for sample start/end addresses

smpl_strt	ds.l	1
smpl_end	ds.l	1

	end