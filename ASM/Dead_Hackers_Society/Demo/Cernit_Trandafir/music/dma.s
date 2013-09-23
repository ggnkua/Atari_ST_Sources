; Atari ST/e synclock demosystem
; January 9, 2008
;
; dma.s
;
; Simple STe DMA sound sample sequencer

		ifne	floppy
music_size:	equ	653176
		else
music_size:	equ	1306256
		endc



dma_loop:	equ	1				;loop music sequence


		
		section	text




music_dma_init:	move.l	music_seq,music_seq_dat

		move.l	#sample_empty,d0
		move.l	#sample_empty_end,d1

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

		ifne	floppy
		move.b	#%10000001,$ffff8921.w 		;12517Hz mono
		else
		move.b	#%10000010,$ffff8921.w 		;25033Hz mono
		endc
		move.b	#%00000011,$ffff8901.w		;Start sample with loop

		rts


music_dma_play:	sub.l	#1000,music_seq_dat
		bpl.s	.done
		add.l	#1000,music_seq_dat		;save the remaining ticks to next loop

		ifne	dma_loop
		move.l	music_seq_adr,a0
		cmp.l	#-1,12(a0)
		bne.s	.no_loop
		move.l	#music_seq,music_seq_adr
.no_loop:
		endc

		add.l	#12,music_seq_adr
		move.l	music_seq_adr,a0
		move.l	(a0)+,d0
		add.l	d0,music_seq_dat
		move.l	(a0)+,music_start
		move.l	(a0)+,music_end


		lea.l	music_start,a0
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



;--------------- Fast forward stuff
		if music_ofs > 0

		ifne	floppy				;Length of sample per vbl*64
music_vblsize:	equ	16022				;12.5 kHz mono 12517/50*64
		else
music_vblsize:	equ	32084				;25 kHz mono 25066/50*64
		endc

music_dma_ffwd:
		clr.b	$ffff8901.w			;kill sample playback

		;run the music vbl rout 
		move.w	#music_ofs-1,.count
.loop:		bsr.w	music_dma_play
		subq.w	#1,.count
		bpl.s	.loop

		;start the music at the correct offset
		move.l	music_seq_adr,a0
		move.l	(a0)+,d2			;num vbls*1024 for entire loop
		move.l	(a0)+,d0			;start
		move.l	(a0)+,d1			;end

		move.l	music_seq_dat,d3		;remaining vbls*1000 for this loop
		sub.l	d3,d2				;vbls that have been played of this loop
		lsr.l	#8,d2 ;/256
		;lsr.l	#2,d2				;actual vbls
		divu.w	#4,d2
		mulu.w	#music_vblsize,d2		;
		lsr.l	#6,d2				;bytes of these vbls
		add.l	d0,d2				;samplestart+ofset


		move.b	d2,$ffff8907.w			;Start of sample
		lsr.l	#8,d2				;
		move.b	d2,$ffff8905.w			;
		lsr.l	#8,d2				;
		move.b	d2,$ffff8903.w			;

		move.b	d1,$ffff8913.w			;End of sample
		lsr.l	#8,d1				;
		move.b	d1,$ffff8911.w			;
		lsr.l	#8,d1				;
		move.b	d1,$ffff890f.w			;

		move.b	#%00000011,$ffff8901.w		;Start at offset

		move.b	d0,$ffff8907.w			;Start of sample - make sure the sample loops at the real start
		lsr.l	#8,d0				;
		move.b	d0,$ffff8905.w			;
		lsr.l	#8,d0				;
		move.b	d0,$ffff8903.w			;

		rts
.count:		dc.w	0
		endc



		section	data

; vbls,address,length
; for pause: length,0,0

		ifne	floppy
s:		set	21772				;small loop size 12.5 kHz
b:		set	43543				;big loop size 12.5 kHz
		else
s:		set	43541				;small loop size 25 kHz
b:		set	87081				;big loop size 25 kHz
		endc
	
svbl:		set	86967 ;(*1000) ;87			;playtime of small loop
bvbl:		set	173912 ;(*1000) ;174			;playtime of big loop

l00s:		equ	zik+44
l00e:		equ	zik+44+s
l01s:		equ	zik+44+s
l01e:		equ	zik+44+s+s
l02s:		equ	zik+44+s+s
l02e:		equ	zik+44+s+s+s
l03s:		equ	zik+44+s+s+s
l03e:		equ	zik+44+s+s+s+s
l04s:		equ	zik+44+s+s+s+s
l04e:		equ	zik+44+s+s+s+s+b
l05s:		equ	zik+44+s+s+s+s+b
l05e:		equ	zik+44+s+s+s+s+b+s
l06s:		equ	zik+44+s+s+s+s+b+s
l06e:		equ	zik+44+s+s+s+s+b+s+s
l07s:		equ	zik+44+s+s+s+s+b+s+s
l07e:		equ	zik+44+s+s+s+s+b+s+s+s
l08s:		equ	zik+44+s+s+s+s+b+s+s+s
l08e:		equ	zik+44+s+s+s+s+b+s+s+s+s
l13s:		equ	zik+44+s+s+s+s+b+s+s+s+s
l13e:		equ	zik+44+s+s+s+s+b+s+s+s+s+b
l14s:		equ	zik+44+s+s+s+s+b+s+s+s+s+b
l14e:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s
l15s:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s
l15e:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s
l16s:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s
l16e:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s
l17s:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s
l17e:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s+s
l18s:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s+s
l18e:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s+s+s
l19s:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s+s+s
l19e:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s+s+s+s
l20s:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s+s+s+s
l20e:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s+s+s+s+s
l21s:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s+s+s+s+s
l21e:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s+s+s+s+s+s
l22s:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s+s+s+s+s+s
l22e:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s+s+s+s+s+s+s
l23s:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s+s+s+s+s+s+s
l23e:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s+s+s+s+s+s+s+s
l24s:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s+s+s+s+s+s+s+s
l24e:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s+s+s+s+s+s+s+s+s
l25s:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s+s+s+s+s+s+s+s+s
l25e:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s+s+s+s+s+s+s+s+s+s
l26s:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s+s+s+s+s+s+s+s+s+s
l26e:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s+s+s+s+s+s+s+s+s+s+b
l27s:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s+s+s+s+s+s+s+s+s+s+b
l27e:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s+s+s+s+s+s+s+s+s+s+b+s
l28s:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s+s+s+s+s+s+s+s+s+s+b+s
l28e:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s+s+s+s+s+s+s+s+s+s+b+s+s
l29s:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s+s+s+s+s+s+s+s+s+s+b+s+s
l29e:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s+s+s+s+s+s+s+s+s+s+b+s+s+s
l30s:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s+s+s+s+s+s+s+s+s+s+b+s+s+s
l30e:		equ	zik+44+s+s+s+s+b+s+s+s+s+b+s+s+s+s+s+s+s+s+s+s+s+s+b+s+s+s+s



music_seq:
		dc.l	1,sample_empty,sample_empty_end

		dc.l	svbl-1000,l00s,l00e	;position 001
		dc.l	svbl-1000,l00s,l00e	;position 002
		dc.l	svbl-1000,l01s,l01e	;position 003
		dc.l	svbl-1000,l02s,l02e	;position 004
		dc.l	svbl-1000,l02s,l02e	;position 005
		dc.l	svbl-1000,l02s,l02e	;position 006
		dc.l	svbl-1000,l01s,l01e	;position 007
		dc.l	svbl-1000,l02s,l02e	;position 008
		dc.l	svbl-1000,l02s,l02e	;position 009
		dc.l	svbl-1000,l02s,l02e	;position 010
		dc.l	svbl-1000,l01s,l01e	;position 011
		dc.l	svbl-1000,l02s,l02e	;position 012
		dc.l	svbl-1000,l02s,l02e	;position 013
		dc.l	svbl-1000,l02s,l02e	;position 014
		dc.l	svbl-1000,l01s,l01e	;position 015
		dc.l	svbl-1000,l02s,l02e	;position 016
		dc.l	svbl-1000,l02s,l02e	;position 017
		dc.l	svbl-1000,l02s,l02e	;position 018
		dc.l	svbl-1000,l01s,l01e	;position 019
		dc.l	svbl-1000,l02s,l02e	;position 020
		dc.l	svbl-1000,l02s,l02e	;position 021
		dc.l	svbl-1000,l02s,l02e	;position 022
		rept	14
		dc.l	svbl-1000,l03s,l03e	;position 023 - 036
		endr
		dc.l	bvbl-1000,l04s,l04e	;position 037
		dc.l	svbl-1000,l05s,l05e	;position 038
		dc.l	svbl-1000,l05s,l05e	;position 039
		dc.l	svbl-1000,l08s,l08e	;position 040
		dc.l	svbl-1000,l08s,l08e	;position 041
		dc.l	svbl-1000,l07s,l07e	;position 042
		dc.l	svbl-1000,l07s,l07e	;position 043
		dc.l	svbl-1000,l08s,l08e	;position 044
		dc.l	svbl-1000,l08s,l08e	;position 045
		dc.l	svbl-1000,l05s,l05e	;position 046
		dc.l	svbl-1000,l05s,l05e	;position 047
		dc.l	svbl-1000,l06s,l06e	;position 048
		dc.l	svbl-1000,l06s,l06e	;position 049
		dc.l	svbl-1000,l07s,l07e	;position 050
		dc.l	svbl-1000,l07s,l07e	;position 051
		dc.l	svbl-1000,l08s,l08e	;position 052
		dc.l	bvbl-1000,l13s,l13e	;position 053
		dc.l	svbl-1000,l01s,l01e	;position 054
		dc.l	svbl-1000,l02s,l02e	;position 055
		dc.l	svbl-1000,l01s,l01e	;position 056
		dc.l	svbl-1000,l02s,l02e	;position 057
		dc.l	svbl-1000,l01s,l01e	;position 058
		dc.l	svbl-1000,l02s,l02e	;position 059
		dc.l	svbl-1000,l01s,l01e	;position 060
		dc.l	svbl-1000,l02s,l02e	;position 061
		dc.l	svbl-1000,l03s,l03e	;position 062
		dc.l	svbl-1000,l03s,l03e	;position 063
		dc.l	svbl-1000,l14s,l14e	;position 064
		dc.l	svbl-1000,l15s,l15e	;position 065
		dc.l	svbl-1000,l03s,l03e	;position 066
		dc.l	svbl-1000,l03s,l03e	;position 067
		dc.l	svbl-1000,l14s,l14e	;position 068
		dc.l	svbl-1000,l15s,l15e	;position 069
		dc.l	svbl-1000,l16s,l16e	;position 070
		dc.l	svbl-1000,l16s,l16e	;position 071
		dc.l	svbl-1000,l15s,l15e	;position 072
		dc.l	svbl-1000,l14s,l14e	;position 073
		dc.l	svbl-1000,l16s,l16e	;position 074
		dc.l	svbl-1000,l16s,l16e	;position 075
		dc.l	svbl-1000,l15s,l15e	;position 076
		dc.l	svbl-1000,l14s,l14e	;position 077
		dc.l	bvbl-1000,l04s,l04e	;position 078
		dc.l	svbl-1000,l17s,l17e	;position 079
		dc.l	svbl-1000,l17s,l17e	;position 080
		dc.l	svbl-1000,l17s,l17e	;position 081
		dc.l	svbl-1000,l18s,l18e	;position 082
		dc.l	svbl-1000,l17s,l17e	;position 083
		dc.l	svbl-1000,l17s,l17e	;position 084
		dc.l	svbl-1000,l17s,l17e	;position 085
		dc.l	svbl-1000,l18s,l18e	;position 086
		dc.l	svbl-1000,l19s,l19e	;position 087
		dc.l	svbl-1000,l19s,l19e	;position 088
		dc.l	svbl-1000,l19s,l19e	;position 089
		dc.l	svbl-1000,l20s,l20e	;position 090
		dc.l	svbl-1000,l19s,l19e	;position 091
		dc.l	svbl-1000,l19s,l19e	;position 092
		dc.l	svbl-1000,l19s,l19e	;position 093
		dc.l	svbl-1000,l21s,l21e	;position 094
		dc.l	svbl-1000,l19s,l19e	;position 095
		dc.l	svbl-1000,l19s,l19e	;position 096
		dc.l	svbl-1000,l19s,l19e	;position 097
		dc.l	svbl-1000,l20s,l20e	;position 098
		dc.l	svbl-1000,l19s,l19e	;position 099
		dc.l	svbl-1000,l19s,l19e	;position 100
		dc.l	svbl-1000,l19s,l19e	;position 101
		dc.l	svbl-1000,l21s,l21e	;position 102
		dc.l	svbl-1000,l22s,l22e	;position 103
		dc.l	svbl-1000,l23s,l23e	;position 104
		dc.l	svbl-1000,l24s,l24e	;position 105
		dc.l	svbl-1000,l24s,l24e	;position 106
		dc.l	svbl-1000,l24s,l24e	;position 107
		dc.l	svbl-1000,l25s,l25e	;position 108
		dc.l	svbl-1000,l25s,l25e	;position 109
		dc.l	svbl-1000,l25s,l25e	;position 110
		dc.l	svbl-1000,l25s,l25e	;position 111
		dc.l	svbl-1000,l24s,l24e	;position 112
		dc.l	svbl-1000,l24s,l24e	;position 113
		dc.l	svbl-1000,l24s,l24e	;position 114
		dc.l	svbl-1000,l24s,l24e	;position 115
		dc.l	svbl-1000,l25s,l25e	;position 116 
		dc.l	svbl-1000,l25s,l25e	;position 117
		dc.l	svbl-1000,l25s,l25e	;position 118
		dc.l	svbl-1000,l25s,l25e	;position 119
		dc.l	svbl-1000,l23s,l23e	;position 120
		dc.l	svbl-1000,l24s,l24e	;position 121
		dc.l	svbl-1000,l24s,l24e	;position 122
		dc.l	svbl-1000,l24s,l24e	;position 123
		dc.l	svbl-1000,l25s,l25e	;position 124
		dc.l	svbl-1000,l25s,l25e	;position 125
		dc.l	svbl-1000,l25s,l25e	;position 126
		dc.l	svbl-1000,l25s,l25e	;position 127
		dc.l	svbl-1000,l24s,l24e	;position 128
		dc.l	svbl-1000,l24s,l24e	;position 129
		dc.l	svbl-1000,l24s,l24e	;position 130
		dc.l	svbl-1000,l24s,l24e	;position 131
		dc.l	svbl-1000,l25s,l25e	;position 132
		dc.l	svbl-1000,l25s,l25e	;position 133
		dc.l	svbl-1000,l25s,l25e	;position 134
		dc.l	svbl-1000,l25s,l25e	;position 135
		dc.l	bvbl-1000,l26s,l26e	;position 136
		dc.l	svbl-1000,l27s,l27e	;position 137
		dc.l	svbl-1000,l28s,l28e	;position 138
		dc.l	svbl-1000,l27s,l27e	;position 139
		dc.l	svbl-1000,l28s,l28e	;position 140
		dc.l	svbl-1000,l27s,l27e	;position 141
		dc.l	svbl-1000,l28s,l28e	;position 142
		dc.l	svbl-1000,l27s,l27e	;position 143
		dc.l	svbl-1000,l28s,l28e	;position 144
		dc.l	svbl-1000,l27s,l27e	;position 145
		dc.l	svbl-1000,l28s,l28e	;position 146
		dc.l	svbl-1000,l27s,l27e	;position 147
		dc.l	svbl-1000,l28s,l28e	;position 148
		dc.l	svbl-1000,l27s,l27e	;position 149
		dc.l	svbl-1000,l28s,l28e	;position 150
		dc.l	svbl-1000,l27s,l27e	;position 151
		dc.l	svbl-1000,l28s,l28e	;position 152
		dc.l	svbl-1000,l29s,l29e	;position 152
		dc.l	svbl-1000,l30s,l30e	;position 154
		dc.l	svbl-1000,l30s,l30e	;position 155
		dc.l	svbl-1000,l30s,l30e	;position 156
		dc.l	svbl-1000,l30s,l30e	;position 157
		dc.l	svbl-1000,l30s,l30e	;position 158
		dc.l	svbl-1000,l03s,l03e	;position 159
		dc.l	svbl-1000,l03s,l03e	;position 160
		dc.l	svbl-1000,l03s,l03e	;position 161
		dc.l	svbl-1000,l03s,l03e	;position 162
		dc.l	svbl-1000,l03s,l03e	;position 163
		dc.l	svbl-1000,l03s,l03e	;position 164
		dc.l	svbl-1000,l03s,l03e	;position 165
		dc.l	svbl-1000,l03s,l03e	;position 166
		dc.l	bvbl-1000,l04s,l04e	;position 167
		dc.l	svbl-1000,l05s,l05e	;position 168
		dc.l	svbl-1000,l05s,l05e	;position 169
		dc.l	svbl-1000,l08s,l08e	;position 170
		dc.l	svbl-1000,l08s,l08e	;position 171
		dc.l	svbl-1000,l07s,l07e	;position 172 
		dc.l	svbl-1000,l07s,l07e	;position 173
		dc.l	svbl-1000,l08s,l08e	;position 174
		dc.l	svbl-1000,l08s,l08e	;position 175
		dc.l	svbl-1000,l05s,l05e	;position 176
		dc.l	svbl-1000,l05s,l05e	;position 177
		dc.l	svbl-1000,l06s,l06e	;position 178
		dc.l	svbl-1000,l06s,l06e	;position 179
		dc.l	svbl-1000,l07s,l07e	;position 180
		dc.l	svbl-1000,l07s,l07e	;position 181
		dc.l	svbl-1000,l08s,l08e	;position 182
		dc.l	svbl-1000,l08s,l08e	;position 183
		dc.l	svbl-1000,l05s,l05e	;position 184
		dc.l	svbl-1000,l05s,l05e	;position 185
		dc.l	svbl-1000,l08s,l08e	;position 186	
		dc.l	svbl-1000,l08s,l08e	;position 187
		dc.l	svbl-1000,l07s,l07e	;position 188
		dc.l	svbl-1000,l07s,l07e	;position 189
		dc.l	svbl-1000,l08s,l08e	;position 190
		dc.l	svbl-1000,l08s,l08e	;position 191
		dc.l	svbl-1000,l05s,l05e	;position 192
		dc.l	svbl-1000,l05s,l05e	;position 193
		dc.l	svbl-1000,l06s,l06e	;position 194
		dc.l	svbl-1000,l06s,l06e	;position 195
		dc.l	svbl-1000,l07s,l07e	;position 196
		dc.l	svbl-1000,l07s,l07e	;position 197
		dc.l	svbl-1000,l08s,l08e	;position 198
		dc.l	bvbl-1000,l13s,l13e	;position 199

		dc.l	3000,sample_empty,sample_empty_end
		dc.l	-1,sample_empty,sample_empty_end



		;test of all loops in a row
		ifne	0
		dc.l	svbl-1000,l00s,l00e
		dc.l	svbl-1000,l01s,l01e
		dc.l	svbl-1000,l02s,l02e
		dc.l	svbl-1000,l03s,l03e
		dc.l	bvbl-1000,l04s,l04e
		dc.l	svbl-1000,l05s,l05e
		dc.l	svbl-1000,l06s,l06e
		dc.l	svbl-1000,l07s,l07e
		dc.l	svbl-1000,l08s,l08e
		dc.l	bvbl-1000,l13s,l13e
		dc.l	svbl-1000,l14s,l14e
		dc.l	svbl-1000,l15s,l15e
		dc.l	svbl-1000,l16s,l16e
		dc.l	svbl-1000,l17s,l17e
		dc.l	svbl-1000,l18s,l18e
		dc.l	svbl-1000,l19s,l19e
		dc.l	svbl-1000,l20s,l20e
		dc.l	svbl-1000,l21s,l21e
		dc.l	svbl-1000,l22s,l22e
		dc.l	svbl-1000,l23s,l23e
		dc.l	svbl-1000,l24s,l24e
		dc.l	svbl-1000,l25s,l25e
		dc.l	bvbl-1000,l26s,l26e
		dc.l	svbl-1000,l27s,l27e
		dc.l	svbl-1000,l28s,l28e
		dc.l	svbl-1000,l29s,l29e
		dc.l	svbl-1000,l30s,l30e
		endc
		
music_seq_adr:	dc.l	music_seq
music_seq_dat:	dc.l	0

		ifne	floppy
music_filename:	dc.b	'cern12.wav',0,0
		else
music_filename:	dc.b	'cern25.wav',0,0
		endc
		even



		even
sample_empty:	dcb.l	256,0
sample_empty_end:
		even

		section	bss

zik:
music_sample:	ds.b	music_size
		even

		
		section	text
