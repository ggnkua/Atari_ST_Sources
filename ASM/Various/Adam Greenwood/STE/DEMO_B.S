* STE DMA sound example program B.

* Linking samples using the Timer A interrupt.

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

* System variables for interrupts
timera	equ	$134		timer A vector

* MFP 68901 Addresses
iea	equ	$fffa07		interrupt Enable A
isra	equ	$fffa0F		in Service A
ima	equ	$fffa13		interrupt Mask A
tacr	equ	$fffa19		timer A Control
tadr	equ	$fffa1f		timer A Data

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

	clr.l	-(a7)		Set supervisor mode
	move.w	#32,-(a7)
	trap	#1
	addq	#6,a7
	move.l	d0,save_stk	save value of old stack

* call routines

	jsr	load_all		load all samples
	jsr	playit		play samples
	
* Sound will now play without further attention
* Now loop getting keypress to look after volume/tone
	
.getkey	move.w	#7,-(a7)		get keypress
	trap	#1
	addq	#2,a7		returns d0.l

	swap	d0		highword is keyscan code

	cmp.b	#57,d0		spacebar = quit.
	bne.s	.getkey
	bra	fin

* Routine which loads all files listed in data section

load_all	movem.l	d0-d2/a6,-(a7)
	move.w	#0,d0
	move.l	#fnames,a6	
.loop	move.b	(a6),d1		check for end of list
	beq	.out
	jsr	load_spl
	add.w	#1,d0
.findend	move.b	(a6)+,d2		find end of filename
	bne.s	.findend
	bra.s	.loop		loop round for next
	
.out	movem.l	(a7)+,d0-d2/a6
	rts
	
* Routine to load a sample into memory
* Gets length of sample, allocates memory
* then loads sample
* d0.w = sample no.
* a6 = filename address
* Assumes file exists

load_spl	movem.l	d0-d7/a0-a6,-(a7)
	
	move.l	#sam_recs,a5	
	mulu	#8,d0
	add.w	d0,a5		a5 = sample record address
	
	move.w	#2,-(a7)		find file
	move.l	a6,-(a7)		d0.l = -33 fnf
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

	move.l	d6,(a5)+		save start/end addresses
	move.l	d0,(a5)+

	move.w	#0,-(a7)
	move.l	a6,-(a7)
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

* Routine which sets up and plays samples
* Once this is done the sequence can be left to play
* and the rest of the program can do what it wants

playit	move.w	#0,d0
	move.b	freq,d0		combine frequency and 
	move.w	ster,d1		stereo/mono
	or.w	d1,d0		to set mode	
	move.w	d0,mode

	move.l	#smpl_list,a1	sample list
	move.l	#loop_list,a2	loop list 

	move.l	#sam_recs,a0	
	move.w	#0,d0
	move.b	(a1)+,d0		get index and use it
	mulu	#8,d0		to find sample
	add.w	d0,a0
	move.l	(a0)+,d0		get sample addresses
	move.l	(a0)+,d1
 	jsr	sample_ad		set addresses
	move.w	#3,enable		enable sound, repeat mode

	jsr	init_int		initialise timer A interrupt

* Now get next sample ready so that we are looking ahead
* 1 sample

	move.b	(a2)+,d3		repeat for first sample
	sub.b	#1,d3		check whether need to
	bne.s	.set		load next address

	move.w	#0,d0		get index
	move.b	(a1)+,d0		for second sample
	move.l	#sam_recs,a0	
	mulu	#8,d0		
	add.w	d0,a0		
	move.l	(a0)+,d0		start address of next sample
	move.l	(a0)+,d1		end address of next sample
	jsr	sample_ad		next sample ready for end
	move.b	(a2)+,d3		of current

.set	move.b	#0,tacr		set timer A countdown to 
	move.b	d3,tadr		correct number of loops
	move.b	#8,tacr		using event countdown	

	move.l	a1,smpl_ptr	save list pointers
	move.l	a2,loop_ptr

	rts

* Routine to initialise Timer A 
* STE provides interrupt after sample has finished playing
* Using event countdown mode we only get the interrupt after
* the sample has played the correct number of times

init_int	move.b	iea,old_iea	save state of MFP
	move.b	ima,old_ima
	move.b	tadr,old_tadr
	move.b	tacr,old_tacr
	move.l	timera,old_vec	save old Timer A vector

	and.b	#$df,iea		disable Timer Interrupt
	move.l	#tim_rtn,timera	address of our routine
	or.b	#$20,iea		re-enable Timer A interrupt
	or.b	#$20,ima		set Timer A Mask
	rts
	
* Interrupt handler called when sample finished.
* This is the routine which actually loads up the address of the 
* next sample.
* Using event countdown this is called after a specified
* number of interrupts

tim_rtn	movem.l	d0-d3/a0-a2,-(a7)
				
	move.b	#0,tacr		stop timer

	move.l	smpl_ptr,a0	get index of next sample
	move.l	loop_ptr,a2	get number of times to play

	move.b	(a2),d0		repeat for next sample			
	cmp.b	#0,d0		check for end
	bne	.doit
	move.l	#smpl_list,a0	if end back to start
	move.l	#loop_list,a2

.doit	move.l	#sam_recs,a1
	clr.l	d0
	move.b	(a0)+,d0		use index to get
	mulu	#8,d0		start and end address
	add.w	d0,a1		of sample
	move.l	(a1)+,d0
	move.l	(a1)+,d1
	jsr	sample_ad
	move.b	(a2)+,tadr	set repeat
 
	move.l	a0,smpl_ptr	move along list
	move.l	a2,loop_ptr
	
	bclr	#5,isra		re-enbale lower level interupts
	move.b	#8,tacr		restart timer

	movem.l	(a7)+,d0-d3/a0-a2
	rte
	
* Routine to set start and end addresses for a sample
* d0.l = start address
* d1.l = end address
* uses movep to set alternate bytes

sample_ad	movem.l	d0-d1/a0,-(a7)

	move.l	#f_strt_h,a0	Frame start high
	movep.w	d0,3(a0)		Set start mid & low
	swap	d0
	move.b	d0,1(a0)		Set start high
	
	move.l	#f_end_h,a0	Frame end high
	movep.w	d1,3(a0)		Set end mid & low
	swap	d1
	move.b	d1,1(a0)		Set end high

	movem.l	(a7)+,d0-d1/a0
	rts

* Return to user mode and exit

fin	move.w	#0,enable		turn off sound
	
	move.w	sr,-(a7)		save status register
	move.w	#$2700,sr		disbale all interrupts
	move.l	old_vec,timera	restore Timer A vector
	move.b	old_iea,iea	restore MFP
	move.b	old_ima,ima	
	move.b	old_tadr,tadr
	move.b	old_tacr,tacr
	move.w	(a7)+,sr		restore status register
	
	lea	save_stk,a6	get value of original stack
	move.l	(a6),-(a7)
	move.w	#32,-(a7)
	trap	#1		return to user mode
	addq	#6,a7

	move.w	#0,-(a7)		exit program
	trap	#1
	addq	#2,a7

	section	data

* List of filenames, in the order they will be in memory
* Make sure every filename is null terminated, ie has 0 after
* it, and that the list is terminated by a 0.
* There is currently strorage for 20 sample start/end address
* records, for more change sam_rec below to 8 x number needed 

fnames	dc.b	'GUN1.SPL',0
	dc.b	'GUN2.SPL',0
	dc.b	'BOMB.SPL',0
	dc.b	0

* Sample and loop lists
* Minimum of two entries per list, plus list terminator (0)
* smpl_list gives the number of the sample, ie
* The first file listed above is 0, the second 1 etc

smpl_list	dc.b	0,1,2,0,1,2,1,0,1,2

* values in loop_list correspond to the numbers in 
* samlist, indicating how many times they should be played
* 0 indicates end of list, the pointer returns to start of 
* the list and plays the first sample again.
* Must be the same number of bytes as smpl_list, plus a 0 to end

loop_list	dc.b	3,1,1,1,2,2,3,1,2,2,0

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

old_vec	ds.l	1	initial interrupt vector
old_iea	ds.b	1	initial state of MFP
old_ima	ds.b	1
old_tadr	ds.b	1
old_tacr	ds.b	1

	even

	ds.l	250
newstack	ds.l	1

sam_recs	ds.l	40
smpl_ptr	ds.l	1
loop_ptr	ds.l	1

	end