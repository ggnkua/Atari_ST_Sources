; Atari ST/e synclock demosystem
; January 9, 2008
;
; dma.s
;
; Simple STe DMA sound sample sequencer



		section	text


music_dma_init:
		move.w	#%10000000001,d0		;mix DMA+YM equally
		bsr.w	lmc1992
		move.w	#%10001000110,d0		+0db bass
		bsr.w	lmc1992
		move.w	#%10010000110,d0		;+0db treble
		bsr.w	lmc1992
		move.w	#%10011101000,d0		;-0db master volume
		bsr.w	lmc1992
		move.w	#%10100010100,d0		;-0db right
		bsr.w	lmc1992
		move.w	#%10101010100,d0		;-0db left
		bsr.w	lmc1992


		ifeq	standalone
		move.l	$40.w,music_data_adr
		endc
		ifne	standalone
		move.l	#music_data,music_data_adr
		endc

		move.l	music_data_adr,d0
		jsr	music_relocate

		move.l	music_seq,music_seq_dat

		move.l	#sample_empty,d0
		move.l	#sample_empty_end,d1

		move.b	d0,$ffff8907			;Start of sample
		lsr.l	#8,d0				;
		move.b	d0,$ffff8905			;
		lsr.l	#8,d0				;
		move.b	d0,$ffff8903			;

		move.b	d1,$ffff8913			;End of sample
		lsr.l	#8,d1				;
		move.b	d1,$ffff8911			;
		lsr.l	#8,d1				;
		move.b	d1,$ffff890f			;

		move.b	#%10000010,$ffff8921.w 		;25033Hz mono
		move.b	#%00000011,$ffff8901.w		;Start sample with loop

		rts


music_dma_play:	subq.l	#1,music_seq_dat
		bne.s	.done

		move.l	music_seq_adr,a0
		lea.l	12(a0),a0
		
		move.l	a0,music_seq_adr
		move.l	(a0)+,music_seq_dat
		move.l	(a0)+,music_start
		move.l	(a0)+,music_end

		lea.l	music_start(pc),a0
		move.b	3(a0),$ffff8907.w		;Start of sample
		move.b	2(a0),$ffff8905.w		;
		move.b	1(a0),$ffff8903.w		;

		move.b	7(a0),$ffff8913.w		;End of sample
		move.b	6(a0),$ffff8911.w		;
		move.b	5(a0),$ffff890f.w		;

.done:		rts
		
music_start:	dc.l	sample_empty
music_end:	dc.l	sample_empty_end
music_switch:	dc.w	0


music_dma_exit:	clr.b	$ffff8901.w			;kill sample playback
		rts



		section	data


;--- START OF 505 MUSIC ----------------------------------------------------------
		ifne	dmazik_505

music_1:	equ	0
music_1_end:	equ	0+24739
music_2:	equ	0+24739
music_2_end:	equ	0+24739+49479
music_3:	equ	0+24739+49479
music_3_end:	equ	0+24739+49479+49479
music_4:	equ	0+24739+49479+49479
music_4_end:	equ	0+24739+49479+49479+98958
music_5:	equ	0+24739+49479+49479+98958
music_5_end:	equ	0+24739+49479+49479+98958+98958
music_6:	equ	0+24739+49479+49479+98958+98958
music_6_end:	equ	0+24739+49479+49479+98958+98958+98958
music_7:	equ	0+24739+49479+49479+98958+98958+98958
music_7_end:	equ	0+24739+49479+49479+98958+98958+98958+98958
music_8:	equ	0+24739+49479+49479+98958+98958+98958+98958
music_8_end:	equ	0+24739+49479+49479+98958+98958+98958+98958+98958

music_bd:	equ	0+24739
music_bd_end:	equ	0+24739+11264

music_relocate:
		;input: d0.l=address to sample base
		lea.l	music_seq,a1
.loop:
		tst.l	(a1)
		beq.s	.done

		addq.l	#4,a1
		add.l	d0,(a1)+
		add.l	d0,(a1)+
		bra.s	.loop
		
.done:		rts

		section	data

music_seq:


		dc.l	49-1,music_1,music_1_end
		dc.l	49-1,music_1,music_1_end
		dc.l	49-1,music_1,music_1_end
		dc.l	49-1,music_1,music_1_end
		dc.l	49-1,music_1,music_1_end
		dc.l	49-1,music_1,music_1_end
		dc.l	49-1,music_1,music_1_end
		dc.l	49-1,music_1,music_1_end	;8

		dc.l	49-1,music_1,music_1_end
		dc.l	49-1,music_1,music_1_end
		dc.l	49-1,music_1,music_1_end
		dc.l	49-1,music_1,music_1_end
		;dc.l	49-1,music_1,music_1_end
		;dc.l	49-1,music_1,music_1_end
		;dc.l	49-1,music_1,music_1_end
		;dc.l	49-1,music_1,music_1_end	;8

		dc.l	98-1,music_2,music_2_end
		dc.l	98-1,music_2,music_2_end
		dc.l	98-1,music_2,music_2_end
		dc.l	98-1,music_2,music_2_end	;8

		dc.l	98-1,music_3,music_3_end
		dc.l	98-1,music_3,music_3_end
		dc.l	98-1,music_3,music_3_end
		dc.l	98-1,music_3,music_3_end	;8

		dc.l	197-1,music_4,music_4_end
		dc.l	197-1,music_4,music_4_end
		dc.l	197-1,music_4,music_4_end
		dc.l	197-1,music_4,music_4_end	;16

		dc.l	197-1,music_5,music_5_end
		dc.l	197-1,music_5,music_5_end
		dc.l	197-1,music_6,music_6_end
		dc.l	197-1,music_6,music_6_end
		dc.l	197-1,music_5,music_5_end
		dc.l	197-1,music_5,music_5_end
		dc.l	197-1,music_6,music_6_end
		dc.l	197-1,music_6,music_6_end	;32

		dc.l	197-1,music_7,music_7_end
		dc.l	197-1,music_8,music_8_end
		dc.l	197-1,music_7,music_7_end
		dc.l	197-1,music_8,music_8_end
		dc.l	197-1,music_7,music_7_end
		dc.l	197-1,music_8,music_8_end
		dc.l	197-1,music_7,music_7_end
		dc.l	197-1,music_8,music_8_end	;32


;----	104

		dc.l	197-1,music_5,music_5_end
		dc.l	197-1,music_5,music_5_end
		dc.l	197-1,music_6,music_6_end
		dc.l	197-1,music_6,music_6_end
		dc.l	197-1,music_5,music_5_end
		dc.l	197-1,music_5,music_5_end
		dc.l	197-1,music_6,music_6_end
		dc.l	197-1,music_6,music_6_end	;32

		dc.l	197-1,music_4,music_4_end
		dc.l	197-1,music_4,music_4_end
		dc.l	197-1,music_4,music_4_end
		dc.l	197-1,music_4,music_4_end	;16

		dc.l	98-1,music_3,music_3_end
		dc.l	98-1,music_3,music_3_end
		dc.l	98-1,music_3,music_3_end
		dc.l	98-1,music_3,music_3_end	;8

		dc.l	197-1,music_4,music_4_end
		dc.l	197-1,music_4,music_4_end
		dc.l	197-1,music_4,music_4_end
		dc.l	197-1,music_4,music_4_end	;16

		dc.l	197-1,music_5,music_5_end
		dc.l	197-1,music_5,music_5_end
		dc.l	197-1,music_6,music_6_end
		dc.l	197-1,music_6,music_6_end
		dc.l	197-1,music_5,music_5_end
		dc.l	197-1,music_5,music_5_end
		dc.l	197-1,music_6,music_6_end
		dc.l	197-1,music_6,music_6_end	;32

		dc.l	197-1,music_7,music_7_end
		dc.l	197-1,music_8,music_8_end
		dc.l	197-1,music_7,music_7_end
		dc.l	197-1,music_8,music_8_end
		dc.l	197-1,music_7,music_7_end
		dc.l	197-1,music_8,music_8_end
		dc.l	197-1,music_7,music_7_end
		dc.l	197-1,music_8,music_8_end	;32
;---	136

		dc.l	197-1,music_5,music_5_end
		dc.l	197-1,music_5,music_5_end
		dc.l	197-1,music_6,music_6_end
		dc.l	197-1,music_6,music_6_end
		dc.l	197-1,music_5,music_5_end
		dc.l	197-1,music_5,music_5_end
		dc.l	197-1,music_6,music_6_end
		dc.l	197-1,music_6,music_6_end	;32

		dc.l	197-1,music_4,music_4_end
		dc.l	197-1,music_4,music_4_end
		dc.l	197-1,music_4,music_4_end
		dc.l	197-1,music_4,music_4_end
		dc.l	197-1,music_4,music_4_end
		dc.l	197-1,music_4,music_4_end	;24

		dc.l	197-1,music_5,music_5_end
		dc.l	197-1,music_5,music_5_end
		dc.l	197-1,music_6,music_6_end
		dc.l	197-1,music_6,music_6_end	;16

		dc.l	197-1,music_5,music_5_end
		dc.l	197-1,music_5,music_5_end
		dc.l	197-1,music_6,music_6_end
		dc.l	197-1,music_6,music_6_end	;16

		dc.l	197-1,music_4,music_4_end
		dc.l	197-1,music_4,music_4_end
		dc.l	197-1,music_4,music_4_end
		dc.l	197-1,music_4,music_4_end	;16


		dc.l	197-1,music_4,music_4_end	;4


		dc.l	22-1,music_bd,music_bd_end	;0.5


;	96

;=336
		dc.l	0

	

music_seq_adr:	dc.l	music_seq
music_seq_dat:	dc.l	0

music_data_adr:	dc.l	0	;music_data

		ifne	standalone
music_data:	incbin	'music/505_v1/all.raw'
		even
		endc

		endc


;--- END OF 505 MUSIC ----------------------------------------------------------



sample_empty:	dcb.l	256,$00000000
sample_empty_end:
		
		section	text
