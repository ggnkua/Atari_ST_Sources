* routine to play several samples several times each!
* by James Ingram, May 1994


	opt	x+,o-,ow-


	include	\includes\macros.s
	include	\includes\ste_defs.s

	free_mem

	super_on
	keep_timers

* load in all the samples!
	bsr	load_em_in


* play them
	bsr	play_em

	restore_timers

	bsr	sound_off

	super_off
	clr.w	-(a7)
	trap	#1


play_em:
* play all the samples in the list!!!

	bsr	vol_max
	bsr	play_next_sample	; start it going!

	clr.b	$fffffa19.w		; timer A off
	move.l	#player,$134.w
	move.b	d0,$fffffa1f.w		; no of loops
	move.b	#8,$fffffa19.w		; event mode

	bset	#5,$fffffa13.w	; mask it in
	bset	#5,$fffffa07.w

	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7

	rts

player:
* timer A sample controller
	clr.b	$fffffa19.w	; timer A off

	movem.l	d0-7/a0-6,-(a7)

	bsr	play_next_sample

	move.b	d0,$fffffa1f.w		; no of loops
	move.b	#8,$fffffa19.w		; timer A on

	movem.l	(a7)+,d0-7/a0-6
	bclr	#5,$fffffa0f.w
	rte


vol_max:
* set master volume to max
	move.w	#$7ff,micro_mask.w	; set microwire to vol/tone

	move.w	#master_vol+40,d1	; set to "master volume" and level 40
	move.w	d1,micro_data.w		; send the data
	rts

sound_off:
	clr.w	enable.w	; turn sound off
	rts


play_next_sample:
* play the next sample in the list!
	move.l	list_pos,a2		; get the position in the list

	moveq	#0,d0
	move.w	(a2)+,d0	; get a word out
	bpl.s	.not_end

* end of list!
	move.l	#list_start,a2
	move.w	(a2)+,d0

.not_end:
	mulu	#10,d0		; as pointer in list
	
	move.l	#sam_list,a1
	add.l	d0,a1		; go to sample addresses in list

	move.l	(a1)+,d0	; get sample start address
	move.w	#base_high,a0
	movep.l	d0,-1(a0)	; put it into register for base address

	move.l	(a1)+,d0	; get sample end address
	move.w	#end_high,a0
	movep.l	d0,-1(a0)	; put it into register for end address

	move.w	(a1)+,d0	; get sound mode
	move.w	d0,sound_mode.w

	move.w	#%11,enable.w	; start the sound going

	move.w	(a2)+,d0	; get number of repeats
	move.l	a2,list_pos
	rts


load_em_in:
* get the start of the sample list
	move.l	#sam_list,a5

* and the address of the filenames
	move.l	#sam_names,a4
	
.load_em:
	move.l	a4,a0
	bsr	load_a_sample

	move.l	a6,(a5)+	; keep sample start address
	add.l	d0,a6
	move.l	a6,(a5)+	; and sample end address
	addq.l	#2,a5		; go past Khz

.next_name:
	tst.b	(a4)+
	bne.s	.next_name	; get next sample name

	tst.b	(a4)
	bne.s	.load_em	; keep going until another 0 reached
	rts

sam_names:
	dc.b	"\includes\sample_1.avr",0
	dc.b	"\includes\sample_2.avr",0
	dc.b	0
	even

sam_list:
	ds.l	2	; start and end addresses
	dc.w	%10000000	; mono & sample rate (6 Khz)

	ds.l	2
	dc.w	%10000000


list_pos	dc.l	list_start


list_start:
* list of sample numbers and number of repeats

	dc.w	0,4		; beat x 4
	dc.w	1,4		; voice 4 times
	
	dc.w	-1


	include	\includes\samples.s



	section	bss

	old

	ds.b	5000
stack:


