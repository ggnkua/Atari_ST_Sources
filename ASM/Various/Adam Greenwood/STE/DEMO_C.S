* STE DMA sound example program C.

* Volume/Tone control and repeating samples using the GPI(7) 
* mono monitor detect interrupt, with the active edge set
* to give an interrupt at the start of a sample.

* Copyright 1991 A Greenwood

* Source code written with Devpac 2
* local variables etc. may need changing for other assemblers

* Feel free to change and use any of this code.

* First the constants

* DMA Sound chip registers
mode	equ	$ff8920		stereo/mono & frequency
enable	equ	$ff8900		enable register
f_strt_h	equ	$ff8902		frame start high
f_end_h	equ	$ff890e		frame end high

* System variables for interrupts
gpi7	equ	$13c		GPI(7) vector

* MFP 68901 Addresses
edge	equ	$fffa03		active edge
iea	equ	$fffa07		interrupt Enable A
isra	equ	$fffa0f		in Service A
ima	equ	$fffa13		interrupt Mask A

* Shift mode register

shft_mode	equ	$fff8260

* microwire registers

mw_data	equ	$ff8922
mw_mask	equ	$ff8924

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
	move.l	d0,stk		save value of old stack

* call routines

	jsr	initsound		set initial vol/tone
	jsr	load_all		load samples
	jsr	playit		play samples
	
* Sound will now play without further attention
* Now loop getting keypress to look after volume/tone
	
.getkey	move.w	#7,-(a7)		get keypress
	trap	#1
	addq	#2,a7		returns d0.l

	swap	d0		highword is keyscan code

	cmp.b	#57,d0		spacebar = quit.
	bne.s	.0
	bra	fin

* Master volume

.0	cmp.b	#59,d0		F1 = master volume down
	bne.s	.1		
	move.b	m_vol,d0
	beq	.getkey
	sub.b	#1,d0
	bra	.set_mv

.1	cmp.b	#60,d0		F2 = master volume down
	bne.s	.2
	move.b	m_vol,d0
	cmp.b	#40,d0		
	beq	.getkey
	add.b	#1,d0		
.set_mv	move.b	d0,m_vol
	move.w	#0,d1		set master volume
	jsr	setparams		
	bra	.getkey

* Left volume

.2	cmp.b	#61,d0		F3 = left volume down
	bne.s	.3
	move.b	l_vol,d0
	beq	.getkey
	sub.b	#1,d0
	bra	.set_lv
	
.3	cmp.b	#62,d0		F4 = left volume up
	bne.s	.4
	move.b	l_vol,d0
	cmp.b	#20,d0
	beq	.getkey
	add.b	#1,d0
.set_lv	move.b	d0,l_vol
	move.w	#1,d1		set left volume
	jsr	setparams
	bra	.getkey
	
* Right volume

.4	cmp.b	#63,d0		F5 = right volume down
	bne.s	.5
	move.b	r_vol,d0
	beq	.getkey
	sub.b	#1,d0
	bra	.set_rv
	
.5	cmp.b	#64,d0		F6 = right volume up
	bne.s	.6
	move.b	r_vol,d0
	cmp.b	#20,d0
	beq	.getkey
	add.b	#1,d0
.set_rv	move.b	d0,r_vol
	move.w	#2,d1		set right volume
	jsr	setparams
	bra	.getkey
	
* Treble

.6	cmp.b	#65,d0		F7 = treble down
	bne.s	.7
	move.b	treble,d0
	beq	.getkey
	sub.b	#1,d0
	bra	.set_tr
	
.7	cmp.b	#66,d0		F8 = treble up
	bne.s	.8
	move.b	treble,d0
	cmp.b	#12,d0
	beq	.getkey
	add.b	#1,d0
.set_tr	move.b	d0,treble
	move.w	#3,d1		set treble
	jsr	setparams
	bra	.getkey
	
* Bass

.8	cmp.b	#67,d0		F9 = bass down
	bne.s	.9
	move.b	bass,d0
	beq	.getkey
	sub.b	#1,d0
	bra	.set_bs

.9	cmp.b	#68,d0		F10 = bass up
	bne.s	.10
	move.b	bass,d0
	cmp.b	#12,d0
	beq	.getkey
	add.b	#1,d0
.set_bs	move.b	d0,bass
	move.w	#4,d1		set bass
	jsr	setparams
	bra	.getkey
	
.10	cmp.b	#1,d0		Esc = reset vol/tone
	bne	.getkey
	jsr	initsound
	bra	.getkey
	
* Routine to initialise volume/tone settings
* The addresses here are storage in this program, the
* Setparams routine uses these to set actual volume/tone

initsound	movem.l	d0-d1/a0,-(a7)

	move.b	#40,m_vol
	move.b	#20,l_vol
	move.b	#20,r_vol
	move.b	#6,treble
	move.b	#6,bass
	move.b	#2,mix 

	move.l	#m_vol,a0
	move.w	#0,d1
.loop	move.b	(a0)+,d0		loop round getting
	jsr	setparams		value and calling routine
	add.w	#1,d1		for each setting
	cmp.w	#6,d1
	blt.s	.loop

	movem.l	(a7)+,d0-d1/a0
	rts

* Routine to set volume & tone
* in: d0.b = parameter level
* Ranges are: master volume, 0 - 40
*	    left/right volume, 0 - 20
* 	    treble/bass, 0 - 12 (6 centre)
* d1.w = parameter no.
* 0 = master volume
* 1 = left volume
* 2 = right volume
* 3 = treble
* 4 = treble
* 5 = mix GI (sound chip)
* Uses microwire to set.

setparams	movem.l	d0-d4/a0-a3,-(a7)

	move.l	#voltone,a0	microwire settings
	move.l	#mw_data,a2	microwire data register
	move.l	#m_vol,a3		parameter Values
	add.w	d1,a3
	mulu	#2,d1
	add.w	d1,a0
	
	move.b	(a3)+,d1		setting for data
	move.w	(a0)+,d2		microwire address
	or.b	d1,d2		combine them
	move.w	(a2),d4		previous value of microwire data
	move.w	#$7ff,mw_mask	set microwire mask for vol/tone
	move.w	d2,(a2)		set data - send data

.wait	move.w	(a2),d2
	cmp.w	d4,d2		current value of microwire data
	bne.s	.wait		data sent when returns to previous

	movem.l	(a7)+,d0-d4/a0-a3
	rts

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
* Assumes that the file exists

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
	jsr	init_int		initialise interrupt

	move.l	#smpl_list,a1	sample list
	move.l	#loop_list,a2	loop list 

	move.l	#sam_recs,a0	
	move.w	#0,d0
	move.b	(a1)+,d0		get index and use it
	mulu	#8,d0		to find sample
	add.w	d0,a0
	move.l	(a0)+,d0		get sample addresses
	move.l	(a0)+,d1
	jsr	sample_ad
	move.b	(a2)+,save_rep	repeat for first sample

	move.l	a1,smpl_ptr	save list pointers
	move.l	a2,loop_ptr	

	move.w	#3,enable		enable sound, repeat mode

	rts

* Routine to initialise GPI(7) mono monitor detect interrupt 
* Active edge for this interrupt is set so that an interrupt
* is provided when sample STARTS playing

init_int	move.b	iea,old_iea	save iea
	move.b	ima,old_ima	save ima
	move.b	edge,old_edge	save active edges
	move.l	gpi7,old_vec	save old GPI(7) vector

	and.b	#$7f,iea		disable GPI(7)

	move.b	shft_mode,d0	get resolution
	cmp.b	#2,d0		check for hi res
	bne.s	.low_med
	or.b	#$80,edge		set edge positive
	bra.s	.edge_set
.low_med	and.b	#$7f,edge		set edge negative

.edge_set	move.l	#tim_rtn,gpi7	address of our routine
	or.b	#$80,iea		re-enable GPI(7)
	or.b	#$80,ima		set mask

	rts
	
* Interrupt handler called when sample STARTS
* Using GPI(7) there is no event countdown mode, so we get an
* interrupt every time
* This is the routine which actually loads up the address of the 
* next sample, ready for when the sample which has just started 
* finishes

tim_rtn	movem.l	d0-d3/a0-a2,-(a7)
				
	move.b	save_rep,d3	loop counter
	sub.b	#1,d3		decrement counter
	bne	.out

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
	jsr	sample_ad		set address of next sample
	move.b	(a2)+,d3

	move.l	a0,smpl_ptr	move along list
	move.l	a2,loop_ptr
	
.out	move.b	d3,save_rep	save loop counter
	bclr	#7,isra		re-enable lower level 
	movem.l	(a7)+,d0-d3/a0-a2	interrupts
	rte
	
* Routine to set start and end addresses for a sample
* d0.l = start address
* d1.l = end address
* Uses movep to set alternate bytes

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

fin	move.w	#0,enable		Turn off sound
	
	move.w	sr,-(a7)		save status register
	move.w	#$2700,sr		disbale all interrupts
	move.l	old_vec,gpi7	restore GPI(7) Vector
	move.b	old_iea,iea	restore enable A
	move.b	old_ima,ima	restore mask A
	move.b	old_edge,edge	restore active edge
	move.w	(a7)+,sr		restore status register
	
	jsr	initsound		set vol/tone to default
	move.b	#1,mix		mix GI (old sound chip)
	move.w	#5,d1		set mix
	jsr	setparams

	lea	stk,a6		get value of original stack
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
* Firtsam and samlist are the number of the sample, ie
* The first file listed above is 0, the second 1 etc

smpl_list	dc.b	0,1,2,1,0,2,0,1,0,2,1

* values in looplst correspond to the numbers in 
* samlist, indicating how many times they should be played
* 0 indicates end of list

loop_list	dc.b	3,1,1,2,1,2,2,4,1,3,2,0

* Playback frequency for ALL samples
* 0 = 6.25 KHz, 1 = 12.5 KHz, 2 = 25 KHz, 3 = 50 KHz

freq	dc.b	2

	even
	
* Stereo/Mono mode
* $00 = stereo, $80 = mono

ster	dc.w	$80

	even

* microwire values for volume/tone

voltone	dc.w	%10011000000	Master volume
	dc.w	%10101000000	Left channel volume
	dc.w	%10100000000	Right channel volume
	dc.w	%10010000000	Treble
	dc.w	%10001000000	Bass
	dc.w	%10000000000	Mix


	section	bss

* storage for volume/tone settings

m_vol	ds.b	1
l_vol	ds.b	1
r_vol	ds.b	1
treble	ds.b	1
bass	ds.b	1
mix	ds.b	1

	even

stk	ds.l	1	original value of stack

old_vec	ds.l	1	initial interrupt vector
old_iea	ds.b	1	initial state of MFP
old_ima	ds.b	1
old_edge	ds.b	1

	even

	ds.l	250
newstack	ds.l	1

* global variables for sample playing

smpl_ptr	ds.l	1
loop_ptr	ds.l	1
next_strt	ds.l	1
next_end	ds.l	1
sam_recs	ds.l	40
save_rep	ds.b	1
next_rep	ds.b	1

	end