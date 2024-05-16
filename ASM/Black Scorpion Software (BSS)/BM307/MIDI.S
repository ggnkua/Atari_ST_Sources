*************************************************************
***	Nytt fîrsîk till fungerande MIDIrutin 961101	*****
***	Undviker all "onîdig kod"!			*****
*************************************************************
***	SmÜÑndrad 970609	ble->bls(FUNKAR NU!!!)	*****
***	Optimerad 970610	midi_fix_duration	*****
***	éndrad 970610		Timer A och D numera	*****
***	éndrad 970610		Dynamisk inladdning	*****
***				av MIDI-filer		*****
*************************************************************

*-------------------------------------------------------*
* MIDI engine -- slightly modified so that we can load	*
* MIDI files without starting their playback 		*
* immediately. We now have midi_start to start playback	*
*-------------------------------------------------------*

	
*-------------------------------------------------------*
*	midi_load_file. Laddar MIDI-fil.		*
*-------------------------------------------------------*

*  in: a2 = pointer to the MIDI file filename to load
* out: d0.l = 'MIDI' for success, else MIDI file load error

midi_load_file
	clr.l	midi_start_adress
			
	move.w	#0,-(sp)	;try and find the midi file (in a2)
	move.l	a2,-(sp)
	move.w	#$4e,-(sp)	Fsfirst
	trap	#1
	addq.l	#8,sp
	
	cmp.l	#0,d0		;did we find it
	beq	mid_fil_finns
	rts
	
* MIDI file found:
mid_fil_finns
	move.w	#$2f,-(sp)	;get pointer to the DTA
	trap	#1
	addq.l	#2,sp
	move.l	d0,a0
	move.l	26(a0),d0	;get the size of the MIDI file out

	moveq	#VRAM_preferred,d1
	bsr	allocate_chunk	;allocate space for the file
	tst.l	d0
	bgt	.got_memory
	moveq	#0,d0
	rts

.got_memory
	move.l	d0,midi_fil_adress

	Fopen	a2,#0		; open MIDI file for reading
	tst.w	d0
	bge	.got_file
	moveq	#0,d0
	rts

.got_file
	move.w	d0,filnummer	

	Fread	d0,d4,midi_fil_adress	; load the MIDI file

	Fclose	filnummer

*-------------------------------------------------------*
*	check MIDI data					*
*-------------------------------------------------------*
	
	move.l	midi_fil_adress,a0
	
	move.l	(a0),d0		;is it the right type of header?
	
	cmp.l	#'MThd',d0
	beq	right_header
	rts

right_header	
	move.l	4(a0),d0	;is it the right length?
	cmp.l	#6,d0
	beq	right_length
	rts
	
right_length
	move.w	8(a0),d0	;is it the right format (0)?
	cmp.l	#0,d0
	bra	right_format	;JC: allow format 1 as well
	rts
	
right_format
	move.w	10(a0),d0	;has it the right number of tracks (1)?
	cmp.l	#1,d0
	beq	right_nr_of_tracks
	rts
	
right_nr_of_tracks
	move.w	12(a0),d0	;Kolla om det Ñr i ppqm-format.
	btst.l	#15,d0
	beq	right_division
	rts
	
right_division
	move.w	d0,midi_division	;Spara division.
	move.l	14(a0),d0	;Kolla om rÑtt trackheader.
	cmp.l	#'MTrk',d0
	beq	right_trackheader
	rts
	
right_trackheader
	lea	22(a0),a0	;Spara midi_start_adress.
	move.l	a0,midi_start_adress

	;bsr	midi_fix_prog	;Fixa Program change.
	;bsr	midi_fix_drum	;Fixa Drum table.
	;bsr	midi_fix_chan	;Fixa MIDI channels.

	move.l	#'MIDI',d0
	rts				;All fîrberedelse klar.
	

*-------------------------------------------------------*
*	midi_start/midi_init_timers			*
*-------------------------------------------------------*

midi_init_timers
midi_start

	tst.b	midi_on
	beq.s	.go
	rts
.go:	st	midi_on

	tst.l	midi_start_adress
	bne	.ok
	rts
.ok
	move.b	#0,midi_read_offset
	move.b	#0,midi_write_offset
	
	move.l	midi_start_adress,a0
	move.l	a0,midi_song_pos
	
	bsr	midi_fix_duration
	
	
; SÑtt îvervakarlÑge.
	
	move.l	$134,old_timera		;Spara undan gamla rutiner.
	move.l	$110,old_timerd
	
	move.l	#timera,$134		;LÑgg in nya rutiner.
	move.l	#timerd,$110
	
	move.b	$fffa07,midi_old_iera	;Spara gamla maskregister.
	move.b	$fffa13,midi_old_imra
	move.b	$fffa09,midi_old_ierb
	move.b	$fffa15,midi_old_imrb
	
	move.b	#64,$fffa25		;SÑtt igÜng timers.  Numera A+D
	or.b	#7,$fffa1d		;Bryr sig inte om nÜgot, Ñnnu.
	move.b	#8,$fffa1f		;Fixa till timing.
	move.b	#6,$fffa19
	
	
	bset.b	#5,$fffa07		;SÑtt igÜng timerinterupts.
	bset.b	#4,$fffa09
	bset.b	#5,$fffa13
        bset.b	#4,$fffa15

; GÜ tillbaka till anvÑndarlÑge.

	rts				;Klart!		


*-------------------------------------------------------*
*	midi_fix_duration. Fixes delay-time.		*
*-------------------------------------------------------*

midi_fix_duration
	move.l	midi_song_pos,a0
	move.b	(a0),d0
	btst.l	#7,d0
	beq	one_byte_delay
	move.b	1(a0),d0
	btst.l	#7,d0
	beq	two_byte_delay
	move.b	2(a0),d0
	btst.l	#7,d0
	beq	three_byte_delay
	
four_byte_delay
	moveq.l	#0,d0
	move.b	(a0),d0
	bclr.l	#7,d0
	lsl.l	#7,d0
	moveq.l	#0,d1
	move.b	1(a0),d1
	bclr.l	#7,d1
	add.l	d1,d0
	lsl.l	#7,d0
	moveq.l	#0,d1
	move.b	2(a0),d1
	bclr.l	#7,d1
	add.l	d1,d0
	lsl.l	#7,d0
	moveq.l	#0,d1
	move.b	3(a0),d1
	add.l	d1,d0
	move.l	d0,midi_delay_time
	addq.l	#4,a0
	move.l	a0,midi_song_pos
	rts



one_byte_delay
	moveq.l	#0,d0
	move.b	(a0),d0
	move.l	d0,midi_delay_time
	addq.l	#1,a0
	move.l	a0,midi_song_pos
	rts
	
two_byte_delay
	moveq.l	#0,d0
	move.b	(a0),d0
	bclr.l	#7,d0
	lsl.l	#7,d0
	moveq.l	#0,d1
	move.b	1(a0),d1
	add.l	d1,d0
	move.l	d0,midi_delay_time
	addq.l	#2,a0
	move.l	a0,midi_song_pos
	rts
	
three_byte_delay
	moveq.l	#0,d0
	move.b	(a0),d0
	bclr.l	#7,d0
	lsl.l	#7,d0
	moveq.l	#0,d1
	move.b	1(a0),d1
	bclr.l	#7,d1
	add.l	d1,d0
	lsl.l	#7,d0
	moveq.l	#0,d1
	move.b	2(a0),d1
	add.l	d1,d0
	move.l	d0,midi_delay_time
	addq.l	#3,a0
	move.l	a0,midi_song_pos
	rts
	


*-------------------------------------------------------*
*	midi_stop. StÑnger av MIDI-uppspelning.		*
*-------------------------------------------------------*

midi_stop

	tst.b	midi_on
	bne.s	.go
	rts
.go:	sf	midi_on

	tst.l	midi_start_adress
	bne	.ok
	rts
.ok
	;èterstÑll timers.
	;LÑmna tillbaka lÜtminne.
	;ètestÑll filbuffert	
	
; SÑtt îvervakarlÑge.
	
	move.b	#0,$fffa19		;StÑng av timer a.
	and.b	#$f8,$fffa1d		;StÑng av timer d.
	
	move.b	midi_old_iera,$fffa07	;T-baks med gamla maskregister.
	move.b	midi_old_imra,$fffa13
	move.b	midi_old_ierb,$fffa09
	move.b	midi_old_imrb,$fffa15
	
	move.l	old_timera,$134		;T-baks med gamla timerrutiner.
	move.l	old_timerd,$110
	
; GÜ tillbaka till anvÑndarlÑge.
	
	move.l	midi_fil_adress,d0	;free the MIDI file memory
	bsr	deallocate_chunk

	clr.l	midi_start_adress		
	rts





*-------------------------------------------------------*
*	timerb. Avbrottsrutin. Sequencern.		*
*-------------------------------------------------------*

timerd
	;Kollar om det Ñr dags att skicka MIDI-message
	;Skickar Midi till buffert
	;SÑtter nytt vÑntevÑrde.
	movem.l	d0-d1/a0-a1,-(sp)
a_loop	cmp.l	#0,midi_delay_time
	bne	a_no_send
	move.l	midi_song_pos,a0
	cmp.b	#$7f,(a0)
	bls	send_running_status
	cmp.b	#$bf,(a0)
	bls	send_three_bytes
	cmp.b	#$df,(a0)
	bls	send_two_bytes
	cmp.b	#$ef,(a0)
	bls	send_three_bytes
	cmp.b	#$f0,(a0)
	beq	send_f0_sysex
	cmp.b	#$f7,(a0)
	beq	send_f7_sysex
	cmp.b	#$ff,(a0)
	beq	send_meta_event
	cmp.b	#$f1,(a0)
	beq	send_system_common_1
	cmp.b	#$f2,(a0)
	beq	send_system_common_2
	cmp.b	#$f3,(a0)
	beq	send_system_common_1
	bra	send_system_common_0
	
a_no_send
	sub.l	#1,midi_delay_time
	movem.l	(sp)+,d0-d1/a0-a1
	bclr.b	#4,$fffa11
	rte
	
send_running_status
	lea	midi_buffert,a1
	moveq.l	#0,d1
	move.b	midi_write_offset,d1
	move.b	run_stat,d0
	cmp.b	#1,d0
	beq	send_only_one
	move.b	(a0)+,(a1,d1.w)
	addq.b	#1,d1
send_only_one
	move.b	(a0)+,(a1,d1.w)
	addq.b	#1,d1
	move.b	d1,midi_write_offset
	move.l	a0,midi_song_pos
	bsr	midi_fix_duration
	bra	a_loop
	
send_three_bytes
	lea	midi_buffert,a1
	moveq.l	#0,d1
	move.b	midi_write_offset,d1
	move.b	#2,run_stat
	move.b	(a0)+,(a1,d1.w)
	addq.b	#1,d1
	move.b	(a0)+,(a1,d1.w)
	addq.b	#1,d1
	move.b	(a0)+,(a1,d1.w)
	addq.b	#1,d1
	move.b	d1,midi_write_offset
	move.l	a0,midi_song_pos
	bsr	midi_fix_duration
	bra	a_loop
	
send_two_bytes
	lea	midi_buffert,a1
	moveq.l	#0,d1
	move.b	midi_write_offset,d1
	move.b	#1,run_stat
	move.b	(a0)+,(a1,d1.w)
	addq.b	#1,d1
	move.b	(a0)+,(a1,d1.w)
	addq.b	#1,d1
	move.b	d1,midi_write_offset
	move.l	a0,midi_song_pos
	bsr	midi_fix_duration
	bra	a_loop
	
send_f0_sysex
	lea	midi_buffert,a1
	moveq.l	#0,d1
	move.b	midi_write_offset,d1
	move.b	(a0)+,(a1,d1.w)
	addq.b	#1,d1
	moveq.l	#0,d0
	move.b	(a0)+,d0
	subq.w	#1,d0
f0_loop
	move.b	(a0)+,(a1,d1.w)
	addq.b	#1,d1
	dbra	d0,f0_loop
	move.b	d1,midi_write_offset
	move.l	a0,midi_song_pos
	bsr	midi_fix_duration
	bra	a_loop



	
send_f7_sysex
	lea	midi_buffert,a1
	moveq.l	#0,d1
	move.b	midi_write_offset,d1
	moveq.l	#0,d0
	move.b	1(a0),d0
	addq.l	#2,a0
	subq.w	#1,d0
f7_loop	
	move.b	(a0)+,(a1,d1.w)
	addq.b	#1,d1
	dbra	d0,f7_loop
	move.b	d1,midi_write_offset
	move.l	a0,midi_song_pos
	bsr	midi_fix_duration
	bra	a_loop

send_meta_event
	move.b	1(a0),d0
	cmp.b	#$51,d0
	beq	send_meta_set_tempo
	cmp.b	#$2f,d0
	beq	send_meta_end_of_track
	moveq.l	#0,d0
	move.b	2(a0),d0
	addq.l	#3,d0
	add.l	d0,a0
	move.l	a0,midi_song_pos
	bsr	midi_fix_duration
	bra	a_loop
	
send_meta_end_of_track
	move.l	midi_start_adress,a0
	move.l	a0,midi_song_pos
	bsr	midi_fix_duration
	bra	a_loop
	
send_meta_set_tempo
	addq.l	#6,a0	;OBS FUNKAR INTE éNNU DONT CARE
	move.l	a0,midi_song_pos
	bsr	midi_fix_duration
	bra	a_loop
		

send_system_common_1
	addq.l	#2,a0
	move.l	a0,midi_song_pos
	bsr	midi_fix_duration
	bra	a_loop

send_system_common_2
	addq.l	#3,a0
	move.l	a0,midi_song_pos
	bsr	midi_fix_duration
	bra	a_loop

send_system_common_0
	addq.l	#1,a0
	move.l	a0,midi_song_pos
	bsr	midi_fix_duration
        bra	a_loop






	
*-------------------------------------------------------*
*	timera. Avbrottsrutin. Outputhantering.		*
*-------------------------------------------------------*

timera
	;Kollar om MIDI-byte finns.
	;SÑnder i sÜ fall detta.
	movem.l	d0-d1/a0,-(sp)
	moveq.l	#0,d0
	move.b	midi_read_offset,d0
	move.b	midi_write_offset,d1
	cmp.b	d0,d1
	beq	no_send
	btst.b	#1,$FFFC04		;Kan kanske bortrationaliseras.
	beq	no_send
	lea	midi_buffert,a0
	add.l	d0,a0
	move.b	(a0),$fffc06
	addq.b	#1,d0
	move.b	d0,midi_read_offset
no_send	movem.l	(sp)+,d0-d1/a0
	bclr.b	#5,$fffa0f
	rte

*********************************************************
*********************************************************
*********************************************************
*	Variabler	*********************************
*********************************************************

*-------------------------------------------------------*
			datlong	
*-------------------------------------------------------*

midi_file_name:
			ifd	test
			dc.b	"d:\bm227a\source\data\niklas.mid",0
			elseif
			dc.b	"NIKLAS.MID",0
			endc
			even	

midi_start_adress	dc.l	0
midi_song_pos		dc.l	0
midi_delay_time		dc.l	0
old_timera		dc.l	0
old_timerd		dc.l	0
filnummer		dc.w	0
midi_division		dc.w	0

midi_old_iera		dc.b	0
midi_old_imra		dc.b	0
midi_old_ierb		dc.b	0
midi_old_imrb		dc.b	0
run_stat		dc.b	0
midi_read_offset	dc.b	0
midi_write_offset	dc.b	0

midi_on:		dc.b	0

	even
midi_fil_adress		dc.l	0
	even


*-------------------------------------------------------*
			bsslong	
*-------------------------------------------------------*
	
midi_buffert		ds.b	256

*-------------------------------------------------------*
			txtlong	
*-------------------------------------------------------*
