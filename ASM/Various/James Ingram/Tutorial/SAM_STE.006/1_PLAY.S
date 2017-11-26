* Play a sample on the STe
* by James Ingram, May 1994

	opt	x+,o-,ow-

	include	\includes\macros.s
	include	\includes\ste_defs.s

	free_mem

	super_on

	lea	beat(pc),a0
	bsr	load_a_sample	; load in the sample

	move.l	d0,beat_len
	move.l	a6,beat_address

* now I play the sample!
	move.w	#0,enable.w	; turn any samples off!

	move.l	beat_address,d0	; get sample address

	move.w	#base_high,a0
	movep.l	d0,-1(a0)	; put it into register for base address

	move.l	beat_address,d0
	add.l	beat_len,d0	; get end address of sample

	move.w	#end_high,a0
	movep.l	d0,-1(a0)	; put it into register for end address

* set master volume to max
	move.w	#$7ff,micro_mask.w	; set microwire to vol/tone

	move.w	#master_vol+40,d1	; set to "master volume" and level 40
	move.w	d1,micro_data.w		; send the data

	move.w	#%10000000,d0		; set to "mono" and 6 Khz
	move.w	d0,sound_mode.w

	move.w	#%11,enable.w		; set sound off
	
	move.w	#7,-(a7)
	trap	#1			; wait for keypress
	addq.l	#2,a7

	clr.w	enable.w	; turn sound off

	super_off
	
	clr.w	-(a7)
	trap	#1

	include	\includes\samples.s

beat:
	dc.b	"\includes\sample_1.avr",0
	even


	section	bss

beat_len	ds.l	1
beat_address	ds.l	1


	ds.b	5000
stack:
