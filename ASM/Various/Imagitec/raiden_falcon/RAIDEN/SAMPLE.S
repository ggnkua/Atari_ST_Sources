; Andy Seed Sample player!
	include ..\Includes\snd_falc.i

Init_Sound
	Push
 	locksnd
	devconnect	#0,#$c,#0,#9,#1
**	devconnect	#3,#$c,#0,#9,#1
	
*                              v--- This nibble 0 > F; 0 = Loudest 
	soundcmd	#0,#$0000	Set attenuation (volume)
	soundcmd	#1,#$0000
	soundcmd	#2,#$0080	Set attenuation (volume)
	soundcmd	#3,#$0080

*	soundcmd	#4,#1
*	soundcmd	#5,#3
	
	buffoper	#%0000		Play nothing
	setmontracks	#0

*	Set play buffer        v--start  v--end
	setbuffer	#0, #buffer_start, #buffer_end
*	8 bit stereo ----v
	setmode		#0
*	Set to playing one stereo track
	settracks	#0,#0
	
* 	Set playing
	buffoper	#%0011		Play with non-repeat
	Pull
	Rts

Quit_Sound	
	Push
	buffoper	#0		Kill the music
unlock	unlocksnd
	Pull
	Rts

block	ds.l	4

no_samples	equ	49*4


play_sams	lea	sample_data(pc),a6
		movem.l	(a6),a0-a5
		moveq	#no_samples/4-1,d7
.lp		move.w	(a0)+,d0
		move.w	(a1)+,d1
		movep.w	d0,0(a4)
		movep.w	d0,1(a4)
		addq.l	#4,a4
		cmp.l	a0,a2
		bgt.s	.no_wrap_a
		lea	blank_sample_start(pc),a0
		lea	blank_sample_end(pc),a2
		st	sample_a_finished-sample_data(a6)
.no_wrap_a	cmp.l	a1,a3
		bne.s	.no_wrap_b
		lea	blank_sample_start(pc),a1
		lea	blank_sample_end(pc),a3
		st	sample_b_finished-sample_data(a6)
.no_wrap_b	dbf	d7,.lp
		move.l	sample_played_buffer(pc),a4
		exg.l	a4,a5
		movem.l	a0-a5,(a6)
		rts
blank_sample_start
		rept	200
		dc.b	255
		endr
blank_sample_end

sample_data
sample_a_start		dc.l	blank_sample_start
sample_b_start		dc.l	blank_sample_start
sample_a_end		dc.l	blank_sample_end
sample_b_end		dc.l	blank_sample_end
sample_played_buffer	dc.l	buffer0
sample_play_buffer	dc.l	buffer1
sample_a_finished	dc.b	0
sample_b_finished	dc.b	0
buffer_start
buffer0			ds.b	no_samples
buffer1			ds.b	no_samples
buffer_end
