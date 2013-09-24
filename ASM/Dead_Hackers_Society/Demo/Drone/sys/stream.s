; Atari ST/e synclock demosystem
; February 18, 2012
;
; sys/stream.s
;
; Simple STe DMA sound streaming


music_stream_bufsize:	equ	25033*28
music_stream_bufvbl:	equ	2503300*28/50066

music_stream_showcol:	equ	0					;Debug colours
		
		section	text

music_stream_load1:
		run_once
		move.l	#music_stream_fn1,filename
		move.l	#music_stream_bufsize,filelength
		move.l	#music_stream_buf1,filebuffer
		move.l	#"DHS!",d0
		jsr	loader
		rts

music_stream_load2:
		run_once
		move.l	#music_stream_fn2,filename
		move.l	#music_stream_bufsize,filelength
		move.l	#music_stream_buf2,filebuffer
		move.l	#"DHS!",d0
		jsr	loader
		rts

music_stream_load3:
		run_once
		move.l	#music_stream_fn3,filename
		move.l	#music_stream_bufsize,filelength
		move.l	#music_stream_buf1,filebuffer
		jsr	loader
		rts

music_stream_load4:
		run_once
		move.l	#music_stream_fn4,filename
		move.l	#music_stream_bufsize,filelength
		move.l	#music_stream_buf2,filebuffer
		jsr	loader
		rts

music_stream_load5:
		run_once
		move.l	#music_stream_fn5,filename
		move.l	#music_stream_bufsize,filelength
		move.l	#music_stream_buf1,filebuffer
		jsr	loader
		rts

music_stream_load6:
		run_once
		move.l	#music_stream_fn6,filename
		move.l	#music_stream_bufsize,filelength
		move.l	#music_stream_buf2,filebuffer
		jsr	loader
		rts

music_stream_load7:
		run_once
		move.l	#music_stream_fn7,filename
		move.l	#music_stream_bufsize,filelength
		move.l	#music_stream_buf1,filebuffer
		jsr	loader
		rts

music_stream_load8:
		run_once
		move.l	#music_stream_fn8,filename
		move.l	#music_stream_bufsize,filelength
		move.l	#music_stream_buf2,filebuffer
		jsr	loader
		rts

music_stream_load9:
		run_once
		move.l	#music_stream_fn9,filename
		move.l	#music_stream_bufsize,filelength
		move.l	#music_stream_buf1,filebuffer
		jsr	loader
		rts

music_stream_load10:
		run_once
		move.l	#music_stream_fn10,filename
		move.l	#music_stream_bufsize,filelength
		move.l	#music_stream_buf2,filebuffer
		jsr	loader
		rts

music_stream_load11:
		run_once
		move.l	#music_stream_fn11,filename
		move.l	#489953,filelength
		move.l	#music_stream_buf1,filebuffer
		jsr	loader
		rts


music_stream_init:
		bsr	music_stream_load1
		bsr	music_stream_load2

		move.l	music_stream_seq,music_stream_seq_dat
		move.l	music_stream_seq+4,d0
		move.l	music_stream_seq+8,d1

		move.b	d0,$ffff8907.w			;Start of sample
		lsr.l	#8,d0				;
		move.b	d0,$ffff8905.w			;
		lsr.l	#8,d0				;
		move.b	d0,$ffff8903.w			;

		move.b	d1,$ffff8913.w			;End of sample
		lsr.l	#8,d1				;
		move.b	d1,$ffff8911.w			;
		lsr.l	#8,d1				;
		move.b	d1,$ffff890f.w			;

		move.b	#%10000010,$ffff8921.w 		;25033Hz mono


		rts


music_stream_play:
		subq.l	#1,.once
		bne.s	.no

		move.b	#%00000011,$ffff8901.w		;Start sample with loop
.no:


		subq.l	#1,music_stream_seq_dat
		bgt.s	.done


		move.l	music_stream_seq_adr,a0
		lea	16(a0),a0
		move.l	a0,music_stream_seq_adr
		beq.s	.finished
		move.l	(a0)+,d0
		move.l	d0,music_stream_seq_dat

		move.b	3(a0),$ffff8907.w		;Start of sample
		move.b	2(a0),$ffff8905.w		;
		move.b	1(a0),$ffff8903.w		;

		move.b	7(a0),$ffff8913.w		;End of sample
		move.b	6(a0),$ffff8911.w		;
		move.b	5(a0),$ffff890f.w		;

	ifne	music_stream_showcol
		move.w	8(a0),$ffff8240.w
	endc

.done:		rts
.finished:	clr.b	$ffff8901.w			;Kill sample playback
		rts
.wait:		dc.w	4
.once:		dc.l	1




music_stream_exit:
		clr.b	$ffff8901.w			;Kill sample playback
		rts




		section	data

; vbls,address,length,debugcolour

music_stream_seq:
		dc.l	music_stream_bufvbl-1,music_stream_buf1,music_stream_buf1+music_stream_bufsize,$02200000
		dc.l	music_stream_bufvbl,music_stream_buf2,music_stream_buf2+music_stream_bufsize,$07700000
		dc.l	music_stream_bufvbl,music_stream_buf1,music_stream_buf1+music_stream_bufsize,$02000000
		dc.l	music_stream_bufvbl,music_stream_buf2,music_stream_buf2+music_stream_bufsize,$07000000
		dc.l	music_stream_bufvbl,music_stream_buf1,music_stream_buf1+music_stream_bufsize,$00200000
		dc.l	music_stream_bufvbl,music_stream_buf2,music_stream_buf2+music_stream_bufsize,$00700000
		dc.l	music_stream_bufvbl,music_stream_buf1,music_stream_buf1+music_stream_bufsize,$00200000
		dc.l	music_stream_bufvbl,music_stream_buf2,music_stream_buf2+music_stream_bufsize,$00700000
		dc.l	music_stream_bufvbl,music_stream_buf1,music_stream_buf1+music_stream_bufsize,$02020000
		dc.l	music_stream_bufvbl,music_stream_buf2,music_stream_buf2+music_stream_bufsize,$07070000
		dc.l	978,music_stream_buf1,music_stream_buf1+489953,$07770000	;pl3
		dc.l	0


music_stream_seq_adr:	dc.l	music_stream_seq
music_stream_seq_dat:	dc.l	0


music_stream_fn1:	dc.b	'music\xaa',0
			even
music_stream_fn2:	dc.b	'music\xab',0
			even
music_stream_fn3:	dc.b	'music\xac',0
			even
music_stream_fn4:	dc.b	'music\xad',0
			even
music_stream_fn5:	dc.b	'music\xae',0
			even
music_stream_fn6:	dc.b	'music\xaf',0
			even
music_stream_fn7:	dc.b	'music\xag',0
			even
music_stream_fn8:	dc.b	'music\xah',0
			even
music_stream_fn9:	dc.b	'music\xai',0
			even
music_stream_fn10:	dc.b	'music\xaj',0
			even
music_stream_fn11:	dc.b	'music\xak',0
			even



		section	bss

music_stream_buf1:	ds.b	music_stream_bufsize
music_stream_buf2:	ds.b	music_stream_bufsize

		section	text
