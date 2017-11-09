; february 1, 1999

; easy to use sidsound designer replay shell.


; tested with st, ste, mste, pak030, tt030,
; falcon030, centurbo2

; sidsound desinger original routines by 
; synergy and animal mine. patched and updated
; by defjam/checkpoint and FroST/Loud.

; timer a, c & d are used for the sid-waveform 
; emulation. this means you can use 
; sid-instruments on all three voices.

; timer b is used for calling the player at 50Hz
; interval.

; ae@atari.org / dhs.atari.org


	section	text

begin:

	clr.l	-(sp)			;into super
	move.w	#32,-(sp)		;
	trap	#1			;
	addq.l	#6,sp			;
	move.l	d0,save_stack		;

	lea.l	voice,a0		;address to sounddata
	lea.l	song,a1			;address to songdata
	jsr	player+0		;init player

	move.w	sr,d0			;save sr
	move.w	#$2700,sr		;all ints off

	lea.l	save_mfp,a0		;save needed mfp regs
	move.b	$fffffa07,(a0)+		;
	move.b	$fffffa13,(a0)+		;
	move.b	$fffffa1b,(a0)+		;
	move.b	$fffffa21,(a0)+		;
	bset	#0,$fffffa07		;timer-b inits
	bset	#0,$fffffa13		;
	move.b	#246,$fffffa21		;2457600/200/246 approx 50 Hz
	or.b	#%111,$fffffa1b		;%111 = divide by 200
	bclr	#3,$fffffa1b		;tos 2.05 fix

	move.l	$120,save_timer_b	;save old timer_b routine
	move.l	#timer_b,$120		;install new timer_b routine

	move.w	d0,sr			;restore sr




.loop:	cmpi.b	#$39,$fffffc02.w	;wait for space
	bne.s	.loop			;




exit:
	move.w	sr,d0			;save sr
	move.w	#$2700,sr		;all ints off

	lea.l	save_mfp,a0		;restore mfp regs
	move.b	(a0)+,$fffffa07		;
	move.b	(a0)+,$fffffa13		;
	move.b	(a0)+,$fffffa1b		;
	move.b	(a0)+,$fffffa21		;

	move.l	save_timer_b,$120.w	;restore timer_b

	move.w	d0,sr			;restore sr

	jsr	player+8		;deinit player

	move.l	save_stack,-(sp)	;exit super
	move.w	#32,-(sp)		;
	trap	#1			;
	addq.l	#6,sp			;

	clr.w	-(sp)			;pterm()
	trap	#1





timer_b:
	jsr	player+4		;call player
	bclr	#0,$fffffa0f		;clear timer_b busyflag
	rte


	section	data

	even
player:	incbin	'replayer.bin'		;replayroutine
	even
song:	incbin	'song.tri'		;songdata
	even
voice:	incbin	'song.tvs'		;sounddata
	even



	section	bss

	even
save_stack:	ds.l	1		;save stack
save_mfp:	ds.l	1		;save mfp (timer_b)
save_timer_b:	ds.l	1		;save timer_b routine
