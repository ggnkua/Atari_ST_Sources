; Atari ST/e synclock demosystem
; February 11, 2011
;
; ymdigi8.s
;
; Simple YM-digi 8-bit sample sequencer, 15650 Hz
; Samples are pre-shifted to 16-bit / sample to speed up volume table lookup
; Does not work on Falcon


ym8length:	equ	55214


		section	text


; 		8-bit YMdigi code during overscan/syncscroll/plasma
;		a6 = lookup volume table address
;		a5 = stream address (with shift-prepared word/sample data)
;		a4 = $ffff8800.w
;		d4-d6 trashed but not locked
music_ymdigi8_play_sample:	macro
		move.w	(a5)+,d6		;2
		movem.l	(a6,d6.w),d4-d6		;11
		movem.l	d4-d6,(a4)		;10
		endm


music_ymdigi8_load:
		move.l	#music_ymfn_01,filename
		move.l	#music_ym01,filebuffer
		move.l	#ym8length,filelength
		jsr	loader

		move.l	#music_ymfn_02,filename
		move.l	#music_ym02,filebuffer
		move.l	#ym8length,filelength
		jsr	loader

		rts


music_ymdigi8_init:

		;Setup YM for sample playback
		lea	$ffff8800.w,a0

		move.l	#$00000000,(a0)				;Channel 1 tone period 0
		move.l	#$01000000,(a0)				;

		move.l	#$02000000,(a0)				;Channel 3 tone period 0
		move.l	#$03000000,(a0)				;

		move.l	#$04000000,(a0)				;Channel 3 tone period 0
		move.l	#$05000000,(a0)				;

		move.b	#7,(a0)					;Mixing all channels
		move.b	(a0),d0					;
		and.b	#%11000000,d0				;
		or.b	#%00111111,d0				;
		move.b	#7,(a0)					;
		move.b	d0,2(a0)				;

		;init sequence
		move.l	music_seq,music_ymdigi8_sample_shifted_pos

		rts

music_ymdigi8_exit:
		move.l	#$08000000,$ffff8800.w			;Channel 1 silence
		move.l	#$09000000,$ffff8800.w			;Channel 2 silence
		move.l	#$0a000000,$ffff8800.w			;Channel 3 silence
		rts


music_ymdigi8_vbl:

		move.l	music_seq_pos,a0
		move.l	4(a0),d0				;end address
		sub.l	#313*2,d0
		move.l	music_ymdigi8_sample_shifted_pos,d1	;start address
		sub.l	d1,d0
		bpl.s	.cont					;not time for next sequence yet
		addq.l	#8,a0					;next sequence
		tst.l	(a0)
		beq.s	.wrap					;sequence ended, start from the beginning
		move.l	a0,music_seq_pos
		bra.s	.set
.wrap:		move.l	#music_seq,music_seq_pos
		move.l	#music_seq,a0
.set:		move.l	(a0),music_ymdigi8_sample_shifted_pos
.cont:		rts


music_ymdigi8_timer:						;HBL (or other interrupt) routine
		movem.l	a6/d6-d7,-(sp)				;Uses no registers

		move.l	music_ymdigi8_sample_shifted_pos,a6	;
		move.w	(a6)+,d7				;
		move.l	a6,music_ymdigi8_sample_shifted_pos	;
		movem.l	music_ymdigi8_lut(pc,d7.w),a6/d6-d7	;
		movem.l	a6/d6-d7,$ffff8800.w			;

		movem.l	(sp)+,a6/d6-d7				;
		rte						;

music_ymdigi8_lut:
		incbin	'sys/wizvol.8'				;Wizzcat volume table
		even


		section	data



music_ymdigi8_sample_shifted_pos:
		dc.l	0

music_seq_pos:	dc.l	music_seq

music_seq:
		dc.l	music_ym01,music_ym01+ym8length
		dc.l	music_ym01,music_ym01+ym8length
		dc.l	music_ym01,music_ym01+ym8length
		dc.l	music_ym02,music_ym02+ym8length
		dc.l	0

music_ymfn_01:	dc.b	'music\02s.ym8',0
		even

music_ymfn_02:	dc.b	'music\03s.ym8',0
		even


		section	bss

music_ym01:	ds.b	ym8length
music_ym02:	ds.b	ym8length


		section	text
