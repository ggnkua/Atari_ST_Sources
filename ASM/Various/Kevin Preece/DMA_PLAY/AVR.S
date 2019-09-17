********************************************************************************
*
* Name     : AVR.S
* Title    : Play an AVR sample through STE hardware
* Author   : Kevin Preece
* Assembler: Devpac 3
*
* ------------------------------------------------------------------------------
*
* This program demonstrates how to play an AVR sample through the STEs sample
* hardware.  Since this is only a demo, it does not do proper program startup
* so does not release unneeded memory back to the free memory pool.
*
* "I love the sound of breaking glass ..."
*
********************************************************************************

AVR_MAGIC		=	$32424954

*
* Layout for the AVR sample header
*
		offset
avr_magic		ds.l	1
avr_name		ds.b	8
avr_mode		ds.w	1
avr_resolution	ds.w	1
avr_signed	ds.w	1
avr_looping	ds.w	1
avr_midinote	ds.w	1
avr_frequency	ds.l	1
avr_length	ds.l	1
avr_loop_first	ds.l	1
avr_loop_end	ds.l	1
avr_reserved	ds.b	6
avr_xname		ds.b	20
avr_user		ds.b	64
avr_data		ds.b	0

		section	text
main		pea	0.w
		move.w	#32,-(sp)		we need to run in super mode
		trap	#1
		move.l	d0,2(sp)
		move.l	$5ac.w,-(sp)	get address of old bell hook routine
		move.l	#crash,$5ac.w	replace with ours
		pea	string(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	(sp)+,$5ac.w	replace old vector
		trap	#1
		clr.w	(sp)
		trap	#1

string		dc.b	1,2,3,4,5,6,7,8,9,10,0

play_avr_sample	move.l	a0,sample_addr		put start address of sample
		pea	playit(pc)		the routine that will set up h/ware registers
		move.w	#38,-(sp)			... must run in super mode
		trap	#14
		addq.l	#6,sp
		rts

crash		move.l	#sample,sample_addr		put address of sample
playit		move.l	sample_addr(pc),a0
		cmp.l	#AVR_MAGIC,avr_magic(a0)	is it an AVR sample
		bne.s	.no_play			no - can't play it
		cmp.w	#8,avr_resolution(a0)	8 bit sample?
		bne.s	.no_play			no - can't play it
		moveq	#0,d0			control - stereo, 6kHz
		tst.w	avr_mode(a0)		is it stereo
		bne.s	.stereo			yes - jump
		move.b	#$80,d0			control - mono 6kHz
		move.l	avr_frequency(a0),d1	get sample frequency
.stereo		cmp.l	#6258,d1			6kHz?
		beq.s	.got_speed		yes - forward
		addq.b	#1,d0			new value for sample frequency register
		cmp.l	#12517,d1			12kHz?
		beq.s	.got_speed
		addq.b	#1,d0
		cmp.l	#25033,d1			25kHz
		beq.s	.got_speed
		addq.w	#1,d0
		cmp.l	#50066,d1			50kHz
		bne.s	.no_play			no - invalid frequency - can't play it
.got_speed	clr.b	$ffff8901.w		disable sound
		move.b	d0,$ffff8921.w		set mode and frequency
		lea	avr_data(a0),a1		get address of sample data
		move.l	a1,d2
		move.l	d2,d3
		add.l	avr_length(a0),d3
		lea	$ffff8902.w,a1		get address of hardware frame base address
		movep.w	d2,3(a1)			load h/ware with low & mid base address
		swap	d2
		move.b	d2,1(a1)			load h/ware with high base address
		lea	$ffff890e.w,a1		get address of hardware frame end address
		movep.w	d3,3(a1)			put low & mid address
		swap	d3
		move.b	d3,1(a1)			put high address
		move.b	#1,$ffff8901.w		put DMA control register (starts playback)
.no_play		rts

		section	data
sample_addr	dc.l	0
sample		incbin	window.avr
